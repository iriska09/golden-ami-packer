set -e

echo "Enabling and starting sshd..."
sudo systemctl enable sshd
sudo systemctl start sshd


echo "Updating system..."
sudo dnf update -y

echo "Installing Ansible..."
sudo dnf install -y ansible-core

echo "Bootstrap complete."

echo "Installing CloudWatch Agent..."
sudo dnf install -y amazon-cloudwatch-agent

echo "Installing SSM Agent..."
sudo dnf install -y amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent



echo "[*] Starting CIS Level 1 Hardening for Amazon Linux 2023..."

# Variables
SSHD_CONFIG="/etc/ssh/sshd_config"
AIDE_CONFIG="/etc/aide.conf"
AIDE_DB="/var/lib/aide/aide.db.gz"
SYSCTL_CONF="/etc/sysctl.d/99-hardening.conf"
LIMITS_CONF="/etc/security/limits.d/hardening.conf"

# SSH Hardening
echo "[*] Hardening SSH configuration..."
cat <<EOF >> "$SSHD_CONFIG"

# ANSIBLE MANAGED BLOCK - SSH HARDENING
PermitRootLogin no
PasswordAuthentication no
Protocol 2
Port 22
LogLevel VERBOSE
X11Forwarding no
MaxAuthTries 3
MaxSessions 2
ClientAliveInterval 300
ClientAliveCountMax 2
AllowTcpForwarding no
AllowAgentForwarding no
Compression no
PermitEmptyPasswords no
PermitUserEnvironment no
TCPKeepAlive no
EOF

echo "[*] Restarting sshd..."
systemctl restart sshd

# Kernel Parameters
echo "[*] Applying kernel hardening sysctl settings..."
cat <<EOF > "$SYSCTL_CONF"
fs.protected_fifos = 2
fs.protected_regular = 2
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
fs.suid_dumpable = 0
kernel.kptr_restrict = 2
kernel.perf_event_paranoid = 3
kernel.yama.ptrace_scope = 1
kernel.core_uses_pid = 1
kernel.dmesg_restrict = 1
kernel.randomize_va_space = 2
kernel.unprivileged_bpf_disabled = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.tcp_syncookies = 1
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
EOF

sysctl --system

# Install and Configure AIDE
echo "[*] Installing AIDE..."
dnf install -y aide

mkdir -p /var/lib/aide /var/log/aide
chmod 700 /var/lib/aide /var/log/aide

echo "[*] Configuring AIDE..."
cat <<EOF > "$AIDE_CONFIG"
database=file:/var/lib/aide/aide.db.gz
database_out=file:/var/lib/aide/aide.db.new.gz
gzip_dbout=yes
report_url=file:/var/log/aide/aide.log
report_url=stdout
log_level=info
report_level=info

@@define DBDIR /var/lib/aide
@@define LOGDIR /var/log/aide

@@define CUSTOMRULE p+i+n+u+g+s+b+m+c+md5+sha256

/bin    CUSTOMRULE
/sbin   CUSTOMRULE
/lib    CUSTOMRULE
/lib64  CUSTOMRULE
/usr    CUSTOMRULE
/etc    CUSTOMRULE
/boot   CUSTOMRULE
/opt    CUSTOMRULE
/root   CUSTOMRULE
/var    CUSTOMRULE
EOF

echo "[*] Initializing AIDE database..."
if /usr/sbin/aide --init --config="$AIDE_CONFIG" | grep -q 'AIDE database initialized'; then
  mv /var/lib/aide/aide.db.new.gz "$AIDE_DB"
  echo "[+] AIDE database installed successfully."
fi

# RKHunter
echo "[*] Installing rkhunter..."
dnf install -y rkhunter
rkhunter --update

echo "[*] Setting up daily rkhunter scan..."
(crontab -l 2>/dev/null; echo "30 4 * * * /usr/bin/rkhunter --cronjob --report-warnings-only") | crontab -

# Disable Unused Services
echo "[*] Disabling unnecessary services..."
for svc in rpcbind nfs-server avahi-daemon cups; do
  systemctl disable --now "$svc" || true
done

# UMask for systemd
echo "[*] Configuring restrictive UMask..."
sed -i '/^#*UMask=/d' /etc/systemd/system.conf
echo "UMask=027" >> /etc/systemd/system.conf
systemctl daemon-reexec

# Password Policy
echo "[*] Setting password policy..."
cat <<EOF >> /etc/login.defs

# ANSIBLE MANAGED BLOCK - PASSWORD POLICIES
PASS_MAX_DAYS 90
PASS_MIN_DAYS 7
PASS_WARN_AGE 14
UMASK 027
SHA_CRYPT_MIN_ROUNDS 640000
EOF

# Limits
echo "[*] Configuring secure limits..."
cat <<EOF > "$LIMITS_CONF"
* hard core 0
* hard maxlogins 10
* hard nproc 512
EOF

# Firewalld
echo "[*] Installing and configuring firewalld..."
dnf install -y firewalld
systemctl enable --now firewalld
firewall-cmd --set-default-zone=drop
firewall-cmd --reload

echo "[✓] Hardening complete."

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





# Enhanced System Hardening Script
# Targets Lynis score of 90% or higher
# Includes all fixes for the warnings and suggestions from Lynis report

# Global Variables
SSH_TIMEOUT=300
LOG_FILE="/var/log/hardening-$(date +%Y%m%d).log"

# Initialize logging
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=============================================="
echo " Starting Comprehensive System Hardening      "
echo " Target: Lynis Score 90%+                    "
echo " Date: $(date)                               "
echo "=============================================="

# 1. System Update and Package Management
echo "[1/10] System Update and Package Management..."
dnf update -y && dnf upgrade -y
dnf install -y aide fail2ban rkhunter clamav

# 2. Filesystem Hardening
echo "[2/10] Filesystem Hardening..."

# Filesystem mount options
echo "  - Setting secure mount options..."
sed -i '/\/ /s/defaults/defaults,nodev,nosuid,noexec/' /etc/fstab || true
sed -i '/\/boot /s/defaults/defaults,nodev,nosuid/' /etc/fstab || true
sed -i '/\/home /s/defaults/defaults,nodev/' /etc/fstab || true
sed -i '/\/var /s/defaults/defaults,nodev,nosuid/' /etc/fstab || true

# Sticky bit for world-writable directories
echo "  - Setting sticky bits..."
chmod +t /tmp /var/tmp

# 3. Account and Authentication Hardening
echo "[3/10] Account and Authentication Hardening..."

# Password policies
echo "  - Configuring password policies..."
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   7/' /etc/login.defs
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   7/' /etc/login.defs
sed -i 's/^UMASK.*/UMASK 027/' /etc/login.defs
echo "password requisite pam_pwquality.so try_first_pass retry=3 minlen=14 dcredit=-1 ucredit=-1 ocredit=-1 lcredit=-1" >> /etc/pam.d/system-auth

# Account lockout
echo "  - Configuring account lockout..."
echo "auth required pam_faillock.so preauth silent audit deny=5 unlock_time=900" >> /etc/pam.d/system-auth
echo "auth [success=1 default=bad] pam_unix.so" >> /etc/pam.d/system-auth
echo "auth [default=die] pam_faillock.so authfail audit deny=5 unlock_time=900" >> /etc/pam.d/system-auth

# Lock inactive accounts
echo "  - Locking inactive accounts..."
useradd -D -f 30
awk -F: '($7 != "/usr/sbin/nologin" && $7 != "/bin/false") { print $1 }' /etc/passwd | while read -r user; do
  chage -I 30 -E $(date -d "+6 months" +%Y-%m-%d) "$user"
done

# 4. SSH Hardening
echo "[4/10] SSH Hardening..."

declare -A SSH_SETTINGS=(
  ["Protocol"]="2"
  ["LogLevel"]="VERBOSE"
  ["X11Forwarding"]="no"
  ["MaxAuthTries"]="3"
  ["MaxSessions"]="2"
  ["IgnoreRhosts"]="yes"
  ["HostbasedAuthentication"]="no"
  ["PermitRootLogin"]="no"
  ["PermitEmptyPasswords"]="no"
  ["PermitUserEnvironment"]="no"
  ["ClientAliveInterval"]="$SSH_TIMEOUT"
  ["ClientAliveCountMax"]="0"
  ["LoginGraceTime"]="60"
  ["Banner"]="/etc/issue.net"
  ["UsePAM"]="yes"
  ["AllowTcpForwarding"]="no"
  ["AllowAgentForwarding"]="no"
  ["TCPKeepAlive"]="no"
  ["Compression"]="no"
  ["Port"]="2222"
  ["Ciphers"]="aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr"
  ["MACs"]="hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com"
  ["KexAlgorithms"]="curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512"
)

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

for setting in "${!SSH_SETTINGS[@]}"; do
  if grep -q "^$setting" /etc/ssh/sshd_config; then
    sed -i "s/^$setting.*/$setting ${SSH_SETTINGS[$setting]}/" /etc/ssh/sshd_config
  else
    echo "$setting ${SSH_SETTINGS[$setting]}" >> /etc/ssh/sshd_config
  fi

  # Remove duplicate entries
  sed -i "/^$setting/!b;n;d" /etc/ssh/sshd_config

done

# Create legal banners
echo "  - Creating legal banners..."
cat <<EOF > /etc/issue
********************************************************************
*                                                                  *
* This system is for the use of authorized users only.             *
* Individuals using this computer system without authority, or in  *
* excess of their authority, are subject to having all of their    *
* activities on this system monitored and recorded by system       *
* personnel.                                                       *
*                                                                  *
* In the course of monitoring individuals improperly using this     *
* system, or in the course of system maintenance, the activities   *
* of authorized users may also be monitored.                       *
*                                                                  *
* Anyone using this system expressly consents to such monitoring   *
* and is advised that if such monitoring reveals possible          *
* evidence of criminal activity, system personnel may provide the   *
* evidence of such monitoring to law enforcement officials.        *
*                                                                  *
********************************************************************
EOF

cp /etc/issue /etc/issue.net

# 5. Network Hardening
echo "[5/10] Network Hardening..."

cat <<EOF > /etc/sysctl.d/99-hardening.conf
# Kernel hardening
kernel.kptr_restrict = 2
kernel.dmesg_restrict = 1
kernel.perf_event_paranoid = 3
kernel.yama.ptrace_scope = 2
kernel.module.sig_enforce = 1
kernel.core_uses_pid = 1
kernel.sysrq = 0
fs.protected_fifos = 2
fs.protected_regular = 2
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
fs.suid_dumpable = 0

# Network hardening
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_timestamps = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.core.bpf_jit_harden = 2
EOF

sysctl --system

# Configure firewall
echo "  - Configuring firewall..."
systemctl enable firewalld --now
firewall-cmd --permanent --new-zone=hardened || true
firewall-cmd --permanent --zone=hardened --set-target=DROP
firewall-cmd --permanent --zone=hardened --add-service=ssh
firewall-cmd --permanent --zone=hardened --add-port=2222/tcp
firewall-cmd --reload

# Done
echo "=============================================="
echo " Hardening Complete - Review Lynis Suggestions"
echo " Log saved to $LOG_FILE"
echo "=============================================="

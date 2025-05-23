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





# ##checking the script version 
# # Enhanced System Hardening Script
# # Targets Lynis score of 90% or higher
# # Includes all fixes for the warnings and suggestions from Lynis report

# # Global Variables
# SSH_TIMEOUT=300
# LOG_FILE="/var/log/hardening-$(date +%Y%m%d).log"

# # Initialize logging
# exec > >(tee -a "$LOG_FILE") 2>&1

# echo "=============================================="
# echo " Starting Comprehensive System Hardening      "
# echo " Target: Lynis Score 90%+                    "
# echo " Date: $(date)                               "
# echo "=============================================="

# # 1. System Update and Package Management
# echo "[1/10] System Update and Package Management..."
# dnf update -y && dnf upgrade -y
# dnf install -y aide fail2ban rkhunter clamav

# # 2. Filesystem Hardening
# echo "[2/10] Filesystem Hardening..."

# # Filesystem mount options
# echo "  - Setting secure mount options..."

# # Only apply mount options if mount points already exist in /etc/fstab
# sed -i '/\/[[:space:]]/s/defaults/defaults,nodev,nosuid,noexec/' /etc/fstab || true
# sed -i '/\/boot[[:space:]]/s/defaults/defaults,nodev,nosuid/' /etc/fstab || true
# sed -i '/\/home[[:space:]]/s/defaults/defaults,nodev/' /etc/fstab || true
# sed -i '/\/var[[:space:]]/s/defaults/defaults,nodev,nosuid/' /etc/fstab || true

# # Don't add or mount non-existing devices
# echo "  - Skipping addition of separate partitions to avoid disk errors..."

# # Sticky bit for world-writable directories
# echo "  - Setting sticky bits..."
# chmod +t /tmp /var/tmp
# # Filesystem mount options
# echo "  - Setting secure mount options..."
# sed -i '/\/ /s/defaults/defaults,nodev,nosuid,noexec/' /etc/fstab
# sed -i '/\/boot /s/defaults/defaults,nodev,nosuid/' /etc/fstab
# sed -i '/\/home /s/defaults/defaults,nodev/' /etc/fstab
# sed -i '/\/var /s/defaults/defaults,nodev,nosuid/' /etc/fstab

# # Sticky bit for world-writable directories
# echo "  - Setting sticky bits..."
# chmod +t /tmp /var/tmp

# # 3. Account and Authentication Hardening
# echo "[3/10] Account and Authentication Hardening..."

# # Password policies
# echo "  - Configuring password policies..."
# sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs
# sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   7/' /etc/login.defs
# sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   7/' /etc/login.defs
# sed -i 's/^UMASK.*/UMASK 027/' /etc/login.defs
# echo "password requisite pam_pwquality.so try_first_pass retry=3 minlen=14 dcredit=-1 ucredit=-1 ocredit=-1 lcredit=-1" >> /etc/pam.d/system-auth

# # Account lockout
# echo "  - Configuring account lockout..."
# echo "auth required pam_faillock.so preauth silent audit deny=5 unlock_time=900" >> /etc/pam.d/system-auth
# echo "auth [success=1 default=bad] pam_unix.so" >> /etc/pam.d/system-auth
# echo "auth [default=die] pam_faillock.so authfail audit deny=5 unlock_time=900" >> /etc/pam.d/system-auth

# # Lock inactive accounts
# echo "  - Locking inactive accounts..."
# useradd -D -f 30
# awk -F: '($7 != "/usr/sbin/nologin" && $7 != "/bin/false") { print $1 }' /etc/passwd | while read user; do
#   chage -I 30 -E $(date -d "+6 months" +%Y-%m-%d) "$user"
# done

# # 4. SSH Hardening
# echo "[4/10] SSH Hardening..."

# declare -A SSH_SETTINGS=(
#   ["Protocol"]="2"
#   ["LogLevel"]="VERBOSE"
#   ["X11Forwarding"]="no"
#   ["MaxAuthTries"]="3"
#   ["MaxSessions"]="2"
#   ["IgnoreRhosts"]="yes"
#   ["HostbasedAuthentication"]="no"
#   ["PermitRootLogin"]="no"
#   ["PermitEmptyPasswords"]="no"
#   ["PermitUserEnvironment"]="no"
#   ["ClientAliveInterval"]="$SSH_TIMEOUT"
#   ["ClientAliveCountMax"]="0"
#   ["LoginGraceTime"]="60"
#   ["Banner"]="/etc/issue.net"
#   ["UsePAM"]="yes"
#   ["AllowTcpForwarding"]="no"
#   ["AllowAgentForwarding"]="no"
#   ["TCPKeepAlive"]="no"
#   ["Compression"]="no"
#   ["Port"]="2222"  # Changing default SSH port
#   ["Ciphers"]="aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr"
#   ["MACs"]="hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com"
#   ["KexAlgorithms"]="curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512"
# )

# # Backup original config
# cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# for setting in "${!SSH_SETTINGS[@]}"; do
#   if grep -q "^$setting" /etc/ssh/sshd_config; then
#     sed -i "s/^$setting.*/$setting ${SSH_SETTINGS[$setting]}/" /etc/ssh/sshd_config
#   else
#     echo "$setting ${SSH_SETTINGS[$setting]}" >> /etc/ssh/sshd_config
#   fi
# done

# # Create legal banners
# echo "  - Creating legal banners..."
# cat <<EOF > /etc/issue
# ********************************************************************
# *                                                                  *
# * This system is for the use of authorized users only.             *
# * Individuals using this computer system without authority, or in  *
# * excess of their authority, are subject to having all of their    *
# * activities on this system monitored and recorded by system       *
# * personnel.                                                       *
# *                                                                  *
# * In the course of monitoring individuals improperly using this     *
# * system, or in the course of system maintenance, the activities   *
# * of authorized users may also be monitored.                       *
# *                                                                  *
# * Anyone using this system expressly consents to such monitoring   *
# * and is advised that if such monitoring reveals possible          *
# * evidence of criminal activity, system personnel may provide the   *
# * evidence of such monitoring to law enforcement officials.        *
# *                                                                  *
# ********************************************************************
# EOF

# cp /etc/issue /etc/issue.net

# # 5. Network Hardening
# echo "[5/10] Network Hardening..."

# # Configure sysctl
# echo "  - Configuring sysctl parameters..."
# cat <<EOF > /etc/sysctl.d/99-hardening.conf
# # Kernel hardening
# kernel.kptr_restrict = 2
# kernel.dmesg_restrict = 1
# kernel.perf_event_paranoid = 3
# kernel.yama.ptrace_scope = 2
# kernel.module.sig_enforce = 1
# kernel.core_uses_pid = 1
# kernel.sysrq = 0
# fs.protected_fifos = 2
# fs.protected_regular = 2
# fs.protected_hardlinks = 1
# fs.protected_symlinks = 1
# fs.suid_dumpable = 0

# # Network hardening
# net.ipv4.conf.all.accept_redirects = 0
# net.ipv4.conf.default.accept_redirects = 0
# net.ipv4.conf.all.send_redirects = 0
# net.ipv4.conf.default.send_redirects = 0
# net.ipv4.conf.all.rp_filter = 1
# net.ipv4.conf.default.rp_filter = 1
# net.ipv4.tcp_syncookies = 1
# net.ipv4.tcp_timestamps = 0
# net.ipv6.conf.all.accept_redirects = 0
# net.ipv6.conf.default.accept_redirects = 0
# net.ipv6.conf.all.disable_ipv6 = 1
# net.ipv6.conf.default.disable_ipv6 = 1
# net.core.bpf_jit_harden = 2
# EOF

# sysctl --system

# # Configure firewall
# echo "  - Configuring firewall..."
# systemctl enable firewalld
# systemctl start firewalld
# firewall-cmd --permanent --new-zone=hardened
# firewall-cmd --permanent --zone=hardened --set-target=DROP
# firewall-cmd --permanent --zone=hardened --add-service=ssh
# firewall-cmd --permanent --zone=hardened --add-port=2222/tcp
# firewall-cmd --permanent --change-interface=eth0 --zone=hardened
# firewall-cmd --reload

# # 6. Service Hardening
# echo "[6/10] Service Hardening..."

# # Disable unnecessary services
# echo "  - Disabling unnecessary services..."

# disable_if_exists() {
#     local service_name=$1
#     if systemctl list-unit-files | grep -q "^$service_name"; then
#         echo "Disabling $service_name..."
#         systemctl disable "$service_name"
#     else
#         echo "$service_name not found, skipping."
#     fi
# }

# # List of services/sockets to disable
# disable_if_exists "rpcbind.service"
# disable_if_exists "nfs.service"
# disable_if_exists "atd.service"
# disable_if_exists "avahi-daemon.service"
# disable_if_exists "cups.service"
# disable_if_exists "dhcpd.service"
# disable_if_exists "slapd.service"
# disable_if_exists "named.service"
# disable_if_exists "vsftpd.service"
# disable_if_exists "telnet.socket"


# # Configure systemd service hardening
# echo "  - Hardening systemd services..."
# for service in $(systemctl list-unit-files --type=service | grep enabled | awk '{print $1}'); do
#   systemd-analyze security "$service" | grep -q "UNSAFE" && \
#     systemctl mask "$service"
# done

# # 7. Logging and Auditing
# echo "[7/10] Logging and Auditing..."

# # Configure auditd
# echo "  - Configuring auditd..."
# cat <<EOF > /etc/audit/rules.d/hardening.rules
# # Audit system events
# -a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change
# -a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change
# -a always,exit -F arch=b64 -S clock_settime -k time-change
# -a always,exit -F arch=b32 -S clock_settime -k time-change
# -w /etc/localtime -p wa -k time-change

# # Audit user/group changes
# -w /etc/group -p wa -k identity
# -w /etc/passwd -p wa -k identity
# -w /etc/gshadow -p wa -k identity
# -w /etc/shadow -p wa -k identity
# -w /etc/security/opasswd -p wa -k identity

# # Audit system network configuration
# -w /etc/hosts -p wa -k network-modifications
# -w /etc/sysconfig/network -p wa -k network-modifications
# -w /etc/sysconfig/network-scripts/ -p wa -k network-modifications

# # Audit privileged commands
# -a always,exit -F path=/usr/sbin/setfiles -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged
# EOF

# augenrules --load
# systemctl enable auditd
# systemctl restart auditd

# # Configure rsyslog
# echo "  - Configuring rsyslog..."
# cat <<EOF > /etc/rsyslog.d/90-hardening.conf
# *.emerg :omusrmsg:*
# auth.* /var/log/auth.log
# authpriv.* /var/log/secure
# mail.* /var/log/mail.log
# cron.* /var/log/cron.log
# *.=warning;*.=err /var/log/warn.log
# *.crit /var/log/warn.log
# *.*;mail.none;authpriv.none;cron.none /var/log/messages
# EOF

# systemctl restart rsyslog

# # 8. File Permissions
# echo "[8/10] File Permissions..."

# # Critical file permissions
# echo "  - Setting critical file permissions..."
# chmod 644 /etc/passwd
# chmod 600 /etc/shadow
# chmod 644 /etc/group
# chmod 600 /etc/gshadow
# chmod 700 /boot /usr/src /lib/modules
# chmod 750 /etc/sudoers.d /etc/polkit-1/localauthority
# chmod 700 /root
# chmod 600 /root/.ssh/authorized_keys 2>/dev/null

# # Set immutable bit on critical files
# chattr +i /etc/passwd /etc/shadow /etc/group /etc/gshadow /etc/sudoers /etc/ssh/sshd_config

# # 9. Malware Protection
# echo "[9/10] Malware Protection..."

# # Configure AIDE (Advanced Intrusion Detection Environment)
# echo "  - Configuring AIDE..."
# aide --init
# mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
# echo "0 3 * * * /usr/sbin/aide --check" >> /etc/crontab

# # Configure rkhunter
# echo "  - Configuring rkhunter..."
# rkhunter --update
# rkhunter --propupd
# echo "0 2 * * * /usr/bin/rkhunter --check --cronjob" >> /etc/crontab

# # Configure ClamAV
# echo "  - Configuring ClamAV..."
# freshclam
# echo "0 1 * * * /usr/bin/freshclam --quiet" >> /etc/crontab
# echo "0 4 * * * /usr/bin/clamscan --recursive --infected --remove /" >> /etc/crontab

# # Configure Fail2Ban
# echo "  - Configuring Fail2Ban..."
# cat <<EOF > /etc/fail2ban/jail.local
# [sshd]
# enabled = true
# port = 2222
# filter = sshd
# logpath = /var/log/secure
# maxretry = 3
# bantime = 86400
# findtime = 3600
# EOF

# systemctl enable fail2ban
# systemctl start fail2ban

# # 10. Final Hardening Steps
# echo "[10/10] Final Hardening Steps..."

# # Disable core dumps
# echo "  - Disabling core dumps..."
# echo "* hard core 0" >> /etc/security/limits.conf
# echo "fs.suid_dumpable = 0" >> /etc/sysctl.conf

# # Disable unnecessary filesystems
# echo "  - Disabling unnecessary filesystems..."
# cat <<EOF > /etc/modprobe.d/hardening.conf
# install cramfs /bin/true
# install freevxfs /bin/true
# install jffs2 /bin/true
# install hfs /bin/true
# install hfsplus /bin/true
# install squashfs /bin/true
# install udf /bin/true
# install dccp /bin/true
# install sctp /bin/true
# install rds /bin/true
# install tipc /bin/true
# install usb-storage /bin/true
# install firewire-ohci /bin/true
# EOF

# # Configure DNS (add secondary nameserver)
# echo "  - Configuring DNS..."
# echo "nameserver 8.8.8.8" >> /etc/resolv.conf
# echo "nameserver 1.1.1.1" >> /etc/resolv.conf

# # Configure hostname in /etc/hosts
# echo "  - Configuring /etc/hosts..."
# IP=$(hostname -I | awk '{print $1}')
# echo "$IP $(hostname) $(hostname -s)" >> /etc/hosts

# # Final system checks
# echo "  - Running final checks..."
# updatedb
# mandb
# ldconfig

# echo "=============================================="
# echo " Hardening Complete!                          "
# echo "                                              "
# echo " IMPORTANT:                                   "
# echo " - SSH is now on port 2222                    "
# echo " - Review $LOG_FILE for details               "
# echo " - Reboot the system to apply all changes     "
# echo " - Run 'lynis audit system' to verify score   "
# echo "=============================================="
#!/bin/bash

# Enhanced System Hardening Script (Packer-Compatible)
# Version: 2.1
# Fixes auditd issues and improves AMI compatibility
# Targets Lynis score of 90%+

# Global Variables
SSH_TIMEOUT=300
LOG_FILE="/var/log/hardening-$(date +%Y%m%d).log"

# Initialize logging
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=============================================="
echo " Starting Packer-Compatible Hardening        "
echo " Target: Lynis Score 90%+                    "
echo " Date: $(date)                               "
echo "=============================================="

# 1. System Update and Package Management
echo "[1/10] System Update and Package Management..."
dnf update -y && dnf upgrade -y
dnf install -y aide fail2ban rkhunter clamav audit

# 2. Filesystem Hardening
echo "[2/10] Filesystem Hardening..."
{
  # Safe mount options (only modify existing entries)
  sed -i '/\/[[:space:]]/s/defaults/defaults,nodev,nosuid,noexec/' /etc/fstab
  sed -i '/\/boot[[:space:]]/s/defaults/defaults,nodev,nosuid/' /etc/fstab
  sed -i '/\/home[[:space:]]/s/defaults/defaults,nodev/' /etc/fstab
  sed -i '/\/var[[:space:]]/s/defaults/defaults,nodev,nosuid/' /etc/fstab
  
  # Sticky bits
  chmod +t /tmp /var/tmp
} || echo "Filesystem hardening partially completed" >> "$LOG_FILE"

# 3. Account and Authentication Hardening
echo "[3/10] Account and Authentication Hardening..."
{
  # Password policies
  sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs
  sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   7/' /etc/login.defs
  sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   7/' /etc/login.defs
  sed -i 's/^UMASK.*/UMASK 027/' /etc/login.defs
  
  # PAM configuration
  cat <<EOF > /etc/pam.d/system-auth
auth required pam_faillock.so preauth silent audit deny=5 unlock_time=900
auth sufficient pam_unix.so try_first_pass
auth [default=die] pam_faillock.so authfail audit deny=5 unlock_time=900
account required pam_unix.so
password requisite pam_pwquality.so try_first_pass retry=3 minlen=14 dcredit=-1 ucredit=-1 ocredit=-1 lcredit=-1
password sufficient pam_unix.so sha512 shadow try_first_pass use_authtok remember=5
session required pam_limits.so
session required pam_unix.so
EOF

  # Lock inactive accounts
  useradd -D -f 30
  awk -F: '($7 != "/usr/sbin/nologin" && $7 != "/bin/false") { print $1 }' /etc/passwd | while read -r user; do
    chage -I 30 -E "$(date -d "+6 months" +%Y-%m-%d)" "$user" || true
  done
} || echo "Account hardening partially completed" >> "$LOG_FILE"

# 4. SSH Hardening (Packer-compatible)
echo "[4/10] SSH Hardening..."
{
  declare -A SSH_SETTINGS=(
    ["Port"]="2222"
    ["Protocol"]="2"
    ["LogLevel"]="VERBOSE"
    ["X11Forwarding"]="no"
    ["MaxAuthTries"]="3"
    ["MaxSessions"]="2"
    ["ClientAliveInterval"]="$SSH_TIMEOUT"
    ["ClientAliveCountMax"]="0"
    ["PermitRootLogin"]="no"
    ["PasswordAuthentication"]="yes"  # Required for Packer
    ["PermitEmptyPasswords"]="no"
    ["ChallengeResponseAuthentication"]="no"
    ["UsePAM"]="yes"
    ["AllowAgentForwarding"]="no"
    ["AllowTcpForwarding"]="no"
    ["GatewayPorts"]="no"
    ["PermitTunnel"]="no"
  )

  # Backup and configure
  cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
  for setting in "${!SSH_SETTINGS[@]}"; do
    if grep -q "^$setting" /etc/ssh/sshd_config; then
      sed -i "s/^$setting.*/$setting ${SSH_SETTINGS[$setting]}/" /etc/ssh/sshd_config
    else
      echo "$setting ${SSH_SETTINGS[$setting]}" >> /etc/ssh/sshd_config
    fi
  done

  # Legal banners
  cat <<EOF > /etc/issue
********************************************************************
*                          NOTICE                                  *
* This system is for authorized use only. Unauthorized access is   *
* prohibited and may be prosecuted.                                *
********************************************************************
EOF
  cp /etc/issue /etc/issue.net
} || echo "SSH hardening partially completed" >> "$LOG_FILE"

# 5. Network Hardening
echo "[5/10] Network Hardening..."
{
  # Sysctl settings
  cat <<EOF > /etc/sysctl.d/99-hardening.conf
# Kernel hardening
kernel.kptr_restrict = 2
kernel.dmesg_restrict = 1
kernel.perf_event_paranoid = 3
kernel.yama.ptrace_scope = 1
fs.protected_fifos = 2
fs.protected_regular = 2
fs.suid_dumpable = 0

# Network hardening
net.ipv4.conf.all.rp_filter = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_timestamps = 0
net.ipv6.conf.all.disable_ipv6 = 1
EOF
  sysctl --system

  # Firewall (Packer-compatible)
  systemctl enable --now firewalld
  firewall-cmd --permanent --new-zone=packer
  firewall-cmd --permanent --zone=packer --add-port=2222/tcp
  firewall-cmd --permanent --zone=packer --set-target=ACCEPT
  firewall-cmd --permanent --change-interface=eth0 --zone=packer
  firewall-cmd --reload
} || echo "Network hardening partially completed" >> "$LOG_FILE"

# 6. Service Hardening (Packer-aware)
echo "[6/10] Service Hardening..."
{
  # Safe service disable function
  safe_disable() {
    if systemctl list-unit-files | grep -q "^$1"; then
      systemctl disable "$1" --now || true
    fi
  }

  # Services to disable (whitelist approach)
  services_to_disable=(
    avahi-daemon cups rpcbind nfs-server
    dhcpd slapd named vsftpd telnet.socket
  )

  for service in "${services_to_disable[@]}"; do
    safe_disable "$service"
  done
} || echo "Service hardening partially completed" >> "$LOG_FILE"

# 7. Logging and Auditing (Packer-compatible)
echo "[7/10] Logging and Auditing..."
{
  # Auditd configuration
  cat <<EOF > /etc/audit/rules.d/50-hardening.rules
## Audit system events
-a always,exit -F arch=b64 -S adjtimex,settimeofday -F key=time-change
-a always,exit -F arch=b32 -S adjtimex,settimeofday,stime -F key=time-change
-w /etc/localtime -p wa -k time-change

## Audit identity changes
-w /etc/group -p wa -k identity
-w /etc/passwd -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/shadow -p wa -k identity

## Audit network configuration
-w /etc/hosts -p wa -k network-modification
-w /etc/sysconfig/network -p wa -k network-modification
EOF

  # Load rules without forcing service restart
  augenrules --load || true
  systemctl try-restart auditd || true

  # Rsyslog configuration
  cat <<EOF > /etc/rsyslog.d/50-hardening.conf
*.emerg :omusrmsg:*
auth.* /var/log/auth.log
authpriv.* /var/log/secure
EOF
  systemctl restart rsyslog
} || echo "Logging hardening partially completed" >> "$LOG_FILE"

# 8. File Permissions
echo "[8/10] File Permissions..."
{
  # Critical permissions
  chmod 644 /etc/passwd
  chmod 600 /etc/shadow
  chmod 644 /etc/group
  chmod 600 /etc/gshadow
  chmod 700 /root
  chmod 750 /etc/sudoers.d

  # Immutable files (skip during Packer build)
  [[ "$PACKER_BUILD_NAME" != "" ]] || {
    chattr +i /etc/passwd /etc/shadow /etc/group /etc/gshadow
  }
} || echo "File permissions partially set" >> "$LOG_FILE"

# 9. Malware Protection
echo "[9/10] Malware Protection..."
{
  # AIDE
  aideinit -y -f || true
  echo "0 3 * * * /usr/sbin/aide --check" >> /etc/crontab

  # RKHunter
  rkhunter --update || true
  rkhunter --propupd || true
  echo "0 2 * * * /usr/bin/rkhunter --check --cronjob" >> /etc/crontab

  # Fail2Ban
  cat <<EOF > /etc/fail2ban/jail.d/sshd.conf
[sshd]
enabled = true
port = 2222
maxretry = 3
bantime = 86400
findtime = 3600
EOF
  systemctl enable --now fail2ban
} || echo "Malware protection partially configured" >> "$LOG_FILE"

# 10. Final Hardening Steps
echo "[10/10] Final Hardening Steps..."
{
  # Core dumps
  echo "* hard core 0" >> /etc/security/limits.conf
  echo "kernel.core_pattern=|/bin/false" > /etc/sysctl.d/50-coredump.conf

  # Disable filesystems
  cat <<EOF > /etc/modprobe.d/disable-filesystems.conf
install cramfs /bin/true
install freevxfs /bin/true
install jffs2 /bin/true
install hfs /bin/true
install hfsplus /bin/true
install udf /bin/true
EOF

  # DNS configuration
  echo "nameserver 8.8.8.8" > /etc/resolv.conf
  echo "nameserver 1.1.1.1" >> /etc/resolv.conf

  # Hosts file
  echo "127.0.0.1 $(hostname)" >> /etc/hosts
} || echo "Final steps partially completed" >> "$LOG_FILE"

echo "=============================================="
echo " Hardening Completed Successfully!           "
echo "=============================================="
echo " Important Notes:                            "
echo " 1. SSH is now on port 2222                  "
echo " 2. Temporary firewall rules for Packer      "
echo " 3. Full auditd will activate on first boot  "
echo " 4. Review $LOG_FILE for details             "
echo "=============================================="

exit 0
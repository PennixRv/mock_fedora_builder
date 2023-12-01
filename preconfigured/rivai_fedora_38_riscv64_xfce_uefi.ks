# Generated by pykickstart v3.48
#version=DEVEL
# Firewall configuration
firewall --enabled --service=mdns
# Keyboard layouts
keyboard 'us'
# System language
lang en_US.UTF-8
# Network information
network  --bootproto=dhcp --device=link --activate
# Shutdown after installation
shutdown
repo --name="Openkoji-1" --baseurl=http://openkoji.iscas.ac.cn/kojifiles/repos/f38-build/latest/riscv64/
repo --name="Openkoji-2" --baseurl=http://openkoji.iscas.ac.cn/kojifiles/repos/f38-build-side-42-init-devel/latest/riscv64/
repo --name="Openkoji-3" --baseurl=http://openkoji.iscas.ac.cn/repos/fc38dist/riscv64/
repo --name="Openkoji-4" --baseurl=http://openkoji.iscas.ac.cn/repos/fc38-noarches-repo/riscv64/
repo --name="Openkoji-5" --baseurl=http://openkoji.iscas.ac.cn/pub/temp-f38-repo/riscv64/
repo --name="Openkoji-6" --baseurl=http://openkoji.iscas.ac.cn/pub/temp-python311-repo/riscv64/
repo --name="Openkoji-7" --baseurl=http://openkoji.iscas.ac.cn/pub/temp-python311-repo/riscv64/
repo --name="FedoraRocks-1" --baseurl=http://fedora.riscv.rocks/repos-dist/f38/latest/riscv64/
# Root password
rootpw --iscrypted --lock locked
# SELinux configuration
selinux --enforcing
# System services
services --disabled="sshd" --enabled="NetworkManager,ModemManager"
# System timezone
timezone US/Eastern
# X Window System configuration information
xconfig  --startxonboot
# System bootloader configuration
bootloader --append="console=tty1 console=ttyS0,115200 debug rootwait earlycon=sbi" --location=mbr --timeout=1
# Clear the Master Boot Record
zerombr
# Partition clearing information
clearpart --all --initlabel --disklabel=gpt
# Disk partitioning information
part /boot/efi --fstype="vfat" --size=100
part swap --fstype="swap" --size=512 --label=swap
part / --fstype="ext4" --grow --size=10240 --label=rootfs

%post
# Enable livesys services
systemctl enable livesys.service
systemctl enable livesys-late.service

# enable tmpfs for /tmp
systemctl enable tmp.mount

# make it so that we don't do writing to the overlay for things which
# are just tmpdirs/caches
# note https://bugzilla.redhat.com/show_bug.cgi?id=1135475
cat >> /etc/fstab << EOF
vartmp   /var/tmp    tmpfs   defaults   0  0
EOF

# work around for poor key import UI in PackageKit
rm -f /var/lib/rpm/__db*
echo "Packages within this LiveCD"
rpm -qa --qf '%{size}\t%{name}-%{version}-%{release}.%{arch}\n' |sort -rn
# Note that running rpm recreates the rpm db files which aren't needed or wanted
rm -f /var/lib/rpm/__db*

# go ahead and pre-make the man -k cache (#455968)
/usr/bin/mandb

# make sure there aren't core files lying around
rm -f /core*

# remove random seed, the newly installed instance should make it's own
rm -f /var/lib/systemd/random-seed

# convince readahead not to collect
# FIXME: for systemd

echo 'File created by kickstart. See systemd-update-done.service(8).' \
| tee /etc/.updated >/var/.updated

# Drop the rescue kernel and initramfs, we don't need them on the live media itself.
# See bug 1317709
rm -f /boot/*-rescue*

# Disable network service here, as doing it in the services line
# fails due to RHBZ #1369794
systemctl disable network

# Remove machine-id on pre generated images
rm -f /etc/machine-id
touch /etc/machine-id

%end

%post
useradd -c "Fedora RISCV User" rivai
echo rivai | passwd --stdin rivai > /dev/null
cat << EOF | tee /etc/issue /etc/issue.net
Welcome to the Fedora/RISC-V customized by RiVAI

Build date: Mon Nov 27 03:10:32 PM UTC 2023

Kernel \r on an \m (\l)

The root password is 'fedora_rocks!'.
root password logins are disabled in SSH.
User 'rivai' with password 'rivai' is provided.
EOF
%end

%post
cat > /etc/sysconfig/desktop <<EOF
PREFERRED=/usr/bin/startxfce4
DISPLAYMANAGER=/usr/sbin/lightdm
EOF
sed -i 's/^livesys_session=.*/livesys_session="xfce"/' /etc/sysconfig/livesys
%end

%packages
@^xfce-desktop-environment
@anaconda-tools
@development-libs
@development-tools
@xfce-apps
@xfce-extra-plugins
@xfce-media
@xfce-office
aajohan-comfortaa-fonts
anaconda
anaconda-install-env-deps
anaconda-live
audit-libs-devel
bzip2-devel
cargo
cpp
dblatex
dbus-devel
dejagnu
docbook5-style-xsl
dracut-config-generic
dracut-live
dwarves
expat-devel
fakechroot
fedora-release-xfce
file-devel
gcc
gcc-c++
gcc-gdb-plugin
gcc-gfortran
gcc-gnat
gcc-plugin-devel
gd-devel
gettext-devel
glibc-all-langpacks
glibc-devel
golang
grub2-efi-riscv64
haveged
ima-evm-utils-devel
isl-devel
java-devel
java-openjdk
java-openjdk-headless
kernel
kernel-modules
kernel-modules-extra
libacl-devel
libarchive-devel
libatomic
libatomic-static
libattr-devel
libbabeltrace-devel
libcap-devel
libcap-ng-devel
libdb-devel
libgcc
libgfortran
libgfortran-static
libgnat
libgnat-devel
libgnat-static
libgomp
libpng-devel
libselinux-devel
libstdc++
libstdc++-devel
libstdc++-static
libuser-devel
libutempter-devel
libzstd-devel
linux-firmware
livesys-scripts
lua-devel
ncurses-devel
opensbi-unstable
pam-devel
pax-utils
pcre2-devel
perl
popt-devel
python3-devel
python3-langtable
python3-sphinx
readline-devel
rpm-devel
rust
sharutils
source-highlight-devel
system-config-printer
systemd-devel
texinfo-tex
texlive-collection-latex
texlive-collection-latexrecommended
uboot-images-riscv64
uboot-tools
usbutils
wget
zlib-static
-@dial-up
-@input-methods
-@standard
-acpid
-aspell-*
-autofs
-desktop-backgrounds-basic
-device-mapper-multipath
-dracut-config-rescue
-fcoe-utils
-gfs2-utils
-gimp-help
-reiserfs-utils
-sdubby
-xfce4-eyes-plugin
-xfce4-sensors-plugin

%end

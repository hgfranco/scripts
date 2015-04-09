# KICK START FILE #
# REMOVE domain.com #

install
url --url http://mirrors.kernel.org/centos/5/os/x86_64
lang en_US.UTF-8
keyboard us
network --device eth0 --bootproto dhcp --hostname test01.int.domain.com
network --device eth1 --onboot no --bootproto static
rootpw --iscrypted $1$33.DdUm5$35RnCnFafXMDJLDapR3Dm.
firewall --disabled
firstboot --disabled
authconfig --enableshadow --enablemd5
selinux --disabled
timezone --utc America/Los_Angeles
#bootloader --location=mbr --driveorder=hda,hdb,hdc
bootloader --location=mbr --driveorder=sda,sdb,sdc
zerombr
skipx
halt
#clearpart --all
part /boot --fstype ext3 --size=1 --grow --ondisk xvda --asprimary
part pv.1 --fstype "physical volume (LVM)" --onpart xvdb1
part pv.2 --fstype "physical volume (LVM)" --onpart xvdc1
#part raid.4 --size=1 --grow --ondisk=hdb --asprimary
#part raid.5 --size=1 --grow --ondisk=hdc --asprimary
#part raid.6 --size=1 --grow --ondisk=hdd --asprimary
#part raid.7 --size=1 --grow --ondisk=hde --asprimary
#part raid.4 --size=1 --grow --onpart=hdb1
#part raid.5 --size=1 --grow --onpart=hdc1
#part raid.6 --size=1 --grow --onpart=hdd1
#part raid.7 --size=1 --grow --onpart=hde1
#raid pv.6 --fstype "physical volume (LVM)" --level=RAID1 --device=md0 raid.4 raid.5
#raid swap --fstype swap --level=RAID1 --device=md1 raid.6 raid.7
volgroup storage --pesize=4096 pv.1
volgroup swap --pesize=4096 pv.2
logvol /tmp --fstype xfs --name=tmp --vgname=storage --size=2048
logvol /opt --fstype xfs --name=opt --vgname=storage --size=6144
logvol /var --fstype xfs --name=var --vgname=storage --size=6144
logvol / --fstype xfs --name=root --vgname=storage --size=1024
logvol /usr --fstype xfs --name=usr --vgname=storage --size=3072
logvol /opt/data --fstype xfs --name=data --vgname=storage --size=10240
logvol swap --fstype swap --name s0 --vgname=swap --size=1904

%packages
patch
@base
-NetworkManager
-amtu
-aspell
-aspell-en
-bluez-utils
bridge-utils
-ccid
-conman
-coolkey
-cpuspeed
-crash
device-mapper-multipath
-dos2unix
-dosfstools
-dump
-fbset
-finger
-firstboot-tui
-gnupg
-ipsec-tools
-iptstate
-irda-utils
iscsi-initiator-utils
-jwhois
-krb5-workstation
-m2crypto
-mgetty
-mkbootdisk
-mlocate
-mtools
-mtr
-nano
-nc
-nfs-utils
-nss_db
-oddjob
-pam_ccreds
-pam_krb5
-pam_passwdqc
-pam_pkcs11
-pam_smb
-pax
-pcmciautils
-pkinit-nss
-redhat-lsb
-rp-pppoe
-sendmail
-setuptool
-smartmontools
-sos
-specspo
-stunnel
-sysreport
-system-config-network-tui
-talk
-tcp_wrappers
-tcpdump
-unix2dos
-wireless-tools
-words
-ypbind
@core
@editors
-emacs
-vim-X11
@mail-server
-sendmail
-sendmail-cf
-cyrus-sasl
-dovecot
postfix
-spamassassin
@text-internet
lynx
-elinks
-cadaver
-epic
-fetchmail
-mutt
-slrn
tftp
@system-tools
-OpenIPMI
-avahi-tools
-bluez-gnome
-bluez-hcidump
-hwbrowser
net-snmp-libs
net-snmp-utils
-nmap
-samba-client
sysstat
-vnc
-xdelta
-zisofs-tools
zsh
ntp

%post --interpreter /bin/zsh

chvt 3

echo -n "editing /etc/fstab and removing references to /boot ..."
cp /etc/fstab /tmp
grep -v "LABEL=/boot" /tmp/fstab > /etc/fstab
rm /tmp/fstab
sed -i 's/\(ext3[[:space:]]*defaults\)/\1,acl/g' /etc/fstab
sed -i 's/xfs\(.*\)\(1 [12]\)$/xfs\10 0/g' /etc/fstab
echo " done"

for i in kudzu yum-updatesd haldaemon autofs gpm ip6tables iptables mcstrans \
         messagebus restorecond ; do
   echo -n "turning off $i ..."
   chkconfig $i off
   echo " done"
done

echo -n "editing network ifscripts to remove references to hwaddr ..."
cp /etc/sysconfig/network-scripts/ifcfg-eth[0-9] /tmp
for i in `find /tmp -maxdepth 1 -type f -name ifcfg-\*`; do
   bni=`basename $i`
   grep -v "HWADDR=" $i > /etc/sysconfig/network-scripts/$bni
   rm $i
done
echo " done"

echo -n "editing network ifscripts to turn off ipv6 ..."
cp /etc/sysconfig/network /tmp
grep -v "NETWORKING_IPV6" /tmp/network > /etc/sysconfig/network
rm /tmp/network
echo " done"

echo -n "editing storage network (eth1) to start with mtu of 9000 ..."
if [ -f /etc/sysconfig/network-scripts/ifcfg-eth1 ] ; then
   file="/etc/sysconfig/network-scripts/ifcfg-eth1"
   echo "DEVICE=eth1" > $file
   echo "ONBOOT=yes" >> $file
   echo "BOOTPROTO=static" >> $file
   echo "MTU=9000" >> $file
fi
echo " done"

echo -n "ensuring xvc0 is in /etc/securetty ..."
if ! grep -q xvc0 /etc/securetty ; then
   echo "xvc0" >> /etc/securetty
fi
echo " done"

echo -n "ensuring login is spawned on xvc0 in /etc/inittab ..."
if ! grep -q xvc0 /etc/inittab ; then
   cp /etc/inittab /tmp
   grep -v mingetty /tmp/inittab >/etc/inittab
   echo "" >>/etc/inittab
   echo "# spawn a console login on xvc0" >>/etc/inittab
   echo "co:2345:respawn:/sbin/agetty xvc0 9600 vt100-nav" >>/etc/inittab
   rm /tmp/inittab
fi
echo " done"

#echo "installing kernel dependencies ..."
#ZPWD=`pwd`
#cd /lib/modules
#tftp 10.0.0.1 -c get linux-install/kmod.tar.gz
#tar -xzf kmod.tar.gz
#rm kmod.tar.gz
#cd $ZPWD

echo -n "changing root's shell to /bin/zsh ..."
chsh -s /bin/zsh root
echo " done"

echo -n "turning off DIR_COLORS ..."
sed -i 's/^COLOR tty/COLOR none/g' /etc/DIR_COLORS    
sed -i 's/^COLOR tty/COLOR none/g' /etc/DIR_COLORS.xterm 
echo " done"

echs -n "adding wheel group to allowed sudoers ..."
# sudo is fucking stupid with these ridiculous permissions
chmod 644 /etc/sudoers
sed -i 's/# \(%wheel.*: ALL\)/\1/g' /etc/sudoers
chmod 440 /etc/sudoers

echo -n "making edits to /etc/zshrc ..."
patch -p0 <<EOF
--- /etc/zshrc  2007-07-06 02:37:08.000000000 -0700
+++ /tmp/zshrc  2007-07-06 02:38:41.000000000 -0700
@@ -7,9 +7,11 @@
 ## shell functions
 #setenv() { export $1=$2 }  # csh compatibility
 
+[ -f /etc/profile ] && . /etc/profile
+
 # Set prompts
-PROMPT='[%n@%m]%~%# '    # default prompt
-#RPROMPT=' %~'     # prompt for right side of screen
+PROMPT='%n@%m%# '    # default prompt
+RPROMPT=' %~'     # prompt for right side of screen
 
 # bindkey -v             # vi key bindings
 # bindkey -e             # emacs key bindings

EOF
echo "alias ls='ls -Fa'" >> /etc/zshrc
echo " done"

echo -n "only allowing root logins via ssh pubkey ..."
sed -i 's/#PermitRootLogin yes/PermitRootLogin without-password/g' \
   /etc/ssh/sshd_config
echo " done"

#echo -n "setting up /dj as symlinks to the proper standard locations ..."
#
#mkdir    /opt/DJYScom
#mkdir    /var/log/dj
#
#ln -s /opt/DJYScom     /dj
#ln -s /var/log/dj      /dj/logs
#
#echo " done"

echo -n "setting sysctl parameters ..."
cat >>/etc/sysctl.conf <<EOF
# raise RAID speed limits
dev.raid.speed_limit_max = 262144
dev.raid.speed_limit_min = 131072

# jumbo frames on raw sockets require more buffer space
net.core.wmem_max = 262144
net.core.rmem_max = 262144
net.core.wmem_default = 262144
net.core.rmem_default = 262144
EOF
echo " done"

echo -n "enabling centosplus repository ..."
patch -p0 <<EOF
--- /etc/yum.repos.d/CentOS-Base.repo  2007-11-22 17:32:15.000000000 -0800
+++ /etc/yum.repos.d/CentOS-Base.repo.orig 2008-04-30 00:48:23.000000000 -0700
@@ -13,41 +13,41 @@
 
 [base]
 name=CentOS-\$releasever - Base
-mirrorlist=http://mirrorlist.centos.org/?release=\$releasever&arch=\$basearch&repo=os
-#baseurl=http://mirror.centos.org/centos/\$releasever/os/\$basearch/
+#mirrorlist=http://mirrorlist.centos.org/?release=\$releasever&arch=\$basearch&repo=os
 gpgcheck=1
 gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-5
 
 #released updates 
 [updates]
 name=CentOS-\$releasever - Updates
-mirrorlist=http://mirrorlist.centos.org/?release=\$releasever&arch=\$basearch&repo=updates
-#baseurl=http://mirror.centos.org/centos/\$releasever/updates/\$basearch/
+#mirrorlist=http://mirrorlist.centos.org/?release=\$releasever&arch=\$basearch&repo=updates
 gpgcheck=1
 gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-5
 
 #packages used/produced in the build but not released
 [addons]
 name=CentOS-\$releasever - Addons
-mirrorlist=http://mirrorlist.centos.org/?release=\$releasever&arch=\$basearch&repo=addons
-#baseurl=http://mirror.centos.org/centos/\$releasever/addons/\$basearch/
+#mirrorlist=http://mirrorlist.centos.org/?release=\$releasever&arch=\$basearch&repo=addons
 gpgcheck=1
 gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-5
 
 #additional packages that may be useful
 [extras]
 name=CentOS-\$releasever - Extras
-mirrorlist=http://mirrorlist.centos.org/?release=\$releasever&arch=\$basearch&repo=extras
-#baseurl=http://mirror.centos.org/centos/\$releasever/extras/\$basearch/
+#mirrorlist=http://mirrorlist.centos.org/?release=\$releasever&arch=\$basearch&repo=extras
 gpgcheck=1
 gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-5
 
 #additional packages that extend functionality of existing packages
 [centosplus]
 name=CentOS-\$releasever - Plus
-mirrorlist=http://mirrorlist.centos.org/?release=\$releasever&arch=\$basearch&repo=centosplus
-#baseurl=http://mirror.centos.org/centos/\$releasever/centosplus/\$basearch/
+#mirrorlist=http://mirrorlist.centos.org/?release=\$releasever&arch=\$basearch&repo=centosplus
 gpgcheck=1
-enabled=0
+enabled=1
 gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-5
 
EOF
echo " done"

echo -n "creating and enabling local yum repo ..."
wget -O $file $burl
rpm -Uvh $file
rm $file
echo " done"

echo " done"

echo -n "installling updates ..."
   yum -y --exclude='*kernel*' \
          --exclude='*kmod*' \
          --disablerepo=centosplus \
          --disablerepo=updates \
          update
echo " done"

sleep 15

echo -n "adding root: root@domain.com to /etc/aliases ..."
   echo "root:	root@domain.com" >> /etc/aliases
   newaliases
echo " done"

echo -n "configuring postfix to relay all mail ..."
   echo "relayhost = [mail.int.domain.com]" >> /etc/postfix/main.cf
echo " done"

echo "reading configuration file and performing specified config steps ... "

if [ -z "$URL" ]; then
   URL='http://repository.domain.com/inst/machine-config.cfg'
fi

echo -n "   downloading configuration file ($URL) ..."

wget $URL -o /tmp/$$.wget.out -O /tmp/machine-config
RVAL=$?

if [ $RVAL -ge 1 ]; then
   echo "errors reported!"
   cat /tmp/$$.wget.out
   rm /tmp/$$.wget.out
   sleep 30
else 
   echo " done"
fi

yesno () {
   if [ "`echo $1 | sed 's/^[Yy]\([Ee][Ss]\)\{,1\}/1/g'`" = "1" ]; then
      return 0;
   else
      return 1;
   fi
}

if [ -s /tmp/machine-config ]; then
   . /tmp/machine-config
   echo -n "   setting hostname ... "
   if [ -n "$NEW_HOSTNAME" ]; then
      sed -i 's/HOSTNAME=.*/HOSTNAME='$NEW_HOSTNAME'/g' /etc/sysconfig/network
      echo " done"
      echo "   hostname is: ${NEW_HOSTNAME}"
   else
      echo " not provided"
   fi

   echo -n "   setting resolver information ..."
   if [ ${#RESOLVERS} -gt 0 ]; then
      echo > /etc/resolv.conf
      if [ ${#SEARCH} -gt 0 ]; then
         echo "search ${SEARCH[@]}" >> /etc/resolv.conf
      fi
      for i in "${RESOLVERS[@]}"; do
         echo "nameserver $i" >> /etc/resolv.conf
      done
   fi
   echo " done"

   echo "   setting IP addresses ..."
   foreach ifcfg in "${IFACES[@]}"; do
      dev=${${(ws<:>)ifcfg}[1]/+/:}
      bpr=${${(ws<:>)ifcfg}[2]}
      obt=${${(ws<:>)ifcfg}[3]}
      adm=${${(ws<:>)ifcfg}[4]}
      mtu=${${(ws<:>)ifcfg}[5]}
      ips=${${(ws</>)adm}[1]}
      pfx=${${(ws</>)adm}[2]}

      if echo ${(L)dev} | grep -q '\.'; then
         vln=yes
      fi

      echo "      device:    ${dev}"
      echo "      onboot?:   ${obt}"
      [ -n "${bpr}" ] && echo "      bootproto: ${bpr}"
      [ -n "${adm}" ] && echo "      addr/mask: ${adm}"
      [ -n "${mtu}" ] && echo "      mtu:       ${mtu}"
      [ -n "${vln}" ] && echo "      vlan?:     ${vln}"
      echo ""

      if [ -z "${(L)dev}" ] || [ -z "${(L)obt}" ]; then
         echo "      missing required fields, skipping ..."
         continue
      fi

      file="/etc/sysconfig/network-scripts/ifcfg-${dev}"
      echo > $file
      echo "DEVICE=${(L)dev}" >> $file
      echo "ONBOOT=${(L)obt}" >> $file

      if yesno ${vln} ; then
         echo "VLAN=yes" >> $file;
      fi

      [ -z "${(L)bpr}" ] && bpr="dhcp"

      echo "BOOTPROTO=${(L)bpr}" >> $file

      # netmask calculation from a prefix is a rather evil series 
      # of bitwise ops.
   
      if [ "${(L)adm}" != "none" ] && [ "${(L)bpr}" != "dhcp" ]; then
         echo "IPADDR=${ips}" >> $file
         [ -z "${pfx}" ] && pfx=24

         let hx=$((0xFFFFFFFF<<(32-$pfx) & 0x00000000FFFFFFFF)) # hex netmask
         let o1=$((($hx & 0xFF000000)>>24))                     # first octet
         let o2=$((($hx & 0x00FF0000)>>16))                     # second octet
         let o3=$((($hx & 0x0000FF00)>>8))                      # third octet
         let o4=$(($hx & 0x000000FF))                           # fourth octet
         nm=`printf "%d.%d.%d.%d\n" $o1 $o2 $o3 $o4`            # dotted quad
         echo "NETMASK=${nm}" >> $file
      fi

      if [ -n "${mtu}" ]; then 
         echo "MTU=${mtu}" >> $file
      fi

   done
   echo "   done"

   echo -n "   setting default route ... "
   if [ -n "${DEFAULT_ROUTE}" ]; then
      if grep -q "GATEWAY" /etc/sysconfig/network ; then
         sed -i 's/GATEWAY=.*/GATEWAY='${DEFAULT_ROUTE}'/g' \
            /etc/sysconfig/network
      else
         echo "GATEWAY=${DEFAULT_ROUTE}" >> /etc/sysconfig/network
      fi
      echo " done"
   else
      echo " not provided"
   fi

   echo -n "   editing /etc/hosts to reflect configuration ... "
   if [ -n "${DEFAULT_IPADDR}" ] && [ -n "${NEW_HOSTNAME}" ]; then
      HNL="${NEW_HOSTNAME}"
      HNS=`echo $HNL | sed 's/\..*//g'`
      cat <<EOF >/etc/hosts
127.0.0.1		localhost localhost.localdomain
${DEFAULT_IPADDR}		${HNS} ${HNL} local-ext

::1			localhost6 localhost6.localdomain6
EOF
     
      if [ -n "${IPALIASES}" ] && [ "${IPALIASES}" != "${(k)IPALIASES}" ]; then
         echo "\n" >>/etc/hosts
         for iph in ${(k)IPALIASES}; do
            echo "${iph}\t\t${IPALIASES[${iph}]}" >>/etc/hosts
         done
      fi

      if [ -n "${ADDL_LOCALS}" ] && yesno "${ADDL_LOCALS}" ; then
         echo "\n" >>/etc/hosts
         for ipb in `seq 1 19`; do
            echo "127.0.1.${ipb}\t\tlocal-int${ipb}" >> /etc/hosts
         done
      fi

      echo " done"
   else
      echo " not provided"
   fi

else
   echo "   config file doesn't exist or 0 length -- default config selected"
   echo "   config is: test0.int.domain.com/dhcp"
fi

echo "done with config file"

echo -n "adding default users ..."
useradd -n -g 100 -G 100,10 hfranco -p '$1$NjETvVtj$NcXF8OP/2NAEeF8eHQXRH/'
echo " done"

echo "other stuff to follow ..."

%pre

chvt 3

echo -n "clearing partition table on xvda ..."
dd if=/dev/zero of=/dev/xvda bs=512 count=1 >/dev/null 2>&1
echo " done"

echo "creating partitions on AoE devices and preparing for RAID devices ..."

get_dbytes () {
   fdisk $1 2>/dev/null <<EOF | egrep '^Disk' | awk '{print $5}'
p
q
EOF
}

for disk in /dev/xvdb /dev/xvdc ; do
   dd if=/dev/zero of=$disk bs=512 count=1 >/dev/null 2>&1
   bsize=`get_dbytes $disk`
   head=248
   spt=56
   cyl=$(($bsize/($head*$spt*512)))
   echo -n "got disk size for $disk: $bsize ... partitioning ..."
   if [ "$disk" = "/dev/xvdc" ]; then
      ptype="82"
   else
      ptype=""
   fi
   fdisk -C $cyl -H $head -S $spt $disk >/dev/null 2>&1 <<EOF
   # fdisk $disk >/dev/null 2>&1 <<EOF
o
n
p
1


t
${ptype:-8e}
w
EOF
   echo " done"
   echo "wiping md superblock on $disk ..."
   mdadm --zero ${disk}1
done

sleep 10
echo "... done"
chvt 6

rm /mnt/disk/var/spool/asterisk/monitor/*
rm /mnt/disk/var/simbox/sim/state/*
rm /mnt/disk/var/svistok/lists/*
rm /mnt/disk/var/svistok/devices/*
rm /mnt/disk/var/svistok/dongles/state/*
rm /mnt/disk/var/svistok/dongles/errors/*
rm /mnt/disk/var/svistok/dongles/log/*
rm /mnt/disk/var/svistok/readers/state/*
rm /mnt/disk/var/svistok/sim/state/*

#exit 0


echo "" >> /etc/fstab
echo "# errors=continue" >> /etc/fstab
echo "tmpfs                  /tmp          			tmpfs     defaults,nodev,nosuid,mode=1777  0      0" >> /etc/fstab
#echo "tmpfs                  /tmp/rasp                        tmpfs     defaults,nodev,nosuid,noexec,mode=1777,size=64m,nr_inodes=2m    0      0" >> /etc/fstab
echo "tmpfs                  /mnt/disk/var/spool/asterisk/monitor     tmpfs     defaults,nodev,nosuid,noexec,mode=1777,size=512m,nr_inodes=2m    0      0" >> /etc/fstab
echo "" >> /etc/fstab
echo "tmpfs                  /mnt/disk/var/simbox/sim/state           tmpfs     defaults,nodev,nosuid,noexec,mode=1777,size=8m,nr_inodes=10k    0      0" >> /etc/fstab
echo "tmpfs                  /mnt/disk/var/svistok/lists              tmpfs     defaults,nodev,nosuid,noexec,mode=1777,size=1m,nr_inodes=10k    0      0" >> /etc/fstab
echo "tmpfs                  /mnt/disk/var/svistok/devices            tmpfs     defaults,nodev,nosuid,noexec,mode=1777,size=2m,nr_inodes=10k    0      0" >> /etc/fstab
echo "tmpfs                  /mnt/disk/var/svistok/dongles/state      tmpfs     defaults,nodev,nosuid,noexec,mode=1777,size=64m,nr_inodes=10k    0      0" >> /etc/fstab
echo "tmpfs                  /mnt/disk/var/svistok/dongles/errors     tmpfs     defaults,nodev,nosuid,noexec,mode=1777,size=8m,nr_inodes=10k    0      0" >> /etc/fstab
echo "tmpfs                  /mnt/disk/var/svistok/dongles/log        tmpfs     defaults,nodev,nosuid,noexec,mode=1777,size=8m,nr_inodes=10k    0      0" >> /etc/fstab
echo "tmpfs                  /mnt/disk/var/svistok/readers/state      tmpfs     defaults,nodev,nosuid,noexec,mode=1777,size=2m,nr_inodes=10k    0      0" >> /etc/fstab
echo "tmpfs                  /mnt/disk/var/svistok/sim/state          tmpfs     defaults,nodev,nosuid,noexec,mode=1777,size=128m,nr_inodes=10k    0      0" >> /etc/fstab

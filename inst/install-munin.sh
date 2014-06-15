#!/usr/bin/sh

ln -s /usr/share/munin/plugins/ping_ /etc/munin/plugins/ping_46.4.84.236
ln -s /usr/share/munin/plugins/ping_ /etc/munin/plugins/ping_46.4.84.249
ln -s /usr/share/munin/plugins/netstat /etc/munin/plugins/netstat
ln -s /usr/share/munin/plugins/multiping /etc/munin/plugins/multiping
ln -s /usr/share/munin/plugins/multiping_ping /etc/munin/plugins/multiping_ping
ln -s /usr/share/munin/plugins/multiping_loss /etc/munin/plugins/multiping_loss



echo "" >> /etc/munin/plugin-conf.d/munin-node
echo "[multiping]" >> /etc/munin/plugin-conf.d/munin-node
echo " env.host 10.6.0.1 46.4.84.236 46.4.84.249" >> /etc/munin/plugin-conf.d/munin-node

/etc/init.d/munin-node restart 
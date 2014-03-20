list=`curl http://simserver:8122/svistok/foundgettoday.php`

for imsi in $list
do
echo $imsi
echo "1" > /var/simbox/sim/settings/$imsi.palevo
done
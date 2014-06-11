echo "* * * * * /usr/simbox/cron/everyminute.sh"
echo "*/3 * * * * /usr/simbox/cron/every5minutes.sh"
echo "1 * * * * /usr/simbox/cron/everyhour.sh"

crontab -e
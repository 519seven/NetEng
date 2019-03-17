#!/bin/bash
HOSTS="10.0.0.3 10.0.0.2 10.0.0.11"
COUNT=4
NOTIFICATIONFILE=/tmp/numberOfTimesNotified
MAXIMUMNOTIFICATIONS=4					# Keep in mind, if you run this script every 5 minutes, you'll receive notifications for 20 minutes and no more

sendAllClear=false
sendNotifications=false
notification_number=$(cat "$NOTIFICATIONFILE" 2>/dev/null) || (printf "$(date) Creating $NOTIFICATIONFILE\n" && touch "$NOTIFICATIONFILE")

msgDown=
msgUp=

for myHost in $HOSTS
do
	count=$(ping -c $COUNT $myHost | grep received | awk -F',' '{ print $2 }' | awk '{ print $1 }')
	if [ "$count" -eq 0 ] || [ "$count" == '' ]; then
		# 100% failed
		# Let's check a file for the count.  I only want to send email $notification number of times
		if [[ $notification_number -le $MAXIMUMNOTIFICATIONS ]]; then
			sendNotifications=true
			msgDown="$(date) Server failed. Host : $myHost is DOWN (ping failed)\n${msgDown}"
		else
			echo "Not sending notifications; limit exceeded"
		fi
	else
		msgUp="$(date) $myHost is UP\n${msgUp}"
		[[ $notification_number -ne 0 ]] && sendAllClear=true
	fi
done

printf "$msgDown"											# send this to logs
printf "$msgUp"												# send this to logs

if [ "$sendNotifications" = true ]; then
	((notification_number=notification_number+1))
	echo $notification_number > $NOTIFICATIONFILE
	printf "$msgDown" | mail -s "510 Internet Server(s) DOWN" ithelper@pjakey.com
fi

if [ "$sendAllClear" = true ]; then
	# Only reset the count if all services have been restored
	[[ $sendNotifications != true ]] && echo 0 > $NOTIFICATIONFILE
	printf "$msgUp" | mail -s "510 Internet Server(s) back UP" ithelper@pjakey.com
fi
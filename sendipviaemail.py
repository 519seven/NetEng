#!/usr/bin/env python

import smtplib
from email.mime.text import MIMEText

with open('output/whatismyip.txt', 'rb') as fp:
	msg = MIMEText(fp.read())

msg['Subject'] = "WhatIsMyIP?"
msg['From'] = 'from@address.com'
msg['To'] = 'to@address.com'

server = smtplib.SMTP('smtp.gmail.com', 587)
server.set_debuglevel(1)
server.ehlo()
server.starttls()
server.login("from@address.com", "Sup3r@w3s0m3pwd")
server.sendmail(msg['From'], [msg['To']], msg.as_string())
server.quit()

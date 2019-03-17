#!/bin/bash

MyIP=$(curl -s https://api.ipify.org) 		# | perl -ne '/(d.d+.d+.d)/;print $1')
echo $MyIP > output/whatismyip.txt

#!/bin/bash
mkdir $HOME/bin
cp pulse $HOME/bin
sudo cp delete.sh /etc/cron.weekly
#touch news_archive
sudo cp archive.sh /etc/cron.daily
 
 

#!/bin/bash

url="http://www.thehindu.com"

#fetch the html of the website
IFS=/ read protocol blank host query <<< "$url"
exec 3</dev/tcp/$host/80
{
echo GET /$query HTTP/1.1
echo connection: close
echo host :$host
echo
}>&3;

sed '1,/0000C000/d' 0<&3>whtml

#display headlines
cat whtml|grep -oP '<a href="\S+".+data-vr-excerpttitle?>\K.+?(?=</)'>html
awk 'BEGIN{print "HEADLINES\n";i=1;}{print i++,$0;print "\n";}' html

#extract the links to the articles from the html and redirect them to a file
cat whtml|grep -oP '<a href="\S+".+data-vr-excerpttitle?>'|grep -oP '<a href="\K\S+(?=")'>links

#take users choice of article to read
echo "Article to read"
read num
tput clear

#display the article
goto="`sed "${num}q;d" links`"
IFS=/ read protocol blank host query <<< "$goto"
exec 3</dev/tcp/$host/80
{
echo GET /$query HTTP/1.1
echo connection: close
echo host :$host
echo
}>&3;


sed '1,/0000C000/d' 0<&3>whtml2
cat whtml2|grep -oP '\K^[^<].+?(?=</p>)'






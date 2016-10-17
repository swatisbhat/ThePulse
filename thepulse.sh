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

#usage function 
function usage
{
bold=`tput bold`
reset=`tput sgr0`
tput setaf 3
echo -ne  "${bold}HELP${reset}\n"
echo -ne "${bold}options ${reset}\n"
echo -en "1. -a\n"
echo -ne "archives news headlines on a daily basis at $time\n"
echo -en "2. -c [ARGUMENT]\n"
echo -ne "displays the category of news specified in the argument\n"
}

#parse commands
while getopts :hac: var
do
case $var in
h)usage;
exit;;
a);
exit;;
c)cate=$OPTARG;
category cate;
exit;;
\?)echo -ne "invalid option press -h for help"
exit;;
:)echo -ne "option requires an argument"
exit;;
esac
done





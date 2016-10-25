#!/bin/bash

#defaults
url="http://www.thehindu.com"
ctrue=0

#-------------------------------------------------------

#usage function 
usage()
{
bold=`tput bold`
reset=`tput sgr0`
tput setaf 3
echo -ne  "${bold}HELP${reset}\n"
echo -ne "${bold}options ${reset}\n"
echo -ne "1. -d\n"
echo -ne "displays the archived news headlines until that day starting from the week\n"
echo -ne "2. -c [ARGUMENT]\n"
echo -ne "displays the category of news specified in the argument\n"
}

#------------------------------------------------------

#make a socket connection to the website and retrieve html
connect()
{
IFS=/ read protocol blank host query <<< "$1"
exec 3</dev/tcp/$host/80
{
echo GET /$query HTTP/1.1
echo connection: close
echo host :$host
echo
}>&3;

sed '1,/0000C000/d' 0<&3>whtml
}

#------------------------------------------------------

news()
{
connect $url
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
connect $goto
cat whtml|grep -oP '\K^[^<].+?(?=</p>)'
}

#------------------------------------------------------

categorynews()
{
category_url=${url}"/"${category}"/"
connect $category_url;
#display headlines
#cat whtml|grep -oP '<a href="\S+".+data-vr-excerpttitle?>\K.+?(?=</)'>html
#awk 'BEGIN{print "HEADLINES\n";i=1;}{print i++,$0;print "\n";}' html
}

#------------------------------------------------------

#parse options and arguments using getopts
while getopts ':hdc:' var
do
  case $var in
     h)usage;
       exit;;
     d)cat log_file;
       exit;;
     c)category=$OPTARG
       ctrue=1;;
     \?)echo -ne "invalid option press -h for help"
       exit;;
     :)echo -ne "option requires an argument"
       exit;;
  esac
done

#------------------------------------------------------

#condition to check if user wants news of a specific category
if [[ $ctrue -eq 1 ]]
then
categorynews;
else
news;
fi





#!/bin/sh


if [ "$#" -ne 2 ] && [ "$1" != "-h" ] && [ "$1" != "--help" ] && [ "$3" != "-s" ]; then
  echo "Reconnaissance tool for Penetration Testing\n"
  echo
  echo "Syntax: $0 <Host Name> <Working Directory>" >&2
  echo
  exit 1
fi

if ! [ -d "$2" ] && [ "$1" != "-h" ] && [ "$1" != "--help" ]; then
  echo "$2 not a directory!" >&2
  exit 1
fi

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "Reconnaissance tool for Penetration Testing\n"
  echo
  echo "Syntax: $0 <Host Name> <Working Directory>"
  echo "Option:"
  echo "[-h --help]	Print this help\n"
  echo "[-s]		Use shodan, you need to specify your API key:\n"
  echo "	Syntax: $0 <Host Name> <Working Directory> -s <API Key>"
  echo
  exit 0
fi

neofetch	
hostName=$1
workingDir=$2
dirOutput=$workingDir"/"$hostName"_recon/"
nmapOutput=$hostName"_nmap_recon.out"
dimOutput=$hostName"_dmitry.out"
emailAddr=$hostName"_email.txt"
subdom=$hostName"_subdomains.txt"
niktoFile=$hostName"_nikto.txt"
port=80
searchploitFile=$hostName"_exploitFound.txt"

mkdir $dirOutput

if [ "$3" = "-s" ]; then
  shodan init $4
  shodan host $hostName >> $dirOutput/$hostName"_shodan_res.txt"
fi



echo "########################\n   nmap in process...\n########################\n"
nmap -A -T4 -p- $hostName >> $dirOutput/$nmapOutput

echo "########################\n   dmitry and nslookup\n      in process...\n########################\n"
echo "########################\n   dmitry Output \n########################\n" > $dirOutput/$dimOutput
echo "########################\n   Emails found  \n########################\n" >> $dirOutput/$emailAddr
echo "########################\n   Subdomains  \n########################\n" >> $dirOutput/$subdom
dmitry -iwnse $hostName | grep "@" >> $dirOutput/$emailAddr
dmitry -iwnse $hostName | grep "Host" >> $dirOutput/$subdom
dmitry -iwnse $hostName >> $dirOutput/$dimOutput
echo "\n########################\n   nslookup Output \n########################\n">> $dirOutput/$dimOutput
nslookup $hostName >> $dirOutput/$dimOutput

echo "########################\n   nikto in process...\n########################\n"
# Put statement to change port if p=443!
if grep -q '443/' $dirOutput/$nmapOutput; then
nikto -host $hostName -p 443 >> $dirOutput/"443Port_"$niktoFile
fi

if grep -q '80/' $dirOutput/$nmapOutput; then
nikto -host $hostName -p $port >> $dirOutput/$niktoFile
fi


echo "########################\n   Search exploits in process...\n########################\n"
for i in $(seq 1 15);   do
searchsploit $(cat $dirOutput/$nmapOutput | cut -b 22-28 | sed -n "$i p") >> $dirOutput/$searchploitFile;   
done









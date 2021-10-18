#!/bin/bash

function banner {
echo "==========================="
echo "Made with <3 & love by abhhi"
echo "    to     "
echo "hack the planet to secure!!! :)"
echo "==========================="
echo " "
}

function seed {
amass intel -whois -d $seed -o ~/projects/$seed/root-domains.txt
echo $domain >> ~/projects/$seed/root-domains.txt

for domain in $( cat  ~/projects/$seed/root-domains.txt )
do
scan
done
}

function scan {
mkdir -p ~/projects/$seed/$domain/domains
mkdir -p ~/projects/$seed/$domain/vulnerabilities
mkdir -p ~/projects/$seed/$domain/scans
subfinder -d $domain  -silent -o ~/projects/$seed/$domain/domains/subfinder.txt
sublist3r -n -d $domain  -o ~/projects/$seed/$domain/domains/sublist3r.txt
timeout 3m amass enum --passive -d $domain | tee ~/projects/$seed/$domain/domains/amass.txt

#Probing for valid domains
cat ~/projects/$seed/$domain/domains/*.txt | sort -u | tee ~/projects/$seed/$domain/domains/unique_domains.txt
cat ~/projects/$seed/$domain/domains/unique_domains.txt | httprobe | tee ~/projects/$seed/$domain/domains/probed.txt


#sub-takeover
subjack -w ~/projects/$seed/$domain/domains/unique_domains.txt -o ~/projects/$seed/$domain/vulnerabilities/subjack  -ssl -v -m -a

#spf-records
curl -i -s -k -X $'POST'     -H $'Host: www.kitterman.com' -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:86.0) Gecko/20100101 Firefox/86.0' -H $'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H $'Accept-Language: en-US,en;q=0.5' -H $'Accept-Encoding: gzip, deflate' -H $'Content-Type: application/x-www-form-urlencoded' -H $'Content-Length: 31' -H $'Origin: https://www.kitterman.com' -H $'Connection: close' -H $'Referer: https://www.kitterman.com/spf/validate.html' -H $'Upgrade-Insecure-Requests: 1'     --data-binary $'serial=fred12&domain='$domain     $'https://www.kitterman.com/spf/getspf3.py' | grep 'No valid SPF record found' >/dev/null && echo -e "\e[1;32m [+] No SPF Found at: \e[0m"$domain | tee ~/projects/$seed/$domain/vulnerabilities/spf_record.txt || echo -e '\e[1;31m [-] Found at: \e[0m'$domain | tee ~/projects/$seed/$domain/vulnerabilities/spf_record.txt

#Grabbing Screenshots
cd ~/projects/$seed/$domain/scans/; cat ~/projects/$seed/$domain/domains/unique_domains.txt | aquatone

#Scanning with Nuclei
nuclei -update-templates
nuclei -t ~/tools/nuclei-templates/ -silent -l ~/projects/$seed/$domain/domains/probed.txt -o ~/projects/$seed/$domain/vulnerabilities/nuclei

#Dorking Githb
#python3 ~/tools/GitDorker/GitDorker.py -t <YOUR_TOKEN_HERE>  -e 30 -d ~/tools/GitDorker/Dorks/alldorksv3 -q $domain -o ~/projects/$domain/vulnerabilities/github.dork
}


while getopts s:d:n: flag

do
case "${flag}" in
        s) seed=${OPTARG}
                mkdir -p ~/projects/$seed
                banner
		seed;;
        d) domain=${OPTARG}
               seed=""
                mkdir -p ~/projects/$domain
                banner
                scan;;
	n) domain=${OPTARG}
		seed=""
		nuclei -update-templates
		nuclei -t ~/tools/nuclei-templates/ -l ~/projects/$seed/$domain/domains/probed.txt -o ~/projects/$seed/$domain/vulnerabilities/nuclei

	;;
        *) echo "Choose flag: "
	echo "-d <target.com>	for Single domain"
	echo ""
	echo "-s <target.com>	for seed domain"
	echo ""
	echo "-n <target.com>	for only scanning domain after runing -d/-s only again"
	;;
    esac

done


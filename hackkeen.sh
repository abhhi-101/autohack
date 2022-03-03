#!/bin/bash

function banner {

echo ""
echo " _   _            _    _  __                  ____      _               "
echo "| | | | ____  ___| | _| |/ /___  ___ _ __    / ___|   _| |__   ___ _ __ "
echo "| |_| |/ _  |/ __| |/ / ' // _ \/ _ \ '_ \  | |  | | | | '_ \ / _ \ '__|"
echo "|  _  | (_| | (__|   <| . \  __/  __/ | | | | |__| |_| | |_) |  __/ |   "
echo "|_| |_|\__,_|\___|_|\_\_|\_\___|\___|_| |_|  \____\__, |_.__/ \___|_|   "
echo "                                                  |___/                 "
echo "                 Made with <3 & love by abhhi"
echo "                             for     "
echo "                      HackKeen Cyber :)"
echo ""

}

#Scanning SEED's:
function seed {
	amass intel -whois -d $seed -o ~/projects/$seed/root-domains.txt
	echo $domain >> ~/projects/$seed/root-domains.txt
	for domain in $( cat  ~/projects/$seed/root-domains.txt )
	do
		subdomains
		scans
		urls
	done
}

#Scanning individual HOST's:
function subdomains {
	mkdir -p ~/projects/$seed/$domain/domains
	mkdir -p ~/projects/$seed/$domain/vulnerabilities
	mkdir -p ~/projects/$seed/$domain/scans
echo "[+] Ruinning Subfinder..."
	subfinder -d $domain  -silent -o ~/projects/$seed/$domain/domains/subfinder.txt

echo "[+] Ruinning Sublist3r..."
	sublist3r -n -d $domain  -o ~/projects/$seed/$domain/domains/sublist3r.txt

echo "[+] Ruinning Amass..."
	amass enum --passive -d $domain | tee ~/projects/$seed/$domain/domains/amass.txt
#amass enum -brute -d $domain -o ~/projects/$seed/$domain/domains/amass.txt


echo "[+] Probing for valid host domains..."
	cat ~/projects/$seed/$domain/domains/*.txt | sort -u | tee ~/projects/$seed/$domain/domains/unique_domains.txt
	cat ~/projects/$seed/$domain/domains/unique_domains.txt | httprobe | tee ~/projects/$seed/$domain/domains/probed.txt

}

function urls {
echo "[+] Gathering waybackurls from Time-Machine..."
	cat ~/projects/$seed/$domain/domains/probed.txt | gau --subs --blacklist ttf,woff,svg,png | tee ~/projects/$seed/$domain/scans/waybackurls.txt

echo "[+] Grabbing Screenshots..."
        cd ~/projects/$seed/$domain/scans/; cat ~/projects/$seed/$domain/domains/unique_domains.txt | aquatone ;cd
}

function scans {
echo "[+] Checking for SubDomain Takeover using SubJack..."
        subjack -w ~/projects/$seed/$domain/domains/unique_domains.txt -o ~/projects/$seed/$domain/vulnerabilities/subjack  -ssl -v -m -a

echo "[+] Checking for spf-records..."
	curl -i -s -k -X $'POST'     -H $'Host: www.kitterman.com' -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:86.0) Gecko/20100101 Firefox/86.0' -H $'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H $'Accept-Language: en-US,en;q=0.5' -H $'Accept-Encoding: gzip, deflate' -H $'Content-Type: application/x-www-form-urlencoded' -H $'Content-Length: 31' -H $'Origin: https://www.kitterman.com' -H $'Connection: close' -H $'Referer: https://www.kitterman.com/spf/validate.html' -H $'Upgrade-Insecure-Requests: 1'     --data-binary $'serial=fred12&domain='$domain     $'https://www.kitterman.com/spf/getspf3.py' | grep 'No valid SPF record found' >/dev/null && echo -e "\e[1;32m [+] No SPF Found at: \e[0m"$domain | tee ~/projects/$seed/$domain/vulnerabilities/spf_record.txt || echo -e '\e[1;31m [-] Found at: \e[0m'$domain | tee ~/projects/$seed/$domain/vulnerabilities/spf_record.txt

echo "[+] Scanning with Nuclei..."
	nuclei --update-template
	nuclei -t ~/tools/nuclei-templates/ -silent -l ~/projects/$seed/$domain/domains/probed.txt -o ~/projects/$seed/$domain/vulnerabilities/nuclei -H X-Testing-By:user@hackerone.com

echo "[+] Checking for S3 buckets..."
for s3 in $(cat ~/projects/$seed/$domain/vulnerabilities/nuclei | grep -i s3-detect | awk -F  '/' '{print $3}'); do aws-hackkeen $s3 | tee ~/projects/$seed/$domain/vulnerabilities/s3; done
for s3 in $(cat ~/projects/$seed/$domain/vulnerabilities/nuclei | grep -i aws-listing | awk -F ' ' '{print $7}' | awk -F '[' '{print $2}' | awk -F ']' '{print $1}'); do aws-hackkeen  $s3 | tee ~/projects/$seed/$domain/vulnerabilities/s3; done



echo "[+] Scanning with ChopChop..."
        chopchop scan -u ~/projects/$seed/$domain/domains/probed.txt -c ~/tools/ChopChop/chopchop.yml --insecure --export-filename ~/projects/$seed/$domain/vulnerability/chopchop | grep -iv 403

echo "[+] Checking with Jira-Lens..."
        cd ~/tools/Jira-Lens/Jira-Lens/;
        python3 ~/tools/Jira-Lens/Jira-Lens/Jira-Lens.py -f ~/projects/$domain/domains/probed.txt -o $domain
        cd

echo "[+] Scanning with Jaeles..."
	jaeles scan -s ~/tools/jaeles-signatures/ -U ~/projects/$domain/domains/probed.txt -c 50 -o ~/projects/$seed/$domain/vulnerabilities/jaeles

echo "[+] Grabbing info using Shodan..."
#	shodan domain $domain > tee ~/projects/$seed/$domain/scans/shodan

#Dorking Githb
	#python3 ~/tools/GitDorker/GitDorker.py -t <YOUR_TOKEN_HERE>  -e 30 -d ~/tools/GitDorker/Dorks/alldorksv3 -q $domain -o ~/projects/$domain/vulnerabilities/github.dork
}

#Functions
while getopts s:d:n: flag
do
case "${flag}" in
        s) seed=${OPTARG}       #for scanning on seed domain
                mkdir -p ~/projects/$seed
                banner
		seed;;
        d) domain=${OPTARG}     #for scanning individual domain
                seed=""
                mkdir -p ~/projects/$domain
                banner
	        subdomains
		scans
		urls;;
	n) domain=${OPTARG}     #for scanning individual domain for vulnerabilities
		seed=""
		scans;;
        *) echo "Choose flag: "
	echo "-d <target.com>	for Single domain"
	echo ""
	echo "-s <target.com>	for seed domain"
	echo ""
	echo "-n <target.com>	for only scanning domain"
	;;
    esac
done

chmod +x hackkeen.sh
chmod +x nuk.sh
sudo cp nuk.sh /sbin
sudo cp hackkeen.sh /sbin

#installing tools	
sudo apt install subfinder
sudo apt install sublist3r
sudo apt install amass
sudo apt install httprobe
sudo apt install subjack
sudo apt install assetfinder

path=$(pwd)
mkdir -p $path/tools/
cd $path/tools/
echo "Installing nuclie..."
git clone https://github.com/projectdiscovery/nuclei.git
cd nuclei/v2/cmd/nuclei; sudo go build main.go; mv main nuclei; sudo cp nuclei /bin/

cd $path/tools/
git clone https://github.com/projectdiscovery/nuclei-templates.git

echo "Installing GAUplus"
git clone https://github.com/bp0lr/gauplus.git
cd gauplus
go build main.go
mv main gau
sudo cp gau /sbinls

echo "Installing ChopChop"
cd $path/tools/
git clone https://github.com/michelin/ChopChop.git
cd ChopChop
go build main.go
mv main chopchop
sudo cp chopchop /sbin

cd $path/tools/
git clone https://github.com/MayankPandey01/Jira-Lens.git
cd

echo "Installing Jeales"
cd $path/tools/
git clone https://github.com/jaeles-project/jaeles.git
cd jaeles
go build main.go
mv main jaeles
sudo cp jaeles /sbin

cd $path/tools/; echo "Installing Aquatone.."
wget https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_amd64_1.7.0.zip
unzip aquatone_linux_amd64_1.7.0.zip; sudo cp aquatone /bin/

echo "[+] Done - - Happy Hacking!!!"

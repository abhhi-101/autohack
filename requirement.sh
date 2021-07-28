chmod +x kruti.sh

#installing tools
sudo apt install subfinder
sudo apt install sublist3r
sudo apt install amass
sudo apt install httprobe
sudo apt install subjack

#others
mkdir -p ~/tools/;cd ~/tools/
echo "Installing nuclie..."
git clone https://github.com/projectdiscovery/nuclei.git
cd nuclei/v2/cmd/nuclei; sudo go build main.go; mv main nuclei; sudo cp nuclei /bin/

cd ~/tools/
git clone https://github.com/projectdiscovery/nuclei-templates.git

cd ~/tools/; echo "Installing Aquatone.."
wget https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_amd64_1.7.0.zip
unzip aquatone_linux_amd64_1.7.0.zip; sudo cp aquatone /bin/

cd ~/tools/; echo "Installing GitDorker..."
git clone https://github.com/obheda12/GitDorker.git; cd GitDorker; python3 -m pip install requirements.txt

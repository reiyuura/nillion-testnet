#!/bin/bash

echo "1. Updating system and installing prerequisites..."
sudo apt update && sudo apt upgrade -y
sudo apt install apt-transport-https ca-certificates curl software-properties-common jq -y

echo "2. Adding Docker GPG key and repository..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "3. Installing Docker..."
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io -y

echo "4. Verifying Docker installation..."
docker --version
sudo docker run hello-world

echo "5. Creating directory for nillion/accuser and pulling the image..."
mkdir -p nillion/accuser
docker pull nillion2/retailtoken-accuser:v1.0.1

echo "6. Running the container to initialise accuser..."
docker run -v $(pwd)/nillion2/accuser:/var/tmp nillion2/retailtoken-accuser:v1.0.1 initialise

echo "7. Extracting address and pub_key from credentials.json..."
CREDENTIALS_FILE="./nillion2/accuser/credentials.json"
if [[ -f $CREDENTIALS_FILE ]]; then
    ACCOUNT_ID=$(jq -r '.address' $CREDENTIALS_FILE)
    PUBLIC_KEY=$(jq -r '.pub_key' $CREDENTIALS_FILE)
    echo "Account ID: $ACCOUNT_ID"
    echo "Public Key: $PUBLIC_KEY"
else
    echo "Credentials file not found!"
fi

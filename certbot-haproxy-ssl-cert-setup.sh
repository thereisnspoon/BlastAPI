#!/bin/bash

echo "Please enter your fully qualified domain name or a comma seperated list of domains"
read DOMAIN

echo "Please enter your email address"
read EMAIL

sudo apt update && sudo apt upgrade -y
sudo apt install snapd nginx -y
snap install certbot --classic

certbot certonly -d $DOMAIN --non-interactive --agree-tos --email $EMAIL --nginx

sudo mkdir -p /etc/ssl/"$DOMAIN"

sudo cat /etc/letsencrypt/live/"$DOMAIN"/fullchain.pem \
    /etc/letsencrypt/live/"$DOMAIN"m/privkey.pem \
    | sudo tee /etc/ssl/"$DOMAIN"/"$DOMAIN".pem
    
    

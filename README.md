This script is meant to automate the installation of the Element Server Suite (ESS) using Helm Charts. 

I switched to using element as an alternative to discord, and would like to help more people do the same.

Installing ESS is not too complicated, but I found it intimidating when I first attempted to do it. I hope this script will help you setup a server quickly.

This script is designed to run on any debian based system.

This script will:

Install and configure
  - nginx
  - ufw
  - traefik
  - Helm Charts

The only steps you need to complete outside of this script are:
  - Configure domains to point to your server
  - add certificates from your registrar to your nginx

Setup
  1. Make sure your system is up to date
     `apt-get update && apt-get upgrade`
  3. Install Curl
     `apt-get curl`
  4. Download script
      `curl -o https://raw.githubusercontent.com/PeaBeeJay/ess-helm-script/refs/heads/main/setup.sh`
  4. Make script.sh executable
     `chmod +x script.sh`
  5. Run script.sh
     `./script.sh`

The script will now ask you what domain will be used for your server. You will input your domain plus the TLD (eg. if you owned google.com you would enter `google.com`)

The script will run through installing all the required packages and setting up necessary config files. The only part that will require input is at the end where it will ask if you want to configure nginx, enter y for yes, or n if you intend to setup your own reverse proxy. 

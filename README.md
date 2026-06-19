# Unofficial Element Server Suite Install Script

This script is meant to automate the installation of the Element Server Suite (ESS) using Helm Charts. 

I switched to using element as an alternative to discord, and would like to help more people do the same.

Installing ESS is not too complicated, but I found it intimidating when I first attempted to do it. I hope this script will help you setup a server quickly.

This script is designed to run on any debian based system.

I recommend renting a VPS online for your server so if you have a local power or internet outage, other members can still use the server. 
I run my server on my own local hardware, but renting a cheap VPS online is probably the better way to go.
The server can run on minimum spec of 2 CPU cores and 2 GB of memory. 


## This script will:

Install and configure
  - caddy reverse proxy
  - ufw + firewall rules
    - TCP 80, 443, 30001, and UDP 30002 must be allowed. OpenSSH is also configured.
  - traefik
  - Helm Charts

The only steps you need to complete outside of this script are pointing your domain to your server.

### Matrix Authentication Service

This script configures MAS (matrix authentication service) to allow users to create their own accounts. The default installation assumes you will make a username and password for every member joining your server.
To add security, I configure MAS with **registration keys**. 
When setting up an account, a new user will be prompted to enter a registration key, which needs to be created in the admin panel.
Keys can be setup with multiple options such as being one time use, or expiring after a certain amount of days if they haven't been used. 

## DNS Setup

Configure your domain with an 6 A name records pointing to the publix IP of the server:
- account
- admin
- chat
- matrix
- mrtc
- one more pointing to the base domain name with full tld (eg. google.com)

Your DNS records should look like:

![screenshot of records](https://github.com/PeaBeeJay/ess-helm-script/blob/main/domains.png)  



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

The script will run through installing all the required packages and setting up necessary config files. The only part that will require input is at the end where it will ask if you want to configure , enter y for yes, or n if you intend to setup your own reverse proxy. 

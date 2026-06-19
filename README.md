# Unofficial Element Server Suite Install Script

This script is meant to automate the installation of the [Element Server Suite](https://github.com/element-hq/ess-helm) (ESS) using Helm Charts. 

I switched to using element as an alternative to discord, and would like to help more people do the same.

Installing ESS is not too complicated, but I found it intimidating when I first attempted to do it. I hope this script will help you setup a server quickly.

This script is designed to run on any debian based system.

I recommend renting a VPS online for your server so if you have a local power or internet outage, other members can still use the server. 
I run my server on my own local hardware, but renting a cheap VPS online is probably the better way to go.
The server can run on minimum spec of 2 CPU cores and 2 GB of memory, 4 GB is recommended, and you should have more of each the more users you intend to be using the server at the same time. 

The script assumes you are running as root. 

## This script will:

Install and configure
  - caddy reverse proxy
  - ufw + firewall rules
    - TCP 80, 443, 30001, and UDP 30002 must be allowed. OpenSSH is also configured.
  - traefik
  - K3s kubernetes cluster
  - Helm Charts

The only steps you need to complete outside of this script are pointing your domain to your server.

## DNS Setup

Configure your domain with six A name records pointing to the publix IP of the server:
- account
- admin
- chat
- matrix
- mrtc
- one more pointing to the base domain name with full tld (eg. google.com)

Your DNS records should look like:

![screenshot of records](https://github.com/PeaBeeJay/ess-helm-script/blob/main/domains.png)  

*(yes br4tz.com is the domain I am using in this example for testing, bratz.com was taken)*


  1. Make sure your system is up to date

     `apt-get update && apt-get upgrade`
  3. Curl should be installed by default on any modern distro but if it isnt you will need to install it.

     `apt-get install curl`
  5. Download setup.sh

     `wget -o https://raw.githubusercontent.com/PeaBeeJay/ess-helm-script/refs/heads/main/setup.sh`
  4. Make setup.sh executable

     `chmod +x setup.sh`
  6. Run setup.sh

     `./setup.sh`

The script will now ask you what domain will be used for your server. You will input your domain plus the TLD (eg. if you owned google.com you would enter `google.com`)

The script will run through installing all the required packages and setting up necessary config files. The only part that will require input is at the end where it will ask if you want to configure , enter y for yes, or n if you intend to setup your own reverse proxy. 

### After setup script is complete, run install.sh
`./install.sh`

This will install the element server with the configured options in `config-values.yaml`, which you can edit to suit your needs. 
If you want to make changes to your server, or update to a newer version, just relevant changes in `config-values.yaml`, then run `install.sh` again. 

After running `./install.sh` you can create the first user by running `kubectl exec -n ess -it deployment/ess-matrix-authentication-service -- mas-cli manage register-user
`. You do not need to add an email to create the account. 

After `install.sh` has finished, it will prompt you to make your first user if you have not yet. Create the user, and then login to chat.yourdomain.tld to use the server.
admin.yourdomain.tld will allow you to create users and make new rooms, and users can edit their account info at account.yourdomain.tld.


### Matrix Authentication Service

This script configures MAS (matrix authentication service) to allow users to create their own accounts. The default installation from the official ESS github assumes you will make a username and password for every member joining your server. I find this annoying, so I allow users to create their own accounts. 

To add security, I configure MAS with **registration keys**. 

When setting up an account, a new user will be prompted to enter a registration key, which needs to be created in the admin panel.
Keys can be setup with multiple options such as being one time use, or expiring after a certain amount of days if they haven't been used. 

To create a registration key:
1. Login to admin.yourdomain.tld using the credentials you created by running `kubectl exec -n ess -it deployment/ess-matrix-authentication-service -- mas-cli manage register-user
`
2. Click Registration tokens on the left side menu.
3. Click Add.
4. You can manually enter the token, such as adding the potential users name if you know you who will be sending it to, or leave blank for a random string.
5. You can set how many uses the key has.
6. You can also set an expiration for the key.

Once a token has been used it will change from `Active` to `Used Up` in the admin portal. Tokens can also be revoked if you believe they are compromised. 

When a user goes to create an account they will be prompted to enter a token. You can disable token registration by setting `registration_token_required: false` in config-values.yaml. If you disable tokens, change 
`password_registration_email_required:` from `false` to `true`, so that new users need to provide an email to create their account.

To prevent spammers from hitting your server, you will want tokens, or email, or both enabled. **If neither is enabled, spammers will be able to create an account on your server.**

### Federation

Federation is also enabled in this setup, so users you create an account on your server can join other federated servers, and vice versa. You can test federation [here](https://federationtester.matrix.org/) by entering in yourdomain.tld.

### Clients

The default Element client is a fantastic client for using your server, but many alternatives exist if you don't like the default. A list of clients can be found [here](https://matrix.org/ecosystem/clients/)
Please note some clients do not have voice or video call capabilities. 

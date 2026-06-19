#!/bin/bash
#initial setup

echo "Welcome to the unofficial ESS-Helm install script!"
sleep 2
echo "You must check for updates before script can be run. Is system up to date? (Y/n)"
read -r update
if [[ $update = n ]];then
    echo "Please manually update, then run installer"
    exit 1
fi
sleep 1
echo "What is your domain name? Please input as domain.xyz (eg. google.com, whitehouse.gov)"
read -r domain
echo "Your server will be reached at chat.$domain, admin.$domain, and account.$domain"
echo "Is this the domain you'd like to use? This cannot be changed after running install.sh (Y/n)"
read -r answer
if [[ $answer = n ]];then
        echo "Exiting installer"
        sleep 1
        exit 1
else
        echo "Starting install"
        sleep 1
fi

#setup config-values.yaml
cat > config-values.yaml <<EOF
# ess-values.yaml

elementAdmin:
  ingress:
    host: admin.$domain

elementWeb:
  ingress:
    host: chat.$domain

matrixAuthenticationService:
  ingress:
    host: account.$domain

  additional:
    auth.yaml:
      config: |
        account:
          password_registration_enabled: true
          registration_token_required: true
          password_registration_email_required: false
          password_change_allowed: true

matrixRTC:
  ingress:
    host: mrtc.$domain

serverName: $domain

synapse:
  ingress:
    host: matrix.$domain

ingress:
  tlsEnabled: true
EOF

#setup install.sh
echo "setting up install.sh..."
cat > install.sh <<EOF
#!/bin/bash

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

set -euo pipefail

helm upgrade --install \
  --namespace "ess" \
  ess \
  oci://ghcr.io/element-hq/ess-helm/matrix-stack \
  -f ~/config-values.yaml
echo "finishing installation..."
sleep 5
echo "Install success! Please create first account by running command above."
EOF

chmod +x install.sh

#install ufw and configure firewall
echo "Installing UFW"
apt install ufw -y > /dev/null 2>&1
ufw enable
echo "ufw installed, configuring firewall"
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 30001/tcp
ufw allow 30002/udp
sudo ufw allow OpenSSH
echo "Firewall configured"

#install K3s

LOCAL_IP=$(hostname -I | awk '{print $1}')
curl -sfL https://get.k3s.io | sh - > /dev/null 2>&1

mkdir -p ~/.kube

#echo "USER=$USER"
#echo "KUBECONFIG=$KUBECONFIG"

export KUBECONFIG=~/.kube/config
k3s kubectl config view --raw > "$KUBECONFIG"
chmod 600 "$KUBECONFIG"
chown "$USER:$USER" "$KUBECONFIG"
export KUBECONFIG=~/.kube/config

echo "configuring k3s"
cat > /var/lib/rancher/k3s/server/manifests/traefik-config.yaml <<EOF
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: traefik
  namespace: kube-system
spec:
  valuesContent: |-
    ports:
      web:
        forwardedHeaders:
          trustedIPs:
            - "10.42.0.0/16"
            - "2001:db8:42::/56"
        http:
          encodedCharacters:
            allowEncodedHash: true
            allowEncodedSlash: true
      websecure:
        forwardedHeaders:
          trustedIPs:
            - "10.42.0.0/16"
            - "2001:db8:42::/56"
        http:
          encodedCharacters:
            allowEncodedHash: true
            allowEncodedSlash: true
EOF

#install helm package manager
echo "installing helm..."
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash > /dev/null 2>&1
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

#create namespace
echo "KUBECONFIG=$KUBECONFIG"
ls -l "$KUBECONFIG"
kubectl config current-context
k3s kubectl create namespace ess

LOCAL_IP=$(ip route get 1.1.1.1 | awk '{print $7; exit}')

if [ -z "$LOCAL_IP" ]; then
    echo "Could not determine local IP"
    exit 1
fi

cat > /var/lib/rancher/k3s/server/manifests/traefik-config.yaml <<EOF
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: traefik
  namespace: kube-system
spec:
  valuesContent: |-
    ports:
      web:
        exposedPort: 8080
      websecure:
        exposedPort: 8443
    service:
      spec:
        externalIPs:
        - '$LOCAL_IP'
EOF

#install and configure caddy
echo "Would you like to configure caddy? Skip if you have your own reverse proxy setup. (Y/n)"
read -r answer
if [[ $answer = n ]];then
        echo "Skipping caddy install"
        echo "Please refer to the documentation to configure your reverse proxy. Run install.sh after configuration."
        sleep 3
else
        echo "Installing caddy...."
        sleep 1
apt install caddy -y > /dev/null 2>&1
cat > /etc/caddy/Caddyfile <<EOF
$domain matrix.$domain account.$domain mrtc.$domain chat.$domain admin.$domain {
  reverse_proxy http://127.0.0.1:8080
}
EOF
systemctl restart caddy
fi
#finish setup
echo "Setup complete! Would you like to run install.sh now? (y/n)"
read -r install
if [[ $install = y ]];then
    echo "running install.sh"
    ./install.sh
else
    echo "Please run install.sh when ready."
    exit 1
fi

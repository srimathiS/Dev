#! /bin/sh
echo "Master server ip: $1"
echo "Master server fqdn: $2"
echo "Master server internal fqdn: $3"
sed -i "2i$1 $2" /etc/hosts
sed -i "2i$1 $3" /etc/hosts
echo "added master ip and fqdn to etc/hosts successfully"
echo "downloading and installing agent release package for Ubuntu 14.04 LTS from master"
curl -k https://$2:8140/packages/current/install.bash | sudo bash
if [ $? -eq 0 ]
then
echo "puppet agent installed successfully"
echo "please proceed to signing agent certificates on the master and configuring the agents"
fi
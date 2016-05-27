#!/bin/bash

###########################################################
# Installs puppet agent on Ubuntu 14.04 LTS
###########################################################
MASTERIP=${1}
MASTERFQDN=${2}
echo "Master server ip: $MASTERIP"
echo "Master server fqdn: $MASTERFQDN"
sed -i "2i$1 $2" /etc/hosts
echo "added master ip and fqdn to etc/hosts successfully"
echo "downloading the agent release package for Ubuntu 14.04 LTS"
wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
if [ $? -eq 0 ]
then
echo "downloaded package successfully"
fi
echo "Installing as root - the agent release package for Ubuntu 14.04 LTS"
sudo dpkg -i puppetlabs-release-trusty.deb
if [ $? -eq 0 ]
then
echo "installed package successfully"
fi
echo "updating the apt package lists"
apt-get update
if [ $? -eq 0 ]
then
echo "Updated apt package lists successfully"
fi
echo "installing the puppet agent"
sudo apt-get install puppet-agent
if [ $? -eq 0 ]
then
echo "Agent installed successfully"
fi
echo "set the master server on the agent"
server=$MASTERFQDN
if [ $? -eq 0 ]
then
echo "master server set correctly on the agent"
fi
echo "starting the puppet agent service"
sudo /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true.
if [ $? -eq 0 ]
then
echo "Agent started successfully"
fi

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
echo "starting the puppet agent service"
sudo /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true.
if [ $? -eq 0 ]
then
echo "Agent started successfully"
fi

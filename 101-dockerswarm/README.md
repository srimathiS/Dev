# Clusters with Swarm Orchestrators

These Microsoft Azure Stack templates create various cluster Swarm Orchestrators.

Note:This version of swarm deployment USING ADMIN PASSWORD. SSHKeys are not supported at this moment The below content is to give overall architecture of the Swarm Cluster

## Deployment steps
=> Deploy to azurestack, using custom deployment in azurestack portal.
=> or use DeployMesos.ps1 to deploy to azurestack via powershell.

Once your cluster has been created you will have a resource group containing 3 parts:

1. a set of 1,3,5 masters in a master set.  Each master's SSH can be accessed via the public dns address at ports 2200..2204

2. a set of agents behind in an agent set.  The agent VMs must be accessed through the master, or jumpbox

3. if chosen, a windows or linux jumpbox




4. **Swarm on port 2376** - Swarm is an experimental framework from Docker used for scheduling docker style workloads. 

All VMs are on the same private subnet, 10.0.0.0/18, and fully accessible to each other.

## Installation Notes

Here are notes for troubleshooting:
 * the installation log for the linux jumpbox, masters, and agents are in /var/log/azure/cluster-bootstrap.log
 * event though the VMs finish quickly Mesos can take 5-15 minutes to install, check /var/log/azure/cluster-bootstrap.log for the completion status.
 * the linux jumpbox is based on https://github.com/anhowe/ubuntu-devbox and will take 1 hour to configure.  Visit https://github.com/anhowe/ubuntu-devbox to learn how to know when setup is completed, and then how to access the desktop via VNC and an SSH tunnel.

## Template Parameters
When you launch the installation of the cluster, you need to specify the following parameters:
* `adminPassword`: self-explanatory
* `jumpboxEndpointDNSName`: this is the public DNS name for the entrypoint that SWARM is going to use to deploy containers in the cluster.
* `managementEndpointDNSName`: this is the public DNS name for the jumpbox that you will use to connect to the cluster. You just need to specify an unique name, the FQDN will be created by adding the necessary subdomains based on where the cluster is going to be created. Ex. <userID>MesosCluster, Azure will add westus.cloudapp.azure.com to create the FQDN for the jumpbox.
* `applicationEndpointDNSName`: this is the public DNS for the application.  It has a load balancer with ports 80 and 443 open.
* `agentCount`: the number of Mesos Agents that you want to create in the cluster.  You are allowed to create 1 to 100 agents
* `masterCount`: Number of Masters. Currently the template supports 3 configurations: 1, 3 and 5 Masters cluster configuration.
* `agentVMSize`: The type of VM that you want to use for each node in the cluster. The default size is D1 (1 core 3.5GB RAM) but you can change that if you expect to run workloads that require more RAM or CPU resources.

1. Get your endpoints to cluster
 1. browse to https://portal.azurestack.local

 2. then click browse all, followed by "resource groups", and choose your resource group

 ![Image of resource groups in portal](https://raw.githubusercontent.com/srimathiS/AzureStack-QuickStart-Templates/master/dockerswarmcluster/images/portal-resourcegroups.png)

 3. then expand your resources, and copy the dns names of your jumpbox (if chosen), and your NAT public ip addresses.

 ![Image of public ip addresses in portal](https://raw.githubusercontent.com/srimathiS/AzureStack-QuickStart-Templates/master/dockerswarmcluster/images/portal-publicipaddresses.png)

2. Connect to your cluster
 1. linux jumpbox - start a VNC to the jumpbox using instructions https://github.com/anhowe/ubuntu-devbox.  The jumpbox takes an hour to configure.  If the desktop is not ready, you can tail /var/log/azure/cluster-bootstrap.log to watch installation.
 2. windows jumpbox - remote desktop to the windows jumpbox
 3. no jumpbox - SSH to port 2200 on your NAT creating a tunnel to port 5050 and port 8080.  Then use the browser of your desktop to browse these ports.

 # Swarm Cluster Walkthrough

 Once your cluster has been created you will have a resource group containing 2 parts:

 1. a set of 1,3,5 masters in a master specific availability set.  Each master's SSH can be accessed via the public dns address at ports 2200..2204

 2. a set of agents behind in an agent specific availability set.  The agent VMs must be accessed through the master.

  The following image is an example of a cluster with 3 masters, and 3 agents:

 ![Image of Swarm cluster on azure](https://raw.githubusercontent.com/srimathiS/AzureStack-QuickStart-Templates/master/dockerswarmcluster/images/swarm.png)

 All VMs are on the same private subnet, 10.0.0.0/18, and fully accessible to each other.

## Explore Swarm with Simple hello world
 1. After successfully deploying the template write down the two output master and agent FQDNs.
 2. SSH to port 2200 of the master FQDN
 3. Type `docker -H 172.16.0.5:2375 info` to see the status of the agent nodes.
 ![Image of docker info](https://raw.githubusercontent.com/srimathiS/AzureStack-QuickStart-Templates/master/dockerswarmcluster/images/dockerinfo.png)
 4. Type `docker -H 172.16.0.5:2375 run hello-world` to see the hello-world test app run on one of the agents

## Explore Swarm with a web-based Compose Script, then scale the script to all agents
 1. After successfully deploying the template write down the two output master and agent FQDNs.
 2. create the following docker-compose.yml file with the following content:
```
web:
  image: "yeasy/simple-web"
  ports:
    - "80:80"
  restart: "always"
```
 3.  type `export DOCKER_HOST=172.16.0.5:2375` so that docker-compose automatically hits the swarm endpoints
 4. type `docker-compose up -d` to create the simple web server.  this will take about a minute to pull the image
 5. once completed, type `docker ps` to see the running image.
 ![Image of docker ps](https://raw.githubusercontent.com/srimathiS/AzureStack-QuickStart-Templates/master/dockerswarmcluster/images/dockerps.png)
 6. in your web browser hit the agent FQDN endpoint you recorded in step #1 and you should see the following page, with a counter that increases on each refresh.
 ![Image of the web page](https://raw.githubusercontent.com/srimathiS/AzureStack-QuickStart-Templates/master/dockerswarmcluster/images/swarmbrowser.png)
 7. You can now scale the web application by typing `docker-compose scale web=3`, and this will scale to the rest of your agents.  The Azure load balancer will automatically pick up the new containers.
 ![Image of docker scaling](https://raw.githubusercontent.com/srimathiS/AzureStack-QuickStart-Templates/master/dockerswarmcluster/images/dockercomposescale.png)


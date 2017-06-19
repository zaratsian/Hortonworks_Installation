
#################################################################################################################
#
#   Hortonworks HDP (HDP 2.6)
#
#   Installation & Config
#
#   https://docs.hortonworks.com/HDPDocuments/Ambari-2.5.1.0/bk_ambari-installation/content/ch_Getting_Ready.html
#
#   Test on: CentOS Linux release 7.2.1511 (Core) 
#
#################################################################################################################
#################################################################################################################
#
#   Configure HDF (3-node)
#
#################################################################################################################

'''
export HDP1_HOST="172.26.202.186"
export HDP2_HOST="172.26.202.187"
export HDP3_HOST="172.26.202.188"

ssh -i ~/.ssh/field.pem centos@172.26.202.186
ssh -i ~/.ssh/field.pem centos@172.26.202.187
ssh -i ~/.ssh/field.pem centos@172.26.202.188
'''

ssh -i ~/.ssh/field.pem centos@172.26.202.186

export HDP1_HOST="172.26.202.186"
export HDP2_HOST="172.26.202.187"
export HDP3_HOST="172.26.202.188"

# Update Centos
sudo yum -y update
sudo yum install -y wget

# Setup password-less SSH
ssh-keygen
sudo sh -c "cat /home/centos/.ssh/id_rsa.pub >> /home/centos/.ssh/authorized_keys"
ssh centos@$HOSTNAME.field.hortonworks.com
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

# Enable NTP 
sudo yum install -y ntp
sudo systemctl is-enabled ntpd
sudo systemctl enable ntpd
sudo systemctl start ntpd

# Update /etc/hosts/ file
sudo sh -c "echo $HDP1_HOST $HOSTNAME $HOSTNAME.field.hortonworks.com >> /etc/hosts"
cat /etc/hosts

echo 'Printing hostname...'
sleep 3
hostname -f

# Edit the Network Configuration File
sudo sh -c "echo HOSTNAME=$HOSTNAME.field.hortonworks.com >> /etc/sysconfig/network"

# Temporarily Disable Firewall
sudo systemctl disable firewalld
sudo service firewalld stop

# Download Ambari Repo and Setup Ambar Server
sudo wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.5.1.0/ambari.repo -O /etc/yum.repos.d/ambari.repo
sudo yum repolist
sudo yum install -y ambari-server
sudo echo -e "y\nn\n1\ny\nn" | sudo ambari-server setup
sudo ambari-server start

# Open up Ambari and continue with Browser-based installation
echo http://$HOSTNAME:8080

cat ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub 


# Configure Additional HDP Nodes


# Node 2

ssh -i ~/.ssh/field.pem centos@172.26.202.187

export HDP2_HOST="172.26.202.187"

ssh-keygen

sudo vi ~/.ssh/authorized_keys
# Then add .ssh/id_rsa.pub from Node 1

echo $HOSTNAME



# Node 3

ssh -i ~/.ssh/field.pem centos@172.26.202.188

export HDP3_HOST="172.26.202.188"

ssh-keygen

sudo vi ~/.ssh/authorized_keys
# Then add .ssh/id_rsa.pub from Node 1

echo $HOSTNAME



# From Node 1
# SSH into nodes 2, 3, ...

ssh centos@$HDP2_HOST

ssh centos@$HDP3_HOST

# Open up Ambari and continue with Browser-based installation
echo http://$HOSTNAME:8080

cat ~/.ssh/id_rsa

echo $HOSTNAME



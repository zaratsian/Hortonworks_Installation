
####################################################################################################################################
#
#   HDP 2.6.4 and HDF 3.1.0 Installation (w/ Ambari 2.6.1)
#
#   Docs: https://docs.hortonworks.com/HDPDocuments/Ambari-2.6.1.0/bk_ambari-installation/content/ch_Getting_Ready.html
#
#   Tested on CentOS Linux release 7.2.1511 (Core)
#
####################################################################################################################################

####################################################################################################################################
#
#   Meet Minimum System Requirements
#
#   https://docs.hortonworks.com/HDPDocuments/Ambari-2.6.1.0/bk_ambari-installation/content/meet_minimum_system_requirements.html
#
####################################################################################################################################

####################################################################################################################################
#
#   Step 1: Install Ambari
#
####################################################################################################################################


cat /etc/centos-release
# CentOS Linux release 7.2.1511 (Core)


# Install Required Packages
sudo yum install -y wget


# Setup password-less SSH
ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''   # Generate a SSH keypair without being prompted for a passphrase
sudo sh -c "cat /home/centos/.ssh/id_rsa.pub >> /home/centos/.ssh/authorized_keys"
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys


# Update /etc/hosts/ file
sudo sh -c "echo $(ifconfig eth0 | grep 'inet ' | cut -d: -f2 | awk '{ print $2}') $HOSTNAME $(hostname -f) >> /etc/hosts"
cat /etc/hosts


# Enable NTP 
sudo yum install -y ntp
sudo systemctl is-enabled ntpd
sudo systemctl enable ntpd
sudo systemctl start ntpd


# Edit the Network Configuration File
sudo sh -c "echo HOSTNAME=$(hostname -f) >> /etc/sysconfig/network"


# Temporarily Disable Firewall
sudo systemctl status firewalld
sudo systemctl disable firewalld
sudo service firewalld stop


# Disable SELinux and PackageKit and check the umask Value
# This should be ok by default, but good to double-check
# https://docs.hortonworks.com/HDPDocuments/Ambari-2.6.1.0/bk_ambari-installation/content/disable_selinux_and_packagekit_and_check_the_umask_value.html


# Install MySQL
sudo yum localinstall -y https://dev.mysql.com/get/mysql57-community-release-el7-8.noarch.rpm
sudo yum install -y epel-release mysql-connector-java* mysql-community-server
sudo ambari-server setup --jdbc-db=mysql --jdbc-driver=/usr/share/java/mysql-connector-java.jar
sudo systemctl start mysqld.service
sudo systemctl status mysqld.service
grep 'A temporary password is generated for root@localhost: ' /var/log/mysqld.log |tail -1
echo 'Dummy mysql password currently used: horton.Mysql123'
sudo /usr/bin/mysql_secure_installation


mysql -u root -p
# Create Hive DB, users, and Permissions
# https://docs.hortonworks.com/HDPDocuments/Ambari-2.6.1.0/bk_ambari-administration/content/using_hive_with_mysql.html
CREATE USER 'hive'@'localhost' IDENTIFIED BY 'horton.Mysql123';
CREATE USER 'hive'@'%' IDENTIFIED BY 'horton.Mysql123';
CREATE USER 'hive'@'dzaratsian0.field.hortonworks.com' IDENTIFIED BY 'horton.Mysql123';
CREATE USER 'rangerdba'@'%' IDENTIFIED BY 'horton.Mysql123';
CREATE USER 'rangerdba'@'localhost' IDENTIFIED BY 'horton.Mysql123';
CREATE USER 'druid'@'%' IDENTIFIED BY 'horton.Mysql123';
CREATE USER 'superset'@'%' IDENTIFIED BY 'horton.Mysql123';
CREATE USER 'registry'@'%' IDENTIFIED BY 'horton.Mysql123';
CREATE USER 'streamline'@'%' IDENTIFIED BY 'horton.Mysql123';

GRANT ALL PRIVILEGES ON *.* TO 'hive'@'localhost';
GRANT ALL PRIVILEGES ON *.* TO 'hive'@'%';
GRANT ALL PRIVILEGES ON *.* TO 'hive'@'dzaratsian0.field.hortonworks.com';
GRANT ALL PRIVILEGES ON *.* TO 'rangerdba'@'localhost';
GRANT ALL PRIVILEGES ON *.* TO 'rangerdba'@'%';
GRANT ALL PRIVILEGES ON *.* TO 'rangerdba'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'rangerdba'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'druid'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'superset'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON registry.* TO 'registry'@'%' WITH GRANT OPTION ;
GRANT ALL PRIVILEGES ON streamline.* TO 'streamline'@'%' WITH GRANT OPTION ;

FLUSH PRIVILEGES;
CREATE DATABASE hive;
CREATE DATABASE druid DEFAULT CHARACTER SET utf8;
CREATE DATABASE superset DEFAULT CHARACTER SET utf8;
CREATE DATABASE registry;
CREATE DATABASE streamline;

COMMIT;
quit;


# Download the Ambari Repository
sudo wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.6.1.0/ambari.repo -O /etc/yum.repos.d/ambari.repo
sudo yum repolist
sudo yum install -y ambari-server
sudo echo -e "y\nn\n1\ny\ny\nn\n" | sudo ambari-server setup
sudo ambari-server start
# ambari-server start --skip-database-check
sudo ambari-server status


# To use MySQL with Hive, you must download the MySQL Connector/J JDBC Driver from MySQL
sudo ambari-server setup --jdbc-db=mysql --jdbc-driver=/usr/share/java/mysql-connector-java.jar


# Open up Ambari and continue with Browser-based installation
echo http://$HOSTNAME.field.hortonworks.com:8080


# Print SSH private key (used within Ambari during setup)
cat ~/.ssh/id_rsa


# Print SSH public key on master host
cat ~/.ssh/id_rsa.pub


# Save public key to local drive (in order to scp to other hosts), then copy to all other hosts in the cluster
cp ~/.ssh/id_rsa.pub /tmp/.
echo "[ INFO ] Exiting from the host machine in 5 seconds. The next step will copy the Ambari Host public key into all other hosts at ~/.ssh/authorized_keys"

sleep 5
exit

# Save public key to local drive (in order to scp to other hosts)
scp -i ~/.ssh/field.pem centos@dzaratsian0.field.hortonworks.com:/tmp/id_rsa.pub /tmp/.
# Copy the Ambari Host public key into this machine's ~/.ssh/authorized_key file
cat /tmp/id_rsa.pub | ssh centos@dzaratsian1.field.hortonworks.com 'cat >> ~/.ssh/authorized_keys'
cat /tmp/id_rsa.pub | ssh centos@dzaratsian2.field.hortonworks.com 'cat >> ~/.ssh/authorized_keys'
cat /tmp/id_rsa.pub | ssh centos@dzaratsian3.field.hortonworks.com 'cat >> ~/.ssh/authorized_keys'
cat /tmp/id_rsa.pub | ssh centos@dzaratsian4.field.hortonworks.com 'cat >> ~/.ssh/authorized_keys'
cat /tmp/id_rsa.pub | ssh centos@dzaratsian5.field.hortonworks.com 'cat >> ~/.ssh/authorized_keys'
cat /tmp/id_rsa.pub | ssh centos@dzaratsian6.field.hortonworks.com 'cat >> ~/.ssh/authorized_keys'





#################################################################################################################
#
#   STEP 2: Installing HDP (Run on all hosts except for Ambari Host)
#
#   https://docs.hortonworks.com/HDPDocuments/HDF3/HDF-3.1.0/bk_installing-hdf-on-hdp/content/ch_install-mpack.html
#
#################################################################################################################

# Display Release
cat /etc/centos-release

# Update Centos
#sudo yum -y update

# Install WGET
sudo yum install -y wget

# Setup password-less SSH
ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''   # Generate a SSH keypair without being prompted for a passphrase
sudo sh -c "cat /home/centos/.ssh/id_rsa.pub >> /home/centos/.ssh/authorized_keys"
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

# Update /etc/hosts/ file
sudo sh -c "echo $(ifconfig eth0 | grep 'inet ' | cut -d: -f2 | awk '{ print $2}') $HOSTNAME $(hostname -f) >> /etc/hosts"
cat /etc/hosts

# Edit the Network Configuration File
sudo sh -c "echo HOSTNAME=$(hostname -f) >> /etc/sysconfig/network"

# Enable NTP 
sudo yum install -y ntp
sudo systemctl is-enabled ntpd
sudo systemctl enable ntpd
sudo systemctl start ntpd

# Temporarily Disable Firewall
sudo systemctl is-enabled firewalld
sudo systemctl disable firewalld
sudo systemctl is-enabled firewalld
sudo service firewalld stop





####################################################################################################################################
#
#   Install HDF 3.1.0 on already installed HDP 2.6.4 Cluster
#
####################################################################################################################################

# https://docs.hortonworks.com/HDPDocuments/HDF3/HDF-3.1.0/bk_release-notes/content/ch_hdf_relnotes.html#repo-location
sudo wget http://public-repo-1.hortonworks.com/HDF/centos7/3.x/updates/3.1.0.0/tars/hdf_ambari_mp/hdf-ambari-mpack-3.1.0.0-564.tar.gz -O /tmp/hdf-ambari-mpack-3.1.0.0-564.tar.gz

sudo ambari-server install-mpack --mpack=/tmp/hdf-ambari-mpack-3.1.0.0-564.tar.gz --verbose

sudo ambari-server restart





#ZEND

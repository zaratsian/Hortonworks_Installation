
#################################################################################################################
#
#   Hortonworks HDP and HDF
#
#   Installation & Config
#
#################################################################################################################

# Display Release
cat /etc/centos-release

# Update Centos
#sudo yum -y update
sudo yum install -y wget

# Setup password-less SSH
ssh-keygen
sudo sh -c "cat /home/centos/.ssh/id_rsa.pub >> /home/centos/.ssh/authorized_keys"
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
cat ~/.ssh/id_rsa.pub

# Update /etc/hosts/ file
sudo sh -c "echo $(ifconfig eth0 | grep 'inet ' | cut -d: -f2 | awk '{ print $2}') $HOSTNAME $(hostname -f) >> /etc/hosts"
cat /etc/hosts

# Edit the Network Configuration File
#sudo sh -c "echo HOSTNAME=$(hostname -f) >> /etc/sysconfig/network"

# Run on all other hosts
sudo vi ~/.ssh/authorized_keys

# SSH into hosts from primary server
ssh dzaratsian1.field.hortonworks.com
ssh dzaratsian2.field.hortonworks.com
ssh dzaratsian3.field.hortonworks.com
ssh dzaratsian4.field.hortonworks.com

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

# Download Ambari Repo and Setup Ambar Server
sudo wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.5.1.0/ambari.repo -O /etc/yum.repos.d/ambari.repo
#sudo wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.6.0.0/ambari.repo -O /etc/yum.repos.d/ambari.repo
sudo yum repolist
sudo yum install -y ambari-server
sudo echo -e "y\nn\n1\ny\nn" | sudo ambari-server setup
#sudo ambari-server start

# Install HDF Management Pack
sudo ambari-server stop
wget http://public-repo-1.hortonworks.com/HDF/centos7/3.x/updates/3.0.0.0/tars/hdf_ambari_mp/hdf-ambari-mpack-3.0.0.0-453.tar.gz -O /tmp/hdf-ambari-mpack-3.0.0.0-453.tar.gz
sudo ambari-server install-mpack --mpack=/tmp/hdf-ambari-mpack-3.0.0.0-453.tar.gz --verbose
#wget http://public-repo-1.hortonworks.com/HDF/centos7/3.x/updates/3.0.1.1/tars/hdf_ambari_mp/hdf-ambari-mpack-3.0.1.1-5.tar.gz -O /tmp/hdf-ambari-mpack-3.0.1.1-5.tar.gz
#sudo ambari-server install-mpack --mpack=/tmp/hdf-ambari-mpack-3.0.1.1-5.tar.gz --verbose
#sudo ambari-server start

# Start Ambari
sudo ambari-server start

# Setup MySQL Database and Users 
sudo yum install -y mysql-connector-java*
sudo ambari-server setup --jdbc-db=mysql --jdbc-driver=/usr/share/java/mysql-connector-java.jar
sudo yum -y localinstall https://dev.mysql.com/get/mysql57-community-release-el7-8.noarch.rpm
sudo yum install -y mysql-community-server
sudo systemctl start mysqld.service
# This command should output a temporary password.
grep 'A temporary password is generated for root@localhost' /var/log/mysqld.log |tail -1
# Enter the password, generated in the previous step.
sudo /usr/bin/mysql_secure_installation

# Login to MySQL
# Enter the new MySQL password that was created in the previous step.
mysql -u root -p

# Setup MySQL Databases, Users, and Privileges
# https://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.6.2/bk_security/content/configuring_mysql_for_ranger.html

CREATE DATABASE druid DEFAULT CHARACTER SET utf8;
CREATE DATABASE superset DEFAULT CHARACTER SET utf8;
create DATABASE registry;
create DATABASE streamline;

CREATE USER 'rangerdba'@'%' IDENTIFIED BY 'horton.Mysql123';
CREATE USER 'rangerdba'@'localhost' IDENTIFIED BY 'horton.Mysql123';
CREATE USER 'druid'@'%' IDENTIFIED BY 'horton.Mysql123';
CREATE USER 'superset'@'%' IDENTIFIED BY 'horton.Mysql123';
CREATE USER 'registry'@'%' IDENTIFIED BY 'horton.Mysql123';
CREATE USER 'streamline'@'%' IDENTIFIED BY 'horton.Mysql123';

GRANT ALL PRIVILEGES ON *.* TO 'rangerdba'@'localhost';
GRANT ALL PRIVILEGES ON *.* TO 'rangerdba'@'%';
GRANT ALL PRIVILEGES ON *.* TO 'rangerdba'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'rangerdba'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'druid'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'superset'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON registry.* TO 'registry'@'%' WITH GRANT OPTION ;
GRANT ALL PRIVILEGES ON streamline.* TO 'streamline'@'%' WITH GRANT OPTION ;

FLUSH PRIVILEGES;

COMMIT;

exit

# Open up Ambari and continue with Browser-based installation
echo http://$HOSTNAME.field.hortonworks.com:8080

cat ~/.ssh/id_rsa

#ZEND

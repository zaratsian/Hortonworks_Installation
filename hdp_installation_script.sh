
#################################################################################################################
#
#   Hortonworks HDP (HDP 2.6)
#
#   Installation & Config
#
#   Installation: https://docs.hortonworks.com/HDPDocuments/Ambari-2.5.1.0/bk_ambari-installation/content/ch_Getting_Ready.html
#   Ambari Repos: https://docs.hortonworks.com/HDPDocuments/Ambari-2.5.1.0/bk_ambari-installation/content/ambari_repositories.html
#   HDP Repos:    https://docs.hortonworks.com/HDPDocuments/Ambari-2.5.1.0/bk_ambari-installation/content/hdp_26_repositories.html
#   HDF Repos:    https://docs.hortonworks.com/HDPDocuments/HDF3/HDF-3.0.0/bk_release-notes/content/ch_hdf_relnotes.html   
#
#   Test on: CentOS Linux release 7.2.1511 (Core) 
#
#################################################################################################################


ssh -i ~/.ssh/field.pem centos@172.26.202.186


# Update Centos
sudo yum -y update
sudo yum install -y wget

# Setup password-less SSH
ssh-keygen
sudo sh -c "cat /home/centos/.ssh/id_rsa.pub >> /home/centos/.ssh/authorized_keys"
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
cat ~/.ssh/id_rsa.pub

# Run on all other hosts
sudo vi ~/.ssh/authorized_keys
echo ssh $(whoami)@$(hostname -f)

# Enable NTP 
sudo yum install -y ntp
sudo systemctl is-enabled ntpd
sudo systemctl enable ntpd
sudo systemctl start ntpd

# Update /etc/hosts/ file
sudo sh -c "echo $(ifconfig eth0 | grep 'inet ' | cut -d: -f2 | awk '{ print $2}') $HOSTNAME $(hostname -f) >> /etc/hosts"
cat /etc/hosts

# Edit the Network Configuration File
#sudo sh -c "echo HOSTNAME=$(hostname -f) >> /etc/sysconfig/network"

# Temporarily Disable Firewall
sudo systemctl disable firewalld
sudo service firewalld stop

# Download Ambari Repo and Setup Ambar Server
sudo wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.5.1.0/ambari.repo -O /etc/yum.repos.d/ambari.repo
sudo yum repolist
sudo yum install -y ambari-server
sudo echo -e "y\nn\n1\ny\nn" | sudo ambari-server setup
sudo ambari-server start

# Setup MySQL Database and Users 
# For Ranger, Druid and Superset
sudo yum install -y mysql-connector-java*
sudo ambari-server setup --jdbc-db=mysql --jdbc-driver=/usr/share/java/mysql-connector-java.jar
sudo yum -y localinstall https://dev.mysql.com/get/mysql57-community-release-el7-8.noarch.rpm
sudo yum install -y mysql-community-server
sudo systemctl start mysqld.service
grep 'A temporary password is generated for root@localhost' /var/log/mysqld.log |tail -1   # This command should output a temporary password.
sudo /usr/bin/mysql_secure_installation  # Enter the password, generated in the previous step.


# Login to MySQL
mysql -u root -p  # Enter the new MySQL password that was created in the previous step.

# Setup MySQL DB for Ranger
# https://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.6.2/bk_security/content/configuring_mysql_for_ranger.html
CREATE USER 'rangerdba'@'localhost' IDENTIFIED BY 'rangerdba';
GRANT ALL PRIVILEGES ON *.* TO 'rangerdba'@'localhost';
CREATE USER 'rangerdba'@'%' IDENTIFIED BY 'rangerdba';
GRANT ALL PRIVILEGES ON *.* TO 'rangerdba'@'%';
GRANT ALL PRIVILEGES ON *.* TO 'rangerdba'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'rangerdba'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;


# Setup MySQL DB for Druid and Superset
CREATE DATABASE druid DEFAULT CHARACTER SET utf8;
CREATE DATABASE superset DEFAULT CHARACTER SET utf8;

echo "Change the MySQL password IDENTIFIED BY, show in the next two lines"
sleep 15

CREATE USER 'druid'@'%' IDENTIFIED BY 'xxx';
CREATE USER 'superset'@'%' IDENTIFIED BY 'xxx';

GRANT ALL PRIVILEGES ON *.* TO 'druid'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'superset'@'%' WITH GRANT OPTION;

commit;

exit

# Open up Ambari and continue with Browser-based installation
echo http://$HOSTNAME:8080

cat ~/.ssh/id_rsa
#cat ~/.ssh/id_rsa.pub 

#ZEND


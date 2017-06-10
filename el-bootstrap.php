<?php
header("Content-Type: text/plain");
header('Content-Disposition: attachment; filename="el-bootstrap.sh"');
header("Connection: close");
?>
#!/bin/bash

### OS detection ###
if [ -f /etc/redhat-release ]
then
 echo "The detected OS is: `cat /etc/redhat-release`"
else
 echo "This script is only supported on RHEL and CentOS." ; exit 1
fi

### Pre-existing installation detection ###
if [ -f /etc/puppet/puppet.conf ] || [ -f /etc/puppetlabs/puppet/puppet.conf ]
then
 echo "Puppet already installed." ; exit 1
else
 echo "Installing Puppet..."
fi

### Install the Puppet yum repo ###
rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-`cat /etc/redhat-release | grep -oE '[0-9]+\.[0-9]+' | cut -c1`.noarch.rpm

[ $? != 0 ] && echo "A problem has occured adding the Puppet repo." && exit 1

### Install Puppet ###
yum -y install puppet
[ $? != 0 ] && echo "A problem has occured installing the Puppet agent." && exit 1

### Configure Puppet Agent if server and environment are not already set ###
TIMESTAMP=`date +%Y%m%d`

grep -q '\[main\]' /etc/puppetlabs/puppet/puppet.conf || echo '[main]' >> /etc/puppetlabs/puppet/puppet.conf
grep -q '\[agent\]' /etc/puppetlabs/puppet/puppet.conf || echo '[agent]' >> /etc/puppetlabs/puppet/puppet.conf

<?php
echo 'grep -q \'server=\' /etc/puppetlabs/puppet/puppet.conf || sed -i_\"${TIMESTAMP}\"-1.bak \'/\\[agent\\]/i server=' . $_GET["master"] . "\' /etc/puppetlabs/puppet/puppet.conf\n";
echo 'grep -q \'environment=\' /etc/puppetlabs/puppet/puppet.conf || sed -i_\"${TIMESTAMP}\"-2.bak \'/\\[agent\\]/i environment=' . $_GET["environment"] . "\' /etc/puppetlabs/puppet/puppet.conf";
?>

### Initial Puppet checkin ###
puppet agent -t --waitforcert=10 | tee /var/log/el-bootstrap.log

### Enable Puppet service ###
service puppet start
[ $? != 0 ] && echo "A problem has occured starting the Puppet agent." && exit 1
chkconfig puppet on
[ $? != 0 ] && echo "A problem has occured enabling the Puppet agent on boot." && exit 1

### Done ###
echo "Puppet install finished."

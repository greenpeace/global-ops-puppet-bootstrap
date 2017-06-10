#!/bin/bash

### OS detection ###
if [ -f /etc/redhat-release ]
then
 echo "The detected OS is: `cat /etc/redhat-release`"
else
 echo "This script is only supported on Enterprise Linux 6 and 7 (RHEL, CentOS, and deritives)." ; exit 1
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
yum -y install puppet-agent
[ $? != 0 ] && echo "A problem has occured installing the Puppet agent." && exit 1

### Configure Puppet Agent if server and environment are not already set ###
TIMESTAMP=`date +%Y%m%d`
PUPPET_SERVER=`curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/puppet_master" -H "Metadata-Flavor: Google"`
PUPPET_ENVIRONMENT=`curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/puppet_environment" -H "Metadata-Flavor: Google"`

grep -q '\[main\]' /etc/puppetlabs/puppet/puppet.conf || echo '[main]' >> /etc/puppetlabs/puppet/puppet.conf
grep -q '\[agent\]' /etc/puppetlabs/puppet/puppet.conf || echo '[agent]' >> /etc/puppetlabs/puppet/puppet.conf

grep -q 'server=' /etc/puppetlabs/puppet/puppet.conf || sed -i_"${TIMESTAMP}"-1.bak "/\[agent\]/i server=$PUPPET_SERVER" /etc/puppetlabs/puppet/puppet.conf
grep -q 'environment=' /etc/puppetlabs/puppet/puppet.conf || sed -i_"${TIMESTAMP}"-2.bak "/\[agent\]/i environment=$PUPPET_ENVIRONMENT" /etc/puppetlabs/puppet/puppet.conf

### Initial Puppet checkin ###
/opt/puppetlabs/bin/puppet agent -t --waitforcert=10 | tee /var/log/puppet-bootstrap.log

### Enable Puppet service ###
/opt/puppetlabs/bin/puppet resource service puppet ensure=running --environment production
[ $? != 0 ] && echo "A problem has occured starting the Puppet agent." && exit 1
/opt/puppetlabs/bin/puppet resource service puppet enable=true --environment production
[ $? != 0 ] && echo "A problem has occured enabling the Puppet agent on boot." && exit 1

### Done ###
echo "Puppet install finished."

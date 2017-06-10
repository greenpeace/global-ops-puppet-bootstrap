# Puppet 4 Bootstrap Scripts

This repository contains scripts for setting
up [Puppet](https://puppet.com/product/how-puppet-works) 4 on a variety
of machines.

Puppet is fantastic for managing infrastructure but there is a chicken/egg problem
of getting Puppet initially installed on a machine so that Puppet can then
take over for the remainder of system setup. This repository contains small scripts
to bootstrap systems just enough so that Puppet can then take over.

## About the Scripts

There are two methods for using these scripts. The scripts with "gce" appended are specifically for bootstrapping Google Compute Engine (GCE) machines. You must set [metadata](https://cloud.google.com/compute/docs/storing-retrieving-metadata) variables for `puppet_master` and `puppet_environment` on your GCE machine prior to using this script. These variables will automatically be passed to the [puppet.conf](https://docs.puppet.com/puppet/latest/config_file_main.html) file as part of the bootstrapping process.

The second method will work outside of GCE environments and is based on PHP. It uses URL variables rather than GCE metadata variables for automatic configuration of `puppet.conf`. The URL variables `master` and `environment` must be defined.

## Using a Script

To use one of the scripts in this repository, you can either download the
script directly from this repository as part of your machine setup process,
or copy the contents of the script you need to your own location and use that.
The latter is recommended since it then doesn't rely on GitHub uptime and
is generally more secure. The PHP based scripts must be hosted on a web server which supports mod_php, FastCGI, PHP-FPM or similar PHP integrations.

If you do choose to download directly from this repository, make sure
you link to a _specific commit_ (and not `master`), so that the file
contents don't change on you unexpectedly.

## Bootstrapping a Machine

You can use [curl](https://linux.die.net/man/1/curl), which exists in most linux distributions by default, to pipe the script into a shell for execution. This must be run as the root user or via [sudo](https://linux.die.net/man/8/sudo). For example:

`curl -s https://www.example.com/bootstrap-gce | bash`

or

`curl -s "https://www.example.com/bootstrap.php?master=puppet.example.com&environment=production" | bash`

In the case of GCE, you can use metadata to define a [startup-script](https://cloud.google.com/compute/docs/startupscript) and place the curl statement there.

## Attribution

Some of the work provided here is a derivative of scripts originally written by [Hashicorp](https://github.com/hashicorp/puppet-bootstrap).

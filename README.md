#puppet-capistrano

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with [Modulename]](#setup)
    * [What [Modulename] affects](#what-[modulename]-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with [Modulename]](#beginning-with-[Modulename])
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

##Overview

auto deploy and setup for capistrano (http://capistranorb.com).

Setup and use on Ubuntu 14.04LTS and puppet 3.7.1.

##Module Description

This module is in two parts, a primary server installation and node. It will auto detect your hosts for capistrano and let you deploy your code to them. Right now only tested/working with git. You can get it to deploy ssh keys for git as well.

It supports production and staging environments from capistrano.

##Setup

###What [puppet-capistrano] affects

* It should not touch anything import on your system but add some fodlers and directories to capistrano can work.

###Setup Requirements 

* puppetlabs-stdlib
* puppetlabs-ruby
* example42-git
* example42-puppi
* .....
	
###Beginning with [puppet-capistrano]	

The very basic steps needed for a user to get the module up and running. 

If your most recent release breaks compatibility or requires particular steps for upgrading, you may wish to include an additional section here: Upgrading (For an example, see http://forge.puppetlabs.com/puppetlabs/firewall).

##Usage
On a primary or 'main' server you will have:
```
  capistrano::cap { 'foo_repo':
    repo_address   => 'github.com',        #we assume the GIT url is git@hostname:$name.git
    app_path       => '/opt/puppet',       #where you want to deploy to
    git_keys       => true,
    ssh_key_source => 'puppet:///modules/applicatoin',   
  }
```

On any nodes you need to 'deploy to':
```
  capistrano::node { 'foo_repo':
    environments   => [ 'production', 'staging' ],    #capistrano stages
    app_path       => '/opt/puppet',
    ssh_key_source => 'puppet:///modules/applicatoin',   
  }
```

I assume a lot as it is a work in progress. You should be able to feed it keys as a file source definition and it will use those keys with github. Once deploy you will have

```
cd /deploy/foo_repo
cap production deploy
```

##Reference

Here, list the classes, types, providers, facts, etc contained in your module. This section should include all of the under-the-hood workings of your module so people know what the module is touching on their system but don't need to mess with things. (We are working on automating this section!)

##Limitations

This is where you list OS compatibility, version compatibility, etc.

##Development

Since your module is awesome, other users will want to play with it. Let them know what the ground rules for contributing are.

##Release Notes/Contributors/Etc **Optional**

If you aren't using changelog, put your release notes here (though you should consider using changelog). You may also add any additional sections you feel are necessary or important to include here. Please use the `## ` header. 

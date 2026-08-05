# metadata.rb - Cookbook Metadata
#
# Intent: Declare metadata, versions, and OS support for the wes_baseline cookbook.
# Role: Used by Chef Server and dependency managers (like Berkshelf or Policyfiles) to resolve dependencies.
# Dependencies: None.

name             'wes_baseline'
maintainer       'Jonathan Nguyen'
maintainer_email 'jonathan@jdnguyen.tech'
license          'All Rights Reserved'
description      'Installs and configures baseline security and packages for Westminster nodes'
version          '0.2.0'
chef_version     '>= 16.0'

supports 'ubuntu', '>= 20.04'
supports 'windows', '>= 10.0'

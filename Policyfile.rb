# Policyfile.rb - Defines how Chef configures the nodes
#
# Intent: Lock down the cookbook dependencies and run-list for the Westminster environment.
# Role: Used by Chef Workstation to compile dependencies and push locked configurations to Chef Server.
# Dependencies: Chef Infra Client 16+ or Chef Workstation.
# Usage:
#   1. From the chef/ directory, run: `chef install` (compiles and locks versions).
#   2. Push to Chef Server: `chef push dev Policyfile.lock.json`

name 'wes_baseline'

# In a production environment, this would point to your local private Supermarket or Artifactory.
# For local development, we search the local cookbooks directory first.
default_source :supermarket
default_source :chef_repo, 'cookbooks'

# The run-list defines the order in which recipes are executed on the node
run_list 'wes_baseline::default', 'wes_baseline::patching', 'wes_baseline::inventory'

# Specify the local cookbook we are developing
cookbook 'wes_baseline', path: 'cookbooks/wes_baseline'

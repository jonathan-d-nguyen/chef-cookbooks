# test/integration/patching/controls/patching_test.rb
#
# InSpec verification profile for wes_baseline::patching.
# Verifies the unattended-upgrades toolchain is installed, configured,
# and the service is running. apply_updates is false in this Kitchen suite
# so no packages are actively installed during the test run.

# ------------------------------------------------------------------------------
# Control 1: Patch toolchain packages
# Maps to: recipes/patching.rb — package %w(unattended-upgrades apt-listchanges)
# ------------------------------------------------------------------------------
control 'patching-packages' do
  impact 1.0
  title 'Unattended-upgrades toolchain is installed'
  desc  'Both unattended-upgrades and apt-listchanges must be present.'

  only_if { os.family == 'debian' }

  %w(unattended-upgrades apt-listchanges).each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end
end

# ------------------------------------------------------------------------------
# Control 2: Upgrade policy config file
# Maps to: recipes/patching.rb — template '/etc/apt/apt.conf.d/50unattended-upgrades'
# ------------------------------------------------------------------------------
control 'patching-upgrade-config' do
  impact 1.0
  title 'Unattended-upgrades policy file is Chef-managed'
  desc  '50unattended-upgrades must exist, be root-owned, and restrict origins to security.'

  only_if { os.family == 'debian' }

  describe file('/etc/apt/apt.conf.d/50unattended-upgrades') do
    it           { should exist }
    its('owner') { should eq 'root' }
    its('mode')  { should cmp '0644' }
    its('content') { should match(/distro_codename.*-security/) }
  end
end

# ------------------------------------------------------------------------------
# Control 3: APT periodic timer config
# Maps to: recipes/patching.rb — file '/etc/apt/apt.conf.d/20auto-upgrades'
# ------------------------------------------------------------------------------
control 'patching-auto-upgrades' do
  impact 1.0
  title 'APT periodic timers are enabled via 20auto-upgrades'
  desc  'Daily download and unattended-upgrade must be scheduled.'

  only_if { os.family == 'debian' }

  describe file('/etc/apt/apt.conf.d/20auto-upgrades') do
    it           { should exist }
    its('owner') { should eq 'root' }
    its('content') { should match(/Unattended-Upgrade "1"/) }
    its('content') { should match(/Managed by Chef/) }
  end
end

# ------------------------------------------------------------------------------
# Control 4: Unattended-upgrades service
# Maps to: recipes/patching.rb — service 'unattended-upgrades'
# ------------------------------------------------------------------------------
control 'patching-service' do
  impact 0.7
  title 'Unattended-upgrades service is enabled and running'

  only_if { os.family == 'debian' }

  describe service('unattended-upgrades') do
    it { should be_enabled }
    it { should be_running }
  end
end

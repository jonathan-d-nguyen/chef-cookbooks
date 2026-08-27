# test/integration/default/controls/baseline_test.rb
#
# InSpec verification profile for wes_baseline::default.
# Runs after chef-client converges inside the Test Kitchen container.
# Each control maps directly to a recipe resource block.

# ------------------------------------------------------------------------------
# Control 1: Base packages
# Maps to: recipes/default.rb — package loop for git and curl
# ------------------------------------------------------------------------------
control 'baseline-packages' do
  impact 1.0
  title 'Base packages are installed'
  desc  'git and curl must be present on all managed nodes.'

  %w(git curl).each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end
end

# ------------------------------------------------------------------------------
# Control 2: SSH daemon (Debian/Ubuntu only)
# Maps to: recipes/default.rb — service 'ssh' block
# ------------------------------------------------------------------------------
control 'baseline-ssh' do
  impact 1.0
  title 'SSH daemon is enabled and running'
  desc  'OpenSSH must be active so nodes remain remotely manageable.'

  only_if { os.family == 'debian' }

  describe service('ssh') do
    it { should be_enabled }
    it { should be_running }
  end
end

# ------------------------------------------------------------------------------
# Control 3: Security banner (MOTD)
# Maps to: recipes/default.rb — file '/etc/motd' block
# ------------------------------------------------------------------------------
control 'baseline-motd' do
  impact 0.7
  title 'Security warning banner is present in /etc/motd'
  desc  'Legal notice must warn that the system is managed by Chef and access is restricted.'

  only_if { os.family == 'debian' }

  describe file('/etc/motd') do
    it     { should exist }
    it     { should be_file }
    its('owner') { should eq 'root' }
    its('mode')  { should cmp '0644' }
    its('content') do
      should match(/Authorized Westminster Home Lab Systems Access Only/)
    end
    its('content') do
      should match(/managed by Chef Automation/)
    end
  end
end

# recipes/default.rb - Westminster Baseline Config
#
# Intent: Apply cross-platform packages, services, and warning banners to hybrid Windows/Linux nodes.
# Role: Evaluated and executed by chef-client on target nodes during convergence.
# Dependencies: Chef Client.
# Usage: Included in node run-list via `recipe[wes_baseline::default]`.

# ==============================================================================
# 1. Base Package Auditing (Cross-Platform)
# ==============================================================================
# Chef's generic 'package' resource automatically detects the platform and utilizes
# apt, yum, dnf, chocolatey, or MSI packages under the hood.
%w(git curl).each do |pkg|
  package pkg do
    action :install
  end
end

# ==============================================================================
# 2. Remote Access Configuration & Enforcement
# ==============================================================================
if platform_family?('debian')
  # Ensure SSH daemon is running and enabled on Ubuntu Server (e.g. wesmt-pc01)
  service 'ssh' do
    action [:enable, :start]
  end

elsif platform_family?('windows')
  # Ensure Windows Remote Management (WinRM) is running and configured for admin
  service 'WinRM' do
    action [:enable, :start]
  end
end

# ==============================================================================
# 3. Security Legal Warning / System Banners
# ==============================================================================
# Shows how we manage config files on Linux vs. Security Policies/Registry on Windows
if platform_family?('debian')
  file '/etc/motd' do
    content <<~MOTD
      ==========================================================================
      WARNING: Authorized Westminster Home Lab Systems Access Only.
      Host FQDN: #{node['fqdn'] || node['hostname']}.wes.home.jdnguyen.tech
      This system is managed by Chef Automation. Configuration drift will be reverted.
      ==========================================================================
    MOTD
    owner 'root'
    group 'root'
    mode '0644'
  end

elsif platform_family?('windows')
  # Set Legal Notice Caption and Text on Windows Login Screen using Registry Keys
  registry_key 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' do
    values [
      { name: 'legalnoticecaption', type: :string, data: 'Authorized Westminster Access Only' },
      { name: 'legalnoticetext', type: :string, data: "This workstation is managed by Chef Automation. All actions are logged. FQDN: #{node['hostname']}.wes.home.jdnguyen.tech" },
    ]
    action :create
  end
end

# ==============================================================================
# 4. Hostname Convention Warning Log
# ==============================================================================
# Demonstrates parsing the node's hostname to verify standard format compliance:
# e.g., 'wesmt-pc01' -> site: wes, bld: m, zone: t, func: pc, index: 01
hostname = node['hostname']
match = hostname.match(/^([a-z]{3})([a-z])([a-z])-([a-z]{2,4})(\d{2})$/)

if match
  site, _, zone, func, index = match.captures
  Chef::Log.info("Chef parsed hostname: Site=#{site}, Zone=#{zone}, Role=#{func}#{index}")

  # Example of dynamic rule allocation based on parsed zone:
  if zone == 'm' # Management Zone
    Chef::Log.warn("Enforcing STRICT Security controls for Management zone Node: #{hostname}")
  end
else
  Chef::Log.warn("WARNING: Hostname '#{hostname}' does not match the Unified Hostname Standard (e.g. wesmt-pc01)!")
end

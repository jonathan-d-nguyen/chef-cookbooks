# recipes/inventory.rb - Westminster Node Inventory & Baseline Snapshot
#
# Intent: Capture the current state of a node by reading Ohai-collected attributes
#         and writing a structured JSON report to disk. This creates an auditable
#         baseline record showing OS, network, CPU, and memory at the time of
#         each chef-client convergence.
# Role: Evaluated by chef-client on target nodes. Ohai runs automatically before
#       any recipe executes, populating all node[] attributes used here.
# Dependencies: Chef Client 16+. No external cookbooks required.
# Usage:
#   sudo chef-client -z -o wes_baseline::inventory
#   Report written to: /var/log/chef/node-inventory.json (Linux)
#                      C:\ProgramData\Chef\node-inventory.json (Windows)

# ==============================================================================
# 1. Resolve platform-specific output path
# ==============================================================================
report_dir  = platform_family?('windows') ? 'C:\ProgramData\Chef' : '/var/log/chef'
report_path = platform_family?('windows') \
  ? "#{report_dir}\\node-inventory.json" \
  : "#{report_dir}/node-inventory.json"

# ==============================================================================
# 2. Ensure the report directory exists
# ==============================================================================
directory report_dir do
  recursive true
  action :create
  # On Linux, restrict read to root — the report may contain sensitive network info.
  unless platform_family?('windows')
    owner 'root'
    group 'root'
    mode  '0750'
  end
end

# ==============================================================================
# 3. Build the inventory hash from Ohai node attributes
#    Ohai runs at the START of every chef-client run; all data below is already
#    collected and available as node[] before any recipe code executes.
# ==============================================================================
inventory = {
  'captured_at'      => Time.now.utc.iso8601,
  'managed_by'       => 'Chef Infra (wes_baseline::inventory)',
  'identity' => {
    'hostname'         => node['hostname'],
    'fqdn'             => node['fqdn'],
    'domain'           => node['domain'],
  },
  'platform' => {
    'os'               => node['os'],
    'family'           => node['platform_family'],
    'platform'         => node['platform'],
    'version'          => node['platform_version'],
    'kernel'           => node['kernel']['release'],
    'architecture'     => node['kernel']['machine'],
  },
  'network' => {
    'ipaddress'        => node['ipaddress'],
    'macaddress'       => node['macaddress'],
    'default_gateway'  => node['network']['default_gateway'],
    'default_interface'=> node['network']['default_interface'],
  },
  'hardware' => {
    'cpu_count'        => node['cpu']['total'],
    'cpu_model'        => node.dig('cpu', '0', 'model_name') || node.dig('cpu', '0', 'brand_string'),
    'memory_total_kb'  => node['memory']['total'],
  },
  'chef' => {
    'chef_version'     => node['chef_packages']['chef']['version'],
    'policy_name'      => node['policy_name'],
    'policy_group'     => node['policy_group'],
    'run_list'         => node.run_list.map(&:to_s),
  },
}

# ==============================================================================
# 4. Write the JSON report (idempotent — only updates on content change)
# ==============================================================================
file report_path do
  content JSON.pretty_generate(inventory)
  unless platform_family?('windows')
    owner 'root'
    group 'root'
    mode  '0640'
  end
  action :create
end

# ==============================================================================
# 5. Log a summary to the Chef run output for quick visibility
# ==============================================================================
log 'inventory-summary' do
  message <<~MSG
    [wes_baseline::inventory] Baseline snapshot written to #{report_path}
      Host    : #{node['hostname']} (#{node['ipaddress']})
      Platform: #{node['platform']} #{node['platform_version']} (#{node['platform_family']})
      CPUs    : #{node['cpu']['total']}  |  Memory: #{node['memory']['total']}
      Kernel  : #{node['kernel']['release']}
  MSG
  level :info
end

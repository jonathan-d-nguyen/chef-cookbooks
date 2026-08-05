# recipes/patching.rb - Westminster OS Patch Enforcement
#
# Intent: Enforce a consistent, auditable OS patching posture across the hybrid fleet:
#         unattended security upgrades on Debian/Ubuntu, Windows Update AU policy on
#         Windows. Configuration is always enforced (drift-corrected); active
#         installation is gated behind node['wes_baseline']['patching']['apply_updates']
#         so routine convergence stays non-disruptive.
# Role: Evaluated by chef-client on target nodes. Add to a run-list via
#       recipe[wes_baseline::patching] or include_recipe from another recipe.
# Dependencies: Chef Client 16+. Debian path installs the 'unattended-upgrades' package.
# Usage: sudo chef-client -z -o wes_baseline::patching
#        Maintenance window (actually install): set apply_updates=true, then converge.

patching = node['wes_baseline']['patching']

if platform_family?('debian')
  # ----------------------------------------------------------------------------
  # 1. Ensure the unattended-upgrades toolchain is present.
  # ----------------------------------------------------------------------------
  package %w(unattended-upgrades apt-listchanges) do
    action :install
  end

  if patching['enforce_config']
    # --------------------------------------------------------------------------
    # 2. Declare *which* upgrades are allowed and reboot policy.
    #    Template is drift-corrected: manual edits revert on next converge.
    # --------------------------------------------------------------------------
    template '/etc/apt/apt.conf.d/50unattended-upgrades' do
      source 'unattended-upgrades.erb'
      owner 'root'
      group 'root'
      mode '0644'
      variables(
        allowed_origins: patching['debian']['allowed_origins'],
        auto_reboot: patching['debian']['auto_reboot'],
        auto_reboot_time: patching['debian']['auto_reboot_time']
      )
    end

    # --------------------------------------------------------------------------
    # 3. Turn the periodic apt timers on (download + unattended-upgrade daily).
    # --------------------------------------------------------------------------
    file '/etc/apt/apt.conf.d/20auto-upgrades' do
      content <<~AUTO
        // Managed by Chef (wes_baseline::patching). Do not edit by hand.
        APT::Periodic::Update-Package-Lists "1";
        APT::Periodic::Download-Upgradeable-Packages "1";
        APT::Periodic::Unattended-Upgrade "1";
        APT::Periodic::AutocleanInterval "7";
      AUTO
      owner 'root'
      group 'root'
      mode '0644'
    end

    service 'unattended-upgrades' do
      action [:enable, :start]
    end
  end

  # ----------------------------------------------------------------------------
  # 4. Optional: actively apply pending security updates during this run.
  # ----------------------------------------------------------------------------
  if patching['apply_updates']
    apt_update 'refresh package lists before patch run' do
      action :update
    end

    execute 'apply unattended-upgrades now' do
      command 'unattended-upgrade -v'
      live_stream true
    end

    log 'patch-run-debian' do
      message "wes_baseline::patching applied unattended security upgrades on #{node['hostname']}"
      level :info
    end
  else
    log 'patch-config-debian' do
      message "wes_baseline::patching enforced patch CONFIG on #{node['hostname']} (apply_updates=false; no packages installed this run)"
      level :info
    end
  end

elsif platform_family?('windows')
  au_key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'

  if patching['enforce_config']
    # --------------------------------------------------------------------------
    # 5. Enforce Windows Update Automatic Update policy via registry.
    #    NoAutoUpdate=0 keeps AU enabled; AUOptions selects behavior.
    # --------------------------------------------------------------------------
    registry_key au_key do
      recursive true
      values [
        { name: 'NoAutoUpdate',            type: :dword, data: 0 },
        { name: 'AUOptions',               type: :dword, data: patching['windows']['au_options'] },
        { name: 'ScheduledInstallDay',     type: :dword, data: patching['windows']['scheduled_install_day'] },
        { name: 'ScheduledInstallTime',    type: :dword, data: patching['windows']['scheduled_install_hour'] },
      ]
      action :create
    end
  end

  if patching['apply_updates']
    # PSWindowsUpdate would be the production path; for the portfolio we trigger the
    # built-in scan/download via UsoClient so the demo stays dependency-free.
    execute 'trigger windows update scan' do
      command 'UsoClient.exe StartScan'
      returns [0]
    end

    log 'patch-run-windows' do
      message "wes_baseline::patching triggered Windows Update scan on #{node['hostname']}"
      level :info
    end
  else
    log 'patch-config-windows' do
      message "wes_baseline::patching enforced Windows Update AU policy on #{node['hostname']} (apply_updates=false)"
      level :info
    end
  end

else
  log 'patch-unsupported' do
    message "wes_baseline::patching: no patch strategy for platform_family '#{node['platform_family']}' — skipping"
    level :warn
  end
end

# attributes/default.rb - wes_baseline default attributes
#
# Intent: Centralize tunable knobs for the baseline + patching recipes so node/role
#         data can override behavior without editing recipe code.
# Role: Loaded by chef-client before recipe compilation; values are merged with any
#       role/environment/node overrides (node['wes_baseline'][...]).
# Dependencies: None.
# Usage: Override in a policyfile attributes block, role, environment, or node JSON, e.g.
#        default['wes_baseline']['patching']['apply_updates'] = true

# ==============================================================================
# Patching (wes_baseline::patching)
# ==============================================================================
# enforce_config: manage the OS patch policy files/registry to guarantee the node
#   is *configured* for automatic security patching (safe, idempotent, always on).
# apply_updates: actively pull+install pending updates during the Chef run. Default
#   false so convergence stays fast/non-disruptive; flip to true on maintenance
#   windows or for the X11SRA 22.04.1 -> 24.04 upgrade demonstration (5o5.7).
default['wes_baseline']['patching']['enforce_config'] = true
default['wes_baseline']['patching']['apply_updates']  = false

# Debian/Ubuntu: which origins unattended-upgrades is allowed to install from.
# Security-only by default (the conservative, production-safe posture).
default['wes_baseline']['patching']['debian']['allowed_origins'] = [
  '${distro_id}:${distro_codename}-security',
  '${distro_id}ESMApps:${distro_codename}-apps-security',
  '${distro_id}ESM:${distro_codename}-infra-security',
]
default['wes_baseline']['patching']['debian']['auto_reboot']      = false
default['wes_baseline']['patching']['debian']['auto_reboot_time'] = '03:00'

# Windows: Automatic Update behavior via the WindowsUpdate\AU policy key.
#   au_options 4 = "Auto download and schedule the install".
default['wes_baseline']['patching']['windows']['au_options'] = 4
default['wes_baseline']['patching']['windows']['scheduled_install_day']  = 0  # 0 = every day
default['wes_baseline']['patching']['windows']['scheduled_install_hour'] = 3  # 03:00 local

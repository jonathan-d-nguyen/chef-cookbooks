---
aliases: []
lead:
tags: [chef, infrastructure-as-code, devops, portfolio]
title: Westminster Lab Chef Cookbooks
created: 2026-07-13T17:09:00-07:00
modified: 2026-07-13T17:09:00-07:00
---

# Westminster Lab Chef Cookbooks

Automated configuration management, patching, software deployment, and baseline compliance for Westminster Home Network Infrastructure. Designed to manage hybrid Linux/Windows nodes in an enterprise-grade home lab environment.

## Current Status

| Area                                 | Status                                          |
| ------------------------------------ | ----------------------------------------------- |
| Baseline Configuration (`wes_baseline`) | ✅ Active (SSH, WinRM, package auditing, warning banners) |
| Policyfile Lock Management            | ✅ Structured (`Policyfile.rb`) |
| Local Execution & Testing             | ✅ Configured for Local/Zero Mode testing |
| Pipeline Integration                 | 🔴 Planned (GitHub Actions baseline testing) |

## File Map

| What you want               | Where to look                          |
| --------------------------- | -------------------------------------- |
| Default baseline config     | `cookbooks/wes_baseline/recipes/default.rb` |
| Version Locking & Run-lists | `Policyfile.rb`                        |
| Cookbook metadata           | `cookbooks/wes_baseline/metadata.rb`   |

## Target Architecture Integration

These cookbooks are designed to manage the baseline configuration of targets within the Westminster Home Lab:

| Device                | Hostname      | IP            | Platform | Role / Chef Application |
| --------------------- | ------------- | ------------- | -------- | ----------------------- |
| smallHP (Ubuntu+KVM)  | wesmt-pc01    | 192.168.20.20 | Ubuntu   | Baseline user, MOTD banner, SSH service |
| Windows Host (KVM)    | wesmt-pc01-win| DHCP          | Windows  | Baseline user, WinRM service, Registry Warning Banner |

## How to Run & Test (Local Mode)

To apply configurations locally without a Chef Server (Chef Zero Mode), run the following:

```bash
# 1. Install Chef Workstation
# Mac: brew install --cask chef-workstation
# Windows: choco install chef-workstation

# 2. Run the baseline recipe
sudo chef-client -z -o wes_baseline
```

<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->

<!-- PROJECT SHIELDS -->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

<!-- PROJECT LOGO -->
<br />
<div align="center">

<h3 align="center">DevOps Portfolio: Chef Infrastructure Automation</h3>

  <p align="center">
    Automated baseline compliance, configuration enforcement, patching, and provisioning for Westminster Home Lab nodes.
    <br />
    <a href="https://github.com/jonathan-d-nguyen/chef-cookbooks"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/jonathan-d-nguyen/chef-cookbooks/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#1-about-the-project">About The Project</a>
      <ul>
        <li><a href="#11-built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#2-quick-start">Quick Start</a>
      <ul>
        <li><a href="#21-prerequisites">Prerequisites</a></li>
        <li><a href="#22-basic-setup">Basic Setup</a></li>
      </ul>
    </li>
    <li>
      <a href="#3-deployment--operations">Deployment & Operations</a>
      <ul>
        <li><a href="#31-full-installation-steps">Full Installation Steps</a></li>
        <li><a href="#32-testing--verification">Testing & Verification</a></li>
        <li><a href="#33-troubleshooting">Troubleshooting</a></li>
        <li><a href="#34-cicd-pipeline">CI/CD Pipeline</a></li>
        <li><a href="#35-cleanup">Cleanup</a></li>
      </ul>
    </li>
    <li><a href="#4-roadmap">Roadmap</a></li>
    <li>
      <a href="#5-contributing">Contributing</a>
      <ul>
        <li><a href="#51-top-contributors">Top Contributors</a></li>
      </ul>
    </li>
    <li><a href="#6-license">License</a></li>
    <li><a href="#7-contact">Contact</a></li>
    <li><a href="#8-acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<a id="readme-top"></a>

<!-- ABOUT THE PROJECT -->

## 1. About The Project

This repository demonstrates enterprise-grade Infrastructure-as-Code (IaC) configuration management using **Chef Infra**. It automates baseline configuration, security policy enforcement, registry modifications, package delivery, and warning banners across a hybrid infrastructure (Linux and Windows Server environments) within the Westminster Home Lab.

It is designed to showcase skills requested in Systems Technical Specialist roles, including:
* **Configuration Drift Enforcement:** Automatic correction of system state to match code definitions.
* **Baseline Standardization:** Unified user creation, package configuration, and policy setup.
* **Cross-Platform Recipes:** Managing Linux system targets (`/etc/motd`, service management) alongside Windows Server registries.
* **Unified Hostname Compliance:** Dynamically parsing and validating node hostname conventions.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### 1.1. Built With

- [![Chef][Chef.io]][Chef-url]
- [![Ruby][Ruby-lang.org]][Ruby-url]
- [![Ubuntu][Ubuntu.com]][Ubuntu-url]
- [![Windows][Windows-server]][Windows-url]
- [![Markdown][Markdown Guide]][Markdown-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- QUICK START -->

## 2. Quick Start

Get up and running quickly with Chef client convergence in local development mode.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### 2.1. Prerequisites

1. **Chef Workstation**
   Follow the official guide to install Chef Workstation on your platform:
   ```sh
   # Mac (Homebrew)
   brew install --cask chef-workstation

   # Verify installation
   chef --version
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### 2.2. Basic Setup

1. **Clone the repository**
   ```sh
   git clone https://github.com/jonathan-d-nguyen/chef-cookbooks.git
   cd chef-cookbooks
   ```

2. **Execute baseline configuration locally (Chef Zero)**
   ```sh
   sudo chef-client -z -o wes_baseline
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- DEPLOYMENT & OPERATIONS -->

## 3. Deployment & Operations

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### 3.1. Full Installation Steps

1. **Compile & Resolve Dependencies using Policyfiles**
   This repository utilizes Policyfiles (`Policyfile.rb`) instead of Berksfiles for secure run-list compilation and cookbook locking:
   ```sh
   # Compile policy dependencies
   chef install
   ```

2. **Run convergence on specific nodes**
   Apply compiled configurations by specifying the cookbook path:
   ```sh
   sudo chef-client -z -o wes_baseline::default
   ```

3. **Enforce OS patch policy (`wes_baseline::patching`)**
   Configures unattended security upgrades on Debian/Ubuntu and Windows Update AU
   policy on Windows. Config is drift-corrected on every run; installation is gated
   behind an attribute so routine convergence stays non-disruptive.
   ```sh
   # Enforce patch CONFIG only (safe — no packages installed):
   sudo chef-client -z -o wes_baseline::patching

   # Maintenance window — actually apply pending security updates:
   sudo chef-client -z -o wes_baseline::patching \
     -j <(echo '{"wes_baseline":{"patching":{"apply_updates":true}}}')
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### 3.2. Testing & Verification

1. **Drift Remediation Test**
   To test the configuration enforcement:
   ```sh
   # 1. Modify the baseline banner manually
   sudo echo "Unauthorized change" > /etc/motd

   # 2. Re-run Chef Client
   sudo chef-client -z -o wes_baseline

   # 3. Verify that the correct template state was enforced
   cat /etc/motd
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### 3.3. Troubleshooting

1. **Policy File Compilation Errors**
   Ensure your ruby dependencies are aligned by running:
   ```sh
   chef clean-policy-cookbooks
   chef install
   ```

2. **Root Privileges**
   Chef Client requires root access on Unix-like systems and elevated Administrator access on Windows to manage registry entries and user directories. Always execute with `sudo` or as an administrator.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### 3.4. CI/CD Pipeline

*Planned Integration:* Automated linting and syntax validations using `cookstyle` combined with Test Kitchen and Docker containers on pushes.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### 3.5. Cleanup

Remove temporary caches created by Chef Zero local mode:
```sh
sudo rm -rf local-mode-cache/
sudo rm -rf .chef/
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ROADMAP -->

## 4. Roadmap

- [ ] Add Test Kitchen config for automated node testing on Docker
- [ ] Integrate GitHub Actions workflows running `cookstyle` checks
- [ ] Add recipes to bootstrap local DNS configurations using Chef templates
- [ ] Configure automatic node provisioning for target VMs

See the [open issues](https://github.com/jonathan-d-nguyen/chef-cookbooks/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->

## 5. Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### 5.1. Top contributors:

<a href="https://github.com/jonathan-d-nguyen/chef-cookbooks/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=jonathan-d-nguyen/chef-cookbooks" alt="contrib.rocks image" />
</a>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- LICENSE -->

## 6. License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->

## 7. Contact

Jonathan Nguyen - jonathan@jdnguyen.tech

Project Link: [https://github.com/jonathan-d-nguyen/chef-cookbooks](https://github.com/jonathan-d-nguyen/chef-cookbooks)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->

## 8. Acknowledgments

- [Awesome README Template](https://github.com/othneildrew/Best-README-Template/)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
[contributors-shield]: https://img.shields.io/github/contributors/jonathan-d-nguyen/chef-cookbooks.svg?style=for-the-badge
[contributors-url]: https://github.com/jonathan-d-nguyen/chef-cookbooks/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/jonathan-d-nguyen/chef-cookbooks.svg?style=for-the-badge
[forks-url]: https://github.com/jonathan-d-nguyen/chef-cookbooks/network/members
[stars-shield]: https://img.shields.io/github/stars/jonathan-d-nguyen/chef-cookbooks.svg?style=for-the-badge
[stars-url]: https://github.com/jonathan-d-nguyen/chef-cookbooks/stargazers
[issues-shield]: https://img.shields.io/github/issues/jonathan-d-nguyen/chef-cookbooks.svg?style=for-the-badge
[issues-url]: https://github.com/jonathan-d-nguyen/chef-cookbooks/issues
[license-shield]: https://img.shields.io/github/license/jonathan-d-nguyen/chef-cookbooks.svg?style=for-the-badge
[license-url]: https://github.com/jonathan-d-nguyen/chef-cookbooks/blob/main/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/JonathanDanhNguyen

[Chef.io]: https://img.shields.io/badge/chef-%23F15A24.svg?style=for-the-badge&logo=chef&logoColor=white
[Chef-url]: https://www.chef.io/
[Ruby-lang.org]: https://img.shields.io/badge/ruby-%23CC342D.svg?style=for-the-badge&logo=ruby&logoColor=white
[Ruby-url]: https://www.ruby-lang.org/
[Ubuntu.com]: https://img.shields.io/badge/ubuntu-%23E95420.svg?style=for-the-badge&logo=ubuntu&logoColor=white
[Ubuntu-url]: https://ubuntu.com/
[Windows-server]: https://img.shields.io/badge/Windows_Server-%230078D6.svg?style=for-the-badge&logo=windows&logoColor=white
[Windows-url]: https://www.microsoft.com/en-us/windows-server
[Markdown Guide]: https://img.shields.io/badge/markdown-%23000000.svg?style=for-the-badge&logo=markdown&logoColor=white
[Markdown-url]: https://www.markdownguide.org/

# CI/CD Pipeline for Cisco ACI with pre-change and post-change validations using Nexus Dashboard Insights
This repository is based on the work made by Alejandro de Alda, presented on the DEVNET-2473 session in Cisco Live US 2023

## Content description

### GitHub Actions workflow

This example contains a GitHub Actions workflow (or pipeline) that executes in sequential order the following steps:


In the preproduction branch (when a push is detected)
======================================================

* Ansible Linting and Syntax validation

  This job runs a syntax validation using [YAMLLINT](https://yamllint.readthedocs.io/)
  
* Ansible dry-run

  This job runs the Ansible playbook `deploy.yaml` using [check mode](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_checkmode.html#using-check-mode). When playbooks are running in check mode, they do not make changes in the infrastructure, instead Ansible just simulates the changes. When using check mode together with Cisco ACI Ansible collection, the body of POST requests is saved in an output file that can be specified in each of the tasks (or in all of them at one using an anchor).
  
  This job runs in a self-hosted runner, and uses the container [pablomathamel/ansible](https://hub.docker.com/r/pablomathamel/ansible), which has ansible and the required collections pre-installed.
  
* Pre-Change Validation

  This job runs a Pre-change Analysis in Nexus Dashboard Insights, waits until it is completed and evaluates the result. This pre-change analysis is triggered using Nexus Dashboard Collection (cisco.nd)
  
  This job runs in a self-hosted runner, and uses the container [pablomathamel/ansible](https://hub.docker.com/r/pablomathamel/ansible), which has ansible and the required collections pre-installed.
  
In the production branch (when a push is detected, after a pull request from preproduction branch)
===================================================================================================

The next two steps are repeated from the previous preproduction push because time between preproduction test, and final incoporation to production might be enough to introduce other changes to the network that may actually trigger an anomaly. Additionally, since multiple teams may be committing code, the complete consolidated code is checked validated (using NDI PCV) in this step.

* Ansible dry-run

* Pre-Change Validation

* Snapshot

  This job runs a snapshot in the Cisco ACI fabric, using a python script that uses Cobra SDK. 
  
  This job runs in a self-hosted runner, and uses the container [adealdag/aci_cobra](https://hub.docker.com/r/adealdag/aci_cobra), which has python and Cobra SDK pre-installed
  
* Ansible Deployment

  This job executes the ansible playbook and deploy the configuration changes in the infrastructure.
  
  This job runs in a self-hosted runner, and uses the container [pablomathamel/ansible](https://hub.docker.com/r/pablomathamel/ansible), which has ansible and the required collections pre-installed.
  
* Post-Change Validation

  This job runs a Delta Analysis in Nexus Dashboard Insights, waits until it is completed and evaluates the result. This delta analysis is triggered using Nexus Dashboard Collection (cisco.nd)
  
  This job runs in a self-hosted runner, and uses the container [pablomathamel/ansible](https://hub.docker.com/r/pablomathamel/ansible), which has ansible and the required collections pre-installed.
  

### Ansible Playbooks
  
This example contains a set of ansible playbook to deploy a new EPG in a pre-existing tenant called TN-Production. Intentional errors or mistakes can be introduced in the playbook, to trigger different anomalies in NDI.  

All objects to be created are defined in the variable files in a very declarative model.

The playbook `deploy.yaml` imports the other two playbooks, hence making it simpler to run both playbooks in the right order in one go.

### Tools

This folder contains other playbooks and/or scripts that are required for the pipeline jobs, for actions such as taking a snapshot or running the pre-change and post-change validations in Nexus Dashboard Insights.

## Configuration

After you fork or copy this project, there are a few steps to take to be ready to run the pipeline

### Deploying on-prem self-hosted runner

In order to automate tasks on your on-premises infrastructure (like the Cisco ACI fabric or Nexus Dashboard) you will need to deploy a self-hosted runner. This can be a VM or baremetal running any of the supported OS (Linux recommended) and:

* Docker Engine installed
* Outbound connection to github.com, directly or via proxy
* Access to package repositories and hub.docker.com

After that, follow the steps specified in GitHub Repository > Settings > Actions > Runners

> **NOTE:** It is strongly recommended to make your repository private before you deploy a self-hosted runner to avoid being exposed to any unintended execution of code in your runner by third parties.

### Configuring Secrets

A few secrets are required for the pipeline to be correctly executed. These are configured in GitHub Repository > Settings > Secrets and variables > Actions.

* APIC_HOST
* APIC_USERNAME
* APIC_PASSWORD
* ND_HOST
* ROOM_ID
* WEBEX_TOKEN

### Creating a Webex Bot

In order to send notifications via Webex, a Webex Bot needs to be created and added to an existing room. Instructions to create a bot can be found [here](https://developer.webex.com/docs/bots)

### Modifying inventory files

Modify the inventory files for Ansible with your own host information.

Please remember not to commit sensitive information to GitHub, use Ansible Vault to encrypt your inventory file (or the sensitive valuees in it) and provide the vault key as a secret (see above)

## Usage

Make changes in the repository content (preferably on the Cisco ACI playbooks within the `playbooks` folder). Then commit the changes and push them to the remote repository. Thhis will trigger a new execution of the pipeline.

Make sure the self-hosted runner is running before triggering the pipeline.
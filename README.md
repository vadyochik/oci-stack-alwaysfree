# Terraform module for AlwaysFree OCI Compute Instances running podman containers

Currently Oracle sets the following Always Free resources limits:

- Non-flex shape VMs (VM.Standard.E2.1.Micro): standard-e2-micro-core-count = 2
- Flex shape VMs (VM.Standard.A1.Flex): standard-a1-core-count = 4, standard-a1-memory-count = 24
- Block volume size: total-free-storage-gb-regional = 200

So this stack creates 4 VMs each with 47GB (minimum default) boot volume:

- 2 x VM.Standard.E2.1.Micro (1 OCPU, 0.7 GB) <= less powerful AMD processor instances (non-flex shape)
- 2 x VM.Standard.A1.Flex (2 OCPU, 12 GB) <= more powerful Ampere Altra ARM processor instances (flex shape)

Detailed information about Oracle Cloud Infrastructure Always Free resources can be found in [official documentation](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm).

NOTE: Always Free compute instances must be created in your Home Region (the region you selected during account registration).

This module is used as a Stack in OCI Resource Manager and creates the following resources:

- Virtual Cloud Network (VCN)
- 2 x Subnets
- Route Table
- Internet Gateway
- Security List (allow ingress port: 22/tcp)
- 2 x Virtual Machine (VM) Compute Instances (Shape: VM.Standard.E2.1.Micro)
- 2 x Virtual Machine (VM) Compute Instances (Shape: VM.Standard.A1.Flex)

Podman is installed on the VMs from cloud-init.

Containers are managed by systemd service units:

- Non-flex instances VM.Standard.E2.1.Micro run db1000n (can be optionally routed through a sidecar ProtonVPN container)
- Flex ARM instances VM.Standard.A1.Flex run mhddos_proxy (can be optionally routed through a sidecar ProtonVPN container)

## Quickstart guide

### One-click deploy button

[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/vadyochik/oci-stack-alwaysfree/releases/latest/download/oci-stack-alwaysfree-latest.zip)

### A bit more detailed info

1. Download the [latest](../../releases/latest/download/oci-stack-alwaysfree-latest.zip) release of this module in *zip* format.
1. [Login](https://www.oracle.com/cloud/sign-in.html) to your Oracle Cloud account. If you still don't have one, [create it](https://signup.cloud.oracle.com/) - you'll need a valid CC with $1 for verification.
1. (Optional) Create an OCI compartment. This is for grouping resources created by this stack. This step is not required and root compartment can be used instead. Follow the documentation for [creating a compartment](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingcompartments.htm).
1. In [Oracle Cloud Console](https://cloud.oracle.com/), open the navigation menu and click **Developer Services**. Under **Resource Manager**, click **Stacks**. Alternatevely, you can get to **Stacks** by entering the word "stacks" in the search bar.
1. Choose a compartment on the left side of the page (use "root" compartment if you skipped creating a new one in step 3). Click **Create Stack**.
1. You are now at **Stack Information** page. For origin of the Terraform configuration, select **My Configuration**; for **Stack Configuration**, select **.Zip file**. Then either click *Browse* or drag-n-drop the zip file that you downloaded at step 1. Click **Next**.
1. You are now at **Configure Variables** page. If you have ProtonVPN subscription, you may want to use it here to route traffic through VPN, either leave VPN vendor selection as "none". Provide your ssh public key to be added to instances `authorized_keys` file (you can generate one by `ssh-keygen -t ed25519` command). Select the latest available Oracle Linux images and click **Next**.
1. You are now at **Review** page. Select **Run Apply** checkbox at the bottom of the page and click **Create**.
1. Wait for about 30-40 minutes for full VMs provisioning (OS updates roll-up takes about 20 mins, podman installation takes up to 10mins).
1. Look at graphs of each VM (**Instances** => <instance_name> => **Metrics**).
1. If you're not a housewife, you may want to login to the instances via SSH and execute some commands.

## SSH login info

Example of `~/.ssh/config` for quick connect:

```
Host alwaysfree-flex-1
  Hostname 11.11.11.11
  User opc
  IdentityFile ~/.ssh/id_ed25519

Host alwaysfree-flex-2
  Hostname 22.22.22.22
  User opc
  IdentityFile ~/.ssh/id_ed25519

Host alwaysfree-nonflex-1
  Hostname 33.33.33.33
  User opc
  IdentityFile ~/.ssh/id_ed25519

Host alwaysfree-nonflex-2
  Hostname 44.44.44.44
  User opc
  IdentityFile ~/.ssh/id_ed25519
```

so you can connect by `ssh alwaysfree-flex-1` and `ssh alwaysfree-nonflex-1`.

Or use a full command without adding hosts to ssh config: `ssh opc@140.238.221.180 -i ~/.ssh/id_ed25519`

## Useful commands

The following examples use `mhddos_proxy` as a container name, replace it with appropriate name for other containers.

NOTE: execute all the below commands as root (do `sudo -i` after ssh login). *Tab* key autocompletion works fine there, use it!

HINT: You can login to the first server with ssh-agent authentication forwarding enabled like `ssh -A alwaysfree-flex-1` and start `tmux` session there, then login to other 3 servers via ssh (use Tab key as hosts autocompletion).

### Container start/stop management via systemd

Show container's systemd service unit

```
systemctl cat container-mhddos_proxy.service
```

Stop/start/restart the container via systemd:

```
systemctl stop container-mhddos_proxy.service
systemctl start container-mhddos_proxy.service
systemctl restart container-mhddos_proxy.service
```

Check/disable/enable container's start on reboot:

```
systemctl is-enabled container-mhddos_proxy.service
systemctl disable container-mhddos_proxy.service
systemctl enable container-mhddos_proxy.service
```

NOTE: because of `--pull=always` option, when you restart the systemd service if there is a newer image available, it will be automatically pulled. So when you need to run the latest image, just restart the systemd service.

### Container status

Systemd service status and logs:

```
systemctl status container-mhddos_proxy.service
journalctl -u container-mhddos_proxy.service
```

List currently running containers:

```
podman ps
```

List all containers (including stopped and created):

```
podman ps --all
```

Display a live stream of container's resource usage statistics:

```
podman stats
```

### Container output and interaction

Retrieve all logs from the container (following the output):

```
podman logs -f mhddos_proxy
```

Attach to the running container:

```
podman attach mhddos_proxy
```

NOTE: Detach with *ctrl-p,ctrl-q* key sequence; and: *ctrl-c* will stop the container.

Get interactive shell inside the running container:

```
podman exec -it mhddos_proxy /bin/sh
```

## Delete resources and the stack

1. In [Oracle Cloud Console](https://cloud.oracle.com/), open the navigation menu and click **Developer Services**. Under **Resource Manager**, click **Stacks**. Alternatevely, you can get to **Stacks** by entering the word "stacks" in the search bar.
1. Click on the stack name you need to remove.
1. Click **Destroy** red button. Click **Destroy** blue button. This will shutdown and remove all the resources created by the stack.
1. Once the above **destroy** job is finished, get back to the stack by clicking on **Stack Details** on top of the page.
1. Click on **More Actions** and then on **Delete Stack**. Click **Delete** red button in the confirmation popup window.

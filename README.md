# Cloud-Init VM Creation Script

This project provides a Bash script for creating virtual machines (VMs) using QEMU/KVM and cloud-init.

## Features

- Interactive creation of VMs.
- Configurable VM settings (RAM, CPUs, image size).
- Supports bridged and open (macvtap) network modes.
- Cloud-init integration for user and SSH setup.

## Prerequisites

- qemu-kvm
- libvirt-daemon-system
- libvirt-clients
- virtinst
- genisoimage
- wget
- bridge-utils (for bridge network mode)
- whois (for `mkpasswd` utility)
- arp-scan (for IP detection in open network mode)

## Usage

1. **Setup `.env` File:**
   Configure environment variables such as VM specs and network settings in `.env`.

2. **Execute the Script:**
   Run the script to interactively create a VM with specified configurations.

3. **Choose Network Mode:**
   Select between 'bridge' or 'open' network modes during script execution.

4. **VM Access:**
   The script provides the VM's IP address at the end for easy access.

## Network Configuration

- **Bridge Mode:** Uses a bridge interface for VM networking.
- **Open Mode:** Uses a macvtap interface, directly connecting the VM to the physical network.

## Contribution

Feel free to contribute, report issues, or suggest improvements!

#!/bin/bash

# Source the .env file in the current directory
source .env

# Ask for VM name, with auto-generation if blank
read -p "Enter VM name (Press enter for auto-generated name): " VM_NAME
if [ -z "$VM_NAME" ]; then
    VM_NAME="cloudimg-$(date +%s)"
fi

# Ask for VM RAM, use default if blank
read -p "Enter RAM size in MB (Press enter for default ${DEFAULT_VM_RAM}): " VM_RAM
VM_RAM=${VM_RAM:-$DEFAULT_VM_RAM}

# Ask for number of vCPUs, use default if blank
read -p "Enter number of vCPUs (Press enter for default ${DEFAULT_VM_CPUS}): " VM_CPUS
VM_CPUS=${VM_CPUS:-$DEFAULT_VM_CPUS}

# Ask for image size, use default if blank
read -p "Enter disk image size (e.g., 10G) (Press enter for default ${DEFAULT_IMAGE_SIZE}): " IMAGE_SIZE
IMAGE_SIZE=${IMAGE_SIZE:-$DEFAULT_IMAGE_SIZE}

# Directory for VM files
VM_DIR="${BASE_DIR}/${VM_NAME}"
mkdir -p $VM_DIR

# Download the specified cloud image
if ! wget $BASE_IMAGE_URL -O $VM_DIR/cloudimg.img; then
  echo "Error downloading the base image. Cleaning up..."
  rm -rf $VM_DIR
  exit 1
fi

# Convert the image format
qemu-img convert -f qcow2 -O raw $VM_DIR/cloudimg.img $VM_DIR/cloudimg.raw

# Create a new disk image from the cloud image
qemu-img create -b $VM_DIR/cloudimg.img -f qcow2 -F qcow2 $VM_DIR/${VM_NAME}.img $IMAGE_SIZE

# Create the meta-data file
cat > $VM_DIR/meta-data <<EOF
instance-id: ${VM_NAME}
local-hostname: ${VM_NAME}
EOF

# Create the user-data file
cat > $VM_DIR/user-data <<EOF
#cloud-config
users:
  - name: ${CLOUD_USER}
    ssh_authorized_keys:
      - ${SSH_PUBLIC_KEY}
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    groups: sudo
    shell: /bin/bash

ssh_authorized_keys:
  - ${SSH_PUBLIC_KEY}
EOF

# Create an ISO with cloud-init configuration files
genisoimage -output $VM_DIR/cidata.iso -V cidata -r -J $VM_DIR/user-data $VM_DIR/meta-data

# Create the VM
virt-install --name=${VM_NAME} --ram=${VM_RAM} --vcpus=${VM_CPUS} --import \
--disk path=$VM_DIR/${VM_NAME}.img,format=qcow2 \
--disk path=$VM_DIR/cidata.iso,device=cdrom \
--os-variant=ubuntu20.04 --network bridge=virbr0,model=virtio \
--graphics vnc,listen=0.0.0.0 --noautoconsole

# Wait for the VM to boot up
sleep 20

# Get the VM's IP address
virsh net-dhcp-leases default


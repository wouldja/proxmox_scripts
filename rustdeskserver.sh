#!/bin/bash

# Variables
rust_server_name="RustServer"
rust_server_disk_size="50G"
rust_server_memory="2G"
rust_server_vmid="110"
rust_server_ostemplate="local:vztmpl/ubuntu-20.04-standard_20.04.1-1_amd64.tar.gz"

# Create new virtual machine
qm create ${rust_server_vmid} --name ${rust_server_name} --memory ${rust_server_memory} --disk size=${rust_server_disk_size} --ostype ubuntu --vga std

# Set operating system template
qm template ${rust_server_vmid} ${rust_server_ostemplate}

# Start virtual machine
qm start ${rust_server_vmid}

# Wait for virtual machine to boot
sleep 60

# Install required packages
pct exec ${rust_server_vmid} -- bash << EOF
apt-get update
apt-get install -y lib32gcc1 curl
EOF

# Download and install Rust server
pct exec ${rust_server_vmid} -- bash << EOF
curl -sSL https://github.com/Rust-Experimental/Rust-Server/releases/download/Rust-Experimental-Latest/rust_server.sh | bash
EOF

# Start Rust server
pct exec ${rust_server_vmid} -- bash << EOF
./rust_server.sh start
EOF

# Configure firewall
pct exec ${rust_server_vmid} -- bash << EOF
ufw allow 28015/tcp
ufw allow 28016/tcp
ufw allow 28017/tcp
ufw allow 28018/tcp
ufw allow 28019/tcp
ufw allow 28020/tcp
EOF

echo "Rust server setup complete!"

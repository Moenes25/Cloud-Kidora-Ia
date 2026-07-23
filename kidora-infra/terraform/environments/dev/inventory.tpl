[k3s_master]
k3s-master-01 ansible_host=${dev_server_ip} ansible_user=ubuntu

[k3s_workers]
# Add worker nodes here when ready
# k3s-worker-01 ansible_host=${worker_1_ip} ansible_user=ubuntu

[all:vars]
admin_user=ubuntu
k3s_tls_san=${dev_server_ip}

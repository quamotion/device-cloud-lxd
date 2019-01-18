[all:vars]
ansible_user=${deployer_user}
ansible_ssh_private_key_file=${deployer_user_key_file}

[device-cloud-pxe]
pxe ansible_host=${pxe_ip}

[device-cloud-master]
master ansible_host=${master_ip}

[device-cloud-master:vars]
device_farm_role=master

[device-cloud-workers]
worker ansible_host=${worker_ip}

[device-cloud-workers:vars]
device_farm_role=worker
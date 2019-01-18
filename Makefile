destroy:
	terraform destroy -auto-approve

apply:
	terraform apply -auto-approve

deploy:
	rm -f ~/.ssh/known_hosts
	ANSIBLE_CONFIG=ansible.cfg ansible-playbook wait-for-ready.yml

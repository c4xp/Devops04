ansible-inventory -i inventory --list -y

openssl passwd -salt S4ltsha256H4sh00 -5 $(read -sp "Password: ";echo $REPLY)
mkpasswd --method=SHA-256 $(read -sp "Password: ";echo $REPLY) S4ltsha256H4sh00

ansible -i inventory all -m ping -u root
ansible -i inventory all -a "df -h" -u root

ansible-playbook -i inventory tasks.yml --user <user> --ask-pass -vvvv
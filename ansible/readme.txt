ansible-inventory -i inventory --list -y

ssh-keyscan -H 10.0.0.10 >> ~/.ssh/known_hosts

openssl passwd -salt S4ltstring -5 $(read -sp "Password: ";echo $REPLY)

ansible -i inventory all -m ping -u root
ansible -i inventory all -a "df -h" -u root

ansible-playbook .. --extra-vars "new_user_name=johndoe new_user_salt=S4ltstring new_user_pass=P4ssword"

ansible-playbook -i inventory tasks.yml --user johndoe --ask-pass -vvvv

ansible-playbook -i inventory tasks.yml --ask-pass
cp secret.yml vault.yml
ansible-vault encrypt vault.yml

ansible-playbook -i inventory tasks.yml --ask-pass --ask-vault-pass

echo 'V4ultP4ssword' > .vault_pass
chmod 0600 .vault_pass
ansible-playbook -i inventory tasks.yml --vault-password-file=.vault_pass


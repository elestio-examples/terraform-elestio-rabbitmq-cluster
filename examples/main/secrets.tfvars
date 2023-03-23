# secrets.tfvars

project_id = "2500"
erlang_cookie = "SecureAndSecretString"
admin_email = "admin@email.com"
ssh_key_name = "Admin"
ssh_public_key = file("~/.ssh/id_rsa.pub")
ssh_private_key = file("~/.ssh/id_rsa")

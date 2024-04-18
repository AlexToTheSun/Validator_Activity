Support for **password authentication** **was removed** on August 13, 2021.
To use Git on the server we need to [set SSH-key](https://htmlacademy.ru/blog/git/git-console) 

1. Install git
```
sudo apt install git htop curl nano mc -y
ls -al ~/.ssh
```
2. Generate keys
```
ssh-keygen -t ed25519 -C "your_email@example.com"
# ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```
3. Add key to your local ssh Agent
```
# Run
eval "$(ssh-agent -s)"
# Adding our SSH key
# Change id_ed25519 to a name of your key
ssh-add ~/.ssh/id_ed25519
```
4. Add generated SSH-key into GitHub account
```
clip < ~/.ssh/id_ed25519.pub
# cat ~/.ssh/id_ed25519.pub
```
Go to https://github.com/settings/keys and past copied ssh key.

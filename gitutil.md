---
currentMenu: gitutil
layout: default
title: Devops04
subTitle: Comenzi Git
---

![Git workflow](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/devops04git00.png)

# Some Git good practices

Need a `git --version --build-options` first.
Also a good ideea is to set `git config user.name` and `git config user.email` for the current project (in the current folder).

```
master
 ---------------------X-----Y-Z
                       \   /
dev                     \ /
 A--B--C-----H--I--J--M--N
        \   /    \
feat001  \ /      \
 D--E--F--G--------K--L
```

### Create a new branch for your feature

```
git checkout -b feat001
```

### Commit your work

```
git add .
git commit -m "adding a change from the feat001 branch"
git push --set-upstream origin feat001
```

### To keep test in sync with Development (*merge Development into feat001*) [so that if there are any conflicts, they can be resolved in the feat001 branch itself, and Development remains clean]:

```
git checkout dev
git pull
git checkout feat001
git merge dev
```

### Then when you are ready (and resolved any conflicts) to *merge feat001 into Development*:

```
git checkout dev
git merge feat001
git push origin dev
```

### Switch back to your new feature, and repeat the flow

```
git checkout feat001
```

## Git global setup

```
git config --global user.name "UPSTREAM-USER"
git config --global user.email "UPSTREAM-EMAIL@SOMETHING"
```

## Create a new repository

```
git clone https://github.com/UPSTREAM-USER/ORIGINAL-PROJECT.git
cd xyz
touch README.md
git add README.md
git commit -m "add README"
git push -u origin master
```

## Existing folder or Git repository

```
cd existing_folder
git init
git remote add origin https://github.com/UPSTREAM-USER/ORIGINAL-PROJECT.git
git add .
git commit
git push -u origin master
```

## Pull request (https://gist.github.com/Chaser324/ce0505fbed06b947d962)

Clone your fork to your local machine
```
git clone https://github.com/MY-USER/NEW-PROJECT.git
cd LimeSurvey
```

Add 'upstream' repo to list of remotes
```
git remote add upstream https://github.com/UPSTREAM-USER/ORIGINAL-PROJECT.git
```

Verify the new remote named 'upstream'
```
git remote -v
```

Whenever you want to update your fork with the latest upstream changes, Fetch from upstream remote
```
git fetch upstream
git branch -va
```

Checkout your master branch and merge upstream
```
git checkout master
git merge upstream/master
```

Create a new branch named newfeature (give your branch its own simple informative name)
```
git branch newfeature
```

Switch to your new branch
```
git checkout newfeature
```

## How to create new branch

First, you must create your branch locally
```
git checkout -b your_branch
```

Then, Push the branch to the remote repository origin
```
git push -u origin your_branch
```

## Generate a SSH Key for use on your GIT repo

Option1. Open Git Bash window (if installed Git from https://git-scm.com/downloads)

![Git-bash-here](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/git-bash-here.png)

Option2. install OpenSsh Client from Windows Features

```
Add-WindowsCapability -Online -Name OpenSSH.Client*
```

Then you can generate a new ssh key

```
ssh-keygen -t rsa -b 2048 -C "MyUser laptop"
```

The result should be something like:
```
Generating public/private rsa key pair.
Enter file in which to save the key (/c/Users/MyUser/.ssh/id_rsa): Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /c/Users/MyUser/.ssh/id_rsa
Your public key has been saved in /c/Users/MyUser/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:1234abcd1234abcd12341234abcd1234abcd1234 MyUser machine
The key's randomart image is:
+---[RSA 2048]----+
|       1234      |
|      abcd       |
|   1234          |
|     abcd        |
|1234             |
+----[SHA256]-----+
```

Copy the contents of the public key into your Git account
```
Linux> cat ~/.ssh/id_rsa.pub
Windows> type C:\Users\$ENV:USERNAME\.ssh\id_rsa.pub
```

Verify that your SSH key was added correctly (example with gitlab)
```
ssh -T git@gitlab.com
```

## Switch from HTTPS to SSH

Open Git Bash

Change the current working directory to your local project

List your existing remotes in order to get the name of the remote you want to change
```
git remote -v
```

Change your remote's URL
```
git remote set-url origin git@github.com:USERNAME/REPOSITORY.git
```

Verify that the remote URL has changed
```
git remote -v
```

![Questions](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/questions.png)

[Manual deployment→](manual.md)

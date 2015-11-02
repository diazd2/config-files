#!/bin/bash
if (( EUID == 0 )); then
	echo "You must NOT be root to run this." 1>&2
	echo "Why? Preferences are changed for the current user." 1>&2
	echo "If ran as root, those changes will not take place for you, but for root instead." 1>&2
	echo "Also, many files will be owned by root rather than you, messing up permissions." 1>&2
	exit 1
fi

# prevent root from creating ~/tmp/ by creating it ourself and cause permission problems
# Make .node because in the later versions of npm, it's too stupid to make a folder anymore
mkdir ~/tmp/ ~/.node/

echo ""
echo "Please enter your name (for git): "
read name

echo ""
echo "Please enter your email (for git): "
read email

echo ""
echo "Would you like to install nginx? (Y/n) "
read nginx

if [ -z "$nginx" ]; then
	nginx="Y"
fi
nginx="${nginx^^}" #toUpperCase

echo ""
echo "Would you like to install docker? (Y/n) "
read docker

if [ -z "$docker" ]; then
	docker="Y"
fi
docker="${docker^^}" #toUpperCase

echo ""
echo "Would you like to install sublime? (Y/n) "
read sublime

if [ -z "$sublime" ]; then
	sublime="Y"
fi
sublime="${sublime^^}" #toUpperCase

if [ "$sublime" == "Y" ]; then
	defaulteditor="S"
else
	defaulteditor="N"
fi

defaulteditor="${defaulteditor^^}" #toUpperCase

sudo apt-get install -y software-properties-common

if [ "$sublime" == "Y" ]; then
	sudo add-apt-repository -y ppa:webupd8team/sublime-text-3
fi

sudo apt-get update
sudo apt-get install -y openjdk-7-jdk openjdk-7-source git gparted curl vim meld

if [ "$sublime" == "Y" ]; then
	sudo apt-get install -y sublime-text-installer
	sudo mv /usr/bin/subl /usr/bin/sublime
	wget https://sublime.wbond.net/Package%20Control.sublime-package -P ~/.config/sublime-text-3/Installed\ Packages
fi

if [ "$nginx" == "Y" ]; then
	sudo apt-get install -y nginx
fi

if [ "$docker" == "Y" ]; then
	sudo apt-get install -y apt-transport-https
	# Add Official Docker Repository to install docker as opposed to using official Ubuntu package
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
	sudo sh -c "echo deb https://get.docker.com/ubuntu docker main\
	> /etc/apt/sources.list.d/docker.list"
	sudo apt-get update
	sudo apt-get install -y lxc-docker
	# Configure Docker to be used without sudo
	sudo groupadd docker
	sudo gpasswd -a $USER docker
	sudo service docker restart
fi


# nodejs (latest ver = 0.12)
curl -sL https://deb.nodesource.com/setup_0.12 | sudo bash -
sudo apt-get install -y nodejs
sudo apt-get install -y build-essential
sudo apt-get install -y npm

echo prefix = ~/.node >> ~/.npmrc
echo 'export PATH=$PATH:$HOME/.node/bin' >> ~/.bashrc
echo 'export NODE_PATH=$NODE_PATH:$HOME/.node/lib/node_modules' >> ~/.bashrc
echo 'export PYTHONPATH=$PYTHONPATH:$HOME/.node/lib/node_modules' >> ~/.bashrc
echo 'export PATH=$PATH:$HOME/.node/bin' >> ~/.profile
echo 'export NODE_PATH=$NODE_PATH:$HOME/.node/lib/node_modules' >> ~/.profile
echo 'export PYTHONPATH=$PYTHONPATH:$HOME/.node/lib/node_modules' >> ~/.profile
hash -r
source ~/.bashrc
npm install -g --prefix=$(npm config get prefix) bower grunt-cli less jscs jshint yo

# If they clone the repo, copy it. If they just downloaded the script, attempt to grab it from github.
[ -f .jshintrc ] && cp .jshintrc ~ || wget https://raw.githubusercontent.com/JonathanGawrych/Linux-up-to-speed/master/.jshintrc -P ~
[ -f .jscsrc ] && cp .jscsrc ~ || wget https://raw.githubusercontent.com/JonathanGawrych/Linux-up-to-speed/master/.jscsrc -P ~
git clone https://github.com/magicmonty/bash-git-prompt.git ~/.bash-git-prompt
(cd ~/.bash-git-prompt && git reset --hard eb2554395c43287c1ada1544012106b61f8ce3c8)
echo "source ~/.bash-git-prompt/gitprompt.sh" >> ~/.bashrc

gsettings set org.gnome.desktop.wm.preferences theme 'Ambiance'
gsettings set org.gnome.desktop.interface gtk-theme 'Ambiance'
gsettings set org.gnome.desktop.interface cursor-theme 'DMZ-White'
gsettings set org.gnome.desktop.interface clock-format 12h
gsettings set org.gnome.desktop.interface clock-show-date true
gsettings set org.gnome.desktop.interface clock-show-seconds true
gsettings set org.gnome.shell.calendar show-weekdate true
gsettings set org.gnome.shell.overrides button-layout ':minimize,maximize,close'
gsettings set org.gnome.shell.overrides workspaces-only-on-primary false
gsettings set org.gnome.gedit.preferences.ui notebook-show-tabs-mode 'auto'
gsettings set org.gnome.gedit.preferences.editor display-line-numbers true
gsettings set org.gnome.gedit.preferences.editor wrap-mode 'none'
gsettings set org.gnome.gedit.preferences.editor tabs-size 4
gsettings set org.gnome.gedit.preferences.editor create-backup-copy false
gsettings set org.gnome.nautilus.preferences enable-interactive-search true
gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "{'Gtk/EnablePrimaryPaste': <0>}"
gsettings set org.gnome.desktop.input-sources xkb-options "['terminate:ctrl_alt_bksp']"

git config --global merge.tool meld
git config --global mergetool.keepBackup false
git config --global diff.tool meld
git config --global --add color.ui true
git config --global push.default simple
git config --global user.email "$email"
git config --global user.name "$name"
git config --global core.pager 'less -x5,9'
git config --global pull.ff only

if [ "$defaulteditor" == "S" ]; then
	git config --global core.editor "sublime -wn"
fi

# generate and save ssh public key
ssh-keygen -t rsa -b 2048 -C "$email" -N "" -f ~/.ssh/id_rsa

cp ~/.bash-git-prompt/git-prompt-colors.sh ~/.git-prompt-colors.sh
sed -i -e 's/\xe2\x97\x8f/\xe2\x80\xa2/' -e 's/\xe2\x9c\x96/\xe2\x98\xa2\x20/' -e 's/\xe2\x9c\x9a/\xc2\xb1/' -e 's/\xe2\x9a\x91/\xe2\xad\x91/' -e 's/\xe2\x9a\x91/\xe2\xad\x91/' -e 's/\xe2\x86\x91\xc2\xb7/\xe2\x86\x91/' -e 's/\xe2\x86\x93\xc2\xb7/\xe2\x86\x93/' ~/.git-prompt-colors.sh
printf '\n  GIT_PROMPT_START="$BoldBlue\w$ResetColor"\n  GIT_PROMPT_END=" $ "' >> ~/.git-prompt-colors.sh

if [ "$docker" == "Y" ]; then
	echo "Script Complete. Please log out and log back in to finish Docker configuration."
fi

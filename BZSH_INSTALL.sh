#!/bin/bash


USER=$(who | awk -F ' ' '{if (NR==1) {print $1}}')


CONF_CHECK() {	
if	[ $(grep $USER /etc/passwd | grep zsh) ] && \
	echo $(which zsh) >/dev/null && \
	[ -d /home/$USER/.zsh/zsh-syntax-highlighting ] && \
	[ -d /home/$USER/.zsh/zsh-autosuggestions ] && \
	[ -d /home/$USER/.zsh/zsh-autocomplete ]; then
	echo "zsh, zshrc and the plugins are installed and configured correctly!"
	echo "default shell for the user "$USER" will be changed to ZSH after login"

else
	echo "#################################################"
	echo "#Something went wrong, didn't install correctly!#"
	echo "#################################################"
fi
}

# Check for zsh then begin configuring
 CONF_ZSH() {
 if [ -f /bin/zsh ]; then
	echo "Installing zshrc plugins..."
	sleep 1
	rm -rf /home/$USER/tmp/.zsh
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git	/home/$USER/tmp/.zsh/zsh-syntax-highlighting/
	git clone https://github.com/marlonrichert/zsh-autocomplete.git		/home/$USER/tmp/.zsh/zsh-autocomplete/
	git clone https://github.com/zsh-users/zsh-autosuggestions		/home/$USER/tmp/.zsh/zsh-autosuggestions/
	cp -r /home/$USER/tmp/.zsh /home/$USER/
	rm -rf /home/$USER/tmp/.zsh
	cp .zshrc /home/$USER/.zshrc
	chsh -s $(which zsh) $USER
	export SHELL=/bin/zsh
	CONF_CHECK
 else
 CONF_CHECK
 fi
 }


# Checks for dependencies
DEP_CHECK() {
for I in $1; do
	if [ ! -f /bin/$I ]; then

		echo "###########################"
		echo "$I not found!		 "
		echo "Installing $I...		 "
		echo "###########################"
 [ -f /etc/redhat-release ] && yum install $I	
 [ -f /etc/arch-release   ] && pacman -S $I	
 [ -f /etc/gentoo-release ] && emerge app-shells/$I
 [ -f /etc/SuSE-release   ] && zypper install $I
 [ -f /etc/debian_version ] && apt install $I	
 [ -f /etc/alpine-release ] && apk add $I	
 [ -f /etc/fedora-release ] && dnf install $I	
	fi
done
CONF_ZSH
}

# Startup
clear
 cat <<EOF
Welcome to BZSH!
This script will install ZSH, ZSH plugins and configure a custom .zshrc
dependencies:
 -zsh
 -git
 -curl
dependencies will ask to be installed if not installed already.
sudo is required if this script will try to install dependencies.
this script will set your default shell to zsh, changes will appear after login.
EOF
 read -r -p "Do you want to continue [y/N]" REPLY
 case "$REPLY" in
	[yY][eE][sS]|[yY])
		DEP_CHECK "zsh git curl"
		;;
	*)
		echo "Exiting..."
		sleep 0.5
		exit
		;;
 esac

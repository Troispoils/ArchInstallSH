#!/bin/bash

#Function d'aide argument
function help(){
	echo "Liste des argument a données :"
	echo "... NAME SWAP RACINE MDPROOT"
	echo "Exemple NAME: Troispoils"
	echo "Exemple de SWAP: +1G"
	echo "Exemple RACINE: /"
	echo "MDPROOT: azerty"
}

#Function Formatage
function format(){
echo "swap : "$1
fdisk /dev/sda << EOF
d

d

d

d

n
p


+150M

n
p


$1

n
p


+15G

n
p




w
EOF
}

if [ $# < 5 ]; then
	echo "Trop d'argument"
	help
elif [ $# = 0 ]; then
	echo "Pas d'argument"
	help
elif [ $1 = "help" ]; then
	help
else
	echo "## Installation Basic ##"
	echo "Enregistrement des Argument"

	echo "Nom de la Machine = "$1
	NAME=$1
	echo "swap = "$2
	SWAP=$2
	echo "/ = "$3
	RACINE=$3
	echo "mdp root = "$4
	MDPROOT=$4
	echo "Fin de l'enregistrement"

	loadkeys fr-pc
	timedatectl set-ntp true

	echo "Test Internet"
	ping www.google.fr -c5 -q
	if [ $? != 1 ]
	then

	echo "Internet Ok, Partitionement:"
	format $SWAP $RACINE
	mkfs.ext2 /dev/sda1
	mkfs.ext4 /dev/sda3
	mkfs.ext4 /dev/sda4
	mkswap /dev/sda2
	mount /dev/sda3 /mnt
	# Pour créer le(s) dossier(s) utilisateur, il nous faut monter la partition /home
	mkdir /mnt/home && mount /dev/sda4 /mnt/home
	swapon /dev/sda2
	mkdir /mnt/boot && mount /dev/sda1 /mnt/boot
	cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
	echo "Server = http://archlinux.mirror.pkern.at/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
	pacstrap /mnt base base-devel dialog wireless_tools 
	pacstrap /mnt syslinux
	genfstab -U -p /mnt >> /mnt/etc/fstab

	arch-chroot /mnt /bin/bash <<EOF
	echo $NAME > /etc/hostname
	echo '127.0.1.1 $NAME.localdomain $NAME' >> /etc/hosts
	ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime
	echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen
	locale-gen
	echo LANG="fr_FR.UTF-8" > /etc/locale.conf
	export LANG=fr_FR.UTF-8
	echo KEYMAP=fr > /etc/vconsole.conf
	mkinitcpio -p linux
	passwd
$MDPROOT
$MDPROOT
	syslinux-install_update -iam
	exit
EOF

	umount -R /mnt

	echo "Fin de l'installtion"
	read entre

	reboot

	else
	echo "ca marche pas, Verifi Internet"
	fi

	echo "FIN"
fi

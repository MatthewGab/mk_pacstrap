#!/bin/bash
set -e

# colors
c_red="\033[1;31m"
c_green="\033[1;32m"
c_blue="\033[1;34m"
c_reset="\033[0m"

CWD=$(pwd)
PKGS=($@)

if ! command -v pacstrap &> /dev/null; then
	printf "\n${c_red}Packge: 'arch-install-scripts' is not installed. Exiting...${c_reset}\n\n"
	exit
fi

checkPackageValidity() {
	not_found=()
	for pkg in ${PKGS[@]}; do
		if ! pacman -Si ${pkg} &> /dev/null; then
			printf "\n${c_red}Pacman Error:${c_green} ${pkg}${c_red} was not found.${c_reset}\n"
			not_found+=(${pkg})
		fi
	done

	if (( ${#not_found[@]} != 0 )); then
		exit	
	fi
}

compressPacstrap() {
	if [[ ! -d ${CWD}"/pacstrap" ]]; then
		printf "\n${c_red}Error: Pacstrap directory doesn't exist. Exiting...${c_reset}\n\n"
		exit
	fi
	(cd ${CWD}"/pacstrap"; sudo tar -czvf ${CWD}"/pacstrap.tar.gz" .)
}

main() {
	if [[ -d ${CWD}"/pacstrap" ]]; then
		sudo rm -rf ${CWD}"/pacstrap"
	fi


	if [[ ${PKGS} != "" ]]; then
		FMT=$(echo "${PKGS[@]}" | sed 's/ /, /g')
		printf "\n${c_green}Extra Packages:${c_reset} ${FMT}\n\n"; sleep 3
	fi

	mkdir -p ${CWD}"/pacstrap"

	BASE=(base linux linux-firmware gvim grub efibootmgr \
	      dhcpcd dosfstools mtools os-prober sudo dmidecode)

	sudo pacstrap -C ${CWD}"/pacman.conf" ${CWD}"/pacstrap" ${BASE[@]} ${PKGS[@]}
}

checkPackageValidity
main
compressPacstrap

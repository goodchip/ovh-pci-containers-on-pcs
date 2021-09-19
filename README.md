# ovh-pci-containers-on-pcs
Automation post-install scripts for install docker based configuration running on PCI (public cloud instance) with containers attached on PCS (public cloud storage)


# Installation :
* Update distribution and install git if not present:
> sudo apt-get -y update && sudo apt-get -y upgrade && sudo apt-get -y install git

* Clone the repo to your current directory:
> git clone https://github.com/goodchip/ovh-pci-containers-on-pcs.git && sudo chmod +x ovh-pci-containers-on-pcs/.configure && sudo ./ovh-pci-containers-on-pcs/.configure

# Configuration:
* Locate you into the project root directory:
> cd ovh-pci-containers-on-pcs/

* Copy .env.example to have a '.env' environnement file into the project root directory:
> sudo cp ../ovh-pci-containers-on-pcs/.env.example .env

* Edit the '.env' file environnement with your server configuration nedded:
> sudo nano ../ovh-pci-containers-on-pcs/.env

* Save the '.env' file typing [CTRL+X] and [y] and [ENTER]


# Usage :
* Use the differents scripts located into /distrib##/ directories to configure step by step your instance, by example (for debian10):

> sudo ./debian10/install-pci.sh -h        # for get help to prepare your PCI

> sudo ./debian10/install-pcs.sh -h        # for get help to install your PCS (attach your volume with ovh manager after)

> sudo ./debian10/install-docker.sh -h     # for get help to install docker and docker-compose in your PCI

> sudo ./debian10/install-webproxy.sh -h   # for get help to install container webproxy in your PCS

> sudo ./debian10/install-wordpress.sh -h   # for get help to install container wordpress in your PCS

> sudo ./debian10/install-nextcloud.sh -h   # for get help to install container nextcloud in your PCS

* OR, use the autoinstall script for all-in-one configuration (make you sure to have correctly edited the '.env' file after!!!) :
> sudo ./auto-install.sh

# Have fun!

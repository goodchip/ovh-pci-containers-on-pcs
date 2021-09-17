# ovh-pci-containers-on-pcs
Automation post-install scripts for install docker based configuration running on PCI (public cloud instance) with containers attached on PCS (public cloud storage)


# Installation :
* Clone the repo to your current directory:
> git clone https://github.com/goodchip/ovh-pci-containers-on-pcs.git && sudo chmod +x ovh-pci-containers-on-pcs/.configure && ./ovh-pci-containers-on-pcs/.configure

# Configuration:
* Locate you into the project root directory:
> cd ovh-pci-containers-on-pcs/

* Copy .env.example to have a '.env' environnement file into the project root directory:
> sudo cp ../ovh-pci-containers-on-pcs/.env.example .env

* Edit the '.env' file environnement with your server configuration nedded:
> sudo nano ../ovh-pci-containers-on-pcs/.env

* Save the '.env' file typing [CTRL+X] and [y]


# Usage :
* Use the differents scripts located into /distrib##/ directories to configure step by step your instance, by example (for debian10):

> ./debian10/install-pci.sh -h        # for prepare your PCI

> ./debian10/install-pcs.sh -h        # for install your PCS (attach your volume with ovh manager after)

> ./debian10/install-docker.sh -h     # for install docker and docker-compose in your PCI

> ./debian10/install-webproxy.sh -h   # for install container webproxy in your PCS

> ./debian10/install-wordpress.sh -h   # for install container wordpress in your PCS

> ./debian10/install-nextcloud.sh -h   # for install container nextcloud in your PCS

* OR, use the autoinstall script for all-in-one configuration (make you sure to have correctly edited the '.env' file after!!!) :
> ./auto-install.sh

# Have fun!

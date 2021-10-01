#! /bin/bash

#THIS SCRIPT ONLY PROVIDES FUNCTIONALITY FOR CREATING LINUX-SERVERS

#Preconfigured servers are created with the script-author's recommended values for RAM,CPU,HardDrive etc.
#If you want to change these preconfigured values, then edit the script.
#Script connects to default Network and uses default securitygroup.

# Variables
InstanceName=""
InstanceImage=""
FlavorID=""
KeyPair=""
AvailaZone=""
Count=""
FloatIP=""
check=""
PreconfigChoice=""

echo "Welcome to the Openstack Instance script."

. files/aw222zr-1dv031-vt19-openrc.sh

echo "Choose which type of instance you would like to create/delete:"
echo "Enter 1 for server"
echo "Enter 2 for router"
echo "Enter 3 for network and subnet"
echo "Enter 4 to create a standard setup for the assignment"
read check

#Create/Delete server:
if [ "$check" == "1" ]; then
	#Ask if wants to print already available servers:
	echo "If you would like to print available servers, enter 1. Otherwise push enter."
	read check
	if [ "$check" == "1" ]; then
		openstack server list
	fi
	check=""

	#Ask if want to delete server:
	echo "If you would like to delete a server, enter 1. If you would like to create a server, press enter."
	read check
	if [ "$check" == "1" ]; then
		while [ "$serverDelete" != "1" ]; do
			openstack server list
			serverDelete=""
			echo "If you would like to delete a server, enter the server's name."
			echo  "To exit the deletion of servers, enter 1"
			read serverDelete
			if [ "$serverDelete" != "1" ]; then
				openstack server delete "$serverDelete"
			fi
		done
	exit
	fi
	check=""

	#Ask if wants to customize server:
	echo "To customize your server from scratch, enter 1. To choose from a preconfigured list, push enter."
	read check
	if [ "$check" == "1" ]; then
		#List the customizable options:
		openstack image list
		echo "Enter the ImageID:"
		read InstanceImage
		while [ -z "$InstanceImage" ]; do
			echo "Enter the ImageID:"
			read InstanceImage
		done

		openstack flavor list
		echo "Enter the FlavorID:"
		read FlavorID
		while [ -z "$FlavorID" ]; do
			echo "Enter the FlavorID:"
			read FlavorID
		done

		openstack availability zone list
		echo "Enter the Zone Name:"
		read AvailaZone
		while [ -z "$AvailaZone" ]; do
			echo "Enter the Zone Name:"
			read AvailaZone
		done
	else
		#List the preconfig options:
		echo "Enter which Preconfigured server to create:"
		echo "Ubuntu minimal 18.04 = enter 1 - Ram 1GB, HD 10GB, 1CPUs"
		echo "Ubuntu 16.04 = enter 2 - Ram 2GB, HD 20GB, 1CPUs"
		echo "Ubuntu 18.04 = enter 3 - Ram 2GB, HD 20GB, 2CPUs"
		echo "CentOS 7 = enter 4 - Ram 2GB, HD 20GB, 2CPUs"
		echo "Debian 9 = enter 5 - Ram 8GB, HD 80GB, 4CPUs"
		while [ -z "$PreConfigChoice" ]; do
			read PreConfigChoice
		done
	fi
	check=""

	#Ask for which KeyPair to use:
	echo "If you want to choose which SSH-key you would like to use, enter 1. To use the default KeyPair, push enter."
	read check
	if [ "$check" == "1" ]; then
		server keypair list
		echo "enter the name of the keypair that you would like to use:"
		read KeyPair
	else
		KeyPair='aw222zr-1dv031_Keypair'
	fi
	check=""


	if [ "$PreConfigChoice" == "1" ]; then
		#Ubuntu-Minimal 16.04:
		InstanceImage="1b20a5d7-8ec1-4c2e-af0e-6175d361b680"
		FlavorID="c1-r1-d10"
		AvailaZone="Education"
	elif [ "$PreConfigChoice" == "2" ]; then
		#Ubuntu-Server 16.04:
		InstanceImage="ae802a6e-89d0-4a6c-978a-5004ece6cf73"
		FlavorID='c1-r2-d20'
		AvailaZone='Education'
	elif [ "$PreConfigChoice" == "3" ]; then
		#Ubuntu-Server 18.04:
		InstanceImage="dec4c641-2949-4857-b31f-822a1567e233"
		FlavorID="c2-r2-d20"
		AvailaZone="Education"
	elif [ "$PreConfigChoice" == "4" ]; then
		#CentOS 7
		InstanceImage="95cf7ac7-c364-43da-a57a-9a6348d1dd16"
		FlavorID="c2-r2-d20"
		AvailaZone="Education"
	elif [ "$PreConfigChoice" == "5" ]; then
		#Debian 9
		InstanceImage="775d1058-c61a-452f-9ac1-c8dbe43eca34"
		FlavorID="c4-r8-d80"
		AvailaZone="Education"
	fi

	#Ask how many instances to create:
	echo "Enter how many instances of the server you would like to create:"
	read count
	countCheck=0

	while [ $count -gt $countCheck ]; do
		#First ask for name of server:
		while [ -z "$InstanceName" ]; do
			echo "Set the ServerName:"
			read InstanceName
		done

		# Create the server:
		openstack server create --image "$InstanceImage" --flavor "$FlavorID" --key-name "$KeyPair" --availability-zone "$AvailaZone" 		"$InstanceName" > "$InstanceName".txt

		#Ask if want to see server info:
		echo "To print the created server's info to terminal, enter 1. Otherwise push enter."
		read check
		if [ "$check" == "1" ]; then
			cat "$InstanceName".txt
		fi
		rm "$InstanceName".txt
		check=""
		let "countCheck++"

		#Ask if want to set a floating-IP:
		echo "To connect a floating-IP to the server, enter 1. Otherwise push enter."
		read check
		if [ "$check" == "1" ]; then
			check=""
			openstack floating ip list
			echo "To create a new Floating-IP, enter 1. To not set a Floating-IP, enter 2.
To set an already created IP, press enter."
			read check
			if [ "$check" == "1" ]; then
				openstack network list
				echo "Enter the name for network to be provided with a Floating IP"
				networkName=""
				read networkName
				openstack floating ip create "$networkName"
				echo "To set this IP to the server, enter it below:"
				read FloatIP
				openstack server add floating ip "$InstanceName" "$FloatIP"
			elif [ "$check" == "2" ]; then
				echo
			else
				echo "To set an IP to the server, enter it below:"
				read FloatIP
				openstack server add floating ip "$InstanceName" "$FloatIP"
			fi
			check=""
		fi
	FloatIP=""
	InstanceName=""
	check=""
	done
	countCheck=""

	#Ask if want to see complete serverlist:
	echo "If you would like to print all current servers, enter 1. To exit program, push enter."
	read check
	if [ "$check" == "1" ]; then
		openstack server list
	fi
check=""
fi

routerName=""
externalNetName=""
subName=""

#Create Router:
if [ "$check" == "2" ]; then
	check=""

	echo "To delete a router enter 1. To create a router enter 2."
	read check
	if [ "$check" == 2 ]; then
		echo "Enter name for the router:"
		read routerName
		openstack network list
		echo "Enter the name of the router's external Network:"
		read externalNetName
		openstack subnet list
		echo "Enter the name of the router's subnet:"
		read subName

		openstack router create "$routerName"
		#Set external gateway:
		openstack router set --external-gateway "$externalNetName" "$routerName"
		openstack router add subnet "$routerName" "$subName"
	fi

	if [ "$check" == 1 ]; then
		openstack router list
		echo "Enter the name of the router to delete. Push 'ctrl+c' to not delete"
		read routerName
		openstack subnet list
		echo "Remove the routers subnet:"
		read subnetName
		openstack router remove subnet "$routerName" "$subnetName"
		openstack router delete "$routerName"
	fi
check=""
fi

networkName=""
subnetRange=""
subnetRangeAllocationStart=""
subnetRangeAllocationEnd=""
ipVersion=""
subnetName=""
gateway=""

#Create Network:
if [ "$check" == "3" ]; then
	check=""

	echo "To delete network, enter 1. To create network enter 2."
	read check

	if [ "$check" == "2" ]; then
		echo "Enter the name for the network:"
		read networkName
		openstack network create "$networkName"

		echo "Enter name for subnet:"
		read subnetName

		echo "Enter ipVersion(4 or 6):"
		read ipVersion

		echo "Enter IP of gateway:"
		read gateway

		echo "Enter subnet-range: (example: 192.168.0.1/24)"
		read subnetRange

		echo "Enter where to start allocation of IP-addresses: (Example: 192.168.0.2)"
		read subnetRangeAllocationStart

		echo "Enter where to end allocation of IP-addresses: (Example: 192.168.0.15)"
		read subnetRangeAllocationEnd

		#Add subnet:
		openstack subnet create --subnet-range "$subnetRange" --ip-version "$ipVersion" --network "$networkName" --gateway "$gateway" --allocation-pool start="$subnetRangeAllocationStart",end="$subnetRangeAllocationEnd" "$subnetName"
	fi

	while [ "$check" == "1" ]; do
		openstack network list
		echo "Enter name of the network to delete. To not delete a network, push 'ctrl+c'"
		read networkName
		openstack network delete "$networkName"
		echo "To delete another network, enter 1. To exit, enter 2."
		read check
	done
check=""
fi

#Setup assignment infrastructure
if [ "$check" == "4" ]; then

	echo "To delete the openstack setup, enter 1. To recreate the setup, enter 2."
	read check

	if [ "$check" == 1 ]; then
		echo "Are you sure that you want to delete the servers,routers,networks?"
		echo "Then enter 'yes', else push 'ctrl+c'"
		read check
		if [ "$check" == "yes" ]; then
			openstack server delete ns1
			openstack server delete ns2
			openstack server delete Apache_Server
			openstack server delete Nginx-LoadBalance
			openstack server delete node_js_1
			openstack server delete node_js_2
			openstack router remove subnet Router_PubConn ACME_DMZ_Subnet
			openstack network delete ACME_DMZ_Network
			openstack router delete Router_PubConn
		fi
	fi

	if [ "$check" == 2 ]; then
		#Create main network:
		openstack network create ACME_DMZ_Network

		#Add subnet to main network:
		openstack subnet create --subnet-range 192.168.0.0/24 --ip-version 4 --network ACME_DMZ_Network --gateway 192.168.0.1 --allocation-pool start=192.168.0.2,end=192.168.0.15 ACME_DMZ_Subnet

		#Create router
		openstack router create Router_PubConn

		#Set external gateway:
		openstack router set --external-gateway public Router_PubConn
		openstack router add subnet Router_PubConn ACME_DMZ_Subnet

		#Create server instances:
		echo "Creating Apache Server"
		openstack server create --image ae802a6e-89d0-4a6c-978a-5004ece6cf73 --flavor c1-r2-d20 --key-name aw222zr-1dv031_Keypair --availability-zone Education Apache_Server
		echo "Creating Nginx Server"
		openstack server create --image ae802a6e-89d0-4a6c-978a-5004ece6cf73 --flavor c1-r2-d20 --key-name aw222zr-1dv031_Keypair --availability-zone Education Nginx-LoadBalance
		echo "Creating ns1 Server"
		openstack server create --image ae802a6e-89d0-4a6c-978a-5004ece6cf73 --flavor c1-r2-d20 --key-name aw222zr-1dv031_Keypair --availability-zone Education ns1
		echo "Creating ns2 Server"
		openstack server create --image ae802a6e-89d0-4a6c-978a-5004ece6cf73 --flavor c1-r2-d20 --key-name aw222zr-1dv031_Keypair --availability-zone Education ns2
		echo "Creating Node.JS_1 Server"
		openstack server create --image ae802a6e-89d0-4a6c-978a-5004ece6cf73 --flavor c1-r2-d20 --key-name aw222zr-1dv031_Keypair --availability-zone Education node_js_1
		echo "Creating Node.JS_2 Server"
		openstack server create --image ae802a6e-89d0-4a6c-978a-5004ece6cf73 --flavor c1-r2-d20 --key-name aw222zr-1dv031_Keypair --availability-zone Education node_js_2
		echo "Infrastructure for assignment created."
	fi
check=""
fi

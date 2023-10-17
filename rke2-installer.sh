#!/bin/bash
echo ''
echo 'This script will install RKE2'
echo 'In order to install RKE2 the config.yaml file must be in folder /root' 
echo ''
echo ''
sleep 3

#Check if RKE2 is already installed
echo 'First, let me check if RKE2 is already installed'
sleep 3

if [ "$(systemctl status rke2-server.service | grep -E active\|activating -c)" = 1 ]; then
    read -rp 'RKE2 already seems to be installed. Would you like to reinstall it? (y/N)' reinstall
    case $reinstall in
        [yY] )      echo ''
                    echo 'RKE2 will be resinstalled'
                    echo '/usr/local/bin/rke2-uninstall.sh'
                    sleep 3
                    /usr/local/bin/rke2-uninstall.sh
                    sleep 3;;

        [nN] )      echo 'RKE2 will not be reinstalled. Exiting.'
                    exit;;

        * )         echo invalid response
                    echo 'Exiting'
                    exit;;
    esac
else
    echo 'RKE2 dosent seem to be installed. Continuing'
    sleep 3
fi


#Check for config file 
echo ''
echo 'Checking for config.yaml in /root'
echo 'ls -l /root/*config.yaml* '
ls -l /root/*config.yaml* 


#Moving config into folder, if it exists
if [ "$(ls -l /root | grep config.yaml -c)" -ge 1 ]; then
    mkdir -p /etc/rancher/rke2
    cp /root/config.yaml /etc/rancher/rke2
else
    echo ''
    echo 'No config.yaml file in /root found. An example config.yaml can be found here: https://docs.rke2.io/install/configuration#configuration-file'
    echo 'Exiting'
    exit
fi
sleep 3


#List Folder
echo ''
echo 'The config file will be moved to /etc/rancher/rke2'
echo 'ls -l /etc/rancher/rke2'
ls -l /etc/rancher/rke2
sleep 3

#View Config
echo ''
echo ''
echo 'The following config will be used: '
echo 'cat /etc/rancher/rke2/config.yaml'
cat /etc/rancher/rke2/config.yaml
echo ''

sleep 3

#Check for correct config
while true; do
    read -rp "Is the config correct? (y/N) " input

    case $input in
        [yY] )      
                    var="1"  #var installation=true
                    echo ''
                    #Get installer
                    curl -sfL https://get.rke2.io | sh -            

                    #Enable systemctl Service
                    systemctl enabel rke2-server.service            

                    #Start Servic in background
                    systemctl start rke2-server.service & 
                    
                    break
                    echo '';;

        [nN] )      
                    var="0" #var installation=false
                    echo ''
                    echo 'Please provide the correct config.yaml in folder /root'
                    echo 'Exiting'
                    exit;;

        * )         echo invalid response;;
    esac
done

#Check if Logs want to be viewed live
if [ "$var" = 1 ]; then
    echo 'The installation has begun.'
    echo 'To view the installation log, run the following command: journalctl -u rke2-server'
    while true; do
        read -rp 'Would you like to follow the log right now? (Y/n) ' follow
        case $follow in
            [yY] )  journalctl -u rke2-server -f;;
            [nN] )  echo 'Exiting'
                    exit;;
            * )         echo invalid response;;
        esac
    done
fi



#EOF
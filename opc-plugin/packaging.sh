#!/bin/bash

FILE1=Dockerfile
FILE2=opcPlugin.py
FILE3=package_config.ini
FILE4=requirements.txt
if [ -f "$FILE1" -a -f "$FILE2" -a -f "$FILE3" -a -f "$FILE4" ]; then
	echo "$FILE1"
	echo "$FILE2"
	echo "$FILE3"
        echo "$FILE4"
	echo "are present. Commencing packaging"
        docker build -t iox-opcua-app:1.0 .
        rm -rf iox-opc-aarch64 && mkdir iox-opc-aarch64
        docker save -o rootfs.tar iox-opcua-app:1.0
        mv rootfs.tar iox-opc-aarch64/
else
	echo "One or more of the files not present. Cannot create container"
fi

echo 'descriptor-schema-version: "2.7"

info:
  name: "iox_opc_app_no_mqtt"
  description: "OPC/UA test"
  version: "1.0"
  author-link: "http://www.cisco.com"
  author-name: "CSAP Tiger Team"

app:
  cpuarch: "aarch64"
  type: "docker"
  resources:
    profile: c1.tiny
    disk: 5
    network:
      - interface-name: eth0
        ports: {}

  startup:
    rootfs: rootfs.tar
    target: ["python3","/opcPlugin.py"]' > package.yaml

mv package.yaml iox-opc-aarch64/
cp package_config.ini iox-opc-aarch64
ioxclient package iox-opc-aarch64
echo 'IOx Application Package tar file created. Ready to upload to Cisco Kinetic GMM'

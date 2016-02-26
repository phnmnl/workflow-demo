
OPENMS_CMAKE_FILE="`wget -qO- 'https://raw.githubusercontent.com/OpenMS/OpenMS/master/src/topp/executables.cmake'
`"


IFS=$'\n' read -rd '' -a split_CMAK <<< "$OPENMS_CMAKE_FILE"
control=0

echo $control
for i in "${split_CMAK[@]}"; do
     #echo "$i"
        if [[ $i == ")" ]]
                then
                        control=0
        fi

	if [[ $control -eq 1 ]]
                then
			if [ ! -d "$i" ]; then
                        	echo "Creating directory for \"$i\""
				mkdir $i
			fi
			echo "Setting the Entry Point to \"$i\""
			entryPoint=$i
			echo "Preparing docker information"
			DockerData="FROM ubuntu:14.04\nMAINTAINER Payam Emami, payam.emami@medsci.uu.se\nRUN apt-get update && apt-get install --yes openms\nENTRYPOINT [\"$entryPoint\"]"
			echo "writing Dokcer file"
			echo -e  $DockerData > $i/Dockerfile
			(cd $i && exec docker build -t "payamemami/"${i,,} .)
			echo "A docker has been created for \"$i\""
			echo "Pushing to Docker hub"
			docker login --username=payamemami --email=payam.emami@medsci.uu.se --password=***
			docker push "payamemami/"${i,,}
			echo "Creating \"readme\" File"
			readmeData="#A Docker container for \"$i\" tool in OpenMS\nFor more information about the tool please visit:\nhttp://ftp.mi.fu-berlin.de/pub/OpenMS/documentation/html/TOPP_$i.html"
			echo -e  $readmeData > $i/README.md
			echo "************"
        fi
	if [[ $i == "set(TOPP_executables" ]]
		then
			control=1
	fi
done

#!/bin/bash

# Color theming
if [ -f ~/clouddrive/aspnet-learn/deploy/k8s/theme.sh ]
then
  . <(cat ~/clouddrive/aspnet-learn/deploy/k8s/theme.sh)
fi

echo
echo "Building images to ACR"
echo "======================"

if [ -f ~/clouddrive/aspnet-learn-temp/create-acr-exports.txt ]
then
  eval $(cat ~/clouddrive/aspnet-learn-temp/create-acr-exports.txt)
fi

pushd /src/deploy/k8s > /dev/null

if [ -z "$ESHOP_REGISTRY" ] || [ -z "$ESHOP_ACRNAME" ]
then
    echo "One or more required environment variables are missing:"
    echo "- ESHOP_REGISTRY.: $ESHOP_REGISTRY"
    echo "- ESHOP_ACRNAME..: $ESHOP_ACRNAME"
    exit 1
fi

while [ "$1" != "" ]; do
    case $1 in
        --services) shift
                    services=$1
                    ;;
             * )    echo "Invalid param: $1"
                    exit 1
    esac
    shift
done

echo
echo "Building and publishing docker images to $ESHOP_REGISTRY"

# This is the list of {service}:{image}>{dockerfile} of the application
appServices=$(cat ./build-to-acr.services)

if [ -z "$services" ]
then
    serviceList=$(echo "${appServices}" | sed -e 's/:.*//')
else
    serviceList=${services//,/ }
fi

pushd ../..  > /dev/null

for service in $serviceList
do
    line=$(echo "${appServices}" | grep "$service:")
    tokens=(${line//[:>]/ })
    service=${tokens[0]}
    image=${tokens[1]}
    dockerfile=${tokens[2]}

    echo
    echo "Building image \"$image\" for service \"$service\" with \"$dockerfile.acr\"..."
    serviceCmd="az acr build -r $ESHOP_ACRNAME -t $ESHOP_REGISTRY/$image:linux-latest -f $dockerfile.acr ."
    echo "${newline} > ${azCliCommandStyle}$serviceCmd${defaultTextStyle}${newline}"
    eval $serviceCmd
done
    
popd  > /dev/null

popd  > /dev/null

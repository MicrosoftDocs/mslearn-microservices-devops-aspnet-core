#!/bin/bash

# Color theming
if [ -f ~/clouddrive/aspnet-learn/deploy/k8s/theme.sh ]
then
  . <(cat ~/clouddrive/aspnet-learn/deploy/k8s/theme.sh)
fi

echo "Deleting service principal(s)..."

while IFS= read -r appId
do
    echo "${newline} > ${azCliCommandStyle}az ad sp delete --id $appId${defaultTextStyle}${newline}"
    az ad sp delete --id $appId
done < <(az ad sp list --show-mine --query "[?contains(displayName,'eshop-learn-sp')].appId" --output tsv)

echo "Done!"
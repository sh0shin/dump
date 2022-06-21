#!/usr/bin/env bash
# vim: set ft=sh :

RES_EX='()'

echo "---"

terraform plan -out plan.zip

echo "---"
echo

readarray -t TF_RES < <( terraform show -json plan.zip | jq -r '.resource_changes[] | .address +"::"+ ( .change.actions | join("") )' )

for RES in "${TF_RES[@]}"
do
  RES_NAME="${RES%%::*}"

  if [[ "$RES" =~ ::create$ ]]
  then
    if [[ "$RES_NAME" =~ $RES_EX ]]
    then
      echo "skipping $RES_NAME"
      continue
    fi

    echo
    echo "$RES_NAME"
    read -r -p "import value: " RES_VAL

    if [[ -n "$RES_VAL" ]]
    then
      echo terraform import "$RES_NAME" "$RES_VAL"
      echo
    else
      echo "skipping $RES_NAME"
      echo
    fi
  fi
done

rm -f plan.zip

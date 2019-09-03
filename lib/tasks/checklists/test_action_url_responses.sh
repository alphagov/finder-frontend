#Basic BASH script that ensures that each URL linked to on the Actions page
#from the Actions yaml is a valid link responding with 200
link_list=($(awk 'BEGIN {OFS = ":"; ORS = "\n" } /http/ { print $2 }' ./lib/checklists/actions.yaml))

echo $(realpath ../../)
#Rejects duplicates so we don't end up pinging the same site multiple times
uniq_link_list=($(printf "%s\n" "${link_list[@]}" | sort -u))

echo '\nRunning check of all links found in actions.yaml for 200:OK status'
echo 'This may take some time...'

final_status="OK\n"
for i in "${uniq_link_list[@]}"
do
   :
  status=$(curl -s -o /dev/null -w '%{http_code}' $i)
  if [ $status != '200' ]; then
    echo $i ":" $status ": FAIL"
    final_status='FAIL'
  fi
done

echo $final_status
if [ $final_status != 'FAIL' ]; then
  exit 0
fi
exit 1

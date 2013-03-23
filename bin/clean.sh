echo "Pruning attributes in Advanced environment"
knife environment from file "./environments/advanced.json" > /dev/null

NODES=$( knife exec -E 'nodes.all { |n| puts n.name if n.name.match(".*?dbapp|java.*") }' )
for n in $NODES; do
  if [ "${n}" = "" ] ; then 
    continue 1
  fi

  echo Deleting client, node and vagrant instance [$n]

  knife client delete "${n}" --yes
  knife node delete "${n}" --yes

  vagrant_n=($(echo "${n}" | tr '-' "\n")) 
  vagrant destroy "${vagrant_n[1]}" --force

done

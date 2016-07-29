#! /bin/bash
cd $(dirname $0)
for line in $(grep -v '^#' ./domains);
 do
  ./update_trusted_source.sh $line $1
 done
exit


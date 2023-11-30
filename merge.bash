#!/bin/bash

for i in subsample/* ; do
  s=$(basename "$i")
  [[ "$s" == *"count95.tsv" ]] && continue
  echo $s
  Table.merge.pl -n "$i"/* | sort -n > "rarefaction/${s}.tsv"  
done



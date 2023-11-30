#!/bin/bash

if true; then
  echo -e "sample\tstrains_fit\tstrains_lwr\tstrains_upr"
  while read LN ; do
    val=($LN)
    echo ${val[0]} >&2
    echo -ne "${val[0]}\t"
    ./project.R ${val[0]} ${val[1]} \
      | tail -n 1 \
      | awk 'BEGIN { OFS="\t" } {print $2,$3,$4}'
  done < "subsample/count95.tsv"
fi > "rarefaction/projection.tsv"


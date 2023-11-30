#!/bin/bash

for i in *.blast ; do
  [[ -s "${i}.id993" ]] && continue
  echo $i
  awk '$3 >= 99.3' < "$i" \
    | perl -pe 's/(Isolate_[^_]+)_\S+/$1/' \
    > "${i}.id993"
done


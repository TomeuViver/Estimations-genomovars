#!/bin/bash

STRAINS=$1
BLAST=$2

TMP=$(mktemp -d)
trap "rm -rf '$TMP'" EXIT

cp "$BLAST" "$TMP/blast.txt"
shuf "$STRAINS" > "$TMP/list.txt"
echo "Q" >> "$TMP/list.txt"

while [[ $(wc -l < "$TMP/list.txt") -gt 1 ]] ; do
  head -n -1 < "$TMP/list.txt" > "$TMP/list.tmp"
  mv "$TMP/list.tmp" "$TMP/list.txt"

  Table.filter.pl -k 2 -n "$TMP/list.txt" "$TMP/blast.txt" > "$TMP/blast.tmp"
  mv "$TMP/blast.tmp" "$TMP/blast.txt"

  echo -ne "$(wc -l < "$TMP/list.txt" | awk '{print $1}')\t"
  cut -f 1 < "$TMP/blast.txt" | sort | uniq | wc -l | awk '{print $1}'
done


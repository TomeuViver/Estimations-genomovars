#!/bin/bash

(cd CORE_GENES && ./preproc.bash)

for i in CORE_GENES/PH1_*_CORE.blast.id993 ; do
  sample=$(basename "$i" _CORE.blast.id993 | perl -pe 's/^PH1_//')
  [[ -d "subsample/$sample" ]] && continue

  echo $sample
  mkdir "subsample/$sample"
  qsub -v "sample=$sample" subsample.pbs
done


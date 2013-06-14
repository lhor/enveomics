#!/bin/bash

##################### RUN
# Find the directory of the pipeline
PDIR=$(dirname $(readlink -f $0));
# Load variables
source "$PDIR/RUNME.bash"
if [[ "$SCRATCH" == "" ]] ; then
   echo "$0: Error loading $PDIR/RUNME.bash, variable SCRATCH undefined" >&2
   exit 1
fi

# Run it
echo "Jobs being launched in $SCRATCH"
RAMMULT=${RAMMULT:-1}
for LIB in $LIBRARIES; do
   # Prepare info
   echo "Running $LIB";
   K_VELVET=$(echo $K_VELVET | sed -e 's/ /:/g')
   K_SOAP=$(echo $K_SOAP | sed -e 's/ /:/g')
   if [[ "$USECOUPLED" == "yes" ]] ; then
      INPUT="$DATA/$LIB.CoupledReads.fa"
   elif [[ "$USESINGLE" == "yes" ]] ; then
      INPUT="$DATA/$LIB.SingleReads.fa"
   else
      echo "$0: Error: No task selected, neither USECOUPLED nor USESINGLE set to yes." >&2
      exit 1;
   fi
   let SIZE=$(ls -l "$INPUT" | awk '{print $5}')/1024/1024/1024;
   let RAM=3+$SIZE*30*$RAMMULT;
   VARS="LIB=$LIB,PDIR=$PDIR,BIN454=$BIN454,KVELVET=$K_VELVET,KSOAP=$K_SOAP"
   # Launch Newbler
   NAME="Newbler_${LIB}"
   qsub "$PDIR/newbler.pbs" -v "$VARS" -d "$SCRATCH" -N "$NAME" -l nodes=1:ppn=$PPN -l mem=$RAM -l walltime=12:00:00
done

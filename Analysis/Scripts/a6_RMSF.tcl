#!/bin/bash
# Shane E Gordon
# v1.0
# Mon Feb  3 12:34:31 EST 2014

# Set your variables here
# Should be fairly self explanatory
STRING="equil"
IDIR="a1_ProteinOnly"
VMDDIR="/usr/local/vmd/1.9.1/bin/vmd"
RMSF_FOLDER="RMSF"

# Safety checks
if [ -d ${IDIR} ];
then 
        echo "${IDIR} directory exists. Proceeding";
else
        echo "Need to create the ${IDIR} directory first!";
        exit
fi
sleep 2

# Safety check for the RMSD output folder
if [ -d $RMSF_FOLDER ]
then
        rm -r $RMSF_FOLDER
        mkdir $RMSF_FOLDER
        echo "Directory '$RMSF_FOLDER' already exists! Cleared folder."
else
        mkdir $RMSF_FOLDER
        echo "Directory '$RMSF_FOLDER' has been created"
fi
sleep 2

# The meat and bones
cd ${IDIR}
for DIR in ${STRING}*dcd; 
do (
        # Just a hack to remove ".dcd" from the end of the string $DIR
        TruncDIR=`echo ${DIR} | sed -r 's/.dcd//'`;
        TruncDIR2=`echo ${DIR} | sed -r 's/.[0-9][0-9].dcd//'`;
        echo "****Now processing ${TruncDIR}*****"; 
        $VMDDIR ${TruncDIR2}*.psf ${TruncDIR}*.dcd -dispdev text -e ../Analysis/Tools/rmsf.tcl;
        mv RMSF.output.dat ../${RMSF_FOLDER}/${TruncDIR}.rmsf.dat
        );
done
cd ..

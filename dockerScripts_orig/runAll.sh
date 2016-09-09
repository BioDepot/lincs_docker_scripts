#!/bin/sh
UMIdir=$1         #Working directory where everything will be calculated
programsDir=$2    #where the programs are stored
referencesDir=$3  #where the modified human reference and associated files are stored
seqsDir=$4        #where the fastq sequences to be aligned are stored
configsDir=$5     #where configs and info regarding dataset are stored
paramsDir=$6      #where parameters regarding the dataset are stored
scriptsDir=$7     #where dockerScripts are stored i.e. this script

if (($# != 7))
 then 

  echo "Required parameters are:
        UMIDir        -where everything will be calculated 
        programsDir   -where the programs are stored
        referencesDir -where the modified human reference and associated files are stored
        seqsDir       -where the fastq sequences to be aligned are stored
        configsDir    -where configs and info regarding dataset are store
        paramsDir     -where parameters regarding the dataset are stored
	scriptsDir    -where dockerScripts are stored i.e. this script
        "
 exit 1
fi
echo service docker start
service docker start

echo "mkdir -p $UMIdir/Aligns $UMIdir/Counts $UMIdir/Results"
mkdir -p $UMIdir/Aligns $UMIdir/Counts $UMIdir/Results
echo "cp $configsDir/*.txt $UMIdir/Counts/." 
cp $configsDir/*.txt $UMIdir/Counts/.

echo "docker run --rm --name=dtoxs$$ \
 -v $referencesDir:/root/LINCS/References/Broad_UMI \
 -v $programsDir:/root/LINCS/Programs/Broad-DGE \
 -v $UMIdir:/root/LINCS \
 -v $scriptsDir:/root/LINCS/DockerScripts\
 -v $seqsDir:/root/LINCS/Seqs\
 -v $configsDir:/root/LINCS/Configs\
 -v $UMIdir/Results:/root/LINCS/Results\
 -v $paramsDir:/root/LINCS/Params\
  biodepot/dtoxs_alignment /bin/bash -c '/root/LINCS/DockerScripts/run-alignment-analysis.sh &> /root/LINCS/Results/log'"

  docker run --rm --name=dtoxs$$ \
 -v $referencesDir:/root/LINCS/References/Broad_UMI \
 -v $programsDir:/root/LINCS/Programs/Broad-DGE \
 -v $UMIdir:/root/LINCS \
 -v $scriptsDir:/root/LINCS/DockerScripts\
 -v $seqsDir:/root/LINCS/Seqs\
 -v $configsDir:/root/LINCS/Configs\
 -v $UMIdir/Results:/root/LINCS/Results\
 -v $paramsDir:/root/LINCS/Params\
  biodepot/dtoxs_alignment /bin/bash -c '/root/LINCS/DockerScripts/run-alignment-analysis.sh &>/root/LINCS/Results/log'

echo "docker run --name=dtox_analysis --rm \
-v $UMIdir/Counts:/home/user/Counts -v $UMIdir/Results:/home/user/Results \
-v $configsDir:/home/user/Configs -v $paramsDir:/home/user/Params \
biodepot/dtoxs_analysis sh -c \
'Rscript /home/user/Programs/Extract-Gene-Expression-Samples.R /home/user/Counts && \
Rscript Programs/Compare-Molecule-Expression.R Configs/Configs.LINCS.Dataset.Gene.LINCS.20150409.tsv . Programs/'"

docker run --name=dtox_analysis$$ --rm \
 -v $UMIdir/Counts:/home/user/Counts -v $UMIdir/Results:/home/user/Results \
 -v $configsDir:/home/user/Configs -v $paramsDir:/home/user/Params \
 biodepot/dtoxs_analysis sh -c \
 'Rscript /home/user/Programs/Extract-Gene-Expression-Samples.R /home/user/Counts && \
 Rscript Programs/Compare-Molecule-Expression.R Configs/Configs.LINCS.Dataset.Gene.LINCS.20150409.tsv . Programs/'

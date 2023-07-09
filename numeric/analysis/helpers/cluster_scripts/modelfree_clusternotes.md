# Steps for ddm fitting using state space

## Complete model fitting code

`yn_ddm.R`: Model definition (trial simulation and likelihood functions)  
`fit_yn_ddm.R`: Task likelihood computation functions
`sim_yn_ddm.R`: Task simulation functions
`optim_yn_ddm.R`: Parameter optimization functions
`grid_search_yn_ddm.R`: Grid search over parameters functions

## Create docker image

```
d:
set STUDY_DIR="D:\OneDrive - California Institute of Technology\PhD\Rangel Lab\2023-gain-loss-attention"
cd %STUDY_DIR%\numeric\analysis\helpers\cluster_scripts

docker build -t brendeneum/modelfreeanalysis:0.0.1 -f ./modelfreeanalysis.Dockerfile .
```

## Check image exists

```
docker images
```

## Push docker image to dockerhub

```
docker push brendeneum/modelfreeanalysis:0.0.1
```


## Test scripts in container locally

Note: Remove `-it` from docker command when submitting jobs

Model free analysis sections for aDDM papers.
(Basic Psychometrics, Fixation Process, Choice Biases)

```
set STUDY_DIR="D:\OneDrive - California Institute of Technology\PhD\Rangel Lab\2023-gain-loss-attention"
set INPUT_PATH=%STUDY_DIR%\numeric\data\processed_data\e
set CODE_PATH=%STUDY_DIR%\numeric\analysis\helpers\modelfreeanalysis
set OUT_PATH=%STUDY_DIR%\numeric\analysis\outputs\temp
set POPT_PATH=%STUDY_DIR%\numeric\analysis\helpers\plot_options
cd %CODE_PATH%

docker run --rm -it -v %INPUT_PATH%:/input -v %CODE_PATH%:/code -v %OUT_PATH%:/out -v %POPT_PATH%:/popt -e INPUT_PATH=/input -e CODE_PATH=/code -e OUT_PATH=/out -e POPT_PATH=/popt brendeneum/modelfreeanalysis:0.0.1 Rscript --vanilla code/ModelFreeAnalysis.R --data cfr.RData
```

aDDM analysis sections for aDDM papers.
(aDDM)

```
set PALETTE_PATH=%STUDY_DIR%\dots\analysis\helpers\modelfreeanalysis
set CODE_PATH=%STUDY_DIR%\dots\analysis\helpers\aDDM
cd %CODE_PATH%

docker run --rm -it -v %INPUT_PATH%:/input -v %CODE_PATH%:/code -v %OUT_PATH%:/out -v %PALETTE_PATH%:/palette -e INPUT_PATH=/input -e CODE_PATH=/code -e OUT_PATH=/out -e PALETTE_PATH=/palette brendeneum/modelfreeanalysis:0.0.1 Rscript --vanilla code/AddmAnalysis.R --data 2022-MAP-indiv.RData
```

## Push behavior files to S3

```
export INPUTS_DIR=/Users/zeynepenkavi/Documents/RangelLab/NovelVsRepeated/behavior/inputs

docker run --rm -it -v ~/.aws:/root/.aws -v $INPUTS_DIR:/inputs amazon/aws-cli s3 cp /inputs/data_choiceYN.csv s3://novel-vs-repeated/behavior/inputs/data_choiceYN.csv

docker run --rm -it -v ~/.aws:/root/.aws -v $INPUTS_DIR:/inputs amazon/aws-cli s3 cp /inputs/ddm_grid.csv s3://novel-vs-repeated/behavior/inputs/ddm_grid.csv

docker run --rm -it -v ~/.aws:/root/.aws -v $INPUTS_DIR:/inputs amazon/aws-cli s3 cp /inputs/ddm_grid_test.csv s3://novel-vs-repeated/behavior/inputs/ddm_grid_test.csv
```

## Push cluster setup and model fitting scripts to s3

```
export STUDY_DIR=/Users/zeynepenkavi/Documents/RangelLab/NovelVsRepeated
cd $STUDY_DIR

docker run --rm -it -v ~/.aws:/root/.aws -v $(pwd)/behavior/analysis/helpers/ddm:/behavior/analysis/helpers/ddm amazon/aws-cli s3 sync /behavior/analysis/helpers/ddm s3://novel-vs-repeated/behavior/analysis/helpers/ddm --exclude "*.DS_Store"

docker run --rm -it -v ~/.aws:/root/.aws -v $(pwd)/behavior/analysis/helpers/cluster_scripts/ddm:/behavior/analysis/helpers/cluster_scripts/ddm amazon/aws-cli s3 sync /behavior/analysis/helpers/cluster_scripts/ddm s3://novel-vs-repeated/behavior/analysis/helpers/cluster_scripts/ddm --exclude "*.DS_Store"
```

## Make key pair for `rddmstatespace-cluster`

```
export KEYS_PATH=/Users/zeynepenkavi/aws_keys

alias aws='docker run --rm -t -v ~/.aws:/root/.aws amazon/aws-cli:2.11.26'

aws ec2 create-key-pair --key-name rddmstatespace-cluster --query 'KeyMaterial' --output text > $KEYS_PATH/rddmstatespace-cluster.pem

chmod 400 $KEYS_PATH/rddmstatespace-cluster.pem

aws ec2 describe-key-pairs
```

## Create cluster config using `make_rddmstatespace_cluster_config.sh`

```
export STUDY_DIR=/Users/zeynepenkavi/Documents/RangelLab/NovelVsRepeated

cd $STUDY_DIR/behavior/analysis/helpers/cluster_scripts/ddm/

sh make_rddmstatespace_cluster_config.sh
```

## Create cluster using the config

```
cd $STUDY_DIR/behavior/analysis/helpers/cluster_scripts/ddm/

pcluster create-cluster --cluster-name rddmstatespace-cluster --cluster-configuration tmp.yaml

pcluster list-clusters
```

## Connect to cluster

```
export KEYS_PATH=/Users/zeynepenkavi/aws_keys
pcluster ssh --cluster-name rddmstatespace-cluster -i $KEYS_PATH/rddmstatespace-cluster.pem
```

## Copy the behavioral data from s3 to cluster

```
export DATA_PATH=/shared/behavior/inputs

aws s3 sync s3://novel-vs-repeated/behavior/inputs $DATA_PATH --exclude '*' --include 'data_choiceYN.csv' --include 'ddm_grid.csv' --include 'ddm_grid_test.csv'
```

## Copy model fitting code from s3 to cluster

```
export CODE_PATH=/shared/behavior/analysis/helpers

aws s3 sync s3://novel-vs-repeated/behavior/analysis/helpers/ddm $CODE_PATH/ddm

aws s3 sync s3://novel-vs-repeated/behavior/analysis/helpers/cluster_scripts/ddm $CODE_PATH/cluster_scripts/ddm
```

## Test fitting on single subject on head node

Grid search

```
export INPUT_PATH=/shared/behavior/inputs
export CODE_PATH=/shared/behavior/analysis/helpers/ddm
export OUT_PATH=/shared/behavior/analysis/helpers/cluster_scripts/ddm/grid_search_out

docker run --rm -it -v $INPUT_PATH:/inputs -v $CODE_PATH:/ddm -v $OUT_PATH:/grid_search_out \
-e INPUT_PATH=/inputs -e CODE_PATH=/ddm -e OUT_PATH=/grid_search_out \
zenkavi/rddmstatespace:0.0.1 Rscript --vanilla /ddm/grid_search_yn_ddm.R --model yn_ddm --subnum 621 --day 4 --type RE --grid ddm_grid_test.csv
```

Optim

```
export INPUT_PATH=/shared/behavior/inputs
export CODE_PATH=/shared/behavior/analysis/helpers/ddm
export OUT_PATH=/shared/behavior/analysis/helpers/cluster_scripts/ddm/optim_out

docker run --rm -it -v $INPUT_PATH:/inputs -v $CODE_PATH:/ddm -v $OUT_PATH:/optim_out \
-e INPUT_PATH=/inputs -e CODE_PATH=/ddm -e OUT_PATH=/optim_out \
zenkavi/rddmstatespace:0.0.1 Rscript --vanilla /ddm/optim_yn_ddm.R --model yn_ddm --subnum 619 --day 5 --type RE --testing 1 --max_iter 10
```

## Submit jobs for levels 1s of all subjects and sessions for both tasks

Only a few examples listed below

```
cd /shared/behavior/analysis/helpers/cluster_scripts/ddm/

sh run_grid_search_yn_ddm.sh -s 611 -t HT -d 5
sh run_optim_yn_ddm.sh -s 601 -t RE -d 4
```

## Push outputs back to s3

```
export OUT_PATH=/shared/behavior/analysis/helpers/cluster_scripts/ddm/grid_search_out
aws s3 sync $OUT_PATH s3://novel-vs-repeated/behavior/analysis/helpers/cluster_scripts/ddm/grid_search_out

export OUT_PATH=/shared/behavior/analysis/helpers/cluster_scripts/ddm/optim_out
aws s3 sync $OUT_PATH s3://novel-vs-repeated/behavior/analysis/helpers/cluster_scripts/ddm/optim_out
```

## Exit out of cluster ssh and delete cluster

```
exit
pcluster delete-cluster --cluster-name rddmstatespace-cluster
pcluster list-clusters
```

## Download fitted parameters

```
export OUTPUTS_DIR=/Users/zeynepenkavi/CpuEaters/NovelVsRepeated/behavior/analysis/helpers/cluster_scripts/ddm

docker run --rm -it -v ~/.aws:/root/.aws -v $OUTPUTS_DIR:/outputs amazon/aws-cli s3 sync s3://novel-vs-repeated/behavior/analysis/helpers/cluster_scripts/ddm/grid_search_out /outputs/grid_search_out

docker run --rm -it -v ~/.aws:/root/.aws -v $OUTPUTS_DIR:/outputs amazon/aws-cli s3 sync s3://novel-vs-repeated/behavior/analysis/helpers/cluster_scripts/ddm/optim_out /outputs/optim_out
```
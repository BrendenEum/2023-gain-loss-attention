# Steps for preprocessing the PsychoPy data

## Complete preprocessing code

`cleanPsychopyData.R`: Cleans the data for each individual subject and saves as cfr_subjectNumber.

## Pull the modelfreeanalysis docker image from Brenden's dockerhub.

```
docker pull brendeneum/modelfreeanalysis:0.0.1
```

## For some reason, if that docker image doesn't exist, then create it yourself.

```
d:
set STUDY_DIR="D:\OneDrive - California Institute of Technology\PhD\Rangel Lab\2023-gain-loss-attention"
cd %STUDY_DIR%\numeric\analysis\helpers\cluster_scripts

docker build -t brendeneum/modelfreeanalysis:0.0.1 -f ./modelfreeanalysis.Dockerfile .
```

## Check image exists.

```
docker images
```

## Push docker image to dockerhub.

```
docker push brendeneum/modelfreeanalysis:0.0.1
```

## Run scripts in container locally

```
set STUDY_DIR="D:\OneDrive - California Institute of Technology\PhD\Rangel Lab\2023-gain-loss-attention"
set INPUT_PATH=%STUDY_DIR%\numeric\data\raw_data\good
set CODE_PATH=%STUDY_DIR%\numeric\analysis\preprocessing
set OUT_PATH=%STUDY_DIR%\numeric\data\processed_data\e
cd %CODE_PATH%

docker run --rm -it -v %INPUT_PATH%:/input -v %CODE_PATH%:/code -v %OUT_PATH%:/out -e INPUT_PATH=/input -e CODE_PATH=/code -e OUT_PATH=/out brendeneum/modelfreeanalysis:0.0.1 Rscript --vanilla code/cleanPsychopyData.R
```
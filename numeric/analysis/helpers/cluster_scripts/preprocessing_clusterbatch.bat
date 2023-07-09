set STUDY_DIR="D:\OneDrive - California Institute of Technology\PhD\Rangel Lab\2023-gain-loss-attention"
set INPUT_PATH=%STUDY_DIR%\numeric\data\raw_data\good
set CODE_PATH=%STUDY_DIR%\numeric\analysis\preprocessing
set OUT_PATH=%STUDY_DIR%\numeric\data\processed_data\e
cd %CODE_PATH%

docker run --rm -it -v %INPUT_PATH%:/input -v %CODE_PATH%:/code -v %OUT_PATH%:/out -e INPUT_PATH=/input -e CODE_PATH=/code -e OUT_PATH=/out brendeneum/modelfreeanalysis:0.0.1 Rscript --vanilla code/cleanPsychopyData.R
set STUDY_DIR="D:\OneDrive - California Institute of Technology\PhD\Rangel Lab\2023-gain-loss-attention"
set INPUT_PATH=%STUDY_DIR%\numeric\data\processed_data\e
set CODE_PATH=%STUDY_DIR%\numeric\analysis\helpers\modelfreeanalysis
set OUT_PATH=%STUDY_DIR%\numeric\analysis\outputs\temp
set POPT_PATH=%STUDY_DIR%\numeric\analysis\helpers\plot_options
cd %CODE_PATH%

docker run --rm -it -v %INPUT_PATH%:/input -v %CODE_PATH%:/code -v %OUT_PATH%:/out -v %POPT_PATH%:/popt -e INPUT_PATH=/input -e CODE_PATH=/code -e OUT_PATH=/out -e POPT_PATH=/popt brendeneum/modelfreeanalysis:0.0.1 Rscript --vanilla code/ModelFreeAnalysis.R --data cfr.RData
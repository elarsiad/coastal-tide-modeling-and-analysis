# Tidal Forecast Project 

## Description

This project contains Matlab scripts to predict and validate tidal levels.

`download_data_awl_api.m` downloads the water level data from the marine automated weather station and use these as an input to forecast the tides.

`forecast_tides.m` performs harmonic analysis on observed tidal data to extract tidal constants, and uses these to predict tides for a future month.

`verification.m` loads predicted and observed tidal data for the same time period and compares them to calculate error statistics. 

## Usage

- Update configuration settings in scripts:
  - Station name, location
  - Months for analysis, prediction, validation
  - Time zone
  - Paths to data files
- Run `forecast_tides.m` to generate tidal predictions
- Run `verification.m` to validate predictions against observations
- Review output plots and statistics

## Input Data

- `data_awl_Batam_Agustus_2020.xlsx`: Sample observed water level data for August to forecast tides for September
- `data_awl_Batam_September_2020.xlsx`: Sample observed water level data for September to forecast tides for October

## Output Data

- Tidal constants saved to `konstanta_harmonik_Batam_Agustus.mat`
- Prediction plots and spreadsheet saved to files like `Prediksi Pasang Surut Sepetember 2020.xlsx` 
- Validation plots like `Perbandingan data Prediksi dan Observasi Batam September 2020.jpg`

## Requirements

- MATLAB
- Tidal analysis toolbox: https://www.eoas.ubc.ca/~rich/#T_Tide

## Credits

Marine Meteorological Center, BMKG Headquarter 

## License

Usage allowed for academic research and education purposes.
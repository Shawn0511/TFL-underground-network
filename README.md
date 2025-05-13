# TFL-underground-network: 

Exploring and Modelling Passenger Flow and crowding in the London Underground Network (pre- and post-COVID)

This repository analyses nine years of Transport for London (TFL) datasets to explore changes in London Underground passenger flows and crowding using multiple **Transport for London (TfL)** datasets (2016–2023), with a focus on:
- Pre- vs. post-COVID demand trends and flags potentially overcrowded origin–destination (OD) links
- Crowding patterns at stations and OD links with netwrok visualisation
- K-means Clustering and predictive modelling of overcrowding using XGBoost


---


## Project Summary

The Full summary report of this project, with all visualisations and analysis:
**[read the summary here »](Summary_report.md)**

A one-page reflective summary is available in:
[`summary/01382316-math70076-assessment-2-summary.pdf`](summary/01382316-math70076-assessment-2-summary.pdf)

For detailed results, see:
[`Output/`](Output/) — all key plots and visualisations

---


## What’s in the Analysis?

The study addresses three main questions:
1. **How has crowding changed pre- and post-COVID?**  
2. **Which OD links and stations are persistently crowded?**  
3. **Can we predict overcrowded links using machine learning?**

Key results include:
- Exploratory Data Analysis for Annual Station Counts pre-COVID & post-COVID
- Top OD pairs and stations by demand or crowding (NUMBAT 2023)
- Network visualisations using chord diagrams
- Station clustering by time-of-day entry patterns
- XGBoost model achieving AUC ≈ 0.99 for crowding alerts


---

## Data Sources

The data can be found and downloaded from the TFL website:
[tfl_open data](https://tfl.gov.uk/info-for/open-data-users/) and
[tfl_crowding.data](https://crowding.data.tfl.gov.uk/).

The downloaded data can also be found here:
- **NUMBAT dataset** (2016–2023): Link-level passenger volumes, station entries/exits, train frequency
    Data/Raw/NUMBAT/
    Data/Raw/Network_Demand/
- **Annual Station Counts**: 2017–2023 raw XLSXS and filtered CSVS
    Data/Raw/Annual_Station_Counts/
    Data/filtered/filtered_csv/Annual_Station_Counts/
- **Network_Demand** (2019–2025): EntryTapCount, ExitTapCount, TubeJourneyCount
    Data/Raw/Network_Demand/
    Data/filtered/Network_Demand/

Scripts assume a local `Data/Raw/NUMBAT/` folder structure or can use the library(here).

---

## Additional Resources (Tube map and train seat information)

- Tube maps: `Tube_map/`
- Train seat capacity data: `Train_seat_capacity/`

---


## Reproducibility Instructions

To reproduce the full pipeline:

1. Open the project in RStudio via `TFL-underground-network.Rproj`
2. Install required packages listed in [`Required_Packages.txt`](Required_Packages.txt)
3. Run the master script:  
   ```r
   source("Code/R/NUMBAT/Main.R")
4. Run the R script for EDA plot of stationfootball and Annual_Station_Counts:
   ```r
   source("Code/R/Stationfootball/Stationfootball.R")
   source("Code/R/Annual_Station_Counts/Annual_Pre_Covid_2017_2019.R")
   source("Code/R/Annual_Station_Counts/Annual_Post_Covid_2021_2023.R")

---


## NUMBAT Data Analysis Structure

| Script              | Purpose                                                                 |
|---------------------|-------------------------------------------------------------------------|
| `00-config.R`       | Set paths, day labels, line colours                                     |
| `01-load.R`         | Load and clean TfL/NUMBAT Excel files                                   |
| `02-process.R`      | Reshape data, create helper functions                                   |
| `03-eda.R`          | Generate exploratory data plots                                         |
| `04-network.R`      | Create chord network diagrams                                           |
| `05-model.R`        | Run clustering + train XGBoost crowding model                           |
| `Main.R`            | Full pipeline runner (sources all scripts)                             |


---

Outputs (plots, diagnostics, model results) will be saved under:

Output/Stationfootball_output/
Output/Annual_Station_Counts_output
Output/NUMBAT_output


---

##  Exploratory Data Analysis (EDA)

- Trends in tap-in/out volumes across day types and years

- Pre/Post COVID changes in station rankings and volume distributions

- Passenger load trends by line and period (e.g., AM/PM peaks)

##  OD Demand and Crowding

- OD flows analysed by time-of-day and train load (passengers per train)

- Chord diagrams and bar plots highlight persistent demand corridors

## Crowding Prediction Model

A binary classification model was trained to identify OD links with high load factors.  
See code: [`05-model.R`](05-model.R)

  - Features: Δ% demand, prior load factor, total passenger volume
  - Classifier: `XGBoost` (AUC ≈ 0.9864)
  - Output: SHAP feature importance plots


---

## Suggested Next Steps
[Details are included in:](Summary_report.md)
Future development could include:
- Real-time crowding alerts  
- Network resilience simulation  
- Passenger segmentation (e.g. commuters vs tourists)

---

## License

This project is released under the MIT License. (See [LICENSE](LICENSE.txt))
For data access and reuse, consult TfL's [open data license](https://tfl.gov.uk/info-for/open-data-users/) and [crowding.data](https://crowding.data.tfl.gov.uk/).



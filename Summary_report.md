## Table of Contents

- [Introduction](#tfl-underground-network)
- [Key Questions Answered](#key-questions-answered)
- [Exploratory Data Analysis (StationFootball)](#exploratory-data-analysis-for-network-demand-stationfootball-dataset)
- [Annual Station Counts Analysis](#exploratory-data-analysis-for-annual-station-counts-pre-covid--post-covid-dataset)
- [NUMBAT Dataset Analysis](#exploratory-data-analysis-for-numbat-datasets)
- [Clustering & Modelling](#clustering--modelling-for-numbat-datasets-od-crowding-and-station-demand-patterns)
- [Crowding Prediction Model](#crowding-prediction-model-using-xgboost)
- [Limitations](#limitations)
- [Future Research Suggestions](#future-research-suggestions)
- [Conclusion](#conclusion)




# TFL-underground-network
Exploring and Modelling Passenger Flow in the London Underground Network

This repository analyses nine years of Transport for London (TFL) datasets to show where and when crowding happens and to train a model that flags potentially overcrowded origin–destination (OD) links.

---

## Key questions answered

1. **How has crowding on rail links evolved pre-COVID-19 and post-COVID-19?**  
2. **Which OD links and stations are persistently crowded?**  
3. **can we predict which origin–destination (OD) links will be critically crowded in the near term?**

---

> The one-page reflective summary is included in `summary/01382316-math70076-assessment-2-summary.pdf`.


## Exploratory Data Analysis for Network Demand Stationfootball dataset

The time series plot of daily total entry and exit tap counts across the entire network from 2019 to 2025 is shown below, It reflects that a sharp drop in demand occurs in early 2020, corresponding to the COVID-19 lockdowns. A gradual recovery is observed from late 2020 to 2023. For the period of Post-2022, the ridership level seems to plateau but does not yet fully reach pre-pandemic levels.

![image](https://github.com/user-attachments/assets/89f7cb9b-44c3-40dc-a9d1-09f5a8384d13)

The yearly entry Tap-in trends below include each year from 2019 to 2025.
- 2019 appears stable and representative of a pre-COVID year.
- 2020 displays an abrupt collapse in demand after day ~70 (March), with a very low baseline for the rest of the year.
- 2021–2022 show recovery phases, but lower peak values and greater variability persist.
- 2023 and 2024 display much more consistent volumes, though still slightly below 2019.
- 2025 (partial data) shows a solid start, but it can be observed that the post-COVID years' overall tap-in is lower than the pre-COVID year, which might be the reason for the increase in hybrid working mode.

![image](https://github.com/user-attachments/assets/4dccd438-5c49-4d39-9036-94f8ddb3af04)



## Exploratory Data Analysis for Annual Station Counts Pre-COVID & Post-COVID dataset

**Top 20 Busiest Stations per Year (Pre-COVID & Post-COVID)**
The two plots below show the top 20 stations by annual volume for each year. Each subplot ranks stations within the year, and the x-axis is fixed to help the comparison of passenger volumes.
- 2017–2019: The top stations are consistently King’s Cross St. Pancras, Oxford Circus, Victoria, Waterloo, and Liverpool Street. The ordering remains stable, which reflects established commuter hubs in Central London.
- 2021–2023: While the same core stations dominate, Tottenham Court Road, Farringdon, and Brixton LU begin to rise in rank, which likely reflects shifts in travel demand and recovery patterns.
- Post-COVID changes: Firstly, the impact of the Elizabeth Line opening is visible in rising ranks for Farringdon and Tottenham Court Road. It is noted that the central section of the Elizabeth line from Paddington to Abbey Wood opened to passengers on 24 May 2022, which connects regions to the east and west of London through the central area and the London Docklands. Secondly, the overall volumes increase from 2021 to 2023, showing recovery from the pandemic since the lockdown.

![image](https://github.com/user-attachments/assets/eadb56a3-f618-479e-b3f4-a7475ed294dd)
![image](https://github.com/user-attachments/assets/d1e04e07-0d87-4034-aff2-37365ce74cf0)

**Annual Passenger Volume Distribution by Year**
The histograms below show the distribution of station annual volumes for each year. It can be observed that:
- 2017–2019: The distribution is symmetric and unimodal, with a large concentration of stations around 10⁶–10⁷ entries/exits annually.
- 2021–2023: The distribution flattens in 2021 due to suppressed demand and lockdown, but gradually recovers in 2022–2023. However, it still shows that there is right-skewness in 2021, which indicates fewer stations with high footfall. Such an issue of heavier tails on the lower end and slightly shifted left, which reflects reduced demand and the uneven pace of recovery across stations.
- These plots highlight how COVID-19 disrupted the volume distribution, creating more heterogeneity and dampened peaks that recover gradually. It can be concluded that 2021–2023 demand remains lower and more dispersed compared to pre-COVID, with slower recovery for some stations.

![image](https://github.com/user-attachments/assets/5432d336-be1e-4491-9bdf-96a5d6dd1f9b)
![image](https://github.com/user-attachments/assets/6f31a888-1d52-4ec9-a227-1b36cb915bec)

**Top 10 Tap-in/Out Imbalance Stations**
The Net Tap-in vs Tap-out imbalance bar plot below visualises stations with the largest net imbalance between tap-ins (entries) and tap-outs (exits). Imbalances  can help identify stations that serve predominantly as entry-only or exit-only hubs, which reveal commuter nodes, residential areas, or tourist hotspots. Oxford Circus, Green Park, and Covent Garden show large negative imbalances (more exits), which suggests that these are destination stations for work, shopping, and tourism. Stations like London Bridge, Bank and Monument, and Finsbury Park exhibit positive imbalance (more entries), which reflects that these stations have a strong commuter base or transfer hub behaviour.
And it is noticed that there are some new addition stations like Seven Sisters and Walthamstow Central, suggesting suburban stations gained relative importance. It is possible that this reflects changes in work-from-home patterns and reduced reliance on Central London hubs for post-COVID period.

![image](https://github.com/user-attachments/assets/5ce7f91c-9123-4570-b85a-1a8eb1c2b398)
![image](https://github.com/user-attachments/assets/a788364c-4355-4fe6-880f-c6403c658a35)

**Network-wide Daily Demand**

The following plots show the total number of passengers entering and exiting the system across different day types (Mon–Thu, Friday, Saturday, Sunday).
- Pre-COVID (2017–2019):
  - Mon–Thu is the busiest, consistent with traditional workweek commuting.
  - Friday is slightly lower, suggesting early leave trends or hybrid working.
  - Saturday matches or exceeds Friday in some years (strong leisure travel).
  - Sunday is the lowest, which is as expected.
- Post-COVID (2021–2023):
  - Weekday volumes remain highest, and the difference between Friday and Saturday narrows.
  - Friday commuting has declined (hybrid work increased after COVID-19).
  - Weekend usage is stabilising (tourism or retail-driven).
  - The post-COVID period entry and exit volumes are still very balanced, which indicates no major system-level directional bias.
![image](https://github.com/user-attachments/assets/677c3529-59a9-4cd7-8c97-d8616245de0f)
![image](https://github.com/user-attachments/assets/f7a78777-abb2-43c2-8ef8-5e791846dc07)


**Weekday vs Weekend Passenger Volume (Scatter Plot)**

The following scatter plots compare total weekday volume vs weekend volume for each station. It provides insight into station-level demand symmetry and it can have conclusions as below:
- Pre-COVID (2017–2019):
  - Strong positive correlation between weekday and weekend usage.
  - Major stations like King’s Cross, Oxford Circus, and Victoria are the highest in both dimensions.
  - Most stations cluster close to the origin, which reflects low overall traffic, while central hubs are far outliers.

- Post-COVID (2021–2023):
  - The correlation remains as pre-COVID, but several top stations (e.g., King’s Cross, Waterloo) appear disproportionately high on weekends, which suggests tourism and leisure have regained traction faster.
  - Stratford is a key interchange and retail hub, which rises in the post-COVID plot, aligning with the growing importance of multi-modal stations.

![image](https://github.com/user-attachments/assets/c405db53-05a0-4747-9d8f-67406780fdd4)
![image](https://github.com/user-attachments/assets/7621374d-dfd5-44d0-8844-8f81bec36f21)



**Total Volume by Transport Mode**

LU (London Underground) dominates both periods, accounting for the majority of the total passenger volume. LO (London Overground) is the second most used mode in both time periods, and DLR consistently follows LO as third. TFL Rail appears as a distinct mode but is replaced by EZL (Elizabeth Line).

There is a clear drop in total volume across all modes in 2021–2023 compared to 2017–2019, which reflects the lingering impact of the COVID-19 pandemic. The emergence of EZL (Elizabeth Line) post-2022 shows how the system evolved structurally, with new services contributing to the recovery. The emergence and expansion of the Elizabeth Line post-2022 illustrate how network planning and infrastructure investment have played an important role. The operation of the Elizabeth Line not only introduces new capacity but also helps alleviate congestion on previously overcrowded lines, such as the Central and Jubilee lines.

![image](https://github.com/user-attachments/assets/34235372-16f3-434c-80e0-13404921e806)
![image](https://github.com/user-attachments/assets/8f5f5ec9-0aaa-4e87-89c9-bdac972c5140)

**K-means Clustering of Stations Based on Demand**

Additionally, it also investigated K-means clustering of stations based on demand for the pre- and post-COVID period. Stations are grouped into 3 clusters based on tap-in and tap-out demand across entry/exit days, the principal component (PC1) explains most of the variance in both periods (>97%). The three clusters are designed as below:
- Cluster 1 (red): It typically contains high-demand, high-variability stations, like Stratford, Victoria LU, Paddington TfL, Waterloo LU.
- Cluster 3 (blue): It represents a large group of low-demand or stable-demand stations.
- Cluster 2 (green): It covers a moderate or mixed group, sometimes including central or interchange stations like Bank, Liverpool Street, London Bridge.

When comparing pre- (2017–2019) and post-COVID period (2021–2023), it can be summarised into two main conclusions:
1. The post-COVID period shows a more compact spread
  - Reduced variability across stations.
  - Possibly more homogenised travel behaviour due to the obvious conversion of working mode (remote work or other behavioural shifts).
2. Some stations shifted between clusters, which indicates changes in their functional role:
  - Leicester Square and Moorgate show relative repositioning, which is possibly due to changes in tourism or commuting patterns, it also possibly due to the operation of the Elizabeth Line
  - Stratford station remained an outlier in both periods, which confirms its role as a key interchange hub.

Clustering indicates functional similarities among stations. It can be summarised that the post-pandemic recovery appears uneven, with some stations bouncing back strongly while others remain subdued. These analyses and insights are valuable for resource allocation.

![image](https://github.com/user-attachments/assets/8fb5ce3b-8911-47f4-8870-2606d24a2732)
![image](https://github.com/user-attachments/assets/f80806de-b69c-4f9d-9b37-ac2b5d57646e)


## Exploratory Data Analysis for NUMBAT datasets

This study dissects nearly a decade of Transport for London data to answer two questions: **How has crowding on rail links evolved before, during and after COVID‑19?** and **Can we predict which origin–destination (OD) links will be critically crowded in the near‑term?**
It used the **NUMBAT** (2016‑2023) dataset, which includes origin-destination (OD) link flows,  OD passenger volumes, station-level entries/exits, and train frequencies across multiple years for every Underground, Overground, DLR and Elizabeth Line link (2016–2023). The goal is to understand post-COVID ridership trends, detect overcrowded links, and compare them to the pre-COVID period. Additionally, it also tries to develop a crowding-alert model using XGBoost.
A modular R pipeline loads, cleans and standardises all sheets, applies TFL colour‑coding, and computes derived metrics such as passengers‑per‑train and station flow. EDA layers summarise the “shape” of demand by line, period, day and year; tidygraph & ggraph power chord diagrams of the busiest links.

## NUMBAT Analysis Pipeline

The NUMBAT analysis pipeline separates scripts by functionality:

| Script         | Purpose                                                                              |
|----------------|--------------------------------------------------------------------------------------|
| `00-config.R`  | Centralises all global constants (paths, days, line colours, etc.)                   |
| `01-load.R`    | Manages loading of raw Excel files and helper function                               |
| `02-process.R` | Processes and reshapes data; write helper function for later use                     |
| `03-eda.R`     | Contains visualisation functions for exploratory analysis (EDA)                      |
| `04-network.R` | Contains network and graph-based plotting functions (Chord network diagrams)         |
| `05-model.R`   | Implements clustering analysis and develops a crowding-alert model using XGBoost     |
| `Main.R`       | Sources all modular scripts and runs the full workflow                               |


# TFL colour palette for each line (The colour code for each line aligns with the actual)
tube_line_colors <- c(
  Bakerloo               = "#B36305",
  Central                = "#E32017",
  DLR                    = "#00AFAD",
  District               = "#00782A",
  `Elizabeth Line`       = "#6950A1",
  `H&C and Circle`       = "#F3A9BB",
  Jubilee                = "#A0A5A9",
  `LO East London`       = "#EE7C0E",
  `LO Gospel Oak-Barking`= "#EE7C0E",
  `LO North London`      = "#EE7C0E",
  `LO Romford–Upminster` = "#EE7C0E",
  `LO Watford-Euston`    = "#EE7C0E",
  `LO West Anglia`       = "#EE7C0E",
  `London Trams`         = "#84B817",
  Metropolitan           = "#9B0056",
  Northern               = "#000000",
  Piccadilly             = "#003688",
  Victoria               = "#0098D4",
  `Waterloo & City`      = "#95CDBA"
)

Due to the rich Dataset from 2016-2023 for NUMBAT, it is hard to investigate in detail. The plots below mostly focus on the recent year 2023, and subsequently, with some matrix plots across different years.

**Top 5 OD (origin–destination) Pairs per Time Period (2023)**
This plot reflects  time-specific commuting patterns by OD pair:
  - Early: Predominantly East London pairs (e.g., Forest Gate → Maryland), possibly capturing early shifts and some dispersed patterns.
  - AM Peak: Strong north-south flow (e.g., Euston → Warren Street), which indicates the commuter influx to central and office zones.
  - Midday: Repeats some peak OD pairs, implying off-peak retention of flow along the same corridors (Euston ↔ Warren).
  - Evening/Late: Possible leisure-oriented flows emerge (e.g., Gloucester Road → Earl's Court), showing more dispersed patterns.

![image](https://github.com/user-attachments/assets/aecba4f5-26a2-4097-abba-e72c5ac77d31)


**Top 20 origin-destination (OD) pairs by total passenger volume (2023)**

The bar plot below highlights the most heavily trafficked OD pairs across the network.
  - The top OD pairs (e.g., Whitechapel ↔ Liverpool Street LU, Liverpool Street ↔ Farringdon) primarily lie on the Elizabeth Line and Central London interchanges.
  - Many connections involve adjacent or closely spaced stations, which suggests high intra-zone mobility. This is possibly due to intermodal transfers or short commutes.
  - Bidirectional travel between some key nodes (e.g., Warren Street ↔ Oxford Circus, Euston ↔ Warren Street) shows symmetric high flow, which reinforces these stations are key interchange corridors.

Such OD analysis supports targeted crowd management, especially along the Elizabeth and Victoria line spines.

![image](https://github.com/user-attachments/assets/3fb52fc8-bd8d-42f8-8c15-ac41509cb738)


**Top 20 most crowded OD links based on passengers per train (2023)**
![image](https://github.com/user-attachments/assets/55551758-74f9-4553-86df-57ffbae8c1e6)


**Top 20 stations with highest combined entries and exits (2023)**

![image](https://github.com/user-attachments/assets/4cf6ccaf-0255-4ae5-9830-b931702cbe08)


**Passenger Load by Line-period across days**

The plots below summarise passenger load by line and period across day types in 2023 and across years (2016–2023).
1. Passenger Load by Line & Period (2023 across Day Types)
 - Weekdays: There is an obvious and classic AM peak and PM peak demand that persists. **Elizabeth, Central, Jubilee, and Victoria lines** dominate in both peak and off-peak flows. Friday demand is slightly lower than TWT/MON, likely due to hybrid work policies or early departures.
 - Weekends: Demand shifts from peak-focused to midday-focused travel patterns. The midday period becomes the busiest, which suggests more leisure and discretionary travel. The **Elizabeth Line** continues to show strong usage, even on weekends (it reflects its multi-purpose appeal). Lines like **District, Jubilee, and DLR** also exhibit strong weekend presence, which is possibly due to serving tourist destinations.

The day-type breakdown highlights the behavioural differences in ridership that are important for service planning. While weekday patterns are driven by work and school routines, weekends reflect recreational and non-commuting purposes, which require different scheduling and frequency strategies. And it is worth mentioning that the continued strength of the Elizabeth Line across all days reaffirms its role as a backbone line in the post-COVID transit network.

2. Passenger Load by Line & Period (2016–2023) (only focus on weekday period)
 - Pre-COVID Patterns (2016–2019): **Central, Northern, Jubilee, and Victoria lines** show the highest volumes, especially during peak periods. And the volume is fairly stable year-to-year, with minor seasonal or operational variations.
 - Pandemic Impact (2020–2021): 2020 shows a dramatic collapse in volume across all lines and periods due to COVID-19. The **District, Jubilee, and Central lines** show the most visible drops, which are possibly due to their link with office-heavy zones.
 - Post-COVID Recovery (2022–2023): It shows a gradual rebound in demand, especially on the Elizabeth Line (operated since 2022). The overall volumes remain lower than pre-COVID levels, though the structure of peak periods is recovering. And it noted that the Elizabeth Line became prominent by 2023, which indicates rapid uptake and importance in relieving overcrowding on older lines.

This longitudinal plot clearly reveals the structural and behavioural impact of the COVID-19 pandemic on urban mobility. Importantly, the rise of the Elizabeth Line represents a shift in the network topology and commuting corridors (TfL, 2023b).

![image](https://github.com/user-attachments/assets/f27d2a98-cf4d-4fb3-9bfe-f1675050d048)
![image](https://github.com/user-attachments/assets/f193dfdb-735a-4d1a-8e21-196223e35e02)


**Compare total passenger demand by Tube line across different years**

The following chart tracks the total annual flow per line, which shows the evolution of usage intensity. It can be observed that the **Northern, Central, Jubilee, and Victoria lines** dominate consistently. The launch of the **Elizabeth Line** shows rapid ascent, which overtakes several legacy lines by 2023.

![image](https://github.com/user-attachments/assets/0a7a42c1-381e-4369-bc26-e953cbf8a6dc)


**Network visualisation: Chord network diagrams**

The chord diagrams were constructed using R, based on the NUMBAT OD flow dataset, which provides origin–destination (OD) passenger counts between stations across various time periods.

  - Chord Diagram – EARLY
Flow is heavily radial, with inbound motion toward central London (e.g., King’s Cross, Oxford Circus). Early Elizabeth Line usage indicates demand from outer London commuters starting work early.

  - Chord Diagram – AM PEAK
Dense flows cluster along Victoria, Elizabeth, and Central lines, which reflect typical white-collar commuting corridors into Zone 1.

  - Chord Diagram – MIDDAY
Flow becomes more dispersed, the tourist and discretionary travel become significant. This volume shift supports TfL's strategic midday service boost to mitigate crowding (TfL, 2022).

  - Chord Diagram – PM PEAK
Return flows become dominant. Strong Eastbound and Northbound outbound OD flows suggest residential dispersal.

  - Chord Diagram – LATE
The flows are fewer than in other periods and more localised. This suggests local nightlife, leisure, or late-shift commuters. In addition, the operation windows have also been reduced.

  - Chord Diagram – TOTAL
Overall, the most critical OD flows across all periods are: Oxford Circus → Warren Street, Whitechapel → Liverpool Street, King’s Cross → Euston. These arcs appear in nearly all time-period diagrams, which suggests persistent all-day demand. It validates them as high-priority corridors for capacity planning and crowd control measures.

![Rplot05](https://github.com/user-attachments/assets/19cc70aa-62ca-456a-82ae-0640ee797091)
![Rplot06](https://github.com/user-attachments/assets/e4254dae-1d2c-44dd-85f7-9ee027c73006)
![Rplot07](https://github.com/user-attachments/assets/3c777845-81ef-4179-8242-6c5a671cf9d3)
![Rplot08](https://github.com/user-attachments/assets/a6659f5d-5291-401e-bc47-609383ac3a2a)
![Rplot09](https://github.com/user-attachments/assets/cd9befc5-2856-4d4f-85a5-6ec81f5cc061)
![total](https://github.com/user-attachments/assets/67436c4b-7038-48e9-9a0f-faee291aefa6)



## Clustering & Modelling for NUMBAT datasets: OD Crowding and Station Demand Patterns

To better understand and manage overcrowding on the London Underground, it applied analysis of unsupervised clustering and supervised machine learning techniques (XGBOOST) to the NUMBAT dataset. It aimed to uncover structure in station-level and OD-level demand patterns, identify key sources of crowding in the post-COVID period, and develop predictive models to anticipate future congestion risks.

It first conducted K-means clustering on the top 75% most crowded origin-destination (OD) pairs using total passenger volume and passengers per train as features. It helps to classify OD pairs into distinct groups that share similar usage and capacity strain characteristics. It also used hierarchical clustering to group stations based on their entry profiles across time of day, which reveals common temporal usage patterns (e.g., strong commuting peaks, steady off-peak flow etc).


Based on these insights and previous EDA, it can developed an XGBoost-based binary classifier to predict which OD links are likely to experience crowding in the future. The model was trained on a variety of engineered features that capture both temporal and structural changes between pre-COVID (2019 MTT) and post-COVID (2023 TWT) conditions, which include percentage change in demand, previous load factors, and total passenger counts.

The clustering reveals where and when structural crowding patterns emerge, while the XGBoost model provides a scalable tool for real-time crowding alerts and proactive capacity planning.

##  Clustering OD Pairs by Crowding (K-means, k=3)

The following scatter plot applies k-means clustering (k=3) on the top 75% of OD pairs ranked by crowding (passengers per train), which used scaled features for 'total_passengers' and 'passengers_per_train'. The goal is to identify natural groupings in high-demand segments and detect patterns in travel intensity and overcrowding.

The three clusters are:

  - Cluster 1 (red): High total demand with moderate crowding. These OD pairs (e.g. Oxford Circus → Warren Street) are the critical central segments, which typically with balanced operations but intense usage.
  - Cluster 2 (green): OD pairs with high crowding (high passengers per train), despite they does not having the highest total flows. Often indicates short trips (e.g. Farringdon → Liverpool Street LU).
  - Cluster 3 (blue): Lower-demand, lower-crowding pairs, which represent either less central routes or well-serviced ones with sufficient capacity.


![image](https://github.com/user-attachments/assets/d86526e5-f07d-4e3d-a9d4-6572617e25b8)


##  Hierarchical Clustering of Stations by Time-of-Day Profiles

It used hourly entry profiles (station × time_bin) here, and it performed hierarchical clustering to group stations with similar temporal patterns. The dendrogram reveals the natural hierarchical structure, while the second line chart summarises average profiles for each cluster.

The four clusters used here are:

- Cluster 4 (purple): Obvious dual-peak (AM & PM peak), high entry volumes. Typical of major commuter hubs (e.g. Oxford Circus, Waterloo LU).
- Cluster 3 (blue): Moderate peak alignment, flatter midday activity. It is likely mixed-use or interchange stations.
- Cluster 2 (green): Mild peaks and higher baseline throughout, which could reflect residential or peripheral stations.
- Cluster 1 (red): Low activity throughout the day, which is likely low-traffic stations.


![Rplot10](https://github.com/user-attachments/assets/8f85fb14-b00f-4372-91ac-d121df153882)
![image](https://github.com/user-attachments/assets/962efd9f-7b72-4e13-9161-66d5c82e3dd7)



##  Crowding Prediction Model Using XGBoost

To proactively predict crowding risk on OD links based on changing travel patterns between pre- and post-COVID periods. 
Target: Binary indicator of overcrowded links based on the top 10% load factor percentile.

It constructed a labelled dataset using the 'make_link_delta()' function between pre- and post-COVID NUMBAT datasets for weekdays.
It defined the target variable as a binary indicator of high load factor (>90th percentile).

Trained using OD-level features: percentage change in demand ('pct_delta'), load factor (pre/post), total passengers, and line encoded numerically.

Model Training
  - Used XGBoost (binary:logistic) with stratified 80/20 train-test split.
  - Performed 5-fold cross-validation with early stopping for tuning.
  - After hyperparameter tuning, the best hyperparameters are used:
      - 'eta = 0.1', 'max_depth = 5'
      - 'nrounds = 44'
      - AUC on held-out set: 0.9864

Evaluation:
    **Best CV AUC: 0.9901**

The SHAP Analysis (Shapley values) indicated that the 'total_passengers_2' and 'load_factor_1' and 'pct_delta' are the top drivers of crowding.
The ROC Curve showed near-perfect separation between crowded and non-crowded links. And the calibration Plot confirmed that predicted probabilities closely matched actual crowding risk.

Use Case
This model  can serve as a crowding alert tool, which can enable proactive monitoring and control. It can be deployed to predict where passenger demand is outstripping supply.

![image](https://github.com/user-attachments/assets/e00bbe5e-2fdc-4830-9784-ef18e93d0679)
![image](https://github.com/user-attachments/assets/c67b747b-fb4f-48b8-b832-a09e2f79f701)


In summary, clustering can enhance understanding of station typologies and temporal rhythms, while the crowding model can offer a forecasting tool to preemptively address passenger congestion.

##  Limitations
Despite the depth of analysis, there are a few notable limitations:

  - Data Scope limitation: 
Due to the time limitation, it did not investigate the NUMBAT dataset across different years and periods (MON, FRI, SAT, SUN). The analysis relied solely on train frequency data and some of the NUMBAT dataset. It is worth spending more time to process the whole dataset and include some external covariates, such as weather, special events, and station accessibility.

  - Model Scope & Diversity:
While XGBoost performed well for binary crowding classification, it is worth trying other models such as logistic regression, random forest, or neural networks, etc. Further benchmarking across models could provide more robustness and interpretability trade-offs.

  - Passenger Demographics and Purpose:
This analysis assumed demand homogeneity across time and space. In reality, trip purpose segmentation (commute, leisure, tourism) could reveal deeper behavioural drivers, especially when comparing weekday to weekend clusters.

  - Transfer Behaviour:
Although tap-in/tap-out data is rich, multi-leg journeys (transfers across lines or stations) are not captured explicitly, which may understate complex passenger movement through key interchanges like Oxford Circus or King’s Cross.

##  Future research suggestions

  - Passenger Flow Simulation & Forecasting:
Develop network-based simulation models or graph neural networks to simulate how shocks (e.g., service disruptions or strikes) ripple through the network, and it is also worth predicting future ridership under various policy or infrastructure scenarios.

  - Further Development of Real-time Crowding Alerts:
With the predictive model in place, this research could be extended into a real-time application for passenger information systems or station control rooms, which could enable dynamic crowd management.

  - Simulation and Network Resilience:
It can use OD network graphs to simulate rerouting during service disruptions. It can also model the resilience of the Underground system under different shock scenarios.


##  Conclusion

This project provides a data-driven exploration of passenger flow patterns and crowding dynamics within the London Underground network from 2016 to 2023. By integrating multiple Transport for London datasets(including annual station entries/exits and detailed NUMBAT OD flow records), the study offers a comprehensive view of how ridership behaviour has evolved, particularly before and after the COVID-19 pandemic.

The project reveals critical insights:

  - Exploratory analyses show persistent structural changes in demand, with lingering post-COVID volume suppression and altered weekday/weekend patterns.

  - Network visualisations, such as chord diagrams and OD bar charts, uncover high-pressure links and validate the growing centrality of the Elizabeth Line.

  - Unsupervised clustering techniques (e.g. K-means and hierarchical clustering) effectively identify spatial and temporal usage patterns, which enhance the understanding of station typologies and peak dynamics.

  - A high-performance XGBoost-based crowding alert model was developed, which achieved an AUC of 0.9864 and demonstrates strong potential for forecasting congestion risks based on past travel and load conditions.

Overall, the study can combine descriptive insights and predictive modelling to help have smarter crowd management, operational planning across the TfL network. While some limitations remain, the modular framework built here offers a scalable foundation for real-time applications in urban mobility forecasting. It also helps to build a  solid foundation for further comprehensive research.

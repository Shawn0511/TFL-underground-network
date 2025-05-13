# TFL-underground-network
Exploring and Modelling Passenger Flow in the London Underground Network

This repository analyses nine years of Transport for London (TFL) datasets to show where and when crowding happens and to train a model that flags potentially overcrowded origin–destination (OD) links.

---

## 🔍 Key questions answered

1. **How has crowding on rail links evolved pre-COVID-19 and post-COVID-19?**  
2. **Which OD links and stations are persistently crowded?**  
3. **can we predict which origin–destination (OD) links will be critically crowded in the near term?**

---

> The one-page reflective summary is included in `summary/01382316-math70076-assessment-2-summary.pdf`.


### Exploratory Data Analysis for Network Demand Stationfootball dataset

The time series plot of daily total entry and exit tap counts across the entire network from 2019 to 2025 is shown below, It reflects that a sharp drop in demand occurs in early 2020, corresponding to the COVID-19 lockdowns. A gradual recovery is observed from late 2020 to 2023. For the period of Post-2022, the ridership level seems to plateau but does not yet fully reach pre-pandemic levels.

![image](https://github.com/user-attachments/assets/89f7cb9b-44c3-40dc-a9d1-09f5a8384d13)

The yearly entry Tap-in trends below include each year from 2019 to 2025.
- 2019 appears stable and representative of a pre-COVID year.
- 2020 displays an abrupt collapse in demand after day ~70 (March), with a very low baseline for the rest of the year.
- 2021–2022 show recovery phases, but lower peak values and greater variability persist.
- 2023 and 2024 display much more consistent volumes, though still slightly below 2019.
- 2025 (partial data) shows a solid start, but it can be observed that the post-COVID years' overall tap-in is lower than the pre-COVID year, which might be the reason for the increase in hybrid working mode.

![image](https://github.com/user-attachments/assets/4dccd438-5c49-4d39-9036-94f8ddb3af04)



### Exploratory Data Analysis for Annual Station Counts Pre-COVID & Post-COVID dataset

The two plots below show the top 20 stations by annual volume for each year. Each subplot ranks stations within the year, and the x-axis is fixed to help the comparison of passenger volumes.
- 2017–2019: The top stations are consistently King’s Cross St. Pancras, Oxford Circus, Victoria, Waterloo, and Liverpool Street. The ordering remains stable, which reflects established commuter hubs in Central London.
- 2021–2023: While the same core stations dominate, Tottenham Court Road, Farringdon, and Brixton LU begin to rise in rank, which likely reflects shifts in travel demand and recovery patterns.
- Post-COVID changes: Firstly, the impact of the Elizabeth Line opening is visible in rising ranks for Farringdon and Tottenham Court Road. It is noted that the central section of the Elizabeth line from Paddington to Abbey Wood opened to passengers on 24 May 2022, which connects regions to the east and west of London through the central area and the London Docklands. Secondly, the overall volumes increase from 2021 to 2023, showing recovery from the pandemic since the lockdown.

![image](https://github.com/user-attachments/assets/eadb56a3-f618-479e-b3f4-a7475ed294dd)
![image](https://github.com/user-attachments/assets/db1aaf30-92d3-4176-82a4-601e3b9337cf)

**Annual Passenger Volume Distribution by Year**
The histograms below show the distribution of station annual volumes for each year. It can be observed that:
- 2017–2019: The distribution is symmetric and unimodal, with a large concentration of stations around 10⁶–10⁷ entries/exits annually.
- 2021–2023: The distribution flattens in 2021 due to suppressed demand and lockdown, but gradually recovers in 2022–2023. However, it still shows that there is right-skewness in 2021, which indicates fewer stations with high footfall. Such an issue of heavier tails on the lower end and slightly shifted left, which reflects reduced demand and the uneven pace of recovery across stations.
- These plots highlight how COVID-19 disrupted the volume distribution, creating more heterogeneity and dampened peaks that recover gradually. It can be concluded that 2021–2023 demand remains lower and more dispersed compared to pre-COVID, with slower recovery for some stations.
























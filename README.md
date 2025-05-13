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
  - The post-COID period entry and exit volumes are still very balanced, which indicates no major system-level directional bias.
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















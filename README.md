## **Project Overview**
The Cyclistic Bikeshare dataset is part of a capstone project in the **Google Data Analytics Professional Certificate program**. The project focuses on analyzing a dataset provided by the Divvy bikeshare program in Chicago, a bicycle-sharing system used by locals and tourists alike. This analysis leverages real-world data to provide insights and actionable recommendations for stakeholders involved in urban mobility, transportation, and data analytics.

The goal of the Google Data Analytics Capstone Project is to:

- **Analyze trends in bike usage**, ride duration, and membership types.
- **Identify key patterns that can help improve the Divvy system**, such as customer behavior, popular times, and high-traffic areas.
- **Provide data-driven recommendations** to optimize operations and marketing strategies for Divvy's management.

## Data
This project uses the Divvy bikeshare dataset from Chicago, which is part of the city's bike-sharing system that serves both Chicago and Evanston.
The dataset consists of 12 separate .csv files, each representing data from a different month (from July 2023 to June 2024). It includes information about bike types, ride start and end dates, station details, and membership types.

The dataset consists of over a year's worth of Divvy trip data, including ride information such as:

- **Ride IDs**
- **Bike types (classic, electric)**
- **Member status (member vs. casual rider)**
- **Trip start and end times**
- **Stations used for pick-up and drop-off**

The data can be downloaded here: [https://divvy-tripdata.s3.amazonaws.com/index.html](https://divvy-tripdata.s3.amazonaws.com/index.html).  
The files are also available in the *data* folder in zip format (due to size limitations).

## Tools & Techniques Used 
- **Data Cleaning**: Handling missing values, filtering irrelevant records, and converting columns (e.g., trip start and end times).
- **Exploratory Data Analysis**: Visualizations using libraries like ggplot2 (R) to uncover patterns in the data.
- **Statistical Analysis**: Using mean, median, and standard deviation to summarize ride durations and other key metrics.
- **Data Visualization**: Bar charts and histograms to present the analysis results.

All steps were done using R language.

## Key Outcomes
- **Peak Season** : Summer is the peak season for rider (top 3: August, July & June) 
- **Peak Usage Times** : Casual riders tend to use bikes more on weekends, while member riders predominantly ride during weekdays, with a peak on Wednesdays, indicating a commuting pattern.
- **Riders' Bike Usage Patterns** : Casual riders and member riders travel similar distances, but casual riders take longer trips, indicating a leisure-focused use, while member riders likely use the bikes for practical, commuting purposes.
- **Member Riders' Consistent Return Behavior** : Member riders are more likely to return bikes to the same station, further supporting the idea of a practical, commuting-focused use.
- **Bike Type Preferences**: Casual riders tend to prefer electric bikes, while members are more likely to choose classic bikes.

## Author
Solène Catella

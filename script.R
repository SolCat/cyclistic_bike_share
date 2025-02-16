library(tidyverse) #wrangling data
library(lubridate) #wrangling date attributes
library(ggplot2) #visualizing data
library(dplyr) #cleaning data
library(tidyr) #cleaning data
library(geosphere) #calculating distance

# DATA IMPORTATION
folder_path <- "./R-data-analysis/data/"

tripdata_2023_07 <- read.csv(file.path(folder_path, "202307-divvy-tripdata.csv"), header = TRUE)
tripdata_2023_08 <- read.csv(file.path(folder_path, "202308-divvy-tripdata.csv"), header=TRUE)
tripdata_2023_09 <- read.csv(file.path(folder_path, "202309-divvy-tripdata.csv"), header=TRUE)
tripdata_2023_10 <- read.csv(file.path(folder_path, "202310-divvy-tripdata.csv"), header=TRUE)
tripdata_2023_11 <- read.csv(file.path(folder_path, "202311-divvy-tripdata.csv"), header=TRUE)
tripdata_2023_12 <- read.csv(file.path(folder_path, "202312-divvy-tripdata.csv"), header=TRUE)
tripdata_2024_01 <- read.csv(file.path(folder_path, "202401-divvy-tripdata.csv"), header=TRUE)
tripdata_2024_02 <- read.csv(file.path(folder_path, "202402-divvy-tripdata.csv"), header=TRUE)
tripdata_2024_03 <- read.csv(file.path(folder_path, "202403-divvy-tripdata.csv"), header=TRUE)
tripdata_2024_04 <- read.csv(file.path(folder_path, "202404-divvy-tripdata.csv"), header=TRUE)
tripdata_2024_05 <- read.csv(file.path(folder_path, "202405-divvy-tripdata.csv"), header=TRUE)
tripdata_2024_06 <- read.csv(file.path(folder_path, "202406-divvy-tripdata.csv"), header=TRUE)

tripdata_list <- list(
  tripdata_2023_07, tripdata_2023_08, tripdata_2023_09, tripdata_2023_10,
  tripdata_2023_11, tripdata_2023_12, tripdata_2024_01, tripdata_2024_02,
  tripdata_2024_03, tripdata_2024_04, tripdata_2024_05, tripdata_2024_06
)

dir.create("viz")

# Combining all the data sets
# Before merging, we need to ensure that all data files have the same structure (columns and column names)
num_columns <- sapply(tripdata_list, ncol) # checking number of columns (13)

column_names <- lapply(tripdata_list, colnames)
unique_column_names <- unique(column_names)
length(unique_column_names) # checking column names

all_tripdata <- bind_rows(tripdata_list) # combining data

# DATA EXPLORATION
dim(all_tripdata) # 5,734,381 lines & 13 columns
head(all_tripdata)
summary(all_tripdata)

# DATA CLEANING & TRANSFORMATION
colSums(is.na(all_tripdata)) # 7919 values are missing for both end_lat & end_lng 

# 1. We will first convert string characters to dates (ymd_hms)
# 2. We will add 3 new columns: ride_length, month & day (mutate)
# 3. We will remove outliers
# 3. We will remove rides with same dates of start and end (filter)
# 4. We will add a bonus column: rided distance

all_tripdata <- all_tripdata %>%
 mutate(
    started_at_date = ymd_hms(started_at),  
    ended_at_date = ymd_hms(ended_at)       
  ) %>%
 mutate(
    ride_length = difftime(ended_at_date, started_at_date, units = "mins"),
    month = month(started_at_date, label = TRUE, abbr = FALSE),
    day = wday(started_at_date, label = TRUE, abbr = FALSE),
    hour = hour(started_at_date),
    ride_length_numeric = as.numeric(ride_length)
  ) %>%
 filter(started_at_date != ended_at_date) # rides where the date of start and the date of end are the same are removed

glimpse(all_tripdata)

mean_value <- mean(all_tripdata$ride_length, na.rm = TRUE) # Time difference of 18.31747 mins
median_value <- median(all_tripdata$ride_length, na.rm = TRUE) # Time difference of 9.75 mins
# The mean is twice as high as the median, indicating that the data are scattered, and pointing to the presence of outliers

std_dev <- sd(all_tripdata$ride_length, na.rm = TRUE)
std_dev # 159.4534 >> 18.32, which means data is very scattered.

hist(all_tripdata$ride_length, breaks = 30, col = "skyblue", main = "Distribution of Ride Lengths")

limits <- boxplot.stats(all_tripdata$ride_length)$stats # automatic detection of limits via IQR
all_tripdata_filtered <- all_tripdata %>%
  filter(ride_length >= limits[1] & ride_length <= limits[5]) # removing outliers

sd(all_tripdata_filtered$ride_length, na.rm = TRUE) # 7.56197, which is better
dim(all_tripdata_filtered)

# time difference of -160.0333 mins (negative value)
# We will assume negative ride_length are rides where the date of start and the date of end were recorded in reverse order
negative_duration <- all_tripdata_filtered$ride_length < 0
all_tripdata_filtered$started_atdate[negative_duration] <- all_tripdata_filtered$ended_at_date[negative_duration]

all_tripdata_filtered <- all_tripdata_filtered %>%
  mutate(
    ride_distance = mapply(function(start_long, start_lat, end_lng, end_lat) {
      distGeo(c(start_long, start_lat), c(end_lng, end_lat))
    }, start_long = start_lng,
       start_lat = start_lat,
       end_lng = end_lng,
       end_lat = end_lat) #  shortest path calculation using longitude & latitude points
)

# DATA ANALYSIS
# -- Maximum ride duration --
max(all_tripdata_filtered$ride_length) # maximum time difference of 496.55 mins

# -- Average ride duration --
average_ride_length <- mean(all_tripdata_filtered$ride_length, na.rm = TRUE) 
average_ride_length # average time for ride is 14.83875 mins

# -- Top 3 months with the most rides --
most_rided_months <- all_tripdata_filtered %>%
 group_by(month) %>% #group by month
 summarise(trip_count = n()) %>% # count number of rides by month
 arrange(desc(trip_count)) %>%
 top_n(3, trip_count) 
most_rided_months # 1. August, 2. July & 3. June > insights: summer is the peak season for rider

# -- Day with the Most Rides --
most_rided_days <- all_tripdata_filtered %>%
 group_by(day) %>% #group by day
 summarise(trip_count = n()) %>% # count number of rides by day
 top_n(1, trip_count) 
most_rided_days # insights: Saturday (896,642 trips) is the most busy day

# -- Average Number of Rides by Hour for Casual Riders --
most_hourly_rides <- all_tripdata_filtered %>%
  group_by(hour) %>%
  summarise(ride_count = n()) %>%
  arrange(desc(ride_count))

plot_1 <- ggplot(most_hourly_rides, aes(x = factor(hour), y = ride_count, fill = ride_count)) +
  geom_bar(stat = "identity") +
  labs(
    title = "Rides per Hour Segment for Casual Members",
    x = "Hour of Day",
    y = "Number of Rides"
  ) +
  scale_x_discrete(labels = as.character(0:23)) +
  scale_y_continuous(labels = scales::comma) +
  scale_fill_gradient(low = "lightgrey", high = "black")

plot_1 # insights: casual riders ride the most between 3pm and 6pm.

ggsave("./viz/average_number_rides_by_hour.png", plot = plot_1, width = 10, height = 6)

# -- Average Trip Duration by User Type --
unique(all_tripdata_filtered$member_casual) # member riders vs casual riders
rides_by_user <- all_tripdata_filtered %>%
 group_by(member_casual) %>% #group by membership
 summarise(average_duration = mean(as.numeric(ride_length), na.rm = TRUE)) # count number of rides by day
rides_by_user

plot_2 <- ggplot(rides_by_user, aes(x = member_casual, y = average_duration, fill = member_casual)) +
geom_bar(stat = "identity") +
labs(
  title = "Average Trip Duration by User Type",
  x = "User type",
  y = "Average ride duration (min)"
  ) 

plot_2 # insights: casual riders have longer average ride duration than member riders, especially on weekends

ggsave("./viz/average_trip_duration_by_user_type.png", plot = plot_2, width = 10, height = 6)

# -- Average Ride Duration for Member Riders by Day --
member_riders_by_day <- all_tripdata_filtered %>%
 filter(member_casual == "member") %>%
 group_by(day) %>%
 summarise(average_duration = mean(as.numeric(ride_length), na.rm = TRUE)) %>%
 arrange(desc(average_duration))
member_riders_by_day # insights: member riders usually ride on Sunday (1), Saturday (2) and Friday (3)

# -- Average Ride Duration for Casual Riders by Day --
casual_riders_by_day <- all_tripdata_filtered %>%
 filter(member_casual == "casual") %>%
 group_by(day) %>%
 summarise(average_duration = mean(as.numeric(ride_length), na.rm = TRUE)) %>%
 arrange(desc(average_duration))
casual_riders_by_day # insights: casual riders usually ride on Sunday (1), Saturday (2) and Monday (3)

all_trip_duration_summary <- all_tripdata_filtered %>%
  group_by(day, member_casual) %>%
  summarise(average_duration = mean(ride_length, na.rm = TRUE), .groups = "drop")

all_trip_duration_summary$average_duration <- as.numeric(all_tripdata_summary$average_duration)

plot_3 <- ggplot(all_trip_duration_summary, aes(x = day, y = average_duration, fill = member_casual)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(
    title = "Total riding time by rider type and by day of the week",
    x = "Day of week",
    y = "Average ride duration",
    fill = "Rider type"
  )

plot_3 # insights: casual riders ride most often on weekends

ggsave("./viz/riding_time_by_rider_type_by_day.png", plot = plot_3, width = 10, height = 6)

# -- Number of Rides by Rider Type and Day --
all_trip_count_summary <- all_tripdata_filtered %>%
  group_by(day, member_casual) %>%
  summarise(trip_count = n(), .groups = "drop")

plot_4 <- ggplot(all_trip_count_summary, aes(x = day, y = trip_count, fill = member_casual)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(
    title = "Number of Rides by Rider Type and Day",
    x = "Day of week",
    y = "Number of rides",
    fill = "Rider type"
  )

plot_4 # insights: casual riders tend to use bikes more on weekends, while member riders ride during weekdays

ggsave("./viz/total_rides_by_rider_type_by_day.png", plot = plot_4, width = 10, height = 6)

# -- Type of Bike By Rider Type --
bike_type_rider_type <- all_tripdata_filtered %>%
  group_by(member_casual, rideable_type) %>%
  summarise(trip_count = n(), .groups = "drop") %>%
  arrange(desc(trip_count))

plot_5 <-  ggplot(bike_type_rider_type, aes(x = member_casual, y = trip_count, fill = member_casual)) +
  geom_col(position = "dodge") +
  scale_y_continuous(labels = scales::comma) +
  facet_wrap(~rideable_type) +
  labs(
    title = "Number of Rides by Bike Type and Rider Type",
    x = "Bike type",
    y = "Number of rides",
    fill = "Rider type"
  )

plot_5 # insights: member riders tend to prefer classic bikes while casual riders tend to prefer electric bikes

ggsave("./viz/total_rides_by_bike_type_by_rider_type.png", plot = plot_5, width = 10, height = 6)

# -- Ride Distance By Rider Type --
distance_by_rider_type <- all_tripdata_filtered %>%
  group_by(member_casual) %>%
  summarise(average_distance = mean(ride_distance, na.rm = TRUE), .groups = "drop") # not very informative

# -- Are members riders or casual riders more likely to return their bikes at the same station? --
all_tripdata_filtered %>%
  group_by(member_casual) %>%
  filter(start_station_id == end_station_id) %>%
  summarise(count_same_station = n(), .groups = "drop") # 371,295 rides for member vs 342,942 rides for casual

all_tripdata_filtered %>%
  group_by(member_casual) %>%
  filter(start_station_id == end_station_id) %>%
  summarise(count_same_station = n(), .groups = "drop")

all_tripdata_filtered %>%
  group_by(member_casual) %>%

group_by(rideable_type, member_casual) %>% 
  summarize(number_of_rides = n(), .groups = 'drop') %>% 
  drop_na() %>% 

## -- Top 10 Used Stations By Casual Riders

top_10_station <- all_tripdata_filtered %>% 
  filter(!is.na(start_station_name) & start_station_name != "") %>%
  group_by(start_station_name) %>% 
  summarise(station_count = n()) %>% 
  arrange(desc(station_count)) %>% 
  slice(1:10)
top_10_station

plot_6 <- ggplot(data = top_10_station, aes(x = reorder(start_station_name, station_count), y = station_count, fill = station_count)) +
  geom_col(position = "dodge") +
  labs(
    title = "Top 10 Used Stations by Casual Riders",
    x = "",
    y = "Number of rides"
  )+  
  scale_y_continuous(labels = scales::comma) +
  scale_fill_gradient(low = "lightgrey", high = "black") +
  coord_flip()

plot_6

ggsave("./viz/top10_station_by_casual_riders.png", plot = plot_6, width = 10, height = 6)

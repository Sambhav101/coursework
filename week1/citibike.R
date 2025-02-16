library(tidyverse)
library(lubridate)

########################################
# READ AND TRANSFORM THE DATA
########################################

# read one month of data
trips <- read_csv('201402-citibike-tripdata.csv')

# replace spaces in column names with underscores
names(trips) <- gsub(' ', '_', names(trips))

# convert dates strings to dates
#trips <- mutate(trips, starttime = mdy_hms(starttime), stoptime = mdy_hms(stoptime))

# recode gender as a factor 0->"Unknown", 1->"Male", 2->"Female"
trips <- mutate(trips, gender = factor(gender, levels=c(0,1,2), labels = c("Unknown","Male","Female")))


########################################
# YOUR SOLUTIONS BELOW
########################################

# count the number of trips (= rows in the data frame)
count(trips)


# find the earliest and latest birth years (see help for max and min to deal with NAs)
max(trips$birth_year)
min(trips$birth_year[trips$birth_year != "\\N"])


#use filter and grepl to find all trips that either start or end on broadway
trips %>%
  filter(grepl('broadway', trips$start_station_name, ignore.case = TRUE) | 
           grepl('broadway', trips$end_station_name, ignore.case = TRUE))


# do the same, but find all trips that both start and end on broadway
trips %>%
  filter(grepl('broadway', trips$start_station_name, ignore.case = TRUE) &
           grepl('broadway', trips$end_station_name, ignore.case = TRUE))


# find all unique station names
unique(trips$start_station_name)

# count the number of trips by gender, the average trip time by gender, and the standard deviation in trip time by gender
# do this all at once, by using summarize() with multiple arguments
trips %>%
  group_by(gender) %>%
  summarize(num_trips = n(), avg_time = mean(tripduration/60), sd_time = sd(tripduration/60))


# find the 10 most frequent station-to-station trips
trips %>%
  group_by(start_station_name, end_station_name) %>%
  summarize(trip_count = n()) %>%
  arrange(desc(trip_count)) %>%
  ungroup() %>%
  top_n(10)


# find the top 3 end stations for trips starting from each start station
trips %>%
  group_by(start_station_name, end_station_name) %>% 
  summarize(trip_count = n()) %>%
  arrange(start_station_name, desc(trip_count)) %>%
  top_n(3)
  

# find the top 3 most common station-to-station trips by gender
trips %>%
  group_by(gender, start_station_name, end_station_name) %>%
  summarize(trip_count = n()) %>%
  arrange(gender, desc(trip_count)) %>%
  ungroup(start_station_name, end_station_name) %>%
  top_n(3)
  

# find the day with the most trips
# tip: first add a column for year/month/day without time of day (use as.Date or floor_date from the lubridate package)
trips %>%
  select(starttime) %>%
  group_by(Date = date(starttime)) %>%
  summarize(trip_count = n()) %>%
  slice_max(trip_count)

# other ways
# mutate(Date = date(starttime))
# separate(starttime, into = c("Date"), sep = " ")
  

# compute the average number of trips taken during each of the 24 hours of the day across the entire month
# what time(s) of day tend to be peak hour(s)?
trips %>%
  select(starttime) %>%
  group_by(Hour = hour(starttime)) %>%
  summarize(avg_trip = n()/28) %>%
  arrange(desc(avg_trip))

# The peak hours are usually from 4pm to 6pm.

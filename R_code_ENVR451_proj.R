#Extracting Census Data for Robeson County, NC using R and ArcGIS Pro

library(tidyverse) #Assists with data import, tidying, manipulation, and data visualization
library(tidycensus) #Helps R users get Census data that is pre-prepared for exploration within the tidyverse, and optionally spatially with sf
library(sf) #Support for simple features, a standardized way to encode spatial vector data
library(dplyr) #Provides a function for each basic verb of data manipulation
library(tidyr) #Contains tools for changing the shape and hierarchy of a dataset, turning deeply nested lists into rectangular data frames, and extracting values out of string columns
library(data.table) #Used for fast aggregation of large datasets, low latency add/update/remove of columns, quicker ordered joins, and a fast file reader
library(ggplot2) #Provides helpful commands to create complex plots from data in a data frame

#("4125e83f848628ca4491af33648306e0db6e858c", install=T)
#overwrite=TRUE

# Retrieving some information from the 2013 5-year ACS
acs_vars = load_variables(2013, "acs5")

# The data is huge, so I am saving it to a file to view it on Excel.
write.csv(acs_vars,file='/Users/akunna1/Desktop/ENVR 451/Group_project_R/ENVR_451_Group_Proj/acsvars.csv')

# Social factor 1: Income level --> finding the percent of households living in poverty. Poverty is defined as earning less than 35k annually
# Retrieve ACS data on the income levels of the households in Robeson county tract in North Carolina
household_income = get_acs(
  geography="tract",  # could be tract, block group, etc.
  variables=c(
    "total_income"="B19001_001",
    "lessthan_10k"="B19001_002",
    "i10k_to_14.9k"="B19001_003",
    "i15k_to_19.9k"="B19001_004",
    "i20k_to_24.9k"="B19001_005",
    "i25k_to_29.9k"="B19001_006",
    "i30k_to_34.9k"="B19001_007",
    "i35k_to_39.9k"="B19001_008",
    "i40k_to_44.9k"="B19001_009",
    "i45k_to_49.9k"="B19001_010",
    "i50k_to_59.9k"="B19001_011",
    "i60k_to_74.9k"="B19001_012",
    "i75k_to_99.9k"="B19001_013",
    "i100k_to_124.9k"="B19001_014",
    "i125k_to_149.9k"="B19001_015",
    "i150k_to_199.9k"="B19001_016",
    "i200k_or_more"="B19001_017"
  ),
  year=2013,
  state="NC",
  survey="acs5",
  output="wide"
)

View(household_income)

# To do any spatial analysis, I have to join the household_income data to spatial information
# Spatial information was obtained from: https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.html

# On ArcGIS Pro, I opened the 2013 downloaded shapefile for the tracts in NC and extract those of Robeson County using the Select by Attributes tool
#County FIPS =37155. On the attribute table, COUNTYFP = 155

# Read in Robeson county tract shapefile
robeson_county = read_sf("Robeson_county_tracts.shp")

# Join the datasets together
robeson_county_joined = left_join(robeson_county, household_income, by="GEOID")
robeson_county_joined

#Calculating the percentage of all households that make <$35,000/year in each tract
robeson_county_joined$percent_under_35k = ((robeson_county_joined$lessthan_10kE + robeson_county_joined$i10k_to_14.9kE + robeson_county_joined$i15k_to_19.9kE + robeson_county_joined$i20k_to_24.9kE + robeson_county_joined$i25k_to_29.9kE + robeson_county_joined$i30k_to_34.9kE)/ robeson_county_joined$total_incomeE)*100
robeson_county_joined$percent_under_35k

# project the data to NC State Plane
# Got the state plane number from https://www.eye4software.com/hydromagic/documentation/state-plane-coordinate-systems/
robeson_county_joined = st_transform(robeson_county_joined,32119)

# And map of income poverty percent
ggplot() +
  geom_sf(data=robeson_county_joined, aes(fill=percent_under_35k)) +
  scale_fill_viridis_c(option = "D")

view(robeson_county_joined)
#write.csv(robeson_county_joined,file='/Users/akunna1/Desktop/ENVR 451/Group_project_R/ENVR_451_Group_Proj/ENVR_451_Group_project_V2/robeson_county_joined.csv')

# Social factor 2: race --> Defining minorities to be Black or AA, American Indian, Alaska Native, Asian, Native Hawaiians and  Pacific Islanders
race_minorities = get_acs(
  geography="tract",  # could be tract, block group, etc.
  variables=c(
    "total_race"="B02001_001",
    "white_race"="B02001_002",
    "black_race"="B02001_003",
    "native_race"="B02001_004",     #American Indian and Alaska native race
    "asian_race"="B02001_005",
    "islander_race"="B02001_006",
    "other_race"="B02001_007",
    "Two_or_more_race"="B02001_008",
    "X_Two_or_more_race"="B02001_009", # Two or more races!!Two races including Some other race
    "Y_Two_or_more_race"="B02001_010" # Two or more races!!Two races excluding Some other race, and three or more races
  ),
  year=2013,
  state="NC",
  survey="acs5",
  output="wide"
)

View(race_minorities)

# joining census data with shapefile
robeson_county_joined_2 = left_join(robeson_county, race_minorities, by="GEOID")
robeson_county_joined_2

# calculating the percent of minorities in Robeson county
robeson_county_joined_2$percent_minority = ((robeson_county_joined_2$black_raceE + robeson_county_joined_2$native_raceE + robeson_county_joined_2$asian_raceE + robeson_county_joined_2$islander_raceE + robeson_county_joined_2$other_raceE)/ robeson_county_joined_2$total_raceE)*100
robeson_county_joined_2$percent_minority

# project the data to NC State Plane
robeson_county_joined_2 = st_transform(robeson_county_joined_2,32119)

# And map of income poverty percent
ggplot() +
  geom_sf(data=robeson_county_joined_2, aes(fill=percent_minority)) +
  scale_fill_viridis_c(option = "A")

view(robeson_county_joined_2)

#show correlation between the poverty percent and concentration of NO2
# perhaps a scatter plot- show r2 value
# combining pollutants or not?
#using spatial join on ArcGIS Pro?

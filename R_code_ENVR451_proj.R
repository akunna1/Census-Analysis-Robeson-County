#Extracting Census Data for Robeson County, NC

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

# The data is huge, so I am saving it to a file and view it on Excel.
write.csv(acs_vars,file='/Users/akunna1/Desktop/ENVR 451/Group_project_R/ENVR_451_Group_Proj/acsvars.csv')


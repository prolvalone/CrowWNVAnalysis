library(tidyverse)
library(maps)

#######################################
# THIS SECTION FILTERS OUT UNNECCESARY DATA --4GB worth!


data <- data[ , -c(1,2,3,4,5,7,8,9,10,12,13,14,15,16,17,19,22,24,25,27,28,32,33,36,37,
                  38,39,40,41,43,44,45,46,47,48,49,50)] 
Edited_crow_Data <- Edited_crow_Data[Edited_crow_Data$OBSERVATION.COUNT != "X",] 
 Edited_crow_Data$`OBSERVATION COUNT`=  as.numeric(Edited_crow_Data$`OBSERVATION COUNT`)

########################################
# THIS SECTION changes data to be numeric 

Edited_crow_Data$`OBSERVATION COUNT` <- replace(Edited_crow_Data$`OBSERVATION COUNT`, Edited_crow_Data$`OBSERVATION COUNT` == "X", 0)


Edited_crow_Data$`OBSERVATION COUNT` <- as.numeric(Edited_crow_Data$`OBSERVATION COUNT`)
total_by_county <- Edited_crow_Data %>%
  group_by(STATE, COUNTY) %>%
  summarize(total_observations = sum(`OBSERVATION COUNT`, na.rm = TRUE))
glimpse(Edited_crow_Data)

#We now have county totals from 1999-2022

############################################
# This Section combines the two datasets on county DATA

#GET FULL FIPS DATA
county_fips <- county.fips$fips
WNVRatesSep <- WNVRatesSep %>% 
  rename(fips = County)

#MAKE FIPS A DATAFRAME
county_fips <- as.data.frame(county.fips)
county_fips$fips <- as.numeric(county_fips$fips)
WNVRatesSep$fips <- as.numeric(WNVRatesSep$fips)
merged_data <- merge(county_fips, WNVRatesSep, by = "fips")

#THIS IS A BUNCH OF MERGING, UNITING, AND RENAMING TO UNITE FRAMES INTO ONE SET
WNVRatesSep <- WNVRates %>% 
separate(col = FullGeoName, into = c("State", "County_Name"), sep = ", ")
WNVRatesSep <- WNVRatesSep %>% 
  rename(COUNTY = County_Name)

county_fips <- as.data.frame(county.fips)
county_fips$fips <- as.numeric(county_fips$fips)
WNVRatesSep$fips <- as.numeric(WNVRatesSep$fips)
merged_data <- merge(county_fips, WNVRatesSep, by = "fips")

total_by_county <- total_by_county %>% 
  unite(polyname, c("STATE", "COUNTY"), sep = ",")

CombinedCountyData <- merge(merged_data, total_by_county, by = "polyname")
write.csv(CombinedCountyData, "C:/Users/chris/OneDrive/Documents/RProjects/RTutorialProject/data/CombinedCrowData.csv", row.names = FALSE)

#at this pint I messed up, Deleting my old table from Rstudio.  I imported the CSV back in, as CombinedCrowData since I saved it

##########################################
#This Section adds the variable for the crow sighting rate
CombinedCrowData$fips <- str_pad(CombinedCrowData$fips, 5, pad = "0")
CombinedCrowData <- CombinedCrowData %>% 
  mutate(CrowRate = round(total_observations / Population, 4))
 
############################################
# This Section calculates and outputs data for WNV
# The Section After this does the same for just Crow Populations.  Only one can be run 
# At the same time, thus why this is commented out for now


library(plotly)
library(rjson)

#Set County Data
 url <- 'https://raw.githubusercontent.com/plotly/datasets/master/geojson-counties-fips.json'
 counties <- rjson::fromJSON(file=url)
# 
# g <- list(
#   scope = 'usa',
#      projection = list(type = 'albers usa'),
#     showlakes = TRUE,
#     lakecolor = toRGB('white')
#  )
#  fig <- plot_ly()
#  fig <- fig %>% add_trace(
#     type="choropleth",
#     geojson=counties,
#     locations=CombinedCrowData$fips,
#     z=CombinedCrowData$Incidence,
#     colorscale="Viridis",
#     zmin=0,
#     zmax=12,
#     marker=list(line=list(
#      width=0)
#    )
#  )
#  fig <- fig %>% colorbar(title = "WNV Incidence")
#  fig <- fig %>% layout(
#    title = "1999-2022 WNV Incidence by County"
#  )
# 
#  fig <- fig %>% layout(
#    geo = g
#  )
# 
#  fig

############################################
# This Section calculates and outputs data for Crow Populations


g <- list(
  scope = 'usa',
  projection = list(type = 'albers usa'),
  showlakes = TRUE,
  lakecolor = toRGB('white')
)
fig <- plot_ly()
fig <- fig %>% add_trace(
  type="choropleth",
  geojson=counties,
  locations=CombinedCrowData$fips,
  z=CombinedCrowData$CrowRate,
  colorscale="Viridis",
  zmin=0,
  zmax=4,
  marker=list(line=list(
    width=0)
  )
)
fig <- fig %>% colorbar(title = "Crow Sightings to Human Population")
fig <- fig %>% layout(
  title = "1999-2022 Crow Sighting Abundance"
)

fig <- fig %>% layout(
  geo = g
)

fig


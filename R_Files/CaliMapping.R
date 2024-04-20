# This File prepares the data to be used for bivariate mapping and creates a bivariate map using said data
library(tidyverse)
library(biscale)
library(cowplot)
library(sf)
library(readr)
library(rnaturalearth)
library(rjson)

CaliCrowDataZF <- read_csv("data/CaliCrowDataZF.csv")
WNVRates <- read_csv("data/WNVRates.csv")
########################
countyData <- CaliCrowDataZF %>% 
  group_by(county) %>% 
  summarize(total_observations = sum(observation_count, na.rm = TRUE),
            total_checklists = sum(n()))
#Add incidence Variable

countyData$incidence <- countyData$total_observations / countyData$total_checklists

#remove Na variable for countyless / off the coast  checklists (n=29)
countyData <- countyData[-59, ]

##############################
# Add FIPS Codes
# Assuming your dataframe is called "county_data" and you want to add the FIPS codes as a new column

# Create a new column with the FIPS codes
countyData$FIPS <- c(
  "06001", "06003", "06005", "06007", "06009", "06011", "06013", "06015",
  "06017", "06019", "06021", "06023", "06025", "06027", "06029", "06031",
  "06033", "06035", "06037", "06039", "06041", "06043", "06045", "06047",
  "06049", "06051", "06053", "06055", "06057", "06059", "06061", "06063",
  "06065", "06067", "06069", "06071", "06073", "06075", "06077", "06079",
  "06081", "06083", "06085", "06087", "06089", "06091", "06093", "06095",
  "06097", "06099", "06101", "06103", "06105", "06107", "06109", "06111",
  "06113", "06115"
)
##############################
#Add WNV Data to countyData

caliWNVRates <- WNVRates[114:165, ] # extracts only California WNV Data
#Merge Datasets
caliWNVRates <- rename(caliWNVRates, FIPS = County)
combinedCountyData <- merge(countyData, caliWNVRates, by = "FIPS", all = TRUE)
combinedCountyData <- rename(combinedCountyData, crowRate = incidence)

######################
#Bivariately Map

#read spacial data
file <- 'data/caliSpatial.json'
sfData <- st_read(file)
counties <- rjson::fromJSON(file="data/caliSpatial.json")

bivariate_data <- combinedCountyData

# Join bivariate classification back with spatial data
bivariate_data$Incidence[is.na(bivariate_data$Incidence)] <- 0 #repalce na values
bivariate_data <- bi_class(bivariate_data, x = Incidence, y = crowRate, style = "quantile", dim = 3)
sfData <- rename(sfData, county = CountyName)
sfData <- merge(sfData, bivariate_data, by = "county", all = TRUE)


##########################
# Create map
map <- ggplot() +
  geom_sf(data = sfData, mapping = aes(fill = bi_class), color = "white", size = 0.1, show.legend = FALSE) +
  bi_scale_fill(pal = "PurpleOr", dim = 3) +
  labs(
     title = "Crow and WNV Rates"
  ) +
  bi_theme()

# Create legend
legend <- bi_legend(pal = "PurpleOr",
                    dim = 3,
                    xlab = "WNV Rates ",
                    ylab = "Crow Rates ",
                    size = 6)

# Draw Map
finalPlot <- ggdraw() +
  draw_plot(map, 0, 0, 1.1, 1.1) +   # Center the map and make it larger (width=2, height=2)
  draw_plot(legend, 0.2, 0.2, 0.2, 0.2)  # Adjust the legend position if needed
finalPlot


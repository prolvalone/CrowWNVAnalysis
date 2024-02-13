# This File Creates a bivariate Chloropleth map for all counties of the USA.  It measures Crow Data and WNV data
library(tidyverse)
library(biscale)
library(cowplot)
library(sf)
library(readr)

CombinedCrowData <- read_csv("data/CombinedCrowData.csv")
View(CombinedCrowData)
url <- 'https://raw.githubusercontent.com/plotly/datasets/master/geojson-counties-fips.json'
counties <- rjson::fromJSON(file=url)

# Read the spatial data
sfData <- st_read(url)
  #calculate crow rate
  CombinedCrowData$fips <- str_pad(CombinedCrowData$fips, 5, pad = "0")
  CombinedCrowData <- CombinedCrowData %>% 
    mutate(CrowRate = round(total_observations / Population, 4))
  
bivariate_data <- CombinedCrowData

# Rename column to 'fips'
sfData <- sfData %>% rename(fips = id)

# Assuming you have columns 'Incidence' and 'CrowRate' in sfData
# Create bivariate data
bivariate_data <- bi_class(bivariate_data, x = Incidence, y = CrowRate, style = "quantile", dim = 3)

# Join bivariate classification back with spatial data
sfData <- sfData %>% 
  left_join(bivariate_data, by = "fips")

# Create map
map <- ggplot() +
  geom_sf(data = sfData, mapping = aes(fill = bi_class), color = "white", size = 0.1, show.legend = FALSE) +
  bi_scale_fill(pal = "GrPink", dim = 3) +
  labs(
   # title = "Crow and WNV Rates"
  ) +
  bi_theme()

# Create legend
legend <- bi_legend(pal = "GrPink",
                    dim = 3,
                    xlab = "WNV Rates ",
                    ylab = "Crow Rates ",
                    size = 6)

# Draw Map
finalPlot <- ggdraw() +
  draw_plot(map, -0.4, -1.3, 4, 4) +  # Center the map and make it larger (width=2, height=2)
  draw_plot(legend, 0.2, .2, 0.2, 0.2)  # Adjust the legend position if needed


finalPlot

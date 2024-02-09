library(plotly)
library(rjson)

#Set County Data
url <- 'https://raw.githubusercontent.com/plotly/datasets/master/geojson-counties-fips.json'
counties <- rjson::fromJSON(file=url)

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
  locations=WNV_rates_county_2002$County,
  z=WNV_rates_county_2002$Incidence,
  colorscale="Viridis",
  zmin=0,
  zmax=12,
  marker=list(line=list(
    width=0)
  )
)
fig <- fig %>% colorbar(title = "WNV Incidence")
fig <- fig %>% layout(
  title = "1999-2022 WNV Incidence by County"
)

fig <- fig %>% layout(
  geo = g
)

fig

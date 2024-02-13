#### Cleaning Data of txt format

library(auk)
library(lubridate)
library(sf)
library(gridExtra)
library(tidyverse)
# resolve namespace conflicts
select <- dplyr::select

# setup data directory
dir.create("data", showWarnings = FALSE)

ebd <- auk_ebd("C:/Users/chris/OneDrive/Documents/RProjects/RTutorialProject/data/ebdCali/CaliDataCrow.txt", 
               file_sampling = "C:/Users/chris/OneDrive/Documents/RProjects/RTutorialProject/data/ebdCali/CaliDataCrowSampling.txt")


ebd_filters <- ebd %>% 
  auk_species("American Crow") %>% 
  # june, use * to get data from any year
  # restrict to the standard traveling and stationary count protocols
  auk_protocol(protocol = c("Stationary", "Traveling")) %>% 
  auk_complete()

data_dir <- "data"
f_ebd <- file.path(data_dir, "ebdCali/CaliDataCrow.txt")
f_sampling <- file.path(data_dir, "ebdCali/CaliDataCrowSampling.txt")

# output files
data_dir <- "data"
if (!dir.exists(data_dir)) {
  dir.create(data_dir)
}
f_ebd <- file.path(data_dir, "ebd_woothr_june_bcr27.txt")
f_sampling <- file.path(data_dir, "ebd_checklists_june_bcr27.txt")

# only run if the files don't already exist
if (!file.exists(f_ebd)) {
  auk_filter(ebd_filters, file = f_ebd, file_sampling = f_sampling)
}
#### Zero Filling DATA
ebd_zf <- auk_zerofill(f_ebd, f_sampling, collapse = TRUE)


# function to convert time observation to hours since midnight
time_to_decimal <- function(x) {
  x <- hms(x, quiet = TRUE)
  hour(x) + minute(x) / 60 + second(x) / 3600
}

# clean up variables
ebd_zf <- ebd_zf %>% 
  mutate(
    # convert X to NA
    observation_count = if_else(observation_count == "X", 
                                NA_character_, observation_count),
    observation_count = as.integer(observation_count),
    # effort_distance_km to 0 for non-travelling counts
    effort_distance_km = if_else(protocol_type != "Traveling", 
                                 0, effort_distance_km),
    # convert time to decimal hours since midnight
    time_observations_started = time_to_decimal(time_observations_started),
    # split date into year and day of year
    year = year(observation_date),
    day_of_year = yday(observation_date)
  )
# additional filtering
ebd_zf_filtered <- ebd_zf %>% 
  filter(
    # effort filters
    duration_minutes <= 5 * 60,
    effort_distance_km <= 5,
    # 10 or fewer observers
    number_observers <= 10)
##Create Final FILTERED DataSet

ebird <- ebd_zf_filtered %>% 
  select(checklist_id, observer_id, sampling_event_identifier,
         scientific_name, county, county_code, iba_code,
         observation_count, species_observed, 
         state_code, locality_id, latitude, longitude,
         protocol_type, all_species_reported,
         observation_date, year, day_of_year,
         time_observations_started, 
         duration_minutes, effort_distance_km,
         number_observers)
write_csv(ebird, "data/CaliCrowDataZF.csv", na = "")

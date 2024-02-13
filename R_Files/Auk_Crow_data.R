library(auk)
library(lubridate)
library(sf)
library(gridExtra)
library(tidyverse)
# resolve namespace conflicts
select <- dplyr::select

# setup data directory
dir.create("data", showWarnings = FALSE)

ebd <- auk_ebd("C:/Users/chris/OneDrive/Desktop/ebird/american_crow_data.txt", 
               file_sampling = "C:/Users/chris/OneDrive/Desktop/ebird/american_crow_sampling_data.txt")
###################################################
# Step 2
###################################################

ebd_filters <- ebd %>% 
  auk_species("American Crow") %>% 
  # june, use * to get data from any year
  auk_date(date = c("*-01-01", "*-12-31")) %>% 
  # restrict to the standard traveling and stationary count protocols
  auk_protocol(protocol = c("Stationary", "Traveling")) %>% 
  auk_complete()
ebd_filters
#> Input 
#>   EBD: C:/Users/chris/OneDrive/Desktop/ebird/american_crow_data.txt 
#>   Sampling events: C:/Users/chris/OneDrive/Desktop/ebird/american_crow_sampling_data.txt 
#> 
#> Output 
#>   Filters not executed
#> 
#> Filters 
#>   Species: Corvus brachyrhynchos
#>   Countries: United States
#>   States: all
#>   Counties: all
#>   Bounding box: full extent
#>   Years: 1999-2022
#>   Date: *-01-01 - *-12-31
#>   Start time: all
#>   Last edited date: all
#>   Protocol: Stationary, Traveling
#>   Project code: all
#>   Duration: all
#>   Distance travelled: all
#>   Records with breeding codes only: no
#>   Complete checklists only: yes

###################################
# Step 3
###################################

# output files
data_dir <- "C:/Users/chris/OneDrive/Desktop/ebird/ebd99_23"
if (!dir.exists(data_dir)) {
  dir.create(data_dir)
}
f_ebd <- file.path(data_dir, "ebd_amercrow.txt")
f_sampling <- file.path(data_dir, "ebd_checklists_amerCrow.txt")

# only run if the files don't already exist
if (!file.exists(f_ebd)) {
  auk_filter(ebd_filters, file = f_ebd, file_sampling = f_sampling)
}
##############################
# Step 4
###########################
ebd_zf <- auk_zerofill(f_ebd, f_sampling, collapse = TRUE)

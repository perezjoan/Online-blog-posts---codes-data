library(sf)
library(mapsf)
library(tidyr)
library(dplyr)
library(gifski)

velib_loc <- st_read("velib_paris.gpkg", layer = "location")
velib_data <- st_read("velib_paris.gpkg", layer = "data_velib")
voronoi <- st_read("velib_paris.gpkg", layer = "voronoi_polygons")

# Pivot the summarized data to a wider format
velib_data_pw <- velib_data %>%
  pivot_wider(
    names_from = time_stamp,
    values_from = num_bikes_available,
    id_cols = station_id
  )

# Rename columns and convert them to numeric
for (i in 2:ncol(velib_data_pw)) {
  colnames(velib_data_pw)[i] <- paste0("TIME_STAMP_", i - 1)
  velib_data_pw[[i]] <- as.numeric(velib_data_pw[[i]])
}

velib_data_loc <- left_join(velib_loc, velib_data_pw, by = "station_id")

names_tp <- colnames(velib_data_loc)

for(i in seq(from = 8, to = 166, by = 1)) {
  png(paste(i+100, "_velib.png", sep =''), 
      width = 1200, 
      height = 800)
  mf_map(x = voronoi)
  mf_map(x = velib_data_loc, 
         var = names_tp[i], 
         type = "prop", 
         inches = 2, 
         val_max = 3000, 
         leg_pos = "topright")
  mf_layout(
    title = "Total flows vlib stations every 5 mins",
    credits = "J.Perez, 2024")
  dev.off()
}

wd <-  getwd()
png_files <- list.files(wd, pattern = ".*png$", full.names = TRUE)
gifski(png_files, gif_file = "animation.gif", width = 1200, height = 800,
       delay = 0.01)


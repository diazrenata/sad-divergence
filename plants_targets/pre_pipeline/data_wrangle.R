library(dplyr)
source(here::here("functions", "wf.R"))


portal_timesteps <- portalr::plant_abundance(level = "Treatment", type = "All", plots = "longterm")

portal_timesteps_communities <- portal_timesteps %>%
  mutate(season = paste0(year, season, substr(treatment, 0, 1))) %>%
  rename(siteID = season) %>%
  filter(abundance > 0) %>%
  select(-species, -quads, -nplots)

write.csv(portal_timesteps_communities, here::here("plants_targets", "pre_pipeline", "all_plant_data.csv"))


tiny_data = portal_timesteps_communities %>%
  filter(siteID== "1994summerc")

write.csv(tiny_data, here::here("plants_targets", "pre_pipeline", "one_plant_data.csv"))


for(thisID in unique(portal_timesteps_communities$siteID)) {
  
  thisdat  = portal_timesteps_communities %>%
    filter(siteID== thisID)
  
  write.csv(thisdat, here::here("plants_targets", "pre_pipeline", "all_data_separate", paste0(thisID, ".csv")))
  
}

library(dplyr)
source(here::here("functions", "wf.R"))


portal_timesteps <- portalr::plant_abundance(level = "Treatment", type = "All", plots = "longterm")

portal_timesteps_communities <- portal_timesteps %>%
  mutate(season = paste0(year, season, substr(treatment, 0, 1))) %>%
  rename(siteID = season) %>%
  filter(abundance > 0) %>%
  select(-species, -quads, -nplots)


portal_richness <- portal_timesteps_communities %>%
  group_by(siteID) %>%
  summarize(rich = dplyr::n(),
            abund = sum(abundance)) %>%
  filter(abund < 5000)


portal_ts_sites <- unique(portal_richness$siteID)

portal_sads <- lapply(portal_ts_sites, FUN = extract_sad, macd_data = portal_timesteps_communities)

names(portal_sads) <- portal_ts_sites

portal_sads <- plyr::compact(portal_sads)

kept_sites <- names(portal_sads)

#portal_sads <- portal_sads[1:10]

portal_outputs <- lapply(portal_sads, full_workflow)

portal_results <- dplyr::bind_rows(portal_outputs, .id = "siteID")

save.image("portal_plant_output.RData")


write.csv(portal_results, here::here("results", "portal_rodent_results.csv"))

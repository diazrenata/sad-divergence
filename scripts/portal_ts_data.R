library(dplyr)
source(here::here("functions", "wf.R"))


portal_timesteps <- portalr::abundance(time = "all", type = "Granivores", level = "treatment", plots = "longterm")

portal_timesteps_communities <- portal_timesteps %>%
  filter(treatment == "control") %>%
  mutate(month = as.numeric(substr(censusdate, 6, 7)),
         year = as.numeric(substr(censusdate, 0, 4))) %>%
  mutate(season = ifelse(
    month %in% 4:9,
    paste0("summer", year),
    ifelse(month %in% 1:3,
    paste0("winter", year),
    paste0("winter", year + 1))
  )) %>%
  select(season, BA:RO) %>%
  rename(siteID = season) %>%
  tidyr::pivot_longer(-siteID, names_to = "species", values_to = "abundance") %>%
  filter(abundance > 0) %>%
  select(-species)


portal_richness <- portal_timesteps_communities %>%
  group_by(siteID) %>%
  summarize(rich = dplyr::n(),
            abund = sum(abundance)) 


portal_ts_sites <- unique(portal_timesteps_communities$siteID)

portal_sads <- lapply(portal_ts_sites, FUN = extract_sad, macd_data = portal_timesteps_communities)

names(portal_sads) <- portal_ts_sites

portal_sads <- plyr::compact(portal_sads)

kept_sites <- names(portal_sads)

#portal_sads <- portal_sads[1:10]

portal_outputs <- lapply(portal_sads, full_workflow)

portal_results <- dplyr::bind_rows(portal_outputs, .id = "siteID")

save.image("portal_output.RData")


write.csv(portal_results, here::here("results", "portal_rodent_results.csv"))

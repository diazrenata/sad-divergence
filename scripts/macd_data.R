library(dplyr)
source(here::here("functions", "wf.R"))

macd_communities <- read.csv(here::here("data", "macd", "community_analysis_data.csv")) 

macd_sites <- unique(macd_communities$siteID)

macd_sads <- lapply(macd_sites, FUN = extract_sad, macd_data = macd_communities)

names(macd_sads) <- macd_sites

macd_sads <- plyr::compact(macd_sads)

kept_sites <- names(macd_sads)

#macd_sads <- macd_sads[1:10]

macd_outputs <- lapply(macd_sads, full_workflow)

macd_results <- dplyr::bind_rows(macd_outputs, .id = "siteID")

save.image("macd_output.RData")
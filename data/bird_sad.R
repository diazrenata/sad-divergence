library(dplyr)

bird_sad <- birdsize::new_hartford_clean %>%
  select(aou, speciestotal) %>%
  rename("species" = "aou",
         "n" = "speciestotal") %>%
  arrange((n)) %>%
  mutate(rank = dplyr::row_number())

write.csv(bird_sad, here::here("data", "bird_sad.csv"), row.names = F)

# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline # nolint

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes) # Load other packages as needed. # nolint
library(tibble)
# Set target options:
tar_option_set(
  packages = c("tibble", "readr", "here", "dplyr"), # packages that your targets need to run
  format = "rds" # default storage format
  # Set other options as needed.
)

# tar_make_clustermq() configuration (okay to leave alone):
options(clustermq.scheduler = "multiprocess")

# tar_make_future() configuration (okay to leave alone):
# Install packages {{future}}, {{future.callr}}, and {{future.batchtools}} to allow use_targets() to configure tar_make_future() options.

# Run the R scripts in the R/ folder with your custom functions:
#tar_source()
source(here::here("plants_targets", "R", "wf.R")) # Source other scripts as needed. # nolint

nsites <- 224 #all is 224

data_files <- tibble(filename = list.files(("plants_targets/pre_pipeline/all_data_separate/"), full.names = T)[1:nsites],
                     tarname = stringr::str_remove(list.files(("plants_targets/pre_pipeline/all_data_separate/"), full.names = F), ".csv")[1:nsites])

targets1 <- tarchetypes::tar_map(
  values = data_files,
  tar_target(dat, read.csv(filename)),
  tar_target(
    sad, extract_sad(dat)
    ),
  tar_target(analysis, full_workflow(sad)),
  names = tarname
)

targets2 <- tarchetypes::tar_combine(name = all_analyses, targets1$analysis, command = bind_rows(!!!.x, .id = "siteID"))


list(targets1, targets2)
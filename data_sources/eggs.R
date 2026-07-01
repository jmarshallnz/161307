library(tidyverse)

# From here: 

# https://www.stats.govt.nz/assets/Uploads/Selected-price-indexes/Selected-price-indexes-May-2026/Download-data/selected-price-indexes-may-2026.csv

prices <- read_csv("data_sources/raw/selected-price-indexes-may-2026.csv")

prices |>
  filter(str_detect("Eggs", Series_title_1)) |>
  print(n=200)

arxiv <- read_csv("data_sources/raw/get_monthly_submissions.csv") |>
  mutate(month = ym(month)) |>
  select(month, arxiv=submissions)
biorxiv <- read_csv("data_sources/raw/biorxiv.csv") |>
  mutate(month = my(Month)) |>
  select(month, biorxiv=`New Papers`)

biorxiv 
both <- arxiv |> full_join(biorxiv, by=join_by(month))

write_csv(both, "data/arxiv_submissions.csv")

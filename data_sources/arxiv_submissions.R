library(tidyverse)

# Google: arxiv submissions by month data
# Google: biorxiv submissions by month data

arxiv <- read_csv("data_sources/raw/get_monthly_submissions.csv") |>
  mutate(month = ym(month)) |>
  select(month, arxiv=submissions)
biorxiv <- read_csv("data_sources/raw/biorxiv.csv") |>
  mutate(month = my(Month)) |>
  select(month, biorxiv=`New Papers`)

biorxiv 
both <- arxiv |> full_join(biorxiv, by=join_by(month))

write_csv(both, "data/arxiv_submissions.csv")

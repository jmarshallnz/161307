library(tidyverse)

solar <- read_csv("data_sources/raw/5885831_custom_report.csv")
solar |>
  mutate(date = mdy_hm(`Date/Time`)) |>
  mutate(month = month(date, label=TRUE)) |>
  group_by(month) |>
  summarise(produced = sum(`Energy Produced (Wh)`)) |>
  write_csv("data/solar_by_month.csv")

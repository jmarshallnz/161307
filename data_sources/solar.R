library(tidyverse)

solar <- read_csv("data_sources/raw/5885831_custom_report.csv")
sol <- solar |>
  mutate(date = mdy_hm(`Date/Time`)) |>
  mutate(day = yday(date)) |>
  group_by(day) |>
  summarise(produced = sum(`Energy Produced (Wh)`))


# fit simple smoother by duplication
foo <- bind_rows(sol, sol, sol, .id='wch') |>
  mutate(day = (day-1)+365*(as.numeric(wch)-2))

library(mgcv)
library(broom)
gam(produced ~ s(day), data=foo) |>
  augment(foo) |>
  filter(wch == 2) |>
  select(produced, smoothed=.fitted, day) |>
  write_csv("data/solar_by_day.csv")

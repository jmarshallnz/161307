library(tidyverse)

# From here: 

# https://www.stats.govt.nz/assets/Uploads/Selected-price-indexes/Selected-price-indexes-May-2026/Download-data/selected-price-indexes-may-2026.csv

prices <- read_csv("data_sources/raw/selected-price-indexes-may-2026.csv")

eggs <- prices |>
  filter(str_detect(Series_title_1, "Eggs,")) |>
  mutate(month = ym(as.character(Period))) |>
  select(month, price = Data_value, product = Series_title_1) |>
  mutate(price = if_else(str_detect(product, "6 pack"), price*10/6, price)) |>
  mutate(product = fct_recode(product,
                              Standard = "Eggs, dozen",
                              `Free range` = "Eggs, free range, 6 pack"))

write_csv(eggs, "data/eggs.csv")

ggplot(eggs) +
  aes(x=month, y=price, col=product) +
  geom_line()

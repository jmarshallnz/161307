library(tidyverse)

# sources (unsure if URLs are stable)
# "Population by year" table
# https://figure.nz/table/NteyKZu48ZHuqab1

population <- read_csv("https://figure.nz/table/NteyKZu48ZHuqab1/download") |>
  janitor::clean_names() |>
  select(-null_reason, -metadata_1)

population |> filter(measure == "Estimated population",
                     unit == "Total") |>
  select(year = year_ended_june, population = value) |>
  write_csv("data/nz_population.csv")

# "Agricultural production" table
# https://figure.nz/table/p362oPSvhp76DLUL

ag_prod <- read_csv("https://figure.nz/table/p362oPSvhp76DLUL/download") |>
  janitor::clean_names() |>
  select(-null_reason, -metadata_1)

#ag_prod |> count(measure) |>

ag_prod |> filter(str_detect(measure, "Total")) |>
  mutate(animal = str_sub(measure, 7)) |>
  filter(animal %in% c("Beef Cattle", "Dairy Cattle (including Bobby Calves)",
                       "Deer", "Pigs", "Sheep", "goats", "poultry")) |>
  mutate(animal = fct_recode(animal,
                    `Dairy Cattle` = "Dairy Cattle (including Bobby Calves)"),
         animal = fct_relabel(animal, str_to_title)) |>
  select(year = year_ended_june,
         animal, value) |>
  write_csv("data/ag_production.csv")

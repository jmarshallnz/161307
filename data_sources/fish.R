# data prep for multivariate lab

library(readxl)
library(tidyverse)

fish <- read.csv("raw/seine_fish_19_24.csv")

# generate species by sampling event matrix

fish_summary <- fish %>%
  # filter(class == "Elasmobranchii" | class == "Actinopteri")  %>%
  filter(species_code != "NOSP") %>% filter( !site_pair %in% c("A", "B", "C")) 
fish_summary2 <- fish_summary %>%
  # filter(!is.na(scientificname_accepted))  %>%  # drops nearly 100 samples, don't want that. It drops some identified samples, why dont they have a name
  mutate(scientificname_accepted = case_when(
    species_code == "YOY" ~ "Young of the Year",
    species_code == "SCAR" ~ "Sebastes carnatus", 
    species_code == "EMBI" ~ "Embiotocidae",
    species_code == "OTRI" ~ "Orthonopias triacis",
    species_code == "SCAU" ~ "Sebastes caurinus", # gorpher rockfish
    species_code == "HALI" ~ "Unidentified halibut",
    species_code == "GAST" ~ "Gasterostidae",
    species_code == "MULL" ~ "mullet",
    species_code == "FFUN" ~ "flounder",
    species_code == "OTSH" ~ "Oncorhynchus tshawytscha",
    .default = as.character(scientificname_accepted)
  )) %>% 
  filter(!is.na(scientificname_accepted)) %>%  # now the only NA is FISH
  #group_by(region, site_name, scientificname_accepted, year, month_day, month, day, site_pair)
  group_by(region, site_name, scientificname_accepted, site_pair, mpa_status) %>% summarise(no_fish = sum(count))


Fish_gr <- read.csv("raw/Fish_sp_drive.csv")

fish_gr_2 <- Fish_gr |> 
  # filter(!is.na(scientificname_accepted))  %>%  # drops nearly 100 samples, don't want that. It drops some identified samples, why dont they have a name
  mutate(scientificname_accepted = case_when(
    species_code == "YOY" ~ "Young of the Year",
    species_code == "SCAR" ~ "Sebastes carnatus", 
    species_code == "EMBI" ~ "Embiotocidae",
    species_code == "OTRI" ~ "Orthonopias triacis",
    species_code == "SCAU" ~ "Sebastes caurinus", # gorpher rockfish
    species_code == "HALI" ~ "Unidentified halibut",
    species_code == "GAST" ~ "Gasterostidae",
    species_code == "MULL" ~ "mullet",
    species_code == "FFUN" ~ "flounder",
    species_code == "OTSH" ~ "Oncorhynchus tshawytscha",
    .default = as.character(scientificname_accepted)
  ),na.rm = TRUE) 


fish_summary_grps <- fish_summary2 |> 
  left_join(fish_gr_2 |>  
              select(scientificname_accepted,funct_grouping), by = "scientificname_accepted") 

fish_summary_grps <- fish_summary_grps |> 
  mutate(funct_grouping = if_else(scientificname_accepted == "Stellerina xyosterna","Agonidae", funct_grouping))

# Stellerina xyosterna was missing in familyish

func_fish_summary_grps <- fish_summary_grps|>  
  #group_by(region, site_name, funct_grouping, year, month_day, day, month, site_pair) |>
  group_by(region, site_name, funct_grouping, site_pair, mpa_status) |>
  summarise(no_fish = sum(no_fish))

fish_wide_func <- pivot_wider(data = func_fish_summary_grps,
                              names_from = funct_grouping, 
                              values_from = no_fish,
                              values_fill = 0)


wrack_data_datone1 <- read.csv("raw/wrack_data_datone_2024update.csv", row.names = 1) 

#**** wide site by wrack type weight *****

wrack_summary_by_type <- wrack_data_datone1 |> 
  filter(!site_pair %in% c("A", "B", "C")) |> 
  #group_by(region, site_name, type, year, month, day, site_pair) %>%
  group_by(region, site_name, type, site_pair, mpa_status) %>%
  summarise(wrack_type_wg = sum(total_wet_weight_g)/1000,
            num_sites = length(unique(site_name)),
            # num_surveys = length(unique(paste0(site_name, "_", year,
            #                                    "_", month, "_",day)))
  )

wrack_wide <- pivot_wider(data = wrack_summary_by_type,
                          names_from = type, 
                          values_from = wrack_type_wg,
                          values_fill = 0)


# join --------------------------------------------------------------------


func_fish_wide_wrack <- left_join(wrack_wide, fish_wide_func,
                                  by = c("region",  "site_name", "site_pair", "mpa_status")) 

func_fish_wide_wrack[,13:25][is.na(func_fish_wide_wrack[,13:25])] <- 0

# removes observations with less than 5 fish

func_fish_wide_wrack <- func_fish_wide_wrack[][rowSums(func_fish_wide_wrack[,13:25]) > 5, ]

# remove obs. with 0 weight, again just in case

func_fish_wide_wrack <- func_fish_wide_wrack[][rowSums(func_fish_wide_wrack[,6:10]) > 0, ]

write.csv(func_fish_wide_wrack, "../data/func_fish_wide_wrack.csv", row.names = FALSE)

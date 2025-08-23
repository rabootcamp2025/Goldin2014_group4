pacman::p_load(tidyverse, foreign, haven)


#データの読み込み
df_0911 <- readRDS("D:/Goldin2014_group4/Fig1/data/original/df_0911_original.rds")

View(df_0911)

df_0911_filter <- df_0911

#データのフィルター
df_0911_filter <- df_0911_filter |>
  filter(uhrswork >= 35, wkswork2 >=4) |>
  filter(educ %in% c(10,11)) |>
  filter(race == 1) |>
  filter(bpl <= 120) |>
  filter(occ1950 != 595, occ1950 != 999)

df_0911_filter <- df_0911_filter |>
  filter(age >= 25, age <= 69)
  
saveRDS(df_0911_filter, "Fig1/data/cleaned/df_0911_filter.rds")

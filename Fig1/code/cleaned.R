pacman::p_load(tidyverse, foreign, haven, estimatr, fixest)


#データの読み込み
df_0911 <- readRDS("D:/Goldin2014_group4/Fig1/data/original/df_0911_original.rds")


df_0911_filter <- df_0911

#データのフィルター
df_0911_filter <- df_0911_filter |>
  filter(uhrswork >= 35, wkswork2 >=4) |>　#35時間以上、40週間以上
  filter(educ %in% c(10,11)) |> #教育年数16年以上
  filter(race == 1) |> #白人
  filter(bpl <= 99) |>　#出生地がアメリカ
  filter(occ1950 != 595, occ1950 != 999) #non-military

df_0911_filter <- df_0911_filter |>
  filter(age >= 25, age <= 69) #25歳以上69歳以下
  

#wage
df_0911_filter <- df_0911_filter |>
  mutate(incwage = case_when( 
    incwage == 999999 ~ NA_real_,
    incwage < 0 ~ NA_real_,
    TRUE ~ incwage))

df_0911_filter <- df_0911_filter |>
  mutate(incbus00 = case_when(
    incbus00 == 999999 ~ NA_real_,
    incbus00 < 0 ~ NA_real_,
    TRUE ~ incbus00))

df_0911_filter <- df_0911_filter |>
  filter(is.na(incwage) == FALSE | is.na(incbus00) == FALSE)

df_0911_filter <- df_0911_filter |>
  mutate(incwage = case_when(
    is.na(incwage) ~ 0,
    TRUE ~ incwage)) |>
  mutate(incbus00 = case_when(
    is.na(incbus00) ~ 0,
    TRUE ~ incbus00)) |>
  mutate(incwbf = incwage + incbus00)


#Annual minimum wage $2009 values(1/2*2009 minwage*full time*full year hours )
min09 <- 0.5*7.25*35*40

#min09を超えている人だけ残す
df_0911_filter <- df_0911_filter |>
  filter(incwbf >= min09)

#age cohort作成
df_0911_filter <- df_0911_filter |>
  mutate(agegroup = case_when(
    age >=25 & age < 30 ~ 1,
    age >=30 & age < 35 ~ 2,
    age >=35 & age < 40 ~ 3,
    age >=40 & age < 45 ~ 4,
    age >=45 & age < 50 ~ 5,
    age >=50 & age < 55 ~ 6,
    age >=55 & age < 60 ~ 7,
    age >=60 & age < 65 ~ 8,
    age >=65 & age < 70 ~ 9
  ))

#男女
df_0911_filter <- df_0911_filter |>
  filter(sex != 9)

#被説明変数に賃金の対数、説明変数にfemaleダミー、agegroupのダミー（計9-1=8個）、femaleとagegroupの交差項（計9-1=8個））

df_0911_filter <- df_0911_filter |>
  mutate(female = case_when(
    sex == 2 ~ 1,
    TRUE ~ 0))

df_0911_filter <- df_0911_filter |>
  mutate(lnincwbf = log(incwbf))


df_0911_filter <- df_0911_filter |>
  mutate(
    agegroup = factor(agegroup)
  )

df_0911_reg <- 
  df_0911_filter %>% 
  fastDummies::dummy_cols("agegroup", remove_first_dummy = T) %>% 
  mutate(
    fage2 = female * agegroup_2,
    fage3 = female * agegroup_3,
    fage4 = female * agegroup_4,
    fage5 = female * agegroup_5,
    fage6 = female * agegroup_6,
    fage7 = female * agegroup_7,
    fage8 = female * agegroup_8,
    fage9 = female * agegroup_9
  )
  
  
#回帰式実行
model_1 <- lm_robust(lnincwbf ~ female + agegroup_2 + agegroup_3 +agegroup_4 +
                       agegroup_5 +agegroup_6 +agegroup_7 +agegroup_8 +agegroup_9 +
                       fage2 + fage3 + fage4 + fage5 + fage6 + fage7 + fage8 + fage9 
                     , data = df_0911_reg, weights = perwt)

summary(model_1)

coef <- model_1$coefficients

coef




#データセーブ
saveRDS(df_0911_filter, "Fig1/data/cleaned/df_0911_filter.rds")



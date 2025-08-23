pacman::p_load(tidyverse, foreign, haven)

#2010年データ

#full-time (+35 hours)
X0911 <- read_dta("Fig1/data/raw/0911.dta")

x0911

df_0911 <- X0911 |>
  select(-sample, -serial, -cbserial, -cluster, -strata, -hhwt, -gq, -pernum, -nchild, -nchlt5, -raced, -bpld, -educd)

df_0911

saveRDS(df_0911, "Fig1/data/original/df_0911_original.rds")

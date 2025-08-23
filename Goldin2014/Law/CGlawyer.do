*do file for SH's original Michigan data, this is for the original Hurder data but can be adapted to newer version
*difference is the SH's data restrict to JD age <= 30 and classes with full job exp data (1982-1991) and returned_5, returned_15 == 1
*note that you did a lot of correcting below for the missing vars so that they aren't counted as zeros
***
*first load Hurder data, then do variable names
use lawyerlongit
do lawyervars
***
log using CGlawyerLog, t replace
*use lawyerlongit <did this already>
*do lawyervars  <did this already>
***
*next correct the zeros issue for loghrs
*note that you could use the 0s and add missinghourswk_X var
replace loghourswk_15 = . if hrsperwk_15 == 0 | hrsperwk_15 == .
replace loghourswk_5 = . if hrsperwk_5 == 0 | hrsperwk_5 == .
***
*in search of non-linearities in payment with respect to hours of work in year 15
gen loghrind40_15 = loghourswk_15 - log(40) if hrsperwk_15 >= 40
replace loghrind40_15 = 0 if hrsperwk_15 < 40 & hrsperwk_15 ~= 0 & hrsperwk_15 ~= .

gen loghrind43_15 = loghourswk_15 - log(43) if hrsperwk_15 >= 43
replace loghrind43_15 = 0 if hrsperwk_15 < 43 & hrsperwk_15 ~= 0 & hrsperwk_15 ~= .

gen loghrind45_15 = loghourswk_15 - log(45) if hrsperwk_15 >= 45
replace loghrind45_15 = 0 if hrsperwk_15 < 45 & hrsperwk_15 ~= 0 & hrsperwk_15 ~= .

*incomes for those who begin in law firms (wksetting == 1) and who work in both periods

table female if returned_5 == 1 & returned_15 == 1 & wksetting_5 == 1 & hrsperwk_5 > 9 & hrsperwk_15 > 9, c(mean logincadj_5 mean logincadj_15)

*stayers in law firms
table female if returned_5 == 1 & returned_15 == 1 & wksetting_5 == 1 & wksetting_15 == 1 & hrsperwk_5 > 9 & hrsperwk_15 > 9, c(mean logincadj_5 mean logincadj_15)
table female if returned_5 == 1 & returned_15 == 1 & wksetting_5 == 1 & wksetting_15 == 1 & hrsperwk_5 > 9 & hrsperwk_15 > 9, c(mean hrsperwk_5 mean hrsperwk_15)

*movers from law firms
table female if returned_5 == 1 & returned_15 == 1 & wksetting_5 == 1 & wksetting_15 ~= 1 & hrsperwk_5 > 9 & hrsperwk_15 > 9, c(mean logincadj_5 mean logincadj_15)
table female if returned_5 == 1 & returned_15 == 1 & wksetting_5 == 1 & wksetting_15 ~= 1 & hrsperwk_5 > 9 & hrsperwk_15 > 9, c(mean hrsperwk_5 mean hrsperwk_15)

*movers to law firms
table female if returned_5 == 1 & returned_15 == 1 & wksetting_5 ~= 1 & wksetting_15 == 1 & hrsperwk_5 > 9 & hrsperwk_15 > 9, c(mean logincadj_5 mean logincadj_15)
table female if returned_5 == 1 & returned_15 == 1 & wksetting_5 ~= 1 & wksetting_15 == 1 & hrsperwk_5 > 9 & hrsperwk_15 > 9, c(mean hrsperwk_5 mean hrsperwk_15)

*never in law firm
table female if returned_5 == 1 & returned_15 == 1 & wksetting_5 ~= 1 & wksetting_15 ~= 1 & hrsperwk_5 > 9 & hrsperwk_15 > 9, c(mean logincadj_5 mean logincadj_15)
table female if returned_5 == 1 & returned_15 == 1 & wksetting_5 ~= 1 & wksetting_15 ~= 1 & hrsperwk_5 > 9 & hrsperwk_15 > 9, c(mean hrsperwk_5 mean hrsperwk_15)

*out in year 5, in year 15
table female if returned_5 == 1 & returned_15 == 1 & wksetting_5 == 0 & wksetting_15 ~= 0 & hrsperwk_5 > 9 & hrsperwk_15 > 9, c(mean logincadj_15)
table female if returned_5 == 1 & returned_15 == 1 & wksetting_5 == 0 & wksetting_15 ~= 0 & hrsperwk_5 > 9 & hrsperwk_15 > 9, c(mean hrsperwk_15)

*out in year 15, in year 5
table female if returned_5 == 1 & returned_15 == 1 & wksetting_5 ~= 0 & wksetting_15 == 0 & hrsperwk_5 > 9 & hrsperwk_15 > 9, c(mean logincadj_5)
table female if returned_5 == 1 & returned_15 == 1 & wksetting_5 ~= 0 & wksetting_15 == 0 & hrsperwk_5 > 9 & hrsperwk_15 > 9, c(mean hrsperwk_5)

*Children variables
*fix ch06_year variable which indicates whether the kids are < 7 years conditional on having children
replace ch06_5 = 0 if ch06_5 == . & ch_5 ~= .
replace ch06_15 = 0 if ch06_15 == . & ch_15 ~= .
gen Fch_15 = female * ch_15
gen Fch6_15 = female * ch06_15
gen Fch_5 = female * ch_5
gen Fch6_5 = female * ch06_5

*Labor force
gen out_5 = wksetting_5 == 0
gen out_15 = wksetting_15 == 0

*Income change
gen logincch = (logincadj_15 - logincadj_5) if returned_5 == 1 & returned_15 == 1

*Job experience
*experience is measured in months, change to years
replace exp_15 = exp_15/12
replace exp_5 = exp_5/12


***job transitions
*define via wksetting vars if in law firm (LF) or not, can be out of the labor force if 0 or in another sector or not practicing as a lawyer

gen occLF11 = 1 if wksetting_5 == 1 & wksetting_15 == 1 & returned_5 == 1 & returned_15 == 1
gen occLF10 = 1 if wksetting_5 == 1 & wksetting_15 ~= 1 & returned_5 == 1 & returned_15 == 1
gen occLF00 = 1 if wksetting_5 ~= 1 & wksetting_15 ~= 1 & returned_5 == 1 & returned_15 == 1
gen occLF01 = 1 if wksetting_5 ~= 1 & wksetting_15 == 1 & returned_5 == 1 & returned_15 == 1

replace occLF11 = 0 if occLF11 == . & returned_5 == 1 & returned_15 == 1
replace occLF10 = 0 if occLF10 == . & returned_5 == 1 & returned_15 == 1
replace occLF00 = 0 if occLF00 == . & returned_5 == 1 & returned_15 == 1
replace occLF01 = 0 if occLF01 == . & returned_5 == 1 & returned_15 == 1

*define partner in a law firm, define lawfirm
gen partner_15 = 1 if wksetting_15 == 1 & attystatus_15 == 2
replace partner_15 = 0 if partner_15 == .
gen partner_5 = 1 if wksetting_5 == 1 & attystatus_5 == 2
replace partner_5 = 0 if partner_5 == .
gen lawfirm_5 = wksetting_5 == 1
gen lawfirm_15 = wksetting_15 == 1

*marital issues
gen Fspouseprof_15 = female * spouseprof_15

***
*regressions on the LONGITUDINAL data
***
*note that you have to get rid of the really low hours people
*you also got rid of the missing hours people, alternatively you can use missinghrswk_X var

*15 year baselines and beyond
*note that lsgpa matters but not lawreview and lsatperc when lsgpa is added, there is one guy with missing timeoff
areg logincadj_15 female if returned_5 == 1 & returned_15 == 1 & hrsperwk_15 > 9 [aw=weight_15], absorb(surveyyear_15)
areg logincadj_15 female lsgpa lawreview if returned_5 == 1 & returned_15 == 1 & hrsperwk_15 > 9 [aw=weight_15], absorb(surveyyear_15)
areg logincadj_15 female lsgpa lawreview loghourswk_15 logwksyr_15 if returned_5 == 1 & returned_15 == 1 & hrsperwk_15 > 9 [aw=weight_15], absorb(surveyyear_15)
areg logincadj_15 female lsgpa lawreview loghourswk_15 logwksyr_15 yrspt_15 exp_15 missingexp_15 if returned_5 == 1 & returned_15 == 1 & hrsperwk_15 > 9 [aw=weight_15], absorb(surveyyear_15)
areg logincadj_15 female lsgpa lawreview loghourswk_15 logwksyr_15 yrspt_15 exp_15 missingexp_15 timeoff if returned_5 == 1 & returned_15 == 1 & hrsperwk_15 > 9 [aw=weight_15], absorb(surveyyear_15)

*add partner, no difference if interaction with female and partner is added
areg logincadj_15 female lsgpa lawreview loghourswk_15 logwksyr_15 exp_15 yrspt_15 missingexp_15 timeoff partner_15 if returned_15 == 1 & returned_5 == 1 & hrsperwk_15 > 9 [aw=weight_15], absorb(surveyyear_15)
areg logincadj_15 female lsgpa lawreview loghourswk_15 logwksyr_15 exp_15 yrspt_15 missingexp_15 timeoff partner_15 occLF11 if returned_15 == 1 & returned_5 == 1 & hrsperwk_15 > 9 [aw=weight_15], absorb(surveyyear_15)

*15 year extended to include job site and family variables, note that kids does not matter differentially by sex except women have fewer
*timeoff = between BA and LS entry
areg logincadj_15 female lsgpa lawreview loghourswk_15 logwksyr_15 exp_15 missingexp_15 yrspt_15 occLF11 partner_15 if returned_15 == 1 & returned_5 == 1 & hrsperwk_15 > 9 [aw=weight_15], absorb(surveyyear_15)
areg logincadj_15 female lsgpa lawreview loghourswk_15 logwksyr_15 exp_15 yrspt_15 missingexp_15 timeoff if returned_15 == 1 & returned_5 == 1 & hrsperwk_15 > 9 [aw=weight_15], absorb(surveyyear_15)
areg logincadj_15 female lsgpa lawreview loghourswk_15 logwksyr_15 exp_15 yrspt_15 missingexp_15 timeoff ch_15 if returned_15 == 1 & returned_5 == 1 & hrsperwk_15 > 9 [aw=weight_15], absorb(surveyyear_15)
areg logincadj_15 female lsgpa lawreview loghourswk_15 logwksyr_15 exp_15 yrspt_15 missingexp_15 timeoff ch_15 yrscurrjob_15 missingyrscurrjob_15 partner_15 if returned_15 == 1 & returned_5 == 1 & hrsperwk_15 > 9 [aw=weight_15], absorb(surveyyear_15)

*5 year baselines and beyond

areg logincadj_5 female if returned_5 == 1 & returned_15 == 1 & hrsperwk_5 > 9 [aw=weight_5], absorb(surveyyear_5)
areg logincadj_5 female lsgpa lawreview if returned_5 == 1 & returned_15 == 1 & hrsperwk_5 > 9 [aw=weight_5], absorb(surveyyear_5)
areg logincadj_5 female lsgpa lawreview loghourswk_5 logwksyr_5 if returned_5 == 1 & returned_15 == 1 & hrsperwk_5 > 9 [aw=weight_5], absorb(surveyyear_5)
areg logincadj_5 female lsgpa lawreview loghourswk_5 logwksyr_5 yrspt_5 exp_5 missingexp_15 if returned_5 == 1 & returned_15 == 1 & hrsperwk_5 > 9 [aw=weight_5], absorb(surveyyear_5)
areg logincadj_5 female lsgpa lawreview loghourswk_5 logwksyr_5 yrspt_5 exp_5 missingexp_15 timeoff if returned_5 == 1 & returned_15 == 1 & hrsperwk_5 > 9 [aw=weight_5], absorb(surveyyear_5)

***Note that there is nothing, it appears, that can bring the coefficient on female below around 0.09 at year 15.

*5 year extended to include job site and family variables
*note that kids do matter a lot in year 5 but married does not, given kids
areg logincadj_5 female lsgpa lawreview loghourswk_5 logwksyr_5 exp_5 missingexp_5 yrspt_5 occLF11 partner_5 if returned_15 == 1 & returned_5 == 1 & hrsperwk_5 > 9 [aw=weight_5], absorb(surveyyear_5)
areg logincadj_5 female lsgpa lawreview loghourswk_5 logwksyr_5 exp_5 missingexp_5 yrspt_5 timeoff if returned_15 == 1 & returned_5 == 1 & hrsperwk_5 > 9 [aw=weight_5], absorb(surveyyear_5)
areg logincadj_5 female lsgpa lawreview loghourswk_5 logwksyr_5 exp_5 missingexp_5 yrspt_5 timeoff ch_5 Fch_5 if returned_15 == 1 & returned_5 == 1 & hrsperwk_5 > 9 [aw=weight_5], absorb(surveyyear_5)
areg logincadj_5 female lsgpa lawreview loghourswk_5 logwksyr_5 exp_5 missingexp_5 yrspt_5 timeoff ch06_5 Fch6_5 if returned_15 == 1 & returned_5 == 1 & hrsperwk_5 > 9 [aw=weight_5], absorb(surveyyear_5)

**note that you can extend the jdyr group by not restricting the sample to be the longitudinal one
**note that you weight using the Hurder weight but it doesn't change much that you have explored
**note that almost nothing you just did uses the longitudinal nature of the data (except job experience, etc.) although you restrict it in this way

***Hours analysis
*Look at hours by first position and by transition
*this is for the bar chart, note that LF means LAW FIRM, not labor force

sort female

** Year 5

by female: sum hrsperwk_5 if returned_5 == 1 & returned_15 == 1 & occLF11 == 1 & hrsperwk_5 > 9 [aw=weight_5]
by female: sum hrsperwk_5 if returned_5 == 1 & returned_15 == 1 & occLF10 == 1 & hrsperwk_5 > 9 [aw=weight_5]
by female: sum hrsperwk_5 if returned_5 == 1 & returned_15 == 1 & occLF01 == 1 & hrsperwk_5 > 9 [aw=weight_5]
by female: sum hrsperwk_5 if returned_5 == 1 & returned_15 == 1 & occLF00 == 1& hrsperwk_5 > 9 [aw=weight_5]
by female: sum hrsperwk_5 if returned_5 == 1 & returned_15 == 1 & out_5 == 0 & out_15 == 1 & hrsperwk_5 > 9 [aw=weight_5]

*separating out making partner by year 15

by female: sum hrsperwk_5 if returned_5 == 1 & returned_15 == 1 & occLF11 == 1 & partner_15 == 1 & hrsperwk_5 > 9 [aw=weight_5]
by female: sum hrsperwk_5 if returned_5 == 1 & returned_15 == 1 & occLF11 == 1 & partner_15 == 0 & hrsperwk_5 > 9 [aw=weight_5]
by female: sum hrsperwk_5 if returned_5 == 1 & returned_15 == 1 & occLF01 == 1 & partner_15 == 1 & hrsperwk_5 > 9 [aw=weight_5]

** Year 15

by female: sum hrsperwk_15 if returned_5 == 1 & returned_15 == 1 & occLF11 == 1 & hrsperwk_15 > 9 [aw=weight_15]
by female: sum hrsperwk_15 if returned_5 == 1 & returned_15 == 1 & occLF10 == 1 & hrsperwk_15 > 9 [aw=weight_15]
by female: sum hrsperwk_15 if returned_5 == 1 & returned_15 == 1 & occLF01 == 1 & hrsperwk_15 > 9 [aw=weight_15]
by female: sum hrsperwk_15 if returned_5 == 1 & returned_15 == 1 & occLF00 == 1 & hrsperwk_15 > 9 [aw=weight_15]
by female: sum hrsperwk_15 if returned_5 == 1 & returned_15 == 1 & out_5 == 1 & out_15 == 0 & hrsperwk_15 > 9  [aw=weight_15]

*separating out partners by year 15

by female: sum hrsperwk_15 if returned_5 == 1 & returned_15 == 1 & occLF11 == 1 & partner_15 == 1 & hrsperwk_15 > 9 [aw=weight_15]
by female: sum hrsperwk_15 if returned_5 == 1 & returned_15 == 1 & occLF11 == 1 & partner_15 == 0 & hrsperwk_15 > 9 [aw=weight_15]
by female: sum hrsperwk_15 if returned_5 == 1 & returned_15 == 1 & occLF01 == 1 & partner_15 == 1 & hrsperwk_15 > 9 [aw=weight_15]

*part-time  (note that part-time is derived from hours so it is fine whereas exp does not exist for all cohorts)
** Year 5

by female: sum ptnow_5 if returned_5 == 1 & returned_15 == 1 & occLF11 == 1 & hrsperwk_5 > 9 [aw=weight_5]
by female: sum ptnow_5 if returned_5 == 1 & returned_15 == 1 & occLF10 == 1 & hrsperwk_5 > 9 [aw=weight_5]
by female: sum ptnow_5 if returned_5 == 1 & returned_15 == 1 & occLF01 == 1 & hrsperwk_5 > 9 [aw=weight_5]
by female: sum ptnow_5 if returned_5 == 1 & returned_15 == 1 & occLF00 == 1& hrsperwk_5 > 9 [aw=weight_5]
by female: sum ptnow_5 if returned_5 == 1 & returned_15 == 1 & out_5 == 0 & out_15 == 1 & hrsperwk_5 > 9 [aw=weight_5]

*separating out partners by year 15

by female: sum ptnow_5 if returned_5 == 1 & returned_15 == 1 & occLF11 == 1 & partner_15 == 1 & hrsperwk_5 > 9 [aw=weight_5]
by female: sum ptnow_5 if returned_5 == 1 & returned_15 == 1 & occLF11 == 1 & partner_15 == 0 & hrsperwk_5 > 9 [aw=weight_5]
by female: sum ptnow_5 if returned_5 == 1 & returned_15 == 1 & occLF01 == 1 & partner_15 == 1 & hrsperwk_5 > 9 [aw=weight_5]

** Year 15

by female: sum ptnow_15 if returned_5 == 1 & returned_15 == 1 & occLF11 == 1 & hrsperwk_15 > 9 [aw=weight_15]
by female: sum ptnow_15 if returned_5 == 1 & returned_15 == 1 & occLF10 == 1 & hrsperwk_15 > 9 [aw=weight_15]
by female: sum ptnow_15 if returned_5 == 1 & returned_15 == 1 & occLF01 == 1 & hrsperwk_15 > 9 [aw=weight_15]
by female: sum ptnow_15 if returned_5 == 1 & returned_15 == 1 & occLF00 == 1 & hrsperwk_15 > 9 [aw=weight_15]
by female: sum ptnow_15 if returned_5 == 1 & returned_15 == 1 & out_5 == 1 & out_15 == 0 & hrsperwk_15 > 9  [aw=weight_15]

*separating out partners by year 15

by female: sum ptnow_15 if returned_5 == 1 & returned_15 == 1 & occLF11 == 1 & partner_15 == 1 & hrsperwk_15 > 9 [aw=weight_15]
by female: sum ptnow_15 if returned_5 == 1 & returned_15 == 1 & occLF11 == 1 & partner_15 == 0 & hrsperwk_15 > 9 [aw=weight_15]
by female: sum ptnow_15 if returned_5 == 1 & returned_15 == 1 & occLF01 == 1 & partner_15 == 1 & hrsperwk_15 > 9 [aw=weight_15]

*By presence of children

by female: sum ptnow_15 if returned_5 == 1 & returned_15 == 1 & occLF11 == 1 & hrsperwk_15 > 9 & ch_15 == 1 [aw=weight_15]
by female: sum ptnow_15 if returned_5 == 1 & returned_15 == 1 & occLF10 == 1 & hrsperwk_15 > 9 & ch_15 == 1 [aw=weight_15]
by female: sum ptnow_15 if returned_5 == 1 & returned_15 == 1 & occLF01 == 1 & hrsperwk_15 > 9 & ch_15 == 1 [aw=weight_15]
by female: sum ptnow_15 if returned_5 == 1 & returned_15 == 1 & occLF00 == 1 & hrsperwk_15 > 9 & ch_15 == 1 [aw=weight_15]
by female: sum ptnow_15 if returned_5 == 1 & returned_15 == 1 & out_5 == 1 & out_15 == 0 & hrsperwk_15 > 9 & ch_15 == 1 [aw=weight_15]

by female: sum ptnow_15 if returned_5 == 1 & returned_15 == 1 & occLF11 == 1 & hrsperwk_15 > 9 & ch06_15 == 1 [aw=weight_15]
by female: sum ptnow_15 if returned_5 == 1 & returned_15 == 1 & occLF10 == 1 & hrsperwk_15 > 9 & ch06_15 == 1 [aw=weight_15]
by female: sum ptnow_15 if returned_5 == 1 & returned_15 == 1 & occLF01 == 1 & hrsperwk_15 > 9 & ch06_15 == 1 [aw=weight_15]
by female: sum ptnow_15 if returned_5 == 1 & returned_15 == 1 & occLF00 == 1 & hrsperwk_15 > 9 & ch06_15 == 1 [aw=weight_15]
by female: sum ptnow_15 if returned_5 == 1 & returned_15 == 1 & out_5 == 1 & out_15 == 0 & hrsperwk_15 > 9 & ch06_15 == 1 [aw=weight_15]

***Earnings
*Earnings to compute changes
by female: sum logincadj_5 if returned_5 == 1 & returned_15 == 1 & occLF11 == 1 & hrsperwk_5 > 9 [aw=weight_5]
by female: sum logincadj_5 if returned_5 == 1 & returned_15 == 1 & occLF10 == 1 & hrsperwk_5 > 9 [aw=weight_5]
by female: sum logincadj_5 if returned_5 == 1 & returned_15 == 1 & occLF01 == 1 & hrsperwk_5 > 9 [aw=weight_5]
by female: sum logincadj_5 if returned_5 == 1 & returned_15 == 1 & occLF00 == 1& hrsperwk_5 > 9 [aw=weight_5]
by female: sum logincadj_5 if returned_5 == 1 & returned_15 == 1 & out_5 == 0 & out_15 == 1 & hrsperwk_5 > 9 [aw=weight_5]

by female: sum logincadj_15 if returned_5 == 1 & returned_15 == 1 & occLF11 == 1 & hrsperwk_15 > 9 [aw=weight_15]
by female: sum logincadj_15 if returned_5 == 1 & returned_15 == 1 & occLF10 == 1 & hrsperwk_15 > 9 [aw=weight_15]
by female: sum logincadj_15 if returned_5 == 1 & returned_15 == 1 & occLF01 == 1 & hrsperwk_15 > 9 [aw=weight_15]
by female: sum logincadj_15 if returned_5 == 1 & returned_15 == 1 & occLF00 == 1 & hrsperwk_15 > 9 [aw=weight_15]
by female: sum logincadj_15 if returned_5 == 1 & returned_15 == 1 & out_5 == 1 & out_15 == 0 & hrsperwk_15 > 9  [aw=weight_15]

*Earnings changes (average) by person

by female: sum logincch if returned_5 == 1 & returned_15 == 1 & occLF11 == 1 & hrsperwk_5 > 9 & hrsperwk_15 > 9 [aw=weight_5]
by female: sum logincch if returned_5 == 1 & returned_15 == 1 & occLF10 == 1 & hrsperwk_5 > 9 & hrsperwk_15 > 9 [aw=weight_5]
by female: sum logincch if returned_5 == 1 & returned_15 == 1 & occLF01 == 1 & hrsperwk_5 > 9 & hrsperwk_15 > 9 [aw=weight_5]
by female: sum logincch if returned_5 == 1 & returned_15 == 1 & occLF00 == 1 & hrsperwk_5 > 9 & hrsperwk_15 > 9 [aw=weight_5]

*Role of children in determining work sector in year 15 and year 5
*note that the sample is larger b/c not conditioning on longit
*note that it is clear that women have kids much later than men, so ch06 and ch are different

table wksetting_15 female if returned_15 == 1, c(mean ch_15)
table wksetting_5 female if returned_5 == 1, c(mean ch_5)

*Various questions with some answers

*of married women who aren't working in year 15, what were they doing in year 5; same for those of high income hubbies
*answer is that about 10 percentage points fewer were in law firms in year 5
tab wksetting_5 if returned_5 == 1 & returned_15 == 1 & notempnow_15 == 1 & female == 1 & married_5 == 1 & hrsperwk_5 > 9 [aw=weight_5]
tab wksetting_5 if returned_5 == 1 & returned_15 == 1 & notempnow_15 == 0 & missingnotemp_15 ~= 1 & female == 1 & married_5 == 1 & hrsperwk_5 > 9 [aw=weight_5]
tab wksetting_5 if returned_5 == 1 & returned_15 == 1 & notempnow_15 == 1 & female == 1 & married_5 == 1 & spouseincadj_15 > 200000 & hrsperwk_5 > 9 [aw=weight_5]
tab wksetting_5 if returned_5 == 1 & returned_15 == 1 & notempnow_15 == 0 & missingnotemp_15 ~= 1 & female == 1 & married_5 == 1 & spouseincadj_15 > 200000 & hrsperwk_5 > 9 [aw=weight_5]

*income and hours before dropping out
*those ones who drop out AND had super high earning hubbies are very positively selected on income in year 5 and on hours of work

sum logincadj_5 if returned_5 == 1 & returned_15 == 1 & notempnow_15 == 1 & female == 1 & married_5 == 1 & hrsperwk_5 > 9 [aw=weight_5]
sum logincadj_5 if returned_5 == 1 & returned_15 == 1 & notempnow_15 == 0 & missingnotemp_15 ~= 1 & female == 1 & married_5 == 1 & hrsperwk_5 > 9 [aw=weight_5]
sum logincadj_5 if returned_5 == 1 & returned_15 == 1 & notempnow_15 == 1 & female == 1 & married_5 == 1 & spouseincadj_15 > 200000 & hrsperwk_5 > 9 [aw=weight_5]
sum logincadj_5 if returned_5 == 1 & returned_15 == 1 & notempnow_15 == 0 & missingnotemp_15 ~= 1 & female == 1 & married_5 == 1 & spouseincadj_15 > 200000 & hrsperwk_5 > 9 [aw=weight_5]

sum hrsperwk_5 if returned_5 == 1 & returned_15 == 1 & notempnow_15 == 1 & female == 1 & married_5 == 1 & hrsperwk_5 > 9 [aw=weight_5]
sum hrsperwk_5 if returned_5 == 1 & returned_15 == 1 & notempnow_15 == 0 & missingnotemp_15 ~= 1 & female == 1 & married_5 == 1 & hrsperwk_5 > 9 [aw=weight_5]
sum hrsperwk_5 if returned_5 == 1 & returned_15 == 1 & notempnow_15 == 1 & female == 1 & married_5 == 1 & spouseincadj_15 > 200000 & hrsperwk_5 > 9 [aw=weight_5]
sum hrsperwk_5 if returned_5 == 1 & returned_15 == 1 & notempnow_15 == 0 & missingnotemp_15 ~= 1 & female == 1 & married_5 == 1 & spouseincadj_15 > 200000 & hrsperwk_5 > 9 [aw=weight_5]

*of those who leave, what was reason given and was it different for those with high income hubbies?
*Cannot do that because reason for leaving appears to be reason for going to another job, too few of those not working answered it

*Among those who were in law firms in year 5 and made partner by year 15, how much did hours in year 5 matter?
*they mattered such that an additional 10 hours/week increased prob by 0.054 on a base of 0.32 for women (given lsgpa)

areg partner_15 hrsperwk_5 lsgpa lawreview if female == 1 & returned_5 == 1 & returned_15 == 1 & hrsperwk_5 > 9 & hrsperwk_15 > 9 & wksetting_5 == 1 [aw=weight_15], absorb(surveyyear_15)
areg partner_15 hrsperwk_5 lsgpa lawreview if female == 0 & returned_5 == 1 & returned_15 == 1 & hrsperwk_5 > 9 & hrsperwk_15 > 9 & wksetting_5 == 1 [aw=weight_15], absorb(surveyyear_15)

***Nov 20, 2013
*Exploring widening earnings gap over time, role of kids
*because you don't have hours for year 1, restrict everything to be > 15000, this affects just 1-2% until year 15 when many work PT
*income means

table cohort female if returned_5 == 1 & returned_15 == 1 & incadj_1 > 15000, c(mean incadj_1)
table cohort female if returned_5 == 1 & returned_15 == 1 & incadj_5 > 15000, c(mean incadj_5)
table cohort female if returned_5 == 1 & returned_15 == 1 & incadj_15 > 15000, c(mean incadj_15)
*restrict to FT hours currently
table cohort female if returned_5 == 1 & returned_15 == 1 & ptnow_5 == 0,  c(mean incadj_5)
table cohort female if returned_5 == 1 & returned_15 == 1 & ptnow_15 == 0, c(mean incadj_15)

*income medians

table cohort female if returned_5 == 1 & returned_15 == 1 & incadj_1 > 15000, c(median incadj_1)
table cohort female if returned_5 == 1 & returned_15 == 1 & incadj_5 > 15000, c(median incadj_5)
table cohort female if returned_5 == 1 & returned_15 == 1 & incadj_15 > 15000, c(median incadj_15)
*restrict to FT hours currently
table cohort female if returned_5 == 1 & returned_15 == 1 & ptnow_5 == 0,  c(median incadj_5)
table cohort female if returned_5 == 1 & returned_15 == 1 & ptnow_15 == 0, c(median incadj_15)


***
*note that exp, exp_ft, etc. are only valid for certain years, ptnow is ok b/c it is derived from hours, also control for missing values
***

*all years of exp
table cohort female if returned_5 == 1 & returned_15 == 1 & jdyr >= 1986 & missingexp_5 ~= 1, c(mean exp_5)
table cohort female if returned_5 == 1 & returned_15 == 1 & jdyr >= 1976 & missingexp_15 ~= 1, c(mean exp_15)
*only full time years
table cohort female if returned_5 == 1 & returned_15 == 1 & jdyr >= 1986 & missingexp_ft_5 ~= 1, c(mean exp_ft_5)
table cohort female if returned_5 == 1 & returned_15 == 1 & jdyr >= 1976 & missingexp_ft_15 ~= 1, c(mean exp_ft_15)

*out of the labor force currently
table cohort female if returned_5 == 1 & returned_15 == 1 & missingnotemp_5 ~= 1, c(mean notempnow_5)
table cohort female if returned_5 == 1 & returned_15 == 1 & missingnotemp_15 ~= 1, c(mean notempnow_15)

*hours of work (without zeros)
table cohort female if returned_5 == 1 & returned_15 == 1 & hrsperwk_5 ~= 0, c(mean hrsperwk_5)
table cohort female if returned_5 == 1 & returned_15 == 1 & hrsperwk_15 ~= 0, c(mean hrsperwk_15)

*in labor force by presence of children
table cohort ch_5 if returned_5 == 1 & returned_15 == 1 & female == 1 & missingnotemp_5 ~= 1, c(mean notempnow_5)
table cohort ch_15 if returned_5 == 1 & returned_15 == 1 & female == 1 & missingnotemp_15 ~= 1, c(mean notempnow_15)

*annual income differences at year 15 for men and women with no work disruptions and no children
*use fuller sample because of small sample size
*note that it isn't kids as much as currently married that matters
areg logincadj_15 female if  returned_15 == 1 [aw=weight_15], absorb(surveyyear_15)
areg logincadj_15 female if  returned_15 == 1 &  exp_15 == 15 [aw=weight_15], absorb(surveyyear_15)
areg logincadj_15 female if  returned_15 == 1 &  exp_15 == 15 & ch_15 == 0  [aw=weight_15], absorb(surveyyear_15)
areg logincadj_15 female lsgpa lawreview if  returned_15 == 1 &  exp_15 == 15 & ch_15 == 0  [aw=weight_15], absorb(surveyyear_15)
areg logincadj_15 female lsgpa lawreview married_15 if returned_15 == 1 &  exp_15 == 15 & ch_15 == 0  [aw=weight_15], absorb(surveyyear_15)
areg logincadj_15 female lsgpa lawreview married_15 if returned_15 == 1 &  exp_15 == 15 [aw=weight_15], absorb(surveyyear_15)

*who is out of the labor force at year 15?
areg notempnow_15 lsgpa married_15 lawfirm_5 ch_15 if female == 1 & returned_15 == 1 & returned_5 == 1, absorb(surveyyear_15)
areg notempnow_15 lsgpa married_15 lawfirm_5 ch_15 notempnow_5  if female == 1 & returned_15 == 1 & returned_5 == 1, absorb(surveyyear_15)

*hubby income matters but only if there are kids

gen spinc300K_15 = spouseincadj_15 > 300000
tab spinc300K_15 if female == 1 & returned_15 == 1 & returned_5 == 1 & married_15 == 1
gen spinc300Kch = spinc300K_15 * ch_15

areg notempnow_15 lawfirm_5 notempnow_5 ch_15   if female == 1 & returned_15 == 1 & returned_5 == 1, absorb(surveyyear_15)
areg notempnow_15 lawfirm_5 notempnow_5 ch_15  spinc300K_15 if female == 1 & returned_15 == 1 & returned_5 == 1, absorb(surveyyear_15)
areg notempnow_15 lawfirm_5 notempnow_5 ch_15  spinc300K_15 spinc300Kch if female == 1 & returned_15 == 1 & returned_5 == 1, absorb(surveyyear_15)
areg notempnow_15 lawfirm_5 notempnow_5 ch_15  spinc300K_15 spinc300Kch if female == 1 & returned_15 == 1 & returned_5 == 1 & married_15 == 1, absorb(surveyyear_15)

tab notempnow_15 if female == 1 & returned_15 == 1  & married_15 == 1 & spinc300Kch == 0 & ch_15 == 1
tab notempnow_15 if female == 1 & returned_15 == 1  & married_15 == 1 & spinc300Kch == 1 & ch_15 == 1

*note that women with kids and super-rich husband who stay IN the labor force earn lots of money (35 log points more), but many leave
areg logincadj_15 lsgpa lawreview loghourswk_15 logwksyr_15 exp_15  yrspt_15 missingexp_15 timeoff ch_15 spinc300K_15 spinc300Kch  if returned_15 == 1 & returned_5 == 1 & hrsperwk_15 > 9 & female == 1 [aw=weight_15], absorb(surveyyear_15)

***Hourly Fee regressions***

gen loghrlyfee_15 = log(hourlyfee_15)

areg loghrlyfee_15 female lsgpa lawreview loghourswk_15  if returned_15 == 1  & returned_5 == 1 & hrsperwk_15 > 9 [aw=weight_15], absorb(surveyyear_15)
areg loghrlyfee_15 female lsgpa lawreview loghourswk_15  yrscurrjob_15 yrsnotemp_15 yrspt_15 missingexp_15 timeoff if returned_15 == 1  & returned_5 == 1 & hrsperwk_15 > 9  [aw=weight_15], absorb(surveyyear_15)

***Figure 5 data on hours***

*for longitudinal group, graduating 1982-1991, > 9 hours/week at year 15

gen hoursbin_15 = 1 if hrsperwk_15 > 9 & hrsperwk_15 < 35
replace hoursbin_15 = 2 if hrsperwk_15 >= 35 & hrsperwk_15 < 45
replace hoursbin_15 = 3 if hrsperwk_15 >= 45 & hrsperwk_15 < 55
replace hoursbin_15 = 4 if hrsperwk_15 >= 55 & hrsperwk_15 ~= .
tab hoursbin_15 if female == 0 & incadj_15 ~= 0 & returned_15 == 1 & returned_5 == 1
tab hoursbin_15 if female == 1 & incadj_15 ~= 0 & returned_15 == 1 & returned_5 == 1
sort hoursbin_15
by hoursbin_15: sum incadj_15 if returned_15 == 1 & returned_5 == 1 & incadj_15 ~= 0
by hoursbin_15: sum incadj_15 if returned_15 == 1 & returned_5 == 1 & incadj_15 ~= 0 & female == 1
by hoursbin_15: sum incadj_15 if returned_15 == 1 & returned_5 == 1 & incadj_15 ~= 0 & female == 0
*to obtain mean hours in each hoursbin for graph
by hoursbin_15: sum hrsperwk_15 if returned_15 == 1 & returned_5 == 1 & incadj_15 ~= 0 & incadj_15 ~= .
*to obtain mean for hourly fee in year 15
by hoursbin_15: sum hourlyfee_15 if returned_15 == 1 & returned_5 == 1 & incadj_15 ~= 0 & incadj_15 ~= .
*to obtain the various job-hours features
table hoursbin_15 if returned_15 == 1 & returned_5 == 1 & incadj_15 ~= 0 & incadj_15 ~= ., c(mean female)
table hoursbin_15 if returned_15 == 1 & returned_5 == 1 & incadj_15 ~= 0 & incadj_15 ~= . & female == 1, c(mean ch_15)
sum female if returned_15 == 1 & returned_5 == 1 & incadj_15 ~= 0 & incadj_15 ~= .
sum ch_15 if returned_15 == 1 & returned_5 == 1 & incadj_15 ~= 0 & incadj_15 ~= . & female == 1

tab wksetting_15 if returned_15 == 1 & returned_5 == 1 & incadj_15 ~= 0 & incadj_15 ~= .

tab wksetting_15 if returned_15 == 1 & returned_5 == 1 & incadj_15 ~= 0 & incadj_15 ~= . & hoursbin_15 == 1
tab wksetting_15 if returned_15 == 1 & returned_5 == 1 & incadj_15 ~= 0 & incadj_15 ~= . & hoursbin_15 == 2
tab wksetting_15 if returned_15 == 1 & returned_5 == 1 & incadj_15 ~= 0 & incadj_15 ~= . & hoursbin_15 == 3
tab wksetting_15 if returned_15 == 1 & returned_5 == 1 & incadj_15 ~= 0 & incadj_15 ~= . & hoursbin_15 == 4

table hoursbin_15 if returned_15 == 1 & returned_5 == 1 & incadj_15 ~= 0 & incadj_15 ~= . & wksetting_15 == 1, c(mean partner_15)
table hoursbin_15 if returned_15 == 1 & returned_5 == 1 & incadj_15 ~= 0 & incadj_15 ~= . & wksetting_15 == 1 & solopractice_15 ~= 99, c(mean solopractice_15)

sum partner_15 if returned_15 == 1 & returned_5 == 1 & incadj_15 ~= 0 & incadj_15 ~= . & wksetting_15 == 1
sum solopractice_15 if returned_15 == 1 & returned_5 == 1 & incadj_15 ~= 0 & incadj_15 ~= . & wksetting_15 == 1 & solopractice_15 ~= 99

table hoursbin_15 if returned_15 == 1 & returned_5 == 1 & incadj_15 ~= 0 & incadj_15 ~= . & wksetting_15 == 1 & firmsize_15 ~= 0, c(mean firmsize_15 median firmsize_15)

sum firmsize_15 if returned_15 == 1 & returned_5 == 1 & incadj_15 ~= 0 & incadj_15 ~= . & wksetting_15 == 1 & firmsize_15 ~= 0, detail

table hoursbin_15 if returned_15 == 1 & returned_5 == 1 & incadj_15 ~= 0 & incadj_15 ~= . & wksetting_15 == 1 & firmsize_15 ~= 0, c(mean client_rich_15  mean client_f500_15)
sum client_f500_15 client_rich_15 if returned_15 == 1 & returned_5 == 1 & incadj_15 ~= 0 & incadj_15 ~= . & wksetting_15 == 1 & firmsize_15 ~= 0


log close

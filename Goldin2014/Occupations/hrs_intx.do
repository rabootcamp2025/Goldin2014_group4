*-------------------------------------------------------------------*
	*Female Wage Analysis using ACS 2009- 2011 
	*August 15, 2013
	*Natalia Emanuel's update of Chenzi Xu's revision of Ryan Sakoda's original code
*-------------------------------------------------------------------*

/*
A note on file names.
Two pieces of information are included in filenames:
	--> what the sample is. Options are
		a) "Full" - full-time, year-round workers (35+ hours, 40+ weeks)
		b) "All"  - All workers
		c) "FullBA" - College graduate workers full-time, year-round
		d) "AllBA" - College Grads (regardless of hours and weeks)
	
	--> what is included in the regression
		a) "Basic" - female dummy, occ dummies, occ x female dummies, age as quartic, race
		b) "Educ" - Basic + schooling dummies
		c) "Time" - either "basic" or "educ" with ln(hours) and ln(weeks)
For example "Full-Basic.dta" includes 
coefficients on the regression that includes full time, year round workers with only base controls.
*/



*clear all 
pause off 
set more off 
set matsize 2400
capture log close 
set varabbrev off 
global path "~emanueln/bulk/ACS/female_wage2"
//to run on local computer, not on server:
//global path "Z:/bulk/ACS/female_wage2"

//local cleaned "/homes/nber/emanueln/ACS/female_wage2/cleaned.dta"

log using "${path}/analysis_2011_hrs.txt", append text
/*

*-------------------------------------------------------------------* 

	*Setup
	
*-------------------------------------------------------------------* 

//needed below
	ssc install mat2txt, replace
	ssc install outreg2, replace
/*	
//Setup
	
use "/homes/nber/emanueln/bulk/ACS/acs_2009_2010_2011.dta", clear

	// Age restrictions
	drop if age<25 | age>64
	
	// Dropping N/A and Military //
	drop if occ == 0 | occ == 980 | occ == 981 | occ == 982 | occ == 983 

	// Standardize occupation codings from 2010 and 2011 with 2009 // 
	replace occ = 130 if (year == 2010 | year==2011) & (occ == 135 | occ == 136 | occ == 137) 
	replace occ = 200 if (year == 2010 | year==2011) & occ == 205 
	replace occ = 320 if (year == 2010 | year==2011) & (occ == 430 | occ == 4465) 
	replace occ = 560 if (year == 2010 | year==2011) & (occ == 565 | occ == 3945) 
	replace occ = 620 if (year == 2010 | year==2011) & (occ == 630 | occ == 640 | occ == 650) 
	replace occ = 720 if (year == 2010 | year==2011) & occ == 725 
	replace occ = 730 if (year == 2010 | year==2011) & (occ == 425 | occ == 725 | occ == 735 | occ == 740) 
	replace occ = 1000 if (year == 2010 | year==2011) & (occ == 1005 | occ == 1006 | occ == 1106 | occ == 1107) 
	replace occ = 1110 if (year == 2010 | year==2011) & (occ == 1007 | occ == 1030 | occ == 1050 | occ == 1105 | occ == 1106) 
	replace occ = 1100 if (year == 2010 | year==2011) & (occ == 1105 | occ == 1106 | occ == 1107) 
	replace occ = 1960 if (year == 2010 | year==2011) & occ == 1965 
	replace occ = 2020 if (year == 2010 | year==2011) & (occ == 2015 | occ == 2016 | occ == 2025) 
	replace occ = 2100 if (year == 2010 | year==2011) & occ == 2105 
	replace occ = 2140 if (year == 2010 | year==2011) & occ == 2145 
	replace occ = 2150 if (year == 2010 | year==2011) & occ == 2160 
	replace occ = 2820 if (year == 2010 | year==2011) & occ == 2825 
	replace occ = 3240 if (year == 2010 | year==2011) & occ == 3245 
	replace occ = 3130 if (year == 2010 | year==2011) & (occ == 3255 | occ == 3256 | occ == 3258) 
	replace occ = 3410 if (year == 2010 | year==2011) & occ == 3420 
	replace occ = 3530 if (year == 2010 | year==2011) & occ == 3535 
	replace occ = 3650 if (year == 2010 | year==2011) & (occ == 3645 | occ == 3646 | occ == 3647 | occ == 3648 | occ == 3649 | occ == 3655) 
	replace occ = 3920 if (year == 2010 | year==2011) & occ == 3930 
	replace occ = 3950 if (year == 2010 | year==2011) & occ == 3955 
	replace occ = 4550 if (year == 2010 | year==2011) & (occ == 9050 | occ == 9415) 
	replace occ = 4960 if (year == 2010 | year==2011) & (occ == 726 | occ == 4965) 
	replace occ = 5930 if (year == 2010 | year==2011) & (occ == 5830 | occ == 5165 | occ == 5940) 
	replace occ = 6000 if (year == 2010 | year==2011) & occ == 6005 
	replace occ = 6350 if (year == 2010 | year==2011) & occ == 6355 
	replace occ = 6510 if (year == 2010 | year==2011) & occ == 6515 
	replace occ = 6760 if (year == 2010 | year==2011) & occ == 6765 
	replace occ = 7310 if (year == 2010 | year==2011) & occ == 7315 
	replace occ = 7620 if (year == 2010 | year==2011) & occ == 7630 
	replace occ = 7850 if (year == 2010 | year==2011) & occ == 7855 
	replace occ = 8240 if (year == 2010 | year==2011) & (occ == 8255 | occ == 8256) 
	replace occ = 8960 if (year == 2010 | year==2011) & occ == 8965

	replace occ = occ/10 

	//demographic controls // 
	gen female = sex == 2 
	
	gen age2 = age*age 
	gen age3 = age2*age
	gen age4 = age2*age2
	
	// Race is coded such that we allow for multiple races, which is relevant mostly for cases of white-hispanics etc. //
	gen white = race == 1 
	gen black = race == 2 
	gen aspi = (race==4 | race==5 | race==6)
	gen hisp = (hispan>0 & hispan<9)
	gen other = (white==0 & black==0 & aspi==0 & hisp==0)	
	sum white black aspi hisp other [aw=perwt]
	
	gen married = (marst==1 | marst==2)
	
	gen somecol = (educ>6 & educ!=.)
	
	gen notempl = empstat != 1 
	
	sum married somecol notempl [aw=perwt]

/* 	There are two variables, "educ" and "educd". We use "educd" because it provides more info.
	The highest educational attainment in the "educ" variable is "5+ years of college".  
	This corresponds to a person either achieving a Master's degree, Professional degree 
	beyond a bachelor's degree, or Doctoral degree as entered in "educd" */

	gen yrsch = . 
	replace yrsch = 0 if educ == 0
	replace yrsch = 3 if educ == 1  //would be 2.5
	replace yrsch = 7 if educ == 2 //would be 6.5
	replace yrsch = 9 if educ == 3 
	replace yrsch = 10 if educ == 4 
	replace yrsch = 11 if educ == 5 
	replace yrsch = 12 if educ == 6 
	replace yrsch = 13 if educ == 7 
	replace yrsch = 14 if educ == 8 
	replace yrsch = 15 if educ == 9 
	replace yrsch = 16 if educ == 10
	replace yrsch = 18 if educd == 114 //would be 17.6
	replace yrsch = 19 if educd == 115
	replace yrsch = 20 if educd == 116
		//NB base category is having Exactly a BA (educ==10)
		//regressions should therefore go b16.yrsch
		
	
		//for collapse fxn, which doesn't allow factor variables 
		/*
		tab yrsch, gen(sch)
		rename sch10 schBA
		rename sch11 schMA
		rename sch12 schPro
		rename sch13 schPhd
		*/
	sum yrsch [aw=perwt]

	// Year Dummies //
	gen year09 = year==2009
	gen year10 = year==2010

	// Cleaning Income variables //
	replace incwage = 0 if incwage == 999999 | incwage < 0 | incwage==.
	replace inctot = 0 if inctot == 999999 | inctot < 0 
	replace incbus00 = 0 if incbus00 == 999999 | incbus00 < 0 | incbus00==.
	label var incbus00 "income from business and farm"
	gen incwbf = incwage + incbus00 
	label var incwbf "income from wage, business, and farm"
	
	sum incwage inctot incbus00 incwbf [aw=perwt]

	gen lninc = log(incwage) 
	gen lnincwbf = log(incwbf) 
	
	gen m_lninc = lninc if female == 0 
	gen m_lnincwbf = lnincwbf if female == 0
	gen f_lninc = lninc if female == 1 
	gen f_lnincwbf = lnincwbf if female == 1 
	
	sum lninc lnincwbf m_lninc m_lnincwbf f_lninc f_lnincwbf [aw=perwt]
	
	// Weeks worked//
	/* In the ACS 2006-2011, only the intervalled version of weeks worked last year is available. 
	We use the mean weeks worked for each interval from the 2007 ACS data set */

	gen wkswork = 0 if wkswork2 == 0 
	replace wkswork = 7.465368 if wkswork2 == 1 
	replace wkswork = 21.14945 if wkswork2 == 2 
	replace wkswork = 33.12715 if wkswork2 == 3 
	replace wkswork = 42.40279 if wkswork2 == 4 
	replace wkswork = 48.18564 if wkswork2 == 5 
	replace wkswork = 51.82708 if wkswork2 == 6 
	
	gen lnweeks = log(wkswork) 
	gen lnhrs = log(uhrswork) 
	
	sum wkswork lnweeks lnhrs [aw=perwt]

	// Full time (35 hours) full year (40 wks) workers // 
	gen full = (uhrswork >= 35 & wkswork2 >= 4)
	label var full "full time full year worker"
	gen min = 3 * 35 * 40 
	label var min "minimum annual income"
	
/* CHOOSE whether you want to use Wage, Business, and Farm Income (incwbf) or Wage Income (incwage) */
	gen hwage=incwbf/(uhrswork*wkswork)
	
/* CHOOSE whether you want to drop Self-Employed people */
	//drop if classwkrd == 13 | classwkrd == 14 
	
	save "${path}/prethreshold.dta", replace
	
*/
*--------------------------------------------------------------------------*

	//Code fixed effects and interactions
	
*--------------------------------------------------------------------------* 
use "${path}/prethreshold.dta", clear

	// Gen count of men and women in each profession // 
	gen cnt_f = 1 if female == 1 
	gen cnt_m = 1 if female == 0 
	bys occ: egen totfem = count(cnt_f) 
	bys occ: egen totmen = count(cnt_m) 
	
	sum cnt_f cnt_m totfem totmen [aw=perwt]

	gen occ2 = occ 

	// Creating interaction variables for all occupations that are not 0 for all observations. //
	forvalues i = 1/975 { 
		count if occ2 == `i' 
		if r(N) > 0 gen occfe_`i' =  occ2 == `i' 
		if r(N) > 0 gen intx_`i' = female*occfe_`i' 
		if r(N) > 0 gen hrs_`i' = lnhrs*occfe_`i'
		clear results 
		capture count if intx_`i' == 1 
		if r(N) == 0 drop intx_`i' 
		capture count if hrs_`i' != 0
		if r(N) == 0 drop hrs_`i'
		compress 
	} 
	
	sum occfe_* intx_* hrs_* [aw=perwt]

	 
	

*-*-*-*-*-*-*-*-*
//Alternative:

use "${path}/cleaned.dta", clear
	forvalues i = 1/975 { 
		display "i=`i'"
		count if occ2 == `i' 
		if r(N) > 0 gen hrs_`i' = lnhrs*occfe_`i'
		clear results 
		capture count if hrs_`i' != 0
		if r(N) == 0 drop hrs_`i'
	} 
	compress
save "${path}/cleaned_hrs_v2.dta", replace
*/
local cleaned "${path}/cleaned_hrs_v2.dta"

*-*-*-*-*-*-*-*-*

	
//------------------------------------------------------------------------------//
//          All forms of Regressions											//
//------------------------------------------------------------------------------//



//Occupation Labels & Categories
insheet using "~emanueln/bulk/ACS/female_wage2/acs_occ_labels.csv", comma clear 
	format occ2_label %150s 
	tempfile occ_labels 
	save `occ_labels' 	
	
insheet using "~emanueln/bulk/ACS/female_wage2/acs_occ_categories.csv", comma clear
	tempfile categories
	save `categories'


//variables in regression
local basevar lnincwbf female age age2 age3 age4 black hisp other aspi year09 year10 intx_* occfe_* hrs_*
local timevar lnhrs lnweeks
local educvar b16.yrsch


	use `cleaned', clear 
	
	// drop post secondary teachers occ == 220 so not overly identified  //
	drop intx_220 
	drop occfe_220 	
	drop hrs_220
	
	//Creating appropriate sample:

		keep if full==1
		//Wage restrictions (Full)
		count if incwbf < min 
		drop if incwbf < min 


		//restrict to college grads
		keep if yrsch>=16



	local allvars `basevar' `timevar' `educvar'
	display "`allvars'"

	
	// Run Analysis, store coefficient matrices // 
	//Regression
	xi:reg `allvars'[aw=perwt], r 
pause
	//coefficient matrices	
	capture matrix list e(b) 
	matrix matrix1 = e(b) 
		//for this next line to work, ensure that "female" is the second item listed after "reg", aka the first indep variable.
	local b_fem = matrix1[1, 1] 
	display `b_fem'
	mat2txt, matrix(matrix1) saving("${path}/Output/FullBA-EducTime-hrs") replace 

	//Copy a version of the regression output
	outreg2 using "${path}/Output/Regression-FullBA-EducTime-hrs"

	
// Call in stored coefficients, tweak  
	insheet using "${path}/Output/FullBA-EducTime-hrs.txt", nonames clear 
	
	//drop variables with no information
	foreach i of numlist 1/975 { 
		local j = `i' - 1 
		capture if v`i' == . drop v`j' 
		capture if v`i' == . drop v`i' 
	} 
	rename _cons cons
	outsheet using "${path}/Output/FullBA-EducTime-hrs.txt", nonames comma replace 
	
	//reshaping
	insheet using "${path}/Output/FullBA-EducTime-hrs.txt", clear 
	keep v1 intx_* occfe_* hrs_*
	reshape long intx_ occfe_ hrs_, i(v1) 
	rename _j occ2 
	rename intx_ coef_intx 
	rename occfe_ coef_occ2 
	rename hrs_ coef_hrs
	keep occ2 coef* 

	tempfile coefficients 
	save `coefficients' 	
	
	
// Collapse down to the occupation level so we can find correlation // 
	use `cleaned', clear
	
	//Creating appropriate sample:

		keep if full==1
		//Wage restrictions (Full)
		count if incwbf < min 
		drop if incwbf < min 
		//restrict to college grads
		keep if yrsch>=16

	
	drop intx_* occfe_* hrs_*
	gen count = 1 
	bys occ2: gen cnt = sum(count) 
	collapse (median) lninc lnincwbf m_lnincwbf f_lnincwbf (sum) cnt_f cnt_m count (mean) meanincwbf_m=m_lnincwbf meanincwbf_f=f_lnincwbf meaninc=lninc meanincwbf=lnincwbf yrsch age age2 female white other black hisp aspi lnhrs lnweeks [aw=perwt], by(occ2) 

	tempfile collapsed
	save `collapsed' 		
	merge 1:1 occ2 using `coefficients'
	keep if _merge !=2
	drop _merge 
		
	//removing secondary school teachers so they are the base-group.
	replace coef_intx = 0 if occ2 == 220 
	replace coef_occ2 = 0 if occ2 == 220 	
	replace coef_hrs = 0 if occ2 == 220 
	sum occ2 coef_intx coef_occ2 lninc lnincwbf m_lnincwbf f_lnincwbf cnt_f cnt_m count meanincwbf_m meanincwbf_f meaninc meanincwbf yrsch age age2 female white other black hisp aspi lnhrs lnweeks

	
//Create comprehensive table and our favorite figure!
	// Merge in occupation names and categories // 
	merge 1:1 occ2 using `occ_labels'
	keep if _merge!=2
	drop _merge 
	order occ2 occ2_label 
	merge 1:1 occ2 using `categories'
	keep if _merge!=2
	drop _merge
/*CHECK: be really sure to check that all the occupations you're looking at have categories
		if they weren't in the top 90 in 2009-2011, they may nothave categories*/

	gsort -meanincwbf_m
	gen b_female=`b_fem'
	gen y=coef_intx+b_female
	//Write regression results to csv//
	outsheet using "${path}/FullBA-EducTime-hrs_table.csv", comma replace 
	

	insheet using "${path}/FullBA-EducTime-hrs_table.csv", clear
	format occ2_label %100s
	gsort -meanincwbf_m
	export excel using "${path}/complete2.xlsx", sheet(FullBA-EducTime-hrs) firstrow(variables) sheetreplace

log close
exit, clear


***Stephanie's Original *.DO file***
clear all
set more off

* lists
global client "rich othind smbus f500 mdlg gov nonp oth"
global time "lib int lit neg draft app lob adm led soc rec oth"
global subj1 "adm anti bank bkrpt civ comm cmerc crim dom emp ene"
global subj2 "env est govt imm tax ins int lab pat real sec tort other"
global history "currjob firstjob govt legserv prac pubint"


* Construct longit_clean
use asrdl.dta, clear

* start looking at consistency of variables
drop v*001
* id number
codebook v0002
	* all unique values, no missing.  good!

*Ryan: These are the corrections sent to us by Terry*

replace v0051=v1051
replace v0051=v2051 if v0051==.
replace v0051=v3051 if v0051==.
replace v0051=v4051 if v0051==.
replace v0051=v5051 if v0051==.

replace v1007 = 1992 if v0003 == 1987 & v1007 != 1992
replace v1007 = 1999 if v0003 == 1994 & v1007 != 1999
replace v2007 = 1981 if v0003 == 1966 & v2007 != 1981
replace v2007 = 1982 if v0003 == 1967 & v2007 != 1982
replace v2007 = 2000 if v0003 == 1985 & v2007 != 2000

* Drop 35-45 year surveys
drop v4* v5*

*** Was the survey returned?  This ends up being an indicator for whether this observation should be used in the regression sample.

forvalues ii=1(1)3 {
local jj=5+10*(`ii'-1)
gen returned_`jj' = v`ii'005
}


* Check graduation year variables
sum v0003, det
	* social class (class the individual wishes to be included with)
sum v0103, det
	* year of graduation


* set jdyr equal to social year
gen jdyr = v0003
* drop the people before 1970 social class or after 2000.  2001 dropped for lack of ug data
drop if jdyr<1970 | jdyr>2000

* De-select rid of years with no spouse characteristics or labor supply history variables
replace returned_5=. if jdyr<=1981
replace returned_15=. if jdyr<=1971

* Create cohort variable and check that it matches UMLS's cohort variable
tostring jdyr, gen(string_class)
gen cohort=substr(string_class,3,2)
destring cohort, replace
replace cohort = floor(cohort/5)*5
tab cohort v0009 , mi
replace cohort = 95 if cohort==0
	* I included 2000 in the 1995 cohort in tabulations
drop string_class

* Create cohort dummies
gen cohort70 = cohort==70
gen cohort75 = cohort==75
gen cohort80 = cohort==80
gen cohort85 = cohort==85
gen cohort90 = cohort==90
gen cohort95 = cohort==95

* Create graduation year decade variable
tostring jdyr, gen(string_class)
gen decade=substr(string_class,3,2)
destring decade, replace
replace decade = floor(decade/10)*10
replace decade = 90 if decade==0
replace decade = 70 if jdyr==1980
replace decade = 80 if jdyr==1990
tab decade v0044 , mi
drop string_class

* Group = in potential sample for that survey wave (includes non-respondents and years without all variables)
gen group_15 = (decade>70)
gen group_5 = (decade>80)


*** BASIC TABULATIONS
* Gender
gen female = 1 if v0012==1
replace female = 0 if v0012==2
drop if missing(v0012)
	* 4 people are missing gender
label define female 0 Male 1 Female
label values female female

* Race
gen race = v0011
replace race = 7 if missing(race)
	* There are 8 individuals with race missing.  Rather than drop them, I coded them as "other"
replace race = 7 if race==3
	* I grouped NatAm with "other" to increase the thickness of the categories
label define race 1 Black 2 Hispanic 4 "Asian" 5 White 7 Other
label values race race

gen black = (race==1)
gen hispanic = (race==2)
gen asian = (race==4)
gen other = (race==7)
gen white = (race==5)
	
	
*** TIMING VARIABLES	
gen birthyear = v0014
gen yearba = v0040
replace yearba = . if v0002==1977142 | v0002==1989357
	* These two observations have obviously incorrect graduation years
gen yearlsentry = v0101
replace yearlsentry = yearba if v0002 == 1971227 | v0002 == 1973452 |v0002 == 1977004 |v0002 == 2001026
replace yearlsentry = 1988 if v0002==1991007
	* For questionable years of LS entry, replace with either three years before graduation or BA year
gen yearlsgrad = v0103

gen yearsinls = yearlsgrad - yearlsentry
gen timeoff = yearlsentry - yearba

* Drop people who entered more than five years before they graduated - 7 people
drop if yearsinls>5
	* 7 people took a long time in law school

* Survey year variable
gen surveyyear_5 = v1007
gen surveyyear_15 = v2007
gen surveyyear_25 = v3007

*** AGES
gen ageatba = yearba - birthyear

gen ageatlsentry = yearlsentry - birthyear
replace ageatlsentry  = v0108 if missing(ageatlsentry)
	* Replace ageatlsentry with UMLS's variable if I can't compute it

gen ageatlsgrad = yearlsgrad - birthyear
replace ageatlsgrad = v0109 if missing(ageatlsgrad)
	* v0109 is UMLS's age at graduation variable
replace ageatlsgrad=25 if missing(ageatlsgrad)
	* If missing, punt and assume 25.  I don't think this is many observations.

gen ageatlsgrad_2 = ageatlsgrad^2

* Age at the time of the survey
forvalues ii=1(1)3 {
local jj=5+10*(`ii'-1)

gen age_`jj' = surveyyear_`jj' - birthyear
replace age_`jj' = ageatlsgrad+`jj' if missing(age_`jj') & jdyr<=2006-`jj'
replace age_`jj' = ageatlsentry+`jj'+3 if missing(age_`jj')  & jdyr<=2006-`jj'
replace age_`jj' = 25+`jj' if missing(age_`jj') & jdyr<=2006-`jj'

gen age_`jj'_2 = age_`jj'^2

}

* Region in which parents reside
label define region 1 "New England" 2 "Mid-Atlantic" 3 "East North Central" 4 "West North Central" 5 "South Atlantic" 6 "East South Central" 7 "West South Central" 8 Mountain 9 Pacific 99 Missing

gen parresregion = v0015
replace parresregion = 99 if missing(parresregion)

label values parresregion region

* Parent occupations
label define occcode 0 Deceased 1 Attorney 2 Teacher 3 "Other professional" 4 Homemaker 5 "Blue/pink" 6 Clerical 7 "Owner/operator" 8 Manager 9 "Pub office" 10 "Public service" 11 Other 99 Missing

gen motherocc = v0019
replace motherocc = 99 if missing(motherocc)
gen fatherocc = v0020
replace fatherocc = 99 if missing(fatherocc)

label values motherocc fatherocc occcode

*** MARITAL STATUS
label define married 1 Never 2 "Married, First Time" 3 "Divorced/Separated" 4 Remarried 5 Widowed 7 Other 99 Missing

* marital status pre-ls
gen marstatprels = v0026
replace marstatprels = 99 if missing(marstatprels)
label values marstatprels married

* married at ls grad
gen marstatlsgrad = v0027
replace marstatlsgrad = 99 if missing(marstatlsgrad)
label values marstatlsgrad married

tab marstat*, mi

gen marriedprels = (marstatprels==2 | marstatprels==4)
replace marriedprels = 99 if marstatprels==99

gen marriedlsgrad = (marstatlsgrad==2 | marstatlsgrad==4)
replace marriedlsgrad = 99 if marstatlsgrad==99

*** SPOUSE OCC

forvalues ii=1(1)3 {
local jj=5+10*(`ii'-1)

gen spouseocc_`jj' = v`ii'431
replace spouseocc_`jj' = 99 if missing(spouseocc_`jj')

gen spouseprof_`jj' = (spouseocc_`jj'==1 | spouseocc_`jj'==3 | spouseocc_`jj'==7 | spouseocc_`jj'==8) if ~missing(spouseocc_`jj')
replace spouseprof_`jj' = 99 if spouseocc_`jj'==99
	* Spouse professional = spouse is a lawyer, owner / operator, manager, or other professional.  Highly correlated with earnings buckets.
}

label values spouseocc* occcode

* Spouse income adjusted
forvalues ii=1(1)3 {
local jj=5+10*(`ii'-1)
gen spouseincadj_`jj' =  v`ii'857
gen logspouseincadj_`jj' = log(spouseincadj_`jj')
}

* Is respondent married now?
forvalues ii=1(1)3 {
local jj=5+10*(`ii'-1)

gen marstat_`jj' = v`ii'028
replace marstat_`jj' = 5 if spouseocc_`jj'==0
	* If spouse is deceased in occupation, mark respondent as widow(er)
gen married_`jj' = (marstat_`jj'==2 | marstat_`jj'==4)
replace marstat_`jj' = 99 if missing(marstat_`jj')
replace married_`jj' = 99 if marstat_`jj'==99
gen evermarried_`jj' = (marstat_`jj'>1)
replace evermarried_`jj' = 99 if marstat_`jj'==99
}

label values marstat* married

* Indicator for spouse is recorded as having no income (used in later coding)
forvalues ii=1(1)3 {
local jj=5+10*(`ii'-1)
gen zeroinc_`jj' = (spouseincadj_`jj'==0)
}

* Does individual cohabit with a partner?  Yes if 1) responds yes to cohabit question 2) reports partner characteristics but reports not being married 3) reports partner occupation but reports not being married
forvalues ii=1(1)3 {
local jj=5+10*(`ii'-1)

gen cohabit_`jj' = v`ii'033
replace cohabit_`jj'=0 if married_`jj'==1
replace cohabit_`jj'=1 if married_`jj'!=1 & spouseincadj_`jj'>0 & spouseincadj_`jj'<.
replace cohabit_`jj'=1 if married_`jj'!=1 & spouseocc_`jj'<99 & spouseocc_`jj'>0
replace cohabit_`jj'=99 if missing(cohabit_`jj')
}

* Is individual partnered = married or cohabiting?  I use this as my marriage variable
forvalues ii=1(1)3 {
local jj=5+10*(`ii'-1)

gen partnered_`jj' = 1 if married_`jj'==1
replace partnered_`jj' = 1 if cohabit_`jj'==1 & married_`jj'!=1
replace partnered_`jj' = 0 if cohabit_`jj'!=1 & married_`jj'!=1
replace partnered_`jj' = 99 if cohabit_`jj'==99 & married_`jj'==99

}
label define partnered 1 Partnered 0 "No Partner" 99 Missing
label values partnered* partnered

* If respondent is not partnered, replace spouse income with missing
forvalues ii=1(1)3 {
local jj=5+10*(`ii'-1)
 replace spouseincadj_`jj' = . if partnered_`jj'!=1
 replace logspouseincadj_`jj' = . if partnered_`jj'!=1
}

* Multi-level code for whether partnered and, if so, partner's earnings (zero, positive, or missing)
forvalues ii=1(1)3 {
local jj=5+10*(`ii'-1)
gen spousebin_`jj' = 0 if partnered_`jj'==0
replace spousebin_`jj' = 1 if partnered_`jj'==1 & spouseincadj_`jj'==0
replace spousebin_`jj' = 2 if partnered_`jj'==1 & spouseincadj_`jj'>0 & spouseincadj_`jj'<.
replace spousebin_`jj' = 3 if partnered_`jj'==1 & missing(spouseincadj_`jj')
replace spousebin_`jj' = 99 if partnered_`jj'==99
replace logspouseincadj_`jj' = 0 if missing(logspouseincadj_`jj')
}

label define spousebin 0 "No Partner" 1 "Partner, No Inc" 2 "Partnered" 3 "Partnered, Inc Missing" 99 Miss
label values spousebin* spousebin


**** CHILDREN***

label define kids 0 0 1 1 2 2 3 3 4 "4+"  99 Miss

* Children at law school entry
gen numchprels = v0034
replace numchprels = 4 if numchprels==5 | numchprels==6 | numchprels==7
	* Top-code at 4+ to avoid bins with no observations in them
replace numchprels = 99 if missing(numchprels)
label values numchprels kids
gen chprels = (numchprels>0) if numchprels<99

* Children at law school graduation
gen numchlsgrad = v0035
replace numchlsgrad = 4 if numchlsgrad==5 | numchlsgrad==6 | numchlsgrad==7
	* Top-code at 4+ to avoid bins with no observations in them
replace numchlsgrad = 99 if missing(numchlsgrad)
label values numchlsgrad kids
gen chlsgrad = (numchlsgrad>0) if numchlsgrad<99

* Children at survey years
forvalues ii = 1(1)3 {
local jj = 5+10*(`ii'-1)

gen numch_`jj' = v`ii'036
replace numch_`jj'=v`ii'758 if missing(numch_`jj')
replace numch_`jj' = 4 if numch_`jj'==5 | numch_`jj'==6 | numch_`jj'==7
replace numch_`jj' = 99 if missing(numch_`jj')

gen ch_`jj' = (numch_`jj'>0) if numch_`jj'<99
replace ch_`jj' = 1 if ~missing(v`ii'759)

* Any children under 6
gen ch06_`jj' = (v`ii'759<6) if ~missing(v`ii'759)

* Child care costs
gen chcarecost_`jj'=v`ii'861
gen missingchcarecost_`jj'= (missing(chcarecost_`jj') | numch_`jj'==0)
	* Child care cost is missing if there are no children
replace chcarecost_`jj'=0 if missingchcarecost_`jj'==1
}
label values numch_* kids


* Undergraduate and admissions characteristics
gen uggpa = v0869
gen lsatperc = 99-v0835
gen missingprels = (missing(uggpa) | missing(lsatperc))
replace lsatperc = 0 if missingprels==1
replace uggpa= 0 if missingprels==1

* Undergraduate institution type
gen ugschool = v0041
replace ugschool = 6 if missing(ugschool)
replace ugschool = 6 if ugschool==7
label define ugschool 1 UMich 2 "Oth Mich" 3 "Oth State" 4 "Ivy/7 Sis" 5 "Oth Priv" 6 Other
label values ugschool ugschool

* Whether undergraduate ivy
gen ivy7 = (ugschool==4)
replace ivy7 = 99 if ugschool==99

* Undergraduate major
label define ugmajor 1 Hum 2 "Soc Sci" 3 "Nat Sci" 4 Bus 5 Eng 6 Oth 99 Miss
gen ugmajor = v0043
replace ugmajor = 99 if missing(ugmajor) | ugmajor>6
label values ugmajor ugmajor

* Population of cities lived in and worked in
label define population 1 "<100K" 2 "100K-500K" 3 "500K-1M" 4 "1M-3M" 5 ">3M" 99 Missing

forvalues ii = 1(1)3 {
local jj = 5+10*(`ii'-1)
gen popcitywork_`jj' = v`ii'647
replace popcitywork_`jj' = v`ii'066 if missing(popcitywork_`jj')
	* if population of work city is missing, use city of residence
replace popcitywork_`jj' = 99 if missing(popcitywork_`jj') | popcitywork_`jj'==0
replace popcitywork_`jj'=1 if popcitywork_`jj'==1 | popcitywork_`jj'==2
replace popcitywork_`jj'=2 if popcitywork_`jj'==3 | popcitywork_`jj'==4
replace popcitywork_`jj'=3 if popcitywork_`jj'==5
replace popcitywork_`jj'=4 if popcitywork_`jj'==6
replace popcitywork_`jj'=5 if popcitywork_`jj'==7
}

label values popcity* population


* people appear to commute to bigger cities.  phew.

* region of residence - use region of work if missing both residence measures
forvalues ii=1(1)3 {
local jj=5+10*(`ii'-1)
gen region_`jj' = v`ii'070
replace region_`jj' = v`ii'071 if missing(region_`jj')
replace region_`jj' = v`ii'779 if missing(region_`jj')
replace region_`jj' = 99 if missing(region_`jj') | region_`jj'<0
}

label values region* region

* Education post-BA and pre-LS
label define graddegree 0 Dropout 1 Masters 2 Doctorate 3 Other 99 Miss
label define graddegfield 1 Human 2 "Soc Sci" 3 "Nat Sci" 4 Bus 5 Eng 6 Oth 99 Miss

gen graddegree = v0054
replace graddegree=99 if missing(graddegree)
gen graddegfield = v0055
replace graddegfield=99 if missing(graddegfield)

label values graddegree graddegree
label values graddegfield graddegfield

* Career plans at the time of ls entry and graduation
label define careerplan 1 None 2 "Large Firm" 3 "Med Firm" 4 "Small Firm" 5 Solo 6 Private 7 "In House" 8 Prosecutor 9 Politics 10 "Leg Serv" 11 Teacher 12 Business 13 Other 99 Missing

gen planprels = v0110
replace planprels = 99 if missing(planprels)
label values planprels careerplan
	* the ladies all want to go in to legal services

gen planlsgrad = v0111
replace planlsgrad = 99 if missing(planlsgrad)
label values planlsgrad careerplan
	* now the ladies want to go in to large firms

* Legal specialty same as planned - only up to 80 for 15 year
label define specplanned 1 Main 2 One 3 Not 7 Other 99 Miss
forvalues ii = 1(1)3 {
local jj=5+10*(`ii'-1)
gen specplanned_`jj'=v`ii'563
replace specplanned_`jj'=99 if specplanned_`jj'>3 | missing(specplanned_`jj')
}
label values specplanned* specplanned

* LS activities
gen legalsociety = v0141
replace legalsociety = 99 if missing(legalsociety)
gen mootcourt = v0142
replace mootcourt = 99 if missing(mootcourt)
gen lawreview = v0143
replace lawreview = 99 if missing(lawreview)
gen studentgovt = v0144
replace studentgovt = 99 if missing(studentgovt)

* LS performance
* First year grades
gen lsgpayr1 = v0871
gen missinglsyr1 = missing(lsgpayr1)
replace lsgpayr1=0 if missinglsyr1==1

* Whether a transfer
gen transfer = v0107

* Final GPA
gen lsgpa = v0872
drop if missing(lsgpa)
	* drop if no ls performance
	
* Total debt from schooling
gen lscoldebt = v0425

*** JOB TYPE ***
label define orgtype 1 "Private firm" 2 "Fed govt" 3 "State local govt" 4 "Legal service" 5 "Public interest" 6 "Education" 7 "Fortune 500" 8 "Other business" 9 "Banking/finance" 10 "Accounting" 11 Insurance 12 Other 99 Missing
label define postype 1 "Law practice" 2 Judge 3 "Law teacher" 4 "Other legal" 5 Official 6 "Teacher/Nonlegal" 7 "Executive/Manager" 8 Staff 9 Other 99 Missing
label define attystatus 0 "Not lawyer" 1 Solo 2 Partner 3 "Jun. Partner" 4 Assoc 5 "Man./Emp."  7 Other 99 Missing
label define consolidated 0 Unemployed 1 "Law Firm" 2 Corporate 3 "Govt/LS/Other" 6 "Not Practicing" 99 Missing
label define nonpractice 0 Unemployed 1 "Judge/Other Govt" 3 Business 4 "Law Teacher" 5 "Other Setting" 6 Practicing 99 Missing

forvalues ii=1(1)3 {
local jj=5+10*(`ii'-1)

gen orgtype_`jj' = v`ii'429
replace orgtype_`jj'=99 if missing(orgtype_`jj')

gen postype_`jj' = v`ii'430
replace postype_`jj'=99 if missing(postype_`jj')

gen lawyer_`jj' = v`ii'451
replace lawyer_`jj' = 99 if missing(lawyer_`jj')

gen attystatus_`jj' = v`ii'453
replace attystatus_`jj' = 2 if attystatus_`jj' ==3
replace attystatus_`jj' = 5 if attystatus_`jj' ==6
replace attystatus_`jj' = 99 if missing(attystatus_`jj')

gen wksetting_`jj' = v`ii'766
replace wksetting_`jj'=3 if wksetting_`jj'==4 | wksetting_`jj'==5
replace attystatus_`jj' = 7 if attystatus_`jj'==5 & wksetting_`jj'==1
replace wksetting_`jj' = 99 if missing(wksetting_`jj')

gen nonpsetting_`jj' = v`ii'767
replace nonpsetting_`jj' = 1 if nonpsetting_`jj'==2
replace nonpsetting_`jj' = 99 if missing(nonpsetting_`jj')

}

label values orgtype* orgtype
label values postype* postype
label values attystatus* attystatus
label values wksetting* consolidated
label values nonpsetting* nonpractice


* Ever a clerk
gen clerk = v0443

* First non-clerk employer
label define firstjob 1 "Private firm" 2 Business 3 "Govt/LS/PI" 7 Other 99 Missing

gen firstjob = v0444
replace firstjob = 3 if firstjob==4 | firstjob==5
replace firstjob=99 if missing(firstjob)
label values firstjob firstjob

* Number of lawyers at first non-clerking
gen numlawfirstjob = v0445
replace numlawfirstjob = . if firstjob > 1

* HISTORICAL LABOR SUPPLY
* Months part time and not working
forvalues ii = 1(1)3 {
local jj=5+10*(`ii'-1)

gen yrspt_`jj' = v`ii'760/12
gen yrsnotemp_`jj' = v`ii'761/12

replace yrspt_`jj' = v`ii'448/12 if missing(yrspt_`jj')
replace yrsnotemp_`jj' = v`ii'449/12 if missing(yrsnotemp_`jj')

gen missingpt_`jj' = missing(yrspt_`jj')
gen missingnotemp_`jj' = missing(yrsnotemp_`jj')

replace yrspt_`jj' = 0 if missingpt_`jj'==1
replace yrsnotemp_`jj' = 0 if missingnotemp_`jj'==1

gen yrspt_`jj'_2 = yrspt_`jj'^2
gen yrsnotemp_`jj'_2 = yrsnotemp_`jj'^2

* Respondent ever part time
gen everpt_`jj' = 1 if yrspt_`jj'>=0.5  & yrspt_`jj'<=`jj'
	* Ever pt = 1 if more than 6 months part-time
replace everpt_`jj' = 1 if (v`ii'447==1 | v`ii'447==3)
	* or if respondent says he or she was ever part-time (not available for all years)
replace everpt_`jj' = 0 if yrspt_`jj'<.5 & missingpt_`jj'==0 & missing(everpt_`jj')
replace everpt_`jj' = 0 if v`ii'447==0 & missing(everpt_`jj')
replace everpt_`jj' = 99 if missing(everpt_`jj')

* Respondent ever not employed
gen evernotemp_`jj' = 1 if yrsnotemp_`jj'>=0.5 & yrsnotemp_`jj'<=`jj'
replace evernotemp_`jj' = 1 if (v`ii'447==2 | v`ii'447==3)
replace evernotemp_`jj' = 0 if yrsnotemp_`jj'<.5 & missingnotemp_`jj'==0 & missing(evernotemp_`jj')
replace evernotemp_`jj' = 0 if v`ii'447==0 & missing(evernotemp_`jj')
replace evernotemp_`jj' = 99 if missing(evernotemp_`jj')
}


* Work Experience
forvalues ii=1(1)3 {
local jj=5+10*(`ii'-1)

* Full-time experience
gen exp_ft_`jj' = max(`jj'*12-yrspt_`jj'-yrsnotemp_`jj',0) if missingnotemp_`jj'==0 & missingpt_`jj'==0
gen missingexp_ft_`jj' = missing(exp_ft_`jj')
replace exp_ft_`jj' = 0 if missingexp_ft_`jj'==1
gen exp_ft_`jj'_2 = exp_ft_`jj'^2

* All experience (FT + PT)
gen exp_`jj' = max(`jj'*12-yrsnotemp_`jj',0)  if missingnotemp_`jj'==0
gen missingexp_`jj' = missing(exp_`jj')
replace exp_`jj' = 0 if missingexp_`jj'==1
gen exp_`jj'_2 = exp_`jj'^2
}

* More specific labor supply variables (tenure at job and number of jobs)
forvalues ii=1(1)3 {
local jj=5+10*(`ii'-1)

gen numjobs_`jj' = v`ii'460
replace numjobs_`jj' = v`ii'461 if missing(numjobs_`jj')
replace numjobs_`jj' = 99 if missing(numjobs_`jj')

gen yrscurrjob_`jj' = v`ii'467
gen yrsfirstjob_`jj' = v`ii'832
gen yrsgovt_`jj' = v`ii'462
gen yrslegserv_`jj' = v`ii'464
gen yrsprac_`jj' = v`ii'465
gen yrspubint_`jj' = v`ii'466

foreach name in $history {
replace yrs`name'_`jj' = `jj' if yrs`name'_`jj'>`jj' & ~missing(yrs`name'_`jj')
	* If years of work experience is more than years since graduation, replace with years since graduation
gen missingyrs`name'_`jj' = (missing(yrs`name'_`jj'))
replace yrs`name'_`jj'=0 if missingyrs`name'_`jj'==1
}
}


*** CURRENT LABOR SUPPLY
label define empstat 1 "Full time" 2 "Part time" 3 "Not emp now" 99 Missing

forvalues ii = 1(1)3 {
local jj = 5+10*(`ii'-1)

* Employment status: full-time, part-time,  or NILF
gen empstat_`jj' = 1 if v`ii'450 == 0
replace empstat_`jj' = 2 if v`ii'450 == 2 | v`ii'450 ==3 | v`ii'450 ==4
replace empstat_`jj' = 3 if v`ii'450 == 1 | v`ii'450 ==5 | v`ii'450 ==6
replace empstat_`jj' = 3 if nonpsetting_`jj'==0 | wksetting_`jj'==0

gen hrsperyr_`jj' = v`ii'478
gen hrsperwk_`jj' = v`ii'479
gen wksperyr_`jj' = v`ii'480

gen missingwksyr_`jj' = missing(wksperyr_`jj')
gen missinghourswk_`jj' = missing(hrsperwk_`jj')

replace wksperyr_`jj' = 0 if missingwksyr_`jj' ==1
replace hrsperwk_`jj' = 0 if missinghourswk_`jj' ==1

* Create bins of hours to use in splines
gen hrsbin_`jj' = 1 if hrsperwk_`jj'==0 & missinghourswk_`jj'==0
replace hrsbin_`jj' = 2 if hrsperwk_`jj'<35 & hrsperwk_`jj'>0
replace hrsbin_`jj' = 3 if hrsperwk_`jj'>=35 & hrsperwk_`jj'<50
replace hrsbin_`jj' = 4 if hrsperwk_`jj'>=50 & hrsperwk_`jj'<65
replace hrsbin_`jj' = 5 if hrsperwk_`jj'>=65
replace hrsbin_`jj' = 99 if missinghourswk_`jj'==1

* Create comprehensive NILF variable.  = 1 if zero hours per week, zero weeks per year, reports NILF, or work setting is "unemployed"
gen notempnow_`jj' = (hrsperwk_`jj'==0) if missinghourswk_`jj'==0
replace notempnow_`jj' = 1 if wksperyr_`jj'==0 & missingwksyr_`jj'==0
replace notempnow_`jj' = 1 if empstat_`jj'==3 & missing(notempnow_`jj')
replace notempnow_`jj' = 1 if nonpsetting_`jj'==0 | wksetting_`jj'==0

* PT now. = 1 if works > 0 and < 35 hrs per wk
gen ptnow_`jj' = (hrsbin_`jj'==2) if missinghourswk_`jj'==0
replace ptnow_`jj'=99 if missinghourswk_`jj'==1

gen loghourswk_`jj' = log(hrsperwk_`jj')
replace loghourswk_`jj'=0 if missinghourswk_`jj'==1

gen logwksyr_`jj' = log(wksperyr_`jj')
replace logwksyr_`jj'=0 if missingwksyr_`jj'==1

* Ever part time and ever not employed include currently PT or NILF
replace everpt_`jj'=1 if ptnow_`jj'==1 & everpt_`jj'!=1
replace evernotemp_`jj'=1 if notempnow_`jj'==1  & evernotemp_`jj'!=1

}

label values empstat* empstat


*** DO YOU PLAN TO MOVE JOBS
label define samesetting 1 yes 2 "prob yes" 3 "prob no" 4 no 99 missing
label define reason 1 "No Advance" 2 Bored 3 "Other Neg" 4 "New Job" 5 Family 7 Other 99 Miss

forvalues ii=1(1)3 {
local jj=5+10*(`ii'-1)

gen samesetting_`jj' = v`ii'481
replace samesetting_`jj' = 99 if missing(samesetting_`jj')
gen reasonforleaving_`jj' = v`ii'482
replace reasonforleaving_`jj'=99 if missing(reasonforleaving_`jj')
}

label values samesetting* samesetting
label values reason* reason

*** INCOME (in $2007)

* Income first year after graduation
gen incadj_1 = v0851
gen logincadj_1 = log(incadj_1)
gen missinginc1 = missing(logincadj_1)
replace logincadj_1=0 if missinginc1==1

* Income fifth year after graduation
gen incadj_5 = v1852
replace incadj_5 = v2852 if missing(incadj_5)
replace incadj_5 = v3852 if missing(incadj_5)

* Income 15 years after graduation
gen incadj_15 = v2853
replace incadj_15 = v3853 if missing(incadj_15)

* Income 25 years after graduation
gen incadj_25 = v3854


forvalues ii=1(1)3 {
local jj=5+10*(`ii'-1)

gen logincadj_`jj' = log(incadj_`jj')

* Non-labor and total income
gen otherhhincadj_`jj' =  v`ii'858
gen totalhhincadj_`jj' =  v`ii'859

* Hourly fee (lots of missing data)
gen hourlyfee_`jj' =  v`ii'860
}

* educational debt
forvalues ii = 1(1)3 {
local jj = 5+10*(`ii'-1)

gen educdebt_`jj' =  v`ii'862
replace educdebt_`jj' = . if educdebt_`jj'<0 | educdebt_`jj' > 10000000

}

*** FIRM SIZE

forvalues ii = 1(1)3 {
local jj = 5+10*(`ii'-1)

gen firmsize_`jj' = v`ii'863
replace firmsize_`jj' =v`ii'791 if missing(firmsize_`jj')
replace firmsize_`jj' =v`ii'793 if missing(firmsize_`jj')
replace firmsize_`jj' =v`ii'762 if missing(firmsize_`jj')
replace firmsize_`jj' =v`ii'792 if missing(firmsize_`jj')

replace firmsize_`jj'=. if firmsize_`jj'<0 | firmsize_`jj'>5000
gen logfirmsize_`jj' = log(firmsize_`jj')

* Is the respondent a solo practitioner
gen solopractice_`jj'=(firmsize_`jj'==0 & wksetting_`jj'==1)

gen missingfirmsize_`jj' = missing(firmsize_`jj')

replace firmsize_`jj' = 0 if missingfirmsize_`jj'==1
replace logfirmsize_`jj' = 0 if missingfirmsize_`jj'==1
replace logfirmsize_`jj' = 0 if solopractice_`jj'==1
replace solopractice_`jj' = 99 if missingfirmsize_`jj'==1 | wksetting_`jj'==0

* Composition of current workplace
gen numwomen_`jj' = v`ii'509
gen numminorities_`jj' = v`ii'510

gen missingwomen_`jj' = missing(v`ii'509)
gen missingminor_`jj' = missing(v`ii'510)

gen fracwomen_`jj' = numwomen_`jj'/firmsize_`jj' if firmsize_`jj'>0
gen fracminor_`jj' = numminorities_`jj'/firmsize_`jj' if firmsize_`jj'>0

replace fracwomen_`jj' = 0 if missing(fracwomen_`jj')
replace fracminor_`jj' = 0 if missing(fracminor_`jj')

* Create discrete bins to use as controls
gen firmsizebin_`jj'=1 if (firmsize_`jj'==0 & missingfirmsize_`jj'==0) | attystatus_`jj'==1
replace firmsizebin_`jj'=2 if firmsize_`jj'>0 & firmsize_`jj'<=10 & missingfirmsize_`jj'==0 & attystatus_`jj'!=1
replace firmsizebin_`jj'=3 if firmsize_`jj'>10 & firmsize_`jj'<=50 & missingfirmsize_`jj'==0
replace firmsizebin_`jj'=4 if firmsize_`jj'>50 & firmsize_`jj'<=200 & missingfirmsize_`jj'==0
replace firmsizebin_`jj'=5 if firmsize_`jj'>200 & firmsize_`jj'<=500 & missingfirmsize_`jj'==0
replace firmsizebin_`jj'=6 if firmsize_`jj'>500 & missingfirmsize_`jj'==0
replace firmsizebin_`jj'=99 if missingfirmsize_`jj'==1

}


*** HOW DOES RESPONDENT SPEND HIS/HER TIME

forvalues ii = 1(1)3 {
local jj = 5+10*(`ii'-1)

gen time_lib_`jj' = v`ii'486
gen time_int_`jj' = v`ii'487
gen time_lit_`jj' = v`ii'488
gen time_neg_`jj' = v`ii'489
gen time_draft_`jj' = v`ii'490
gen time_app_`jj' = v`ii'491
gen time_lob_`jj' = v`ii'492
gen time_adm_`jj' = v`ii'493
gen time_led_`jj' = v`ii'494
gen time_soc_`jj' = v`ii'495
gen time_rec_`jj' = v`ii'496
gen time_oth_`jj' = v`ii'497


egen totaltime_`jj' = rowtotal(time_lib_`jj' - time_oth_`jj')
gen missingtime_`jj' = (totaltime_`jj'<50)

* These should add up to 100.  If not, normalize so they do
foreach name in $time {
replace time_`name'_`jj' = time_`name'_`jj'/totaltime_`jj' if missingtime_`jj'==0
replace time_`name'_`jj' = 0 if missingtime_`jj'==1 | missing(time_`name'_`jj')
gen `name'2 = time_`name'_`jj'^2
}

* Indicators for whether individual spends more than 10%, 25%, or 50% on each area
foreach name in $time  {
gen timeind_`name'_`jj' = (time_`name'_`jj'>.1)
gen timespec_`name'_`jj' = (time_`name'_`jj'>.25)
gen timesuper_`name'_`jj' = (time_`name'_`jj'>.5)
}

* Measure of dispersion of time use (Herfindahl index)
egen herf_time_`jj' = rowtotal(lib2-oth2)
drop lib2-oth2  totaltime_`jj'
}


* substantitive time
forvalues ii = 1(1)3 {
local jj = 5+10*(`ii'-1)
gen subj_adm_`jj' = v`ii'513
gen subj_anti_`jj' = v`ii'514
gen subj_bank_`jj' = v`ii'515
gen subj_bkrpt_`jj' = v`ii'516
gen subj_civ_`jj' = v`ii'517
gen subj_comm_`jj' = v`ii'518
gen subj_cmerc_`jj' = v`ii'519
gen subj_crim_`jj' = v`ii'520
gen subj_dom_`jj' = v`ii'521
gen subj_emp_`jj' = v`ii'522
gen subj_ene_`jj' = v`ii'523
gen subj_env_`jj' = v`ii'524
gen subj_est_`jj' = v`ii'525
gen subj_govt_`jj' = v`ii'526
gen subj_imm_`jj' = v`ii'527
gen subj_tax_`jj' = v`ii'528
gen subj_ins_`jj' = v`ii'529
gen subj_int_`jj' = v`ii'530
gen subj_lab_`jj' = v`ii'531
gen subj_pat_`jj' = v`ii'532
gen subj_real_`jj' = v`ii'533
gen subj_sec_`jj' = v`ii'534
gen subj_tort_`jj' = v`ii'535
gen subj_other_`jj' = v`ii'536

egen totaltime_`jj' = rowtotal(subj_adm_`jj'-subj_other_`jj')
gen missingsubj_`jj' = (totaltime_`jj'<50)

* These should sum to 100.  Normalize so they do
foreach name in $subj1 $subj2 {
replace subj_`name'_`jj' = subj_`name'_`jj'/totaltime_`jj'  if missingsubj_`jj'==0
replace subj_`name'_`jj' = 0 if missingsubj_`jj'==1 | missing(subj_`name'_`jj')
gen `name'2 = subj_`name'_`jj'^2
}

* Indicators for more than 10%, 25%, or 50% of time on each
foreach name in $subj1 $subj2 {
gen subjind_`name'_`jj' = (subj_`name'_`jj'>.1)
gen subjspec_`name'_`jj' = (subj_`name'_`jj'>.25)
gen subjsuper_`name'_`jj' = (subj_`name'_`jj'>.5)
}

* Herfindahl index for dispersion of time
egen herf_subj_`jj' = rowtotal(adm2-other2)
drop adm2-other2 totaltime_`jj'
}

* client time

forvalues ii = 1(1)3 {
local jj = 5+10*(`ii'-1)
gen client_rich_`jj' = v`ii'569
gen client_othind_`jj' = v`ii'570
gen client_smbus_`jj' = v`ii'572
gen client_mdlg_`jj' = v`ii'575
gen client_f500_`jj' = v`ii'574
gen client_gov_`jj' = v`ii'577
gen client_nonp_`jj' = v`ii'578
gen client_oth_`jj' = v`ii'579

egen totaltime_`jj' = rowtotal(client_rich_`jj'-client_oth_`jj')
gen missingclient_`jj' = (totaltime_`jj'==0)

foreach name in $client {
replace client_`name'_`jj' = client_`name'_`jj'/totaltime_`jj' if totaltime_`jj'>0
replace client_`name'_`jj' = 0 if totaltime_`jj'==0 | missing(client_`name'_`jj')
gen `name'2 = client_`name'_`jj'^2
}
foreach name in $client {
gen clientind_`name'_`jj' = (client_`name'_`jj'>.1)
gen clientspec_`name'_`jj' = (client_`name'_`jj'>.25)
gen clientsuper_`name'_`jj' = (client_`name'_`jj'>.5)
}

egen herf_client_`jj' = rowtotal(rich2-oth2)
drop rich2-oth2  totaltime_`jj'
}

* SATISFACTION WITH LIFE DIMENSIONS

label define satis 1 "very satisfied" 7 "very unsatisfied"
forvalues ii = 1(1)3 {
local jj = 5+(`ii'-1)*10
gen satis_fam_`jj'=v`ii'080	
gen satis_famcar_`jj'=v`ii'082
gen satis_ls_`jj'=v`ii'410
gen satis_stress_`jj'=v`ii'678
gen satis_contwk_`jj'=v`ii'680
gen satis_socval_`jj'=v`ii'681
gen satis_relco_`jj'=v`ii'682
gen satis_inc_`jj'=v`ii'683
gen satis_prsocv_`jj'=v`ii'684
gen satis_intel_`jj'=v`ii'685
gen satis_prest_`jj'=v`ii'686
gen satis_over_`jj'=v`ii'688
}

label values satis* satis

*** PERCEPTION OF DISCRIMINATION
label define discrim 1 None 2 Litle 3 Lot 99 Miss

forvalues ii=1(1)3 {
local jj=5+10*(`ii'-1)

gen discrim_firm_`jj' = v`ii'733
gen discrim_lawyers_`jj' = v`ii'734
gen discrim_clients_`jj' = v`ii'735
replace discrim_clients_`jj'=. if discrim_clients_`jj'<0

replace discrim_firm_`jj'=99 if missing(discrim_firm_`jj')
replace discrim_lawyers_`jj'=99 if missing(discrim_lawyers_`jj')
replace discrim_clients_`jj'=99 if missing(discrim_clients_`jj')

}

label values discrim* discrim


* Drop if graduates after age 30
drop if ageatlsgrad>30

****  MODELING RESPONSE - estimate response probability and create weights for use in regressions

probit returned_5 female ageatlsgrad ageatlsgrad_2 i.race lsgpa lsatperc i.transfer i.missingprels i.ugschool uggpa ib80.cohort
predict rhat_5
gen weight_5 = 1/rhat_5

probit returned_15 female ageatlsgrad ageatlsgrad_2 i.race lsgpa lsatperc i.transfer i.missingprels i.ugschool uggpa ib80.cohort
predict rhat_15 if jdyr<=1991
gen weight_15 = 1/rhat_15

compress
save longit_clean.dta, replace



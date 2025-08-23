insheet using "Z:\bulk\ACS\OccChar\OccChar.csv", comma clear

tempfile OccChar
save `OccChar'

foreach occ in 29-1071-00 17-2121-01 17-2121-02 17-2061-00 29-1124-00 19-2011-00 19-2012-00 11-2011-00 11-9111-00 17-2051-00 ///
53-2021-00 53-2022-00 29-1123-00 17-2051-01 11-1021-00 19-2041-00 19-2042-00 19-1042-00 15-2031-00 13-2011-01 ///
13-2011-02 15-1141-00 17-2081-01 17-2081-00 39-4031-00 33-1021-01 33-1021-02 11-9131-00 17-2021-00 17-2031-00 ///
11-3061-00 17-2141-00 17-2131-00 15-1131-00 29-1181-00 29-1011-00 11-9033-00 11-9032-00 19-2021-00 27-3031-00 ///
15-1111-00 15-1121-00 13-2031-00 19-3031-01 19-3031-02 19-3031-03 19-3032-00 19-3039-01 17-2112-00 17-2111-01 ///
51-8011-00 51-8012-00 51-8013-00 13-2053-00 11-3111-00 11-3121-00 11-3131-00 19-2099-01 33-1012-00 17-1011-00 ///
17-1012-00 33-3021-01 33-3021-02 33-3021-03 33-3021-05 33-3021-06 11-3051-00 11-3051-01 11-3051-02 11-3051-04 ///
29-1122-00 29-1122-01 13-1199-01 13-1199-03 13-1199-04 11-9161-00 13-1121-00 13-1151-00 19-3051-00 19-2031-00 ///
19-2032-00 29-1141-04 29-1141-03 29-1141-02 29-1141-01 29-1141-00 47-4021-00 15-1142-00 13-2071-01 13-2072-00 ///
27-3042-00 41-3021-00 41-4011-00 41-4011-07 41-4012-00 27-2012-01 27-2012-02 27-2012-03  27-2012-04 27-2012-05 ///
11-3011-00 13-1041-07 13-1041-06 13-1041-04 13-1041-03 13-1041-02 13-1041-01 13-1051-00 11-9021-00 41-1012-00 ///
43-4011-00 25-1194-00 25-1193-00 25-1192-00 25-1191-00 25-1126-00 25-1125-00 25-1124-00 25-1123-00 25-1122-00 ///
25-1121-00 25-1113-00 25-1112-00 25-1111-00 25-1082-00 25-1081-00 25-1072-00 25-1071-00 25-1067-00 25-1066-00 ///
25-1065-00 25-1064-00 25-1063-00 25-1062-00  25-1061-00 25-1054-00 25-1053-00 25-1052-00 25-1051-00 25-1043-00 ///
25-1042-00 25-1041-00 25-1032-00 25-1031-00 25-1022-00 25-1021-00 25-1011-00 53-5022-00 53-5021-03 53-5021-02 53-5021-01{
insheet using "Z:\bulk\ACS\OccChar\Temp\work_context_`occ'.csv", comma clear
rename context cont
gen double context=round(cont/100, 0.01)
compress
sort workcontext

keep if workcontext=="Contact With Others" | workcontext=="Coordinate or Lead Others" | workcontext=="Degree of Automation" | workcontext=="Duration of Typical Work Week"  | workcontext=="Face-to-Face Discussions" | workcontext=="Freedom to Make Decisions"  | workcontext=="Frequency of Conflict Situations" | workcontext=="Frequency of Decision Making"  | workcontext=="Impact of Decisions on Co-workers or Company Results"  | workcontext=="Level of Competition" | workcontext=="Physical Proximity" | workcontext=="Structured versus Unstructured Work" | workcontext=="Time Pressure" | workcontext=="Work Schedules"  | workcontext=="Work With Work Group or Team"

	local wwd = context[4]
	local freedom = context[6]
	local freq = context[8]
	local impact = context[9]
	local compet = context[10]
	local struct = context[12]
	local timep = context[13]
	local regs = context[14]
	local cont = context[1]
	local coord = context[2]
	local face = context[5]
	local tea = context[15]
	local phys = context[11]
	local conf = context[7]
	local auto = context[3]

macro list _all

insheet using "Z:\bulk\ACS\OccChar\Temp\work_activities_`occ'.csv", comma clear
gen double activity=round(importance/100, 0.01)
compress
sort workactivity
keep if workactivity=="Communicating with Supervisors, Peers, or Subordinates" | workactivity=="Coordinating the Work and Activities of Others" | workactivity=="Developing and Building Teams" | workactivity=="Establishing and Maintaining Interpersonal Relationships"

	local comm=activity[1]
	local coordin=activity[2]
	local devtea=activity[3]
	local interp=activity[4]

use `OccChar', clear
display "USE SUCCESSFUL"
	replace wwduration=`wwd' if onet=="`occ'"
	replace freedom_decision=`freedom' if onet=="`occ'"
	replace freq_decision=`freq' if onet=="`occ'"
	replace impact_decision=`impact' if onet=="`occ'"
	replace competition=`compet' if onet=="`occ'"
	replace structuredwork=`struct' if onet=="`occ'"
	replace timepressure=`timep' if  onet=="`occ'"
	replace reg_schedule=`regs' if onet=="`occ'"
	replace contact=`cont' if onet=="`occ'"
	replace coordinate=`coord' if onet=="`occ'"
	replace facetime=`face' if onet=="`occ'"
	replace team=`tea' if  onet=="`occ'"
	replace phys_prox = `phys' if onet=="`occ'"
	replace conflict=`conf' if onet=="`occ'"
	replace automation=`auto' if onet=="`occ'"
	display "WORK CONTEXT SUCCESSFUL FOR `occ'"
	
	replace coordinating=`coordin' if onet=="`occ'"
	replace developing_teams=`devtea' if onet=="`occ'"
	replace interpersonal_rel=`interp' if onet=="`occ'"
	replace communicating=`comm' if onet=="`occ'"
	display "WORK ACTIVITIES SUCCESSFUL FOR `occ'"
	
tempfile OccChar
save `OccChar'
}

drop tot
egen tot=total(n), by(occ2)
drop weight
gen weight=n/tot
replace weight=1 if n==. & onet!=""

outsheet using "Z:\bulk\ACS\OccChar\OccChar.csv", replace comma
/*tempfile OccChar
save `OccChar'

insheet using "Z:\bulk\ACS\female_wage2\acs_occ_categories.csv", clear comma
merge 1:m occ2 using `OccChar'
keep if _m!=2
*/
keep if onet!=""
drop tot _m
format occ2_ onet_ %75s
sort occ2
outsheet using "Z:\bulk\ACS\OccChar\OccChar.csv", replace comma


//Checks
foreach var in coordinating developing_teams interpersonal_rel communicating wwduration freedom_decision freq_decision impact_decisions competition structuredwork timepressure reg_schedule contact coordinate facetime team phys_prox conflict automation{
display "`var'"
list n if `var'>1
}



//creating a stata files out of it
insheet using "Z:\bulk\ACS\OccChar\OccChar.csv", comma clear
keep occ2 occ2_lab category
egen gru=group(occ2)
gen first=1 if gru!=gru[_n-1]
duplicates tag occ2 first, gen(dup)
replace dup=0 if first==.
tab dup
keep if first==1
drop gru first dup
tempfile categories
save `categories'

insheet using "Z:\bulk\ACS\OccChar\OccChar.csv", comma clear
collapse coordinating developing_teams interpersonal_rel communicating wwduration freedom_decision freq_decision impact_decisions competition structuredwork timepressure reg_schedule contact coordinate facetime team phys_prox conflict automation weight[aw=weight], by(occ2)
merge 1:1 occ2 using `categories'
order occ2 occ2_l category
drop _m weight

gen business= category=="business"
gen health= category=="health"
gen other= category=="other"
gen science= category=="science"
gen tech= category=="tech"

outsheet using "Z:\bulk\ACS\OccChar\OccChar_collapsed.csv", replace comma
label var coordinating "coordinate or lead others"
label var contact "contact with others"
label var automation "degree of automation"
label var facetime "face-to-face discussions"
label var wwduration "duration of typical work week"
label var freedom_decision "freedom to make decisions"
label var freq_d "frequency of decision making"
label var impact_d "impact of decisions on coworkers or company results"
label var conflict "frequency of conflict situations"
label var competition "level of competition"
label var phys_prox "physical proximity"
label var structured "structured vs unstructured work"
label var timepressure "time pressure"
label var reg_s "regular work schedule"
label var team "work with a workgroup or team"
label var coordinating "coordinating the work and activities of others"
label var developing "Developing and Building Teams"
label var communicating "Communicating with Supervisors, Peers or Subordinates"
label var interpersonal "Establishing and Maintaining Interpersonal Relationships"
 
save "Z:\bulk\ACS\OccChar\OccChar_collapsed.dta", replace 

* Maps the SOC-level O*Net task composites onto ISCO-08 4-digit codes,
* producing the task-score dataset used by 2_build_data.do and Table 5.
* Called by 1_build_task_scores.do.
*   in : $path_raw/isco08_soc10_crosswalk.xls  (BLS 2010 SOC <-> ISCO-08;
*        sheet "2010 SOC to ISCO-08", header on row 7, columns A:F)
*        $path_clean_onet/onet16_tasks_soc.dta
*   out: $path_raw/isco_soc10_crosswalk.dta
*        $path_raw/scores_isco4dig.dta   (439 ISCO-08 4-digit codes x 4 scores)
//////////////////////////////////////
// Step 1: parse the SOC-2010 / ISCO-08 crosswalk
//////////////////////////////////////

import excel "$path_raw/isco08_soc10_crosswalk.xls", sheet("2010 SOC to ISCO-08") cellrange(A7:F1132) firstrow clear


gen soc2010_aux = substr(SOCCode,1,7)
	split soc2010_aux, parse("-") gen(soc2010_aux2)
	gen soc2010 = soc2010_aux21 + soc2010_aux22
	label var soc2010 "SOC2010 code"
	
	
	rename SOCTitle soc2010_title
	
	drop part Comment81711 SOCCode soc2010_aux*
	
save $path_raw/isco_soc10_crosswalk, replace


//////////////////////////////////////
// Step 2: attach the task scores to ISCO-08 codes
//////////////////////////////////////

* O*NET-SOC codes extend the 6-digit SOC code with a decimal suffix only, so the
* first six digits of an O*NET-SOC code are the SOC-2010 code and can be matched
* to the crosswalk directly.
use "$path_clean_onet/onet16_tasks_soc", clear

gen soc2010 = soc_1 + soc_2 
drop soc_1 soc_2

merge 1:m soc2010 using $path_raw/isco_soc10_crosswalk
	* The SOC codes that fail to match are mostly the "all other" residual
	* categories, which the next two blocks fill in by imputation.


* Residual "all other" categories end in 9. SOC 11-1031 (Legislators) is the one
* code outside that pattern that also has no O*NET scores, so it is imputed too.
gen soc_lastdig = substr(soc2010, 6, 6)

* First pass: impute a residual code's missing scores with the average over the
* other codes sharing its first 5 SOC digits.
gen soc_5 = substr(soc2010, 1, 5) 

foreach var in socskills_onet16 routine_onet16 cognitive_onet16 manual_onet16{
	
	bysort soc_5: egen m`var'_soc5 = mean(`var')
	replace `var' = m`var'_soc5 if (soc_lastdig == "9" | soc2010 == "111031") & `var' == .
	
}

* Second pass: for codes still missing after the first pass, widen the average
* to all codes sharing the first 4 SOC digits.
gen soc_4 = substr(soc2010, 1, 4) 

foreach var in socskills_onet16 routine_onet16 cognitive_onet16 manual_onet16{
	
	bysort soc_4: egen m`var'_soc4 = mean(`var')
	replace `var' = m`var'_soc4 if (soc_lastdig == "9" |  soc2010 == "111031") & `var' == .
	
}


* Report the ISCO codes that are still without scores after imputation (the
* armed-forces codes; see data/raw/README.md).
bys ISCO08Code : egen mean_socskills=mean(socskills_onet16)	
tab ISCO08Code if mean_socskills==.
list ISCO08Code if mean_socskills==., clean noobs


	rename ISCO08Code occup4_10

* Three codes carry a trailing space in the crosswalk file; strip it so they do
* not form separate categories in the collapse below.
replace occup4_10 =  "3322" if occup4_10 ==  "3322 "
replace occup4_10 =  "5169" if occup4_10 ==  "5169 "
replace occup4_10 =  "7422" if occup4_10 ==  "7422 "

* Average the scores over all SOC-2010 occupations mapping to the same ISCO-08 code
collapse (mean) socskills_onet16 routine_onet16 cognitive_onet16 manual_onet16, by(occup4_10)	

save $path_raw/scores_isco4dig, replace

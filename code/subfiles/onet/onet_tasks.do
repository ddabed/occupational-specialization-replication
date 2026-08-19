* Combines the four O*Net 2016 modules into the Deming-style task composites
* (social skills, routine, cognitive, manual) at the SOC level.
* Called by 1_build_task_scores.do.
*   out: $path_clean_onet/onet16_tasks_soc.dta
****************************************
*** Generate ONet 2016 task measures ***
****************************************

	* From Skills module: social skill measures and one of the math measures
use soc_1 soc_2 skill5_lvl_16 skill11_lvl_16 ///
		skill12_lvl_16 skill13_lvl_16 skill14_lvl_16 ///
		skill33_lvl_16 skill34_lvl_16 skill35_lvl_16 ///
		using "$path_clean_onet/onet16_skill_soc", clear

	* From Work Context module: routine measures
merge 1:1 soc_1 soc_2 using "$path_clean_onet/onet16_wkcontext_soc", ///
	keep(1 3) ///
	keepusing(wkcontext35_16 wkcontext37_16) nogen
	
	* From Abilities module: one of the math measures
merge 1:1 soc_1 soc_2 using "$path_clean_onet/onet16_abil_soc", ///
	keep(1 3) ///
	keepusing(abil12_lvl_16 abil26_lvl_16 abil39_lvl_16) nogen
	
	* From Knowledge module: one of the math measures
merge 1:1 soc_1 soc_2 using "$path_clean_onet/onet16_knowl_soc", ///
	keep(1 3) ///
	keepusing(knowl15_lvl_16) nogen

	
		
* Following Deming, transform scale of variables to 0-10	
foreach var of varlist skill* wkcontext* abil* knowl* {
	sum `var', meanonly
	replace `var'=`var'-r(min)
	sum `var', meanonly
	replace `var'=`var'/r(max)
	replace `var'=`var'*10
}

* Following Deming, create composites
	
foreach num in 16 {
* Social skills
egen socskills_onet`num'=rowmean(skill11_lvl_`num' skill12_lvl_`num' skill13_lvl_`num' skill14_lvl_`num')
drop skill11_lvl_`num' skill12_lvl_`num' skill13_lvl_`num' skill14_lvl_`num'

* Routine
egen routine_onet`num'=rowmean(wkcontext35_`num' wkcontext37_`num')
drop wkcontext35_`num' wkcontext37_`num'

* Cognitive: Average of the three math measures and the three DCP (management) questions
egen cognitive_onet`num'=rowmean(abil12_lvl_`num' skill5_lvl_`num' knowl15_lvl_`num' skill33_lvl_`num' skill34_lvl_`num' skill35_lvl_`num')
drop abil12_lvl_`num' skill5_lvl_`num' knowl15_lvl_`num' skill33_lvl_`num' skill34_lvl_`num' skill35_lvl_`num'

* Manual: Average of Abilities 26 Multilimb Coordination and 39 Gross Body Coordination
egen manual_onet`num'=rowmean(abil26_lvl_`num' abil39_lvl_`num')
drop abil26_lvl_`num' abil39_lvl_`num'
}

* Following Deming, rescale composites
foreach var in socskills_onet16 routine_onet16 cognitive_onet16 manual_onet16 {
	sum `var', meanonly
	replace `var'=`var'-r(min)
	sum `var', meanonly
	replace `var'=`var'/r(max)
	replace `var'=`var'*10
}

/*
* Normalize measures to mean zero s.d. one across occ1990dd codes 
*** (weighted using 1980 occupational employment shares)
gen aux=1
tempfile aux1 aux2 aux3
save `aux1', replace

* Gen dataset with weighted means
collapse socskills_onet* routine_onet* cognitive_onet* manual_onet* [w=empshare1980]
foreach y in 02 16 {
	foreach name in socskills_onet routine_onet cognitive_onet manual_onet {
	rename `name'`y' mean`name'`y'
	}
}
gen aux=1
save `aux2', replace

* Gen dataset with weighted sd's
use `aux1', clear
collapse (sd) socskills_onet* routine_onet* cognitive_onet* manual_onet* [w=empshare1980]
foreach y in 02 16 {
	foreach name in socskills_onet routine_onet cognitive_onet manual_onet {
	rename `name'`y' sd`name'`y'
	}
}
gen aux=1
save `aux3', replace

* Merge in weighted means/sd's
use `aux1', clear
merge m:1 aux using `aux2', nogen
merge m:1 aux using `aux3', nogen
drop aux

*** Normalization
foreach y in 02 16 {
	foreach name in socskills_onet routine_onet cognitive_onet manual_onet {
	rename `name'`y' `name'`y'_raw
	* Generate weighted mean
	gen `name'`y' = (`name'`y'_raw - mean`name'`y') / sd`name'`y'
	drop mean`name'`y' sd`name'`y'
	}
}
*/


save "$path_clean_onet/onet16_tasks_soc", replace


* Combines the four O*Net 2016 modules into the Deming-style task composites
* (social skills, routine, cognitive, manual) at the SOC level.
* Called by 1_build_task_scores.do.
*   out: $path_clean_onet/onet16_tasks_soc.dta
****************************************
*** Generate ONet 2016 task measures ***
****************************************

	* From Skills module: the social-skill measures, one math measure, and the
	* three "decision-making, communication and problem-solving" (DCP) measures
use soc_1 soc_2 skill5_lvl_16 skill11_lvl_16 ///
		skill12_lvl_16 skill13_lvl_16 skill14_lvl_16 ///
		skill33_lvl_16 skill34_lvl_16 skill35_lvl_16 ///
		using "$path_clean_onet/onet16_skill_soc", clear

	* From Work Context module: the two routine measures
merge 1:1 soc_1 soc_2 using "$path_clean_onet/onet16_wkcontext_soc", ///
	keep(1 3) ///
	keepusing(wkcontext35_16 wkcontext37_16) nogen
	
	* From Abilities module: mathematical reasoning, and the two coordination
	* measures that form the manual composite
merge 1:1 soc_1 soc_2 using "$path_clean_onet/onet16_abil_soc", ///
	keep(1 3) ///
	keepusing(abil12_lvl_16 abil26_lvl_16 abil39_lvl_16) nogen
	
	* From Knowledge module: the third math measure
merge 1:1 soc_1 soc_2 using "$path_clean_onet/onet16_knowl_soc", ///
	keep(1 3) ///
	keepusing(knowl15_lvl_16) nogen

	
		
* Rescale each input measure to 0-10, following Deming (2017)
foreach var of varlist skill* wkcontext* abil* knowl* {
	sum `var', meanonly
	replace `var'=`var'-r(min)
	sum `var', meanonly
	replace `var'=`var'/r(max)
	replace `var'=`var'*10
}

* Build the four composites, following Deming (2017)
	
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

* Rescale the composites to 0-10 as well
foreach var in socskills_onet16 routine_onet16 cognitive_onet16 manual_onet16 {
	sum `var', meanonly
	replace `var'=`var'-r(min)
	sum `var', meanonly
	replace `var'=`var'/r(max)
	replace `var'=`var'*10
}

save "$path_clean_onet/onet16_tasks_soc", replace


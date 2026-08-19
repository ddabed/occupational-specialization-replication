* Builds the O*Net 2016 ABILITIES, KNOWLEDGE and SKILLS modules at the
* SOC level. Called by 1_build_task_scores.do.
*   in : $path_raw_onet/{Abilities,Knowledge,Skills}.txt  (O*NET 21.0, 2016)
*   out: $path_clean_onet/onet16_{abil,knowl,skill}[_soc].dta


* This do-file builds a dataset of the O*Net 2016 ABILITIES, KNOWLEDGE and
* SKILLS components. 
***** THIS PART HAS BEEN COMMENTED OUT FOR FISS-FIRMS PROJECT (BUT KEEPING IT IN CASE IT ENDS UP BEING RELEVANT)
	* It aggregates them to 2010 Census codes by doing a weighted average of all 
	* the O*Net occ's that fall into the same 2010 Census code based on OES 
	* employment data, and then aggregates to occ1990dd codes again doing a 
	* weighted average of all the 2010 codes that fall into the same occ1990dd
	* code using OES employment data

*************************************************************************
******************************** ONET 2016 ******************************

tempfile temp

foreach module in abil knowl skill {

if "`module'"=="abil" {
insheet using "$path_raw_onet/Abilities.txt", clear
* Source: O*Net Resource Center Analyst Database;
* http://www.onetcenter.org/database.html;
* https://www.onetcenter.org/db_releases.html

* Number of dimensions in this module:
local n_dim=52
}

if "`module'"=="knowl" {
insheet using "$path_raw_onet/Knowledge.txt", clear
* Number of dimensions in this module:
local n_dim=33
}

if "`module'"=="skill" {
insheet using "$path_raw_onet/Skills.txt", clear
* Number of dimensions in this module:
local n_dim=35
}

keep onetsoccode elementid elementname scaleid datavalue

reshape wide datavalue, i(onetsoccode elementid) j(scaleid) string

rename datavalueLV lvl
rename datavalueIM imp
	corr imp lv, m

* Generate score that combines importance and level 
gen score=imp^(2/3)*lvl^(1/3)

egen dim=group(elementid)

keep onetsoccode lvl imp score dim

reshape wide lvl imp score, i(onetsoccode) j(dim)

* Rename to make clear that it is from the corresponding module of ONet 2016
forvalues num=1/`n_dim' {
	foreach name in lvl imp score {
		rename `name'`num' `module'`num'_`name'_16
	}
}

* Label variables
do "$path_do_sub/onet/label_`module'.do"

split onetsoccode, gen(soc_) parse(- .)
	* soc_1-soc_2 are the SOC code, soc_3 is the extra bit added by ONet;
sort soc_1 soc_2
rename onetsoccode onet16

save "$path_clean_onet/onet16_`module'", replace

*** Collapse so that each soc_1 soc_2 code appears only once (i.e. combine the
* even finer occupations unique to ONet doing a simple average)
collapse *lvl* *imp* *score*, by(soc_1 soc_2)

save "$path_clean_onet/onet16_`module'_soc", replace

}

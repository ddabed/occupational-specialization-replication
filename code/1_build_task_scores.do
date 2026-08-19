clear all

*=========================================================================
* 1_build_task_scores.do -- build the O*Net task-score lookup
*
* Produces data/raw/scores_isco4dig.dta: the Deming-style task composites
* (social skills, routine, cognitive, manual) averaged onto ISCO-08 4-digit
* occupation codes. It is an INPUT to 2_build_data.do (Step 3) and underlies
* the task-concentration measure in Table 5.
*
* This is the only stage of the package that runs entirely on public data.
* scores_isco4dig.dta is shipped with the package, so you only need to run
* this file if you want to rebuild the lookup from source.
*
* INPUTS (see data/raw/README.md for how to obtain them)
*   data/raw/onet/{Abilities,Knowledge,Skills,Work Context}.txt
*       O*NET 21.0 (2016), from https://www.onetcenter.org/db_releases.html
*   data/raw/isco08_soc10_crosswalk.xls
*       BLS 2010 SOC <-> ISCO-08 crosswalk (shipped; public domain)
*
* OUTPUTS
*   data/clean/onet/onet16_*.dta        intermediates
*   data/raw/isco_soc10_crosswalk.dta  parsed crosswalk
*   data/raw/scores_isco4dig.dta       the lookup consumed downstream
*=========================================================================

* Locate the shared configuration. Run this file from the package's code/ folder.
capture confirm file "_paths.do"
if _rc {
	display as error "Run this do-file from the package's {bf:code/} folder, e.g."
	display as error `"    cd "<path>/replication-package/code" "'
	exit 601
}
include "_paths.do"

cap log close
log using $path_out_log/1_build_task_scores, replace

* Fail early with a clear message if the O*NET download is missing.
foreach file in "Abilities" "Knowledge" "Skills" "Work Context" {
	capture confirm file "$path_raw_onet/`file'.txt"
	if _rc {
		display as error "Missing: $path_raw_onet/`file'.txt"
		display as error "Download O*NET 21.0 (2016) -- see data/raw/README.md."
		exit 601
	}
}

*-------------------------------------------------------------------------
* Step 1: build the four O*Net modules at the SOC level
*-------------------------------------------------------------------------
do "$path_do_sub/onet/build_onet_abil_knowl_skill.do"   // abilities, knowledge, skills
do "$path_do_sub/onet/build_onet_workcontext.do"        // work context

*-------------------------------------------------------------------------
* Step 2: combine the modules into the task composites
*-------------------------------------------------------------------------
do "$path_do_sub/onet/onet_tasks.do"                    // -> onet16_tasks_soc.dta

*-------------------------------------------------------------------------
* Step 3: map SOC -> ISCO-08 4-digit
*-------------------------------------------------------------------------
do "$path_do_sub/onet/make_scores_isco4dig.do"          // -> scores_isco4dig.dta

cap log close

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
* scores_isco4dig.dta is included with the package, so you only need to run
* this file if you want to rebuild the file from the raw data.
*
* INPUTS (see data/raw/README.md for how to obtain them)
*   data/raw/onet/{Abilities,Knowledge,Skills,Work Context}.txt
*       O*NET 21.0 (2016), from https://www.onetcenter.org/db_releases.html
*   data/raw/isco08_soc10_crosswalk.xls
*       BLS 2010 SOC <-> ISCO-08 crosswalk (included in package; public domain)
*
* OUTPUTS
*   data/clean/onet/onet16_*.dta        intermediates
*   data/raw/isco_soc10_crosswalk.dta  parsed crosswalk
*   data/raw/scores_isco4dig.dta       the file used downstream
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

*-------------------------------------------------------------------------
* Is the O*NET download present?
* Checking file by file rather than in a foreach loop, because one of the
* names contains a space ("Work Context.txt").
*-------------------------------------------------------------------------
global onet_ok 1
global onet_missing ""

capture program drop _onetck
program define _onetck
	args fname
	capture confirm file "$path_raw_onet/`fname'"
	if _rc {
		global onet_ok 0
		global onet_missing "${onet_missing} `fname'"
	}
end

_onetck "Abilities.txt"
_onetck "Knowledge.txt"
_onetck "Skills.txt"
_onetck "Work Context.txt"
capture program drop _onetck

if ${onet_ok} == 0 {

	* The file constructed here is included with the package, so a missing 
	* O*NET download is only a problem if you actually meant to rebuild it. 
	* If the output is already there, say so and stop cleanly rather than 
	* raising an error.
	capture confirm file "$path_raw/scores_isco4dig.dta"
	if _rc == 0 {
		display _n "{hline 70}"
		display "  O*NET SOURCE FILES NOT FOUND -- skipping the rebuild."
		display ""
		display "  Missing in $path_raw_onet :"
		display "     ${onet_missing}"
		display ""
		display "  TO BUILD FROM SCRATCH (what this file is for): download the"
		display "  O*NET 21.0 (2016) text release, put those files in the folder"
		display "  above, and run this file again. See data/raw/README.md."
		display ""
		display "  TO PROCEED WITHOUT REBUILDING: data/raw/scores_isco4dig.dta is"
		display "  already present and is what the rest of the package consumes,"
		display "  so you can continue with"
		display "      do 2_build_data.do"
		display "{hline 70}"
		cap log close
		exit
	}

	display as error _n "Cannot build the task scores: the O*NET files are missing AND"
	display as error "data/raw/scores_isco4dig.dta is not present either."
	display as error "Missing in $path_raw_onet :${onet_missing}"
	display as error "Download O*NET 21.0 (2016) -- see data/raw/README.md."
	cap log close
	exit 601
}

display _n "O*NET files found. Rebuilding scores_isco4dig.dta from source."

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

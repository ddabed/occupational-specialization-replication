clear all

*=========================================================================
* 0_check_setup.do -- pre-flight check. Run this FIRST.
*
* Verifies that everything the package needs is in place: Stata packages,
* graph schemes, the projectfolder setting, the input data, and R. It takes
* seconds and WRITES NOTHING, so it is safe to run at any time.
*
* Worth doing first because 3_run_analysis.do runs for DAYS (it re-estimates
* the AKM model and the local projections). 2_build_data.do is comparatively
* quick -- a couple of hours.
*=========================================================================

global chk_nfail 0
global chk_nwarn 0

* Check that one file exists. Called as: _ckfile "<path>" "<description>"
capture program drop _ckfile
program define _ckfile
	args path label
	capture confirm file "`path'"
	if _rc {
		display as error "    FAIL  missing: `path'"
		global chk_nfail = ${chk_nfail} + 1
	}
	else display "    ok    `label'"
end

* Check that one directory exists. Called as: _ckdir "<path>" "<description>"
capture program drop _ckdir
program define _ckdir
	args path label
	mata: st_local("ex", strofreal(direxists(st_local("path"))))
	if `ex' == 0 {
		display as error "    FAIL  directory not found: `path'"
		global chk_nfail = ${chk_nfail} + 1
	}
	else display "    ok    `label'"
end

display _n "{hline 72}"
display "  PRE-FLIGHT CHECK"
display "{hline 72}"

*-------------------------------------------------------------------------
* 1. Stata version
*-------------------------------------------------------------------------
display _n "[1] Stata version"
if c(stata_version) < 17 {
	display as error "    FAIL  Stata `c(stata_version)' found; the code declares version 17."
	global chk_nfail = ${chk_nfail} + 1
}
else display "    ok    Stata `c(stata_version)' `c(flavor)'"

*-------------------------------------------------------------------------
* 2. User-written commands
*-------------------------------------------------------------------------
display _n "[2] Required user-written commands"
foreach cmd in reghdfe ftools esttab estpost eststo estadd gcollapse gegen xlincom colorpalette {
	capture which `cmd'
	if _rc {
		display as error "    FAIL  `cmd' not installed"
		global chk_nfail = ${chk_nfail} + 1
	}
	else display "    ok    `cmd'"
}

*-------------------------------------------------------------------------
* 3. Graph schemes
*    Both are used: plotplain for Figure 1, cleanplots for everything else.
*-------------------------------------------------------------------------
display _n "[3] Graph schemes"
foreach sch in cleanplots plotplain {
	capture findfile scheme-`sch'.scheme
	if _rc {
		display as error "    FAIL  scheme `sch' not installed"
		global chk_nfail = ${chk_nfail} + 1
	}
	else display "    ok    scheme `sch'"
}
if ${chk_nfail} > 0 {
	display as error _n "    -> Run {bf:0_install_packages.do} to fix the items above."
}

*-------------------------------------------------------------------------
* 4. projectfolder and the directory layout
*-------------------------------------------------------------------------
display _n "[4] Paths"
capture confirm file "_paths.do"
if _rc {
	display as error "    FAIL  _paths.do not found."
	display as error "          Run this from the package's code/ folder:"
	display as error `"              cd "<path>/replication-package/code" "'
	exit 601
}
include "_paths.do"
display "    ok    projectfolder = $projectfolder"

*-------------------------------------------------------------------------
* 5. Input data
*-------------------------------------------------------------------------
display _n "[5] Input data -- shipped with the package"
_ckfile "$path_raw/scores_isco4dig.dta"        "scores_isco4dig.dta"
_ckfile "$path_raw/isco08_soc10_crosswalk.xls" "isco08_soc10_crosswalk.xls"
_ckfile "$path_raw_INE/priceindex.dta"         "INE/priceindex.dta"
_ckfile "$path_raw_INE/PriceIndex.xls"         "INE/PriceIndex.xls"

display _n "[5] Input data -- confidential, supplied by you (see data/raw/README.md)"

* SCIE is needed by step 3 and has no substitute.
_ckdir "$path_raw_SCIE" "SCIE folder (needed by step 3)"

*-- QdP comes in two forms and the requirement depends on which you have:
*     data/raw/QdP/           original SPSS files. Read ONLY by step 1.
*     data/raw/QdP-renamed/   written by step 1. Read by step 2 (makepanel.R)
*                             AND at analysis time by Table 6
*                             (wage_reg_HHI_3dig_withlayers.do).
*   So if QdP-renamed is already complete, step 1 can be skipped entirely.
local nren 0
forvalues y = 2010/2019 {
	capture confirm file "$path_raw_QdPren/workers_renamed_occlabel`y'.dta"
	local rc_w = _rc
	capture confirm file "$path_raw_QdPren/firms_renamed`y'.dta"
	if `rc_w' == 0 & _rc == 0 local nren = `nren' + 1
}

mata: st_local("qdp_raw", strofreal(direxists(st_global("path_raw_QdP"))))

if `nren' == 10 {
	display "    ok    QdP-renamed/ complete: all 10 years present"
	display "          -> step 1 is already done. You may set {bf:global do_step1_rename 0}"
	display "             in 2_build_data.do to skip re-importing the SPSS files."
}
else if `nren' > 0 {
	display as result "    WARN  QdP-renamed/ is partial: `nren' of 10 years present."
	display as result "          Step 1 must run to complete it (leave do_step1_rename 1)."
	global chk_nwarn = ${chk_nwarn} + 1
}
else display "    ..    QdP-renamed/ empty -- step 1 will create it"

if `nren' < 10 {
	* Step 1 has to run, so the original SPSS files are required.
	if `qdp_raw' == 0 {
		display as error "    FAIL  QdP-renamed/ is incomplete AND data/raw/QdP/ is missing."
		display as error "          One of the two is required: either the original SPSS files"
		display as error "          in data/raw/QdP/, or a complete data/raw/QdP-renamed/."
		global chk_nfail = ${chk_nfail} + 1
	}
	else {
		display "    ok    QdP folder (needed by step 1)"
		* Spot-check one raw file, to catch a wrong folder or renamed copies.
		capture confirm file "$path_raw_QdP/QP_Trabalhadores_2010_Fins_Cientificos_21-05-2018.sav"
		if _rc {
			display as result "    WARN  the 2010 raw QdP worker file was not found under"
			display as result "          $path_raw_QdP"
			display as result "          If your copies are named differently, reconcile them with"
			display as result "          the import spss lines in build_1_rename_raw_files.do."
			global chk_nwarn = ${chk_nwarn} + 1
		}
		else display "    ok    2010 raw QdP worker file present"
	}
}
else if `qdp_raw' == 0 {
	display "    ..    data/raw/QdP/ absent, but not needed since step 1 is done"
}

* Table 6 reads QdP-renamed directly, so flag it even if you skip the build.
if `nren' < 10 {
	display as result "    note  Table 6 reads QdP-renamed/workers_renamed_occlabel*.dta"
	display as result "          directly, so those files must exist before 3_run_analysis.do."
}

*-------------------------------------------------------------------------
* 6. Code files
*-------------------------------------------------------------------------
display _n "[6] Code"
_ckfile "$path_do_sub/makepanel.R"                    "subfiles/makepanel.R"
_ckfile "$path_do_sub/build_1_rename_raw_files.do"    "subfiles/build_1_rename_raw_files.do"
_ckfile "$path_do_sub/build_3_label_and_merge.do"     "subfiles/build_3_label_and_merge.do"

*-------------------------------------------------------------------------
* 7. R
*    Stata cannot read a shell exit code portably, so this prints R's own
*    output for you to read rather than trying to judge it.
*-------------------------------------------------------------------------
display _n "[7] R -- output below comes straight from R"
display     "    If NOTHING appears, Rscript could not be launched: set"
display     "    {bf:global Rscript} in _paths.do to the full path of Rscript."
display     "    ----------------------------------------------------------------"
shell "$Rscript" -e "cat(R.version.string, '\n'); p <- c('haven','readxl','fixest','xtable','docstring','dplyr','data.table'); m <- p[!sapply(p, requireNamespace, quietly=TRUE)]; if (length(m)) cat('MISSING R PACKAGES:', paste(m, collapse=', '), '\n') else cat('All 7 required R packages present\n')"
display     "    ----------------------------------------------------------------"

*-------------------------------------------------------------------------
* Summary
*-------------------------------------------------------------------------
display _n "{hline 72}"
if ${chk_nfail} == 0 & ${chk_nwarn} == 0 {
	display "  ALL STATA-SIDE CHECKS PASSED. Confirm the R block above, then run:"
	display "      do 1_build_task_scores.do    (optional -- see README)"
	display "      do 2_build_data.do"
	display "      do 3_run_analysis.do"
}
else if ${chk_nfail} == 0 {
	display "  PASSED with ${chk_nwarn} warning(s). Read them before the multi-day analysis run."
}
else {
	display as error "  ${chk_nfail} failure(s), ${chk_nwarn} warning(s). Fix the failures first."
}
display "{hline 72}"

capture program drop _ckfile
capture program drop _ckdir

clear all

*=========================================================================
* 2_build_data.do -- build the analysis datasets from the raw microdata
*
* Run this ONCE. It performs all three build steps in order, including the
* R panel construction, which it launches for you. Expect roughly a couple of
* hours; the multi-day stage of this package is 3_run_analysis.do, not this.
*
*   Step 1  build_1_rename_raw_files.do  rename the raw QdP files (Stata)
*   Step 2  makepanel.R                  build the three panel datasets (R)
*   Step 3  build_3_label_and_merge.do   label panels, build VA/TFP (Stata)
*
* Datasets produced (consumed by 3_run_analysis.do):
*   data/clean/panel/2010-2019-regression.dta            (min firm size 10 -- main sample)
*   data/clean/panel/2010-2019-regression-5ormore.dta    (min firm size 5)
*   data/clean/panel/allfirms/2010-2019-regression-allfirms.dta  (all firms)
*   data/clean/intermediate/va_tfp_data/tfp_va_data.dta  (tfp_cd_wb, lva, valueadded_mp)
*   data/raw/QdP-renamed/workers_renamed_occlabel{2010..2019}.dta
*
* Requires data/raw/scores_isco4dig.dta (Step 3). It ships with the package;
* 1_build_task_scores.do rebuilds it from the O*NET release.
*=========================================================================

* Locate the shared configuration. Run this file from the package's code/ folder.
capture confirm file "_paths.do"
if _rc {
	display as error "Run this do-file from the package's {bf:code/} folder, e.g."
	display as error `"    cd "<path>/replication-package/code" "'
	exit 601
}
include "_paths.do"

*-------------------------------------------------------------------------
* Step switches -- all 1, so a plain run does the whole build.
* Set one to 0 only to SKIP work you have already completed, e.g. when
* restarting after a failure part-way through. Leaving them all at 1 always
* produces a complete, correct build.
*-------------------------------------------------------------------------
global do_step1_rename  1
global do_step2_panel   1
global do_step3_label   1

cap log close
log using $path_out_log/2_build_data, replace

*=========================================================================
* Step 1: rename the raw QdP worker and firm files
*=========================================================================
if $do_step1_rename == 1 {
	display _n(2) "{hline 70}"
	display "  STEP 1 of 3: renaming raw QdP files"
	display "{hline 70}"
	do "$path_do_sub/build_1_rename_raw_files.do"
}
else display _n "STEP 1 of 3 skipped (do_step1_rename = 0)."

*=========================================================================
* Step 2: build the panel datasets in R
*
* makepanel.R is launched via Rscript and receives $projectfolder as its
* only argument, so the path never has to be set in two places.
*=========================================================================
if $do_step2_panel == 1 {
	display _n(2) "{hline 70}"
	display "  STEP 2 of 3: building panel datasets in R (the slowest step here)"
	display "{hline 70}"

	shell "$Rscript" "$path_do_sub/makepanel.R" "$projectfolder"

	* Rscript's exit status is not reported reliably across platforms, so
	* confirm the three panels R is responsible for actually exist.
	local missing 0
	foreach f in "$path_clean_panel/2010-2019-regression.dta"              ///
	             "$path_clean_panel/2010-2019-regression-5ormore.dta"      ///
	             "$path_clean_panel/allfirms/2010-2019-regression-allfirms.dta" {
		capture confirm file "`f'"
		if _rc {
			display as error "Missing after the R step: `f'"
			local missing 1
		}
	}
	if `missing' {
		display as error _n "{hline 70}"
		display as error "The R step did not produce its output. Scroll up for R's"
		display as error "own error message. Common causes:"
		display as error "  - Rscript not found. Check {bf:global Rscript} in _paths.do;"
		display as error "    on Windows this usually needs the full path to Rscript.exe."
		display as error "  - A required R package is missing. makepanel.R lists them."
		display as error _n "To run the R step by hand instead:"
		display as error `"    Rscript "$path_do_sub/makepanel.R" "$projectfolder""'
		display as error "then re-run this file with {bf:global do_step2_panel 0}."
		display as error "{hline 70}"
		exit 601
	}
	display _n "R step complete: all three panel datasets present."
}
else display _n "STEP 2 of 3 skipped (do_step2_panel = 0)."

*=========================================================================
* Step 3: label the panels and build the VA/TFP dataset
*=========================================================================
if $do_step3_label == 1 {
	display _n(2) "{hline 70}"
	display "  STEP 3 of 3: labelling panels, building VA/TFP data"
	display "{hline 70}"
	do "$path_do_sub/build_3_label_and_merge.do"
}
else display _n "STEP 3 of 3 skipped (do_step3_label = 0)."

display _n(2) "Data build complete. Next: do 3_run_analysis.do"

cap log close

*=========================================================================
* _paths.do -- shared configuration, included by every numbered master file
* except 0_install_packages.do, which needs no paths.
*
* REPLICATORS: set `projectfolder' below to the folder that contains this
* replication package (the folder holding `code/' and `data/'). This is the
* ONLY line you need to change to run the package.
*=========================================================================

* IMPORTANT: put the path ALONE on the line below. `global' takes the whole
* rest of the line as the value, and `*' does not start a comment in the
* middle of a command -- so anything you add after the closing quote becomes
* part of the path.
global projectfolder "/CHANGE/ME/path/to/replication-package"

* Guard 1: the placeholder has not been replaced.
* Compound quotes `"..."' are used so a stray quote in the value still gives a
* readable message instead of a "type mismatch" error.
if strpos(`"$projectfolder"', "CHANGE/ME") > 0 {
	display as error "Set {bf:global projectfolder} in code/_paths.do before running."
	exit 601
}

* Guard 2: the folder must actually exist. This catches typos, and catches a
* trailing comment having been swallowed into the value.
mata: st_local("pf_ok", strofreal(direxists(st_global("projectfolder"))))
if `pf_ok' == 0 {
	display as error `"projectfolder does not point to an existing folder:"'
	display as error `"    $projectfolder"'
	display as error "Check code/_paths.do. The path must be alone on the line,"
	display as error "with nothing after the closing quote."
	exit 601
}

* Command Stata uses to launch R for the panel-construction step in
* 2_build_data.do. "Rscript" works if R is on your PATH. If it is not --
* common on Windows -- put the full path here, e.g.
*   global Rscript "C:/Program Files/R/R-4.4.1/bin/Rscript.exe"
global Rscript "Rscript"

* Variable used to cluster standard errors throughout the analysis (firm id).
global clustervar fnumber

*-------------------------------------------------------------------------
* Directory structure (all paths derive from $projectfolder)
*-------------------------------------------------------------------------
global path_raw 		"$projectfolder/data/raw"
global path_raw_INE		"$projectfolder/data/raw/INE"
global path_raw_QdP		"$projectfolder/data/raw/QdP"
global path_raw_QdPren	"$projectfolder/data/raw/QdP-renamed"
global path_raw_SCIE	"$projectfolder/data/raw/SCIE"
global path_raw_onet	"$projectfolder/data/raw/onet"
global path_clean 		"$projectfolder/data/clean"
global path_clean_panel "$projectfolder/data/clean/panel"
global path_clean_int 	"$projectfolder/data/clean/intermediate"
global path_clean_onet	"$projectfolder/data/clean/onet"
global path_out_fig 	"$projectfolder/data/out/fig"
global path_out_log 	"$projectfolder/data/out/log"
global path_out_tab 	"$projectfolder/data/out/tab"
global path_temp	 	"$projectfolder/data/tmp"
global path_do 			"$projectfolder/code"
global path_do_sub 		"$projectfolder/code/subfiles"

*-------------------------------------------------------------------------
* Create every output directory up front.
* Stata's save/graph export/esttab do NOT create directories themselves --
* a missing folder means the output is silently skipped.
*-------------------------------------------------------------------------
cap mkdir "$projectfolder/data"
cap mkdir "$path_raw"
cap mkdir "$path_raw_QdPren"
cap mkdir "$path_clean"
cap mkdir "$path_clean_panel"
cap mkdir "$path_clean_panel/allfirms"
cap mkdir "$path_raw_onet"
cap mkdir "$path_clean_int"
cap mkdir "$path_clean_onet"
cap mkdir "$path_clean_int/va_tfp_data"
cap mkdir "$projectfolder/data/out"
cap mkdir "$path_out_fig"
cap mkdir "$path_out_log"
cap mkdir "$path_out_log/ind_composition"
cap mkdir "$path_out_tab"
cap mkdir "$path_temp"

*-------------------------------------------------------------------------
* Program setup
*-------------------------------------------------------------------------
set more off
version 17.0
* The figures require the cleanplots scheme (and Figure 1 uses plotplain).
* Check it up front: without this, the run dies on a cryptic scheme error, or
* worse, silently draws the figures in the wrong scheme.
capture findfile scheme-cleanplots.scheme
if _rc {
	display as error "The {bf:cleanplots} graph scheme is not installed."
	display as error "Run {bf:0_install_packages.do} first -- it installs cleanplots from"
	display as error "https://tdmize.github.io/data/cleanplots"
	exit 601
}
set scheme cleanplots
set logtype text

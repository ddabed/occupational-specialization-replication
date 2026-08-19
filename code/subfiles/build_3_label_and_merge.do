*=========================================================================
* build_3_label_and_merge.do -- Phase 3 of the data build
*
* Labels the three panel datasets written by makepanel.R, builds the
* normalized HHI and task-concentration measures, and cleans and merges the
* SCIE balance-sheet data into the value-added / TFP dataset.
*
*   in : $path_clean_panel/  the three panels from makepanel.R
*        $path_raw_SCIE/     yearly balance-sheet files
*        $path_raw/scores_isco4dig.dta
*   out: labelled panels, $path_clean_int/va_tfp_data/tfp_va_data.dta
*
* Called by 2_build_data.do. Do not run directly -- it relies on the globals
* that 2_build_data.do sets up via _paths.do.
*=========================================================================

*-------------------------------------------------------------------------
* Step 3: Compress saved panel datasets, generate normalized HHI, generate normalized task concentration measure, and add labels
*         Covers all three datasets produced by makepanel.R:
*           - 2010-2019-regression.dta        (min_size = 10)
*           - 2010-2019-regression-5ormore.dta (min_size = 5)
*           - allfirms/2010-2019-regression-allfirms.dta (all firms)
*-------------------------------------------------------------------------

capture program drop label_regression_dataset
program define label_regression_dataset

	**Standardized HHI
	bysort year: egen std_HHI_3dig = std(HHI_3dig)
		label var std_HHI_3dig "Std. HHI"
	bysort year: egen std_HHI_1dig = std(HHI_1dig)
		label var std_HHI_1dig "Std. HHI"

	**Normalized HHI
	gen nHHI_3dig = (HHI_3dig - (1/sizeFirm)) / (1 - (1/sizeFirm))
		label var nHHI_3dig "HHI 3-digit"
	gen nHHI_1dig = (HHI_1dig - (1/sizeFirm)) / (1 - (1/sizeFirm))
		label var nHHI_1dig "Normalized HHI 1-dig."
	gen nHHI_4dig = (HHI_4dig - (1/sizeFirm)) / (1 - (1/sizeFirm))
		label var nHHI_4dig "Normalized HHI 4-dig."

	** Industry
	encode fEAC_34dig_rev3, gen(industry)
	label var industry "Industry 4-dig."

	** Log monthly wages and hours worked
	gen lreal_wage = ln(real_wage)
	label var lreal_wage "Log real monthly wage"

	gen lreg_hours_month = ln(reg_hours_month)

	** Log real hourly wage and log employment
	** (created by makepanel.R; cap gen is a safe fallback)
	cap gen ltotal_realhrem = ln(total_realhrem)
	cap gen lfsize = ln(sizeFirm)

	** Labeling
	label var HHIw_1dig 		"Hr. weighted HHI 1-dig."
	label var HHIw_3dig 		"Hr. weighted HHI 3-digit"
	label var HHI_1dig 			"HHI 1-dig."
	label var HHI_3dig 			"HHI 3-digit"
	label var HHI_4dig 			"HHI 4-dig."
	label var share_1dig     	"Share of 1-digit occ."
	label var share_3dig     	"Share of 3-digit occ."
	label var share_1dig_max 	"Main occ. share 1-dig"
	label var share_3dig_max 	"Main occ. share 3-dig"

	label var real_hrl_wage 	"Real hourly base wage + reg. payments"
	label var real_wage 		"Real base wage + reg. payments"
	label var lreal_hrl_wage 	"ln(w)"
	label var total_realhrem 	"Real hourly wage (euros)"
	label var ltotal_realhrem	"Log real hourly wage"

	label var lfsize 			"Log firm employment"
	label var share_1dig_max 	"Share of largest 1-dig. occ."
	label var share_3dig_max 	"Share of largest 3-digit occ."

	label var share_college 	"Share of college workers"
	label var age 				"Age (years)"
	label var female 			"Female"
	label var native 			"Native"
	label var young 			"Young workers"
	label var full_time 		"Full time workers"
	label var tenure 			"Tenure at firm (years)"

	label def educ_l1 1 "Less than high-school" 2 "High-school" 3 "College degree"
	label values educ educ_l1

	label var occup1_10       "1-digit occupation"
	label var occup3_10       "3-digit occupation"
	label var fEAC_34dig_rev3 "4-digit industry"

	**Destring 1d occupation
	destring occup1_10, replace
	label define occup1_10_l ///
		1 "Managers" ///
		2 "Professionals" ///
		3 "Technicians and associate prof." ///
		4 "Clerical workers" ///
		5 "Service and sales workers" ///
		7 "Craft and related trade workers" ///
		8 "Plant and machine operators" ///
		9 "Elementary occupations", replace
	label values occup1_10 occup1_10_l
	label var occup1_10 "1-Dig. ISCO"
	label var occup3_10 "3-Dig. ISCO"
	
	
	**Normalized Task Concentration measure
	
	merge m:1 occup4_10 using $path_raw/scores_isco4dig
		drop if _m == 2

	preserve
			tempfile taskdiv
			gcollapse (sd) socskills routine cognitive manual, by(fnumber year) fast
			
			//Average sd's
			egen taskdiv = rowmean(socskills routine cognitive manual)
			label var taskdiv "Task diversity measure"
			save `taskdiv', replace
	restore

	merge m:1 fnumber year using `taskdiv', keepusing(taskdiv) nogen
		
	sum taskdiv, meanonly 
	gen ntaskdiv= (taskdiv - r(min)) / (r(max) - r(min)) 
		label var ntaskdiv "Normalized Task Diversity"
	gen ntaskcon = 1 - ntaskdiv 
		label var ntaskcon "Normalized Task Concentration"
	

	
	compress

end

*--- Main dataset (min_size = 10) ---
use "$path_clean_panel/2010-2019-regression.dta", clear
label_regression_dataset
save "$path_clean_panel/2010-2019-regression.dta", replace

*--- 5-or-more dataset (min_size = 5) ---
use "$path_clean_panel/2010-2019-regression-5ormore.dta", clear
label_regression_dataset
save "$path_clean_panel/2010-2019-regression-5ormore.dta", replace

*--- All-firms dataset (min_size = 1) ---
use "$path_clean_panel/allfirms/2010-2019-regression-allfirms.dta", clear
label_regression_dataset
save "$path_clean_panel/allfirms/2010-2019-regression-allfirms.dta", replace




*-------------------------------------------------------------------------
* Step 4: Cleans and merges yearly balance sheet datasets (SCIE)
*         Estimates TFP using balance sheet variables
*		  Creates intermediate panel with year, firm id, va and estimated TFP
*-------------------------------------------------------------------------

	** Make sure the output folder exists (save does not create directories)
	cap mkdir "$path_clean_int/va_tfp_data"

	** Rename variables from SCIE database and deflates relevant variables
	foreach y in  2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 {

		use $path_raw_SCIE/SCIE`y', clear

			destring ano, g(year)
				drop ano 

			rename sv500801 labor_costs_total
			rename sd000014 valueadded_mp
			rename sd000015 va_fc
			rename sv601201 employees
			rename sv502501 netincome 
			rename sv500101 revenue 
			rename sd000002 sales
			rename sd000034 investment
			rename sd000012 intermediates
			
			// Proxying capital
			rename sv510101 tangible_fixed_assets
			rename sv510201 investmen_properties
			rename sv510401 intangible_assets
			rename sv511201 total_noncurrent_assets
			rename sv512601 total_current_asset
			rename sv512701 total_net_assets
			rename sv516101 total_liab_equity

			rename sd000005 fixed_assets //derived variable (tangibles and non intagibles)
				
			// Drop entrepreneurs
			drop if cae == "19_205"
			drop if efjr0=="eni" // entrepreneur/single person "company"

			gen nace_2d=substr(cae_cod, 1,2)
				order nace_2d, a(cae_cod)
				label var nace_2d "Industry 2digits"

			gen nace_4d=substr(cae_cod, 1,4)
				order nace_4d, a(cae_cod)
				label var nace_4d "Industry 4digits"

			// Drop agriculture firms (NACE 01-03) now that nace_2d exists
			drop if nace_2d == "01" | nace_2d == "02" | nace_2d == "03"
			
				
		if year < 2018{	
			keep year npc_fic nace_4d nace_2d i_nasc i_mort employees revenue sales labor_costs_total netincome tangible_fixed_assets investmen_properties intangible_assets total_noncurrent_assets total_current_asset total_net_assets total_liab_equity valueadded_mp va_fc fixed_assets investment  intermediates
		} 

		if year >= 2018{	
			keep year npc_fic nace_4d nace_2d i_nasc employees revenue sales labor_costs_total netincome tangible_fixed_assets investmen_properties intangible_assets total_noncurrent_assets total_current_asset total_net_assets total_liab_equity valueadded_mp va_fc fixed_assets investment  intermediates
		} 


		//Deflate nominal values
		merge m:1 year using $path_raw_INE/priceindex, keep(matched)
			drop _m
			
		foreach var in revenue sales labor_costs_total netincome tangible_fixed_assets investmen_properties intangible_assets total_noncurrent_assets total_current_asset total_net_assets total_liab_equity valueadded_mp va_fc fixed_assets investment intermediates{
			
			gen r_`var' = `var' / (priceindex/100)
			gen lr_`var' = ln(r_`var')
				order r_`var', a(`var')
				order lr_`var', a(r_`var')
		}

		rename npc fnumber_FIC 

		save $path_clean_int/va_tfp_data/selectedvar_SCIE_`y', replace

		}


	** Append yearly files
		use $path_clean_int/va_tfp_data/selectedvar_SCIE_2010, clear

			foreach y in 2011 2012 2013 2014 2015 2016 2017 2018 2019{
				append using $path_clean_int/va_tfp_data/selectedvar_SCIE_`y'
			}

		save $path_clean_int/va_tfp_data/SCIE_2010_2019, replace


	** Estimate Total Factor Productivity using Cobb-Douglas and wage bill as labor input
		cap drop residuals
		cap drop l_employees
		gen l_employees = ln(employees) if employees > 0 & !missing(employees)


		clonevar lva  = lr_valueadded_mp
		clonevar lemp = l_employees
		clonevar lka  = lr_fixed_assets
		clonevar lint = lr_intermediates
		clonevar lwb  = lr_labor_costs_total

		xtset fnumber_FIC year

		prodest lva, free(lwb) state(lka) ///
			proxy(lint) va met(wrdg) poly(2) ///
			id(fnumber_FIC) t(year)
		predict tfp_cd_wb
		quietly count if !missing(tfp_cd_wb)
		display "  non-missing tfp_cd_wb: " %12.0fc r(N)

		** Collapse to firm level: keep only the variables the analysis needs
		** (tfp_cd_wb, lva, valueadded_mp merged in by the AKM and summary-stats do-files)
		gcollapse (mean) tfp_cd_wb lva valueadded_mp, by(fnumber_FIC) fast

	* Save panel with firm id and productivity measures
	save $path_clean_int/va_tfp_data/tfp_va_data, replace

clear all

*=========================================================================
* 1_build_data.do -- build the analysis datasets from the raw microdata
*
* RUN ORDER (three phases; the R step runs outside Stata):
*   Phase 1: set runpart1 1, runpart3 0 -> run this file
*            (renames the raw QdP worker & firm files into English)
*   Phase 2: run code/subfiles/makepanel.R in R
*            (builds the 3 panel datasets + the ind_composition logs)
*   Phase 3: set runpart1 0, runpart3 1 -> run this file again
*            (labels the 3 panels and builds va_tfp_data/tfp_va_data)
*
* Datasets produced (consumed by 2_run_analysis.do):
*   data/clean/panel/2010-2019-regression.dta            (min firm size 10 -- main sample)
*   data/clean/panel/2010-2019-regression-5ormore.dta    (min firm size 5)
*   data/clean/panel/allfirms/2010-2019-regression-allfirms.dta  (all firms)
*   data/clean/intermediate/va_tfp_data/tfp_va_data.dta  (tfp_cd_wb, lva, valueadded_mp)
*   data/raw/QdP-renamed/workers_renamed_occlabel{2010..2019}.dta
*=========================================================================

* Locate the shared configuration. Run this file from the package's code/ folder.
capture confirm file "_paths.do"
if _rc {
	display as error "Run this do-file from the package's {bf:code/} folder, e.g."
	display as error `"    cd "<path>/replication-package/code" "'
	exit 601
}
include "_paths.do"


global runpart1 0
global runpart3 1

if $runpart1==1 {

cap log close
log using $path_out_log/1_build_data, replace


*-------------------------------------------------------------------------
* Step 1: Clean raw datasets: convert from spss to stata, rename variables in English
*-------------------------------------------------------------------------

*****************************************************************************
** Rename workers files 2010-2019
*****************************************************************************

forvalues y = 2010/2019 {


if `y' <= 2016 {

	import spss using "$path_raw_QdP/QP_Trabalhadores_`y'_Fins_Cientificos_21-05-2018.sav" , clear

}

if `y' == 2017 {

	import spss using "$path_raw_QdP/QP_Trabalhadores_`y'_Fins_Cientificos_07-02-2019", clear
}


if `y' == 2018 {

	import spss using "$path_raw_QdP/QP_Trabalhadores_`y'_Fins_Cientificos_08-07-2020", clear
}

if `y' == 2019 {

	import spss using "$path_raw_QdP/QP_Trabalhadores_`y'_Fins_Cientificos_21-06-2021", clear
}

		// Translate variable names from Portuguese to English
		rename ANO year
		rename NPC_FIC fnumber_FIC
		rename NUEMP fnumber
		rename EMP_ID f_ID
		rename NUEST enumber
		rename ESTAB_ID e_ID
		cap rename irct colect_contrat
		rename ntrab w_numer
		rename sexo gender
		rename nacio nationality
		rename prof_4d occup4_10
		rename prof_3d occup3_10
		rename prof_2d occup2_10
		rename prof_1d occup1_10
		rename ctpro occup_categ
		rename sitpro employ_status
		rename nqual1 qualif_level1dig
		rename habil school
		rename habil2 school_2dig
		rename habil1 school_1dig
		rename idade_Cod age
		rename antig tenure
		cap rename dt_adm hiring_date
		cap rename dt_prom promotion_date
		rename ctrem worktime_rem
		rename rbase basic_rem
		rename prest_reg reg_pay
		rename prest_irreg irreg_pay
		rename rextra extra_rem
		rename rganho total_rem
		rename hnormais reg_hours_month
		rename hextra extra_hours_month
		rename pnt reg_hours_week
		rename tipo_contr type_contract
		rename tipo_contr1 type_contract_1
		rename esc_rem_base basic_rem_class
		rename esc_rem_ganho total_rem_class

	// Label 3-dig occupations (ESCO classification)


		destring occup3_10, replace force


		label def occup3_10_1 111 "Legislators and senior officials" /*
		*/112 "Managing directors and chief executives" 121 "Business services and administration managers"/*
		*/ 122 "Sales, marketing and development managers" 131 "Production managers in agriculture, forestry and fisheries"/*
		*/ 132 "Manufacturing, mining, construction, and distribution managers" 133 "Information and communications technology service managers"/*
		*/ 134 "Professional services managers" 141 "Hotel and restaurant managers" 142 "Retail and wholesale trade managers"/*
		*/ 143 "Other services managers" 211 "Physical and Earth Science Professionals" 212 "Mathematicians, Actuaries and Statisticians"/*
		*/ 213 "Life Science Professionals" 214 "Engineering Professionals (exc. Electrotechnology)" 215 "Electrotechnology Engineers"/*
		*/ 216 "Architects, Planners, Surveyors and Designers" 221 "Medical Doctors" 222 "Nursing and Midwifery Professionals" /*
		*/ 223 "Traditional and Complementary Medicine Professionals" 224 "Paramedical Practitioners" 225 "Veterinarians"/*
		*/ 226 "Other Health Professionals" 231 " University and Higher Education Teachers" 232 "Vocational Education Teachers" /*
		*/ 233 "Secondary Education Teachers" 234 "Primary School and Early Childhood Teachers" 235 "Other Teaching Professionals" /*
		*/ 241 "Finance Professionals" 242 "Administration Professionals" 243 "Sales, Marketing and Public Relations Professionals" /*
		*/ 251 "Software and Applications Developers and Analysts" 252 "Database and Network Professionals" /*
		*/ 261 "Legal Professionals" 262 "Librarians, Archivists and Curators" 263 "Social and Religious Professionals" /*
		*/ 264 "Authors, Journalists and Linguists" 265 "Creative and Performing Artists" 311 "Physical and Engineering Science Technicians" /*
		*/ 312 "Mining, Manufacturing and Construction Supervisors" 313 "Process Control Technicians" 314 "Life Science Technicians and Related Associate Professionals"/*
		*/ 315 "Ship and Aircraft Controllers and Technicians" 321 "Medical and Pharmaceutical Technicians" 322 "Nursing and Midwifery Associate Professionals" /*
		*/ 323 "Traditional and Complementary Medicine Associate Professionals" 324 "Veterinary Technicians and Assistants" /*
		*/ 325 "Other Health Associate Professionals" 331 "Financial and Mathematical Associate Professionals" 332 "Sales and Purchasing Agents and Brokers" /*
		*/ 333 "Business Services Agents" 334 "Administrative and Specialized Secretaries" 335 "Regulatory Government Associate Professionals"/*
		*/ 341 "Legal, Social and Religious Associate Professionals" 342 "Sports and Fitness Workers" 343 "Artistic, Cultural and Culinary Associate Professionals" /*
		*/ 351 "Information and Communications Technology Operations and User Support Technicians" 352 "Telecommunications and Broadcasting Technicians" /*
		*/ 411 "General Office Clerks" 412 "Secretaries (general)" 413 "Keyboard Operators" 421 "Tellers, Money Collectors and Related Clerks" /*
		*/ 422 "Client Information Workers" 431 "Numerical Clerks" 432 "Material Recording and Transport Clerks" 441 "Other Clerical Support Workers" /*
		*/ 511 "Travel Attendants, Conductors and Guides" 512 "Cooks" 513 "Waiters and Bartenders" 514 "Hairdressers, Beauticians and Related Workers" /*
		*/ 515 "Building and Housekeeping Supervisors" 516 "Other Personal Services Workers" 521 "Street and Market Salespersons" 522 "Shop Salespersons"/*
		*/ 523 "Cashiers and Ticket Clerks" 524 "Other Sales Workers" 531 " Child Care Workers and Teachers' Aides" 532 "Personal Care Workers in Health Services"/*
		*/ 541 "Protective Services Workers" 611 "Market Gardeners and Crop growers" 612 "Animal Producers" 613 "Mixed Crop and Animal Producers" /*
		*/ 621 "Forestry and Related Workers" 622 "Fishery Workers, Hunters and Trappers" 631 "Subsistence Crop Farmers" 632 "Subsistence Livestock Farmers" /*
		*/ 633 "Subsistence Mixed Crop and Livestock Farmers" 634 "Subsistence fishers, huntersm trappers and gatherers" /*
		*/ 711 "Building Frame and Related Trades Workers" 712 "Building Finishers and Related Trades Workers"/*
		*/ 713 "Painters, Building Structure Cleaners and Related Trades Workers" 721 "Sheet and Structural Metal Workers, Moulders and Welders, and Related Workers"/*
		*/ 722 "Blacksmiths, Toolmakers and Related Trades Workers" 723 "Machinery Mechanics and Repairers" 731 "Handicraft Workers" 732 "Printing Trades Workers" /*
		*/ 741 "Electrical Equipment Installers and Repairers" 742 "Electronics and Telecommunications Installers and Repairers" 751 "Food Processing and Related Trades Workers"/*
		*/ 752 "Wood Treaters, Cabinet-makers and Related Trades Workers" 753 "Garment and Related Trades Workers" 754 "Other Craft and Related Workers" /*
		*/ 811 "Mining and Mineral Processing Plant Operators" 812 "Metal Processing and Finishing Plant Operators" 813 "Chemical and Photographic Products Plant and Machine Operators" /*
		*/ 814 "Rubber, Plastic and Paper Products Machine Operators" 815 "Textile, Fur and Leather Products Machine Operators" 816 "Food and Related Products Machine Operators"/*
		*/ 817 "Wood Processing and Papermaking Plant Operators" 818 "Other Stationary Plant and Machine Operators" 821 "Assemblers"/*
		*/ 831 "Locomotive Engine Drivers and Related Workers" 832 "Car, Van and Motorcycle Drivers" 833 "Heavy Truck and Bus Drivers" 834 "Mobile Plant Operators"/*
		*/ 835 "Ships' Deck Crews and Related Workers" 911 "Domestic, Hotel and Office Cleaners and Helpers" 912 "Vehicle, Window, Laundry and Other Hand Cleaning Workers"/*
		*/ 921 "Agricultural, Forestry and Fishery Labourers" 931 "Mining and Construction Labourers" 932 "Manufacturing Labourers" 933 "Transport and Storage Labourers"/*
		*/ 941 "Food Preparation Assistants" 951 "Street and Related Services Workers" 952 "Street Vendors (excluding Food)" 961 "Refuse Workers" 962 "Other Elementary Workers"


		label values occup3_10 occup3_10_1

		compress

save "$path_raw_QdPren/workers_renamed_occlabel`y'", replace

}


*****************************************************************************
** Rename firms files 2010-2019
*****************************************************************************

forvalues y = 2010/2019 {


if `y' <= 2015 {

	import spss using "$path_raw_QdP/Empresas_`y'_Fins_Cientificos_25-05-2017.sav" , clear

}

if `y' == 2016 {

	import spss using "$path_raw_QdP/Empresas_`y'_Fins_Cientificos_13-04-2018", clear
}

if `y' == 2017 {

	import spss using "$path_raw_QdP/QP_Empresas_`y'_Fins_Cientificos_07-02-2019", clear
}

if `y' == 2018 {

	import spss using "$path_raw_QdP/QP_Empresas_`y'_Fins_Cientificos_30-06-2020", clear
}

if `y' == 2019 {

	import spss using "$path_raw_QdP/QP_Empresas_`y'_Fins_Cientificos_18-06-2021", clear
}

	// Translate variable names from Portuguese to English
		rename ANO year
		rename NPC_FIC fnumber_FIC
		rename NUEMP fnumber
		rename EMP_ID f_ID
		rename nut1_emp fNUTS1
		rename nut2_emp fNUTS2
		rename natju flegalnature
		rename csoc fcapital_total
		rename cspri fcapital_nac
		rename cspub fcapital_pub
		rename csest fcapital_fore
		rename nest festablish_number
		rename pemp fpersonnel
		rename pempl fpersonnel_oct
		rename CAE2 fEAC_2dig_rev3
		rename caem1 fEAC_1let_rev3
		rename CAE4_COD fEAC_34dig_rev3
		cap rename ancon fbirth_year
		rename antiguidade fseniority
		rename esc_antig_emp fseniority_class
		rename vn fsales
		rename vndesc1 fsales_class
		rename vndesc2 fturnover_class
		rename vn_ano fsales_refyear
		rename csocesc fcapital_class
		rename escdim1 fsize_class
		rename escdim2 fsize_class_des
		rename escdim_linhas1 fsize_class_oct
		rename tcoemp femployees_oct
		cap rename ANO_CONSTITUICAO fbirth_year

		compress

save "$path_raw_QdPren/firms_renamed`y'", replace
}


log close

}

*	--- STOP, RUN R ---


*-------------------------------------------------------------------------
* Step 2: Clean raw datasets -- make panel dataset used for all subsequent analyses
*-------------------------------------------------------------------------

// Note: for the R code to run, you must have a personal R library to install packages

*Rscript "$path_do_sub/makepanel.R"



*	--- RETURN TO STATA ---

if $runpart3==1 {
	cap log close
set logtype text
log using $path_out_log/1_build_data, append

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



log close

}

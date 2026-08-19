

*----------------------------------------------------------
* Rerun regression models 
*----------------------------------------------------------

use $path_clean_panel/2010-2019-regression.dta, clear

drop _m 

gen sales_per_worker = fsales/sizeFirm	
gen logsales = log(sales_per_worker)

/*
*0. Retain Main region
tempfile temp
save `temp'


		gcollapse (first) fNUTS2, by(year fnumber_FIC)

		bysort fnumber: egen nryears = count(year)
		bysort fnumber fNUTS2: egen nryears_reg = count(year)
		bysort fnumber: egen tag0 = max(nryears_reg)

		gen fNUTS2_main_aux = fNUTS2 if nryears_reg == tag0
		bysort fnumber: egen fNUTS2_main = max(fNUTS2_main_aux)

		label values fNUTS2_main fNUTS2
		
		collapse (first) fNUTS2_main, by(year fnumber_FIC)

	
merge 1:m fnumber_FIC year using `temp'
*/


*1. AKM regression
eststo AKM: reghdfe lreal_hrl_wage, absorb(firm_year_fe = fnumber_FIC age#educ w_numer year occup3_10 fNUTS2) cluster($clustervar)
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedfirm "X", replace
	quietly estadd local fixedageeduc "X", replace
	quietly estadd local fixedworker "X", replace
	quietly estadd local fixed3digocc "X", replace
	
gcollapse (mean) nHHI_1dig nHHI_3dig firm_year_fe sizeFirm lfsize logsales sales_per_worker (first) industry, by(fnumber_FIC) fast

gegen std_firm_akm = std(firm_year_fe)

label var nHHI_1dig "Norm. HHI 1-dig."
label var nHHI_3dig "Norm. HHI 3-digit"
label var lfsize "Log firm employment"
label var sales_per_worker "Sales per worker"
label var logsales "Log labor productivity"

compress
save $path_clean_int/AKM_full, replace


* Figures 4 and A1 (and their decompositions) are produced by AKM_firm_HHI_VA_TFP.do,
* which reads the AKM_full.dta saved above.

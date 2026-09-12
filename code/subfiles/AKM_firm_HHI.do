*----------------------------------------------------------
* AKM_firm_HHI.do -- estimates the AKM firm wage premia
*
* Fits a two-way fixed effects (AKM) wage regression on the full worker-year
* panel and collapses the estimated firm effects to the firm level, alongside
* the specialization measures, firm size and labour productivity.
*
* Produces no paper output directly. AKM_full.dta is the shared input to
* AKM_firm_HHI_VA_TFP.do (Figures 4 and A1) and to local-projections.do
* (Figures 5 and A2), so this file runs before either of them.
*   out: $path_clean_int/AKM_full.dta
*
* This is one of the two slow stages of 3_run_analysis.do.
*----------------------------------------------------------

eststo clear   // drop estimates stored by earlier do-files, so esttab cannot pick up a stale one

use $path_clean_panel/2010-2019-regression.dta, clear

drop _m 

gen sales_per_worker = fsales/sizeFirm	
gen logsales = log(sales_per_worker)


* Worker, firm, age x education, year, occupation and region effects are all
* absorbed; firm_year_fe saves the estimated firm component.
eststo AKM: reghdfe lreal_hrl_wage, absorb(firm_year_fe = fnumber_FIC age#educ w_numer year occup3_10 fNUTS2) cluster($clustervar)
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedfirm "X", replace
	quietly estadd local fixedageeduc "X", replace
	quietly estadd local fixedworker "X", replace
	quietly estadd local fixed3digocc "X", replace
	
* Collapse to one row per firm, carrying the firm effect and the covariates
* the downstream decompositions need.
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

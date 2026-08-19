

* Worker-level summary statistics - Combined table
* Three columns: (1) All firms, (2) Estimation sample (firm size filter),
* (3) Value-added sample (firms with non-missing value added)

*===============================================================================
* Column 1: All firms (before firm size filter)
*===============================================================================
use $path_clean_panel/allfirms/2010-2019-regression-allfirms.dta, clear

** education dummies
tabulate educ, gen(dum_educ)

label var dum_educ1 "No high school"
label var dum_educ2 "High school"
label var dum_educ3 "College"

** occupation dummies
tabulate occup1_10, gen(dum_occup1_10)

label var dum_occup1_101 "Managers"
label var dum_occup1_102 "Professionals"
label var dum_occup1_103 "Technicians"
label var dum_occup1_104 "Clerical"
label var dum_occup1_105 "Service and sales"
label var dum_occup1_106 "Craft and trade"
label var dum_occup1_107 "Plant operators"
label var dum_occup1_108 "Elementary occupations"

** non-permanent contract
gen nonperm_contract = type_contract_1 != 1
label var nonperm_contract "Non-permanent contract"

estpost summarize total_realhrem age dum_educ1 dum_educ2 dum_educ3 female native full_time nonperm_contract tenure dum_occup1_101 dum_occup1_102 dum_occup1_103 dum_occup1_104 dum_occup1_105 dum_occup1_106 dum_occup1_107 dum_occup1_108

gegen tag = tag(w_numer)
count if tag == 1 & !missing(w_numer)
local num_unique_all = r(N)
local num_unique_all_f = string(`num_unique_all', "%13.0fc")

gegen tag2 = tag(w_numer year)
count if tag2 == 1 & !missing(w_numer)
local num_obs_all = r(N)
local num_obs_all_f = string(`num_obs_all', "%13.0fc")

drop tag*

eststo summstats_allfirms

*===============================================================================
* Column 2: Filtered sample (with firm size filter)
*===============================================================================
use $path_clean_panel/2010-2019-regression.dta, clear

** education dummies
tabulate educ, gen(dum_educ)

label var dum_educ1 "No high school"
label var dum_educ2 "High school"
label var dum_educ3 "College"

** occupation dummies
tabulate occup1_10, gen(dum_occup1_10)

label var dum_occup1_101 "Managers"
label var dum_occup1_102 "Professionals"
label var dum_occup1_103 "Technicians"
label var dum_occup1_104 "Clerical"
label var dum_occup1_105 "Service and sales"
label var dum_occup1_106 "Craft and trade"
label var dum_occup1_107 "Plant operators"
label var dum_occup1_108 "Elementary occupations"

** non-permanent contract
gen nonperm_contract = type_contract_1 != 1
label var nonperm_contract "Non-permanent contract"

estpost summarize total_realhrem age dum_educ1 dum_educ2 dum_educ3 female native full_time nonperm_contract tenure dum_occup1_101 dum_occup1_102 dum_occup1_103 dum_occup1_104 dum_occup1_105 dum_occup1_106 dum_occup1_107 dum_occup1_108

gegen tag = tag(w_numer)
count if tag == 1 & !missing(w_numer)
local num_unique_filt = r(N)
local num_unique_filt_f = string(`num_unique_filt', "%13.0fc")

gegen tag2 = tag(w_numer year)
count if tag2 == 1 & !missing(w_numer)
local num_obs_filt = r(N)
local num_obs_filt_f = string(`num_obs_filt', "%13.0fc")

drop tag*

eststo summstats_filtered

*===============================================================================
* Column 3: Value added sample (firms with non-missing value added)
* Defined as in ind_composition_stages.do / AKM_firm_HHI_VA_TFP.do: start from
* the Estimation Sample and keep the worker-years whose firm has non-missing
* value added in tfp_va_data (merged m:1 on fnumber_FIC).
*===============================================================================
use $path_clean_panel/2010-2019-regression.dta, clear

merge m:1 fnumber_FIC using $path_clean_int/va_tfp_data/tfp_va_data, ///
	keepusing(valueadded_mp) keep(master match) nogenerate
drop if missing(valueadded_mp)

** education dummies
tabulate educ, gen(dum_educ)

label var dum_educ1 "No high school"
label var dum_educ2 "High school"
label var dum_educ3 "College"

** occupation dummies
tabulate occup1_10, gen(dum_occup1_10)

label var dum_occup1_101 "Managers"
label var dum_occup1_102 "Professionals"
label var dum_occup1_103 "Technicians"
label var dum_occup1_104 "Clerical"
label var dum_occup1_105 "Service and sales"
label var dum_occup1_106 "Craft and trade"
label var dum_occup1_107 "Plant operators"
label var dum_occup1_108 "Elementary occupations"

** non-permanent contract
gen nonperm_contract = type_contract_1 != 1
label var nonperm_contract "Non-permanent contract"

estpost summarize total_realhrem age dum_educ1 dum_educ2 dum_educ3 female native full_time nonperm_contract tenure dum_occup1_101 dum_occup1_102 dum_occup1_103 dum_occup1_104 dum_occup1_105 dum_occup1_106 dum_occup1_107 dum_occup1_108

gegen tag = tag(w_numer)
count if tag == 1 & !missing(w_numer)
local num_unique_va = r(N)
local num_unique_va_f = string(`num_unique_va', "%13.0fc")

gegen tag2 = tag(w_numer year)
count if tag2 == 1 & !missing(w_numer)
local num_obs_va = r(N)
local num_obs_va_f = string(`num_obs_va', "%13.0fc")

drop tag*

eststo summstats_vasample

*===============================================================================
* Combined table output
*===============================================================================
local tablabel "table_01_panel_a_summary_stats_workers"

preserve

	foreach v of varlist dum_edu* {
		label variable `v' `"- `: variable label `v''"'
	}

	foreach v of varlist dum_occup* {
		label variable `v' `"- `: variable label `v''"'
	}

	esttab summstats_allfirms summstats_filtered summstats_vasample using $path_out_tab/`tablabel'.tex, ///
		cells("mean(fmt(%6.2f))") replace ///
		prehead("\begin{tabular}{l*{3}{c}}" "\toprule" "& \multicolumn{3}{c}{Sample} \\" "\cmidrule(lr){2-4}") ///
		mtitles("All Firms" "Estimation" "Value added") ///
		posthead("& (1) & (2) & (3) \\" "\midrule") ///
		collabels(none) nonumber nostar label ///
		refcat(dum_educ1 "Education:" dum_occup1_101 "Occupation:", nolabel) ///
		booktabs wide noobs ///
		prefoot("\midrule Observations: & `num_obs_all_f' & `num_obs_filt_f' & `num_obs_va_f' \\") ///
		postfoot("Unique Individuals: & `num_unique_all_f' & `num_unique_filt_f' & `num_unique_va_f' \\ \bottomrule \end{tabular}") ///
		nonotes

restore

eststo clear

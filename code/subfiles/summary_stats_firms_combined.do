eststo clear   // drop estimates stored by earlier do-files, so esttab cannot pick up a stale one


* Firm-level summary statistics - Combined table
* Three columns: (1) All firms, (2) Estimation sample (firm size filter),
* (3) Value-added sample (firms with non-missing value added)

*===============================================================================
* Column 1: All firms (before firm size filter)
*===============================================================================
use $path_clean_panel/allfirms/2010-2019-regression-allfirms.dta, clear

* Collapse to firm-year level
gcollapse (first) sizeFirm fsales, by(fnumber_FIC year) fast

label var sizeFirm "Firm size"
label var fsales "Firm sales (euros)"

estpost summarize sizeFirm fsales

gegen tag = tag(fnumber_FIC)
count if tag == 1 & !missing(fnumber_FIC)
local num_unique_all = r(N)
local num_unique_all_f = string(`num_unique_all', "%13.0fc")

gegen tag2 = tag(fnumber_FIC year)
count if tag2 == 1 & !missing(fnumber_FIC)
local num_obs_all = r(N)
local num_obs_all_f = string(`num_obs_all', "%13.0fc")

drop tag*

eststo summstats_allfirms

*===============================================================================
* Column 2: Filtered sample (with firm size filter)
*===============================================================================
use $path_clean_panel/2010-2019-regression.dta, clear

* Collapse to firm-year level
gcollapse (first) sizeFirm fsales, by(fnumber_FIC year) fast

label var sizeFirm "Firm size"
label var fsales "Firm sales (euros)"

estpost summarize sizeFirm fsales

gegen tag = tag(fnumber_FIC)
count if tag == 1 & !missing(fnumber_FIC)
local num_unique_filt = r(N)
local num_unique_filt_f = string(`num_unique_filt', "%13.0fc")

gegen tag2 = tag(fnumber_FIC year)
count if tag2 == 1 & !missing(fnumber_FIC)
local num_obs_filt = r(N)
local num_obs_filt_f = string(`num_obs_filt', "%13.0fc")

drop tag*

eststo summstats_filtered



*===============================================================================
* Column 3: Value added sample (firms with non-missing value added)
* Defined as in ind_composition_stages.do / AKM_firm_HHI_VA_TFP.do: start from
* the Estimation Sample and keep the firm-years whose firm has non-missing
* value added in tfp_va_data (merged m:1 on fnumber_FIC).
*===============================================================================
use $path_clean_panel/2010-2019-regression.dta, clear

* Collapse to firm-year level
gcollapse (first) sizeFirm fsales, by(fnumber_FIC year) fast

merge m:1 fnumber_FIC using $path_clean_int/va_tfp_data/tfp_va_data, ///
	keepusing(valueadded_mp) keep(master match) nogenerate
drop if missing(valueadded_mp)

label var sizeFirm "Firm size"
label var fsales "Firm sales (euros)"

estpost summarize sizeFirm fsales

gegen tag = tag(fnumber_FIC)
count if tag == 1 & !missing(fnumber_FIC)
local num_unique_va = r(N)
local num_unique_va_f = string(`num_unique_va', "%13.0fc")

gegen tag2 = tag(fnumber_FIC year)
count if tag2 == 1 & !missing(fnumber_FIC)
local num_obs_va = r(N)
local num_obs_va_f = string(`num_obs_va', "%13.0fc")

drop tag*

eststo summstats_vasample


*===============================================================================
* Combined table output
*===============================================================================
local tablabel "table_01_panel_b_summary_stats_firms"

esttab summstats_allfirms summstats_filtered summstats_vasample using $path_out_tab/`tablabel'.tex, ///
	cells("mean(fmt(%13.0fc))") replace ///
	prehead("\begin{tabular}{l*{3}{c}}" "\toprule" "& \multicolumn{3}{c}{Sample} \\" "\cmidrule(lr){2-4}") ///
	mtitles("All Firms" "Estimation" "Value added") ///
	posthead("& (1) & (2) & (3) \\" "\midrule") ///
	collabels(none) nonumber nostar label ///
	booktabs noobs ///
	prefoot("\midrule Observations: & `num_obs_all_f' & `num_obs_filt_f' & `num_obs_va_f' \\") ///
	postfoot("Unique Firms: & `num_unique_all_f' & `num_unique_filt_f' & `num_unique_va_f' \\ \bottomrule \end{tabular}") ///
	nonotes

eststo clear

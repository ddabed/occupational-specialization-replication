* Named log, so it coexists with the master log that 3_run_analysis.do opens.
* Do NOT use a plain `log close' here, that closes the MASTER log and leaves
* everything after Table A1 unlogged.
capture log close indcomp
log using "$path_out_log/ind_composition_stages.log", replace name(indcomp)


* Average real wage per 1-digit industry (for ordering, low to high)
use $path_clean_panel/2010-2019-regression.dta, clear
gcollapse (mean) mean_lreal_wage = lreal_wage, by(fEAC_1let_rev3) fast
rename fEAC_1let_rev3 feac_1let_rev3
tempfile wage_ind
save `wage_ind', replace

* Industry composition of the VA subsample.
* This mirrors how value-added data is used in AKM_firm_HHI_VA_TFP.do: start
* from the Estimation Sample (the regression panel) and keep the worker-years
* whose firm has non-missing value added in the firm-level tfp_va_data file
* (merged m:1 on fnumber_FIC). The result is the subset of the Estimation
* Sample for which the VA-based decompositions can be run.
use $path_clean_panel/2010-2019-regression.dta, clear
merge m:1 fnumber_FIC using $path_clean_int/va_tfp_data/tfp_va_data, ///
    keepusing(valueadded_mp) keep(master match) nogenerate
drop if missing(valueadded_mp)
gcollapse (count) N_va = valueadded_mp, by(fEAC_1let_rev3) fast
rename fEAC_1let_rev3 feac_1let_rev3
egen total_va = total(N_va)
gen pct_va = round(100 * N_va / total_va, 0.01)
drop total_va
tempfile va_coll
save `va_coll', replace

* Load and append all three stages across years
clear
tempfile raw
save `raw', replace emptyok
foreach y of numlist 2010/2019 {
    capture import delimited "$path_out_log/ind_composition/raw_`y'.csv", clear varnames(1)
    if _rc == 0 {
        append using `raw'
        save `raw', replace
    }
}
use `raw', clear

clear
tempfile presize
save `presize', replace emptyok
foreach y of numlist 2010/2019 {
    capture import delimited "$path_out_log/ind_composition/presize_`y'.csv", clear varnames(1)
    if _rc == 0 {
        append using `presize'
        save `presize', replace
    }
}
use `presize', clear

clear
tempfile final
save `final', replace emptyok
foreach y of numlist 2010/2019 {
    capture import delimited "$path_out_log/ind_composition/final_min10_`y'.csv", clear varnames(1)
    if _rc == 0 {
        append using `final'
        save `final', replace
    }
}
use `final', clear

* Collapse each stage to overall (all years)
use `raw', clear
gen total_raw = sum(n)
sum total_raw, meanonly
local total_raw = r(max)
gcollapse (sum) N_raw = n, by(feac_1let_rev3) fast
gen pct_raw = round(100 * N_raw / `total_raw', 0.01)
tempfile raw_coll
save `raw_coll', replace

use `presize', clear
gen total_presize = sum(n)
sum total_presize, meanonly
local total_presize = r(max)
gcollapse (sum) N_presize = n, by(feac_1let_rev3) fast
gen pct_presize = round(100 * N_presize / `total_presize', 0.01)
tempfile presize_coll
save `presize_coll', replace

use `final', clear
gen total_final = sum(n)
sum total_final, meanonly
local total_final = r(max)
gcollapse (sum) N_final = n, by(feac_1let_rev3) fast
gen pct_final = round(100 * N_final / `total_final', 0.01)
tempfile final_coll
save `final_coll', replace

* Merge all three
use `raw_coll', clear
merge 1:1 feac_1let_rev3 using `presize_coll', nogenerate
merge 1:1 feac_1let_rev3 using `final_coll', nogenerate
merge 1:1 feac_1let_rev3 using `va_coll', keep(master match) nogenerate

* Industries absent from the VA subsample have 0% VA composition
replace pct_va = 0 if missing(pct_va)

* Merge in average wage per industry (for ordering)
merge 1:1 feac_1let_rev3 using `wage_ind', keep(master match) nogenerate

* Drop missing industry (if any)
drop if missing(feac_1let_rev3)

* Drop industries with 0 in the All-Firms sample
drop if missing(pct_presize) | pct_presize == 0

* Relabel industries
replace feac_1let_rev3 = "Agriculture" if feac_1let_rev3 == "A"
replace feac_1let_rev3 = "Mining and quarrying" if feac_1let_rev3 == "B"
replace feac_1let_rev3 = "Manufacturing" if feac_1let_rev3 == "C"
replace feac_1let_rev3 = "Electricity, gas, steam and air cond. supply" if feac_1let_rev3 == "D"
replace feac_1let_rev3 = "Water supply; sewerage, waste management " if feac_1let_rev3 == "E"
replace feac_1let_rev3 = "Construction" if feac_1let_rev3 == "F"
replace feac_1let_rev3 = "Wholesale and retail trade" if feac_1let_rev3 == "G"
replace feac_1let_rev3 = "Transportation and storage" if feac_1let_rev3 == "H"
replace feac_1let_rev3 = "Accommodation and food service act." if feac_1let_rev3 == "I"
replace feac_1let_rev3 = "Information and communication" if feac_1let_rev3 == "J"
replace feac_1let_rev3 = "Financial and insurance act." if feac_1let_rev3 == "K"
replace feac_1let_rev3 = "Real estate act." if feac_1let_rev3 == "L"
replace feac_1let_rev3 = "Professional, scientific and technical act." if feac_1let_rev3 == "M"
replace feac_1let_rev3 = "Administrative and support service act." if feac_1let_rev3 == "N"
replace feac_1let_rev3 = "Public administration and defense" if feac_1let_rev3 == "O"
replace feac_1let_rev3 = "Education" if feac_1let_rev3 == "P"
replace feac_1let_rev3 = "Human health and social work act." if feac_1let_rev3 == "Q"
replace feac_1let_rev3 = "Arts, entertainment and recreation" if feac_1let_rev3 == "R"
replace feac_1let_rev3 = "Other service activities" if feac_1let_rev3 == "S"
replace feac_1let_rev3 = "Activities of households as employers" if feac_1let_rev3 == "T"
replace feac_1let_rev3 = "Act. of extraterritorial organisations" if feac_1let_rev3 == "U"

* Sort by average wage ascending (low to high)
gsort mean_lreal_wage

* Label variables
label var feac_1let_rev3 "Industry"
label var pct_presize "% (All Firms Sample)"
label var pct_final "% (Estimation Sample)"
label var pct_va "% (Value added Sample)"

* Display
list feac_1let_rev3 pct_presize pct_final pct_va, sep(0) abbrev(50)

* Export to LaTeX
local tablabel "table_a01_industry_composition"

file open texfile using "$path_out_tab/`tablabel'.tex", write replace
file write texfile "\begin{tabular}{lccc}" _n
file write texfile "\toprule" _n
file write texfile "& \multicolumn{3}{c}{Sample} \\" _n
file write texfile "\cmidrule(lr){2-4}" _n
file write texfile "Industry & All Firms & Estimation & Value added \\" _n
file write texfile "& (1) & (2) & (3) \\" _n
file write texfile "\midrule" _n

local N = _N
forvalues i = 1/`N' {
    local ind = feac_1let_rev3[`i']
    local p2 : di %6.2f pct_presize[`i']
    local p3 : di %6.2f pct_final[`i']
    local p4 : di %6.2f pct_va[`i']
    local p2 = strtrim("`p2'")
    local p3 = strtrim("`p3'")
    local p4 = strtrim("`p4'")
    file write texfile "`ind' & `p2' & `p3' & `p4' \\" _n
}

file write texfile "\bottomrule" _n
file write texfile "\end{tabular}" _n
file close texfile

log close indcomp

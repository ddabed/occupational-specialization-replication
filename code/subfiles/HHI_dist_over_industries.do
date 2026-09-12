*-------------------------------------------------------------------------
* HHI_dist_over_industries.do -- Table 3
*
* Mean, 10th and 90th percentile of firm specialization within each 1-digit
* (NACE letter) industry, over firm-year observations. Industries are ordered
* by their average worker wage, from lowest to highest.
*   out: $path_out_tab/table_03_specialization_across_industries.tex
*-------------------------------------------------------------------------

use $path_clean_panel/2010-2019-regression.dta, clear

* Average real wage per 1-digit industry (worker-year mean, for ordering low to high)
* Computed on the full worker-year panel so it matches ind_composition_stages.do
preserve
gcollapse (mean) mean_lreal_wage = lreal_wage, by(fEAC_1let_rev3) fast
tempfile wage_ind
save `wage_ind', replace
restore

* Collapse to firm-year level
gegen tag = tag(fnumber year)
keep if tag == 1
drop tag

* Compute mean, p10 and p90 of nHHI_3dig by industry
gcollapse (mean) mean_nHHI = nHHI_3dig (p10) p10_nHHI = nHHI_3dig (p90) p90_nHHI = nHHI_3dig, by(fEAC_1let_rev3) fast

* Merge in worker-year mean wage per industry (for ordering)
merge 1:1 fEAC_1let_rev3 using `wage_ind', keep(master match) nogenerate

* Relabel industries
replace fEAC_1let_rev3 = "Mining and quarrying" if fEAC_1let_rev3 == "B"
replace fEAC_1let_rev3 = "Manufacturing" if fEAC_1let_rev3 == "C"
replace fEAC_1let_rev3 = "Electricity, gas, steam and air cond. supply" if fEAC_1let_rev3 == "D"
replace fEAC_1let_rev3 = "Water supply; sewerage, waste management " if fEAC_1let_rev3 == "E"
replace fEAC_1let_rev3 = "Construction" if fEAC_1let_rev3 == "F"
replace fEAC_1let_rev3 = "Wholesale and retail trade" if fEAC_1let_rev3 == "G"
replace fEAC_1let_rev3 = "Transportation and storage" if fEAC_1let_rev3 == "H"
replace fEAC_1let_rev3 = "Accommodation and food service act." if fEAC_1let_rev3 == "I"
replace fEAC_1let_rev3 = "Information and communication" if fEAC_1let_rev3 == "J"
replace fEAC_1let_rev3 = "Financial and insurance act." if fEAC_1let_rev3 == "K"
replace fEAC_1let_rev3 = "Real estate act." if fEAC_1let_rev3 == "L"
replace fEAC_1let_rev3 = "Professional, scientific and technical act." if fEAC_1let_rev3 == "M"
replace fEAC_1let_rev3 = "Administrative and support service act." if fEAC_1let_rev3 == "N"
replace fEAC_1let_rev3 = "Public administration and defense" if fEAC_1let_rev3 == "O"
replace fEAC_1let_rev3 = "Education" if fEAC_1let_rev3 == "P"
replace fEAC_1let_rev3 = "Human health and social work act." if fEAC_1let_rev3 == "Q"
replace fEAC_1let_rev3 = "Arts, entertainment and recreation" if fEAC_1let_rev3 == "R"
replace fEAC_1let_rev3 = "Other service activities" if fEAC_1let_rev3 == "S"
replace fEAC_1let_rev3 = "Activities of households as employers" if fEAC_1let_rev3 == "T"
replace fEAC_1let_rev3 = "Act. of extraterritorial organisations" if fEAC_1let_rev3 == "U"

* Format for display
format mean_nHHI %9.3f
format p10_nHHI %9.3f
format p90_nHHI %9.3f

* Sort by average wage ascending (low to high)
gsort mean_lreal_wage

* Label variables
label var fEAC_1let_rev3 "Industry"
label var mean_nHHI "Mean"
label var p10_nHHI "P10"
label var p90_nHHI "P90"

* Display results
list fEAC_1let_rev3 mean_nHHI p10_nHHI p90_nHHI, sep(0) abbrev(50)

* Export to LaTeX
local tablabel "table_03_specialization_across_industries"

file open texfile using "$path_out_tab/`tablabel'.tex", write replace
file write texfile "\begin{tabular}{lccc}" _n
file write texfile "\toprule" _n
file write texfile "Industry & Mean & P10 & P90 \\" _n
file write texfile "\midrule" _n

local N = _N
forvalues i = 1/`N' {
	local ind = fEAC_1let_rev3[`i']
	local mn = string(mean_nHHI[`i'], "%9.3f")
	local p10 = string(p10_nHHI[`i'], "%9.3f")
	local p90 = string(p90_nHHI[`i'], "%9.3f")
	file write texfile "`ind' & `mn' & `p10' & `p90' \\\\" _n
}

file write texfile "\bottomrule" _n
file write texfile "\end{tabular}" _n
file close texfile

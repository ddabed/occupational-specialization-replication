
use $path_clean_panel/2010-2019-regression.dta, clear

* ---------------------------------------------------------------------------
* Build firm-year Normalized Task Concentration measure (see task_analysis.do)
* ---------------------------------------------------------------------------
preserve
	cap drop _merge
	merge m:1 occup4_10 using $path_raw/scores_isco4dig
	drop if _merge == 2
	gcollapse (sd) socskills routine cognitive manual, by(fnumber year) fast
	egen taskdiv = rowmean(socskills routine cognitive manual)
	tempfile taskdiv
	save `taskdiv', replace
restore

preserve
	merge m:1 fnumber year using `taskdiv', keepusing(taskdiv) keep(master match) nogen
	cap drop ntaskdiv ntaskcon
	sum taskdiv, meanonly
	gen ntaskdiv = (taskdiv - r(min)) / (r(max) - r(min))
	gen ntaskcon = 1 - ntaskdiv
	gcollapse (first) ntaskcon, by(fnumber_FIC year) fast
	tempfile taskcon
	save `taskcon', replace
restore

* Count number of occs per firm
by fnumber_FIC occup1_10, sort: gen noccs_1dig = _n == 1
by fnumber_FIC: replace noccs_1dig = sum(noccs_1dig)
by fnumber_FIC: replace noccs_1dig = noccs_1dig[_N]
label var noccs_1dig "N. of occ. 1-dig"

by fnumber_FIC occup3_10, sort: gen noccs_3dig = _n == 1
by fnumber_FIC: replace noccs_3dig = sum(noccs_3dig)
by fnumber_FIC: replace noccs_3dig = noccs_3dig[_N]
label var noccs_3dig "N. of occ. 3-dig"
	
encode fEAC_34dig_rev3, gen(industry4)
encode fEAC_1let_rev3, gen(industry1)


*1. anova at the firm level
gcollapse (first) industry4 industry1 HHI_3dig HHI_1dig nHHI_3dig nHHI_1dig share_3dig_max share_1dig_max noccs_1dig noccs_3dig, by(fnumber_FIC year) fast

merge 1:1 fnumber_FIC year using `taskcon', keepusing(ntaskcon) keep(master match) nogen
label var ntaskcon "Normalized Task Concentration"

label var HHI_1dig "HHI 1-dig."
label var HHI_3dig "HHI 3-digit"
label var industry4 "Industry 4-dig."
label var industry1 "Industry 1-dig."
label var share_1dig_max "Main occ. share 1-dig"
label var share_3dig_max "Main occ. share 3-dig"
label var noccs_1dig "N. of occs. 1-dig"
label var noccs_3dig "N. of occs. 3-dig"
label var nHHI_3dig "HHI 3-digit"
label var nHHI_1dig "Normalized HHI 1-dig."

* Store the number of observations with comma formatting
local num = _N
local num_formatted : di %12.0fc `num'
local num_formatted = strtrim("`num_formatted'")

* Create a matrix to store all R-squared values (7 rows for measures, 4 columns for fixed effects)
matrix R2 = J(7, 4, .)
matrix rownames R2 = "nHHI_1dig" "nHHI_3dig" "share_1dig_max" "share_3dig_max" "noccs_1dig" "noccs_3dig" "ntaskcon"
matrix colnames R2 = "1-dig_ind" "4-dig_ind" "1-dig_ind_year" "4-dig_ind_year"

* Row 1: nHHI_1dig
anova nHHI_1dig industry1
matrix R2[1,1] = round(e(r2), 0.01)

regress nHHI_1dig i.industry4	
matrix R2[1,2] = round(e(r2), 0.01)

reghdfe nHHI_1dig, noconstant absorb(i.industry1#i.year)
matrix R2[1,3] = round(e(r2), 0.01)

reghdfe nHHI_1dig, noconstant absorb(i.industry4#i.year)
matrix R2[1,4] = round(e(r2), 0.01)

* Row 2: nHHI_3dig
anova nHHI_3dig industry1
matrix R2[2,1] = round(e(r2), 0.01)

regress nHHI_3dig i.industry4	
matrix R2[2,2] = round(e(r2), 0.01)

reghdfe nHHI_3dig, noconstant absorb(i.industry1#i.year)
matrix R2[2,3] = round(e(r2), 0.01)

reghdfe nHHI_3dig, noconstant absorb(i.industry4#i.year)
matrix R2[2,4] = round(e(r2), 0.01)

* Row 3: share_1dig_max
anova share_1dig_max industry1
matrix R2[3,1] = round(e(r2), 0.01)

regress share_1dig_max i.industry4	
matrix R2[3,2] = round(e(r2), 0.01)

reghdfe share_1dig_max, noconstant absorb(i.industry1#i.year)
matrix R2[3,3] = round(e(r2), 0.01)

reghdfe share_1dig_max, noconstant absorb(i.industry4#i.year)
matrix R2[3,4] = round(e(r2), 0.01)

* Row 4: share_3dig_max
anova share_3dig_max industry1
matrix R2[4,1] = round(e(r2), 0.01)

regress share_3dig_max i.industry4	
matrix R2[4,2] = round(e(r2), 0.01)

reghdfe share_3dig_max, noconstant absorb(i.industry1#i.year)
matrix R2[4,3] = round(e(r2), 0.01)

reghdfe share_3dig_max, noconstant absorb(i.industry4#i.year)
matrix R2[4,4] = round(e(r2), 0.01)

* Row 5: noccs_1dig
anova noccs_1dig industry1
matrix R2[5,1] = round(e(r2), 0.01)

regress noccs_1dig i.industry4	
matrix R2[5,2] = round(e(r2), 0.01)

regress noccs_1dig i.industry1#i.year
matrix R2[5,3] = round(e(r2), 0.01)

reghdfe noccs_1dig, noconstant absorb(i.industry4#i.year)
matrix R2[5,4] = round(e(r2), 0.01)

* Row 6: noccs_3dig
anova noccs_3dig industry1
matrix R2[6,1] = round(e(r2), 0.01)

regress noccs_3dig i.industry4	
matrix R2[6,2] = round(e(r2), 0.01)

regress noccs_3dig i.industry1#i.year
matrix R2[6,3] = round(e(r2), 0.01)

reghdfe noccs_3dig, noconstant absorb(i.industry4#i.year)
matrix R2[6,4] = round(e(r2), 0.01)

* Row 7: ntaskcon
anova ntaskcon industry1
matrix R2[7,1] = round(e(r2), 0.01)

regress ntaskcon i.industry4
matrix R2[7,2] = round(e(r2), 0.01)

reghdfe ntaskcon, noconstant absorb(i.industry1#i.year)
matrix R2[7,3] = round(e(r2), 0.01)

reghdfe ntaskcon, noconstant absorb(i.industry4#i.year)
matrix R2[7,4] = round(e(r2), 0.01)

* Export the matrix to LaTeX format
local tablabel "table_a02_anova_fixed_effects"

* Write the LaTeX table manually with proper formatting
file open myfile using "$path_out_tab/`tablabel'.tex", write replace

* Write the LaTeX table header
file write myfile "\begin{tabular}{lcccc}" _n
file write myfile "\toprule" _n
file write myfile "Specialization & \multicolumn{4}{c}{\textit{Fixed Effects:}} \\" _n
file write myfile "\cmidrule(lr){2-5}" _n
file write myfile "Measure & 1-dig. ind & 4-dig. ind & 1-dig. \$\times\$ year & 4-dig. \$\times\$ year \\" _n
file write myfile "\midrule" _n

* Write data rows

* Row labeled HHI 3-dig (matrix row 2: nHHI_3dig)
local val1 = string(R2[2,1], "%9.2f")
local val2 = string(R2[2,2], "%9.2f")
local val3 = string(R2[2,3], "%9.2f")
local val4 = string(R2[2,4], "%9.2f")
file write myfile "HHI 3-dig & `val1' & `val2' & `val3' & `val4' \\" _n


* Row labeled HHI 1-dig (matrix row 1: nHHI_1dig)
local val1 = string(R2[1,1], "%9.2f")
local val2 = string(R2[1,2], "%9.2f")
local val3 = string(R2[1,3], "%9.2f")
local val4 = string(R2[1,4], "%9.2f")
file write myfile "HHI 1-dig & `val1' & `val2' & `val3' & `val4' \\" _n

* Row labeled share 3-dig (matrix row 4: share_3dig_max)
local val1 = string(R2[4,1], "%9.2f")
local val2 = string(R2[4,2], "%9.2f")
local val3 = string(R2[4,3], "%9.2f")
local val4 = string(R2[4,4], "%9.2f")
file write myfile "Share largest 3-dig occupation & `val1' & `val2' & `val3' & `val4' \\" _n

* Row labeled share 1-dig (matrix row 3: share_1dig_max)
local val1 = string(R2[3,1], "%9.2f")
local val2 = string(R2[3,2], "%9.2f")
local val3 = string(R2[3,3], "%9.2f")
local val4 = string(R2[3,4], "%9.2f")
file write myfile "Share largest 1-dig occupation & `val1' & `val2' & `val3' & `val4' \\" _n

* Row 7: Normalized task concentration
local val1 = string(R2[7,1], "%9.2f")
local val2 = string(R2[7,2], "%9.2f")
local val3 = string(R2[7,3], "%9.2f")
local val4 = string(R2[7,4], "%9.2f")
file write myfile "Task concentration & `val1' & `val2' & `val3' & `val4' \\" _n



* Write the table footer with note
file write myfile "\midrule" _n
file write myfile "\end{tabular}" _n


file close myfile

* Also display the matrix for verification
matrix list R2, format(%9.2f)

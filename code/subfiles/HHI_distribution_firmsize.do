*-------------------------------------------------------------------------
* HHI_distribution_firmsize.do -- Table A3
*
* Distribution of the 3-digit HHI within deciles of average firm size, with the
* standard deviation after residualizing on industry x year fixed effects.
* Firms are assigned to a size decile once, on their average employment over
* the whole period, so a firm does not move between columns across years.
*   out: $path_out_tab/table_a03_specialization_by_firm_size.tex
*-------------------------------------------------------------------------

use $path_clean_panel/2010-2019-regression.dta, clear


* Count number of occs per firm
by fnumber_FIC occup1_10, sort: gen noccs_1dig = _n == 1
by fnumber_FIC: replace noccs_1dig = sum(noccs_1dig)
by fnumber_FIC: replace noccs_1dig = noccs_1dig[_N]

by fnumber_FIC occup3_10, sort: gen noccs_3dig = _n == 1
by fnumber_FIC: replace noccs_3dig = sum(noccs_3dig)
by fnumber_FIC: replace noccs_3dig = noccs_3dig[_N]

*Deciles firm size (average size across period)
bysort fnumber_FIC: gegen avfirmsize = mean(sizeFirm)

bysort fnumber_FIC: gen aux = _n == 1
xtile fs_dec = avfirmsize if aux == 1, nq(10)
bysort fnumber_FIC: gegen fs_decile = max(fs_dec)

drop aux fs_dec

*Labels

label var noccs_1dig "N. of occs. 1-dig"
label var noccs_3dig "N. of occs. 3-dig"
label var fs_decile "Firm size decile"

** firm level

gcollapse (first) nHHI_1dig nHHI_3dig share_1dig_max share_3dig_max noccs_1dig noccs_3dig industry fs_decile, by(year fnumber_FIC) fast 


* Residualize HHI 3-dig wrt Industry and Year by Firm Size decile

forvalues i=1/10{
	
	reghdfe c.nHHI_3dig if fs_decile == `i', noconstant absorb(year#industry) cluster($clustervar) residuals(HHI_3_resid_`i')
	summarize HHI_3_resid_`i'
	local HHI_3_resid_`i'_sd = r(sd)

}



* Summary table

eststo clear

forvalues i = 1/10{
	
	estpost tabstat nHHI_3dig if fs_decile == `i' , listwise statistics(mean p10 p25 p50 p75 p90) columns(variables) 
	estadd scalar HHI_indyear_sd = `HHI_3_resid_`i'_sd'
	eststo HHI_n3digtab_`i'
	
} 


		
* Table file name

local tabtitle "Distribution of specialization over firm-year observations"
local tablabel "table_a03_specialization_by_firm_size"

* One estimate per size decile, each contributing a single column.
esttab HHI_n3digtab_*  using $path_out_tab/`tablabel'.tex, ///
	cells("nHHI_3dig(fmt(2) label(nHH1_3dig))")  ///
	stats(HHI_indyear_sd, label("Sd. year $\times$ industry")) ///
	label noobs eqlabels(none) booktabs style(tex) noomitted mtitles("1" "2" "3" "4" "5" "6" "7" "8" "9" "10") ///
	substitute(mean Mean) collabels(none) nonotes ///
	nonumbers ///
	prehead(`"\begin{tabularx}{\textwidth}{l*{@M}{Y}}"' ///
	`"\toprule"' ///
	`"& \multicolumn{10}{c}{\textit{Firm size decile}} \\"') ///
	posthead("\midrule") ///
	prefoot("\midrule") ///
	postfoot("\bottomrule" "\end{tabularx}") ///
	replace


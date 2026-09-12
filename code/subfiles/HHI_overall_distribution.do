*-------------------------------------------------------------------------
* HHI_overall_distribution.do -- Table 2, Panel A
*
* Distribution of the specialization measures over FIRM-YEAR observations:
* mean and percentiles, plus the standard deviation overall and after
* residualizing on year, industry, and industry x year fixed effects.
* Panel B (HHI_overall_distribution_emp_weighted.do) reports the same
* statistics over worker-year observations, so that each firm is weighted by
* its employment.
*   out: $path_out_tab/table_02_panel_a_specialization_distribution.tex
*-------------------------------------------------------------------------

use $path_clean_panel/2010-2019-regression.dta, clear

* Count number of occs per firm
by fnumber_FIC occup1_10, sort: gen noccs_1dig = _n == 1
by fnumber_FIC: replace noccs_1dig = sum(noccs_1dig)
by fnumber_FIC: replace noccs_1dig = noccs_1dig[_N]

by fnumber_FIC occup3_10, sort: gen noccs_3dig = _n == 1
by fnumber_FIC: replace noccs_3dig = sum(noccs_3dig)
by fnumber_FIC: replace noccs_3dig = noccs_3dig[_N]

label var noccs_1dig "N. of occs. 1-dig"
label var noccs_3dig "N. of occs. 3-dig"

** Collapse to firmXyear level

gcollapse (first) nHHI_1dig nHHI_3dig share_1dig_max share_3dig_max noccs_1dig noccs_3dig ntaskcon nHHI_4dig share_4dig_max industry HHI_1dig HHI_3dig sizeFirm, by(year fnumber_FIC) fast

	
* Residualize HHI wrt Industry and Year
reghdfe c.nHHI_1dig , noconstant absorb(year) cluster($clustervar) residuals(HHI_resid_0)

reghdfe c.nHHI_1dig , noconstant absorb(industry) cluster($clustervar) residuals(HHI_resid_1)

reghdfe c.nHHI_1dig , noconstant absorb(year#industry) cluster($clustervar) residuals(HHI_resid_2)


* Residualize HHI 3-dig wrt Industry and Year
reghdfe c.nHHI_3dig , noconstant absorb(year) cluster($clustervar) residuals(HHI_3_resid_0)

reghdfe c.nHHI_3dig , noconstant absorb(industry) cluster($clustervar) residuals(HHI_3_resid_1)

reghdfe c.nHHI_3dig , noconstant absorb(year#industry) cluster($clustervar) residuals(HHI_3_resid_2)


* Residualize main occ share 1-dig wrt Industry and Year
reghdfe c.share_1dig_max , noconstant absorb(year) cluster($clustervar) residuals(share_1dig_max_resid_0)

reghdfe c.share_1dig_max , noconstant absorb(industry) cluster($clustervar) residuals(share_1dig_max_resid_1)

reghdfe c.share_1dig_max , noconstant absorb(year#industry) cluster($clustervar) residuals(share_1dig_max_resid_2)


* Residualize Normalized Task Concentration measure wrt Industry and Year

reghdfe c.ntaskcon , noconstant absorb(year) cluster($clustervar) residuals(ntaskcon_resid_0)

reghdfe c.ntaskcon , noconstant absorb(industry) cluster($clustervar) residuals(ntaskcon_resid_1)

reghdfe c.ntaskcon , noconstant absorb(year#industry) cluster($clustervar) residuals(ntaskcon_resid_2)


* Residualize main occ share 3-dig wrt Industry and Year
reghdfe c.share_3dig_max , noconstant absorb(year) cluster($clustervar) residuals(share_3dig_max_resid_0)

reghdfe c.share_3dig_max , noconstant absorb(industry) cluster($clustervar) residuals(share_3dig_max_resid_1)

reghdfe c.share_3dig_max , noconstant absorb(year#industry) cluster($clustervar) residuals(share_3dig_max_resid_2)


* Residualize n occs 1-dig wrt Industry and Year
reghdfe c.noccs_1dig , noconstant absorb(year) cluster($clustervar) residuals(noccs_1dig_resid_0)

reghdfe c.noccs_1dig , noconstant absorb(industry) cluster($clustervar) residuals(noccs_1dig_resid_1)

reghdfe c.noccs_1dig , noconstant absorb(year#industry) cluster($clustervar) residuals(noccs_1dig_resid_2)

* Residualize n occs 3-dig wrt Industry and Year
reghdfe c.noccs_3dig , noconstant absorb(year) cluster($clustervar) residuals(noccs_3dig_resid_0)

reghdfe c.noccs_3dig , noconstant absorb(industry) cluster($clustervar) residuals(noccs_3dig_resid_1)

reghdfe c.noccs_3dig , noconstant absorb(year#industry) cluster($clustervar) residuals(noccs_3dig_resid_2)

	
* Residualize HHI wrt Industry and Year
reghdfe c.nHHI_4dig , noconstant absorb(year) cluster($clustervar) residuals(HHI_4_resid_0)

reghdfe c.nHHI_4dig , noconstant absorb(industry) cluster($clustervar) residuals(HHI_4_resid_1)

reghdfe c.nHHI_4dig , noconstant absorb(year#industry) cluster($clustervar) residuals(HHI_4_resid_2)


* Residualize main occ share 4-dig wrt Industry and Year
reghdfe c.share_4dig_max , noconstant absorb(year) cluster($clustervar) residuals(share_4dig_max_resid_0)

reghdfe c.share_4dig_max , noconstant absorb(industry) cluster($clustervar) residuals(share_4dig_max_resid_1)

reghdfe c.share_4dig_max , noconstant absorb(year#industry) cluster($clustervar) residuals(share_4dig_max_resid_2)


*HHI 1dig
summarize nHHI_1dig
local HHI_1dig_sd = r(sd)

summarize HHI_resid_0
local HHI_res_0_sd = r(sd)

summarize HHI_resid_1
local HHI_res_1_sd = r(sd)

summarize HHI_resid_2
local HHI_res_2_sd = r(sd)

*HHI 3dig
summarize nHHI_3dig
local HHI_3dig_sd = r(sd)

summarize HHI_3_resid_0
local HHI_3_res_0_sd = r(sd)

summarize HHI_3_resid_1
local HHI_3_res_1_sd = r(sd)

summarize HHI_3_resid_2
local HHI_3_res_2_sd = r(sd)

*Largest occ 1dig
summarize share_1dig_max
local main_occ_share_1dig_sd = r(sd)

summarize share_1dig_max_resid_0
local main_occ_1_res_0_sd = r(sd)

summarize share_1dig_max_resid_1
local main_occ_1_res_1_sd = r(sd)

summarize share_1dig_max_resid_2
local main_occ_1_res_2_sd = r(sd)

*Largest occ 3 dig
summarize share_3dig_max
local main_occ_share_3dig_sd = r(sd)

summarize share_3dig_max_resid_0
local main_occ_3_res_0_sd = r(sd)

summarize share_3dig_max_resid_1
local main_occ_3_res_1_sd = r(sd)

summarize share_3dig_max_resid_2
local main_occ_3_res_2_sd = r(sd)

*Task concentration
summarize ntaskcon
local ntaskcon_sd = r(sd)

summarize ntaskcon_resid_0
local ntaskcon_res_0_sd = r(sd)

summarize ntaskcon_resid_1
local ntaskcon_res_1_sd = r(sd)

summarize ntaskcon_resid_2
local ntaskcon_res_2_sd = r(sd)

*Nr 1 dig occ
summarize noccs_1dig_resid_0
local n_occs_1_res_0_sd = r(sd)

summarize noccs_1dig_resid_1
local n_occs_1_res_1_sd = r(sd)

summarize noccs_1dig_resid_2
local n_occs_1_res_2_sd = r(sd)

*Nr 3 dig occ
summarize noccs_3dig_resid_0
local n_occs_3_res_0_sd = r(sd)

summarize noccs_3dig_resid_1
local n_occs_3_res_1_sd = r(sd)

summarize noccs_3dig_resid_2
local n_occs_3_res_2_sd = r(sd)

*HHI 4 dig
summarize nHHI_4dig
local HHI_4dig_sd = r(sd)

summarize HHI_4_resid_0
local HHI_4_res_0_sd = r(sd)

summarize HHI_4_resid_1
local HHI_4_res_1_sd = r(sd)

summarize HHI_4_resid_2
local HHI_4_res_2_sd = r(sd)


*Largest occ 4 dig
summarize share_4dig_max
local main_occ_share_4dig_sd = r(sd)

summarize share_4dig_max_resid_0
local main_occ_4_res_0_sd = r(sd)

summarize share_4dig_max_resid_1
local main_occ_4_res_1_sd = r(sd)

summarize share_4dig_max_resid_2
local main_occ_4_res_2_sd = r(sd)

* Summary table

eststo clear

estpost tabstat nHHI_1dig, listwise statistics(mean p10 p25 p50 p75 p90) columns(variables) 
estadd scalar HHI_0_sd = `HHI_1dig_sd'
estadd scalar HHI_res_0_sd = `HHI_res_0_sd'
estadd scalar HHI_res_1_sd = `HHI_res_1_sd'
estadd scalar HHI_res_2_sd = `HHI_res_2_sd'
eststo HHI_1digtab


estpost tabstat nHHI_3dig, listwise statistics(mean p10 p25 p50 p75 p90) columns(variables)
estadd scalar HHI_0_sd = `HHI_3dig_sd'
estadd scalar HHI_res_0_sd = `HHI_3_res_0_sd'
estadd scalar HHI_res_1_sd = `HHI_3_res_1_sd'
estadd scalar HHI_res_2_sd = `HHI_3_res_2_sd'
eststo HHI_3digtab

estpost tabstat share_1dig_max, listwise statistics(mean p10 p25 p50 p75 p90) columns(variables)
estadd scalar HHI_0_sd = `main_occ_share_1dig_sd'
estadd scalar HHI_res_0_sd = `main_occ_1_res_0_sd'
estadd scalar HHI_res_1_sd = `main_occ_1_res_1_sd'
estadd scalar HHI_res_2_sd = `main_occ_1_res_2_sd'
eststo share_1dig_max_tab

estpost tabstat share_3dig_max, listwise statistics(mean p10 p25 p50 p75 p90) columns(variables)
estadd scalar HHI_0_sd = `main_occ_share_3dig_sd'
estadd scalar HHI_res_0_sd = `main_occ_3_res_0_sd'
estadd scalar HHI_res_1_sd = `main_occ_3_res_1_sd'
estadd scalar HHI_res_2_sd = `main_occ_3_res_2_sd'
eststo share_3dig_max_tab


estpost tabstat ntaskcon, listwise statistics(mean p10 p25 p50 p75 p90) columns(variables) 
estadd scalar HHI_0_sd = `ntaskcon_sd'
estadd scalar HHI_res_0_sd = `ntaskcon_res_0_sd'
estadd scalar HHI_res_1_sd = `ntaskcon_res_1_sd'
estadd scalar HHI_res_2_sd = `ntaskcon_res_2_sd'
eststo ntaskcon_tab


estpost tabstat nHHI_4dig, listwise statistics(mean p10 p25 p50 p75 p90) columns(variables)
estadd scalar HHI_0_sd = `HHI_4dig_sd'
estadd scalar HHI_res_0_sd = `HHI_4_res_0_sd'
estadd scalar HHI_res_1_sd = `HHI_4_res_1_sd'
estadd scalar HHI_res_2_sd = `HHI_4_res_2_sd'
eststo HHI_4digtab

estpost tabstat share_4dig_max, listwise statistics(mean p10 p25 p50 p75 p90) columns(variables)
estadd scalar HHI_0_sd = `main_occ_share_4dig_sd'
estadd scalar HHI_res_0_sd = `main_occ_4_res_0_sd'
estadd scalar HHI_res_1_sd = `main_occ_4_res_1_sd'
estadd scalar HHI_res_2_sd = `main_occ_4_res_2_sd'
eststo share_4dig_max_tab

* The main-text table reports the 3-digit HHI, the 3-digit main-occupation
* share, and task concentration. The 1-digit and 4-digit estimates are stored
* above as well, so the appendix version can be assembled from the same run.

local tabtitle "Distribution of specialization over firm-year observations"
local tablabel "table_02_panel_a_specialization_distribution"

* The "&" between the cells() entries stacks the three measures into a single
* row block, so each stored estimate contributes one column rather than four.
esttab HHI_3digtab share_3dig_max_tab ntaskcon_tab  using $path_out_tab/`tablabel'.tex, ///
	cells("nHHI_3dig(fmt(2) label(nHH1_3dig))&share_3dig_max(fmt(2) label('Main occ. share 3-dig'))&ntaskcon(fmt(2) label('Task concentration'))")  ///
	stats(HHI_0_sd HHI_res_0_sd HHI_res_1_sd HHI_res_2_sd, label("Sd. overall" "Sd. within year" "Sd. within industry" "Sd. year $\times$ industry")) ///
	label noobs eqlabels(none) booktabs style(tex) noomitted mtitles("Norm. HHI 3-dig" "Share 3-dig" "Norm. Task Concentration") ///
	substitute(mean Mean) collabels(none) nonotes ///
	prehead("\begin{tabularx}{\textwidth}{l*{@M}{Y}}" "\toprule") ///
	posthead("\midrule") ///
	prefoot("\midrule") ///
	postfoot("\bottomrule" "\end{tabularx}") ///
	replace
	

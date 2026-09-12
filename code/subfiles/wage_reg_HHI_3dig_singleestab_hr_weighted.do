*-------------------------------------------------------------------------
* wage_reg_HHI_3dig_singleestab_hr_weighted.do -- Table A6, Panels A, B and C
*
* Two robustness checks on Table 4, reported side by side:
*   cols 1-2  the hours-weighted HHI in place of the headcount-based HHI,
*             estimated on the full sample
*   cols 3-4  the headcount HHI, restricted to single-establishment firms,
*             where firm-level and establishment-level specialization coincide
* Within each pair the specifications are Table 4 columns 5 and 6.
*   out: $path_out_tab/table_a06_panel_a_singleestab_hoursweighted_monthly_earnings.tex
*        $path_out_tab/table_a06_panel_b_singleestab_hoursweighted_monthly_hours.tex
*        $path_out_tab/table_a06_panel_c_singleestab_hoursweighted_hourly_wage.tex
*-------------------------------------------------------------------------

eststo clear   // drop estimates stored by earlier do-files, so esttab cannot pick up a stale one

use $path_clean_panel/2010-2019-regression.dta, clear


label var nHHI_3dig "HHI 3-digit"

**Normalized hours weighted HHI
gen nHHIw_3dig = (HHIw_3dig - (1/sizeFirm)) / (1 - (1/sizeFirm))
	label var nHHIw_3dig "HHI 3-digit"

* Estimate the hours-weighted columns under the shared coefficient name
* nHHI_3dig so they land on the same table row as the (unweighted) single-
* establishment columns. Park the unweighted measure, restore it afterwards.
rename nHHI_3dig nHHI_3dig_unw
rename nHHIw_3dig nHHI_3dig
	label var nHHI_3dig "HHI 3-digit"


// =====================================================================
// Hours-weighted HHI columns: run on the FULL sample, matching Table 4
// columns 5 and 6. The e_ID drop below is only needed to build the
// establishment count for the single-establishment columns, so it must
// not affect these regressions.
// =====================================================================
foreach depvar in lreal_wage lreg_hours_month lreal_hrl_wage {

		// Weighted hours
		eststo wHHI_`depvar'4: reghdfe `depvar' c.nHHI_3dig lfsize female native , ///
			   noconstant absorb(year#industry fNUTS2 age#educ occup3_10) cluster($clustervar)
					quietly estadd local fixedfsize "X", replace
					quietly estadd local fixedyear "X", replace
					quietly estadd local fixedind "X", replace
					quietly estadd local fixeddemographics "X", replace
					quietly estadd local fixedaeduc "X", replace
					quietly estadd local fixed1dig "X", replace
					quietly estadd local fixed3dig "X", replace
					quietly estadd local fixedworker " ", replace


		eststo wHHI_`depvar'5: reghdfe `depvar' c.nHHI_3dig lfsize , ///
			  noconstant absorb(year#industry fNUTS2 age#educ occup3_10 w_numer) cluster($clustervar)
					quietly estadd local fixedfsize "X", replace
					quietly estadd local fixedyear "X", replace
					quietly estadd local fixedind "X", replace
					quietly estadd local fixeddemographics " ", replace
					quietly estadd local fixedaeduc "X", replace
					quietly estadd local fixed1dig "X", replace
					quietly estadd local fixed3dig "X", replace
					quietly estadd local fixedworker "X", replace
}

* Restore names: nHHI_3dig back to the unweighted measure for the
* single-establishment (unweighted) columns below.
rename nHHI_3dig nHHIw_3dig
rename nHHI_3dig_unw nHHI_3dig
	label var nHHI_3dig "HHI 3-digit"


*Nr of establishments
drop if e_ID < 0                            // invalid establishment identifiers
bysort fnumber_FIC e_ID year: gen aux =_n==1 // group on firm as well, so that an
                                             // establishment id is never shared
                                             // across firms
bysort fnumber_FIC year: gegen nrestab_aux = sum(aux)
bysort fnumber_FIC year: gegen nrestab = max(nrestab_aux)
	drop nrestab_aux aux


// =====================================================================
// Single establishment firms columns: restricted sample (nrestab == 1)
// =====================================================================
foreach depvar in lreal_wage lreg_hours_month lreal_hrl_wage {

		// Single establishment firms
		eststo se_`depvar'4: reghdfe `depvar' c.nHHI_3dig lfsize female native if nrestab == 1 , ///
			   noconstant absorb(year#industry fNUTS2 age#educ occup3_10) cluster($clustervar)
					quietly estadd local fixedfsize "X", replace
					quietly estadd local fixedyear "X", replace
					quietly estadd local fixedind "X", replace
					quietly estadd local fixeddemographics "X", replace
					quietly estadd local fixedaeduc "X", replace
					quietly estadd local fixed1dig "X", replace
					quietly estadd local fixed3dig "X", replace
					quietly estadd local fixedworker " ", replace


		eststo se_`depvar'5: reghdfe `depvar' c.nHHI_3dig lfsize if nrestab == 1 , ///
			  noconstant absorb(year#industry fNUTS2 age#educ occup3_10 w_numer) cluster($clustervar)
					quietly estadd local fixedfsize "X", replace
					quietly estadd local fixedyear "X", replace
					quietly estadd local fixedind "X", replace
					quietly estadd local fixeddemographics " ", replace
					quietly estadd local fixedaeduc "X", replace
					quietly estadd local fixed1dig "X", replace
					quietly estadd local fixed3dig "X", replace
					quietly estadd local fixedworker "X", replace

}

* Each panel is exported as a standalone .tex fragment

local tabtitle "Wage regression: hours weighted HHI at 3 digit occupation and restricted sample"
local tablabel "table_a06_panel_a_singleestab_hoursweighted_monthly_earnings"

esttab wHHI_lreal_wage4 wHHI_lreal_wage5 se_lreal_wage4 se_lreal_wage5 using $path_out_tab/`tablabel'.tex, ///
	keep(nHHI_3dig) ///
	star(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
	b(%9.3f) se(%9.3f) ///
	nomtitles ///
	prehead(  "" ) ///
	mgroups("Hours Weighted HHI" "Single Establishment Firms", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	posthead("\toprule" "\multicolumn{@span}{l}{\textbf{A. Dependent variable: Log monthly earnings}} \vspace{0.5cm}  \\") ///
	prefoot("\midrule") ///
	postfoot("\midrule") ///
	s(r2, fmt( %9.2fc) label("$\text{R}^2$")) ///
	style(tex) ///
	label ///
	booktabs ///
	nonotes ///
	noobs ///
	fragment ///
	replace



local tablabel "table_a06_panel_b_singleestab_hoursweighted_monthly_hours"

esttab wHHI_lreg_hours_month4 wHHI_lreg_hours_month5 se_lreg_hours_month4 se_lreg_hours_month5 using $path_out_tab/`tablabel'.tex, ///
	keep(nHHI_3dig) ///
	star(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
	b(%9.3f) se(%9.3f) ///
	nomtitles ///
	prehead("\\" "\multicolumn{@span}{l}{\textbf{B. Dependent variable: Log total monthly hours}} \vspace{0.5cm} \\" ) ///
	postfoot("\midrule") ///
	posthead("") ///
	s(r2, fmt( %9.2fc) label("$\text{R}^2$")) ///
	style(tex) ///
	label ///
	booktabs ///
	nonotes ///
	nonumbers ///
	noobs ///
	fragment ///
	replace

local tablabel "table_a06_panel_c_singleestab_hoursweighted_hourly_wage"

esttab wHHI_lreal_hrl_wage4 wHHI_lreal_hrl_wage5 se_lreal_hrl_wage4 se_lreal_hrl_wage5  using $path_out_tab/`tablabel'.tex, ///
	keep(nHHI_3dig) ///
	star(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
	b(%9.3f) se(%9.3f) ///
	nomtitles ///
	prehead("\\" "\multicolumn{@span}{l}{\textbf{C. Dependent variable:  Log hourly wage}} \vspace{0.5cm}  \\"  ) ///
	postfoot("\bottomrule" ) ///
	posthead("") ///
	s(r2 hline fixedfsize fixedyear fixedaeduc fixed1dig fixed3dig fixedind fixedworker N, fmt(%9.2fc %9s %9s %9s %9s %9s %9s %9s %9s %12.2gc ) label("$\text{R}^2$" "\midrule" "Firm size" "Year and region FE" "Demographic controls"  "1-dig occupation FE" "3-dig occupation FE" "4-dig ind. $\times$ year FE" "Worker FE" "N" )) ///
	style(tex) ///
	label ///
	booktabs ///
	nonotes ///
	noobs ///
	nonumbers ///
	fragment ///
	replace

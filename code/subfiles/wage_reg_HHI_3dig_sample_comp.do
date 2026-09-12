*-------------------------------------------------------------------------
* wage_reg_HHI_3dig_sample_comp.do -- Table A5, Panels A, B and C
*
* Robustness of Table 4 to the minimum firm size. The two specifications of
* Table 4 columns 5 and 6 are re-run on a stricter sample (50 or more
* employees, obtained by filtering the main panel) and on a looser one (5 or
* more employees, which is its own panel built by makepanel.R).
*   out: $path_out_tab/table_a05_panel_a_size_cutoffs_monthly_earnings.tex
*        $path_out_tab/table_a05_panel_b_size_cutoffs_monthly_hours.tex
*        $path_out_tab/table_a05_panel_c_size_cutoffs_hourly_wage.tex
*-------------------------------------------------------------------------

eststo clear   // drop estimates stored by earlier do-files, so esttab cannot pick up a stale one


** ============================================================
** 50+ EMPLOYEES SAMPLE (baseline data, drop sizeFirm < 50)
** ============================================================

use $path_clean_panel/2010-2019-regression.dta, clear
drop if sizeFirm < 50
label var nHHI_3dig "HHI 3-digit"

** PANEL A

*A4. Table 4 col. 5 specification (50+ employees)
eststo s50_monthlywage4: reghdfe lreal_wage c.nHHI_3dig lfsize female native , noconstant absorb(year#industry fNUTS2 age#educ occup3_10) cluster($clustervar)
	quietly estadd local fixedfsize "X", replace
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker " ", replace

*A5. Table 4 col. 6 specification (50+ employees)
eststo s50_monthlywage5: reghdfe lreal_wage c.nHHI_3dig lfsize , noconstant absorb(year#industry fNUTS2 age#educ occup3_10 w_numer) cluster($clustervar)
	quietly estadd local fixedfsize "X", replace
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics " ", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker "X", replace

** PANEL B

*B4. Table 4 col. 5 specification (50+ employees)
eststo s50_hours4: reghdfe lreg_hours_month c.nHHI_3dig lfsize female native , noconstant absorb(year#industry fNUTS2 age#educ occup3_10) cluster($clustervar)
	quietly estadd local fixedfsize "X", replace
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker " ", replace

*B5. Table 4 col. 6 specification (50+ employees)
eststo s50_hours5: reghdfe lreg_hours_month c.nHHI_3dig lfsize , noconstant absorb(year#industry fNUTS2 age#educ occup3_10 w_numer) cluster($clustervar)
	quietly estadd local fixedfsize "X", replace
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics " ", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker "X", replace

** PANEL C

*C4. Table 4 col. 5 specification (50+ employees)
eststo s50_hourlywage4: reghdfe lreal_hrl_wage c.nHHI_3dig lfsize female native , noconstant absorb(year#industry fNUTS2 age#educ occup3_10) cluster($clustervar)
	quietly estadd local fixedfsize "X", replace
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker " ", replace

*C5. Table 4 col. 6 specification (50+ employees)
eststo s50_hourlywage5: reghdfe lreal_hrl_wage c.nHHI_3dig lfsize , noconstant absorb(year#industry fNUTS2 age#educ occup3_10 w_numer) cluster($clustervar)
	quietly estadd local fixedfsize "X", replace
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics " ", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker "X", replace


** ============================================================
** 5+ EMPLOYEES SAMPLE (separate dataset)
** ============================================================

use $path_clean_panel/2010-2019-regression-5ormore.dta, clear

** PANEL A

*A4. Table 4 col. 5 specification (5+ employees)
eststo s5_monthlywage4: reghdfe lreal_wage c.nHHI_3dig lfsize female native , noconstant absorb(year#industry fNUTS2 age#educ occup3_10) cluster($clustervar)
	quietly estadd local fixedfsize "X", replace
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker " ", replace

*A5. Table 4 col. 6 specification (5+ employees)
eststo s5_monthlywage5: reghdfe lreal_wage c.nHHI_3dig lfsize , noconstant absorb(year#industry fNUTS2 age#educ occup3_10 w_numer) cluster($clustervar)
	quietly estadd local fixedfsize "X", replace
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics " ", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker "X", replace

** PANEL B

*B4. Table 4 col. 5 specification (5+ employees)
eststo s5_hours4: reghdfe lreg_hours_month c.nHHI_3dig lfsize female native , noconstant absorb(year#industry fNUTS2 age#educ occup3_10) cluster($clustervar)
	quietly estadd local fixedfsize "X", replace
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker " ", replace

*B5. Table 4 col. 6 specification (5+ employees)
eststo s5_hours5: reghdfe lreg_hours_month c.nHHI_3dig lfsize , noconstant absorb(year#industry fNUTS2 age#educ occup3_10 w_numer) cluster($clustervar)
	quietly estadd local fixedfsize "X", replace
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics " ", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker "X", replace

** PANEL C

*C4. Table 4 col. 5 specification (5+ employees)
eststo s5_hourlywage4: reghdfe lreal_hrl_wage c.nHHI_3dig lfsize female native , noconstant absorb(year#industry fNUTS2 age#educ occup3_10) cluster($clustervar)
	quietly estadd local fixedfsize "X", replace
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker " ", replace

*C5. Table 4 col. 6 specification (5+ employees)
eststo s5_hourlywage5: reghdfe lreal_hrl_wage c.nHHI_3dig lfsize , noconstant absorb(year#industry fNUTS2 age#educ occup3_10 w_numer) cluster($clustervar)
	quietly estadd local fixedfsize "X", replace
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics " ", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker "X", replace

	quietly estadd local hline " ", replace


** ============================================================
** TABLE OUTPUT
** ============================================================

local tabtitle "Wage regression: HHI at 3-digit occupation — sample comparison (baseline, 50+, 5+ employees)."

* Panel A (log monthly earnings)

local tablabel "table_a05_panel_a_size_cutoffs_monthly_earnings"

esttab s50_monthlywage4 s50_monthlywage5 s5_monthlywage4 s5_monthlywage5 using $path_out_tab/`tablabel'.tex, ///
	keep(nHHI_3dig) ///
	star(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
	b(%9.3f) se(%9.3f) ///
	nomtitles ///
	prehead(  "" ) ///
	mgroups("50 employees or more" "5 employees or more", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
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


* Panel B (log total monthly hours)

local tablabel "table_a05_panel_b_size_cutoffs_monthly_hours"

esttab s50_hours4 s50_hours5 s5_hours4 s5_hours5 using $path_out_tab/`tablabel'.tex, ///
	keep(nHHI_3dig ) ///
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


* Panel C (log hourly wage)

local tablabel "table_a05_panel_c_size_cutoffs_hourly_wage"

esttab s50_hourlywage4 s50_hourlywage5 s5_hourlywage4 s5_hourlywage5 using $path_out_tab/`tablabel'.tex, ///
	keep(nHHI_3dig ) ///
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

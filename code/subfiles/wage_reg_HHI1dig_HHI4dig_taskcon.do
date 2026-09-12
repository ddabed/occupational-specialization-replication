*-------------------------------------------------------------------------
* wage_reg_HHI1dig_HHI4dig_taskcon.do -- Table 5, Panels A, B and C
*
* Repeats the two most demanding specifications of Table 4 (columns 5 and 6)
* using three alternative measures of firm specialization in place of the
* 3-digit HHI: the 1-digit HHI, the 4-digit HHI, and task concentration.
*
* Each measure is copied into a common variable name, `specialization', so
* that all six columns report on a single table row.
*   out: $path_out_tab/table_05_panel_a_alt_measures_monthly_earnings.tex
*        $path_out_tab/table_05_panel_b_alt_measures_monthly_hours.tex
*        $path_out_tab/table_05_panel_c_alt_measures_hourly_wage.tex
*-------------------------------------------------------------------------

eststo clear   // drop estimates stored by earlier do-files, so esttab cannot pick up a stale one
use $path_clean_panel/2010-2019-regression.dta, clear



	foreach measure in nHHI_1dig nHHI_4dig ntaskcon {
		gen specialization = `measure'
		
		foreach depvar in lreal_wage lreg_hours_month lreal_hrl_wage {
			eststo `measure'_`depvar'4: reghdfe `depvar' specialization lfsize female native , ///
				noconstant absorb(year#industry fNUTS2 age#educ occup3_10) cluster($clustervar)
					quietly estadd local fixedfsize "X", replace
					quietly estadd local fixedyear "X", replace
					quietly estadd local fixedind "X", replace
					quietly estadd local fixeddemographics "X", replace
					quietly estadd local fixedaeduc "X", replace
					quietly estadd local fixed1dig "X", replace
					quietly estadd local fixed3dig "X", replace
					quietly estadd local fixedworker " ", replace

			eststo `measure'_`depvar'5: reghdfe `depvar' specialization lfsize , ///
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
		drop specialization
	}
	
	


* Table output: Panel A (log monthly earnings)

local tabtitle "Wage regression: HHI at 1-digit, 4-digit, and task concentration."
local tablabel "table_05_panel_a_alt_measures_monthly_earnings"

esttab nHHI_1dig_lreal_wage4 nHHI_1dig_lreal_wage5 nHHI_4dig_lreal_wage4 nHHI_4dig_lreal_wage5 ntaskcon_lreal_wage4 ntaskcon_lreal_wage5 using $path_out_tab/`tablabel'.tex, ///
	keep(specialization) ///
	varlabels(specialization "Specialization measure") ///
	star(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
	b(%9.3f) se(%9.3f) ///
	nomtitles ///
	prehead(  "" ) ///
	mgroups("HHI 1-dig" "HHI 4-dig" "Task Concentration", ///
        pattern(1 0 1 0 1 0) ///
        prefix(\multicolumn{@span}{c}{) suffix(}) ///
        span erepeat(\cmidrule(lr){@span})) ///
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


* Table output: Panel B (log total monthly hours)

local tablabel "table_05_panel_b_alt_measures_monthly_hours"

esttab nHHI_1dig_lreg_hours_month4 nHHI_1dig_lreg_hours_month5 nHHI_4dig_lreg_hours_month4 nHHI_4dig_lreg_hours_month5 ntaskcon_lreg_hours_month4 ntaskcon_lreg_hours_month5 using $path_out_tab/`tablabel'.tex, ///
	keep(specialization) ///
	varlabels(specialization "Specialization measure") ///
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


* Table output: Panel C (log hourly wage)

local tablabel "table_05_panel_c_alt_measures_hourly_wage"

esttab nHHI_1dig_lreal_hrl_wage4 nHHI_1dig_lreal_hrl_wage5 nHHI_4dig_lreal_hrl_wage4 nHHI_4dig_lreal_hrl_wage5 ntaskcon_lreal_hrl_wage4 ntaskcon_lreal_hrl_wage5 using $path_out_tab/`tablabel'.tex, ///
	keep(specialization) ///
	varlabels(specialization "Specialization measure") ///
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

	
	

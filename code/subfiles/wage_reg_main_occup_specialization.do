

use $path_clean_panel/2010-2019-regression.dta, clear

*sample 5

rename share_1dig_max s1_max
rename share_3dig_max s3_max
rename share_4dig_max s4_max

label var s4_max "Share of the largest 4-digit occ."

	foreach measure in s1_max s3_max s4_max {
		
		gen share = `measure'
		label var share "Share largest occupation"
			
		foreach depvar in lreal_wage lreg_hours_month lreal_hrl_wage {
			eststo `measure'_`depvar'4: reghdfe `depvar' share lfsize female native , ///
				noconstant absorb(year#industry fNUTS2 age#educ occup3_10) cluster($clustervar)
					quietly estadd local fixedfsize "X", replace
					quietly estadd local fixedyear "X", replace
					quietly estadd local fixedind "X", replace
					quietly estadd local fixeddemographics "X", replace
					quietly estadd local fixedaeduc "X", replace
					quietly estadd local fixed1dig "X", replace
					quietly estadd local fixed3dig "X", replace
					quietly estadd local fixedworker " ", replace

			eststo `measure'_`depvar'5: reghdfe `depvar' share lfsize , ///
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
		drop share
	}
	
	


/// Table Output: Panel A (Monthly earnings)

*local tabtitle "Wage regression: HHI at 1-digit, 4-digit, and task concentration."
local tablabel "table_a04_panel_a_largest_occupation_monthly_earnings"

esttab s4_max_lreal_wage4 s4_max_lreal_wage5 s3_max_lreal_wage4 s3_max_lreal_wage5 s1_max_lreal_wage4 s1_max_lreal_wage5 using $path_out_tab/`tablabel'.tex, ///
	keep(share) ///
	varlabels(share "Share largest occupation") ///
	star(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
	b(%9.3f) se(%9.3f) ///
	nomtitles ///
	prehead(  "" ) ///
	mgroups("4-digit occupation" "3-digit occupation" "1-digit occupation", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
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


/// Table Output: Panel B (Monthly hours)

local tablabel "table_a04_panel_b_largest_occupation_monthly_hours"

esttab s4_max_lreg_hours_month4 s4_max_lreg_hours_month5 s3_max_lreg_hours_month4 s3_max_lreg_hours_month5 s1_max_lreg_hours_month4 s1_max_lreg_hours_month5 using $path_out_tab/`tablabel'.tex, ///
	keep(share) ///
	varlabels(share "Share largest occupation") ///
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


/// Table Output: Panel C (Hourly wage)

local tablabel "table_a04_panel_c_largest_occupation_hourly_wage"

esttab s4_max_lreal_hrl_wage4 s4_max_lreal_hrl_wage5 s3_max_lreal_hrl_wage4 s3_max_lreal_hrl_wage5 s1_max_lreal_hrl_wage4 s1_max_lreal_hrl_wage5 using $path_out_tab/`tablabel'.tex, ///
	keep(share) ///
	varlabels(share "Share largest occupation") ///
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

	









use $path_clean_panel/2010-2019-regression.dta, clear


label var nHHI_3dig "HHI 3-digit"


	foreach depvar in lreal_wage lreg_hours_month lreal_hrl_wage {
			
			eststo reg_`depvar'4: reghdfe `depvar' nHHI_3dig lfsize female native , ///
				noconstant absorb(year#industry fNUTS2 age#educ occup3_10) cluster($clustervar)
					quietly estadd local fixedfsize "X", replace
					quietly estadd local fixedyear "X", replace
					quietly estadd local fixedind "X", replace
					quietly estadd local fixeddemographics "X", replace
					quietly estadd local fixedaeduc "X", replace
					quietly estadd local fixed1dig "X", replace
					quietly estadd local fixed3dig "X", replace
					quietly estadd local fixedworker " ", replace
					quietly estadd local fixedworkerocc3 " ", replace
			

			eststo reg_`depvar'5: reghdfe `depvar' nHHI_3dig lfsize , ///
				noconstant absorb(year#industry fNUTS2 age#educ occup3_10 w_numer) cluster($clustervar)
					quietly estadd local fixedfsize "X", replace
					quietly estadd local fixedyear "X", replace
					quietly estadd local fixedind "X", replace
					quietly estadd local fixeddemographics " ", replace
					quietly estadd local fixedaeduc "X", replace
					quietly estadd local fixed1dig "X", replace
					quietly estadd local fixed3dig "X", replace
					quietly estadd local fixedworker "X", replace
					quietly estadd local fixedworkerocc3 " ", replace
					
			eststo reg_`depvar'6: reghdfe `depvar' nHHI_3dig lfsize , ///
				noconstant absorb(year#industry fNUTS2 age#educ w_numer#occup3_10) cluster($clustervar)
					quietly estadd local fixedfsize "X", replace
					quietly estadd local fixedyear "X", replace
					quietly estadd local fixedind "X", replace
					quietly estadd local fixeddemographics " ", replace
					quietly estadd local fixedaeduc "X", replace
					quietly estadd local fixed1dig "X", replace
					quietly estadd local fixed3dig "X", replace
					quietly estadd local fixedworker "X", replace
					quietly estadd local fixedworkerocc3 "X", replace
		

	}
	
	


/// Table Output: Panel A (Monthly earnings)

local tabtitle "Wage regression: baseline regression and worker $\times$ occupation FE"
local tablabel "table_a07_panel_a_alt_fixed_effects_monthly_earnings"

esttab reg_lreal_wage4 reg_lreal_wage5 reg_lreal_wage6 using $path_out_tab/`tablabel'.tex, ///
	keep(nHHI_3dig) ///
	star(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
	b(%9.3f) se(%9.3f) ///
	nomtitles ///
	prehead(  "" ) ///
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

local tablabel "table_a07_panel_b_alt_fixed_effects_monthly_hours"

esttab reg_lreg_hours_month4 reg_lreg_hours_month5 reg_lreg_hours_month6 using $path_out_tab/`tablabel'.tex, ///
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


/// Table Output: Panel C (Hourly wage)

local tablabel "table_a07_panel_c_alt_fixed_effects_hourly_wage"

esttab reg_lreal_hrl_wage4 reg_lreal_hrl_wage5 reg_lreal_hrl_wage6 using $path_out_tab/`tablabel'.tex, ///
	keep(nHHI_3dig) ///
	star(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
	b(%9.3f) se(%9.3f) ///
	nomtitles ///
	prehead("\\" "\multicolumn{@span}{l}{\textbf{C. Dependent variable:  Log hourly wage}} \vspace{0.5cm}  \\"  ) ///
	postfoot("\bottomrule" ) ///
	posthead("") ///
	s(r2 hline fixedfsize fixedyear fixedaeduc fixed1dig fixed3dig fixedind fixedworker fixedworkerocc3 N, fmt(%9.2fc %9s %9s %9s %9s %9s %9s %9s %9s %9s %12.2gc ) label("$\text{R}^2$" "\midrule" "Firm size" "Year and region FE" "Demographic controls"  "1-dig occupation FE" "3-dig occupation FE" "4-dig ind. $\times$ year FE" "Worker FE" "Worker $\times$ 3-dig occupation FE" "N" )) ///
	style(tex) ///
	label ///
	booktabs ///
	nonotes ///
	noobs ///
	nonumbers ///
	fragment ///
	replace

	
	

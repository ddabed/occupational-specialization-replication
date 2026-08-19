
use $path_clean_panel/2010-2019-regression.dta, clear

label var nHHI_3dig "HHI 3-digit"

///// TABLE, 3 PANELS

** PANEL A: Monthly Base Wage as Dependent Variable

*A0. dep var: monthly wage; HHI worker controls no firm size
eststo HHI_3dig_monthlywage0: reghdfe lreal_wage c.nHHI_3dig female native , noconstant absorb(year fNUTS2 age#educ) cluster($clustervar)
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind " ", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig " ", replace
	quietly estadd local fixed3dig " ", replace
	quietly estadd local fixedworker " ", replace


*A1. 1 + firm size
eststo HHI_3dig_monthlywage1:reghdfe lreal_wage c.nHHI_3dig lfsize female native , noconstant absorb(year fNUTS2 age#educ) cluster($clustervar)
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind " ", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig " ", replace
	quietly estadd local fixed3dig " ", replace
	quietly estadd local fixedworker " ", replace
	

*A2. 1.1 + 1 digit isco FE
eststo HHI_3dig_monthlywage2:reghdfe lreal_wage c.nHHI_3dig lfsize female native , noconstant absorb(year fNUTS2 age#educ occup1_10) cluster($clustervar)
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind " ", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig " ", replace
	quietly estadd local fixedworker " ", replace
	 

*A3. 1.2 - 1 digit isco FE + 3 digit isco FE
eststo HHI_3dig_monthlywage3:reghdfe lreal_wage c.nHHI_3dig lfsize female native , noconstant absorb(year fNUTS2 age#educ occup3_10) cluster($clustervar)
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind " ", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker " ", replace

	
*A4. 1.3 + industry fixed effect
eststo HHI_3dig_monthlywage4:reghdfe lreal_wage c.nHHI_3dig lfsize female native , noconstant absorb(year#industry fNUTS2 age#educ occup3_10) cluster($clustervar)
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker " ", replace
	 

*A5. 1.4 + worker FE
eststo HHI_3dig_monthlywage5:reghdfe lreal_wage c.nHHI_3dig lfsize , noconstant absorb(year#industry fNUTS2 age#educ occup3_10 w_numer) cluster($clustervar)
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics " ", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker "X", replace
	
	
	
	
** PANEL B: Total monthly hours

*B0. dep var: monthly hours wage; HHI worker controls no firm size
eststo HHI_3dig_hours0: reghdfe lreg_hours_month c.nHHI_3dig female native , noconstant absorb(year fNUTS2 age#educ) cluster($clustervar)
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind " ", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig " ", replace
	quietly estadd local fixed3dig " ", replace
	quietly estadd local fixedworker " ", replace


*B1. 1 + firm size
eststo HHI_3dig_hours1:reghdfe lreg_hours_month c.nHHI_3dig lfsize female native , noconstant absorb(year fNUTS2 age#educ) cluster($clustervar)
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind " ", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig " ", replace
	quietly estadd local fixed3dig " ", replace
	quietly estadd local fixedworker " ", replace
	 

*B2. 1.1 + 1 digit isco FE
eststo HHI_3dig_hours2:reghdfe lreg_hours_month c.nHHI_3dig lfsize female native , noconstant absorb(year fNUTS2 age#educ occup1_10) cluster($clustervar)
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind " ", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig " ", replace
	quietly estadd local fixedworker " ", replace
	 

	
*B3. 1.2 - 1 digit isco FE + 3 digit isco FE
eststo HHI_3dig_hours3:reghdfe lreg_hours_month c.nHHI_3dig lfsize female native , noconstant absorb(year fNUTS2 age#educ occup3_10) cluster($clustervar)
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind " ", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker " ", replace
	

*B4. 1.3 + industry fixed effect
eststo HHI_3dig_hours4:reghdfe lreg_hours_month c.nHHI_3dig lfsize female native , noconstant absorb(year#industry fNUTS2 age#educ occup3_10) cluster($clustervar)
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker " ", replace
	 

*B5. 1.4 + worker FE
eststo HHI_3dig_hours5:reghdfe lreg_hours_month c.nHHI_3dig lfsize , noconstant absorb(year#industry fNUTS2 age#educ occup3_10 w_numer) cluster($clustervar)
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics " ", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker "X", replace
	
	

** PANEL C: real hourly wage

*C0. dep var: real hourly wagee; HHI worker controls no firm size
eststo HHI_3dig_hourlywage0: reghdfe lreal_hrl_wage c.nHHI_3dig female native , noconstant absorb(year fNUTS2 age#educ) cluster($clustervar)
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind " ", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig " ", replace
	quietly estadd local fixed3dig " ", replace
	quietly estadd local fixedworker " ", replace


*C1. 1 + firm size
eststo HHI_3dig_hourlywage1:reghdfe lreal_hrl_wage c.nHHI_3dig lfsize female native , noconstant absorb(year fNUTS2 age#educ) cluster($clustervar)
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind " ", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig " ", replace
	quietly estadd local fixed3dig " ", replace
	quietly estadd local fixedworker " ", replace


*C2. 1.1 + 1 digit isco FE
eststo HHI_3dig_hourlywage2:reghdfe lreal_hrl_wage c.nHHI_3dig lfsize female native , noconstant absorb(year fNUTS2 age#educ occup1_10) cluster($clustervar)
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind " ", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig " ", replace
	quietly estadd local fixedworker " ", replace
	 

	
*C3. 1.2 - 1 digit isco FE + 3 digit isco FE
eststo HHI_3dig_hourlywage3:reghdfe lreal_hrl_wage c.nHHI_3dig lfsize female native , noconstant absorb(year fNUTS2 age#educ occup3_10) cluster($clustervar)
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind " ", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker " ", replace
	 

*C4. 1.3 + industry fixed effect
eststo HHI_3dig_hourlywage4:reghdfe lreal_hrl_wage c.nHHI_3dig lfsize female native , noconstant absorb(year#industry fNUTS2 age#educ occup3_10) cluster($clustervar)
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker " ", replace
	 

*C5. 1.4 + worker FE
eststo HHI_3dig_hourlywage5:reghdfe lreal_hrl_wage c.nHHI_3dig lfsize , noconstant absorb(year#industry fNUTS2 age#educ occup3_10 w_numer) cluster($clustervar)
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics " ", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker "X", replace
	
	
	quietly estadd local hline " ", replace
	
			
		

/// Table Label, File Name and Title

local tabtitle "Wage regression: HHI at 3 digit occupation."
local tablabel "table_04_panel_a_monthly_earnings"

esttab HHI_3dig_monthlywage0 HHI_3dig_monthlywage1 HHI_3dig_monthlywage2 HHI_3dig_monthlywage3 HHI_3dig_monthlywage4 HHI_3dig_monthlywage5 using $path_out_tab/`tablabel'.tex, ///
	keep(nHHI_3dig lfsize) ///
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
	

	
local tablabel "table_04_panel_b_monthly_hours"
	
esttab HHI_3dig_hours0 HHI_3dig_hours1 HHI_3dig_hours2 HHI_3dig_hours3 HHI_3dig_hours4 HHI_3dig_hours5 using $path_out_tab/`tablabel'.tex, ///
	keep(nHHI_3dig lfsize) ///
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
	
local tablabel "table_04_panel_c_hourly_wage"
	
esttab HHI_3dig_hourlywage0 HHI_3dig_hourlywage1 HHI_3dig_hourlywage2 HHI_3dig_hourlywage3 HHI_3dig_hourlywage4 HHI_3dig_hourlywage5 using $path_out_tab/`tablabel'.tex, ///
	keep(nHHI_3dig lfsize) ///
	star(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
	b(%9.3f) se(%9.3f) ///
	nomtitles ///
	prehead("\\" "\multicolumn{@span}{l}{\textbf{C. Dependent variable:  Log hourly wage}} \vspace{0.5cm}  \\"  ) ///
	postfoot("\bottomrule" ) ///
	posthead("") ///
	s(r2 hline fixedyear fixedaeduc fixed1dig fixed3dig fixedind fixedworker N, fmt(%9.2fc %9s %9s %9s %9s %9s %9s %12.2gc ) label("$\text{R}^2$" "\midrule" "Year and region FE" "Demographic controls"  "1-dig occupation FE" "3-dig occupation FE" "4-dig ind. $\times$ year FE" "Worker FE" "N" )) ///
	style(tex) ///
	label ///
	booktabs ///
	nonotes ///
	noobs ///
	nonumbers ///
	fragment ///
	replace
			
		


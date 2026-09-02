eststo clear   // drop estimates stored by earlier do-files, so esttab cannot pick up a stale one


use $path_clean_panel/2010-2019-regression.dta, clear

label var nHHI_3dig "HHI 3-dig"

*1.2. 1.1 + industry fixed effect


eststo HHI_3dig_2:reghdfe lreal_hrl_wage c.nHHI_3dig#i.occup1_10 female native lfsize, noconstant absorb(year#industry fNUTS2 age#educ occup1_10) cluster($clustervar)
	quietly estadd local fixedfsize "X", replace
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind " ", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig " ", replace
	quietly estadd local fixedworker " ", replace
	 

	
*1.4. 1.2 + 3 digit isco FE


eststo HHI_3dig_4:reghdfe lreal_hrl_wage c.nHHI_3dig#i.occup1_10 female native lfsize, noconstant absorb(year#industry fNUTS2 age#educ occup3_10) cluster($clustervar)
	quietly estadd local fixedfsize "X", replace
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker " ", replace
	 

*1.5. 1.4 + worker FE

eststo HHI_3dig_5:reghdfe lreal_hrl_wage c.nHHI_3dig#i.occup1_10 lfsize, noconstant absorb(year#industry fNUTS2 age#educ occup3_10 w_numer) cluster($clustervar)
	quietly estadd local fixedfsize "X", replace
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics " ", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker "X", replace
	
	
/// Table Label, File Name and Title

local tabtitle "Wage regression: Norm. HHI at 3 digit occupation interacted with occupation."
local tablabel "table_a08_heterogeneity_occupation"


esttab HHI_3dig_2 HHI_3dig_4 HHI_3dig_5 using $path_out_tab/`tablabel'.tex, ///
	drop(female native lfsize) ///
	star(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
	b(%9.3f) se(%9.3f) ///
	s(fixedfsize fixedyear fixedaeduc fixed1dig fixed3dig fixedind fixedworker N r2, fmt(%9s %9s %9s %9s %9s %9s %9s %12.2gc %9.2fc) label("Firm size" "Year and region FE" "Demographic controls"  "1-dig occupation FE" "3-dig occupation FE" "4-dig ind. $\times$ year FE" "Worker FE" "N" "$\text{R}^2$")) ///
	mgroups("\makecell{Dependent variable: \\ Log hourly wage}", prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	prehead("\begin{tabularx}{\textwidth}{l*{@M}{Y}}" "\toprule") ///
	posthead("\midrule") ///
	prefoot("\midrule") ///
	postfoot("\bottomrule" "\end{tabularx}") ///
	style(tex) ///
	label ///
	booktabs ///
	nomtitles ///
	nonotes ///
	replace



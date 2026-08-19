

use $path_clean_panel/2010-2019-regression.dta, clear

label var nHHI_3dig "HHI 3-digit"

replace fEAC_1let_rev3 = "Mining and quarrying" if fEAC_1let_rev3 == "B"
replace fEAC_1let_rev3 = "Manufacturing" if fEAC_1let_rev3 == "C"
replace fEAC_1let_rev3 = "Electricity, gas, steam and air cond. supply" if fEAC_1let_rev3 == "D"
replace fEAC_1let_rev3 = "Water supply; sewerage, waste managment " if fEAC_1let_rev3 == "E"
replace fEAC_1let_rev3 = "Construction" if fEAC_1let_rev3 == "F"
replace fEAC_1let_rev3 = "Wholesale and retail trade" if fEAC_1let_rev3 == "G"
replace fEAC_1let_rev3 = "Transportation and storage" if fEAC_1let_rev3 == "H"
replace fEAC_1let_rev3 = "Accommodation and food service act." if fEAC_1let_rev3 == "I"
replace fEAC_1let_rev3 = "Information and communication" if fEAC_1let_rev3 == "J"
replace fEAC_1let_rev3 = "Financial and insurance act." if fEAC_1let_rev3 == "K"
replace fEAC_1let_rev3 = "Real estate act." if fEAC_1let_rev3 == "L"
replace fEAC_1let_rev3 = "Professional, scientific and technical act." if fEAC_1let_rev3 == "M"
replace fEAC_1let_rev3 = "Administrative and support service activities" if fEAC_1let_rev3 == "N"
replace fEAC_1let_rev3 = "Public administration and defense" if fEAC_1let_rev3 == "O"
replace fEAC_1let_rev3 = "Education" if fEAC_1let_rev3 == "P"
replace fEAC_1let_rev3 = "Human health and social work act." if fEAC_1let_rev3 == "Q"
replace fEAC_1let_rev3 = "Arts, entertainment and recreation" if fEAC_1let_rev3 == "R"
replace fEAC_1let_rev3 = "Other service activities" if fEAC_1let_rev3 == "S"
replace fEAC_1let_rev3 = "Activities of households as employers" if fEAC_1let_rev3 == "T"
replace fEAC_1let_rev3 = "Act. of extraterritorial organisations" if fEAC_1let_rev3 == "U"
	
encode fEAC_1let_rev3, gen(ind_1dig)

label var ind_1dig "1-let. industry"


*1.2. 1.1 + industry fixed effect


eststo HHI_1dig_2:reghdfe lreal_hrl_wage c.nHHI_3dig#i.ind_1dig female native lfsize, noconstant absorb(year#industry fNUTS2 age#educ occup1_10) cluster($clustervar)
	quietly estadd local fixedfsize "X", replace
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind " ", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig " ", replace
	quietly estadd local fixedworker " ", replace
	 

	
*1.4. 1.2 + 3 digit isco FE


eststo HHI_1dig_4:reghdfe lreal_hrl_wage c.nHHI_3dig#i.ind_1dig female native lfsize, noconstant absorb(year#industry fNUTS2 age#educ occup3_10) cluster($clustervar)
	quietly estadd local fixedfsize "X", replace
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker " ", replace
	 
	 

*1.5. 1.4 + worker FE

eststo HHI_1dig_5:reghdfe lreal_hrl_wage c.nHHI_3dig#i.ind_1dig lfsize, noconstant absorb(year#industry fNUTS2 age#educ occup3_10 w_numer) cluster($clustervar)
	quietly estadd local fixedfsize "X", replace
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics " ", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker "X", replace
	 
/// Table Label, File Name and Title

local tabtitle "Wage regression: HHI at 3 digit occupation interacted with industry."
local tablabel "table_a09_heterogeneity_industry"


esttab HHI_1dig_2 HHI_1dig_4 HHI_1dig_5 using $path_out_tab/`tablabel'.tex, ///
	drop(female native lfsize) ///
	star(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
	b(%9.3f) se(%9.3f) ///
	s(fixedfsize fixedyear fixedaeduc fixed1dig fixed3dig fixedind fixedworker N r2, fmt(%9s %9s %9s %9s %9s %9s %9s %12.2gc %9.2fc) label("Firm size" "Year and region FE" "Demographic controls"  "1-dig occupation FE" "3-dig occupation FE" "4-dig ind. $\times$ year FE" "Worker FE" "N" "$\text{R}^2$")) ///
	prehead("\begin{tabularx}{\textwidth}{l >{\hsize=5\hsize}Y >{\hsize=5\hsize}Y >{\hsize=5\hsize}Y}" "\cmidrule[0.05cm](lr){1-4}") ///
	mgroups("Dependent variable: Log hourly wage", prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	posthead("\cmidrule(lr){1-4}") ///
	prefoot("\cmidrule(lr){1-4}") ///
	postfoot("\cmidrule[0.05cm](lr){1-4}" "\end{tabularx}") ///
	style(tex) ///
	label ///
	booktabs ///
	nomtitles ///
	nonotes ///
	replace
	


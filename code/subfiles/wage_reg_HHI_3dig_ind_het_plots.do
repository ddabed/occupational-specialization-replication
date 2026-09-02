eststo clear   // drop estimates stored by earlier do-files, so esttab cannot pick up a stale one

use $path_clean_panel/2010-2019-regression.dta, clear

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
	
	
///// Regressions


*C. Hourly wage

eststo HHI_1dig_hourlywage: reghdfe lreal_hrl_wage c.nHHI_3dig#i.ind_1dig lfsize, noconstant absorb(year#industry fNUTS2 age#educ occup3_10 w_numer) cluster($clustervar)

matrix b = e(b)
matrix V = e(V)
matrix list b
matrix list V

// Calculate confidence intervals
local n = _N
local level = 95
local z = invttail(`n' - 1, (100 - `level') / 200)

matrix ci = J(20,3, .)
matrix colnames ci = coef lower upper
forvalues i = 1/20{
    matrix ci[`i', 1] = b[1, `i']
    matrix ci[`i', 2] = b[1, `i'] - `z' * sqrt(V[`i', `i'])
    matrix ci[`i', 3] = b[1, `i'] + `z' * sqrt(V[`i', `i'])
}


matrix list ci

gen interaction_b = .
gen interaction_ci_lb = .
gen interaction_ci_ub = .

 forvalues i = 1/20{
	local interaction_coef`i' = ci[`i',1]
	local ci_lb`i' = ci[`i',2]
	local ci_ub`i' = ci[`i',3]
	
	gen interaction_coef_var`i' = `interaction_coef`i'' if ind_1dig == `i'
	gen ci_lb`i' = `ci_lb`i'' if ind_1dig == `i'
	gen ci_ub`i' = `ci_ub`i'' if ind_1dig == `i'
	
	replace interaction_b =  interaction_coef_var`i' if ind_1dig == `i'
	replace interaction_ci_lb =  ci_lb`i' if ind_1dig == `i'
	replace interaction_ci_ub =  ci_ub`i' if ind_1dig == `i'
	
} 	

	drop interaction_coef* ci_lb* ci_ub*

	
	
// Coefplot

bysort ind_1dig: gegen ind_mean_lhrly_wage = mean(lreal_hrl_wage)


gcollapse (first) ind_mean_lhrly_wage interaction_b interaction_ci_lb interaction_ci_ub (count) number = w_numer (sum) reg_hours_month, by(ind_1dig) fast



rename interaction_b ind1xhhi_hrlwage 

compress

// Save collapsed panel to work locally later	
save $path_clean_int/indhetplots_collapsed, replace


label var ind1xhhi_hrlwage "Industry X Norm. HHI 3-digit"
label var ind_mean_lhrly_wage "Industry mean log hourly wage"



//ind1 Employment weight
gegen totemp = sum(number)
gen indweight = number / totemp 
	
	//consistency check
	gegen test = sum(indweight)
	assert test > 0.99999 & test < 1.00001
	drop test 
	


//Ind1 Employment weight in hours worked
gegen tothoursworked = sum(reg_hours_month)
gen indweight_hours = reg_hours_month / tothoursworked 

	//consistency check
	gegen test = sum(indweight_hours)
	assert test > 0.99999 & test < 1.00001
	drop test 

	
twoway  (rcap interaction_ci_lb interaction_ci_ub ind_mean_lhrly_wage, lstyle(ci)) || ///
		(scatter ind1xhhi_hrlwage ind_mean_lhrly_wage [aweight=indweight_hours], msymbol(circle_hollow)) (lfit ind1xhhi_hrlwage ind_mean_lhrly_wage [aweight = indweight_hours]), ///
		ylabel(-.2(0.05).15) /// 
		yline(0, lcolor(grey)) legend(off) scheme(cleanplots)  ytitle("Coeff. HHI 3-dig x 1-dig. Industry")	///
		play($path_do_sub/ind_het_plots_manuallabels)
	
		
graph export $path_out_fig/figure_02_panel_b_heterogeneity_industry.pdf, replace
		
	
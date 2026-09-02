eststo clear   // drop estimates stored by earlier do-files, so esttab cannot pick up a stale one


use $path_clean_panel/2010-2019-regression.dta, clear


///// Regression


*C. Hourly wage regression

eststo HHI_1dig_hourlywage:reghdfe lreal_hrl_wage c.nHHI_3dig#i.occup1_10 lfsize, noconstant absorb(year#industry age#educ occup3_10 w_numer) cluster($clustervar)
matrix b = e(b)
matrix V = e(V)
matrix list b
matrix list V

// Calculate confidence intervals
local n = _N
local level = 95
local z = invttail(`n' - 1, (100 - `level') / 200)

matrix ci = J(9,3, .)
matrix colnames ci = coef lower upper
foreach i in 1 2 3 4 5 6 7 8 {
    matrix ci[`i', 1] = b[1, `i']
    matrix ci[`i', 2] = b[1, `i'] - `z' * sqrt(V[`i', `i'])
    matrix ci[`i', 3] = b[1, `i'] + `z' * sqrt(V[`i', `i'])
}


matrix list ci

gen interaction_b = .
gen interaction_ci_lb = .
gen interaction_ci_ub = .

foreach i in 1 2 3 4 5 6 7 8{
	local interaction_coef`i' = ci[`i',1]
	local ci_lb`i' = ci[`i',2]
	local ci_ub`i' = ci[`i',3]
	
	if `i' <= 5{
		gen interaction_coef_var`i' = `interaction_coef`i'' if occup1 == `i'
		gen ci_lb`i' = `ci_lb`i'' if occup1 == `i'
		gen ci_ub`i' = `ci_ub`i'' if occup1 == `i'
	}
	
	if `i' >= 6{
		gen interaction_coef_var`i' = `interaction_coef`i'' if occup1 == `i' + 1
		gen ci_lb`i' = `ci_lb`i'' if occup1 == `i' + 1
		gen ci_ub`i' = `ci_ub`i'' if occup1 == `i' + 1
	}
	
	if `i' <= 5{
		replace interaction_b =  interaction_coef_var`i' if occup1 == `i' 
		replace interaction_ci_lb =  ci_lb`i' if occup1 == `i' 
		replace interaction_ci_ub =  ci_ub`i' if occup1 == `i' 
	}
	
	if `i' >= 6{
		replace interaction_b =  interaction_coef_var`i' if occup1 == `i' + 1
		replace interaction_ci_lb =  ci_lb`i' if occup1 == `i' + 1
		replace interaction_ci_ub =  ci_ub`i' if occup1 == `i' + 1
	} 
} 	

	drop interaction_coef* ci_lb* ci_ub*

	

// Coefplot

bysort occup1_10: gegen occ1_mean_hrly_wage = mean(lreal_hrl_wage)

gcollapse (first) occ1_mean_hrly_wage interaction_b interaction_ci_lb interaction_ci_ub (count) number = w_numer (sum) reg_hours_month, by(occup1_10) fast


// Save collapsed panel to work locally later	
compress
save $path_clean_int/occhetplots_coef, replace


rename interaction_b occ1xhhi_hrlwage 

label var occ1xhhi_hrlwage "Occ. 1-dig X Norm. HHI 3-digit"
label var occ1_mean_hrly_wage "Occupation mean log hourly wage"

//Occ1 Employment weight
gegen totemp = sum(number)
gen occweight = number / totemp 
	
	//consistency check
	gegen test = sum(occweight)
	assert test > 0.99999 & test < 1.00001
	drop test 
	
// Avoid label overprinting	
generate pos = 3
	replace pos = 9 if occup1 == 1 // managers
	replace pos = 3 if occup1 == 9 // elementary occ
	replace pos = 6 if occup1 == 7 // craft and trade
	replace pos = 3 if occup1 == 8 // plant operators
	replace pos = 3 if occup1 == 5 // service and sales
	replace pos = 2 if occup1 == 4 // clerical

	
// Weight by hoursworked (instead of employment counts)

//Occ1 Employment weight in hours worked
gegen tothoursworked = sum(reg_hours_month)
gen occweight_hours = reg_hours_month / tothoursworked 

	//consistency check
	gegen test = sum(occweight_hours)
	assert test > 0.99999 & test < 1.00001
	drop test 


twoway  (rcap interaction_ci_lb interaction_ci_ub occ1_mean_hrly_wage, lstyle(ci)) || ///
		(scatter occ1xhhi_hrlwage occ1_mean_hrly_wage [aweight=occweight_hours], msymbol(circle_hollow)) (lfit occ1xhhi_hrlwage occ1_mean_hrly_wage [aweight = occweight_hours]) || ///
		(scatter occ1xhhi_hrlwage occ1_mean_hrly_wage, mlabcol(black)  mlabv(pos) msym(i) mlabel(occup1_10)), ///
		xlabel(1.2(0.2)2.8) /// 
		ylabel(-.1(0.02).02) /// 
		yline(0, lcolor(grey)) legend(off) scheme(cleanplots) ytitle("Coeff. Norm. HHI 3-dig x 1-dig. Occupation")


graph export $path_out_fig/figure_02_panel_a_heterogeneity_occupation.pdf, replace



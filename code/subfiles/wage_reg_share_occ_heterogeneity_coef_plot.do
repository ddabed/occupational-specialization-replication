

	
*--------------------------------------------------------------
* Run each model, store b/lb/ub into row 1 (largest) and row 2 (other)
*--------------------------------------------------------------
use $path_clean_panel/2010-2019-regression.dta, clear

*=======================
* Setup / variables
*=======================
* Largest / smallest 3-digit occupation within firm-year
bysort fnumber_FIC year: egen maxshare = max(share_3dig)
bysort fnumber_FIC year: egen minshare = min(share_3dig)

gen byte maxshare_dummy = (share_3dig == maxshare)
gen byte minshare_dummy = (share_3dig == minshare)

label var maxshare_dummy "Largest 3-digit occ."
label var minshare_dummy "Smallest 3-digit occ."
label var maxshare       "Share largest 3-digit occ."

*=======================
* Estimate models & store results
*=======================

* -------- Model 1: No worker FE --------
eststo reg1: reghdfe lreal_hrl_wage c.maxshare##maxshare_dummy female native lfsize, ///
    noconstant absorb(year#industry fNUTS2 age#educ occup3_10) cluster($clustervar)

xlincom c.maxshare, post
	matrix b1_1 = e(b)
	matrix V1_1 = e(V)

est restore reg1
xlincom c.maxshare + 1.maxshare_dummy#c.maxshare, post
	matrix b2_1 = e(b)
	matrix V2_1 = e(V)

* -------- Model 2: With worker FE --------
eststo reg2: reghdfe lreal_hrl_wage c.maxshare##maxshare_dummy lfsize, ///
    noconstant absorb(year#industry fNUTS2 age#educ occup3_10 w_numer) cluster($clustervar)

xlincom c.maxshare, post
	matrix b1_2 = e(b)
	matrix V1_2 = e(V)
	
est restore reg2
xlincom c.maxshare + 1.maxshare_dummy#c.maxshare, post
	matrix b2_2 = e(b)
	matrix V2_2 = e(V)

forvalues i = 1/2 {
	matrix list b`i'_1
	matrix list V`i'_1
	
	matrix list b`i'_2
	matrix list V`i'_2
}


// Calculate confidence intervals
local n = _N
local level = 95
local z = invttail(`n' - 1, (100 - `level') / 200)

matrix ci_1 = J(2,3, .)
matrix colnames ci_1 = coef lower upper

matrix ci_2 = J(2,3, .)
matrix colnames ci_2= coef lower upper


foreach i in 1 2 {
	
	//no worker FE
    matrix ci_1[`i', 1] = b`i'_1[1, 1]
    matrix ci_1[`i', 2] = b`i'_1[1, 1] - `z' * sqrt(V`i'_1[1,1])
    matrix ci_1[`i', 3] = b`i'_1[1, 1] + `z' * sqrt(V`i'_1[1,1])
	
 	matrix ci_2[`i', 1] = b`i'_2[1, 1]
    matrix ci_2[`i', 2] = b`i'_2[1, 1] - `z' * sqrt(V`i'_2[1,1])
    matrix ci_2[`i', 3] = b`i'_2[1, 1] + `z' * sqrt(V`i'_2[1,1])
}

matrix list ci_1
matrix list ci_2

preserve 
clear	
set obs 2 

gen byte maxshare_dummy = (_n==1)

foreach i in 1 2 {
	gen interaction_b_`i' = .
	gen interaction_ci_lb_`i' = .
	gen interaction_ci_ub_`i' = .
}

// coeff. and ci estimation model without worker FE
foreach i in 1 2 {
		local interaction_coef`i'_1 = ci_1[`i',1]
		local ci_lb`i'_1 = ci_1[`i',2]
		local ci_ub`i'_1 = ci_1[`i',3]

		gen interaction_coef_var`i'_1 = `interaction_coef`i'_1' if maxshare_dummy == `i' - 1
		gen ci_lb`i'_1 = `ci_lb`i'_1' if maxshare_dummy == `i' - 1
		gen ci_ub`i'_1 = `ci_ub`i'_1' if maxshare_dummy == `i' - 1

		replace interaction_b_1 = interaction_coef_var`i'_1 if  maxshare_dummy == `i' - 1
		replace interaction_ci_lb_1 =  ci_lb`i'_1 if  maxshare_dummy == `i' - 1
		replace interaction_ci_ub_1 =  ci_ub`i'_1 if  maxshare_dummy == `i' - 1
}

// coeff. and ci estimation model with worker FE
foreach i in 1 2 {
		local interaction_coef`i'_2 = ci_2[`i',1]
		local ci_lb`i'_2 = ci_2[`i',2]
		local ci_ub`i'_2 = ci_2[`i',3]
		

		gen interaction_coef_var`i'_2 = `interaction_coef`i'_2' if maxshare_dummy == `i' - 1
		gen ci_lb`i'_2 = `ci_lb`i'_2' if maxshare_dummy == `i' - 1
		gen ci_ub`i'_2 = `ci_ub`i'_2' if maxshare_dummy == `i' - 1

		replace interaction_b_2 = interaction_coef_var`i'_2 if  maxshare_dummy == `i' - 1
		replace interaction_ci_lb_2 =  ci_lb`i'_2 if  maxshare_dummy == `i' - 1
		replace interaction_ci_ub_2 =  ci_ub`i'_2 if  maxshare_dummy == `i' - 1
}


compress
save $path_clean_int/pay-transparency-plotprep, replace
restore



*----------------------------------------------------------
* Make graph
*----------------------------------------------------------

use $path_clean_int/pay-transparency-plotprep, clear

gcollapse (mean) interaction_b* interaction_ci_lb* interaction_ci_ub*, by(maxshare_dummy) fast

// in order to have the large occupation first
gen locc_dum = 0 if maxshare_dummy == 1
replace locc_dum = 1 if maxshare_dummy == 0
	
label define locc_dum_l0  0 "Largest Occupation in the Firm" 1 "Other Occupations in the Firm" 
label value locc_dum locc_dum_l0

reshape long interaction_b_  interaction_ci_lb_ interaction_ci_ub_, i(maxshare_dummy) j(model)
rename *_* *

label define locc_dum_l0 1 "Other Occupations", modify
label define model 1 "Without Worker Fixed Effects"
label define model 2 "With Worker Fixed Effects", modify
label values model model

twoway (scatter interaction_b locc if locc==0, by(model, note("") legend(off)) msymbol(Oh) color("scheme p1") msize(large) ) || /// 
       (rcap interaction_ci_lb interaction_ci_ub locc, lstyle(ci) lcolor(gs9))  ||  ///
	   (scatter interaction_b locc if locc==1, by(model)  msymbol(T)  msize(large) color("scheme p2") )  || ///
		(rcap interaction_ci_lb interaction_ci_ub locc, lstyle(ci) lcolor(gs9) ,  ///
		xlabel(0 1, valuelabel noticks) legend(off) xscale(range(-0.5 1.5)) ///
		ylabel(-0.09(0.01).0) yline(0) /// 
		 scheme(cleanplots)  ytitle("Coef. Share Largest Occ. x Occ. Type Dummy", size(small)) xtitle("") )
		 

graph export $path_out_fig/figure_03_heterogeneity_occupation_size.pdf, replace	

*---------------------------------------------------------------------------------
* Local projection models considering the impact of firm specialization exposure
* on relative earnings, wage, and hours growth;
* as well as on relative firm and occupation switching, and switching to non-employment.
*---------------------------------------------------------------------------------

global max = 5 // how many years since initial exposure


use $path_clean_panel/2010-2019-regression.dta, clear
*use  $path_clean_panel/2010-2019-regression-sample.dta, clear	


xtset w_numer year

// complete the panel (i.e. add intermediate years when workers not in employment)
tsfill	
 
gegen ageeduc = group(age educ)

// Normalized HHI
cap drop nHHI_1dig nHHI_3dig

gen nHHI_3dig = (HHI_3dig - (1/sizeFirm)) / (1 - (1/sizeFirm))	
	label var nHHI_3dig "HHI 3-digit"

gen nHHI_1dig = (HHI_1dig - (1/sizeFirm)) / (1 - (1/sizeFirm))	
	label var nHHI_1dig "Normalized HHI 1-dig."
	

// Generate lagged variables
gen Loccup1_10=L.occup1_10 
gen Loccup3_10=l.occup3_10
gen Lindustry=L.industry 
gen LnHHI_3dig = L.nHHI_3dig
gen LfNUTS2 = L.fNUTS2				// Added 19.02 -- ERASE COMMENT AT THE VERY END

foreach var in real_wage real_hrl_wage reg_hours_month {
	gen ln`var' = ln(`var')
	gen Lln`var' = L.ln`var'
	gen L2ln`var' = L2.ln`var'
	gen LDln`var' = L.ln`var' - L2.ln`var'
}


// construct indicators for firm and occupation switching (conditional on employment)

gen firmswitch = 0 if fnumber_FIC==L.fnumber_FIC & w_numer==L.w_numer & fnumber_FIC!=. & L.fnumber_FIC!=.
replace firmswitch = 1 if fnumber_FIC!=L.fnumber_FIC & w_numer==L.w_numer & fnumber_FIC!=. & L.fnumber_FIC!=.
label var firmswitch "=1 if worker switched firm in this year"

gen occswitch = 0 if occup3_10==L.occup3_10 & w_numer==L.w_numer & fnumber_FIC!=. & L.fnumber_FIC!=.
replace occswitch = 1 if occup3_10!=L.occup3_10  & w_numer==L.w_numer & fnumber_FIC!=. & L.fnumber_FIC!=. 
replace occswitch = . if L.occup3_10==. | occup3_10==. // added
label var occswitch "=1 if worker switched 3d occupation in this year" 

sum *switch // % of workers that switch firm or occupation in any one year 

// lagged indicators for firm and occ switch
foreach var in firmswitch occswitch {
	gen L`var' = L.`var'
}


// construct relative outcomes and reformat to have one variable for outcomes over subsequent k years:
forval k=1/$max {
	bysort w_numer (year): gen lnreal_wage_`k' = F`k'.lnreal_wage - lnreal_wage
	gen rellnreal_wage_`k' = lnreal_wage_`k' - LDlnreal_wage
	
	bysort w_numer (year): gen lnreal_hrl_wage_`k' = F`k'.lnreal_hrl_wage - lnreal_hrl_wage
	gen rellnreal_hrl_wage_`k' = lnreal_hrl_wage_`k'- LDlnreal_hrl_wage
	
	bysort w_numer (year): gen lnreg_hours_month_`k' = F`k'.lnreg_hours_month - lnreg_hours_month
	gen rellnreg_hours_month_`k' = lnreg_hours_month_`k'- LDlnreg_hours_month

	gen firmswitch_`k' = 0 if F`k'.fnumber_FIC==fnumber_FIC & w_numer==F`k'.w_numer 
	replace firmswitch_`k' = 1 if F`k'.fnumber_FIC!=fnumber_FIC & w_numer==F`k'.w_numer 
	replace firmswitch_`k' = . if F`k'.fnumber_FIC==. | fnumber_FIC==. 
	gen relfirmswitch_`k' = firmswitch_`k'- Lfirmswitch
	
	gen occswitch_`k' = 0 if F`k'.occup3_10==occup3_10 & w_numer==F`k'.w_numer & F`k'.occup3_10!=. & occup3_10!=. 
	replace occswitch_`k' = 1 if F`k'.occup3_10!=occup3_10 & w_numer==F`k'.w_numer 
	replace occswitch_`k' = . if F`k'.occup3_10==. | occup3_10==. 
	gen reloccswitch_`k' = occswitch_`k'- Loccswitch	
	
}

	// construct indicator for non-employment spells
	gen nonempl = 1 if fnumber_FIC==.
	recode nonempl (.=0)
	sum nonempl

	// indicator for switch to non-employment (and its lag)
	gen neswitch = 0 if fnumber_FIC!=.
	replace neswitch = 1 if fnumber_FIC==. & L.fnumber_FIC!=. & w_numer==L.w_numer
	foreach var in neswitch  {
		gen L`var' = L.`var'
	}

	// construct relative outcomes and reformat to have one variable for outcomes over subsequent years:
	forval k=1/$max {
		gen neswitch_`k' = 1 if fnumber_FIC!=. & F`k'.fnumber_FIC==. & w_numer==F`k'.w_numer
		replace neswitch_`k' = 0 if fnumber_FIC!=. & F`k'.fnumber_FIC!=. & w_numer!=. &  neswitch_`k'==.
		gen rneswitch_`k' = neswitch_`k' - Lneswitch // note: identical to neswitch_`k' in the regression sample -- this is bc the Lneswitch variable is always defined over a year when LHHI_1dig by definition is not observed
	}

	sum *neswitch_1 if LnHHI_3dig!=.
	sum *neswitch_5 if LnHHI_3dig!=.

	sum *neswitch* if LnHHI_3dig!=.


gen k = _n in 1/$max 

// renaming for convenience
forval k=1/$max{	
	rename rellnreal_wage_`k' earn`k'
	rename rellnreal_hrl_wage_`k' wage`k'
	rename rellnreg_hours_month_`k' hours`k'
	rename firmswitch_`k' fswitch`k'
	rename occswitch_`k' oswitch`k'
	rename relfirmswitch_`k' rfswitch`k'
	rename reloccswitch_`k' roswitch`k'
	cap rename neswitch_`k' neswitch`k'
	cap rename rneswitch_`k' rneswitch`k'
}

// two specs: one for entire sample, one for only years before 2015 (more balanced)
global c1 "" 
global c2 "if year<=2014" 

	
// ===== Non-AKM local projections (produce lp_est_exp1 estimates for Figures 5 and A2) =====
foreach dv in earn wage hours fswitch rfswitch oswitch roswitch {
		forval c=1/2 {
		gen k`c'_`dv' = k - 0.1
		replace k`c'_`dv' = k  if "`dv'"=="wage" | "`dv'"=="fswitch" | "`dv'"=="rfswitch" 
		replace k`c'_`dv' = k + 0.1 if "`dv'"=="hours" | "`dv'"=="oswitch" | "`dv'"=="roswitch" | "`dv'"=="neswitch" | "`dv'"=="rneswitch"
		gen b`c'_`dv'=. 
		gen lb`c'_`dv'=.
		gen ub`c'_`dv'=.
		gen n`c'_`dv'=. 
		forval k=1/$max {
	
			reghdfe `dv'`k' LnHHI_3dig Llnreal_wage ${c`c'}, cluster($clustervar) absorb(Loccup3_10 ageeduc Lindustry LfNUTS2 female native year)
			qui replace b`c'_`dv'= _b[LnHHI_3dig] in `k'
			qui replace lb`c'_`dv'= b`c'_`dv' - _se[LnHHI_3dig]*invt(e(df_r), 0.025) in `k'
			qui replace ub`c'_`dv'= b`c'_`dv' + _se[LnHHI_3dig]*invt(e(df_r), 0.025) in `k'
			qui replace n`c'_`dv'= e(N) in `k'
			di "`k' years since exposure: `e(N)' observations"
		}
	}
}

foreach dv in rneswitch {
	forval c=1/2 { 
		gen k`c'_`dv' = k - 0.1 
		replace k`c'_`dv' = k  if "`dv'"=="wage" | "`dv'"=="fswitch" | "`dv'"=="rfswitch" 
		replace k`c'_`dv' = k + 0.1 if "`dv'"=="hours" | "`dv'"=="oswitch" | "`dv'"=="roswitch" | "`dv'"=="neswitch" | "`dv'"=="rneswitch"
		gen b`c'_`dv'=. 
		gen lb`c'_`dv'=.
		gen ub`c'_`dv'=.
		gen n`c'_`dv'=. 
		forval k=1/$max {
		
			reghdfe `dv'`k' LnHHI_3dig Llnreal_wage ${c`c'}, cluster($clustervar) absorb(Loccup3_10 ageeduc Lindustry LfNUTS2 female native year)
			qui replace b`c'_`dv'= _b[LnHHI_3dig] in `k'
			qui replace lb`c'_`dv'= b`c'_`dv' - _se[LnHHI_3dig]*invt(e(df_r), 0.025) in `k'
			qui replace ub`c'_`dv'= b`c'_`dv' + _se[LnHHI_3dig]*invt(e(df_r), 0.025) in `k'
			qui replace n`c'_`dv'= e(N) in `k'
			di "`k' years since exposure: `e(N)' observations"
			}
		}
}



// Earnings and employment outcomes for occupation stayers
foreach dv in earn wage hours {
    forval c=1/2 { 
        gen k`c'_`dv'_st = k - 0.1 
        replace k`c'_`dv'_st = k  if "`dv'"=="wage"  
        replace k`c'_`dv'_st = k + 0.1 if "`dv'"=="hours" 
        gen b`c'_`dv'_st=. 
        gen lb`c'_`dv'_st=.
        gen ub`c'_`dv'_st=.
        gen n`c'_`dv'_st=. 
        
        local controls ${c`c'}
        if `c' == 1 local c_cond "Loccswitch == 0"
        if `c' == 2 local c_cond "year<=2014 & Loccswitch == 0"
        
        forval k=1/$max {
            reghdfe `dv'`k' LnHHI_3dig Llnreal_wage if `c_cond', cluster($clustervar) absorb(Loccup3_10 ageeduc Lindustry LfNUTS2 female native year)
            qui replace b`c'_`dv'_st= _b[LnHHI_3dig] in `k'
            qui replace lb`c'_`dv'_st= b`c'_`dv'_st - _se[LnHHI_3dig]*invt(e(df_r), 0.025) in `k'
            qui replace ub`c'_`dv'_st= b`c'_`dv'_st + _se[LnHHI_3dig]*invt(e(df_r), 0.025) in `k'
            qui replace n`c'_`dv'_st= e(N) in `k'
            di "`k' years since exposure: `e(N)' observations"
        }
    }
}
// ===== end of non-AKM local projections =====

// Controlling for initial AKM FE -- create a new intermediate sample because we may have to drop some firms when merging with the AKM_full sample
preserve
		
		cap drop _merge
		merge m:1 fnumber_FIC using $path_clean_int/AKM_full
			keep if _m == 3
			drop _m

		xtset w_numer year		// merge re-sorted by fnumber_FIC; restore panel order for L. operator
		// Initial firm FE control: AKM firm fixed effect of the worker's firm at the
		// exposure period t-1 (the same period the HHI exposure LnHHI_3dig is measured),
		// held fixed across all horizons k. firm_year_fe is the firm-level (time-invariant)
		// AKM firm effect stored in AKM_full.
		gen Lakm = L.firm_year_fe
			
		foreach dv in earn wage hours {
			forval c=1/2 { 
				gen k`c'_`dv'_akm = k - 0.1 
				replace k`c'_`dv'_akm = k  if "`dv'"=="wage"  
				replace k`c'_`dv'_akm = k + 0.1 if "`dv'"=="hours" 
				gen b`c'_`dv'_akm=. 
				gen lb`c'_`dv'_akm=.
				gen ub`c'_`dv'_akm=.
				gen n`c'_`dv'_akm=. 
				
				forval k=1/$max {
					reghdfe `dv'`k' LnHHI_3dig Llnreal_wage Lakm ${c`c'}, cluster($clustervar) absorb(Loccup3_10 ageeduc Lindustry LfNUTS2 female native year)
					qui replace b`c'_`dv'_akm= _b[LnHHI_3dig] in `k'
					qui replace lb`c'_`dv'_akm= b`c'_`dv'_akm - _se[LnHHI_3dig]*invt(e(df_r), 0.025) in `k'
					qui replace ub`c'_`dv'_akm= b`c'_`dv'_akm + _se[LnHHI_3dig]*invt(e(df_r), 0.025) in `k'
					qui replace n`c'_`dv'_akm= e(N) in `k'
					di "`k' years since exposure: `e(N)' observations"
				}
			}
		}
		
				
			// Panel B equivalent: relative firm switch, occupation switch, and
			// switch to non-employment, controlling for initial AKM firm FE
			foreach dv in rfswitch roswitch rneswitch {
				forval c=1/2 {
					gen k`c'_`dv'_akm = k - 0.1
					replace k`c'_`dv'_akm = k       if "`dv'"=="roswitch"
					replace k`c'_`dv'_akm = k + 0.1 if "`dv'"=="rneswitch"
					gen b`c'_`dv'_akm=.
					gen lb`c'_`dv'_akm=.
					gen ub`c'_`dv'_akm=.
					gen n`c'_`dv'_akm=.

					forval k=1/$max {
						reghdfe `dv'`k' LnHHI_3dig Llnreal_wage Lakm ${c`c'}, cluster($clustervar) absorb(Loccup3_10 ageeduc Lindustry LfNUTS2 female native year)
						qui replace b`c'_`dv'_akm= _b[LnHHI_3dig] in `k'
						qui replace lb`c'_`dv'_akm= b`c'_`dv'_akm - _se[LnHHI_3dig]*invt(e(df_r), 0.025) in `k'
						qui replace ub`c'_`dv'_akm= b`c'_`dv'_akm + _se[LnHHI_3dig]*invt(e(df_r), 0.025) in `k'
						qui replace n`c'_`dv'_akm= e(N) in `k'
						di "`k' years since exposure: `e(N)' observations"
					}
				}
			}


		// Save dataset with local projection estimates
			keep in 1/5
			keep k-n2_rneswitch_akm

			// The merge + xtset above re-sorted the data, so k (and the k*_akm
			// x-axis offsets, generated from _n before the preserve) no longer
			// align with the physical rows the estimates were written to via `in k'.
			// Rebuild them from _n so all 5 horizons have a valid x-coordinate.
			cap drop k
			gen k = _n
			foreach dv in earn wage hours {
				forval c=1/2 {
					replace k`c'_`dv'_akm = k - 0.1
					replace k`c'_`dv'_akm = k     if "`dv'"=="wage"
					replace k`c'_`dv'_akm = k + 0.1 if "`dv'"=="hours"
				}
			}
				foreach dv in rfswitch roswitch rneswitch {
					forval c=1/2 {
						replace k`c'_`dv'_akm = k - 0.1
						replace k`c'_`dv'_akm = k       if "`dv'"=="roswitch"
						replace k`c'_`dv'_akm = k + 0.1 if "`dv'"=="rneswitch"
					}
				}

		save $path_clean_int/lp_est_exp1_akm, replace

	
restore


// Save dataset with non-AKM local projection estimates
	keep in 1/5
	keep k-n2_hours_st

save $path_clean_int/lp_est_exp1, replace


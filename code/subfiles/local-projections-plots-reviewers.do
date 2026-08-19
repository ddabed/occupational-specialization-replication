*---------------------------------------------------------------------------------
* Plots using estimates from local projection models
*---------------------------------------------------------------------------------

use $path_clean_int/lp_est_exp1, clear

// Make graphs - only final versions selected, c can be 1 (full sample, reported) or 2 (only years up to 2014)

	// relative earning, wages, hours outcomes
	forval c=1/1 { 

	# delimit
	twoway 	(rcap ub`c'_earn_st lb`c'_earn_st k`c'_earn_st, color("scheme p1"))
		(scatter b`c'_earn_st k`c'_earn_st, mcolor("scheme p1"))
		
		(rcap ub`c'_wage_st lb`c'_wage_st k`c'_wage_st, color("scheme p2"))
		(scatter b`c'_wage_st k`c'_wage_st, mcolor("scheme p2"))
		
		(rcap ub`c'_hours_st lb`c'_hours_st k`c'_hours_st, color("scheme p3"))
		(scatter b`c'_hours_st k`c'_hours_st, mcolor("scheme p3")),
		
		yline(0)
		legend(order(2 "Earnings" 4 "Hourly wages" 6 "Hours worked")
				position(6) row(1) size(*1.3))
		xtitle("Years since specialization exposure")
		ytitle("Change in growth relative to pre-period")
		xlabel(,gstyle(dot)) ylabel(,gstyle(dot));
	graph export $path_out_fig/figure_a02_panel_a_lp_occupation_stayers.pdf, as(pdf) replace;	

	# delimit cr
	}

* For reporting N in figure footnote 
table k, stat(mean n1_earn_st n1_wage_st n1_hours_st) notot nformat(%12.0f)



use $path_clean_int/lp_est_exp1_akm, clear
	
	// relative earning, wages, hours outcomes
	forval c=1/1 { 

	# delimit
	twoway 	(rcap ub`c'_earn_akm lb`c'_earn_akm k`c'_earn_akm, color("scheme p1"))
		(scatter b`c'_earn_akm k`c'_earn_akm, mcolor("scheme p1"))
		
		(rcap ub`c'_wage_akm lb`c'_wage_akm k`c'_wage_akm, color("scheme p2"))
		(scatter b`c'_wage_akm k`c'_wage_akm, mcolor("scheme p2"))
		
		(rcap ub`c'_hours_akm lb`c'_hours_akm k`c'_hours_akm, color("scheme p3"))
		(scatter b`c'_hours_akm k`c'_hours_akm, mcolor("scheme p3")),
		
		yline(0)
		legend(order(2 "Earnings" 4 "Hourly wages" 6 "Hours worked")
				position(6) row(1) size(*1.3))
		xtitle("Years since specialization exposure")
		ytitle("Change in growth relative to pre-period")
		xlabel(,gstyle(dot)) ylabel(,gstyle(dot));
	graph export $path_out_fig/figure_a02_panel_b_lp_akm_controlled.pdf, as(pdf) replace;	

	# delimit cr
	}

* For reporting N in figure footnote 
table k, stat(mean n1_earn_akm n1_wage_akm n1_hours_akm) notot nformat(%12.0f)



/* LaTeX object for figure note: number of observations (AKM FE controlled, c=1).
   Commented out by default -- uncomment to (re)write the .tex note after the disclosure check.
qui {
	// Panel B figure (figure_a02_panel_b_lp_akm_controlled): earnings, hourly wages, hours
	egen _nmin = rowmin(n1_earn_akm n1_wage_akm n1_hours_akm)
	egen _nmax = rowmax(n1_earn_akm n1_wage_akm n1_hours_akm)
	summ _nmin, meanonly
	local Nlo : di %15.0fc r(min)
	local Nlo = trim("`Nlo'")
	summ _nmax, meanonly
	local Nhi : di %15.0fc r(max)
	local Nhi = trim("`Nhi'")
	drop _nmin _nmax
	file open fn using "$path_out_tab/figure_a02_panel_b_lp_akm_controlled_note.tex", write replace
	file write fn "Number of observations ranges from `Nlo' to `Nhi' across the one- to five-year horizons." _n
	file close fn
}
*/

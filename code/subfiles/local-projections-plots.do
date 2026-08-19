*---------------------------------------------------------------------------------
* Plots using estimates from local projection models
*---------------------------------------------------------------------------------

use $path_clean_int/lp_est_exp1, clear

// Make graphs - only final versions selected, c can be 1 (full sample, reported) or 2 (only years up to 2014)

	// relative earning, wages, hours outcomes
	forval c=1/1 { 

	# delimit
	twoway 	(rcap ub`c'_earn lb`c'_earn k`c'_earn, color("scheme p1"))
		(scatter b`c'_earn k`c'_earn, mcolor("scheme p1"))
		
		(rcap ub`c'_wage lb`c'_wage k`c'_wage, color("scheme p2"))
		(scatter b`c'_wage k`c'_wage, mcolor("scheme p2"))
		
		(rcap ub`c'_hours lb`c'_hours k`c'_hours, color("scheme p3"))
		(scatter b`c'_hours k`c'_hours, mcolor("scheme p3")),
		
		yline(0)
		legend(order(2 "Earnings" 4 "Hourly wages" 6 "Hours worked")
				position(6) row(1) size(*1.3))
		xtitle("Years since specialization exposure")
		ytitle("Change in growth relative to pre-period")
		xlabel(,gstyle(dot)) ylabel(,gstyle(dot));
	graph export $path_out_fig/figure_05_panel_a_lp_earnings.pdf, as(pdf) replace;	

	# delimit cr
	}

	
	// relative firm and occ and non empl switching outcomes		
	forval c=1/1 { 
	# delimit cr
		replace k`c'_rfswitch = k - 0.1 
		replace k`c'_roswitch = k  
		replace k`c'_rneswitch = k + 0.1
		
	# delimit ;
	twoway 	(rcap ub`c'_rfswitch lb`c'_rfswitch k`c'_rfswitch, mcolor("scheme p1"))
		(scatter b`c'_rfswitch k`c'_rfswitch, mcolor("scheme p1"))
		
		(rcap ub`c'_roswitch lb`c'_roswitch k`c'_roswitch, color("scheme p2"))
		(scatter b`c'_roswitch k`c'_roswitch, mcolor("scheme p2"))
		
		(rcap ub`c'_rneswitch lb`c'_rneswitch k`c'_rneswitch, color("scheme p3"))
		(scatter b`c'_rneswitch k`c'_rneswitch, mcolor("scheme p3")),
		
		yline(0)
		legend(order(2 "Firm switch" 4 "Occupation switch" 6 "Switch to non-employment")
				position(6) row(1) size(*1.3))
		xtitle("Years since specialization exposure")
		ytitle("Switch probability relative to pre-period")
		xlabel(,gstyle(dot)) ylabel(,gstyle(dot));
	graph export $path_out_fig/figure_05_panel_b_lp_switching.pdf, as(pdf) replace;	

	# delimit cr
	
}	


* For reporting N in figure footnote
table k, stat(mean n1_earn n1_wage n1_hours n1_rfswitch n1_roswitch n1_rneswitch) notot nformat(%12.0f)

/* LaTeX object for figure note: number of observations (full sample, c=1).
   Commented out by default -- uncomment to (re)write the .tex note after the disclosure check.
qui {
	// Panel A figure (lp_rel_earn1exp1): earnings, hourly wages, hours
	egen _nmin = rowmin(n1_earn n1_wage n1_hours)
	egen _nmax = rowmax(n1_earn n1_wage n1_hours)
	summ _nmin, meanonly
	local Nlo : di %15.0fc r(min)
	local Nlo = trim("`Nlo'")
	summ _nmax, meanonly
	local Nhi : di %15.0fc r(max)
	local Nhi = trim("`Nhi'")
	drop _nmin _nmax
	file open fn using "$path_out_tab/figure_05_panel_a_lp_earnings_note.tex", write replace
	file write fn "Number of observations ranges from `Nlo' to `Nhi' across the one- to five-year horizons." _n
	file close fn

	// Panel B figure (lp_rel_allswitch1exp1): firm switch, occupation switch, switch to non-employment
	egen _nmin = rowmin(n1_rfswitch n1_roswitch n1_rneswitch)
	egen _nmax = rowmax(n1_rfswitch n1_roswitch n1_rneswitch)
	summ _nmin, meanonly
	local Nlo : di %15.0fc r(min)
	local Nlo = trim("`Nlo'")
	summ _nmax, meanonly
	local Nhi : di %15.0fc r(max)
	local Nhi = trim("`Nhi'")
	drop _nmin _nmax
	file open fn using "$path_out_tab/figure_05_panel_b_lp_switching_note.tex", write replace
	file write fn "Number of observations ranges from `Nlo' to `Nhi' across the one- to five-year horizons." _n
	file close fn
}
*/

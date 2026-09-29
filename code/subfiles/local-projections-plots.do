*---------------------------------------------------------------------------------
* local-projections-plots.do -- Figure 5, Panels A and B
*
* Draws the baseline local projection estimates produced by
* local-projections.do: the response of earnings, hourly wages and hours
* (Panel A), and of firm switching, occupation switching and switching to
* non-employment (Panel B), at horizons of one to five years.
*   in : $path_clean_int/lp_est_exp1.dta
*   out: $path_out_fig/figure_05_panel_a_lp_earnings.pdf
*        $path_out_fig/figure_05_panel_b_lp_switching.pdf
*---------------------------------------------------------------------------------

use $path_clean_int/lp_est_exp1, clear

// c indexes the sample: 1 is the full sample, which is what the paper reports;
// 2 restricts to years up to 2014, where the panel is more balanced. Only c = 1
// is plotted, but the estimates for both are available in lp_est_exp1.dta.

	// Panel A: earnings, hourly wages and hours
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

	
	// Panel B: firm, occupation and non-employment switching
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


* Observation counts behind each horizon, for the figure note
table k, stat(mean n1_earn n1_wage n1_hours n1_rfswitch n1_roswitch n1_rneswitch) notot nformat(%12.0f)

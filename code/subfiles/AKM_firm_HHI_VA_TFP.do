*-------------------------------------------------------------------------
* AKM_firm_HHI_VA_TFP.do -- Figure 4 and Figure A1
*
* Relates the AKM firm wage premia estimated in AKM_firm_HHI.do to firm
* productivity, and decomposes the p10-p90 gap in firm premia across HHI
* deciles into a productivity (composition) component, a rent-sharing
* component, and a size/industry component.
*
* The same code runs twice, once per productivity measure:
*   TFP              -> Figure A1, Panels A and B
*   Value added p.w. -> Figure 4,  Panels A and B
*
* Because the interaction term makes the split between the productivity and
* rent-sharing components depend on the order of the decomposition, each is
* reported as an upper and a lower bound (the _v1 / _v2 variants below).
*   out: $path_out_fig/figure_04_panel_{a,b}_*.pdf
*        $path_out_fig/figure_a01_panel_{a,b}_*.pdf
*-------------------------------------------------------------------------

use $path_clean_int/AKM_full.dta, clear

merge m:1 fnumber_FIC using $path_clean_int/va_tfp_data/tfp_va_data, ///
    keepusing(tfp_cd_wb valueadded_mp lva)
drop if _m == 2
drop _m

drop if firm_year_fe == .

*** Dispersion of the AKM firm effects, reported in the text
		* Unweighted
		sum firm_year_fe, det
		scalar sd_firm_akm = r(sd)

		* Worker-weighted 
		sum firm_year_fe [aw=sizeFirm], det
		scalar sd_firm_akm_w = r(sd)
		
		* The effect of a 1 SD difference in firm premia on log wages:
		scalar effect_1sd = sd_firm_akm_w          // in log points
		scalar effect_pct = (exp(sd_firm_akm_w) - 1) * 100   // approx. % wage difference

		di "1 SD of AKM firm FE = " %6.4f sd_firm_akm_w " log points"
		di "                    ≈ " %5.2f effect_pct "% wage difference"
		


* Productivity levels (per worker uses sizeFirm, matching the sales measure).
* Log value added per worker is formed as lva - lfsize rather than by logging
* va_per_worker, so that firms with non-positive value added stay missing in
* the same way they are in lva.
gen va_per_worker = valueadded_mp / sizeFirm
gen lva_pw = lva - lfsize
    label var va_per_worker "Value added per worker"
    label var lva_pw        "Log value added per worker"
* logsales (log sales per worker) is already present in AKM_full.dta.

tempfile akmprod
save `akmprod', replace

*-------------------------------------------------------------------------
* Loop over the three productivity measures
*-------------------------------------------------------------------------
foreach m in  tfp va {

    if "`m'" == "tfp" {
        local prodlevel tfp_cd_wb
        local axisname  "TFP (standardized)"
        local legname   "TFP (standardized)"
        local title     "TFP (Cobb-Douglas, wage bill)"
        local tag       tfp_cd_wb
        local figA      figure_a01_panel_a_akm_tfp                  // Figure A1, Panel A
        local figB      figure_a01_panel_b_akm_tfp_decomposition    // Figure A1, Panel B
    }
    else if "`m'" == "va" {
        local prodlevel lva_pw
        local axisname  "Log VA per worker (standardized)"
        local legname   "Log VA per Worker"
        local title     "Value added per worker"
        local tag       va
        local figA      figure_04_panel_a_akm_value_added                 // Figure 4, Panel A
        local figB      figure_04_panel_b_akm_value_added_decomposition   // Figure 4, Panel B
    }
    
    display _n(2) "{hline 70}"
    display "  AKM-productivity decomposition for: `title'"
    display "{hline 70}"

    use `akmprod', clear
    drop if missing(`prodlevel')
	display "Dropped `r(N_drop)' observations due to missing `title'"  

    *--- Standardize productivity, weighting firms by employment
    sum `prodlevel' [aweight=sizeFirm]
    gen std_prod = (`prodlevel' - r(mean)) / r(sd)
        label var std_prod "`axisname'"


    *--- Main regression: firm FE = HHI x std_prod + size + industry FE
    reghdfe firm_year_fe c.nHHI_3dig##c.std_prod lfsize [aweight=sizeFirm], ///
        absorb(industry) nocons resid
    predict resid  if e(sample), resid
    predict ind_fe if e(sample), d
    gen observ = ind_fe + _b[lfsize]*lfsize

    scalar HHI_coef         = _b[nHHI_3dig]
    scalar prod_coef        = _b[std_prod]
    scalar interaction_coef = _b[c.nHHI_3dig#c.std_prod]

    * Sanity check: components add up to firm_year_fe
    gen test = firm_year_fe - HHI_coef*nHHI_3dig - prod_coef*std_prod ///
               - interaction_coef*nHHI_3dig*std_prod - observ - resid
    sum test, det
    drop test

    *--- Allocate firms to HHI deciles (employment-weighted) + interaction product
    xtile HHI_decile = nHHI_3dig [aw=sizeFirm], nq(10)
    gen product = nHHI_3dig * std_prod

    *--- Collapse to decile
    gcollapse (mean) firm_year_fe nHHI_3dig std_prod observ resid product ///
        [aweight=sizeFirm], by(HHI_decile) fast

    * Sanity check: the decomposition still adds up after collapsing. test uses
    * the collapsed mean of the interaction product, test2 the product of the
    * collapsed means; test3 scales the latter discrepancy by the firm effect.
    gen test  = firm_year_fe - HHI_coef*nHHI_3dig - prod_coef*std_prod ///
                - interaction_coef*product - observ - resid
    gen test2 = firm_year_fe - HHI_coef*nHHI_3dig - prod_coef*std_prod ///
                - interaction_coef*nHHI_3dig*std_prod - observ - resid
    gen test3 = test2 / firm_year_fe
    tab test
    tab test2
    tab test3

    * The gap between the two forms is the within-decile covariance between HHI
    * and productivity, which is reported together with resid under "others".
    gen resid2 = test2
    drop test*

    *=====================================================================
    * Panel A: HHI-decile scatter
    *=====================================================================
    twoway scatter firm_year_fe nHHI_3dig, ms(circle) color("scheme p1") || ///
           scatter std_prod nHHI_3dig, ms(triangle_hollow) yaxis(2) color("scheme p2") ///
        xtitle("Firm's Occupational Specialization (HHI 3-dig)") ///
        ytitle("AKM Firm Fixed Effect") graphregion(col(white)) ///
        ytitle("`axisname'", axis(2)) ///
        legend(pos(6)) legend(rows(1)) ///
        legend(order(1 "AKM Firm Fixed Effect" 2 "`legname'"))

    graph export "$path_out_fig/`figA'.pdf", replace

    *=====================================================================
    * Panel B: p10-p90 decomposition bar plot
    *=====================================================================
    gen p10_p90_overall         = firm_year_fe - firm_year_fe[_n+9]
    gen p10_p90_composition_v1  = (prod_coef + interaction_coef*nHHI_3dig[_n+9]) * (std_prod - std_prod[_n+9])
    gen p10_p90_rent_sharing_v1 = (HHI_coef + interaction_coef*std_prod) * (nHHI_3dig - nHHI_3dig[_n+9])
    gen p10_p90_composition_v2  = (prod_coef + interaction_coef*nHHI_3dig) * (std_prod - std_prod[_n+9])
    gen p10_p90_rent_sharing_v2 = (HHI_coef + interaction_coef*std_prod[_n+9]) * (nHHI_3dig - nHHI_3dig[_n+9])
    gen p10_p90_observ          = observ - observ[_n+9]
    gen p10_p90_resid           = resid  - resid[_n+9]
    gen p10_p90_resid2          = resid2 - resid2[_n+9]

    gen test1 = p10_p90_overall - p10_p90_composition_v1 - p10_p90_rent_sharing_v1 ///
                - p10_p90_observ - p10_p90_resid - p10_p90_resid2
    gen test2 = p10_p90_overall - p10_p90_composition_v2 - p10_p90_rent_sharing_v2 ///
                - p10_p90_observ - p10_p90_resid - p10_p90_resid2
    tab test1
    tab test2
    drop test*

    gen others = p10_p90_resid + p10_p90_resid2

    foreach var of varlist p10_p90_composition_v1 p10_p90_rent_sharing_v1 ///
                            p10_p90_composition_v2 p10_p90_rent_sharing_v2 ///
                            p10_p90_observ others {
        gen sh_`var' = `var' / p10_p90_overall
    }

    * Reduce to the single p10-p90 row, reshape, and draw the bars. Destructive
    * (no preserve needed): the next loop iteration reloads from the tempfile.
    keep in 1
    keep p10_p90_overall p10_p90_composition_v1 p10_p90_rent_sharing_v1 ///
         p10_p90_observ  p10_p90_composition_v2 p10_p90_rent_sharing_v2

    gen id = 1
    reshape long p10_p90_, i(id) j(type) string
    replace id = 2 if type=="composition_v1"
    replace id = 2 if type=="composition_v2"
    replace id = 3 if type=="rent_sharing_v1"
    replace id = 3 if type=="rent_sharing_v2"
    replace id = 4 if type=="observ"

    gen overall = p10_p90_ if type=="overall"
    gen prodlow = p10_p90_ if type=="composition_v1"
    gen produp  = p10_p90_ if type=="composition_v2"
    gen rentlow = p10_p90_ if type=="rent_sharing_v2"
    gen rentup  = p10_p90_ if type=="rent_sharing_v1"
    gen observ  = p10_p90_ if type=="observ"

    colorpalette cblind, globals
    twoway  bar overall id, color(maroon) || ///
            bar produp  id, color($Sky_Blue) || ///
            bar prodlow id, color($Blue) lcolor($Blue) lwidth(med) || ///
            bar rentup  id, color($Gray) || ///
            bar rentlow id, color($Black) lcolor($Black) lwidth(med) || ///
            bar observ  id, color($bluish_Green) ///
        graphregion(col(white)) ///
        legend(order(1 "Overall Gap in Firm Wage Premia" ///
                     4 "Rent Sharing (Upper Bound)" ///
                     2 "Productivity (Upper Bound)" ///
                     5 "Rent Sharing (Lower Bound)" ///
                     3 "Productivity (Lower Bound)" ///
                     6 "Size, Industry") ///
               region(lstyle(none)) pos(6) rows(3)) ///
        xtitle("") xlabel("") xscale(noline) ///
        ylabel(0(0.02)0.10) ///
        title("")
    graph export "$path_out_fig/`figB'.pdf", replace
}


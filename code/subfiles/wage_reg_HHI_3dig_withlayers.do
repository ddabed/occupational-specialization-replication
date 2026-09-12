*-------------------------------------------------------------------------
* wage_reg_HHI_3dig_withlayers.do -- Table 6, Panels A, B and C
*
* Re-runs the two most demanding specifications of Table 4 (columns 5 and 6)
* with and without controls for the firm's hierarchical structure, to show
* that the specialization effect is not just a layers effect.
*
* Layers follow Caliendo, Monte and Rossi-Hansberg: each worker is assigned to
* one of four hierarchical layers from the QdP qualification level, and
* nrlayers counts how many distinct layers a firm-year contains. The table
* controls for nrlayers, with one-layer firms as the reference category.
*
* This file reads the renamed QdP worker files directly, because the
* qualification level is not carried into the analysis panel. Those files must
* therefore still be present at analysis time -- see data/raw/README.md.
*   out: $path_out_tab/table_06_panel_a_layers_monthly_earnings.tex
*        $path_out_tab/table_06_panel_b_layers_monthly_hours.tex
*        $path_out_tab/table_06_panel_c_layers_hourly_wage.tex
*-------------------------------------------------------------------------

eststo clear   // drop estimates stored by earlier do-files, so esttab cannot pick up a stale one

*Building the layers

foreach y in 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 {
	
	use $path_raw_QdPren/workers_renamed_occlabel`y', clear
	
	keep w_n fnumber_FIC year qualif_level occup3_10 school_1
	
	* Layer 4 is the top of the hierarchy, layer 1 the bottom.
	gen layer = 2 if qualif_level == 4 | (qualif_level == 5 & occup3_10 < 400)
		replace layer = 4 if qualif_level == 1
		replace layer = 3 if qualif_level == 2 | qualif_level == 3
		replace layer = 1 if layer == .
		
		label var layer "Layer (Caliendo)"
		
	* Alternative occupation-based layer definition, built for comparison but
	* not used in the table below.
	gen layer2 = 4 if occup3_10 == 111
		replace layer2 = 3 if occup3_10 == 112
		replace layer2 = 1 if occup3_10 >= 400
		replace layer2 = 2 if layer2 ==.
		
		label var layer2 "Layer (alternative)"
		
	bysort w_numer fnumber_FIC year: gen dup = cond(_N==1,0,_n)
		drop if dup > 1
		drop dup
	
	compress 
	save $path_temp/layer_`y', replace

}

use $path_temp/layer_2010, clear

foreach y in 2011 2012 2013 2014 2015 2016 2017 2018 2019 {
	
	append using $path_temp/layer_`y'

}

compress	

save $path_temp/layer_10_19, replace


*Merge with full panel

use $path_clean_panel/2010-2019-regression.dta, clear

label var nHHI_3dig "HHI 3-digit"

drop _m

merge 1:1 w_n fnumber_FIC year using $path_temp/layer_10_19
		keep if  _m == 3
		drop _m
	
// number of layers
bysort fnumber_FIC year layer: gen aux = _n == 1
bysort fnumber_FIC year: gegen nrlayers = sum(aux)
	drop aux
		

label def nrlayers_l 1 "One layer" 2 "Two Layers" 3 "Three Layers" 4 "Four Layers"
label values nrlayers nrlayers_l

// Distribution of workers across layers
tab layer
bysort fnumber_FIC year layer: gegen femp_layer = count(w_numer)
gen empshare_layer = femp_layer / sizeFirm


///// TABLE, 3 PANELS

** PANEL A: log real monthly wage


*A4. Table 4 col. 5 specification: 4-digit industry x year FE

** No layers

eststo HHI_3dig_monthlywage_nl_4:reghdfe lreal_wage c.nHHI_3dig lfsize female native, noconstant absorb(year#industry fNUTS2 age#educ occup3_10) cluster($clustervar)
	quietly estadd local fixedfsize "X", replace
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker " ", replace


** With layers

eststo HHI_3dig_monthlywage4:reghdfe lreal_wage c.nHHI_3dig i.nrlayers lfsize female native, noconstant absorb(year#industry fNUTS2 age#educ occup3_10 layer) cluster($clustervar)
	quietly estadd local fixedfsize "X", replace
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker " ", replace
	 

*A5. Table 4 col. 6 specification: + worker FE

** No layers 

eststo HHI_3dig_monthlywage_nl_5:reghdfe lreal_wage c.nHHI_3dig lfsize, noconstant absorb(year#industry fNUTS2 age#educ occup3_10 w_numer) cluster($clustervar)
	quietly estadd local fixedfsize "X", replace
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics " ", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker "X", replace



** With layers
eststo HHI_3dig_monthlywage5:reghdfe lreal_wage c.nHHI_3dig i.nrlayers lfsize, noconstant absorb(year#industry fNUTS2 age#educ occup3_10 w_numer layer) cluster($clustervar)
	quietly estadd local fixedfsize "X", replace
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics " ", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker "X", replace
	
	
	
	
** PANEL B: log total monthly hours



*B4. Table 4 col. 5 specification: 4-digit industry x year FE

* No layers
eststo HHI_3dig_hours_nl_4:reghdfe lreg_hours_month c.nHHI_3dig lfsize female native, noconstant absorb(year#industry fNUTS2 age#educ occup3_10) cluster($clustervar)
	quietly estadd local fixedfsize "X", replace
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker " ", replace


* With layers
eststo HHI_3dig_hours4:reghdfe lreg_hours_month c.nHHI_3dig i.nrlayers lfsize female native, noconstant absorb(year#industry fNUTS2 age#educ occup3_10 layer) cluster($clustervar)
	quietly estadd local fixedfsize "X", replace
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker " ", replace
	 

*B5. Table 4 col. 6 specification: + worker FE

*No layers

eststo HHI_3dig_hours_nl_5:reghdfe lreg_hours_month c.nHHI_3dig lfsize, noconstant absorb(year#industry fNUTS2 age#educ occup3_10 w_numer) cluster($clustervar)
	quietly estadd local fixedfsize "X", replace
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics " ", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker "X", replace


* With Layers
eststo HHI_3dig_hours5:reghdfe lreg_hours_month c.nHHI_3dig i.nrlayers lfsize, noconstant absorb(year#industry fNUTS2 age#educ occup3_10 w_numer layer) cluster($clustervar)
	quietly estadd local fixedfsize "X", replace
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics " ", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker "X", replace
	
	

** PANEL C: log real hourly wage


*C4. Table 4 col. 5 specification: 4-digit industry x year FE

* No layers

eststo HHI_3dig_hourlywage_nl_4:reghdfe lreal_hrl_wage c.nHHI_3dig lfsize female native , noconstant absorb(year#industry fNUTS2 age#educ occup3_10) cluster($clustervar)
	quietly estadd local fixedfsize "X", replace
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker " ", replace
	
	
* With layers
eststo HHI_3dig_hourlywage4:reghdfe lreal_hrl_wage c.nHHI_3dig i.nrlayers lfsize female native , noconstant absorb(year#industry fNUTS2 age#educ occup3_10 layer) cluster($clustervar)
	quietly estadd local fixedfsize "X", replace
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics "X", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker " ", replace
	 

*C5. Table 4 col. 6 specification: + worker FE

* No layers

eststo HHI_3dig_hourlywage_nl_5:reghdfe lreal_hrl_wage c.nHHI_3dig lfsize , noconstant absorb(year#industry fNUTS2 age#educ occup3_10 w_numer) cluster($clustervar)
	quietly estadd local fixedfsize "X", replace
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics " ", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker "X", replace
	
* With layers

eststo HHI_3dig_hourlywage5:reghdfe lreal_hrl_wage c.nHHI_3dig i.nrlayers lfsize , noconstant absorb(year#industry fNUTS2 age#educ occup3_10 w_numer layer) cluster($clustervar)
	quietly estadd local fixedfsize "X", replace
	quietly estadd local fixedyear "X", replace
	quietly estadd local fixedind "X", replace
	quietly estadd local fixeddemographics " ", replace
	quietly estadd local fixedaeduc "X", replace
	quietly estadd local fixed1dig "X", replace
	quietly estadd local fixed3dig "X", replace
	quietly estadd local fixedworker "X", replace
	
	
	quietly estadd local hline " ", replace
	
	
label def nrlayers_l3 1 "- One layer" 2 "- Two layers" 3 "- Three layers" 4 "- Four layers"
label values nrlayers nrlayers_l3
		

* Each panel is exported as a standalone .tex fragment

local tabtitle "Wage regression: HHI at 3 digit occupation."
local tablabel "table_06_panel_a_layers_monthly_earnings"

esttab HHI_3dig_monthlywage_nl_4  HHI_3dig_monthlywage4 HHI_3dig_monthlywage_nl_5 HHI_3dig_monthlywage5 using $path_out_tab/`tablabel'.tex, ///
	keep(nHHI_3dig *.nrlayers) ///
	nobaselevels ///
	refcat(2.nrlayers "Firm's number of layers  (Reference: One layer)", nolabel) ///
	star(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
	b(%9.3f) se(%9.3f) ///
	nomtitles ///
	prehead(  "" ) ///
	posthead("\toprule" "\multicolumn{@span}{l}{\textbf{A. Dependent variable: Log monthly earnings}} \vspace{0.5cm}  \\") ///
	prefoot("\midrule") ///
	postfoot("\midrule") ///
	s(r2, fmt( %9.2fc) label("$\text{R}^2$")) ///
	style(tex) ///
	label ///
	booktabs ///
	nonotes ///
	noobs ///
	fragment ///
	replace
	

	
local tablabel "table_06_panel_b_layers_monthly_hours"
	
esttab HHI_3dig_hours_nl_4 HHI_3dig_hours4 HHI_3dig_hours_nl_5 HHI_3dig_hours5 using $path_out_tab/`tablabel'.tex, ///
	keep(nHHI_3dig *.nrlayers) ///
	nobaselevels ///
	refcat(2.nrlayers "Firm's number of layers (Reference: One layer)", nolabel) ///
	star(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
	b(%9.3f) se(%9.3f) ///
	nomtitles ///
	prehead("\\" "\multicolumn{@span}{l}{\textbf{B. Dependent variable: Log total monthly hours}} \vspace{0.5cm} \\" ) ///
	postfoot("\midrule") ///
	posthead("") ///
	s(r2, fmt( %9.2fc) label("$\text{R}^2$")) ///
	style(tex) ///
	label ///
	booktabs ///
	nonotes ///
	nonumbers ///
	noobs ///
	fragment ///
	replace
	
local tablabel "table_06_panel_c_layers_hourly_wage"
	
esttab HHI_3dig_hourlywage_nl_4 HHI_3dig_hourlywage4 HHI_3dig_hourlywage_nl_5 HHI_3dig_hourlywage5 using $path_out_tab/`tablabel'.tex, ///
	keep(nHHI_3dig *.nrlayers) ///
	nobaselevels ///
	refcat(2.nrlayers "Firm's number of layers  (Reference: One layer)", nolabel) ///
	star(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
	b(%9.3f) se(%9.3f) ///
	nomtitles ///
	prehead("\\" "\multicolumn{@span}{l}{\textbf{C. Dependent variable:  Log hourly wage}} \vspace{0.5cm}  \\"  ) ///
	postfoot("\bottomrule" ) ///
	posthead("") ///
	s(r2 hline fixedfsize fixedyear fixedaeduc fixed1dig fixed3dig fixedind fixedworker N, fmt(%9.2fc %9s %9s %9s %9s %9s %9s %9s %9s %12.2gc ) label("$\text{R}^2$" "\midrule" "Firm size" "Year and region FE" "Demographic controls"  "1-dig occupation FE" "3-dig occupation FE" "4-dig ind. $\times$ year FE" "Worker FE" "N" )) ///
	style(tex) ///
	label ///
	booktabs ///
	nonotes ///
	noobs ///
	nonumbers ///
	fragment ///
	replace
			
		
foreach y in 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 {
	
	erase "$path_temp/layer_`y'.dta"
	
}	
	erase $path_temp/layer_10_19.dta
	
		
		
	


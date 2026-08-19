 
use $path_clean_panel/2010-2019-regression.dta, clear

gen agecat = 1 if age < 34
replace agecat = 2 if age >= 34 & age < 54
replace agecat = 3 if age >= 54

label def agecat_l 1 "Young" 2 "Prime age" 3 "Old"
label values agecat agecat_l

count

preserve

gcollapse (mean) HHI_occs = nHHI_3dig (sd) HHI_occs_sd = nHHI_3dig (count) n_occs=nHHI_3dig, by(occup1_10) fast

gen index =_n
gegen total_obs = sum(n_occs)

generate hihhi_occs = HHI_occs + invttail(n-1,0.025)*(HHI_occs_sd / sqrt(n_occs))
generate lowhhi_occs = HHI_occs - invttail(n-1,0.025)*(HHI_occs_sd / sqrt(n_occs))


gen text_sd_occs = "Sd: " + string(HHI_occs_sd, "%3.2f")
gen y = 0.135

set scheme plotplain // change scheme

twoway (bar HHI_occs index) (rcap hihhi_occs lowhhi_occs index) (scatter y index, ms(none) mlabpos(12) mlab(text_sd_occs)mlabangle(90) mlabgap(1)) , ///
	   xlabel(1 "Managers" 2 "Professionals" 3 "Technicians and associate prof." 4 "Clerical workers" 5 "Service and sales workers" 6 "Craft and related trade workers" 7 "Plant and machine operators" 8 "Elementary occupations", ///
	   noticks angle(30)) ytitle("Mean Firm-Level Specialization (HHI)") xtitle("1 Digit ISCO Occupation") ///
	   leg(off)

local gphlabel "figure_01_panel_b_exposure_occupation"
graph export $path_out_fig/`gphlabel'.pdf, replace


set scheme cleanplots // restore previous scheme


restore



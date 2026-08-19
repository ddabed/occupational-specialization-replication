use $path_clean_panel/2010-2019-regression.dta, clear

gen agecat = 1 if age < 34
replace agecat = 2 if inrange(age,34,53)
replace agecat = 3 if age >= 54
label def agecat_l 1 "Young" 2 "Prime age" 3 "Old"
label values agecat agecat_l

tempfile Teduc Tage Tsex Tnat

* --- EDUC ---
preserve
gcollapse (mean) HHI_educ = nHHI_3dig (sd) HHI_educ_sd = nHHI_3dig (count) n_educ = nHHI_3dig, by(educ) fast
gen index_educ = _n
gen hihhi_educ = HHI_educ + invttail(n_educ-1, 0.025) * (HHI_educ_sd / sqrt(n_educ))
gen lowhhi_educ = HHI_educ - invttail(n_educ-1, 0.025) * (HHI_educ_sd / sqrt(n_educ))
gen location_educ = 1
gen text_sd_educ = "Sd: " + string(HHI_educ_sd, "%3.2f")
save `Teduc'
restore

* --- AGE ---
preserve
gcollapse (mean) HHI_age = nHHI_3dig (sd) HHI_age_sd = nHHI_3dig (count) n_age = nHHI_3dig, by(agecat) fast
gen index_age = _n + 4          // positions 5–7
gen hihhi_age = HHI_age + invttail(n_age-1, 0.025) * (HHI_age_sd / sqrt(n_age))
gen lowhhi_age = HHI_age - invttail(n_age-1, 0.025) * (HHI_age_sd / sqrt(n_age))
gen location_age = 2
gen text_sd_age = "Sd: " + string(HHI_age_sd, "%3.2f")
save `Tage'
restore

* --- SEX ---
preserve
gcollapse (mean) HHI_sex = nHHI_3dig (sd) HHI_sex_sd = nHHI_3dig (count) n_sex = nHHI_3dig, by(female) fast
gen index_sex = _n + 8           // positions 9–10
gen hihhi_sex = HHI_sex + invttail(n_sex-1, 0.025) * (HHI_sex_sd / sqrt(n_sex))
gen lowhhi_sex = HHI_sex - invttail(n_sex-1, 0.025) * (HHI_sex_sd / sqrt(n_sex))
gen location_sex = 3
gen text_sd_sex = "Sd: " + string(HHI_sex_sd, "%3.2f")
save `Tsex'
restore

* --- NATIVE ---
preserve
gcollapse (mean) HHI_native = nHHI_3dig (sd) HHI_native_sd = nHHI_3dig (count) n_native = nHHI_3dig, by(native) fast
gen index_native = _n + 11       // positions 12–13
gen hihhi_native = HHI_native + invttail(n_native-1, 0.025) * (HHI_native_sd / sqrt(n_native))
gen lowhhi_native = HHI_native - invttail(n_native-1, 0.025) * (HHI_native_sd / sqrt(n_native))
gen location_native = 4
gen text_sd_native = "Sd: " + string(HHI_native_sd, "%3.2f")
save `Tnat'
restore

* --- Build plotting dataset and graph ---
preserve
use `Teduc', clear
append using `Tage'
append using `Tsex'
append using `Tnat'
gen y = 0.32

set scheme plotplain
twoway ///
    (bar HHI_educ index_educ) (rcap hihhi_educ lowhhi_educ index_educ) (scatter y index_educ, ms(none) mlab(text_sd_educ) mlabangle(90) mlabgap(1)) ///
    (bar HHI_age   index_age)  (rcap hihhi_age  lowhhi_age  index_age)  (scatter y index_age,   ms(none) mlab(text_sd_age)   mlabangle(90) mlabgap(1)) ///
    (bar HHI_sex   index_sex)  (rcap hihhi_sex  lowhhi_sex  index_sex)  (scatter y index_sex,   ms(none) mlab(text_sd_sex)   mlabangle(90) mlabgap(1)) ///
    (bar HHI_native index_native) (rcap hihhi_native lowhhi_native index_native) (scatter y index_native, ms(none) mlab(text_sd_native) mlabangle(90) mlabgap(1)), ///
    xlabel( 1 "No high school" 2 "High school" 3 "College" ///
            5 "Young" 6 "Middle age" 7 "Old" ///
            9 "Male" 10 "Female" ///
            12 "Foreign" 13 "Native", noticks angle(30)) ///
    ytitle("Mean Firm-Level Specialization (HHI)") ///
    legend(off)

local gphlabel "figure_01_panel_a_exposure_demographics"
graph export $path_out_fig/`gphlabel'.pdf, replace

set scheme cleanplots
restore


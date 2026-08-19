
use $path_clean_panel/2010-2019-regression.dta, clear

* ---------- 3-digit block ----------
bys fnumber_FIC year: egen maxshare = max(share_3dig)
bys fnumber_FIC year: egen minshare = min(share_3dig)

gen maxshare_dummy = 0
replace maxshare_dummy=1 if maxshare == share_3dig
gen minshare_dummy = 0
replace minshare_dummy=1 if minshare == share_3dig

label var maxshare_dummy "Largest 3-dig occ."
label var minshare_dummy "Smallest 3-dig occ."
label var maxshare        "Share largest 3-dig. occ."

* Pay Transparency (3-digit)
eststo reg1: reghdfe lreal_hrl_wage c.maxshare##maxshare_dummy female native lfsize, ///
    noconstant absorb(year#industry fNUTS2 age#educ occup3_10) cluster($clustervar)
			quietly estadd local fixedfsize "X", replace
			quietly estadd local fixedyear "X", replace
			quietly estadd local fixedind "X", replace
			quietly estadd local fixeddemographics "X", replace
			quietly estadd local fixedaeduc "X", replace
			quietly estadd local fixed3dig "X", replace
			quietly estadd local fixedworker " ", replace

eststo reg2: reghdfe lreal_hrl_wage c.maxshare##maxshare_dummy lfsize, ///
    noconstant absorb(year#industry fNUTS2 age#educ occup3_10 w_numer) cluster($clustervar)
quietly estadd local fixedfsize "X", replace
			quietly estadd local fixedyear "X", replace
			quietly estadd local fixedind "X", replace
			quietly estadd local fixeddemographics " ", replace
			quietly estadd local fixedaeduc "X", replace
			quietly estadd local fixed3dig "X", replace
			quietly estadd local fixedworker "X", replace

* ---------- table ----------
local tablabel "table_a10_pay_transparency"
esttab reg1 reg2 using $path_out_tab/`tablabel'.tex, ///
    drop(female native lfsize) ///
    star(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
    b(%9.3f) se(%9.3f) ///
    s(fixedfsize fixedyear fixedaeduc fixed3dig fixedind fixedworker N r2, fmt(%9s %9s %9s %9s %9s %9s %12.2gc %9.2fc) ///
      label("Firm size" "Year and region FE" "Demographic Controls" "3-dig occupation FE" "4-dig ind. $\times$ year FE" "Worker FE" "N" "$\text{R}^2$")) ///
    prehead("\begin{tabularx}{\textwidth}{l*{@M}{Y}}" "\toprule" "&\multicolumn{@M}{c}{Dependent variable: Log hourly wage} \\" "\cmidrule(lr){2-@span} ") ///
    posthead("\midrule") ///
    prefoot("\midrule") ///
    postfoot("\bottomrule" "\end{tabularx}") ///
    style(tex) label booktabs nomtitles nobaselevels noomitted nonotes ///
    substitute({table} {} ///
        "Largest 3-dig occ.=0 $\times$ Share largest 3-dig. occ." "Share largest $\times$ Largest occ.=0" ///
        "Largest 3-dig occ.=1 $\times$ Share largest 3-dig. occ." "Share largest $\times$ Largest occ.=1" ///
        "Largest 3-dig occ." "Largest occ. dummy" "Share largest 3-dig. occ." "Share largest occupation") ///
    replace

	
*=========================================================================
* 0_install_packages.do -- run ONCE before 1_build_data.do
*
* Installs the user-written Stata commands the package depends on.
* Requires an internet connection. Safe to re-run.
*=========================================================================

ssc install reghdfe,   replace   // high-dimensional fixed-effects regressions
ssc install ftools,    replace   // required by reghdfe
ssc install estout,    replace   // esttab / estpost table export
ssc install gtools,    replace   // gcollapse, gegen (fast collapse/egen)
ssc install xlincom,   replace   // linear combinations of coefficients
ssc install palettes,  replace   // colorpalette
ssc install colrspace, replace   // required by palettes
ssc install blindschemes, replace

* Graph scheme used by every figure (not on SSC)
cap net install cleanplots, from("https://tdmize.github.io/data/cleanplots")

* gtools ships precompiled plugins; refresh them for the local platform
cap gtools, upgrade

display _n "Package installation complete. Next: set projectfolder in code/_paths.do"

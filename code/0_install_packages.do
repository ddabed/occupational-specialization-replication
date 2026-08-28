*=========================================================================
* 0_install_packages.do -- run ONCE before any other file
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

* Graph scheme used by every figure. Not on SSC, so it comes from the author's
* site. Deliberately NOT wrapped in `capture': a silent failure here would only
* show up later as a cryptic scheme error, or as figures drawn in the wrong
* scheme.
capture findfile scheme-cleanplots.scheme
if _rc {
	display _n "Installing the cleanplots scheme..."
	net install cleanplots, from("https://tdmize.github.io/data/cleanplots") replace
}
else display _n "cleanplots scheme already installed."

* gtools ships precompiled plugins; refresh them for the local platform.
* Optional, so failure here is not fatal.
cap gtools, upgrade

*-------------------------------------------------------------------------
* Confirm the two graph schemes are now present
*-------------------------------------------------------------------------
foreach sch in cleanplots plotplain {
	capture findfile scheme-`sch'.scheme
	if _rc {
		display as error _n "scheme `sch' is STILL not installed."
		if "`sch'" == "cleanplots" {
			display as error "Install it by hand with:"
			display as error `"    net install cleanplots, from("https://tdmize.github.io/data/cleanplots") replace"'
		}
		else {
			display as error "It comes from blindschemes: ssc install blindschemes, replace"
		}
	}
	else display "ok  scheme `sch'"
}

display _n "{hline 70}"
display "Package installation done. Next steps:"
display "  1. set {bf:projectfolder} in code/_paths.do"
display "  2. run {bf:0_check_setup.do} to verify everything before the long build"
display "{hline 70}"

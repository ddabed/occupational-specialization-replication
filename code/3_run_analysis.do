clear all

*=========================================================================
* 3_run_analysis.do -- produces every table and figure in the paper
*
* Prerequisites: 0_install_packages.do (once), then 1_build_task_scores.do
* (optional) and 2_build_data.do.
*
* THIS IS THE LONG ONE -- expect days, not hours. Section 1 re-estimates the
* AKM model (worker and firm fixed effects on the full panel) and the local
* projections; those dominate the runtime. Plan it as an unattended run.
*
* All switches below are 1, so a single run reproduces the full package.
* Output file names state which paper float they are, e.g.
*   data/out/tab/table_04_panel_a_monthly_earnings.tex
*   data/out/fig/figure_05_panel_a_lp_earnings.pdf
* See README.md for the complete float -> file map.
*
* Section 1 builds shared intermediate datasets; Section 2 produces the
* tables and figures in paper order. Section 1 rebuilds an intermediate
* whenever any consumer switch is on, so any subset of switches runs.
*=========================================================================

* Locate the shared configuration. Run this file from the package's code/ folder.
capture confirm file "_paths.do"
if _rc {
	display as error "Run this do-file from the package's {bf:code/} folder, e.g."
	display as error `"    cd "<path>/replication-package/code" "'
	exit 601
}
include "_paths.do"

cap log close
log using $path_out_log/3_run_analysis, replace

*-------------------------------------------------------------------------
* Switches  (ordered as tables/figures appear in the paper)
*-------------------------------------------------------------------------

// ---- Main paper ----
*table 1
local summary_stats_allfirms 1
*table 2
local HHI_overall_distribution 1
*table 3
local HHI_dist_over_industries 1
*figure 1
local hhi_3_dig_exposure_bars 1
*table 4
local wage_reg_HHI_3dig 1
*table 5
local wage_reg_HHI1_HHI4_taskcon 1
*table 6
local wage_reg_HHI_3dig_withlayers 1
*figure 2
local wage_reg_HHI_het_plots 1
*figure 3
local wage_reg_share_het 1
*figure 4 (also produces figure A1: TFP panels)
local AKM_firm_HHI 1
*figure 5
local wage_growth_local_projections 1

// ---- Appendix ----
*table A1
local ind_composition_stages 1
*table A2
local anova_HHI_industry 1
*table A3
local HHI_distribution_firmsize 1
*table A4
local wage_reg_occup_spec 1
*table A5
local wage_reg_HHI_3dig_sample_comp 1
*table A6
local wage_reg_singleestab_hrw 1
*table A7
local wage_reg_worker3digoccfe 1
*table A8
local wage_reg_HHI_3dig_occup_het_tab 1
*table A9
local wage_reg_HHI_3dig_ind_het_tab 1
*table A10
local wage_reg_share_transparency 1
*figure A1 -- produced together with figure 4 (AKM_firm_HHI_VA_TFP.do)
*figure A2
local proj_plots_reviewers 1

*=========================================================================
* SECTION 1: Build shared intermediate datasets
*   These do-files produce NO paper output directly; they build datasets
*   that several output do-files in Section 2 depend on. Running them first
*   makes Section 2 work regardless of which output switches are on.
*     - AKM_firm_HHI.do      -> $path_clean_int/AKM_full.dta          (used by figs 4, A1, 5)
*     - local-projections.do -> $path_clean_int/lp_est_exp1(_akm).dta (used by figs 5, A2)
*   local-projections.do reads AKM_full.dta, so AKM must be built first.
*=========================================================================

* AKM firm fixed effects (needed by figures 4, A1, and 5)
if (`AKM_firm_HHI' == 1 | `wage_growth_local_projections' == 1 | `proj_plots_reviewers' == 1) {
   do "$path_do_sub/AKM_firm_HHI.do"        // estimates AKM firm/worker FE -> AKM_full.dta
}
* Local projection estimates (needed by figures 5 and A2)
if (`wage_growth_local_projections' == 1 | `proj_plots_reviewers' == 1) {
   do "$path_do_sub/local-projections.do"   // -> lp_est_exp1.dta, lp_est_exp1_akm.dta
}

*=========================================================================
* SECTION 2: Produce paper output (tables & figures, in paper order)
*=========================================================================

*===== Main paper =====

*table 1
if (`summary_stats_allfirms' == 1) {
   do "$path_do_sub/summary_stats_workers_combined.do"
   do "$path_do_sub/summary_stats_firms_combined.do"
}
*table 2
if (`HHI_overall_distribution' == 1) {
   do "$path_do_sub/HHI_overall_distribution.do"
   do "$path_do_sub/HHI_overall_distribution_emp_weighted.do"
}
*table 3
if (`HHI_dist_over_industries' == 1) {
   do "$path_do_sub/HHI_dist_over_industries.do"
}
*figure 1
if (`hhi_3_dig_exposure_bars' == 1) {
   do "$path_do_sub/hhi_3dig_exposure_bar_plots_demographics.do"
   do "$path_do_sub/hhi_3dig_exposure_bar_plots_occupation.do"
}
*table 4
if (`wage_reg_HHI_3dig' == 1) {
   do "$path_do_sub/wage_reg_HHI_3dig.do"
}
*table 5
if (`wage_reg_HHI1_HHI4_taskcon' == 1) {
   do "$path_do_sub/wage_reg_HHI1dig_HHI4dig_taskcon.do"
}
*table 6
if (`wage_reg_HHI_3dig_withlayers' == 1) {
   do "$path_do_sub/wage_reg_HHI_3dig_withlayers.do"
}
*figure 2
if (`wage_reg_HHI_het_plots' == 1) {
   do "$path_do_sub/occ1_interaction_wage_rank_withbubbles_hoursweighted.do"
   do "$path_do_sub/wage_reg_HHI_3dig_ind_het_plots.do"
}
*figure 3
if (`wage_reg_share_het' == 1) {
   do "$path_do_sub/wage_reg_share_occ_heterogeneity_coef_plot.do"
}
*figure 4  (also produces figure A1: TFP panels; AKM_full.dta built in Section 1)
if (`AKM_firm_HHI' == 1) {
   do "$path_do_sub/AKM_firm_HHI_VA_TFP.do" // Panels for value added (fig 4) and TFP (fig A1)
}
*figure 5  (LP estimates built in Section 1)
if (`wage_growth_local_projections' == 1) {
   do "$path_do_sub/local-projections-plots.do" // make local projection graphs
}

*===== Appendix =====

*table A1
if (`ind_composition_stages' == 1) {
   do "$path_do_sub/ind_composition_stages.do"
}
*table A2
if (`anova_HHI_industry' == 1) {
   do "$path_do_sub/anova_HHI_industry.do"
}
*table A3
if (`HHI_distribution_firmsize' == 1) {
   do "$path_do_sub/HHI_distribution_firmsize.do"
}
*table A4
if (`wage_reg_occup_spec' == 1) {
   do "$path_do_sub/wage_reg_main_occup_specialization.do"
}
*table A5
if (`wage_reg_HHI_3dig_sample_comp' == 1) {
   do "$path_do_sub/wage_reg_HHI_3dig_sample_comp.do"
}
*table A6
if (`wage_reg_singleestab_hrw' == 1) {
   do "$path_do_sub/wage_reg_HHI_3dig_singleestab_hr_weighted.do"
}
*table A7
if (`wage_reg_worker3digoccfe' == 1) {
   do "$path_do_sub/wage_reg_HHI_3dig_worker3digoccfe.do"
}
*table A8
if (`wage_reg_HHI_3dig_occup_het_tab' == 1) {
   do "$path_do_sub/wage_reg_HHI_3dig_interacted.do"
}
*table A9
if (`wage_reg_HHI_3dig_ind_het_tab' == 1) {
   do "$path_do_sub/wage_reg_HHI_3dig_ind_het_table.do"
}
*table A10
if (`wage_reg_share_transparency' == 1) {
   do "$path_do_sub/wage_reg_share_transparency.do"
}
*figure A1 -- produced together with figure 4 (see AKM_firm_HHI_VA_TFP.do above)
*figure A2
if (`proj_plots_reviewers' == 1) {
   do "$path_do_sub/local-projections-plots-reviewers.do"
}

cap log close

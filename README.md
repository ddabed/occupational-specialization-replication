# Replication package

**Firm Organization and Worker Outcomes: The Role of Occupational Specialization**
Guido Matias Cortes, Diego Dabed, Ana Oliveira, Anna Salomons

This repository contains the complete code to reproduce every table and figure in
the paper. Every output file is named for the paper float it produces (see
[Output map](#output-map)).

The underlying microdata are confidential and are **not** included. See
[`data/raw/README.md`](data/raw/README.md) for how to obtain access.

---

## Software requirements

| | |
|---|---|
| Stata | 17 or later |
| R | 4.0 or later, with `haven`, `dplyr`, `data.table` |
| Stata packages | installed by `code/0_install_packages.do` |

## Setup

1. Run `code/0_install_packages.do` once. It installs `reghdfe`, `ftools`,
   `estout`, `gtools`, `xlincom`, `palettes`, `colrspace`, `blindschemes` and the
   `cleanplots` graph scheme.
2. Set the package root in **two** places — they must match:
   - `projectfolder` in [`code/_paths.do`](code/_paths.do)
   - `projectfolder` at the top of [`code/subfiles/makepanel.R`](code/subfiles/makepanel.R)
3. Place the raw data under `data/raw/` as described in
   [`data/raw/README.md`](data/raw/README.md).

All other directories (`data/clean/`, `data/out/fig/`, `data/out/tab/`,
`data/out/log/`, `data/tmp/`) are created automatically. Stata's `save`,
`graph export` and `esttab` do not create directories, so `_paths.do` makes them
all up front — a missing folder would otherwise mean output is silently skipped.

## Running

Run the Stata files from the `code/` folder (they `include "_paths.do"` by
relative path and will stop with an explanatory error otherwise):

```stata
cd "<path>/replication-package/code"
```

### Step 1 — build the analysis datasets

`1_build_data.do` runs in three phases, because the panel construction happens in
R. Set the two globals at the top of the file for each phase:

| Phase | Globals | What it does |
|---|---|---|
| 1 | `runpart1 1`, `runpart3 0` | Converts the raw QdP files from SPSS and renames variables to English |
| 2 | *(run `code/subfiles/makepanel.R` in R)* | Builds the three panel datasets and the `ind_composition` logs |
| 3 | `runpart1 0`, `runpart3 1` | Labels the three panels and builds `va_tfp_data/tfp_va_data` |

Datasets produced, all consumed by step 2:

- `data/clean/panel/2010-2019-regression.dta` — min firm size 10, **main sample**
- `data/clean/panel/2010-2019-regression-5ormore.dta` — min firm size 5
- `data/clean/panel/allfirms/2010-2019-regression-allfirms.dta` — all firms
- `data/clean/intermediate/va_tfp_data/tfp_va_data.dta` — `tfp_cd_wb`, `lva`, `valueadded_mp`
- `data/raw/QdP-renamed/workers_renamed_occlabel{2010..2019}.dta`

### Step 2 — produce the tables and figures

```stata
do 2_run_analysis.do
```

All switches in the file are set to `1`, so one run reproduces the whole package.
Tables land in `data/out/tab/` as `.tex` fragments; figures land in
`data/out/fig/` as `.pdf`.

The file runs in two sections:

- **Section 1** builds shared intermediates that produce no output of their own:
  `AKM_firm_HHI.do` → `AKM_full.dta`, then `local-projections.do` →
  `lp_est_exp1.dta` and `lp_est_exp1_akm.dta`. Section 1 rebuilds an intermediate
  whenever any switch that consumes it is on, so **any subset of output switches
  runs correctly** without manual ordering.
- **Section 2** produces the tables and figures in paper order.

Dependency to be aware of if you edit the switches: `local-projections.do` reads
`AKM_full.dta`, so the AKM step must run before the local-projection step.

## Output map

Every output file states its paper float. 45 files, 23 floats.

| Paper float | Output file | Produced by (`code/subfiles/`) |
|---|---|---|
| Table 1, Panel A | `table_01_panel_a_summary_stats_workers.tex` | `summary_stats_workers_combined.do` |
| Table 1, Panel B | `table_01_panel_b_summary_stats_firms.tex` | `summary_stats_firms_combined.do` |
| Table 2, Panel A | `table_02_panel_a_specialization_distribution.tex` | `HHI_overall_distribution.do` |
| Table 2, Panel B | `table_02_panel_b_specialization_distribution_emp_weighted.tex` | `HHI_overall_distribution_emp_weighted.do` |
| Table 3 | `table_03_specialization_across_industries.tex` | `HHI_dist_over_industries.do` |
| Table 4, Panel A | `table_04_panel_a_monthly_earnings.tex` | `wage_reg_HHI_3dig.do` |
| Table 4, Panel B | `table_04_panel_b_monthly_hours.tex` | `wage_reg_HHI_3dig.do` |
| Table 4, Panel C | `table_04_panel_c_hourly_wage.tex` | `wage_reg_HHI_3dig.do` |
| Table 5, Panel A | `table_05_panel_a_alt_measures_monthly_earnings.tex` | `wage_reg_HHI1dig_HHI4dig_taskcon.do` |
| Table 5, Panel B | `table_05_panel_b_alt_measures_monthly_hours.tex` | `wage_reg_HHI1dig_HHI4dig_taskcon.do` |
| Table 5, Panel C | `table_05_panel_c_alt_measures_hourly_wage.tex` | `wage_reg_HHI1dig_HHI4dig_taskcon.do` |
| Table 6, Panel A | `table_06_panel_a_layers_monthly_earnings.tex` | `wage_reg_HHI_3dig_withlayers.do` |
| Table 6, Panel B | `table_06_panel_b_layers_monthly_hours.tex` | `wage_reg_HHI_3dig_withlayers.do` |
| Table 6, Panel C | `table_06_panel_c_layers_hourly_wage.tex` | `wage_reg_HHI_3dig_withlayers.do` |
| Table A1 | `table_a01_industry_composition.tex` | `ind_composition_stages.do` |
| Table A2 | `table_a02_anova_fixed_effects.tex` | `anova_HHI_industry.do` |
| Table A3 | `table_a03_specialization_by_firm_size.tex` | `HHI_distribution_firmsize.do` |
| Table A4, Panel A | `table_a04_panel_a_largest_occupation_monthly_earnings.tex` | `wage_reg_main_occup_specialization.do` |
| Table A4, Panel B | `table_a04_panel_b_largest_occupation_monthly_hours.tex` | `wage_reg_main_occup_specialization.do` |
| Table A4, Panel C | `table_a04_panel_c_largest_occupation_hourly_wage.tex` | `wage_reg_main_occup_specialization.do` |
| Table A5, Panel A | `table_a05_panel_a_size_cutoffs_monthly_earnings.tex` | `wage_reg_HHI_3dig_sample_comp.do` |
| Table A5, Panel B | `table_a05_panel_b_size_cutoffs_monthly_hours.tex` | `wage_reg_HHI_3dig_sample_comp.do` |
| Table A5, Panel C | `table_a05_panel_c_size_cutoffs_hourly_wage.tex` | `wage_reg_HHI_3dig_sample_comp.do` |
| Table A6, Panel A | `table_a06_panel_a_singleestab_hoursweighted_monthly_earnings.tex` | `wage_reg_HHI_3dig_singleestab_hr_weighted.do` |
| Table A6, Panel B | `table_a06_panel_b_singleestab_hoursweighted_monthly_hours.tex` | `wage_reg_HHI_3dig_singleestab_hr_weighted.do` |
| Table A6, Panel C | `table_a06_panel_c_singleestab_hoursweighted_hourly_wage.tex` | `wage_reg_HHI_3dig_singleestab_hr_weighted.do` |
| Table A7, Panel A | `table_a07_panel_a_alt_fixed_effects_monthly_earnings.tex` | `wage_reg_HHI_3dig_worker3digoccfe.do` |
| Table A7, Panel B | `table_a07_panel_b_alt_fixed_effects_monthly_hours.tex` | `wage_reg_HHI_3dig_worker3digoccfe.do` |
| Table A7, Panel C | `table_a07_panel_c_alt_fixed_effects_hourly_wage.tex` | `wage_reg_HHI_3dig_worker3digoccfe.do` |
| Table A8 | `table_a08_heterogeneity_occupation.tex` | `wage_reg_HHI_3dig_interacted.do` |
| Table A9 | `table_a09_heterogeneity_industry.tex` | `wage_reg_HHI_3dig_ind_het_table.do` |
| Table A10 | `table_a10_pay_transparency.tex` | `wage_reg_share_transparency.do` |
| Figure 1, Panel A | `figure_01_panel_a_exposure_demographics.pdf` | `hhi_3dig_exposure_bar_plots_demographics.do` |
| Figure 1, Panel B | `figure_01_panel_b_exposure_occupation.pdf` | `hhi_3dig_exposure_bar_plots_occupation.do` |
| Figure 2, Panel A | `figure_02_panel_a_heterogeneity_occupation.pdf` | `occ1_interaction_wage_rank_withbubbles_hoursweighted.do` |
| Figure 2, Panel B | `figure_02_panel_b_heterogeneity_industry.pdf` | `wage_reg_HHI_3dig_ind_het_plots.do` |
| Figure 3 | `figure_03_heterogeneity_occupation_size.pdf` | `wage_reg_share_occ_heterogeneity_coef_plot.do` |
| Figure 4, Panel A | `figure_04_panel_a_akm_value_added.pdf` | `AKM_firm_HHI_VA_TFP.do` |
| Figure 4, Panel B | `figure_04_panel_b_akm_value_added_decomposition.pdf` | `AKM_firm_HHI_VA_TFP.do` |
| Figure 5, Panel A | `figure_05_panel_a_lp_earnings.pdf` | `local-projections-plots.do` |
| Figure 5, Panel B | `figure_05_panel_b_lp_switching.pdf` | `local-projections-plots.do` |
| Figure A1, Panel A | `figure_a01_panel_a_akm_tfp.pdf` | `AKM_firm_HHI_VA_TFP.do` |
| Figure A1, Panel B | `figure_a01_panel_b_akm_tfp_decomposition.pdf` | `AKM_firm_HHI_VA_TFP.do` |
| Figure A2, Panel A | `figure_a02_panel_a_lp_occupation_stayers.pdf` | `local-projections-plots-reviewers.do` |
| Figure A2, Panel B | `figure_a02_panel_b_lp_akm_controlled.pdf` | `local-projections-plots-reviewers.do` |

## Notes on the code

- **Two figure notes are not written by default.** `local-projections-plots.do`
  contains commented-out blocks that write `*_note.tex` files reporting the range
  of observation counts across horizons for the Figure 5 panels; the same exists
  for Figure A2 Panel B in `local-projections-plots-reviewers.do`. These are left
  commented because the counts require statistical-disclosure clearance before
  release. Uncomment them if you have cleared output.
- **Input not built by the pipeline.** `data/raw/scores_isco4dig.dta` is a
  pre-made task-scores-by-ISCO4 lookup used by `1_build_data.do` (Step 3) and by
  Table 5. It must be present before running.
- **`ind_het_plots_manuallabels.grec`** holds the manual label positions for
  Figure 2, Panel B and is applied by `wage_reg_HHI_3dig_ind_het_plots.do`.
- Standard errors are clustered on `clustervar`, set once in `_paths.do` (firm id).

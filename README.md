# Replication package

**Firm Organization and Worker Outcomes: The Role of Occupational Specialization**
Guido Matias Cortes, Diego Dabed, Ana Oliveira, Anna Salomons

This repository contains the complete code to reproduce every table and figure in
the paper. Every output file is named for the paper float it produces (see
[Output map](#output-map)).

The underlying microdata are confidential and are **not** included. See
[`data/raw/README.md`](data/raw/README.md) for how to obtain access.

---

## Layout

```
code/
├── _paths.do                  set `projectfolder' here -- the only path you must edit
├── 0_install_packages.do      run once
├── 1_build_task_scores.do     O*Net -> data/raw/scores_isco4dig.dta   (optional)
├── 2_build_data.do            raw microdata -> analysis panels (runs R for you)
├── 3_run_analysis.do          panels -> every table and figure
└── subfiles/
    ├── onet/                  the 6 do-files behind 1_build_task_scores.do
    ├── build_1_rename_raw_files.do   step 1 of the data build
    ├── makepanel.R                   step 2 of the data build (R)
    ├── build_3_label_and_merge.do    step 3 of the data build
    └── *.do                   26 output do-files + 2 shared-intermediate builders
data/
├── raw/                       inputs; see data/raw/README.md
├── clean/                     built datasets (created by the code)
└── out/{fig,tab,log}/         paper output (created by the code)
```

## Software requirements

| | |
|---|---|
| Stata | 17 or later |
| R | 4.0 or later, with `haven`, `readxl`, `fixest`, `xtable`, `docstring`, `dplyr`, `data.table` |
| `Rscript` | reachable from Stata's `shell` (see setup step 3) |
| Stata packages | installed by `code/0_install_packages.do` |

## Setup

1. Run `code/0_install_packages.do` once. It installs `reghdfe`, `ftools`,
   `estout`, `gtools`, `xlincom`, `palettes`, `colrspace`, `blindschemes` and the
   `cleanplots` graph scheme.
2. Set `projectfolder` in [`code/_paths.do`](code/_paths.do) to the folder
   holding `code/` and `data/`. **This is the only path you have to set** — it is
   passed through to the R step automatically.
3. If `Rscript` is not on your `PATH` (common on Windows), also set
   `global Rscript` in `_paths.do` to the full path of `Rscript.exe`.
4. Place the raw data under `data/raw/` as described in
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

### Step 1 — build the O*Net task scores *(optional)*

```stata
do 1_build_task_scores.do
```

Rebuilds `data/raw/scores_isco4dig.dta` — the O*Net task composites mapped onto
ISCO-08 4-digit codes, which feed the task-concentration measure in Table 5.

**This step is optional.** The built file ships with the package, so you only
need to run it to reproduce the lookup from source. It is the one stage that runs
entirely on public data: it needs the O*NET 21.0 (2016) text release, which is a
free download (see [`data/raw/README.md`](data/raw/README.md)) and is not
included here. Everything downstream requires the confidential microdata.

### Step 2 — build the analysis datasets

```stata
do 2_build_data.do
```

**One run does everything.** The build has three internal steps, and
`2_build_data.do` performs all of them in order, launching R for you:

| Step | Runs | What it does |
|---|---|---|
| 1 | `subfiles/build_1_rename_raw_files.do` (Stata) | Converts the raw QdP files from SPSS and renames variables to English |
| 2 | `subfiles/makepanel.R` (R, launched via `Rscript`) | Builds the three panel datasets and the `ind_composition` logs |
| 3 | `subfiles/build_3_label_and_merge.do` (Stata) | Labels the three panels and builds `va_tfp_data/tfp_va_data` |

Step 2 receives `$projectfolder` as a command-line argument, so the path is never
set in two places. After R finishes, `2_build_data.do` confirms the three panel
datasets exist before continuing — if R failed, it stops with the reason and
prints the exact command to run the R step by hand.

**Restarting after a failure.** The three switches at the top of
`2_build_data.do` are all `1`. Set one to `0` to *skip* work already done — for
example, after fixing an R problem and running `makepanel.R` yourself, set
`global do_step2_panel 0`. Leaving all three at `1` always produces a complete
build, so forgetting to change them cannot silently give you a partial result.

If you would rather drive R yourself, set `global do_step2_panel 0` and run:

```sh
Rscript code/subfiles/makepanel.R "/path/to/replication-package"
```

Datasets produced, all consumed by step 3:

- `data/clean/panel/2010-2019-regression.dta` — min firm size 10, **main sample**
- `data/clean/panel/2010-2019-regression-5ormore.dta` — min firm size 5
- `data/clean/panel/allfirms/2010-2019-regression-allfirms.dta` — all firms
- `data/clean/intermediate/va_tfp_data/tfp_va_data.dta` — `tfp_cd_wb`, `lva`, `valueadded_mp`
- `data/raw/QdP-renamed/workers_renamed_occlabel{2010..2019}.dta`

### Step 3 — produce the tables and figures

```stata
do 3_run_analysis.do
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
- **`scores_isco4dig.dta` is committed, not generated on demand.** It is used by
  `2_build_data.do` (Step 3) and by Table 5. `1_build_task_scores.do` rebuilds it
  from the O*NET release if you want to verify it.
- **`ind_het_plots_manuallabels.grec`** holds the manual label positions for
  Figure 2, Panel B and is applied by `wage_reg_HHI_3dig_ind_het_plots.do`.
- Standard errors are clustered on `clustervar`, set once in `_paths.do` (firm id).

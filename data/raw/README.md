# Raw data

Four files in this folder are **included** in the repository because they derive
only from public sources. Everything else is confidential and must be obtained
from the data providers before running the code.

## Included in this repository

| File | Description |
|---|---|
| `scores_isco4dig.dta` | O*Net task composites (social skills, routine, cognitive, manual) averaged onto ISCO-08 4-digit codes: 439 rows × 4 scores (see [Note on coverage](#note-on-coverage)). Built by `code/1_build_task_scores.do`. |
| `isco08_soc10_crosswalk.xls` | BLS crosswalk between 2010 SOC and ISCO-08. |
| `INE/PriceIndex.xls` | Portuguese consumer price index (IPC, base 2012), published INE statistics. Read by `makepanel.R` to deflate nominal values. |
| `INE/priceindex.dta` | The same CPI series in Stata format, read by the labelling step. Both formats are kept because the R and Stata portions of the data building process each read their own. |

## Must be obtained separately — confidential

| Path | Source | Description |
|---|---|---|
| `QdP/` | Portuguese Ministry of Labour (GEP/MTSSS) | *Quadros de Pessoal* matched employer–employee data, 2010–2019: worker and firm files, one per year |
| `SCIE/` | Statistics Portugal (INE) | *Sistema de Contas Integradas das Empresas*: firm balance-sheet data (value added at market prices, labour costs, intermediate inputs, capital stock) |

*Quadros de Pessoal* is made available to researchers by the Portuguese Ministry
of Labour (Gabinete de Estratégia e Planeamento, GEP/MTSSS). SCIE is made
available by Statistics Portugal (INE) under a data-use agreement. Both require
an approved research project and a signed confidentiality agreement; neither
dataset may be redistributed by the authors.

Step 1 of `2_build_data.do` writes Stata copies of the QdP files, with English
variable names, to `QdP-renamed/`. Keep this folder after the build: Table 6
(`wage_reg_HHI_3dig_withlayers.do`) reads it directly. It also holds
confidential microdata and may not be redistributed.

## Must be downloaded separately — public

| Path | Source | Description |
|---|---|---|
| `onet/` | O*NET Resource Center | O*NET 21.0 (2016) database, text version |

Only needed if you want to **rebuild** `scores_isco4dig.dta` from source by
running `code/1_build_task_scores.do`. The built file is already included, so
the rest of the package runs without this download.

Download the O*NET 21.0 (2016) text release from
<https://www.onetcenter.org/db_releases.html> and place these four files
directly in `data/raw/onet/` (they come from `db_21_0_text.zip`):

```
data/raw/onet/Abilities.txt
data/raw/onet/Knowledge.txt
data/raw/onet/Skills.txt
data/raw/onet/Work Context.txt
```

`1_build_task_scores.do` checks for all four and stops with an explicit message
if any is missing. Keep the file names exactly as distributed, including the
space in `Work Context.txt`.

## Note on coverage

Three ISCO-08 codes in `scores_isco4dig.dta` (`0110`, `0210`, `0310` — armed
forces) have missing scores, because O*NET does not cover military occupations.
This is inherent to the SOC–ISCO crosswalk and is why a small number of
occupations do not merge downstream.

The file also has one row with an empty ISCO-08 code. It holds the average
scores of the SOC occupations that have no ISCO-08 code in the crosswalk, and
it does not correspond to any occupation. The panel build drops records
without an occupation code (`makepanel.R`) before these scores are merged.

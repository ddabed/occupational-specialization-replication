# Raw data

The microdata used in this paper are **confidential** and cannot be redistributed.
They must be obtained directly from the data providers and placed in this folder
before running the code.

## Required inputs

| Path | Source | Description |
|---|---|---|
| `QdP/` | Portuguese Ministry of Labour, via GEP/MTSSS | *Quadros de Pessoal* matched employer–employee data, 2010–2019: worker and firm files, one per year |
| `SCIE/` | Statistics Portugal (INE) | *Sistema de Contas Integradas das Empresas*: firm balance-sheet data (value added at market prices, labour costs, intermediate inputs, capital stock) |
| `INE/` | Statistics Portugal (INE) | Auxiliary INE files used in the cleaning step |
| `scores_isco4dig.dta` | Derived (see below) | Task-score-by-ISCO-4-digit lookup |

`QdP-renamed/` is created by `1_build_data.do` (Phase 1) and holds the
English-renamed versions of the raw QdP files. Do not populate it by hand.

## Access

*Quadros de Pessoal* is made available to researchers by the Portuguese Ministry
of Labour (Gabinete de Estratégia e Planeamento, GEP/MTSSS). SCIE is made
available by Statistics Portugal (INE) under a data-use agreement. Both require an
approved research project and a signed confidentiality agreement; neither dataset
may be redistributed by the authors.

## `scores_isco4dig.dta`

This is a crosswalk of task scores to 4-digit ISCO occupation codes, used to build
the task-concentration measure (Table 5) and by `1_build_data.do` Step 3. It is not
built by the code in this package.

<!-- TODO(authors): state the source of scores_isco4dig.dta (which task database,
     which crosswalk) and whether it can be shared, so replicators can rebuild it. -->

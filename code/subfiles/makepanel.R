#-------------------------------#
# Install required packages if missing
#-------------------------------#
#install.packages(
#  c("readxl", "haven", "fixest", "xtable", "docstring", "dplyr", "data.table"),
#  type = "source",
#  repos = "https://cloud.r-project.org"
#)

.required <- c("haven", "readxl", "fixest", "xtable",
               "docstring", "dplyr", "data.table")
.missing <- .required[!vapply(.required, requireNamespace, logical(1),
                              quietly = TRUE)]
if (length(.missing)) {
  stop("Missing R packages: ", paste(.missing, collapse = ", "),
       "\nInstall them with:\n  install.packages(c(",
       paste0('"', .missing, '"', collapse = ", "), "))",
       call. = FALSE)
}
invisible(lapply(.required, library, character.only = TRUE))

#-------------------------------#
# Set working directory here
#-------------------------------#

# 2_build_data.do launches this script and passes the package root as the
# first argument, so normally there is nothing to set here.
#
# Only if you run this script BY HAND (rather than via 2_build_data.do) do you
# need to set the fallback below to the folder holding code/ and data/.
projectfolder <- "/CHANGE/ME/path/to/replication-package"

.args <- commandArgs(trailingOnly = TRUE)
if (length(.args) >= 1 && nzchar(.args[1])) {
  projectfolder <- .args[1]
  message("Package root taken from command line: ", projectfolder)
}

if (grepl("^/CHANGE/ME", projectfolder)) {
  stop("No package root given. Either run this via 2_build_data.do, or pass it:\n",
       '  Rscript makepanel.R "/path/to/replication-package"\n',
       "or set `projectfolder' at the top of this file.", call. = FALSE)
}
if (!dir.exists(projectfolder)) {
  stop("Package root does not exist: ", projectfolder, call. = FALSE)
}
setwd(projectfolder)

#-------------------------------#
# Directory layout
#-------------------------------#
# Mirrors the globals in code/_paths.do. If you change the layout there,
# change it here too -- these are the only path definitions in this script.
path_raw          <- file.path(projectfolder, "data", "raw")
path_raw_QdPren   <- file.path(path_raw, "QdP-renamed")
path_raw_INE      <- file.path(path_raw, "INE")
path_clean_panel  <- file.path(projectfolder, "data", "clean", "panel")
path_out_log      <- file.path(projectfolder, "data", "out", "log")
path_out_log_ind  <- file.path(path_out_log, "ind_composition")

dir.create(path_clean_panel,                       showWarnings = FALSE, recursive = TRUE)
dir.create(file.path(path_clean_panel, "allfirms"), showWarnings = FALSE, recursive = TRUE)
dir.create(path_out_log,                           showWarnings = FALSE, recursive = TRUE)
dir.create(path_out_log_ind,                       showWarnings = FALSE, recursive = TRUE)

#-------------------------------#
# Helper functions
#-------------------------------#

compute_firm_specialization_weighted <- function(dt, colName){
  dt <- dt[!is.na(get(colName))]

  dt[, total_hrs_firm := sum(reg_hours_month), by=c("sizeFirm", "year", "fnumber_FIC")]
  agg_firm_occups <- dt[, .(hrs_occ=sum(reg_hours_month)), by=c("total_hrs_firm","year","fnumber_FIC",colName)]

  agg_firm_occups[, share := hrs_occ/total_hrs_firm]
  agg_firm_occups[, wHHI := sum(share**2), by=c("year","fnumber_FIC")]

  return(agg_firm_occups)
}

compute_firm_specialization <- function(dt, colName){
  dt <- dt[!is.na(get(colName))]

  agg_firm_occups <- dt[, .(N = .N, sizeFirm = max(sizeFirm), uniqueSize = uniqueN(sizeFirm)), by=c("year","fnumber_FIC",colName)]

  agg_firm_occups[, share := N/sizeFirm]
  agg_firm_occups[, HHI := sum(share**2), by=c("year","fnumber_FIC")]

  return(agg_firm_occups)
}

save_ind_composition <- function(dt, stage_label, year) {
  comp <- dt[, .(N = .N), by = fEAC_1let_rev3]
  comp[, pct := round(100 * N / sum(N), 2)]
  comp[, stage := stage_label]
  comp[, year := year]
  fwrite(comp, file.path(path_out_log_ind, paste0(stage_label, "_", year, ".csv")))
}

# helper: safely turn a vector into year integers
extract_year <- function(v) {
  if (inherits(v, "Date") || inherits(v, "POSIXt")) return(as.integer(format(v, "%Y")))
  if (is.numeric(v)) return(as.integer(format(as.Date(v, origin = "1970-01-01"), "%Y")))
  if (is.character(v)) {
    y <- suppressWarnings(as.integer(regmatches(v, regexpr("\\d{4}", v))))
    return(y)
  }
  rep(NA_integer_, length(v))
}

#-------------------------------#
# Log table helpers
#-------------------------------#

make_empty_log <- function() {
  data.table(
    year                  = integer(),
    obs_before_total      = integer(),
    obs_missing_w_numer   = integer(),
    obs_missing_hours     = integer(),
    obs_zero_hours        = integer(),
    obs_missing_occu      = integer(),
    obs_missing_educ      = integer(),
    obs_agri_firm         = integer(),
    obs_full_sample       = integer(),
    obs_small_firms       = integer(),
    pct_estimation_sample = numeric()
  )
}

make_log_totals <- function(log_dt) {
  log_dt[, .(
    year                  = 9999L,
    obs_before_total      = sum(obs_before_total),
    obs_missing_w_numer   = sum(obs_missing_w_numer),
    obs_missing_hours     = sum(obs_missing_hours),
    obs_zero_hours        = sum(obs_zero_hours),
    obs_missing_occu      = sum(obs_missing_occu),
    obs_missing_educ      = sum(obs_missing_educ),
    obs_agri_firm         = sum(obs_agri_firm),
    obs_full_sample       = sum(obs_full_sample),
    obs_small_firms       = sum(obs_small_firms),
    pct_estimation_sample = round(100 * (sum(obs_full_sample) - sum(obs_small_firms)) / sum(obs_full_sample), 1)
  )]
}

#-------------------------------#
# Data cleaning function
# min_size: minimum firm size to keep (1 = all firms, 5, 10, ...)
# cpi_table: data.frame with columns 'year' and 'cpi', loaded once outside
# log_zero_hours: if TRUE, writes zero-hours characterization CSVs
#-------------------------------#

prep_data_for_reg <- function(year, min_size, cpi_table, log_zero_hours = FALSE) {

  file_name <- file.path(path_raw_QdPren, paste0("workers_renamed_occlabel", year, ".dta"))
  dt <- as.data.table(read_dta(file_name))

  obs_before_total <- dt[,.N]
  print(paste("Observations this year total:", obs_before_total))

  # Remove missing worker IDs first
  before_n <- dt[,.N]
  dt <- dt[w_numer != 0]
  obs_missing_w_numer <- before_n - dt[,.N]
  print(paste("Observations lost this year with missing worker ID:", obs_missing_w_numer))

  # Count missing vs. zero hours separately
  obs_missing_hours <- sum(is.na(dt$reg_hours_month))
  print(paste("Observations lost this year with missing hours:", obs_missing_hours))

  dt <- dt[!is.na(reg_hours_month)]

  obs_zero_hours <- sum(dt$reg_hours_month == 0)
  print(paste("Observations lost this year with zero hours:", obs_zero_hours))

  # Characterize firms with zero hours (only on designated pass)
  if (log_zero_hours && obs_zero_hours > 0) {
    firm_size_full <- dt[, .(full_size = .N), by = fnumber_FIC]
    dt_zero_hours  <- dt[reg_hours_month == 0, .(fnumber_FIC)]
    firm_file      <- file.path(path_raw_QdPren, paste0("firms_renamed", year, ".dta"))
    firms_ind      <- as.data.table(read_dta(firm_file))[, .(fnumber_FIC, fEAC_1let_rev3)]
    dt_zero_hours  <- merge(dt_zero_hours, firm_size_full, by = "fnumber_FIC", all.x = TRUE)
    dt_zero_hours  <- merge(dt_zero_hours, firms_ind,     by = "fnumber_FIC", all.x = TRUE)
    dt_zero_hours[, size_bin := cut(full_size,
                                    breaks = c(0, 9, 49, 249, Inf),
                                    labels = c("1-9", "10-49", "50-249", "250+"))]
    summary_zero_hours <- dt_zero_hours[, .N, by = .(fEAC_1let_rev3, size_bin)]
    summary_zero_hours <- dcast(summary_zero_hours, fEAC_1let_rev3 ~ size_bin, value.var = "N", fill = 0)
    fwrite(summary_zero_hours, file.path(path_out_log, paste0("zero_hours_firms_", year, ".csv")))
  }

  # Remove zero regular hours
  dt <- dt[reg_hours_month != 0]

  obs_before_occ <- dt[,.N]
  dt <- dt[!is.na(occup1_10)]
  dt <- dt[!is.na(occup3_10)]
  dt <- dt[!is.na(occup4_10)]
  obs_missing_occu <- obs_before_occ - dt[,.N]
  print(paste("Observations lost this year without occupation:", obs_missing_occu))

  before_n <- dt[,.N]
  print(paste("Observations this year before missing education:", before_n))
  dt <- dt[school_1dig != 9]
  after_n <- dt[,.N]
  obs_missing_educ <- before_n - after_n
  print(paste("Observations lost this year without education:", obs_missing_educ))

  # New variable educ to summarize schooling
  dt[, educ := school_1dig][school_1dig == 2, educ := 1][school_1dig == 3 | school_1dig == 4, educ := 2]
  dt[school_1dig == 5 | school_1dig == 6 | school_1dig == 7 | school_1dig == 8 | school_1dig == 0, educ := 3]

  # Remove too young or too old workers and ageless
  dt <- dt[!(age %in% c(">=68", "<=17", ""))]

  # Make age numerical
  dt$age <- strtoi(dt$age)

  # CPI deflator (pre-loaded outside function)
  dt$cpi <- as.numeric(cpi_table$cpi[cpi_table$year == year])

  dt[, ':='(real_total_rem = total_rem * 100 / cpi,
            total_realhrem = (total_rem * 100 / cpi) / reg_hours_month,
            real_extra_rem = extra_rem * 100 / cpi,
            real_reg_pay   = reg_pay * 100 / cpi,
            real_irreg_pay = irreg_pay * 100 / cpi,
            nominal_wage   = (basic_rem + reg_pay),
            real_hrl_wage  = ((basic_rem + reg_pay) * 100 / cpi) / reg_hours_month,
            real_wage      = (basic_rem + reg_pay) * 100 / cpi)]

  dt[, lreal_hrl_wage := log(real_hrl_wage)]

  # Keep only first MAX wage value per worker for the year
  dt <- dt[dt[, .I[which.max(nominal_wage)], by = 'w_numer']$V1]

  # Get year of promotion data (robust to missing/various types)
  if ("promotion_date" %in% names(dt)) {
    dt[, promotion_year := extract_year(promotion_date)]
  } else {
    message("No promotion_date in file for year: ", year)
    dt[, promotion_year := NA_integer_]
  }

  # Get year of hiring data (robust to missing/various types)
  if ("hiring_date" %in% names(dt)) {
    dt[, hiring_year := extract_year(hiring_date)]
  } else {
    message("No hiring_date in file for year: ", year)
    dt[, hiring_year := NA_integer_]
  }

  # Full time job
  dt[, full_time := 2 - reg_dur]

  # Import firm info
  file_name <- file.path(path_raw_QdPren, paste0("firms_renamed", year, ".dta"))
  firms <- as.data.table(read_dta(file_name))
  firms <- firms[, c('year', 'fnumber_FIC', "fEAC_1let_rev3", "fEAC_34dig_rev3",
                     "fbirth_year", "fsales", "fNUTS2")]

  # Merge
  dt <- merge(dt, firms, by = c("fnumber_FIC", "year"))

  save_ind_composition(dt, "raw", year)

  before_n <- copy(after_n)
  print(paste("Observations this year before dropping agricultural workers:", before_n))
  # Remove Agriculture workers
  dt <- dt[!(occup3_10 %in% c(131, 611, 612, 613, 621, 622, 921))]

  print(paste("Observations this year before dropping agricultural and other firms:", before_n))
  # Drop agricultural and other firms
  dt <- dt[fEAC_1let_rev3 != 'A']
  dt <- dt[fEAC_1let_rev3 != 'O']
  dt <- dt[fEAC_1let_rev3 != 'U']
  after_n <- dt[,.N]

  obs_agri_firm <- before_n - after_n
  print(paste("Observations lost this year agricultural workers and firms:", obs_agri_firm))

  # Dummy for being Portuguese native
  dt$native <- (dt$nationality == "PT")

  # Dummy for female
  dt$female <- dt$gender - 1

  # Compute size of firm
  dt[, sizeFirm := .N, by = c("fnumber_FIC", "year")]

  # Specialization (hours-weighted)
  specialization_1dig <- compute_firm_specialization_weighted(dt, "occup1_10")
  dt <- merge(dt, specialization_1dig,
              by = c("fnumber_FIC", "year", "occup1_10"),
              suffixes = c("", "_1dig"))
  colnames(dt)[colnames(dt)=="hrs_occ"] <- "hrs_occ_1dig"
  colnames(dt)[colnames(dt)=="share"]   <- "sharew_1dig"
  colnames(dt)[colnames(dt)=="wHHI"]    <- "HHIw_1dig"

  specialization_3dig <- compute_firm_specialization_weighted(dt, "occup3_10")
  dt <- merge(dt, specialization_3dig,
              by = c("fnumber_FIC", "year", "occup3_10"),
              suffixes = c("", "_3dig"))
  colnames(dt)[colnames(dt)=="hrs_occ"] <- "hrs_occ_3dig"
  colnames(dt)[colnames(dt)=="share"]   <- "sharew_3dig"
  colnames(dt)[colnames(dt)=="wHHI"]    <- "HHIw_3dig"

  specialization_4dig <- compute_firm_specialization_weighted(dt, "occup4_10")
  dt <- merge(dt, specialization_4dig,
              by = c("fnumber_FIC", "year", "occup4_10"),
              suffixes = c("", "_4dig"))
  colnames(dt)[colnames(dt)=="hrs_occ"] <- "hrs_occ_4dig"
  colnames(dt)[colnames(dt)=="share"]   <- "sharew_4dig"
  colnames(dt)[colnames(dt)=="wHHI"]    <- "HHIw_4dig"

  # Specialization (count-based)
  specialization_1dig <- compute_firm_specialization(dt, "occup1_10")
  dt <- merge(dt, specialization_1dig,
              by = c("fnumber_FIC", "year", "sizeFirm", "occup1_10"),
              suffixes = c("", "_1dig"))
  colnames(dt)[colnames(dt)=="N"]   <- "N_1dig"
  colnames(dt)[colnames(dt)=="share"] <- "share_1dig"
  colnames(dt)[colnames(dt)=="HHI"]   <- "HHI_1dig"

  specialization_3dig <- compute_firm_specialization(dt, "occup3_10")
  dt <- merge(dt, specialization_3dig,
              by = c("fnumber_FIC", "year", "sizeFirm", "occup3_10"),
              suffixes = c("", "_3dig"))
  colnames(dt)[colnames(dt)=="N"]     <- "N_3dig"
  colnames(dt)[colnames(dt)=="share"] <- "share_3dig"
  colnames(dt)[colnames(dt)=="HHI"]   <- "HHI_3dig"

  specialization_4dig <- compute_firm_specialization(dt, "occup4_10")
  dt <- merge(dt, specialization_4dig,
              by = c("fnumber_FIC", "year", "sizeFirm", "occup4_10"),
              suffixes = c("", "_4dig"))
  colnames(dt)[colnames(dt)=="N"]     <- "N_4dig"
  colnames(dt)[colnames(dt)=="share"] <- "share_4dig"
  colnames(dt)[colnames(dt)=="HHI"]   <- "HHI_4dig"

  dt[, share_1dig_max := max(share_1dig)[1], by = c("fnumber_FIC", "year")]
  dt[, share_3dig_max := max(share_3dig)[1], by = c("fnumber_FIC", "year")]
  dt[, share_4dig_max := max(share_4dig)[1], by = c("fnumber_FIC", "year")]

  # Share of workers that have some college
  dt[, share_college := as.double(0), by = c('fnumber_FIC', 'year')]
  dt[educ==3, share_college := .N, by = c('fnumber_FIC', 'year')]
  dt[, share_college := max(share_college, na.rm=TRUE), by = c('fnumber_FIC', 'year')]
  dt[, share_college := share_college / sizeFirm]

  # Generate quintiles, decile and percentile based on the worker per year
  dt[, workerQuintile_1dig := .bincode(x = ntile(share_1dig, 100),
                                       breaks = seq(0,100,20), right = TRUE,
                                       include.lowest = TRUE), by = occup1_10]
  dt[, workerDecile_1dig := .bincode(x = ntile(share_1dig, 100),
                                     breaks = seq(0,100,10), right = TRUE,
                                     include.lowest = TRUE), by = occup1_10]
  dt[, workerPercentile_1dig := .bincode(x = ntile(share_1dig, 100),
                                         breaks = seq(0,100,1), right = TRUE,
                                         include.lowest = TRUE), by = occup1_10]

  # Homogenize (tie-break) per firm (max quintile)
  dt[, workerQuintile_1dig   := max(workerQuintile_1dig),   by = c("occup1_10", "fnumber_FIC")]
  dt[, workerDecile_1dig     := max(workerDecile_1dig),     by = c("occup1_10", "fnumber_FIC")]
  dt[, workerPercentile_1dig := max(workerPercentile_1dig), by = c("occup1_10", "fnumber_FIC")]

  dt[, workerQuintile_3dig := .bincode(x = ntile(share_3dig, 100),
                                       breaks = seq(0,100,20), right = TRUE,
                                       include.lowest = TRUE), by = occup3_10]
  dt[, workerDecile_3dig := .bincode(x = ntile(share_3dig, 100),
                                     breaks = seq(0,100,10), right = TRUE,
                                     include.lowest = TRUE), by = occup3_10]
  dt[, workerPercentile_3dig := .bincode(x = ntile(share_3dig, 100),
                                         breaks = seq(0,100,1), right = TRUE,
                                         include.lowest = TRUE), by = occup3_10]

  dt[, workerQuintile_3dig   := max(workerQuintile_3dig),   by = c("occup3_10", "fnumber_FIC")]
  dt[, workerDecile_3dig     := max(workerDecile_3dig),     by = c("occup3_10", "fnumber_FIC")]
  dt[, workerPercentile_3dig := max(workerPercentile_3dig), by = c("occup3_10", "fnumber_FIC")]

  # Create 3 digit NACE (industry code)
  dt[, NACE_3dig := as.integer(as.integer(fEAC_34dig_rev3)/10)]

  # Define young workers
  dt[, young := '< 29'][age > 28, young := '>= 29']
  dt$young <- as.factor(dt$young)

  # Keep only first MAX wage value per worker for the year
  dt <- dt[dt[, .I[which.max(total_realhrem)], by = 'w_numer']$V1]

  obs_full_sample <- dt[,.N]
  before_n        <- obs_full_sample
  print(paste("Full sample (all firm sizes) this year:", obs_full_sample))

  save_ind_composition(dt, "presize", year)

  # Apply firm size filter
  dt <- dt[sizeFirm >= min_size]

  after_n               <- dt[,.N]
  obs_small_firms       <- before_n - after_n
  pct_estimation_sample <- round(100 * after_n / obs_full_sample, 1)
  print(paste("Observations lost this year in small firms:", obs_small_firms))
  print(paste0("Estimation sample is ", pct_estimation_sample, "% of Full firm sample"))

  # Log wage and log employment
  dt[, ':='(ltotal_realhrem = log(total_realhrem), lfsize = log(sizeFirm))]

  save_ind_composition(dt, paste0("final_min", min_size), year)

  # Select output columns
  dt <- dt[, c("fnumber_FIC", "year", "sizeFirm", "occup4_10", "occup3_10", "occup1_10",
               "w_numer", "e_ID", "age", "tenure", "type_contract", "type_contract_1",
               "school_1dig", "school_2dig", "school", "occup2_10", "educ", "total_realhrem",
               "promotion_year", "hiring_year", "full_time", "fEAC_1let_rev3", "HHIw_4dig",
               "fEAC_34dig_rev3", "fbirth_year", "fsales", "fNUTS2", "native", "female", "HHIw_3dig",
               "hrs_occ_1dig", "share_1dig", "HHI_1dig", "HHIw_1dig", "hrs_occ_3dig", "share_3dig", "HHI_3dig",
               "hrs_occ_4dig", "share_4dig", "HHI_4dig", "share_1dig_max", "share_3dig_max",
               "share_4dig_max", "share_college", "NACE_3dig", "young",
               "ltotal_realhrem", "lfsize", "total_hrs_firm", "real_hrl_wage", "lreal_hrl_wage",
               "real_wage", "reg_hours_month",
               "real_extra_rem", "real_reg_pay", "real_irreg_pay", "real_total_rem")]

  # Return dt and log row for this year
  list(
    dt  = dt,
    log = data.table(
      year                  = year,
      obs_before_total      = obs_before_total,
      obs_missing_w_numer   = obs_missing_w_numer,
      obs_missing_hours     = obs_missing_hours,
      obs_zero_hours        = obs_zero_hours,
      obs_missing_occu      = obs_missing_occu,
      obs_missing_educ      = obs_missing_educ,
      obs_agri_firm         = obs_agri_firm,
      obs_full_sample       = obs_full_sample,
      obs_small_firms       = obs_small_firms,
      pct_estimation_sample = pct_estimation_sample
    )
  )
}

#-------------------------------#
# Load CPI data once
#-------------------------------#

cpi_table <- read_excel(file.path(path_raw_INE, "PriceIndex.xls"))
names(cpi_table) <- c('year', 'cpi')

#============================================================
# Pass 1: min_size = 10 (main estimation sample)
#============================================================

log_dt_10 <- make_empty_log()

result    <- prep_data_for_reg(2019, min_size = 10, cpi_table, log_zero_hours = TRUE)
dt_10     <- result$dt
log_dt_10 <- rbind(log_dt_10, result$log)

for (year in 2018:2010) {
  print(year)
  result    <- prep_data_for_reg(year, min_size = 10, cpi_table, log_zero_hours = TRUE)
  dt_10     <- rbind(dt_10, result$dt)
  log_dt_10 <- rbind(log_dt_10, result$log)
}

# Aggregate zero-hours characterization across years (generated only in Pass 1)
all_zero  <- rbindlist(lapply(2010:2019, function(y) {
  f <- file.path(path_out_log, paste0("zero_hours_firms_", y, ".csv"))
  if (file.exists(f)) fread(f) else NULL
}))
size_cols <- c("1-9", "10-49", "50-249", "250+")
all_zero  <- all_zero[, lapply(.SD, sum, na.rm = TRUE), by = fEAC_1let_rev3, .SDcols = size_cols]
all_zero[, Total := rowSums(.SD, na.rm = TRUE), .SDcols = size_cols]
col_totals <- c("Total", as.list(colSums(all_zero[, c(size_cols, "Total"), with = FALSE], na.rm = TRUE)))
names(col_totals) <- names(all_zero)
all_zero <- rbind(all_zero, col_totals)
fwrite(all_zero, file.path(path_out_log, "zero_hours_firms_all_years.csv"))

# Winsorize wages 1-99%
percentiles <- quantile(dt_10$lreal_hrl_wage, probs = c(0.01, 0.99), na.rm = TRUE)
dt_10[lreal_hrl_wage < percentiles[1], lreal_hrl_wage := percentiles[1]]
dt_10[lreal_hrl_wage > percentiles[2], lreal_hrl_wage := percentiles[2]]

# Save main dataset (create the output folder if it does not exist)
write_dta(dt_10, file.path(path_clean_panel, "2010-2019-regression.dta"))

# Save log
log_dt_10 <- rbind(log_dt_10, make_log_totals(log_dt_10))
fwrite(log_dt_10,
       file.path(path_out_log, paste0("log_makepanel_10_", format(Sys.time(), "%Y%m%d"), ".csv")),
       row.names = FALSE)

rm(dt_10, samp)
gc()

#============================================================
# Pass 2: min_size = 5
#============================================================

log_dt_5 <- make_empty_log()

result   <- prep_data_for_reg(2019, min_size = 5, cpi_table, log_zero_hours = FALSE)
dt_5     <- result$dt
log_dt_5 <- rbind(log_dt_5, result$log)

for (year in 2018:2010) {
  print(year)
  result   <- prep_data_for_reg(year, min_size = 5, cpi_table, log_zero_hours = FALSE)
  dt_5     <- rbind(dt_5, result$dt)
  log_dt_5 <- rbind(log_dt_5, result$log)
}

percentiles <- quantile(dt_5$lreal_hrl_wage, probs = c(0.01, 0.99), na.rm = TRUE)
dt_5[lreal_hrl_wage < percentiles[1], lreal_hrl_wage := percentiles[1]]
dt_5[lreal_hrl_wage > percentiles[2], lreal_hrl_wage := percentiles[2]]

write_dta(dt_5, file.path(path_clean_panel, "2010-2019-regression-5ormore.dta"))

log_dt_5 <- rbind(log_dt_5, make_log_totals(log_dt_5))
fwrite(log_dt_5,
       file.path(path_out_log, paste0("log_makepanel_5_", format(Sys.time(), "%Y%m%d"), ".csv")),
       row.names = FALSE)

rm(dt_5)
gc()

#============================================================
# Pass 3: min_size = 1 (all firms)
#============================================================

log_dt_all <- make_empty_log()

result     <- prep_data_for_reg(2019, min_size = 1, cpi_table, log_zero_hours = FALSE)
dt_all     <- result$dt
log_dt_all <- rbind(log_dt_all, result$log)

for (year in 2018:2010) {
  print(year)
  result     <- prep_data_for_reg(year, min_size = 1, cpi_table, log_zero_hours = FALSE)
  dt_all     <- rbind(dt_all, result$dt)
  log_dt_all <- rbind(log_dt_all, result$log)
}

percentiles_af <- quantile(dt_all$lreal_hrl_wage, probs = c(0.01, 0.99), na.rm = TRUE)
dt_all[lreal_hrl_wage < percentiles_af[1], lreal_hrl_wage := percentiles_af[1]]
dt_all[lreal_hrl_wage > percentiles_af[2], lreal_hrl_wage := percentiles_af[2]]

write_dta(dt_all, file.path(path_clean_panel, "allfirms", "2010-2019-regression-allfirms.dta"))

log_dt_all <- rbind(log_dt_all, make_log_totals(log_dt_all))
fwrite(log_dt_all,
       file.path(path_out_log, paste0("log_makepanel_allfirms_", format(Sys.time(), "%Y%m%d"), ".csv")),
       row.names = FALSE)

rm(dt_all)
gc()

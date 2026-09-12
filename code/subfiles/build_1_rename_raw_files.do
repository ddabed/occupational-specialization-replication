*=========================================================================
* build_1_rename_raw_files.do -- Phase 1 of the data build
*
* Converts the raw Quadros de Pessoal worker and firm files from SPSS and
* renames the variables into English.
*
*   in : $path_raw_QdP/     (raw QdP files, one pair per year 2010-2019)
*   out: $path_raw_QdPren/  workers_renamed*, firms_renamed*
*
* Called by 2_build_data.do. Do not run directly -- it relies on the globals
* that 2_build_data.do sets up via _paths.do.
*=========================================================================



*-------------------------------------------------------------------------
* The file names change across years because the extracts were delivered in
* several batches; the date suffix is the delivery date. If your copies are
* named differently, adjust the import spss lines below to match.
*-------------------------------------------------------------------------

*****************************************************************************
** Rename workers files 2010-2019
*****************************************************************************

forvalues y = 2010/2019 {


if `y' <= 2016 {

	import spss using "$path_raw_QdP/QP_Trabalhadores_`y'_Fins_Cientificos_21-05-2018.sav" , clear

}

if `y' == 2017 {

	import spss using "$path_raw_QdP/QP_Trabalhadores_`y'_Fins_Cientificos_07-02-2019", clear
}


if `y' == 2018 {

	import spss using "$path_raw_QdP/QP_Trabalhadores_`y'_Fins_Cientificos_08-07-2020", clear
}

if `y' == 2019 {

	import spss using "$path_raw_QdP/QP_Trabalhadores_`y'_Fins_Cientificos_21-06-2021", clear
}

		// Translate variable names from Portuguese to English
		rename ANO year
		rename NPC_FIC fnumber_FIC
		rename NUEMP fnumber
		rename EMP_ID f_ID
		rename NUEST enumber
		rename ESTAB_ID e_ID
		cap rename irct colect_contrat
		rename ntrab w_numer
		rename sexo gender
		rename nacio nationality
		rename prof_4d occup4_10
		rename prof_3d occup3_10
		rename prof_2d occup2_10
		rename prof_1d occup1_10
		rename ctpro occup_categ
		rename sitpro employ_status
		rename nqual1 qualif_level1dig
		rename habil school
		rename habil2 school_2dig
		rename habil1 school_1dig
		rename idade_Cod age
		rename antig tenure
		cap rename dt_adm hiring_date
		cap rename dt_prom promotion_date
		rename ctrem worktime_rem
		rename rbase basic_rem
		rename prest_reg reg_pay
		rename prest_irreg irreg_pay
		rename rextra extra_rem
		rename rganho total_rem
		rename hnormais reg_hours_month
		rename hextra extra_hours_month
		rename pnt reg_hours_week
		rename tipo_contr type_contract
		rename tipo_contr1 type_contract_1
		rename esc_rem_base basic_rem_class
		rename esc_rem_ganho total_rem_class

	// Attach ISCO-08 titles to the 3-digit occupation codes.
	// force makes any non-numeric entry missing rather than stopping the run;
	// records without a valid occupation are dropped later in the build.

		destring occup3_10, replace force


		label def occup3_10_1 111 "Legislators and senior officials" /*
		*/112 "Managing directors and chief executives" 121 "Business services and administration managers"/*
		*/ 122 "Sales, marketing and development managers" 131 "Production managers in agriculture, forestry and fisheries"/*
		*/ 132 "Manufacturing, mining, construction, and distribution managers" 133 "Information and communications technology service managers"/*
		*/ 134 "Professional services managers" 141 "Hotel and restaurant managers" 142 "Retail and wholesale trade managers"/*
		*/ 143 "Other services managers" 211 "Physical and Earth Science Professionals" 212 "Mathematicians, Actuaries and Statisticians"/*
		*/ 213 "Life Science Professionals" 214 "Engineering Professionals (exc. Electrotechnology)" 215 "Electrotechnology Engineers"/*
		*/ 216 "Architects, Planners, Surveyors and Designers" 221 "Medical Doctors" 222 "Nursing and Midwifery Professionals" /*
		*/ 223 "Traditional and Complementary Medicine Professionals" 224 "Paramedical Practitioners" 225 "Veterinarians"/*
		*/ 226 "Other Health Professionals" 231 " University and Higher Education Teachers" 232 "Vocational Education Teachers" /*
		*/ 233 "Secondary Education Teachers" 234 "Primary School and Early Childhood Teachers" 235 "Other Teaching Professionals" /*
		*/ 241 "Finance Professionals" 242 "Administration Professionals" 243 "Sales, Marketing and Public Relations Professionals" /*
		*/ 251 "Software and Applications Developers and Analysts" 252 "Database and Network Professionals" /*
		*/ 261 "Legal Professionals" 262 "Librarians, Archivists and Curators" 263 "Social and Religious Professionals" /*
		*/ 264 "Authors, Journalists and Linguists" 265 "Creative and Performing Artists" 311 "Physical and Engineering Science Technicians" /*
		*/ 312 "Mining, Manufacturing and Construction Supervisors" 313 "Process Control Technicians" 314 "Life Science Technicians and Related Associate Professionals"/*
		*/ 315 "Ship and Aircraft Controllers and Technicians" 321 "Medical and Pharmaceutical Technicians" 322 "Nursing and Midwifery Associate Professionals" /*
		*/ 323 "Traditional and Complementary Medicine Associate Professionals" 324 "Veterinary Technicians and Assistants" /*
		*/ 325 "Other Health Associate Professionals" 331 "Financial and Mathematical Associate Professionals" 332 "Sales and Purchasing Agents and Brokers" /*
		*/ 333 "Business Services Agents" 334 "Administrative and Specialized Secretaries" 335 "Regulatory Government Associate Professionals"/*
		*/ 341 "Legal, Social and Religious Associate Professionals" 342 "Sports and Fitness Workers" 343 "Artistic, Cultural and Culinary Associate Professionals" /*
		*/ 351 "Information and Communications Technology Operations and User Support Technicians" 352 "Telecommunications and Broadcasting Technicians" /*
		*/ 411 "General Office Clerks" 412 "Secretaries (general)" 413 "Keyboard Operators" 421 "Tellers, Money Collectors and Related Clerks" /*
		*/ 422 "Client Information Workers" 431 "Numerical Clerks" 432 "Material Recording and Transport Clerks" 441 "Other Clerical Support Workers" /*
		*/ 511 "Travel Attendants, Conductors and Guides" 512 "Cooks" 513 "Waiters and Bartenders" 514 "Hairdressers, Beauticians and Related Workers" /*
		*/ 515 "Building and Housekeeping Supervisors" 516 "Other Personal Services Workers" 521 "Street and Market Salespersons" 522 "Shop Salespersons"/*
		*/ 523 "Cashiers and Ticket Clerks" 524 "Other Sales Workers" 531 " Child Care Workers and Teachers' Aides" 532 "Personal Care Workers in Health Services"/*
		*/ 541 "Protective Services Workers" 611 "Market Gardeners and Crop growers" 612 "Animal Producers" 613 "Mixed Crop and Animal Producers" /*
		*/ 621 "Forestry and Related Workers" 622 "Fishery Workers, Hunters and Trappers" 631 "Subsistence Crop Farmers" 632 "Subsistence Livestock Farmers" /*
		*/ 633 "Subsistence Mixed Crop and Livestock Farmers" 634 "Subsistence fishers, huntersm trappers and gatherers" /*
		*/ 711 "Building Frame and Related Trades Workers" 712 "Building Finishers and Related Trades Workers"/*
		*/ 713 "Painters, Building Structure Cleaners and Related Trades Workers" 721 "Sheet and Structural Metal Workers, Moulders and Welders, and Related Workers"/*
		*/ 722 "Blacksmiths, Toolmakers and Related Trades Workers" 723 "Machinery Mechanics and Repairers" 731 "Handicraft Workers" 732 "Printing Trades Workers" /*
		*/ 741 "Electrical Equipment Installers and Repairers" 742 "Electronics and Telecommunications Installers and Repairers" 751 "Food Processing and Related Trades Workers"/*
		*/ 752 "Wood Treaters, Cabinet-makers and Related Trades Workers" 753 "Garment and Related Trades Workers" 754 "Other Craft and Related Workers" /*
		*/ 811 "Mining and Mineral Processing Plant Operators" 812 "Metal Processing and Finishing Plant Operators" 813 "Chemical and Photographic Products Plant and Machine Operators" /*
		*/ 814 "Rubber, Plastic and Paper Products Machine Operators" 815 "Textile, Fur and Leather Products Machine Operators" 816 "Food and Related Products Machine Operators"/*
		*/ 817 "Wood Processing and Papermaking Plant Operators" 818 "Other Stationary Plant and Machine Operators" 821 "Assemblers"/*
		*/ 831 "Locomotive Engine Drivers and Related Workers" 832 "Car, Van and Motorcycle Drivers" 833 "Heavy Truck and Bus Drivers" 834 "Mobile Plant Operators"/*
		*/ 835 "Ships' Deck Crews and Related Workers" 911 "Domestic, Hotel and Office Cleaners and Helpers" 912 "Vehicle, Window, Laundry and Other Hand Cleaning Workers"/*
		*/ 921 "Agricultural, Forestry and Fishery Labourers" 931 "Mining and Construction Labourers" 932 "Manufacturing Labourers" 933 "Transport and Storage Labourers"/*
		*/ 941 "Food Preparation Assistants" 951 "Street and Related Services Workers" 952 "Street Vendors (excluding Food)" 961 "Refuse Workers" 962 "Other Elementary Workers"


		label values occup3_10 occup3_10_1

		compress

save "$path_raw_QdPren/workers_renamed_occlabel`y'", replace

}


*****************************************************************************
** Rename firms files 2010-2019
*****************************************************************************

forvalues y = 2010/2019 {


if `y' <= 2015 {

	import spss using "$path_raw_QdP/Empresas_`y'_Fins_Cientificos_25-05-2017.sav" , clear

}

if `y' == 2016 {

	import spss using "$path_raw_QdP/Empresas_`y'_Fins_Cientificos_13-04-2018", clear
}

if `y' == 2017 {

	import spss using "$path_raw_QdP/QP_Empresas_`y'_Fins_Cientificos_07-02-2019", clear
}

if `y' == 2018 {

	import spss using "$path_raw_QdP/QP_Empresas_`y'_Fins_Cientificos_30-06-2020", clear
}

if `y' == 2019 {

	import spss using "$path_raw_QdP/QP_Empresas_`y'_Fins_Cientificos_18-06-2021", clear
}

	// Translate variable names from Portuguese to English
		rename ANO year
		rename NPC_FIC fnumber_FIC
		rename NUEMP fnumber
		rename EMP_ID f_ID
		rename nut1_emp fNUTS1
		rename nut2_emp fNUTS2
		rename natju flegalnature
		rename csoc fcapital_total
		rename cspri fcapital_nac
		rename cspub fcapital_pub
		rename csest fcapital_fore
		rename nest festablish_number
		rename pemp fpersonnel
		rename pempl fpersonnel_oct
		rename CAE2 fEAC_2dig_rev3
		rename caem1 fEAC_1let_rev3
		rename CAE4_COD fEAC_34dig_rev3
		cap rename ancon fbirth_year
		rename antiguidade fseniority
		rename esc_antig_emp fseniority_class
		rename vn fsales
		rename vndesc1 fsales_class
		rename vndesc2 fturnover_class
		rename vn_ano fsales_refyear
		rename csocesc fcapital_class
		rename escdim1 fsize_class
		rename escdim2 fsize_class_des
		rename escdim_linhas1 fsize_class_oct
		rename tcoemp femployees_oct
		cap rename ANO_CONSTITUICAO fbirth_year

		compress

save "$path_raw_QdPren/firms_renamed`y'", replace
}

* Builds the O*Net 2016 WORK CONTEXT module at the SOC level.
* Called by 1_build_task_scores.do.
*   in : $path_raw_onet/Work Context.txt   (O*NET 21.0, 2016)
*   out: $path_clean_onet/onet16_wkcontext[_soc].dta

* The module is reshaped so that one row is one O*NET-SOC occupation, then
* collapsed to the 6-digit SOC level. Only two of these dimensions are used
* downstream (degree of automation and importance of repeating the same tasks,
* which form the routine composite in onet_tasks.do); the rest are built and
* labelled here for completeness.
*************************************************************************
******************************** ONET 2016 ******************************

insheet using "$path_raw_onet/Work Context.txt", clear
* Source: O*Net Resource Center Analyst Database;
* http://www.onetcenter.org/database.html;
* https://www.onetcenter.org/db_releases.html

*** scaleid's CXP and CTP, in combination with "category" indicate the proportion
*** of people that fall into different categories for each dimension. 
*** CX and CT (no "category") provide a continuous measure (mean)
*** The CXs range from 1 to 5, the CTs range from 1 to 3

keep if scaleid=="CX" | scaleid=="CT"

rename datavalue wkcontext

egen dim=group(elementid)

keep onetsoccode wkcontext dim

reshape wide wkcontext, i(onetsoccode) j(dim)


* Rename variables so that the numbers match the ones from ealier ONETs (which 
* had fewer dimensions), also add _16 at the end to make clear that these measures
* are from ONet 2016, and label varuables
rename wkcontext1 wkcontext39_16
label variable wkcontext39_16 "Public Speaking"
rename wkcontext2 wkcontext40_16
label variable wkcontext40 "Telephone"
rename wkcontext3 wkcontext41_16
label variable wkcontext41_16 "Electronic Mail"
rename wkcontext4 wkcontext42_16
label variable wkcontext42_16 "Letters and Memos"
rename wkcontext5 wkcontext43_16
label variable wkcontext43_16 "Face-to-Face Discussions"
rename wkcontext6 wkcontext1_16	
label variable wkcontext1_16	"Contact With Others	"
rename wkcontext7 wkcontext44_16 
label variable wkcontext44_16 "Work With Work Group or Team"
rename wkcontext8 wkcontext2_16	
label variable wkcontext2_16	"Deal With External Customers	"
rename wkcontext9 wkcontext3_16	
label variable wkcontext3_16	"Coordinate or Lead Others	"
rename wkcontext10 wkcontext4_16	
label variable wkcontext4_16	"Responsible for Others' Health and Safety	"
rename wkcontext11 wkcontext5_16	
label variable wkcontext5_16	"Responsibility for Outcomes and Results	"
rename wkcontext12 wkcontext6_16	
label variable wkcontext6_16	"Frequency of Conflict Situations	"
rename wkcontext13 wkcontext7_16	
label variable wkcontext7_16	"Deal With Unpleasant or Angry People	"
rename wkcontext14 wkcontext8_16	
label variable wkcontext8_16	"Deal With Physically Aggressive People	"
rename wkcontext15 wkcontext9_16	
label variable wkcontext9_16	"Indoors, Environmentally Controlled	"
rename wkcontext16 wkcontext45_16
label variable wkcontext45_16 "Indoors, Not Environmentally Controlled"
rename wkcontext17 wkcontext10_16
label variable wkcontext10_16	"Outdoors, Exposed to Weather	"
rename wkcontext18 wkcontext46_16
label variable wkcontext46_16 "Outdoors, Under Cover"
rename wkcontext19 wkcontext47_16
label variable wkcontext47_16 "In an Open Vehicle or Equipment"
rename wkcontext20 wkcontext48_16
label variable wkcontext48_16 "In an Enclosed Vehicle or Equipment"
rename wkcontext21 wkcontext49_16
label variable wkcontext49_16 "Physical Proximity"
rename wkcontext22 wkcontext11_16
label variable wkcontext11_16	"Sounds, Noise Levels Are Distracting or Uncomfortable	"
rename wkcontext23 wkcontext12_16
label variable wkcontext12_16	"Very Hot or Cold Temperatures	"
rename wkcontext24 wkcontext13_16
label variable wkcontext13_16	"Extremely Bright or Inadequate Lighting	"
rename wkcontext25 wkcontext14_16
label variable wkcontext14_16	"Exposed to Contaminants	"
rename wkcontext26 wkcontext15_16
label variable wkcontext15_16	"Cramped Work Space, Awkward Positions	"
rename wkcontext27 wkcontext16_16
label variable wkcontext16_16	"Exposed to Whole Body Vibration	"
rename wkcontext28 wkcontext17_16
label variable wkcontext17_16	"Exposed to Radiation	"
rename wkcontext29 wkcontext18_16
label variable wkcontext18_16	"Exposed to Disease or Infections	"
rename wkcontext30 wkcontext19_16
label variable wkcontext19_16	"Exposed to High Places	"
rename wkcontext31 wkcontext20_16
label variable wkcontext20_16	"Exposed to Hazardous Conditions	"
rename wkcontext32 wkcontext21_16
label variable wkcontext21_16	"Exposed to Hazardous Equipment	"
rename wkcontext33 wkcontext22_16
label variable wkcontext22_16	"Exposed to Minor Burns, Cuts, Bites, or Stings	"
rename wkcontext34 wkcontext23_16
label variable wkcontext23_16	"Spend Time Sitting	"
rename wkcontext35 wkcontext24_16
label variable wkcontext24_16	"Spend Time Standing	"
rename wkcontext36 wkcontext25_16
label variable wkcontext25_16	"Spend Time Climbing Ladders, Scaffolds, or Poles	"
rename wkcontext37 wkcontext26_16
label variable wkcontext26_16	"Spend Time Walking and Running	"
rename wkcontext38 wkcontext27_16
label variable wkcontext27_16	"Spend Time Kneeling, Crouching, Stooping, or Crawling?	"
rename wkcontext39 wkcontext28_16
label variable wkcontext28_16	"Spend Time Keeping or Regaining Balance	"
rename wkcontext40 wkcontext29_16
label variable wkcontext29_16	"Spend Time Using Your Hands to Handle, Control, or Feel Objects, Tools, or Controls	"
rename wkcontext41 wkcontext30_16
label variable wkcontext30_16	"Spend Time Bending or Twisting the Body	"
rename wkcontext42 wkcontext31_16
label variable wkcontext31_16	"Spend Time Making Repetitive Motions	"
rename wkcontext43 wkcontext32_16
label variable wkcontext32_16	"Wear Common Protective or Safety Equipment such as Safety Shoes, Glasses, Gloves, Hearing Protection, Hard Hats, or Life Jackets	"
rename wkcontext44 wkcontext33_16
label variable wkcontext33_16	"Wear Specialized Protective or Safety Equipment such as Breathing Apparatus, Safety Harness, Full Protection Suits, or Radiation Protection	"
rename wkcontext45 wkcontext34_16
label variable wkcontext34_16	"Consequence of Error	"
rename wkcontext46 wkcontext50_16
label variable wkcontext50_16 "Impact of Decisions on Co-workers or Company Results"
rename wkcontext47 wkcontext51_16
label variable wkcontext51_16 "Frequency of Decision Making"
rename wkcontext48 wkcontext52_16
label variable wkcontext52_16 "Freedom to Make Decisions"
rename wkcontext49 wkcontext35_16
label variable wkcontext35_16	"Degree of Automation	"
rename wkcontext50 wkcontext36_16
label variable wkcontext36_16	"Importance of Being Exact or Accurate	"
rename wkcontext51 wkcontext37_16
label variable wkcontext37_16	"Importance of Repeating Same Tasks	"
rename wkcontext52 wkcontext53_16
label variable wkcontext53_16 "Structured versus Unstructured Work"
rename wkcontext53 wkcontext54_16
label variable wkcontext54_16 "Level of Competition"
rename wkcontext54 wkcontext55_16
label variable wkcontext55_16 "Time Pressure"
rename wkcontext55 wkcontext38_16
label variable wkcontext38_16	"Pace Determined by Speed of Equipment	"
rename wkcontext56 wkcontext56_16
label variable wkcontext56_16 "Work Schedules"
rename wkcontext57 wkcontext57_16
label variable wkcontext57_16 "Duration of Typical Work Week"


split onetsoccode, gen(soc_) parse(- .)
	* soc_1-soc_2 are the SOC code, soc_3 is the extra bit added by ONet;
sort soc_1 soc_2
rename onetsoccode onet16

save "$path_clean_onet/onet16_wkcontext", replace

*** Collapse so that each soc_1 soc_2 code appears only once (i.e. combine the
* even finer occupations unique to ONet doing a simple average)
collapse *wkcontext*, by(soc_1 soc_2)

save "$path_clean_onet/onet16_wkcontext_soc", replace

clear all
set more off
macro drop _all

if inlist("`c(username)'","parthchawla1") global path "/users/parthchawla1/Desktop/Worldwide_Governance_Indicators"
else global path ""
cd "$path"

use "wgidataset.dta"

rename code country_text_id
rename countryname country_name

merge m:1 country_text_id using "RegionalGroupings.dta"
keep if _merge == 3

replace sdg_region = "Australia & New Zealand" if sdg_region == "Australia and New Zealand"
replace sdg_region = "Central & South Asia" if sdg_region == "Central Asia and Southern Asia"
replace sdg_region = "East & South-East Asia" if sdg_region == "Eastern Asia and South-Eastern Asia"
replace sdg_region = "Europe & North America" if sdg_region == "Europe and Northern America"
replace sdg_region = "Latin America & Caribbean" if sdg_region == "Latin America and the Caribbean"
replace sdg_region = "North Africa & West Asia" if sdg_region == "Northern Africa and Western Asia"
replace sdg_region = "Oceania (ex Aus, NZ)" if sdg_region == "Oceania (excluding Australia and New Zealand)"

replace hdi = "Low HDI" if hdi == "Low"
replace hdi = "Medium HDI" if hdi == "Medium"
replace hdi = "High HDI" if hdi == "High"
replace hdi = "Very High HDI" if hdi == "Very High"

encode sdg_region, gen(sdg_region1)
encode developing_region, gen(developing_region1)
encode hdi, gen(hdi1)
gen ldc1 = 0
replace ldc1 = 1 if ldc == "LDC"
gen oecd1 = 0
replace oecd1 = 1 if oecd == "OECD"

order country_name country_text_id sdg_region1 developing_region1 ldc1 oecd1 hdi1

save "wgidataset_edited.dta", replace

use "wgidataset_edited.dta", clear

drop if year < 2010
keep sdg_region1 country_name country_text_id year vae pve gee rqe rle cce
label var pve "Polit. Stability, No Violence/Terrorism"

local indexes vae pve gee rqe rle cce

foreach var of varlist `indexes'  {
	egen regavg_`var' = mean(`var'), by(sdg_region1 year)
	lab var regavg_`var' "`: var lab `var''"
}

duplicates drop sdg_region1 year, force
xtset sdg_region1 year

foreach var of varlist `indexes'  {
	xtline regavg_`var', overlay name(g_`var') graphregion(color(white)) ///
	ylab(#10, valuelabel angle(horizontal) format(%9.2f)) xlab(2010(2)2020) ///
	ytitle(,size(medsmall))
	graph export "g_`var'.png", replace
}


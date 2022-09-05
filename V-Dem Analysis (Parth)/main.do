clear all
set more off
macro drop _all

if inlist("`c(username)'","parthchawla1") global path "/users/parthchawla1/Desktop/V-Dem"
else global path ""
cd "$path"

use "V-Dem-CY-Full+Others-v12.dta"
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

order country_name country_text_id country_id sdg_region1 developing_region1 ldc1 oecd1 hdi1

save "V-Dem-CY-Full+Others-v12_edited.dta", replace

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

use "V-Dem-CY-Core-v12_edited.dta", clear

drop if year < 2011
drop *_codelow *_codehigh *_sd

local indexes v2x_*

foreach var of varlist `indexes'  {
	egen regavg_`var' = mean(`var'), by(sdg_region1 year)
	lab var regavg_`var' "`: var lab `var''"
}

duplicates drop sdg_region1 year, force
xtset sdg_region1 year

foreach var of varlist `indexes'  {
	xtline regavg_`var', overlay name(g_`var') graphregion(color(white)) ///
	ylab(#10, valuelabel angle(horizontal) format(%9.2f)) xlab(2011(2)2021)
	graph export "FIGURES/g_`var'.png", replace
}


use "V-Dem-CY-Core-v12_edited.dta", clear

drop if year < 2011
drop *_codelow *_codehigh *_sd

drop if hdi1 == 4

local indexes v2x_*

foreach var of varlist `indexes'  {
	egen hdiavg_`var' = mean(`var'), by(hdi1 year)
	lab var hdiavg_`var' "`: var lab `var''"
}

duplicates drop hdi1 year, force
xtset hdi1 year

foreach var of varlist `indexes'  {
	xtline hdiavg_`var', overlay name(g2_`var') graphregion(color(white)) ///
	ylab(#10, valuelabel angle(horizontal) format(%9.2f)) xlab(2011(2)2021)
	graph export "FIGURES/g2_`var'.png", replace
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

use "V-Dem-CY-Full+Others-v12_edited.dta", clear

drop if year < 2008

local indexes e_autoc e_polcomp

foreach var of varlist `indexes'  {
	egen regavg_`var' = mean(`var'), by(sdg_region1 year)
	lab var regavg_`var' "`: var lab `var''"
}

duplicates drop sdg_region1 year, force
xtset sdg_region1 year

foreach var of varlist `indexes'  {
	xtline regavg_`var', overlay name(g_`var') graphregion(color(white)) ///
	ylab(#10, valuelabel angle(horizontal) format(%9.2f)) xlab(2008(2)2018)
	graph export "FIGURES/g3_`var'.png", replace
}


use "V-Dem-CY-Full+Others-v12_edited.dta", clear

drop if year < 2008

drop if hdi1 == 4

local indexes e_autoc e_polcomp

foreach var of varlist `indexes'  {
	egen hdiavg_`var' = mean(`var'), by(hdi1 year)
	lab var hdiavg_`var' "`: var lab `var''"
}

duplicates drop hdi1 year, force
xtset hdi1 year

foreach var of varlist `indexes'  {
	xtline hdiavg_`var', overlay name(g2_`var') graphregion(color(white)) ///
	ylab(#10, valuelabel angle(horizontal) format(%9.2f)) xlab(2008(2)2018)
	graph export "FIGURES/g4_`var'.png", replace
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

use "V-Dem-CY-Full+Others-v12_edited.dta", clear

keep country_name country_text_id country_id sdg_region1 hdi1 year v2x_regime
drop if v2x_regime == .
drop if year < 2001

gen regime_type = 0
replace regime_type = 1 if v2x_regime == 0 | v2x_regime == 1
replace regime_type = 2 if v2x_regime == 2 | v2x_regime == 3
label define lregime_type 1 "Closed/Electoral Autocracy" 2 "Electoral/Liberal Democracy"
label values regime_type lregime_type

egen regime_count = count(country_text_id), by(regime_type year)

duplicates drop regime_type year, force
xtset regime_type year

xtline regime_count, overlay name(g1_) graphregion(color(white)) ///
ylab(#10, valuelabel angle(horizontal)) xlab(2001(4)2021) ///
ytitle("No. of countries")
graph export "FIGURES/g5_regime_count.png", replace


use "V-Dem-CY-Full+Others-v12_edited.dta", clear

keep country_name country_text_id country_id sdg_region1 hdi1 year v2x_regime
drop if v2x_regime == .
drop if year < 2001

egen regime_count = count(country_text_id), by(v2x_regime year)
lab var regime_count "`: var lab v2x_regime'"

duplicates drop v2x_regime year, force
xtset v2x_regime year

xtline regime_count, overlay name(g2_) graphregion(color(white)) ///
ylab(#10, valuelabel angle(horizontal)) xlab(2001(2)2021)  ///
ytitle("No. of countries")
graph export "FIGURES/g6_regime_count.png", replace

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

use "V-Dem-CY-Full+Others-v12_edited.dta", clear

keep country_name country_text_id country_id year v2x_regime
drop if v2x_regime == .
keep if year == 2001 | year == 2021

tab country_name

reshape wide v2x_regime, i(country_id) j(year)

keep if v2x_regime2021 < v2x_regime2001
drop if v2x_regime2001 == .

save "democratic_backslide_countries.dta", replace


import delimited /Users/parthchawla1/Desktop/V-Dem/HDI_HDR2020_040722.csv, clear

keep iso3 hdi_*

drop if iso3 == ""
rename iso3 country_text_id

reshape long hdi_, i(country_text_id) j(year)

merge m:1 country_text_id using "democratic_backslide_countries.dta"
keep if _merge == 3

xtset country_id year

/*
levelsof country_id, local(levels)

foreach l of local levels {
	xtline hdi_ if country_id == `l', overlay name(h`l') graphregion(color(white)) ///
	ylab(#10, valuelabel angle(horizontal)) xlab(#5)  ytitle("HDI")
}
*/

// Falling HDI: 14 (Yemen), 51 (Venezuela), 97 (Syria)

egen hdi_avg = mean(hdi_), by(year)

tsline hdi_avg, name(hdi_avg) graphregion(color(white)) ///
ylab(#10, valuelabel angle(horizontal)) xlab(1990(5)2020)  ///
ytitle("Avg. HDI of countries sliding democratically") xtitle("Year")
graph export "FIGURES/hdi_avg.png", replace

keep if country_id == 14 | country_id == 51 | country_id == 97

encode country_name, gen(country_name1)
xtset country_name1 year

xtline hdi_, overlay graphregion(color(white)) ytitle("HDI") xtitle("Year") ///
ylab(#10, valuelabel angle(horizontal)) xlab(1990(5)2020)

graph export "FIGURES/hdi2.png", replace

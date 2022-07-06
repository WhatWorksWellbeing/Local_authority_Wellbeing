
********************************************************************************************************************************
**************************************** APS Local Authority Data - Welleing over time *****************************************
************************************************ Michael Sanders ***************************************************************
******************************************** What Works Centre for Wellbeing ***************************************************
********************************************************************************************************************************

********************************************************************************************************************************
**Version 1.0
**Importing each year's data - 2014-2021
**This data also standardises organisational identifiers across time periods, and standardises wellbeing variable denominations, and truncate wellbeing variable names
**First step - insheet each year's data (from 2014-2021). We also analyse to look at inequalities of wellbeing in LAs over time.

**Set working directory:
cd 
**Import dataset**
import excel "wellbeing-local-authority-time-series-v2.xlsx", sheet("Dataset") cellrange(A3:AR8423) firstrow clear
**Recode variable names to make years more sensibly identified.
ren E y2011
ren I y2012
ren M y2013
ren Q y2014
ren U y2015
ren Y y2016
ren AC y2017
ren AG y2018
ren AK y2019
ren AO y2020

**Getting rid of national/aggregated data, whole civil service medians, etc.
local getrid E92000001 E12000007 E12000001 E12000002 N92000002 E12000008 E12000009 S92000003 E12000008 E12000009 K02000001 W92000004
foreach x of local getrid{
drop if Geographycode =="`x'"
}
**Keep the averages, drop standard deviations, medians**
keep if Estimate =="Average (mean)"

**Local for variable types**
local list  Anxiety Happiness Life Worthwhile
**Foreach loop for each of the wellbeing variables
foreach x of local list{
**Preserve**
preserve
**Keep only the relevant measure
keep if strpos(Measure, "`x'")!=0
**Rehape long so that each LA/year appears as a row
reshape long y, i(Geography) j(Time)
**Rename outcome measure
ren y `x'
**Identify time*
gen t20 = Time==2020
**Create a continuous variable for time starting at 1.
gen Time2 = Time-2010
**Regression analysis of outcome over time with Huber-White Standard Errors
reg `x' Time2 t20, robust
**Create a categorical variable from a string variable
egen LANO = group(Geography)
**Set the data as a panel dataset with local authority (LANO) as the cross sectional unit and year (Time) as the time series unit.
xtset LANO Time
**Generate first difference of outcom.
gen firstdiff`x' = `x' - L.`x'
**Summarise the properties of the first differences in 2020 (Covid Year**
summ firstdiff`x' if Time==2020, det
summ firstdiff`x' if Time==2020 & firstdiff`x'>0
summ firstdiff`x' if Time==2020 & firstdiff`x'<0
**Create a graph of the distribution of the first differences in 2020, and then save that graph. 
kdensity firstdiff`x' if Time==2020, graphregion(color(white)) xtitle("First Difference, `x' in 2020") ytitle(Density)
graph export "Diffsin`x'.png", replace
**Collapse to give average of outcome measure of all organisations at the time period level. 
collapse `x', by(Time)
**Draw a graph for mean organisational outcome measure over time and export it
twoway (connected `x' Time), graphregion(color(white)) xtitle(Year) ytitle(`x')
graph export "`x' over time LAs.png", replace
**Restore data to how it was on line 43. 
restore
}

**Generate changes between each pair of years (data are back in wide format now**
gen d1 = y2012-y2011
gen d2 = y2013-y2012
gen d3 = y2014-y2013
gen d4 = y2015-y2014
gen d5 = y2016-y2015
gen d6 = y2017-y2016
gen d7 = y2018-y2017
gen d8 = y2019-y2018
gen d9 = y2020-y2019
gen dall = y2019-y2011
gen increase2020 = 0
**Generate a variable which shows rising wellbeing in period 9 for non-anxiety measures and declining anxiety.
gen d9up = d9>0 if strpos(Measure, "Anxiety")==0
replace d9up = d9<0 if strpos(Measure,"Anxiety")!=0
**Create an indicator which shows how many wellbeing mesaures are improving over time
bysort Geography: egen sumd9 = sum(d9up)
**Show increases over the whole data period for each outcome measure
summ dall if strpos(Measure, "Anxiety")!=0, det
summ dall if strpos(Measure, "Happiness")!=0, det
summ dall if strpos(Measure, "Life")!=0, det
summ dall if strpos(Measure, "Worthwhile")!=0, det
**Show tables of organisations for the top performing local authorities over the whole time period
tab Geography if dall<=-1.02 & strpos(Measure, "Anxiety")!=0
**
tab Geography if dall>0.88 & strpos(Measure, "Happiness")!=0
**
tab Geography if dall>0.83 & strpos(Measure, "Life")!=0
**
tab Geography if dall>0.85 & strpos(Measure, "Worthwhile")!=0


local list  Anxiety Happiness Life Worthwhile
**Tidy up names of places to make things exportable (remove commas)
replace Measure = "Satisfaction" if Measure=="Life Satisfaction"
replace Geography = "Armagh City Banbridge and Craigavon" if Geography=="Armagh City, Banbridge and Craigavon"
replace Geography = "Bournemouth Christchurch and Poole" if Geography=="Bournemouth, Christchurch and Poole"
replace Geography = "Bristol" if Geography=="Bristol, City of"
replace Geography = "Kingston upon Hull" if Geography=="Kingston upon Hull, City of"
replace Geography = "Herefordshire" if Geography=="Herefordshire, County of"
replace Geography = "Newry Mourne and Down" if Geography=="Newry, Mourne and Down"
cd "/Users/michaelsanders/Documents/WW Wellbeing/LA Wellbeinganalysis/Graphs at LA level"
**Create a local with all local authorities in it**
levelsof Geography, local(las)

**Looking now at inequalities - focus next on proportion in lower status - reopen dataset**
import excel "wellbeing-local-authority-time-series-v2.xlsx", sheet("Dataset") cellrange(A3:AR8423) firstrow clear
**Recode years again**
ren E y2011
ren I y2012
ren M y2013
ren Q y2014
ren U y2015
ren Y y2016
ren AC y2017
ren AG y2018
ren AK y2019
ren AO y2020

**Getting rid of national/aggregated data, whole civil service medians, etc.
local getrid E92000001 E12000007 E12000001 E12000002 N92000002 E12000008 E12000009 S92000003 E12000008 E12000009 K02000001 W92000004
foreach x of local getrid{
drop if Geographycode =="`x'"
}

**Keep only poor performance measure**
keep if Estimate =="Poor"

**Local with wellbeing measures in
local list  Anxiety Happiness Life Worthwhile
**Run a foreach loop for each wellbeing measure
preserve
**Keep only this outcome**
keep if strpos(Measure, "`x'")!=0
**Reshape long so that each row is a time period/LA pair
reshape long y, i(Geography) j(Time)
**Rename outcome measure**
ren y `x'
**Create a Covid time period
gen t20 = Time==2020
**Create continuous time variable starting at 1**
gen Time2 = Time-2010
**regression analysis of wellbeing indicator over time with a binary indicator for 2020
reg `x' Time2 t20, robust
**Generate a categorical variable from the string variable local authority name
egen LANO = group(Geography)
**Set a panel with local authority as the cross sectional unit and time in years as the time series unit
xtset LANO Time
**Calculate first differences**
gen firstdiff`x' = `x' - L.`x'
summ firstdiff`x' if Time==2020, det
summ firstdiff`x' if Time==2020 & firstdiff`x'>0
summ firstdiff`x' if Time==2020 & firstdiff`x'<0
**Show the distribution of first differences in rate of low wellbeing in 2020
kdensity firstdiff`x' if Time==2020, graphregion(color(white)) xtitle("First Difference, `x' in 2020") ytitle(Density)
graph export "Diffsin`x' - poor.png", replace
collapse `x', by(Time)
**Show levels of low wellbeing over time**
twoway (connected `x' Time), graphregion(color(white)) xtitle(Year) ytitle(Proportion with poor `x')
graph export "`x' over time LAs - poor.png", replace
**Restore to dataset on line 150 
restore
}

**Generate changes over time with data in wide format**
gen d1 = y2012-y2011
gen d2 = y2013-y2012
gen d3 = y2014-y2013
gen d4 = y2015-y2014
gen d5 = y2016-y2015
gen d6 = y2017-y2016
gen d7 = y2018-y2017
gen d8 = y2019-y2018
gen d9 = y2020-y2019
gen dall = y2019-y2011
gen increase2020 = 0
gen d9up = d9>0 if strpos(Measure, "Anxiety")==0
replace d9up = d9<0 if strpos(Measure,"Anxiety")!=0
bysort Geography: egen sumd9 = sum(d9up)
**Show changes in levels of poor wellbeing changing over the last ten years**
summ dall if strpos(Measure, "Anxiety")!=0, det

summ dall if strpos(Measure, "Happiness")!=0, det

summ dall if strpos(Measure, "Life")!=0, det

summ dall if strpos(Measure, "Worthwhile")!=0, det
**Create information for tables
tab Geography if dall<=-1.02 & strpos(Measure, "Anxiety")!=0

tab Geography if dall>0.88 & strpos(Measure, "Happiness")!=0

tab Geography if dall>0.83 & strpos(Measure, "Life")!=0

tab Geography if dall>0.85 & strpos(Measure, "Worthwhile")!=0


**Look at inequalities - focus next on proportion in higher "very good" status**
**Insheet dataset**
import excel "wellbeing-local-authority-time-series-v2.xlsx", sheet("Dataset") cellrange(A3:AR8423) firstrow clear
**Recode years
ren E y2011
ren I y2012
ren M y2013
ren Q y2014
ren U y2015
ren Y y2016
ren AC y2017
ren AG y2018
ren AK y2019
ren AO y2020

**Getting rid of national/aggregated data, whole civil service medians, etc.
local getrid E92000001 E12000007 E12000001 E12000002 N92000002 E12000008 E12000009 S92000003 E12000008 E12000009 K02000001 W92000004
foreach x of local getrid{
drop if Geographycode =="`x'"
}
**Keep only "very good" proportions
keep if Estimate =="Very good"

**Create a local of wellbeing outcomes
local list  Anxiety Happiness Life Worthwhile
**Create a foreach loop running each wellbeing outcome
foreach x of local list{
**Preserve dataset as it is**
preserve
**Only kep this measure**
keep if strpos(Measure, "`x'")!=0
**Reshape data to long so each row is an LA/Time period pair.
reshape long y, i(Geography) j(Time)
**Rename outcomes*
ren y `x'
**Create a covid 2020 indicator and a time series variable starting at 1
gen t20 = Time==2020
gen Time2 = Time-2010
**Regress proportion with very high wellbeing on time with a binary indicator for covid
reg `x' Time2 t20, robust
**Create a categorical variable from the string variable of local authority names
egen LANO = group(Geography)
**Set as a panel with Local Authority (LANO) as the cross sectional unit and year (Time) as the time series unit.
xtset LANO Time
**Createfirst differences**
gen firstdiff`x' = `x' - L.`x'
summ firstdiff`x' if Time==2020, det
summ firstdiff`x' if Time==2020 & firstdiff`x'>0
summ firstdiff`x' if Time==2020 & firstdiff`x'<0
**Show the distribution of first differences in rate of low wellbeing in 2020
kdensity firstdiff`x' if Time==2020, graphregion(color(white)) xtitle("First Difference, `x' in 2020") ytitle(Density)
graph export "Diffsin`x' - vgood.png", replace
collapse `x', by(Time)
**Show levels of low wellbeing over time**
twoway (connected `x' Time), graphregion(color(white)) xtitle(Year) ytitle(Proportion with very good `x')
graph export "`x' over time LAs - vgood.png", replace
**Restore to line 243
restore
}

**Generate changes over time with dataset back in wide format**
gen d1 = y2012-y2011
gen d2 = y2013-y2012
gen d3 = y2014-y2013
gen d4 = y2015-y2014
gen d5 = y2016-y2015
gen d6 = y2017-y2016
gen d7 = y2018-y2017
gen d8 = y2019-y2018
gen d9 = y2020-y2019
gen dall = y2019-y2011
gen increase2020 = 0
gen d9up = d9>0 if strpos(Measure, "Anxiety")==0
replace d9up = d9<0 if strpos(Measure,"Anxiety")!=0
bysort Geography: egen sumd9 = sum(d9up)
**Show changes in levels of very good wellbeing changing over the last ten years**

summ dall if strpos(Measure, "Anxiety")!=0, det

summ dall if strpos(Measure, "Happiness")!=0, det

summ dall if strpos(Measure, "Life")!=0, det

summ dall if strpos(Measure, "Worthwhile")!=0, det
**Create information for tables**
tab Geography if dall<=-1.02 & strpos(Measure, "Anxiety")!=0

tab Geography if dall>0.88 & strpos(Measure, "Happiness")!=0

tab Geography if dall>0.83 & strpos(Measure, "Life")!=0

tab Geography if dall>0.85 & strpos(Measure, "Worthwhile")!=0



clear all
use trade_data.dta

*Drop outermost regions and regions that only trade with themselves and ROW
drop if outermost==1

drop if i=="ES63"
drop if j=="ES63"
drop if i=="ES64"
drop if j=="ES64"

drop if i=="FI20"
drop if j=="FI20"
drop if i=="MT00"
drop if j=="MT00"

drop if i=="IS00"
drop if j=="IS00"

drop if i=="LI00"
drop if j=="LI00"

*Generate interaction variables (trend with intra and inter)
bys i j (year): gen trend=_n
gen intrapr_t=trend*intra 
gen interpr_t=trend*inter
drop trend

*generate dependent variable
gen E_m=ee/(gdp_i*gdp_j)

*PAIR FE GRAVITY
ppml_panel_sg E_m intrapr_t interpr_t, ex(i2) im(j2) y(year) dropsing ro max(1000000) genD(FE)
outreg2 using baseline.xls, excel keep(intrapr_t interpr_t) replace ctitle(Structural)
drop if FE==.
replace FE=ln(FE)

*Accomodation of some of the independent variables
replace lndist=0 if intra==1
gen ROW_i=0
replace ROW_i=1 if i=="ROW"
gen ROW_j=0
replace ROW_j=1 if j=="ROW"
replace lndist=0 if i=="ROW" | j=="ROW"

*Gravity variables estimation
ppmlhdfe E_m intrapr_t interpr_t lndist contig_r contig_c, absorb(HB=intra#i2 year#i2 year#j2 ROW_i#j2 ROW_j#i2) cluster (i2#j2)
outreg2 using baseline.xls, excel keep(intrapr_t interpr_t lndist contig_r contig_c) append ctitle(Gravity)

*"Trade cost" with gravity variables
gen grav=(_b[lndist]*lndist+_b[contig_r]*contig_r+_b[contig_c]*contig_c)

*Save "home bias" of origin (i) y destination (j)
gen intrai=0
forvalues aa=1/284{
gen HB1_`aa'=HB if intra==1 & i2==`aa'
egen HB1_`aa'_mean=mean(HB1_`aa')
gen HB0_`aa'=HB if intra==0 & i2==`aa'
egen HB0_`aa'_mean=mean(HB0_`aa')
gen HB_`aa'=HB1_`aa'_mean-HB0_`aa'_mean

replace intrai=HB_`aa' if i2==`aa'
drop HB1_`aa' HB0_`aa' HB1_`aa'_mean HB0_`aa'_mean HB_`aa'
}

preserve
keep i intrai
bys i: drop if i==i[_n-1]
rename i j
rename intrai intraj
save intra, replace
restore

*Merge of the home bias
merge m:1 j using intra
drop _merge

*Keep only the observations needed in the estimation (Inter-regional european flows)
gen inter_reg=1
replace inter_reg=0 if intra==1
replace inter_reg=0 if i=="ROW" | j=="ROW"
replace FE=. if inter_reg==0 
replace grav=. if FE==.
*We keep only one year (the results are the same for all years, an average)
keep if year==2016

*Model for the estimation of the UTB
bootstrap, reps(50): reg FE grav if inter_reg==1, robust
outreg2 using UTB.xls, excel replace ctitle(UTB)

bootstrap, reps(50): reg FE grav intrai intraj if inter_reg==1, robust
outreg2 using UTB.xls, excel append ctitle(UTB_2)

*Final computation of the UTB
gen lnUTB=_b[_cons]+((_b[grav]-1)*grav)+(_b[intrai]+_b[intrai]/(_b[intrai]+_b[intraj]))*intrai+(_b[intraj]+_b[intraj]/(_b[intrai]+_b[intraj]))*intraj if inter_reg==1
gen UTB=exp(lnUTB)

*Results
preserve
keep i j UTB
bys i j: drop if j==j[_n-1]
reshape wide UTB, i(i) j(j, s)
export excel using UTB_matrix.xlsx, firstrow(variables) replace
restore

save UTB_services_europe.dta, replace






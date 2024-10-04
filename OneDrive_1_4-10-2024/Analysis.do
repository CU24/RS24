* Services

clear all
use NUTS_RG_01M_2016_4326_LEVL_2, clear
merge 1:1 NUTS_ID using Data_maps
drop if _merge==1
drop if _merge ==2
drop _merge

xtset, clear
format %9.1g UTB_international
format %9.1g UTB_interreg

*Average International UTB
grmap UTB_international, clnum(9) fcolor(RdYlGn) title() subtitle() legstyle(2) legend(title(UTB mean value, size(small)) size(*1.25) position(11))
*graph save Graph UTB_mean, replace
*graph export UTB_mean.emf, as(emf) replace


*Average Intranational UTB
grmap UTB_interreg, clnum(9) fcolor(RdYlGn) title() subtitle() legstyle(2) legend(title(UTB mean value, size(small)) size(*1.25) position(11))
*graph save Graph UTB_inter_mean, replace
*graph export UTB_inter_mean.emf, as(emf) replace



* Figure 3
egen UTB_internat_mean=mean(UTB_international)
egen UTB_interreg_mean=mean(UTB_interreg)
twoway (scatter UTB_international UTB_interreg, mlabel(NUTS_ID) mlabposition(0) msymbol(i)) (lfit UTB_international UTB_interreg) (line UTB_internat_mean UTB_interreg,color(black)) (line UTB_international UTB_interreg_mean,color(black)),ytitle(International UTB, size()) yscale(range()) xscale(range()) ylabel(,angle(horizontal)  labsize()) xtitle(Inter-regional UTB, size()) xlabel(,angle(horizontal) labsize()) title() legend(pos() col() order (1 "UTB Values" 2 "Fitted values")) scheme() saving()
*graph save Graph scatter1, replace
*graph export scatter1.emf, as(emf) replace



*****************************************
* Goods and Services comparison
*****************************************


clear all
use Data_services_goods
egen y_ref_value=median(UTB_international)
egen x_ref_value=median(UTB_international_services)

egen country_1=group(country)
label define countries 1 "AT" 2 "BE"  3 "BG" 4 "CH"  5 "CY" 6 "CZ"  7 "DE" 8 "DK"  9 "EE" 10 "EE" 11 "ES" 12 "FI"  13 "FR" 14 "HR" 15 "HU" 16 "IE" 17 "IT" 18 "LI" 19 "LT" 20 "LU" 21 "LV" 22 "NL" 23 "NO" 24 "PL" 25 "PT" 26 "RO" 27 "SE" 28 "SI" 29 "SK" 30 "UK"
label values country_1 countries 

* Figure 4a
twoway (scatter UTB_international UTB_international_services, colorvar(country_1) colordiscrete msymbol(i) msize() mlabsize() mlabel(NUTS2) mlabpos(center) mcolor())  ///
              (line y_ref_value UTB_international_services, lpattern(dash) sort lcolor(black)) ///
              (line UTB_international x_ref_value, lpattern(dash) sort lcolor(black)), ///
              legend(off) title() ///
			  xtitle("UTB Services") ///
			  ytitle("UTB Goods")
*graph save Graph goods_vs_services_regional, replace
*graph export goods_vs_services_regional.emf, as(emf) replace



preserve
bys country: egen mean_UTB_international_services=mean(UTB_international_services)
bys country: egen mean_UTB_international=mean(UTB_international)
bys country: drop if country==country[_n-1]

* Figure 4b

twoway (lfit mean_UTB_international mean_UTB_international_services if mean_UTB_international<0.4, lcolor(red))(scatter mean_UTB_international mean_UTB_international_services if mean_UTB_international<0.4, yscale() msymbol(i) mlabsize(medium) msize() mlabel(country) mlabpos(center) mlabcolor(stblue) mcolor())  ///
              (line y_ref_value mean_UTB_international_services, lpattern(dash) sort lcolor(black)) ///
              (line mean_UTB_international x_ref_value, lpattern(dash) sort lcolor(black)), ///
              legend(off) title() ///
			  xtitle("UTB Services") ///
			  ytitle("UTB Goods")
*graph save Graph goods_vs_services_country, replace
*graph export goods_vs_services_country.emf, as(emf) replace
restore			  

egen y_ref_value2=median(UTB_interreg)
egen x_ref_value2=median(UTB_interreg_services)

preserve
bys country: egen mean_UTB_interreg_services=mean(UTB_interreg_services)
bys country: egen mean_UTB_interreg=mean(UTB_interreg)
bys country: drop if country==country[_n-1]
drop if mean_UTB_interreg>4

* Figure 5
twoway (scatter mean_UTB_interreg mean_UTB_interreg_services, yscale() msymbol(i) mlabsize(medium) msize() mlabel(country) mlabpos(center) mlabcolor(stblue) mcolor())  ///
              (line y_ref_value2 mean_UTB_interreg_services, lpattern(dash) sort lcolor(black)) ///
              (line mean_UTB_interreg x_ref_value2, lpattern(dash) sort lcolor(black)), ///
              legend(off) title() ///
			  xtitle("UTB Services") ///
			  ytitle("UTB Goods")
*graph save Graph goods_vs_services_interreg_country, replace
*graph export goods_vs_services_interreg_country.emf, as(emf) replace
restore			  








*****************************************
* Cluster
*****************************************


clear all
use Data_services_goods

drop if NUTS2=="ROW"

sum UTB_international_services UTB_interreg_services UTB_international UTB_interreg

graph box UTB_international_services UTB_interreg_services UTB_international UTB_interreg, ysize() ylabel(, nogrid labsize(small)) graphregion(ifcolor(white) fcolor(white) lcolor(white) icolor(white)) ytitle() legend(ring() position() cols() order (1 "International UTB (Services)" 2 "Intra-national UTB (Services)" 3 "International UTB (Goods)" 4 "Intra-national UTB (Goods)") size(small)) scheme() title()

egen I1_s=std(UTB_international_services)
egen I2_s=std(UTB_interreg_services)
egen I3_s=std(UTB_international)
egen I4_s=std(UTB_interreg)

drop if I2_s==.
graph box I*_s, ysize() ylabel(, nogrid labsize(small)) graphregion(ifcolor(white) fcolor(white) lcolor(white) icolor(white)) ytitle() legend(ring() position() cols() order (1 "International UTB (Services)" 2 "Intra-national UTB (Services)" 3 "International UTB (Goods)" 4 "Intra-national UTB (Goods)") size(small)) scheme() title()

summarize I1_s, detail
display r(p75)
gen I1_75 = r(p75)
egen iqr_I1=iqr(I1_s)
gen max_I1=3*iqr_I1+I1_75
replace I1_s=max_I1 if I1_s>max_I1

summarize I2_s, detail
display r(p75)
gen I2_75 = r(p75)
egen iqr_I2=iqr(I2_s)
gen max_I2=3*iqr_I2+I2_75
replace I2_s=max_I2 if I2_s>max_I2

summarize I3_s, detail
display r(p75)
gen I3_75 = r(p75)
egen iqr_I3=iqr(I3_s)
gen max_I3=3*iqr_I3+I3_75
replace I3_s=max_I3 if I3_s>max_I3

summarize I4_s, detail
display r(p75)
gen I4_75 = r(p75)
egen iqr_I4=iqr(I4_s)
gen max_I4=3*iqr_I4+I4_75
replace I4_s=max_I4 if I4_s>max_I4


*correlations
corr I*_s

graph box I*_s, ysize() ylabel(, nogrid labsize(small)) graphregion(ifcolor(white) fcolor(white) lcolor(white) icolor(white)) ytitle() legend(ring() position() cols() order () size(small)) scheme() title()
keep NUTS2 -I4_s

*Export data for doing Principal component analysis in SPSS
*export excel using "datos_UTB_paraPC.xlsx", firstrow(variables) replace


clear all
use Data_cluster
drop I*_s

* Cluster analysis
cluster wardslinkage FAC*_1, measure(L2squared) name(cluster1)
cluster dendrogram cluster1, cutnumber(100) labels(NUTS2) xlabel(, angle(vertical)) name(cluster1)
cluster generate c1 = groups(5), name(cluster1)
cluster kmeans FAC*_1, k(5) measure(L2squared) name(Kmedias) start(group(c1))
tab c1 Kmedias
bys Kmedias: sum UTB_international_services UTB_interreg_services UTB_international UTB_interreg

keep NUTS2 Kmedias
save groups_cluster, replace


** Figure 6
clear all
use NUTS_RG_01M_2016_4326_LEVL_2, clear
rename NUTS_ID NUTS2
merge 1:1 NUTS2 using groups_cluster
drop if _merge==1
drop _merge
rename NUTS2 NUTS_ID
xtset, clear

grmap Kmedias, clnum(6) clmethod(custom) clb(0 1 2 3 4 5) fcolor(Set1) title() subtitle() legstyle() legend(order(1 "No data" 2 "Group 1" 3 "Group 2" 4 "Group 3" 5 "Group 4" 6 "Group 5") title(Cluster, size(small))  size(*1.25) position(11))
*graph save Graph_cluster, replace
*graph export cluster.emf, as(emf) replace




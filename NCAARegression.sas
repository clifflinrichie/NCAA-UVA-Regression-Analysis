filename newdata '/folders/myfolders/Project1/gamesUVA.csv';

 proc import datafile=newdata
        dbms=csv
        out=mydata.gamesUVA
        replace;
     
     getnames=yes;
run;

*proc contents allows you to ensure your data uploaded as desired;

proc contents data=mydata.gamesUVA;
run;

* setting dummy variables;
data mydata.gamesUVA1 ; *create a new data set saved to your library;
	set mydata.gamesUVA; *set with the original table ;
	DumTrb = 0;
	if trb > opp_trb then DumTrb = 1;
	
	DumStl = 0;
	if stl > opp_stl then DumStl = 1;
	
	DumBlk = 0;
	if blk > opp_blk then DumBlk = 1;
	
	DumTov = 0;
	if tov < opp_tov then DumTov = 1;
	
run;

* EDA, multiple scatter plots were made since they would not all fit on the same page;
proc sgscatter data=mydata.gamesUVA1;
plot pts * (opp_pts fg fga fg_per _3p _3pa _3p_per);
run;

proc sgscatter data=mydata.gamesUVA1;
plot pts * (ft fta ft_per orb trb ast stl blk tov);
run;


proc sgscatter data=mydata.gamesUVA1;
plot pts * (pf opp_fg opp_fga opp_fg_per opp_3p opp_3pa opp_3p_per 
opp_ft opp_fta);
run;

proc sgscatter data=mydata.gamesUVA1;
plot pts * (opp_ft_per opp_orb opp_trb opp_ast opp_stl opp_blk opp_tov opp_pf);
run;

* for dummy variables;

proc sgplot data = mydata.gamesUVA1;
vline dumTrb/ response = pts stat=mean datalabel;
run;

proc sgplot data = mydata.gamesUVA1;
vline dumStl/ response = pts stat=mean datalabel;
run;

proc sgplot data = mydata.gamesUVA1;
vline dumBlk/ response = pts stat=mean datalabel;
run;

proc sgplot data = mydata.gamesUVA1;
vline dumTov/ response = pts stat=mean datalabel;
run;

* creating interactions;
data mydata.gamesUVA2 ; *create a new data set saved to your library;
	set mydata.gamesUVA1; *set with the original table ;
	dumHome = 0;
	if site = "Home" then dumHome = 1;
	dumNeutral = 0;
	if site = "Neutral" then dumNeutral = 1;
	homeFt = dumHome * ft_per;
	neutralFt = dumNeutral * ft_per;
	
	ftsqr = ft * ft;	* higher order variable;
	
run;

* line plot of means for dummy site variables;
proc sgplot data = mydata.gamesUVA2;
vline dumHome/ response = pts stat=mean datalabel;
run;

proc sgplot data = mydata.gamesUVA2;
vline dumNeutral/ response = pts stat=mean datalabel;
run;

* plotting interactions;
proc sgplot data = mydata.gamesUVA2;
vline fg / group = dumHome response = pts stat=mean datalabel;
run;

* interaction of home vs. away;
proc sgplot data=mydata.gamesUVA2;
scatter y=pts x=ft_per/group=dumHome;
reg y=pts x=ft_per/group=dumHome;
run;

* interaction of neutral vs. away;
proc sgplot data=mydata.gamesUVA2;
scatter y=pts x=ft_per/group=dumNeutral;
reg y=pts x=ft_per/group=dumNeutral;
run;

* EDA Model;
* first stage, just quantitative variables;
proc reg data=mydata.gamesUVA2 plots=none;
model pts = fg_per ast _3p_per ft ftsqr ft_per tov;
run;

* second stage, qualitative variables;
proc reg data=mydata.gamesUVA2 plots=none;
model pts = fg_per ast _3p_per ft ft_per tov dumHome dumTrb dumBlk;
test dumHome, dumTrb, dumBlk;
run;

* nested f-test;
proc reg data=mydata.gamesUVA2 plots=none;
model pts = fg_per ast _3p_per ft ft_per tov;
run;

* third stage, interaction terms;
proc reg data=mydata.gamesUVA2 plots=none;
model pts = fg_per ast _3p_per ft ft_per tov dumHome homeFt;
run;

* final model;
proc reg data=mydata.gamesUVA2 plots=none;
model pts = fg_per ast _3p_per ft tov;
run;












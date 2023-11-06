***************************************************************************************
**		P8483 Final Project Group 15							 					 **
**		Eastelle Ding (eyd2112)														 **
**		Maxine Blech (mb5021)														 **
**		Teresa Moore  (tem2171)														 **
**		Xuan Lu (xl3214)															 **
**		Daniel Gilchrist (dg3307)													 **
***************************************************************************************;

*
 Population of interest: US adults (age 18-65)
 Data source: NHANES 2017-2018
 
 Research Questions
 1. Does diastolic/systolic blood pressure differ between the presence or 
 	absence of major depressiver disorder?
 2. Does any observed relationship persist after adjusting for 
    age, gender, income, and race?
    
 Variables of interest (NHANES 2017-2018 name)
	Mean systolic blood pressure, calculated from at most 3 readings
		(BPXSY1, BPXSY2, BPXSY3)
	Mean diastolic blood pressure, calculated from at most 3 readings
		(BPXDI1, BPXDI2, BPXDI3)
	Actively taking medication prescribed to reduce cholesterol
		(BPQ100D)
	Major Depressive Disorder score, calculated from DPQ_J screener
		(DPQ010-DPQ090)
	Age in years (ridageyr)
	Income (IND235)
	Gender (riagendr)
	Race (RIDRETH1)
	Unique ID (seqn)
;

***************************************************************************************
**		Section 1. Inputting data sources											 **
**************************************************************************************;

*Part 1:  
 *Population of interest:
 Adults 18-65 years of age (variable ridageyr from "DEMO_J" data file)
 Must answer question on depression screener (variables DPQ010-DPQ090 from "DPQ_J" data file)
 Must have systolic and diastolic blood pressure measurements (BPXSY1-3 and BPXDI1-3)
 Must have non-missing gender, race, and income
 	(riagendr and RIDRETH1 from DEMO_J, IND235 from INQ_J);

*1. Inputting all XPT files;
filename DEMO_J "/home/u63090240/sasuser.v94/DEMO_J.XPT";
filename DPQ_J "/home/u63090240/sasuser.v94/DPQ_J.XPT";
filename BPX_J "/home/u63090240/sasuser.v94/BPX_J.XPT";
filename INQ_J "/home/u63090240/sasuser.v94/INQ_J.XPT";
filename BPQ_J "/home/u63090240/sasuser.v94/BPQ_J.XPT";
 
proc http
	url = "https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/DEMO_J.XPT"
	out = DEMO_J;
	/*dataset: Demographic Variables and Sample Weights (DEMO_J)*/
	/*codebook: https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/DEMO_J.htm*/
proc http
	url = "https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/DPQ_J.XPT"
	out = DPQ_J;
	/*dataset: Mental Health - Depression Screener (DPQ_J)*/
	/*codebook: https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/DPQ_J.htm*/
proc http
	url = "https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/BPX_J.XPT"
	out = BPX_J;
	/*dataset: Blood Pressure (BPX_J)*/
	/*codebook: https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/BPX_J.htm*/
proc http
	url = "https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/INQ_J.XPT"
	out = INQ_J;
	/*dataset: Income (INQ_J)*/
	/*codebook: https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/INQ_J.htm*/
proc http
	url = "https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/BPQ_J.XPT"
	out = BPQ_J;
	/*dataset: Blood Pressure & Cholesterol (BPQ_J)*/
	/*codebook: https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/BPQ_J.htm*/
run;
libname Xport1 xport "/home/u63090240/sasuser.v94/DEMO_J.XPT";
libname Xport2 xport "/home/u63090240/sasuser.v94/DPQ_J.XPT";
libname Xport3 xport "/home/u63090240/sasuser.v94/BPX_J.XPT";
libname Xport4 xport "/home/u63090240/sasuser.v94/INQ_J.XPT";
libname Xport5 xport "/home/u63090240/sasuser.v94/BPQ_J.XPT";

data DEMO_J; set Xport1.DEMO_J;
data DPQ_J; set Xport2.DPQ_J;
data BPX_J; set Xport3.BPX_J;
data INQ_J; set Xport4.INQ_J;
data BPQ_J; set Xport5.BPQ_J;
run;
/*
The data set WORK.DEMO_J has 9254 observations and 46 variables.
The data set WORK.DPQ_J has 5533 observations and 11 variables.
The data set WORK.BPX_J has 8704 observations and 21 variables.
The data set WORK.INQ_J has 9254 observations and 16 variables.
The data set WORK.BPQ_J has 6161 observations and 11 variables.
*/

*2. Demographic Inclusion Criteria;

data DEMO_J; set DEMO_J; 
	keep SEQN RIAGENDR RIDAGEYR RIDRETH1;
	where RIAGENDR ne . AND RIDRETH1 ne .;
	if 18 <= RIDAGEYR <= 65; /*includes age in years at screening between 18 to 65 only*/
	/*All data not satisfying the inclusion criteria will be excluded*/
run;
/*
The data set WORK.DEMO_J has 4449 observations and 4 variables.
*/

data INQ_J; set INQ_J;
	where IND235 not in(77, 99, .);
run;
/*
The data set WORK.INQ_J has 7483 observations and 16 variables.
*/

data DPQ_J; set DPQ_J;
	where DPQ010 not in (7,9,.) and 
		DPQ020 not in (7,9,.) and 
		DPQ030 not in (7,9,.) and 
		DPQ040 not in (7,9,.) and 
		DPQ050 not in (7,9,.) and 
		DPQ060 not in (7,9,.) and 
		DPQ070 not in (7,9,.) and 
		DPQ080 not in (7,9,.) and 
		DPQ090 not in (7,9,.);
run;
/*
The data set WORK.DPQ_J has 5068 observations and 11 variables.
*/


/*
Because we'll be using a known blood pressure operationalization, we create the hypertension
variable and merge the hypertension dataset before the larger merge, as recommended by Dr. Lamb.
*/
data BPX_J; set BPX_J;
	where (BPXSY1 and BPXSY2 and BPXSY3 and BPXDI1 and BPXDI2 and BPXDI3) ne .;
	BPXSY_avg=(BPXSY1+BPXSY2+BPXSY3)/3;
	BPXDI_avg=(BPXDI1+BPXDI2+BPXDI3)/3;
	if BPXSY_avg < 130 and BPXDI_avg < 80 then hypertension1 = 0;
	else if BPXSY_avg >= 130 or BPXDI_avg >= 80 then hypertension1 = 1;
run;
/*Eliminating all observations with missing blood pressure values
The data set WORK.BPX_J has 8704 observations and 24 variables.*/

data BPQ_J; set BPQ_J;
	keep SEQN BPQ100D hypertension2;
	if BPQ100D = 1 then hypertension2 = 1;
	else hypertension2 = 0; 
run;
/*Keeping the dataset with the blood cholesterol medication question
The data set WORK.BPQ_J has 6161 observations and 3 variables.*/

proc sort data = BPX_J; by SEQN; run;
proc sort data = BPQ_J; by SEQN; run;
data HPT; 
	merge BPX_J BPQ_J; by SEQN;
	if hypertension1 = 1 then hypertension = 1;
	else if hypertension2 = 1 then hypertension = 1;
	else hypertension = 0;
	format hypertension hypertensionF.;
run;	
/*The data set WORK.HPT has 9037 observations and 27 variables.*/

proc sort data = DEMO_J; by SEQN;
proc sort data = DPQ_J; by SEQN;
proc sort data = HPT; by SEQN;
proc sort data = INQ_J; by SEQN;
run;

data MENTAL;
	merge DEMO_J (in = a) DPQ_J (in = b) HPT (in = c) INQ_J (in = d); 
	by SEQN;
	if a and b and c and d;
run;

*Note: there are 3161 observations in my dataset. This is recorded
 in the Background section and in Table 1.;
 
***************************************************************************************
**		Section 2. Creating Analytic Dataset										 **
**************************************************************************************;

*Operationalizations of exposure, outcome, confounders:
********************************************************************************************
1. Operationalize Exposure: Major Depressive Disorder as dichotomous variable (yes/no)
a) PHQ-9 score 0-4 as no MDD, 5-27 as MDD.
b) reference: Kroenke K, Spitzer RL. The PHQ-9: a new depression and diagnostic severity measure. 
	Psych Annals 2002, 32:509-21.
********************************************************************************************
2. Operationalize Outcome: Hypertension as dichotomous variable (yes/no)
	a) blood pressure operationalized as the average of three takes. 
	b) hypertension operationalized as greater than or equal to 130 systolic blood pressure 
	or greater than or equal to 80 for diastolic blood pressure. 
	c) individuals not meeting the operationalization of hypertension but are currently taking prescribed medication
	for hypertension (BPQ100D = 1) are included in the "hypertension" group. 
	d) reference: American College of Cardiology, & American College of Cardiology/American Heart Association (2018). 
	2017 ACC/AHA/AAPA/ABC/ACPM/AGS/APhA/ASH/ASPC/NMA/PCNA guideline for the prevention, detection, evaluation, 
	and management of high blood pressure in adults a report of the American College of Cardiology/American 
	Heart Association Task Force on Clinical practice guidelines. Hypertension, 71(6), E13-E115. 
	https://doi.org/10.1161/HYP.0000000000000065
********************************************************************************************
3. Operationalize Confounders:
	a) Age as 4-level categorical variable
		i) exclusion criteria specified in demographic exclusion criteria section
	b) Family monthly income $0-$1249 as category 1, $1250-$2899 as category 2, $2900-$5399 as category 3,
		$5400 or more as category 4.
		i) exclusion criteria: missing, refused, or don't know data are excluded.
	c) Race as dichotomous variable (white/non-white)
		i) exclusion criteria: missing values are excluded.
********************************************************************************************;
*We are also adding formats for some categorical variables here, to report cleaner univariate
and bivariate analyses;
 
proc format;
 	value MDDf
	0 = "no MDD"
	1 = "MDD";
	value genderF
	0 = "female"
	1 = "male";
	value hypertensionF
	0 = "not hypertensive"
	1 = "hypertensive";
	value Age 
	0 = '18-29y' 
	1 = '30-42y' 
	2 = '43-55y' 
	3 = '56-65y';
run;

/*
Depression score is summed to reflect totality of reported depression from
depression screener.
*/

data mental; set mental;
	Score = sum(DPQ010,DPQ020,DPQ030,DPQ040,DPQ050,DPQ060,DPQ070,DPQ080,DPQ090);
	if RIAGENDR = 1 then gender = 1;
	if RIAGENDR = 2 then gender = 0;
	format gender genderf.;
run;

*******************************************************************************
**	Section 3. Preliminary Univariate and Bivariate Analyses				 **
******************************************************************************;

title1 "gender data distribution";
proc freq data = MENTAL;
	table gender;
run;

/*
Gender				|Frequency	|Percent
Female				|1649		|52.17
Male				|1512		|47.83
*/

title1 "raw depressive disorder score distribution";
proc univariate data = mental;
	var score;
	histogram score;
run;

/*
Depression Score: Mean (SD) = 3.3 (4.3)
Score has a strong right skew, and there is an established method in the literature
to operationalize major depressive disorder from this screener, which we will use here.
3 categories does not gain any granularity that is worth the compromise in sample size 
that would result from a very small third category as a result of the strong right skew.
*/

data mental; set mental;
	if 0 <= Score <= 4 then MDDStatus = 0;
	if Score >= 5 then MDDStatus = 1;
	format MDDStatus MDDf.;
run;

title1 "MDD data distribution";
proc freq data = MENTAL; 
	table MDDStatus;
run;

/*
MDD					|Frequency	|Percent
not MDD				|6349		|74.19
MDD					|2688		|25.81

26% of respondents have exposure, using operationalization from literature does not
threaten sample size and aligns with previously validated depression screening.
*/

title1 "raw age distribution";
proc univariate data = mental;
	var ridageyr;
	histogram ridageyr;
run;
/*
Age is not distributed evenly across its range, which could be concerning for equal variance assumptions
Table 1 mean and SD value for age originates here.
*/

proc sgplot data=mental;
	heatmap y=score x=ridageyr;
run;
/*
Use a heatmap instead of a scatter plot because of the many overlapping scores,
(boxplots had a similar problem at the edges).

Heatmap loosely suggests that there is some relationship (see trend up and to the right), but it is
being disguised by the high variance within years. Grouping could help.
*/

proc ttest data = mental;
	class MDDStatus;
	var ridageyr;
run;
/*
Age is not meaningfully associated with MDDstatus when kept as a continuous variable,
but the distribution is not normal. Grouping age into quartiles would allay theseconcerns 
without threatening sample size.

Table 1 p-value and stratified mean and SD are from here.
*/

proc rank data = MENTAL out = MENTAL groups = 4;
	ranks AgeCat;
	var ridageyr;
run;

/*
Income analyses to check distribution and sample size
*/

title1 "Monthly income distribution";
proc freq data = MENTAL; 
	table ind235;
run;

proc univariate data =mental;
	var ind235;
	histogram ind235;
run;

/*

Monthly family income
Reported income		|Frequency		|Percent
$0 - $399			|131			|4.14
$400 - $799			|129			|4.08
$800 - $1,249		|282			|8.92
$1,250 - $1,649		|216			|6.83
$1,650 - $2,099		|277			|8.76
$2,100 - $2,899		|335			|10.60
$2,900 - $3,749		|358			|11.33
$3,750 - $4,599		|328			|10.38
$4,600 - $5,399		|236			|7.47
$5,400 - $6,249		|154			|4.87
$6,250 - $8,399		|271			|8.57
$8,400 and over		|444			|14.05

Two concerns with income in reported categories without grouping:
1. Sample size, especially at the lowest end is concerning
2. Distribution is skewed, with the high ends of income representing a larger
proportion of sample population than lower ends.

Grouping income categories into roughly equal categories assists with both concerns.
*/


data mental; set mental;
	if IND235 in(1, 2, 3) then monthly_inccat = 1;
		else if IND235 in(4, 5, 6) then monthly_inccat = 2;
		else if IND235 in(7, 8, 9) then monthly_inccat = 3;
		else if IND235 in(10, 11, 12) then monthly_inccat = 4;
	if RIDRETH1 = 3 then race = 1;
		else race = 0;
	format hypertension hypertensionF. AgeCat Age.;
run;

proc univariate data = MENTAL;
	var AgeCat;
	histogram AgeCat; 
run;

title1 "age data distribution";
proc freq data = MENTAL;
table AgeCat;
run;

/*
Age Category		|Frequency	|Percent
18-29y				|767		|24.26
30-42y				|800		|25.31
43-55y				|808		|25.56
56-65y				|786		|24.87

Grouping age into quartiles instead of keeping it continuous has helped
sample size concerns and smoothed distribution, as well as ensuring normality
assumptions do not affect later results.
*/

title1 "hypertension data distribution";
proc freq data = MENTAL;
	table hypertension;
run;

/*
Hypertension		|Frequency	|Percent
no Hypertension		|1925		|60.90
Hypertension		|1236		|39.10
*/

title1 "race data distribution";
proc freq data = MENTAL;
	table ridreth1;
run;
/*
Race				|Frequency	|Percent
Mexican American	|436		|13.79
Other Hispanic		|275		|8.70
Non-Hispanic White	|1080		|34.17
Non-Hispanic Black	|724		|22.90
Other Race 			|646		|20.44

There are serious sample size concerns with keeping this race operationalization
as is, especially with the "Other Hispanic" stratum.
*/

proc freq data = MENTAL;
	table race;
run;

/*
Race				|Frequency	|Percent
Nonwhite			|2081		|65.83
White				|1080		|34.17

Operationalizing race as white/nonwhite preserves sample size and eliminates concern
of strata too small to perform analyses on.
*/

title1 "monthly income data distribution";
proc freq data = MENTAL; 
	table monthly_inccat;
run;

/*
Income category		|Frequency	|Percent
$0-$1249			|542		|17.15
$1250-$2899			|828		|26.19
$2900-$5399			|922		|29.17
$5400+				|869		|27.49

Grouping income alleviates sample size concerns.
*/

proc univariate data = MENTAL;
	var monthly_inccat;
	histogram monthly_inccat;/*bar graph of family monthly income; "$0-$1249" has the least frequencies*/
run;

***************************************************************************************
**		Section 4. Formatting and labelling of variables not already formatted		 **
**************************************************************************************;
proc format;
	value monthlyinccatF
	1 = "$0-$1249"
	2 = "$1250-$2899"
	3 = "$2900-$5399"
	4 = "$5400 or higher";
	value raceF
	0 = "non-white"
	1 = "white";
run;

data mental; set mental;
	format monthly_inccat monthlyinccatF. race racef.;
run;


***************************************************************************************
**		Section 5. Basic descriptive analyses (Table 1)								 **
**************************************************************************************;

title1 "Table 1";
proc tabulate data=mental;
class AgeCat monthly_inccat race;
var ridageyr;
class gender / order = data;
class MDDstatus / order = formatted;
table all (gender AgeCat monthly_inccat race)*(N rowpctn colpctn) ridageyr*(mean std), all MDDStatus;
title;
run;

/*
Ns and row percents in table 1 are from here, as noted in results.
*/

***************************************************************************************
**		Statistical Association														 **
**************************************************************************************;
 
title1 "Chi-squared's for MDD and variables of interest";
proc freq data = mental;
table mddstatus*(gender agecat monthly_inccat race)/chisq measures;
run;

/*
Table 1 chi-square p-values are from this command, all <0.0001
Table 1 t-test value for continuous age was already listed above.
*/
 
***************************************************************************************
**		Section 6. crude and fully adjusted analyses to test our hypotheses			 **
**************************************************************************************;
*Crude and covariate-adjusted models
*Crude, exposure = MDD status; 
*Categorical outcome: Hypertension; 
/*We will employ forward step-wise selection of potential confounders into the model.*/
*a) crude model;
title1 "Multivariable Logistic Regression Analysis";
title2 "Simple Logistic Model (Crude)";
proc logistic data = MENTAL descending;
	class MDDStatus (ref = "no MDD") / param = ref;
	model hypertension (event = "hypertensive") = MDDStatus / cl;
	oddsratio MDDStatus / diff = ref;
run;

proc freq data = mental;
	table mddstatus*hypertension / measures chisq;
run;
/*
Crude Fitted Model: logit(hypertension) = -0.4861+0.1647*MDDStatus
Convergence Criterion Satisfied. 
-2 Log L = 4226.731
Type 3 Analysis of Effects: 
	MDDStatus: DF = 1, Wald Chi-Square = 3.9691, p-val = 0.0463
MDDStatus OR(95%CI): 1.179(1.003,1.387)

Crude model confirmed by proc freq; crude OR and 95% CI in table 2 and results determined here.
*/

*b) adjusted for age;
title2 "Multivariable Logistic Model (adjusted for age)";
proc logistic data = MENTAL descending;
	class MDDStatus (ref = "no MDD") / param = ref;
	class AgeCat (ref = "18-29y") / param = ref;
	model hypertension (event = "hypertensive") = MDDStatus AgeCat / cl;
	oddsratio MDDStatus / diff = ref;
run;
/*
Adjusted Fitted Model 1: logit(hypertension) = -2.2190+0.1500*MDDStatus+1.4084*30-42y+2.1308*43-55y+2.7998*56-65y
Convergence Criterion Satisfied. 
-2 Log L = 3635.924
Type 3 Analysis of Effects: 
	MDDStatus: DF = 1, Wald Chi-Square = 2.7019, p-val = 0.1002
	AgeCat: DF = 1, Wald Chi-Square = 449.6704, p-val = <0.0001
MDDStatus OR(95%CI): 1.162(0.972,1.389)
Decision: Appears to significantly confound the association between MDD and
hypertension; included in final adjusted model
*/

*c) adjusted for race;
title2 "Multivariable Logistic Model (adjusted for race)";
proc logistic data = MENTAL descending;
	class MDDStatus (ref = "no MDD") / param = ref;
	class race (ref = "non-white") / param = ref;
	model hypertension (event = "hypertensive") = MDDStatus race / cl;
	oddsratio MDDStatus / diff = ref;
run;
/*
Adjusted Fitted Model 2: logit(hypertension) = -0.4492+0.1772*MDDStatus-0.1186*race
Convergence Criterion Satisfied. 
-2 Log L = 4224.387
Type 3 Analysis of Effects: 
	MDDStatus: DF = 1, Wald Chi-Square = 4.5444, p-val = 0.0330
	race: DF = 1, Wald Chi-Square = 2.3363, p-val = 0.1264
MDDStatus OR(95%CI): 1.194(1.014,1.405)
Decision: does not seem to confound the association between MDD and hypertension;
not included in final adjusted model
*/

*d) adjusted for monthly income;
title2 "Multivariable Logistic Model (adjusted for monthly income)";
proc logistic data = MENTAL descending;
	class MDDStatus (ref = "no MDD") / param = ref;
	class monthly_inccat (ref = "$0-$1249") / param = ref;
	model hypertension (event = "hypertensive") = MDDStatus monthly_inccat / cl;
	oddsratio MDDStatus / diff = ref;
run;
/*
Adjusted Fitted Model 3: logit(hypertension) = -0.4548+0.1485*MDDStatus+0.0137*$1250-$2899-0.0227*$2900-$5399-0.0881*$5400 or higher
Convergence Criterion Satisfied. 
-2 Log L = 4225.581
Type 3 Analysis of Effects: 
	MDDStatus: DF = 1, Wald Chi-Square = 3.0860, p-val = 0.0790
	monthly_inccat: DF = 3, Wald Chi-Square = 1.1482, p-val = 0.7655
MDDStatus OR(95%CI): 1.160(0.983,1.369)
Decision: does not seem to confound the association between MDD and hypertension; not included in final adjusted model
*/

*e) adjusted for gender;
title2 "Multivariable Logistic Model (adjusted for gender)";
proc logistic data = MENTAL descending;
	class MDDStatus (ref = "no MDD") / param = ref;
	class gender (ref = "female") / param = ref;
	model hypertension (event = "hypertensive") = MDDStatus gender / cl;
	oddsratio MDDStatus / diff = ref;
run;
/*
Adjusted Fitted Model 4: logit(hypertension) = -0.7744+0.2256*MDDStatus+0.5528*gender
Convergence Criterion Satisfied. 
-2 Log L = 4170.385
Type 3 Analysis of Effects: 
	MDDStatus: DF = 1, Wald Chi-Square = 7.2278, p-val = 0.0072
	gender: DF = 3, Wald Chi-Square = 55.7831, p-val = <.0001
MDDStatus OR(95%CI): 1.253(1.063,1.477)
Decision: Appears to be significantly confounds the association between MDD and hypertension; included in model
*/

*f) FINAL MODEL: adjusted for age and gender;
title2 "Final Multivariable Logistic Model (adjusted for age, gender, and monthly income)";
proc logistic data = MENTAL descending;
	class MDDStatus (ref = "no MDD") / param = ref;
	class AgeCat (ref = "18-29y") / param = ref;
	class gender (ref = "female") / param = ref;
	model hypertension (event = "hypertensive") = MDDStatus AgeCat gender / cl;
	oddsratio MDDStatus / diff = ref;
run;

/*
FINAL FITTED MODEL:
	logit(hypertension) = -2.5743 	+ 
				0.2189*MDDStatus	+
				0.6320*gender		+
				1.4321*(30-42yr)	+
				2.1656*(43-55yr)	+
				2.8377*(55-65yr)	+

Convergence Criterion Satisfied. 
-2 Log L = 3575.237
Type 3 Analysis of Effects: 
	MDDStatus: DF = 1, Wald Chi-Square = 5.5949, p-val = 0.0180
	AgeCat: DF = 3, Wald Chi-Square = 451.3347, p-val = <.0001
	gender: DF = 1, Wald Chi-Square = 59.7357, p-val = <.0001

*********
OR (95% CI) reported in table 2 and results is here!
*********

MDDStatus OR(95%CI): 1.245(1.038,1.492)
*/
 
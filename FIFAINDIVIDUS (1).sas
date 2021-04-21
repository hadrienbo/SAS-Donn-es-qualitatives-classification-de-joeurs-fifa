/* Code généré (IMPORT) */
/* Fichier source : fifa_new_dataset.csv */
/* Chemin source : /folders/myfolders/donneesquali */
/* Code généré le : 01/02/2021 17:54 */
/* Generated Code (IMPORT) */
/* Source File: fifa_new_dataset.csv */
/* Source Path: /folders/myfolders */
/* Code generated on: 2/5/21, 4:49 PM */

%web_drop_table(WORK.IMPORT);


FILENAME REFFILE '/folders/myfolders/fifa_new_dataset.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.IMPORT;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.IMPORT; RUN;


%web_open_table(WORK.IMPORT);
PROC CORRESP DATA =WORK.IMPORT binary  n=46 NOPRINT outc= sortie; * n=4 c'est pour avoir toutes les composantes, les r�sultats sont dans le fichier sortie;
TABLES Overall	Preferred_Foot International_Reputation	Weak_Foot	Body_Type	Crossing	Finishing	HeadingAccuracy	ShortPassing	LongPassing	Agility	BallControl	Dribbling	Stamina	Aggression GKDiving	GKHandling	GKKicking	GKPositioning	Age_int ;
supplementary Overall;
RUN;
/*proc print data =sortie; run;*/

data comp_acm; 
set sortie;
if _TYPE_ ='OBS'; *on ne garde que les coordonn�es des individus;
keep DIM1-DIM46;  * on ne garde que les   composantes;
run;

/*proc print data =sortie; run;*/


data comp_acm_tot;
merge WORK.IMPORT comp_acm;
keep Overall DIM1-DIM46;
run; 

/*proc print data =sortie; run;*/

proc stepdisc data = comp_acm_tot sw;  * stepwise, s�lection mixte ;
class Overall;
run;

data comp_acm_tot_stepdisc;
set comp_acm_tot;
keep Overall Dim2 Dim3 Dim32 Dim1 Dim14 Dim11 Dim34 Dim8 Dim33 Dim6 Dim19 Dim9 Dim7 Dim29 Dim31 Dim28 Dim20 Dim10 Dim4 Dim39 Dim24 Dim26 Dim15 Dim35 Dim37 Dim30 Dim27 Dim41 ;
run;

data = comp_acm_tot_stepdisc;
/*proc print;
run;*/



proc surveyselect data = comp_acm_tot_stepdisc

method=srs  /*idem que ci dessus*/

samprate=0.7  /*il prend 70% des observations de chaque groupe , voir le commentaire pr�c�dent sur strata*/
seed =520  /*idem que ci dessus*/
out =SampleStrata outall; /*idem que ci dessus*/
run
;
/*proc print ; 
run;*/
/********netoyage des bases finales****************/
*cr�ation du fichier train (base);
data base (keep=Overall Dim2 Dim3 Dim32 Dim1 Dim14 Dim11 Dim34 Dim8 Dim33 Dim6 Dim19 Dim9 Dim7 Dim29 Dim31 Dim28 Dim20 Dim10 Dim4 Dim39 Dim24 Dim26 Dim15 Dim35 Dim37 Dim30 Dim27 Dim41);
set SampleStrata;
if selected=1;
run
; 
*cr�ation du fichier de test;
data test (keep=Overall Dim2 Dim3 Dim32 Dim1 Dim14 Dim11 Dim34 Dim8 Dim33 Dim6 Dim19 Dim9 Dim7 Dim29 Dim31 Dim28 Dim20 Dim10 Dim4 Dim39 Dim24 Dim26 Dim15 Dim35 Dim37 Dim30 Dim27 Dim41);
set SampleStrata;
if selected=0;
run
; 
/*libname mycas cas;
libname mycas cas caslib=testTables;
*/
/*proc treesplit data=comp_acm_tot_stepdisc maxdepth=10;
   class Overall Dim2 Dim3 Dim32 Dim1 Dim14 Dim11 Dim34 Dim8 Dim33 Dim6 Dim19 Dim9 Dim7 Dim29 Dim31 Dim28 Dim20 Dim10 Dim4 Dim39 Dim24 Dim26 Dim15 Dim35 Dim37 Dim30 Dim27 Dim41;
   model Overall = Dim2 Dim3 Dim32 Dim1 Dim14 Dim11 Dim34 Dim8 Dim33 Dim6 Dim19 Dim9 Dim7 Dim29 Dim31 Dim28 Dim20 Dim10 Dim4 Dim39 Dim24 Dim26 Dim15 Dim35 Dim37 Dim30 Dim27 Dim41;
   prune costcomplexity;
   partition fraction(validate=0.3 seed=123);
   code file='treesplexc.sas';
run;*/

*Analyse factoriellle discriminante sur variable qualitative AFD DISQUAL;
proc candisc data =comp_acm_tot_stepdisc;
class Overall;
var Dim2 Dim3 Dim32 Dim1 Dim14 Dim11 Dim34 Dim8 Dim33 Dim6 Dim19 Dim9 Dim7 Dim29 Dim31 Dim28 Dim20 Dim10 Dim4 Dim39 Dim24 Dim26 Dim15 Dim35 Dim37 Dim30 Dim27 Dim41;
run;


* DISCRIMINATION BAYESIENNE ON CALCULE LE % DE MAL CLASSES PAR VALIDATION CROIS2E;
PROC DISCRIM DATA= comp_acm_tot_stepdisc  all crossvalidate canonical;
class Overall;
var Dim2 Dim3 Dim32 Dim1 Dim14 Dim11 Dim34 Dim8 Dim33 Dim6 Dim19 Dim9 Dim7 Dim29 Dim31 Dim28 Dim20 Dim10 Dim4 Dim39 Dim24 Dim26 Dim15 Dim35 Dim37 Dim30 Dim27 Dim41;
run;

* CLASSIFICATION SUR LES COORDONNEES FACTORIELLES DE L'ACM;
ods graphics on;
proc cluster data=comp_acm_tot_stepdisc method=ward out=ARBRE;
var Dim2 Dim3 Dim32 Dim1 Dim14 Dim11 Dim34 Dim8 Dim33 Dim6 Dim19 Dim9 Dim7 Dim29 Dim31 Dim28 Dim20 Dim10 Dim4 Dim39 Dim24 Dim26 Dim15 Dim35 Dim37 Dim30 Dim27 Dim41;
run;
*TRACE LE DENDROGRAMME ON MET COPY LES DIM POUR POUVOIR FAIRE UNE REPRESENTATION GRAPHIQUE DES CLASSES SUR LE PLAN FACTORIEL;
proc tree data=ARBRE out=PLAN nclusters=5 ;
COPY DIM1 DIM2;
run;
proc sgplot data=PLAN;
   scatter y=dim2 x=dim1 / group=cluster;
run;
ods graphics off;


**export comp_acm_tot_stepdisc**;

DATA=comp_acm_tot_stepdisc;
proc print;
run;

PROC EXPORT DATA=comp_acm_tot_stepdisc
  OUTFILE="C:\Users\ASUS\Desktop\TRIED\D.qualitatives\Dep_comp_acm_tot_stepdisc_Export.Xlsx"
  DBMS=xlsx
  REPLACE;
RUN;

ods excel file="C:\Users\ASUS\Desktop\TRIED\D.qualitatives\Dep_comp_acm_tot_stepdisc_Export.xlsx";


ods excel close;

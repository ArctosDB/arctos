
<!----

https://paleobiodb.org/data1.2/taxa/list.txt?id=69296&rel=all_children&show=full,attr,common

curl -o pdb.txt "https://paleobiodb.org/data1.2/taxa/list.txt?all_records&show=full,attr,common"


curl -o  tst.txt "https://paleobiodb.org/data1.2/taxa/list.txt?id=69296&rel=all_children&show=full,attr,common"


curl -o pdb.txt https://paleobiodb.org/data1.2/taxa/list.json?all_taxa&variant=all&show=full





curl -o pdb.txt https://paleobiodb.org/data1.2/taxa/list.txt?all_taxa&variant=all&show=full
scp data.csv dustylee@arctos-test.tacc.utexas.edu:/usr/local/tmp/data.csv


drop table temp_pdbd;

create table temp_pdbd (
	orig_no VARCHAR2(4000),
	taxon_no VARCHAR2(4000),
	record_type VARCHAR2(4000),
	flags VARCHAR2(4000),
	taxon_rank VARCHAR2(4000),
	taxon_name VARCHAR2(4000),
	taxon_attr VARCHAR2(4000),
	common_name VARCHAR2(4000),
	difference VARCHAR2(4000),
	accepted_no VARCHAR2(4000),
	accepted_rank VARCHAR2(4000),
	accepted_name VARCHAR2(4000),
	parent_no VARCHAR2(4000),
	reference_no VARCHAR2(4000),
	is_extant VARCHAR2(4000),
	n_occs VARCHAR2(4000),
	early_interval VARCHAR2(4000),
	late_interval VARCHAR2(4000),
	taxon_size VARCHAR2(4000),
	extant_size VARCHAR2(4000),
	phylum VARCHAR2(4000),
	class VARCHAR2(4000),
	order VARCHAR2(4000),
	family VARCHAR2(4000),
	genus VARCHAR2(4000),
	type_taxon VARCHAR2(4000),
	taxon_environment VARCHAR2(4000),
	environment_basis VARCHAR2(4000),
	motility VARCHAR2(4000),
	life_habit VARCHAR2(4000),
	vision VARCHAR2(4000),
	diet VARCHAR2(4000),
	reproduction VARCHAR2(4000),
	ontogeny VARCHAR2(4000),
	ecospace_comments VARCHAR2(4000),
	composition VARCHAR2(4000),
	architecture VARCHAR2(4000),
	thickness VARCHAR2(4000),
	reinforcement VARCHAR2(4000)
);

create table temp_pdbd (
orig_no VARCHAR2(4000),
taxon_no VARCHAR2(4000),
record_type VARCHAR2(4000),
flags VARCHAR2(4000),
taxon_rank VARCHAR2(4000),
taxon_name VARCHAR2(4000),
difference VARCHAR2(4000),
accepted_no VARCHAR2(4000),
accepted_rank VARCHAR2(4000),
accepted_name VARCHAR2(4000),
parent_no VARCHAR2(4000),
reference_no VARCHAR2(4000),
is_extant VARCHAR2(4000),
n_occs VARCHAR2(4000)
 16  );


delete from temp_pdbd where taxon_rank='taxon_rank';

select distinct taxon_rank from temp_pdbd;


alter table temp_pdbd add got_this_one varchar2(255);





{"oid":"txn:568","rnk":5,"nam":"Lupherium","tdf":"subjective synonym of","acc":"txn:593","acr":5,"acn":"Parahsuum","par":"txn:65980","rid":"ref:8792","ext":0,"noc":765},
{"oid":"txn:585",  "rnk":5,"nam":"Neowrangellium",   "tdf":"subjective synonym of","acc":"txn:452","acr":5,"acn":"Canoptum","par":"txn:86390","rid":"ref:40780","ext":0,"noc":645},
{"oid":"txn:4997", "rnk":5,"nam":"Pleurosiphonella","par":"txn:54332","rid":"ref:6930","ext":0,"noc":16},

drop table temp_pdb;
create table temp_pdb (
	oid varchar2(255),
	rnk varchar2(255),
	nam varchar2(255),
	tdf varchar2(255),
	acc varchar2(255),
	acr varchar2(255),
	acn varchar2(255),
	par varchar2(255),
	rid varchar2(255),
	ext varchar2(255),
	noc varchar2(255),
	vid varchar2(255),
	FLG varchar2(255),
	dummy varchar2(255)
);

select * from temp_pdb;
select count(*) from temp_pdb;
--truncate table temp_pdb;

UAM@ARCTOS> select distinct FLG from temp_pdb;

FLG
------------------------------------------------------------------------------------------------------------------------

I
F
IF

4 rows selected.


select distinct vid from temp_pdb;

var:383798
var:383846

50811 rows selected.


select distinct noc from temp_pdb;

1089
2215

1988 rows selected.


select distinct ext from temp_pdb;
EXT
------------------------------------------------------------------------------------------------------------------------
1

0


select distinct par from temp_pdb;


txn:304616
...

select distinct acn from temp_pdb;
Agetopanorpa
Sharpeiceras florencae
Cyperus filiferus
Triceromeryx
...

select distinct acr from temp_pdb;
UAM@ARCTOS> select distinct acr from temp_pdb;

ACR
------------------------------------------------------------------------------------------------------------------------

17
11
18
20
16
8
5
14
23
2
26
13
3
12
6
19
25
10
7
15
9
4

23 rows selected.

select distinct acc from temp_pdb;

txn:106986
txn:244394
...

select distinct rid from temp_pdb;

ref:67541
ref:66882
...
select distinct tdf from temp_pdb;

TDF
------------------------------------------------------------------------------------------------------------------------

nomen oblitum
invalid subgroup of
nomen dubium
replaced by
nomen nudum
nomen vanum
subjective synonym of
objective synonym of



orig_no 	oid 	basic

A unique identifier for this taxonomic name
taxon_no 	vid 	basic

A unique identifier for the selected variant of this taxonomic name. By default, this is the variant currently accepted as most correct.
record_type 	typ 	basic

The type of this object: txn for a taxon.
flags 	flg 	basic

This field will be empty for most records. Otherwise, it will contain one or more of the following letters:
B

This taxon is one of the ones specified explicitly in the query. If the result is a subtree, this represents the 'base'.
E

This taxon was specified in the query as an exclusion.
V

This taxonomic name is a variant that is not currently accepted.
I

This taxon is an ichnotaxon.
F

This taxon is a form taxon.
taxon_rank 	rnk 	basic

The rank of this taxon, ranging from subspecies up to kingdom
taxon_name 	nam 	basic

The scientific name of this taxon
taxon_attr 	att 	attr

The attribution (author and year) of this taxonomic name
common_name 	nm2 	common, full

The common (vernacular) name of this taxon, if any
difference 	tdf 	basic

If this name is either a junior synonym or is invalid for some reason, this field gives the reason. The fields accepted_no and accepted_name then specify the name that should be used instead.
tax_status 	n/a 	basic

The taxonomic status of this name, in the Darwin Core vocabulary. This field only appears if that vocabulary is selected.
nom_status 	n/a 	basic

The nomenclatural status of this name, in the Darwin Core vocabulary. This field only appears if that vocabulary is selected.
accepted_no 	acc 	basic

If this name is either a junior synonym or an invalid name, this field gives the identifier of the accepted name to be used in its place. Otherwise, its value will be the same as orig_no. In the compact vocabulary, this field will be omitted in that case.
accepted_rank 	acr 	basic

If accepted_no is different from orig_no, this field gives the rank of the accepted name. Otherwise, its value will be the same as taxon_rank. In the compact voabulary, this field will be omitted in that case.
accepted_name 	acn 	basic

If accepted_no is different from orig_no, this field gives the accepted name. Otherwise, its value will be the same as taxon_name. In the compact vocabulary, this field will be omitted in that case.
parent_no 	par 	basic

The identifier of the parent taxon, or of its senior synonym if there is one. This field and those following are only available if the classification of this taxon is known to the database.
parent_name 	prl 	parent, immparent

The name of the parent taxon, or of its senior synonym if there is one.
immpar_no 	ipn 	immparent

The identifier of the immediate parent taxon, even if it is a junior synonym.
immpar_name 	ipl 	immparent

The name of the immediate parent taxon, even if it is a junior synonym.
container_no 	ctn 	basic

The identifier of a taxon from the result set containing this one, which may or may not be the parent. This field will only appear in the result of the occs/taxa operation, where no base taxon is specified. The taxa reported in this case are the "classical" ranks, rather than the full taxonomic hierarcy.
ref_author 	aut 	refattr

The author(s) of the reference from which this name was entered. Note that the author of the name itself may be different if the reference is a secondary source.
ref_pubyr 	pby 	refattr

The year of publication of the reference from which this name was entered. Note that the publication year of the name itself may be different if the reference is a secondary source.
reference_no 	rid 	basic

The identifier of the reference from which this name was entered.
is_extant 	ext 	basic

True if this taxon is extant on earth today, false if not, not present if unrecorded
n_occs 	noc 	basic

The number of fossil occurrences in this database that are identified as belonging to this taxon or any of its subtaxa.
firstapp_max_ma 	fea 	app

The early age bound for the first appearance of this taxon in the database
firstapp_min_ma 	fla 	app

The late age bound for the first appearance of this taxon in the database
lastapp_max_ma 	lea 	app

The early age bound for the last appearance of this taxon in the database
lastapp_min_ma 	lla 	app

The late age bound for the last appearance of this taxon in the database
early_interval 	tei 	app

The name of the interval in which this taxon first appears, or the start of its range.
late_interval 	tli 	app

The name of the interval in which this taxon last appears, if different from early_interval.
taxon_size 	siz 	size

The total number of taxa in the database that are contained within this taxon, including itself
extant_size 	exs 	size

The total number of extant taxa in the database that are contained within this taxon, including itself
phylum 	phl 	class

The name of the phylum in which this taxon is classified
phylum_no 	phn 	classext

The identifier of the phylum in which this taxon is classified. This is only included with the block classext.
class 	cll 	class

The name of the class in which this taxon is classified
class_no 	cln 	classext

The identifier of the class in which this taxon is classified. This is only included with the block classext.
order 	odl 	class

The name of the order in which this taxon is classified
order_no 	odn 	classext

The identifier of the order in which this occurrence is classified. This is only included with the block classext.
family 	fml 	class

The name of the family in which this taxon is classified
family_no 	fmn 	classext

The identifier of the family in which this occurrence is classified. This is only included with the block classext.
genus 	gnl 	class

The name of the genus in which this taxon is classified. A genus may be listed as occurring in a different genus if it is a junior synonym; a species may be listed as occurring in a different genus than its name would indicate if its genus is synonymized but no synonymy opinion has been entered for the species.
genus_no 	gnn 	classext

The identifier of the genus in which this occurrence is classified. This is only included with the block classext.
subgenus_no 	sgn 	classext

The identifier of the subgenus in which this occurrence is classified, if any. This is only included with the block classext.
type_taxon 	ttl 	class

The name of the type taxon for this taxon, if known.
type_taxon_no 	ttn 	classext

The identifier of the type taxon for this taxon, if known.
n_orders 	odc 	subcounts

The number of orders within this taxon. For lists of taxa derived from a set of occurrences, this will be the number of orders that appear within that set. Otherwise, this will be the total number of orders within this taxon that are known to the database.
n_families 	fmc 	subcounts

The number of families within this taxon, according to the same rules as n_orders above.
n_genera 	gnc 	subcounts

The number of genera within this taxon, according to the same rules as n_orders above.
n_species 	spc 	subcounts

The number of species within this taxon, according to the same rules as n_orders above.
taxon_environment 	jev 	ecospace

The general environment or environments in which this life form is found. See ecotaph vocabulary.
environment_basis 	jec 	ecospace

Specifies the taxon from which the environment information is inherited.
motility 	jmo 	ecospace

Whether the organism is motile, attached and/or epibiont, and its mode of locomotion if any. See ecotaph vocabulary.
motility_basis 	jmc 	etbasis

Specifies the taxon for which the motility information was set. The taphonomy and ecospace information are inherited from parent taxa unless specific values are set.
life_habit 	jlh 	ecospace

The general life mode and locality of this organism. See ecotaph vocabulary.
life_habit_basis 	jhc 	etbasis

Specifies the taxon for which the life habit information was set. See motility_basis above. These fields are only included if the ecospace block is also included.
vision 	jvs 	ecospace

The degree of vision possessed by this organism. See ecotaph vocabulary.
vision_basis 	jvc 	etbasis

Specifies the taxon for which the vision information was set. See motility_basis above. These fields are only included if the ecospace block is also included.
diet 	jdt 	ecospace

The general diet or feeding mode of this organism. See ecotaph vocabulary.
diet_basis 	jdc 	etbasis

Specifies the taxon for which the diet information was set. See motility_basis above. These fields are only included if the ecospace block is also included.
reproduction 	jre 	ecospace

The mode of reproduction of this organism. See ecotaph vocabulary.
reproduction_basis 	jrc 	etbasis

Specifies the taxon for which the reproduction information was set. See motility_basis above. These fields are only included if the ecospace block is also included.
ontogeny 	jon 	ecospace

Briefly describes the ontogeny of this organism. See ecotaph vocabulary.
ontogeny_basis 	joc 	etbasis

Specifies the taxon for which the ontogeny information was set. See motility_basis above. These fields are only included if the ecospace block is also included.
ecospace_comments 	jcm 	ecospace

Additional remarks about the ecospace, if any.
composition 	jco 	ttaph

The composition of the skeletal parts of this organism. See taphonomy vocabulary.
architecture 	jsa 	ttaph

An indication of the internal skeletal architecture. See taphonomy vocabulary.
thickness 	jth 	ttaph

An indication of the relative thickness of the skeleton. See taphonomy vocabulary.
reinforcement 	jsr 	ttaph

An indication of the skeletal reinforcement, if any. See taphonomy vocabulary.
taphonomy_basis 	jtc 	etbasis

Specifies the taxon for which the taphonomy information was set. See motility_basis above. These fields are only included if the otaph block is also included.
lft 	lsq 	seq

This number gives the taxon's position in a preorder traversal of the taxonomic tree.
rgt 	rsq 	seq

This number greater than or equal to the maximum of the sequence numbers of all of this taxon's subtaxa, and less than the sequence of any succeeding taxon in the sequence. You can use this, along with lft, to determine subtaxon relationships. If the pair lft,rgt for taxon <A> is bracketed by the pair lft,rgt for taxon <B>, then A is a subtaxon of B.
image_no 	img 	img

If this value is non-zero, you can use it to construct image URLs using taxa/thumb and taxa/icon.
primary_reference 	ref 	ref

The primary reference associated with this record (as formatted text)
authorizer_no 	ati 	ent, entname

The identifier of the person who authorized the entry of this record
enterer_no 	eni 	ent, entname

The identifier of the person who actually entered this record.
modifier_no 	mdi 	ent, entname

The identifier of the person who last modified this record, if it has been modified.
authorizer 	ath 	entname

The name of the person who authorized the entry of this record
enterer 	ent 	entname

The name of the person who actually entered this record
modifier 	mdf 	entname

The name of the person who last modified this record, if it has been modified.
created 	dcr 	crmod

The date and time at which this record was created.
modified 	dmd 	crmod

The date and time at which this record was last modified.






<cfsetting requestTimeOut = "6000">



<cffile action = "read" file = "/usr/local/tmp/pdb.json" variable = "x">
<cfset j=DeserializeJSON(x)>
<!----
<cfdump var=#j#>
---->
<cftransaction>
<cfoutput>
	<cfloop array="#j.records#" index="rec">
		<cfquery name="ins" datasource="uam_god">
			insert into temp_pdb (
			<cfloop collection="#rec#" item="key">
		    	 #key#,
			</cfloop>
			dummy) values (
			<cfloop collection="#rec#" item="key">
		    	 '#rec[key]#',
			</cfloop>
			NULL)
		</cfquery>
	</cfloop>
</cfoutput>
</cftransaction>

SELECT taxon_rank, taxon_name
   FROM temp_pdbd
   CONNECT BY PRIOR parent_no=taxon_no
start with taxon_no=363;



create table temp_flat_pbdb as select * from cf_temp_classification where 1=2;


 CLASSIFICATION_ID							    VARCHAR2(4000)
 USERNAME							   NOT NULL VARCHAR2(255)
 SOURCE 							   NOT NULL VARCHAR2(255)
 TAXON_NAME_ID								    NUMBER
 SCIENTIFIC_NAME						   NOT NULL VARCHAR2(255)
 AUTHOR_TEXT								    VARCHAR2(255)


alter table temp_flat_pbdb modify USERNAME  null;
alter table temp_flat_pbdb modify SOURCE  null;


select taxon_no from temp_pdbd having count(*) > 1 group by taxon_no;
select count(*) from temp_pdbd where taxon_no is null;

select count(*) from temp_pdbd where taxon_no =parent_no;
select count(*) from temp_pdbd where parent_no is null;

select taxon_no,parent_no from temp_pdbd where taxon_name='Animalia';

select taxon_no,parent_no from temp_pdbd where taxon_no='212579';

select taxon_no,parent_no from temp_pdbd where taxon_no='1';
select taxon_no,parent_no from temp_pdbd where taxon_no='28595';
select taxon_no,parent_no from temp_pdbd where taxon_no='0';


update temp_pdbd set parent_no=0 where taxon_no =parent_no;



select * from 212579


SELECT *
  			 FROM temp_pdbd
   			CONNECT BY PRIOR parent_no=taxon_no
			start with taxon_no='1'
			;

			delete from temp_pdbd where orig_no='orig_no';

select distinct IS_EXTANT from temp_pdbd;


select TAXON_NAME, ACCEPTED_NAME from temp_pdbd;


create table temp_flat_pbdb as select * from cf_temp_classification where 1=2;
alter table temp_flat_pbdb add common_name varchar2(4000);
alter table temp_flat_pbdb add preferred_name varchar2(4000);
alter table temp_flat_pbdb add extinctyn varchar2(4000);
alter table temp_flat_pbdb add misses varchar2(4000);

---->


UAM@ARCTOS> desc temp_pdbd
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 ORIG_NO								    VARCHAR2(4000)
 TAXON_NO								    VARCHAR2(4000)
 RECORD_TYPE								    VARCHAR2(4000)
 FLAGS									    VARCHAR2(4000)
 TAXON_RANK								    VARCHAR2(4000)
 TAXON_NAME								    VARCHAR2(4000)
 TAXON_ATTR								    VARCHAR2(4000)
 DIFFERENCE								    VARCHAR2(4000)
 ACCEPTED_NO								    VARCHAR2(4000)
 ACCEPTED_RANK								    VARCHAR2(4000)
 ACCEPTED_NAME								    VARCHAR2(4000)
 PARENT_NO								    VARCHAR2(4000)
 REFERENCE_NO								    VARCHAR2(4000)
 IS_EXTANT								    VARCHAR2(4000)
 N_OCCS 								    VARCHAR2(4000)
 EARLY_INTERVAL 							    VARCHAR2(4000)
 LATE_INTERVAL								    VARCHAR2(4000)
 TAXON_SIZE								    VARCHAR2(4000)
 EXTANT_SIZE								    VARCHAR2(4000)
 PHYLUM 								    VARCHAR2(4000)
 CLASS									    VARCHAR2(4000)
 PORDER 								    VARCHAR2(4000)
 FAMILY 								    VARCHAR2(4000)
 GENUS									    VARCHAR2(4000)
 TYPE_TAXON								    VARCHAR2(4000)
 TAXON_ENVIRONMENT							    VARCHAR2(4000)
 ENVIRONMENT_BASIS							    VARCHAR2(4000)
 MOTILITY								    VARCHAR2(4000)
 LIFE_HABIT								    VARCHAR2(4000)
 VISION 								    VARCHAR2(4000)
 DIET									    VARCHAR2(4000)
 REPRODUCTION								    VARCHAR2(4000)
 ONTOGENY								    VARCHAR2(4000)
 ECOSPACE_COMMENTS							    VARCHAR2(4000)
 COMPOSITION								    VARCHAR2(4000)
 ARCHITECTURE								    VARCHAR2(4000)
 THICKNESS								    VARCHAR2(4000)
 REINFORCEMENT								    VARCHAR2(4000)
 GOT_THIS_ONE								    VARCHAR2(255)





<cfoutput>

	<cfquery name="d" datasource="uam_god">
		select * from temp_pdbd where rownum < 2 and got_this_one is null
	</cfquery>
	<cfdump var=#d#>
	<cfloop query="d">
		<cfset thisRec=[]>
		<cfset thisRec.preferred_name=d.TAXON_NAME>
		<cfif d.TAXON_NAME neq ACCEPTED_NAME>
			<cfset thisRec.preferred_name=d.ACCEPTED_NAME>
		</cfif>

		<br>d.taxon_no::#d.taxon_no#
		<cfquery name="c" datasource="uam_god">
			SELECT TAXON_RANK,TAXON_NAME
  			 FROM temp_pdbd
   			CONNECT BY PRIOR parent_no=taxon_no
			start with taxon_no='#d.taxon_no#'
		</cfquery>
		<cfloop query="c">
			<cfset "thisrec.#TAXON_RANK#"="#c.TAXON_NAME#">
		</cfloop>
		<cfdump var=#thisrec#>


		<cfdump var=#c#><br>




	</cfloop>

</cfoutput>


<!---

create table temp_pdbd (
orig_no VARCHAR2(4000),
taxon_no VARCHAR2(4000),
record_type VARCHAR2(4000),
flags VARCHAR2(4000),
taxon_rank VARCHAR2(4000),
taxon_name VARCHAR2(4000),
difference VARCHAR2(4000),
accepted_no VARCHAR2(4000),
accepted_rank VARCHAR2(4000),
accepted_name VARCHAR2(4000),
parent_no VARCHAR2(4000),
reference_no VARCHAR2(4000),
is_extant VARCHAR2(4000),
n_occs VARCHAR2(4000)
 16  );
--->
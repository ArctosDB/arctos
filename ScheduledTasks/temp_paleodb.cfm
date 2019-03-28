<!----



curl -o pdb.json https://paleobiodb.org/data1.2/taxa/list.json?all_taxa&variant=all


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
truncate table temp_pdb;

---->


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

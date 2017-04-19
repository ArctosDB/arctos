unrollDynamicProperties.cfm
<!----

	-- just turn the junk from VN into usable variable names with replace

	update temp_uwbm_mamm set DYNAMICPROPERTIES=replace(DYNAMICPROPERTIES,'"Accession Number"','"accn"');
	update temp_uwbm_mamm set DYNAMICPROPERTIES=replace(DYNAMICPROPERTIES,'"Collector and Collector Number"','"colls"');
	update temp_uwbm_mamm set DYNAMICPROPERTIES=replace(DYNAMICPROPERTIES,'"earLengthInMM"','"earmm"');
	update temp_uwbm_mamm set DYNAMICPROPERTIES=replace(DYNAMICPROPERTIES,'"hindfootLengthInMM"','"hfmm"');
	update temp_uwbm_mamm set DYNAMICPROPERTIES=replace(DYNAMICPROPERTIES,'"Preparator and Preparator Number"','"preps"');
	update temp_uwbm_mamm set DYNAMICPROPERTIES=replace(DYNAMICPROPERTIES,'"total length measurement system"','""');
	update temp_uwbm_mamm set DYNAMICPROPERTIES=replace(DYNAMICPROPERTIES,'"reproductive remarks"','"repro"');
	update temp_uwbm_mamm set DYNAMICPROPERTIES=replace(DYNAMICPROPERTIES,'"Litter size"','"littersize"');
	update temp_uwbm_mamm set DYNAMICPROPERTIES=replace(DYNAMICPROPERTIES,'"foot length measurement system"','"foot_units"');


	-- temp table to hold this stuff
	create table cf_vnDynamicProps (
		catnum  varchar2(4000),
		accn varchar2(4000),
		colls varchar2(4000),
		earmm varchar2(4000),
		hfmm varchar2(4000),
		tail varchar2(4000),
		totalLength varchar2(4000),
		weight varchar2(4000),
		tl_units varchar2(4000),
		repro varchar2(4000),
		littersize varchar2(4000)
	);

	alter table cf_vnDynamicProps add wth  varchar2(4000);
	alter table cf_vnDynamicProps add foot_units  varchar2(4000);
	alter table cf_vnDynamicProps add measurements  varchar2(4000);
	alter table cf_vnDynamicProps add preps  varchar2(4000);
	alter table cf_vnDynamicProps add FEATURE  varchar2(4000);


---->
<cfquery name="kc" datasource='prod'>
	select * from cf_vnDynamicProps where 1=2
</cfquery>

<cfquery name="d" datasource='prod'>
	select DYNAMICPROPERTIES,CATALOGNUMBER from temp_uwbm_mamm where CATALOGNUMBER not in (select catnum from  cf_vnDynamicProps) and rownum<10000
</cfquery>
<cfoutput>
	<cfloop query="d">
		<br>#CATALOGNUMBER#: #DYNAMICPROPERTIES#
		<cfset x=DeserializeJSON(DYNAMICPROPERTIES)>
		<cfquery name="insone" datasource='prod'>
			insert into cf_vnDynamicProps (catnum
			<cfloop list="#structKeyList(x)#" index="key">
				,#key#
			</cfloop>
			) values (
			'#CATALOGNUMBER#'
			<cfloop list="#structKeyList(x)#" index="key">
				,'#x[key]#'
			</cfloop>
			)
		</cfquery>
	</cfloop>
</cfoutput>
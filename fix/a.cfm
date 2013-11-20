<cfinclude template="/includes/_header.cfm">

<cfquery name="d" datasource="uam_god">
	select * from user_tab_cols where table_name like 'CT%'
</cfquery>
<cfquery name="tabl" dbtype="query">
	select table_name from d group by table_name
</cfquery>

<cfoutput>
	<cfloop query="tabl">
		<cfquery name="cols" dbtype="query">
			select * from d where table_name='#table_name#'
		</cfquery>
		
		<cfset thisSQL="create table log_#tabl.table_name# ( ">
		<p>
			
			<cfloop query="cols">
				<cfset thisSQL=thisSQL & "n_#COLUMN_NAME# #DATA_TYPE#(#DATA_LENGTH#),">
			</cfloop>
			<cfloop query="cols">
				<cfset thisSQL=thisSQL & "o_#COLUMN_NAME# #DATA_TYPE#(#DATA_LENGTH#),">
			</cfloop>
			<cfset thisSQL=thisSQL & ");">
			<cfset thisSQL=replace(thisSQL,',);',');')>
			#thisSQL#
			
		</p>
		<!---------
		
		create table log_geog_auth_rec (
	GEOG_AUTH_REC_ID NUMBER,
	username varchar2(60),
	action_type varchar2(60),
	when date default sysdate,
	n_CONTINENT_OCEAN VARCHAR2(50),
	n_COUNTRY VARCHAR2(50),
	n_STATE_PROV VARCHAR2(75),
	n_COUNTY VARCHAR2(50),
	n_QUAD VARCHAR2(30),
	n_FEATURE VARCHAR2(50),
	n_ISLAND VARCHAR2(50),
	n_ISLAND_GROUP VARCHAR2(50),
	n_SEA VARCHAR2(50),
	o_CONTINENT_OCEAN VARCHAR2(50),
	o_COUNTRY VARCHAR2(50),
	o_STATE_PROV VARCHAR2(75),
	o_COUNTY VARCHAR2(50),
	o_QUAD VARCHAR2(30),
	o_FEATURE VARCHAR2(50),
	o_ISLAND VARCHAR2(50),
	o_ISLAND_GROUP VARCHAR2(50),
	o_SEA VARCHAR2(50)
);
		
		
		TABLE_NAME							   NOT NULL VARCHAR2(30)
 COLUMN_NAME							   NOT NULL VARCHAR2(30)
 DATA_TYPE								    VARCHAR2(106)
 DATA_TYPE_MOD								    VARCHAR2(3)
 DATA_TYPE_OWNER							    VARCHAR2(30)
 DATA_LENGTH							   NOT NULL NUMBER
 DATA_PRECISION 							    NUMBER
 DATA_SCALE								    NUMBER
 NULLABLE								    VARCHAR2(1)
 COLUMN_ID								    NUMBER
 DEFAULT_LENGTH 							    NUMBER
 DATA_DEFAULT								    LONG
 NUM_DISTINCT								    NUMBER
 LOW_VALUE								    RAW(32)
 HIGH_VALUE								    RAW(32)
 DENSITY								    NUMBER
 NUM_NULLS								    NUMBER
 NUM_BUCKETS								    NUMBER
 LAST_ANALYZED								    DATE
 SAMPLE_SIZE								    NUMBER
 CHARACTER_SET_NAME							    VARCHAR2(44)
 CHAR_COL_DECL_LENGTH							    NUMBER
 GLOBAL_STATS								    VARCHAR2(3)
 USER_STATS								    VARCHAR2(3)
 AVG_COL_LEN								    NUMBER
 CHAR_LENGTH								    NUMBER
 CHAR_USED								    VARCHAR2(1)
 V80_FMT_IMAGE								    VARCHAR2(3)
 DATA_UPGRADED								    VARCHAR2(3)
 HIDDEN_COLUMN								    VARCHAR2(3)
 VIRTUAL_COLUMN 							    VARCHAR2(3)
 SEGMENT_COLUMN_ID							    NUMBER
 INTERNAL_COLUMN_ID						   NOT NULL NUMBER
 HISTOGRAM								    VARCHAR2(15)
 QUALIFIED_COL_NAME							    VARCHAR2(4000)



------------>

	</cfloop>
</cfoutput>

<cfinclude template="/includes/_footer.cfm">


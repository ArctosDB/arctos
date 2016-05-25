<!----

https://docs.google.com/spreadsheets/d/1jgFP2gBS-ukFvR9owUATHUX21YAmKAbII9CfmHAoCug/edit#gid=631812590

create table temp_iso_cc as select * from dlm.my_temp_cf;

alter table temp_iso_cc add geog_auth_rec_id number;

UAM@ARCTOS> desc geog_auth_rec
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 GEOG_AUTH_REC_ID						   NOT NULL NUMBER
 CONTINENT_OCEAN							    VARCHAR2(50)
 COUNTRY								    VARCHAR2(50)
 STATE_PROV								    VARCHAR2(75)
 COUNTY 								    VARCHAR2(50)
 QUAD									    VARCHAR2(30)
 FEATURE								    VARCHAR2(50)
 ISLAND 								    VARCHAR2(50)
 ISLAND_GROUP								    VARCHAR2(50)
 SEA									    VARCHAR2(50)
 VALID_CATALOG_TERM_FG						   NOT NULL NUMBER(3)
 SOURCE_AUTHORITY						   NOT NULL VARCHAR2(255)
 HIGHER_GEOG							   NOT NULL VARCHAR2(255)
 STRIPPED_KEY							   NOT NULL VARCHAR2(4000)
 GEOG_REMARK								    VARCHAR2(4000)
 WKT_POLYGON								    CLOB



----->
	<cfquery name="c" datasource="uam_god">
		select
			country,
			geog_auth_rec_id
		from
			geog_auth_rec
		where
			country is not null and
			STATE_PROV is null and
			COUNTY is null and
			QUAD is null and
			FEATURE is null and
			ISLAND  is null and
			ISLAND_GROUP is null and
			SEA is null
	</cfquery>
	<cfoutput>
	<cfloop query="c">
		<br>#country#
	</cfloop>
	</cfoutput>

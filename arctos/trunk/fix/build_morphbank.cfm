<cfoutput>
<!---
<cfquery name="nci" datasource="#Application.uam_dbo#">
	insert into t (c) values (
		<cfqueryparam cfsqltype="cf_sql_varchar" 
							value="http://www.morphbank.net/Show/?pop=Ye&id=4">
							)
</cfquery>

<cfabort>

---->
<cfquery name="mb" datasource="#Application.uam_dbo#">
	select * from mb where done is null
</cfquery>

<cfloop query="mb">
<cftransaction >
	<cftry>
		<cfdirectory action="create" directory="/var/www/html/SpecimenImages/UAM/Herb/#u#">
			<cfcatch>
				---already got one---
				<!--- it already exists, do nothing--->
			</cfcatch>
	</cftry>

	<cffile action="copy" source="/var/www/html/temp/mb/#f#" destination="/var/www/html/SpecimenImages/UAM/Herb/#u#/#f#">
	<cfquery name="mcid" datasource="#Application.uam_dbo#">
		select max(collection_object_id) + 1 mcid from coll_object
	</cfquery>
	<cfquery name="catdata" datasource="#Application.uam_dbo#">
		select 
			cataloged_item.collection_object_id
		from
			cataloged_item
		where
			collection_id=6 and
			cat_num=#u#
	</cfquery>
	<cfquery name="nci" datasource="#Application.uam_dbo#">
		INSERT INTO coll_object (
			COLLECTION_OBJECT_ID,
			COLL_OBJECT_TYPE,
			ENTERED_PERSON_ID,
			COLL_OBJECT_ENTERED_DATE,
			COLL_OBJ_DISPOSITION,
			LOT_COUNT,
			CONDITION
		) values (
			#mcid.mcid#,
			'IO',
			2072,
			sysdate,
			'not applicable',
			1,
			'not applicable'
		)
	</cfquery>

	<cfquery name="nbo" datasource="#Application.uam_dbo#">
		insert into binary_object (
			 COLLECTION_OBJECT_ID,
			 VIEWER_ID,
			 DERIVED_FROM_CAT_ITEM,
			 MADE_DATE,
			 SUBJECT,
			 description,
			 FULL_URL,
			 MADE_AGENT_ID,
			 THUMBNAIL_URL
		) values (
			#mcid.mcid#,
			1,
			#catdata.collection_object_id#,
			sysdate,
			'prepared specimen',
			'UAM Herb #u# MorphBank Record',
			<cfqueryparam cfsqltype="cf_sql_varchar" 
							value="http://www.morphbank.net/Show/?pop=Yes&id=#m#">
			,
			1016226,
			'http://arctos.database.museum/SpecimenImages/UAM/Herb/#u#/#f#'
		)
	</cfquery>
	<cfquery name="done" datasource='#Application.uam_dbo#'>
		update mb set done=1 where u=#u#
	</cfquery>
	#u# - #m# - #f#<br>
	</cftransaction>
</cfloop>
</cfoutput>
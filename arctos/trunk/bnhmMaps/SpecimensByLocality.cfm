deprecated<cfabort>
Retrieving map data - please wait....
<cfflush>
<cfoutput>
	<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>
		<cfset flatTableName = "flat">
	<cfelse>
		<cfset flatTableName = "filtered_flat">
	</cfif>
	<cfset dlPath = "#Application.webDirectory#/bnhmMaps/tabfiles/">
	<cfset dlFile = "tabfile#left(session.sessionKey,10)#.txt">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select 
			#flatTableName#.collection_object_id,
			#flatTableName#.cat_num,
			locality.dec_lat,
			locality.dec_long,
			specimen_event_type,
			to_meters(locality.max_error_distance,locality.max_error_units) errorInMeters,
			locality.datum,
			#flatTableName#.scientific_name,
			#flatTableName#.collection,
			#flatTableName#.spec_locality,
			#flatTableName#.locality_id,
			#flatTableName#.verbatimLatitude,
			#flatTableName#.verbatimLongitude
		 from 
		 	#flatTableName#,
		 	lat_long
		 where
		 	#flatTableName#.locality_id = lat_long.locality_id and
		 	#flatTableName#.locality_id IN (
		 		select #flatTableName#.locality_id from #table_name#,#flatTableName#
		 		where #flatTableName#.collection_object_id = #table_name#.collection_object_id)
		 		
		 		
		 		 from 
		 	#flatTableName#,
		 	specimen_event,
		 	collecting_event,
		 	locality,
		 	#table_name#		 	
		 where
		 	#flatTableName#.collection_object_id = specimen_event.collection_object_id and
		 	specimen_event.collecting_event_id=collecting_event.collecting_event_id and
		 	collecting_event.locality_id=locality.locality_id and
		 	locality.dec_lat is not null 
		 	#flatTableName#.collection_object_id = #table_name#.collection_object_id
		 	
		 	
		 	
	</cfquery>
	<cfquery name="loc" dbtype="query">
		select 
			dec_lat,
			dec_long,
			isAcceptedLatLong,
			errorInMeters,
			datum,
			spec_locality,
			locality_id,
			verbatimLatitude,
			verbatimLongitude
		from
			data
		group by
			dec_lat,
			dec_long,
			isAcceptedLatLong,
			errorInMeters,
			datum,
			spec_locality,
			locality_id,
			verbatimLatitude,
			verbatimLongitude
	</cfquery>
	<cffile action="write" file="#dlPath##dlFile#" addnewline="no" output="" nameconflict="overwrite">
	<cfloop query="loc">
		<cfquery name="sdet" dbtype="query">
			select 
				collection_object_id,
				cat_num,
				scientific_name,
				collection
			from
				data
			where
				locality_id = #locality_id#
			group by
				collection_object_id,
				cat_num,
				scientific_name,
				collection
		</cfquery>
		<cfset specLink = "">
		<cfloop query="sdet">
			<cfset rColn = replace(collection," ","&nbsp;","all")>
			<cfset rName = replace(scientific_name," ","&nbsp;","all")>
			<cfset oneSpecLink = '<a href="#Application.serverRootUrl#/SpecimenDetail.cfm?collection_object_id=#collection_object_id#" target="_blank">#rColn#&nbsp;#cat_num#&nbsp;#rName#</a>'>
			<cfif len(#specLink#) is 0>
				<cfset specLink = oneSpecLink>
			<cfelse>
				<cfset specLink = '#specLink#<br>#oneSpecLink#'>
			</cfif>
		</cfloop>
		<cfset relInfo='<a href="#Application.ServerRootUrl#/editLocality.cfm?locality_id=#locality_id#" target="_blank">#spec_locality#</a>'>
		<cfset oneLine="#relInfo##chr(9)##locality_id##chr(9)##lat_long_id##chr(9)##spec_locality##chr(9)##dec_lat##chr(9)##dec_long##chr(9)##errorInMeters##chr(9)##datum##chr(9)##isAcceptedLatLong##chr(9)##specLink##chr(9)##verbatimLatitude#/#verbatimLongitude#">
		<cfset oneLine=trim(oneLine)>
		<cffile action="append" file="#dlPath##dlFile#" addnewline="yes" output="#oneLine#">
	</cfloop>

	<cfset bnhmUrl="http://berkeleymapper.berkeley.edu/index.php?ViewResults=tab&tabfile=#Application.ServerRootUrl#/bnhmMaps/tabfiles/#dlFile#&configfile=#Application.ServerRootUrl#/bnhmMaps/SpecByLoc.xml&sourcename=Locality">
	

	<script type="text/javascript" language="javascript">
		document.location='#bnhmUrl#';
	</script>
</cfoutput>
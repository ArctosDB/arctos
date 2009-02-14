<cfinclude template="/includes/_header.cfm">
<cfif #action# is "nothing">
    <cfoutput>
    <cfquery name="ctOtherIdType" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,60,0)#">
		SELECT distinct(other_id_type) other_id_type FROM ctColl_Other_id_type
			order by other_id_type
       </cfquery>
    <form name="a" method="post" action="">
        <input type="hidden" name="action" value="getData">
        <input type="hidden" name="collection_object_id" value="#collection_object_id#">
        <label for="user_otherID">Other ID</label>
        <select name="user_otherID" id="user_otherID" size="1">
            <option value="">None</option>
            <cfloop query="ctOtherIdType">
                <option value="#other_id_type#">#other_id_type#</option>
            </cfloop>
        </select>
        <label for="line3">Line 3</label>
        <input type="text" id="line3" name="line3">
        <input type="submit">
    </form>
    </cfoutput>
</cfif>
<cfif #action# is "getData">
<cfoutput>	
<cfset sql="
	select
	    concatsingleotherid(cataloged_item.collection_object_id,'#user_otherID#') user_id_num,
        '#user_otherID#' user_id_type,
        '#line3#' line3,
        scientific_name,
		decode(trim(ConcatAttributeValue(cataloged_item.collection_object_id,'sex')),
			'male','M',
			'female','F',
			'U') sex,					
		concatParts(cataloged_item.collection_object_id) parts,
		cat_num,
		state_prov,
		country,
		quad,
		county,
		island,
		island_group,
		sea,
		feature,
		spec_locality,
		CASE orig_lat_long_units
			WHEN 'decimal degrees' THEN dec_lat || 'd'
			WHEN 'deg. min. sec.' THEN lat_deg || 'd ' || lat_min || 'm ' || lat_sec || 's ' || lat_dir
			WHEN 'degrees dec. minutes' THEN lat_deg || 'd ' || dec_lat_min || 'm ' || lat_dir
		END as VerbatimLatitude,
		CASE orig_lat_long_units
			WHEN 'decimal degrees' THEN dec_long || 'd'
			WHEN'degrees dec. minutes' THEN long_deg || 'd ' || dec_long_min || 'm ' || long_dir
			WHEN 'deg. min. sec.' THEN long_deg || 'd ' || long_min || 'm ' || long_sec || 's ' || long_dir
		END as VerbatimLongitude,
		MAXIMUM_ELEVATION,
		MINIMUM_ELEVATION,
		ORIG_ELEV_UNITS,
		concatColl(cataloged_item.collection_object_id) as collectors,
		concatPrep(cataloged_item.collection_object_id) as preparators,
		concatotherid(cataloged_item.collection_object_id) as other_ids,
		concatsingleotherid(cataloged_item.collection_object_id,'collector number') collector_number,
		concatsingleotherid(cataloged_item.collection_object_id,'preparator number') preparator_number,
		concatsingleotherid(cataloged_item.collection_object_id,'NK') NK,
		verbatim_date,
		began_date,
		ended_date,
		habitat_desc,
		habitat
	FROM
		cataloged_item,
		identification,
		collecting_event,
		locality,
		geog_auth_rec,
		accepted_lat_long,
		coll_object_remark,
		project_trans,
		project
	WHERE
		cataloged_item.collection_object_id = identification.collection_object_id AND
		cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND
		collecting_event.locality_id = locality.locality_id AND
		locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND
		locality.locality_id = accepted_lat_long.locality_id (+) AND
		cataloged_item.collection_object_id = coll_object_remark.collection_object_id (+) AND
		cataloged_item.accn_id = project_trans.transaction_id (+) AND
		project_trans.project_id = project.project_id(+) AND
		accepted_id_fg=1 AND cataloged_item.collection_object_id IN (#collection_object_id#)
	ORDER BY
		cat_num">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(sql)#
	</cfquery>
	<cfset lAr = ArrayNew(1)>
	<cfset gAr = ArrayNew(1)>
	<cfset dAr = ArrayNew(1)>
	<cfset i=1>
	<cfloop query="data">
        <cfset geog="">
		<cfif #country# is "United States">
			<cfset geog="USA">
		<cfelse>
			<cfset geog="#geog#, #country#">
		</cfif>
		<cfset geog="#geog#: #state_prov#">
		<cfif len(#county#) gt 0>
			<cfset geog="#geog#; #replace(county,'County','Co.')#">
		</cfif>
		<cfset coordinates = "">
		<cfif len(#verbatimLatitude#) gt 0 AND len(#verbatimLongitude#) gt 0>
			<cfset coordinates = "#verbatimLatitude# / #verbatimLongitude#">
			<!---
			<cfset coordinates = replace(coordinates,"d","&##176;","all")>
			<cfset coordinates = replace(coordinates,"m","'","all")>
			<cfset coordinates = replace(coordinates,"s","''","all")>
			--->
		</cfif>
		<cfset locality="#geog#,">
		<cfif len(#quad#) gt 0>
			<cfset locality = "#quad# Quad.:">
		</cfif>
		<cfif len(#spec_locality#) gt 0>
			<cfset locality = "#locality# #spec_locality#">
		</cfif>
		<cfif len(#coordinates#) gt 0>
		 	<cfset locality = "#locality#, #coordinates#">
		 </cfif>
		  <cfif len(#ORIG_ELEV_UNITS#) gt 0>
		 	<cfset locality = "#locality#. Elev. #MINIMUM_ELEVATION#-#MAXIMUM_ELEVATION# #ORIG_ELEV_UNITS#">
		 </cfif>
		 <cfif len(#habitat#) gt 0>
		 	<cfset locality = "#locality#, #habitat#">
		 </cfif>
		 <cfif right(locality,1) is not ".">
			 <cfset locality = "#locality#.">
		</cfif>
		<cfset lAr[i] = #locality#>
		<cftry>
			<cfset dAr[i] = #dateformat(verbatim_date,"dd mmmm yyyy")#>
			<cfcatch>
				<cfset dAr[i] = #verbatim_date#>
			</cfcatch>
		</cftry>
		
		<cfset i=i+1>
		
	</cfloop>
		
	<cfset temp=queryAddColumn(data,"locality","VarChar",lAr)>
	<cfset temp=queryAddColumn(data,"geog","VarChar",gAr)>
	<cfset temp=queryAddColumn(data,"formatted_date","VarChar",dAr)>
		
	

	<cfset fileDir = "#Application.webDirectory#">		
	<cfset fileName = "/download/ArctosLabelData.csv">
	<cfset ac=data.columnlist>
	<cfset header=#trim(ac)#>
		<cffile action="write" file="#fileDir##fileName#" addnewline="yes" output="#header#">
		<cfloop query="data">
			<cfset oneLine = "">
			<cfloop list="#ac#" index="c">
				<cfset thisData = #evaluate(c)#>
				<cfif #c# is "BEGAN_DATE" or #c# is "ENDED_DATE">
					<cfset thisData=dateformat(thisData,"dd-mmm-yyyy")>
				</cfif>
				<cfif len(#oneLine#) is 0>
					<cfset oneLine = '"#thisData#"'>
				<cfelse>
					<cfset oneLine = '#oneLine#,"#thisData#"'>
				</cfif>
			</cfloop>
			<cfset oneLine = trim(oneLine)>
			<cffile action="append" file="#fileDir##fileName#" addnewline="yes" output="#oneLine#">
		</cfloop>
		<a href="#Application.serverRootUrl#/#fileName#">Right-click to save your download.</a>
</cfoutput>
</cfif>
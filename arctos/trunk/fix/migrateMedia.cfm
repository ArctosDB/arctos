<cfinclude template="/includes/_header.cfm">

<cfquery name="m" datasource="uam_god">
	select * from binary_object
</cfquery>
<cfquery name="ms" datasource="uam_god">
	select seq_media.nextval nv from dual
</cfquery>
<cfset mid=ms.nv>
<cfoutput>
	<cfloop query="m">
		<cfset dotPos=find(".",reverse(full_url))>
		<cfset ext=right(full_url,dotPos)>
		<cfif ext is ".jpeg" or ext is ".jpg" or ext is ".JPG" or ext is ".JPEG">
			<cfset mtype="image/jpeg">
		<cfelseif ext is ".TIFF" or ext is ".tiff">
			<cfset mtype="image/tiff">
		<cfelseif left(ext,4) is ".net">
			<cfset mtype="text/html">
		<cfelse>
			-----------badext: #ext#-----------
			<cfabort>
		</cfif>
		
		
		insert into media (
			media_id,
			media_uri,
			mime_type,
			media_type,
			preview_uri
		) values (
			#mid#,
			'#FULL_URL#',
			'#mtype#',
			'image',
			'#THUMBNAIL_URL#')
			<br>
		insert into media_relations (
    		media_id,
			media_relationship,
			created_by_agent_id,
			related_primary_key
		) values (
			#mid#,
			'shows cataloged_item',
			2072,
			#DERIVED_FROM_CAT_ITEM#
		)
		<br>
		insert into media_relations (
    		media_id,
			media_relationship,
			created_by_agent_id,
			related_primary_key
		) values (
			#mid#,
			'created by agent',
			2072,
			#MADE_AGENT_ID#
		)
		<br>
		insert into media_labels (
    		media_id,
			media_label,
			label_value
		) values (
			#mid#,
			'made date',
			'#dateformat(MADE_DATE,"dd mmm yyyy")#'
		)
		<br>
		insert into media_labels (
    		media_id,
			media_label,
			label_value
		) values (
			#mid#,
			'subject',
			'#SUBJECT#'
		)
		<cfif len(#DESCRIPTION#) gt 0>
			<br>
			insert into media_labels (
	    		media_id,
				media_label,
				label_value
			) values (
				#mid#,
				'description',
				'#DESCRIPTION#'
			)
		</cfif>
		<cfif len(#ASPECT#) gt 0>
			<br>
			insert into media_labels (
	    		media_id,
				media_label,
				label_value
			) values (
				#mid#,
				'aspect',
				'#ASPECT#'
			)
		</cfif>
			<hr>
			<cfset mid=mid+1>
	</cfloop> 
</cfoutput>
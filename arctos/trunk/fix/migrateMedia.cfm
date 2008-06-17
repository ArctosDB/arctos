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
			
			<hr>
			<cfset mid=mid+1>
	</cfloop>
	
	
	 COLLECTION_OBJECT_ID                                  NOT NULL NUMBER
 VIEWER_ID                                             NOT NULL NUMBER
 DERIVED_FROM_CAT_ITEM                                 NOT NULL NUMBER
 DERIVED_FROM_COLL_OBJ                                          NUMBER
 MADE_DATE                                             NOT NULL DATE
 SUBJECT                                               NOT NULL VARCHAR2(50)
 ASPECT                                                         VARCHAR2(30)
 DESCRIPTION                                                    VARCHAR2(255)
                                               NOT NULL VARCHAR2(255)
 MADE_AGENT_ID                                         NOT NULL NUMBER
 
</cfoutput>
<cfabort>



<cfoutput>

<cfhttp url="http://web.corral.tacc.utexas.edu/UAF/1000MachineOutputWithSpellingCorrection/" charset="utf-8" method="get"></cfhttp>
<cfif isXML(cfhttp.FileContent)>
	<cfset xStr=cfhttp.FileContent>
	<!--- goddamned xmlns bug in CF --->
	<cfset xStr= replace(xStr,' xmlns="http://www.w3.org/1999/xhtml" xml:lang="en"','')>
	<cfset xdir=xmlparse(xStr)>
	<cfset dir = xmlsearch(xdir, "//td[@class='n']")>
	<cftransaction>
	<cfloop index="i" from="1" to="#arrayLen(dir)#">
		<cfset thisFile = dir[i].XmlChildren[1].xmlText>
		<cfif right(thisFile,4) is ".xml">
			<br>#thisFile#
			<cfset thisBarcode=listgetat(thisFile,1,".")>
			
			<br>#thisBarcode#
			
			<cfquery name="d" datasource="uam_god">
				select 
					c.barcode,
					guid,
					flat.collection_object_id
				from 
					flat,
					specimen_part,
					coll_obj_cont_hist,
					container p,
					container c 
				where 
					flat.collection_object_id=specimen_part.derived_from_cat_item and
					specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
					coll_obj_cont_hist.container_id=p.container_id and
					p.parent_container_id=c.container_id and
					c.barcode ='#thisBarcode#'
			</cfquery>
			<cfif d.recordcount is 1>
				<cfset muri='http://web.corral.tacc.utexas.edu/UAF/1000MachineOutputWithSpellingCorrection/#thisFile#'>
				<cfquery name="nid" datasource="uam_god">
					select sq_media_id.nextval media_id from dual
				</cfquery>
				<cfquery name="media" datasource="uam_god">
					insert into media (
						media_id,
						media_uri,
						mime_type,
						media_type
					) values (
						#nid.media_id#,
						'#muri#',
						'application/xml',
						'text'
					)
				</cfquery>
				<cfquery name="mr_cat" datasource="uam_god">
					insert into media_relations (
						MEDIA_ID,
						MEDIA_RELATIONSHIP,
						CREATED_BY_AGENT_ID,
						RELATED_PRIMARY_KEY
					) values (
						#nid.media_id#,
						'shows cataloged_item',
						2072,
						#d.collection_object_id#
					)
				</cfquery>
				<cfquery name="mr_agnt" datasource="uam_god">
					insert into media_relations (
						MEDIA_ID,
						MEDIA_RELATIONSHIP,
						CREATED_BY_AGENT_ID,
						RELATED_PRIMARY_KEY
					) values (
						#nid.media_id#,
						'created by agent',
						2072,
						21259824
					)
				</cfquery>
				<cfquery name="lbl" datasource="uam_god">
					insert into  media_labels (
						MEDIA_ID,
						MEDIA_LABEL,
						LABEL_VALUE,
						ASSIGNED_BY_AGENT_ID
					) values (
						#nid.media_id#,
						'description',
						'Herbis corrected OCR',
						2072
					)
				</cfquery>
				<!---------
				
				
				
				
					insert into media (
						media_id,
						media_uri,
						mime_type,
						media_type
					) values (
						#nid.media_id#,
						'#muri#',
						'image/dng',
						'image'
					)
				</cfquery>
				
				
				
				
				-------->
			</cfif>
		</cfif>
	</cfloop>
	</cftransaction>
</cfif>
</cfoutput>
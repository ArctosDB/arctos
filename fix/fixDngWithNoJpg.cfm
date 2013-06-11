<cfabort>


<cfquery name="d" datasource="uam_god">
select 
MEDIA_ID,
								media_uri,
								MIME_TYPE,
								MEDIA_TYPE,
								PREVIEW_URI,
								regexp_replace(media_uri,'^(http.*)(H.*)(dng)$','\1jpegs/\2jpg') jpeguri
 from media where mime_type='image/dng' and media_id not in (select related_primary_key from media_relations where media_relationship='derived from media')

</cfquery>

<cfoutput>

<cftransaction>
	<cfloop query="d">
		<p>
			<br>#media_id#
			<br>#media_uri#
			
			
			<cfquery name="dngci" datasource="uam_god">
				select * from media_relations where media_id=#media_id# and media_relationship='shows cataloged_item'
			</cfquery>
			
			
			<cfquery name="dngci" datasource="uam_god">
				select * from media_relations where media_id=#media_id# and media_relationship='shows cataloged_item'
			</cfquery>
			
		
			
			<cfquery name="dngl" datasource="uam_god">
				select * from media_labels where media_id=#media_id# and media_label='description'
			</cfquery>
			
					<cfif dngci.recordcount is 1 and dngl.recordcount is 1 and len(dngci.media_id) gt 0 and len(dngl.label_value) gt 0>
					
						<cfquery name="mm" datasource="uam_god">
							insert into media (
								MEDIA_ID,
								media_uri,
								MIME_TYPE,
								MEDIA_TYPE,
								PREVIEW_URI
							) values (
								sq_media_id.nextval,
								'#jpeguri#',
								'image/jpeg',
								'image',
								'#PREVIEW_URI#'
							)
						</cfquery>

				insert into media (
					MEDIA_ID,
								media_uri,
					MIME_TYPE,
					MEDIA_TYPE,
					PREVIEW_URI
				) values (
					nval,
								'#jpeguri#',
					'image/jpeg',
					'image',
					'#PREVIEW_URI#'
				)
				
				
						<cfquery name="mmr1" datasource="uam_god">
						insert into media_relations (
					MEDIA_ID,
					MEDIA_RELATIONSHIP,
					CREATED_BY_AGENT_ID,
					RELATED_PRIMARY_KEY
				) values (
					sq_media_id.currval,
					'shows cataloged_item',
					#dngci.CREATED_BY_AGENT_ID#,
					#dngci.RELATED_PRIMARY_KEY#
				)
						</cfquery>
				
				insert into media_relations (
					MEDIA_ID,
					MEDIA_RELATIONSHIP,
					CREATED_BY_AGENT_ID,
					RELATED_PRIMARY_KEY
				) values (
					curval,
					'shows cataloged_item',
					#dngci.CREATED_BY_AGENT_ID#,
					#dngci.RELATED_PRIMARY_KEY#
				)
				
				
						<cfquery name="mmr2" datasource="uam_god">
						insert into media_relations (
					MEDIA_ID,
					MEDIA_RELATIONSHIP,
					CREATED_BY_AGENT_ID,
					RELATED_PRIMARY_KEY
				) values (
					sq_media_id.currval,
					'derived from media',
					#dngci.CREATED_BY_AGENT_ID#,
					#media_id#
				)
						</cfquery>
				insert into media_relations (
					MEDIA_ID,
					MEDIA_RELATIONSHIP,
					CREATED_BY_AGENT_ID,
					RELATED_PRIMARY_KEY
				) values (
					curval,
					'derived from media',
					#dngci.CREATED_BY_AGENT_ID#,
					#media_id#
				)
				
				
				<cfquery name="mml" datasource="uam_god">
				insert into media_labels (
					MEDIA_ID,
					MEDIA_LABEL,
					LABEL_VALUE,
					ASSIGNED_BY_AGENT_ID
				) values (
					sq_media_id.currval,
					'#dngl.MEDIA_LABEL#',
					'#dngl.LABEL_VALUE#',
					#dngl.ASSIGNED_BY_AGENT_ID#
				)
				</cfquery>
				insert into media_labels (
					MEDIA_ID,
					MEDIA_LABEL,
					LABEL_VALUE,
					ASSIGNED_BY_AGENT_ID
				) values (
					curval,
					'#dngl.MEDIA_LABEL#',
					'#dngl.LABEL_VALUE#',
					#dngl.ASSIGNED_BY_AGENT_ID#'
				)
			<cfelse>
				somethingbroke
			</cfif>
		</p>
	</cfloop>
	
	</cftransaction>
</cfoutput>
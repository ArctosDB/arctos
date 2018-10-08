
<cfoutput>




		<cfquery name="d" datasource="uam_god">
			select distinct FORMER_TAXON_NAME,NEW_TAXON_NAME  from temp_former_subgenus_ids where new_taxon_name in (select SCIENTIFIC_NAME from temp_taxon_sn_nn)
		</cfquery>
		<cfloop query="d">
			<br>#FORMER_TAXON_NAME#
			<cfquery name="id" datasource="uam_god">
				select taxon_name_id from taxon_name where scientific_name='#FORMER_TAXON_NAME#'
			</cfquery>

			<cfquery name="c" datasource="uam_god">
				select * from taxon_term where source in ('Arctos','Arctos Plants') and taxon_name_id=#id.taxon_name_id#
			</cfquery>
			<cfquery name="cnt" dbtype="query">
				select distinct classification_id from c
			</cfquery>
			<cfif cnt.recordcount is 1>
				<br>rock on....
			</cfif>

			<!----
			<cfdump var=#exc#>
					<cfset thisSourceID=CreateUUID()>
					<cfquery name="newdata" dbtype="query">
						select
							POSITION_IN_CLASSIFICATION,
							SOURCE,
							TERM,
							TERM_TYPE
						from
							exc
						where
							TERM_TYPE!='genus' and TERM_TYPE!='display_name' and TERM_TYPE!='scientific_name'
					</cfquery>
					<cfdump var=#newdata#>
					<cfloop query="newdata">
						<!----
						<cfquery name="makeaterm" datasource="uam_god">
							insert into taxon_term (
								TAXON_TERM_ID,
								TAXON_NAME_ID,
								CLASSIFICATION_ID,
								TERM,
								TERM_TYPE,
								SOURCE,
								LASTDATE
							) values (
								sq_TAXON_TERM_ID.nextval,
								#tnid.tnid#,
								'#thisSourceID#',
								'#newdata.term#',
								'#newdata.TERM_TYPE#',
								'#newdata.SOURCE#',
								sysdate
							)
						</cfquery>
						---->
						<br>insert into taxon_term (
								TAXON_TERM_ID,
								TAXON_NAME_ID,
								CLASSIFICATION_ID,
								TERM,
								TERM_TYPE,
								SOURCE,
								LASTDATE
							) values (
								sq_TAXON_TERM_ID.nextval,
								#tnid.tnid#,
								'#thisSourceID#',
								'#newdata.term#',
								'#newdata.TERM_TYPE#',
								'#newdata.SOURCE#',
								sysdate
							);
					</cfloop>
				</cfif>
			</cfif>
			---->
		</cfloop>




	<!----
	<cfif action is "CaptureIntendedMoveSpecimenIDs">

		<cfquery name="d" datasource="uam_god">
			select * from taxon_name where scientific_name like '%(%'
		</cfquery>
		<cfloop query="d">
			<br>scientific_name:#scientific_name#
			<cfquery name="id" datasource="uam_god">
				select
					 identification_taxonomy.identification_id,
					 identification_taxonomy.taxon_name_id,
					 flat.guid
				from
					identification_taxonomy,
					identification,
					flat
				where
					identification_taxonomy.taxon_name_id=#d.taxon_name_id# and
					identification_taxonomy.identification_id=identification.identification_id and
					identification.collection_object_id=flat.collection_object_id
			</cfquery>
			<cfset startpos=find('(',scientific_name)>
			<cfset stoppos=find(')',scientific_name)>
			<cfset theSG=mid(scientific_name,startpos+1,stoppos-startpos-1)>
			<br>replacement:#theSG#
			<cfquery name="rid" datasource="uam_god" >
				select * from taxon_name where scientific_name='#theSG#'
			</cfquery>
			<cfloop query="id">
				<cfquery name="upidt" datasource="uam_god">
					insert into temp_former_subgenus_id (
						guid,
						former_taxon_name,
						new_taxon_name
					) values (
						'#id.guid#',
						'#d.scientific_name#',
						'#rid.scientific_name#'
					)
				</cfquery>
			</cfloop>
		</cfloop>
	</cfif>


	<cfif action is "moveSpecimenIDs">
		<cfquery name="d" datasource="uam_god">
			select * from taxon_name where scientific_name like '%(%'
		</cfquery>
		<cfloop query="d">
			<br>scientific_name:#scientific_name#
			<cfquery name="id" datasource="uam_god">
				select identification_id from identification_taxonomy where taxon_name_id=#d.taxon_name_id#
			</cfquery>
			<cfif id.recordcount gt 0>
				<cfdump var=#id#>
				<cfset startpos=find('(',scientific_name)>
				<cfset stoppos=find(')',scientific_name)>
				<cfset theSG=mid(scientific_name,startpos+1,stoppos-startpos-1)>
				<br>replacement:#theSG#
				<cfquery name="rid" datasource="uam_god">
					select * from taxon_name where scientific_name='#theSG#'
				</cfquery>
				<cfquery name="upidt" datasource="uam_god">
					update identification_taxonomy set taxon_name_id=#rid.taxon_name_id# where taxon_name_id=#d.taxon_name_id#
				</cfquery>
				<br>update identification_taxonomy set taxon_name_id=#rid.taxon_name_id# where taxon_name_id=#d.taxon_name_id#
			</cfif>
		</cfloop>
	</cfif>
	---->
</cfoutput>
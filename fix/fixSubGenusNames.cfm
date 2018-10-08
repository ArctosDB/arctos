<cfoutput>
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
				<br>update identification_taxonomy set taxon_name_id=#rid.taxon_name_id# where taxon_name_id=#d.taxon_name_id#
			</cfif>
		</cfloop>
	</cfif>
	<cfif action is "createMissingSubgenera">
		<cfquery name="d" datasource="uam_god">
			select * from taxon_name where scientific_name like '%(%'
		</cfquery>
		<cfloop query="d">
			<br>#scientific_name#
			<cfset startpos=find('(',scientific_name)>
			<cfset stoppos=find(')',scientific_name)>
			<cfset theSG=mid(scientific_name,startpos+1,stoppos-startpos-1)>
			<br>theSG: #theSG#
			<!---- exists?? --->
			<cfquery name="ag1" datasource="uam_god">
				select * from taxon_name where scientific_name='#theSG#'
			</cfquery>
			<cfif ag1.recordcount is 1>
				<br>already got one, do nothing
			<cfelse>
				<br>make a name
				<!--- pull in existing classification data when we can --->
				<cfquery name="exc" datasource="uam_god">
					select * from taxon_term where source in ('Arctos','Arctos Plants') and taxon_name_id=#d.taxon_name_id# order by POSITION_IN_CLASSIFICATION
				</cfquery>
				<cfquery name="workable" dbtype="query">
					select distinct classification_id from exc
				</cfquery>

				<cfquery name="tnid" datasource="uam_god">
					select sq_taxon_name_id.nextval tnid from dual
				</cfquery>

				<cfquery name="makethename" datasource="uam_god">
					insert into taxon_name (taxon_name_id,scientific_name) values (#tnid.tnid#,'#theSG#')
				</cfquery>
				<cfif workable.recordcount is not 1>
					<br>is a mess, not going here, just make the name
				<cfelse>
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
					</cfloop>
				</cfif>
			</cfif>
		</cfloop>
	</cfif>
</cfoutput>
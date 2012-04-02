
<cfoutput>
	<!----
create table sikestax as select * from taxonomy where 1=2
---->


<cfquery name="d" datasource="uam_god">
select taxon_name from bulkloader where collection_id in (4,50) and lower(loaded) like '%taxon_name%' and 
loaded != 'OLD_RECORD: SEE ENTEREDTOBULKDATE' 
group by taxon_name
</cfquery>
<cfloop query="d">
	
	<cfif taxon_name does not contain " " or (listlen(taxon_name,' ') is 2 and listgetat(taxon_name,2," ") is "sp.")>
		<cfif listlen(taxon_name,' ') is 2>
			<cfset thisTerm=listgetat(taxon_name,1," ")>
		<cfelse>
			<cfset thisTerm=taxon_name>
		</cfif>
		
		<cfquery name="bt" datasource="uam_god">
			select * from sikestax where thisname='#thisTerm#'	
		</cfquery>
		<cfif bt.recordcount is 0>
			<br>#taxon_name#
	<br>===#thisTerm#
		
			<cfquery name="f" datasource="uam_god">
				select
					KINGDOM,
					NOMENCLATURAL_CODE,
					PHYLCLASS,
					PHYLORDER,
					PHYLUM,
					SOURCE_AUTHORITY,
					SUBCLASS,
					SUPERFAMILY,
					TAXON_STATUS,
					VALID_CATALOG_TERM_FG
				from taxonomy where PHYLORDER='#thisTerm#'
				group by
					KINGDOM,
					NOMENCLATURAL_CODE,
					PHYLCLASS,
					PHYLORDER,
					PHYLUM,
					SOURCE_AUTHORITY,
					SUBCLASS,
					SUPERFAMILY,
					TAXON_STATUS,
					VALID_CATALOG_TERM_FG
			</cfquery>
			<cfloop query="f">
				<br>got #f.recordcount# - saving....
				<cfquery name="gotone" datasource="uam_god">
					insert into sikestax (
						KINGDOM,
						NOMENCLATURAL_CODE,
						PHYLCLASS,
						PHYLORDER,
						PHYLUM,
						SOURCE_AUTHORITY,
						SUBCLASS,
						SUPERFAMILY,
						TAXON_STATUS,
						VALID_CATALOG_TERM_FG,
						status,
						THISNAME,
						taxon_name
					) values (
						'#KINGDOM#',
						'#NOMENCLATURAL_CODE#',
						'#PHYLCLASS#',
						'#PHYLORDER#',
						'#PHYLUM#',
						'#SOURCE_AUTHORITY#',
						'#SUBCLASS#',
						'#SUPERFAMILY#',
						'#TAXON_STATUS#',
						#VALID_CATALOG_TERM_FG#,
						'#f.recordcount# PHYLORDER match',
						'#thisTerm#',
						'#d.taxon_name#'
					)
				</cfquery>
			</cfloop>
			
			
			<!----
			
			<cfquery name="f" datasource="uam_god">
				select
					KINGDOM,
					NOMENCLATURAL_CODE,
					PHYLCLASS,
					PHYLORDER,
					PHYLUM,
					SOURCE_AUTHORITY,
					SUBCLASS,
					SUBORDER,
					SUPERFAMILY,
					TAXON_STATUS,
					VALID_CATALOG_TERM_FG
				from taxonomy where SUBORDER='#thisTerm#'
				group by
					KINGDOM,
					NOMENCLATURAL_CODE,
					PHYLCLASS,
					PHYLORDER,
					PHYLUM,
					SOURCE_AUTHORITY,
					SUBCLASS,
					SUBORDER,
					SUPERFAMILY,
					TAXON_STATUS,
					VALID_CATALOG_TERM_FG
			</cfquery>
			<cfloop query="f">
				<br>got #f.recordcount# - saving....
				<cfquery name="gotone" datasource="uam_god">
					insert into sikestax (
						KINGDOM,
						NOMENCLATURAL_CODE,
						PHYLCLASS,
						PHYLORDER,
						PHYLUM,
						SOURCE_AUTHORITY,
						SUBCLASS,
						SUBORDER,
						SUPERFAMILY,
						TAXON_STATUS,
						VALID_CATALOG_TERM_FG,
						status,
						THISNAME,
						taxon_name
					) values (
						'#KINGDOM#',
						'#NOMENCLATURAL_CODE#',
						'#PHYLCLASS#',
						'#PHYLORDER#',
						'#PHYLUM#',
						'#SOURCE_AUTHORITY#',
						'#SUBCLASS#',
						'#SUBORDER#',
						'#SUPERFAMILY#',
						'#TAXON_STATUS#',
						#VALID_CATALOG_TERM_FG#,
						'#f.recordcount# SUBORDER match',
						'#thisTerm#',
						'#d.taxon_name#'
					)
				</cfquery>
			</cfloop>
			
			
			
			<cfquery name="f" datasource="uam_god">
				select
					KINGDOM,
					NOMENCLATURAL_CODE,
					PHYLCLASS,
					PHYLORDER,
					PHYLUM,
					SOURCE_AUTHORITY,
					SUBCLASS,
					SUBORDER,
					SUPERFAMILY,
					TAXON_STATUS,
					VALID_CATALOG_TERM_FG
				from taxonomy where PHYLCLASS='#thisTerm#'
				group by
					KINGDOM,
					NOMENCLATURAL_CODE,
					PHYLCLASS,
					PHYLORDER,
					PHYLUM,
					SOURCE_AUTHORITY,
					SUBCLASS,
					SUBORDER,
					SUPERFAMILY,
					TAXON_STATUS,
					VALID_CATALOG_TERM_FG
			</cfquery>
			<cfloop query="f">
				<br>got #f.recordcount# - saving....
				<cfquery name="gotone" datasource="uam_god">
					insert into sikestax (
						KINGDOM,
						NOMENCLATURAL_CODE,
						PHYLCLASS,
						PHYLORDER,
						PHYLUM,
						SOURCE_AUTHORITY,
						SUBCLASS,
						SUBORDER,
						SUPERFAMILY,
						TAXON_STATUS,
						VALID_CATALOG_TERM_FG,
						status,
						THISNAME,
						taxon_name
					) values (
						'#KINGDOM#',
						'#NOMENCLATURAL_CODE#',
						'#PHYLCLASS#',
						'#PHYLORDER#',
						'#PHYLUM#',
						'#SOURCE_AUTHORITY#',
						'#SUBCLASS#',
						'#SUBORDER#',
						'#SUPERFAMILY#',
						'#TAXON_STATUS#',
						#VALID_CATALOG_TERM_FG#,
						'#f.recordcount# PHYLCLASS match',
						'#thisTerm#',
						'#d.taxon_name#'
					)
				</cfquery>
			</cfloop>
				<cfquery name="f" datasource="uam_god">
				select
					FAMILY,
					KINGDOM,
					NOMENCLATURAL_CODE,
					PHYLCLASS,
					PHYLORDER,
					PHYLUM,
					SOURCE_AUTHORITY,
					SUBCLASS,
					SUBORDER,
					SUPERFAMILY,
					TAXON_STATUS,
					VALID_CATALOG_TERM_FG
				from taxonomy where FAMILY='#thisTerm#'
				group by
					FAMILY,
					KINGDOM,
					NOMENCLATURAL_CODE,
					PHYLCLASS,
					PHYLORDER,
					PHYLUM,
					SOURCE_AUTHORITY,
					SUBCLASS,
					SUBORDER,
					SUPERFAMILY,
					TAXON_STATUS,
					VALID_CATALOG_TERM_FG
			</cfquery>
			<cfloop query="f">
				<br>got #f.recordcount# - saving....
				<cfquery name="gotone" datasource="uam_god">
					insert into sikestax (
						FAMILY,
						KINGDOM,
						NOMENCLATURAL_CODE,
						PHYLCLASS,
						PHYLORDER,
						PHYLUM,
						SOURCE_AUTHORITY,
						SUBCLASS,
						SUBORDER,
						SUPERFAMILY,
						TAXON_STATUS,
						VALID_CATALOG_TERM_FG,
						status,
						THISNAME,
						taxon_name
					) values (
						'#FAMILY#',
						'#KINGDOM#',
						'#NOMENCLATURAL_CODE#',
						'#PHYLCLASS#',
						'#PHYLORDER#',
						'#PHYLUM#',
						'#SOURCE_AUTHORITY#',
						'#SUBCLASS#',
						'#SUBORDER#',
						'#SUPERFAMILY#',
						'#TAXON_STATUS#',
						#VALID_CATALOG_TERM_FG#,
						'#f.recordcount# FAMILY match',
						'#thisTerm#',
						'#d.taxon_name#'
					)
				</cfquery>
			</cfloop>
			
			
			
			
			<cfquery name="f" datasource="uam_god">
				select
					FAMILY,
					KINGDOM,
					NOMENCLATURAL_CODE,
					PHYLCLASS,
					PHYLORDER,
					PHYLUM,
					SOURCE_AUTHORITY,
					SUBCLASS,
					SUBFAMILY,
					SUBORDER,
					SUPERFAMILY,
					TAXON_STATUS,
					VALID_CATALOG_TERM_FG
				from taxonomy where SUBFAMILY='#thisTerm#'
				group by
					FAMILY,
					KINGDOM,
					NOMENCLATURAL_CODE,
					PHYLCLASS,
					PHYLORDER,
					PHYLUM,
					SOURCE_AUTHORITY,
					SUBCLASS,
					SUBFAMILY,
					SUBORDER,
					SUPERFAMILY,
					TAXON_STATUS,
					VALID_CATALOG_TERM_FG
			</cfquery>
			<cfloop query="f">
				<br>got #f.recordcount# - saving....
				<cfquery name="gotone" datasource="uam_god">
					insert into sikestax (
						FAMILY,
						KINGDOM,
						NOMENCLATURAL_CODE,
						PHYLCLASS,
						PHYLORDER,
						PHYLUM,
						SOURCE_AUTHORITY,
						SUBCLASS,
						SUBFAMILY,
						SUBORDER,
						SUPERFAMILY,
						TAXON_STATUS,
						VALID_CATALOG_TERM_FG,
						status,
						THISNAME,
						taxon_name
					) values (
						'#FAMILY#',
						'#KINGDOM#',
						'#NOMENCLATURAL_CODE#',
						'#PHYLCLASS#',
						'#PHYLORDER#',
						'#PHYLUM#',
						'#SOURCE_AUTHORITY#',
						'#SUBCLASS#',
						'#SUBFAMILY#',
						'#SUBORDER#',
						'#SUPERFAMILY#',
						'#TAXON_STATUS#',
						#VALID_CATALOG_TERM_FG#,
						'#f.recordcount# SUBFAMILY match',
						'#thisTerm#',
						'#d.taxon_name#'
					)
				</cfquery>
			</cfloop>
			
			
			
			<cfquery name="f" datasource="uam_god">
				select
					FAMILY,
					KINGDOM,
					NOMENCLATURAL_CODE,
					PHYLCLASS,
					PHYLORDER,
					PHYLUM,
					SOURCE_AUTHORITY,
					SUBCLASS,
					SUBFAMILY,
					SUBORDER,
					SUPERFAMILY,
					TAXON_STATUS,
					TRIBE,
					VALID_CATALOG_TERM_FG
				from taxonomy where TRIBE='#thisTerm#'
				group by
					FAMILY,
					KINGDOM,
					NOMENCLATURAL_CODE,
					PHYLCLASS,
					PHYLORDER,
					PHYLUM,
					SOURCE_AUTHORITY,
					SUBCLASS,
					SUBFAMILY,
					SUBORDER,
					SUPERFAMILY,
					TAXON_STATUS,
					TRIBE,
					VALID_CATALOG_TERM_FG
			</cfquery>
			<cfloop query="f">
				<br>got #f.recordcount# - saving....
				<cfquery name="gotone" datasource="uam_god">
					insert into sikestax (
						FAMILY,
						KINGDOM,
						NOMENCLATURAL_CODE,
						PHYLCLASS,
						PHYLORDER,
						PHYLUM,
						SOURCE_AUTHORITY,
						SUBCLASS,
						SUBFAMILY,
						SUBORDER,
						SUPERFAMILY,
						TAXON_STATUS,
						TRIBE,
						VALID_CATALOG_TERM_FG,
						status,
						THISNAME,
						taxon_name
					) values (
						'#FAMILY#',
						'#KINGDOM#',
						'#NOMENCLATURAL_CODE#',
						'#PHYLCLASS#',
						'#PHYLORDER#',
						'#PHYLUM#',
						'#SOURCE_AUTHORITY#',
						'#SUBCLASS#',
						'#SUBFAMILY#',
						'#SUBORDER#',
						'#SUPERFAMILY#',
						'#TAXON_STATUS#',
						'#TRIBE#',
						#VALID_CATALOG_TERM_FG#,
						'#f.recordcount# TRIBE match',
						'#thisTerm#',
						'#d.taxon_name#'
					)
				</cfquery>
			</cfloop>
			
			
			
			
			<cfquery name="f" datasource="uam_god">
				select
					FAMILY,
					KINGDOM,
					NOMENCLATURAL_CODE,
					PHYLCLASS,
					PHYLORDER,
					PHYLUM,
					SOURCE_AUTHORITY,
					SUBCLASS,
					SUBFAMILY,
					SUBORDER,
					SUPERFAMILY,
					TAXON_STATUS,
					TRIBE,
					VALID_CATALOG_TERM_FG,
					genus
				from taxonomy where genus='#thisTerm#'
				group by
					FAMILY,
					KINGDOM,
					NOMENCLATURAL_CODE,
					PHYLCLASS,
					PHYLORDER,
					PHYLUM,
					SOURCE_AUTHORITY,
					SUBCLASS,
					SUBFAMILY,
					SUBORDER,
					SUPERFAMILY,
					TAXON_STATUS,
					TRIBE,
					VALID_CATALOG_TERM_FG,
					genus
			</cfquery>
			<cfloop query="f">
				<br>got #f.recordcount# - saving....
				<cfquery name="gotone" datasource="uam_god">
					insert into sikestax (
						FAMILY,
						KINGDOM,
						NOMENCLATURAL_CODE,
						PHYLCLASS,
						PHYLORDER,
						PHYLUM,
						SOURCE_AUTHORITY,
						SUBCLASS,
						SUBFAMILY,
						SUBORDER,
						SUPERFAMILY,
						TAXON_STATUS,
						TRIBE,
						VALID_CATALOG_TERM_FG,
						status,
						THISNAME,
						genus,
						taxon_name
					) values (
						'#FAMILY#',
						'#KINGDOM#',
						'#NOMENCLATURAL_CODE#',
						'#PHYLCLASS#',
						'#PHYLORDER#',
						'#PHYLUM#',
						'#SOURCE_AUTHORITY#',
						'#SUBCLASS#',
						'#SUBFAMILY#',
						'#SUBORDER#',
						'#SUPERFAMILY#',
						'#TAXON_STATUS#',
						'#TRIBE#',
						#VALID_CATALOG_TERM_FG#,
						'#f.recordcount# GENUS match',
						'#thisTerm#',
						'#genus#',
						'#d.taxon_name#'
					)
				</cfquery>
			</cfloop>
			----->
		</cfif>
	</cfif>
</cfloop>

</cfoutput>
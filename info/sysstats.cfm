<cfinclude template="/includes/_header.cfm">
<cfoutput>
	<cfquery name="d" datasource="uam_god">
		select collection, institution_acronym, replace(institution_acronym,'Obs') relinst from collection order by collection
	</cfquery>
	<cfquery name="i" dbtype="query">
		select institution_acronym from d group by institution_acronym
	</cfquery>
	<cfquery name="ri" dbtype="query">
		select relinst from d group by relinst
	</cfquery>
	<cfquery name="cataloged_item" datasource="uam_god">
		select count(*) c from cataloged_item
	</cfquery>
		<cfquery name="taxonomy" datasource="uam_god">
			select count(*) c from taxonomy
		</cfquery>
		<cfquery name="locality" datasource="uam_god">
			select count(*) c from locality
		</cfquery>

		<cfquery name="media" datasource="uam_god">
					select count(*) c from media
				</cfquery>
			<cfquery name="collecting_event" datasource="uam_god">
						select count(*) c from collecting_event
					</cfquery>
				<cfquery name="agent" datasource="uam_god">
										select count(*) c from agent
									</cfquery>

					<cfquery name="all_objects" datasource="uam_god">
															select * from all_objects
														</cfquery>
<cfdump var=#all_objects#>
	<table border>
		<tr>
			<th>Metric</th>
			<th>Value</th>
		</tr>
		<tr>
			<td>Number Collections</td>
			<td><input value="#d.recordcount#"></td>
		</tr>
		<tr>
			<td>Number Institutions (raw)</td>
			<td><input value="#i.recordcount#"></td>
		</tr>

		<tr>
			<td>Number Institutions ("Obs" removed)</td>
			<td><input value="#ri.recordcount#"></td>
		</tr>
		<tr>
			<td>Number Specimens</td>
			<td><input value="#cataloged_item.c#"></td>
		</tr>
			<tr>
				<td>Number Taxon Names</td>
				<td><input value="#taxonomy.c#"></td>
			</tr>

			<tr>
				<td>Number Localities</td>
				<td><input value="#locality.c#"></td>
			</tr>
				<tr>
					<td>Number Collecting Events</td>
					<td><input value="#collecting_event.c#"></td>
				</tr>
			<tr>
				<td>Number Media</td>
				<td><input value="#media.c#"></td>
			</tr>
					<tr>
						<td>Number Agents</td>
						<td><input value="#agent.c#"></td>
					</tr>
	</table>
</cfoutput>
Arctos Basics http://arctosdb.org/ Arctos is a dynamic collection management information system that is continually evolving and growing.
Growth depends on activities of individual collections plus new collections that migrate into Arctos. As of 5 Feb 2013,
Arctos is comprised of: 18 Institutions 54 Collections 1.7M specimen/observation records (21 GB)

528,802 Media objects in Arctos linked to cataloged items
782,000 media files at TACC consuming about 6.6TB (plus some additional uningested files, so probably more like 7.4TB.
2426608 Taxonomic names 568135 Localities 838683 Collecting Events 40404 Agents Arctos as a whole has 512 persistent tables 85 are for specimen-related data including data on cataloged items, localities, collecting events, agents, attributes, transactions (loans, accessions, permits), projects, publications, other identifiers, relationships, taxonomy & identification, related media, etc. other tables hold data on code tables, user info, VPD settings, user settings and customizations, temp CF bulkloading tables, CF admin stuff, cached data (collection-type-specific code tables), archives of deletes from various places, snapshots of system objects (eg, audit), and probably some other stuff.
<cfinclude template="/includes/_footer.cfm">

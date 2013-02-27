<cfinclude template="/includes/_header.cfm">
<cfset title="system statistics">
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
	<cfquery name="publication" datasource="uam_god">
		select count(*) c from publication
	</cfquery>

	<cfquery name="project" datasource="uam_god">
		select count(*) c from project
	</cfquery>
	<cfquery name="user_tables" datasource="uam_god">
		select TABLE_NAME from user_tables
	</cfquery>
	<cfquery name="ct" dbtype="query">
		select TABLE_NAME from user_tables where table_name like 'CT%'
	</cfquery>
	<table border>
		<tr><th>
				Metric
			</th>
			<th>
				Value
			</th></tr>
		<tr>
			<td>
				Number Collections
				<a href="##collections" class="infoLink">list</a>
			</td>
			<td><input value="#d.recordcount#"></td>
		</tr>
		<tr>
			<td>Number Institutions (raw)<a href="##rawinst" class="infoLink">list</a></td>
			<td><input value="#i.recordcount#"></td>
		</tr>
		<tr>
			<td>Number Institutions ("Obs" removed)
		<a href="##inst" class="infoLink">list</a>
		</td>
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
		<tr>
			<td>Number Publications</td>
			<td><input value="#publication.c#"></td>
		</tr>
		<tr>
			<td>Number Projects</td>
			<td><input value="#project.c#"></td>
		</tr>
		<tr>
			<td>Number Tables *</td>
			<td><input value="#user_tables.recordcount#"></td>
		</tr>
		<tr>
			<td>Number Code Tables *</td>
			<td><input value="#ct.recordcount#"></td>
		</tr>
	</table>
	* The numbers above represent tables owned by the system owner.
	There are about 85 "data tables" which contain primary specimen data. They're pretty useless by themselves - the other several hundred tables are user info,
	 VPD settings, user settings and customizations, temp CF bulkloading tables, CF admin stuff, cached data (collection-type-specific code tables),
	 archives of deletes from various places, snapshots of system objects (eg, audit), and the other stuff that together makes Arctos work. Additionally,
	 there are approximately 100,000 triggers, views, procedures, system tables, etc. - think of them as the duct tape that holds Arctos together.
	 Arctos is a deeply-integrated system which heavily uses Oracle functionality; it is not a couple tables loosely held together by some
	 middleware, a stark contrast to any other system with which we are familiar.
	<p>
		Arctos access data are available from Google Analytics - ask any member of the Advisory Committee for access. http://www.google.com/analytics/
	</p>
	<p>Query and Download stats are available under the Reports tab.</p>
	<a name="growth"></a>

	<hr>
	<cfset fileDir = "#Application.webDirectory#">
	<cfset variables.encoding="UTF-8">
	<cfset fname = "arctos_by_year.csv">
	<cfset variables.fileName="#Application.webDirectory#/download/#fname#">
	Specimens and collection by year
	<a href="/download/#fname#">CSV</a>
	<table border>
		<tr>
			<th>Year</th>
			<th>Number Collections</th>
			<th>Number Specimens</th>
		</tr>
	<cfscript>
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
		variables.joFileWriter.writeLine("year,NumberCollections,NumberSpecimens");
	</cfscript>
	<cfquery name="qy" datasource="uam_god">
			select
			to_number(to_char(COLL_OBJECT_ENTERED_DATE,'YYYY')) yy,
			count(*) numberSpecimens,
			count(distinct(collection_id)) numberCollections
		from
			cataloged_item,
			coll_object
		where cataloged_item.collection_object_id=coll_object.collection_object_id and
	 		to_number(to_char(COLL_OBJECT_ENTERED_DATE,'YYYY')) between 1995 and #dateformat(now(),"YYYY")#
	 	order by
			to_number(to_char(COLL_OBJECT_ENTERED_DATE,'YYYY'))
	</cfquery>
	<cfloop query="qy">
		<tr>
			<td>#y#</td>
			<td>#qy.numberCollections#</td>
			<td>#qy.numberSpecimens#</td>
		</tr>
		<cfscript>
			variables.joFileWriter.writeLine('"#y#","#qy.numberCollections#","#qy.numberSpecimens#"');
		</cfscript>
	</cfloop>
	</table>
	<cfscript>
		variables.joFileWriter.close();
	</cfscript>


	<hr>
	<a name="collections"></a>
	<p>List of collections in Arctos:</p>
	<ul>
		<cfloop query="d">
			<li>#collection#</li>
		</cfloop>
	</ul>
	<hr>
	<a name="rawinst"></a>
	<p>Unmanipulated list of institutions in Arctos:</p>
	<ul>
		<cfloop query="i">
			<li>#institution_acronym#</li>
		</cfloop>
	</ul>

	<hr>
	<a name="inst"></a>
	<p>List of institutions in Arctos (OBS replaced):</p>
	<ul>
		<cfloop query="ri">
			<li>#relinst#</li>
		</cfloop>
	</ul>

</cfoutput>
<cfinclude template="/includes/_footer.cfm">

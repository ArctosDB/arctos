<cfinclude template="/includes/_header.cfm">
<cfset title="system statistics">
<cfoutput>
	<cfquery name="d" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select * from collection order by guid_prefix
	</cfquery>
	<br>this form caches for one hour
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
		<cfquery name="inst" dbtype="query">
			select institution from d group by institution order by institution
		</cfquery>
		<tr>
			<td>Number Institutions<a href="##rawinst" class="infoLink">list</a></td>
			<td><input value="#inst.recordcount#"></td>
		</tr>

		<cfquery name="cataloged_item" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select count(*) c from cataloged_item
		</cfquery>
		<tr>
			<td>Total Number Specimens</td>
			<td><input value="#cataloged_item.c#"></td>
		</tr>


		<cfquery name="citype" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select
				CATALOGED_ITEM_TYPE,
				count(*) c
			from
				cataloged_item
			group by
				CATALOGED_ITEM_TYPE
		</cfquery>
		<tr>
			<td>Number Specimens by cataloged_item_type</td>
			<td>
				<cfloop query="citype">
					#CATALOGED_ITEM_TYPE#: <input value="#c#"><br>
				</cfloop>
			</td>
		</tr>

		<cfquery name="taxonomy" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select count(*) c from taxon_name
		</cfquery>
		<tr>
			<td>Number Taxon Names</td>
			<td><input value="#taxonomy.c#"></td>
		</tr>
		<cfquery name="locality" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select count(*) c from locality
		</cfquery>
		<tr>
			<td>Number Localities</td>
			<td><input value="#locality.c#"></td>
		</tr>

		<cfquery name="collecting_event" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select count(*) c from collecting_event
		</cfquery>
		<tr>
			<td>Number Collecting Events</td>
			<td><input value="#collecting_event.c#"></td>
		</tr>

		<cfquery name="media" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select count(*) c from media
		</cfquery>
		<tr>
			<td>Number Media</td>
			<td><input value="#media.c#"></td>
		</tr>
		<cfquery name="agent" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select count(*) c from agent
		</cfquery>
		<tr>
			<td>Number Agents</td>
			<td><input value="#agent.c#"></td>
		</tr>
		<cfquery name="publication" datasource="uam_god"  cachedwithin="#createtimespan(0,0,60,0)#">
			select count(*) c from publication
		</cfquery>
		<tr>
			<td>Number Publications (<a href="/info/MoreCitationStats.cfm">more detail</a>)</td>
			<td><input value="#publication.c#"></td>
		</tr>
		<cfquery name="project" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select count(*) c from project
		</cfquery>
		<tr>
			<td>Number Projects (<a href="/info/MoreCitationStats.cfm">more detail</a>)</td>
			<td><input value="#project.c#"></td>
		</tr>
		<cfquery name="user_tables" datasource="uam_god"  cachedwithin="#createtimespan(0,0,60,0)#">
			select TABLE_NAME from user_tables
		</cfquery>
		<tr>
			<td>Number Tables *</td>
			<td><input value="#user_tables.recordcount#"></td>
		</tr>
		<cfquery name="ct" dbtype="query">
			select TABLE_NAME from user_tables where table_name like 'CT%'
		</cfquery>
		<tr>
			<td>Number Code Tables *</td>
			<td><input value="#ct.recordcount#"></td>
		</tr>
		<cfquery name="gb"  datasource="uam_god"  cachedwithin="#createtimespan(0,0,60,0)#">
			select count(*) c from coll_obj_other_id_num where OTHER_ID_TYPE = 'GenBank'
		</cfquery>
		<tr>
			<td>Number GenBank Linkouts</td>
			<td><input value="#gb.c#"></td>
		</tr>
		<cfquery name="reln"  datasource="uam_god"  cachedwithin="#createtimespan(0,0,60,0)#">
			select count(*) c from coll_obj_other_id_num where ID_REFERENCES != 'self'
		</cfquery>
		<tr>
			<td>Number Inter-Specimen Relationships</td>
			<td><input value="#reln.c#"></td>
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
	<cfloop from="1995" to="#dateformat(now(),"YYYY")#" index="y">
		<cfquery name="qy" datasource="uam_god">
 			select
				count(*) numberSpecimens,
				count(distinct(collection_id)) numberCollections
			from
				cataloged_item,
				coll_object
			where cataloged_item.collection_object_id=coll_object.collection_object_id and
		 		to_number(to_char(COLL_OBJECT_ENTERED_DATE,'YYYY')) between 1995 and #y#
		</cfquery>
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
			<li>#guid_prefix#: #institution# #collection#</li>
		</cfloop>
	</ul>
	<hr>
	<a name="rawinst"></a>
	<p>List of institutions in Arctos:</p>
	<ul>
		<cfloop query="inst">
			<li>#institution#</li>
		</cfloop>
	</ul>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">

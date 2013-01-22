<cfinclude template="/includes/_header.cfm">
<cfoutput>
	<cfquery name="d" datasource="uam_god">
		select
			collection.collection_id,
			collection.collection,
			collection.descr,
			collection.citation,
			collection.web_link,
			display,
			uri
		from
			collection,
			ctmedia_license
		where
			collection.USE_LICENSE_ID=ctmedia_license.media_license_id (+)
			and collection_id=29
	</cfquery>
<cfloop query="d">
	<br>collection: #collection#
	<br>descr: #descr#
	<br>citation: #citation#
	<br>web_link: #web_link#
	<br>display: #display#
	<br>uri: #uri#
	<cfquery name="gc" datasource="uam_god">
		select continent_ocean from flat where collection_id=#collection_id# group by continent_ocean
	</cfquery>
	<br>Geographic  Coverage: #valuelist(gc.continent_ocean)#
	<cfquery name="tc" datasource="uam_god">
		select phylclass from flat where collection_id=#collection_id# group by phylclass
	</cfquery>
	<br>taxonomic  Coverage: #valuelist(tc.phylclass)#

	<cfquery name="tec" datasource="uam_god">
		select min(began_date) earliest, max(ended_date) latest from flat where collection_id=#collection_id#
	</cfquery>
	<br>temporal  Coverage: #tec.earliest# to #tec.latest#
	<cfquery name="contacts" datasource="uam_god">
		select
			first_name,
			last_name,
			CONTACT_AGENT_ID
		from
			collection_contacts
		where
			collection_id=#collection_id#
	</cfquery>

	<cfloop query="contacts">
		<br>first_name: #first_name#
		<br>last_name: #last_name#
		<cfquery name="addr" datasource="uam_god">
			select * from addr where agent_id=#CONTACT_AGENT_ID#
		</cfquery>
		<cfloop query-"addr">
			<br>ADDR_TYPE: #ADDR_TYPE#
			<br>VALID_ADDR_FG: #VALID_ADDR_FG#
			<br>JOB_TITLE: #JOB_TITLE#
			<br>STREET_ADDR1: #STREET_ADDR1#
			<br>STREET_ADDR2: #STREET_ADDR2#
			<br>CITY: #CITY#
			<br>STATE: #STATE#
			<br>ZIP: #ZIP#
			<br>COUNTRY_CDE: #COUNTRY_CDE#
			<br>MAIL_STOP: #MAIL_STOP#
			<br>INSTITUTION: #INSTITUTION#
			<br>DEPARTMENT: #DEPARTMENT#
		</cfloop>
		<cfquery name="addr" datasource="uam_god">
			select * from electronic_address where agent_id=#CONTACT_AGENT_ID#
		</cfquery>
		<cfloop query-"addr">
			<br>ADDRESS_TYPE: #ADDRESS_TYPE#
			<br>ADDRESS: #ADDRESS#
		</cfloop>

	</cfloop>

	</cfquery>

	<br>
</cfloop>
<cfabort>
	</cfoutput>


	    Resource Contact*


	all from collection contacts - we may need some new roles, and new types of agent address etc. (I suspect some Curators aren't going to want all of their contact information published)

	http://arctos.database.museum/info/ctDocumentation.cfm?table=CTCOLL_CONTACT_ROLE
	http://arctos.database.museum/info/ctDocumentation.cfm?table=CTADDR_TYPE
	http://arctos.database.museum/info/ctDocumentation.cfm?table=CTELECTRONIC_ADDR_TYPE

	This may affect http://code.google.com/p/arctos/issues/detail?id=499 - I added a comment to the Issue.



	    -- First Name  ===> Parsed from Agents/Preferred Name


	 person.first_name


	    -- Last Name ===> Parsed from Agents/Preferred Name


	person.last_name



	or agent's electronic_address?


	    Resource Creator* - can be same as Resource Contact (or could be Laura or John who create the resource?)


	or just another collection_contact_role


	    Metadata Provider*  - can be same as Resource Contact


	or just another collection_contact_role





	    Associated Parties - by default, we would add Laura Russell, Dave Bloom, and John Wieczorek; we could also add other resource contacts (e.g., curatorial staff in addition to main resource contact)


	more collection_contact_roles - we shouldn't need a programmer to change this when one of those folks gets a new email address or something.




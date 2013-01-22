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
		<cfloop query="addr">
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
		<cfquery name="eaddr" datasource="uam_god">
			select * from electronic_address where agent_id=#CONTACT_AGENT_ID#
		</cfquery>
		<cfloop query="eaddr">
			<br>ADDRESS_TYPE: #ADDRESS_TYPE#
			<br>ADDRESS: #ADDRESS#
		</cfloop>

	</cfloop>

</cfloop>
	</cfoutput>

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
			order by collection
	</cfquery>
	<cfloop query="d">
	<hr>
		<label for="">collection</label>
		<input type="text" size="80" value="#collection#">
		<blockquote>
			<label for="">descr</label>
			<textarea rows="6" cols="80">descr</textarea>
			<label for="">citation</label>
			<input type="text" size="80" value="#citation#">
			<label for="">web_link</label>
			<input type="text" size="80" value="#web_link#">
			<label for="">license</label>
			<input type="text" size="80" value="#display#">
			<label for="">license_uri</label>
			<input type="text" size="80" value="#uri#">
		</blockquote>
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
				CONTACT_ROLE,
				CONTACT_AGENT_ID
			from
				collection_contacts,
				person
			where
			CONTACT_AGENT_ID=person_id and
			collection_id=#collection_id#
		</cfquery>
	<br>-----------------------contacts--------------------
		<cfloop query="contacts">
		<br>--------person--------------------
			<br>first_name: #first_name#
			<br>last_name: #last_name#
			<br>CONTACT_ROLE: #CONTACT_ROLE#
			<cfquery name="addr" datasource="uam_god">
				select * from addr where agent_id=#CONTACT_AGENT_ID#
			</cfquery>
			<br>------------addresses--------------------
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
			<br>------------------------electronic addresses-------------------------
			<cfloop query="eaddr">
				<br>-----------------------electronic address-------------------
				<br>ADDRESS_TYPE: #ADDRESS_TYPE#
				<br>ADDRESS: #ADDRESS#
			</cfloop>
		</cfloop>
	</cfloop>
</cfoutput>

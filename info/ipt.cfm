<cfinclude template="/includes/_header.cfm">
<style>
	.redborder {border:2px solid red;}
	.greenborder {border:2px solid green; padding-left:2em;}
	.blueborder {border:2px solid blue; padding-left:4em;}
	.yellowborder {border:2px solid yellow; padding-left:4em;}


</style>
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
		<div class="redborder">
			<label for="">descr</label>
			<textarea rows="6" cols="80">#descr#</textarea>
			<label for="">citation</label>
			<input type="text" size="80" value="#citation#">
			<label for="">web_link</label>
			<input type="text" size="80" value="#web_link#">
			<label for="">license</label>
			<input type="text" size="80" value="#display#">
			<label for="">license_uri</label>
			<input type="text" size="80" value="#uri#">
			<cfquery name="gc" datasource="uam_god">
				select continent_ocean from flat where collection_id=#collection_id# group by continent_ocean
			</cfquery>
			<label for="">Geographic  Coverage</label>
			<input type="text" size="80" value="#valuelist(gc.continent_ocean)#">
			<cfquery name="tc" datasource="uam_god">
				select phylclass from flat where collection_id=#collection_id# group by phylclass
			</cfquery>
			<label for="">Taxonomic  Coverage</label>
			<input type="text" size="80" value="#valuelist(tc.phylclass)#">
			<cfquery name="tec" datasource="uam_god">
				select min(began_date) earliest, max(ended_date) latest from flat where collection_id=#collection_id#
			</cfquery>
			<label for="">Temporal Coverage - earliest</label>
			<input type="text" size="80" value="#tec.earliest#">
			<label for="">Temporal Coverage - latest</label>
			<input type="text" size="80" value="#tec.latest#">
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
			<div class="greenborder">
				<cfloop query="contacts">
					<label for="">CONTACT_ROLE</label>
					<input type="text" size="80" value="#CONTACT_ROLE#">
					<label for="">first_name</label>
					<input type="text" size="80" value="#first_name#">
					<label for="">last_name</label>
					<input type="text" size="80" value="#last_name#">
					<cfquery name="addr" datasource="uam_god">
						select * from addr where agent_id=#CONTACT_AGENT_ID#
					</cfquery>
					<div class="blueborder">
						<cfloop query="addr">
							<label for="">ADDR_TYPE</label>
							<input type="text" size="80" value="#ADDR_TYPE#">
							<label for="">VALID_ADDR_FG</label>
							<input type="text" size="80" value="#VALID_ADDR_FG#">
							<label for="">JOB_TITLE</label>
							<input type="text" size="80" value="#JOB_TITLE#">
							<label for="">STREET_ADDR1</label>
							<input type="text" size="80" value="#STREET_ADDR1#">
							<label for="">STREET_ADDR2</label>
							<input type="text" size="80" value="#STREET_ADDR2#">
							<label for="">CITY</label>
							<input type="text" size="80" value="#CITY#">
							<label for="">STATE</label>
							<input type="text" size="80" value="#STATE#">
							<label for="">ZIP</label>
							<input type="text" size="80" value="#ZIP#">
							<label for="">COUNTRY_CDE</label>
							<input type="text" size="80" value="#COUNTRY_CDE#">
							<label for="">MAIL_STOP</label>
							<input type="text" size="80" value="#MAIL_STOP#">
							<label for="">INSTITUTION</label>
							<input type="text" size="80" value="#INSTITUTION#">
							<label for="">DEPARTMENT</label>
							<input type="text" size="80" value="#DEPARTMENT#">
						</cfloop>
					</div>
					<cfquery name="eaddr" datasource="uam_god">
						select * from electronic_address where agent_id=#CONTACT_AGENT_ID#
					</cfquery>
					<div class="yellowborder">
						<cfloop query="eaddr">
							<label for="">ADDRESS_TYPE</label>
							<input type="text" size="80" value="#ADDRESS_TYPE#">
							<label for="">ADDRESS</label>
							<input type="text" size="80" value="#ADDRESS#">
						</cfloop>
					</div>
				</cfloop>
			</div>
		</div>
	</cfloop>
</cfoutput>

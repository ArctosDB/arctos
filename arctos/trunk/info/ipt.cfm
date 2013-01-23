<cfinclude template="/includes/_header.cfm">
<style>
	.redborder {border:2px solid red; margin:1em;display: inline-block;}
	.greenborder {border:2px solid green; padding: 1em 1em 1em 2em; margin:1em; display: inline-block;}
	.blueborder {border:2px solid blue; padding: 1em 1em 1em 2em; margin:1em;display: inline-block;}
	.yellowborder {border:2px solid yellow; padding: 1em 1em 1em 2em; margin:1em;display: inline-block;}


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
		<span class="redborder">

		stuff
		<label for="">collection</label>
					<input type="text" size="80" value="#collection#">
		<!---------

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
				select continent_ocean from flat where continent_ocean is not null and collection_id=#collection_id# group by continent_ocean order by continent_ocean
			</cfquery>
			<label for="">Geographic  Coverage</label>
			<cfset geocov=valuelist(gc.continent_ocean)>
			<cfif listfind(geocov,"no higher geography recorded")>
				<cfset geocov=listdeleteat(geocov,listfind(geocov,"no higher geography recorded"))>
			</cfif>
			<textarea rows="6" cols="80">#geocov#</textarea>
			<cfquery name="tc" datasource="uam_god">
				select phylclass from flat where phylclass is not null and collection_id=#collection_id# group by phylclass order by phylclass
			</cfquery>
			<label for="">Taxonomic  Coverage</label>
			<textarea rows="6" cols="80">#valuelist(tc.phylclass)#</textarea>
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
			<cfloop query="contacts">
				<span class="greenborder">
					<label for="">CONTACT_ROLE</label>
					<input type="text" size="80" value="#CONTACT_ROLE#">
					<label for="">first_name</label>
					<input type="text" size="80" value="#first_name#">
					<label for="">last_name</label>
					<input type="text" size="80" value="#last_name#">
					<cfquery name="addr" datasource="uam_god">
						select * from addr where agent_id=#CONTACT_AGENT_ID#
					</cfquery>
					<cfloop query="addr">
						<span class="blueborder">
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
						</span>
					</cfloop>
					<cfquery name="eaddr" datasource="uam_god">
						select * from electronic_address where agent_id=#CONTACT_AGENT_ID#
					</cfquery>
					<cfloop query="eaddr">
						<span class="yellowborder">
							<label for="">ADDRESS_TYPE</label>
							<input type="text" size="80" value="#ADDRESS_TYPE#">
							<label for="">ADDRESS</label>
							<input type="text" size="80" value="#ADDRESS#">
						</span>
					</cfloop>
				</span>
			</cfloop>

			--------->
		</span>
		<br>
	</cfloop>
</cfoutput>

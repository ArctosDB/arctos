<cfquery name="e" datasource="uam_god">
	select * from eddy
</cfquery>
<cfoutput>
	<cfloop query="e">
		<cfquery name="loc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select higher_geog from 
				geog_auth_rec,
				locality,
				collecting_event,
				cataloged_item
				where
				geog_auth_rec.geog_auth_rec_id = locality.geog_auth_rec_id and
				locality.locality_id = collecting_event.locality_id AND
				collecting_event.collecting_event_id = cataloged_item.collecting_event_id AND
				cataloged_item.collection_id=14 and
				cataloged_item.cat_num=#cat_num#
		</cfquery>
		#cat_num#: #loc.higher_geog#<br>
	</cfloop>
</cfoutput>
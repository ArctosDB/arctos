<cfinclude template="/includes/_header.cfm">
<cfset title="Update Classification Data">

<cfif action is "update">
	<cfoutput>
		<cfquery name="scn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_taxonomy_update set i$status='scientific_name not found' where scientific_name not in (
				select scientific_name from taxon_name
			)
		</cfquery>
		<cfquery name="un" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_taxonomy_update set i$status='username not found' where i$status is null and
			 upper(username) not in (select upper(username) from cf_users)
		</cfquery>
		<cfquery name="snf" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_taxonomy_update set i$status='source not found' where 
			i$status is null and source not in (select source from CTTAXONOMY_SOURCE)
		</cfquery>
		<cfquery name="snf" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_taxonomy_update set i$taxon_name_id=(
				select taxon_name_id from taxon_name where taxon_name.scientific_name=cf_taxonomy_update.scientific_name
			) where i$status is null
		</cfquery>
		
		
		
		
		<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_taxonomy_update where i$status is null
		</cfquery>
		
		
		
		<cfloop query="data">
			
			<cfset classification_id=CreateUUID()>
			
		</cfloop>



	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">


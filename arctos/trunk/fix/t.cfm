<cfoutput>
<cfquery name="killOld" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		insert into CF_TEMP_GEOREF (
			KEY_IDENTIFIER,
			KEY_IDENTIFIER_TYPE,
			INSTITUTION_ACRONYM,
			COLLECTION_CDE)
			values ('a','b','c','d')
	</cfquery>
	
	happy happy worked wheeee!!
	</cfoutput>
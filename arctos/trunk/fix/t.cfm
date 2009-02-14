<cfoutput>
<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		insert into CF_TEMP_GEOREF (
			KEY_IDENTIFIER,
			KEY_IDENTIFIER_TYPE,
			INSTITUTION_ACRONYM,
			COLLECTION_CDE)
			values ('a','b','c','d')
	</cfquery>
	
	happy happy worked wheeee!!
	</cfoutput>
<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select 
		SELECT dbms_metadata.get_ddl('TABLE', 'ATTRIBUTES') FROM DUAL
</cfquery>
<CFDUMP VAR=#D#>


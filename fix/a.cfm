<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		SELECT dbms_metadata.get_ddl('TABLE', 'ATTRIBUTES','UAM') FROM DUAL
</cfquery>
<CFDUMP VAR=#D#>


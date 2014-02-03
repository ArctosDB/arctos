<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		SELECT dbms_metadata.get_ddl('TABLE', 'UAM.ATTRIBUTES') FROM DUAL
</cfquery>
<CFDUMP VAR=#D#>


hi there, I'm an attribute picky thingy

<cfoutput>
	<cfquery name="whatIsIt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select
			VALUE_CODE_TABLE,
			UNITS_CODE_TABLE
		FROM
			ctattribute_code_tables
		where ATTRIBUTE_TYPE='#attribute#'
	</cfquery>
	<cfif #whatIsIt.recordcount# is 0>
		<!--- not code table controlled --->
		No code tables
	<cfelseif #whatIsIt.recordcount# is 1>
		<!---- good ---->
		got one
	<cfelse>
		something bad happened!
	</cfif>
		-#whatIsIt.VALUE_CODE_TABLE# -#whatIsIt.UNITS_CODE_TABLE#-<br>
		<script>
			opener.document.write('i wrote this');
		</script>
</cfoutput>
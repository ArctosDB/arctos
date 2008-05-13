<cfinclude template = "/includes/_header.cfm">
    <cfif not isdefined("sql")>
        <cfset sql = "SELECT 'test' FROM dual;">
    </cfif>
	    <cfoutput>
	    <form method="post" action="">
	        <input type="hidden" name="action" value="run">
	        <label for="sql">SQL</label>
	        <textarea name="sql" id="sql" rows="10" cols="80" wrap="soft">#sql#</textarea>
	        <input type="submit">
	    </form>
	
	    <cfif #action# is "run">
	        <!--- check the SQL to see if they're doing anything naughty --->
	       <cf_codecleaner input=#sql#>
           <cfset nono="update|insert|delete|drop|create|alter">
            <cfset clean_code = REReplaceNoCase(clean_code, "(</?(#nono#)[^>]*>)", "", "ALL")>
	       --------#clean_code#-------
	    </cfif>
    </cfoutput>
<cfinclude template = "/includes/_footer.cfm">
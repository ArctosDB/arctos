<cfinclude template = "/includes/_header.cfm">
    <cfif not isdefined("sql")>
        <cfset sql = "SELECT 'test' FROM dual;">
    </cfif>
    <form method="post" action="">
        <label for="sql">SQL</label>
        <textarea name="sql" id="sql" rows="10" cols="80" wrap="soft">#sql#</textarea>
    </form>
<cfinclude template = "/includes/_footer.cfm">
<cfoutput>
<cfif not isdefined("collection_object_id")>
    <cfset collection_object_id="">
</cfif>
<cfif not isdefined("transaction_id")>
    <cfset transaction_id="">
</cfif>	
<cfinclude template="/includes/_header.cfm">
<cfinclude template="/includes/functionLib.cfm">
<cfinclude template="/Reports/functions/label_functions.cfm">

<cfif #action# is "nothing">
	<cfif isdefined("report") and len(#report#) gt 0>
		<cfquery name="id" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			select report_id from report where upper(report_name)='#ucase(report)#'
		</cfquery>
		<cfif id.recordcount is 1 and id.report_id gt 0>
			<cflocation url='report_printer.cfm?action=print&report_id=#id.report_id#&collection_object_id=#collection_object_id#&transaction_id=#transaction_id#'>
		<cfelse>
			<div class="error">
				You tried to call this page with a report name, but that failed.
			</div>
		</cfif>
	</cfif>
	<a href="reporter.cfm" target="_blank">Manage Reports</a>
	<cfquery name="e" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
	    select * from cf_report_sql order by report_name
	</cfquery>
	 
	<form name="print" id="print" method="post" action="report_printer.cfm">
	    <input type="hidden" name="action" value="print">
	    <input type="hidden" name="transaction_id" value="#transaction_id#">
	    <input type="hidden" name="collection_object_id" value="#collection_object_id#">
	    <label for="report_id">Print....</label>
		<select name="report_id" id="report_id">
		   <cfloop query="e">
		       <option value="#report_id#">#report_name# (#report_template#)</option>
		   </cfloop>
		</select>
		<input type="submit" value="Print Report">
	</form>
</cfif>
<!------------------------------------------------------>
<cfif #action# is "print">
	<cfquery name="e" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
	    select * from cf_report_sql where report_id=#report_id#
	</cfquery>
	<cfif len(e.sql_text) gt 0>
        <cfset sql=replace(e.sql_text,"##collection_object_id##",#collection_object_id#)>
	 	<cfquery name="d" datasource="#Application.web_user#">
			#preservesinglequotes(sql)#
		</cfquery>
    <cfelse>
        <!--- need soemthing to pass to the function --->
        <cfset d="">
    </cfif>
    <!--- 
        Can call a custom function here to transform the query
    --->
    <cfif len(e.pre_function) gt 0>
        <cfset d=evaluate(e.pre_function & "(d)")>
    </cfif>

        <cfreport format="#e.report_format#" 
            template="#application.webDirectory#/Reports/templates/#e.report_template#"
            query="d" 
           overwrite="true"></cfreport>

    

</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">

<cfoutput>
<cfif not isdefined("collection_object_id")>
    <cfset collection_object_id="">
</cfif>
<cfif not isdefined("transaction_id")>
    <cfset transaction_id="">
</cfif>
<cfif not isdefined("container_id")>
    <cfset container_id="">
</cfif>
<cfif not isdefined("sort")>
    <cfset sort="">
</cfif>	
<cfinclude template="/includes/_header.cfm">
<cfinclude template="/Reports/functions/label_functions.cfm">

<cfif #action# is "nothing">
	<cfif isdefined("report") and len(#report#) gt 0>
		<cfquery name="id" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select report_id from cf_report_sql where upper(report_name)='#ucase(report)#'
		</cfquery>
		<cfif id.recordcount is 1 and id.report_id gt 0>
			<cflocation url='report_printer.cfm?action=print&report_id=#id.report_id#&collection_object_id=#collection_object_id#&container_id=#container_id#&transaction_id=#transaction_id#&sort=#sort#'>
		<cfelse>
			<div class="error">
				You tried to call this page with a report name, but that failed.
			</div>
		</cfif>
	</cfif>
	<a href="reporter.cfm" target="_blank">Manage Reports</a>
	<cfquery name="e" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	    select * from cf_report_sql order by report_name
	</cfquery>
	 
	<form name="print" id="print" method="post" action="report_printer.cfm">
	    <input type="hidden" name="action" value="print">
	    <input type="hidden" name="transaction_id" value="#transaction_id#">
	    <input type="hidden" name="container_id" value="#container_id#">
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
	<cfquery name="e" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	    select * from cf_report_sql where report_id=#report_id#
	</cfquery>
	<cfif len(e.sql_text) gt 0>
		<cfset sql=e.sql_text>
         <cfif sql contains "##transaction_id##">
			yeppers
			<cfset sql=replace(sql,"##transaction_id##",#transaction_id#,"all")>
		<cfelse>
			noper
		</cfif> 
		<cfif sql contains "##collection_object_id##">
			<cfset sql=replace(sql,"##collection_object_id##",#collection_object_id#)>
		</cfif>
		<cfif sql contains "##container_id##">
			<cfset sql=replace(sql,"##container_id##",#container_id#)>
		</cfif>
		
		<cfif sql contains "##session.CustomOtherIdentifier##">
			<cfset sql=replace(sql,"##session.CustomOtherIdentifier##",#session.CustomOtherIdentifier#,"all")>
		</cfif>
		<cfif sql contains "##session.SpecSrchTab##">
			<cfset sql=replace(sql,"##session.SpecSrchTab##",#session.SpecSrchTab#,"all")>
		</cfif>
		
		
		 
		<cfif len(#sort#) gt 0 and #sql# does not contain "order by">
			<cfset ssql=sql & " order by #sort#">
		<cfelse>
			<cfset ssql=sql>
		</cfif>
		<hr>#ssql#<hr>
	 	<cftry>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				#preservesinglequotes(ssql)#
			</cfquery>
		<cfcatch>
			<!--- sort can screw the pooch if they try to sort by things that aren't in the query --->
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				#preservesinglequotes(sql)#
			</cfquery>
		</cfcatch>
		</cftry>
    <cfelse>
        <!--- need soemthing to pass to the function --->
        <cfset d="">
    </cfif>
    <!---  Can call a custom function here to transform the query --->
    <cfif len(e.pre_function) gt 0>
        <cfset d=evaluate(e.pre_function & "(d)")>
    </cfif>
	<cfif e.report_format is "pdf">
		<cfset extension="pdf">
	<cfelseif e.report_format is "RTF">
		<cfset extension="rtf">
	<cfelse>
		<cfset extension="swf">
	</cfif>
    <cfreport format="#e.report_format#" 
    	template="#application.webDirectory#/Reports/templates/#e.report_template#"
        query="d"
        overwrite="true"></cfreport>
</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">

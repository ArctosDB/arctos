<cfoutput>	
<cfinclude template="/includes/_header.cfm">
<cfinclude template="/includes/functionLib.cfm">
<cfinclude template="/Reports/functions/label_functions.cfm">
<!-------------------------------------------------------------->
<cfif #action# is "delete">
    <cfquery name="e" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
        delete from cf_report_sql 
        where report_id=#report_id#
    </cfquery>
    <cflocation url="reporter.cfm">
</cfif>
<!-------------------------------------------------------------->
<cfif #action# is "saveEdit">
    <cfif unsafeSql(sql_text)>
        Your SQL is not acceptable.
        <cfabort>
    </cfif>
    <cfquery name="e" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
        update cf_report_sql set     
        report_name ='#report_name#',
        report_template  ='#report_template#',
        sql_text ='#escapeQuotes(sql_text)#',
        pre_function ='#pre_function#',
        report_format ='#report_format#'
        where report_id=#report_id#
    </cfquery>
    <cflocation url="reporter.cfm?action=edit&report_id=#report_id#">
</cfif>
<!--------------------------------------------------------------------------------------->
<cfif #action# is "edit">
    <cfif not isdefined("report_id")>
	    <cfquery name="e" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
	        select report_id from cf_report_sql where report_name='#report_name#'
	    </cfquery>
        <cflocation url="reporter.cfm?action=edit&report_id=#e.report_id#">
    </cfif>

    <cfquery name="e" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
        select * from cf_report_sql where report_id='#report_id#'
    </cfquery>
    <cfdirectory action="list" directory="#Application.webDirectory#/Reports/templates" filter="*.cfr" name="reportList">
   
    <form method="get" action="reporter.cfm" enctype="text/plain">
        <input type="hidden" name="action" value="saveEdit">
        <input type="hidden" name="collection_object_id" value="#collection_object_id#">
        <input type="hidden" name="report_id" value="#e.report_id#">
        <label for="report_name">Report Name</label>
        <input type="text" name="report_name" id="report_name" value="#e.report_name#">
        <label for="report_template">Report Template</label>
        <select name="report_template" id="report_template">
            <option value="-notfound-">ERROR: Not found!</option>
            <cfloop query="reportList">
                <option <cfif name is e.report_template> selected="selected" </cfif>value="#name#">#name#</option>
            </cfloop>
        </select>
        <label for="pre_function">Pre-Function</label>
        <input type="text" name="pre_function" id="pre_function" value="#e.pre_function#">
        <label for="report_format">Report Format</label>
        <cfset fmt="PDF,FlashPaper">

        <select name="report_format" id="report_format">
            <cfloop list="#fmt#" index="f">
                <option <cfif f is e.report_format> selected="selected" </cfif>value="#f#">#f#</option>
            </cfloop>
        </select>
        <label for="sql_text">SQL</label>
        <textarea name="sql_text" id="sql_text" rows="40" cols="120" wrap="soft"></textarea>
        <br>
        <input type="submit" value="save handler" class="savBtn">
    </form>
    <cfset j=JSStringFormat(e.sql_text)>
    <script>
        var a = escape("#j#");
        var b=document.getElementById('sql_text');
        b.value=unescape(a);
    </script>
       <form method="post" action="reporter.cfm" target="_blank">
           <input type="hidden" name="action" value="testSQL">           
            <input type="hidden" name="collection_object_id" value="#collection_object_id#">
	       <input type="hidden" name="test_sql" id="test_sql">
           <input type="hidden" name="format" id="format" value="table">
           <input type="button" value="Test SQL" onclick="document.getElementById('test_sql').value=document.getElementById('sql_text').value;
                submit();" class="lnkBtn">
    </form>
</cfif>
<!-------------------------------------------------------------->
<cfif #action# is "newHandler">
     <cfquery name="e" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
        insert into cf_report_sql (
            report_name,
            report_template,
            sql_text)
        values (
            'New_Report',
            '#report_template#',
            'select 1 from dual')
    </cfquery>
    <cflocation url="reporter.cfm?action=edit&report_name=New_Report">
</cfif>
<!-------------------------------------------------------------->
<cfif #action# is "clone">
    <cfquery name="e" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
        select * from cf_report_sql where report_id='#report_id#'
    </cfquery>
    <cfquery name="e" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
        insert into cf_report_sql (
            report_name,
            report_template,
            sql_text)
        values (
            'Clone Of #e.report_name#',
            '#e.report_template#',
            '#e.sql_text#')
    </cfquery>
    <cflocation url="reporter.cfm">
</cfif>
<!-------------------------------------------------------------->
<cfif #action# is "testSQL">
    <cfif unsafeSql(test_sql)>
        <div class="error">
             The code you submitted contains illegal characters.
         </div>
         <cfabort>
    </cfif>

         <cfset sql=replace(test_sql,"##collection_object_id##",#collection_object_id#)>
         <cfquery name="user_sql" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
             #preservesinglequotes(sql)#
         </cfquery>
         <cfdump var=#user_sql#>
        
</cfif>
<!-------------------------------------------------------------->
<cfif #action# is "loadTemplate">
    <cffile action="upload"
    	destination="#Application.webDirectory#/Reports/templates/"
      	nameConflict="overwrite"
      	fileField="Form.FiletoUpload" mode="777">
	<cfset fileName=#cffile.serverfile#>
	<cfset dotPos=find(".",fileName)>
	<cfset name=left(fileName,dotPos-1)>
	<cfset extension=right(fileName,len(fileName)-dotPos+1)>
	<cfif REFind("[^A-Za-z0-9_]",name,1) gt 0>
		<font color="##FF0000" size="+2">The filename (<strong>#fileName#</strong>) you entered contains characters that are not alphanumeric.
		Please rename your file and try again.</font>
		<a href="javascript:back()">Go Back</a>
		<cffile action="delete"
	    	file="#Application.webDirectory#/Reports/templates/#fileName#">
        <cfabort>   
	</cfif>
	<cfset ext=right(extension,len(extension)-1)>
	<cfif ext is not "cfr">
		Only .cfr files are accepted.
		<cffile action="delete"
	    	file="#Application.webDirectory#/Reports/templates/#fileName#">
        <cfabort>
	</cfif>
	<cflocation url="reporter.cfm">

</cfif>
<!-------------------------------------------------------------->
<cfif #action# is "nothing">
    <cfdirectory action="list" directory="#Application.webDirectory#/Reports/templates" filter="*.cfr" name="reportList">
    Load a new template (will overwrite old templates). .cfr files only.
    <form name="n" method="post" enctype="multipart/form-data" action="reporter.cfm">
        <input type="hidden" name="action" value="loadTemplate">
        <input type="hidden" name="collection_object_id" value="#collection_object_id#">
        <input type="file" name="FiletoUpload" id="FiletoUpload" size="45">
        <input type="submit" class="savBtn" value="Upload File">
    </form>
    Existing Reports:<br>
    <table border>
         <tr>
            <td>Report Template</td>
            <td>Handler Name</td>
        </tr>
    <cfloop query="reportList">
		<cfquery name="h" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
	        select * from cf_report_sql where report_template='#name#'
	    </cfquery>
        <cfif h.recordcount is 0>
            <cfquery name="h" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		        select 0 report_id,
                '#reportList.name#' report_template,
                ' ' report_name
                from dual
		    </cfquery>
        </cfif>
	    <cfloop query="h">
             <tr>
	            <td>#report_template#</td>
	            <td>#report_name#</td>
	            <cfif report_id gt 1>
	                <td><a href="reporter.cfm?action=edit&report_id=#report_id#">Edit Handler</a></td>
	                <td><a href="reporter.cfm?action=clone&report_id=#report_id#">Clone Handler</a></td>
                    <td><a href="reporter.cfm?action=delete&report_id=#report_id#">Delete Handler</a></td>
	            <cfelse>
	                <td><a href="reporter.cfm?action=newHandler&report_template=#report_template#">Create Handler</a></td>
	            </cfif>
	            <td><a href="reporter.cfm?action=download&report_template=#report_template#">Download Report</a></td>
	        </tr>
        </cfloop>
      
    </cfloop>
    </table>
</cfif>
<!-------------------------------------------------------------->
<cfif #action# is "download">
    <a href="/Reports/templates/#report_template#">Here it is.</a>
</cfif>
<!-------------------------------------------------------------->
</cfoutput>
<cfinclude template="/includes/_footer.cfm">

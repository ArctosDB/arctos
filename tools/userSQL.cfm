<cfinclude template = "/includes/_header.cfm">
    <cfif not isdefined("sql")>
        <cfset sql = "SELECT 'test' FROM dual">
    </cfif>
	    <cfoutput>
	    <form method="post" action="">
	        <input type="hidden" name="action" value="run">
	        <label for="sql">SQL</label>
	        <textarea name="sql" id="sql" rows="10" cols="80" wrap="soft">#sql#</textarea>
	        <br>Result: Table:<input type="radio" name="format" value="table" checked="checked">
                        CSV:<input type="radio" name="format" value="csv">
            <br>
            <input type="submit" value="Run Query" class="lnkBtn">
	    </form>
	    
	    <cfif #action# is "run">
	       <hr>

           <!--- check the SQL to see if they're doing anything naughty --->

           <cfset nono="update,insert,delete,drop,create,alter,dba_,user_,all_,set,execute,exec,begin,end,declare">
           <cfset dels="';','|',">
           <cfset safe=0>
           <cfloop index="i" list="#sql#" delimiters=" .,?!;:%$&""'/|[]{}()">
               <cfif ListFindNoCase(nono, i)>
                   <cfset safe=1>
                </cfif>
            </cfloop>

            <div style="font-size:smaller;background-color:lightgray">
                SQL:<br>
                #sql#
            </div>
            Result:<br>
            <cfif safe gt 0>
               <div class="error">
                    The code you submitted contains illegal characters.
                </div> 
            <cfelse>
	             <cftry>
	                 <cfquery name="user_sql" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		                #preservesinglequotes(sql)#
		            </cfquery>
                    <cfif #format# is "csv">
                        csv this....
                    <cfelse>
                        <cfdump var=#user_sql#>
                    </cfif>
		            
	            <cfcatch>
	                <div class="error">
	                    #cfcatch.message#
	                    <br>
	                    #cfcatch.detail#
	                </div>
	            </cfcatch>
	            </cftry>
            </cfif>
	    </cfif>
    </cfoutput>
<cfinclude template = "/includes/_footer.cfm">
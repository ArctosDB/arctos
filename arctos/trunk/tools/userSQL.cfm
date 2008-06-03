<cfinclude template = "/includes/_header.cfm">
<cfinclude template = "/includes/functionLib.cfm">
    <cfif not isdefined("sql")>
        <cfset sql = "SELECT 'test' FROM dual">
    </cfif>
    <cfif not isdefined("format")>
        <cfset format = "table">
    </cfif>
	    <cfoutput>
	    <form method="post" action="">
	        <input type="hidden" name="action" value="run">
	        <label for="sql">SQL</label>
	        <textarea name="sql" id="sql" rows="10" cols="80" wrap="soft">#sql#</textarea>
	        <br>Result: 
            Table:<input type="radio" name="format" value="table" <cfif #format# is "table"> checked="checked" </cfif>>
                        CSV:<input type="radio" name="format" value="csv" <cfif #format# is "csv"> checked="checked" </cfif>>
            <br>
            <input type="submit" value="Run Query" class="lnkBtn">
	    </form>
	    
	    <cfif #action# is "run">
	       <hr>

           <!--- check the SQL to see if they're doing anything naughty --->

           <cfset nono="update,insert,delete,drop,create,alter,set,execute,exec,begin,end,declare,all_tables,v$session">
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
            unsafeSql(sql): #unsafeSql(sql)#
            <cfif unsafeSql(sql)>
               <div class="error">
                    The code you submitted contains illegal characters.
                </div> 
            <cfelse>
                <cftry>
                    <cfif client.username is "uam" or client.username is "uam_update">
                        <cfabort>
                    </cfif>
	                 <cfquery name="user_sql" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		                #preservesinglequotes(sql)#
		            </cfquery>
                    <cfif #format# is "csv">
                        <cfset ac = user_sql.columnlist>
                        <cfset fileDir = "#Application.webDirectory#">
				        <cfset fileName = "/download/ArctosUserSql_#cfid#_#cftoken#.csv">
				        <cfset header=#trim(ac)#>
				        <cffile action="write" file="#fileDir##fileName#" addnewline="yes" output="#header#">
				        <cfloop query="user_sql">
					        <cfset oneLine = "">
					        <cfloop list="#ac#" index="c">
						        <cfset thisData = #evaluate(c)#>
								<cfif len(#oneLine#) is 0>
									<cfset oneLine = '"#thisData#"'>
								<cfelse>
									<cfset oneLine = '#oneLine#,"#thisData#"'>
								</cfif>
					        </cfloop>
					        <cfset oneLine = trim(oneLine)>
					        <cffile action="append" file="#fileDir##fileName#" addnewline="yes" output="#oneLine#">
				        </cfloop>
				        <a href="#Application.serverRootUrl#/#fileName#">Right-click to save your download.</a>
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
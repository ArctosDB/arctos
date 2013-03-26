<cfoutput>

<!--- Get the starting time. --->

<cfset intStartTime = GetTickCount() />

<cfhttp method="GET" url="http://arctos.database.museum"/>


          Single request GET of http://arctos.database.museum: Results in

          #NumberFormat(((GetTickCount() - intStartTime) / 1000),",.00")#

</cfoutput>


<!----
<cfset intStartTime = GetTickCount() />

<cfloop index="intGet" from="1" to="10" step="1">

          <!--- Start a new thread for this CFHttp call. --->

          <cfthread action="run" name="objGet#intGet#">

               <cfhttp method="GET" url="#strBaseURL##((intGet - 1) * 100)#"

                    useragent="#CGI.http_user_agent#"

                    result="THREAD.Get#intGet#" />

          </cfthread>

</cfloop>



<cfloop index="intGet" from="1" to="10" step="1">

          <cfthread action="join" name="objGet#intGet#" />

</cfloop>




          <!--- Output retrieval times. --->

          <p>We Got 1000 Results in

                #NumberFormat(((GetTickCount() - intStartTime) / 1000),",.00")#

               seconds using CFHttp and CFThread</p>

</cfoutput>

---->
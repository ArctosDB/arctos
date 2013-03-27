	<cfoutput>

	<!--- Get the starting time. --->

	<cfset intStartTime = GetTickCount() />

	<cfhttp method="GET" url="http://www.tacc.utexas.edu/"/>


	          #now()#: Single request GET of http://www.tacc.utexas.edu/: Results in

	          #NumberFormat(((GetTickCount() - intStartTime) / 1000),",.00")#



<cfsavecontent variable="X">
		<cfexecute name = "/usr/bin/curl"
		arguments = "http://www.tacc.utexas.edu/"
		timeout = "20">
		</cfexecute>
		</cfsavecontent>
		done page grab!	          #NumberFormat(((GetTickCount() - intStartTime) / 1000),",.00")#

here's x

<cfdump var=#x#>
<!----

<cfdump var=#cfexecte#>

---->

	</cfoutput>

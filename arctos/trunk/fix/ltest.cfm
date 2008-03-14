<cfset rowsPerPage = 2>
<cfset colsPerPage = 2>

<cfset vSpace = .1>
<cfset hSpace=.1>
<cfset pHeight=8.5>
<cfset pWidth=11>

<cfset lblHeight=3.5>
<cfset lblWidth=5.5>

<cfset counter=0>
<cfloop from="1" to="6" index="i">
	<cfif #counter# is 1>
		<!--- new page --->
		<div style="border:1px solid blue;width:11in;height:8.5in;position:relative">
	</cfif>
	<cfset topPosn = counter * lblHeight>
	<!--- only works on 2-column labels --->
	<cfset lrPosn = counter mod 2 * lblWidth>
			
	<div style="border:1px solid red;width:#lblWidth#in;height:#lblHeight#in;position:absolute;top:#topPosn#in;left:0in;">
		labeley
		<cfdump var=#variables#>
	</div>
	
	<cfset counter=counter+1>
	<cfif counter gt (rowsPerPage * colsPerPage)>
		<cfset counter=0>
	</cfif>
	<cfif #counter# is 0>
		<!--- close new page --->
		</div>
	</cfif>
</cfloop>

	<!----
	<div style="border:1px solid red;width:5.5in;height:2.5in;position:absolute;top:0in;left:5.5in;">
		labeley
	</div>
	<div style="border:1px solid red;width:5.5in;height:2.5in;position:absolute;top:2.5in;left:0in;">
		labeley
	</div>
	<div style="border:1px solid red;width:5.5in;height:2.5in;position:absolute;top:2.5in;left:5.5in;">
		labeley
	</div>
---->
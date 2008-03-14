<cfoutput>
<cfset rowsPerPage = 2>
<cfset colsPerPage = 2>

<cfset pHeight=8.5>
<cfset pWidth=11>

<cfset lblHeight=3.5>
<cfset lblWidth=5.5>

<cfset lrPosn=0>
<cfset topPosn = 0>
<cfset counter=1>
<cfset currentRow=0>
<cfset currentColumn=0>
<cfloop from="1" to="10" index="i">
	<cfif #counter# is 1>
		<!--- new page --->
		<div style="border:1px solid blue;width:11in;height:8.5in;position:relative">
	</cfif>
	
	<!--- only works on 2-column labels --->

	<div style="border:1px solid red;width:#lblWidth#in;height:#lblHeight#in;position:absolute;top:#topPosn#in;left:#lrPosn#in;">
		counter:#counter#;width:#lblWidth#in;height:#lblHeight#in;position:absolute;top:#topPosn#in;left:#lrPosn#in;
	</div>
	
	<cfif lrPosn is 0>
		<cfset lrPosn=lblWidth>
	<cfelse>
		<cfset lrPosn=0>
	</cfif>
	
	<cfif topPosn is 0>
		<cfset topPosn=lblHeight>
	<cfelse>
		<cfset topPosn=0>
	</cfif>
	
	<cfset counter=counter+1>
	<cfif counter gt (rowsPerPage * colsPerPage)>
		<cfset counter=1>
	</cfif>
	<cfif #counter# is 1>
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
</cfoutput>
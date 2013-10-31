	<cfinclude template="/includes/_header.cfm">

<cfoutput>

<cfquery name="c" datasource="uam_god">
	select data from county order by data
</cfquery>
<cfset state="">
<cfset county="">

<cfloop query="c">
	<br>#data#
	<cfif listlen(data," ") is 2>
		<cfset state=listgetat(data,2," ")>
	<cfelse>
		<cfset county=listgetat(data,1,",")>
		<br>ctemp1: #county#
		<cfset listdeleteat(county,1," ")>
	</cfif>
	<br>State: #state#
	<br>County: #county#
</cfloop>
			</cfoutput>
		<cfinclude template="/includes/_footer.cfm">


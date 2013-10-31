	<cfinclude template="/includes/_header.cfm">

<cfoutput>

<cfquery name="c" datasource="uam_god">
	select data from county order by data
</cfquery>
<cfset state="">

<cfloop query="c">
<hr>
<cfset county="">
	<br>#data#
	<cfif listlen(data," ") is 2>
		<cfset state=listgetat(data,2," ")>
	<cfelse>
		<cfset county=listgetat(data,1,",")>
		<br>ctemp1: #county#
		<cfset county = listdeleteat(county,1," ")>
	</cfif>
	<br>State: #state#
	<br>County: #county#
	<cfif len(state) gt 0 and len(county) gt 0>
	<cfquery name="d" datasource="uam_god">
		insert into uscensuscounty (state,county) values ('#trim(state)#','#trim(county)#')
	</cfquery>

		
	</cfif>
</cfloop>
			</cfoutput>
		<cfinclude template="/includes/_footer.cfm">


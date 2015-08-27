<cfoutput>
<cfif not isdefined("attributes.to")>
	<cfset attributes.to="[ unknown ]">
</cfif>
<cfif not isdefined("attributes.subject")>
	<cfset attributes.subject="[ unknown ]">
</cfif>
<cfif not isdefined("attributes.body")>
	<cfset attributes.body="[ unknown ]">
</cfif>


<cfset attributes.date='#dateformat(now(),"yyyy-mm-dd")#T#TimeFormat(now(), "HH:mm:ss")#'>

<cfset attributes.body=trim(replace(HTMLEditFormat(attributes.body),'=','[EQUALS]','all'))>



<cfset logdata="<logEntry>">
	<cfset logdata=logdata & "<date>#attributes.date#</date>">
	<cfset logdata=logdata & "<to>#attributes.to#</to>">
	<cfset logdata=logdata & "<subject>#attributes.subject#</subject>">
	<cfset logdata=logdata & "<body>#attributes.body#</body>">
<cfset logdata=logdata & "</logEntry>">
<cffile action="append" file="#Application.logfile#" output="#logdata#">
</cfoutput>
<!---
	INCLUDE this form, and this form alone, to blacklist IP addresses.

	If ip/subnet already exists in application.blacklist/ application.subnet_blacklist, then log it, show the "justify yourself" form, and abort

	Never autoblacklist or re-auto-blacklist subnets, so mostly ignore that here

	If IP is new, add to blacklist

	If IP is a repeat customer, update and refresh

	Possibilities:


		new ip from allowed subnet
			insert into application.blacklist
			show the "justify yourself" form
		existing IP from allowed subnet, expired or otherwise
		ip


---->
<script>
	try{document.getElementById('loading').style.display='none';}catch(e){}
</script>

<cfquery name="protected_ip_list" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
	select protected_ip_list from cf_global_settings
</cfquery>
<cfif listfind(protected_ip_list.protected_ip_list,trim(request.ipaddress))>
	<cfset ee="
		cgi.HTTP_X_Forwarded_For: #cgi.HTTP_X_Forwarded_For#
		<br>cgi.Remote_Addr: #cgi.Remote_Addr#
		<br>request.ipaddress: #request.ipaddress#
		<br>request.requestingSubnet: #request.requestingSubnet#
	">
	<cfthrow message = "protected IP cannot be blacklisted" errorCode = "127001" extendedInfo="#ee#">
	<cfabort>
</cfif>

<cfif
	isdefined("CGI.HTTP_X_Forwarded_For") and len(CGI.HTTP_X_Forwarded_For) gt 0 and
	isdefined("CGI.Remote_Addr") and len(CGI.Remote_Addr) gt 0 and
	CGI.HTTP_X_Forwarded_For neq CGI.Remote_Addr and
	 CGI.Remote_Addr neq "129.114.52.171">
	 <!---- 129.114.52.171 is Arctos' IP ---->
	<cfset pa="PROXY ALERT: ">
<cfelse>
	<cfset pa="">
</cfif>


<cfif not isdefined("bl_reason")>
	<cfset bl_reason="unknown">
</cfif>
<!--- sometimes already-banned IPs end up here due to click-flooding etc. ---->
<cfif listcontains(application.blacklist,request.ipaddress)>
	<!--- they're already actively blacklisted - do nothing here---->
	<cf_logError subject="#pa#existing active IP autoblacklisted"  message="#bl_reason#">
	<cfinclude template="/errors/gtfo.cfm">
	<cfabort>
</cfif>
<cfif listcontains(application.subnet_blacklist,request.requestingSubnet,",")>
	<!--- they're already actively blacklisted - do nothing here---->
	<cf_logError subject="#pa#existing active subnet autoblacklisted"  message="#bl_reason#">
	<cfinclude template="/errors/gtfo.cfm">
	<cfabort>
</cfif>
<!--- not currently on the nukelist --->
<cfquery name="exists" datasource="uam_god">
	select ip from uam.blacklist where ip='#trim(request.ipaddress)#'
</cfquery>
<cfif len(exists.ip) gt 0>
	<cfquery name="d" datasource="uam_god">
		update uam.blacklist set LISTDATE=sysdate where ip='#trim(request.ipaddress)#'
	</cfquery>
	<cfset application.blacklist=listappend(application.blacklist,trim(request.ipaddress))>
	<cf_logError subject="#pa#updated autoblacklist" message="#bl_reason#">
	<cfinclude template="/errors/gtfo.cfm">
	<cfabort>
<cfelse>
	<cfquery name="d" datasource="uam_god">
		insert into uam.blacklist (ip) values ('#trim(request.ipaddress)#')
	</cfquery>
	<cfset application.blacklist=listappend(application.blacklist,trim(request.ipaddress))>
	<cf_logError subject="#pa#new autoblacklist" message="#bl_reason#">
	<cfinclude template="/errors/gtfo.cfm">
	<cfabort>
</cfif>
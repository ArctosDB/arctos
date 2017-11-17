<cfoutput>
	<cffunction
	    name="ISOToDateTime"
	    access="public"
	    returntype="string"
	    output="false"
	    hint="Converts an ISO 8601 date/time stamp with optional dashes to a ColdFusion date/time stamp.">

	    <!--- Define arguments. --->
	    <cfargument
	    name="Date"
	    type="string"
	    required="true"
	    hint="ISO 8601 date/time stamp."
	    />

	    <!---
	    When returning the converted date/time stamp,
	    allow for optional dashes.
	    --->
	    <cfreturn ARGUMENTS.Date.ReplaceFirst(
	    "^.*?(\d{4})-?(\d{2})-?(\d{2})T([\d:]+).*$",
	    "$1-$2-$3 $4"
	    ) />
</cffunction>

<cfexecute
	 timeout="10"
	 name = "/usr/bin/tail"
	 errorVariable="errorOut"
	 variable="exrslt"
	 arguments = "-5000 #Application.requestlog#" />

<cfset x=queryNew("ts,ip,rqst,usrname")>
<cfloop list="#exrslt#" delimiters="#chr(10)#" index="i">
	<cfset t=listgetat(i,1,"|","yes")>
	<cfset ipa=listgetat(i,5,"|","yes")>
	<cfset r=listgetat(i,7,"|","yes")>
	<cfset u=listgetat(i,3,"|","yes")>
	<cfset queryAddRow(x,{ts=t,ip=ipa,rqst=r,usrname=u})>
</cfloop>

<!--- don't care about scheduled tasks ---->
<cf_qoq>
	delete from x where ip='0.0.0.0'
</cf_qoq>
<!--- for now, ignore cfc request ---->
<cfquery name="x" dbtype="query">
	select * from x where rqst not like '%.cfc%'
</cfquery>

<cfquery name="x" dbtype="query">
	select * from x where rqst not like '%/form/%'
</cfquery>

<cfquery name="x" dbtype="query">
	select * from x where rqst not like '%/includes/%'
</cfquery>

<cfquery name="dip" dbtype="query">
	select distinct(ip) from x
</cfquery>

<cfset maybeBad="">

<cfset timeBetweenQueries=5>
<cfset numberOfQueries=10>
<cfloop query="dip">
	<br>running for #ip#
	<cfquery name="thisRequests" dbtype="query">
		select * from x where ip='#ip#' order by ts
	</cfquery>
	<cfif thisrequests.recordcount gte 10>
		<!--- IPs making 10 or fewer requests just get ignored ---->
		<cfset lastTime=ISOToDateTime("2000-11-08T12:36:0")>
		<cfset nrq=0>
		<cfloop query="thisRequests">
			<cfset thisTime=ISOToDateTime(ts)>
			<cfset ttl=DateDiff("s", lastTime, thisTime)>
			<cfif ttl lte timeBetweenQueries>
				<cfset nrq=nrq+1>
			</cfif>
			<cfset lastTime=thisTime>
		</cfloop>
		<cfif nrq gt numberOfQueries>
			<cfset maybeBad=listappend(maybeBad,'#ip#|#nrq#',",")>
		</cfif>
	</cfif>
</cfloop>

mailing to #application.logemail#....

	<cfloop list="#maybeBad#" index="o" delimiters=",">
		<cfset thisIP=listgetat(o,1,"|")>
		<cfset cfcnt=listgetat(o,2,"|")>
		<p>IP #thisIP# made #cfcnt# flood-like requests in the last 5000 overall requests.</p>

		<a href="http://whatismyipaddress.com/ip/#thisIP#">[ lookup #thisIP# @whatismyipaddress ]</a>
		<br><a href="https://www.ipalyzer.com/#thisIP#">[ lookup #thisIP# @ipalyzer ]</a>
		<br><a href="https://gwhois.org/#thisIP#">[ lookup #thisIP# @gwhois ]</a>
		<p>
			<a href="#Application.serverRootURL#/Admin/blacklist.cfm?action=ins&ip=#thisIP#">[ blacklist #thisIP# ]</a>
			<br><a href="#Application.serverRootURL#/Admin/blacklist.cfm?ipstartswith=#thisIP#">[ manage IP and subnet restrictions ]</a>
		</p>
		<cfquery name="thisIPR" dbtype="query">
			select * from x where ip='#thisIP#' order by ts
		</cfquery>
		<cfloop query="thisIPR">
			<br>#usrname#|#ts#|#rqst#|#ip#
		</cfloop>
	</cfloop>


<!----
<cfmail to="#application.logemail#" subject="click flood detection" from="clickflood@#Application.fromEmail#" type="html">
	<cfloop list="#maybeBad#" index="o" delimiters=",">
		<cfset thisIP=listgetat(o,1,"|")>
		<cfset cfcnt=listgetat(o,2,"|")>
		<p>IP #thisIP# made #cfcnt# flood-like requests in the last 5000 overall requests.</p>

		<br><a href="http://whatismyipaddress.com/ip/#thisIP#">[ lookup #thisIP# @whatismyipaddress ]</a>
		<br><a href="https://www.ipalyzer.com/#thisIP#">[ lookup #thisIP# @ipalyzer ]</a>
		<br><a href="https://gwhois.org/#thisIP#">[ lookup #thisIP# @gwhois ]</a>
		<p>
			<a href="#Application.serverRootURL#/Admin/blacklist.cfm?action=ins&ip=#thisIP#">[ blacklist #thisIP# ]</a>
			<br><a href="#Application.serverRootURL#/Admin/blacklist.cfm?ipstartswith=#thisIP#">[ manage IP and subnet restrictions ]</a>
		</p>
		<cfquery name="thisIPR" dbtype="query">
			select * from x where ip='#thisIP#' order by ts
		</cfquery>
		<cfloop query="thisIPR">
			<br>#usrname#|#ts#|#rqst#|#ip#
		</cfloop>
	</cfloop>
</cfmail>
------->
</cfoutput>

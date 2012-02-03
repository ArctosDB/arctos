<cfoutput>
	<cfparam name="vd" default="">
	<cfparam name="bd" default="">
	<cfparam name="ed" default="">
	<form>
		<input name="vd" value="#vd#">
		<input type="submit">
	</form>
	
	<cfif isdefined("vd") and len(vd) gt 0>
		
		<!--- 4-digit year --->
		<cfif len(vd) is 4 and isnumeric(vd)>
			<cfset bd="#vd#-01-01">
			<cfset ed="#vd#-12-31">
		<cfelseif isdate(vd)>
			<br>vd is a date --#dateformat(vd,"yyyy-mm-dd")#--
			<cfset theYear=datepart("yyyy",vd)>
			<br>theYear=#theYear#
			<cfset theMonth=datepart("m",vd)>
			<br>theMonth=#theMonth#
			<cfset theDay=datepart("d",vd)>
			<br>theDay=#theDay#
			<cfset theDay2=day(vd)>
			<br>theDay2=#theDay2#
			
			<br>diff: #DateDiff("d", vd, dateformat(vd,"yyyy-mm-dd"))#
		</cfif>
		
		<hr>
		vd: #vd#
		<br>bd: #bd#
		<br>ed: #ed#
	</cfif>
</cfoutput>
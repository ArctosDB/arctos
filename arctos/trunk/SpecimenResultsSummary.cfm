<cfinclude template = "/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfset title="Specimen Results Summary">
<cfset basSelect = " SELECT COUNT(distinct(#session.flatTableName#.collection_object_id)) CountOfCatalogedItem,#groupby#">
<cfset basFrom = " FROM #session.flatTableName#">
<cfset basJoin = "">
<cfset basWhere = " WHERE #session.flatTableName#.collection_object_id IS NOT NULL ">	
<cfset basQual = "">
<cfset mapurl="">
<cfinclude template="includes/SearchSql.cfm">
<!--- wrap everything up in a string --->
<cfset SqlString = "#basSelect# #basFrom# #basJoin# #basWhere# #basQual# group by #groupby#">
<cfset sqlstring = replace(sqlstring,"flatTableName","#session.flatTableName#","all")>
<!--- require some actual searching --->
<cfset srchTerms="">
<cfloop list="#mapurl#" delimiters="&" index="t">
	<cfset tt=listgetat(t,1,"=")>
	<cfset srchTerms=listappend(srchTerms,tt)>
</cfloop>
<!--- remove standard criteria that kill Oracle... --->
<cfif listcontains(srchTerms,"ShowObservations")>
	<cfset srchTerms=listdeleteat(srchTerms,listfindnocase(srchTerms,'ShowObservations'))>
</cfif>
<cfif listcontains(srchTerms,"collection_id")>
	<cfset srchTerms=listdeleteat(srchTerms,listfindnocase(srchTerms,'collection_id'))>
</cfif>
<!--- ... and abort if there's nothing left --->
<cfif len(srchTerms) is 0>
	<CFSETTING ENABLECFOUTPUTONLY=0>			
	<font color="##FF0000" size="+2">You must enter some search criteria!</font>	  
	<cfabort>
</cfif>

<cfset checkSql(SqlString)>
<cfif isdefined("debug") and debug is true>
	#preserveSingleQuotes(SqlString)#
</cfif>
<cfquery name="getData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	#preserveSingleQuotes(SqlString)#
</cfquery>
<cfoutput>
<table border id="t" class="sortable">
	<tr>
		<th>Count</th>
		<th>Link</th>
		<cfloop list="#groupby#" index="x">
			<th>#x#</th>
		</cfloop>
	</tr>
	<cfloop query="getData">
		<cfset thisLink=mapurl>
		<cfloop list="#groupby#" index="x">
			<cfset thisLink=listappend(thisLink,'#x#=#evaluate("getData." & x)#',"&")>
		</cfloop>
		<tr>
			<td>#COUNTOFCATALOGEDITEM#</td>
			<td><a href="/SpecimenResults.cfm?#thisLink#">specimens</a>
			<cfloop list="#groupby#" index="x">
				<td>#evaluate("getData." & x)#</td>
			</cfloop>
		</tr>
	</cfloop>
</table>
</cfoutput>
	
<!------------------------------- download --------------------------------->


<cfset dlPath = "#Application.DownloadPath#">
<cfset dlFile = "#session.DownloadFileName#">
 <cfset header ="Count#chr(9)#Scientific_Name">
	<cfif #groupBy# contains "family">
		 <cfset header = "#header##chr(9)#family">
	</cfif>
	<cfif #groupBy# contains "continent_ocean">
		 <cfset header = "#header##chr(9)#continent_ocean">
	</cfif>
	<cfif #groupBy# contains "country">
		<cfset header = "#header##chr(9)#country">
	</cfif>
	<cfif #groupBy# contains "state_prov">
		<cfset header = "#header##chr(9)#state_prov">
	</cfif>
	<cfif #groupBy# contains "county">
		<cfset header = "#header##chr(9)#county">
	</cfif>
	<cfif #groupBy# contains "quad">
		<cfset header = "#header##chr(9)#quad">
	</cfif>
	<cfif #groupBy# contains "feature">
		<cfset header = "#header##chr(9)#feature">
	</cfif>
	<cfif #groupBy# contains "isl_group">
		<cfset header = "#header##chr(9)#island_group">
	</cfif>
	<cfif #groupBy# contains "island">
		<cfset header = "#header##chr(9)#island">
	</cfif>
	<cfif #groupBy# contains "sea">
		<cfset header = "#header##chr(9)#sea">
	</cfif>
	<cfif #groupBy# contains "spec_locality">
		<cfset header = "#header##chr(9)#spec_locality">
	</cfif>

<cfset header=#trim(header)#>
	<cfset header = "#header##chr(10)#"><!--- add one and only one line break back onto the end --->
<cffile action="write" file="#dlPath##dlFile#" addnewline="no" output="#header#">


<cfoutput query="getBasic">
 	 <cfset oneLine ="#countOfCatalogedItem##chr(9)##Scientific_Name#">
	<cfif #groupBy# contains "family">
		 <cfset oneLine = "#oneLine##chr(9)##family#">
	</cfif>
	<cfif #groupBy# contains "continent_ocean">
		 <cfset oneLine = "#oneLine##chr(9)##continent_ocean#">
	</cfif>
	<cfif #groupBy# contains "country">
		<cfset oneLine = "#oneLine##chr(9)##country#">
	</cfif>
	<cfif #groupBy# contains "state_prov">
		<cfset oneLine = "#oneLine##chr(9)##state_prov#">
	</cfif>
	<cfif #groupBy# contains "county">
		<cfset oneLine = "#oneLine##chr(9)##county#">
	</cfif>
	<cfif #groupBy# contains "quad">
		<cfset oneLine = "#oneLine##chr(9)##quad#">
	</cfif>
	<cfif #groupBy# contains "feature">
		<cfset oneLine = "#oneLine##chr(9)##feature#">
	</cfif>
	<cfif #groupBy# contains "isl_group">
		<cfset oneLine = "#oneLine##chr(9)##island_group#">
	</cfif>
	<cfif #groupBy# contains "island">
		<cfset oneLine = "#oneLine##chr(9)##island#">
	</cfif>
	<cfif #groupBy# contains "sea">
		<cfset oneLine = "#oneLine##chr(9)##sea#">
	</cfif>
	<cfif #groupBy# contains "spec_locality">
		<cfset oneLine = "#oneLine##chr(9)##spec_locality#">
	</cfif>






<cfset oneLine = trim(#oneLine#)>
	<cffile action="append" file="#dlPath##dlFile#" addnewline="yes" output="#oneLine#">
</cfoutput>
	<cfoutput>
		<cfset downloadFile = "/download/#dlFile#">
		<form name="download" method="post" action="/download_agree.cfm">
			<input type="hidden" name="cnt" value="#cnt.recordcount#">
			<input type="hidden" name="downloadFile" value="#downloadFile#">
			<input type="submit" value="Download" 
			class="lnkBtn"
   			onmouseover="this.className='lnkBtn btnhov'" 
			onmouseout="this.className='lnkBtn'">
		</form>
	</cfoutput>
<cfinclude template = "includes/_footer.cfm">
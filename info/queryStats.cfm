<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<script language="JavaScript" src="/includes/CalendarPopup.js" type="text/javascript"></script>
<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
	var cal1 = new CalendarPopup("theCalendar");
	cal1.showYearNavigation();
	cal1.showYearNavigationInput();
</SCRIPT>
<SCRIPT LANGUAGE="JavaScript" type="text/javascript">document.write(getCalendarStyles());</SCRIPT>

<cfif action is "nothing">
<cfoutput>
	<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select collection_id,collection from collection order by collection
	</cfquery>
<h2>Query Statistics</h2>
<form method="post" name="f" action="#cgi.script_name#">
	<input type="hidden" name="action" value="show">
	<label for="query_type">Type</label>
	<select name="query_type" id="query_type">
		<option value=""></option>
		<option value="specimen">specimen</option>
		<option value="taxa">taxonomy</option>
	</select>
	<label for="collection_id">Collection</label>
	<select name="collection_id" id="collection_id">
		<option value=""></option>
		<cfloop query="ctcollection">
			<option value="#collection_id#">#collection#</option>
		</cfloop>
	</select>
	<label for="bdate">Begin Date</label>
		<input type="text" name="bdate" id="bdate">
		<img src="/images/pick.gif" 
			class="likeLink" 
			border="0" 
			alt="[calendar]"
			name="anchor1"
			id="anchor1"
			onClick="cal1.select(document.srch.bdate,'anchor1','dd-MMM-yyyy'); return false;"/>
		<label for="edate">Ended Date</label>
		<input type="text" name="edate" id="edate">
		<img src="/images/pick.gif" 
			class="likeLink" 
			border="0" 
			alt="[calendar]"
			name="anchor1"
			id="anchor1"
			onClick="cal1.select(document.srch.edate,'anchor1','dd-MMM-yyyy'); return false;"/>	
	<br><input type="button" class="lnkBtn" value="Table" onclick="f.action.value='showTable';f.submit();">
	<br><input type="button" class="lnkBtn" value="Graph" onclick="f.action.value='showGraph';f.submit();">
</form>
</cfoutput>
</cfif>
<cfif action is "showTable">
<cfoutput>
	<cfif len(bdate) gt 0 and len(edate) is 0>
		<cfset edate=bdate>
	</cfif>
	<cfquery name="d" datasource="uam_god">
		select
			collection,
			QUERY_TYPE,
			CREATE_DATE,
			SUM_COUNT,
			REC_COUNT
		from
			uam_query.query_stats,
			uam_query.query_stats_coll,
			collection
		where
			uam_query.query_stats.QUERY_ID=uam_query.query_stats_coll.QUERY_ID (+) and
			uam_query.query_stats_coll.collection_id=collection.collection_id (+)
		<cfif isdefined("query_type") and len(query_type) gt 0>
			and query_type ='#query_type#'
		</cfif>
		<cfif isdefined("collection_id") and len(collection_id) gt 0>
			and uam_query.query_stats_coll.collection_id ='#collection_id#'
		</cfif>
		<cfif len(#bdate#) gt 0>
			AND (
				to_date(to_char(CREATE_DATE,'dd-mon-yyy')) between to_date('#dateformat(bdate,"dd-mmm-yyyy")#')
				and to_date('#dateformat(edate,"dd-mmm-yyyy")#')
			)
		</cfif>
	</cfquery>
	<cfdump var=#d#>
</cfoutput>
</cfif>
<DIV ID="theCalendar" STYLE="position:absolute;visibility:hidden;background-color:white;layer-background-color:white;"></DIV>
<cfinclude template="/includes/_footer.cfm">
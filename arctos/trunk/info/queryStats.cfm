<!----

create unique index u_query_stats_q_id on uam_query.query_stats (QUERY_ID) tablespace uam_idx_1;
create index query_stats_coll_q_id on uam_query.query_stats_coll (QUERY_ID) tablespace uam_idx_1;
create index query_stats_coll_coll_id on uam_query.query_stats_coll (collection_id) tablespace uam_idx_1;
create index query_stats_coll_c_date on uam_query.query_stats (create_date) tablespace uam_idx_1;
analyze table uam_query.query_stats_coll compute statistics;
analyze table uam_query.query_stats compute statistics;

test-uam> desc ;
 Name										     Null?    Type
 ----------------------------------------------------------------------------------- -------- --------------------------------------------------------
 										      NUMBER
 QUERY_TYPE										      VARCHAR2(10)
 CREATE_DATE										      DATE
 SUM_COUNT										      NUMBER

test-uam> desc uam_query.query_stats_coll
 Name										     Null?    Type
 ----------------------------------------------------------------------------------- -------- --------------------------------------------------------
 QUERY_ID										      NUMBER
 REC_COUNT										      NUMBER
 COLLECTION_ID		


---->

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
			onClick="cal1.select(document.f.bdate,'anchor1','dd-MMM-yyyy'); return false;"/>
		<label for="edate">Ended Date</label>
		<input type="text" name="edate" id="edate">
		<img src="/images/pick.gif" 
			class="likeLink" 
			border="0" 
			alt="[calendar]"
			name="anchor1"
			id="anchor1"
			onClick="cal1.select(document.f.edate,'anchor1','dd-MMM-yyyy'); return false;"/>	
	<br><input type="button" class="lnkBtn" value="Table" onclick="f.action.value='showTable';f.submit();">
	<br><input type="button" class="lnkBtn" value="Graph" onclick="f.action.value='showSummary';f.submit();">
</form>
</cfoutput>
</cfif>
<cfif action is "showSummary">
	<cfoutput>
		<cfif len(bdate) gt 0 and len(edate) is 0>
			<cfset edate=bdate>
		</cfif>
		<cfquery name="total" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select
				uam_query.query_stats.query_id,
				collection,
				QUERY_TYPE,
				CREATE_DATE,
				SUM_COUNT,
				REC_COUNT,
				username
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
		<cfquery name="smr" dbtype="query">
			select 
				sum(SUM_COUNT) tot,
				avg(sum_count) avrg,
				min(sum_count) minrec,
				max(sum_count) maxrec 
			from total
		</cfquery>
		
		<cfdump var=#smr#>
	</cfoutput>
</cfif>
<cfif action is "showTable">
<cfoutput>
	This form will return no more than 5000 rows.
	<cfif len(bdate) gt 0 and len(edate) is 0>
		<cfset edate=bdate>
	</cfif>
	<cfquery name="d" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select * from (	
			select
				uam_query.query_stats.query_id,
				collection,
				QUERY_TYPE,
				CREATE_DATE,
				SUM_COUNT,
				REC_COUNT,
				username
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
					to_date(to_char(CREATE_DATE,'dd mmm yyy')) between to_date('#dateformat(bdate,"dd-mmm-yyyy")#')
					and to_date('#dateformat(edate,"dd-mmm-yyyy")#')
				)
			</cfif>
		) where rownum <= 5000
	</cfquery>
	<table border="1" id="tbl"  class="sortable">
		<tr>
			<th>ID</th>
			<th>Username</th>
			<th>Type</th>
			<th>Date</th>
			<th>Total</th>
			<th>Collection</th>
			<th>Colln. Cnt.</th>
		</tr>
		<cfloop query="d">
			<tr>
				<td>#query_id#</td>
				<td>#username#</td>
				<td>#QUERY_TYPE#</td>
				<td>#dateformat(CREATE_DATE,"dd mmm yyyy")#</td>
				<td>#SUM_COUNT#</td>
				<td>#collection#</td>
				<td>#REC_COUNT#</td>
			</tr>
		</cfloop>
	</table>
</cfoutput>
</cfif>
<DIV ID="theCalendar" STYLE="position:absolute;visibility:hidden;background-color:white;layer-background-color:white;"></DIV>
<cfinclude template="/includes/_footer.cfm">
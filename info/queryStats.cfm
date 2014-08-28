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
<cfset title="Query Statistics">
<script src="/includes/sorttable.js"></script>
<script language="javascript" type="text/javascript">
	jQuery(document).ready(function() {
		$("#bdate").datepicker();
		$("#edate").datepicker();
	});
</script>
<cfif action is "nothing">
	These data include all requests, including those made by machines, for specimens or taxon names.
	
	<br>Large queries may time out and/or eat your browser. Limit your results and try again, or contact us for help.
	
	<p>
		CSV option headers:
		
		<br>QID=query ID
		<br>COLLECTION=collection that REC_COUNT applies to
		<br>QUERY_TYPE=specimen,taxonomy
		<br>CREATE_DATE=timestamp
		<br>SUM_COUNT=total specimens returned by query. Queries often include specimens from >1 collection.
		<br>REC_COUNT=specimens for collection reported in COLLECTION. Use QID to find other specimens.
		<br>USER=Oracle user performing the query
	</p>
	<cfoutput>
	<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
	<select name="collection_id" id="collection_id" multiple="multiple">
		<option value=""></option>
		<cfloop query="ctcollection">
			<option value="#collection_id#">#collection#</option>
		</cfloop>
	</select>
	<label for="bdate">Begin Date</label>
		<input type="text" name="bdate" id="bdate">
		
		<label for="edate">Ended Date</label>
		<input type="text" name="edate" id="edate">
		<!---
	<br><input type="button" class="lnkBtn" value="Table" onclick="f.action.value='showTable';f.submit();">
	<br><input type="button" class="lnkBtn" value="Graph" onclick="f.action.value='showSummary';f.submit();">
	--->
	<br><input type="button" class="lnkBtn" value="Monthly Summary" onclick="f.action.value='monthlySummary';f.submit();">
	<br><input type="button" class="lnkBtn" value="Raw Data (csv)" onclick="f.action.value='raw';f.submit();">
</form>
</cfoutput>
</cfif>

<cfif action is "raw">
<cfoutput>
	
	<cfif len(bdate) gt 0 and len(edate) is 0>
		<cfset edate=bdate>
	</cfif>
	<cfquery name="d" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
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
			and uam_query.query_stats_coll.collection_id in (#collection_id#)
		</cfif>
		<cfif len(bdate) gt 0>
			AND (
				to_date(to_char(CREATE_DATE,'yyyy-mm-dd')) between to_date('#dateformat(bdate,"yyyy-mm-dd")#')
				and to_date('#dateformat(edate,"yyyy-mm-dd")#')
			)
		</cfif>
	</cfquery>
	<cfset variables.encoding="UTF-8">
	<cfset fname = "arctosQueryStats.csv">
	<cfset variables.fileName="#Application.webDirectory#/download/#fname#">
	<cfset header="QID,COLLECTION,QUERY_TYPE,CREATE_DATE,SUM_COUNT,REC_COUNT,USER">
	<cfscript>
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
		variables.joFileWriter.writeLine(header); 
	</cfscript>
	<cfloop query="d">
		<cfset oneLine = '"#query_id#","#collection#","#QUERY_TYPE#","#CREATE_DATE#","#SUM_COUNT#","#REC_COUNT#","#username#"'>
		<cfscript>
			variables.joFileWriter.writeLine(oneLine);
		</cfscript>
	</cfloop>
	<cfscript>	
		variables.joFileWriter.close();
	</cfscript>
	<cflocation url="/download.cfm?file=#fname#" addtoken="false">
	<a href="/download/#fname#">Click here if your file does not automatically download.</a>
</cfoutput>
</cfif>
<cfif action is "monthlySummary">
	<cfoutput>
		<cfif len(bdate) gt 0 and len(edate) is 0>
			<cfset edate=bdate>
		</cfif>
		<cfquery name="total" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select 
				collection,
				to_char(qs.create_date, 'YYYY-MM') d,
				count(qsc.query_id) c,
        		sum(qsc.rec_count) s
			from 
				uam_query.query_stats qs, 
				uam_query.query_stats_coll qsc,
				collection
			where 
				qs.query_id = qsc.query_id and
				qsc.collection_id=collection.collection_id (+)
				<cfif isdefined("collection_id") and len(collection_id) gt 0>
					and qsc.collection_id in (#collection_id#)
				</cfif>
				<cfif len(bdate) gt 0>
					AND (
						to_date(to_char(CREATE_DATE,'yyyy-mm-dd')) between to_date('#dateformat(bdate,"yyyy-mm-dd")#')
						and to_date('#dateformat(edate,"yyyy-mm-dd")#')
					)
				</cfif>
				<cfif isdefined("query_type") and len(query_type) gt 0>
					and query_type ='#query_type#'
				</cfif>
			group by 
				collection,
				to_char(qs.create_date, 'YYYY-MM')
			order by 
				to_char(qs.create_date, 'YYYY-MM')
		</cfquery>
		
		<cfquery name="tot" dbtype="query">
			select sum(c) totc, sum(s) tots from total
		</cfquery>
		<cfdump var=#tot#>
		<table border="1" class="sortable">
			<tr>
				<th>Collection</th>
				<th>Date</th>
				<th>##Queries</th>
				<th>##records</th>
			</tr>
			<cfloop query="total">
				<tr>
					<td>#collection#</td>
					<td>#d#</td>
					<td>#c#</td>
					<td>#s#</td>
				</tr>
			</cfloop>
		</table>
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
				and uam_query.query_stats_coll.collection_id  in (#collection_id#)
			</cfif>
			<cfif len(#bdate#) gt 0>
				AND (
					to_date(to_char(CREATE_DATE,'yyyy-mm-dd')) between to_date('#dateformat(bdate,"yyyy-mm-dd")#')
					and to_date('#dateformat(edate,"yyyy-mm-dd")#')
				)
			</cfif>
		</cfquery>
		<cfquery name="smr" dbtype="query">
			select 
				count(*) c,
				sum(SUM_COUNT) tot,
				avg(sum_count) avrg,
				min(sum_count) minrec,
				max(sum_count) maxrec
			from 
				total
		</cfquery>
		Overall Summary
		<table border="1">
			<tr>
				<th>Queries</th>
				<th>Total records</th>
				<th>Mean records/query</th>
				<th>Minimum records/query</th>
				<th>Maximum records/query</th>
			</tr>
			<tr>
				<td>#smr.c#</td>
				<td>#smr.tot#</td>
				<td>#round(smr.avrg)#</td>
				<td>#smr.minrec#</td>
				<td>#smr.maxrec#</td>
			</tr>
		</table>
		<cfquery name="smrc" dbtype="query">
			select 
				collection,
				count(*) c,
				sum(SUM_COUNT) tot,
				avg(sum_count) avrg,
				min(sum_count) minrec,
				max(sum_count) maxrec
			from 
				total
			group by collection
		</cfquery>
		Collection Summary
		<table border="1" class="sortable">
			<tr>
				<th>Collection</th>
				<th>Queries</th>
				<th>Total records</th>
				<th>Mean records/query</th>
				<th>Minimum records/query</th>
				<th>Maximum records/query</th>
			</tr>
			<cfloop query="smrc">
				<tr>
					<td>#collection#</td>
					<td>#c#</td>
					<td>#tot#</td>
					<td>#round(avrg)#</td>
					<td>#minrec#</td>
					<td>#maxrec#</td>
				</tr>
			</cfloop>
		</table>
		<cfquery name="lcl" dbtype="query">
			select * from total
		</cfquery>
		<cfset mon=arraynew(1)>
		<cfset yr=arraynew(1)>
		<cfset myr=arraynew(1)>
		<cfset i=1>
		<cfloop query="lcl">
			<cfset mon[i]=dateformat(create_date,"mm")>
			<cfset yr[i]=dateformat(create_date,"yyyy")>
			<cfset myr[i]=dateformat(create_date,"Mmm-yyyy")>
			<cfset i=i+1>
		</cfloop>
		
		<cfset nColumnNumber = QueryAddColumn(lcl, "mm", "Integer",mon)>
		<cfset nColumnNumber = QueryAddColumn(lcl, "yr", "Integer",yr)>
		<cfset nColumnNumber = QueryAddColumn(lcl, "myr", "VarChar",myr)>
		
		<cfquery name="sbd" dbtype="query">
			select
				collection,
				myr,
				count(*) c,
				sum(SUM_COUNT) tot,
				avg(sum_count) avrg,
				min(sum_count) minrec,
				max(sum_count) maxrec,
				yr,
				mm			
			from
				lcl
			group by
				collection,
				myr,
				yr,
				mm	
			order by
				collection,
				yr,
				mm
		</cfquery>
		<cfquery name="allc" dbtype="query">
			select
				myr,
				yr,
				mm,
				sum(SUM_COUNT) tot		
			from
				lcl
			group by
				myr,
				yr,
				mm
			order by
				yr,
				mm
		</cfquery>
		<cfchart 
			style="slanty"
			chartHeight="600"
			chartWidth="600"
			format="png" 
		    xaxistitle="Month" 
		    yaxistitle="Number records accessed"> 
			<cfchartseries type="bar" 
			    query="allc" 
			    itemcolumn="myr" 
			    valuecolumn="tot"
				dataLabelStyle="value">
			</cfchartseries>
		</cfchart>
		
		<cfquery name="cbt" dbtype="query">
			select
				collection,
				sum(SUM_COUNT) tot					
			from
				total
			group by
				collection
			order by
				collection
		</cfquery>
		<cfchart format="png" 
		   style="slanty"
		   	 chartHeight="600"
			chartWidth="1200"
				xaxistitle="Collection" 
		    yaxistitle="Number records accessed"> 
			<cfchartseries type="bar" 
			    query="cbt" 
			    itemcolumn="collection" 
			    valuecolumn="tot"
				dataLabelStyle="value">
			</cfchartseries>
		</cfchart>
		
		<cfquery name="dcol" dbtype="query">
			select collection from total where collection is not null group by collection
		</cfquery>
		<cfloop query="dcol">
			<cfquery name="q" dbtype="query">
				select
					myr,
					yr,
					mm,
					count(*) c					
				from
					lcl
				where
					collection='#collection#'
				group by
					myr,
					yr,
					mm
				order by
					yr,
					mm
			</cfquery>
			<cfchart 
				style="slanty"
				chartHeight="600"
				chartWidth="600"
				format="png" 
			    xaxistitle="Month" 
			    yaxistitle="Number #collection# records accessed"> 
				<cfchartseries type="bar" 
				    query="q" 
				    itemcolumn="myr" 
				    valuecolumn="c"
					dataLabelStyle="value">
				</cfchartseries>
			</cfchart>
		</cfloop>
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
					to_date(to_char(CREATE_DATE,'yyyy-mm-dd')) between to_date('#dateformat(bdate,"yyyy-mm-dd")#')
					and to_date('#dateformat(edate,"yyyy-mm-dd")#')
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
<cfinclude template="/includes/_footer.cfm">
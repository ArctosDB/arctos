<cfoutput>
<cfinclude template="/includes/_header.cfm">
<script language="JavaScript" src="/includes/jquery/scrollTo.js" type="text/javascript"></script>
<cfset title="code table documentation">
<script src="/includes/sorttable.js"></script>
<cfparam name="coln" default="">
<cfif not isdefined("table")>
	<cfquery name="getCTName" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select
			distinct(table_name) table_name
		from
			sys.user_tables
		where
			table_name like 'CT%'
		UNION
			select 'CTGEOLOGY_ATTRIBUTE' table_name from dual
		 order by table_name
	</cfquery>
	<b>Code Table Documentation</b>
	<cfloop query="getCTName">
		<br><a href="ctDocumentation.cfm?table=#table_name#">#table_name#</a>
	</cfloop>
</cfif>
<cfif isdefined("table")>
<cfset tableName = right(table,len(table)-2)>
<cfif not isdefined("field") or field is "undefined">
	<cfset field="">
</cfif>
<cfif len(field) gt 0>
	<script>
		$(document).ready(function () {
			$(document).scrollTo( $('[name="#field#"]:first'), 800 );
		});
	</script>
</cfif>
<cfset title="#table# - code table documentation">
Documentation for code table <strong>#tableName#</strong> ~ <a href="ctDocumentation.cfm">[ table list ]</a>
	<cftry>
		<!-------->
	<cfquery name="docs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select * from #wrd(table)# <cfif len(coln) gt 0> where collection_cde='#coln#'</cfif>
	</cfquery>
	<cfcatch>
		<div class="error">table not found</div><cfabort>
	</cfcatch>
	</cftry>
	<cfif docs.columnlist contains "collection_cde">
		<cfquery name="ccde" datasource="cf_dbuser" cachedwithin="#createtimespan(0,0,60,0)#">
			select collection_cde from ctcollection_cde order by collection_cde
		</cfquery>
		<form name="f" method="get" action="ctDocumentation.cfm">
			<input type="hidden" name="table" value="#table#">
			<label for="coln">Show only collection type</label>
			<select name="coln">
				<option value="">All</option>
				<cfloop query="ccde">
					<option <cfif coln is collection_cde>selected="selected"</cfif> value="#collection_cde#">#collection_cde#</option>
				</cfloop>
			</select>
			<input type="submit" value="filter">
		</form>
	</cfif>
	<cfif table is "ctmedia_license">
		<table border id="t" class="sortable">
			<tr>
				<th>
					<strong>License</strong>
				</th>
				<th><strong>Description</strong></th>
				<th>
					<strong>URI</strong>
				</th>
			</tr>
			<cfloop query="docs">
				<tr>
					<td>#display#</td>
					<td>#description#</td>
					<td><a href="#uri#" target="_blank" class="external">#uri#</a></td>
				</tr>
			</cfloop>
		</table>
	<cfelseif table is "CTTAXON_TERM">
		<cfquery name="cData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			SELECT
				TAXON_TERM,
				DESCRIPTION,
				DECODE(IS_CLASSIFICATION,0,'no','yes') IS_CLASSIFICATION
			FROM
				CTTAXON_TERM
			order by
				IS_CLASSIFICATION,
				RELATIVE_POSITION,
				TAXON_TERM
		</cfquery>
		<table border id="t" class="sortable">
			<tr>
				<th>Term</th>
				<th>Classification</th>
				<th>Definition</th>
			</tr>
			<cfset i=1>
			<cfloop query="cData">
				<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
					<td>#TAXON_TERM#</td>
					<td>#IS_CLASSIFICATION#</td>
					<td>#DESCRIPTION#</td>
				</tr>
				<cfset i=i+1>
			</cfloop>
		</table>
	<cfelseif table is "CTGEOLOGY_ATTRIBUTE">
		<cfquery name="cData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			 SELECT
			 	level,
			 	geology_attribute_hierarchy_id,
			 	parent_id,
			 	usable_value_fg,
		   		attribute_value || ' (' || attribute || ')' attribute
			FROM
				geology_attribute_hierarchy
			start with parent_id is null
			CONNECT BY PRIOR
				geology_attribute_hierarchy_id = parent_id
		</cfquery>
		(Values in red are not "data" values but may be used in searches.)
		<cfset levelList = "">
		<cfloop query="cData">
			<cfif listLast(levelList,",") IS NOT level>
		    	<cfset levelListIndex = listFind(levelList,cData.level,",")>
		      	<cfif levelListIndex IS NOT 0>
		        	<cfset numberOfLevelsToRemove = listLen(levelList,",") - levelListIndex>
		         	<cfloop from="1" to="#numberOfLevelsToRemove#" index="i">
		            	<cfset levelList = listDeleteAt(levelList,listLen(levelList,","))>
		         	</cfloop>
		        	#repeatString("</ul>",numberOfLevelsToRemove)#
		      	<cfelse>
		        	<cfset levelList = listAppend(levelList,cData.level)>
		         	<ul>
		      	</cfif>
		  	</cfif>
			<li><span <cfif usable_value_fg is 0>style="color:red"</cfif>
			>#attribute#</span>
			</li>
			<cfif cData.currentRow IS cData.recordCount>
				#repeatString("</ul>",listLen(levelList,","))#
		   	</cfif>
		</cfloop>
	<cfelseif table is "ctcollection_cde">
		<cfset i=1>
		<table border id="t" class="sortable">
			<tr>
				<th>
					<strong>Collection_Cde</strong>
				</th>
			</tr>
			<cfloop query="docs">
				<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
					<td nowrap>#collection_cde#</td>
				</tr>
				<cfset i=i+1>
			</cfloop>
		</table>
	<cfelseif table is "ctcoll_other_id_type">
		<cfquery name="docs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select OTHER_ID_TYPE,DESCRIPTION,BASE_URL,sort_order from ctcoll_other_id_type order by sort_order,OTHER_ID_TYPE
		</cfquery>
		<table border id="t" class="sortable">
			<tr>
				<th>
					<strong>IDType</strong>
				</th>
				<th><strong>Description</strong></th>
				<th>
					<strong>Base URI</strong>
				</th>
				<th>
					<strong>Sort</strong>
				</th>
			</tr>
			<cfloop query="docs">
				<tr>
					<td name="#OTHER_ID_TYPE#">#OTHER_ID_TYPE#</td>
					<td>#description#</td>
					<td>#BASE_URL#</td>
					<td>#sort_order#</td>
				</tr>
			</cfloop>
		</table>
	<cfelseif table is "ctattribute_code_tables">
		<cfquery name="ctAttribute_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select distinct(attribute_type) from ctAttribute_type <cfif len(coln) gt 0> where collection_cde='#coln#'</cfif>
		</cfquery>
		<cfquery name="thisRec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			Select * from ctattribute_code_tables
			order by attribute_type
		</cfquery>
		<cfquery name="allCTs" datasource="uam_god">
			select distinct(table_name) as tablename from sys.user_tables where table_name like 'CT%' order by table_name
		</cfquery>
		<table border id="t" class="sortable">
			<tr>
				<th>Attribute</th>
				<th>Value Code Table</th>
				<th>Units Code Table</th>
			</tr>
			<cfset i=1>
			<cfloop query="thisRec">
				<tr>
					<td name="#attribute_type#">
						<a href="ctDocumentation.cfm?table=CTATTRIBUTE_TYPE&field=#attribute_type#">#attribute_type#</a>
					</td>
					<td>
						<a href="ctDocumentation.cfm?table=#value_code_table#">#value_code_table#</a>
					</td>
					<td>
						<a href="ctDocumentation.cfm?table=#units_code_table#">#units_code_table#</a>
					</td>
					<td>
				</tr>
			</cfloop>
		</table>
	<cfelseif table is "ctspecimen_part_name">
		<cfquery name="ctspecimen_part_name" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select * from ctspecimen_part_name <cfif len(coln) gt 0> where collection_cde='#coln#'</cfif> order by part_name,collection_cde,is_tissue
		</cfquery>
		<cfquery name="dpartName" dbtype="query">
			select distinct(part_name) from ctspecimen_part_name order by part_name
		</cfquery>
		<table border id="t" class="sortable">
			<tr>
				<th>Part_Name</th>
				<th>Collection</th>
				<th>IsTissue</th>
				<th>Documentation</th>
			</tr>
			<cfset i=1>
			<cfloop query="dpartName">
				<tr>
					<td name="#Part_Name#">
						#Part_Name#
					</td>
					<td>
						<cfquery name="ubc" dbtype="query">
							select distinct collection_cde from ctspecimen_part_name where part_name='#part_name#'
						</cfquery>
						<cfloop query="ubc">
							<div>#collection_cde#</div>
						</cfloop>

					</td>
					<td>
						<cfquery name="it" dbtype="query">
							select distinct is_Tissue from ctspecimen_part_name where part_name='#part_name#'
						</cfquery>
						<cfif it.is_Tissue eq 1>yes<cfelse>no</cfif>
					</td>
					<td>
						<cfquery name="ud" dbtype="query">
							select distinct DESCRIPTION from ctspecimen_part_name where part_name='#part_name#'
						</cfquery>
						<cfloop query="ud">
							<div>#DESCRIPTION#</div>
						</cfloop>
					</td>
				</tr>
			</cfloop>
		</table>
	<cfelse>
		<cfset hasColnCde=false>
		<cfloop list="#docs.columnlist#" index="colName">
			<cfif colName is not "COLLECTION_CDE" and colName is not "DESCRIPTION">
				<cfset theColumnName = colName>
			</cfif>
			<cfif colName is "COLLECTION_CDE">
				<cfset hasColnCde=true>
			</cfif>
		</cfloop>
		<cfquery name="theRest" dbtype="query">
			select * from docs order by #theColumnName#
			<cfif docs.columnlist contains "collection_cde">
				 ,collection_cde
			</cfif>
		</cfquery>
		<cfif hasColnCde is false>
			<table border id="t" class="sortable">
				<tr>
					<th>
						<strong>#theColumnName#</strong>
					</th>
					<cfif docs.columnlist contains "collection_cde">
						<th><strong>Collection</strong></th>
					</cfif>
					<cfif docs.columnlist contains "description">
						<th><strong>Documentation</strong></th>
					</cfif>
				</tr>
				<cfset i=1>
				<cfloop query="theRest">
					<cfset thisVal=trim(evaluate(theColumnName))>
					<cfif field is thisVal>
						<tr style="font-weight:bold;">
					<cfelse>
						<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
					</cfif>
					<td name="#thisVal#">
						#thisVal#
					</td>
					<cfif docs.columnlist contains "collection_cde">
						<td>#collection_cde#</td>
					</cfif>
					<cfif docs.columnlist contains "description">
						<td>#description#</td>
					</cfif>
					</tr>
					<cfset i=i+1>
				</cfloop>
			</table>
		<cfelse>
			<cfquery name="ut" dbtype="query">
				select #theColumnName# from theRest group by #theColumnName# order by #theColumnName#
			</cfquery>
			<table border id="t" class="sortable">
				<tr>
					<th>
						<strong>#theColumnName#</strong>
					</th>
						<th><strong>Collection</strong></th>
					<cfif docs.columnlist contains "description">
						<th><strong>Documentation</strong></th>
					</cfif>
				</tr>
				<cfset i=1>
				<cfloop query="ut">
					<cfset thisVal=trim(evaluate(theColumnName))>
					<cfif field is thisVal>
						<tr style="font-weight:bold;">
					<cfelse>
						<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
					</cfif>

					<td name="#thisVal#">
						#thisVal#
					</td>
					<cfquery name="thisC" dbtype="query">
						select collection_cde from theRest where #theColumnName#='#thisVal#' group by collection_cde order by collection_cde
					</cfquery>
					<td>
						<cfloop query="thisC">
							<div>#collection_cde#</div>
						</cfloop>
					</td>
					<cfquery name="thisD" dbtype="query">
						select description from theRest where description is not null and
						#theColumnName#='#thisVal#' group by description order by description
					</cfquery>
					<td>
						<cfloop query="thisD">
							<div>#description#</div>
						</cfloop>
					</td>

					</tr>
					<cfset i=i+1>
				</cfloop>
			</table>
		</cfif>
	</cfif>
</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
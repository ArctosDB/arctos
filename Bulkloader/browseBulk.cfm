<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfset title="Browse/Edit Bulkloaded Data">
<style>
.blTabDiv {
	width: 100%;
	overflow:scroll;
}
</style>
<!-------------------------------------------------------------->
<cfparam name="enteredby" default="" type="any">
<cfparam name="accn" default="" type="any">
<cfparam name="colln" default="" type="any">
<cfif len(enteredby) gt 0>
	<cfif left(enteredby,1) neq "'">
		<cfset enteredby=listqualify(enteredby,"'")>
	</cfif>
</cfif>
<cfif action is "loadAll">
	<cfoutput>
		<cfset sql="UPDATE bulkloader SET LOADED = NULL WHERE collection_object_id > 500" >
		<cfif len(enteredby) gt 0>
			<cfset sql = "#sql# AND enteredby IN (#enteredby#)">
		</cfif>
		<cfif len(accn) gt 0>
			<cfset sql = "#sql# AND accn IN (#accn#)">
		</cfif>
		<cfif isdefined("colln") and len(colln) gt 0>
			<cfset sql = "#sql# AND institution_acronym || ':' || collection_cde IN (#colln#)">
		</cfif>
		<cfquery name="upBulk" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			#preservesinglequotes(sql)#
		</cfquery>
		<cflocation url="browseBulk.cfm?action=#returnAction#&enteredby=#enteredby#&accn=#accn#&colln=#colln#" addtoken="false">
	</cfoutput>
</cfif>
<cfif action is "download">
	<cfoutput>
		<cfquery name="cNames" datasource="uam_god">
			select column_name from user_tab_cols where table_name='BULKLOADER' and column_name not like '%$%'
			order by internal_column_id
		</cfquery>
		<cfset sql = "select * from bulkloader where 1=1">
		<cfif len(enteredby) gt 0>
			<cfset sql = "#sql# AND enteredby IN (#enteredby#)">
		</cfif>
		<cfif len(accn) gt 0>
			<cfset sql = "#sql# AND accn IN (#accn#)">
		</cfif>
		<cfif isdefined("colln") and len(colln) gt 0>
			<cfset sql = "#sql# AND institution_acronym || ':' || collection_cde IN (#colln#)">
		</cfif>
		<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			#preservesinglequotes(sql)#
		</cfquery>
		<cfset variables.encoding="UTF-8">
		<cfset fname = "BulkPendingData_#left(session.sessionKey,10)#.csv">
		<cfset variables.fileName="#Application.webDirectory#/download/#fname#">
		<cfset header=#trim(valuelist(cNames.column_name))#>
		<cfscript>
			variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
			variables.joFileWriter.writeLine(header);
		</cfscript>
		<cfloop query="data">
			<cfset oneLine = "">
			<cfloop list="#valuelist(cNames.column_name)#" index="c">
				<cfset thisData = #evaluate(c)#>
				<cfif len(oneLine) is 0>
					<cfset oneLine = '"#thisData#"'>
				<cfelse>
					<cfset oneLine = '#oneLine#,"#thisData#"'>
				</cfif>
			</cfloop>
			<cfset oneLine = trim(oneLine)>
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
<cfif action is "ajaxGrid">
	<cfoutput>
		<cfquery name="cNames" datasource="uam_god">
			select column_name from user_tab_cols where table_name='BULKLOADER' and column_name not like '%$%'
			order by internal_column_id
		</cfquery>
		<cfset ColNameList = valuelist(cNames.column_name)>
		<cfset ColNameList = replace(ColNameList,"COLLECTION_OBJECT_ID","","all")>
		<cfset args.width="1200">
		<cfset args.height="600">
		<cfset args.stripeRows = true>
		<cfset args.selectColor = "##D9E8FB">
		<cfset args.selectmode = "edit">
		<cfset args.format="html">
		<cfset args.onchange = "cfc:component.Bulkloader.editRecord({cfgridaction},{cfgridrow},{cfgridchanged})">
		<cfset args.bind="cfc:component.Bulkloader.getPage({cfgridpage},{cfgridpagesize},{cfgridsortcolumn},{cfgridsortdirection},{accn},{enteredby},{colln})">
		<cfset args.name="blGrid">
		<cfset args.pageSize="20">		
		<a href="browseBulk.cfm?action=download&enteredby=#enteredby#&accn=#accn#&colln=#colln#">Download CSV</a>&nbsp;~&nbsp;
		Set LOADED to DELETE to delete.&nbsp;~&nbsp;
		<a href="browseBulk.cfm?action=loadAll&enteredby=#enteredby#&accn=#accn#&colln=#colln#&returnAction=ajaxGrid">Mark all to load</a>
		<cfform method="post" action="browseBulk.cfm">
			<cfinput type="hidden" name="returnAction" value="ajaxGrid">
			<cfinput type="hidden" name="action" value="saveGridUpdate">
			<cfinput type="hidden" name="enteredby" value="#enteredby#">
			<cfinput type="hidden" name="accn" value="#accn#">
			<cfinput type="hidden" name="colln" value="#colln#">
			<cfgrid attributeCollection="#args#">
				<cfgridcolumn name="collection_object_id" select="no" href="/DataEntry.cfm?action=edit&ImAGod=yes"
					hrefkey="collection_object_id" target="_blank" header="Key">
				<cfloop list="#ColNameList#" index="thisName">
					<cfgridcolumn name="#thisName#">
				</cfloop>
			</cfgrid>
		</cfform>
	</cfoutput>
</cfif>
<!-------------------------------------------------------->
<cfif action IS "nothing">
	<cfoutput>
		<cfquery name="ctAccn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				accn
			from
				bulkloader
			group by
				accn
			order by
				accn
		</cfquery>
		<cfquery name="ctColln" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				institution_acronym || ':' || collection_cde colln
			from
				bulkloader
			group by
				institution_acronym || ':' || collection_cde
			order by institution_acronym || ':' || collection_cde
		</cfquery>
		<cfquery name="ctEnteredby" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				enteredby
			from
				bulkloader
			group by
				enteredby
			order by
				enteredby
		</cfquery>
		<table>
			<tr>
				<td width="50%">
					<form name="f" method="post" action="browseBulk.cfm">
					<table>
						<tr>
							<td align="center">
								<input type="hidden" name="action" value="viewTable" />
								<label for="enteredby">Entered By</label>
								<select name="enteredby" multiple="multiple" size="12" id="enteredby">
									<option value="" selected="selected">All</option>
									<cfloop query="ctEnteredby">
										<option value="'#enteredby#'">#enteredby#</option>
									</cfloop>
								</select>
							</td>
							<td align="center">
								<label for="accn">Accession</label>
								<select name="accn" multiple="multiple" size="12" id="accn">
									<option value="" selected>All</option>
									<cfloop query="ctAccn">
										<option value="'#accn#'">#accn#</option>
									</cfloop>
								</select>
							</td>
							<td align="center">
								<label for="colln">Collection</label>
								<select name="colln" multiple="multiple" size="12" id="colln">
									<option value="" selected>All</option>
									<cfloop query="ctColln">
										<option value="'#colln#'">#colln#</option>
									</cfloop>
								</select>
							</td>
						</tr>
						<tr>
							<td colspan="2">
								<input type="button" value="JAVA grid" class="lnkBtn" onclick="f.action.value='viewTable';f.submit();">
					 			<input type="button" value="SQL" class="lnkBtn" onclick="f.action.value='sqlTab';f.submit();">
								<input type="button" value="AJAX grid" class="lnkBtn" onclick="f.action.value='ajaxGrid';f.submit();">
							</td>
						</tr>
					</table>
					</form>
				</td>
				<td>
					<div style="border:1px solid green;margin-left:5em;padding:1em;">
						This form provides access to data in table bulkloader. Data may enter bulkloader from the various
						bulkloader applications or from the data entry screens.
						<br>Collections managers may set loaded=NULL to mark records to load.
						<br>Data Entry personnell may not NULL loaded, but may alter any other data in their own records.
						<br>
						Pick any, all, or none of enteredby agent, accession, or collection to view or edit data.
						<br>
						<ul>
							<li>
								<strong>Edit in JAVA grid</strong>
								<br>Opens a JAVA applet. Click headers to sort. You must click the button to save.
								Unhappy in some browsers. Copy/Paste from non-Java apps disallowed by Java.
							</li>
							<li>
								<strong>Edit in SQL</strong>
								<br>Allows mass updates based on existing values. Will only load 500 records at one time.
								Not for the timid.
							</li>
							<li>
								<strong>Edit in AJAX grid</strong>
								<br>Opens an AJAX table. Click headers to sort. Drag columns. Doubleclick cells to edit.
								Saves automatically on change. Slow to load. May occasionally not actually save changes;
								force-reload to confirm.
							</li>
						</ul>
					</div>
				</td>
			</tr>
		</table>
	</cfoutput>
</cfif>
<!----------------------------------------------------------->
<cfif action is "runSQLUp">
	<cfoutput>
		<cfif not isdefined("uc1") or not isdefined("uv1") or len(uc1) is 0 or len(uv1) is 0>
			Not enough information. <cfabort>
		</cfif>
		<cfif uv1 is "NULL">
	        <cfset sql = "update bulkloader set #uc1# = NULL where 1=1">
	    <cfelse>
	        <cfset sql = "update bulkloader set #uc1# = '#uv1#' where 1=1">
	    </cfif>
		<cfif isdefined("enteredby") and len(enteredby) gt 0>
			<cfset sql = "#sql# AND enteredby IN (#enteredby#)">
		</cfif>
		<cfif isdefined("accn") and len(accn) gt 0>
			<cfset sql = "#sql# AND accn IN (#accn#)">
		</cfif>
		<cfif isdefined("colln") and len(colln) gt 0>
			<cfset sql = "#sql# AND institution_acronym || ':' || collection_cde IN (#colln#)">
		</cfif>
		<cfif isdefined("c1") and len(c1) gt 0 and isdefined("op1") and len(op1) gt 0 and isdefined("v1") and len(v1) gt 0>
			<cfset sql = "#sql# AND #c1# #op1# ">
			<cfif op1 is "=">
				<cfset sql = "#sql# '#v1#'">
			<cfelseif op1 is "like">
				<cfset sql = "#sql# '%#v1#%'">
			<cfelseif op1 is "in">
				<cfset sql = "#sql# ('#replace(v1,",","','","all")#')">
			<cfelseif op1 is "between">
				<cfset dash = find("-",v1)>
				<cfset f = left(v1,dash-1)>
				<cfset t = mid(v1,dash+1,len(v1))>
				<cfset sql = "#sql# #f# and #t# ">
			</cfif>
		</cfif>
		<cfif isdefined("c2") and len(c2) gt 0 and isdefined("op2") and len(op2) gt 0 and isdefined("v2") and len(v2) gt 0>
			<cfset sql = "#sql# AND #c2# #op2# ">
			<cfif op2 is "=">
				<cfset sql = "#sql# '#v2#'">
			<cfelseif op2 is "like">
				<cfset sql = "#sql# '%#v2#%'">
			<cfelseif op2 is "in">
				<cfset sql = "#sql# ('#replace(v2,",","','","all")#')">
			<cfelseif op2 is "between">
				<cfset dash = find("-",v2)>
				<cfset f = left(v2,dash-1)>
				<cfset t = mid(v2,dash+1,len(v2))>
				<cfset sql = "#sql# #f# and #t# ">
			</cfif>
		</cfif>
		<cfif isdefined("c3") and len(c3) gt 0 and isdefined("op3") and len(op3) gt 0 and isdefined("v3") and len(v3) gt 0>
			<cfset sql = "#sql# AND #c3# #op3# ">
			<cfif #op3# is "=">
				<cfset sql = "#sql# '#v3#'">
			<cfelseif op3 is "like">
				<cfset sql = "#sql# '%#v3#%'">
			<cfelseif op3 is "in">
				<cfset sql = "#sql# ('#replace(v3,",","','","all")#')">
			<cfelseif op3 is "between">
				<cfset dash = find("-",v3)>
				<cfset f = left(v3,dash-1)>
				<cfset t = mid(v3,dash+1,len(v3))>
				<cfset sql = "#sql# #f# and #t# ">
			</cfif>
		</cfif>
		<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			#preservesinglequotes(sql)#
		</cfquery>
		<cfset rUrl="browseBulk.cfm?action=sqlTab&enteredby=#enteredby#">
		<cfif isdefined("accn") and len(accn) gt 0>
			<cfset rUrl="#rUrl#&accn=#accn#">
		</cfif>
		<cfif isdefined("colln") and len(colln) gt 0>
			<cfset rUrl = "#rUrl#&colln=#colln#">
		</cfif>
		<cfif isdefined("c1") and len(c1) gt 0 and isdefined("op1") and len(op1) gt 0 and isdefined("v1") and len(v1) gt 0>
			<cfset rUrl="#rUrl#&c1=#c1#&op1=#op1#&v1=#v1#">
		</cfif>
		<cfif isdefined("c2") and len(c2) gt 0 and isdefined("op2") and len(op2) gt 0 and isdefined("v2") and len(v2) gt 0>
			<cfset rUrl="#rUrl#&c2=#c2#&op2=#op2#&v2=#v2#">
		</cfif>
		<cfif isdefined("c3") and len(c3) gt 0 and isdefined("op3") and len(op3) gt 0 and isdefined("v3") and len(v3) gt 0>
			<cfset rUrl="#rUrl#&c3=#c3#&op3=#op3#&v3=#v3#">
		</cfif>
		<cflocation url="#rUrl#" addtoken="false">
	</cfoutput>
</cfif>
<!----------------------------------------------------------->
<cfif action is "sqlTab">
<cfoutput>
	<cfset sql = "select * from bulkloader where 1=1">
	<cfif isdefined("enteredby") and len(enteredby) gt 0>
		<cfset sql = "#sql# AND enteredby IN (#enteredby#)">
	</cfif>
	<cfif isdefined("accn") and len(accn) gt 0>
		<cfset sql = "#sql# AND accn IN (#accn#)">
	</cfif>
	<cfif isdefined("colln") and len(colln) gt 0>
		<cfset sql = "#sql# AND institution_acronym || ':' || collection_cde IN (#colln#)">
	</cfif>
	<cfif isdefined("c1") and len(c1) gt 0 and isdefined("op1") and len(op1) gt 0 and isdefined("v1") and len(v1) gt 0>
		<cfset sql = "#sql# AND #c1# #op1# ">
		<cfif #op1# is "=">
			<cfset sql = "#sql# '#v1#'">
		<cfelseif op1 is "like">
			<cfset sql = "#sql# '%#v1#%'">
		<cfelseif op1 is "in">
			<cfset sql = "#sql# ('#replace(v1,",","','","all")#')">
		<cfelseif op1 is "between">
			<cfset dash = find("-",v1)>
			<cfset f = left(v1,dash-1)>
			<cfset t = mid(v1,dash+1,len(v1))>
			<cfset sql = "#sql# #f# and #t# ">
		</cfif>
	</cfif>
	<cfif isdefined("c2") and len(c2) gt 0 and isdefined("op2") and len(op2) gt 0 and isdefined("v2") and len(v2) gt 0>
		<cfset sql = "#sql# AND #c2# #op2# ">
		<cfif #op2# is "=">
			<cfset sql = "#sql# '#v2#'">
		<cfelseif op2 is "like">
			<cfset sql = "#sql# '%#v2#%'">
		<cfelseif op2 is "in">
			<cfset sql = "#sql# ('#replace(v2,",","','","all")#')">
		<cfelseif op2 is "between">
			<cfset dash = find("-",v2)>
			<cfset f = left(v2,dash-1)>
			<cfset t = mid(v2,dash+1,len(v2))>
			<cfset sql = "#sql# #f# and #t# ">
		</cfif>
	</cfif>
	<cfif isdefined("c3") and len(c3) gt 0 and isdefined("op3") and len(op3) gt 0 and isdefined("v3") and len(v3) gt 0>
		<cfset sql = "#sql# AND #c3# #op3# ">
		<cfif op3 is "=">
			<cfset sql = "#sql# '#v3#'">
		<cfelseif op3 is "like">
			<cfset sql = "#sql# '%#v3#%'">
		<cfelseif op3 is "in">
			<cfset sql = "#sql# ('#replace(v3,",","','","all")#')">
		<cfelseif op3 is "between">
			<cfset dash = find("-",v3)>
			<cfset f = left(v3,dash-1)>
			<cfset t = mid(v3,dash+1,len(v3))>
			<cfset sql = "#sql# #f# and #t# ">
		</cfif>
	</cfif>
	<cfset sql="#sql# and rownum<500">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		#preservesinglequotes(sql)#
	</cfquery>
	<cfquery name="cNames" datasource="uam_god">
		select column_name from user_tab_cols where table_name='BULKLOADER' and column_name not like '%$%'
		order by internal_column_id
	</cfquery>
	<div style="background-color:##C0C0C0; font-size:smaller;">
		Use the top form to filter the table to the records you are interested in. All values are ANDed together. Everything is case-sensitive.
		You must provide all three values for the filter to apply.
		<br>Then use the bottom form to update them. Values are case sensitive. There is no control here - you can easily update such
		that records will never load. Don't.
		<br>Updates will affect only the records visible in the table below, and will affect ALL records in the table in the same way.
		<br>Click the table headers to sort.
		<br>
		Operator values:
		<ul>
			<li>=: single case-sensitive exact match ("something"-->"<strong>something</strong>")</li>
			<li>like: partial string match ("somet" --> "<strong>somet</strong>hing", "got<strong>somet</strong>oo", "<strong>somet</strong>ime", etc.)</li>
			<li>in: comma-delimited list ("one,two" --> "<strong>one</strong>" OR "<strong>two</strong>")</li>
			<li>between: range ("1-5" --> "1,2...5") Works only when ALL values are numeric (not only those you see in the current table)</li>
		</ul>
		<p>
			NOTE: This form will load at most 500 records. Your browser will thank me.
		</p>
		<p>
			Set LOADED to DELETE to delete.
		</p>
	</div>
	<form name="filter" method="post" action="browseBulk.cfm">
		<input type="hidden" name="action" value="sqlTab">
		<input type="hidden" name="enteredby" value="#enteredby#">
		<cfif isdefined("accn") and len(accn) gt 0>
			<input type="hidden" name="accn" value="#accn#">
		</cfif>
		<cfif isdefined("colln") and len(colln) gt 0>
			<input type="hidden" name="colln" value="#colln#">
		</cfif>
		<h2>Create Filter:</h2>
		<table border>
			<tr>
				<th>
					Column
				</th>
				<th>Operator</th>
				<th>Value</th>
			</tr>
			<tr>
				<td>
					<select name="c1" size="1">
						<option value=""></option>
						<cfloop query="cNames">
							<option
								<cfif isdefined("c1") and c1 is column_name> selected="selected" </cfif>value="#column_name#">#column_name#</option>
						</cfloop>
					</select>
				</td>
				<td>
					<select name="op1" size="1">
						<option <cfif isdefined("op1") and op1 is "="> selected="selected" </cfif>value="=">=</option>
						<option <cfif isdefined("op1") and op1 is "like"> selected="selected" </cfif>value="like">like</option>
						<option <cfif isdefined("op1") and op1 is "in"> selected="selected" </cfif>value="in">in</option>
						<option <cfif isdefined("op1") and op1 is "between"> selected="selected" </cfif>value="between">between</option>
					</select>
				</td>
				<td>
					<input type="text" name="v1" <cfif isdefined("v1")> value="#v1#"</cfif> size="50">
				</td>
			</tr>
			<tr>
				<td>
					<select name="c2" size="1">
						<option value=""></option>
						<cfloop query="cNames">
							<option
								<cfif isdefined("c2") and #c2# is #column_name#> selected="selected" </cfif>value="#column_name#">#column_name#</option>
						</cfloop>
					</select>
				</td>
				<td>
					<select name="op2" size="1">
						<option <cfif isdefined("op2") and op2 is "="> selected="selected" </cfif>value="=">=</option>
						<option <cfif isdefined("op2") and op2 is "like"> selected="selected" </cfif>value="like">like</option>
						<option <cfif isdefined("op2") and op2 is "in"> selected="selected" </cfif>value="in">in</option>
						<option <cfif isdefined("op2") and op2 is "between"> selected="selected" </cfif>value="between">between</option>
					</select>
				</td>
				<td>
					<input type="text" name="v2" <cfif isdefined("v2")> value="#v2#"</cfif> size="50">
				</td>
			</tr>
			<tr>
				<td>
					<select name="c3" size="1">
						<option value=""></option>
						<cfloop query="cNames">
							<option
								<cfif isdefined("c3") and #c3# is #column_name#> selected="selected" </cfif>value="#column_name#">#column_name#</option>
						</cfloop>
					</select>
				</td>
				<td>
					<select name="op3" size="1">
						<option <cfif isdefined("op3") and op3 is "="> selected="selected" </cfif>value="=">=</option>
						<option <cfif isdefined("op3") and op3 is "like"> selected="selected" </cfif>value="like">like</option>
						<option <cfif isdefined("op3") and op3 is "in"> selected="selected" </cfif>value="in">in</option>
						<option <cfif isdefined("op3") and op3 is "between"> selected="selected" </cfif>value="between">between</option>
					</select>
				</td>
				<td>
					<input type="text" name="v3" <cfif isdefined("v3")> value="#v3#"</cfif> size="50">
				</td>
			</tr>
			<tr>
				<td colspan="3">
					<input type="submit" value="Filter">
				</td>
			</tr>
		</table>
	</form>
	<h2>Update data in table below:</h2>
	<form name="up" method="post" action="browseBulk.cfm">
		<input type="hidden" name="action" value="runSQLUp">
		<input type="hidden" name="enteredby" value="#enteredby#">
		<cfif isdefined("accn") and len(accn) gt 0>
			<input type="hidden" name="accn" value="#accn#">
		</cfif>
		<cfif isdefined("colln") and len(colln) gt 0>
			<input type="hidden" name="colln" value="#colln#">
		</cfif>
		<cfif isdefined("c1") and len(#c1#) gt 0 and isdefined("op1") and len(#op1#) gt 0 and isdefined("v1") and len(#v1#) gt 0>
			<input type="hidden" name="c1" value="#c1#">
			<input type="hidden" name="op1" value="#op1#">
			<input type="hidden" name="v1" value="#v1#">
		</cfif>
		<cfif isdefined("c2") and len(#c2#) gt 0 and isdefined("op2") and len(#op2#) gt 0 and isdefined("v2") and len(#v2#) gt 0>
			<input type="hidden" name="c2" value="#c2#">
			<input type="hidden" name="op2" value="#op2#">
			<input type="hidden" name="v2" value="#v2#">
		</cfif>
		<cfif isdefined("c3") and len(#c3#) gt 0 and isdefined("op3") and len(#op3#) gt 0 and isdefined("v3") and len(#v3#) gt 0>
			<input type="hidden" name="c3" value="#c3#">
			<input type="hidden" name="op3" value="#op3#">
			<input type="hidden" name="v3" value="#v3#">
		</cfif>
		<table border>
			<tr>
				<th>
					Column
				</th>
				<th>Update To</th>
				<th>Value</th>
			</tr>
			<tr>
				<td>
					<select name="uc1" size="1">
						<option value=""></option>
						<cfloop query="cNames">
							<option value="#column_name#">#column_name#</option>
						</cfloop>
					</select>
				</td>
				<td>
					-->
				</td>
				<td>
					<input type="text" name="uv1" id="uv1" size="50">
                    <span class="infoLink" onclick="document.getElementById('uv1').value='NULL';">NULL</span>
				</td>
			</tr>
			<tr>
				<td colspan="3">
					<input type="submit" value="Update">
				</td>
			</tr>
		</table>
	</form>

	<div class="blTabDiv">
		<table border id="t" class="sortable">
			<tr>
			<cfloop query="cNames">
				<th>#column_name#</th>
			</cfloop>
			<cfloop query="data">
				<tr>
				<cfquery name="thisRec" dbtype="query">
					select * from data where collection_object_id=#data.collection_object_id#
				</cfquery>
				<cfloop query="cNames">
					<cfset thisData = evaluate("thisRec." & cNames.column_name)>
					<td>#thisData#</td>
				</cfloop>
				</tr>
			</cfloop>
			</tr>
		</table>
	</div>
</cfoutput>
</cfif>
<!-------------------------->
<cfif #action# is "saveGridUpdate">
<cfoutput>
<cfquery name="cNames" datasource="uam_god">
	select column_name from user_tab_cols where table_name='BULKLOADER' and column_name not like '%$%'
</cfquery>
<cfset ColNameList = valuelist(cNames.column_name)>
<cfset GridName = "blGrid">
<cfset numRows = #ArrayLen(form.blGrid.rowstatus.action)#>
<p></p>there are	#numRows# rows updated
<!--- loop for each record --->
<cfloop from="1" to="#numRows#" index="i">
	<!--- and for each column --->
	<cfset thisCollObjId = evaluate("Form.#GridName#.collection_object_id[#i#]")>
	<cfset sql ='update BULKLOADER SET collection_object_id = #thisCollObjId#'>
	<cfloop index="ColName" list="#ColNameList#">
		<cfset oldValue = evaluate("Form.#GridName#.original.#ColName#[#i#]")>
		<cfset newValue = evaluate("Form.#GridName#.#ColName#[#i#]")>
		<cfif #oldValue# neq #newValue#>
			<cfset sql = "#sql#, #ColName# = '#newValue#'">
		</cfif>
	</cfloop>

		<cfset sql ="#sql# WHERE collection_object_id = #thisCollObjId#">
	<cfquery name="up" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		#preservesinglequotes(sql)#
	</cfquery>
</cfloop>
<cflocation url="browseBulk.cfm?action=#returnAction#&enteredby=#enteredby#&accn=#accn#&colln=#colln#">
</cfoutput>
</cfif>
<!-------------------------------------------------------------->
<cfif #action# is "upBulk">
<cfoutput>
	<cfif len(#loaded#) gt 0 and
		len(#column_name#) gt 0 and
		len(#tValue#) gt 0>
		<cfset sql="UPDATE bulkloader SET LOADED = ">
		<cfif #loaded# is "NULL">
			<cfset sql="#sql# NULL">
		<cfelse>
			<cfset sql="#sql# '#loaded#'">
		</cfif>
			<cfset sql="#sql# WHERE #column_name#	=
			'#trim(tValue)#'">
		<cfif len(enteredby) gt 0>
			<cfset sql = "#sql# AND enteredby IN (#enteredby#)">
		</cfif>
		<cfif len(accn) gt 0>
			<cfset sql = "#sql# AND accn IN (#accn#)">
		</cfif>
		<cfif isdefined("colln") and len(colln) gt 0>
			<cfset sql = "#sql# AND institution_acronym || ':' || collection_cde IN (#colln#)">
		</cfif>
			#preservesinglequotes(sql)#
		<!---

		<cfabort>
		--->
		<cfquery name="upBulk" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			#preservesinglequotes(sql)#
		</cfquery>
	</cfif>

<cflocation url="browseBulk.cfm?action=viewTable&enteredby=#enteredby#&accn=#accn#&colln=#colln#">

</cfoutput>
</cfif>
<!-------------------------------------------------------------->
<cfif #action# is "viewTable">
<cfoutput>
<cfset sql = "select * from bulkloader where 1=1">
<cfif len(enteredby) gt 0>
	<cfset sql = "#sql# AND enteredby IN (#enteredby#)">
</cfif>
<cfif len(accn) gt 0>
	<cfset sql = "#sql# AND accn IN (#accn#)">
</cfif>

	<cfif isdefined("colln") and len(colln) gt 0>
		<cfset sql = "#sql# AND institution_acronym || ':' || collection_cde IN (#colln#)">
	</cfif>
<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	#preservesinglequotes(sql)#
</cfquery>
<cfquery name="cNames" datasource="uam_god">
	select column_name from user_tab_cols where table_name='BULKLOADER' and column_name not like '%$%'
	order by internal_column_id
</cfquery>
<!---
<div style="background-color:##FFFFCC;">
Roll yer own:
<cfset columnList = "SPEC_LOCALITY,HIGHER_GEOG,ENTEREDBY,LOADED,ACCN,OTHER_ID_NUM_5">

<form name="bulkStuff" method="post" action="browseBulk.cfm">
	<input type="hidden" name="action" value="upBulk" />
	<input type="hidden" name="enteredby" value="#enteredby#" />
	<input type="hidden" name="accn" value="#accn#" />
	UPDATE bulkloader SET LOADED =
	<select name="loaded" size="1">
		<option value="NULL">NULL</option>
		<option value="FLAGGED BY BULKLOADER EDITOR">FLAGGED BY BULKLOADER EDITOR</option>
		<option value="MARK FOR DELETION">MARK FOR DELETION</option>
	</select>
	<br />WHERE
	<select name="column_name" size="1">
		<CFLOOP list="#columnList#" index="i">
			<option value="#i#">#i#</option>
		</CFLOOP>
	</select>
	= TRIM(
	<input type="text" name="tValue" size="50" />)
	<br />
	<input type="submit"
				value="Update All Matches"
				class="savBtn"
				onmouseover="this.className='savBtn btnhov'"
				onmouseout="this.className='savBtn'">
</form>
</div>
---->
<hr /><cfset ColNameList = valuelist(cNames.column_name)>
<cfset ColNameList = replace(ColNameList,"COLLECTION_OBJECT_ID","","all")>
<!---
<cfset ColNameList = replace(ColNameList,"LOADED","","all")>
<cfset ColNameList = replace(ColNameList,"ENTEREDBY","","all")>
--->
<hr />There are #data.recordcount# records in this view.
<br>
<cfform method="post" action="browseBulk.cfm">
	<cfinput type="hidden" name="action" value="saveGridUpdate">
	<cfinput type="hidden" name="enteredby" value="#enteredby#">
	<cfinput type="hidden" name="accn" value="#accn#">
	<cfinput type="hidden" name="colln" value="#colln#">
	<cfinput type="hidden" name="returnAction" value="viewTable">
	<cfgrid query="data"  name="blGrid" width="1200" height="400" selectmode="edit">
		<cfgridcolumn name="collection_object_id" select="no" href="/DataEntry.cfm?action=edit&ImAGod=yes" hrefkey="collection_object_id" target="_blank">
		<!----
		<cfgridcolumn name="loaded" select="yes">
		<cfgridcolumn name="ENTEREDBY" select="yes">
		---->
		<cfloop list="#ColNameList#" index="thisName">
			<cfgridcolumn name="#thisName#">
		</cfloop>
	</cfgrid>
	<br><cfinput type="submit" name="save" value="Save Changes In Grid">
	<br><a href="browseBulk.cfm?action=loadAll&enteredby=#enteredby#&accn=#accn#&colln=#colln#&returnAction=viewTable">Mark all to load</a>
	<br><a href="browseBulk.cfm?action=download&enteredby=#enteredby#&accn=#accn#&colln=#colln#">Download CSV</a>
	<br>Set LOADED to DELETE to delete.
</cfform>

</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">
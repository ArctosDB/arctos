<cfinclude template="/includes/_header.cfm">
<script type='text/javascript' src='/ajax/core/engine.js'></script>
	<script type='text/javascript' src='/ajax/core/util.js'></script>
	<script type='text/javascript' src='/ajax/core/settings.js'></script>
	<cfinclude template="/ajax/core/cfajax.cfm">

<script>
	function get_sql_value(id,returnID){
		
		var sql = document.getElementById(id).value;
		alert(sql);
		DWREngine._execute(_cfscriptLocation, null,'get_sql_result',sql, returnID, get_sql_value_success);
	}
	function get_sql_value_success (result) {
		
		//alert(result);
		var count = result[0].RECORDCOUNT;
		var value = result[0].RESULT;
		var id = result[0].ID;
		var pf = document.getElementById(id);
		//alert(count);
		//alert(value);
		if (count == 0) {
			pf.value='';
			alert(value);
		} else {
			
			pf.value=value;
			}
	}

	function concatMe() {
		var p = document.getElementById('string_prefix').value;
		var n = document.getElementById('next_value').value;
		var s = document.getElementById('string_suffix').value;
		var r = document.getElementById('string');
		var rs = p + n + s;
		r.value=rs;
		
	}
</script>
<cfif #action# is "nothing">
	<cfquery name="mS" datasource="#Application.uam_dbo#">
		select * from string_series
	</cfquery>
</cfif>
<!---------------------------------------------------------------------------->
<cfif #action# is "new">
	<form method="post" action="string_series.cfm">
		<input type="hidden" name="action" value="saveNew">
		<table border="1" class="newRec">
			<tr>
				<td>
					<label for="string_name">Name</label>
					<input type="text" name="string_name" id="string_name" class="reqdCle">
				</td>
				<td>
					<label for="string_description">Description</label>
					<textarea name="string_description" id="string_description" rows="3" cols="30"></textarea>
				</td>
				<td rowspan="99">
					SQL statements must:
					<ul>
						<li>Return one record</li>
						<li>Alias that record as "value"</li>
						<li>NOT include closing parentheses</li>
					</ul>
					Examples:
					<ul>
					<li>
						select max(cat_num) value from cataloged_item
					</li>
					select max(accn_num) value from accn,trans where accn_num_prefix='
					</ul>
					
				</td>
			</tr>
			<tr>
				<td>
					<label for="string_prefix">Prefix</label>
					<input type="text" name="string_prefix" id="string_prefix">
				</td>
				<td>
					<label for="get_prefix_sql">Prefix SQL</label>
					<textarea name="get_prefix_sql" id="get_prefix_sql" rows="3" cols="30"></textarea>
					<input type="button" value="test" onClick="get_sql_value('get_prefix_sql','string_prefix');">
				</td>
			</tr>
			<tr>
				<td>
					<label for="next_value">Next Value</label>
					<input type="text" name="next_value" id="next_value">
				</td>
				<td>
					<label for="get_next_sql">Next Value SQL</label>
					<textarea name="get_next_sql" id="get_next_sql" rows="3" cols="30"></textarea>
					<input type="button" value="test" onClick="get_sql_value('get_next_sql','next_value');">
				</td>
			</tr>
			<tr>
				<td>
					<label for="string_suffix">Suffix</label>
					<input type="text" name="string_suffix" id="string_suffix">
				</td>
				<td>
					<label for="get_suffix_sql">Suffix SQL</label>
					<textarea name="get_suffix_sql" id="get_suffix_sql" rows="3" cols="30"></textarea>
				</td>
			</tr>
			<tr>
				<td>
					<label for="string">Final Product</label>
					<input type="text" size="60" readonly="yes" id="string" name="string">
					<input type="button" value="Test" onClick="concatMe();">
				
				</td>
			</tr>
			<tr>
				<td>
					<input type="submit" value="Create">
				</td>
			</tr>
		</table>
	</form>
	
	select min(agent_id) value from agent
</cfif>
<cfif #action# is "saveNew">
	<cfset sql = "
	INSERT INTO string_series (
	string_name,
	next_value,
	string">
	<cfif len(#string_description#) gt 0>
		<cfset sql = "#sql#,string_description">
	</cfif>
	<cfif len(#string_prefix#) gt 0>
		<cfset sql = "#sql#,string_prefix">
	</cfif>
	<cfif len(#get_prefix_sql#) gt 0>
		<cfset sql = "#sql#,get_prefix_sql">
	</cfif>
	<cfif len(#get_next_sql#) gt 0>
		<cfset sql = "#sql#,get_next_sql">
	</cfif>
	<cfif len(#string_suffix#) gt 0>
		<cfset sql = "#sql#,string_suffix">
	</cfif>
	<cfif len(#get_suffix_sql#) gt 0>
		<cfset sql = "#sql#,get_suffix_sql">
	</cfif>
	<cfset sql = "#sql# ) values (
		'#string_name#',
		#next_value#,
		'#string#'">
	<cfif len(#string_description#) gt 0>
		<cfset sql = "#sql#,'#string_description#'">
	</cfif>
	<cfif len(#string_prefix#) gt 0>
		<cfset sql = "#sql#,'#string_prefix#'">
	</cfif>
	<cfif len(#get_prefix_sql#) gt 0>
		<cfset sql = "#sql#,'#get_prefix_sql#'">
	</cfif>
	<cfif len(#get_next_sql#) gt 0>
		<cfset sql = "#sql#,'#get_next_sql#'">
	</cfif>
	<cfif len(#string_suffix#) gt 0>
		<cfset sql = "#sql#,'#string_suffix#'">
	</cfif>
	<cfif len(#get_suffix_sql#) gt 0>
		<cfset sql = "#sql#,'#get_suffix_sql#'">
	</cfif>
	<cfset sql = "#sql#)">
	<cfoutput>
		<cfquery name="i" datasource="#Application.uam_dbo#">
			#preservesinglequotes(sql)#
		</cfquery>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">
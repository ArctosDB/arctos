<cfinclude template="/includes/_header.cfm">
<script type='text/javascript' language="javascript" src='/fix/jtable/jquery.jtable.min.js'></script>
<link rel="stylesheet" title="lightcolor-blue"  href="/fix/jtable/themes/lightcolor/blue/jtable.min.css" type="text/css">
<script type="text/javascript">
    $(document).ready(function () {
        $('#jtdocdoc').jtable({
            title: 'Documentation',       
			paging: true, //Enable paging
            pageSize: 10, //Set page size (default: 10)
            sorting: true, //Enable sorting
            defaultSorting: 'GUID ASC', //Set default sorting
			columnResizable: true,
			multiSorting: true,
			columnSelectable: false,
			actions: {
                listAction: '/component/docs.cfc?method=listDocDoc',
				updateAction: '/component/docs.cfc?method=updateDocDoc',
 				createAction: '/component/docs.cfc?method=createDocDoc',
 				deleteAction: '/component/docs.cfc?method=deleteDocDoc',
            },
            fields:  {
				 SSRCH_FIELD_DOC_ID: {
                    key: true,
                    create: false,
                    edit: false,
                    list: false
                },
				CF_VARIABLE: {title: 'VARIABLE'},
				DISPLAY_TEXT: {title: 'DISPLAY'},
				CONTROLLED_VOCABULARY: {title: 'VOCABULARY'},
				DATA_TYPE: {title: 'TYPE'},
				DEFINITION: {
					title: 'DEFINITION',
					type: 'textarea'
				},
				DOCUMENTATION_LINK: {title: 'DOCUMENTATION_LINK'},
				SEARCH_HINT: {title: 'SEARCH_HINT'},
				PLACEHOLDER_TEXT: {title: 'PLACEHOLDER'},
				CATEGORY: {title: 'CATEGORY'},
				DISP_ORDER: {title: 'ORD'},
				SPECIMEN_RESULTS_COL: {title: 'SR'},
				SQL_ELEMENT: {title: 'SQL_ELEMENT'}
            }
        });

		$('#LoadRecordsButton').click(function (e) {
           e.preventDefault();
           $('#jtdocdoc').jtable('load', {
               CF_VARIABLE: $('#CF_VARIABLE').val()
           });
       });
       $('#jtdocdoc').jtable('load');
    });
</script>
<cfset title="form-field documentation"> 
<table border>
	<tr>
		<th>Column Name</th>
		<th>What's it do?</th>
	</tr>
	<tr>
		<td>VARIABLE</td>
		<td>Variable as used by Arctos applications, eg, in specimenresults mapurl. Must be lower case (to improve internal query performance - variable are not case-sensitive).</td>
	</tr>
	<tr>
		<td>TYPE</td>
		<td>"Human-readable" approximation of the datatype accepted by the variable, e.g., "comma-separated list of integers."</td>
	</tr>
	<tr>
		<td>DISPLAY</td>
		<td>"Field label" - "Catalog Number" - keep it short.</td>
	</tr>
	<tr>
		<td>VOCABULARY</td>
		<td>Either 1) controlling code table, name only - "ctage_class," OR 2) comma-separated list of values ("LIKE,IS"). Do not guess at this.</td>
	</tr>
	<tr>
		<td>PLACEHOLDER</td>
		<td>Very short snippet to display in the HTML5 "placeholder" element.</td>
	</tr>
	<tr>
		<td>SEARCH_HINT</td>
		<td>Short "how it works" useful for guiding search.</td>
	</tr>
	<tr>
		<td>SR</td>
		<td>Is the element available as a column in specimenresults? Don't guess at this. 0 or 1</td>
	</tr>
	<tr>
		<td>ORD</td>
		<td>Order (left to right) in which to display columns on specimenresults.</td>
	</tr>
	<tr>
		<td>CATEGORY</td>
		<td>Category on specimen results. Don't guess at this.</td>
	</tr>
	<tr>
		<td>SQL_ELEMENT</td>
		<td>SQL to use in building dynamic queries. Don't guess at this.</td>
	</tr>
	<tr>
		<td>DEFINITION</td>
		<td>Short-ish definition suitable for popup/tooltip documentation</td>
	</tr>
	<tr>
		<td>DOCUMENTATION_LINK</td>
		<td>Link to further documentation, probably on http://arctosdb.org/.</td>
	</tr>
</table>

<hr>Filter records:
<div class="filtering">
    <form>
        CF_VARIABLE: <input type="text" name="CF_VARIABLE" id="CF_VARIABLE" />
        <button type="submit" id="LoadRecordsButton">Search</button>
    </form>
</div>
<div id="jtdocdoc"></div>
<!----------------------------
<cfif action is "oldform">
<script src="/includes/sorttable.js"></script>

	<cfoutput>
	
	
	
	<hr>Add a row
	

<form method="post" action="field_documentation.cfm">
	<input type="hidden" name="action" value="newRow">
	<label for="CF_VARIABLE">CF_VARIABLE</label>
	<input type="text" name="CF_VARIABLE" size="80">
	<label for="DEFINITION">DEFINITION</label>
	<input type="text" name="DEFINITION" size="80">
	<label for="CONTROLLED_VOCABULARY">CONTROLLED_VOCABULARY</label>
	<input type="text" name="CONTROLLED_VOCABULARY" size="80">
	<label for="DOCUMENTATION_LINK">DOCUMENTATION_LINK</label>
	<input type="text" name="DOCUMENTATION_LINK" size="80">
	<label for="PLACEHOLDER_TEXT">PLACEHOLDER_TEXT</label>
	<input type="text" name="PLACEHOLDER_TEXT" size="80">
	<label for="SEARCH_HINT">SEARCH_HINT</label>
	<input type="text" name="SEARCH_HINT" size="80">
	<br><input type="submit" value="create">
</form>	
	<hr>
	
	
	<cfparam name="width" default="1200">
	<cfparam name="height" default="600">
	<cfparam name="pageSize" default="20">
Use this form to adjust the grid layout
<form name="x" method="post" action="field_documentation.cfm">
	<label for="width">width</label>
	<input type="text" name="width" value="#width#">
	<label for="height">height</label>
	<input type="text" name="height" value="#height#">
	<label for="pageSize">pageSize</label>
	<input type="text" name="pageSize" value="#pageSize#">
	<br>
	<input type="submit">
</form>
			
	<hr>		
		<cfquery name="cNames" datasource="uam_god">
			select column_name from user_tab_cols where lower(table_name)='ssrch_field_doc' order by internal_column_id
		</cfquery>
		<cfset ColNameList = valuelist(cNames.column_name)>
		<cfset ColNameList = replace(ColNameList,"SSRCH_FIELD_DOC_ID","","all")>
		<cfset args.width="#width#">
		<cfset args.height="#height#">
		<cfset args.stripeRows = true>
		<cfset args.selectColor = "##D9E8FB">
		<cfset args.selectmode = "edit">
		<cfset args.format="html">
		<cfset args.name="blGrid">
		<cfset args.pageSize="#pageSize#">
		<cfset args.onchange = "cfc:component.docs.editRecord({cfgridaction},{cfgridrow},{cfgridchanged})">
		<cfset args.bind="cfc:component.docs.getPage({cfgridpage},{cfgridpagesize},{cfgridsortcolumn},{cfgridsortdirection})">
		<cfset args.name="blGrid">
		<cfform method="post" action="field_documentation.cfm">
			<cfinput type="hidden" name="returnAction" value="ajaxGrid">
			<cfinput type="hidden" name="action" value="saveGridUpdate">
			<cfgrid attributeCollection="#args#">
				<cfloop list="#ColNameList#" index="thisName">
					<cfgridcolumn name="#thisName#">
				</cfloop>
			</cfgrid>
		</cfform>
		
		
		<!----
		
			<cfloop query="d">
				<tr>
					<td>
						<a href="field_documentation.cfm?action=edit&SSRCH_FIELD_DOC_ID=#SSRCH_FIELD_DOC_ID#">#CF_VARIABLE#</a>
					</td>
					<td>#display_name#</td>
					<td>#definition#</td>
					<td>#search_hint#</td>
					<td>#more_info#</td>
				</tr>
			</cfloop>
		</table>
		
		
		---->
	</cfoutput>
	
</cfif>


<cfif action is "newRow">
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into ssrch_field_doc
				(
					CF_VARIABLE,
					DEFINITION,
					CONTROLLED_VOCABULARY,
					DOCUMENTATION_LINK,
					PLACEHOLDER_TEXT,
					SEARCH_HINT
				) values (
					'#CF_VARIABLE#',
					'#DEFINITION#',
					'#CONTROLLED_VOCABULARY#',
					'#DOCUMENTATION_LINK#',
					'#PLACEHOLDER_TEXT#',
					'#SEARCH_HINT#'
				)
		</cfquery>
		
	
		<cflocation addtoken="false" url="field_documentation.cfm">
</cfif>
------------------------------>
<cfinclude template="/includes/_footer.cfm">
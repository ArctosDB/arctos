<cfinclude template="/includes/_header.cfm">

<cfif action is "integerizeOrder">
	<cfquery name="makeabiggap" datasource="uam_god">
			update ssrch_field_doc set disp_order=disp_order+10000 where DISP_ORDER is not null
	</cfquery>
	
	<cfquery name="o" datasource="uam_god">
		select disp_order from ssrch_field_doc where DISP_ORDER is not null order by DISP_ORDER
	</cfquery>
	<cfset n=1>
	<cfloop query="o">
		<cfquery name="u" datasource="uam_god">
			update ssrch_field_doc set disp_order=#n# where disp_order=#o.disp_order#
		</cfquery>
		<cfset n=n+1>
	</cfloop>
	<cflocation url="field_documentation.cfm" addtoken="false">
</cfif>


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
    		noDataAvailable: 'No data available!',
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
				CATEGORY: {title: 'CATEGORY',
					options: { 
						'': '-not specresults-',
						'locality': 'locality', 
						'specimen': 'specimen',
						'required': 'required',
						'sort': 'sort',
						'attribute': 'attribute',
						'curatorial': 'curatorial'
					}
				},
				DISP_ORDER: {title: 'ORD'},
				SPECIMEN_RESULTS_COL: {
					title: 'SR',
					type: 'radiobutton',
                    	options: { 
							'0': 'no',
                            '1': 'yes'
						}
				},
				SPECIMEN_QUERY_TERM: {
					title: 'SST',
					type: 'radiobutton',
                    	options: { 
							'0': 'no',
                            '1': 'yes'
						}
				},
				SQL_ELEMENT: {title: 'SQL_ELEMENT'}
            }
        });

		$('#LoadRecordsButton').click(function (e) {
           e.preventDefault();
           $('#jtdocdoc').jtable('load', {
               CF_VARIABLE: $('#CF_VARIABLE').val(),
               SPECIMEN_RESULTS_COL: $('#SPECIMEN_RESULTS_COL').val(),
               specimen_query_term: $('#specimen_query_term').val(),
               DISPLAY: $('#DISPLAY').val(),
               CATEGORY: $('#CATEGORY').val(),
               SQL_ELEMENT: $('#SQL_ELEMENT').val()
           });
       });
       $('#jtdocdoc').jtable('load');
    });
</script>
<cfset title="form-field documentation">

<!----
<a href="field_documentation.cfm?action=potential_problems">look for problems in these data</a>


<cfquery name="pp" datasource='cf_dbuser'>
	select * from ssrch_field_doc order by cf_variable
</cfquery>
<cfloop query="pp">

</cfloop>
--------->

<table border>
	<tr>
		<th>Column Name</th>
		<th>What's it do?</th>
	</tr>
	<tr>
		<td><strong>VARIABLE</strong></td>
		<td>Variable as used by Arctos applications, eg, in specimenresults mapurl. Will be forced to lower-case. 
		Must be a <a href="http://livedocs.adobe.com/coldfusion/8/Variables_03.html" target="_blank" class="external">valid ColdFusion variable string</a> and a 
		<a href="http://docs.oracle.com/cd/E11882_01/server.112/e41084/sql_elements008.htm" target="_blank" class="external">valid Oracle column alias</a>
		.
		</td>
		
		
		
		
	</tr>
	<tr>
		<td>TYPE</td>
		<td>"Human-readable" approximation of the datatype accepted by the variable, e.g., "comma-separated list of integers."</td>
	</tr>
	<tr>
		<td><strong>DISPLAY</strong></td>
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
		<td><strong>SR</strong> *</td>
		<td>Is the element available as a column in specimenresults?</td>
	</tr>
	<tr>
		<td>SST</td>
		<td>Is cf_variable available as a specimen results query term? Variable must be handled by /includes/SearchSQL</td>
	</tr>
	<tr>
		<td><strong>ORD</strong> *</td>
		<td>
			Order (left to right) in which to display columns on specimenresults (and elsewhere). 
			Use this to group terms within category, to keep related columns close together, etc.
			This is a unique number (not integer) and serves only to order things.
			<a href="field_documentation.cfm?action=integerizeOrder">click here to turn them into sequential integers</a>
		</td>
	</tr>
	<tr>
		<td>CATEGORY *</td>
		<td>Category on specimen results.</td>
	</tr>
	<tr>
		<td>SQL_ELEMENT *</td>
		<td>
			SQL to use in building dynamic queries. Don't guess at this. 
			<br>To pull from FLAT, use flatTableName.{flat column name} - this is case sensitive. Do not hard-code in flat or filtered_flat.
			<br>use any Oracle function
			<br>Only hard-code table names if you KNOW they'll be included in specimenresults. (Hint: none are.)
		
		</td>
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
* must be given as a set: provide all or none
<br> <strong>BOLD</strong> elements are required

<hr>Filter records:
<div class="filtering">
    <form>
        CF_VARIABLE: <input type="text" name="CF_VARIABLE" id="CF_VARIABLE" />
		 DISPLAY: <input type="text" name="DISPLAY" id="DISPLAY" />
		SR:
		<select name="SPECIMEN_RESULTS_COL" id="SPECIMEN_RESULTS_COL">
			<option value=""></option>
			<option value="1">yes</option>
			<option value="0">no</option>
		</select>
		SST:
		<select name="specimen_query_term" id="specimen_query_term">
			<option value=""></option>
			<option value="1">yes</option>
			<option value="0">no</option>
		</select>
		
		
		  CATEGORY:
		<select name="CATEGORY" id="CATEGORY">
			<option value=""></option>
			<option value="locality">locality</option>
			<option value="specimen">specimen</option>
			<option value="required">required</option>
			<option value="sort">sort</option>
			<option value="attribute">attribute</option>
			<option value="curatorial">curatorial</option>
		</select>
SQL_ELEMENT: <input type="text" name="SQL_ELEMENT" id="SQL_ELEMENT" />

<button type="reset" id="">clear form</button>

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
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
<!---------------------------------------------------------------------------------------------------------------------------->
<cfif action is "saveDragOrderEdits">
	<cfif isdefined("DRUGORDER") and len(DRUGORDER) gt 0>
		<cfquery name="makeabiggap" datasource="uam_god">
			update ssrch_field_doc set disp_order=disp_order+10000 where DISP_ORDER is not null
		</cfquery>
		<cfset n=1>
		<cfloop list="#DRUGORDER#" index="i">
			<cfset thisID=listgetat(i,2,"_")>
			<cfquery name="u" datasource="uam_god">
				update ssrch_field_doc set disp_order=#n# where SSRCH_FIELD_DOC_ID=#thisID#
			</cfquery>
			<cfset n=n+1>
		</cfloop>
	</cfif>
	All done.
	<p>
		<a href="field_documentation.cfm?action=dragsortorder">back to drag/sort</a>
	</p>
	<p>
		<a href="field_documentation.cfm">back to edit docs</a>
	</p>
	<p>
		<a href="field_documentation.cfm?action=integerizeOrder">integerize (this app leaves big gaps in sort order)</a>
	</p>
</cfif>
<!---------------------------------------------------------------------------------------------------------------------------->
<cfif action is "dragsortorder">
	<style>
		.dragger {
			cursor:move;
		}
		.locality {
			color:green;
		}
		.required {color:red;}
		.specimen {color:purple;}
	</style>
	<script>
		// copy this with create classification
		$(function() {
			$( "#sortable" ).sortable({
				handle: '.dragger'
			});
		});
		function submitForm() {
			var linkOrderData=$("#sortable").sortable('toArray').join(',');
			//console.log('linkOrderData: ' + linkOrderData);
			$( "#drugorder" ).val(linkOrderData);
			$( "#f1" ).submit();
		}
	</script>
	<cfoutput>
		Drag rows to sort specimen results columns.
		<br>
		Attributes are automagically generated and are ordered by name - they're not on here.
		SEX (the one hard-coded attribute) should probably remain near the bottom - other attributes will follow, in alphabetical order
		<br>Users will always see <span class="required">required</span> terms.
		<br>Users may turn any other option on or off as they wish.
		<br>GUID should remain at the top.
		<br>CustomID is hard-coded in after GUID.
		<br>Clowncolors are by CATEGORY - they should probably be grouped in some sort of logical order - "biggest" to "smallest" or related together or some
		indescribable combination thereof. Use the edit form to change CATEGORY.
		<p>
			<a href="field_documentation.cfm">back to edit docs</a> (or scroll to the bottom to save first)
		</p>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				SSRCH_FIELD_DOC_ID,
				CATEGORY,
				CF_VARIABLE,
				DISPLAY_TEXT,
				DISP_ORDER
			 from ssrch_field_doc where CATEGORY!='attribute' and DISP_ORDER is not null order by DISP_ORDER
		</cfquery>
		<form name="f1" id="f1" method="post" action="field_documentation.cfm">
			<input type="hidden" name="action" value="saveDragOrderEdits">
			<input type="hidden" name="drugorder" id="drugorder" value="">
			<table id="clastbl" border="1">
				<thead>
					<tr><th>Drag Handle</th><th>CF_VARIABLE</th><th>DISPLAY_TEXT</th><th>CATEGORY</th></tr>
				</thead>
				<tbody id="sortable">
					<cfloop query="d">
						<tr id="cell_#SSRCH_FIELD_DOC_ID#" class="#CATEGORY#">
							<td class="dragger">
								(drag row here)
							</td>
							<td>#CF_VARIABLE#</td>
							<td>#CATEGORY#</td>
							<td>#CF_VARIABLE#</td>
						</tr>
					</cfloop>
				</tbody>
			</table>
			<input type="button" onclick="submitForm();" value="save sort order">
		</form>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------------------------------->
<cfif action is "nothing">
	<script type='text/javascript' language="javascript" src='/includes/jtable/jquery.jtable.min.js'></script>
	<link rel="stylesheet" title="lightcolor-blue"  href="/includes/jtable/themes/lightcolor/blue/jtable.min.css" type="text/css">
	<style>
	form.jtable-dialog-form {
  width:800px;
}


div.jtable-input-field-container {
  float: left;
  margin: 0px 5px 5px 0;
  padding: 2px;
}
	</style>
	<script type="text/javascript">
	    $(document).ready(function () {
	        $('#jtdocdoc').jtable({
	            title: 'Documentation',
				paging: true, //Enable paging
	            pageSize: 20, //Set page size (default: 10)
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
					DOCUMENTATION_LINK: {title: 'DOCUMENTATION_LINK',
						type: 'textarea'},
					SEARCH_HINT: {
						title: 'SEARCH_HINT',
						type: 'textarea'
					},
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
					SQL_ELEMENT: {title: 'SQL_ELEMENT',
						type: 'textarea'}
	            }
	            /*
	            , formCreated: function(event, data) {
	            	data.form.children(':lt(11)').wrapAll('');
	            	data.form.children(':gt(0)').wrapAll('');
	            }
	            */
	        });
			$.extend({
				getUrlVars: function(){
					var vars = [], hash;
					var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
					for(var i = 0; i < hashes.length; i++){
						hash = hashes[i].split('=');
						vars.push(hash[0]);
						vars[hash[0]] = hash[1];
					}
					return vars;
				},
					getUrlVar: function(name){
					return $.getUrlVars()[name];
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
	               SQL_ELEMENT: $('#SQL_ELEMENT').val(),
	               DOCUMENTATION_LINK: $('#DOCUMENTATION_LINK').val()
	           });
	       });
	       if ($.getUrlVar("cf_variable") != null) {
				$('#CF_VARIABLE').val($.getUrlVar("cf_variable"));
				$('#jtdocdoc').jtable('load', {
	               CF_VARIABLE: $.getUrlVar("cf_variable")
	           });
	           // and scroll to loaded table....
			    $('html, body').animate({
			        scrollTop: $("#jtdocdoc").offset().top
			    }, 2000);
			    // edit?
			    if ($.getUrlVar("popEdit") != null) {
			    	console.log('open edit');
			    	    $(".jtable-edit-command-button button").trigger('click');
			    }
			} else {
	       		$('#jtdocdoc').jtable('load');
	       	}
	    });
	</script>
	<cfset title="form-field documentation">

	<div class="importantNotification">
		IMPORTANT! The data from this form dynamically build Arctos forms. Do not do anything here unless you KNOW what you're doing!
	</div>
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
			<td>Short "how it works" useful for guiding search, or URL (eg, of how-to page).</td>
		</tr>
		<tr>
			<td><strong>SR</strong> *</td>
			<td>Is the element available as a column in specimenresults?</td>
		</tr>
		<tr>
			<td><strong>SST</strong></td>
			<td>Is cf_variable available as a specimen results query term? Variable must be handled by /includes/SearchSQL</td>
		</tr>
		<tr>
			<td><strong>ORD</strong> *</td>
			<td>
				Order (left to right) in which to display columns on specimenresults (and elsewhere).
				Use this to group terms within category, to keep related columns close together, etc.
				This is a unique number (not integer) and serves only to order things.
				<br><a href="field_documentation.cfm?action=integerizeOrder">click here to turn them into sequential integers</a>
				<br><a href="field_documentation.cfm?action=dragsortorder">click here to drag/sort</a>
			</td>
		</tr>
		<tr>
			<td>CATEGORY *</td>
			<td>Category on specimen results. Removing required fields may break code; be careful.</td>
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
			<td>
				Link to further documentation, probably on
				<a href="http://handbook.arctosdb.org" target="_blank">http://handbook.arctosdb.org</a>.</td>
		</tr>
	</table>
	* must be given as a set: provide all or none
	<br> <strong>BOLD</strong> elements are required
	<p>
		NOTE: Do not change category=attribute records. They are periodically auto-generated from the relevant code tables and
		anything you do here will be lost. Add documentation directly to CTATTRIBUTE_TYPE.
	</p>
	<p>
		NOTE: ALL documentation now goes through this form. To create for example a link to the geography creation guidelines,
		<ul>
			<li>
				Enter the ID of the relevant element (ID of "helpLink" elements) into variable. This is key; everything
				else is fairly normal.
			</li>
			<li>Enter something clever into Display - perhaps "Geography Creation Guidelines"</li>
			<li>Enter a definition - "Click the link for documentation." works.</li>
			<li>Enter a link (probably to the Handbook).</li>
			<li>Set both SR and SST to NO</li>
			<li>Leave everything else blank</li>
		</ul>
	</p>
	<p>
		Admin tools <a href="/doc/checkHelpLinks.cfm">here</a>
	</p>
	<hr>Filter records:
	<div class="filtering">
	    <form>
	        CF_VARIABLE: <input type="text" name="CF_VARIABLE" id="CF_VARIABLE" />
	        DOC_LINK: <input type="text" name="DOCUMENTATION_LINK" id="DOCUMENTATION_LINK" />
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
	        <button type="submit" id="LoadRecordsButton">Search/Filter</button>
	    </form>
	</div>
	<div id="jtdocdoc"></div>
</cfif>
<cfinclude template="/includes/_footer.cfm">
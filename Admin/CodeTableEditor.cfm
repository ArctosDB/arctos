<cfinclude template="/includes/_header.cfm">
<!---
	default code table editor

	This form assumes there's a DESCRIPTION column. Make that valid.

	select table_name from sys.user_tables where table_name like 'CT%' and table_name not in (
	select table_name from user_tab_cols where column_name='DESCRIPTION');

	CTATTRIBUTE_CODE_TABLES
	-- OK to ignore, not used here

	alter table CTAUTHOR_ROLE add description varchar2(4000);
	alter table CTBORROW_STATUS add description varchar2(4000);
	alter table CTCASTE add description varchar2(4000);
	alter table CTDATUM add description varchar2(4000);
	alter table CTDOWNLOAD_PURPOSE add description varchar2(4000);
	alter table CTEW add description varchar2(4000);
	alter table CTFLAGS add description varchar2(4000);

	alter table CTMONETARY_UNITS add description varchar2(4000);
	alter table CTNS add description varchar2(4000);
	alter table CTNUMERIC_AGE_UNITS add description varchar2(4000);
	alter table CTPART_ATTRIBUTE_PART add description varchar2(4000);
	alter table CTPERMIT_TYPE add description varchar2(4000);
	alter table CTPREFIX add description varchar2(4000);
	alter table CTSHIPPED_CARRIER_METHOD add description varchar2(4000);
	alter table CTTAXON_VARIABLE add description varchar2(4000);
	alter table CTTISSUE_VOLUME_UNITS add description varchar2(4000);
	alter table CTTRANSACTION_TYPE add description varchar2(4000);
	alter table CTYES_NO add description varchar2(4000);



	CTCOLLECTION_CDE
	-- OK to ignore, has own handler

	CTCOLL_OBJECT_TYPE
	-- not used, dropping. Current values, just in case:
	UAM@ARCTOS> select * from CTCOLL_OBJECT_TYPE;

		COLL_O
		------
		CI
		HS
		IO
		KS
		SP
		SS
		TP
		TS
		ss

	-- old, replaced
	create table fluid_cont_hist20170425 as select * from fluid_container_history;
	drop table fluid_container_history;
	drop table CTFLUID_CONCENTRATION;
	drop table CTFLUID_TYPE;
drop table ctpublication_attribute;


	drop table CTGEOG_SOURCE_AUTHORITY;


UAM@ARCTOS> select * from CTSECTION_TYPE;

FIELD_NOTE_SECT_TYPE
------------------------------------------------------------------------------------------
catalog
catalog and species account
chapter
index
journal
journal and catalog
journal and species account
letter
mixed
species account
table of contents




	drop table CTSECTION_TYPE;







CTSPECIMEN_PART_LIST_ORDER
-- has unique handler/function

CTSPEC_PART_ATT_ATT
-- has unique handler/function






---->
<p>
	<a href="/Admin/CodeTableEditor.cfm">Back to table list</a>
</p>
<cfif action is "edit">

	<cfif tbl is "CTGEOLOGY_ATTRIBUTE">
		<!----
			<cflocation url="/info/geol_hierarchy.cfm" addtoken="false">
			let's do this inline
		---->
		<cflocation url="CodeTableEditor.cfm?action=editGeologyTree"  addtoken="false" >
	<cfelseif tbl is "ctspecimen_part_name"><!---------------------------------------------------->
		<cflocation url="CodeTableEditor.cfm?action=editSpecimenPart" addtoken="false" >
	<cfelseif tbl is "ctspec_part_att_att"><!---------------------------------------------------->
		<cflocation url="CodeTableEditor.cfm?action=editPartAttAtt" addtoken="false" >
	<cfelseif tbl is "ctmedia_license"><!---------------------------------------------------->
		<cflocation url="CodeTableEditor.cfm?action=editMediaLicense" addtoken="false" >
	<cfelseif tbl is "ctattribute_code_tables"><!---------------------------------------------------->
		<cflocation url="CodeTableEditor.cfm?action=editAttCodeTables&tbl=#tbl#" addtoken="false" >
	<cfelseif tbl is "cttaxon_term"><!---------------------------------------------------->
		<cflocation url="CodeTableEditor.cfm?action=editTaxTrm&tbl=#tbl#" addtoken="false">
	<cfelseif tbl is "ctcoll_other_id_type"><!--------------------------------------------------------------->
		<cflocation url="CodeTableEditor.cfm?action=editCollOIDT&tbl=#tbl#" addtoken="false" >
	<cfelseif tbl is "ctspecimen_part_list_order"><!--- special section to handle  another  funky code table --->
		<cflocation url="CodeTableEditor.cfm?action=editSpecPartOrder&tbl=#tbl#" addtoken="false" >
	<cfelseif tbl is "ctcollection_cde"><!--- this IS the thing that makes this form funky.... --->
		use SQL<cfabort>
	<cfelse><!---------------------------- normal CTs --------------->
		<cfquery name="asldfjaisakdshas" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select * from #tbl# where 1=2
		</cfquery>
		<cfif listcontainsnocase(asldfjaisakdshas.columnlist,'collection_cde')>
			<cflocation url="CodeTableEditor.cfm?action=editWithCollectionCode&tbl=#tbl#" addtoken="false" >
		<cfelse>
			<cflocation url="CodeTableEditor.cfm?action=editNoCollectionCode&tbl=#tbl#" addtoken="false" >
		</cfif>
	</cfif>
</cfif>
<!--------------------------------------------->

<cfquery name="ctcollcde" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select distinct collection_cde from ctcollection_cde
</cfquery>


<!--------------------------------------------------------->



<cfif action is "editMediaLicense">
	<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			*
		from ctmedia_license
		ORDER BY
			display
	</cfquery>
	<cfoutput>


		<table class="newRec" border="1">
			<tr>
				<th>DisplayName</th>
				<th>description</th>
				<td>URI</td>
			</tr>
			<form name="newData" method="post" action="CodeTableEditor.cfm">
				<input type="hidden" name="action" value="editMediaLicense_insert">
				<tr>
					<td>
						<input type="text" name="display" class="reqdClr">
					</td>
					<td>
						<textarea name="description"  class="reqdClr" id="description" rows="4" cols="40"></textarea>
					</td>
					<td>
						<input type="text" name="uri" class="reqdClr">
					</td>
					<td>
						<input type="submit" value="Insert" class="insBtn">
					</td>
				</tr>
			</form>
		</table>
		<cfset i = 1>
		Edit
		<table border="1">
			<tr>
				<th>Display</th>
				<th>description</th>
				<th>URI</th>
			</tr>
			<cfloop query="q">
				<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
					<form name="m#media_license_id#" id="m#media_license_id#" action="CodeTableEditor.cfm">
						<input name="action" type="hidden">
						<input name="media_license_id" type="hidden" value="#media_license_id#">
						<td><input type="text" name="display" class="reqdClr" value="#display#"></td>
						<td><textarea name="description"  class="reqdClr" id="description" rows="4" cols="40">#description#</textarea></td>
						<td><input type="text" name="uri" value="#uri#" class="reqdClr"></td>
						<td nowrap="nowrap">
							<span class="likeLink" onclick="m#media_license_id#.action.value='editMediaLicense_delete';m#media_license_id#.submit();">[ Delete ]</span>
							<br><span class="likeLink" onclick="m#media_license_id#.action.value='editMediaLicense_save';m#media_license_id#.submit();">[ Update ]</span>
						</td>
					</form>
				</tr>
				<cfset i = i+1>
			</cfloop>
		</table>
	</cfoutput>
</cfif>

<cfif action is "editMediaLicense_delete">
	<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from ctmedia_license where media_license_id=#media_license_id#
	</cfquery>
	<cflocation addtoken="false" url="CodeTableEditor.cfm?action=edit&tbl=ctmedia_license">
</cfif>
<cfif action is "editMediaLicense_save">
	<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update ctmedia_license set
			display='#display#',
			description='#description#',
			uri='#uri#'
		where media_license_id=#media_license_id#
	</cfquery>
	<cflocation addtoken="false" url="CodeTableEditor.cfm?action=edit&tbl=ctmedia_license">
</cfif>
<cfif action is "editMediaLicense_insert">
	<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		insert into ctmedia_license (
			display,
			description,
			uri
		) values (
			'#display#',
			'#description#',
			'#uri#'
		)
	</cfquery>
	<cflocation addtoken="false" url="CodeTableEditor.cfm?action=edit&tbl=ctmedia_license">
</cfif>









<cfif action is "editPartAttAtt">
	<cfset title="part attribute controls">
	<cfoutput>
		<cfquery name="ctAttribute_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select distinct(attribute_type) from ctspecpart_attribute_type
		</cfquery>
		<cfquery name="thisRec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			Select * from ctspec_part_att_att
			order by attribute_type
		</cfquery>
		<cfquery name="allCTs" datasource="uam_god">
			select distinct(table_name) as tablename from sys.user_tables where table_name like 'CT%' order by table_name
		</cfquery>
		<br>Create Attribute Control
		<table class="newRec" border>
			<tr>
				<th>Attribute</th>
				<th>Value Code Table</th>
				<th>unit Code Table</th>
				<th>&nbsp;</th>
			</tr>
			<form method="post" action="CodeTableEditor.cfm">
				<input type="hidden" name="action" value="editPartAttAtt_newValue">
				<tr>
					<td>
						<select name="attribute_type" size="1">
							<option value=""></option>
							<cfloop query="ctAttribute_type">
							<option
								value="#ctAttribute_type.attribute_type#">#ctAttribute_type.attribute_type#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<cfset thisValueTable = #thisRec.value_code_table#>
						<select name="value_code_table" size="1">
							<option value="">none</option>
							<cfloop query="allCTs">
							<option
							value="#allCTs.tablename#">#allCTs.tablename#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<cfset thisunitTable = #thisRec.unit_code_table#>
						<select name="unit_code_table" size="1">
							<option value="">none</option>
							<cfloop query="allCTs">
							<option
							value="#allCTs.tablename#">#allCTs.tablename#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<input type="submit" value="Create" class="insBtn">
					</td>
				</tr>
			</form>
		</table>
			<br>Edit Attribute Controls
			<table border>
				<tr>
					<th>Attribute</th>
					<th>Value Code Table</th>
					<th>unit Code Table</th>
					<th>&nbsp;</th>
				</tr>
				<cfset i=1>
				<cfloop query="thisRec">
					<form name="att#i#" method="post" action="CodeTableEditor.cfm">
						<input type="hidden" name="action" value="editPartAttAtt_update">
						<input type="hidden" name="oldAttribute_type" value="#Attribute_type#">
						<input type="hidden" name="oldvalue_code_table" value="#value_code_table#">
						<input type="hidden" name="oldunit_code_table" value="#unit_code_table#">
						<tr>
							<td>
								<input type="hidden" name="attribute_type" value="#thisRec.attribute_type#">
								#attribute_type#
							</td>
							<td>
								<cfset thisValueTable = #thisRec.value_code_table#>
								<select name="value_code_table" size="1">
									<option value="">none</option>
									<cfloop query="allCTs">
									<option
									<cfif #thisValueTable# is "#allCTs.tablename#"> selected </cfif>value="#allCTs.tablename#">#allCTs.tablename#</option>
									</cfloop>
								</select>
							</td>
							<td>
								<cfset thisunitTable = #thisRec.unit_code_table#>
								<select name="unit_code_table" size="1">
									<option value="">none</option>
									<cfloop query="allCTs">
									<option
									<cfif #thisunitTable# is "#allCTs.tablename#"> selected </cfif>value="#allCTs.tablename#">#allCTs.tablename#</option>
									</cfloop>
								</select>
							</td>
							<td>
								<input type="button"
									value="Save"
									class="savBtn"
								 	onclick="att#i#.action.value='editPartAttAtt_saveEdit';submit();">
								<input type="button"
									value="Delete"
									class="delBtn"
								  	onclick="att#i#.action.value='editPartAttAtt_deleteValue';submit();">
							</td>
						</tr>
					</form>
				<cfset i=i+1>
			</cfloop>
		</table>
	</cfoutput>
</cfif>

<cfif action is "editPartAttAtt_saveEdit">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update ctspec_part_att_att
		set VALUE_code_table='#value_code_table#',
		unit_code_table='#unit_code_table#'
		 where attribute_type='#attribute_type#'
	</cfquery>
	<cflocation addtoken="false" url="CodeTableEditor.cfm?action=edit&tbl=ctspec_part_att_att">
</cfif>
<cfif action is "editPartAttAtt_deleteValue">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from ctspec_part_att_att where
    		attribute_type='#attribute_type#'
	</cfquery>
	<cflocation addtoken="false" url="CodeTableEditor.cfm?action=edit&tbl=ctspec_part_att_att">
</cfif>
<cfif action is "editPartAttAtt_newValue">
	<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		insert into ctspec_part_att_att (
    		attribute_type,
			VALUE_code_table,
			unit_code_table
		) values (
			'#attribute_type#',
			'#value_code_table#',
			'#unit_code_table#'
		)
	</cfquery>
	<cflocation addtoken="false" url="CodeTableEditor.cfm?action=edit&tbl=ctspec_part_att_att">
</cfif>


<cfset title = "Edit Code Tables">
<cfif action is "nothing">
	<cfquery name="getCTName" datasource="uam_god">
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
	<cfoutput>
		<cfloop query="getCTName">
			<a href="CodeTableEditor.cfm?action=edit&tbl=#getCTName.table_name#">#getCTName.table_name#</a><br>
		</cfloop>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------>
<cfif action is "editWithCollectionCode">
	<!-------- handle any table with a collection_cde column here --------->
	<script type="text/javascript" src="/includes/tablesorter/tablesorter.js"></script>
	<link rel="stylesheet" href="/includes/tablesorter/themes/blue/style.css">
	<style>
		.edited{background:#eaa8b4;}
	</style>
	<script>
		//$(document).ready(function(){
		//    $("#tbl").tablesorter();
		//});
		function updateRecord(a) {
			var rid=a.replace(/\W/g, '_');
			console.log(rid);
			$("#prow_" + rid).addClass('edited');
			var tbl=$("#tbl").val();
			var fld=$("#fld").val();
			var v=encodeURI(a);
			var guts = "/includes/forms/f_editCodeTableVal.cfm?tbl=" + tbl + "&fld=" + fld + "&v=" + v;
			$("<iframe src='" + guts + "' id='dialog' class='popupDialog' style='width:600px;height:600px;'></iframe>").dialog({
				autoOpen: true,
				closeOnEscape: true,
				height: 'auto',
				modal: true,
				position: ['center', 'center'],
				title: 'Edit Code Table',
					width:800,
		 			height:600,
				close: function() {
					$( this ).remove();
				}
			}).width(800-10).height(600-10);
			$(window).resize(function() {
				$(".ui-dialog-content").dialog("option", "position", ['center', 'center']);
			});
			$(".ui-widget-overlay").click(function(){
			    $(".ui-dialog-titlebar-close").trigger('click');
			});
		}
	</script>
	<div class="importantNotification">
		<strong>IMPORTANT!</strong>
		<p>
			Data must be consistent across collection types; the definition
			(and eg, expected result of a search)
			must be the same for all collections in which the term is used. That is, "some attribute" must have the same intent
			across all collection types.
		</p>
		<p>
			Edit existing data to make them available to other collections.
		</p>
		<p>
			Delete and re-create to change values name.
		</p>
		<p>
			Include a description or definition.
		</p>
		<p class="edited">
			Rows that look like this may have been edited and may not be current; reload to refresh.
		</p>
	</div>
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select * from #tbl#
		</cfquery>
		<!--- if we're in this form, the table should always have three columns:
			collection_cde
			description
			something else
		---->
		<cfset fld=d.columnlist>
		<cfset fld=listDeleteAt(fld,listfindnocase(fld,'collection_cde'))>
		<cfset fld=listDeleteAt(fld,listfindnocase(fld,'description'))>
		<cfquery name="od" dbtype="query">
			select distinct(#fld#) from d order by #fld#
		</cfquery>
		Add record:
		<table class="newRec" border="1">
			<tr>
				<th>Collection Type</th>
				<th>#fld#</th>
				<th>Description</th>
			</tr>
			<form name="newData" method="post" action="CodeTableEditor.cfm">
				<input type="hidden" name="action" value="newValue">
				<input type="hidden" name="tbl" id="tbl" value="#tbl#">
				<input type="hidden" name="fld" id="fld" value="#fld#">
				<tr>
					<td>
						<select name="collection_cde" size="1">
							<cfloop query="ctcollcde">
								<option value="#ctcollcde.collection_cde#">#ctcollcde.collection_cde#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<input type="text" name="newData" >
					</td>
					<td>
						<textarea name="description" id="description" rows="4" cols="40"></textarea>
					</td>
					<td>
						<input type="submit" value="Insert"	class="insBtn">
					</td>
				</tr>
			</form>
		</table>



		<cfset i = 1>
		Edit
		<table id="tbl" border="1" class="">
			<thead>
			<tr>
				<th>Collection Type</th>
				<th>#fld#</th>
				<th>Description</th>
				<th>Edit</th>
			</tr>
			</thead>
			<tbody>

			<cfloop query="od">
				<cfset thisValue=evaluate("od." & fld)>
				<cfset rid=rereplace(thisValue,"[^A-Za-z0-9]","_","all")>
				<cfset canedit=true>
				<tr id="prow_#rid#">
					<cfquery name="pd" dbtype="query">
						select * from d where #fld#='#thisValue#' order by collection_cde
					</cfquery>
					<td>
						<cfloop query="pd">
							<div>
								#collection_cde#
							</div>
						</cfloop>
					</td>
					<td>
						#thisValue#
					</td>
					<td>
						<cfquery name="dsc" dbtype="query">
							select description from pd group by description
						</cfquery>
						<cfif dsc.recordcount gt 1>
							description inconsistency!!!
							#valuelist(dsc.description)#
							<cfset canedit=false>
						<cfelse>
							#dsc.description#
						</cfif>
					</td>
					<td nowrap="nowrap">
						<cfif canedit is false>
							Inconsistent data;contact a DBA.
						<cfelse>
							<br><span class="likeLink" onclick="updateRecord('#thisValue#')">[ Update ]</span>
						</cfif>
					</td>
				</tr>
				<cfset i=i+1>
			</cfloop>
			</tbody>
		</table>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->


<!---------------------------------------------------------------------------->
<cfif action is "editAttCodeTables">
	<cfoutput>
		<cfquery name="ctAttribute_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select distinct(attribute_type) from ctAttribute_type
		</cfquery>
		<cfquery name="thisRec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			Select * from ctattribute_code_tables
			order by attribute_type
		</cfquery>
		<cfquery name="allCTs" datasource="uam_god">
			select distinct(table_name) as tablename from sys.user_tables where table_name like 'CT%' order by table_name
		</cfquery>
		<br>Create Attribute Control
		<table class="newRec" border>
			<tr>
				<th>Attribute</th>
				<th>Value Code Table</th>
				<th>Units Code Table</th>
				<th>&nbsp;</th>
			</tr>
			<form method="post" action="CodeTableEditor.cfm">
				<input type="hidden" name="action" value="newValue">
				<input type="hidden" name="tbl" value="#tbl#">
				<tr>
					<td>
						<select name="attribute_type" size="1">
							<option value=""></option>
							<cfloop query="ctAttribute_type">
							<option
								value="#ctAttribute_type.attribute_type#">#ctAttribute_type.attribute_type#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<cfset thisValueTable = #thisRec.value_code_table#>
						<select name="value_code_table" size="1">
							<option value="">none</option>
							<cfloop query="allCTs">
							<option
							value="#allCTs.tablename#">#allCTs.tablename#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<cfset thisUnitsTable = #thisRec.units_code_table#>
						<select name="units_code_table" size="1">
							<option value="">none</option>
							<cfloop query="allCTs">
							<option
							value="#allCTs.tablename#">#allCTs.tablename#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<input type="submit"
							value="Create"
							class="insBtn">
					</td>
				</tr>
			</form>
		</table>
		<br>Edit Attribute Controls
		<table border>
			<tr>
				<th>Attribute</th>
				<th>Value Code Table</th>
				<th>Units Code Table</th>
				<th>&nbsp;</th>
			</tr>
			<cfset i=1>
			<cfloop query="thisRec">
				<form name="att#i#" method="post" action="CodeTableEditor.cfm">
					<input type="hidden" name="action" value="">
					<input type="hidden" name="tbl" value="#tbl#">
					<input type="hidden" name="oldAttribute_type" value="#Attribute_type#">
					<input type="hidden" name="oldvalue_code_table" value="#value_code_table#">
					<input type="hidden" name="oldunits_code_table" value="#units_code_table#">
					<tr>
						<td>
							<cfset thisAttType = #thisRec.attribute_type#>
								<select name="attribute_type" size="1">
									<option value=""></option>
									<cfloop query="ctAttribute_type">
									<option
												<cfif #thisAttType# is "#ctAttribute_type.attribute_type#"> selected </cfif>value="#ctAttribute_type.attribute_type#">#ctAttribute_type.attribute_type#</option>
									</cfloop>
								</select>
						</td>
						<td>
							<cfset thisValueTable = #thisRec.value_code_table#>
							<select name="value_code_table" size="1">
								<option value="">none</option>
								<cfloop query="allCTs">
								<option
								<cfif #thisValueTable# is "#allCTs.tablename#"> selected </cfif>value="#allCTs.tablename#">#allCTs.tablename#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<cfset thisUnitsTable = #thisRec.units_code_table#>
							<select name="units_code_table" size="1">
								<option value="">none</option>
								<cfloop query="allCTs">
								<option
								<cfif #thisUnitsTable# is "#allCTs.tablename#"> selected </cfif>value="#allCTs.tablename#">#allCTs.tablename#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<input type="button"
								value="Save"
								class="savBtn"
							 	onclick="att#i#.action.value='saveEdit';submit();">
							<input type="button"
								value="Delete"
								class="delBtn"
							  	onclick="att#i#.action.value='deleteValue';submit();">
						</td>
					</tr>
				</form>
			<cfset i=#i#+1>
		</cfloop>
	</table>
</cfoutput>
</cfif>



<!---------------------------------------------------------------------------->
<cfif action is "editTaxTrm">

<cfoutput>
Terms must be lower-case
		<hr>
		<style>
			.dragger {
				cursor:move;
			}
		</style>
		<script>
			$(function() {
				$( "##sortable" ).sortable({
					handle: '.dragger'
				});
				$("##tcncclasstbl").submit(function(event){
					var linkOrderData=$("##sortable").sortable('toArray').join(',');
					$( "##classificationRowOrder" ).val(linkOrderData);
					return true;
				});
			});
		</script>
		<cfquery name="q_noclass" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				TAXON_TERM,
				DESCRIPTION,
				cttaxon_term_id
			from cttaxon_term where is_classification=0 order by taxon_term
		</cfquery>
		<cfquery name="q_isclass" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				TAXON_TERM,
				DESCRIPTION,
				is_classification,
				relative_position,
				cttaxon_term_id
			from cttaxon_term where is_classification=1
			order by relative_position
		</cfquery>

		<form name="newData" method="post" action="CodeTableEditor.cfm">
			<input type="hidden" name="action" value="newValue">
			<input type="hidden" name="tbl" value="cttaxon_term">
			Note: new classification terms will insert into the bottom of the hierarchy. EDIT THEM AFTER YOU CREATE!
			<table class="newRec">
				<tr>
					<th>Term</th>
					<th>Classification?</th>
					<th>Definition</th>
				</tr>
				<tr>
					<td>
						<input type="text" name="newData" >
					</td>
					<td>
						<select name="classification">
							<option value="1">yes</option>
							<option value="0">no</option>
						</select>
					</td>
					<td>
						<textarea name="description" rows="4" cols="40"></textarea>
					</td>
					<td>
						<input type="submit"
							value="Insert"
							class="insBtn">
					</td>
				</tr>
			</table>
		</form>
		<hr>Non-classification terms
		<form name="tcnc" method="post" action="CodeTableEditor.cfm">
			<input type="hidden" name="action" value="saveEditsTaxonTermNoClass">
			<table border>
				<tr>
					<th>Term</th>
					<th>Definition</th>
					<th></th>
				</tr>
				<cfset i=1>
				<cfloop query="q_noclass">
					<input type="hidden" name="rowid_#cttaxon_term_id#" value="#cttaxon_term_id#">
					<tr>
						<td>
							<input type="text" id="term_#cttaxon_term_id#"  name="term_#cttaxon_term_id#" value="#taxon_term#">
						</td>
						<td><textarea name="description_#cttaxon_term_id#" rows="4" cols="40">#description#</textarea></td>
						<td>
							<span class="likeLink" onclick='$("##term_#cttaxon_term_id#").val("");'>delete</span>
						</td>
					</tr>
				</cfloop>
			</table>
			<input type="submit" class="savBtn" value="save all non-classification edits">
		</form>
		<hr>Classification terms. Drag to order. NOTE: Order sets only the display oorder of code tables.
		<form name="tcncclasstbl" id="tcncclasstbl" method="post" action="CodeTableEditor.cfm">
			<input type="hidden" name="action" value="saveEditsTaxonTermWithClass">
			<table border>
				<tr>
					<th>sort</th>
					<th>Term</th>
					<th>Definition</th>
					<th></th>
				</tr>
				<tbody id="sortable">
				<cfloop query="q_isclass">
					<input type="hidden" name="rowid_#cttaxon_term_id#" value="#cttaxon_term_id#">
					<tr id="cell_#cttaxon_term_id#">
						<td class="dragger">
							(drag)
						</td>
						<td>
							<input type="text" id="term_#cttaxon_term_id#"  name="term_#cttaxon_term_id#" value="#taxon_term#">
						</td>
						<td><textarea name="description_#cttaxon_term_id#" rows="4" cols="40">#description#</textarea></td>
						<td>
							<span class="likeLink" onclick='$("##term_#cttaxon_term_id#").val("");'>delete</span>
						</td>
					</tr>
				</cfloop>
				</tbody>
			</table>
			<input type="submit" class="savBtn" value="save all classification edits">
			<input type="hidden" name="classificationRowOrder" id="classificationRowOrder">
		</form>
		</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->
<cfif action is "editCollOIDT">
	<script>
			jQuery(document).ready(function() {

		$("form").submit(function (e) {
			console.log('submitted');
		    e.preventDefault();
		    var formId = this.id;  // "this" is a reference to the submitted form
		    console.log(formId);
		    return false;
		});

	});

	</script>
	<cfoutput>
		<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from ctcoll_other_id_type order by sort_order,other_id_type
		</cfquery>
		<div class="importantNotification">
			IMPORTANT: Read the important notification! It's big and red for a reason!!
			<div class="importantNotification">
				<strong>Base URL</strong> is a string which when prepended to values of OtherIDNumber in specimen records
				creates a resolvable URI. Include necessary "punctuation"; the only operation Arctos will perform is
				appending  OtherIDNumber onto BaseURL. A URL describing the resource which initially created the OtherID or
				a general page from which the data represented by the OtherID may be searched should be entered in Description.
				Do NOT use Base URL for any purpose other than forming resolvable identifiers
				from specimens to related records.

				<p>Examples:</p>

				<ul>
					<li>Desired link: <strong>https://www.ncbi.nlm.nih.gov/nuccore/KU199801</strong></li>
					<li>What a user will enter as OtherIDNumber: <strong>KU199801</strong></li>
					<li>Base URL: <strong>https://www.ncbi.nlm.nih.gov/nuccore/</strong></li>
				</ul>

				<ul>
					<li>Desired link: <strong>https://mywebsite.com?someStaticVar=someValue&thingYouWantToPassIn=ABC123</strong></li>
					<li>What a user will enter as OtherIDNumber: <strong>ABC123</strong></li>
					<li>Base URL: <strong>https://mywebsite.com?someStaticVar=someValue&thingYouWantToPassIn=</strong></li>
				</ul>
			</div>
		</div>
		<form name="newData" method="post" action="CodeTableEditor.cfm">
			<input type="hidden" name="action" value="newValue">
			<input type="hidden" name="tbl" value="ctcoll_other_id_type">
			<table class="newRec">
				<tr>
					<th>ID Type</th>
					<th>Description</th>
					<th>Base URL</th>
					<th>Sort</th>
					<th></th>
				</tr>
				<tr>
					<td>
						<input type="text" name="newData" required class="reqdClr">
					</td>
					<td>
						<textarea name="description" rows="4" cols="40"  class="reqdClr" required="required"></textarea>
					</td>
					<td>
						<input type="text" name="base_url" size="50">
					</td>
					<td>
						<input type="number" name="sort_order">
					</td>
					<td>
						<input type="submit" value="Insert" class="insBtn">
					</td>
				</tr>
			</table>
		</form>
		<cfset i = 1>
		<table>
			<tr>
				<th>Type</th>
				<th>Description</th>
				<th>Base URL</th>
				<th>Sort</th>
			</tr>
			<cfloop query="q">
				<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
					<td>
			<form name="#tbl##i#" id="#tbl##i#" method="post" action="CodeTableEditor.cfm">
				<input type="hidden" name="action" value="saveEdit">
						<input type="hidden" name="tbl" value="ctcoll_other_id_type">
						<input type="hidden" name="origData" value="#other_id_type#">
				<table>
				<tr>

						<td>
							<input type="text" name="other_id_type" value="#other_id_type#" size="50" required class="reqdClr">
						</td>
						<td>
							<textarea name="description" id="description#i#" rows="4" cols="40" required="required" class="reqdClr">#trim(description)#</textarea>
						</td>
						<td>
							<input type="text" name="base_url" size="60" value="#base_url#">
						</td>
						<td>
							<input type="number" name="sort_order" value="#sort_order#">
						</td>
						<td>
							<input type="submit"
								value="Save"
								class="savBtn">
								<!----
							   	onclick="#tbl##i#.action.value='saveEdit';submit();"---->
							<input type="submit"
								value="Delete"
								class="delBtn"
								onclick="#tbl##i#.action.value='deleteValue';">
						</td>
						</tr>
						</table>

					</form>
				</td>
</tr>
				<cfset i=i+1>
			</cfloop>
		</table>
	</cfoutput>
</cfif>





<!---------------------------------------------------------------------------->
<cfif action is "editSpecPartOrder">


		<cfquery name="thisRec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from ctspecimen_part_list_order order by
			list_order,partname
		</cfquery>
		<cfquery name="ctspecimen_part_name" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select collection_cde, part_name partname from ctspecimen_part_name
		</cfquery>
		<cfquery name="mo" dbtype="query">
			select max(list_order) +1 maxNum from thisRec
		</cfquery>
		<p>
			This application sets the order part names appear in certain reports and forms.
			Nothing prevents you from making several parts the same
			order, and doing so will just cause them to not be ordered. You don't have to order things you don't care about.
		</p>
		Create part ordering
		<table class="newRec" border>
			<tr>
				<th>Part Name</th>
				<th>List Order</th>
				<th></th>
			</tr>
			<form name="newPart" method="post" action="CodeTableEditor.cfm">
				<input type="hidden" name="action" value="newValue">
				<input type="hidden" name="tbl" value="#tbl#">
				<tr>
					<td>
						<cfset thisPart = #thisRec.partname#>
						<select name="partname" size="1">
							<cfloop query="ctspecimen_part_name">
							<option
							value="#ctspecimen_part_name.partname#">#ctspecimen_part_name.partname# (#ctspecimen_part_name.collection_cde#)</option>
							</cfloop>
						</select>
					</td>
					<cfquery name="mo" dbtype="query">
						select max(list_order) +1 maxNum from thisRec
					</cfquery>
					<td>
						<cfset thisLO = #thisRec.list_order#>
						<select name="list_order" size="1">
							<cfloop from="1" to="#mo.maxNum#" index="n">
								<option value="#n#">#n#</option>
							</cfloop>
						</select>
					</td>
					<td colspan="3">
						<input type="submit"
							value="Create"
							class="insBtn">
					</td>
				</tr>
			</form>
		</table>
		Edit part order
		<table border>
			<tr>
				<th>Part Name</th>
				<th>List Order</th>
				<th>&nbsp;</th>
			</tr>
			<cfset i=1>
			<cfloop query="thisRec">
				<form name="part#i#" method="post" action="CodeTableEditor.cfm">
					<input type="hidden" name="action" value="ctspecimen_part_list_order">
					<input type="hidden" name="tbl" value="#tbl#">
					<input type="hidden" name="oldlist_order" value="#list_order#">
					<input type="hidden" name="oldpartname" value="#partname#">
					<tr>
						<td>
							<cfset thisPart = #thisRec.partname#>
							<select name="partname" size="1">
								<cfloop query="ctspecimen_part_name">
								<option
								<cfif #thisPart# is "#ctspecimen_part_name.partname#"> selected </cfif>value="#ctspecimen_part_name.partname#">#ctspecimen_part_name.partname#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<cfset thisLO = #thisRec.list_order#>
							<select name="list_order" size="1">
								<cfloop from="1" to="#mo.maxNum#" index="n">
									<option <cfif #thisLO# is "#n#"> selected </cfif>value="#n#">#n#</option>
								</cfloop>
							</select>
						</td>
						<td colspan="3">
							<input type="button"
								value="Save"
								class="savBtn"
								onclick="part#i#.action.value='saveEdit';submit();">
							<input type="button"
								value="Delete"
								class="delBtn"
							 	onclick="part#i#.action.value='deleteValue';submit();">

						</td>
					</tr>
				</form>
				<cfset i=#i#+1>
			</cfloop>
		</table>


		</cfif>


<!---------------------------------------------------------------------------->
<cfif action is "editNoCollectionCode">
	<cfoutput>

		<cfquery name="getCols" datasource="uam_god">
			select column_name from sys.user_tab_columns where table_name='#tbl#'
		</cfquery>
		<cfset collcde=listfindnocase(valuelist(getCols.column_name),"collection_cde")>
		<cfset hasDescn=listfindnocase(valuelist(getCols.column_name),"description")>
		<cfquery name="f" dbtype="query">
			select column_name from getCols where lower(column_name) not in ('collection_cde','description')
		</cfquery>
		<cfset fld=f.column_name>
		<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select #fld# as data
			<cfif collcde gt 0>
				,collection_cde
			</cfif>
			<cfif hasDescn gt 0>
				,description
			</cfif>
			from #tbl#
			ORDER BY
			<cfif collcde gt 0>
				collection_cde,
			</cfif>
			#fld#
		</cfquery>
		Add record:
		<table class="newRec" border="1">
			<tr>
				<cfif collcde gt 0>
					<th>Collection Type</th>
				</cfif>
				<th>#fld#</th>
				<cfif hasDescn gt 0>
					<th>Description</th>
				</cfif>
			</tr>
			<form name="newData" method="post" action="CodeTableEditor.cfm">
				<input type="hidden" name="collcde" value="#collcde#">
				<input type="hidden" name="action" value="newValue">
				<input type="hidden" name="tbl" value="#tbl#">
				<input type="hidden" name="hasDescn" value="#hasDescn#">
				<input type="hidden" name="fld" value="#fld#">
				<tr>
					<cfif collcde gt 0>
						<td>
							<select name="collection_cde" size="1">
								<cfloop query="ctcollcde">
									<option value="#ctcollcde.collection_cde#">#ctcollcde.collection_cde#</option>
								</cfloop>
							</select>
						</td>
					</cfif>
					<td>
						<input type="text" name="newData" >
					</td>

					<cfif hasDescn gt 0>
						<td>
							<textarea name="description" id="description" rows="4" cols="40"></textarea>
						</td>
					</cfif>
					<td>
						<input type="submit"
							value="Insert"
							class="insBtn">
					</td>
				</tr>
			</form>
		</table>
		<cfset i = 1>
		Edit #tbl#:
		<table border="1">
			<tr>
				<cfif collcde gt 0>
					<th>Collection Type</th>
				</cfif>
				<th>#fld#</th>
				<cfif hasDescn gt 0>
					<th>Description</th>
				</cfif>
			</tr>
			<cfloop query="q">
				<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
					<form name="#tbl##i#" method="post" action="CodeTableEditor.cfm">
						<input type="hidden" name="Action">
						<input type="hidden" name="tbl" value="#tbl#">
						<input type="hidden" name="fld" value="#fld#">
						<input type="hidden" name="collcde" value="#collcde#">
						<input type="hidden" name="hasDescn" value="#hasDescn#">
						<input type="hidden" name="origData" value="#q.data#">
						<cfif collcde gt 0>
							<input type="hidden" name="origcollection_cde" value="#q.collection_cde#">
							<cfset thisColl=#q.collection_cde#>
							<td>
								<select name="collection_cde" size="1">
									<cfloop query="ctcollcde">
										<option
											<cfif #thisColl# is "#ctcollcde.collection_cde#"> selected </cfif>value="#ctcollcde.collection_cde#">#ctcollcde.collection_cde#</option>
									</cfloop>
								</select>
							</td>
						</cfif>
						<td>
							<input type="text" name="thisField" value="#q.data#" size="50">
						</td>
						<cfif hasDescn gt 0>
							<td>
								<textarea name="description" rows="4" cols="40">#q.description#</textarea>
							</td>
						</cfif>
						<td>
							<input type="button"
								value="Save"
								class="savBtn"
								onclick="#tbl##i#.Action.value='saveEdit';submit();">
							<input type="button"
								value="Delete"
								class="delBtn"
								onclick="#tbl##i#.Action.value='deleteValue';submit();">

						</td>
					</form>
				</tr>
				<cfset i = #i#+1>
			</cfloop>
		</table>
		</cfoutput>
	</cfif>

<!---------------------------------------------------------------------------->





<cfif action is "deleteValue">

	<cfif tbl is "ctpublication_attribute">
		<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from ctpublication_attribute
			where
				publication_attribute='#origData#'
		</cfquery>
	<cfelseif tbl is "ctcoll_other_id_type">
		<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from ctcoll_other_id_type
			where
				OTHER_ID_TYPE='#origData#'
		</cfquery>
	<cfelseif tbl is "ctattribute_code_tables">
		<cfquery name="del" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			DELETE FROM ctattribute_code_tables
			WHERE
				Attribute_type = '#oldAttribute_type#'
				<cfif len(#oldvalue_code_table#) gt 0>
					AND	value_code_table = '#oldvalue_code_table#'
				</cfif>
				<cfif len(#oldunits_code_table#) gt 0>
					AND	units_code_table = '#oldunits_code_table#'
				</cfif>
		</cfquery>
	<cfelseif tbl is "ctspecimen_part_list_order">
		<cfquery name="del" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			DELETE FROM ctspecimen_part_list_order
			WHERE
				partname = '#oldpartname#' AND
				list_order = '#oldlist_order#'
		</cfquery>
	<cfelse>
		<cfquery name="del" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			DELETE FROM #tbl#
			where #fld# = '#origData#'
			<cfif isdefined("collection_cde") and len(collection_cde) gt 0>
				 AND collection_cde='#origcollection_cde#'
			</cfif>
		</cfquery>
	</cfif>
	<cflocation url="CodeTableEditor.cfm?action=edit&tbl=#tbl#" addtoken="false">

	</cfif>
	<cfif action is "saveEdit">

	<cfif tbl is "ctpublication_attribute">
		<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update ctpublication_attribute set
				publication_attribute='#publication_attribute#',
				DESCRIPTION='#description#',
				control='#control#'
			where
				publication_attribute='#origData#'
		</cfquery>
	<cfelseif tbl is "ctcoll_other_id_type">
		<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update ctcoll_other_id_type set
				OTHER_ID_TYPE='#other_id_type#',
				DESCRIPTION='#description#',
				base_URL='#base_url#',
				<cfif len(sort_order) gt 0>
					sort_order=#sort_order#
				<cfelse>
					sort_order=null
				</cfif>
			where
				OTHER_ID_TYPE='#origData#'
		</cfquery>
	<cfelseif tbl is "ctattribute_code_tables">
		<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			UPDATE ctattribute_code_tables SET
				Attribute_type = '#Attribute_type#',
				value_code_table = '#value_code_table#',
				units_code_table = '#units_code_table#'
			WHERE
				Attribute_type = '#oldAttribute_type#' AND
				value_code_table = '#oldvalue_code_table#' AND
				units_code_table = '#oldunits_code_table#'
		</cfquery>
	<cfelseif tbl is "ctspecimen_part_list_order">
		<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			UPDATE ctspecimen_part_list_order SET
				partname = '#partname#',
				list_order = '#list_order#'
			WHERE
				partname = '#oldpartname#' AND
				list_order = '#oldlist_order#'
		</cfquery>
	<cfelse>
		<cfquery name="up" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			UPDATE #tbl# SET #fld# = '#thisField#'
			<cfif isdefined("collection_cde") and len(collection_cde) gt 0>
				,collection_cde='#collection_cde#'
			</cfif>
			<cfif isdefined("description")>
				,description='#description#'
			</cfif>
			where #fld# = '#origData#'
			<cfif isdefined("collection_cde") and len(collection_cde) gt 0>
				 AND collection_cde='#origcollection_cde#'
			</cfif>
		</cfquery>
	</cfif>
	<cflocation url="CodeTableEditor.cfm?action=edit&tbl=#tbl#" addtoken="false">


	</cfif>
	<cfif action is "newValue">
	<cfif tbl is "ctpublication_attribute">
		<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into ctpublication_attribute (
				publication_attribute,
				DESCRIPTION,
				control
			) values (
				'#newData#',
				'#description#',
				'#control#'
			)
		</cfquery>

	<cfelseif tbl is "cttaxon_term">
		<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into cttaxon_term (
				taxon_term,
				DESCRIPTION,
				IS_CLASSIFICATION,
				relative_position
			) values (
				'#newData#',
				'#description#',
				#classification#,
				<cfif classification is 1>
					999999999
				<cfelse>
					NULL
				</cfif>
			)
		</cfquery>
	<cfelseif tbl is "ctcoll_other_id_type">
		<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into ctcoll_other_id_type (
				OTHER_ID_TYPE,
				DESCRIPTION,
				base_URL,
				sort_order
			) values (
				'#newData#',
				'#description#',
				'#base_url#',
				<cfif len(sort_order) gt 0>
					#sort_order#
				<cfelse>
					null
				</cfif>
			)
		</cfquery>
	<cfelseif tbl is "ctattribute_code_tables">
		<cfquery name="new" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			INSERT INTO ctattribute_code_tables (
				Attribute_type
				<cfif len(#value_code_table#) gt 0>
					,value_code_table
				</cfif>
				<cfif len(#units_code_table#) gt 0>
					,units_code_table
				</cfif>
				)
			VALUES (
				'#Attribute_type#'
				<cfif len(#value_code_table#) gt 0>
					,'#value_code_table#'
				</cfif>
				<cfif len(#units_code_table#) gt 0>
					,'#units_code_table#'
				</cfif>
			)
		</cfquery>
	<cfelseif tbl is "ctspecimen_part_list_order">
		<cfquery name="new" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			INSERT INTO ctspecimen_part_list_order (
				partname,
				list_order
				)
			VALUES (
				'#partname#',
				#list_order#
			)
		</cfquery>
	<cfelse>
		<cfquery name="new" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			INSERT INTO #tbl#
				(#fld#
				<cfif isdefined("collection_cde") and len(collection_cde) gt 0>
					 ,collection_cde
				</cfif>
				<cfif isdefined("description") and len(description) gt 0>
					 ,description
				</cfif>
				)
			VALUES
				('#newData#'
				<cfif isdefined("collection_cde") and len(collection_cde) gt 0>
					 ,'#collection_cde#'
				</cfif>
				<cfif isdefined("description") and len(description) gt 0>
					 ,'#description#'
				</cfif>
			)
		</cfquery>
	</cfif>
	<cflocation url="CodeTableEditor.cfm?action=edit&tbl=#tbl#" addtoken="false">
</cfif>



<cfif action is "saveEditsTaxonTermNoClass">
<cfoutput>
	<cftransaction>
		<cfloop list="#FIELDNAMES#" index="i">
			<cfif left(i,6) is "rowid_">
				<!--- because CF UPPERs FIELDNAMES ---->
				<cfset rid=replace(i,'ROWID_','')>
				<cfset thisROWID=evaluate("rowid_" & rid)>
				<cfset thisVAL=evaluate("term_" & thisROWID)>
				<cfset thisDEF=evaluate("DESCRIPTION_" & thisROWID)>
				<cfif len(thisVAL) is 0>
					<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						delete from cttaxon_term where cttaxon_term_id=#thisROWID#
					</cfquery>
				<cfelse>
					<cfquery name="u" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						update cttaxon_term set taxon_term='#thisVAL#',description='#thisDEF#' where cttaxon_term_id=#thisROWID#
					</cfquery>
				</cfif>
			</cfif>
			<cflocation url="CodeTableEditor.cfm?action=edit&tbl=cttaxon_term" addtoken="false">
		</cfloop>
	</cftransaction>
	</cfoutput>

	</cfif>
	<cfif action is "saveEditsTaxonTermWithClass">


	<cftransaction>
		<cfoutput>
		<cfquery name="moveasideplease" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cttaxon_term set relative_position=relative_position+100000000 where relative_position is not null
		</cfquery>
		<cfloop from="1" to="#listlen(CLASSIFICATIONROWORDER)#" index="listpos">
			<cfset x=listgetat(CLASSIFICATIONROWORDER,listpos)>
			<cfset thisROWID=listlast(x,"_")>
			<cfset thisVAL=evaluate("term_" & thisROWID)>
			<cfset thisDEF=evaluate("DESCRIPTION_" & thisROWID)>
			<cfif len(thisVAL) is 0>
				<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					delete from cttaxon_term where cttaxon_term_id=#thisROWID#
				</cfquery>
			<cfelse>
				<cfquery name="u" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update
						cttaxon_term
					set
						relative_position=#listpos#,
						taxon_term='#thisVAL#',
						description='#thisDEF#'
					where cttaxon_term_id=#thisROWID#
				</cfquery>
			</cfif>
		</cfloop>
		</cfoutput>
	</cftransaction>
	<cflocation url="CodeTableEditor.cfm?action=edit&tbl=cttaxon_term" addtoken="false">
</cfif>












<!----------------------- geology is weird (hierarchy) so gets it's own code ----------------------------------------->

<!---------------------------------------------------------------------------->
<cfif action is "editGeologyTerm">
	<!---- old: /info/geol_hierarchy.cfm ---->
	<cfoutput>
		<cfquery name="c"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from geology_attribute_hierarchy where geology_attribute_hierarchy_id=#geology_attribute_hierarchy_id#
		</cfquery>
		<form name="ins" method="post" action="CodeTableEditor.cfm">
			<input type="hidden" name="action" value="saveGeologyTermEdit">
			<input type="hidden" name="geology_attribute_hierarchy_id" value="#geology_attribute_hierarchy_id#">
			<label for="newTerm">Attribute ("formation")</label>
			<input type="text" name="attribute" value="#c.attribute#">
			<label for="newTerm">Value ("Prince Creek")</label>
			<input type="text" name="attribute_value" value="#c.attribute_value#">
			<label for="newTerm">Attribute valid for Data Entry?</label>
			<cfset uvf=c.usable_value_fg>
			<select name="usable_value_fg" id="usable_value_fg">
				<option <cfif #uvf# is 0>selected="selected" </cfif>value="0">no</option>
				<option <cfif #uvf# is 1>selected="selected" </cfif>value="1">yes</option>
			</select>
			<label for="description">Description</label>
			<input type="text" name="description" value="#c.description#" size="60">
			<br>
			<input type="submit" value="Save Edits"	class="savBtn">
			<br>
			<input type="button" value="Delete"	class="delBtn"
		   		onclick="document.location='CodeTableEditor.cfm?action=deleteGeologyTerm&geology_attribute_hierarchy_id=#geology_attribute_hierarchy_id#';">
		</form>
	</cfoutput>
</cfif>
<!---------------------------------------->

<cfif action is "editGeologyTree">
	<cfset title="Geology Attribute Hierarchy">
	<cfquery name="cData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
	<cfquery name="terms"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select geology_attribute_hierarchy_id,
		attribute_value || ' (' || attribute || ')' attribute
		 from geology_attribute_hierarchy  order by attribute
	</cfquery>
	<div style="border:1px dotted gray;font-size:smaller;margin-left:50px;margin-right:50px;">
		This form serves dual purpose as the code table editor for geology attributes (=term vocabulary/authority) and a way to store
		attribute values as hierarchical data for use in searching.
		<br>
		Create any attributes that you need.
		<br>
		Select "no" for "Attribute valid for Data Entry" for those that should only be used for searching. "Lithostratigraphy"
		might be a useful term as the start of a set of hierarchies, but it's not something that can have a meaning in Geology Attributes
		so should not be "valid." Note that Attribute and Value required. Value is used in building hierarchies for dearching, so
		 " " (a blank space) is an acceptable and appropriate attribute for this example.
		<br>
		Create hierarchies by selecting a child and parent term.
		<br>
		Click More to edit or delete an attribute. You cannot delete attributes with children or attributes used as Geology Attributes.
	</div>
	<cfoutput>
		<table class="newRec"><tr><td>
			New Term:
			<form name="ins" method="post" action="CodeTableEditor.cfm">
				<input type="hidden" name="action" value="newGeologyTerm">
				<label for="newTerm">Attribute ("formation")</label>
				<input type="text" name="attribute">
				<label for="newTerm">Value ("Prince Creek")</label>
				<input type="text" name="attribute_value">
				<label for="newTerm">Attribute valid for Data Entry?</label>
				<select name="usable_value_fg" id="usable_value_fg">
					<option value="0">no</option>
					<option value="1">yes</option>
				</select>
				<label for="description">Description</label>
				<input type="text" name="description" size="60">
				<br>
				<input type="submit" value="Insert Term" class="insBtn">
			</form>
		</td></tr></table>
		Create Hierarchies:
		<form name="rel" method="post" action="CodeTableEditor.cfm">
			<input type="hidden" name="action" value="newGeologyReln">
			<label for="newTerm">Parent Term</label>
			<select name="parent">
				<option value="">NULL</option>
				<cfloop query="terms">
					<option value="#geology_attribute_hierarchy_id#">#attribute#</option>
				</cfloop>
			</select>
			<label for="newTerm">Child Term</label>
			<select name="child">
				<cfloop query="terms">
					<option value="#geology_attribute_hierarchy_id#">#attribute#</option>
				</cfloop>
			</select>
			<br>
			<input type="submit" value="Create Relationship" class="savBtn">
		</form>


		<br>Current Data (values in red are NOT code table values but may still be used in searches):
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
			<a class="infoLink" href="CodeTableEditor.cfm?action=editGeologyTerm&geology_attribute_hierarchy_id=#geology_attribute_hierarchy_id#">more</a>
			</li>
			<cfif cData.currentRow IS cData.recordCount>
				#repeatString("</ul>",listLen(levelList,","))#
		   	</cfif>
		</cfloop>
	</cfoutput>
</cfif>
<!------------------- end editGeologyTree --------------------------------->
<cfif action is "deleteGeologyTerm">
	<cfoutput>
		<cfquery name="killGeog" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from geology_attribute_hierarchy where geology_attribute_hierarchy_id=#geology_attribute_hierarchy_id#
		</cfquery>
		<cflocation url="CodeTableEditor.cfm?action=editGeologyTree" addtoken="false">
	</cfoutput>
</cfif>

<!------------------------------------------------------------->
<cfif action is "saveGeologyTermEdit">
	<cfoutput>
		<cfquery name="changeGeog" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update geology_attribute_hierarchy set
			attribute='#attribute#',
			attribute_value='#attribute_value#',
			usable_value_fg=#usable_value_fg#,
			description='#description#'
			where
			geology_attribute_hierarchy_id=#geology_attribute_hierarchy_id#
		</cfquery>
		<cflocation url="CodeTableEditor.cfm?action=editGeologyTree" addtoken="false">
	</cfoutput>
</cfif>
<!---------------------------------------------------->
<cfif action is "newGeologyTerm">
	<cfoutput>

		<cfquery name="changeGeog" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into geology_attribute_hierarchy (attribute,attribute_value,usable_value_fg,description)
			values
			 ('#attribute#','#attribute_value#',#usable_value_fg#,'#description#')
		</cfquery>
		<cflocation url="CodeTableEditor.cfm?action=editGeologyTree" addtoken="false">
	</cfoutput>
</cfif>
<!---------------------------------------------------->
<cfif action is "newGeologyReln">
	<cfoutput>
		<cfquery name="changeGeog" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update geology_attribute_hierarchy set parent_id=<cfif parent is "">NULL<cfelse>#parent#</cfif> where geology_attribute_hierarchy_id=#child#
		</cfquery>
		<cflocation url="CodeTableEditor.cfm?action=editGeologyTree" addtoken="false">
	</cfoutput>
</cfif>

<!----------------------- END weird geology code ------------------------------------------------------------->








<!------------------------------------------- specimen parts are weird (is_tissue flag) so get their own code block ------------------>
<!-------------------------------------------------->
<cfif action is "editSpecimenPart">
	<script type="text/javascript" src="/includes/tablesorter/tablesorter.js"></script>
	<link rel="stylesheet" href="/includes/tablesorter/themes/blue/style.css">
	<cfset title="ctspecimen_part_name editor">

	<style>
		.edited{background:#eaa8b4;}
	</style>
	<script>

		//$("tr:odd").addClass("odd");

		//$("tr:odd").addClass("odd");

		$(document).ready(function(){
	        $("#partstbl").tablesorter();
	    });

		function updatePart(pn) {
			var rid= pn.replace(/\W/g, '_');
			//$("#" + rid).addClass('edited');
			$("#prow_ediv_" + rid).addClass('edited').html('EDITED! Reload to see current data.');

			var guts = "/includes/forms/f2_ctspecimen_part_name.cfm?part_name=" + encodeURI(pn);
			$("<iframe src='" + guts + "' id='dialog' class='popupDialog' style='width:600px;height:600px;'></iframe>").dialog({
				autoOpen: true,
				closeOnEscape: true,
				height: 'auto',
				modal: true,
				position: ['center', 'center'],
				title: 'Edit Part',
					width:800,
		 			height:600,
				close: function() {
					$( this ).remove();
				}
			}).width(800-10).height(600-10);
			$(window).resize(function() {
				$(".ui-dialog-content").dialog("option", "position", ['center', 'center']);
			});
			$(".ui-widget-overlay").click(function(){
			    $(".ui-dialog-titlebar-close").trigger('click');
			});
		}
	</script>
	<div class="importantNotification">
		<strong>IMPORTANT!</strong>
		<p>
			Parts (including description and tissue-status) must be consistent across collection types; the definition
			(and eg, expected result of a search for the part)
			must be the same for all collections in which the part is used. That is, "operculum" cannot be used for fish gill covers
			as it has already been claimed to describe snail anatomy.
		</p>
		<p>
			Edit existing parts to make them available to other collections.
		</p>
		<p>
			Delete and re-create to change a part name.
		</p>
		<p>
			Please include a description or definition.
		</p>
		<p>
			Please be consistent, especially in complex parts. If "heart, kidney" exists do NOT create "kidney, heart."
			Contact a DBA if you need assistance in creating consistency.
		</p>
		<p class="edited">
			Rows that look like this may have been edited and may not be current; reload to refresh.
		</p>
	</div>


	<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			*
		from ctspecimen_part_name
		ORDER BY
			collection_cde,part_name
	</cfquery>
	<cfoutput>
		Add record:
		<table class="newRec" border="1" >
			<tr>
				<th>Collection Type</th>
				<th>Part Name</th>
				<td>IsTissue</td>
				<th>Description</th>
			</tr>
			<form name="newData" method="post" action="CodeTableEditor.cfm">
				<input type="hidden" name="action" value="insertSpecimenPart">
				<tr>
					<td>
						<select name="collection_cde" size="1">
							<cfloop query="ctcollcde">
								<option value="#ctcollcde.collection_cde#">#ctcollcde.collection_cde#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<input type="text" name="part_name">
					</td>
					<td>
						<select name="is_tissue">
							<option value="0">no</option>
							<option value="1">yes</option>
						</select>
					</td>
					<td>
						<textarea name="description" id="description" rows="4" cols="40"></textarea>
					</td>
					<td>
						<input type="submit" value="Insert" class="insBtn">
					</td>
				</tr>
			</form>
		</table>
		<cfset i = 1>
		Edit
		<table id="partstbl" border="1" class="tablesorter">
			<thead>
			<tr>
				<th>Collection Type</th>
				<th>part_name</th>
				<th>IsTissue</th>
				<th>Description</th>
				<th>Edit</th>
			</tr>
			</thead>
			<tbody>
			<cfquery name="pname" dbtype="query">
				select part_name from q group by part_name order by part_name
			</cfquery>
			<cfloop query="pname">
			<cfset rid=rereplace(part_name,"[^A-Za-z0-9]","_","all")>

				<cfset canedit=true>
				<tr id="prow_#rid#">
					<cfquery name="pd" dbtype="query">
						select * from q where part_name='#part_name#' order by collection_cde
					</cfquery>
					<td>
						<cfloop query="pd">
							<div>
								#collection_cde#
							</div>
						</cfloop>
					</td>
					<td>
						#part_name#
					</td>
					<td>
						<cfquery name="ist" dbtype="query">
							select is_tissue from pd group by is_tissue
						</cfquery>
						<cfif ist.recordcount gt 1>
							is tissue inconsistency!!!
							#valuelist(ist.is_tissue)#
							<cfset canedit=false>
						<cfelse>
							#ist.is_tissue#
						</cfif>
					</td>
					<td>
						<cfquery name="dsc" dbtype="query">
							select description from pd group by description
						</cfquery>
						<cfif dsc.recordcount gt 1>
							description inconsistency!!!
							#valuelist(dsc.description)#
							<cfset canedit=false>
						<cfelse>
							#dsc.description#
						</cfif>
					</td>
					<td nowrap="nowrap">
						<cfif canedit is false>
							Inconsistent data;contact a DBA.
						<cfelse>
							<br><span class="likeLink" onclick="updatePart('#part_name#')">[ Update ]</span>
						</cfif>
						<div id="prow_ediv_#rid#">

						</div>
					</td>
				</tr>
				<cfset i=i+1>
			</cfloop>

			<!----
			<cfloop query="q">
				<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))# id="r#ctspnid#">
					<td>#collection_cde#</td>
					<td>#q.part_name#</td>
					<td>#is_tissue#</td>
					<td>#q.description#</td>
					<td nowrap="nowrap">
						<span class="likeLink" onclick="deletePart(#ctspnid#)">[ Delete ]</span>
						<br><span class="likeLink" onclick="updatePart(#ctspnid#)">[ Update ]</span>
					</td>
				</tr>
				<cfset i = #i#+1>
			</cfloop>
			---->
			</tbody>
		</table>
	</cfoutput>
</cfif>
<!-------------------------------------------------->
<cfif action is "insertSpecimenPart">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from ctspecimen_part_name where part_name='#part_name#'
	</cfquery>
	<cfif d.recordcount gt 0>
		<cfthrow message="Part already exists; edit to add collection types.">
	</cfif>
	<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		insert into ctspecimen_part_name (
			collection_cde,
			part_name,
			DESCRIPTION,
			is_tissue
		) values (
			'#collection_cde#',
			'#part_name#',
			'#description#',
			#is_tissue#
		)
	</cfquery>
	<cflocation url="CodeTableEditor.cfm?action=editSpecimenPart" addtoken="false">
</cfif>
<!-------------------------------------------------->
<!------------------------------------------- END weird specimen parts code block ------------------>




<cfinclude template="/includes/_footer.cfm">
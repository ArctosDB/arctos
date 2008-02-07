
<cfinclude template="/includes/_header.cfm">
<!--- no security --->
<!---- uses table below:
	drop table cf_temp_scans;
	drop public synonym cf_temp_scans;
	CREATE TABLE cf_temp_scans (
		key number,
		collection_object_id number,
		part_name varchar2(60),
		barcode varchar2(60),
		parent_barcode varchar2(60),
		print_flag number,
		problem varchar2(4000))
	;
	CREATE PUBLIC SYNONYM cf_temp_scans FOR cf_temp_scans;
	GRANT select, insert,update,delete ON cf_temp_scans TO uam_query,uam_update;
---->
<cfif #action# is "nothing">
<!--- see if they have something in the que ---->

<cfquery name="inTheWings" datasource="#Application.web_user#">
	select collection_object_id FROM cf_temp_scans
</cfquery>
<cfif #inTheWings.recordcount# gt 0>
	You have stuff waiting!	
	<cfabort>
</cfif>

<cfquery name="ctCollection" datasource="#Application.web_user#">
	select collection_cde, institution_acronym, collection_id FROM collection
</cfquery>
<cfquery name="ctPartName" datasource="#Application.web_user#">
	select part_name, collection_cde FROM ctspecimen_part_name
</cfquery>
<table border>
	<tr>
		<td>Collection</td>
		<td>Catalog Number</td>
		<td>Part Name</td>
		<td>Barcode</td>
		<td>Parent Barcode</td>
		<td>Print Flag</td>
	</tr>
	<cfif not isdefined("numRows") OR #numRows# lt 10>
		<cfset numRows=10>
	</cfif>
		<cfset finalNumberOfRows=10>
	<cfoutput>
		<form name="scans" method="post" action="addPartScan.cfm">
		<input type="hidden" name="action" value="validate">
		<cfloop from="1" to="#numrows#" index="i">
			<tr>
				<td>
					<select name="collection_id_#i#" size="1">
						<cfloop query="ctCollection">
							<option value="#collection_id#">#institution_acronym# #collection_cde#</option>
						</cfloop>
					</select>
				</td>
				<td>
					<input type="text" name="cat_num_#i#">
				</td>
				<td>
					<select name="part_name_#i#" size="1">
						<cfloop query="ctPartName">
							<option value="#part_name#">#part_name# (#collection_cde#)</option>
						</cfloop>
					</select>
				</td>
				<td>
					<input type="text" name="barcode_#i#">
				</td>
				<td>
					<input type="text" name="parent_barcode_#i#">
				</td>
				<td>
					<select name="print_flag_#i#" size="1">
						<option value="0">N</option>
						<option value="1">C</option>
						<option value="2">V</option>
					</select>
				</td>
			</tr>
			<cfset finalNumberOfRows=#i#>
		</cfloop>
			<input type="hidden" name="finalNumberOfRows" value="#finalNumberOfRows#">
			<tr>
				<td colspan="5">
					<input type="submit">
				</td>
			</tr>
		</form>
	</cfoutput>
</table>
</cfif>
<!--------------------------------------------------------------------------->
<cfif #action# is "validate">
	<cfoutput>
		<cfloop from="1" to="#finalNumberOfRows#" index="n">
			<cfset thisProblem = "">
			<cfset thisCollectionId = #evaluate("collection_id_" & n)#>
			<cfset thisCatNum = #evaluate("cat_num_" & n)#>
			<cfset thisPartName = #evaluate("part_name_" & n)#>
			<cfset thisBarcode = #evaluate("barcode_" & n)#>
			<cfset thisParentBarcode = #evaluate("parent_barcode_" & n)#>
			<cfset thisPringFlag = #evaluate("print_flag_" & n)#>
			<cfif len(#thisCatNum#) gt 0 AND 
				len(#thisPartName#) gt 0 AND
				len(#thisBarcode#) gt 0>
			<!--- validate this --->
			<cfquery name="thisSpecimen" datasource="#Application.web_user#">
				select 
					collection_object_id,
					collection_cde
				from 
					cataloged_item
				where 
					collection_id=#thisCollectionId# and cat_num=#thisCatNum#
			</cfquery>
			<cfquery name="isValidPart" datasource="#Application.web_user#">
				select part_name from ctspecimen_part_name where part_name='#thisPartName#' and 
				collection_cde='#thisSpecimen.collection_cde#'
			</cfquery>
			<cfif #isValidPart.recordcount# neq 1>
				<cfset thisProblem = "#thisPartName# was found #isValidPart.recordcount# 
				times for collection #thisSpecimen.collection_cde#!">
			</cfif>
			<cfif len(#thisParentBarcode#) gt 0>
				<cfquery name="isValidParentContainer" datasource="#Application.web_user#">
					select barcode from container where barcode='#thisParentBarcode#'
				</cfquery>
				<cfif #isValidParentContainer.recordcount# neq 1>
					<cfset thisProblem = "Parent Container #thisParentBarcode# was found 
					#isValidParentContainer.recordcount# times!">
				</cfif>
			</cfif>
			<cfquery name="isValidContainer" datasource="#Application.web_user#">
				select barcode from container where barcode='#thisBarcode#'
			</cfquery>
			<cfif #isValidContainer.recordcount# neq 1>
				<cfset thisProblem = "Container #thisBarcode# was found 
				#isValidContainer.recordcount# times!">
			</cfif>
			<cfquery name="itsAlreadyThere" datasource="#Application.web_user#">
				select part_name from specimen_part where part_name='#thisPartName#'
				and derived_from_cat_item = #thisSpecimen.collection_object_id#
			</cfquery>
			<cfif #itsAlreadyThere.recordcount# neq 0>
				<cfset thisProblem = "Part #thisPartName# exists 
				#itsAlreadyThere.recordcount# times!">
			</cfif>
			<cfquery name="nextKey" datasource="#Application.web_user#">
				select max(key) from cf_temp_scans
			</cfquery>
			<cfif not isdefined("nextKey.key")>
				<cfset key = 1>
			<cfelse>
				<cfset key = #nextKey.key# + 1>
			</cfif>
			
			<cfquery name="insertOne" datasource="#Application.web_user#">
				INSERT INTO cf_temp_scans (
					key,
					collection_object_id,
					part_name,
					barcode,
					parent_barcode,
					print_flag,
					problem)
				VALUES (
					#key#,
					<CFIF #thisSpecimen.collection_object_id# GT 0>
						#thisSpecimen.collection_object_id#,
					<CFELSE>
						000000000000,
					</CFIF>
					'#thisPartName#',
					'#thisBarcode#',
					<CFIF LEN(#thisParentBarcode#) GT 0>
						'#thisParentBarcode#',
					<CFELSE>
						NULL,
					</CFIF>
					#thisPringFlag#,
					<CFIF LEN(#thisProblem#) GT 0>
						'#thisProblem#'
					<CFELSE>
						NULL
					</CFIF>
					)
			</cfquery>
			</cfif><!--- enc check that we got somethign --->
			<hr>
		</cfloop>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------->
<cfif #action# is "load">
<cfquery name="thisSpecimen" datasource="#Application.web_user#">
				select 
					cataloged_item.collection_object_id, 
					collection_cde,
					scientific_name,
					concatparts(cataloged_item.collection_object_id) partString
				from 
					cataloged_item,
					identification
				where 
					cataloged_item.collection_object_id = identification.collection_object_id AND
					identification.accepted_id_fg = 1 AND
					collection_id=#thisCollectionId# and cat_num=#thisCatNum#
			</cfquery>

</cfif>
<cfinclude template="/includes/_footer.cfm">
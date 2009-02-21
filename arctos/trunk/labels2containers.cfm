<cfinclude template="/includes/_header.cfm">
<cfif #action# IS "nothing">
To use this form, all of the following must be true:

<ul>
	<li>You want to make labels into containers</li>
	<li>All the containers have barcodes</li>
	<li>The barcodes are
		<ul>
			<li>Integers</li>
			<li>Integers with a prefix or suffix</li>
		</ul>
	</li>
</ul>
<cfoutput>
	<cfquery name="ctContainerType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select distinct(container_type) container_type from ctcontainer_type
		where container_type <> 'collection object'
	</cfquery>
	<form name="wtf" method="post" action="labels2containers.cfm">
		<input type="hidden" name="action" value="change">
		<label for="Original Container Type"></label>
		<select name="origContType" id="origContType" size="1">
			<cfloop query="ctContainerType">
				<option value="#container_type#">#container_type#</option>
			</cfloop>
		</select>
		<label for="newContType">New Container Type</label>
		<select name="newContType" id="newContType" size="1">
			<cfloop query="ctContainerType">
				<option value="#container_type#">#container_type#</option>
			</cfloop>
		</select>
		<label for="barcode_prefix">Barcode Prefix</label>
		<input type="text" name="barcode_prefix" id="barcode_prefix" size="3">
		<label for="barcode_suffix">Barcode Suffix</label>
		<input type="text" name="barcode_suffix" id="barcode_suffix" size="3">
		<label for="begin_barcode">Low barcode (integer component)</label>
		<input type="text" name="begin_barcode" id="begin_barcode">
		<label for="end_barcode">High barcode (integer component)</label>
		<input type="text" name="end_barcode" id="end_barcode">
		<label for="description">Description</label>
		<input type="text" name="description" id="description">
		<label for="container_remarks">Remarks</label>
		<input type="text" name="container_remarks" id="container_remarks">
		<label for="height">Height</label>
		<input type="text" name="height" id="height">
		<label for="length">Length</label>
		<input type="text" name="length" id="length">
		<label for="width">Width</label>
		<input type="text" name="width" id="width">
		<label for="number_positions">Number of Positions</label>
		<input type="text" name="number_positions" id="number_positions">
		<label for="ignore_zero_pad">Ignore leading zeroes?</label>
		<select name="ignore_zero_pad" id="ignore_zero_pad">
			<option value="0">no</option>
			<option value="1">yes</option>
		</select>
		<br><input type="submit" value="save" class="savBtn">
	</form>
</cfoutput>
</cfif>
<!--------------------------------------->
<!---
<cfif #action# IS "change">
<cfoutput>
<cfif #origContType# does not contain "label">
	You can't use this with #origContType#!
	<cfabort>
</cfif>
<cfif len(#barcode_prefix#) gt 0>
	<cfset sqlBC = "to_number(TRIM('#barcode_prefix#' FROM barcode))">
<cfelse>
	<cfset sqlBC = "to_number(barcode)">
</cfif>
<cfset sql="select barcode,container_id from container where 
		#sqlBC# >= #begin_barcode# and
		#sqlBC# <= #end_barcode# 
		and container_type='#origContType#'">
	<cfif len(#barcode_prefix#) gt 0>
			<cfset sql="#sql# and barcode LIKE '#barcode_prefix#%'">
		</cfif>
	<cfquery name="contID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(sql)#
	</cfquery>
	<hr>
	<cftransaction>
	<cfloop query="contID">
		<cfquery name="upCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			update container set container_type='#newContType#'
			where container_id=#container_id#
		</cfquery>
	</cfloop>
	</cftransaction>
	Spiffy, changed #contID.recordcount# #origContType# to #newContType#.
</cfoutput>
</cfif>
--->
<!--------------------------------------->
<cfif #action# IS "change">
<cfoutput>
<cfif #origContType# is "collection object">
	You can't use this with #origContType#!
	<cfabort>
</cfif>
<cfset minBcF="">
<cfquery name="testCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select barcode,container_type from container where
	container_type='#origContType#' and
	<cfif len(barcode_prefix) gt 0>
		substr(barcode,1,#len(barcode_prefix)#)='#barcode_prefix#' and
	</cfif>
	<cfif len(barcode_prefix) gt 0>
		substr(barcode,#len(barcode_prefix)#,length(barcode)) between #begin_barcode# and #end_barcode#
	<cfelse>
		barcode between #begin_barcode# and #end_barcode#
	</cfif>
</cfquery>
<cfdump var=#testCont#>



<cfabort>
<cfset inBarcode = "">

<cfloop from="#begin_barcode#" to="#end_barcode#" index="i">
	<cfif len(#inBarcode#) gt 0>
		<cfset inBarcode = "#inBarcode#,'#barcode_prefix##i##barcode_suffix#'">
	<cfelse>
		<cfset inBarcode = "'#barcode_prefix##i##barcode_suffix#'">
	</cfif>
</cfloop>
<!---
<cfif len(#barcode_prefix#) gt 0>
	<cfset sqlBC = "to_number(TRIM('#barcode_prefix#' FROM barcode))">
<cfelse>
	<cfset sqlBC = "to_number(barcode)">
</cfif>
--->
<cfset sql="select barcode,container_id from container where 
		container_type='#origContType#' AND
		barcode IN (#inBarcode#)">
	
	<cfquery name="contID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(sql)#
	</cfquery>
	<cftransaction>
	<cfloop query="contID">
		<cfquery name="upCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			update container set container_type='#newContType#'
			<cfif len(#DESCRIPTION#) gt 0>
				,DESCRIPTION='#DESCRIPTION#'
			</cfif>
			<cfif len(#CONTAINER_REMARKS#) gt 0>
				,CONTAINER_REMARKS='#CONTAINER_REMARKS#'
			</cfif>
			<cfif len(#WIDTH#) gt 0>
				,WIDTH=#WIDTH#
			</cfif>
			<cfif len(#HEIGHT#) gt 0>
				,HEIGHT=#HEIGHT#
			</cfif>
			<cfif len(#LENGTH#) gt 0>
				,LENGTH=#LENGTH#
			</cfif>
			<cfif len(#NUMBER_POSITIONS#) gt 0>
				,NUMBER_POSITIONS=#NUMBER_POSITIONS#
			</cfif>
			where container_id=#container_id#
		</cfquery>
	</cfloop>
	</cftransaction>
	
	
	Spiffy, changed #contID.recordcount# #origContType# to #newContType#.
	<hr>
	
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">
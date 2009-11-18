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

Leading zeroes will be ignored.
<cfoutput>
	<cfquery name="ctContainerType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select distinct(container_type) container_type from ctcontainer_type
		where container_type <> 'collection object'
	</cfquery>
	<form name="wtf" method="post" action="labels2containers.cfm">
		<input type="hidden" name="action" value="change">
		<label for="origContType">Original Container Type</label>
		<select name="origContType" id="origContType" size="1" class="reqdClr">
			<cfloop query="ctContainerType">
				<option value="#container_type#">#container_type#</option>
			</cfloop>
		</select>
		<label for="newContType">New Container Type</label>
		<select name="newContType" id="newContType" size="1" class="reqdClr">
			<cfloop query="ctContainerType">
				<option value="#container_type#">#container_type#</option>
			</cfloop>
		</select>
		<label for="barcode_prefix">Barcode Prefix (include spaces if necessary)</label>
		<input type="text" name="barcode_prefix" id="barcode_prefix" size="3">
		<!---
		<label for="barcode_suffix">Barcode Suffix</label>
		<input type="text" name="barcode_suffix" id="barcode_suffix" size="3">
		--->
		<label for="begin_barcode">Low barcode (integer component)</label>
		<input type="text" name="begin_barcode" id="begin_barcode" class="reqdClr">
		<label for="end_barcode">High barcode (integer component)</label>
		<input type="text" name="end_barcode" id="end_barcode" class="reqdClr">
		<label for="description">New Description</label>
		<input type="text" name="description" id="description">
		<label for="container_remarks">New Remark</label>
		<input type="text" name="container_remarks" id="container_remarks">
		<label for="height">New Height</label>
		<input type="text" name="height" id="height">
		<label for="length">New Length</label>
		<input type="text" name="length" id="length">
		<label for="width">New Width</label>
		<input type="text" name="width" id="width">
		<label for="number_positions">New Number of Positions</label>
		<input type="text" name="number_positions" id="number_positions">
		<br><input type="submit" value="save" class="savBtn">
	</form>
</cfoutput>
</cfif>
<!--------------------------------------->
<cfif #action# IS "change">
<cfoutput>
<cfif #origContType# is "collection object">
	You can't use this with #origContType#!
	<cfabort>
</cfif>
	<cfloop from="#begin_barcode#" to="#end_barcode#" index="i">
		<cfset bc = barcode_prefix & i>
		update container set 
			container_type='#newContType#'
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
		where
			container_type='#origContType#' and
			barcode = '#bc#'
	<hr>
	</cfloop>
	
	


<cfset minBcF="">
<cfquery name="testCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select barcode,container_type from container where
	container_type='#origContType#' and
	<cfif len(barcode_prefix) gt 0>
		substr(barcode,1,#len(barcode_prefix)#)='#barcode_prefix#' and
	</cfif>
	<cfif len(barcode_prefix) gt 0>
		substr(barcode,#len(barcode_prefix)#+1,length(barcode)) between #begin_barcode# and #end_barcode#
	<cfelse>
		barcode between #begin_barcode# and #end_barcode#
	</cfif>
</cfquery>
<cfset curl="labels2containers.cfm?action=update&origContType=#origContType#&newContType=#newContType#&barcode_prefix=#barcode_prefix#&begin_barcode=#begin_barcode#&end_barcode=#end_barcode#&description=#description#&container_remarks=#container_remarks#&height=#height#&length=#length#&width=#width#&number_positions=#number_positions#">

Your criteria matched #testCont.recordcount# containers. Carefully review what you're about the update in the 
following table, and <a href="#curl#">click here to continue</a> if it all look good.
<cfdump var=#testCont#>
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "update">
<cfoutput>
	<!---<cftransaction>
	<cfquery name="testCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update container set 
			container_type='#newContType#'
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
		where
			container_type='#origContType#' and
			<cfif len(barcode_prefix) gt 0>
				substr(barcode,1,#len(barcode_prefix)#)='#barcode_prefix#' and
			</cfif>
			<cfif len(barcode_prefix) gt 0>
				substr(barcode,#len(barcode_prefix)#+1,length(barcode)) between #begin_barcode# and #end_barcode#
			<cfelse>
				barcode between #begin_barcode# and #end_barcode#
			</cfif>
	</cfquery>
	</cftransaction>
	---->
	It's done.
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">
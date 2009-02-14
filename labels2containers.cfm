
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
	<table border>
		<cfquery name="ctContainerType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select distinct(container_type) container_type from ctcontainer_type
			where container_type <> 'collection object'
		</cfquery>
		<form name="wtf" method="post" action="labels2containers.cfm">
			<input type="hidden" name="action" value="change">
			<tr>
				<td align="right">Original Container Type</td>
				<td>
					<select name="origContType" size="1">
						<cfloop query="ctContainerType">
							<option value="#container_type#">#container_type#</option>
						</cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<td align="right">New Container Type</td>
				<td>
					<select name="newContType" size="1">
						<cfloop query="ctContainerType">
							<option value="#container_type#">#container_type#</option>
						</cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<td align="right">Barcode Prefix</td>
				<td>
					<input type="text" name="barcode_prefix" size="3">
				</td>
			</tr>
			<tr>
				<td align="right">Barcode Suffix</td>
				<td>
					<input type="text" name="barcode_suffix" size="3">
				</td>
			</tr>
			<tr>
				<td align="right">Low barcode (integer component)</td>
				<td>
					<input type="text" name="begin_barcode">
				</td>
			</tr>
			<tr>
				<td align="right">High barcode (integer component)</td>
				<td>
					<input type="text" name="end_barcode">
				</td>
			</tr>
			<tr>
				<td align="right">Description:</td>
				<td>
					<input type="text" name="DESCRIPTION">
				</td>
			</tr>
			<tr>
				<td align="right">Remarks:</td>
				<td>
					<input type="text" name="CONTAINER_REMARKS">
				</td>
			</tr>
			
			<tr>
				<td align="right">HEIGHT:</td>
				<td>
					<input type="text" name="HEIGHT">
				</td>
			</tr>
			<tr>
				<td align="right">LENGTH:</td>
				<td>
					<input type="text" name="LENGTH">
				</td>
			</tr>
			<tr>
				<td align="right">Width:</td>
				<td>
					<input type="text" name="WIDTH">
				</td>
			</tr>
			<tr>
				<td align="right">Number Positions:</td>
				<td>
					<input type="text" name="NUMBER_POSITIONS">
				</td>
			</tr>
			<tr>
				<td colspan="2">
					<input type="submit">
				</td>
			</tr>
		</form>
		</table>
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
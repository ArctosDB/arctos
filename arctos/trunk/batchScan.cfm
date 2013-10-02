<cfset title="Move Containers">
<cfinclude template="/includes/_header.cfm">
<script>
jQuery(document).ready(function() {
	$("#parent_barcode").focus();
});
</script>
<cfif action is "nothing">
<cfoutput>
	<cfset numberFolders = 100>
	<cfset colCount=5>
	<form name="pd" method="post" action="batchScan.cfm">
		<input type="hidden" name="action" value="save">
		<input type="hidden" name="numberFolders" value="#numberFolders#">
		<label for="parent_barcode">Parent Barcode</label>
		<input type="text" name="parent_barcode" id="parent_barcode" size="20" class="reqdClr">
		<input type="submit" 
					class="savBtn"
					onmouseover="this.className='savBtn btnhov'" 
	   				onmouseout="this.className='savBtn'"
					value="Save"
					tabindex="-1">
					&nbsp;&nbsp;&nbsp;
				<input type="reset" 
					class="clrBtn"
					onmouseover="this.className='clrBtn btnhov'" 
	   				onmouseout="this.className='clrBtn'"
					value="Clear Form"
					tabindex="-1">
					<hr>
					
		<label for="sheets">Child Barcodes</label>		
		<cfset numCols="3">		
			<div style="border:1px solid green; padding:10px;" id="sheets">
				<table>
					<cfset c=1>
					<cfloop from="1" to="#numberFolders#" index="i">
						<cfif c is 1>
							<tr>
						</cfif>
							<td>
								<input type="text" name="barcode_#i#" id="barcode_#i#" size="20" class="reqdClr">&nbsp;&nbsp;	
							</td>
						<cfset c=c+1>
						<cfif c is colCount+1>
							</tr>
							<cfset c=1>
						</cfif>
																				
					</cfloop>					
				</table>
			</div>
		</td>
		
	</tr>
</table>
</form>
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------->
<cfif #action# is "save">
	<cfoutput>
	
	
	<cfdump var=#form#>
		<hr>Scans are being processed. If you don't see a success message and a link at the bottom of this page, it
		probably didn't work.
		<hr>
		<cfset pf="">
		<cftransaction>
		
		<table border>
			<tr>
				<th>Parent</th>
				<th>Child</th>
				<th>isDup</th>
				<th>GUID</th>
				<th>Status</th>
			</tr>
			<cfset numberOfBarcodesScanned=0>
			<cfset numberOfUniqueBarcodesScanned=0>
			<cfset barcodescanlist="">
		<cfloop from="1" to ="#numberFolders#" index="i">
		<tr>
			<cfset thisBarcode=evaluate("barcode_" & i)>
			<cfif len(thisBarcode) gt 0>
				<cfset isDup=true>
				<cfif not listfind(barcodescanlist,thisBarcode)>
					<cfset numberOfUniqueBarcodesScanned=numberOfUniqueBarcodesScanned+1>
					<cfset isDup=false>
				</cfif>
				<cfset barcodescanlist=listappend(barcodescanlist,thisBarcode)>
				<cfset numberOfBarcodesScanned=numberOfBarcodesScanned+1>
				 
				<cfquery name="chk" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select 
						checkContainerMovement('#parent_barcode#','#thisBarcode#') cmvt
	 				from
						dual
				</cfquery>
				<cfquery name="guid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select 
						guid 
					from 
						flat,
						specimen_part,
						coll_obj_cont_hist,
						container part,
						container 
					where
						flat.collection_object_id=specimen_part.derived_from_cat_item and 
						specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
						coll_obj_cont_hist.container_id=part.container_id and 
						part.parent_container_id=container.container_id and
						container.barcode='#thisBarcode#'
				</cfquery>

				<td>#parent_barcode#</td>
				<td>#thisBarcode#</td>
				<td>#isDup#</td>
				<td>#valuelist(guid.guid)#</td>
				<td>#chk.cmvt#</td>
				<cfif chk.cmvt is 'pass'>
					<cfset pf=listappend(pf,"p")>
					<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						update 
							container 
						set 
							parent_container_id=(select container_id from container where barcode='#parent_barcode#')
						where
							barcode='#thisBarcode#'
					</cfquery>	
				<cfelse>
					<cfset pf=listappend(pf,"f")>
					<cftransaction action="rollback" />
					<cfabort>
				</cfif>
			</cfif>
		</cfloop>
		</tr>
		</table>
		<ul>
			<li>Number barcodes scanned: #numberOfBarcodesScanned#</li>
			<li>Number unique barcodes scanned: #numberOfUniqueBarcodesScanned#</li>
		</ul>

		</cftransaction>
		<cfif listcontains(pf,'f')>
			<div class="error">
				Something hinky happened. Scans were not saved. See log above, then use your back button.
			</div>
		<cfelse>
			Success. <a href="batchScan.cfm">Scan more</a>
		</cfif>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">

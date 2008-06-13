<cfset title="Move Containers">
<cfinclude template="/includes/_header.cfm">
<cfif #action# is "nothing">
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
					value="Save">
					&nbsp;&nbsp;&nbsp;
				<input type="reset" 
					class="clrBtn"
					onmouseover="this.className='clrBtn btnhov'" 
	   				onmouseout="this.className='clrBtn'"
					value="Clear Form">
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
		<cftransaction>
		<cfloop from="1" to ="#numberFolders#" index="i">
			<cfset thisBarcode=evaluate("barcode_" & i)>
			<cfif len(#thisBarcode#) gt 0>
				<cfquery name="chk" datasource="#Application.uam_dbo#">
					select 
						c.container_id cid,
						p.container_id pid,
						checkContainerMovement('#parent_barcode#','#thisBarcode#') cmvt
	 				from
						container c,
						container p
					where
						c.barcode='#thisBarcode#' and
						p.barcode='#parent_barcode#'
				</cfquery>
				----------------------
				select 
						c.container_id cid,
						p.container_id pid,
						checkContainerMovement('#parent_barcode#','#thisBarcode#') cmvt
	 				from
						container c,
						container p
					where
						c.barcode='#thisBarcode#' and
						p.barcode='#parent_barcode#'
						-----------------------------
				<cfdump var=#chk#>
				<cfif chk.cmvt is 'pass'>
					<cfquery name="ins" datasource="#Application.uam_dbo#">
						update container set 
							parent_container_id=#chk.pid#,
							PARENT_INSTALL_DATE=sysdate
						where
							container_id=#chk.cid#
					</cfquery>	
				<cfelse>
					Bad container: Parent: #parent_barcode#; Child: #thisBarcode#; Error: #chk.cmvt#
					<cftransaction action="rollback" />
					<cfabort>
				</cfif>
			</cfif>
		</cfloop>
		</cftransaction>
		relocate.....
		<!---
		<cflocation url="index.cfm">
		--->
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">

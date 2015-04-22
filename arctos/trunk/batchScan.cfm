<cfset title="Move Containers">
<cfinclude template="/includes/_header.cfm">
<script>
jQuery(document).ready(function() {
	$("#parent_barcode").focus();
});
</script>
<cfif action is "nothing">
	<cfoutput>
		<div class="infoBox">
			<a href="moveContainer.cfm">
				Move Container
			</a>
			will provide instant feedback and should be preferred over this form.
		</div>
		<p>
		<cfquery name="ctcontainer_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	   select container_type from ctcontainer_type where container_type!='collection object' order by container_type
	</cfquery>
		<cfparam name="mode" default="tab">
		<cfset numberFolders = 100>
		<cfset colCount=5>
		<form name="pd" method="post" action="batchScan.cfm">
			<input type="hidden" name="action" value="save">
			<input type="hidden" name="mode" value="#mode#">
			<input type="hidden" name="numberFolders" value="#numberFolders#">

			<div style="border:2px solid red;">
				<strong>
					Use with caution. Updating individual container type is dangerous.
				</strong>
				<label for="new_parent_c_type">
					On save, force-change Parent Container to type....
				</label>
				<select name="new_parent_c_type" id="new_parent_c_type" size="1">
					<option value="">
						change nothing
					</option>
					<cfloop query="ctcontainer_type">
						<option value="#container_type#">
							#container_type#
						</option>
					</cfloop>
				</select>
				<label for="new_child_c_type">
					On save, force-change ALL scanned children to type....
				</label>
				<select name="new_child_c_type" id="new_child_c_type" size="1">
					<option value="">
						change nothing
					</option>
					<cfloop query="ctcontainer_type">
						<option value="#container_type#">
							#container_type#
						</option>
					</cfloop>
				</select>
			</div>
			<br>
			<input type="reset"
				class="clrBtn"
				value="Clear Form"
				tabindex="-1">
			<br>
			<input type="submit"
				class="savBtn"
				value="Fill in the form, then click here to Save"
				tabindex="-1">
			<br>
			<cfif mode is "tab">
				<a href="batchScan.cfm?mode=csv">
					CSV mode
				</a>
			<cfelse>
				<a href="batchScan.cfm?mode=tab">
				    TAB mode
				</a>
			</cfif>
			<hr>
            <label for="parent_barcode">
                Parent Barcode
            </label>
            <input type="text" name="parent_barcode" id="parent_barcode" size="20" class="reqdClr">

			<label for="sheets">
				Child Barcodes
			</label>
			<cfif mode is "tab">
				<cfset numCols="3">
				<div style="border:1px solid green; padding:10px;" id="sheets">
					<table>
						<cfset c=1>
						<cfloop from="1" to="#numberFolders#" index="i">
							<cfif c is 1>
								<tr>
							</cfif>
							<td> <input type="text" name="barcode_#i#" id="barcode_#i#" size="20" class="" placeholder="scan barcode">&nbsp;&nbsp; </td> <cfset c=c+1> <cfif c is colCount+1> </tr> <cfset c=1> </cfif>
						</cfloop>
					</table>
				</div>
			<cfelse>
				<textarea id="childscans" name="childscans" class="hugetextarea" placeholder="scan comma-delimited list here">
				</textarea>
			</cfif>
		</form>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------->
<cfif action is "save">
	<cfoutput>
		<cfif len(parent_barcode) lt 1>
			Parent barcode is required.
			<cfabort>
		</cfif>
		<cfif mode is "csv">
			<cfset bclist=childscans>
		<cfelse>
			<cfset bclist=''>
			<cfloop from="1" to ="#numberFolders#" index="i">
				<cfset thisBarcode=evaluate("barcode_" & i)>
				<cfset bclist=listappend(bclist,thisBarcode)>
			</cfloop>
		</cfif>
		<p>
			Scans are being processed. If you don't see a success message and a link at the bottom of this page, it probably didn't work.
		</p>
		<p>
			GUID is populated only when the scanned barcode contains a part.
		</p>
		<cfset pf="">
		<cftransaction>
			<cfset numberOfBarcodesScanned=0>
			<cfset numberOfUniqueBarcodesScanned=0>
			<cfset barcodescanlist="">
			<table border>
				<tr>
					<th>
						Parent
					</th>
					<th>
						Child
					</th>
					<th>
						isDup
					</th>
					<th>
						GUID
					</th>
				</tr>
				<cfloop from="1" to="#listlen(bclist)#" INDEX="I">
					<cfset thisBarcode=listgetat(bclist,i)>
					<cfif len(thisBarcode) gt 0>
						<cfset isDup=true>
						<cfif not listfind(barcodescanlist,thisBarcode)>
							<cfset numberOfUniqueBarcodesScanned=numberOfUniqueBarcodesScanned+1>
							<cfset isDup=false>
						</cfif>
						<cfset barcodescanlist=listappend(barcodescanlist,thisBarcode)>
						<cfset numberOfBarcodesScanned=numberOfBarcodesScanned+1>
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
						<tr>
							<td>
								#parent_barcode#
							</td>
							<td>
								#thisBarcode#
							</td>
							<td>
								#isDup#
							</td>
							<td>
								#valuelist(guid.guid)#
							</td>
						</tr>
						<cfset pf=listappend(pf,"p")>
						<cfstoredproc
							datasource="user_login"
							username="#session.dbuser#"
							password="#decrypt(session.epw,session.sessionKey)#"
							procedure="moveContainerByBarcode">
							<cfprocparam cfsqltype="cf_sql_varchar" value="#thisBarcode#">
							<cfprocparam cfsqltype="cf_sql_varchar" value="#parent_barcode#">
							<cfprocparam cfsqltype="cf_sql_varchar" value="#new_child_c_type#">
							<cfprocparam cfsqltype="cf_sql_varchar" value="#new_parent_c_type#">
						</cfstoredproc>
						<!----
							<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							update
							container
							set
							parent_container_id=(select container_id from container where barcode='#parent_barcode#')
							where
							barcode='#thisBarcode#'
							</cfquery>
							---->
					</cfif>
				</cfloop>
			</table>
			<ul>
				<li>
					Number barcodes scanned: #numberOfBarcodesScanned#
				</li>
				<li>
					Number unique barcodes scanned: #numberOfUniqueBarcodesScanned#
				</li>
			</ul>
		</cftransaction>
		<cfif listcontains(pf,'f')>
			<div class="error">
				Something hinky happened. Scans were not saved. See log above, then use your back button.
			</div>
		<cfelse>
			Success.
			<a href="batchScan.cfm?mode=#mode#">
				Scan more
			</a>
		</cfif>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">

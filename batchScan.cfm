<cfset title="Move Containers">
<cfinclude template="/includes/_header.cfm">
<script>
jQuery(document).ready(function() {
	$("#parent_barcode").focus();
});

function setContDim(h,w,l){
	$("#new_h").val(h);
	$("#new_w").val(w);
	$("#new_l").val(l);
}

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
				<div style="border:1px solid green; padding:.5em;margin:.5em;">
				<label for="new_h">
					On save, when
					<ul>
						<li>"force-change Parent Container" is "freezer box", and </li>
						<li>ALL of (H, W, L) are provided</li>
					</ul>
					Change parent container	dimensions to....
				</label>
				<table border>
					<tr>
						<td>H</td>
						<td>W</td>
						<td>L</td>
					</tr>
					<tr>
						<td><input type="number" id="new_h" name="new_h" placeholder="H"></td>
						<td><input type="number" id="new_w" name="new_w" placeholder="W"></td>
						<td><input type="number" id="new_l" name="new_l" placeholder="H"></td>
					</tr>
				</table>

				<br><span class="likeLink" onclick="setContDim('5','13','13');">Set dimensions to (5,13,13)</span>
				<br><span class="likeLink" onclick="setContDim('7','13','13');">Set dimensions to (7,13,13)</span>
				<br><span class="likeLink" onclick="setContDim('','','');">reset dimensions</span>
				</div>
			</div>
			<br>
			<input type="reset"	class="clrBtn"	value="Clear Form"	tabindex="-1">
			<br>
			<input type="submit"
				class="savBtn"
				value="Fill in the form, then click here to Save"
				tabindex="-1">
			<br>
			<cfif mode is "tab">
				<a href="batchScan.cfm?mode=csv">
					CSV Paste mode
				</a>
			<cfelse>
				<a href="batchScan.cfm?mode=tab">
				    TAB mode
				</a>
			</cfif>
			<br><a href="batchScan.cfm?action=loadCSV">Upload CSV file</a>
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
<cfif action is "loadCSV">
	<!----

		create table cf_temp_move_container (
			barcode varchar2(255),
			parent_barcode  varchar2(255)
		);

		create public synonym cf_temp_move_container for cf_temp_move_container;
		grant all on cf_temp_move_container to manage_container;

		create unique index ix_u_cf_temp_move_container_bc on cf_temp_move_container (barcode) tablespace uam_idx_1;

		create unique index ix_u_cf_temp_move_ctr_bcpc on cf_temp_move_container (barcode,parent_barcode) tablespace uam_idx_1;
	---->
	Upload CSV with two columns:
	<ul>
		<li>barcode</li>
		<li>parent_barcode</li>
	</ul>
	<form name="getFile" method="post" action="batchScan.cfm" enctype="multipart/form-data">
		<input type="hidden" name="action" value="loadCSVFile">
		 <input type="file"
			   name="FiletoUpload"
			   size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" class="savBtn">
	</form>
</cfif>
<cfif action is "loadCSVFile">
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
    <cfset  util = CreateObject("component","component.utilities")>
	<cfset x=util.CSVToQuery(fileContent)>
    <cfset cols=x.columnlist>
	<cftransaction>
		<cfquery name="del" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from cf_temp_move_container
		</cfquery>

	    <cfloop query="x">
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into cf_temp_move_container (#cols#) values (
				<cfloop list="#cols#" index="i">
					'#stripQuotes(evaluate(i))#'
					<cfif i is not listlast(cols)>
						,
					</cfif>
				</cfloop>
				)
			</cfquery>
		</cfloop>
	</cftransaction>
	<p>
		Loaded - <a href="batchScan.cfm?action=saveCSV">proceed to save</a>
	</p>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_move_container
	</cfquery>
	<table border>
		<tr>
			<th>barcode</th>
			<th>parent_barcode</th>
		</tr>
		<cfoutput>
			<cfloop query="d">
				<tr>
					<td>#barcode#</td>
					<td>#parent_barcode#</td>
				</tr>
			</cfloop>
		</cfoutput>
	</table>
</cfif>

<cfif action is "saveCSV">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_move_container
	</cfquery>
	<cfloop query="d">
		<cftransaction>
			<cfstoredproc
				datasource="user_login"
				username="#session.dbuser#"
				password="#decrypt(session.epw,session.sessionKey)#"
				procedure="moveContainerByBarcode">
				<cfprocparam cfsqltype="cf_sql_varchar" value="#barcode#">
				<cfprocparam cfsqltype="cf_sql_varchar" value="#parent_barcode#">
				<cfprocparam cfsqltype="cf_sql_varchar" value="">
				<cfprocparam cfsqltype="cf_sql_varchar" value="">
			</cfstoredproc>
		</cftransaction>
	</cfloop>
	<p>
		Success: All changes saved to DB
	</p>
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
			<cfif new_parent_c_type is "freezer box" and len(new_h) gt 0 and len(new_w) gt 0 and len(new_l) gt 0>
				<cfquery name="updatingpgarent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select * from container where barcode='parent_barcode'
				</cfquery>


				<p>
					<br>v_container_id=#updatingpgarent.container_id#
					<br>v_parent_container_id=#updatingpgarent.parent_container_id#
					<br>v_container_type=#new_parent_c_type#
					<br>v_label=#updatingpgarent.label#
					<br>v_description=#updatingpgarent.description#
					<br>v_container_remarks=#updatingpgarent.CONTAINER_REMARKS#
					<br>v_barcode=#updatingpgarent.barcode#
					<br>v_width=#new_w#
					<br>v_height=#new_h#
					<br>v_length=#new_l#
					<br>v_number_positions=#updatingpgarent.number_positions#
					<br>v_locked_position=#updatingpgarent.locked_position#
					<br>v_institution_acronym=#updatingpgarent.institution_acronym#



				</p>
				<cfstoredproc
					datasource="user_login"
					username="#session.dbuser#"
					password="#decrypt(session.epw,session.sessionKey)#"
					procedure="updateContainer">
					<cfprocparam cfsqltype="cf_sql_varchar" value="#updatingpgarent.container_id#"><!----v_container_id---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#updatingpgarent.parent_container_id#"><!----v_parent_container_id---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#new_parent_c_type#"><!----v_container_type---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#updatingpgarent.label#"><!---- v_label ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#updatingpgarent.description#"><!---- v_description ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#updatingpgarent.CONTAINER_REMARKS#"><!---- v_container_remarks ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#updatingpgarent.barcode#"><!---- v_barcode ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#new_w#"><!---- v_width ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#new_h#"><!---- v_height ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#new_l#"><!---- v_length ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#updatingpgarent.number_positions#"><!---- v_number_positions ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#updatingpgarent.locked_position#"><!---- v_locked_position ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#updatingpgarent.institution_acronym#"><!---- v_institution_acronym ---->
				</cfstoredproc>
			</cfif>


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
					<cfset thisBarcode=trim(listgetat(bclist,i))>
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
						<hr>
						<br>thisBarcode: |#thisBarcode#|
						<br>parent_barcode: |#parent_barcode#|
						<br>new_child_c_type: |#new_child_c_type#|
						<br>new_parent_c_type: |#new_parent_c_type#|
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

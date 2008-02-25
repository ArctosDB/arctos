
<cfif not isdefined("globalerror")><cfset globalerror=''></cfif>
<cfinclude template="/includes/_header.cfm">
	<cfset title="Scan a Batch">
	<style>
		
		div.thisTable {
			border: 1px solid black;
			width:65%;
			}
		div.leftCell {
			width:50%;
			float:left;
			text-align:right;
			}
		div.rightCell {
			width:50%;
			margin-left:50%;
			text-align:left;
			}
		input.notThere {
			di
			}
		input.isThere {
			visibility:visible;
			}
		div.aHiddenRow {
			display: none;
			}
		div.aRow {
			}
		div.farRightCol {
			float:right;
			}
	</style>
	<cfset numberOfRecords = 100>
	<cfloop from="1" to="#numberOfRecords#" index="i">
		<cfparam name="parent#i#" default="">
		<cfparam name="child#i#" default="">
	</cfloop>
	<!------------------------>
	<cfif #action# is "nothing">
	<div class="leftCell">
			<strong>Parent Barcode&nbsp;</strong>
		</div>
		<div class="rightCell">
			<strong>&nbsp;Child Barcode</strong>
		</div>
		<cfoutput>
		<form name="scans" method="post" action="batchScan.cfm" >
			<input type="hidden" name="action" value="checkScans">
		<cfloop from="1" to="#numberOfRecords#" index="i">
			<cfset thisChild = evaluate("child" & i)>
			<cfset thisParent = evaluate("parent" & i)>
			<cfif len(#thisParent#) gt 0 OR len(#thisChild#) gt 0>
				<cfset thisDivClass = "aRow">
			<cfelse>
				<cfset thisDivClass = "aHiddenRow">
			</cfif>
			<div class="#thisDivClass#" id="row#i#">
				<div class="leftCell">
					<input type="text" name="parent#i#" id="parent#i#" value="#thisParent#">
				</div>
				<div class="rightCell">
					<input type="text" name="child#i#" onChange="turnNextOn('#i#');" id="child#i#" value="#thisChild#">
				</div>
			</div>
		</cfloop>
			<div class="farRightCol">
				Carry over parent values?
				<input type="checkbox" name="carryParent" id="carryParent" value="1" checked>
				<input type="hidden" name="maxRowNum" id="maxRowNum">
				<p></p>
				<input type="submit" 
												value="Save Scans"
												class="savBtn"
												onmouseover="this.className='savBtn btnhov'" 
												onmouseout="this.className='savBtn'">
			</div>
		</form>
		</cfoutput>
	<!---- run a script to turn the first one on ---->
	<script>
		var firstRow=document.getElementById('row1');
		firstRow.className='aRow';
		function turnNextOn (thisVal) {
			var thisVal;
			var nextVal = eval(thisVal) + 1;
			if (nextVal == 101) {
				alert('That\'s all, folks! Submit to save and start over.');
			}
			var nRow = "row" + nextVal;
			var nPar = "parent" + nextVal;
			var nChld = "child" + nextVal;
			var nextRow=document.getElementById(nRow);
			nextRow.className='aRow';
			var maxRow=document.getElementById('maxRowNum');
			maxRow.value=nextVal;
			var isCarry=document.getElementById('carryParent').checked;
			if (isCarry == 1) {
				var nextTab=document.getElementById(nChld);
				var thisParent = "parent" + eval(thisVal);
				var thisParentVal=document.getElementById(thisParent).value;
				var nextParent=document.getElementById(nPar);
				nextParent.value=thisParentVal;
				var nChld = "child" + nextVal;
				nextTab.focus();
			} else {
				// not carrying, set the cursor to the next parent
				var nextTab=document.getElementById(nPar);
				nextTab.focus();
			}
		}			
	</script>
	</cfif>
<!----------------------->
	<cfif #action# is "checkScans">
	
	<cfset localError = "">
	<cfoutput>
	
	<cfset thisDate = dateformat(now(),"dd-mmm-yyyy")>
	
	<cfloop from="1" to="#numberOfRecords#" index="i">
			<cfset thisChildBarcode = #evaluate("child" & i)#>
			<cfset thisParentBarcode = #evaluate("parent" & i)#>
			<!--- only deal with things that have a pair of values --->
			<cfif len(#thisChildBarcode#) gt 0 AND len(#thisParentBarcode#) gt 0>
				<!--- check to make sure both are valid containers --->
				<cfquery name="childID" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
					select container_id from container where barcode='#thisChildBarcode#'
				</cfquery>
				<cfquery name="parentID" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
					select container_id from container where barcode='#thisParentBarcode#'
				</cfquery>
				<cfif #childID.recordcount# is 1 and #parentID.recordcount# is 1>
					<!--- ok, proceed to load them --->
					<cfquery name="putItIn" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
						INSERT INTO cf_temp_container_location (
							CONTAINER_ID,
							PARENT_CONTAINER_ID,
							TIMESTAMP )
						VALUES (
							#childID.container_id#,
							#parentID.container_id#,
							'#thisDate#')
					</cfquery>
				<cfelse>
					<cfset localError = "#localError#; #thisParentBarcode# - #thisChildBarcode#">
					
				</cfif>
			</cfif>
	  </cfloop>
	<!----<cfdump var="#form#">
		
		---->
		
		<hr>
		
		<cfif len(#localError#) gt 0 or len(#globalerror#) gt 0>
			<hr>
			<strong><font color="##FF0000">Containers in the table above have valid barcodes, but something else is wrong with the scans. 
			<p></p>Pairs below (given as  parent - child barcode) have bad barcodes.
			<p>Everything else - if there was anything else - has been loaded into the temporary table, available for load <a href="checkContainerMovement.cfm">here</a>.</p>
			</font>
			 <hr>
			<cfloop list="#localError#" delimiters=";" index="l">
				#l#<br>
			</cfloop>
			
			<p>
			<form name="everything" method="post" action="batchScan.cfm">
				<input type="hidden" name="action" value="nothing">
				<cfloop item="key" collection="#form#">
					<cfif #key# is not 'action'>
						<input type="hidden" name="#key#" value="#form[key]#">
					</cfif>
				</cfloop>
				<input type="submit" 
					value="Return and Preserve Form Values" 
					class="savBtn"
					onmouseover="this.className='savBtn btnhov'"
					onmouseout="this.className='savBtn'">
				<br /><input type="submit" 
					value="Return and Clear Form" 
					class="savBtn"
					onmouseover="this.className='savBtn btnhov'"
					onmouseout="this.className='savBtn'"
					onclick="document.location='batchScan.cfm'">
			</form>
	</p>
		<cfelse>
			All data has been saved to the temp table. Click <a href="checkContainerMovement.cfm">here</a> to load it into the real tables.
	<p>
		<a href="batchScan.cfm" target="_self">Go back and scan some more stuff</a>
	</p>	
			<!---<cflocation url="">--->
		</cfif>
	
	</cfoutput>
	</cfif>
<cfinclude template="/includes/_footer.cfm">
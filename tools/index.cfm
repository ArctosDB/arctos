<!--- no security --->
<cfinclude template="/includes/_header.cfm">
<cfset title="Arctos Tools">
<table border>
	<!----
	<tr>
		<td><a href="/fix/DupLocs.cfm">DupLocs.cfm</a></td>
		<td>Clean up duplicate localities and collecting events. </td>
	</tr>
	---->
	
	<!----
	<tr>
		<td><a href="/fix/fixLatLong.cfm">Lat/Long Conversion</a></td>
		<td>Converts lat/long to dd.dddd format and updates the table so we can map. <span style="color: #FF0000">You
	    may need to run this before DupLocs will work</span>.</td>
	</tr>
	---->
	<tr>
		<td valign="top">
			<strong>Enter Data</strong>
		</td>
		<td>
			<ul>
				<li>
					<a href="/Bulkloader/Bulkloader.cfm">Bulkload Specimens</a>
				</li>
				<li>
					<a href="/DataEntry.cfm">Data Entry</a>
				</li>
				<li>
					<a href="/tools/BulkloadAgents.cfm">Bulkload Agents</a>
				</li>
				<li>
					<a href="/tools/BulkloadParts.cfm">Bulkload Parts</a>
				</li>
				<li>
					<a href="/tools/BulkloadAttributes.cfm">Bulkload Attributes</a>
				</li>
				<li>
					<a href="/tools/BulkloadCitations.cfm">Bulkload Citations</a>
				</li>
				<li>
					<a href="/tools/BulkloadOtherId.cfm">Bulkload Other IDs</a>
				</li>
				<li>
					<a href="/SpecimenSearch.cfm?Action=identification">Add multiple accepted Identifications</a>
				</li>
				<li>
					<a href="/SpecimenSearch.cfm?Action=collEvent">Change collecting event for many specimens</a>
				</li>
				<li>
					<a href="/tools/loanBulkload.cfm">Bulkload Loan Items</a>
				</li>
				<li>
					<a href="/LoadBarcodes.cfm">Upload part and container scans</a>
				</li>
				
				
			</ul>
		</td>
	</tr>
	<tr>
		<td valign="top"><strong>Containers and Barcodes</strong></td>
		<td>
			<ul>
				<li>
					<a href="/batchScan.cfm">Batch Scan Containers</a>
				</li>
				<li>
					<a href="/moveContainer.cfm">Move a container (deprecated)</a>
				</li>
				<li>
					<a href="/a_moveContainer.cfm">Move a container</a>
				</li>
				<li>
					<a href="/dragContainer.cfm">Move a container graphically</a>
				</li>
				<li>
					<a href="/labels2containers.cfm">Change a bunch of labels to containers</a>
				</li>
				<li>
					<a href="/bits2containers.cfm">Add a collection object to a container</a>
				</li>
				<li>
					<a href="/aps.cfm">Add a collection object to a container using barcode</a>
				</li>
				<li>
					<a href="/containerContainer.cfm">Find Parts/Containers (AJAX))</a>
				</li>
				<li>
					<a href="/start.cfm?action=container">Find Parts/Containers (HTML))</a>
				</li>
				<li>
					<a href="/EditContainer.cfm?action=newContainer">Create a new container</a>
				</li>
				<li>
					<a href="/SpecimenContainerLabels.cfm">Download label data for printing</a>
				</li>
				
				<li>
					<a href="/CreateContainersForBarcodes.cfm?action=set">Load a series of specimen labels to the database</a>
				</li>
				<li>
					<a href="dgr_locator.cfm">DGR Locator Tool</a>
				</li>
			</ul>
		</td>
	</tr>
	<tr>
		<td valign="top">
			<strong>Error Checking and random</strong>
		</td>
		<td>
			<ul>
				<li>
					<a href="/info/annotate.cfm">Annotations</a>
				</li>
				<li>
					<a href="/fix/fixBlCatNum.cfm">UAM Mammals Bulkloader Catnums</a>
				</li>
				<li>
					<a href="/tools/PublicationStatus.cfm">Publication Staging</a>
				</li>
				
				<li>
					<a href="/info/CodeTableValuesVersusTableValues.cfm">Find values that appear in data tables and not code tables and vice-verse</a>
				</li>
				<li>
					<a href="/tools/TaxonomyGaps.cfm">Taxonomy without higher taxa</a>
				</li>
				<li>
					<a href="/tools/findGap.cfm">Catalog Number Gaps</a>
				</li>
				<li>
					<a href="/tools/downloadData.cfm">Download Tables</a>
				</li>
				<li>
					<a href="/tools/parent_child_taxonomy.cfm">Sync parent/child taxonomy</a>
				</li>
				<cfif #client.rights# contains "Admin">
				<li>
					<a href="/Admin/killBadAgentDups.cfm">Clean up 'bad duplicate of' agents</a>
				</li>
				</cfif>
			</ul>
		</td>
	</tr>
	<tr>
		<td valign="top"><strong>Manage Collection Data</strong></td>
		<td>
			<ul>
				<li>
					<a href="/CodeTableButtons.cfm">Manage code tables</a>
				</li>
				<li>
					<a href="/tools/pendingRelations.cfm">Pending Relationships</a>
				</li>
				<li>
					<a href="/Admin/Collection.cfm">Manage collections</a>
				</li>
				<li>
					<a href="/BarcodeParts.cfm">Search for specimens by catalog number</a>
				</li>
				<li>
					<a href="/Encumbrances.cfm">Manage Encumbrances</a>
				</li>
				<li>
					<a href="/Permit.cfm">Manage Permits</a>
				</li>
			</ul>
		</td>
	</tr>	
	<cfif #client.rights# contains "Update">
		<!--- no security --->
		<tr>
			<td valign="top"><strong>Administrative Stuff</strong></td>
			<td>
				<ul>
					<cfif #client.rights# contains "Admin">
						<!--- no security --->
						<li>
							<a href="/Admin/form_roles.cfm">Form Permissions</a>
						</li>
						<li>
							<a href="/info/svn.cfm">SVN</a>
						</li>
						<li>
							<a href="/Admin/dumpAll.cfm">dump</a>
						</li>
						<li>
							<a href="/info/release_notes.cfm">Release Notes</a>
						</li>
						<li>
							<a href="/ScheduledTasks/index.cfm">Manually run Scheduled Tasks</a>
						</li>
						<li>
							<a href="/AdminUsers.cfm">Manage Users</a>
						</li>
						<li>
							<a href="/Admin/user_roles.cfm">Database Roles</a>
						</li>
						<li>
							<a href="/Admin/user_report.cfm">All User Stats</a>
						</li>
						<!----
						<li>
							<a href="/Admin/UserAccessLevel.cfm">Manage Users (da future...)</a>
						</li>
						---->
						<li>
							<a href="/CFIDE/administrator/">Manage ColdFusion</a>
						</li>
						<li>
							<a href="imageList.cfm">Image List</a>
						</li>
						<li>
							<a href="sqlTaxonomy.cfm">SQL Taxonomy</a>
						</li>
					</cfif>
					
					<li>
						<a href="/Admin/download.cfm">View Download Stats</a>
					</li>
					<li>
						<a href="/Admin/ActivityLog.cfm">View SQL log</a>
					</li>
					<li>
						<a href="/Admin/cfUserLog.cfm">View user access data</a>
					</li>
					<li>
						<a href="/Admin/manage_user_loan_request.cfm">Manage user-requested loans</a>
					</li>
					<li>
						<a href="/info/UserSearchHits.cfm">Some random stats</a>
					</li>
					<li>
						<a href="/Bulkloader/browseBulk.cfm">Browse and Edit Bulkloader</a>
					</li>
					<!----
					<li>
						<a href="/Bulkloader/browseBulkedData.cfm">Browse and Edit Bulkloader</a>
					</li>---->
					
				</ul>
			</td>
		</tr>
	</cfif>
</table>



<p><cfinclude template="../includes/_footer.cfm">
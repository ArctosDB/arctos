<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
	<html>
	<head>	
		<cfinclude template="/includes/alwaysInclude.cfm">
		<link rel="stylesheet" href="/includes/css.css">
		<!--[if IE]>
		<style type="text/css" media="screen">
		body {behavior: url(/includes/csshover.htc);} 
		
		</style>
		<![endif]-->
		<script type="text/javascript" src="/includes/js.js">
	</head>			
	<body>	
	helloooooo....
	<cfoutput>
	<cfif #cgi.HTTP_USER_AGENT# contains "MSIE">
		<div align="center">
			<font color="##FF0000"  size="-1">
				<i>
					Some features of this site may not work in your browser. We recommend 
					<a href="http://www.mozilla.org/products/firefox/">FireFox</a>.
				</i>
			</font>
		</div>
	</cfif>
	<div class="mlmenu mainMenu bluewhite arrow">
		<ul>
			<li>
				<a href="/SpecimenSearch.cfm">Search</a>
				<ul>
					<li><a href="/SpecimenSearch.cfm">Specimens</a></li>
					<li><a href="/SpecimenUsage.cfm">Projects</a></li>
					<li><a href="/TaxonomySearch.cfm">Taxonomy</a></li>
					<li><a href="/BarcodeParts.cfm">Specimens by cat##</a></li>				
				</ul>
			</li>
			<li>
				<a href="/home.cfm">Stuff That We May Not Need</a>
				<ul>
					<li><a href="/home.cfm">Home</a></li>
					<li><a href="##" onClick="getInstDocs('GENERIC','index')">Help</a></li>
					<li><a href="/Collections/index.cfm">Collections</a></li>
					<li><a href="/siteMap.cfm">Site Map</a></li>
					
				</ul>
			</li>
			<li>
				<a href="##">People&Places</a>
				<ul>
					<li>
						<a href="##">People</a>
						<ul>
							<li><a href="/agents.cfm">Agents</a></li>							
							<li><a href="/AdminUsers.cfm">Arctos Users</a></li>
							<li><a href="/Admin/user_roles.cfm">Database Roles</a></li>
							<li><a href="/Admin/user_report.cfm">All User Stats</a></li>
						</ul>
					</li>
					<li>
						<a href="##">Places</a>
						<ul>
							<li><a href="##">Geog</a>
								<ul>
									<li><a href="/Locality.cfm?action=findHG">Find</a></li>
									<li><a href="/Locality.cfm?action=newHG">Create</a></li>
								</ul>
							</li>
							<li><a href="##">Locality</a>
								<ul>
									<li><a href="/Locality.cfm?action=findLO">Find</a></li>
									<li><a href="/Locality.cfm?action=newLocality">Create</a></li>
								</ul>
							</li>
							<li><a href="##">Event</a>
								<ul>
									<li><a href="/Locality.cfm?action=findCO">Find</a></li>
								</ul>
							</li>
						</ul>
					</li>
				</ul>
			</li>
			<li>
				<a href="##">Transactions</a>
				<ul>
					<li><a href="##">Accession</a>
						<ul>
							<li><a href="/newAccn.cfm">Create</a></li>
							<li><a href="/editAccn.cfm">Find</a></li>
						</ul>
					</li>
					<li><a href="##">Loan</a>
						<ul>
							<li><a href="/Loan.cfm?Action=newLoan">Create</a></li>
							<li><a href="/Loan.cfm?Action=addItems">Find</a></li>
							<li><a href="/Admin/manage_user_loan_request.cfm">User-requested</a></li>
						</ul>
					</li>
					<li><a href="##">Borrow</a>
						<ul>
							<li><a href="/borrow.cfm?action=new">Create</a></li>
							<li><a href="/borrow.cfm">Find</a></li>
						</ul>
					</li>
					<li><a href="##">Permit</a>
						<ul>
							<li><a href="/Permit.cfm?action=newPermit">Create</a></li>
							<li><a href="/Permit.cfm">Find</a></li>
						</ul>
					</li>
				</ul>
			</li>
			<li>
				<a href="##">Widgets</a>
				<ul>
					<li><a href="/Bulkloader/Bulkloader.cfm">Specimens</a>
						<ul>
							<li><a href="/Bulkloader/bulkloaderLoader.cfm">Bulkload Specimens</a></li>
							<li><a href="/DataEntry.cfm">Data Entry</a></li>
							<li><a href="/Bulkloader/bulkloader_status.cfm">Bulkloader Status</a></li>
							<li><a href="/Bulkloader/accessBL/.cfm">Templates</a></li>
							<li><a href="##" onclick="getDocs('Bulkloader/index')">Documentation</a></li>
							<li><a href="/Bulkloader/browseBulk.cfm">Browse and Edit</a></li>								
						</ul>
					</li>
					<li><a href="/tools/BulkloadAgents.cfm">Bulkload Agents</a></li>
					<li><a href="/tools/BulkloadParts.cfm">Bulkload Parts</a></li>
					<li><a href="/tools/BulkloadAttributes.cfm">Bulkload Attributes</a></li>
					<li><a href="/tools/BulkloadCitations.cfm">Bulkload Citations</a></li>
					<li><a href="/tools/BulkloadOtherId.cfm">Bulkload Identifiers</a></li>
					<li><a href="/tools/loanBulkload.cfm">Bulkload Loan Items</a></li>
					<li><a href="##">Containers</a>
						<ul>
							<li><a href="/LoadBarcodes.cfm">Load Labels</a></li>
							<li><a href="/batchScan.cfm">Scan Container</a></li>
							<li><a href="/moveContainer.cfm">Move container (old)</a></li>
							<li><a href="/a_moveContainer.cfm">Move container (boring)</a></li>
							<li><a href="/dragContainer.cfm">Move container (AJAX)</a></li>
							<li><a href="/labels2containers.cfm">Label>Container</a></li>
							<li><a href="/bits2containers.cfm">Object>>Container</a></li>
							<li><a href="/aps.cfm">Object+BC>>Container</a></li>
							<li><a href="/containerContainer.cfm">Find Containers (AJAX)</a></li>
							<li><a href="/start.cfm?action=container">Find Containers (HTML)</a></li>
							<li><a href="/EditContainer.cfm?action=newContainer">Create container</a></li>
							<li><a href="/SpecimenContainerLabels.cfm">Print label data</a></li>
							<li><a href="/CreateContainersForBarcodes.cfm?action=set">Load Specimen Labels</a></li>
							<li><a href="dgr_locator.cfm">DGR Locator</a></li>
						</ul>
					</li>
				</ul>
			</li>
			<li>
				<a href="##">SuperWidgets</a>
				<ul>
					<li>
						<a href="##">Data Widgets</a>
						<ul>
							<li><a href="/info/annotate.cfm">Annotations</a></li>
							<li><a href="/fix/fixBlCatNum.cfm">UAM Mamm BL Cat##</a></li>
							<li><a href="/tools/PublicationStatus.cfm">Publication Staging</a></li>
							<li><a href="/tools/parent_child_taxonomy.cfm">Sync parent/child taxonomy</a></li>
							<li><a href="/Admin/killBadAgentDups.cfm">Clean up 'bad duplicate of' agents</a></li>
							<li><a href="/CodeTableButtons.cfm">Code tables</a></li>
							<li><a href="/tools/pendingRelations.cfm">Pending Relationships</a></li>
							<li><a href="/Admin/Collection.cfm">Manage collections</a></li>
							<li><a href="/Encumbrances.cfm">Encumbrances</a></li>
						</ul>
					</li>
					<li>
						<a href="##">Admin Widgets</a>
						<ul>
							<li><a href="/info/CodeTableValuesVersusTableValues.cfm">CT vs Data</a></li>
							<li><a href="/tools/TaxonomyGaps.cfm">Messy Taxonomy</a></li>
							<li><a href="/tools/findGap.cfm">Catalog Number Gaps</a></li>
							<li><a href="/tools/downloadData.cfm">Download Tables</a></li>
							<li><a href="/ScheduledTasks/index.cfm">Scheduled Tasks</a></li>
							<li><a href="sqlTaxonomy.cfm">SQL Taxonomy</a></li>
						</ul>
					</li>
					<li>
						<a href="##">Developer Widgets</a>
						<ul>
							<li><a href="/info/svn.cfm">SVN</a></li>
							<li><a href="/Admin/dumpAll.cfm">dump</a></li>
							<li><a href="/CFIDE/administrator/">Manage ColdFusion</a></li>
							<li><a href="imageList.cfm">Image List</a></li>
						</ul>
					</li>
					<li>
						<a href="##">Reports</a>
						<ul>
							<li><a href="/Admin/download.cfm">Download Stats</a></li>
							<li><a href="/Admin/ActivityLog.cfm">SQL log</a></li>
							<li><a href="/Admin/cfUserLog.cfm">User access</a></li>
							<li><a href="/info/UserSearchHits.cfm">Some random stats</a></li>
						</ul>
					</li>
				</ul>
			</li>
			<li><a href="/myArctos.cfm">My Stuff</a>
				<ul>
					<li><a href="/myArctos.cfm">Preferences</a></li>
					<li><a href="/user_loan_request.cfm">Use Specimens</a></li>
					<cfif len(#client.username#) gt 0>
						<li><a href="/login.cfm?action=signOut">Log Out #client.username#</a></li>
					<cfelse>
						<li><a href="/login.cfm">Log In</a></li>
					</cfif>
				</ul>
			</li>			
		</ul>
	</div>
	
	<hr>
	<hr>
	look ma, no CSS
	<hr>
	<hr>
	<ul>
			<li>
				<a href="/SpecimenSearch.cfm">Search</a>
				<ul>
					<li><a href="/SpecimenSearch.cfm">Specimens</a></li>
					<li><a href="/SpecimenUsage.cfm">Projects</a></li>
					<li><a href="/TaxonomySearch.cfm">Taxonomy</a></li>
					<li><a href="/BarcodeParts.cfm">Specimens by cat##</a></li>				
				</ul>
			</li>
			<li>
				<a href="/home.cfm">Stuff That We May Not Need</a>
				<ul>
					<li><a href="/home.cfm">Home</a></li>
					<li><a href="##" onClick="getInstDocs('GENERIC','index')">Help</a></li>
					<li><a href="/Collections/index.cfm">Collections</a></li>
					<li><a href="/siteMap.cfm">Site Map</a></li>
					
				</ul>
			</li>
			<li>
				<a href="##">People&Places</a>
				<ul>
					<li>
						<a href="##">People</a>
						<ul>
							<li><a href="/agents.cfm">Agents</a></li>							
							<li><a href="/AdminUsers.cfm">Arctos Users</a></li>
							<li><a href="/Admin/user_roles.cfm">Database Roles</a></li>
							<li><a href="/Admin/user_report.cfm">All User Stats</a></li>
						</ul>
					</li>
					<li>
						<a href="##">Places</a>
						<ul>
							<li><a href="##">Geog</a>
								<ul>
									<li><a href="/Locality.cfm?action=findHG">Find</a></li>
									<li><a href="/Locality.cfm?action=newHG">Create</a></li>
								</ul>
							</li>
							<li><a href="##">Locality</a>
								<ul>
									<li><a href="/Locality.cfm?action=findLO">Find</a></li>
									<li><a href="/Locality.cfm?action=newLocality">Create</a></li>
								</ul>
							</li>
							<li><a href="##">Event</a>
								<ul>
									<li><a href="/Locality.cfm?action=findCO">Find</a></li>
								</ul>
							</li>
						</ul>
					</li>
				</ul>
			</li>
			<li>
				<a href="##">Transactions</a>
				<ul>
					<li><a href="##">Accession</a>
						<ul>
							<li><a href="/newAccn.cfm">Create</a></li>
							<li><a href="/editAccn.cfm">Find</a></li>
						</ul>
					</li>
					<li><a href="##">Loan</a>
						<ul>
							<li><a href="/Loan.cfm?Action=newLoan">Create</a></li>
							<li><a href="/Loan.cfm?Action=addItems">Find</a></li>
							<li><a href="/Admin/manage_user_loan_request.cfm">User-requested</a></li>
						</ul>
					</li>
					<li><a href="##">Borrow</a>
						<ul>
							<li><a href="/borrow.cfm?action=new">Create</a></li>
							<li><a href="/borrow.cfm">Find</a></li>
						</ul>
					</li>
					<li><a href="##">Permit</a>
						<ul>
							<li><a href="/Permit.cfm?action=newPermit">Create</a></li>
							<li><a href="/Permit.cfm">Find</a></li>
						</ul>
					</li>
				</ul>
			</li>
			<li>
				<a href="##">Widgets</a>
				<ul>
					<li><a href="/Bulkloader/Bulkloader.cfm">Specimens</a>
						<ul>
							<li><a href="/Bulkloader/bulkloaderLoader.cfm">Bulkload Specimens</a></li>
							<li><a href="/DataEntry.cfm">Data Entry</a></li>
							<li><a href="/Bulkloader/bulkloader_status.cfm">Bulkloader Status</a></li>
							<li><a href="/Bulkloader/accessBL/.cfm">Templates</a></li>
							<li><a href="##" onclick="getDocs('Bulkloader/index')">Documentation</a></li>
							<li><a href="/Bulkloader/browseBulk.cfm">Browse and Edit</a></li>								
						</ul>
					</li>
					<li><a href="/tools/BulkloadAgents.cfm">Bulkload Agents</a></li>
					<li><a href="/tools/BulkloadParts.cfm">Bulkload Parts</a></li>
					<li><a href="/tools/BulkloadAttributes.cfm">Bulkload Attributes</a></li>
					<li><a href="/tools/BulkloadCitations.cfm">Bulkload Citations</a></li>
					<li><a href="/tools/BulkloadOtherId.cfm">Bulkload Identifiers</a></li>
					<li><a href="/tools/loanBulkload.cfm">Bulkload Loan Items</a></li>
					<li><a href="##">Containers</a>
						<ul>
							<li><a href="/LoadBarcodes.cfm">Load Labels</a></li>
							<li><a href="/batchScan.cfm">Scan Container</a></li>
							<li><a href="/moveContainer.cfm">Move container (old)</a></li>
							<li><a href="/a_moveContainer.cfm">Move container (boring)</a></li>
							<li><a href="/dragContainer.cfm">Move container (AJAX)</a></li>
							<li><a href="/labels2containers.cfm">Label>Container</a></li>
							<li><a href="/bits2containers.cfm">Object>>Container</a></li>
							<li><a href="/aps.cfm">Object+BC>>Container</a></li>
							<li><a href="/containerContainer.cfm">Find Containers (AJAX)</a></li>
							<li><a href="/start.cfm?action=container">Find Containers (HTML)</a></li>
							<li><a href="/EditContainer.cfm?action=newContainer">Create container</a></li>
							<li><a href="/SpecimenContainerLabels.cfm">Print label data</a></li>
							<li><a href="/CreateContainersForBarcodes.cfm?action=set">Load Specimen Labels</a></li>
							<li><a href="dgr_locator.cfm">DGR Locator</a></li>
						</ul>
					</li>
				</ul>
			</li>
			<li>
				<a href="##">SuperWidgets</a>
				<ul>
					<li>
						<a href="##">Data Widgets</a>
						<ul>
							<li><a href="/info/annotate.cfm">Annotations</a></li>
							<li><a href="/fix/fixBlCatNum.cfm">UAM Mamm BL Cat##</a></li>
							<li><a href="/tools/PublicationStatus.cfm">Publication Staging</a></li>
							<li><a href="/tools/parent_child_taxonomy.cfm">Sync parent/child taxonomy</a></li>
							<li><a href="/Admin/killBadAgentDups.cfm">Clean up 'bad duplicate of' agents</a></li>
							<li><a href="/CodeTableButtons.cfm">Code tables</a></li>
							<li><a href="/tools/pendingRelations.cfm">Pending Relationships</a></li>
							<li><a href="/Admin/Collection.cfm">Manage collections</a></li>
							<li><a href="/Encumbrances.cfm">Encumbrances</a></li>
						</ul>
					</li>
					<li>
						<a href="##">Admin Widgets</a>
						<ul>
							<li><a href="/info/CodeTableValuesVersusTableValues.cfm">CT vs Data</a></li>
							<li><a href="/tools/TaxonomyGaps.cfm">Messy Taxonomy</a></li>
							<li><a href="/tools/findGap.cfm">Catalog Number Gaps</a></li>
							<li><a href="/tools/downloadData.cfm">Download Tables</a></li>
							<li><a href="/ScheduledTasks/index.cfm">Scheduled Tasks</a></li>
							<li><a href="sqlTaxonomy.cfm">SQL Taxonomy</a></li>
						</ul>
					</li>
					<li>
						<a href="##">Developer Widgets</a>
						<ul>
							<li><a href="/info/svn.cfm">SVN</a></li>
							<li><a href="/Admin/dumpAll.cfm">dump</a></li>
							<li><a href="/CFIDE/administrator/">Manage ColdFusion</a></li>
							<li><a href="imageList.cfm">Image List</a></li>
						</ul>
					</li>
					<li>
						<a href="##">Reports</a>
						<ul>
							<li><a href="/Admin/download.cfm">Download Stats</a></li>
							<li><a href="/Admin/ActivityLog.cfm">SQL log</a></li>
							<li><a href="/Admin/cfUserLog.cfm">User access</a></li>
							<li><a href="/info/UserSearchHits.cfm">Some random stats</a></li>
						</ul>
					</li>
				</ul>
			</li>
			<li><a href="/myArctos.cfm">My Stuff</a>
				<ul>
					<li><a href="/myArctos.cfm">Preferences</a></li>
					<li><a href="/user_loan_request.cfm">Use Specimens</a></li>
					<cfif len(#client.username#) gt 0>
						<li><a href="/login.cfm?action=signOut">Log Out #client.username#</a></li>
					<cfelse>
						<li><a href="/login.cfm">Log In</a></li>
					</cfif>
				</ul>
			</li>			
		</ul>
</cfoutput>
<div class="content">

</div>
</body>
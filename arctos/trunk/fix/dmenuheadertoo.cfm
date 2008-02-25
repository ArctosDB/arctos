<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> 
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="content-type" content="text/html; charset=iso-8859-1"></meta>
<title>ooo- buttons</title>
<style type="text/css" media="screen"> 
@import "/includes/mainMenu.css"; 
</style>
<!--[if IE]>
<style type="text/css" media="screen">
 #menu ul li {float: left; width: 100%;}
</style>
<![endif]-->
<!--[if lt IE 7]>
<style type="text/css" media="screen">
body {
behavior: url(/includes/csshover.htc);
font-size: 100%;
} 
#menu ul li {float: left; width: 100%;}
#menu ul li a {height: 1%;} 

#menu a, #menu h2 {
font: bold 0.7em/1.4em arial, helvetica, sans-serif;
} 

</style>
<![endif]-->
<cfinclude template="/includes/alwaysInclude.cfm">
<script>
	function bla () {
		setTimeout("nope()",3000); 
	}
	function nope (){
	alert('nope');
	}
</script>
</head>
<body>
<div style='background-color:#E7E7E7;'>
	<table width="95%" cellpadding="0" cellspacing="0">
		<tr>
			<td width="95" nowrap>
				<a href="/Collections"><img src="/images/genericHeaderIcon.gif" alt="Arctos" border="0"></a>
			</td>
			<td align="left">
				<table>
					<tr>
						<td rowspan="2">
							<img src="/images/nada.gif" width="15px" border="0" alt="spacer">
						</td>
						<td align="left" nowrap>
						</td>
					</tr>
					<tr>
						<td align="left" nowrap>
							<a href="/SpecimenSearch.cfm" class="novisit">
										<span style="font-family:Arial, Helvetica, sans-serif;  font-size:24px; color:#000066;">
										Arctos</span>
							</a>
							<br>
							<a href="/Collections" class="novisit">
							<span style="font-family:Arial, Helvetica, sans-serif;color:#000066; font-weight:bold;">
								Multi-Institution, Multi-Collection Museum Database</span>
							</a>
						</td>
					</tr>			 
				</table>
			</td>
		</tr>
	</table>

<cfoutput>
<div id="menu">
<ul>
	<li><h2>Search</h2>
		<ul>
			<li><a href="/SpecimenSearch.cfm">Specimens</a></li>
			<li><a href="/SpecimenUsage.cfm">Projects</a></li>
			<li><a href="/TaxonomySearch.cfm">Taxonomy</a></li>
		</ul>
	</li> 
</ul>
<ul>
	<li><h2>People&Places</h2>
		<ul>
			<li>
				<a href="##" class="x">People</a>
				<ul>
					<li><a href="/agents.cfm">Agents</a></li>							
					<li><a href="/AdminUsers.cfm">Arctos Users</a></li>
					<li><a href="/Admin/user_roles.cfm">Database Roles</a></li>
					<li><a href="/Admin/user_report.cfm">All User Stats</a></li>
				</ul>
			</li>
			<li>
				<a href="##" class="x">Places</a>
				<ul>
					<li><a href="##"  class="x">Geog</a>
						<ul>
							<li><a href="/Locality.cfm?action=findHG">Find</a></li>
							<li><a href="/Locality.cfm?action=newHG">Create</a></li>
						</ul>
					</li>
					<li><a href="##"  class="x">Locality</a>
						<ul>
							<li><a href="/Locality.cfm?action=findLO">Find</a></li>
							<li><a href="/Locality.cfm?action=newLocality">Create</a></li>
						</ul>
					</li>
					<li><a href="##" class="x">Event</a>
						<ul>
							<li><a href="/Locality.cfm?action=findCO">Find</a></li>
						</ul>
					</li>
				</ul>
			</li>
		</ul>
	</li>
</ul>
<ul>
	<li><h2>Transactions</h2>
		<ul>
			<li><a href="##" class="x">Accession</a>
				<ul>
					<li><a href="/newAccn.cfm">Create</a></li>
					<li><a href="/editAccn.cfm">Find</a></li>
				</ul>
			</li>
			<li><a href="##" class="x">Loan</a>
				<ul>
					<li><a href="/Loan.cfm?Action=newLoan">Create</a></li>
					<li><a href="/Loan.cfm?Action=addItems">Find</a></li>
					<li><a href="/Admin/manage_user_loan_request.cfm">User-requested</a></li>
				</ul>
			</li>
			<li><a href="##" class="x">Borrow</a>
				<ul>
					<li><a href="/borrow.cfm?action=new">Create</a></li>
					<li><a href="/borrow.cfm">Find</a></li>
				</ul>
			</li>
			<li><a href="##" class="x">Permit</a>
				<ul>
					<li><a href="/Permit.cfm?action=newPermit">Create</a></li>
					<li><a href="/Permit.cfm">Find</a></li>
				</ul>
			</li>
		</ul>
	</li>
</ul>
<ul>
	<li>
		<h2>Widgets</h2>
		<ul>
			<li><a href="/Bulkloader/Bulkloader.cfm" class="x">Specimens</a>
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
			<li><a href="##" class="x">Containers</a>
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
</ul>
<ul>
	<li>
		<h2>SuperWidgets</h2>
		<ul>
			<li>
				<h2>Data Widgets</h2>
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
				<a href="##" class="x">Admin Widgets</a>
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
				<a href="##" class="x">Developer Widgets</a>
				<ul>
					<li><a href="/info/svn.cfm">SVN</a></li>
					<li><a href="/Admin/dumpAll.cfm">dump</a></li>
					<li><a href="/CFIDE/administrator/">Manage ColdFusion</a></li>
					<li><a href="imageList.cfm">Image List</a></li>
				</ul>
			</li>
			<li>
				<a href="##" class="x">Reports</a>
				<ul>
					<li><a href="/Admin/download.cfm">Download Stats</a></li>
					<li><a href="/Admin/ActivityLog.cfm">SQL log</a></li>
					<li><a href="/Admin/cfUserLog.cfm">User access</a></li>
					<li><a href="/info/UserSearchHits.cfm">Some random stats</a></li>
				</ul>
			</li>
		</ul>
	</li>
</ul>
<ul>
	<li><h2>My Stuff</h2>
		<ul>
			<cfif len(#client.username#) gt 0>
				<li><a href="/login.cfm?action=signOut">Log Out #client.username#</a></li>
				<li><a href="/myArctos.cfm">Preferences</a></li>
			<cfelse>
				<li><a href="/login.cfm">Log In</a></li>
			</cfif>
			<li><a href="##" onClick="getInstDocs('GENERIC','index')">Help</a></li>
			<li><a href="/home.cfm">Home</a></li>
			<li><a href="/Collections/index.cfm">Collections</a></li>
			<li><a href="/siteMap.cfm">Site Map</a></li>
			<li><a href="/user_loan_request.cfm">Use Specimens</a></li>
		</ul>
	</li>		
</ul>

</div>
</div>
</cfoutput>

<hr>

</body>
</html>
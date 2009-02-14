<!--- see if there's a collection that we should be trying to look good for --->
<cfif isdefined("session.exclusive_collection_id") and len(#session.exclusive_collection_id#) gt 0>
	<!--- 
		create table cf_collection_appearance (
			collection_id number not null,
			header_color varchar2(20) not null,
			header_image varchar2(255) not null,
			collection_url varchar2(255) not null,
			collection_link_text varchar2(60) not null,
			institution_url varchar2(255) not null,
			institution_link_text varchar2(60) not null,
			meta_description varchar2(255) not null,
			meta_keywords varchar2(255) not null
		);
			
		create or replace public synonym cf_collection_appearance for cf_collection_appearance;
		grant all on cf_collection_appearance to manage_collection;
		grant select on cf_collection_appearance to public;

		ALTER TABLE cf_collection_appearance
		add CONSTRAINT fk_collection
  		FOREIGN KEY (collection_id)
  		REFERENCES collection(collection_id);
	--->
	<cfif not isdefined("session.header_color") or len(#session.header_color#) is 0>
		<!--- assign client variables - otherwise, no reason to repeat --->
		<cfquery name="getCollApp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from collection_appearance where collection_id = #session.exclusive_collection_id#
		</cfquery>
		<cfif #getCollApp.recordcount# gt 0>
			<!--- they have an entry --->
			<cfset session.header_color = getCollApp.header_color>
			<cfset session.header_image = getCollApp.header_image>
			<cfset session.collection_url = getCollApp.collection_url>
			<cfset session.collection_link_text = getCollApp.collection_link_text>
			<cfset session.institution_url = getCollApp.institution_url>
			<cfset session.institution_link_text = getCollApp.institution_link_text>
			<cfset session.meta_description = getCollApp.meta_description>
			<cfset session.meta_keywords = getCollApp.meta_keywords>
		<cfelse>
			<!--- collection has not set up customization --->
			<cfset session.header_color = Application.header_color>
			<cfset session.header_image = Application.header_image>
			<cfset session.collection_url = Application.collection_url>
			<cfset session.collection_link_text = Application.collection_link_text>
			<cfset session.institution_url = Application.institution_url>
			<cfset session.institution_link_text = Application.institution_link_text>
			<cfset session.meta_description = Application.meta_description>
			<cfset session.meta_keywords = Application.meta_keywords>
		</cfif>
	</cfif>		
<cfelse>
			<!--- collection has not set up customization --->
			<cfset session.header_color = Application.header_color>
			<cfset session.header_image = Application.header_image>
			<cfset session.collection_url = Application.collection_url>
			<cfset session.collection_link_text = Application.collection_link_text>
			<cfset session.institution_url = Application.institution_url>
			<cfset session.institution_link_text = Application.institution_link_text>
			<cfset session.meta_description = Application.meta_description>
			<cfset session.meta_keywords = Application.meta_keywords>
</cfif> 
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> 
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<cfinclude template="/Application.cfm">
<cfoutput>
<meta name="keywords" content="##">
<meta name="description" content="Arctos is a biological specimen database at the University of Alaska Museum of the North.">
<LINK REL="SHORTCUT ICON" HREF="/images/favicon.ico">
<script type='text/javascript' src='/ajax/core/engine.js'></script>
<script type='text/javascript' src='/ajax/core/util.js'></script>
<script type='text/javascript' src='/ajax/core/settings.js'></script>
<link rel="stylesheet" type="text/css" href="/includes/style.css" >
<link rel="alternate stylesheet" type="text/css" href="/includes/nbsb_style.css" title="NBSB" >
<link rel="alternate stylesheet" type="text/css" href="/includes/msb_style.css" title="MSB" >
<link rel="alternate stylesheet" type="text/css" href="/includes/uam_style.css" title="UAM" >
<script language="JavaScript" src="/includes/_overlib.js" type="text/javascript"></script>
<script src="http://www.google-analytics.com/urchin.js" type="text/javascript"></script>
<script type="text/javascript">_uacct = "#Application.Google_uacct#";urchinTracker();</script>
<meta http-equiv="content-type" content="text/html; charset=iso-8859-1"></meta>
<title>ooo- buttons</title>
<style type="text/css" media="screen"> 
@import "/includes/mainMenu.css"; 
</style>
<!--[if IE]>
<style type="text/css" media="screen">
 ##menu ul li {float: left; width: 100%;}
</style>
<![endif]-->
<!--[if lt IE 7]>
<style type="text/css" media="screen">
body {
behavior: url(/includes/csshover.htc);
font-size: 100%;
} 
##menu ul li {float: left; width: 100%;}
##menu ul li a {height: 1%;} 

##menu a, ##menu h2 {
font: bold 0.7em/1.4em arial, helvetica, sans-serif;
} 

</style>
<![endif]-->
</head>
<body>
<cfif #cgi.HTTP_USER_AGENT# contains "4.7">
		<font color="##FF0000">
			<i>
				This page does not function properly with Netscape 4.7.
				<br>Please see our <a href="/About.cfm?Action=sys">System Requirements</a>.
			</i>
		</font>
	<cfelseif #cgi.HTTP_USER_AGENT# contains "MSIE">
		<div align="center">
			<font color="##FF0000"  size="-1">
				<i>
					Some features of this site may not work in your browser. We recommend 
					<a href="http://www.mozilla.org/products/firefox/">FireFox</a>.
				</i>
			</font>
		</div>
	</cfif>
<div style='background-color:#session.header_color#;'>
	<table width="95%" cellpadding="0" cellspacing="0">
		<tr>
			<td width="95" nowrap>
				<a href="#session.collection_url#"><img src="#session.header_image#" alt="Arctos" border="0"></a>
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
							<a href="#session.collection_url#" class="novisit">
										<span style="font-family:Arial, Helvetica, sans-serif;  font-size:24px; color:##000066;">
										Arctos</span>
							</a>
							<br>
							<a href="#session.institution_url#" class="novisit">
							<span style="font-family:Arial, Helvetica, sans-serif;color:##000066; font-weight:bold;">
								#session.institution_link_text#</span>
							</a>
						</td>
					</tr>			 
				</table>
			</td>
		</tr>
	</table>

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
<cfif isdefined("session.roles") and len(#session.roles#) gt 0>
	<!--- see what forms this user gets access to --->
	<cfset r = replace(session.roles,",","','","all")>
	<cfset r = "'#r#'">
	<!---  cachedWithin="#CreateTimeSpan(0,1,0,0)#" --->
<cfquery name="roles" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select form_path from cf_form_permissions 
	where upper(role_name) IN (#ucase(preservesinglequotes(r))#)
</cfquery>
<cfset formList = valuelist(roles.form_path)>
<ul>
	<li><h2>Add</h2>
		<ul>
			<cfif listfind(formList,"/agents.cfm")>
				<li><a href="/agents.cfm">Agents</a></li>
			</cfif>
			<cfif listfind(formList,"/Loan.cfm")>
				<li><a href="/Loan.cfm?Action=newLoan">Loan</a></li>
			</cfif>
			<cfif listfind(formList,"/Locality.cfm")>
				<li><a href="/Locality.cfm?action=newHG">Geography</a></li>
				<li><a href="/Locality.cfm?action=newLocality">Locality</a></li>
			</cfif>			
			<cfif listfind(formList,"/newAccn.cfm")>
				<li><a href="/newAccn.cfm">Accession</a></li>
			</cfif>	
			<cfif listfind(formList,"/borrow.cfm")>
				<li><a href="/borrow.cfm?action=new">Borrow</a></li>
			</cfif>
			<cfif listfind(formList,"/Permit.cfm")>
				<li><a href="/Permit.cfm?action=newPermit">Permit</a></li>
			</cfif>
			
			
			<li><a href="##" class="x">Specimens</a>
				<ul>
					<cfif listfind(formList,"/Bulkloader/Bulkloader.cfm")>
						<li><a href="/Bulkloader/Bulkloader.cfm">Bulkloader</a></li>
						<li><a href="/Bulkloader/bulkloaderLoader.cfm">Bulkload Specimens</a></li>
					</cfif>
					<cfif listfind(formList,"/DataEntry.cfm")>
						<li><a href="/DataEntry.cfm">Data Entry</a></li>
					</cfif>
				</ul>
			</li>
			<cfif listfind(formList,"/tools/BulkloadParts.cfm")>
				<li><a href="##" class="x">Bulkloaders</a>
					<ul>
						<li><a href="/tools/BulkloadParts.cfm">Bulkload Parts</a></li>
						<li><a href="/tools/BulkloadAttributes.cfm">Bulkload Attributes</a></li>
						<li><a href="/tools/BulkloadCitations.cfm">Bulkload Citations</a></li>
						<li><a href="/tools/BulkloadOtherId.cfm">Bulkload Identifiers</a></li>
						<li><a href="/tools/loanBulkload.cfm">Bulkload Loan Items</a></li>
						<li><li><a href="/tools/BulkloadAgents.cfm">Bulkload Agents</a></li></li>
					</ul>
				</li>
			</cfif>
			<cfif listfind(formList,"/EditContainer.cfm")>
				<li><a href="##" class="x">Containers</a>
					<ul>
						<li><a href="/LoadBarcodes.cfm">Load Labels</a></li>
						<li><a href="/EditContainer.cfm?action=newContainer">Create container</a></li>
						<li><a href="/SpecimenContainerLabels.cfm">Print label data</a></li>
						<li><a href="/CreateContainersForBarcodes.cfm?action=set">Load Specimen Labels</a></li>
					</ul>
				</li>
			</cfif>			
		</ul>
	</li>
</ul>
<ul>
	<li><h2>Update</h2>
		<ul>
			<li><a href="##" class="x">Containers</a>
				<ul>
					<cfif listfind(formList,"/dgr_locator.cfm")>
						<li><a href="/tools/dgr_locator.cfm">DGR Locator</a></li>
					</cfif>
					<cfif listfind(formList,"/moveContainer.cfm")>
						<li><a href="/batchScan.cfm">Scan Container</a></li>
						<li><a href="/moveContainer.cfm">Move container (old)</a></li>
						<li><a href="/a_moveContainer.cfm">Move container (boring)</a></li>
						<li><a href="/dragContainer.cfm">Move container (AJAX)</a></li>
						<li><a href="/labels2containers.cfm">Label>Container</a></li>
						<li><a href="/bits2containers.cfm">Object>>Container</a></li>
						<li><a href="/aps.cfm">Object+BC>>Container</a></li>
						<li><a href="/containerContainer.cfm">Find Containers (AJAX)</a></li>
						<li><a href="/start.cfm?action=container">Find Containers (HTML)</a></li>
					</cfif>						
				</ul>
			</li>
			<cfif listfind(formList,"/agents.cfm")>
				<li><a href="/agents.cfm">Agents</a></li>
			</cfif>
			<cfif listfind(formList,"/Locality.cfm")>
				<li><a href="##" class="x">Location</a>
					<ul>
						<li><a href="/Locality.cfm?action=findHG">Geography</a></li>
						<li><a href="/Locality.cfm?action=findLO">Locality</a></li>
					</ul>
				</li>
			</cfif>
			<cfif listfind(formList,"/editAccn.cfm")>
				<li><a href="##" class="x">Transaction</a>
					<ul>
						<li><a href="/editAccn.cfm">Accession</a></li>
						<li><a href="/Loan.cfm?Action=addItems">Loan</a></li>
						<li><a href="/borrow.cfm">Borrow</a></li>
						<li><a href="/Permit.cfm">Permit</a></li>
					</ul>
				</li>
			</cfif>
			<cfif listfind(formList,"/AdminUsers.cfm")>
				<li><a href="##" class="x">Arctos User</a>
					<ul>
						<li><a href="/AdminUsers.cfm">Arctos Users</a></li>
						<li><a href="/Admin/user_roles.cfm">Database Roles</a></li>
						<li><a href="/Admin/user_report.cfm">All User Stats</a></li>
						<li><a href="/Admin/manage_user_loan_request.cfm">User-requested</a></li>
					</ul>
				</li>
			</cfif>			
		</ul>	
	</li>
</ul>
<ul>
	<li>
		<h2>Widgets</h2>
		<ul>
			<li><li><a href="##" class="x">Specimen Loader</a>
				<ul>
					<cfif listfind(formList,"/Bulkloader/bulkloader_status.cfm")>
						<li><a href="/Bulkloader/bulkloader_status.cfm">Bulkloader Status</a></li>
						<li><a href="/Bulkloader/accessBL/.cfm">Templates</a></li>
					</cfif>
					<li><a href="##" onclick="getDocs('Bulkloader/index')">Documentation</a></li>
					<cfif listfind(formList,"/Bulkloader/browseBulk.cfm")>
						<li><a href="/Bulkloader/browseBulk.cfm">Browse and Edit</a></li>
					</cfif>					
				</ul>
			</li>
			<cfif listfind(formList,"/tools/sqlTaxonomy.cfm")>
				<li><a href="/tools/sqlTaxonomy.cfm">SQL Taxonomy</a></li>
			</cfif>
			<cfif listfind(formList,"/info/annotate.cfm")>
				<li><a href="/info/annotate.cfm">Annotations</a></li>
				<li><a href="/fix/fixBlCatNum.cfm">UAM Mamm BL Cat##</a></li>
				<li><a href="/tools/PublicationStatus.cfm">Publication Staging</a></li>
				<li><a href="/tools/parent_child_taxonomy.cfm">Sync parent/child taxonomy</a></li>
				<li><a href="/Admin/killBadAgentDups.cfm">Clean up 'bad duplicate of' agents</a></li>
				<li><a href="/CodeTableButtons.cfm">Code tables</a></li>
				<li><a href="/tools/pendingRelations.cfm">Pending Relationships</a></li>
				<li><a href="/Admin/Collection.cfm">Manage collections</a></li>
				<li><a href="/Encumbrances.cfm">Encumbrances</a></li>
			</cfif>
			<cfif listfind(formList,"/info/svn.cfm")>
				<li>
					<a href="##" class="x">Developer Widgets</a>
					<ul>
						<li><a href="/ScheduledTasks/index.cfm">Scheduled Tasks</a></li>
						<li><a href="/info/svn.cfm">SVN</a></li>
						<li><a href="/Admin/dumpAll.cfm">dump</a></li>
						<li><a href="/CFIDE/administrator/">Manage ColdFusion</a></li>
						<li><a href="imageList.cfm">Image List</a></li>
					</ul>
				</li>
			</cfif>			
		</ul>
	</li>
</ul>
<cfif listfind(formList,"/Admin/ActivityLog.cfm")>
<ul>
	<li><h2>Reports</h2>
		<ul>
			<li><a href="/Admin/download.cfm">Download Stats</a></li>
			<li><a href="/Admin/ActivityLog.cfm">SQL log</a></li>
			<li><a href="/Admin/cfUserLog.cfm">User access</a></li>
			<li><a href="/info/UserSearchHits.cfm">Some random stats</a></li>
			<li><a href="/info/CodeTableValuesVersusTableValues.cfm">CT vs Data</a></li>
			<li><a href="/tools/TaxonomyGaps.cfm">Messy Taxonomy</a></li>
			<li><a href="/tools/findGap.cfm">Catalog Number Gaps</a></li>
			<li><a href="/tools/downloadData.cfm">Download Tables</a></li>
		</ul>
	</li>
</ul>
</cfif>
</cfif>	
<ul>
	<li><h2>My Stuff</h2>
		<ul>
			<cfif len(#session.username#) gt 0>
				<li><a href="/login.cfm?action=signOut">Log Out #session.username#</a></li>
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
	<li><h2>Add</h2>
		<ul>
			<li><a href="/agents.cfm">Agents</a></li>
			<li><a href="/Loan.cfm?Action=newLoan">Loan</a></li>
			<li><a href="/Locality.cfm?action=newHG">Geography</a></li>
			<li><a href="/Locality.cfm?action=newLocality">Locality</a></li>
			<li><a href="/newAccn.cfm">Accession</a></li>
			<li><a href="/borrow.cfm?action=new">Borrow</a></li>
			<li><a href="/Permit.cfm?action=newPermit">Permit</a></li>
			<li><a href="/Bulkloader/Bulkloader.cfm" class="x">Specimens</a>
				<ul>
					<li><a href="/Bulkloader/bulkloaderLoader.cfm">Bulkload Specimens</a></li>
					<li><a href="/DataEntry.cfm">Data Entry</a></li>
				</ul>
			</li>
			<li><a href="##" class="x">Bulkloaders</a>
				<ul>
					<li><a href="/tools/BulkloadParts.cfm">Bulkload Parts</a></li>
					<li><a href="/tools/BulkloadAttributes.cfm">Bulkload Attributes</a></li>
					<li><a href="/tools/BulkloadCitations.cfm">Bulkload Citations</a></li>
					<li><a href="/tools/BulkloadOtherId.cfm">Bulkload Identifiers</a></li>
					<li><a href="/tools/loanBulkload.cfm">Bulkload Loan Items</a></li>
					<li><li><a href="/tools/BulkloadAgents.cfm">Bulkload Agents</a></li></li>
				</ul>
			</li>
			<li><a href="##" class="x">Containers</a>
				<ul>
					<li><a href="/LoadBarcodes.cfm">Load Labels</a></li>
					<li><a href="/EditContainer.cfm?action=newContainer">Create container</a></li>
					<li><a href="/SpecimenContainerLabels.cfm">Print label data</a></li>
					<li><a href="/CreateContainersForBarcodes.cfm?action=set">Load Specimen Labels</a></li>
				</ul>
			</li>
			
					
					
									
		</ul>
		
	</li>
</ul>
<ul>
	<li><h2>Update</h2>
		<ul>
			<li><a href="##" class="x">Containers</a>
				<ul>
					<li><a href="dgr_locator.cfm">DGR Locator</a></li>
					<li><a href="/batchScan.cfm">Scan Container</a></li>
					<li><a href="/moveContainer.cfm">Move container (old)</a></li>
					<li><a href="/a_moveContainer.cfm">Move container (boring)</a></li>
					<li><a href="/dragContainer.cfm">Move container (AJAX)</a></li>
					<li><a href="/labels2containers.cfm">Label>Container</a></li>
					<li><a href="/bits2containers.cfm">Object>>Container</a></li>
					<li><a href="/aps.cfm">Object+BC>>Container</a></li>
					<li><a href="/containerContainer.cfm">Find Containers (AJAX)</a></li>
					<li><a href="/start.cfm?action=container">Find Containers (HTML)</a></li>
					
				</ul>
			</li>
			<li><a href="/agents.cfm">Agents</a></li>
			<li><a href="##" class="x">Location</a>
				<ul>
					<li><a href="/Locality.cfm?action=findHG">Geography</a></li>
					<li><a href="/Locality.cfm?action=findLO">Locality</a></li>
				</ul>
			</li>
			<li><a href="##" class="x">Transaction</a>
				<ul>
					<li><a href="/editAccn.cfm">Accession</a></li>
					<li><a href="/Loan.cfm?Action=addItems">Loan</a></li>
					<li><a href="/borrow.cfm">Borrow</a></li>
					<li><a href="/Permit.cfm">Permit</a></li>
				</ul>
			</li>
			
			<li><a href="##" class="x">Arctos User</a>
				<ul>
					<li><a href="/AdminUsers.cfm">Arctos Users</a></li>
					<li><a href="/Admin/user_roles.cfm">Database Roles</a></li>
					<li><a href="/Admin/user_report.cfm">All User Stats</a></li>
					<li><a href="/Admin/manage_user_loan_request.cfm">User-requested</a></li>
				</ul>
			</li>
		</ul>
	
	</li>
</ul>
<ul>
	<li>
		<h2>Widgets</h2>
		<ul>
			<li><li><a href="##" class="x">Specimen Loader</a>
				<ul>
					<li><a href="/Bulkloader/bulkloader_status.cfm">Bulkloader Status</a></li>
					<li><a href="/Bulkloader/accessBL/.cfm">Templates</a></li>
					<li><a href="##" onclick="getDocs('Bulkloader/index')">Documentation</a></li>
					<li><a href="/Bulkloader/browseBulk.cfm">Browse and Edit</a></li>
				</ul>
			</li>
			<li><a href="sqlTaxonomy.cfm">SQL Taxonomy</a></li>
			
			
			<li><a href="/info/annotate.cfm">Annotations</a></li>
			<li><a href="/fix/fixBlCatNum.cfm">UAM Mamm BL Cat##</a></li>
			<li><a href="/tools/PublicationStatus.cfm">Publication Staging</a></li>
			<li><a href="/tools/parent_child_taxonomy.cfm">Sync parent/child taxonomy</a></li>
			<li><a href="/Admin/killBadAgentDups.cfm">Clean up 'bad duplicate of' agents</a></li>
			<li><a href="/CodeTableButtons.cfm">Code tables</a></li>
			<li><a href="/tools/pendingRelations.cfm">Pending Relationships</a></li>
			<li><a href="/Admin/Collection.cfm">Manage collections</a></li>
			<li><a href="/Encumbrances.cfm">Encumbrances</a></li>
			<li>
				<a href="##" class="x">Developer Widgets</a>
				<ul>
					<li><a href="/ScheduledTasks/index.cfm">Scheduled Tasks</a></li>
					<li><a href="/info/svn.cfm">SVN</a></li>
					<li><a href="/Admin/dumpAll.cfm">dump</a></li>
					<li><a href="/CFIDE/administrator/">Manage ColdFusion</a></li>
					<li><a href="imageList.cfm">Image List</a></li>
				</ul>
			</li>
			
		</ul>
	</li>
</ul>
<ul>
	<li><h2>Reports</h2>
		<ul>
			<li><a href="/Admin/download.cfm">Download Stats</a></li>
			<li><a href="/Admin/ActivityLog.cfm">SQL log</a></li>
			<li><a href="/Admin/cfUserLog.cfm">User access</a></li>
			<li><a href="/info/UserSearchHits.cfm">Some random stats</a></li>
			<li><a href="/info/CodeTableValuesVersusTableValues.cfm">CT vs Data</a></li>
			<li><a href="/tools/TaxonomyGaps.cfm">Messy Taxonomy</a></li>
			<li><a href="/tools/findGap.cfm">Catalog Number Gaps</a></li>
			<li><a href="/tools/downloadData.cfm">Download Tables</a></li>
		</ul>
	</li>
</ul>

	
<ul>
	<li><h2>My Stuff</h2>
		<ul>
			<cfif len(#session.username#) gt 0>
				<li><a href="/login.cfm?action=signOut">Log Out #session.username#</a></li>
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
</body>
</html>
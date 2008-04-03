<!---
	no cookie, no username: do nothing
	has cookie, no username: do nothing
	no cookie, has username: log out immediate
	has cookie, has username: check cookie age

	<cfset Application.session_timeout=1>
<cfif len("client.username") gt 0>
	<cfif not isdefined("cookie.ArctosSession")>
		<cfloop collection="#session#" item="i">
			<cfset temp = StructDelete(session,i)>
		</cfloop>
		<cfloop collection="#client#" item="i">
			<cfset temp = StructDelete(client,i)>
		</cfloop>
		<cflogout>
		<!---- defeat goofy BUG that puts 500 NULL at the bottom of every page --->
		<cfset client.HitCount=0>
		<cfcookie name="ArctosSession" value="-" expires="NOW" domain="#Application.domain#" path="/">
	<cfelse>
		<cfset thisTime = #dateconvert('local2Utc',now())#>
		<cfset cookieTime = #cookie.ArctosSession#>
		<cfset cage = DateDiff("n",cookieTime, thisTime)>
		<cfset tleft = Application.session_timeout - cage>
		<cfif tleft lte 0>
			<cfcookie name="ArctosSession" value="-" expires="NOW" domain="#Application.domain#" path="/">
			<cfloop collection="#session#" item="i">
				<cfset temp = StructDelete(session,i)>
			</cfloop>
			<cfloop collection="#client#" item="i">
				<cfset temp = StructDelete(client,i)>
			</cfloop>
			<cflogout>
			<!---- defeat goofy BUG that puts 500 NULL at the bottom of every page --->
			<cfset client.HitCount=0>
		</cfif>
	</cfif>
</cfif>	
--->
<!--- see if there's a collection that we should be trying to look good for --->
<cfif isdefined("client.exclusive_collection_id") and len(#client.exclusive_collection_id#) gt 0>
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
			meta_keywords varchar2(255) not null,
			stylesheet varchar2(60) not null
		);
			
		create or replace public synonym cf_collection_appearance for cf_collection_appearance;
		grant all on cf_collection_appearance to manage_collection;
		grant select on cf_collection_appearance to public;

		ALTER TABLE cf_collection_appearance
		add CONSTRAINT fk_collection
  		FOREIGN KEY (collection_id)
  		REFERENCES collection(collection_id);
	--->
		<cfquery name="getCollApp" datasource="#Application.web_user#" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
			select * from cf_collection_appearance where collection_id = #client.exclusive_collection_id#
		</cfquery>
		<cfif #getCollApp.recordcount# gt 0>
			<!--- they have an entry --->
			<cfset Client.header_color = getCollApp.header_color>
			<cfset Client.header_image = getCollApp.header_image>
			<cfset Client.collection_url = getCollApp.collection_url>
			<cfset Client.collection_link_text = getCollApp.collection_link_text>
			<cfset Client.institution_url = getCollApp.institution_url>
			<cfset Client.institution_link_text = getCollApp.institution_link_text>
			<cfset Client.meta_description = getCollApp.meta_description>
			<cfset Client.meta_keywords = getCollApp.meta_keywords>
			<cfset Client.stylesheet = getCollApp.stylesheet>
		<cfelse>
			<!--- collection has not set up customization --->
			<cfset Client.header_color = Application.header_color>
			<cfset Client.header_image = Application.header_image>
			<cfset Client.collection_url = Application.collection_url>
			<cfset Client.collection_link_text = Application.collection_link_text>
			<cfset Client.institution_url = Application.institution_url>
			<cfset Client.institution_link_text = Application.institution_link_text>
			<cfset Client.meta_description = Application.meta_description>
			<cfset Client.meta_keywords = Application.meta_keywords>
			<cfset Client.stylesheet = Application.stylesheet>
		</cfif>
<cfelse>
			<!--- collection has not set up customization --->
			<cfset Client.header_color = Application.header_color>
			<cfset Client.header_image = Application.header_image>
			<cfset Client.collection_url = Application.collection_url>
			<cfset Client.collection_link_text = Application.collection_link_text>
			<cfset Client.institution_url = Application.institution_url>
			<cfset Client.institution_link_text = Application.institution_link_text>
			<cfset Client.meta_description = Application.meta_description>
			<cfset Client.meta_keywords = Application.meta_keywords>
			<cfset Client.stylesheet = Application.stylesheet>
</cfif> 
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"> 
<head>
<cfoutput>
<meta name="keywords" content="#Client.meta_keywords#">
<meta name="description" content="#Client.meta_description#">
<LINK REL="SHORTCUT ICON" HREF="/images/favicon.ico">
<cfinclude template="/includes/alwaysInclude.cfm"><!--- keep this stuff accessible from non-header-having files --->
<meta http-equiv="content-type" content="text/html; charset=iso-8859-1">
<cfset ssName = replace(Client.stylesheet,".css","","all")>
<link rel="alternate stylesheet" type="text/css" href="/includes/css/#Client.stylesheet#" title="#ssName#">
<META http-equiv="Default-Style" content="#ssName#">
<style type="text/css" media="screen"> 
@import "/includes/mainMenu.css"; 
</style>
<!--[if IE]>
<style type="text/css" media="screen">
 ##menu ul li {float: left; width: 100%;}
 .submenu ul li {float: left; width: 100%;}
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
.submenu ul li {float: left; width: 100%;}
.submenu ul li a {height: 1%;} 

##menu a, ##menu h2 {
font: bold 0.7em/1.4em arial, helvetica, sans-serif;
} 
.submenu a, .submenu h2{
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
				<br>Please see our <a target="_top" href="/About.cfm?Action=sys">System Requirements</a>.
			</i>
		</font>
	<cfelseif #cgi.HTTP_USER_AGENT# contains "MSIE">
		<div align="center">
			<font color="##FF0000"  size="-1">
				<i>
					Some features of this site may not work in your browser. We recommend 
					<a target="_top" href="http://www.mozilla.org/products/firefox/">FireFox</a>.
				</i>
			</font>
		</div>
	</cfif>

<div id="header_color" style='background-color:#Client.header_color#;'>
	<!--- allow option for header that doesn't eat a bunch of screen space --->
	<table width="95%" cellpadding="0" cellspacing="0" border="0" id="headerContent">
		<tr>
			<td width="95" nowrap="nowrap" class="headerImageCell" id="headerImageCell">
				<a target="_top" href="#client.collection_url#"><img src="#Client.header_image#" alt="Arctos" border="0"></a>
			</td>
			<td align="left">
				<table>
					<tr>
						<td rowspan="2">
							<img src="/images/nada.gif" width="15px" border="0" alt="spacer">
						</td>
						<td align="left" nowrap>
							&nbsp;
						</td>
					</tr>
					<tr>
						<td align="left" nowrap="nowrap" id="collectionCell" class="collectionCell">
							<a target="_top" href="#client.collection_url#" class="novisit">
								<span class="headerCollectionText">
										#client.collection_link_text#
								</span>
							</a>
							<br>
							<a target="_top" href="#client.institution_url#" class="novisit">
								<span class="headerInstitutionText">
									#client.institution_link_text#
								</span>
							</a>
						</td>
					</tr>			 
				</table>
			</td>
		</tr>
	</table>
	
	<div style="float:right;position:absolute;top:0px;right:0px;clear:both; font-size:smaller;">
	<cfif len(#client.username#) gt 0>
				<a target="_top" href="/myArctos.cfm">Preferences</a>&nbsp;|&nbsp;<a target="_top" href="/login.cfm?action=signOut">Log out #client.username#</a>
				<cfif isdefined("client.last_login") and len(#client.last_login#) gt 0>
					<span style="font-size:smaller">(Last login: #dateformat(last_login, "mmm d yyyy")#)</span>&nbsp;
				</cfif>
			<cfelse>
			<cfset escapeGoofyInstall=replace(cgi.SCRIPT_NAME,"/cfusion","","all")>
				<form name="logIn" method="post" action="/login.cfm">
				<input type="hidden" name="action" value="signIn">
				<input type="hidden" name="gotopage" value="#escapeGoofyInstall#">
						<table border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td>
									<input type="text" name="username" title="Username" value="Username" size="12" 
										onfocus="if(this.value==this.title){this.value=''};">
								</td>
								<td>
										 
									  <input type="text" name="password" value="Password" title="Password"  size="12"
									  		onfocus="if(this.value==this.title){this.value='';this.type='password'};">
								</td>
							</tr>
							<tr>
								<td colspan="2">
										<input type="submit" value="Log In" class="lnkBtn"
   											onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'">
			or	
										<input type="button" value="Create Account" class="lnkBtn"
						   					onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'"
											onClick="logIn.action.value='newUser';submit();">
									
								</td>
								
							</tr>
						</table>
				</form>
			</cfif>
	</div>
<div id="menu">
<ul>
	<li><h2 onclick="document.location='/SpecimenSearch.cfm';">Search</h2>
		<ul>
			<li><a target="_top" href="/SpecimenSearch.cfm">Specimens</a></li>
			<li><a target="_top" href="/SpecimenUsage.cfm">Projects</a></li>
			<li><a target="_top" href="/TaxonomySearch.cfm">Taxonomy</a></li>
		</ul>
	</li> 
</ul>
<cfif client.roles is not "public">
	<!--- see what forms this user gets access to --->
	<cfset r = replace(client.roles,",","','","all")>
	<cfset r = "'#r#'">
	<!---    --->
<cfquery name="roles" datasource="#Application.web_user#" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
	select form_path from cf_form_permissions 
	where upper(role_name) IN (#ucase(preservesinglequotes(r))#)
	minus select form_path from cf_form_permissions 
	where upper(role_name)  not in (#ucase(preservesinglequotes(r))#)
</cfquery>
<cfset formList = valuelist(roles.form_path)>
<ul>
	<li><h2>Specimen</h2>
		<ul>
			<li><a href="##" class="x">Enter Data</a>
				<ul>
					<cfif listfind(formList,"/DataEntry.cfm")>
						<li><a target="_top" href="/DataEntry.cfm">Data Entry</a></li>
					</cfif>
					<cfif listfind(formList,"/Bulkloader/Bulkloader.cfm")>
						<li><a target="_top" href="/Bulkloader/Bulkloader.cfm">Bulkloader</a></li>
						<li><a target="_top" href="/Bulkloader/bulkloaderLoader.cfm">Bulkload Specimens</a></li>
						<li><a target="_top" href="/Bulkloader/bulkloader_status.cfm">Bulkloader Status</a></li>
						<li><a target="_top" href="/Bulkloader/accessBL.cfm">Bulkloader Templates</a></li>
						<li><a target="_top" href="##" onclick="getDocs('Bulkloader/index')">Bulkloader Docs</a></li>
					</cfif>
					<cfif listfind(formList,"/Bulkloader/browseBulk.cfm")>
						<li><a target="_top" href="/Bulkloader/browseBulk.cfm">Browse and Edit</a></li>
					</cfif>
				</ul>
			</li>
			<cfif listfind(formList,"/tools/BulkloadParts.cfm")>
				<li><a target="_top" href="##" class="x">Bulkloaders</a>
					<ul>
						<li><a target="_top" href="/tools/BulkloadParts.cfm">Bulkload Parts</a></li>
						<li><a target="_top" href="/tools/BulkloadAttributes.cfm">Bulkload Attributes</a></li>
						<li><a target="_top" href="/tools/BulkloadCitations.cfm">Bulkload Citations</a></li>
						<li><a target="_top" href="/tools/BulkloadOtherId.cfm">Bulkload Identifiers</a></li>
						<li><a target="_top" href="/tools/loanBulkload.cfm">Bulkload Loan Items</a></li>
						<li><li><a target="_top" href="/tools/BulkloadAgents.cfm">Bulkload Agents</a></li></li>
					</ul>
				</li>
			</cfif>
			<cfif listfind(formList,"/Locality.cfm")>
				<li><a target="_top" href="##" class="x">Location</a>
					<ul>
						<li><a target="_top" href="/Locality.cfm?action=findHG">Find Geography</a></li>
						<li><a target="_top" href="/Locality.cfm?action=newHG">Create Geography</a></li>
						<li><a target="_top" href="/Locality.cfm?action=findLO">Find Locality</a></li>
						<li><a target="_top" href="/Locality.cfm?action=newLocality">Create Locality</a></li>
						<li><a target="_top" href="/Locality.cfm?action=findCO">Find Event</a></li>
					</ul>
				</li>			
			</cfif>
			<cfif listfind(formList,"/agents.cfm")><li><a target="_top" href="/agents.cfm">Agents</a></li></cfif>				
		</ul>
	</li>
</ul>
<ul>
	<li><h2>Management</h2>
		<ul>
			<cfif listfind(formList,"/info/svn.cfm")>
				<li>
					<a target="_top" href="##" class="x">Developer Widgets</a>
					<ul>
						<li><a target="_top" href="/ScheduledTasks/index.cfm">Scheduled Tasks</a></li>
						<li><a target="_top" href="/info/svn.cfm">SVN</a></li>
						<li><a target="_top" href="/Admin/dumpAll.cfm">dump</a></li>
						<li><a target="_top" href="/CFIDE/administrator/">Manage ColdFusion</a></li>
						<li><a target="_top" href="/tools/imageList.cfm">Image List</a></li>
					</ul>
				</li>
			</cfif>
			<cfif listfind(formList,"/EditContainer.cfm") OR listfind(formList,"/tools/dgr_locator.cfm")>
				<li><a target="_top" href="##" class="x">Object Tracking</a>
					<ul>
						<cfif listfind(formList,"/tools/dgr_locator.cfm")>
							<li><a target="_top" href="/tools/dgr_locator.cfm">DGR Locator</a></li>
						</cfif>
						<cfif listfind(formList,"/EditContainer.cfm")>
							<li><a target="_top" href="/LoadBarcodes.cfm">Load Labels</a></li>
							<li><a target="_top" href="/EditContainer.cfm?action=newContainer">Create container</a></li>
							<li><a target="_top" href="/SpecimenContainerLabels.cfm">Print label data</a></li>
							<li><a target="_top" href="/CreateContainersForBarcodes.cfm?action=set">Load Specimen Labels</a></li>
						</cfif>
						<cfif listfind(formList,"/moveContainer.cfm")>
							<li><a target="_top" href="/batchScan.cfm">Scan Container</a></li>
							<li><a target="_top" href="/moveContainer.cfm">Move container (old)</a></li>
							<li><a target="_top" href="/a_moveContainer.cfm">Move container (boring)</a></li>
							<li><a target="_top" href="/dragContainer.cfm">Move container (AJAX)</a></li>
							<li><a target="_top" href="/labels2containers.cfm">Label>Container</a></li>
							<li><a target="_top" href="/bits2containers.cfm">Object>>Container</a></li>
							<li><a target="_top" href="/aps.cfm">Object+BC>>Container</a></li>
							<li><a target="_top" href="/containerContainer.cfm">Find Containers (AJAX)</a></li>
							<li><a target="_top" href="/start.cfm?action=container">Find Containers (HTML)</a></li>
						</cfif>		
					</ul>
				</li>
			</cfif>
			<cfif listfind(formList,"/Loan.cfm")>
				<li><a target="_top" href="##" class="x">Transactions</a>
					<ul>
						<li><a target="_top" href="/newAccn.cfm">Create Accession</a></li>
						<li><a target="_top" href="/editAccn.cfm">Find Accession</a></li>
						<li><a target="_top" href="/Loan.cfm?Action=newLoan">Create Loan</a></li>
						<li><a target="_top" href="/Loan.cfm?Action=addItems">Find Loan</a></li>
						<li><a target="_top" href="/borrow.cfm?action=new">Create Borrow</a></li>
						<li><a target="_top" href="/borrow.cfm">Find Borrow</a></li>
						<li><a target="_top" href="/Permit.cfm?action=newPermit">Create Permit</a></li>
						<li><a target="_top" href="/Permit.cfm">Find Permit</a></li>
					</ul>
				</li>
			</cfif>
			<cfif listfind(formList,"/AdminUsers.cfm")>
				<li><a target="_top" href="##" class="x">Arctos</a>
					<ul>
						<li><a target="_top" href="/Admin/form_roles.cfm">Form Permissions</a></li>
						<li><a target="_top" href="/tools/uncontrolledPages.cfm">See Form Permissions</a></li>
						<li><a target="_top" href="/AdminUsers.cfm">Arctos Users</a></li>
						<li><a target="_top" href="/Admin/user_roles.cfm">Database Roles</a></li>
						<li><a target="_top" href="/Admin/user_report.cfm">All User Stats</a></li>
						<li><a target="_top" href="/Admin/manage_user_loan_request.cfm">User Loan</a></li>
					</ul>
				</li>
			</cfif>
			<cfif listfind(formList,"/info/annotate.cfm")>
				<li><a target="_top" href="##" class="x">Misc.</a>
					<ul>
						<li><a target="_top" href="/info/annotate.cfm">Annotations</a></li>
						<li><a target="_top" href="/fix/fixBlCatNum.cfm">UAM Mamm BL Cat##</a></li>
						<li><a target="_top" href="/tools/PublicationStatus.cfm">Publication Staging</a></li>
						<li><a target="_top" href="/tools/parent_child_taxonomy.cfm">Sync parent/child taxonomy</a></li>
						<li><a target="_top" href="/Admin/killBadAgentDups.cfm">Merge bad dup agents</a></li>
						<li><a target="_top" href="/CodeTableButtons.cfm">Code tables</a></li>
						<li><a target="_top" href="/info/geol_hierarchy.cfm">Geol. Att. Hierarchy</a></li>
						<li><a target="_top" href="/tools/pendingRelations.cfm">Pending Relationships</a></li>
						<li><a target="_top" href="/Admin/Collection.cfm">Manage collections</a></li>
						<li><a target="_top" href="/Encumbrances.cfm">Encumbrances</a></li>
						<cfif listfind(formList,"/tools/sqlTaxonomy.cfm")>
							<li><a target="_top" href="/tools/sqlTaxonomy.cfm">SQL Taxonomy</a></li>
						</cfif>
					</ul>
				</li>
			</cfif>		
		</ul>
</ul>	
<cfif listfind(formList,"/Admin/ActivityLog.cfm")>
<ul>
	<li><h2>Reports</h2>
		<ul>
			<li><a target="_top" href="/info/annotate.cfm">Annotations</a></li>
			<li><a target="_top" href="/Admin/download.cfm">Download Stats</a></li>
			<li><a target="_top" href="/Admin/ActivityLog.cfm">SQL log</a></li>
			<li><a target="_top" href="/Admin/cfUserLog.cfm">User access</a></li>
			<li><a target="_top" href="/info/UserSearchHits.cfm">Some random stats</a></li>
			<li><a target="_top" href="/info/CodeTableValuesVersusTableValues.cfm">CT vs Data</a></li>
			<li><a target="_top" href="/tools/TaxonomyGaps.cfm">Messy Taxonomy</a></li>
			<li><a target="_top" href="/tools/findGap.cfm">Catalog Number Gaps</a></li>
			<li><a target="_top" href="/tools/downloadData.cfm">Download Tables</a></li>
		</ul>
	</li>
</ul>
</cfif>	
</cfif>
<ul>
	<li><h2 onclick="document.location='/myArctos.cfm';">My Stuff</h2>
		<ul>
			<li><a target="_top" href="/myArctos.cfm">Preferences</a></li>
			<li><a target="_top" href="##" onClick="getInstDocs('GENERIC','index')">Help</a></li>
			<li><a target="_top" href="/home.cfm">Home</a></li>
			<li><a target="_top" href="/Collections/index.cfm">Collections</a></li>
			<li><a target="_top" href="/siteMap.cfm">Site Map</a></li>
			<li><a target="_top" href="/user_loan_request.cfm">Use Specimens</a></li>
		</ul>
	</li>		
</ul>
</div>
</div>
<div class="content">
<cf_rolecheck>
</cfoutput>
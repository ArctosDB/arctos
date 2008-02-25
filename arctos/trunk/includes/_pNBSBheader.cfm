<cfoutput>
<cfinclude template="/Application.cfm">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>

<LINK REL="SHORTCUT ICON" HREF="#icon#">
	#metaTags#
</head>			
<body>
<div style='background-color:##252e4e;'>
<!----border-bottom-style:solid; border-bottom-color:#000000; border-bottom-width:thin;---->
	<cfif #cgi.HTTP_USER_AGENT# contains "4.7">
		<font color="##FF0000">
			<i>
				This page does not function properly with Netscape 4.7.
				<br>Please see our <a href="http://arctos.database.museum/About.cfm?Action=sys">System Requirements</a>.
			</i>
		</font>
	</cfif>
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
	
	<div style="padding-left:25px; ">
		<table width="95%" cellpadding="0" cellspacing="0">
			<tr>
				
				<td width="85" nowrap>
					<a href="http://www.absc.usgs.gov/research/ammtap/" target="_blank">
						<img src="/images/USGSHeader.gif" alt="USGS Icon" alt="USGS Icon" border="0">
					</a>
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
								<!---
								<a href="http://www.uaf.edu/" target="_blank" style="font-family:Arial, Helvetica, sans-serif; 
		color:##ffffff;">
										UNIVERSITY of ALASKA
									</a>
								--->
									<a href="http://www.absc.usgs.gov/research.htm" target="_blank" >
										<span style="font-family:Arial, Helvetica, sans-serif;  font-size:24px;
		color:##ffffff;">USGS</span>
									</a>
								<br>
									
									<a href="http://www.absc.usgs.gov/research/ammtap/" target="_blank" >
										<span style="font-family:Arial, Helvetica, sans-serif;
		color:##ffffff; 
		font-weight:bold;">Alaska Contaminant and Tissue Archival Program</span>
										
									</a>
							</td>
						</tr>			 
					</table>
				</td>
				</cfoutput>
			  <td align="right" valign="top" nowrap>
					<!---
					<table border>
						<tr>
							<td>
								<a href="/siteMap.cfm" target="_top" class="novisit">
						Site Map</a>
							</td>
							<td>
								<cfif #client.username# is not "">
						<a href="/login.cfm?action=signOut" target="_top" class="novisit">
							Log out <cfoutput>#client.username#</cfoutput>
						</a>
					<cfelse><a href="/login.cfm" target="_top" class="novisit">Log in</a></cfif>
							</td>
							<td>
								<a href="/login.cfm" target="_top" class="novisit">Log in</a></cfif>&nbsp;&nbsp;|&nbsp;&nbsp;<a href="javascript:void(0);" onClick="getInstDocs('GENERIC','index')">Help</a>
							</td>
						</tr>
					</table>
					--->
					<span class="helpLink">
					<a href="/siteMap.cfm" target="_top" class="novisit">
						Site Map</a>&nbsp;&nbsp;|&nbsp;&nbsp;
					<cfif #client.username# is not "">
						<a href="/login.cfm?action=signOut" target="_top" class="novisit">
							Log out <cfoutput>#client.username#</cfoutput>
						</a>
					<cfelse><a href="/login.cfm" target="_top" class="novisit">Log in</a></cfif>&nbsp;&nbsp;|&nbsp;&nbsp;<a href="javascript:void(0);" onClick="getInstDocs('GENERIC','index')">Help</a>
					</span>
					
			</td>
			
			</tr>
		</table>
		<table cellpadding="0" cellspacing="0" border="0" width="95%">
			<tr>
				<td nowrap>		
					<ul id="tabmenu">		
						<li>
							<a href="/SpecimenSearch.cfm" 
							target="_top"
							<cfif 
							#cgi.SCRIPT_NAME# contains "SpecimenSearch.cfm"> class="active"</cfif>
							><span>Specimen Search</span></a>
						</li>
						<li>
							<a href="/SpecimenUsage.cfm" 
							<cfif #cgi.SCRIPT_NAME# contains "SpecimenUsage.cfm"> class="active"</cfif>
							target="_top" ><span>Publication/Project Search</span></a>
						</li>
						
						
						<cfif #client.rights# contains "student0">
						<li>
								<a href="/TaxonomySearch.cfm" 
								<cfif #cgi.SCRIPT_NAME# contains "/TaxonomySearch.cfm"> class="active"</cfif>
								target="_top" ><span>Taxonomy Search</span></a>
							</li>
							<li>
								<a href="/transactions.cfm" 
								target="_top" 
								<cfif #cgi.SCRIPT_NAME# contains "transactions.cfm"> class="active"</cfif>
								><span>Transactions</span></a>
							</li>
							<li>
								<!--- this is in a frame, so cgi.script_name just detects _header.cfm---->
								<a href="/agents.cfm" 
								target="_top" 
								<cfif #cgi.SCRIPT_NAME# contains "/_header.cfm"> class="active"</cfif>
								><span>Agents</span></a>
							</li>
							<li>
								<a href="/Locality.cfm" 
								target="_top" 
								c<cfif #cgi.SCRIPT_NAME# contains "/Locality.cfm">  class="active"</cfif>
								><span>Locality</span></a>
							</li>
							
							<li>
								<a href="/tools/" target="_top" 
								<cfif #cgi.SCRIPT_NAME# contains "/tools/"> class="active"</cfif>
								><span>Tools</span></a>
							</li>
						</cfif>
						
							<li>
								<a href="/login.cfm" target="_top"
								<cfif #cgi.SCRIPT_NAME# contains "/login.cfm"> class="active"</cfif>><span>Advanced Features</span></a>
							</li>
						
					</ul>
			</td>
		</tr>
	</table>
	</div><!---- end laft-padding div ---->
</div><!---- end full-width background div ---->

<div class="content">
<cfoutput>
<cfinclude template="/Application.cfm">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<LINK REL="SHORTCUT ICON" HREF="#icon#">
	#metaTags#
</head>			
<body>
<table border cellpadding="0" cellspacing="0" style="background-color:##FFFFFF; position:absolute; top:0px; right:0px; font-size:12px;">
		<tr>
			<td>&nbsp;<a href="/home.cfm" target="_top" class="novisit">Home</a>&nbsp;</td>
			<td>&nbsp;<a href="/login.cfm" target="_top" class="novisit">Preferences</a>&nbsp;</td>
			<td>&nbsp;<a href="javascript:void(0);" onClick="getInstDocs('GENERIC','index')">Help</a>&nbsp;</td>
		</tr>
		<tr>
			<td>&nbsp;<a href="/siteMap.cfm" target="_top" class="novisit">Site Map</a>&nbsp;</td>
			<td>&nbsp;<a href="http://www.uaf.edu/museum/af/using.html" target="_top" class="novisit">Contact Us</a>&nbsp;</td>
			<td>&nbsp;<a href="/Collections/index.cfm" target="_top" class="novisit">Collections</a>&nbsp;</td>
		</tr>
		<tr>
			<td colspan="3" align="center">
			<cfif len(#client.username#) gt 0><a href="/login.cfm?action=signOut" target="_top" class="novisit">
							Log out <cfoutput>#client.username#</cfoutput>
						</a>
					<cfelse><a href="/login.cfm" target="_top" class="novisit">Log in</a></cfif>
			</td>
		</tr>
	</table>
<div style='background-color:##8FA682;'>
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
				
				<td width="95" nowrap>
						<a href="http://www.uaf.edu/museum/herb/index.html"><img src="/images/boykinia3.gif" alt="Arctos" border="0" ></a>
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
							<a href="http://www.uaf.edu/museum/herb/index.html" >
										<span style="font-family:Arial, Helvetica, sans-serif;  font-size:24px;
		color:##000066;">Herbarium</span>
									</a>
								<br>
									
									<a href="http://www.uaf.edu/museum/" >
										<span style="font-family:Arial, Helvetica, sans-serif;
		color:##000066; 
		font-weight:bold;">University of Alaska Museum of the North (ALA)</span>
										
									</a>
							</td>
						</tr>			 
					</table>
				</td>
				</cfoutput>
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
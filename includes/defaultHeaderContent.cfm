<!--- defaultHeaderContent.cfm --->
<!--- <div style='background-color:#FFFFFF;'>
	<table width="95%" cellpadding="0" cellspacing="0">
		<tr>
			<td width="95" nowrap>
				<a href="/home.cfm"><img src="/images/arctos_logo.gif" alt="Arctos" border="0" style="margin-left:10px;margin-right:10px;"></a>
			</td>
			<td align="left" nowrap>
				<span style="font-family:Arial, Helvetica, sans-serif;color:#000066; font-weight:bold; font-size:x-large;">
					A Collaborative Database System
				</span>	
				<br>
				<span style="font-size:large">			
					<cfoutput>#Application.InstitutionBlurb#</cfoutput>						
				</span>
			</td>
		</tr>
	</table>
	<!--- include tabs before closing div --->
	<cfinclude template="/includes/mainTabs.cfm">
</div>--->
<cfif #cgi.HTTP_HOST# contains "database.museum">
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
	<!--- include tabs before closing div 
	<cfinclude template="/includes/mainTabs.cfm">
	--->
</div>
<cfelseif #cgi.HTTP_HOST# contains "harvard.edu">
<div style='background-color:#dddddd; padding-left:20px;padding-top:10px;'>
	<table width="95%" cellpadding="0" cellspacing="0">
		<tr>
			<td width="90" nowrap>
				<a href="http://www.mcz.harvard.edu" class="novisit">
					<img src="/images/Harvard_shield.gif" alt="MCZ" border="0"></a>
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
						
							<span style="font-family:Arial, Helvetica, sans-serif;font-size:24px;color:#000066;">MCZB<span style="font-family:Arial, Helvetica, sans-serif;font-size:18px;color:#000066;">ASE:&nbsp;<span style="font-family:Arial, Helvetica, sans-serif;  font-size:24px;	color:#000066;">
								The Database of the Zoological Collections</span>
						
						<br>
						<a href="http://www.mcz.harvard.edu" class="novisit" >
						<span style="font-family:Arial, Helvetica, sans-serif;color:#000066; font-weight:bold;">
							Museum of Comparative Zoology - Harvard University</span>
						</a>
						</td>
					</tr>			 
				</table>
			</td>	
		</tr>
	</table>
	<!--- include tabs before closing div --->
	<cfinclude template="/includes/mainTabs.cfm">
</div>
<cfelse>
	<!--- MVZ site-wide header thingy --->
<div style='background-color:#ffffff;'>
	<table width="95%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td rowspan="4" width="87" valign="top"><a href="http://mvz.berkeley.edu"><img src="/images/MVZ_fancy_logo.jpg" alt="MVZ Home" width="87" height="88" border="0" align="left"></a></td>
    <td rowspan="4">&nbsp;</td>
	<td nowrap><span class="style2"><a href="http://www.berkeley.edu">University of California at Berkeley </a></span></td>
    </tr>
  <tr>
    <td height="10"><img src="/images/10_10_blank.jpg" width="10" height="10" border="0"></td>
  </tr>
  <tr>
    <td nowrap><span class="style3">Collections Database </span></td>
  </tr>
  <tr>
    <td nowrap><span class="style4"><a href="http://mvz.berkeley.edu">M<span class="style5">USEUM OF</span> V<span class="style5">ERTEBRATE</span> Z<span class="style5">OOLOGY</span></a> </span></td>
  </tr>
</table>
		
		
	<!--- include tabs before closing div --->
	<cfinclude template="/includes/mainTabs.cfm">
</div>
</cfif>

<!--- /defaultHeaderContent.cfm --->

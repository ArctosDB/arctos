<cfinclude template="includes/_header.cfm">
<table width="80%" cellpadding="10">
	<tr>
		
      <td  align="left" valign="top">
        <!--- left column --->
		<ul>
			<li>
				<a href="About.cfm">
					<cfif #Action# is "nothing">
						<font color="#999999">About&nbsp;the&nbsp;database</font>
					  <cfelse>
						<font color="blue">About&nbsp;the&nbsp;database</font>	
					</cfif>
				</a>
			</li>
			<li>
				<a href="About.cfm?Action=sugg">
					<cfif #Action# is "sugg">
						<font color="#999999">Suggestions?</font>
					  <cfelse>
						<font color="blue">Suggestions?</font>	
					</cfif>
				</a>
			</li>
			<li>
				<a href="About.cfm?Action=stat">
					<cfif #Action# is "stat">
						<font color="#999999">Server Statistics</font>
					  <cfelse>
						<font color="blue">Server Statistics</font>	
					</cfif>
				</a>
			</li>
			<li>
				<a href="About.cfm?Action=sys">
					<cfif #Action# is "sys">
						<font color="#999999">System Requirements</font>
					  <cfelse>
						<font color="blue">System Requirements</font>	
					</cfif>
				</a>
			</li>
			<li>
				<a href="About.cfm?Action=search">
					<cfif #Action# is "search">
						<font color="#999999">How&nbsp;to&nbsp;Search</font>
					  <cfelse>
						<font color="blue">How&nbsp;to&nbsp;Search</font>	
					</cfif>
				</a>
					<ul>
						<li>
							<a href="About.cfm?Action=SpecSearch">
								<cfif #Action# is "SpecSearch">
									<font color="#999999">Specimen&nbsp;Search</font>
								  <cfelse>
									<font color="blue">Specimen&nbsp;Search</font>	
								</cfif>
							</a>
						</li>
						<li>
							<a href="About.cfm?Action=ProjSearch">
								<cfif #Action# is "ProjSearch">
									<font color="#999999">Project&nbsp;Search</font>
								  <cfelse>
									<font color="blue">Project&nbsp;Search</font>	
								</cfif>
							</a>
						</li>
						<li>
							<a href="About.cfm?Action=PubSearch">
								<cfif #Action# is "PubSearch">
									<font color="#999999">Publication&nbsp;Search</font>
								  <cfelse>
									<font color="blue">Publication&nbsp;Search</font>	
								</cfif>
							</a>
						</li>
						<li>
							<a href="About.cfm?Action=TaxSearch">
								<cfif #Action# is "TaxSearch">
									<font color="#999999">Taxonomy&nbsp;Search</font>
								  <cfelse>
									<font color="blue">Taxonomy&nbsp;Search</font>	
								</cfif>
							</a>
						</li>
					</ul>
			</li>
		</ul>
      </td>
		<td>
			<cfif #Action# is "nothing">
				<cfset title = "About Arctos">
				Arctos is an effort to integrate catalog data, scientific results, and collection management 
				data into a system that facilitates and showcases the use of natural history collections.
				<p>
				The data structure is based on the Collections Information System at the University of California's Museum 
				of Vertebrate Zoology (MVZ) and programming 
				efforts have been shared. Because of licensing at the University of Alaska, Arctos uses Oracle® 
				for the database engine (as opposed to Sybase® at MVZ).
				<p>
				All programming is freely available for use or evaluation with some SQL-create statements posted at 
				MVZ for both Sybase® and Oracle®. User-interfaces are being developed in ColdFusion®. 
				Potential users are welcome to contact either MVZ or UAM.
			</cfif>
			<cfif #Action# is "sugg">
				<cfset title = "Suggestions">
				Have a suggestion to make this application better? We want to hear it! We can accomodate most 
				user requests, either through custom forms or queries or, if your suggestion is likely to benefit
				other users, through additions and modifications to this site.
				<p>
				Please send email to <a href="mailto:fndlm@uaf.edu">Dusty</a>
				or <a href="mailto:fnghj@uaf.edu">Gordon</a> 
				if you have any questions, comments, or suggestions.
				
			</cfif>
			<cfif #Action# is "stat">
				<cflocation url="stat.cfm">
			</cfif>
			<cfif #Action# is "sys">
				<cfset title = "System Requirements">
				<p>We've attempted to keep the client-side coding in these applications as generic as possible. 
				However, we have made some exceptions:
				<ul>
					<li>
					<b>JavaScript:</b> We have used JavaScript throughout the applications. Your browser 
					must be JavaScript enabled to access all the features of this application. 
					</li>
					<li>
					<b>Frames:</b> We've used frames when doing so greatly enhances our ability to present data.
					</li>
					<li>
					<b>Cookies:</b> We use cookies to set user preferences and track logins. You must enable 
					cookies to use these applications. Cookies are used only to control 
					your preferences and rights.
					</li>
				</ul>
				Browser Compatibility:
				<ul>
					<li>
					<b><a href="http://www.mozilla.org/">Mozilla</a> 
					<a href="http://www.mozilla.org/products/firefox/">Firefox</a>:</b> 
					All applications have been tested in Firefox. 
					</li>
					
					<li>
					<b>Netscape 4.x:</b> Older versions of Netscape are JavaScript and CSS deficient and don't properly render some forms.
					</li>
					<li>
					<b>Internet Explorer:</b> While we've attempted to build Microsoft-enabled applications, IE's non-standard 
					"standards" occasionally cause something unexpected to happen. Please let us know of any IE-related errors. 
					We'll fix them if we can.
					</li>
				</ul>
				We have no intention of supporting Netscape 4.x. Please <a href="mailto:fndlm@uaf.edu">report</a> 
				problems with other browsers.

			</cfif>
			<cfif #Action# is "search">
				<cfset title = "Searching Arctos">
				In contrast to traditional museum databases, Arctos may be queried by publications, projects, or taxonomy, 
				in addition to the standard specimen attributes. The specimen search screen is user-customizable, a feature 
				we can easily add to other forms as and if it is needed.
				<p>
				Unless otherwise specified, all fields are ANDed together, are not case sensitive,
				and match substrings.
			</cfif>
			<cfif #Action# is "SpecSearch">
				<cfset title = "Specimen Search">
				The Specimen Search screen represents the traditional museum database interface.
			</cfif>
			<cfif #Action# is "ProjSearch">
				<cfset title = "Project Search">
				The Project Search screen allows querys based on Projects.
			</cfif>
			<cfif #Action# is "PubSearch">
				<cfset title = "Publication Search">
				The Publication Search screen allows querys based on publications.
			</cfif>
			<cfif #Action# is "TaxSearch">
				<cfset title = "Taxonomy Search">
				The Taxonomy Search screen allows querys based on taxonomy.
			</cfif>	

</td></tr></table>
<cfinclude template="includes/_footer.cfm">
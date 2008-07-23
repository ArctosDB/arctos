<cfset title = "System Requirements">
<cfinclude template="includes/_header.cfm">
<p>This is a new application and may have issues! Much of the code contained in these applications
		was written to bridge a gap in the changeover from a Versata Business Logic Server (which contains rules about both the database and the data) to our long-term goal of developing "dumb" applications interfacing with a "smart" database containing business and referential integrity rules. For these reasons, most of these applications have limited functionality and all are much slower than they will be once our changeover is complete. 
		
		<p></p>
We've attempted to keep the client-side coding in these applications as generic as possible. However, we have made some exceptions:

<ul>
	<li>
		<b>JavaScript:</b> We have used JavaScript throughout the applications. Your browser must be JavaScript enabled to access all the features of this application. 
	</li>
	<li>
		<b>Frames:</b> We've used frames when doing so greatly enhances our ability to present data.
	</li>
	<li>
		<b>Java:</b> Some internal forms use Java to display hierarchical data. You must have the appropriate JRE (Java Runtime Environment) installed to see these forms.
	</li>
	<li>
		<b>Cookies:</b> We use cookies to set user preferences and track logins. You must enable cookies to use these applications. Cookies expire after 24 hours and are used only to control your preferences and rights and to gather usage statistics.
	</li>
</ul>
Browser Compatibility:
<ul>
	
  <li> <b><a href="http://www.mozilla.org/">Mozilla</a> <a href="http://www.mozilla.org/products/firebird/">FireBird</a>:</b> 
    All applications have been tested in FireBird and work properly with the approprite 
    JRE. </li>
	<li>
		<b>Netscape 6.x +:</b> Should function the same as FireBird.
	</li>
	<li>
		<b>Netscape 4.x:</b> Older versions of Netscape are JavaScript-deficient and don't properly render some forms.
	</li>
	<li>
		<b>Internet Explorer:</b> These applications are largely untested in IE. Expect JavaScript problems and ugly table rendering if you're brave enough to use IE here.
	</li>
</ul>
We have no intention of supporting Netscape 4.x. Please <a href="mailto:fndlm@uaf.edu">report</a> problems with other browsers; we'll fix them if we can.

<cfinclude template="includes/_footer.cfm">
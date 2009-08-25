<cfoutput>
	<!---
	<cfquery name="pn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select
			preferred_agent_name.agent_name
		from
			agent_name,
			preferred_agent_name
		where 
			agent_name.agent_id=preferred_agent_name.agent_id and
			upper(agent_name.agent_name) like '#ucase(q)#%'
		group by
			preferred_agent_name.agent_name
		order by
			preferred_agent_name.agent_name
	</cfquery>
	<cfloop query="pn">
		#agent_name# #chr(10)#
	</cfloop>
	---->
	[{"1":"Hello World !"},{"6":"Implementing basic searching for your website"},{"7":"A different approach to page caching"},{"8":"contact"},{"9":"resources"},{"11":"ADODB, best php database abstraction class"},{"4":"about"},{"5":"How to implement Mysql full text search on a big website"},{"12":"When to use join and when to use subselects"},{"13":"PHP simple timer class"},{"14":"Apache 2.2.6 is out"},{"15":"Bug fix for apache 2.2.6 compilation on 64 bit linux"},{"16":"Upgrade to apache 2.2.6 without downtime"},{"17":"Php mysql client library compilation problem"},{"19":"How to compile wxActivex (wxIe) with wxwidgets 2.8"},{"20":"Why template systems like smarty are useless and sometimes bad"},{"21":"How to display inifinit depth expandable categories using php and javascript"},{"22":"How to display infinite depth expandable categories using php and javascript"},{"23":"Validate your html forms with javascript and php with a simple php class that generates everything"},{"24":"Add multiple chained ajax comboboxes without writing even one line of javascript code, using a php class"},{"25":"How to make a product slideshow for your website's homepage using javascript"},{"27":"My favorite videos from youtube about linux"},{"28":"How to optimize your website layout to ensure your content is the first one in the page"},{"29":"Best firefox extensions for developers"},{"30":"HTML elements semantics"},{"31":"How to center a page layout"},{"32":"How to avoid some Internet explorer hacks and other unavoidable hacks"},{"33":"Tips on how to show a div above a page that has flash objects"},{"34":"How to make a password strength meter for your register form"},{"35":"Why are php coding guidelines important"},{"36":"How to sanitize your php input"},{"37":"Fedora 8 Impressions"},{"38":"Generate xml sitemaps with php directly from the database of your site"},["projects"],{"39":"How to solve common problems in fedora 8"},{"40":"A more fun php captcha for your forms, choose the cats from the dogs"},{"41":"Simple chained combobox plugin for jQuery"},{"45":"Are you still worried about sql injection ?"},{"44":"A php code beautifier that works"},{"46":"Unobtrusive jQuery autocomplete plugin with json key value support"},{"48":"Templates and presentation logic"},{"47":"jQuery morphing gallery"},{"49":"What cascading html template sheet is"}]
</cfoutput>
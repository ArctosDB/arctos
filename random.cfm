<cfset title="Explore Arctos">
<cfinclude template="/includes/_header.cfm">
<style>
	
#browseArctos {
	font-size:small;
	margin:1em;
	padding:1em;
}
#browseArctos ul {
	list-style-type:none;
	margin-left:-3em;
	vertical-align:middle;
}
	
#browseArctos ul li {
	margin:.5em;
	border-bottom:1px solid green;
}
	
#browseArctos .title {
	text-align:center;
	font-weight:bold;
	font-size:large;
	color:black;
}
		
#browseArctos ul li {
	text-indent:-1em;
	padding-left:1em;
}
</style>
<cfquery name="links" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" >
	select link,display from (
		select 
			link,display
		from
			browse
		 	sample(25)
		 order by
		 	dbms_random.value
		)
	WHERE rownum <= 25
</cfquery>
<cfoutput>
	<ul>
		<cfloop query="links">
			<li><a href="#link#">#display#</a></li>
		</cfloop>
	</ul>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">

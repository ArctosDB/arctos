<cfinclude template="../includes/_pickHeader.cfm">
<cfoutput>
<cfif not isdefined("container_id")>
	Container ID not found. Aborting....
	<cfabort>
</cfif>
<cfquery name="thisCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select * from container where container_id=#container_id#
</cfquery>

<cfquery name="getHist" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select 
		install_date,
		container_type,
		label,
		description,
		barcode,
		container.container_id
		 from container_history,container
		 where container_history.parent_container_id = container.container_id and
		  container_history.container_id=#container_id#
		 GROUP BY
		 install_date,
		container_type,
		label,
		description,
		barcode,
		container.container_id
	ORDER BY install_date DESC
</cfquery>
<cfif #getHist.recordcount# gt 0>
#thisCont.label# (<cfif len(#thisCont.description#) gt 0>#thisCont.description#,&nbsp;</cfif>a&nbsp;#thisCont.container_type#) 
has been in the following container(s):
<cfelse>
#thisCont.label# (<cfif len(#thisCont.description#) gt 0>#thisCont.description#,&nbsp;</cfif>a&nbsp;#thisCont.container_type#) 
has no scan history.

</cfif>
<p>&nbsp;</p>
<table border>
	<tr>
		<td><b>Date</b></td>
		<td><b>Type</b></td>
		<td><b>Label</b></td>
		<td><b>Description</b></td>
		<td><b>Barcode</b></td>
		<td>&nbsp;</td>
	</tr>

<cfloop query="getHist">
<tr>
	<td>#dateformat(install_date,"dd mmm yyyy")#
	&nbsp; #timeformat(install_date,"HH:mm:ss")#</td>
		<td>#container_type#</td>
		<td>#label#</td>
		<td>#description#</td>
		<td>#barcode#</td>		
		<td><a href="/findContainer.cfm?container_id=#container_id#">details</a></td>		
		</tr>
</cfloop>
</table>
</cfoutput>


<cfinclude template="../includes/_pickFooter.cfm">
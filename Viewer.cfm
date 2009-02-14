<cfinclude template="includes/_header.cfm">
<cfquery name="getViewers" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from viewer
</cfquery>
<br>Existing Viewers:
	<table border><tr>
		<td>ID</td>
		<td>Viewer</td>
		<td>Path</td>
		<td>Params</td>
		</tr>
	<cfoutput query="getViewers">
		<tr>
		<td>#viewer_ID#</td>
		<td>#Viewer#</td>
		<td>#Path#&nbsp;</td>
		<td>#Params#&nbsp;</td>
		</tr>
	</cfoutput>
</table>
<br>New Viewer:
<form name="viewer" method="post" action="Viewer.cfm">
	<input type="hidden" name="Action" value="newViewer">
	<br>Viewer: <input type="text" name="viewer">
	<br>Path: <input type="text" name="path">
	<br>Params: <input type="text" name="params">
	<br><input type="submit">
	
</form>

<cfif #Action# is "newViewer">
<cfoutput>
	<cfquery name="nextViewer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select max(viewer_id) +1 as nextViewer from viewer
	</cfquery>
	<cfquery name="newViewer" datasource="#Application.uam_dbo#">
	INSERT INTO viewer (viewer_id, viewer
		<cfif len(#path#) gt 0>
			,path
		</cfif>
		<cfif len(#params#) gt 0>
			,params
		</cfif>
		)
		values (#nextViewer.nextViewer#, '#viewer#'
		<cfif len(#path#) gt 0>
			,'#path#'
		</cfif>
		<cfif len(#params#) gt 0>
			,'#params#'
		</cfif>
		)
		</cfquery>
		<cflocation url="Viewer.cfm">
		
</cfoutput>
</cfif>

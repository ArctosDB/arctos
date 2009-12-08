<cfinclude template = "/includes/_header.cfm">
<script language="JavaScript" src="/includes/jquery/jquery.imgareaselect.pack.js" type="text/javascript"></script>
<link rel="stylesheet" type="text/css" href="/includes/jquery/css/imgareaselect-default.css">
<link rel="stylesheet" type="text/css" href="/includes/jquery/css/ui-lightness/jquery-ui-1.7.2.custom.css">
<script language="JavaScript" src="/includes/jquery/jquery-ui-1.7.2.custom.min.js" type="text/javascript"></script>
<script language="JavaScript" src="/includes/jquery/scrollTo.js" type="text/javascript"></script>
<script language="JavaScript" src="/includes/showTAG.js" type="text/javascript"></script>

<cfoutput>
	<input type="hidden" id="media_id" value="#media_id#">
	<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from media where media_id=#media_id#
	</cfquery>
	<cfif (c.media_type is not "image" and c.media_type is not "multi-page document") or c.mime_type does not contain 'image/'>
		FAIL@images only.
		<cfabort>
	</cfif>
	<div id="imgDiv">
		<img src="#c.media_uri#" id="theImage">
	</div>
	<div id="navDiv">
		<a href="MediaSearch.cfm?action=search&media_id=#media_id#">Back to Media</a>
		<cfif isdefined("session.roles") and listcontainsnocase(session.roles,"manage_media")>
			<br><a href="media.cfm?action=edit&media_id=#media_id#">Edit Media</a>
			<br><a href="TAG.cfm?media_id=#media_id#">Edit TAGs</a>
		</cfif>
		<div id="editRefDiv"></div>
	</div>
</cfoutput>
<cfset title="View Media TAGs">
<cfinclude template="/includes/_footer.cfm">
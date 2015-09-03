<!--- no security --->
<cfinclude template="../includes/_pickHeader.cfm">
 <cfif not isdefined("collection_object_id")>
	Didn't get a collection_object_id.<cfabort>
</cfif>
load some media yo!
<p>
	Media already created as Arctos Media? <span class="likeLink" onclick="findMedia('media_id','media_uri');">Click here to pick</span>.


}

<form name="m">
	<input type="text" name="media_uri" id="media_uri">
	<input type="text" name="media_id" id="media_id">
</form>

</p>
<cfinclude template="../includes/_pickFooter.cfm">
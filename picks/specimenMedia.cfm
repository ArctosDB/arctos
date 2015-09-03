<!--- no security --->
<cfinclude template="../includes/_pickHeader.cfm">


<script src="/includes/dropzone.js"></script>
<link rel="stylesheet" href="/includes/dropzone.css">

<script>
	$("div#dropzone").dropzone({ url: "/component/utilities.cfc?method=loadFile&returnFormat=json" });
</script>

 <cfif not isdefined("collection_object_id")>
	Didn't get a collection_object_id.<cfabort>
</cfif>
load some media yo!
<p>
	Media already created as Arctos Media? <span class="likeLink" onclick="findMedia('media_id','media_uri');">Click here to pick</span>.




  <div id="dropzone" class="dropzone">droppy</div>

<!----
<form action="/component/utilities.cfc?method=loadFile&returnFormat=json" class="dropzone" id="demo-upload">

  <div class="dz-message">
    Drop files here or click to upload.<br />
    <span class="note">(This is just a demo dropzone. Selected files are <strong>not</strong> actually uploaded.)</span>
  </div>

</form>

<form name="m">
	<input type="text" name="media_uri" id="media_uri">
	<input type="text" name="media_id" id="media_id">
</form>
---->
</p>

<cfinclude template="../includes/_pickFooter.cfm">
<cfinclude template="/includes/_header.cfm">
<h2>Bulkloading Specimens</h2>
<p>
	The <a href="/Bulkloader/BulkloadSpecimens.cfm">web-based specimen bulkloader</a> will handle a few thousand records. 
</p>

		
		 
<p>
	If that won't work, split your load into smaller files or contact a DBA. We're happy to help, and can load files of any size.
</p>

<p>You may create your own templates with the <a href="/Bulkloader/bulkloaderBuilder.cfm">Bulkloader Builder</a>. This is the only valid place to 
find bulkloader fields. It is not static: That year-old template probably won't work.
</p>

<p>Use <a href="/Bulkloader/bulkloader_status.cfm">Bulkloader Status</a> to see what's made it to the
bulkloader but not yet to Arctos</p>

<p>Documentation, including field definitions, is at <a href="https://arctosdb.wordpress.com/how-to/create/bulkloader/">Bulkloader Docs</a>
</p>
<cfinclude template="/includes/_footer.cfm">
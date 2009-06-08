<cfinclude template="/includes/_header.cfm">
<h2>Bulkloading Specimens</h2>

There are 2 online methods by which you may bulkload specimens. 
<ul>
	<li>
		The SQLLDR-based application will theoretically handle any number of records, 
		and calls an Oracle application to insert a text file into the bulkloader table.
		Practical use is limited by your upload speed and serverside preprocessing time.
		This method can be used for ca. 10,000 records on a good connection.
	</li>
	<li>
		The INSERT-based application will handle up to about 1000 records. This application
		is entirely ColdFusion, and is generally more stable than the SQLLDR application. We recommend
		it's usage when possible.
	</li>
	<li>
		Very large datasets may be impossible to load without DBA assistance due to network speeds and timeout
		settings, and your browser's ability to handle very large text files. Contact a DBA if you're having 
		trouble with the above methods.
	</li>
</ul>



<cfinclude template="/includes/_footer.cfm">
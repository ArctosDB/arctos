<cfinclude template="/includes/_header.cfm">
<script>

function test () {
	// save edited - this happens only from edit and 
	// returns only to edit
		$.ajax({
		    url: "/component/Bulkloader.cfc",
		    dataType: "json",
			type: "GET",
		    data: {
				method: "test",
				queryformat : "column",
				returnformat : "json",
				q : "collection_object_id=12"
			},
			success: function( r ){
				console.log(r);
			}
		});
}
</script>

<span onclick="test();">test</span>
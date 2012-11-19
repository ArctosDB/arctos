<cfinclude template="/includes/_header.cfm">
<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.9.1/jquery-ui.min.js"></script>
<script type='text/javascript' src='/includes/jquery/jquery-autocomplete/jquery.autocomplete.pack.js'></script>
<script>
	jQuery(document).ready(function() {

		    $('#theTable tbody table').sortable();
	});
</script>
<table id="theTable" border>
<tbody>
	<tr>
		<td>
			<table border>
				<tr>
					<td>i am table1</td>
				</tr>
			</table>
		</td>
		<td>
			<table border>
				<tr>
					<td>i am table2</td>
				</tr>
			</table>
		</td>
	</tr>
	<!----
	<tr>
		<td>
			<table border>
				<tr>
					<td>i am table</td>
				</tr>
			</table>
		</td>
		<td>
			<table border>
				<tr>
					<td>i am table</td>
				</tr>
			</table>
		</td>
	</tr>
	---->
	</tbody>
</table>
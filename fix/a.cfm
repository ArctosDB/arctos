<cfinclude template="/includes/_header.cfm">
<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.9.1/jquery-ui.min.js"></script>
<script type='text/javascript' src='/includes/jquery/jquery-autocomplete/jquery.autocomplete.pack.js'></script>
<script>
	jQuery(document).ready(function() {

		    $('.draggy').sortable();

});
</script>
<style>
	.left {
	    float: left;
	}
</style>

	<div class="left">

	<div class="draggy">
					<table border>
						<tr>
							<td>i am table1</td>
						</tr>
					</table>
				</div>


	<div class="draggy">
						<table border>
							<tr>
								<td>i am table2</td>
							</tr>
						</table>
					</div>
	</div>
	<div class="right">
	<div class="draggy">
							<table border>
								<tr>
									<td>i am table3</td>
								</tr>
							</table>
						</div>

	<div class="draggy">
								<table border>
									<tr>
										<td>i am table4</td>
									</tr>
								</table>
							</div>



	</div>
<!----


<table id="theTable" border cellspacing="10">
	<tr>
		<td>

		</td>
	</tr>
	<tr>
		<td>
			<div class="draggy">
					<table border>
						<tr>
							<td>i am table2</td>
						</tr>
					</table>
				</div>
		</td>
	</tr>
		<tr>
				<td>
					<div class="draggy">
						<table border>
							<tr>
								<td>i am table3</td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
			<tr>
				<td>
					<div class="draggy">
							<table border>
								<tr>
									<td>i am table4</td>
								</tr>
							</table>
						</div>
				</td>
			</tr>
</table>
---->

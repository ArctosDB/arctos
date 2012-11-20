<cfinclude template="/includes/_header.cfm">
<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.9.1/jquery-ui.min.js"></script>
<script type='text/javascript' src='/includes/jquery/jquery-autocomplete/jquery.autocomplete.pack.js'></script>
<script>
	jQuery(document).ready(function() {

		    $('div.draggy').draggable();

});

var dragItems = document.querySelectorAll('[draggable=true]');

for (var i = 0; i < dragItems.length; i++) {
  addEvent(dragItems[i], 'dragstart', function (event) {
    // store the ID of the element, and collect it on the drop later on

    event.dataTransfer.setData('Text', this.id);
  });
}


</script>
<style>
	.left {
	    float: left;
	}
	.draggy {border:2px solid red;}

[draggable=true] {
  -khtml-user-drag: element;
}
</style>

	<div id="columns">
	  <div class="column" draggable="true"><header>A</header></div>
	  <div class="column" draggable="true"><header>B</header></div>
	  <div class="column" draggable="true"><header>C</header></div>
	</div>

		<div class="draggy">
					11111
				</div>


		<div class="draggy">
						22222
					</div>

	<div class="draggy">
							33333
						</div>

	<div class="draggy">
							44444
							</div>



<!----

	<div class="left"></div>
	<div class="right">
	</div>


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

<cfinclude template="/includes/_header.cfm">
	<script src="/includes/jquery.gridster.min.js"></script>

	<link rel="stylesheet" href="/includes/jquery.gridster.min.css" type="text/css" />

	<script>


$(function(){ //DOM Ready

    $(".gridster ul").gridster({
        widget_margins: [10, 10],
        widget_base_dimensions: [140, 140],
        avoid_overlapped_widgets: true
    });

});




	</script>

	<div class="gridster">
	    <ul>
	        <li data-row="1" data-col="1" data-sizex="2" data-sizey="2">
				<table border="1">
					<tr>
						<td>
							<div style="border:2px solid red; height:200px;width:400px;">i am div 1-1</div>
						</td>
					</tr>

				</table>
			</li>
	        <li data-row="1" data-col="2" data-sizex="1" data-sizey="1">
				<table border="1">
						<tr>
							<td>
								<div style="border:2px solid red; height:200px;width:400px;">i am div1-2</div>
							</td>
						</tr>

					</table>
			</li>
			<li data-row="2" data-col="1" data-sizex="2" data-sizey="2">
					<table border="1">
						<tr>
							<td>
								<div style="border:2px solid red; height:200px;width:400px;">i am div2-1</div>
							</td>
						</tr>

					</table>
				</li>
		        <li data-row="2" data-col="2" data-sizex="1" data-sizey="1">
					<table border="1">
							<tr>
								<td>
									<div style="border:2px solid red; height:200px;width:400px;">i am div2-2</div>
								</td>
							</tr>

						</table>
				</li>

	<li data-row="3" data-col="1" data-sizex="2" data-sizey="2">
					<table border="1">
						<tr>
							<td>
								<div style="border:2px solid red; height:200px;width:400px;">i am div3-1</div>
							</td>
						</tr>

					</table>
				</li>
		        <li data-row="3" data-col="2" data-sizex="1" data-sizey="1">
					<table border="1">
							<tr>
								<td>
									<div style="border:2px solid red; height:200px;width:400px;">i am div3-2</div>
								</td>
							</tr>

						</table>
				</li>
	    </ul>
	</div>


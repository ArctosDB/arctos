<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<style>



	.localityevent {
		display:table-row;
	}

	.locality {
		padding-left:1em;
		width:100%;
		 display: table;
		border-left:1em solid lightgray;
	}
	.mapgohere {
		vertical-align: top;
		display: table-cell;
	}
	.localityData{
		display: table-cell;
		vertical-align: top;

	}


	.event {
		border:1px solid black;
		padding-left:2em;
		border-left:2em solid lightblue;
		display:table-row;
	}




	.tcontainer {
		display:table;
	}
	.trow {
		display:table-row;
	}
	.higher_geog {
		border:1px solid black;
		display:table-cell;
	}
	.searchterm {
		border:1px solid black;
		font-size:small;
	}

</style>
<div class="tcontainer">
	<div class="trow">
		<div class="higher_geog">
			Higher Geography:
			<div class="searchterm">
				SEARCH_TERM
			</div>
		</div>
	</div>

</div>

<hr>



	<!---- /searchterm ---->
	<div class="localityevent">
		<div class="locality">
			<div class="localityData">
				locality data
			</div>
			<div class="mapgohere">
				ima map
			</div>
		</div>
		<div class="event">
			events
		</div>
	</div>
</div>
<!---------------------------------------------------------------------------------------------------->
<cfinclude template="/includes/_footer.cfm">
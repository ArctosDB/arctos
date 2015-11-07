<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<style>
.tcontainer {
		display:table;
		border:1px solid black;
	}
	.trow {
		display:table-row;
	}
	.higher_geog {
		display:table-cell;
	}
	.searchterm {
		font-size:small;
		padding-left:1em;
	}
	.locality {
		 display: table-row;

	}
	.localityData{
		display: table-cell;
		vertical-align: top;
		padding:.5em;
		border-left:1em solid lightgray;

	}
	.mapgohere {
		vertical-align: top;
		display: table-cell;
		padding-left:1em;
		border:2px solid red;
	}
	.event {
		border:1px solid black;
		padding-left:.5em;
		border-left:4em solid lightblue;
		display:table-cell;
		padding:.5em;
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
	<div class="locality">
		<div class="localityData">
			locality data
		</div>
		<div class="mapgohere">
			ima map
		</div>
	</div>
	<div class="trow">
		<div class="event">
			events
		</div>
	</div>

</div>

<hr>



	<!---- /searchterm ---->

</div>
<!---------------------------------------------------------------------------------------------------->
<cfinclude template="/includes/_footer.cfm">
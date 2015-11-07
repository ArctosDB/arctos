<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<style>

.tcontainer {
		border-bottom:1px solid black;
	}
	.trow {
	}
	.higher_geog {
	}
	.searchterm {
		font-size:small;
		padding-left:1em;
		border-left:.2em solid lightgray;
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
		padding-left:.5em;
		border-left:2em solid lightgray;
		padding:.5em;
	}

</style>
<div class="tcontainer">
	<div class="higher_geog">
		Higher Geography:
		<div class="searchterm">
			SEARCH_TERM
		</div>
	</div>
	<div class="locality">
		<div class="localityData">
			locality data
		</div>
		<div class="mapgohere">
			ima map
		</div>
			<div class="event">
		events bla bla bla long bla
	</div>
	</div>


</div>

<hr>



	<!---- /searchterm ---->

</div>
<!---------------------------------------------------------------------------------------------------->
<cfinclude template="/includes/_footer.cfm">
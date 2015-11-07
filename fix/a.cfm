<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<style>

	.locstack {
		border:1px solid black;
		margin:1em;
	}
	.trow {
	}

	.searchterm {
		font-size:small;
		padding-left:1em;
		border-left:.2em solid lightgray;
	}









	.higher_geog {
		border:1px solid green;
		margin:1em;
		padding:1em;
	}
	.eventloc {
		border:1px solid red;
		margin:1em;
		padding:1em;
	}
	.locality {
		 display: table-row;
	}
	.localityData{
		display: table-cell;
		vertical-align: top;
		padding:.5em;
	}
	.mapgohere {
		vertical-align: top;
		display: table-cell;
		padding-left:1em;
		border:2px solid red;
	}
	.event {
		border:1px solid blue;
		margin:1em;
		padding:1em;
	}
</style>
	<div class="higher_geog">
		Higher Geography:
		<div class="searchterm">
			SEARCH_TERM
		</div>
		<div class="eventloc">
			<div class="locality">
				<div class="localityData">
					locality data
				</div>
				<div class="mapgohere">
					ima map
				</div>
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
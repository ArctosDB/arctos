<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<style>

	.higher_geog {
		border:1px solid black;
		display:table;
	}
	.searchterm {
		border:1px solid black;
		font-size:small;
	}
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

</style>
<div class="higher_geog">
	Higher Geography:
	<div class="searchterm">
		SEARCH_TERM
	</div><!---- /searchterm ---->
	<div class="localityevent">
		<div class="locality">
			<div class="localityData">
				locality data
			</div>
			<div class="mapgohere">
				ima map
			</div>
			<div class="event">
				events
			</div>
		</div>
	</div>
</div>
<!---------------------------------------------------------------------------------------------------->
<cfinclude template="/includes/_footer.cfm">
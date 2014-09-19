<cfinclude template="/includes/_header.cfm">

<style>
	.table {display:table}
	.tr {display:table-row}
	.td {display:table-cell;border:1px solid black;margin:1em;}
	.institutiongroup {border:1px dotted green;}
</style>

<div class="institutiongroup">
	<div class="table">
		<div class="tr">
			<div class="td">
				inst
			</div>
		</div>
		<div class="tr">
			<div class="td">
				<div>stuff</div>
				<div>nextrow</div>
			</div>
			<div class="td">
				another cell
			</div>
				
		</div>
	</div>
</div>
<!---------------



<div style="display:table">
				<div style="display:table-row">
					<div style="display:table-cell">
						<div style="display:table">
							<div style="display:table-row">
								<div style="display:table-cell">
									descrn
								</div>
							</div>
						</div>
					</div>
				</div>
				<div style="display:table-row">
					
				</div>
			</div>
		</div>
		
		
		
		--------->
		
		
		
<hr>


<cfhtmlhead text='<script src="http://maps.googleapis.com/maps/api/js?client=gme-museumofvertebrate1&sensor=false&libraries=places,geometry" type="text/javascript"></script>'>
<script src="/includes/jquery/jquery-autocomplete/jquery.autocomplete.pack.js" language="javascript" type="text/javascript"></script>
<script src="/includes/jquery.multiselect.min.js"></script>


<link rel="stylesheet" href="/includes/jquery.multiselect.css" />


<script>

jQuery(document).ready(function() {
			$("#collection_id").multiselect({
			minWidth: "500",
			height: "300"
		});
		});


</script>


<select name="collection_id" id="collection_id" size="3" multiple="multiple">
		<optgroup label="Natural History Museum of Utah (UMNH)">
				<option>Amphibian and reptile specimens</option>
				<option>Bird specimens</option>
				<option>Insect specimens</option>
				<option>Mollusc specimens</option>
		</optgroup>	
		<optgroup label="Museum of Vertebrate Zoology (MVZ), University of California-Berkeley">
				<option>Amphibian and reptile observations</option
				<option>Anatomical preparations</option>
				<option>Bird eggs/nests</option>
				<option>Bird observations</option>
				<option>Bird specimens</option>
				<option>Mammal specimens</option>>
		</optgroup>	
		<optgroup label="University of Alaska Museum (UAM)">
				<option>Archeology</option>
				<option>Bird specimens</option>
				<option>Cryptogam specimens (ALA)</option>
				<option>Earth Science</option>
				<option>Invertebrate specimens</option>
		</optgroup>

</select>





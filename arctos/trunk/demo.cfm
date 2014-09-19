<cfinclude template="/includes/_header.cfm">
<cfhtmlhead text='<script src="http://maps.googleapis.com/maps/api/js?client=gme-museumofvertebrate1&sensor=false&libraries=places,geometry" type="text/javascript"></script>'>
<script src="/includes/jquery/jquery-autocomplete/jquery.autocomplete.pack.js" language="javascript" type="text/javascript"></script>
<script src="/includes/jquery.multiselect.min.js"></script>


<link rel="stylesheet" href="/includes/jquery.multiselect.css" />


<style>
	.ui-multiselect-optgroup-label a {font-size:1.4em}
</style>

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





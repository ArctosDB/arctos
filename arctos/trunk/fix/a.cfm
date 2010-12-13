<cfinclude template = "/includes/_header.cfm">

<script>
	function getImg(typ,q,tgt,rpp,o){
		
		var ptl="/form/inclMedia.cfm?typ=" + typ + "&q=" + q + "&tgt=" +tgt+ "&rpp=" +rpp+ "&o="+o;
		
		jQuery.get(ptl, function(data){
			 jQuery('##' + tgt).html(data);
		})
	}
</script>
<span onclick="getImg('taxon','70','t')">q=70</span>

<div id="t">

</div>
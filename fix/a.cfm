<cfinclude template = "/includes/_header.cfm">

<script>
	function getImg(typ,q,tgt,rpp,pg){
		var typ;
		var q;
		var tgt;
		var rpp;
		var pg;
		var ptl="/form/inclMedia.cfm?typ=" + typ + "&q=" + q + "&tgt=" +tgt+ "&rpp=" +rpp+ "&pg="+pg;
		
		jQuery.get(ptl, function(data){
			 jQuery('#' + tgt).html(data);
		})
	}
</script>
<span onclick="getImg('taxon','70','t','','')">q=70</span>
<span onclick="getImg('taxon','89','t','','')">q=89</span>

<div id="t">

</div>
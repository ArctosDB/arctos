<cfinclude template = "/includes/_header.cfm">

<script>
	function getImg(typ,q,tgt,rpp,pg){
		$('#imgBrowserCtlDiv').append('<img src="/images/indicator.gif">');
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
<span onclick="getImg('taxon','70','t','','')">tax=70</span>
<span onclick="getImg('taxon','89','t','','')">tax=89</span>
<span onclick="getImg('accn','10000293','t','','')">accn=10000293</span>


<div id="t">

</div>
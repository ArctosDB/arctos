
<cfinclude template="/includes/_header.cfm">

    <script src="/includes/jquery.colorbox-min.js"></script>
        <link rel="stylesheet" href="/includes/colorbox.css" />

        <script>
            jQuery(document).ready(function () {
                jQuery('a.gallery').colorbox({ opacity:0.5 , rel:'group1' });

				$(".iframe").colorbox({iframe:true, width:"80%", height:"80%"});
            });


			function pushToParent (teid,tv,ieid,idv){
	$("#" + teid).val(tv).addClass('goodPick');
	$("#" + ieid).val(idv);
	
	console.log('hellp');
	try{
	$.colorbox.close();
	}catch(e){
		console.log(e);
	}
	
	try{
		parent.$.colorbox.close();
		}catch(e){
			console.log(e);
		}
		
		try{
			colorbox.close();
			}catch(e){
				console.log(e);
			}

			try{
				jQuery().colorbox.close();
				}catch(e){
					console.log(e);
				}			
			
			
}

        </script>
   		<p><a class='iframe' href="/picks/op_findAgent.cfm?agent_name=dusty&agentIdFld=a&agentNameFld=b">Outside Webpage (Iframe)</a></p>
	
	
	<form name="t">
	agent id
		<input type="text" id="b" name="b">
		agent name
		<input type="text" id="a" name="a" onchange="op_getAgent('b',this.id,this.value);">
	</form>
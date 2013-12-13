
<cfinclude template="/includes/_header.cfm">

    <script src="/includes/jquery.colorbox-min.js"></script>
        <link rel="stylesheet" href="/includes/colorbox.css" />

        <script>
            jQuery(document).ready(function () {
                jQuery('a.gallery').colorbox({ opacity:0.5 , rel:'group1' });

				$(".iframe").colorbox({iframe:true, width:"80%", height:"80%"});
            });
        </script>
   		<p><a class='iframe' href="/picks/findAgent.cfm?agent_name=dusty">Outside Webpage (Iframe)</a></p>
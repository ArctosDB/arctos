
<cfinclude template="/includes/_header.cfm">

    <script src="/includes/jquery.bpopup.min.js"></script>

<script>
  $('element_to_pop_up').bPopup({
            contentContainer:'.content',
            loadUrl: 'test.html' //Uses jQuery.load()
        });
</script>
				<span class="button small pop2" data-bpopup='{"contentContainer":".content","loadUrl":"/picks/agentPick.cfm"}'>Pop it up</span>



<cfinclude template="/includes/_header.cfm">
<cfset title="Search Arctos: Google Custom Search">
This form searches Arctos using Google's cache. Not everything in Arctos is indexed, and the results can be a bit quirky.
We're working to make that better.
<p>
	Use one of the other search options if you don't find what you expect here.
</p>
<div id="cse" style="width: 50%;">Loading</div>
<script>
  (function() {
    var cx = '011384802149075345004:_xhrdehjm50';
    var gcse = document.createElement('script');
    gcse.type = 'text/javascript';
    gcse.async = true;
    gcse.src = 'https://cse.google.com/cse.js?cx=' + cx;
    var s = document.getElementsByTagName('script')[0];
    s.parentNode.insertBefore(gcse, s);
  })();
</script>
<gcse:search></gcse:search>
<link rel="stylesheet" href="http://www.google.com/cse/style/look/default.css" type="text/css" />


<cfinclude template="/includes/_footer.cfm">
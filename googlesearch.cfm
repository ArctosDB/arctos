<cfinclude template="/includes/_header.cfm">
<cfset title="Search Arctos: Google Custom Search">
This form searches Arctos using Google's cache. Not everything in Arctos is indexed, and the results can be a bit quirky.
We're working to make that better.
<p>
	Use one of the other search options if you don't find what you expect here.
</p>			
<div id="cse" style="width: 50%;">Loading</div>	

<script src="http://www.google.com/jsapi" type="text/javascript"></script>
<script type="text/javascript">
  google.load('search', '1', {language : 'en'});
  google.setOnLoadCallback(function(){
    var customSearchControl = new google.search.CustomSearchControl('011384802149075345004:_xhrdehjm50');
    customSearchControl.setResultSetSize(google.search.Search.FILTERED_CSE_RESULTSET);
    customSearchControl.draw('cse');
  }, true);
</script>
<link rel="stylesheet" href="http://www.google.com/cse/style/look/default.css" type="text/css" />


<cfinclude template="/includes/_footer.cfm">
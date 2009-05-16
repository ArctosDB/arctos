<cfinclude template="/includes/_header.cfm">
<cfoutput>
	
	<script type='text/javascript' src='/includes/jquery/jquery.js'></script>	
	

<script>

 function GetWords(){
 $.getJSON(
 // Invoke the TextUtility.cfc as a web service.
 // Be sure to include WSDL for web service.
 "/component/test.cfc",
  
 // Send the method name and the phrase that the
 // user has entered in the form.
 {
 method : "test",
 q : $("##q").val(),
 returnformat : "json",
 queryformat : 'column'
 },
  
 // When the JSON data has returned, fire this
 // callback function and pass in the JSON data
 // as it's argument.
 ShowWords
 );
 }
function ShowWords(r) {console.log(r)}
</script>


<!---

function ShowProducts(qProducts){
  // matches CF8 implementation of JSON...
  // example: 
  // {"ROWCOUNT":2,"COLUMNS":["ID","TITLE"],"DATA":{"id":[1,2],"title":["AAA","BBB"]}}
  if (qProducts.ROWCOUNT==0) {
    alert('Sorry, no matches found');
  }
  else {
    for (var i=0; i<qProducts.ROWCOUNT; i++) {
      // loop through JSON recordset...
      // we can reference the fields like this...
      nId = qProducts.DATA.id[i];
      sTitle = qProducts.DATA.title[i];
    }
  }
}
	
		--->
		q: <input type="text" id="q">
<button onclick="GetWords()">GetWords</button>
<button onclick="test()">test</button>
</cfoutput>
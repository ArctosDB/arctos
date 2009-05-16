<cfinclude template="/includes/_header.cfm">
<cfoutput>
	
	<script type='text/javascript' src='/includes/jquery/jquery.js'></script>	
	
<cfajaxproxy cfc="component.test" jsclassname="myproxy">
<script>
var myCFC = new myproxy()

function test() {
   result = myCFC.test('dusty')
   console.log(result)
}   



 function GetWords(){
 $.get(
 // Invoke the TextUtility.cfc as a web service.
 // Be sure to include WSDL for web service.
 "/component/test.cfc",
  
 // Send the method name and the phrase that the
 // user has entered in the form.
 {
 method : "test",
 q : "gordon",
 returnformat : "json"
 },
  
 // When the JSON data has returned, fire this
 // callback function and pass in the JSON data
 // as it's argument.
 ShowWords
 );
 }
function ShowWords(r) {console.log(r)}
</script>

<button onclick="GetWords()">GetWords</button>
<button onclick="test()">test</button>
</cfoutput>
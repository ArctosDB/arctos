<cfinclude template="/includes/_header.cfm">
<cfoutput>
<cfajaxproxy cfc="component.test" jsclassname="myproxy">
<script>
var myCFC = new myproxy()

function test() {
   result = myCFC.test('dusty')
   console.log(result)
}   
</script>

<button onclick="test()">test</button>

</cfoutput>
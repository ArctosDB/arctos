<!----



curl -o pdb.json https://paleobiodb.org/data1.2/taxa/list.json?all_taxa&variant=all


{"oid":"txn:568","rnk":5,"nam":"Lupherium","tdf":"subjective synonym of","acc":"txn:593","acr":5,"acn":"Parahsuum","par":"txn:65980","rid":"ref:8792","ext":0,"noc":765},
{"oid":"txn:585",  "rnk":5,"nam":"Neowrangellium",   "tdf":"subjective synonym of","acc":"txn:452","acr":5,"acn":"Canoptum","par":"txn:86390","rid":"ref:40780","ext":0,"noc":645},
{"oid":"txn:4997", "rnk":5,"nam":"Pleurosiphonella","par":"txn:54332","rid":"ref:6930","ext":0,"noc":16},

---->

<cffile action = "read" file = "/usr/local/tmp/test.json" variable = "x">
<cfset j=DeserializeJSON(x)>
<cfdump var=#j#>


<cfloop collection=#j.records# item="r">
	<cfloop collection=#j# item="r">
       <cfdump var=#r#>
    </cfloop>
</table>



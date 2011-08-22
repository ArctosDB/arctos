<cfhttp method="get" url="http://canary.vert-net.appspot.com/api/search?q=c"></cfhttp>

<cfset cfo=DeserializeJSON(cfhttp.FileContent)>

<cfdump var=#cfo#>
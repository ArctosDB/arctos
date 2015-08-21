<cfoutput>

<cfinclude template="/includes/_header.cfm">

<cfset dap="American,Animal,al,alaska,and,Anonymous,Acad,Academy,Abrasive,agents,agent,Association,Arkansas,Arizona,attributed,author,Automatic">
<cfset dap=dap & ",biol,biology,Bros,Bro,brought,by,Botanic ">
<cfset dap=dap & ",Class,california,company,co,Club,center,Coast,collector,Coll,collection,Collecting,College,Chicago,Corporation,Commission,Captive,commercial">
<cfset dap=dap & ",Division,Department,Donate,Donated,det,data">
<cfset dap=dap & ",Ecology,et,estate,Exchange,Expedition,Exch,Exc,Ex">
<cfset dap=dap & ",field,Forest,Florida,from,Fish,for,Fur,found">
<cfset dap=dap & ",Group,Growth,guard,Geological,Govt,Garden">
<cfset dap=dap & ",Hospital,hunter,High,History">
<cfset dap=dap & ",illegible,inc,Information,Institution,in,Institute,Instruments,Instrument,Illinois">
<cfset dap=dap & ",Kentucky,known">
<cfset dap=dap & ",Lab,Laboratories,Laboratory">
<cfset dap=dap & ",Management,Museum,Mexico,Mfg,Medical,Media,Machine,Monument">
<cfset dap=dap & ",National,native,Network,No,Natural,name">
<cfset dap=dap & ",Old,other,of,or,Office,Oklahoma">
<cfset dap=dap & ",Philadelphia,Production,Productions,prob,Probably,Park,Possibly,purchased,purchase">
<cfset dap=dap & ",Rangers,Ranger,research,remark,remarks,Railroad">
<cfset dap=dap & ",Predatory,Project,Puffin">
<cfset dap=dap & ",School,Sanctuary,Science,Sciences,Seabird,specimen,Staff,Service,Smithsonian,Southwestern">
<cfset dap=dap & ",Society,Study,student,students,station,summer,shop,service,store,system,Survey,State">
<cfset dap=dap & ",the,through,tag,Taxidermy,Taxidermist">
<cfset dap=dap & ",University,uaf">
<cfset dap=dap & ",various">
<cfset dap=dap & ",Wildlife,Wisconsin,Washington,Works,with">
 
<cfset dap=dap & ",Zoological,zoo,Zoology">

<cfloop list="dap" index="i">
	<br>insert into ds_ct_notperson(term) values ('#lcase(i)#');
</cfloop>

<cfinclude template="/includes/_footer.cfm">
</cfoutput>


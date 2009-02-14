<cfif #action# is "update">
<cfquery name="allTaxa" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from taxonomy
</cfquery>
<cfindex 
	collection="Taxonomy" 
	action="update" 
	title="Title" 
	type="custom" 
	body="phylclass,phylorder,suborder,family,subfamily,genus,subgenus,species,subspecies,tribe,author_name,scientific_name,infraspecific_rank"
	key="taxon_name_id" 
	query="allTaxa">

done
</cfif>
<cfif #Action# is "search">
Search For:
<form action="Verity_Taxonomy.cfm" method="post">
<input type="text" name="criteria">
<input type="hidden" name="action" value="getData">
<input type="submit">

</form>

</cfif>

<cfif #action# is "getData">
<cfsearch collection="Taxonomy" name="taxa" criteria="#criteria#" type="simple">

<cfoutput>
	#taxa.recordcount# of #taxa.recordsSearched# records:
	
	<br>
</cfoutput>
<cfoutput query="taxa"	>
	<br>
		#scientific_name#
		
	
</cfoutput>
</cfif>
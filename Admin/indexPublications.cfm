	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select a.formatted_publication shortcit,
b.formatted_publication longcit, a.publication_id
from formatted_publication a, formatted_publication b
where a.publication_id = b.publication_id and
b.format_style='full citation' and a.format_style='author-year'
	</cfquery>
	<cfindex 
	query="data" 
	collection="veritySearchData"
	action="Update"
	type="Custom"
	key="publication_id"
	category="data,publication"
	title="publication_id"	
	custom1="shortcit"
	body="
		longcit">
		
spiffy
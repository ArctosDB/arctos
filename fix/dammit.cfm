this is a change
<!---I'm changed, yes I am--->

I'm changed again. And wuzzup with the stoopid singlequotes this thing keeps throwing in?

I can change things at will. That's new!

<cfoutput>
	<cfquery name="bob" datasource="wow">
		whatever
	</cfquery>
</cfoutput>
<cfquery name="t" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select goofytiss.af,cnt,freezer,found,r1,b1,r2,b2,
	cat_num,collection_cde,
	concatpartswithloc(cataloged_item.collection_object_id) as part
	from
	goofytiss,
	af,
	cataloged_item
	where 
	goofytiss.af=af.af (+) and
	af.collection_object_id=cataloged_item.collection_object_id (+)
</cfquery>
<cfoutput>

<table border>
<tr>
		<td>af</td>
		<td>cnt</td>
		<td>freezer</td>
		<td>found</td>
		<td>r1</td>
		<td>b1</td>
		<td>r2</td>
		<td>b2</td>
		<td>cat_num</td>
		<td>collection_cde</td>
		<td>part</td>
	</tr>
	<cfloop query="t">
	<tr>
		<td>#af#&nbsp;</td>
		<td>#cnt#&nbsp;</td>
		<td>#freezer#&nbsp;</td>
		<td>#found#&nbsp;</td>
		<td>#r1#&nbsp;</td>
		<td>#b1#&nbsp;</td>
		<td>#r2#&nbsp;</td>
		<td>#b2#&nbsp;</td>
		<td>#cat_num#&nbsp;</td>
		<td>#collection_cde#&nbsp;</td>
		<td>#part#&nbsp;</td>
	</tr>
	</cfloop>
	</table>
</cfoutput>
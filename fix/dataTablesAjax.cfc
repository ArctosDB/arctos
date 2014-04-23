<cfcomponent>
<cffunction name="t" access="remote" returnformat="plain" queryFormat="column">

<cfparam name="jtStartIndex" type="numeric" default="0">
<cfparam name="jtPageSize" type="numeric" default="10">
<cfparam name="jtSorting" type="string" default="GUID ASC">

<cfset jtStopIndex=jtStartIndex+jtPageSize>
<cfquery name="r_d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select * from cf_spec_res_cols_exp where category='required' order by DISP_ORDER
</cfquery>
	

	
			
	
	
	<cfquery name="d"datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		Select * from (
				Select a.*, rownum rnum From (
					select * from #session.SpecSrchTab# order by #jtSorting#
				) a where rownum <= #jtStopIndex#
			) where rnum >= #jtStartIndex#
	</cfquery>
	<!----
	<cfdump var=#d#>
--->
<cfoutput>
	<!--- CF and jtable don't play well together, so roll our own.... ---->
	
	
	
	
		</cfquery>
		
	
	
	
	
	<cfset x=''>
	<cfloop query="d">
		<cfset response = structNew()>
		<cfloop list="#d.columnlist#" index="i">
			<cfset temp = evaluate("d." & i)>
			<cfif i is "guid">
				<cfset temp ='<a target="_blank" href="/guid/#temp#">#temp#</a>"'>
			</cfif>
			<cfset response["#i#"]=temp>
		</cfloop>
		<cfset thisItem=serializeJSON(response)>
		<cfset x=x & thisItem>
		<!----
		<cfset trow="">
		<cfloop list="#d.columnlist#" index="i">
			<cfif i is "guid">
				<cfset temp ='"GUID":"<a target=\"_blank\" href=\"/guid/' & evaluate("d." & i) &'\">' & evaluate("d." & i) & '</a>"'>
			<cfelse>
				<cfset temp = '"#i#":"' & evaluate("d." & i) & '"'>
			</cfif>
			<cfset response["#cname#"]=evaluate("new." & cname)>
			<cfset trow=listappend(trow,temp)>
		</cfloop>
		<cfset trow="{" & trow & "}">
		<cfset x=listappend(x,trow)>
		
		
		---->
		
	</cfloop>
<cfset result='{"Result":"OK","Records":[' & x & '],"TotalRecordCount":#TotalRecordCount#}'>

<!----



{
	"Result":"OK",
	"Records":[
		{,"AGE":"2163","NAME":"S. Miller","PERSONID":"2163","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4025","NAME":"Dixon H. Landers","PERSONID":"4025","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4026","NAME":"Brenda K. Lasorsa","PERSONID":"4026","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4028","NAME":"Lawrence R. Curtis","PERSONID":"4028","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4029","NAME":"T. L. Wade","PERSONID":"4029","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4031","NAME":"John A. Kirsch","PERSONID":"4031","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4032","NAME":"Francois-Joseph Lapointe","PERSONID":"4032","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4034","NAME":"Sibile Pardue","PERSONID":"4034","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4035","NAME":"Sverre Pedersen","PERSONID":"4035","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4036","NAME":"Grant Keddie","PERSONID":"4036","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4038","NAME":"Anna V. Goropashnaya","PERSONID":"4038","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4039","NAME":"Nils C. Stenseth","PERSONID":"4039","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4040","NAME":"Charles J. Krebs","PERSONID":"4040","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4041","NAME":"D. Ehrich","PERSONID":"4041","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4042","NAME":"A. Kenney","PERSONID":"4042","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4043","NAME":"Eric P. Hoberg","PERSONID":"4043","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4045","NAME":"Natalya Abramson","PERSONID":"4045","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4046","NAME":"Christine Adkins","PERSONID":"4046","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4047","NAME":"William Akersten","PERSONID":"4047","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4048","NAME":"Lois F. Alexander","PERSONID":"4048","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4049","NAME":"Sergio Ticul Alvarez-Casta–eda","PERSONID":"4049","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4050","NAME":"M. Angaiak","PERSONID":"4050","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4053","NAME":"Daniel Bachteler","PERSONID":"4053","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4054","NAME":"Robert J. Baker","PERSONID":"4054","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4055","NAME":"Brian Barnes","PERSONID":"4055","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4058","NAME":"Sheran L. Benerth","PERSONID":"4058","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4059","NAME":"Michael A. Castellini","PERSONID":"4059","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4060","NAME":"Elaina Tuttle","PERSONID":"4060","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4063","NAME":"Amy Geiger","PERSONID":"4063","RECORDDATE":"2013-12-05 12:18:40.0"}]}



<cfset x='{
 "Result":"OK",
 "Records":[
  {"PersonId":1,"Name":"Benjamin Button","Age":17,"RecordDate":"\/Date(1320259705710)\/"},
  {"PersonId":2,"Name":"Douglas Adams","Age":42,"RecordDate":"\/Date(1320259705710)\/"},
  {"PersonId":3,"Name":"Isaac Asimov","Age":26,"RecordDate":"\/Date(1320259705710)\/"},
  {"PersonId":4,"Name":"Thomas More","Age":65,"RecordDate":"\/Date(1320259705710)\/"}
 ]
}'>

<cfreturn x>

---->


</cfoutput>

<cfreturn result>
</cffunction>

</cfcomponent>
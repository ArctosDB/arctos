<cfinclude template="/includes/_header.cfm">
	<cfset title='disposition vs remarks'>
	<cfoutput>

<cfif action is "nothing">
	<cfquery name="c" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select collection,collection_id from collection order by collection	
	</cfquery>
	<cfquery name="disp" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select coll_obj_disposition from CTCOLL_OBJ_DISP order by coll_obj_disposition	
	</cfquery>

<form name="f" method="post" action="dispVRemark.cfm">
	<input type="hidden" name="action" value="go">
	<label for="collection_id">select collections</label>
	<select name="collection_id" multiple="multiple" size="10">
		<cfloop query="c">
			<option value="#collection_id#">#collection#</option>
		</cfloop>
	</select>
	<label for="disposition">part disposition....</label>
	
	<select name="pdoper">
		<option value="in">IN</option>
		<option value="not in">NOT IN</option>
	</select>
	<select name="disposition" multiple="multiple" size="10">
		<cfloop query="disp">
			<option value="#coll_obj_disposition#">#coll_obj_disposition#</option>
		</cfloop>
	</select>
	<label for="remark">remarks like (comma-list, substring match, no case)</label>
	<textarea name="remark" rows="10" cols="50">donat,transfer,loan,exchange,miss</textarea>
	<br><input type="submit">
</form>

</cfif>
<cfif action is "go">
	<script src="/includes/sorttable.js"></script>
	<cfset sql="
			select
		    guid_prefix || ':' || cat_num cat_num,
		    spo.coll_obj_disposition spdisp,
		    cir.coll_object_remarks cirem,
		    spr.coll_object_remarks sprem
		from
		    cataloged_item,
		    collection,
		    specimen_part,
		    coll_object spo,
		    coll_object_remark cir,
		    coll_object_remark spr
		where
		    cataloged_item.collection_id in (#collection_id#) and
		    cataloged_item.collection_id=collection.collection_id and
		    cataloged_item.collection_object_id=specimen_part.derived_from_cat_item and
		    specimen_part.collection_object_id=spo.collection_object_id and
		    specimen_part.collection_object_id=spr.collection_object_id (+) and
		    cataloged_item.collection_object_id=cir.collection_object_id (+) and
		   spo.coll_obj_disposition #pdoper# (">
		        
	<cfset sql=sql & listqualify(disposition,"'")>
	<cfset sql=sql & "
		    ) and
		    (">
		    
		        <cfloop list="#remark#" index="i">
					<cfset sql=sql & " upper(cir.coll_object_remarks) like '%#ucase(i)#%' or ">
				</cfloop>
		        <cfloop list="#remark#" index="i">
					<cfset sql=sql & " upper(spr.coll_object_remarks) like '%#ucase(i)#%' or ">
				</cfloop>
				<cfset sql=sql &  " 1=2
		    )
			group by
				 guid_prefix || ':' || cat_num,
		    spo.coll_obj_disposition,
		    cir.coll_object_remarks,
		    spr.coll_object_remarks	
		   order by cat_num ">
	
	<div style="border:1px solid green;padding:1em;font-size:smaller">
		#sql#
	</div>
	<cfquery name="d" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		#preservesinglequotes(sql)#
	</cfquery>
	<table border id="t" class="sortable">
		<tr>
			<td>specimen</td>
			<td>PartDispn</td>
			<td>CatItemRemark</td>
			<td>Partremark</td>
		</tr>
		
		<cfset clist="specimen,PartDispn,CatItemRemark,Partremark">
		
	<cfset fileDir = "#Application.webDirectory#">
	<cfset variables.encoding="UTF-8">
	<cfset fname = "disv_v_remark.csv">
	<cfset variables.fileName="#Application.webDirectory#/download/#fname#">
	<cfscript>
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
		variables.joFileWriter.writeLine(ListQualify(clist,'"')); 
	</cfscript>
	
	
	
	<cfloop query="getData">
		<cfloop list="#clist#" index="c">
			<cfset thisData = evaluate("getData." & c)>
			<cfset thisData=replace(thisData,'"','""','all')>			
			<cfif len(oneLine) is 0>
				<cfset oneLine = '"#thisData#"'>
			<cfelse>
				<cfset oneLine = '#oneLine#,"#thisData#"'>
			</cfif>
		</cfloop>
		<cfset oneLine = trim(oneLine)>
		<cfscript>
			variables.joFileWriter.writeLine(oneLine);
		</cfscript>
	</cfloop>
	<cfscript>	
		variables.joFileWriter.close();
	</cfscript>
	
	
	
	
	<cfloop query="d">
		<cfset oneLine = '"#cat_num#","#spdisp#","#cirem#","#sprem#"'>
		<cfscript>
			variables.joFileWriter.writeLine(oneLine);
		</cfscript>
		<tr>
			<td><a href="/guid/#cat_num#">#cat_num#</a></td>
			<td>#spdisp#</td>
			<td>#cirem#</td>
			<td>#sprem#</td>
		</tr>
	</cfloop>
	
	<cfscript>	
		variables.joFileWriter.close();
	</cfscript>	
	</table>
	
	
		<a href="/download/#fname#">CSV</a>



</cfif>
	</cfoutput>

<cfinclude template="/includes/_footer.cfm">
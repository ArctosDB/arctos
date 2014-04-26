<cfinclude template="/includes/_header.cfm">
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select ATTRIBUTE_TYPE from ctattribute_type group by ATTRIBUTE_TYPE order by ATTRIBUTE_TYPE
		</cfquery>
		<cfquery name="fattrorder" datasource="uam_god">
			select min(DISP_ORDER) mdo from ssrch_field_doc where CATEGORY='attribute'
		</cfquery>		
		<cfset n=fattrorder.mdo>
		<cfset variables.encoding="UTF-8">
		<cfset variables.f_srch_field_doc="#Application.webDirectory#/download/srch_field_doc.sql">
		<cfset variables.f_ss_doc="#Application.webDirectory#/download/specsrch.txt">
		
		<cfset x='<cfset attrunits="M,METERS,METER,FT,FEET,FOOT,KM,KILOMETER,KILOMETERS,MM,MILLIMETER,MILLIMETERS,CM,CENTIMETER,CENTIMETERS,MI,MILE,MILES,YD,YARD,YARDS,FM,FATHOM,FATHOMS">'>
		<cfset x=x&'<cfset charattrschops="=,!"><cfset numattrschops="=,!,<,>">'>
		<cfscript>
			variables.josrch_field_doc = createObject('Component', '/component.FileWriter').init(variables.f_srch_field_doc, variables.encoding, 32768);
			variables.josrch_field_doc.writeLine("delete from srch_field_doc where CATEGORY='attribute';");
			variables.f_ss_doc = createObject('Component', '/component.FileWriter').init(variables.f_ss_doc, variables.encoding, 32768);
				variables.f_ss_doc.writeLine(x);
		</cfscript>
			
		<cfloop query="d">
			<cfquery name="tctl" datasource="uam_god">
				select ATTRIBUTE_TYPE,VALUE_CODE_TABLE,UNITS_CODE_TABLE from ctattribute_code_tables where ATTRIBUTE_TYPE='#ATTRIBUTE_TYPE#' 
			</cfquery>
			<cfset attrvar=replace(replace(replace(ATTRIBUTE_TYPE,' ','_','all'),'-','_','all'),"/","_","all")>
<cfset v="insert into ssrch_field_doc (
		CATEGORY,
		CF_VARIABLE,
		CONTROLLED_VOCABULARY,
		DATA_TYPE,
		DEFINITION,
		DISPLAY_TEXT,
		DOCUMENTATION_LINK,
		PLACEHOLDER_TEXT,
		SEARCH_HINT,
		SQL_ELEMENT,
		SPECIMEN_RESULTS_COL,
		DISP_ORDER,
		SPECIMEN_QUERY_TERM
	) values (
		'attribute',
		'#attrvar#',
		'#tctl.VALUE_CODE_TABLE#',
		'',
		'',
		'#ATTRIBUTE_TYPE#',
		'',
		'#ATTRIBUTE_TYPE#',
		'',
		'concatAttributeValue(flatTableName.collection_object_id,''#ATTRIBUTE_TYPE#''),
		1,
		#n#,
		1
	);
">
			
		
		
			<cfset n=n+1>
		
		
		



		
			<cfset x='<cfif isdefined("#attrvar#")>'>
			<cfset x=x & chr(10) & '    <cfset mapurl = "##mapurl##&#attrvar#=###attrvar###">'>
			<cfset x=x & chr(10) & '    <cfset basJoin = " ##basJoin## INNER JOIN v_attributes t_#attrvar# ON (##session.flatTableName##.collection_object_id = t_#attrvar#.collection_object_id)">'>
			<cfset x=x & chr(10) & '    <cfset basQual = " ##basQual## AND t_#attrvar#.attribute_type = ''#ATTRIBUTE_TYPE#''">'>
			<cfset x=x & chr(10) & '    <cfif session.flatTableName is not "flat">'>
			<cfset x=x & chr(10) & '        <cfset basQual = " ##basQual## AND t_#attrvar#.is_encumbered = 0">'>
			<cfset x=x & chr(10) & '    </cfif>'>
			<cfset x=x & chr(10) & '    <cfset schunits="">'>
			<cfset x=x & chr(10) & '    <cfif len(#attrvar#) gt 0>'>
			<cfset x=x & chr(10) & '        <cfset oper=left(#attrvar#,1)>'>
			<cfif len(tctl.UNITS_CODE_TABLE) gt 0>
				<cfset x=x & chr(10) & '        <cfif listfind(numattrschops,oper)>'>
			<cfelse>
				<cfset x=x & chr(10) & '        <cfif listfind(charattrschops,oper)>'>
			</cfif>
			<cfset x=x & chr(10) & '            <cfset schTerm=ucase(right(#attrvar#,len(#attrvar#)-1))>'>
			<cfset x=x & chr(10) & '        <cfelse>'>
			<cfset x=x & chr(10) & '            <cfset oper="like"><cfset schTerm=ucase(#attrvar#)>'>
			<cfset x=x & chr(10) & '        </cfif>'>
			<cfif len(tctl.UNITS_CODE_TABLE) gt 0>
				<cfset x=x & chr(10) & '     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>'>    
				<cfset x=x & chr(10) & '     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>'>  
				<cfset x=x & chr(10) & '         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>'>  
				<cfset x=x & chr(10) & '     </cfif>'> 
			</cfif>
			<cfset x=x & chr(10) & '      <cfif len(schunits) gt 0>'>  
			<cfset x=x & chr(10) & '         <cfset basQual = " ##basQual## AND to_meters(t_#attrvar#.attribute_value,t_#attrvar#.attribute_units) ##oper## to_meters(##schTerm##,''##schunits##'')">'>  
			<cfset x=x & chr(10) & '     <cfelseif oper is not "like" and len(schunits) is 0>'> 
			<cfset x=x & chr(10) & '         <cfset basQual = " ##basQual## AND upper(t_#attrvar#.attribute_value) ##oper## ''##escapeQuotes(schTerm)##'')">'>  
			<cfset x=x & chr(10) & '     <cfelse>'> 
			<cfset x=x & chr(10) & '         <cfset basQual = " ##basQual## AND upper(t_#attrvar#.attribute_value) like ''%##ucase(escapeQuotes(schTerm))##%''">'>  
			<cfset x=x & chr(10) & '     </cfif>'> 
			<cfset x=x & chr(10) & '    </cfif>'>
			<cfset x=x & chr(10) &  '</cfif>'>
			<cfset x=x & chr(10)>
		
       



			
			<cfscript>
				variables.josrch_field_doc.writeLine(v);
				variables.f_ss_doc.writeLine(x);
			</cfscript>
		</cfloop>
		<cfscript>	
			variables.josrch_field_doc.close();
			variables.f_ss_doc.close();
		</cfscript>
		This app just builds text.
		<p>
			Get the SQL to update ssrch_field_doc <a href="/download/srch_field_doc.sql">here</a>
		</p>
		
		<p>
			Get the CFML to update specimen search <a href="/download/specsrch.txt">here</a>
		</p>
	</cfoutput>
<cfinclude template="/includes/_footer.cfm">

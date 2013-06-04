<cfinclude template="/includes/_header.cfm">
<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select
		flat.spec_locality,
		round(accepted_lat_long.DEC_LAT,4) DEC_LAT,
		round(accepted_lat_long.DEC_LONG,4) DEC_LONG,
		accepted_lat_long.MAX_ERROR_DISTANCE,
		accepted_lat_long.MAX_ERROR_UNITS,
		flat.began_date,
		collectors,
		flat.CAT_NUM
	from
		flat,
		accepted_lat_long
	where
		flat.locality_id=accepted_lat_long.locality_id (+) and
		flat.collection_object_id IN (select collection_object_id from #table_name#)
	order by to_number(flat.cat_num)	
</cfquery>
<cfset fname = "bugs.tex">
<cfset variables.fileName="#Application.webDirectory#/download/#fname#">
<cfset variables.encoding="UTF-8">
<cfscript>
	header='\documentclass[10pt]{article}
\usepackage{xltxtra}
\usepackage{multicol}
\usepackage[margin=1cm]{geometry}

%% Font.
\setmainfont[Scale=0.3, PunctuationSpace=3, WordSpace = 0.3]{TeX Gyre Heros}
%% Inter-line spacing.
\linespread{0.25}

%% Commands for typesetting labels.
\renewcommand{\fboxsep}{0.2mm}
\newcommand{\insectlabel}[1]{\fbox{\parbox{16mm}{\raggedright ##1}}\\}
\newcommand{\idlabel}[1]{\fbox{\parbox{4mm}{\centering\bfseries ##1}}\\}
\setlength{\columnsep}{1mm}
\setlength{\parindent}{0mm}

\begin{document}
\begin{multicols}{10}
';
	variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
	variables.joFileWriter.writeLine(header);
</cfscript>
<cfloop query="d">
	<cfset colr=replace(collectors," ","~","all")>
	<cfif len(DEC_LAT) gt 0>
		<cfset dlat=abs(dec_lat)>
	<cfelse>
		<cfset dlat=''>
	</cfif>
	<cfif len(DEC_LONG) gt 0>
		<cfset dlon=abs(DEC_LONG)>
	<cfelse>
		<cfset dlon=''>
	</cfif>
	<cfif len(MAX_ERROR_DISTANCE) gt 0>
		<cfset errstr="#chr(177)##MAX_ERROR_DISTANCE##MAX_ERROR_UNITS#. ">
	<cfelse>
		<cfset errstr="">
	</cfif>
	<cfset l=escapequotes('\insectlabel{USA: Alaska. #SPEC_LOCALITY# #dlat##chr(176)#N #dlon##chr(176)#W #errstr##dateformat(began_date,"dd-MMM-yyyy")#. #colr#}\idlabel{KNWR #CAT_NUM#}')>
	
	<cfscript>
		variables.joFileWriter.writeLine(l);
	</cfscript>
</cfloop>
<cfscript>
	l='\end{multicols}
\end{document}';
	variables.joFileWriter.writeLine(l);
	variables.joFileWriter.close();
</cfscript>d
<cflocation url="/download.cfm?file=#fname#" addtoken="false">
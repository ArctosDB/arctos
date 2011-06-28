<cfinclude template="/includes/_header.cfm">
<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select
		collecting_event.VERBATIM_LOCALITY,
		round(accepted_lat_long.DEC_LAT,4) DEC_LAT,
		round(accepted_lat_long.DEC_LONG,4) DEC_LONG,
		accepted_lat_long.MAX_ERROR_DISTANCE,
		accepted_lat_long.MAX_ERROR_UNITS,
		flat.VERBATIM_DATE,
		collectors,
		flat.CAT_NUM
	from
		flat,
		accepted_lat_long,
		collecting_event
	where
		flat.locality_id=accepted_lat_long.locality_id (+) and
		flat.collecting_event_id=collecting_event.collecting_event_id and
		flat.collection_object_id IN (#collection_object_id#)		
</cfquery>
<cfset fname = "bugs.tex">
<cfset variables.fileName="#Application.webDirectory#/download/#fname#">
<cfset variables.encoding="UTF-8">
<cfscript>
	header='\documentclass[10pt]{letter}
		\usepackage{xltxtra}
		\usepackage[noprintbarcodes,%
		nocapaddress]{envlab}
		
		%% Label size.
		%% Using label size of 17 mm by 6 mm as prescribed by the Biological Survey of Canada''s Label data standards for terrestrial arthropods at http://www.biology.ualberta.ca/bsc/briefs/brlabelstandards.htm.
		\SetLabel{25mm}{6mm}{3mm}{6mm}{0mm}{7}{40}
		
		%% Font.
		\setmainfont[Mapping=tex-text]{Linux Libertine O}
		\newcommand{\supertiny}{\fontsize{2.9pt}{2.9pt}\selectfont}
		
		
		%% Command for typesetting labels
		\newcommand{\ilabel}[1]{%
		\mlabel{}{\supertiny ##1}}
		
		\makelabels
		
		\begin{document}
		\startlabels
		
		
		%\documentclass[10pt]{letter}
		%\usepackage[avery5160label,noprintbarcodes,%
		%nocapaddress]{envlab}
		
		%% Font.
		%\font\supertiny=cmss10 at 3pt
		%\renewcommand{\rmdefault}{cmss}
		
		
		
		
		%\linespread{0.2}


';

	variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
	variables.joFileWriter.writeLine(header);
</cfscript>
<cfloop query="d">
	<cfset l=escapequotes('\mlabel{}{\supertiny USA: Alaska. #VERBATIM_LOCALITY# #DEC_LAT##chr(176)#N #DEC_LONG##chr(176)#W #chr(177)# #MAX_ERROR_DISTANCE# #MAX_ERROR_UNITS# #VERBATIM_DATE# #collectors# KNWR~#CAT_NUM#}')>
	<cfscript>
		variables.joFileWriter.writeLine(l);
	</cfscript>
	
</cfloop>

<cfscript>
	l='\end{document}';
	variables.joFileWriter.writeLine(l);
	variables.joFileWriter.close();
</cfscript>d

<cflocation url="/download.cfm?file=#fname#" addtoken="false">
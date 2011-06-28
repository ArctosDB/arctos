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
	<cfset h='\mlabel{}{\supertiny USA: Alaska. #VERBATIM_LOCALITY# #DEC_LAT#¡N #DEC_LONG#¡W ± #MAX_ERROR_DISTANCE# #MAX_ERROR_UNITS# #VERBATIM_DATE# #collectors# KNWR~#CAT_NUM#}'>
	<cfscript>
		variables.joFileWriter.writeLine(d);
	</cfscript>
	
</cfloop>

<cfscript>
	l='\end{document}';
	variables.joFileWriter.writeLine(l);
	variables.joFileWriter.close();
</cfscript>d
	
<cfdump var=#d#>
<!----




		
		
		
\documentclass[10pt]{letter}
\usepackage{xltxtra}
\usepackage[noprintbarcodes,%
nocapaddress]{envlab}

%% Label size.
%% Using label size of 17 mm by 6 mm as prescribed by the Biological Survey of Canada's Label data standards for terrestrial arthropods at http://www.biology.ualberta.ca/bsc/briefs/brlabelstandards.htm.
\SetLabel{25mm}{6mm}{3mm}{6mm}{0mm}{7}{40}

%% Font.
\setmainfont[Mapping=tex-text]{Linux Libertine O}
\newcommand{\supertiny}{\fontsize{2.9pt}{2.9pt}\selectfont}


%% Command for typesetting labels
\newcommand{\ilabel}[1]{%
\mlabel{}{\supertiny #1}}

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





\mlabel{}{\supertiny USA: Alaska. Soldotna. Headquarters L. 60.462656¡N 151.074364¡W +/-6m. 	60.4627¡N 	151.0744¡W 	±6m 	26.VI.2009 	Matt Bowser 	KNWR~7000}
\mlabel{}{\supertiny USA: AK. Soldotna. Ski Hill Rd. 	60.4647¡N 	151.0732¡W 	±50m 	2.May.2011 	Matt Bowser 	KNWR~7001}
\mlabel{}{\supertiny USA: AK. Soldotna. Headquaters L. 	60.4626¡N 	151.0745¡W 	±50m 	4.May.2011 	Matt Bowser 	KNWR~7002}
\mlabel{}{\supertiny USA: Alaska. Soldotna. Headquarters Lake 	60.4627¡N 	151.0741¡W 	±50m 	2.May.2011 	Matt Bowser 	KNWR~7003}
\mlabel{}{\supertiny found in lab Refuge HQ 	60.4647¡N 	151.0735¡W 	±50m 	9/1/2006	Todd Eskelin 	KNWR~7004}
\mlabel{}{\supertiny DC-2004-2 Floating Sphagnum mat, Finger Lake rd, KNWR, AK USA 	60.6556¡N 	150.8756¡W 	±80m 	6/18/2004	Dominique M. Collet 	KNWR~7005}
\mlabel{}{\supertiny USA: AK, Kenai. Beaver Loop Rd. 	60.5485¡N 	151.1464¡W 	±50m 	22-May-05	Todd Eskelin 	KNWR~7006}
\mlabel{}{\supertiny USA: AK, KENWR Soldotna. road near Headquarters Lake 	60.4626¡N 	151.0771¡W 	±250m 	3-Jun-05	Matt Bowser 	KNWR~7007}
\mlabel{}{\supertiny USA: Alaska, Kenai Peninsula. Black spruce forest by Swanson River SE of Grus Lake 	60.7648¡N 	150.6512¡W 	±2km 	25-VIII-2008 	Matt Bowser 	KNWR~7008}
\mlabel{}{\supertiny USA: AK. Soldotna. Granite Hollow Ct. 	60.5262¡N 	150.9145¡W 	±50m 	7.May.2011 	Matt Bowser 	KNWR~7009}
\mlabel{}{\supertiny Johnson Lake, Kasilof, Alaska 	60.2911¡N 	151.2659¡W 	±550m 	8/5/2005	Selene O'Dell 	KNWR~7010}
\mlabel{}{\supertiny Longmere Lake, Soldotna, AK 	60.5096¡N 	150.9075¡W 	± 	8/5/2005	Mary Pfauth 	KNWR~7011}
\mlabel{}{\supertiny Johnson Lake, Kasilof, AK 	60.2911¡N 	151.2659¡W 	±550m 	8/5/2005	Mary Pfauth 	KNWR~7012}
\mlabel{}{\supertiny Longmere Lake, Soldotna, AK 	60.5096¡N 	150.9075¡W 	± 	8/5/2005	Selene O'Dell 	KNWR~7013}
\mlabel{}{\supertiny Johnson Lake, Kasilof, AK 	60.2911¡N 	151.2659¡W 	±550m 	8/5/2005	Mary Pfauth 	KNWR~7014}
\mlabel{}{\supertiny Vogel Lake, Kenai NWR, AK 	60.9957¡N 	150.4259¡W 	±10m 	8/2/2005	Mary Pfauth 	KNWR~7015}
\mlabel{}{\supertiny USA: Alaska. Headquaters Lake. 	60.4631¡N 	151.0749¡W 	±50m 	23.May.2011 	Matt Bowser 	KNWR~7016}
\mlabel{}{\supertiny USA: AK. Soldotna. Headquarters L. 	60.4619¡N 	151.0755¡W 	±50m 	23.May.2011 	Matt Bowser 	KNWR~7017}
\mlabel{}{\supertiny Kenai NWR Headquarters 	60.4649¡N 	151.0737¡W 	±50m 	10/22/2009	Todd Eskelin 	KNWR~7018}
\mlabel{}{\supertiny USA: WA, Thurston Co. 5 mi N of Olympia. Athens Beach Rd. NW urban adjacent to mature Doug Fir + Western Red Cedar forest 	47.1166¡N 	122.925¡W 	±180m 	3-XI-2005 	Todd Eskelin 	KNWR~7019}
\mlabel{}{\supertiny Vogel Lake, Kenai NWR, AK 	60.9957¡N 	150.4259¡W 	±10m 	8/4/2005	Selene O'Dell 	KNWR~7020}
\mlabel{}{\supertiny Vogel Lake, Kenai NWR, AK 	60.9957¡N 	150.4259¡W 	±10m 	8/4/2005	Selene O'Dell 	KNWR~7021}
\mlabel{}{\supertiny Kasilof, Old Kasilof Road. 	60.3632¡N 	151.2699¡W 	±20m 	6.June.2011 	Matt Bowser 	KNWR~7022}
\mlabel{}{\supertiny Falls Creek Rd., Clam Gulch, AK 	60.1754¡N 	151.3395¡W 	±100m 	5/31/2011	Todd Eskelin 	KNWR~7023}
\mlabel{}{\supertiny Botenentin Lake approx 500m from campground 	60.519¡N 	150.558¡W 	±200m 	4-Jun-11	Andy Baltensperger 	KNWR~7024}
\mlabel{}{\supertiny Botenentin Lake approx 500m from campground 	60.519¡N 	150.558¡W 	±200m 	4-Jun-11	Tim Mullet 	KNWR~7024}
\mlabel{}{\supertiny Hidden Lake campground by boat launch 	60.4677¡N 	150.2035¡W 	±50m 	27.VII.2010 	Alberto Pantoja 	KNWR~7025}
\mlabel{}{\supertiny Hidden Lake campground by boat launch 	60.4677¡N 	150.2035¡W 	±50m 	27.VII.2010 	Matt Bowser 	KNWR~7025}
\mlabel{}{\supertiny Hidden Lake campground by boat launch 	60.4677¡N 	150.2035¡W 	±50m 	27.VII.2010 	Keith Pike 	KNWR~7025}
\mlabel{}{\supertiny Hidden Lake campground by boat launch 	60.4677¡N 	150.2035¡W 	±50m 	27.VII.2010 	Robert Foottit 	KNWR~7025}
\mlabel{}{\supertiny USA: Alaska, Skilak Lake Road. 	60.5151¡N 	150.5386¡W 	±15m 	27.VII.2010 	Keith Pike 	KNWR~7026}
\mlabel{}{\supertiny USA: Alaska, Skilak Lake Road. 	60.5151¡N 	150.5386¡W 	±15m 	27.VII.2010 	Matt Bowser 	KNWR~7026}
\mlabel{}{\supertiny USA: Alaska, Skilak Lake Road. 	60.5151¡N 	150.5386¡W 	±15m 	27.VII.2010 	Alberto Pantoja 	KNWR~7026}
\mlabel{}{\supertiny USA: Alaska, Skilak Lake Road. 	60.5151¡N 	150.5386¡W 	±15m 	27.VII.2010 	Robert Foottit 	KNWR~7026}
\mlabel{}{\supertiny USA: Alaska, Soldotna. 	60.4636¡N 	151.0764¡W 	±20m 	9.IX.2010 	Matt Bowser 	KNWR~7027}
\mlabel{}{\supertiny USA: Alaska, Soldotna. Forest on W. shore of Headquarters L. 	60.4628¡N 	151.0748¡W 	±50m 	26.VII.2010 	Keith Pike 	KNWR~7028}
\mlabel{}{\supertiny USA: AK, KENWR, Mystery Hills. N-facing slope above Mystery Creek. 	60.5334¡N 	150.1538¡W 	±10m 	2-Jun-05	Edward Berg 	KNWR~7029}
\mlabel{}{\supertiny Beaver Lp. Rd. 	60.562¡N 	151.1286¡W 	±50m 	7/3/2005	Todd Eskelin 	KNWR~7030}
\mlabel{}{\supertiny Beaver Lp. Rd. 	60.562¡N 	151.1286¡W 	±50m 	7/5/2005	Todd Eskelin 	KNWR~7031}
\mlabel{}{\supertiny USA: AK, Kenai NWR. Soldotna. Ski Hill Rd. Headquarters building. 	60.4647¡N 	151.0732¡W 	±50m 	2-XI-2007 	Matt Bowser 	KNWR~7032}
\mlabel{}{\supertiny USA: AK, Kasilof. N Cohoe and Hermensen Rd. 	60.3562¡N 	151.3183¡W 	±50m 	23-Jun-05	Matt Bowser 	KNWR~7033}
\mlabel{}{\supertiny USFWS building at E Tudor and New Seward Highway 	61.1825¡N 	149.862¡W 	±50m 	15.IX.2010 	Matt Bowser 	KNWR~7034}
\mlabel{}{\supertiny USFWS building at E Tudor and New Seward Highway 	61.1825¡N 	149.862¡W 	±50m 	15.IX.2010 	Matt Bowser 	KNWR~7035}
\mlabel{}{\supertiny Soldotna 	60.4637¡N 	151.076¡W 	±40m 	13.June.2011 	Matt Bowser 	KNWR~7036}
\mlabel{}{\supertiny Upper Skilak camp ground 	60.4385¡N 	150.321¡W 	±20m 	11.May.2011 	Matt Bowser 	KNWR~7037}
\mlabel{}{\supertiny USA: AK. Kasilof. Old Kasilof Rd. 	60.3653¡N 	151.2814¡W 	±80m 	15.June.2011 	Matt Bowser 	KNWR~7038}
\mlabel{}{\supertiny USA: AK. Kasilof R. 	60.3651¡N 	151.2859¡W 	±60m 	14.June.2011 	Matt Bowser 	KNWR~7039}
\mlabel{}{\supertiny USA: AK. Kasilof R. 	60.3651¡N 	151.2859¡W 	±60m 	14.June.2011 	Matt Bowser 	KNWR~7040}
\mlabel{}{\supertiny USA: AK. Kasilof R. 	60.3651¡N 	151.2859¡W 	±60m 	14.June.2011 	Matt Bowser 	KNWR~7041}
\mlabel{}{\supertiny USA: AK, Juneau. Nugget Falls Trail 	58.422¡N 	134.539¡W 	±500m 	18.June.2011 	Matt Bowser 	KNWR~7042}
\mlabel{}{\supertiny USA: AK, Juneau. UAS campus near Auke Lake. 	58.3852¡N 	134.6394¡W 	±80m 	18.June.2011 	Darren Snyder 	KNWR~7043}
\mlabel{}{\supertiny USA: AK, Juneau. 4202 Auke Lane 	58.3922¡N 	134.6297¡W 	±50m 	18.June.2011 	Darren Snyder 	KNWR~7044} 

  


\end{document}
---->

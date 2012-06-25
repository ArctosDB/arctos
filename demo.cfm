<script type="text/javascript" src="http://webplayer.yahooapis.com/player.js"></script> 

<br><a href="http://web.corral.tacc.utexas.edu/MVZ/audio/cut/D6230_Cicero_26Jun2006_Pmaculatus2.wav">http://web.corral.tacc.utexas.edu/MVZ/audio/cut/D6230_Cicero_26Jun2006_Pmaculatus2.wav</a>


<br><a href="http://web.corral.tacc.utexas.edu/MVZ/audio/mp3/D6231_Cicero_26Jun2006_Pmaculatus3.mp3">http://web.corral.tacc.utexas.edu/MVZ/audio/mp3/D6231_Cicero_26Jun2006_Pmaculatus3.mp3</a>


<br><a href="http://altai.corral.tacc.utexas.edu/mediaUploads/dlm/SweetHomeAlabama.mp3">
http://altai.corral.tacc.utexas.edu/mediaUploads/dlm/SweetHomeAlabama.mp3</a>


http://altai.corral.tacc.utexas.edu/mediaUploads/dlm/SweetHomeAlabama.mp3

<cfhttp method="get" url="http://maps.googleapis.com/maps/api/elevation/json?locations=349.7391536,-104.9847034&sensor=false">

</cfhttp>	
	
	<cfdump var=#cfhttp#>
	
	<cfoutput>
		#cfhttp.fileContent#
		
		
		<cfset x=DeserializeJSON(cfhttp.fileContent)>
		
		<cfdump var=#x#>
		
		#x.results[1].elevation#
	</cfoutput>
	
	

<cfquery name="d" datasource="uam_god">
	select ip from uam.blacklist
</cfquery>
<cfset variables.fileName="#Application.webDirectory#/.htaccess">
<cfset variables.encoding="US-ASCII">
<cfscript>
	variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
	variables.joFileWriter.writeLine('RewriteEngine On');
	variables.joFileWriter.writeLine('RewriteBase /');
	//let PNG through so CAPTCHA works
	variables.joFileWriter.writeLine('RewriteRule ^(.*)png$ - [L]');
</cfscript>	
<cfset i=1>
<cfloop query="d">
	<cfscript>
		a='RewriteCond %{REMOTE_ADDR} #ip#';
		if(i lt d.recordcount){
			a=a & ' [OR]';
		}
		variables.joFileWriter.writeLine(a);
		i=i+1;
	</cfscript>
</cfloop>
<cfscript>
	a='RewriteRule .*$ errors/gtfo.cfm';		
	variables.joFileWriter.writeLine(a);
	variables.joFileWriter.close();
</cfscript>

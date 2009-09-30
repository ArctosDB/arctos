<cfsetting showdebugoutput="false" />
<cfsetting enablecfoutputonly="false" />
<cfscript>
/*
	Create the combine object, or use the cached version
	@enableCache:				true: cache combined/compressed files locally, false: re-combine on each request
	@cachePath:					where should the cached combined files be stored?
	@enableETags:				should we return etags in the headers? Etags allow the browser to do conditional requests, i.e. only give me the file if the etag is different.
	@enableJSMin:				compress Javascript using JSMin?
	@enableYuiCSS:				compress CSS using YUI CSS compressor
	@skipMissingFiles:			true: ignore file-not-found errors, false: throw errors when a requested file cannot be found
	@getFileModifiedMethod:		'java' or 'com'. Which method to use to obtain the last modified dates of local files. Java is the recommended and default option
*/
variables.sKey = 'combine_#hash(getCurrentTemplatePath())#';
if(isDefined('application') and structKeyExists(application, variables.sKey) and not structKeyExists(url, 'reinit'))
{
	variables.oCombine = application[variables.sKey];
}
else
{
	variables.oCombine = createObject("component", "includes.Combine").init(
		enableCache: true,
		cachePath: '#application.webDirectory#/cache',
		enableETags: true,
		enableJSMin: true,
		enableYuiCSS: true,
		skipMissingFiles: false
	);
	if(isDefined('application'))
	{
		application[variables.sKey] = variables.oCombine;
	}
}
if(not structKeyExists(url, 'files'))
{
	return;
}
try
{
	variables.oCombine.combine(files: url.files);
}
catch(any e)
{
	handleError(e);
}
</cfscript>
<cffunction name="handleError" access="public" returntype="void" output="false">
	<cfargument name="cfcatch" type="any" required="true" />
	<cfmail subject="COMBINE failure" to="#Application.PageProblemEmail#" from="COMBINE_fail@#Application.fromEmail#" type="html">
		<cfdump var="#cfcatch#" />
	</cfmail>
</cffunction>
<cfsetting showdebugoutput="false" />
<cfapplication name="combine" />
<cfsetting enablecfoutputonly="true" />
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
	// use a cached version of Combine if available (unless reinit is specified in the url)
	variables.oCombine = application[variables.sKey];
}
else
{
	// no cached version, or a forced reinit. Create a new instance.
	
	// not using JavaLoader (the jar files must be in the classpath)
	variables.oCombine = createObject("component", "combine").init(
		enableCache: true,
		cachePath: expandPath('example\cache'),
		enableETags: true,
		enableJSMin: true,
		enableYuiCSS: true,
		skipMissingFiles: false
	);
	
	// using JavaLoader
	/*variables.oCombine = createObject("component", "combine").init(
		enableCache: true,
		cachePath: expandPath('example\cache'),
		enableETags: true,
		enableJSMin: true,
		enableYuiCSS: true,
		skipMissingFiles: false,
		javaLoader: createObject("component", "javaloader.JavaLoader"),
		jarPath: 'C:\www\misc\zefer\projects\combine'
	);*/
	
	// cache the object in the application scope, if we have an application scope!
	if(isDefined('application'))
	{
		application[variables.sKey] = variables.oCombine;
	}
}

/*	Make sure we have the required paths (files to combine) in the url */
if(not structKeyExists(url, 'files'))
{
	return;
}

/*	Combine the files, and handle any errors in an appropriate way for the current app */
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
	
	<!--- Put any custom error handling here e.g. --->
	<cfdump var="#cfcatch#" />
	<cflog file="combine" text="Fault caught by 'combine'">
	<cfabort />

</cffunction>
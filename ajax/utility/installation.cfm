<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		<title>CFAjax - Installation utility</title>
	</head>
	<body>
		<center>
		<h3><u>Installation Utility</u></h3>
		<cfif cgi.request_method equals "post">
			<cfset path = #path#>
			<cfset _virtual = #trim(virtual)#>
			<cfset _exiVirtual = #trim(exivirtual)#>
			
			<cfparam name="convert" default="false">
			
			<cfset virtualWithoutHost = getVirtualWithoutHost(_virtual)>
			<cfset exiVirtualWithoutHost = getVirtualWithoutHost(_exiVirtual)>

			<cfset structFindAndReplace = StructNew()>
			<cfset StructInsert(structFindAndReplace, "'#exiVirtualWithoutHost#/core/engine.js'", "'#virtualWithoutHost#/core/engine.js'")>
			<cfset StructInsert(structFindAndReplace, "'#exiVirtualWithoutHost#/core/util.js'", "'#virtualWithoutHost#/core/util.js'")>
			<cfset StructInsert(structFindAndReplace, "'#exiVirtualWithoutHost#/core/settings.js'", "'#virtualWithoutHost#/core/settings.js'")>
			<cfset StructInsert(structFindAndReplace, _exiVirtual, _virtual)>

			<cfif convert EQ false>
				<br>
				<h3><font color="#FF0000"><u>Confirmation!</u></font></h3>
				<p>Once you press confirm button following changes will occur.<br>ALL INSTANCES OF<br><br>
					<cfloop collection="#structFindAndReplace#" item="itm">
						<cfoutput><font color="##FF0000">#itm#</font>  will get changed to <font color="##FF0000">#structFindAndReplace[itm]#</font><br></cfoutput>
					</cfloop>
				</p>
				<cfoutput>
				<form id="frm" name="frm" method="post" action="installation.cfm">
					<input type="hidden" name="path" value="#path#">
					<input type="hidden" name="virtual" value="#virtual#">
					<input type="hidden" name="exivirtual" value="#exivirtual#">
					<input type="hidden" name="convert" value="true">
					<input type="submit" id="btnSubmit" name="btnSubmit" value="  Confirm  ">
				</form>
				</cfoutput>
			<cfelse>
				<br>
				<h3><font color="#FF0000"><u>Files Updated!</u></font></h3>
				
				<cfset installationDir = ArrayNew(1)>
				<cfset ArrayAppend(installationDir, path)>
				<cfset ArrayAppend(installationDir, path & "app\amazon\")>
				<cfset ArrayAppend(installationDir, path & "app\voting\")>
				<cfset ArrayAppend(installationDir, path & "app\yahoo\")>
				<cfset ArrayAppend(installationDir, path & "core\")>
				<cfset ArrayAppend(installationDir, path & "examples\")>
				<cfset files = getFiles(installationDir)>
				<cfloop from="1" to="#ArrayLen(files)#" index="i">
					<cfset fileChanged = false>
					<cffile action="read" file="#files[i]#" variable="content">
					<cfloop collection="#structFindAndReplace#" item="itm">
						<cfif FindNoCase(itm, content) GT 0>
							<cfset fileChanged = true>
							<cfset content = replaceNoCase(content, itm, structFindAndReplace[itm],"ALL")>
						</cfif>
					</cfloop>
					<cfif fileChanged EQ true>
						<cffile action="write" file="#files[i]#" output="#content#">
						<cfoutput>#files[i]#<br></cfoutput>
					</cfif>
				</cfloop>
			</cfif>
		<cfelse>
			<form id="frm" name="frm" method="post" action="installation.cfm">
				<table width="700">
					<tr>
						<td colspan="2">
							<hr size="1" width="100%">
							<br>
							<font color="#FF0000">NOTE :</font>  if you have already created a virtual folder by the name <font color="#FF0000">Ajax</font>
							in your web server and that virtual folder is accessable via the url <a href="http://localhost/ajax" target="_blank">http://localhost/ajax</a> (<small>click on this url to check</small>) then
							please <font color="#FF0000">DON NOT RUN</font> this utility. Your system is properly set for CFAjax.
							<br><br>
						</td>
					</tr>
					<tr>
						<td align="right" valign="top">
							CFAjax Physical Location : 
						</td>
						<td align="left">
							<input type="text" id="path" name="path" size="60" value="<cfoutput>#ExpandPath('..\')#</cfoutput>">
							<br>
							In order to run this utility, make sure you have write permission <br>to this folder (including sub folders)
							<br><br>
						</td>
					</tr>
					<tr>
						<td align="right" valign="top">
							Existing Virtual Path : 
						</td>
						<td align="left">
							<input type="text" id="exivirtual" name="exivirtual" size="60" value="http://localhost/ajax"> 
							<br>
							(Default value with installation is <font color="#FF0000">http://localhost/ajax</font>)
							<br><br>
						</td>
					</tr>
					<tr>
						<td align="right">
							New Virtual Path : 
						</td>
						<td align="left">
							<input type="text" id="virtual" name="virtual" size="60" value="http://localhost/ajax">
							<br>
							This is the name of virtual folder that you have created in your Web Server.
						</td>
					</tr>
					<tr>
						<td colspan="2">
							<br>
							<hr size="1" width="100%">
							<input type="submit" id="btnSubmit" name="btnSubmit" value="Convert">
							<br><br>
							<center>
							<font color="#FF0000">IMPORTANT:</font> Before running this installation utility make sure you have backed up all the files. 
							After running this utility changes cannot be reverted back.
							</center>
						</td>
					</tr>
				</table>
			</form>
		</cfif>
		</center>
	</body>
</html>


<cffunction name="getFiles" returntype="array">
	<cfargument name="dir">
	
	<cfset variables.result = ArrayNew(1)>
	<cfloop from="1" to="#ArrayLen(arguments.dir)#" index="i">
		<cfdirectory directory="#GetDirectoryFromPath(arguments.dir[i])#" name="variables.myDirectory">
		<cfloop query="variables.myDirectory">
			<cfif variables.myDirectory.type EQ "File">
				<cfif Listfind("htm,cfm,.js", lcase(right(variables.myDirectory.name,3))) GT 0>
					<cfset ArrayAppend(variables.result, arguments.dir[i] & variables.myDirectory.name)>
				</cfif>
			</cfif>
		</cfloop>
	</cfloop>
	<cfreturn variables.result>
</cffunction>

<cffunction name="getVirtualWithoutHost" returntype="string">
	<cfargument name="_virtual" required="yes" type="string">
	
	<cfset variables._virtualWithoutHost = "">
	<cfif lcase(mid(arguments._virtual,1,7)) EQ "http://">
		<cfset variables._virtualWithoutHost = mid(arguments._virtual,8,len(arguments._virtual) - 6)>
	<cfelseif lcase(mid(arguments._virtual,1,8)) EQ "https://">
		<cfset variables._virtualWithoutHost = mid(arguments._virtual,9,len(arguments._virtual) - 7)>
	</cfif>
	
	<cfif Len(_virtualWithoutHost) GT 0>
		<cfset _firstItem = ListGetAt(variables._virtualWithoutHost, 1, "/")>
		<cfset variables._virtualWithoutHost = mid(variables._virtualWithoutHost, len(_firstItem)+1, len(variables._virtualWithoutHost))>
	</cfif>
	
	<cfreturn variables._virtualWithoutHost>
</cffunction>

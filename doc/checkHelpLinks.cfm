    <cfset res=  DirectoryList(Application.webDirectory,true,path,".cfm")>
            <cfdump var="#res#">
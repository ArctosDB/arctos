    <cfset res=  DirectoryList(Application.webDirectory,true,"path","*.cf*")>
            <cfdump var="#res#">
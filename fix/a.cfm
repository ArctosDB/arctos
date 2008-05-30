<cfoutput>
 <cfimage 
            action="resize"  
            width="100"
            height="100"
            source="#application.webdirectory#/images/genericHeaderIcon.gif" 
            destination="#application.webdirectory#/temp/test.gif"
            overwrite="true">
            resize gif worked
            <cfflush>
            
             <cfimage 
            action="resize"  
            width="100"
            height="100"
            source="#application.webdirectory#/imediaUploads/dlm/screenshot_1.png " 
            destination="#application.webdirectory#/temp/test2.png"
            overwrite="true">
            resize png worked
            <cfflush>
            </cfoutput>   
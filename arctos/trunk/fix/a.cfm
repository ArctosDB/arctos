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
            source="#application.webdirectory#/images/UamMsb.jpg" 
            destination="#application.webdirectory#/temp/test2.jpg"
            overwrite="true">
            resize jpg worked
            <cfflush>
           
           
             <cfimage 
            action="convert"  
            source="#application.webdirectory#/mediaUploads/dlm/screenshot_1.png" 
            destination="#application.webdirectory#/temp/testc.jpg"
            overwrite="true">
            convert png worked
            <cfflush>
            
            
              <cfimage 
            action="convert"  
            source="#application.webdirectory#/temp/testc.jpg" 
            destination="#application.webdirectory#/temp/testc.png"
            overwrite="true">
            back to png
            <cfflush>
            
               <cfimage 
            action="resize"  
            width="100"
            height="100"
            source="#application.webdirectory#/temp/testc.png" 
            destination="#application.webdirectory#/temp/testcs.png"
            overwrite="true">
            resize made png worked....
            <cfflush>
            
             
             <cfimage 
            action="resize"  
            width="100"
            height="100"
            source="#application.webdirectory#/mediaUploads/dlm/screenshot_1.png" 
            destination="#application.webdirectory#/temp/test2.png"
            overwrite="true">
            resize png worked
            <cfflush>
            
            
            
            
            </cfoutput>   
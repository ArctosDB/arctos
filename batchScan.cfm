
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "DTD/xhtml1-transitional.dtd">
<html><head><title>glish.com : CSS layout techniques : 3 columns, the holy grail</title>

<style type="text/css">
	#leftcontent {
		position: absolute;
		left:10px;
		top:50px;
		width:30%;
		border:1px solid #000;
		}

	#centercontent {
   		margin-left: 30%;
   		margin-right:30%;
		border:1px solid #000;

	#rightcontent {
		position: absolute;
		right:10px;
		top:50px;
		width:30%;
		border:1px solid #000;
		}
	
	
</style>
</head><body>
<div id="banner"><h1><a href="home.asp">LAYOUT TECHNIQUES</a>: 3 columns, the holy grail</h1></div>
<div id="leftcontent">
	<h1>leftcontent</h1>
<pre>#leftcontent {
position: absolute;
left:10px;
top:50px;
width:200px;
background:#fff;
border:1px solid #000;
	}</pre>
	<p class="greek">
	 Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exercitation ulliam corper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem veleum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel willum lunombro dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. 
	</p>
</div>

<div id="centercontent">
	<h1>centercontent</h1>
<pre>#centercontent {
background:#fff;
margin-left: 199px;
margin-right:199px;
border:1px solid #000;
voice-family: "\"}\"";
voice-family: inherit;
margin-left: 201px;
margin-right:201px;
	}
html>body #centercontent {
margin-left: 201px;
margin-right:201px;
	}</pre>
	<p>This is the most elegant technique and perhaps the most sought after layout: a 3 column page with a fluid center column. Easy to understand, easy to implement. I first saw this layout at <a href="http://www.wrongwaygoback.com">dynamic ribbon device</a> and have since learned that the sweet CSS came from Rob Chandanais of <a href="http://www.bluerobot.com">BlueRobot</a>. Owen also made a very nice <a href="http://members.home.net/bigstripes/tutorial/css_3box_plus_topbox.html">tutorial</a> using this layout technique.</p>
	<p>Read about the IE5x PC workaround in use on this page <a href="hacks.asp">here</a>.</p>
	<p><strong>Scroll down for the source.</strong></p>
	<p class="greek">
	 Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exercitation ulliam corper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem veleum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel willum lunombro dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. 
	</p>
	<p class="greek">Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc., li tot Europa usa li sam vocabularium. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilità de un nov lingua franca: on refusa continuar payar custosi traductores. It solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles. 
	</p>
	<br />
</div>

<div id="rightcontent">
	<h1>rightcontent</h1>
<pre>#rightcontent {
position: absolute;
right:10px;
top:50px;
width:200px;
background:#fff;
border:1px solid #000;
	}</pre>
		<p>
	This page is part of <a href="home.asp">CSS Layout Techniques</a>, a resource for web developers and designers.
	</p>
	<p>
	Other Layout Techniques:<br/>
		<a href="7.asp">3 columns, the holy grail</a><br/>
	<a href="9.asp">2 columns, ALA style</a><br/>
	<a href="8.asp">4 columns, all fluid</a><br/>
	<a href="2.asp">3 columns, all fluid </a><br/>
	<a href="3.asp">static width and centered</a><br/>
	<a href="1.asp">nested float</a><br/>
	</p>
	<p>
	Does it <a href="http://validator.w3.org/check?uri=http://www.glish.com/css/7.asp?noSRC=true">validate</a>?
	</p>
</div>

</body>
</html>


<!----

<cfset title="Move Containers">
<cfinclude template="/includes/_header.cfm">
<cfif #action# is "nothing">
<cfoutput>
	<cfset numberFolders = 40>
	<form name="pd" method="post" action="index.cfm">
		<input type="hidden" name="action" value="save">
		<input type="hidden" name="numberFolders" value="#numberFolders#">
		<label for="parent_barcode">Barcode</label>
		<input type="text" name="parent_barcode" id="parent_barcode" size="20" class="reqdClr">
		<label for="sheets">Child Barcodes</label>		
		<cfset numCols="3">
		<cfset numRows=int(numberFolders/numCols)>
		
			<div style="border:1px solid green; padding:10px;" id="sheets">
				<table border>
					<tr>						
						<th>Barcode</th>
					</tr>
					<cfset i=1>
					<cfloop from="1" to="#numberFolders#" index="i">
						<tr>
							<td>
								<input type="text" name="barcode_#i#" id="barcode_#i#" size="20" class="reqdClr">	
							</td>												
						</tr>
						<cfset i=i+1>
					</cfloop>					
				</table>
			</div>
		</td>
		<td valign="top">
			<label for="control">Controls</label>	
			<div style="border:1px solid green; padding:10px;" id="control">
				<input type="submit" 
					class="savBtn"
					onmouseover="this.className='savBtn btnhov'" 
	   				onmouseout="this.className='savBtn'"
					value="Save to Database">
				<p>
				<input type="reset" 
					class="clrBtn"
					onmouseover="this.className='clrBtn btnhov'" 
	   				onmouseout="this.className='clrBtn'"
					value="Clear Form">
				<p>
				<input type="button" 
					class="lnkBtn"
					onmouseover="this.className='lnkBtn btnhov'" 
	   				onmouseout="this.className='lnkBtn'"
					value="Edit Mode"
					onclick="document.location='ala_edit.cfm';">			
			
			</div>
		</td>
	</tr>
</table>
</form>
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------->
<cfif #action# is "save">
<!--- 
	create table ala_plant_imaging (
		image_id number not null,
		folder_identification varchar2(255),
		folder_barcode varchar2(255),
		idType varchar2(255),
		idNum varchar2(255),
		barcode varchar2(255),
		whodunit varchar2(255),
		whendunit date
	);
	create public synonym ala_plant_imaging for ala_plant_imaging;
	grant select on ala_plant_imaging to public;
	grant insert on ala_plant_imaging to uam_update;
	create sequence ala_plant_imaging_seq;
	create public synonym ala_plant_imaging_seq for ala_plant_imaging_seq;
	
CREATE OR REPLACE TRIGGER ala_plant_imaging_key                                         
 before insert  ON ala_plant_imaging  
 for each row 
    begin                                                                                       
    	select ala_plant_imaging_seq.nextval into :new.image_id from dual;
   	end;                                                                                            
/
sho err


--->	

	<cfoutput>
		<cfif len(#folder_identification#) is 0 or len(#folder_barcode#) is 0>
			Folder Identification, Folder Barcode and Sheet Barcode are required. Use your back button...
			<cfabort>
		</cfif>
		<cfloop from="1" to ="#numberFolders#" index="i">
			<cfset thisNumType = evaluate("idType_" & i)>
			<cfset thisNum = evaluate("idNum_" & i)>
			<cfset thisBarcode=evaluate("barcode_" & i)>
			<cfif len(#thisBarcode#) gt 0>
			<cfquery name="ins" datasource="#Application.uam_dbo#">
				insert into ala_plant_imaging (
					folder_identification,
					folder_barcode,
					idType,
					idNum,
					barcode,
					whodunit,
					whendunit
				) values (
					'#folder_identification#',
					'#folder_barcode#',
					'#thisNumType#',
					'#thisNum#',
					'#thisBarcode#',
					'#session.username#',
					sysdate
				)
			</cfquery>				
			</cfif>	
		</cfloop>
		<cflocation url="index.cfm">
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">

---->
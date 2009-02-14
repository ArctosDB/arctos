<cfinclude template="/includes/_helpHeader.cfm">
<cfset title = "Fields in Bulk-loader Template">

<font size="-2"><a href="../">Help</a> >> <a href="index.cfm">Bulk-loading Overview</a> >> <strong>Fields in Bulk-loader Template</strong></font><br />

<strong><font size="+2">Fields in Bulk-loader Template</font></strong>
  <table width="100%" border="1" bordercolor="#191970">
    <tr> 
      <td><font size="+1"><strong>Field Name<br>
        </strong><font color="#FF0000" size="-1">required</font><font size="-1"><br>
        <font color="#666666">conditionally required</font><br>
        <font color="#00FF00">not required</font></font></font></td>
      <td><font size="+1"><strong>Data&nbsp;Type</strong></font></td>
      <td><font size="+1"><strong>Controlled?</strong></font></td>
      <td><font size="+1"><strong>Description/Example</strong></font></td>
    </tr>
    <tr> 
      <td><font color="#FF0000">Collection_Object_Id</font></td>
      <td>autonumber</td>
      <td>yes</td>
      <td>Any unique, within the current file, integer. Does NOT carry over to any internal primary keys.</td>
    </tr>
    <tr> 
      <td><font color="#00FF00">Cat_Num</font></td>
      <td>number</td>
      <td>no</td>
      <td><a href="../cataloged_item#catalog_number">
	  <img src="../images/info.gif" border="0" width="12" height="11"></a> 
	  Existing catalog number, or leave blank to assign sequential numbers 
        on upload.</td>
    </tr>
    <tr> 
      <td><font color="#FF0000">Began_Date</font></td>
      <td>date<sup><a href="#dateFormat">*</a></sup></td>
      <td>no</td>
      <td><a href="../collecting_event.cfm#began_date"><img src="../images/info.gif" border="0" width="12" height="11"></a> 
	  Earliest date the specimen could have been collected. </td>
    </tr>
    <tr> 
      <td><font color="#FF0000">Ended_Date</font></td>
      <td>date<sup><a href="#dateFormat">*</a></sup></td>
      <td>no</td>
      <td><a href="../collecting_event.cfm#began_date"><img src="../images/info.gif" border="0" width="12" height="11"></a> 
	  Latest date the specimen could have been collected. </td>
    </tr>
    <tr> 
      <td><font color="#FF0000">Verbatim_Date</font></td>
      <td>text</td>
      <td>no</td>
      <td><a href="../collecting_event.cfm#verbatim_date"><img src="../images/info.gif" border="0" width="12" height="11"></a> 
	  Examples: 'winter 2002';
        '1 Nov 2002';  'Nov 2002'. </td>
    </tr>
    <tr> 
      <td><font color="#00FF00">Coll_Event_Remarks</font></td>
      <td>text</td>
      <td>no</td>
      <td>Remarks about Collecting Event.</td>
    </tr>
    <tr> 
      <td><font color="#FF0000">Higher_Geog</font></td>
      <td>text</td>
      <td>yes</td>
      <td><a href="../higher_geography.cfm"><img src="../images/info.gif" border="0" width="12" height="11"></a> 
	  Higher Geography <em>exactly</em> as it appears in table Geog_Auth_Rec. 
      New values must be added to the database prior to bulk-loading.</td>
    </tr>
    <tr> 
      <td><font color="#666666">Maximum_Elevation</font></td>
      <td>number</td>
      <td>no</td>
      <td><a href="../locality.cfm#elevation"><img src="../images/info.gif" border="0" width="12" height="11"></a> 
	  Maximum elevation from which the specimen could have come. 
	  Used in conjunction with Minimum_Elevation and Orig_Elev_Units.</td>
    </tr>
    <tr> 
      <td><font color="#666666">Minimum_Elevation</font></td>
      <td>number</td>
      <td>no</td>
      <td><a href="../locality.cfm#elevation"><img src="../images/info.gif" border="0" width="12" height="11"></a> 
	  Minimum elevation from which the specimen could have come. 
	  Used in conjunction with Maximum_Elevation and Orig_Elev_Units.</td>
    </tr>
    <tr> 
      <td><font color="#666666">Orig_Elev_Units</font></td>
      <td>text</td>
      <td>yes</td>
      <td><a href="../locality.cfm#elevation"><img src="../images/info.gif" border="0" width="12" height="11"></a> 
	  Used in conjunction with Maximum_Elevation and Minimum_Elevation. 
	  (Code table controlled.)</td>
    </tr>
    <tr> 
      <td><font color="#FF0000">Spec_Locality</font></td>
      <td>text</td>
      <td>no</td>
      <td><a href="../locality.cfm#specific_locality"><img src="../images/info.gif" border="0" width="12" height="11"></a> 
	  Specific locality from which a specimen originates.</td>
    </tr>
    <tr> 
      <td><font color="#00FF00">Locality_Remarks</font></td>
      <td>text</td>
      <td>no</td>
      <td>Remarks associated with Locality.</td>
    </tr>
    <tr> 
      <td><font color="#00FF00">Datum</font></td>
      <td>text</td>
      <td>yes</td>
      <td><a href="../lat_long.cfm#datum"><img src="../images/info.gif" border="0" width="12" height="11"></a> 
	  Map datum used to determine Lat/Long.</td>
    </tr>
    <tr> 
      <td><font color="#00FF00">Orig_Lat_Long_Units</font></td>
      <td>text</td>
      <td>yes</td>
      <td><a href="../lat_long.cfm#original_units"><img src="../images/info.gif" border="0" width="12" height="11"></a> Lat/Long units as given by the determining agent and before any transformations.</td>
    </tr>
    <tr> 
      <td><font color="#00FF00">Determined_By_Agent</font></td>
      <td>text</td>
      <td>yes</td>
      <td><a href="../lat_long.cfm#determiner"><img src="../images/info.gif" border="0" width="12" height="11"></a> Agent who determined Lat/Long and associated data. Must exactly match 
        an existing Agent Name.</td>
    </tr>
    <tr> 
      <td><font color="#00FF00">Determined_Date</font></td>
      <td>date<sup><a href="#dateFormat">*</a></sup></td>
      <td>no</td>
      <td><a href="../lat_long.cfm#date"><img src="../images/info.gif" border="0" width="12" height="11"></a> Date on which Lat/Long was determined.</td>
    </tr>
    <tr> 
      <td><font color="#00FF00">Lat_Long_Ref_Source</font></td>
      <td>text</td>
      <td>yes</td>
      <td><a href="../lat_long.cfm#source"><img src="../images/info.gif" border="0" width="12" height="11"></a> 
	  A code indicating the reference from which a Lat/Long was determined.</td>
    </tr>
    <tr> 
      <td><font color="#00FF00">Lat_Long_Remarks</font></td>
      <td>text</td>
      <td>no</td>
      <td>&nbsp;Remarks associated with the Lat/Long determination..</td>
    </tr>
    <tr> 
      <td><font color="#00FF00">Max_Error_Distance</font></td>
      <td>number</td>
      <td>no</td>
      <td><a href="../lat_long.cfm#maximum_error"><img src="../images/info.gif" border="0" width="12" height="11"></a> 
	  The maximum possible error in distance between the recorded Lat_Long 
        and the actual Lat_Long of the specific locality.</td>
    </tr>
    <tr> 
      <td><font color="#00FF00">Max_Error_Units</font> </td>
      <td>text</td>
      <td>yes</td>
      <td><a href="../lat_long.cfm#maximum_error"><img src="../images/info.gif" border="0" width="12" height="11"></a> 
	  The units in which the Max_Error_Distance are recorded.</td>
    </tr>
    <tr>
      <td colspan="4"><em>Geogrphic coordinates may be entered in decimal degrees<sup>1</sup>, 
	  degrees-minutes-seconds<sup>2</sup>, or in degrees with decimal minutes<sup>3</sup>.</em>
	  <a href="../lat_long.cfm#original_units"><img src="../images/info.gif" border="0" width="12" height="11"></a></td>
    </tr>
    <tr> 
      <td><font color="#666666">Dec_Lat<sup>1</sup></font></td>
      <td>number</td>
      <td>no</td>
      <td>Decimal latitude.</td>
    </tr>
    <tr> 
      <td><font color="#666666">Dec_Long<sup>1</sup></font></td>
      <td>number</td>
      <td>no</td>
      <td>Decimal longitude.</td>
    </tr>
    <tr> 
      <td><font color="#666666">LatDeg<sup>2 and 3</sup></font></td>
      <td>number</td>
      <td>no</td>
      <td>Degrees Latitude (Integer, 90 or less.) </td>
    </tr>
    <tr> 
      <td><font color="#666666">LatMin<sup>2</sup></font></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>Minutes Latitude (Integer, less than 60.) </td>
    </tr>
    <tr> 
      <td><font color="#666666">LatSec<sup>2</sup></font></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>Seconds Latitude (Decimal fraction, less than 60.)</td>
    </tr>
    <tr> 
      <td><font color="#666666">LatDir<sup>2 and 3</sup></font></td>
      <td>text</td>
      <td>yes</td>
      <td>Latitude Direction: "N" or "S" (North or South).</td>
    </tr>
    <tr> 
      <td><font color="#666666">LongDeg<sup>2 and 3</sup></font></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>Degrees Longitude (Integer, 180 or less.) </td>
    </tr>
    <tr> 
      <td><font color="#666666">LongMin<sup>2</sup></font></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>Minutes Longitude (Integer, less than 60.)</td>
    </tr>
    <tr> 
      <td><font color="#666666">LongSec<sup>2</sup></font></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>Seconds Longitude (Decimal fraction, less than 60.)</td>
    </tr>
    <tr> 
      <td><font color="#666666">LongDir<sup>2 and 3</sup></font></td>
      <td>text</td>
      <td>yes</td>
      <td>Longitude Direction: "E" or "W" (East or West).</td>
    </tr>
    <tr> 
      <td><font color="#666666">Dec_Lat_Min<sup>3</sup></font></td>
      <td>number</td>
      <td>no</td>
      <td>Decimal Latitude Minutes (Used with LatDeg, decimal fraction, less than 60.) </td>
    </tr>
    <tr> 
      <td><font color="#666666">dec_long_min<sup>3</sup></font></td>
      <td>number</td>
      <td>no</td>
      <td>Decimal Longitude Minutes (Used with LongDeg, decimal fraction, less than 60.) </td>
    </tr>
    <tr> 
      <td><font color="#FF0000">Verbatim_Locality</font></td>
      <td>text</td>
      <td>no</td>
      <td><a href="../collecting_event.cfm#verbatim_locality"><img src="../images/info.gif" border="0" width="12" height="11"></a> 
	  The  locality, entered as closely as possible 
        to the original text provided by the collector. 
		(Not necessarily the same as 
        <a href="../locality.cfm#specific_locality">specific locality</a>.)</td>
    </tr>
	  <tr> 
      <td><font color="#FF0000">Collecting_Source</font></td>
      <td>text</td>
      <td>yes</td>
      <td>
	  	Source from which the specimen was received. Example: "wild caught"
	  </td>
    </tr>
    <tr> 
      <td><font color="#00FF00">Habitat_Desc</font></td>
      <td>text</td>
      <td>no</td>
      <td><a href="../collecting_event.cfm#habitat"><img src="../images/info.gif" border="0" width="12" height="11"></a> 
	  A description of gross specimen habitat (&quot;black spruce forest&quot;).</td>
    </tr>
    <tr> 
      <td><font color="#FF0000">Coll_Obj_Disposition</font></td>
      <td>text</td>
      <td>yes</td>
      <td><a href="../parts.cfm#disposition">
	  <img src="../images/info.gif" border="0" width="12" height="11"></a> 
	  Disposition of the collection object.</td>
    </tr>
    <tr> 
      <td><font color="#FF0000">Condition</font></td>
      <td>text</td>
      <td>no</td>
      <td><a href="../parts.cfm#condition">
	  <img src="../images/info.gif" border="0" width="12" height="11"></a> 
	  Condition of the Collection Object.</td>
    </tr>
    <tr> 
      <td><font color="#00FF00">Coll_Object_Remarks</font></td>
      <td>text</td>
      <td>no</td>
      <td>Collection Object Remarks.</td>
    </tr>
    <tr> 
      <td><font color="#00FF00">Disposition_Remarks</font></td>
      <td>text</td>
      <td>no</td>
      <td>Remarks explaining the disposition of the collection object.</td>
    </tr>
    <tr> 
      <td><font color="#FF0000">Id_Made_By_Agent</font></td>
      <td>text</td>
      <td>yes</td>
      <td><a href="../identification.cfm#id_by"><img src="../images/info.gif" border="0" width="12" height="11"></a> 
	  Agent who identified the specimen.</p>
      </td>
    </tr>
    <tr> 
      <td><font color="#00FF00">Identification_Remarks</font></td>
      <td>text</td>
      <td>no</td>
      <td>Remarks associated with this identification.</td>
    </tr>
    <tr> 
      <td><font color="#FF0000">Made_Date</font></td>
      <td>date<sup><a href="#dateFormat">*</a></sup></td>
      <td>no</td>
      <td><a href="../identification.cfm#id_date"><img src="../images/info.gif" border="0" width="12" height="11"></a> 
	  Date identification was determined.</td>
    </tr>
    <tr> 
      <td><font color="#FF0000">Nature_of_Id</font></td>
      <td>text</td>
      <td>yes</td>
      <td><a href="../identification.cfm#nature_of_id"><img src="../images/info.gif" border="0" width="12" height="11"></a> 
	  How identification was determined. (Code-table controlled.) </td>
    </tr>
    <tr> 
      <td><font color="#FF0000">Taxon_Name</font></td>
      <td>text</td>
      <td>yes</td>
      <td><a href="../identification.cfm#id_formula"><img src="../images/info.gif" border="0" width="12" height="11"></a> 
	  Scientific Name assigned by identifying agent.</td>
    </tr>
    <tr> 
      <td><font color="#00FF00">Other_Id_Num_x</font></td>
      <td>text</td>
      <td>no</td>
      <td>Other identifying numbers (ie, original field number).</td>
    </tr>
    <tr> 
      <td><font color="#666666">Other_Id_Num_Type_x</font></td>
      <td>text</td>
      <td>yes</td>
      <td>Used in conjunction with Other_Id_Num</td>
    </tr>
    <tr> 
      <td><font color="#FF0000">Collector_Agent_x</font></td>
      <td>text</td>
      <td>yes</td>
      <td>Collector or preparator name as it appears in Arctos. At least one collector_agent is required.</td>
    </tr>
    <tr> 
      <td><font color="#FF0000">Collector_Role_x</font></td>
      <td>text</td>
      <td>yes</td>
      <td>"c" or "p" (collector or preparator). First collector must exist with a role of "c."</td>
    </tr>
    <tr> 
      <td><font color="#FF0000">Part_Name_x</font></td>
      <td>text</td>
      <td>yes</td>
      <td><a href="../parts.cfm#part_name">
	  <img src="../images/info.gif" border="0" width="12" height="11"></a> 
	  At least one part is required.</td>
    </tr>
	<tr> 
      <td><font color="#FF0000">Part_lot_count_x</font></td>
      <td>number</td>
      <td>no</td>
      <td>A part_lot_count is required for all non-null parts.</td>
    </tr>
    <tr> 
      <td><font color="#00FF00">Part_Modifier_x</font></td>
      <td>text</td>
      <td>no</td>
      <td>A series of one or more adjectives describing specimen part (broken, left, upper) </td>
    </tr>
    <tr> 
      <td><font color="#666666">Preserv_Method_x</font></td>
      <td>text</td>
      <td>yes</td>
      <td><a href="../parts.cfm#pres_method">
	  <img src="../images/info.gif" border="0" width="12" height="11"></a> 
	  Indicates preservation method(s) used for a specimen. Used only if non-standard 
        for the part.&nbsp;</td>
    </tr>
    <tr> 
      <td><font color="#FF0000">Part_Condition_x</font></td>
      <td>text</td>
      <td>no</td>
      <td>A description of the latest documented condition.&nbsp;</td>
    </tr>
	<tr> 
      <td><font color="#FF0000">Part_disposition_x</font></td>
      <td>text</td>
      <td>no</td>
      <td>A Part_disposition is required for all non-null parts. Example: "in collection"</td>
    </tr>
    <tr> 
      <td><font color="#00FF00">Part_Barcode_x</font></td>
      <td>text</td>
      <td>no</td>
      <td>Barcode on the part as it will be read by a barcode scanner.</td>
    </tr>
    <tr> 
      <td><font color="#00FF00">Part_Container_Label_x</font></td>
      <td>text</td>
      <td>no</td>
      <td>Label on the container (ie, Nunc tube). The human-readable printing 
        on the container.</td>
    </tr>
    <tr> 
      <td><font color="#FF0000">Accn</font></td>
      <td>number</td>
      <td>yes</td>
      <td>Accession Number assigned upon acceptance of specimens.</td>
    </tr>
    <tr> 
      <td><font color="#FF0000">EnteredBy</font></td>
      <td>text</td>
      <td>yes</td>
      <td>Agent entering the data into this table. Must match agent_name of type login.</td>
    </tr>
    <tr> 
      <td><font color="#FF0000">Collection_Cde</font></td>
      <td>text</td>
      <td>yes</td>
      <td>Collection under which the specimen will be cataloged.</td>
    </tr>
    <tr> 
      <td><font color="#FF0000">Loaded</font></td>
      <td>n</td>
      <td>yes</td>
      	<td>
			Generally NULL for loading text files. This is where errors are 
			stored after Bulkloader processing
		</td>
    </tr>
    <tr>
      <td><font color="#FF0000">institution_acronym</font></td>
      <td>text</td>
      <td>yes</td>
      <td>UAM, MVZ, MSB, MCZ, etc.    
    </tr>
    <tr>
      <td><font color="#00FF00">Flags</font></td>
      <td>text</td>
      <td>yes</td>
      <td>Flag indicating the specimen needs further work.    
    </tr>
    <tr>
      <td><font color="#FF0000">Attribute</font></td>
      <td>text</td>
      <td>yes</td>
      <td>Attribute type. (Code-table controlled.)</td>     
    </tr>
    <tr>
      <td><font color="#FF0000">Attribute_value</font></td>
      <td>text</td>
      <td>sometimes</td>
      <td>Value of the attribute     
    </tr>
    <tr>
      <td><font color="#FF0000">Attribute_units</font></td>
      <td>text</td>
      <td>yes</td>
      <td>Units on attribute_value, where appropriate.     
    </tr>
    <tr>
      <td><font color="#00FF00">attribute_remarks</font></td>
      <td>text</td>
      <td>no</td>
      <td>Remarks about the attribute.     
    </tr>
    <tr>
      <td><font color="#FF0000">attribute_date</font></td>
      <td>date<sup><a href="#dateFormat">*</a></sup></td>
      <td>no</td>
      <td>Date the attribute was determined.    
    </tr>
    <tr>
      <td><font color="#00FF00">attribute_det_meth</font></td>
      <td>text</td>
      <td>no</td>
      <td>How the attribute was determined.    
    </tr>
    <tr>
      <td><font color="#FF0000">attribute_determiner</font></td>
      <td>text</td>
      <td>yes</td>
      <td>Agent who determined the attribute. 
    </tr>
  </table>
<ul>
	<a name="dateFormat"></a>
	<li>All date fields should be formatted as DD-Mon-YYYY, <em>e.g.</em>, <strong>01-Jan-2006</strong></li>
</ul>
<cfinclude template="/includes/_helpFooter.cfm">
<cfquery name="getUser" datasource="uam_god">
   DECLARE   @param1 varchar(50)
   DECLARE @param2 int = 5555
   
   set @param1 = 'UAM:Mamm'
   set @param2 = 12
   
   SELECT
	cat_num,guid
   FROM   flat
   WHERE   cat_num = @param1
   AND      guid = @param2
</cfquery>


<cfdump var=#getUser#>

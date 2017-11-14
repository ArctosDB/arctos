<!----
	alter table cf_global_settings add announcement_text varchar2 (255);
---->


<cfinclude template="/includes/_header.cfm">
<cfoutput>
	<cfif action is "nothing">
		<cfset title="Global Arctos Settings: be careful in here!">
		<cfquery name="d" datasource="uam_god">
			select * from cf_global_settings
		</cfquery>
		<cfif d.recordcount neq 1>
			Something is hosed. Contact a DBA.
			<cfabort>
		</cfif>
		<h2>
			Global DB Settings
		</h2>
		<h3>You can break everything here. Please don't.</h3>
		<form method="post" action="global_settings.cfm" name="f" id="f">
			<input type="hidden" name="action" value="save">

			<label for="announcement_text">announcement_text (displays in header)</label>
			<textarea name="announcement_text" id="announcement_text" rows="6" cols="50" class="hugetextarea">#d.announcement_text#</textarea>


			<!---- google ---->
			<label for="GOOGLE_CLIENT_ID">GOOGLE_CLIENT_ID (https://google.secure.force.com)</label>
			<input type="text" name="GOOGLE_CLIENT_ID" id="GOOGLE_CLIENT_ID" size="80" value="#d.GOOGLE_CLIENT_ID#">

			<label for="GOOGLE_PRIVATE_KEY">GOOGLE_PRIVATE_KEY (https://google.secure.force.com)</label>
			<input type="text" name="GOOGLE_PRIVATE_KEY" id="GOOGLE_PRIVATE_KEY" size="80" value="#d.GOOGLE_PRIVATE_KEY#">


			<label for="GOOGLE_UACCT">GOOGLE_UACCT (Analytics logging)</label>
			<input type="text" name="GOOGLE_UACCT" id="GOOGLE_UACCT" size="80" value="#d.GOOGLE_UACCT#">

			<label for="GMAP_API_KEY">GMAP_API_KEY (Public Google APIs)</label>
			<input type="text" name="GMAP_API_KEY" id="GMAP_API_KEY" size="80" value="#d.GMAP_API_KEY#">

			<!--- DOIs ---->
			<label for="EZID_USERNAME">EZID_USERNAME (http://ezid.cdlib.org/)</label>
			<input type="text" name="EZID_USERNAME" id="EZID_USERNAME" size="80" value="#d.EZID_USERNAME#">

			<label for="EZID_PASSWORD">EZID_PASSWORD (http://ezid.cdlib.org/)</label>
			<input type="text" name="EZID_PASSWORD" id="EZID_PASSWORD" size="80" value="#d.EZID_PASSWORD#">

			<label for="EZID_SHOULDER">EZID_SHOULDER (http://ezid.cdlib.org/)</label>
			<input type="text" name="EZID_SHOULDER" id="EZID_SHOULDER" size="80" value="#d.EZID_SHOULDER#">

			<!--- genbank ---->
			<label for="GENBANK_PRID">GENBANK_PRID (GenBank data sharing)</label>
			<input type="text" name="GENBANK_PRID" id="GENBANK_PRID" size="80" value="#d.GENBANK_PRID#">

			<label for="GENBANK_PASSWORD">GENBANK_PASSWORD(GenBank data sharing)</label>
			<input type="text" name="GENBANK_PASSWORD" id="GENBANK_PASSWORD" size="80" value="#d.GENBANK_PASSWORD#">
			<label for="GENBANK_USERNAME">GENBANK_USERNAME(GenBank data sharing)</label>
			<input type="text" name="GENBANK_USERNAME" id="GENBANK_USERNAME" size="80" value="#d.GENBANK_USERNAME#">

			<!--- contacts ---->

			<label for="BUG_REPORT_EMAIL">BUG_REPORT_EMAIL (no-space comma-list; application problems, but much overlap with data)</label>
			<textarea name="BUG_REPORT_EMAIL" id="BUG_REPORT_EMAIL" rows="6" cols="50" class="hugetextarea">#d.BUG_REPORT_EMAIL#</textarea>


			<label for="DATA_REPORT_EMAIL">DATA_REPORT_EMAIL (no-space comma-list; data problems, but much overlap with application)</label>
			<textarea name="DATA_REPORT_EMAIL" id="DATA_REPORT_EMAIL" rows="6" cols="50" class="hugetextarea">#d.DATA_REPORT_EMAIL#</textarea>


			<label for="LOG_EMAIL">LOG_EMAIL (no-space comma-list; normal systems logs; heavy use)</label>
			<textarea name="LOG_EMAIL" id="LOG_EMAIL" rows="6" cols="50" class="hugetextarea">#d.LOG_EMAIL#</textarea>

			<!--- monitoring ---->


			<label for="monitor_email_addr">monitor_email_addr</label>
			<input type="text" name="monitor_email_addr" id="monitor_email_addr" size="80" value="#d.monitor_email_addr#">@gmail.com


			<label for="monitor_email_pwd">monitor_email_pwd</label>
			<input type="text" name="monitor_email_pwd" id="monitor_email_pwd" size="80" value="#d.monitor_email_pwd#">




			<label for="PROTECTED_IP_LIST">PROTECTED_IP_LIST (never-blacklist IPs)</label>
			<textarea name="PROTECTED_IP_LIST" id="PROTECTED_IP_LIST" rows="6" cols="50" class="hugetextarea">#d.PROTECTED_IP_LIST#</textarea>
			<br>IP FORMAT:
			<ul>
				<li>
					IP addresses (1.2.3.4) separated by commas WITH NO SPACES
					<ul>
						<li>1.2.3.4,1.2.3.5</li>
						<li>NOT: 1.2.3.4, 1.2.3.5</li>
					</ul>
				</li>
				<li>
					As above with * wildcards
					<ul>
						<li>1.2.3.* protects 1.2.3.1 and ... and 1.2.3.255</li>
						<li>1.2.*.* protects subnet 1.2</li>
					</ul>
				</li>
			</ul>

			<label for="protect_ip_remark">protect_ip_remark (document everything up there down here)</label>
			<textarea name="protect_ip_remark" id="protect_ip_remark" rows="6" cols="50" class="hugetextarea">#d.protect_ip_remark#</textarea>



			<input type="submit" value="saveAll" class="savBtn">
		</form>
	</cfif>
	<cfif action is "save">
		<cfquery name="d" datasource="uam_god">
			update cf_global_settings set
				GOOGLE_CLIENT_ID='#GOOGLE_CLIENT_ID#',
				GOOGLE_PRIVATE_KEY='#GOOGLE_PRIVATE_KEY#',
				EZID_USERNAME='#EZID_USERNAME#',
				EZID_PASSWORD='#EZID_PASSWORD#',
				EZID_SHOULDER='#EZID_SHOULDER#',
				GMAP_API_KEY='#GMAP_API_KEY#',
				BUG_REPORT_EMAIL='#BUG_REPORT_EMAIL#',
				GOOGLE_UACCT='#GOOGLE_UACCT#',
				GENBANK_PRID='#GENBANK_PRID#',
				GENBANK_PASSWORD='#GENBANK_PASSWORD#',
				GENBANK_USERNAME='#GENBANK_USERNAME#',
				DATA_REPORT_EMAIL='#DATA_REPORT_EMAIL#',
				LOG_EMAIL='#LOG_EMAIL#',
				PROTECTED_IP_LIST='#PROTECTED_IP_LIST#',
				protect_ip_remark='#protect_ip_remark#',
				monitor_email_addr='#monitor_email_addr#',
				monitor_email_pwd='#monitor_email_pwd#',
				announcement_text='#announcement_text#'
		</cfquery>
		<cflocation url="global_settings.cfm" addtoken="false">
	</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
<cfquery name="sentEmail" datasource="uam_god">
					update 
						cf_dup_agent
					set 
						status='E',
						last_date=sysdate
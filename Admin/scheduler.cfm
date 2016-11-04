<!---------------

-- see v7.3.4.3 for last working old-style version



select * from cf_crontab where job_name='upclass_getClassificationID';




insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'upclass_getClassificationID',
	'processBulkloadClassification.cfm?action=getClassificationID',
	'600',
	'classification bulkloader: get Taxon IDs',
	'every hour at 25 after',
	'0',
	'25',
	'*',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'upclass_checkMeta',
	'processBulkloadClassification.cfm?action=checkMeta',
	'60',
	'classification bulkloader: prepare for processing',
	'every hour at 5 after',
	'0',
	'05',
	'*',
	'*',
	'*',
	'?'
);

insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'upclass_fitbfg',
	'processBulkloadClassification.cfm?action=fill_in_the_blanks_from_genus',
	'60',
	'classification bulkloader: fill in blanks when given genus',
	'every 3 minutes',
	'0',
	'0/3',
	'*',
	'1/1',
	'*',
	'?'
);
insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'bulkload_classification_checkall',
	'processBulkloadClassification.cfm?action=doEverything',
	'60',
	'Process things marked "go_go_all" in the classification bulkloader',
	'every 2 minutes',
	'0',
	'0/2',
	'*',
	'1/1',
	'*',
	'?'
);




drop table cf_crontab;

create table cf_crontab (
	cf_crontab_id number not null,
	job_name varchar2(30) not null,
	path varchar2(255) not null,
	timeout number not null,
	purpose varchar2(255) not null,
	run_interval_desc varchar2(255) not null,
	cron_sec varchar2(6) not null,
	cron_min varchar2(255) not null,
	cron_hour varchar2(6) not null,
	cron_dom varchar2(6) not null,
	cron_mon  varchar2(6) not null,
	cron_dow varchar2(6) not null
);

create unique index ixu_cf_crontab_jobname on cf_crontab (job_name) tablespace uam_idx_1;
create unique index ixu_cf_crontab_path on cf_crontab (path) tablespace uam_idx_1;

alter table cf_crontab modify job_name varchar2(38);


CREATE OR REPLACE TRIGGER trg_cf_crontab
 before insert or update ON cf_crontab
 for each row
    begin
	    if inserting then
		    IF :new.cf_crontab_id IS NULL THEN
	    		select someRandomSequence.nextval into :new.cf_crontab_id from dual;
	    	end if;
	    end if;

    end;
/
sho err










delete from cf_crontab;


-- existing data
insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'reports_deleteUnused',
	'reportMaintenance.cfm?action=deleteUnused',
	'600',
	'maintenance: delete report templates which have no handler and are not used.',
	'daily: 4:17 AM',
	'0',
	'17',
	'04',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'reports_emailNotifyNotUsed',
	'reportMaintenance.cfm?action=emailNotifyNotUsed',
	'600',
	'email reminder for possibly-unused reports',
	'4:21 AM every day',
	'0',
	'21',
	'04',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'fetchRelatedInfo',
	'fetchRelatedInfo.cfm',
	'600',
	'maintenance: Cache related-specimen information',
	'42 minutes after every hour',
	'0',
	'42',
	'*',
	'*',
	'*',
	'?'
);

insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'pendingRelations',
	'pendingRelations.cfm',
	'600',
	'maintenance: Fetch unreciprocated relationships into otherID bulkloader',
	'every 10 minutes - xx:03, xx:13, etc. Necessary to ensure a run for every (100) collection every day',
	'0',
	'3,13,23,33,43,53',
	'*',
	'*',
	'*',
	'?'
);



insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'duplicate_agents_findDups',
	'duplicate_agents.cfm?action=findDups',
	'600',
	'agent maintenance: detect duplicate agents',
	'4:51 AM every day',
	'0',
	'51',
	'04',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'duplicate_agents_merge',
	'duplicate_agents.cfm?action=merge',
	'600',
	'agent maintenance: Merge duplicate agents',
	'5:01 AM every day',
	'0',
	'01',
	'05',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'duplicate_agents_notify',
	'duplicate_agents.cfm?action=notify',
	'600',
	'agent maintenance: Merge duplicate agents notification',
	'05:21 AM every day',
	'0',
	'21',
	'05',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'es_spec_insBulk',
	'es_spec.cfm?action=insBulk',
	'600',
	'ES imaging: insert to bulkloader from uam:es imaging app',
	'12:21 AM AM every day',
	'0',
	'21',
	'12',
	'*',
	'*',
	'?'
);

insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'es_spec_findSpec',
	'es_spec.cfm?action=findSpec',
	'600',
	'ES imaging: Find imaged UAM:ES specimens by barcode',
	'01:31 AM every day',
	'0',
	'31',
	'1',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'es_tacc_getDir',
	'es_tacc.cfm?action=getDir',
	'600',
	'ES imaging: Find UAM:ES images at TACC',
	'02:31 AM every day',
	'0',
	'31',
	'02',
	'*',
	'*',
	'?'
);

insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'es_tacc_accn_card_media',
	'es_tacc.cfm?action=accn_card_media',
	'600',
	'ES imaging: Find images of UAM:ES accn cards at TACC',
	'02:51 AM every day',
	'0',
	'51',
	'02',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'es_tacc_loc_card_media',
	'es_tacc.cfm?action=loc_card_media',
	'600',
	'ES imaging: Find images of UAM:ES locality cards at TACC',
	'03:01 AM every day',
	'0',
	'01',
	'03',
	'*',
	'*',
	'?'
);



insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'es_tacc_spec_media',
	'es_tacc.cfm?action=spec_media',
	'600',
	'ES imaging: Find images of UAM:ES specimens at TACC',
	'03:11 AM every day',
	'0',
	'11',
	'03',
	'*',
	'*',
	'?'
);


delete from cf_crontab where job_name='es_tacc_spec_media_alreadyentered';

insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'es_tacc_spec_media_alreadyentered',
	'es_tacc.cfm?action=spec_media_alreadyentered',
	'600',
	'ES imaging: Find images of UAM:ES specimens at TACC',
	'03:21 AM every day',
	'0',
	'21',
	'03',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'MBL_cleanup',
	'BulkloadMedia.cfm?action=cleanup',
	'600',
	'media bulkloader: Cleanup',
	'12:31 AM every day',
	'0',
	'31',
	'12',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'MBL_report',
	'BulkloadMedia.cfm?action=report',
	'600',
	'media bulkloader: Send email',
	'04:31 AM every day',
	'0',
	'31',
	'04',
	'*',
	'*',
	'?'
);

delete from cf_crontab where job_name='MBL_validate';
insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'MBL_validate',
	'BulkloadMedia.cfm?action=validate',
	'600',
	'media bulkloader: validate',
	'12:02 AM every day',
	'0',
	'02',
	'12',
	'*',
	'*',
	'?'
);

insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'MBL_load',
	'BulkloadMedia.cfm?action=load',
	'600',
	'media bulkloader: load',
	'12:06 AM every day',
	'0',
	'06',
	'12',
	'*',
	'*',
	'?'
);

delete from cf_crontab where job_name='upclass_checkMeta';
insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'upclass_checkMeta',
	'processBulkloadClassification.cfm?action=checkMeta',
	'600',
	'classification bulkloader: prepare for processing',
	'every hour at 5 after',
	'0',
	'05',
	'*',
	'*',
	'*',
	'?'
);



insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'upclass_getTID',
	'processBulkloadClassification.cfm?action=getTID',
	'600',
	'classification bulkloader: get Taxon IDs',
	'every hour at 17 after',
	'0',
	'17',
	'*',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'upclass_getClassificationID',
	'processBulkloadClassification.cfm?action=getClassificationID',
	'600',
	'classification bulkloader: get Taxon IDs',
	'every hour at 25 after',
	'0',
	'25',
	'*',
	'*',
	'*',
	'?'
);

insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'upclass_fitbfg',
	'processBulkloadClassification.cfm?action=fill_in_the_blanks_from_genus',
	'60',
	'classification bulkloader: fill in blanks when given genus',
	'every other hour at 3 after',
	'0',
	'03',
	'0/2',
	'*',
	'*',
	'?'
);



insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'CTupdates',
	'CTupdates.cfm',
	'600',
	'alerts: Email report of code table changes',
	'12:01 AM every day',
	'0',
	'01',
	'12',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'sitemap_map',
	'build_sitemap.cfm?action=build_map',
	'600',
	'sitemaps: build sitemaps',
	'Every week, Wednesday at 9:17 PM',
	'0',
	'17',
	'21',
	'?',
	'*',
	'WED'
);



insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'sitemapindex',
	'build_sitemap.cfm?action=build_index',
	'600',
	'sitemaps: build sitemaps index',
	'Every week, Wednesday at 9:37 PM',
	'0',
	'37',
	'21',
	'?',
	'*',
	'WED'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'sitemap_specimens',
	'build_sitemap.cfm?action=build_sitemaps_spec',
	'600',
	'sitemaps: specimens',
	'Every 30 minutes',
	'0',
	'57',
	'21',
	'?',
	'*',
	'WED'
);

delete from cf_crontab where job_name='sitemap_taxonomy';
insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'sitemap_taxonomy',
	'build_sitemap.cfm?action=build_sitemaps_tax',
	'600',
	'sitemaps: taxonomy',
	'Every 30 minutes',
	'0',
	'22,52',
	'*',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'sitemap_publication',
	'build_sitemap.cfm?action=build_sitemaps_pub',
	'600',
	'sitemaps: publication',
	'Every hour',
	'0',
	'26',
	'*',
	'*',
	'*',
	'?'
);

insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'sitemap_project',
	'build_sitemap.cfm?action=build_sitemaps_proj',
	'600',
	'sitemaps: project',
	'Every hour',
	'0',
	'31',
	'*',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'sitemap_static',
	'build_sitemap.cfm?action=build_sitemaps_stat',
	'600',
	'sitemaps: static',
	'Every hour',
	'0',
	'35',
	'*',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'sitemap_media',
	'build_sitemap.cfm?action=build_sitemaps_media',
	'600',
	'sitemaps: media',
	'Every hour',
	'0',
	'45',
	'*',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'ALA_ProblemReport',
	'alaImaging/ala_has_probs.cfm',
	'600',
	'ALA Imaging: send email about ALA imaging problems',
	'Every day',
	'0',
	'0',
	'6',
	'*',
	'*',
	'?'
);



insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'tacc1_findAllDirectories',
	'tacc.cfm?action=findAllDirectories',
	'600',
	'ALA Imaging: find image directories at TACC',
	'daily',
	'0',
	'30',
	'4',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'TACC2_findFilesOnePath',
	'tacc.cfm?action=findFilesOnePath',
	'600',
	'ALA Imaging: find images in directories at TACC',
	'daily',
	'0',
	'17',
	'0',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'TACC3_linkToSpecimens',
	'tacc.cfm?action=linkToSpecimens',
	'600',
	'ALA Imaging: link images to specimens',
	'every 20 minutes',
	'0',
	'07,27,47',
	'*',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'TACC4_makeDNGMedia',
	'tacc.cfm?action=makeDNGMedia',
	'600',
	'ALA Imaging: make media for DNGs',
	'every hour',
	'0',
	'37',
	'*',
	'*',
	'*',
	'?'
);


delete from cf_crontab where job_name='TACC5_makeJPGMedia';
insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'TACC5_makeJPGMedia',
	'tacc.cfm?action=makeJPGMedia',
	'600',
	'ALA Imaging: make media for JPGs',
	'every hour',
	'0',
	'46',
	'*',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'reminder',
	'reminder.cfm',
	'600',
	'Email Alert: loans due, permits expiring, etc.',
	'daily',
	'0',
	'56',
	'*',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'globalnames_refresh',
	'globalnames_refresh.cfm',
	'600',
	'GlobalNames: refresh oldest/un-cached data',
	'every 10 minutes',
	'0',
	'0,10,20,30,40,50',
	'*',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'authority_change',
	'authority_change.cfm?action=sendEmail',
	'600',
	'email alert: code tables or geography change notifications',
	'daily',
	'0',
	'59',
	'0',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'genbank_crawl_institution_wild2',
	'genbank_crawl.cfm?action=institution_wild2',
	'600',
	'GenBank: crawl for linkable data',
	'daily',
	'0',
	'25',
	'7',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'genbank_crawl_institution_wild1',
	'genbank_crawl.cfm?action=institution_wild1',
	'600',
	'GenBank: crawl for linkable data',
	'daily',
	'0',
	'20',
	'7',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'genbank_crawl_collection_wild2',
	'genbank_crawl.cfm?action=collection_wild2',
	'600',
	'GenBank: crawl for linkable data',
	'daily',
	'0',
	'15',
	'7',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'genbank_crawl_collection_wild1',
	'genbank_crawl.cfm?action=collection_wild1',
	'600',
	'GenBank: crawl for linkable data',
	'daily',
	'0',
	'10',
	'7',
	'*',
	'*',
	'?'
);




insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'genbank_crawl_collection_voucher',
	'genbank_crawl.cfm?action=collection_voucher',
	'600',
	'GenBank: crawl for linkable data',
	'daily',
	'0',
	'05',
	'7',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'genbank_crawl_institution_voucher',
	'genbank_crawl.cfm?action=institution_voucher',
	'600',
	'GenBank: crawl for linkable data',
	'daily',
	'0',
	'00',
	'7',
	'*',
	'*',
	'?'
);



insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'GenBank_build',
	'GenBank_build.cfm',
	'600',
	'GenBank: build data for linkouts',
	'daily',
	'0',
	'00',
	'22',
	'*',
	'*',
	'?'
);


delete from cf_crontab where job_name='GenBank_transfer_name';

insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'GenBank_transfer_name',
	'GenBank_transfer_name.cfm',
	'600',
	'GenBank: transfer names data',
	'daily',
	'0',
	'34',
	'22',
	'*',
	'*',
	'?'
);


delete from cf_crontab where job_name='GenBank_transfer_nuc';


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'GenBank_transfer_nuc',
	'GenBank_transfer_nuc.cfm',
	'600',
	'GenBank: transfer nucleotide data',
	'daily',
	'0',
	'36',
	'22',
	'*',
	'*',
	'?'
);

delete from cf_crontab where job_name='GenBank_transfer_tax';


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'GenBank_transfer_tax',
	'GenBank_transfer_tax.cfm',
	'600',
	'GenBank: transfer taxonomy data',
	'daily',
	'0',
	'38',
	'22',
	'*',
	'*',
	'?'
);

delete from cf_crontab where job_name='GenBank_transfer_bio';

insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'GenBank_transfer_bio',
	'GenBank_transfer_bio.cfm',
	'600',
	'GenBank: transfer biosample data',
	'daily',
	'0',
	'44',
	'22',
	'*',
	'*',
	'?'
);

delete from cf_crontab where job_name='cf_spec_res_cols';

insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'cf_spec_res_cols',
	'cf_spec_res_cols.cfm',
	'600',
	'maintenance: Sync specresults with code table additions',
	'weekly',
	'0',
	'38',
	'0',
	'?',
	'*',
	'THU'
);

insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'CleanTempFiles',
	'CleanTempFiles.cfm',
	'600',
	'maintenance: Clean up temporary fileserver gunk',
	'daily',
	'0',
	'0',
	'0',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'build_home',
	'build_home.cfm',
	'600',
	'maintenance: maintain home.cfm',
	'daily',
	'0',
	'56',
	'0',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'createRobots',
	'createRobots.cfm',
	'600',
	'maintenance: maintain robots.txt',
	'daily',
	'0',
	'36',
	'01',
	'*',
	'*',
	'?'
);


delete from cf_crontab where job_name='stale_users';
insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'stale_users',
	'stale_users.cfm',
	'600',
	'maintenance: lock old and unused user accounts',
	'weekly',
	'0',
	'56',
	'01',
	'?',
	'*',
	'TUE'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'intrusionreport',
	'intrusionreport.cfm',
	'600',
	'email alert: blacklisted IP entry attempts report',
	'weekly',
	'0',
	'42',
	'03',
	'?',
	'*',
	'MON'
);


--------------->
<!--- first, get rid of everything --->

<cfinclude template="/includes/_header.cfm">
<cfif action is "nothing">
	<cfset title="Arctos ColdFusion Scheduler Manager">
	<script>
		function getCM(id){
			$.ajax({
				url: "/component/utilities.cfc?queryformat=column",
				type: "GET",
				dataType: "json",
				async: false,
				data: {
					method:  "getChronMaker",
					exp : $("#cexp_" + id).val(),
					returnformat : "json"
				},
				success: function(r) {
					var arr = r.split(',');
			        for(var i = 0; i<arr.length; i++){
			        	$("#cm_" + id + "_" + parseInt(i+1)).html(arr[i]);
			        }



				},
				error: function (xhr, textStatus, errorThrown){
				    alert(errorThrown + ': ' + textStatus + ': ' + xhr);
				}
			});
		}
		function fetchAllCM(){
			$(".noshow").removeClass("noshow");
			$("input[id^='cexp_']").each(function(e){
				getCM(this.id.replace('cexp_',''));
			});
		}
	</script>
	<style>
		.noshow{display:none;}
	</style>

<!----
	<div style="white-space: nowrap;">#cron_sec# #cron_min# #cron_hour# #cron_dom# #cron_mon# #cron_dow#</div>
					<input type="hidden" name="cexp_#cf_crontab_id#" value="#cron_sec# #cron_min# #cron_hour# #cron_dom# #cron_mon# #cron_dow#">
				</td>
				<td><a href="scheduler.cfm?action=deleteTask&cf_crontab_id=#cf_crontab_id#">delete</a></td>
				<td><a href="scheduler.cfm?action=editTask&cf_crontab_id=#cf_crontab_id#">edit</a></td>
				<td><div id="cm_#cf_crontab_id#"><span class="likeLink" onclick="getCM(#cf_crontab_id#);">get next 10 r


				---->
<cfobject type="JAVA" action="Create" name="factory" class="coldfusion.server.ServiceFactory">
<cfset allTasks = factory.CronService.listAll()>
<cfset numberOtasks = arraylen(allTasks)>
<cfloop index="i" from="1" to="#numberOtasks#">
	<cfschedule action="delete" task="#allTasks[i].task#">
</cfloop>
<script src="/includes/sorttable.js"></script>
<cfparam name="orderby" default="cron_hour,cron_min,cron_dow">
<cfoutput>
	<form name="o" method="get">
		<label for="orderby">OrderBy (job_name,path,timeout,purpose,run_interval_desc,cron_sec,cron_min,cron_hour,cron_dom,cron_mon,cron_dow)
		</label>
		<textarea name="orderby" class="hugetextarea reqdClr">#orderby#</textarea>
		<input type="submit" value="reorder">
	</form>
	<cfquery name="sched" datasource="uam_god">
		select * from cf_crontab order by #orderby#
	</cfquery>
	<p>
		See <a href="http://www.cronmaker.com/" class="external" target="_blank">http://www.cronmaker.com/</a> for toys.
	</p>
	<p>
		See <a href="/ScheduledTasks/index.cfm">/ScheduledTasks/</a> folder
	</p>
	<p>
		Fetch next 10 runtimes -
		<span class="likeLink" onclick="fetchAllCM()">clicky</span> and wait for the fetch to complete before sorting.
	</p>
	Current Scheduled Tasks:
	<table class="sortable" id="tblls" border>
		<tr>
			<th>job_name</th>
			<th>/ScheduledTasks/</th>
			<th>timeout</th>
			<th>purpose</th>
			<th>run_interval_desc</th>
			<th>s</th>
			<th>m</th>
			<th>h</th>
			<th>DoM</th>
			<th>M</th>
			<th>DoW</th>
			<th>crontime</th>
			<th>bye</th>
			<th>edit</th>
			<th class="noshow">next1</th>
			<th class="noshow">next2</th>
			<th class="noshow">next3</th>
			<th class="noshow">next4</th>
			<th class="noshow">next5</th>
			<th class="noshow">next6</th>
			<th class="noshow">next7</th>
			<th class="noshow">next8</th>
			<th class="noshow">next9</th>
			<th class="noshow">next10</th>
		</tr>
		<cfloop query="sched">
			<tr>
				<td>#job_name#</td>
				<td>
					<a href="/ScheduledTasks/#path#">#path#</a>
				</td>
				<td>#timeout#</td>
				<td>#purpose#</td>
				<td>#run_interval_desc#</td>
				<td>#cron_sec#</td>
				<td>#cron_min#</td>
				<td>#cron_hour#</td>
				<td>#cron_dom#</td>
				<td>#cron_mon#</td>
				<td>#cron_dow#</td>
				<td>
					<div style="white-space: nowrap;">#cron_sec# #cron_min# #cron_hour# #cron_dom# #cron_mon# #cron_dow#</div>
					<input type="hidden" id="cexp_#cf_crontab_id#" name="cexp_#cf_crontab_id#" value="#cron_sec# #cron_min# #cron_hour# #cron_dom# #cron_mon# #cron_dow#">
				</td>
				<td><a href="scheduler.cfm?action=deleteTask&cf_crontab_id=#cf_crontab_id#">delete</a></td>
				<td><a href="scheduler.cfm?action=editTask&cf_crontab_id=#cf_crontab_id#">edit</a></td>
				<td class="noshow"><div id="cm_#cf_crontab_id#_1"></div></td>
				<td class="noshow"><div id="cm_#cf_crontab_id#_2"></div></td>
				<td class="noshow"><div id="cm_#cf_crontab_id#_3"></div></td>
				<td class="noshow"><div id="cm_#cf_crontab_id#_4"></div></td>
				<td class="noshow"><div id="cm_#cf_crontab_id#_5"></div></td>
				<td class="noshow"><div id="cm_#cf_crontab_id#_6"></div></td>
				<td class="noshow"><div id="cm_#cf_crontab_id#_7"></div></td>
				<td class="noshow"><div id="cm_#cf_crontab_id#_8"></div></td>
				<td class="noshow"><div id="cm_#cf_crontab_id#_9"></div></td>
				<td class="noshow"><div id="cm_#cf_crontab_id#_10"></div></td>
			</tr>
			<!--- and actually build the tasks ---->
			<cfschedule action = "update"
			    task = "#job_name#"
			    operation = "HTTPRequest"
			    url = "127.0.0.1/ScheduledTasks/#path#"
			    cronTime="#cron_sec# #cron_min# #cron_hour# #cron_dom# #cron_mon# #cron_dow#"
			    requestTimeOut = "#timeout#">
		</cfloop>
	</table>
	</cfoutput>
	Add a task
	<form method="post" action="scheduler.cfm">
		<input type="hidden" name="action" value="addTask">
		<label for="job_name">job_name</label>
		<input type="text" name="job_name" class="reqdClr">

		<label for="path">path (/ScheduledTasks/....)</label>
		<input type="text" name="path" class="reqdClr">

		<label for="timeout">timeout</label>
		<input type="text" name="timeout" class="reqdClr" value="60">

		<label for="purpose">purpose</label>
		<textarea name="purpose" class="hugetextarea reqdClr"></textarea>

		<label for="run_interval_desc">run_interval_desc</label>
		<input type="text" name="run_interval_desc" class="reqdClr">
		<br>Crontime (Quartz):
		<table border>
			<tr>
				<td>s</td>
				<td>m</td>
				<td>h</td>
				<td>DoM</td>
				<td>M</td>
				<td>DoW</td>
			</tr>
			<tr>
				<td><input type="text" name="cron_sec" class="reqdClr" value="0"></td>
				<td><input type="text" name="cron_min" class="reqdClr"></td>
				<td><input type="text" name="cron_hour" class="reqdClr"></td>
				<td><input type="text" name="cron_dom" class="reqdClr"></td>
				<td><input type="text" name="cron_mon" class="reqdClr"></td>
				<td><input type="text" name="cron_dow" class="reqdClr"></td>
			</tr>
		</table>
		<br><input type="submit" value="add task">
	</form>
</cfif>

<cfif action is "editTask">
	<cfquery name="editTask" datasource="uam_god">
		select * from cf_crontab where cf_crontab_id=#cf_crontab_id#
	</cfquery>
	<cfoutput>
	<form method="post" action="scheduler.cfm">
		<input type="hidden" name="action" value="saveEditTask">
		<input type="hidden" name="cf_crontab_id" value="#cf_crontab_id#">
		<label for="job_name">job_name</label>
		<input type="text" name="job_name" class="reqdClr" value="#editTask.job_name#">

		<label for="path">path (/ScheduledTasks/....)</label>
		<input type="text" name="path" class="reqdClr" value="#editTask.path#">

		<label for="timeout">timeout</label>
		<input type="text" name="timeout" class="reqdClr"  value="#editTask.timeout#">

		<label for="purpose">purpose</label>
		<textarea name="purpose" class="hugetextarea reqdClr">#editTask.purpose#</textarea>

		<label for="run_interval_desc">run_interval_desc</label>
		<input type="text" name="run_interval_desc" class="reqdClr" value="#editTask.run_interval_desc#">
		<br>Crontime (Quartz):
		<table border>
			<tr>
				<td>s</td>
				<td>m</td>
				<td>h</td>
				<td>DoM</td>
				<td>M</td>
				<td>DoW</td>
			</tr>
			<tr>
				<td><input type="text" name="cron_sec" class="reqdClr" value="#editTask.cron_sec#"></td>
				<td><input type="text" name="cron_min" class="reqdClr" value="#editTask.cron_min#"></td>
				<td><input type="text" name="cron_hour" class="reqdClr" value="#editTask.cron_hour#"></td>
				<td><input type="text" name="cron_dom" class="reqdClr" value="#editTask.cron_dom#"></td>
				<td><input type="text" name="cron_mon" class="reqdClr" value="#editTask.cron_mon#"></td>
				<td><input type="text" name="cron_dow" class="reqdClr" value="#editTask.cron_dow#"></td>
			</tr>
		</table>
		<br><input type="submit" value="save edits">
	</form>
	</cfoutput>
</cfif>
<cfif action is "saveEditTask">
	<cfquery name="saveEditTask" datasource="uam_god">
		update cf_crontab set
			job_name='#job_name#',
			path='#path#',
			timeout='#timeout#',
			purpose='#purpose#',
			run_interval_desc='#run_interval_desc#',
			cron_sec='#cron_sec#',
			cron_min='#cron_min#',
			cron_hour='#cron_hour#',
			cron_dom='#cron_dom#',
			cron_mon='#cron_mon#',
			cron_dow='#cron_dow#'
		where cf_crontab_id=#cf_crontab_id#
	</cfquery>
	<cflocation url="scheduler.cfm" addtoken="false">
</cfif>
<cfif action is "deleteTask">
	<cfquery name="deleteTask" datasource="uam_god">
		delete from cf_crontab where cf_crontab_id=#cf_crontab_id#
	</cfquery>
	<cflocation url="scheduler.cfm" addtoken="false">
</cfif>
<cfif action is "addTask">
	<cfquery name="addTask" datasource="uam_god">
		insert into cf_crontab (
			job_name,
			path,
			timeout,
			purpose,
			run_interval_desc,
			cron_sec,
			cron_min,
			cron_hour,
			cron_dom,
			cron_mon,
			cron_dow
		) values (
			'#job_name#',
			'#path#',
			'#timeout#',
			'#purpose#',
			'#run_interval_desc#',
			'#cron_sec#',
			'#cron_min#',
			'#cron_hour#',
			'#cron_dom#',
			'#cron_mon#',
			'#cron_dow#'
		)
	</cfquery>
	<cflocation url="scheduler.cfm" addtoken="false">
</cfif>
<cfinclude template="/includes/_footer.cfm">

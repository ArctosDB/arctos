drop table temp_media;

create table temp_media as select * from media where media_uri like 'http://goodnight.corral.tacc.utexas.edu/%.dng';

alter table temp_media add checksum varchar2(4000);
alter table temp_media add filename varchar2(255);

update temp_media set checksum=(
	select label_value from media_labels where
	media_label='MD5 checksum' and
	temp_media.media_id=media_labels.media_id);
	
	
<cfoutput>
	
</cfoutput>
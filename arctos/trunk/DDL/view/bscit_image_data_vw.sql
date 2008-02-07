create or replace view bscit_image_data_vw as
    select
        ci.collection_object_id,
        c.institution_acronym,
        ci.collection_cde,
        ci.cat_num,
        concatColl(ci.collection_object_id) collector,
        g.country,
        g.state_prov,
        g.county,
        l.spec_locality,
        g.island,
        g.island_group,
        ce.began_date,
        ce.ended_date,
        ce.verbatim_date,
        bis.subject,
        a.attribute_value description,
        decode(i.scientific_name,
            'unidentifiable', null,
            i.scientific_name) scientific_name,
        biu.made_date,
        biu.jpeg_full_url,
        biu.tilepic_full_url,
        biu.thumbnail_url
    from
        collection c,
        cataloged_item ci,
        geog_auth_rec g,
        locality l,
        collecting_event ce,
        bscit_image_subject bis,
        attributes a,
        identification i,
        bscit_image_url biu
    where
        ci.collection_id = c.collection_id
        and ci.collecting_event_id = ce.collecting_event_id
        and ce.locality_id = l.locality_id
        and l.geog_auth_rec_id = g.geog_auth_rec_id
        and ci.collection_object_id = i.collection_object_id
        and ci.collection_id = 7
        and ci.collection_object_id = a.collection_object_id
        and a.attribute_type = 'title'
        and ci.collection_object_id = bis.collection_object_id
        and bis.collection_object_id = biu.collection_object_id (+);

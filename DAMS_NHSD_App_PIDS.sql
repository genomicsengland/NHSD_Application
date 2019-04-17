/*SQL to pull name, address, email address and gcm death record for all participants in DAMS*/
with all_rows as (
	select p.participant_id
		,p.forenames
		,p.surname
		,p.date_of_birth
		,p.person_identifier
		,r.pcd_address_line1
		,r.pcd_address_line2
		,r.pcd_address_line3
		,r.pcd_address_line4
		,r.pcd_address_line5
		,r.pcd_postcode
		,r.person_phenotypic_sex_id as sex
		,m.metadata_source_organisation as ods
		/*get duplicated registration record so only take most recently submitted record from GMC*/
		,row_number() over (partition by p.participant_id order by m.metadata_date desc) as record_num
		,'RD' as programme
	from 
		rarediseases.participant_identifier p 
	left join 
		rarediseases.rare_diseases_registration r  
			on	p.participant_id=r.participant_identifiers_id
	left join 
		rarediseases.rare_diseases_subject s 
			on  r.subject_id=s.id 
	left join 
		rarediseases.rare_diseases_message m  
			on	s.message_id=m.id
		 
	union
	
	select 
		p.participant_id
		,p.forenames
		,p.surname
		,p.date_of_birth
		,p.person_identifier
		,r.pcd_address_line1
		,r.pcd_address_line2
		,r.pcd_address_line3
		,r.pcd_address_line4
		,r.pcd_address_line5
		,r.pcd_postcode
		,r.person_phenotypic_sex_id as sex
		,m.metadata_source_organisation as ods
		,row_number() over (partition by p.participant_id order by m.metadata_datetime desc) as record_num
		,'CA' as programme
	from 
		gelcancer.participant_identifier p 
	left join 
		gelcancer.cancer_registration r 
			on p.participant_id=r.participant_identifiers_id
	left join 
		gelcancer.cancer_subject s 
			on r.subject_id=s.id 
	left join 
		gelcancer.cancer_message m 
			on s.message_id=m.id
)


select 
     participant_id
	,forenames
	,surname
	,date_of_birth
	,person_identifier as nhs_number
	,pcd_address_line1
	,pcd_address_line2
	,pcd_address_line3
	,pcd_address_line4
	,pcd_address_line5
	,pcd_postcode
	,sex
	,programme
	,ods
	
--	,case
--		when participant_id in (
--			select participant_identifiers_id from rarediseases.rare_diseases_death where participant_identifiers_id is not null
--			union
--			select participant_identifiers_id from gelcancer.cancer_death where participant_identifiers_id is not null
--			) then true 
--		else false 
--	end as death_record_submitted_by_gmc
--	,case
--		when participant_id in (
--			select participant_identifiers_id from rarediseases.rare_diseases_withdrawal where participant_identifiers_id is not null
--			union
--			select participant_identifiers_id from gelcancer.cancer_withdrawal where participant_identifiers_id and is not null
--			) then true 
--		else false 
--	end as full_or_partially_withdrawn
from all_rows
	
where record_num = 1
;

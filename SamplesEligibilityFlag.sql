/*SQL to flag participants with eligibility status according to Samples not sent criteria Apr'19 */

with all_rows as (
	select p.participant_id
		,sns.participant_sk is null as pass_cancer_sns /*participant has not had ca sample not sent submitted*/
		,pmr.participant_sk is null as pass_rd_mr /*participant has not failed participant med review*/
		,lower(p.withdrawal_option) not in ('full withdrawal') or p.withdrawal_option is null as pass_withdrawal /*participant has not fully withdrawn*/
	from 
		cdm.vw_participant_level_data p
	left join (select * from cdm.cancer_participant_reason_sample_not_sent where participant_sk is not null) sns 
		on p.participant_sk = sns.participant_sk
	left join (
		/* get list of participant_sks that fail MR (state = 1, failed), the understanding at the moment is that this is rd equivalent of ca sample not sent*/
		select 
			distinct participant_sk
			from 
				cdm.rare_diseases_participant_medical_review
			where medical_review_qc_state_sk in (1) and
			participant_sk is not null
			) pmr
		on p.participant_sk = pmr.participant_sk
)

select participant_id
	,pass_cancer_sns = true and pass_rd_mr = true and pass_withdrawal = true as eligible
from all_rows
;


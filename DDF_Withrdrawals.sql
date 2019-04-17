/*SQL to pull withdrawals from DDF */
	
select 
	participant_identifiers_id, withdrawal_form, withdrawal_option_id 
from 
	rarediseases.rare_diseases_withdrawal 

union
	
select 
	participant_identifiers_id, withdrawal_form, withdrawal_option_id
from 
	gelcancer.cancer_withdrawal
	
	

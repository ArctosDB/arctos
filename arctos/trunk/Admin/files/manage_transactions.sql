create role manage_transactions;
grant insert,update,delete on ACCN to manage_transactions;
grant insert,update,delete on LOAN to manage_transactions;
grant insert,update,delete on BORROW to manage_transactions;
grant insert,update,delete on LOAN_ITEM to manage_transactions;
grant insert,update,delete on TRANS to manage_transactions;
grant insert,update,delete on permit_trans to manage_transactions;
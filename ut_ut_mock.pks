create or replace package UT_UT_MOCK as
   procedure UT_SETUP;
   procedure UT_TEARDOWN;
   --procedure ut_use_mock_acceptance;
   procedure ut_get_source;
   procedure ut_recompile;
end;
/
show err
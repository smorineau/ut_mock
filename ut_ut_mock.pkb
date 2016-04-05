create or replace package body ut_ut_mock as

   procedure ut_setup
   is
   begin
      null;
   end;

   procedure ut_teardown
   is
   begin
      null;
   end;

   procedure ut_use_mock_acceptance
   is
   begin
      ut_mock.use_mock('ut_ut_mock:mock_action');
      utassert.eq('action.perform should be mocked', action.perform, true);
      ut_mock.reset_mock;
      utassert.eq('action.perform should be reset', action.perform, false);
   end;

   -- @mock mock_action :: action:perform_mockable
   function mock_action return boolean
   is
   begin
     return true;
   end;
   -- @endmock

   procedure ut_get_source
   is
   begin
      utassert.eq('action should be reset', 
         instr(
            ut_mock.get_source_of('action'),
            '@mockable perform_mockable'), 
         72);
   end;
end;
/
show err
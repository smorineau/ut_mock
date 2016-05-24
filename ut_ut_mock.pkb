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
      ut_mock.use_mock('ut_ut_mock', 'mock_action');
      utassert.eq('action.perform should be mocked', action.perform, true);
      ut_mock.reset_mock;
      utassert.eq('action.perform should be reset', action.perform, false);
   end;

   -- @mock mock_action :: action:perform
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
            '@mockable perform'),
         72);
   end;

   procedure ut_recompile
   is
      source clob;
   begin
      source := ut_mock.get_source_of('action');
      ut_mock.recompile(replace(source, 'false', 'true'));
      execute immediate 'begin utassert.eq(''action.perform should return true'', action.perform, true); end;';
      ut_mock.recompile(source);
      execute immediate 'begin utassert.eq(''action.perform should be restored to false'', action.perform, false); end;';
   end;

   procedure ut_find_mock
   is
   begin
      utassert.eq('mock_code should be extracted',
                  ut_mock.find_mock('
bla bla
-- @mock [another_mock_action] :: action.perform
mock_action
-- @endmock
bla bla
-- @mock [mock_action] :: action.perform
mock code for mock_action.
-- @endmock
bla bla',
                     'mock_action').mock_code,
                  'mock code for perform.');

      utassert.eq('target_package should be extracted',
                  ut_mock.find_mock('
bla bla
-- @mock [mock_action_another] :: action.perform
mock_action
-- @endmock
bla bla
-- @mock [mock_action] :: action.perform
mock code for mock_action.
-- @endmock
bla bla',
                     'mock_action').mockable_package,
                  'action');

      utassert.eq('target_entity should be extracted',
                  ut_mock.find_mock('
bla bla
-- @mock [another_mock_action] :: action.perform
mock_action
-- @endmock
bla bla
-- @mock [mock_action] :: action.perform
mock code for mock_action.
-- @endmock
bla bla',
                     'mock_action').mockable_name,
                  'perform');
   end;

   procedure ut_replace_mockable
   is
   begin
      utassert.eq('mockable_code should be extracted',
                  ut_mock.replace_mockable('
create or replace package body action as

   -- @mockable [perform_another]
   function perform return boolean
   is
   begin
     return true;
   end;
   -- @endmockable
   -- @mockable [perform]
   function perform return boolean
   is
   begin
     return false;
   end;
   -- @endmockable

end;',
                  'perform',
                  'toto')
         , '
create or replace package body action as

   -- @mockable [perform_another]
   function perform return boolean
   is
   begin
     return true;
   end;
   -- @endmockable
   toto

end;');
   end;

end;
/
show err
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

   function perform_caller_proxy return boolean
   is
      v_return      boolean;
   begin
      execute immediate 'begin :this := action.perform; end;' using in out v_return;
     return v_return;
   end;

   procedure ut_use_mock_acceptance
   is
   begin
      ut_mock.use_mock('ut_ut_mock', 'mock_action');
      utassert.eq('action.perform should be mocked', perform_caller_proxy, true);
      ut_mock.reset_mock;
      utassert.eq('action.perform should be reset', perform_caller_proxy, false);
   end;

   -- @mock [mock_action] :: action.perform
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
            '@mockable [perform]'),
         72);
   end;

   procedure ut_recompile
   is
      source clob;
      action_value      boolean := null;
   begin
      source := ut_mock.get_source_of('action');
      ut_mock.recompile(replace(source, 'false', 'true'));
      utassert.eq('action.perform should return true', perform_caller_proxy, true);

      ut_mock.recompile(source);
      utassert.eq('action.perform should be restored to false', perform_caller_proxy, false);
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
-- @mock [wanted_mock_action] :: action.perform
wanted_mock_action
-- @endmock
-- @mock [yet_another_mock_action] :: action.perform
yet_another_mock_action
-- @endmock

bla bla',
                     'wanted_mock_action').mock_code,
                  'perform');

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

   procedure ut_backup_package_source
   is
   begin
      utassert.eqqueryvalue('package TOTO is not backed up',
         'select count(*) from ut_mockable_packages where package_name = ''TOTO''',
         0);
      ut_mock.backup_package_source('TOTO','toto source');
      utassert.eqqueryvalue('package TOTO is backed up',
         'select count(*) from ut_mockable_packages where package_name = ''TOTO''',
         1);
      ut_mock.backup_package_source('TITI','titi source');
      utassert.eqqueryvalue('package TITI is backed up',
         'select count(*) from ut_mockable_packages',
         2);
      ut_mock.backup_package_source('TOTO','toto source 2');
      utassert.eqqueryvalue('package TOTO is not backed up again',
         'select count(*) from ut_mockable_packages',
         2);
      execute immediate 'truncate table ut_mockable_packages';
   end;

end;
/
show err
set serveroutput on
set lines 80

@ut_mockable_packages.sql

@ut_mock.pks
@ut_mock.pkb

@action.pks
@action.pkb

@ut_ut_mock.pks
@ut_ut_mock.pkb

--exec utresult.ignore_successes;
exec utplsql.test('ut_mock', recompile_in => FALSE);

exit
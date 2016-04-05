test: ut_mock.pks ut_mock.pkb ut_ut_mock.pks ut_ut_mock.pkb action.pks action.pkb
	sqlplus ${DB_CONNECT_STRING} @build.sql

drop table ut_mockable_packages;

create table ut_mockable_packages(
package_name            varchar2(30) primary key,
package_source          clob
);
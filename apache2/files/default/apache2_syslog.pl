#!/usr/bin/perl
use Sys::Syslog qw( :DEFAULT setlogsock );

setlogsock('unix');
openlog('apache', 'cons', 'pid', 'local3');

while ($log = <STDIN>) {
    syslog('local3.info', $log);
}
closelog

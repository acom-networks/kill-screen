#!/usr/bin/perl

#################################################################################
## Name:         kill_screen.pl
## Function:     Automatically kill screen session
## Description:
##	The script can monitor screen ssession to check whether to use.
##   If over to specific time, the script can kill this session.
## Version 1.0.0 : 2022-12-27 Aiden Tang (aiden@acom-networks.com)
##               - init.
##################################################################################


use Date::Manip;
use File::Find;
use Date::Format;
use Time::HiRes qw( usleep ualarm gettimeofday tv_interval nanosleep clock_gettime clock_getres clock_nanosleep clock stat );

our $log_dir      = "/home/logs/kill_screen";
our $program_name = "kill_screen";

my $version = "1.0.0";
my $hostname = `/bin/ls -l /var/run/screen/ |/bin/grep -v total | /bin/awk '{print \$9}'`;
my @username = split("\n",$hostname);
&logger("START: Excute this program (/home/acomusr4/kill_screen.pl)\n");
if (!$hostname){
           &logger("INFO: No user executes screen session\n");
           &logger("END: Stop this program\n");
        }

foreach my$user(@username){
	my $cmd = `/bin/ls -l /var/run/screen\\/$user\\/ |/bin/grep -v total | /bin/awk '{print \$4,\$6,\$7,\$8,\$9}'`;
	my @msg = split("\n",$cmd);
        if (!$cmd){
           &logger("INFO: No user executes screen session\n");
        }

	foreach my$i(@msg){
		my @line = split(" ",$i);
        my $date = UnixDate("$line[1] $line[2] $line[3]","%s");
        my @msg1 = split(/\./,$line[4]);
        my $screen_num = $msg1[0];
		my $local_time = localtime(time);
        my $local_time_sec = UnixDate("$local_time","%s");
		my $date_12h = $local_time_sec - $date;
		if ($date_12h > 43200){
			my $screen_kill = `/bin/rm -rf /var/run/screen\\/S-$line[0]\\/ $line[4]`;
			&logger("INFO: The [$line[0]]screen session ($screen_num) was exceeded 12 hours already!\n");
			&logger("INFO: Kill this [$line[0]]screen session ($screen_num)\n");
            
		}else{
			&logger("INFO: No session can be killed!\n");
            &logger("END: Stop this program\n");
            exit 0 
		}

	}
    &logger("END: Stop this program\n");
}





sub logger {

    my @log_array = @_;
    my $log_line = $log_array[0];

    # if ( (!($debug)) && ($log_line =~ /^DEBUG/i)) {
    #     return;
    # }

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $year += 1900; $mon++; $mon = sprintf("%02d", $mon); $mday = sprintf("%02d", $mday);
    $sec = sprintf("%02d", $sec); $min = sprintf("%02d", $min); $hour = sprintf("%02d", $hour);
    my ($seconds, $usec) = gettimeofday();
    $usec = sprintf("%06d", $usec);
    my $timestring;
    my $datestring = $year . '-' . $mon . '-' . $mday;
    $timestring = $datestring . ' ' . $hour . ':' . $min . ':' . $sec  . '.' . $usec;

    print "[$timestring] $log_line";

    #return;

    if ($log_dir =~ /\/$/) {
        # Do nothing
    } else {
        $log_dir = $log_dir . '/';
    }

    my $logfile = $log_dir . $program_name . '-' . $datestring . '.log';

    open(LOGFILE,">> $logfile");
    print LOGFILE "[$timestring] $log_line";
    close(LOGFILE);
    return;

}

#!/usr/bin/perl
use strict;
use warnings;
use Time::Local;
use feature ':5.10';
use Getopt::Long;
use Pod::Usage;
use Net::Ping;
use POSIX qw(setsid);
#use SafeCommand;


my $host="";
my $timeout=5;
my $interval=60;
my $retries=3;
my $upscript="";
my $downscript="";
my $logfile="";


my $upscript_hash="";
my $downscript_hash="";

my $lfhd;

my $man  = 0;
my $help = 0;
my $daemon = 0;
my $verbose = 0;


GetOptions ("host|h=s" => \$host,    # string
            "timeout|t=i"   => \$timeout,  # numeric
            "interval|i=i"  => \$interval, # numeric
            "retries|r=i" 	=> \$retries,	 #numeric
            "up-script|u=s" => \$upscript,
            "down-script|d=s" => \$downscript,
            "verbose|v:s"			=> \$verbose,
            "daemon|b"			=> \$daemon,
            "logfile|l=s"   => \$logfile,
            "man|m" 				=> \$man,
            "help|?"				=> \$help)
  or pod2usage(2);
  
pod2usage(1) if $help;
pod2usage(1) if $host =~ /^$/;
pod2usage(1) if $upscript =~ /^$/;
pod2usage(1) if $downscript =~ /^$/;
pod2usage(1) if ($verbose and $daemon);
pod2usage(-exitval => 0, -verbose => 2) if $man;

my $cmdline = \$0;

sub daemonize {
#deamonize
chdir '/';
umask 0;
open (STDIN,'/dev/null') or die ('Nao foi possivel abrir /dev/null $!');
open (STDERR,'>/dev/null') or die ('Nao foi possivel abrir /dev/null $!');
open (STDOUT,'>/dev/null') or die ('Nao foi possivel abrir /dev/null $!');

defined(my $pid = fork) or die ('Cannot fork');
exit if $pid;
setsid or die ('Nao foi possivel iniciar nova sessao');

}

sub sanitize{
	

}

sub checkhost ( $ $ $ ) {
	my ($host, $timeout, $retries) = @_;
	my $fail=0;
	my $p = Net::Ping->new("icmp");
	debug ("Check $host");
	for (my $i=0 ; $i < $retries ; $i++){
		my ($ret, $duration, $ip) = $p->ping($host, $timeout);
		debug ("Check Return\n\tRet: ${ret}, Duration: ${duration}, IP: ${ip}",2);
		$fail++ unless ($ret) ;
	};
	say ("Fail $fail times");
	return ($fail != $retries);
}

sub debug{
	my $msg = shift;
	my $level = shift || 1;
	if (defined $lfhd){		
		unless ($verbose < 2 and $level >1) {
			say $lfhd, $msg;
		}
	}
	if ($verbose ge $level) {
		say $msg;
	}
}

sub runup{
	debug ("running $upscript ", 1);
	if (system ($upscript)) {
		return "Online";
	}else {
		debug("Up Fail: $upscript");
		return "Up Fail: $upscript";
	}
}
sub rundown{
	debug ("running $downscript ", 1);
	if (system ($downscript)) {
		return "Down";
	}else {
		debug ("Down Fail: $downscript");
		return "Fail: $downscript";
	}
}

sub procname( $ $ ){
	my ($h, $s) = @_;
	$$cmdline	= "CheckHost: Host $h is $s ";
}
##############START HHRER
my $state = "Undefined";

if ($daemon){
	daemonize;
}
#Set CMD Name
procname ($host, $state);


if ($logfile) {
	open $lfhd, ">" . $logfile;
}
while (1) {
 	if (checkhost ($host, $timeout, $retries)){
		if ($state ne "Online"){
			my $ret = runup();
			procname ($host, $ret);
		};
	}else{
		if($state ne "Down"){
			my $ret = rundown();
			procname ($host, $ret);
		};
	};
	sleep $interval;

};

__END__

=head1 NAME

netwatch - Monitor remote host and takes an action

=head1 SYNOPSIS

netwatch [options]

 Options:
	-host|h host        Hostname to monitor (required)
	-timeout|t seconds  Monitor timeout 
	-interval|i seconds Check interval
	-retries|r retries  Check retries
	-up-script|u cmd    Host up command (required)
	-down-script|d cmd  Host down command (required)
	-verbose|v          Print State and operations on console
	-daemon|b           Background process, could not be used with verbose
	-help               Brief help message
	-man                Full documentation

=head1 OPTIONS

=over 8

=item B<-host>

Hostname to monitor

=item B<-timeout>

Seconds before consider a test fail

=item B<-interval>

Seconds between checks

=item B<-retries>

Number of checks before consider host down

=item B<-up-script>

Script to run when host is up

=item B<-down-script>

Script to run hen host is down

=item B<-verbose>

Print state and operations on console

=item B<-daemon>

Send process to background. Could not be used with verbose

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=back

=head1 DESCRIPTION

B<This program> will check a host by icmp and run a script when declares the host down

=cut


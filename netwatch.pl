#!/usr/bin/perl
use strict;
use warnings;
use Time::Local;
use feature ':5.10';
use Getopt::Long;
use Pod::Usage;
use Net::Ping;


my $host="";
my $timeout=5;
my $interval=60;
my $retries=3;
my $upscript="";
my $downscript="";

my $man  = 0;
my $help = 0;
my $daemonize = 0;
my $verbose = 0;


GetOptions ("host|h=s" => \$host,    # string
            "timeout|t=i"   => \$timeout,      # numeric
            "interval|i=i"  => \$interval,   # numeric
            "retries|r=i" 	=> \$retries,	#numeric
            "up-script|u=s" => \$upscript,
            "down-script|d" => \$downscript,
            "verbose|v"			=> \$verbose,
            "daemon|b"			=> \$daemonize,
            "man|m" 				=> \$man,
            "help|?"				=> \$help)
  or pod2usage(2);
  
pod2usage(1) if $help;
pod2usage(1) if $host =~ /^$/;
pod2usage(1) if $upscript =~ /^$/;
pod2usage(1) if $downscript =~ /^$/;
pod2usage(1) if ($verbose and $daemonize);
pod2usage(-exitval => 0, -verbose => 2) if $man;

my $cmdline = \$0;

sub daemonize {
	say "daemon";
}


sub check ( $ $ $ ) {
	my ($host, $timeout, $retries) = @_;
	my $fail=0;
	my $p = Net::Ping->new("icmp");
	for (my $i=0 ; $i < $retries ; $i++){
		#my ($ret, $duration, $ip) = $p->ping($host, $timeout);
		$fail++ unless ($p->ping($host, $timeout)) ;
	};
	return ($fail != $retries);
}
sub runup{
	print $upscript;
	if (system ($upscript)) {
		return "Online";
	}else {
		return "Erro em $upscript";
	}
}
sub rundown{
	if (system ($downscript)) {
		return "Down";
	}else {
		return "Erro em $downscript";
	}
}

sub procname( $ $ ){
	my ($h, $s) = @_;
	$$cmdline	= "CheckHost: Host $h is $s ";
}

my $state = "Undefined";
procname ($host, $state);

while (1) {
 	if (check ($host, $timeout, $retries)){
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
	-host|h host        Hostname to monitor
	-timeout|t seconds  Monitor timeout
	-interval|i seconds Check interval
	-retries|r retries  Check retries
	-up-script|u cmd    Command to be executed when host is up
	-down-script|d cmd  Command to be executed when host is down
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


#!/usr/bin/perl
########################################################################
# 
# File   :  SafeCommand.pm
# History:  22 (fams) Initial Version, implements safe script execution
#
########################################################################
#
# Este módulo implementa uma série de checagens para executar um script
# 
########################################################################
package SafeCommand;
 use strict;
 use warnings;
 use feature ':5.10';
 our $VERSION = 1.001;

 use Digest::SHA1 qw(sha1 sha1_hex sha1_base64);


 sub new{
 	my $class = shift;
 	my $self = {
 		'_cmd-type' => "",
 		'_cmd-hash' => "",
 		'_cmd-string' => "",
 		'_cmd-out'	=>"",
		};
	my $cmd = shift;
	bless $self, $class ;
  init($self,$cmd);
  return $self;
 }
 
sub init{
	my $self = shift;
	my $cmd = shift;

	#Testa o tipo de commando
	if ( -e $cmd ) {
		$self->{_cmd-type} = "script";
		open my $scfh, '<' , $cmd or die "Não foi possivel abrir $cmd\n";		
		my $sha1 = Digest::SHA1->new;
		$sha1->addfile($scfh);
		$self->{_cmd-hash} = $sha1->digest;

	}else{
		$self->{_cmd-type} = "direct";
	};
	$self->{_cmd-string} = $cmd;
}

sub issafe{
	my $self = shift;
	if ($self->{_cmd-type} == "script"){
		if ( ! -e $cmd ) {
			return false;
		}
		my $cmd =  $self->{cmd-string};
		open my $scfh, '<' $cmd ,or die "Não foi possivel abrir $l2idf\n";		
		my $sha1 = Digest::SHA1->new;
		$sha1->addfile($scfh);
		return ($self->{cmd-hash} eq $sha1->digest);
	}
}
sub run{
	my $self = shift;
	my $param = shift;
	return 0 unless issafe;
	my $tmp;
	open( CMD, "-|", $self->{cmd-script}." 2>&1 ", $param ) or return 0;
  chomp($tmp = <CMD>);
  close CMD;
  chomp($tmp);
  $self->{cmd-out} = $tmp;
}

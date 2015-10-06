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
 		'_cmd_type' => "",
 		'_cmd_hash' => "",
 		'_cmd_string' => "",
 		'_cmd_out'	=>"",
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
		$self->{_cmd_type} = "script";
		open my $scfh, '<' , $cmd or die "Não foi possivel abrir $cmd\n";		
		my $sha1 = Digest::SHA1->new;
		$sha1->addfile($scfh);
		$self->{_cmd_hash} = $sha1->digest;

	}else{
		$self->{_cmd_type} = "direct";
	};
	$self->{_cmd_string} = $cmd;
}

sub issafe{
	my $self = shift;
	my $cmd =  $self->{_cmd_string};
	if ($self->{_cmd_type} eq "script"){
		unless ( -e $cmd ) {
			return 0;
		}
		open my $scfh, '<', $cmd ,or die "Não foi possivel abrir $cmd\n";		
		my $sha1 = Digest::SHA1->new;
		$sha1->addfile($scfh);
		return ($self->{_cmd_hash} eq $sha1->digest);
	}
	return 1;
};
sub run{
	my $self = shift;
	my $param = shift;
	return 0 unless issafe($self);
	my $cmd;
	if ($self->{_cmd_type} eq 'direct'){
		$cmd = "/bin/bash -c '". $self->{_cmd_string}." 2>&1 '";
	}else{
		$cmd = $self->{_cmd_string}." 2>&1";
	}
	open( CMD, "-|", $cmd , $param ) or return 0;
  my $tmp = <CMD>;
  close CMD;
  chomp($tmp);
  $self->{_cmd_out} = $tmp;
};

sub out{
	my $self = shift;
	return $self->{_cmd_out};
}

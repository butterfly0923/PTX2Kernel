#!/usr/bin/perl -w

############################
# Created by zhangshuai #
############################

use 5.010;
use strict;
use utf8;

my %constrain_letter = (
	u16 => "h",
	u32 => "r",
	u64 => "l",
	f32 => "f",
	f64 => "d",
);

sub convert {
	my $entry = shift;

	$entry =~ m{\.entry (\w+)\(};
	my $mangle = $1;
	my $kernel_name = `c++filt $mangle`;
	chomp $kernel_name;

	say "// $kernel_name";
	say "__global__";

	my $arg_count = 0;
	$kernel_name =~ s{<.*>}{};
	while ( $kernel_name =~ m{, }g ) {
		my $p = pos $kernel_name;
		my $param = "param_" . $arg_count++;
		( substr $kernel_name, $p - 2, 2 ) = " $param, ";
		pos $kernel_name = $p + 1 + length $param;
	}
	$kernel_name =~ s/\)$/ param_$arg_count\)/;
	say $kernel_name;

	$_ = <> for ( 0 .. $arg_count );
	$_ = <>;
	if ( ")\n" ne $_ ) {
		say;
		die 'expecting a ) ...';
	}
	$_ = <>;
	if ( "{\n" ne $_ ) {
		die 'expecting a { ...';
	}

	print;
	while ( <> ) {
		chomp;
		last if m/^}$/;

		$_ =~ s/^\s+//;

		if ( m{ld.param.(\w+)\s+%([^,]+), \[\w+(param_\d+)\];} ) {
			my $c = $constrain_letter{$1};
			$_ = qq{asm("mov.$1 $2, %0;"::"$c"($3));};
		} elsif ( m{mov.u32\s+%(\w+), %(ntid|ctaid|tid|nctaid).(x|y|z);} ) {
			$_ = qq{asm("mov.u32 $1, %$2.$3;");};
		} elsif ( m{.loc \d+ \d+ \d+} ) {
			$_ = '';
		} else {
			s/%//g;
			$_ = qq{asm("$_");} if ( $_ );
		}

		say $_ ? "\t$_" : '';
	}
	say;
}

while ( <> ) {
	next unless m{\.entry};
	chomp;
	&convert ( $_ );
}

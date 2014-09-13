package Mantra::Generator::Perl;
use strict;
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = ();
our @EXPORT_OK = ();

use Mantra::Framework;


use constant {
	STATE_NONE => 0,
};


sub new {
	# The mantra framework will ultimately override this class
	# but some information must be handed to the framework that dictates
	# how parsing should occur for varying file types


	my %config = ();
	$config{'regex_line_comment_start'} = qr/^\s*#/;
	$config{'regex_mline_comment_start'} = qr/^=pod\s*/;
	$config{'regex_mline_comment_end'} = qr/^=cut\s*/;
	$config{'new_sub_parse_line'} = sub {
		

		# other state data pointers can be kept here
		# as closure values


		return sub {
			my ($s, $rc, $state) = @_;# str, state_ptr/return code
			$state = $$rc;
			$$rc = -1; # default state is error state
			return undef; # TODO
	};};
	return Mantra::Framework->new($_[0], %config);
}

1;
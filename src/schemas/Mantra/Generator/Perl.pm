package Mantra::Generator::Perl;
use strict;
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = ();
our @EXPORT_OK = ();

use Mantra::Framework;


use constant {
	STATE_NONE => 0,
	STATE_STRING => 1,
	STATE_END => 2
};


sub new {
	# The mantra framework will ultimately override this class
	# but some information must be handed to the framework that dictates
	# how parsing should occur for varying file types


	my %config = ();
	$config{'regex_line_comment_start'} = qr/^\s*#/;
	$config{'regex_mline_comment_start'} = qr/^=pod\s*$/;
	$config{'regex_mline_comment_end'} = qr/^=cut\s*$/;
	$config{'new_sub_parse_line'} = sub {
		

		# other state data pointers can be kept here
		# as closure values
		my $strType = undef;
		my @line = ();


		return sub {
			my ($self, $s, $rc, $cState, $rval) = @_;# self, str, state_ptr/return code
			$cState = $$rc;
			$rval = undef;
			if ($cState == STATE_NONE)
			{
				if ($s =~ /^__(?:END|DATA)__$/)
				{
					$$rc = STATE_END;
				}
				elsif ($s =~ /(?<=[^\$\@\&\%])[\#\"\']/)
				{
					my ($pre, $t, $post) = ($`, $&, $');
					if ($t eq '#')
					{
						# tail end is a line comment
						if ($pre !~ /^\s*$/)
						{
							if ($#line > -1)
							{
								$pre =~ s/(\s|\r|\n)+\z//;
								push(@line, $pre);
							}
							else
							{
								# TODO: do something with code segment $pre
							}
						}
						$$rc = STATE_NONE;
					}
					else
					{
						# got a string segment

						push(@line, $pre);
						push(@line, $t);

						$strType = $t;
						$$rc = STATE_STRING;
						$rval = $post;
					}
				}
				else
				{
					if ($#line > -1)
					{
						$s =~ s/(\s|\r|\n)+\z//;
						push(@line, $s);
					}
					else
					{
						# TODO: do something with code segment $s
					}
				}
			}
			elsif ($cState == STATE_STRING)
			{
				if ($s =~ /^(?:\\\\)*$strType/ || $s =~ /(?<=[^\\])(?:\\\\)*$strType/)
				{
					$rval = $';
					$line[$#line] = sprintf("%s%s%s", $line[$#line], $`, $strType);
					$strType = undef;
					if ((defined $rval) && $rval =~ /^\s*$/)
					{
						$rval = undef;
					}
					$$rc = STATE_NONE;
				}
				else
				{
					$line[$#line] .= $s;
				}
			}
			if (!(defined $rval) && $#line != -1 && $$rc != STATE_STRING)
			{
				#printf("Got line with strings: '%s'\n", join('', @line));
				#TODO: do something with code segment @line
				@line = ();
			}
			return $rval;
		};
	};
	$config{'hash_comment_valid_states'} = {
		(map { $_ => undef } (
			STATE_NONE
		))
	};
	$config{'hash_terminal_states'} = {
		(map { $_ => undef } (
			STATE_NONE,
			STATE_END
		))
	};
	return Mantra::Framework->new($_[0], %config);
}

1;
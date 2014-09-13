package Mantra::Framework;
use strict;
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = ();
our @EXPORT_OK = ();

use FileHandle;


### TODO:
## define methodology that should be standard in all environments
#
# e.g. support for
# 
# rip = relative import path for a spcific file's template definitions
# lip = library import path for a specific file's template definitions (relative import paths are not traversed)
# [rl]idef = include definition of a template by name, using relative lookup paths first
# [rl]imp = import/dump the contents of a file by relative or library path

sub new {
	# override's a class once's its configuration has been confirmed usable
	my $frameworkClass = shift;# this class... not important
	my $classToOverride = shift;
	my %config = @_;
	my $initializer = $config{'new_sub_parse_line'};

	my $nNewFunc = sub {
		my $state = 0;
		my $self = {
			(undef) => [\$state, $initializer->()]
		};
		return bless($self, $classToOverride);
	};

	my $nParseLineFunc = sub {
		my $runtime = $_[0]->{(undef)};
		my ($s, $rc, $parserFunc) = ($_[1], @$runtime);
		#print "GOT: '" . substr($s, 0, length($s) - (($s =~ /[^\r\n]\z/) ? 0 : (($s =~ /\r\n/) ? 2 : 1))) . "'\n";
		do
		{{
			$s = $parserFunc->($s, $rc);
			last;# TODO
		}} while ((defined $s) && $$rc >= 0);
		if ($$rc < 0)
		{
			# TODO: die and report error at line
		}
	};

	my $r = eval("*{$classToOverride\::new} = \$nNewFunc;return 1;");
	die if ($@ || !$r);
	$r = eval("*{$classToOverride\::execute} = *{$frameworkClass\::execute};return 1;");
	die if ($@ || !$r);
	$r = eval("*{$classToOverride\::parseLine} = \$nParseLineFunc;return 1;");
	die if ($@ || !$r);

	my $self = undef;
	$r = eval("\$self = $classToOverride\->new();return 1;");
	die if ($@ || !$r || !(defined $self));
	return $self;
}

sub execute {
	my ($self, $filesInOut, $libPaths) = ((shift), (shift), (shift));
	# TODO: handle libPaths
	my @options = @_;
	my $e;
	foreach $e (@$filesInOut) {
		my $fNameIn = $e->[0];
		my ($fin, $fout) = (FileHandle->new($fNameIn, '<'), FileHandle->new($e->[1], '>'));
		$fin || die;
		$fout || die;
		binmode($fin) || die;
		binmode($fout) || die;
		foreach $e (<$fin>) {
			$self->parseLine($e);
		}
		eval{{
			$fin->close();
		}};
		$e = $@ ? sprintf("%s %s", $@, $!) : undef;
		$fout->close() || die($e);
		die($e) if (defined $e);
	}
}

1;
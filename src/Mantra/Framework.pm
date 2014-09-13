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
	my $frameworkClass = shift;# this class
	my $classToOverride = shift;# class to generate
	my %config = @_;
	my ($self, $initializer, $r) = (undef, $config{'new_sub_parse_line'});

	(sub {
		my ($i, $methodName, $genMethodName1, $genMethodName2) = (0);
		my @genSpec = (
			1, 'new', "\$classToOverride,\$initializer",
			0, 'execute',
			1, 'parseLine', "\%config",
		);
		do {{
			if ($genSpec[$i++]) {
				$methodName = $genSpec[$i++];
				($genMethodName1, $genMethodName2) = (uc(substr($methodName, 0, 1)), substr($methodName, 1, length($methodName) - 1));
				$r = sprintf("*{%s::%s} = %s::_gen%s%sFunc(%s);return 1;", $classToOverride, $methodName, $frameworkClass, $genMethodName1, $genMethodName2, $genSpec[$i++]);
			}
			else {
				$methodName = $genSpec[$i++];
				$r = sprintf("*{%s::%s} = *{%s::%s};return 1;", $classToOverride, $methodName, $frameworkClass, $methodName);
			}
			$r = eval($r);
			die if ($@ || !$r);
		}} while ($i <= $#genSpec);
	})->();

	$r = "\$self = $classToOverride\->new();return 1;";
	$r = eval($r);
	die if ($@ || !$r || !(defined $self));
	return $self;
}

sub _genNewFunc {
	my $classToOverride = shift;
	my $initializer = shift;
	return sub {
		my $state = 0;
		my $self = {
			(undef) => [\$state, $initializer->()]
		};
		return bless($self, $classToOverride);
	};
}

sub _genParseLineFunc {
	my %config = @_;
	
	(exists($config{'regex_line_comment_start'}) && defined($config{'regex_line_comment_start'})) || die;
	
	my ($regex_mline_comment_start, $regex_mline_comment_end, $validCommentStatesMapRef) = (undef, undef);
	my %validCommentStatesMap;
	
	if (exists($config{'regex_mline_comment_start'}) || exists($config{'regex_mline_comment_end'}))
	{
		((exists $config{'regex_mline_comment_start'})
			&& defined(($regex_mline_comment_start = $config{'regex_mline_comment_start'}))
			&& (exists $config{'regex_mline_comment_end'})
			&& defined(($regex_mline_comment_end = $config{'regex_mline_comment_end'}))
		) || die;
	}
	
	$validCommentStatesMapRef = $config{'hash_comment_valid_states'};
	if (defined $validCommentStatesMapRef)
	{
		%validCommentStatesMap = %$validCommentStatesMapRef;
	}
	$validCommentStatesMapRef = (defined $validCommentStatesMapRef);
	
	return sub {
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
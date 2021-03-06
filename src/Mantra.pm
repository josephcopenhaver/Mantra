package Mantra;
use strict;
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = ();
our @EXPORT_OK = ();

use Mantra::Framework;
use Mantra::Constants;

use constant {
	PACKAGE_PREFIX => "Mantra::Generator::"
};

###
# Alloc new file generator
sub new {
	my ($class, $generatorName) = @_;
	die unless ($generatorName !~ /[\r\n]/ && $generatorName =~ /^[a-zA-Z0-9_]+(?:\:\:[a-zA-Z0-9_]+)*$/);
	$generatorName = PACKAGE_PREFIX . $generatorName;
	my ($newCallFinished, $generator) = (undef, undef);
	eval("use $generatorName;\n\$generator = $generatorName\->new();\n\$newCallFinished = 1;");
	die("Failed to find code generation class named \"$generatorName\"\n$@ $!") if ($@ || (!(defined $generator) && !$newCallFinished));
	die("Generator did not return an object!") if !(defined $generator);
	return $generator;
}

1;
BEGIN {
	use strict;
	use File::Basename;
	use Cwd 'abs_path';
	use File::Spec;
	my $baseDir = dirname(abs_path($0));
	push(@INC, File::Spec->catdir($baseDir, 'src'));
	push(@INC, File::Spec->catdir($baseDir, 'src/schemas'));
}

use Mantra;

# load a code generation mantra by name
my $generator = new Mantra("Perl");
$generator->execute([["helloWorld.pl", "out.pl"]]);
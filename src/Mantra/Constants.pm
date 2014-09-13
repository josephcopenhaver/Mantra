package Mantra::Constants;
use strict;
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = ();
our @EXPORT_OK = do {
	no strict 'refs';
	my @list = grep {/^(IDX|TYPE)_/ && (*{*{__PACKAGE__ . '::' . $_}}{CODE})} %{__PACKAGE__ . '::'};
	use strict 'refs';
	@list;
};

1;
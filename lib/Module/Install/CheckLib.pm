package Module::Install::CheckLib;

use strict;
use warnings;
use File::Spec;
use base qw(Module::Install::Base);
use vars qw($VERSION);

$VERSION = '0.04';

sub checklibs {
  my $self = shift;
  my @parms = @_;
  return unless scalar @parms;

  unless ( $Module::Install::AUTHOR ) {
     require Devel::CheckLib;
     Devel::CheckLib::check_lib_or_exit( @parms );
     return;
  }

  _author_side();
}

sub assertlibs {
  my $self = shift;
  my @parms = @_;
  return unless scalar @parms;

  unless ( $Module::Install::AUTHOR ) {
     require Devel::CheckLib;
     Devel::CheckLib::assert_lib( @parms );
     return;
  }

  _author_side();
}

sub _author_side {
  mkdir 'inc';
  mkdir 'inc/Devel';
  print "Extra directories created under inc/\n";
  require Devel::CheckLib;
  local $/ = undef;
  open(CHECKLIBPM, $INC{'Devel/CheckLib.pm'}) ||
    die("Can't read $INC{'Devel/CheckLib.pm'}: $!");
  (my $checklibpm = <CHECKLIBPM>) =~ s/package Devel::CheckLib/package #\nDevel::CheckLib/;
  close(CHECKLIBPM);
  open(CHECKLIBPM, '>'.File::Spec->catfile(qw(inc Devel CheckLib.pm))) ||
    die("Can't write inc/Devel/CheckLib.pm: $!");
  print CHECKLIBPM $checklibpm;
  close(CHECKLIBPM);

  print "Copied Devel::CheckLib to inc/ directory\n";
  return 1;
}

'All your libs are belong';

__END__

=head1 NAME

Module::Install::CheckLib - A Module::Install extension to check that a library is available

=head1 SYNOPSIS

  # In Makefile.PL

  use inc::Module::Install;
  checklibs lib => 'jpeg', header => 'jpeglib.h';

The Makefile.PL will exit unless library or header is found.

=head1 DESCRIPTION

Module::Install::CheckLib is a L<Module::Install> extension that integrates L<Devel::CheckLib> so that
CPAN authors may stipulate which particular C library and its headers they want available and to exit
the C<Makefile.PL> gracefully if they aren't.

The author specifies which C libraries, etc, they want available. L<Devel::CheckLib> is copied to the 
C<inc/> directory along with the L<Module::Install> files.

On the module user side, the bundled C<inc/> L<Devel::CheckLib> determines whether the current environment is 
supported or not and will exit accordingly.

=head1 COMMANDS

This plugin adds the following Module::Install command:

=over

=item C<checklibs>

Requires a list of parameters. These are passed directly to L<Devel::CheckLib> C<check_lib_or_exit> function.
Please consult the documentation for L<Devel::CheckLib> for more details on what these parameters are.

This is generally the function one should use in L<Makefile.PL>, as it exits gracefully and plays nice
with CPAN Testers.

=item C<assertlibs>

The same as C<checklibs> but uses L<Devel::CheckLib> C<assert_lib> instead. C<assert_lib> dies instead
of exiting gracefully. It is provided for completeness, please use C<checklibs>.

=back

=head1 AUTHOR

Chris C<BinGOs> Williams

Based on L<use-devel-checklib> by David Cantrell

=head1 LICENSE

Copyright E<copy> Chris Williams and David Cantrell

This module may be used, modified, and distributed under the same terms as Perl itself. Please see the license that came with your Perl distribution for details.

=head1 SEE ALSO

L<Module::Install>

L<Devel::CheckLib>

=cut

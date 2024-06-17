package Module::Build::MorphoDiTa;
use Module::Build;
@ISA = qw(Module::Build);
sub ACTION_build {
    my $self = shift;
    print STDERR "Building requires C++11 compiler, either g++ 4.7 or newer, or clang++ 3.2 or newer.\n";
    $self->SUPER::ACTION_build;
}

1;

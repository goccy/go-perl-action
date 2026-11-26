use strict;
use warnings;
use Test::More tests => 1;
use Try::Tiny;

my $got = try { die "boom\n" } catch { "caught $_" };
is($got, "caught boom\n", 'Try::Tiny from the cpanfile');

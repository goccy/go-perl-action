use strict;
use warnings;
use Try::Tiny;

print try { die "gperl\n" } catch { "hello from $_" };

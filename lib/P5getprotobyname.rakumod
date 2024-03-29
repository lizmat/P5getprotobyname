use NativeCall;

my class ProtoStruct is repr<CStruct> {
    has Str         $.p_name;
    has CArray[Str] $.p_aliases;
    has uint32      $.p_proto;

    sub HLLizeCArrayStr(\list) {
        my @members;
        with list -> $members {
            for ^Inf {
                with $members[$_] -> $member {
                    @members.push($member)
                }
                else {
                    last
                }
            }
        }
        @members
    }

    multi method scalar(ProtoStruct:U: --> Nil) { }
    multi method scalar(ProtoStruct:D: :$proto) {
        $proto ?? $.p_proto !! $.p_name
    }

    multi method list(ProtoStruct:U:) { () }
    multi method list(ProtoStruct:D:) {
        ($.p_name,HLLizeCArrayStr($.p_aliases).join(" "),$.p_proto)
    }
}

# actual NativeCall interfaces
sub _getprotobyname(Str --> ProtoStruct)
  is native is symbol<getprotobyname> {*}
sub _getprotobynumber(int32 --> ProtoStruct)
  is native is symbol<getprotobynumber> {*}
sub _getprotoent(--> ProtoStruct) is native is symbol<getprotoent> {*}
sub _setprotoent(int32) is native is symbol<setprotoent> {*}
sub _endprotoent() is native is symbol<endprotoent> {*}

# actual exported subs
my proto sub getprotobyname(|) is export {*}
multi sub getprotobyname(Scalar:U, Str() $name) {
    _getprotobyname($name).scalar(:proto)
}
multi sub getprotobyname(Str() $name) { _getprotobyname($name).list }

my proto sub getprotobynumber(|) is export {*}
multi sub getprotobynumber(Scalar:U, Int:D $proto) {
    my int32 $nproto = $proto;
    _getprotobynumber($nproto).scalar
}
multi sub getprotobynumber(Int:D $proto) {
    my int32 $nproto = $proto;
    _getprotobynumber($nproto).list
}

my proto sub getprotoent(|) is export {*}
multi sub getprotoent(Scalar:U) { _getprotoent.scalar }
multi sub getprotoent() { _getprotoent.list }

my sub setprotoent($stayopen) is export {
    my int32 $nstayopen = ?$stayopen;
    _setprotoent($nstayopen);
    1;  # this is apparently what Perl does, although not documented
}

my sub endprotoent() is export {
    _endprotoent;
    1;  # this is apparently what Perl does, although not documented
}

=begin pod

=head1 NAME

Raku port of Perl's getprotobyname() and associated built-ins

=head1 SYNOPSIS

    use P5getprotobyname;
    # exports getprotobyname, getprotobyport, getprotoent, setprotoent, endprotoent

    say getprotobynumber(0, :scalar);   # "ip"

    my @result_byname = getprotobyname("ip");

    my @result_bynumber = getprotobynumber(@result_byname[2]);

=head1 DESCRIPTION

This module tries to mimic the behaviour of Perl's C<getprotobyname> and
associated built-ins as closely as possible in the Raku Programing Language.

It exports by default:

    endprotoent getprotobyname getprotobynumber getprotoent setprotoent

=head1 ORIGINAL PERL 5 DOCUMENTATION

    getprotobyname NAME
    getprotobynumber NUMBER
    getprotoent
    setprotoent STAYOPEN
    endprotoent
            These routines are the same as their counterparts in the system C
            library. In list context, the return values from the various get
            routines are as follows:

             # 0        1          2           3         4
             ( $name,   $aliases,  $proto                ) = getproto*

            In scalar context, you get the name, unless the function was a
            lookup by name, in which case you get the other thing, whatever it
            is. (If the entry doesn't exist you get the undefined value.)

            The "getprotobynumber" function, even though it only takes one
            argument, has the precedence of a list operator, so beware:

                getprotobynumber $number eq 'icmp'   # WRONG
                getprotobynumber($number eq 'icmp')  # actually means this
                getprotobynumber($number) eq 'icmp'  # better this way

=head1 PORTING CAVEATS

This module depends on the availability of POSIX semantics.  This is
generally not available on Windows, so this module will probably not work
on Windows.

=head1 AUTHOR

Elizabeth Mattijsen <liz@raku.rocks>

If you like this module, or what I’m doing more generally, committing to a
L<small sponsorship|https://github.com/sponsors/lizmat/>  would mean a great
deal to me!

Source can be located at: https://github.com/lizmat/P5getprotobyname .
Comments and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018, 2019, 2020, 2021, 2023 Elizabeth Mattijsen

Re-imagined from Perl as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4

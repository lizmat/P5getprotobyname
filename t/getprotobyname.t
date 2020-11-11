use v6.*;
use Test;
use P5getprotobyname;
%*ENV<RAKUDO_NO_DEPRECATIONS> = True;

plan 16;

my @ip = 'ip','IP',0;
is getprotobyname(Scalar, "ip"), 0,
  'did we find ip by name in scalar context';
is getprotobyname("ip", :scalar), 0,
  'did we find ip by name in scalar context';

my @byname = getprotobyname("ip");
is-deeply @byname, @ip, 'did we find ip by name';

is getprotobynumber(Scalar, 0), "ip",
  'did we find ip by number in scalar context';
is getprotobynumber(0,:scalar), "ip",
  'did we find ip by number in scalar context';

my @bynumber = getprotobynumber(0);
is-deeply @bynumber, @ip, 'did we find ip by number';

my $protoname = getprotoent(Scalar);
ok ?$protoname, 'did we get a proto name';

is setprotoent(False), 1, 'does setprotoent(False) return the undocumented 1';
is setprotoent(True),  1, 'does setprotoent(True) return the undocumented 1';

is endprotoent(), 1, 'does endprotoent return the undocumented 1';

is getprotobyname(Scalar, "thisnameshouldnotexist"), Nil,
  'did lookup by non-existing name fail in scalar context';
is getprotobyname("thisnameshouldnotexist", :scalar), Nil,
  'did lookup by non-existing name fail in scalar context';
is-deeply getprotobyname("thisnameshouldnotexist"), (),
  'did lookup by non-existing name fail';

is getprotobynumber(Scalar, 99999), Nil,
  'did lookup by non-existing proto fail in scalar context';
is getprotobynumber(99999, :scalar), Nil,
  'did lookup by non-existing proto fail in scalar context';
is-deeply getprotobynumber(99999), (),
  'did lookup by non-existing proto fail';

# vim: expandtab shiftwidth=4

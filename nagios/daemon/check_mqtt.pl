#!/usr/bin/env perl
# nagios plugin connecting to an mqtt broker (plain tcp, mqtt 3.1.1) and reading its CONNACK
#
# usage: check_mqtt -H <host> [-p <port>] [-u <user> -P <password>] [-t <timeout>]
#
# without credentials the broker proves it is working by answering the CONNECT at all,
# so "not authorized" and "bad user name or password" are OK as well.
# with credentials only an accepted connection is OK.
use strict;
use warnings;
use Getopt::Long qw(:config no_ignore_case bundling);
use IO::Socket::INET;
use Time::HiRes qw(time);

my %STATE = (OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3);

# CONNACK return codes of mqtt 3.1.1
my %RETURN_CODES = (
    0 => 'connection accepted',
    1 => 'unacceptable protocol version',
    2 => 'client identifier rejected',
    3 => 'server unavailable',
    4 => 'bad user name or password',
    5 => 'not authorized',
);

my ($host, $user, $password);
my $port = 1883;
my $timeout = 10;
GetOptions(
    'H=s' => \$host, 'p=i' => \$port, 'u=s' => \$user, 'P=s' => \$password, 't=i' => \$timeout,
) or finish('UNKNOWN', 'invalid arguments');
finish('UNKNOWN', 'usage: check_mqtt -H <host> [-p port] [-u user -P password] [-t timeout]') unless $host;
finish('UNKNOWN', 'user and password have to be given together') if defined $user xor defined $password;

local $SIG{ALRM} = sub { finish('CRITICAL', "no answer from $host:$port within $timeout seconds") };
alarm $timeout;

my $start = time;
my $socket = IO::Socket::INET->new(PeerAddr => $host, PeerPort => $port, Proto => 'tcp')
    or finish('CRITICAL', "cannot connect to $host:$port: $@");

# variable header: protocol name, level 4 (3.1.1), flags, keep alive 60 seconds
# flags: clean session, plus user name and password when given
my $flags = 0x02 | (defined $user ? 0xc0 : 0);
my $body = mqtt_string('MQTT') . pack('C C n', 4, $flags, 60);
$body .= mqtt_string("nagios-$$");
$body .= mqtt_string($user) . mqtt_string($password) if defined $user;
print $socket pack('C', 0x10) . remaining_length(length $body) . $body;

my $read = read($socket, my $connack, 4);
my $elapsed = time - $start;
finish('CRITICAL', "$host:$port closed the connection without CONNACK") unless $read && $read == 4;

my ($type, $length, $session_present, $code) = unpack('C4', $connack);
finish('CRITICAL', sprintf('%s:%d answered with packet type 0x%02x, not CONNACK', $host, $port, $type))
    unless $type == 0x20 && $length == 2;

# disconnect cleanly, the broker would log an unexpected connection loss otherwise
print $socket pack('C2', 0xe0, 0) if $code == 0;
close $socket;

my $text = $RETURN_CODES{$code} // "unknown return code $code";
my $perfdata = sprintf('time=%.3fs;;;0', $elapsed);
my $state = $code == 0 ? 'OK'
    : !defined $user && ($code == 4 || $code == 5) ? 'OK'
    : 'CRITICAL';
finish($state, "MQTT broker on $host:$port: $text", $perfdata);

sub finish {
    my ($state, $text, $perfdata) = @_;
    print "$state - $text" . ($perfdata ? " | $perfdata" : '') . "\n";
    exit $STATE{$state};
}

# utf-8 string with a 2 byte length prefix
sub mqtt_string { pack('n/a*', $_[0]) }

# variable length encoding, 7 bits per byte, high bit set when more bytes follow
sub remaining_length {
    my ($length) = @_;
    my $encoded = '';
    do {
        my $byte = $length % 128;
        $length = int($length / 128);
        $encoded .= pack('C', $length > 0 ? $byte | 0x80 : $byte);
    } while ($length > 0);
    return $encoded;
}

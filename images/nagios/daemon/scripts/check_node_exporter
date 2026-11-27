#!/usr/bin/env perl
# nagios plugin reading the metrics of a prometheus node_exporter (http://<host>:9100/metrics)
#
# usage: check_node_exporter -H <host> -m <mode> [-p <port>] [-w <warning>] [-c <critical>] [-x <exclude regex>] [-t <timeout>]
#
# modes (default thresholds in brackets):
#   disk      free space and inodes per filesystem in percent [15,5], read only filesystems are critical
#             -x excludes mount points
#   memory    available memory in percent [10,5]
#   load      5 minute load per cpu [2,4]
#   time      clock synchronised and offset in seconds [0.1,1]
#   services  failed systemd units, or runit services (gitlab omnibus) that are down although wanted up
#             -x excludes unit/service names
#   raid      software raid (md): failed disks are critical, resync/recovery a warning
#   smart     disk health from the smartmon and nvme textfile collectors, nvme wear in percent [80,90]
#   updates   reboot required is a warning, pending package upgrades are reported
use strict;
use warnings;
use Getopt::Long qw(:config no_ignore_case bundling);
use HTTP::Tiny;

my %STATE = (OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3);

my ($host, $mode, $warning, $critical, $exclude);
my $port = 9100;
my $timeout = 10;
GetOptions(
    'H=s' => \$host, 'm=s' => \$mode, 'p=i' => \$port,
    'w=s' => \$warning, 'c=s' => \$critical, 'x=s' => \$exclude, 't=i' => \$timeout,
) or finish('UNKNOWN', 'invalid arguments');
finish('UNKNOWN', 'usage: check_node_exporter -H <host> -m <mode> [-p port] [-w warning] [-c critical] [-x exclude] [-t timeout]')
    unless $host && $mode;

my $response = HTTP::Tiny->new(timeout => $timeout)->get("http://$host:$port/metrics");
finish('CRITICAL', "node_exporter on $host:$port not reachable: $response->{status} $response->{reason}")
    unless $response->{success};

# metric name => list of { labels => {..}, value => .. }
my %metrics;
for my $line (split /\n/, $response->{content}) {
    next if $line =~ /^#/;
    next unless $line =~ /^([a-zA-Z_:][\w:]*)(?:\{(.*)\})?\s+(\S+)/;
    my ($name, $labels, $value) = ($1, $2 // '', $3);
    my %labels = $labels =~ /(\w+)="((?:[^"\\]|\\.)*)"/g;
    push @{ $metrics{$name} }, { labels => \%labels, value => $value };
}

my %checks = (
    disk => \&check_disk, memory => \&check_memory, load => \&check_load, time => \&check_time,
    services => \&check_services, raid => \&check_raid, smart => \&check_smart, updates => \&check_updates,
);
finish('UNKNOWN', "unknown mode $mode, expected one of: " . join(', ', sort keys %checks)) unless $checks{$mode};
$checks{$mode}->();

sub finish {
    my ($state, $text, $perfdata) = @_;
    print "$state - $text" . ($perfdata ? " | $perfdata" : '') . "\n";
    exit $STATE{$state};
}

sub series { @{ $metrics{ $_[0] } // [] } }

sub value {
    my ($name) = @_;
    my @series = series($name);
    return @series ? $series[0]{value} : undef;
}

sub require_metrics {
    for (@_) { finish('UNKNOWN', "metric $_ not exported by $host") unless $metrics{$_} }
}

sub worst { (sort { $STATE{$b} <=> $STATE{$a} } @_)[0] // 'OK' }

# lower values are worse, e.g. free space
sub state_below { my ($v, $w, $c) = @_; $v <= $c ? 'CRITICAL' : $v <= $w ? 'WARNING' : 'OK' }

# higher values are worse, e.g. load
sub state_above { my ($v, $w, $c) = @_; $v >= $c ? 'CRITICAL' : $v >= $w ? 'WARNING' : 'OK' }

sub check_disk {
    my ($w, $c) = ($warning // 15, $critical // 5);
    require_metrics('node_filesystem_size_bytes');
    my $virtual = qr/^(tmpfs|ramfs|devtmpfs|overlay|squashfs|nsfs|autofs|efivarfs|iso9660|fuse.*)$/;
    my (%size, %avail, %files, %ffree, %readonly, %error, %device);
    for my $s (series('node_filesystem_size_bytes')) {
        my $l = $s->{labels};
        next if $l->{fstype} =~ $virtual || ($exclude && $l->{mountpoint} =~ /$exclude/);
        $size{ $l->{mountpoint} } = $s->{value};
        $device{ $l->{mountpoint} } = $l->{device};
    }
    my %lookup = (
        node_filesystem_avail_bytes => \%avail, node_filesystem_files => \%files,
        node_filesystem_files_free => \%ffree, node_filesystem_readonly => \%readonly,
        node_filesystem_device_error => \%error,
    );
    while (my ($name, $target) = each %lookup) {
        $target->{ $_->{labels}{mountpoint} } = $_->{value} for series($name);
    }

    # node_exporter could not stat the mount point, e.g. missing permissions: no data
    my @skipped = sort grep { $error{$_} && !($exclude && /$exclude/) } keys %error;

    my (@states, @problems, @perfdata, %seen_device);
    for my $mount (sort keys %size) {
        # bind mounts show the same device several times
        next if $seen_device{ $device{$mount} }++;
        next if $error{$mount} || !$size{$mount};
        my $free = 100 * ($avail{$mount} // 0) / $size{$mount};
        my $state = state_below($free, $w, $c);
        my $text = sprintf '%s %.1f%% free', $mount, $free;
        if ($files{$mount}) {
            my $ifree = 100 * ($ffree{$mount} // 0) / $files{$mount};
            my $istate = state_below($ifree, $w, $c);
            if ($STATE{$istate} > $STATE{$state}) { $state = $istate; $text = sprintf '%s %.1f%% inodes free', $mount, $ifree }
        }
        if ($readonly{$mount}) { $state = 'CRITICAL'; $text = "$mount read only" }
        push @states, $state;
        push @problems, $text if $state ne 'OK';
        push @perfdata, sprintf "'%s'=%.1f%%;%s;%s;0;100", $mount, $free, $w, $c;
    }
    finish('UNKNOWN', 'no filesystems found') unless @states;
    my $state = worst(@states);
    my $text = @problems ? join(', ', @problems) : scalar(@states) . ' filesystems ok';
    $text .= ' (not readable: ' . join(', ', @skipped) . ')' if @skipped;
    finish($state, $text, join ' ', @perfdata);
}

sub check_memory {
    my ($w, $c) = ($warning // 10, $critical // 5);
    require_metrics('node_memory_MemAvailable_bytes', 'node_memory_MemTotal_bytes');
    my $total = value('node_memory_MemTotal_bytes');
    my $available = value('node_memory_MemAvailable_bytes');
    my $percent = 100 * $available / $total;
    finish(state_below($percent, $w, $c),
        sprintf('%.1f%% available (%.1f of %.1f GiB)', $percent, $available / 2**30, $total / 2**30),
        sprintf('available=%.1f%%;%s;%s;0;100', $percent, $w, $c));
}

sub check_load {
    my ($w, $c) = ($warning // 2, $critical // 4);
    require_metrics('node_load5', 'node_cpu_seconds_total');
    my $cpus = grep { $_->{labels}{mode} eq 'idle' } series('node_cpu_seconds_total');
    my $load = value('node_load5') / ($cpus || 1);
    finish(state_above($load, $w, $c),
        sprintf('load5 %.2f per cpu (%.2f on %d cpus)', $load, value('node_load5'), $cpus),
        sprintf('load5_per_cpu=%.2f;%s;%s;0', $load, $w, $c));
}

sub check_time {
    my ($w, $c) = ($warning // 0.1, $critical // 1);
    require_metrics('node_timex_sync_status', 'node_timex_offset_seconds');
    my $offset = value('node_timex_offset_seconds');
    finish('CRITICAL', 'clock not synchronised') unless value('node_timex_sync_status') == 1;
    finish(state_above(abs $offset, $w, $c), sprintf('clock synchronised, offset %.4fs', $offset),
        sprintf('offset=%.6fs;%s;%s', $offset, $w, $c));
}

sub check_services {
    my @failed;
    if ($metrics{node_systemd_unit_state}) {
        @failed = map { $_->{labels}{name} }
            grep { $_->{labels}{state} eq 'failed' && $_->{value} == 1 } series('node_systemd_unit_state');
    }
    elsif ($metrics{node_service_state}) {
        my %wanted = map { $_->{labels}{service} => $_->{value} } series('node_service_desired_state');
        @failed = map { $_->{labels}{service} }
            grep { $wanted{ $_->{labels}{service} } && $_->{value} != 1 } series('node_service_state');
    }
    else {
        finish('UNKNOWN', "neither systemd nor runit metrics exported by $host");
    }
    @failed = grep { !/$exclude/ } @failed if $exclude;
    finish('CRITICAL', 'failed: ' . join(', ', sort @failed), 'failed=' . scalar @failed) if @failed;
    finish('OK', 'no failed services', 'failed=0');
}

sub check_raid {
    require_metrics('node_md_disks', 'node_md_state');
    my (@states, @texts);
    my %devices = map { $_->{labels}{device} => 1 } series('node_md_state');
    for my $device (sort keys %devices) {
        my %disks = map { $_->{labels}{state} => $_->{value} } grep { $_->{labels}{device} eq $device } series('node_md_disks');
        my ($state) = map { $_->{labels}{state} } grep { $_->{labels}{device} eq $device && $_->{value} == 1 } series('node_md_state');
        $state //= 'unknown';
        my $result = $disks{failed} ? 'CRITICAL' : $state eq 'active' ? 'OK' : $state =~ /^(resync|recovering|check)$/ ? 'WARNING' : 'CRITICAL';
        push @states, $result;
        push @texts, sprintf '%s %s (%d active, %d failed)', $device, $state, $disks{active} // 0, $disks{failed} // 0;
    }
    finish(worst(@states), join(', ', @texts));
}

sub check_smart {
    my ($w, $c) = ($warning // 80, $critical // 90);
    finish('UNKNOWN', "no smartmon or nvme metrics exported by $host")
        unless $metrics{smartmon_device_smart_healthy} || $metrics{nvme_critical_warning};
    my (@states, @problems, $count);
    for (series('smartmon_device_smart_healthy')) {
        $count++;
        next if $_->{value} == 1;
        push @states, 'CRITICAL';
        push @problems, "$_->{labels}{disk} smart unhealthy";
    }
    # the smartmon textfile collector runs periodically, stale data means it stopped working
    for (series('smartmon_smartctl_run')) {
        next if time - $_->{value} < 2 * 86400;
        push @states, 'WARNING';
        push @problems, "$_->{labels}{disk} smart data older than 2 days";
    }
    for (series('nvme_critical_warning')) {
        next if $_->{value} == 0;
        push @states, 'CRITICAL';
        push @problems, "$_->{labels}{device} nvme critical warning $_->{value}";
    }
    for (series('nvme_media_errors_total')) {
        next if $_->{value} == 0;
        push @states, 'WARNING';
        push @problems, "$_->{labels}{device} $_->{value} media errors";
    }
    my @perfdata;
    for (series('nvme_percentage_used_ratio')) {
        # share of the rated endurance used, can exceed 1
        my $used = $_->{value} * 100;
        my $state = state_above($used, $w, $c);
        push @states, $state;
        push @problems, sprintf '%s %.0f%% worn', $_->{labels}{device}, $used if $state ne 'OK';
        push @perfdata, sprintf "'%s_used'=%.1f%%;%s;%s;0;100", $_->{labels}{device}, $used, $w, $c;
    }
    finish(worst(@states), @problems ? join(', ', @problems) : ($count // 0) . ' disks healthy', join ' ', @perfdata);
}

sub check_updates {
    require_metrics('node_reboot_required');
    my $upgrades = 0;
    $upgrades += $_->{value} for series('apt_upgrades_pending');
    my $text = "$upgrades package upgrades pending";
    finish('WARNING', "reboot required, $text", "upgrades=$upgrades") if value('node_reboot_required');
    finish('OK', "no reboot required, $text", "upgrades=$upgrades");
}

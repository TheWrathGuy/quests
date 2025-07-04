sub ZoneHasBonusType {
    my ($zone_short, $bonus_type) = @_;
    return 0 unless $zone_short && $bonus_type;

    my $dbh = plugin::LoadMysql();
    my $query = "SELECT 1 FROM daily_juice_zones WHERE zone_short_name = ? AND bonus_type = ? LIMIT 1";
    my $sth = $dbh->prepare($query);
    $sth->execute($zone_short, $bonus_type);

    my $row = $sth->fetchrow_arrayref();
    $sth->finish();

    return $row ? 1 : 0;
}

sub GetJuiceZonesByType {
    my $dbh = plugin::LoadMysql();

    my $query = "SELECT bonus_type, zone_short_name FROM daily_juice_zones";
    my $sth = $dbh->prepare($query);
    $sth->execute();

    my %bonuses;
    while (my ($type, $zone_short_name) = $sth->fetchrow_array) {
        push @{ $bonuses{$type} }, quest::GetZoneLongName($zone_short_name);
    }

    $sth->finish;
    $dbh->disconnect;
    return %bonuses;
}


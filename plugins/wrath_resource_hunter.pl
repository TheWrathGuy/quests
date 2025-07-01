sub ZoneHasBonusType {
    my ($zone_short, $bonus_type) = @_;
    return 0 unless $zone_short && $bonus_type;

    my $dbh = plugin::LoadMysql();
    my $query = "SELECT 1 FROM resource_hunter_zones WHERE zone_short_name = ? AND bonus_type = ? LIMIT 1";
    my $sth = $dbh->prepare($query);
    $sth->execute($zone_short, $bonus_type);

    my $row = $sth->fetchrow_arrayref();
    $sth->finish();

    return $row ? 1 : 0;
}

sub EVENT_ENTERZONE {
    if ($instanceversion > 0) {        
        return;
    }

    if (plugin::ZoneHasBonusType($zonesn, 'coin')) {
        $client->Message(15, "JUICE! Coin is flowing heavy in this zone!");
        $client->Popup2(
            "JUICE COIN ZONE",
            "<br><c \"#FFD700\">Enemies in this zone are dropping that sweet, sweet JUICE! (extra coin)</c><br><br>
            Don't miss your chance to cash in.<br><br>
            <c \"#00FF00\">Stack that plat!</c>",
            6
        );
    }
    elsif (plugin::ZoneHasBonusType($zonesn, 'exp')) {
        $client->Message(15, "JUICE! This zone is overflowing with bonus experience!");
        $client->Popup2(
            "JUICE EXP ZONE",
            "<br><c \"#00BFFF\">Experience gains are juiced up in this zone!</c><br><br>
            Level faster, grind smarter.<br><br>
            <c \"#00FF00\">Get that XP drip!</c>",
            6
        );
    }
    elsif (plugin::ZoneHasBonusType($zonesn, 'empowered')) {
        $client->Message(15, "JUICE! Items in this zone are more likely to Empower!");
        $client->Popup2(
            "JUICE UPGRADE ZONE",
            "<br><c \"#FF69B4\">Items found here have a higher chance to be <b>Empowered</b>!</c><br><br>
            The JUICE is real—score boosted stats and rare affixes.<br><br>
            <c \"#00FF00\">Loot with purpose!</c>",
            6
        );
    }
    elsif (plugin::ZoneHasBonusType($zonesn, 'respawn')) {
        $client->Message(15, "JUICE! Fast respawns are active in this zone!");
        $client->Popup2(
            "JUICE RESPAWN ZONE",
            "<br><c \"#FFA500\">Enemies in this zone respawn much quicker than usual.</c><br><br>
            More mobs, more mayhem, more JUICE!<br><br>
            <c \"#00FF00\">Farm like a beast!</c>",
            6
        );
    }
    elsif (plugin::ZoneHasBonusType($zonesn, 'loot')) {
        $client->Message(15, "JUICE! Enemies here are dropping more loot!");
        $client->Popup2(
            "JUICE LOOT ZONE",
            "<br><c \"#FFD700\">Loot drops are juiced in this zone!</c><br><br>
            Kill mobs. Get gear. Repeat.<br><br>
            <c \"#00FF00\">Grab the goods!</c>",
            6
        );
    }
}

sub EVENT_ENTERZONE {
    if ($instanceversion > 0) {        
        return;
    }

    if (plugin::ZoneHasBonusType($zonesn, 'coin')) {
        $client->Message(15, "Coin Bonus Active: Enemies drop extra coin in this zone!");
        $client->Popup2(
            "Coin Bonus Active!",
            "<br><c \"#FFD700\">Enemies in this zone drop extra coin!</c><br><br>
            Gather your riches while it lasts.<br><br>
            <c \"#00FF00\">Happy hunting!</c>",
            6
        );
    }
    elsif (plugin::ZoneHasBonusType($zonesn, 'exp')) {
        $client->Message(15, "EXP Bonus Active: Enemies grant extra experience!");
        $client->Popup2(
            "EXP Bonus Active!",
            "<br><c \"#00BFFF\">Enemies grant extra experience in this zone!</c><br><br>
            Level up faster while this bonus is active.<br><br>
            <c \"#00FF00\">Grind smart!</c>",
            6
        );
    }
    elsif (plugin::ZoneHasBonusType($zonesn, 'empowered')) {
        $client->Message(15, "Empowered Bonus: Items now have a greater chance to upgrade to Empowered quality!");
        $client->Popup2(
            "Empowered Item Upgrade Bonus!",
            "<br><c \"#FF69B4\">Items found in this zone have a higher chance to upgrade to <b>Empowered</b> quality!</c><br><br>
            Hunt for gear with enhanced stats and rare affixes.<br><br>
            <c \"#00FF00\">Good luck!</c>",
            6
        );
    }
    elsif (plugin::ZoneHasBonusType($zonesn, 'respawn')) {
        $client->Message(15, "Fast Respawn Bonus: Enemies respawn more quickly here.");
        $client->Popup2(
            "Fast Respawn Bonus!",
            "<br><c \"#FFA500\">Enemies in this zone respawn faster than usual.</c><br><br>
            Great for farming or group grinding.<br><br>
            <c \"#00FF00\">Stay alert!</c>",
            6
        );
    }
    elsif (plugin::ZoneHasBonusType($zonesn, 'loot')) {
        $client->Message(15, "Loot Bonus Active: Enemies drop more items here!");
        $client->Popup2(
            "Loot Bonus Active!",
            "<br><c \"#FFD700\">Enhanced drop rates are active in this zone!</c><br><br>
            Expect more loot from every battle.<br><br>
            <c \"#00FF00\">Loot everything!</c>",
            6
        );
    }
}

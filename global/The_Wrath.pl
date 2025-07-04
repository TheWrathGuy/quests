sub EVENT_SAY {
    my $name = $client->GetCleanName();

    if ($text =~ /hail/i) {
        plugin::Whisper("Welcome to The Wrath, $name.");

        plugin::Whisper("");
        plugin::Whisper("This is a progression-based EverQuest server with custom balancing.");
        plugin::Whisper("Here are some things to know:");

        plugin::Whisper("");
        plugin::Whisper("  - Enemies are scaled down by era to support solo and small group play:");
        plugin::Whisper("    • Classic: 35% weaker");
        plugin::Whisper("    • Kunark: 25% weaker");
        plugin::Whisper("    • Velious: 15% weaker");
        plugin::Whisper("    • Luclin: 10% weaker");
        plugin::Whisper("    • Planes of Power: 5% weaker");

        plugin::Whisper("");
        plugin::Whisper("  - Max level is 65 (unlocked by completing the progression path)");
        plugin::Whisper("  - Content up through Legacy of Ykesha and Lost Dungeons of Norrath is available");
        plugin::Whisper("  - AA abilities unlock at level 51");
        plugin::Whisper("  - Out-of-era spells and AAs are enabled");
        plugin::Whisper("  - No boxing. No bots. Balanced for solo, duo, and trio gameplay");

        plugin::Whisper("");
        plugin::Whisper("  - Daily JUICE zones rotate every 24 hours, providing special zone bonuses such as EXP, coin, loot, faster spawns, and empowered drops!");

        plugin::Whisper("");
        plugin::Whisper("Need help or want to connect? [Join Discord] | [Disclaimer]");
    }

    elsif ($text =~ /discord/i) {
        plugin::Whisper("");
        plugin::Whisper("Join our Discord community here:");
        plugin::Whisper("https://discord.gg/YOUR_INVITE_HERE");
    }

    elsif ($text =~ /disclaimer/i) {
        plugin::Whisper("");
        plugin::Whisper("Disclaimer:");
        plugin::Whisper("This is a fan-made project and is not affiliated with or endorsed by Daybreak Games.");
        plugin::Whisper("All intellectual property belongs to Daybreak and the original EverQuest team.");
        plugin::Whisper("The official version of EverQuest can be found at:");
        plugin::Whisper("https://www.everquest.com/");
        plugin::Whisper("We do not accept donations. All content used is publicly available.");
    }
}

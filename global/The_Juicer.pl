sub EVENT_SAY {
    my $name = $client->GetCleanName();

if ($text =~ /hail/i) {
    my $greeting = quest::ChooseRandom(
        "Mmm... well hello there, $name. Are you here for the [Daily JUICE]!? [Yes] [No] [What's That?]",
        "You've got that thirsty look, $name... craving a little [Daily JUICE]? [Yes] [No] [What's That?]",
        "Hey there, sweetness. Want a taste of today's [Daily JUICE]? [Yes] [No] [What's That?]",
        "The JUICE is fresh, the bonuses are hot... What do you say, $name? [Yes] [No] [What's That?]",
        "Welcome back, $name. Ready to get JUICED UP? [Yes] [No] [What's That?]"
    );
    plugin::Whisper($greeting);
}

    elsif ($text =~ /daily juice/i || $text =~ /yes/i) {
        plugin::Whisper(quest::ChooseRandom(
            "Mmm... I thought you might be thirsty.",
            "I knew you couldn't resist the JUICE!",
            "You're in luck—today's JUICE is extra fresh.",
            "Let's get you dripping with bonuses, sugar."
        ));
        plugin::Whisper("What kind of JUICE! are you thirsty for?");
        plugin::Whisper("[EXP], [Coin], [Loot], [Respawn], [Empowered], [All]");
    }


    elsif ($text =~ /^(exp|coin|loot|respawn|empowered)$/i) {
        my $type = lc($1);
        my %bonuses = plugin::GetJuiceZonesByType();
        my $zones = $bonuses{$type};

        if ($zones && @$zones) {
            my $pretty = ucfirst($type);
            plugin::Whisper("=========================");
            plugin::Whisper("[$pretty Bonus]");
            plugin::Whisper("  " . join(", ", @$zones));
            plugin::Whisper("=========================");
        } else {
            plugin::Whisper("Hmm... No JUICE! is flowing for that type today.");
        }
    }
    elsif ($text =~ /all/i) {
        plugin::Whisper(quest::ChooseRandom(
            "You want the full JUICE!? I like your style.",
            "Everything? You animal. Let's pour it all.",
            "You're a JUICE connoisseur... I respect it.",
            "Bottoms up! Here's today's full JUICE lineup."
        ));

        plugin::Whisper("=========================");

        my %bonuses = plugin::GetJuiceZonesByType();

        foreach my $type (qw(exp coin loot respawn empowered)) {
            my $zones = $bonuses{$type};
            next unless $zones && @$zones;

            my $pretty = ucfirst($type);
            plugin::Whisper("$pretty");
            plugin::Whisper("  " . join(", ", @$zones));
            plugin::Whisper(""); # spacing
        }

        plugin::Whisper("=========================");
    }
    elsif ($text =~ /no/i) {
        plugin::Whisper(quest::ChooseRandom(
            "Oh honey... You don't want MY JUICE!? Haha, your loss. Come back when you're feeling dry~",
            "Suit yourself, sweetness. My JUICE isn't for the faint of heart.",
            "No JUICE for you? Tsk tsk. You'll be back. They always come back.",
            "Playing hard to get, huh? That's okay. I've got JUICE for days."
        ));
    }
    elsif ($text =~ /what/i) {
        plugin::Whisper("The Daily JUICE! is a rotating set of bonus zones. Each day, different zones are juiced up with extra perks:");
        plugin::Whisper("- Coin: More money from kills.");
        plugin::Whisper("- EXP: Faster leveling.");
        plugin::Whisper("- Loot: Extra item drops.");
        plugin::Whisper("- Empowered: Better chance for upgraded items.");
        plugin::Whisper("- Respawn: Faster mob respawns.");
        plugin::Whisper(quest::ChooseRandom(
            "Get out there and soak up that JUICE!",
            "Now go, and let that JUICE flow through you!",
            "Come back when you've had your fill... or want seconds.",
            "Time to squeeze every drop out of today!"
        ));
    }
}

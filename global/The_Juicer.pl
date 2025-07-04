sub EVENT_SAY {
    my $name = $client->GetCleanName();
    my $qglobal = $qglobals{"juicebuff"};

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

    elsif ($text =~ /^juice!$/i) {
        if (defined $qglobals{"juicebuff"}) {
            plugin::Whisper("Mmm... You've already had your JUICE! Come back later.");
            return;
        }

        plugin::Whisper("You said the magic word... Time to get JUICED UP!");
        quest::emote("grins wickedly and raises her hands. A surge of fruity power envelops you!");

        my @juice_buffs = (278, 39, 263, 697, 17, 89);
        foreach my $spell_id (@juice_buffs) {
            $npc->SpellFinished($spell_id, $client);
        }

        quest::setglobal("juicebuff", 1, 5, "S10");
        plugin::Whisper("Enjoy the JUICE! You'll be ready for more JUICE later (30 minutes).");
        plugin::Whisper("*psst*... If you hand me 1000 platinum, I'll give you the REAL JUICE.");
    }
}

sub EVENT_ITEM {
    my $platinum = $platinum;  # This is provided by the event context

    if ($platinum >= 1000) {
        plugin::Whisper("Ooohh baby. You're ready for the REAL JUICE!");

        my @real_juice_buffs = (
            1533,   # Heroism
            488,    # Symbol of Naltron
            145,    # Chloroplast
            1397,   # Strength of Nature
            2524,   # Spirit of Bih`Li
            1580,   # Talisman of the Brute
            1579,   # Talisman of the Cat
            168,    # Talisman of Altuna
            1571,   # Talisman of Shadoo
            1693,   # Clarity II
            175,    # Insight
            412,    # Shield of Lava
            10     # Augmentation
        );

        foreach my $spell_id (@real_juice_buffs) {
            $npc->SpellFinished($spell_id, $client);
        }
        plugin::Whisper("You're drippin'. Now go tear it up!");
        $client->TakeMoneyFromPP(1000000, 1);

    } else {
        plugin::return_items(\%itemcount);  # Return anything else handed in
    }
}

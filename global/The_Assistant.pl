sub EVENT_SAY {
    my $name = $client->GetCleanName();

    # Saylinks
    my $grant_levels  = quest::saylink("Grant Levels", 1);
    my $grant_aa      = quest::saylink("Grant AAs", 1);
    my $max_skills    = quest::saylink("Max Skills", 1);
    my $all_discs     = quest::saylink("All Disciplines", 1);
    my $gear_up       = quest::saylink("Gear Up", 1);
    my $destroy_worn  = quest::saylink("Destroy Worn", 1);
    my $scribe_spells  = quest::saylink("Scribe Spells", 1);

    if ($text =~ /hail/i) {
        plugin::Whisper("Welcome to The Wrath, $name! We're in active development.");
        plugin::Whisper("$grant_levels | $grant_aa | $max_skills | $all_discs | $gear_up | $scribe_spells");
    }

    # Grant Levels
    elsif ($text =~ /grant levels/i) {
        plugin::Whisper("What level do you want to be?");
        plugin::Whisper(join(' ', map { quest::saylink($_, 1) } (10, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65)));
    }
    elsif ($text =~ /^(\d{2})$/ && $text <= 65) {
        $client->SetLevel($1);
        plugin::Whisper("You are now level $1.");
    }

    # Grant AAs
    elsif ($text =~ /grant aas/i) {
        plugin::Whisper("How many AA's do you want?");
        plugin::Whisper(join(' ', map { quest::saylink($_, 1) } (100, 250, 500, 1000, 5000)));
    }
    elsif ($text =~ /^(\d{2,5})$/) {
        my $unspent = $client->GetAAPoints();
        if ($unspent >= 5000) {
            plugin::Whisper("You already have $unspent unspent AAs. Cannot grant more than 5000.");
        } else {
            my $grant = $1;
            $grant = 5000 - $unspent if $unspent + $grant > 5000;
            $client->AddAAPoints($grant);
            plugin::Whisper("Granted $grant AA points. You now have " . ($unspent + $grant) . " unspent AAs.");
        }
    }

    # Max Skills
    elsif ($text =~ /max skills/i) {
        for (my $skill = 0; $skill <= 74; $skill++) {
            $client->SetSkill($skill, $client->MaxSkill($skill));
        }
        plugin::Whisper("All skills maxed for your level.");
    }

    # All Disciplines
    elsif ($text =~ /all disciplines/i) {
        quest::traindiscs($client->GetLevel());
        plugin::Whisper("All disciplines trained.");
    }

    # Gear Up
    elsif ($text =~ /gear up(?: (\d+))?/i) {
        my %expansion_names = (
            0 => "Classic", 1 => "Ruins of Kunark", 2 => "Scars of Velious", 3 => "Shadows of Luclin",
            4 => "Planes of Power", 5 => "Legacy of Ykesha", 6 => "Lost Dungeons of Norrath", 7 => "Gates of Discord",
            8 => "Omens of War", 9 => "Dragons of Norrath", 10 => "Depths of Darkhollow", 11 => "Prophecy of Ro",
            12 => "The Serpent's Spine", 13 => "The Buried Sea", 14 => "Secrets of Faydwer", 15 => "Seeds of Destruction",
            16 => "Underfoot", 17 => "House of Thule", 18 => "Veil of Alaris", 19 => "Rain of Fear",
            20 => "Call of the Forsaken", 21 => "The Darkened Sea", 22 => "The Broken Mirror", 23 => "Empires of Kunark",
            24 => "Ring of Scale", 25 => "The Burning Lands", 26 => "Torment of Velious", 27 => "Claws of Veeshan",
            28 => "Terror of Luclin", 29 => "Night of Shadows"
        );

        my $dbh = plugin::LoadMysql();
        my $class = $client->GetClass();
        my $level = $client->GetLevel();

        if (defined $1) {
            my $expansion = $1;
            my $sth = $dbh->prepare("
                SELECT item_id, slot
                FROM tool_gearup_armor_sets
                WHERE class = ? AND level = ? AND expansion = ?
                ORDER BY score DESC
            ");
            $sth->execute($class, $level, $expansion);

            my %equipped_slots;
            my $count = 0;
            while (my ($item_id, $slot_id) = $sth->fetchrow_array()) {
                next if $equipped_slots{$slot_id}++;
                my $existing = $client->GetItemIDAt($slot_id);
                $client->DeleteItemInInventory($slot_id, 0, true) if $existing;
                $client->SummonItem($item_id, 1);  # Just summon to inventory


                $count++;
            }

            my $label = $expansion_names{$expansion} // "Expansion $expansion";
            plugin::Whisper("You are now geared as $label. ($count items)");
        } else {
            my $sth = $dbh->prepare("
                SELECT DISTINCT expansion
                FROM tool_gearup_armor_sets
                WHERE class = ? AND level = ?
                ORDER BY expansion
            ");
            $sth->execute($class, $level);

            my @expansions;
            while (my ($expansion) = $sth->fetchrow_array()) {
                my $label = $expansion_names{$expansion} // "Expansion $expansion";
                push @expansions, quest::saylink("Gear Up $expansion", 1, $label);
            }

            if (@expansions) {
                plugin::Whisper("Choose Armor by Expansion:");
                plugin::Whisper(join(' | ', @expansions));
            } else {
                plugin::Whisper("No gear found for your level and class.");
            }
        }
    }
    # Auto-Scribe Spells to Player's Level
    elsif ($text =~ /scribe spells/i) {
        quest::scribespells($client->GetLevel(), 0);
        plugin::Whisper("All spells granted up to level " . $client->GetLevel() . ".");
    }
    # --- Destroy Worn ---
    #elsif ($text =~ /destroy worn/i) {
    #    my $count = 0;
    #    for (my $slot = 0; $slot <= 21; $slot++) {
    #        my $item_id = $client->GetItemIDAt($slot);
    #        if ($item_id && $item_id != 0) {
    #            $client->DeleteItemInInventory($slot, 0, true);  # Delete and send client update
    #            $count++;
    #        }
    #    }
    #    plugin::Whisper("? Destroyed $count worn item(s).");
    #    quest::scribespells($client->GetLevel(), 0);  # harmless refresh
    #}


}

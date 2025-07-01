sub EVENT_SPAWN {
    if ($instanceversion > 0) {        
        if ($npc->GetName() =~ /The_Riftwalker/) {
            $npc->Depop(0);
        }
    }

    if ($instanceid) {
        my $expedition = quest::get_expedition();
        if ($expedition) {
            plugin::ScaleInstanceNPC($npc, $expedition->GetMemberCount());
        }
    }
}
sub EVENT_DEATH {
    if (plugin::ZoneHasBonusType($zonesn, 'coin')) {
        # handled server-side
    }
    elsif (plugin::ZoneHasBonusType($zonesn, 'exp')) {
        # handled server-side
    }
    elsif (plugin::ZoneHasBonusType($zonesn, 'empowered')) {
        #handled server-side
    }
    elsif (plugin::ZoneHasBonusType($zonesn, 'respawn')) {
        # handled server-side
    }
    elsif (plugin::ZoneHasBonusType($zonesn, 'loot')) {
        # handled server-side
    }
}

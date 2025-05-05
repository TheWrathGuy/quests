sub EVENT_SPAWN {

    #plugin::CheckSpawnWaypoints();
    
    if ($instanceversion > 0) {        
        if ($npc->GetName() =~ /Agent_of_Change/) {
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
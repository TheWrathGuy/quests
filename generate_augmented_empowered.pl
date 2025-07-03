#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use POSIX qw(ceil);
use JSON;
use Getopt::Long;

# Default configuration
my $new_only = 1;             # Only create new items by default
my $process_Augmented = 1;    # Process Augmented items by default
my $process_Empowered = 1;    # Process Empowered items by default
my $skip_no_stats = 1;        # Skip items with no relevant stats
my $exclude_glamour = 1;      # Exclude glamour items
my $batch_size = 1000;        # Default batch size
my $min_id = undef;           # Minimum item ID to process
my $max_id = undef;           # Maximum item ID to process
my $id_list = "";             # Comma-separated list of specific IDs
my $help = 0;                 # Display help

# Process command line arguments
GetOptions(
    "new-only|n!" => \$new_only,          # Flag to only create new items (negatable with --no-new-only)
    "Augmented|e!" => \$process_Augmented, # Flag to process Augmented items
    "Empowered|l!" => \$process_Empowered, # Flag to process Empowered items
    "skip-no-stats|s!" => \$skip_no_stats, # Flag to skip items with no relevant stats
    "exclude-glamour|g!" => \$exclude_glamour, # Flag to exclude glamour items
    "batch-size|b=i" => \$batch_size,     # Batch size for commits
    "min-id|min=i" => \$min_id,           # Minimum item ID
    "max-id|max=i" => \$max_id,           # Maximum item ID
    "ids|i=s" => \$id_list,               # Specific item IDs
    "help|h" => \$help,                   # Display help
) or die("Error in command line arguments\n");

# Display help if requested
if ($help) {
    print_help();
    exit 0;
}

# Validate arguments
if (!$process_Augmented && !$process_Empowered) {
    die "Error: You must process at least one type (Augmented or Empowered)\n";
}

# Parse ID list if provided
my %specific_ids;
if ($id_list) {
    map { $specific_ids{$_} = 1 } split(/,/, $id_list);
}

sub print_help {
    print <<'HELP';
Item Duplication Script - Creates Augmented and Empowered versions of items

Usage: perl generate_Augmented_Empowered.pl [options]

Options:
  --new-only, -n             Only create new items, don't update existing ones (default: on)
                             Use --no-new-only to also update existing items
  --Augmented, -e            Process Augmented items (default: on)
                             Use --no-Augmented to skip Augmented items
  --Empowered, -l            Process Empowered items (default: on)
                             Use --no-Empowered to skip Empowered items
  --skip-no-stats, -s        Skip items with no relevant stats (default: on)
                             Use --no-skip-no-stats to process all items
  --exclude-glamour, -g      Exclude Glamour items (default: on)
                             Use --no-exclude-glamour to include Glamour items
  --batch-size, -b SIZE      Batch size for commits (default: 1000)
  --min-id, --min MIN        Minimum item ID to process
  --max-id, --max MAX        Maximum item ID to process
  --ids, -i "ID1,ID2,..."    Comma-separated list of specific IDs to process
  --help, -h                 Display this help message

Examples:
  # Process only Augmented items for IDs 1000-2000
  perl generate_Augmented_Empowered.pl --no-Empowered --min-id 1000 --max-id 2000

  # Process only Empowered items for specific IDs
  perl generate_Augmented_Empowered.pl --no-Augmented --ids "1001,1002,1005,1010"

  # Create and update both types of items
  perl generate_Augmented_Empowered.pl --no-new-only
HELP
}

sub LoadMysql {
        use DBI;
        use DBD::mysql;
        use JSON;

        my $json = new JSON();

        #::: Load Config
        my $content;
        open(my $fh, '<', "../eqemu_config.json") or die; {
                local $/;
                $content = <$fh>;
        }
        close($fh);

        #::: Decode
        my $config = $json->decode($content);

        #::: Set MySQL Connection vars
        my $db   = $config->{"server"}{"content_database"}{"db"};
        my $host = $config->{"server"}{"content_database"}{"host"};
        my $user = $config->{"server"}{"content_database"}{"username"};
        my $pass = $config->{"server"}{"content_database"}{"password"};

        #::: Map DSN
        my $dsn = "dbi:mysql:$db:$host:3306";

        #::: Connect and return
        my $connect = DBI->connect($dsn, $user, $pass, {
            mysql_enable_utf8 => 1,
            RaiseError => 1,
            PrintError => 0,
            AutoCommit => 0
        });

        return $connect;
}

# Use the LoadMysql function to get the database handle
my $dbh = LoadMysql();

# Check if successfully connected
unless ($dbh) {
    die "Failed to connect to database.";
}

print "Starting item improvement process...\n";
print "Mode: " . ($new_only ? "New items only" : "Create and update items") . "\n";
print "Processing: " . ($process_Augmented ? "Augmented " : "") . ($process_Empowered ? "Empowered" : "") . "\n";

if ($min_id || $max_id) {
    print "ID Range: " . (defined $min_id ? $min_id : "MIN") . " to " . (defined $max_id ? $max_id : "MAX") . "\n";
}

if ($id_list) {
    print "Processing specific IDs: $id_list\n";
}

# Get the database column names
my $columns_query = $dbh->prepare("SHOW COLUMNS FROM items");
$columns_query->execute();
my @column_names;
while (my $col = $columns_query->fetchrow_hashref()) {
    push @column_names, $col->{Field};
}
$columns_query->finish();

# Counters for tracking progress
my $created_augmented = 0;
my $created_empowered = 0;
my $updated_augmented = 0;
my $updated_empowered = 0;
my $skipped_no_stats = 0;
my $processed = 0;
my $batch_count = 0;

# Process Augmented items if enabled
if ($process_Augmented) {
    process_specific_items('Augmented');
}

# Process Empowered items if enabled
if ($process_Empowered) {
    process_specific_items('Empowered');
}

# Commit any remaining changes
$dbh->commit();

print "\nProcess complete!\n";
print "Processed $processed base items\n";
print "Created $created_augmented Augmented, $created_empowered Empowered\n";
if (!$new_only) {
    print "Updated $updated_augmented Augmented, $updated_empowered Empowered\n";
}
print "Skipped $skipped_no_stats items with no relevant stats\n";
print "Total modified: " . ($created_augmented + $created_empowered + $updated_augmented + $updated_empowered) . " items\n";

$dbh->disconnect();

# Process items for a specific type (Augmented or Empowered)
sub process_specific_items {
    my ($type) = @_;
    my $id_offset = ($type eq 'Augmented') ? 200000 : 400000;

    my $query;

    if ($new_only) {
        # In new item only mode, only get items that don't have the special version
        $query = "
            SELECT base.*,
                   CASE WHEN special.id IS NULL THEN TRUE ELSE FALSE END AS needs_special
            FROM items base
            LEFT JOIN items special ON special.id = base.id + $id_offset
            WHERE base.id < 200000
              AND base.slots > 0
              AND base.classes > 0
              AND base.races > 0
        ";

        # Add ID range conditions if specified
        if (defined $min_id) {
            $query .= " AND base.id >= $min_id";
        }
        if (defined $max_id) {
            $query .= " AND base.id <= $max_id";
        }

        # Add specific IDs condition if provided
        if (%specific_ids) {
            $query .= " AND base.id IN (" . join(",", keys %specific_ids) . ")";
        }

        if ($exclude_glamour) {
            $query .= " AND base.Name NOT LIKE 'Glamour -%'";
        }

        $query .= " HAVING needs_special = TRUE";
    } else {
        # Process all equippable base items when update mode is enabled
        $query = "
            SELECT *
            FROM items
            WHERE id < 200000
              AND slots > 0
              AND classes > 0
              AND races > 0
        ";

        # Add ID range conditions if specified
        if (defined $min_id) {
            $query .= " AND id >= $min_id";
        }
        if (defined $max_id) {
            $query .= " AND id <= $max_id";
        }

        # Add specific IDs condition if provided
        if (%specific_ids) {
            $query .= " AND id IN (" . join(",", keys %specific_ids) . ")";
        }

        if ($exclude_glamour) {
            $query .= " AND Name NOT LIKE 'Glamour -%'";
        }
    }

    my $items = $dbh->prepare($query);
    $items->execute();

    print "Processing items for $type versions...\n";

    # Process each base item
    while (my $base_item = $items->fetchrow_hashref()) {
        my $original_id = $base_item->{id};
        my $original_name = $base_item->{Name};

        # Check if the item has any of the tracked stats (excluding damage)
        if ($skip_no_stats) {
            my $has_tracked_stats = 0;
            foreach my $stat_field (qw(astr adex asta aagi aint awis acha mr fr cr dr pr ac hp mana endur attack healamt spelldmg bardvalue haste regen manaregen enduranceregen shielding spellshield dotshielding dsmitigation damageshield strikethrough accuracy combateffects avoidance stunresist)) {
                if (defined_and_positive($base_item->{$stat_field})) {
                    $has_tracked_stats = 1;
                    last;
                }
            }

            if (!$has_tracked_stats) {
                # Skip items with no tracked stats
                print "Skipping item with no relevant stats: $original_id ($original_name)\n" if $original_id % 100 == 0;
                $skipped_no_stats++;
                $processed++;
                next;
            }
        }

        # Calculate the expected Augmented stats (needed for both types)
        my $Augmented_stats = calculate_Augmented_stats($base_item);

        # Choose which stats to use based on type
        my $stats_to_use;
        if ($type eq 'Augmented') {
            $stats_to_use = $Augmented_stats;
        } else {
            # For Empowered, we need to get the current Augmented stats
            # if they exist, or calculate what they would be
            my $Augmented_id = $original_id + 200000;
            my $existing_Augmented_query = $dbh->prepare("SELECT * FROM items WHERE id = ?");
            $existing_Augmented_query->execute($Augmented_id);
            my $existing_Augmented = $existing_Augmented_query->fetchrow_hashref();
            $existing_Augmented_query->finish();

            # If Augmented item exists, use its actual values
            # otherwise use our calculated values
            my $Augmented_data = $existing_Augmented || { %$base_item, %$Augmented_stats };

            # Calculate Empowered stats based on Augmented stats
            $stats_to_use = calculate_Empowered_stats($base_item, $Augmented_data);
        }

        # Process the special version
        process_special_version($original_id, $original_name, $type, $id_offset, $stats_to_use);

        $processed++;
        $batch_count++;

        # Commit every batch_size items
        if ($batch_count >= $batch_size) {
            $dbh->commit();
            print "\nCommitted batch. Processed $processed items.\n";
            if ($type eq 'Augmented') {
                print "Created $created_augmented Augmented items\n";
                if (!$new_only) {
                    print "Updated $updated_augmented Augmented items\n";
                }
            } else {
                print "Created $created_empowered Empowered items\n";
                if (!$new_only) {
                    print "Updated $updated_empowered Empowered items\n";
                }
            }
            print "Skipped $skipped_no_stats items with no relevant stats\n\n";
            $batch_count = 0;
        }
    }

    $items->finish();
    $dbh->commit();
    print "\nCompleted $type items processing.\n";
}

# Calculate expected stats for Augmented version
sub calculate_Augmented_stats {
    my ($base) = @_;
    my %stats;

    # List of stats to be doubled
    my @double_stats = qw(ac astr adex asta aagi aint awis acha hp mana endur mr fr cr dr pr damage bardvalue);

    # List of stats to preserve (no scaling)
    my @preserve_stats = qw(haste enduranceregen shielding spellshield dotshielding dsmitigation damageshield strikethrough accuracy combateffects avoidance stunresist);

    # List of stats to add 50%
    my @fifty_percent_stats = qw(regen manaregen);

    # Double specific stats, ensuring no negative values (round up)
    foreach my $stat (@double_stats) {
        $stats{$stat} = non_negative($base->{$stat}) ? ceil($base->{$stat} * 2) : 0;
    }

    # Add 50% to specific stats (round up)
    foreach my $stat (@fifty_percent_stats) {
        $stats{$stat} = non_negative($base->{$stat}) ? ceil($base->{$stat} * 1.5) : 0;
    }

    # Preserve stats (copy as is, but ensure non-negative)
    foreach my $stat (@preserve_stats) {
        $stats{$stat} = non_negative($base->{$stat}) ? $base->{$stat} : 0;
    }

    # Set backstabdmg to twice the damage value (only if base item had backstabdmg)
    if (defined $stats{damage} && non_negative($base->{backstabdmg})) {
        $stats{backstabdmg} = $stats{damage} * 2;
    }

    # +25% of each str and dex to attack (post-doubling)
    if (non_negative($base->{attack})) {
        my $str_bonus = non_negative($stats{astr}) ? ceil($stats{astr} * 0.25) : 0;
        my $dex_bonus = non_negative($stats{adex}) ? ceil($stats{adex} * 0.25) : 0;
        $stats{attack} = ceil($base->{attack} * 2) + $str_bonus + $dex_bonus;
    } else {
        $stats{attack} = 0;
    }

    # +50% of int to spelldmg (post-doubling)
    if (non_negative($base->{spelldmg})) {
        my $int_bonus = non_negative($stats{aint}) ? ceil($stats{aint} * 0.5) : 0;
        $stats{spelldmg} = ceil($base->{spelldmg} * 2) + $int_bonus;
    }

    # +50% of wis to healamt (post-doubling)
    if (non_negative($base->{healamt})) {
        my $wis_bonus = non_negative($stats{awis}) ? ceil($stats{awis} * 0.5) : 0;
        $stats{healamt} = ceil($base->{healamt} * 2) + $wis_bonus;
    }

    # +25% of dex to accuracy (post-doubling) - removed per updated rules
    if (non_negative($base->{accuracy})) {
        $stats{accuracy} = $base->{accuracy}; # Preserve original value
    }

    # Adjust proc rate if there's a proc effect
    $stats{procrate} = non_negative($base->{procrate}) ? $base->{procrate} : 0;
    if (non_negative($base->{proceffect}) && $base->{proceffect} > 0) {
        $stats{procrate} += 10;
    }

    return \%stats;
}

# Calculate expected stats for Empowered version
sub calculate_Empowered_stats {
    my ($base, $Augmented) = @_;
    my %stats;

    # Copy all Augmented values first
    foreach my $key (keys %$Augmented) {
        $stats{$key} = $Augmented->{$key};
    }

    # Set ID and name properly (these will be overridden later in process_special_version)
    $stats{id} = $base->{id} + 400000;
    $stats{Name} = $base->{Name} . " (Empowered)";

    # List of stats that need heroic versions set to 25% of Augmented
    my @heroic_stats = (
        ["astr", "heroic_str"],
        ["adex", "heroic_dex"],
        ["asta", "heroic_sta"],
        ["aagi", "heroic_agi"],
        ["aint", "heroic_int"],
        ["awis", "heroic_wis"],
        ["acha", "heroic_cha"],
        ["mr", "heroic_mr"],
        ["fr", "heroic_fr"],
        ["cr", "heroic_cr"],
        ["dr", "heroic_dr"],
        ["pr", "heroic_pr"]
    );

    # Add 25% of base values to heroic stats (round up)
    foreach my $pair (@heroic_stats) {
        my ($normal_stat, $heroic_stat) = @$pair;
        if (non_negative($base->{$normal_stat})) {
            $stats{$heroic_stat} = ceil($base->{$normal_stat} * 0.25);
        } else {
            $stats{$heroic_stat} = 0;
        }
    }

    # List of stats to add additional 50% (double base values)
    my @double_base_stats = qw(regen manaregen);

    # List of stats to preserve from Augmented (no additional scaling)
    my @preserve_stats = qw(haste enduranceregen shielding spellshield dotshielding dsmitigation damageshield strikethrough accuracy combateffects avoidance stunresist);

    # Add another 50% to these stats (round up)
    foreach my $stat (@double_base_stats) {
        if (non_negative($Augmented->{$stat})) {
            $stats{$stat} = ceil($Augmented->{$stat} * 1.5); # already 1.5x base, now 1.5x that = 2.25x base
        } else {
            $stats{$stat} = 0;
        }
    }

    # Preserve these stats from Augmented (which are same as base)
    foreach my $stat (@preserve_stats) {
        $stats{$stat} = non_negative($Augmented->{$stat}) ? $Augmented->{$stat} : 0;
    }

    # Double spelldmg, healamt, attack from Augmented (round up)
    if (non_negative($Augmented->{spelldmg})) {
        $stats{spelldmg} = ceil($Augmented->{spelldmg} * 2);
    }

    if (non_negative($Augmented->{healamt})) {
        $stats{healamt} = ceil($Augmented->{healamt} * 2);
    }

    if (non_negative($Augmented->{attack})) {
        $stats{attack} = ceil($Augmented->{attack} * 2);
    }

    # Set backstabdmg to twice the damage value (only if base item had backstabdmg)
    if (defined $stats{damage} && non_negative($base->{backstabdmg})) {
        $stats{backstabdmg} = $stats{damage} * 2;
    }

    # Triple bardvalue from base
    if (non_negative($base->{bardvalue})) {
        $stats{bardvalue} = ceil($base->{bardvalue} * 3);
    }

    # Adjust proc rate if there's a proc effect
    if (non_negative($base->{proceffect}) && $base->{proceffect} > 0) {
        $stats{procrate} += 10; # +10 additional (on top of the +10 from Augmented)
    }

    return \%stats;
}

# Helper to check if a value is defined and positive
sub defined_and_positive {
    my ($value) = @_;
    return defined($value) && $value ne '' && $value > 0;
}

# Helper to check if a value is defined and non-negative
sub non_negative {
    my ($value) = @_;
    return defined($value) && $value ne '' && $value >= 0;
}

# Process a special version (create or update as needed)
sub process_special_version {
    my ($base_id, $base_name, $type, $id_offset, $expected_stats) = @_;
    my $special_id = $base_id + $id_offset;
    my $special_name = $base_name . " ($type)";

    if ($new_only) {
        # In new item only mode, we can skip checking for existence since our query
        # already filtered for items that don't have special versions

        # Get all the original item details
        my $get_base_stmt = $dbh->prepare("SELECT * FROM items WHERE id = ?");
        $get_base_stmt->execute($base_id);
        my $base_data = $get_base_stmt->fetchrow_hashref();
        $get_base_stmt->finish();

        if ($base_data) {
            # Create a copy with modified details
            my %new_item = %$base_data;
            $new_item{id} = $special_id;
            $new_item{Name} = $special_name;

            # Apply all the expected stats
            foreach my $stat (keys %$expected_stats) {
                $new_item{$stat} = $expected_stats->{$stat};
            }

            # Prepare the INSERT statement with backticks around column names
            my @placeholders;
            my @values;
            my @escaped_columns;

            foreach my $column (@column_names) {
                if (exists $new_item{$column}) {
                    push @escaped_columns, "`$column`";
                    push @placeholders, "?";
                    push @values, $new_item{$column};
                }
            }

            my $insert_sql = "INSERT INTO items (" . join(", ", @escaped_columns) . ") VALUES (" . join(", ", @placeholders) . ")";
            my $insert_stmt = $dbh->prepare($insert_sql);

            $insert_stmt->execute(@values);
            print "Creating $type item: $base_id -> $special_id ($base_name -> $special_name)\n";

            if ($type eq 'Augmented') {
                $created_augmented++;
            } else {
                $created_empowered++;
            }
        }
    } else {
        # Check if the special version exists
        my $check_stmt = $dbh->prepare("SELECT * FROM items WHERE id = ?");
        $check_stmt->execute($special_id);
        my $special_item = $check_stmt->fetchrow_hashref();
        $check_stmt->finish();

        if ($special_item) {
            # Item exists - check if stats need to be updated
            my $updates_needed = 0;
            my %updates;

            # Check each expected stat to see if it needs updating
            foreach my $stat (keys %$expected_stats) {
                # Skip undefined values
                next unless defined $special_item->{$stat};

                # Compare current with expected, update if current is less
                if ($special_item->{$stat} < $expected_stats->{$stat}) {
                    $updates{$stat} = $expected_stats->{$stat};
                    $updates_needed = 1;
                }
            }

            # Update the item if needed
            if ($updates_needed) {
                my @set_clauses;
                my @values;
                my @update_log;

                foreach my $stat (sort keys %updates) {
                    push @set_clauses, "`$stat` = ?";
                    push @values, $updates{$stat};
                    push @update_log, "$stat: $special_item->{$stat} -> $updates{$stat}";
                }

                my $update_sql = "UPDATE items SET " . join(", ", @set_clauses) . " WHERE id = ?";
                push @values, $special_id;

                my $update_stmt = $dbh->prepare($update_sql);
                $update_stmt->execute(@values);

                print "Updating $type item: $base_id -> $special_id ($base_name -> $special_name)\n";
                print "  " . join(", ", @update_log) . "\n";

                if ($type eq 'Augmented') {
                    $updated_augmented++;
                } else {
                    $updated_empowered++;
                }
            }
        } else {
            # Item doesn't exist - create it
            # First get all the original item details
            my $get_base_stmt = $dbh->prepare("SELECT * FROM items WHERE id = ?");
            $get_base_stmt->execute($base_id);
            my $base_data = $get_base_stmt->fetchrow_hashref();
            $get_base_stmt->finish();

            if ($base_data) {
                # Create a copy with modified details
                my %new_item = %$base_data;
                $new_item{id} = $special_id;
                $new_item{Name} = $special_name;

                # Apply all the expected stats
                foreach my $stat (keys %$expected_stats) {
                    $new_item{$stat} = $expected_stats->{$stat};
                }

                # Prepare the INSERT statement with backticks around column names
                my @placeholders;
                my @values;
                my @escaped_columns;

                foreach my $column (@column_names) {
                    if (exists $new_item{$column}) {
                        push @escaped_columns, "`$column`";
                        push @placeholders, "?";
                        push @values, $new_item{$column};
                    }
                }

                my $insert_sql = "INSERT INTO items (" . join(", ", @escaped_columns) . ") VALUES (" . join(", ", @placeholders) . ")";
                my $insert_stmt = $dbh->prepare($insert_sql);

                $insert_stmt->execute(@values);
                print "Creating $type item: $base_id -> $special_id ($base_name -> $special_name)\n";

                if ($type eq 'Augmented') {
                    $created_augmented++;
                } else {
                    $created_empowered++;
                }
            }
        }
    }
}
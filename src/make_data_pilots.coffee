#'use strict';
$exp = exports ? this

$exp.xws.pilot_faction2ship2pilot2obj_dict = {}
for pilot in $exp.basicCardData().pilotsById
    if pilot.points < 99 and pilot.points > 0

        multisection = false

        if pilot.ship == 'CR90 Corvette (Fore)' or pilot.ship == 'CR90 Corvette (Aft)'
            pilot.ship = 'CR90 Corvette'
            multisection = true

        else if pilot.ship == 'Raider-class Corvette (Fore)' or pilot.ship == 'Raider-class Corvette (Aft)'
            pilot.ship = 'Raider-class Corvette'
            multisection = true

        faction_str = $exp.xws.subfaction2faction_dict[pilot.faction]
        faction_key = $exp.xws.canonicalize(faction_str)
        if faction_key not of $exp.xws.pilot_faction2ship2pilot2obj_dict
            $exp.xws.pilot_faction2ship2pilot2obj_dict[faction_key] = {
                name: faction_str,
                ships: {}
            }

        ship_key = $exp.xws.canonicalize(pilot.ship)
        if ship_key not of $exp.xws.pilot_faction2ship2pilot2obj_dict[faction_key].ships
            $exp.xws.pilot_faction2ship2pilot2obj_dict[faction_key].ships[ship_key] = {
                name: pilot.ship,
                subfaction: pilot.faction,
                multisection: multisection,
                pilots: {}
            }

        xpac_str = ''
        if pilot.name == 'Maarek Stele (TIE Defender)'
            xpac_str = '-swx52'
#        else if pilot.name == 'Sabine Wren (Scum)'
#            xpac_str = '-swx56'
        else if pilot.name == 'Poe Dameron (PS9)'
            xpac_str = '-swx57'
        else if pilot.name == 'Han Solo (TFA)'
            xpac_str = '-swx57'
        else if pilot.name == 'Chewbacca (TFA)'
            xpac_str = '-swx57'
        else if pilot.name == 'Sabine Wren (TIE Fighter)'
            xpac_str = '-swx59'

        orig_name = pilot.name
        pilot.name = pilot.name.replace(/\ \(.*\)/, '')

        name_key = $exp.xws.canonicalize(pilot.name, xpac_str)

        if name_key of $exp.xws.pilot_faction2ship2pilot2obj_dict[faction_key].ships[ship_key].pilots
            console.log("# '#{orig_name}' already present as '#{name_key}'")

        $exp.xws.pilot_faction2ship2pilot2obj_dict[faction_key].ships[ship_key].pilots[name_key] = {
            name: pilot.name,
            points: pilot.points,
        }

        if pilot.canonical_name and pilot.canonical_name != name_key
            console.log("# '#{orig_name}': '#{pilot.canonical_name}',")


console.log('(exports ? this).xws ?= {}')
console.log('(exports ? this).xws.pilot_faction2ship2pilot2obj_dict = \\')
console.log(JSON.stringify($exp.xws.pilot_faction2ship2pilot2obj_dict))


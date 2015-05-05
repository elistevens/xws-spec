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

        faction_key = $exp.xws.canonicalize(pilot.faction)
        if faction_key not of $exp.xws.pilot_faction2ship2pilot2obj_dict
            $exp.xws.pilot_faction2ship2pilot2obj_dict[faction_key] = {
                name: pilot.faction,
                ships: {}
            }

        ship_key = $exp.xws.canonicalize(pilot.ship)
        if ship_key not of $exp.xws.pilot_faction2ship2pilot2obj_dict[faction_key].ships
            $exp.xws.pilot_faction2ship2pilot2obj_dict[faction_key].ships[ship_key] = {
                name: pilot.ship,
                multisection: multisection,
                pilots: {}
            }

        if pilot.name == 'Boba Fett (Scum)'
            pilot.name = 'Boba Fett'
        if pilot.name == 'Kath Scarlet (Scum)'
            pilot.name = 'Kath Scarlet'

        name_key = $exp.xws.canonicalize(pilot.name)
        $exp.xws.pilot_faction2ship2pilot2obj_dict[faction_key].ships[ship_key].pilots[name_key] = {
            name: pilot.name,
            points: pilot.points,
        }

console.log('(exports ? this).xws ?= {}')
console.log('(exports ? this).xws.pilot_faction2ship2pilot2obj_dict = ' + JSON.stringify($exp.xws.pilot_faction2ship2pilot2obj_dict))


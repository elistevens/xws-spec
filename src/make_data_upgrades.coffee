#'use strict';
$exp = exports ? this

upgrade_list = $exp.basicCardData().upgradesById

mod_list = $exp.basicCardData().modificationsById
for upgrade in mod_list
    upgrade.slot = 'Modification'
upgrade_list = upgrade_list.concat mod_list

title_list = $exp.basicCardData().titlesById
for upgrade in title_list
    upgrade.slot = 'Title'
upgrade_list = upgrade_list.concat title_list

$exp.xws.upgrade_slot2key2obj_dict = {}
for upgrade in upgrade_list
    if upgrade.points < 99
        if upgrade.slot == 'Elite'
            upgrade.slot = 'Elite Pilot Talent'
        if upgrade.slot == 'Astromech'
            upgrade.slot = 'Astromech Droid'
        if upgrade.slot == 'Salvaged Astromech'
            upgrade.slot = 'Salvaged Astromech Droid'

        if upgrade.name == 'R2-D2 (Crew)'
            upgrade.name = 'R2-D2'
        if upgrade.name == '"Heavy Scyk" Interceptor (Cannon)'
            upgrade.name = '"Heavy Scyk" Interceptor'
        if upgrade.name == '"Heavy Scyk" Interceptor (Missile)'
            upgrade.name = '"Heavy Scyk" Interceptor'
        if upgrade.name == '"Heavy Scyk" Interceptor (Torpedo)'
            upgrade.name = '"Heavy Scyk" Interceptor'

        if upgrade.name == 'Adaptability (+1)'
            upgrade.name = 'Adaptability'
        if upgrade.name == 'Adaptability (-1)'
            upgrade.name = 'Adaptability'


        slot_key = $exp.xws.canonicalize(upgrade.slot)
        if slot_key not of $exp.xws.upgrade_slot2key2obj_dict
            $exp.xws.upgrade_slot2key2obj_dict[slot_key] = {
                name: upgrade.slot
                upgrades: {}
            }
        name_key = $exp.xws.canonicalize(upgrade.name)
        $exp.xws.upgrade_slot2key2obj_dict[slot_key].upgrades[name_key] = {
            name: upgrade.name
            points: upgrade.points
            #slot: upgrade.slot
            #value: "#{slot_key}:#{name_key}"
        }

console.log('(exports ? this).xws ?= {}')
console.log('(exports ? this).xws.upgrade_slot2key2obj_dict = \\')
console.log(JSON.stringify($exp.xws.upgrade_slot2key2obj_dict))
#console.log('(exports ? this).upgrade_slots_list = ' + JSON.stringify($exp.xws.upgrade_slots_list))


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

        xpac_str = ''
        if upgrade.name == 'R2-D2 (Crew)'
            xpac_str = '-swx22'
        else if upgrade.name == 'Millennium Falcon (TFA)'
            xpac_str = '-swx57'
        else if upgrade.name == 'Ghost (Phantom II)'
            xpac_str = '-swx72'

        orig_name = upgrade.name
        upgrade.name = upgrade.name.replace(/\ \(.*\)/, '')

        slot_key = $exp.xws.canonicalize(upgrade.slot)
        if slot_key not of $exp.xws.upgrade_slot2key2obj_dict
            $exp.xws.upgrade_slot2key2obj_dict[slot_key] = {
                name: upgrade.slot
                upgrades: {}
            }
        name_key = $exp.xws.canonicalize(upgrade.name, xpac_str)

        if name_key of $exp.xws.upgrade_slot2key2obj_dict[slot_key].upgrades
            console.log("# '#{orig_name}' already present as '#{name_key}'")

        $exp.xws.upgrade_slot2key2obj_dict[slot_key].upgrades[name_key] = {
            name: upgrade.name
            points: upgrade.points
            #slot: upgrade.slot
            #value: "#{slot_key}:#{name_key}"
        }

        if upgrade.canonical_name and upgrade.canonical_name != name_key
            console.log("# YASB claims '#{orig_name}': '#{upgrade.canonical_name}'; double check which is correct.")

console.log('(exports ? this).xws ?= {}')
console.log('(exports ? this).xws.upgrade_slot2key2obj_dict = \\')
console.log(JSON.stringify($exp.xws.upgrade_slot2key2obj_dict, undefined, 4))
#console.log('(exports ? this).upgrade_slots_list = ' + JSON.stringify($exp.xws.upgrade_slots_list))


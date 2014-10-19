#'use strict';
$exp = exports ? this
$exp.xws ?= {}
$exp.xws.version = '0.2.0'

$exp.xws.canonicalizationExceptions_dict = {
    "Rebel Alliance": "rebels",
    "Galactic Empire": "empire",
    "Scum and Villainy": "scum",

    "Astromech Droid": "amd",
    "Salvaged Astromech Droid": "samd",
    "Elite Pilot Talent": "ept",
    "Modification": "mod"
}

$exp.xws.canonicalize = (name) ->
    if name of $exp.xws.canonicalizationExceptions_dict
        return $exp.xws.canonicalizationExceptions_dict[name]

    return name.toLowerCase().replace(/[^a-z0-9]/g, '')

$exp.xws.checkVersion = (other_str) ->
    other_list = other_str.split('.')
    if other_list.length != 3
        return false

    [oMajor, oMinor, oPatch] = other_list
    [vMajor, vMinor, vPatch] = $exp.xws.version.split('.')

    if vMajor != oMajor
        return false

    if vMinor < oMinor
        return false

    return true


_validateSquadron_upgradeSlot = (slot_key, dirty_obj, prefix, vendor=true) ->
    try
        error_list = []
        clean_list = []
        for upgrade_key, i in dirty_obj or []
            if upgrade_key of $exp.xws.upgrade_slot2key2obj_dict[slot_key].upgrades
                clean_list.push upgrade_key
            else
                error_list.push "#{prefix}[#{i}]: #{upgrade_key} invalid"

        return [clean_list, error_list]
    catch error
        return [null, ["52 #{prefix}: #{error}"]]

_validateSquadron_upgrades = (dirty_obj, prefix, vendor=true) ->
    try
        error_list = []

        clean_obj = {}
        if dirty_obj
            console.log(dirty_obj)
            for slot_key, key2obj_dict of $exp.xws.upgrade_slot2key2obj_dict
                clean_list = []
                if slot_key of dirty_obj
                    [clean_list, error_sublist] = _validateSquadron_upgradeSlot(slot_key, dirty_obj[slot_key], "#{prefix}.#{slot_key}", vendor)

                    if clean_list
                        clean_obj[slot_key] = clean_list
                    if error_sublist
                        error_list = error_list.concat error_sublist

                    delete dirty_obj[slot_key]

            for own dirty_key, dirty_value of dirty_obj
                error_list.push "#{prefix}.upgrades.#{dirty_key}: unrecognized key, value #{dirty_value}"

        return [clean_obj, error_list]
    catch error
        return [null, ["77 #{prefix}: #{error}"]]

_validateSquadron_nameAndUpgrades = (faction_key, ship_key, clean_obj, dirty_obj, prefix, vendor=true) ->
    try
        error_list = []

        if 'vendor' of dirty_obj and vendor
            clean_obj.vendor = dirty_obj.vendor
        delete dirty_obj.vendor
        delete dirty_obj.points

        if not dirty_obj.name or dirty_obj.name not of $exp.xws.pilot_faction2ship2pilot2obj_dict[faction_key].ships[ship_key].pilots
            return [null, ["#{prefix}.name: #{dirty_obj.name}"]]
        clean_obj.name = dirty_obj.name
        delete dirty_obj.name

        [clean_obj.upgrades, error_sublist] = _validateSquadron_upgrades(dirty_obj.upgrades, prefix, vendor)
        error_list = error_list.concat error_sublist
        delete dirty_obj.upgrades

        for own dirty_key, dirty_value of dirty_obj
            error_list.push "#{prefix}.#{dirty_key}: unrecognized key"
            #error_list.push "#{prefix}.#{dirty_key}: unrecognized key, value #{dirty_value}"

        return [clean_obj, error_list]
    catch error
        return [null, ["103 #{prefix}: #{error}"]]

_validateSquadron_pilot = (faction_key, dirty_obj, prefix, vendor=true) ->
    try
        error_list = []
        clean_obj = {}

        if 'vendor' of dirty_obj and vendor
            clean_obj.vendor = dirty_obj.vendor
        delete dirty_obj.vendor
        delete dirty_obj.points

        if not dirty_obj.ship or dirty_obj.ship not of $exp.xws.pilot_faction2ship2pilot2obj_dict[faction_key].ships
            return [null, ["#{prefix}.ship: #{dirty_obj.ship}"]]
        clean_obj.ship = dirty_obj.ship
        delete dirty_obj.ship

        if clean_obj.ship == 'cr90corvette'
            clean_obj.sections = []
            for dirty_section, i in dirty_obj.sections
                [clean_section, error_sublist] = _validateSquadron_nameAndUpgrades(faction_key, clean_obj.ship, {upgrades: []}, dirty_section, "#{prefix}.sections[#{i}]", vendor=true)
                clean_obj.sections.push clean_section
                error_list = error_list.concat error_sublist
        else
            [clean_obj, error_sublist] = _validateSquadron_nameAndUpgrades(faction_key, clean_obj.ship, clean_obj, dirty_obj, prefix, vendor=true)
            error_list = error_list.concat error_sublist


        #if not dirty_obj.name or dirty_obj.name not of $exp.xws.pilot_faction2ship2pilot2obj_dict[faction_key].ships[ship_key].pilots
        #    return [null, ["#{prefix}.name: #{dirty_obj.name}"]]
        #clean_obj.name = dirty_obj.name
        #delete dirty_obj.name
        #
        #[clean_obj.upgrades, suberror_list] = _validateSquadron_upgrades = (dirty_obj.upgrades, prefix, vendor)
        #error_list = error_list.concat error_sublist
        #delete dirty_obj.upgrades
        #
        #for own dirty_key, dirty_value of dirty_obj
        #    error_list.push "#{prefix}.#{dirty_key}: unrecognized key"
        #    #error_list.push "#{prefix}.#{dirty_key}: unrecognized key, value #{dirty_value}"

        return [clean_obj, error_list]
    catch error
        return [null, ["#{prefix}: #{error}"]]


$exp.xws.validateSquadron = (dirty_obj, prefix='squadron', vendor=true) ->
    try
        error_list = []
        clean_obj = {pilots: [], points: 0}

        #for key of ignore
        #    clean_obj[key] = dirty_obj[key]
        #    delete dirty_obj[key]

        if not $exp.xws.checkVersion(dirty_obj.version)
            error_list.push "#{prefix}.version: #{dirty_obj.version} != #{$exp.xws.version}"
        clean_obj.version = $exp.xws.version
        delete dirty_obj.version

        for attr in ['name', 'description', 'vendor']
            if attr of dirty_obj and dirty_obj[attr]
                clean_obj[attr] = dirty_obj[attr]
            delete dirty_obj[attr]
        delete dirty_obj.points

        if not dirty_obj.faction or dirty_obj.faction not of $exp.xws.pilot_faction2ship2pilot2obj_dict
            return [null, ["#{prefix}.faction: #{dirty_obj.faction}"]]
        clean_obj.faction = dirty_obj.faction
        delete dirty_obj.faction

        for pilot_dirty, i in (dirty_obj.pilots or [])
            [pilot_clean, error_sublist] = _validateSquadron_pilot(clean_obj.faction, pilot_dirty, "#{prefix}.pilots[#{i}]", vendor)
            if pilot_clean
                clean_obj.pilots.push pilot_clean
            if error_sublist
                error_list = error_list.concat error_sublist
        delete dirty_obj.pilots

        for own dirty_key, dirty_value of dirty_obj
            error_list.push "#{prefix}.#{dirty_key}: unrecognized key"
            #error_list.push "squadron.#{dirty_key}: unrecognized key, value #{dirty_value}"

        return [clean_obj, error_list]
    catch error
        return [null, ["#{prefix}: #{error}"]]


$exp.xws.computePoints = (squad_obj) ->
    squad_obj.points = 0
    for pilot in squad_obj.pilots
        pilot.points = $exp.xws.pilot_faction2ship2pilot2obj_dict[squad_obj.faction].ships[pilot.ship].pilots[pilot.name].points

        for slot_key, upgrade_list of pilot.upgrades
            for upgrade_key in upgrade_list
                pilot.points += $exp.xws.upgrade_slot2key2obj_dict[slot_key].upgrades[upgrade_key].points

        squad_obj.points += pilot.points

    return squad_obj.points


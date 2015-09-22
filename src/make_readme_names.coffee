#'use strict';
$exp = exports ? this

#console.log('(exports ? this).xws ?= {}')
#console.log('(exports ? this).xws.pilot_faction2ship2pilot2obj_dict = ' + JSON.stringify($exp.xws.pilot_faction2ship2pilot2obj_dict))

name2keyTable = (title, data, col1='Name', col2='Canonical') ->
    console.log("## #{title}")
    console.log("")
    console.log("#{col1} | #{col2}")
    console.log("-----|----------")

    key_list = Object.keys(data)
    key_list.sort()

    for key in key_list
        console.log("#{key} | #{data[key]}")

    console.log("")

key2objnameTable = (title, data) ->
    subdata = {}
    for own key, obj of data
        subdata[obj.name] = key

    name2keyTable(title, subdata)

console.log("""# Canonicalized Names

This is a listing of canonicalized card names for app authors to check their
output against (for all cards released by 14th Oct 2014).

Implementation authors should not rely on this listing to be updated promptly
upon the release of new content. It is intended to be a useful check of an
implementation's canonicalization routines.

This information is also provided as part of the `xws-spec` bower package. See
the `window.xws.pilot_faction2ship2pilot2obj_dict` and
`window.xws.upgrade_slot2key2obj_dict` variables.

""")

name2keyTable('Subfactions and Factions', $exp.xws.subfaction2faction_dict, 'Subfaction', 'Faction')
name2keyTable('Canonicalization Special Cases', $exp.xws.canonicalizationExceptions_dict)

key2objnameTable('Upgrade Slots', $exp.xws.upgrade_slot2key2obj_dict)

slot_list = Object.keys($exp.xws.upgrade_slot2key2obj_dict)
slot_list.sort()
for slot_key in slot_list
    slot_obj = $exp.xws.upgrade_slot2key2obj_dict[slot_key]
    key2objnameTable("#{slot_obj.name} Upgrades", slot_obj.upgrades)


key2objnameTable('Factions', $exp.xws.pilot_faction2ship2pilot2obj_dict)

faction_list = Object.keys($exp.xws.pilot_faction2ship2pilot2obj_dict)
faction_list.sort()

for faction_key in faction_list
    faction_obj = $exp.xws.pilot_faction2ship2pilot2obj_dict[faction_key]

    key2objnameTable("#{faction_obj.name} Ships", faction_obj.ships)

    ship_list = Object.keys(faction_obj.ships)
    ship_list.sort()

    for ship_key in ship_list
        ship_obj = faction_obj.ships[ship_key]

        key2objnameTable("#{faction_obj.name} #{ship_obj.name} Pilots", ship_obj.pilots)

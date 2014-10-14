*This is version 0.1.1 of this document.*

In order to move squadrons from one app to another, we need a common format. Hereâ€™s what it should achieve and how it should work:

####Aims
* To allow users to move a squadron from one squadron building app to another, easily
* To allow users to share a squadron without dictating how it should be viewed
* To backup multiple squadrons without being tied to a specific app to restore them
* To be future-proof
* To be human-readable
* To be human-writeable (with just a text editor)

####Versioning
This spec SHALL have a version number. 

Future versions of this specification will increment the version number according to
http://semver.org/ . 

The version number SHALL NOT be used to indicate which content releases have been announced and/or are supported by the producing implementation. 

The version number SHALL be incremented when FFG releases errata that changes the point cost of any pilots or cards.

####Single Squadron Data Format (X-Wing Squadron Format or .XWS)

A "squadron" is a single dictionary.

The "squadron" MUST contain the following:
* A faction ID with the key "faction"
* An array of pilots with the key "pilots" (see below). A squadron MUST have at least one pilot.

The "squadron" MAY contain the following:
* A squadron name with the key "name"
* A squadron description with the key "description"
* The point total for the *squadron* with the key "points". Note that this MUST NOT be used when importing; it is just for readability and convenience.
* A "vendor" property, under which an dictionary of app-specific data can be stored. Each vendor should use a key specific to their app to contain their data, eg. "voidstate". 
* If a "squadron"-level vendor property is added, some properties keys are reserved for specific data.
  * The key "link" should contain a link back to the original squadron. 
  * The key "builder" should contain the name of the original squadron builder app.
  * The key "builder_link" should contain a link to the original squadron builder app. 
  
A "pilot" MUST contain:
* A unique ID for the pilot with the key "name"
* A unique ID for the ship with the key "ship"
  
A "pilot" MAY contain:
* A point values for a *pilot* with the key "points". This is the total point value, after upgrades. As with squadrons, these are only for convenience, apps MUST ignore them when importing.
* A dictionary of upgrades with the key "upgrades", each with:
  * A key identifying the type of upgrade, eg. "crew", "missile", "torpedo", etc.
  * A value which is an array of unique IDs for each upgrade of that type, eg. "pushthelimit", "outmaneuver", etc.
* A dictionary of app-specific data with the key "vendor". Each vendor should use a key specific to their app, eg. "voidstate". 
 
######Vendor Property Special Considerations
After importing a squadron, an app MUST remove all vendor properties before exporting again. This is to prevent obsolete data being exported.

####Multiple Squadron Container (X-Wing Squadron Container Format or .XWC)
Using this format, multiple squadrons can be stored together, as an array wrapped in a dictionary. 

The top level MUST be a dictionary with a single key of "collection". This allows the type of data-structure to be easily detected programmatically ands avoids security vulnerabilities related to top-level arrays in JSON. 

The value MUST BE array of "squadron" level dictionaries as defined above.

Each squadron MUST obey the rules for Single Squadron Data Formats, above.

####Unique IDs
As new ships, pilots, upgrades and other cards are added, it would be best if their IDs could be generated without further discussion between developers. The best solution is to canonicalize the card names, taking into account some cards share the same name (eg. Chewbacca as pilot and as crew, R2-D2 as astromech and as crew, etc.)

####Requirements for App Developers
Apps that provide the ability to import squadrons in these formats should also provide the ability to export them.

######Import failures
When encountering a canonicalized name that is not recognized, an implementation MAY reject the input with an error, silently drop the unrecognized portions of the input, preserve the unrecognized data, or behave in some other manner consistent with the purpose of the application. It is recommended that apps ignore unrecognised data where possible.

Implementations SHOULD provide an indication that the data might have changed on import, when feasible.

Note: Some builders may include unreleased cards, where the canonical name is not known. Their export would be valid if re-imported into the original app but may fail elsewhere.

######Importing might take the form of:
* A form containing a textarea where users can paste the JSON and the app will parse it and load that squadron.
* A file uploader that will accept .XWS and .XWC files
* An API endpoint which would receive a squadron in this format, parse and display it. 

######Exporting might take the form of:
* A button to download a text file containing one or multiple squadrons
* A button for exporting a squadron directly to a different app. So, you'd click "export to Voidstate", for example, which would generate the JSON version of the squadron, POST it to an API endpoint (eg. http://xwing-builder.co.uk/import), where the app would parse the JSON and reload the page with the squadron builder populated with that squadron

######Checking should also be implemented by the app importing a squadron, including ensuring that:
* Point totals are correct
* There are no illegal upgrades
* Factions are not mixed

####Technical Spec. for the Format

######Data Format
Both formats will use JSON. It is lightweight, well-supported and easy to edit by hand.

######MIME Type
application/json or text/plain

######Encoding
UTF-8

######File Extension
Single squadron: .XWS 

Container (multiple squadrons): .XWC 

######Canonicalization Rules
1.	Take the English-language name as printed on the card 
2. Convert non-ASCII characters to closest ASCII equivalent (to remove umlauts, etc.)
3.	Remove non-alphanumeric characters
4.	Lowercase it
	
######Canonicalization Special Cases
The following factions and card names are abbreviated to reduce the data length.

Key | Canonicalization
----|-----
"Rebel Alliance" |	"rebels"
"Galactic Empire" |	"empire",
"Scum and Villainy" |	"scum",
-|-
"Astromech Droid" |	"amd",
"Salvaged Astromech Droid" |	"samd",
"Elite Pilot Talent" |	"ept",
"Modification" |	"mod"

####Sample XWS Data Structure
This sample shows a build with lots of upgrades, some added dynamically by other upgrades (A-Wing Test Pilot). It includes all required and optional data as well as vendor data at both top level and squadron level.

```json
{
    "name": "2 A-Wings, 2 X-Wings",
    "faction": "rebels",
    "points": 100,
    "version": "0.1.0",
    "description": "Tycho leads a flight",
    "pilots": [
        {
            "name": "tychocelchu",
            "ship": "awing",
            "upgrades": {
                "title": [
                    "awingtestpilot"
                ],
                "missile": [
                    "chardaanrefit"
                ],
                "ept": [
                    "pushthelimit",
                    "experthandling"
                ],
                "modification": [
                    "experimentalinterface"
                ]
            },
            "vendor": {
                "voidstate": {
                    "pilot_id": 30
                }
            }
        },
        {
            "name": "rookiepilot",
            "ship": "xwing",
            "upgrades": {
                "amd": [
                    "r2astromech"
                ]
            },
            "vendor": {
                "voidstate": {
                    "pilot_id": 14
                }
            }
        },
        {
            "name": "rookiepilot",
            "ship": "xwing",
            "upgrades": {
                "amd": [
                    "r2astromech"
                ]
            },
            "vendor": {
                "voidstate": {
                    "pilot_id": 14
                }
            }
        },
        {
            "name": "greensquadronpilot",
            "ship": "awing",
            "upgrades": {
                "title": [
                    "awingtestpilot"
                ],
                "missile": [
                    "chardaanrefit"
                ],
                "ept": [
                    "elusiveness",
                    "experthandling"
                ],
                "mod": [
                    "stealthdevice"
                ]
            },
            "vendor": {
                "voidstate": {
                    "pilot_id": 33
                }
            }
        }
    ],
    "vendor": {
        "voidstate": {
            "squadron_id": 2498,
            "link": "http\/\/xwing-builder.co.uk\/view\/2498\/2-a-wings-2-x-wings",
            "builder": "Voidstate's Unofficial X-Wing Squadron Builder",
            "builder_link": "http\/\/xwing-builder.co.uk\/build"
        }
    }
}
```

####Data Structure

######Top-level Dictionary Keys

Key | Notes
----|-----
name |	Squadron name. Optional. String.  
points | Total points spent. Optional. Integer. 
faction | Faction (string). Possible values: â€œrebelsâ€, â€œempireâ€, â€œscumâ€.	Required. String.
description | Text description or notes on the squadron.	Optional. String.
pilots | An array of pilots. See below.	Required. Array.
vendor | A dictionary of vendors, each with their own dictionary of app-specific data.	Optional. Dictionary.

######Pilot-level Dictionary Keys

Key | Notes
----|-----
name | Pilot name.	Required. String.
ship | Pilot ship. Required. String.
upgrades | Upgrade cards for this pilot. A dictionary where each key is a type of upgrade and contains an array of upgrades of that type. Optional. Dictionary.
points | Total points spent, including upgrades.	Optional. Integer.
vendor | A dictionary of vendors, each with their own dictionary of app-specific data.	Optional. Dictionary.

######Vendor-level Dictionary Keys

Key | Notes
----|-----
link | Web link to view this squadron. Optional. String.
builder | Name of the squadron builder used to generate the squadron. Optional. String.
builder_link | Link to the squadron builder used to generate the squadron. Optional. String.
... | Other properties can be added here as required

####Canonicalized Names
A full list of canonicalized card names for app authors to check their output against (for all cards released by 14th Oct 2014).

######Upgrade Types
 
Name | Canonical
----|-----
Astromech Droid | amd (special case)
Bomb/Mine | bombmine
Cannon | cannon
Cargo | cargo
Crew | crew
Elite Pilot Talent | ept (special case)
Hardpoint | hardpoint
Illicit | illicit
Missile | missile
Modification | mod (special case)
Salvaged Astromech Droid | samd (special case)
System Upgrade | systemupgrade
Team | team
Title | title
Torpedo | torpedo
Turret Weapon | turretweapon

######Pilots

Name | Canonical
----|-----
"Echo" | echo
"Hobbie" Klivian | hobbieklivian
"Leebo" | leebo
"Whisper" | whisper
"Dutch" Vander | dutchvander
"Fel's Wrath" | felswrath
Academy Pilot | academypilot
Airen Cracken | airencracken
Alpha Squadron Pilot | alphasquadronpilot
Arvel Crynyd | arvelcrynyd
Avenger Squadron Pilot | avengersquadronpilot
Backstabber | backstabber
Bandit Squadron Pilot | banditsquadronpilot
Biggs Darklighter | biggsdarklighter
Binayre Pirate | binayrepirate
Black Squadron Pilot | blacksquadronpilot
Blackmoon Squadron Pilot | blackmoonsquadronpilot
Blue Squadron Pilot | bluesquadronpilot
Boba Fett | bobafett
Boba Fett | bobafett
Bounty Hunter | bountyhunter
Captain Jonus | captainjonus
Captain Kagi | captainkagi
Captain Oicunn | captainoicunn
Captain Yorr | captainyorr
Carnor Jax | carnorjax
Chewbacca | chewbacca
Colonel Jendon | coloneljendon
Colonel Vessery | colonelvessery
Commander Kenkirk | commanderkenkirk
Corran Horn | corranhorn
CR90 Corvette (Aft) | cr90corvetteaft
CR90 Corvette (Fore) | cr90corvettefore
Dagger Squadron Pilot | daggersquadronpilot
Dark Curse | darkcurse
Darth Vader | darthvader
Dash Rendar | dashrendar
Delta Squadron Pilot | deltasquadronpilot
Eaden Vrill | eadenvrill
Etahn A"baht | etahnabaht
Gamma Squadron Pilot | gammasquadronpilot
Garven Dreis | garvendreis
Gemmer Sojan | gemmersojan
Gold Squadron Pilot | goldsquadronpilot
GR-75 Medium Transport | gr75mediumtransport
Green Squadron Pilot | greensquadronpilot
Grey Squadron Pilot | greysquadronpilot
Han Solo | hansolo
Horton Salm | hortonsalm
Howlrunner | howlrunner
Ibtisam | ibtisam
IG88-D | ig88d
Jake Farrell | jakefarrell
Jan Ors | janors
Jek Porkins | jekporkins
Kath Scarlet | kathscarlet
Keyan Farlander | keyanfarlander
Kir Kanos | kirkanos
Knave Squadron Pilot | knavesquadronpilot
Krassis Trelix | krassistrelix
Kyle Katarn | kylekatarn
Lando Calrissian | landocalrissian
Lieutenant Blount | lieutenantblount
Lieutenant Lorrir | lieutenantlorrir
Luke Skywalker | lukeskywalker
Maarek Stele | maarekstele
Major Rhymer | majorrhymer
Mauler Mithel | maulermithel
N'Dru Suhlak | ndrusuhlak
Nera Dantels | neradantels
Night Beast | nightbeast
Obsidian Squadron Pilot | obsidiansquadronpilot
Omicron Group Pilot | omicrongrouppilot
Onyx Squadron Pilot | onyxsquadronpilot
Outer Rim Smuggler | outerrimsmuggler
Patrol Leader | patrolleader
Prince Xizor | princexizor
Prototype Pilot | prototypepilot
Rear Admiral Chiraneau | rearadmiralchiraneau
Rebel Operative | rebeloperative
Red Squadron Pilot | redsquadronpilot
Rexler Brath | rexlerbrath
Roark Garnet | roarkgarnet
Rookie Pilot | rookiepilot
Royal Guard Pilot | royalguardpilot
Saber Squadron Pilot | sabersquadronpilot
Scimitar Squadron Pilot | scimitarsquadronpilot
Serissu | serissu
Shadow Squadron Pilot | shadowsquadronpilot
Sigma Squadron Pilot | sigmasquadronpilot
Soontir Fel | soontirfel
Storm Squadron Pilot | stormsquadronpilot
Tala Squadron Pilot | talasquadronpilot
Tarn Mison | tarnmison
Tempest Squadron Pilot | tempestsquadronpilot
Ten Numb | tennumb
Tetran Cowell | tetrancowell
Turr Phennir | turrphennir
Tycho Celchu | tychocelchu
Wedge Antilles | wedgeantilles
Wes Janson | wesjanson
Wild Space Fringer | wildspacefringer
Winged Gundark | wingedgundark

######Ship Types 

Name | Canonical
----|-----
A-Wing | awing
Aggressor | aggressor
B-Wing | bwing
CR90 Corvette | cr90corvette
E-Wing | ewing
Firespray-31 | firespray31
GR-75 Medium Transport | gr75mediumtransport
HWK-290 | hwk290
Lambda-Class Shuttle | lambdaclassshuttle
M3-A "Scyk" Interceptor | m3ascykinterceptor
StarViper | starviper
TIE Advanced | tieadvanced
TIE Bomber | tiebomber
TIE Defender | tiedefender
TIE Fighter | tiefighter
TIE Interceptor | tieinterceptor
TIE Phantom | tiephantom
VT-49 Decimator | vt49decimator
X-Wing | xwing
Y-Wing | ywing
YT-1300 | yt1300
YT-2400 Freighter | yt2400freighter
Z-95 Headhunter | z95headhunter

######Astromechs 

Name | Canonical
----|-----
R2 Astromech | r2astromech
R2-D2 | r2d2
R2-D6 | r2d6
R2-F2 | r2f2
R3-A2 | r3a2
R4-D6 | r4d6
R5 Astromech | r5astromech
R5-D8 | r5d8
R5-K6 | r5k6
R5-P9 | r5p9
R7 Astromech | r7astromech
R7-T1 | r7t1

######Bombs 

Name | Canonical
----|-----
Proton Bombs | protonbombs
Proximity Mines | proximitymines
Seismic Charges | seismiccharges

######Cannons 

Name | Canonical
----|-----
Autoblaster | autoblaster
Heavy Laser Cannon | heavylasercannon
Ion Cannon | ioncannon

######Cargo 

Name | Canonical
----|-----
Backup Shield Generator | backupshieldgenerator
Comms Booster | commsbooster
EM Emitter | ememitter
Engine Booster | enginebooster
Expanded Cargo Hold | expandedcargohold
Frequency Jammer | frequencyjammer
Ionization Reactor | ionizationreactor
Shield Projector | shieldprojector
Slicer Tools | slicertools
Tibanna Gas Supplies | tibannagassupplies

######Crew 

Name | Canonical
----|-----
"Leebo" | leebo
C-3PO | c3po
Carlist Rieekan | carlistrieekan
Chewbacca | chewbacca
Darth Vader | darthvader
Dash Rendar | dashrendar
Fleet Officer | fleetofficer
Flight Instructor | flightinstructor
Greedo | greedo
Gunner | gunner
Han Solo | hansolo
Intelligence Agent | intelligenceagent
Jan Dodonna | jandodonna
Jan Ors | janors
Kyle Katarn | kylekatarn
Lando Calrissian | landocalrissian
Leia Organa | leiaorgana
Luke Skywalker | lukeskywalker
Mara Jade | marajade
Mercenary Copilot | mercenarycopilot
Moff Jerjerrod | moffjerjerrod
Navigator | navigator
Nien Nunb | niennunb
R2-D2 | r2d2
Raymus Antilles | raymusantilles
Rebel Captive | rebelcaptive
Recon Specialist | reconspecialist
Saboteur | saboteur
Tactician | tactician
Targeting Coordinator | targetingcoordinator
Toryn Farr | torynfarr
Weapons Engineer  | weaponsengineer
WED-15 Repair Droid | wed15repairdroid
Ysanne Isard | ysanneisard

######Elite Pilot Talents 

Name | Canonical
----|-----
Adrenaline Rush | adrenalinerush
Daredevil | daredevil
Deadeye | deadeye
Decoy | decoy
Determination | determination
Draw Their Fire | drawtheirfire
Elusiveness | elusiveness
Expert Handling | experthandling
Expose | expose
Intimidation | intimidation
Lone Wolf | lonewolf
Marksmanship | marksmanship
Opportunist | opportunist
Outmaneuver | outmaneuver
Predator | predator
Push the Limit | pushthelimit
Ruthlessness | ruthlessness
Squad Leader | squadleader
Stay on Target | stayontarget
Swarm Tactics | swarmtactics
Veteran Instincts | veteraninstincts
Wingman | wingman

######Hardpoints 

Name | Canonical
----|-----
Quad Laser Cannons | quadlasercannons
Single Turbolasers | singleturbolasers

######Illicits 

Name | Canonical
----|-----
"Hot Shot" Blaster | hotshotblaster
Dead Man's Switch | deadmansswitch
Feedback Array | feedbackarray
Inertial Dampeners | inertialdampeners

######Missiles 

Name | Canonical
----|-----
Assault Missiles | assaultmissiles
Chardaan Refit | chardaanrefit
Cluster Missiles | clustermissiles
Concussion Missiles | concussionmissiles
Homing Missiles | homingmissiles
Ion Pulse Missiles | ionpulsemissiles
Proton Rockets | protonrockets

######Modifications 

Name | Canonical
----|-----
Advanced Cloaking Device | advancedcloakingdevice
Anti-Pursuit Lasers | antipursuitlasers
B-Wing/E2 | bwinge2
Combat Retrofit | combatretrofit
Counter-Measures | countermeasures
Engine Upgrade | engineupgrade
Experimental Interface | experimentalinterface
Hull Upgrade | hullupgrade
Munitions Failsafe | munitionsfailsafe
Shield Upgrade | shieldupgrade
Stealth Device | stealthdevice
Stygium Particle Accelerator | stygiumparticleaccelerator
Tactical Jammer | tacticaljammer
Targeting Computer | targetingcomputer

######Pilots 

Name | Canonical
----|-----
"Echo" | echo
"Hobbie" Klivian | hobbieklivian
"Leebo" | leebo
"Whisper" | whisper
"Dutch" Vander | dutchvander
"Fel's Wrath" | felswrath
Academy Pilot | academypilot
Airen Cracken | airencracken
Alpha Squadron Pilot | alphasquadronpilot
Arvel Crynyd | arvelcrynyd
Avenger Squadron Pilot | avengersquadronpilot
Backstabber | backstabber
Bandit Squadron Pilot | banditsquadronpilot
Biggs Darklighter | biggsdarklighter
Binayre Pirate | binayrepirate
Black Squadron Pilot | blacksquadronpilot
Blackmoon Squadron Pilot | blackmoonsquadronpilot
Blue Squadron Pilot | bluesquadronpilot
Boba Fett | bobafett
Boba Fett | bobafett
Bounty Hunter | bountyhunter
Captain Jonus | captainjonus
Captain Kagi | captainkagi
Captain Oicunn | captainoicunn
Captain Yorr | captainyorr
Carnor Jax | carnorjax
Chewbacca | chewbacca
Colonel Jendon | coloneljendon
Colonel Vessery | colonelvessery
Commander Kenkirk | commanderkenkirk
Corran Horn | corranhorn
CR90 Corvette (Aft) | cr90corvetteaft
CR90 Corvette (Fore) | cr90corvettefore
Dagger Squadron Pilot | daggersquadronpilot
Dark Curse | darkcurse
Darth Vader | darthvader
Dash Rendar | dashrendar
Delta Squadron Pilot | deltasquadronpilot
Eaden Vrill | eadenvrill
Etahn A"baht | etahnabaht
Gamma Squadron Pilot | gammasquadronpilot
Garven Dreis | garvendreis
Gemmer Sojan | gemmersojan
Gold Squadron Pilot | goldsquadronpilot
GR-75 Medium Transport | gr75mediumtransport
Green Squadron Pilot | greensquadronpilot
Grey Squadron Pilot | greysquadronpilot
Han Solo | hansolo
Horton Salm | hortonsalm
Howlrunner | howlrunner
Ibtisam | ibtisam
IG88-D | ig88d
Jake Farrell | jakefarrell
Jan Ors | janors
Jek Porkins | jekporkins
Kath Scarlet | kathscarlet
Keyan Farlander | keyanfarlander
Kir Kanos | kirkanos
Knave Squadron Pilot | knavesquadronpilot
Krassis Trelix | krassistrelix
Kyle Katarn | kylekatarn
Lando Calrissian | landocalrissian
Lieutenant Blount | lieutenantblount
Lieutenant Lorrir | lieutenantlorrir
Luke Skywalker | lukeskywalker
Maarek Stele | maarekstele
Major Rhymer | majorrhymer
Mauler Mithel | maulermithel
N'Dru Suhlak | ndrusuhlak
Nera Dantels | neradantels
Night Beast | nightbeast
Obsidian Squadron Pilot | obsidiansquadronpilot
Omicron Group Pilot | omicrongrouppilot
Onyx Squadron Pilot | onyxsquadronpilot
Outer Rim Smuggler | outerrimsmuggler
Patrol Leader | patrolleader
Prince Xizor | princexizor
Prototype Pilot | prototypepilot
Rear Admiral Chiraneau | rearadmiralchiraneau
Rebel Operative | rebeloperative
Red Squadron Pilot | redsquadronpilot
Rexler Brath | rexlerbrath
Roark Garnet | roarkgarnet
Rookie Pilot | rookiepilot
Royal Guard Pilot | royalguardpilot
Saber Squadron Pilot | sabersquadronpilot
Scimitar Squadron Pilot | scimitarsquadronpilot
Serissu | serissu
Shadow Squadron Pilot | shadowsquadronpilot
Sigma Squadron Pilot | sigmasquadronpilot
Soontir Fel | soontirfel
Storm Squadron Pilot | stormsquadronpilot
Tala Squadron Pilot | talasquadronpilot
Tarn Mison | tarnmison
Tempest Squadron Pilot | tempestsquadronpilot
Ten Numb | tennumb
Tetran Cowell | tetrancowell
Turr Phennir | turrphennir
Tycho Celchu | tychocelchu
Wedge Antilles | wedgeantilles
Wes Janson | wesjanson
Wild Space Fringer | wildspacefringer
Winged Gundark | wingedgundark

######Ship Types 

Name | Canonical
----|-----
A-Wing | awing
Aggressor | aggressor
B-Wing | bwing
CR90 Corvette | cr90corvette
E-Wing | ewing
Firespray-31 | firespray31
GR-75 Medium Transport | gr75mediumtransport
HWK-290 | hwk290
Lambda-Class Shuttle | lambdaclassshuttle
M3-A "Scyk" Interceptor | m3ascykinterceptor
StarViper | starviper
TIE Advanced | tieadvanced
TIE Bomber | tiebomber
TIE Defender | tiedefender
TIE Fighter | tiefighter
TIE Interceptor | tieinterceptor
TIE Phantom | tiephantom
VT-49 Decimator | vt49decimator
X-Wing | xwing
Y-Wing | ywing
YT-1300 | yt1300
YT-2400 Freighter | yt2400freighter
Z-95 Headhunter | z95headhunter

######Systems 

Name | Canonical
----|-----
Accuracy Corrector | accuracycorrector
Advanced Sensors | advancedsensors
Enhanced Scopes | enhancedscopes
Fire-Control System | firecontrolsystem
Sensor Jammer | sensorjammer

######Teams 

Name | Canonical
----|-----
Engineering Team | engineeringteam
Gunnery Team | gunneryteam
Sensor Team | sensorteam

######Torpedoes 

Name | Canonical
----|-----
Advanced Proton Torpedoes | advancedprotontorpedoes
Flechette Torpedoes | flechettetorpedoes
Ion Torpedoes | iontorpedoes
Proton Torpedoes | protontorpedoes

######Turrets 

Name | Canonical
----|-----
Blaster Turret | blasterturret
Ion Cannon Turret | ioncannonturret

####Validation
Implementations MAY use the following JSON schema to validate XWS data. More on JSON schemas can be fond here: http://json-schema.org

```json
{
	"$schema": "http://json-schema.org/draft-04/schema#",
	"title": "X-Wing Squadron Format Schema",
	"description": "A squadron for the X-Wing Miniatures Game in app-independent format for sharing, saving and moving between apps.",
	"type": "object",
	"required": ["version","faction","pilots"],
	"additionalProperties" : false,
	"properties": {
		"version": {
			"type": "string",
			"pattern" : "^[0-9]+\.[0-9]+\.[0-9]+$",
			"description": "The version of the XWS spec used to create this data"
		},
		"name": {
			"type": "string",
			"description": "The name of the squadron."
		},
		"points": {
			"type": "integer",
			"description": "The total points spent creating this squadron."
		},
		"faction": {
			"type": "string",
			"enum": [ "rebels", "empire", "scum" ],
			"description": "The faction this squadron belongs to."
		},
		"description": {
			"type": "string",
			"description": "A description of this squadron."
		},
		"pilots": {
			"type": "array",
			"description": "The members of this squadron.",
            "items": {
                "type": "object",
                "required": ["name","ship"],
                "additionalProperties" : false,
                "properties": {
                    "name": {
	                    "type": "string",
	                    "pattern" : "^[0-9a-z]+$"
		            },
                    "ship": {
	                    "type": "string",
	                    "pattern" : "^[0-9a-z]+$"
		            },
                    "upgrades": {
	                    "type": "object",
	                    "additionalProperties": false,
	                    "minProperties": 1,
	                    "patternProperties": {
	                        "^[0-9a-z]+$": {
								"type": "array",
								"minItems": 1,
								"items": {
									"type": "string",
									"pattern" : "^[0-9a-z]+$"
		                    	}
	                        }
	                    }
		             },
		             "vendor": {
		            	"type": "object",
		     			"minProperties": 1,
		     			"maxProperties": 1,
		     			"description": "An extensible object containing app-specific data. Developers should put extra data here under their own namespace."
		             }
                }
            }
		},
		"vendor": {
			"type": "object",
			"minProperties": 1,
			"maxProperties": 1,
			"description": "An extensible object containing app-specific data. Developers should put extra data here under their own namespace."
		}
	}
}
```

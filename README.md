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
* Points values for a *pilot* with the key "points". This is the total point value, after upgrades. Again, these are only for convenience, apps MUST ignore them when importing.
* A "vendor" property, under which an dictionary of app-specific data can be stored. Each vendor should use a key specific to their app to contain their data, eg. "voidstate". 
* If a "squadron"-level vendor property is added, some properties keys are reserved for specific data.
  * The key "link" should contain a link back to the original squadron. 
  * The key "builder" should contain the name of the original squadron builder app.
  * The key "builder_link" should contain a link to the original squadron builder app. 
  
A "pilot" MUST contain:
* A unique ID for the pilot with the key "name"
* A unique ID for the ship with the key "ship"
  
A "pilot" MAY contain:
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
A selection of canonicalized card names for app authors to check their output agains.

######Upgrades
amd ( special case for astromech droid)  
bomb  
cannon  
cargo  
crew  
ept (special case for elitepilottalent)  
hardpoint  
illicit  
missile  
mod (special case for modification)  
samd (special case for salvaged astromech droid)  
system  
team  
title  
torpedo  
turret

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

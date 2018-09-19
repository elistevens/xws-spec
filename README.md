# X-Wing Squadron Specification version 2.0.0

This specification facilitates the export and subsequent import of squadrons for
FFG's X-Wing Miniatures game from one compliant application to another.

## Goals
* Allow users to easily move a squadron from one squadron building app to another
* Allow users to share a squadron without dictating how it should be viewed
* Back up squadrons without being tied to a specific app to restore them
* Be future-proof
* Be human-readable


## Single Squadron Data Format (X-Wing Squadron Format or .XWS)
A container can be represented as a stand-alone JSON file encoded in UTF-8 with
either an .xws or a .json extension. MIME types of application/json or
text/plain SHOULD be accepted by API endpoints.

A squadron is generally a single player's list used for an X-Wing Miniatures
match.

Note that no assertion of tournament-legality is made for a squadron represented
in this format. While the specification targets tournament legal lists
(single-faction, points and pilots as printed, etc.), there are some rules of
list construction that are not enforced by this specification (point totals,
pilots having the required upgrade slots for an upgrade card, etc.).

Importing implementations MUST perform validation before making assumptions
about the appropriate nature of a list for any given purpose.


### Squadron Attributes
Requirement | Key | Type | Notes
---|---|---|---
Mandatory | faction | String | Canonicalized faction name; see below. 
Mandatory | pilots | Array | List of one or more pilots; see below.
 | | |
Optional | name | String | Human-readable squadron name.
Optional | description | String | Text description or notes for the squadron.
Optional | obstacles | Array | Array of three Strings, each being an identifier for the obstacle chosen for tournament use.
Optional | points | Integer | Total point cost of the squadron. SHOULD be ignored by importing applications unless the XWS source is trusted.
 | | |
Ignored | vendor | Dictionary | An object used to store vendor-specific data; see above.

In situations where the type of data being imported is not known, a squadron
data structure can be identified by the mandatory `faction` and `pilots` keys.

Possible values for the faction key include: `rebelalliance`, `galacticempire`, `scumandvillainy`, `firstorder`, `resistance`.

## Pilot Data Format
Each entry in the `squadron.pilots` list represents a separate pilot card in the
squadron. Duplicates are repeated verbatim.

A squadron MUST have at least one pilot entry.


### Pilot Attributes
Requirement | Key | Type | Notes
---|---|---|---
Mandatory | id | String | Canonicalized pilot identifier (replaces `name` and `ship` from 1e).
 | | |
Optional | upgrades | Dictionary | Equipped upgrade cards for this pilot; see below.
Optional | points | Integer | Total point cost of the pilot plus upgrades. SHOULD be ignored by importing applications unless the XWS source is trusted.
 | | |
Ignored | vendor | Dictionary | An object used to store vendor-specific data; see above.


## Upgrades Data Format
Each entry in the `pilot.upgrades` dictionary MUST have a key of a canonicalized
name of an upgrade slot. The value is an Array of Strings, each the
canonicalized name of an upgrade card for the appropriate slot type.

```json
{
    "id": "...",
    "upgrades": {
        "astromech": ["r2d2"],
        "modification": ["hullupgrade"]
    }
}
```

A list of all valid upgrade type keys can be found at 
[https://github.com/guidokessels/xwing-data2/tree/master/data/upgrades](xwing-data2 upgrades).


## Canonical Unique IDs
As new pilots and upgrades are added, it would be best if
their IDs could be generated without further discussion between developers. The
best solution is to canonicalize the card names, taking into account some cards
share the same name (eg. Han Solo as several different pilots, R2-D2 as astromech and
as crew, etc.)


### Canonicalization Rules
1. Take the English-language name exactly as printed on the card
2. Lowercase the name
3. Convert non-ASCII characters to closest ASCII equivalent (to remove umlauts, etc.)
4. Remove non-alphanumeric characters
5. Check for collisions, reference [https://github.com/guidokessels/xwing-data2](xwing-data2) if any exist


#### Canonicalization and Name Collisions
To determine collisions, simply see if there are two cards of the same type (upgrade or pilot) that have the
same canonicalized name. Pilots and upgrades cannot collide with each other.

When there is a collision, then the canonicalized name is determined by the card's entry in 
[https://github.com/guidokessels/xwing-data2](xwing-data2).


## Obstacles
Obstacle canonicalization is:

    ${set containing the obstacle}${astreiod or debris}${number}

Obstacle outlines are roughly ordered from smallest to largest in the order they're
listed on the official tournament sheet, but since that's somewhat
subjective, the exact numbering of each obstacle should be considered arbitrary.

![Please consult the following image.](xws-obstacles-core2.png)


# Requirements for Application Developers

## Import / Export
Apps that provide the ability to import squadrons in these formats SHOULD
provide the ability to export them.


### Importing Examples
* A form containing a textarea where users can paste the JSON and the app will parse it and load that squadron.
* A file uploader that will accept .json, .XWS and .XWC files
* An API endpoint which would receive a squadron in this format, parse and display it.


### Exporting Examples
* A button to download a text file containing one or multiple squadrons
* A button for exporting a squadron directly to a different app. So, you'd click "export to Voidstate", for example, which would:
  * generate the JSON version of the squadron,
  * POST it to an API endpoint (eg. http://xwing-builder.co.uk/import),
  * where the app would parse the JSON and
  * reload the page with the squadron builder populated with that squadron


### Import Failures
When encountering a canonicalized name that is not recognized, an implementation
MAY reject the input with an error, silently drop the unrecognized portions of
the input, preserve the unrecognized data, or behave in some other manner
consistent with the purpose of the application. It is recommended that apps
ignore unrecognised data where possible.

Implementations SHOULD provide an indication that the data might have changed on
import, when feasible.

Note: Some builders may include unreleased cards, where the canonical name is
not known. Their export would be valid if re-imported into the original app but
MAY fail when imported into other applications.


### Checking should also be implemented by the app importing a squadron
Importing applications should ensure that:
* Point totals are correct, or failing that, the `points` key is dropped/ignored
* There are no illegal upgrades
* Factions are not mixed


## Vendor-Specific Extensions
To accomodate vendor-specific metadata, every Dictionary can optionally include
the `"vendor"` key. To prevent collisions between different implementations'
metadata, any data placed into the `"vendor"` key MUST be structured as follows:

```json
{
    "vendor": {
        "IMPLEMENTATION_NAME": {
            ...,
        }
    }
}
```

Where IMPLEMENTATION_NAME is a unique identifier for the application. An
application is free to structure the internal dictionary as desired, however the
following keys SHOULD be used consistently if provided at the top level of the
application-specific dictionary:

Requirement  | Key |  Type  | Notes
---|---|---|---
Optional | url | String | URL to this item in the exporting application.
Optional | builder | String | Name of the exporting squad-building application.
Optional | builder_url | String | URL to the exporting squad-building application.
 | | |
Ignored | ??? | Any | Other properties can be added as desired by the implementation.

After importing a squadron or collection, the application SHOULD remove all
unrecognized vendor properties before exporting again. This is to prevent
obsolete data being exported. It is acceptable to entirely remove all other
implementations' vendor keys to accomplish this.

### Official FFG builder data

The `"ffg"` vendor is a special case. Applications SHOULD NOT remove the `"ffg"` vendor 
key on import, since that key will tie the list back to the official builder.

```json
{
    "vendor": {
        "ffg": {
            "builder_url": "http://..."
        }
    }
}
```


# Validation
Implementations MAY use the following JSON schema to validate XWS data.

[http://github.com/elistevens/xws-spec/blob/master/schema.json](./schema.json)

More on JSON schemas can be fond at:

- http://json-schema.org
- https://github.com/geraintluff/tv4

Additionally, the `xws-spec` bower package has custom validation functions that
can be used to validate single-squadron lists. An online validator can be found
at:

http://elistevens.github.io/xws-spec/


# Versioning
This spec SHALL have a version number.

Future versions of this specification will increment the version number
according to http://semver.org/ .

The version number SHOULD NOT be used to reject squadrons on import. An
exporting implementation might support content through wave 6 but a given
squadron could be valid for wave 4. An importing application that has content
through wave 5 should not reject the squadron based on the spec version
indicated in the export JSON.


# QR Code Support (Experimental, Deprecated from 1e)
Implementations are encouraged to provide QR codes containing single-squadron
XWS JSON when it makes sense to do so, and similarly to provide QR code scanning
when appropriate.

The primary envisioned use case is for builders to provide a QR code that can be
loaded on a mobile device and scanned in by tournament organizing software to
quickly provide name and list information to the tournament organizer.

The content of the QR code should be in one of two forms:

- The raw XWS JSON with all optional whitespace removed from the JSON.
- The above compressed with a zlib-compatible compression algorithm.

In addition, implmenetations are encouraged to:

- Provide a sizable white border around the QR code.
- Allow mobile devices to zoom/scale the QR code

Based on limited experimental evidence, implementations are encouraged to use
error correction level H (high; 30%). Further experimentation may refine this
suggestion.

http://en.wikipedia.org/wiki/QR_code#Error_correction

Implementation authors are encouraged to share their experiences with QR codes,
as there are a large number of possible environments and scanners, and this spec
aims to provide guidelines for use in as many of those as possible.

# Implementations and Resources
A listing of known applications and developer resources that might be of use when working with XWS. Please submit pull requests with additions!

## Applications that implement import and/or export
- http://lists.starwarsclubhouse.com/ https://github.com/lhayhurst/xwlists
    X-Wing List Juggler. A web site to track X-Wing Miniature Combat lists and tournament stats.
- https://geordanr.github.io/xwing/ https://github.com/geordanr/xwing
    (Yet Another) X-Wing Miniatures Squad Builder
- http://xwing-builder.co.uk/ 
    Unofficial X-Wing Squadron Builder
- http://x-wing.fabpsb.net/
    Fab's squadrons generator
- http://randolphw.github.io/han-shopped-first/
    Han Shopped First. Makes purchase suggestions for starting collections or building out factions, or getting a specific list.
- https://github.com/kingargyle/xstreamer
    X-Wing Squad Helper for Twitch and YouTube Streamers.

## Resources for developers
- https://github.com/guidokessels/xwing-data2 . 
    An easy-to-use collection of data and images from X-Wing: The Miniatures Game by Fantasy Flight Games. 
    It has every card in the game, and each pilot and upgrade has the XWS id so you should be able to follow the XWS spec.
- https://github.com/voidstate/xwing-card-images 
    A collection of card images from X-Wing: The Miniatures Game by Fantasy Flight Games, arranged and named to be compatible with the XWS format.
    Initially forked from guidokessels/xwing-data
- https://github.com/geordanr/xwing-miniatures-font
    X-Wing Miniatures Font. Vector font by Hinny and armoredgear7.


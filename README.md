# PostMortem
A script to log, inform admins, victims and offenders in case of unlawful destruction of spacecraft.


# License

GNU GPL Affero license; if you modify and then distribute this mod, please share your improvements to the community.
Additionally, under the affero license, servers running publicly with this mod fall under redistribution.

You are welcome to make improvements and send pull requests.

# Installation

Extract the main file to Avorion/Mods/PostMortem/postmortem.lua

Add these lines to the bottom of Avorion/data/scripts/entity/init.lua :

````
--BEGIN MOD: PostMortem
if not entity.aiOwned and (entity.isShip or entity.isStation) then 
	entity:addScriptOnce("mods/PostMortem/postmortem.lua") 
end
--END MOD: PostMortem
````

# features

Creates a report indicating the destruction of a ship or station took place that is owned by an alliance or player with whom the offending player or alliance is NOT currently hostile.

There are several settings which can be changed in the PostMortem object.


# example output:

    2019-06-29 17-48-14| Player1 (1234567890)'s Ship asdasd was destroyed by Player1 (1234567890) in sector (202:206)
    2019-06-29 17-48-14| <PVP warning>  Player1 just destroyed a ship owned by Player1 with whom they are not at war. 
    2019-06-29 17-48-14| --PostMortem--
    2019-06-29 17-48-14| 	Post-mortem report for destruction of asdasd owned by the player 'Player1'
    2019-06-29 17-48-14| 	Which is a ship
    2019-06-29 17-48-14| 	(Stations require the victim to rebuild using resources listed below.)
    2019-06-29 17-48-14| 	maximum hull: 1572864
    2019-06-29 17-48-14| 	maximum shield: 0
    2019-06-29 17-48-14| 	omicron: 0
    2019-06-29 17-48-14| 	Construction resources: Destroyed value is:
    2019-06-29 17-48-14| Credits: 3932160
    2019-06-29 17-48-14| Titanium: 1310720
    2019-06-29 17-48-14| 	
    2019-06-29 17-48-14| 	Cause of death: destruction resulted from damage by: Player1.
    2019-06-29 17-48-14| 	Factions which contributed to damage: 
    2019-06-29 17-48-14| 1 : player named Player1, relations to entity: 100000 	
    2019-06-29 17-48-14| 	
    2019-06-29 17-48-14| 	Does this seem to be legal at first glance? Definitely not..
    2019-06-29 17-48-14| 	
    2019-06-29 17-48-14| 	Player1 may be subject to a maximum temporary ban of 53 days if this was not legal.
    2019-06-29 17-48-14| 	
    2019-06-29 17-48-14| 	Please note that according to our rules, combat between players and other players or alliances
    2019-06-29 17-48-14| 	Requires a standing of lower than -80000 (hateful). Additionally, alliances must have been at war at least 24 hours.
    2019-06-29 17-48-14| 	
    2019-06-29 17-48-14| 	Repeat offenders may be subject to a permanent ban.
    2019-06-29 17-48-14| 			 The relations of the killing faction was not hostile or worse; it was 100000.
    2019-06-29 17-48-14| 			
    2019-06-29 17-48-14| Player1 (1234567890)'s Ship asdasd was destroyed by Player1 (1234567890) in sector (202:206)

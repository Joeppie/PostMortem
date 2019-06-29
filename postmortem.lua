--The purpose of this script is to offer information in the log pertaining to the destruction of entities belonging to player.
--this should allow admins to understand what has led to the descruction of entities.
--This is designed specifically for  Divine Reapers server to understand whether rules were violated.


require ("faction")

--namespace PostMortem
PostMortem = {};

--settings that can be modified; be careful with ${} tags, you can repeat them or remove them, not introducing new terms means you have to introduce them in the code also.
PostMortem.maximumStandingForLawfulDestruction = -80000; --If standing between factions is not lower than this, then killing player/alliance stuff is considered an offense.
PostMortem.minimumBan = 0; --PostMortem does not ban  it just uses this to calculate a banLength suggestion, the defaults match the rules on DivineReapers.
PostMortem.resourcesPerDayofBan = 100000;
PostMortem.mailSender =  "Server";
PostMortem.mailHeader =  "Regarding unlawful destruction of spaceborne property";
PostMortem.publicBroadcast = [[ ${culprit} just destroyed a ${entityType} owned by ${victim} with whom they are not at war. ]];
PostMortem.killerWarning = [[${killerName}, You have violated the rules by destroying ${shipName}
This incident has been logged. Please contact the victim or the admins and handle the situation as per the rules.
Failure to comply may result in a in a ban of ${banLength} days, according to an automatic tally of the amount of resources lost, even for first time offenders!]];
PostMortem.victimMessage = [[Your vessel ${shipName} was destroyed in violation of server rules, by ${killerName}. Contact them and/or admins about resolving this.]]
PostMortem.reportTemplate = [[--PostMortem--
	Post-mortem report for destruction of ${shipName} owned by ${owner}
	Which is a ${entityType}
	(Stations require the victim to rebuild using resources listed below.)
	maximum hull: ${shipMaxDurability}
	maximum shield: ${shipShieldMaxDurability}
	omicron: ${shipFirePower}
	Construction resources: ${priceDump}
	
	Cause of death: destruction resulted from damage by: ${destroyerName}.
	Factions which contributed to damage: ${damagers}	
	
	Does this seem to be legal at first glance? ${allowed}.
	
	${destroyerName} may be subject to a maximum temporary ban of ${banLength} days if this was not legal.
	
	Please note that according to our rules, combat between players and other players or alliances
	Requires a standing of lower than -80000 (hateful). Additionally, alliances must have been at war at least 24 hours.
	
	Repeat offenders may be subject to a permanent ban.
]];
 
 if(onServer) then
	 
	function PostMortem.initialize()
		local faction = Faction()
		if not faction then return end

		if faction.isPlayer or faction.isAlliance then
			Entity():registerCallback("onDestroyed" , "onDestroyed")
		end
	end

	 
	 -- if ship is destroyed this function is called
	function PostMortem.onDestroyed(index, lastDamageInflictor)
		

		local faction = Faction() --Faction of entity that was destroyed.
		if not faction then return end

		if faction.isPlayer or faction.isAlliance then
			local crimeSceneSector = Sector();
			PostMortem.autopsy(Entity(),faction,lastDamageInflictor,crimeSceneSector);
		end
	end
		
			
	--Perform an autopsy on the 
	function PostMortem.autopsy(ship,faction,killerEntityId,crimeSceneSector)
	
	
	--Create variables to store the location of where this happened.
		local owner = nil;
		if faction.isPlayer then owner = "the player '" .. faction.name .. "'"; else owner = "the alliance '" .. faction.name .. "'"; end
		
		local entityType = nil;
		if ship.isShip then entityType = "ship"; elseif(ship.isStation) then entityType = "station"; else entityType = "unknown entity"; end
				
		local damagers = "";    
		for i,factionIndex in pairs({ship:getDamageContributors()}) do
			local offendingFaction = Faction(factionIndex);
			
			local owner= "";
			if(offendingFaction.isAlliance) then owner = owner .. "player alliance"; 
			elseif offendingFaction.isPlayer then owner = owner ..  "player";
			elseif offendingFaction.isAIFaction then owner = owner ..  "AI faction" ;
			else  owner = owner .. "unknown (not player, alliance of AI faction)"; end
			owner = owner .. " named " .. offendingFaction.name;
			local standing = offendingFaction:getRelations(faction.index);
			damagers = damagers .. "\n" .. ([[${i} : ${owner}, relations to entity: ${standing} ]] % { i = i, owner= owner, standing=standing}) ;
		end
		
		local currencies =
		{
			"Credits",
			"Iron",
			"Titanium",
			"Naonite",
			"Trinium",
			"Xanion",
			"Ogonite",
			"Avorion",
		}	

		local prices = {ship:getUndamagedPlanMoneyValue(), ship:getUndamagedPlanResourceValue()}
		local banLength = PostMortem.minimumBan;
		local priceDump = "Destroyed value is:"
		for i,price in ipairs(prices) do
			if price > 0 then
				priceDump = priceDump .. "\n" .. currencies[i] .. ": " .. math.ceil(price)
				banLength = banLength + price /PostMortem.resourcesPerDayofBan;
			end
		end
		
		banLength = math.ceil(banLength) --round it up.
		local killer =  Faction(Entity(killerEntityId).factionIndex);
		local standing = killer:getRelations(faction.index);
		
		local allowedString  = "Looks like it.";
		if (killer.isPlayer or killer.isAlliance) and (standing > PostMortem.maximumStandingForLawfulDestruction) and (killer.index ~= faction.index) then
			allowedString = "Definitely not.";
		end
		
		 local report = PostMortem.reportTemplate % {	shipName = ship.name,
			owner = owner,
			entityType = entityType,
			shipMaxDurability = ship.maxDurability,
			shipShieldMaxDurability = ship.shieldMaxDurability,
			shipFirePower = ship.firePower,
			priceDump = priceDump,
			destroyerName = killer.name,
			damagers = damagers,
			allowed = allowedString,
			banLength= banLength
			}

		if (killer.isPlayer or killer.isAlliance) and (standing > PostMortem.maximumStandingForLawfulDestruction) and (killer.index ~= faction.index)    then
			report = report .. ([[
			 The relations of the killing faction was not hostile or worse; it was ${standing}.
			]] % {standing=standing}  )
				
			local message = PostMortem.publicBroadcast % {culprit = killer.name,entityType=entityType, victim = faction.name};
			Server():broadcastChatMessage("PVP warning", ChatMessageType.Warning, message);
			killer:sendChatMessage("PVP warning", ChatMessageType.Error,PostMortem.killerWarning % { killerName=killer.name, shipName = ship.name, banLength=banLength});
			faction:sendChatMessage("PVP warning", ChatMessageType.Error,PostMortem.victimMessage % {shipName = ship.name, killerName=killer.name} );
			
			--Send mails to player entities for convenience so they hopefully can arrange proper solution.
			if(faction.isPlayer) then
				local mail = Mail();
				mail.header = PostMortem.mailHeader;
				mail.text = report;
				mail.sender = PostMortem.mailSender;
				
				Player():addMail(mail); --Hopefully that works properly and safely.
			end
		
			print(report)
		else
			--Prints the postmortem report to the server, even if it was a self-kill or 'lawful'; in case of loopholes being found.
			print("probably legal: " .. report .. "(probably legal)"); 	
		end
		
	end
end		

	 
	 
	 
	 



local timer1 = {};
local timer2 = {};

addEvent('spreader:enable', true);
addEventHandler('spreader:enable', root, function(component)
	if (component) then
		vehicle = getPedTarget(source);
		if (getElementType(vehicle) == 'vehicle') then

			if (isPedInVehicle(source)) then
				outputChatBox('Neden araçta bir şey kesmek istedin?', source);
				return;
			end;

			if (getElementData(source, 'rozpieranie') == true) then
				outputChatBox('Genişletme zaten devam ediyor!', source);
				return;
			end;

			if (getVehicleDoorState(vehicle, component) == 4) then
				outputChatBox('Bu bileşeni dengeleyemezsiniz çünkü o orada değil!', source);
				return;
			end;

			local x, y, z = getElementPosition(source);

			setPedAnimation(source, "CHAINSAW", "csaw_part", 5000);
			setElementData(source, "animation", {"CHAINSAW", "csaw_part"})

			outputChatBox('Yayılma sürüyor...', source);

			setElementData(source, 'rozpieranie', true);

			toggleControl(source, "sprint", false);
        	toggleControl(source, "jump", false);

        	setElementFrozen(source, false);

        	triggerClientEvent(source, 'spreader:enableProgress', source);
        	triggerClientEvent(source, 'spreader:enableSound', source, x, y, z);

        	player = source;
			veh = vehicle;

			timer1[player] = setTimer(function()
				setVehicleLocked(veh, false);
				setVehicleDoorState(veh, component, 2); -- najpierw lekko zniszczy komponent

				if isTimer(timer1[player]) then killTimer(timer1[player]) end
			end, 2500, 1);

			player = source;
			veh = vehicle;

			timer2[player] = setTimer(function()
				setElementData(player, 'rozpieranie', false);
				setPedAnimation(player);
				setElementData(player, "animation", nil)
				setVehicleDoorState(veh, component, 4, false); -- teraz go wywali z auta
				outputChatBox('Yayma tamamlandı.', player);

				toggleControl(player, "sprint", true);
        		toggleControl(player, "jump", true);

        		setElementFrozen(player, false);

        		triggerClientEvent(player, 'spreader:disableProgress', player);
        		triggerClientEvent(player, 'spreader:disableSound', player);

				if isTimer(timer2[player]) then killTimer(timer2[player]) end
			end, 5000, 1);
		end;
	else
		return;
	end;
end);

addEventHandler('onPlayerQuit', root, function()
	if (timer1[source]) then
		killTimer(timer1[source]);
	end;
	if (timer2[source]) then
		killTimer(timer2[source]);
	end;
end);
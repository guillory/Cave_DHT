
require("settings")
gpio.mode(PIN_RELAI,gpio.OUTPUT);  gpio.write(PIN_RELAI,gpio.HIGH);
nbtrypost=0;
dofile("wifi.lua")
dofile('postDomoticz.lua')
dofile('sensor.lua')
logfile("init")
function blink(nb,duree) 	for i=0,nb do gpio.write(PIN_LED,gpio.LOW);tmr.delay(duree);gpio.write(PIN_LED,gpio.HIGH); end end

	nbcycle=0;
	mesures={};
	gpio.mode(PIN_LED,gpio.OUTPUT);
	gpio.mode(PIN_3V_DHT,gpio.OUTPUT)
	nb=5 logfile("5 s") tmr.alarm(0, 1000, 1, function()		
		nb=nb-1  	
		logfile (".");blink(1,10000);
		if nb ==0 then  tmr.stop(0)
			if adc.force_init_mode(adc.INIT_VDD33) then
				ConnectWifi(Consigne, NodeSleep)
			else
				logfile "ALIM";
				adc.force_init_mode(adc.INIT_ADC)
				WAIT_MN=0;
				Vdd(NodeSleep);
			end
		end 
	end)



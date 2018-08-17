function logfile(txt)
			--file.open("log.log" , "a" );
			--file.writeline(txt);
		    --file.close();
		    print (txt);
end

function Vdd(call_back)
			--  VDD --------------------
			vdd=adc.readvdd33(0)/1000 or 0;
			logfile ("VDD ".. vdd.. " level="..battery_level(vdd));
		  	file.remove("vdd.log" );
			file.open("vdd.log" , "w" );
			file.writeline(vdd);
		    file.close();
		    call_back();
end
function AnalyseConsigne(jsondata)
	logfile ("AnalyseConsigne");
	t=sjson.decode(jsondata);
	logfile ("CONSIGNE avant ="..CONSIGNE);
	CONSIGNE=tonumber(t['result'][1]['Data']);
	logfile ("CONSIGNE nouvelle ="..CONSIGNE);
	logfile('consigne '..CONSIGNE);
	if (CONSIGNE >12 and CONSIGNE<20) then
		logfile ("ok");
	else
		CONSIGNE =15;
	end 
	Sensor();
end

function Consigne()
	--http://192.168.2.8:8084/json.htm?type=devices&rid=163
	httpgetdomoticz={}
	table.insert(httpgetdomoticz, {rid=idxconsigne, type="devices"})
	postDomoticz_all(AnalyseConsigne);
end
function Sensor()
	httpgetdomoticz={}
	VDD=0;		
	if 	file.open("vdd.log" , "r" ) then 		
		VDD=tonumber(file.readline()); 
	else
		logfile("fichier settings.cfg introuvable");
	end
		--  DHT  11 --------------------
		
		gpio.write(PIN_3V_DHT,gpio.HIGH) ;
		tmr.delay(1000000);
		
		--table.insert(mesures, {idx=50,nvalue=0, svalue=-wifi.sta.getrssi()} )
		nb=0;status=-2;
		temp=0;		humi=0;
		while(status ~= dht.OK and nb<=5 and temp == 0  and humi == 0 ) do
			nb=nb+1;
			tmr.delay(500000);
			status, temp, humi, temp_dec, humi_dec = dht.read(PIN_DHT);
			logfile (status, temp, humi, temp_dec, humi_dec);
			tmr.delay(500000);
			logfile (nb, " => Status "..status);

			if status == dht.OK  then 
				logfile ("temp = ".. temp.. " humi = ".. humi);
				table.insert(httpgetdomoticz, { type="command", idx=idxcave, param="udevice", svalue=temp..";"..humi..";0", nvalue=0, rssi=rssi_level(wifi.sta.getrssi()),  battery=battery_level(VDD)} )
	    		nb=6;
	    		logfile('temp = '..temp);
		    	ERROR=0;
			elseif status == dht.ERROR_CHECKSUM then
				logfile( "  DHT Checksum error." )
				ERROR=1;
			elseif status == dht.ERROR_TIMEOUT then
				logfile( "  DHT timed out." )
				ERROR=1;
			end
		end
		gpio.write(PIN_3V_DHT,gpio.LOW) ;
		if ERROR==1 then 
			logfile('Restart ');
			logfile ("ERROR"); node.restart();	
		else
			if  temp> CONSIGNE  and CONSIGNE >12 and CONSIGNE<20 then 
				logfile ("REFROIDIR : "..temp..">"..CONSIGNE)
				postDomoticz_all(refroidir);
			else
				logfile ("temp < CONSIGNE")
				gpio.write(PIN_RELAI,gpio.HIGH);
				tmr.delay(500000);
				logfile('Coup ');
				postDomoticz_all(NodeSleep);
			end
		end
		
		
end
function refroidir()
	nbcycle=nbcycle+1;
	if nbcycle > 4 then gpio.write(PIN_RELAI,gpio.HIGH); logfile('4 sequences');  NodeSleep();  end -- securite
	gpio.write(PIN_RELAI,gpio.LOW);
	nb=NBMNCOOL; logfile("10 mn") ;
	tmr.alarm(0, 60*1000, 1, function()		
		nb=nb-1 ;
		logfile(nb, "=>refroidir 1 mn");
		if nb <=0 then  tmr.stop(0); Consigne();end
	end);
	
end
function  rssi_level(rssi)
	local level=math.floor((- (rssi*rssi)  +  (15000 *rssi) + 1700000 )/100000  ) ;
		if  level>12 then return 12; else return level; end

end
function  battery_level(i)
	local level=math.floor(i /0.05);
	if  (level>100 or level<0) then return 255; else return level; end
end
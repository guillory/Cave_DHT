function postDomoticz_all(callback)
	--httpgetdomoticz
	if (table.getn(httpgetdomoticz)>0) then 
		serveur="http://"..DOMO_IP..":"..DOMO_PORT.."/json.htm?";
		url="";
		logfile("nb url: "..table.getn(httpgetdomoticz))
		for k,v in pairs(httpgetdomoticz[table.getn(httpgetdomoticz)]) do
			url=url..k.."="..v.."&";
		end
		logfile ("URL : "..serveur..url)
		http.get(serveur..url, nil, function(code, data)
		    if (code < 0) then
		      logfile("HTTP request failed");
		      nbtry=nbtry+1;
		      logfile ("nbtry : "..nbtry);
		      if (nbtry<10) then postDomoticz_all(callback) else node.restart() end
		      ERROR=1;
		    else
		      ERROR=0;
		      logfile('HTTP OK');
			 --   print(code, data);
			    if httpgetdomoticz[table.getn(httpgetdomoticz)]['type']=="devices" then 
			    		table.remove(httpgetdomoticz,table.getn(httpgetdomoticz))
						callback(data);
			    else
  						table.remove(httpgetdomoticz,table.getn(httpgetdomoticz))
					if (table.getn(httpgetdomoticz)>0) then 
						postDomoticz_all(callback)
					else
						logfile ("All posted")
					 	callback();
					end
				end
		    end
	  	end)
  else
	logfile("aucune valeur a poster");
	callback();
  end
end

function NodeSleep()
		logfile("sleeping "..WAIT_MN.." mn")
		if (DEEPSLEEP=='YES') then 
				logfile('DEEP');
				tmr.delay(1000000);
				node.dsleep(WAIT_MN * 60000000 +100000)
		else
				logfile("NO DEEP")
				wifi.sta.disconnect()
				tmr.delay(WAIT_MN * 60000000 +100000)
				node.restart()
		end
end


clear; 
clc;


client = CommsClient();
client.connect("COM11", 115200);
pause(0.5);

disp("BASIC CONNECTIVITY TESTS");
client.ping();        
pause(0.2);

client.echo("Hello"); 
pause(0.2);

disp("RATE CONFIGURATION");
client.queryRate();   
pause(0.2);

client.setRate(50);   
pause(0.2);

client.queryRate();   
pause(0.2);

disp("AXIS CONTROL TESTS");
client.setYaw(30);    
pause(0.2);

client.queryYaw();    
pause(0.2);

client.setPitch(15);  
pause(0.2);

client.queryPitch();  
pause(0.2);

client.queryLGFF();   
pause(0.2);

disp("STREAMING TEST");


client.OnTelemetry = @(data) fprintf("[T] t=%.2f  ax=%.4f  ay=%.4f  az=%.4f\n",data.t, data.ax, data.ay, data.az);

client.startStream();
pause(5);    
client.stopStream();

disp("Streaming stopped. Saving telemetry log...");
client.saveToCSV("telemetry_log.csv");

disp("SYSTEM CONTROL");
client.resetSystem(); 
pause(0.5);

client.abort();       
pause(0.5);

disp("TEST COMPLETE");
client.disconnect();

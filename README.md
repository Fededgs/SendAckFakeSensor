Federico Di Giusto

10693473

Link repository github: https://github.com/Fededgs/SendAckFakeSensor

# IOT_Home_Challenge_2

### In the folder:
* ```log_simulation.txt```: log of the simulation done
* ```README.md```: report (actually this)
* ```RunSimulationScript.py```: Simulation by TOSSIM
* ```SendAckFakeSensor``` ```AppC.nc```,```C.nc```,```.h```:  TinyOS files for Mote1 and Mote2
* ```FakeSensor``` ```C.nc```,```P.nc```: TinyOS files for simulation of the sensor
* ```meyer-heavy.txt```: radio noise
* ```topology.txt```: topology
* ```Makefile```

### Key points on development for Mote1-2:
* message type structure:
   * msg_type (REQ or RESP)
   * counter
   * value
* Every message exchanged, are acknoledged (from 1 to 2, from 2 to 1)
* Mote1 has ```Timer``` with period set to 1s. When it fires, it sends a message to Mote2(type ```REQ```,counter incremented, value ```0```).  
* Mote1 stops its ```Timer``` when it receives the ACK.
* Mote2 read the value of the ```FakeSensor```, it sends the response as message to Mote1 (type ```RESP```,counter as what it received, value of the sensor)

### Key points on simulation with TOSSIM:

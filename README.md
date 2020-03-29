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
* Debug Channels:
  * ```init```
  * ```boot```
  * ```timer``` : when it starts/stops
  * ```radio``` : when it's tunerd on/off or raise error.
  * ```radio_send``` :  sending of packet
  * ```radio_ack``` : received or not the ACK
  * ```radio_rec``` : received packet
  * ```radio_pack``` : info on packet
  * ```sensor``` : whent it reads or raises error
* Create two nodes with ```TOS_NODE_ID``` equal to ```1``` and ```2```
* Booting times:
  * at ```0```s node1 is booted
  * at ```5```s node2 is booted
* ```1200``` number of events

### Specific points of development:

* use of ```switch case``` on the event ```receive.receive``` to distiguish the message type (```REQ``` or ```RESP```):
  * if it's ```REQ``` arrived -> call ```sendResp``` function
  * if it's ```RESP``` arrived -> nothing
* The closing of the simulation is done in this way:
  * The ```Timer``` of Mote1 is stopped when it receives the ACK od its REQ.
  * Mote2 sends its ```RESP``` and it receives the ACK (NB: I would like to implement multiple ```RESP``` sending until the ACK is not received by Mote2, but as it's not specified in the rules, I prefered to not complicate code)
* use of ```PacketAcknowledgements```:
  * ```call PacketAcknowledgements.requestAck( &packet );``` in every sent message (both Mote1 and Mote2)
  * ```call PacketAcknowledgements.wasAcked( buf ); ``` in ```sendDone``` event to check if the ACK is received.

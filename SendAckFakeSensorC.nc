			/**
 *  Source file for implementation of module sendAckC in which
 *  the node 1 send a request to node 2 until it receives a response.
 *  The reply message contains a reading from the Fake Sensor.
 *
 *  @author Luca Pietro Borsani
 */

#include "SendAckFakeSensor.h"
#include "Timer.h"

module SendAckFakeSensorC {

  uses {
  /****** INTERFACES *****/
	interface Boot; 
	
	interface SplitControl;
	interface Packet;
	
	interface AMSend;
    interface Receive;
    	
    interface Timer<TMilli> as TimerMote1;
	interface Timer<TMilli> as TimerMote2;
	
	interface Read<uint16_t>;
  }

} implementation {

  uint8_t counter=0;
  uint8_t rec_id;
  message_t packet;

  void sendReq();
  void sendResp();
  
   //***************** Boot interface ********************//
  event void Boot.booted() {
	dbg("boot","Application booted on node %u.\n",TOS_NODE_ID);
	call SplitControl.start();
  }
  
  
  //***************** SplitControl interface ********************//
  event void SplitControl.startDone(error_t err){
    if(err == SUCCESS){
    	dbg("radio","Radio on \n");
    	 
		if(TOS_NODE_ID==1){ //in RunSimulation settato 1-2 id node
  		//temp
  		call TimerMote1.startPeriodic(1000);
  		}

        if(TOS_NODE_ID==2){
        call TimerMote2.startPeriodic(1000);
        }  
 	}
    else{
	//TODO:dbg for error
		dbgerror("radio_err","radio error restart radio \n");
		call SplitControl.start();
    }
  }
  
  
  event void SplitControl.stopDone(error_t err){
    /* Fill it ... */
	dbg("radio","Radio off \n");
  }


  
    //***************** MilliTimer interface ********************//
  event void TimerMote1.fired() {
	/* This event is triggered every time the timer fires.
	 * When the timer fires, we send a request
	 * Fill this part...
	 */
	 
   	dbg("timer","Mote1 Timer fired at %s.\n", sim_time_string());
   	//call sendReq();
   	
  }

  event void TimerMote2.fired() {
	/* This event is triggered every time the timer fires.
	 * When the timer fires, we send a request
	 * Fill this part...
	 */
	dbg("timer","Mote2 Timer fired at %s.\n", sim_time_string());
  }
  
  
  //***************** Send request function ********************//
  void sendReq() {
	/* This function is called when we want to send a request
	 *
	 * STEPS:
	 * 1. Prepare the msg
	 * 2. Set the ACK flag for the message using the PacketAcknowledgements interface
	 *     (read the docs)
	 * 3. Send an UNICAST message to the correct node
	 * X. Use debug statements showing what's happening (i.e. message fields)
	 */
 }        

  //****************** Task send response *****************//
  void sendResp() {
  	/* This function is called when we receive the REQ message.
  	 * Nothing to do here. 
  	 * `call Read.read()` reads from the fake sensor.
  	 * When the reading is done it raise the event read one.
  	 */
	call Read.read();
  }

 

  //********************* AMSend interface ****************//
  event void AMSend.sendDone(message_t* buf,error_t err) {
	/* This event is triggered when a message is sent 
	 *
	 * STEPS:
	 * 1. Check if the packet is sent
	 * 2. Check if the ACK is received (read the docs)
	 * 2a. If yes, stop the timer. The program is done
	 * 2b. Otherwise, send again the request
	 * X. Use debug statements showing what's happening (i.e. message fields)
	 */
  }

  //***************************** Receive interface *****************//
  event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) {
	/* This event is triggered when a message is received 
	 *
	 * STEPS:
	 * 1. Read the content of the message
	 * 2. Check if the type is request (REQ)
	 * 3. If a request is received, send the response
	 * X. Use debug statements showing what's happening (i.e. message fields)
	 */

  }
  
  //************************* Read interface **********************//
  event void Read.readDone(error_t result, uint16_t data) {
	/* This event is triggered when the fake sensor finish to read (after a Read.read()) 
	 *
	 * STEPS:
	 * 1. Prepare the response (RESP)
	 * 2. Send back (with a unicast message) the response
	 * X. Use debug statement showing what's happening (i.e. message fields)
	 */

}
}

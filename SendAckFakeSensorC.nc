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
	interface AMSend;
    interface Receive;
    
    interface Timer<TMilli> as TimerMote1;
	
	//Packet
	interface Packet;
	interface PacketAcknowledgements;
	
	
	interface Read<uint16_t> as SensorRead;//read fake sensor
	
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
   	sendReq();
   	
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
	 
 	my_msg_t* msgg=(my_msg_t*)(call Packet.getPayload(&packet,sizeof(my_msg_t)));
 	
 	if(msgg==NULL){
 	//dbg error pack
 	return;}
 	
 	msgg->msg_type = REQ;
 	msgg->counter = counter;
 	
 	call PacketAcknowledgements.requestAck( &packet ); //checks
 	
 	
 	if(call AMSend.send(2,&packet,sizeof(my_msg_t)) == SUCCESS){
 	
	  dbg("radio_send", "Packet sent successfully!\n");
	  dbg("radio_pack",">>>Pack\n \t Payload length %hhu \n", call Packet.payloadLength( &packet ) );
	  //dbg_clear("radio_pack","\t Source: %hhu \n ", call AMPacket.source( &packet ) );
	  //dbg_clear("radio_pack","\t Destination: %hhu \n ", call AMPacket.destination( &packet ) );
	  //dbg_clear("radio_pack","\t AM Type???????: %hhu \n ", call AMPacket.type( &packet ) );
	  dbg_clear("radio_pack","\t\t Payload \n" );
	  dbg_clear("radio_pack", "\t\t msg_type: %hhu \n ", msgg->msg_type);
  	  dbg_clear("radio_pack", "\t\t counter: %hhu \n ", msgg->counter);
	  dbg_clear("radio_pack", "\t\t value: %hhu \n ", msgg->value);
	  dbg_clear("radio_send", "\n ");
	  dbg_clear("radio_pack", "\n");
      
      }
      //increment counter
      counter++;	
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
	 
	if(&packet == buf && err == SUCCESS ) {
		dbg("radio_send", "Packet sent...\n");
    
	
		if ( call PacketAcknowledgements.wasAcked( buf ) ) {
			dbg_clear("radio_ack", "\t\tand ack received at time %s \n", sim_time_string());

			if(TOS_NODE_ID==1){			
				call TimerMote1.stop();
				dbg("timer","Timer stopped at time %s \n", sim_time_string());
			}

			
			}
		  
		else{
			dbg_clear("radio_ack", "\t\tand NO ack received at time %s \n", sim_time_string());
		}  
		
//		dbg_clear("radio_send", " at time %s \n", sim_time_string());
    }
	 
	 
	 
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
	 
	 my_msg_t* msgg=(my_msg_t*)payload;

	 switch(msgg->msg_type)
	 {
	 	case (REQ):
			dbg("role", "REQ message arrived\n");
		 sendResp();
	 	break;	 	
	 	
	 	case (RESP):
	 		dbg("role", "RESP message arrived\n");
	 	break;
	 	
	 	default:
	 	break;
	 }

  }

  //************************* Read interface **********************//
  event void SensorRead.readDone(error_t result, uint16_t data) {
	/* This event is triggered when the fake sensor finish to read (after a Read.read()) 
	 *
	 * STEPS:
	 * 1. Prepare the response (RESP)
	 * 2. Send back (with a unicast message) the response
	 * X. Use debug statement showing what's happening (i.e. message fields)
	 */

 	my_msg_t* msgg=(my_msg_t*)(call Packet.getPayload(&packet,sizeof(my_msg_t)));
 	
	double value_sens = ((double)data/65535)*100;
	dbg("fake_sensor","read done %f\n",value_sens);
	
 	if(msgg==NULL){
 	//dbg error pack
 	return;}
 	
 	msgg->msg_type = RESP;
 	msgg->counter = counter;
 	msgg->value = value_sens;
 	
 	call PacketAcknowledgements.requestAck( &packet ); //checks
 	
 	
 	if(call AMSend.send(1,&packet,sizeof(my_msg_t)) == SUCCESS){
 	
	  dbg("radio_send", "Packet sent successfully!\n");
	  dbg("radio_pack",">>>Pack\n \t Payload length %hhu \n", call Packet.payloadLength( &packet ) );
	  //dbg_clear("radio_pack","\t Source: %hhu \n ", call AMPacket.source( &packet ) );
	  //dbg_clear("radio_pack","\t Destination: %hhu \n ", call AMPacket.destination( &packet ) );
	  //dbg_clear("radio_pack","\t AM Type???????: %hhu \n ", call AMPacket.type( &packet ) );
	  dbg_clear("radio_pack","\t\t Payload \n" );
	  dbg_clear("radio_pack", "\t\t msg_type: %hhu \n ", msgg->msg_type);
  	  dbg_clear("radio_pack", "\t\t counter: %hhu \n ", msgg->counter);
	  dbg_clear("radio_pack", "\t\t value: %hhu \n ", msgg->value);
	  dbg_clear("radio_send", "\n ");
	  dbg_clear("radio_pack", "\n");
     
      }
	
}

  
  
  //****************** Task send response *****************//
  void sendResp() {
  	/* This function is called when we receive the REQ message.
  	 * Nothing to do here. 
  	 * `call Read.read()` reads from the fake sensor.
  	 * When the reading is done it raise the event read one.
  	 */
	call SensorRead.read();
  }

 

  
}


























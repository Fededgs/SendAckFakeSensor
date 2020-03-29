/**
 *  
 *
 *  @author Di Giusto Federico 10693473
 */

#include "SendAckFakeSensor.h"
#include "Timer.h"

module SendAckFakeSensorC {

  uses {
 
	interface Boot; 
	
	interface SplitControl;
	interface AMSend;
    interface Receive;    
    interface Timer<TMilli> as TimerMote1;
	
	//Packet
	interface Packet;
	interface PacketAcknowledgements;
	
	//Sensor
	interface Read<uint16_t> as SensorRead;
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
    	 
		if(TOS_NODE_ID==1){ 
	  		call TimerMote1.startPeriodic(1000);
  		}
  		
  		//do nothing for node=2
 	}
    else{
    
		dbgerror("radio","Restart radio \n"); //controlla in run python
		call SplitControl.start();
    }
  }
  
  
  event void SplitControl.stopDone(error_t err){
  
	dbg("radio","Radio off \n");
  }


  
    //***************** MilliTimer interface ********************//
  event void TimerMote1.fired() {
	
   	dbg("timer","Mote1 Timer fired at %s.\n", sim_time_string());
   	sendReq();
   	
  }
  

  //***************** Send request function ********************//
  void sendReq() {

 	my_msg_t* msgg=(my_msg_t*)(call Packet.getPayload(&packet,sizeof(my_msg_t)));
 	
 	if(msgg==NULL){
 		dbgerror("radio_pack","Error on packet \n"); //todo un altro canale??
 		return;
 	}
 	
 	msgg->msg_type = REQ;
 	msgg->counter = counter;
 	
 	dbg("radio_pack","Preparing the message... \n");
 	
 	call PacketAcknowledgements.requestAck( &packet ); 
 	
 	
 	if(call AMSend.send(2,&packet,sizeof(my_msg_t)) == SUCCESS){
 	
	  dbg("radio_send", "Packet sent successfully!\n");
	  dbg("radio_pack",">>>Pack\n ", call Packet.payloadLength( &packet ) );
	  dbg_clear("radio_pack","\t\t Payload Sent\n" );
	  dbg_clear("radio_pack", "\t\t msg_type: %hhu \n ", msgg->msg_type);
  	  dbg_clear("radio_pack", "\t\t counter: %hhu \n ", msgg->counter);
	  dbg_clear("radio_pack", "\t\t value: %hhu \n ", msgg->value);
	  dbg_clear("radio_send", "\n ");
	  dbg_clear("radio_pack", "\n");
      
      }
      
      //incrementing the counter
      counter++;	
 }        


  //********************* AMSend interface ****************//
  
  event void AMSend.sendDone(message_t* buf,error_t err) {

	if(&packet == buf && err == SUCCESS ) {
	
		dbg("radio_send", "Packet sent...\n");
    
		if ( call PacketAcknowledgements.wasAcked( buf ) ) {
			dbg_clear("radio_ack", "\t\tand ack received at time %s \n", sim_time_string());

			//Stop timer only if it's node1 to receive the ack
			if(TOS_NODE_ID==1){			
				call TimerMote1.stop();
				dbg("timer","Timer stopped at time %s \n", sim_time_string());
			}
		}
		else{
			dbg_clear("radio_ack", "\t\tand NO ack received at time %s \n", sim_time_string());
		}  
    }
  }

  //***************************** Receive interface *****************//
  event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) {

	 if (len != sizeof(my_msg_t)) {return buf;}
	 else{
		my_msg_t* msgg=(my_msg_t*)payload;
		 
		dbg("radio_rec", "Received packet at time %s\n", sim_time_string());
	
		dbg("radio_pack", ">>>Pack \n");
		dbg_clear("radio_pack","\t\t Payload Received\n" );
		dbg_clear("radio_pack", "\t\t msg_type: %hhu \n ", msgg->msg_type);
		dbg_clear("radio_pack", "\t\t counter: %hhu \n ", msgg->counter);
		dbg_clear("radio_pack", "\t\t value: %hhu \n ", msgg->value);
		dbg_clear("radio_send", "\n ");
		dbg_clear("radio_pack", "\n");
 
		//save the counter (in node 2)
		counter=msgg->counter;

		switch(msgg->msg_type)
		{
			case (REQ):
				dbg("radio_pack", "REQ message arrived\n");
				sendResp(); 
			break;	 	

			case (RESP):
				dbg("radio_pack", "RESP message arrived\n");
			break;

			default:
			break;
		}
		 
     	return buf;	 
	 }

  }
  
  
  //****************** Task send response *****************//
  void sendResp() {
  
	call SensorRead.read();
  }


  //************************* Read interface **********************//
  event void SensorRead.readDone(error_t result, uint16_t data) {
  
  	if(result==SUCCESS){

 	my_msg_t* msgg=(my_msg_t*)(call Packet.getPayload(&packet,sizeof(my_msg_t)));
 	
	double value_sens = ((double)data/65535)*100;
	dbg("sensor","Read done %f\n",value_sens);
	
 	if(msgg==NULL){
	 	dbgerror("radio_pack","Error on packet \n");
 		return;
 	}
 	
 	msgg->msg_type = RESP;
 	msgg->counter = counter;
 	msgg->value = value_sens;
 	
 	dbg("radio_pack","Preparing the message... \n");
 	
 	call PacketAcknowledgements.requestAck( &packet ); 
 	
 	if(call AMSend.send(1,&packet,sizeof(my_msg_t)) == SUCCESS){
 	
	  dbg("radio_send", "Packet sent successfully!\n");
	  dbg("radio_pack",">>>Pack\n ");	  
	  dbg_clear("radio_pack","\t\t Payload \n" );
	  dbg_clear("radio_pack", "\t\t msg_type: %hhu \n ", msgg->msg_type);
  	  dbg_clear("radio_pack", "\t\t counter: %hhu \n ", msgg->counter);
	  dbg_clear("radio_pack", "\t\t value: %f \n ", msgg->value);
	  dbg_clear("radio_send", "\n ");
	  dbg_clear("radio_pack", "\n");
     
      } 
    }
    else{
    	dbgerror("sensor","Error on reading sensor \n");
    }   
  }

}


























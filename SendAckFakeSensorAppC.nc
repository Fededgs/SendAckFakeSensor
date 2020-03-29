/**
 *  @author Di Giusto Federico 10693473
 */

#include "SendAckFakeSensor.h"

configuration SendAckFakeSensorAppC {}

implementation {


/****** COMPONENTS *****/
  components MainC, SendAckFakeSensorC as App;
  components new TimerMilliC() as mote1_t;
  components ActiveMessageC;
  components new AMSenderC(AM_SEND_MSG);
  components new AMReceiverC(AM_SEND_MSG);  
  
  //Sensor
  components new FakeSensorC();


/****** INTERFACES *****/
  //Boot interface
  App.Boot -> MainC.Boot;  
  
  //Packet
  App.PacketAcknowledgements->ActiveMessageC;
  App.Receive -> AMReceiverC;
  App.SplitControl -> ActiveMessageC;
  App.AMSend -> AMSenderC;
  App.Packet -> AMSenderC;
  //Timer interface
  App.TimerMote1 -> mote1_t;

  //SensorRead
  App.SensorRead -> FakeSensorC;

}


/**
 *  @author Di Giusto Federico 10693473
 */

#include "SendAckFakeSensor.h"

configuration SendAckFakeSensorAppC {}

implementation {


/****** COMPONENTS *****/
  components MainC, SendAckFakeSensorC as App;
  components new TimerMilliC() as mote1_t;
  components new TimerMilliC() as mote2_t;
  //components new TempHumSensorC();
  components ActiveMessageC;
  components new AMSenderC(AM_SEND_MSG);
  components new AMReceiverC(AM_SEND_MSG);  


/****** INTERFACES *****/
  //Boot interface
  App.Boot -> MainC.Boot;

  /****** Wire the other interfaces down here *****/
  //Send and Receive interfaces
  App.Receive -> AMReceiverC;
  App.SplitControl -> ActiveMessageC;
  //Radio Control
  App.AMSend -> AMSenderC;
  //Interfaces to access package fields
  App.Packet -> AMSenderC;
  //Timer interface
  App.TimerMote1 -> mote1_t;
  App.TimerMote2 -> mote2_t;
  //Fake Sensor read
  //App.Read -> FakeSensorC;

}


/**
 *  @author Federico Di Giusto 10693473
 */

#ifndef SENDACK_H
#define SENDACK_H

//payload of the msg
typedef nx_struct my_msg {
	//REQ/RESP
	type;
	//counter
	counter;
	//temp
	value;
} my_msg_t;

#define REQ 1
#define RESP 2 

enum{
AM_MY_MSG = 6,
};

#endif

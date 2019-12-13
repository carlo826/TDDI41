#!/bin/bash

:' 
ID:			    DNS-5
Purpose:		To check that A record queries to zone sysinst.ida.liu.se work from any network.
SUT:			The DNS server at 130.236.189.1.

Preconditions:	The DNS server is configured with the sysinst.ida.liu.se zone (test DNS-1).
			    The SUT server is reachable over the network from any host (test NET-1).
			    The zone contains A records for www.sysinst.ida.liu.se, ns.sysinst.ida.liu.se and d1-gw.sysinst.ida.liu.se (test DNS-2).

Procedure:		Run the following commands on 130.236.189.1, 130.236.189.12 and on any host not connected to 130.236.189.0/24:
			    1. host www.sysinst.ida.liu.se.
			    2. host ns.sysinst.ida.liu.se.
			    3. host d1-gw.sysinst.ida.liu.se.

Expected results:	Each command should return "HOST has address IP", where HOST is identical to the argument to the host command and IP is an IPv4 address.

Pass criteria:		The IP returned by command 1 is always 130.236.189.6, the IP returned by command 2 is always 130.236.189.2 and the IP returned by command 3 is always 130.236.189.48.
'


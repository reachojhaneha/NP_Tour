README for CSE 533 Assignment 3 (Network Programming)
-----------------------------------------------------

Submitted by : Neha Ojha (111635128)


Address-Resolution-Protocol 

In this assignment we have implemented :

1)An application that uses raw IP sockets to ‘walk’ around an ordered list of nodes given as a command line argument at the ‘source’ node.
2)At each node, the application pings the preceding node in the tour.
3)Finally, when the ‘walk’ is completed, the group of nodes visited on the tour will exchange broadcast messages.
4)Finally, when the ‘walk’ is completed, the group of nodes visited on the tour will also exchange multicast messages.

The application contains two modules

tour.c : Usage after make and deploy at source node: ./nojha_tour <node1> <node2> etc
Usage after make and deploy and other nodes: ./nojha_tour

arp.c : Usage after make and deploy: ./nojha_arp

-------------
Tour module
-------------

-----------------
Sockets Created
-----------------

Raw Socket:
rt(route traversal) - IP_HDRINCL option is set . Protocol Value 10
pg(ping socket) - Used to receive ping replies . Protocol value IPPROTO_ICMP
pf_packet - SOCK_DGRAM type. Protocol value : ETH_P_IP
Two UDP sockets. Multicast receive and send. 

---------------------
Implemented Features
---------------------
All requirements of assignment 3 are implemented

----------------------------------------------
Tour Module - Implemented :
----------------------------------------------

When evoking the application on the source node, the user supplies a sequence of vm node names (not IP
addresses) to be visited in order. This command line sequence starts with the next node to be visited from the
source node (i.e., it does not start with the source node itself). 
The sequence can include any number of repeated visits to the same node. For example, suppose that the source node is vm3 and the executable is called nojha_tour
[root@vm3/root]# ./nojha_tour vm2 vm10 vm4 vm7 vm5 vm2 vm6 vm2 vm9 vm4 vm7 vm2 vm6 vm5 vm1 vm10 vm8
1) Check to see if the source node is the first node. If so abort with appropriate message.
2) Check to see if two nodes are continuous. If so abort with appropriate message.


The application turns the sequence into a list of IP addresses for source routing. It also adds the IP address of
the source node itself to the beginning of the list. The list thus produced will be carried as the payload of an IP
packet, not as a SSRR option in the packet header. 
Application ensures that every node in the sequence is visited in order.
The source node adds to the  list an IP multicast address and a port number. It also joins the multicast group at that address and port number on its UDP socket. The TTL for outgoing multicasts is set to 1.

The application then fills in the header of an IP packet, designating itself as the IP source, and the next node
to be visited as the IP destination. The packet is sent out on the rt socket. Identification field is set to 171.

When a node receives an IP packet on its rt socket, it should first check that the identification field carries the right
value.If the identification field value does not check out, the packet is ignored. For a valid packet :
The following message is printed.
<time> received source routing packet from <hostname>

If this is the first time the node is visited, the application should use the multicast address and port number in
the packet received to join the multicast group on its UDP socket. 
The TTL for outgoing multicasts is set to 1.

The application then fills in the header of an IP packet, designating itself as the IP source, and the next node
to be visited as the IP destination. The packet is sent out on the rt socket. 

When a node receives an IP packet on its rt socket, it checks that the identification field carries the right
value and if the identification field (171) value does not check out, the packet is ignored. 
For a valid packet : appropriate message is printed

If node is visited for the first time it joins multicast group on its UDP socket. The TTL now is set to 1.

Then list in the payload is uploaded, so that the next node in the tour can easily identify what the
next hop from itself will be when it receives the packet. 

application call arp module to get ethernet address of its preceding node through areq function implemeted in tour module
The node initiate pinging(ICMP echo request) to the preceding node in the tour on pf_packet socket . 

This ARP is evoked every time the application wants to send out an echo request message.

This echo request message is properly encapsulated in IP packet(Ehternet Header + Ethernet Payload(IP header + ICMP header + ICMP data))

When a node is ready to start pinging, it first prints out a ‘PING’ message

It then builds up ICMP echo request messages and sends them to the target node every 1 second
through the PF_PACKET socket. It also reads incoming echo response messages off the pg socket, in response
to which it prints out appropriate message.

If this node and its preceding node have been previously visited in that order during the tour, then
pinging would have already been initiated from the one to the other in response to the first visit and it will already be there in pinglist of this node, and
nothing is done during second and subsequent visits.

Node read from both its rt and pg sockets, through select routine while always monitoring its UDP socket for incoming multicast datagrams.

When tour reaches last node nd if this is the first time it is visited, it starts pinging the preceding node (if it is not already doing so). After a few echo replies are received it
sends out the multicast message below on its UDP socket and waits about five seconds before
sending the multicast message :
<<<<< This is node vmi. Tour has ended . Group members please identify yourselves. >>>>>

Each node including last node receives this message and then each node stops its pinging activity.
The node then send out the following multicast message:
<<<<< Node vmj. I am a member of the group. >>>>>

Each other node including last node of tour receives this second multicast messages.
Then each node waits for 5 second(Timeout) and ends the Tour Process finally.

-------------------------------------------
ARP MODULE - Implemented
-------------------------------------------

It is run on every vm node.
It uses the get_hw_addrs function to explore its node’s interfaces and build a set of <IP address ,
HW address> matching pairs for all eth0 interface IP addresses (including alias IP addresses, if any).

The module creates two sockets: a PF_PACKET(SOCK_RAW) socket and a Unix domain socket(SOCK_STREAM).

This is a listening socket bound to a ‘well-known’ sun_path "kimi" file. This socket will be used to communicate with the function areq that is
implemented in the Tour module 

The ARP module then sits in an infinite loop, monitoring these two sockets.
As ARP request messages arrive on the PF_PACKET socket, the module processes them, and responds with ARP
reply messages as appropriate.
The protocol builds a ‘cache’ of matching <IP address , HW address> pairs from the replies it receives. For simplicity, and unlike the real ARP, we shall not implement timing out mechanisms for these
cache entries.
When an ARP reply is being entered in the
cache, the ARP module uses the socket descriptor in to send a reply to the client and closes the connection socket,
and deletes the socket descriptor from the cache entry.

If the ARP request received does not pertain to the node receiving it, but there is already an entry in that receiving
node's cache for the sender’s <IP address, HW address> matching pair, that entry is checked and updated. If there is no such entry, no action is taken (in particular, and unlike the case above, no new entry should
be made in the receiving node's cache of the sender’s <IP address, HW address> matching pair if such an
entry does not already exist).

ARP request and reply messages have an extra
2-byte identification field added at the beginning for uniqueness.
This value is echoed in the reply message.

The contents of the Ethernet frame header and ARP request message that are send are printed out properly. 
The two sender addresses with the two target
addresses are swapped, as well as extra identification field are echoed back sent with the request. 
The protocol at this responding node prints out both the request frame (header and ARP
message) it receives and the reply frame it sends. 
Similarly, the node that sent the request prints out the
reply frame it receives. Finally,node that issues the request sends out a broadcast Ethernet frame, but the responding node replies with a unicast frame.

--------------------------
API SPECIFICATIONS
--------------------------

The areq api is for communication between the Tour process and the ARP process 
implemented in the Tour module. 

	int areq (struct sockaddr *IPaddr, socklen_t sockaddrlen, struct hwaddr *HWaddr);
	
IPaddr contains the primary or alias IPaddress of a ‘target’ node on the LAN for which the corresponding hardware
address is being requested.

areq creates a Unix domain socket of type SOCK_STREAM and connects to the ‘well-known’ sun_path file of the
ARP listening socket. It sends the IP address from parameter IPaddr and the information in the three fields of
parameter HWaddr to ARP. It then blocks on a read awaiting a reply from ARP. This read is backed up by a
timeout since it is possible that no reply is received for the request. If a timeout occurs, areq closes the socket
and returns to its caller indicating failure.

Your application code is printing in clear format,every
time areq is called, giving the IP address for which a HW address is being sought. It is similarly printing out
the result when the call to areq returns (HW address returned, or failure).

When the ARP module receives a request for a HW address from areq through its Unix domain listening socket, it
first checks if the required HW address is already in the cache. If so, it responds immediately to the areq and
close the Unix domain connection socket. Else : it is makeing an ‘incomplete’ entry in the cache, puts out an ARP request message on the network on its PF_PACKET socket; and starts
monitoring the areq connection socket for readability – if the areq client closes the connection socket (this would
occur in response to a timeout in areq), ARP deletes the corresponding incomplete entry from the cache (and ignores
any subsequent ARP reply from the network if such is received). On the other hand, if ARP receives a reply from the
network, it updates the incomplete cache entry, responds to areq, and closes the connection socket.
		
Constants Used in arp are : 

#define PROTOCOL 62357     //Unique protocol
#define SOURCEPORT 13855
#define SERVERPORT 13854
#define ARP_PATH "kimi"   //Unique sun path
#define ETH_HDRLEN 14      // Ethernet header length
#define IP4_HDRLEN 20      // IPv4 header length
#define ARP_HDRLEN 30      // ARP header length
#define ARPOP_REQUEST 1    // Taken from <linux/if_arp.h>
#define ARPOP_REPLY 2
#define GROUP_ID 3571       //Group Unique ID for the team
#define ETH_FRAME_LENGTH 1500
#define INCOMPLETE -1
#define COMPLETE 1


Constants used in tour are : 

#define IP_PROTOCOL 10                                //unique protocol value
#define MULTICAST_IP "239.126.255.180"                //unique multicast ip
#define MPORT 13852                                  //unique multicast port number
#define IDENTIFICATION 171                          //unique identification number
#define ARP_PATH "kimi"                              //unique arp path for communicating with arp
#define ETH_HDRLEN 14                                 // Ethernet header length
#define IP4_HDRLEN 20                               // IPv4 header length
#define ICMP_HDRLEN 8                            // ICMP header length for echo request, excludes data
#define DATALEN 56                                 //ICMP Data
#define ETH_PAYLOAD_LEN IP4_HDRLEN + ICMP_HDRLEN + DATALEN
#define ETH_PACKET_LEN ETH_HDRLEN + ETH_PAYLOAD_LEN

STEPS TO RUN CODE:
==================
1. Make sure that the arp and tour is not already running when deploying(on each individual vm).
pkill nojha_arp
pkill nojha_tour

2. Deploy ARP and TOUR(on minix)
./deploy_app nojha_arp
./deploy_app nojha_tour

3. Run arp in background on all the machines(vms)
./nojha_arp &

4. Run tour on all the machines(vms) 
./nojha_tour vm3 vm4(source)
./nojha_tour (non source machines)	

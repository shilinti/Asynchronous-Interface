# Asynchronous-Interface
The asynchronous interface is spercifically designed for a scalable parallel datapaths. 
Scalable parallel data enter at 250 MHz. They are read out in the same width at 50 MHz. For maximum throughput, the interface should be capable of accepting a burst of 10 of the 250 MHz words. To avoid overflow, the sending side must be signaled that new data cannot be accepted a cycle before a new word would actually cause loss of data. The clocks are asynchronous. Each operates from a crystal that operates with a stability of 10 PPM per degree C.

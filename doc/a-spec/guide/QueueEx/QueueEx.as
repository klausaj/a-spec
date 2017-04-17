#fileID<queue_ex_as>

<DocumentInfo>
   docID     A_Spec_Queue_Example;
   docVer    00;
   docRev    a;
</DocumentInfo>

#import<toolkit.al>

begin schema Packet
   p_type: UINT8;
   p_data: BYTE_ARRAY;
where
end

<Description>
<Text>
A $Packet$ is composed of a one byte packet type and packet data.  No
constraints are placed on the conents of a $Packet$ apart from the packet type
being an eight-bit unsigned integer.
</Text>
</Description>

begin axdef MaxQueueSize
   MAX_QUEUE_SIZE: UINT32;
where
   MAX_QUEUE_SIZE = 256;
end

begin schema PacketQueue
   pq_queue: seq Packet;
where
   size(pq_queue) <= MAX_QUEUE_SIZE;
end

<Description>
<Text>
A $PacketQueue$ maintains an ordered list of $Packets$.  The size of this list
may never exceed 256 elements as specified by $MAX_QUEUE_SIZE$.
</Text>
</Description>

begin schema QueueAppend
   [delta]PacketQueue;

   qa_pkt[?]: Packet;
where
   if(size(pq_queue) < MAX_QUEUE_SIZE) then
      pq_queue['] = pq_queue cat seqDisp{qa_pkt[?]};
   else
      pq_queue['] = tail(pq_queue) cat seqDisp{qa_pkt[?]};
   endif;
end

begin schema QueueTake
   [delta]PacketQueue;

   qt_pkt[!]: Packet;
where
   pq_queue['] = tail(pq_queue);
   qt_pkt[!] = head(pq_queue);
end

<Description>
<Text>
$QueueAppend$ and $QueueTake$ specify operations on a $PacketQueue$ that allow
FIFO manipulation of the queue.  Note: If $QueueAppend$ is invoked on an already
full queue, the first element of the queue shall be rolled under.  Also note
that $QueueTake$ is undefined on an empty queue and must therefore not be
invoked under this condition.
</Text>
</Description>

begin axdef QueueEmpty
   bool queueEmpty: pset PacketQueue;
where
   forAll{queue: PacketQueue; ? @
      queueEmpty(queue) <=> size(queue.pq_queue) = 0;
   };
end

<Description>
<Text>
$queueEmpty$ specifies a predicate function used to determine if a
$PacketQueue$ is empty.  This function may be used to guarantee the
necessary preconditions for the $QueueTake$ schema.
</Text>
</Description>

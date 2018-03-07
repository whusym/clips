(deffacts initial 
	(peg A) 
	(peg B) 
	(peg C) 
	(disks-provided 8) 
	(arranged false) 
	(minDisk 65536 B) 
	(minDisk 65536 C) 
	(lastMoved C) 
)

(defrule even-disk
	(disks-provided ?v)
	(test (evenp ?v))
	(arranged ?b)
   	(test (eq false ?b))
   	?F <- (arranged false)
=>
	(assert (arranged true))
	(assert (leftof A B))
	(assert (leftof B C))
	(assert (leftof C A))
	(assert (quantity even))
	(retract ?F)
	(printout t "even number!" crlf)
)

(defrule odd-disk
	(disks-provided ?v)
	(test (oddp ?v))
	(arranged ?b)
   (test (eq false ?b))
   ?F <- (arranged false)
=>
	(assert (arranged true))
	(assert (leftof A C))
	(assert (leftof C B))
	(assert (leftof B A))
	(assert (quantity odd))
	(retract ?F)
	(printout t "odd number!" crlf)
)

(defrule add-disk
   	(disks-provided ?v)
   	(arranged ?b)
   	(test (eq true ?b))
   	(test (neq 0 ?v))
   	?F <- (disks-provided ?v)
 =>
   	(while (> ?v 0)
	 	(assert (onPeg ?v A))
      	(printout t "Adding " ?v " on the peg" crlf)
      	(bind ?v (- ?v 1)))
   	(retract ?F)
)

;From https://stackoverflow.com/questions/20275384/find-maximum-among-facts-in-clips
(defrule find-min-value
   	(onPeg ?v ?p)
   	(not (onPeg ?v2 ?p &:(< ?v2 ?v)))
=>
   	;(printout t "Disk " ?v " is the min on" ?p crlf)
   	(assert (minDisk ?v ?p))
)

(defrule add-max
	(peg ?p)
	(not (minDisk ?v ?p))
	(not (onPeg ?d ?p))
=>
	(assert (minDisk 65536 ?p))
	;(printout t "Disk " ?p " needs a max" crlf)
)

(defrule move-disk
	; move to the immediate right peg
	(minDisk ?v1 ?p)
	?F1 <- (minDisk ?v1 ?p)
	(minDisk ?v2 ?q)
	(peg ?p)
	(peg ?q)
	?F2 <- (minDisk ?v2 ?q)
	?F3 <- (onPeg ?v1 ?p)
	(test (< (- ?v1 ?v2) 0))
	(rightof ?q ?p)
	(lastMoved ?r)
	?F4 <- (lastMoved ?r)
	(test (neq ?r ?p))
=>
	(assert (onPeg ?v1 ?q))
	(retract ?F1)
	(printout t "move disk " ?v1 " from " ?p " to " ?q crlf)
	(retract ?F2)
	(retract ?F3)
	(retract ?F4)
	(assert (lastMoved ?q))
)

(defrule move-disk-2
	; if the immediate right peg is not available, move to the peg on its left (move to the second right)
	(minDisk ?v1 ?p)
	?F1 <- (minDisk ?v1 ?p)
	(minDisk ?v2 ?q)
	(peg ?p)
	(peg ?q)
	(peg ?s)
	?F3 <- (onPeg ?v1 ?p)
	(rightof ?q ?p)
	(leftof ?s ?p)
	(minDisk ?v3 ?s)
	(test (< ?v1 ?v3))
	(lastMoved ?r)
	?F4 <- (lastMoved ?r)
	?F2 <- (minDisk ?v3 ?s)
	(test (neq ?r ?p))
=>
	(assert (onPeg ?v1 ?s))
	(retract ?F4)
	(assert (lastMoved ?s))
	(retract ?F1)
	(printout t "move disk " ?v1 " from " ?p " to " ?s crlf)
	(retract ?F2)
	(retract ?F3)
)

(defrule relocation-odd
	; moved all all pegs to one already; but not the final peg; hard-code to move top one
	(quantity odd)
	(minDisk 65536 A)
	(minDisk 65536 B)
	?F1 <- (onPeg 1 C)
	?F2 <- (minDisk 65536 B)
	?F3 <- (lastMoved ?m)
=>
	(retract ?F1)
	(retract ?F3)
	(assert (onPeg 1 B))
	(assert (lastMoved B))
	(assert (minDisk 1 B))
	(printout t "move disk 1 from C to B" crlf)
	(retract ?F2)
)

(defrule relocation-even
	; moved all all pegs to one already; but not the final peg; hard-code to move top one
	(quantity even)
	(minDisk 65536 A)
	(minDisk 65536 C)
	?F1 <- (onPeg 1 B)
	?F2 <- (minDisk 65536 C)
	?F3 <- (lastMoved ?m)
=>
	(retract ?F1)
	(retract ?F3)
	(assert (onPeg 1 C))
	(assert (lastMoved C))
	(assert (minDisk 1 C))
	(printout t "move disk 1 from B to peg C" crlf)
	(retract ?F2)
)

(defrule end-even
	(quantity even)
	(minDisk 65536 A)
	(minDisk 65536 B)
=>
	(halt)
)

(defrule end-odd
	(quantity odd)
	(minDisk 65536 A)
	(minDisk 65536 C)
=>
	(halt)
)


(defrule location
	(leftof ?x ?y)
=>
	(assert (rightof ?y ?x))
	(printout t "re-location completed" crlf)
)

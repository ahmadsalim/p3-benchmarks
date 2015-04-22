rm pan*
spin -a minepump.pml
cc -o pan pan.c -O3
./pan -a -n -m25000

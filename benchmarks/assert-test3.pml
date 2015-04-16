typedef features {
  bool A;
  bool B;
  bool C
}

features f;

active proctype main() {
  int i = 0;
  gd :: f.A -> i++;
     :: else -> skip;
  dg;
  gd :: f.B -> i++;
     :: else -> skip;
  dg;
  gd :: f.C -> i++;
     :: else -> skip;
  dg;
  assert (i >= 0);
}

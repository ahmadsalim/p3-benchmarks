typedef features {
  bool A;
  bool B;
  bool C;
  bool D;
  bool E;
  bool F;
  bool G;
  bool H;
  bool I;
  bool J;
  bool K;
  bool L
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
  gd :: f.D -> i++;
     :: else -> skip;
  dg;
  gd :: f.E -> i++;
     :: else -> skip;
  dg;
  gd :: f.F -> i++;
     :: else -> skip;
  dg;
  gd :: f.G -> i++;
     :: else -> skip;
  dg;
  gd :: f.H -> i++;
     :: else -> skip;
  dg;
  gd :: f.I -> i++;
     :: else -> skip;
  dg;
  gd :: f.J -> i++;
     :: else -> skip;
  dg;
  gd :: f.K -> i++;
     :: else -> skip;
  dg;
  gd :: f.L -> i++;
     :: else -> skip;
  dg;
  assert (i >= 0);
}

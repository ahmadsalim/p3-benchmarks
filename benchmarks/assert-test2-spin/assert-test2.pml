typedef features {
  bool A;
  bool B
}

features f;

active proctype main() {
  int i = 0;
  if :: true -> i++;
     :: true -> skip;
  fi;
  if :: true -> i++;
     :: true -> skip;
  fi;
  assert (i >= 0);
}

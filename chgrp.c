#ifdef CS333_P5
#include "types.h"
#include "user.h"
int
main(int argc, char *argv[])
{
  int gid = 0;
  if (argc < 2 || argc > 3)
  {
    printf(1,"Incorrect arguments.\n");
    exit();
  }
  gid = atoi(argv[1]);
  if(gid < 0 || gid > 32767)
  {
    printf(1,"invalid gid number.\n");
    exit();
  }
  if(chgrp(argv[2], gid) < 0)
  {
    printf(1, "chown failed\n");
  }

  exit();
}

#endif

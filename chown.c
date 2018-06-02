#ifdef CS333_P5
#include "types.h"
#include "user.h"
int
main(int argc, char *argv[])
{

  int uid = 0;
  if (argc < 2 || argc > 3)
  {
    printf(1,"Incorrect arguments.\n");
    exit();
  }
  uid = atoi(argv[1]);
  if(uid < 0 || uid > 32767)
  {
    printf(1,"invalid uid number.\n");
    exit();
  }
  if(chown(argv[2], uid) < 0)
  {
    printf(1, "chown failed\n");
  }


  exit();
}

#endif

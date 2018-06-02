#ifdef CS333_P5
#include "types.h"
#include "user.h"
int
main(int argc, char*argv[])
{
  int mode;
  char * mode_check = argv[1];
  char c;
  if (argc < 2 || argc > 3)
  {
    printf(1,"Incorrect arguments.\n");
    exit();
  }
  for(int i = 0; i < strlen(mode_check); ++i)
  {
    c = mode_check[i];
    if(i == 0 && (c != '0' && c != '1'))
    {
      printf(1,"bad setuid bit.\n");
      exit();
    }
    if (i > 0 && c < '0' && c > '7')
    {
      printf(1,"bad mode bit at %d index\n", i);
      exit();
    }


    mode = mode*8 + mode_check[i] - '0';

  }

  if(chmod(argv[2], mode) < 0)
  {
    printf(1,"chmod failed\n");
  }

  exit();
}

#endif

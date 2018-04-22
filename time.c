#ifdef CS333_P2
#include "types.h"
#include "user.h"
int
main(int argc, char * argv[])
{
  int pid = 0;
  int end_ticks = 0;
  int start_ticks = uptime();
  pid = fork();
  if (pid < 0)
  {
    printf(1,"invalid pid\n");
    exit();
  }
  if(pid > 0)
  {
    wait();
    end_ticks = uptime();
  }
  if (pid == 0)
  {
    if(exec(argv[1], argv+1) < 0)
    {
      exit();
    }
  }
  int seconds  = (end_ticks - start_ticks)/1000;
  int miliseconds = (end_ticks - start_ticks)%1000;
  printf(1,"%s ran in %d.", argv[1], seconds);
  if(miliseconds < 10)
    printf(1,"0");
  printf(1,"%d\n", miliseconds);
  //printf(1, "Not imlpemented yet.\n");
  exit();
}

#endif

#ifdef CS333_P2
#include "types.h"
#include "user.h"
#include "uproc.h"
int
main(int argc, char * argv[])
{
  //array size for ps command
  int max = 72;

  struct uproc * proctable;
  proctable = malloc(max*sizeof(struct uproc));
  int collected = getprocs(max,proctable);

  //if there was a problem with getprocs, catch it and alert user.
  if(collected<=0)
  {
    printf(1,"There was an error getting the process table.\n");
  }
  else
  {
    //Header
    printf(1,"PID\tUID\tGID\tPPID\tPrio\tElapsed\tCPU\tSate\tSize\tName\n");
    //Print everything that was copied in the array.
    for(int i = 0; i<collected; ++i)
    {
      printf(1,"%d\t%d\t%d\t%d\t%d\t%d.", proctable[i].pid, proctable[i].uid, proctable[i].gid, proctable[i].ppid, proctable[i].priority,
                                          proctable[i].elapsed_ticks/1000);
      if(proctable[i].elapsed_ticks%1000 < 100)
        printf(1,"0");
      if(proctable[i].elapsed_ticks%1000 < 10)
        printf(1,"0");
      printf(1,"%d\t%d.",proctable[i].elapsed_ticks%1000, proctable[i].CPU_total_ticks/1000);
      if(proctable[i].CPU_total_ticks%1000 < 100)
        printf(1,"0");
      if(proctable[i].CPU_total_ticks%1000 < 10)
        printf(1,"0");
      printf(1,"%d\t%s\t%d\t%s\n", proctable[i].CPU_total_ticks%1000, proctable[i].state, proctable[i].size, proctable[i].name);
    }
  }
  free(proctable);
//printf(1, "Not imlpemented yet.\n");
  exit();
}
#endif

#ifdef CS333_P2
#include "types.h"
#include "user.h"
#include "uproc.h"
int
main(void)
{
  int max = 64;
  struct uproc * proctable = malloc(max*sizeof(struct uproc));
  int size = getprocs(max,proctable);

  if(size<=0)
  {
    printf(1,"There was an error getting the process table.\n");
  }
  else
  {
    printf(1,"\nPID\tUID\tGID\tPPID\tElapsed\tCPU\tSate\t\tSize\tName\n");
    for(int i = 0; i<size; ++i)
    {
      printf(1,"%d\t%d\t%d\t%d\t%d.", proctable[i].pid, proctable[i].uid, proctable[i].gid, proctable[i].ppid, proctable[i].elapsed_ticks/1000);
      if(proctable[i].elapsed_ticks%1000 < 100)
        printf(1,"0");
      if(proctable[i].elapsed_ticks%1000 < 10)
        printf(1,"0");
      printf(1,"%d\t%d.",proctable[i].elapsed_ticks%1000, proctable[i].CPU_total_ticks/1000);
      if(proctable[i].CPU_total_ticks%1000 < 100)
        printf(1,"0");
      if(proctable[i].CPU_total_ticks%1000 < 10)
        printf(1,"0");
      printf(1,"%d\t%s \t%d\t%s\n", proctable[i].CPU_total_ticks%1000, proctable[i].state, proctable[i].size, proctable[i].name);
    }
  }
//printf(1, "Not imlpemented yet.\n");
  exit();
}
#endif

#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "uproc.h"

int
sys_fork(void)
{
  return fork();
}

int
sys_exit(void)
{
  exit();
  return 0;  // not reached
}

int
sys_wait(void)
{
  return wait();
}

int
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

int
sys_getpid(void)
{
  return proc->pid;
}

int
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = proc->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

int
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(proc->killed){
      return -1;
    }
    sleep(&ticks, (struct spinlock *)0);
  }
  return 0;
}

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
  uint xticks;

  xticks = ticks;
  return xticks;
}

//Turn of the computer
int
sys_halt(void){
  cprintf("Shutting down ...\n");
  outw( 0x604, 0x0 | 0x2000);
  return 0;
}


int
sys_date(void)
{
  struct rtcdate *d;
  if(argptr(0, (void*)&d, sizeof(struct rtcdate)) < 0)
    return -1;
  cmostime(d);
  return 0;
}

//Get gid
uint
sys_getuid(void)
{
  return proc->uid;
}

//Get gid
uint
sys_getgid(void)
{
  return proc->gid;
}

//Returns init's pid, since it has no parent.
//Or returns the parents pid.
uint
sys_getppid(void)
{
  if(proc->parent != 0)
    return proc->parent->pid;
  return proc->pid;
}

//Sets the uid after making sure that the argument
//is within the bounds 0<=32767
int
sys_setuid(uint _uid)
{
  argint(0, (int*)&_uid);
  if (_uid>= 0 && _uid<= 32767)
  {
    proc->uid = _uid;
    return 0;
  }
  return -1;
}

//Sets the gid after making sure that the argument
//is within the bouds 0<=32767
int
sys_setgid(uint _uid)
{
  argint(0, (int*)&_uid);
  if (_uid>= 0 && _uid<= 32767)
  {
    proc->gid = _uid;
    return 0;
  }
  return -1;
}

//Getprocs calls getprocs in proc.c in order to lock the ptable and
//grab all the processes off of that when ps is called.
int
sys_getprocs(int max, struct uproc* table)
{
  if(argint(0,&max)< 0 || argptr(1,(void*)&table,sizeof(*table)*max) <0)
    return -1;
  return getprocs(max,table);
}

#ifdef CS333_P3P4
int
sys_setpriority(void)
{
  int pid;
  int value;

  if(argint(0, &pid)< 0 || argint(1,&value))
    return -1;

  return setpriority(pid, value);
}
#endif

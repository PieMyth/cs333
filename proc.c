#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"
#include "uproc.h"

struct StateLists {
  struct proc* ready[MAXPRIO+1];
  struct proc* readyTail[MAXPRIO+1];
  struct proc* free;
  struct proc* freeTail;
  struct proc* sleep;
  struct proc* sleepTail;
  struct proc* zombie;
  struct proc* zombieTail;
  struct proc* running;
  struct proc* runningTail;
  struct proc* embryo;
  struct proc* embryoTail;
};

struct {
  struct spinlock lock;
  struct proc proc[NPROC];
  struct StateLists pLists;
  uint PromoteAtTime;
} ptable;

static struct proc *initproc;

int nextpid = 1;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);


#ifdef CS333_P3P4
static void initProcessLists(void);
static void initFreeList(void);
static int stateListAdd(struct proc** head, struct proc** tail, struct proc* p);
static int stateListRemove(struct proc** head, struct proc** tail, struct proc* p);
static void assertState(struct proc* p, enum procstate state);
static void promoteAll(void);
#endif

void
pinit(void)
{
  initlock(&ptable.lock, "ptable");
}

//PAGEBREAK: 32
// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
#ifndef CS333_P3P4
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
#else
  p = ptable.pLists.free;
  if(p)
    goto found;
#endif
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
#ifdef CS333_P3P4
  if(stateListRemove(&ptable.pLists.free, &ptable.pLists.freeTail, p))
    panic("error removing from free list.");
  if(stateListAdd(&ptable.pLists.embryo, &ptable.pLists.embryoTail,p))
    panic("error adding to embryo list.");
  assertState(p, EMBRYO);
#endif
  p->pid = nextpid++;
  p->start_ticks = ticks;
  p->uid = 0;
  p->gid = 0;
  p->cpu_ticks_in = 0;
  p->cpu_ticks_total = 0;
  p->priority = 0;
  p->budget = BUDGET;
  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
#ifdef CS333_P3P4
    if(stateListRemove(&ptable.pLists.embryo, &ptable.pLists.embryoTail,p))
      panic("error removing from embryo list.");
    if(stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail,p))
      panic("error adding to free list.");
    assertState(p, UNUSED);
#endif
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  p->tf = (struct trapframe*)sp;

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

  return p;
}

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

#ifdef CS333_P3P4
  acquire(&ptable.lock);
  initProcessLists();
  initFreeList();
  ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
  release(&ptable.lock);
#endif
  p = allocproc();

  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;
  memset(p->tf, 0, sizeof(*p->tf));
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  p->tf->es = p->tf->ds;
  p->tf->ss = p->tf->ds;
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  p->state = RUNNABLE;
#ifdef CS333_P3P4
  acquire(&ptable.lock);
  if(stateListRemove(&ptable.pLists.embryo, &ptable.pLists.embryoTail, p))
    panic("error removing from embryo list.");
  if(stateListAdd(&ptable.pLists.ready[p->priority], &ptable.pLists.readyTail[p->priority], p))
    panic("error adding to ready list.");
  assertState(p, RUNNABLE);
  release(&ptable.lock);
#endif
  p->uid = 0;
  p->gid = 0;
}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;

  sz = proc->sz;
  if(n > 0){
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  proc->sz = sz;
  switchuvm(proc);
  return 0;
}

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
    return -1;

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
#ifdef CS333_P3P4
    acquire(&ptable.lock);
    if(stateListRemove(&ptable.pLists.embryo, &ptable.pLists.embryoTail, np))
      panic("error removing from embryo.");
    if(stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail, np))
      panic("error adding to freelist.");
    assertState(np, UNUSED);
    release(&ptable.lock);
#endif
    return -1;
  }
  np->sz = proc->sz;
  np->parent = proc;
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);

  safestrcpy(np->name, proc->name, sizeof(proc->name));

  pid = np->pid;

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
  np->state = RUNNABLE;
#ifdef CS333_P3P4
  if(stateListRemove(&ptable.pLists.embryo, &ptable.pLists.embryoTail, np))
    panic("error removing from embryo.");
  if(stateListAdd(&ptable.pLists.ready[np->priority], &ptable.pLists.readyTail[np->priority], np))
    panic("error adding to ready list.");
  assertState(np, RUNNABLE);
#endif
  release(&ptable.lock);

  np->uid = proc->uid;
  np->gid = proc->gid;

  return pid;
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
#ifndef CS333_P3P4
void
exit(void)
{
  struct proc *p;
  int fd;

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd]){
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(proc->cwd);
  end_op();
  proc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == proc){
      p->parent = initproc;
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
  sched();
  panic("zombie exit");
}
#else
void
exit(void)
{
  struct proc *p;
  int fd;

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd]){
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(proc->cwd);
  end_op();
  proc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(int i = 0; i<MAXPRIO+1 ; ++i)
  {
    for(p = ptable.pLists.ready[i];p;p=p->next)
    {
      if(p->parent == proc)
        p->parent = initproc;
    }
  }
  for(p = ptable.pLists.sleep;p;p=p->next)
  {
    if(p->parent == proc)
      p->parent = initproc;
  }
  for(p = ptable.pLists.embryo;p;p=p->next)
  {
    if(p->parent == proc)
      p->parent = initproc;
  }
  for(p=ptable.pLists.running;p;p=p->next)
  {
    if(p->parent == proc)
      p->parent = initproc;
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
  if(stateListRemove(&ptable.pLists.running, &ptable.pLists.runningTail, proc))
    panic("Error removing from running.");
  if(stateListAdd(&ptable.pLists.zombie, &ptable.pLists.zombieTail, proc))
    panic("error adding to zombie list.");
  assertState(proc, ZOMBIE);
  sched();
  panic("zombie exit");

}
#endif

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
#ifndef CS333_P3P4
int
wait(void)
{
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    p = ptable.pLists.zombie;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
        freevm(p->pgdir);
        p->state = UNUSED;
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        release(&ptable.lock);
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
  }
}
#else
int
wait(void)
{
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.pLists.zombie; p; p=p->next){
      if(p->parent != proc)
        continue;

      havekids = 1;
      // Found one.
      pid = p->pid;
      kfree(p->kstack);
      p->kstack = 0;
      freevm(p->pgdir);
      p->state = UNUSED;
      if(stateListRemove(&ptable.pLists.zombie, &ptable.pLists.zombieTail,p))
        panic("Error removing from zombie list.");
      if(stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail,p))
        panic("Error adding to free list.");
      assertState(p, UNUSED);
      p->pid = 0;
      p->parent = 0;
      p->name[0] = 0;
      p->killed = 0;
      release(&ptable.lock);
      return pid;

    }

    for(int i = 0; i<MAXPRIO+1 ; ++i)
    {
      for(p = ptable.pLists.ready[i];p;p=p->next)
      {
        if(p->parent == proc)
        {
          havekids = 1;
          goto kids;
        }
      }
    }
    for(p = ptable.pLists.sleep;p;p=p->next)
    {
      if(p->parent == proc)
      {
        havekids = 1;
        goto kids;
      }
    }
    for(p = ptable.pLists.embryo;p;p=p->next)
    {
      if(p->parent == proc)
      {
        havekids = 1;
        goto kids;
      }
    }
    for(p=ptable.pLists.running;p;p=p->next)
    {
      if(p->parent == proc)
      {
        havekids = 1;
        goto kids;
      }
    }

    kids:
    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
  }
}
#endif

//PAGEBREAK: 42
// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
#ifndef CS333_P3P4
// original xv6 scheduler. Use if CS333_P3P4 NOT defined.
void
scheduler(void)
{
  struct proc *p;
  int idle;  // for checking if processor is idle

  for(;;){
    // Enable interrupts on this processor.
    sti();

    idle = 1;  // assume idle unless we schedule a process
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      idle = 0;  // not idle this timeslice
      proc = p;
      switchuvm(p);
      p->state = RUNNING;

      proc->cpu_ticks_in = ticks;

      swtch(&cpu->scheduler, proc->context);

      proc->cpu_ticks_total = proc->cpu_ticks_total + (ticks - proc->cpu_ticks_in);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
    // if idle, wait for next interrupt
    if (idle) {
      sti();
      hlt();
    }
  }
}

#else
void
scheduler(void)
{
  struct proc *p;
  int idle;  // for checking if processor is idle

  for(;;){
    // Enable interrupts on this processor.
    sti();

    idle = 1;  // assume idle unless we schedule a process
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    if(ticks >= ptable.PromoteAtTime)
    {
      promoteAll();
      ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
    }
    for(int i = 0; i<MAXPRIO+1; ++i)
    {
      for(p = ptable.pLists.ready[i]; p; p = p->next){

        // Switch to chosen process.  It is the process's job
        // to release ptable.lock and then reacquire it
        // before jumping back to us.
        idle = 0;  // not idle this timeslice
        proc = p;
        switchuvm(p);
        p->state = RUNNING;
        if(stateListRemove(&ptable.pLists.ready[i], &ptable.pLists.readyTail[i], p))
          panic("problem with removing from ready list.");
        if(stateListAdd(&ptable.pLists.running, &ptable.pLists.runningTail, p))
          panic("problem with adding to running list.");
        assertState(p, RUNNING);

        p->cpu_ticks_in = ticks;

        swtch(&cpu->scheduler, proc->context);

        p->cpu_ticks_total = p->cpu_ticks_total + (ticks - p->cpu_ticks_in);
        switchkvm();

        // Process is done running for now.
        // It should have changed its p->state before coming back.
        proc = 0;
      }
    }
    release(&ptable.lock);
    // if idle, wait for next interrupt
    if (idle) {
      sti();
      hlt();
    }
  }
}
#endif

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
  int intena;

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
    panic("sched locks");
  if(proc->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = cpu->intena;
  swtch(&proc->context, cpu->scheduler);
  cpu->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  acquire(&ptable.lock);  //DOC: yieldlock
  proc->state = RUNNABLE;
#ifdef CS333_P3P4
  proc->budget = proc->budget - (ticks - proc->cpu_ticks_in);
  if(proc->budget <= 0)
  {
    if(proc->priority < MAXPRIO)
      proc->priority += 1;
    proc->budget = BUDGET*(proc->priority+1);
  }
  stateListRemove(&ptable.pLists.running, &ptable.pLists.runningTail, proc);
  stateListAdd(&ptable.pLists.ready[proc->priority], &ptable.pLists.readyTail[proc->priority], proc);
  assertState(proc, RUNNABLE);
#endif
  sched();
  release(&ptable.lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);

  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
// 2016/12/28: ticklock removed from xv6. sleep() changed to
// accept a NULL lock to accommodate.
void
sleep(void *chan, struct spinlock *lk)
{
  if(proc == 0)
    panic("sleep");

  // Must acquire ptable.lock in order to
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){
    acquire(&ptable.lock);
    if (lk) release(lk);
  }

  // Go to sleep.
  proc->chan = chan;
  proc->state = SLEEPING;
#ifdef CS333_P3P4
  proc->budget = proc->budget - (ticks - proc->cpu_ticks_in);
  if(proc->budget <= 0)
  {
    if(proc->priority < MAXPRIO)
      proc->priority += 1;
    proc->budget = BUDGET*(proc->priority+1);
  }
  if(stateListRemove(&ptable.pLists.running, &ptable.pLists.runningTail, proc))
    panic("error removing from running list.");
  if(stateListAdd(&ptable.pLists.sleep, &ptable.pLists.sleepTail, proc))
    panic("error adding to sleep list.");
  assertState(proc, SLEEPING);
#endif
  sched();

  // Tidy up.
  proc->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){
    release(&ptable.lock);
    if (lk) acquire(lk);
  }
}

//PAGEBREAK!
#ifndef CS333_P3P4
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
#else
static void
wakeup1(void *chan)
{
  struct proc *p;

  p = ptable.pLists.sleep;
  while(p)
  {
    if(p->chan == chan)
    {
      p->state = RUNNABLE;
      if(stateListRemove(&ptable.pLists.sleep, &ptable.pLists.sleepTail, p))
        panic("error removing from sleep list.");
      if(stateListAdd(&ptable.pLists.ready[p->priority], &ptable.pLists.readyTail[p->priority], p))
        panic("error adding to ready list.");
      assertState(p, RUNNABLE);
    }
    p = p->next;
  }
}
#endif

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
}

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
#ifndef CS333_P3P4
int
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}
#else
int
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(int i = 0; i<MAXPRIO+1; ++i)
  {
    for(p = ptable.pLists.ready[i]; p ; p = p->next)
    {
      if(p->pid == pid)
        goto found;
    }
  }
  for(p = ptable.pLists.running; p ; p = p->next)
  {
    if(p->pid == pid)
      goto found;
  }
  for(p = ptable.pLists.embryo; p ; p = p->next)
  {
    if(p->pid == pid)
      goto found;
  }
  for(p = ptable.pLists.zombie; p ; p = p->next)
  {
    if(p->pid == pid)
      goto found;
  }
  for(p = ptable.pLists.sleep; p ; p = p->next)
  {
    if(p->pid == pid)
    {
      // Wake process from sleep if necessary.
      if(stateListRemove(&ptable.pLists.sleep, &ptable.pLists.sleepTail, p))
        panic("error removing from sleep list.");
      if(stateListAdd(&ptable.pLists.ready[p->priority], &ptable.pLists.readyTail[p->priority], p))
        panic("error adding to ready list.");
      p->state = RUNNABLE;
      assertState(p, RUNNABLE);
      goto found;
    }
  }
  release(&ptable.lock);
  return -1;

  found:
  p->killed = 1;
  release(&ptable.lock);
  return 0;
}
#endif

static char *states[] = {
  [UNUSED]    "unused",
  [EMBRYO]    "embryo",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
};

//PAGEBREAK: 36
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  int i;
  uint current_ticks;
  struct proc *p;
  char *state;
  uint pc[10];
#if defined CS333_P3P4
  cprintf("\nPID\tName\tUID\tGID\tPPID\tPrio\tElapsed\tCPU\tState\tSize\t PCs\n");
#elif defined CS333_P2
  cprintf("\nPID\tName\tUID\tGID\tPPID\tElapsed\tCPU\tState\tSize\t PCs\n");
#elif defined CS333_P1
  cprintf("\nPID\tState\tName\tElapsed\t PCs\n");
#else
  cprintf("\nPID\tState\tName\t PCs\n");
#endif
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    current_ticks = ticks;
    i = ((current_ticks-p->start_ticks)%1000);
#if defined CS333_P2
    cprintf("%d\t%s\t%d\t%d", p->pid, p->name, p->uid, p->gid);
    if(p->pid == 1)
      cprintf("\t%d",p->pid);
    else
      cprintf("\t%d",p->parent->pid);
#if defined CS333_P3P4
      cprintf("\t%d", p->priority);
#endif
    cprintf("\t%d.", ((current_ticks-p->start_ticks)/1000));
    if (i<100)
      cprintf("0");
    if (i<10)
      cprintf("0");
    cprintf("%d", i);
    i = p->cpu_ticks_total;
    cprintf("\t%d.", i/1000);
    i = i%1000;
    if (i<100)
      cprintf("0");
    if (i<10)
      cprintf("0");
    cprintf("%d\t%s\t%d\t", i, state, p->sz);
#elif defined CS333_P1
    cprintf("%d\t%s\t%s\t%d.", p->pid, state, p->name, ((current_ticks-p->start_ticks)/1000));
    if (i<100)
      cprintf("0");
    if (i<10)
      cprintf("0");
    cprintf("%d\t",i);
#else
    cprintf("%d\t%s\t%s", p->pid, state, p->name);
#endif
    i = 0;
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}


#ifdef CS333_P3P4
static int
stateListAdd(struct proc** head, struct proc** tail, struct proc* p)
{
  if (*head == 0) {
    *head = p;
    *tail = p;
    p->next = 0;
  } else {
    (*tail)->next = p;
    *tail = (*tail)->next;
    (*tail)->next = 0;
  }

  return 0;
}

static int
stateListRemove(struct proc** head, struct proc** tail, struct proc* p)
{
  if (*head == 0 || *tail == 0 || p == 0) {
    return -1;
  }

  struct proc* current = *head;
  struct proc* previous = 0;

  if (current == p) {
    *head = (*head)->next;
    return 0;
  }

  while(current) {
    if (current == p) {
      break;
    }

    previous = current;
    current = current->next;
  }

  // Process not found, hit eject.
  if (current == 0) {
    return -1;
  }

  // Process found. Set the appropriate next pointer.
  if (current == *tail) {
    *tail = previous;
    (*tail)->next = 0;
  } else {
    previous->next = current->next;
  }

  // Make sure p->next doesn't point into the list.
  p->next = 0;

  return 0;
}

static void
initProcessLists(void) {
  for(int i = 0; i<MAXPRIO+1; ++i)
  {
    ptable.pLists.ready[i] = 0;
    ptable.pLists.readyTail[i] = 0;
  }
  ptable.pLists.free = 0;
  ptable.pLists.freeTail = 0;
  ptable.pLists.sleep = 0;
  ptable.pLists.sleepTail = 0;
  ptable.pLists.zombie = 0;
  ptable.pLists.zombieTail = 0;
  ptable.pLists.running = 0;
  ptable.pLists.runningTail = 0;
  ptable.pLists.embryo = 0;
  ptable.pLists.embryoTail = 0;
}

static void
initFreeList(void) {
  if (!holding(&ptable.lock)) {
    panic("acquire the ptable lock before calling initFreeList\n");
  }

  struct proc* p;

  for (p = ptable.proc; p < ptable.proc + NPROC; ++p) {
    p->state = UNUSED;
    stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail, p);
  }
}
#endif

//Get all current processes within the system.
int
getprocs(int max, struct uproc* proctable)
{
  struct proc *p;
  int i;

  //LOCK PTABLE
  acquire(&ptable.lock);

  //ptable gets incremented within forloop, i get incremented at the end
  //of the forloop.
  for(i=0, p = ptable.proc; p < &ptable.proc[NPROC] && i<max; p++)
  {
    //copy all the info into one element of the array
    //skip if the process is in the unused state
    if(p->state != UNUSED && p->state != EMBRYO)
    {
      proctable[i].pid = p->pid;
      proctable[i].uid = p->uid;
      proctable[i].gid = p->gid;
      proctable[i].priority = p->priority;
      if(p->parent != 0)
        proctable[i].ppid = p->parent->pid;
      else
        proctable[i].ppid = p->pid;

      //Get the current ticks for elapsed ticks.
      proctable[i].elapsed_ticks = ticks-p->start_ticks;
      proctable[i].CPU_total_ticks = p->cpu_ticks_total;
      safestrcpy(proctable[i].state, states[p->state], sizeof(proctable[i].state));
      proctable[i].size = p->sz;
      safestrcpy(proctable[i].name, p->name, sizeof(p->name));

      //Increment the array that is having info copied into
      ++i;

    }
  }

  //UNLOCK PTABLE
  release(&ptable.lock);

  return i;
}

void
piddump(void)
{
  struct proc *p;
  acquire(&ptable.lock);
  cprintf("\nReady List Processes:\n");
  for(int i = 0; i<MAXPRIO+1; ++i)
  {
    p = ptable.pLists.ready[i];
    cprintf("%d: ", i);
    while(p)
    {
      cprintf("(%d, %d)", p->pid, p->budget);
      if(p->next)
        cprintf(" -> ");
      p = p->next;
    }
    cprintf("\n");
  }
  release(&ptable.lock);
}

void
freedump(void)
{
  struct proc *p;
  int counter = 0;
  acquire(&ptable.lock);
  p = ptable.pLists.free;
  while(p)
  {
    p = p->next;
    ++counter;
  }

  cprintf("\nFree List Size: %d processes\n", counter);

  release(&ptable.lock);
}

void
sleepdump(void)
{
  struct proc *p;
  acquire(&ptable.lock);
  p = ptable.pLists.sleep;
  cprintf("\nSleep List Processes:\n");
  while(p)
  {
    cprintf("%d", p->pid);
    if(p->next)
      cprintf(" -> ");
    p = p->next;
  }
  cprintf("\n");
  release(&ptable.lock);
}

void
zombiedump(void)
{
  struct proc *p;
  acquire(&ptable.lock);
  p = ptable.pLists.zombie;
  cprintf("\nZombie List Processes:\n");
  while(p)
  {
    cprintf("(PID%d, PPID%d)", p->pid, (p->parent? p->parent->pid : p->pid));
    if(p->next)
      cprintf(" -> ");
    p = p->next;
  }
  cprintf("\n");
  release(&ptable.lock);
}

void
assertState(struct proc* p, enum procstate state)
{
  if(p->state != state)
    panic("proc state does not match list state.");
}

int
setpriority(int pid, int priority)
{
  struct proc* p;
  if(pid<0 || priority < 0 || priority > MAXPRIO+1)
    return -1;

  acquire(&ptable.lock);
  for(int i = 0; i < MAXPRIO+1; ++i)
  {
    for(p = ptable.pLists.ready[i];p;p=p->next)
    {
      if(p->pid == pid && priority != p->priority)
      {
#ifdef CS333_P3P4
        if(stateListRemove(&ptable.pLists.ready[p->priority], &ptable.pLists.readyTail[p->priority], p))
          panic("Error removing process from current priority");
        p->priority = priority;
        if(stateListAdd(&ptable.pLists.ready[p->priority], &ptable.pLists.readyTail[p->priority], p))
          panic("Error adding process to current priority");
#endif
        p->budget = BUDGET*(p->priority+1);
        release(&ptable.lock);
        return 0;
      }
    }
  }
  for(p = ptable.pLists.sleep; p ; p=p->next)
  {
    if(p->pid == pid)
    {
      p->priority = priority;
      p->budget = BUDGET*(p->priority+1);
      release(&ptable.lock);
      return 0;
    }
  }

  for(p = ptable.pLists.running; p ; p=p->next)
  {
    if(p->pid == pid)
    {
      p->priority = priority;
      p->budget = BUDGET*(p->priority+1);
      release(&ptable.lock);
      return 0;
    }
  }

  release(&ptable.lock);
  return -1;
}

void
promoteAll(void)
{
  struct proc *p;
  for(int i = 0; i < MAXPRIO+1; ++i)
  {
    for(p = ptable.pLists.ready[i]; p; p=p->next)
    {
      if(i>0)
      {
#ifdef CS333_P3P4
        if(stateListRemove(&ptable.pLists.ready[p->priority], &ptable.pLists.readyTail[p->priority], p))
          panic("Error removing process from current priority");
        p->priority -= 1;
        if(stateListAdd(&ptable.pLists.ready[p->priority], &ptable.pLists.readyTail[p->priority], p))
          panic("Error adding process to desired priority");
#endif
      }
      p->budget = BUDGET*(p->priority+1);
    }
  }
  for(p = ptable.pLists.sleep; p; p=p->next)
  {
    if(p->priority > 0)
    {
      p->priority -= 1;
    }
    p->budget = BUDGET*(p->priority+1);
  }
  for(p = ptable.pLists.running; p; p=p->next)
  {
    if(p->priority > 0)
    {
      p->priority -= 1;
    }
    p->budget = BUDGET*(p->priority+1);
  }
}

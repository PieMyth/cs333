
_ps:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "user.h"
#include "uproc.h"
int
main(int argc, char * argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	57                   	push   %edi
   e:	56                   	push   %esi
   f:	53                   	push   %ebx
  10:	51                   	push   %ecx
  11:	83 ec 28             	sub    $0x28,%esp
  //array size for ps command
  int max = 72;
  14:	c7 45 e0 48 00 00 00 	movl   $0x48,-0x20(%ebp)

  struct uproc * proctable;
  proctable = malloc(max*sizeof(struct uproc));
  1b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1e:	89 d0                	mov    %edx,%eax
  20:	01 c0                	add    %eax,%eax
  22:	01 d0                	add    %edx,%eax
  24:	c1 e0 05             	shl    $0x5,%eax
  27:	83 ec 0c             	sub    $0xc,%esp
  2a:	50                   	push   %eax
  2b:	e8 d7 0a 00 00       	call   b07 <malloc>
  30:	83 c4 10             	add    $0x10,%esp
  33:	89 45 dc             	mov    %eax,-0x24(%ebp)
  int collected = getprocs(max,proctable);
  36:	8b 45 e0             	mov    -0x20(%ebp),%eax
  39:	83 ec 08             	sub    $0x8,%esp
  3c:	ff 75 dc             	pushl  -0x24(%ebp)
  3f:	50                   	push   %eax
  40:	e8 08 07 00 00       	call   74d <getprocs>
  45:	83 c4 10             	add    $0x10,%esp
  48:	89 45 d8             	mov    %eax,-0x28(%ebp)

  //if there was a problem with getprocs, catch it and alert user.
  if(collected<=0)
  4b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  4f:	7f 17                	jg     68 <main+0x68>
  {
    printf(1,"There was an error getting the process table.\n");
  51:	83 ec 08             	sub    $0x8,%esp
  54:	68 ec 0b 00 00       	push   $0xbec
  59:	6a 01                	push   $0x1
  5b:	e8 d4 07 00 00       	call   834 <printf>
  60:	83 c4 10             	add    $0x10,%esp
  63:	e9 d0 02 00 00       	jmp    338 <main+0x338>
  }
  else
  {
    //Header
    printf(1,"PID\tUID\tGID\tPPID\tPrio\tElapsed\tCPU\tSate\tSize\tName\n");
  68:	83 ec 08             	sub    $0x8,%esp
  6b:	68 1c 0c 00 00       	push   $0xc1c
  70:	6a 01                	push   $0x1
  72:	e8 bd 07 00 00       	call   834 <printf>
  77:	83 c4 10             	add    $0x10,%esp
    //Print everything that was copied in the array.
    for(int i = 0; i<collected; ++i)
  7a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  81:	e9 a6 02 00 00       	jmp    32c <main+0x32c>
    {
      printf(1,"%d\t%d\t%d\t%d\t%d\t%d.", proctable[i].pid, proctable[i].uid, proctable[i].gid, proctable[i].ppid, proctable[i].priority,
                                          proctable[i].elapsed_ticks/1000);
  86:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  89:	89 d0                	mov    %edx,%eax
  8b:	01 c0                	add    %eax,%eax
  8d:	01 d0                	add    %edx,%eax
  8f:	c1 e0 05             	shl    $0x5,%eax
  92:	89 c2                	mov    %eax,%edx
  94:	8b 45 dc             	mov    -0x24(%ebp),%eax
  97:	01 d0                	add    %edx,%eax
  99:	8b 40 10             	mov    0x10(%eax),%eax
    //Header
    printf(1,"PID\tUID\tGID\tPPID\tPrio\tElapsed\tCPU\tSate\tSize\tName\n");
    //Print everything that was copied in the array.
    for(int i = 0; i<collected; ++i)
    {
      printf(1,"%d\t%d\t%d\t%d\t%d\t%d.", proctable[i].pid, proctable[i].uid, proctable[i].gid, proctable[i].ppid, proctable[i].priority,
  9c:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  a1:	f7 e2                	mul    %edx
  a3:	c1 ea 06             	shr    $0x6,%edx
  a6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  ac:	89 d0                	mov    %edx,%eax
  ae:	01 c0                	add    %eax,%eax
  b0:	01 d0                	add    %edx,%eax
  b2:	c1 e0 05             	shl    $0x5,%eax
  b5:	89 c2                	mov    %eax,%edx
  b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  ba:	01 d0                	add    %edx,%eax
  bc:	8b 78 5c             	mov    0x5c(%eax),%edi
  bf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  c2:	89 d0                	mov    %edx,%eax
  c4:	01 c0                	add    %eax,%eax
  c6:	01 d0                	add    %edx,%eax
  c8:	c1 e0 05             	shl    $0x5,%eax
  cb:	89 c2                	mov    %eax,%edx
  cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  d0:	01 d0                	add    %edx,%eax
  d2:	8b 70 0c             	mov    0xc(%eax),%esi
  d5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  d8:	89 d0                	mov    %edx,%eax
  da:	01 c0                	add    %eax,%eax
  dc:	01 d0                	add    %edx,%eax
  de:	c1 e0 05             	shl    $0x5,%eax
  e1:	89 c2                	mov    %eax,%edx
  e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  e6:	01 d0                	add    %edx,%eax
  e8:	8b 58 08             	mov    0x8(%eax),%ebx
  eb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  ee:	89 d0                	mov    %edx,%eax
  f0:	01 c0                	add    %eax,%eax
  f2:	01 d0                	add    %edx,%eax
  f4:	c1 e0 05             	shl    $0x5,%eax
  f7:	89 c2                	mov    %eax,%edx
  f9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  fc:	01 d0                	add    %edx,%eax
  fe:	8b 48 04             	mov    0x4(%eax),%ecx
 101:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 104:	89 d0                	mov    %edx,%eax
 106:	01 c0                	add    %eax,%eax
 108:	01 d0                	add    %edx,%eax
 10a:	c1 e0 05             	shl    $0x5,%eax
 10d:	89 c2                	mov    %eax,%edx
 10f:	8b 45 dc             	mov    -0x24(%ebp),%eax
 112:	01 d0                	add    %edx,%eax
 114:	8b 00                	mov    (%eax),%eax
 116:	ff 75 d4             	pushl  -0x2c(%ebp)
 119:	57                   	push   %edi
 11a:	56                   	push   %esi
 11b:	53                   	push   %ebx
 11c:	51                   	push   %ecx
 11d:	50                   	push   %eax
 11e:	68 4e 0c 00 00       	push   $0xc4e
 123:	6a 01                	push   $0x1
 125:	e8 0a 07 00 00       	call   834 <printf>
 12a:	83 c4 20             	add    $0x20,%esp
                                          proctable[i].elapsed_ticks/1000);
      if(proctable[i].elapsed_ticks%1000 < 100)
 12d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 130:	89 d0                	mov    %edx,%eax
 132:	01 c0                	add    %eax,%eax
 134:	01 d0                	add    %edx,%eax
 136:	c1 e0 05             	shl    $0x5,%eax
 139:	89 c2                	mov    %eax,%edx
 13b:	8b 45 dc             	mov    -0x24(%ebp),%eax
 13e:	01 d0                	add    %edx,%eax
 140:	8b 48 10             	mov    0x10(%eax),%ecx
 143:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
 148:	89 c8                	mov    %ecx,%eax
 14a:	f7 e2                	mul    %edx
 14c:	89 d0                	mov    %edx,%eax
 14e:	c1 e8 06             	shr    $0x6,%eax
 151:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
 157:	29 c1                	sub    %eax,%ecx
 159:	89 c8                	mov    %ecx,%eax
 15b:	83 f8 63             	cmp    $0x63,%eax
 15e:	77 12                	ja     172 <main+0x172>
        printf(1,"0");
 160:	83 ec 08             	sub    $0x8,%esp
 163:	68 61 0c 00 00       	push   $0xc61
 168:	6a 01                	push   $0x1
 16a:	e8 c5 06 00 00       	call   834 <printf>
 16f:	83 c4 10             	add    $0x10,%esp
      if(proctable[i].elapsed_ticks%1000 < 10)
 172:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 175:	89 d0                	mov    %edx,%eax
 177:	01 c0                	add    %eax,%eax
 179:	01 d0                	add    %edx,%eax
 17b:	c1 e0 05             	shl    $0x5,%eax
 17e:	89 c2                	mov    %eax,%edx
 180:	8b 45 dc             	mov    -0x24(%ebp),%eax
 183:	01 d0                	add    %edx,%eax
 185:	8b 48 10             	mov    0x10(%eax),%ecx
 188:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
 18d:	89 c8                	mov    %ecx,%eax
 18f:	f7 e2                	mul    %edx
 191:	89 d0                	mov    %edx,%eax
 193:	c1 e8 06             	shr    $0x6,%eax
 196:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
 19c:	29 c1                	sub    %eax,%ecx
 19e:	89 c8                	mov    %ecx,%eax
 1a0:	83 f8 09             	cmp    $0x9,%eax
 1a3:	77 12                	ja     1b7 <main+0x1b7>
        printf(1,"0");
 1a5:	83 ec 08             	sub    $0x8,%esp
 1a8:	68 61 0c 00 00       	push   $0xc61
 1ad:	6a 01                	push   $0x1
 1af:	e8 80 06 00 00       	call   834 <printf>
 1b4:	83 c4 10             	add    $0x10,%esp
      printf(1,"%d\t%d.",proctable[i].elapsed_ticks%1000, proctable[i].CPU_total_ticks/1000);
 1b7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 1ba:	89 d0                	mov    %edx,%eax
 1bc:	01 c0                	add    %eax,%eax
 1be:	01 d0                	add    %edx,%eax
 1c0:	c1 e0 05             	shl    $0x5,%eax
 1c3:	89 c2                	mov    %eax,%edx
 1c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
 1c8:	01 d0                	add    %edx,%eax
 1ca:	8b 40 14             	mov    0x14(%eax),%eax
 1cd:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
 1d2:	f7 e2                	mul    %edx
 1d4:	89 d3                	mov    %edx,%ebx
 1d6:	c1 eb 06             	shr    $0x6,%ebx
 1d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 1dc:	89 d0                	mov    %edx,%eax
 1de:	01 c0                	add    %eax,%eax
 1e0:	01 d0                	add    %edx,%eax
 1e2:	c1 e0 05             	shl    $0x5,%eax
 1e5:	89 c2                	mov    %eax,%edx
 1e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
 1ea:	01 d0                	add    %edx,%eax
 1ec:	8b 48 10             	mov    0x10(%eax),%ecx
 1ef:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
 1f4:	89 c8                	mov    %ecx,%eax
 1f6:	f7 e2                	mul    %edx
 1f8:	89 d0                	mov    %edx,%eax
 1fa:	c1 e8 06             	shr    $0x6,%eax
 1fd:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
 203:	29 c1                	sub    %eax,%ecx
 205:	89 c8                	mov    %ecx,%eax
 207:	53                   	push   %ebx
 208:	50                   	push   %eax
 209:	68 63 0c 00 00       	push   $0xc63
 20e:	6a 01                	push   $0x1
 210:	e8 1f 06 00 00       	call   834 <printf>
 215:	83 c4 10             	add    $0x10,%esp
      if(proctable[i].CPU_total_ticks%1000 < 100)
 218:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 21b:	89 d0                	mov    %edx,%eax
 21d:	01 c0                	add    %eax,%eax
 21f:	01 d0                	add    %edx,%eax
 221:	c1 e0 05             	shl    $0x5,%eax
 224:	89 c2                	mov    %eax,%edx
 226:	8b 45 dc             	mov    -0x24(%ebp),%eax
 229:	01 d0                	add    %edx,%eax
 22b:	8b 48 14             	mov    0x14(%eax),%ecx
 22e:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
 233:	89 c8                	mov    %ecx,%eax
 235:	f7 e2                	mul    %edx
 237:	89 d0                	mov    %edx,%eax
 239:	c1 e8 06             	shr    $0x6,%eax
 23c:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
 242:	29 c1                	sub    %eax,%ecx
 244:	89 c8                	mov    %ecx,%eax
 246:	83 f8 63             	cmp    $0x63,%eax
 249:	77 12                	ja     25d <main+0x25d>
        printf(1,"0");
 24b:	83 ec 08             	sub    $0x8,%esp
 24e:	68 61 0c 00 00       	push   $0xc61
 253:	6a 01                	push   $0x1
 255:	e8 da 05 00 00       	call   834 <printf>
 25a:	83 c4 10             	add    $0x10,%esp
      if(proctable[i].CPU_total_ticks%1000 < 10)
 25d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 260:	89 d0                	mov    %edx,%eax
 262:	01 c0                	add    %eax,%eax
 264:	01 d0                	add    %edx,%eax
 266:	c1 e0 05             	shl    $0x5,%eax
 269:	89 c2                	mov    %eax,%edx
 26b:	8b 45 dc             	mov    -0x24(%ebp),%eax
 26e:	01 d0                	add    %edx,%eax
 270:	8b 48 14             	mov    0x14(%eax),%ecx
 273:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
 278:	89 c8                	mov    %ecx,%eax
 27a:	f7 e2                	mul    %edx
 27c:	89 d0                	mov    %edx,%eax
 27e:	c1 e8 06             	shr    $0x6,%eax
 281:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
 287:	29 c1                	sub    %eax,%ecx
 289:	89 c8                	mov    %ecx,%eax
 28b:	83 f8 09             	cmp    $0x9,%eax
 28e:	77 12                	ja     2a2 <main+0x2a2>
        printf(1,"0");
 290:	83 ec 08             	sub    $0x8,%esp
 293:	68 61 0c 00 00       	push   $0xc61
 298:	6a 01                	push   $0x1
 29a:	e8 95 05 00 00       	call   834 <printf>
 29f:	83 c4 10             	add    $0x10,%esp
      printf(1,"%d\t%s\t%d\t%s\n", proctable[i].CPU_total_ticks%1000, proctable[i].state, proctable[i].size, proctable[i].name);
 2a2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 2a5:	89 d0                	mov    %edx,%eax
 2a7:	01 c0                	add    %eax,%eax
 2a9:	01 d0                	add    %edx,%eax
 2ab:	c1 e0 05             	shl    $0x5,%eax
 2ae:	89 c2                	mov    %eax,%edx
 2b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
 2b3:	01 d0                	add    %edx,%eax
 2b5:	8d 78 3c             	lea    0x3c(%eax),%edi
 2b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 2bb:	89 d0                	mov    %edx,%eax
 2bd:	01 c0                	add    %eax,%eax
 2bf:	01 d0                	add    %edx,%eax
 2c1:	c1 e0 05             	shl    $0x5,%eax
 2c4:	89 c2                	mov    %eax,%edx
 2c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
 2c9:	01 d0                	add    %edx,%eax
 2cb:	8b 58 38             	mov    0x38(%eax),%ebx
 2ce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 2d1:	89 d0                	mov    %edx,%eax
 2d3:	01 c0                	add    %eax,%eax
 2d5:	01 d0                	add    %edx,%eax
 2d7:	c1 e0 05             	shl    $0x5,%eax
 2da:	89 c2                	mov    %eax,%edx
 2dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
 2df:	01 d0                	add    %edx,%eax
 2e1:	8d 70 18             	lea    0x18(%eax),%esi
 2e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 2e7:	89 d0                	mov    %edx,%eax
 2e9:	01 c0                	add    %eax,%eax
 2eb:	01 d0                	add    %edx,%eax
 2ed:	c1 e0 05             	shl    $0x5,%eax
 2f0:	89 c2                	mov    %eax,%edx
 2f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
 2f5:	01 d0                	add    %edx,%eax
 2f7:	8b 48 14             	mov    0x14(%eax),%ecx
 2fa:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
 2ff:	89 c8                	mov    %ecx,%eax
 301:	f7 e2                	mul    %edx
 303:	89 d0                	mov    %edx,%eax
 305:	c1 e8 06             	shr    $0x6,%eax
 308:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
 30e:	29 c1                	sub    %eax,%ecx
 310:	89 c8                	mov    %ecx,%eax
 312:	83 ec 08             	sub    $0x8,%esp
 315:	57                   	push   %edi
 316:	53                   	push   %ebx
 317:	56                   	push   %esi
 318:	50                   	push   %eax
 319:	68 6a 0c 00 00       	push   $0xc6a
 31e:	6a 01                	push   $0x1
 320:	e8 0f 05 00 00       	call   834 <printf>
 325:	83 c4 20             	add    $0x20,%esp
  else
  {
    //Header
    printf(1,"PID\tUID\tGID\tPPID\tPrio\tElapsed\tCPU\tSate\tSize\tName\n");
    //Print everything that was copied in the array.
    for(int i = 0; i<collected; ++i)
 328:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
 32c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 32f:	3b 45 d8             	cmp    -0x28(%ebp),%eax
 332:	0f 8c 4e fd ff ff    	jl     86 <main+0x86>
      if(proctable[i].CPU_total_ticks%1000 < 10)
        printf(1,"0");
      printf(1,"%d\t%s\t%d\t%s\n", proctable[i].CPU_total_ticks%1000, proctable[i].state, proctable[i].size, proctable[i].name);
    }
  }
  free(proctable);
 338:	83 ec 0c             	sub    $0xc,%esp
 33b:	ff 75 dc             	pushl  -0x24(%ebp)
 33e:	e8 82 06 00 00       	call   9c5 <free>
 343:	83 c4 10             	add    $0x10,%esp
//printf(1, "Not imlpemented yet.\n");
  exit();
 346:	e8 2a 03 00 00       	call   675 <exit>

0000034b <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 34b:	55                   	push   %ebp
 34c:	89 e5                	mov    %esp,%ebp
 34e:	57                   	push   %edi
 34f:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 350:	8b 4d 08             	mov    0x8(%ebp),%ecx
 353:	8b 55 10             	mov    0x10(%ebp),%edx
 356:	8b 45 0c             	mov    0xc(%ebp),%eax
 359:	89 cb                	mov    %ecx,%ebx
 35b:	89 df                	mov    %ebx,%edi
 35d:	89 d1                	mov    %edx,%ecx
 35f:	fc                   	cld    
 360:	f3 aa                	rep stos %al,%es:(%edi)
 362:	89 ca                	mov    %ecx,%edx
 364:	89 fb                	mov    %edi,%ebx
 366:	89 5d 08             	mov    %ebx,0x8(%ebp)
 369:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 36c:	90                   	nop
 36d:	5b                   	pop    %ebx
 36e:	5f                   	pop    %edi
 36f:	5d                   	pop    %ebp
 370:	c3                   	ret    

00000371 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 371:	55                   	push   %ebp
 372:	89 e5                	mov    %esp,%ebp
 374:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 377:	8b 45 08             	mov    0x8(%ebp),%eax
 37a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 37d:	90                   	nop
 37e:	8b 45 08             	mov    0x8(%ebp),%eax
 381:	8d 50 01             	lea    0x1(%eax),%edx
 384:	89 55 08             	mov    %edx,0x8(%ebp)
 387:	8b 55 0c             	mov    0xc(%ebp),%edx
 38a:	8d 4a 01             	lea    0x1(%edx),%ecx
 38d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 390:	0f b6 12             	movzbl (%edx),%edx
 393:	88 10                	mov    %dl,(%eax)
 395:	0f b6 00             	movzbl (%eax),%eax
 398:	84 c0                	test   %al,%al
 39a:	75 e2                	jne    37e <strcpy+0xd>
    ;
  return os;
 39c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 39f:	c9                   	leave  
 3a0:	c3                   	ret    

000003a1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3a1:	55                   	push   %ebp
 3a2:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3a4:	eb 08                	jmp    3ae <strcmp+0xd>
    p++, q++;
 3a6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3aa:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 3ae:	8b 45 08             	mov    0x8(%ebp),%eax
 3b1:	0f b6 00             	movzbl (%eax),%eax
 3b4:	84 c0                	test   %al,%al
 3b6:	74 10                	je     3c8 <strcmp+0x27>
 3b8:	8b 45 08             	mov    0x8(%ebp),%eax
 3bb:	0f b6 10             	movzbl (%eax),%edx
 3be:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c1:	0f b6 00             	movzbl (%eax),%eax
 3c4:	38 c2                	cmp    %al,%dl
 3c6:	74 de                	je     3a6 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 3c8:	8b 45 08             	mov    0x8(%ebp),%eax
 3cb:	0f b6 00             	movzbl (%eax),%eax
 3ce:	0f b6 d0             	movzbl %al,%edx
 3d1:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d4:	0f b6 00             	movzbl (%eax),%eax
 3d7:	0f b6 c0             	movzbl %al,%eax
 3da:	29 c2                	sub    %eax,%edx
 3dc:	89 d0                	mov    %edx,%eax
}
 3de:	5d                   	pop    %ebp
 3df:	c3                   	ret    

000003e0 <strlen>:

uint
strlen(char *s)
{
 3e0:	55                   	push   %ebp
 3e1:	89 e5                	mov    %esp,%ebp
 3e3:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3e6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3ed:	eb 04                	jmp    3f3 <strlen+0x13>
 3ef:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3f3:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3f6:	8b 45 08             	mov    0x8(%ebp),%eax
 3f9:	01 d0                	add    %edx,%eax
 3fb:	0f b6 00             	movzbl (%eax),%eax
 3fe:	84 c0                	test   %al,%al
 400:	75 ed                	jne    3ef <strlen+0xf>
    ;
  return n;
 402:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 405:	c9                   	leave  
 406:	c3                   	ret    

00000407 <memset>:

void*
memset(void *dst, int c, uint n)
{
 407:	55                   	push   %ebp
 408:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 40a:	8b 45 10             	mov    0x10(%ebp),%eax
 40d:	50                   	push   %eax
 40e:	ff 75 0c             	pushl  0xc(%ebp)
 411:	ff 75 08             	pushl  0x8(%ebp)
 414:	e8 32 ff ff ff       	call   34b <stosb>
 419:	83 c4 0c             	add    $0xc,%esp
  return dst;
 41c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 41f:	c9                   	leave  
 420:	c3                   	ret    

00000421 <strchr>:

char*
strchr(const char *s, char c)
{
 421:	55                   	push   %ebp
 422:	89 e5                	mov    %esp,%ebp
 424:	83 ec 04             	sub    $0x4,%esp
 427:	8b 45 0c             	mov    0xc(%ebp),%eax
 42a:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 42d:	eb 14                	jmp    443 <strchr+0x22>
    if(*s == c)
 42f:	8b 45 08             	mov    0x8(%ebp),%eax
 432:	0f b6 00             	movzbl (%eax),%eax
 435:	3a 45 fc             	cmp    -0x4(%ebp),%al
 438:	75 05                	jne    43f <strchr+0x1e>
      return (char*)s;
 43a:	8b 45 08             	mov    0x8(%ebp),%eax
 43d:	eb 13                	jmp    452 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 43f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 443:	8b 45 08             	mov    0x8(%ebp),%eax
 446:	0f b6 00             	movzbl (%eax),%eax
 449:	84 c0                	test   %al,%al
 44b:	75 e2                	jne    42f <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 44d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 452:	c9                   	leave  
 453:	c3                   	ret    

00000454 <gets>:

char*
gets(char *buf, int max)
{
 454:	55                   	push   %ebp
 455:	89 e5                	mov    %esp,%ebp
 457:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 45a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 461:	eb 42                	jmp    4a5 <gets+0x51>
    cc = read(0, &c, 1);
 463:	83 ec 04             	sub    $0x4,%esp
 466:	6a 01                	push   $0x1
 468:	8d 45 ef             	lea    -0x11(%ebp),%eax
 46b:	50                   	push   %eax
 46c:	6a 00                	push   $0x0
 46e:	e8 1a 02 00 00       	call   68d <read>
 473:	83 c4 10             	add    $0x10,%esp
 476:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 479:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 47d:	7e 33                	jle    4b2 <gets+0x5e>
      break;
    buf[i++] = c;
 47f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 482:	8d 50 01             	lea    0x1(%eax),%edx
 485:	89 55 f4             	mov    %edx,-0xc(%ebp)
 488:	89 c2                	mov    %eax,%edx
 48a:	8b 45 08             	mov    0x8(%ebp),%eax
 48d:	01 c2                	add    %eax,%edx
 48f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 493:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 495:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 499:	3c 0a                	cmp    $0xa,%al
 49b:	74 16                	je     4b3 <gets+0x5f>
 49d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4a1:	3c 0d                	cmp    $0xd,%al
 4a3:	74 0e                	je     4b3 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4a8:	83 c0 01             	add    $0x1,%eax
 4ab:	3b 45 0c             	cmp    0xc(%ebp),%eax
 4ae:	7c b3                	jl     463 <gets+0xf>
 4b0:	eb 01                	jmp    4b3 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 4b2:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 4b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4b6:	8b 45 08             	mov    0x8(%ebp),%eax
 4b9:	01 d0                	add    %edx,%eax
 4bb:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4be:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4c1:	c9                   	leave  
 4c2:	c3                   	ret    

000004c3 <stat>:

int
stat(char *n, struct stat *st)
{
 4c3:	55                   	push   %ebp
 4c4:	89 e5                	mov    %esp,%ebp
 4c6:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4c9:	83 ec 08             	sub    $0x8,%esp
 4cc:	6a 00                	push   $0x0
 4ce:	ff 75 08             	pushl  0x8(%ebp)
 4d1:	e8 df 01 00 00       	call   6b5 <open>
 4d6:	83 c4 10             	add    $0x10,%esp
 4d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4dc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4e0:	79 07                	jns    4e9 <stat+0x26>
    return -1;
 4e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4e7:	eb 25                	jmp    50e <stat+0x4b>
  r = fstat(fd, st);
 4e9:	83 ec 08             	sub    $0x8,%esp
 4ec:	ff 75 0c             	pushl  0xc(%ebp)
 4ef:	ff 75 f4             	pushl  -0xc(%ebp)
 4f2:	e8 d6 01 00 00       	call   6cd <fstat>
 4f7:	83 c4 10             	add    $0x10,%esp
 4fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 4fd:	83 ec 0c             	sub    $0xc,%esp
 500:	ff 75 f4             	pushl  -0xc(%ebp)
 503:	e8 95 01 00 00       	call   69d <close>
 508:	83 c4 10             	add    $0x10,%esp
  return r;
 50b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 50e:	c9                   	leave  
 50f:	c3                   	ret    

00000510 <atoi>:

int
atoi(const char *s)
{
 510:	55                   	push   %ebp
 511:	89 e5                	mov    %esp,%ebp
 513:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 516:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 51d:	eb 04                	jmp    523 <atoi+0x13>
 51f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 523:	8b 45 08             	mov    0x8(%ebp),%eax
 526:	0f b6 00             	movzbl (%eax),%eax
 529:	3c 20                	cmp    $0x20,%al
 52b:	74 f2                	je     51f <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 52d:	8b 45 08             	mov    0x8(%ebp),%eax
 530:	0f b6 00             	movzbl (%eax),%eax
 533:	3c 2d                	cmp    $0x2d,%al
 535:	75 07                	jne    53e <atoi+0x2e>
 537:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 53c:	eb 05                	jmp    543 <atoi+0x33>
 53e:	b8 01 00 00 00       	mov    $0x1,%eax
 543:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 546:	8b 45 08             	mov    0x8(%ebp),%eax
 549:	0f b6 00             	movzbl (%eax),%eax
 54c:	3c 2b                	cmp    $0x2b,%al
 54e:	74 0a                	je     55a <atoi+0x4a>
 550:	8b 45 08             	mov    0x8(%ebp),%eax
 553:	0f b6 00             	movzbl (%eax),%eax
 556:	3c 2d                	cmp    $0x2d,%al
 558:	75 2b                	jne    585 <atoi+0x75>
    s++;
 55a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 55e:	eb 25                	jmp    585 <atoi+0x75>
    n = n*10 + *s++ - '0';
 560:	8b 55 fc             	mov    -0x4(%ebp),%edx
 563:	89 d0                	mov    %edx,%eax
 565:	c1 e0 02             	shl    $0x2,%eax
 568:	01 d0                	add    %edx,%eax
 56a:	01 c0                	add    %eax,%eax
 56c:	89 c1                	mov    %eax,%ecx
 56e:	8b 45 08             	mov    0x8(%ebp),%eax
 571:	8d 50 01             	lea    0x1(%eax),%edx
 574:	89 55 08             	mov    %edx,0x8(%ebp)
 577:	0f b6 00             	movzbl (%eax),%eax
 57a:	0f be c0             	movsbl %al,%eax
 57d:	01 c8                	add    %ecx,%eax
 57f:	83 e8 30             	sub    $0x30,%eax
 582:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
 585:	8b 45 08             	mov    0x8(%ebp),%eax
 588:	0f b6 00             	movzbl (%eax),%eax
 58b:	3c 2f                	cmp    $0x2f,%al
 58d:	7e 0a                	jle    599 <atoi+0x89>
 58f:	8b 45 08             	mov    0x8(%ebp),%eax
 592:	0f b6 00             	movzbl (%eax),%eax
 595:	3c 39                	cmp    $0x39,%al
 597:	7e c7                	jle    560 <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 599:	8b 45 f8             	mov    -0x8(%ebp),%eax
 59c:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 5a0:	c9                   	leave  
 5a1:	c3                   	ret    

000005a2 <atoo>:

int
atoo(const char *s)
{
 5a2:	55                   	push   %ebp
 5a3:	89 e5                	mov    %esp,%ebp
 5a5:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 5a8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 5af:	eb 04                	jmp    5b5 <atoo+0x13>
 5b1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 5b5:	8b 45 08             	mov    0x8(%ebp),%eax
 5b8:	0f b6 00             	movzbl (%eax),%eax
 5bb:	3c 20                	cmp    $0x20,%al
 5bd:	74 f2                	je     5b1 <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 5bf:	8b 45 08             	mov    0x8(%ebp),%eax
 5c2:	0f b6 00             	movzbl (%eax),%eax
 5c5:	3c 2d                	cmp    $0x2d,%al
 5c7:	75 07                	jne    5d0 <atoo+0x2e>
 5c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 5ce:	eb 05                	jmp    5d5 <atoo+0x33>
 5d0:	b8 01 00 00 00       	mov    $0x1,%eax
 5d5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 5d8:	8b 45 08             	mov    0x8(%ebp),%eax
 5db:	0f b6 00             	movzbl (%eax),%eax
 5de:	3c 2b                	cmp    $0x2b,%al
 5e0:	74 0a                	je     5ec <atoo+0x4a>
 5e2:	8b 45 08             	mov    0x8(%ebp),%eax
 5e5:	0f b6 00             	movzbl (%eax),%eax
 5e8:	3c 2d                	cmp    $0x2d,%al
 5ea:	75 27                	jne    613 <atoo+0x71>
    s++;
 5ec:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 5f0:	eb 21                	jmp    613 <atoo+0x71>
    n = n*8 + *s++ - '0';
 5f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5f5:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 5fc:	8b 45 08             	mov    0x8(%ebp),%eax
 5ff:	8d 50 01             	lea    0x1(%eax),%edx
 602:	89 55 08             	mov    %edx,0x8(%ebp)
 605:	0f b6 00             	movzbl (%eax),%eax
 608:	0f be c0             	movsbl %al,%eax
 60b:	01 c8                	add    %ecx,%eax
 60d:	83 e8 30             	sub    $0x30,%eax
 610:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 613:	8b 45 08             	mov    0x8(%ebp),%eax
 616:	0f b6 00             	movzbl (%eax),%eax
 619:	3c 2f                	cmp    $0x2f,%al
 61b:	7e 0a                	jle    627 <atoo+0x85>
 61d:	8b 45 08             	mov    0x8(%ebp),%eax
 620:	0f b6 00             	movzbl (%eax),%eax
 623:	3c 37                	cmp    $0x37,%al
 625:	7e cb                	jle    5f2 <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 627:	8b 45 f8             	mov    -0x8(%ebp),%eax
 62a:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 62e:	c9                   	leave  
 62f:	c3                   	ret    

00000630 <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 630:	55                   	push   %ebp
 631:	89 e5                	mov    %esp,%ebp
 633:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 636:	8b 45 08             	mov    0x8(%ebp),%eax
 639:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 63c:	8b 45 0c             	mov    0xc(%ebp),%eax
 63f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 642:	eb 17                	jmp    65b <memmove+0x2b>
    *dst++ = *src++;
 644:	8b 45 fc             	mov    -0x4(%ebp),%eax
 647:	8d 50 01             	lea    0x1(%eax),%edx
 64a:	89 55 fc             	mov    %edx,-0x4(%ebp)
 64d:	8b 55 f8             	mov    -0x8(%ebp),%edx
 650:	8d 4a 01             	lea    0x1(%edx),%ecx
 653:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 656:	0f b6 12             	movzbl (%edx),%edx
 659:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 65b:	8b 45 10             	mov    0x10(%ebp),%eax
 65e:	8d 50 ff             	lea    -0x1(%eax),%edx
 661:	89 55 10             	mov    %edx,0x10(%ebp)
 664:	85 c0                	test   %eax,%eax
 666:	7f dc                	jg     644 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 668:	8b 45 08             	mov    0x8(%ebp),%eax
}
 66b:	c9                   	leave  
 66c:	c3                   	ret    

0000066d <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 66d:	b8 01 00 00 00       	mov    $0x1,%eax
 672:	cd 40                	int    $0x40
 674:	c3                   	ret    

00000675 <exit>:
SYSCALL(exit)
 675:	b8 02 00 00 00       	mov    $0x2,%eax
 67a:	cd 40                	int    $0x40
 67c:	c3                   	ret    

0000067d <wait>:
SYSCALL(wait)
 67d:	b8 03 00 00 00       	mov    $0x3,%eax
 682:	cd 40                	int    $0x40
 684:	c3                   	ret    

00000685 <pipe>:
SYSCALL(pipe)
 685:	b8 04 00 00 00       	mov    $0x4,%eax
 68a:	cd 40                	int    $0x40
 68c:	c3                   	ret    

0000068d <read>:
SYSCALL(read)
 68d:	b8 05 00 00 00       	mov    $0x5,%eax
 692:	cd 40                	int    $0x40
 694:	c3                   	ret    

00000695 <write>:
SYSCALL(write)
 695:	b8 10 00 00 00       	mov    $0x10,%eax
 69a:	cd 40                	int    $0x40
 69c:	c3                   	ret    

0000069d <close>:
SYSCALL(close)
 69d:	b8 15 00 00 00       	mov    $0x15,%eax
 6a2:	cd 40                	int    $0x40
 6a4:	c3                   	ret    

000006a5 <kill>:
SYSCALL(kill)
 6a5:	b8 06 00 00 00       	mov    $0x6,%eax
 6aa:	cd 40                	int    $0x40
 6ac:	c3                   	ret    

000006ad <exec>:
SYSCALL(exec)
 6ad:	b8 07 00 00 00       	mov    $0x7,%eax
 6b2:	cd 40                	int    $0x40
 6b4:	c3                   	ret    

000006b5 <open>:
SYSCALL(open)
 6b5:	b8 0f 00 00 00       	mov    $0xf,%eax
 6ba:	cd 40                	int    $0x40
 6bc:	c3                   	ret    

000006bd <mknod>:
SYSCALL(mknod)
 6bd:	b8 11 00 00 00       	mov    $0x11,%eax
 6c2:	cd 40                	int    $0x40
 6c4:	c3                   	ret    

000006c5 <unlink>:
SYSCALL(unlink)
 6c5:	b8 12 00 00 00       	mov    $0x12,%eax
 6ca:	cd 40                	int    $0x40
 6cc:	c3                   	ret    

000006cd <fstat>:
SYSCALL(fstat)
 6cd:	b8 08 00 00 00       	mov    $0x8,%eax
 6d2:	cd 40                	int    $0x40
 6d4:	c3                   	ret    

000006d5 <link>:
SYSCALL(link)
 6d5:	b8 13 00 00 00       	mov    $0x13,%eax
 6da:	cd 40                	int    $0x40
 6dc:	c3                   	ret    

000006dd <mkdir>:
SYSCALL(mkdir)
 6dd:	b8 14 00 00 00       	mov    $0x14,%eax
 6e2:	cd 40                	int    $0x40
 6e4:	c3                   	ret    

000006e5 <chdir>:
SYSCALL(chdir)
 6e5:	b8 09 00 00 00       	mov    $0x9,%eax
 6ea:	cd 40                	int    $0x40
 6ec:	c3                   	ret    

000006ed <dup>:
SYSCALL(dup)
 6ed:	b8 0a 00 00 00       	mov    $0xa,%eax
 6f2:	cd 40                	int    $0x40
 6f4:	c3                   	ret    

000006f5 <getpid>:
SYSCALL(getpid)
 6f5:	b8 0b 00 00 00       	mov    $0xb,%eax
 6fa:	cd 40                	int    $0x40
 6fc:	c3                   	ret    

000006fd <sbrk>:
SYSCALL(sbrk)
 6fd:	b8 0c 00 00 00       	mov    $0xc,%eax
 702:	cd 40                	int    $0x40
 704:	c3                   	ret    

00000705 <sleep>:
SYSCALL(sleep)
 705:	b8 0d 00 00 00       	mov    $0xd,%eax
 70a:	cd 40                	int    $0x40
 70c:	c3                   	ret    

0000070d <uptime>:
SYSCALL(uptime)
 70d:	b8 0e 00 00 00       	mov    $0xe,%eax
 712:	cd 40                	int    $0x40
 714:	c3                   	ret    

00000715 <halt>:
SYSCALL(halt)
 715:	b8 16 00 00 00       	mov    $0x16,%eax
 71a:	cd 40                	int    $0x40
 71c:	c3                   	ret    

0000071d <date>:
SYSCALL(date)
 71d:	b8 17 00 00 00       	mov    $0x17,%eax
 722:	cd 40                	int    $0x40
 724:	c3                   	ret    

00000725 <getuid>:
SYSCALL(getuid)
 725:	b8 18 00 00 00       	mov    $0x18,%eax
 72a:	cd 40                	int    $0x40
 72c:	c3                   	ret    

0000072d <getgid>:
SYSCALL(getgid)
 72d:	b8 19 00 00 00       	mov    $0x19,%eax
 732:	cd 40                	int    $0x40
 734:	c3                   	ret    

00000735 <getppid>:
SYSCALL(getppid)
 735:	b8 1a 00 00 00       	mov    $0x1a,%eax
 73a:	cd 40                	int    $0x40
 73c:	c3                   	ret    

0000073d <setuid>:
SYSCALL(setuid)
 73d:	b8 1b 00 00 00       	mov    $0x1b,%eax
 742:	cd 40                	int    $0x40
 744:	c3                   	ret    

00000745 <setgid>:
SYSCALL(setgid)
 745:	b8 1c 00 00 00       	mov    $0x1c,%eax
 74a:	cd 40                	int    $0x40
 74c:	c3                   	ret    

0000074d <getprocs>:
SYSCALL(getprocs)
 74d:	b8 1a 00 00 00       	mov    $0x1a,%eax
 752:	cd 40                	int    $0x40
 754:	c3                   	ret    

00000755 <setpriority>:
SYSCALL(setpriority)
 755:	b8 1b 00 00 00       	mov    $0x1b,%eax
 75a:	cd 40                	int    $0x40
 75c:	c3                   	ret    

0000075d <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 75d:	55                   	push   %ebp
 75e:	89 e5                	mov    %esp,%ebp
 760:	83 ec 18             	sub    $0x18,%esp
 763:	8b 45 0c             	mov    0xc(%ebp),%eax
 766:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 769:	83 ec 04             	sub    $0x4,%esp
 76c:	6a 01                	push   $0x1
 76e:	8d 45 f4             	lea    -0xc(%ebp),%eax
 771:	50                   	push   %eax
 772:	ff 75 08             	pushl  0x8(%ebp)
 775:	e8 1b ff ff ff       	call   695 <write>
 77a:	83 c4 10             	add    $0x10,%esp
}
 77d:	90                   	nop
 77e:	c9                   	leave  
 77f:	c3                   	ret    

00000780 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 780:	55                   	push   %ebp
 781:	89 e5                	mov    %esp,%ebp
 783:	53                   	push   %ebx
 784:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 787:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 78e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 792:	74 17                	je     7ab <printint+0x2b>
 794:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 798:	79 11                	jns    7ab <printint+0x2b>
    neg = 1;
 79a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 7a1:	8b 45 0c             	mov    0xc(%ebp),%eax
 7a4:	f7 d8                	neg    %eax
 7a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 7a9:	eb 06                	jmp    7b1 <printint+0x31>
  } else {
    x = xx;
 7ab:	8b 45 0c             	mov    0xc(%ebp),%eax
 7ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 7b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 7b8:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 7bb:	8d 41 01             	lea    0x1(%ecx),%eax
 7be:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
 7c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7c7:	ba 00 00 00 00       	mov    $0x0,%edx
 7cc:	f7 f3                	div    %ebx
 7ce:	89 d0                	mov    %edx,%eax
 7d0:	0f b6 80 f4 0e 00 00 	movzbl 0xef4(%eax),%eax
 7d7:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 7db:	8b 5d 10             	mov    0x10(%ebp),%ebx
 7de:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7e1:	ba 00 00 00 00       	mov    $0x0,%edx
 7e6:	f7 f3                	div    %ebx
 7e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
 7eb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7ef:	75 c7                	jne    7b8 <printint+0x38>
  if(neg)
 7f1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7f5:	74 2d                	je     824 <printint+0xa4>
    buf[i++] = '-';
 7f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7fa:	8d 50 01             	lea    0x1(%eax),%edx
 7fd:	89 55 f4             	mov    %edx,-0xc(%ebp)
 800:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 805:	eb 1d                	jmp    824 <printint+0xa4>
    putc(fd, buf[i]);
 807:	8d 55 dc             	lea    -0x24(%ebp),%edx
 80a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80d:	01 d0                	add    %edx,%eax
 80f:	0f b6 00             	movzbl (%eax),%eax
 812:	0f be c0             	movsbl %al,%eax
 815:	83 ec 08             	sub    $0x8,%esp
 818:	50                   	push   %eax
 819:	ff 75 08             	pushl  0x8(%ebp)
 81c:	e8 3c ff ff ff       	call   75d <putc>
 821:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 824:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 828:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 82c:	79 d9                	jns    807 <printint+0x87>
    putc(fd, buf[i]);
}
 82e:	90                   	nop
 82f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 832:	c9                   	leave  
 833:	c3                   	ret    

00000834 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 834:	55                   	push   %ebp
 835:	89 e5                	mov    %esp,%ebp
 837:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 83a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 841:	8d 45 0c             	lea    0xc(%ebp),%eax
 844:	83 c0 04             	add    $0x4,%eax
 847:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 84a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 851:	e9 59 01 00 00       	jmp    9af <printf+0x17b>
    c = fmt[i] & 0xff;
 856:	8b 55 0c             	mov    0xc(%ebp),%edx
 859:	8b 45 f0             	mov    -0x10(%ebp),%eax
 85c:	01 d0                	add    %edx,%eax
 85e:	0f b6 00             	movzbl (%eax),%eax
 861:	0f be c0             	movsbl %al,%eax
 864:	25 ff 00 00 00       	and    $0xff,%eax
 869:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 86c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 870:	75 2c                	jne    89e <printf+0x6a>
      if(c == '%'){
 872:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 876:	75 0c                	jne    884 <printf+0x50>
        state = '%';
 878:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 87f:	e9 27 01 00 00       	jmp    9ab <printf+0x177>
      } else {
        putc(fd, c);
 884:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 887:	0f be c0             	movsbl %al,%eax
 88a:	83 ec 08             	sub    $0x8,%esp
 88d:	50                   	push   %eax
 88e:	ff 75 08             	pushl  0x8(%ebp)
 891:	e8 c7 fe ff ff       	call   75d <putc>
 896:	83 c4 10             	add    $0x10,%esp
 899:	e9 0d 01 00 00       	jmp    9ab <printf+0x177>
      }
    } else if(state == '%'){
 89e:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 8a2:	0f 85 03 01 00 00    	jne    9ab <printf+0x177>
      if(c == 'd'){
 8a8:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 8ac:	75 1e                	jne    8cc <printf+0x98>
        printint(fd, *ap, 10, 1);
 8ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8b1:	8b 00                	mov    (%eax),%eax
 8b3:	6a 01                	push   $0x1
 8b5:	6a 0a                	push   $0xa
 8b7:	50                   	push   %eax
 8b8:	ff 75 08             	pushl  0x8(%ebp)
 8bb:	e8 c0 fe ff ff       	call   780 <printint>
 8c0:	83 c4 10             	add    $0x10,%esp
        ap++;
 8c3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8c7:	e9 d8 00 00 00       	jmp    9a4 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 8cc:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 8d0:	74 06                	je     8d8 <printf+0xa4>
 8d2:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 8d6:	75 1e                	jne    8f6 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 8d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8db:	8b 00                	mov    (%eax),%eax
 8dd:	6a 00                	push   $0x0
 8df:	6a 10                	push   $0x10
 8e1:	50                   	push   %eax
 8e2:	ff 75 08             	pushl  0x8(%ebp)
 8e5:	e8 96 fe ff ff       	call   780 <printint>
 8ea:	83 c4 10             	add    $0x10,%esp
        ap++;
 8ed:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8f1:	e9 ae 00 00 00       	jmp    9a4 <printf+0x170>
      } else if(c == 's'){
 8f6:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 8fa:	75 43                	jne    93f <printf+0x10b>
        s = (char*)*ap;
 8fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8ff:	8b 00                	mov    (%eax),%eax
 901:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 904:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 908:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 90c:	75 25                	jne    933 <printf+0xff>
          s = "(null)";
 90e:	c7 45 f4 77 0c 00 00 	movl   $0xc77,-0xc(%ebp)
        while(*s != 0){
 915:	eb 1c                	jmp    933 <printf+0xff>
          putc(fd, *s);
 917:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91a:	0f b6 00             	movzbl (%eax),%eax
 91d:	0f be c0             	movsbl %al,%eax
 920:	83 ec 08             	sub    $0x8,%esp
 923:	50                   	push   %eax
 924:	ff 75 08             	pushl  0x8(%ebp)
 927:	e8 31 fe ff ff       	call   75d <putc>
 92c:	83 c4 10             	add    $0x10,%esp
          s++;
 92f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 933:	8b 45 f4             	mov    -0xc(%ebp),%eax
 936:	0f b6 00             	movzbl (%eax),%eax
 939:	84 c0                	test   %al,%al
 93b:	75 da                	jne    917 <printf+0xe3>
 93d:	eb 65                	jmp    9a4 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 93f:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 943:	75 1d                	jne    962 <printf+0x12e>
        putc(fd, *ap);
 945:	8b 45 e8             	mov    -0x18(%ebp),%eax
 948:	8b 00                	mov    (%eax),%eax
 94a:	0f be c0             	movsbl %al,%eax
 94d:	83 ec 08             	sub    $0x8,%esp
 950:	50                   	push   %eax
 951:	ff 75 08             	pushl  0x8(%ebp)
 954:	e8 04 fe ff ff       	call   75d <putc>
 959:	83 c4 10             	add    $0x10,%esp
        ap++;
 95c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 960:	eb 42                	jmp    9a4 <printf+0x170>
      } else if(c == '%'){
 962:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 966:	75 17                	jne    97f <printf+0x14b>
        putc(fd, c);
 968:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 96b:	0f be c0             	movsbl %al,%eax
 96e:	83 ec 08             	sub    $0x8,%esp
 971:	50                   	push   %eax
 972:	ff 75 08             	pushl  0x8(%ebp)
 975:	e8 e3 fd ff ff       	call   75d <putc>
 97a:	83 c4 10             	add    $0x10,%esp
 97d:	eb 25                	jmp    9a4 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 97f:	83 ec 08             	sub    $0x8,%esp
 982:	6a 25                	push   $0x25
 984:	ff 75 08             	pushl  0x8(%ebp)
 987:	e8 d1 fd ff ff       	call   75d <putc>
 98c:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 98f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 992:	0f be c0             	movsbl %al,%eax
 995:	83 ec 08             	sub    $0x8,%esp
 998:	50                   	push   %eax
 999:	ff 75 08             	pushl  0x8(%ebp)
 99c:	e8 bc fd ff ff       	call   75d <putc>
 9a1:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 9a4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 9ab:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 9af:	8b 55 0c             	mov    0xc(%ebp),%edx
 9b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9b5:	01 d0                	add    %edx,%eax
 9b7:	0f b6 00             	movzbl (%eax),%eax
 9ba:	84 c0                	test   %al,%al
 9bc:	0f 85 94 fe ff ff    	jne    856 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 9c2:	90                   	nop
 9c3:	c9                   	leave  
 9c4:	c3                   	ret    

000009c5 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 9c5:	55                   	push   %ebp
 9c6:	89 e5                	mov    %esp,%ebp
 9c8:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 9cb:	8b 45 08             	mov    0x8(%ebp),%eax
 9ce:	83 e8 08             	sub    $0x8,%eax
 9d1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9d4:	a1 10 0f 00 00       	mov    0xf10,%eax
 9d9:	89 45 fc             	mov    %eax,-0x4(%ebp)
 9dc:	eb 24                	jmp    a02 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9de:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e1:	8b 00                	mov    (%eax),%eax
 9e3:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9e6:	77 12                	ja     9fa <free+0x35>
 9e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9eb:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9ee:	77 24                	ja     a14 <free+0x4f>
 9f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9f3:	8b 00                	mov    (%eax),%eax
 9f5:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9f8:	77 1a                	ja     a14 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9fd:	8b 00                	mov    (%eax),%eax
 9ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
 a02:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a05:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 a08:	76 d4                	jbe    9de <free+0x19>
 a0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a0d:	8b 00                	mov    (%eax),%eax
 a0f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 a12:	76 ca                	jbe    9de <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 a14:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a17:	8b 40 04             	mov    0x4(%eax),%eax
 a1a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 a21:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a24:	01 c2                	add    %eax,%edx
 a26:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a29:	8b 00                	mov    (%eax),%eax
 a2b:	39 c2                	cmp    %eax,%edx
 a2d:	75 24                	jne    a53 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 a2f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a32:	8b 50 04             	mov    0x4(%eax),%edx
 a35:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a38:	8b 00                	mov    (%eax),%eax
 a3a:	8b 40 04             	mov    0x4(%eax),%eax
 a3d:	01 c2                	add    %eax,%edx
 a3f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a42:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 a45:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a48:	8b 00                	mov    (%eax),%eax
 a4a:	8b 10                	mov    (%eax),%edx
 a4c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a4f:	89 10                	mov    %edx,(%eax)
 a51:	eb 0a                	jmp    a5d <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 a53:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a56:	8b 10                	mov    (%eax),%edx
 a58:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a5b:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 a5d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a60:	8b 40 04             	mov    0x4(%eax),%eax
 a63:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 a6a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a6d:	01 d0                	add    %edx,%eax
 a6f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 a72:	75 20                	jne    a94 <free+0xcf>
    p->s.size += bp->s.size;
 a74:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a77:	8b 50 04             	mov    0x4(%eax),%edx
 a7a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a7d:	8b 40 04             	mov    0x4(%eax),%eax
 a80:	01 c2                	add    %eax,%edx
 a82:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a85:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 a88:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a8b:	8b 10                	mov    (%eax),%edx
 a8d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a90:	89 10                	mov    %edx,(%eax)
 a92:	eb 08                	jmp    a9c <free+0xd7>
  } else
    p->s.ptr = bp;
 a94:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a97:	8b 55 f8             	mov    -0x8(%ebp),%edx
 a9a:	89 10                	mov    %edx,(%eax)
  freep = p;
 a9c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a9f:	a3 10 0f 00 00       	mov    %eax,0xf10
}
 aa4:	90                   	nop
 aa5:	c9                   	leave  
 aa6:	c3                   	ret    

00000aa7 <morecore>:

static Header*
morecore(uint nu)
{
 aa7:	55                   	push   %ebp
 aa8:	89 e5                	mov    %esp,%ebp
 aaa:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 aad:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 ab4:	77 07                	ja     abd <morecore+0x16>
    nu = 4096;
 ab6:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 abd:	8b 45 08             	mov    0x8(%ebp),%eax
 ac0:	c1 e0 03             	shl    $0x3,%eax
 ac3:	83 ec 0c             	sub    $0xc,%esp
 ac6:	50                   	push   %eax
 ac7:	e8 31 fc ff ff       	call   6fd <sbrk>
 acc:	83 c4 10             	add    $0x10,%esp
 acf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 ad2:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 ad6:	75 07                	jne    adf <morecore+0x38>
    return 0;
 ad8:	b8 00 00 00 00       	mov    $0x0,%eax
 add:	eb 26                	jmp    b05 <morecore+0x5e>
  hp = (Header*)p;
 adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ae2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 ae5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ae8:	8b 55 08             	mov    0x8(%ebp),%edx
 aeb:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 aee:	8b 45 f0             	mov    -0x10(%ebp),%eax
 af1:	83 c0 08             	add    $0x8,%eax
 af4:	83 ec 0c             	sub    $0xc,%esp
 af7:	50                   	push   %eax
 af8:	e8 c8 fe ff ff       	call   9c5 <free>
 afd:	83 c4 10             	add    $0x10,%esp
  return freep;
 b00:	a1 10 0f 00 00       	mov    0xf10,%eax
}
 b05:	c9                   	leave  
 b06:	c3                   	ret    

00000b07 <malloc>:

void*
malloc(uint nbytes)
{
 b07:	55                   	push   %ebp
 b08:	89 e5                	mov    %esp,%ebp
 b0a:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b0d:	8b 45 08             	mov    0x8(%ebp),%eax
 b10:	83 c0 07             	add    $0x7,%eax
 b13:	c1 e8 03             	shr    $0x3,%eax
 b16:	83 c0 01             	add    $0x1,%eax
 b19:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 b1c:	a1 10 0f 00 00       	mov    0xf10,%eax
 b21:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b24:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 b28:	75 23                	jne    b4d <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 b2a:	c7 45 f0 08 0f 00 00 	movl   $0xf08,-0x10(%ebp)
 b31:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b34:	a3 10 0f 00 00       	mov    %eax,0xf10
 b39:	a1 10 0f 00 00       	mov    0xf10,%eax
 b3e:	a3 08 0f 00 00       	mov    %eax,0xf08
    base.s.size = 0;
 b43:	c7 05 0c 0f 00 00 00 	movl   $0x0,0xf0c
 b4a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b50:	8b 00                	mov    (%eax),%eax
 b52:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b55:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b58:	8b 40 04             	mov    0x4(%eax),%eax
 b5b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 b5e:	72 4d                	jb     bad <malloc+0xa6>
      if(p->s.size == nunits)
 b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b63:	8b 40 04             	mov    0x4(%eax),%eax
 b66:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 b69:	75 0c                	jne    b77 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b6e:	8b 10                	mov    (%eax),%edx
 b70:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b73:	89 10                	mov    %edx,(%eax)
 b75:	eb 26                	jmp    b9d <malloc+0x96>
      else {
        p->s.size -= nunits;
 b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b7a:	8b 40 04             	mov    0x4(%eax),%eax
 b7d:	2b 45 ec             	sub    -0x14(%ebp),%eax
 b80:	89 c2                	mov    %eax,%edx
 b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b85:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b8b:	8b 40 04             	mov    0x4(%eax),%eax
 b8e:	c1 e0 03             	shl    $0x3,%eax
 b91:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 b94:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b97:	8b 55 ec             	mov    -0x14(%ebp),%edx
 b9a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 b9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ba0:	a3 10 0f 00 00       	mov    %eax,0xf10
      return (void*)(p + 1);
 ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ba8:	83 c0 08             	add    $0x8,%eax
 bab:	eb 3b                	jmp    be8 <malloc+0xe1>
    }
    if(p == freep)
 bad:	a1 10 0f 00 00       	mov    0xf10,%eax
 bb2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 bb5:	75 1e                	jne    bd5 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 bb7:	83 ec 0c             	sub    $0xc,%esp
 bba:	ff 75 ec             	pushl  -0x14(%ebp)
 bbd:	e8 e5 fe ff ff       	call   aa7 <morecore>
 bc2:	83 c4 10             	add    $0x10,%esp
 bc5:	89 45 f4             	mov    %eax,-0xc(%ebp)
 bc8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 bcc:	75 07                	jne    bd5 <malloc+0xce>
        return 0;
 bce:	b8 00 00 00 00       	mov    $0x0,%eax
 bd3:	eb 13                	jmp    be8 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bd8:	89 45 f0             	mov    %eax,-0x10(%ebp)
 bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bde:	8b 00                	mov    (%eax),%eax
 be0:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 be3:	e9 6d ff ff ff       	jmp    b55 <malloc+0x4e>
}
 be8:	c9                   	leave  
 be9:	c3                   	ret    

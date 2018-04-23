
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
  11:	83 ec 18             	sub    $0x18,%esp
  //array size for ps command
  int max = 72;
  14:	c7 45 e0 48 00 00 00 	movl   $0x48,-0x20(%ebp)

  struct uproc * proctable;
  proctable = malloc(max*sizeof(struct uproc));
  1b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1e:	6b c0 5c             	imul   $0x5c,%eax,%eax
  21:	83 ec 0c             	sub    $0xc,%esp
  24:	50                   	push   %eax
  25:	e8 40 0a 00 00       	call   a6a <malloc>
  2a:	83 c4 10             	add    $0x10,%esp
  2d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  int collected = getprocs(max,proctable);
  30:	8b 45 e0             	mov    -0x20(%ebp),%eax
  33:	83 ec 08             	sub    $0x8,%esp
  36:	ff 75 dc             	pushl  -0x24(%ebp)
  39:	50                   	push   %eax
  3a:	e8 79 06 00 00       	call   6b8 <getprocs>
  3f:	83 c4 10             	add    $0x10,%esp
  42:	89 45 d8             	mov    %eax,-0x28(%ebp)

  //if there was a problem with getprocs, catch it and alert user.
  if(collected<=0)
  45:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  49:	7f 17                	jg     62 <main+0x62>
  {
    printf(1,"There was an error getting the process table.\n");
  4b:	83 ec 08             	sub    $0x8,%esp
  4e:	68 50 0b 00 00       	push   $0xb50
  53:	6a 01                	push   $0x1
  55:	e8 3d 07 00 00       	call   797 <printf>
  5a:	83 c4 10             	add    $0x10,%esp
  5d:	e9 41 02 00 00       	jmp    2a3 <main+0x2a3>
  }
  else
  {
    //Header
    printf(1,"PID\tUID\tGID\tPPID\tElapsed\tCPU\tSate\tSize\tName\n");
  62:	83 ec 08             	sub    $0x8,%esp
  65:	68 80 0b 00 00       	push   $0xb80
  6a:	6a 01                	push   $0x1
  6c:	e8 26 07 00 00       	call   797 <printf>
  71:	83 c4 10             	add    $0x10,%esp
    //Print everything that was copied in the array.
    for(int i = 0; i<collected; ++i)
  74:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  7b:	e9 17 02 00 00       	jmp    297 <main+0x297>
    {
      printf(1,"%d\t%d\t%d\t%d\t%d.", proctable[i].pid, proctable[i].uid, proctable[i].gid, proctable[i].ppid, proctable[i].elapsed_ticks/1000);
  80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  83:	6b d0 5c             	imul   $0x5c,%eax,%edx
  86:	8b 45 dc             	mov    -0x24(%ebp),%eax
  89:	01 d0                	add    %edx,%eax
  8b:	8b 40 10             	mov    0x10(%eax),%eax
  8e:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  93:	f7 e2                	mul    %edx
  95:	89 d6                	mov    %edx,%esi
  97:	c1 ee 06             	shr    $0x6,%esi
  9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  9d:	6b d0 5c             	imul   $0x5c,%eax,%edx
  a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  a3:	01 d0                	add    %edx,%eax
  a5:	8b 58 0c             	mov    0xc(%eax),%ebx
  a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  ab:	6b d0 5c             	imul   $0x5c,%eax,%edx
  ae:	8b 45 dc             	mov    -0x24(%ebp),%eax
  b1:	01 d0                	add    %edx,%eax
  b3:	8b 48 08             	mov    0x8(%eax),%ecx
  b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  b9:	6b d0 5c             	imul   $0x5c,%eax,%edx
  bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  bf:	01 d0                	add    %edx,%eax
  c1:	8b 50 04             	mov    0x4(%eax),%edx
  c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  c7:	6b f8 5c             	imul   $0x5c,%eax,%edi
  ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
  cd:	01 f8                	add    %edi,%eax
  cf:	8b 00                	mov    (%eax),%eax
  d1:	83 ec 04             	sub    $0x4,%esp
  d4:	56                   	push   %esi
  d5:	53                   	push   %ebx
  d6:	51                   	push   %ecx
  d7:	52                   	push   %edx
  d8:	50                   	push   %eax
  d9:	68 ad 0b 00 00       	push   $0xbad
  de:	6a 01                	push   $0x1
  e0:	e8 b2 06 00 00       	call   797 <printf>
  e5:	83 c4 20             	add    $0x20,%esp
      if(proctable[i].elapsed_ticks%1000 < 100)
  e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  eb:	6b d0 5c             	imul   $0x5c,%eax,%edx
  ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
  f1:	01 d0                	add    %edx,%eax
  f3:	8b 48 10             	mov    0x10(%eax),%ecx
  f6:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  fb:	89 c8                	mov    %ecx,%eax
  fd:	f7 e2                	mul    %edx
  ff:	89 d0                	mov    %edx,%eax
 101:	c1 e8 06             	shr    $0x6,%eax
 104:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
 10a:	29 c1                	sub    %eax,%ecx
 10c:	89 c8                	mov    %ecx,%eax
 10e:	83 f8 63             	cmp    $0x63,%eax
 111:	77 12                	ja     125 <main+0x125>
        printf(1,"0");
 113:	83 ec 08             	sub    $0x8,%esp
 116:	68 bd 0b 00 00       	push   $0xbbd
 11b:	6a 01                	push   $0x1
 11d:	e8 75 06 00 00       	call   797 <printf>
 122:	83 c4 10             	add    $0x10,%esp
      if(proctable[i].elapsed_ticks%1000 < 10)
 125:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 128:	6b d0 5c             	imul   $0x5c,%eax,%edx
 12b:	8b 45 dc             	mov    -0x24(%ebp),%eax
 12e:	01 d0                	add    %edx,%eax
 130:	8b 48 10             	mov    0x10(%eax),%ecx
 133:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
 138:	89 c8                	mov    %ecx,%eax
 13a:	f7 e2                	mul    %edx
 13c:	89 d0                	mov    %edx,%eax
 13e:	c1 e8 06             	shr    $0x6,%eax
 141:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
 147:	29 c1                	sub    %eax,%ecx
 149:	89 c8                	mov    %ecx,%eax
 14b:	83 f8 09             	cmp    $0x9,%eax
 14e:	77 12                	ja     162 <main+0x162>
        printf(1,"0");
 150:	83 ec 08             	sub    $0x8,%esp
 153:	68 bd 0b 00 00       	push   $0xbbd
 158:	6a 01                	push   $0x1
 15a:	e8 38 06 00 00       	call   797 <printf>
 15f:	83 c4 10             	add    $0x10,%esp
      printf(1,"%d\t%d.",proctable[i].elapsed_ticks%1000, proctable[i].CPU_total_ticks/1000);
 162:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 165:	6b d0 5c             	imul   $0x5c,%eax,%edx
 168:	8b 45 dc             	mov    -0x24(%ebp),%eax
 16b:	01 d0                	add    %edx,%eax
 16d:	8b 40 14             	mov    0x14(%eax),%eax
 170:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
 175:	f7 e2                	mul    %edx
 177:	89 d3                	mov    %edx,%ebx
 179:	c1 eb 06             	shr    $0x6,%ebx
 17c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 17f:	6b d0 5c             	imul   $0x5c,%eax,%edx
 182:	8b 45 dc             	mov    -0x24(%ebp),%eax
 185:	01 d0                	add    %edx,%eax
 187:	8b 48 10             	mov    0x10(%eax),%ecx
 18a:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
 18f:	89 c8                	mov    %ecx,%eax
 191:	f7 e2                	mul    %edx
 193:	89 d0                	mov    %edx,%eax
 195:	c1 e8 06             	shr    $0x6,%eax
 198:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
 19e:	29 c1                	sub    %eax,%ecx
 1a0:	89 c8                	mov    %ecx,%eax
 1a2:	53                   	push   %ebx
 1a3:	50                   	push   %eax
 1a4:	68 bf 0b 00 00       	push   $0xbbf
 1a9:	6a 01                	push   $0x1
 1ab:	e8 e7 05 00 00       	call   797 <printf>
 1b0:	83 c4 10             	add    $0x10,%esp
      if(proctable[i].CPU_total_ticks%1000 < 100)
 1b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 1b6:	6b d0 5c             	imul   $0x5c,%eax,%edx
 1b9:	8b 45 dc             	mov    -0x24(%ebp),%eax
 1bc:	01 d0                	add    %edx,%eax
 1be:	8b 48 14             	mov    0x14(%eax),%ecx
 1c1:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
 1c6:	89 c8                	mov    %ecx,%eax
 1c8:	f7 e2                	mul    %edx
 1ca:	89 d0                	mov    %edx,%eax
 1cc:	c1 e8 06             	shr    $0x6,%eax
 1cf:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
 1d5:	29 c1                	sub    %eax,%ecx
 1d7:	89 c8                	mov    %ecx,%eax
 1d9:	83 f8 63             	cmp    $0x63,%eax
 1dc:	77 12                	ja     1f0 <main+0x1f0>
        printf(1,"0");
 1de:	83 ec 08             	sub    $0x8,%esp
 1e1:	68 bd 0b 00 00       	push   $0xbbd
 1e6:	6a 01                	push   $0x1
 1e8:	e8 aa 05 00 00       	call   797 <printf>
 1ed:	83 c4 10             	add    $0x10,%esp
      if(proctable[i].CPU_total_ticks%1000 < 10)
 1f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 1f3:	6b d0 5c             	imul   $0x5c,%eax,%edx
 1f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
 1f9:	01 d0                	add    %edx,%eax
 1fb:	8b 48 14             	mov    0x14(%eax),%ecx
 1fe:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
 203:	89 c8                	mov    %ecx,%eax
 205:	f7 e2                	mul    %edx
 207:	89 d0                	mov    %edx,%eax
 209:	c1 e8 06             	shr    $0x6,%eax
 20c:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
 212:	29 c1                	sub    %eax,%ecx
 214:	89 c8                	mov    %ecx,%eax
 216:	83 f8 09             	cmp    $0x9,%eax
 219:	77 12                	ja     22d <main+0x22d>
        printf(1,"0");
 21b:	83 ec 08             	sub    $0x8,%esp
 21e:	68 bd 0b 00 00       	push   $0xbbd
 223:	6a 01                	push   $0x1
 225:	e8 6d 05 00 00       	call   797 <printf>
 22a:	83 c4 10             	add    $0x10,%esp
      printf(1,"%d\t%s\t%d\t%s\n", proctable[i].CPU_total_ticks%1000, proctable[i].state, proctable[i].size, proctable[i].name);
 22d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 230:	6b d0 5c             	imul   $0x5c,%eax,%edx
 233:	8b 45 dc             	mov    -0x24(%ebp),%eax
 236:	01 d0                	add    %edx,%eax
 238:	8d 78 3c             	lea    0x3c(%eax),%edi
 23b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 23e:	6b d0 5c             	imul   $0x5c,%eax,%edx
 241:	8b 45 dc             	mov    -0x24(%ebp),%eax
 244:	01 d0                	add    %edx,%eax
 246:	8b 58 38             	mov    0x38(%eax),%ebx
 249:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 24c:	6b d0 5c             	imul   $0x5c,%eax,%edx
 24f:	8b 45 dc             	mov    -0x24(%ebp),%eax
 252:	01 d0                	add    %edx,%eax
 254:	8d 70 18             	lea    0x18(%eax),%esi
 257:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 25a:	6b d0 5c             	imul   $0x5c,%eax,%edx
 25d:	8b 45 dc             	mov    -0x24(%ebp),%eax
 260:	01 d0                	add    %edx,%eax
 262:	8b 48 14             	mov    0x14(%eax),%ecx
 265:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
 26a:	89 c8                	mov    %ecx,%eax
 26c:	f7 e2                	mul    %edx
 26e:	89 d0                	mov    %edx,%eax
 270:	c1 e8 06             	shr    $0x6,%eax
 273:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
 279:	29 c1                	sub    %eax,%ecx
 27b:	89 c8                	mov    %ecx,%eax
 27d:	83 ec 08             	sub    $0x8,%esp
 280:	57                   	push   %edi
 281:	53                   	push   %ebx
 282:	56                   	push   %esi
 283:	50                   	push   %eax
 284:	68 c6 0b 00 00       	push   $0xbc6
 289:	6a 01                	push   $0x1
 28b:	e8 07 05 00 00       	call   797 <printf>
 290:	83 c4 20             	add    $0x20,%esp
  else
  {
    //Header
    printf(1,"PID\tUID\tGID\tPPID\tElapsed\tCPU\tSate\tSize\tName\n");
    //Print everything that was copied in the array.
    for(int i = 0; i<collected; ++i)
 293:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
 297:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 29a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
 29d:	0f 8c dd fd ff ff    	jl     80 <main+0x80>
      if(proctable[i].CPU_total_ticks%1000 < 10)
        printf(1,"0");
      printf(1,"%d\t%s\t%d\t%s\n", proctable[i].CPU_total_ticks%1000, proctable[i].state, proctable[i].size, proctable[i].name);
    }
  }
  free(proctable);
 2a3:	83 ec 0c             	sub    $0xc,%esp
 2a6:	ff 75 dc             	pushl  -0x24(%ebp)
 2a9:	e8 7a 06 00 00       	call   928 <free>
 2ae:	83 c4 10             	add    $0x10,%esp
//printf(1, "Not imlpemented yet.\n");
  exit();
 2b1:	e8 2a 03 00 00       	call   5e0 <exit>

000002b6 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2b6:	55                   	push   %ebp
 2b7:	89 e5                	mov    %esp,%ebp
 2b9:	57                   	push   %edi
 2ba:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2be:	8b 55 10             	mov    0x10(%ebp),%edx
 2c1:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c4:	89 cb                	mov    %ecx,%ebx
 2c6:	89 df                	mov    %ebx,%edi
 2c8:	89 d1                	mov    %edx,%ecx
 2ca:	fc                   	cld    
 2cb:	f3 aa                	rep stos %al,%es:(%edi)
 2cd:	89 ca                	mov    %ecx,%edx
 2cf:	89 fb                	mov    %edi,%ebx
 2d1:	89 5d 08             	mov    %ebx,0x8(%ebp)
 2d4:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2d7:	90                   	nop
 2d8:	5b                   	pop    %ebx
 2d9:	5f                   	pop    %edi
 2da:	5d                   	pop    %ebp
 2db:	c3                   	ret    

000002dc <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 2dc:	55                   	push   %ebp
 2dd:	89 e5                	mov    %esp,%ebp
 2df:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 2e2:	8b 45 08             	mov    0x8(%ebp),%eax
 2e5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 2e8:	90                   	nop
 2e9:	8b 45 08             	mov    0x8(%ebp),%eax
 2ec:	8d 50 01             	lea    0x1(%eax),%edx
 2ef:	89 55 08             	mov    %edx,0x8(%ebp)
 2f2:	8b 55 0c             	mov    0xc(%ebp),%edx
 2f5:	8d 4a 01             	lea    0x1(%edx),%ecx
 2f8:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 2fb:	0f b6 12             	movzbl (%edx),%edx
 2fe:	88 10                	mov    %dl,(%eax)
 300:	0f b6 00             	movzbl (%eax),%eax
 303:	84 c0                	test   %al,%al
 305:	75 e2                	jne    2e9 <strcpy+0xd>
    ;
  return os;
 307:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 30a:	c9                   	leave  
 30b:	c3                   	ret    

0000030c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 30c:	55                   	push   %ebp
 30d:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 30f:	eb 08                	jmp    319 <strcmp+0xd>
    p++, q++;
 311:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 315:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 319:	8b 45 08             	mov    0x8(%ebp),%eax
 31c:	0f b6 00             	movzbl (%eax),%eax
 31f:	84 c0                	test   %al,%al
 321:	74 10                	je     333 <strcmp+0x27>
 323:	8b 45 08             	mov    0x8(%ebp),%eax
 326:	0f b6 10             	movzbl (%eax),%edx
 329:	8b 45 0c             	mov    0xc(%ebp),%eax
 32c:	0f b6 00             	movzbl (%eax),%eax
 32f:	38 c2                	cmp    %al,%dl
 331:	74 de                	je     311 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 333:	8b 45 08             	mov    0x8(%ebp),%eax
 336:	0f b6 00             	movzbl (%eax),%eax
 339:	0f b6 d0             	movzbl %al,%edx
 33c:	8b 45 0c             	mov    0xc(%ebp),%eax
 33f:	0f b6 00             	movzbl (%eax),%eax
 342:	0f b6 c0             	movzbl %al,%eax
 345:	29 c2                	sub    %eax,%edx
 347:	89 d0                	mov    %edx,%eax
}
 349:	5d                   	pop    %ebp
 34a:	c3                   	ret    

0000034b <strlen>:

uint
strlen(char *s)
{
 34b:	55                   	push   %ebp
 34c:	89 e5                	mov    %esp,%ebp
 34e:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 351:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 358:	eb 04                	jmp    35e <strlen+0x13>
 35a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 35e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 361:	8b 45 08             	mov    0x8(%ebp),%eax
 364:	01 d0                	add    %edx,%eax
 366:	0f b6 00             	movzbl (%eax),%eax
 369:	84 c0                	test   %al,%al
 36b:	75 ed                	jne    35a <strlen+0xf>
    ;
  return n;
 36d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 370:	c9                   	leave  
 371:	c3                   	ret    

00000372 <memset>:

void*
memset(void *dst, int c, uint n)
{
 372:	55                   	push   %ebp
 373:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 375:	8b 45 10             	mov    0x10(%ebp),%eax
 378:	50                   	push   %eax
 379:	ff 75 0c             	pushl  0xc(%ebp)
 37c:	ff 75 08             	pushl  0x8(%ebp)
 37f:	e8 32 ff ff ff       	call   2b6 <stosb>
 384:	83 c4 0c             	add    $0xc,%esp
  return dst;
 387:	8b 45 08             	mov    0x8(%ebp),%eax
}
 38a:	c9                   	leave  
 38b:	c3                   	ret    

0000038c <strchr>:

char*
strchr(const char *s, char c)
{
 38c:	55                   	push   %ebp
 38d:	89 e5                	mov    %esp,%ebp
 38f:	83 ec 04             	sub    $0x4,%esp
 392:	8b 45 0c             	mov    0xc(%ebp),%eax
 395:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 398:	eb 14                	jmp    3ae <strchr+0x22>
    if(*s == c)
 39a:	8b 45 08             	mov    0x8(%ebp),%eax
 39d:	0f b6 00             	movzbl (%eax),%eax
 3a0:	3a 45 fc             	cmp    -0x4(%ebp),%al
 3a3:	75 05                	jne    3aa <strchr+0x1e>
      return (char*)s;
 3a5:	8b 45 08             	mov    0x8(%ebp),%eax
 3a8:	eb 13                	jmp    3bd <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 3aa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3ae:	8b 45 08             	mov    0x8(%ebp),%eax
 3b1:	0f b6 00             	movzbl (%eax),%eax
 3b4:	84 c0                	test   %al,%al
 3b6:	75 e2                	jne    39a <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 3b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3bd:	c9                   	leave  
 3be:	c3                   	ret    

000003bf <gets>:

char*
gets(char *buf, int max)
{
 3bf:	55                   	push   %ebp
 3c0:	89 e5                	mov    %esp,%ebp
 3c2:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3cc:	eb 42                	jmp    410 <gets+0x51>
    cc = read(0, &c, 1);
 3ce:	83 ec 04             	sub    $0x4,%esp
 3d1:	6a 01                	push   $0x1
 3d3:	8d 45 ef             	lea    -0x11(%ebp),%eax
 3d6:	50                   	push   %eax
 3d7:	6a 00                	push   $0x0
 3d9:	e8 1a 02 00 00       	call   5f8 <read>
 3de:	83 c4 10             	add    $0x10,%esp
 3e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 3e4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3e8:	7e 33                	jle    41d <gets+0x5e>
      break;
    buf[i++] = c;
 3ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3ed:	8d 50 01             	lea    0x1(%eax),%edx
 3f0:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3f3:	89 c2                	mov    %eax,%edx
 3f5:	8b 45 08             	mov    0x8(%ebp),%eax
 3f8:	01 c2                	add    %eax,%edx
 3fa:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3fe:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 400:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 404:	3c 0a                	cmp    $0xa,%al
 406:	74 16                	je     41e <gets+0x5f>
 408:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 40c:	3c 0d                	cmp    $0xd,%al
 40e:	74 0e                	je     41e <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 410:	8b 45 f4             	mov    -0xc(%ebp),%eax
 413:	83 c0 01             	add    $0x1,%eax
 416:	3b 45 0c             	cmp    0xc(%ebp),%eax
 419:	7c b3                	jl     3ce <gets+0xf>
 41b:	eb 01                	jmp    41e <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 41d:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 41e:	8b 55 f4             	mov    -0xc(%ebp),%edx
 421:	8b 45 08             	mov    0x8(%ebp),%eax
 424:	01 d0                	add    %edx,%eax
 426:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 429:	8b 45 08             	mov    0x8(%ebp),%eax
}
 42c:	c9                   	leave  
 42d:	c3                   	ret    

0000042e <stat>:

int
stat(char *n, struct stat *st)
{
 42e:	55                   	push   %ebp
 42f:	89 e5                	mov    %esp,%ebp
 431:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 434:	83 ec 08             	sub    $0x8,%esp
 437:	6a 00                	push   $0x0
 439:	ff 75 08             	pushl  0x8(%ebp)
 43c:	e8 df 01 00 00       	call   620 <open>
 441:	83 c4 10             	add    $0x10,%esp
 444:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 447:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 44b:	79 07                	jns    454 <stat+0x26>
    return -1;
 44d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 452:	eb 25                	jmp    479 <stat+0x4b>
  r = fstat(fd, st);
 454:	83 ec 08             	sub    $0x8,%esp
 457:	ff 75 0c             	pushl  0xc(%ebp)
 45a:	ff 75 f4             	pushl  -0xc(%ebp)
 45d:	e8 d6 01 00 00       	call   638 <fstat>
 462:	83 c4 10             	add    $0x10,%esp
 465:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 468:	83 ec 0c             	sub    $0xc,%esp
 46b:	ff 75 f4             	pushl  -0xc(%ebp)
 46e:	e8 95 01 00 00       	call   608 <close>
 473:	83 c4 10             	add    $0x10,%esp
  return r;
 476:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 479:	c9                   	leave  
 47a:	c3                   	ret    

0000047b <atoi>:

int
atoi(const char *s)
{
 47b:	55                   	push   %ebp
 47c:	89 e5                	mov    %esp,%ebp
 47e:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 481:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 488:	eb 04                	jmp    48e <atoi+0x13>
 48a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 48e:	8b 45 08             	mov    0x8(%ebp),%eax
 491:	0f b6 00             	movzbl (%eax),%eax
 494:	3c 20                	cmp    $0x20,%al
 496:	74 f2                	je     48a <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 498:	8b 45 08             	mov    0x8(%ebp),%eax
 49b:	0f b6 00             	movzbl (%eax),%eax
 49e:	3c 2d                	cmp    $0x2d,%al
 4a0:	75 07                	jne    4a9 <atoi+0x2e>
 4a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4a7:	eb 05                	jmp    4ae <atoi+0x33>
 4a9:	b8 01 00 00 00       	mov    $0x1,%eax
 4ae:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 4b1:	8b 45 08             	mov    0x8(%ebp),%eax
 4b4:	0f b6 00             	movzbl (%eax),%eax
 4b7:	3c 2b                	cmp    $0x2b,%al
 4b9:	74 0a                	je     4c5 <atoi+0x4a>
 4bb:	8b 45 08             	mov    0x8(%ebp),%eax
 4be:	0f b6 00             	movzbl (%eax),%eax
 4c1:	3c 2d                	cmp    $0x2d,%al
 4c3:	75 2b                	jne    4f0 <atoi+0x75>
    s++;
 4c5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 4c9:	eb 25                	jmp    4f0 <atoi+0x75>
    n = n*10 + *s++ - '0';
 4cb:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4ce:	89 d0                	mov    %edx,%eax
 4d0:	c1 e0 02             	shl    $0x2,%eax
 4d3:	01 d0                	add    %edx,%eax
 4d5:	01 c0                	add    %eax,%eax
 4d7:	89 c1                	mov    %eax,%ecx
 4d9:	8b 45 08             	mov    0x8(%ebp),%eax
 4dc:	8d 50 01             	lea    0x1(%eax),%edx
 4df:	89 55 08             	mov    %edx,0x8(%ebp)
 4e2:	0f b6 00             	movzbl (%eax),%eax
 4e5:	0f be c0             	movsbl %al,%eax
 4e8:	01 c8                	add    %ecx,%eax
 4ea:	83 e8 30             	sub    $0x30,%eax
 4ed:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
 4f0:	8b 45 08             	mov    0x8(%ebp),%eax
 4f3:	0f b6 00             	movzbl (%eax),%eax
 4f6:	3c 2f                	cmp    $0x2f,%al
 4f8:	7e 0a                	jle    504 <atoi+0x89>
 4fa:	8b 45 08             	mov    0x8(%ebp),%eax
 4fd:	0f b6 00             	movzbl (%eax),%eax
 500:	3c 39                	cmp    $0x39,%al
 502:	7e c7                	jle    4cb <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 504:	8b 45 f8             	mov    -0x8(%ebp),%eax
 507:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 50b:	c9                   	leave  
 50c:	c3                   	ret    

0000050d <atoo>:

int
atoo(const char *s)
{
 50d:	55                   	push   %ebp
 50e:	89 e5                	mov    %esp,%ebp
 510:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 513:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 51a:	eb 04                	jmp    520 <atoo+0x13>
 51c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 520:	8b 45 08             	mov    0x8(%ebp),%eax
 523:	0f b6 00             	movzbl (%eax),%eax
 526:	3c 20                	cmp    $0x20,%al
 528:	74 f2                	je     51c <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 52a:	8b 45 08             	mov    0x8(%ebp),%eax
 52d:	0f b6 00             	movzbl (%eax),%eax
 530:	3c 2d                	cmp    $0x2d,%al
 532:	75 07                	jne    53b <atoo+0x2e>
 534:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 539:	eb 05                	jmp    540 <atoo+0x33>
 53b:	b8 01 00 00 00       	mov    $0x1,%eax
 540:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 543:	8b 45 08             	mov    0x8(%ebp),%eax
 546:	0f b6 00             	movzbl (%eax),%eax
 549:	3c 2b                	cmp    $0x2b,%al
 54b:	74 0a                	je     557 <atoo+0x4a>
 54d:	8b 45 08             	mov    0x8(%ebp),%eax
 550:	0f b6 00             	movzbl (%eax),%eax
 553:	3c 2d                	cmp    $0x2d,%al
 555:	75 27                	jne    57e <atoo+0x71>
    s++;
 557:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 55b:	eb 21                	jmp    57e <atoo+0x71>
    n = n*8 + *s++ - '0';
 55d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 560:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 567:	8b 45 08             	mov    0x8(%ebp),%eax
 56a:	8d 50 01             	lea    0x1(%eax),%edx
 56d:	89 55 08             	mov    %edx,0x8(%ebp)
 570:	0f b6 00             	movzbl (%eax),%eax
 573:	0f be c0             	movsbl %al,%eax
 576:	01 c8                	add    %ecx,%eax
 578:	83 e8 30             	sub    $0x30,%eax
 57b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 57e:	8b 45 08             	mov    0x8(%ebp),%eax
 581:	0f b6 00             	movzbl (%eax),%eax
 584:	3c 2f                	cmp    $0x2f,%al
 586:	7e 0a                	jle    592 <atoo+0x85>
 588:	8b 45 08             	mov    0x8(%ebp),%eax
 58b:	0f b6 00             	movzbl (%eax),%eax
 58e:	3c 37                	cmp    $0x37,%al
 590:	7e cb                	jle    55d <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 592:	8b 45 f8             	mov    -0x8(%ebp),%eax
 595:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 599:	c9                   	leave  
 59a:	c3                   	ret    

0000059b <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 59b:	55                   	push   %ebp
 59c:	89 e5                	mov    %esp,%ebp
 59e:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 5a1:	8b 45 08             	mov    0x8(%ebp),%eax
 5a4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 5a7:	8b 45 0c             	mov    0xc(%ebp),%eax
 5aa:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 5ad:	eb 17                	jmp    5c6 <memmove+0x2b>
    *dst++ = *src++;
 5af:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5b2:	8d 50 01             	lea    0x1(%eax),%edx
 5b5:	89 55 fc             	mov    %edx,-0x4(%ebp)
 5b8:	8b 55 f8             	mov    -0x8(%ebp),%edx
 5bb:	8d 4a 01             	lea    0x1(%edx),%ecx
 5be:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 5c1:	0f b6 12             	movzbl (%edx),%edx
 5c4:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 5c6:	8b 45 10             	mov    0x10(%ebp),%eax
 5c9:	8d 50 ff             	lea    -0x1(%eax),%edx
 5cc:	89 55 10             	mov    %edx,0x10(%ebp)
 5cf:	85 c0                	test   %eax,%eax
 5d1:	7f dc                	jg     5af <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 5d3:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5d6:	c9                   	leave  
 5d7:	c3                   	ret    

000005d8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5d8:	b8 01 00 00 00       	mov    $0x1,%eax
 5dd:	cd 40                	int    $0x40
 5df:	c3                   	ret    

000005e0 <exit>:
SYSCALL(exit)
 5e0:	b8 02 00 00 00       	mov    $0x2,%eax
 5e5:	cd 40                	int    $0x40
 5e7:	c3                   	ret    

000005e8 <wait>:
SYSCALL(wait)
 5e8:	b8 03 00 00 00       	mov    $0x3,%eax
 5ed:	cd 40                	int    $0x40
 5ef:	c3                   	ret    

000005f0 <pipe>:
SYSCALL(pipe)
 5f0:	b8 04 00 00 00       	mov    $0x4,%eax
 5f5:	cd 40                	int    $0x40
 5f7:	c3                   	ret    

000005f8 <read>:
SYSCALL(read)
 5f8:	b8 05 00 00 00       	mov    $0x5,%eax
 5fd:	cd 40                	int    $0x40
 5ff:	c3                   	ret    

00000600 <write>:
SYSCALL(write)
 600:	b8 10 00 00 00       	mov    $0x10,%eax
 605:	cd 40                	int    $0x40
 607:	c3                   	ret    

00000608 <close>:
SYSCALL(close)
 608:	b8 15 00 00 00       	mov    $0x15,%eax
 60d:	cd 40                	int    $0x40
 60f:	c3                   	ret    

00000610 <kill>:
SYSCALL(kill)
 610:	b8 06 00 00 00       	mov    $0x6,%eax
 615:	cd 40                	int    $0x40
 617:	c3                   	ret    

00000618 <exec>:
SYSCALL(exec)
 618:	b8 07 00 00 00       	mov    $0x7,%eax
 61d:	cd 40                	int    $0x40
 61f:	c3                   	ret    

00000620 <open>:
SYSCALL(open)
 620:	b8 0f 00 00 00       	mov    $0xf,%eax
 625:	cd 40                	int    $0x40
 627:	c3                   	ret    

00000628 <mknod>:
SYSCALL(mknod)
 628:	b8 11 00 00 00       	mov    $0x11,%eax
 62d:	cd 40                	int    $0x40
 62f:	c3                   	ret    

00000630 <unlink>:
SYSCALL(unlink)
 630:	b8 12 00 00 00       	mov    $0x12,%eax
 635:	cd 40                	int    $0x40
 637:	c3                   	ret    

00000638 <fstat>:
SYSCALL(fstat)
 638:	b8 08 00 00 00       	mov    $0x8,%eax
 63d:	cd 40                	int    $0x40
 63f:	c3                   	ret    

00000640 <link>:
SYSCALL(link)
 640:	b8 13 00 00 00       	mov    $0x13,%eax
 645:	cd 40                	int    $0x40
 647:	c3                   	ret    

00000648 <mkdir>:
SYSCALL(mkdir)
 648:	b8 14 00 00 00       	mov    $0x14,%eax
 64d:	cd 40                	int    $0x40
 64f:	c3                   	ret    

00000650 <chdir>:
SYSCALL(chdir)
 650:	b8 09 00 00 00       	mov    $0x9,%eax
 655:	cd 40                	int    $0x40
 657:	c3                   	ret    

00000658 <dup>:
SYSCALL(dup)
 658:	b8 0a 00 00 00       	mov    $0xa,%eax
 65d:	cd 40                	int    $0x40
 65f:	c3                   	ret    

00000660 <getpid>:
SYSCALL(getpid)
 660:	b8 0b 00 00 00       	mov    $0xb,%eax
 665:	cd 40                	int    $0x40
 667:	c3                   	ret    

00000668 <sbrk>:
SYSCALL(sbrk)
 668:	b8 0c 00 00 00       	mov    $0xc,%eax
 66d:	cd 40                	int    $0x40
 66f:	c3                   	ret    

00000670 <sleep>:
SYSCALL(sleep)
 670:	b8 0d 00 00 00       	mov    $0xd,%eax
 675:	cd 40                	int    $0x40
 677:	c3                   	ret    

00000678 <uptime>:
SYSCALL(uptime)
 678:	b8 0e 00 00 00       	mov    $0xe,%eax
 67d:	cd 40                	int    $0x40
 67f:	c3                   	ret    

00000680 <halt>:
SYSCALL(halt)
 680:	b8 16 00 00 00       	mov    $0x16,%eax
 685:	cd 40                	int    $0x40
 687:	c3                   	ret    

00000688 <date>:
SYSCALL(date)
 688:	b8 17 00 00 00       	mov    $0x17,%eax
 68d:	cd 40                	int    $0x40
 68f:	c3                   	ret    

00000690 <getuid>:
SYSCALL(getuid)
 690:	b8 18 00 00 00       	mov    $0x18,%eax
 695:	cd 40                	int    $0x40
 697:	c3                   	ret    

00000698 <getgid>:
SYSCALL(getgid)
 698:	b8 19 00 00 00       	mov    $0x19,%eax
 69d:	cd 40                	int    $0x40
 69f:	c3                   	ret    

000006a0 <getppid>:
SYSCALL(getppid)
 6a0:	b8 1a 00 00 00       	mov    $0x1a,%eax
 6a5:	cd 40                	int    $0x40
 6a7:	c3                   	ret    

000006a8 <setuid>:
SYSCALL(setuid)
 6a8:	b8 1b 00 00 00       	mov    $0x1b,%eax
 6ad:	cd 40                	int    $0x40
 6af:	c3                   	ret    

000006b0 <setgid>:
SYSCALL(setgid)
 6b0:	b8 1c 00 00 00       	mov    $0x1c,%eax
 6b5:	cd 40                	int    $0x40
 6b7:	c3                   	ret    

000006b8 <getprocs>:
SYSCALL(getprocs)
 6b8:	b8 1a 00 00 00       	mov    $0x1a,%eax
 6bd:	cd 40                	int    $0x40
 6bf:	c3                   	ret    

000006c0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 6c0:	55                   	push   %ebp
 6c1:	89 e5                	mov    %esp,%ebp
 6c3:	83 ec 18             	sub    $0x18,%esp
 6c6:	8b 45 0c             	mov    0xc(%ebp),%eax
 6c9:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 6cc:	83 ec 04             	sub    $0x4,%esp
 6cf:	6a 01                	push   $0x1
 6d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
 6d4:	50                   	push   %eax
 6d5:	ff 75 08             	pushl  0x8(%ebp)
 6d8:	e8 23 ff ff ff       	call   600 <write>
 6dd:	83 c4 10             	add    $0x10,%esp
}
 6e0:	90                   	nop
 6e1:	c9                   	leave  
 6e2:	c3                   	ret    

000006e3 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6e3:	55                   	push   %ebp
 6e4:	89 e5                	mov    %esp,%ebp
 6e6:	53                   	push   %ebx
 6e7:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6ea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6f1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6f5:	74 17                	je     70e <printint+0x2b>
 6f7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6fb:	79 11                	jns    70e <printint+0x2b>
    neg = 1;
 6fd:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 704:	8b 45 0c             	mov    0xc(%ebp),%eax
 707:	f7 d8                	neg    %eax
 709:	89 45 ec             	mov    %eax,-0x14(%ebp)
 70c:	eb 06                	jmp    714 <printint+0x31>
  } else {
    x = xx;
 70e:	8b 45 0c             	mov    0xc(%ebp),%eax
 711:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 714:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 71b:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 71e:	8d 41 01             	lea    0x1(%ecx),%eax
 721:	89 45 f4             	mov    %eax,-0xc(%ebp)
 724:	8b 5d 10             	mov    0x10(%ebp),%ebx
 727:	8b 45 ec             	mov    -0x14(%ebp),%eax
 72a:	ba 00 00 00 00       	mov    $0x0,%edx
 72f:	f7 f3                	div    %ebx
 731:	89 d0                	mov    %edx,%eax
 733:	0f b6 80 50 0e 00 00 	movzbl 0xe50(%eax),%eax
 73a:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 73e:	8b 5d 10             	mov    0x10(%ebp),%ebx
 741:	8b 45 ec             	mov    -0x14(%ebp),%eax
 744:	ba 00 00 00 00       	mov    $0x0,%edx
 749:	f7 f3                	div    %ebx
 74b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 74e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 752:	75 c7                	jne    71b <printint+0x38>
  if(neg)
 754:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 758:	74 2d                	je     787 <printint+0xa4>
    buf[i++] = '-';
 75a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 75d:	8d 50 01             	lea    0x1(%eax),%edx
 760:	89 55 f4             	mov    %edx,-0xc(%ebp)
 763:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 768:	eb 1d                	jmp    787 <printint+0xa4>
    putc(fd, buf[i]);
 76a:	8d 55 dc             	lea    -0x24(%ebp),%edx
 76d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 770:	01 d0                	add    %edx,%eax
 772:	0f b6 00             	movzbl (%eax),%eax
 775:	0f be c0             	movsbl %al,%eax
 778:	83 ec 08             	sub    $0x8,%esp
 77b:	50                   	push   %eax
 77c:	ff 75 08             	pushl  0x8(%ebp)
 77f:	e8 3c ff ff ff       	call   6c0 <putc>
 784:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 787:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 78b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 78f:	79 d9                	jns    76a <printint+0x87>
    putc(fd, buf[i]);
}
 791:	90                   	nop
 792:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 795:	c9                   	leave  
 796:	c3                   	ret    

00000797 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 797:	55                   	push   %ebp
 798:	89 e5                	mov    %esp,%ebp
 79a:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 79d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 7a4:	8d 45 0c             	lea    0xc(%ebp),%eax
 7a7:	83 c0 04             	add    $0x4,%eax
 7aa:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 7ad:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 7b4:	e9 59 01 00 00       	jmp    912 <printf+0x17b>
    c = fmt[i] & 0xff;
 7b9:	8b 55 0c             	mov    0xc(%ebp),%edx
 7bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7bf:	01 d0                	add    %edx,%eax
 7c1:	0f b6 00             	movzbl (%eax),%eax
 7c4:	0f be c0             	movsbl %al,%eax
 7c7:	25 ff 00 00 00       	and    $0xff,%eax
 7cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 7cf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7d3:	75 2c                	jne    801 <printf+0x6a>
      if(c == '%'){
 7d5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7d9:	75 0c                	jne    7e7 <printf+0x50>
        state = '%';
 7db:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 7e2:	e9 27 01 00 00       	jmp    90e <printf+0x177>
      } else {
        putc(fd, c);
 7e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7ea:	0f be c0             	movsbl %al,%eax
 7ed:	83 ec 08             	sub    $0x8,%esp
 7f0:	50                   	push   %eax
 7f1:	ff 75 08             	pushl  0x8(%ebp)
 7f4:	e8 c7 fe ff ff       	call   6c0 <putc>
 7f9:	83 c4 10             	add    $0x10,%esp
 7fc:	e9 0d 01 00 00       	jmp    90e <printf+0x177>
      }
    } else if(state == '%'){
 801:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 805:	0f 85 03 01 00 00    	jne    90e <printf+0x177>
      if(c == 'd'){
 80b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 80f:	75 1e                	jne    82f <printf+0x98>
        printint(fd, *ap, 10, 1);
 811:	8b 45 e8             	mov    -0x18(%ebp),%eax
 814:	8b 00                	mov    (%eax),%eax
 816:	6a 01                	push   $0x1
 818:	6a 0a                	push   $0xa
 81a:	50                   	push   %eax
 81b:	ff 75 08             	pushl  0x8(%ebp)
 81e:	e8 c0 fe ff ff       	call   6e3 <printint>
 823:	83 c4 10             	add    $0x10,%esp
        ap++;
 826:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 82a:	e9 d8 00 00 00       	jmp    907 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 82f:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 833:	74 06                	je     83b <printf+0xa4>
 835:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 839:	75 1e                	jne    859 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 83b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 83e:	8b 00                	mov    (%eax),%eax
 840:	6a 00                	push   $0x0
 842:	6a 10                	push   $0x10
 844:	50                   	push   %eax
 845:	ff 75 08             	pushl  0x8(%ebp)
 848:	e8 96 fe ff ff       	call   6e3 <printint>
 84d:	83 c4 10             	add    $0x10,%esp
        ap++;
 850:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 854:	e9 ae 00 00 00       	jmp    907 <printf+0x170>
      } else if(c == 's'){
 859:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 85d:	75 43                	jne    8a2 <printf+0x10b>
        s = (char*)*ap;
 85f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 862:	8b 00                	mov    (%eax),%eax
 864:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 867:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 86b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 86f:	75 25                	jne    896 <printf+0xff>
          s = "(null)";
 871:	c7 45 f4 d3 0b 00 00 	movl   $0xbd3,-0xc(%ebp)
        while(*s != 0){
 878:	eb 1c                	jmp    896 <printf+0xff>
          putc(fd, *s);
 87a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87d:	0f b6 00             	movzbl (%eax),%eax
 880:	0f be c0             	movsbl %al,%eax
 883:	83 ec 08             	sub    $0x8,%esp
 886:	50                   	push   %eax
 887:	ff 75 08             	pushl  0x8(%ebp)
 88a:	e8 31 fe ff ff       	call   6c0 <putc>
 88f:	83 c4 10             	add    $0x10,%esp
          s++;
 892:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 896:	8b 45 f4             	mov    -0xc(%ebp),%eax
 899:	0f b6 00             	movzbl (%eax),%eax
 89c:	84 c0                	test   %al,%al
 89e:	75 da                	jne    87a <printf+0xe3>
 8a0:	eb 65                	jmp    907 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 8a2:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 8a6:	75 1d                	jne    8c5 <printf+0x12e>
        putc(fd, *ap);
 8a8:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8ab:	8b 00                	mov    (%eax),%eax
 8ad:	0f be c0             	movsbl %al,%eax
 8b0:	83 ec 08             	sub    $0x8,%esp
 8b3:	50                   	push   %eax
 8b4:	ff 75 08             	pushl  0x8(%ebp)
 8b7:	e8 04 fe ff ff       	call   6c0 <putc>
 8bc:	83 c4 10             	add    $0x10,%esp
        ap++;
 8bf:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8c3:	eb 42                	jmp    907 <printf+0x170>
      } else if(c == '%'){
 8c5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8c9:	75 17                	jne    8e2 <printf+0x14b>
        putc(fd, c);
 8cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8ce:	0f be c0             	movsbl %al,%eax
 8d1:	83 ec 08             	sub    $0x8,%esp
 8d4:	50                   	push   %eax
 8d5:	ff 75 08             	pushl  0x8(%ebp)
 8d8:	e8 e3 fd ff ff       	call   6c0 <putc>
 8dd:	83 c4 10             	add    $0x10,%esp
 8e0:	eb 25                	jmp    907 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8e2:	83 ec 08             	sub    $0x8,%esp
 8e5:	6a 25                	push   $0x25
 8e7:	ff 75 08             	pushl  0x8(%ebp)
 8ea:	e8 d1 fd ff ff       	call   6c0 <putc>
 8ef:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 8f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8f5:	0f be c0             	movsbl %al,%eax
 8f8:	83 ec 08             	sub    $0x8,%esp
 8fb:	50                   	push   %eax
 8fc:	ff 75 08             	pushl  0x8(%ebp)
 8ff:	e8 bc fd ff ff       	call   6c0 <putc>
 904:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 907:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 90e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 912:	8b 55 0c             	mov    0xc(%ebp),%edx
 915:	8b 45 f0             	mov    -0x10(%ebp),%eax
 918:	01 d0                	add    %edx,%eax
 91a:	0f b6 00             	movzbl (%eax),%eax
 91d:	84 c0                	test   %al,%al
 91f:	0f 85 94 fe ff ff    	jne    7b9 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 925:	90                   	nop
 926:	c9                   	leave  
 927:	c3                   	ret    

00000928 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 928:	55                   	push   %ebp
 929:	89 e5                	mov    %esp,%ebp
 92b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 92e:	8b 45 08             	mov    0x8(%ebp),%eax
 931:	83 e8 08             	sub    $0x8,%eax
 934:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 937:	a1 6c 0e 00 00       	mov    0xe6c,%eax
 93c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 93f:	eb 24                	jmp    965 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 941:	8b 45 fc             	mov    -0x4(%ebp),%eax
 944:	8b 00                	mov    (%eax),%eax
 946:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 949:	77 12                	ja     95d <free+0x35>
 94b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 94e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 951:	77 24                	ja     977 <free+0x4f>
 953:	8b 45 fc             	mov    -0x4(%ebp),%eax
 956:	8b 00                	mov    (%eax),%eax
 958:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 95b:	77 1a                	ja     977 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 95d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 960:	8b 00                	mov    (%eax),%eax
 962:	89 45 fc             	mov    %eax,-0x4(%ebp)
 965:	8b 45 f8             	mov    -0x8(%ebp),%eax
 968:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 96b:	76 d4                	jbe    941 <free+0x19>
 96d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 970:	8b 00                	mov    (%eax),%eax
 972:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 975:	76 ca                	jbe    941 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 977:	8b 45 f8             	mov    -0x8(%ebp),%eax
 97a:	8b 40 04             	mov    0x4(%eax),%eax
 97d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 984:	8b 45 f8             	mov    -0x8(%ebp),%eax
 987:	01 c2                	add    %eax,%edx
 989:	8b 45 fc             	mov    -0x4(%ebp),%eax
 98c:	8b 00                	mov    (%eax),%eax
 98e:	39 c2                	cmp    %eax,%edx
 990:	75 24                	jne    9b6 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 992:	8b 45 f8             	mov    -0x8(%ebp),%eax
 995:	8b 50 04             	mov    0x4(%eax),%edx
 998:	8b 45 fc             	mov    -0x4(%ebp),%eax
 99b:	8b 00                	mov    (%eax),%eax
 99d:	8b 40 04             	mov    0x4(%eax),%eax
 9a0:	01 c2                	add    %eax,%edx
 9a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9a5:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 9a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ab:	8b 00                	mov    (%eax),%eax
 9ad:	8b 10                	mov    (%eax),%edx
 9af:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9b2:	89 10                	mov    %edx,(%eax)
 9b4:	eb 0a                	jmp    9c0 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 9b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b9:	8b 10                	mov    (%eax),%edx
 9bb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9be:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 9c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c3:	8b 40 04             	mov    0x4(%eax),%eax
 9c6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d0:	01 d0                	add    %edx,%eax
 9d2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9d5:	75 20                	jne    9f7 <free+0xcf>
    p->s.size += bp->s.size;
 9d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9da:	8b 50 04             	mov    0x4(%eax),%edx
 9dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9e0:	8b 40 04             	mov    0x4(%eax),%eax
 9e3:	01 c2                	add    %eax,%edx
 9e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e8:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9ee:	8b 10                	mov    (%eax),%edx
 9f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9f3:	89 10                	mov    %edx,(%eax)
 9f5:	eb 08                	jmp    9ff <free+0xd7>
  } else
    p->s.ptr = bp;
 9f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9fa:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9fd:	89 10                	mov    %edx,(%eax)
  freep = p;
 9ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a02:	a3 6c 0e 00 00       	mov    %eax,0xe6c
}
 a07:	90                   	nop
 a08:	c9                   	leave  
 a09:	c3                   	ret    

00000a0a <morecore>:

static Header*
morecore(uint nu)
{
 a0a:	55                   	push   %ebp
 a0b:	89 e5                	mov    %esp,%ebp
 a0d:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 a10:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 a17:	77 07                	ja     a20 <morecore+0x16>
    nu = 4096;
 a19:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 a20:	8b 45 08             	mov    0x8(%ebp),%eax
 a23:	c1 e0 03             	shl    $0x3,%eax
 a26:	83 ec 0c             	sub    $0xc,%esp
 a29:	50                   	push   %eax
 a2a:	e8 39 fc ff ff       	call   668 <sbrk>
 a2f:	83 c4 10             	add    $0x10,%esp
 a32:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a35:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a39:	75 07                	jne    a42 <morecore+0x38>
    return 0;
 a3b:	b8 00 00 00 00       	mov    $0x0,%eax
 a40:	eb 26                	jmp    a68 <morecore+0x5e>
  hp = (Header*)p;
 a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a45:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a48:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a4b:	8b 55 08             	mov    0x8(%ebp),%edx
 a4e:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a51:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a54:	83 c0 08             	add    $0x8,%eax
 a57:	83 ec 0c             	sub    $0xc,%esp
 a5a:	50                   	push   %eax
 a5b:	e8 c8 fe ff ff       	call   928 <free>
 a60:	83 c4 10             	add    $0x10,%esp
  return freep;
 a63:	a1 6c 0e 00 00       	mov    0xe6c,%eax
}
 a68:	c9                   	leave  
 a69:	c3                   	ret    

00000a6a <malloc>:

void*
malloc(uint nbytes)
{
 a6a:	55                   	push   %ebp
 a6b:	89 e5                	mov    %esp,%ebp
 a6d:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a70:	8b 45 08             	mov    0x8(%ebp),%eax
 a73:	83 c0 07             	add    $0x7,%eax
 a76:	c1 e8 03             	shr    $0x3,%eax
 a79:	83 c0 01             	add    $0x1,%eax
 a7c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a7f:	a1 6c 0e 00 00       	mov    0xe6c,%eax
 a84:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a87:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a8b:	75 23                	jne    ab0 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a8d:	c7 45 f0 64 0e 00 00 	movl   $0xe64,-0x10(%ebp)
 a94:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a97:	a3 6c 0e 00 00       	mov    %eax,0xe6c
 a9c:	a1 6c 0e 00 00       	mov    0xe6c,%eax
 aa1:	a3 64 0e 00 00       	mov    %eax,0xe64
    base.s.size = 0;
 aa6:	c7 05 68 0e 00 00 00 	movl   $0x0,0xe68
 aad:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ab0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ab3:	8b 00                	mov    (%eax),%eax
 ab5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 abb:	8b 40 04             	mov    0x4(%eax),%eax
 abe:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 ac1:	72 4d                	jb     b10 <malloc+0xa6>
      if(p->s.size == nunits)
 ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac6:	8b 40 04             	mov    0x4(%eax),%eax
 ac9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 acc:	75 0c                	jne    ada <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad1:	8b 10                	mov    (%eax),%edx
 ad3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ad6:	89 10                	mov    %edx,(%eax)
 ad8:	eb 26                	jmp    b00 <malloc+0x96>
      else {
        p->s.size -= nunits;
 ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
 add:	8b 40 04             	mov    0x4(%eax),%eax
 ae0:	2b 45 ec             	sub    -0x14(%ebp),%eax
 ae3:	89 c2                	mov    %eax,%edx
 ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ae8:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aee:	8b 40 04             	mov    0x4(%eax),%eax
 af1:	c1 e0 03             	shl    $0x3,%eax
 af4:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 afa:	8b 55 ec             	mov    -0x14(%ebp),%edx
 afd:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 b00:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b03:	a3 6c 0e 00 00       	mov    %eax,0xe6c
      return (void*)(p + 1);
 b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b0b:	83 c0 08             	add    $0x8,%eax
 b0e:	eb 3b                	jmp    b4b <malloc+0xe1>
    }
    if(p == freep)
 b10:	a1 6c 0e 00 00       	mov    0xe6c,%eax
 b15:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 b18:	75 1e                	jne    b38 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 b1a:	83 ec 0c             	sub    $0xc,%esp
 b1d:	ff 75 ec             	pushl  -0x14(%ebp)
 b20:	e8 e5 fe ff ff       	call   a0a <morecore>
 b25:	83 c4 10             	add    $0x10,%esp
 b28:	89 45 f4             	mov    %eax,-0xc(%ebp)
 b2b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b2f:	75 07                	jne    b38 <malloc+0xce>
        return 0;
 b31:	b8 00 00 00 00       	mov    $0x0,%eax
 b36:	eb 13                	jmp    b4b <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b3b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b41:	8b 00                	mov    (%eax),%eax
 b43:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 b46:	e9 6d ff ff ff       	jmp    ab8 <malloc+0x4e>
}
 b4b:	c9                   	leave  
 b4c:	c3                   	ret    

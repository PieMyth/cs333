
_time:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#ifdef CS333_P2
#include "types.h"
#include "user.h"
int
main(int argc, char * argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
   f:	83 ec 20             	sub    $0x20,%esp
  12:	89 cb                	mov    %ecx,%ebx
  int pid = 0;
  14:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int end_ticks = 0;
  1b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  int start_ticks = uptime();
  22:	e8 dc 04 00 00       	call   503 <uptime>
  27:	89 45 e8             	mov    %eax,-0x18(%ebp)
  pid = fork();
  2a:	e8 34 04 00 00       	call   463 <fork>
  2f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (pid < 0)
  32:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  36:	79 17                	jns    4f <main+0x4f>
  {
    printf(1,"invalid pid\n");
  38:	83 ec 08             	sub    $0x8,%esp
  3b:	68 d8 09 00 00       	push   $0x9d8
  40:	6a 01                	push   $0x1
  42:	e8 db 05 00 00       	call   622 <printf>
  47:	83 c4 10             	add    $0x10,%esp
    exit();
  4a:	e8 1c 04 00 00       	call   46b <exit>
  }
  if(pid > 0)
  4f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  53:	7e 0d                	jle    62 <main+0x62>
  {
    wait();
  55:	e8 19 04 00 00       	call   473 <wait>
    end_ticks = uptime();
  5a:	e8 a4 04 00 00       	call   503 <uptime>
  5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  if (pid == 0)
  62:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  66:	75 24                	jne    8c <main+0x8c>
  {
    argv = argv + 1;
  68:	83 43 04 04          	addl   $0x4,0x4(%ebx)
    if(exec(argv[1], argv) < 0)
  6c:	8b 43 04             	mov    0x4(%ebx),%eax
  6f:	83 c0 04             	add    $0x4,%eax
  72:	8b 00                	mov    (%eax),%eax
  74:	83 ec 08             	sub    $0x8,%esp
  77:	ff 73 04             	pushl  0x4(%ebx)
  7a:	50                   	push   %eax
  7b:	e8 23 04 00 00       	call   4a3 <exec>
  80:	83 c4 10             	add    $0x10,%esp
  83:	85 c0                	test   %eax,%eax
  85:	79 05                	jns    8c <main+0x8c>
    {
      exit();
  87:	e8 df 03 00 00       	call   46b <exit>
    }
  }
  int seconds  = (end_ticks - start_ticks)/1000;
  8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8f:	2b 45 e8             	sub    -0x18(%ebp),%eax
  92:	89 c1                	mov    %eax,%ecx
  94:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  99:	89 c8                	mov    %ecx,%eax
  9b:	f7 ea                	imul   %edx
  9d:	c1 fa 06             	sar    $0x6,%edx
  a0:	89 c8                	mov    %ecx,%eax
  a2:	c1 f8 1f             	sar    $0x1f,%eax
  a5:	29 c2                	sub    %eax,%edx
  a7:	89 d0                	mov    %edx,%eax
  a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  int miliseconds = (end_ticks - start_ticks)%1000;
  ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  af:	2b 45 e8             	sub    -0x18(%ebp),%eax
  b2:	89 c1                	mov    %eax,%ecx
  b4:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  b9:	89 c8                	mov    %ecx,%eax
  bb:	f7 ea                	imul   %edx
  bd:	c1 fa 06             	sar    $0x6,%edx
  c0:	89 c8                	mov    %ecx,%eax
  c2:	c1 f8 1f             	sar    $0x1f,%eax
  c5:	29 c2                	sub    %eax,%edx
  c7:	89 d0                	mov    %edx,%eax
  c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  cf:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
  d5:	29 c1                	sub    %eax,%ecx
  d7:	89 c8                	mov    %ecx,%eax
  d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  char * name;
  if(argv[1] != 0)
  dc:	8b 43 04             	mov    0x4(%ebx),%eax
  df:	83 c0 04             	add    $0x4,%eax
  e2:	8b 00                	mov    (%eax),%eax
  e4:	85 c0                	test   %eax,%eax
  e6:	74 0b                	je     f3 <main+0xf3>
    name = argv[1];
  e8:	8b 43 04             	mov    0x4(%ebx),%eax
  eb:	8b 40 04             	mov    0x4(%eax),%eax
  ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  f1:	eb 07                	jmp    fa <main+0xfa>
  else
    name = "";
  f3:	c7 45 f0 e5 09 00 00 	movl   $0x9e5,-0x10(%ebp)
  printf(1,"%s ran in %d.", name, seconds);
  fa:	ff 75 e4             	pushl  -0x1c(%ebp)
  fd:	ff 75 f0             	pushl  -0x10(%ebp)
 100:	68 e6 09 00 00       	push   $0x9e6
 105:	6a 01                	push   $0x1
 107:	e8 16 05 00 00       	call   622 <printf>
 10c:	83 c4 10             	add    $0x10,%esp
  if(miliseconds < 10)
 10f:	83 7d e0 09          	cmpl   $0x9,-0x20(%ebp)
 113:	7f 12                	jg     127 <main+0x127>
    printf(1,"0");
 115:	83 ec 08             	sub    $0x8,%esp
 118:	68 f4 09 00 00       	push   $0x9f4
 11d:	6a 01                	push   $0x1
 11f:	e8 fe 04 00 00       	call   622 <printf>
 124:	83 c4 10             	add    $0x10,%esp
  printf(1,"%d\n", miliseconds);
 127:	83 ec 04             	sub    $0x4,%esp
 12a:	ff 75 e0             	pushl  -0x20(%ebp)
 12d:	68 f6 09 00 00       	push   $0x9f6
 132:	6a 01                	push   $0x1
 134:	e8 e9 04 00 00       	call   622 <printf>
 139:	83 c4 10             	add    $0x10,%esp
  //printf(1, "Not imlpemented yet.\n");
  exit();
 13c:	e8 2a 03 00 00       	call   46b <exit>

00000141 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 141:	55                   	push   %ebp
 142:	89 e5                	mov    %esp,%ebp
 144:	57                   	push   %edi
 145:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 146:	8b 4d 08             	mov    0x8(%ebp),%ecx
 149:	8b 55 10             	mov    0x10(%ebp),%edx
 14c:	8b 45 0c             	mov    0xc(%ebp),%eax
 14f:	89 cb                	mov    %ecx,%ebx
 151:	89 df                	mov    %ebx,%edi
 153:	89 d1                	mov    %edx,%ecx
 155:	fc                   	cld    
 156:	f3 aa                	rep stos %al,%es:(%edi)
 158:	89 ca                	mov    %ecx,%edx
 15a:	89 fb                	mov    %edi,%ebx
 15c:	89 5d 08             	mov    %ebx,0x8(%ebp)
 15f:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 162:	90                   	nop
 163:	5b                   	pop    %ebx
 164:	5f                   	pop    %edi
 165:	5d                   	pop    %ebp
 166:	c3                   	ret    

00000167 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 167:	55                   	push   %ebp
 168:	89 e5                	mov    %esp,%ebp
 16a:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 16d:	8b 45 08             	mov    0x8(%ebp),%eax
 170:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 173:	90                   	nop
 174:	8b 45 08             	mov    0x8(%ebp),%eax
 177:	8d 50 01             	lea    0x1(%eax),%edx
 17a:	89 55 08             	mov    %edx,0x8(%ebp)
 17d:	8b 55 0c             	mov    0xc(%ebp),%edx
 180:	8d 4a 01             	lea    0x1(%edx),%ecx
 183:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 186:	0f b6 12             	movzbl (%edx),%edx
 189:	88 10                	mov    %dl,(%eax)
 18b:	0f b6 00             	movzbl (%eax),%eax
 18e:	84 c0                	test   %al,%al
 190:	75 e2                	jne    174 <strcpy+0xd>
    ;
  return os;
 192:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 195:	c9                   	leave  
 196:	c3                   	ret    

00000197 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 197:	55                   	push   %ebp
 198:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 19a:	eb 08                	jmp    1a4 <strcmp+0xd>
    p++, q++;
 19c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1a0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 1a4:	8b 45 08             	mov    0x8(%ebp),%eax
 1a7:	0f b6 00             	movzbl (%eax),%eax
 1aa:	84 c0                	test   %al,%al
 1ac:	74 10                	je     1be <strcmp+0x27>
 1ae:	8b 45 08             	mov    0x8(%ebp),%eax
 1b1:	0f b6 10             	movzbl (%eax),%edx
 1b4:	8b 45 0c             	mov    0xc(%ebp),%eax
 1b7:	0f b6 00             	movzbl (%eax),%eax
 1ba:	38 c2                	cmp    %al,%dl
 1bc:	74 de                	je     19c <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 1be:	8b 45 08             	mov    0x8(%ebp),%eax
 1c1:	0f b6 00             	movzbl (%eax),%eax
 1c4:	0f b6 d0             	movzbl %al,%edx
 1c7:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ca:	0f b6 00             	movzbl (%eax),%eax
 1cd:	0f b6 c0             	movzbl %al,%eax
 1d0:	29 c2                	sub    %eax,%edx
 1d2:	89 d0                	mov    %edx,%eax
}
 1d4:	5d                   	pop    %ebp
 1d5:	c3                   	ret    

000001d6 <strlen>:

uint
strlen(char *s)
{
 1d6:	55                   	push   %ebp
 1d7:	89 e5                	mov    %esp,%ebp
 1d9:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1dc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1e3:	eb 04                	jmp    1e9 <strlen+0x13>
 1e5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1e9:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1ec:	8b 45 08             	mov    0x8(%ebp),%eax
 1ef:	01 d0                	add    %edx,%eax
 1f1:	0f b6 00             	movzbl (%eax),%eax
 1f4:	84 c0                	test   %al,%al
 1f6:	75 ed                	jne    1e5 <strlen+0xf>
    ;
  return n;
 1f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1fb:	c9                   	leave  
 1fc:	c3                   	ret    

000001fd <memset>:

void*
memset(void *dst, int c, uint n)
{
 1fd:	55                   	push   %ebp
 1fe:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 200:	8b 45 10             	mov    0x10(%ebp),%eax
 203:	50                   	push   %eax
 204:	ff 75 0c             	pushl  0xc(%ebp)
 207:	ff 75 08             	pushl  0x8(%ebp)
 20a:	e8 32 ff ff ff       	call   141 <stosb>
 20f:	83 c4 0c             	add    $0xc,%esp
  return dst;
 212:	8b 45 08             	mov    0x8(%ebp),%eax
}
 215:	c9                   	leave  
 216:	c3                   	ret    

00000217 <strchr>:

char*
strchr(const char *s, char c)
{
 217:	55                   	push   %ebp
 218:	89 e5                	mov    %esp,%ebp
 21a:	83 ec 04             	sub    $0x4,%esp
 21d:	8b 45 0c             	mov    0xc(%ebp),%eax
 220:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 223:	eb 14                	jmp    239 <strchr+0x22>
    if(*s == c)
 225:	8b 45 08             	mov    0x8(%ebp),%eax
 228:	0f b6 00             	movzbl (%eax),%eax
 22b:	3a 45 fc             	cmp    -0x4(%ebp),%al
 22e:	75 05                	jne    235 <strchr+0x1e>
      return (char*)s;
 230:	8b 45 08             	mov    0x8(%ebp),%eax
 233:	eb 13                	jmp    248 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 235:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 239:	8b 45 08             	mov    0x8(%ebp),%eax
 23c:	0f b6 00             	movzbl (%eax),%eax
 23f:	84 c0                	test   %al,%al
 241:	75 e2                	jne    225 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 243:	b8 00 00 00 00       	mov    $0x0,%eax
}
 248:	c9                   	leave  
 249:	c3                   	ret    

0000024a <gets>:

char*
gets(char *buf, int max)
{
 24a:	55                   	push   %ebp
 24b:	89 e5                	mov    %esp,%ebp
 24d:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 250:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 257:	eb 42                	jmp    29b <gets+0x51>
    cc = read(0, &c, 1);
 259:	83 ec 04             	sub    $0x4,%esp
 25c:	6a 01                	push   $0x1
 25e:	8d 45 ef             	lea    -0x11(%ebp),%eax
 261:	50                   	push   %eax
 262:	6a 00                	push   $0x0
 264:	e8 1a 02 00 00       	call   483 <read>
 269:	83 c4 10             	add    $0x10,%esp
 26c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 26f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 273:	7e 33                	jle    2a8 <gets+0x5e>
      break;
    buf[i++] = c;
 275:	8b 45 f4             	mov    -0xc(%ebp),%eax
 278:	8d 50 01             	lea    0x1(%eax),%edx
 27b:	89 55 f4             	mov    %edx,-0xc(%ebp)
 27e:	89 c2                	mov    %eax,%edx
 280:	8b 45 08             	mov    0x8(%ebp),%eax
 283:	01 c2                	add    %eax,%edx
 285:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 289:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 28b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 28f:	3c 0a                	cmp    $0xa,%al
 291:	74 16                	je     2a9 <gets+0x5f>
 293:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 297:	3c 0d                	cmp    $0xd,%al
 299:	74 0e                	je     2a9 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 29b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 29e:	83 c0 01             	add    $0x1,%eax
 2a1:	3b 45 0c             	cmp    0xc(%ebp),%eax
 2a4:	7c b3                	jl     259 <gets+0xf>
 2a6:	eb 01                	jmp    2a9 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 2a8:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 2a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2ac:	8b 45 08             	mov    0x8(%ebp),%eax
 2af:	01 d0                	add    %edx,%eax
 2b1:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2b4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2b7:	c9                   	leave  
 2b8:	c3                   	ret    

000002b9 <stat>:

int
stat(char *n, struct stat *st)
{
 2b9:	55                   	push   %ebp
 2ba:	89 e5                	mov    %esp,%ebp
 2bc:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2bf:	83 ec 08             	sub    $0x8,%esp
 2c2:	6a 00                	push   $0x0
 2c4:	ff 75 08             	pushl  0x8(%ebp)
 2c7:	e8 df 01 00 00       	call   4ab <open>
 2cc:	83 c4 10             	add    $0x10,%esp
 2cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2d6:	79 07                	jns    2df <stat+0x26>
    return -1;
 2d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2dd:	eb 25                	jmp    304 <stat+0x4b>
  r = fstat(fd, st);
 2df:	83 ec 08             	sub    $0x8,%esp
 2e2:	ff 75 0c             	pushl  0xc(%ebp)
 2e5:	ff 75 f4             	pushl  -0xc(%ebp)
 2e8:	e8 d6 01 00 00       	call   4c3 <fstat>
 2ed:	83 c4 10             	add    $0x10,%esp
 2f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2f3:	83 ec 0c             	sub    $0xc,%esp
 2f6:	ff 75 f4             	pushl  -0xc(%ebp)
 2f9:	e8 95 01 00 00       	call   493 <close>
 2fe:	83 c4 10             	add    $0x10,%esp
  return r;
 301:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 304:	c9                   	leave  
 305:	c3                   	ret    

00000306 <atoi>:

int
atoi(const char *s)
{
 306:	55                   	push   %ebp
 307:	89 e5                	mov    %esp,%ebp
 309:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 30c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 313:	eb 04                	jmp    319 <atoi+0x13>
 315:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 319:	8b 45 08             	mov    0x8(%ebp),%eax
 31c:	0f b6 00             	movzbl (%eax),%eax
 31f:	3c 20                	cmp    $0x20,%al
 321:	74 f2                	je     315 <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 323:	8b 45 08             	mov    0x8(%ebp),%eax
 326:	0f b6 00             	movzbl (%eax),%eax
 329:	3c 2d                	cmp    $0x2d,%al
 32b:	75 07                	jne    334 <atoi+0x2e>
 32d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 332:	eb 05                	jmp    339 <atoi+0x33>
 334:	b8 01 00 00 00       	mov    $0x1,%eax
 339:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 33c:	8b 45 08             	mov    0x8(%ebp),%eax
 33f:	0f b6 00             	movzbl (%eax),%eax
 342:	3c 2b                	cmp    $0x2b,%al
 344:	74 0a                	je     350 <atoi+0x4a>
 346:	8b 45 08             	mov    0x8(%ebp),%eax
 349:	0f b6 00             	movzbl (%eax),%eax
 34c:	3c 2d                	cmp    $0x2d,%al
 34e:	75 2b                	jne    37b <atoi+0x75>
    s++;
 350:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 354:	eb 25                	jmp    37b <atoi+0x75>
    n = n*10 + *s++ - '0';
 356:	8b 55 fc             	mov    -0x4(%ebp),%edx
 359:	89 d0                	mov    %edx,%eax
 35b:	c1 e0 02             	shl    $0x2,%eax
 35e:	01 d0                	add    %edx,%eax
 360:	01 c0                	add    %eax,%eax
 362:	89 c1                	mov    %eax,%ecx
 364:	8b 45 08             	mov    0x8(%ebp),%eax
 367:	8d 50 01             	lea    0x1(%eax),%edx
 36a:	89 55 08             	mov    %edx,0x8(%ebp)
 36d:	0f b6 00             	movzbl (%eax),%eax
 370:	0f be c0             	movsbl %al,%eax
 373:	01 c8                	add    %ecx,%eax
 375:	83 e8 30             	sub    $0x30,%eax
 378:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
 37b:	8b 45 08             	mov    0x8(%ebp),%eax
 37e:	0f b6 00             	movzbl (%eax),%eax
 381:	3c 2f                	cmp    $0x2f,%al
 383:	7e 0a                	jle    38f <atoi+0x89>
 385:	8b 45 08             	mov    0x8(%ebp),%eax
 388:	0f b6 00             	movzbl (%eax),%eax
 38b:	3c 39                	cmp    $0x39,%al
 38d:	7e c7                	jle    356 <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 38f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 392:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 396:	c9                   	leave  
 397:	c3                   	ret    

00000398 <atoo>:

int
atoo(const char *s)
{
 398:	55                   	push   %ebp
 399:	89 e5                	mov    %esp,%ebp
 39b:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 39e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 3a5:	eb 04                	jmp    3ab <atoo+0x13>
 3a7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3ab:	8b 45 08             	mov    0x8(%ebp),%eax
 3ae:	0f b6 00             	movzbl (%eax),%eax
 3b1:	3c 20                	cmp    $0x20,%al
 3b3:	74 f2                	je     3a7 <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 3b5:	8b 45 08             	mov    0x8(%ebp),%eax
 3b8:	0f b6 00             	movzbl (%eax),%eax
 3bb:	3c 2d                	cmp    $0x2d,%al
 3bd:	75 07                	jne    3c6 <atoo+0x2e>
 3bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 3c4:	eb 05                	jmp    3cb <atoo+0x33>
 3c6:	b8 01 00 00 00       	mov    $0x1,%eax
 3cb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 3ce:	8b 45 08             	mov    0x8(%ebp),%eax
 3d1:	0f b6 00             	movzbl (%eax),%eax
 3d4:	3c 2b                	cmp    $0x2b,%al
 3d6:	74 0a                	je     3e2 <atoo+0x4a>
 3d8:	8b 45 08             	mov    0x8(%ebp),%eax
 3db:	0f b6 00             	movzbl (%eax),%eax
 3de:	3c 2d                	cmp    $0x2d,%al
 3e0:	75 27                	jne    409 <atoo+0x71>
    s++;
 3e2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 3e6:	eb 21                	jmp    409 <atoo+0x71>
    n = n*8 + *s++ - '0';
 3e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3eb:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 3f2:	8b 45 08             	mov    0x8(%ebp),%eax
 3f5:	8d 50 01             	lea    0x1(%eax),%edx
 3f8:	89 55 08             	mov    %edx,0x8(%ebp)
 3fb:	0f b6 00             	movzbl (%eax),%eax
 3fe:	0f be c0             	movsbl %al,%eax
 401:	01 c8                	add    %ecx,%eax
 403:	83 e8 30             	sub    $0x30,%eax
 406:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 409:	8b 45 08             	mov    0x8(%ebp),%eax
 40c:	0f b6 00             	movzbl (%eax),%eax
 40f:	3c 2f                	cmp    $0x2f,%al
 411:	7e 0a                	jle    41d <atoo+0x85>
 413:	8b 45 08             	mov    0x8(%ebp),%eax
 416:	0f b6 00             	movzbl (%eax),%eax
 419:	3c 37                	cmp    $0x37,%al
 41b:	7e cb                	jle    3e8 <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 41d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 420:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 424:	c9                   	leave  
 425:	c3                   	ret    

00000426 <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 426:	55                   	push   %ebp
 427:	89 e5                	mov    %esp,%ebp
 429:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 42c:	8b 45 08             	mov    0x8(%ebp),%eax
 42f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 432:	8b 45 0c             	mov    0xc(%ebp),%eax
 435:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 438:	eb 17                	jmp    451 <memmove+0x2b>
    *dst++ = *src++;
 43a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 43d:	8d 50 01             	lea    0x1(%eax),%edx
 440:	89 55 fc             	mov    %edx,-0x4(%ebp)
 443:	8b 55 f8             	mov    -0x8(%ebp),%edx
 446:	8d 4a 01             	lea    0x1(%edx),%ecx
 449:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 44c:	0f b6 12             	movzbl (%edx),%edx
 44f:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 451:	8b 45 10             	mov    0x10(%ebp),%eax
 454:	8d 50 ff             	lea    -0x1(%eax),%edx
 457:	89 55 10             	mov    %edx,0x10(%ebp)
 45a:	85 c0                	test   %eax,%eax
 45c:	7f dc                	jg     43a <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 45e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 461:	c9                   	leave  
 462:	c3                   	ret    

00000463 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 463:	b8 01 00 00 00       	mov    $0x1,%eax
 468:	cd 40                	int    $0x40
 46a:	c3                   	ret    

0000046b <exit>:
SYSCALL(exit)
 46b:	b8 02 00 00 00       	mov    $0x2,%eax
 470:	cd 40                	int    $0x40
 472:	c3                   	ret    

00000473 <wait>:
SYSCALL(wait)
 473:	b8 03 00 00 00       	mov    $0x3,%eax
 478:	cd 40                	int    $0x40
 47a:	c3                   	ret    

0000047b <pipe>:
SYSCALL(pipe)
 47b:	b8 04 00 00 00       	mov    $0x4,%eax
 480:	cd 40                	int    $0x40
 482:	c3                   	ret    

00000483 <read>:
SYSCALL(read)
 483:	b8 05 00 00 00       	mov    $0x5,%eax
 488:	cd 40                	int    $0x40
 48a:	c3                   	ret    

0000048b <write>:
SYSCALL(write)
 48b:	b8 10 00 00 00       	mov    $0x10,%eax
 490:	cd 40                	int    $0x40
 492:	c3                   	ret    

00000493 <close>:
SYSCALL(close)
 493:	b8 15 00 00 00       	mov    $0x15,%eax
 498:	cd 40                	int    $0x40
 49a:	c3                   	ret    

0000049b <kill>:
SYSCALL(kill)
 49b:	b8 06 00 00 00       	mov    $0x6,%eax
 4a0:	cd 40                	int    $0x40
 4a2:	c3                   	ret    

000004a3 <exec>:
SYSCALL(exec)
 4a3:	b8 07 00 00 00       	mov    $0x7,%eax
 4a8:	cd 40                	int    $0x40
 4aa:	c3                   	ret    

000004ab <open>:
SYSCALL(open)
 4ab:	b8 0f 00 00 00       	mov    $0xf,%eax
 4b0:	cd 40                	int    $0x40
 4b2:	c3                   	ret    

000004b3 <mknod>:
SYSCALL(mknod)
 4b3:	b8 11 00 00 00       	mov    $0x11,%eax
 4b8:	cd 40                	int    $0x40
 4ba:	c3                   	ret    

000004bb <unlink>:
SYSCALL(unlink)
 4bb:	b8 12 00 00 00       	mov    $0x12,%eax
 4c0:	cd 40                	int    $0x40
 4c2:	c3                   	ret    

000004c3 <fstat>:
SYSCALL(fstat)
 4c3:	b8 08 00 00 00       	mov    $0x8,%eax
 4c8:	cd 40                	int    $0x40
 4ca:	c3                   	ret    

000004cb <link>:
SYSCALL(link)
 4cb:	b8 13 00 00 00       	mov    $0x13,%eax
 4d0:	cd 40                	int    $0x40
 4d2:	c3                   	ret    

000004d3 <mkdir>:
SYSCALL(mkdir)
 4d3:	b8 14 00 00 00       	mov    $0x14,%eax
 4d8:	cd 40                	int    $0x40
 4da:	c3                   	ret    

000004db <chdir>:
SYSCALL(chdir)
 4db:	b8 09 00 00 00       	mov    $0x9,%eax
 4e0:	cd 40                	int    $0x40
 4e2:	c3                   	ret    

000004e3 <dup>:
SYSCALL(dup)
 4e3:	b8 0a 00 00 00       	mov    $0xa,%eax
 4e8:	cd 40                	int    $0x40
 4ea:	c3                   	ret    

000004eb <getpid>:
SYSCALL(getpid)
 4eb:	b8 0b 00 00 00       	mov    $0xb,%eax
 4f0:	cd 40                	int    $0x40
 4f2:	c3                   	ret    

000004f3 <sbrk>:
SYSCALL(sbrk)
 4f3:	b8 0c 00 00 00       	mov    $0xc,%eax
 4f8:	cd 40                	int    $0x40
 4fa:	c3                   	ret    

000004fb <sleep>:
SYSCALL(sleep)
 4fb:	b8 0d 00 00 00       	mov    $0xd,%eax
 500:	cd 40                	int    $0x40
 502:	c3                   	ret    

00000503 <uptime>:
SYSCALL(uptime)
 503:	b8 0e 00 00 00       	mov    $0xe,%eax
 508:	cd 40                	int    $0x40
 50a:	c3                   	ret    

0000050b <halt>:
SYSCALL(halt)
 50b:	b8 16 00 00 00       	mov    $0x16,%eax
 510:	cd 40                	int    $0x40
 512:	c3                   	ret    

00000513 <date>:
SYSCALL(date)
 513:	b8 17 00 00 00       	mov    $0x17,%eax
 518:	cd 40                	int    $0x40
 51a:	c3                   	ret    

0000051b <getuid>:
SYSCALL(getuid)
 51b:	b8 18 00 00 00       	mov    $0x18,%eax
 520:	cd 40                	int    $0x40
 522:	c3                   	ret    

00000523 <getgid>:
SYSCALL(getgid)
 523:	b8 19 00 00 00       	mov    $0x19,%eax
 528:	cd 40                	int    $0x40
 52a:	c3                   	ret    

0000052b <getppid>:
SYSCALL(getppid)
 52b:	b8 1a 00 00 00       	mov    $0x1a,%eax
 530:	cd 40                	int    $0x40
 532:	c3                   	ret    

00000533 <setuid>:
SYSCALL(setuid)
 533:	b8 1b 00 00 00       	mov    $0x1b,%eax
 538:	cd 40                	int    $0x40
 53a:	c3                   	ret    

0000053b <setgid>:
SYSCALL(setgid)
 53b:	b8 1c 00 00 00       	mov    $0x1c,%eax
 540:	cd 40                	int    $0x40
 542:	c3                   	ret    

00000543 <getprocs>:
SYSCALL(getprocs)
 543:	b8 1a 00 00 00       	mov    $0x1a,%eax
 548:	cd 40                	int    $0x40
 54a:	c3                   	ret    

0000054b <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 54b:	55                   	push   %ebp
 54c:	89 e5                	mov    %esp,%ebp
 54e:	83 ec 18             	sub    $0x18,%esp
 551:	8b 45 0c             	mov    0xc(%ebp),%eax
 554:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 557:	83 ec 04             	sub    $0x4,%esp
 55a:	6a 01                	push   $0x1
 55c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 55f:	50                   	push   %eax
 560:	ff 75 08             	pushl  0x8(%ebp)
 563:	e8 23 ff ff ff       	call   48b <write>
 568:	83 c4 10             	add    $0x10,%esp
}
 56b:	90                   	nop
 56c:	c9                   	leave  
 56d:	c3                   	ret    

0000056e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 56e:	55                   	push   %ebp
 56f:	89 e5                	mov    %esp,%ebp
 571:	53                   	push   %ebx
 572:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 575:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 57c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 580:	74 17                	je     599 <printint+0x2b>
 582:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 586:	79 11                	jns    599 <printint+0x2b>
    neg = 1;
 588:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 58f:	8b 45 0c             	mov    0xc(%ebp),%eax
 592:	f7 d8                	neg    %eax
 594:	89 45 ec             	mov    %eax,-0x14(%ebp)
 597:	eb 06                	jmp    59f <printint+0x31>
  } else {
    x = xx;
 599:	8b 45 0c             	mov    0xc(%ebp),%eax
 59c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 59f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5a6:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 5a9:	8d 41 01             	lea    0x1(%ecx),%eax
 5ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
 5af:	8b 5d 10             	mov    0x10(%ebp),%ebx
 5b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5b5:	ba 00 00 00 00       	mov    $0x0,%edx
 5ba:	f7 f3                	div    %ebx
 5bc:	89 d0                	mov    %edx,%eax
 5be:	0f b6 80 70 0c 00 00 	movzbl 0xc70(%eax),%eax
 5c5:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 5c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
 5cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5cf:	ba 00 00 00 00       	mov    $0x0,%edx
 5d4:	f7 f3                	div    %ebx
 5d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5d9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5dd:	75 c7                	jne    5a6 <printint+0x38>
  if(neg)
 5df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5e3:	74 2d                	je     612 <printint+0xa4>
    buf[i++] = '-';
 5e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5e8:	8d 50 01             	lea    0x1(%eax),%edx
 5eb:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5ee:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5f3:	eb 1d                	jmp    612 <printint+0xa4>
    putc(fd, buf[i]);
 5f5:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5fb:	01 d0                	add    %edx,%eax
 5fd:	0f b6 00             	movzbl (%eax),%eax
 600:	0f be c0             	movsbl %al,%eax
 603:	83 ec 08             	sub    $0x8,%esp
 606:	50                   	push   %eax
 607:	ff 75 08             	pushl  0x8(%ebp)
 60a:	e8 3c ff ff ff       	call   54b <putc>
 60f:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 612:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 616:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 61a:	79 d9                	jns    5f5 <printint+0x87>
    putc(fd, buf[i]);
}
 61c:	90                   	nop
 61d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 620:	c9                   	leave  
 621:	c3                   	ret    

00000622 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 622:	55                   	push   %ebp
 623:	89 e5                	mov    %esp,%ebp
 625:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 628:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 62f:	8d 45 0c             	lea    0xc(%ebp),%eax
 632:	83 c0 04             	add    $0x4,%eax
 635:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 638:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 63f:	e9 59 01 00 00       	jmp    79d <printf+0x17b>
    c = fmt[i] & 0xff;
 644:	8b 55 0c             	mov    0xc(%ebp),%edx
 647:	8b 45 f0             	mov    -0x10(%ebp),%eax
 64a:	01 d0                	add    %edx,%eax
 64c:	0f b6 00             	movzbl (%eax),%eax
 64f:	0f be c0             	movsbl %al,%eax
 652:	25 ff 00 00 00       	and    $0xff,%eax
 657:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 65a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 65e:	75 2c                	jne    68c <printf+0x6a>
      if(c == '%'){
 660:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 664:	75 0c                	jne    672 <printf+0x50>
        state = '%';
 666:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 66d:	e9 27 01 00 00       	jmp    799 <printf+0x177>
      } else {
        putc(fd, c);
 672:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 675:	0f be c0             	movsbl %al,%eax
 678:	83 ec 08             	sub    $0x8,%esp
 67b:	50                   	push   %eax
 67c:	ff 75 08             	pushl  0x8(%ebp)
 67f:	e8 c7 fe ff ff       	call   54b <putc>
 684:	83 c4 10             	add    $0x10,%esp
 687:	e9 0d 01 00 00       	jmp    799 <printf+0x177>
      }
    } else if(state == '%'){
 68c:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 690:	0f 85 03 01 00 00    	jne    799 <printf+0x177>
      if(c == 'd'){
 696:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 69a:	75 1e                	jne    6ba <printf+0x98>
        printint(fd, *ap, 10, 1);
 69c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 69f:	8b 00                	mov    (%eax),%eax
 6a1:	6a 01                	push   $0x1
 6a3:	6a 0a                	push   $0xa
 6a5:	50                   	push   %eax
 6a6:	ff 75 08             	pushl  0x8(%ebp)
 6a9:	e8 c0 fe ff ff       	call   56e <printint>
 6ae:	83 c4 10             	add    $0x10,%esp
        ap++;
 6b1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6b5:	e9 d8 00 00 00       	jmp    792 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 6ba:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6be:	74 06                	je     6c6 <printf+0xa4>
 6c0:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6c4:	75 1e                	jne    6e4 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 6c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6c9:	8b 00                	mov    (%eax),%eax
 6cb:	6a 00                	push   $0x0
 6cd:	6a 10                	push   $0x10
 6cf:	50                   	push   %eax
 6d0:	ff 75 08             	pushl  0x8(%ebp)
 6d3:	e8 96 fe ff ff       	call   56e <printint>
 6d8:	83 c4 10             	add    $0x10,%esp
        ap++;
 6db:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6df:	e9 ae 00 00 00       	jmp    792 <printf+0x170>
      } else if(c == 's'){
 6e4:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6e8:	75 43                	jne    72d <printf+0x10b>
        s = (char*)*ap;
 6ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6ed:	8b 00                	mov    (%eax),%eax
 6ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6f2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6fa:	75 25                	jne    721 <printf+0xff>
          s = "(null)";
 6fc:	c7 45 f4 fa 09 00 00 	movl   $0x9fa,-0xc(%ebp)
        while(*s != 0){
 703:	eb 1c                	jmp    721 <printf+0xff>
          putc(fd, *s);
 705:	8b 45 f4             	mov    -0xc(%ebp),%eax
 708:	0f b6 00             	movzbl (%eax),%eax
 70b:	0f be c0             	movsbl %al,%eax
 70e:	83 ec 08             	sub    $0x8,%esp
 711:	50                   	push   %eax
 712:	ff 75 08             	pushl  0x8(%ebp)
 715:	e8 31 fe ff ff       	call   54b <putc>
 71a:	83 c4 10             	add    $0x10,%esp
          s++;
 71d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 721:	8b 45 f4             	mov    -0xc(%ebp),%eax
 724:	0f b6 00             	movzbl (%eax),%eax
 727:	84 c0                	test   %al,%al
 729:	75 da                	jne    705 <printf+0xe3>
 72b:	eb 65                	jmp    792 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 72d:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 731:	75 1d                	jne    750 <printf+0x12e>
        putc(fd, *ap);
 733:	8b 45 e8             	mov    -0x18(%ebp),%eax
 736:	8b 00                	mov    (%eax),%eax
 738:	0f be c0             	movsbl %al,%eax
 73b:	83 ec 08             	sub    $0x8,%esp
 73e:	50                   	push   %eax
 73f:	ff 75 08             	pushl  0x8(%ebp)
 742:	e8 04 fe ff ff       	call   54b <putc>
 747:	83 c4 10             	add    $0x10,%esp
        ap++;
 74a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 74e:	eb 42                	jmp    792 <printf+0x170>
      } else if(c == '%'){
 750:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 754:	75 17                	jne    76d <printf+0x14b>
        putc(fd, c);
 756:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 759:	0f be c0             	movsbl %al,%eax
 75c:	83 ec 08             	sub    $0x8,%esp
 75f:	50                   	push   %eax
 760:	ff 75 08             	pushl  0x8(%ebp)
 763:	e8 e3 fd ff ff       	call   54b <putc>
 768:	83 c4 10             	add    $0x10,%esp
 76b:	eb 25                	jmp    792 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 76d:	83 ec 08             	sub    $0x8,%esp
 770:	6a 25                	push   $0x25
 772:	ff 75 08             	pushl  0x8(%ebp)
 775:	e8 d1 fd ff ff       	call   54b <putc>
 77a:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 77d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 780:	0f be c0             	movsbl %al,%eax
 783:	83 ec 08             	sub    $0x8,%esp
 786:	50                   	push   %eax
 787:	ff 75 08             	pushl  0x8(%ebp)
 78a:	e8 bc fd ff ff       	call   54b <putc>
 78f:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 792:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 799:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 79d:	8b 55 0c             	mov    0xc(%ebp),%edx
 7a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a3:	01 d0                	add    %edx,%eax
 7a5:	0f b6 00             	movzbl (%eax),%eax
 7a8:	84 c0                	test   %al,%al
 7aa:	0f 85 94 fe ff ff    	jne    644 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7b0:	90                   	nop
 7b1:	c9                   	leave  
 7b2:	c3                   	ret    

000007b3 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7b3:	55                   	push   %ebp
 7b4:	89 e5                	mov    %esp,%ebp
 7b6:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7b9:	8b 45 08             	mov    0x8(%ebp),%eax
 7bc:	83 e8 08             	sub    $0x8,%eax
 7bf:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c2:	a1 8c 0c 00 00       	mov    0xc8c,%eax
 7c7:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7ca:	eb 24                	jmp    7f0 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7cf:	8b 00                	mov    (%eax),%eax
 7d1:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7d4:	77 12                	ja     7e8 <free+0x35>
 7d6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d9:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7dc:	77 24                	ja     802 <free+0x4f>
 7de:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e1:	8b 00                	mov    (%eax),%eax
 7e3:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7e6:	77 1a                	ja     802 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7eb:	8b 00                	mov    (%eax),%eax
 7ed:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7f0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f3:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7f6:	76 d4                	jbe    7cc <free+0x19>
 7f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7fb:	8b 00                	mov    (%eax),%eax
 7fd:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 800:	76 ca                	jbe    7cc <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 802:	8b 45 f8             	mov    -0x8(%ebp),%eax
 805:	8b 40 04             	mov    0x4(%eax),%eax
 808:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 80f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 812:	01 c2                	add    %eax,%edx
 814:	8b 45 fc             	mov    -0x4(%ebp),%eax
 817:	8b 00                	mov    (%eax),%eax
 819:	39 c2                	cmp    %eax,%edx
 81b:	75 24                	jne    841 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 81d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 820:	8b 50 04             	mov    0x4(%eax),%edx
 823:	8b 45 fc             	mov    -0x4(%ebp),%eax
 826:	8b 00                	mov    (%eax),%eax
 828:	8b 40 04             	mov    0x4(%eax),%eax
 82b:	01 c2                	add    %eax,%edx
 82d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 830:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 833:	8b 45 fc             	mov    -0x4(%ebp),%eax
 836:	8b 00                	mov    (%eax),%eax
 838:	8b 10                	mov    (%eax),%edx
 83a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 83d:	89 10                	mov    %edx,(%eax)
 83f:	eb 0a                	jmp    84b <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 841:	8b 45 fc             	mov    -0x4(%ebp),%eax
 844:	8b 10                	mov    (%eax),%edx
 846:	8b 45 f8             	mov    -0x8(%ebp),%eax
 849:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 84b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84e:	8b 40 04             	mov    0x4(%eax),%eax
 851:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 858:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85b:	01 d0                	add    %edx,%eax
 85d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 860:	75 20                	jne    882 <free+0xcf>
    p->s.size += bp->s.size;
 862:	8b 45 fc             	mov    -0x4(%ebp),%eax
 865:	8b 50 04             	mov    0x4(%eax),%edx
 868:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86b:	8b 40 04             	mov    0x4(%eax),%eax
 86e:	01 c2                	add    %eax,%edx
 870:	8b 45 fc             	mov    -0x4(%ebp),%eax
 873:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 876:	8b 45 f8             	mov    -0x8(%ebp),%eax
 879:	8b 10                	mov    (%eax),%edx
 87b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87e:	89 10                	mov    %edx,(%eax)
 880:	eb 08                	jmp    88a <free+0xd7>
  } else
    p->s.ptr = bp;
 882:	8b 45 fc             	mov    -0x4(%ebp),%eax
 885:	8b 55 f8             	mov    -0x8(%ebp),%edx
 888:	89 10                	mov    %edx,(%eax)
  freep = p;
 88a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88d:	a3 8c 0c 00 00       	mov    %eax,0xc8c
}
 892:	90                   	nop
 893:	c9                   	leave  
 894:	c3                   	ret    

00000895 <morecore>:

static Header*
morecore(uint nu)
{
 895:	55                   	push   %ebp
 896:	89 e5                	mov    %esp,%ebp
 898:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 89b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8a2:	77 07                	ja     8ab <morecore+0x16>
    nu = 4096;
 8a4:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8ab:	8b 45 08             	mov    0x8(%ebp),%eax
 8ae:	c1 e0 03             	shl    $0x3,%eax
 8b1:	83 ec 0c             	sub    $0xc,%esp
 8b4:	50                   	push   %eax
 8b5:	e8 39 fc ff ff       	call   4f3 <sbrk>
 8ba:	83 c4 10             	add    $0x10,%esp
 8bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8c0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8c4:	75 07                	jne    8cd <morecore+0x38>
    return 0;
 8c6:	b8 00 00 00 00       	mov    $0x0,%eax
 8cb:	eb 26                	jmp    8f3 <morecore+0x5e>
  hp = (Header*)p;
 8cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d6:	8b 55 08             	mov    0x8(%ebp),%edx
 8d9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8df:	83 c0 08             	add    $0x8,%eax
 8e2:	83 ec 0c             	sub    $0xc,%esp
 8e5:	50                   	push   %eax
 8e6:	e8 c8 fe ff ff       	call   7b3 <free>
 8eb:	83 c4 10             	add    $0x10,%esp
  return freep;
 8ee:	a1 8c 0c 00 00       	mov    0xc8c,%eax
}
 8f3:	c9                   	leave  
 8f4:	c3                   	ret    

000008f5 <malloc>:

void*
malloc(uint nbytes)
{
 8f5:	55                   	push   %ebp
 8f6:	89 e5                	mov    %esp,%ebp
 8f8:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8fb:	8b 45 08             	mov    0x8(%ebp),%eax
 8fe:	83 c0 07             	add    $0x7,%eax
 901:	c1 e8 03             	shr    $0x3,%eax
 904:	83 c0 01             	add    $0x1,%eax
 907:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 90a:	a1 8c 0c 00 00       	mov    0xc8c,%eax
 90f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 912:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 916:	75 23                	jne    93b <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 918:	c7 45 f0 84 0c 00 00 	movl   $0xc84,-0x10(%ebp)
 91f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 922:	a3 8c 0c 00 00       	mov    %eax,0xc8c
 927:	a1 8c 0c 00 00       	mov    0xc8c,%eax
 92c:	a3 84 0c 00 00       	mov    %eax,0xc84
    base.s.size = 0;
 931:	c7 05 88 0c 00 00 00 	movl   $0x0,0xc88
 938:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 93b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 93e:	8b 00                	mov    (%eax),%eax
 940:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 943:	8b 45 f4             	mov    -0xc(%ebp),%eax
 946:	8b 40 04             	mov    0x4(%eax),%eax
 949:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 94c:	72 4d                	jb     99b <malloc+0xa6>
      if(p->s.size == nunits)
 94e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 951:	8b 40 04             	mov    0x4(%eax),%eax
 954:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 957:	75 0c                	jne    965 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 959:	8b 45 f4             	mov    -0xc(%ebp),%eax
 95c:	8b 10                	mov    (%eax),%edx
 95e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 961:	89 10                	mov    %edx,(%eax)
 963:	eb 26                	jmp    98b <malloc+0x96>
      else {
        p->s.size -= nunits;
 965:	8b 45 f4             	mov    -0xc(%ebp),%eax
 968:	8b 40 04             	mov    0x4(%eax),%eax
 96b:	2b 45 ec             	sub    -0x14(%ebp),%eax
 96e:	89 c2                	mov    %eax,%edx
 970:	8b 45 f4             	mov    -0xc(%ebp),%eax
 973:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 976:	8b 45 f4             	mov    -0xc(%ebp),%eax
 979:	8b 40 04             	mov    0x4(%eax),%eax
 97c:	c1 e0 03             	shl    $0x3,%eax
 97f:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 982:	8b 45 f4             	mov    -0xc(%ebp),%eax
 985:	8b 55 ec             	mov    -0x14(%ebp),%edx
 988:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 98b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 98e:	a3 8c 0c 00 00       	mov    %eax,0xc8c
      return (void*)(p + 1);
 993:	8b 45 f4             	mov    -0xc(%ebp),%eax
 996:	83 c0 08             	add    $0x8,%eax
 999:	eb 3b                	jmp    9d6 <malloc+0xe1>
    }
    if(p == freep)
 99b:	a1 8c 0c 00 00       	mov    0xc8c,%eax
 9a0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9a3:	75 1e                	jne    9c3 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 9a5:	83 ec 0c             	sub    $0xc,%esp
 9a8:	ff 75 ec             	pushl  -0x14(%ebp)
 9ab:	e8 e5 fe ff ff       	call   895 <morecore>
 9b0:	83 c4 10             	add    $0x10,%esp
 9b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9ba:	75 07                	jne    9c3 <malloc+0xce>
        return 0;
 9bc:	b8 00 00 00 00       	mov    $0x0,%eax
 9c1:	eb 13                	jmp    9d6 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9cc:	8b 00                	mov    (%eax),%eax
 9ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9d1:	e9 6d ff ff ff       	jmp    943 <malloc+0x4e>
}
 9d6:	c9                   	leave  
 9d7:	c3                   	ret    

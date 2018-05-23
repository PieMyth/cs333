
_ls:     file format elf32-i386


Disassembly of section .text:

00000000 <print_mode>:
#ifdef CS333_P5
// this is an ugly series of if statements but it works
void
print_mode(struct stat* st)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 08             	sub    $0x8,%esp
  switch (st->type) {
   6:	8b 45 08             	mov    0x8(%ebp),%eax
   9:	0f b7 00             	movzwl (%eax),%eax
   c:	98                   	cwtl   
   d:	83 f8 02             	cmp    $0x2,%eax
  10:	74 1e                	je     30 <print_mode+0x30>
  12:	83 f8 03             	cmp    $0x3,%eax
  15:	74 2d                	je     44 <print_mode+0x44>
  17:	83 f8 01             	cmp    $0x1,%eax
  1a:	75 3c                	jne    58 <print_mode+0x58>
    case T_DIR: printf(1, "d"); break;
  1c:	83 ec 08             	sub    $0x8,%esp
  1f:	68 d8 0e 00 00       	push   $0xed8
  24:	6a 01                	push   $0x1
  26:	e8 f6 0a 00 00       	call   b21 <printf>
  2b:	83 c4 10             	add    $0x10,%esp
  2e:	eb 3a                	jmp    6a <print_mode+0x6a>
    case T_FILE: printf(1, "-"); break;
  30:	83 ec 08             	sub    $0x8,%esp
  33:	68 da 0e 00 00       	push   $0xeda
  38:	6a 01                	push   $0x1
  3a:	e8 e2 0a 00 00       	call   b21 <printf>
  3f:	83 c4 10             	add    $0x10,%esp
  42:	eb 26                	jmp    6a <print_mode+0x6a>
    case T_DEV: printf(1, "c"); break;
  44:	83 ec 08             	sub    $0x8,%esp
  47:	68 dc 0e 00 00       	push   $0xedc
  4c:	6a 01                	push   $0x1
  4e:	e8 ce 0a 00 00       	call   b21 <printf>
  53:	83 c4 10             	add    $0x10,%esp
  56:	eb 12                	jmp    6a <print_mode+0x6a>
    default: printf(1, "?");
  58:	83 ec 08             	sub    $0x8,%esp
  5b:	68 de 0e 00 00       	push   $0xede
  60:	6a 01                	push   $0x1
  62:	e8 ba 0a 00 00       	call   b21 <printf>
  67:	83 c4 10             	add    $0x10,%esp
  }

  if (st->mode.flags.u_r)
  6a:	8b 45 08             	mov    0x8(%ebp),%eax
  6d:	0f b6 40 15          	movzbl 0x15(%eax),%eax
  71:	83 e0 01             	and    $0x1,%eax
  74:	84 c0                	test   %al,%al
  76:	74 14                	je     8c <print_mode+0x8c>
    printf(1, "r");
  78:	83 ec 08             	sub    $0x8,%esp
  7b:	68 e0 0e 00 00       	push   $0xee0
  80:	6a 01                	push   $0x1
  82:	e8 9a 0a 00 00       	call   b21 <printf>
  87:	83 c4 10             	add    $0x10,%esp
  8a:	eb 12                	jmp    9e <print_mode+0x9e>
  else
    printf(1, "-");
  8c:	83 ec 08             	sub    $0x8,%esp
  8f:	68 da 0e 00 00       	push   $0xeda
  94:	6a 01                	push   $0x1
  96:	e8 86 0a 00 00       	call   b21 <printf>
  9b:	83 c4 10             	add    $0x10,%esp

  if (st->mode.flags.u_w)
  9e:	8b 45 08             	mov    0x8(%ebp),%eax
  a1:	0f b6 40 14          	movzbl 0x14(%eax),%eax
  a5:	83 e0 80             	and    $0xffffff80,%eax
  a8:	84 c0                	test   %al,%al
  aa:	74 14                	je     c0 <print_mode+0xc0>
    printf(1, "w");
  ac:	83 ec 08             	sub    $0x8,%esp
  af:	68 e2 0e 00 00       	push   $0xee2
  b4:	6a 01                	push   $0x1
  b6:	e8 66 0a 00 00       	call   b21 <printf>
  bb:	83 c4 10             	add    $0x10,%esp
  be:	eb 12                	jmp    d2 <print_mode+0xd2>
  else
    printf(1, "-");
  c0:	83 ec 08             	sub    $0x8,%esp
  c3:	68 da 0e 00 00       	push   $0xeda
  c8:	6a 01                	push   $0x1
  ca:	e8 52 0a 00 00       	call   b21 <printf>
  cf:	83 c4 10             	add    $0x10,%esp

  if ((st->mode.flags.u_x) & (st->mode.flags.setuid))
  d2:	8b 45 08             	mov    0x8(%ebp),%eax
  d5:	0f b6 40 14          	movzbl 0x14(%eax),%eax
  d9:	c0 e8 06             	shr    $0x6,%al
  dc:	83 e0 01             	and    $0x1,%eax
  df:	0f b6 d0             	movzbl %al,%edx
  e2:	8b 45 08             	mov    0x8(%ebp),%eax
  e5:	0f b6 40 15          	movzbl 0x15(%eax),%eax
  e9:	d0 e8                	shr    %al
  eb:	83 e0 01             	and    $0x1,%eax
  ee:	0f b6 c0             	movzbl %al,%eax
  f1:	21 d0                	and    %edx,%eax
  f3:	85 c0                	test   %eax,%eax
  f5:	74 14                	je     10b <print_mode+0x10b>
    printf(1, "S");
  f7:	83 ec 08             	sub    $0x8,%esp
  fa:	68 e4 0e 00 00       	push   $0xee4
  ff:	6a 01                	push   $0x1
 101:	e8 1b 0a 00 00       	call   b21 <printf>
 106:	83 c4 10             	add    $0x10,%esp
 109:	eb 34                	jmp    13f <print_mode+0x13f>
  else if (st->mode.flags.u_x)
 10b:	8b 45 08             	mov    0x8(%ebp),%eax
 10e:	0f b6 40 14          	movzbl 0x14(%eax),%eax
 112:	83 e0 40             	and    $0x40,%eax
 115:	84 c0                	test   %al,%al
 117:	74 14                	je     12d <print_mode+0x12d>
    printf(1, "x");
 119:	83 ec 08             	sub    $0x8,%esp
 11c:	68 e6 0e 00 00       	push   $0xee6
 121:	6a 01                	push   $0x1
 123:	e8 f9 09 00 00       	call   b21 <printf>
 128:	83 c4 10             	add    $0x10,%esp
 12b:	eb 12                	jmp    13f <print_mode+0x13f>
  else
    printf(1, "-");
 12d:	83 ec 08             	sub    $0x8,%esp
 130:	68 da 0e 00 00       	push   $0xeda
 135:	6a 01                	push   $0x1
 137:	e8 e5 09 00 00       	call   b21 <printf>
 13c:	83 c4 10             	add    $0x10,%esp

  if (st->mode.flags.g_r)
 13f:	8b 45 08             	mov    0x8(%ebp),%eax
 142:	0f b6 40 14          	movzbl 0x14(%eax),%eax
 146:	83 e0 20             	and    $0x20,%eax
 149:	84 c0                	test   %al,%al
 14b:	74 14                	je     161 <print_mode+0x161>
    printf(1, "r");
 14d:	83 ec 08             	sub    $0x8,%esp
 150:	68 e0 0e 00 00       	push   $0xee0
 155:	6a 01                	push   $0x1
 157:	e8 c5 09 00 00       	call   b21 <printf>
 15c:	83 c4 10             	add    $0x10,%esp
 15f:	eb 12                	jmp    173 <print_mode+0x173>
  else
    printf(1, "-");
 161:	83 ec 08             	sub    $0x8,%esp
 164:	68 da 0e 00 00       	push   $0xeda
 169:	6a 01                	push   $0x1
 16b:	e8 b1 09 00 00       	call   b21 <printf>
 170:	83 c4 10             	add    $0x10,%esp

  if (st->mode.flags.g_w)
 173:	8b 45 08             	mov    0x8(%ebp),%eax
 176:	0f b6 40 14          	movzbl 0x14(%eax),%eax
 17a:	83 e0 10             	and    $0x10,%eax
 17d:	84 c0                	test   %al,%al
 17f:	74 14                	je     195 <print_mode+0x195>
    printf(1, "w");
 181:	83 ec 08             	sub    $0x8,%esp
 184:	68 e2 0e 00 00       	push   $0xee2
 189:	6a 01                	push   $0x1
 18b:	e8 91 09 00 00       	call   b21 <printf>
 190:	83 c4 10             	add    $0x10,%esp
 193:	eb 12                	jmp    1a7 <print_mode+0x1a7>
  else
    printf(1, "-");
 195:	83 ec 08             	sub    $0x8,%esp
 198:	68 da 0e 00 00       	push   $0xeda
 19d:	6a 01                	push   $0x1
 19f:	e8 7d 09 00 00       	call   b21 <printf>
 1a4:	83 c4 10             	add    $0x10,%esp

  if (st->mode.flags.g_x)
 1a7:	8b 45 08             	mov    0x8(%ebp),%eax
 1aa:	0f b6 40 14          	movzbl 0x14(%eax),%eax
 1ae:	83 e0 08             	and    $0x8,%eax
 1b1:	84 c0                	test   %al,%al
 1b3:	74 14                	je     1c9 <print_mode+0x1c9>
    printf(1, "x");
 1b5:	83 ec 08             	sub    $0x8,%esp
 1b8:	68 e6 0e 00 00       	push   $0xee6
 1bd:	6a 01                	push   $0x1
 1bf:	e8 5d 09 00 00       	call   b21 <printf>
 1c4:	83 c4 10             	add    $0x10,%esp
 1c7:	eb 12                	jmp    1db <print_mode+0x1db>
  else
    printf(1, "-");
 1c9:	83 ec 08             	sub    $0x8,%esp
 1cc:	68 da 0e 00 00       	push   $0xeda
 1d1:	6a 01                	push   $0x1
 1d3:	e8 49 09 00 00       	call   b21 <printf>
 1d8:	83 c4 10             	add    $0x10,%esp

  if (st->mode.flags.o_r)
 1db:	8b 45 08             	mov    0x8(%ebp),%eax
 1de:	0f b6 40 14          	movzbl 0x14(%eax),%eax
 1e2:	83 e0 04             	and    $0x4,%eax
 1e5:	84 c0                	test   %al,%al
 1e7:	74 14                	je     1fd <print_mode+0x1fd>
    printf(1, "r");
 1e9:	83 ec 08             	sub    $0x8,%esp
 1ec:	68 e0 0e 00 00       	push   $0xee0
 1f1:	6a 01                	push   $0x1
 1f3:	e8 29 09 00 00       	call   b21 <printf>
 1f8:	83 c4 10             	add    $0x10,%esp
 1fb:	eb 12                	jmp    20f <print_mode+0x20f>
  else
    printf(1, "-");
 1fd:	83 ec 08             	sub    $0x8,%esp
 200:	68 da 0e 00 00       	push   $0xeda
 205:	6a 01                	push   $0x1
 207:	e8 15 09 00 00       	call   b21 <printf>
 20c:	83 c4 10             	add    $0x10,%esp

  if (st->mode.flags.o_w)
 20f:	8b 45 08             	mov    0x8(%ebp),%eax
 212:	0f b6 40 14          	movzbl 0x14(%eax),%eax
 216:	83 e0 02             	and    $0x2,%eax
 219:	84 c0                	test   %al,%al
 21b:	74 14                	je     231 <print_mode+0x231>
    printf(1, "w");
 21d:	83 ec 08             	sub    $0x8,%esp
 220:	68 e2 0e 00 00       	push   $0xee2
 225:	6a 01                	push   $0x1
 227:	e8 f5 08 00 00       	call   b21 <printf>
 22c:	83 c4 10             	add    $0x10,%esp
 22f:	eb 12                	jmp    243 <print_mode+0x243>
  else
    printf(1, "-");
 231:	83 ec 08             	sub    $0x8,%esp
 234:	68 da 0e 00 00       	push   $0xeda
 239:	6a 01                	push   $0x1
 23b:	e8 e1 08 00 00       	call   b21 <printf>
 240:	83 c4 10             	add    $0x10,%esp

  if (st->mode.flags.o_x)
 243:	8b 45 08             	mov    0x8(%ebp),%eax
 246:	0f b6 40 14          	movzbl 0x14(%eax),%eax
 24a:	83 e0 01             	and    $0x1,%eax
 24d:	84 c0                	test   %al,%al
 24f:	74 14                	je     265 <print_mode+0x265>
    printf(1, "x");
 251:	83 ec 08             	sub    $0x8,%esp
 254:	68 e6 0e 00 00       	push   $0xee6
 259:	6a 01                	push   $0x1
 25b:	e8 c1 08 00 00       	call   b21 <printf>
 260:	83 c4 10             	add    $0x10,%esp
  else
    printf(1, "-");

  return;
 263:	eb 13                	jmp    278 <print_mode+0x278>
    printf(1, "-");

  if (st->mode.flags.o_x)
    printf(1, "x");
  else
    printf(1, "-");
 265:	83 ec 08             	sub    $0x8,%esp
 268:	68 da 0e 00 00       	push   $0xeda
 26d:	6a 01                	push   $0x1
 26f:	e8 ad 08 00 00       	call   b21 <printf>
 274:	83 c4 10             	add    $0x10,%esp

  return;
 277:	90                   	nop
}
 278:	c9                   	leave  
 279:	c3                   	ret    

0000027a <fmtname>:
#include "print_mode.c"
#endif

char*
fmtname(char *path)
{
 27a:	55                   	push   %ebp
 27b:	89 e5                	mov    %esp,%ebp
 27d:	53                   	push   %ebx
 27e:	83 ec 14             	sub    $0x14,%esp
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
 281:	83 ec 0c             	sub    $0xc,%esp
 284:	ff 75 08             	pushl  0x8(%ebp)
 287:	e8 41 04 00 00       	call   6cd <strlen>
 28c:	83 c4 10             	add    $0x10,%esp
 28f:	89 c2                	mov    %eax,%edx
 291:	8b 45 08             	mov    0x8(%ebp),%eax
 294:	01 d0                	add    %edx,%eax
 296:	89 45 f4             	mov    %eax,-0xc(%ebp)
 299:	eb 04                	jmp    29f <fmtname+0x25>
 29b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 29f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2a2:	3b 45 08             	cmp    0x8(%ebp),%eax
 2a5:	72 0a                	jb     2b1 <fmtname+0x37>
 2a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2aa:	0f b6 00             	movzbl (%eax),%eax
 2ad:	3c 2f                	cmp    $0x2f,%al
 2af:	75 ea                	jne    29b <fmtname+0x21>
    ;
  p++;
 2b1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
 2b5:	83 ec 0c             	sub    $0xc,%esp
 2b8:	ff 75 f4             	pushl  -0xc(%ebp)
 2bb:	e8 0d 04 00 00       	call   6cd <strlen>
 2c0:	83 c4 10             	add    $0x10,%esp
 2c3:	83 f8 0d             	cmp    $0xd,%eax
 2c6:	76 05                	jbe    2cd <fmtname+0x53>
    return p;
 2c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2cb:	eb 60                	jmp    32d <fmtname+0xb3>
  memmove(buf, p, strlen(p));
 2cd:	83 ec 0c             	sub    $0xc,%esp
 2d0:	ff 75 f4             	pushl  -0xc(%ebp)
 2d3:	e8 f5 03 00 00       	call   6cd <strlen>
 2d8:	83 c4 10             	add    $0x10,%esp
 2db:	83 ec 04             	sub    $0x4,%esp
 2de:	50                   	push   %eax
 2df:	ff 75 f4             	pushl  -0xc(%ebp)
 2e2:	68 50 12 00 00       	push   $0x1250
 2e7:	e8 31 06 00 00       	call   91d <memmove>
 2ec:	83 c4 10             	add    $0x10,%esp
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
 2ef:	83 ec 0c             	sub    $0xc,%esp
 2f2:	ff 75 f4             	pushl  -0xc(%ebp)
 2f5:	e8 d3 03 00 00       	call   6cd <strlen>
 2fa:	83 c4 10             	add    $0x10,%esp
 2fd:	ba 0e 00 00 00       	mov    $0xe,%edx
 302:	89 d3                	mov    %edx,%ebx
 304:	29 c3                	sub    %eax,%ebx
 306:	83 ec 0c             	sub    $0xc,%esp
 309:	ff 75 f4             	pushl  -0xc(%ebp)
 30c:	e8 bc 03 00 00       	call   6cd <strlen>
 311:	83 c4 10             	add    $0x10,%esp
 314:	05 50 12 00 00       	add    $0x1250,%eax
 319:	83 ec 04             	sub    $0x4,%esp
 31c:	53                   	push   %ebx
 31d:	6a 20                	push   $0x20
 31f:	50                   	push   %eax
 320:	e8 cf 03 00 00       	call   6f4 <memset>
 325:	83 c4 10             	add    $0x10,%esp
  return buf;
 328:	b8 50 12 00 00       	mov    $0x1250,%eax
}
 32d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 330:	c9                   	leave  
 331:	c3                   	ret    

00000332 <ls>:

void
ls(char *path)
{
 332:	55                   	push   %ebp
 333:	89 e5                	mov    %esp,%ebp
 335:	57                   	push   %edi
 336:	56                   	push   %esi
 337:	53                   	push   %ebx
 338:	81 ec 5c 02 00 00    	sub    $0x25c,%esp
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
 33e:	83 ec 08             	sub    $0x8,%esp
 341:	6a 00                	push   $0x0
 343:	ff 75 08             	pushl  0x8(%ebp)
 346:	e8 57 06 00 00       	call   9a2 <open>
 34b:	83 c4 10             	add    $0x10,%esp
 34e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 351:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
 355:	79 1a                	jns    371 <ls+0x3f>
    printf(2, "ls: cannot open %s\n", path);
 357:	83 ec 04             	sub    $0x4,%esp
 35a:	ff 75 08             	pushl  0x8(%ebp)
 35d:	68 e8 0e 00 00       	push   $0xee8
 362:	6a 02                	push   $0x2
 364:	e8 b8 07 00 00       	call   b21 <printf>
 369:	83 c4 10             	add    $0x10,%esp
    return;
 36c:	e9 5b 02 00 00       	jmp    5cc <ls+0x29a>
  }

  if(fstat(fd, &st) < 0){
 371:	83 ec 08             	sub    $0x8,%esp
 374:	8d 85 b4 fd ff ff    	lea    -0x24c(%ebp),%eax
 37a:	50                   	push   %eax
 37b:	ff 75 e4             	pushl  -0x1c(%ebp)
 37e:	e8 37 06 00 00       	call   9ba <fstat>
 383:	83 c4 10             	add    $0x10,%esp
 386:	85 c0                	test   %eax,%eax
 388:	79 28                	jns    3b2 <ls+0x80>
    printf(2, "ls: cannot stat %s\n", path);
 38a:	83 ec 04             	sub    $0x4,%esp
 38d:	ff 75 08             	pushl  0x8(%ebp)
 390:	68 fc 0e 00 00       	push   $0xefc
 395:	6a 02                	push   $0x2
 397:	e8 85 07 00 00       	call   b21 <printf>
 39c:	83 c4 10             	add    $0x10,%esp
    close(fd);
 39f:	83 ec 0c             	sub    $0xc,%esp
 3a2:	ff 75 e4             	pushl  -0x1c(%ebp)
 3a5:	e8 e0 05 00 00       	call   98a <close>
 3aa:	83 c4 10             	add    $0x10,%esp
    return;
 3ad:	e9 1a 02 00 00       	jmp    5cc <ls+0x29a>
  }

  switch(st.type){
 3b2:	0f b7 85 b4 fd ff ff 	movzwl -0x24c(%ebp),%eax
 3b9:	98                   	cwtl   
 3ba:	83 f8 01             	cmp    $0x1,%eax
 3bd:	0f 84 82 00 00 00    	je     445 <ls+0x113>
 3c3:	83 f8 02             	cmp    $0x2,%eax
 3c6:	0f 85 f2 01 00 00    	jne    5be <ls+0x28c>
  case T_FILE:
#ifdef CS333_P5
    printf(1, "mode\t\tname\tuid\tgid\tinode\tsize\n");
 3cc:	83 ec 08             	sub    $0x8,%esp
 3cf:	68 10 0f 00 00       	push   $0xf10
 3d4:	6a 01                	push   $0x1
 3d6:	e8 46 07 00 00       	call   b21 <printf>
 3db:	83 c4 10             	add    $0x10,%esp
    print_mode(&st);
 3de:	83 ec 0c             	sub    $0xc,%esp
 3e1:	8d 85 b4 fd ff ff    	lea    -0x24c(%ebp),%eax
 3e7:	50                   	push   %eax
 3e8:	e8 13 fc ff ff       	call   0 <print_mode>
 3ed:	83 c4 10             	add    $0x10,%esp
    printf(1, " %s%d\t%d\t%d\t%d\n", fmtname(path), st.uid, st.gid, st.ino, st.size);
 3f0:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
 3f6:	89 85 a4 fd ff ff    	mov    %eax,-0x25c(%ebp)
 3fc:	8b bd bc fd ff ff    	mov    -0x244(%ebp),%edi
 402:	0f b7 85 ce fd ff ff 	movzwl -0x232(%ebp),%eax
 409:	0f b7 f0             	movzwl %ax,%esi
 40c:	0f b7 85 cc fd ff ff 	movzwl -0x234(%ebp),%eax
 413:	0f b7 d8             	movzwl %ax,%ebx
 416:	83 ec 0c             	sub    $0xc,%esp
 419:	ff 75 08             	pushl  0x8(%ebp)
 41c:	e8 59 fe ff ff       	call   27a <fmtname>
 421:	83 c4 10             	add    $0x10,%esp
 424:	83 ec 04             	sub    $0x4,%esp
 427:	ff b5 a4 fd ff ff    	pushl  -0x25c(%ebp)
 42d:	57                   	push   %edi
 42e:	56                   	push   %esi
 42f:	53                   	push   %ebx
 430:	50                   	push   %eax
 431:	68 2f 0f 00 00       	push   $0xf2f
 436:	6a 01                	push   $0x1
 438:	e8 e4 06 00 00       	call   b21 <printf>
 43d:	83 c4 20             	add    $0x20,%esp
#else
    printf(1, "%s %d %d %d\n", fmtname(path), st.type, st.ino, st.size);
#endif
    break;
 440:	e9 79 01 00 00       	jmp    5be <ls+0x28c>

  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 445:	83 ec 0c             	sub    $0xc,%esp
 448:	ff 75 08             	pushl  0x8(%ebp)
 44b:	e8 7d 02 00 00       	call   6cd <strlen>
 450:	83 c4 10             	add    $0x10,%esp
 453:	83 c0 10             	add    $0x10,%eax
 456:	3d 00 02 00 00       	cmp    $0x200,%eax
 45b:	76 17                	jbe    474 <ls+0x142>
      printf(1, "ls: path too long\n");
 45d:	83 ec 08             	sub    $0x8,%esp
 460:	68 3f 0f 00 00       	push   $0xf3f
 465:	6a 01                	push   $0x1
 467:	e8 b5 06 00 00       	call   b21 <printf>
 46c:	83 c4 10             	add    $0x10,%esp
      break;
 46f:	e9 4a 01 00 00       	jmp    5be <ls+0x28c>
    }
    strcpy(buf, path);
 474:	83 ec 08             	sub    $0x8,%esp
 477:	ff 75 08             	pushl  0x8(%ebp)
 47a:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 480:	50                   	push   %eax
 481:	e8 d8 01 00 00       	call   65e <strcpy>
 486:	83 c4 10             	add    $0x10,%esp
    p = buf+strlen(buf);
 489:	83 ec 0c             	sub    $0xc,%esp
 48c:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 492:	50                   	push   %eax
 493:	e8 35 02 00 00       	call   6cd <strlen>
 498:	83 c4 10             	add    $0x10,%esp
 49b:	89 c2                	mov    %eax,%edx
 49d:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 4a3:	01 d0                	add    %edx,%eax
 4a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    *p++ = '/';
 4a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
 4ab:	8d 50 01             	lea    0x1(%eax),%edx
 4ae:	89 55 e0             	mov    %edx,-0x20(%ebp)
 4b1:	c6 00 2f             	movb   $0x2f,(%eax)
#ifdef CS333_P5
    printf(1, "mode\t\tname\tuid\tgid\tinode\tsize\n");
 4b4:	83 ec 08             	sub    $0x8,%esp
 4b7:	68 10 0f 00 00       	push   $0xf10
 4bc:	6a 01                	push   $0x1
 4be:	e8 5e 06 00 00       	call   b21 <printf>
 4c3:	83 c4 10             	add    $0x10,%esp
#endif
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 4c6:	e9 d2 00 00 00       	jmp    59d <ls+0x26b>
      if(de.inum == 0)
 4cb:	0f b7 85 d0 fd ff ff 	movzwl -0x230(%ebp),%eax
 4d2:	66 85 c0             	test   %ax,%ax
 4d5:	75 05                	jne    4dc <ls+0x1aa>
        continue;
 4d7:	e9 c1 00 00 00       	jmp    59d <ls+0x26b>
      memmove(p, de.name, DIRSIZ);
 4dc:	83 ec 04             	sub    $0x4,%esp
 4df:	6a 0e                	push   $0xe
 4e1:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 4e7:	83 c0 02             	add    $0x2,%eax
 4ea:	50                   	push   %eax
 4eb:	ff 75 e0             	pushl  -0x20(%ebp)
 4ee:	e8 2a 04 00 00       	call   91d <memmove>
 4f3:	83 c4 10             	add    $0x10,%esp
      p[DIRSIZ] = 0;
 4f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
 4f9:	83 c0 0e             	add    $0xe,%eax
 4fc:	c6 00 00             	movb   $0x0,(%eax)
      if(stat(buf, &st) < 0){
 4ff:	83 ec 08             	sub    $0x8,%esp
 502:	8d 85 b4 fd ff ff    	lea    -0x24c(%ebp),%eax
 508:	50                   	push   %eax
 509:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 50f:	50                   	push   %eax
 510:	e8 9b 02 00 00       	call   7b0 <stat>
 515:	83 c4 10             	add    $0x10,%esp
 518:	85 c0                	test   %eax,%eax
 51a:	79 1b                	jns    537 <ls+0x205>
        printf(1, "ls: cannot stat %s\n", buf);
 51c:	83 ec 04             	sub    $0x4,%esp
 51f:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 525:	50                   	push   %eax
 526:	68 fc 0e 00 00       	push   $0xefc
 52b:	6a 01                	push   $0x1
 52d:	e8 ef 05 00 00       	call   b21 <printf>
 532:	83 c4 10             	add    $0x10,%esp
        continue;
 535:	eb 66                	jmp    59d <ls+0x26b>
      }
#ifdef CS333_P5
      print_mode(&st);
 537:	83 ec 0c             	sub    $0xc,%esp
 53a:	8d 85 b4 fd ff ff    	lea    -0x24c(%ebp),%eax
 540:	50                   	push   %eax
 541:	e8 ba fa ff ff       	call   0 <print_mode>
 546:	83 c4 10             	add    $0x10,%esp
      printf(1, " %s%d\t%d\t%d\t%d\n", fmtname(buf), st.uid, st.gid, st.ino, st.size);
 549:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
 54f:	89 85 a4 fd ff ff    	mov    %eax,-0x25c(%ebp)
 555:	8b bd bc fd ff ff    	mov    -0x244(%ebp),%edi
 55b:	0f b7 85 ce fd ff ff 	movzwl -0x232(%ebp),%eax
 562:	0f b7 f0             	movzwl %ax,%esi
 565:	0f b7 85 cc fd ff ff 	movzwl -0x234(%ebp),%eax
 56c:	0f b7 d8             	movzwl %ax,%ebx
 56f:	83 ec 0c             	sub    $0xc,%esp
 572:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 578:	50                   	push   %eax
 579:	e8 fc fc ff ff       	call   27a <fmtname>
 57e:	83 c4 10             	add    $0x10,%esp
 581:	83 ec 04             	sub    $0x4,%esp
 584:	ff b5 a4 fd ff ff    	pushl  -0x25c(%ebp)
 58a:	57                   	push   %edi
 58b:	56                   	push   %esi
 58c:	53                   	push   %ebx
 58d:	50                   	push   %eax
 58e:	68 2f 0f 00 00       	push   $0xf2f
 593:	6a 01                	push   $0x1
 595:	e8 87 05 00 00       	call   b21 <printf>
 59a:	83 c4 20             	add    $0x20,%esp
    p = buf+strlen(buf);
    *p++ = '/';
#ifdef CS333_P5
    printf(1, "mode\t\tname\tuid\tgid\tinode\tsize\n");
#endif
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 59d:	83 ec 04             	sub    $0x4,%esp
 5a0:	6a 10                	push   $0x10
 5a2:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 5a8:	50                   	push   %eax
 5a9:	ff 75 e4             	pushl  -0x1c(%ebp)
 5ac:	e8 c9 03 00 00       	call   97a <read>
 5b1:	83 c4 10             	add    $0x10,%esp
 5b4:	83 f8 10             	cmp    $0x10,%eax
 5b7:	0f 84 0e ff ff ff    	je     4cb <ls+0x199>
      printf(1, " %s%d\t%d\t%d\t%d\n", fmtname(buf), st.uid, st.gid, st.ino, st.size);
#else
      printf(1, " %s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
#endif
    }
    break;
 5bd:	90                   	nop
  }
  close(fd);
 5be:	83 ec 0c             	sub    $0xc,%esp
 5c1:	ff 75 e4             	pushl  -0x1c(%ebp)
 5c4:	e8 c1 03 00 00       	call   98a <close>
 5c9:	83 c4 10             	add    $0x10,%esp
}
 5cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
 5cf:	5b                   	pop    %ebx
 5d0:	5e                   	pop    %esi
 5d1:	5f                   	pop    %edi
 5d2:	5d                   	pop    %ebp
 5d3:	c3                   	ret    

000005d4 <main>:

int
main(int argc, char *argv[])
{
 5d4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 5d8:	83 e4 f0             	and    $0xfffffff0,%esp
 5db:	ff 71 fc             	pushl  -0x4(%ecx)
 5de:	55                   	push   %ebp
 5df:	89 e5                	mov    %esp,%ebp
 5e1:	53                   	push   %ebx
 5e2:	51                   	push   %ecx
 5e3:	83 ec 10             	sub    $0x10,%esp
 5e6:	89 cb                	mov    %ecx,%ebx
  int i;

  if(argc < 2){
 5e8:	83 3b 01             	cmpl   $0x1,(%ebx)
 5eb:	7f 15                	jg     602 <main+0x2e>
    ls(".");
 5ed:	83 ec 0c             	sub    $0xc,%esp
 5f0:	68 52 0f 00 00       	push   $0xf52
 5f5:	e8 38 fd ff ff       	call   332 <ls>
 5fa:	83 c4 10             	add    $0x10,%esp
    exit();
 5fd:	e8 60 03 00 00       	call   962 <exit>
  }
  for(i=1; i<argc; i++)
 602:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
 609:	eb 21                	jmp    62c <main+0x58>
    ls(argv[i]);
 60b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 60e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 615:	8b 43 04             	mov    0x4(%ebx),%eax
 618:	01 d0                	add    %edx,%eax
 61a:	8b 00                	mov    (%eax),%eax
 61c:	83 ec 0c             	sub    $0xc,%esp
 61f:	50                   	push   %eax
 620:	e8 0d fd ff ff       	call   332 <ls>
 625:	83 c4 10             	add    $0x10,%esp

  if(argc < 2){
    ls(".");
    exit();
  }
  for(i=1; i<argc; i++)
 628:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 62c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 62f:	3b 03                	cmp    (%ebx),%eax
 631:	7c d8                	jl     60b <main+0x37>
    ls(argv[i]);
  exit();
 633:	e8 2a 03 00 00       	call   962 <exit>

00000638 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 638:	55                   	push   %ebp
 639:	89 e5                	mov    %esp,%ebp
 63b:	57                   	push   %edi
 63c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 63d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 640:	8b 55 10             	mov    0x10(%ebp),%edx
 643:	8b 45 0c             	mov    0xc(%ebp),%eax
 646:	89 cb                	mov    %ecx,%ebx
 648:	89 df                	mov    %ebx,%edi
 64a:	89 d1                	mov    %edx,%ecx
 64c:	fc                   	cld    
 64d:	f3 aa                	rep stos %al,%es:(%edi)
 64f:	89 ca                	mov    %ecx,%edx
 651:	89 fb                	mov    %edi,%ebx
 653:	89 5d 08             	mov    %ebx,0x8(%ebp)
 656:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 659:	90                   	nop
 65a:	5b                   	pop    %ebx
 65b:	5f                   	pop    %edi
 65c:	5d                   	pop    %ebp
 65d:	c3                   	ret    

0000065e <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 65e:	55                   	push   %ebp
 65f:	89 e5                	mov    %esp,%ebp
 661:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 664:	8b 45 08             	mov    0x8(%ebp),%eax
 667:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 66a:	90                   	nop
 66b:	8b 45 08             	mov    0x8(%ebp),%eax
 66e:	8d 50 01             	lea    0x1(%eax),%edx
 671:	89 55 08             	mov    %edx,0x8(%ebp)
 674:	8b 55 0c             	mov    0xc(%ebp),%edx
 677:	8d 4a 01             	lea    0x1(%edx),%ecx
 67a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 67d:	0f b6 12             	movzbl (%edx),%edx
 680:	88 10                	mov    %dl,(%eax)
 682:	0f b6 00             	movzbl (%eax),%eax
 685:	84 c0                	test   %al,%al
 687:	75 e2                	jne    66b <strcpy+0xd>
    ;
  return os;
 689:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 68c:	c9                   	leave  
 68d:	c3                   	ret    

0000068e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 68e:	55                   	push   %ebp
 68f:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 691:	eb 08                	jmp    69b <strcmp+0xd>
    p++, q++;
 693:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 697:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 69b:	8b 45 08             	mov    0x8(%ebp),%eax
 69e:	0f b6 00             	movzbl (%eax),%eax
 6a1:	84 c0                	test   %al,%al
 6a3:	74 10                	je     6b5 <strcmp+0x27>
 6a5:	8b 45 08             	mov    0x8(%ebp),%eax
 6a8:	0f b6 10             	movzbl (%eax),%edx
 6ab:	8b 45 0c             	mov    0xc(%ebp),%eax
 6ae:	0f b6 00             	movzbl (%eax),%eax
 6b1:	38 c2                	cmp    %al,%dl
 6b3:	74 de                	je     693 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 6b5:	8b 45 08             	mov    0x8(%ebp),%eax
 6b8:	0f b6 00             	movzbl (%eax),%eax
 6bb:	0f b6 d0             	movzbl %al,%edx
 6be:	8b 45 0c             	mov    0xc(%ebp),%eax
 6c1:	0f b6 00             	movzbl (%eax),%eax
 6c4:	0f b6 c0             	movzbl %al,%eax
 6c7:	29 c2                	sub    %eax,%edx
 6c9:	89 d0                	mov    %edx,%eax
}
 6cb:	5d                   	pop    %ebp
 6cc:	c3                   	ret    

000006cd <strlen>:

uint
strlen(char *s)
{
 6cd:	55                   	push   %ebp
 6ce:	89 e5                	mov    %esp,%ebp
 6d0:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 6d3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 6da:	eb 04                	jmp    6e0 <strlen+0x13>
 6dc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 6e0:	8b 55 fc             	mov    -0x4(%ebp),%edx
 6e3:	8b 45 08             	mov    0x8(%ebp),%eax
 6e6:	01 d0                	add    %edx,%eax
 6e8:	0f b6 00             	movzbl (%eax),%eax
 6eb:	84 c0                	test   %al,%al
 6ed:	75 ed                	jne    6dc <strlen+0xf>
    ;
  return n;
 6ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 6f2:	c9                   	leave  
 6f3:	c3                   	ret    

000006f4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 6f4:	55                   	push   %ebp
 6f5:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 6f7:	8b 45 10             	mov    0x10(%ebp),%eax
 6fa:	50                   	push   %eax
 6fb:	ff 75 0c             	pushl  0xc(%ebp)
 6fe:	ff 75 08             	pushl  0x8(%ebp)
 701:	e8 32 ff ff ff       	call   638 <stosb>
 706:	83 c4 0c             	add    $0xc,%esp
  return dst;
 709:	8b 45 08             	mov    0x8(%ebp),%eax
}
 70c:	c9                   	leave  
 70d:	c3                   	ret    

0000070e <strchr>:

char*
strchr(const char *s, char c)
{
 70e:	55                   	push   %ebp
 70f:	89 e5                	mov    %esp,%ebp
 711:	83 ec 04             	sub    $0x4,%esp
 714:	8b 45 0c             	mov    0xc(%ebp),%eax
 717:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 71a:	eb 14                	jmp    730 <strchr+0x22>
    if(*s == c)
 71c:	8b 45 08             	mov    0x8(%ebp),%eax
 71f:	0f b6 00             	movzbl (%eax),%eax
 722:	3a 45 fc             	cmp    -0x4(%ebp),%al
 725:	75 05                	jne    72c <strchr+0x1e>
      return (char*)s;
 727:	8b 45 08             	mov    0x8(%ebp),%eax
 72a:	eb 13                	jmp    73f <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 72c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 730:	8b 45 08             	mov    0x8(%ebp),%eax
 733:	0f b6 00             	movzbl (%eax),%eax
 736:	84 c0                	test   %al,%al
 738:	75 e2                	jne    71c <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 73a:	b8 00 00 00 00       	mov    $0x0,%eax
}
 73f:	c9                   	leave  
 740:	c3                   	ret    

00000741 <gets>:

char*
gets(char *buf, int max)
{
 741:	55                   	push   %ebp
 742:	89 e5                	mov    %esp,%ebp
 744:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 747:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 74e:	eb 42                	jmp    792 <gets+0x51>
    cc = read(0, &c, 1);
 750:	83 ec 04             	sub    $0x4,%esp
 753:	6a 01                	push   $0x1
 755:	8d 45 ef             	lea    -0x11(%ebp),%eax
 758:	50                   	push   %eax
 759:	6a 00                	push   $0x0
 75b:	e8 1a 02 00 00       	call   97a <read>
 760:	83 c4 10             	add    $0x10,%esp
 763:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 766:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 76a:	7e 33                	jle    79f <gets+0x5e>
      break;
    buf[i++] = c;
 76c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 76f:	8d 50 01             	lea    0x1(%eax),%edx
 772:	89 55 f4             	mov    %edx,-0xc(%ebp)
 775:	89 c2                	mov    %eax,%edx
 777:	8b 45 08             	mov    0x8(%ebp),%eax
 77a:	01 c2                	add    %eax,%edx
 77c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 780:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 782:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 786:	3c 0a                	cmp    $0xa,%al
 788:	74 16                	je     7a0 <gets+0x5f>
 78a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 78e:	3c 0d                	cmp    $0xd,%al
 790:	74 0e                	je     7a0 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 792:	8b 45 f4             	mov    -0xc(%ebp),%eax
 795:	83 c0 01             	add    $0x1,%eax
 798:	3b 45 0c             	cmp    0xc(%ebp),%eax
 79b:	7c b3                	jl     750 <gets+0xf>
 79d:	eb 01                	jmp    7a0 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 79f:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 7a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
 7a3:	8b 45 08             	mov    0x8(%ebp),%eax
 7a6:	01 d0                	add    %edx,%eax
 7a8:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 7ab:	8b 45 08             	mov    0x8(%ebp),%eax
}
 7ae:	c9                   	leave  
 7af:	c3                   	ret    

000007b0 <stat>:

int
stat(char *n, struct stat *st)
{
 7b0:	55                   	push   %ebp
 7b1:	89 e5                	mov    %esp,%ebp
 7b3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 7b6:	83 ec 08             	sub    $0x8,%esp
 7b9:	6a 00                	push   $0x0
 7bb:	ff 75 08             	pushl  0x8(%ebp)
 7be:	e8 df 01 00 00       	call   9a2 <open>
 7c3:	83 c4 10             	add    $0x10,%esp
 7c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 7c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7cd:	79 07                	jns    7d6 <stat+0x26>
    return -1;
 7cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 7d4:	eb 25                	jmp    7fb <stat+0x4b>
  r = fstat(fd, st);
 7d6:	83 ec 08             	sub    $0x8,%esp
 7d9:	ff 75 0c             	pushl  0xc(%ebp)
 7dc:	ff 75 f4             	pushl  -0xc(%ebp)
 7df:	e8 d6 01 00 00       	call   9ba <fstat>
 7e4:	83 c4 10             	add    $0x10,%esp
 7e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 7ea:	83 ec 0c             	sub    $0xc,%esp
 7ed:	ff 75 f4             	pushl  -0xc(%ebp)
 7f0:	e8 95 01 00 00       	call   98a <close>
 7f5:	83 c4 10             	add    $0x10,%esp
  return r;
 7f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 7fb:	c9                   	leave  
 7fc:	c3                   	ret    

000007fd <atoi>:

int
atoi(const char *s)
{
 7fd:	55                   	push   %ebp
 7fe:	89 e5                	mov    %esp,%ebp
 800:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 803:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 80a:	eb 04                	jmp    810 <atoi+0x13>
 80c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 810:	8b 45 08             	mov    0x8(%ebp),%eax
 813:	0f b6 00             	movzbl (%eax),%eax
 816:	3c 20                	cmp    $0x20,%al
 818:	74 f2                	je     80c <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 81a:	8b 45 08             	mov    0x8(%ebp),%eax
 81d:	0f b6 00             	movzbl (%eax),%eax
 820:	3c 2d                	cmp    $0x2d,%al
 822:	75 07                	jne    82b <atoi+0x2e>
 824:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 829:	eb 05                	jmp    830 <atoi+0x33>
 82b:	b8 01 00 00 00       	mov    $0x1,%eax
 830:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 833:	8b 45 08             	mov    0x8(%ebp),%eax
 836:	0f b6 00             	movzbl (%eax),%eax
 839:	3c 2b                	cmp    $0x2b,%al
 83b:	74 0a                	je     847 <atoi+0x4a>
 83d:	8b 45 08             	mov    0x8(%ebp),%eax
 840:	0f b6 00             	movzbl (%eax),%eax
 843:	3c 2d                	cmp    $0x2d,%al
 845:	75 2b                	jne    872 <atoi+0x75>
    s++;
 847:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 84b:	eb 25                	jmp    872 <atoi+0x75>
    n = n*10 + *s++ - '0';
 84d:	8b 55 fc             	mov    -0x4(%ebp),%edx
 850:	89 d0                	mov    %edx,%eax
 852:	c1 e0 02             	shl    $0x2,%eax
 855:	01 d0                	add    %edx,%eax
 857:	01 c0                	add    %eax,%eax
 859:	89 c1                	mov    %eax,%ecx
 85b:	8b 45 08             	mov    0x8(%ebp),%eax
 85e:	8d 50 01             	lea    0x1(%eax),%edx
 861:	89 55 08             	mov    %edx,0x8(%ebp)
 864:	0f b6 00             	movzbl (%eax),%eax
 867:	0f be c0             	movsbl %al,%eax
 86a:	01 c8                	add    %ecx,%eax
 86c:	83 e8 30             	sub    $0x30,%eax
 86f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
 872:	8b 45 08             	mov    0x8(%ebp),%eax
 875:	0f b6 00             	movzbl (%eax),%eax
 878:	3c 2f                	cmp    $0x2f,%al
 87a:	7e 0a                	jle    886 <atoi+0x89>
 87c:	8b 45 08             	mov    0x8(%ebp),%eax
 87f:	0f b6 00             	movzbl (%eax),%eax
 882:	3c 39                	cmp    $0x39,%al
 884:	7e c7                	jle    84d <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 886:	8b 45 f8             	mov    -0x8(%ebp),%eax
 889:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 88d:	c9                   	leave  
 88e:	c3                   	ret    

0000088f <atoo>:

int
atoo(const char *s)
{
 88f:	55                   	push   %ebp
 890:	89 e5                	mov    %esp,%ebp
 892:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 895:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 89c:	eb 04                	jmp    8a2 <atoo+0x13>
 89e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 8a2:	8b 45 08             	mov    0x8(%ebp),%eax
 8a5:	0f b6 00             	movzbl (%eax),%eax
 8a8:	3c 20                	cmp    $0x20,%al
 8aa:	74 f2                	je     89e <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 8ac:	8b 45 08             	mov    0x8(%ebp),%eax
 8af:	0f b6 00             	movzbl (%eax),%eax
 8b2:	3c 2d                	cmp    $0x2d,%al
 8b4:	75 07                	jne    8bd <atoo+0x2e>
 8b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 8bb:	eb 05                	jmp    8c2 <atoo+0x33>
 8bd:	b8 01 00 00 00       	mov    $0x1,%eax
 8c2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 8c5:	8b 45 08             	mov    0x8(%ebp),%eax
 8c8:	0f b6 00             	movzbl (%eax),%eax
 8cb:	3c 2b                	cmp    $0x2b,%al
 8cd:	74 0a                	je     8d9 <atoo+0x4a>
 8cf:	8b 45 08             	mov    0x8(%ebp),%eax
 8d2:	0f b6 00             	movzbl (%eax),%eax
 8d5:	3c 2d                	cmp    $0x2d,%al
 8d7:	75 27                	jne    900 <atoo+0x71>
    s++;
 8d9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 8dd:	eb 21                	jmp    900 <atoo+0x71>
    n = n*8 + *s++ - '0';
 8df:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e2:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 8e9:	8b 45 08             	mov    0x8(%ebp),%eax
 8ec:	8d 50 01             	lea    0x1(%eax),%edx
 8ef:	89 55 08             	mov    %edx,0x8(%ebp)
 8f2:	0f b6 00             	movzbl (%eax),%eax
 8f5:	0f be c0             	movsbl %al,%eax
 8f8:	01 c8                	add    %ecx,%eax
 8fa:	83 e8 30             	sub    $0x30,%eax
 8fd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 900:	8b 45 08             	mov    0x8(%ebp),%eax
 903:	0f b6 00             	movzbl (%eax),%eax
 906:	3c 2f                	cmp    $0x2f,%al
 908:	7e 0a                	jle    914 <atoo+0x85>
 90a:	8b 45 08             	mov    0x8(%ebp),%eax
 90d:	0f b6 00             	movzbl (%eax),%eax
 910:	3c 37                	cmp    $0x37,%al
 912:	7e cb                	jle    8df <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 914:	8b 45 f8             	mov    -0x8(%ebp),%eax
 917:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 91b:	c9                   	leave  
 91c:	c3                   	ret    

0000091d <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 91d:	55                   	push   %ebp
 91e:	89 e5                	mov    %esp,%ebp
 920:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 923:	8b 45 08             	mov    0x8(%ebp),%eax
 926:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 929:	8b 45 0c             	mov    0xc(%ebp),%eax
 92c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 92f:	eb 17                	jmp    948 <memmove+0x2b>
    *dst++ = *src++;
 931:	8b 45 fc             	mov    -0x4(%ebp),%eax
 934:	8d 50 01             	lea    0x1(%eax),%edx
 937:	89 55 fc             	mov    %edx,-0x4(%ebp)
 93a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 93d:	8d 4a 01             	lea    0x1(%edx),%ecx
 940:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 943:	0f b6 12             	movzbl (%edx),%edx
 946:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 948:	8b 45 10             	mov    0x10(%ebp),%eax
 94b:	8d 50 ff             	lea    -0x1(%eax),%edx
 94e:	89 55 10             	mov    %edx,0x10(%ebp)
 951:	85 c0                	test   %eax,%eax
 953:	7f dc                	jg     931 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 955:	8b 45 08             	mov    0x8(%ebp),%eax
}
 958:	c9                   	leave  
 959:	c3                   	ret    

0000095a <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 95a:	b8 01 00 00 00       	mov    $0x1,%eax
 95f:	cd 40                	int    $0x40
 961:	c3                   	ret    

00000962 <exit>:
SYSCALL(exit)
 962:	b8 02 00 00 00       	mov    $0x2,%eax
 967:	cd 40                	int    $0x40
 969:	c3                   	ret    

0000096a <wait>:
SYSCALL(wait)
 96a:	b8 03 00 00 00       	mov    $0x3,%eax
 96f:	cd 40                	int    $0x40
 971:	c3                   	ret    

00000972 <pipe>:
SYSCALL(pipe)
 972:	b8 04 00 00 00       	mov    $0x4,%eax
 977:	cd 40                	int    $0x40
 979:	c3                   	ret    

0000097a <read>:
SYSCALL(read)
 97a:	b8 05 00 00 00       	mov    $0x5,%eax
 97f:	cd 40                	int    $0x40
 981:	c3                   	ret    

00000982 <write>:
SYSCALL(write)
 982:	b8 10 00 00 00       	mov    $0x10,%eax
 987:	cd 40                	int    $0x40
 989:	c3                   	ret    

0000098a <close>:
SYSCALL(close)
 98a:	b8 15 00 00 00       	mov    $0x15,%eax
 98f:	cd 40                	int    $0x40
 991:	c3                   	ret    

00000992 <kill>:
SYSCALL(kill)
 992:	b8 06 00 00 00       	mov    $0x6,%eax
 997:	cd 40                	int    $0x40
 999:	c3                   	ret    

0000099a <exec>:
SYSCALL(exec)
 99a:	b8 07 00 00 00       	mov    $0x7,%eax
 99f:	cd 40                	int    $0x40
 9a1:	c3                   	ret    

000009a2 <open>:
SYSCALL(open)
 9a2:	b8 0f 00 00 00       	mov    $0xf,%eax
 9a7:	cd 40                	int    $0x40
 9a9:	c3                   	ret    

000009aa <mknod>:
SYSCALL(mknod)
 9aa:	b8 11 00 00 00       	mov    $0x11,%eax
 9af:	cd 40                	int    $0x40
 9b1:	c3                   	ret    

000009b2 <unlink>:
SYSCALL(unlink)
 9b2:	b8 12 00 00 00       	mov    $0x12,%eax
 9b7:	cd 40                	int    $0x40
 9b9:	c3                   	ret    

000009ba <fstat>:
SYSCALL(fstat)
 9ba:	b8 08 00 00 00       	mov    $0x8,%eax
 9bf:	cd 40                	int    $0x40
 9c1:	c3                   	ret    

000009c2 <link>:
SYSCALL(link)
 9c2:	b8 13 00 00 00       	mov    $0x13,%eax
 9c7:	cd 40                	int    $0x40
 9c9:	c3                   	ret    

000009ca <mkdir>:
SYSCALL(mkdir)
 9ca:	b8 14 00 00 00       	mov    $0x14,%eax
 9cf:	cd 40                	int    $0x40
 9d1:	c3                   	ret    

000009d2 <chdir>:
SYSCALL(chdir)
 9d2:	b8 09 00 00 00       	mov    $0x9,%eax
 9d7:	cd 40                	int    $0x40
 9d9:	c3                   	ret    

000009da <dup>:
SYSCALL(dup)
 9da:	b8 0a 00 00 00       	mov    $0xa,%eax
 9df:	cd 40                	int    $0x40
 9e1:	c3                   	ret    

000009e2 <getpid>:
SYSCALL(getpid)
 9e2:	b8 0b 00 00 00       	mov    $0xb,%eax
 9e7:	cd 40                	int    $0x40
 9e9:	c3                   	ret    

000009ea <sbrk>:
SYSCALL(sbrk)
 9ea:	b8 0c 00 00 00       	mov    $0xc,%eax
 9ef:	cd 40                	int    $0x40
 9f1:	c3                   	ret    

000009f2 <sleep>:
SYSCALL(sleep)
 9f2:	b8 0d 00 00 00       	mov    $0xd,%eax
 9f7:	cd 40                	int    $0x40
 9f9:	c3                   	ret    

000009fa <uptime>:
SYSCALL(uptime)
 9fa:	b8 0e 00 00 00       	mov    $0xe,%eax
 9ff:	cd 40                	int    $0x40
 a01:	c3                   	ret    

00000a02 <halt>:
SYSCALL(halt)
 a02:	b8 16 00 00 00       	mov    $0x16,%eax
 a07:	cd 40                	int    $0x40
 a09:	c3                   	ret    

00000a0a <date>:
SYSCALL(date)
 a0a:	b8 17 00 00 00       	mov    $0x17,%eax
 a0f:	cd 40                	int    $0x40
 a11:	c3                   	ret    

00000a12 <getuid>:
SYSCALL(getuid)
 a12:	b8 18 00 00 00       	mov    $0x18,%eax
 a17:	cd 40                	int    $0x40
 a19:	c3                   	ret    

00000a1a <getgid>:
SYSCALL(getgid)
 a1a:	b8 19 00 00 00       	mov    $0x19,%eax
 a1f:	cd 40                	int    $0x40
 a21:	c3                   	ret    

00000a22 <getppid>:
SYSCALL(getppid)
 a22:	b8 1a 00 00 00       	mov    $0x1a,%eax
 a27:	cd 40                	int    $0x40
 a29:	c3                   	ret    

00000a2a <setuid>:
SYSCALL(setuid)
 a2a:	b8 1b 00 00 00       	mov    $0x1b,%eax
 a2f:	cd 40                	int    $0x40
 a31:	c3                   	ret    

00000a32 <setgid>:
SYSCALL(setgid)
 a32:	b8 1c 00 00 00       	mov    $0x1c,%eax
 a37:	cd 40                	int    $0x40
 a39:	c3                   	ret    

00000a3a <getprocs>:
SYSCALL(getprocs)
 a3a:	b8 1a 00 00 00       	mov    $0x1a,%eax
 a3f:	cd 40                	int    $0x40
 a41:	c3                   	ret    

00000a42 <setpriority>:
SYSCALL(setpriority)
 a42:	b8 1b 00 00 00       	mov    $0x1b,%eax
 a47:	cd 40                	int    $0x40
 a49:	c3                   	ret    

00000a4a <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 a4a:	55                   	push   %ebp
 a4b:	89 e5                	mov    %esp,%ebp
 a4d:	83 ec 18             	sub    $0x18,%esp
 a50:	8b 45 0c             	mov    0xc(%ebp),%eax
 a53:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 a56:	83 ec 04             	sub    $0x4,%esp
 a59:	6a 01                	push   $0x1
 a5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
 a5e:	50                   	push   %eax
 a5f:	ff 75 08             	pushl  0x8(%ebp)
 a62:	e8 1b ff ff ff       	call   982 <write>
 a67:	83 c4 10             	add    $0x10,%esp
}
 a6a:	90                   	nop
 a6b:	c9                   	leave  
 a6c:	c3                   	ret    

00000a6d <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 a6d:	55                   	push   %ebp
 a6e:	89 e5                	mov    %esp,%ebp
 a70:	53                   	push   %ebx
 a71:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 a74:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 a7b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 a7f:	74 17                	je     a98 <printint+0x2b>
 a81:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 a85:	79 11                	jns    a98 <printint+0x2b>
    neg = 1;
 a87:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 a8e:	8b 45 0c             	mov    0xc(%ebp),%eax
 a91:	f7 d8                	neg    %eax
 a93:	89 45 ec             	mov    %eax,-0x14(%ebp)
 a96:	eb 06                	jmp    a9e <printint+0x31>
  } else {
    x = xx;
 a98:	8b 45 0c             	mov    0xc(%ebp),%eax
 a9b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 a9e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 aa5:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 aa8:	8d 41 01             	lea    0x1(%ecx),%eax
 aab:	89 45 f4             	mov    %eax,-0xc(%ebp)
 aae:	8b 5d 10             	mov    0x10(%ebp),%ebx
 ab1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 ab4:	ba 00 00 00 00       	mov    $0x0,%edx
 ab9:	f7 f3                	div    %ebx
 abb:	89 d0                	mov    %edx,%eax
 abd:	0f b6 80 3c 12 00 00 	movzbl 0x123c(%eax),%eax
 ac4:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 ac8:	8b 5d 10             	mov    0x10(%ebp),%ebx
 acb:	8b 45 ec             	mov    -0x14(%ebp),%eax
 ace:	ba 00 00 00 00       	mov    $0x0,%edx
 ad3:	f7 f3                	div    %ebx
 ad5:	89 45 ec             	mov    %eax,-0x14(%ebp)
 ad8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 adc:	75 c7                	jne    aa5 <printint+0x38>
  if(neg)
 ade:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 ae2:	74 2d                	je     b11 <printint+0xa4>
    buf[i++] = '-';
 ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ae7:	8d 50 01             	lea    0x1(%eax),%edx
 aea:	89 55 f4             	mov    %edx,-0xc(%ebp)
 aed:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 af2:	eb 1d                	jmp    b11 <printint+0xa4>
    putc(fd, buf[i]);
 af4:	8d 55 dc             	lea    -0x24(%ebp),%edx
 af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 afa:	01 d0                	add    %edx,%eax
 afc:	0f b6 00             	movzbl (%eax),%eax
 aff:	0f be c0             	movsbl %al,%eax
 b02:	83 ec 08             	sub    $0x8,%esp
 b05:	50                   	push   %eax
 b06:	ff 75 08             	pushl  0x8(%ebp)
 b09:	e8 3c ff ff ff       	call   a4a <putc>
 b0e:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 b11:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 b15:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b19:	79 d9                	jns    af4 <printint+0x87>
    putc(fd, buf[i]);
}
 b1b:	90                   	nop
 b1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 b1f:	c9                   	leave  
 b20:	c3                   	ret    

00000b21 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 b21:	55                   	push   %ebp
 b22:	89 e5                	mov    %esp,%ebp
 b24:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 b27:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 b2e:	8d 45 0c             	lea    0xc(%ebp),%eax
 b31:	83 c0 04             	add    $0x4,%eax
 b34:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 b37:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 b3e:	e9 59 01 00 00       	jmp    c9c <printf+0x17b>
    c = fmt[i] & 0xff;
 b43:	8b 55 0c             	mov    0xc(%ebp),%edx
 b46:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b49:	01 d0                	add    %edx,%eax
 b4b:	0f b6 00             	movzbl (%eax),%eax
 b4e:	0f be c0             	movsbl %al,%eax
 b51:	25 ff 00 00 00       	and    $0xff,%eax
 b56:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 b59:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 b5d:	75 2c                	jne    b8b <printf+0x6a>
      if(c == '%'){
 b5f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 b63:	75 0c                	jne    b71 <printf+0x50>
        state = '%';
 b65:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 b6c:	e9 27 01 00 00       	jmp    c98 <printf+0x177>
      } else {
        putc(fd, c);
 b71:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 b74:	0f be c0             	movsbl %al,%eax
 b77:	83 ec 08             	sub    $0x8,%esp
 b7a:	50                   	push   %eax
 b7b:	ff 75 08             	pushl  0x8(%ebp)
 b7e:	e8 c7 fe ff ff       	call   a4a <putc>
 b83:	83 c4 10             	add    $0x10,%esp
 b86:	e9 0d 01 00 00       	jmp    c98 <printf+0x177>
      }
    } else if(state == '%'){
 b8b:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 b8f:	0f 85 03 01 00 00    	jne    c98 <printf+0x177>
      if(c == 'd'){
 b95:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 b99:	75 1e                	jne    bb9 <printf+0x98>
        printint(fd, *ap, 10, 1);
 b9b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 b9e:	8b 00                	mov    (%eax),%eax
 ba0:	6a 01                	push   $0x1
 ba2:	6a 0a                	push   $0xa
 ba4:	50                   	push   %eax
 ba5:	ff 75 08             	pushl  0x8(%ebp)
 ba8:	e8 c0 fe ff ff       	call   a6d <printint>
 bad:	83 c4 10             	add    $0x10,%esp
        ap++;
 bb0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 bb4:	e9 d8 00 00 00       	jmp    c91 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 bb9:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 bbd:	74 06                	je     bc5 <printf+0xa4>
 bbf:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 bc3:	75 1e                	jne    be3 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 bc5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 bc8:	8b 00                	mov    (%eax),%eax
 bca:	6a 00                	push   $0x0
 bcc:	6a 10                	push   $0x10
 bce:	50                   	push   %eax
 bcf:	ff 75 08             	pushl  0x8(%ebp)
 bd2:	e8 96 fe ff ff       	call   a6d <printint>
 bd7:	83 c4 10             	add    $0x10,%esp
        ap++;
 bda:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 bde:	e9 ae 00 00 00       	jmp    c91 <printf+0x170>
      } else if(c == 's'){
 be3:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 be7:	75 43                	jne    c2c <printf+0x10b>
        s = (char*)*ap;
 be9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 bec:	8b 00                	mov    (%eax),%eax
 bee:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 bf1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 bf5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 bf9:	75 25                	jne    c20 <printf+0xff>
          s = "(null)";
 bfb:	c7 45 f4 54 0f 00 00 	movl   $0xf54,-0xc(%ebp)
        while(*s != 0){
 c02:	eb 1c                	jmp    c20 <printf+0xff>
          putc(fd, *s);
 c04:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c07:	0f b6 00             	movzbl (%eax),%eax
 c0a:	0f be c0             	movsbl %al,%eax
 c0d:	83 ec 08             	sub    $0x8,%esp
 c10:	50                   	push   %eax
 c11:	ff 75 08             	pushl  0x8(%ebp)
 c14:	e8 31 fe ff ff       	call   a4a <putc>
 c19:	83 c4 10             	add    $0x10,%esp
          s++;
 c1c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c23:	0f b6 00             	movzbl (%eax),%eax
 c26:	84 c0                	test   %al,%al
 c28:	75 da                	jne    c04 <printf+0xe3>
 c2a:	eb 65                	jmp    c91 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 c2c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 c30:	75 1d                	jne    c4f <printf+0x12e>
        putc(fd, *ap);
 c32:	8b 45 e8             	mov    -0x18(%ebp),%eax
 c35:	8b 00                	mov    (%eax),%eax
 c37:	0f be c0             	movsbl %al,%eax
 c3a:	83 ec 08             	sub    $0x8,%esp
 c3d:	50                   	push   %eax
 c3e:	ff 75 08             	pushl  0x8(%ebp)
 c41:	e8 04 fe ff ff       	call   a4a <putc>
 c46:	83 c4 10             	add    $0x10,%esp
        ap++;
 c49:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 c4d:	eb 42                	jmp    c91 <printf+0x170>
      } else if(c == '%'){
 c4f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 c53:	75 17                	jne    c6c <printf+0x14b>
        putc(fd, c);
 c55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 c58:	0f be c0             	movsbl %al,%eax
 c5b:	83 ec 08             	sub    $0x8,%esp
 c5e:	50                   	push   %eax
 c5f:	ff 75 08             	pushl  0x8(%ebp)
 c62:	e8 e3 fd ff ff       	call   a4a <putc>
 c67:	83 c4 10             	add    $0x10,%esp
 c6a:	eb 25                	jmp    c91 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 c6c:	83 ec 08             	sub    $0x8,%esp
 c6f:	6a 25                	push   $0x25
 c71:	ff 75 08             	pushl  0x8(%ebp)
 c74:	e8 d1 fd ff ff       	call   a4a <putc>
 c79:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 c7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 c7f:	0f be c0             	movsbl %al,%eax
 c82:	83 ec 08             	sub    $0x8,%esp
 c85:	50                   	push   %eax
 c86:	ff 75 08             	pushl  0x8(%ebp)
 c89:	e8 bc fd ff ff       	call   a4a <putc>
 c8e:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 c91:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 c98:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 c9c:	8b 55 0c             	mov    0xc(%ebp),%edx
 c9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ca2:	01 d0                	add    %edx,%eax
 ca4:	0f b6 00             	movzbl (%eax),%eax
 ca7:	84 c0                	test   %al,%al
 ca9:	0f 85 94 fe ff ff    	jne    b43 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 caf:	90                   	nop
 cb0:	c9                   	leave  
 cb1:	c3                   	ret    

00000cb2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 cb2:	55                   	push   %ebp
 cb3:	89 e5                	mov    %esp,%ebp
 cb5:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 cb8:	8b 45 08             	mov    0x8(%ebp),%eax
 cbb:	83 e8 08             	sub    $0x8,%eax
 cbe:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 cc1:	a1 68 12 00 00       	mov    0x1268,%eax
 cc6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 cc9:	eb 24                	jmp    cef <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ccb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cce:	8b 00                	mov    (%eax),%eax
 cd0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 cd3:	77 12                	ja     ce7 <free+0x35>
 cd5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 cd8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 cdb:	77 24                	ja     d01 <free+0x4f>
 cdd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ce0:	8b 00                	mov    (%eax),%eax
 ce2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 ce5:	77 1a                	ja     d01 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ce7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cea:	8b 00                	mov    (%eax),%eax
 cec:	89 45 fc             	mov    %eax,-0x4(%ebp)
 cef:	8b 45 f8             	mov    -0x8(%ebp),%eax
 cf2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 cf5:	76 d4                	jbe    ccb <free+0x19>
 cf7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cfa:	8b 00                	mov    (%eax),%eax
 cfc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 cff:	76 ca                	jbe    ccb <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 d01:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d04:	8b 40 04             	mov    0x4(%eax),%eax
 d07:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 d0e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d11:	01 c2                	add    %eax,%edx
 d13:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d16:	8b 00                	mov    (%eax),%eax
 d18:	39 c2                	cmp    %eax,%edx
 d1a:	75 24                	jne    d40 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 d1c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d1f:	8b 50 04             	mov    0x4(%eax),%edx
 d22:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d25:	8b 00                	mov    (%eax),%eax
 d27:	8b 40 04             	mov    0x4(%eax),%eax
 d2a:	01 c2                	add    %eax,%edx
 d2c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d2f:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 d32:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d35:	8b 00                	mov    (%eax),%eax
 d37:	8b 10                	mov    (%eax),%edx
 d39:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d3c:	89 10                	mov    %edx,(%eax)
 d3e:	eb 0a                	jmp    d4a <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 d40:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d43:	8b 10                	mov    (%eax),%edx
 d45:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d48:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 d4a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d4d:	8b 40 04             	mov    0x4(%eax),%eax
 d50:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 d57:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d5a:	01 d0                	add    %edx,%eax
 d5c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 d5f:	75 20                	jne    d81 <free+0xcf>
    p->s.size += bp->s.size;
 d61:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d64:	8b 50 04             	mov    0x4(%eax),%edx
 d67:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d6a:	8b 40 04             	mov    0x4(%eax),%eax
 d6d:	01 c2                	add    %eax,%edx
 d6f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d72:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 d75:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d78:	8b 10                	mov    (%eax),%edx
 d7a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d7d:	89 10                	mov    %edx,(%eax)
 d7f:	eb 08                	jmp    d89 <free+0xd7>
  } else
    p->s.ptr = bp;
 d81:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d84:	8b 55 f8             	mov    -0x8(%ebp),%edx
 d87:	89 10                	mov    %edx,(%eax)
  freep = p;
 d89:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d8c:	a3 68 12 00 00       	mov    %eax,0x1268
}
 d91:	90                   	nop
 d92:	c9                   	leave  
 d93:	c3                   	ret    

00000d94 <morecore>:

static Header*
morecore(uint nu)
{
 d94:	55                   	push   %ebp
 d95:	89 e5                	mov    %esp,%ebp
 d97:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 d9a:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 da1:	77 07                	ja     daa <morecore+0x16>
    nu = 4096;
 da3:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 daa:	8b 45 08             	mov    0x8(%ebp),%eax
 dad:	c1 e0 03             	shl    $0x3,%eax
 db0:	83 ec 0c             	sub    $0xc,%esp
 db3:	50                   	push   %eax
 db4:	e8 31 fc ff ff       	call   9ea <sbrk>
 db9:	83 c4 10             	add    $0x10,%esp
 dbc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 dbf:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 dc3:	75 07                	jne    dcc <morecore+0x38>
    return 0;
 dc5:	b8 00 00 00 00       	mov    $0x0,%eax
 dca:	eb 26                	jmp    df2 <morecore+0x5e>
  hp = (Header*)p;
 dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 dcf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 dd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 dd5:	8b 55 08             	mov    0x8(%ebp),%edx
 dd8:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 ddb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 dde:	83 c0 08             	add    $0x8,%eax
 de1:	83 ec 0c             	sub    $0xc,%esp
 de4:	50                   	push   %eax
 de5:	e8 c8 fe ff ff       	call   cb2 <free>
 dea:	83 c4 10             	add    $0x10,%esp
  return freep;
 ded:	a1 68 12 00 00       	mov    0x1268,%eax
}
 df2:	c9                   	leave  
 df3:	c3                   	ret    

00000df4 <malloc>:

void*
malloc(uint nbytes)
{
 df4:	55                   	push   %ebp
 df5:	89 e5                	mov    %esp,%ebp
 df7:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 dfa:	8b 45 08             	mov    0x8(%ebp),%eax
 dfd:	83 c0 07             	add    $0x7,%eax
 e00:	c1 e8 03             	shr    $0x3,%eax
 e03:	83 c0 01             	add    $0x1,%eax
 e06:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 e09:	a1 68 12 00 00       	mov    0x1268,%eax
 e0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
 e11:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 e15:	75 23                	jne    e3a <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 e17:	c7 45 f0 60 12 00 00 	movl   $0x1260,-0x10(%ebp)
 e1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 e21:	a3 68 12 00 00       	mov    %eax,0x1268
 e26:	a1 68 12 00 00       	mov    0x1268,%eax
 e2b:	a3 60 12 00 00       	mov    %eax,0x1260
    base.s.size = 0;
 e30:	c7 05 64 12 00 00 00 	movl   $0x0,0x1264
 e37:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 e3d:	8b 00                	mov    (%eax),%eax
 e3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e45:	8b 40 04             	mov    0x4(%eax),%eax
 e48:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 e4b:	72 4d                	jb     e9a <malloc+0xa6>
      if(p->s.size == nunits)
 e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e50:	8b 40 04             	mov    0x4(%eax),%eax
 e53:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 e56:	75 0c                	jne    e64 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 e58:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e5b:	8b 10                	mov    (%eax),%edx
 e5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 e60:	89 10                	mov    %edx,(%eax)
 e62:	eb 26                	jmp    e8a <malloc+0x96>
      else {
        p->s.size -= nunits;
 e64:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e67:	8b 40 04             	mov    0x4(%eax),%eax
 e6a:	2b 45 ec             	sub    -0x14(%ebp),%eax
 e6d:	89 c2                	mov    %eax,%edx
 e6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e72:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 e75:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e78:	8b 40 04             	mov    0x4(%eax),%eax
 e7b:	c1 e0 03             	shl    $0x3,%eax
 e7e:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 e81:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e84:	8b 55 ec             	mov    -0x14(%ebp),%edx
 e87:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 e8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 e8d:	a3 68 12 00 00       	mov    %eax,0x1268
      return (void*)(p + 1);
 e92:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e95:	83 c0 08             	add    $0x8,%eax
 e98:	eb 3b                	jmp    ed5 <malloc+0xe1>
    }
    if(p == freep)
 e9a:	a1 68 12 00 00       	mov    0x1268,%eax
 e9f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 ea2:	75 1e                	jne    ec2 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 ea4:	83 ec 0c             	sub    $0xc,%esp
 ea7:	ff 75 ec             	pushl  -0x14(%ebp)
 eaa:	e8 e5 fe ff ff       	call   d94 <morecore>
 eaf:	83 c4 10             	add    $0x10,%esp
 eb2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 eb5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 eb9:	75 07                	jne    ec2 <malloc+0xce>
        return 0;
 ebb:	b8 00 00 00 00       	mov    $0x0,%eax
 ec0:	eb 13                	jmp    ed5 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ec5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ec8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ecb:	8b 00                	mov    (%eax),%eax
 ecd:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 ed0:	e9 6d ff ff ff       	jmp    e42 <malloc+0x4e>
}
 ed5:	c9                   	leave  
 ed6:	c3                   	ret    

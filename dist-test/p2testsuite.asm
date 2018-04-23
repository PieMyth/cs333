
_p2testsuite:     file format elf32-i386


Disassembly of section .text:

00000000 <testppid>:
#include "uproc.h"
#endif

#ifdef UIDGIDPPID_TEST
static void
testppid(void){
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	83 ec 18             	sub    $0x18,%esp
  int ret, pid, ppid;

  printf(1, "\n----------\nRunning PPID Test\n----------\n");
       6:	83 ec 08             	sub    $0x8,%esp
       9:	68 0c 16 00 00       	push   $0x160c
       e:	6a 01                	push   $0x1
      10:	e8 3e 12 00 00       	call   1253 <printf>
      15:	83 c4 10             	add    $0x10,%esp
  pid = getpid();
      18:	e8 ff 10 00 00       	call   111c <getpid>
      1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ret = fork();
      20:	e8 6f 10 00 00       	call   1094 <fork>
      25:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(ret == 0){
      28:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
      2c:	75 3e                	jne    6c <testppid+0x6c>
    ppid = getppid();
      2e:	e8 29 11 00 00       	call   115c <getppid>
      33:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(ppid != pid)
      36:	8b 45 ec             	mov    -0x14(%ebp),%eax
      39:	3b 45 f4             	cmp    -0xc(%ebp),%eax
      3c:	74 17                	je     55 <testppid+0x55>
      printf(2, "FAILED: Parent PID is %d, Child's PPID is %d\n", pid, ppid);
      3e:	ff 75 ec             	pushl  -0x14(%ebp)
      41:	ff 75 f4             	pushl  -0xc(%ebp)
      44:	68 38 16 00 00       	push   $0x1638
      49:	6a 02                	push   $0x2
      4b:	e8 03 12 00 00       	call   1253 <printf>
      50:	83 c4 10             	add    $0x10,%esp
      53:	eb 12                	jmp    67 <testppid+0x67>
    else
      printf(1, "** Test passed! **\n");
      55:	83 ec 08             	sub    $0x8,%esp
      58:	68 66 16 00 00       	push   $0x1666
      5d:	6a 01                	push   $0x1
      5f:	e8 ef 11 00 00       	call   1253 <printf>
      64:	83 c4 10             	add    $0x10,%esp
    exit();
      67:	e8 30 10 00 00       	call   109c <exit>
  }
  else
    wait();
      6c:	e8 33 10 00 00       	call   10a4 <wait>
}
      71:	90                   	nop
      72:	c9                   	leave  
      73:	c3                   	ret    

00000074 <testgid>:

static int
testgid(uint new_val, uint expected_get_val, int expected_set_ret){
      74:	55                   	push   %ebp
      75:	89 e5                	mov    %esp,%ebp
      77:	83 ec 18             	sub    $0x18,%esp
  int ret;
  uint post_gid, pre_gid;
  int success = 0;
      7a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  pre_gid = getgid();
      81:	e8 ce 10 00 00       	call   1154 <getgid>
      86:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ret = setgid(new_val);
      89:	83 ec 0c             	sub    $0xc,%esp
      8c:	ff 75 08             	pushl  0x8(%ebp)
      8f:	e8 d8 10 00 00       	call   116c <setgid>
      94:	83 c4 10             	add    $0x10,%esp
      97:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((ret < 0 && expected_set_ret >= 0) || (ret >= 0 && expected_set_ret < 0)){
      9a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
      9e:	79 06                	jns    a6 <testgid+0x32>
      a0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
      a4:	79 0c                	jns    b2 <testgid+0x3e>
      a6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
      aa:	78 28                	js     d4 <testgid+0x60>
      ac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
      b0:	79 22                	jns    d4 <testgid+0x60>
    printf(2, "FAILED: setgid(%d) returned %d, expected %d\n", new_val, ret, expected_set_ret);
      b2:	83 ec 0c             	sub    $0xc,%esp
      b5:	ff 75 10             	pushl  0x10(%ebp)
      b8:	ff 75 ec             	pushl  -0x14(%ebp)
      bb:	ff 75 08             	pushl  0x8(%ebp)
      be:	68 7c 16 00 00       	push   $0x167c
      c3:	6a 02                	push   $0x2
      c5:	e8 89 11 00 00       	call   1253 <printf>
      ca:	83 c4 20             	add    $0x20,%esp
    success = -1;
      cd:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  }
  post_gid = getgid();
      d4:	e8 7b 10 00 00       	call   1154 <getgid>
      d9:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(post_gid != expected_get_val){
      dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
      df:	3b 45 0c             	cmp    0xc(%ebp),%eax
      e2:	74 25                	je     109 <testgid+0x95>
    printf(2, "FAILED: UID was %d. After setgid(%d), getgid() returned %d, expected %d\n",
      e4:	83 ec 08             	sub    $0x8,%esp
      e7:	ff 75 0c             	pushl  0xc(%ebp)
      ea:	ff 75 e8             	pushl  -0x18(%ebp)
      ed:	ff 75 08             	pushl  0x8(%ebp)
      f0:	ff 75 f0             	pushl  -0x10(%ebp)
      f3:	68 ac 16 00 00       	push   $0x16ac
      f8:	6a 02                	push   $0x2
      fa:	e8 54 11 00 00       	call   1253 <printf>
      ff:	83 c4 20             	add    $0x20,%esp
          pre_gid, new_val, post_gid, expected_get_val);
    success = -1;
     102:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  }
  return success;
     109:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     10c:	c9                   	leave  
     10d:	c3                   	ret    

0000010e <testuid>:

static int
testuid(uint new_val, uint expected_get_val, int expected_set_ret){
     10e:	55                   	push   %ebp
     10f:	89 e5                	mov    %esp,%ebp
     111:	83 ec 18             	sub    $0x18,%esp
  int ret;
  uint post_uid, pre_uid;
  int success = 0;
     114:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  pre_uid = getuid();
     11b:	e8 2c 10 00 00       	call   114c <getuid>
     120:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ret = setuid(new_val);
     123:	83 ec 0c             	sub    $0xc,%esp
     126:	ff 75 08             	pushl  0x8(%ebp)
     129:	e8 36 10 00 00       	call   1164 <setuid>
     12e:	83 c4 10             	add    $0x10,%esp
     131:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((ret < 0 && expected_set_ret >= 0) || (ret >= 0 && expected_set_ret < 0)){
     134:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     138:	79 06                	jns    140 <testuid+0x32>
     13a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     13e:	79 0c                	jns    14c <testuid+0x3e>
     140:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     144:	78 28                	js     16e <testuid+0x60>
     146:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     14a:	79 22                	jns    16e <testuid+0x60>
    printf(2, "FAILED: setuid(%d) returned %d, expected %d\n", new_val, ret, expected_set_ret);
     14c:	83 ec 0c             	sub    $0xc,%esp
     14f:	ff 75 10             	pushl  0x10(%ebp)
     152:	ff 75 ec             	pushl  -0x14(%ebp)
     155:	ff 75 08             	pushl  0x8(%ebp)
     158:	68 f8 16 00 00       	push   $0x16f8
     15d:	6a 02                	push   $0x2
     15f:	e8 ef 10 00 00       	call   1253 <printf>
     164:	83 c4 20             	add    $0x20,%esp
    success = -1;
     167:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  }
  post_uid = getuid();
     16e:	e8 d9 0f 00 00       	call   114c <getuid>
     173:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(post_uid != expected_get_val){
     176:	8b 45 e8             	mov    -0x18(%ebp),%eax
     179:	3b 45 0c             	cmp    0xc(%ebp),%eax
     17c:	74 25                	je     1a3 <testuid+0x95>
    printf(2, "FAILED: UID was %d. After setuid(%d), getuid() returned %d, expected %d\n",
     17e:	83 ec 08             	sub    $0x8,%esp
     181:	ff 75 0c             	pushl  0xc(%ebp)
     184:	ff 75 e8             	pushl  -0x18(%ebp)
     187:	ff 75 08             	pushl  0x8(%ebp)
     18a:	ff 75 f0             	pushl  -0x10(%ebp)
     18d:	68 28 17 00 00       	push   $0x1728
     192:	6a 02                	push   $0x2
     194:	e8 ba 10 00 00       	call   1253 <printf>
     199:	83 c4 20             	add    $0x20,%esp
          pre_uid, new_val, post_uid, expected_get_val);
    success = -1;
     19c:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  }
  return success;
     1a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     1a6:	c9                   	leave  
     1a7:	c3                   	ret    

000001a8 <testuidgid>:

static void
testuidgid(void)
{
     1a8:	55                   	push   %ebp
     1a9:	89 e5                	mov    %esp,%ebp
     1ab:	83 ec 18             	sub    $0x18,%esp
  int uid, gid;
  int success = 0;
     1ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  printf(1, "\n----------\nRunning UID / GID Tests\n----------\n");
     1b5:	83 ec 08             	sub    $0x8,%esp
     1b8:	68 74 17 00 00       	push   $0x1774
     1bd:	6a 01                	push   $0x1
     1bf:	e8 8f 10 00 00       	call   1253 <printf>
     1c4:	83 c4 10             	add    $0x10,%esp
  uid = getuid();
     1c7:	e8 80 0f 00 00       	call   114c <getuid>
     1cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(uid < 0 || uid > 32767){
     1cf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     1d3:	78 09                	js     1de <testuidgid+0x36>
     1d5:	81 7d f0 ff 7f 00 00 	cmpl   $0x7fff,-0x10(%ebp)
     1dc:	7e 1c                	jle    1fa <testuidgid+0x52>
    printf(1, "FAILED: Default UID %d, out of range\n", uid);
     1de:	83 ec 04             	sub    $0x4,%esp
     1e1:	ff 75 f0             	pushl  -0x10(%ebp)
     1e4:	68 a4 17 00 00       	push   $0x17a4
     1e9:	6a 01                	push   $0x1
     1eb:	e8 63 10 00 00       	call   1253 <printf>
     1f0:	83 c4 10             	add    $0x10,%esp
    success = -1;
     1f3:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  }
  if (testuid(0, 0, 0))
     1fa:	83 ec 04             	sub    $0x4,%esp
     1fd:	6a 00                	push   $0x0
     1ff:	6a 00                	push   $0x0
     201:	6a 00                	push   $0x0
     203:	e8 06 ff ff ff       	call   10e <testuid>
     208:	83 c4 10             	add    $0x10,%esp
     20b:	85 c0                	test   %eax,%eax
     20d:	74 07                	je     216 <testuidgid+0x6e>
    success = -1;
     20f:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if (testuid(5, 5, 0))
     216:	83 ec 04             	sub    $0x4,%esp
     219:	6a 00                	push   $0x0
     21b:	6a 05                	push   $0x5
     21d:	6a 05                	push   $0x5
     21f:	e8 ea fe ff ff       	call   10e <testuid>
     224:	83 c4 10             	add    $0x10,%esp
     227:	85 c0                	test   %eax,%eax
     229:	74 07                	je     232 <testuidgid+0x8a>
    success = -1;
     22b:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if (testuid(32767, 32767, 0))
     232:	83 ec 04             	sub    $0x4,%esp
     235:	6a 00                	push   $0x0
     237:	68 ff 7f 00 00       	push   $0x7fff
     23c:	68 ff 7f 00 00       	push   $0x7fff
     241:	e8 c8 fe ff ff       	call   10e <testuid>
     246:	83 c4 10             	add    $0x10,%esp
     249:	85 c0                	test   %eax,%eax
     24b:	74 07                	je     254 <testuidgid+0xac>
    success = -1;
     24d:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if (testuid(32768, 32767, -1))
     254:	83 ec 04             	sub    $0x4,%esp
     257:	6a ff                	push   $0xffffffff
     259:	68 ff 7f 00 00       	push   $0x7fff
     25e:	68 00 80 00 00       	push   $0x8000
     263:	e8 a6 fe ff ff       	call   10e <testuid>
     268:	83 c4 10             	add    $0x10,%esp
     26b:	85 c0                	test   %eax,%eax
     26d:	74 07                	je     276 <testuidgid+0xce>
    success = -1;
     26f:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if (testuid(-1, 32767, -1))
     276:	83 ec 04             	sub    $0x4,%esp
     279:	6a ff                	push   $0xffffffff
     27b:	68 ff 7f 00 00       	push   $0x7fff
     280:	6a ff                	push   $0xffffffff
     282:	e8 87 fe ff ff       	call   10e <testuid>
     287:	83 c4 10             	add    $0x10,%esp
     28a:	85 c0                	test   %eax,%eax
     28c:	74 07                	je     295 <testuidgid+0xed>
    success = -1;
     28e:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)

  gid = getgid();
     295:	e8 ba 0e 00 00       	call   1154 <getgid>
     29a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(gid < 0 || gid > 32767){
     29d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     2a1:	78 09                	js     2ac <testuidgid+0x104>
     2a3:	81 7d ec ff 7f 00 00 	cmpl   $0x7fff,-0x14(%ebp)
     2aa:	7e 1c                	jle    2c8 <testuidgid+0x120>
    printf(1, "FAILED: Default GID %d, out of range\n", gid);
     2ac:	83 ec 04             	sub    $0x4,%esp
     2af:	ff 75 ec             	pushl  -0x14(%ebp)
     2b2:	68 cc 17 00 00       	push   $0x17cc
     2b7:	6a 01                	push   $0x1
     2b9:	e8 95 0f 00 00       	call   1253 <printf>
     2be:	83 c4 10             	add    $0x10,%esp
    success = -1;
     2c1:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  }
  if (testgid(0, 0, 0))
     2c8:	83 ec 04             	sub    $0x4,%esp
     2cb:	6a 00                	push   $0x0
     2cd:	6a 00                	push   $0x0
     2cf:	6a 00                	push   $0x0
     2d1:	e8 9e fd ff ff       	call   74 <testgid>
     2d6:	83 c4 10             	add    $0x10,%esp
     2d9:	85 c0                	test   %eax,%eax
     2db:	74 07                	je     2e4 <testuidgid+0x13c>
    success = -1;
     2dd:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if (testgid(5, 5, 0))
     2e4:	83 ec 04             	sub    $0x4,%esp
     2e7:	6a 00                	push   $0x0
     2e9:	6a 05                	push   $0x5
     2eb:	6a 05                	push   $0x5
     2ed:	e8 82 fd ff ff       	call   74 <testgid>
     2f2:	83 c4 10             	add    $0x10,%esp
     2f5:	85 c0                	test   %eax,%eax
     2f7:	74 07                	je     300 <testuidgid+0x158>
    success = -1;
     2f9:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if (testgid(32767, 32767, 0))
     300:	83 ec 04             	sub    $0x4,%esp
     303:	6a 00                	push   $0x0
     305:	68 ff 7f 00 00       	push   $0x7fff
     30a:	68 ff 7f 00 00       	push   $0x7fff
     30f:	e8 60 fd ff ff       	call   74 <testgid>
     314:	83 c4 10             	add    $0x10,%esp
     317:	85 c0                	test   %eax,%eax
     319:	74 07                	je     322 <testuidgid+0x17a>
    success = -1;
     31b:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if (testgid(-1, 32767, -1))
     322:	83 ec 04             	sub    $0x4,%esp
     325:	6a ff                	push   $0xffffffff
     327:	68 ff 7f 00 00       	push   $0x7fff
     32c:	6a ff                	push   $0xffffffff
     32e:	e8 41 fd ff ff       	call   74 <testgid>
     333:	83 c4 10             	add    $0x10,%esp
     336:	85 c0                	test   %eax,%eax
     338:	74 07                	je     341 <testuidgid+0x199>
    success = -1;
     33a:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if (testgid(32768, 32767, -1))
     341:	83 ec 04             	sub    $0x4,%esp
     344:	6a ff                	push   $0xffffffff
     346:	68 ff 7f 00 00       	push   $0x7fff
     34b:	68 00 80 00 00       	push   $0x8000
     350:	e8 1f fd ff ff       	call   74 <testgid>
     355:	83 c4 10             	add    $0x10,%esp
     358:	85 c0                	test   %eax,%eax
     35a:	74 07                	je     363 <testuidgid+0x1bb>
    success = -1;
     35c:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)

  if (success == 0)
     363:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     367:	75 12                	jne    37b <testuidgid+0x1d3>
    printf(1, "** All tests passed! **\n");
     369:	83 ec 08             	sub    $0x8,%esp
     36c:	68 f2 17 00 00       	push   $0x17f2
     371:	6a 01                	push   $0x1
     373:	e8 db 0e 00 00       	call   1253 <printf>
     378:	83 c4 10             	add    $0x10,%esp
}
     37b:	90                   	nop
     37c:	c9                   	leave  
     37d:	c3                   	ret    

0000037e <testuidgidinheritance>:

static void
testuidgidinheritance(void){
     37e:	55                   	push   %ebp
     37f:	89 e5                	mov    %esp,%ebp
     381:	83 ec 18             	sub    $0x18,%esp
  int ret, success, uid, gid;
  success = 0;
     384:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  printf(1, "\n----------\nRunning UID / GID Inheritance Test\n----------\n");
     38b:	83 ec 08             	sub    $0x8,%esp
     38e:	68 0c 18 00 00       	push   $0x180c
     393:	6a 01                	push   $0x1
     395:	e8 b9 0e 00 00       	call   1253 <printf>
     39a:	83 c4 10             	add    $0x10,%esp
  if (testuid(12345, 12345, 0))
     39d:	83 ec 04             	sub    $0x4,%esp
     3a0:	6a 00                	push   $0x0
     3a2:	68 39 30 00 00       	push   $0x3039
     3a7:	68 39 30 00 00       	push   $0x3039
     3ac:	e8 5d fd ff ff       	call   10e <testuid>
     3b1:	83 c4 10             	add    $0x10,%esp
     3b4:	85 c0                	test   %eax,%eax
     3b6:	74 07                	je     3bf <testuidgidinheritance+0x41>
    success = -1;
     3b8:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if (testgid(12345, 12345, 0))
     3bf:	83 ec 04             	sub    $0x4,%esp
     3c2:	6a 00                	push   $0x0
     3c4:	68 39 30 00 00       	push   $0x3039
     3c9:	68 39 30 00 00       	push   $0x3039
     3ce:	e8 a1 fc ff ff       	call   74 <testgid>
     3d3:	83 c4 10             	add    $0x10,%esp
     3d6:	85 c0                	test   %eax,%eax
     3d8:	74 07                	je     3e1 <testuidgidinheritance+0x63>
    success = -1;
     3da:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if(success != 0)
     3e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     3e5:	75 7c                	jne    463 <testuidgidinheritance+0xe5>
    return;

  ret = fork();
     3e7:	e8 a8 0c 00 00       	call   1094 <fork>
     3ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(ret == 0){
     3ef:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     3f3:	75 67                	jne    45c <testuidgidinheritance+0xde>
    uid = getuid();
     3f5:	e8 52 0d 00 00       	call   114c <getuid>
     3fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
    gid = getgid();
     3fd:	e8 52 0d 00 00       	call   1154 <getgid>
     402:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(uid != 12345){
     405:	81 7d ec 39 30 00 00 	cmpl   $0x3039,-0x14(%ebp)
     40c:	74 17                	je     425 <testuidgidinheritance+0xa7>
      printf(2, "FAILED: Parent UID is 12345, child UID is %d\n", uid);
     40e:	83 ec 04             	sub    $0x4,%esp
     411:	ff 75 ec             	pushl  -0x14(%ebp)
     414:	68 48 18 00 00       	push   $0x1848
     419:	6a 02                	push   $0x2
     41b:	e8 33 0e 00 00       	call   1253 <printf>
     420:	83 c4 10             	add    $0x10,%esp
     423:	eb 32                	jmp    457 <testuidgidinheritance+0xd9>
    }
    else if(gid != 12345){
     425:	81 7d e8 39 30 00 00 	cmpl   $0x3039,-0x18(%ebp)
     42c:	74 17                	je     445 <testuidgidinheritance+0xc7>
      printf(2, "FAILED: Parent GID is 12345, child GID is %d\n", gid);
     42e:	83 ec 04             	sub    $0x4,%esp
     431:	ff 75 e8             	pushl  -0x18(%ebp)
     434:	68 78 18 00 00       	push   $0x1878
     439:	6a 02                	push   $0x2
     43b:	e8 13 0e 00 00       	call   1253 <printf>
     440:	83 c4 10             	add    $0x10,%esp
     443:	eb 12                	jmp    457 <testuidgidinheritance+0xd9>
    }
    else
      printf(1, "** Test Passed! **\n");
     445:	83 ec 08             	sub    $0x8,%esp
     448:	68 a6 18 00 00       	push   $0x18a6
     44d:	6a 01                	push   $0x1
     44f:	e8 ff 0d 00 00       	call   1253 <printf>
     454:	83 c4 10             	add    $0x10,%esp
    exit();
     457:	e8 40 0c 00 00       	call   109c <exit>
  }
  else {
    wait();
     45c:	e8 43 0c 00 00       	call   10a4 <wait>
     461:	eb 01                	jmp    464 <testuidgidinheritance+0xe6>
  if (testuid(12345, 12345, 0))
    success = -1;
  if (testgid(12345, 12345, 0))
    success = -1;
  if(success != 0)
    return;
     463:	90                   	nop
    exit();
  }
  else {
    wait();
  }
}
     464:	c9                   	leave  
     465:	c3                   	ret    

00000466 <getcputime>:
#ifdef GETPROCS_TEST
#ifdef CPUTIME_TEST
// Simple test to have the program sleep for 200 milliseconds to see if CPU_time properly doesn't change
// And then gets CPU_time again to see if elapsed CPU_total_ticks is reasonable
static int
getcputime(char * name, struct uproc * table){
     466:	55                   	push   %ebp
     467:	89 e5                	mov    %esp,%ebp
     469:	83 ec 18             	sub    $0x18,%esp
  struct uproc *p = 0;
     46c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  int size;

  size = getprocs(64, table);
     473:	83 ec 08             	sub    $0x8,%esp
     476:	ff 75 0c             	pushl  0xc(%ebp)
     479:	6a 40                	push   $0x40
     47b:	e8 f4 0c 00 00       	call   1174 <getprocs>
     480:	83 c4 10             	add    $0x10,%esp
     483:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(int i = 0; i < size; ++i){
     486:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     48d:	eb 35                	jmp    4c4 <getcputime+0x5e>
    if(strcmp(table[i].name, name) == 0){
     48f:	8b 45 f0             	mov    -0x10(%ebp),%eax
     492:	6b d0 5c             	imul   $0x5c,%eax,%edx
     495:	8b 45 0c             	mov    0xc(%ebp),%eax
     498:	01 d0                	add    %edx,%eax
     49a:	83 c0 3c             	add    $0x3c,%eax
     49d:	83 ec 08             	sub    $0x8,%esp
     4a0:	ff 75 08             	pushl  0x8(%ebp)
     4a3:	50                   	push   %eax
     4a4:	e8 1f 09 00 00       	call   dc8 <strcmp>
     4a9:	83 c4 10             	add    $0x10,%esp
     4ac:	85 c0                	test   %eax,%eax
     4ae:	75 10                	jne    4c0 <getcputime+0x5a>
      p = table + i;
     4b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
     4b3:	6b d0 5c             	imul   $0x5c,%eax,%edx
     4b6:	8b 45 0c             	mov    0xc(%ebp),%eax
     4b9:	01 d0                	add    %edx,%eax
     4bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
      break;
     4be:	eb 0c                	jmp    4cc <getcputime+0x66>
getcputime(char * name, struct uproc * table){
  struct uproc *p = 0;
  int size;

  size = getprocs(64, table);
  for(int i = 0; i < size; ++i){
     4c0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
     4c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
     4c7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
     4ca:	7c c3                	jl     48f <getcputime+0x29>
    if(strcmp(table[i].name, name) == 0){
      p = table + i;
      break;
    }
  }
  if(p == 0){
     4cc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     4d0:	75 1c                	jne    4ee <getcputime+0x88>
    printf(2, "FAILED: Test program \"%s\" not found in table returned by getprocs\n", name);
     4d2:	83 ec 04             	sub    $0x4,%esp
     4d5:	ff 75 08             	pushl  0x8(%ebp)
     4d8:	68 bc 18 00 00       	push   $0x18bc
     4dd:	6a 02                	push   $0x2
     4df:	e8 6f 0d 00 00       	call   1253 <printf>
     4e4:	83 c4 10             	add    $0x10,%esp
    return -1;
     4e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     4ec:	eb 06                	jmp    4f4 <getcputime+0x8e>
  }
  else
    return p->CPU_total_ticks;
     4ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4f1:	8b 40 14             	mov    0x14(%eax),%eax
}
     4f4:	c9                   	leave  
     4f5:	c3                   	ret    

000004f6 <testcputime>:

static void
testcputime(char * name){
     4f6:	55                   	push   %ebp
     4f7:	89 e5                	mov    %esp,%ebp
     4f9:	83 ec 28             	sub    $0x28,%esp
  struct uproc *table;
  uint time1, time2, pre_sleep, post_sleep;
  int success = 0;
     4fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  int i, num;

  printf(1, "\n----------\nRunning CPU Time Test\n----------\n");
     503:	83 ec 08             	sub    $0x8,%esp
     506:	68 00 19 00 00       	push   $0x1900
     50b:	6a 01                	push   $0x1
     50d:	e8 41 0d 00 00       	call   1253 <printf>
     512:	83 c4 10             	add    $0x10,%esp
  table = malloc(sizeof(struct uproc) * 64);
     515:	83 ec 0c             	sub    $0xc,%esp
     518:	68 00 17 00 00       	push   $0x1700
     51d:	e8 04 10 00 00       	call   1526 <malloc>
     522:	83 c4 10             	add    $0x10,%esp
     525:	89 45 e8             	mov    %eax,-0x18(%ebp)
  printf(1, "This will take a couple seconds\n");
     528:	83 ec 08             	sub    $0x8,%esp
     52b:	68 30 19 00 00       	push   $0x1930
     530:	6a 01                	push   $0x1
     532:	e8 1c 0d 00 00       	call   1253 <printf>
     537:	83 c4 10             	add    $0x10,%esp

  // Loop for a long time to see if the elapsed CPU_total_ticks is in a reasonable range
  time1 = getcputime(name, table);
     53a:	83 ec 08             	sub    $0x8,%esp
     53d:	ff 75 e8             	pushl  -0x18(%ebp)
     540:	ff 75 08             	pushl  0x8(%ebp)
     543:	e8 1e ff ff ff       	call   466 <getcputime>
     548:	83 c4 10             	add    $0x10,%esp
     54b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  for(i = 0, num = 0; i < 1000000; ++i){
     54e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     555:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
     55c:	e9 8a 00 00 00       	jmp    5eb <testcputime+0xf5>
    ++num;
     561:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
    if(num % 100000 == 0){
     565:	8b 4d ec             	mov    -0x14(%ebp),%ecx
     568:	ba 89 b5 f8 14       	mov    $0x14f8b589,%edx
     56d:	89 c8                	mov    %ecx,%eax
     56f:	f7 ea                	imul   %edx
     571:	c1 fa 0d             	sar    $0xd,%edx
     574:	89 c8                	mov    %ecx,%eax
     576:	c1 f8 1f             	sar    $0x1f,%eax
     579:	29 c2                	sub    %eax,%edx
     57b:	89 d0                	mov    %edx,%eax
     57d:	69 c0 a0 86 01 00    	imul   $0x186a0,%eax,%eax
     583:	29 c1                	sub    %eax,%ecx
     585:	89 c8                	mov    %ecx,%eax
     587:	85 c0                	test   %eax,%eax
     589:	75 5c                	jne    5e7 <testcputime+0xf1>
      pre_sleep = getcputime(name, table);
     58b:	83 ec 08             	sub    $0x8,%esp
     58e:	ff 75 e8             	pushl  -0x18(%ebp)
     591:	ff 75 08             	pushl  0x8(%ebp)
     594:	e8 cd fe ff ff       	call   466 <getcputime>
     599:	83 c4 10             	add    $0x10,%esp
     59c:	89 45 e0             	mov    %eax,-0x20(%ebp)
      sleep(200);
     59f:	83 ec 0c             	sub    $0xc,%esp
     5a2:	68 c8 00 00 00       	push   $0xc8
     5a7:	e8 80 0b 00 00       	call   112c <sleep>
     5ac:	83 c4 10             	add    $0x10,%esp
      post_sleep = getcputime(name, table);
     5af:	83 ec 08             	sub    $0x8,%esp
     5b2:	ff 75 e8             	pushl  -0x18(%ebp)
     5b5:	ff 75 08             	pushl  0x8(%ebp)
     5b8:	e8 a9 fe ff ff       	call   466 <getcputime>
     5bd:	83 c4 10             	add    $0x10,%esp
     5c0:	89 45 dc             	mov    %eax,-0x24(%ebp)
      if((post_sleep - pre_sleep) >= 100){
     5c3:	8b 45 dc             	mov    -0x24(%ebp),%eax
     5c6:	2b 45 e0             	sub    -0x20(%ebp),%eax
     5c9:	83 f8 63             	cmp    $0x63,%eax
     5cc:	76 19                	jbe    5e7 <testcputime+0xf1>
        printf(2, "FAILED: CPU_total_ticks changed by 100+ milliseconds while process was asleep\n");
     5ce:	83 ec 08             	sub    $0x8,%esp
     5d1:	68 54 19 00 00       	push   $0x1954
     5d6:	6a 02                	push   $0x2
     5d8:	e8 76 0c 00 00       	call   1253 <printf>
     5dd:	83 c4 10             	add    $0x10,%esp
        success = -1;
     5e0:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  table = malloc(sizeof(struct uproc) * 64);
  printf(1, "This will take a couple seconds\n");

  // Loop for a long time to see if the elapsed CPU_total_ticks is in a reasonable range
  time1 = getcputime(name, table);
  for(i = 0, num = 0; i < 1000000; ++i){
     5e7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
     5eb:	81 7d f0 3f 42 0f 00 	cmpl   $0xf423f,-0x10(%ebp)
     5f2:	0f 8e 69 ff ff ff    	jle    561 <testcputime+0x6b>
        printf(2, "FAILED: CPU_total_ticks changed by 100+ milliseconds while process was asleep\n");
        success = -1;
      }
    }
  }
  time2 = getcputime(name, table);
     5f8:	83 ec 08             	sub    $0x8,%esp
     5fb:	ff 75 e8             	pushl  -0x18(%ebp)
     5fe:	ff 75 08             	pushl  0x8(%ebp)
     601:	e8 60 fe ff ff       	call   466 <getcputime>
     606:	83 c4 10             	add    $0x10,%esp
     609:	89 45 d8             	mov    %eax,-0x28(%ebp)
  if((time2 - time1) < 0){
    printf(2, "FAILED: difference in CPU_total_ticks is negative.  T2 - T1 = %d\n", (time2 - time1));
    success = -1;
  }
  if((time2 - time1) > 400){
     60c:	8b 45 d8             	mov    -0x28(%ebp),%eax
     60f:	2b 45 e4             	sub    -0x1c(%ebp),%eax
     612:	3d 90 01 00 00       	cmp    $0x190,%eax
     617:	76 20                	jbe    639 <testcputime+0x143>
    printf(2, "ABNORMALLY HIGH: T2 - T1 = %d milliseconds.  Run test again\n", (time2 - time1));
     619:	8b 45 d8             	mov    -0x28(%ebp),%eax
     61c:	2b 45 e4             	sub    -0x1c(%ebp),%eax
     61f:	83 ec 04             	sub    $0x4,%esp
     622:	50                   	push   %eax
     623:	68 a4 19 00 00       	push   $0x19a4
     628:	6a 02                	push   $0x2
     62a:	e8 24 0c 00 00       	call   1253 <printf>
     62f:	83 c4 10             	add    $0x10,%esp
    success = -1;
     632:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  }
  printf(1, "T2 - T1 = %d milliseconds\n", (time2 - time1));
     639:	8b 45 d8             	mov    -0x28(%ebp),%eax
     63c:	2b 45 e4             	sub    -0x1c(%ebp),%eax
     63f:	83 ec 04             	sub    $0x4,%esp
     642:	50                   	push   %eax
     643:	68 e1 19 00 00       	push   $0x19e1
     648:	6a 01                	push   $0x1
     64a:	e8 04 0c 00 00       	call   1253 <printf>
     64f:	83 c4 10             	add    $0x10,%esp
  free(table);
     652:	83 ec 0c             	sub    $0xc,%esp
     655:	ff 75 e8             	pushl  -0x18(%ebp)
     658:	e8 87 0d 00 00       	call   13e4 <free>
     65d:	83 c4 10             	add    $0x10,%esp

  if(success == 0)
     660:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     664:	75 12                	jne    678 <testcputime+0x182>
    printf(1, "** All Tests Passed! **\n");
     666:	83 ec 08             	sub    $0x8,%esp
     669:	68 fc 19 00 00       	push   $0x19fc
     66e:	6a 01                	push   $0x1
     670:	e8 de 0b 00 00       	call   1253 <printf>
     675:	83 c4 10             	add    $0x10,%esp
}
     678:	90                   	nop
     679:	c9                   	leave  
     67a:	c3                   	ret    

0000067b <testprocarray>:

#ifdef GETPROCS_TEST
// Fork to 64 process and then make sure we get all when passing table array
// of sizes 1, 16, 64, 72
static int
testprocarray(int max, int expected_ret, char * name){
     67b:	55                   	push   %ebp
     67c:	89 e5                	mov    %esp,%ebp
     67e:	83 ec 28             	sub    $0x28,%esp
  struct uproc * table;
  int ret, success, num_init, num_sh, num_this;
  success = num_init = num_sh = num_this = 0;
     681:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
     688:	8b 45 e8             	mov    -0x18(%ebp),%eax
     68b:	89 45 ec             	mov    %eax,-0x14(%ebp)
     68e:	8b 45 ec             	mov    -0x14(%ebp),%eax
     691:	89 45 f0             	mov    %eax,-0x10(%ebp)
     694:	8b 45 f0             	mov    -0x10(%ebp),%eax
     697:	89 45 f4             	mov    %eax,-0xc(%ebp)

  table = malloc(sizeof(struct uproc) * max);
     69a:	8b 45 08             	mov    0x8(%ebp),%eax
     69d:	6b c0 5c             	imul   $0x5c,%eax,%eax
     6a0:	83 ec 0c             	sub    $0xc,%esp
     6a3:	50                   	push   %eax
     6a4:	e8 7d 0e 00 00       	call   1526 <malloc>
     6a9:	83 c4 10             	add    $0x10,%esp
     6ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  ret = getprocs(max, table);
     6af:	8b 45 08             	mov    0x8(%ebp),%eax
     6b2:	83 ec 08             	sub    $0x8,%esp
     6b5:	ff 75 e0             	pushl  -0x20(%ebp)
     6b8:	50                   	push   %eax
     6b9:	e8 b6 0a 00 00       	call   1174 <getprocs>
     6be:	83 c4 10             	add    $0x10,%esp
     6c1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  for (int i = 0; i < ret; ++i){
     6c4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     6cb:	eb 7b                	jmp    748 <testprocarray+0xcd>
    if(strcmp(table[i].name, "init") == 0)
     6cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     6d0:	6b d0 5c             	imul   $0x5c,%eax,%edx
     6d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
     6d6:	01 d0                	add    %edx,%eax
     6d8:	83 c0 3c             	add    $0x3c,%eax
     6db:	83 ec 08             	sub    $0x8,%esp
     6de:	68 15 1a 00 00       	push   $0x1a15
     6e3:	50                   	push   %eax
     6e4:	e8 df 06 00 00       	call   dc8 <strcmp>
     6e9:	83 c4 10             	add    $0x10,%esp
     6ec:	85 c0                	test   %eax,%eax
     6ee:	75 06                	jne    6f6 <testprocarray+0x7b>
      ++num_init;
     6f0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
     6f4:	eb 4e                	jmp    744 <testprocarray+0xc9>
    else if(strcmp(table[i].name, "sh") == 0)
     6f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     6f9:	6b d0 5c             	imul   $0x5c,%eax,%edx
     6fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
     6ff:	01 d0                	add    %edx,%eax
     701:	83 c0 3c             	add    $0x3c,%eax
     704:	83 ec 08             	sub    $0x8,%esp
     707:	68 1a 1a 00 00       	push   $0x1a1a
     70c:	50                   	push   %eax
     70d:	e8 b6 06 00 00       	call   dc8 <strcmp>
     712:	83 c4 10             	add    $0x10,%esp
     715:	85 c0                	test   %eax,%eax
     717:	75 06                	jne    71f <testprocarray+0xa4>
      ++num_sh;
     719:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
     71d:	eb 25                	jmp    744 <testprocarray+0xc9>
    else if(strcmp(table[i].name, name) == 0)
     71f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     722:	6b d0 5c             	imul   $0x5c,%eax,%edx
     725:	8b 45 e0             	mov    -0x20(%ebp),%eax
     728:	01 d0                	add    %edx,%eax
     72a:	83 c0 3c             	add    $0x3c,%eax
     72d:	83 ec 08             	sub    $0x8,%esp
     730:	ff 75 10             	pushl  0x10(%ebp)
     733:	50                   	push   %eax
     734:	e8 8f 06 00 00       	call   dc8 <strcmp>
     739:	83 c4 10             	add    $0x10,%esp
     73c:	85 c0                	test   %eax,%eax
     73e:	75 04                	jne    744 <testprocarray+0xc9>
      ++num_this;
     740:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
  int ret, success, num_init, num_sh, num_this;
  success = num_init = num_sh = num_this = 0;

  table = malloc(sizeof(struct uproc) * max);
  ret = getprocs(max, table);
  for (int i = 0; i < ret; ++i){
     744:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
     748:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     74b:	3b 45 dc             	cmp    -0x24(%ebp),%eax
     74e:	0f 8c 79 ff ff ff    	jl     6cd <testprocarray+0x52>
    else if(strcmp(table[i].name, "sh") == 0)
      ++num_sh;
    else if(strcmp(table[i].name, name) == 0)
      ++num_this;
  }
  if (ret != expected_ret){
     754:	8b 45 dc             	mov    -0x24(%ebp),%eax
     757:	3b 45 0c             	cmp    0xc(%ebp),%eax
     75a:	74 24                	je     780 <testprocarray+0x105>
    printf(2, "FAILED: getprocs(%d) returned %d, expected %d\n", max, ret, expected_ret);
     75c:	83 ec 0c             	sub    $0xc,%esp
     75f:	ff 75 0c             	pushl  0xc(%ebp)
     762:	ff 75 dc             	pushl  -0x24(%ebp)
     765:	ff 75 08             	pushl  0x8(%ebp)
     768:	68 20 1a 00 00       	push   $0x1a20
     76d:	6a 02                	push   $0x2
     76f:	e8 df 0a 00 00       	call   1253 <printf>
     774:	83 c4 20             	add    $0x20,%esp
    success = -1;
     777:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
     77e:	eb 21                	jmp    7a1 <testprocarray+0x126>
  }
  else{
    printf(1, "getprocs(%d), found %d processes with names(qty), \"init\"(%d), \"sh\"(%d), \"%s\"(%d)\n",
     780:	ff 75 e8             	pushl  -0x18(%ebp)
     783:	ff 75 10             	pushl  0x10(%ebp)
     786:	ff 75 ec             	pushl  -0x14(%ebp)
     789:	ff 75 f0             	pushl  -0x10(%ebp)
     78c:	ff 75 dc             	pushl  -0x24(%ebp)
     78f:	ff 75 08             	pushl  0x8(%ebp)
     792:	68 50 1a 00 00       	push   $0x1a50
     797:	6a 01                	push   $0x1
     799:	e8 b5 0a 00 00       	call   1253 <printf>
     79e:	83 c4 20             	add    $0x20,%esp
            max, ret, num_init, num_sh, name, num_this);
  }
  free(table);
     7a1:	83 ec 0c             	sub    $0xc,%esp
     7a4:	ff 75 e0             	pushl  -0x20(%ebp)
     7a7:	e8 38 0c 00 00       	call   13e4 <free>
     7ac:	83 c4 10             	add    $0x10,%esp
  return success;
     7af:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     7b2:	c9                   	leave  
     7b3:	c3                   	ret    

000007b4 <testinvalidarray>:

static int
testinvalidarray(void){
     7b4:	55                   	push   %ebp
     7b5:	89 e5                	mov    %esp,%ebp
     7b7:	83 ec 18             	sub    $0x18,%esp
  struct uproc * table;
  int ret;

  table = malloc(sizeof(struct uproc));
     7ba:	83 ec 0c             	sub    $0xc,%esp
     7bd:	6a 5c                	push   $0x5c
     7bf:	e8 62 0d 00 00       	call   1526 <malloc>
     7c4:	83 c4 10             	add    $0x10,%esp
     7c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ret = getprocs(1024, table);
     7ca:	83 ec 08             	sub    $0x8,%esp
     7cd:	ff 75 f4             	pushl  -0xc(%ebp)
     7d0:	68 00 04 00 00       	push   $0x400
     7d5:	e8 9a 09 00 00       	call   1174 <getprocs>
     7da:	83 c4 10             	add    $0x10,%esp
     7dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  free(table);
     7e0:	83 ec 0c             	sub    $0xc,%esp
     7e3:	ff 75 f4             	pushl  -0xc(%ebp)
     7e6:	e8 f9 0b 00 00       	call   13e4 <free>
     7eb:	83 c4 10             	add    $0x10,%esp
  if(ret >= 0){
     7ee:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     7f2:	78 1c                	js     810 <testinvalidarray+0x5c>
    printf(2, "FAILED: called getprocs with max way larger than table and returned %d, not error\n", ret);
     7f4:	83 ec 04             	sub    $0x4,%esp
     7f7:	ff 75 f0             	pushl  -0x10(%ebp)
     7fa:	68 a4 1a 00 00       	push   $0x1aa4
     7ff:	6a 02                	push   $0x2
     801:	e8 4d 0a 00 00       	call   1253 <printf>
     806:	83 c4 10             	add    $0x10,%esp
    return -1;
     809:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     80e:	eb 05                	jmp    815 <testinvalidarray+0x61>
  }
  return 0;
     810:	b8 00 00 00 00       	mov    $0x0,%eax
}
     815:	c9                   	leave  
     816:	c3                   	ret    

00000817 <testgetprocs>:

static void
testgetprocs(char * name){
     817:	55                   	push   %ebp
     818:	89 e5                	mov    %esp,%ebp
     81a:	83 ec 18             	sub    $0x18,%esp
  int ret, success;

  printf(1, "\n----------\nRunning GetProcs Test\n----------\n");
     81d:	83 ec 08             	sub    $0x8,%esp
     820:	68 f8 1a 00 00       	push   $0x1af8
     825:	6a 01                	push   $0x1
     827:	e8 27 0a 00 00       	call   1253 <printf>
     82c:	83 c4 10             	add    $0x10,%esp
  // Fork until no space left in ptable
  ret = fork();
     82f:	e8 60 08 00 00       	call   1094 <fork>
     834:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if (ret == 0){
     837:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     83b:	0f 85 c6 00 00 00    	jne    907 <testgetprocs+0xf0>
    while((ret = fork()) == 0);
     841:	e8 4e 08 00 00       	call   1094 <fork>
     846:	89 45 f0             	mov    %eax,-0x10(%ebp)
     849:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     84d:	74 f2                	je     841 <testgetprocs+0x2a>
    if(ret > 0){
     84f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     853:	7e 0a                	jle    85f <testgetprocs+0x48>
      wait();
     855:	e8 4a 08 00 00       	call   10a4 <wait>
      exit();
     85a:	e8 3d 08 00 00       	call   109c <exit>
    }
    // Only return left is -1, which is no space left in ptable
    success = 0;
     85f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(testinvalidarray())
     866:	e8 49 ff ff ff       	call   7b4 <testinvalidarray>
     86b:	85 c0                	test   %eax,%eax
     86d:	74 07                	je     876 <testgetprocs+0x5f>
      success = -1;
     86f:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
    if(testprocarray(1, 1, name))
     876:	83 ec 04             	sub    $0x4,%esp
     879:	ff 75 08             	pushl  0x8(%ebp)
     87c:	6a 01                	push   $0x1
     87e:	6a 01                	push   $0x1
     880:	e8 f6 fd ff ff       	call   67b <testprocarray>
     885:	83 c4 10             	add    $0x10,%esp
     888:	85 c0                	test   %eax,%eax
     88a:	74 07                	je     893 <testgetprocs+0x7c>
      success = -1;
     88c:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
    if(testprocarray(16, 16, name))
     893:	83 ec 04             	sub    $0x4,%esp
     896:	ff 75 08             	pushl  0x8(%ebp)
     899:	6a 10                	push   $0x10
     89b:	6a 10                	push   $0x10
     89d:	e8 d9 fd ff ff       	call   67b <testprocarray>
     8a2:	83 c4 10             	add    $0x10,%esp
     8a5:	85 c0                	test   %eax,%eax
     8a7:	74 07                	je     8b0 <testgetprocs+0x99>
      success = -1;
     8a9:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
    if(testprocarray(64, 64, name))
     8b0:	83 ec 04             	sub    $0x4,%esp
     8b3:	ff 75 08             	pushl  0x8(%ebp)
     8b6:	6a 40                	push   $0x40
     8b8:	6a 40                	push   $0x40
     8ba:	e8 bc fd ff ff       	call   67b <testprocarray>
     8bf:	83 c4 10             	add    $0x10,%esp
     8c2:	85 c0                	test   %eax,%eax
     8c4:	74 07                	je     8cd <testgetprocs+0xb6>
      success = -1;
     8c6:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
    if(testprocarray(72, 64, name))
     8cd:	83 ec 04             	sub    $0x4,%esp
     8d0:	ff 75 08             	pushl  0x8(%ebp)
     8d3:	6a 40                	push   $0x40
     8d5:	6a 48                	push   $0x48
     8d7:	e8 9f fd ff ff       	call   67b <testprocarray>
     8dc:	83 c4 10             	add    $0x10,%esp
     8df:	85 c0                	test   %eax,%eax
     8e1:	74 07                	je     8ea <testgetprocs+0xd3>
      success = -1;
     8e3:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
    if (success == 0)
     8ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     8ee:	75 12                	jne    902 <testgetprocs+0xeb>
      printf(1, "** All Tests Passed **\n");
     8f0:	83 ec 08             	sub    $0x8,%esp
     8f3:	68 26 1b 00 00       	push   $0x1b26
     8f8:	6a 01                	push   $0x1
     8fa:	e8 54 09 00 00       	call   1253 <printf>
     8ff:	83 c4 10             	add    $0x10,%esp
    exit();
     902:	e8 95 07 00 00       	call   109c <exit>
  }
  wait();
     907:	e8 98 07 00 00       	call   10a4 <wait>
}
     90c:	90                   	nop
     90d:	c9                   	leave  
     90e:	c3                   	ret    

0000090f <testtimewitharg>:
#endif

#ifdef TIME_TEST
// Forks a process and execs with time + args to see how it handles no args, invalid args, mulitple args
void
testtimewitharg(char **arg){
     90f:	55                   	push   %ebp
     910:	89 e5                	mov    %esp,%ebp
     912:	83 ec 18             	sub    $0x18,%esp
  int ret;

  ret = fork();
     915:	e8 7a 07 00 00       	call   1094 <fork>
     91a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (ret == 0){
     91d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     921:	75 31                	jne    954 <testtimewitharg+0x45>
    exec(arg[0], arg);
     923:	8b 45 08             	mov    0x8(%ebp),%eax
     926:	8b 00                	mov    (%eax),%eax
     928:	83 ec 08             	sub    $0x8,%esp
     92b:	ff 75 08             	pushl  0x8(%ebp)
     92e:	50                   	push   %eax
     92f:	e8 a0 07 00 00       	call   10d4 <exec>
     934:	83 c4 10             	add    $0x10,%esp
    printf(2, "FAILED: exec failed to execute %s\n", arg[0]);
     937:	8b 45 08             	mov    0x8(%ebp),%eax
     93a:	8b 00                	mov    (%eax),%eax
     93c:	83 ec 04             	sub    $0x4,%esp
     93f:	50                   	push   %eax
     940:	68 40 1b 00 00       	push   $0x1b40
     945:	6a 02                	push   $0x2
     947:	e8 07 09 00 00       	call   1253 <printf>
     94c:	83 c4 10             	add    $0x10,%esp
    exit();
     94f:	e8 48 07 00 00       	call   109c <exit>
  }
  else if(ret == -1){
     954:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
     958:	75 14                	jne    96e <testtimewitharg+0x5f>
    printf(2, "FAILED: fork failed\n");
     95a:	83 ec 08             	sub    $0x8,%esp
     95d:	68 63 1b 00 00       	push   $0x1b63
     962:	6a 02                	push   $0x2
     964:	e8 ea 08 00 00       	call   1253 <printf>
     969:	83 c4 10             	add    $0x10,%esp
  }
  else
    wait();
}
     96c:	eb 05                	jmp    973 <testtimewitharg+0x64>
  }
  else if(ret == -1){
    printf(2, "FAILED: fork failed\n");
  }
  else
    wait();
     96e:	e8 31 07 00 00       	call   10a4 <wait>
}
     973:	90                   	nop
     974:	c9                   	leave  
     975:	c3                   	ret    

00000976 <testtime>:
void
testtime(void){
     976:	55                   	push   %ebp
     977:	89 e5                	mov    %esp,%ebp
     979:	53                   	push   %ebx
     97a:	83 ec 14             	sub    $0x14,%esp
  char **arg1 = malloc(sizeof(char *));
     97d:	83 ec 0c             	sub    $0xc,%esp
     980:	6a 04                	push   $0x4
     982:	e8 9f 0b 00 00       	call   1526 <malloc>
     987:	83 c4 10             	add    $0x10,%esp
     98a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  char **arg2 = malloc(sizeof(char *)*2);
     98d:	83 ec 0c             	sub    $0xc,%esp
     990:	6a 08                	push   $0x8
     992:	e8 8f 0b 00 00       	call   1526 <malloc>
     997:	83 c4 10             	add    $0x10,%esp
     99a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char **arg3 = malloc(sizeof(char *)*2);
     99d:	83 ec 0c             	sub    $0xc,%esp
     9a0:	6a 08                	push   $0x8
     9a2:	e8 7f 0b 00 00       	call   1526 <malloc>
     9a7:	83 c4 10             	add    $0x10,%esp
     9aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  char **arg4 = malloc(sizeof(char *)*4);
     9ad:	83 ec 0c             	sub    $0xc,%esp
     9b0:	6a 10                	push   $0x10
     9b2:	e8 6f 0b 00 00       	call   1526 <malloc>
     9b7:	83 c4 10             	add    $0x10,%esp
     9ba:	89 45 e8             	mov    %eax,-0x18(%ebp)

  arg1[0] = malloc(sizeof(char) * 5);
     9bd:	83 ec 0c             	sub    $0xc,%esp
     9c0:	6a 05                	push   $0x5
     9c2:	e8 5f 0b 00 00       	call   1526 <malloc>
     9c7:	83 c4 10             	add    $0x10,%esp
     9ca:	89 c2                	mov    %eax,%edx
     9cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9cf:	89 10                	mov    %edx,(%eax)
  strcpy(arg1[0], "time");
     9d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9d4:	8b 00                	mov    (%eax),%eax
     9d6:	83 ec 08             	sub    $0x8,%esp
     9d9:	68 78 1b 00 00       	push   $0x1b78
     9de:	50                   	push   %eax
     9df:	e8 b4 03 00 00       	call   d98 <strcpy>
     9e4:	83 c4 10             	add    $0x10,%esp

  arg2[0] = malloc(sizeof(char) * 5);
     9e7:	83 ec 0c             	sub    $0xc,%esp
     9ea:	6a 05                	push   $0x5
     9ec:	e8 35 0b 00 00       	call   1526 <malloc>
     9f1:	83 c4 10             	add    $0x10,%esp
     9f4:	89 c2                	mov    %eax,%edx
     9f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
     9f9:	89 10                	mov    %edx,(%eax)
  strcpy(arg2[0], "time");
     9fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
     9fe:	8b 00                	mov    (%eax),%eax
     a00:	83 ec 08             	sub    $0x8,%esp
     a03:	68 78 1b 00 00       	push   $0x1b78
     a08:	50                   	push   %eax
     a09:	e8 8a 03 00 00       	call   d98 <strcpy>
     a0e:	83 c4 10             	add    $0x10,%esp
  arg2[1] = malloc(sizeof(char) * 4);
     a11:	8b 45 f0             	mov    -0x10(%ebp),%eax
     a14:	8d 58 04             	lea    0x4(%eax),%ebx
     a17:	83 ec 0c             	sub    $0xc,%esp
     a1a:	6a 04                	push   $0x4
     a1c:	e8 05 0b 00 00       	call   1526 <malloc>
     a21:	83 c4 10             	add    $0x10,%esp
     a24:	89 03                	mov    %eax,(%ebx)
  strcpy(arg2[1], "abc");
     a26:	8b 45 f0             	mov    -0x10(%ebp),%eax
     a29:	83 c0 04             	add    $0x4,%eax
     a2c:	8b 00                	mov    (%eax),%eax
     a2e:	83 ec 08             	sub    $0x8,%esp
     a31:	68 7d 1b 00 00       	push   $0x1b7d
     a36:	50                   	push   %eax
     a37:	e8 5c 03 00 00       	call   d98 <strcpy>
     a3c:	83 c4 10             	add    $0x10,%esp

  arg3[0] = malloc(sizeof(char) * 5);
     a3f:	83 ec 0c             	sub    $0xc,%esp
     a42:	6a 05                	push   $0x5
     a44:	e8 dd 0a 00 00       	call   1526 <malloc>
     a49:	83 c4 10             	add    $0x10,%esp
     a4c:	89 c2                	mov    %eax,%edx
     a4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
     a51:	89 10                	mov    %edx,(%eax)
  strcpy(arg3[0], "time");
     a53:	8b 45 ec             	mov    -0x14(%ebp),%eax
     a56:	8b 00                	mov    (%eax),%eax
     a58:	83 ec 08             	sub    $0x8,%esp
     a5b:	68 78 1b 00 00       	push   $0x1b78
     a60:	50                   	push   %eax
     a61:	e8 32 03 00 00       	call   d98 <strcpy>
     a66:	83 c4 10             	add    $0x10,%esp
  arg3[1] = malloc(sizeof(char) * 5);
     a69:	8b 45 ec             	mov    -0x14(%ebp),%eax
     a6c:	8d 58 04             	lea    0x4(%eax),%ebx
     a6f:	83 ec 0c             	sub    $0xc,%esp
     a72:	6a 05                	push   $0x5
     a74:	e8 ad 0a 00 00       	call   1526 <malloc>
     a79:	83 c4 10             	add    $0x10,%esp
     a7c:	89 03                	mov    %eax,(%ebx)
  strcpy(arg3[1], "date");
     a7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
     a81:	83 c0 04             	add    $0x4,%eax
     a84:	8b 00                	mov    (%eax),%eax
     a86:	83 ec 08             	sub    $0x8,%esp
     a89:	68 81 1b 00 00       	push   $0x1b81
     a8e:	50                   	push   %eax
     a8f:	e8 04 03 00 00       	call   d98 <strcpy>
     a94:	83 c4 10             	add    $0x10,%esp

  arg4[0] = malloc(sizeof(char) * 5);
     a97:	83 ec 0c             	sub    $0xc,%esp
     a9a:	6a 05                	push   $0x5
     a9c:	e8 85 0a 00 00       	call   1526 <malloc>
     aa1:	83 c4 10             	add    $0x10,%esp
     aa4:	89 c2                	mov    %eax,%edx
     aa6:	8b 45 e8             	mov    -0x18(%ebp),%eax
     aa9:	89 10                	mov    %edx,(%eax)
  strcpy(arg4[0], "time");
     aab:	8b 45 e8             	mov    -0x18(%ebp),%eax
     aae:	8b 00                	mov    (%eax),%eax
     ab0:	83 ec 08             	sub    $0x8,%esp
     ab3:	68 78 1b 00 00       	push   $0x1b78
     ab8:	50                   	push   %eax
     ab9:	e8 da 02 00 00       	call   d98 <strcpy>
     abe:	83 c4 10             	add    $0x10,%esp
  arg4[1] = malloc(sizeof(char) * 5);
     ac1:	8b 45 e8             	mov    -0x18(%ebp),%eax
     ac4:	8d 58 04             	lea    0x4(%eax),%ebx
     ac7:	83 ec 0c             	sub    $0xc,%esp
     aca:	6a 05                	push   $0x5
     acc:	e8 55 0a 00 00       	call   1526 <malloc>
     ad1:	83 c4 10             	add    $0x10,%esp
     ad4:	89 03                	mov    %eax,(%ebx)
  strcpy(arg4[1], "time");
     ad6:	8b 45 e8             	mov    -0x18(%ebp),%eax
     ad9:	83 c0 04             	add    $0x4,%eax
     adc:	8b 00                	mov    (%eax),%eax
     ade:	83 ec 08             	sub    $0x8,%esp
     ae1:	68 78 1b 00 00       	push   $0x1b78
     ae6:	50                   	push   %eax
     ae7:	e8 ac 02 00 00       	call   d98 <strcpy>
     aec:	83 c4 10             	add    $0x10,%esp
  arg4[2] = malloc(sizeof(char) * 5);
     aef:	8b 45 e8             	mov    -0x18(%ebp),%eax
     af2:	8d 58 08             	lea    0x8(%eax),%ebx
     af5:	83 ec 0c             	sub    $0xc,%esp
     af8:	6a 05                	push   $0x5
     afa:	e8 27 0a 00 00       	call   1526 <malloc>
     aff:	83 c4 10             	add    $0x10,%esp
     b02:	89 03                	mov    %eax,(%ebx)
  strcpy(arg4[2], "echo");
     b04:	8b 45 e8             	mov    -0x18(%ebp),%eax
     b07:	83 c0 08             	add    $0x8,%eax
     b0a:	8b 00                	mov    (%eax),%eax
     b0c:	83 ec 08             	sub    $0x8,%esp
     b0f:	68 86 1b 00 00       	push   $0x1b86
     b14:	50                   	push   %eax
     b15:	e8 7e 02 00 00       	call   d98 <strcpy>
     b1a:	83 c4 10             	add    $0x10,%esp
  arg4[3] = malloc(sizeof(char) * 6);
     b1d:	8b 45 e8             	mov    -0x18(%ebp),%eax
     b20:	8d 58 0c             	lea    0xc(%eax),%ebx
     b23:	83 ec 0c             	sub    $0xc,%esp
     b26:	6a 06                	push   $0x6
     b28:	e8 f9 09 00 00       	call   1526 <malloc>
     b2d:	83 c4 10             	add    $0x10,%esp
     b30:	89 03                	mov    %eax,(%ebx)
  strcpy(arg4[3], "\"abc\"");
     b32:	8b 45 e8             	mov    -0x18(%ebp),%eax
     b35:	83 c0 0c             	add    $0xc,%eax
     b38:	8b 00                	mov    (%eax),%eax
     b3a:	83 ec 08             	sub    $0x8,%esp
     b3d:	68 8b 1b 00 00       	push   $0x1b8b
     b42:	50                   	push   %eax
     b43:	e8 50 02 00 00       	call   d98 <strcpy>
     b48:	83 c4 10             	add    $0x10,%esp

  printf(1, "\n----------\nRunning Time Test\n----------\n");
     b4b:	83 ec 08             	sub    $0x8,%esp
     b4e:	68 94 1b 00 00       	push   $0x1b94
     b53:	6a 01                	push   $0x1
     b55:	e8 f9 06 00 00       	call   1253 <printf>
     b5a:	83 c4 10             	add    $0x10,%esp
  printf(1, "You will need to verify these tests passed\n");
     b5d:	83 ec 08             	sub    $0x8,%esp
     b60:	68 c0 1b 00 00       	push   $0x1bc0
     b65:	6a 01                	push   $0x1
     b67:	e8 e7 06 00 00       	call   1253 <printf>
     b6c:	83 c4 10             	add    $0x10,%esp

  printf(1,"\n%s\n", arg1[0]);
     b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     b72:	8b 00                	mov    (%eax),%eax
     b74:	83 ec 04             	sub    $0x4,%esp
     b77:	50                   	push   %eax
     b78:	68 ec 1b 00 00       	push   $0x1bec
     b7d:	6a 01                	push   $0x1
     b7f:	e8 cf 06 00 00       	call   1253 <printf>
     b84:	83 c4 10             	add    $0x10,%esp
  testtimewitharg(arg1);
     b87:	83 ec 0c             	sub    $0xc,%esp
     b8a:	ff 75 f4             	pushl  -0xc(%ebp)
     b8d:	e8 7d fd ff ff       	call   90f <testtimewitharg>
     b92:	83 c4 10             	add    $0x10,%esp
  printf(1,"\n%s %s\n", arg2[0], arg2[1]);
     b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
     b98:	83 c0 04             	add    $0x4,%eax
     b9b:	8b 10                	mov    (%eax),%edx
     b9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
     ba0:	8b 00                	mov    (%eax),%eax
     ba2:	52                   	push   %edx
     ba3:	50                   	push   %eax
     ba4:	68 f1 1b 00 00       	push   $0x1bf1
     ba9:	6a 01                	push   $0x1
     bab:	e8 a3 06 00 00       	call   1253 <printf>
     bb0:	83 c4 10             	add    $0x10,%esp
  testtimewitharg(arg2);
     bb3:	83 ec 0c             	sub    $0xc,%esp
     bb6:	ff 75 f0             	pushl  -0x10(%ebp)
     bb9:	e8 51 fd ff ff       	call   90f <testtimewitharg>
     bbe:	83 c4 10             	add    $0x10,%esp
  printf(1,"\n%s %s\n", arg3[0], arg3[1]);
     bc1:	8b 45 ec             	mov    -0x14(%ebp),%eax
     bc4:	83 c0 04             	add    $0x4,%eax
     bc7:	8b 10                	mov    (%eax),%edx
     bc9:	8b 45 ec             	mov    -0x14(%ebp),%eax
     bcc:	8b 00                	mov    (%eax),%eax
     bce:	52                   	push   %edx
     bcf:	50                   	push   %eax
     bd0:	68 f1 1b 00 00       	push   $0x1bf1
     bd5:	6a 01                	push   $0x1
     bd7:	e8 77 06 00 00       	call   1253 <printf>
     bdc:	83 c4 10             	add    $0x10,%esp
  testtimewitharg(arg3);
     bdf:	83 ec 0c             	sub    $0xc,%esp
     be2:	ff 75 ec             	pushl  -0x14(%ebp)
     be5:	e8 25 fd ff ff       	call   90f <testtimewitharg>
     bea:	83 c4 10             	add    $0x10,%esp
  printf(1,"\n%s %s %s %s\n", arg4[0], arg4[1], arg4[2], arg4[3]);
     bed:	8b 45 e8             	mov    -0x18(%ebp),%eax
     bf0:	83 c0 0c             	add    $0xc,%eax
     bf3:	8b 18                	mov    (%eax),%ebx
     bf5:	8b 45 e8             	mov    -0x18(%ebp),%eax
     bf8:	83 c0 08             	add    $0x8,%eax
     bfb:	8b 08                	mov    (%eax),%ecx
     bfd:	8b 45 e8             	mov    -0x18(%ebp),%eax
     c00:	83 c0 04             	add    $0x4,%eax
     c03:	8b 10                	mov    (%eax),%edx
     c05:	8b 45 e8             	mov    -0x18(%ebp),%eax
     c08:	8b 00                	mov    (%eax),%eax
     c0a:	83 ec 08             	sub    $0x8,%esp
     c0d:	53                   	push   %ebx
     c0e:	51                   	push   %ecx
     c0f:	52                   	push   %edx
     c10:	50                   	push   %eax
     c11:	68 f9 1b 00 00       	push   $0x1bf9
     c16:	6a 01                	push   $0x1
     c18:	e8 36 06 00 00       	call   1253 <printf>
     c1d:	83 c4 20             	add    $0x20,%esp
  testtimewitharg(arg4);
     c20:	83 ec 0c             	sub    $0xc,%esp
     c23:	ff 75 e8             	pushl  -0x18(%ebp)
     c26:	e8 e4 fc ff ff       	call   90f <testtimewitharg>
     c2b:	83 c4 10             	add    $0x10,%esp

  free(arg1[0]);
     c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     c31:	8b 00                	mov    (%eax),%eax
     c33:	83 ec 0c             	sub    $0xc,%esp
     c36:	50                   	push   %eax
     c37:	e8 a8 07 00 00       	call   13e4 <free>
     c3c:	83 c4 10             	add    $0x10,%esp
  free(arg1);
     c3f:	83 ec 0c             	sub    $0xc,%esp
     c42:	ff 75 f4             	pushl  -0xc(%ebp)
     c45:	e8 9a 07 00 00       	call   13e4 <free>
     c4a:	83 c4 10             	add    $0x10,%esp
  free(arg2[0]); free(arg2[1]);
     c4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c50:	8b 00                	mov    (%eax),%eax
     c52:	83 ec 0c             	sub    $0xc,%esp
     c55:	50                   	push   %eax
     c56:	e8 89 07 00 00       	call   13e4 <free>
     c5b:	83 c4 10             	add    $0x10,%esp
     c5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c61:	83 c0 04             	add    $0x4,%eax
     c64:	8b 00                	mov    (%eax),%eax
     c66:	83 ec 0c             	sub    $0xc,%esp
     c69:	50                   	push   %eax
     c6a:	e8 75 07 00 00       	call   13e4 <free>
     c6f:	83 c4 10             	add    $0x10,%esp
  free(arg2);
     c72:	83 ec 0c             	sub    $0xc,%esp
     c75:	ff 75 f0             	pushl  -0x10(%ebp)
     c78:	e8 67 07 00 00       	call   13e4 <free>
     c7d:	83 c4 10             	add    $0x10,%esp
  free(arg3[0]); free(arg3[1]);
     c80:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c83:	8b 00                	mov    (%eax),%eax
     c85:	83 ec 0c             	sub    $0xc,%esp
     c88:	50                   	push   %eax
     c89:	e8 56 07 00 00       	call   13e4 <free>
     c8e:	83 c4 10             	add    $0x10,%esp
     c91:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c94:	83 c0 04             	add    $0x4,%eax
     c97:	8b 00                	mov    (%eax),%eax
     c99:	83 ec 0c             	sub    $0xc,%esp
     c9c:	50                   	push   %eax
     c9d:	e8 42 07 00 00       	call   13e4 <free>
     ca2:	83 c4 10             	add    $0x10,%esp
  free(arg3);
     ca5:	83 ec 0c             	sub    $0xc,%esp
     ca8:	ff 75 ec             	pushl  -0x14(%ebp)
     cab:	e8 34 07 00 00       	call   13e4 <free>
     cb0:	83 c4 10             	add    $0x10,%esp
  free(arg4[0]); free(arg4[1]); free(arg4[2]); free(arg4[3]);
     cb3:	8b 45 e8             	mov    -0x18(%ebp),%eax
     cb6:	8b 00                	mov    (%eax),%eax
     cb8:	83 ec 0c             	sub    $0xc,%esp
     cbb:	50                   	push   %eax
     cbc:	e8 23 07 00 00       	call   13e4 <free>
     cc1:	83 c4 10             	add    $0x10,%esp
     cc4:	8b 45 e8             	mov    -0x18(%ebp),%eax
     cc7:	83 c0 04             	add    $0x4,%eax
     cca:	8b 00                	mov    (%eax),%eax
     ccc:	83 ec 0c             	sub    $0xc,%esp
     ccf:	50                   	push   %eax
     cd0:	e8 0f 07 00 00       	call   13e4 <free>
     cd5:	83 c4 10             	add    $0x10,%esp
     cd8:	8b 45 e8             	mov    -0x18(%ebp),%eax
     cdb:	83 c0 08             	add    $0x8,%eax
     cde:	8b 00                	mov    (%eax),%eax
     ce0:	83 ec 0c             	sub    $0xc,%esp
     ce3:	50                   	push   %eax
     ce4:	e8 fb 06 00 00       	call   13e4 <free>
     ce9:	83 c4 10             	add    $0x10,%esp
     cec:	8b 45 e8             	mov    -0x18(%ebp),%eax
     cef:	83 c0 0c             	add    $0xc,%eax
     cf2:	8b 00                	mov    (%eax),%eax
     cf4:	83 ec 0c             	sub    $0xc,%esp
     cf7:	50                   	push   %eax
     cf8:	e8 e7 06 00 00       	call   13e4 <free>
     cfd:	83 c4 10             	add    $0x10,%esp
  free(arg4);
     d00:	83 ec 0c             	sub    $0xc,%esp
     d03:	ff 75 e8             	pushl  -0x18(%ebp)
     d06:	e8 d9 06 00 00       	call   13e4 <free>
     d0b:	83 c4 10             	add    $0x10,%esp
}
     d0e:	90                   	nop
     d0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
     d12:	c9                   	leave  
     d13:	c3                   	ret    

00000d14 <main>:
#endif

int
main(int argc, char *argv[])
{
     d14:	8d 4c 24 04          	lea    0x4(%esp),%ecx
     d18:	83 e4 f0             	and    $0xfffffff0,%esp
     d1b:	ff 71 fc             	pushl  -0x4(%ecx)
     d1e:	55                   	push   %ebp
     d1f:	89 e5                	mov    %esp,%ebp
     d21:	53                   	push   %ebx
     d22:	51                   	push   %ecx
     d23:	89 cb                	mov    %ecx,%ebx
  #ifdef CPUTIME_TEST
  testcputime(argv[0]);
     d25:	8b 43 04             	mov    0x4(%ebx),%eax
     d28:	8b 00                	mov    (%eax),%eax
     d2a:	83 ec 0c             	sub    $0xc,%esp
     d2d:	50                   	push   %eax
     d2e:	e8 c3 f7 ff ff       	call   4f6 <testcputime>
     d33:	83 c4 10             	add    $0x10,%esp
  #endif
  #ifdef UIDGIDPPID_TEST
  testuidgid();
     d36:	e8 6d f4 ff ff       	call   1a8 <testuidgid>
  testuidgidinheritance();
     d3b:	e8 3e f6 ff ff       	call   37e <testuidgidinheritance>
  testppid();
     d40:	e8 bb f2 ff ff       	call   0 <testppid>
  #endif
  #ifdef GETPROCS_TEST
  testgetprocs(argv[0]);
     d45:	8b 43 04             	mov    0x4(%ebx),%eax
     d48:	8b 00                	mov    (%eax),%eax
     d4a:	83 ec 0c             	sub    $0xc,%esp
     d4d:	50                   	push   %eax
     d4e:	e8 c4 fa ff ff       	call   817 <testgetprocs>
     d53:	83 c4 10             	add    $0x10,%esp
  #endif
  #ifdef TIME_TEST
  testtime();
     d56:	e8 1b fc ff ff       	call   976 <testtime>
  #endif
  printf(1, "\n** End of Tests **\n");
     d5b:	83 ec 08             	sub    $0x8,%esp
     d5e:	68 07 1c 00 00       	push   $0x1c07
     d63:	6a 01                	push   $0x1
     d65:	e8 e9 04 00 00       	call   1253 <printf>
     d6a:	83 c4 10             	add    $0x10,%esp
  exit();
     d6d:	e8 2a 03 00 00       	call   109c <exit>

00000d72 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     d72:	55                   	push   %ebp
     d73:	89 e5                	mov    %esp,%ebp
     d75:	57                   	push   %edi
     d76:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
     d77:	8b 4d 08             	mov    0x8(%ebp),%ecx
     d7a:	8b 55 10             	mov    0x10(%ebp),%edx
     d7d:	8b 45 0c             	mov    0xc(%ebp),%eax
     d80:	89 cb                	mov    %ecx,%ebx
     d82:	89 df                	mov    %ebx,%edi
     d84:	89 d1                	mov    %edx,%ecx
     d86:	fc                   	cld    
     d87:	f3 aa                	rep stos %al,%es:(%edi)
     d89:	89 ca                	mov    %ecx,%edx
     d8b:	89 fb                	mov    %edi,%ebx
     d8d:	89 5d 08             	mov    %ebx,0x8(%ebp)
     d90:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     d93:	90                   	nop
     d94:	5b                   	pop    %ebx
     d95:	5f                   	pop    %edi
     d96:	5d                   	pop    %ebp
     d97:	c3                   	ret    

00000d98 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
     d98:	55                   	push   %ebp
     d99:	89 e5                	mov    %esp,%ebp
     d9b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
     d9e:	8b 45 08             	mov    0x8(%ebp),%eax
     da1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
     da4:	90                   	nop
     da5:	8b 45 08             	mov    0x8(%ebp),%eax
     da8:	8d 50 01             	lea    0x1(%eax),%edx
     dab:	89 55 08             	mov    %edx,0x8(%ebp)
     dae:	8b 55 0c             	mov    0xc(%ebp),%edx
     db1:	8d 4a 01             	lea    0x1(%edx),%ecx
     db4:	89 4d 0c             	mov    %ecx,0xc(%ebp)
     db7:	0f b6 12             	movzbl (%edx),%edx
     dba:	88 10                	mov    %dl,(%eax)
     dbc:	0f b6 00             	movzbl (%eax),%eax
     dbf:	84 c0                	test   %al,%al
     dc1:	75 e2                	jne    da5 <strcpy+0xd>
    ;
  return os;
     dc3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     dc6:	c9                   	leave  
     dc7:	c3                   	ret    

00000dc8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     dc8:	55                   	push   %ebp
     dc9:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
     dcb:	eb 08                	jmp    dd5 <strcmp+0xd>
    p++, q++;
     dcd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     dd1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
     dd5:	8b 45 08             	mov    0x8(%ebp),%eax
     dd8:	0f b6 00             	movzbl (%eax),%eax
     ddb:	84 c0                	test   %al,%al
     ddd:	74 10                	je     def <strcmp+0x27>
     ddf:	8b 45 08             	mov    0x8(%ebp),%eax
     de2:	0f b6 10             	movzbl (%eax),%edx
     de5:	8b 45 0c             	mov    0xc(%ebp),%eax
     de8:	0f b6 00             	movzbl (%eax),%eax
     deb:	38 c2                	cmp    %al,%dl
     ded:	74 de                	je     dcd <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
     def:	8b 45 08             	mov    0x8(%ebp),%eax
     df2:	0f b6 00             	movzbl (%eax),%eax
     df5:	0f b6 d0             	movzbl %al,%edx
     df8:	8b 45 0c             	mov    0xc(%ebp),%eax
     dfb:	0f b6 00             	movzbl (%eax),%eax
     dfe:	0f b6 c0             	movzbl %al,%eax
     e01:	29 c2                	sub    %eax,%edx
     e03:	89 d0                	mov    %edx,%eax
}
     e05:	5d                   	pop    %ebp
     e06:	c3                   	ret    

00000e07 <strlen>:

uint
strlen(char *s)
{
     e07:	55                   	push   %ebp
     e08:	89 e5                	mov    %esp,%ebp
     e0a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
     e0d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
     e14:	eb 04                	jmp    e1a <strlen+0x13>
     e16:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
     e1a:	8b 55 fc             	mov    -0x4(%ebp),%edx
     e1d:	8b 45 08             	mov    0x8(%ebp),%eax
     e20:	01 d0                	add    %edx,%eax
     e22:	0f b6 00             	movzbl (%eax),%eax
     e25:	84 c0                	test   %al,%al
     e27:	75 ed                	jne    e16 <strlen+0xf>
    ;
  return n;
     e29:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     e2c:	c9                   	leave  
     e2d:	c3                   	ret    

00000e2e <memset>:

void*
memset(void *dst, int c, uint n)
{
     e2e:	55                   	push   %ebp
     e2f:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
     e31:	8b 45 10             	mov    0x10(%ebp),%eax
     e34:	50                   	push   %eax
     e35:	ff 75 0c             	pushl  0xc(%ebp)
     e38:	ff 75 08             	pushl  0x8(%ebp)
     e3b:	e8 32 ff ff ff       	call   d72 <stosb>
     e40:	83 c4 0c             	add    $0xc,%esp
  return dst;
     e43:	8b 45 08             	mov    0x8(%ebp),%eax
}
     e46:	c9                   	leave  
     e47:	c3                   	ret    

00000e48 <strchr>:

char*
strchr(const char *s, char c)
{
     e48:	55                   	push   %ebp
     e49:	89 e5                	mov    %esp,%ebp
     e4b:	83 ec 04             	sub    $0x4,%esp
     e4e:	8b 45 0c             	mov    0xc(%ebp),%eax
     e51:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
     e54:	eb 14                	jmp    e6a <strchr+0x22>
    if(*s == c)
     e56:	8b 45 08             	mov    0x8(%ebp),%eax
     e59:	0f b6 00             	movzbl (%eax),%eax
     e5c:	3a 45 fc             	cmp    -0x4(%ebp),%al
     e5f:	75 05                	jne    e66 <strchr+0x1e>
      return (char*)s;
     e61:	8b 45 08             	mov    0x8(%ebp),%eax
     e64:	eb 13                	jmp    e79 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
     e66:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     e6a:	8b 45 08             	mov    0x8(%ebp),%eax
     e6d:	0f b6 00             	movzbl (%eax),%eax
     e70:	84 c0                	test   %al,%al
     e72:	75 e2                	jne    e56 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
     e74:	b8 00 00 00 00       	mov    $0x0,%eax
}
     e79:	c9                   	leave  
     e7a:	c3                   	ret    

00000e7b <gets>:

char*
gets(char *buf, int max)
{
     e7b:	55                   	push   %ebp
     e7c:	89 e5                	mov    %esp,%ebp
     e7e:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     e81:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     e88:	eb 42                	jmp    ecc <gets+0x51>
    cc = read(0, &c, 1);
     e8a:	83 ec 04             	sub    $0x4,%esp
     e8d:	6a 01                	push   $0x1
     e8f:	8d 45 ef             	lea    -0x11(%ebp),%eax
     e92:	50                   	push   %eax
     e93:	6a 00                	push   $0x0
     e95:	e8 1a 02 00 00       	call   10b4 <read>
     e9a:	83 c4 10             	add    $0x10,%esp
     e9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
     ea0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     ea4:	7e 33                	jle    ed9 <gets+0x5e>
      break;
    buf[i++] = c;
     ea6:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ea9:	8d 50 01             	lea    0x1(%eax),%edx
     eac:	89 55 f4             	mov    %edx,-0xc(%ebp)
     eaf:	89 c2                	mov    %eax,%edx
     eb1:	8b 45 08             	mov    0x8(%ebp),%eax
     eb4:	01 c2                	add    %eax,%edx
     eb6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     eba:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
     ebc:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     ec0:	3c 0a                	cmp    $0xa,%al
     ec2:	74 16                	je     eda <gets+0x5f>
     ec4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     ec8:	3c 0d                	cmp    $0xd,%al
     eca:	74 0e                	je     eda <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     ecc:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ecf:	83 c0 01             	add    $0x1,%eax
     ed2:	3b 45 0c             	cmp    0xc(%ebp),%eax
     ed5:	7c b3                	jl     e8a <gets+0xf>
     ed7:	eb 01                	jmp    eda <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
     ed9:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
     eda:	8b 55 f4             	mov    -0xc(%ebp),%edx
     edd:	8b 45 08             	mov    0x8(%ebp),%eax
     ee0:	01 d0                	add    %edx,%eax
     ee2:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
     ee5:	8b 45 08             	mov    0x8(%ebp),%eax
}
     ee8:	c9                   	leave  
     ee9:	c3                   	ret    

00000eea <stat>:

int
stat(char *n, struct stat *st)
{
     eea:	55                   	push   %ebp
     eeb:	89 e5                	mov    %esp,%ebp
     eed:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     ef0:	83 ec 08             	sub    $0x8,%esp
     ef3:	6a 00                	push   $0x0
     ef5:	ff 75 08             	pushl  0x8(%ebp)
     ef8:	e8 df 01 00 00       	call   10dc <open>
     efd:	83 c4 10             	add    $0x10,%esp
     f00:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
     f03:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     f07:	79 07                	jns    f10 <stat+0x26>
    return -1;
     f09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     f0e:	eb 25                	jmp    f35 <stat+0x4b>
  r = fstat(fd, st);
     f10:	83 ec 08             	sub    $0x8,%esp
     f13:	ff 75 0c             	pushl  0xc(%ebp)
     f16:	ff 75 f4             	pushl  -0xc(%ebp)
     f19:	e8 d6 01 00 00       	call   10f4 <fstat>
     f1e:	83 c4 10             	add    $0x10,%esp
     f21:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
     f24:	83 ec 0c             	sub    $0xc,%esp
     f27:	ff 75 f4             	pushl  -0xc(%ebp)
     f2a:	e8 95 01 00 00       	call   10c4 <close>
     f2f:	83 c4 10             	add    $0x10,%esp
  return r;
     f32:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     f35:	c9                   	leave  
     f36:	c3                   	ret    

00000f37 <atoi>:

int
atoi(const char *s)
{
     f37:	55                   	push   %ebp
     f38:	89 e5                	mov    %esp,%ebp
     f3a:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
     f3d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
     f44:	eb 04                	jmp    f4a <atoi+0x13>
     f46:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     f4a:	8b 45 08             	mov    0x8(%ebp),%eax
     f4d:	0f b6 00             	movzbl (%eax),%eax
     f50:	3c 20                	cmp    $0x20,%al
     f52:	74 f2                	je     f46 <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
     f54:	8b 45 08             	mov    0x8(%ebp),%eax
     f57:	0f b6 00             	movzbl (%eax),%eax
     f5a:	3c 2d                	cmp    $0x2d,%al
     f5c:	75 07                	jne    f65 <atoi+0x2e>
     f5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     f63:	eb 05                	jmp    f6a <atoi+0x33>
     f65:	b8 01 00 00 00       	mov    $0x1,%eax
     f6a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
     f6d:	8b 45 08             	mov    0x8(%ebp),%eax
     f70:	0f b6 00             	movzbl (%eax),%eax
     f73:	3c 2b                	cmp    $0x2b,%al
     f75:	74 0a                	je     f81 <atoi+0x4a>
     f77:	8b 45 08             	mov    0x8(%ebp),%eax
     f7a:	0f b6 00             	movzbl (%eax),%eax
     f7d:	3c 2d                	cmp    $0x2d,%al
     f7f:	75 2b                	jne    fac <atoi+0x75>
    s++;
     f81:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
     f85:	eb 25                	jmp    fac <atoi+0x75>
    n = n*10 + *s++ - '0';
     f87:	8b 55 fc             	mov    -0x4(%ebp),%edx
     f8a:	89 d0                	mov    %edx,%eax
     f8c:	c1 e0 02             	shl    $0x2,%eax
     f8f:	01 d0                	add    %edx,%eax
     f91:	01 c0                	add    %eax,%eax
     f93:	89 c1                	mov    %eax,%ecx
     f95:	8b 45 08             	mov    0x8(%ebp),%eax
     f98:	8d 50 01             	lea    0x1(%eax),%edx
     f9b:	89 55 08             	mov    %edx,0x8(%ebp)
     f9e:	0f b6 00             	movzbl (%eax),%eax
     fa1:	0f be c0             	movsbl %al,%eax
     fa4:	01 c8                	add    %ecx,%eax
     fa6:	83 e8 30             	sub    $0x30,%eax
     fa9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
     fac:	8b 45 08             	mov    0x8(%ebp),%eax
     faf:	0f b6 00             	movzbl (%eax),%eax
     fb2:	3c 2f                	cmp    $0x2f,%al
     fb4:	7e 0a                	jle    fc0 <atoi+0x89>
     fb6:	8b 45 08             	mov    0x8(%ebp),%eax
     fb9:	0f b6 00             	movzbl (%eax),%eax
     fbc:	3c 39                	cmp    $0x39,%al
     fbe:	7e c7                	jle    f87 <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
     fc0:	8b 45 f8             	mov    -0x8(%ebp),%eax
     fc3:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
     fc7:	c9                   	leave  
     fc8:	c3                   	ret    

00000fc9 <atoo>:

int
atoo(const char *s)
{
     fc9:	55                   	push   %ebp
     fca:	89 e5                	mov    %esp,%ebp
     fcc:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
     fcf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
     fd6:	eb 04                	jmp    fdc <atoo+0x13>
     fd8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     fdc:	8b 45 08             	mov    0x8(%ebp),%eax
     fdf:	0f b6 00             	movzbl (%eax),%eax
     fe2:	3c 20                	cmp    $0x20,%al
     fe4:	74 f2                	je     fd8 <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
     fe6:	8b 45 08             	mov    0x8(%ebp),%eax
     fe9:	0f b6 00             	movzbl (%eax),%eax
     fec:	3c 2d                	cmp    $0x2d,%al
     fee:	75 07                	jne    ff7 <atoo+0x2e>
     ff0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     ff5:	eb 05                	jmp    ffc <atoo+0x33>
     ff7:	b8 01 00 00 00       	mov    $0x1,%eax
     ffc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
     fff:	8b 45 08             	mov    0x8(%ebp),%eax
    1002:	0f b6 00             	movzbl (%eax),%eax
    1005:	3c 2b                	cmp    $0x2b,%al
    1007:	74 0a                	je     1013 <atoo+0x4a>
    1009:	8b 45 08             	mov    0x8(%ebp),%eax
    100c:	0f b6 00             	movzbl (%eax),%eax
    100f:	3c 2d                	cmp    $0x2d,%al
    1011:	75 27                	jne    103a <atoo+0x71>
    s++;
    1013:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
    1017:	eb 21                	jmp    103a <atoo+0x71>
    n = n*8 + *s++ - '0';
    1019:	8b 45 fc             	mov    -0x4(%ebp),%eax
    101c:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
    1023:	8b 45 08             	mov    0x8(%ebp),%eax
    1026:	8d 50 01             	lea    0x1(%eax),%edx
    1029:	89 55 08             	mov    %edx,0x8(%ebp)
    102c:	0f b6 00             	movzbl (%eax),%eax
    102f:	0f be c0             	movsbl %al,%eax
    1032:	01 c8                	add    %ecx,%eax
    1034:	83 e8 30             	sub    $0x30,%eax
    1037:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
    103a:	8b 45 08             	mov    0x8(%ebp),%eax
    103d:	0f b6 00             	movzbl (%eax),%eax
    1040:	3c 2f                	cmp    $0x2f,%al
    1042:	7e 0a                	jle    104e <atoo+0x85>
    1044:	8b 45 08             	mov    0x8(%ebp),%eax
    1047:	0f b6 00             	movzbl (%eax),%eax
    104a:	3c 37                	cmp    $0x37,%al
    104c:	7e cb                	jle    1019 <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
    104e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1051:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
    1055:	c9                   	leave  
    1056:	c3                   	ret    

00001057 <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
    1057:	55                   	push   %ebp
    1058:	89 e5                	mov    %esp,%ebp
    105a:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
    105d:	8b 45 08             	mov    0x8(%ebp),%eax
    1060:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    1063:	8b 45 0c             	mov    0xc(%ebp),%eax
    1066:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    1069:	eb 17                	jmp    1082 <memmove+0x2b>
    *dst++ = *src++;
    106b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    106e:	8d 50 01             	lea    0x1(%eax),%edx
    1071:	89 55 fc             	mov    %edx,-0x4(%ebp)
    1074:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1077:	8d 4a 01             	lea    0x1(%edx),%ecx
    107a:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    107d:	0f b6 12             	movzbl (%edx),%edx
    1080:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    1082:	8b 45 10             	mov    0x10(%ebp),%eax
    1085:	8d 50 ff             	lea    -0x1(%eax),%edx
    1088:	89 55 10             	mov    %edx,0x10(%ebp)
    108b:	85 c0                	test   %eax,%eax
    108d:	7f dc                	jg     106b <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    108f:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1092:	c9                   	leave  
    1093:	c3                   	ret    

00001094 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    1094:	b8 01 00 00 00       	mov    $0x1,%eax
    1099:	cd 40                	int    $0x40
    109b:	c3                   	ret    

0000109c <exit>:
SYSCALL(exit)
    109c:	b8 02 00 00 00       	mov    $0x2,%eax
    10a1:	cd 40                	int    $0x40
    10a3:	c3                   	ret    

000010a4 <wait>:
SYSCALL(wait)
    10a4:	b8 03 00 00 00       	mov    $0x3,%eax
    10a9:	cd 40                	int    $0x40
    10ab:	c3                   	ret    

000010ac <pipe>:
SYSCALL(pipe)
    10ac:	b8 04 00 00 00       	mov    $0x4,%eax
    10b1:	cd 40                	int    $0x40
    10b3:	c3                   	ret    

000010b4 <read>:
SYSCALL(read)
    10b4:	b8 05 00 00 00       	mov    $0x5,%eax
    10b9:	cd 40                	int    $0x40
    10bb:	c3                   	ret    

000010bc <write>:
SYSCALL(write)
    10bc:	b8 10 00 00 00       	mov    $0x10,%eax
    10c1:	cd 40                	int    $0x40
    10c3:	c3                   	ret    

000010c4 <close>:
SYSCALL(close)
    10c4:	b8 15 00 00 00       	mov    $0x15,%eax
    10c9:	cd 40                	int    $0x40
    10cb:	c3                   	ret    

000010cc <kill>:
SYSCALL(kill)
    10cc:	b8 06 00 00 00       	mov    $0x6,%eax
    10d1:	cd 40                	int    $0x40
    10d3:	c3                   	ret    

000010d4 <exec>:
SYSCALL(exec)
    10d4:	b8 07 00 00 00       	mov    $0x7,%eax
    10d9:	cd 40                	int    $0x40
    10db:	c3                   	ret    

000010dc <open>:
SYSCALL(open)
    10dc:	b8 0f 00 00 00       	mov    $0xf,%eax
    10e1:	cd 40                	int    $0x40
    10e3:	c3                   	ret    

000010e4 <mknod>:
SYSCALL(mknod)
    10e4:	b8 11 00 00 00       	mov    $0x11,%eax
    10e9:	cd 40                	int    $0x40
    10eb:	c3                   	ret    

000010ec <unlink>:
SYSCALL(unlink)
    10ec:	b8 12 00 00 00       	mov    $0x12,%eax
    10f1:	cd 40                	int    $0x40
    10f3:	c3                   	ret    

000010f4 <fstat>:
SYSCALL(fstat)
    10f4:	b8 08 00 00 00       	mov    $0x8,%eax
    10f9:	cd 40                	int    $0x40
    10fb:	c3                   	ret    

000010fc <link>:
SYSCALL(link)
    10fc:	b8 13 00 00 00       	mov    $0x13,%eax
    1101:	cd 40                	int    $0x40
    1103:	c3                   	ret    

00001104 <mkdir>:
SYSCALL(mkdir)
    1104:	b8 14 00 00 00       	mov    $0x14,%eax
    1109:	cd 40                	int    $0x40
    110b:	c3                   	ret    

0000110c <chdir>:
SYSCALL(chdir)
    110c:	b8 09 00 00 00       	mov    $0x9,%eax
    1111:	cd 40                	int    $0x40
    1113:	c3                   	ret    

00001114 <dup>:
SYSCALL(dup)
    1114:	b8 0a 00 00 00       	mov    $0xa,%eax
    1119:	cd 40                	int    $0x40
    111b:	c3                   	ret    

0000111c <getpid>:
SYSCALL(getpid)
    111c:	b8 0b 00 00 00       	mov    $0xb,%eax
    1121:	cd 40                	int    $0x40
    1123:	c3                   	ret    

00001124 <sbrk>:
SYSCALL(sbrk)
    1124:	b8 0c 00 00 00       	mov    $0xc,%eax
    1129:	cd 40                	int    $0x40
    112b:	c3                   	ret    

0000112c <sleep>:
SYSCALL(sleep)
    112c:	b8 0d 00 00 00       	mov    $0xd,%eax
    1131:	cd 40                	int    $0x40
    1133:	c3                   	ret    

00001134 <uptime>:
SYSCALL(uptime)
    1134:	b8 0e 00 00 00       	mov    $0xe,%eax
    1139:	cd 40                	int    $0x40
    113b:	c3                   	ret    

0000113c <halt>:
SYSCALL(halt)
    113c:	b8 16 00 00 00       	mov    $0x16,%eax
    1141:	cd 40                	int    $0x40
    1143:	c3                   	ret    

00001144 <date>:
SYSCALL(date)
    1144:	b8 17 00 00 00       	mov    $0x17,%eax
    1149:	cd 40                	int    $0x40
    114b:	c3                   	ret    

0000114c <getuid>:
SYSCALL(getuid)
    114c:	b8 18 00 00 00       	mov    $0x18,%eax
    1151:	cd 40                	int    $0x40
    1153:	c3                   	ret    

00001154 <getgid>:
SYSCALL(getgid)
    1154:	b8 19 00 00 00       	mov    $0x19,%eax
    1159:	cd 40                	int    $0x40
    115b:	c3                   	ret    

0000115c <getppid>:
SYSCALL(getppid)
    115c:	b8 1a 00 00 00       	mov    $0x1a,%eax
    1161:	cd 40                	int    $0x40
    1163:	c3                   	ret    

00001164 <setuid>:
SYSCALL(setuid)
    1164:	b8 1b 00 00 00       	mov    $0x1b,%eax
    1169:	cd 40                	int    $0x40
    116b:	c3                   	ret    

0000116c <setgid>:
SYSCALL(setgid)
    116c:	b8 1c 00 00 00       	mov    $0x1c,%eax
    1171:	cd 40                	int    $0x40
    1173:	c3                   	ret    

00001174 <getprocs>:
SYSCALL(getprocs)
    1174:	b8 1a 00 00 00       	mov    $0x1a,%eax
    1179:	cd 40                	int    $0x40
    117b:	c3                   	ret    

0000117c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    117c:	55                   	push   %ebp
    117d:	89 e5                	mov    %esp,%ebp
    117f:	83 ec 18             	sub    $0x18,%esp
    1182:	8b 45 0c             	mov    0xc(%ebp),%eax
    1185:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    1188:	83 ec 04             	sub    $0x4,%esp
    118b:	6a 01                	push   $0x1
    118d:	8d 45 f4             	lea    -0xc(%ebp),%eax
    1190:	50                   	push   %eax
    1191:	ff 75 08             	pushl  0x8(%ebp)
    1194:	e8 23 ff ff ff       	call   10bc <write>
    1199:	83 c4 10             	add    $0x10,%esp
}
    119c:	90                   	nop
    119d:	c9                   	leave  
    119e:	c3                   	ret    

0000119f <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    119f:	55                   	push   %ebp
    11a0:	89 e5                	mov    %esp,%ebp
    11a2:	53                   	push   %ebx
    11a3:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    11a6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    11ad:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    11b1:	74 17                	je     11ca <printint+0x2b>
    11b3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    11b7:	79 11                	jns    11ca <printint+0x2b>
    neg = 1;
    11b9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    11c0:	8b 45 0c             	mov    0xc(%ebp),%eax
    11c3:	f7 d8                	neg    %eax
    11c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    11c8:	eb 06                	jmp    11d0 <printint+0x31>
  } else {
    x = xx;
    11ca:	8b 45 0c             	mov    0xc(%ebp),%eax
    11cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    11d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    11d7:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    11da:	8d 41 01             	lea    0x1(%ecx),%eax
    11dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    11e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
    11e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
    11e6:	ba 00 00 00 00       	mov    $0x0,%edx
    11eb:	f7 f3                	div    %ebx
    11ed:	89 d0                	mov    %edx,%eax
    11ef:	0f b6 80 14 20 00 00 	movzbl 0x2014(%eax),%eax
    11f6:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    11fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
    11fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1200:	ba 00 00 00 00       	mov    $0x0,%edx
    1205:	f7 f3                	div    %ebx
    1207:	89 45 ec             	mov    %eax,-0x14(%ebp)
    120a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    120e:	75 c7                	jne    11d7 <printint+0x38>
  if(neg)
    1210:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1214:	74 2d                	je     1243 <printint+0xa4>
    buf[i++] = '-';
    1216:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1219:	8d 50 01             	lea    0x1(%eax),%edx
    121c:	89 55 f4             	mov    %edx,-0xc(%ebp)
    121f:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    1224:	eb 1d                	jmp    1243 <printint+0xa4>
    putc(fd, buf[i]);
    1226:	8d 55 dc             	lea    -0x24(%ebp),%edx
    1229:	8b 45 f4             	mov    -0xc(%ebp),%eax
    122c:	01 d0                	add    %edx,%eax
    122e:	0f b6 00             	movzbl (%eax),%eax
    1231:	0f be c0             	movsbl %al,%eax
    1234:	83 ec 08             	sub    $0x8,%esp
    1237:	50                   	push   %eax
    1238:	ff 75 08             	pushl  0x8(%ebp)
    123b:	e8 3c ff ff ff       	call   117c <putc>
    1240:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    1243:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    1247:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    124b:	79 d9                	jns    1226 <printint+0x87>
    putc(fd, buf[i]);
}
    124d:	90                   	nop
    124e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    1251:	c9                   	leave  
    1252:	c3                   	ret    

00001253 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    1253:	55                   	push   %ebp
    1254:	89 e5                	mov    %esp,%ebp
    1256:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    1259:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    1260:	8d 45 0c             	lea    0xc(%ebp),%eax
    1263:	83 c0 04             	add    $0x4,%eax
    1266:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    1269:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1270:	e9 59 01 00 00       	jmp    13ce <printf+0x17b>
    c = fmt[i] & 0xff;
    1275:	8b 55 0c             	mov    0xc(%ebp),%edx
    1278:	8b 45 f0             	mov    -0x10(%ebp),%eax
    127b:	01 d0                	add    %edx,%eax
    127d:	0f b6 00             	movzbl (%eax),%eax
    1280:	0f be c0             	movsbl %al,%eax
    1283:	25 ff 00 00 00       	and    $0xff,%eax
    1288:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    128b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    128f:	75 2c                	jne    12bd <printf+0x6a>
      if(c == '%'){
    1291:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1295:	75 0c                	jne    12a3 <printf+0x50>
        state = '%';
    1297:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    129e:	e9 27 01 00 00       	jmp    13ca <printf+0x177>
      } else {
        putc(fd, c);
    12a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    12a6:	0f be c0             	movsbl %al,%eax
    12a9:	83 ec 08             	sub    $0x8,%esp
    12ac:	50                   	push   %eax
    12ad:	ff 75 08             	pushl  0x8(%ebp)
    12b0:	e8 c7 fe ff ff       	call   117c <putc>
    12b5:	83 c4 10             	add    $0x10,%esp
    12b8:	e9 0d 01 00 00       	jmp    13ca <printf+0x177>
      }
    } else if(state == '%'){
    12bd:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    12c1:	0f 85 03 01 00 00    	jne    13ca <printf+0x177>
      if(c == 'd'){
    12c7:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    12cb:	75 1e                	jne    12eb <printf+0x98>
        printint(fd, *ap, 10, 1);
    12cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
    12d0:	8b 00                	mov    (%eax),%eax
    12d2:	6a 01                	push   $0x1
    12d4:	6a 0a                	push   $0xa
    12d6:	50                   	push   %eax
    12d7:	ff 75 08             	pushl  0x8(%ebp)
    12da:	e8 c0 fe ff ff       	call   119f <printint>
    12df:	83 c4 10             	add    $0x10,%esp
        ap++;
    12e2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    12e6:	e9 d8 00 00 00       	jmp    13c3 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
    12eb:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    12ef:	74 06                	je     12f7 <printf+0xa4>
    12f1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    12f5:	75 1e                	jne    1315 <printf+0xc2>
        printint(fd, *ap, 16, 0);
    12f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
    12fa:	8b 00                	mov    (%eax),%eax
    12fc:	6a 00                	push   $0x0
    12fe:	6a 10                	push   $0x10
    1300:	50                   	push   %eax
    1301:	ff 75 08             	pushl  0x8(%ebp)
    1304:	e8 96 fe ff ff       	call   119f <printint>
    1309:	83 c4 10             	add    $0x10,%esp
        ap++;
    130c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1310:	e9 ae 00 00 00       	jmp    13c3 <printf+0x170>
      } else if(c == 's'){
    1315:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    1319:	75 43                	jne    135e <printf+0x10b>
        s = (char*)*ap;
    131b:	8b 45 e8             	mov    -0x18(%ebp),%eax
    131e:	8b 00                	mov    (%eax),%eax
    1320:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    1323:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    1327:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    132b:	75 25                	jne    1352 <printf+0xff>
          s = "(null)";
    132d:	c7 45 f4 1c 1c 00 00 	movl   $0x1c1c,-0xc(%ebp)
        while(*s != 0){
    1334:	eb 1c                	jmp    1352 <printf+0xff>
          putc(fd, *s);
    1336:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1339:	0f b6 00             	movzbl (%eax),%eax
    133c:	0f be c0             	movsbl %al,%eax
    133f:	83 ec 08             	sub    $0x8,%esp
    1342:	50                   	push   %eax
    1343:	ff 75 08             	pushl  0x8(%ebp)
    1346:	e8 31 fe ff ff       	call   117c <putc>
    134b:	83 c4 10             	add    $0x10,%esp
          s++;
    134e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    1352:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1355:	0f b6 00             	movzbl (%eax),%eax
    1358:	84 c0                	test   %al,%al
    135a:	75 da                	jne    1336 <printf+0xe3>
    135c:	eb 65                	jmp    13c3 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    135e:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    1362:	75 1d                	jne    1381 <printf+0x12e>
        putc(fd, *ap);
    1364:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1367:	8b 00                	mov    (%eax),%eax
    1369:	0f be c0             	movsbl %al,%eax
    136c:	83 ec 08             	sub    $0x8,%esp
    136f:	50                   	push   %eax
    1370:	ff 75 08             	pushl  0x8(%ebp)
    1373:	e8 04 fe ff ff       	call   117c <putc>
    1378:	83 c4 10             	add    $0x10,%esp
        ap++;
    137b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    137f:	eb 42                	jmp    13c3 <printf+0x170>
      } else if(c == '%'){
    1381:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1385:	75 17                	jne    139e <printf+0x14b>
        putc(fd, c);
    1387:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    138a:	0f be c0             	movsbl %al,%eax
    138d:	83 ec 08             	sub    $0x8,%esp
    1390:	50                   	push   %eax
    1391:	ff 75 08             	pushl  0x8(%ebp)
    1394:	e8 e3 fd ff ff       	call   117c <putc>
    1399:	83 c4 10             	add    $0x10,%esp
    139c:	eb 25                	jmp    13c3 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    139e:	83 ec 08             	sub    $0x8,%esp
    13a1:	6a 25                	push   $0x25
    13a3:	ff 75 08             	pushl  0x8(%ebp)
    13a6:	e8 d1 fd ff ff       	call   117c <putc>
    13ab:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
    13ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    13b1:	0f be c0             	movsbl %al,%eax
    13b4:	83 ec 08             	sub    $0x8,%esp
    13b7:	50                   	push   %eax
    13b8:	ff 75 08             	pushl  0x8(%ebp)
    13bb:	e8 bc fd ff ff       	call   117c <putc>
    13c0:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
    13c3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    13ca:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    13ce:	8b 55 0c             	mov    0xc(%ebp),%edx
    13d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
    13d4:	01 d0                	add    %edx,%eax
    13d6:	0f b6 00             	movzbl (%eax),%eax
    13d9:	84 c0                	test   %al,%al
    13db:	0f 85 94 fe ff ff    	jne    1275 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    13e1:	90                   	nop
    13e2:	c9                   	leave  
    13e3:	c3                   	ret    

000013e4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    13e4:	55                   	push   %ebp
    13e5:	89 e5                	mov    %esp,%ebp
    13e7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    13ea:	8b 45 08             	mov    0x8(%ebp),%eax
    13ed:	83 e8 08             	sub    $0x8,%eax
    13f0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    13f3:	a1 30 20 00 00       	mov    0x2030,%eax
    13f8:	89 45 fc             	mov    %eax,-0x4(%ebp)
    13fb:	eb 24                	jmp    1421 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    13fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1400:	8b 00                	mov    (%eax),%eax
    1402:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1405:	77 12                	ja     1419 <free+0x35>
    1407:	8b 45 f8             	mov    -0x8(%ebp),%eax
    140a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    140d:	77 24                	ja     1433 <free+0x4f>
    140f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1412:	8b 00                	mov    (%eax),%eax
    1414:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1417:	77 1a                	ja     1433 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1419:	8b 45 fc             	mov    -0x4(%ebp),%eax
    141c:	8b 00                	mov    (%eax),%eax
    141e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1421:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1424:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1427:	76 d4                	jbe    13fd <free+0x19>
    1429:	8b 45 fc             	mov    -0x4(%ebp),%eax
    142c:	8b 00                	mov    (%eax),%eax
    142e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1431:	76 ca                	jbe    13fd <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    1433:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1436:	8b 40 04             	mov    0x4(%eax),%eax
    1439:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1440:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1443:	01 c2                	add    %eax,%edx
    1445:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1448:	8b 00                	mov    (%eax),%eax
    144a:	39 c2                	cmp    %eax,%edx
    144c:	75 24                	jne    1472 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    144e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1451:	8b 50 04             	mov    0x4(%eax),%edx
    1454:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1457:	8b 00                	mov    (%eax),%eax
    1459:	8b 40 04             	mov    0x4(%eax),%eax
    145c:	01 c2                	add    %eax,%edx
    145e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1461:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    1464:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1467:	8b 00                	mov    (%eax),%eax
    1469:	8b 10                	mov    (%eax),%edx
    146b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    146e:	89 10                	mov    %edx,(%eax)
    1470:	eb 0a                	jmp    147c <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    1472:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1475:	8b 10                	mov    (%eax),%edx
    1477:	8b 45 f8             	mov    -0x8(%ebp),%eax
    147a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    147c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    147f:	8b 40 04             	mov    0x4(%eax),%eax
    1482:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1489:	8b 45 fc             	mov    -0x4(%ebp),%eax
    148c:	01 d0                	add    %edx,%eax
    148e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1491:	75 20                	jne    14b3 <free+0xcf>
    p->s.size += bp->s.size;
    1493:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1496:	8b 50 04             	mov    0x4(%eax),%edx
    1499:	8b 45 f8             	mov    -0x8(%ebp),%eax
    149c:	8b 40 04             	mov    0x4(%eax),%eax
    149f:	01 c2                	add    %eax,%edx
    14a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
    14a4:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    14a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
    14aa:	8b 10                	mov    (%eax),%edx
    14ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
    14af:	89 10                	mov    %edx,(%eax)
    14b1:	eb 08                	jmp    14bb <free+0xd7>
  } else
    p->s.ptr = bp;
    14b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
    14b6:	8b 55 f8             	mov    -0x8(%ebp),%edx
    14b9:	89 10                	mov    %edx,(%eax)
  freep = p;
    14bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
    14be:	a3 30 20 00 00       	mov    %eax,0x2030
}
    14c3:	90                   	nop
    14c4:	c9                   	leave  
    14c5:	c3                   	ret    

000014c6 <morecore>:

static Header*
morecore(uint nu)
{
    14c6:	55                   	push   %ebp
    14c7:	89 e5                	mov    %esp,%ebp
    14c9:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    14cc:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    14d3:	77 07                	ja     14dc <morecore+0x16>
    nu = 4096;
    14d5:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    14dc:	8b 45 08             	mov    0x8(%ebp),%eax
    14df:	c1 e0 03             	shl    $0x3,%eax
    14e2:	83 ec 0c             	sub    $0xc,%esp
    14e5:	50                   	push   %eax
    14e6:	e8 39 fc ff ff       	call   1124 <sbrk>
    14eb:	83 c4 10             	add    $0x10,%esp
    14ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    14f1:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    14f5:	75 07                	jne    14fe <morecore+0x38>
    return 0;
    14f7:	b8 00 00 00 00       	mov    $0x0,%eax
    14fc:	eb 26                	jmp    1524 <morecore+0x5e>
  hp = (Header*)p;
    14fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1501:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    1504:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1507:	8b 55 08             	mov    0x8(%ebp),%edx
    150a:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    150d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1510:	83 c0 08             	add    $0x8,%eax
    1513:	83 ec 0c             	sub    $0xc,%esp
    1516:	50                   	push   %eax
    1517:	e8 c8 fe ff ff       	call   13e4 <free>
    151c:	83 c4 10             	add    $0x10,%esp
  return freep;
    151f:	a1 30 20 00 00       	mov    0x2030,%eax
}
    1524:	c9                   	leave  
    1525:	c3                   	ret    

00001526 <malloc>:

void*
malloc(uint nbytes)
{
    1526:	55                   	push   %ebp
    1527:	89 e5                	mov    %esp,%ebp
    1529:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    152c:	8b 45 08             	mov    0x8(%ebp),%eax
    152f:	83 c0 07             	add    $0x7,%eax
    1532:	c1 e8 03             	shr    $0x3,%eax
    1535:	83 c0 01             	add    $0x1,%eax
    1538:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    153b:	a1 30 20 00 00       	mov    0x2030,%eax
    1540:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1543:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1547:	75 23                	jne    156c <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    1549:	c7 45 f0 28 20 00 00 	movl   $0x2028,-0x10(%ebp)
    1550:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1553:	a3 30 20 00 00       	mov    %eax,0x2030
    1558:	a1 30 20 00 00       	mov    0x2030,%eax
    155d:	a3 28 20 00 00       	mov    %eax,0x2028
    base.s.size = 0;
    1562:	c7 05 2c 20 00 00 00 	movl   $0x0,0x202c
    1569:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    156c:	8b 45 f0             	mov    -0x10(%ebp),%eax
    156f:	8b 00                	mov    (%eax),%eax
    1571:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    1574:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1577:	8b 40 04             	mov    0x4(%eax),%eax
    157a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    157d:	72 4d                	jb     15cc <malloc+0xa6>
      if(p->s.size == nunits)
    157f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1582:	8b 40 04             	mov    0x4(%eax),%eax
    1585:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1588:	75 0c                	jne    1596 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    158a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    158d:	8b 10                	mov    (%eax),%edx
    158f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1592:	89 10                	mov    %edx,(%eax)
    1594:	eb 26                	jmp    15bc <malloc+0x96>
      else {
        p->s.size -= nunits;
    1596:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1599:	8b 40 04             	mov    0x4(%eax),%eax
    159c:	2b 45 ec             	sub    -0x14(%ebp),%eax
    159f:	89 c2                	mov    %eax,%edx
    15a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15a4:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    15a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15aa:	8b 40 04             	mov    0x4(%eax),%eax
    15ad:	c1 e0 03             	shl    $0x3,%eax
    15b0:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    15b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15b6:	8b 55 ec             	mov    -0x14(%ebp),%edx
    15b9:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    15bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15bf:	a3 30 20 00 00       	mov    %eax,0x2030
      return (void*)(p + 1);
    15c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15c7:	83 c0 08             	add    $0x8,%eax
    15ca:	eb 3b                	jmp    1607 <malloc+0xe1>
    }
    if(p == freep)
    15cc:	a1 30 20 00 00       	mov    0x2030,%eax
    15d1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    15d4:	75 1e                	jne    15f4 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
    15d6:	83 ec 0c             	sub    $0xc,%esp
    15d9:	ff 75 ec             	pushl  -0x14(%ebp)
    15dc:	e8 e5 fe ff ff       	call   14c6 <morecore>
    15e1:	83 c4 10             	add    $0x10,%esp
    15e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    15e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    15eb:	75 07                	jne    15f4 <malloc+0xce>
        return 0;
    15ed:	b8 00 00 00 00       	mov    $0x0,%eax
    15f2:	eb 13                	jmp    1607 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    15f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    15fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15fd:	8b 00                	mov    (%eax),%eax
    15ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    1602:	e9 6d ff ff ff       	jmp    1574 <malloc+0x4e>
}
    1607:	c9                   	leave  
    1608:	c3                   	ret    

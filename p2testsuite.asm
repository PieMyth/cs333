
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
       9:	68 44 16 00 00       	push   $0x1644
       e:	6a 01                	push   $0x1
      10:	e8 77 12 00 00       	call   128c <printf>
      15:	83 c4 10             	add    $0x10,%esp
  pid = getpid();
      18:	e8 30 11 00 00       	call   114d <getpid>
      1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ret = fork();
      20:	e8 a0 10 00 00       	call   10c5 <fork>
      25:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(ret == 0){
      28:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
      2c:	75 3e                	jne    6c <testppid+0x6c>
    ppid = getppid();
      2e:	e8 5a 11 00 00       	call   118d <getppid>
      33:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(ppid != pid)
      36:	8b 45 ec             	mov    -0x14(%ebp),%eax
      39:	3b 45 f4             	cmp    -0xc(%ebp),%eax
      3c:	74 17                	je     55 <testppid+0x55>
      printf(2, "FAILED: Parent PID is %d, Child's PPID is %d\n", pid, ppid);
      3e:	ff 75 ec             	pushl  -0x14(%ebp)
      41:	ff 75 f4             	pushl  -0xc(%ebp)
      44:	68 70 16 00 00       	push   $0x1670
      49:	6a 02                	push   $0x2
      4b:	e8 3c 12 00 00       	call   128c <printf>
      50:	83 c4 10             	add    $0x10,%esp
      53:	eb 12                	jmp    67 <testppid+0x67>
    else
      printf(1, "** Test passed! **\n");
      55:	83 ec 08             	sub    $0x8,%esp
      58:	68 9e 16 00 00       	push   $0x169e
      5d:	6a 01                	push   $0x1
      5f:	e8 28 12 00 00       	call   128c <printf>
      64:	83 c4 10             	add    $0x10,%esp
    exit();
      67:	e8 61 10 00 00       	call   10cd <exit>
  }
  else
    wait();
      6c:	e8 64 10 00 00       	call   10d5 <wait>
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
      81:	e8 ff 10 00 00       	call   1185 <getgid>
      86:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ret = setgid(new_val);
      89:	83 ec 0c             	sub    $0xc,%esp
      8c:	ff 75 08             	pushl  0x8(%ebp)
      8f:	e8 09 11 00 00       	call   119d <setgid>
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
      be:	68 b4 16 00 00       	push   $0x16b4
      c3:	6a 02                	push   $0x2
      c5:	e8 c2 11 00 00       	call   128c <printf>
      ca:	83 c4 20             	add    $0x20,%esp
    success = -1;
      cd:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  }
  post_gid = getgid();
      d4:	e8 ac 10 00 00       	call   1185 <getgid>
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
      f3:	68 e4 16 00 00       	push   $0x16e4
      f8:	6a 02                	push   $0x2
      fa:	e8 8d 11 00 00       	call   128c <printf>
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
     11b:	e8 5d 10 00 00       	call   117d <getuid>
     120:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ret = setuid(new_val);
     123:	83 ec 0c             	sub    $0xc,%esp
     126:	ff 75 08             	pushl  0x8(%ebp)
     129:	e8 67 10 00 00       	call   1195 <setuid>
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
     158:	68 30 17 00 00       	push   $0x1730
     15d:	6a 02                	push   $0x2
     15f:	e8 28 11 00 00       	call   128c <printf>
     164:	83 c4 20             	add    $0x20,%esp
    success = -1;
     167:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  }
  post_uid = getuid();
     16e:	e8 0a 10 00 00       	call   117d <getuid>
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
     18d:	68 60 17 00 00       	push   $0x1760
     192:	6a 02                	push   $0x2
     194:	e8 f3 10 00 00       	call   128c <printf>
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
     1b8:	68 ac 17 00 00       	push   $0x17ac
     1bd:	6a 01                	push   $0x1
     1bf:	e8 c8 10 00 00       	call   128c <printf>
     1c4:	83 c4 10             	add    $0x10,%esp
  uid = getuid();
     1c7:	e8 b1 0f 00 00       	call   117d <getuid>
     1cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(uid < 0 || uid > 32767){
     1cf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     1d3:	78 09                	js     1de <testuidgid+0x36>
     1d5:	81 7d f0 ff 7f 00 00 	cmpl   $0x7fff,-0x10(%ebp)
     1dc:	7e 1c                	jle    1fa <testuidgid+0x52>
    printf(1, "FAILED: Default UID %d, out of range\n", uid);
     1de:	83 ec 04             	sub    $0x4,%esp
     1e1:	ff 75 f0             	pushl  -0x10(%ebp)
     1e4:	68 dc 17 00 00       	push   $0x17dc
     1e9:	6a 01                	push   $0x1
     1eb:	e8 9c 10 00 00       	call   128c <printf>
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
     295:	e8 eb 0e 00 00       	call   1185 <getgid>
     29a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(gid < 0 || gid > 32767){
     29d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     2a1:	78 09                	js     2ac <testuidgid+0x104>
     2a3:	81 7d ec ff 7f 00 00 	cmpl   $0x7fff,-0x14(%ebp)
     2aa:	7e 1c                	jle    2c8 <testuidgid+0x120>
    printf(1, "FAILED: Default GID %d, out of range\n", gid);
     2ac:	83 ec 04             	sub    $0x4,%esp
     2af:	ff 75 ec             	pushl  -0x14(%ebp)
     2b2:	68 04 18 00 00       	push   $0x1804
     2b7:	6a 01                	push   $0x1
     2b9:	e8 ce 0f 00 00       	call   128c <printf>
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
     36c:	68 2a 18 00 00       	push   $0x182a
     371:	6a 01                	push   $0x1
     373:	e8 14 0f 00 00       	call   128c <printf>
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
     38e:	68 44 18 00 00       	push   $0x1844
     393:	6a 01                	push   $0x1
     395:	e8 f2 0e 00 00       	call   128c <printf>
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
     3e7:	e8 d9 0c 00 00       	call   10c5 <fork>
     3ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(ret == 0){
     3ef:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     3f3:	75 67                	jne    45c <testuidgidinheritance+0xde>
    uid = getuid();
     3f5:	e8 83 0d 00 00       	call   117d <getuid>
     3fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
    gid = getgid();
     3fd:	e8 83 0d 00 00       	call   1185 <getgid>
     402:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(uid != 12345){
     405:	81 7d ec 39 30 00 00 	cmpl   $0x3039,-0x14(%ebp)
     40c:	74 17                	je     425 <testuidgidinheritance+0xa7>
      printf(2, "FAILED: Parent UID is 12345, child UID is %d\n", uid);
     40e:	83 ec 04             	sub    $0x4,%esp
     411:	ff 75 ec             	pushl  -0x14(%ebp)
     414:	68 80 18 00 00       	push   $0x1880
     419:	6a 02                	push   $0x2
     41b:	e8 6c 0e 00 00       	call   128c <printf>
     420:	83 c4 10             	add    $0x10,%esp
     423:	eb 32                	jmp    457 <testuidgidinheritance+0xd9>
    }
    else if(gid != 12345){
     425:	81 7d e8 39 30 00 00 	cmpl   $0x3039,-0x18(%ebp)
     42c:	74 17                	je     445 <testuidgidinheritance+0xc7>
      printf(2, "FAILED: Parent GID is 12345, child GID is %d\n", gid);
     42e:	83 ec 04             	sub    $0x4,%esp
     431:	ff 75 e8             	pushl  -0x18(%ebp)
     434:	68 b0 18 00 00       	push   $0x18b0
     439:	6a 02                	push   $0x2
     43b:	e8 4c 0e 00 00       	call   128c <printf>
     440:	83 c4 10             	add    $0x10,%esp
     443:	eb 12                	jmp    457 <testuidgidinheritance+0xd9>
    }
    else
      printf(1, "** Test Passed! **\n");
     445:	83 ec 08             	sub    $0x8,%esp
     448:	68 de 18 00 00       	push   $0x18de
     44d:	6a 01                	push   $0x1
     44f:	e8 38 0e 00 00       	call   128c <printf>
     454:	83 c4 10             	add    $0x10,%esp
    exit();
     457:	e8 71 0c 00 00       	call   10cd <exit>
  }
  else {
    wait();
     45c:	e8 74 0c 00 00       	call   10d5 <wait>
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
     47b:	e8 25 0d 00 00       	call   11a5 <getprocs>
     480:	83 c4 10             	add    $0x10,%esp
     483:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(int i = 0; i < size; ++i){
     486:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     48d:	eb 45                	jmp    4d4 <getcputime+0x6e>
    if(strcmp(table[i].name, name) == 0){
     48f:	8b 55 f0             	mov    -0x10(%ebp),%edx
     492:	89 d0                	mov    %edx,%eax
     494:	01 c0                	add    %eax,%eax
     496:	01 d0                	add    %edx,%eax
     498:	c1 e0 05             	shl    $0x5,%eax
     49b:	89 c2                	mov    %eax,%edx
     49d:	8b 45 0c             	mov    0xc(%ebp),%eax
     4a0:	01 d0                	add    %edx,%eax
     4a2:	83 c0 3c             	add    $0x3c,%eax
     4a5:	83 ec 08             	sub    $0x8,%esp
     4a8:	ff 75 08             	pushl  0x8(%ebp)
     4ab:	50                   	push   %eax
     4ac:	e8 48 09 00 00       	call   df9 <strcmp>
     4b1:	83 c4 10             	add    $0x10,%esp
     4b4:	85 c0                	test   %eax,%eax
     4b6:	75 18                	jne    4d0 <getcputime+0x6a>
      p = table + i;
     4b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
     4bb:	89 d0                	mov    %edx,%eax
     4bd:	01 c0                	add    %eax,%eax
     4bf:	01 d0                	add    %edx,%eax
     4c1:	c1 e0 05             	shl    $0x5,%eax
     4c4:	89 c2                	mov    %eax,%edx
     4c6:	8b 45 0c             	mov    0xc(%ebp),%eax
     4c9:	01 d0                	add    %edx,%eax
     4cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
      break;
     4ce:	eb 0c                	jmp    4dc <getcputime+0x76>
getcputime(char * name, struct uproc * table){
  struct uproc *p = 0;
  int size;

  size = getprocs(64, table);
  for(int i = 0; i < size; ++i){
     4d0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
     4d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
     4d7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
     4da:	7c b3                	jl     48f <getcputime+0x29>
    if(strcmp(table[i].name, name) == 0){
      p = table + i;
      break;
    }
  }
  if(p == 0){
     4dc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     4e0:	75 1c                	jne    4fe <getcputime+0x98>
    printf(2, "FAILED: Test program \"%s\" not found in table returned by getprocs\n", name);
     4e2:	83 ec 04             	sub    $0x4,%esp
     4e5:	ff 75 08             	pushl  0x8(%ebp)
     4e8:	68 f4 18 00 00       	push   $0x18f4
     4ed:	6a 02                	push   $0x2
     4ef:	e8 98 0d 00 00       	call   128c <printf>
     4f4:	83 c4 10             	add    $0x10,%esp
    return -1;
     4f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     4fc:	eb 06                	jmp    504 <getcputime+0x9e>
  }
  else
    return p->CPU_total_ticks;
     4fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
     501:	8b 40 14             	mov    0x14(%eax),%eax
}
     504:	c9                   	leave  
     505:	c3                   	ret    

00000506 <testcputime>:

static void
testcputime(char * name){
     506:	55                   	push   %ebp
     507:	89 e5                	mov    %esp,%ebp
     509:	83 ec 28             	sub    $0x28,%esp
  struct uproc *table;
  uint time1, time2, pre_sleep, post_sleep;
  int success = 0;
     50c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  int i, num;

  printf(1, "\n----------\nRunning CPU Time Test\n----------\n");
     513:	83 ec 08             	sub    $0x8,%esp
     516:	68 38 19 00 00       	push   $0x1938
     51b:	6a 01                	push   $0x1
     51d:	e8 6a 0d 00 00       	call   128c <printf>
     522:	83 c4 10             	add    $0x10,%esp
  table = malloc(sizeof(struct uproc) * 64);
     525:	83 ec 0c             	sub    $0xc,%esp
     528:	68 00 18 00 00       	push   $0x1800
     52d:	e8 2d 10 00 00       	call   155f <malloc>
     532:	83 c4 10             	add    $0x10,%esp
     535:	89 45 e8             	mov    %eax,-0x18(%ebp)
  printf(1, "This will take a couple seconds\n");
     538:	83 ec 08             	sub    $0x8,%esp
     53b:	68 68 19 00 00       	push   $0x1968
     540:	6a 01                	push   $0x1
     542:	e8 45 0d 00 00       	call   128c <printf>
     547:	83 c4 10             	add    $0x10,%esp

  // Loop for a long time to see if the elapsed CPU_total_ticks is in a reasonable range
  time1 = getcputime(name, table);
     54a:	83 ec 08             	sub    $0x8,%esp
     54d:	ff 75 e8             	pushl  -0x18(%ebp)
     550:	ff 75 08             	pushl  0x8(%ebp)
     553:	e8 0e ff ff ff       	call   466 <getcputime>
     558:	83 c4 10             	add    $0x10,%esp
     55b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  for(i = 0, num = 0; i < 1000000; ++i){
     55e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     565:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
     56c:	e9 8a 00 00 00       	jmp    5fb <testcputime+0xf5>
    ++num;
     571:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
    if(num % 100000 == 0){
     575:	8b 4d ec             	mov    -0x14(%ebp),%ecx
     578:	ba 89 b5 f8 14       	mov    $0x14f8b589,%edx
     57d:	89 c8                	mov    %ecx,%eax
     57f:	f7 ea                	imul   %edx
     581:	c1 fa 0d             	sar    $0xd,%edx
     584:	89 c8                	mov    %ecx,%eax
     586:	c1 f8 1f             	sar    $0x1f,%eax
     589:	29 c2                	sub    %eax,%edx
     58b:	89 d0                	mov    %edx,%eax
     58d:	69 c0 a0 86 01 00    	imul   $0x186a0,%eax,%eax
     593:	29 c1                	sub    %eax,%ecx
     595:	89 c8                	mov    %ecx,%eax
     597:	85 c0                	test   %eax,%eax
     599:	75 5c                	jne    5f7 <testcputime+0xf1>
      pre_sleep = getcputime(name, table);
     59b:	83 ec 08             	sub    $0x8,%esp
     59e:	ff 75 e8             	pushl  -0x18(%ebp)
     5a1:	ff 75 08             	pushl  0x8(%ebp)
     5a4:	e8 bd fe ff ff       	call   466 <getcputime>
     5a9:	83 c4 10             	add    $0x10,%esp
     5ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
      sleep(200);
     5af:	83 ec 0c             	sub    $0xc,%esp
     5b2:	68 c8 00 00 00       	push   $0xc8
     5b7:	e8 a1 0b 00 00       	call   115d <sleep>
     5bc:	83 c4 10             	add    $0x10,%esp
      post_sleep = getcputime(name, table);
     5bf:	83 ec 08             	sub    $0x8,%esp
     5c2:	ff 75 e8             	pushl  -0x18(%ebp)
     5c5:	ff 75 08             	pushl  0x8(%ebp)
     5c8:	e8 99 fe ff ff       	call   466 <getcputime>
     5cd:	83 c4 10             	add    $0x10,%esp
     5d0:	89 45 dc             	mov    %eax,-0x24(%ebp)
      if((post_sleep - pre_sleep) >= 100){
     5d3:	8b 45 dc             	mov    -0x24(%ebp),%eax
     5d6:	2b 45 e0             	sub    -0x20(%ebp),%eax
     5d9:	83 f8 63             	cmp    $0x63,%eax
     5dc:	76 19                	jbe    5f7 <testcputime+0xf1>
        printf(2, "FAILED: CPU_total_ticks changed by 100+ milliseconds while process was asleep\n");
     5de:	83 ec 08             	sub    $0x8,%esp
     5e1:	68 8c 19 00 00       	push   $0x198c
     5e6:	6a 02                	push   $0x2
     5e8:	e8 9f 0c 00 00       	call   128c <printf>
     5ed:	83 c4 10             	add    $0x10,%esp
        success = -1;
     5f0:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  table = malloc(sizeof(struct uproc) * 64);
  printf(1, "This will take a couple seconds\n");

  // Loop for a long time to see if the elapsed CPU_total_ticks is in a reasonable range
  time1 = getcputime(name, table);
  for(i = 0, num = 0; i < 1000000; ++i){
     5f7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
     5fb:	81 7d f0 3f 42 0f 00 	cmpl   $0xf423f,-0x10(%ebp)
     602:	0f 8e 69 ff ff ff    	jle    571 <testcputime+0x6b>
        printf(2, "FAILED: CPU_total_ticks changed by 100+ milliseconds while process was asleep\n");
        success = -1;
      }
    }
  }
  time2 = getcputime(name, table);
     608:	83 ec 08             	sub    $0x8,%esp
     60b:	ff 75 e8             	pushl  -0x18(%ebp)
     60e:	ff 75 08             	pushl  0x8(%ebp)
     611:	e8 50 fe ff ff       	call   466 <getcputime>
     616:	83 c4 10             	add    $0x10,%esp
     619:	89 45 d8             	mov    %eax,-0x28(%ebp)
  if((time2 - time1) < 0){
    printf(2, "FAILED: difference in CPU_total_ticks is negative.  T2 - T1 = %d\n", (time2 - time1));
    success = -1;
  }
  if((time2 - time1) > 400){
     61c:	8b 45 d8             	mov    -0x28(%ebp),%eax
     61f:	2b 45 e4             	sub    -0x1c(%ebp),%eax
     622:	3d 90 01 00 00       	cmp    $0x190,%eax
     627:	76 20                	jbe    649 <testcputime+0x143>
    printf(2, "ABNORMALLY HIGH: T2 - T1 = %d milliseconds.  Run test again\n", (time2 - time1));
     629:	8b 45 d8             	mov    -0x28(%ebp),%eax
     62c:	2b 45 e4             	sub    -0x1c(%ebp),%eax
     62f:	83 ec 04             	sub    $0x4,%esp
     632:	50                   	push   %eax
     633:	68 dc 19 00 00       	push   $0x19dc
     638:	6a 02                	push   $0x2
     63a:	e8 4d 0c 00 00       	call   128c <printf>
     63f:	83 c4 10             	add    $0x10,%esp
    success = -1;
     642:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  }
  printf(1, "T2 - T1 = %d milliseconds\n", (time2 - time1));
     649:	8b 45 d8             	mov    -0x28(%ebp),%eax
     64c:	2b 45 e4             	sub    -0x1c(%ebp),%eax
     64f:	83 ec 04             	sub    $0x4,%esp
     652:	50                   	push   %eax
     653:	68 19 1a 00 00       	push   $0x1a19
     658:	6a 01                	push   $0x1
     65a:	e8 2d 0c 00 00       	call   128c <printf>
     65f:	83 c4 10             	add    $0x10,%esp
  free(table);
     662:	83 ec 0c             	sub    $0xc,%esp
     665:	ff 75 e8             	pushl  -0x18(%ebp)
     668:	e8 b0 0d 00 00       	call   141d <free>
     66d:	83 c4 10             	add    $0x10,%esp

  if(success == 0)
     670:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     674:	75 12                	jne    688 <testcputime+0x182>
    printf(1, "** All Tests Passed! **\n");
     676:	83 ec 08             	sub    $0x8,%esp
     679:	68 34 1a 00 00       	push   $0x1a34
     67e:	6a 01                	push   $0x1
     680:	e8 07 0c 00 00       	call   128c <printf>
     685:	83 c4 10             	add    $0x10,%esp
}
     688:	90                   	nop
     689:	c9                   	leave  
     68a:	c3                   	ret    

0000068b <testprocarray>:

#ifdef GETPROCS_TEST
// Fork to 64 process and then make sure we get all when passing table array
// of sizes 1, 16, 64, 72
static int
testprocarray(int max, int expected_ret, char * name){
     68b:	55                   	push   %ebp
     68c:	89 e5                	mov    %esp,%ebp
     68e:	83 ec 28             	sub    $0x28,%esp
  struct uproc * table;
  int ret, success, num_init, num_sh, num_this;
  success = num_init = num_sh = num_this = 0;
     691:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
     698:	8b 45 e8             	mov    -0x18(%ebp),%eax
     69b:	89 45 ec             	mov    %eax,-0x14(%ebp)
     69e:	8b 45 ec             	mov    -0x14(%ebp),%eax
     6a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
     6a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
     6a7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  table = malloc(sizeof(struct uproc) * max);
     6aa:	8b 55 08             	mov    0x8(%ebp),%edx
     6ad:	89 d0                	mov    %edx,%eax
     6af:	01 c0                	add    %eax,%eax
     6b1:	01 d0                	add    %edx,%eax
     6b3:	c1 e0 05             	shl    $0x5,%eax
     6b6:	83 ec 0c             	sub    $0xc,%esp
     6b9:	50                   	push   %eax
     6ba:	e8 a0 0e 00 00       	call   155f <malloc>
     6bf:	83 c4 10             	add    $0x10,%esp
     6c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  ret = getprocs(max, table);
     6c5:	8b 45 08             	mov    0x8(%ebp),%eax
     6c8:	83 ec 08             	sub    $0x8,%esp
     6cb:	ff 75 e0             	pushl  -0x20(%ebp)
     6ce:	50                   	push   %eax
     6cf:	e8 d1 0a 00 00       	call   11a5 <getprocs>
     6d4:	83 c4 10             	add    $0x10,%esp
     6d7:	89 45 dc             	mov    %eax,-0x24(%ebp)
  for (int i = 0; i < ret; ++i){
     6da:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     6e1:	e9 93 00 00 00       	jmp    779 <testprocarray+0xee>
    if(strcmp(table[i].name, "init") == 0)
     6e6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
     6e9:	89 d0                	mov    %edx,%eax
     6eb:	01 c0                	add    %eax,%eax
     6ed:	01 d0                	add    %edx,%eax
     6ef:	c1 e0 05             	shl    $0x5,%eax
     6f2:	89 c2                	mov    %eax,%edx
     6f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
     6f7:	01 d0                	add    %edx,%eax
     6f9:	83 c0 3c             	add    $0x3c,%eax
     6fc:	83 ec 08             	sub    $0x8,%esp
     6ff:	68 4d 1a 00 00       	push   $0x1a4d
     704:	50                   	push   %eax
     705:	e8 ef 06 00 00       	call   df9 <strcmp>
     70a:	83 c4 10             	add    $0x10,%esp
     70d:	85 c0                	test   %eax,%eax
     70f:	75 06                	jne    717 <testprocarray+0x8c>
      ++num_init;
     711:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
     715:	eb 5e                	jmp    775 <testprocarray+0xea>
    else if(strcmp(table[i].name, "sh") == 0)
     717:	8b 55 e4             	mov    -0x1c(%ebp),%edx
     71a:	89 d0                	mov    %edx,%eax
     71c:	01 c0                	add    %eax,%eax
     71e:	01 d0                	add    %edx,%eax
     720:	c1 e0 05             	shl    $0x5,%eax
     723:	89 c2                	mov    %eax,%edx
     725:	8b 45 e0             	mov    -0x20(%ebp),%eax
     728:	01 d0                	add    %edx,%eax
     72a:	83 c0 3c             	add    $0x3c,%eax
     72d:	83 ec 08             	sub    $0x8,%esp
     730:	68 52 1a 00 00       	push   $0x1a52
     735:	50                   	push   %eax
     736:	e8 be 06 00 00       	call   df9 <strcmp>
     73b:	83 c4 10             	add    $0x10,%esp
     73e:	85 c0                	test   %eax,%eax
     740:	75 06                	jne    748 <testprocarray+0xbd>
      ++num_sh;
     742:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
     746:	eb 2d                	jmp    775 <testprocarray+0xea>
    else if(strcmp(table[i].name, name) == 0)
     748:	8b 55 e4             	mov    -0x1c(%ebp),%edx
     74b:	89 d0                	mov    %edx,%eax
     74d:	01 c0                	add    %eax,%eax
     74f:	01 d0                	add    %edx,%eax
     751:	c1 e0 05             	shl    $0x5,%eax
     754:	89 c2                	mov    %eax,%edx
     756:	8b 45 e0             	mov    -0x20(%ebp),%eax
     759:	01 d0                	add    %edx,%eax
     75b:	83 c0 3c             	add    $0x3c,%eax
     75e:	83 ec 08             	sub    $0x8,%esp
     761:	ff 75 10             	pushl  0x10(%ebp)
     764:	50                   	push   %eax
     765:	e8 8f 06 00 00       	call   df9 <strcmp>
     76a:	83 c4 10             	add    $0x10,%esp
     76d:	85 c0                	test   %eax,%eax
     76f:	75 04                	jne    775 <testprocarray+0xea>
      ++num_this;
     771:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
  int ret, success, num_init, num_sh, num_this;
  success = num_init = num_sh = num_this = 0;

  table = malloc(sizeof(struct uproc) * max);
  ret = getprocs(max, table);
  for (int i = 0; i < ret; ++i){
     775:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
     779:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     77c:	3b 45 dc             	cmp    -0x24(%ebp),%eax
     77f:	0f 8c 61 ff ff ff    	jl     6e6 <testprocarray+0x5b>
    else if(strcmp(table[i].name, "sh") == 0)
      ++num_sh;
    else if(strcmp(table[i].name, name) == 0)
      ++num_this;
  }
  if (ret != expected_ret){
     785:	8b 45 dc             	mov    -0x24(%ebp),%eax
     788:	3b 45 0c             	cmp    0xc(%ebp),%eax
     78b:	74 24                	je     7b1 <testprocarray+0x126>
    printf(2, "FAILED: getprocs(%d) returned %d, expected %d\n", max, ret, expected_ret);
     78d:	83 ec 0c             	sub    $0xc,%esp
     790:	ff 75 0c             	pushl  0xc(%ebp)
     793:	ff 75 dc             	pushl  -0x24(%ebp)
     796:	ff 75 08             	pushl  0x8(%ebp)
     799:	68 58 1a 00 00       	push   $0x1a58
     79e:	6a 02                	push   $0x2
     7a0:	e8 e7 0a 00 00       	call   128c <printf>
     7a5:	83 c4 20             	add    $0x20,%esp
    success = -1;
     7a8:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
     7af:	eb 21                	jmp    7d2 <testprocarray+0x147>
  }
  else{
    printf(1, "getprocs(%d), found %d processes with names(qty), \"init\"(%d), \"sh\"(%d), \"%s\"(%d)\n",
     7b1:	ff 75 e8             	pushl  -0x18(%ebp)
     7b4:	ff 75 10             	pushl  0x10(%ebp)
     7b7:	ff 75 ec             	pushl  -0x14(%ebp)
     7ba:	ff 75 f0             	pushl  -0x10(%ebp)
     7bd:	ff 75 dc             	pushl  -0x24(%ebp)
     7c0:	ff 75 08             	pushl  0x8(%ebp)
     7c3:	68 88 1a 00 00       	push   $0x1a88
     7c8:	6a 01                	push   $0x1
     7ca:	e8 bd 0a 00 00       	call   128c <printf>
     7cf:	83 c4 20             	add    $0x20,%esp
            max, ret, num_init, num_sh, name, num_this);
  }
  free(table);
     7d2:	83 ec 0c             	sub    $0xc,%esp
     7d5:	ff 75 e0             	pushl  -0x20(%ebp)
     7d8:	e8 40 0c 00 00       	call   141d <free>
     7dd:	83 c4 10             	add    $0x10,%esp
  return success;
     7e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     7e3:	c9                   	leave  
     7e4:	c3                   	ret    

000007e5 <testinvalidarray>:

static int
testinvalidarray(void){
     7e5:	55                   	push   %ebp
     7e6:	89 e5                	mov    %esp,%ebp
     7e8:	83 ec 18             	sub    $0x18,%esp
  struct uproc * table;
  int ret;

  table = malloc(sizeof(struct uproc));
     7eb:	83 ec 0c             	sub    $0xc,%esp
     7ee:	6a 60                	push   $0x60
     7f0:	e8 6a 0d 00 00       	call   155f <malloc>
     7f5:	83 c4 10             	add    $0x10,%esp
     7f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ret = getprocs(1024, table);
     7fb:	83 ec 08             	sub    $0x8,%esp
     7fe:	ff 75 f4             	pushl  -0xc(%ebp)
     801:	68 00 04 00 00       	push   $0x400
     806:	e8 9a 09 00 00       	call   11a5 <getprocs>
     80b:	83 c4 10             	add    $0x10,%esp
     80e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  free(table);
     811:	83 ec 0c             	sub    $0xc,%esp
     814:	ff 75 f4             	pushl  -0xc(%ebp)
     817:	e8 01 0c 00 00       	call   141d <free>
     81c:	83 c4 10             	add    $0x10,%esp
  if(ret >= 0){
     81f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     823:	78 1c                	js     841 <testinvalidarray+0x5c>
    printf(2, "FAILED: called getprocs with max way larger than table and returned %d, not error\n", ret);
     825:	83 ec 04             	sub    $0x4,%esp
     828:	ff 75 f0             	pushl  -0x10(%ebp)
     82b:	68 dc 1a 00 00       	push   $0x1adc
     830:	6a 02                	push   $0x2
     832:	e8 55 0a 00 00       	call   128c <printf>
     837:	83 c4 10             	add    $0x10,%esp
    return -1;
     83a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     83f:	eb 05                	jmp    846 <testinvalidarray+0x61>
  }
  return 0;
     841:	b8 00 00 00 00       	mov    $0x0,%eax
}
     846:	c9                   	leave  
     847:	c3                   	ret    

00000848 <testgetprocs>:

static void
testgetprocs(char * name){
     848:	55                   	push   %ebp
     849:	89 e5                	mov    %esp,%ebp
     84b:	83 ec 18             	sub    $0x18,%esp
  int ret, success;

  printf(1, "\n----------\nRunning GetProcs Test\n----------\n");
     84e:	83 ec 08             	sub    $0x8,%esp
     851:	68 30 1b 00 00       	push   $0x1b30
     856:	6a 01                	push   $0x1
     858:	e8 2f 0a 00 00       	call   128c <printf>
     85d:	83 c4 10             	add    $0x10,%esp
  // Fork until no space left in ptable
  ret = fork();
     860:	e8 60 08 00 00       	call   10c5 <fork>
     865:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if (ret == 0){
     868:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     86c:	0f 85 c6 00 00 00    	jne    938 <testgetprocs+0xf0>
    while((ret = fork()) == 0);
     872:	e8 4e 08 00 00       	call   10c5 <fork>
     877:	89 45 f0             	mov    %eax,-0x10(%ebp)
     87a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     87e:	74 f2                	je     872 <testgetprocs+0x2a>
    if(ret > 0){
     880:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     884:	7e 0a                	jle    890 <testgetprocs+0x48>
      wait();
     886:	e8 4a 08 00 00       	call   10d5 <wait>
      exit();
     88b:	e8 3d 08 00 00       	call   10cd <exit>
    }
    // Only return left is -1, which is no space left in ptable
    success = 0;
     890:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(testinvalidarray())
     897:	e8 49 ff ff ff       	call   7e5 <testinvalidarray>
     89c:	85 c0                	test   %eax,%eax
     89e:	74 07                	je     8a7 <testgetprocs+0x5f>
      success = -1;
     8a0:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
    if(testprocarray(1, 1, name))
     8a7:	83 ec 04             	sub    $0x4,%esp
     8aa:	ff 75 08             	pushl  0x8(%ebp)
     8ad:	6a 01                	push   $0x1
     8af:	6a 01                	push   $0x1
     8b1:	e8 d5 fd ff ff       	call   68b <testprocarray>
     8b6:	83 c4 10             	add    $0x10,%esp
     8b9:	85 c0                	test   %eax,%eax
     8bb:	74 07                	je     8c4 <testgetprocs+0x7c>
      success = -1;
     8bd:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
    if(testprocarray(16, 16, name))
     8c4:	83 ec 04             	sub    $0x4,%esp
     8c7:	ff 75 08             	pushl  0x8(%ebp)
     8ca:	6a 10                	push   $0x10
     8cc:	6a 10                	push   $0x10
     8ce:	e8 b8 fd ff ff       	call   68b <testprocarray>
     8d3:	83 c4 10             	add    $0x10,%esp
     8d6:	85 c0                	test   %eax,%eax
     8d8:	74 07                	je     8e1 <testgetprocs+0x99>
      success = -1;
     8da:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
    if(testprocarray(64, 64, name))
     8e1:	83 ec 04             	sub    $0x4,%esp
     8e4:	ff 75 08             	pushl  0x8(%ebp)
     8e7:	6a 40                	push   $0x40
     8e9:	6a 40                	push   $0x40
     8eb:	e8 9b fd ff ff       	call   68b <testprocarray>
     8f0:	83 c4 10             	add    $0x10,%esp
     8f3:	85 c0                	test   %eax,%eax
     8f5:	74 07                	je     8fe <testgetprocs+0xb6>
      success = -1;
     8f7:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
    if(testprocarray(72, 64, name))
     8fe:	83 ec 04             	sub    $0x4,%esp
     901:	ff 75 08             	pushl  0x8(%ebp)
     904:	6a 40                	push   $0x40
     906:	6a 48                	push   $0x48
     908:	e8 7e fd ff ff       	call   68b <testprocarray>
     90d:	83 c4 10             	add    $0x10,%esp
     910:	85 c0                	test   %eax,%eax
     912:	74 07                	je     91b <testgetprocs+0xd3>
      success = -1;
     914:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
    if (success == 0)
     91b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     91f:	75 12                	jne    933 <testgetprocs+0xeb>
      printf(1, "** All Tests Passed **\n");
     921:	83 ec 08             	sub    $0x8,%esp
     924:	68 5e 1b 00 00       	push   $0x1b5e
     929:	6a 01                	push   $0x1
     92b:	e8 5c 09 00 00       	call   128c <printf>
     930:	83 c4 10             	add    $0x10,%esp
    exit();
     933:	e8 95 07 00 00       	call   10cd <exit>
  }
  wait();
     938:	e8 98 07 00 00       	call   10d5 <wait>
}
     93d:	90                   	nop
     93e:	c9                   	leave  
     93f:	c3                   	ret    

00000940 <testtimewitharg>:
#endif

#ifdef TIME_TEST
// Forks a process and execs with time + args to see how it handles no args, invalid args, mulitple args
void
testtimewitharg(char **arg){
     940:	55                   	push   %ebp
     941:	89 e5                	mov    %esp,%ebp
     943:	83 ec 18             	sub    $0x18,%esp
  int ret;

  ret = fork();
     946:	e8 7a 07 00 00       	call   10c5 <fork>
     94b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (ret == 0){
     94e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     952:	75 31                	jne    985 <testtimewitharg+0x45>
    exec(arg[0], arg);
     954:	8b 45 08             	mov    0x8(%ebp),%eax
     957:	8b 00                	mov    (%eax),%eax
     959:	83 ec 08             	sub    $0x8,%esp
     95c:	ff 75 08             	pushl  0x8(%ebp)
     95f:	50                   	push   %eax
     960:	e8 a0 07 00 00       	call   1105 <exec>
     965:	83 c4 10             	add    $0x10,%esp
    printf(2, "FAILED: exec failed to execute %s\n", arg[0]);
     968:	8b 45 08             	mov    0x8(%ebp),%eax
     96b:	8b 00                	mov    (%eax),%eax
     96d:	83 ec 04             	sub    $0x4,%esp
     970:	50                   	push   %eax
     971:	68 78 1b 00 00       	push   $0x1b78
     976:	6a 02                	push   $0x2
     978:	e8 0f 09 00 00       	call   128c <printf>
     97d:	83 c4 10             	add    $0x10,%esp
    exit();
     980:	e8 48 07 00 00       	call   10cd <exit>
  }
  else if(ret == -1){
     985:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
     989:	75 14                	jne    99f <testtimewitharg+0x5f>
    printf(2, "FAILED: fork failed\n");
     98b:	83 ec 08             	sub    $0x8,%esp
     98e:	68 9b 1b 00 00       	push   $0x1b9b
     993:	6a 02                	push   $0x2
     995:	e8 f2 08 00 00       	call   128c <printf>
     99a:	83 c4 10             	add    $0x10,%esp
  }
  else
    wait();
}
     99d:	eb 05                	jmp    9a4 <testtimewitharg+0x64>
  }
  else if(ret == -1){
    printf(2, "FAILED: fork failed\n");
  }
  else
    wait();
     99f:	e8 31 07 00 00       	call   10d5 <wait>
}
     9a4:	90                   	nop
     9a5:	c9                   	leave  
     9a6:	c3                   	ret    

000009a7 <testtime>:
void
testtime(void){
     9a7:	55                   	push   %ebp
     9a8:	89 e5                	mov    %esp,%ebp
     9aa:	53                   	push   %ebx
     9ab:	83 ec 14             	sub    $0x14,%esp
  char **arg1 = malloc(sizeof(char *));
     9ae:	83 ec 0c             	sub    $0xc,%esp
     9b1:	6a 04                	push   $0x4
     9b3:	e8 a7 0b 00 00       	call   155f <malloc>
     9b8:	83 c4 10             	add    $0x10,%esp
     9bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  char **arg2 = malloc(sizeof(char *)*2);
     9be:	83 ec 0c             	sub    $0xc,%esp
     9c1:	6a 08                	push   $0x8
     9c3:	e8 97 0b 00 00       	call   155f <malloc>
     9c8:	83 c4 10             	add    $0x10,%esp
     9cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char **arg3 = malloc(sizeof(char *)*2);
     9ce:	83 ec 0c             	sub    $0xc,%esp
     9d1:	6a 08                	push   $0x8
     9d3:	e8 87 0b 00 00       	call   155f <malloc>
     9d8:	83 c4 10             	add    $0x10,%esp
     9db:	89 45 ec             	mov    %eax,-0x14(%ebp)
  char **arg4 = malloc(sizeof(char *)*4);
     9de:	83 ec 0c             	sub    $0xc,%esp
     9e1:	6a 10                	push   $0x10
     9e3:	e8 77 0b 00 00       	call   155f <malloc>
     9e8:	83 c4 10             	add    $0x10,%esp
     9eb:	89 45 e8             	mov    %eax,-0x18(%ebp)

  arg1[0] = malloc(sizeof(char) * 5);
     9ee:	83 ec 0c             	sub    $0xc,%esp
     9f1:	6a 05                	push   $0x5
     9f3:	e8 67 0b 00 00       	call   155f <malloc>
     9f8:	83 c4 10             	add    $0x10,%esp
     9fb:	89 c2                	mov    %eax,%edx
     9fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
     a00:	89 10                	mov    %edx,(%eax)
  strcpy(arg1[0], "time");
     a02:	8b 45 f4             	mov    -0xc(%ebp),%eax
     a05:	8b 00                	mov    (%eax),%eax
     a07:	83 ec 08             	sub    $0x8,%esp
     a0a:	68 b0 1b 00 00       	push   $0x1bb0
     a0f:	50                   	push   %eax
     a10:	e8 b4 03 00 00       	call   dc9 <strcpy>
     a15:	83 c4 10             	add    $0x10,%esp

  arg2[0] = malloc(sizeof(char) * 5);
     a18:	83 ec 0c             	sub    $0xc,%esp
     a1b:	6a 05                	push   $0x5
     a1d:	e8 3d 0b 00 00       	call   155f <malloc>
     a22:	83 c4 10             	add    $0x10,%esp
     a25:	89 c2                	mov    %eax,%edx
     a27:	8b 45 f0             	mov    -0x10(%ebp),%eax
     a2a:	89 10                	mov    %edx,(%eax)
  strcpy(arg2[0], "time");
     a2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
     a2f:	8b 00                	mov    (%eax),%eax
     a31:	83 ec 08             	sub    $0x8,%esp
     a34:	68 b0 1b 00 00       	push   $0x1bb0
     a39:	50                   	push   %eax
     a3a:	e8 8a 03 00 00       	call   dc9 <strcpy>
     a3f:	83 c4 10             	add    $0x10,%esp
  arg2[1] = malloc(sizeof(char) * 4);
     a42:	8b 45 f0             	mov    -0x10(%ebp),%eax
     a45:	8d 58 04             	lea    0x4(%eax),%ebx
     a48:	83 ec 0c             	sub    $0xc,%esp
     a4b:	6a 04                	push   $0x4
     a4d:	e8 0d 0b 00 00       	call   155f <malloc>
     a52:	83 c4 10             	add    $0x10,%esp
     a55:	89 03                	mov    %eax,(%ebx)
  strcpy(arg2[1], "abc");
     a57:	8b 45 f0             	mov    -0x10(%ebp),%eax
     a5a:	83 c0 04             	add    $0x4,%eax
     a5d:	8b 00                	mov    (%eax),%eax
     a5f:	83 ec 08             	sub    $0x8,%esp
     a62:	68 b5 1b 00 00       	push   $0x1bb5
     a67:	50                   	push   %eax
     a68:	e8 5c 03 00 00       	call   dc9 <strcpy>
     a6d:	83 c4 10             	add    $0x10,%esp

  arg3[0] = malloc(sizeof(char) * 5);
     a70:	83 ec 0c             	sub    $0xc,%esp
     a73:	6a 05                	push   $0x5
     a75:	e8 e5 0a 00 00       	call   155f <malloc>
     a7a:	83 c4 10             	add    $0x10,%esp
     a7d:	89 c2                	mov    %eax,%edx
     a7f:	8b 45 ec             	mov    -0x14(%ebp),%eax
     a82:	89 10                	mov    %edx,(%eax)
  strcpy(arg3[0], "time");
     a84:	8b 45 ec             	mov    -0x14(%ebp),%eax
     a87:	8b 00                	mov    (%eax),%eax
     a89:	83 ec 08             	sub    $0x8,%esp
     a8c:	68 b0 1b 00 00       	push   $0x1bb0
     a91:	50                   	push   %eax
     a92:	e8 32 03 00 00       	call   dc9 <strcpy>
     a97:	83 c4 10             	add    $0x10,%esp
  arg3[1] = malloc(sizeof(char) * 5);
     a9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
     a9d:	8d 58 04             	lea    0x4(%eax),%ebx
     aa0:	83 ec 0c             	sub    $0xc,%esp
     aa3:	6a 05                	push   $0x5
     aa5:	e8 b5 0a 00 00       	call   155f <malloc>
     aaa:	83 c4 10             	add    $0x10,%esp
     aad:	89 03                	mov    %eax,(%ebx)
  strcpy(arg3[1], "date");
     aaf:	8b 45 ec             	mov    -0x14(%ebp),%eax
     ab2:	83 c0 04             	add    $0x4,%eax
     ab5:	8b 00                	mov    (%eax),%eax
     ab7:	83 ec 08             	sub    $0x8,%esp
     aba:	68 b9 1b 00 00       	push   $0x1bb9
     abf:	50                   	push   %eax
     ac0:	e8 04 03 00 00       	call   dc9 <strcpy>
     ac5:	83 c4 10             	add    $0x10,%esp

  arg4[0] = malloc(sizeof(char) * 5);
     ac8:	83 ec 0c             	sub    $0xc,%esp
     acb:	6a 05                	push   $0x5
     acd:	e8 8d 0a 00 00       	call   155f <malloc>
     ad2:	83 c4 10             	add    $0x10,%esp
     ad5:	89 c2                	mov    %eax,%edx
     ad7:	8b 45 e8             	mov    -0x18(%ebp),%eax
     ada:	89 10                	mov    %edx,(%eax)
  strcpy(arg4[0], "time");
     adc:	8b 45 e8             	mov    -0x18(%ebp),%eax
     adf:	8b 00                	mov    (%eax),%eax
     ae1:	83 ec 08             	sub    $0x8,%esp
     ae4:	68 b0 1b 00 00       	push   $0x1bb0
     ae9:	50                   	push   %eax
     aea:	e8 da 02 00 00       	call   dc9 <strcpy>
     aef:	83 c4 10             	add    $0x10,%esp
  arg4[1] = malloc(sizeof(char) * 5);
     af2:	8b 45 e8             	mov    -0x18(%ebp),%eax
     af5:	8d 58 04             	lea    0x4(%eax),%ebx
     af8:	83 ec 0c             	sub    $0xc,%esp
     afb:	6a 05                	push   $0x5
     afd:	e8 5d 0a 00 00       	call   155f <malloc>
     b02:	83 c4 10             	add    $0x10,%esp
     b05:	89 03                	mov    %eax,(%ebx)
  strcpy(arg4[1], "time");
     b07:	8b 45 e8             	mov    -0x18(%ebp),%eax
     b0a:	83 c0 04             	add    $0x4,%eax
     b0d:	8b 00                	mov    (%eax),%eax
     b0f:	83 ec 08             	sub    $0x8,%esp
     b12:	68 b0 1b 00 00       	push   $0x1bb0
     b17:	50                   	push   %eax
     b18:	e8 ac 02 00 00       	call   dc9 <strcpy>
     b1d:	83 c4 10             	add    $0x10,%esp
  arg4[2] = malloc(sizeof(char) * 5);
     b20:	8b 45 e8             	mov    -0x18(%ebp),%eax
     b23:	8d 58 08             	lea    0x8(%eax),%ebx
     b26:	83 ec 0c             	sub    $0xc,%esp
     b29:	6a 05                	push   $0x5
     b2b:	e8 2f 0a 00 00       	call   155f <malloc>
     b30:	83 c4 10             	add    $0x10,%esp
     b33:	89 03                	mov    %eax,(%ebx)
  strcpy(arg4[2], "echo");
     b35:	8b 45 e8             	mov    -0x18(%ebp),%eax
     b38:	83 c0 08             	add    $0x8,%eax
     b3b:	8b 00                	mov    (%eax),%eax
     b3d:	83 ec 08             	sub    $0x8,%esp
     b40:	68 be 1b 00 00       	push   $0x1bbe
     b45:	50                   	push   %eax
     b46:	e8 7e 02 00 00       	call   dc9 <strcpy>
     b4b:	83 c4 10             	add    $0x10,%esp
  arg4[3] = malloc(sizeof(char) * 6);
     b4e:	8b 45 e8             	mov    -0x18(%ebp),%eax
     b51:	8d 58 0c             	lea    0xc(%eax),%ebx
     b54:	83 ec 0c             	sub    $0xc,%esp
     b57:	6a 06                	push   $0x6
     b59:	e8 01 0a 00 00       	call   155f <malloc>
     b5e:	83 c4 10             	add    $0x10,%esp
     b61:	89 03                	mov    %eax,(%ebx)
  strcpy(arg4[3], "\"abc\"");
     b63:	8b 45 e8             	mov    -0x18(%ebp),%eax
     b66:	83 c0 0c             	add    $0xc,%eax
     b69:	8b 00                	mov    (%eax),%eax
     b6b:	83 ec 08             	sub    $0x8,%esp
     b6e:	68 c3 1b 00 00       	push   $0x1bc3
     b73:	50                   	push   %eax
     b74:	e8 50 02 00 00       	call   dc9 <strcpy>
     b79:	83 c4 10             	add    $0x10,%esp

  printf(1, "\n----------\nRunning Time Test\n----------\n");
     b7c:	83 ec 08             	sub    $0x8,%esp
     b7f:	68 cc 1b 00 00       	push   $0x1bcc
     b84:	6a 01                	push   $0x1
     b86:	e8 01 07 00 00       	call   128c <printf>
     b8b:	83 c4 10             	add    $0x10,%esp
  printf(1, "You will need to verify these tests passed\n");
     b8e:	83 ec 08             	sub    $0x8,%esp
     b91:	68 f8 1b 00 00       	push   $0x1bf8
     b96:	6a 01                	push   $0x1
     b98:	e8 ef 06 00 00       	call   128c <printf>
     b9d:	83 c4 10             	add    $0x10,%esp

  printf(1,"\n%s\n", arg1[0]);
     ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ba3:	8b 00                	mov    (%eax),%eax
     ba5:	83 ec 04             	sub    $0x4,%esp
     ba8:	50                   	push   %eax
     ba9:	68 24 1c 00 00       	push   $0x1c24
     bae:	6a 01                	push   $0x1
     bb0:	e8 d7 06 00 00       	call   128c <printf>
     bb5:	83 c4 10             	add    $0x10,%esp
  testtimewitharg(arg1);
     bb8:	83 ec 0c             	sub    $0xc,%esp
     bbb:	ff 75 f4             	pushl  -0xc(%ebp)
     bbe:	e8 7d fd ff ff       	call   940 <testtimewitharg>
     bc3:	83 c4 10             	add    $0x10,%esp
  printf(1,"\n%s %s\n", arg2[0], arg2[1]);
     bc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
     bc9:	83 c0 04             	add    $0x4,%eax
     bcc:	8b 10                	mov    (%eax),%edx
     bce:	8b 45 f0             	mov    -0x10(%ebp),%eax
     bd1:	8b 00                	mov    (%eax),%eax
     bd3:	52                   	push   %edx
     bd4:	50                   	push   %eax
     bd5:	68 29 1c 00 00       	push   $0x1c29
     bda:	6a 01                	push   $0x1
     bdc:	e8 ab 06 00 00       	call   128c <printf>
     be1:	83 c4 10             	add    $0x10,%esp
  testtimewitharg(arg2);
     be4:	83 ec 0c             	sub    $0xc,%esp
     be7:	ff 75 f0             	pushl  -0x10(%ebp)
     bea:	e8 51 fd ff ff       	call   940 <testtimewitharg>
     bef:	83 c4 10             	add    $0x10,%esp
  printf(1,"\n%s %s\n", arg3[0], arg3[1]);
     bf2:	8b 45 ec             	mov    -0x14(%ebp),%eax
     bf5:	83 c0 04             	add    $0x4,%eax
     bf8:	8b 10                	mov    (%eax),%edx
     bfa:	8b 45 ec             	mov    -0x14(%ebp),%eax
     bfd:	8b 00                	mov    (%eax),%eax
     bff:	52                   	push   %edx
     c00:	50                   	push   %eax
     c01:	68 29 1c 00 00       	push   $0x1c29
     c06:	6a 01                	push   $0x1
     c08:	e8 7f 06 00 00       	call   128c <printf>
     c0d:	83 c4 10             	add    $0x10,%esp
  testtimewitharg(arg3);
     c10:	83 ec 0c             	sub    $0xc,%esp
     c13:	ff 75 ec             	pushl  -0x14(%ebp)
     c16:	e8 25 fd ff ff       	call   940 <testtimewitharg>
     c1b:	83 c4 10             	add    $0x10,%esp
  printf(1,"\n%s %s %s %s\n", arg4[0], arg4[1], arg4[2], arg4[3]);
     c1e:	8b 45 e8             	mov    -0x18(%ebp),%eax
     c21:	83 c0 0c             	add    $0xc,%eax
     c24:	8b 18                	mov    (%eax),%ebx
     c26:	8b 45 e8             	mov    -0x18(%ebp),%eax
     c29:	83 c0 08             	add    $0x8,%eax
     c2c:	8b 08                	mov    (%eax),%ecx
     c2e:	8b 45 e8             	mov    -0x18(%ebp),%eax
     c31:	83 c0 04             	add    $0x4,%eax
     c34:	8b 10                	mov    (%eax),%edx
     c36:	8b 45 e8             	mov    -0x18(%ebp),%eax
     c39:	8b 00                	mov    (%eax),%eax
     c3b:	83 ec 08             	sub    $0x8,%esp
     c3e:	53                   	push   %ebx
     c3f:	51                   	push   %ecx
     c40:	52                   	push   %edx
     c41:	50                   	push   %eax
     c42:	68 31 1c 00 00       	push   $0x1c31
     c47:	6a 01                	push   $0x1
     c49:	e8 3e 06 00 00       	call   128c <printf>
     c4e:	83 c4 20             	add    $0x20,%esp
  testtimewitharg(arg4);
     c51:	83 ec 0c             	sub    $0xc,%esp
     c54:	ff 75 e8             	pushl  -0x18(%ebp)
     c57:	e8 e4 fc ff ff       	call   940 <testtimewitharg>
     c5c:	83 c4 10             	add    $0x10,%esp

  free(arg1[0]);
     c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     c62:	8b 00                	mov    (%eax),%eax
     c64:	83 ec 0c             	sub    $0xc,%esp
     c67:	50                   	push   %eax
     c68:	e8 b0 07 00 00       	call   141d <free>
     c6d:	83 c4 10             	add    $0x10,%esp
  free(arg1);
     c70:	83 ec 0c             	sub    $0xc,%esp
     c73:	ff 75 f4             	pushl  -0xc(%ebp)
     c76:	e8 a2 07 00 00       	call   141d <free>
     c7b:	83 c4 10             	add    $0x10,%esp
  free(arg2[0]); free(arg2[1]);
     c7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c81:	8b 00                	mov    (%eax),%eax
     c83:	83 ec 0c             	sub    $0xc,%esp
     c86:	50                   	push   %eax
     c87:	e8 91 07 00 00       	call   141d <free>
     c8c:	83 c4 10             	add    $0x10,%esp
     c8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c92:	83 c0 04             	add    $0x4,%eax
     c95:	8b 00                	mov    (%eax),%eax
     c97:	83 ec 0c             	sub    $0xc,%esp
     c9a:	50                   	push   %eax
     c9b:	e8 7d 07 00 00       	call   141d <free>
     ca0:	83 c4 10             	add    $0x10,%esp
  free(arg2);
     ca3:	83 ec 0c             	sub    $0xc,%esp
     ca6:	ff 75 f0             	pushl  -0x10(%ebp)
     ca9:	e8 6f 07 00 00       	call   141d <free>
     cae:	83 c4 10             	add    $0x10,%esp
  free(arg3[0]); free(arg3[1]);
     cb1:	8b 45 ec             	mov    -0x14(%ebp),%eax
     cb4:	8b 00                	mov    (%eax),%eax
     cb6:	83 ec 0c             	sub    $0xc,%esp
     cb9:	50                   	push   %eax
     cba:	e8 5e 07 00 00       	call   141d <free>
     cbf:	83 c4 10             	add    $0x10,%esp
     cc2:	8b 45 ec             	mov    -0x14(%ebp),%eax
     cc5:	83 c0 04             	add    $0x4,%eax
     cc8:	8b 00                	mov    (%eax),%eax
     cca:	83 ec 0c             	sub    $0xc,%esp
     ccd:	50                   	push   %eax
     cce:	e8 4a 07 00 00       	call   141d <free>
     cd3:	83 c4 10             	add    $0x10,%esp
  free(arg3);
     cd6:	83 ec 0c             	sub    $0xc,%esp
     cd9:	ff 75 ec             	pushl  -0x14(%ebp)
     cdc:	e8 3c 07 00 00       	call   141d <free>
     ce1:	83 c4 10             	add    $0x10,%esp
  free(arg4[0]); free(arg4[1]); free(arg4[2]); free(arg4[3]);
     ce4:	8b 45 e8             	mov    -0x18(%ebp),%eax
     ce7:	8b 00                	mov    (%eax),%eax
     ce9:	83 ec 0c             	sub    $0xc,%esp
     cec:	50                   	push   %eax
     ced:	e8 2b 07 00 00       	call   141d <free>
     cf2:	83 c4 10             	add    $0x10,%esp
     cf5:	8b 45 e8             	mov    -0x18(%ebp),%eax
     cf8:	83 c0 04             	add    $0x4,%eax
     cfb:	8b 00                	mov    (%eax),%eax
     cfd:	83 ec 0c             	sub    $0xc,%esp
     d00:	50                   	push   %eax
     d01:	e8 17 07 00 00       	call   141d <free>
     d06:	83 c4 10             	add    $0x10,%esp
     d09:	8b 45 e8             	mov    -0x18(%ebp),%eax
     d0c:	83 c0 08             	add    $0x8,%eax
     d0f:	8b 00                	mov    (%eax),%eax
     d11:	83 ec 0c             	sub    $0xc,%esp
     d14:	50                   	push   %eax
     d15:	e8 03 07 00 00       	call   141d <free>
     d1a:	83 c4 10             	add    $0x10,%esp
     d1d:	8b 45 e8             	mov    -0x18(%ebp),%eax
     d20:	83 c0 0c             	add    $0xc,%eax
     d23:	8b 00                	mov    (%eax),%eax
     d25:	83 ec 0c             	sub    $0xc,%esp
     d28:	50                   	push   %eax
     d29:	e8 ef 06 00 00       	call   141d <free>
     d2e:	83 c4 10             	add    $0x10,%esp
  free(arg4);
     d31:	83 ec 0c             	sub    $0xc,%esp
     d34:	ff 75 e8             	pushl  -0x18(%ebp)
     d37:	e8 e1 06 00 00       	call   141d <free>
     d3c:	83 c4 10             	add    $0x10,%esp
}
     d3f:	90                   	nop
     d40:	8b 5d fc             	mov    -0x4(%ebp),%ebx
     d43:	c9                   	leave  
     d44:	c3                   	ret    

00000d45 <main>:
#endif

int
main(int argc, char *argv[])
{
     d45:	8d 4c 24 04          	lea    0x4(%esp),%ecx
     d49:	83 e4 f0             	and    $0xfffffff0,%esp
     d4c:	ff 71 fc             	pushl  -0x4(%ecx)
     d4f:	55                   	push   %ebp
     d50:	89 e5                	mov    %esp,%ebp
     d52:	53                   	push   %ebx
     d53:	51                   	push   %ecx
     d54:	89 cb                	mov    %ecx,%ebx
  #ifdef CPUTIME_TEST
  testcputime(argv[0]);
     d56:	8b 43 04             	mov    0x4(%ebx),%eax
     d59:	8b 00                	mov    (%eax),%eax
     d5b:	83 ec 0c             	sub    $0xc,%esp
     d5e:	50                   	push   %eax
     d5f:	e8 a2 f7 ff ff       	call   506 <testcputime>
     d64:	83 c4 10             	add    $0x10,%esp
  #endif
  #ifdef UIDGIDPPID_TEST
  testuidgid();
     d67:	e8 3c f4 ff ff       	call   1a8 <testuidgid>
  testuidgidinheritance();
     d6c:	e8 0d f6 ff ff       	call   37e <testuidgidinheritance>
  testppid();
     d71:	e8 8a f2 ff ff       	call   0 <testppid>
  #endif
  #ifdef GETPROCS_TEST
  testgetprocs(argv[0]);
     d76:	8b 43 04             	mov    0x4(%ebx),%eax
     d79:	8b 00                	mov    (%eax),%eax
     d7b:	83 ec 0c             	sub    $0xc,%esp
     d7e:	50                   	push   %eax
     d7f:	e8 c4 fa ff ff       	call   848 <testgetprocs>
     d84:	83 c4 10             	add    $0x10,%esp
  #endif
  #ifdef TIME_TEST
  testtime();
     d87:	e8 1b fc ff ff       	call   9a7 <testtime>
  #endif
  printf(1, "\n** End of Tests **\n");
     d8c:	83 ec 08             	sub    $0x8,%esp
     d8f:	68 3f 1c 00 00       	push   $0x1c3f
     d94:	6a 01                	push   $0x1
     d96:	e8 f1 04 00 00       	call   128c <printf>
     d9b:	83 c4 10             	add    $0x10,%esp
  exit();
     d9e:	e8 2a 03 00 00       	call   10cd <exit>

00000da3 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     da3:	55                   	push   %ebp
     da4:	89 e5                	mov    %esp,%ebp
     da6:	57                   	push   %edi
     da7:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
     da8:	8b 4d 08             	mov    0x8(%ebp),%ecx
     dab:	8b 55 10             	mov    0x10(%ebp),%edx
     dae:	8b 45 0c             	mov    0xc(%ebp),%eax
     db1:	89 cb                	mov    %ecx,%ebx
     db3:	89 df                	mov    %ebx,%edi
     db5:	89 d1                	mov    %edx,%ecx
     db7:	fc                   	cld    
     db8:	f3 aa                	rep stos %al,%es:(%edi)
     dba:	89 ca                	mov    %ecx,%edx
     dbc:	89 fb                	mov    %edi,%ebx
     dbe:	89 5d 08             	mov    %ebx,0x8(%ebp)
     dc1:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     dc4:	90                   	nop
     dc5:	5b                   	pop    %ebx
     dc6:	5f                   	pop    %edi
     dc7:	5d                   	pop    %ebp
     dc8:	c3                   	ret    

00000dc9 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
     dc9:	55                   	push   %ebp
     dca:	89 e5                	mov    %esp,%ebp
     dcc:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
     dcf:	8b 45 08             	mov    0x8(%ebp),%eax
     dd2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
     dd5:	90                   	nop
     dd6:	8b 45 08             	mov    0x8(%ebp),%eax
     dd9:	8d 50 01             	lea    0x1(%eax),%edx
     ddc:	89 55 08             	mov    %edx,0x8(%ebp)
     ddf:	8b 55 0c             	mov    0xc(%ebp),%edx
     de2:	8d 4a 01             	lea    0x1(%edx),%ecx
     de5:	89 4d 0c             	mov    %ecx,0xc(%ebp)
     de8:	0f b6 12             	movzbl (%edx),%edx
     deb:	88 10                	mov    %dl,(%eax)
     ded:	0f b6 00             	movzbl (%eax),%eax
     df0:	84 c0                	test   %al,%al
     df2:	75 e2                	jne    dd6 <strcpy+0xd>
    ;
  return os;
     df4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     df7:	c9                   	leave  
     df8:	c3                   	ret    

00000df9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     df9:	55                   	push   %ebp
     dfa:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
     dfc:	eb 08                	jmp    e06 <strcmp+0xd>
    p++, q++;
     dfe:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     e02:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
     e06:	8b 45 08             	mov    0x8(%ebp),%eax
     e09:	0f b6 00             	movzbl (%eax),%eax
     e0c:	84 c0                	test   %al,%al
     e0e:	74 10                	je     e20 <strcmp+0x27>
     e10:	8b 45 08             	mov    0x8(%ebp),%eax
     e13:	0f b6 10             	movzbl (%eax),%edx
     e16:	8b 45 0c             	mov    0xc(%ebp),%eax
     e19:	0f b6 00             	movzbl (%eax),%eax
     e1c:	38 c2                	cmp    %al,%dl
     e1e:	74 de                	je     dfe <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
     e20:	8b 45 08             	mov    0x8(%ebp),%eax
     e23:	0f b6 00             	movzbl (%eax),%eax
     e26:	0f b6 d0             	movzbl %al,%edx
     e29:	8b 45 0c             	mov    0xc(%ebp),%eax
     e2c:	0f b6 00             	movzbl (%eax),%eax
     e2f:	0f b6 c0             	movzbl %al,%eax
     e32:	29 c2                	sub    %eax,%edx
     e34:	89 d0                	mov    %edx,%eax
}
     e36:	5d                   	pop    %ebp
     e37:	c3                   	ret    

00000e38 <strlen>:

uint
strlen(char *s)
{
     e38:	55                   	push   %ebp
     e39:	89 e5                	mov    %esp,%ebp
     e3b:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
     e3e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
     e45:	eb 04                	jmp    e4b <strlen+0x13>
     e47:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
     e4b:	8b 55 fc             	mov    -0x4(%ebp),%edx
     e4e:	8b 45 08             	mov    0x8(%ebp),%eax
     e51:	01 d0                	add    %edx,%eax
     e53:	0f b6 00             	movzbl (%eax),%eax
     e56:	84 c0                	test   %al,%al
     e58:	75 ed                	jne    e47 <strlen+0xf>
    ;
  return n;
     e5a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     e5d:	c9                   	leave  
     e5e:	c3                   	ret    

00000e5f <memset>:

void*
memset(void *dst, int c, uint n)
{
     e5f:	55                   	push   %ebp
     e60:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
     e62:	8b 45 10             	mov    0x10(%ebp),%eax
     e65:	50                   	push   %eax
     e66:	ff 75 0c             	pushl  0xc(%ebp)
     e69:	ff 75 08             	pushl  0x8(%ebp)
     e6c:	e8 32 ff ff ff       	call   da3 <stosb>
     e71:	83 c4 0c             	add    $0xc,%esp
  return dst;
     e74:	8b 45 08             	mov    0x8(%ebp),%eax
}
     e77:	c9                   	leave  
     e78:	c3                   	ret    

00000e79 <strchr>:

char*
strchr(const char *s, char c)
{
     e79:	55                   	push   %ebp
     e7a:	89 e5                	mov    %esp,%ebp
     e7c:	83 ec 04             	sub    $0x4,%esp
     e7f:	8b 45 0c             	mov    0xc(%ebp),%eax
     e82:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
     e85:	eb 14                	jmp    e9b <strchr+0x22>
    if(*s == c)
     e87:	8b 45 08             	mov    0x8(%ebp),%eax
     e8a:	0f b6 00             	movzbl (%eax),%eax
     e8d:	3a 45 fc             	cmp    -0x4(%ebp),%al
     e90:	75 05                	jne    e97 <strchr+0x1e>
      return (char*)s;
     e92:	8b 45 08             	mov    0x8(%ebp),%eax
     e95:	eb 13                	jmp    eaa <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
     e97:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     e9b:	8b 45 08             	mov    0x8(%ebp),%eax
     e9e:	0f b6 00             	movzbl (%eax),%eax
     ea1:	84 c0                	test   %al,%al
     ea3:	75 e2                	jne    e87 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
     ea5:	b8 00 00 00 00       	mov    $0x0,%eax
}
     eaa:	c9                   	leave  
     eab:	c3                   	ret    

00000eac <gets>:

char*
gets(char *buf, int max)
{
     eac:	55                   	push   %ebp
     ead:	89 e5                	mov    %esp,%ebp
     eaf:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     eb2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     eb9:	eb 42                	jmp    efd <gets+0x51>
    cc = read(0, &c, 1);
     ebb:	83 ec 04             	sub    $0x4,%esp
     ebe:	6a 01                	push   $0x1
     ec0:	8d 45 ef             	lea    -0x11(%ebp),%eax
     ec3:	50                   	push   %eax
     ec4:	6a 00                	push   $0x0
     ec6:	e8 1a 02 00 00       	call   10e5 <read>
     ecb:	83 c4 10             	add    $0x10,%esp
     ece:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
     ed1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     ed5:	7e 33                	jle    f0a <gets+0x5e>
      break;
    buf[i++] = c;
     ed7:	8b 45 f4             	mov    -0xc(%ebp),%eax
     eda:	8d 50 01             	lea    0x1(%eax),%edx
     edd:	89 55 f4             	mov    %edx,-0xc(%ebp)
     ee0:	89 c2                	mov    %eax,%edx
     ee2:	8b 45 08             	mov    0x8(%ebp),%eax
     ee5:	01 c2                	add    %eax,%edx
     ee7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     eeb:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
     eed:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     ef1:	3c 0a                	cmp    $0xa,%al
     ef3:	74 16                	je     f0b <gets+0x5f>
     ef5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     ef9:	3c 0d                	cmp    $0xd,%al
     efb:	74 0e                	je     f0b <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     efd:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f00:	83 c0 01             	add    $0x1,%eax
     f03:	3b 45 0c             	cmp    0xc(%ebp),%eax
     f06:	7c b3                	jl     ebb <gets+0xf>
     f08:	eb 01                	jmp    f0b <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
     f0a:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
     f0b:	8b 55 f4             	mov    -0xc(%ebp),%edx
     f0e:	8b 45 08             	mov    0x8(%ebp),%eax
     f11:	01 d0                	add    %edx,%eax
     f13:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
     f16:	8b 45 08             	mov    0x8(%ebp),%eax
}
     f19:	c9                   	leave  
     f1a:	c3                   	ret    

00000f1b <stat>:

int
stat(char *n, struct stat *st)
{
     f1b:	55                   	push   %ebp
     f1c:	89 e5                	mov    %esp,%ebp
     f1e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     f21:	83 ec 08             	sub    $0x8,%esp
     f24:	6a 00                	push   $0x0
     f26:	ff 75 08             	pushl  0x8(%ebp)
     f29:	e8 df 01 00 00       	call   110d <open>
     f2e:	83 c4 10             	add    $0x10,%esp
     f31:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
     f34:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     f38:	79 07                	jns    f41 <stat+0x26>
    return -1;
     f3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     f3f:	eb 25                	jmp    f66 <stat+0x4b>
  r = fstat(fd, st);
     f41:	83 ec 08             	sub    $0x8,%esp
     f44:	ff 75 0c             	pushl  0xc(%ebp)
     f47:	ff 75 f4             	pushl  -0xc(%ebp)
     f4a:	e8 d6 01 00 00       	call   1125 <fstat>
     f4f:	83 c4 10             	add    $0x10,%esp
     f52:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
     f55:	83 ec 0c             	sub    $0xc,%esp
     f58:	ff 75 f4             	pushl  -0xc(%ebp)
     f5b:	e8 95 01 00 00       	call   10f5 <close>
     f60:	83 c4 10             	add    $0x10,%esp
  return r;
     f63:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     f66:	c9                   	leave  
     f67:	c3                   	ret    

00000f68 <atoi>:

int
atoi(const char *s)
{
     f68:	55                   	push   %ebp
     f69:	89 e5                	mov    %esp,%ebp
     f6b:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
     f6e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
     f75:	eb 04                	jmp    f7b <atoi+0x13>
     f77:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     f7b:	8b 45 08             	mov    0x8(%ebp),%eax
     f7e:	0f b6 00             	movzbl (%eax),%eax
     f81:	3c 20                	cmp    $0x20,%al
     f83:	74 f2                	je     f77 <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
     f85:	8b 45 08             	mov    0x8(%ebp),%eax
     f88:	0f b6 00             	movzbl (%eax),%eax
     f8b:	3c 2d                	cmp    $0x2d,%al
     f8d:	75 07                	jne    f96 <atoi+0x2e>
     f8f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     f94:	eb 05                	jmp    f9b <atoi+0x33>
     f96:	b8 01 00 00 00       	mov    $0x1,%eax
     f9b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
     f9e:	8b 45 08             	mov    0x8(%ebp),%eax
     fa1:	0f b6 00             	movzbl (%eax),%eax
     fa4:	3c 2b                	cmp    $0x2b,%al
     fa6:	74 0a                	je     fb2 <atoi+0x4a>
     fa8:	8b 45 08             	mov    0x8(%ebp),%eax
     fab:	0f b6 00             	movzbl (%eax),%eax
     fae:	3c 2d                	cmp    $0x2d,%al
     fb0:	75 2b                	jne    fdd <atoi+0x75>
    s++;
     fb2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
     fb6:	eb 25                	jmp    fdd <atoi+0x75>
    n = n*10 + *s++ - '0';
     fb8:	8b 55 fc             	mov    -0x4(%ebp),%edx
     fbb:	89 d0                	mov    %edx,%eax
     fbd:	c1 e0 02             	shl    $0x2,%eax
     fc0:	01 d0                	add    %edx,%eax
     fc2:	01 c0                	add    %eax,%eax
     fc4:	89 c1                	mov    %eax,%ecx
     fc6:	8b 45 08             	mov    0x8(%ebp),%eax
     fc9:	8d 50 01             	lea    0x1(%eax),%edx
     fcc:	89 55 08             	mov    %edx,0x8(%ebp)
     fcf:	0f b6 00             	movzbl (%eax),%eax
     fd2:	0f be c0             	movsbl %al,%eax
     fd5:	01 c8                	add    %ecx,%eax
     fd7:	83 e8 30             	sub    $0x30,%eax
     fda:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
     fdd:	8b 45 08             	mov    0x8(%ebp),%eax
     fe0:	0f b6 00             	movzbl (%eax),%eax
     fe3:	3c 2f                	cmp    $0x2f,%al
     fe5:	7e 0a                	jle    ff1 <atoi+0x89>
     fe7:	8b 45 08             	mov    0x8(%ebp),%eax
     fea:	0f b6 00             	movzbl (%eax),%eax
     fed:	3c 39                	cmp    $0x39,%al
     fef:	7e c7                	jle    fb8 <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
     ff1:	8b 45 f8             	mov    -0x8(%ebp),%eax
     ff4:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
     ff8:	c9                   	leave  
     ff9:	c3                   	ret    

00000ffa <atoo>:

int
atoo(const char *s)
{
     ffa:	55                   	push   %ebp
     ffb:	89 e5                	mov    %esp,%ebp
     ffd:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
    1000:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
    1007:	eb 04                	jmp    100d <atoo+0x13>
    1009:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    100d:	8b 45 08             	mov    0x8(%ebp),%eax
    1010:	0f b6 00             	movzbl (%eax),%eax
    1013:	3c 20                	cmp    $0x20,%al
    1015:	74 f2                	je     1009 <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
    1017:	8b 45 08             	mov    0x8(%ebp),%eax
    101a:	0f b6 00             	movzbl (%eax),%eax
    101d:	3c 2d                	cmp    $0x2d,%al
    101f:	75 07                	jne    1028 <atoo+0x2e>
    1021:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    1026:	eb 05                	jmp    102d <atoo+0x33>
    1028:	b8 01 00 00 00       	mov    $0x1,%eax
    102d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
    1030:	8b 45 08             	mov    0x8(%ebp),%eax
    1033:	0f b6 00             	movzbl (%eax),%eax
    1036:	3c 2b                	cmp    $0x2b,%al
    1038:	74 0a                	je     1044 <atoo+0x4a>
    103a:	8b 45 08             	mov    0x8(%ebp),%eax
    103d:	0f b6 00             	movzbl (%eax),%eax
    1040:	3c 2d                	cmp    $0x2d,%al
    1042:	75 27                	jne    106b <atoo+0x71>
    s++;
    1044:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
    1048:	eb 21                	jmp    106b <atoo+0x71>
    n = n*8 + *s++ - '0';
    104a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    104d:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
    1054:	8b 45 08             	mov    0x8(%ebp),%eax
    1057:	8d 50 01             	lea    0x1(%eax),%edx
    105a:	89 55 08             	mov    %edx,0x8(%ebp)
    105d:	0f b6 00             	movzbl (%eax),%eax
    1060:	0f be c0             	movsbl %al,%eax
    1063:	01 c8                	add    %ecx,%eax
    1065:	83 e8 30             	sub    $0x30,%eax
    1068:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
    106b:	8b 45 08             	mov    0x8(%ebp),%eax
    106e:	0f b6 00             	movzbl (%eax),%eax
    1071:	3c 2f                	cmp    $0x2f,%al
    1073:	7e 0a                	jle    107f <atoo+0x85>
    1075:	8b 45 08             	mov    0x8(%ebp),%eax
    1078:	0f b6 00             	movzbl (%eax),%eax
    107b:	3c 37                	cmp    $0x37,%al
    107d:	7e cb                	jle    104a <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
    107f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1082:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
    1086:	c9                   	leave  
    1087:	c3                   	ret    

00001088 <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
    1088:	55                   	push   %ebp
    1089:	89 e5                	mov    %esp,%ebp
    108b:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
    108e:	8b 45 08             	mov    0x8(%ebp),%eax
    1091:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    1094:	8b 45 0c             	mov    0xc(%ebp),%eax
    1097:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    109a:	eb 17                	jmp    10b3 <memmove+0x2b>
    *dst++ = *src++;
    109c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    109f:	8d 50 01             	lea    0x1(%eax),%edx
    10a2:	89 55 fc             	mov    %edx,-0x4(%ebp)
    10a5:	8b 55 f8             	mov    -0x8(%ebp),%edx
    10a8:	8d 4a 01             	lea    0x1(%edx),%ecx
    10ab:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    10ae:	0f b6 12             	movzbl (%edx),%edx
    10b1:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    10b3:	8b 45 10             	mov    0x10(%ebp),%eax
    10b6:	8d 50 ff             	lea    -0x1(%eax),%edx
    10b9:	89 55 10             	mov    %edx,0x10(%ebp)
    10bc:	85 c0                	test   %eax,%eax
    10be:	7f dc                	jg     109c <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    10c0:	8b 45 08             	mov    0x8(%ebp),%eax
}
    10c3:	c9                   	leave  
    10c4:	c3                   	ret    

000010c5 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    10c5:	b8 01 00 00 00       	mov    $0x1,%eax
    10ca:	cd 40                	int    $0x40
    10cc:	c3                   	ret    

000010cd <exit>:
SYSCALL(exit)
    10cd:	b8 02 00 00 00       	mov    $0x2,%eax
    10d2:	cd 40                	int    $0x40
    10d4:	c3                   	ret    

000010d5 <wait>:
SYSCALL(wait)
    10d5:	b8 03 00 00 00       	mov    $0x3,%eax
    10da:	cd 40                	int    $0x40
    10dc:	c3                   	ret    

000010dd <pipe>:
SYSCALL(pipe)
    10dd:	b8 04 00 00 00       	mov    $0x4,%eax
    10e2:	cd 40                	int    $0x40
    10e4:	c3                   	ret    

000010e5 <read>:
SYSCALL(read)
    10e5:	b8 05 00 00 00       	mov    $0x5,%eax
    10ea:	cd 40                	int    $0x40
    10ec:	c3                   	ret    

000010ed <write>:
SYSCALL(write)
    10ed:	b8 10 00 00 00       	mov    $0x10,%eax
    10f2:	cd 40                	int    $0x40
    10f4:	c3                   	ret    

000010f5 <close>:
SYSCALL(close)
    10f5:	b8 15 00 00 00       	mov    $0x15,%eax
    10fa:	cd 40                	int    $0x40
    10fc:	c3                   	ret    

000010fd <kill>:
SYSCALL(kill)
    10fd:	b8 06 00 00 00       	mov    $0x6,%eax
    1102:	cd 40                	int    $0x40
    1104:	c3                   	ret    

00001105 <exec>:
SYSCALL(exec)
    1105:	b8 07 00 00 00       	mov    $0x7,%eax
    110a:	cd 40                	int    $0x40
    110c:	c3                   	ret    

0000110d <open>:
SYSCALL(open)
    110d:	b8 0f 00 00 00       	mov    $0xf,%eax
    1112:	cd 40                	int    $0x40
    1114:	c3                   	ret    

00001115 <mknod>:
SYSCALL(mknod)
    1115:	b8 11 00 00 00       	mov    $0x11,%eax
    111a:	cd 40                	int    $0x40
    111c:	c3                   	ret    

0000111d <unlink>:
SYSCALL(unlink)
    111d:	b8 12 00 00 00       	mov    $0x12,%eax
    1122:	cd 40                	int    $0x40
    1124:	c3                   	ret    

00001125 <fstat>:
SYSCALL(fstat)
    1125:	b8 08 00 00 00       	mov    $0x8,%eax
    112a:	cd 40                	int    $0x40
    112c:	c3                   	ret    

0000112d <link>:
SYSCALL(link)
    112d:	b8 13 00 00 00       	mov    $0x13,%eax
    1132:	cd 40                	int    $0x40
    1134:	c3                   	ret    

00001135 <mkdir>:
SYSCALL(mkdir)
    1135:	b8 14 00 00 00       	mov    $0x14,%eax
    113a:	cd 40                	int    $0x40
    113c:	c3                   	ret    

0000113d <chdir>:
SYSCALL(chdir)
    113d:	b8 09 00 00 00       	mov    $0x9,%eax
    1142:	cd 40                	int    $0x40
    1144:	c3                   	ret    

00001145 <dup>:
SYSCALL(dup)
    1145:	b8 0a 00 00 00       	mov    $0xa,%eax
    114a:	cd 40                	int    $0x40
    114c:	c3                   	ret    

0000114d <getpid>:
SYSCALL(getpid)
    114d:	b8 0b 00 00 00       	mov    $0xb,%eax
    1152:	cd 40                	int    $0x40
    1154:	c3                   	ret    

00001155 <sbrk>:
SYSCALL(sbrk)
    1155:	b8 0c 00 00 00       	mov    $0xc,%eax
    115a:	cd 40                	int    $0x40
    115c:	c3                   	ret    

0000115d <sleep>:
SYSCALL(sleep)
    115d:	b8 0d 00 00 00       	mov    $0xd,%eax
    1162:	cd 40                	int    $0x40
    1164:	c3                   	ret    

00001165 <uptime>:
SYSCALL(uptime)
    1165:	b8 0e 00 00 00       	mov    $0xe,%eax
    116a:	cd 40                	int    $0x40
    116c:	c3                   	ret    

0000116d <halt>:
SYSCALL(halt)
    116d:	b8 16 00 00 00       	mov    $0x16,%eax
    1172:	cd 40                	int    $0x40
    1174:	c3                   	ret    

00001175 <date>:
SYSCALL(date)
    1175:	b8 17 00 00 00       	mov    $0x17,%eax
    117a:	cd 40                	int    $0x40
    117c:	c3                   	ret    

0000117d <getuid>:
SYSCALL(getuid)
    117d:	b8 18 00 00 00       	mov    $0x18,%eax
    1182:	cd 40                	int    $0x40
    1184:	c3                   	ret    

00001185 <getgid>:
SYSCALL(getgid)
    1185:	b8 19 00 00 00       	mov    $0x19,%eax
    118a:	cd 40                	int    $0x40
    118c:	c3                   	ret    

0000118d <getppid>:
SYSCALL(getppid)
    118d:	b8 1a 00 00 00       	mov    $0x1a,%eax
    1192:	cd 40                	int    $0x40
    1194:	c3                   	ret    

00001195 <setuid>:
SYSCALL(setuid)
    1195:	b8 1b 00 00 00       	mov    $0x1b,%eax
    119a:	cd 40                	int    $0x40
    119c:	c3                   	ret    

0000119d <setgid>:
SYSCALL(setgid)
    119d:	b8 1c 00 00 00       	mov    $0x1c,%eax
    11a2:	cd 40                	int    $0x40
    11a4:	c3                   	ret    

000011a5 <getprocs>:
SYSCALL(getprocs)
    11a5:	b8 1a 00 00 00       	mov    $0x1a,%eax
    11aa:	cd 40                	int    $0x40
    11ac:	c3                   	ret    

000011ad <setpriority>:
SYSCALL(setpriority)
    11ad:	b8 1b 00 00 00       	mov    $0x1b,%eax
    11b2:	cd 40                	int    $0x40
    11b4:	c3                   	ret    

000011b5 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    11b5:	55                   	push   %ebp
    11b6:	89 e5                	mov    %esp,%ebp
    11b8:	83 ec 18             	sub    $0x18,%esp
    11bb:	8b 45 0c             	mov    0xc(%ebp),%eax
    11be:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    11c1:	83 ec 04             	sub    $0x4,%esp
    11c4:	6a 01                	push   $0x1
    11c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
    11c9:	50                   	push   %eax
    11ca:	ff 75 08             	pushl  0x8(%ebp)
    11cd:	e8 1b ff ff ff       	call   10ed <write>
    11d2:	83 c4 10             	add    $0x10,%esp
}
    11d5:	90                   	nop
    11d6:	c9                   	leave  
    11d7:	c3                   	ret    

000011d8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    11d8:	55                   	push   %ebp
    11d9:	89 e5                	mov    %esp,%ebp
    11db:	53                   	push   %ebx
    11dc:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    11df:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    11e6:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    11ea:	74 17                	je     1203 <printint+0x2b>
    11ec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    11f0:	79 11                	jns    1203 <printint+0x2b>
    neg = 1;
    11f2:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    11f9:	8b 45 0c             	mov    0xc(%ebp),%eax
    11fc:	f7 d8                	neg    %eax
    11fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1201:	eb 06                	jmp    1209 <printint+0x31>
  } else {
    x = xx;
    1203:	8b 45 0c             	mov    0xc(%ebp),%eax
    1206:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    1209:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    1210:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1213:	8d 41 01             	lea    0x1(%ecx),%eax
    1216:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1219:	8b 5d 10             	mov    0x10(%ebp),%ebx
    121c:	8b 45 ec             	mov    -0x14(%ebp),%eax
    121f:	ba 00 00 00 00       	mov    $0x0,%edx
    1224:	f7 f3                	div    %ebx
    1226:	89 d0                	mov    %edx,%eax
    1228:	0f b6 80 4c 20 00 00 	movzbl 0x204c(%eax),%eax
    122f:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    1233:	8b 5d 10             	mov    0x10(%ebp),%ebx
    1236:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1239:	ba 00 00 00 00       	mov    $0x0,%edx
    123e:	f7 f3                	div    %ebx
    1240:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1243:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1247:	75 c7                	jne    1210 <printint+0x38>
  if(neg)
    1249:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    124d:	74 2d                	je     127c <printint+0xa4>
    buf[i++] = '-';
    124f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1252:	8d 50 01             	lea    0x1(%eax),%edx
    1255:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1258:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    125d:	eb 1d                	jmp    127c <printint+0xa4>
    putc(fd, buf[i]);
    125f:	8d 55 dc             	lea    -0x24(%ebp),%edx
    1262:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1265:	01 d0                	add    %edx,%eax
    1267:	0f b6 00             	movzbl (%eax),%eax
    126a:	0f be c0             	movsbl %al,%eax
    126d:	83 ec 08             	sub    $0x8,%esp
    1270:	50                   	push   %eax
    1271:	ff 75 08             	pushl  0x8(%ebp)
    1274:	e8 3c ff ff ff       	call   11b5 <putc>
    1279:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    127c:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    1280:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1284:	79 d9                	jns    125f <printint+0x87>
    putc(fd, buf[i]);
}
    1286:	90                   	nop
    1287:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    128a:	c9                   	leave  
    128b:	c3                   	ret    

0000128c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    128c:	55                   	push   %ebp
    128d:	89 e5                	mov    %esp,%ebp
    128f:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    1292:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    1299:	8d 45 0c             	lea    0xc(%ebp),%eax
    129c:	83 c0 04             	add    $0x4,%eax
    129f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    12a2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    12a9:	e9 59 01 00 00       	jmp    1407 <printf+0x17b>
    c = fmt[i] & 0xff;
    12ae:	8b 55 0c             	mov    0xc(%ebp),%edx
    12b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
    12b4:	01 d0                	add    %edx,%eax
    12b6:	0f b6 00             	movzbl (%eax),%eax
    12b9:	0f be c0             	movsbl %al,%eax
    12bc:	25 ff 00 00 00       	and    $0xff,%eax
    12c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    12c4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    12c8:	75 2c                	jne    12f6 <printf+0x6a>
      if(c == '%'){
    12ca:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    12ce:	75 0c                	jne    12dc <printf+0x50>
        state = '%';
    12d0:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    12d7:	e9 27 01 00 00       	jmp    1403 <printf+0x177>
      } else {
        putc(fd, c);
    12dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    12df:	0f be c0             	movsbl %al,%eax
    12e2:	83 ec 08             	sub    $0x8,%esp
    12e5:	50                   	push   %eax
    12e6:	ff 75 08             	pushl  0x8(%ebp)
    12e9:	e8 c7 fe ff ff       	call   11b5 <putc>
    12ee:	83 c4 10             	add    $0x10,%esp
    12f1:	e9 0d 01 00 00       	jmp    1403 <printf+0x177>
      }
    } else if(state == '%'){
    12f6:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    12fa:	0f 85 03 01 00 00    	jne    1403 <printf+0x177>
      if(c == 'd'){
    1300:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    1304:	75 1e                	jne    1324 <printf+0x98>
        printint(fd, *ap, 10, 1);
    1306:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1309:	8b 00                	mov    (%eax),%eax
    130b:	6a 01                	push   $0x1
    130d:	6a 0a                	push   $0xa
    130f:	50                   	push   %eax
    1310:	ff 75 08             	pushl  0x8(%ebp)
    1313:	e8 c0 fe ff ff       	call   11d8 <printint>
    1318:	83 c4 10             	add    $0x10,%esp
        ap++;
    131b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    131f:	e9 d8 00 00 00       	jmp    13fc <printf+0x170>
      } else if(c == 'x' || c == 'p'){
    1324:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    1328:	74 06                	je     1330 <printf+0xa4>
    132a:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    132e:	75 1e                	jne    134e <printf+0xc2>
        printint(fd, *ap, 16, 0);
    1330:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1333:	8b 00                	mov    (%eax),%eax
    1335:	6a 00                	push   $0x0
    1337:	6a 10                	push   $0x10
    1339:	50                   	push   %eax
    133a:	ff 75 08             	pushl  0x8(%ebp)
    133d:	e8 96 fe ff ff       	call   11d8 <printint>
    1342:	83 c4 10             	add    $0x10,%esp
        ap++;
    1345:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1349:	e9 ae 00 00 00       	jmp    13fc <printf+0x170>
      } else if(c == 's'){
    134e:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    1352:	75 43                	jne    1397 <printf+0x10b>
        s = (char*)*ap;
    1354:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1357:	8b 00                	mov    (%eax),%eax
    1359:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    135c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    1360:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1364:	75 25                	jne    138b <printf+0xff>
          s = "(null)";
    1366:	c7 45 f4 54 1c 00 00 	movl   $0x1c54,-0xc(%ebp)
        while(*s != 0){
    136d:	eb 1c                	jmp    138b <printf+0xff>
          putc(fd, *s);
    136f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1372:	0f b6 00             	movzbl (%eax),%eax
    1375:	0f be c0             	movsbl %al,%eax
    1378:	83 ec 08             	sub    $0x8,%esp
    137b:	50                   	push   %eax
    137c:	ff 75 08             	pushl  0x8(%ebp)
    137f:	e8 31 fe ff ff       	call   11b5 <putc>
    1384:	83 c4 10             	add    $0x10,%esp
          s++;
    1387:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    138b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    138e:	0f b6 00             	movzbl (%eax),%eax
    1391:	84 c0                	test   %al,%al
    1393:	75 da                	jne    136f <printf+0xe3>
    1395:	eb 65                	jmp    13fc <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1397:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    139b:	75 1d                	jne    13ba <printf+0x12e>
        putc(fd, *ap);
    139d:	8b 45 e8             	mov    -0x18(%ebp),%eax
    13a0:	8b 00                	mov    (%eax),%eax
    13a2:	0f be c0             	movsbl %al,%eax
    13a5:	83 ec 08             	sub    $0x8,%esp
    13a8:	50                   	push   %eax
    13a9:	ff 75 08             	pushl  0x8(%ebp)
    13ac:	e8 04 fe ff ff       	call   11b5 <putc>
    13b1:	83 c4 10             	add    $0x10,%esp
        ap++;
    13b4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    13b8:	eb 42                	jmp    13fc <printf+0x170>
      } else if(c == '%'){
    13ba:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    13be:	75 17                	jne    13d7 <printf+0x14b>
        putc(fd, c);
    13c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    13c3:	0f be c0             	movsbl %al,%eax
    13c6:	83 ec 08             	sub    $0x8,%esp
    13c9:	50                   	push   %eax
    13ca:	ff 75 08             	pushl  0x8(%ebp)
    13cd:	e8 e3 fd ff ff       	call   11b5 <putc>
    13d2:	83 c4 10             	add    $0x10,%esp
    13d5:	eb 25                	jmp    13fc <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    13d7:	83 ec 08             	sub    $0x8,%esp
    13da:	6a 25                	push   $0x25
    13dc:	ff 75 08             	pushl  0x8(%ebp)
    13df:	e8 d1 fd ff ff       	call   11b5 <putc>
    13e4:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
    13e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    13ea:	0f be c0             	movsbl %al,%eax
    13ed:	83 ec 08             	sub    $0x8,%esp
    13f0:	50                   	push   %eax
    13f1:	ff 75 08             	pushl  0x8(%ebp)
    13f4:	e8 bc fd ff ff       	call   11b5 <putc>
    13f9:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
    13fc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    1403:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    1407:	8b 55 0c             	mov    0xc(%ebp),%edx
    140a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    140d:	01 d0                	add    %edx,%eax
    140f:	0f b6 00             	movzbl (%eax),%eax
    1412:	84 c0                	test   %al,%al
    1414:	0f 85 94 fe ff ff    	jne    12ae <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    141a:	90                   	nop
    141b:	c9                   	leave  
    141c:	c3                   	ret    

0000141d <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    141d:	55                   	push   %ebp
    141e:	89 e5                	mov    %esp,%ebp
    1420:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1423:	8b 45 08             	mov    0x8(%ebp),%eax
    1426:	83 e8 08             	sub    $0x8,%eax
    1429:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    142c:	a1 68 20 00 00       	mov    0x2068,%eax
    1431:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1434:	eb 24                	jmp    145a <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1436:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1439:	8b 00                	mov    (%eax),%eax
    143b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    143e:	77 12                	ja     1452 <free+0x35>
    1440:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1443:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1446:	77 24                	ja     146c <free+0x4f>
    1448:	8b 45 fc             	mov    -0x4(%ebp),%eax
    144b:	8b 00                	mov    (%eax),%eax
    144d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1450:	77 1a                	ja     146c <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1452:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1455:	8b 00                	mov    (%eax),%eax
    1457:	89 45 fc             	mov    %eax,-0x4(%ebp)
    145a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    145d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1460:	76 d4                	jbe    1436 <free+0x19>
    1462:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1465:	8b 00                	mov    (%eax),%eax
    1467:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    146a:	76 ca                	jbe    1436 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    146c:	8b 45 f8             	mov    -0x8(%ebp),%eax
    146f:	8b 40 04             	mov    0x4(%eax),%eax
    1472:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1479:	8b 45 f8             	mov    -0x8(%ebp),%eax
    147c:	01 c2                	add    %eax,%edx
    147e:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1481:	8b 00                	mov    (%eax),%eax
    1483:	39 c2                	cmp    %eax,%edx
    1485:	75 24                	jne    14ab <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    1487:	8b 45 f8             	mov    -0x8(%ebp),%eax
    148a:	8b 50 04             	mov    0x4(%eax),%edx
    148d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1490:	8b 00                	mov    (%eax),%eax
    1492:	8b 40 04             	mov    0x4(%eax),%eax
    1495:	01 c2                	add    %eax,%edx
    1497:	8b 45 f8             	mov    -0x8(%ebp),%eax
    149a:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    149d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    14a0:	8b 00                	mov    (%eax),%eax
    14a2:	8b 10                	mov    (%eax),%edx
    14a4:	8b 45 f8             	mov    -0x8(%ebp),%eax
    14a7:	89 10                	mov    %edx,(%eax)
    14a9:	eb 0a                	jmp    14b5 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    14ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
    14ae:	8b 10                	mov    (%eax),%edx
    14b0:	8b 45 f8             	mov    -0x8(%ebp),%eax
    14b3:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    14b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    14b8:	8b 40 04             	mov    0x4(%eax),%eax
    14bb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    14c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
    14c5:	01 d0                	add    %edx,%eax
    14c7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    14ca:	75 20                	jne    14ec <free+0xcf>
    p->s.size += bp->s.size;
    14cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
    14cf:	8b 50 04             	mov    0x4(%eax),%edx
    14d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
    14d5:	8b 40 04             	mov    0x4(%eax),%eax
    14d8:	01 c2                	add    %eax,%edx
    14da:	8b 45 fc             	mov    -0x4(%ebp),%eax
    14dd:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    14e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
    14e3:	8b 10                	mov    (%eax),%edx
    14e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    14e8:	89 10                	mov    %edx,(%eax)
    14ea:	eb 08                	jmp    14f4 <free+0xd7>
  } else
    p->s.ptr = bp;
    14ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
    14ef:	8b 55 f8             	mov    -0x8(%ebp),%edx
    14f2:	89 10                	mov    %edx,(%eax)
  freep = p;
    14f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
    14f7:	a3 68 20 00 00       	mov    %eax,0x2068
}
    14fc:	90                   	nop
    14fd:	c9                   	leave  
    14fe:	c3                   	ret    

000014ff <morecore>:

static Header*
morecore(uint nu)
{
    14ff:	55                   	push   %ebp
    1500:	89 e5                	mov    %esp,%ebp
    1502:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    1505:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    150c:	77 07                	ja     1515 <morecore+0x16>
    nu = 4096;
    150e:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    1515:	8b 45 08             	mov    0x8(%ebp),%eax
    1518:	c1 e0 03             	shl    $0x3,%eax
    151b:	83 ec 0c             	sub    $0xc,%esp
    151e:	50                   	push   %eax
    151f:	e8 31 fc ff ff       	call   1155 <sbrk>
    1524:	83 c4 10             	add    $0x10,%esp
    1527:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    152a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    152e:	75 07                	jne    1537 <morecore+0x38>
    return 0;
    1530:	b8 00 00 00 00       	mov    $0x0,%eax
    1535:	eb 26                	jmp    155d <morecore+0x5e>
  hp = (Header*)p;
    1537:	8b 45 f4             	mov    -0xc(%ebp),%eax
    153a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    153d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1540:	8b 55 08             	mov    0x8(%ebp),%edx
    1543:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    1546:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1549:	83 c0 08             	add    $0x8,%eax
    154c:	83 ec 0c             	sub    $0xc,%esp
    154f:	50                   	push   %eax
    1550:	e8 c8 fe ff ff       	call   141d <free>
    1555:	83 c4 10             	add    $0x10,%esp
  return freep;
    1558:	a1 68 20 00 00       	mov    0x2068,%eax
}
    155d:	c9                   	leave  
    155e:	c3                   	ret    

0000155f <malloc>:

void*
malloc(uint nbytes)
{
    155f:	55                   	push   %ebp
    1560:	89 e5                	mov    %esp,%ebp
    1562:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1565:	8b 45 08             	mov    0x8(%ebp),%eax
    1568:	83 c0 07             	add    $0x7,%eax
    156b:	c1 e8 03             	shr    $0x3,%eax
    156e:	83 c0 01             	add    $0x1,%eax
    1571:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    1574:	a1 68 20 00 00       	mov    0x2068,%eax
    1579:	89 45 f0             	mov    %eax,-0x10(%ebp)
    157c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1580:	75 23                	jne    15a5 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    1582:	c7 45 f0 60 20 00 00 	movl   $0x2060,-0x10(%ebp)
    1589:	8b 45 f0             	mov    -0x10(%ebp),%eax
    158c:	a3 68 20 00 00       	mov    %eax,0x2068
    1591:	a1 68 20 00 00       	mov    0x2068,%eax
    1596:	a3 60 20 00 00       	mov    %eax,0x2060
    base.s.size = 0;
    159b:	c7 05 64 20 00 00 00 	movl   $0x0,0x2064
    15a2:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    15a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15a8:	8b 00                	mov    (%eax),%eax
    15aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    15ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15b0:	8b 40 04             	mov    0x4(%eax),%eax
    15b3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    15b6:	72 4d                	jb     1605 <malloc+0xa6>
      if(p->s.size == nunits)
    15b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15bb:	8b 40 04             	mov    0x4(%eax),%eax
    15be:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    15c1:	75 0c                	jne    15cf <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    15c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15c6:	8b 10                	mov    (%eax),%edx
    15c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15cb:	89 10                	mov    %edx,(%eax)
    15cd:	eb 26                	jmp    15f5 <malloc+0x96>
      else {
        p->s.size -= nunits;
    15cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15d2:	8b 40 04             	mov    0x4(%eax),%eax
    15d5:	2b 45 ec             	sub    -0x14(%ebp),%eax
    15d8:	89 c2                	mov    %eax,%edx
    15da:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15dd:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    15e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15e3:	8b 40 04             	mov    0x4(%eax),%eax
    15e6:	c1 e0 03             	shl    $0x3,%eax
    15e9:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    15ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15ef:	8b 55 ec             	mov    -0x14(%ebp),%edx
    15f2:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    15f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15f8:	a3 68 20 00 00       	mov    %eax,0x2068
      return (void*)(p + 1);
    15fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1600:	83 c0 08             	add    $0x8,%eax
    1603:	eb 3b                	jmp    1640 <malloc+0xe1>
    }
    if(p == freep)
    1605:	a1 68 20 00 00       	mov    0x2068,%eax
    160a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    160d:	75 1e                	jne    162d <malloc+0xce>
      if((p = morecore(nunits)) == 0)
    160f:	83 ec 0c             	sub    $0xc,%esp
    1612:	ff 75 ec             	pushl  -0x14(%ebp)
    1615:	e8 e5 fe ff ff       	call   14ff <morecore>
    161a:	83 c4 10             	add    $0x10,%esp
    161d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1620:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1624:	75 07                	jne    162d <malloc+0xce>
        return 0;
    1626:	b8 00 00 00 00       	mov    $0x0,%eax
    162b:	eb 13                	jmp    1640 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    162d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1630:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1633:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1636:	8b 00                	mov    (%eax),%eax
    1638:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    163b:	e9 6d ff ff ff       	jmp    15ad <malloc+0x4e>
}
    1640:	c9                   	leave  
    1641:	c3                   	ret    

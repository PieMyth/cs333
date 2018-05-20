
_sh:     file format elf32-i386


Disassembly of section .text:

00000000 <runcmd>:
struct cmd *parsecmd(char*);

// Execute cmd.  Never returns.
void
runcmd(struct cmd *cmd)
{
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	83 ec 28             	sub    $0x28,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
       6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
       a:	75 05                	jne    11 <runcmd+0x11>
    exit();
       c:	e8 97 0f 00 00       	call   fa8 <exit>
  
  switch(cmd->type){
      11:	8b 45 08             	mov    0x8(%ebp),%eax
      14:	8b 00                	mov    (%eax),%eax
      16:	83 f8 05             	cmp    $0x5,%eax
      19:	77 09                	ja     24 <runcmd+0x24>
      1b:	8b 04 85 4c 15 00 00 	mov    0x154c(,%eax,4),%eax
      22:	ff e0                	jmp    *%eax
  default:
    panic("runcmd");
      24:	83 ec 0c             	sub    $0xc,%esp
      27:	68 20 15 00 00       	push   $0x1520
      2c:	e8 6b 03 00 00       	call   39c <panic>
      31:	83 c4 10             	add    $0x10,%esp

  case EXEC:
    ecmd = (struct execcmd*)cmd;
      34:	8b 45 08             	mov    0x8(%ebp),%eax
      37:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ecmd->argv[0] == 0)
      3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
      3d:	8b 40 04             	mov    0x4(%eax),%eax
      40:	85 c0                	test   %eax,%eax
      42:	75 05                	jne    49 <runcmd+0x49>
      exit();
      44:	e8 5f 0f 00 00       	call   fa8 <exit>
    exec(ecmd->argv[0], ecmd->argv);
      49:	8b 45 f4             	mov    -0xc(%ebp),%eax
      4c:	8d 50 04             	lea    0x4(%eax),%edx
      4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
      52:	8b 40 04             	mov    0x4(%eax),%eax
      55:	83 ec 08             	sub    $0x8,%esp
      58:	52                   	push   %edx
      59:	50                   	push   %eax
      5a:	e8 81 0f 00 00       	call   fe0 <exec>
      5f:	83 c4 10             	add    $0x10,%esp
    printf(2, "exec %s failed\n", ecmd->argv[0]);
      62:	8b 45 f4             	mov    -0xc(%ebp),%eax
      65:	8b 40 04             	mov    0x4(%eax),%eax
      68:	83 ec 04             	sub    $0x4,%esp
      6b:	50                   	push   %eax
      6c:	68 27 15 00 00       	push   $0x1527
      71:	6a 02                	push   $0x2
      73:	e8 ef 10 00 00       	call   1167 <printf>
      78:	83 c4 10             	add    $0x10,%esp
    break;
      7b:	e9 c6 01 00 00       	jmp    246 <runcmd+0x246>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
      80:	8b 45 08             	mov    0x8(%ebp),%eax
      83:	89 45 f0             	mov    %eax,-0x10(%ebp)
    close(rcmd->fd);
      86:	8b 45 f0             	mov    -0x10(%ebp),%eax
      89:	8b 40 14             	mov    0x14(%eax),%eax
      8c:	83 ec 0c             	sub    $0xc,%esp
      8f:	50                   	push   %eax
      90:	e8 3b 0f 00 00       	call   fd0 <close>
      95:	83 c4 10             	add    $0x10,%esp
    if(open(rcmd->file, rcmd->mode) < 0){
      98:	8b 45 f0             	mov    -0x10(%ebp),%eax
      9b:	8b 50 10             	mov    0x10(%eax),%edx
      9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
      a1:	8b 40 08             	mov    0x8(%eax),%eax
      a4:	83 ec 08             	sub    $0x8,%esp
      a7:	52                   	push   %edx
      a8:	50                   	push   %eax
      a9:	e8 3a 0f 00 00       	call   fe8 <open>
      ae:	83 c4 10             	add    $0x10,%esp
      b1:	85 c0                	test   %eax,%eax
      b3:	79 1e                	jns    d3 <runcmd+0xd3>
      printf(2, "open %s failed\n", rcmd->file);
      b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
      b8:	8b 40 08             	mov    0x8(%eax),%eax
      bb:	83 ec 04             	sub    $0x4,%esp
      be:	50                   	push   %eax
      bf:	68 37 15 00 00       	push   $0x1537
      c4:	6a 02                	push   $0x2
      c6:	e8 9c 10 00 00       	call   1167 <printf>
      cb:	83 c4 10             	add    $0x10,%esp
      exit();
      ce:	e8 d5 0e 00 00       	call   fa8 <exit>
    }
    runcmd(rcmd->cmd);
      d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
      d6:	8b 40 04             	mov    0x4(%eax),%eax
      d9:	83 ec 0c             	sub    $0xc,%esp
      dc:	50                   	push   %eax
      dd:	e8 1e ff ff ff       	call   0 <runcmd>
      e2:	83 c4 10             	add    $0x10,%esp
    break;
      e5:	e9 5c 01 00 00       	jmp    246 <runcmd+0x246>

  case LIST:
    lcmd = (struct listcmd*)cmd;
      ea:	8b 45 08             	mov    0x8(%ebp),%eax
      ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(fork1() == 0)
      f0:	e8 c7 02 00 00       	call   3bc <fork1>
      f5:	85 c0                	test   %eax,%eax
      f7:	75 12                	jne    10b <runcmd+0x10b>
      runcmd(lcmd->left);
      f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
      fc:	8b 40 04             	mov    0x4(%eax),%eax
      ff:	83 ec 0c             	sub    $0xc,%esp
     102:	50                   	push   %eax
     103:	e8 f8 fe ff ff       	call   0 <runcmd>
     108:	83 c4 10             	add    $0x10,%esp
    wait();
     10b:	e8 a0 0e 00 00       	call   fb0 <wait>
    runcmd(lcmd->right);
     110:	8b 45 ec             	mov    -0x14(%ebp),%eax
     113:	8b 40 08             	mov    0x8(%eax),%eax
     116:	83 ec 0c             	sub    $0xc,%esp
     119:	50                   	push   %eax
     11a:	e8 e1 fe ff ff       	call   0 <runcmd>
     11f:	83 c4 10             	add    $0x10,%esp
    break;
     122:	e9 1f 01 00 00       	jmp    246 <runcmd+0x246>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     127:	8b 45 08             	mov    0x8(%ebp),%eax
     12a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pipe(p) < 0)
     12d:	83 ec 0c             	sub    $0xc,%esp
     130:	8d 45 dc             	lea    -0x24(%ebp),%eax
     133:	50                   	push   %eax
     134:	e8 7f 0e 00 00       	call   fb8 <pipe>
     139:	83 c4 10             	add    $0x10,%esp
     13c:	85 c0                	test   %eax,%eax
     13e:	79 10                	jns    150 <runcmd+0x150>
      panic("pipe");
     140:	83 ec 0c             	sub    $0xc,%esp
     143:	68 47 15 00 00       	push   $0x1547
     148:	e8 4f 02 00 00       	call   39c <panic>
     14d:	83 c4 10             	add    $0x10,%esp
    if(fork1() == 0){
     150:	e8 67 02 00 00       	call   3bc <fork1>
     155:	85 c0                	test   %eax,%eax
     157:	75 4c                	jne    1a5 <runcmd+0x1a5>
      close(1);
     159:	83 ec 0c             	sub    $0xc,%esp
     15c:	6a 01                	push   $0x1
     15e:	e8 6d 0e 00 00       	call   fd0 <close>
     163:	83 c4 10             	add    $0x10,%esp
      dup(p[1]);
     166:	8b 45 e0             	mov    -0x20(%ebp),%eax
     169:	83 ec 0c             	sub    $0xc,%esp
     16c:	50                   	push   %eax
     16d:	e8 ae 0e 00 00       	call   1020 <dup>
     172:	83 c4 10             	add    $0x10,%esp
      close(p[0]);
     175:	8b 45 dc             	mov    -0x24(%ebp),%eax
     178:	83 ec 0c             	sub    $0xc,%esp
     17b:	50                   	push   %eax
     17c:	e8 4f 0e 00 00       	call   fd0 <close>
     181:	83 c4 10             	add    $0x10,%esp
      close(p[1]);
     184:	8b 45 e0             	mov    -0x20(%ebp),%eax
     187:	83 ec 0c             	sub    $0xc,%esp
     18a:	50                   	push   %eax
     18b:	e8 40 0e 00 00       	call   fd0 <close>
     190:	83 c4 10             	add    $0x10,%esp
      runcmd(pcmd->left);
     193:	8b 45 e8             	mov    -0x18(%ebp),%eax
     196:	8b 40 04             	mov    0x4(%eax),%eax
     199:	83 ec 0c             	sub    $0xc,%esp
     19c:	50                   	push   %eax
     19d:	e8 5e fe ff ff       	call   0 <runcmd>
     1a2:	83 c4 10             	add    $0x10,%esp
    }
    if(fork1() == 0){
     1a5:	e8 12 02 00 00       	call   3bc <fork1>
     1aa:	85 c0                	test   %eax,%eax
     1ac:	75 4c                	jne    1fa <runcmd+0x1fa>
      close(0);
     1ae:	83 ec 0c             	sub    $0xc,%esp
     1b1:	6a 00                	push   $0x0
     1b3:	e8 18 0e 00 00       	call   fd0 <close>
     1b8:	83 c4 10             	add    $0x10,%esp
      dup(p[0]);
     1bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1be:	83 ec 0c             	sub    $0xc,%esp
     1c1:	50                   	push   %eax
     1c2:	e8 59 0e 00 00       	call   1020 <dup>
     1c7:	83 c4 10             	add    $0x10,%esp
      close(p[0]);
     1ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1cd:	83 ec 0c             	sub    $0xc,%esp
     1d0:	50                   	push   %eax
     1d1:	e8 fa 0d 00 00       	call   fd0 <close>
     1d6:	83 c4 10             	add    $0x10,%esp
      close(p[1]);
     1d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1dc:	83 ec 0c             	sub    $0xc,%esp
     1df:	50                   	push   %eax
     1e0:	e8 eb 0d 00 00       	call   fd0 <close>
     1e5:	83 c4 10             	add    $0x10,%esp
      runcmd(pcmd->right);
     1e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
     1eb:	8b 40 08             	mov    0x8(%eax),%eax
     1ee:	83 ec 0c             	sub    $0xc,%esp
     1f1:	50                   	push   %eax
     1f2:	e8 09 fe ff ff       	call   0 <runcmd>
     1f7:	83 c4 10             	add    $0x10,%esp
    }
    close(p[0]);
     1fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1fd:	83 ec 0c             	sub    $0xc,%esp
     200:	50                   	push   %eax
     201:	e8 ca 0d 00 00       	call   fd0 <close>
     206:	83 c4 10             	add    $0x10,%esp
    close(p[1]);
     209:	8b 45 e0             	mov    -0x20(%ebp),%eax
     20c:	83 ec 0c             	sub    $0xc,%esp
     20f:	50                   	push   %eax
     210:	e8 bb 0d 00 00       	call   fd0 <close>
     215:	83 c4 10             	add    $0x10,%esp
    wait();
     218:	e8 93 0d 00 00       	call   fb0 <wait>
    wait();
     21d:	e8 8e 0d 00 00       	call   fb0 <wait>
    break;
     222:	eb 22                	jmp    246 <runcmd+0x246>
    
  case BACK:
    bcmd = (struct backcmd*)cmd;
     224:	8b 45 08             	mov    0x8(%ebp),%eax
     227:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(fork1() == 0)
     22a:	e8 8d 01 00 00       	call   3bc <fork1>
     22f:	85 c0                	test   %eax,%eax
     231:	75 12                	jne    245 <runcmd+0x245>
      runcmd(bcmd->cmd);
     233:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     236:	8b 40 04             	mov    0x4(%eax),%eax
     239:	83 ec 0c             	sub    $0xc,%esp
     23c:	50                   	push   %eax
     23d:	e8 be fd ff ff       	call   0 <runcmd>
     242:	83 c4 10             	add    $0x10,%esp
    break;
     245:	90                   	nop
  }
  exit();
     246:	e8 5d 0d 00 00       	call   fa8 <exit>

0000024b <getcmd>:
}

int
getcmd(char *buf, int nbuf)
{
     24b:	55                   	push   %ebp
     24c:	89 e5                	mov    %esp,%ebp
     24e:	83 ec 08             	sub    $0x8,%esp
  printf(2, "$ ");
     251:	83 ec 08             	sub    $0x8,%esp
     254:	68 64 15 00 00       	push   $0x1564
     259:	6a 02                	push   $0x2
     25b:	e8 07 0f 00 00       	call   1167 <printf>
     260:	83 c4 10             	add    $0x10,%esp
  memset(buf, 0, nbuf);
     263:	8b 45 0c             	mov    0xc(%ebp),%eax
     266:	83 ec 04             	sub    $0x4,%esp
     269:	50                   	push   %eax
     26a:	6a 00                	push   $0x0
     26c:	ff 75 08             	pushl  0x8(%ebp)
     26f:	e8 c6 0a 00 00       	call   d3a <memset>
     274:	83 c4 10             	add    $0x10,%esp
  gets(buf, nbuf);
     277:	83 ec 08             	sub    $0x8,%esp
     27a:	ff 75 0c             	pushl  0xc(%ebp)
     27d:	ff 75 08             	pushl  0x8(%ebp)
     280:	e8 02 0b 00 00       	call   d87 <gets>
     285:	83 c4 10             	add    $0x10,%esp
  if(buf[0] == 0) // EOF
     288:	8b 45 08             	mov    0x8(%ebp),%eax
     28b:	0f b6 00             	movzbl (%eax),%eax
     28e:	84 c0                	test   %al,%al
     290:	75 07                	jne    299 <getcmd+0x4e>
    return -1;
     292:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     297:	eb 05                	jmp    29e <getcmd+0x53>
  return 0;
     299:	b8 00 00 00 00       	mov    $0x0,%eax
}
     29e:	c9                   	leave  
     29f:	c3                   	ret    

000002a0 <main>:
// ***** processing for shell builtins ends here *****
#endif

int
main(void)
{
     2a0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
     2a4:	83 e4 f0             	and    $0xfffffff0,%esp
     2a7:	ff 71 fc             	pushl  -0x4(%ecx)
     2aa:	55                   	push   %ebp
     2ab:	89 e5                	mov    %esp,%ebp
     2ad:	51                   	push   %ecx
     2ae:	83 ec 14             	sub    $0x14,%esp
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     2b1:	eb 16                	jmp    2c9 <main+0x29>
    if(fd >= 3){
     2b3:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
     2b7:	7e 10                	jle    2c9 <main+0x29>
      close(fd);
     2b9:	83 ec 0c             	sub    $0xc,%esp
     2bc:	ff 75 f4             	pushl  -0xc(%ebp)
     2bf:	e8 0c 0d 00 00       	call   fd0 <close>
     2c4:	83 c4 10             	add    $0x10,%esp
      break;
     2c7:	eb 1b                	jmp    2e4 <main+0x44>
{
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     2c9:	83 ec 08             	sub    $0x8,%esp
     2cc:	6a 02                	push   $0x2
     2ce:	68 67 15 00 00       	push   $0x1567
     2d3:	e8 10 0d 00 00       	call   fe8 <open>
     2d8:	83 c4 10             	add    $0x10,%esp
     2db:	89 45 f4             	mov    %eax,-0xc(%ebp)
     2de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     2e2:	79 cf                	jns    2b3 <main+0x13>
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     2e4:	e9 94 00 00 00       	jmp    37d <main+0xdd>
// add support for built-ins here. cd is a built-in
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     2e9:	0f b6 05 e0 1a 00 00 	movzbl 0x1ae0,%eax
     2f0:	3c 63                	cmp    $0x63,%al
     2f2:	75 5f                	jne    353 <main+0xb3>
     2f4:	0f b6 05 e1 1a 00 00 	movzbl 0x1ae1,%eax
     2fb:	3c 64                	cmp    $0x64,%al
     2fd:	75 54                	jne    353 <main+0xb3>
     2ff:	0f b6 05 e2 1a 00 00 	movzbl 0x1ae2,%eax
     306:	3c 20                	cmp    $0x20,%al
     308:	75 49                	jne    353 <main+0xb3>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
     30a:	83 ec 0c             	sub    $0xc,%esp
     30d:	68 e0 1a 00 00       	push   $0x1ae0
     312:	e8 fc 09 00 00       	call   d13 <strlen>
     317:	83 c4 10             	add    $0x10,%esp
     31a:	83 e8 01             	sub    $0x1,%eax
     31d:	c6 80 e0 1a 00 00 00 	movb   $0x0,0x1ae0(%eax)
      if(chdir(buf+3) < 0)
     324:	b8 e3 1a 00 00       	mov    $0x1ae3,%eax
     329:	83 ec 0c             	sub    $0xc,%esp
     32c:	50                   	push   %eax
     32d:	e8 e6 0c 00 00       	call   1018 <chdir>
     332:	83 c4 10             	add    $0x10,%esp
     335:	85 c0                	test   %eax,%eax
     337:	79 44                	jns    37d <main+0xdd>
        printf(2, "cannot cd %s\n", buf+3);
     339:	b8 e3 1a 00 00       	mov    $0x1ae3,%eax
     33e:	83 ec 04             	sub    $0x4,%esp
     341:	50                   	push   %eax
     342:	68 6f 15 00 00       	push   $0x156f
     347:	6a 02                	push   $0x2
     349:	e8 19 0e 00 00       	call   1167 <printf>
     34e:	83 c4 10             	add    $0x10,%esp
      continue;
     351:	eb 2a                	jmp    37d <main+0xdd>
    if (buf[0]=='_') {     // assume it is a builtin command
      dobuiltin(buf);
      continue;
    }
#endif
    if(fork1() == 0)
     353:	e8 64 00 00 00       	call   3bc <fork1>
     358:	85 c0                	test   %eax,%eax
     35a:	75 1c                	jne    378 <main+0xd8>
      runcmd(parsecmd(buf));
     35c:	83 ec 0c             	sub    $0xc,%esp
     35f:	68 e0 1a 00 00       	push   $0x1ae0
     364:	e8 ab 03 00 00       	call   714 <parsecmd>
     369:	83 c4 10             	add    $0x10,%esp
     36c:	83 ec 0c             	sub    $0xc,%esp
     36f:	50                   	push   %eax
     370:	e8 8b fc ff ff       	call   0 <runcmd>
     375:	83 c4 10             	add    $0x10,%esp
    wait();
     378:	e8 33 0c 00 00       	call   fb0 <wait>
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     37d:	83 ec 08             	sub    $0x8,%esp
     380:	6a 64                	push   $0x64
     382:	68 e0 1a 00 00       	push   $0x1ae0
     387:	e8 bf fe ff ff       	call   24b <getcmd>
     38c:	83 c4 10             	add    $0x10,%esp
     38f:	85 c0                	test   %eax,%eax
     391:	0f 89 52 ff ff ff    	jns    2e9 <main+0x49>
#endif
    if(fork1() == 0)
      runcmd(parsecmd(buf));
    wait();
  }
  exit();
     397:	e8 0c 0c 00 00       	call   fa8 <exit>

0000039c <panic>:
}

void
panic(char *s)
{
     39c:	55                   	push   %ebp
     39d:	89 e5                	mov    %esp,%ebp
     39f:	83 ec 08             	sub    $0x8,%esp
  printf(2, "%s\n", s);
     3a2:	83 ec 04             	sub    $0x4,%esp
     3a5:	ff 75 08             	pushl  0x8(%ebp)
     3a8:	68 7d 15 00 00       	push   $0x157d
     3ad:	6a 02                	push   $0x2
     3af:	e8 b3 0d 00 00       	call   1167 <printf>
     3b4:	83 c4 10             	add    $0x10,%esp
  exit();
     3b7:	e8 ec 0b 00 00       	call   fa8 <exit>

000003bc <fork1>:
}

int
fork1(void)
{
     3bc:	55                   	push   %ebp
     3bd:	89 e5                	mov    %esp,%ebp
     3bf:	83 ec 18             	sub    $0x18,%esp
  int pid;
  
  pid = fork();
     3c2:	e8 d9 0b 00 00       	call   fa0 <fork>
     3c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid == -1)
     3ca:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
     3ce:	75 10                	jne    3e0 <fork1+0x24>
    panic("fork");
     3d0:	83 ec 0c             	sub    $0xc,%esp
     3d3:	68 81 15 00 00       	push   $0x1581
     3d8:	e8 bf ff ff ff       	call   39c <panic>
     3dd:	83 c4 10             	add    $0x10,%esp
  return pid;
     3e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     3e3:	c9                   	leave  
     3e4:	c3                   	ret    

000003e5 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     3e5:	55                   	push   %ebp
     3e6:	89 e5                	mov    %esp,%ebp
     3e8:	83 ec 18             	sub    $0x18,%esp
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3eb:	83 ec 0c             	sub    $0xc,%esp
     3ee:	6a 54                	push   $0x54
     3f0:	e8 45 10 00 00       	call   143a <malloc>
     3f5:	83 c4 10             	add    $0x10,%esp
     3f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     3fb:	83 ec 04             	sub    $0x4,%esp
     3fe:	6a 54                	push   $0x54
     400:	6a 00                	push   $0x0
     402:	ff 75 f4             	pushl  -0xc(%ebp)
     405:	e8 30 09 00 00       	call   d3a <memset>
     40a:	83 c4 10             	add    $0x10,%esp
  cmd->type = EXEC;
     40d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     410:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  return (struct cmd*)cmd;
     416:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     419:	c9                   	leave  
     41a:	c3                   	ret    

0000041b <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     41b:	55                   	push   %ebp
     41c:	89 e5                	mov    %esp,%ebp
     41e:	83 ec 18             	sub    $0x18,%esp
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     421:	83 ec 0c             	sub    $0xc,%esp
     424:	6a 18                	push   $0x18
     426:	e8 0f 10 00 00       	call   143a <malloc>
     42b:	83 c4 10             	add    $0x10,%esp
     42e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     431:	83 ec 04             	sub    $0x4,%esp
     434:	6a 18                	push   $0x18
     436:	6a 00                	push   $0x0
     438:	ff 75 f4             	pushl  -0xc(%ebp)
     43b:	e8 fa 08 00 00       	call   d3a <memset>
     440:	83 c4 10             	add    $0x10,%esp
  cmd->type = REDIR;
     443:	8b 45 f4             	mov    -0xc(%ebp),%eax
     446:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  cmd->cmd = subcmd;
     44c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     44f:	8b 55 08             	mov    0x8(%ebp),%edx
     452:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->file = file;
     455:	8b 45 f4             	mov    -0xc(%ebp),%eax
     458:	8b 55 0c             	mov    0xc(%ebp),%edx
     45b:	89 50 08             	mov    %edx,0x8(%eax)
  cmd->efile = efile;
     45e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     461:	8b 55 10             	mov    0x10(%ebp),%edx
     464:	89 50 0c             	mov    %edx,0xc(%eax)
  cmd->mode = mode;
     467:	8b 45 f4             	mov    -0xc(%ebp),%eax
     46a:	8b 55 14             	mov    0x14(%ebp),%edx
     46d:	89 50 10             	mov    %edx,0x10(%eax)
  cmd->fd = fd;
     470:	8b 45 f4             	mov    -0xc(%ebp),%eax
     473:	8b 55 18             	mov    0x18(%ebp),%edx
     476:	89 50 14             	mov    %edx,0x14(%eax)
  return (struct cmd*)cmd;
     479:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     47c:	c9                   	leave  
     47d:	c3                   	ret    

0000047e <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     47e:	55                   	push   %ebp
     47f:	89 e5                	mov    %esp,%ebp
     481:	83 ec 18             	sub    $0x18,%esp
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     484:	83 ec 0c             	sub    $0xc,%esp
     487:	6a 0c                	push   $0xc
     489:	e8 ac 0f 00 00       	call   143a <malloc>
     48e:	83 c4 10             	add    $0x10,%esp
     491:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     494:	83 ec 04             	sub    $0x4,%esp
     497:	6a 0c                	push   $0xc
     499:	6a 00                	push   $0x0
     49b:	ff 75 f4             	pushl  -0xc(%ebp)
     49e:	e8 97 08 00 00       	call   d3a <memset>
     4a3:	83 c4 10             	add    $0x10,%esp
  cmd->type = PIPE;
     4a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4a9:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
  cmd->left = left;
     4af:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4b2:	8b 55 08             	mov    0x8(%ebp),%edx
     4b5:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     4b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4bb:	8b 55 0c             	mov    0xc(%ebp),%edx
     4be:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     4c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     4c4:	c9                   	leave  
     4c5:	c3                   	ret    

000004c6 <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     4c6:	55                   	push   %ebp
     4c7:	89 e5                	mov    %esp,%ebp
     4c9:	83 ec 18             	sub    $0x18,%esp
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     4cc:	83 ec 0c             	sub    $0xc,%esp
     4cf:	6a 0c                	push   $0xc
     4d1:	e8 64 0f 00 00       	call   143a <malloc>
     4d6:	83 c4 10             	add    $0x10,%esp
     4d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     4dc:	83 ec 04             	sub    $0x4,%esp
     4df:	6a 0c                	push   $0xc
     4e1:	6a 00                	push   $0x0
     4e3:	ff 75 f4             	pushl  -0xc(%ebp)
     4e6:	e8 4f 08 00 00       	call   d3a <memset>
     4eb:	83 c4 10             	add    $0x10,%esp
  cmd->type = LIST;
     4ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4f1:	c7 00 04 00 00 00    	movl   $0x4,(%eax)
  cmd->left = left;
     4f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4fa:	8b 55 08             	mov    0x8(%ebp),%edx
     4fd:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     500:	8b 45 f4             	mov    -0xc(%ebp),%eax
     503:	8b 55 0c             	mov    0xc(%ebp),%edx
     506:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     509:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     50c:	c9                   	leave  
     50d:	c3                   	ret    

0000050e <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     50e:	55                   	push   %ebp
     50f:	89 e5                	mov    %esp,%ebp
     511:	83 ec 18             	sub    $0x18,%esp
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     514:	83 ec 0c             	sub    $0xc,%esp
     517:	6a 08                	push   $0x8
     519:	e8 1c 0f 00 00       	call   143a <malloc>
     51e:	83 c4 10             	add    $0x10,%esp
     521:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     524:	83 ec 04             	sub    $0x4,%esp
     527:	6a 08                	push   $0x8
     529:	6a 00                	push   $0x0
     52b:	ff 75 f4             	pushl  -0xc(%ebp)
     52e:	e8 07 08 00 00       	call   d3a <memset>
     533:	83 c4 10             	add    $0x10,%esp
  cmd->type = BACK;
     536:	8b 45 f4             	mov    -0xc(%ebp),%eax
     539:	c7 00 05 00 00 00    	movl   $0x5,(%eax)
  cmd->cmd = subcmd;
     53f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     542:	8b 55 08             	mov    0x8(%ebp),%edx
     545:	89 50 04             	mov    %edx,0x4(%eax)
  return (struct cmd*)cmd;
     548:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     54b:	c9                   	leave  
     54c:	c3                   	ret    

0000054d <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     54d:	55                   	push   %ebp
     54e:	89 e5                	mov    %esp,%ebp
     550:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int ret;
  
  s = *ps;
     553:	8b 45 08             	mov    0x8(%ebp),%eax
     556:	8b 00                	mov    (%eax),%eax
     558:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     55b:	eb 04                	jmp    561 <gettoken+0x14>
    s++;
     55d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
{
  char *s;
  int ret;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     561:	8b 45 f4             	mov    -0xc(%ebp),%eax
     564:	3b 45 0c             	cmp    0xc(%ebp),%eax
     567:	73 1e                	jae    587 <gettoken+0x3a>
     569:	8b 45 f4             	mov    -0xc(%ebp),%eax
     56c:	0f b6 00             	movzbl (%eax),%eax
     56f:	0f be c0             	movsbl %al,%eax
     572:	83 ec 08             	sub    $0x8,%esp
     575:	50                   	push   %eax
     576:	68 bc 1a 00 00       	push   $0x1abc
     57b:	e8 d4 07 00 00       	call   d54 <strchr>
     580:	83 c4 10             	add    $0x10,%esp
     583:	85 c0                	test   %eax,%eax
     585:	75 d6                	jne    55d <gettoken+0x10>
    s++;
  if(q)
     587:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     58b:	74 08                	je     595 <gettoken+0x48>
    *q = s;
     58d:	8b 45 10             	mov    0x10(%ebp),%eax
     590:	8b 55 f4             	mov    -0xc(%ebp),%edx
     593:	89 10                	mov    %edx,(%eax)
  ret = *s;
     595:	8b 45 f4             	mov    -0xc(%ebp),%eax
     598:	0f b6 00             	movzbl (%eax),%eax
     59b:	0f be c0             	movsbl %al,%eax
     59e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  switch(*s){
     5a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5a4:	0f b6 00             	movzbl (%eax),%eax
     5a7:	0f be c0             	movsbl %al,%eax
     5aa:	83 f8 29             	cmp    $0x29,%eax
     5ad:	7f 14                	jg     5c3 <gettoken+0x76>
     5af:	83 f8 28             	cmp    $0x28,%eax
     5b2:	7d 28                	jge    5dc <gettoken+0x8f>
     5b4:	85 c0                	test   %eax,%eax
     5b6:	0f 84 94 00 00 00    	je     650 <gettoken+0x103>
     5bc:	83 f8 26             	cmp    $0x26,%eax
     5bf:	74 1b                	je     5dc <gettoken+0x8f>
     5c1:	eb 3a                	jmp    5fd <gettoken+0xb0>
     5c3:	83 f8 3e             	cmp    $0x3e,%eax
     5c6:	74 1a                	je     5e2 <gettoken+0x95>
     5c8:	83 f8 3e             	cmp    $0x3e,%eax
     5cb:	7f 0a                	jg     5d7 <gettoken+0x8a>
     5cd:	83 e8 3b             	sub    $0x3b,%eax
     5d0:	83 f8 01             	cmp    $0x1,%eax
     5d3:	77 28                	ja     5fd <gettoken+0xb0>
     5d5:	eb 05                	jmp    5dc <gettoken+0x8f>
     5d7:	83 f8 7c             	cmp    $0x7c,%eax
     5da:	75 21                	jne    5fd <gettoken+0xb0>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     5dc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
     5e0:	eb 75                	jmp    657 <gettoken+0x10a>
  case '>':
    s++;
     5e2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(*s == '>'){
     5e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5e9:	0f b6 00             	movzbl (%eax),%eax
     5ec:	3c 3e                	cmp    $0x3e,%al
     5ee:	75 63                	jne    653 <gettoken+0x106>
      ret = '+';
     5f0:	c7 45 f0 2b 00 00 00 	movl   $0x2b,-0x10(%ebp)
      s++;
     5f7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    break;
     5fb:	eb 56                	jmp    653 <gettoken+0x106>
  default:
    ret = 'a';
     5fd:	c7 45 f0 61 00 00 00 	movl   $0x61,-0x10(%ebp)
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     604:	eb 04                	jmp    60a <gettoken+0xbd>
      s++;
     606:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      s++;
    }
    break;
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     60a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     60d:	3b 45 0c             	cmp    0xc(%ebp),%eax
     610:	73 44                	jae    656 <gettoken+0x109>
     612:	8b 45 f4             	mov    -0xc(%ebp),%eax
     615:	0f b6 00             	movzbl (%eax),%eax
     618:	0f be c0             	movsbl %al,%eax
     61b:	83 ec 08             	sub    $0x8,%esp
     61e:	50                   	push   %eax
     61f:	68 bc 1a 00 00       	push   $0x1abc
     624:	e8 2b 07 00 00       	call   d54 <strchr>
     629:	83 c4 10             	add    $0x10,%esp
     62c:	85 c0                	test   %eax,%eax
     62e:	75 26                	jne    656 <gettoken+0x109>
     630:	8b 45 f4             	mov    -0xc(%ebp),%eax
     633:	0f b6 00             	movzbl (%eax),%eax
     636:	0f be c0             	movsbl %al,%eax
     639:	83 ec 08             	sub    $0x8,%esp
     63c:	50                   	push   %eax
     63d:	68 c4 1a 00 00       	push   $0x1ac4
     642:	e8 0d 07 00 00       	call   d54 <strchr>
     647:	83 c4 10             	add    $0x10,%esp
     64a:	85 c0                	test   %eax,%eax
     64c:	74 b8                	je     606 <gettoken+0xb9>
      s++;
    break;
     64e:	eb 06                	jmp    656 <gettoken+0x109>
  if(q)
    *q = s;
  ret = *s;
  switch(*s){
  case 0:
    break;
     650:	90                   	nop
     651:	eb 04                	jmp    657 <gettoken+0x10a>
    s++;
    if(*s == '>'){
      ret = '+';
      s++;
    }
    break;
     653:	90                   	nop
     654:	eb 01                	jmp    657 <gettoken+0x10a>
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
     656:	90                   	nop
  }
  if(eq)
     657:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     65b:	74 0e                	je     66b <gettoken+0x11e>
    *eq = s;
     65d:	8b 45 14             	mov    0x14(%ebp),%eax
     660:	8b 55 f4             	mov    -0xc(%ebp),%edx
     663:	89 10                	mov    %edx,(%eax)
  
  while(s < es && strchr(whitespace, *s))
     665:	eb 04                	jmp    66b <gettoken+0x11e>
    s++;
     667:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
  }
  if(eq)
    *eq = s;
  
  while(s < es && strchr(whitespace, *s))
     66b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     66e:	3b 45 0c             	cmp    0xc(%ebp),%eax
     671:	73 1e                	jae    691 <gettoken+0x144>
     673:	8b 45 f4             	mov    -0xc(%ebp),%eax
     676:	0f b6 00             	movzbl (%eax),%eax
     679:	0f be c0             	movsbl %al,%eax
     67c:	83 ec 08             	sub    $0x8,%esp
     67f:	50                   	push   %eax
     680:	68 bc 1a 00 00       	push   $0x1abc
     685:	e8 ca 06 00 00       	call   d54 <strchr>
     68a:	83 c4 10             	add    $0x10,%esp
     68d:	85 c0                	test   %eax,%eax
     68f:	75 d6                	jne    667 <gettoken+0x11a>
    s++;
  *ps = s;
     691:	8b 45 08             	mov    0x8(%ebp),%eax
     694:	8b 55 f4             	mov    -0xc(%ebp),%edx
     697:	89 10                	mov    %edx,(%eax)
  return ret;
     699:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     69c:	c9                   	leave  
     69d:	c3                   	ret    

0000069e <peek>:

int
peek(char **ps, char *es, char *toks)
{
     69e:	55                   	push   %ebp
     69f:	89 e5                	mov    %esp,%ebp
     6a1:	83 ec 18             	sub    $0x18,%esp
  char *s;
  
  s = *ps;
     6a4:	8b 45 08             	mov    0x8(%ebp),%eax
     6a7:	8b 00                	mov    (%eax),%eax
     6a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     6ac:	eb 04                	jmp    6b2 <peek+0x14>
    s++;
     6ae:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
peek(char **ps, char *es, char *toks)
{
  char *s;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     6b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6b5:	3b 45 0c             	cmp    0xc(%ebp),%eax
     6b8:	73 1e                	jae    6d8 <peek+0x3a>
     6ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6bd:	0f b6 00             	movzbl (%eax),%eax
     6c0:	0f be c0             	movsbl %al,%eax
     6c3:	83 ec 08             	sub    $0x8,%esp
     6c6:	50                   	push   %eax
     6c7:	68 bc 1a 00 00       	push   $0x1abc
     6cc:	e8 83 06 00 00       	call   d54 <strchr>
     6d1:	83 c4 10             	add    $0x10,%esp
     6d4:	85 c0                	test   %eax,%eax
     6d6:	75 d6                	jne    6ae <peek+0x10>
    s++;
  *ps = s;
     6d8:	8b 45 08             	mov    0x8(%ebp),%eax
     6db:	8b 55 f4             	mov    -0xc(%ebp),%edx
     6de:	89 10                	mov    %edx,(%eax)
  return *s && strchr(toks, *s);
     6e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6e3:	0f b6 00             	movzbl (%eax),%eax
     6e6:	84 c0                	test   %al,%al
     6e8:	74 23                	je     70d <peek+0x6f>
     6ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6ed:	0f b6 00             	movzbl (%eax),%eax
     6f0:	0f be c0             	movsbl %al,%eax
     6f3:	83 ec 08             	sub    $0x8,%esp
     6f6:	50                   	push   %eax
     6f7:	ff 75 10             	pushl  0x10(%ebp)
     6fa:	e8 55 06 00 00       	call   d54 <strchr>
     6ff:	83 c4 10             	add    $0x10,%esp
     702:	85 c0                	test   %eax,%eax
     704:	74 07                	je     70d <peek+0x6f>
     706:	b8 01 00 00 00       	mov    $0x1,%eax
     70b:	eb 05                	jmp    712 <peek+0x74>
     70d:	b8 00 00 00 00       	mov    $0x0,%eax
}
     712:	c9                   	leave  
     713:	c3                   	ret    

00000714 <parsecmd>:
struct cmd *parseexec(char**, char*);
struct cmd *nulterminate(struct cmd*);

struct cmd*
parsecmd(char *s)
{
     714:	55                   	push   %ebp
     715:	89 e5                	mov    %esp,%ebp
     717:	53                   	push   %ebx
     718:	83 ec 14             	sub    $0x14,%esp
  char *es;
  struct cmd *cmd;

  es = s + strlen(s);
     71b:	8b 5d 08             	mov    0x8(%ebp),%ebx
     71e:	8b 45 08             	mov    0x8(%ebp),%eax
     721:	83 ec 0c             	sub    $0xc,%esp
     724:	50                   	push   %eax
     725:	e8 e9 05 00 00       	call   d13 <strlen>
     72a:	83 c4 10             	add    $0x10,%esp
     72d:	01 d8                	add    %ebx,%eax
     72f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cmd = parseline(&s, es);
     732:	83 ec 08             	sub    $0x8,%esp
     735:	ff 75 f4             	pushl  -0xc(%ebp)
     738:	8d 45 08             	lea    0x8(%ebp),%eax
     73b:	50                   	push   %eax
     73c:	e8 61 00 00 00       	call   7a2 <parseline>
     741:	83 c4 10             	add    $0x10,%esp
     744:	89 45 f0             	mov    %eax,-0x10(%ebp)
  peek(&s, es, "");
     747:	83 ec 04             	sub    $0x4,%esp
     74a:	68 86 15 00 00       	push   $0x1586
     74f:	ff 75 f4             	pushl  -0xc(%ebp)
     752:	8d 45 08             	lea    0x8(%ebp),%eax
     755:	50                   	push   %eax
     756:	e8 43 ff ff ff       	call   69e <peek>
     75b:	83 c4 10             	add    $0x10,%esp
  if(s != es){
     75e:	8b 45 08             	mov    0x8(%ebp),%eax
     761:	3b 45 f4             	cmp    -0xc(%ebp),%eax
     764:	74 26                	je     78c <parsecmd+0x78>
    printf(2, "leftovers: %s\n", s);
     766:	8b 45 08             	mov    0x8(%ebp),%eax
     769:	83 ec 04             	sub    $0x4,%esp
     76c:	50                   	push   %eax
     76d:	68 87 15 00 00       	push   $0x1587
     772:	6a 02                	push   $0x2
     774:	e8 ee 09 00 00       	call   1167 <printf>
     779:	83 c4 10             	add    $0x10,%esp
    panic("syntax");
     77c:	83 ec 0c             	sub    $0xc,%esp
     77f:	68 96 15 00 00       	push   $0x1596
     784:	e8 13 fc ff ff       	call   39c <panic>
     789:	83 c4 10             	add    $0x10,%esp
  }
  nulterminate(cmd);
     78c:	83 ec 0c             	sub    $0xc,%esp
     78f:	ff 75 f0             	pushl  -0x10(%ebp)
     792:	e8 eb 03 00 00       	call   b82 <nulterminate>
     797:	83 c4 10             	add    $0x10,%esp
  return cmd;
     79a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     79d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
     7a0:	c9                   	leave  
     7a1:	c3                   	ret    

000007a2 <parseline>:

struct cmd*
parseline(char **ps, char *es)
{
     7a2:	55                   	push   %ebp
     7a3:	89 e5                	mov    %esp,%ebp
     7a5:	83 ec 18             	sub    $0x18,%esp
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
     7a8:	83 ec 08             	sub    $0x8,%esp
     7ab:	ff 75 0c             	pushl  0xc(%ebp)
     7ae:	ff 75 08             	pushl  0x8(%ebp)
     7b1:	e8 99 00 00 00       	call   84f <parsepipe>
     7b6:	83 c4 10             	add    $0x10,%esp
     7b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(peek(ps, es, "&")){
     7bc:	eb 23                	jmp    7e1 <parseline+0x3f>
    gettoken(ps, es, 0, 0);
     7be:	6a 00                	push   $0x0
     7c0:	6a 00                	push   $0x0
     7c2:	ff 75 0c             	pushl  0xc(%ebp)
     7c5:	ff 75 08             	pushl  0x8(%ebp)
     7c8:	e8 80 fd ff ff       	call   54d <gettoken>
     7cd:	83 c4 10             	add    $0x10,%esp
    cmd = backcmd(cmd);
     7d0:	83 ec 0c             	sub    $0xc,%esp
     7d3:	ff 75 f4             	pushl  -0xc(%ebp)
     7d6:	e8 33 fd ff ff       	call   50e <backcmd>
     7db:	83 c4 10             	add    $0x10,%esp
     7de:	89 45 f4             	mov    %eax,-0xc(%ebp)
parseline(char **ps, char *es)
{
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
  while(peek(ps, es, "&")){
     7e1:	83 ec 04             	sub    $0x4,%esp
     7e4:	68 9d 15 00 00       	push   $0x159d
     7e9:	ff 75 0c             	pushl  0xc(%ebp)
     7ec:	ff 75 08             	pushl  0x8(%ebp)
     7ef:	e8 aa fe ff ff       	call   69e <peek>
     7f4:	83 c4 10             	add    $0x10,%esp
     7f7:	85 c0                	test   %eax,%eax
     7f9:	75 c3                	jne    7be <parseline+0x1c>
    gettoken(ps, es, 0, 0);
    cmd = backcmd(cmd);
  }
  if(peek(ps, es, ";")){
     7fb:	83 ec 04             	sub    $0x4,%esp
     7fe:	68 9f 15 00 00       	push   $0x159f
     803:	ff 75 0c             	pushl  0xc(%ebp)
     806:	ff 75 08             	pushl  0x8(%ebp)
     809:	e8 90 fe ff ff       	call   69e <peek>
     80e:	83 c4 10             	add    $0x10,%esp
     811:	85 c0                	test   %eax,%eax
     813:	74 35                	je     84a <parseline+0xa8>
    gettoken(ps, es, 0, 0);
     815:	6a 00                	push   $0x0
     817:	6a 00                	push   $0x0
     819:	ff 75 0c             	pushl  0xc(%ebp)
     81c:	ff 75 08             	pushl  0x8(%ebp)
     81f:	e8 29 fd ff ff       	call   54d <gettoken>
     824:	83 c4 10             	add    $0x10,%esp
    cmd = listcmd(cmd, parseline(ps, es));
     827:	83 ec 08             	sub    $0x8,%esp
     82a:	ff 75 0c             	pushl  0xc(%ebp)
     82d:	ff 75 08             	pushl  0x8(%ebp)
     830:	e8 6d ff ff ff       	call   7a2 <parseline>
     835:	83 c4 10             	add    $0x10,%esp
     838:	83 ec 08             	sub    $0x8,%esp
     83b:	50                   	push   %eax
     83c:	ff 75 f4             	pushl  -0xc(%ebp)
     83f:	e8 82 fc ff ff       	call   4c6 <listcmd>
     844:	83 c4 10             	add    $0x10,%esp
     847:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     84a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     84d:	c9                   	leave  
     84e:	c3                   	ret    

0000084f <parsepipe>:

struct cmd*
parsepipe(char **ps, char *es)
{
     84f:	55                   	push   %ebp
     850:	89 e5                	mov    %esp,%ebp
     852:	83 ec 18             	sub    $0x18,%esp
  struct cmd *cmd;

  cmd = parseexec(ps, es);
     855:	83 ec 08             	sub    $0x8,%esp
     858:	ff 75 0c             	pushl  0xc(%ebp)
     85b:	ff 75 08             	pushl  0x8(%ebp)
     85e:	e8 ec 01 00 00       	call   a4f <parseexec>
     863:	83 c4 10             	add    $0x10,%esp
     866:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(peek(ps, es, "|")){
     869:	83 ec 04             	sub    $0x4,%esp
     86c:	68 a1 15 00 00       	push   $0x15a1
     871:	ff 75 0c             	pushl  0xc(%ebp)
     874:	ff 75 08             	pushl  0x8(%ebp)
     877:	e8 22 fe ff ff       	call   69e <peek>
     87c:	83 c4 10             	add    $0x10,%esp
     87f:	85 c0                	test   %eax,%eax
     881:	74 35                	je     8b8 <parsepipe+0x69>
    gettoken(ps, es, 0, 0);
     883:	6a 00                	push   $0x0
     885:	6a 00                	push   $0x0
     887:	ff 75 0c             	pushl  0xc(%ebp)
     88a:	ff 75 08             	pushl  0x8(%ebp)
     88d:	e8 bb fc ff ff       	call   54d <gettoken>
     892:	83 c4 10             	add    $0x10,%esp
    cmd = pipecmd(cmd, parsepipe(ps, es));
     895:	83 ec 08             	sub    $0x8,%esp
     898:	ff 75 0c             	pushl  0xc(%ebp)
     89b:	ff 75 08             	pushl  0x8(%ebp)
     89e:	e8 ac ff ff ff       	call   84f <parsepipe>
     8a3:	83 c4 10             	add    $0x10,%esp
     8a6:	83 ec 08             	sub    $0x8,%esp
     8a9:	50                   	push   %eax
     8aa:	ff 75 f4             	pushl  -0xc(%ebp)
     8ad:	e8 cc fb ff ff       	call   47e <pipecmd>
     8b2:	83 c4 10             	add    $0x10,%esp
     8b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     8b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     8bb:	c9                   	leave  
     8bc:	c3                   	ret    

000008bd <parseredirs>:

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     8bd:	55                   	push   %ebp
     8be:	89 e5                	mov    %esp,%ebp
     8c0:	83 ec 18             	sub    $0x18,%esp
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     8c3:	e9 b6 00 00 00       	jmp    97e <parseredirs+0xc1>
    tok = gettoken(ps, es, 0, 0);
     8c8:	6a 00                	push   $0x0
     8ca:	6a 00                	push   $0x0
     8cc:	ff 75 10             	pushl  0x10(%ebp)
     8cf:	ff 75 0c             	pushl  0xc(%ebp)
     8d2:	e8 76 fc ff ff       	call   54d <gettoken>
     8d7:	83 c4 10             	add    $0x10,%esp
     8da:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(gettoken(ps, es, &q, &eq) != 'a')
     8dd:	8d 45 ec             	lea    -0x14(%ebp),%eax
     8e0:	50                   	push   %eax
     8e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
     8e4:	50                   	push   %eax
     8e5:	ff 75 10             	pushl  0x10(%ebp)
     8e8:	ff 75 0c             	pushl  0xc(%ebp)
     8eb:	e8 5d fc ff ff       	call   54d <gettoken>
     8f0:	83 c4 10             	add    $0x10,%esp
     8f3:	83 f8 61             	cmp    $0x61,%eax
     8f6:	74 10                	je     908 <parseredirs+0x4b>
      panic("missing file for redirection");
     8f8:	83 ec 0c             	sub    $0xc,%esp
     8fb:	68 a3 15 00 00       	push   $0x15a3
     900:	e8 97 fa ff ff       	call   39c <panic>
     905:	83 c4 10             	add    $0x10,%esp
    switch(tok){
     908:	8b 45 f4             	mov    -0xc(%ebp),%eax
     90b:	83 f8 3c             	cmp    $0x3c,%eax
     90e:	74 0c                	je     91c <parseredirs+0x5f>
     910:	83 f8 3e             	cmp    $0x3e,%eax
     913:	74 26                	je     93b <parseredirs+0x7e>
     915:	83 f8 2b             	cmp    $0x2b,%eax
     918:	74 43                	je     95d <parseredirs+0xa0>
     91a:	eb 62                	jmp    97e <parseredirs+0xc1>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     91c:	8b 55 ec             	mov    -0x14(%ebp),%edx
     91f:	8b 45 f0             	mov    -0x10(%ebp),%eax
     922:	83 ec 0c             	sub    $0xc,%esp
     925:	6a 00                	push   $0x0
     927:	6a 00                	push   $0x0
     929:	52                   	push   %edx
     92a:	50                   	push   %eax
     92b:	ff 75 08             	pushl  0x8(%ebp)
     92e:	e8 e8 fa ff ff       	call   41b <redircmd>
     933:	83 c4 20             	add    $0x20,%esp
     936:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     939:	eb 43                	jmp    97e <parseredirs+0xc1>
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     93b:	8b 55 ec             	mov    -0x14(%ebp),%edx
     93e:	8b 45 f0             	mov    -0x10(%ebp),%eax
     941:	83 ec 0c             	sub    $0xc,%esp
     944:	6a 01                	push   $0x1
     946:	68 01 02 00 00       	push   $0x201
     94b:	52                   	push   %edx
     94c:	50                   	push   %eax
     94d:	ff 75 08             	pushl  0x8(%ebp)
     950:	e8 c6 fa ff ff       	call   41b <redircmd>
     955:	83 c4 20             	add    $0x20,%esp
     958:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     95b:	eb 21                	jmp    97e <parseredirs+0xc1>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     95d:	8b 55 ec             	mov    -0x14(%ebp),%edx
     960:	8b 45 f0             	mov    -0x10(%ebp),%eax
     963:	83 ec 0c             	sub    $0xc,%esp
     966:	6a 01                	push   $0x1
     968:	68 01 02 00 00       	push   $0x201
     96d:	52                   	push   %edx
     96e:	50                   	push   %eax
     96f:	ff 75 08             	pushl  0x8(%ebp)
     972:	e8 a4 fa ff ff       	call   41b <redircmd>
     977:	83 c4 20             	add    $0x20,%esp
     97a:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     97d:	90                   	nop
parseredirs(struct cmd *cmd, char **ps, char *es)
{
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     97e:	83 ec 04             	sub    $0x4,%esp
     981:	68 c0 15 00 00       	push   $0x15c0
     986:	ff 75 10             	pushl  0x10(%ebp)
     989:	ff 75 0c             	pushl  0xc(%ebp)
     98c:	e8 0d fd ff ff       	call   69e <peek>
     991:	83 c4 10             	add    $0x10,%esp
     994:	85 c0                	test   %eax,%eax
     996:	0f 85 2c ff ff ff    	jne    8c8 <parseredirs+0xb>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
      break;
    }
  }
  return cmd;
     99c:	8b 45 08             	mov    0x8(%ebp),%eax
}
     99f:	c9                   	leave  
     9a0:	c3                   	ret    

000009a1 <parseblock>:

struct cmd*
parseblock(char **ps, char *es)
{
     9a1:	55                   	push   %ebp
     9a2:	89 e5                	mov    %esp,%ebp
     9a4:	83 ec 18             	sub    $0x18,%esp
  struct cmd *cmd;

  if(!peek(ps, es, "("))
     9a7:	83 ec 04             	sub    $0x4,%esp
     9aa:	68 c3 15 00 00       	push   $0x15c3
     9af:	ff 75 0c             	pushl  0xc(%ebp)
     9b2:	ff 75 08             	pushl  0x8(%ebp)
     9b5:	e8 e4 fc ff ff       	call   69e <peek>
     9ba:	83 c4 10             	add    $0x10,%esp
     9bd:	85 c0                	test   %eax,%eax
     9bf:	75 10                	jne    9d1 <parseblock+0x30>
    panic("parseblock");
     9c1:	83 ec 0c             	sub    $0xc,%esp
     9c4:	68 c5 15 00 00       	push   $0x15c5
     9c9:	e8 ce f9 ff ff       	call   39c <panic>
     9ce:	83 c4 10             	add    $0x10,%esp
  gettoken(ps, es, 0, 0);
     9d1:	6a 00                	push   $0x0
     9d3:	6a 00                	push   $0x0
     9d5:	ff 75 0c             	pushl  0xc(%ebp)
     9d8:	ff 75 08             	pushl  0x8(%ebp)
     9db:	e8 6d fb ff ff       	call   54d <gettoken>
     9e0:	83 c4 10             	add    $0x10,%esp
  cmd = parseline(ps, es);
     9e3:	83 ec 08             	sub    $0x8,%esp
     9e6:	ff 75 0c             	pushl  0xc(%ebp)
     9e9:	ff 75 08             	pushl  0x8(%ebp)
     9ec:	e8 b1 fd ff ff       	call   7a2 <parseline>
     9f1:	83 c4 10             	add    $0x10,%esp
     9f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!peek(ps, es, ")"))
     9f7:	83 ec 04             	sub    $0x4,%esp
     9fa:	68 d0 15 00 00       	push   $0x15d0
     9ff:	ff 75 0c             	pushl  0xc(%ebp)
     a02:	ff 75 08             	pushl  0x8(%ebp)
     a05:	e8 94 fc ff ff       	call   69e <peek>
     a0a:	83 c4 10             	add    $0x10,%esp
     a0d:	85 c0                	test   %eax,%eax
     a0f:	75 10                	jne    a21 <parseblock+0x80>
    panic("syntax - missing )");
     a11:	83 ec 0c             	sub    $0xc,%esp
     a14:	68 d2 15 00 00       	push   $0x15d2
     a19:	e8 7e f9 ff ff       	call   39c <panic>
     a1e:	83 c4 10             	add    $0x10,%esp
  gettoken(ps, es, 0, 0);
     a21:	6a 00                	push   $0x0
     a23:	6a 00                	push   $0x0
     a25:	ff 75 0c             	pushl  0xc(%ebp)
     a28:	ff 75 08             	pushl  0x8(%ebp)
     a2b:	e8 1d fb ff ff       	call   54d <gettoken>
     a30:	83 c4 10             	add    $0x10,%esp
  cmd = parseredirs(cmd, ps, es);
     a33:	83 ec 04             	sub    $0x4,%esp
     a36:	ff 75 0c             	pushl  0xc(%ebp)
     a39:	ff 75 08             	pushl  0x8(%ebp)
     a3c:	ff 75 f4             	pushl  -0xc(%ebp)
     a3f:	e8 79 fe ff ff       	call   8bd <parseredirs>
     a44:	83 c4 10             	add    $0x10,%esp
     a47:	89 45 f4             	mov    %eax,-0xc(%ebp)
  return cmd;
     a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     a4d:	c9                   	leave  
     a4e:	c3                   	ret    

00000a4f <parseexec>:

struct cmd*
parseexec(char **ps, char *es)
{
     a4f:	55                   	push   %ebp
     a50:	89 e5                	mov    %esp,%ebp
     a52:	83 ec 28             	sub    $0x28,%esp
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;
  
  if(peek(ps, es, "("))
     a55:	83 ec 04             	sub    $0x4,%esp
     a58:	68 c3 15 00 00       	push   $0x15c3
     a5d:	ff 75 0c             	pushl  0xc(%ebp)
     a60:	ff 75 08             	pushl  0x8(%ebp)
     a63:	e8 36 fc ff ff       	call   69e <peek>
     a68:	83 c4 10             	add    $0x10,%esp
     a6b:	85 c0                	test   %eax,%eax
     a6d:	74 16                	je     a85 <parseexec+0x36>
    return parseblock(ps, es);
     a6f:	83 ec 08             	sub    $0x8,%esp
     a72:	ff 75 0c             	pushl  0xc(%ebp)
     a75:	ff 75 08             	pushl  0x8(%ebp)
     a78:	e8 24 ff ff ff       	call   9a1 <parseblock>
     a7d:	83 c4 10             	add    $0x10,%esp
     a80:	e9 fb 00 00 00       	jmp    b80 <parseexec+0x131>

  ret = execcmd();
     a85:	e8 5b f9 ff ff       	call   3e5 <execcmd>
     a8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  cmd = (struct execcmd*)ret;
     a8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
     a90:	89 45 ec             	mov    %eax,-0x14(%ebp)

  argc = 0;
     a93:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  ret = parseredirs(ret, ps, es);
     a9a:	83 ec 04             	sub    $0x4,%esp
     a9d:	ff 75 0c             	pushl  0xc(%ebp)
     aa0:	ff 75 08             	pushl  0x8(%ebp)
     aa3:	ff 75 f0             	pushl  -0x10(%ebp)
     aa6:	e8 12 fe ff ff       	call   8bd <parseredirs>
     aab:	83 c4 10             	add    $0x10,%esp
     aae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while(!peek(ps, es, "|)&;")){
     ab1:	e9 87 00 00 00       	jmp    b3d <parseexec+0xee>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     ab6:	8d 45 e0             	lea    -0x20(%ebp),%eax
     ab9:	50                   	push   %eax
     aba:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     abd:	50                   	push   %eax
     abe:	ff 75 0c             	pushl  0xc(%ebp)
     ac1:	ff 75 08             	pushl  0x8(%ebp)
     ac4:	e8 84 fa ff ff       	call   54d <gettoken>
     ac9:	83 c4 10             	add    $0x10,%esp
     acc:	89 45 e8             	mov    %eax,-0x18(%ebp)
     acf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     ad3:	0f 84 84 00 00 00    	je     b5d <parseexec+0x10e>
      break;
    if(tok != 'a')
     ad9:	83 7d e8 61          	cmpl   $0x61,-0x18(%ebp)
     add:	74 10                	je     aef <parseexec+0xa0>
      panic("syntax");
     adf:	83 ec 0c             	sub    $0xc,%esp
     ae2:	68 96 15 00 00       	push   $0x1596
     ae7:	e8 b0 f8 ff ff       	call   39c <panic>
     aec:	83 c4 10             	add    $0x10,%esp
    cmd->argv[argc] = q;
     aef:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
     af2:	8b 45 ec             	mov    -0x14(%ebp),%eax
     af5:	8b 55 f4             	mov    -0xc(%ebp),%edx
     af8:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
    cmd->eargv[argc] = eq;
     afc:	8b 55 e0             	mov    -0x20(%ebp),%edx
     aff:	8b 45 ec             	mov    -0x14(%ebp),%eax
     b02:	8b 4d f4             	mov    -0xc(%ebp),%ecx
     b05:	83 c1 08             	add    $0x8,%ecx
     b08:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    argc++;
     b0c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(argc >= MAXARGS)
     b10:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     b14:	7e 10                	jle    b26 <parseexec+0xd7>
      panic("too many args");
     b16:	83 ec 0c             	sub    $0xc,%esp
     b19:	68 e5 15 00 00       	push   $0x15e5
     b1e:	e8 79 f8 ff ff       	call   39c <panic>
     b23:	83 c4 10             	add    $0x10,%esp
    ret = parseredirs(ret, ps, es);
     b26:	83 ec 04             	sub    $0x4,%esp
     b29:	ff 75 0c             	pushl  0xc(%ebp)
     b2c:	ff 75 08             	pushl  0x8(%ebp)
     b2f:	ff 75 f0             	pushl  -0x10(%ebp)
     b32:	e8 86 fd ff ff       	call   8bd <parseredirs>
     b37:	83 c4 10             	add    $0x10,%esp
     b3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ret = execcmd();
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
  while(!peek(ps, es, "|)&;")){
     b3d:	83 ec 04             	sub    $0x4,%esp
     b40:	68 f3 15 00 00       	push   $0x15f3
     b45:	ff 75 0c             	pushl  0xc(%ebp)
     b48:	ff 75 08             	pushl  0x8(%ebp)
     b4b:	e8 4e fb ff ff       	call   69e <peek>
     b50:	83 c4 10             	add    $0x10,%esp
     b53:	85 c0                	test   %eax,%eax
     b55:	0f 84 5b ff ff ff    	je     ab6 <parseexec+0x67>
     b5b:	eb 01                	jmp    b5e <parseexec+0x10f>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
     b5d:	90                   	nop
    argc++;
    if(argc >= MAXARGS)
      panic("too many args");
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
     b5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
     b61:	8b 55 f4             	mov    -0xc(%ebp),%edx
     b64:	c7 44 90 04 00 00 00 	movl   $0x0,0x4(%eax,%edx,4)
     b6b:	00 
  cmd->eargv[argc] = 0;
     b6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
     b6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
     b72:	83 c2 08             	add    $0x8,%edx
     b75:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
     b7c:	00 
  return ret;
     b7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     b80:	c9                   	leave  
     b81:	c3                   	ret    

00000b82 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     b82:	55                   	push   %ebp
     b83:	89 e5                	mov    %esp,%ebp
     b85:	83 ec 28             	sub    $0x28,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     b88:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     b8c:	75 0a                	jne    b98 <nulterminate+0x16>
    return 0;
     b8e:	b8 00 00 00 00       	mov    $0x0,%eax
     b93:	e9 e4 00 00 00       	jmp    c7c <nulterminate+0xfa>
  
  switch(cmd->type){
     b98:	8b 45 08             	mov    0x8(%ebp),%eax
     b9b:	8b 00                	mov    (%eax),%eax
     b9d:	83 f8 05             	cmp    $0x5,%eax
     ba0:	0f 87 d3 00 00 00    	ja     c79 <nulterminate+0xf7>
     ba6:	8b 04 85 f8 15 00 00 	mov    0x15f8(,%eax,4),%eax
     bad:	ff e0                	jmp    *%eax
  case EXEC:
    ecmd = (struct execcmd*)cmd;
     baf:	8b 45 08             	mov    0x8(%ebp),%eax
     bb2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(i=0; ecmd->argv[i]; i++)
     bb5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     bbc:	eb 14                	jmp    bd2 <nulterminate+0x50>
      *ecmd->eargv[i] = 0;
     bbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
     bc1:	8b 55 f4             	mov    -0xc(%ebp),%edx
     bc4:	83 c2 08             	add    $0x8,%edx
     bc7:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
     bcb:	c6 00 00             	movb   $0x0,(%eax)
    return 0;
  
  switch(cmd->type){
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     bce:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     bd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
     bd5:	8b 55 f4             	mov    -0xc(%ebp),%edx
     bd8:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
     bdc:	85 c0                	test   %eax,%eax
     bde:	75 de                	jne    bbe <nulterminate+0x3c>
      *ecmd->eargv[i] = 0;
    break;
     be0:	e9 94 00 00 00       	jmp    c79 <nulterminate+0xf7>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
     be5:	8b 45 08             	mov    0x8(%ebp),%eax
     be8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    nulterminate(rcmd->cmd);
     beb:	8b 45 ec             	mov    -0x14(%ebp),%eax
     bee:	8b 40 04             	mov    0x4(%eax),%eax
     bf1:	83 ec 0c             	sub    $0xc,%esp
     bf4:	50                   	push   %eax
     bf5:	e8 88 ff ff ff       	call   b82 <nulterminate>
     bfa:	83 c4 10             	add    $0x10,%esp
    *rcmd->efile = 0;
     bfd:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c00:	8b 40 0c             	mov    0xc(%eax),%eax
     c03:	c6 00 00             	movb   $0x0,(%eax)
    break;
     c06:	eb 71                	jmp    c79 <nulterminate+0xf7>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     c08:	8b 45 08             	mov    0x8(%ebp),%eax
     c0b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nulterminate(pcmd->left);
     c0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
     c11:	8b 40 04             	mov    0x4(%eax),%eax
     c14:	83 ec 0c             	sub    $0xc,%esp
     c17:	50                   	push   %eax
     c18:	e8 65 ff ff ff       	call   b82 <nulterminate>
     c1d:	83 c4 10             	add    $0x10,%esp
    nulterminate(pcmd->right);
     c20:	8b 45 e8             	mov    -0x18(%ebp),%eax
     c23:	8b 40 08             	mov    0x8(%eax),%eax
     c26:	83 ec 0c             	sub    $0xc,%esp
     c29:	50                   	push   %eax
     c2a:	e8 53 ff ff ff       	call   b82 <nulterminate>
     c2f:	83 c4 10             	add    $0x10,%esp
    break;
     c32:	eb 45                	jmp    c79 <nulterminate+0xf7>
    
  case LIST:
    lcmd = (struct listcmd*)cmd;
     c34:	8b 45 08             	mov    0x8(%ebp),%eax
     c37:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nulterminate(lcmd->left);
     c3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     c3d:	8b 40 04             	mov    0x4(%eax),%eax
     c40:	83 ec 0c             	sub    $0xc,%esp
     c43:	50                   	push   %eax
     c44:	e8 39 ff ff ff       	call   b82 <nulterminate>
     c49:	83 c4 10             	add    $0x10,%esp
    nulterminate(lcmd->right);
     c4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     c4f:	8b 40 08             	mov    0x8(%eax),%eax
     c52:	83 ec 0c             	sub    $0xc,%esp
     c55:	50                   	push   %eax
     c56:	e8 27 ff ff ff       	call   b82 <nulterminate>
     c5b:	83 c4 10             	add    $0x10,%esp
    break;
     c5e:	eb 19                	jmp    c79 <nulterminate+0xf7>

  case BACK:
    bcmd = (struct backcmd*)cmd;
     c60:	8b 45 08             	mov    0x8(%ebp),%eax
     c63:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nulterminate(bcmd->cmd);
     c66:	8b 45 e0             	mov    -0x20(%ebp),%eax
     c69:	8b 40 04             	mov    0x4(%eax),%eax
     c6c:	83 ec 0c             	sub    $0xc,%esp
     c6f:	50                   	push   %eax
     c70:	e8 0d ff ff ff       	call   b82 <nulterminate>
     c75:	83 c4 10             	add    $0x10,%esp
    break;
     c78:	90                   	nop
  }
  return cmd;
     c79:	8b 45 08             	mov    0x8(%ebp),%eax
}
     c7c:	c9                   	leave  
     c7d:	c3                   	ret    

00000c7e <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     c7e:	55                   	push   %ebp
     c7f:	89 e5                	mov    %esp,%ebp
     c81:	57                   	push   %edi
     c82:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
     c83:	8b 4d 08             	mov    0x8(%ebp),%ecx
     c86:	8b 55 10             	mov    0x10(%ebp),%edx
     c89:	8b 45 0c             	mov    0xc(%ebp),%eax
     c8c:	89 cb                	mov    %ecx,%ebx
     c8e:	89 df                	mov    %ebx,%edi
     c90:	89 d1                	mov    %edx,%ecx
     c92:	fc                   	cld    
     c93:	f3 aa                	rep stos %al,%es:(%edi)
     c95:	89 ca                	mov    %ecx,%edx
     c97:	89 fb                	mov    %edi,%ebx
     c99:	89 5d 08             	mov    %ebx,0x8(%ebp)
     c9c:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     c9f:	90                   	nop
     ca0:	5b                   	pop    %ebx
     ca1:	5f                   	pop    %edi
     ca2:	5d                   	pop    %ebp
     ca3:	c3                   	ret    

00000ca4 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
     ca4:	55                   	push   %ebp
     ca5:	89 e5                	mov    %esp,%ebp
     ca7:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
     caa:	8b 45 08             	mov    0x8(%ebp),%eax
     cad:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
     cb0:	90                   	nop
     cb1:	8b 45 08             	mov    0x8(%ebp),%eax
     cb4:	8d 50 01             	lea    0x1(%eax),%edx
     cb7:	89 55 08             	mov    %edx,0x8(%ebp)
     cba:	8b 55 0c             	mov    0xc(%ebp),%edx
     cbd:	8d 4a 01             	lea    0x1(%edx),%ecx
     cc0:	89 4d 0c             	mov    %ecx,0xc(%ebp)
     cc3:	0f b6 12             	movzbl (%edx),%edx
     cc6:	88 10                	mov    %dl,(%eax)
     cc8:	0f b6 00             	movzbl (%eax),%eax
     ccb:	84 c0                	test   %al,%al
     ccd:	75 e2                	jne    cb1 <strcpy+0xd>
    ;
  return os;
     ccf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     cd2:	c9                   	leave  
     cd3:	c3                   	ret    

00000cd4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     cd4:	55                   	push   %ebp
     cd5:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
     cd7:	eb 08                	jmp    ce1 <strcmp+0xd>
    p++, q++;
     cd9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     cdd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
     ce1:	8b 45 08             	mov    0x8(%ebp),%eax
     ce4:	0f b6 00             	movzbl (%eax),%eax
     ce7:	84 c0                	test   %al,%al
     ce9:	74 10                	je     cfb <strcmp+0x27>
     ceb:	8b 45 08             	mov    0x8(%ebp),%eax
     cee:	0f b6 10             	movzbl (%eax),%edx
     cf1:	8b 45 0c             	mov    0xc(%ebp),%eax
     cf4:	0f b6 00             	movzbl (%eax),%eax
     cf7:	38 c2                	cmp    %al,%dl
     cf9:	74 de                	je     cd9 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
     cfb:	8b 45 08             	mov    0x8(%ebp),%eax
     cfe:	0f b6 00             	movzbl (%eax),%eax
     d01:	0f b6 d0             	movzbl %al,%edx
     d04:	8b 45 0c             	mov    0xc(%ebp),%eax
     d07:	0f b6 00             	movzbl (%eax),%eax
     d0a:	0f b6 c0             	movzbl %al,%eax
     d0d:	29 c2                	sub    %eax,%edx
     d0f:	89 d0                	mov    %edx,%eax
}
     d11:	5d                   	pop    %ebp
     d12:	c3                   	ret    

00000d13 <strlen>:

uint
strlen(char *s)
{
     d13:	55                   	push   %ebp
     d14:	89 e5                	mov    %esp,%ebp
     d16:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
     d19:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
     d20:	eb 04                	jmp    d26 <strlen+0x13>
     d22:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
     d26:	8b 55 fc             	mov    -0x4(%ebp),%edx
     d29:	8b 45 08             	mov    0x8(%ebp),%eax
     d2c:	01 d0                	add    %edx,%eax
     d2e:	0f b6 00             	movzbl (%eax),%eax
     d31:	84 c0                	test   %al,%al
     d33:	75 ed                	jne    d22 <strlen+0xf>
    ;
  return n;
     d35:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     d38:	c9                   	leave  
     d39:	c3                   	ret    

00000d3a <memset>:

void*
memset(void *dst, int c, uint n)
{
     d3a:	55                   	push   %ebp
     d3b:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
     d3d:	8b 45 10             	mov    0x10(%ebp),%eax
     d40:	50                   	push   %eax
     d41:	ff 75 0c             	pushl  0xc(%ebp)
     d44:	ff 75 08             	pushl  0x8(%ebp)
     d47:	e8 32 ff ff ff       	call   c7e <stosb>
     d4c:	83 c4 0c             	add    $0xc,%esp
  return dst;
     d4f:	8b 45 08             	mov    0x8(%ebp),%eax
}
     d52:	c9                   	leave  
     d53:	c3                   	ret    

00000d54 <strchr>:

char*
strchr(const char *s, char c)
{
     d54:	55                   	push   %ebp
     d55:	89 e5                	mov    %esp,%ebp
     d57:	83 ec 04             	sub    $0x4,%esp
     d5a:	8b 45 0c             	mov    0xc(%ebp),%eax
     d5d:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
     d60:	eb 14                	jmp    d76 <strchr+0x22>
    if(*s == c)
     d62:	8b 45 08             	mov    0x8(%ebp),%eax
     d65:	0f b6 00             	movzbl (%eax),%eax
     d68:	3a 45 fc             	cmp    -0x4(%ebp),%al
     d6b:	75 05                	jne    d72 <strchr+0x1e>
      return (char*)s;
     d6d:	8b 45 08             	mov    0x8(%ebp),%eax
     d70:	eb 13                	jmp    d85 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
     d72:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     d76:	8b 45 08             	mov    0x8(%ebp),%eax
     d79:	0f b6 00             	movzbl (%eax),%eax
     d7c:	84 c0                	test   %al,%al
     d7e:	75 e2                	jne    d62 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
     d80:	b8 00 00 00 00       	mov    $0x0,%eax
}
     d85:	c9                   	leave  
     d86:	c3                   	ret    

00000d87 <gets>:

char*
gets(char *buf, int max)
{
     d87:	55                   	push   %ebp
     d88:	89 e5                	mov    %esp,%ebp
     d8a:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     d8d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     d94:	eb 42                	jmp    dd8 <gets+0x51>
    cc = read(0, &c, 1);
     d96:	83 ec 04             	sub    $0x4,%esp
     d99:	6a 01                	push   $0x1
     d9b:	8d 45 ef             	lea    -0x11(%ebp),%eax
     d9e:	50                   	push   %eax
     d9f:	6a 00                	push   $0x0
     da1:	e8 1a 02 00 00       	call   fc0 <read>
     da6:	83 c4 10             	add    $0x10,%esp
     da9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
     dac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     db0:	7e 33                	jle    de5 <gets+0x5e>
      break;
    buf[i++] = c;
     db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
     db5:	8d 50 01             	lea    0x1(%eax),%edx
     db8:	89 55 f4             	mov    %edx,-0xc(%ebp)
     dbb:	89 c2                	mov    %eax,%edx
     dbd:	8b 45 08             	mov    0x8(%ebp),%eax
     dc0:	01 c2                	add    %eax,%edx
     dc2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     dc6:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
     dc8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     dcc:	3c 0a                	cmp    $0xa,%al
     dce:	74 16                	je     de6 <gets+0x5f>
     dd0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     dd4:	3c 0d                	cmp    $0xd,%al
     dd6:	74 0e                	je     de6 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     dd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ddb:	83 c0 01             	add    $0x1,%eax
     dde:	3b 45 0c             	cmp    0xc(%ebp),%eax
     de1:	7c b3                	jl     d96 <gets+0xf>
     de3:	eb 01                	jmp    de6 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
     de5:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
     de6:	8b 55 f4             	mov    -0xc(%ebp),%edx
     de9:	8b 45 08             	mov    0x8(%ebp),%eax
     dec:	01 d0                	add    %edx,%eax
     dee:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
     df1:	8b 45 08             	mov    0x8(%ebp),%eax
}
     df4:	c9                   	leave  
     df5:	c3                   	ret    

00000df6 <stat>:

int
stat(char *n, struct stat *st)
{
     df6:	55                   	push   %ebp
     df7:	89 e5                	mov    %esp,%ebp
     df9:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     dfc:	83 ec 08             	sub    $0x8,%esp
     dff:	6a 00                	push   $0x0
     e01:	ff 75 08             	pushl  0x8(%ebp)
     e04:	e8 df 01 00 00       	call   fe8 <open>
     e09:	83 c4 10             	add    $0x10,%esp
     e0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
     e0f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     e13:	79 07                	jns    e1c <stat+0x26>
    return -1;
     e15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     e1a:	eb 25                	jmp    e41 <stat+0x4b>
  r = fstat(fd, st);
     e1c:	83 ec 08             	sub    $0x8,%esp
     e1f:	ff 75 0c             	pushl  0xc(%ebp)
     e22:	ff 75 f4             	pushl  -0xc(%ebp)
     e25:	e8 d6 01 00 00       	call   1000 <fstat>
     e2a:	83 c4 10             	add    $0x10,%esp
     e2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
     e30:	83 ec 0c             	sub    $0xc,%esp
     e33:	ff 75 f4             	pushl  -0xc(%ebp)
     e36:	e8 95 01 00 00       	call   fd0 <close>
     e3b:	83 c4 10             	add    $0x10,%esp
  return r;
     e3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     e41:	c9                   	leave  
     e42:	c3                   	ret    

00000e43 <atoi>:

int
atoi(const char *s)
{
     e43:	55                   	push   %ebp
     e44:	89 e5                	mov    %esp,%ebp
     e46:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
     e49:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
     e50:	eb 04                	jmp    e56 <atoi+0x13>
     e52:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     e56:	8b 45 08             	mov    0x8(%ebp),%eax
     e59:	0f b6 00             	movzbl (%eax),%eax
     e5c:	3c 20                	cmp    $0x20,%al
     e5e:	74 f2                	je     e52 <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
     e60:	8b 45 08             	mov    0x8(%ebp),%eax
     e63:	0f b6 00             	movzbl (%eax),%eax
     e66:	3c 2d                	cmp    $0x2d,%al
     e68:	75 07                	jne    e71 <atoi+0x2e>
     e6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     e6f:	eb 05                	jmp    e76 <atoi+0x33>
     e71:	b8 01 00 00 00       	mov    $0x1,%eax
     e76:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
     e79:	8b 45 08             	mov    0x8(%ebp),%eax
     e7c:	0f b6 00             	movzbl (%eax),%eax
     e7f:	3c 2b                	cmp    $0x2b,%al
     e81:	74 0a                	je     e8d <atoi+0x4a>
     e83:	8b 45 08             	mov    0x8(%ebp),%eax
     e86:	0f b6 00             	movzbl (%eax),%eax
     e89:	3c 2d                	cmp    $0x2d,%al
     e8b:	75 2b                	jne    eb8 <atoi+0x75>
    s++;
     e8d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
     e91:	eb 25                	jmp    eb8 <atoi+0x75>
    n = n*10 + *s++ - '0';
     e93:	8b 55 fc             	mov    -0x4(%ebp),%edx
     e96:	89 d0                	mov    %edx,%eax
     e98:	c1 e0 02             	shl    $0x2,%eax
     e9b:	01 d0                	add    %edx,%eax
     e9d:	01 c0                	add    %eax,%eax
     e9f:	89 c1                	mov    %eax,%ecx
     ea1:	8b 45 08             	mov    0x8(%ebp),%eax
     ea4:	8d 50 01             	lea    0x1(%eax),%edx
     ea7:	89 55 08             	mov    %edx,0x8(%ebp)
     eaa:	0f b6 00             	movzbl (%eax),%eax
     ead:	0f be c0             	movsbl %al,%eax
     eb0:	01 c8                	add    %ecx,%eax
     eb2:	83 e8 30             	sub    $0x30,%eax
     eb5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
     eb8:	8b 45 08             	mov    0x8(%ebp),%eax
     ebb:	0f b6 00             	movzbl (%eax),%eax
     ebe:	3c 2f                	cmp    $0x2f,%al
     ec0:	7e 0a                	jle    ecc <atoi+0x89>
     ec2:	8b 45 08             	mov    0x8(%ebp),%eax
     ec5:	0f b6 00             	movzbl (%eax),%eax
     ec8:	3c 39                	cmp    $0x39,%al
     eca:	7e c7                	jle    e93 <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
     ecc:	8b 45 f8             	mov    -0x8(%ebp),%eax
     ecf:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
     ed3:	c9                   	leave  
     ed4:	c3                   	ret    

00000ed5 <atoo>:

int
atoo(const char *s)
{
     ed5:	55                   	push   %ebp
     ed6:	89 e5                	mov    %esp,%ebp
     ed8:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
     edb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
     ee2:	eb 04                	jmp    ee8 <atoo+0x13>
     ee4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     ee8:	8b 45 08             	mov    0x8(%ebp),%eax
     eeb:	0f b6 00             	movzbl (%eax),%eax
     eee:	3c 20                	cmp    $0x20,%al
     ef0:	74 f2                	je     ee4 <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
     ef2:	8b 45 08             	mov    0x8(%ebp),%eax
     ef5:	0f b6 00             	movzbl (%eax),%eax
     ef8:	3c 2d                	cmp    $0x2d,%al
     efa:	75 07                	jne    f03 <atoo+0x2e>
     efc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     f01:	eb 05                	jmp    f08 <atoo+0x33>
     f03:	b8 01 00 00 00       	mov    $0x1,%eax
     f08:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
     f0b:	8b 45 08             	mov    0x8(%ebp),%eax
     f0e:	0f b6 00             	movzbl (%eax),%eax
     f11:	3c 2b                	cmp    $0x2b,%al
     f13:	74 0a                	je     f1f <atoo+0x4a>
     f15:	8b 45 08             	mov    0x8(%ebp),%eax
     f18:	0f b6 00             	movzbl (%eax),%eax
     f1b:	3c 2d                	cmp    $0x2d,%al
     f1d:	75 27                	jne    f46 <atoo+0x71>
    s++;
     f1f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
     f23:	eb 21                	jmp    f46 <atoo+0x71>
    n = n*8 + *s++ - '0';
     f25:	8b 45 fc             	mov    -0x4(%ebp),%eax
     f28:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
     f2f:	8b 45 08             	mov    0x8(%ebp),%eax
     f32:	8d 50 01             	lea    0x1(%eax),%edx
     f35:	89 55 08             	mov    %edx,0x8(%ebp)
     f38:	0f b6 00             	movzbl (%eax),%eax
     f3b:	0f be c0             	movsbl %al,%eax
     f3e:	01 c8                	add    %ecx,%eax
     f40:	83 e8 30             	sub    $0x30,%eax
     f43:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
     f46:	8b 45 08             	mov    0x8(%ebp),%eax
     f49:	0f b6 00             	movzbl (%eax),%eax
     f4c:	3c 2f                	cmp    $0x2f,%al
     f4e:	7e 0a                	jle    f5a <atoo+0x85>
     f50:	8b 45 08             	mov    0x8(%ebp),%eax
     f53:	0f b6 00             	movzbl (%eax),%eax
     f56:	3c 37                	cmp    $0x37,%al
     f58:	7e cb                	jle    f25 <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
     f5a:	8b 45 f8             	mov    -0x8(%ebp),%eax
     f5d:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
     f61:	c9                   	leave  
     f62:	c3                   	ret    

00000f63 <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
     f63:	55                   	push   %ebp
     f64:	89 e5                	mov    %esp,%ebp
     f66:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
     f69:	8b 45 08             	mov    0x8(%ebp),%eax
     f6c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
     f6f:	8b 45 0c             	mov    0xc(%ebp),%eax
     f72:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
     f75:	eb 17                	jmp    f8e <memmove+0x2b>
    *dst++ = *src++;
     f77:	8b 45 fc             	mov    -0x4(%ebp),%eax
     f7a:	8d 50 01             	lea    0x1(%eax),%edx
     f7d:	89 55 fc             	mov    %edx,-0x4(%ebp)
     f80:	8b 55 f8             	mov    -0x8(%ebp),%edx
     f83:	8d 4a 01             	lea    0x1(%edx),%ecx
     f86:	89 4d f8             	mov    %ecx,-0x8(%ebp)
     f89:	0f b6 12             	movzbl (%edx),%edx
     f8c:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
     f8e:	8b 45 10             	mov    0x10(%ebp),%eax
     f91:	8d 50 ff             	lea    -0x1(%eax),%edx
     f94:	89 55 10             	mov    %edx,0x10(%ebp)
     f97:	85 c0                	test   %eax,%eax
     f99:	7f dc                	jg     f77 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
     f9b:	8b 45 08             	mov    0x8(%ebp),%eax
}
     f9e:	c9                   	leave  
     f9f:	c3                   	ret    

00000fa0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
     fa0:	b8 01 00 00 00       	mov    $0x1,%eax
     fa5:	cd 40                	int    $0x40
     fa7:	c3                   	ret    

00000fa8 <exit>:
SYSCALL(exit)
     fa8:	b8 02 00 00 00       	mov    $0x2,%eax
     fad:	cd 40                	int    $0x40
     faf:	c3                   	ret    

00000fb0 <wait>:
SYSCALL(wait)
     fb0:	b8 03 00 00 00       	mov    $0x3,%eax
     fb5:	cd 40                	int    $0x40
     fb7:	c3                   	ret    

00000fb8 <pipe>:
SYSCALL(pipe)
     fb8:	b8 04 00 00 00       	mov    $0x4,%eax
     fbd:	cd 40                	int    $0x40
     fbf:	c3                   	ret    

00000fc0 <read>:
SYSCALL(read)
     fc0:	b8 05 00 00 00       	mov    $0x5,%eax
     fc5:	cd 40                	int    $0x40
     fc7:	c3                   	ret    

00000fc8 <write>:
SYSCALL(write)
     fc8:	b8 10 00 00 00       	mov    $0x10,%eax
     fcd:	cd 40                	int    $0x40
     fcf:	c3                   	ret    

00000fd0 <close>:
SYSCALL(close)
     fd0:	b8 15 00 00 00       	mov    $0x15,%eax
     fd5:	cd 40                	int    $0x40
     fd7:	c3                   	ret    

00000fd8 <kill>:
SYSCALL(kill)
     fd8:	b8 06 00 00 00       	mov    $0x6,%eax
     fdd:	cd 40                	int    $0x40
     fdf:	c3                   	ret    

00000fe0 <exec>:
SYSCALL(exec)
     fe0:	b8 07 00 00 00       	mov    $0x7,%eax
     fe5:	cd 40                	int    $0x40
     fe7:	c3                   	ret    

00000fe8 <open>:
SYSCALL(open)
     fe8:	b8 0f 00 00 00       	mov    $0xf,%eax
     fed:	cd 40                	int    $0x40
     fef:	c3                   	ret    

00000ff0 <mknod>:
SYSCALL(mknod)
     ff0:	b8 11 00 00 00       	mov    $0x11,%eax
     ff5:	cd 40                	int    $0x40
     ff7:	c3                   	ret    

00000ff8 <unlink>:
SYSCALL(unlink)
     ff8:	b8 12 00 00 00       	mov    $0x12,%eax
     ffd:	cd 40                	int    $0x40
     fff:	c3                   	ret    

00001000 <fstat>:
SYSCALL(fstat)
    1000:	b8 08 00 00 00       	mov    $0x8,%eax
    1005:	cd 40                	int    $0x40
    1007:	c3                   	ret    

00001008 <link>:
SYSCALL(link)
    1008:	b8 13 00 00 00       	mov    $0x13,%eax
    100d:	cd 40                	int    $0x40
    100f:	c3                   	ret    

00001010 <mkdir>:
SYSCALL(mkdir)
    1010:	b8 14 00 00 00       	mov    $0x14,%eax
    1015:	cd 40                	int    $0x40
    1017:	c3                   	ret    

00001018 <chdir>:
SYSCALL(chdir)
    1018:	b8 09 00 00 00       	mov    $0x9,%eax
    101d:	cd 40                	int    $0x40
    101f:	c3                   	ret    

00001020 <dup>:
SYSCALL(dup)
    1020:	b8 0a 00 00 00       	mov    $0xa,%eax
    1025:	cd 40                	int    $0x40
    1027:	c3                   	ret    

00001028 <getpid>:
SYSCALL(getpid)
    1028:	b8 0b 00 00 00       	mov    $0xb,%eax
    102d:	cd 40                	int    $0x40
    102f:	c3                   	ret    

00001030 <sbrk>:
SYSCALL(sbrk)
    1030:	b8 0c 00 00 00       	mov    $0xc,%eax
    1035:	cd 40                	int    $0x40
    1037:	c3                   	ret    

00001038 <sleep>:
SYSCALL(sleep)
    1038:	b8 0d 00 00 00       	mov    $0xd,%eax
    103d:	cd 40                	int    $0x40
    103f:	c3                   	ret    

00001040 <uptime>:
SYSCALL(uptime)
    1040:	b8 0e 00 00 00       	mov    $0xe,%eax
    1045:	cd 40                	int    $0x40
    1047:	c3                   	ret    

00001048 <halt>:
SYSCALL(halt)
    1048:	b8 16 00 00 00       	mov    $0x16,%eax
    104d:	cd 40                	int    $0x40
    104f:	c3                   	ret    

00001050 <date>:
SYSCALL(date)
    1050:	b8 17 00 00 00       	mov    $0x17,%eax
    1055:	cd 40                	int    $0x40
    1057:	c3                   	ret    

00001058 <getuid>:
SYSCALL(getuid)
    1058:	b8 18 00 00 00       	mov    $0x18,%eax
    105d:	cd 40                	int    $0x40
    105f:	c3                   	ret    

00001060 <getgid>:
SYSCALL(getgid)
    1060:	b8 19 00 00 00       	mov    $0x19,%eax
    1065:	cd 40                	int    $0x40
    1067:	c3                   	ret    

00001068 <getppid>:
SYSCALL(getppid)
    1068:	b8 1a 00 00 00       	mov    $0x1a,%eax
    106d:	cd 40                	int    $0x40
    106f:	c3                   	ret    

00001070 <setuid>:
SYSCALL(setuid)
    1070:	b8 1b 00 00 00       	mov    $0x1b,%eax
    1075:	cd 40                	int    $0x40
    1077:	c3                   	ret    

00001078 <setgid>:
SYSCALL(setgid)
    1078:	b8 1c 00 00 00       	mov    $0x1c,%eax
    107d:	cd 40                	int    $0x40
    107f:	c3                   	ret    

00001080 <getprocs>:
SYSCALL(getprocs)
    1080:	b8 1a 00 00 00       	mov    $0x1a,%eax
    1085:	cd 40                	int    $0x40
    1087:	c3                   	ret    

00001088 <setpriority>:
SYSCALL(setpriority)
    1088:	b8 1b 00 00 00       	mov    $0x1b,%eax
    108d:	cd 40                	int    $0x40
    108f:	c3                   	ret    

00001090 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    1090:	55                   	push   %ebp
    1091:	89 e5                	mov    %esp,%ebp
    1093:	83 ec 18             	sub    $0x18,%esp
    1096:	8b 45 0c             	mov    0xc(%ebp),%eax
    1099:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    109c:	83 ec 04             	sub    $0x4,%esp
    109f:	6a 01                	push   $0x1
    10a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
    10a4:	50                   	push   %eax
    10a5:	ff 75 08             	pushl  0x8(%ebp)
    10a8:	e8 1b ff ff ff       	call   fc8 <write>
    10ad:	83 c4 10             	add    $0x10,%esp
}
    10b0:	90                   	nop
    10b1:	c9                   	leave  
    10b2:	c3                   	ret    

000010b3 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    10b3:	55                   	push   %ebp
    10b4:	89 e5                	mov    %esp,%ebp
    10b6:	53                   	push   %ebx
    10b7:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    10ba:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    10c1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    10c5:	74 17                	je     10de <printint+0x2b>
    10c7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    10cb:	79 11                	jns    10de <printint+0x2b>
    neg = 1;
    10cd:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    10d4:	8b 45 0c             	mov    0xc(%ebp),%eax
    10d7:	f7 d8                	neg    %eax
    10d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    10dc:	eb 06                	jmp    10e4 <printint+0x31>
  } else {
    x = xx;
    10de:	8b 45 0c             	mov    0xc(%ebp),%eax
    10e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    10e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    10eb:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    10ee:	8d 41 01             	lea    0x1(%ecx),%eax
    10f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    10f4:	8b 5d 10             	mov    0x10(%ebp),%ebx
    10f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
    10fa:	ba 00 00 00 00       	mov    $0x0,%edx
    10ff:	f7 f3                	div    %ebx
    1101:	89 d0                	mov    %edx,%eax
    1103:	0f b6 80 cc 1a 00 00 	movzbl 0x1acc(%eax),%eax
    110a:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    110e:	8b 5d 10             	mov    0x10(%ebp),%ebx
    1111:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1114:	ba 00 00 00 00       	mov    $0x0,%edx
    1119:	f7 f3                	div    %ebx
    111b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    111e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1122:	75 c7                	jne    10eb <printint+0x38>
  if(neg)
    1124:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1128:	74 2d                	je     1157 <printint+0xa4>
    buf[i++] = '-';
    112a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    112d:	8d 50 01             	lea    0x1(%eax),%edx
    1130:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1133:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    1138:	eb 1d                	jmp    1157 <printint+0xa4>
    putc(fd, buf[i]);
    113a:	8d 55 dc             	lea    -0x24(%ebp),%edx
    113d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1140:	01 d0                	add    %edx,%eax
    1142:	0f b6 00             	movzbl (%eax),%eax
    1145:	0f be c0             	movsbl %al,%eax
    1148:	83 ec 08             	sub    $0x8,%esp
    114b:	50                   	push   %eax
    114c:	ff 75 08             	pushl  0x8(%ebp)
    114f:	e8 3c ff ff ff       	call   1090 <putc>
    1154:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    1157:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    115b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    115f:	79 d9                	jns    113a <printint+0x87>
    putc(fd, buf[i]);
}
    1161:	90                   	nop
    1162:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    1165:	c9                   	leave  
    1166:	c3                   	ret    

00001167 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    1167:	55                   	push   %ebp
    1168:	89 e5                	mov    %esp,%ebp
    116a:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    116d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    1174:	8d 45 0c             	lea    0xc(%ebp),%eax
    1177:	83 c0 04             	add    $0x4,%eax
    117a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    117d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1184:	e9 59 01 00 00       	jmp    12e2 <printf+0x17b>
    c = fmt[i] & 0xff;
    1189:	8b 55 0c             	mov    0xc(%ebp),%edx
    118c:	8b 45 f0             	mov    -0x10(%ebp),%eax
    118f:	01 d0                	add    %edx,%eax
    1191:	0f b6 00             	movzbl (%eax),%eax
    1194:	0f be c0             	movsbl %al,%eax
    1197:	25 ff 00 00 00       	and    $0xff,%eax
    119c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    119f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    11a3:	75 2c                	jne    11d1 <printf+0x6a>
      if(c == '%'){
    11a5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    11a9:	75 0c                	jne    11b7 <printf+0x50>
        state = '%';
    11ab:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    11b2:	e9 27 01 00 00       	jmp    12de <printf+0x177>
      } else {
        putc(fd, c);
    11b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    11ba:	0f be c0             	movsbl %al,%eax
    11bd:	83 ec 08             	sub    $0x8,%esp
    11c0:	50                   	push   %eax
    11c1:	ff 75 08             	pushl  0x8(%ebp)
    11c4:	e8 c7 fe ff ff       	call   1090 <putc>
    11c9:	83 c4 10             	add    $0x10,%esp
    11cc:	e9 0d 01 00 00       	jmp    12de <printf+0x177>
      }
    } else if(state == '%'){
    11d1:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    11d5:	0f 85 03 01 00 00    	jne    12de <printf+0x177>
      if(c == 'd'){
    11db:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    11df:	75 1e                	jne    11ff <printf+0x98>
        printint(fd, *ap, 10, 1);
    11e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
    11e4:	8b 00                	mov    (%eax),%eax
    11e6:	6a 01                	push   $0x1
    11e8:	6a 0a                	push   $0xa
    11ea:	50                   	push   %eax
    11eb:	ff 75 08             	pushl  0x8(%ebp)
    11ee:	e8 c0 fe ff ff       	call   10b3 <printint>
    11f3:	83 c4 10             	add    $0x10,%esp
        ap++;
    11f6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    11fa:	e9 d8 00 00 00       	jmp    12d7 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
    11ff:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    1203:	74 06                	je     120b <printf+0xa4>
    1205:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    1209:	75 1e                	jne    1229 <printf+0xc2>
        printint(fd, *ap, 16, 0);
    120b:	8b 45 e8             	mov    -0x18(%ebp),%eax
    120e:	8b 00                	mov    (%eax),%eax
    1210:	6a 00                	push   $0x0
    1212:	6a 10                	push   $0x10
    1214:	50                   	push   %eax
    1215:	ff 75 08             	pushl  0x8(%ebp)
    1218:	e8 96 fe ff ff       	call   10b3 <printint>
    121d:	83 c4 10             	add    $0x10,%esp
        ap++;
    1220:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1224:	e9 ae 00 00 00       	jmp    12d7 <printf+0x170>
      } else if(c == 's'){
    1229:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    122d:	75 43                	jne    1272 <printf+0x10b>
        s = (char*)*ap;
    122f:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1232:	8b 00                	mov    (%eax),%eax
    1234:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    1237:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    123b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    123f:	75 25                	jne    1266 <printf+0xff>
          s = "(null)";
    1241:	c7 45 f4 10 16 00 00 	movl   $0x1610,-0xc(%ebp)
        while(*s != 0){
    1248:	eb 1c                	jmp    1266 <printf+0xff>
          putc(fd, *s);
    124a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    124d:	0f b6 00             	movzbl (%eax),%eax
    1250:	0f be c0             	movsbl %al,%eax
    1253:	83 ec 08             	sub    $0x8,%esp
    1256:	50                   	push   %eax
    1257:	ff 75 08             	pushl  0x8(%ebp)
    125a:	e8 31 fe ff ff       	call   1090 <putc>
    125f:	83 c4 10             	add    $0x10,%esp
          s++;
    1262:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    1266:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1269:	0f b6 00             	movzbl (%eax),%eax
    126c:	84 c0                	test   %al,%al
    126e:	75 da                	jne    124a <printf+0xe3>
    1270:	eb 65                	jmp    12d7 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1272:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    1276:	75 1d                	jne    1295 <printf+0x12e>
        putc(fd, *ap);
    1278:	8b 45 e8             	mov    -0x18(%ebp),%eax
    127b:	8b 00                	mov    (%eax),%eax
    127d:	0f be c0             	movsbl %al,%eax
    1280:	83 ec 08             	sub    $0x8,%esp
    1283:	50                   	push   %eax
    1284:	ff 75 08             	pushl  0x8(%ebp)
    1287:	e8 04 fe ff ff       	call   1090 <putc>
    128c:	83 c4 10             	add    $0x10,%esp
        ap++;
    128f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1293:	eb 42                	jmp    12d7 <printf+0x170>
      } else if(c == '%'){
    1295:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1299:	75 17                	jne    12b2 <printf+0x14b>
        putc(fd, c);
    129b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    129e:	0f be c0             	movsbl %al,%eax
    12a1:	83 ec 08             	sub    $0x8,%esp
    12a4:	50                   	push   %eax
    12a5:	ff 75 08             	pushl  0x8(%ebp)
    12a8:	e8 e3 fd ff ff       	call   1090 <putc>
    12ad:	83 c4 10             	add    $0x10,%esp
    12b0:	eb 25                	jmp    12d7 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    12b2:	83 ec 08             	sub    $0x8,%esp
    12b5:	6a 25                	push   $0x25
    12b7:	ff 75 08             	pushl  0x8(%ebp)
    12ba:	e8 d1 fd ff ff       	call   1090 <putc>
    12bf:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
    12c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    12c5:	0f be c0             	movsbl %al,%eax
    12c8:	83 ec 08             	sub    $0x8,%esp
    12cb:	50                   	push   %eax
    12cc:	ff 75 08             	pushl  0x8(%ebp)
    12cf:	e8 bc fd ff ff       	call   1090 <putc>
    12d4:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
    12d7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    12de:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    12e2:	8b 55 0c             	mov    0xc(%ebp),%edx
    12e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
    12e8:	01 d0                	add    %edx,%eax
    12ea:	0f b6 00             	movzbl (%eax),%eax
    12ed:	84 c0                	test   %al,%al
    12ef:	0f 85 94 fe ff ff    	jne    1189 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    12f5:	90                   	nop
    12f6:	c9                   	leave  
    12f7:	c3                   	ret    

000012f8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    12f8:	55                   	push   %ebp
    12f9:	89 e5                	mov    %esp,%ebp
    12fb:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    12fe:	8b 45 08             	mov    0x8(%ebp),%eax
    1301:	83 e8 08             	sub    $0x8,%eax
    1304:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1307:	a1 4c 1b 00 00       	mov    0x1b4c,%eax
    130c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    130f:	eb 24                	jmp    1335 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1311:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1314:	8b 00                	mov    (%eax),%eax
    1316:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1319:	77 12                	ja     132d <free+0x35>
    131b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    131e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1321:	77 24                	ja     1347 <free+0x4f>
    1323:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1326:	8b 00                	mov    (%eax),%eax
    1328:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    132b:	77 1a                	ja     1347 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    132d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1330:	8b 00                	mov    (%eax),%eax
    1332:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1335:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1338:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    133b:	76 d4                	jbe    1311 <free+0x19>
    133d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1340:	8b 00                	mov    (%eax),%eax
    1342:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1345:	76 ca                	jbe    1311 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    1347:	8b 45 f8             	mov    -0x8(%ebp),%eax
    134a:	8b 40 04             	mov    0x4(%eax),%eax
    134d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1354:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1357:	01 c2                	add    %eax,%edx
    1359:	8b 45 fc             	mov    -0x4(%ebp),%eax
    135c:	8b 00                	mov    (%eax),%eax
    135e:	39 c2                	cmp    %eax,%edx
    1360:	75 24                	jne    1386 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    1362:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1365:	8b 50 04             	mov    0x4(%eax),%edx
    1368:	8b 45 fc             	mov    -0x4(%ebp),%eax
    136b:	8b 00                	mov    (%eax),%eax
    136d:	8b 40 04             	mov    0x4(%eax),%eax
    1370:	01 c2                	add    %eax,%edx
    1372:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1375:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    1378:	8b 45 fc             	mov    -0x4(%ebp),%eax
    137b:	8b 00                	mov    (%eax),%eax
    137d:	8b 10                	mov    (%eax),%edx
    137f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1382:	89 10                	mov    %edx,(%eax)
    1384:	eb 0a                	jmp    1390 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    1386:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1389:	8b 10                	mov    (%eax),%edx
    138b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    138e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    1390:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1393:	8b 40 04             	mov    0x4(%eax),%eax
    1396:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    139d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13a0:	01 d0                	add    %edx,%eax
    13a2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    13a5:	75 20                	jne    13c7 <free+0xcf>
    p->s.size += bp->s.size;
    13a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13aa:	8b 50 04             	mov    0x4(%eax),%edx
    13ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
    13b0:	8b 40 04             	mov    0x4(%eax),%eax
    13b3:	01 c2                	add    %eax,%edx
    13b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13b8:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    13bb:	8b 45 f8             	mov    -0x8(%ebp),%eax
    13be:	8b 10                	mov    (%eax),%edx
    13c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13c3:	89 10                	mov    %edx,(%eax)
    13c5:	eb 08                	jmp    13cf <free+0xd7>
  } else
    p->s.ptr = bp;
    13c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13ca:	8b 55 f8             	mov    -0x8(%ebp),%edx
    13cd:	89 10                	mov    %edx,(%eax)
  freep = p;
    13cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13d2:	a3 4c 1b 00 00       	mov    %eax,0x1b4c
}
    13d7:	90                   	nop
    13d8:	c9                   	leave  
    13d9:	c3                   	ret    

000013da <morecore>:

static Header*
morecore(uint nu)
{
    13da:	55                   	push   %ebp
    13db:	89 e5                	mov    %esp,%ebp
    13dd:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    13e0:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    13e7:	77 07                	ja     13f0 <morecore+0x16>
    nu = 4096;
    13e9:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    13f0:	8b 45 08             	mov    0x8(%ebp),%eax
    13f3:	c1 e0 03             	shl    $0x3,%eax
    13f6:	83 ec 0c             	sub    $0xc,%esp
    13f9:	50                   	push   %eax
    13fa:	e8 31 fc ff ff       	call   1030 <sbrk>
    13ff:	83 c4 10             	add    $0x10,%esp
    1402:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    1405:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    1409:	75 07                	jne    1412 <morecore+0x38>
    return 0;
    140b:	b8 00 00 00 00       	mov    $0x0,%eax
    1410:	eb 26                	jmp    1438 <morecore+0x5e>
  hp = (Header*)p;
    1412:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1415:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    1418:	8b 45 f0             	mov    -0x10(%ebp),%eax
    141b:	8b 55 08             	mov    0x8(%ebp),%edx
    141e:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    1421:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1424:	83 c0 08             	add    $0x8,%eax
    1427:	83 ec 0c             	sub    $0xc,%esp
    142a:	50                   	push   %eax
    142b:	e8 c8 fe ff ff       	call   12f8 <free>
    1430:	83 c4 10             	add    $0x10,%esp
  return freep;
    1433:	a1 4c 1b 00 00       	mov    0x1b4c,%eax
}
    1438:	c9                   	leave  
    1439:	c3                   	ret    

0000143a <malloc>:

void*
malloc(uint nbytes)
{
    143a:	55                   	push   %ebp
    143b:	89 e5                	mov    %esp,%ebp
    143d:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1440:	8b 45 08             	mov    0x8(%ebp),%eax
    1443:	83 c0 07             	add    $0x7,%eax
    1446:	c1 e8 03             	shr    $0x3,%eax
    1449:	83 c0 01             	add    $0x1,%eax
    144c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    144f:	a1 4c 1b 00 00       	mov    0x1b4c,%eax
    1454:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1457:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    145b:	75 23                	jne    1480 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    145d:	c7 45 f0 44 1b 00 00 	movl   $0x1b44,-0x10(%ebp)
    1464:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1467:	a3 4c 1b 00 00       	mov    %eax,0x1b4c
    146c:	a1 4c 1b 00 00       	mov    0x1b4c,%eax
    1471:	a3 44 1b 00 00       	mov    %eax,0x1b44
    base.s.size = 0;
    1476:	c7 05 48 1b 00 00 00 	movl   $0x0,0x1b48
    147d:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1480:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1483:	8b 00                	mov    (%eax),%eax
    1485:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    1488:	8b 45 f4             	mov    -0xc(%ebp),%eax
    148b:	8b 40 04             	mov    0x4(%eax),%eax
    148e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1491:	72 4d                	jb     14e0 <malloc+0xa6>
      if(p->s.size == nunits)
    1493:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1496:	8b 40 04             	mov    0x4(%eax),%eax
    1499:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    149c:	75 0c                	jne    14aa <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    149e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14a1:	8b 10                	mov    (%eax),%edx
    14a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
    14a6:	89 10                	mov    %edx,(%eax)
    14a8:	eb 26                	jmp    14d0 <malloc+0x96>
      else {
        p->s.size -= nunits;
    14aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14ad:	8b 40 04             	mov    0x4(%eax),%eax
    14b0:	2b 45 ec             	sub    -0x14(%ebp),%eax
    14b3:	89 c2                	mov    %eax,%edx
    14b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14b8:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    14bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14be:	8b 40 04             	mov    0x4(%eax),%eax
    14c1:	c1 e0 03             	shl    $0x3,%eax
    14c4:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    14c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14ca:	8b 55 ec             	mov    -0x14(%ebp),%edx
    14cd:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    14d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
    14d3:	a3 4c 1b 00 00       	mov    %eax,0x1b4c
      return (void*)(p + 1);
    14d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14db:	83 c0 08             	add    $0x8,%eax
    14de:	eb 3b                	jmp    151b <malloc+0xe1>
    }
    if(p == freep)
    14e0:	a1 4c 1b 00 00       	mov    0x1b4c,%eax
    14e5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    14e8:	75 1e                	jne    1508 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
    14ea:	83 ec 0c             	sub    $0xc,%esp
    14ed:	ff 75 ec             	pushl  -0x14(%ebp)
    14f0:	e8 e5 fe ff ff       	call   13da <morecore>
    14f5:	83 c4 10             	add    $0x10,%esp
    14f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    14fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    14ff:	75 07                	jne    1508 <malloc+0xce>
        return 0;
    1501:	b8 00 00 00 00       	mov    $0x0,%eax
    1506:	eb 13                	jmp    151b <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1508:	8b 45 f4             	mov    -0xc(%ebp),%eax
    150b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    150e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1511:	8b 00                	mov    (%eax),%eax
    1513:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    1516:	e9 6d ff ff ff       	jmp    1488 <malloc+0x4e>
}
    151b:	c9                   	leave  
    151c:	c3                   	ret    

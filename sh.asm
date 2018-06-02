
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
       c:	e8 ad 12 00 00       	call   12be <exit>

  switch(cmd->type){
      11:	8b 45 08             	mov    0x8(%ebp),%eax
      14:	8b 00                	mov    (%eax),%eax
      16:	83 f8 05             	cmp    $0x5,%eax
      19:	77 09                	ja     24 <runcmd+0x24>
      1b:	8b 04 85 78 18 00 00 	mov    0x1878(,%eax,4),%eax
      22:	ff e0                	jmp    *%eax
  default:
    panic("runcmd");
      24:	83 ec 0c             	sub    $0xc,%esp
      27:	68 4c 18 00 00       	push   $0x184c
      2c:	e8 81 06 00 00       	call   6b2 <panic>
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
      44:	e8 75 12 00 00       	call   12be <exit>
    exec(ecmd->argv[0], ecmd->argv);
      49:	8b 45 f4             	mov    -0xc(%ebp),%eax
      4c:	8d 50 04             	lea    0x4(%eax),%edx
      4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
      52:	8b 40 04             	mov    0x4(%eax),%eax
      55:	83 ec 08             	sub    $0x8,%esp
      58:	52                   	push   %edx
      59:	50                   	push   %eax
      5a:	e8 97 12 00 00       	call   12f6 <exec>
      5f:	83 c4 10             	add    $0x10,%esp
    printf(2, "exec %s failed\n", ecmd->argv[0]);
      62:	8b 45 f4             	mov    -0xc(%ebp),%eax
      65:	8b 40 04             	mov    0x4(%eax),%eax
      68:	83 ec 04             	sub    $0x4,%esp
      6b:	50                   	push   %eax
      6c:	68 53 18 00 00       	push   $0x1853
      71:	6a 02                	push   $0x2
      73:	e8 1d 14 00 00       	call   1495 <printf>
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
      90:	e8 51 12 00 00       	call   12e6 <close>
      95:	83 c4 10             	add    $0x10,%esp
    if(open(rcmd->file, rcmd->mode) < 0){
      98:	8b 45 f0             	mov    -0x10(%ebp),%eax
      9b:	8b 50 10             	mov    0x10(%eax),%edx
      9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
      a1:	8b 40 08             	mov    0x8(%eax),%eax
      a4:	83 ec 08             	sub    $0x8,%esp
      a7:	52                   	push   %edx
      a8:	50                   	push   %eax
      a9:	e8 50 12 00 00       	call   12fe <open>
      ae:	83 c4 10             	add    $0x10,%esp
      b1:	85 c0                	test   %eax,%eax
      b3:	79 1e                	jns    d3 <runcmd+0xd3>
      printf(2, "open %s failed\n", rcmd->file);
      b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
      b8:	8b 40 08             	mov    0x8(%eax),%eax
      bb:	83 ec 04             	sub    $0x4,%esp
      be:	50                   	push   %eax
      bf:	68 63 18 00 00       	push   $0x1863
      c4:	6a 02                	push   $0x2
      c6:	e8 ca 13 00 00       	call   1495 <printf>
      cb:	83 c4 10             	add    $0x10,%esp
      exit();
      ce:	e8 eb 11 00 00       	call   12be <exit>
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
      f0:	e8 dd 05 00 00       	call   6d2 <fork1>
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
     10b:	e8 b6 11 00 00       	call   12c6 <wait>
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
     134:	e8 95 11 00 00       	call   12ce <pipe>
     139:	83 c4 10             	add    $0x10,%esp
     13c:	85 c0                	test   %eax,%eax
     13e:	79 10                	jns    150 <runcmd+0x150>
      panic("pipe");
     140:	83 ec 0c             	sub    $0xc,%esp
     143:	68 73 18 00 00       	push   $0x1873
     148:	e8 65 05 00 00       	call   6b2 <panic>
     14d:	83 c4 10             	add    $0x10,%esp
    if(fork1() == 0){
     150:	e8 7d 05 00 00       	call   6d2 <fork1>
     155:	85 c0                	test   %eax,%eax
     157:	75 4c                	jne    1a5 <runcmd+0x1a5>
      close(1);
     159:	83 ec 0c             	sub    $0xc,%esp
     15c:	6a 01                	push   $0x1
     15e:	e8 83 11 00 00       	call   12e6 <close>
     163:	83 c4 10             	add    $0x10,%esp
      dup(p[1]);
     166:	8b 45 e0             	mov    -0x20(%ebp),%eax
     169:	83 ec 0c             	sub    $0xc,%esp
     16c:	50                   	push   %eax
     16d:	e8 c4 11 00 00       	call   1336 <dup>
     172:	83 c4 10             	add    $0x10,%esp
      close(p[0]);
     175:	8b 45 dc             	mov    -0x24(%ebp),%eax
     178:	83 ec 0c             	sub    $0xc,%esp
     17b:	50                   	push   %eax
     17c:	e8 65 11 00 00       	call   12e6 <close>
     181:	83 c4 10             	add    $0x10,%esp
      close(p[1]);
     184:	8b 45 e0             	mov    -0x20(%ebp),%eax
     187:	83 ec 0c             	sub    $0xc,%esp
     18a:	50                   	push   %eax
     18b:	e8 56 11 00 00       	call   12e6 <close>
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
     1a5:	e8 28 05 00 00       	call   6d2 <fork1>
     1aa:	85 c0                	test   %eax,%eax
     1ac:	75 4c                	jne    1fa <runcmd+0x1fa>
      close(0);
     1ae:	83 ec 0c             	sub    $0xc,%esp
     1b1:	6a 00                	push   $0x0
     1b3:	e8 2e 11 00 00       	call   12e6 <close>
     1b8:	83 c4 10             	add    $0x10,%esp
      dup(p[0]);
     1bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1be:	83 ec 0c             	sub    $0xc,%esp
     1c1:	50                   	push   %eax
     1c2:	e8 6f 11 00 00       	call   1336 <dup>
     1c7:	83 c4 10             	add    $0x10,%esp
      close(p[0]);
     1ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1cd:	83 ec 0c             	sub    $0xc,%esp
     1d0:	50                   	push   %eax
     1d1:	e8 10 11 00 00       	call   12e6 <close>
     1d6:	83 c4 10             	add    $0x10,%esp
      close(p[1]);
     1d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1dc:	83 ec 0c             	sub    $0xc,%esp
     1df:	50                   	push   %eax
     1e0:	e8 01 11 00 00       	call   12e6 <close>
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
     201:	e8 e0 10 00 00       	call   12e6 <close>
     206:	83 c4 10             	add    $0x10,%esp
    close(p[1]);
     209:	8b 45 e0             	mov    -0x20(%ebp),%eax
     20c:	83 ec 0c             	sub    $0xc,%esp
     20f:	50                   	push   %eax
     210:	e8 d1 10 00 00       	call   12e6 <close>
     215:	83 c4 10             	add    $0x10,%esp
    wait();
     218:	e8 a9 10 00 00       	call   12c6 <wait>
    wait();
     21d:	e8 a4 10 00 00       	call   12c6 <wait>
    break;
     222:	eb 22                	jmp    246 <runcmd+0x246>

  case BACK:
    bcmd = (struct backcmd*)cmd;
     224:	8b 45 08             	mov    0x8(%ebp),%eax
     227:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(fork1() == 0)
     22a:	e8 a3 04 00 00       	call   6d2 <fork1>
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
     246:	e8 73 10 00 00       	call   12be <exit>

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
     254:	68 90 18 00 00       	push   $0x1890
     259:	6a 02                	push   $0x2
     25b:	e8 35 12 00 00       	call   1495 <printf>
     260:	83 c4 10             	add    $0x10,%esp
  memset(buf, 0, nbuf);
     263:	8b 45 0c             	mov    0xc(%ebp),%eax
     266:	83 ec 04             	sub    $0x4,%esp
     269:	50                   	push   %eax
     26a:	6a 00                	push   $0x0
     26c:	ff 75 08             	pushl  0x8(%ebp)
     26f:	e8 dc 0d 00 00       	call   1050 <memset>
     274:	83 c4 10             	add    $0x10,%esp
  gets(buf, nbuf);
     277:	83 ec 08             	sub    $0x8,%esp
     27a:	ff 75 0c             	pushl  0xc(%ebp)
     27d:	ff 75 08             	pushl  0x8(%ebp)
     280:	e8 18 0e 00 00       	call   109d <gets>
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

000002a0 <strncmp>:
#ifdef USE_BUILTINS_NOT_YET
// ***** processing for shell builtins begins here *****

int
strncmp(const char *p, const char *q, uint n)
{
     2a0:	55                   	push   %ebp
     2a1:	89 e5                	mov    %esp,%ebp
    while(n > 0 && *p && *p == *q)
     2a3:	eb 0c                	jmp    2b1 <strncmp+0x11>
      n--, p++, q++;
     2a5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
     2a9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     2ad:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
// ***** processing for shell builtins begins here *****

int
strncmp(const char *p, const char *q, uint n)
{
    while(n > 0 && *p && *p == *q)
     2b1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     2b5:	74 1a                	je     2d1 <strncmp+0x31>
     2b7:	8b 45 08             	mov    0x8(%ebp),%eax
     2ba:	0f b6 00             	movzbl (%eax),%eax
     2bd:	84 c0                	test   %al,%al
     2bf:	74 10                	je     2d1 <strncmp+0x31>
     2c1:	8b 45 08             	mov    0x8(%ebp),%eax
     2c4:	0f b6 10             	movzbl (%eax),%edx
     2c7:	8b 45 0c             	mov    0xc(%ebp),%eax
     2ca:	0f b6 00             	movzbl (%eax),%eax
     2cd:	38 c2                	cmp    %al,%dl
     2cf:	74 d4                	je     2a5 <strncmp+0x5>
      n--, p++, q++;
    if(n == 0)
     2d1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     2d5:	75 07                	jne    2de <strncmp+0x3e>
      return 0;
     2d7:	b8 00 00 00 00       	mov    $0x0,%eax
     2dc:	eb 16                	jmp    2f4 <strncmp+0x54>
    return (uchar)*p - (uchar)*q;
     2de:	8b 45 08             	mov    0x8(%ebp),%eax
     2e1:	0f b6 00             	movzbl (%eax),%eax
     2e4:	0f b6 d0             	movzbl %al,%edx
     2e7:	8b 45 0c             	mov    0xc(%ebp),%eax
     2ea:	0f b6 00             	movzbl (%eax),%eax
     2ed:	0f b6 c0             	movzbl %al,%eax
     2f0:	29 c2                	sub    %eax,%edx
     2f2:	89 d0                	mov    %edx,%eax
}
     2f4:	5d                   	pop    %ebp
     2f5:	c3                   	ret    

000002f6 <makeint>:

int
makeint(char *p)
{
     2f6:	55                   	push   %ebp
     2f7:	89 e5                	mov    %esp,%ebp
     2f9:	83 ec 10             	sub    $0x10,%esp
  int val = 0;
     2fc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)

  while ((*p >= '0') && (*p <= '9')) {
     303:	eb 23                	jmp    328 <makeint+0x32>
    val = 10*val + (*p-'0');
     305:	8b 55 fc             	mov    -0x4(%ebp),%edx
     308:	89 d0                	mov    %edx,%eax
     30a:	c1 e0 02             	shl    $0x2,%eax
     30d:	01 d0                	add    %edx,%eax
     30f:	01 c0                	add    %eax,%eax
     311:	89 c2                	mov    %eax,%edx
     313:	8b 45 08             	mov    0x8(%ebp),%eax
     316:	0f b6 00             	movzbl (%eax),%eax
     319:	0f be c0             	movsbl %al,%eax
     31c:	83 e8 30             	sub    $0x30,%eax
     31f:	01 d0                	add    %edx,%eax
     321:	89 45 fc             	mov    %eax,-0x4(%ebp)
    ++p;
     324:	83 45 08 01          	addl   $0x1,0x8(%ebp)
int
makeint(char *p)
{
  int val = 0;

  while ((*p >= '0') && (*p <= '9')) {
     328:	8b 45 08             	mov    0x8(%ebp),%eax
     32b:	0f b6 00             	movzbl (%eax),%eax
     32e:	3c 2f                	cmp    $0x2f,%al
     330:	7e 0a                	jle    33c <makeint+0x46>
     332:	8b 45 08             	mov    0x8(%ebp),%eax
     335:	0f b6 00             	movzbl (%eax),%eax
     338:	3c 39                	cmp    $0x39,%al
     33a:	7e c9                	jle    305 <makeint+0xf>
    val = 10*val + (*p-'0');
    ++p;
  }
  return val;
     33c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     33f:	c9                   	leave  
     340:	c3                   	ret    

00000341 <setbuiltin>:

int
setbuiltin(char *p)
{
     341:	55                   	push   %ebp
     342:	89 e5                	mov    %esp,%ebp
     344:	83 ec 18             	sub    $0x18,%esp
  int i;

  p += strlen("_set");
     347:	83 ec 0c             	sub    $0xc,%esp
     34a:	68 93 18 00 00       	push   $0x1893
     34f:	e8 d5 0c 00 00       	call   1029 <strlen>
     354:	83 c4 10             	add    $0x10,%esp
     357:	01 45 08             	add    %eax,0x8(%ebp)
  while (strncmp(p, " ", 1) == 0) p++; // chomp spaces
     35a:	eb 04                	jmp    360 <setbuiltin+0x1f>
     35c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     360:	83 ec 04             	sub    $0x4,%esp
     363:	6a 01                	push   $0x1
     365:	68 98 18 00 00       	push   $0x1898
     36a:	ff 75 08             	pushl  0x8(%ebp)
     36d:	e8 2e ff ff ff       	call   2a0 <strncmp>
     372:	83 c4 10             	add    $0x10,%esp
     375:	85 c0                	test   %eax,%eax
     377:	74 e3                	je     35c <setbuiltin+0x1b>
  if (strncmp("uid", p, 3) == 0) {
     379:	83 ec 04             	sub    $0x4,%esp
     37c:	6a 03                	push   $0x3
     37e:	ff 75 08             	pushl  0x8(%ebp)
     381:	68 9a 18 00 00       	push   $0x189a
     386:	e8 15 ff ff ff       	call   2a0 <strncmp>
     38b:	83 c4 10             	add    $0x10,%esp
     38e:	85 c0                	test   %eax,%eax
     390:	75 56                	jne    3e8 <setbuiltin+0xa7>
    p += strlen("uid");
     392:	83 ec 0c             	sub    $0xc,%esp
     395:	68 9a 18 00 00       	push   $0x189a
     39a:	e8 8a 0c 00 00       	call   1029 <strlen>
     39f:	83 c4 10             	add    $0x10,%esp
     3a2:	01 45 08             	add    %eax,0x8(%ebp)
    while (strncmp(p, " ", 1) == 0) p++; // chomp spaces
     3a5:	eb 04                	jmp    3ab <setbuiltin+0x6a>
     3a7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     3ab:	83 ec 04             	sub    $0x4,%esp
     3ae:	6a 01                	push   $0x1
     3b0:	68 98 18 00 00       	push   $0x1898
     3b5:	ff 75 08             	pushl  0x8(%ebp)
     3b8:	e8 e3 fe ff ff       	call   2a0 <strncmp>
     3bd:	83 c4 10             	add    $0x10,%esp
     3c0:	85 c0                	test   %eax,%eax
     3c2:	74 e3                	je     3a7 <setbuiltin+0x66>
    i = makeint(p); // ugly
     3c4:	83 ec 0c             	sub    $0xc,%esp
     3c7:	ff 75 08             	pushl  0x8(%ebp)
     3ca:	e8 27 ff ff ff       	call   2f6 <makeint>
     3cf:	83 c4 10             	add    $0x10,%esp
     3d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return (setuid(i));
     3d5:	83 ec 0c             	sub    $0xc,%esp
     3d8:	ff 75 f4             	pushl  -0xc(%ebp)
     3db:	e8 a6 0f 00 00       	call   1386 <setuid>
     3e0:	83 c4 10             	add    $0x10,%esp
     3e3:	e9 83 00 00 00       	jmp    46b <setbuiltin+0x12a>
  } else
  if (strncmp("gid", p, 3) == 0) {
     3e8:	83 ec 04             	sub    $0x4,%esp
     3eb:	6a 03                	push   $0x3
     3ed:	ff 75 08             	pushl  0x8(%ebp)
     3f0:	68 9e 18 00 00       	push   $0x189e
     3f5:	e8 a6 fe ff ff       	call   2a0 <strncmp>
     3fa:	83 c4 10             	add    $0x10,%esp
     3fd:	85 c0                	test   %eax,%eax
     3ff:	75 53                	jne    454 <setbuiltin+0x113>
    p += strlen("gid");
     401:	83 ec 0c             	sub    $0xc,%esp
     404:	68 9e 18 00 00       	push   $0x189e
     409:	e8 1b 0c 00 00       	call   1029 <strlen>
     40e:	83 c4 10             	add    $0x10,%esp
     411:	01 45 08             	add    %eax,0x8(%ebp)
    while (strncmp(p, " ", 1) == 0) p++; // chomp spaces
     414:	eb 04                	jmp    41a <setbuiltin+0xd9>
     416:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     41a:	83 ec 04             	sub    $0x4,%esp
     41d:	6a 01                	push   $0x1
     41f:	68 98 18 00 00       	push   $0x1898
     424:	ff 75 08             	pushl  0x8(%ebp)
     427:	e8 74 fe ff ff       	call   2a0 <strncmp>
     42c:	83 c4 10             	add    $0x10,%esp
     42f:	85 c0                	test   %eax,%eax
     431:	74 e3                	je     416 <setbuiltin+0xd5>
    i = makeint(p); // ugly
     433:	83 ec 0c             	sub    $0xc,%esp
     436:	ff 75 08             	pushl  0x8(%ebp)
     439:	e8 b8 fe ff ff       	call   2f6 <makeint>
     43e:	83 c4 10             	add    $0x10,%esp
     441:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return (setgid(i));
     444:	83 ec 0c             	sub    $0xc,%esp
     447:	ff 75 f4             	pushl  -0xc(%ebp)
     44a:	e8 3f 0f 00 00       	call   138e <setgid>
     44f:	83 c4 10             	add    $0x10,%esp
     452:	eb 17                	jmp    46b <setbuiltin+0x12a>
  }
  printf(2, "Invalid _set parameter\n");
     454:	83 ec 08             	sub    $0x8,%esp
     457:	68 a2 18 00 00       	push   $0x18a2
     45c:	6a 02                	push   $0x2
     45e:	e8 32 10 00 00       	call   1495 <printf>
     463:	83 c4 10             	add    $0x10,%esp
  return -1;
     466:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
     46b:	c9                   	leave  
     46c:	c3                   	ret    

0000046d <getbuiltin>:

int
getbuiltin(char *p)
{
     46d:	55                   	push   %ebp
     46e:	89 e5                	mov    %esp,%ebp
     470:	83 ec 08             	sub    $0x8,%esp
  p += strlen("_get");
     473:	83 ec 0c             	sub    $0xc,%esp
     476:	68 ba 18 00 00       	push   $0x18ba
     47b:	e8 a9 0b 00 00       	call   1029 <strlen>
     480:	83 c4 10             	add    $0x10,%esp
     483:	01 45 08             	add    %eax,0x8(%ebp)
  while (strncmp(p, " ", 1) == 0) p++; // chomp spaces
     486:	eb 04                	jmp    48c <getbuiltin+0x1f>
     488:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     48c:	83 ec 04             	sub    $0x4,%esp
     48f:	6a 01                	push   $0x1
     491:	68 98 18 00 00       	push   $0x1898
     496:	ff 75 08             	pushl  0x8(%ebp)
     499:	e8 02 fe ff ff       	call   2a0 <strncmp>
     49e:	83 c4 10             	add    $0x10,%esp
     4a1:	85 c0                	test   %eax,%eax
     4a3:	74 e3                	je     488 <getbuiltin+0x1b>
  if (strncmp("uid", p, 3) == 0) {
     4a5:	83 ec 04             	sub    $0x4,%esp
     4a8:	6a 03                	push   $0x3
     4aa:	ff 75 08             	pushl  0x8(%ebp)
     4ad:	68 9a 18 00 00       	push   $0x189a
     4b2:	e8 e9 fd ff ff       	call   2a0 <strncmp>
     4b7:	83 c4 10             	add    $0x10,%esp
     4ba:	85 c0                	test   %eax,%eax
     4bc:	75 1f                	jne    4dd <getbuiltin+0x70>
    printf(2, "%d\n", getuid());
     4be:	e8 ab 0e 00 00       	call   136e <getuid>
     4c3:	83 ec 04             	sub    $0x4,%esp
     4c6:	50                   	push   %eax
     4c7:	68 bf 18 00 00       	push   $0x18bf
     4cc:	6a 02                	push   $0x2
     4ce:	e8 c2 0f 00 00       	call   1495 <printf>
     4d3:	83 c4 10             	add    $0x10,%esp
    return 0;
     4d6:	b8 00 00 00 00       	mov    $0x0,%eax
     4db:	eb 4f                	jmp    52c <getbuiltin+0xbf>
  }
  if (strncmp("gid", p, 3) == 0) {
     4dd:	83 ec 04             	sub    $0x4,%esp
     4e0:	6a 03                	push   $0x3
     4e2:	ff 75 08             	pushl  0x8(%ebp)
     4e5:	68 9e 18 00 00       	push   $0x189e
     4ea:	e8 b1 fd ff ff       	call   2a0 <strncmp>
     4ef:	83 c4 10             	add    $0x10,%esp
     4f2:	85 c0                	test   %eax,%eax
     4f4:	75 1f                	jne    515 <getbuiltin+0xa8>
    printf(2, "%d\n", getgid());
     4f6:	e8 7b 0e 00 00       	call   1376 <getgid>
     4fb:	83 ec 04             	sub    $0x4,%esp
     4fe:	50                   	push   %eax
     4ff:	68 bf 18 00 00       	push   $0x18bf
     504:	6a 02                	push   $0x2
     506:	e8 8a 0f 00 00       	call   1495 <printf>
     50b:	83 c4 10             	add    $0x10,%esp
    return 0;
     50e:	b8 00 00 00 00       	mov    $0x0,%eax
     513:	eb 17                	jmp    52c <getbuiltin+0xbf>
  }
  printf(2, "Invalid _get parameter\n");
     515:	83 ec 08             	sub    $0x8,%esp
     518:	68 c3 18 00 00       	push   $0x18c3
     51d:	6a 02                	push   $0x2
     51f:	e8 71 0f 00 00       	call   1495 <printf>
     524:	83 c4 10             	add    $0x10,%esp
  return -1;
     527:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
     52c:	c9                   	leave  
     52d:	c3                   	ret    

0000052e <dobuiltin>:
  {"_get", getbuiltin}
};
int FDTcount = sizeof(fdt) / sizeof(fdt[0]); // # entris in FDT

void
dobuiltin(char *cmd) {
     52e:	55                   	push   %ebp
     52f:	89 e5                	mov    %esp,%ebp
     531:	83 ec 18             	sub    $0x18,%esp
  int i;

  for (i=0; i<FDTcount; i++)
     534:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     53b:	eb 4f                	jmp    58c <dobuiltin+0x5e>
    if (strncmp(cmd, fdt[i].cmd, strlen(fdt[i].cmd)) == 0)
     53d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     540:	8b 04 c5 d0 1e 00 00 	mov    0x1ed0(,%eax,8),%eax
     547:	83 ec 0c             	sub    $0xc,%esp
     54a:	50                   	push   %eax
     54b:	e8 d9 0a 00 00       	call   1029 <strlen>
     550:	83 c4 10             	add    $0x10,%esp
     553:	89 c2                	mov    %eax,%edx
     555:	8b 45 f4             	mov    -0xc(%ebp),%eax
     558:	8b 04 c5 d0 1e 00 00 	mov    0x1ed0(,%eax,8),%eax
     55f:	83 ec 04             	sub    $0x4,%esp
     562:	52                   	push   %edx
     563:	50                   	push   %eax
     564:	ff 75 08             	pushl  0x8(%ebp)
     567:	e8 34 fd ff ff       	call   2a0 <strncmp>
     56c:	83 c4 10             	add    $0x10,%esp
     56f:	85 c0                	test   %eax,%eax
     571:	75 15                	jne    588 <dobuiltin+0x5a>
     (*fdt[i].name)(cmd);
     573:	8b 45 f4             	mov    -0xc(%ebp),%eax
     576:	8b 04 c5 d4 1e 00 00 	mov    0x1ed4(,%eax,8),%eax
     57d:	83 ec 0c             	sub    $0xc,%esp
     580:	ff 75 08             	pushl  0x8(%ebp)
     583:	ff d0                	call   *%eax
     585:	83 c4 10             	add    $0x10,%esp

void
dobuiltin(char *cmd) {
  int i;

  for (i=0; i<FDTcount; i++)
     588:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     58c:	a1 e0 1e 00 00       	mov    0x1ee0,%eax
     591:	39 45 f4             	cmp    %eax,-0xc(%ebp)
     594:	7c a7                	jl     53d <dobuiltin+0xf>
    if (strncmp(cmd, fdt[i].cmd, strlen(fdt[i].cmd)) == 0)
     (*fdt[i].name)(cmd);
}
     596:	90                   	nop
     597:	c9                   	leave  
     598:	c3                   	ret    

00000599 <main>:
// ***** processing for shell builtins ends here *****
#endif

int
main(void)
{
     599:	8d 4c 24 04          	lea    0x4(%esp),%ecx
     59d:	83 e4 f0             	and    $0xfffffff0,%esp
     5a0:	ff 71 fc             	pushl  -0x4(%ecx)
     5a3:	55                   	push   %ebp
     5a4:	89 e5                	mov    %esp,%ebp
     5a6:	51                   	push   %ecx
     5a7:	83 ec 14             	sub    $0x14,%esp
  static char buf[100];
  int fd;

  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     5aa:	eb 16                	jmp    5c2 <main+0x29>
    if(fd >= 3){
     5ac:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
     5b0:	7e 10                	jle    5c2 <main+0x29>
      close(fd);
     5b2:	83 ec 0c             	sub    $0xc,%esp
     5b5:	ff 75 f4             	pushl  -0xc(%ebp)
     5b8:	e8 29 0d 00 00       	call   12e6 <close>
     5bd:	83 c4 10             	add    $0x10,%esp
      break;
     5c0:	eb 1b                	jmp    5dd <main+0x44>
{
  static char buf[100];
  int fd;

  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     5c2:	83 ec 08             	sub    $0x8,%esp
     5c5:	6a 02                	push   $0x2
     5c7:	68 db 18 00 00       	push   $0x18db
     5cc:	e8 2d 0d 00 00       	call   12fe <open>
     5d1:	83 c4 10             	add    $0x10,%esp
     5d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
     5d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     5db:	79 cf                	jns    5ac <main+0x13>
      break;
    }
  }

  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     5dd:	e9 b1 00 00 00       	jmp    693 <main+0xfa>
// add support for built-ins here. cd is a built-in
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     5e2:	0f b6 05 20 1f 00 00 	movzbl 0x1f20,%eax
     5e9:	3c 63                	cmp    $0x63,%al
     5eb:	75 5f                	jne    64c <main+0xb3>
     5ed:	0f b6 05 21 1f 00 00 	movzbl 0x1f21,%eax
     5f4:	3c 64                	cmp    $0x64,%al
     5f6:	75 54                	jne    64c <main+0xb3>
     5f8:	0f b6 05 22 1f 00 00 	movzbl 0x1f22,%eax
     5ff:	3c 20                	cmp    $0x20,%al
     601:	75 49                	jne    64c <main+0xb3>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
     603:	83 ec 0c             	sub    $0xc,%esp
     606:	68 20 1f 00 00       	push   $0x1f20
     60b:	e8 19 0a 00 00       	call   1029 <strlen>
     610:	83 c4 10             	add    $0x10,%esp
     613:	83 e8 01             	sub    $0x1,%eax
     616:	c6 80 20 1f 00 00 00 	movb   $0x0,0x1f20(%eax)
      if(chdir(buf+3) < 0)
     61d:	b8 23 1f 00 00       	mov    $0x1f23,%eax
     622:	83 ec 0c             	sub    $0xc,%esp
     625:	50                   	push   %eax
     626:	e8 03 0d 00 00       	call   132e <chdir>
     62b:	83 c4 10             	add    $0x10,%esp
     62e:	85 c0                	test   %eax,%eax
     630:	79 61                	jns    693 <main+0xfa>
        printf(2, "cannot cd %s\n", buf+3);
     632:	b8 23 1f 00 00       	mov    $0x1f23,%eax
     637:	83 ec 04             	sub    $0x4,%esp
     63a:	50                   	push   %eax
     63b:	68 e3 18 00 00       	push   $0x18e3
     640:	6a 02                	push   $0x2
     642:	e8 4e 0e 00 00       	call   1495 <printf>
     647:	83 c4 10             	add    $0x10,%esp
      continue;
     64a:	eb 47                	jmp    693 <main+0xfa>
    }
#ifdef USE_BUILTINS_NOT_YET
    if (buf[0]=='_') {     // assume it is a builtin command
     64c:	0f b6 05 20 1f 00 00 	movzbl 0x1f20,%eax
     653:	3c 5f                	cmp    $0x5f,%al
     655:	75 12                	jne    669 <main+0xd0>
      dobuiltin(buf);
     657:	83 ec 0c             	sub    $0xc,%esp
     65a:	68 20 1f 00 00       	push   $0x1f20
     65f:	e8 ca fe ff ff       	call   52e <dobuiltin>
     664:	83 c4 10             	add    $0x10,%esp
      continue;
     667:	eb 2a                	jmp    693 <main+0xfa>
    }
#endif
    if(fork1() == 0)
     669:	e8 64 00 00 00       	call   6d2 <fork1>
     66e:	85 c0                	test   %eax,%eax
     670:	75 1c                	jne    68e <main+0xf5>
      runcmd(parsecmd(buf));
     672:	83 ec 0c             	sub    $0xc,%esp
     675:	68 20 1f 00 00       	push   $0x1f20
     67a:	e8 ab 03 00 00       	call   a2a <parsecmd>
     67f:	83 c4 10             	add    $0x10,%esp
     682:	83 ec 0c             	sub    $0xc,%esp
     685:	50                   	push   %eax
     686:	e8 75 f9 ff ff       	call   0 <runcmd>
     68b:	83 c4 10             	add    $0x10,%esp
    wait();
     68e:	e8 33 0c 00 00       	call   12c6 <wait>
      break;
    }
  }

  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     693:	83 ec 08             	sub    $0x8,%esp
     696:	6a 64                	push   $0x64
     698:	68 20 1f 00 00       	push   $0x1f20
     69d:	e8 a9 fb ff ff       	call   24b <getcmd>
     6a2:	83 c4 10             	add    $0x10,%esp
     6a5:	85 c0                	test   %eax,%eax
     6a7:	0f 89 35 ff ff ff    	jns    5e2 <main+0x49>
#endif
    if(fork1() == 0)
      runcmd(parsecmd(buf));
    wait();
  }
  exit();
     6ad:	e8 0c 0c 00 00       	call   12be <exit>

000006b2 <panic>:
}

void
panic(char *s)
{
     6b2:	55                   	push   %ebp
     6b3:	89 e5                	mov    %esp,%ebp
     6b5:	83 ec 08             	sub    $0x8,%esp
  printf(2, "%s\n", s);
     6b8:	83 ec 04             	sub    $0x4,%esp
     6bb:	ff 75 08             	pushl  0x8(%ebp)
     6be:	68 f1 18 00 00       	push   $0x18f1
     6c3:	6a 02                	push   $0x2
     6c5:	e8 cb 0d 00 00       	call   1495 <printf>
     6ca:	83 c4 10             	add    $0x10,%esp
  exit();
     6cd:	e8 ec 0b 00 00       	call   12be <exit>

000006d2 <fork1>:
}

int
fork1(void)
{
     6d2:	55                   	push   %ebp
     6d3:	89 e5                	mov    %esp,%ebp
     6d5:	83 ec 18             	sub    $0x18,%esp
  int pid;

  pid = fork();
     6d8:	e8 d9 0b 00 00       	call   12b6 <fork>
     6dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid == -1)
     6e0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
     6e4:	75 10                	jne    6f6 <fork1+0x24>
    panic("fork");
     6e6:	83 ec 0c             	sub    $0xc,%esp
     6e9:	68 f5 18 00 00       	push   $0x18f5
     6ee:	e8 bf ff ff ff       	call   6b2 <panic>
     6f3:	83 c4 10             	add    $0x10,%esp
  return pid;
     6f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     6f9:	c9                   	leave  
     6fa:	c3                   	ret    

000006fb <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     6fb:	55                   	push   %ebp
     6fc:	89 e5                	mov    %esp,%ebp
     6fe:	83 ec 18             	sub    $0x18,%esp
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     701:	83 ec 0c             	sub    $0xc,%esp
     704:	6a 54                	push   $0x54
     706:	e8 5d 10 00 00       	call   1768 <malloc>
     70b:	83 c4 10             	add    $0x10,%esp
     70e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     711:	83 ec 04             	sub    $0x4,%esp
     714:	6a 54                	push   $0x54
     716:	6a 00                	push   $0x0
     718:	ff 75 f4             	pushl  -0xc(%ebp)
     71b:	e8 30 09 00 00       	call   1050 <memset>
     720:	83 c4 10             	add    $0x10,%esp
  cmd->type = EXEC;
     723:	8b 45 f4             	mov    -0xc(%ebp),%eax
     726:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  return (struct cmd*)cmd;
     72c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     72f:	c9                   	leave  
     730:	c3                   	ret    

00000731 <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     731:	55                   	push   %ebp
     732:	89 e5                	mov    %esp,%ebp
     734:	83 ec 18             	sub    $0x18,%esp
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     737:	83 ec 0c             	sub    $0xc,%esp
     73a:	6a 18                	push   $0x18
     73c:	e8 27 10 00 00       	call   1768 <malloc>
     741:	83 c4 10             	add    $0x10,%esp
     744:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     747:	83 ec 04             	sub    $0x4,%esp
     74a:	6a 18                	push   $0x18
     74c:	6a 00                	push   $0x0
     74e:	ff 75 f4             	pushl  -0xc(%ebp)
     751:	e8 fa 08 00 00       	call   1050 <memset>
     756:	83 c4 10             	add    $0x10,%esp
  cmd->type = REDIR;
     759:	8b 45 f4             	mov    -0xc(%ebp),%eax
     75c:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  cmd->cmd = subcmd;
     762:	8b 45 f4             	mov    -0xc(%ebp),%eax
     765:	8b 55 08             	mov    0x8(%ebp),%edx
     768:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->file = file;
     76b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     76e:	8b 55 0c             	mov    0xc(%ebp),%edx
     771:	89 50 08             	mov    %edx,0x8(%eax)
  cmd->efile = efile;
     774:	8b 45 f4             	mov    -0xc(%ebp),%eax
     777:	8b 55 10             	mov    0x10(%ebp),%edx
     77a:	89 50 0c             	mov    %edx,0xc(%eax)
  cmd->mode = mode;
     77d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     780:	8b 55 14             	mov    0x14(%ebp),%edx
     783:	89 50 10             	mov    %edx,0x10(%eax)
  cmd->fd = fd;
     786:	8b 45 f4             	mov    -0xc(%ebp),%eax
     789:	8b 55 18             	mov    0x18(%ebp),%edx
     78c:	89 50 14             	mov    %edx,0x14(%eax)
  return (struct cmd*)cmd;
     78f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     792:	c9                   	leave  
     793:	c3                   	ret    

00000794 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     794:	55                   	push   %ebp
     795:	89 e5                	mov    %esp,%ebp
     797:	83 ec 18             	sub    $0x18,%esp
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     79a:	83 ec 0c             	sub    $0xc,%esp
     79d:	6a 0c                	push   $0xc
     79f:	e8 c4 0f 00 00       	call   1768 <malloc>
     7a4:	83 c4 10             	add    $0x10,%esp
     7a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     7aa:	83 ec 04             	sub    $0x4,%esp
     7ad:	6a 0c                	push   $0xc
     7af:	6a 00                	push   $0x0
     7b1:	ff 75 f4             	pushl  -0xc(%ebp)
     7b4:	e8 97 08 00 00       	call   1050 <memset>
     7b9:	83 c4 10             	add    $0x10,%esp
  cmd->type = PIPE;
     7bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7bf:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
  cmd->left = left;
     7c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7c8:	8b 55 08             	mov    0x8(%ebp),%edx
     7cb:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     7ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7d1:	8b 55 0c             	mov    0xc(%ebp),%edx
     7d4:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     7d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     7da:	c9                   	leave  
     7db:	c3                   	ret    

000007dc <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     7dc:	55                   	push   %ebp
     7dd:	89 e5                	mov    %esp,%ebp
     7df:	83 ec 18             	sub    $0x18,%esp
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     7e2:	83 ec 0c             	sub    $0xc,%esp
     7e5:	6a 0c                	push   $0xc
     7e7:	e8 7c 0f 00 00       	call   1768 <malloc>
     7ec:	83 c4 10             	add    $0x10,%esp
     7ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     7f2:	83 ec 04             	sub    $0x4,%esp
     7f5:	6a 0c                	push   $0xc
     7f7:	6a 00                	push   $0x0
     7f9:	ff 75 f4             	pushl  -0xc(%ebp)
     7fc:	e8 4f 08 00 00       	call   1050 <memset>
     801:	83 c4 10             	add    $0x10,%esp
  cmd->type = LIST;
     804:	8b 45 f4             	mov    -0xc(%ebp),%eax
     807:	c7 00 04 00 00 00    	movl   $0x4,(%eax)
  cmd->left = left;
     80d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     810:	8b 55 08             	mov    0x8(%ebp),%edx
     813:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     816:	8b 45 f4             	mov    -0xc(%ebp),%eax
     819:	8b 55 0c             	mov    0xc(%ebp),%edx
     81c:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     81f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     822:	c9                   	leave  
     823:	c3                   	ret    

00000824 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     824:	55                   	push   %ebp
     825:	89 e5                	mov    %esp,%ebp
     827:	83 ec 18             	sub    $0x18,%esp
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     82a:	83 ec 0c             	sub    $0xc,%esp
     82d:	6a 08                	push   $0x8
     82f:	e8 34 0f 00 00       	call   1768 <malloc>
     834:	83 c4 10             	add    $0x10,%esp
     837:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     83a:	83 ec 04             	sub    $0x4,%esp
     83d:	6a 08                	push   $0x8
     83f:	6a 00                	push   $0x0
     841:	ff 75 f4             	pushl  -0xc(%ebp)
     844:	e8 07 08 00 00       	call   1050 <memset>
     849:	83 c4 10             	add    $0x10,%esp
  cmd->type = BACK;
     84c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     84f:	c7 00 05 00 00 00    	movl   $0x5,(%eax)
  cmd->cmd = subcmd;
     855:	8b 45 f4             	mov    -0xc(%ebp),%eax
     858:	8b 55 08             	mov    0x8(%ebp),%edx
     85b:	89 50 04             	mov    %edx,0x4(%eax)
  return (struct cmd*)cmd;
     85e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     861:	c9                   	leave  
     862:	c3                   	ret    

00000863 <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     863:	55                   	push   %ebp
     864:	89 e5                	mov    %esp,%ebp
     866:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int ret;

  s = *ps;
     869:	8b 45 08             	mov    0x8(%ebp),%eax
     86c:	8b 00                	mov    (%eax),%eax
     86e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     871:	eb 04                	jmp    877 <gettoken+0x14>
    s++;
     873:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
{
  char *s;
  int ret;

  s = *ps;
  while(s < es && strchr(whitespace, *s))
     877:	8b 45 f4             	mov    -0xc(%ebp),%eax
     87a:	3b 45 0c             	cmp    0xc(%ebp),%eax
     87d:	73 1e                	jae    89d <gettoken+0x3a>
     87f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     882:	0f b6 00             	movzbl (%eax),%eax
     885:	0f be c0             	movsbl %al,%eax
     888:	83 ec 08             	sub    $0x8,%esp
     88b:	50                   	push   %eax
     88c:	68 e4 1e 00 00       	push   $0x1ee4
     891:	e8 d4 07 00 00       	call   106a <strchr>
     896:	83 c4 10             	add    $0x10,%esp
     899:	85 c0                	test   %eax,%eax
     89b:	75 d6                	jne    873 <gettoken+0x10>
    s++;
  if(q)
     89d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     8a1:	74 08                	je     8ab <gettoken+0x48>
    *q = s;
     8a3:	8b 45 10             	mov    0x10(%ebp),%eax
     8a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
     8a9:	89 10                	mov    %edx,(%eax)
  ret = *s;
     8ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8ae:	0f b6 00             	movzbl (%eax),%eax
     8b1:	0f be c0             	movsbl %al,%eax
     8b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  switch(*s){
     8b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8ba:	0f b6 00             	movzbl (%eax),%eax
     8bd:	0f be c0             	movsbl %al,%eax
     8c0:	83 f8 29             	cmp    $0x29,%eax
     8c3:	7f 14                	jg     8d9 <gettoken+0x76>
     8c5:	83 f8 28             	cmp    $0x28,%eax
     8c8:	7d 28                	jge    8f2 <gettoken+0x8f>
     8ca:	85 c0                	test   %eax,%eax
     8cc:	0f 84 94 00 00 00    	je     966 <gettoken+0x103>
     8d2:	83 f8 26             	cmp    $0x26,%eax
     8d5:	74 1b                	je     8f2 <gettoken+0x8f>
     8d7:	eb 3a                	jmp    913 <gettoken+0xb0>
     8d9:	83 f8 3e             	cmp    $0x3e,%eax
     8dc:	74 1a                	je     8f8 <gettoken+0x95>
     8de:	83 f8 3e             	cmp    $0x3e,%eax
     8e1:	7f 0a                	jg     8ed <gettoken+0x8a>
     8e3:	83 e8 3b             	sub    $0x3b,%eax
     8e6:	83 f8 01             	cmp    $0x1,%eax
     8e9:	77 28                	ja     913 <gettoken+0xb0>
     8eb:	eb 05                	jmp    8f2 <gettoken+0x8f>
     8ed:	83 f8 7c             	cmp    $0x7c,%eax
     8f0:	75 21                	jne    913 <gettoken+0xb0>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     8f2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
     8f6:	eb 75                	jmp    96d <gettoken+0x10a>
  case '>':
    s++;
     8f8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(*s == '>'){
     8fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8ff:	0f b6 00             	movzbl (%eax),%eax
     902:	3c 3e                	cmp    $0x3e,%al
     904:	75 63                	jne    969 <gettoken+0x106>
      ret = '+';
     906:	c7 45 f0 2b 00 00 00 	movl   $0x2b,-0x10(%ebp)
      s++;
     90d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    break;
     911:	eb 56                	jmp    969 <gettoken+0x106>
  default:
    ret = 'a';
     913:	c7 45 f0 61 00 00 00 	movl   $0x61,-0x10(%ebp)
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     91a:	eb 04                	jmp    920 <gettoken+0xbd>
      s++;
     91c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      s++;
    }
    break;
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     920:	8b 45 f4             	mov    -0xc(%ebp),%eax
     923:	3b 45 0c             	cmp    0xc(%ebp),%eax
     926:	73 44                	jae    96c <gettoken+0x109>
     928:	8b 45 f4             	mov    -0xc(%ebp),%eax
     92b:	0f b6 00             	movzbl (%eax),%eax
     92e:	0f be c0             	movsbl %al,%eax
     931:	83 ec 08             	sub    $0x8,%esp
     934:	50                   	push   %eax
     935:	68 e4 1e 00 00       	push   $0x1ee4
     93a:	e8 2b 07 00 00       	call   106a <strchr>
     93f:	83 c4 10             	add    $0x10,%esp
     942:	85 c0                	test   %eax,%eax
     944:	75 26                	jne    96c <gettoken+0x109>
     946:	8b 45 f4             	mov    -0xc(%ebp),%eax
     949:	0f b6 00             	movzbl (%eax),%eax
     94c:	0f be c0             	movsbl %al,%eax
     94f:	83 ec 08             	sub    $0x8,%esp
     952:	50                   	push   %eax
     953:	68 ec 1e 00 00       	push   $0x1eec
     958:	e8 0d 07 00 00       	call   106a <strchr>
     95d:	83 c4 10             	add    $0x10,%esp
     960:	85 c0                	test   %eax,%eax
     962:	74 b8                	je     91c <gettoken+0xb9>
      s++;
    break;
     964:	eb 06                	jmp    96c <gettoken+0x109>
  if(q)
    *q = s;
  ret = *s;
  switch(*s){
  case 0:
    break;
     966:	90                   	nop
     967:	eb 04                	jmp    96d <gettoken+0x10a>
    s++;
    if(*s == '>'){
      ret = '+';
      s++;
    }
    break;
     969:	90                   	nop
     96a:	eb 01                	jmp    96d <gettoken+0x10a>
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
     96c:	90                   	nop
  }
  if(eq)
     96d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     971:	74 0e                	je     981 <gettoken+0x11e>
    *eq = s;
     973:	8b 45 14             	mov    0x14(%ebp),%eax
     976:	8b 55 f4             	mov    -0xc(%ebp),%edx
     979:	89 10                	mov    %edx,(%eax)

  while(s < es && strchr(whitespace, *s))
     97b:	eb 04                	jmp    981 <gettoken+0x11e>
    s++;
     97d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
  }
  if(eq)
    *eq = s;

  while(s < es && strchr(whitespace, *s))
     981:	8b 45 f4             	mov    -0xc(%ebp),%eax
     984:	3b 45 0c             	cmp    0xc(%ebp),%eax
     987:	73 1e                	jae    9a7 <gettoken+0x144>
     989:	8b 45 f4             	mov    -0xc(%ebp),%eax
     98c:	0f b6 00             	movzbl (%eax),%eax
     98f:	0f be c0             	movsbl %al,%eax
     992:	83 ec 08             	sub    $0x8,%esp
     995:	50                   	push   %eax
     996:	68 e4 1e 00 00       	push   $0x1ee4
     99b:	e8 ca 06 00 00       	call   106a <strchr>
     9a0:	83 c4 10             	add    $0x10,%esp
     9a3:	85 c0                	test   %eax,%eax
     9a5:	75 d6                	jne    97d <gettoken+0x11a>
    s++;
  *ps = s;
     9a7:	8b 45 08             	mov    0x8(%ebp),%eax
     9aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
     9ad:	89 10                	mov    %edx,(%eax)
  return ret;
     9af:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     9b2:	c9                   	leave  
     9b3:	c3                   	ret    

000009b4 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     9b4:	55                   	push   %ebp
     9b5:	89 e5                	mov    %esp,%ebp
     9b7:	83 ec 18             	sub    $0x18,%esp
  char *s;

  s = *ps;
     9ba:	8b 45 08             	mov    0x8(%ebp),%eax
     9bd:	8b 00                	mov    (%eax),%eax
     9bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     9c2:	eb 04                	jmp    9c8 <peek+0x14>
    s++;
     9c4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
peek(char **ps, char *es, char *toks)
{
  char *s;

  s = *ps;
  while(s < es && strchr(whitespace, *s))
     9c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9cb:	3b 45 0c             	cmp    0xc(%ebp),%eax
     9ce:	73 1e                	jae    9ee <peek+0x3a>
     9d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9d3:	0f b6 00             	movzbl (%eax),%eax
     9d6:	0f be c0             	movsbl %al,%eax
     9d9:	83 ec 08             	sub    $0x8,%esp
     9dc:	50                   	push   %eax
     9dd:	68 e4 1e 00 00       	push   $0x1ee4
     9e2:	e8 83 06 00 00       	call   106a <strchr>
     9e7:	83 c4 10             	add    $0x10,%esp
     9ea:	85 c0                	test   %eax,%eax
     9ec:	75 d6                	jne    9c4 <peek+0x10>
    s++;
  *ps = s;
     9ee:	8b 45 08             	mov    0x8(%ebp),%eax
     9f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
     9f4:	89 10                	mov    %edx,(%eax)
  return *s && strchr(toks, *s);
     9f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9f9:	0f b6 00             	movzbl (%eax),%eax
     9fc:	84 c0                	test   %al,%al
     9fe:	74 23                	je     a23 <peek+0x6f>
     a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
     a03:	0f b6 00             	movzbl (%eax),%eax
     a06:	0f be c0             	movsbl %al,%eax
     a09:	83 ec 08             	sub    $0x8,%esp
     a0c:	50                   	push   %eax
     a0d:	ff 75 10             	pushl  0x10(%ebp)
     a10:	e8 55 06 00 00       	call   106a <strchr>
     a15:	83 c4 10             	add    $0x10,%esp
     a18:	85 c0                	test   %eax,%eax
     a1a:	74 07                	je     a23 <peek+0x6f>
     a1c:	b8 01 00 00 00       	mov    $0x1,%eax
     a21:	eb 05                	jmp    a28 <peek+0x74>
     a23:	b8 00 00 00 00       	mov    $0x0,%eax
}
     a28:	c9                   	leave  
     a29:	c3                   	ret    

00000a2a <parsecmd>:
struct cmd *parseexec(char**, char*);
struct cmd *nulterminate(struct cmd*);

struct cmd*
parsecmd(char *s)
{
     a2a:	55                   	push   %ebp
     a2b:	89 e5                	mov    %esp,%ebp
     a2d:	53                   	push   %ebx
     a2e:	83 ec 14             	sub    $0x14,%esp
  char *es;
  struct cmd *cmd;

  es = s + strlen(s);
     a31:	8b 5d 08             	mov    0x8(%ebp),%ebx
     a34:	8b 45 08             	mov    0x8(%ebp),%eax
     a37:	83 ec 0c             	sub    $0xc,%esp
     a3a:	50                   	push   %eax
     a3b:	e8 e9 05 00 00       	call   1029 <strlen>
     a40:	83 c4 10             	add    $0x10,%esp
     a43:	01 d8                	add    %ebx,%eax
     a45:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cmd = parseline(&s, es);
     a48:	83 ec 08             	sub    $0x8,%esp
     a4b:	ff 75 f4             	pushl  -0xc(%ebp)
     a4e:	8d 45 08             	lea    0x8(%ebp),%eax
     a51:	50                   	push   %eax
     a52:	e8 61 00 00 00       	call   ab8 <parseline>
     a57:	83 c4 10             	add    $0x10,%esp
     a5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  peek(&s, es, "");
     a5d:	83 ec 04             	sub    $0x4,%esp
     a60:	68 fa 18 00 00       	push   $0x18fa
     a65:	ff 75 f4             	pushl  -0xc(%ebp)
     a68:	8d 45 08             	lea    0x8(%ebp),%eax
     a6b:	50                   	push   %eax
     a6c:	e8 43 ff ff ff       	call   9b4 <peek>
     a71:	83 c4 10             	add    $0x10,%esp
  if(s != es){
     a74:	8b 45 08             	mov    0x8(%ebp),%eax
     a77:	3b 45 f4             	cmp    -0xc(%ebp),%eax
     a7a:	74 26                	je     aa2 <parsecmd+0x78>
    printf(2, "leftovers: %s\n", s);
     a7c:	8b 45 08             	mov    0x8(%ebp),%eax
     a7f:	83 ec 04             	sub    $0x4,%esp
     a82:	50                   	push   %eax
     a83:	68 fb 18 00 00       	push   $0x18fb
     a88:	6a 02                	push   $0x2
     a8a:	e8 06 0a 00 00       	call   1495 <printf>
     a8f:	83 c4 10             	add    $0x10,%esp
    panic("syntax");
     a92:	83 ec 0c             	sub    $0xc,%esp
     a95:	68 0a 19 00 00       	push   $0x190a
     a9a:	e8 13 fc ff ff       	call   6b2 <panic>
     a9f:	83 c4 10             	add    $0x10,%esp
  }
  nulterminate(cmd);
     aa2:	83 ec 0c             	sub    $0xc,%esp
     aa5:	ff 75 f0             	pushl  -0x10(%ebp)
     aa8:	e8 eb 03 00 00       	call   e98 <nulterminate>
     aad:	83 c4 10             	add    $0x10,%esp
  return cmd;
     ab0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     ab3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
     ab6:	c9                   	leave  
     ab7:	c3                   	ret    

00000ab8 <parseline>:

struct cmd*
parseline(char **ps, char *es)
{
     ab8:	55                   	push   %ebp
     ab9:	89 e5                	mov    %esp,%ebp
     abb:	83 ec 18             	sub    $0x18,%esp
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
     abe:	83 ec 08             	sub    $0x8,%esp
     ac1:	ff 75 0c             	pushl  0xc(%ebp)
     ac4:	ff 75 08             	pushl  0x8(%ebp)
     ac7:	e8 99 00 00 00       	call   b65 <parsepipe>
     acc:	83 c4 10             	add    $0x10,%esp
     acf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(peek(ps, es, "&")){
     ad2:	eb 23                	jmp    af7 <parseline+0x3f>
    gettoken(ps, es, 0, 0);
     ad4:	6a 00                	push   $0x0
     ad6:	6a 00                	push   $0x0
     ad8:	ff 75 0c             	pushl  0xc(%ebp)
     adb:	ff 75 08             	pushl  0x8(%ebp)
     ade:	e8 80 fd ff ff       	call   863 <gettoken>
     ae3:	83 c4 10             	add    $0x10,%esp
    cmd = backcmd(cmd);
     ae6:	83 ec 0c             	sub    $0xc,%esp
     ae9:	ff 75 f4             	pushl  -0xc(%ebp)
     aec:	e8 33 fd ff ff       	call   824 <backcmd>
     af1:	83 c4 10             	add    $0x10,%esp
     af4:	89 45 f4             	mov    %eax,-0xc(%ebp)
parseline(char **ps, char *es)
{
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
  while(peek(ps, es, "&")){
     af7:	83 ec 04             	sub    $0x4,%esp
     afa:	68 11 19 00 00       	push   $0x1911
     aff:	ff 75 0c             	pushl  0xc(%ebp)
     b02:	ff 75 08             	pushl  0x8(%ebp)
     b05:	e8 aa fe ff ff       	call   9b4 <peek>
     b0a:	83 c4 10             	add    $0x10,%esp
     b0d:	85 c0                	test   %eax,%eax
     b0f:	75 c3                	jne    ad4 <parseline+0x1c>
    gettoken(ps, es, 0, 0);
    cmd = backcmd(cmd);
  }
  if(peek(ps, es, ";")){
     b11:	83 ec 04             	sub    $0x4,%esp
     b14:	68 13 19 00 00       	push   $0x1913
     b19:	ff 75 0c             	pushl  0xc(%ebp)
     b1c:	ff 75 08             	pushl  0x8(%ebp)
     b1f:	e8 90 fe ff ff       	call   9b4 <peek>
     b24:	83 c4 10             	add    $0x10,%esp
     b27:	85 c0                	test   %eax,%eax
     b29:	74 35                	je     b60 <parseline+0xa8>
    gettoken(ps, es, 0, 0);
     b2b:	6a 00                	push   $0x0
     b2d:	6a 00                	push   $0x0
     b2f:	ff 75 0c             	pushl  0xc(%ebp)
     b32:	ff 75 08             	pushl  0x8(%ebp)
     b35:	e8 29 fd ff ff       	call   863 <gettoken>
     b3a:	83 c4 10             	add    $0x10,%esp
    cmd = listcmd(cmd, parseline(ps, es));
     b3d:	83 ec 08             	sub    $0x8,%esp
     b40:	ff 75 0c             	pushl  0xc(%ebp)
     b43:	ff 75 08             	pushl  0x8(%ebp)
     b46:	e8 6d ff ff ff       	call   ab8 <parseline>
     b4b:	83 c4 10             	add    $0x10,%esp
     b4e:	83 ec 08             	sub    $0x8,%esp
     b51:	50                   	push   %eax
     b52:	ff 75 f4             	pushl  -0xc(%ebp)
     b55:	e8 82 fc ff ff       	call   7dc <listcmd>
     b5a:	83 c4 10             	add    $0x10,%esp
     b5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     b63:	c9                   	leave  
     b64:	c3                   	ret    

00000b65 <parsepipe>:

struct cmd*
parsepipe(char **ps, char *es)
{
     b65:	55                   	push   %ebp
     b66:	89 e5                	mov    %esp,%ebp
     b68:	83 ec 18             	sub    $0x18,%esp
  struct cmd *cmd;

  cmd = parseexec(ps, es);
     b6b:	83 ec 08             	sub    $0x8,%esp
     b6e:	ff 75 0c             	pushl  0xc(%ebp)
     b71:	ff 75 08             	pushl  0x8(%ebp)
     b74:	e8 ec 01 00 00       	call   d65 <parseexec>
     b79:	83 c4 10             	add    $0x10,%esp
     b7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(peek(ps, es, "|")){
     b7f:	83 ec 04             	sub    $0x4,%esp
     b82:	68 15 19 00 00       	push   $0x1915
     b87:	ff 75 0c             	pushl  0xc(%ebp)
     b8a:	ff 75 08             	pushl  0x8(%ebp)
     b8d:	e8 22 fe ff ff       	call   9b4 <peek>
     b92:	83 c4 10             	add    $0x10,%esp
     b95:	85 c0                	test   %eax,%eax
     b97:	74 35                	je     bce <parsepipe+0x69>
    gettoken(ps, es, 0, 0);
     b99:	6a 00                	push   $0x0
     b9b:	6a 00                	push   $0x0
     b9d:	ff 75 0c             	pushl  0xc(%ebp)
     ba0:	ff 75 08             	pushl  0x8(%ebp)
     ba3:	e8 bb fc ff ff       	call   863 <gettoken>
     ba8:	83 c4 10             	add    $0x10,%esp
    cmd = pipecmd(cmd, parsepipe(ps, es));
     bab:	83 ec 08             	sub    $0x8,%esp
     bae:	ff 75 0c             	pushl  0xc(%ebp)
     bb1:	ff 75 08             	pushl  0x8(%ebp)
     bb4:	e8 ac ff ff ff       	call   b65 <parsepipe>
     bb9:	83 c4 10             	add    $0x10,%esp
     bbc:	83 ec 08             	sub    $0x8,%esp
     bbf:	50                   	push   %eax
     bc0:	ff 75 f4             	pushl  -0xc(%ebp)
     bc3:	e8 cc fb ff ff       	call   794 <pipecmd>
     bc8:	83 c4 10             	add    $0x10,%esp
     bcb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     bd1:	c9                   	leave  
     bd2:	c3                   	ret    

00000bd3 <parseredirs>:

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     bd3:	55                   	push   %ebp
     bd4:	89 e5                	mov    %esp,%ebp
     bd6:	83 ec 18             	sub    $0x18,%esp
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     bd9:	e9 b6 00 00 00       	jmp    c94 <parseredirs+0xc1>
    tok = gettoken(ps, es, 0, 0);
     bde:	6a 00                	push   $0x0
     be0:	6a 00                	push   $0x0
     be2:	ff 75 10             	pushl  0x10(%ebp)
     be5:	ff 75 0c             	pushl  0xc(%ebp)
     be8:	e8 76 fc ff ff       	call   863 <gettoken>
     bed:	83 c4 10             	add    $0x10,%esp
     bf0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(gettoken(ps, es, &q, &eq) != 'a')
     bf3:	8d 45 ec             	lea    -0x14(%ebp),%eax
     bf6:	50                   	push   %eax
     bf7:	8d 45 f0             	lea    -0x10(%ebp),%eax
     bfa:	50                   	push   %eax
     bfb:	ff 75 10             	pushl  0x10(%ebp)
     bfe:	ff 75 0c             	pushl  0xc(%ebp)
     c01:	e8 5d fc ff ff       	call   863 <gettoken>
     c06:	83 c4 10             	add    $0x10,%esp
     c09:	83 f8 61             	cmp    $0x61,%eax
     c0c:	74 10                	je     c1e <parseredirs+0x4b>
      panic("missing file for redirection");
     c0e:	83 ec 0c             	sub    $0xc,%esp
     c11:	68 17 19 00 00       	push   $0x1917
     c16:	e8 97 fa ff ff       	call   6b2 <panic>
     c1b:	83 c4 10             	add    $0x10,%esp
    switch(tok){
     c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     c21:	83 f8 3c             	cmp    $0x3c,%eax
     c24:	74 0c                	je     c32 <parseredirs+0x5f>
     c26:	83 f8 3e             	cmp    $0x3e,%eax
     c29:	74 26                	je     c51 <parseredirs+0x7e>
     c2b:	83 f8 2b             	cmp    $0x2b,%eax
     c2e:	74 43                	je     c73 <parseredirs+0xa0>
     c30:	eb 62                	jmp    c94 <parseredirs+0xc1>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     c32:	8b 55 ec             	mov    -0x14(%ebp),%edx
     c35:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c38:	83 ec 0c             	sub    $0xc,%esp
     c3b:	6a 00                	push   $0x0
     c3d:	6a 00                	push   $0x0
     c3f:	52                   	push   %edx
     c40:	50                   	push   %eax
     c41:	ff 75 08             	pushl  0x8(%ebp)
     c44:	e8 e8 fa ff ff       	call   731 <redircmd>
     c49:	83 c4 20             	add    $0x20,%esp
     c4c:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     c4f:	eb 43                	jmp    c94 <parseredirs+0xc1>
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     c51:	8b 55 ec             	mov    -0x14(%ebp),%edx
     c54:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c57:	83 ec 0c             	sub    $0xc,%esp
     c5a:	6a 01                	push   $0x1
     c5c:	68 01 02 00 00       	push   $0x201
     c61:	52                   	push   %edx
     c62:	50                   	push   %eax
     c63:	ff 75 08             	pushl  0x8(%ebp)
     c66:	e8 c6 fa ff ff       	call   731 <redircmd>
     c6b:	83 c4 20             	add    $0x20,%esp
     c6e:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     c71:	eb 21                	jmp    c94 <parseredirs+0xc1>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     c73:	8b 55 ec             	mov    -0x14(%ebp),%edx
     c76:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c79:	83 ec 0c             	sub    $0xc,%esp
     c7c:	6a 01                	push   $0x1
     c7e:	68 01 02 00 00       	push   $0x201
     c83:	52                   	push   %edx
     c84:	50                   	push   %eax
     c85:	ff 75 08             	pushl  0x8(%ebp)
     c88:	e8 a4 fa ff ff       	call   731 <redircmd>
     c8d:	83 c4 20             	add    $0x20,%esp
     c90:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     c93:	90                   	nop
parseredirs(struct cmd *cmd, char **ps, char *es)
{
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     c94:	83 ec 04             	sub    $0x4,%esp
     c97:	68 34 19 00 00       	push   $0x1934
     c9c:	ff 75 10             	pushl  0x10(%ebp)
     c9f:	ff 75 0c             	pushl  0xc(%ebp)
     ca2:	e8 0d fd ff ff       	call   9b4 <peek>
     ca7:	83 c4 10             	add    $0x10,%esp
     caa:	85 c0                	test   %eax,%eax
     cac:	0f 85 2c ff ff ff    	jne    bde <parseredirs+0xb>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
      break;
    }
  }
  return cmd;
     cb2:	8b 45 08             	mov    0x8(%ebp),%eax
}
     cb5:	c9                   	leave  
     cb6:	c3                   	ret    

00000cb7 <parseblock>:

struct cmd*
parseblock(char **ps, char *es)
{
     cb7:	55                   	push   %ebp
     cb8:	89 e5                	mov    %esp,%ebp
     cba:	83 ec 18             	sub    $0x18,%esp
  struct cmd *cmd;

  if(!peek(ps, es, "("))
     cbd:	83 ec 04             	sub    $0x4,%esp
     cc0:	68 37 19 00 00       	push   $0x1937
     cc5:	ff 75 0c             	pushl  0xc(%ebp)
     cc8:	ff 75 08             	pushl  0x8(%ebp)
     ccb:	e8 e4 fc ff ff       	call   9b4 <peek>
     cd0:	83 c4 10             	add    $0x10,%esp
     cd3:	85 c0                	test   %eax,%eax
     cd5:	75 10                	jne    ce7 <parseblock+0x30>
    panic("parseblock");
     cd7:	83 ec 0c             	sub    $0xc,%esp
     cda:	68 39 19 00 00       	push   $0x1939
     cdf:	e8 ce f9 ff ff       	call   6b2 <panic>
     ce4:	83 c4 10             	add    $0x10,%esp
  gettoken(ps, es, 0, 0);
     ce7:	6a 00                	push   $0x0
     ce9:	6a 00                	push   $0x0
     ceb:	ff 75 0c             	pushl  0xc(%ebp)
     cee:	ff 75 08             	pushl  0x8(%ebp)
     cf1:	e8 6d fb ff ff       	call   863 <gettoken>
     cf6:	83 c4 10             	add    $0x10,%esp
  cmd = parseline(ps, es);
     cf9:	83 ec 08             	sub    $0x8,%esp
     cfc:	ff 75 0c             	pushl  0xc(%ebp)
     cff:	ff 75 08             	pushl  0x8(%ebp)
     d02:	e8 b1 fd ff ff       	call   ab8 <parseline>
     d07:	83 c4 10             	add    $0x10,%esp
     d0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!peek(ps, es, ")"))
     d0d:	83 ec 04             	sub    $0x4,%esp
     d10:	68 44 19 00 00       	push   $0x1944
     d15:	ff 75 0c             	pushl  0xc(%ebp)
     d18:	ff 75 08             	pushl  0x8(%ebp)
     d1b:	e8 94 fc ff ff       	call   9b4 <peek>
     d20:	83 c4 10             	add    $0x10,%esp
     d23:	85 c0                	test   %eax,%eax
     d25:	75 10                	jne    d37 <parseblock+0x80>
    panic("syntax - missing )");
     d27:	83 ec 0c             	sub    $0xc,%esp
     d2a:	68 46 19 00 00       	push   $0x1946
     d2f:	e8 7e f9 ff ff       	call   6b2 <panic>
     d34:	83 c4 10             	add    $0x10,%esp
  gettoken(ps, es, 0, 0);
     d37:	6a 00                	push   $0x0
     d39:	6a 00                	push   $0x0
     d3b:	ff 75 0c             	pushl  0xc(%ebp)
     d3e:	ff 75 08             	pushl  0x8(%ebp)
     d41:	e8 1d fb ff ff       	call   863 <gettoken>
     d46:	83 c4 10             	add    $0x10,%esp
  cmd = parseredirs(cmd, ps, es);
     d49:	83 ec 04             	sub    $0x4,%esp
     d4c:	ff 75 0c             	pushl  0xc(%ebp)
     d4f:	ff 75 08             	pushl  0x8(%ebp)
     d52:	ff 75 f4             	pushl  -0xc(%ebp)
     d55:	e8 79 fe ff ff       	call   bd3 <parseredirs>
     d5a:	83 c4 10             	add    $0x10,%esp
     d5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  return cmd;
     d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     d63:	c9                   	leave  
     d64:	c3                   	ret    

00000d65 <parseexec>:

struct cmd*
parseexec(char **ps, char *es)
{
     d65:	55                   	push   %ebp
     d66:	89 e5                	mov    %esp,%ebp
     d68:	83 ec 28             	sub    $0x28,%esp
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
     d6b:	83 ec 04             	sub    $0x4,%esp
     d6e:	68 37 19 00 00       	push   $0x1937
     d73:	ff 75 0c             	pushl  0xc(%ebp)
     d76:	ff 75 08             	pushl  0x8(%ebp)
     d79:	e8 36 fc ff ff       	call   9b4 <peek>
     d7e:	83 c4 10             	add    $0x10,%esp
     d81:	85 c0                	test   %eax,%eax
     d83:	74 16                	je     d9b <parseexec+0x36>
    return parseblock(ps, es);
     d85:	83 ec 08             	sub    $0x8,%esp
     d88:	ff 75 0c             	pushl  0xc(%ebp)
     d8b:	ff 75 08             	pushl  0x8(%ebp)
     d8e:	e8 24 ff ff ff       	call   cb7 <parseblock>
     d93:	83 c4 10             	add    $0x10,%esp
     d96:	e9 fb 00 00 00       	jmp    e96 <parseexec+0x131>

  ret = execcmd();
     d9b:	e8 5b f9 ff ff       	call   6fb <execcmd>
     da0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  cmd = (struct execcmd*)ret;
     da3:	8b 45 f0             	mov    -0x10(%ebp),%eax
     da6:	89 45 ec             	mov    %eax,-0x14(%ebp)

  argc = 0;
     da9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  ret = parseredirs(ret, ps, es);
     db0:	83 ec 04             	sub    $0x4,%esp
     db3:	ff 75 0c             	pushl  0xc(%ebp)
     db6:	ff 75 08             	pushl  0x8(%ebp)
     db9:	ff 75 f0             	pushl  -0x10(%ebp)
     dbc:	e8 12 fe ff ff       	call   bd3 <parseredirs>
     dc1:	83 c4 10             	add    $0x10,%esp
     dc4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while(!peek(ps, es, "|)&;")){
     dc7:	e9 87 00 00 00       	jmp    e53 <parseexec+0xee>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     dcc:	8d 45 e0             	lea    -0x20(%ebp),%eax
     dcf:	50                   	push   %eax
     dd0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     dd3:	50                   	push   %eax
     dd4:	ff 75 0c             	pushl  0xc(%ebp)
     dd7:	ff 75 08             	pushl  0x8(%ebp)
     dda:	e8 84 fa ff ff       	call   863 <gettoken>
     ddf:	83 c4 10             	add    $0x10,%esp
     de2:	89 45 e8             	mov    %eax,-0x18(%ebp)
     de5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     de9:	0f 84 84 00 00 00    	je     e73 <parseexec+0x10e>
      break;
    if(tok != 'a')
     def:	83 7d e8 61          	cmpl   $0x61,-0x18(%ebp)
     df3:	74 10                	je     e05 <parseexec+0xa0>
      panic("syntax");
     df5:	83 ec 0c             	sub    $0xc,%esp
     df8:	68 0a 19 00 00       	push   $0x190a
     dfd:	e8 b0 f8 ff ff       	call   6b2 <panic>
     e02:	83 c4 10             	add    $0x10,%esp
    cmd->argv[argc] = q;
     e05:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
     e08:	8b 45 ec             	mov    -0x14(%ebp),%eax
     e0b:	8b 55 f4             	mov    -0xc(%ebp),%edx
     e0e:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
    cmd->eargv[argc] = eq;
     e12:	8b 55 e0             	mov    -0x20(%ebp),%edx
     e15:	8b 45 ec             	mov    -0x14(%ebp),%eax
     e18:	8b 4d f4             	mov    -0xc(%ebp),%ecx
     e1b:	83 c1 08             	add    $0x8,%ecx
     e1e:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    argc++;
     e22:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(argc >= MAXARGS)
     e26:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     e2a:	7e 10                	jle    e3c <parseexec+0xd7>
      panic("too many args");
     e2c:	83 ec 0c             	sub    $0xc,%esp
     e2f:	68 59 19 00 00       	push   $0x1959
     e34:	e8 79 f8 ff ff       	call   6b2 <panic>
     e39:	83 c4 10             	add    $0x10,%esp
    ret = parseredirs(ret, ps, es);
     e3c:	83 ec 04             	sub    $0x4,%esp
     e3f:	ff 75 0c             	pushl  0xc(%ebp)
     e42:	ff 75 08             	pushl  0x8(%ebp)
     e45:	ff 75 f0             	pushl  -0x10(%ebp)
     e48:	e8 86 fd ff ff       	call   bd3 <parseredirs>
     e4d:	83 c4 10             	add    $0x10,%esp
     e50:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ret = execcmd();
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
  while(!peek(ps, es, "|)&;")){
     e53:	83 ec 04             	sub    $0x4,%esp
     e56:	68 67 19 00 00       	push   $0x1967
     e5b:	ff 75 0c             	pushl  0xc(%ebp)
     e5e:	ff 75 08             	pushl  0x8(%ebp)
     e61:	e8 4e fb ff ff       	call   9b4 <peek>
     e66:	83 c4 10             	add    $0x10,%esp
     e69:	85 c0                	test   %eax,%eax
     e6b:	0f 84 5b ff ff ff    	je     dcc <parseexec+0x67>
     e71:	eb 01                	jmp    e74 <parseexec+0x10f>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
     e73:	90                   	nop
    argc++;
    if(argc >= MAXARGS)
      panic("too many args");
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
     e74:	8b 45 ec             	mov    -0x14(%ebp),%eax
     e77:	8b 55 f4             	mov    -0xc(%ebp),%edx
     e7a:	c7 44 90 04 00 00 00 	movl   $0x0,0x4(%eax,%edx,4)
     e81:	00 
  cmd->eargv[argc] = 0;
     e82:	8b 45 ec             	mov    -0x14(%ebp),%eax
     e85:	8b 55 f4             	mov    -0xc(%ebp),%edx
     e88:	83 c2 08             	add    $0x8,%edx
     e8b:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
     e92:	00 
  return ret;
     e93:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     e96:	c9                   	leave  
     e97:	c3                   	ret    

00000e98 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     e98:	55                   	push   %ebp
     e99:	89 e5                	mov    %esp,%ebp
     e9b:	83 ec 28             	sub    $0x28,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     e9e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     ea2:	75 0a                	jne    eae <nulterminate+0x16>
    return 0;
     ea4:	b8 00 00 00 00       	mov    $0x0,%eax
     ea9:	e9 e4 00 00 00       	jmp    f92 <nulterminate+0xfa>

  switch(cmd->type){
     eae:	8b 45 08             	mov    0x8(%ebp),%eax
     eb1:	8b 00                	mov    (%eax),%eax
     eb3:	83 f8 05             	cmp    $0x5,%eax
     eb6:	0f 87 d3 00 00 00    	ja     f8f <nulterminate+0xf7>
     ebc:	8b 04 85 6c 19 00 00 	mov    0x196c(,%eax,4),%eax
     ec3:	ff e0                	jmp    *%eax
  case EXEC:
    ecmd = (struct execcmd*)cmd;
     ec5:	8b 45 08             	mov    0x8(%ebp),%eax
     ec8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(i=0; ecmd->argv[i]; i++)
     ecb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     ed2:	eb 14                	jmp    ee8 <nulterminate+0x50>
      *ecmd->eargv[i] = 0;
     ed4:	8b 45 f0             	mov    -0x10(%ebp),%eax
     ed7:	8b 55 f4             	mov    -0xc(%ebp),%edx
     eda:	83 c2 08             	add    $0x8,%edx
     edd:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
     ee1:	c6 00 00             	movb   $0x0,(%eax)
    return 0;

  switch(cmd->type){
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     ee4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     ee8:	8b 45 f0             	mov    -0x10(%ebp),%eax
     eeb:	8b 55 f4             	mov    -0xc(%ebp),%edx
     eee:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
     ef2:	85 c0                	test   %eax,%eax
     ef4:	75 de                	jne    ed4 <nulterminate+0x3c>
      *ecmd->eargv[i] = 0;
    break;
     ef6:	e9 94 00 00 00       	jmp    f8f <nulterminate+0xf7>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
     efb:	8b 45 08             	mov    0x8(%ebp),%eax
     efe:	89 45 ec             	mov    %eax,-0x14(%ebp)
    nulterminate(rcmd->cmd);
     f01:	8b 45 ec             	mov    -0x14(%ebp),%eax
     f04:	8b 40 04             	mov    0x4(%eax),%eax
     f07:	83 ec 0c             	sub    $0xc,%esp
     f0a:	50                   	push   %eax
     f0b:	e8 88 ff ff ff       	call   e98 <nulterminate>
     f10:	83 c4 10             	add    $0x10,%esp
    *rcmd->efile = 0;
     f13:	8b 45 ec             	mov    -0x14(%ebp),%eax
     f16:	8b 40 0c             	mov    0xc(%eax),%eax
     f19:	c6 00 00             	movb   $0x0,(%eax)
    break;
     f1c:	eb 71                	jmp    f8f <nulterminate+0xf7>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     f1e:	8b 45 08             	mov    0x8(%ebp),%eax
     f21:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nulterminate(pcmd->left);
     f24:	8b 45 e8             	mov    -0x18(%ebp),%eax
     f27:	8b 40 04             	mov    0x4(%eax),%eax
     f2a:	83 ec 0c             	sub    $0xc,%esp
     f2d:	50                   	push   %eax
     f2e:	e8 65 ff ff ff       	call   e98 <nulterminate>
     f33:	83 c4 10             	add    $0x10,%esp
    nulterminate(pcmd->right);
     f36:	8b 45 e8             	mov    -0x18(%ebp),%eax
     f39:	8b 40 08             	mov    0x8(%eax),%eax
     f3c:	83 ec 0c             	sub    $0xc,%esp
     f3f:	50                   	push   %eax
     f40:	e8 53 ff ff ff       	call   e98 <nulterminate>
     f45:	83 c4 10             	add    $0x10,%esp
    break;
     f48:	eb 45                	jmp    f8f <nulterminate+0xf7>

  case LIST:
    lcmd = (struct listcmd*)cmd;
     f4a:	8b 45 08             	mov    0x8(%ebp),%eax
     f4d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nulterminate(lcmd->left);
     f50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     f53:	8b 40 04             	mov    0x4(%eax),%eax
     f56:	83 ec 0c             	sub    $0xc,%esp
     f59:	50                   	push   %eax
     f5a:	e8 39 ff ff ff       	call   e98 <nulterminate>
     f5f:	83 c4 10             	add    $0x10,%esp
    nulterminate(lcmd->right);
     f62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     f65:	8b 40 08             	mov    0x8(%eax),%eax
     f68:	83 ec 0c             	sub    $0xc,%esp
     f6b:	50                   	push   %eax
     f6c:	e8 27 ff ff ff       	call   e98 <nulterminate>
     f71:	83 c4 10             	add    $0x10,%esp
    break;
     f74:	eb 19                	jmp    f8f <nulterminate+0xf7>

  case BACK:
    bcmd = (struct backcmd*)cmd;
     f76:	8b 45 08             	mov    0x8(%ebp),%eax
     f79:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nulterminate(bcmd->cmd);
     f7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
     f7f:	8b 40 04             	mov    0x4(%eax),%eax
     f82:	83 ec 0c             	sub    $0xc,%esp
     f85:	50                   	push   %eax
     f86:	e8 0d ff ff ff       	call   e98 <nulterminate>
     f8b:	83 c4 10             	add    $0x10,%esp
    break;
     f8e:	90                   	nop
  }
  return cmd;
     f8f:	8b 45 08             	mov    0x8(%ebp),%eax
}
     f92:	c9                   	leave  
     f93:	c3                   	ret    

00000f94 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     f94:	55                   	push   %ebp
     f95:	89 e5                	mov    %esp,%ebp
     f97:	57                   	push   %edi
     f98:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
     f99:	8b 4d 08             	mov    0x8(%ebp),%ecx
     f9c:	8b 55 10             	mov    0x10(%ebp),%edx
     f9f:	8b 45 0c             	mov    0xc(%ebp),%eax
     fa2:	89 cb                	mov    %ecx,%ebx
     fa4:	89 df                	mov    %ebx,%edi
     fa6:	89 d1                	mov    %edx,%ecx
     fa8:	fc                   	cld    
     fa9:	f3 aa                	rep stos %al,%es:(%edi)
     fab:	89 ca                	mov    %ecx,%edx
     fad:	89 fb                	mov    %edi,%ebx
     faf:	89 5d 08             	mov    %ebx,0x8(%ebp)
     fb2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     fb5:	90                   	nop
     fb6:	5b                   	pop    %ebx
     fb7:	5f                   	pop    %edi
     fb8:	5d                   	pop    %ebp
     fb9:	c3                   	ret    

00000fba <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
     fba:	55                   	push   %ebp
     fbb:	89 e5                	mov    %esp,%ebp
     fbd:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
     fc0:	8b 45 08             	mov    0x8(%ebp),%eax
     fc3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
     fc6:	90                   	nop
     fc7:	8b 45 08             	mov    0x8(%ebp),%eax
     fca:	8d 50 01             	lea    0x1(%eax),%edx
     fcd:	89 55 08             	mov    %edx,0x8(%ebp)
     fd0:	8b 55 0c             	mov    0xc(%ebp),%edx
     fd3:	8d 4a 01             	lea    0x1(%edx),%ecx
     fd6:	89 4d 0c             	mov    %ecx,0xc(%ebp)
     fd9:	0f b6 12             	movzbl (%edx),%edx
     fdc:	88 10                	mov    %dl,(%eax)
     fde:	0f b6 00             	movzbl (%eax),%eax
     fe1:	84 c0                	test   %al,%al
     fe3:	75 e2                	jne    fc7 <strcpy+0xd>
    ;
  return os;
     fe5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     fe8:	c9                   	leave  
     fe9:	c3                   	ret    

00000fea <strcmp>:

int
strcmp(const char *p, const char *q)
{
     fea:	55                   	push   %ebp
     feb:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
     fed:	eb 08                	jmp    ff7 <strcmp+0xd>
    p++, q++;
     fef:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     ff3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
     ff7:	8b 45 08             	mov    0x8(%ebp),%eax
     ffa:	0f b6 00             	movzbl (%eax),%eax
     ffd:	84 c0                	test   %al,%al
     fff:	74 10                	je     1011 <strcmp+0x27>
    1001:	8b 45 08             	mov    0x8(%ebp),%eax
    1004:	0f b6 10             	movzbl (%eax),%edx
    1007:	8b 45 0c             	mov    0xc(%ebp),%eax
    100a:	0f b6 00             	movzbl (%eax),%eax
    100d:	38 c2                	cmp    %al,%dl
    100f:	74 de                	je     fef <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    1011:	8b 45 08             	mov    0x8(%ebp),%eax
    1014:	0f b6 00             	movzbl (%eax),%eax
    1017:	0f b6 d0             	movzbl %al,%edx
    101a:	8b 45 0c             	mov    0xc(%ebp),%eax
    101d:	0f b6 00             	movzbl (%eax),%eax
    1020:	0f b6 c0             	movzbl %al,%eax
    1023:	29 c2                	sub    %eax,%edx
    1025:	89 d0                	mov    %edx,%eax
}
    1027:	5d                   	pop    %ebp
    1028:	c3                   	ret    

00001029 <strlen>:

uint
strlen(char *s)
{
    1029:	55                   	push   %ebp
    102a:	89 e5                	mov    %esp,%ebp
    102c:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    102f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    1036:	eb 04                	jmp    103c <strlen+0x13>
    1038:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    103c:	8b 55 fc             	mov    -0x4(%ebp),%edx
    103f:	8b 45 08             	mov    0x8(%ebp),%eax
    1042:	01 d0                	add    %edx,%eax
    1044:	0f b6 00             	movzbl (%eax),%eax
    1047:	84 c0                	test   %al,%al
    1049:	75 ed                	jne    1038 <strlen+0xf>
    ;
  return n;
    104b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    104e:	c9                   	leave  
    104f:	c3                   	ret    

00001050 <memset>:

void*
memset(void *dst, int c, uint n)
{
    1050:	55                   	push   %ebp
    1051:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
    1053:	8b 45 10             	mov    0x10(%ebp),%eax
    1056:	50                   	push   %eax
    1057:	ff 75 0c             	pushl  0xc(%ebp)
    105a:	ff 75 08             	pushl  0x8(%ebp)
    105d:	e8 32 ff ff ff       	call   f94 <stosb>
    1062:	83 c4 0c             	add    $0xc,%esp
  return dst;
    1065:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1068:	c9                   	leave  
    1069:	c3                   	ret    

0000106a <strchr>:

char*
strchr(const char *s, char c)
{
    106a:	55                   	push   %ebp
    106b:	89 e5                	mov    %esp,%ebp
    106d:	83 ec 04             	sub    $0x4,%esp
    1070:	8b 45 0c             	mov    0xc(%ebp),%eax
    1073:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    1076:	eb 14                	jmp    108c <strchr+0x22>
    if(*s == c)
    1078:	8b 45 08             	mov    0x8(%ebp),%eax
    107b:	0f b6 00             	movzbl (%eax),%eax
    107e:	3a 45 fc             	cmp    -0x4(%ebp),%al
    1081:	75 05                	jne    1088 <strchr+0x1e>
      return (char*)s;
    1083:	8b 45 08             	mov    0x8(%ebp),%eax
    1086:	eb 13                	jmp    109b <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    1088:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    108c:	8b 45 08             	mov    0x8(%ebp),%eax
    108f:	0f b6 00             	movzbl (%eax),%eax
    1092:	84 c0                	test   %al,%al
    1094:	75 e2                	jne    1078 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    1096:	b8 00 00 00 00       	mov    $0x0,%eax
}
    109b:	c9                   	leave  
    109c:	c3                   	ret    

0000109d <gets>:

char*
gets(char *buf, int max)
{
    109d:	55                   	push   %ebp
    109e:	89 e5                	mov    %esp,%ebp
    10a0:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    10a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    10aa:	eb 42                	jmp    10ee <gets+0x51>
    cc = read(0, &c, 1);
    10ac:	83 ec 04             	sub    $0x4,%esp
    10af:	6a 01                	push   $0x1
    10b1:	8d 45 ef             	lea    -0x11(%ebp),%eax
    10b4:	50                   	push   %eax
    10b5:	6a 00                	push   $0x0
    10b7:	e8 1a 02 00 00       	call   12d6 <read>
    10bc:	83 c4 10             	add    $0x10,%esp
    10bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    10c2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    10c6:	7e 33                	jle    10fb <gets+0x5e>
      break;
    buf[i++] = c;
    10c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    10cb:	8d 50 01             	lea    0x1(%eax),%edx
    10ce:	89 55 f4             	mov    %edx,-0xc(%ebp)
    10d1:	89 c2                	mov    %eax,%edx
    10d3:	8b 45 08             	mov    0x8(%ebp),%eax
    10d6:	01 c2                	add    %eax,%edx
    10d8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    10dc:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    10de:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    10e2:	3c 0a                	cmp    $0xa,%al
    10e4:	74 16                	je     10fc <gets+0x5f>
    10e6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    10ea:	3c 0d                	cmp    $0xd,%al
    10ec:	74 0e                	je     10fc <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    10ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
    10f1:	83 c0 01             	add    $0x1,%eax
    10f4:	3b 45 0c             	cmp    0xc(%ebp),%eax
    10f7:	7c b3                	jl     10ac <gets+0xf>
    10f9:	eb 01                	jmp    10fc <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    10fb:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    10fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
    10ff:	8b 45 08             	mov    0x8(%ebp),%eax
    1102:	01 d0                	add    %edx,%eax
    1104:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    1107:	8b 45 08             	mov    0x8(%ebp),%eax
}
    110a:	c9                   	leave  
    110b:	c3                   	ret    

0000110c <stat>:

int
stat(char *n, struct stat *st)
{
    110c:	55                   	push   %ebp
    110d:	89 e5                	mov    %esp,%ebp
    110f:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    1112:	83 ec 08             	sub    $0x8,%esp
    1115:	6a 00                	push   $0x0
    1117:	ff 75 08             	pushl  0x8(%ebp)
    111a:	e8 df 01 00 00       	call   12fe <open>
    111f:	83 c4 10             	add    $0x10,%esp
    1122:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    1125:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1129:	79 07                	jns    1132 <stat+0x26>
    return -1;
    112b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    1130:	eb 25                	jmp    1157 <stat+0x4b>
  r = fstat(fd, st);
    1132:	83 ec 08             	sub    $0x8,%esp
    1135:	ff 75 0c             	pushl  0xc(%ebp)
    1138:	ff 75 f4             	pushl  -0xc(%ebp)
    113b:	e8 d6 01 00 00       	call   1316 <fstat>
    1140:	83 c4 10             	add    $0x10,%esp
    1143:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    1146:	83 ec 0c             	sub    $0xc,%esp
    1149:	ff 75 f4             	pushl  -0xc(%ebp)
    114c:	e8 95 01 00 00       	call   12e6 <close>
    1151:	83 c4 10             	add    $0x10,%esp
  return r;
    1154:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    1157:	c9                   	leave  
    1158:	c3                   	ret    

00001159 <atoi>:

int
atoi(const char *s)
{
    1159:	55                   	push   %ebp
    115a:	89 e5                	mov    %esp,%ebp
    115c:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
    115f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
    1166:	eb 04                	jmp    116c <atoi+0x13>
    1168:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    116c:	8b 45 08             	mov    0x8(%ebp),%eax
    116f:	0f b6 00             	movzbl (%eax),%eax
    1172:	3c 20                	cmp    $0x20,%al
    1174:	74 f2                	je     1168 <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
    1176:	8b 45 08             	mov    0x8(%ebp),%eax
    1179:	0f b6 00             	movzbl (%eax),%eax
    117c:	3c 2d                	cmp    $0x2d,%al
    117e:	75 07                	jne    1187 <atoi+0x2e>
    1180:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    1185:	eb 05                	jmp    118c <atoi+0x33>
    1187:	b8 01 00 00 00       	mov    $0x1,%eax
    118c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
    118f:	8b 45 08             	mov    0x8(%ebp),%eax
    1192:	0f b6 00             	movzbl (%eax),%eax
    1195:	3c 2b                	cmp    $0x2b,%al
    1197:	74 0a                	je     11a3 <atoi+0x4a>
    1199:	8b 45 08             	mov    0x8(%ebp),%eax
    119c:	0f b6 00             	movzbl (%eax),%eax
    119f:	3c 2d                	cmp    $0x2d,%al
    11a1:	75 2b                	jne    11ce <atoi+0x75>
    s++;
    11a3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
    11a7:	eb 25                	jmp    11ce <atoi+0x75>
    n = n*10 + *s++ - '0';
    11a9:	8b 55 fc             	mov    -0x4(%ebp),%edx
    11ac:	89 d0                	mov    %edx,%eax
    11ae:	c1 e0 02             	shl    $0x2,%eax
    11b1:	01 d0                	add    %edx,%eax
    11b3:	01 c0                	add    %eax,%eax
    11b5:	89 c1                	mov    %eax,%ecx
    11b7:	8b 45 08             	mov    0x8(%ebp),%eax
    11ba:	8d 50 01             	lea    0x1(%eax),%edx
    11bd:	89 55 08             	mov    %edx,0x8(%ebp)
    11c0:	0f b6 00             	movzbl (%eax),%eax
    11c3:	0f be c0             	movsbl %al,%eax
    11c6:	01 c8                	add    %ecx,%eax
    11c8:	83 e8 30             	sub    $0x30,%eax
    11cb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
    11ce:	8b 45 08             	mov    0x8(%ebp),%eax
    11d1:	0f b6 00             	movzbl (%eax),%eax
    11d4:	3c 2f                	cmp    $0x2f,%al
    11d6:	7e 0a                	jle    11e2 <atoi+0x89>
    11d8:	8b 45 08             	mov    0x8(%ebp),%eax
    11db:	0f b6 00             	movzbl (%eax),%eax
    11de:	3c 39                	cmp    $0x39,%al
    11e0:	7e c7                	jle    11a9 <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
    11e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
    11e5:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
    11e9:	c9                   	leave  
    11ea:	c3                   	ret    

000011eb <atoo>:

int
atoo(const char *s)
{
    11eb:	55                   	push   %ebp
    11ec:	89 e5                	mov    %esp,%ebp
    11ee:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
    11f1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
    11f8:	eb 04                	jmp    11fe <atoo+0x13>
    11fa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    11fe:	8b 45 08             	mov    0x8(%ebp),%eax
    1201:	0f b6 00             	movzbl (%eax),%eax
    1204:	3c 20                	cmp    $0x20,%al
    1206:	74 f2                	je     11fa <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
    1208:	8b 45 08             	mov    0x8(%ebp),%eax
    120b:	0f b6 00             	movzbl (%eax),%eax
    120e:	3c 2d                	cmp    $0x2d,%al
    1210:	75 07                	jne    1219 <atoo+0x2e>
    1212:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    1217:	eb 05                	jmp    121e <atoo+0x33>
    1219:	b8 01 00 00 00       	mov    $0x1,%eax
    121e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
    1221:	8b 45 08             	mov    0x8(%ebp),%eax
    1224:	0f b6 00             	movzbl (%eax),%eax
    1227:	3c 2b                	cmp    $0x2b,%al
    1229:	74 0a                	je     1235 <atoo+0x4a>
    122b:	8b 45 08             	mov    0x8(%ebp),%eax
    122e:	0f b6 00             	movzbl (%eax),%eax
    1231:	3c 2d                	cmp    $0x2d,%al
    1233:	75 27                	jne    125c <atoo+0x71>
    s++;
    1235:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
    1239:	eb 21                	jmp    125c <atoo+0x71>
    n = n*8 + *s++ - '0';
    123b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    123e:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
    1245:	8b 45 08             	mov    0x8(%ebp),%eax
    1248:	8d 50 01             	lea    0x1(%eax),%edx
    124b:	89 55 08             	mov    %edx,0x8(%ebp)
    124e:	0f b6 00             	movzbl (%eax),%eax
    1251:	0f be c0             	movsbl %al,%eax
    1254:	01 c8                	add    %ecx,%eax
    1256:	83 e8 30             	sub    $0x30,%eax
    1259:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
    125c:	8b 45 08             	mov    0x8(%ebp),%eax
    125f:	0f b6 00             	movzbl (%eax),%eax
    1262:	3c 2f                	cmp    $0x2f,%al
    1264:	7e 0a                	jle    1270 <atoo+0x85>
    1266:	8b 45 08             	mov    0x8(%ebp),%eax
    1269:	0f b6 00             	movzbl (%eax),%eax
    126c:	3c 37                	cmp    $0x37,%al
    126e:	7e cb                	jle    123b <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
    1270:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1273:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
    1277:	c9                   	leave  
    1278:	c3                   	ret    

00001279 <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
    1279:	55                   	push   %ebp
    127a:	89 e5                	mov    %esp,%ebp
    127c:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
    127f:	8b 45 08             	mov    0x8(%ebp),%eax
    1282:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    1285:	8b 45 0c             	mov    0xc(%ebp),%eax
    1288:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    128b:	eb 17                	jmp    12a4 <memmove+0x2b>
    *dst++ = *src++;
    128d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1290:	8d 50 01             	lea    0x1(%eax),%edx
    1293:	89 55 fc             	mov    %edx,-0x4(%ebp)
    1296:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1299:	8d 4a 01             	lea    0x1(%edx),%ecx
    129c:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    129f:	0f b6 12             	movzbl (%edx),%edx
    12a2:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    12a4:	8b 45 10             	mov    0x10(%ebp),%eax
    12a7:	8d 50 ff             	lea    -0x1(%eax),%edx
    12aa:	89 55 10             	mov    %edx,0x10(%ebp)
    12ad:	85 c0                	test   %eax,%eax
    12af:	7f dc                	jg     128d <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    12b1:	8b 45 08             	mov    0x8(%ebp),%eax
}
    12b4:	c9                   	leave  
    12b5:	c3                   	ret    

000012b6 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    12b6:	b8 01 00 00 00       	mov    $0x1,%eax
    12bb:	cd 40                	int    $0x40
    12bd:	c3                   	ret    

000012be <exit>:
SYSCALL(exit)
    12be:	b8 02 00 00 00       	mov    $0x2,%eax
    12c3:	cd 40                	int    $0x40
    12c5:	c3                   	ret    

000012c6 <wait>:
SYSCALL(wait)
    12c6:	b8 03 00 00 00       	mov    $0x3,%eax
    12cb:	cd 40                	int    $0x40
    12cd:	c3                   	ret    

000012ce <pipe>:
SYSCALL(pipe)
    12ce:	b8 04 00 00 00       	mov    $0x4,%eax
    12d3:	cd 40                	int    $0x40
    12d5:	c3                   	ret    

000012d6 <read>:
SYSCALL(read)
    12d6:	b8 05 00 00 00       	mov    $0x5,%eax
    12db:	cd 40                	int    $0x40
    12dd:	c3                   	ret    

000012de <write>:
SYSCALL(write)
    12de:	b8 10 00 00 00       	mov    $0x10,%eax
    12e3:	cd 40                	int    $0x40
    12e5:	c3                   	ret    

000012e6 <close>:
SYSCALL(close)
    12e6:	b8 15 00 00 00       	mov    $0x15,%eax
    12eb:	cd 40                	int    $0x40
    12ed:	c3                   	ret    

000012ee <kill>:
SYSCALL(kill)
    12ee:	b8 06 00 00 00       	mov    $0x6,%eax
    12f3:	cd 40                	int    $0x40
    12f5:	c3                   	ret    

000012f6 <exec>:
SYSCALL(exec)
    12f6:	b8 07 00 00 00       	mov    $0x7,%eax
    12fb:	cd 40                	int    $0x40
    12fd:	c3                   	ret    

000012fe <open>:
SYSCALL(open)
    12fe:	b8 0f 00 00 00       	mov    $0xf,%eax
    1303:	cd 40                	int    $0x40
    1305:	c3                   	ret    

00001306 <mknod>:
SYSCALL(mknod)
    1306:	b8 11 00 00 00       	mov    $0x11,%eax
    130b:	cd 40                	int    $0x40
    130d:	c3                   	ret    

0000130e <unlink>:
SYSCALL(unlink)
    130e:	b8 12 00 00 00       	mov    $0x12,%eax
    1313:	cd 40                	int    $0x40
    1315:	c3                   	ret    

00001316 <fstat>:
SYSCALL(fstat)
    1316:	b8 08 00 00 00       	mov    $0x8,%eax
    131b:	cd 40                	int    $0x40
    131d:	c3                   	ret    

0000131e <link>:
SYSCALL(link)
    131e:	b8 13 00 00 00       	mov    $0x13,%eax
    1323:	cd 40                	int    $0x40
    1325:	c3                   	ret    

00001326 <mkdir>:
SYSCALL(mkdir)
    1326:	b8 14 00 00 00       	mov    $0x14,%eax
    132b:	cd 40                	int    $0x40
    132d:	c3                   	ret    

0000132e <chdir>:
SYSCALL(chdir)
    132e:	b8 09 00 00 00       	mov    $0x9,%eax
    1333:	cd 40                	int    $0x40
    1335:	c3                   	ret    

00001336 <dup>:
SYSCALL(dup)
    1336:	b8 0a 00 00 00       	mov    $0xa,%eax
    133b:	cd 40                	int    $0x40
    133d:	c3                   	ret    

0000133e <getpid>:
SYSCALL(getpid)
    133e:	b8 0b 00 00 00       	mov    $0xb,%eax
    1343:	cd 40                	int    $0x40
    1345:	c3                   	ret    

00001346 <sbrk>:
SYSCALL(sbrk)
    1346:	b8 0c 00 00 00       	mov    $0xc,%eax
    134b:	cd 40                	int    $0x40
    134d:	c3                   	ret    

0000134e <sleep>:
SYSCALL(sleep)
    134e:	b8 0d 00 00 00       	mov    $0xd,%eax
    1353:	cd 40                	int    $0x40
    1355:	c3                   	ret    

00001356 <uptime>:
SYSCALL(uptime)
    1356:	b8 0e 00 00 00       	mov    $0xe,%eax
    135b:	cd 40                	int    $0x40
    135d:	c3                   	ret    

0000135e <halt>:
SYSCALL(halt)
    135e:	b8 16 00 00 00       	mov    $0x16,%eax
    1363:	cd 40                	int    $0x40
    1365:	c3                   	ret    

00001366 <date>:
SYSCALL(date)
    1366:	b8 17 00 00 00       	mov    $0x17,%eax
    136b:	cd 40                	int    $0x40
    136d:	c3                   	ret    

0000136e <getuid>:
SYSCALL(getuid)
    136e:	b8 18 00 00 00       	mov    $0x18,%eax
    1373:	cd 40                	int    $0x40
    1375:	c3                   	ret    

00001376 <getgid>:
SYSCALL(getgid)
    1376:	b8 19 00 00 00       	mov    $0x19,%eax
    137b:	cd 40                	int    $0x40
    137d:	c3                   	ret    

0000137e <getppid>:
SYSCALL(getppid)
    137e:	b8 1a 00 00 00       	mov    $0x1a,%eax
    1383:	cd 40                	int    $0x40
    1385:	c3                   	ret    

00001386 <setuid>:
SYSCALL(setuid)
    1386:	b8 1b 00 00 00       	mov    $0x1b,%eax
    138b:	cd 40                	int    $0x40
    138d:	c3                   	ret    

0000138e <setgid>:
SYSCALL(setgid)
    138e:	b8 1c 00 00 00       	mov    $0x1c,%eax
    1393:	cd 40                	int    $0x40
    1395:	c3                   	ret    

00001396 <getprocs>:
SYSCALL(getprocs)
    1396:	b8 1d 00 00 00       	mov    $0x1d,%eax
    139b:	cd 40                	int    $0x40
    139d:	c3                   	ret    

0000139e <setpriority>:
SYSCALL(setpriority)
    139e:	b8 1e 00 00 00       	mov    $0x1e,%eax
    13a3:	cd 40                	int    $0x40
    13a5:	c3                   	ret    

000013a6 <chmod>:
SYSCALL(chmod)
    13a6:	b8 1f 00 00 00       	mov    $0x1f,%eax
    13ab:	cd 40                	int    $0x40
    13ad:	c3                   	ret    

000013ae <chown>:
SYSCALL(chown)
    13ae:	b8 20 00 00 00       	mov    $0x20,%eax
    13b3:	cd 40                	int    $0x40
    13b5:	c3                   	ret    

000013b6 <chgrp>:
SYSCALL(chgrp)
    13b6:	b8 21 00 00 00       	mov    $0x21,%eax
    13bb:	cd 40                	int    $0x40
    13bd:	c3                   	ret    

000013be <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    13be:	55                   	push   %ebp
    13bf:	89 e5                	mov    %esp,%ebp
    13c1:	83 ec 18             	sub    $0x18,%esp
    13c4:	8b 45 0c             	mov    0xc(%ebp),%eax
    13c7:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    13ca:	83 ec 04             	sub    $0x4,%esp
    13cd:	6a 01                	push   $0x1
    13cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
    13d2:	50                   	push   %eax
    13d3:	ff 75 08             	pushl  0x8(%ebp)
    13d6:	e8 03 ff ff ff       	call   12de <write>
    13db:	83 c4 10             	add    $0x10,%esp
}
    13de:	90                   	nop
    13df:	c9                   	leave  
    13e0:	c3                   	ret    

000013e1 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    13e1:	55                   	push   %ebp
    13e2:	89 e5                	mov    %esp,%ebp
    13e4:	53                   	push   %ebx
    13e5:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    13e8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    13ef:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    13f3:	74 17                	je     140c <printint+0x2b>
    13f5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    13f9:	79 11                	jns    140c <printint+0x2b>
    neg = 1;
    13fb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    1402:	8b 45 0c             	mov    0xc(%ebp),%eax
    1405:	f7 d8                	neg    %eax
    1407:	89 45 ec             	mov    %eax,-0x14(%ebp)
    140a:	eb 06                	jmp    1412 <printint+0x31>
  } else {
    x = xx;
    140c:	8b 45 0c             	mov    0xc(%ebp),%eax
    140f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    1412:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    1419:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    141c:	8d 41 01             	lea    0x1(%ecx),%eax
    141f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1422:	8b 5d 10             	mov    0x10(%ebp),%ebx
    1425:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1428:	ba 00 00 00 00       	mov    $0x0,%edx
    142d:	f7 f3                	div    %ebx
    142f:	89 d0                	mov    %edx,%eax
    1431:	0f b6 80 f4 1e 00 00 	movzbl 0x1ef4(%eax),%eax
    1438:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    143c:	8b 5d 10             	mov    0x10(%ebp),%ebx
    143f:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1442:	ba 00 00 00 00       	mov    $0x0,%edx
    1447:	f7 f3                	div    %ebx
    1449:	89 45 ec             	mov    %eax,-0x14(%ebp)
    144c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1450:	75 c7                	jne    1419 <printint+0x38>
  if(neg)
    1452:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1456:	74 2d                	je     1485 <printint+0xa4>
    buf[i++] = '-';
    1458:	8b 45 f4             	mov    -0xc(%ebp),%eax
    145b:	8d 50 01             	lea    0x1(%eax),%edx
    145e:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1461:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    1466:	eb 1d                	jmp    1485 <printint+0xa4>
    putc(fd, buf[i]);
    1468:	8d 55 dc             	lea    -0x24(%ebp),%edx
    146b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    146e:	01 d0                	add    %edx,%eax
    1470:	0f b6 00             	movzbl (%eax),%eax
    1473:	0f be c0             	movsbl %al,%eax
    1476:	83 ec 08             	sub    $0x8,%esp
    1479:	50                   	push   %eax
    147a:	ff 75 08             	pushl  0x8(%ebp)
    147d:	e8 3c ff ff ff       	call   13be <putc>
    1482:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    1485:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    1489:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    148d:	79 d9                	jns    1468 <printint+0x87>
    putc(fd, buf[i]);
}
    148f:	90                   	nop
    1490:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    1493:	c9                   	leave  
    1494:	c3                   	ret    

00001495 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    1495:	55                   	push   %ebp
    1496:	89 e5                	mov    %esp,%ebp
    1498:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    149b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    14a2:	8d 45 0c             	lea    0xc(%ebp),%eax
    14a5:	83 c0 04             	add    $0x4,%eax
    14a8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    14ab:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    14b2:	e9 59 01 00 00       	jmp    1610 <printf+0x17b>
    c = fmt[i] & 0xff;
    14b7:	8b 55 0c             	mov    0xc(%ebp),%edx
    14ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
    14bd:	01 d0                	add    %edx,%eax
    14bf:	0f b6 00             	movzbl (%eax),%eax
    14c2:	0f be c0             	movsbl %al,%eax
    14c5:	25 ff 00 00 00       	and    $0xff,%eax
    14ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    14cd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    14d1:	75 2c                	jne    14ff <printf+0x6a>
      if(c == '%'){
    14d3:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    14d7:	75 0c                	jne    14e5 <printf+0x50>
        state = '%';
    14d9:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    14e0:	e9 27 01 00 00       	jmp    160c <printf+0x177>
      } else {
        putc(fd, c);
    14e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    14e8:	0f be c0             	movsbl %al,%eax
    14eb:	83 ec 08             	sub    $0x8,%esp
    14ee:	50                   	push   %eax
    14ef:	ff 75 08             	pushl  0x8(%ebp)
    14f2:	e8 c7 fe ff ff       	call   13be <putc>
    14f7:	83 c4 10             	add    $0x10,%esp
    14fa:	e9 0d 01 00 00       	jmp    160c <printf+0x177>
      }
    } else if(state == '%'){
    14ff:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    1503:	0f 85 03 01 00 00    	jne    160c <printf+0x177>
      if(c == 'd'){
    1509:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    150d:	75 1e                	jne    152d <printf+0x98>
        printint(fd, *ap, 10, 1);
    150f:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1512:	8b 00                	mov    (%eax),%eax
    1514:	6a 01                	push   $0x1
    1516:	6a 0a                	push   $0xa
    1518:	50                   	push   %eax
    1519:	ff 75 08             	pushl  0x8(%ebp)
    151c:	e8 c0 fe ff ff       	call   13e1 <printint>
    1521:	83 c4 10             	add    $0x10,%esp
        ap++;
    1524:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1528:	e9 d8 00 00 00       	jmp    1605 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
    152d:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    1531:	74 06                	je     1539 <printf+0xa4>
    1533:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    1537:	75 1e                	jne    1557 <printf+0xc2>
        printint(fd, *ap, 16, 0);
    1539:	8b 45 e8             	mov    -0x18(%ebp),%eax
    153c:	8b 00                	mov    (%eax),%eax
    153e:	6a 00                	push   $0x0
    1540:	6a 10                	push   $0x10
    1542:	50                   	push   %eax
    1543:	ff 75 08             	pushl  0x8(%ebp)
    1546:	e8 96 fe ff ff       	call   13e1 <printint>
    154b:	83 c4 10             	add    $0x10,%esp
        ap++;
    154e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1552:	e9 ae 00 00 00       	jmp    1605 <printf+0x170>
      } else if(c == 's'){
    1557:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    155b:	75 43                	jne    15a0 <printf+0x10b>
        s = (char*)*ap;
    155d:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1560:	8b 00                	mov    (%eax),%eax
    1562:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    1565:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    1569:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    156d:	75 25                	jne    1594 <printf+0xff>
          s = "(null)";
    156f:	c7 45 f4 84 19 00 00 	movl   $0x1984,-0xc(%ebp)
        while(*s != 0){
    1576:	eb 1c                	jmp    1594 <printf+0xff>
          putc(fd, *s);
    1578:	8b 45 f4             	mov    -0xc(%ebp),%eax
    157b:	0f b6 00             	movzbl (%eax),%eax
    157e:	0f be c0             	movsbl %al,%eax
    1581:	83 ec 08             	sub    $0x8,%esp
    1584:	50                   	push   %eax
    1585:	ff 75 08             	pushl  0x8(%ebp)
    1588:	e8 31 fe ff ff       	call   13be <putc>
    158d:	83 c4 10             	add    $0x10,%esp
          s++;
    1590:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    1594:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1597:	0f b6 00             	movzbl (%eax),%eax
    159a:	84 c0                	test   %al,%al
    159c:	75 da                	jne    1578 <printf+0xe3>
    159e:	eb 65                	jmp    1605 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    15a0:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    15a4:	75 1d                	jne    15c3 <printf+0x12e>
        putc(fd, *ap);
    15a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
    15a9:	8b 00                	mov    (%eax),%eax
    15ab:	0f be c0             	movsbl %al,%eax
    15ae:	83 ec 08             	sub    $0x8,%esp
    15b1:	50                   	push   %eax
    15b2:	ff 75 08             	pushl  0x8(%ebp)
    15b5:	e8 04 fe ff ff       	call   13be <putc>
    15ba:	83 c4 10             	add    $0x10,%esp
        ap++;
    15bd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    15c1:	eb 42                	jmp    1605 <printf+0x170>
      } else if(c == '%'){
    15c3:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    15c7:	75 17                	jne    15e0 <printf+0x14b>
        putc(fd, c);
    15c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    15cc:	0f be c0             	movsbl %al,%eax
    15cf:	83 ec 08             	sub    $0x8,%esp
    15d2:	50                   	push   %eax
    15d3:	ff 75 08             	pushl  0x8(%ebp)
    15d6:	e8 e3 fd ff ff       	call   13be <putc>
    15db:	83 c4 10             	add    $0x10,%esp
    15de:	eb 25                	jmp    1605 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    15e0:	83 ec 08             	sub    $0x8,%esp
    15e3:	6a 25                	push   $0x25
    15e5:	ff 75 08             	pushl  0x8(%ebp)
    15e8:	e8 d1 fd ff ff       	call   13be <putc>
    15ed:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
    15f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    15f3:	0f be c0             	movsbl %al,%eax
    15f6:	83 ec 08             	sub    $0x8,%esp
    15f9:	50                   	push   %eax
    15fa:	ff 75 08             	pushl  0x8(%ebp)
    15fd:	e8 bc fd ff ff       	call   13be <putc>
    1602:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
    1605:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    160c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    1610:	8b 55 0c             	mov    0xc(%ebp),%edx
    1613:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1616:	01 d0                	add    %edx,%eax
    1618:	0f b6 00             	movzbl (%eax),%eax
    161b:	84 c0                	test   %al,%al
    161d:	0f 85 94 fe ff ff    	jne    14b7 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    1623:	90                   	nop
    1624:	c9                   	leave  
    1625:	c3                   	ret    

00001626 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1626:	55                   	push   %ebp
    1627:	89 e5                	mov    %esp,%ebp
    1629:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    162c:	8b 45 08             	mov    0x8(%ebp),%eax
    162f:	83 e8 08             	sub    $0x8,%eax
    1632:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1635:	a1 8c 1f 00 00       	mov    0x1f8c,%eax
    163a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    163d:	eb 24                	jmp    1663 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    163f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1642:	8b 00                	mov    (%eax),%eax
    1644:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1647:	77 12                	ja     165b <free+0x35>
    1649:	8b 45 f8             	mov    -0x8(%ebp),%eax
    164c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    164f:	77 24                	ja     1675 <free+0x4f>
    1651:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1654:	8b 00                	mov    (%eax),%eax
    1656:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1659:	77 1a                	ja     1675 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    165b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    165e:	8b 00                	mov    (%eax),%eax
    1660:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1663:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1666:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1669:	76 d4                	jbe    163f <free+0x19>
    166b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    166e:	8b 00                	mov    (%eax),%eax
    1670:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1673:	76 ca                	jbe    163f <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    1675:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1678:	8b 40 04             	mov    0x4(%eax),%eax
    167b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1682:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1685:	01 c2                	add    %eax,%edx
    1687:	8b 45 fc             	mov    -0x4(%ebp),%eax
    168a:	8b 00                	mov    (%eax),%eax
    168c:	39 c2                	cmp    %eax,%edx
    168e:	75 24                	jne    16b4 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    1690:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1693:	8b 50 04             	mov    0x4(%eax),%edx
    1696:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1699:	8b 00                	mov    (%eax),%eax
    169b:	8b 40 04             	mov    0x4(%eax),%eax
    169e:	01 c2                	add    %eax,%edx
    16a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16a3:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    16a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16a9:	8b 00                	mov    (%eax),%eax
    16ab:	8b 10                	mov    (%eax),%edx
    16ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16b0:	89 10                	mov    %edx,(%eax)
    16b2:	eb 0a                	jmp    16be <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    16b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16b7:	8b 10                	mov    (%eax),%edx
    16b9:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16bc:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    16be:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16c1:	8b 40 04             	mov    0x4(%eax),%eax
    16c4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    16cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16ce:	01 d0                	add    %edx,%eax
    16d0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    16d3:	75 20                	jne    16f5 <free+0xcf>
    p->s.size += bp->s.size;
    16d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16d8:	8b 50 04             	mov    0x4(%eax),%edx
    16db:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16de:	8b 40 04             	mov    0x4(%eax),%eax
    16e1:	01 c2                	add    %eax,%edx
    16e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16e6:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    16e9:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16ec:	8b 10                	mov    (%eax),%edx
    16ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16f1:	89 10                	mov    %edx,(%eax)
    16f3:	eb 08                	jmp    16fd <free+0xd7>
  } else
    p->s.ptr = bp;
    16f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16f8:	8b 55 f8             	mov    -0x8(%ebp),%edx
    16fb:	89 10                	mov    %edx,(%eax)
  freep = p;
    16fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1700:	a3 8c 1f 00 00       	mov    %eax,0x1f8c
}
    1705:	90                   	nop
    1706:	c9                   	leave  
    1707:	c3                   	ret    

00001708 <morecore>:

static Header*
morecore(uint nu)
{
    1708:	55                   	push   %ebp
    1709:	89 e5                	mov    %esp,%ebp
    170b:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    170e:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    1715:	77 07                	ja     171e <morecore+0x16>
    nu = 4096;
    1717:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    171e:	8b 45 08             	mov    0x8(%ebp),%eax
    1721:	c1 e0 03             	shl    $0x3,%eax
    1724:	83 ec 0c             	sub    $0xc,%esp
    1727:	50                   	push   %eax
    1728:	e8 19 fc ff ff       	call   1346 <sbrk>
    172d:	83 c4 10             	add    $0x10,%esp
    1730:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    1733:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    1737:	75 07                	jne    1740 <morecore+0x38>
    return 0;
    1739:	b8 00 00 00 00       	mov    $0x0,%eax
    173e:	eb 26                	jmp    1766 <morecore+0x5e>
  hp = (Header*)p;
    1740:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1743:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    1746:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1749:	8b 55 08             	mov    0x8(%ebp),%edx
    174c:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    174f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1752:	83 c0 08             	add    $0x8,%eax
    1755:	83 ec 0c             	sub    $0xc,%esp
    1758:	50                   	push   %eax
    1759:	e8 c8 fe ff ff       	call   1626 <free>
    175e:	83 c4 10             	add    $0x10,%esp
  return freep;
    1761:	a1 8c 1f 00 00       	mov    0x1f8c,%eax
}
    1766:	c9                   	leave  
    1767:	c3                   	ret    

00001768 <malloc>:

void*
malloc(uint nbytes)
{
    1768:	55                   	push   %ebp
    1769:	89 e5                	mov    %esp,%ebp
    176b:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    176e:	8b 45 08             	mov    0x8(%ebp),%eax
    1771:	83 c0 07             	add    $0x7,%eax
    1774:	c1 e8 03             	shr    $0x3,%eax
    1777:	83 c0 01             	add    $0x1,%eax
    177a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    177d:	a1 8c 1f 00 00       	mov    0x1f8c,%eax
    1782:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1785:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1789:	75 23                	jne    17ae <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    178b:	c7 45 f0 84 1f 00 00 	movl   $0x1f84,-0x10(%ebp)
    1792:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1795:	a3 8c 1f 00 00       	mov    %eax,0x1f8c
    179a:	a1 8c 1f 00 00       	mov    0x1f8c,%eax
    179f:	a3 84 1f 00 00       	mov    %eax,0x1f84
    base.s.size = 0;
    17a4:	c7 05 88 1f 00 00 00 	movl   $0x0,0x1f88
    17ab:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    17ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17b1:	8b 00                	mov    (%eax),%eax
    17b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    17b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17b9:	8b 40 04             	mov    0x4(%eax),%eax
    17bc:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    17bf:	72 4d                	jb     180e <malloc+0xa6>
      if(p->s.size == nunits)
    17c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17c4:	8b 40 04             	mov    0x4(%eax),%eax
    17c7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    17ca:	75 0c                	jne    17d8 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    17cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17cf:	8b 10                	mov    (%eax),%edx
    17d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17d4:	89 10                	mov    %edx,(%eax)
    17d6:	eb 26                	jmp    17fe <malloc+0x96>
      else {
        p->s.size -= nunits;
    17d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17db:	8b 40 04             	mov    0x4(%eax),%eax
    17de:	2b 45 ec             	sub    -0x14(%ebp),%eax
    17e1:	89 c2                	mov    %eax,%edx
    17e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17e6:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    17e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17ec:	8b 40 04             	mov    0x4(%eax),%eax
    17ef:	c1 e0 03             	shl    $0x3,%eax
    17f2:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    17f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17f8:	8b 55 ec             	mov    -0x14(%ebp),%edx
    17fb:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    17fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1801:	a3 8c 1f 00 00       	mov    %eax,0x1f8c
      return (void*)(p + 1);
    1806:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1809:	83 c0 08             	add    $0x8,%eax
    180c:	eb 3b                	jmp    1849 <malloc+0xe1>
    }
    if(p == freep)
    180e:	a1 8c 1f 00 00       	mov    0x1f8c,%eax
    1813:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    1816:	75 1e                	jne    1836 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
    1818:	83 ec 0c             	sub    $0xc,%esp
    181b:	ff 75 ec             	pushl  -0x14(%ebp)
    181e:	e8 e5 fe ff ff       	call   1708 <morecore>
    1823:	83 c4 10             	add    $0x10,%esp
    1826:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1829:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    182d:	75 07                	jne    1836 <malloc+0xce>
        return 0;
    182f:	b8 00 00 00 00       	mov    $0x0,%eax
    1834:	eb 13                	jmp    1849 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1836:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1839:	89 45 f0             	mov    %eax,-0x10(%ebp)
    183c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    183f:	8b 00                	mov    (%eax),%eax
    1841:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    1844:	e9 6d ff ff ff       	jmp    17b6 <malloc+0x4e>
}
    1849:	c9                   	leave  
    184a:	c3                   	ret    

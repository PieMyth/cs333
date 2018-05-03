
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 70 d6 10 80       	mov    $0x8010d670,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 2d 39 10 80       	mov    $0x8010392d,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 98 93 10 80       	push   $0x80109398
80100042:	68 80 d6 10 80       	push   $0x8010d680
80100047:	e8 b5 5c 00 00       	call   80105d01 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 90 15 11 80 84 	movl   $0x80111584,0x80111590
80100056:	15 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 94 15 11 80 84 	movl   $0x80111584,0x80111594
80100060:	15 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 b4 d6 10 80 	movl   $0x8010d6b4,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 94 15 11 80    	mov    0x80111594,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c 84 15 11 80 	movl   $0x80111584,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 94 15 11 80       	mov    0x80111594,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 94 15 11 80       	mov    %eax,0x80111594

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 84 15 11 80       	mov    $0x80111584,%eax
801000ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ae:	72 bc                	jb     8010006c <binit+0x38>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000b0:	90                   	nop
801000b1:	c9                   	leave  
801000b2:	c3                   	ret    

801000b3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b3:	55                   	push   %ebp
801000b4:	89 e5                	mov    %esp,%ebp
801000b6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b9:	83 ec 0c             	sub    $0xc,%esp
801000bc:	68 80 d6 10 80       	push   $0x8010d680
801000c1:	e8 5d 5c 00 00       	call   80105d23 <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c9:	a1 94 15 11 80       	mov    0x80111594,%eax
801000ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d1:	eb 67                	jmp    8010013a <bget+0x87>
    if(b->dev == dev && b->blockno == blockno){
801000d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d6:	8b 40 04             	mov    0x4(%eax),%eax
801000d9:	3b 45 08             	cmp    0x8(%ebp),%eax
801000dc:	75 53                	jne    80100131 <bget+0x7e>
801000de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e1:	8b 40 08             	mov    0x8(%eax),%eax
801000e4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e7:	75 48                	jne    80100131 <bget+0x7e>
      if(!(b->flags & B_BUSY)){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 00                	mov    (%eax),%eax
801000ee:	83 e0 01             	and    $0x1,%eax
801000f1:	85 c0                	test   %eax,%eax
801000f3:	75 27                	jne    8010011c <bget+0x69>
        b->flags |= B_BUSY;
801000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f8:	8b 00                	mov    (%eax),%eax
801000fa:	83 c8 01             	or     $0x1,%eax
801000fd:	89 c2                	mov    %eax,%edx
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
80100104:	83 ec 0c             	sub    $0xc,%esp
80100107:	68 80 d6 10 80       	push   $0x8010d680
8010010c:	e8 79 5c 00 00       	call   80105d8a <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 80 d6 10 80       	push   $0x8010d680
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 dd 50 00 00       	call   80105209 <sleep>
8010012c:	83 c4 10             	add    $0x10,%esp
      goto loop;
8010012f:	eb 98                	jmp    801000c9 <bget+0x16>

  acquire(&bcache.lock);

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100134:	8b 40 10             	mov    0x10(%eax),%eax
80100137:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010013a:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100143:	a1 90 15 11 80       	mov    0x80111590,%eax
80100148:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014b:	eb 51                	jmp    8010019e <bget+0xeb>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010014d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100150:	8b 00                	mov    (%eax),%eax
80100152:	83 e0 01             	and    $0x1,%eax
80100155:	85 c0                	test   %eax,%eax
80100157:	75 3c                	jne    80100195 <bget+0xe2>
80100159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015c:	8b 00                	mov    (%eax),%eax
8010015e:	83 e0 04             	and    $0x4,%eax
80100161:	85 c0                	test   %eax,%eax
80100163:	75 30                	jne    80100195 <bget+0xe2>
      b->dev = dev;
80100165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100168:	8b 55 08             	mov    0x8(%ebp),%edx
8010016b:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010016e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100171:	8b 55 0c             	mov    0xc(%ebp),%edx
80100174:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100180:	83 ec 0c             	sub    $0xc,%esp
80100183:	68 80 d6 10 80       	push   $0x8010d680
80100188:	e8 fd 5b 00 00       	call   80105d8a <release>
8010018d:	83 c4 10             	add    $0x10,%esp
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1f                	jmp    801001b4 <bget+0x101>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 0c             	mov    0xc(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 9f 93 10 80       	push   $0x8010939f
801001af:	e8 b2 03 00 00       	call   80100566 <panic>
}
801001b4:	c9                   	leave  
801001b5:	c3                   	ret    

801001b6 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b6:	55                   	push   %ebp
801001b7:	89 e5                	mov    %esp,%ebp
801001b9:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bc:	83 ec 08             	sub    $0x8,%esp
801001bf:	ff 75 0c             	pushl  0xc(%ebp)
801001c2:	ff 75 08             	pushl  0x8(%ebp)
801001c5:	e8 e9 fe ff ff       	call   801000b3 <bget>
801001ca:	83 c4 10             	add    $0x10,%esp
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0e                	jne    801001ea <bread+0x34>
    iderw(b);
801001dc:	83 ec 0c             	sub    $0xc,%esp
801001df:	ff 75 f4             	pushl  -0xc(%ebp)
801001e2:	e8 c4 27 00 00       	call   801029ab <iderw>
801001e7:	83 c4 10             	add    $0x10,%esp
  }
  return b;
801001ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ed:	c9                   	leave  
801001ee:	c3                   	ret    

801001ef <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001ef:	55                   	push   %ebp
801001f0:	89 e5                	mov    %esp,%ebp
801001f2:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
801001f5:	8b 45 08             	mov    0x8(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 01             	and    $0x1,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0d                	jne    8010020e <bwrite+0x1f>
    panic("bwrite");
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	68 b0 93 10 80       	push   $0x801093b0
80100209:	e8 58 03 00 00       	call   80100566 <panic>
  b->flags |= B_DIRTY;
8010020e:	8b 45 08             	mov    0x8(%ebp),%eax
80100211:	8b 00                	mov    (%eax),%eax
80100213:	83 c8 04             	or     $0x4,%eax
80100216:	89 c2                	mov    %eax,%edx
80100218:	8b 45 08             	mov    0x8(%ebp),%eax
8010021b:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021d:	83 ec 0c             	sub    $0xc,%esp
80100220:	ff 75 08             	pushl  0x8(%ebp)
80100223:	e8 83 27 00 00       	call   801029ab <iderw>
80100228:	83 c4 10             	add    $0x10,%esp
}
8010022b:	90                   	nop
8010022c:	c9                   	leave  
8010022d:	c3                   	ret    

8010022e <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022e:	55                   	push   %ebp
8010022f:	89 e5                	mov    %esp,%ebp
80100231:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100234:	8b 45 08             	mov    0x8(%ebp),%eax
80100237:	8b 00                	mov    (%eax),%eax
80100239:	83 e0 01             	and    $0x1,%eax
8010023c:	85 c0                	test   %eax,%eax
8010023e:	75 0d                	jne    8010024d <brelse+0x1f>
    panic("brelse");
80100240:	83 ec 0c             	sub    $0xc,%esp
80100243:	68 b7 93 10 80       	push   $0x801093b7
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 80 d6 10 80       	push   $0x8010d680
80100255:	e8 c9 5a 00 00       	call   80105d23 <acquire>
8010025a:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
8010025d:	8b 45 08             	mov    0x8(%ebp),%eax
80100260:	8b 40 10             	mov    0x10(%eax),%eax
80100263:	8b 55 08             	mov    0x8(%ebp),%edx
80100266:	8b 52 0c             	mov    0xc(%edx),%edx
80100269:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
8010026c:	8b 45 08             	mov    0x8(%ebp),%eax
8010026f:	8b 40 0c             	mov    0xc(%eax),%eax
80100272:	8b 55 08             	mov    0x8(%ebp),%edx
80100275:	8b 52 10             	mov    0x10(%edx),%edx
80100278:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010027b:	8b 15 94 15 11 80    	mov    0x80111594,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c 84 15 11 80 	movl   $0x80111584,0xc(%eax)
  bcache.head.next->prev = b;
80100291:	a1 94 15 11 80       	mov    0x80111594,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 94 15 11 80       	mov    %eax,0x80111594

  b->flags &= ~B_BUSY;
801002a4:	8b 45 08             	mov    0x8(%ebp),%eax
801002a7:	8b 00                	mov    (%eax),%eax
801002a9:	83 e0 fe             	and    $0xfffffffe,%eax
801002ac:	89 c2                	mov    %eax,%edx
801002ae:	8b 45 08             	mov    0x8(%ebp),%eax
801002b1:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	ff 75 08             	pushl  0x8(%ebp)
801002b9:	e8 92 50 00 00       	call   80105350 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 80 d6 10 80       	push   $0x8010d680
801002c9:	e8 bc 5a 00 00       	call   80105d8a <release>
801002ce:	83 c4 10             	add    $0x10,%esp
}
801002d1:	90                   	nop
801002d2:	c9                   	leave  
801002d3:	c3                   	ret    

801002d4 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
801002d4:	55                   	push   %ebp
801002d5:	89 e5                	mov    %esp,%ebp
801002d7:	83 ec 14             	sub    $0x14,%esp
801002da:	8b 45 08             	mov    0x8(%ebp),%eax
801002dd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e5:	89 c2                	mov    %eax,%edx
801002e7:	ec                   	in     (%dx),%al
801002e8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002eb:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002ef:	c9                   	leave  
801002f0:	c3                   	ret    

801002f1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	83 ec 08             	sub    $0x8,%esp
801002f7:	8b 55 08             	mov    0x8(%ebp),%edx
801002fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801002fd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80100301:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100304:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100308:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	90                   	nop
8010030e:	c9                   	leave  
8010030f:	c3                   	ret    

80100310 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100310:	55                   	push   %ebp
80100311:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100313:	fa                   	cli    
}
80100314:	90                   	nop
80100315:	5d                   	pop    %ebp
80100316:	c3                   	ret    

80100317 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100317:	55                   	push   %ebp
80100318:	89 e5                	mov    %esp,%ebp
8010031a:	53                   	push   %ebx
8010031b:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100322:	74 1c                	je     80100340 <printint+0x29>
80100324:	8b 45 08             	mov    0x8(%ebp),%eax
80100327:	c1 e8 1f             	shr    $0x1f,%eax
8010032a:	0f b6 c0             	movzbl %al,%eax
8010032d:	89 45 10             	mov    %eax,0x10(%ebp)
80100330:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100334:	74 0a                	je     80100340 <printint+0x29>
    x = -xx;
80100336:	8b 45 08             	mov    0x8(%ebp),%eax
80100339:	f7 d8                	neg    %eax
8010033b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033e:	eb 06                	jmp    80100346 <printint+0x2f>
  else
    x = xx;
80100340:	8b 45 08             	mov    0x8(%ebp),%eax
80100343:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100350:	8d 41 01             	lea    0x1(%ecx),%eax
80100353:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100359:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035c:	ba 00 00 00 00       	mov    $0x0,%edx
80100361:	f7 f3                	div    %ebx
80100363:	89 d0                	mov    %edx,%eax
80100365:	0f b6 80 04 a0 10 80 	movzbl -0x7fef5ffc(%eax),%eax
8010036c:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
80100370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100376:	ba 00 00 00 00       	mov    $0x0,%edx
8010037b:	f7 f3                	div    %ebx
8010037d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100380:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100384:	75 c7                	jne    8010034d <printint+0x36>

  if(sign)
80100386:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038a:	74 2a                	je     801003b6 <printint+0x9f>
    buf[i++] = '-';
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010039a:	eb 1a                	jmp    801003b6 <printint+0x9f>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	0f b6 00             	movzbl (%eax),%eax
801003a7:	0f be c0             	movsbl %al,%eax
801003aa:	83 ec 0c             	sub    $0xc,%esp
801003ad:	50                   	push   %eax
801003ae:	e8 df 03 00 00       	call   80100792 <consputc>
801003b3:	83 c4 10             	add    $0x10,%esp
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003be:	79 dc                	jns    8010039c <printint+0x85>
    consputc(buf[i]);
}
801003c0:	90                   	nop
801003c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801003c4:	c9                   	leave  
801003c5:	c3                   	ret    

801003c6 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003cc:	a1 14 c6 10 80       	mov    0x8010c614,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 e0 c5 10 80       	push   $0x8010c5e0
801003e2:	e8 3c 59 00 00       	call   80105d23 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 be 93 10 80       	push   $0x801093be
801003f9:	e8 68 01 00 00       	call   80100566 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003fe:	8d 45 0c             	lea    0xc(%ebp),%eax
80100401:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100404:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010040b:	e9 1a 01 00 00       	jmp    8010052a <cprintf+0x164>
    if(c != '%'){
80100410:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100414:	74 13                	je     80100429 <cprintf+0x63>
      consputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	ff 75 e4             	pushl  -0x1c(%ebp)
8010041c:	e8 71 03 00 00       	call   80100792 <consputc>
80100421:	83 c4 10             	add    $0x10,%esp
      continue;
80100424:	e9 fd 00 00 00       	jmp    80100526 <cprintf+0x160>
    }
    c = fmt[++i] & 0xff;
80100429:	8b 55 08             	mov    0x8(%ebp),%edx
8010042c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100433:	01 d0                	add    %edx,%eax
80100435:	0f b6 00             	movzbl (%eax),%eax
80100438:	0f be c0             	movsbl %al,%eax
8010043b:	25 ff 00 00 00       	and    $0xff,%eax
80100440:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100443:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100447:	0f 84 ff 00 00 00    	je     8010054c <cprintf+0x186>
      break;
    switch(c){
8010044d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100450:	83 f8 70             	cmp    $0x70,%eax
80100453:	74 47                	je     8010049c <cprintf+0xd6>
80100455:	83 f8 70             	cmp    $0x70,%eax
80100458:	7f 13                	jg     8010046d <cprintf+0xa7>
8010045a:	83 f8 25             	cmp    $0x25,%eax
8010045d:	0f 84 98 00 00 00    	je     801004fb <cprintf+0x135>
80100463:	83 f8 64             	cmp    $0x64,%eax
80100466:	74 14                	je     8010047c <cprintf+0xb6>
80100468:	e9 9d 00 00 00       	jmp    8010050a <cprintf+0x144>
8010046d:	83 f8 73             	cmp    $0x73,%eax
80100470:	74 47                	je     801004b9 <cprintf+0xf3>
80100472:	83 f8 78             	cmp    $0x78,%eax
80100475:	74 25                	je     8010049c <cprintf+0xd6>
80100477:	e9 8e 00 00 00       	jmp    8010050a <cprintf+0x144>
    case 'd':
      printint(*argp++, 10, 1);
8010047c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047f:	8d 50 04             	lea    0x4(%eax),%edx
80100482:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100485:	8b 00                	mov    (%eax),%eax
80100487:	83 ec 04             	sub    $0x4,%esp
8010048a:	6a 01                	push   $0x1
8010048c:	6a 0a                	push   $0xa
8010048e:	50                   	push   %eax
8010048f:	e8 83 fe ff ff       	call   80100317 <printint>
80100494:	83 c4 10             	add    $0x10,%esp
      break;
80100497:	e9 8a 00 00 00       	jmp    80100526 <cprintf+0x160>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	83 ec 04             	sub    $0x4,%esp
801004aa:	6a 00                	push   $0x0
801004ac:	6a 10                	push   $0x10
801004ae:	50                   	push   %eax
801004af:	e8 63 fe ff ff       	call   80100317 <printint>
801004b4:	83 c4 10             	add    $0x10,%esp
      break;
801004b7:	eb 6d                	jmp    80100526 <cprintf+0x160>
    case 's':
      if((s = (char*)*argp++) == 0)
801004b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004bc:	8d 50 04             	lea    0x4(%eax),%edx
801004bf:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c2:	8b 00                	mov    (%eax),%eax
801004c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cb:	75 22                	jne    801004ef <cprintf+0x129>
        s = "(null)";
801004cd:	c7 45 ec c7 93 10 80 	movl   $0x801093c7,-0x14(%ebp)
      for(; *s; s++)
801004d4:	eb 19                	jmp    801004ef <cprintf+0x129>
        consputc(*s);
801004d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d9:	0f b6 00             	movzbl (%eax),%eax
801004dc:	0f be c0             	movsbl %al,%eax
801004df:	83 ec 0c             	sub    $0xc,%esp
801004e2:	50                   	push   %eax
801004e3:	e8 aa 02 00 00       	call   80100792 <consputc>
801004e8:	83 c4 10             	add    $0x10,%esp
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004eb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f2:	0f b6 00             	movzbl (%eax),%eax
801004f5:	84 c0                	test   %al,%al
801004f7:	75 dd                	jne    801004d6 <cprintf+0x110>
        consputc(*s);
      break;
801004f9:	eb 2b                	jmp    80100526 <cprintf+0x160>
    case '%':
      consputc('%');
801004fb:	83 ec 0c             	sub    $0xc,%esp
801004fe:	6a 25                	push   $0x25
80100500:	e8 8d 02 00 00       	call   80100792 <consputc>
80100505:	83 c4 10             	add    $0x10,%esp
      break;
80100508:	eb 1c                	jmp    80100526 <cprintf+0x160>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010050a:	83 ec 0c             	sub    $0xc,%esp
8010050d:	6a 25                	push   $0x25
8010050f:	e8 7e 02 00 00       	call   80100792 <consputc>
80100514:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100517:	83 ec 0c             	sub    $0xc,%esp
8010051a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010051d:	e8 70 02 00 00       	call   80100792 <consputc>
80100522:	83 c4 10             	add    $0x10,%esp
      break;
80100525:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100526:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010052a:	8b 55 08             	mov    0x8(%ebp),%edx
8010052d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100530:	01 d0                	add    %edx,%eax
80100532:	0f b6 00             	movzbl (%eax),%eax
80100535:	0f be c0             	movsbl %al,%eax
80100538:	25 ff 00 00 00       	and    $0xff,%eax
8010053d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100540:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100544:	0f 85 c6 fe ff ff    	jne    80100410 <cprintf+0x4a>
8010054a:	eb 01                	jmp    8010054d <cprintf+0x187>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
8010054c:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
8010054d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100551:	74 10                	je     80100563 <cprintf+0x19d>
    release(&cons.lock);
80100553:	83 ec 0c             	sub    $0xc,%esp
80100556:	68 e0 c5 10 80       	push   $0x8010c5e0
8010055b:	e8 2a 58 00 00       	call   80105d8a <release>
80100560:	83 c4 10             	add    $0x10,%esp
}
80100563:	90                   	nop
80100564:	c9                   	leave  
80100565:	c3                   	ret    

80100566 <panic>:

void
panic(char *s)
{
80100566:	55                   	push   %ebp
80100567:	89 e5                	mov    %esp,%ebp
80100569:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
8010056c:	e8 9f fd ff ff       	call   80100310 <cli>
  cons.locking = 0;
80100571:	c7 05 14 c6 10 80 00 	movl   $0x0,0x8010c614
80100578:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010057b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f b6 c0             	movzbl %al,%eax
80100587:	83 ec 08             	sub    $0x8,%esp
8010058a:	50                   	push   %eax
8010058b:	68 ce 93 10 80       	push   $0x801093ce
80100590:	e8 31 fe ff ff       	call   801003c6 <cprintf>
80100595:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100598:	8b 45 08             	mov    0x8(%ebp),%eax
8010059b:	83 ec 0c             	sub    $0xc,%esp
8010059e:	50                   	push   %eax
8010059f:	e8 22 fe ff ff       	call   801003c6 <cprintf>
801005a4:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005a7:	83 ec 0c             	sub    $0xc,%esp
801005aa:	68 dd 93 10 80       	push   $0x801093dd
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 15 58 00 00       	call   80105ddc <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 df 93 10 80       	push   $0x801093df
801005e3:	e8 de fd ff ff       	call   801003c6 <cprintf>
801005e8:	83 c4 10             	add    $0x10,%esp
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005ef:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005f3:	7e de                	jle    801005d3 <panic+0x6d>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005f5:	c7 05 c0 c5 10 80 01 	movl   $0x1,0x8010c5c0
801005fc:	00 00 00 
  for(;;)
    ;
801005ff:	eb fe                	jmp    801005ff <panic+0x99>

80100601 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100601:	55                   	push   %ebp
80100602:	89 e5                	mov    %esp,%ebp
80100604:	83 ec 18             	sub    $0x18,%esp
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100607:	6a 0e                	push   $0xe
80100609:	68 d4 03 00 00       	push   $0x3d4
8010060e:	e8 de fc ff ff       	call   801002f1 <outb>
80100613:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
80100616:	68 d5 03 00 00       	push   $0x3d5
8010061b:	e8 b4 fc ff ff       	call   801002d4 <inb>
80100620:	83 c4 04             	add    $0x4,%esp
80100623:	0f b6 c0             	movzbl %al,%eax
80100626:	c1 e0 08             	shl    $0x8,%eax
80100629:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010062c:	6a 0f                	push   $0xf
8010062e:	68 d4 03 00 00       	push   $0x3d4
80100633:	e8 b9 fc ff ff       	call   801002f1 <outb>
80100638:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
8010063b:	68 d5 03 00 00       	push   $0x3d5
80100640:	e8 8f fc ff ff       	call   801002d4 <inb>
80100645:	83 c4 04             	add    $0x4,%esp
80100648:	0f b6 c0             	movzbl %al,%eax
8010064b:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010064e:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100652:	75 30                	jne    80100684 <cgaputc+0x83>
    pos += 80 - pos%80;
80100654:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100657:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010065c:	89 c8                	mov    %ecx,%eax
8010065e:	f7 ea                	imul   %edx
80100660:	c1 fa 05             	sar    $0x5,%edx
80100663:	89 c8                	mov    %ecx,%eax
80100665:	c1 f8 1f             	sar    $0x1f,%eax
80100668:	29 c2                	sub    %eax,%edx
8010066a:	89 d0                	mov    %edx,%eax
8010066c:	c1 e0 02             	shl    $0x2,%eax
8010066f:	01 d0                	add    %edx,%eax
80100671:	c1 e0 04             	shl    $0x4,%eax
80100674:	29 c1                	sub    %eax,%ecx
80100676:	89 ca                	mov    %ecx,%edx
80100678:	b8 50 00 00 00       	mov    $0x50,%eax
8010067d:	29 d0                	sub    %edx,%eax
8010067f:	01 45 f4             	add    %eax,-0xc(%ebp)
80100682:	eb 34                	jmp    801006b8 <cgaputc+0xb7>
  else if(c == BACKSPACE){
80100684:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010068b:	75 0c                	jne    80100699 <cgaputc+0x98>
    if(pos > 0) --pos;
8010068d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100691:	7e 25                	jle    801006b8 <cgaputc+0xb7>
80100693:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100697:	eb 1f                	jmp    801006b8 <cgaputc+0xb7>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100699:	8b 0d 00 a0 10 80    	mov    0x8010a000,%ecx
8010069f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006a2:	8d 50 01             	lea    0x1(%eax),%edx
801006a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006a8:	01 c0                	add    %eax,%eax
801006aa:	01 c8                	add    %ecx,%eax
801006ac:	8b 55 08             	mov    0x8(%ebp),%edx
801006af:	0f b6 d2             	movzbl %dl,%edx
801006b2:	80 ce 07             	or     $0x7,%dh
801006b5:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
801006b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006bc:	78 09                	js     801006c7 <cgaputc+0xc6>
801006be:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
801006c5:	7e 0d                	jle    801006d4 <cgaputc+0xd3>
    panic("pos under/overflow");
801006c7:	83 ec 0c             	sub    $0xc,%esp
801006ca:	68 e3 93 10 80       	push   $0x801093e3
801006cf:	e8 92 fe ff ff       	call   80100566 <panic>

  if((pos/80) >= 24){  // Scroll up.
801006d4:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006db:	7e 4c                	jle    80100729 <cgaputc+0x128>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006dd:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006e2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006e8:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006ed:	83 ec 04             	sub    $0x4,%esp
801006f0:	68 60 0e 00 00       	push   $0xe60
801006f5:	52                   	push   %edx
801006f6:	50                   	push   %eax
801006f7:	e8 49 59 00 00       	call   80106045 <memmove>
801006fc:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801006ff:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100703:	b8 80 07 00 00       	mov    $0x780,%eax
80100708:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010070b:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010070e:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100713:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100716:	01 c9                	add    %ecx,%ecx
80100718:	01 c8                	add    %ecx,%eax
8010071a:	83 ec 04             	sub    $0x4,%esp
8010071d:	52                   	push   %edx
8010071e:	6a 00                	push   $0x0
80100720:	50                   	push   %eax
80100721:	e8 60 58 00 00       	call   80105f86 <memset>
80100726:	83 c4 10             	add    $0x10,%esp
  }

  outb(CRTPORT, 14);
80100729:	83 ec 08             	sub    $0x8,%esp
8010072c:	6a 0e                	push   $0xe
8010072e:	68 d4 03 00 00       	push   $0x3d4
80100733:	e8 b9 fb ff ff       	call   801002f1 <outb>
80100738:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010073b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010073e:	c1 f8 08             	sar    $0x8,%eax
80100741:	0f b6 c0             	movzbl %al,%eax
80100744:	83 ec 08             	sub    $0x8,%esp
80100747:	50                   	push   %eax
80100748:	68 d5 03 00 00       	push   $0x3d5
8010074d:	e8 9f fb ff ff       	call   801002f1 <outb>
80100752:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
80100755:	83 ec 08             	sub    $0x8,%esp
80100758:	6a 0f                	push   $0xf
8010075a:	68 d4 03 00 00       	push   $0x3d4
8010075f:	e8 8d fb ff ff       	call   801002f1 <outb>
80100764:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
80100767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010076a:	0f b6 c0             	movzbl %al,%eax
8010076d:	83 ec 08             	sub    $0x8,%esp
80100770:	50                   	push   %eax
80100771:	68 d5 03 00 00       	push   $0x3d5
80100776:	e8 76 fb ff ff       	call   801002f1 <outb>
8010077b:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
8010077e:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100783:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100786:	01 d2                	add    %edx,%edx
80100788:	01 d0                	add    %edx,%eax
8010078a:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010078f:	90                   	nop
80100790:	c9                   	leave  
80100791:	c3                   	ret    

80100792 <consputc>:

void
consputc(int c)
{
80100792:	55                   	push   %ebp
80100793:	89 e5                	mov    %esp,%ebp
80100795:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100798:	a1 c0 c5 10 80       	mov    0x8010c5c0,%eax
8010079d:	85 c0                	test   %eax,%eax
8010079f:	74 07                	je     801007a8 <consputc+0x16>
    cli();
801007a1:	e8 6a fb ff ff       	call   80100310 <cli>
    for(;;)
      ;
801007a6:	eb fe                	jmp    801007a6 <consputc+0x14>
  }

  if(c == BACKSPACE){
801007a8:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007af:	75 29                	jne    801007da <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007b1:	83 ec 0c             	sub    $0xc,%esp
801007b4:	6a 08                	push   $0x8
801007b6:	e8 66 72 00 00       	call   80107a21 <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 59 72 00 00       	call   80107a21 <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 4c 72 00 00       	call   80107a21 <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 3c 72 00 00       	call   80107a21 <uartputc>
801007e5:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
801007e8:	83 ec 0c             	sub    $0xc,%esp
801007eb:	ff 75 08             	pushl  0x8(%ebp)
801007ee:	e8 0e fe ff ff       	call   80100601 <cgaputc>
801007f3:	83 c4 10             	add    $0x10,%esp
}
801007f6:	90                   	nop
801007f7:	c9                   	leave  
801007f8:	c3                   	ret    

801007f9 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007f9:	55                   	push   %ebp
801007fa:	89 e5                	mov    %esp,%ebp
801007fc:	83 ec 28             	sub    $0x28,%esp
  int c, doprocdump = 0;
801007ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
#ifdef CS333_P3P4
  int dopids = 0;
80100806:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  int dofree = 0;
8010080d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int dosleep = 0;
80100814:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  int dozombie = 0;
8010081b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
#endif

  acquire(&cons.lock);
80100822:	83 ec 0c             	sub    $0xc,%esp
80100825:	68 e0 c5 10 80       	push   $0x8010c5e0
8010082a:	e8 f4 54 00 00       	call   80105d23 <acquire>
8010082f:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
80100832:	e9 9a 01 00 00       	jmp    801009d1 <consoleintr+0x1d8>
    switch(c){
80100837:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010083a:	83 f8 12             	cmp    $0x12,%eax
8010083d:	74 50                	je     8010088f <consoleintr+0x96>
8010083f:	83 f8 12             	cmp    $0x12,%eax
80100842:	7f 18                	jg     8010085c <consoleintr+0x63>
80100844:	83 f8 08             	cmp    $0x8,%eax
80100847:	0f 84 bd 00 00 00    	je     8010090a <consoleintr+0x111>
8010084d:	83 f8 10             	cmp    $0x10,%eax
80100850:	74 31                	je     80100883 <consoleintr+0x8a>
80100852:	83 f8 06             	cmp    $0x6,%eax
80100855:	74 44                	je     8010089b <consoleintr+0xa2>
80100857:	e9 e3 00 00 00       	jmp    8010093f <consoleintr+0x146>
8010085c:	83 f8 15             	cmp    $0x15,%eax
8010085f:	74 7b                	je     801008dc <consoleintr+0xe3>
80100861:	83 f8 15             	cmp    $0x15,%eax
80100864:	7f 0a                	jg     80100870 <consoleintr+0x77>
80100866:	83 f8 13             	cmp    $0x13,%eax
80100869:	74 3c                	je     801008a7 <consoleintr+0xae>
8010086b:	e9 cf 00 00 00       	jmp    8010093f <consoleintr+0x146>
80100870:	83 f8 1a             	cmp    $0x1a,%eax
80100873:	74 3e                	je     801008b3 <consoleintr+0xba>
80100875:	83 f8 7f             	cmp    $0x7f,%eax
80100878:	0f 84 8c 00 00 00    	je     8010090a <consoleintr+0x111>
8010087e:	e9 bc 00 00 00       	jmp    8010093f <consoleintr+0x146>
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
80100883:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
8010088a:	e9 42 01 00 00       	jmp    801009d1 <consoleintr+0x1d8>
#ifdef CS333_P3P4
    case C('R'):
      dopids = 1;
8010088f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      break;
80100896:	e9 36 01 00 00       	jmp    801009d1 <consoleintr+0x1d8>
    case C('F'):
      dofree = 1;
8010089b:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
      break;
801008a2:	e9 2a 01 00 00       	jmp    801009d1 <consoleintr+0x1d8>
    case C('S'):
      dosleep = 1;
801008a7:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
      break;
801008ae:	e9 1e 01 00 00       	jmp    801009d1 <consoleintr+0x1d8>
    case C('Z'):
      dozombie = 1;
801008b3:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
      break;
801008ba:	e9 12 01 00 00       	jmp    801009d1 <consoleintr+0x1d8>
#endif
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801008bf:	a1 28 18 11 80       	mov    0x80111828,%eax
801008c4:	83 e8 01             	sub    $0x1,%eax
801008c7:	a3 28 18 11 80       	mov    %eax,0x80111828
        consputc(BACKSPACE);
801008cc:	83 ec 0c             	sub    $0xc,%esp
801008cf:	68 00 01 00 00       	push   $0x100
801008d4:	e8 b9 fe ff ff       	call   80100792 <consputc>
801008d9:	83 c4 10             	add    $0x10,%esp
    case C('Z'):
      dozombie = 1;
      break;
#endif
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801008dc:	8b 15 28 18 11 80    	mov    0x80111828,%edx
801008e2:	a1 24 18 11 80       	mov    0x80111824,%eax
801008e7:	39 c2                	cmp    %eax,%edx
801008e9:	0f 84 e2 00 00 00    	je     801009d1 <consoleintr+0x1d8>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008ef:	a1 28 18 11 80       	mov    0x80111828,%eax
801008f4:	83 e8 01             	sub    $0x1,%eax
801008f7:	83 e0 7f             	and    $0x7f,%eax
801008fa:	0f b6 80 a0 17 11 80 	movzbl -0x7feee860(%eax),%eax
    case C('Z'):
      dozombie = 1;
      break;
#endif
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100901:	3c 0a                	cmp    $0xa,%al
80100903:	75 ba                	jne    801008bf <consoleintr+0xc6>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100905:	e9 c7 00 00 00       	jmp    801009d1 <consoleintr+0x1d8>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
8010090a:	8b 15 28 18 11 80    	mov    0x80111828,%edx
80100910:	a1 24 18 11 80       	mov    0x80111824,%eax
80100915:	39 c2                	cmp    %eax,%edx
80100917:	0f 84 b4 00 00 00    	je     801009d1 <consoleintr+0x1d8>
        input.e--;
8010091d:	a1 28 18 11 80       	mov    0x80111828,%eax
80100922:	83 e8 01             	sub    $0x1,%eax
80100925:	a3 28 18 11 80       	mov    %eax,0x80111828
        consputc(BACKSPACE);
8010092a:	83 ec 0c             	sub    $0xc,%esp
8010092d:	68 00 01 00 00       	push   $0x100
80100932:	e8 5b fe ff ff       	call   80100792 <consputc>
80100937:	83 c4 10             	add    $0x10,%esp
      }
      break;
8010093a:	e9 92 00 00 00       	jmp    801009d1 <consoleintr+0x1d8>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010093f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100943:	0f 84 87 00 00 00    	je     801009d0 <consoleintr+0x1d7>
80100949:	8b 15 28 18 11 80    	mov    0x80111828,%edx
8010094f:	a1 20 18 11 80       	mov    0x80111820,%eax
80100954:	29 c2                	sub    %eax,%edx
80100956:	89 d0                	mov    %edx,%eax
80100958:	83 f8 7f             	cmp    $0x7f,%eax
8010095b:	77 73                	ja     801009d0 <consoleintr+0x1d7>
        c = (c == '\r') ? '\n' : c;
8010095d:	83 7d e0 0d          	cmpl   $0xd,-0x20(%ebp)
80100961:	74 05                	je     80100968 <consoleintr+0x16f>
80100963:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100966:	eb 05                	jmp    8010096d <consoleintr+0x174>
80100968:	b8 0a 00 00 00       	mov    $0xa,%eax
8010096d:	89 45 e0             	mov    %eax,-0x20(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
80100970:	a1 28 18 11 80       	mov    0x80111828,%eax
80100975:	8d 50 01             	lea    0x1(%eax),%edx
80100978:	89 15 28 18 11 80    	mov    %edx,0x80111828
8010097e:	83 e0 7f             	and    $0x7f,%eax
80100981:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100984:	88 90 a0 17 11 80    	mov    %dl,-0x7feee860(%eax)
        consputc(c);
8010098a:	83 ec 0c             	sub    $0xc,%esp
8010098d:	ff 75 e0             	pushl  -0x20(%ebp)
80100990:	e8 fd fd ff ff       	call   80100792 <consputc>
80100995:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100998:	83 7d e0 0a          	cmpl   $0xa,-0x20(%ebp)
8010099c:	74 18                	je     801009b6 <consoleintr+0x1bd>
8010099e:	83 7d e0 04          	cmpl   $0x4,-0x20(%ebp)
801009a2:	74 12                	je     801009b6 <consoleintr+0x1bd>
801009a4:	a1 28 18 11 80       	mov    0x80111828,%eax
801009a9:	8b 15 20 18 11 80    	mov    0x80111820,%edx
801009af:	83 ea 80             	sub    $0xffffff80,%edx
801009b2:	39 d0                	cmp    %edx,%eax
801009b4:	75 1a                	jne    801009d0 <consoleintr+0x1d7>
          input.w = input.e;
801009b6:	a1 28 18 11 80       	mov    0x80111828,%eax
801009bb:	a3 24 18 11 80       	mov    %eax,0x80111824
          wakeup(&input.r);
801009c0:	83 ec 0c             	sub    $0xc,%esp
801009c3:	68 20 18 11 80       	push   $0x80111820
801009c8:	e8 83 49 00 00       	call   80105350 <wakeup>
801009cd:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
801009d0:	90                   	nop
  int dosleep = 0;
  int dozombie = 0;
#endif

  acquire(&cons.lock);
  while((c = getc()) >= 0){
801009d1:	8b 45 08             	mov    0x8(%ebp),%eax
801009d4:	ff d0                	call   *%eax
801009d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
801009d9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801009dd:	0f 89 54 fe ff ff    	jns    80100837 <consoleintr+0x3e>
        }
      }
      break;
    }
  }
  release(&cons.lock);
801009e3:	83 ec 0c             	sub    $0xc,%esp
801009e6:	68 e0 c5 10 80       	push   $0x8010c5e0
801009eb:	e8 9a 53 00 00       	call   80105d8a <release>
801009f0:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009f7:	74 05                	je     801009fe <consoleintr+0x205>
    procdump();  // now call procdump() wo. cons.lock held
801009f9:	e8 46 4a 00 00       	call   80105444 <procdump>
  }
#ifdef CS333_P3P4
  if(dopids) {
801009fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100a02:	74 05                	je     80100a09 <consoleintr+0x210>
    piddump();
80100a04:	e8 76 50 00 00       	call   80105a7f <piddump>
  }
  if(dofree) {
80100a09:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100a0d:	74 05                	je     80100a14 <consoleintr+0x21b>
    freedump();
80100a0f:	e8 04 51 00 00       	call   80105b18 <freedump>
  }
  if(dosleep) {
80100a14:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100a18:	74 05                	je     80100a1f <consoleintr+0x226>
    sleepdump();
80100a1a:	e8 5c 51 00 00       	call   80105b7b <sleepdump>
  }
  if(dozombie) {
80100a1f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a23:	74 05                	je     80100a2a <consoleintr+0x231>
    zombiedump();
80100a25:	e8 ea 51 00 00       	call   80105c14 <zombiedump>
  }
#endif
}
80100a2a:	90                   	nop
80100a2b:	c9                   	leave  
80100a2c:	c3                   	ret    

80100a2d <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100a2d:	55                   	push   %ebp
80100a2e:	89 e5                	mov    %esp,%ebp
80100a30:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100a33:	83 ec 0c             	sub    $0xc,%esp
80100a36:	ff 75 08             	pushl  0x8(%ebp)
80100a39:	e8 28 11 00 00       	call   80101b66 <iunlock>
80100a3e:	83 c4 10             	add    $0x10,%esp
  target = n;
80100a41:	8b 45 10             	mov    0x10(%ebp),%eax
80100a44:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a47:	83 ec 0c             	sub    $0xc,%esp
80100a4a:	68 e0 c5 10 80       	push   $0x8010c5e0
80100a4f:	e8 cf 52 00 00       	call   80105d23 <acquire>
80100a54:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100a57:	e9 ac 00 00 00       	jmp    80100b08 <consoleread+0xdb>
    while(input.r == input.w){
      if(proc->killed){
80100a5c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100a62:	8b 40 24             	mov    0x24(%eax),%eax
80100a65:	85 c0                	test   %eax,%eax
80100a67:	74 28                	je     80100a91 <consoleread+0x64>
        release(&cons.lock);
80100a69:	83 ec 0c             	sub    $0xc,%esp
80100a6c:	68 e0 c5 10 80       	push   $0x8010c5e0
80100a71:	e8 14 53 00 00       	call   80105d8a <release>
80100a76:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a79:	83 ec 0c             	sub    $0xc,%esp
80100a7c:	ff 75 08             	pushl  0x8(%ebp)
80100a7f:	e8 84 0f 00 00       	call   80101a08 <ilock>
80100a84:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a8c:	e9 ab 00 00 00       	jmp    80100b3c <consoleread+0x10f>
      }
      sleep(&input.r, &cons.lock);
80100a91:	83 ec 08             	sub    $0x8,%esp
80100a94:	68 e0 c5 10 80       	push   $0x8010c5e0
80100a99:	68 20 18 11 80       	push   $0x80111820
80100a9e:	e8 66 47 00 00       	call   80105209 <sleep>
80100aa3:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100aa6:	8b 15 20 18 11 80    	mov    0x80111820,%edx
80100aac:	a1 24 18 11 80       	mov    0x80111824,%eax
80100ab1:	39 c2                	cmp    %eax,%edx
80100ab3:	74 a7                	je     80100a5c <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100ab5:	a1 20 18 11 80       	mov    0x80111820,%eax
80100aba:	8d 50 01             	lea    0x1(%eax),%edx
80100abd:	89 15 20 18 11 80    	mov    %edx,0x80111820
80100ac3:	83 e0 7f             	and    $0x7f,%eax
80100ac6:	0f b6 80 a0 17 11 80 	movzbl -0x7feee860(%eax),%eax
80100acd:	0f be c0             	movsbl %al,%eax
80100ad0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100ad3:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100ad7:	75 17                	jne    80100af0 <consoleread+0xc3>
      if(n < target){
80100ad9:	8b 45 10             	mov    0x10(%ebp),%eax
80100adc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100adf:	73 2f                	jae    80100b10 <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100ae1:	a1 20 18 11 80       	mov    0x80111820,%eax
80100ae6:	83 e8 01             	sub    $0x1,%eax
80100ae9:	a3 20 18 11 80       	mov    %eax,0x80111820
      }
      break;
80100aee:	eb 20                	jmp    80100b10 <consoleread+0xe3>
    }
    *dst++ = c;
80100af0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100af3:	8d 50 01             	lea    0x1(%eax),%edx
80100af6:	89 55 0c             	mov    %edx,0xc(%ebp)
80100af9:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100afc:	88 10                	mov    %dl,(%eax)
    --n;
80100afe:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100b02:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100b06:	74 0b                	je     80100b13 <consoleread+0xe6>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100b08:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100b0c:	7f 98                	jg     80100aa6 <consoleread+0x79>
80100b0e:	eb 04                	jmp    80100b14 <consoleread+0xe7>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100b10:	90                   	nop
80100b11:	eb 01                	jmp    80100b14 <consoleread+0xe7>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100b13:	90                   	nop
  }
  release(&cons.lock);
80100b14:	83 ec 0c             	sub    $0xc,%esp
80100b17:	68 e0 c5 10 80       	push   $0x8010c5e0
80100b1c:	e8 69 52 00 00       	call   80105d8a <release>
80100b21:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b24:	83 ec 0c             	sub    $0xc,%esp
80100b27:	ff 75 08             	pushl  0x8(%ebp)
80100b2a:	e8 d9 0e 00 00       	call   80101a08 <ilock>
80100b2f:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100b32:	8b 45 10             	mov    0x10(%ebp),%eax
80100b35:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b38:	29 c2                	sub    %eax,%edx
80100b3a:	89 d0                	mov    %edx,%eax
}
80100b3c:	c9                   	leave  
80100b3d:	c3                   	ret    

80100b3e <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100b3e:	55                   	push   %ebp
80100b3f:	89 e5                	mov    %esp,%ebp
80100b41:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100b44:	83 ec 0c             	sub    $0xc,%esp
80100b47:	ff 75 08             	pushl  0x8(%ebp)
80100b4a:	e8 17 10 00 00       	call   80101b66 <iunlock>
80100b4f:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100b52:	83 ec 0c             	sub    $0xc,%esp
80100b55:	68 e0 c5 10 80       	push   $0x8010c5e0
80100b5a:	e8 c4 51 00 00       	call   80105d23 <acquire>
80100b5f:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b62:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100b69:	eb 21                	jmp    80100b8c <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100b6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b6e:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b71:	01 d0                	add    %edx,%eax
80100b73:	0f b6 00             	movzbl (%eax),%eax
80100b76:	0f be c0             	movsbl %al,%eax
80100b79:	0f b6 c0             	movzbl %al,%eax
80100b7c:	83 ec 0c             	sub    $0xc,%esp
80100b7f:	50                   	push   %eax
80100b80:	e8 0d fc ff ff       	call   80100792 <consputc>
80100b85:	83 c4 10             	add    $0x10,%esp
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100b88:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b8f:	3b 45 10             	cmp    0x10(%ebp),%eax
80100b92:	7c d7                	jl     80100b6b <consolewrite+0x2d>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100b94:	83 ec 0c             	sub    $0xc,%esp
80100b97:	68 e0 c5 10 80       	push   $0x8010c5e0
80100b9c:	e8 e9 51 00 00       	call   80105d8a <release>
80100ba1:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ba4:	83 ec 0c             	sub    $0xc,%esp
80100ba7:	ff 75 08             	pushl  0x8(%ebp)
80100baa:	e8 59 0e 00 00       	call   80101a08 <ilock>
80100baf:	83 c4 10             	add    $0x10,%esp

  return n;
80100bb2:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100bb5:	c9                   	leave  
80100bb6:	c3                   	ret    

80100bb7 <consoleinit>:

void
consoleinit(void)
{
80100bb7:	55                   	push   %ebp
80100bb8:	89 e5                	mov    %esp,%ebp
80100bba:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100bbd:	83 ec 08             	sub    $0x8,%esp
80100bc0:	68 f6 93 10 80       	push   $0x801093f6
80100bc5:	68 e0 c5 10 80       	push   $0x8010c5e0
80100bca:	e8 32 51 00 00       	call   80105d01 <initlock>
80100bcf:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100bd2:	c7 05 ec 21 11 80 3e 	movl   $0x80100b3e,0x801121ec
80100bd9:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100bdc:	c7 05 e8 21 11 80 2d 	movl   $0x80100a2d,0x801121e8
80100be3:	0a 10 80 
  cons.locking = 1;
80100be6:	c7 05 14 c6 10 80 01 	movl   $0x1,0x8010c614
80100bed:	00 00 00 

  picenable(IRQ_KBD);
80100bf0:	83 ec 0c             	sub    $0xc,%esp
80100bf3:	6a 01                	push   $0x1
80100bf5:	e8 cf 33 00 00       	call   80103fc9 <picenable>
80100bfa:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100bfd:	83 ec 08             	sub    $0x8,%esp
80100c00:	6a 00                	push   $0x0
80100c02:	6a 01                	push   $0x1
80100c04:	e8 6f 1f 00 00       	call   80102b78 <ioapicenable>
80100c09:	83 c4 10             	add    $0x10,%esp
}
80100c0c:	90                   	nop
80100c0d:	c9                   	leave  
80100c0e:	c3                   	ret    

80100c0f <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100c0f:	55                   	push   %ebp
80100c10:	89 e5                	mov    %esp,%ebp
80100c12:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100c18:	e8 ce 29 00 00       	call   801035eb <begin_op>
  if((ip = namei(path)) == 0){
80100c1d:	83 ec 0c             	sub    $0xc,%esp
80100c20:	ff 75 08             	pushl  0x8(%ebp)
80100c23:	e8 9e 19 00 00       	call   801025c6 <namei>
80100c28:	83 c4 10             	add    $0x10,%esp
80100c2b:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c2e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c32:	75 0f                	jne    80100c43 <exec+0x34>
    end_op();
80100c34:	e8 3e 2a 00 00       	call   80103677 <end_op>
    return -1;
80100c39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c3e:	e9 ce 03 00 00       	jmp    80101011 <exec+0x402>
  }
  ilock(ip);
80100c43:	83 ec 0c             	sub    $0xc,%esp
80100c46:	ff 75 d8             	pushl  -0x28(%ebp)
80100c49:	e8 ba 0d 00 00       	call   80101a08 <ilock>
80100c4e:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100c51:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100c58:	6a 34                	push   $0x34
80100c5a:	6a 00                	push   $0x0
80100c5c:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100c62:	50                   	push   %eax
80100c63:	ff 75 d8             	pushl  -0x28(%ebp)
80100c66:	e8 0b 13 00 00       	call   80101f76 <readi>
80100c6b:	83 c4 10             	add    $0x10,%esp
80100c6e:	83 f8 33             	cmp    $0x33,%eax
80100c71:	0f 86 49 03 00 00    	jbe    80100fc0 <exec+0x3b1>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c77:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100c7d:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c82:	0f 85 3b 03 00 00    	jne    80100fc3 <exec+0x3b4>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c88:	e8 e9 7e 00 00       	call   80108b76 <setupkvm>
80100c8d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c90:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c94:	0f 84 2c 03 00 00    	je     80100fc6 <exec+0x3b7>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c9a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ca1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100ca8:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100cae:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cb1:	e9 ab 00 00 00       	jmp    80100d61 <exec+0x152>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100cb6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100cb9:	6a 20                	push   $0x20
80100cbb:	50                   	push   %eax
80100cbc:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100cc2:	50                   	push   %eax
80100cc3:	ff 75 d8             	pushl  -0x28(%ebp)
80100cc6:	e8 ab 12 00 00       	call   80101f76 <readi>
80100ccb:	83 c4 10             	add    $0x10,%esp
80100cce:	83 f8 20             	cmp    $0x20,%eax
80100cd1:	0f 85 f2 02 00 00    	jne    80100fc9 <exec+0x3ba>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100cd7:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100cdd:	83 f8 01             	cmp    $0x1,%eax
80100ce0:	75 71                	jne    80100d53 <exec+0x144>
      continue;
    if(ph.memsz < ph.filesz)
80100ce2:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100ce8:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cee:	39 c2                	cmp    %eax,%edx
80100cf0:	0f 82 d6 02 00 00    	jb     80100fcc <exec+0x3bd>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100cf6:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100cfc:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100d02:	01 d0                	add    %edx,%eax
80100d04:	83 ec 04             	sub    $0x4,%esp
80100d07:	50                   	push   %eax
80100d08:	ff 75 e0             	pushl  -0x20(%ebp)
80100d0b:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d0e:	e8 0a 82 00 00       	call   80108f1d <allocuvm>
80100d13:	83 c4 10             	add    $0x10,%esp
80100d16:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d19:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d1d:	0f 84 ac 02 00 00    	je     80100fcf <exec+0x3c0>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100d23:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100d29:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d2f:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100d35:	83 ec 0c             	sub    $0xc,%esp
80100d38:	52                   	push   %edx
80100d39:	50                   	push   %eax
80100d3a:	ff 75 d8             	pushl  -0x28(%ebp)
80100d3d:	51                   	push   %ecx
80100d3e:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d41:	e8 00 81 00 00       	call   80108e46 <loaduvm>
80100d46:	83 c4 20             	add    $0x20,%esp
80100d49:	85 c0                	test   %eax,%eax
80100d4b:	0f 88 81 02 00 00    	js     80100fd2 <exec+0x3c3>
80100d51:	eb 01                	jmp    80100d54 <exec+0x145>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100d53:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d54:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d58:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d5b:	83 c0 20             	add    $0x20,%eax
80100d5e:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d61:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100d68:	0f b7 c0             	movzwl %ax,%eax
80100d6b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100d6e:	0f 8f 42 ff ff ff    	jg     80100cb6 <exec+0xa7>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100d74:	83 ec 0c             	sub    $0xc,%esp
80100d77:	ff 75 d8             	pushl  -0x28(%ebp)
80100d7a:	e8 49 0f 00 00       	call   80101cc8 <iunlockput>
80100d7f:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d82:	e8 f0 28 00 00       	call   80103677 <end_op>
  ip = 0;
80100d87:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d91:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d96:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d9b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100da1:	05 00 20 00 00       	add    $0x2000,%eax
80100da6:	83 ec 04             	sub    $0x4,%esp
80100da9:	50                   	push   %eax
80100daa:	ff 75 e0             	pushl  -0x20(%ebp)
80100dad:	ff 75 d4             	pushl  -0x2c(%ebp)
80100db0:	e8 68 81 00 00       	call   80108f1d <allocuvm>
80100db5:	83 c4 10             	add    $0x10,%esp
80100db8:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100dbb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100dbf:	0f 84 10 02 00 00    	je     80100fd5 <exec+0x3c6>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100dc5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100dc8:	2d 00 20 00 00       	sub    $0x2000,%eax
80100dcd:	83 ec 08             	sub    $0x8,%esp
80100dd0:	50                   	push   %eax
80100dd1:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dd4:	e8 6a 83 00 00       	call   80109143 <clearpteu>
80100dd9:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100ddc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ddf:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100de2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100de9:	e9 96 00 00 00       	jmp    80100e84 <exec+0x275>
    if(argc >= MAXARG)
80100dee:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100df2:	0f 87 e0 01 00 00    	ja     80100fd8 <exec+0x3c9>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100df8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dfb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e02:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e05:	01 d0                	add    %edx,%eax
80100e07:	8b 00                	mov    (%eax),%eax
80100e09:	83 ec 0c             	sub    $0xc,%esp
80100e0c:	50                   	push   %eax
80100e0d:	e8 c1 53 00 00       	call   801061d3 <strlen>
80100e12:	83 c4 10             	add    $0x10,%esp
80100e15:	89 c2                	mov    %eax,%edx
80100e17:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e1a:	29 d0                	sub    %edx,%eax
80100e1c:	83 e8 01             	sub    $0x1,%eax
80100e1f:	83 e0 fc             	and    $0xfffffffc,%eax
80100e22:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e28:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e32:	01 d0                	add    %edx,%eax
80100e34:	8b 00                	mov    (%eax),%eax
80100e36:	83 ec 0c             	sub    $0xc,%esp
80100e39:	50                   	push   %eax
80100e3a:	e8 94 53 00 00       	call   801061d3 <strlen>
80100e3f:	83 c4 10             	add    $0x10,%esp
80100e42:	83 c0 01             	add    $0x1,%eax
80100e45:	89 c1                	mov    %eax,%ecx
80100e47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e4a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e51:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e54:	01 d0                	add    %edx,%eax
80100e56:	8b 00                	mov    (%eax),%eax
80100e58:	51                   	push   %ecx
80100e59:	50                   	push   %eax
80100e5a:	ff 75 dc             	pushl  -0x24(%ebp)
80100e5d:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e60:	e8 95 84 00 00       	call   801092fa <copyout>
80100e65:	83 c4 10             	add    $0x10,%esp
80100e68:	85 c0                	test   %eax,%eax
80100e6a:	0f 88 6b 01 00 00    	js     80100fdb <exec+0x3cc>
      goto bad;
    ustack[3+argc] = sp;
80100e70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e73:	8d 50 03             	lea    0x3(%eax),%edx
80100e76:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e79:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e80:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e87:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e91:	01 d0                	add    %edx,%eax
80100e93:	8b 00                	mov    (%eax),%eax
80100e95:	85 c0                	test   %eax,%eax
80100e97:	0f 85 51 ff ff ff    	jne    80100dee <exec+0x1df>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100e9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea0:	83 c0 03             	add    $0x3,%eax
80100ea3:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100eaa:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100eae:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100eb5:	ff ff ff 
  ustack[1] = argc;
80100eb8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ebb:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100ec1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ec4:	83 c0 01             	add    $0x1,%eax
80100ec7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ece:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ed1:	29 d0                	sub    %edx,%eax
80100ed3:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100ed9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100edc:	83 c0 04             	add    $0x4,%eax
80100edf:	c1 e0 02             	shl    $0x2,%eax
80100ee2:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100ee5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ee8:	83 c0 04             	add    $0x4,%eax
80100eeb:	c1 e0 02             	shl    $0x2,%eax
80100eee:	50                   	push   %eax
80100eef:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100ef5:	50                   	push   %eax
80100ef6:	ff 75 dc             	pushl  -0x24(%ebp)
80100ef9:	ff 75 d4             	pushl  -0x2c(%ebp)
80100efc:	e8 f9 83 00 00       	call   801092fa <copyout>
80100f01:	83 c4 10             	add    $0x10,%esp
80100f04:	85 c0                	test   %eax,%eax
80100f06:	0f 88 d2 00 00 00    	js     80100fde <exec+0x3cf>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f0c:	8b 45 08             	mov    0x8(%ebp),%eax
80100f0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f15:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f18:	eb 17                	jmp    80100f31 <exec+0x322>
    if(*s == '/')
80100f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f1d:	0f b6 00             	movzbl (%eax),%eax
80100f20:	3c 2f                	cmp    $0x2f,%al
80100f22:	75 09                	jne    80100f2d <exec+0x31e>
      last = s+1;
80100f24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f27:	83 c0 01             	add    $0x1,%eax
80100f2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f2d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f34:	0f b6 00             	movzbl (%eax),%eax
80100f37:	84 c0                	test   %al,%al
80100f39:	75 df                	jne    80100f1a <exec+0x30b>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100f3b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f41:	83 c0 6c             	add    $0x6c,%eax
80100f44:	83 ec 04             	sub    $0x4,%esp
80100f47:	6a 10                	push   $0x10
80100f49:	ff 75 f0             	pushl  -0x10(%ebp)
80100f4c:	50                   	push   %eax
80100f4d:	e8 37 52 00 00       	call   80106189 <safestrcpy>
80100f52:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100f55:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f5b:	8b 40 04             	mov    0x4(%eax),%eax
80100f5e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100f61:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f67:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f6a:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100f6d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f73:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f76:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100f78:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f7e:	8b 40 18             	mov    0x18(%eax),%eax
80100f81:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100f87:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100f8a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f90:	8b 40 18             	mov    0x18(%eax),%eax
80100f93:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f96:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100f99:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f9f:	83 ec 0c             	sub    $0xc,%esp
80100fa2:	50                   	push   %eax
80100fa3:	e8 b5 7c 00 00       	call   80108c5d <switchuvm>
80100fa8:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100fab:	83 ec 0c             	sub    $0xc,%esp
80100fae:	ff 75 d0             	pushl  -0x30(%ebp)
80100fb1:	e8 ed 80 00 00       	call   801090a3 <freevm>
80100fb6:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fb9:	b8 00 00 00 00       	mov    $0x0,%eax
80100fbe:	eb 51                	jmp    80101011 <exec+0x402>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100fc0:	90                   	nop
80100fc1:	eb 1c                	jmp    80100fdf <exec+0x3d0>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100fc3:	90                   	nop
80100fc4:	eb 19                	jmp    80100fdf <exec+0x3d0>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100fc6:	90                   	nop
80100fc7:	eb 16                	jmp    80100fdf <exec+0x3d0>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100fc9:	90                   	nop
80100fca:	eb 13                	jmp    80100fdf <exec+0x3d0>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100fcc:	90                   	nop
80100fcd:	eb 10                	jmp    80100fdf <exec+0x3d0>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100fcf:	90                   	nop
80100fd0:	eb 0d                	jmp    80100fdf <exec+0x3d0>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100fd2:	90                   	nop
80100fd3:	eb 0a                	jmp    80100fdf <exec+0x3d0>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80100fd5:	90                   	nop
80100fd6:	eb 07                	jmp    80100fdf <exec+0x3d0>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100fd8:	90                   	nop
80100fd9:	eb 04                	jmp    80100fdf <exec+0x3d0>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100fdb:	90                   	nop
80100fdc:	eb 01                	jmp    80100fdf <exec+0x3d0>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100fde:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100fdf:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100fe3:	74 0e                	je     80100ff3 <exec+0x3e4>
    freevm(pgdir);
80100fe5:	83 ec 0c             	sub    $0xc,%esp
80100fe8:	ff 75 d4             	pushl  -0x2c(%ebp)
80100feb:	e8 b3 80 00 00       	call   801090a3 <freevm>
80100ff0:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100ff3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100ff7:	74 13                	je     8010100c <exec+0x3fd>
    iunlockput(ip);
80100ff9:	83 ec 0c             	sub    $0xc,%esp
80100ffc:	ff 75 d8             	pushl  -0x28(%ebp)
80100fff:	e8 c4 0c 00 00       	call   80101cc8 <iunlockput>
80101004:	83 c4 10             	add    $0x10,%esp
    end_op();
80101007:	e8 6b 26 00 00       	call   80103677 <end_op>
  }
  return -1;
8010100c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101011:	c9                   	leave  
80101012:	c3                   	ret    

80101013 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101013:	55                   	push   %ebp
80101014:	89 e5                	mov    %esp,%ebp
80101016:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80101019:	83 ec 08             	sub    $0x8,%esp
8010101c:	68 fe 93 10 80       	push   $0x801093fe
80101021:	68 40 18 11 80       	push   $0x80111840
80101026:	e8 d6 4c 00 00       	call   80105d01 <initlock>
8010102b:	83 c4 10             	add    $0x10,%esp
}
8010102e:	90                   	nop
8010102f:	c9                   	leave  
80101030:	c3                   	ret    

80101031 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101031:	55                   	push   %ebp
80101032:	89 e5                	mov    %esp,%ebp
80101034:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80101037:	83 ec 0c             	sub    $0xc,%esp
8010103a:	68 40 18 11 80       	push   $0x80111840
8010103f:	e8 df 4c 00 00       	call   80105d23 <acquire>
80101044:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101047:	c7 45 f4 74 18 11 80 	movl   $0x80111874,-0xc(%ebp)
8010104e:	eb 2d                	jmp    8010107d <filealloc+0x4c>
    if(f->ref == 0){
80101050:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101053:	8b 40 04             	mov    0x4(%eax),%eax
80101056:	85 c0                	test   %eax,%eax
80101058:	75 1f                	jne    80101079 <filealloc+0x48>
      f->ref = 1;
8010105a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010105d:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101064:	83 ec 0c             	sub    $0xc,%esp
80101067:	68 40 18 11 80       	push   $0x80111840
8010106c:	e8 19 4d 00 00       	call   80105d8a <release>
80101071:	83 c4 10             	add    $0x10,%esp
      return f;
80101074:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101077:	eb 23                	jmp    8010109c <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101079:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
8010107d:	b8 d4 21 11 80       	mov    $0x801121d4,%eax
80101082:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101085:	72 c9                	jb     80101050 <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80101087:	83 ec 0c             	sub    $0xc,%esp
8010108a:	68 40 18 11 80       	push   $0x80111840
8010108f:	e8 f6 4c 00 00       	call   80105d8a <release>
80101094:	83 c4 10             	add    $0x10,%esp
  return 0;
80101097:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010109c:	c9                   	leave  
8010109d:	c3                   	ret    

8010109e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010109e:	55                   	push   %ebp
8010109f:	89 e5                	mov    %esp,%ebp
801010a1:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
801010a4:	83 ec 0c             	sub    $0xc,%esp
801010a7:	68 40 18 11 80       	push   $0x80111840
801010ac:	e8 72 4c 00 00       	call   80105d23 <acquire>
801010b1:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b4:	8b 45 08             	mov    0x8(%ebp),%eax
801010b7:	8b 40 04             	mov    0x4(%eax),%eax
801010ba:	85 c0                	test   %eax,%eax
801010bc:	7f 0d                	jg     801010cb <filedup+0x2d>
    panic("filedup");
801010be:	83 ec 0c             	sub    $0xc,%esp
801010c1:	68 05 94 10 80       	push   $0x80109405
801010c6:	e8 9b f4 ff ff       	call   80100566 <panic>
  f->ref++;
801010cb:	8b 45 08             	mov    0x8(%ebp),%eax
801010ce:	8b 40 04             	mov    0x4(%eax),%eax
801010d1:	8d 50 01             	lea    0x1(%eax),%edx
801010d4:	8b 45 08             	mov    0x8(%ebp),%eax
801010d7:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010da:	83 ec 0c             	sub    $0xc,%esp
801010dd:	68 40 18 11 80       	push   $0x80111840
801010e2:	e8 a3 4c 00 00       	call   80105d8a <release>
801010e7:	83 c4 10             	add    $0x10,%esp
  return f;
801010ea:	8b 45 08             	mov    0x8(%ebp),%eax
}
801010ed:	c9                   	leave  
801010ee:	c3                   	ret    

801010ef <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801010ef:	55                   	push   %ebp
801010f0:	89 e5                	mov    %esp,%ebp
801010f2:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010f5:	83 ec 0c             	sub    $0xc,%esp
801010f8:	68 40 18 11 80       	push   $0x80111840
801010fd:	e8 21 4c 00 00       	call   80105d23 <acquire>
80101102:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101105:	8b 45 08             	mov    0x8(%ebp),%eax
80101108:	8b 40 04             	mov    0x4(%eax),%eax
8010110b:	85 c0                	test   %eax,%eax
8010110d:	7f 0d                	jg     8010111c <fileclose+0x2d>
    panic("fileclose");
8010110f:	83 ec 0c             	sub    $0xc,%esp
80101112:	68 0d 94 10 80       	push   $0x8010940d
80101117:	e8 4a f4 ff ff       	call   80100566 <panic>
  if(--f->ref > 0){
8010111c:	8b 45 08             	mov    0x8(%ebp),%eax
8010111f:	8b 40 04             	mov    0x4(%eax),%eax
80101122:	8d 50 ff             	lea    -0x1(%eax),%edx
80101125:	8b 45 08             	mov    0x8(%ebp),%eax
80101128:	89 50 04             	mov    %edx,0x4(%eax)
8010112b:	8b 45 08             	mov    0x8(%ebp),%eax
8010112e:	8b 40 04             	mov    0x4(%eax),%eax
80101131:	85 c0                	test   %eax,%eax
80101133:	7e 15                	jle    8010114a <fileclose+0x5b>
    release(&ftable.lock);
80101135:	83 ec 0c             	sub    $0xc,%esp
80101138:	68 40 18 11 80       	push   $0x80111840
8010113d:	e8 48 4c 00 00       	call   80105d8a <release>
80101142:	83 c4 10             	add    $0x10,%esp
80101145:	e9 8b 00 00 00       	jmp    801011d5 <fileclose+0xe6>
    return;
  }
  ff = *f;
8010114a:	8b 45 08             	mov    0x8(%ebp),%eax
8010114d:	8b 10                	mov    (%eax),%edx
8010114f:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101152:	8b 50 04             	mov    0x4(%eax),%edx
80101155:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101158:	8b 50 08             	mov    0x8(%eax),%edx
8010115b:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010115e:	8b 50 0c             	mov    0xc(%eax),%edx
80101161:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101164:	8b 50 10             	mov    0x10(%eax),%edx
80101167:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010116a:	8b 40 14             	mov    0x14(%eax),%eax
8010116d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101170:	8b 45 08             	mov    0x8(%ebp),%eax
80101173:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010117a:	8b 45 08             	mov    0x8(%ebp),%eax
8010117d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101183:	83 ec 0c             	sub    $0xc,%esp
80101186:	68 40 18 11 80       	push   $0x80111840
8010118b:	e8 fa 4b 00 00       	call   80105d8a <release>
80101190:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
80101193:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101196:	83 f8 01             	cmp    $0x1,%eax
80101199:	75 19                	jne    801011b4 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
8010119b:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010119f:	0f be d0             	movsbl %al,%edx
801011a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801011a5:	83 ec 08             	sub    $0x8,%esp
801011a8:	52                   	push   %edx
801011a9:	50                   	push   %eax
801011aa:	e8 83 30 00 00       	call   80104232 <pipeclose>
801011af:	83 c4 10             	add    $0x10,%esp
801011b2:	eb 21                	jmp    801011d5 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
801011b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011b7:	83 f8 02             	cmp    $0x2,%eax
801011ba:	75 19                	jne    801011d5 <fileclose+0xe6>
    begin_op();
801011bc:	e8 2a 24 00 00       	call   801035eb <begin_op>
    iput(ff.ip);
801011c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011c4:	83 ec 0c             	sub    $0xc,%esp
801011c7:	50                   	push   %eax
801011c8:	e8 0b 0a 00 00       	call   80101bd8 <iput>
801011cd:	83 c4 10             	add    $0x10,%esp
    end_op();
801011d0:	e8 a2 24 00 00       	call   80103677 <end_op>
  }
}
801011d5:	c9                   	leave  
801011d6:	c3                   	ret    

801011d7 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801011d7:	55                   	push   %ebp
801011d8:	89 e5                	mov    %esp,%ebp
801011da:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801011dd:	8b 45 08             	mov    0x8(%ebp),%eax
801011e0:	8b 00                	mov    (%eax),%eax
801011e2:	83 f8 02             	cmp    $0x2,%eax
801011e5:	75 40                	jne    80101227 <filestat+0x50>
    ilock(f->ip);
801011e7:	8b 45 08             	mov    0x8(%ebp),%eax
801011ea:	8b 40 10             	mov    0x10(%eax),%eax
801011ed:	83 ec 0c             	sub    $0xc,%esp
801011f0:	50                   	push   %eax
801011f1:	e8 12 08 00 00       	call   80101a08 <ilock>
801011f6:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011f9:	8b 45 08             	mov    0x8(%ebp),%eax
801011fc:	8b 40 10             	mov    0x10(%eax),%eax
801011ff:	83 ec 08             	sub    $0x8,%esp
80101202:	ff 75 0c             	pushl  0xc(%ebp)
80101205:	50                   	push   %eax
80101206:	e8 25 0d 00 00       	call   80101f30 <stati>
8010120b:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
8010120e:	8b 45 08             	mov    0x8(%ebp),%eax
80101211:	8b 40 10             	mov    0x10(%eax),%eax
80101214:	83 ec 0c             	sub    $0xc,%esp
80101217:	50                   	push   %eax
80101218:	e8 49 09 00 00       	call   80101b66 <iunlock>
8010121d:	83 c4 10             	add    $0x10,%esp
    return 0;
80101220:	b8 00 00 00 00       	mov    $0x0,%eax
80101225:	eb 05                	jmp    8010122c <filestat+0x55>
  }
  return -1;
80101227:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010122c:	c9                   	leave  
8010122d:	c3                   	ret    

8010122e <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010122e:	55                   	push   %ebp
8010122f:	89 e5                	mov    %esp,%ebp
80101231:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101234:	8b 45 08             	mov    0x8(%ebp),%eax
80101237:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010123b:	84 c0                	test   %al,%al
8010123d:	75 0a                	jne    80101249 <fileread+0x1b>
    return -1;
8010123f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101244:	e9 9b 00 00 00       	jmp    801012e4 <fileread+0xb6>
  if(f->type == FD_PIPE)
80101249:	8b 45 08             	mov    0x8(%ebp),%eax
8010124c:	8b 00                	mov    (%eax),%eax
8010124e:	83 f8 01             	cmp    $0x1,%eax
80101251:	75 1a                	jne    8010126d <fileread+0x3f>
    return piperead(f->pipe, addr, n);
80101253:	8b 45 08             	mov    0x8(%ebp),%eax
80101256:	8b 40 0c             	mov    0xc(%eax),%eax
80101259:	83 ec 04             	sub    $0x4,%esp
8010125c:	ff 75 10             	pushl  0x10(%ebp)
8010125f:	ff 75 0c             	pushl  0xc(%ebp)
80101262:	50                   	push   %eax
80101263:	e8 72 31 00 00       	call   801043da <piperead>
80101268:	83 c4 10             	add    $0x10,%esp
8010126b:	eb 77                	jmp    801012e4 <fileread+0xb6>
  if(f->type == FD_INODE){
8010126d:	8b 45 08             	mov    0x8(%ebp),%eax
80101270:	8b 00                	mov    (%eax),%eax
80101272:	83 f8 02             	cmp    $0x2,%eax
80101275:	75 60                	jne    801012d7 <fileread+0xa9>
    ilock(f->ip);
80101277:	8b 45 08             	mov    0x8(%ebp),%eax
8010127a:	8b 40 10             	mov    0x10(%eax),%eax
8010127d:	83 ec 0c             	sub    $0xc,%esp
80101280:	50                   	push   %eax
80101281:	e8 82 07 00 00       	call   80101a08 <ilock>
80101286:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101289:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010128c:	8b 45 08             	mov    0x8(%ebp),%eax
8010128f:	8b 50 14             	mov    0x14(%eax),%edx
80101292:	8b 45 08             	mov    0x8(%ebp),%eax
80101295:	8b 40 10             	mov    0x10(%eax),%eax
80101298:	51                   	push   %ecx
80101299:	52                   	push   %edx
8010129a:	ff 75 0c             	pushl  0xc(%ebp)
8010129d:	50                   	push   %eax
8010129e:	e8 d3 0c 00 00       	call   80101f76 <readi>
801012a3:	83 c4 10             	add    $0x10,%esp
801012a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801012a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801012ad:	7e 11                	jle    801012c0 <fileread+0x92>
      f->off += r;
801012af:	8b 45 08             	mov    0x8(%ebp),%eax
801012b2:	8b 50 14             	mov    0x14(%eax),%edx
801012b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012b8:	01 c2                	add    %eax,%edx
801012ba:	8b 45 08             	mov    0x8(%ebp),%eax
801012bd:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801012c0:	8b 45 08             	mov    0x8(%ebp),%eax
801012c3:	8b 40 10             	mov    0x10(%eax),%eax
801012c6:	83 ec 0c             	sub    $0xc,%esp
801012c9:	50                   	push   %eax
801012ca:	e8 97 08 00 00       	call   80101b66 <iunlock>
801012cf:	83 c4 10             	add    $0x10,%esp
    return r;
801012d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012d5:	eb 0d                	jmp    801012e4 <fileread+0xb6>
  }
  panic("fileread");
801012d7:	83 ec 0c             	sub    $0xc,%esp
801012da:	68 17 94 10 80       	push   $0x80109417
801012df:	e8 82 f2 ff ff       	call   80100566 <panic>
}
801012e4:	c9                   	leave  
801012e5:	c3                   	ret    

801012e6 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801012e6:	55                   	push   %ebp
801012e7:	89 e5                	mov    %esp,%ebp
801012e9:	53                   	push   %ebx
801012ea:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801012ed:	8b 45 08             	mov    0x8(%ebp),%eax
801012f0:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012f4:	84 c0                	test   %al,%al
801012f6:	75 0a                	jne    80101302 <filewrite+0x1c>
    return -1;
801012f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012fd:	e9 1b 01 00 00       	jmp    8010141d <filewrite+0x137>
  if(f->type == FD_PIPE)
80101302:	8b 45 08             	mov    0x8(%ebp),%eax
80101305:	8b 00                	mov    (%eax),%eax
80101307:	83 f8 01             	cmp    $0x1,%eax
8010130a:	75 1d                	jne    80101329 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
8010130c:	8b 45 08             	mov    0x8(%ebp),%eax
8010130f:	8b 40 0c             	mov    0xc(%eax),%eax
80101312:	83 ec 04             	sub    $0x4,%esp
80101315:	ff 75 10             	pushl  0x10(%ebp)
80101318:	ff 75 0c             	pushl  0xc(%ebp)
8010131b:	50                   	push   %eax
8010131c:	e8 bb 2f 00 00       	call   801042dc <pipewrite>
80101321:	83 c4 10             	add    $0x10,%esp
80101324:	e9 f4 00 00 00       	jmp    8010141d <filewrite+0x137>
  if(f->type == FD_INODE){
80101329:	8b 45 08             	mov    0x8(%ebp),%eax
8010132c:	8b 00                	mov    (%eax),%eax
8010132e:	83 f8 02             	cmp    $0x2,%eax
80101331:	0f 85 d9 00 00 00    	jne    80101410 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101337:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
8010133e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101345:	e9 a3 00 00 00       	jmp    801013ed <filewrite+0x107>
      int n1 = n - i;
8010134a:	8b 45 10             	mov    0x10(%ebp),%eax
8010134d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101350:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101353:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101356:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101359:	7e 06                	jle    80101361 <filewrite+0x7b>
        n1 = max;
8010135b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010135e:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101361:	e8 85 22 00 00       	call   801035eb <begin_op>
      ilock(f->ip);
80101366:	8b 45 08             	mov    0x8(%ebp),%eax
80101369:	8b 40 10             	mov    0x10(%eax),%eax
8010136c:	83 ec 0c             	sub    $0xc,%esp
8010136f:	50                   	push   %eax
80101370:	e8 93 06 00 00       	call   80101a08 <ilock>
80101375:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101378:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010137b:	8b 45 08             	mov    0x8(%ebp),%eax
8010137e:	8b 50 14             	mov    0x14(%eax),%edx
80101381:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101384:	8b 45 0c             	mov    0xc(%ebp),%eax
80101387:	01 c3                	add    %eax,%ebx
80101389:	8b 45 08             	mov    0x8(%ebp),%eax
8010138c:	8b 40 10             	mov    0x10(%eax),%eax
8010138f:	51                   	push   %ecx
80101390:	52                   	push   %edx
80101391:	53                   	push   %ebx
80101392:	50                   	push   %eax
80101393:	e8 35 0d 00 00       	call   801020cd <writei>
80101398:	83 c4 10             	add    $0x10,%esp
8010139b:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010139e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013a2:	7e 11                	jle    801013b5 <filewrite+0xcf>
        f->off += r;
801013a4:	8b 45 08             	mov    0x8(%ebp),%eax
801013a7:	8b 50 14             	mov    0x14(%eax),%edx
801013aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013ad:	01 c2                	add    %eax,%edx
801013af:	8b 45 08             	mov    0x8(%ebp),%eax
801013b2:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801013b5:	8b 45 08             	mov    0x8(%ebp),%eax
801013b8:	8b 40 10             	mov    0x10(%eax),%eax
801013bb:	83 ec 0c             	sub    $0xc,%esp
801013be:	50                   	push   %eax
801013bf:	e8 a2 07 00 00       	call   80101b66 <iunlock>
801013c4:	83 c4 10             	add    $0x10,%esp
      end_op();
801013c7:	e8 ab 22 00 00       	call   80103677 <end_op>

      if(r < 0)
801013cc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013d0:	78 29                	js     801013fb <filewrite+0x115>
        break;
      if(r != n1)
801013d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013d5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801013d8:	74 0d                	je     801013e7 <filewrite+0x101>
        panic("short filewrite");
801013da:	83 ec 0c             	sub    $0xc,%esp
801013dd:	68 20 94 10 80       	push   $0x80109420
801013e2:	e8 7f f1 ff ff       	call   80100566 <panic>
      i += r;
801013e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013ea:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801013ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013f0:	3b 45 10             	cmp    0x10(%ebp),%eax
801013f3:	0f 8c 51 ff ff ff    	jl     8010134a <filewrite+0x64>
801013f9:	eb 01                	jmp    801013fc <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
801013fb:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801013fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ff:	3b 45 10             	cmp    0x10(%ebp),%eax
80101402:	75 05                	jne    80101409 <filewrite+0x123>
80101404:	8b 45 10             	mov    0x10(%ebp),%eax
80101407:	eb 14                	jmp    8010141d <filewrite+0x137>
80101409:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010140e:	eb 0d                	jmp    8010141d <filewrite+0x137>
  }
  panic("filewrite");
80101410:	83 ec 0c             	sub    $0xc,%esp
80101413:	68 30 94 10 80       	push   $0x80109430
80101418:	e8 49 f1 ff ff       	call   80100566 <panic>
}
8010141d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101420:	c9                   	leave  
80101421:	c3                   	ret    

80101422 <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101422:	55                   	push   %ebp
80101423:	89 e5                	mov    %esp,%ebp
80101425:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
80101428:	8b 45 08             	mov    0x8(%ebp),%eax
8010142b:	83 ec 08             	sub    $0x8,%esp
8010142e:	6a 01                	push   $0x1
80101430:	50                   	push   %eax
80101431:	e8 80 ed ff ff       	call   801001b6 <bread>
80101436:	83 c4 10             	add    $0x10,%esp
80101439:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010143c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010143f:	83 c0 18             	add    $0x18,%eax
80101442:	83 ec 04             	sub    $0x4,%esp
80101445:	6a 1c                	push   $0x1c
80101447:	50                   	push   %eax
80101448:	ff 75 0c             	pushl  0xc(%ebp)
8010144b:	e8 f5 4b 00 00       	call   80106045 <memmove>
80101450:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101453:	83 ec 0c             	sub    $0xc,%esp
80101456:	ff 75 f4             	pushl  -0xc(%ebp)
80101459:	e8 d0 ed ff ff       	call   8010022e <brelse>
8010145e:	83 c4 10             	add    $0x10,%esp
}
80101461:	90                   	nop
80101462:	c9                   	leave  
80101463:	c3                   	ret    

80101464 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101464:	55                   	push   %ebp
80101465:	89 e5                	mov    %esp,%ebp
80101467:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
8010146a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010146d:	8b 45 08             	mov    0x8(%ebp),%eax
80101470:	83 ec 08             	sub    $0x8,%esp
80101473:	52                   	push   %edx
80101474:	50                   	push   %eax
80101475:	e8 3c ed ff ff       	call   801001b6 <bread>
8010147a:	83 c4 10             	add    $0x10,%esp
8010147d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101480:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101483:	83 c0 18             	add    $0x18,%eax
80101486:	83 ec 04             	sub    $0x4,%esp
80101489:	68 00 02 00 00       	push   $0x200
8010148e:	6a 00                	push   $0x0
80101490:	50                   	push   %eax
80101491:	e8 f0 4a 00 00       	call   80105f86 <memset>
80101496:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101499:	83 ec 0c             	sub    $0xc,%esp
8010149c:	ff 75 f4             	pushl  -0xc(%ebp)
8010149f:	e8 7f 23 00 00       	call   80103823 <log_write>
801014a4:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801014a7:	83 ec 0c             	sub    $0xc,%esp
801014aa:	ff 75 f4             	pushl  -0xc(%ebp)
801014ad:	e8 7c ed ff ff       	call   8010022e <brelse>
801014b2:	83 c4 10             	add    $0x10,%esp
}
801014b5:	90                   	nop
801014b6:	c9                   	leave  
801014b7:	c3                   	ret    

801014b8 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801014b8:	55                   	push   %ebp
801014b9:	89 e5                	mov    %esp,%ebp
801014bb:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801014be:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801014c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801014cc:	e9 13 01 00 00       	jmp    801015e4 <balloc+0x12c>
    bp = bread(dev, BBLOCK(b, sb));
801014d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014d4:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801014da:	85 c0                	test   %eax,%eax
801014dc:	0f 48 c2             	cmovs  %edx,%eax
801014df:	c1 f8 0c             	sar    $0xc,%eax
801014e2:	89 c2                	mov    %eax,%edx
801014e4:	a1 58 22 11 80       	mov    0x80112258,%eax
801014e9:	01 d0                	add    %edx,%eax
801014eb:	83 ec 08             	sub    $0x8,%esp
801014ee:	50                   	push   %eax
801014ef:	ff 75 08             	pushl  0x8(%ebp)
801014f2:	e8 bf ec ff ff       	call   801001b6 <bread>
801014f7:	83 c4 10             	add    $0x10,%esp
801014fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014fd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101504:	e9 a6 00 00 00       	jmp    801015af <balloc+0xf7>
      m = 1 << (bi % 8);
80101509:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010150c:	99                   	cltd   
8010150d:	c1 ea 1d             	shr    $0x1d,%edx
80101510:	01 d0                	add    %edx,%eax
80101512:	83 e0 07             	and    $0x7,%eax
80101515:	29 d0                	sub    %edx,%eax
80101517:	ba 01 00 00 00       	mov    $0x1,%edx
8010151c:	89 c1                	mov    %eax,%ecx
8010151e:	d3 e2                	shl    %cl,%edx
80101520:	89 d0                	mov    %edx,%eax
80101522:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101525:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101528:	8d 50 07             	lea    0x7(%eax),%edx
8010152b:	85 c0                	test   %eax,%eax
8010152d:	0f 48 c2             	cmovs  %edx,%eax
80101530:	c1 f8 03             	sar    $0x3,%eax
80101533:	89 c2                	mov    %eax,%edx
80101535:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101538:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
8010153d:	0f b6 c0             	movzbl %al,%eax
80101540:	23 45 e8             	and    -0x18(%ebp),%eax
80101543:	85 c0                	test   %eax,%eax
80101545:	75 64                	jne    801015ab <balloc+0xf3>
        bp->data[bi/8] |= m;  // Mark block in use.
80101547:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010154a:	8d 50 07             	lea    0x7(%eax),%edx
8010154d:	85 c0                	test   %eax,%eax
8010154f:	0f 48 c2             	cmovs  %edx,%eax
80101552:	c1 f8 03             	sar    $0x3,%eax
80101555:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101558:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010155d:	89 d1                	mov    %edx,%ecx
8010155f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101562:	09 ca                	or     %ecx,%edx
80101564:	89 d1                	mov    %edx,%ecx
80101566:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101569:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
8010156d:	83 ec 0c             	sub    $0xc,%esp
80101570:	ff 75 ec             	pushl  -0x14(%ebp)
80101573:	e8 ab 22 00 00       	call   80103823 <log_write>
80101578:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
8010157b:	83 ec 0c             	sub    $0xc,%esp
8010157e:	ff 75 ec             	pushl  -0x14(%ebp)
80101581:	e8 a8 ec ff ff       	call   8010022e <brelse>
80101586:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101589:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010158c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010158f:	01 c2                	add    %eax,%edx
80101591:	8b 45 08             	mov    0x8(%ebp),%eax
80101594:	83 ec 08             	sub    $0x8,%esp
80101597:	52                   	push   %edx
80101598:	50                   	push   %eax
80101599:	e8 c6 fe ff ff       	call   80101464 <bzero>
8010159e:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801015a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015a7:	01 d0                	add    %edx,%eax
801015a9:	eb 57                	jmp    80101602 <balloc+0x14a>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015ab:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801015af:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801015b6:	7f 17                	jg     801015cf <balloc+0x117>
801015b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015be:	01 d0                	add    %edx,%eax
801015c0:	89 c2                	mov    %eax,%edx
801015c2:	a1 40 22 11 80       	mov    0x80112240,%eax
801015c7:	39 c2                	cmp    %eax,%edx
801015c9:	0f 82 3a ff ff ff    	jb     80101509 <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801015cf:	83 ec 0c             	sub    $0xc,%esp
801015d2:	ff 75 ec             	pushl  -0x14(%ebp)
801015d5:	e8 54 ec ff ff       	call   8010022e <brelse>
801015da:	83 c4 10             	add    $0x10,%esp
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
801015dd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801015e4:	8b 15 40 22 11 80    	mov    0x80112240,%edx
801015ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015ed:	39 c2                	cmp    %eax,%edx
801015ef:	0f 87 dc fe ff ff    	ja     801014d1 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801015f5:	83 ec 0c             	sub    $0xc,%esp
801015f8:	68 3c 94 10 80       	push   $0x8010943c
801015fd:	e8 64 ef ff ff       	call   80100566 <panic>
}
80101602:	c9                   	leave  
80101603:	c3                   	ret    

80101604 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101604:	55                   	push   %ebp
80101605:	89 e5                	mov    %esp,%ebp
80101607:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
8010160a:	83 ec 08             	sub    $0x8,%esp
8010160d:	68 40 22 11 80       	push   $0x80112240
80101612:	ff 75 08             	pushl  0x8(%ebp)
80101615:	e8 08 fe ff ff       	call   80101422 <readsb>
8010161a:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
8010161d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101620:	c1 e8 0c             	shr    $0xc,%eax
80101623:	89 c2                	mov    %eax,%edx
80101625:	a1 58 22 11 80       	mov    0x80112258,%eax
8010162a:	01 c2                	add    %eax,%edx
8010162c:	8b 45 08             	mov    0x8(%ebp),%eax
8010162f:	83 ec 08             	sub    $0x8,%esp
80101632:	52                   	push   %edx
80101633:	50                   	push   %eax
80101634:	e8 7d eb ff ff       	call   801001b6 <bread>
80101639:	83 c4 10             	add    $0x10,%esp
8010163c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
8010163f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101642:	25 ff 0f 00 00       	and    $0xfff,%eax
80101647:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010164a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010164d:	99                   	cltd   
8010164e:	c1 ea 1d             	shr    $0x1d,%edx
80101651:	01 d0                	add    %edx,%eax
80101653:	83 e0 07             	and    $0x7,%eax
80101656:	29 d0                	sub    %edx,%eax
80101658:	ba 01 00 00 00       	mov    $0x1,%edx
8010165d:	89 c1                	mov    %eax,%ecx
8010165f:	d3 e2                	shl    %cl,%edx
80101661:	89 d0                	mov    %edx,%eax
80101663:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101666:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101669:	8d 50 07             	lea    0x7(%eax),%edx
8010166c:	85 c0                	test   %eax,%eax
8010166e:	0f 48 c2             	cmovs  %edx,%eax
80101671:	c1 f8 03             	sar    $0x3,%eax
80101674:	89 c2                	mov    %eax,%edx
80101676:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101679:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
8010167e:	0f b6 c0             	movzbl %al,%eax
80101681:	23 45 ec             	and    -0x14(%ebp),%eax
80101684:	85 c0                	test   %eax,%eax
80101686:	75 0d                	jne    80101695 <bfree+0x91>
    panic("freeing free block");
80101688:	83 ec 0c             	sub    $0xc,%esp
8010168b:	68 52 94 10 80       	push   $0x80109452
80101690:	e8 d1 ee ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
80101695:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101698:	8d 50 07             	lea    0x7(%eax),%edx
8010169b:	85 c0                	test   %eax,%eax
8010169d:	0f 48 c2             	cmovs  %edx,%eax
801016a0:	c1 f8 03             	sar    $0x3,%eax
801016a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016a6:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801016ab:	89 d1                	mov    %edx,%ecx
801016ad:	8b 55 ec             	mov    -0x14(%ebp),%edx
801016b0:	f7 d2                	not    %edx
801016b2:	21 ca                	and    %ecx,%edx
801016b4:	89 d1                	mov    %edx,%ecx
801016b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016b9:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
801016bd:	83 ec 0c             	sub    $0xc,%esp
801016c0:	ff 75 f4             	pushl  -0xc(%ebp)
801016c3:	e8 5b 21 00 00       	call   80103823 <log_write>
801016c8:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801016cb:	83 ec 0c             	sub    $0xc,%esp
801016ce:	ff 75 f4             	pushl  -0xc(%ebp)
801016d1:	e8 58 eb ff ff       	call   8010022e <brelse>
801016d6:	83 c4 10             	add    $0x10,%esp
}
801016d9:	90                   	nop
801016da:	c9                   	leave  
801016db:	c3                   	ret    

801016dc <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801016dc:	55                   	push   %ebp
801016dd:	89 e5                	mov    %esp,%ebp
801016df:	57                   	push   %edi
801016e0:	56                   	push   %esi
801016e1:	53                   	push   %ebx
801016e2:	83 ec 1c             	sub    $0x1c,%esp
  initlock(&icache.lock, "icache");
801016e5:	83 ec 08             	sub    $0x8,%esp
801016e8:	68 65 94 10 80       	push   $0x80109465
801016ed:	68 60 22 11 80       	push   $0x80112260
801016f2:	e8 0a 46 00 00       	call   80105d01 <initlock>
801016f7:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
801016fa:	83 ec 08             	sub    $0x8,%esp
801016fd:	68 40 22 11 80       	push   $0x80112240
80101702:	ff 75 08             	pushl  0x8(%ebp)
80101705:	e8 18 fd ff ff       	call   80101422 <readsb>
8010170a:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
8010170d:	a1 58 22 11 80       	mov    0x80112258,%eax
80101712:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101715:	8b 3d 54 22 11 80    	mov    0x80112254,%edi
8010171b:	8b 35 50 22 11 80    	mov    0x80112250,%esi
80101721:	8b 1d 4c 22 11 80    	mov    0x8011224c,%ebx
80101727:	8b 0d 48 22 11 80    	mov    0x80112248,%ecx
8010172d:	8b 15 44 22 11 80    	mov    0x80112244,%edx
80101733:	a1 40 22 11 80       	mov    0x80112240,%eax
80101738:	ff 75 e4             	pushl  -0x1c(%ebp)
8010173b:	57                   	push   %edi
8010173c:	56                   	push   %esi
8010173d:	53                   	push   %ebx
8010173e:	51                   	push   %ecx
8010173f:	52                   	push   %edx
80101740:	50                   	push   %eax
80101741:	68 6c 94 10 80       	push   $0x8010946c
80101746:	e8 7b ec ff ff       	call   801003c6 <cprintf>
8010174b:	83 c4 20             	add    $0x20,%esp
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
8010174e:	90                   	nop
8010174f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101752:	5b                   	pop    %ebx
80101753:	5e                   	pop    %esi
80101754:	5f                   	pop    %edi
80101755:	5d                   	pop    %ebp
80101756:	c3                   	ret    

80101757 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101757:	55                   	push   %ebp
80101758:	89 e5                	mov    %esp,%ebp
8010175a:	83 ec 28             	sub    $0x28,%esp
8010175d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101760:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101764:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010176b:	e9 9e 00 00 00       	jmp    8010180e <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
80101770:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101773:	c1 e8 03             	shr    $0x3,%eax
80101776:	89 c2                	mov    %eax,%edx
80101778:	a1 54 22 11 80       	mov    0x80112254,%eax
8010177d:	01 d0                	add    %edx,%eax
8010177f:	83 ec 08             	sub    $0x8,%esp
80101782:	50                   	push   %eax
80101783:	ff 75 08             	pushl  0x8(%ebp)
80101786:	e8 2b ea ff ff       	call   801001b6 <bread>
8010178b:	83 c4 10             	add    $0x10,%esp
8010178e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101791:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101794:	8d 50 18             	lea    0x18(%eax),%edx
80101797:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010179a:	83 e0 07             	and    $0x7,%eax
8010179d:	c1 e0 06             	shl    $0x6,%eax
801017a0:	01 d0                	add    %edx,%eax
801017a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801017a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017a8:	0f b7 00             	movzwl (%eax),%eax
801017ab:	66 85 c0             	test   %ax,%ax
801017ae:	75 4c                	jne    801017fc <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
801017b0:	83 ec 04             	sub    $0x4,%esp
801017b3:	6a 40                	push   $0x40
801017b5:	6a 00                	push   $0x0
801017b7:	ff 75 ec             	pushl  -0x14(%ebp)
801017ba:	e8 c7 47 00 00       	call   80105f86 <memset>
801017bf:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017c5:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017c9:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017cc:	83 ec 0c             	sub    $0xc,%esp
801017cf:	ff 75 f0             	pushl  -0x10(%ebp)
801017d2:	e8 4c 20 00 00       	call   80103823 <log_write>
801017d7:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017da:	83 ec 0c             	sub    $0xc,%esp
801017dd:	ff 75 f0             	pushl  -0x10(%ebp)
801017e0:	e8 49 ea ff ff       	call   8010022e <brelse>
801017e5:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017eb:	83 ec 08             	sub    $0x8,%esp
801017ee:	50                   	push   %eax
801017ef:	ff 75 08             	pushl  0x8(%ebp)
801017f2:	e8 f8 00 00 00       	call   801018ef <iget>
801017f7:	83 c4 10             	add    $0x10,%esp
801017fa:	eb 30                	jmp    8010182c <ialloc+0xd5>
    }
    brelse(bp);
801017fc:	83 ec 0c             	sub    $0xc,%esp
801017ff:	ff 75 f0             	pushl  -0x10(%ebp)
80101802:	e8 27 ea ff ff       	call   8010022e <brelse>
80101807:	83 c4 10             	add    $0x10,%esp
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010180a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010180e:	8b 15 48 22 11 80    	mov    0x80112248,%edx
80101814:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101817:	39 c2                	cmp    %eax,%edx
80101819:	0f 87 51 ff ff ff    	ja     80101770 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
8010181f:	83 ec 0c             	sub    $0xc,%esp
80101822:	68 bf 94 10 80       	push   $0x801094bf
80101827:	e8 3a ed ff ff       	call   80100566 <panic>
}
8010182c:	c9                   	leave  
8010182d:	c3                   	ret    

8010182e <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
8010182e:	55                   	push   %ebp
8010182f:	89 e5                	mov    %esp,%ebp
80101831:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101834:	8b 45 08             	mov    0x8(%ebp),%eax
80101837:	8b 40 04             	mov    0x4(%eax),%eax
8010183a:	c1 e8 03             	shr    $0x3,%eax
8010183d:	89 c2                	mov    %eax,%edx
8010183f:	a1 54 22 11 80       	mov    0x80112254,%eax
80101844:	01 c2                	add    %eax,%edx
80101846:	8b 45 08             	mov    0x8(%ebp),%eax
80101849:	8b 00                	mov    (%eax),%eax
8010184b:	83 ec 08             	sub    $0x8,%esp
8010184e:	52                   	push   %edx
8010184f:	50                   	push   %eax
80101850:	e8 61 e9 ff ff       	call   801001b6 <bread>
80101855:	83 c4 10             	add    $0x10,%esp
80101858:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010185b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010185e:	8d 50 18             	lea    0x18(%eax),%edx
80101861:	8b 45 08             	mov    0x8(%ebp),%eax
80101864:	8b 40 04             	mov    0x4(%eax),%eax
80101867:	83 e0 07             	and    $0x7,%eax
8010186a:	c1 e0 06             	shl    $0x6,%eax
8010186d:	01 d0                	add    %edx,%eax
8010186f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101872:	8b 45 08             	mov    0x8(%ebp),%eax
80101875:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101879:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010187c:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010187f:	8b 45 08             	mov    0x8(%ebp),%eax
80101882:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101886:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101889:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010188d:	8b 45 08             	mov    0x8(%ebp),%eax
80101890:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101894:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101897:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010189b:	8b 45 08             	mov    0x8(%ebp),%eax
8010189e:	0f b7 50 16          	movzwl 0x16(%eax),%edx
801018a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018a5:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801018a9:	8b 45 08             	mov    0x8(%ebp),%eax
801018ac:	8b 50 18             	mov    0x18(%eax),%edx
801018af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018b2:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801018b5:	8b 45 08             	mov    0x8(%ebp),%eax
801018b8:	8d 50 1c             	lea    0x1c(%eax),%edx
801018bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018be:	83 c0 0c             	add    $0xc,%eax
801018c1:	83 ec 04             	sub    $0x4,%esp
801018c4:	6a 34                	push   $0x34
801018c6:	52                   	push   %edx
801018c7:	50                   	push   %eax
801018c8:	e8 78 47 00 00       	call   80106045 <memmove>
801018cd:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018d0:	83 ec 0c             	sub    $0xc,%esp
801018d3:	ff 75 f4             	pushl  -0xc(%ebp)
801018d6:	e8 48 1f 00 00       	call   80103823 <log_write>
801018db:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018de:	83 ec 0c             	sub    $0xc,%esp
801018e1:	ff 75 f4             	pushl  -0xc(%ebp)
801018e4:	e8 45 e9 ff ff       	call   8010022e <brelse>
801018e9:	83 c4 10             	add    $0x10,%esp
}
801018ec:	90                   	nop
801018ed:	c9                   	leave  
801018ee:	c3                   	ret    

801018ef <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018ef:	55                   	push   %ebp
801018f0:	89 e5                	mov    %esp,%ebp
801018f2:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018f5:	83 ec 0c             	sub    $0xc,%esp
801018f8:	68 60 22 11 80       	push   $0x80112260
801018fd:	e8 21 44 00 00       	call   80105d23 <acquire>
80101902:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101905:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010190c:	c7 45 f4 94 22 11 80 	movl   $0x80112294,-0xc(%ebp)
80101913:	eb 5d                	jmp    80101972 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101915:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101918:	8b 40 08             	mov    0x8(%eax),%eax
8010191b:	85 c0                	test   %eax,%eax
8010191d:	7e 39                	jle    80101958 <iget+0x69>
8010191f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101922:	8b 00                	mov    (%eax),%eax
80101924:	3b 45 08             	cmp    0x8(%ebp),%eax
80101927:	75 2f                	jne    80101958 <iget+0x69>
80101929:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010192c:	8b 40 04             	mov    0x4(%eax),%eax
8010192f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101932:	75 24                	jne    80101958 <iget+0x69>
      ip->ref++;
80101934:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101937:	8b 40 08             	mov    0x8(%eax),%eax
8010193a:	8d 50 01             	lea    0x1(%eax),%edx
8010193d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101940:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101943:	83 ec 0c             	sub    $0xc,%esp
80101946:	68 60 22 11 80       	push   $0x80112260
8010194b:	e8 3a 44 00 00       	call   80105d8a <release>
80101950:	83 c4 10             	add    $0x10,%esp
      return ip;
80101953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101956:	eb 74                	jmp    801019cc <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101958:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010195c:	75 10                	jne    8010196e <iget+0x7f>
8010195e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101961:	8b 40 08             	mov    0x8(%eax),%eax
80101964:	85 c0                	test   %eax,%eax
80101966:	75 06                	jne    8010196e <iget+0x7f>
      empty = ip;
80101968:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010196b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010196e:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101972:	81 7d f4 34 32 11 80 	cmpl   $0x80113234,-0xc(%ebp)
80101979:	72 9a                	jb     80101915 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010197b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010197f:	75 0d                	jne    8010198e <iget+0x9f>
    panic("iget: no inodes");
80101981:	83 ec 0c             	sub    $0xc,%esp
80101984:	68 d1 94 10 80       	push   $0x801094d1
80101989:	e8 d8 eb ff ff       	call   80100566 <panic>

  ip = empty;
8010198e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101991:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101994:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101997:	8b 55 08             	mov    0x8(%ebp),%edx
8010199a:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010199c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010199f:	8b 55 0c             	mov    0xc(%ebp),%edx
801019a2:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801019a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
801019af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019b2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
801019b9:	83 ec 0c             	sub    $0xc,%esp
801019bc:	68 60 22 11 80       	push   $0x80112260
801019c1:	e8 c4 43 00 00       	call   80105d8a <release>
801019c6:	83 c4 10             	add    $0x10,%esp

  return ip;
801019c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019cc:	c9                   	leave  
801019cd:	c3                   	ret    

801019ce <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019ce:	55                   	push   %ebp
801019cf:	89 e5                	mov    %esp,%ebp
801019d1:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019d4:	83 ec 0c             	sub    $0xc,%esp
801019d7:	68 60 22 11 80       	push   $0x80112260
801019dc:	e8 42 43 00 00       	call   80105d23 <acquire>
801019e1:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019e4:	8b 45 08             	mov    0x8(%ebp),%eax
801019e7:	8b 40 08             	mov    0x8(%eax),%eax
801019ea:	8d 50 01             	lea    0x1(%eax),%edx
801019ed:	8b 45 08             	mov    0x8(%ebp),%eax
801019f0:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019f3:	83 ec 0c             	sub    $0xc,%esp
801019f6:	68 60 22 11 80       	push   $0x80112260
801019fb:	e8 8a 43 00 00       	call   80105d8a <release>
80101a00:	83 c4 10             	add    $0x10,%esp
  return ip;
80101a03:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101a06:	c9                   	leave  
80101a07:	c3                   	ret    

80101a08 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101a08:	55                   	push   %ebp
80101a09:	89 e5                	mov    %esp,%ebp
80101a0b:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101a0e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a12:	74 0a                	je     80101a1e <ilock+0x16>
80101a14:	8b 45 08             	mov    0x8(%ebp),%eax
80101a17:	8b 40 08             	mov    0x8(%eax),%eax
80101a1a:	85 c0                	test   %eax,%eax
80101a1c:	7f 0d                	jg     80101a2b <ilock+0x23>
    panic("ilock");
80101a1e:	83 ec 0c             	sub    $0xc,%esp
80101a21:	68 e1 94 10 80       	push   $0x801094e1
80101a26:	e8 3b eb ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101a2b:	83 ec 0c             	sub    $0xc,%esp
80101a2e:	68 60 22 11 80       	push   $0x80112260
80101a33:	e8 eb 42 00 00       	call   80105d23 <acquire>
80101a38:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
80101a3b:	eb 13                	jmp    80101a50 <ilock+0x48>
    sleep(ip, &icache.lock);
80101a3d:	83 ec 08             	sub    $0x8,%esp
80101a40:	68 60 22 11 80       	push   $0x80112260
80101a45:	ff 75 08             	pushl  0x8(%ebp)
80101a48:	e8 bc 37 00 00       	call   80105209 <sleep>
80101a4d:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101a50:	8b 45 08             	mov    0x8(%ebp),%eax
80101a53:	8b 40 0c             	mov    0xc(%eax),%eax
80101a56:	83 e0 01             	and    $0x1,%eax
80101a59:	85 c0                	test   %eax,%eax
80101a5b:	75 e0                	jne    80101a3d <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101a5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a60:	8b 40 0c             	mov    0xc(%eax),%eax
80101a63:	83 c8 01             	or     $0x1,%eax
80101a66:	89 c2                	mov    %eax,%edx
80101a68:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6b:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101a6e:	83 ec 0c             	sub    $0xc,%esp
80101a71:	68 60 22 11 80       	push   $0x80112260
80101a76:	e8 0f 43 00 00       	call   80105d8a <release>
80101a7b:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
80101a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a81:	8b 40 0c             	mov    0xc(%eax),%eax
80101a84:	83 e0 02             	and    $0x2,%eax
80101a87:	85 c0                	test   %eax,%eax
80101a89:	0f 85 d4 00 00 00    	jne    80101b63 <ilock+0x15b>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a8f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a92:	8b 40 04             	mov    0x4(%eax),%eax
80101a95:	c1 e8 03             	shr    $0x3,%eax
80101a98:	89 c2                	mov    %eax,%edx
80101a9a:	a1 54 22 11 80       	mov    0x80112254,%eax
80101a9f:	01 c2                	add    %eax,%edx
80101aa1:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa4:	8b 00                	mov    (%eax),%eax
80101aa6:	83 ec 08             	sub    $0x8,%esp
80101aa9:	52                   	push   %edx
80101aaa:	50                   	push   %eax
80101aab:	e8 06 e7 ff ff       	call   801001b6 <bread>
80101ab0:	83 c4 10             	add    $0x10,%esp
80101ab3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ab9:	8d 50 18             	lea    0x18(%eax),%edx
80101abc:	8b 45 08             	mov    0x8(%ebp),%eax
80101abf:	8b 40 04             	mov    0x4(%eax),%eax
80101ac2:	83 e0 07             	and    $0x7,%eax
80101ac5:	c1 e0 06             	shl    $0x6,%eax
80101ac8:	01 d0                	add    %edx,%eax
80101aca:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101acd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ad0:	0f b7 10             	movzwl (%eax),%edx
80101ad3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad6:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101ada:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101add:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101ae1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae4:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101ae8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aeb:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101aef:	8b 45 08             	mov    0x8(%ebp),%eax
80101af2:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101af6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101af9:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101afd:	8b 45 08             	mov    0x8(%ebp),%eax
80101b00:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101b04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b07:	8b 50 08             	mov    0x8(%eax),%edx
80101b0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0d:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b13:	8d 50 0c             	lea    0xc(%eax),%edx
80101b16:	8b 45 08             	mov    0x8(%ebp),%eax
80101b19:	83 c0 1c             	add    $0x1c,%eax
80101b1c:	83 ec 04             	sub    $0x4,%esp
80101b1f:	6a 34                	push   $0x34
80101b21:	52                   	push   %edx
80101b22:	50                   	push   %eax
80101b23:	e8 1d 45 00 00       	call   80106045 <memmove>
80101b28:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101b2b:	83 ec 0c             	sub    $0xc,%esp
80101b2e:	ff 75 f4             	pushl  -0xc(%ebp)
80101b31:	e8 f8 e6 ff ff       	call   8010022e <brelse>
80101b36:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101b39:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3c:	8b 40 0c             	mov    0xc(%eax),%eax
80101b3f:	83 c8 02             	or     $0x2,%eax
80101b42:	89 c2                	mov    %eax,%edx
80101b44:	8b 45 08             	mov    0x8(%ebp),%eax
80101b47:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101b4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101b51:	66 85 c0             	test   %ax,%ax
80101b54:	75 0d                	jne    80101b63 <ilock+0x15b>
      panic("ilock: no type");
80101b56:	83 ec 0c             	sub    $0xc,%esp
80101b59:	68 e7 94 10 80       	push   $0x801094e7
80101b5e:	e8 03 ea ff ff       	call   80100566 <panic>
  }
}
80101b63:	90                   	nop
80101b64:	c9                   	leave  
80101b65:	c3                   	ret    

80101b66 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b66:	55                   	push   %ebp
80101b67:	89 e5                	mov    %esp,%ebp
80101b69:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101b6c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b70:	74 17                	je     80101b89 <iunlock+0x23>
80101b72:	8b 45 08             	mov    0x8(%ebp),%eax
80101b75:	8b 40 0c             	mov    0xc(%eax),%eax
80101b78:	83 e0 01             	and    $0x1,%eax
80101b7b:	85 c0                	test   %eax,%eax
80101b7d:	74 0a                	je     80101b89 <iunlock+0x23>
80101b7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b82:	8b 40 08             	mov    0x8(%eax),%eax
80101b85:	85 c0                	test   %eax,%eax
80101b87:	7f 0d                	jg     80101b96 <iunlock+0x30>
    panic("iunlock");
80101b89:	83 ec 0c             	sub    $0xc,%esp
80101b8c:	68 f6 94 10 80       	push   $0x801094f6
80101b91:	e8 d0 e9 ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101b96:	83 ec 0c             	sub    $0xc,%esp
80101b99:	68 60 22 11 80       	push   $0x80112260
80101b9e:	e8 80 41 00 00       	call   80105d23 <acquire>
80101ba3:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101ba6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba9:	8b 40 0c             	mov    0xc(%eax),%eax
80101bac:	83 e0 fe             	and    $0xfffffffe,%eax
80101baf:	89 c2                	mov    %eax,%edx
80101bb1:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb4:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101bb7:	83 ec 0c             	sub    $0xc,%esp
80101bba:	ff 75 08             	pushl  0x8(%ebp)
80101bbd:	e8 8e 37 00 00       	call   80105350 <wakeup>
80101bc2:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101bc5:	83 ec 0c             	sub    $0xc,%esp
80101bc8:	68 60 22 11 80       	push   $0x80112260
80101bcd:	e8 b8 41 00 00       	call   80105d8a <release>
80101bd2:	83 c4 10             	add    $0x10,%esp
}
80101bd5:	90                   	nop
80101bd6:	c9                   	leave  
80101bd7:	c3                   	ret    

80101bd8 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101bd8:	55                   	push   %ebp
80101bd9:	89 e5                	mov    %esp,%ebp
80101bdb:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101bde:	83 ec 0c             	sub    $0xc,%esp
80101be1:	68 60 22 11 80       	push   $0x80112260
80101be6:	e8 38 41 00 00       	call   80105d23 <acquire>
80101beb:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101bee:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf1:	8b 40 08             	mov    0x8(%eax),%eax
80101bf4:	83 f8 01             	cmp    $0x1,%eax
80101bf7:	0f 85 a9 00 00 00    	jne    80101ca6 <iput+0xce>
80101bfd:	8b 45 08             	mov    0x8(%ebp),%eax
80101c00:	8b 40 0c             	mov    0xc(%eax),%eax
80101c03:	83 e0 02             	and    $0x2,%eax
80101c06:	85 c0                	test   %eax,%eax
80101c08:	0f 84 98 00 00 00    	je     80101ca6 <iput+0xce>
80101c0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c11:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101c15:	66 85 c0             	test   %ax,%ax
80101c18:	0f 85 88 00 00 00    	jne    80101ca6 <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101c1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c21:	8b 40 0c             	mov    0xc(%eax),%eax
80101c24:	83 e0 01             	and    $0x1,%eax
80101c27:	85 c0                	test   %eax,%eax
80101c29:	74 0d                	je     80101c38 <iput+0x60>
      panic("iput busy");
80101c2b:	83 ec 0c             	sub    $0xc,%esp
80101c2e:	68 fe 94 10 80       	push   $0x801094fe
80101c33:	e8 2e e9 ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101c38:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3b:	8b 40 0c             	mov    0xc(%eax),%eax
80101c3e:	83 c8 01             	or     $0x1,%eax
80101c41:	89 c2                	mov    %eax,%edx
80101c43:	8b 45 08             	mov    0x8(%ebp),%eax
80101c46:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101c49:	83 ec 0c             	sub    $0xc,%esp
80101c4c:	68 60 22 11 80       	push   $0x80112260
80101c51:	e8 34 41 00 00       	call   80105d8a <release>
80101c56:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101c59:	83 ec 0c             	sub    $0xc,%esp
80101c5c:	ff 75 08             	pushl  0x8(%ebp)
80101c5f:	e8 a8 01 00 00       	call   80101e0c <itrunc>
80101c64:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101c67:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6a:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101c70:	83 ec 0c             	sub    $0xc,%esp
80101c73:	ff 75 08             	pushl  0x8(%ebp)
80101c76:	e8 b3 fb ff ff       	call   8010182e <iupdate>
80101c7b:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101c7e:	83 ec 0c             	sub    $0xc,%esp
80101c81:	68 60 22 11 80       	push   $0x80112260
80101c86:	e8 98 40 00 00       	call   80105d23 <acquire>
80101c8b:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101c8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c91:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101c98:	83 ec 0c             	sub    $0xc,%esp
80101c9b:	ff 75 08             	pushl  0x8(%ebp)
80101c9e:	e8 ad 36 00 00       	call   80105350 <wakeup>
80101ca3:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101ca6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca9:	8b 40 08             	mov    0x8(%eax),%eax
80101cac:	8d 50 ff             	lea    -0x1(%eax),%edx
80101caf:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb2:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101cb5:	83 ec 0c             	sub    $0xc,%esp
80101cb8:	68 60 22 11 80       	push   $0x80112260
80101cbd:	e8 c8 40 00 00       	call   80105d8a <release>
80101cc2:	83 c4 10             	add    $0x10,%esp
}
80101cc5:	90                   	nop
80101cc6:	c9                   	leave  
80101cc7:	c3                   	ret    

80101cc8 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101cc8:	55                   	push   %ebp
80101cc9:	89 e5                	mov    %esp,%ebp
80101ccb:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101cce:	83 ec 0c             	sub    $0xc,%esp
80101cd1:	ff 75 08             	pushl  0x8(%ebp)
80101cd4:	e8 8d fe ff ff       	call   80101b66 <iunlock>
80101cd9:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101cdc:	83 ec 0c             	sub    $0xc,%esp
80101cdf:	ff 75 08             	pushl  0x8(%ebp)
80101ce2:	e8 f1 fe ff ff       	call   80101bd8 <iput>
80101ce7:	83 c4 10             	add    $0x10,%esp
}
80101cea:	90                   	nop
80101ceb:	c9                   	leave  
80101cec:	c3                   	ret    

80101ced <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101ced:	55                   	push   %ebp
80101cee:	89 e5                	mov    %esp,%ebp
80101cf0:	53                   	push   %ebx
80101cf1:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101cf4:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101cf8:	77 42                	ja     80101d3c <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101cfa:	8b 45 08             	mov    0x8(%ebp),%eax
80101cfd:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d00:	83 c2 04             	add    $0x4,%edx
80101d03:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d07:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d0a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d0e:	75 24                	jne    80101d34 <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d10:	8b 45 08             	mov    0x8(%ebp),%eax
80101d13:	8b 00                	mov    (%eax),%eax
80101d15:	83 ec 0c             	sub    $0xc,%esp
80101d18:	50                   	push   %eax
80101d19:	e8 9a f7 ff ff       	call   801014b8 <balloc>
80101d1e:	83 c4 10             	add    $0x10,%esp
80101d21:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d24:	8b 45 08             	mov    0x8(%ebp),%eax
80101d27:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d2a:	8d 4a 04             	lea    0x4(%edx),%ecx
80101d2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d30:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d37:	e9 cb 00 00 00       	jmp    80101e07 <bmap+0x11a>
  }
  bn -= NDIRECT;
80101d3c:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d40:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d44:	0f 87 b0 00 00 00    	ja     80101dfa <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d4d:	8b 40 4c             	mov    0x4c(%eax),%eax
80101d50:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d53:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d57:	75 1d                	jne    80101d76 <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101d59:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5c:	8b 00                	mov    (%eax),%eax
80101d5e:	83 ec 0c             	sub    $0xc,%esp
80101d61:	50                   	push   %eax
80101d62:	e8 51 f7 ff ff       	call   801014b8 <balloc>
80101d67:	83 c4 10             	add    $0x10,%esp
80101d6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d70:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d73:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101d76:	8b 45 08             	mov    0x8(%ebp),%eax
80101d79:	8b 00                	mov    (%eax),%eax
80101d7b:	83 ec 08             	sub    $0x8,%esp
80101d7e:	ff 75 f4             	pushl  -0xc(%ebp)
80101d81:	50                   	push   %eax
80101d82:	e8 2f e4 ff ff       	call   801001b6 <bread>
80101d87:	83 c4 10             	add    $0x10,%esp
80101d8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d90:	83 c0 18             	add    $0x18,%eax
80101d93:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d96:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d99:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101da0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101da3:	01 d0                	add    %edx,%eax
80101da5:	8b 00                	mov    (%eax),%eax
80101da7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101daa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101dae:	75 37                	jne    80101de7 <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80101db0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101db3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101dba:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dbd:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101dc0:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc3:	8b 00                	mov    (%eax),%eax
80101dc5:	83 ec 0c             	sub    $0xc,%esp
80101dc8:	50                   	push   %eax
80101dc9:	e8 ea f6 ff ff       	call   801014b8 <balloc>
80101dce:	83 c4 10             	add    $0x10,%esp
80101dd1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dd7:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101dd9:	83 ec 0c             	sub    $0xc,%esp
80101ddc:	ff 75 f0             	pushl  -0x10(%ebp)
80101ddf:	e8 3f 1a 00 00       	call   80103823 <log_write>
80101de4:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101de7:	83 ec 0c             	sub    $0xc,%esp
80101dea:	ff 75 f0             	pushl  -0x10(%ebp)
80101ded:	e8 3c e4 ff ff       	call   8010022e <brelse>
80101df2:	83 c4 10             	add    $0x10,%esp
    return addr;
80101df5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101df8:	eb 0d                	jmp    80101e07 <bmap+0x11a>
  }

  panic("bmap: out of range");
80101dfa:	83 ec 0c             	sub    $0xc,%esp
80101dfd:	68 08 95 10 80       	push   $0x80109508
80101e02:	e8 5f e7 ff ff       	call   80100566 <panic>
}
80101e07:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101e0a:	c9                   	leave  
80101e0b:	c3                   	ret    

80101e0c <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101e0c:	55                   	push   %ebp
80101e0d:	89 e5                	mov    %esp,%ebp
80101e0f:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e12:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e19:	eb 45                	jmp    80101e60 <itrunc+0x54>
    if(ip->addrs[i]){
80101e1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e21:	83 c2 04             	add    $0x4,%edx
80101e24:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e28:	85 c0                	test   %eax,%eax
80101e2a:	74 30                	je     80101e5c <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101e2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e32:	83 c2 04             	add    $0x4,%edx
80101e35:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e39:	8b 55 08             	mov    0x8(%ebp),%edx
80101e3c:	8b 12                	mov    (%edx),%edx
80101e3e:	83 ec 08             	sub    $0x8,%esp
80101e41:	50                   	push   %eax
80101e42:	52                   	push   %edx
80101e43:	e8 bc f7 ff ff       	call   80101604 <bfree>
80101e48:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101e4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e4e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e51:	83 c2 04             	add    $0x4,%edx
80101e54:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101e5b:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e5c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101e60:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101e64:	7e b5                	jle    80101e1b <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101e66:	8b 45 08             	mov    0x8(%ebp),%eax
80101e69:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e6c:	85 c0                	test   %eax,%eax
80101e6e:	0f 84 a1 00 00 00    	je     80101f15 <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101e74:	8b 45 08             	mov    0x8(%ebp),%eax
80101e77:	8b 50 4c             	mov    0x4c(%eax),%edx
80101e7a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7d:	8b 00                	mov    (%eax),%eax
80101e7f:	83 ec 08             	sub    $0x8,%esp
80101e82:	52                   	push   %edx
80101e83:	50                   	push   %eax
80101e84:	e8 2d e3 ff ff       	call   801001b6 <bread>
80101e89:	83 c4 10             	add    $0x10,%esp
80101e8c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e92:	83 c0 18             	add    $0x18,%eax
80101e95:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e98:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e9f:	eb 3c                	jmp    80101edd <itrunc+0xd1>
      if(a[j])
80101ea1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ea4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101eab:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101eae:	01 d0                	add    %edx,%eax
80101eb0:	8b 00                	mov    (%eax),%eax
80101eb2:	85 c0                	test   %eax,%eax
80101eb4:	74 23                	je     80101ed9 <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101eb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101eb9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ec0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ec3:	01 d0                	add    %edx,%eax
80101ec5:	8b 00                	mov    (%eax),%eax
80101ec7:	8b 55 08             	mov    0x8(%ebp),%edx
80101eca:	8b 12                	mov    (%edx),%edx
80101ecc:	83 ec 08             	sub    $0x8,%esp
80101ecf:	50                   	push   %eax
80101ed0:	52                   	push   %edx
80101ed1:	e8 2e f7 ff ff       	call   80101604 <bfree>
80101ed6:	83 c4 10             	add    $0x10,%esp
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101ed9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101edd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ee0:	83 f8 7f             	cmp    $0x7f,%eax
80101ee3:	76 bc                	jbe    80101ea1 <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101ee5:	83 ec 0c             	sub    $0xc,%esp
80101ee8:	ff 75 ec             	pushl  -0x14(%ebp)
80101eeb:	e8 3e e3 ff ff       	call   8010022e <brelse>
80101ef0:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101ef3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef6:	8b 40 4c             	mov    0x4c(%eax),%eax
80101ef9:	8b 55 08             	mov    0x8(%ebp),%edx
80101efc:	8b 12                	mov    (%edx),%edx
80101efe:	83 ec 08             	sub    $0x8,%esp
80101f01:	50                   	push   %eax
80101f02:	52                   	push   %edx
80101f03:	e8 fc f6 ff ff       	call   80101604 <bfree>
80101f08:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101f0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0e:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101f15:	8b 45 08             	mov    0x8(%ebp),%eax
80101f18:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101f1f:	83 ec 0c             	sub    $0xc,%esp
80101f22:	ff 75 08             	pushl  0x8(%ebp)
80101f25:	e8 04 f9 ff ff       	call   8010182e <iupdate>
80101f2a:	83 c4 10             	add    $0x10,%esp
}
80101f2d:	90                   	nop
80101f2e:	c9                   	leave  
80101f2f:	c3                   	ret    

80101f30 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101f30:	55                   	push   %ebp
80101f31:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f33:	8b 45 08             	mov    0x8(%ebp),%eax
80101f36:	8b 00                	mov    (%eax),%eax
80101f38:	89 c2                	mov    %eax,%edx
80101f3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f3d:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f40:	8b 45 08             	mov    0x8(%ebp),%eax
80101f43:	8b 50 04             	mov    0x4(%eax),%edx
80101f46:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f49:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4f:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101f53:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f56:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101f59:	8b 45 08             	mov    0x8(%ebp),%eax
80101f5c:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101f60:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f63:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101f67:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6a:	8b 50 18             	mov    0x18(%eax),%edx
80101f6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f70:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f73:	90                   	nop
80101f74:	5d                   	pop    %ebp
80101f75:	c3                   	ret    

80101f76 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101f76:	55                   	push   %ebp
80101f77:	89 e5                	mov    %esp,%ebp
80101f79:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101f83:	66 83 f8 03          	cmp    $0x3,%ax
80101f87:	75 5c                	jne    80101fe5 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f89:	8b 45 08             	mov    0x8(%ebp),%eax
80101f8c:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f90:	66 85 c0             	test   %ax,%ax
80101f93:	78 20                	js     80101fb5 <readi+0x3f>
80101f95:	8b 45 08             	mov    0x8(%ebp),%eax
80101f98:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f9c:	66 83 f8 09          	cmp    $0x9,%ax
80101fa0:	7f 13                	jg     80101fb5 <readi+0x3f>
80101fa2:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa5:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fa9:	98                   	cwtl   
80101faa:	8b 04 c5 e0 21 11 80 	mov    -0x7feede20(,%eax,8),%eax
80101fb1:	85 c0                	test   %eax,%eax
80101fb3:	75 0a                	jne    80101fbf <readi+0x49>
      return -1;
80101fb5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fba:	e9 0c 01 00 00       	jmp    801020cb <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80101fbf:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc2:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fc6:	98                   	cwtl   
80101fc7:	8b 04 c5 e0 21 11 80 	mov    -0x7feede20(,%eax,8),%eax
80101fce:	8b 55 14             	mov    0x14(%ebp),%edx
80101fd1:	83 ec 04             	sub    $0x4,%esp
80101fd4:	52                   	push   %edx
80101fd5:	ff 75 0c             	pushl  0xc(%ebp)
80101fd8:	ff 75 08             	pushl  0x8(%ebp)
80101fdb:	ff d0                	call   *%eax
80101fdd:	83 c4 10             	add    $0x10,%esp
80101fe0:	e9 e6 00 00 00       	jmp    801020cb <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80101fe5:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe8:	8b 40 18             	mov    0x18(%eax),%eax
80101feb:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fee:	72 0d                	jb     80101ffd <readi+0x87>
80101ff0:	8b 55 10             	mov    0x10(%ebp),%edx
80101ff3:	8b 45 14             	mov    0x14(%ebp),%eax
80101ff6:	01 d0                	add    %edx,%eax
80101ff8:	3b 45 10             	cmp    0x10(%ebp),%eax
80101ffb:	73 0a                	jae    80102007 <readi+0x91>
    return -1;
80101ffd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102002:	e9 c4 00 00 00       	jmp    801020cb <readi+0x155>
  if(off + n > ip->size)
80102007:	8b 55 10             	mov    0x10(%ebp),%edx
8010200a:	8b 45 14             	mov    0x14(%ebp),%eax
8010200d:	01 c2                	add    %eax,%edx
8010200f:	8b 45 08             	mov    0x8(%ebp),%eax
80102012:	8b 40 18             	mov    0x18(%eax),%eax
80102015:	39 c2                	cmp    %eax,%edx
80102017:	76 0c                	jbe    80102025 <readi+0xaf>
    n = ip->size - off;
80102019:	8b 45 08             	mov    0x8(%ebp),%eax
8010201c:	8b 40 18             	mov    0x18(%eax),%eax
8010201f:	2b 45 10             	sub    0x10(%ebp),%eax
80102022:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102025:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010202c:	e9 8b 00 00 00       	jmp    801020bc <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102031:	8b 45 10             	mov    0x10(%ebp),%eax
80102034:	c1 e8 09             	shr    $0x9,%eax
80102037:	83 ec 08             	sub    $0x8,%esp
8010203a:	50                   	push   %eax
8010203b:	ff 75 08             	pushl  0x8(%ebp)
8010203e:	e8 aa fc ff ff       	call   80101ced <bmap>
80102043:	83 c4 10             	add    $0x10,%esp
80102046:	89 c2                	mov    %eax,%edx
80102048:	8b 45 08             	mov    0x8(%ebp),%eax
8010204b:	8b 00                	mov    (%eax),%eax
8010204d:	83 ec 08             	sub    $0x8,%esp
80102050:	52                   	push   %edx
80102051:	50                   	push   %eax
80102052:	e8 5f e1 ff ff       	call   801001b6 <bread>
80102057:	83 c4 10             	add    $0x10,%esp
8010205a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010205d:	8b 45 10             	mov    0x10(%ebp),%eax
80102060:	25 ff 01 00 00       	and    $0x1ff,%eax
80102065:	ba 00 02 00 00       	mov    $0x200,%edx
8010206a:	29 c2                	sub    %eax,%edx
8010206c:	8b 45 14             	mov    0x14(%ebp),%eax
8010206f:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102072:	39 c2                	cmp    %eax,%edx
80102074:	0f 46 c2             	cmovbe %edx,%eax
80102077:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
8010207a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010207d:	8d 50 18             	lea    0x18(%eax),%edx
80102080:	8b 45 10             	mov    0x10(%ebp),%eax
80102083:	25 ff 01 00 00       	and    $0x1ff,%eax
80102088:	01 d0                	add    %edx,%eax
8010208a:	83 ec 04             	sub    $0x4,%esp
8010208d:	ff 75 ec             	pushl  -0x14(%ebp)
80102090:	50                   	push   %eax
80102091:	ff 75 0c             	pushl  0xc(%ebp)
80102094:	e8 ac 3f 00 00       	call   80106045 <memmove>
80102099:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010209c:	83 ec 0c             	sub    $0xc,%esp
8010209f:	ff 75 f0             	pushl  -0x10(%ebp)
801020a2:	e8 87 e1 ff ff       	call   8010022e <brelse>
801020a7:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020ad:	01 45 f4             	add    %eax,-0xc(%ebp)
801020b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020b3:	01 45 10             	add    %eax,0x10(%ebp)
801020b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020b9:	01 45 0c             	add    %eax,0xc(%ebp)
801020bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020bf:	3b 45 14             	cmp    0x14(%ebp),%eax
801020c2:	0f 82 69 ff ff ff    	jb     80102031 <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
801020c8:	8b 45 14             	mov    0x14(%ebp),%eax
}
801020cb:	c9                   	leave  
801020cc:	c3                   	ret    

801020cd <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801020cd:	55                   	push   %ebp
801020ce:	89 e5                	mov    %esp,%ebp
801020d0:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801020d3:	8b 45 08             	mov    0x8(%ebp),%eax
801020d6:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801020da:	66 83 f8 03          	cmp    $0x3,%ax
801020de:	75 5c                	jne    8010213c <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801020e0:	8b 45 08             	mov    0x8(%ebp),%eax
801020e3:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020e7:	66 85 c0             	test   %ax,%ax
801020ea:	78 20                	js     8010210c <writei+0x3f>
801020ec:	8b 45 08             	mov    0x8(%ebp),%eax
801020ef:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020f3:	66 83 f8 09          	cmp    $0x9,%ax
801020f7:	7f 13                	jg     8010210c <writei+0x3f>
801020f9:	8b 45 08             	mov    0x8(%ebp),%eax
801020fc:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102100:	98                   	cwtl   
80102101:	8b 04 c5 e4 21 11 80 	mov    -0x7feede1c(,%eax,8),%eax
80102108:	85 c0                	test   %eax,%eax
8010210a:	75 0a                	jne    80102116 <writei+0x49>
      return -1;
8010210c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102111:	e9 3d 01 00 00       	jmp    80102253 <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
80102116:	8b 45 08             	mov    0x8(%ebp),%eax
80102119:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010211d:	98                   	cwtl   
8010211e:	8b 04 c5 e4 21 11 80 	mov    -0x7feede1c(,%eax,8),%eax
80102125:	8b 55 14             	mov    0x14(%ebp),%edx
80102128:	83 ec 04             	sub    $0x4,%esp
8010212b:	52                   	push   %edx
8010212c:	ff 75 0c             	pushl  0xc(%ebp)
8010212f:	ff 75 08             	pushl  0x8(%ebp)
80102132:	ff d0                	call   *%eax
80102134:	83 c4 10             	add    $0x10,%esp
80102137:	e9 17 01 00 00       	jmp    80102253 <writei+0x186>
  }

  if(off > ip->size || off + n < off)
8010213c:	8b 45 08             	mov    0x8(%ebp),%eax
8010213f:	8b 40 18             	mov    0x18(%eax),%eax
80102142:	3b 45 10             	cmp    0x10(%ebp),%eax
80102145:	72 0d                	jb     80102154 <writei+0x87>
80102147:	8b 55 10             	mov    0x10(%ebp),%edx
8010214a:	8b 45 14             	mov    0x14(%ebp),%eax
8010214d:	01 d0                	add    %edx,%eax
8010214f:	3b 45 10             	cmp    0x10(%ebp),%eax
80102152:	73 0a                	jae    8010215e <writei+0x91>
    return -1;
80102154:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102159:	e9 f5 00 00 00       	jmp    80102253 <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
8010215e:	8b 55 10             	mov    0x10(%ebp),%edx
80102161:	8b 45 14             	mov    0x14(%ebp),%eax
80102164:	01 d0                	add    %edx,%eax
80102166:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010216b:	76 0a                	jbe    80102177 <writei+0xaa>
    return -1;
8010216d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102172:	e9 dc 00 00 00       	jmp    80102253 <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102177:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010217e:	e9 99 00 00 00       	jmp    8010221c <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102183:	8b 45 10             	mov    0x10(%ebp),%eax
80102186:	c1 e8 09             	shr    $0x9,%eax
80102189:	83 ec 08             	sub    $0x8,%esp
8010218c:	50                   	push   %eax
8010218d:	ff 75 08             	pushl  0x8(%ebp)
80102190:	e8 58 fb ff ff       	call   80101ced <bmap>
80102195:	83 c4 10             	add    $0x10,%esp
80102198:	89 c2                	mov    %eax,%edx
8010219a:	8b 45 08             	mov    0x8(%ebp),%eax
8010219d:	8b 00                	mov    (%eax),%eax
8010219f:	83 ec 08             	sub    $0x8,%esp
801021a2:	52                   	push   %edx
801021a3:	50                   	push   %eax
801021a4:	e8 0d e0 ff ff       	call   801001b6 <bread>
801021a9:	83 c4 10             	add    $0x10,%esp
801021ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801021af:	8b 45 10             	mov    0x10(%ebp),%eax
801021b2:	25 ff 01 00 00       	and    $0x1ff,%eax
801021b7:	ba 00 02 00 00       	mov    $0x200,%edx
801021bc:	29 c2                	sub    %eax,%edx
801021be:	8b 45 14             	mov    0x14(%ebp),%eax
801021c1:	2b 45 f4             	sub    -0xc(%ebp),%eax
801021c4:	39 c2                	cmp    %eax,%edx
801021c6:	0f 46 c2             	cmovbe %edx,%eax
801021c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801021cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021cf:	8d 50 18             	lea    0x18(%eax),%edx
801021d2:	8b 45 10             	mov    0x10(%ebp),%eax
801021d5:	25 ff 01 00 00       	and    $0x1ff,%eax
801021da:	01 d0                	add    %edx,%eax
801021dc:	83 ec 04             	sub    $0x4,%esp
801021df:	ff 75 ec             	pushl  -0x14(%ebp)
801021e2:	ff 75 0c             	pushl  0xc(%ebp)
801021e5:	50                   	push   %eax
801021e6:	e8 5a 3e 00 00       	call   80106045 <memmove>
801021eb:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801021ee:	83 ec 0c             	sub    $0xc,%esp
801021f1:	ff 75 f0             	pushl  -0x10(%ebp)
801021f4:	e8 2a 16 00 00       	call   80103823 <log_write>
801021f9:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801021fc:	83 ec 0c             	sub    $0xc,%esp
801021ff:	ff 75 f0             	pushl  -0x10(%ebp)
80102202:	e8 27 e0 ff ff       	call   8010022e <brelse>
80102207:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010220a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010220d:	01 45 f4             	add    %eax,-0xc(%ebp)
80102210:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102213:	01 45 10             	add    %eax,0x10(%ebp)
80102216:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102219:	01 45 0c             	add    %eax,0xc(%ebp)
8010221c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010221f:	3b 45 14             	cmp    0x14(%ebp),%eax
80102222:	0f 82 5b ff ff ff    	jb     80102183 <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102228:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010222c:	74 22                	je     80102250 <writei+0x183>
8010222e:	8b 45 08             	mov    0x8(%ebp),%eax
80102231:	8b 40 18             	mov    0x18(%eax),%eax
80102234:	3b 45 10             	cmp    0x10(%ebp),%eax
80102237:	73 17                	jae    80102250 <writei+0x183>
    ip->size = off;
80102239:	8b 45 08             	mov    0x8(%ebp),%eax
8010223c:	8b 55 10             	mov    0x10(%ebp),%edx
8010223f:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
80102242:	83 ec 0c             	sub    $0xc,%esp
80102245:	ff 75 08             	pushl  0x8(%ebp)
80102248:	e8 e1 f5 ff ff       	call   8010182e <iupdate>
8010224d:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102250:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102253:	c9                   	leave  
80102254:	c3                   	ret    

80102255 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102255:	55                   	push   %ebp
80102256:	89 e5                	mov    %esp,%ebp
80102258:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
8010225b:	83 ec 04             	sub    $0x4,%esp
8010225e:	6a 0e                	push   $0xe
80102260:	ff 75 0c             	pushl  0xc(%ebp)
80102263:	ff 75 08             	pushl  0x8(%ebp)
80102266:	e8 70 3e 00 00       	call   801060db <strncmp>
8010226b:	83 c4 10             	add    $0x10,%esp
}
8010226e:	c9                   	leave  
8010226f:	c3                   	ret    

80102270 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102270:	55                   	push   %ebp
80102271:	89 e5                	mov    %esp,%ebp
80102273:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102276:	8b 45 08             	mov    0x8(%ebp),%eax
80102279:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010227d:	66 83 f8 01          	cmp    $0x1,%ax
80102281:	74 0d                	je     80102290 <dirlookup+0x20>
    panic("dirlookup not DIR");
80102283:	83 ec 0c             	sub    $0xc,%esp
80102286:	68 1b 95 10 80       	push   $0x8010951b
8010228b:	e8 d6 e2 ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102290:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102297:	eb 7b                	jmp    80102314 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102299:	6a 10                	push   $0x10
8010229b:	ff 75 f4             	pushl  -0xc(%ebp)
8010229e:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022a1:	50                   	push   %eax
801022a2:	ff 75 08             	pushl  0x8(%ebp)
801022a5:	e8 cc fc ff ff       	call   80101f76 <readi>
801022aa:	83 c4 10             	add    $0x10,%esp
801022ad:	83 f8 10             	cmp    $0x10,%eax
801022b0:	74 0d                	je     801022bf <dirlookup+0x4f>
      panic("dirlink read");
801022b2:	83 ec 0c             	sub    $0xc,%esp
801022b5:	68 2d 95 10 80       	push   $0x8010952d
801022ba:	e8 a7 e2 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801022bf:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022c3:	66 85 c0             	test   %ax,%ax
801022c6:	74 47                	je     8010230f <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
801022c8:	83 ec 08             	sub    $0x8,%esp
801022cb:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022ce:	83 c0 02             	add    $0x2,%eax
801022d1:	50                   	push   %eax
801022d2:	ff 75 0c             	pushl  0xc(%ebp)
801022d5:	e8 7b ff ff ff       	call   80102255 <namecmp>
801022da:	83 c4 10             	add    $0x10,%esp
801022dd:	85 c0                	test   %eax,%eax
801022df:	75 2f                	jne    80102310 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
801022e1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801022e5:	74 08                	je     801022ef <dirlookup+0x7f>
        *poff = off;
801022e7:	8b 45 10             	mov    0x10(%ebp),%eax
801022ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801022ed:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801022ef:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022f3:	0f b7 c0             	movzwl %ax,%eax
801022f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801022f9:	8b 45 08             	mov    0x8(%ebp),%eax
801022fc:	8b 00                	mov    (%eax),%eax
801022fe:	83 ec 08             	sub    $0x8,%esp
80102301:	ff 75 f0             	pushl  -0x10(%ebp)
80102304:	50                   	push   %eax
80102305:	e8 e5 f5 ff ff       	call   801018ef <iget>
8010230a:	83 c4 10             	add    $0x10,%esp
8010230d:	eb 19                	jmp    80102328 <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
8010230f:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102310:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102314:	8b 45 08             	mov    0x8(%ebp),%eax
80102317:	8b 40 18             	mov    0x18(%eax),%eax
8010231a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010231d:	0f 87 76 ff ff ff    	ja     80102299 <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102323:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102328:	c9                   	leave  
80102329:	c3                   	ret    

8010232a <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010232a:	55                   	push   %ebp
8010232b:	89 e5                	mov    %esp,%ebp
8010232d:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102330:	83 ec 04             	sub    $0x4,%esp
80102333:	6a 00                	push   $0x0
80102335:	ff 75 0c             	pushl  0xc(%ebp)
80102338:	ff 75 08             	pushl  0x8(%ebp)
8010233b:	e8 30 ff ff ff       	call   80102270 <dirlookup>
80102340:	83 c4 10             	add    $0x10,%esp
80102343:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102346:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010234a:	74 18                	je     80102364 <dirlink+0x3a>
    iput(ip);
8010234c:	83 ec 0c             	sub    $0xc,%esp
8010234f:	ff 75 f0             	pushl  -0x10(%ebp)
80102352:	e8 81 f8 ff ff       	call   80101bd8 <iput>
80102357:	83 c4 10             	add    $0x10,%esp
    return -1;
8010235a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010235f:	e9 9c 00 00 00       	jmp    80102400 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102364:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010236b:	eb 39                	jmp    801023a6 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010236d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102370:	6a 10                	push   $0x10
80102372:	50                   	push   %eax
80102373:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102376:	50                   	push   %eax
80102377:	ff 75 08             	pushl  0x8(%ebp)
8010237a:	e8 f7 fb ff ff       	call   80101f76 <readi>
8010237f:	83 c4 10             	add    $0x10,%esp
80102382:	83 f8 10             	cmp    $0x10,%eax
80102385:	74 0d                	je     80102394 <dirlink+0x6a>
      panic("dirlink read");
80102387:	83 ec 0c             	sub    $0xc,%esp
8010238a:	68 2d 95 10 80       	push   $0x8010952d
8010238f:	e8 d2 e1 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
80102394:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102398:	66 85 c0             	test   %ax,%ax
8010239b:	74 18                	je     801023b5 <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010239d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023a0:	83 c0 10             	add    $0x10,%eax
801023a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023a6:	8b 45 08             	mov    0x8(%ebp),%eax
801023a9:	8b 50 18             	mov    0x18(%eax),%edx
801023ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023af:	39 c2                	cmp    %eax,%edx
801023b1:	77 ba                	ja     8010236d <dirlink+0x43>
801023b3:	eb 01                	jmp    801023b6 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
801023b5:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801023b6:	83 ec 04             	sub    $0x4,%esp
801023b9:	6a 0e                	push   $0xe
801023bb:	ff 75 0c             	pushl  0xc(%ebp)
801023be:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023c1:	83 c0 02             	add    $0x2,%eax
801023c4:	50                   	push   %eax
801023c5:	e8 67 3d 00 00       	call   80106131 <strncpy>
801023ca:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801023cd:	8b 45 10             	mov    0x10(%ebp),%eax
801023d0:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023d7:	6a 10                	push   $0x10
801023d9:	50                   	push   %eax
801023da:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023dd:	50                   	push   %eax
801023de:	ff 75 08             	pushl  0x8(%ebp)
801023e1:	e8 e7 fc ff ff       	call   801020cd <writei>
801023e6:	83 c4 10             	add    $0x10,%esp
801023e9:	83 f8 10             	cmp    $0x10,%eax
801023ec:	74 0d                	je     801023fb <dirlink+0xd1>
    panic("dirlink");
801023ee:	83 ec 0c             	sub    $0xc,%esp
801023f1:	68 3a 95 10 80       	push   $0x8010953a
801023f6:	e8 6b e1 ff ff       	call   80100566 <panic>
  
  return 0;
801023fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102400:	c9                   	leave  
80102401:	c3                   	ret    

80102402 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102402:	55                   	push   %ebp
80102403:	89 e5                	mov    %esp,%ebp
80102405:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102408:	eb 04                	jmp    8010240e <skipelem+0xc>
    path++;
8010240a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
8010240e:	8b 45 08             	mov    0x8(%ebp),%eax
80102411:	0f b6 00             	movzbl (%eax),%eax
80102414:	3c 2f                	cmp    $0x2f,%al
80102416:	74 f2                	je     8010240a <skipelem+0x8>
    path++;
  if(*path == 0)
80102418:	8b 45 08             	mov    0x8(%ebp),%eax
8010241b:	0f b6 00             	movzbl (%eax),%eax
8010241e:	84 c0                	test   %al,%al
80102420:	75 07                	jne    80102429 <skipelem+0x27>
    return 0;
80102422:	b8 00 00 00 00       	mov    $0x0,%eax
80102427:	eb 7b                	jmp    801024a4 <skipelem+0xa2>
  s = path;
80102429:	8b 45 08             	mov    0x8(%ebp),%eax
8010242c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010242f:	eb 04                	jmp    80102435 <skipelem+0x33>
    path++;
80102431:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102435:	8b 45 08             	mov    0x8(%ebp),%eax
80102438:	0f b6 00             	movzbl (%eax),%eax
8010243b:	3c 2f                	cmp    $0x2f,%al
8010243d:	74 0a                	je     80102449 <skipelem+0x47>
8010243f:	8b 45 08             	mov    0x8(%ebp),%eax
80102442:	0f b6 00             	movzbl (%eax),%eax
80102445:	84 c0                	test   %al,%al
80102447:	75 e8                	jne    80102431 <skipelem+0x2f>
    path++;
  len = path - s;
80102449:	8b 55 08             	mov    0x8(%ebp),%edx
8010244c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010244f:	29 c2                	sub    %eax,%edx
80102451:	89 d0                	mov    %edx,%eax
80102453:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102456:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010245a:	7e 15                	jle    80102471 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
8010245c:	83 ec 04             	sub    $0x4,%esp
8010245f:	6a 0e                	push   $0xe
80102461:	ff 75 f4             	pushl  -0xc(%ebp)
80102464:	ff 75 0c             	pushl  0xc(%ebp)
80102467:	e8 d9 3b 00 00       	call   80106045 <memmove>
8010246c:	83 c4 10             	add    $0x10,%esp
8010246f:	eb 26                	jmp    80102497 <skipelem+0x95>
  else {
    memmove(name, s, len);
80102471:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102474:	83 ec 04             	sub    $0x4,%esp
80102477:	50                   	push   %eax
80102478:	ff 75 f4             	pushl  -0xc(%ebp)
8010247b:	ff 75 0c             	pushl  0xc(%ebp)
8010247e:	e8 c2 3b 00 00       	call   80106045 <memmove>
80102483:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
80102486:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102489:	8b 45 0c             	mov    0xc(%ebp),%eax
8010248c:	01 d0                	add    %edx,%eax
8010248e:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102491:	eb 04                	jmp    80102497 <skipelem+0x95>
    path++;
80102493:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102497:	8b 45 08             	mov    0x8(%ebp),%eax
8010249a:	0f b6 00             	movzbl (%eax),%eax
8010249d:	3c 2f                	cmp    $0x2f,%al
8010249f:	74 f2                	je     80102493 <skipelem+0x91>
    path++;
  return path;
801024a1:	8b 45 08             	mov    0x8(%ebp),%eax
}
801024a4:	c9                   	leave  
801024a5:	c3                   	ret    

801024a6 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801024a6:	55                   	push   %ebp
801024a7:	89 e5                	mov    %esp,%ebp
801024a9:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801024ac:	8b 45 08             	mov    0x8(%ebp),%eax
801024af:	0f b6 00             	movzbl (%eax),%eax
801024b2:	3c 2f                	cmp    $0x2f,%al
801024b4:	75 17                	jne    801024cd <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
801024b6:	83 ec 08             	sub    $0x8,%esp
801024b9:	6a 01                	push   $0x1
801024bb:	6a 01                	push   $0x1
801024bd:	e8 2d f4 ff ff       	call   801018ef <iget>
801024c2:	83 c4 10             	add    $0x10,%esp
801024c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024c8:	e9 bb 00 00 00       	jmp    80102588 <namex+0xe2>
  else
    ip = idup(proc->cwd);
801024cd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801024d3:	8b 40 68             	mov    0x68(%eax),%eax
801024d6:	83 ec 0c             	sub    $0xc,%esp
801024d9:	50                   	push   %eax
801024da:	e8 ef f4 ff ff       	call   801019ce <idup>
801024df:	83 c4 10             	add    $0x10,%esp
801024e2:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801024e5:	e9 9e 00 00 00       	jmp    80102588 <namex+0xe2>
    ilock(ip);
801024ea:	83 ec 0c             	sub    $0xc,%esp
801024ed:	ff 75 f4             	pushl  -0xc(%ebp)
801024f0:	e8 13 f5 ff ff       	call   80101a08 <ilock>
801024f5:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
801024f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024fb:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801024ff:	66 83 f8 01          	cmp    $0x1,%ax
80102503:	74 18                	je     8010251d <namex+0x77>
      iunlockput(ip);
80102505:	83 ec 0c             	sub    $0xc,%esp
80102508:	ff 75 f4             	pushl  -0xc(%ebp)
8010250b:	e8 b8 f7 ff ff       	call   80101cc8 <iunlockput>
80102510:	83 c4 10             	add    $0x10,%esp
      return 0;
80102513:	b8 00 00 00 00       	mov    $0x0,%eax
80102518:	e9 a7 00 00 00       	jmp    801025c4 <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
8010251d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102521:	74 20                	je     80102543 <namex+0x9d>
80102523:	8b 45 08             	mov    0x8(%ebp),%eax
80102526:	0f b6 00             	movzbl (%eax),%eax
80102529:	84 c0                	test   %al,%al
8010252b:	75 16                	jne    80102543 <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
8010252d:	83 ec 0c             	sub    $0xc,%esp
80102530:	ff 75 f4             	pushl  -0xc(%ebp)
80102533:	e8 2e f6 ff ff       	call   80101b66 <iunlock>
80102538:	83 c4 10             	add    $0x10,%esp
      return ip;
8010253b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010253e:	e9 81 00 00 00       	jmp    801025c4 <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102543:	83 ec 04             	sub    $0x4,%esp
80102546:	6a 00                	push   $0x0
80102548:	ff 75 10             	pushl  0x10(%ebp)
8010254b:	ff 75 f4             	pushl  -0xc(%ebp)
8010254e:	e8 1d fd ff ff       	call   80102270 <dirlookup>
80102553:	83 c4 10             	add    $0x10,%esp
80102556:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102559:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010255d:	75 15                	jne    80102574 <namex+0xce>
      iunlockput(ip);
8010255f:	83 ec 0c             	sub    $0xc,%esp
80102562:	ff 75 f4             	pushl  -0xc(%ebp)
80102565:	e8 5e f7 ff ff       	call   80101cc8 <iunlockput>
8010256a:	83 c4 10             	add    $0x10,%esp
      return 0;
8010256d:	b8 00 00 00 00       	mov    $0x0,%eax
80102572:	eb 50                	jmp    801025c4 <namex+0x11e>
    }
    iunlockput(ip);
80102574:	83 ec 0c             	sub    $0xc,%esp
80102577:	ff 75 f4             	pushl  -0xc(%ebp)
8010257a:	e8 49 f7 ff ff       	call   80101cc8 <iunlockput>
8010257f:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102582:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102585:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102588:	83 ec 08             	sub    $0x8,%esp
8010258b:	ff 75 10             	pushl  0x10(%ebp)
8010258e:	ff 75 08             	pushl  0x8(%ebp)
80102591:	e8 6c fe ff ff       	call   80102402 <skipelem>
80102596:	83 c4 10             	add    $0x10,%esp
80102599:	89 45 08             	mov    %eax,0x8(%ebp)
8010259c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025a0:	0f 85 44 ff ff ff    	jne    801024ea <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801025a6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025aa:	74 15                	je     801025c1 <namex+0x11b>
    iput(ip);
801025ac:	83 ec 0c             	sub    $0xc,%esp
801025af:	ff 75 f4             	pushl  -0xc(%ebp)
801025b2:	e8 21 f6 ff ff       	call   80101bd8 <iput>
801025b7:	83 c4 10             	add    $0x10,%esp
    return 0;
801025ba:	b8 00 00 00 00       	mov    $0x0,%eax
801025bf:	eb 03                	jmp    801025c4 <namex+0x11e>
  }
  return ip;
801025c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801025c4:	c9                   	leave  
801025c5:	c3                   	ret    

801025c6 <namei>:

struct inode*
namei(char *path)
{
801025c6:	55                   	push   %ebp
801025c7:	89 e5                	mov    %esp,%ebp
801025c9:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801025cc:	83 ec 04             	sub    $0x4,%esp
801025cf:	8d 45 ea             	lea    -0x16(%ebp),%eax
801025d2:	50                   	push   %eax
801025d3:	6a 00                	push   $0x0
801025d5:	ff 75 08             	pushl  0x8(%ebp)
801025d8:	e8 c9 fe ff ff       	call   801024a6 <namex>
801025dd:	83 c4 10             	add    $0x10,%esp
}
801025e0:	c9                   	leave  
801025e1:	c3                   	ret    

801025e2 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801025e2:	55                   	push   %ebp
801025e3:	89 e5                	mov    %esp,%ebp
801025e5:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
801025e8:	83 ec 04             	sub    $0x4,%esp
801025eb:	ff 75 0c             	pushl  0xc(%ebp)
801025ee:	6a 01                	push   $0x1
801025f0:	ff 75 08             	pushl  0x8(%ebp)
801025f3:	e8 ae fe ff ff       	call   801024a6 <namex>
801025f8:	83 c4 10             	add    $0x10,%esp
}
801025fb:	c9                   	leave  
801025fc:	c3                   	ret    

801025fd <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
801025fd:	55                   	push   %ebp
801025fe:	89 e5                	mov    %esp,%ebp
80102600:	83 ec 14             	sub    $0x14,%esp
80102603:	8b 45 08             	mov    0x8(%ebp),%eax
80102606:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010260a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010260e:	89 c2                	mov    %eax,%edx
80102610:	ec                   	in     (%dx),%al
80102611:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102614:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102618:	c9                   	leave  
80102619:	c3                   	ret    

8010261a <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
8010261a:	55                   	push   %ebp
8010261b:	89 e5                	mov    %esp,%ebp
8010261d:	57                   	push   %edi
8010261e:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010261f:	8b 55 08             	mov    0x8(%ebp),%edx
80102622:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102625:	8b 45 10             	mov    0x10(%ebp),%eax
80102628:	89 cb                	mov    %ecx,%ebx
8010262a:	89 df                	mov    %ebx,%edi
8010262c:	89 c1                	mov    %eax,%ecx
8010262e:	fc                   	cld    
8010262f:	f3 6d                	rep insl (%dx),%es:(%edi)
80102631:	89 c8                	mov    %ecx,%eax
80102633:	89 fb                	mov    %edi,%ebx
80102635:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102638:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
8010263b:	90                   	nop
8010263c:	5b                   	pop    %ebx
8010263d:	5f                   	pop    %edi
8010263e:	5d                   	pop    %ebp
8010263f:	c3                   	ret    

80102640 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102640:	55                   	push   %ebp
80102641:	89 e5                	mov    %esp,%ebp
80102643:	83 ec 08             	sub    $0x8,%esp
80102646:	8b 55 08             	mov    0x8(%ebp),%edx
80102649:	8b 45 0c             	mov    0xc(%ebp),%eax
8010264c:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102650:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102653:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102657:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010265b:	ee                   	out    %al,(%dx)
}
8010265c:	90                   	nop
8010265d:	c9                   	leave  
8010265e:	c3                   	ret    

8010265f <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
8010265f:	55                   	push   %ebp
80102660:	89 e5                	mov    %esp,%ebp
80102662:	56                   	push   %esi
80102663:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102664:	8b 55 08             	mov    0x8(%ebp),%edx
80102667:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010266a:	8b 45 10             	mov    0x10(%ebp),%eax
8010266d:	89 cb                	mov    %ecx,%ebx
8010266f:	89 de                	mov    %ebx,%esi
80102671:	89 c1                	mov    %eax,%ecx
80102673:	fc                   	cld    
80102674:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102676:	89 c8                	mov    %ecx,%eax
80102678:	89 f3                	mov    %esi,%ebx
8010267a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010267d:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102680:	90                   	nop
80102681:	5b                   	pop    %ebx
80102682:	5e                   	pop    %esi
80102683:	5d                   	pop    %ebp
80102684:	c3                   	ret    

80102685 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102685:	55                   	push   %ebp
80102686:	89 e5                	mov    %esp,%ebp
80102688:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
8010268b:	90                   	nop
8010268c:	68 f7 01 00 00       	push   $0x1f7
80102691:	e8 67 ff ff ff       	call   801025fd <inb>
80102696:	83 c4 04             	add    $0x4,%esp
80102699:	0f b6 c0             	movzbl %al,%eax
8010269c:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010269f:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026a2:	25 c0 00 00 00       	and    $0xc0,%eax
801026a7:	83 f8 40             	cmp    $0x40,%eax
801026aa:	75 e0                	jne    8010268c <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801026ac:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026b0:	74 11                	je     801026c3 <idewait+0x3e>
801026b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026b5:	83 e0 21             	and    $0x21,%eax
801026b8:	85 c0                	test   %eax,%eax
801026ba:	74 07                	je     801026c3 <idewait+0x3e>
    return -1;
801026bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801026c1:	eb 05                	jmp    801026c8 <idewait+0x43>
  return 0;
801026c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801026c8:	c9                   	leave  
801026c9:	c3                   	ret    

801026ca <ideinit>:

void
ideinit(void)
{
801026ca:	55                   	push   %ebp
801026cb:	89 e5                	mov    %esp,%ebp
801026cd:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
801026d0:	83 ec 08             	sub    $0x8,%esp
801026d3:	68 42 95 10 80       	push   $0x80109542
801026d8:	68 20 c6 10 80       	push   $0x8010c620
801026dd:	e8 1f 36 00 00       	call   80105d01 <initlock>
801026e2:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
801026e5:	83 ec 0c             	sub    $0xc,%esp
801026e8:	6a 0e                	push   $0xe
801026ea:	e8 da 18 00 00       	call   80103fc9 <picenable>
801026ef:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801026f2:	a1 60 39 11 80       	mov    0x80113960,%eax
801026f7:	83 e8 01             	sub    $0x1,%eax
801026fa:	83 ec 08             	sub    $0x8,%esp
801026fd:	50                   	push   %eax
801026fe:	6a 0e                	push   $0xe
80102700:	e8 73 04 00 00       	call   80102b78 <ioapicenable>
80102705:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102708:	83 ec 0c             	sub    $0xc,%esp
8010270b:	6a 00                	push   $0x0
8010270d:	e8 73 ff ff ff       	call   80102685 <idewait>
80102712:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102715:	83 ec 08             	sub    $0x8,%esp
80102718:	68 f0 00 00 00       	push   $0xf0
8010271d:	68 f6 01 00 00       	push   $0x1f6
80102722:	e8 19 ff ff ff       	call   80102640 <outb>
80102727:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
8010272a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102731:	eb 24                	jmp    80102757 <ideinit+0x8d>
    if(inb(0x1f7) != 0){
80102733:	83 ec 0c             	sub    $0xc,%esp
80102736:	68 f7 01 00 00       	push   $0x1f7
8010273b:	e8 bd fe ff ff       	call   801025fd <inb>
80102740:	83 c4 10             	add    $0x10,%esp
80102743:	84 c0                	test   %al,%al
80102745:	74 0c                	je     80102753 <ideinit+0x89>
      havedisk1 = 1;
80102747:	c7 05 58 c6 10 80 01 	movl   $0x1,0x8010c658
8010274e:	00 00 00 
      break;
80102751:	eb 0d                	jmp    80102760 <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102753:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102757:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
8010275e:	7e d3                	jle    80102733 <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102760:	83 ec 08             	sub    $0x8,%esp
80102763:	68 e0 00 00 00       	push   $0xe0
80102768:	68 f6 01 00 00       	push   $0x1f6
8010276d:	e8 ce fe ff ff       	call   80102640 <outb>
80102772:	83 c4 10             	add    $0x10,%esp
}
80102775:	90                   	nop
80102776:	c9                   	leave  
80102777:	c3                   	ret    

80102778 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102778:	55                   	push   %ebp
80102779:	89 e5                	mov    %esp,%ebp
8010277b:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
8010277e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102782:	75 0d                	jne    80102791 <idestart+0x19>
    panic("idestart");
80102784:	83 ec 0c             	sub    $0xc,%esp
80102787:	68 46 95 10 80       	push   $0x80109546
8010278c:	e8 d5 dd ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE)
80102791:	8b 45 08             	mov    0x8(%ebp),%eax
80102794:	8b 40 08             	mov    0x8(%eax),%eax
80102797:	3d cf 07 00 00       	cmp    $0x7cf,%eax
8010279c:	76 0d                	jbe    801027ab <idestart+0x33>
    panic("incorrect blockno");
8010279e:	83 ec 0c             	sub    $0xc,%esp
801027a1:	68 4f 95 10 80       	push   $0x8010954f
801027a6:	e8 bb dd ff ff       	call   80100566 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801027ab:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801027b2:	8b 45 08             	mov    0x8(%ebp),%eax
801027b5:	8b 50 08             	mov    0x8(%eax),%edx
801027b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027bb:	0f af c2             	imul   %edx,%eax
801027be:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
801027c1:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801027c5:	7e 0d                	jle    801027d4 <idestart+0x5c>
801027c7:	83 ec 0c             	sub    $0xc,%esp
801027ca:	68 46 95 10 80       	push   $0x80109546
801027cf:	e8 92 dd ff ff       	call   80100566 <panic>
  
  idewait(0);
801027d4:	83 ec 0c             	sub    $0xc,%esp
801027d7:	6a 00                	push   $0x0
801027d9:	e8 a7 fe ff ff       	call   80102685 <idewait>
801027de:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
801027e1:	83 ec 08             	sub    $0x8,%esp
801027e4:	6a 00                	push   $0x0
801027e6:	68 f6 03 00 00       	push   $0x3f6
801027eb:	e8 50 fe ff ff       	call   80102640 <outb>
801027f0:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
801027f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027f6:	0f b6 c0             	movzbl %al,%eax
801027f9:	83 ec 08             	sub    $0x8,%esp
801027fc:	50                   	push   %eax
801027fd:	68 f2 01 00 00       	push   $0x1f2
80102802:	e8 39 fe ff ff       	call   80102640 <outb>
80102807:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
8010280a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010280d:	0f b6 c0             	movzbl %al,%eax
80102810:	83 ec 08             	sub    $0x8,%esp
80102813:	50                   	push   %eax
80102814:	68 f3 01 00 00       	push   $0x1f3
80102819:	e8 22 fe ff ff       	call   80102640 <outb>
8010281e:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102821:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102824:	c1 f8 08             	sar    $0x8,%eax
80102827:	0f b6 c0             	movzbl %al,%eax
8010282a:	83 ec 08             	sub    $0x8,%esp
8010282d:	50                   	push   %eax
8010282e:	68 f4 01 00 00       	push   $0x1f4
80102833:	e8 08 fe ff ff       	call   80102640 <outb>
80102838:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
8010283b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010283e:	c1 f8 10             	sar    $0x10,%eax
80102841:	0f b6 c0             	movzbl %al,%eax
80102844:	83 ec 08             	sub    $0x8,%esp
80102847:	50                   	push   %eax
80102848:	68 f5 01 00 00       	push   $0x1f5
8010284d:	e8 ee fd ff ff       	call   80102640 <outb>
80102852:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102855:	8b 45 08             	mov    0x8(%ebp),%eax
80102858:	8b 40 04             	mov    0x4(%eax),%eax
8010285b:	83 e0 01             	and    $0x1,%eax
8010285e:	c1 e0 04             	shl    $0x4,%eax
80102861:	89 c2                	mov    %eax,%edx
80102863:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102866:	c1 f8 18             	sar    $0x18,%eax
80102869:	83 e0 0f             	and    $0xf,%eax
8010286c:	09 d0                	or     %edx,%eax
8010286e:	83 c8 e0             	or     $0xffffffe0,%eax
80102871:	0f b6 c0             	movzbl %al,%eax
80102874:	83 ec 08             	sub    $0x8,%esp
80102877:	50                   	push   %eax
80102878:	68 f6 01 00 00       	push   $0x1f6
8010287d:	e8 be fd ff ff       	call   80102640 <outb>
80102882:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102885:	8b 45 08             	mov    0x8(%ebp),%eax
80102888:	8b 00                	mov    (%eax),%eax
8010288a:	83 e0 04             	and    $0x4,%eax
8010288d:	85 c0                	test   %eax,%eax
8010288f:	74 30                	je     801028c1 <idestart+0x149>
    outb(0x1f7, IDE_CMD_WRITE);
80102891:	83 ec 08             	sub    $0x8,%esp
80102894:	6a 30                	push   $0x30
80102896:	68 f7 01 00 00       	push   $0x1f7
8010289b:	e8 a0 fd ff ff       	call   80102640 <outb>
801028a0:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
801028a3:	8b 45 08             	mov    0x8(%ebp),%eax
801028a6:	83 c0 18             	add    $0x18,%eax
801028a9:	83 ec 04             	sub    $0x4,%esp
801028ac:	68 80 00 00 00       	push   $0x80
801028b1:	50                   	push   %eax
801028b2:	68 f0 01 00 00       	push   $0x1f0
801028b7:	e8 a3 fd ff ff       	call   8010265f <outsl>
801028bc:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
801028bf:	eb 12                	jmp    801028d3 <idestart+0x15b>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
801028c1:	83 ec 08             	sub    $0x8,%esp
801028c4:	6a 20                	push   $0x20
801028c6:	68 f7 01 00 00       	push   $0x1f7
801028cb:	e8 70 fd ff ff       	call   80102640 <outb>
801028d0:	83 c4 10             	add    $0x10,%esp
  }
}
801028d3:	90                   	nop
801028d4:	c9                   	leave  
801028d5:	c3                   	ret    

801028d6 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801028d6:	55                   	push   %ebp
801028d7:	89 e5                	mov    %esp,%ebp
801028d9:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801028dc:	83 ec 0c             	sub    $0xc,%esp
801028df:	68 20 c6 10 80       	push   $0x8010c620
801028e4:	e8 3a 34 00 00       	call   80105d23 <acquire>
801028e9:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
801028ec:	a1 54 c6 10 80       	mov    0x8010c654,%eax
801028f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801028f8:	75 15                	jne    8010290f <ideintr+0x39>
    release(&idelock);
801028fa:	83 ec 0c             	sub    $0xc,%esp
801028fd:	68 20 c6 10 80       	push   $0x8010c620
80102902:	e8 83 34 00 00       	call   80105d8a <release>
80102907:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
8010290a:	e9 9a 00 00 00       	jmp    801029a9 <ideintr+0xd3>
  }
  idequeue = b->qnext;
8010290f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102912:	8b 40 14             	mov    0x14(%eax),%eax
80102915:	a3 54 c6 10 80       	mov    %eax,0x8010c654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010291a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010291d:	8b 00                	mov    (%eax),%eax
8010291f:	83 e0 04             	and    $0x4,%eax
80102922:	85 c0                	test   %eax,%eax
80102924:	75 2d                	jne    80102953 <ideintr+0x7d>
80102926:	83 ec 0c             	sub    $0xc,%esp
80102929:	6a 01                	push   $0x1
8010292b:	e8 55 fd ff ff       	call   80102685 <idewait>
80102930:	83 c4 10             	add    $0x10,%esp
80102933:	85 c0                	test   %eax,%eax
80102935:	78 1c                	js     80102953 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
80102937:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010293a:	83 c0 18             	add    $0x18,%eax
8010293d:	83 ec 04             	sub    $0x4,%esp
80102940:	68 80 00 00 00       	push   $0x80
80102945:	50                   	push   %eax
80102946:	68 f0 01 00 00       	push   $0x1f0
8010294b:	e8 ca fc ff ff       	call   8010261a <insl>
80102950:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102956:	8b 00                	mov    (%eax),%eax
80102958:	83 c8 02             	or     $0x2,%eax
8010295b:	89 c2                	mov    %eax,%edx
8010295d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102960:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102962:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102965:	8b 00                	mov    (%eax),%eax
80102967:	83 e0 fb             	and    $0xfffffffb,%eax
8010296a:	89 c2                	mov    %eax,%edx
8010296c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010296f:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102971:	83 ec 0c             	sub    $0xc,%esp
80102974:	ff 75 f4             	pushl  -0xc(%ebp)
80102977:	e8 d4 29 00 00       	call   80105350 <wakeup>
8010297c:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
8010297f:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102984:	85 c0                	test   %eax,%eax
80102986:	74 11                	je     80102999 <ideintr+0xc3>
    idestart(idequeue);
80102988:	a1 54 c6 10 80       	mov    0x8010c654,%eax
8010298d:	83 ec 0c             	sub    $0xc,%esp
80102990:	50                   	push   %eax
80102991:	e8 e2 fd ff ff       	call   80102778 <idestart>
80102996:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102999:	83 ec 0c             	sub    $0xc,%esp
8010299c:	68 20 c6 10 80       	push   $0x8010c620
801029a1:	e8 e4 33 00 00       	call   80105d8a <release>
801029a6:	83 c4 10             	add    $0x10,%esp
}
801029a9:	c9                   	leave  
801029aa:	c3                   	ret    

801029ab <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801029ab:	55                   	push   %ebp
801029ac:	89 e5                	mov    %esp,%ebp
801029ae:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
801029b1:	8b 45 08             	mov    0x8(%ebp),%eax
801029b4:	8b 00                	mov    (%eax),%eax
801029b6:	83 e0 01             	and    $0x1,%eax
801029b9:	85 c0                	test   %eax,%eax
801029bb:	75 0d                	jne    801029ca <iderw+0x1f>
    panic("iderw: buf not busy");
801029bd:	83 ec 0c             	sub    $0xc,%esp
801029c0:	68 61 95 10 80       	push   $0x80109561
801029c5:	e8 9c db ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801029ca:	8b 45 08             	mov    0x8(%ebp),%eax
801029cd:	8b 00                	mov    (%eax),%eax
801029cf:	83 e0 06             	and    $0x6,%eax
801029d2:	83 f8 02             	cmp    $0x2,%eax
801029d5:	75 0d                	jne    801029e4 <iderw+0x39>
    panic("iderw: nothing to do");
801029d7:	83 ec 0c             	sub    $0xc,%esp
801029da:	68 75 95 10 80       	push   $0x80109575
801029df:	e8 82 db ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
801029e4:	8b 45 08             	mov    0x8(%ebp),%eax
801029e7:	8b 40 04             	mov    0x4(%eax),%eax
801029ea:	85 c0                	test   %eax,%eax
801029ec:	74 16                	je     80102a04 <iderw+0x59>
801029ee:	a1 58 c6 10 80       	mov    0x8010c658,%eax
801029f3:	85 c0                	test   %eax,%eax
801029f5:	75 0d                	jne    80102a04 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
801029f7:	83 ec 0c             	sub    $0xc,%esp
801029fa:	68 8a 95 10 80       	push   $0x8010958a
801029ff:	e8 62 db ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102a04:	83 ec 0c             	sub    $0xc,%esp
80102a07:	68 20 c6 10 80       	push   $0x8010c620
80102a0c:	e8 12 33 00 00       	call   80105d23 <acquire>
80102a11:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102a14:	8b 45 08             	mov    0x8(%ebp),%eax
80102a17:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102a1e:	c7 45 f4 54 c6 10 80 	movl   $0x8010c654,-0xc(%ebp)
80102a25:	eb 0b                	jmp    80102a32 <iderw+0x87>
80102a27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a2a:	8b 00                	mov    (%eax),%eax
80102a2c:	83 c0 14             	add    $0x14,%eax
80102a2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a35:	8b 00                	mov    (%eax),%eax
80102a37:	85 c0                	test   %eax,%eax
80102a39:	75 ec                	jne    80102a27 <iderw+0x7c>
    ;
  *pp = b;
80102a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a3e:	8b 55 08             	mov    0x8(%ebp),%edx
80102a41:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102a43:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102a48:	3b 45 08             	cmp    0x8(%ebp),%eax
80102a4b:	75 23                	jne    80102a70 <iderw+0xc5>
    idestart(b);
80102a4d:	83 ec 0c             	sub    $0xc,%esp
80102a50:	ff 75 08             	pushl  0x8(%ebp)
80102a53:	e8 20 fd ff ff       	call   80102778 <idestart>
80102a58:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a5b:	eb 13                	jmp    80102a70 <iderw+0xc5>
    sleep(b, &idelock);
80102a5d:	83 ec 08             	sub    $0x8,%esp
80102a60:	68 20 c6 10 80       	push   $0x8010c620
80102a65:	ff 75 08             	pushl  0x8(%ebp)
80102a68:	e8 9c 27 00 00       	call   80105209 <sleep>
80102a6d:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a70:	8b 45 08             	mov    0x8(%ebp),%eax
80102a73:	8b 00                	mov    (%eax),%eax
80102a75:	83 e0 06             	and    $0x6,%eax
80102a78:	83 f8 02             	cmp    $0x2,%eax
80102a7b:	75 e0                	jne    80102a5d <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
80102a7d:	83 ec 0c             	sub    $0xc,%esp
80102a80:	68 20 c6 10 80       	push   $0x8010c620
80102a85:	e8 00 33 00 00       	call   80105d8a <release>
80102a8a:	83 c4 10             	add    $0x10,%esp
}
80102a8d:	90                   	nop
80102a8e:	c9                   	leave  
80102a8f:	c3                   	ret    

80102a90 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102a90:	55                   	push   %ebp
80102a91:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a93:	a1 34 32 11 80       	mov    0x80113234,%eax
80102a98:	8b 55 08             	mov    0x8(%ebp),%edx
80102a9b:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a9d:	a1 34 32 11 80       	mov    0x80113234,%eax
80102aa2:	8b 40 10             	mov    0x10(%eax),%eax
}
80102aa5:	5d                   	pop    %ebp
80102aa6:	c3                   	ret    

80102aa7 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102aa7:	55                   	push   %ebp
80102aa8:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102aaa:	a1 34 32 11 80       	mov    0x80113234,%eax
80102aaf:	8b 55 08             	mov    0x8(%ebp),%edx
80102ab2:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102ab4:	a1 34 32 11 80       	mov    0x80113234,%eax
80102ab9:	8b 55 0c             	mov    0xc(%ebp),%edx
80102abc:	89 50 10             	mov    %edx,0x10(%eax)
}
80102abf:	90                   	nop
80102ac0:	5d                   	pop    %ebp
80102ac1:	c3                   	ret    

80102ac2 <ioapicinit>:

void
ioapicinit(void)
{
80102ac2:	55                   	push   %ebp
80102ac3:	89 e5                	mov    %esp,%ebp
80102ac5:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102ac8:	a1 64 33 11 80       	mov    0x80113364,%eax
80102acd:	85 c0                	test   %eax,%eax
80102acf:	0f 84 a0 00 00 00    	je     80102b75 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102ad5:	c7 05 34 32 11 80 00 	movl   $0xfec00000,0x80113234
80102adc:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102adf:	6a 01                	push   $0x1
80102ae1:	e8 aa ff ff ff       	call   80102a90 <ioapicread>
80102ae6:	83 c4 04             	add    $0x4,%esp
80102ae9:	c1 e8 10             	shr    $0x10,%eax
80102aec:	25 ff 00 00 00       	and    $0xff,%eax
80102af1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102af4:	6a 00                	push   $0x0
80102af6:	e8 95 ff ff ff       	call   80102a90 <ioapicread>
80102afb:	83 c4 04             	add    $0x4,%esp
80102afe:	c1 e8 18             	shr    $0x18,%eax
80102b01:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102b04:	0f b6 05 60 33 11 80 	movzbl 0x80113360,%eax
80102b0b:	0f b6 c0             	movzbl %al,%eax
80102b0e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102b11:	74 10                	je     80102b23 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102b13:	83 ec 0c             	sub    $0xc,%esp
80102b16:	68 a8 95 10 80       	push   $0x801095a8
80102b1b:	e8 a6 d8 ff ff       	call   801003c6 <cprintf>
80102b20:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b23:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102b2a:	eb 3f                	jmp    80102b6b <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b2f:	83 c0 20             	add    $0x20,%eax
80102b32:	0d 00 00 01 00       	or     $0x10000,%eax
80102b37:	89 c2                	mov    %eax,%edx
80102b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b3c:	83 c0 08             	add    $0x8,%eax
80102b3f:	01 c0                	add    %eax,%eax
80102b41:	83 ec 08             	sub    $0x8,%esp
80102b44:	52                   	push   %edx
80102b45:	50                   	push   %eax
80102b46:	e8 5c ff ff ff       	call   80102aa7 <ioapicwrite>
80102b4b:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b51:	83 c0 08             	add    $0x8,%eax
80102b54:	01 c0                	add    %eax,%eax
80102b56:	83 c0 01             	add    $0x1,%eax
80102b59:	83 ec 08             	sub    $0x8,%esp
80102b5c:	6a 00                	push   $0x0
80102b5e:	50                   	push   %eax
80102b5f:	e8 43 ff ff ff       	call   80102aa7 <ioapicwrite>
80102b64:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b67:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b6e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102b71:	7e b9                	jle    80102b2c <ioapicinit+0x6a>
80102b73:	eb 01                	jmp    80102b76 <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102b75:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102b76:	c9                   	leave  
80102b77:	c3                   	ret    

80102b78 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102b78:	55                   	push   %ebp
80102b79:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102b7b:	a1 64 33 11 80       	mov    0x80113364,%eax
80102b80:	85 c0                	test   %eax,%eax
80102b82:	74 39                	je     80102bbd <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102b84:	8b 45 08             	mov    0x8(%ebp),%eax
80102b87:	83 c0 20             	add    $0x20,%eax
80102b8a:	89 c2                	mov    %eax,%edx
80102b8c:	8b 45 08             	mov    0x8(%ebp),%eax
80102b8f:	83 c0 08             	add    $0x8,%eax
80102b92:	01 c0                	add    %eax,%eax
80102b94:	52                   	push   %edx
80102b95:	50                   	push   %eax
80102b96:	e8 0c ff ff ff       	call   80102aa7 <ioapicwrite>
80102b9b:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b9e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ba1:	c1 e0 18             	shl    $0x18,%eax
80102ba4:	89 c2                	mov    %eax,%edx
80102ba6:	8b 45 08             	mov    0x8(%ebp),%eax
80102ba9:	83 c0 08             	add    $0x8,%eax
80102bac:	01 c0                	add    %eax,%eax
80102bae:	83 c0 01             	add    $0x1,%eax
80102bb1:	52                   	push   %edx
80102bb2:	50                   	push   %eax
80102bb3:	e8 ef fe ff ff       	call   80102aa7 <ioapicwrite>
80102bb8:	83 c4 08             	add    $0x8,%esp
80102bbb:	eb 01                	jmp    80102bbe <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102bbd:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102bbe:	c9                   	leave  
80102bbf:	c3                   	ret    

80102bc0 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102bc0:	55                   	push   %ebp
80102bc1:	89 e5                	mov    %esp,%ebp
80102bc3:	8b 45 08             	mov    0x8(%ebp),%eax
80102bc6:	05 00 00 00 80       	add    $0x80000000,%eax
80102bcb:	5d                   	pop    %ebp
80102bcc:	c3                   	ret    

80102bcd <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102bcd:	55                   	push   %ebp
80102bce:	89 e5                	mov    %esp,%ebp
80102bd0:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102bd3:	83 ec 08             	sub    $0x8,%esp
80102bd6:	68 da 95 10 80       	push   $0x801095da
80102bdb:	68 40 32 11 80       	push   $0x80113240
80102be0:	e8 1c 31 00 00       	call   80105d01 <initlock>
80102be5:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102be8:	c7 05 74 32 11 80 00 	movl   $0x0,0x80113274
80102bef:	00 00 00 
  freerange(vstart, vend);
80102bf2:	83 ec 08             	sub    $0x8,%esp
80102bf5:	ff 75 0c             	pushl  0xc(%ebp)
80102bf8:	ff 75 08             	pushl  0x8(%ebp)
80102bfb:	e8 2a 00 00 00       	call   80102c2a <freerange>
80102c00:	83 c4 10             	add    $0x10,%esp
}
80102c03:	90                   	nop
80102c04:	c9                   	leave  
80102c05:	c3                   	ret    

80102c06 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102c06:	55                   	push   %ebp
80102c07:	89 e5                	mov    %esp,%ebp
80102c09:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102c0c:	83 ec 08             	sub    $0x8,%esp
80102c0f:	ff 75 0c             	pushl  0xc(%ebp)
80102c12:	ff 75 08             	pushl  0x8(%ebp)
80102c15:	e8 10 00 00 00       	call   80102c2a <freerange>
80102c1a:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102c1d:	c7 05 74 32 11 80 01 	movl   $0x1,0x80113274
80102c24:	00 00 00 
}
80102c27:	90                   	nop
80102c28:	c9                   	leave  
80102c29:	c3                   	ret    

80102c2a <freerange>:

void
freerange(void *vstart, void *vend)
{
80102c2a:	55                   	push   %ebp
80102c2b:	89 e5                	mov    %esp,%ebp
80102c2d:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102c30:	8b 45 08             	mov    0x8(%ebp),%eax
80102c33:	05 ff 0f 00 00       	add    $0xfff,%eax
80102c38:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102c3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c40:	eb 15                	jmp    80102c57 <freerange+0x2d>
    kfree(p);
80102c42:	83 ec 0c             	sub    $0xc,%esp
80102c45:	ff 75 f4             	pushl  -0xc(%ebp)
80102c48:	e8 1a 00 00 00       	call   80102c67 <kfree>
80102c4d:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c50:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c5a:	05 00 10 00 00       	add    $0x1000,%eax
80102c5f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102c62:	76 de                	jbe    80102c42 <freerange+0x18>
    kfree(p);
}
80102c64:	90                   	nop
80102c65:	c9                   	leave  
80102c66:	c3                   	ret    

80102c67 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102c67:	55                   	push   %ebp
80102c68:	89 e5                	mov    %esp,%ebp
80102c6a:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102c6d:	8b 45 08             	mov    0x8(%ebp),%eax
80102c70:	25 ff 0f 00 00       	and    $0xfff,%eax
80102c75:	85 c0                	test   %eax,%eax
80102c77:	75 1b                	jne    80102c94 <kfree+0x2d>
80102c79:	81 7d 08 5c 67 11 80 	cmpl   $0x8011675c,0x8(%ebp)
80102c80:	72 12                	jb     80102c94 <kfree+0x2d>
80102c82:	ff 75 08             	pushl  0x8(%ebp)
80102c85:	e8 36 ff ff ff       	call   80102bc0 <v2p>
80102c8a:	83 c4 04             	add    $0x4,%esp
80102c8d:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102c92:	76 0d                	jbe    80102ca1 <kfree+0x3a>
    panic("kfree");
80102c94:	83 ec 0c             	sub    $0xc,%esp
80102c97:	68 df 95 10 80       	push   $0x801095df
80102c9c:	e8 c5 d8 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102ca1:	83 ec 04             	sub    $0x4,%esp
80102ca4:	68 00 10 00 00       	push   $0x1000
80102ca9:	6a 01                	push   $0x1
80102cab:	ff 75 08             	pushl  0x8(%ebp)
80102cae:	e8 d3 32 00 00       	call   80105f86 <memset>
80102cb3:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102cb6:	a1 74 32 11 80       	mov    0x80113274,%eax
80102cbb:	85 c0                	test   %eax,%eax
80102cbd:	74 10                	je     80102ccf <kfree+0x68>
    acquire(&kmem.lock);
80102cbf:	83 ec 0c             	sub    $0xc,%esp
80102cc2:	68 40 32 11 80       	push   $0x80113240
80102cc7:	e8 57 30 00 00       	call   80105d23 <acquire>
80102ccc:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102ccf:	8b 45 08             	mov    0x8(%ebp),%eax
80102cd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102cd5:	8b 15 78 32 11 80    	mov    0x80113278,%edx
80102cdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cde:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ce3:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102ce8:	a1 74 32 11 80       	mov    0x80113274,%eax
80102ced:	85 c0                	test   %eax,%eax
80102cef:	74 10                	je     80102d01 <kfree+0x9a>
    release(&kmem.lock);
80102cf1:	83 ec 0c             	sub    $0xc,%esp
80102cf4:	68 40 32 11 80       	push   $0x80113240
80102cf9:	e8 8c 30 00 00       	call   80105d8a <release>
80102cfe:	83 c4 10             	add    $0x10,%esp
}
80102d01:	90                   	nop
80102d02:	c9                   	leave  
80102d03:	c3                   	ret    

80102d04 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102d04:	55                   	push   %ebp
80102d05:	89 e5                	mov    %esp,%ebp
80102d07:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102d0a:	a1 74 32 11 80       	mov    0x80113274,%eax
80102d0f:	85 c0                	test   %eax,%eax
80102d11:	74 10                	je     80102d23 <kalloc+0x1f>
    acquire(&kmem.lock);
80102d13:	83 ec 0c             	sub    $0xc,%esp
80102d16:	68 40 32 11 80       	push   $0x80113240
80102d1b:	e8 03 30 00 00       	call   80105d23 <acquire>
80102d20:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102d23:	a1 78 32 11 80       	mov    0x80113278,%eax
80102d28:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102d2b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102d2f:	74 0a                	je     80102d3b <kalloc+0x37>
    kmem.freelist = r->next;
80102d31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d34:	8b 00                	mov    (%eax),%eax
80102d36:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102d3b:	a1 74 32 11 80       	mov    0x80113274,%eax
80102d40:	85 c0                	test   %eax,%eax
80102d42:	74 10                	je     80102d54 <kalloc+0x50>
    release(&kmem.lock);
80102d44:	83 ec 0c             	sub    $0xc,%esp
80102d47:	68 40 32 11 80       	push   $0x80113240
80102d4c:	e8 39 30 00 00       	call   80105d8a <release>
80102d51:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102d57:	c9                   	leave  
80102d58:	c3                   	ret    

80102d59 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80102d59:	55                   	push   %ebp
80102d5a:	89 e5                	mov    %esp,%ebp
80102d5c:	83 ec 14             	sub    $0x14,%esp
80102d5f:	8b 45 08             	mov    0x8(%ebp),%eax
80102d62:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d66:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102d6a:	89 c2                	mov    %eax,%edx
80102d6c:	ec                   	in     (%dx),%al
80102d6d:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d70:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d74:	c9                   	leave  
80102d75:	c3                   	ret    

80102d76 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102d76:	55                   	push   %ebp
80102d77:	89 e5                	mov    %esp,%ebp
80102d79:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102d7c:	6a 64                	push   $0x64
80102d7e:	e8 d6 ff ff ff       	call   80102d59 <inb>
80102d83:	83 c4 04             	add    $0x4,%esp
80102d86:	0f b6 c0             	movzbl %al,%eax
80102d89:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d8f:	83 e0 01             	and    $0x1,%eax
80102d92:	85 c0                	test   %eax,%eax
80102d94:	75 0a                	jne    80102da0 <kbdgetc+0x2a>
    return -1;
80102d96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d9b:	e9 23 01 00 00       	jmp    80102ec3 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102da0:	6a 60                	push   $0x60
80102da2:	e8 b2 ff ff ff       	call   80102d59 <inb>
80102da7:	83 c4 04             	add    $0x4,%esp
80102daa:	0f b6 c0             	movzbl %al,%eax
80102dad:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102db0:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102db7:	75 17                	jne    80102dd0 <kbdgetc+0x5a>
    shift |= E0ESC;
80102db9:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102dbe:	83 c8 40             	or     $0x40,%eax
80102dc1:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102dc6:	b8 00 00 00 00       	mov    $0x0,%eax
80102dcb:	e9 f3 00 00 00       	jmp    80102ec3 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102dd0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dd3:	25 80 00 00 00       	and    $0x80,%eax
80102dd8:	85 c0                	test   %eax,%eax
80102dda:	74 45                	je     80102e21 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102ddc:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102de1:	83 e0 40             	and    $0x40,%eax
80102de4:	85 c0                	test   %eax,%eax
80102de6:	75 08                	jne    80102df0 <kbdgetc+0x7a>
80102de8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102deb:	83 e0 7f             	and    $0x7f,%eax
80102dee:	eb 03                	jmp    80102df3 <kbdgetc+0x7d>
80102df0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102df3:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102df6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102df9:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102dfe:	0f b6 00             	movzbl (%eax),%eax
80102e01:	83 c8 40             	or     $0x40,%eax
80102e04:	0f b6 c0             	movzbl %al,%eax
80102e07:	f7 d0                	not    %eax
80102e09:	89 c2                	mov    %eax,%edx
80102e0b:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e10:	21 d0                	and    %edx,%eax
80102e12:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102e17:	b8 00 00 00 00       	mov    $0x0,%eax
80102e1c:	e9 a2 00 00 00       	jmp    80102ec3 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102e21:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e26:	83 e0 40             	and    $0x40,%eax
80102e29:	85 c0                	test   %eax,%eax
80102e2b:	74 14                	je     80102e41 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102e2d:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102e34:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e39:	83 e0 bf             	and    $0xffffffbf,%eax
80102e3c:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  }

  shift |= shiftcode[data];
80102e41:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e44:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102e49:	0f b6 00             	movzbl (%eax),%eax
80102e4c:	0f b6 d0             	movzbl %al,%edx
80102e4f:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e54:	09 d0                	or     %edx,%eax
80102e56:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  shift ^= togglecode[data];
80102e5b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e5e:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102e63:	0f b6 00             	movzbl (%eax),%eax
80102e66:	0f b6 d0             	movzbl %al,%edx
80102e69:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e6e:	31 d0                	xor    %edx,%eax
80102e70:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102e75:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e7a:	83 e0 03             	and    $0x3,%eax
80102e7d:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102e84:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e87:	01 d0                	add    %edx,%eax
80102e89:	0f b6 00             	movzbl (%eax),%eax
80102e8c:	0f b6 c0             	movzbl %al,%eax
80102e8f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e92:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e97:	83 e0 08             	and    $0x8,%eax
80102e9a:	85 c0                	test   %eax,%eax
80102e9c:	74 22                	je     80102ec0 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e9e:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102ea2:	76 0c                	jbe    80102eb0 <kbdgetc+0x13a>
80102ea4:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102ea8:	77 06                	ja     80102eb0 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102eaa:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102eae:	eb 10                	jmp    80102ec0 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102eb0:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102eb4:	76 0a                	jbe    80102ec0 <kbdgetc+0x14a>
80102eb6:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102eba:	77 04                	ja     80102ec0 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102ebc:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102ec0:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102ec3:	c9                   	leave  
80102ec4:	c3                   	ret    

80102ec5 <kbdintr>:

void
kbdintr(void)
{
80102ec5:	55                   	push   %ebp
80102ec6:	89 e5                	mov    %esp,%ebp
80102ec8:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102ecb:	83 ec 0c             	sub    $0xc,%esp
80102ece:	68 76 2d 10 80       	push   $0x80102d76
80102ed3:	e8 21 d9 ff ff       	call   801007f9 <consoleintr>
80102ed8:	83 c4 10             	add    $0x10,%esp
}
80102edb:	90                   	nop
80102edc:	c9                   	leave  
80102edd:	c3                   	ret    

80102ede <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80102ede:	55                   	push   %ebp
80102edf:	89 e5                	mov    %esp,%ebp
80102ee1:	83 ec 14             	sub    $0x14,%esp
80102ee4:	8b 45 08             	mov    0x8(%ebp),%eax
80102ee7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102eeb:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102eef:	89 c2                	mov    %eax,%edx
80102ef1:	ec                   	in     (%dx),%al
80102ef2:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102ef5:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102ef9:	c9                   	leave  
80102efa:	c3                   	ret    

80102efb <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102efb:	55                   	push   %ebp
80102efc:	89 e5                	mov    %esp,%ebp
80102efe:	83 ec 08             	sub    $0x8,%esp
80102f01:	8b 55 08             	mov    0x8(%ebp),%edx
80102f04:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f07:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102f0b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102f0e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102f12:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102f16:	ee                   	out    %al,(%dx)
}
80102f17:	90                   	nop
80102f18:	c9                   	leave  
80102f19:	c3                   	ret    

80102f1a <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102f1a:	55                   	push   %ebp
80102f1b:	89 e5                	mov    %esp,%ebp
80102f1d:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102f20:	9c                   	pushf  
80102f21:	58                   	pop    %eax
80102f22:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102f25:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102f28:	c9                   	leave  
80102f29:	c3                   	ret    

80102f2a <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102f2a:	55                   	push   %ebp
80102f2b:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102f2d:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f32:	8b 55 08             	mov    0x8(%ebp),%edx
80102f35:	c1 e2 02             	shl    $0x2,%edx
80102f38:	01 c2                	add    %eax,%edx
80102f3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f3d:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102f3f:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f44:	83 c0 20             	add    $0x20,%eax
80102f47:	8b 00                	mov    (%eax),%eax
}
80102f49:	90                   	nop
80102f4a:	5d                   	pop    %ebp
80102f4b:	c3                   	ret    

80102f4c <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102f4c:	55                   	push   %ebp
80102f4d:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80102f4f:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f54:	85 c0                	test   %eax,%eax
80102f56:	0f 84 0b 01 00 00    	je     80103067 <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102f5c:	68 3f 01 00 00       	push   $0x13f
80102f61:	6a 3c                	push   $0x3c
80102f63:	e8 c2 ff ff ff       	call   80102f2a <lapicw>
80102f68:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102f6b:	6a 0b                	push   $0xb
80102f6d:	68 f8 00 00 00       	push   $0xf8
80102f72:	e8 b3 ff ff ff       	call   80102f2a <lapicw>
80102f77:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102f7a:	68 20 00 02 00       	push   $0x20020
80102f7f:	68 c8 00 00 00       	push   $0xc8
80102f84:	e8 a1 ff ff ff       	call   80102f2a <lapicw>
80102f89:	83 c4 08             	add    $0x8,%esp
  // lapicw(TICR, 10000000); 
  lapicw(TICR, 1000000000/TPS); // PSU CS333. Makes ticks per second programmable
80102f8c:	68 40 42 0f 00       	push   $0xf4240
80102f91:	68 e0 00 00 00       	push   $0xe0
80102f96:	e8 8f ff ff ff       	call   80102f2a <lapicw>
80102f9b:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f9e:	68 00 00 01 00       	push   $0x10000
80102fa3:	68 d4 00 00 00       	push   $0xd4
80102fa8:	e8 7d ff ff ff       	call   80102f2a <lapicw>
80102fad:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102fb0:	68 00 00 01 00       	push   $0x10000
80102fb5:	68 d8 00 00 00       	push   $0xd8
80102fba:	e8 6b ff ff ff       	call   80102f2a <lapicw>
80102fbf:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102fc2:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102fc7:	83 c0 30             	add    $0x30,%eax
80102fca:	8b 00                	mov    (%eax),%eax
80102fcc:	c1 e8 10             	shr    $0x10,%eax
80102fcf:	0f b6 c0             	movzbl %al,%eax
80102fd2:	83 f8 03             	cmp    $0x3,%eax
80102fd5:	76 12                	jbe    80102fe9 <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80102fd7:	68 00 00 01 00       	push   $0x10000
80102fdc:	68 d0 00 00 00       	push   $0xd0
80102fe1:	e8 44 ff ff ff       	call   80102f2a <lapicw>
80102fe6:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102fe9:	6a 33                	push   $0x33
80102feb:	68 dc 00 00 00       	push   $0xdc
80102ff0:	e8 35 ff ff ff       	call   80102f2a <lapicw>
80102ff5:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102ff8:	6a 00                	push   $0x0
80102ffa:	68 a0 00 00 00       	push   $0xa0
80102fff:	e8 26 ff ff ff       	call   80102f2a <lapicw>
80103004:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80103007:	6a 00                	push   $0x0
80103009:	68 a0 00 00 00       	push   $0xa0
8010300e:	e8 17 ff ff ff       	call   80102f2a <lapicw>
80103013:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103016:	6a 00                	push   $0x0
80103018:	6a 2c                	push   $0x2c
8010301a:	e8 0b ff ff ff       	call   80102f2a <lapicw>
8010301f:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103022:	6a 00                	push   $0x0
80103024:	68 c4 00 00 00       	push   $0xc4
80103029:	e8 fc fe ff ff       	call   80102f2a <lapicw>
8010302e:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103031:	68 00 85 08 00       	push   $0x88500
80103036:	68 c0 00 00 00       	push   $0xc0
8010303b:	e8 ea fe ff ff       	call   80102f2a <lapicw>
80103040:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80103043:	90                   	nop
80103044:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80103049:	05 00 03 00 00       	add    $0x300,%eax
8010304e:	8b 00                	mov    (%eax),%eax
80103050:	25 00 10 00 00       	and    $0x1000,%eax
80103055:	85 c0                	test   %eax,%eax
80103057:	75 eb                	jne    80103044 <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80103059:	6a 00                	push   $0x0
8010305b:	6a 20                	push   $0x20
8010305d:	e8 c8 fe ff ff       	call   80102f2a <lapicw>
80103062:	83 c4 08             	add    $0x8,%esp
80103065:	eb 01                	jmp    80103068 <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
80103067:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80103068:	c9                   	leave  
80103069:	c3                   	ret    

8010306a <cpunum>:

int
cpunum(void)
{
8010306a:	55                   	push   %ebp
8010306b:	89 e5                	mov    %esp,%ebp
8010306d:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80103070:	e8 a5 fe ff ff       	call   80102f1a <readeflags>
80103075:	25 00 02 00 00       	and    $0x200,%eax
8010307a:	85 c0                	test   %eax,%eax
8010307c:	74 26                	je     801030a4 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
8010307e:	a1 60 c6 10 80       	mov    0x8010c660,%eax
80103083:	8d 50 01             	lea    0x1(%eax),%edx
80103086:	89 15 60 c6 10 80    	mov    %edx,0x8010c660
8010308c:	85 c0                	test   %eax,%eax
8010308e:	75 14                	jne    801030a4 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80103090:	8b 45 04             	mov    0x4(%ebp),%eax
80103093:	83 ec 08             	sub    $0x8,%esp
80103096:	50                   	push   %eax
80103097:	68 e8 95 10 80       	push   $0x801095e8
8010309c:	e8 25 d3 ff ff       	call   801003c6 <cprintf>
801030a1:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
801030a4:	a1 7c 32 11 80       	mov    0x8011327c,%eax
801030a9:	85 c0                	test   %eax,%eax
801030ab:	74 0f                	je     801030bc <cpunum+0x52>
    return lapic[ID]>>24;
801030ad:	a1 7c 32 11 80       	mov    0x8011327c,%eax
801030b2:	83 c0 20             	add    $0x20,%eax
801030b5:	8b 00                	mov    (%eax),%eax
801030b7:	c1 e8 18             	shr    $0x18,%eax
801030ba:	eb 05                	jmp    801030c1 <cpunum+0x57>
  return 0;
801030bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801030c1:	c9                   	leave  
801030c2:	c3                   	ret    

801030c3 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801030c3:	55                   	push   %ebp
801030c4:	89 e5                	mov    %esp,%ebp
  if(lapic)
801030c6:	a1 7c 32 11 80       	mov    0x8011327c,%eax
801030cb:	85 c0                	test   %eax,%eax
801030cd:	74 0c                	je     801030db <lapiceoi+0x18>
    lapicw(EOI, 0);
801030cf:	6a 00                	push   $0x0
801030d1:	6a 2c                	push   $0x2c
801030d3:	e8 52 fe ff ff       	call   80102f2a <lapicw>
801030d8:	83 c4 08             	add    $0x8,%esp
}
801030db:	90                   	nop
801030dc:	c9                   	leave  
801030dd:	c3                   	ret    

801030de <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801030de:	55                   	push   %ebp
801030df:	89 e5                	mov    %esp,%ebp
}
801030e1:	90                   	nop
801030e2:	5d                   	pop    %ebp
801030e3:	c3                   	ret    

801030e4 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801030e4:	55                   	push   %ebp
801030e5:	89 e5                	mov    %esp,%ebp
801030e7:	83 ec 14             	sub    $0x14,%esp
801030ea:	8b 45 08             	mov    0x8(%ebp),%eax
801030ed:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
801030f0:	6a 0f                	push   $0xf
801030f2:	6a 70                	push   $0x70
801030f4:	e8 02 fe ff ff       	call   80102efb <outb>
801030f9:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
801030fc:	6a 0a                	push   $0xa
801030fe:	6a 71                	push   $0x71
80103100:	e8 f6 fd ff ff       	call   80102efb <outb>
80103105:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103108:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010310f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103112:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103117:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010311a:	83 c0 02             	add    $0x2,%eax
8010311d:	8b 55 0c             	mov    0xc(%ebp),%edx
80103120:	c1 ea 04             	shr    $0x4,%edx
80103123:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103126:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010312a:	c1 e0 18             	shl    $0x18,%eax
8010312d:	50                   	push   %eax
8010312e:	68 c4 00 00 00       	push   $0xc4
80103133:	e8 f2 fd ff ff       	call   80102f2a <lapicw>
80103138:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010313b:	68 00 c5 00 00       	push   $0xc500
80103140:	68 c0 00 00 00       	push   $0xc0
80103145:	e8 e0 fd ff ff       	call   80102f2a <lapicw>
8010314a:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010314d:	68 c8 00 00 00       	push   $0xc8
80103152:	e8 87 ff ff ff       	call   801030de <microdelay>
80103157:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
8010315a:	68 00 85 00 00       	push   $0x8500
8010315f:	68 c0 00 00 00       	push   $0xc0
80103164:	e8 c1 fd ff ff       	call   80102f2a <lapicw>
80103169:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
8010316c:	6a 64                	push   $0x64
8010316e:	e8 6b ff ff ff       	call   801030de <microdelay>
80103173:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103176:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010317d:	eb 3d                	jmp    801031bc <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
8010317f:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103183:	c1 e0 18             	shl    $0x18,%eax
80103186:	50                   	push   %eax
80103187:	68 c4 00 00 00       	push   $0xc4
8010318c:	e8 99 fd ff ff       	call   80102f2a <lapicw>
80103191:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103194:	8b 45 0c             	mov    0xc(%ebp),%eax
80103197:	c1 e8 0c             	shr    $0xc,%eax
8010319a:	80 cc 06             	or     $0x6,%ah
8010319d:	50                   	push   %eax
8010319e:	68 c0 00 00 00       	push   $0xc0
801031a3:	e8 82 fd ff ff       	call   80102f2a <lapicw>
801031a8:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801031ab:	68 c8 00 00 00       	push   $0xc8
801031b0:	e8 29 ff ff ff       	call   801030de <microdelay>
801031b5:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801031b8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801031bc:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801031c0:	7e bd                	jle    8010317f <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801031c2:	90                   	nop
801031c3:	c9                   	leave  
801031c4:	c3                   	ret    

801031c5 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801031c5:	55                   	push   %ebp
801031c6:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
801031c8:	8b 45 08             	mov    0x8(%ebp),%eax
801031cb:	0f b6 c0             	movzbl %al,%eax
801031ce:	50                   	push   %eax
801031cf:	6a 70                	push   $0x70
801031d1:	e8 25 fd ff ff       	call   80102efb <outb>
801031d6:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801031d9:	68 c8 00 00 00       	push   $0xc8
801031de:	e8 fb fe ff ff       	call   801030de <microdelay>
801031e3:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
801031e6:	6a 71                	push   $0x71
801031e8:	e8 f1 fc ff ff       	call   80102ede <inb>
801031ed:	83 c4 04             	add    $0x4,%esp
801031f0:	0f b6 c0             	movzbl %al,%eax
}
801031f3:	c9                   	leave  
801031f4:	c3                   	ret    

801031f5 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801031f5:	55                   	push   %ebp
801031f6:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
801031f8:	6a 00                	push   $0x0
801031fa:	e8 c6 ff ff ff       	call   801031c5 <cmos_read>
801031ff:	83 c4 04             	add    $0x4,%esp
80103202:	89 c2                	mov    %eax,%edx
80103204:	8b 45 08             	mov    0x8(%ebp),%eax
80103207:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
80103209:	6a 02                	push   $0x2
8010320b:	e8 b5 ff ff ff       	call   801031c5 <cmos_read>
80103210:	83 c4 04             	add    $0x4,%esp
80103213:	89 c2                	mov    %eax,%edx
80103215:	8b 45 08             	mov    0x8(%ebp),%eax
80103218:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
8010321b:	6a 04                	push   $0x4
8010321d:	e8 a3 ff ff ff       	call   801031c5 <cmos_read>
80103222:	83 c4 04             	add    $0x4,%esp
80103225:	89 c2                	mov    %eax,%edx
80103227:	8b 45 08             	mov    0x8(%ebp),%eax
8010322a:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
8010322d:	6a 07                	push   $0x7
8010322f:	e8 91 ff ff ff       	call   801031c5 <cmos_read>
80103234:	83 c4 04             	add    $0x4,%esp
80103237:	89 c2                	mov    %eax,%edx
80103239:	8b 45 08             	mov    0x8(%ebp),%eax
8010323c:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
8010323f:	6a 08                	push   $0x8
80103241:	e8 7f ff ff ff       	call   801031c5 <cmos_read>
80103246:	83 c4 04             	add    $0x4,%esp
80103249:	89 c2                	mov    %eax,%edx
8010324b:	8b 45 08             	mov    0x8(%ebp),%eax
8010324e:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
80103251:	6a 09                	push   $0x9
80103253:	e8 6d ff ff ff       	call   801031c5 <cmos_read>
80103258:	83 c4 04             	add    $0x4,%esp
8010325b:	89 c2                	mov    %eax,%edx
8010325d:	8b 45 08             	mov    0x8(%ebp),%eax
80103260:	89 50 14             	mov    %edx,0x14(%eax)
}
80103263:	90                   	nop
80103264:	c9                   	leave  
80103265:	c3                   	ret    

80103266 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80103266:	55                   	push   %ebp
80103267:	89 e5                	mov    %esp,%ebp
80103269:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
8010326c:	6a 0b                	push   $0xb
8010326e:	e8 52 ff ff ff       	call   801031c5 <cmos_read>
80103273:	83 c4 04             	add    $0x4,%esp
80103276:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103279:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010327c:	83 e0 04             	and    $0x4,%eax
8010327f:	85 c0                	test   %eax,%eax
80103281:	0f 94 c0             	sete   %al
80103284:	0f b6 c0             	movzbl %al,%eax
80103287:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
8010328a:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010328d:	50                   	push   %eax
8010328e:	e8 62 ff ff ff       	call   801031f5 <fill_rtcdate>
80103293:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
80103296:	6a 0a                	push   $0xa
80103298:	e8 28 ff ff ff       	call   801031c5 <cmos_read>
8010329d:	83 c4 04             	add    $0x4,%esp
801032a0:	25 80 00 00 00       	and    $0x80,%eax
801032a5:	85 c0                	test   %eax,%eax
801032a7:	75 27                	jne    801032d0 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
801032a9:	8d 45 c0             	lea    -0x40(%ebp),%eax
801032ac:	50                   	push   %eax
801032ad:	e8 43 ff ff ff       	call   801031f5 <fill_rtcdate>
801032b2:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
801032b5:	83 ec 04             	sub    $0x4,%esp
801032b8:	6a 18                	push   $0x18
801032ba:	8d 45 c0             	lea    -0x40(%ebp),%eax
801032bd:	50                   	push   %eax
801032be:	8d 45 d8             	lea    -0x28(%ebp),%eax
801032c1:	50                   	push   %eax
801032c2:	e8 26 2d 00 00       	call   80105fed <memcmp>
801032c7:	83 c4 10             	add    $0x10,%esp
801032ca:	85 c0                	test   %eax,%eax
801032cc:	74 05                	je     801032d3 <cmostime+0x6d>
801032ce:	eb ba                	jmp    8010328a <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
801032d0:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801032d1:	eb b7                	jmp    8010328a <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
801032d3:	90                   	nop
  }

  // convert
  if (bcd) {
801032d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801032d8:	0f 84 b4 00 00 00    	je     80103392 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801032de:	8b 45 d8             	mov    -0x28(%ebp),%eax
801032e1:	c1 e8 04             	shr    $0x4,%eax
801032e4:	89 c2                	mov    %eax,%edx
801032e6:	89 d0                	mov    %edx,%eax
801032e8:	c1 e0 02             	shl    $0x2,%eax
801032eb:	01 d0                	add    %edx,%eax
801032ed:	01 c0                	add    %eax,%eax
801032ef:	89 c2                	mov    %eax,%edx
801032f1:	8b 45 d8             	mov    -0x28(%ebp),%eax
801032f4:	83 e0 0f             	and    $0xf,%eax
801032f7:	01 d0                	add    %edx,%eax
801032f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801032fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
801032ff:	c1 e8 04             	shr    $0x4,%eax
80103302:	89 c2                	mov    %eax,%edx
80103304:	89 d0                	mov    %edx,%eax
80103306:	c1 e0 02             	shl    $0x2,%eax
80103309:	01 d0                	add    %edx,%eax
8010330b:	01 c0                	add    %eax,%eax
8010330d:	89 c2                	mov    %eax,%edx
8010330f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103312:	83 e0 0f             	and    $0xf,%eax
80103315:	01 d0                	add    %edx,%eax
80103317:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010331a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010331d:	c1 e8 04             	shr    $0x4,%eax
80103320:	89 c2                	mov    %eax,%edx
80103322:	89 d0                	mov    %edx,%eax
80103324:	c1 e0 02             	shl    $0x2,%eax
80103327:	01 d0                	add    %edx,%eax
80103329:	01 c0                	add    %eax,%eax
8010332b:	89 c2                	mov    %eax,%edx
8010332d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103330:	83 e0 0f             	and    $0xf,%eax
80103333:	01 d0                	add    %edx,%eax
80103335:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103338:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010333b:	c1 e8 04             	shr    $0x4,%eax
8010333e:	89 c2                	mov    %eax,%edx
80103340:	89 d0                	mov    %edx,%eax
80103342:	c1 e0 02             	shl    $0x2,%eax
80103345:	01 d0                	add    %edx,%eax
80103347:	01 c0                	add    %eax,%eax
80103349:	89 c2                	mov    %eax,%edx
8010334b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010334e:	83 e0 0f             	and    $0xf,%eax
80103351:	01 d0                	add    %edx,%eax
80103353:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103356:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103359:	c1 e8 04             	shr    $0x4,%eax
8010335c:	89 c2                	mov    %eax,%edx
8010335e:	89 d0                	mov    %edx,%eax
80103360:	c1 e0 02             	shl    $0x2,%eax
80103363:	01 d0                	add    %edx,%eax
80103365:	01 c0                	add    %eax,%eax
80103367:	89 c2                	mov    %eax,%edx
80103369:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010336c:	83 e0 0f             	and    $0xf,%eax
8010336f:	01 d0                	add    %edx,%eax
80103371:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103374:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103377:	c1 e8 04             	shr    $0x4,%eax
8010337a:	89 c2                	mov    %eax,%edx
8010337c:	89 d0                	mov    %edx,%eax
8010337e:	c1 e0 02             	shl    $0x2,%eax
80103381:	01 d0                	add    %edx,%eax
80103383:	01 c0                	add    %eax,%eax
80103385:	89 c2                	mov    %eax,%edx
80103387:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010338a:	83 e0 0f             	and    $0xf,%eax
8010338d:	01 d0                	add    %edx,%eax
8010338f:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103392:	8b 45 08             	mov    0x8(%ebp),%eax
80103395:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103398:	89 10                	mov    %edx,(%eax)
8010339a:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010339d:	89 50 04             	mov    %edx,0x4(%eax)
801033a0:	8b 55 e0             	mov    -0x20(%ebp),%edx
801033a3:	89 50 08             	mov    %edx,0x8(%eax)
801033a6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801033a9:	89 50 0c             	mov    %edx,0xc(%eax)
801033ac:	8b 55 e8             	mov    -0x18(%ebp),%edx
801033af:	89 50 10             	mov    %edx,0x10(%eax)
801033b2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801033b5:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801033b8:	8b 45 08             	mov    0x8(%ebp),%eax
801033bb:	8b 40 14             	mov    0x14(%eax),%eax
801033be:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801033c4:	8b 45 08             	mov    0x8(%ebp),%eax
801033c7:	89 50 14             	mov    %edx,0x14(%eax)
}
801033ca:	90                   	nop
801033cb:	c9                   	leave  
801033cc:	c3                   	ret    

801033cd <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801033cd:	55                   	push   %ebp
801033ce:	89 e5                	mov    %esp,%ebp
801033d0:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801033d3:	83 ec 08             	sub    $0x8,%esp
801033d6:	68 14 96 10 80       	push   $0x80109614
801033db:	68 80 32 11 80       	push   $0x80113280
801033e0:	e8 1c 29 00 00       	call   80105d01 <initlock>
801033e5:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
801033e8:	83 ec 08             	sub    $0x8,%esp
801033eb:	8d 45 dc             	lea    -0x24(%ebp),%eax
801033ee:	50                   	push   %eax
801033ef:	ff 75 08             	pushl  0x8(%ebp)
801033f2:	e8 2b e0 ff ff       	call   80101422 <readsb>
801033f7:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
801033fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033fd:	a3 b4 32 11 80       	mov    %eax,0x801132b4
  log.size = sb.nlog;
80103402:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103405:	a3 b8 32 11 80       	mov    %eax,0x801132b8
  log.dev = dev;
8010340a:	8b 45 08             	mov    0x8(%ebp),%eax
8010340d:	a3 c4 32 11 80       	mov    %eax,0x801132c4
  recover_from_log();
80103412:	e8 b2 01 00 00       	call   801035c9 <recover_from_log>
}
80103417:	90                   	nop
80103418:	c9                   	leave  
80103419:	c3                   	ret    

8010341a <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
8010341a:	55                   	push   %ebp
8010341b:	89 e5                	mov    %esp,%ebp
8010341d:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103420:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103427:	e9 95 00 00 00       	jmp    801034c1 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010342c:	8b 15 b4 32 11 80    	mov    0x801132b4,%edx
80103432:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103435:	01 d0                	add    %edx,%eax
80103437:	83 c0 01             	add    $0x1,%eax
8010343a:	89 c2                	mov    %eax,%edx
8010343c:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103441:	83 ec 08             	sub    $0x8,%esp
80103444:	52                   	push   %edx
80103445:	50                   	push   %eax
80103446:	e8 6b cd ff ff       	call   801001b6 <bread>
8010344b:	83 c4 10             	add    $0x10,%esp
8010344e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103451:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103454:	83 c0 10             	add    $0x10,%eax
80103457:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
8010345e:	89 c2                	mov    %eax,%edx
80103460:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103465:	83 ec 08             	sub    $0x8,%esp
80103468:	52                   	push   %edx
80103469:	50                   	push   %eax
8010346a:	e8 47 cd ff ff       	call   801001b6 <bread>
8010346f:	83 c4 10             	add    $0x10,%esp
80103472:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103475:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103478:	8d 50 18             	lea    0x18(%eax),%edx
8010347b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010347e:	83 c0 18             	add    $0x18,%eax
80103481:	83 ec 04             	sub    $0x4,%esp
80103484:	68 00 02 00 00       	push   $0x200
80103489:	52                   	push   %edx
8010348a:	50                   	push   %eax
8010348b:	e8 b5 2b 00 00       	call   80106045 <memmove>
80103490:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103493:	83 ec 0c             	sub    $0xc,%esp
80103496:	ff 75 ec             	pushl  -0x14(%ebp)
80103499:	e8 51 cd ff ff       	call   801001ef <bwrite>
8010349e:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
801034a1:	83 ec 0c             	sub    $0xc,%esp
801034a4:	ff 75 f0             	pushl  -0x10(%ebp)
801034a7:	e8 82 cd ff ff       	call   8010022e <brelse>
801034ac:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801034af:	83 ec 0c             	sub    $0xc,%esp
801034b2:	ff 75 ec             	pushl  -0x14(%ebp)
801034b5:	e8 74 cd ff ff       	call   8010022e <brelse>
801034ba:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801034bd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034c1:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801034c6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034c9:	0f 8f 5d ff ff ff    	jg     8010342c <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
801034cf:	90                   	nop
801034d0:	c9                   	leave  
801034d1:	c3                   	ret    

801034d2 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801034d2:	55                   	push   %ebp
801034d3:	89 e5                	mov    %esp,%ebp
801034d5:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801034d8:	a1 b4 32 11 80       	mov    0x801132b4,%eax
801034dd:	89 c2                	mov    %eax,%edx
801034df:	a1 c4 32 11 80       	mov    0x801132c4,%eax
801034e4:	83 ec 08             	sub    $0x8,%esp
801034e7:	52                   	push   %edx
801034e8:	50                   	push   %eax
801034e9:	e8 c8 cc ff ff       	call   801001b6 <bread>
801034ee:	83 c4 10             	add    $0x10,%esp
801034f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801034f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034f7:	83 c0 18             	add    $0x18,%eax
801034fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801034fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103500:	8b 00                	mov    (%eax),%eax
80103502:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  for (i = 0; i < log.lh.n; i++) {
80103507:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010350e:	eb 1b                	jmp    8010352b <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103510:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103513:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103516:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010351a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010351d:	83 c2 10             	add    $0x10,%edx
80103520:	89 04 95 8c 32 11 80 	mov    %eax,-0x7feecd74(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103527:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010352b:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103530:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103533:	7f db                	jg     80103510 <read_head+0x3e>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103535:	83 ec 0c             	sub    $0xc,%esp
80103538:	ff 75 f0             	pushl  -0x10(%ebp)
8010353b:	e8 ee cc ff ff       	call   8010022e <brelse>
80103540:	83 c4 10             	add    $0x10,%esp
}
80103543:	90                   	nop
80103544:	c9                   	leave  
80103545:	c3                   	ret    

80103546 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103546:	55                   	push   %ebp
80103547:	89 e5                	mov    %esp,%ebp
80103549:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010354c:	a1 b4 32 11 80       	mov    0x801132b4,%eax
80103551:	89 c2                	mov    %eax,%edx
80103553:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103558:	83 ec 08             	sub    $0x8,%esp
8010355b:	52                   	push   %edx
8010355c:	50                   	push   %eax
8010355d:	e8 54 cc ff ff       	call   801001b6 <bread>
80103562:	83 c4 10             	add    $0x10,%esp
80103565:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103568:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010356b:	83 c0 18             	add    $0x18,%eax
8010356e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103571:	8b 15 c8 32 11 80    	mov    0x801132c8,%edx
80103577:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010357a:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010357c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103583:	eb 1b                	jmp    801035a0 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80103585:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103588:	83 c0 10             	add    $0x10,%eax
8010358b:	8b 0c 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%ecx
80103592:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103595:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103598:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
8010359c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801035a0:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801035a5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801035a8:	7f db                	jg     80103585 <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
801035aa:	83 ec 0c             	sub    $0xc,%esp
801035ad:	ff 75 f0             	pushl  -0x10(%ebp)
801035b0:	e8 3a cc ff ff       	call   801001ef <bwrite>
801035b5:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801035b8:	83 ec 0c             	sub    $0xc,%esp
801035bb:	ff 75 f0             	pushl  -0x10(%ebp)
801035be:	e8 6b cc ff ff       	call   8010022e <brelse>
801035c3:	83 c4 10             	add    $0x10,%esp
}
801035c6:	90                   	nop
801035c7:	c9                   	leave  
801035c8:	c3                   	ret    

801035c9 <recover_from_log>:

static void
recover_from_log(void)
{
801035c9:	55                   	push   %ebp
801035ca:	89 e5                	mov    %esp,%ebp
801035cc:	83 ec 08             	sub    $0x8,%esp
  read_head();      
801035cf:	e8 fe fe ff ff       	call   801034d2 <read_head>
  install_trans(); // if committed, copy from log to disk
801035d4:	e8 41 fe ff ff       	call   8010341a <install_trans>
  log.lh.n = 0;
801035d9:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
801035e0:	00 00 00 
  write_head(); // clear the log
801035e3:	e8 5e ff ff ff       	call   80103546 <write_head>
}
801035e8:	90                   	nop
801035e9:	c9                   	leave  
801035ea:	c3                   	ret    

801035eb <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801035eb:	55                   	push   %ebp
801035ec:	89 e5                	mov    %esp,%ebp
801035ee:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
801035f1:	83 ec 0c             	sub    $0xc,%esp
801035f4:	68 80 32 11 80       	push   $0x80113280
801035f9:	e8 25 27 00 00       	call   80105d23 <acquire>
801035fe:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103601:	a1 c0 32 11 80       	mov    0x801132c0,%eax
80103606:	85 c0                	test   %eax,%eax
80103608:	74 17                	je     80103621 <begin_op+0x36>
      sleep(&log, &log.lock);
8010360a:	83 ec 08             	sub    $0x8,%esp
8010360d:	68 80 32 11 80       	push   $0x80113280
80103612:	68 80 32 11 80       	push   $0x80113280
80103617:	e8 ed 1b 00 00       	call   80105209 <sleep>
8010361c:	83 c4 10             	add    $0x10,%esp
8010361f:	eb e0                	jmp    80103601 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103621:	8b 0d c8 32 11 80    	mov    0x801132c8,%ecx
80103627:	a1 bc 32 11 80       	mov    0x801132bc,%eax
8010362c:	8d 50 01             	lea    0x1(%eax),%edx
8010362f:	89 d0                	mov    %edx,%eax
80103631:	c1 e0 02             	shl    $0x2,%eax
80103634:	01 d0                	add    %edx,%eax
80103636:	01 c0                	add    %eax,%eax
80103638:	01 c8                	add    %ecx,%eax
8010363a:	83 f8 1e             	cmp    $0x1e,%eax
8010363d:	7e 17                	jle    80103656 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010363f:	83 ec 08             	sub    $0x8,%esp
80103642:	68 80 32 11 80       	push   $0x80113280
80103647:	68 80 32 11 80       	push   $0x80113280
8010364c:	e8 b8 1b 00 00       	call   80105209 <sleep>
80103651:	83 c4 10             	add    $0x10,%esp
80103654:	eb ab                	jmp    80103601 <begin_op+0x16>
    } else {
      log.outstanding += 1;
80103656:	a1 bc 32 11 80       	mov    0x801132bc,%eax
8010365b:	83 c0 01             	add    $0x1,%eax
8010365e:	a3 bc 32 11 80       	mov    %eax,0x801132bc
      release(&log.lock);
80103663:	83 ec 0c             	sub    $0xc,%esp
80103666:	68 80 32 11 80       	push   $0x80113280
8010366b:	e8 1a 27 00 00       	call   80105d8a <release>
80103670:	83 c4 10             	add    $0x10,%esp
      break;
80103673:	90                   	nop
    }
  }
}
80103674:	90                   	nop
80103675:	c9                   	leave  
80103676:	c3                   	ret    

80103677 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103677:	55                   	push   %ebp
80103678:	89 e5                	mov    %esp,%ebp
8010367a:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
8010367d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103684:	83 ec 0c             	sub    $0xc,%esp
80103687:	68 80 32 11 80       	push   $0x80113280
8010368c:	e8 92 26 00 00       	call   80105d23 <acquire>
80103691:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103694:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103699:	83 e8 01             	sub    $0x1,%eax
8010369c:	a3 bc 32 11 80       	mov    %eax,0x801132bc
  if(log.committing)
801036a1:	a1 c0 32 11 80       	mov    0x801132c0,%eax
801036a6:	85 c0                	test   %eax,%eax
801036a8:	74 0d                	je     801036b7 <end_op+0x40>
    panic("log.committing");
801036aa:	83 ec 0c             	sub    $0xc,%esp
801036ad:	68 18 96 10 80       	push   $0x80109618
801036b2:	e8 af ce ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
801036b7:	a1 bc 32 11 80       	mov    0x801132bc,%eax
801036bc:	85 c0                	test   %eax,%eax
801036be:	75 13                	jne    801036d3 <end_op+0x5c>
    do_commit = 1;
801036c0:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801036c7:	c7 05 c0 32 11 80 01 	movl   $0x1,0x801132c0
801036ce:	00 00 00 
801036d1:	eb 10                	jmp    801036e3 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
801036d3:	83 ec 0c             	sub    $0xc,%esp
801036d6:	68 80 32 11 80       	push   $0x80113280
801036db:	e8 70 1c 00 00       	call   80105350 <wakeup>
801036e0:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801036e3:	83 ec 0c             	sub    $0xc,%esp
801036e6:	68 80 32 11 80       	push   $0x80113280
801036eb:	e8 9a 26 00 00       	call   80105d8a <release>
801036f0:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
801036f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801036f7:	74 3f                	je     80103738 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801036f9:	e8 f5 00 00 00       	call   801037f3 <commit>
    acquire(&log.lock);
801036fe:	83 ec 0c             	sub    $0xc,%esp
80103701:	68 80 32 11 80       	push   $0x80113280
80103706:	e8 18 26 00 00       	call   80105d23 <acquire>
8010370b:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010370e:	c7 05 c0 32 11 80 00 	movl   $0x0,0x801132c0
80103715:	00 00 00 
    wakeup(&log);
80103718:	83 ec 0c             	sub    $0xc,%esp
8010371b:	68 80 32 11 80       	push   $0x80113280
80103720:	e8 2b 1c 00 00       	call   80105350 <wakeup>
80103725:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103728:	83 ec 0c             	sub    $0xc,%esp
8010372b:	68 80 32 11 80       	push   $0x80113280
80103730:	e8 55 26 00 00       	call   80105d8a <release>
80103735:	83 c4 10             	add    $0x10,%esp
  }
}
80103738:	90                   	nop
80103739:	c9                   	leave  
8010373a:	c3                   	ret    

8010373b <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
8010373b:	55                   	push   %ebp
8010373c:	89 e5                	mov    %esp,%ebp
8010373e:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103741:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103748:	e9 95 00 00 00       	jmp    801037e2 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010374d:	8b 15 b4 32 11 80    	mov    0x801132b4,%edx
80103753:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103756:	01 d0                	add    %edx,%eax
80103758:	83 c0 01             	add    $0x1,%eax
8010375b:	89 c2                	mov    %eax,%edx
8010375d:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103762:	83 ec 08             	sub    $0x8,%esp
80103765:	52                   	push   %edx
80103766:	50                   	push   %eax
80103767:	e8 4a ca ff ff       	call   801001b6 <bread>
8010376c:	83 c4 10             	add    $0x10,%esp
8010376f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103772:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103775:	83 c0 10             	add    $0x10,%eax
80103778:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
8010377f:	89 c2                	mov    %eax,%edx
80103781:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103786:	83 ec 08             	sub    $0x8,%esp
80103789:	52                   	push   %edx
8010378a:	50                   	push   %eax
8010378b:	e8 26 ca ff ff       	call   801001b6 <bread>
80103790:	83 c4 10             	add    $0x10,%esp
80103793:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103796:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103799:	8d 50 18             	lea    0x18(%eax),%edx
8010379c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010379f:	83 c0 18             	add    $0x18,%eax
801037a2:	83 ec 04             	sub    $0x4,%esp
801037a5:	68 00 02 00 00       	push   $0x200
801037aa:	52                   	push   %edx
801037ab:	50                   	push   %eax
801037ac:	e8 94 28 00 00       	call   80106045 <memmove>
801037b1:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801037b4:	83 ec 0c             	sub    $0xc,%esp
801037b7:	ff 75 f0             	pushl  -0x10(%ebp)
801037ba:	e8 30 ca ff ff       	call   801001ef <bwrite>
801037bf:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
801037c2:	83 ec 0c             	sub    $0xc,%esp
801037c5:	ff 75 ec             	pushl  -0x14(%ebp)
801037c8:	e8 61 ca ff ff       	call   8010022e <brelse>
801037cd:	83 c4 10             	add    $0x10,%esp
    brelse(to);
801037d0:	83 ec 0c             	sub    $0xc,%esp
801037d3:	ff 75 f0             	pushl  -0x10(%ebp)
801037d6:	e8 53 ca ff ff       	call   8010022e <brelse>
801037db:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801037de:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037e2:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801037e7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037ea:	0f 8f 5d ff ff ff    	jg     8010374d <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
801037f0:	90                   	nop
801037f1:	c9                   	leave  
801037f2:	c3                   	ret    

801037f3 <commit>:

static void
commit()
{
801037f3:	55                   	push   %ebp
801037f4:	89 e5                	mov    %esp,%ebp
801037f6:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801037f9:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801037fe:	85 c0                	test   %eax,%eax
80103800:	7e 1e                	jle    80103820 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103802:	e8 34 ff ff ff       	call   8010373b <write_log>
    write_head();    // Write header to disk -- the real commit
80103807:	e8 3a fd ff ff       	call   80103546 <write_head>
    install_trans(); // Now install writes to home locations
8010380c:	e8 09 fc ff ff       	call   8010341a <install_trans>
    log.lh.n = 0; 
80103811:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
80103818:	00 00 00 
    write_head();    // Erase the transaction from the log
8010381b:	e8 26 fd ff ff       	call   80103546 <write_head>
  }
}
80103820:	90                   	nop
80103821:	c9                   	leave  
80103822:	c3                   	ret    

80103823 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103823:	55                   	push   %ebp
80103824:	89 e5                	mov    %esp,%ebp
80103826:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103829:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010382e:	83 f8 1d             	cmp    $0x1d,%eax
80103831:	7f 12                	jg     80103845 <log_write+0x22>
80103833:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103838:	8b 15 b8 32 11 80    	mov    0x801132b8,%edx
8010383e:	83 ea 01             	sub    $0x1,%edx
80103841:	39 d0                	cmp    %edx,%eax
80103843:	7c 0d                	jl     80103852 <log_write+0x2f>
    panic("too big a transaction");
80103845:	83 ec 0c             	sub    $0xc,%esp
80103848:	68 27 96 10 80       	push   $0x80109627
8010384d:	e8 14 cd ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
80103852:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103857:	85 c0                	test   %eax,%eax
80103859:	7f 0d                	jg     80103868 <log_write+0x45>
    panic("log_write outside of trans");
8010385b:	83 ec 0c             	sub    $0xc,%esp
8010385e:	68 3d 96 10 80       	push   $0x8010963d
80103863:	e8 fe cc ff ff       	call   80100566 <panic>

  acquire(&log.lock);
80103868:	83 ec 0c             	sub    $0xc,%esp
8010386b:	68 80 32 11 80       	push   $0x80113280
80103870:	e8 ae 24 00 00       	call   80105d23 <acquire>
80103875:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103878:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010387f:	eb 1d                	jmp    8010389e <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103881:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103884:	83 c0 10             	add    $0x10,%eax
80103887:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
8010388e:	89 c2                	mov    %eax,%edx
80103890:	8b 45 08             	mov    0x8(%ebp),%eax
80103893:	8b 40 08             	mov    0x8(%eax),%eax
80103896:	39 c2                	cmp    %eax,%edx
80103898:	74 10                	je     801038aa <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
8010389a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010389e:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801038a3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038a6:	7f d9                	jg     80103881 <log_write+0x5e>
801038a8:	eb 01                	jmp    801038ab <log_write+0x88>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
801038aa:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801038ab:	8b 45 08             	mov    0x8(%ebp),%eax
801038ae:	8b 40 08             	mov    0x8(%eax),%eax
801038b1:	89 c2                	mov    %eax,%edx
801038b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038b6:	83 c0 10             	add    $0x10,%eax
801038b9:	89 14 85 8c 32 11 80 	mov    %edx,-0x7feecd74(,%eax,4)
  if (i == log.lh.n)
801038c0:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801038c5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038c8:	75 0d                	jne    801038d7 <log_write+0xb4>
    log.lh.n++;
801038ca:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801038cf:	83 c0 01             	add    $0x1,%eax
801038d2:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  b->flags |= B_DIRTY; // prevent eviction
801038d7:	8b 45 08             	mov    0x8(%ebp),%eax
801038da:	8b 00                	mov    (%eax),%eax
801038dc:	83 c8 04             	or     $0x4,%eax
801038df:	89 c2                	mov    %eax,%edx
801038e1:	8b 45 08             	mov    0x8(%ebp),%eax
801038e4:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801038e6:	83 ec 0c             	sub    $0xc,%esp
801038e9:	68 80 32 11 80       	push   $0x80113280
801038ee:	e8 97 24 00 00       	call   80105d8a <release>
801038f3:	83 c4 10             	add    $0x10,%esp
}
801038f6:	90                   	nop
801038f7:	c9                   	leave  
801038f8:	c3                   	ret    

801038f9 <v2p>:
801038f9:	55                   	push   %ebp
801038fa:	89 e5                	mov    %esp,%ebp
801038fc:	8b 45 08             	mov    0x8(%ebp),%eax
801038ff:	05 00 00 00 80       	add    $0x80000000,%eax
80103904:	5d                   	pop    %ebp
80103905:	c3                   	ret    

80103906 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103906:	55                   	push   %ebp
80103907:	89 e5                	mov    %esp,%ebp
80103909:	8b 45 08             	mov    0x8(%ebp),%eax
8010390c:	05 00 00 00 80       	add    $0x80000000,%eax
80103911:	5d                   	pop    %ebp
80103912:	c3                   	ret    

80103913 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103913:	55                   	push   %ebp
80103914:	89 e5                	mov    %esp,%ebp
80103916:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103919:	8b 55 08             	mov    0x8(%ebp),%edx
8010391c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010391f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103922:	f0 87 02             	lock xchg %eax,(%edx)
80103925:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103928:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010392b:	c9                   	leave  
8010392c:	c3                   	ret    

8010392d <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010392d:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103931:	83 e4 f0             	and    $0xfffffff0,%esp
80103934:	ff 71 fc             	pushl  -0x4(%ecx)
80103937:	55                   	push   %ebp
80103938:	89 e5                	mov    %esp,%ebp
8010393a:	51                   	push   %ecx
8010393b:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010393e:	83 ec 08             	sub    $0x8,%esp
80103941:	68 00 00 40 80       	push   $0x80400000
80103946:	68 5c 67 11 80       	push   $0x8011675c
8010394b:	e8 7d f2 ff ff       	call   80102bcd <kinit1>
80103950:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103953:	e8 d0 52 00 00       	call   80108c28 <kvmalloc>
  mpinit();        // collect info about this machine
80103958:	e8 43 04 00 00       	call   80103da0 <mpinit>
  lapicinit();
8010395d:	e8 ea f5 ff ff       	call   80102f4c <lapicinit>
  seginit();       // set up segments
80103962:	e8 6a 4c 00 00       	call   801085d1 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103967:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010396d:	0f b6 00             	movzbl (%eax),%eax
80103970:	0f b6 c0             	movzbl %al,%eax
80103973:	83 ec 08             	sub    $0x8,%esp
80103976:	50                   	push   %eax
80103977:	68 58 96 10 80       	push   $0x80109658
8010397c:	e8 45 ca ff ff       	call   801003c6 <cprintf>
80103981:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
80103984:	e8 6d 06 00 00       	call   80103ff6 <picinit>
  ioapicinit();    // another interrupt controller
80103989:	e8 34 f1 ff ff       	call   80102ac2 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010398e:	e8 24 d2 ff ff       	call   80100bb7 <consoleinit>
  uartinit();      // serial port
80103993:	e8 95 3f 00 00       	call   8010792d <uartinit>
  pinit();         // process table
80103998:	e8 5d 0b 00 00       	call   801044fa <pinit>
  tvinit();        // trap vectors
8010399d:	e8 64 3b 00 00       	call   80107506 <tvinit>
  binit();         // buffer cache
801039a2:	e8 8d c6 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801039a7:	e8 67 d6 ff ff       	call   80101013 <fileinit>
  ideinit();       // disk
801039ac:	e8 19 ed ff ff       	call   801026ca <ideinit>
  if(!ismp)
801039b1:	a1 64 33 11 80       	mov    0x80113364,%eax
801039b6:	85 c0                	test   %eax,%eax
801039b8:	75 05                	jne    801039bf <main+0x92>
    timerinit();   // uniprocessor timer
801039ba:	e8 98 3a 00 00       	call   80107457 <timerinit>
  startothers();   // start other processors
801039bf:	e8 7f 00 00 00       	call   80103a43 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801039c4:	83 ec 08             	sub    $0x8,%esp
801039c7:	68 00 00 00 8e       	push   $0x8e000000
801039cc:	68 00 00 40 80       	push   $0x80400000
801039d1:	e8 30 f2 ff ff       	call   80102c06 <kinit2>
801039d6:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
801039d9:	e8 b0 0c 00 00       	call   8010468e <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
801039de:	e8 1a 00 00 00       	call   801039fd <mpmain>

801039e3 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801039e3:	55                   	push   %ebp
801039e4:	89 e5                	mov    %esp,%ebp
801039e6:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
801039e9:	e8 52 52 00 00       	call   80108c40 <switchkvm>
  seginit();
801039ee:	e8 de 4b 00 00       	call   801085d1 <seginit>
  lapicinit();
801039f3:	e8 54 f5 ff ff       	call   80102f4c <lapicinit>
  mpmain();
801039f8:	e8 00 00 00 00       	call   801039fd <mpmain>

801039fd <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801039fd:	55                   	push   %ebp
801039fe:	89 e5                	mov    %esp,%ebp
80103a00:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103a03:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103a09:	0f b6 00             	movzbl (%eax),%eax
80103a0c:	0f b6 c0             	movzbl %al,%eax
80103a0f:	83 ec 08             	sub    $0x8,%esp
80103a12:	50                   	push   %eax
80103a13:	68 6f 96 10 80       	push   $0x8010966f
80103a18:	e8 a9 c9 ff ff       	call   801003c6 <cprintf>
80103a1d:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103a20:	e8 42 3c 00 00       	call   80107667 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103a25:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103a2b:	05 a8 00 00 00       	add    $0xa8,%eax
80103a30:	83 ec 08             	sub    $0x8,%esp
80103a33:	6a 01                	push   $0x1
80103a35:	50                   	push   %eax
80103a36:	e8 d8 fe ff ff       	call   80103913 <xchg>
80103a3b:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103a3e:	e8 07 15 00 00       	call   80104f4a <scheduler>

80103a43 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103a43:	55                   	push   %ebp
80103a44:	89 e5                	mov    %esp,%ebp
80103a46:	53                   	push   %ebx
80103a47:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103a4a:	68 00 70 00 00       	push   $0x7000
80103a4f:	e8 b2 fe ff ff       	call   80103906 <p2v>
80103a54:	83 c4 04             	add    $0x4,%esp
80103a57:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103a5a:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103a5f:	83 ec 04             	sub    $0x4,%esp
80103a62:	50                   	push   %eax
80103a63:	68 2c c5 10 80       	push   $0x8010c52c
80103a68:	ff 75 f0             	pushl  -0x10(%ebp)
80103a6b:	e8 d5 25 00 00       	call   80106045 <memmove>
80103a70:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103a73:	c7 45 f4 80 33 11 80 	movl   $0x80113380,-0xc(%ebp)
80103a7a:	e9 90 00 00 00       	jmp    80103b0f <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
80103a7f:	e8 e6 f5 ff ff       	call   8010306a <cpunum>
80103a84:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103a8a:	05 80 33 11 80       	add    $0x80113380,%eax
80103a8f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a92:	74 73                	je     80103b07 <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103a94:	e8 6b f2 ff ff       	call   80102d04 <kalloc>
80103a99:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103a9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a9f:	83 e8 04             	sub    $0x4,%eax
80103aa2:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103aa5:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103aab:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103aad:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ab0:	83 e8 08             	sub    $0x8,%eax
80103ab3:	c7 00 e3 39 10 80    	movl   $0x801039e3,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103abc:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103abf:	83 ec 0c             	sub    $0xc,%esp
80103ac2:	68 00 b0 10 80       	push   $0x8010b000
80103ac7:	e8 2d fe ff ff       	call   801038f9 <v2p>
80103acc:	83 c4 10             	add    $0x10,%esp
80103acf:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103ad1:	83 ec 0c             	sub    $0xc,%esp
80103ad4:	ff 75 f0             	pushl  -0x10(%ebp)
80103ad7:	e8 1d fe ff ff       	call   801038f9 <v2p>
80103adc:	83 c4 10             	add    $0x10,%esp
80103adf:	89 c2                	mov    %eax,%edx
80103ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae4:	0f b6 00             	movzbl (%eax),%eax
80103ae7:	0f b6 c0             	movzbl %al,%eax
80103aea:	83 ec 08             	sub    $0x8,%esp
80103aed:	52                   	push   %edx
80103aee:	50                   	push   %eax
80103aef:	e8 f0 f5 ff ff       	call   801030e4 <lapicstartap>
80103af4:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103af7:	90                   	nop
80103af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103afb:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103b01:	85 c0                	test   %eax,%eax
80103b03:	74 f3                	je     80103af8 <startothers+0xb5>
80103b05:	eb 01                	jmp    80103b08 <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103b07:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103b08:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103b0f:	a1 60 39 11 80       	mov    0x80113960,%eax
80103b14:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103b1a:	05 80 33 11 80       	add    $0x80113380,%eax
80103b1f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b22:	0f 87 57 ff ff ff    	ja     80103a7f <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103b28:	90                   	nop
80103b29:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b2c:	c9                   	leave  
80103b2d:	c3                   	ret    

80103b2e <p2v>:
80103b2e:	55                   	push   %ebp
80103b2f:	89 e5                	mov    %esp,%ebp
80103b31:	8b 45 08             	mov    0x8(%ebp),%eax
80103b34:	05 00 00 00 80       	add    $0x80000000,%eax
80103b39:	5d                   	pop    %ebp
80103b3a:	c3                   	ret    

80103b3b <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80103b3b:	55                   	push   %ebp
80103b3c:	89 e5                	mov    %esp,%ebp
80103b3e:	83 ec 14             	sub    $0x14,%esp
80103b41:	8b 45 08             	mov    0x8(%ebp),%eax
80103b44:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103b48:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103b4c:	89 c2                	mov    %eax,%edx
80103b4e:	ec                   	in     (%dx),%al
80103b4f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103b52:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103b56:	c9                   	leave  
80103b57:	c3                   	ret    

80103b58 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103b58:	55                   	push   %ebp
80103b59:	89 e5                	mov    %esp,%ebp
80103b5b:	83 ec 08             	sub    $0x8,%esp
80103b5e:	8b 55 08             	mov    0x8(%ebp),%edx
80103b61:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b64:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103b68:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103b6b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103b6f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103b73:	ee                   	out    %al,(%dx)
}
80103b74:	90                   	nop
80103b75:	c9                   	leave  
80103b76:	c3                   	ret    

80103b77 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103b77:	55                   	push   %ebp
80103b78:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103b7a:	a1 64 c6 10 80       	mov    0x8010c664,%eax
80103b7f:	89 c2                	mov    %eax,%edx
80103b81:	b8 80 33 11 80       	mov    $0x80113380,%eax
80103b86:	29 c2                	sub    %eax,%edx
80103b88:	89 d0                	mov    %edx,%eax
80103b8a:	c1 f8 02             	sar    $0x2,%eax
80103b8d:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103b93:	5d                   	pop    %ebp
80103b94:	c3                   	ret    

80103b95 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103b95:	55                   	push   %ebp
80103b96:	89 e5                	mov    %esp,%ebp
80103b98:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103b9b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103ba2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103ba9:	eb 15                	jmp    80103bc0 <sum+0x2b>
    sum += addr[i];
80103bab:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103bae:	8b 45 08             	mov    0x8(%ebp),%eax
80103bb1:	01 d0                	add    %edx,%eax
80103bb3:	0f b6 00             	movzbl (%eax),%eax
80103bb6:	0f b6 c0             	movzbl %al,%eax
80103bb9:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103bbc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103bc0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103bc3:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103bc6:	7c e3                	jl     80103bab <sum+0x16>
    sum += addr[i];
  return sum;
80103bc8:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103bcb:	c9                   	leave  
80103bcc:	c3                   	ret    

80103bcd <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103bcd:	55                   	push   %ebp
80103bce:	89 e5                	mov    %esp,%ebp
80103bd0:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103bd3:	ff 75 08             	pushl  0x8(%ebp)
80103bd6:	e8 53 ff ff ff       	call   80103b2e <p2v>
80103bdb:	83 c4 04             	add    $0x4,%esp
80103bde:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103be1:	8b 55 0c             	mov    0xc(%ebp),%edx
80103be4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103be7:	01 d0                	add    %edx,%eax
80103be9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103bec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bef:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103bf2:	eb 36                	jmp    80103c2a <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103bf4:	83 ec 04             	sub    $0x4,%esp
80103bf7:	6a 04                	push   $0x4
80103bf9:	68 80 96 10 80       	push   $0x80109680
80103bfe:	ff 75 f4             	pushl  -0xc(%ebp)
80103c01:	e8 e7 23 00 00       	call   80105fed <memcmp>
80103c06:	83 c4 10             	add    $0x10,%esp
80103c09:	85 c0                	test   %eax,%eax
80103c0b:	75 19                	jne    80103c26 <mpsearch1+0x59>
80103c0d:	83 ec 08             	sub    $0x8,%esp
80103c10:	6a 10                	push   $0x10
80103c12:	ff 75 f4             	pushl  -0xc(%ebp)
80103c15:	e8 7b ff ff ff       	call   80103b95 <sum>
80103c1a:	83 c4 10             	add    $0x10,%esp
80103c1d:	84 c0                	test   %al,%al
80103c1f:	75 05                	jne    80103c26 <mpsearch1+0x59>
      return (struct mp*)p;
80103c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c24:	eb 11                	jmp    80103c37 <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103c26:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c2d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103c30:	72 c2                	jb     80103bf4 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103c32:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103c37:	c9                   	leave  
80103c38:	c3                   	ret    

80103c39 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103c39:	55                   	push   %ebp
80103c3a:	89 e5                	mov    %esp,%ebp
80103c3c:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103c3f:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103c46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c49:	83 c0 0f             	add    $0xf,%eax
80103c4c:	0f b6 00             	movzbl (%eax),%eax
80103c4f:	0f b6 c0             	movzbl %al,%eax
80103c52:	c1 e0 08             	shl    $0x8,%eax
80103c55:	89 c2                	mov    %eax,%edx
80103c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c5a:	83 c0 0e             	add    $0xe,%eax
80103c5d:	0f b6 00             	movzbl (%eax),%eax
80103c60:	0f b6 c0             	movzbl %al,%eax
80103c63:	09 d0                	or     %edx,%eax
80103c65:	c1 e0 04             	shl    $0x4,%eax
80103c68:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c6b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c6f:	74 21                	je     80103c92 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103c71:	83 ec 08             	sub    $0x8,%esp
80103c74:	68 00 04 00 00       	push   $0x400
80103c79:	ff 75 f0             	pushl  -0x10(%ebp)
80103c7c:	e8 4c ff ff ff       	call   80103bcd <mpsearch1>
80103c81:	83 c4 10             	add    $0x10,%esp
80103c84:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c87:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c8b:	74 51                	je     80103cde <mpsearch+0xa5>
      return mp;
80103c8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c90:	eb 61                	jmp    80103cf3 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103c92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c95:	83 c0 14             	add    $0x14,%eax
80103c98:	0f b6 00             	movzbl (%eax),%eax
80103c9b:	0f b6 c0             	movzbl %al,%eax
80103c9e:	c1 e0 08             	shl    $0x8,%eax
80103ca1:	89 c2                	mov    %eax,%edx
80103ca3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca6:	83 c0 13             	add    $0x13,%eax
80103ca9:	0f b6 00             	movzbl (%eax),%eax
80103cac:	0f b6 c0             	movzbl %al,%eax
80103caf:	09 d0                	or     %edx,%eax
80103cb1:	c1 e0 0a             	shl    $0xa,%eax
80103cb4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103cb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cba:	2d 00 04 00 00       	sub    $0x400,%eax
80103cbf:	83 ec 08             	sub    $0x8,%esp
80103cc2:	68 00 04 00 00       	push   $0x400
80103cc7:	50                   	push   %eax
80103cc8:	e8 00 ff ff ff       	call   80103bcd <mpsearch1>
80103ccd:	83 c4 10             	add    $0x10,%esp
80103cd0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103cd3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103cd7:	74 05                	je     80103cde <mpsearch+0xa5>
      return mp;
80103cd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103cdc:	eb 15                	jmp    80103cf3 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103cde:	83 ec 08             	sub    $0x8,%esp
80103ce1:	68 00 00 01 00       	push   $0x10000
80103ce6:	68 00 00 0f 00       	push   $0xf0000
80103ceb:	e8 dd fe ff ff       	call   80103bcd <mpsearch1>
80103cf0:	83 c4 10             	add    $0x10,%esp
}
80103cf3:	c9                   	leave  
80103cf4:	c3                   	ret    

80103cf5 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103cf5:	55                   	push   %ebp
80103cf6:	89 e5                	mov    %esp,%ebp
80103cf8:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103cfb:	e8 39 ff ff ff       	call   80103c39 <mpsearch>
80103d00:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d03:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d07:	74 0a                	je     80103d13 <mpconfig+0x1e>
80103d09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d0c:	8b 40 04             	mov    0x4(%eax),%eax
80103d0f:	85 c0                	test   %eax,%eax
80103d11:	75 0a                	jne    80103d1d <mpconfig+0x28>
    return 0;
80103d13:	b8 00 00 00 00       	mov    $0x0,%eax
80103d18:	e9 81 00 00 00       	jmp    80103d9e <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103d1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d20:	8b 40 04             	mov    0x4(%eax),%eax
80103d23:	83 ec 0c             	sub    $0xc,%esp
80103d26:	50                   	push   %eax
80103d27:	e8 02 fe ff ff       	call   80103b2e <p2v>
80103d2c:	83 c4 10             	add    $0x10,%esp
80103d2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103d32:	83 ec 04             	sub    $0x4,%esp
80103d35:	6a 04                	push   $0x4
80103d37:	68 85 96 10 80       	push   $0x80109685
80103d3c:	ff 75 f0             	pushl  -0x10(%ebp)
80103d3f:	e8 a9 22 00 00       	call   80105fed <memcmp>
80103d44:	83 c4 10             	add    $0x10,%esp
80103d47:	85 c0                	test   %eax,%eax
80103d49:	74 07                	je     80103d52 <mpconfig+0x5d>
    return 0;
80103d4b:	b8 00 00 00 00       	mov    $0x0,%eax
80103d50:	eb 4c                	jmp    80103d9e <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103d52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d55:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103d59:	3c 01                	cmp    $0x1,%al
80103d5b:	74 12                	je     80103d6f <mpconfig+0x7a>
80103d5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d60:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103d64:	3c 04                	cmp    $0x4,%al
80103d66:	74 07                	je     80103d6f <mpconfig+0x7a>
    return 0;
80103d68:	b8 00 00 00 00       	mov    $0x0,%eax
80103d6d:	eb 2f                	jmp    80103d9e <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80103d6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d72:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103d76:	0f b7 c0             	movzwl %ax,%eax
80103d79:	83 ec 08             	sub    $0x8,%esp
80103d7c:	50                   	push   %eax
80103d7d:	ff 75 f0             	pushl  -0x10(%ebp)
80103d80:	e8 10 fe ff ff       	call   80103b95 <sum>
80103d85:	83 c4 10             	add    $0x10,%esp
80103d88:	84 c0                	test   %al,%al
80103d8a:	74 07                	je     80103d93 <mpconfig+0x9e>
    return 0;
80103d8c:	b8 00 00 00 00       	mov    $0x0,%eax
80103d91:	eb 0b                	jmp    80103d9e <mpconfig+0xa9>
  *pmp = mp;
80103d93:	8b 45 08             	mov    0x8(%ebp),%eax
80103d96:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d99:	89 10                	mov    %edx,(%eax)
  return conf;
80103d9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103d9e:	c9                   	leave  
80103d9f:	c3                   	ret    

80103da0 <mpinit>:

void
mpinit(void)
{
80103da0:	55                   	push   %ebp
80103da1:	89 e5                	mov    %esp,%ebp
80103da3:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103da6:	c7 05 64 c6 10 80 80 	movl   $0x80113380,0x8010c664
80103dad:	33 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103db0:	83 ec 0c             	sub    $0xc,%esp
80103db3:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103db6:	50                   	push   %eax
80103db7:	e8 39 ff ff ff       	call   80103cf5 <mpconfig>
80103dbc:	83 c4 10             	add    $0x10,%esp
80103dbf:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103dc2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103dc6:	0f 84 96 01 00 00    	je     80103f62 <mpinit+0x1c2>
    return;
  ismp = 1;
80103dcc:	c7 05 64 33 11 80 01 	movl   $0x1,0x80113364
80103dd3:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103dd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dd9:	8b 40 24             	mov    0x24(%eax),%eax
80103ddc:	a3 7c 32 11 80       	mov    %eax,0x8011327c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103de1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103de4:	83 c0 2c             	add    $0x2c,%eax
80103de7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103dea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ded:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103df1:	0f b7 d0             	movzwl %ax,%edx
80103df4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103df7:	01 d0                	add    %edx,%eax
80103df9:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103dfc:	e9 f2 00 00 00       	jmp    80103ef3 <mpinit+0x153>
    switch(*p){
80103e01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e04:	0f b6 00             	movzbl (%eax),%eax
80103e07:	0f b6 c0             	movzbl %al,%eax
80103e0a:	83 f8 04             	cmp    $0x4,%eax
80103e0d:	0f 87 bc 00 00 00    	ja     80103ecf <mpinit+0x12f>
80103e13:	8b 04 85 c8 96 10 80 	mov    -0x7fef6938(,%eax,4),%eax
80103e1a:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e1f:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103e22:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e25:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e29:	0f b6 d0             	movzbl %al,%edx
80103e2c:	a1 60 39 11 80       	mov    0x80113960,%eax
80103e31:	39 c2                	cmp    %eax,%edx
80103e33:	74 2b                	je     80103e60 <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103e35:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e38:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e3c:	0f b6 d0             	movzbl %al,%edx
80103e3f:	a1 60 39 11 80       	mov    0x80113960,%eax
80103e44:	83 ec 04             	sub    $0x4,%esp
80103e47:	52                   	push   %edx
80103e48:	50                   	push   %eax
80103e49:	68 8a 96 10 80       	push   $0x8010968a
80103e4e:	e8 73 c5 ff ff       	call   801003c6 <cprintf>
80103e53:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103e56:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
80103e5d:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103e60:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e63:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103e67:	0f b6 c0             	movzbl %al,%eax
80103e6a:	83 e0 02             	and    $0x2,%eax
80103e6d:	85 c0                	test   %eax,%eax
80103e6f:	74 15                	je     80103e86 <mpinit+0xe6>
        bcpu = &cpus[ncpu];
80103e71:	a1 60 39 11 80       	mov    0x80113960,%eax
80103e76:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103e7c:	05 80 33 11 80       	add    $0x80113380,%eax
80103e81:	a3 64 c6 10 80       	mov    %eax,0x8010c664
      cpus[ncpu].id = ncpu;
80103e86:	a1 60 39 11 80       	mov    0x80113960,%eax
80103e8b:	8b 15 60 39 11 80    	mov    0x80113960,%edx
80103e91:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103e97:	05 80 33 11 80       	add    $0x80113380,%eax
80103e9c:	88 10                	mov    %dl,(%eax)
      ncpu++;
80103e9e:	a1 60 39 11 80       	mov    0x80113960,%eax
80103ea3:	83 c0 01             	add    $0x1,%eax
80103ea6:	a3 60 39 11 80       	mov    %eax,0x80113960
      p += sizeof(struct mpproc);
80103eab:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103eaf:	eb 42                	jmp    80103ef3 <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103eb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eb4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103eb7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103eba:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103ebe:	a2 60 33 11 80       	mov    %al,0x80113360
      p += sizeof(struct mpioapic);
80103ec3:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103ec7:	eb 2a                	jmp    80103ef3 <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103ec9:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103ecd:	eb 24                	jmp    80103ef3 <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ed2:	0f b6 00             	movzbl (%eax),%eax
80103ed5:	0f b6 c0             	movzbl %al,%eax
80103ed8:	83 ec 08             	sub    $0x8,%esp
80103edb:	50                   	push   %eax
80103edc:	68 a8 96 10 80       	push   $0x801096a8
80103ee1:	e8 e0 c4 ff ff       	call   801003c6 <cprintf>
80103ee6:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103ee9:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
80103ef0:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103ef3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ef6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103ef9:	0f 82 02 ff ff ff    	jb     80103e01 <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103eff:	a1 64 33 11 80       	mov    0x80113364,%eax
80103f04:	85 c0                	test   %eax,%eax
80103f06:	75 1d                	jne    80103f25 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103f08:	c7 05 60 39 11 80 01 	movl   $0x1,0x80113960
80103f0f:	00 00 00 
    lapic = 0;
80103f12:	c7 05 7c 32 11 80 00 	movl   $0x0,0x8011327c
80103f19:	00 00 00 
    ioapicid = 0;
80103f1c:	c6 05 60 33 11 80 00 	movb   $0x0,0x80113360
    return;
80103f23:	eb 3e                	jmp    80103f63 <mpinit+0x1c3>
  }

  if(mp->imcrp){
80103f25:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f28:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103f2c:	84 c0                	test   %al,%al
80103f2e:	74 33                	je     80103f63 <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103f30:	83 ec 08             	sub    $0x8,%esp
80103f33:	6a 70                	push   $0x70
80103f35:	6a 22                	push   $0x22
80103f37:	e8 1c fc ff ff       	call   80103b58 <outb>
80103f3c:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103f3f:	83 ec 0c             	sub    $0xc,%esp
80103f42:	6a 23                	push   $0x23
80103f44:	e8 f2 fb ff ff       	call   80103b3b <inb>
80103f49:	83 c4 10             	add    $0x10,%esp
80103f4c:	83 c8 01             	or     $0x1,%eax
80103f4f:	0f b6 c0             	movzbl %al,%eax
80103f52:	83 ec 08             	sub    $0x8,%esp
80103f55:	50                   	push   %eax
80103f56:	6a 23                	push   $0x23
80103f58:	e8 fb fb ff ff       	call   80103b58 <outb>
80103f5d:	83 c4 10             	add    $0x10,%esp
80103f60:	eb 01                	jmp    80103f63 <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103f62:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103f63:	c9                   	leave  
80103f64:	c3                   	ret    

80103f65 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103f65:	55                   	push   %ebp
80103f66:	89 e5                	mov    %esp,%ebp
80103f68:	83 ec 08             	sub    $0x8,%esp
80103f6b:	8b 55 08             	mov    0x8(%ebp),%edx
80103f6e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f71:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103f75:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103f78:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103f7c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103f80:	ee                   	out    %al,(%dx)
}
80103f81:	90                   	nop
80103f82:	c9                   	leave  
80103f83:	c3                   	ret    

80103f84 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103f84:	55                   	push   %ebp
80103f85:	89 e5                	mov    %esp,%ebp
80103f87:	83 ec 04             	sub    $0x4,%esp
80103f8a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f8d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103f91:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f95:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80103f9b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f9f:	0f b6 c0             	movzbl %al,%eax
80103fa2:	50                   	push   %eax
80103fa3:	6a 21                	push   $0x21
80103fa5:	e8 bb ff ff ff       	call   80103f65 <outb>
80103faa:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80103fad:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103fb1:	66 c1 e8 08          	shr    $0x8,%ax
80103fb5:	0f b6 c0             	movzbl %al,%eax
80103fb8:	50                   	push   %eax
80103fb9:	68 a1 00 00 00       	push   $0xa1
80103fbe:	e8 a2 ff ff ff       	call   80103f65 <outb>
80103fc3:	83 c4 08             	add    $0x8,%esp
}
80103fc6:	90                   	nop
80103fc7:	c9                   	leave  
80103fc8:	c3                   	ret    

80103fc9 <picenable>:

void
picenable(int irq)
{
80103fc9:	55                   	push   %ebp
80103fca:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80103fcc:	8b 45 08             	mov    0x8(%ebp),%eax
80103fcf:	ba 01 00 00 00       	mov    $0x1,%edx
80103fd4:	89 c1                	mov    %eax,%ecx
80103fd6:	d3 e2                	shl    %cl,%edx
80103fd8:	89 d0                	mov    %edx,%eax
80103fda:	f7 d0                	not    %eax
80103fdc:	89 c2                	mov    %eax,%edx
80103fde:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103fe5:	21 d0                	and    %edx,%eax
80103fe7:	0f b7 c0             	movzwl %ax,%eax
80103fea:	50                   	push   %eax
80103feb:	e8 94 ff ff ff       	call   80103f84 <picsetmask>
80103ff0:	83 c4 04             	add    $0x4,%esp
}
80103ff3:	90                   	nop
80103ff4:	c9                   	leave  
80103ff5:	c3                   	ret    

80103ff6 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103ff6:	55                   	push   %ebp
80103ff7:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103ff9:	68 ff 00 00 00       	push   $0xff
80103ffe:	6a 21                	push   $0x21
80104000:	e8 60 ff ff ff       	call   80103f65 <outb>
80104005:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80104008:	68 ff 00 00 00       	push   $0xff
8010400d:	68 a1 00 00 00       	push   $0xa1
80104012:	e8 4e ff ff ff       	call   80103f65 <outb>
80104017:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
8010401a:	6a 11                	push   $0x11
8010401c:	6a 20                	push   $0x20
8010401e:	e8 42 ff ff ff       	call   80103f65 <outb>
80104023:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80104026:	6a 20                	push   $0x20
80104028:	6a 21                	push   $0x21
8010402a:	e8 36 ff ff ff       	call   80103f65 <outb>
8010402f:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80104032:	6a 04                	push   $0x4
80104034:	6a 21                	push   $0x21
80104036:	e8 2a ff ff ff       	call   80103f65 <outb>
8010403b:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
8010403e:	6a 03                	push   $0x3
80104040:	6a 21                	push   $0x21
80104042:	e8 1e ff ff ff       	call   80103f65 <outb>
80104047:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
8010404a:	6a 11                	push   $0x11
8010404c:	68 a0 00 00 00       	push   $0xa0
80104051:	e8 0f ff ff ff       	call   80103f65 <outb>
80104056:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80104059:	6a 28                	push   $0x28
8010405b:	68 a1 00 00 00       	push   $0xa1
80104060:	e8 00 ff ff ff       	call   80103f65 <outb>
80104065:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80104068:	6a 02                	push   $0x2
8010406a:	68 a1 00 00 00       	push   $0xa1
8010406f:	e8 f1 fe ff ff       	call   80103f65 <outb>
80104074:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80104077:	6a 03                	push   $0x3
80104079:	68 a1 00 00 00       	push   $0xa1
8010407e:	e8 e2 fe ff ff       	call   80103f65 <outb>
80104083:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80104086:	6a 68                	push   $0x68
80104088:	6a 20                	push   $0x20
8010408a:	e8 d6 fe ff ff       	call   80103f65 <outb>
8010408f:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80104092:	6a 0a                	push   $0xa
80104094:	6a 20                	push   $0x20
80104096:	e8 ca fe ff ff       	call   80103f65 <outb>
8010409b:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
8010409e:	6a 68                	push   $0x68
801040a0:	68 a0 00 00 00       	push   $0xa0
801040a5:	e8 bb fe ff ff       	call   80103f65 <outb>
801040aa:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
801040ad:	6a 0a                	push   $0xa
801040af:	68 a0 00 00 00       	push   $0xa0
801040b4:	e8 ac fe ff ff       	call   80103f65 <outb>
801040b9:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
801040bc:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
801040c3:	66 83 f8 ff          	cmp    $0xffff,%ax
801040c7:	74 13                	je     801040dc <picinit+0xe6>
    picsetmask(irqmask);
801040c9:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
801040d0:	0f b7 c0             	movzwl %ax,%eax
801040d3:	50                   	push   %eax
801040d4:	e8 ab fe ff ff       	call   80103f84 <picsetmask>
801040d9:	83 c4 04             	add    $0x4,%esp
}
801040dc:	90                   	nop
801040dd:	c9                   	leave  
801040de:	c3                   	ret    

801040df <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801040df:	55                   	push   %ebp
801040e0:	89 e5                	mov    %esp,%ebp
801040e2:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
801040e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
801040ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801040ef:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801040f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801040f8:	8b 10                	mov    (%eax),%edx
801040fa:	8b 45 08             	mov    0x8(%ebp),%eax
801040fd:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801040ff:	e8 2d cf ff ff       	call   80101031 <filealloc>
80104104:	89 c2                	mov    %eax,%edx
80104106:	8b 45 08             	mov    0x8(%ebp),%eax
80104109:	89 10                	mov    %edx,(%eax)
8010410b:	8b 45 08             	mov    0x8(%ebp),%eax
8010410e:	8b 00                	mov    (%eax),%eax
80104110:	85 c0                	test   %eax,%eax
80104112:	0f 84 cb 00 00 00    	je     801041e3 <pipealloc+0x104>
80104118:	e8 14 cf ff ff       	call   80101031 <filealloc>
8010411d:	89 c2                	mov    %eax,%edx
8010411f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104122:	89 10                	mov    %edx,(%eax)
80104124:	8b 45 0c             	mov    0xc(%ebp),%eax
80104127:	8b 00                	mov    (%eax),%eax
80104129:	85 c0                	test   %eax,%eax
8010412b:	0f 84 b2 00 00 00    	je     801041e3 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104131:	e8 ce eb ff ff       	call   80102d04 <kalloc>
80104136:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104139:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010413d:	0f 84 9f 00 00 00    	je     801041e2 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
80104143:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104146:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010414d:	00 00 00 
  p->writeopen = 1;
80104150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104153:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
8010415a:	00 00 00 
  p->nwrite = 0;
8010415d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104160:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104167:	00 00 00 
  p->nread = 0;
8010416a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010416d:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104174:	00 00 00 
  initlock(&p->lock, "pipe");
80104177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010417a:	83 ec 08             	sub    $0x8,%esp
8010417d:	68 dc 96 10 80       	push   $0x801096dc
80104182:	50                   	push   %eax
80104183:	e8 79 1b 00 00       	call   80105d01 <initlock>
80104188:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
8010418b:	8b 45 08             	mov    0x8(%ebp),%eax
8010418e:	8b 00                	mov    (%eax),%eax
80104190:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104196:	8b 45 08             	mov    0x8(%ebp),%eax
80104199:	8b 00                	mov    (%eax),%eax
8010419b:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010419f:	8b 45 08             	mov    0x8(%ebp),%eax
801041a2:	8b 00                	mov    (%eax),%eax
801041a4:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801041a8:	8b 45 08             	mov    0x8(%ebp),%eax
801041ab:	8b 00                	mov    (%eax),%eax
801041ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041b0:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
801041b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801041b6:	8b 00                	mov    (%eax),%eax
801041b8:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801041be:	8b 45 0c             	mov    0xc(%ebp),%eax
801041c1:	8b 00                	mov    (%eax),%eax
801041c3:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801041c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801041ca:	8b 00                	mov    (%eax),%eax
801041cc:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801041d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801041d3:	8b 00                	mov    (%eax),%eax
801041d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041d8:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801041db:	b8 00 00 00 00       	mov    $0x0,%eax
801041e0:	eb 4e                	jmp    80104230 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
801041e2:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
801041e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801041e7:	74 0e                	je     801041f7 <pipealloc+0x118>
    kfree((char*)p);
801041e9:	83 ec 0c             	sub    $0xc,%esp
801041ec:	ff 75 f4             	pushl  -0xc(%ebp)
801041ef:	e8 73 ea ff ff       	call   80102c67 <kfree>
801041f4:	83 c4 10             	add    $0x10,%esp
  if(*f0)
801041f7:	8b 45 08             	mov    0x8(%ebp),%eax
801041fa:	8b 00                	mov    (%eax),%eax
801041fc:	85 c0                	test   %eax,%eax
801041fe:	74 11                	je     80104211 <pipealloc+0x132>
    fileclose(*f0);
80104200:	8b 45 08             	mov    0x8(%ebp),%eax
80104203:	8b 00                	mov    (%eax),%eax
80104205:	83 ec 0c             	sub    $0xc,%esp
80104208:	50                   	push   %eax
80104209:	e8 e1 ce ff ff       	call   801010ef <fileclose>
8010420e:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104211:	8b 45 0c             	mov    0xc(%ebp),%eax
80104214:	8b 00                	mov    (%eax),%eax
80104216:	85 c0                	test   %eax,%eax
80104218:	74 11                	je     8010422b <pipealloc+0x14c>
    fileclose(*f1);
8010421a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010421d:	8b 00                	mov    (%eax),%eax
8010421f:	83 ec 0c             	sub    $0xc,%esp
80104222:	50                   	push   %eax
80104223:	e8 c7 ce ff ff       	call   801010ef <fileclose>
80104228:	83 c4 10             	add    $0x10,%esp
  return -1;
8010422b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104230:	c9                   	leave  
80104231:	c3                   	ret    

80104232 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104232:	55                   	push   %ebp
80104233:	89 e5                	mov    %esp,%ebp
80104235:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80104238:	8b 45 08             	mov    0x8(%ebp),%eax
8010423b:	83 ec 0c             	sub    $0xc,%esp
8010423e:	50                   	push   %eax
8010423f:	e8 df 1a 00 00       	call   80105d23 <acquire>
80104244:	83 c4 10             	add    $0x10,%esp
  if(writable){
80104247:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010424b:	74 23                	je     80104270 <pipeclose+0x3e>
    p->writeopen = 0;
8010424d:	8b 45 08             	mov    0x8(%ebp),%eax
80104250:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104257:	00 00 00 
    wakeup(&p->nread);
8010425a:	8b 45 08             	mov    0x8(%ebp),%eax
8010425d:	05 34 02 00 00       	add    $0x234,%eax
80104262:	83 ec 0c             	sub    $0xc,%esp
80104265:	50                   	push   %eax
80104266:	e8 e5 10 00 00       	call   80105350 <wakeup>
8010426b:	83 c4 10             	add    $0x10,%esp
8010426e:	eb 21                	jmp    80104291 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80104270:	8b 45 08             	mov    0x8(%ebp),%eax
80104273:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010427a:	00 00 00 
    wakeup(&p->nwrite);
8010427d:	8b 45 08             	mov    0x8(%ebp),%eax
80104280:	05 38 02 00 00       	add    $0x238,%eax
80104285:	83 ec 0c             	sub    $0xc,%esp
80104288:	50                   	push   %eax
80104289:	e8 c2 10 00 00       	call   80105350 <wakeup>
8010428e:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104291:	8b 45 08             	mov    0x8(%ebp),%eax
80104294:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010429a:	85 c0                	test   %eax,%eax
8010429c:	75 2c                	jne    801042ca <pipeclose+0x98>
8010429e:	8b 45 08             	mov    0x8(%ebp),%eax
801042a1:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801042a7:	85 c0                	test   %eax,%eax
801042a9:	75 1f                	jne    801042ca <pipeclose+0x98>
    release(&p->lock);
801042ab:	8b 45 08             	mov    0x8(%ebp),%eax
801042ae:	83 ec 0c             	sub    $0xc,%esp
801042b1:	50                   	push   %eax
801042b2:	e8 d3 1a 00 00       	call   80105d8a <release>
801042b7:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
801042ba:	83 ec 0c             	sub    $0xc,%esp
801042bd:	ff 75 08             	pushl  0x8(%ebp)
801042c0:	e8 a2 e9 ff ff       	call   80102c67 <kfree>
801042c5:	83 c4 10             	add    $0x10,%esp
801042c8:	eb 0f                	jmp    801042d9 <pipeclose+0xa7>
  } else
    release(&p->lock);
801042ca:	8b 45 08             	mov    0x8(%ebp),%eax
801042cd:	83 ec 0c             	sub    $0xc,%esp
801042d0:	50                   	push   %eax
801042d1:	e8 b4 1a 00 00       	call   80105d8a <release>
801042d6:	83 c4 10             	add    $0x10,%esp
}
801042d9:	90                   	nop
801042da:	c9                   	leave  
801042db:	c3                   	ret    

801042dc <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801042dc:	55                   	push   %ebp
801042dd:	89 e5                	mov    %esp,%ebp
801042df:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
801042e2:	8b 45 08             	mov    0x8(%ebp),%eax
801042e5:	83 ec 0c             	sub    $0xc,%esp
801042e8:	50                   	push   %eax
801042e9:	e8 35 1a 00 00       	call   80105d23 <acquire>
801042ee:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
801042f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042f8:	e9 ad 00 00 00       	jmp    801043aa <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
801042fd:	8b 45 08             	mov    0x8(%ebp),%eax
80104300:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104306:	85 c0                	test   %eax,%eax
80104308:	74 0d                	je     80104317 <pipewrite+0x3b>
8010430a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104310:	8b 40 24             	mov    0x24(%eax),%eax
80104313:	85 c0                	test   %eax,%eax
80104315:	74 19                	je     80104330 <pipewrite+0x54>
        release(&p->lock);
80104317:	8b 45 08             	mov    0x8(%ebp),%eax
8010431a:	83 ec 0c             	sub    $0xc,%esp
8010431d:	50                   	push   %eax
8010431e:	e8 67 1a 00 00       	call   80105d8a <release>
80104323:	83 c4 10             	add    $0x10,%esp
        return -1;
80104326:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010432b:	e9 a8 00 00 00       	jmp    801043d8 <pipewrite+0xfc>
      }
      wakeup(&p->nread);
80104330:	8b 45 08             	mov    0x8(%ebp),%eax
80104333:	05 34 02 00 00       	add    $0x234,%eax
80104338:	83 ec 0c             	sub    $0xc,%esp
8010433b:	50                   	push   %eax
8010433c:	e8 0f 10 00 00       	call   80105350 <wakeup>
80104341:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104344:	8b 45 08             	mov    0x8(%ebp),%eax
80104347:	8b 55 08             	mov    0x8(%ebp),%edx
8010434a:	81 c2 38 02 00 00    	add    $0x238,%edx
80104350:	83 ec 08             	sub    $0x8,%esp
80104353:	50                   	push   %eax
80104354:	52                   	push   %edx
80104355:	e8 af 0e 00 00       	call   80105209 <sleep>
8010435a:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010435d:	8b 45 08             	mov    0x8(%ebp),%eax
80104360:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104366:	8b 45 08             	mov    0x8(%ebp),%eax
80104369:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010436f:	05 00 02 00 00       	add    $0x200,%eax
80104374:	39 c2                	cmp    %eax,%edx
80104376:	74 85                	je     801042fd <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104378:	8b 45 08             	mov    0x8(%ebp),%eax
8010437b:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104381:	8d 48 01             	lea    0x1(%eax),%ecx
80104384:	8b 55 08             	mov    0x8(%ebp),%edx
80104387:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010438d:	25 ff 01 00 00       	and    $0x1ff,%eax
80104392:	89 c1                	mov    %eax,%ecx
80104394:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104397:	8b 45 0c             	mov    0xc(%ebp),%eax
8010439a:	01 d0                	add    %edx,%eax
8010439c:	0f b6 10             	movzbl (%eax),%edx
8010439f:	8b 45 08             	mov    0x8(%ebp),%eax
801043a2:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801043a6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801043aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ad:	3b 45 10             	cmp    0x10(%ebp),%eax
801043b0:	7c ab                	jl     8010435d <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801043b2:	8b 45 08             	mov    0x8(%ebp),%eax
801043b5:	05 34 02 00 00       	add    $0x234,%eax
801043ba:	83 ec 0c             	sub    $0xc,%esp
801043bd:	50                   	push   %eax
801043be:	e8 8d 0f 00 00       	call   80105350 <wakeup>
801043c3:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801043c6:	8b 45 08             	mov    0x8(%ebp),%eax
801043c9:	83 ec 0c             	sub    $0xc,%esp
801043cc:	50                   	push   %eax
801043cd:	e8 b8 19 00 00       	call   80105d8a <release>
801043d2:	83 c4 10             	add    $0x10,%esp
  return n;
801043d5:	8b 45 10             	mov    0x10(%ebp),%eax
}
801043d8:	c9                   	leave  
801043d9:	c3                   	ret    

801043da <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801043da:	55                   	push   %ebp
801043db:	89 e5                	mov    %esp,%ebp
801043dd:	53                   	push   %ebx
801043de:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801043e1:	8b 45 08             	mov    0x8(%ebp),%eax
801043e4:	83 ec 0c             	sub    $0xc,%esp
801043e7:	50                   	push   %eax
801043e8:	e8 36 19 00 00       	call   80105d23 <acquire>
801043ed:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801043f0:	eb 3f                	jmp    80104431 <piperead+0x57>
    if(proc->killed){
801043f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801043f8:	8b 40 24             	mov    0x24(%eax),%eax
801043fb:	85 c0                	test   %eax,%eax
801043fd:	74 19                	je     80104418 <piperead+0x3e>
      release(&p->lock);
801043ff:	8b 45 08             	mov    0x8(%ebp),%eax
80104402:	83 ec 0c             	sub    $0xc,%esp
80104405:	50                   	push   %eax
80104406:	e8 7f 19 00 00       	call   80105d8a <release>
8010440b:	83 c4 10             	add    $0x10,%esp
      return -1;
8010440e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104413:	e9 bf 00 00 00       	jmp    801044d7 <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104418:	8b 45 08             	mov    0x8(%ebp),%eax
8010441b:	8b 55 08             	mov    0x8(%ebp),%edx
8010441e:	81 c2 34 02 00 00    	add    $0x234,%edx
80104424:	83 ec 08             	sub    $0x8,%esp
80104427:	50                   	push   %eax
80104428:	52                   	push   %edx
80104429:	e8 db 0d 00 00       	call   80105209 <sleep>
8010442e:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104431:	8b 45 08             	mov    0x8(%ebp),%eax
80104434:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010443a:	8b 45 08             	mov    0x8(%ebp),%eax
8010443d:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104443:	39 c2                	cmp    %eax,%edx
80104445:	75 0d                	jne    80104454 <piperead+0x7a>
80104447:	8b 45 08             	mov    0x8(%ebp),%eax
8010444a:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104450:	85 c0                	test   %eax,%eax
80104452:	75 9e                	jne    801043f2 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104454:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010445b:	eb 49                	jmp    801044a6 <piperead+0xcc>
    if(p->nread == p->nwrite)
8010445d:	8b 45 08             	mov    0x8(%ebp),%eax
80104460:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104466:	8b 45 08             	mov    0x8(%ebp),%eax
80104469:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010446f:	39 c2                	cmp    %eax,%edx
80104471:	74 3d                	je     801044b0 <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104473:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104476:	8b 45 0c             	mov    0xc(%ebp),%eax
80104479:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010447c:	8b 45 08             	mov    0x8(%ebp),%eax
8010447f:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104485:	8d 48 01             	lea    0x1(%eax),%ecx
80104488:	8b 55 08             	mov    0x8(%ebp),%edx
8010448b:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104491:	25 ff 01 00 00       	and    $0x1ff,%eax
80104496:	89 c2                	mov    %eax,%edx
80104498:	8b 45 08             	mov    0x8(%ebp),%eax
8010449b:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
801044a0:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801044a2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801044a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a9:	3b 45 10             	cmp    0x10(%ebp),%eax
801044ac:	7c af                	jl     8010445d <piperead+0x83>
801044ae:	eb 01                	jmp    801044b1 <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
801044b0:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801044b1:	8b 45 08             	mov    0x8(%ebp),%eax
801044b4:	05 38 02 00 00       	add    $0x238,%eax
801044b9:	83 ec 0c             	sub    $0xc,%esp
801044bc:	50                   	push   %eax
801044bd:	e8 8e 0e 00 00       	call   80105350 <wakeup>
801044c2:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801044c5:	8b 45 08             	mov    0x8(%ebp),%eax
801044c8:	83 ec 0c             	sub    $0xc,%esp
801044cb:	50                   	push   %eax
801044cc:	e8 b9 18 00 00       	call   80105d8a <release>
801044d1:	83 c4 10             	add    $0x10,%esp
  return i;
801044d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801044d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801044da:	c9                   	leave  
801044db:	c3                   	ret    

801044dc <hlt>:
}

// hlt() added by Noah Zentzis, Fall 2016.
static inline void
hlt()
{
801044dc:	55                   	push   %ebp
801044dd:	89 e5                	mov    %esp,%ebp
  asm volatile("hlt");
801044df:	f4                   	hlt    
}
801044e0:	90                   	nop
801044e1:	5d                   	pop    %ebp
801044e2:	c3                   	ret    

801044e3 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801044e3:	55                   	push   %ebp
801044e4:	89 e5                	mov    %esp,%ebp
801044e6:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801044e9:	9c                   	pushf  
801044ea:	58                   	pop    %eax
801044eb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801044ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801044f1:	c9                   	leave  
801044f2:	c3                   	ret    

801044f3 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801044f3:	55                   	push   %ebp
801044f4:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801044f6:	fb                   	sti    
}
801044f7:	90                   	nop
801044f8:	5d                   	pop    %ebp
801044f9:	c3                   	ret    

801044fa <pinit>:
static int stateListRemove(struct proc** head, struct proc** tail, struct proc* p);
#endif

void
pinit(void)
{
801044fa:	55                   	push   %ebp
801044fb:	89 e5                	mov    %esp,%ebp
801044fd:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104500:	83 ec 08             	sub    $0x8,%esp
80104503:	68 e4 96 10 80       	push   $0x801096e4
80104508:	68 80 39 11 80       	push   $0x80113980
8010450d:	e8 ef 17 00 00       	call   80105d01 <initlock>
80104512:	83 c4 10             	add    $0x10,%esp
}
80104515:	90                   	nop
80104516:	c9                   	leave  
80104517:	c3                   	ret    

80104518 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104518:	55                   	push   %ebp
80104519:	89 e5                	mov    %esp,%ebp
8010451b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
8010451e:	83 ec 0c             	sub    $0xc,%esp
80104521:	68 80 39 11 80       	push   $0x80113980
80104526:	e8 f8 17 00 00       	call   80105d23 <acquire>
8010452b:	83 c4 10             	add    $0x10,%esp
#ifndef CS333_P3P4
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
#else
  p = ptable.pLists.free;
8010452e:	a1 bc 5e 11 80       	mov    0x80115ebc,%eax
80104533:	89 45 f4             	mov    %eax,-0xc(%ebp)
  stateListRemove(&ptable.pLists.free, &ptable.pLists.freeTail, p);
80104536:	83 ec 04             	sub    $0x4,%esp
80104539:	ff 75 f4             	pushl  -0xc(%ebp)
8010453c:	68 c0 5e 11 80       	push   $0x80115ec0
80104541:	68 bc 5e 11 80       	push   $0x80115ebc
80104546:	e8 f9 11 00 00       	call   80105744 <stateListRemove>
8010454b:	83 c4 10             	add    $0x10,%esp
  goto found;
8010454e:	90                   	nop
#endif
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
8010454f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104552:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
#ifdef CS333_P3P4
  stateListAdd(&ptable.pLists.embryo, &ptable.pLists.embryoTail,p);
80104559:	83 ec 04             	sub    $0x4,%esp
8010455c:	ff 75 f4             	pushl  -0xc(%ebp)
8010455f:	68 e0 5e 11 80       	push   $0x80115ee0
80104564:	68 dc 5e 11 80       	push   $0x80115edc
80104569:	e8 77 11 00 00       	call   801056e5 <stateListAdd>
8010456e:	83 c4 10             	add    $0x10,%esp
#endif
  p->pid = nextpid++;
80104571:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104576:	8d 50 01             	lea    0x1(%eax),%edx
80104579:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
8010457f:	89 c2                	mov    %eax,%edx
80104581:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104584:	89 50 10             	mov    %edx,0x10(%eax)
  p->start_ticks = ticks;
80104587:	8b 15 00 67 11 80    	mov    0x80116700,%edx
8010458d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104590:	89 50 7c             	mov    %edx,0x7c(%eax)
  p->uid = 0;
80104593:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104596:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
8010459d:	00 00 00 
  p->gid = 0;
801045a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a3:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
801045aa:	00 00 00 
  p->cpu_ticks_in = 0;
801045ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b0:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
801045b7:	00 00 00 
  p->cpu_ticks_total = 0;
801045ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045bd:	c7 80 88 00 00 00 00 	movl   $0x0,0x88(%eax)
801045c4:	00 00 00 
  release(&ptable.lock);
801045c7:	83 ec 0c             	sub    $0xc,%esp
801045ca:	68 80 39 11 80       	push   $0x80113980
801045cf:	e8 b6 17 00 00       	call   80105d8a <release>
801045d4:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801045d7:	e8 28 e7 ff ff       	call   80102d04 <kalloc>
801045dc:	89 c2                	mov    %eax,%edx
801045de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e1:	89 50 08             	mov    %edx,0x8(%eax)
801045e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e7:	8b 40 08             	mov    0x8(%eax),%eax
801045ea:	85 c0                	test   %eax,%eax
801045ec:	75 41                	jne    8010462f <allocproc+0x117>
    p->state = UNUSED;
801045ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
#ifdef CS333_P3P4
    stateListRemove(&ptable.pLists.embryo, &ptable.pLists.embryoTail,p);
801045f8:	83 ec 04             	sub    $0x4,%esp
801045fb:	ff 75 f4             	pushl  -0xc(%ebp)
801045fe:	68 e0 5e 11 80       	push   $0x80115ee0
80104603:	68 dc 5e 11 80       	push   $0x80115edc
80104608:	e8 37 11 00 00       	call   80105744 <stateListRemove>
8010460d:	83 c4 10             	add    $0x10,%esp
    stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail,p);
80104610:	83 ec 04             	sub    $0x4,%esp
80104613:	ff 75 f4             	pushl  -0xc(%ebp)
80104616:	68 c0 5e 11 80       	push   $0x80115ec0
8010461b:	68 bc 5e 11 80       	push   $0x80115ebc
80104620:	e8 c0 10 00 00       	call   801056e5 <stateListAdd>
80104625:	83 c4 10             	add    $0x10,%esp
#endif
    return 0;
80104628:	b8 00 00 00 00       	mov    $0x0,%eax
8010462d:	eb 5d                	jmp    8010468c <allocproc+0x174>
  }
  sp = p->kstack + KSTACKSIZE;
8010462f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104632:	8b 40 08             	mov    0x8(%eax),%eax
80104635:	05 00 10 00 00       	add    $0x1000,%eax
8010463a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010463d:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104641:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104644:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104647:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010464a:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010464e:	ba b4 74 10 80       	mov    $0x801074b4,%edx
80104653:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104656:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104658:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010465c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010465f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104662:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104665:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104668:	8b 40 1c             	mov    0x1c(%eax),%eax
8010466b:	83 ec 04             	sub    $0x4,%esp
8010466e:	6a 14                	push   $0x14
80104670:	6a 00                	push   $0x0
80104672:	50                   	push   %eax
80104673:	e8 0e 19 00 00       	call   80105f86 <memset>
80104678:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
8010467b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010467e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104681:	ba c3 51 10 80       	mov    $0x801051c3,%edx
80104686:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104689:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010468c:	c9                   	leave  
8010468d:	c3                   	ret    

8010468e <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010468e:	55                   	push   %ebp
8010468f:	89 e5                	mov    %esp,%ebp
80104691:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

#ifdef CS333_P3P4
  acquire(&ptable.lock);
80104694:	83 ec 0c             	sub    $0xc,%esp
80104697:	68 80 39 11 80       	push   $0x80113980
8010469c:	e8 82 16 00 00       	call   80105d23 <acquire>
801046a1:	83 c4 10             	add    $0x10,%esp
  initProcessLists();
801046a4:	e8 6a 11 00 00       	call   80105813 <initProcessLists>
  initFreeList();
801046a9:	e8 e3 11 00 00       	call   80105891 <initFreeList>
  release(&ptable.lock);
801046ae:	83 ec 0c             	sub    $0xc,%esp
801046b1:	68 80 39 11 80       	push   $0x80113980
801046b6:	e8 cf 16 00 00       	call   80105d8a <release>
801046bb:	83 c4 10             	add    $0x10,%esp
#endif
  p = allocproc();
801046be:	e8 55 fe ff ff       	call   80104518 <allocproc>
801046c3:	89 45 f4             	mov    %eax,-0xc(%ebp)

  initproc = p;
801046c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c9:	a3 68 c6 10 80       	mov    %eax,0x8010c668
  if((p->pgdir = setupkvm()) == 0)
801046ce:	e8 a3 44 00 00       	call   80108b76 <setupkvm>
801046d3:	89 c2                	mov    %eax,%edx
801046d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d8:	89 50 04             	mov    %edx,0x4(%eax)
801046db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046de:	8b 40 04             	mov    0x4(%eax),%eax
801046e1:	85 c0                	test   %eax,%eax
801046e3:	75 0d                	jne    801046f2 <userinit+0x64>
    panic("userinit: out of memory?");
801046e5:	83 ec 0c             	sub    $0xc,%esp
801046e8:	68 eb 96 10 80       	push   $0x801096eb
801046ed:	e8 74 be ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801046f2:	ba 2c 00 00 00       	mov    $0x2c,%edx
801046f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046fa:	8b 40 04             	mov    0x4(%eax),%eax
801046fd:	83 ec 04             	sub    $0x4,%esp
80104700:	52                   	push   %edx
80104701:	68 00 c5 10 80       	push   $0x8010c500
80104706:	50                   	push   %eax
80104707:	e8 c4 46 00 00       	call   80108dd0 <inituvm>
8010470c:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
8010470f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104712:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104718:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010471b:	8b 40 18             	mov    0x18(%eax),%eax
8010471e:	83 ec 04             	sub    $0x4,%esp
80104721:	6a 4c                	push   $0x4c
80104723:	6a 00                	push   $0x0
80104725:	50                   	push   %eax
80104726:	e8 5b 18 00 00       	call   80105f86 <memset>
8010472b:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010472e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104731:	8b 40 18             	mov    0x18(%eax),%eax
80104734:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010473a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010473d:	8b 40 18             	mov    0x18(%eax),%eax
80104740:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104746:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104749:	8b 40 18             	mov    0x18(%eax),%eax
8010474c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010474f:	8b 52 18             	mov    0x18(%edx),%edx
80104752:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104756:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010475a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010475d:	8b 40 18             	mov    0x18(%eax),%eax
80104760:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104763:	8b 52 18             	mov    0x18(%edx),%edx
80104766:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010476a:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010476e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104771:	8b 40 18             	mov    0x18(%eax),%eax
80104774:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010477b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010477e:	8b 40 18             	mov    0x18(%eax),%eax
80104781:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104788:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010478b:	8b 40 18             	mov    0x18(%eax),%eax
8010478e:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104795:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104798:	83 c0 6c             	add    $0x6c,%eax
8010479b:	83 ec 04             	sub    $0x4,%esp
8010479e:	6a 10                	push   $0x10
801047a0:	68 04 97 10 80       	push   $0x80109704
801047a5:	50                   	push   %eax
801047a6:	e8 de 19 00 00       	call   80106189 <safestrcpy>
801047ab:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801047ae:	83 ec 0c             	sub    $0xc,%esp
801047b1:	68 0d 97 10 80       	push   $0x8010970d
801047b6:	e8 0b de ff ff       	call   801025c6 <namei>
801047bb:	83 c4 10             	add    $0x10,%esp
801047be:	89 c2                	mov    %eax,%edx
801047c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047c3:	89 50 68             	mov    %edx,0x68(%eax)

  p->state = RUNNABLE;
801047c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047c9:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
#ifdef CS333_P3P4
  acquire(&ptable.lock);
801047d0:	83 ec 0c             	sub    $0xc,%esp
801047d3:	68 80 39 11 80       	push   $0x80113980
801047d8:	e8 46 15 00 00       	call   80105d23 <acquire>
801047dd:	83 c4 10             	add    $0x10,%esp
  stateListRemove(&ptable.pLists.embryo, &ptable.pLists.embryoTail, p);
801047e0:	83 ec 04             	sub    $0x4,%esp
801047e3:	ff 75 f4             	pushl  -0xc(%ebp)
801047e6:	68 e0 5e 11 80       	push   $0x80115ee0
801047eb:	68 dc 5e 11 80       	push   $0x80115edc
801047f0:	e8 4f 0f 00 00       	call   80105744 <stateListRemove>
801047f5:	83 c4 10             	add    $0x10,%esp
  stateListAdd(&ptable.pLists.ready, &ptable.pLists.readyTail, p);
801047f8:	83 ec 04             	sub    $0x4,%esp
801047fb:	ff 75 f4             	pushl  -0xc(%ebp)
801047fe:	68 b8 5e 11 80       	push   $0x80115eb8
80104803:	68 b4 5e 11 80       	push   $0x80115eb4
80104808:	e8 d8 0e 00 00       	call   801056e5 <stateListAdd>
8010480d:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104810:	83 ec 0c             	sub    $0xc,%esp
80104813:	68 80 39 11 80       	push   $0x80113980
80104818:	e8 6d 15 00 00       	call   80105d8a <release>
8010481d:	83 c4 10             	add    $0x10,%esp
#endif
  p->uid = 0;
80104820:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104823:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
8010482a:	00 00 00 
  p->gid = 0;
8010482d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104830:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
80104837:	00 00 00 
}
8010483a:	90                   	nop
8010483b:	c9                   	leave  
8010483c:	c3                   	ret    

8010483d <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
8010483d:	55                   	push   %ebp
8010483e:	89 e5                	mov    %esp,%ebp
80104840:	83 ec 18             	sub    $0x18,%esp
  uint sz;

  sz = proc->sz;
80104843:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104849:	8b 00                	mov    (%eax),%eax
8010484b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010484e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104852:	7e 31                	jle    80104885 <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104854:	8b 55 08             	mov    0x8(%ebp),%edx
80104857:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010485a:	01 c2                	add    %eax,%edx
8010485c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104862:	8b 40 04             	mov    0x4(%eax),%eax
80104865:	83 ec 04             	sub    $0x4,%esp
80104868:	52                   	push   %edx
80104869:	ff 75 f4             	pushl  -0xc(%ebp)
8010486c:	50                   	push   %eax
8010486d:	e8 ab 46 00 00       	call   80108f1d <allocuvm>
80104872:	83 c4 10             	add    $0x10,%esp
80104875:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104878:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010487c:	75 3e                	jne    801048bc <growproc+0x7f>
      return -1;
8010487e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104883:	eb 59                	jmp    801048de <growproc+0xa1>
  } else if(n < 0){
80104885:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104889:	79 31                	jns    801048bc <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
8010488b:	8b 55 08             	mov    0x8(%ebp),%edx
8010488e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104891:	01 c2                	add    %eax,%edx
80104893:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104899:	8b 40 04             	mov    0x4(%eax),%eax
8010489c:	83 ec 04             	sub    $0x4,%esp
8010489f:	52                   	push   %edx
801048a0:	ff 75 f4             	pushl  -0xc(%ebp)
801048a3:	50                   	push   %eax
801048a4:	e8 3d 47 00 00       	call   80108fe6 <deallocuvm>
801048a9:	83 c4 10             	add    $0x10,%esp
801048ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
801048af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801048b3:	75 07                	jne    801048bc <growproc+0x7f>
      return -1;
801048b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048ba:	eb 22                	jmp    801048de <growproc+0xa1>
  }
  proc->sz = sz;
801048bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801048c5:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
801048c7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048cd:	83 ec 0c             	sub    $0xc,%esp
801048d0:	50                   	push   %eax
801048d1:	e8 87 43 00 00       	call   80108c5d <switchuvm>
801048d6:	83 c4 10             	add    $0x10,%esp
  return 0;
801048d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801048de:	c9                   	leave  
801048df:	c3                   	ret    

801048e0 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801048e0:	55                   	push   %ebp
801048e1:	89 e5                	mov    %esp,%ebp
801048e3:	57                   	push   %edi
801048e4:	56                   	push   %esi
801048e5:	53                   	push   %ebx
801048e6:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
801048e9:	e8 2a fc ff ff       	call   80104518 <allocproc>
801048ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
801048f1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801048f5:	75 0a                	jne    80104901 <fork+0x21>
    return -1;
801048f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048fc:	e9 16 02 00 00       	jmp    80104b17 <fork+0x237>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104901:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104907:	8b 10                	mov    (%eax),%edx
80104909:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010490f:	8b 40 04             	mov    0x4(%eax),%eax
80104912:	83 ec 08             	sub    $0x8,%esp
80104915:	52                   	push   %edx
80104916:	50                   	push   %eax
80104917:	e8 68 48 00 00       	call   80109184 <copyuvm>
8010491c:	83 c4 10             	add    $0x10,%esp
8010491f:	89 c2                	mov    %eax,%edx
80104921:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104924:	89 50 04             	mov    %edx,0x4(%eax)
80104927:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010492a:	8b 40 04             	mov    0x4(%eax),%eax
8010492d:	85 c0                	test   %eax,%eax
8010492f:	0f 85 80 00 00 00    	jne    801049b5 <fork+0xd5>
    kfree(np->kstack);
80104935:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104938:	8b 40 08             	mov    0x8(%eax),%eax
8010493b:	83 ec 0c             	sub    $0xc,%esp
8010493e:	50                   	push   %eax
8010493f:	e8 23 e3 ff ff       	call   80102c67 <kfree>
80104944:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104947:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010494a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104951:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104954:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
#ifdef CS333_P3P4
    acquire(&ptable.lock);
8010495b:	83 ec 0c             	sub    $0xc,%esp
8010495e:	68 80 39 11 80       	push   $0x80113980
80104963:	e8 bb 13 00 00       	call   80105d23 <acquire>
80104968:	83 c4 10             	add    $0x10,%esp
    stateListRemove(&ptable.pLists.embryo, &ptable.pLists.embryoTail, np);
8010496b:	83 ec 04             	sub    $0x4,%esp
8010496e:	ff 75 e0             	pushl  -0x20(%ebp)
80104971:	68 e0 5e 11 80       	push   $0x80115ee0
80104976:	68 dc 5e 11 80       	push   $0x80115edc
8010497b:	e8 c4 0d 00 00       	call   80105744 <stateListRemove>
80104980:	83 c4 10             	add    $0x10,%esp
    stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail, np);
80104983:	83 ec 04             	sub    $0x4,%esp
80104986:	ff 75 e0             	pushl  -0x20(%ebp)
80104989:	68 c0 5e 11 80       	push   $0x80115ec0
8010498e:	68 bc 5e 11 80       	push   $0x80115ebc
80104993:	e8 4d 0d 00 00       	call   801056e5 <stateListAdd>
80104998:	83 c4 10             	add    $0x10,%esp
    release(&ptable.lock);
8010499b:	83 ec 0c             	sub    $0xc,%esp
8010499e:	68 80 39 11 80       	push   $0x80113980
801049a3:	e8 e2 13 00 00       	call   80105d8a <release>
801049a8:	83 c4 10             	add    $0x10,%esp
#endif
    return -1;
801049ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049b0:	e9 62 01 00 00       	jmp    80104b17 <fork+0x237>
  }
  np->sz = proc->sz;
801049b5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049bb:	8b 10                	mov    (%eax),%edx
801049bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049c0:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801049c2:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801049c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049cc:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801049cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049d2:	8b 50 18             	mov    0x18(%eax),%edx
801049d5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049db:	8b 40 18             	mov    0x18(%eax),%eax
801049de:	89 c3                	mov    %eax,%ebx
801049e0:	b8 13 00 00 00       	mov    $0x13,%eax
801049e5:	89 d7                	mov    %edx,%edi
801049e7:	89 de                	mov    %ebx,%esi
801049e9:	89 c1                	mov    %eax,%ecx
801049eb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801049ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049f0:	8b 40 18             	mov    0x18(%eax),%eax
801049f3:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801049fa:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104a01:	eb 43                	jmp    80104a46 <fork+0x166>
    if(proc->ofile[i])
80104a03:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a09:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104a0c:	83 c2 08             	add    $0x8,%edx
80104a0f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a13:	85 c0                	test   %eax,%eax
80104a15:	74 2b                	je     80104a42 <fork+0x162>
      np->ofile[i] = filedup(proc->ofile[i]);
80104a17:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a1d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104a20:	83 c2 08             	add    $0x8,%edx
80104a23:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a27:	83 ec 0c             	sub    $0xc,%esp
80104a2a:	50                   	push   %eax
80104a2b:	e8 6e c6 ff ff       	call   8010109e <filedup>
80104a30:	83 c4 10             	add    $0x10,%esp
80104a33:	89 c1                	mov    %eax,%ecx
80104a35:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a38:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104a3b:	83 c2 08             	add    $0x8,%edx
80104a3e:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104a42:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104a46:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104a4a:	7e b7                	jle    80104a03 <fork+0x123>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104a4c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a52:	8b 40 68             	mov    0x68(%eax),%eax
80104a55:	83 ec 0c             	sub    $0xc,%esp
80104a58:	50                   	push   %eax
80104a59:	e8 70 cf ff ff       	call   801019ce <idup>
80104a5e:	83 c4 10             	add    $0x10,%esp
80104a61:	89 c2                	mov    %eax,%edx
80104a63:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a66:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104a69:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a6f:	8d 50 6c             	lea    0x6c(%eax),%edx
80104a72:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a75:	83 c0 6c             	add    $0x6c,%eax
80104a78:	83 ec 04             	sub    $0x4,%esp
80104a7b:	6a 10                	push   $0x10
80104a7d:	52                   	push   %edx
80104a7e:	50                   	push   %eax
80104a7f:	e8 05 17 00 00       	call   80106189 <safestrcpy>
80104a84:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104a87:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a8a:	8b 40 10             	mov    0x10(%eax),%eax
80104a8d:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104a90:	83 ec 0c             	sub    $0xc,%esp
80104a93:	68 80 39 11 80       	push   $0x80113980
80104a98:	e8 86 12 00 00       	call   80105d23 <acquire>
80104a9d:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
80104aa0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104aa3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
#ifdef CS333_P3P4
  stateListRemove(&ptable.pLists.embryo, &ptable.pLists.embryoTail, np);
80104aaa:	83 ec 04             	sub    $0x4,%esp
80104aad:	ff 75 e0             	pushl  -0x20(%ebp)
80104ab0:	68 e0 5e 11 80       	push   $0x80115ee0
80104ab5:	68 dc 5e 11 80       	push   $0x80115edc
80104aba:	e8 85 0c 00 00       	call   80105744 <stateListRemove>
80104abf:	83 c4 10             	add    $0x10,%esp
  stateListAdd(&ptable.pLists.ready, &ptable.pLists.readyTail, np);
80104ac2:	83 ec 04             	sub    $0x4,%esp
80104ac5:	ff 75 e0             	pushl  -0x20(%ebp)
80104ac8:	68 b8 5e 11 80       	push   $0x80115eb8
80104acd:	68 b4 5e 11 80       	push   $0x80115eb4
80104ad2:	e8 0e 0c 00 00       	call   801056e5 <stateListAdd>
80104ad7:	83 c4 10             	add    $0x10,%esp
#endif
  release(&ptable.lock);
80104ada:	83 ec 0c             	sub    $0xc,%esp
80104add:	68 80 39 11 80       	push   $0x80113980
80104ae2:	e8 a3 12 00 00       	call   80105d8a <release>
80104ae7:	83 c4 10             	add    $0x10,%esp

  np->uid = proc->uid;
80104aea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104af0:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104af6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104af9:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  np->gid = proc->gid;
80104aff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b05:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80104b0b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b0e:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)

  return pid;
80104b14:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104b17:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104b1a:	5b                   	pop    %ebx
80104b1b:	5e                   	pop    %esi
80104b1c:	5f                   	pop    %edi
80104b1d:	5d                   	pop    %ebp
80104b1e:	c3                   	ret    

80104b1f <exit>:
  panic("zombie exit");
}
#else
void
exit(void)
{
80104b1f:	55                   	push   %ebp
80104b20:	89 e5                	mov    %esp,%ebp
80104b22:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104b25:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104b2c:	a1 68 c6 10 80       	mov    0x8010c668,%eax
80104b31:	39 c2                	cmp    %eax,%edx
80104b33:	75 0d                	jne    80104b42 <exit+0x23>
    panic("init exiting");
80104b35:	83 ec 0c             	sub    $0xc,%esp
80104b38:	68 0f 97 10 80       	push   $0x8010970f
80104b3d:	e8 24 ba ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104b42:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104b49:	eb 48                	jmp    80104b93 <exit+0x74>
    if(proc->ofile[fd]){
80104b4b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b51:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104b54:	83 c2 08             	add    $0x8,%edx
80104b57:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104b5b:	85 c0                	test   %eax,%eax
80104b5d:	74 30                	je     80104b8f <exit+0x70>
      fileclose(proc->ofile[fd]);
80104b5f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b65:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104b68:	83 c2 08             	add    $0x8,%edx
80104b6b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104b6f:	83 ec 0c             	sub    $0xc,%esp
80104b72:	50                   	push   %eax
80104b73:	e8 77 c5 ff ff       	call   801010ef <fileclose>
80104b78:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80104b7b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b81:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104b84:	83 c2 08             	add    $0x8,%edx
80104b87:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104b8e:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104b8f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104b93:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104b97:	7e b2                	jle    80104b4b <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104b99:	e8 4d ea ff ff       	call   801035eb <begin_op>
  iput(proc->cwd);
80104b9e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ba4:	8b 40 68             	mov    0x68(%eax),%eax
80104ba7:	83 ec 0c             	sub    $0xc,%esp
80104baa:	50                   	push   %eax
80104bab:	e8 28 d0 ff ff       	call   80101bd8 <iput>
80104bb0:	83 c4 10             	add    $0x10,%esp
  end_op();
80104bb3:	e8 bf ea ff ff       	call   80103677 <end_op>
  proc->cwd = 0;
80104bb8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bbe:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104bc5:	83 ec 0c             	sub    $0xc,%esp
80104bc8:	68 80 39 11 80       	push   $0x80113980
80104bcd:	e8 51 11 00 00       	call   80105d23 <acquire>
80104bd2:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104bd5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bdb:	8b 40 14             	mov    0x14(%eax),%eax
80104bde:	83 ec 0c             	sub    $0xc,%esp
80104be1:	50                   	push   %eax
80104be2:	e8 ff 06 00 00       	call   801052e6 <wakeup1>
80104be7:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
    for(p = ptable.pLists.ready;p;p=p->next)
80104bea:	a1 b4 5e 11 80       	mov    0x80115eb4,%eax
80104bef:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104bf2:	eb 28                	jmp    80104c1c <exit+0xfd>
    {
      if(p->parent == proc)
80104bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf7:	8b 50 14             	mov    0x14(%eax),%edx
80104bfa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c00:	39 c2                	cmp    %eax,%edx
80104c02:	75 0c                	jne    80104c10 <exit+0xf1>
        p->parent = initproc;
80104c04:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
80104c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c0d:	89 50 14             	mov    %edx,0x14(%eax)

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
    for(p = ptable.pLists.ready;p;p=p->next)
80104c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c13:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104c19:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104c1c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104c20:	75 d2                	jne    80104bf4 <exit+0xd5>
    {
      if(p->parent == proc)
        p->parent = initproc;
    }
    for(p = ptable.pLists.sleep;p;p=p->next)
80104c22:	a1 c4 5e 11 80       	mov    0x80115ec4,%eax
80104c27:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104c2a:	eb 28                	jmp    80104c54 <exit+0x135>
    {
      if(p->parent == proc)
80104c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c2f:	8b 50 14             	mov    0x14(%eax),%edx
80104c32:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c38:	39 c2                	cmp    %eax,%edx
80104c3a:	75 0c                	jne    80104c48 <exit+0x129>
        p->parent = initproc;
80104c3c:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
80104c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c45:	89 50 14             	mov    %edx,0x14(%eax)
    for(p = ptable.pLists.ready;p;p=p->next)
    {
      if(p->parent == proc)
        p->parent = initproc;
    }
    for(p = ptable.pLists.sleep;p;p=p->next)
80104c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c4b:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104c51:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104c54:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104c58:	75 d2                	jne    80104c2c <exit+0x10d>
    {
      if(p->parent == proc)
        p->parent = initproc;
    }
    for(p = ptable.pLists.embryo;p;p=p->next)
80104c5a:	a1 dc 5e 11 80       	mov    0x80115edc,%eax
80104c5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104c62:	eb 28                	jmp    80104c8c <exit+0x16d>
    {
      if(p->parent == proc)
80104c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c67:	8b 50 14             	mov    0x14(%eax),%edx
80104c6a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c70:	39 c2                	cmp    %eax,%edx
80104c72:	75 0c                	jne    80104c80 <exit+0x161>
        p->parent = initproc;
80104c74:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
80104c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c7d:	89 50 14             	mov    %edx,0x14(%eax)
    for(p = ptable.pLists.sleep;p;p=p->next)
    {
      if(p->parent == proc)
        p->parent = initproc;
    }
    for(p = ptable.pLists.embryo;p;p=p->next)
80104c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c83:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104c89:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104c8c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104c90:	75 d2                	jne    80104c64 <exit+0x145>
    {
      if(p->parent == proc)
        p->parent = initproc;
    }
    for(p=ptable.pLists.running;p;p=p->next)
80104c92:	a1 d4 5e 11 80       	mov    0x80115ed4,%eax
80104c97:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104c9a:	eb 28                	jmp    80104cc4 <exit+0x1a5>
    {
      if(p->parent == proc)
80104c9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c9f:	8b 50 14             	mov    0x14(%eax),%edx
80104ca2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ca8:	39 c2                	cmp    %eax,%edx
80104caa:	75 0c                	jne    80104cb8 <exit+0x199>
        p->parent = initproc;
80104cac:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
80104cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cb5:	89 50 14             	mov    %edx,0x14(%eax)
    for(p = ptable.pLists.embryo;p;p=p->next)
    {
      if(p->parent == proc)
        p->parent = initproc;
    }
    for(p=ptable.pLists.running;p;p=p->next)
80104cb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cbb:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104cc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104cc4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104cc8:	75 d2                	jne    80104c9c <exit+0x17d>
      if(p->parent == proc)
        p->parent = initproc;
    }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104cca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cd0:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  stateListRemove(&ptable.pLists.running, &ptable.pLists.runningTail, proc);
80104cd7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cdd:	83 ec 04             	sub    $0x4,%esp
80104ce0:	50                   	push   %eax
80104ce1:	68 d8 5e 11 80       	push   $0x80115ed8
80104ce6:	68 d4 5e 11 80       	push   $0x80115ed4
80104ceb:	e8 54 0a 00 00       	call   80105744 <stateListRemove>
80104cf0:	83 c4 10             	add    $0x10,%esp
  stateListAdd(&ptable.pLists.zombie, &ptable.pLists.zombieTail, proc);
80104cf3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cf9:	83 ec 04             	sub    $0x4,%esp
80104cfc:	50                   	push   %eax
80104cfd:	68 d0 5e 11 80       	push   $0x80115ed0
80104d02:	68 cc 5e 11 80       	push   $0x80115ecc
80104d07:	e8 d9 09 00 00       	call   801056e5 <stateListAdd>
80104d0c:	83 c4 10             	add    $0x10,%esp
  sched();
80104d0f:	e8 80 03 00 00       	call   80105094 <sched>
  panic("zombie exit");
80104d14:	83 ec 0c             	sub    $0xc,%esp
80104d17:	68 1c 97 10 80       	push   $0x8010971c
80104d1c:	e8 45 b8 ff ff       	call   80100566 <panic>

80104d21 <wait>:
  }
}
#else
int
wait(void)
{
80104d21:	55                   	push   %ebp
80104d22:	89 e5                	mov    %esp,%ebp
80104d24:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104d27:	83 ec 0c             	sub    $0xc,%esp
80104d2a:	68 80 39 11 80       	push   $0x80113980
80104d2f:	e8 ef 0f 00 00       	call   80105d23 <acquire>
80104d34:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104d37:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.pLists.zombie; p; p=p->next){
80104d3e:	a1 cc 5e 11 80       	mov    0x80115ecc,%eax
80104d43:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104d46:	e9 d6 00 00 00       	jmp    80104e21 <wait+0x100>
      if(p->parent != proc)
80104d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d4e:	8b 50 14             	mov    0x14(%eax),%edx
80104d51:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d57:	39 c2                	cmp    %eax,%edx
80104d59:	74 11                	je     80104d6c <wait+0x4b>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.pLists.zombie; p; p=p->next){
80104d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d5e:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104d64:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104d67:	e9 b5 00 00 00       	jmp    80104e21 <wait+0x100>
      if(p->parent != proc)
        continue;

      havekids = 1;
80104d6c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      // Found one.
      pid = p->pid;
80104d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d76:	8b 40 10             	mov    0x10(%eax),%eax
80104d79:	89 45 ec             	mov    %eax,-0x14(%ebp)
      kfree(p->kstack);
80104d7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d7f:	8b 40 08             	mov    0x8(%eax),%eax
80104d82:	83 ec 0c             	sub    $0xc,%esp
80104d85:	50                   	push   %eax
80104d86:	e8 dc de ff ff       	call   80102c67 <kfree>
80104d8b:	83 c4 10             	add    $0x10,%esp
      p->kstack = 0;
80104d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d91:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
      freevm(p->pgdir);
80104d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d9b:	8b 40 04             	mov    0x4(%eax),%eax
80104d9e:	83 ec 0c             	sub    $0xc,%esp
80104da1:	50                   	push   %eax
80104da2:	e8 fc 42 00 00       	call   801090a3 <freevm>
80104da7:	83 c4 10             	add    $0x10,%esp
      p->state = UNUSED;
80104daa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dad:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
      stateListRemove(&ptable.pLists.zombie, &ptable.pLists.zombieTail,p);
80104db4:	83 ec 04             	sub    $0x4,%esp
80104db7:	ff 75 f4             	pushl  -0xc(%ebp)
80104dba:	68 d0 5e 11 80       	push   $0x80115ed0
80104dbf:	68 cc 5e 11 80       	push   $0x80115ecc
80104dc4:	e8 7b 09 00 00       	call   80105744 <stateListRemove>
80104dc9:	83 c4 10             	add    $0x10,%esp
      stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail,p);
80104dcc:	83 ec 04             	sub    $0x4,%esp
80104dcf:	ff 75 f4             	pushl  -0xc(%ebp)
80104dd2:	68 c0 5e 11 80       	push   $0x80115ec0
80104dd7:	68 bc 5e 11 80       	push   $0x80115ebc
80104ddc:	e8 04 09 00 00       	call   801056e5 <stateListAdd>
80104de1:	83 c4 10             	add    $0x10,%esp
      p->pid = 0;
80104de4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104de7:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
      p->parent = 0;
80104dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104df1:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
      p->name[0] = 0;
80104df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dfb:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
      p->killed = 0;
80104dff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e02:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
      release(&ptable.lock);
80104e09:	83 ec 0c             	sub    $0xc,%esp
80104e0c:	68 80 39 11 80       	push   $0x80113980
80104e11:	e8 74 0f 00 00       	call   80105d8a <release>
80104e16:	83 c4 10             	add    $0x10,%esp
      return pid;
80104e19:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104e1c:	e9 27 01 00 00       	jmp    80104f48 <wait+0x227>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.pLists.zombie; p; p=p->next){
80104e21:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e25:	0f 85 20 ff ff ff    	jne    80104d4b <wait+0x2a>
      release(&ptable.lock);
      return pid;

    }

    for(p = ptable.pLists.ready;p;p=p->next)
80104e2b:	a1 b4 5e 11 80       	mov    0x80115eb4,%eax
80104e30:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e33:	eb 28                	jmp    80104e5d <wait+0x13c>
    {
      if(p->parent == proc)
80104e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e38:	8b 50 14             	mov    0x14(%eax),%edx
80104e3b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e41:	39 c2                	cmp    %eax,%edx
80104e43:	75 0c                	jne    80104e51 <wait+0x130>
      {
        havekids = 1;
80104e45:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
        goto kids;
80104e4c:	e9 b1 00 00 00       	jmp    80104f02 <wait+0x1e1>
      release(&ptable.lock);
      return pid;

    }

    for(p = ptable.pLists.ready;p;p=p->next)
80104e51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e54:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104e5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e5d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e61:	75 d2                	jne    80104e35 <wait+0x114>
      {
        havekids = 1;
        goto kids;
      }
    }
    for(p = ptable.pLists.sleep;p;p=p->next)
80104e63:	a1 c4 5e 11 80       	mov    0x80115ec4,%eax
80104e68:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e6b:	eb 25                	jmp    80104e92 <wait+0x171>
    {
      if(p->parent == proc)
80104e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e70:	8b 50 14             	mov    0x14(%eax),%edx
80104e73:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e79:	39 c2                	cmp    %eax,%edx
80104e7b:	75 09                	jne    80104e86 <wait+0x165>
      {
        havekids = 1;
80104e7d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
        goto kids;
80104e84:	eb 7c                	jmp    80104f02 <wait+0x1e1>
      {
        havekids = 1;
        goto kids;
      }
    }
    for(p = ptable.pLists.sleep;p;p=p->next)
80104e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e89:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104e8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e92:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e96:	75 d5                	jne    80104e6d <wait+0x14c>
      {
        havekids = 1;
        goto kids;
      }
    }
    for(p = ptable.pLists.embryo;p;p=p->next)
80104e98:	a1 dc 5e 11 80       	mov    0x80115edc,%eax
80104e9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104ea0:	eb 25                	jmp    80104ec7 <wait+0x1a6>
    {
      if(p->parent == proc)
80104ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ea5:	8b 50 14             	mov    0x14(%eax),%edx
80104ea8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104eae:	39 c2                	cmp    %eax,%edx
80104eb0:	75 09                	jne    80104ebb <wait+0x19a>
      {
        havekids = 1;
80104eb2:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
        goto kids;
80104eb9:	eb 47                	jmp    80104f02 <wait+0x1e1>
      {
        havekids = 1;
        goto kids;
      }
    }
    for(p = ptable.pLists.embryo;p;p=p->next)
80104ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ebe:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104ec4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104ec7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104ecb:	75 d5                	jne    80104ea2 <wait+0x181>
      {
        havekids = 1;
        goto kids;
      }
    }
    for(p=ptable.pLists.running;p;p=p->next)
80104ecd:	a1 d4 5e 11 80       	mov    0x80115ed4,%eax
80104ed2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104ed5:	eb 25                	jmp    80104efc <wait+0x1db>
    {
      if(p->parent == proc)
80104ed7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eda:	8b 50 14             	mov    0x14(%eax),%edx
80104edd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ee3:	39 c2                	cmp    %eax,%edx
80104ee5:	75 09                	jne    80104ef0 <wait+0x1cf>
      {
        havekids = 1;
80104ee7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
        goto kids;
80104eee:	eb 12                	jmp    80104f02 <wait+0x1e1>
      {
        havekids = 1;
        goto kids;
      }
    }
    for(p=ptable.pLists.running;p;p=p->next)
80104ef0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ef3:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104ef9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104efc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104f00:	75 d5                	jne    80104ed7 <wait+0x1b6>
      }
    }

    kids:
    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104f02:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104f06:	74 0d                	je     80104f15 <wait+0x1f4>
80104f08:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f0e:	8b 40 24             	mov    0x24(%eax),%eax
80104f11:	85 c0                	test   %eax,%eax
80104f13:	74 17                	je     80104f2c <wait+0x20b>
      release(&ptable.lock);
80104f15:	83 ec 0c             	sub    $0xc,%esp
80104f18:	68 80 39 11 80       	push   $0x80113980
80104f1d:	e8 68 0e 00 00       	call   80105d8a <release>
80104f22:	83 c4 10             	add    $0x10,%esp
      return -1;
80104f25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f2a:	eb 1c                	jmp    80104f48 <wait+0x227>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104f2c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f32:	83 ec 08             	sub    $0x8,%esp
80104f35:	68 80 39 11 80       	push   $0x80113980
80104f3a:	50                   	push   %eax
80104f3b:	e8 c9 02 00 00       	call   80105209 <sleep>
80104f40:	83 c4 10             	add    $0x10,%esp
  }
80104f43:	e9 ef fd ff ff       	jmp    80104d37 <wait+0x16>
}
80104f48:	c9                   	leave  
80104f49:	c3                   	ret    

80104f4a <scheduler>:
}

#else
void
scheduler(void)
{
80104f4a:	55                   	push   %ebp
80104f4b:	89 e5                	mov    %esp,%ebp
80104f4d:	53                   	push   %ebx
80104f4e:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;
  int idle;  // for checking if processor is idle

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104f51:	e8 9d f5 ff ff       	call   801044f3 <sti>

    idle = 1;  // assume idle unless we schedule a process
80104f56:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104f5d:	83 ec 0c             	sub    $0xc,%esp
80104f60:	68 80 39 11 80       	push   $0x80113980
80104f65:	e8 b9 0d 00 00       	call   80105d23 <acquire>
80104f6a:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f6d:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104f74:	e9 e5 00 00 00       	jmp    8010505e <scheduler+0x114>
      if(p->state != RUNNABLE)
80104f79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f7c:	8b 40 0c             	mov    0xc(%eax),%eax
80104f7f:	83 f8 03             	cmp    $0x3,%eax
80104f82:	0f 85 ce 00 00 00    	jne    80105056 <scheduler+0x10c>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      idle = 0;  // not idle this timeslice
80104f88:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      proc = p;
80104f8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f92:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104f98:	83 ec 0c             	sub    $0xc,%esp
80104f9b:	ff 75 f4             	pushl  -0xc(%ebp)
80104f9e:	e8 ba 3c 00 00       	call   80108c5d <switchuvm>
80104fa3:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104fa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fa9:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      stateListRemove(&ptable.pLists.ready, &ptable.pLists.readyTail, p);
80104fb0:	83 ec 04             	sub    $0x4,%esp
80104fb3:	ff 75 f4             	pushl  -0xc(%ebp)
80104fb6:	68 b8 5e 11 80       	push   $0x80115eb8
80104fbb:	68 b4 5e 11 80       	push   $0x80115eb4
80104fc0:	e8 7f 07 00 00       	call   80105744 <stateListRemove>
80104fc5:	83 c4 10             	add    $0x10,%esp
      stateListAdd(&ptable.pLists.running, &ptable.pLists.runningTail, p);
80104fc8:	83 ec 04             	sub    $0x4,%esp
80104fcb:	ff 75 f4             	pushl  -0xc(%ebp)
80104fce:	68 d8 5e 11 80       	push   $0x80115ed8
80104fd3:	68 d4 5e 11 80       	push   $0x80115ed4
80104fd8:	e8 08 07 00 00       	call   801056e5 <stateListAdd>
80104fdd:	83 c4 10             	add    $0x10,%esp

      proc->cpu_ticks_in = ticks;
80104fe0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fe6:	8b 15 00 67 11 80    	mov    0x80116700,%edx
80104fec:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)

      swtch(&cpu->scheduler, proc->context);
80104ff2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ff8:	8b 40 1c             	mov    0x1c(%eax),%eax
80104ffb:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105002:	83 c2 04             	add    $0x4,%edx
80105005:	83 ec 08             	sub    $0x8,%esp
80105008:	50                   	push   %eax
80105009:	52                   	push   %edx
8010500a:	e8 eb 11 00 00       	call   801061fa <swtch>
8010500f:	83 c4 10             	add    $0x10,%esp

      proc->cpu_ticks_total = proc->cpu_ticks_total + (ticks - proc->cpu_ticks_in);
80105012:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105018:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010501f:	8b 8a 88 00 00 00    	mov    0x88(%edx),%ecx
80105025:	8b 1d 00 67 11 80    	mov    0x80116700,%ebx
8010502b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105032:	8b 92 8c 00 00 00    	mov    0x8c(%edx),%edx
80105038:	29 d3                	sub    %edx,%ebx
8010503a:	89 da                	mov    %ebx,%edx
8010503c:	01 ca                	add    %ecx,%edx
8010503e:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
      switchkvm();
80105044:	e8 f7 3b 00 00       	call   80108c40 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80105049:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80105050:	00 00 00 00 
80105054:	eb 01                	jmp    80105057 <scheduler+0x10d>
    idle = 1;  // assume idle unless we schedule a process
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80105056:	90                   	nop
    sti();

    idle = 1;  // assume idle unless we schedule a process
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105057:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
8010505e:	81 7d f4 b4 5e 11 80 	cmpl   $0x80115eb4,-0xc(%ebp)
80105065:	0f 82 0e ff ff ff    	jb     80104f79 <scheduler+0x2f>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
8010506b:	83 ec 0c             	sub    $0xc,%esp
8010506e:	68 80 39 11 80       	push   $0x80113980
80105073:	e8 12 0d 00 00       	call   80105d8a <release>
80105078:	83 c4 10             	add    $0x10,%esp
    // if idle, wait for next interrupt
    if (idle) {
8010507b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010507f:	0f 84 cc fe ff ff    	je     80104f51 <scheduler+0x7>
      sti();
80105085:	e8 69 f4 ff ff       	call   801044f3 <sti>
      hlt();
8010508a:	e8 4d f4 ff ff       	call   801044dc <hlt>
    }
  }
8010508f:	e9 bd fe ff ff       	jmp    80104f51 <scheduler+0x7>

80105094 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80105094:	55                   	push   %ebp
80105095:	89 e5                	mov    %esp,%ebp
80105097:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
8010509a:	83 ec 0c             	sub    $0xc,%esp
8010509d:	68 80 39 11 80       	push   $0x80113980
801050a2:	e8 af 0d 00 00       	call   80105e56 <holding>
801050a7:	83 c4 10             	add    $0x10,%esp
801050aa:	85 c0                	test   %eax,%eax
801050ac:	75 0d                	jne    801050bb <sched+0x27>
    panic("sched ptable.lock");
801050ae:	83 ec 0c             	sub    $0xc,%esp
801050b1:	68 28 97 10 80       	push   $0x80109728
801050b6:	e8 ab b4 ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
801050bb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801050c1:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801050c7:	83 f8 01             	cmp    $0x1,%eax
801050ca:	74 0d                	je     801050d9 <sched+0x45>
    panic("sched locks");
801050cc:	83 ec 0c             	sub    $0xc,%esp
801050cf:	68 3a 97 10 80       	push   $0x8010973a
801050d4:	e8 8d b4 ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
801050d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050df:	8b 40 0c             	mov    0xc(%eax),%eax
801050e2:	83 f8 04             	cmp    $0x4,%eax
801050e5:	75 0d                	jne    801050f4 <sched+0x60>
    panic("sched running");
801050e7:	83 ec 0c             	sub    $0xc,%esp
801050ea:	68 46 97 10 80       	push   $0x80109746
801050ef:	e8 72 b4 ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
801050f4:	e8 ea f3 ff ff       	call   801044e3 <readeflags>
801050f9:	25 00 02 00 00       	and    $0x200,%eax
801050fe:	85 c0                	test   %eax,%eax
80105100:	74 0d                	je     8010510f <sched+0x7b>
    panic("sched interruptible");
80105102:	83 ec 0c             	sub    $0xc,%esp
80105105:	68 54 97 10 80       	push   $0x80109754
8010510a:	e8 57 b4 ff ff       	call   80100566 <panic>
  intena = cpu->intena;
8010510f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105115:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010511b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
8010511e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105124:	8b 40 04             	mov    0x4(%eax),%eax
80105127:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010512e:	83 c2 1c             	add    $0x1c,%edx
80105131:	83 ec 08             	sub    $0x8,%esp
80105134:	50                   	push   %eax
80105135:	52                   	push   %edx
80105136:	e8 bf 10 00 00       	call   801061fa <swtch>
8010513b:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
8010513e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105144:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105147:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
8010514d:	90                   	nop
8010514e:	c9                   	leave  
8010514f:	c3                   	ret    

80105150 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80105150:	55                   	push   %ebp
80105151:	89 e5                	mov    %esp,%ebp
80105153:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80105156:	83 ec 0c             	sub    $0xc,%esp
80105159:	68 80 39 11 80       	push   $0x80113980
8010515e:	e8 c0 0b 00 00       	call   80105d23 <acquire>
80105163:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80105166:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010516c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
#ifdef CS333_P3P4
  stateListRemove(&ptable.pLists.running, &ptable.pLists.runningTail, proc);
80105173:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105179:	83 ec 04             	sub    $0x4,%esp
8010517c:	50                   	push   %eax
8010517d:	68 d8 5e 11 80       	push   $0x80115ed8
80105182:	68 d4 5e 11 80       	push   $0x80115ed4
80105187:	e8 b8 05 00 00       	call   80105744 <stateListRemove>
8010518c:	83 c4 10             	add    $0x10,%esp
  stateListAdd(&ptable.pLists.ready, &ptable.pLists.readyTail, proc);
8010518f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105195:	83 ec 04             	sub    $0x4,%esp
80105198:	50                   	push   %eax
80105199:	68 b8 5e 11 80       	push   $0x80115eb8
8010519e:	68 b4 5e 11 80       	push   $0x80115eb4
801051a3:	e8 3d 05 00 00       	call   801056e5 <stateListAdd>
801051a8:	83 c4 10             	add    $0x10,%esp
#endif
  sched();
801051ab:	e8 e4 fe ff ff       	call   80105094 <sched>
  release(&ptable.lock);
801051b0:	83 ec 0c             	sub    $0xc,%esp
801051b3:	68 80 39 11 80       	push   $0x80113980
801051b8:	e8 cd 0b 00 00       	call   80105d8a <release>
801051bd:	83 c4 10             	add    $0x10,%esp
}
801051c0:	90                   	nop
801051c1:	c9                   	leave  
801051c2:	c3                   	ret    

801051c3 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801051c3:	55                   	push   %ebp
801051c4:	89 e5                	mov    %esp,%ebp
801051c6:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801051c9:	83 ec 0c             	sub    $0xc,%esp
801051cc:	68 80 39 11 80       	push   $0x80113980
801051d1:	e8 b4 0b 00 00       	call   80105d8a <release>
801051d6:	83 c4 10             	add    $0x10,%esp

  if (first) {
801051d9:	a1 20 c0 10 80       	mov    0x8010c020,%eax
801051de:	85 c0                	test   %eax,%eax
801051e0:	74 24                	je     80105206 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801051e2:	c7 05 20 c0 10 80 00 	movl   $0x0,0x8010c020
801051e9:	00 00 00 
    iinit(ROOTDEV);
801051ec:	83 ec 0c             	sub    $0xc,%esp
801051ef:	6a 01                	push   $0x1
801051f1:	e8 e6 c4 ff ff       	call   801016dc <iinit>
801051f6:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801051f9:	83 ec 0c             	sub    $0xc,%esp
801051fc:	6a 01                	push   $0x1
801051fe:	e8 ca e1 ff ff       	call   801033cd <initlog>
80105203:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80105206:	90                   	nop
80105207:	c9                   	leave  
80105208:	c3                   	ret    

80105209 <sleep>:
// Reacquires lock when awakened.
// 2016/12/28: ticklock removed from xv6. sleep() changed to
// accept a NULL lock to accommodate.
void
sleep(void *chan, struct spinlock *lk)
{
80105209:	55                   	push   %ebp
8010520a:	89 e5                	mov    %esp,%ebp
8010520c:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
8010520f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105215:	85 c0                	test   %eax,%eax
80105217:	75 0d                	jne    80105226 <sleep+0x1d>
    panic("sleep");
80105219:	83 ec 0c             	sub    $0xc,%esp
8010521c:	68 68 97 10 80       	push   $0x80109768
80105221:	e8 40 b3 ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){
80105226:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
8010522d:	74 24                	je     80105253 <sleep+0x4a>
    acquire(&ptable.lock);
8010522f:	83 ec 0c             	sub    $0xc,%esp
80105232:	68 80 39 11 80       	push   $0x80113980
80105237:	e8 e7 0a 00 00       	call   80105d23 <acquire>
8010523c:	83 c4 10             	add    $0x10,%esp
    if (lk) release(lk);
8010523f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105243:	74 0e                	je     80105253 <sleep+0x4a>
80105245:	83 ec 0c             	sub    $0xc,%esp
80105248:	ff 75 0c             	pushl  0xc(%ebp)
8010524b:	e8 3a 0b 00 00       	call   80105d8a <release>
80105250:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80105253:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105259:	8b 55 08             	mov    0x8(%ebp),%edx
8010525c:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
8010525f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105265:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
#ifdef CS333_P3P4
  stateListRemove(&ptable.pLists.running, &ptable.pLists.runningTail, proc);
8010526c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105272:	83 ec 04             	sub    $0x4,%esp
80105275:	50                   	push   %eax
80105276:	68 d8 5e 11 80       	push   $0x80115ed8
8010527b:	68 d4 5e 11 80       	push   $0x80115ed4
80105280:	e8 bf 04 00 00       	call   80105744 <stateListRemove>
80105285:	83 c4 10             	add    $0x10,%esp
  stateListAdd(&ptable.pLists.sleep, &ptable.pLists.sleepTail, proc);
80105288:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010528e:	83 ec 04             	sub    $0x4,%esp
80105291:	50                   	push   %eax
80105292:	68 c8 5e 11 80       	push   $0x80115ec8
80105297:	68 c4 5e 11 80       	push   $0x80115ec4
8010529c:	e8 44 04 00 00       	call   801056e5 <stateListAdd>
801052a1:	83 c4 10             	add    $0x10,%esp
#endif
  sched();
801052a4:	e8 eb fd ff ff       	call   80105094 <sched>

  // Tidy up.
  proc->chan = 0;
801052a9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052af:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){
801052b6:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
801052bd:	74 24                	je     801052e3 <sleep+0xda>
    release(&ptable.lock);
801052bf:	83 ec 0c             	sub    $0xc,%esp
801052c2:	68 80 39 11 80       	push   $0x80113980
801052c7:	e8 be 0a 00 00       	call   80105d8a <release>
801052cc:	83 c4 10             	add    $0x10,%esp
    if (lk) acquire(lk);
801052cf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801052d3:	74 0e                	je     801052e3 <sleep+0xda>
801052d5:	83 ec 0c             	sub    $0xc,%esp
801052d8:	ff 75 0c             	pushl  0xc(%ebp)
801052db:	e8 43 0a 00 00       	call   80105d23 <acquire>
801052e0:	83 c4 10             	add    $0x10,%esp
  }
}
801052e3:	90                   	nop
801052e4:	c9                   	leave  
801052e5:	c3                   	ret    

801052e6 <wakeup1>:
      p->state = RUNNABLE;
}
#else
static void
wakeup1(void *chan)
{
801052e6:	55                   	push   %ebp
801052e7:	89 e5                	mov    %esp,%ebp
801052e9:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  p = ptable.pLists.sleep;
801052ec:	a1 c4 5e 11 80       	mov    0x80115ec4,%eax
801052f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(p)
801052f4:	eb 51                	jmp    80105347 <wakeup1+0x61>
  {
    if(p->chan == chan)
801052f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052f9:	8b 40 20             	mov    0x20(%eax),%eax
801052fc:	3b 45 08             	cmp    0x8(%ebp),%eax
801052ff:	75 3a                	jne    8010533b <wakeup1+0x55>
    {
      p->state = RUNNABLE;
80105301:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105304:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      stateListRemove(&ptable.pLists.sleep, &ptable.pLists.sleepTail, p);
8010530b:	83 ec 04             	sub    $0x4,%esp
8010530e:	ff 75 f4             	pushl  -0xc(%ebp)
80105311:	68 c8 5e 11 80       	push   $0x80115ec8
80105316:	68 c4 5e 11 80       	push   $0x80115ec4
8010531b:	e8 24 04 00 00       	call   80105744 <stateListRemove>
80105320:	83 c4 10             	add    $0x10,%esp
      stateListAdd(&ptable.pLists.ready, &ptable.pLists.readyTail, p);
80105323:	83 ec 04             	sub    $0x4,%esp
80105326:	ff 75 f4             	pushl  -0xc(%ebp)
80105329:	68 b8 5e 11 80       	push   $0x80115eb8
8010532e:	68 b4 5e 11 80       	push   $0x80115eb4
80105333:	e8 ad 03 00 00       	call   801056e5 <stateListAdd>
80105338:	83 c4 10             	add    $0x10,%esp
    }
    p = p->next;
8010533b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010533e:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105344:	89 45 f4             	mov    %eax,-0xc(%ebp)
wakeup1(void *chan)
{
  struct proc *p;

  p = ptable.pLists.sleep;
  while(p)
80105347:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010534b:	75 a9                	jne    801052f6 <wakeup1+0x10>
      stateListRemove(&ptable.pLists.sleep, &ptable.pLists.sleepTail, p);
      stateListAdd(&ptable.pLists.ready, &ptable.pLists.readyTail, p);
    }
    p = p->next;
  }
}
8010534d:	90                   	nop
8010534e:	c9                   	leave  
8010534f:	c3                   	ret    

80105350 <wakeup>:
#endif

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80105350:	55                   	push   %ebp
80105351:	89 e5                	mov    %esp,%ebp
80105353:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80105356:	83 ec 0c             	sub    $0xc,%esp
80105359:	68 80 39 11 80       	push   $0x80113980
8010535e:	e8 c0 09 00 00       	call   80105d23 <acquire>
80105363:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80105366:	83 ec 0c             	sub    $0xc,%esp
80105369:	ff 75 08             	pushl  0x8(%ebp)
8010536c:	e8 75 ff ff ff       	call   801052e6 <wakeup1>
80105371:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80105374:	83 ec 0c             	sub    $0xc,%esp
80105377:	68 80 39 11 80       	push   $0x80113980
8010537c:	e8 09 0a 00 00       	call   80105d8a <release>
80105381:	83 c4 10             	add    $0x10,%esp
}
80105384:	90                   	nop
80105385:	c9                   	leave  
80105386:	c3                   	ret    

80105387 <kill>:
  return -1;
}
#else
int
kill(int pid)
{
80105387:	55                   	push   %ebp
80105388:	89 e5                	mov    %esp,%ebp
8010538a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
8010538d:	83 ec 0c             	sub    $0xc,%esp
80105390:	68 80 39 11 80       	push   $0x80113980
80105395:	e8 89 09 00 00       	call   80105d23 <acquire>
8010539a:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010539d:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
801053a4:	eb 7a                	jmp    80105420 <kill+0x99>
    if(p->pid == pid){
801053a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053a9:	8b 50 10             	mov    0x10(%eax),%edx
801053ac:	8b 45 08             	mov    0x8(%ebp),%eax
801053af:	39 c2                	cmp    %eax,%edx
801053b1:	75 66                	jne    80105419 <kill+0x92>
      p->killed = 1;
801053b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053b6:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801053bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053c0:	8b 40 0c             	mov    0xc(%eax),%eax
801053c3:	83 f8 02             	cmp    $0x2,%eax
801053c6:	75 3a                	jne    80105402 <kill+0x7b>
      {
        stateListRemove(&ptable.pLists.sleep, &ptable.pLists.sleepTail, p);
801053c8:	83 ec 04             	sub    $0x4,%esp
801053cb:	ff 75 f4             	pushl  -0xc(%ebp)
801053ce:	68 c8 5e 11 80       	push   $0x80115ec8
801053d3:	68 c4 5e 11 80       	push   $0x80115ec4
801053d8:	e8 67 03 00 00       	call   80105744 <stateListRemove>
801053dd:	83 c4 10             	add    $0x10,%esp
        stateListAdd(&ptable.pLists.ready, &ptable.pLists.readyTail, p);
801053e0:	83 ec 04             	sub    $0x4,%esp
801053e3:	ff 75 f4             	pushl  -0xc(%ebp)
801053e6:	68 b8 5e 11 80       	push   $0x80115eb8
801053eb:	68 b4 5e 11 80       	push   $0x80115eb4
801053f0:	e8 f0 02 00 00       	call   801056e5 <stateListAdd>
801053f5:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNABLE;
801053f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053fb:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      }
      release(&ptable.lock);
80105402:	83 ec 0c             	sub    $0xc,%esp
80105405:	68 80 39 11 80       	push   $0x80113980
8010540a:	e8 7b 09 00 00       	call   80105d8a <release>
8010540f:	83 c4 10             	add    $0x10,%esp
      return 0;
80105412:	b8 00 00 00 00       	mov    $0x0,%eax
80105417:	eb 29                	jmp    80105442 <kill+0xbb>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105419:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
80105420:	81 7d f4 b4 5e 11 80 	cmpl   $0x80115eb4,-0xc(%ebp)
80105427:	0f 82 79 ff ff ff    	jb     801053a6 <kill+0x1f>
      }
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
8010542d:	83 ec 0c             	sub    $0xc,%esp
80105430:	68 80 39 11 80       	push   $0x80113980
80105435:	e8 50 09 00 00       	call   80105d8a <release>
8010543a:	83 c4 10             	add    $0x10,%esp
  return -1;
8010543d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

}
80105442:	c9                   	leave  
80105443:	c3                   	ret    

80105444 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105444:	55                   	push   %ebp
80105445:	89 e5                	mov    %esp,%ebp
80105447:	53                   	push   %ebx
80105448:	83 ec 44             	sub    $0x44,%esp
  uint current_ticks;
  struct proc *p;
  char *state;
  uint pc[10];
#if defined CS333_P2
  cprintf("\nPID\tName\tUID\tGID\tPPID\tElapsed\tCPU\tState\tSize\t PCs\n");
8010544b:	83 ec 0c             	sub    $0xc,%esp
8010544e:	68 98 97 10 80       	push   $0x80109798
80105453:	e8 6e af ff ff       	call   801003c6 <cprintf>
80105458:	83 c4 10             	add    $0x10,%esp
#elif defined CS333_P1
  cprintf("\nPID\tState\tName\tElapsed\t PCs\n");
#else
  cprintf("\nPID\tState\tName\t PCs\n");
#endif
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010545b:	c7 45 f0 b4 39 11 80 	movl   $0x801139b4,-0x10(%ebp)
80105462:	e9 6b 02 00 00       	jmp    801056d2 <procdump+0x28e>
    if(p->state == UNUSED)
80105467:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010546a:	8b 40 0c             	mov    0xc(%eax),%eax
8010546d:	85 c0                	test   %eax,%eax
8010546f:	0f 84 55 02 00 00    	je     801056ca <procdump+0x286>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105475:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105478:	8b 40 0c             	mov    0xc(%eax),%eax
8010547b:	83 f8 05             	cmp    $0x5,%eax
8010547e:	77 23                	ja     801054a3 <procdump+0x5f>
80105480:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105483:	8b 40 0c             	mov    0xc(%eax),%eax
80105486:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
8010548d:	85 c0                	test   %eax,%eax
8010548f:	74 12                	je     801054a3 <procdump+0x5f>
      state = states[p->state];
80105491:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105494:	8b 40 0c             	mov    0xc(%eax),%eax
80105497:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
8010549e:	89 45 ec             	mov    %eax,-0x14(%ebp)
801054a1:	eb 07                	jmp    801054aa <procdump+0x66>
    else
      state = "???";
801054a3:	c7 45 ec cc 97 10 80 	movl   $0x801097cc,-0x14(%ebp)
    current_ticks = ticks;
801054aa:	a1 00 67 11 80       	mov    0x80116700,%eax
801054af:	89 45 e8             	mov    %eax,-0x18(%ebp)
    i = ((current_ticks-p->start_ticks)%1000);
801054b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054b5:	8b 40 7c             	mov    0x7c(%eax),%eax
801054b8:	8b 55 e8             	mov    -0x18(%ebp),%edx
801054bb:	89 d1                	mov    %edx,%ecx
801054bd:	29 c1                	sub    %eax,%ecx
801054bf:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
801054c4:	89 c8                	mov    %ecx,%eax
801054c6:	f7 e2                	mul    %edx
801054c8:	89 d0                	mov    %edx,%eax
801054ca:	c1 e8 06             	shr    $0x6,%eax
801054cd:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
801054d3:	29 c1                	sub    %eax,%ecx
801054d5:	89 c8                	mov    %ecx,%eax
801054d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
#if defined CS333_P2
    cprintf("%d\t%s\t%d\t%d", p->pid, p->name, p->uid, p->gid);
801054da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054dd:	8b 88 84 00 00 00    	mov    0x84(%eax),%ecx
801054e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054e6:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
801054ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054ef:	8d 58 6c             	lea    0x6c(%eax),%ebx
801054f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054f5:	8b 40 10             	mov    0x10(%eax),%eax
801054f8:	83 ec 0c             	sub    $0xc,%esp
801054fb:	51                   	push   %ecx
801054fc:	52                   	push   %edx
801054fd:	53                   	push   %ebx
801054fe:	50                   	push   %eax
801054ff:	68 d0 97 10 80       	push   $0x801097d0
80105504:	e8 bd ae ff ff       	call   801003c6 <cprintf>
80105509:	83 c4 20             	add    $0x20,%esp
    if(p->pid == 1)
8010550c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010550f:	8b 40 10             	mov    0x10(%eax),%eax
80105512:	83 f8 01             	cmp    $0x1,%eax
80105515:	75 19                	jne    80105530 <procdump+0xec>
      cprintf("\t%d",p->pid);
80105517:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010551a:	8b 40 10             	mov    0x10(%eax),%eax
8010551d:	83 ec 08             	sub    $0x8,%esp
80105520:	50                   	push   %eax
80105521:	68 dc 97 10 80       	push   $0x801097dc
80105526:	e8 9b ae ff ff       	call   801003c6 <cprintf>
8010552b:	83 c4 10             	add    $0x10,%esp
8010552e:	eb 1a                	jmp    8010554a <procdump+0x106>
    else
      cprintf("\t%d",p->parent->pid);
80105530:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105533:	8b 40 14             	mov    0x14(%eax),%eax
80105536:	8b 40 10             	mov    0x10(%eax),%eax
80105539:	83 ec 08             	sub    $0x8,%esp
8010553c:	50                   	push   %eax
8010553d:	68 dc 97 10 80       	push   $0x801097dc
80105542:	e8 7f ae ff ff       	call   801003c6 <cprintf>
80105547:	83 c4 10             	add    $0x10,%esp
    cprintf("\t%d.", ((current_ticks-p->start_ticks)/1000));
8010554a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010554d:	8b 40 7c             	mov    0x7c(%eax),%eax
80105550:	8b 55 e8             	mov    -0x18(%ebp),%edx
80105553:	29 c2                	sub    %eax,%edx
80105555:	89 d0                	mov    %edx,%eax
80105557:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
8010555c:	f7 e2                	mul    %edx
8010555e:	89 d0                	mov    %edx,%eax
80105560:	c1 e8 06             	shr    $0x6,%eax
80105563:	83 ec 08             	sub    $0x8,%esp
80105566:	50                   	push   %eax
80105567:	68 e0 97 10 80       	push   $0x801097e0
8010556c:	e8 55 ae ff ff       	call   801003c6 <cprintf>
80105571:	83 c4 10             	add    $0x10,%esp
    if (i<100)
80105574:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
80105578:	7f 10                	jg     8010558a <procdump+0x146>
      cprintf("0");
8010557a:	83 ec 0c             	sub    $0xc,%esp
8010557d:	68 e5 97 10 80       	push   $0x801097e5
80105582:	e8 3f ae ff ff       	call   801003c6 <cprintf>
80105587:	83 c4 10             	add    $0x10,%esp
    if (i<10)
8010558a:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010558e:	7f 10                	jg     801055a0 <procdump+0x15c>
      cprintf("0");
80105590:	83 ec 0c             	sub    $0xc,%esp
80105593:	68 e5 97 10 80       	push   $0x801097e5
80105598:	e8 29 ae ff ff       	call   801003c6 <cprintf>
8010559d:	83 c4 10             	add    $0x10,%esp
    cprintf("%d", i);
801055a0:	83 ec 08             	sub    $0x8,%esp
801055a3:	ff 75 f4             	pushl  -0xc(%ebp)
801055a6:	68 e7 97 10 80       	push   $0x801097e7
801055ab:	e8 16 ae ff ff       	call   801003c6 <cprintf>
801055b0:	83 c4 10             	add    $0x10,%esp
    i = p->cpu_ticks_total;
801055b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055b6:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
801055bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("\t%d.", i/1000);
801055bf:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801055c2:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
801055c7:	89 c8                	mov    %ecx,%eax
801055c9:	f7 ea                	imul   %edx
801055cb:	c1 fa 06             	sar    $0x6,%edx
801055ce:	89 c8                	mov    %ecx,%eax
801055d0:	c1 f8 1f             	sar    $0x1f,%eax
801055d3:	29 c2                	sub    %eax,%edx
801055d5:	89 d0                	mov    %edx,%eax
801055d7:	83 ec 08             	sub    $0x8,%esp
801055da:	50                   	push   %eax
801055db:	68 e0 97 10 80       	push   $0x801097e0
801055e0:	e8 e1 ad ff ff       	call   801003c6 <cprintf>
801055e5:	83 c4 10             	add    $0x10,%esp
    i = i%1000;
801055e8:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801055eb:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
801055f0:	89 c8                	mov    %ecx,%eax
801055f2:	f7 ea                	imul   %edx
801055f4:	c1 fa 06             	sar    $0x6,%edx
801055f7:	89 c8                	mov    %ecx,%eax
801055f9:	c1 f8 1f             	sar    $0x1f,%eax
801055fc:	29 c2                	sub    %eax,%edx
801055fe:	89 d0                	mov    %edx,%eax
80105600:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
80105606:	29 c1                	sub    %eax,%ecx
80105608:	89 c8                	mov    %ecx,%eax
8010560a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i<100)
8010560d:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
80105611:	7f 10                	jg     80105623 <procdump+0x1df>
      cprintf("0");
80105613:	83 ec 0c             	sub    $0xc,%esp
80105616:	68 e5 97 10 80       	push   $0x801097e5
8010561b:	e8 a6 ad ff ff       	call   801003c6 <cprintf>
80105620:	83 c4 10             	add    $0x10,%esp
    if (i<10)
80105623:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105627:	7f 10                	jg     80105639 <procdump+0x1f5>
      cprintf("0");
80105629:	83 ec 0c             	sub    $0xc,%esp
8010562c:	68 e5 97 10 80       	push   $0x801097e5
80105631:	e8 90 ad ff ff       	call   801003c6 <cprintf>
80105636:	83 c4 10             	add    $0x10,%esp
    cprintf("%d\t%s\t%d\t", i, state, p->sz);
80105639:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010563c:	8b 00                	mov    (%eax),%eax
8010563e:	50                   	push   %eax
8010563f:	ff 75 ec             	pushl  -0x14(%ebp)
80105642:	ff 75 f4             	pushl  -0xc(%ebp)
80105645:	68 ea 97 10 80       	push   $0x801097ea
8010564a:	e8 77 ad ff ff       	call   801003c6 <cprintf>
8010564f:	83 c4 10             	add    $0x10,%esp
      cprintf("0");
    cprintf("%d\t",i);
#else
    cprintf("%d\t%s\t%s", p->pid, state, p->name);
#endif
    i = 0;
80105652:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(p->state == SLEEPING){
80105659:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010565c:	8b 40 0c             	mov    0xc(%eax),%eax
8010565f:	83 f8 02             	cmp    $0x2,%eax
80105662:	75 54                	jne    801056b8 <procdump+0x274>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105664:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105667:	8b 40 1c             	mov    0x1c(%eax),%eax
8010566a:	8b 40 0c             	mov    0xc(%eax),%eax
8010566d:	83 c0 08             	add    $0x8,%eax
80105670:	89 c2                	mov    %eax,%edx
80105672:	83 ec 08             	sub    $0x8,%esp
80105675:	8d 45 c0             	lea    -0x40(%ebp),%eax
80105678:	50                   	push   %eax
80105679:	52                   	push   %edx
8010567a:	e8 5d 07 00 00       	call   80105ddc <getcallerpcs>
8010567f:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105682:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105689:	eb 1c                	jmp    801056a7 <procdump+0x263>
        cprintf(" %p", pc[i]);
8010568b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010568e:	8b 44 85 c0          	mov    -0x40(%ebp,%eax,4),%eax
80105692:	83 ec 08             	sub    $0x8,%esp
80105695:	50                   	push   %eax
80105696:	68 f4 97 10 80       	push   $0x801097f4
8010569b:	e8 26 ad ff ff       	call   801003c6 <cprintf>
801056a0:	83 c4 10             	add    $0x10,%esp
    cprintf("%d\t%s\t%s", p->pid, state, p->name);
#endif
    i = 0;
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
801056a3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801056a7:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801056ab:	7f 0b                	jg     801056b8 <procdump+0x274>
801056ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056b0:	8b 44 85 c0          	mov    -0x40(%ebp,%eax,4),%eax
801056b4:	85 c0                	test   %eax,%eax
801056b6:	75 d3                	jne    8010568b <procdump+0x247>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801056b8:	83 ec 0c             	sub    $0xc,%esp
801056bb:	68 f8 97 10 80       	push   $0x801097f8
801056c0:	e8 01 ad ff ff       	call   801003c6 <cprintf>
801056c5:	83 c4 10             	add    $0x10,%esp
801056c8:	eb 01                	jmp    801056cb <procdump+0x287>
#else
  cprintf("\nPID\tState\tName\t PCs\n");
#endif
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
801056ca:	90                   	nop
#elif defined CS333_P1
  cprintf("\nPID\tState\tName\tElapsed\t PCs\n");
#else
  cprintf("\nPID\tState\tName\t PCs\n");
#endif
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801056cb:	81 45 f0 94 00 00 00 	addl   $0x94,-0x10(%ebp)
801056d2:	81 7d f0 b4 5e 11 80 	cmpl   $0x80115eb4,-0x10(%ebp)
801056d9:	0f 82 88 fd ff ff    	jb     80105467 <procdump+0x23>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
801056df:	90                   	nop
801056e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801056e3:	c9                   	leave  
801056e4:	c3                   	ret    

801056e5 <stateListAdd>:


#ifdef CS333_P3P4
static int
stateListAdd(struct proc** head, struct proc** tail, struct proc* p)
{
801056e5:	55                   	push   %ebp
801056e6:	89 e5                	mov    %esp,%ebp
  if (*head == 0) {
801056e8:	8b 45 08             	mov    0x8(%ebp),%eax
801056eb:	8b 00                	mov    (%eax),%eax
801056ed:	85 c0                	test   %eax,%eax
801056ef:	75 1f                	jne    80105710 <stateListAdd+0x2b>
    *head = p;
801056f1:	8b 45 08             	mov    0x8(%ebp),%eax
801056f4:	8b 55 10             	mov    0x10(%ebp),%edx
801056f7:	89 10                	mov    %edx,(%eax)
    *tail = p;
801056f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801056fc:	8b 55 10             	mov    0x10(%ebp),%edx
801056ff:	89 10                	mov    %edx,(%eax)
    p->next = 0;
80105701:	8b 45 10             	mov    0x10(%ebp),%eax
80105704:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
8010570b:	00 00 00 
8010570e:	eb 2d                	jmp    8010573d <stateListAdd+0x58>
  } else {
    (*tail)->next = p;
80105710:	8b 45 0c             	mov    0xc(%ebp),%eax
80105713:	8b 00                	mov    (%eax),%eax
80105715:	8b 55 10             	mov    0x10(%ebp),%edx
80105718:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
    *tail = (*tail)->next;
8010571e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105721:	8b 00                	mov    (%eax),%eax
80105723:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
80105729:	8b 45 0c             	mov    0xc(%ebp),%eax
8010572c:	89 10                	mov    %edx,(%eax)
    (*tail)->next = 0;
8010572e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105731:	8b 00                	mov    (%eax),%eax
80105733:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
8010573a:	00 00 00 
  }

  return 0;
8010573d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105742:	5d                   	pop    %ebp
80105743:	c3                   	ret    

80105744 <stateListRemove>:

static int
stateListRemove(struct proc** head, struct proc** tail, struct proc* p)
{
80105744:	55                   	push   %ebp
80105745:	89 e5                	mov    %esp,%ebp
80105747:	83 ec 10             	sub    $0x10,%esp
  if (*head == 0 || *tail == 0 || p == 0) {
8010574a:	8b 45 08             	mov    0x8(%ebp),%eax
8010574d:	8b 00                	mov    (%eax),%eax
8010574f:	85 c0                	test   %eax,%eax
80105751:	74 0f                	je     80105762 <stateListRemove+0x1e>
80105753:	8b 45 0c             	mov    0xc(%ebp),%eax
80105756:	8b 00                	mov    (%eax),%eax
80105758:	85 c0                	test   %eax,%eax
8010575a:	74 06                	je     80105762 <stateListRemove+0x1e>
8010575c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105760:	75 0a                	jne    8010576c <stateListRemove+0x28>
    return -1;
80105762:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105767:	e9 a5 00 00 00       	jmp    80105811 <stateListRemove+0xcd>
  }

  struct proc* current = *head;
8010576c:	8b 45 08             	mov    0x8(%ebp),%eax
8010576f:	8b 00                	mov    (%eax),%eax
80105771:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct proc* previous = 0;
80105774:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

  if (current == p) {
8010577b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010577e:	3b 45 10             	cmp    0x10(%ebp),%eax
80105781:	75 31                	jne    801057b4 <stateListRemove+0x70>
    *head = (*head)->next;
80105783:	8b 45 08             	mov    0x8(%ebp),%eax
80105786:	8b 00                	mov    (%eax),%eax
80105788:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
8010578e:	8b 45 08             	mov    0x8(%ebp),%eax
80105791:	89 10                	mov    %edx,(%eax)
    return 0;
80105793:	b8 00 00 00 00       	mov    $0x0,%eax
80105798:	eb 77                	jmp    80105811 <stateListRemove+0xcd>
  }

  while(current) {
    if (current == p) {
8010579a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010579d:	3b 45 10             	cmp    0x10(%ebp),%eax
801057a0:	74 1a                	je     801057bc <stateListRemove+0x78>
      break;
    }

    previous = current;
801057a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057a5:	89 45 f8             	mov    %eax,-0x8(%ebp)
    current = current->next;
801057a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057ab:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801057b1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if (current == p) {
    *head = (*head)->next;
    return 0;
  }

  while(current) {
801057b4:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801057b8:	75 e0                	jne    8010579a <stateListRemove+0x56>
801057ba:	eb 01                	jmp    801057bd <stateListRemove+0x79>
    if (current == p) {
      break;
801057bc:	90                   	nop
    previous = current;
    current = current->next;
  }

  // Process not found, hit eject.
  if (current == 0) {
801057bd:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801057c1:	75 07                	jne    801057ca <stateListRemove+0x86>
    return -1;
801057c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057c8:	eb 47                	jmp    80105811 <stateListRemove+0xcd>
  }

  // Process found. Set the appropriate next pointer.
  if (current == *tail) {
801057ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801057cd:	8b 00                	mov    (%eax),%eax
801057cf:	3b 45 fc             	cmp    -0x4(%ebp),%eax
801057d2:	75 19                	jne    801057ed <stateListRemove+0xa9>
    *tail = previous;
801057d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801057d7:	8b 55 f8             	mov    -0x8(%ebp),%edx
801057da:	89 10                	mov    %edx,(%eax)
    (*tail)->next = 0;
801057dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801057df:	8b 00                	mov    (%eax),%eax
801057e1:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
801057e8:	00 00 00 
801057eb:	eb 12                	jmp    801057ff <stateListRemove+0xbb>
  } else {
    previous->next = current->next;
801057ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057f0:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
801057f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801057f9:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
  }

  // Make sure p->next doesn't point into the list.
  p->next = 0;
801057ff:	8b 45 10             	mov    0x10(%ebp),%eax
80105802:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80105809:	00 00 00 

  return 0;
8010580c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105811:	c9                   	leave  
80105812:	c3                   	ret    

80105813 <initProcessLists>:

static void
initProcessLists(void) {
80105813:	55                   	push   %ebp
80105814:	89 e5                	mov    %esp,%ebp
  ptable.pLists.ready = 0;
80105816:	c7 05 b4 5e 11 80 00 	movl   $0x0,0x80115eb4
8010581d:	00 00 00 
  ptable.pLists.readyTail = 0;
80105820:	c7 05 b8 5e 11 80 00 	movl   $0x0,0x80115eb8
80105827:	00 00 00 
  ptable.pLists.free = 0;
8010582a:	c7 05 bc 5e 11 80 00 	movl   $0x0,0x80115ebc
80105831:	00 00 00 
  ptable.pLists.freeTail = 0;
80105834:	c7 05 c0 5e 11 80 00 	movl   $0x0,0x80115ec0
8010583b:	00 00 00 
  ptable.pLists.sleep = 0;
8010583e:	c7 05 c4 5e 11 80 00 	movl   $0x0,0x80115ec4
80105845:	00 00 00 
  ptable.pLists.sleepTail = 0;
80105848:	c7 05 c8 5e 11 80 00 	movl   $0x0,0x80115ec8
8010584f:	00 00 00 
  ptable.pLists.zombie = 0;
80105852:	c7 05 cc 5e 11 80 00 	movl   $0x0,0x80115ecc
80105859:	00 00 00 
  ptable.pLists.zombieTail = 0;
8010585c:	c7 05 d0 5e 11 80 00 	movl   $0x0,0x80115ed0
80105863:	00 00 00 
  ptable.pLists.running = 0;
80105866:	c7 05 d4 5e 11 80 00 	movl   $0x0,0x80115ed4
8010586d:	00 00 00 
  ptable.pLists.runningTail = 0;
80105870:	c7 05 d8 5e 11 80 00 	movl   $0x0,0x80115ed8
80105877:	00 00 00 
  ptable.pLists.embryo = 0;
8010587a:	c7 05 dc 5e 11 80 00 	movl   $0x0,0x80115edc
80105881:	00 00 00 
  ptable.pLists.embryoTail = 0;
80105884:	c7 05 e0 5e 11 80 00 	movl   $0x0,0x80115ee0
8010588b:	00 00 00 
}
8010588e:	90                   	nop
8010588f:	5d                   	pop    %ebp
80105890:	c3                   	ret    

80105891 <initFreeList>:

static void
initFreeList(void) {
80105891:	55                   	push   %ebp
80105892:	89 e5                	mov    %esp,%ebp
80105894:	83 ec 18             	sub    $0x18,%esp
  if (!holding(&ptable.lock)) {
80105897:	83 ec 0c             	sub    $0xc,%esp
8010589a:	68 80 39 11 80       	push   $0x80113980
8010589f:	e8 b2 05 00 00       	call   80105e56 <holding>
801058a4:	83 c4 10             	add    $0x10,%esp
801058a7:	85 c0                	test   %eax,%eax
801058a9:	75 0d                	jne    801058b8 <initFreeList+0x27>
    panic("acquire the ptable lock before calling initFreeList\n");
801058ab:	83 ec 0c             	sub    $0xc,%esp
801058ae:	68 fc 97 10 80       	push   $0x801097fc
801058b3:	e8 ae ac ff ff       	call   80100566 <panic>
  }

  struct proc* p;

  for (p = ptable.proc; p < ptable.proc + NPROC; ++p) {
801058b8:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
801058bf:	eb 29                	jmp    801058ea <initFreeList+0x59>
    p->state = UNUSED;
801058c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058c4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail, p);
801058cb:	83 ec 04             	sub    $0x4,%esp
801058ce:	ff 75 f4             	pushl  -0xc(%ebp)
801058d1:	68 c0 5e 11 80       	push   $0x80115ec0
801058d6:	68 bc 5e 11 80       	push   $0x80115ebc
801058db:	e8 05 fe ff ff       	call   801056e5 <stateListAdd>
801058e0:	83 c4 10             	add    $0x10,%esp
    panic("acquire the ptable lock before calling initFreeList\n");
  }

  struct proc* p;

  for (p = ptable.proc; p < ptable.proc + NPROC; ++p) {
801058e3:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
801058ea:	b8 b4 5e 11 80       	mov    $0x80115eb4,%eax
801058ef:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801058f2:	72 cd                	jb     801058c1 <initFreeList+0x30>
    p->state = UNUSED;
    stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail, p);
  }
}
801058f4:	90                   	nop
801058f5:	c9                   	leave  
801058f6:	c3                   	ret    

801058f7 <getprocs>:
#endif

//Get all current processes within the system.
int
getprocs(int max, struct uproc* proctable)
{
801058f7:	55                   	push   %ebp
801058f8:	89 e5                	mov    %esp,%ebp
801058fa:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int i;

  //LOCK PTABLE
  acquire(&ptable.lock);
801058fd:	83 ec 0c             	sub    $0xc,%esp
80105900:	68 80 39 11 80       	push   $0x80113980
80105905:	e8 19 04 00 00       	call   80105d23 <acquire>
8010590a:	83 c4 10             	add    $0x10,%esp

  //ptable gets incremented within forloop, i get incremented at the end
  //of the forloop.
  for(i=0, p = ptable.proc; p < &ptable.proc[NPROC] && i<max; p++)
8010590d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80105914:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
8010591b:	e9 35 01 00 00       	jmp    80105a55 <getprocs+0x15e>
  {
    //copy all the info into one element of the array
    //skip if the process is in the unused state
    if(p->state != UNUSED && p->state != EMBRYO)
80105920:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105923:	8b 40 0c             	mov    0xc(%eax),%eax
80105926:	85 c0                	test   %eax,%eax
80105928:	0f 84 20 01 00 00    	je     80105a4e <getprocs+0x157>
8010592e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105931:	8b 40 0c             	mov    0xc(%eax),%eax
80105934:	83 f8 01             	cmp    $0x1,%eax
80105937:	0f 84 11 01 00 00    	je     80105a4e <getprocs+0x157>
    {
      proctable[i].pid = p->pid;
8010593d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105940:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105943:	8b 45 0c             	mov    0xc(%ebp),%eax
80105946:	01 c2                	add    %eax,%edx
80105948:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010594b:	8b 40 10             	mov    0x10(%eax),%eax
8010594e:	89 02                	mov    %eax,(%edx)
      proctable[i].uid = p->uid;
80105950:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105953:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105956:	8b 45 0c             	mov    0xc(%ebp),%eax
80105959:	01 c2                	add    %eax,%edx
8010595b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010595e:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105964:	89 42 04             	mov    %eax,0x4(%edx)
      proctable[i].gid = p->gid;
80105967:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010596a:	6b d0 5c             	imul   $0x5c,%eax,%edx
8010596d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105970:	01 c2                	add    %eax,%edx
80105972:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105975:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
8010597b:	89 42 08             	mov    %eax,0x8(%edx)
      if(p->parent != 0)
8010597e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105981:	8b 40 14             	mov    0x14(%eax),%eax
80105984:	85 c0                	test   %eax,%eax
80105986:	74 19                	je     801059a1 <getprocs+0xaa>
        proctable[i].ppid = p->parent->pid;
80105988:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010598b:	6b d0 5c             	imul   $0x5c,%eax,%edx
8010598e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105991:	01 c2                	add    %eax,%edx
80105993:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105996:	8b 40 14             	mov    0x14(%eax),%eax
80105999:	8b 40 10             	mov    0x10(%eax),%eax
8010599c:	89 42 0c             	mov    %eax,0xc(%edx)
8010599f:	eb 14                	jmp    801059b5 <getprocs+0xbe>
      else
        proctable[i].ppid = p->pid;
801059a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059a4:	6b d0 5c             	imul   $0x5c,%eax,%edx
801059a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801059aa:	01 c2                	add    %eax,%edx
801059ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059af:	8b 40 10             	mov    0x10(%eax),%eax
801059b2:	89 42 0c             	mov    %eax,0xc(%edx)

      //Get the current ticks for elapsed ticks.
      proctable[i].elapsed_ticks = ticks-p->start_ticks;
801059b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059b8:	6b d0 5c             	imul   $0x5c,%eax,%edx
801059bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801059be:	01 c2                	add    %eax,%edx
801059c0:	8b 0d 00 67 11 80    	mov    0x80116700,%ecx
801059c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c9:	8b 40 7c             	mov    0x7c(%eax),%eax
801059cc:	29 c1                	sub    %eax,%ecx
801059ce:	89 c8                	mov    %ecx,%eax
801059d0:	89 42 10             	mov    %eax,0x10(%edx)
      proctable[i].CPU_total_ticks = p->cpu_ticks_total;
801059d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059d6:	6b d0 5c             	imul   $0x5c,%eax,%edx
801059d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801059dc:	01 c2                	add    %eax,%edx
801059de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059e1:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
801059e7:	89 42 14             	mov    %eax,0x14(%edx)
      safestrcpy(proctable[i].state, states[p->state], sizeof(proctable[i].state));
801059ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ed:	8b 40 0c             	mov    0xc(%eax),%eax
801059f0:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
801059f7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059fa:	6b ca 5c             	imul   $0x5c,%edx,%ecx
801059fd:	8b 55 0c             	mov    0xc(%ebp),%edx
80105a00:	01 ca                	add    %ecx,%edx
80105a02:	83 c2 18             	add    $0x18,%edx
80105a05:	83 ec 04             	sub    $0x4,%esp
80105a08:	6a 20                	push   $0x20
80105a0a:	50                   	push   %eax
80105a0b:	52                   	push   %edx
80105a0c:	e8 78 07 00 00       	call   80106189 <safestrcpy>
80105a11:	83 c4 10             	add    $0x10,%esp
      proctable[i].size = p->sz;
80105a14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a17:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105a1a:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a1d:	01 c2                	add    %eax,%edx
80105a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a22:	8b 00                	mov    (%eax),%eax
80105a24:	89 42 38             	mov    %eax,0x38(%edx)
      safestrcpy(proctable[i].name, p->name, sizeof(p->name));
80105a27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a2a:	8d 50 6c             	lea    0x6c(%eax),%edx
80105a2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a30:	6b c8 5c             	imul   $0x5c,%eax,%ecx
80105a33:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a36:	01 c8                	add    %ecx,%eax
80105a38:	83 c0 3c             	add    $0x3c,%eax
80105a3b:	83 ec 04             	sub    $0x4,%esp
80105a3e:	6a 10                	push   $0x10
80105a40:	52                   	push   %edx
80105a41:	50                   	push   %eax
80105a42:	e8 42 07 00 00       	call   80106189 <safestrcpy>
80105a47:	83 c4 10             	add    $0x10,%esp

      //Increment the array that is having info copied into
      ++i;
80105a4a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  //LOCK PTABLE
  acquire(&ptable.lock);

  //ptable gets incremented within forloop, i get incremented at the end
  //of the forloop.
  for(i=0, p = ptable.proc; p < &ptable.proc[NPROC] && i<max; p++)
80105a4e:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
80105a55:	81 7d f4 b4 5e 11 80 	cmpl   $0x80115eb4,-0xc(%ebp)
80105a5c:	73 0c                	jae    80105a6a <getprocs+0x173>
80105a5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a61:	3b 45 08             	cmp    0x8(%ebp),%eax
80105a64:	0f 8c b6 fe ff ff    	jl     80105920 <getprocs+0x29>

    }
  }

  //UNLOCK PTABLE
  release(&ptable.lock);
80105a6a:	83 ec 0c             	sub    $0xc,%esp
80105a6d:	68 80 39 11 80       	push   $0x80113980
80105a72:	e8 13 03 00 00       	call   80105d8a <release>
80105a77:	83 c4 10             	add    $0x10,%esp

  return i;
80105a7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105a7d:	c9                   	leave  
80105a7e:	c3                   	ret    

80105a7f <piddump>:

void
piddump(void)
{
80105a7f:	55                   	push   %ebp
80105a80:	89 e5                	mov    %esp,%ebp
80105a82:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  acquire(&ptable.lock);
80105a85:	83 ec 0c             	sub    $0xc,%esp
80105a88:	68 80 39 11 80       	push   $0x80113980
80105a8d:	e8 91 02 00 00       	call   80105d23 <acquire>
80105a92:	83 c4 10             	add    $0x10,%esp
  p = ptable.pLists.ready;
80105a95:	a1 b4 5e 11 80       	mov    0x80115eb4,%eax
80105a9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cprintf("\nReady List Processes:\n");
80105a9d:	83 ec 0c             	sub    $0xc,%esp
80105aa0:	68 31 98 10 80       	push   $0x80109831
80105aa5:	e8 1c a9 ff ff       	call   801003c6 <cprintf>
80105aaa:	83 c4 10             	add    $0x10,%esp
  while(p)
80105aad:	eb 40                	jmp    80105aef <piddump+0x70>
  {
    cprintf("%d", p->pid);
80105aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ab2:	8b 40 10             	mov    0x10(%eax),%eax
80105ab5:	83 ec 08             	sub    $0x8,%esp
80105ab8:	50                   	push   %eax
80105ab9:	68 e7 97 10 80       	push   $0x801097e7
80105abe:	e8 03 a9 ff ff       	call   801003c6 <cprintf>
80105ac3:	83 c4 10             	add    $0x10,%esp
    if(p->next)
80105ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ac9:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105acf:	85 c0                	test   %eax,%eax
80105ad1:	74 10                	je     80105ae3 <piddump+0x64>
      cprintf(" -> ");
80105ad3:	83 ec 0c             	sub    $0xc,%esp
80105ad6:	68 49 98 10 80       	push   $0x80109849
80105adb:	e8 e6 a8 ff ff       	call   801003c6 <cprintf>
80105ae0:	83 c4 10             	add    $0x10,%esp
    p = p->next;
80105ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ae6:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105aec:	89 45 f4             	mov    %eax,-0xc(%ebp)
{
  struct proc *p;
  acquire(&ptable.lock);
  p = ptable.pLists.ready;
  cprintf("\nReady List Processes:\n");
  while(p)
80105aef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105af3:	75 ba                	jne    80105aaf <piddump+0x30>
    cprintf("%d", p->pid);
    if(p->next)
      cprintf(" -> ");
    p = p->next;
  }
  cprintf("\n");
80105af5:	83 ec 0c             	sub    $0xc,%esp
80105af8:	68 f8 97 10 80       	push   $0x801097f8
80105afd:	e8 c4 a8 ff ff       	call   801003c6 <cprintf>
80105b02:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80105b05:	83 ec 0c             	sub    $0xc,%esp
80105b08:	68 80 39 11 80       	push   $0x80113980
80105b0d:	e8 78 02 00 00       	call   80105d8a <release>
80105b12:	83 c4 10             	add    $0x10,%esp
}
80105b15:	90                   	nop
80105b16:	c9                   	leave  
80105b17:	c3                   	ret    

80105b18 <freedump>:

void
freedump(void)
{
80105b18:	55                   	push   %ebp
80105b19:	89 e5                	mov    %esp,%ebp
80105b1b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int counter = 0;
80105b1e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  acquire(&ptable.lock);
80105b25:	83 ec 0c             	sub    $0xc,%esp
80105b28:	68 80 39 11 80       	push   $0x80113980
80105b2d:	e8 f1 01 00 00       	call   80105d23 <acquire>
80105b32:	83 c4 10             	add    $0x10,%esp
  p = ptable.pLists.free;
80105b35:	a1 bc 5e 11 80       	mov    0x80115ebc,%eax
80105b3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(p)
80105b3d:	eb 10                	jmp    80105b4f <freedump+0x37>
  {
    p = p->next;
80105b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b42:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105b48:	89 45 f4             	mov    %eax,-0xc(%ebp)
    ++counter;
80105b4b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
{
  struct proc *p;
  int counter = 0;
  acquire(&ptable.lock);
  p = ptable.pLists.free;
  while(p)
80105b4f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b53:	75 ea                	jne    80105b3f <freedump+0x27>
  {
    p = p->next;
    ++counter;
  }

  cprintf("\nFree List Size: %d processes\n", counter);
80105b55:	83 ec 08             	sub    $0x8,%esp
80105b58:	ff 75 f0             	pushl  -0x10(%ebp)
80105b5b:	68 50 98 10 80       	push   $0x80109850
80105b60:	e8 61 a8 ff ff       	call   801003c6 <cprintf>
80105b65:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80105b68:	83 ec 0c             	sub    $0xc,%esp
80105b6b:	68 80 39 11 80       	push   $0x80113980
80105b70:	e8 15 02 00 00       	call   80105d8a <release>
80105b75:	83 c4 10             	add    $0x10,%esp
}
80105b78:	90                   	nop
80105b79:	c9                   	leave  
80105b7a:	c3                   	ret    

80105b7b <sleepdump>:

void
sleepdump(void)
{
80105b7b:	55                   	push   %ebp
80105b7c:	89 e5                	mov    %esp,%ebp
80105b7e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  acquire(&ptable.lock);
80105b81:	83 ec 0c             	sub    $0xc,%esp
80105b84:	68 80 39 11 80       	push   $0x80113980
80105b89:	e8 95 01 00 00       	call   80105d23 <acquire>
80105b8e:	83 c4 10             	add    $0x10,%esp
  p = ptable.pLists.sleep;
80105b91:	a1 c4 5e 11 80       	mov    0x80115ec4,%eax
80105b96:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cprintf("\nSleep List Processes:\n");
80105b99:	83 ec 0c             	sub    $0xc,%esp
80105b9c:	68 6f 98 10 80       	push   $0x8010986f
80105ba1:	e8 20 a8 ff ff       	call   801003c6 <cprintf>
80105ba6:	83 c4 10             	add    $0x10,%esp
  while(p)
80105ba9:	eb 40                	jmp    80105beb <sleepdump+0x70>
  {
    cprintf("%d", p->pid);
80105bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bae:	8b 40 10             	mov    0x10(%eax),%eax
80105bb1:	83 ec 08             	sub    $0x8,%esp
80105bb4:	50                   	push   %eax
80105bb5:	68 e7 97 10 80       	push   $0x801097e7
80105bba:	e8 07 a8 ff ff       	call   801003c6 <cprintf>
80105bbf:	83 c4 10             	add    $0x10,%esp
    if(p->next)
80105bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc5:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105bcb:	85 c0                	test   %eax,%eax
80105bcd:	74 10                	je     80105bdf <sleepdump+0x64>
      cprintf(" -> ");
80105bcf:	83 ec 0c             	sub    $0xc,%esp
80105bd2:	68 49 98 10 80       	push   $0x80109849
80105bd7:	e8 ea a7 ff ff       	call   801003c6 <cprintf>
80105bdc:	83 c4 10             	add    $0x10,%esp
    p = p->next;
80105bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105be2:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105be8:	89 45 f4             	mov    %eax,-0xc(%ebp)
{
  struct proc *p;
  acquire(&ptable.lock);
  p = ptable.pLists.sleep;
  cprintf("\nSleep List Processes:\n");
  while(p)
80105beb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bef:	75 ba                	jne    80105bab <sleepdump+0x30>
    cprintf("%d", p->pid);
    if(p->next)
      cprintf(" -> ");
    p = p->next;
  }
  cprintf("\n");
80105bf1:	83 ec 0c             	sub    $0xc,%esp
80105bf4:	68 f8 97 10 80       	push   $0x801097f8
80105bf9:	e8 c8 a7 ff ff       	call   801003c6 <cprintf>
80105bfe:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80105c01:	83 ec 0c             	sub    $0xc,%esp
80105c04:	68 80 39 11 80       	push   $0x80113980
80105c09:	e8 7c 01 00 00       	call   80105d8a <release>
80105c0e:	83 c4 10             	add    $0x10,%esp
}
80105c11:	90                   	nop
80105c12:	c9                   	leave  
80105c13:	c3                   	ret    

80105c14 <zombiedump>:

void
zombiedump(void)
{
80105c14:	55                   	push   %ebp
80105c15:	89 e5                	mov    %esp,%ebp
80105c17:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  acquire(&ptable.lock);
80105c1a:	83 ec 0c             	sub    $0xc,%esp
80105c1d:	68 80 39 11 80       	push   $0x80113980
80105c22:	e8 fc 00 00 00       	call   80105d23 <acquire>
80105c27:	83 c4 10             	add    $0x10,%esp
  p = ptable.pLists.zombie;
80105c2a:	a1 cc 5e 11 80       	mov    0x80115ecc,%eax
80105c2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cprintf("\nZombie List Processes:\n");
80105c32:	83 ec 0c             	sub    $0xc,%esp
80105c35:	68 87 98 10 80       	push   $0x80109887
80105c3a:	e8 87 a7 ff ff       	call   801003c6 <cprintf>
80105c3f:	83 c4 10             	add    $0x10,%esp
  while(p)
80105c42:	eb 5c                	jmp    80105ca0 <zombiedump+0x8c>
  {
    cprintf("(PID%d, PPID%d)", p->pid, (p->parent? p->parent->pid : p->pid));
80105c44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c47:	8b 40 14             	mov    0x14(%eax),%eax
80105c4a:	85 c0                	test   %eax,%eax
80105c4c:	74 0b                	je     80105c59 <zombiedump+0x45>
80105c4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c51:	8b 40 14             	mov    0x14(%eax),%eax
80105c54:	8b 40 10             	mov    0x10(%eax),%eax
80105c57:	eb 06                	jmp    80105c5f <zombiedump+0x4b>
80105c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c5c:	8b 40 10             	mov    0x10(%eax),%eax
80105c5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c62:	8b 52 10             	mov    0x10(%edx),%edx
80105c65:	83 ec 04             	sub    $0x4,%esp
80105c68:	50                   	push   %eax
80105c69:	52                   	push   %edx
80105c6a:	68 a0 98 10 80       	push   $0x801098a0
80105c6f:	e8 52 a7 ff ff       	call   801003c6 <cprintf>
80105c74:	83 c4 10             	add    $0x10,%esp
    if(p->next)
80105c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c7a:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105c80:	85 c0                	test   %eax,%eax
80105c82:	74 10                	je     80105c94 <zombiedump+0x80>
      cprintf(" -> ");
80105c84:	83 ec 0c             	sub    $0xc,%esp
80105c87:	68 49 98 10 80       	push   $0x80109849
80105c8c:	e8 35 a7 ff ff       	call   801003c6 <cprintf>
80105c91:	83 c4 10             	add    $0x10,%esp
    p = p->next;
80105c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c97:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105c9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
{
  struct proc *p;
  acquire(&ptable.lock);
  p = ptable.pLists.zombie;
  cprintf("\nZombie List Processes:\n");
  while(p)
80105ca0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ca4:	75 9e                	jne    80105c44 <zombiedump+0x30>
    cprintf("(PID%d, PPID%d)", p->pid, (p->parent? p->parent->pid : p->pid));
    if(p->next)
      cprintf(" -> ");
    p = p->next;
  }
  cprintf("\n");
80105ca6:	83 ec 0c             	sub    $0xc,%esp
80105ca9:	68 f8 97 10 80       	push   $0x801097f8
80105cae:	e8 13 a7 ff ff       	call   801003c6 <cprintf>
80105cb3:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80105cb6:	83 ec 0c             	sub    $0xc,%esp
80105cb9:	68 80 39 11 80       	push   $0x80113980
80105cbe:	e8 c7 00 00 00       	call   80105d8a <release>
80105cc3:	83 c4 10             	add    $0x10,%esp
}
80105cc6:	90                   	nop
80105cc7:	c9                   	leave  
80105cc8:	c3                   	ret    

80105cc9 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105cc9:	55                   	push   %ebp
80105cca:	89 e5                	mov    %esp,%ebp
80105ccc:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105ccf:	9c                   	pushf  
80105cd0:	58                   	pop    %eax
80105cd1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105cd4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105cd7:	c9                   	leave  
80105cd8:	c3                   	ret    

80105cd9 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105cd9:	55                   	push   %ebp
80105cda:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105cdc:	fa                   	cli    
}
80105cdd:	90                   	nop
80105cde:	5d                   	pop    %ebp
80105cdf:	c3                   	ret    

80105ce0 <sti>:

static inline void
sti(void)
{
80105ce0:	55                   	push   %ebp
80105ce1:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105ce3:	fb                   	sti    
}
80105ce4:	90                   	nop
80105ce5:	5d                   	pop    %ebp
80105ce6:	c3                   	ret    

80105ce7 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105ce7:	55                   	push   %ebp
80105ce8:	89 e5                	mov    %esp,%ebp
80105cea:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105ced:	8b 55 08             	mov    0x8(%ebp),%edx
80105cf0:	8b 45 0c             	mov    0xc(%ebp),%eax
80105cf3:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105cf6:	f0 87 02             	lock xchg %eax,(%edx)
80105cf9:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105cfc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105cff:	c9                   	leave  
80105d00:	c3                   	ret    

80105d01 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105d01:	55                   	push   %ebp
80105d02:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105d04:	8b 45 08             	mov    0x8(%ebp),%eax
80105d07:	8b 55 0c             	mov    0xc(%ebp),%edx
80105d0a:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105d0d:	8b 45 08             	mov    0x8(%ebp),%eax
80105d10:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105d16:	8b 45 08             	mov    0x8(%ebp),%eax
80105d19:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105d20:	90                   	nop
80105d21:	5d                   	pop    %ebp
80105d22:	c3                   	ret    

80105d23 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105d23:	55                   	push   %ebp
80105d24:	89 e5                	mov    %esp,%ebp
80105d26:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105d29:	e8 52 01 00 00       	call   80105e80 <pushcli>
  if(holding(lk))
80105d2e:	8b 45 08             	mov    0x8(%ebp),%eax
80105d31:	83 ec 0c             	sub    $0xc,%esp
80105d34:	50                   	push   %eax
80105d35:	e8 1c 01 00 00       	call   80105e56 <holding>
80105d3a:	83 c4 10             	add    $0x10,%esp
80105d3d:	85 c0                	test   %eax,%eax
80105d3f:	74 0d                	je     80105d4e <acquire+0x2b>
    panic("acquire");
80105d41:	83 ec 0c             	sub    $0xc,%esp
80105d44:	68 b0 98 10 80       	push   $0x801098b0
80105d49:	e8 18 a8 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105d4e:	90                   	nop
80105d4f:	8b 45 08             	mov    0x8(%ebp),%eax
80105d52:	83 ec 08             	sub    $0x8,%esp
80105d55:	6a 01                	push   $0x1
80105d57:	50                   	push   %eax
80105d58:	e8 8a ff ff ff       	call   80105ce7 <xchg>
80105d5d:	83 c4 10             	add    $0x10,%esp
80105d60:	85 c0                	test   %eax,%eax
80105d62:	75 eb                	jne    80105d4f <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105d64:	8b 45 08             	mov    0x8(%ebp),%eax
80105d67:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105d6e:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105d71:	8b 45 08             	mov    0x8(%ebp),%eax
80105d74:	83 c0 0c             	add    $0xc,%eax
80105d77:	83 ec 08             	sub    $0x8,%esp
80105d7a:	50                   	push   %eax
80105d7b:	8d 45 08             	lea    0x8(%ebp),%eax
80105d7e:	50                   	push   %eax
80105d7f:	e8 58 00 00 00       	call   80105ddc <getcallerpcs>
80105d84:	83 c4 10             	add    $0x10,%esp
}
80105d87:	90                   	nop
80105d88:	c9                   	leave  
80105d89:	c3                   	ret    

80105d8a <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105d8a:	55                   	push   %ebp
80105d8b:	89 e5                	mov    %esp,%ebp
80105d8d:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105d90:	83 ec 0c             	sub    $0xc,%esp
80105d93:	ff 75 08             	pushl  0x8(%ebp)
80105d96:	e8 bb 00 00 00       	call   80105e56 <holding>
80105d9b:	83 c4 10             	add    $0x10,%esp
80105d9e:	85 c0                	test   %eax,%eax
80105da0:	75 0d                	jne    80105daf <release+0x25>
    panic("release");
80105da2:	83 ec 0c             	sub    $0xc,%esp
80105da5:	68 b8 98 10 80       	push   $0x801098b8
80105daa:	e8 b7 a7 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80105daf:	8b 45 08             	mov    0x8(%ebp),%eax
80105db2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105db9:	8b 45 08             	mov    0x8(%ebp),%eax
80105dbc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105dc3:	8b 45 08             	mov    0x8(%ebp),%eax
80105dc6:	83 ec 08             	sub    $0x8,%esp
80105dc9:	6a 00                	push   $0x0
80105dcb:	50                   	push   %eax
80105dcc:	e8 16 ff ff ff       	call   80105ce7 <xchg>
80105dd1:	83 c4 10             	add    $0x10,%esp

  popcli();
80105dd4:	e8 ec 00 00 00       	call   80105ec5 <popcli>
}
80105dd9:	90                   	nop
80105dda:	c9                   	leave  
80105ddb:	c3                   	ret    

80105ddc <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105ddc:	55                   	push   %ebp
80105ddd:	89 e5                	mov    %esp,%ebp
80105ddf:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105de2:	8b 45 08             	mov    0x8(%ebp),%eax
80105de5:	83 e8 08             	sub    $0x8,%eax
80105de8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105deb:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105df2:	eb 38                	jmp    80105e2c <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105df4:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105df8:	74 53                	je     80105e4d <getcallerpcs+0x71>
80105dfa:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105e01:	76 4a                	jbe    80105e4d <getcallerpcs+0x71>
80105e03:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105e07:	74 44                	je     80105e4d <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105e09:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e0c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105e13:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e16:	01 c2                	add    %eax,%edx
80105e18:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e1b:	8b 40 04             	mov    0x4(%eax),%eax
80105e1e:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105e20:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e23:	8b 00                	mov    (%eax),%eax
80105e25:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105e28:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105e2c:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105e30:	7e c2                	jle    80105df4 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105e32:	eb 19                	jmp    80105e4d <getcallerpcs+0x71>
    pcs[i] = 0;
80105e34:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e37:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105e3e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e41:	01 d0                	add    %edx,%eax
80105e43:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105e49:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105e4d:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105e51:	7e e1                	jle    80105e34 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105e53:	90                   	nop
80105e54:	c9                   	leave  
80105e55:	c3                   	ret    

80105e56 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105e56:	55                   	push   %ebp
80105e57:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105e59:	8b 45 08             	mov    0x8(%ebp),%eax
80105e5c:	8b 00                	mov    (%eax),%eax
80105e5e:	85 c0                	test   %eax,%eax
80105e60:	74 17                	je     80105e79 <holding+0x23>
80105e62:	8b 45 08             	mov    0x8(%ebp),%eax
80105e65:	8b 50 08             	mov    0x8(%eax),%edx
80105e68:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105e6e:	39 c2                	cmp    %eax,%edx
80105e70:	75 07                	jne    80105e79 <holding+0x23>
80105e72:	b8 01 00 00 00       	mov    $0x1,%eax
80105e77:	eb 05                	jmp    80105e7e <holding+0x28>
80105e79:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e7e:	5d                   	pop    %ebp
80105e7f:	c3                   	ret    

80105e80 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105e80:	55                   	push   %ebp
80105e81:	89 e5                	mov    %esp,%ebp
80105e83:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105e86:	e8 3e fe ff ff       	call   80105cc9 <readeflags>
80105e8b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105e8e:	e8 46 fe ff ff       	call   80105cd9 <cli>
  if(cpu->ncli++ == 0)
80105e93:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105e9a:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105ea0:	8d 48 01             	lea    0x1(%eax),%ecx
80105ea3:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105ea9:	85 c0                	test   %eax,%eax
80105eab:	75 15                	jne    80105ec2 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105ead:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105eb3:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105eb6:	81 e2 00 02 00 00    	and    $0x200,%edx
80105ebc:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105ec2:	90                   	nop
80105ec3:	c9                   	leave  
80105ec4:	c3                   	ret    

80105ec5 <popcli>:

void
popcli(void)
{
80105ec5:	55                   	push   %ebp
80105ec6:	89 e5                	mov    %esp,%ebp
80105ec8:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105ecb:	e8 f9 fd ff ff       	call   80105cc9 <readeflags>
80105ed0:	25 00 02 00 00       	and    $0x200,%eax
80105ed5:	85 c0                	test   %eax,%eax
80105ed7:	74 0d                	je     80105ee6 <popcli+0x21>
    panic("popcli - interruptible");
80105ed9:	83 ec 0c             	sub    $0xc,%esp
80105edc:	68 c0 98 10 80       	push   $0x801098c0
80105ee1:	e8 80 a6 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80105ee6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105eec:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105ef2:	83 ea 01             	sub    $0x1,%edx
80105ef5:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105efb:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105f01:	85 c0                	test   %eax,%eax
80105f03:	79 0d                	jns    80105f12 <popcli+0x4d>
    panic("popcli");
80105f05:	83 ec 0c             	sub    $0xc,%esp
80105f08:	68 d7 98 10 80       	push   $0x801098d7
80105f0d:	e8 54 a6 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105f12:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105f18:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105f1e:	85 c0                	test   %eax,%eax
80105f20:	75 15                	jne    80105f37 <popcli+0x72>
80105f22:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105f28:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105f2e:	85 c0                	test   %eax,%eax
80105f30:	74 05                	je     80105f37 <popcli+0x72>
    sti();
80105f32:	e8 a9 fd ff ff       	call   80105ce0 <sti>
}
80105f37:	90                   	nop
80105f38:	c9                   	leave  
80105f39:	c3                   	ret    

80105f3a <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105f3a:	55                   	push   %ebp
80105f3b:	89 e5                	mov    %esp,%ebp
80105f3d:	57                   	push   %edi
80105f3e:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105f3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105f42:	8b 55 10             	mov    0x10(%ebp),%edx
80105f45:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f48:	89 cb                	mov    %ecx,%ebx
80105f4a:	89 df                	mov    %ebx,%edi
80105f4c:	89 d1                	mov    %edx,%ecx
80105f4e:	fc                   	cld    
80105f4f:	f3 aa                	rep stos %al,%es:(%edi)
80105f51:	89 ca                	mov    %ecx,%edx
80105f53:	89 fb                	mov    %edi,%ebx
80105f55:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105f58:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105f5b:	90                   	nop
80105f5c:	5b                   	pop    %ebx
80105f5d:	5f                   	pop    %edi
80105f5e:	5d                   	pop    %ebp
80105f5f:	c3                   	ret    

80105f60 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105f60:	55                   	push   %ebp
80105f61:	89 e5                	mov    %esp,%ebp
80105f63:	57                   	push   %edi
80105f64:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105f65:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105f68:	8b 55 10             	mov    0x10(%ebp),%edx
80105f6b:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f6e:	89 cb                	mov    %ecx,%ebx
80105f70:	89 df                	mov    %ebx,%edi
80105f72:	89 d1                	mov    %edx,%ecx
80105f74:	fc                   	cld    
80105f75:	f3 ab                	rep stos %eax,%es:(%edi)
80105f77:	89 ca                	mov    %ecx,%edx
80105f79:	89 fb                	mov    %edi,%ebx
80105f7b:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105f7e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105f81:	90                   	nop
80105f82:	5b                   	pop    %ebx
80105f83:	5f                   	pop    %edi
80105f84:	5d                   	pop    %ebp
80105f85:	c3                   	ret    

80105f86 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105f86:	55                   	push   %ebp
80105f87:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105f89:	8b 45 08             	mov    0x8(%ebp),%eax
80105f8c:	83 e0 03             	and    $0x3,%eax
80105f8f:	85 c0                	test   %eax,%eax
80105f91:	75 43                	jne    80105fd6 <memset+0x50>
80105f93:	8b 45 10             	mov    0x10(%ebp),%eax
80105f96:	83 e0 03             	and    $0x3,%eax
80105f99:	85 c0                	test   %eax,%eax
80105f9b:	75 39                	jne    80105fd6 <memset+0x50>
    c &= 0xFF;
80105f9d:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105fa4:	8b 45 10             	mov    0x10(%ebp),%eax
80105fa7:	c1 e8 02             	shr    $0x2,%eax
80105faa:	89 c1                	mov    %eax,%ecx
80105fac:	8b 45 0c             	mov    0xc(%ebp),%eax
80105faf:	c1 e0 18             	shl    $0x18,%eax
80105fb2:	89 c2                	mov    %eax,%edx
80105fb4:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fb7:	c1 e0 10             	shl    $0x10,%eax
80105fba:	09 c2                	or     %eax,%edx
80105fbc:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fbf:	c1 e0 08             	shl    $0x8,%eax
80105fc2:	09 d0                	or     %edx,%eax
80105fc4:	0b 45 0c             	or     0xc(%ebp),%eax
80105fc7:	51                   	push   %ecx
80105fc8:	50                   	push   %eax
80105fc9:	ff 75 08             	pushl  0x8(%ebp)
80105fcc:	e8 8f ff ff ff       	call   80105f60 <stosl>
80105fd1:	83 c4 0c             	add    $0xc,%esp
80105fd4:	eb 12                	jmp    80105fe8 <memset+0x62>
  } else
    stosb(dst, c, n);
80105fd6:	8b 45 10             	mov    0x10(%ebp),%eax
80105fd9:	50                   	push   %eax
80105fda:	ff 75 0c             	pushl  0xc(%ebp)
80105fdd:	ff 75 08             	pushl  0x8(%ebp)
80105fe0:	e8 55 ff ff ff       	call   80105f3a <stosb>
80105fe5:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105fe8:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105feb:	c9                   	leave  
80105fec:	c3                   	ret    

80105fed <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105fed:	55                   	push   %ebp
80105fee:	89 e5                	mov    %esp,%ebp
80105ff0:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105ff3:	8b 45 08             	mov    0x8(%ebp),%eax
80105ff6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105ff9:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ffc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105fff:	eb 30                	jmp    80106031 <memcmp+0x44>
    if(*s1 != *s2)
80106001:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106004:	0f b6 10             	movzbl (%eax),%edx
80106007:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010600a:	0f b6 00             	movzbl (%eax),%eax
8010600d:	38 c2                	cmp    %al,%dl
8010600f:	74 18                	je     80106029 <memcmp+0x3c>
      return *s1 - *s2;
80106011:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106014:	0f b6 00             	movzbl (%eax),%eax
80106017:	0f b6 d0             	movzbl %al,%edx
8010601a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010601d:	0f b6 00             	movzbl (%eax),%eax
80106020:	0f b6 c0             	movzbl %al,%eax
80106023:	29 c2                	sub    %eax,%edx
80106025:	89 d0                	mov    %edx,%eax
80106027:	eb 1a                	jmp    80106043 <memcmp+0x56>
    s1++, s2++;
80106029:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010602d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80106031:	8b 45 10             	mov    0x10(%ebp),%eax
80106034:	8d 50 ff             	lea    -0x1(%eax),%edx
80106037:	89 55 10             	mov    %edx,0x10(%ebp)
8010603a:	85 c0                	test   %eax,%eax
8010603c:	75 c3                	jne    80106001 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
8010603e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106043:	c9                   	leave  
80106044:	c3                   	ret    

80106045 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80106045:	55                   	push   %ebp
80106046:	89 e5                	mov    %esp,%ebp
80106048:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010604b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010604e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80106051:	8b 45 08             	mov    0x8(%ebp),%eax
80106054:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80106057:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010605a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010605d:	73 54                	jae    801060b3 <memmove+0x6e>
8010605f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106062:	8b 45 10             	mov    0x10(%ebp),%eax
80106065:	01 d0                	add    %edx,%eax
80106067:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010606a:	76 47                	jbe    801060b3 <memmove+0x6e>
    s += n;
8010606c:	8b 45 10             	mov    0x10(%ebp),%eax
8010606f:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80106072:	8b 45 10             	mov    0x10(%ebp),%eax
80106075:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80106078:	eb 13                	jmp    8010608d <memmove+0x48>
      *--d = *--s;
8010607a:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010607e:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80106082:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106085:	0f b6 10             	movzbl (%eax),%edx
80106088:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010608b:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
8010608d:	8b 45 10             	mov    0x10(%ebp),%eax
80106090:	8d 50 ff             	lea    -0x1(%eax),%edx
80106093:	89 55 10             	mov    %edx,0x10(%ebp)
80106096:	85 c0                	test   %eax,%eax
80106098:	75 e0                	jne    8010607a <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
8010609a:	eb 24                	jmp    801060c0 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
8010609c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010609f:	8d 50 01             	lea    0x1(%eax),%edx
801060a2:	89 55 f8             	mov    %edx,-0x8(%ebp)
801060a5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801060a8:	8d 4a 01             	lea    0x1(%edx),%ecx
801060ab:	89 4d fc             	mov    %ecx,-0x4(%ebp)
801060ae:	0f b6 12             	movzbl (%edx),%edx
801060b1:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801060b3:	8b 45 10             	mov    0x10(%ebp),%eax
801060b6:	8d 50 ff             	lea    -0x1(%eax),%edx
801060b9:	89 55 10             	mov    %edx,0x10(%ebp)
801060bc:	85 c0                	test   %eax,%eax
801060be:	75 dc                	jne    8010609c <memmove+0x57>
      *d++ = *s++;

  return dst;
801060c0:	8b 45 08             	mov    0x8(%ebp),%eax
}
801060c3:	c9                   	leave  
801060c4:	c3                   	ret    

801060c5 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801060c5:	55                   	push   %ebp
801060c6:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801060c8:	ff 75 10             	pushl  0x10(%ebp)
801060cb:	ff 75 0c             	pushl  0xc(%ebp)
801060ce:	ff 75 08             	pushl  0x8(%ebp)
801060d1:	e8 6f ff ff ff       	call   80106045 <memmove>
801060d6:	83 c4 0c             	add    $0xc,%esp
}
801060d9:	c9                   	leave  
801060da:	c3                   	ret    

801060db <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801060db:	55                   	push   %ebp
801060dc:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801060de:	eb 0c                	jmp    801060ec <strncmp+0x11>
    n--, p++, q++;
801060e0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801060e4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801060e8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801060ec:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801060f0:	74 1a                	je     8010610c <strncmp+0x31>
801060f2:	8b 45 08             	mov    0x8(%ebp),%eax
801060f5:	0f b6 00             	movzbl (%eax),%eax
801060f8:	84 c0                	test   %al,%al
801060fa:	74 10                	je     8010610c <strncmp+0x31>
801060fc:	8b 45 08             	mov    0x8(%ebp),%eax
801060ff:	0f b6 10             	movzbl (%eax),%edx
80106102:	8b 45 0c             	mov    0xc(%ebp),%eax
80106105:	0f b6 00             	movzbl (%eax),%eax
80106108:	38 c2                	cmp    %al,%dl
8010610a:	74 d4                	je     801060e0 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
8010610c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106110:	75 07                	jne    80106119 <strncmp+0x3e>
    return 0;
80106112:	b8 00 00 00 00       	mov    $0x0,%eax
80106117:	eb 16                	jmp    8010612f <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80106119:	8b 45 08             	mov    0x8(%ebp),%eax
8010611c:	0f b6 00             	movzbl (%eax),%eax
8010611f:	0f b6 d0             	movzbl %al,%edx
80106122:	8b 45 0c             	mov    0xc(%ebp),%eax
80106125:	0f b6 00             	movzbl (%eax),%eax
80106128:	0f b6 c0             	movzbl %al,%eax
8010612b:	29 c2                	sub    %eax,%edx
8010612d:	89 d0                	mov    %edx,%eax
}
8010612f:	5d                   	pop    %ebp
80106130:	c3                   	ret    

80106131 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80106131:	55                   	push   %ebp
80106132:	89 e5                	mov    %esp,%ebp
80106134:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80106137:	8b 45 08             	mov    0x8(%ebp),%eax
8010613a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010613d:	90                   	nop
8010613e:	8b 45 10             	mov    0x10(%ebp),%eax
80106141:	8d 50 ff             	lea    -0x1(%eax),%edx
80106144:	89 55 10             	mov    %edx,0x10(%ebp)
80106147:	85 c0                	test   %eax,%eax
80106149:	7e 2c                	jle    80106177 <strncpy+0x46>
8010614b:	8b 45 08             	mov    0x8(%ebp),%eax
8010614e:	8d 50 01             	lea    0x1(%eax),%edx
80106151:	89 55 08             	mov    %edx,0x8(%ebp)
80106154:	8b 55 0c             	mov    0xc(%ebp),%edx
80106157:	8d 4a 01             	lea    0x1(%edx),%ecx
8010615a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010615d:	0f b6 12             	movzbl (%edx),%edx
80106160:	88 10                	mov    %dl,(%eax)
80106162:	0f b6 00             	movzbl (%eax),%eax
80106165:	84 c0                	test   %al,%al
80106167:	75 d5                	jne    8010613e <strncpy+0xd>
    ;
  while(n-- > 0)
80106169:	eb 0c                	jmp    80106177 <strncpy+0x46>
    *s++ = 0;
8010616b:	8b 45 08             	mov    0x8(%ebp),%eax
8010616e:	8d 50 01             	lea    0x1(%eax),%edx
80106171:	89 55 08             	mov    %edx,0x8(%ebp)
80106174:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80106177:	8b 45 10             	mov    0x10(%ebp),%eax
8010617a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010617d:	89 55 10             	mov    %edx,0x10(%ebp)
80106180:	85 c0                	test   %eax,%eax
80106182:	7f e7                	jg     8010616b <strncpy+0x3a>
    *s++ = 0;
  return os;
80106184:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106187:	c9                   	leave  
80106188:	c3                   	ret    

80106189 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80106189:	55                   	push   %ebp
8010618a:	89 e5                	mov    %esp,%ebp
8010618c:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010618f:	8b 45 08             	mov    0x8(%ebp),%eax
80106192:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80106195:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106199:	7f 05                	jg     801061a0 <safestrcpy+0x17>
    return os;
8010619b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010619e:	eb 31                	jmp    801061d1 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
801061a0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801061a4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801061a8:	7e 1e                	jle    801061c8 <safestrcpy+0x3f>
801061aa:	8b 45 08             	mov    0x8(%ebp),%eax
801061ad:	8d 50 01             	lea    0x1(%eax),%edx
801061b0:	89 55 08             	mov    %edx,0x8(%ebp)
801061b3:	8b 55 0c             	mov    0xc(%ebp),%edx
801061b6:	8d 4a 01             	lea    0x1(%edx),%ecx
801061b9:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801061bc:	0f b6 12             	movzbl (%edx),%edx
801061bf:	88 10                	mov    %dl,(%eax)
801061c1:	0f b6 00             	movzbl (%eax),%eax
801061c4:	84 c0                	test   %al,%al
801061c6:	75 d8                	jne    801061a0 <safestrcpy+0x17>
    ;
  *s = 0;
801061c8:	8b 45 08             	mov    0x8(%ebp),%eax
801061cb:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801061ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801061d1:	c9                   	leave  
801061d2:	c3                   	ret    

801061d3 <strlen>:

int
strlen(const char *s)
{
801061d3:	55                   	push   %ebp
801061d4:	89 e5                	mov    %esp,%ebp
801061d6:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801061d9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801061e0:	eb 04                	jmp    801061e6 <strlen+0x13>
801061e2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801061e6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801061e9:	8b 45 08             	mov    0x8(%ebp),%eax
801061ec:	01 d0                	add    %edx,%eax
801061ee:	0f b6 00             	movzbl (%eax),%eax
801061f1:	84 c0                	test   %al,%al
801061f3:	75 ed                	jne    801061e2 <strlen+0xf>
    ;
  return n;
801061f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801061f8:	c9                   	leave  
801061f9:	c3                   	ret    

801061fa <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801061fa:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801061fe:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80106202:	55                   	push   %ebp
  pushl %ebx
80106203:	53                   	push   %ebx
  pushl %esi
80106204:	56                   	push   %esi
  pushl %edi
80106205:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80106206:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80106208:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010620a:	5f                   	pop    %edi
  popl %esi
8010620b:	5e                   	pop    %esi
  popl %ebx
8010620c:	5b                   	pop    %ebx
  popl %ebp
8010620d:	5d                   	pop    %ebp
  ret
8010620e:	c3                   	ret    

8010620f <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010620f:	55                   	push   %ebp
80106210:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80106212:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106218:	8b 00                	mov    (%eax),%eax
8010621a:	3b 45 08             	cmp    0x8(%ebp),%eax
8010621d:	76 12                	jbe    80106231 <fetchint+0x22>
8010621f:	8b 45 08             	mov    0x8(%ebp),%eax
80106222:	8d 50 04             	lea    0x4(%eax),%edx
80106225:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010622b:	8b 00                	mov    (%eax),%eax
8010622d:	39 c2                	cmp    %eax,%edx
8010622f:	76 07                	jbe    80106238 <fetchint+0x29>
    return -1;
80106231:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106236:	eb 0f                	jmp    80106247 <fetchint+0x38>
  *ip = *(int*)(addr);
80106238:	8b 45 08             	mov    0x8(%ebp),%eax
8010623b:	8b 10                	mov    (%eax),%edx
8010623d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106240:	89 10                	mov    %edx,(%eax)
  return 0;
80106242:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106247:	5d                   	pop    %ebp
80106248:	c3                   	ret    

80106249 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80106249:	55                   	push   %ebp
8010624a:	89 e5                	mov    %esp,%ebp
8010624c:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
8010624f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106255:	8b 00                	mov    (%eax),%eax
80106257:	3b 45 08             	cmp    0x8(%ebp),%eax
8010625a:	77 07                	ja     80106263 <fetchstr+0x1a>
    return -1;
8010625c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106261:	eb 46                	jmp    801062a9 <fetchstr+0x60>
  *pp = (char*)addr;
80106263:	8b 55 08             	mov    0x8(%ebp),%edx
80106266:	8b 45 0c             	mov    0xc(%ebp),%eax
80106269:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
8010626b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106271:	8b 00                	mov    (%eax),%eax
80106273:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80106276:	8b 45 0c             	mov    0xc(%ebp),%eax
80106279:	8b 00                	mov    (%eax),%eax
8010627b:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010627e:	eb 1c                	jmp    8010629c <fetchstr+0x53>
    if(*s == 0)
80106280:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106283:	0f b6 00             	movzbl (%eax),%eax
80106286:	84 c0                	test   %al,%al
80106288:	75 0e                	jne    80106298 <fetchstr+0x4f>
      return s - *pp;
8010628a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010628d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106290:	8b 00                	mov    (%eax),%eax
80106292:	29 c2                	sub    %eax,%edx
80106294:	89 d0                	mov    %edx,%eax
80106296:	eb 11                	jmp    801062a9 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80106298:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010629c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010629f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801062a2:	72 dc                	jb     80106280 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
801062a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801062a9:	c9                   	leave  
801062aa:	c3                   	ret    

801062ab <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801062ab:	55                   	push   %ebp
801062ac:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
801062ae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062b4:	8b 40 18             	mov    0x18(%eax),%eax
801062b7:	8b 40 44             	mov    0x44(%eax),%eax
801062ba:	8b 55 08             	mov    0x8(%ebp),%edx
801062bd:	c1 e2 02             	shl    $0x2,%edx
801062c0:	01 d0                	add    %edx,%eax
801062c2:	83 c0 04             	add    $0x4,%eax
801062c5:	ff 75 0c             	pushl  0xc(%ebp)
801062c8:	50                   	push   %eax
801062c9:	e8 41 ff ff ff       	call   8010620f <fetchint>
801062ce:	83 c4 08             	add    $0x8,%esp
}
801062d1:	c9                   	leave  
801062d2:	c3                   	ret    

801062d3 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801062d3:	55                   	push   %ebp
801062d4:	89 e5                	mov    %esp,%ebp
801062d6:	83 ec 10             	sub    $0x10,%esp
  int i;

  if(argint(n, &i) < 0)
801062d9:	8d 45 fc             	lea    -0x4(%ebp),%eax
801062dc:	50                   	push   %eax
801062dd:	ff 75 08             	pushl  0x8(%ebp)
801062e0:	e8 c6 ff ff ff       	call   801062ab <argint>
801062e5:	83 c4 08             	add    $0x8,%esp
801062e8:	85 c0                	test   %eax,%eax
801062ea:	79 07                	jns    801062f3 <argptr+0x20>
    return -1;
801062ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062f1:	eb 3b                	jmp    8010632e <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801062f3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062f9:	8b 00                	mov    (%eax),%eax
801062fb:	8b 55 fc             	mov    -0x4(%ebp),%edx
801062fe:	39 d0                	cmp    %edx,%eax
80106300:	76 16                	jbe    80106318 <argptr+0x45>
80106302:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106305:	89 c2                	mov    %eax,%edx
80106307:	8b 45 10             	mov    0x10(%ebp),%eax
8010630a:	01 c2                	add    %eax,%edx
8010630c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106312:	8b 00                	mov    (%eax),%eax
80106314:	39 c2                	cmp    %eax,%edx
80106316:	76 07                	jbe    8010631f <argptr+0x4c>
    return -1;
80106318:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010631d:	eb 0f                	jmp    8010632e <argptr+0x5b>
  *pp = (char*)i;
8010631f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106322:	89 c2                	mov    %eax,%edx
80106324:	8b 45 0c             	mov    0xc(%ebp),%eax
80106327:	89 10                	mov    %edx,(%eax)
  return 0;
80106329:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010632e:	c9                   	leave  
8010632f:	c3                   	ret    

80106330 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80106330:	55                   	push   %ebp
80106331:	89 e5                	mov    %esp,%ebp
80106333:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80106336:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106339:	50                   	push   %eax
8010633a:	ff 75 08             	pushl  0x8(%ebp)
8010633d:	e8 69 ff ff ff       	call   801062ab <argint>
80106342:	83 c4 08             	add    $0x8,%esp
80106345:	85 c0                	test   %eax,%eax
80106347:	79 07                	jns    80106350 <argstr+0x20>
    return -1;
80106349:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010634e:	eb 0f                	jmp    8010635f <argstr+0x2f>
  return fetchstr(addr, pp);
80106350:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106353:	ff 75 0c             	pushl  0xc(%ebp)
80106356:	50                   	push   %eax
80106357:	e8 ed fe ff ff       	call   80106249 <fetchstr>
8010635c:	83 c4 08             	add    $0x8,%esp
}
8010635f:	c9                   	leave  
80106360:	c3                   	ret    

80106361 <syscall>:
};
#endif

void
syscall(void)
{
80106361:	55                   	push   %ebp
80106362:	89 e5                	mov    %esp,%ebp
80106364:	53                   	push   %ebx
80106365:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
80106368:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010636e:	8b 40 18             	mov    0x18(%eax),%eax
80106371:	8b 40 1c             	mov    0x1c(%eax),%eax
80106374:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80106377:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010637b:	7e 30                	jle    801063ad <syscall+0x4c>
8010637d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106380:	83 f8 1c             	cmp    $0x1c,%eax
80106383:	77 28                	ja     801063ad <syscall+0x4c>
80106385:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106388:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
8010638f:	85 c0                	test   %eax,%eax
80106391:	74 1a                	je     801063ad <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80106393:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106399:	8b 58 18             	mov    0x18(%eax),%ebx
8010639c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010639f:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
801063a6:	ff d0                	call   *%eax
801063a8:	89 43 1c             	mov    %eax,0x1c(%ebx)
801063ab:	eb 34                	jmp    801063e1 <syscall+0x80>
#ifdef PRINT_SYSCALLS
    cprintf("%s -> %d\n",syscallnames[num],proc->tf->eax);
#endif
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801063ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063b3:	8d 50 6c             	lea    0x6c(%eax),%edx
801063b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
// some code goes here
#ifdef PRINT_SYSCALLS
    cprintf("%s -> %d\n",syscallnames[num],proc->tf->eax);
#endif
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801063bc:	8b 40 10             	mov    0x10(%eax),%eax
801063bf:	ff 75 f4             	pushl  -0xc(%ebp)
801063c2:	52                   	push   %edx
801063c3:	50                   	push   %eax
801063c4:	68 de 98 10 80       	push   $0x801098de
801063c9:	e8 f8 9f ff ff       	call   801003c6 <cprintf>
801063ce:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801063d1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063d7:	8b 40 18             	mov    0x18(%eax),%eax
801063da:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801063e1:	90                   	nop
801063e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801063e5:	c9                   	leave  
801063e6:	c3                   	ret    

801063e7 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801063e7:	55                   	push   %ebp
801063e8:	89 e5                	mov    %esp,%ebp
801063ea:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801063ed:	83 ec 08             	sub    $0x8,%esp
801063f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063f3:	50                   	push   %eax
801063f4:	ff 75 08             	pushl  0x8(%ebp)
801063f7:	e8 af fe ff ff       	call   801062ab <argint>
801063fc:	83 c4 10             	add    $0x10,%esp
801063ff:	85 c0                	test   %eax,%eax
80106401:	79 07                	jns    8010640a <argfd+0x23>
    return -1;
80106403:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106408:	eb 50                	jmp    8010645a <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
8010640a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010640d:	85 c0                	test   %eax,%eax
8010640f:	78 21                	js     80106432 <argfd+0x4b>
80106411:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106414:	83 f8 0f             	cmp    $0xf,%eax
80106417:	7f 19                	jg     80106432 <argfd+0x4b>
80106419:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010641f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106422:	83 c2 08             	add    $0x8,%edx
80106425:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106429:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010642c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106430:	75 07                	jne    80106439 <argfd+0x52>
    return -1;
80106432:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106437:	eb 21                	jmp    8010645a <argfd+0x73>
  if(pfd)
80106439:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010643d:	74 08                	je     80106447 <argfd+0x60>
    *pfd = fd;
8010643f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106442:	8b 45 0c             	mov    0xc(%ebp),%eax
80106445:	89 10                	mov    %edx,(%eax)
  if(pf)
80106447:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010644b:	74 08                	je     80106455 <argfd+0x6e>
    *pf = f;
8010644d:	8b 45 10             	mov    0x10(%ebp),%eax
80106450:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106453:	89 10                	mov    %edx,(%eax)
  return 0;
80106455:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010645a:	c9                   	leave  
8010645b:	c3                   	ret    

8010645c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010645c:	55                   	push   %ebp
8010645d:	89 e5                	mov    %esp,%ebp
8010645f:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80106462:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106469:	eb 30                	jmp    8010649b <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
8010646b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106471:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106474:	83 c2 08             	add    $0x8,%edx
80106477:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010647b:	85 c0                	test   %eax,%eax
8010647d:	75 18                	jne    80106497 <fdalloc+0x3b>
      proc->ofile[fd] = f;
8010647f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106485:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106488:	8d 4a 08             	lea    0x8(%edx),%ecx
8010648b:	8b 55 08             	mov    0x8(%ebp),%edx
8010648e:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80106492:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106495:	eb 0f                	jmp    801064a6 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80106497:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010649b:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
8010649f:	7e ca                	jle    8010646b <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801064a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801064a6:	c9                   	leave  
801064a7:	c3                   	ret    

801064a8 <sys_dup>:

int
sys_dup(void)
{
801064a8:	55                   	push   %ebp
801064a9:	89 e5                	mov    %esp,%ebp
801064ab:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
801064ae:	83 ec 04             	sub    $0x4,%esp
801064b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064b4:	50                   	push   %eax
801064b5:	6a 00                	push   $0x0
801064b7:	6a 00                	push   $0x0
801064b9:	e8 29 ff ff ff       	call   801063e7 <argfd>
801064be:	83 c4 10             	add    $0x10,%esp
801064c1:	85 c0                	test   %eax,%eax
801064c3:	79 07                	jns    801064cc <sys_dup+0x24>
    return -1;
801064c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064ca:	eb 31                	jmp    801064fd <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801064cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064cf:	83 ec 0c             	sub    $0xc,%esp
801064d2:	50                   	push   %eax
801064d3:	e8 84 ff ff ff       	call   8010645c <fdalloc>
801064d8:	83 c4 10             	add    $0x10,%esp
801064db:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064e2:	79 07                	jns    801064eb <sys_dup+0x43>
    return -1;
801064e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064e9:	eb 12                	jmp    801064fd <sys_dup+0x55>
  filedup(f);
801064eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064ee:	83 ec 0c             	sub    $0xc,%esp
801064f1:	50                   	push   %eax
801064f2:	e8 a7 ab ff ff       	call   8010109e <filedup>
801064f7:	83 c4 10             	add    $0x10,%esp
  return fd;
801064fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801064fd:	c9                   	leave  
801064fe:	c3                   	ret    

801064ff <sys_read>:

int
sys_read(void)
{
801064ff:	55                   	push   %ebp
80106500:	89 e5                	mov    %esp,%ebp
80106502:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106505:	83 ec 04             	sub    $0x4,%esp
80106508:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010650b:	50                   	push   %eax
8010650c:	6a 00                	push   $0x0
8010650e:	6a 00                	push   $0x0
80106510:	e8 d2 fe ff ff       	call   801063e7 <argfd>
80106515:	83 c4 10             	add    $0x10,%esp
80106518:	85 c0                	test   %eax,%eax
8010651a:	78 2e                	js     8010654a <sys_read+0x4b>
8010651c:	83 ec 08             	sub    $0x8,%esp
8010651f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106522:	50                   	push   %eax
80106523:	6a 02                	push   $0x2
80106525:	e8 81 fd ff ff       	call   801062ab <argint>
8010652a:	83 c4 10             	add    $0x10,%esp
8010652d:	85 c0                	test   %eax,%eax
8010652f:	78 19                	js     8010654a <sys_read+0x4b>
80106531:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106534:	83 ec 04             	sub    $0x4,%esp
80106537:	50                   	push   %eax
80106538:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010653b:	50                   	push   %eax
8010653c:	6a 01                	push   $0x1
8010653e:	e8 90 fd ff ff       	call   801062d3 <argptr>
80106543:	83 c4 10             	add    $0x10,%esp
80106546:	85 c0                	test   %eax,%eax
80106548:	79 07                	jns    80106551 <sys_read+0x52>
    return -1;
8010654a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010654f:	eb 17                	jmp    80106568 <sys_read+0x69>
  return fileread(f, p, n);
80106551:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106554:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106557:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010655a:	83 ec 04             	sub    $0x4,%esp
8010655d:	51                   	push   %ecx
8010655e:	52                   	push   %edx
8010655f:	50                   	push   %eax
80106560:	e8 c9 ac ff ff       	call   8010122e <fileread>
80106565:	83 c4 10             	add    $0x10,%esp
}
80106568:	c9                   	leave  
80106569:	c3                   	ret    

8010656a <sys_write>:

int
sys_write(void)
{
8010656a:	55                   	push   %ebp
8010656b:	89 e5                	mov    %esp,%ebp
8010656d:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106570:	83 ec 04             	sub    $0x4,%esp
80106573:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106576:	50                   	push   %eax
80106577:	6a 00                	push   $0x0
80106579:	6a 00                	push   $0x0
8010657b:	e8 67 fe ff ff       	call   801063e7 <argfd>
80106580:	83 c4 10             	add    $0x10,%esp
80106583:	85 c0                	test   %eax,%eax
80106585:	78 2e                	js     801065b5 <sys_write+0x4b>
80106587:	83 ec 08             	sub    $0x8,%esp
8010658a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010658d:	50                   	push   %eax
8010658e:	6a 02                	push   $0x2
80106590:	e8 16 fd ff ff       	call   801062ab <argint>
80106595:	83 c4 10             	add    $0x10,%esp
80106598:	85 c0                	test   %eax,%eax
8010659a:	78 19                	js     801065b5 <sys_write+0x4b>
8010659c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010659f:	83 ec 04             	sub    $0x4,%esp
801065a2:	50                   	push   %eax
801065a3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801065a6:	50                   	push   %eax
801065a7:	6a 01                	push   $0x1
801065a9:	e8 25 fd ff ff       	call   801062d3 <argptr>
801065ae:	83 c4 10             	add    $0x10,%esp
801065b1:	85 c0                	test   %eax,%eax
801065b3:	79 07                	jns    801065bc <sys_write+0x52>
    return -1;
801065b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065ba:	eb 17                	jmp    801065d3 <sys_write+0x69>
  return filewrite(f, p, n);
801065bc:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801065bf:	8b 55 ec             	mov    -0x14(%ebp),%edx
801065c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065c5:	83 ec 04             	sub    $0x4,%esp
801065c8:	51                   	push   %ecx
801065c9:	52                   	push   %edx
801065ca:	50                   	push   %eax
801065cb:	e8 16 ad ff ff       	call   801012e6 <filewrite>
801065d0:	83 c4 10             	add    $0x10,%esp
}
801065d3:	c9                   	leave  
801065d4:	c3                   	ret    

801065d5 <sys_close>:

int
sys_close(void)
{
801065d5:	55                   	push   %ebp
801065d6:	89 e5                	mov    %esp,%ebp
801065d8:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
801065db:	83 ec 04             	sub    $0x4,%esp
801065de:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065e1:	50                   	push   %eax
801065e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801065e5:	50                   	push   %eax
801065e6:	6a 00                	push   $0x0
801065e8:	e8 fa fd ff ff       	call   801063e7 <argfd>
801065ed:	83 c4 10             	add    $0x10,%esp
801065f0:	85 c0                	test   %eax,%eax
801065f2:	79 07                	jns    801065fb <sys_close+0x26>
    return -1;
801065f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065f9:	eb 28                	jmp    80106623 <sys_close+0x4e>
  proc->ofile[fd] = 0;
801065fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106601:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106604:	83 c2 08             	add    $0x8,%edx
80106607:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010660e:	00 
  fileclose(f);
8010660f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106612:	83 ec 0c             	sub    $0xc,%esp
80106615:	50                   	push   %eax
80106616:	e8 d4 aa ff ff       	call   801010ef <fileclose>
8010661b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010661e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106623:	c9                   	leave  
80106624:	c3                   	ret    

80106625 <sys_fstat>:

int
sys_fstat(void)
{
80106625:	55                   	push   %ebp
80106626:	89 e5                	mov    %esp,%ebp
80106628:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010662b:	83 ec 04             	sub    $0x4,%esp
8010662e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106631:	50                   	push   %eax
80106632:	6a 00                	push   $0x0
80106634:	6a 00                	push   $0x0
80106636:	e8 ac fd ff ff       	call   801063e7 <argfd>
8010663b:	83 c4 10             	add    $0x10,%esp
8010663e:	85 c0                	test   %eax,%eax
80106640:	78 17                	js     80106659 <sys_fstat+0x34>
80106642:	83 ec 04             	sub    $0x4,%esp
80106645:	6a 14                	push   $0x14
80106647:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010664a:	50                   	push   %eax
8010664b:	6a 01                	push   $0x1
8010664d:	e8 81 fc ff ff       	call   801062d3 <argptr>
80106652:	83 c4 10             	add    $0x10,%esp
80106655:	85 c0                	test   %eax,%eax
80106657:	79 07                	jns    80106660 <sys_fstat+0x3b>
    return -1;
80106659:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010665e:	eb 13                	jmp    80106673 <sys_fstat+0x4e>
  return filestat(f, st);
80106660:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106663:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106666:	83 ec 08             	sub    $0x8,%esp
80106669:	52                   	push   %edx
8010666a:	50                   	push   %eax
8010666b:	e8 67 ab ff ff       	call   801011d7 <filestat>
80106670:	83 c4 10             	add    $0x10,%esp
}
80106673:	c9                   	leave  
80106674:	c3                   	ret    

80106675 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80106675:	55                   	push   %ebp
80106676:	89 e5                	mov    %esp,%ebp
80106678:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010667b:	83 ec 08             	sub    $0x8,%esp
8010667e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80106681:	50                   	push   %eax
80106682:	6a 00                	push   $0x0
80106684:	e8 a7 fc ff ff       	call   80106330 <argstr>
80106689:	83 c4 10             	add    $0x10,%esp
8010668c:	85 c0                	test   %eax,%eax
8010668e:	78 15                	js     801066a5 <sys_link+0x30>
80106690:	83 ec 08             	sub    $0x8,%esp
80106693:	8d 45 dc             	lea    -0x24(%ebp),%eax
80106696:	50                   	push   %eax
80106697:	6a 01                	push   $0x1
80106699:	e8 92 fc ff ff       	call   80106330 <argstr>
8010669e:	83 c4 10             	add    $0x10,%esp
801066a1:	85 c0                	test   %eax,%eax
801066a3:	79 0a                	jns    801066af <sys_link+0x3a>
    return -1;
801066a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066aa:	e9 68 01 00 00       	jmp    80106817 <sys_link+0x1a2>

  begin_op();
801066af:	e8 37 cf ff ff       	call   801035eb <begin_op>
  if((ip = namei(old)) == 0){
801066b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
801066b7:	83 ec 0c             	sub    $0xc,%esp
801066ba:	50                   	push   %eax
801066bb:	e8 06 bf ff ff       	call   801025c6 <namei>
801066c0:	83 c4 10             	add    $0x10,%esp
801066c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801066c6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066ca:	75 0f                	jne    801066db <sys_link+0x66>
    end_op();
801066cc:	e8 a6 cf ff ff       	call   80103677 <end_op>
    return -1;
801066d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066d6:	e9 3c 01 00 00       	jmp    80106817 <sys_link+0x1a2>
  }

  ilock(ip);
801066db:	83 ec 0c             	sub    $0xc,%esp
801066de:	ff 75 f4             	pushl  -0xc(%ebp)
801066e1:	e8 22 b3 ff ff       	call   80101a08 <ilock>
801066e6:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801066e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066ec:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801066f0:	66 83 f8 01          	cmp    $0x1,%ax
801066f4:	75 1d                	jne    80106713 <sys_link+0x9e>
    iunlockput(ip);
801066f6:	83 ec 0c             	sub    $0xc,%esp
801066f9:	ff 75 f4             	pushl  -0xc(%ebp)
801066fc:	e8 c7 b5 ff ff       	call   80101cc8 <iunlockput>
80106701:	83 c4 10             	add    $0x10,%esp
    end_op();
80106704:	e8 6e cf ff ff       	call   80103677 <end_op>
    return -1;
80106709:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010670e:	e9 04 01 00 00       	jmp    80106817 <sys_link+0x1a2>
  }

  ip->nlink++;
80106713:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106716:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010671a:	83 c0 01             	add    $0x1,%eax
8010671d:	89 c2                	mov    %eax,%edx
8010671f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106722:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106726:	83 ec 0c             	sub    $0xc,%esp
80106729:	ff 75 f4             	pushl  -0xc(%ebp)
8010672c:	e8 fd b0 ff ff       	call   8010182e <iupdate>
80106731:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80106734:	83 ec 0c             	sub    $0xc,%esp
80106737:	ff 75 f4             	pushl  -0xc(%ebp)
8010673a:	e8 27 b4 ff ff       	call   80101b66 <iunlock>
8010673f:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80106742:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106745:	83 ec 08             	sub    $0x8,%esp
80106748:	8d 55 e2             	lea    -0x1e(%ebp),%edx
8010674b:	52                   	push   %edx
8010674c:	50                   	push   %eax
8010674d:	e8 90 be ff ff       	call   801025e2 <nameiparent>
80106752:	83 c4 10             	add    $0x10,%esp
80106755:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106758:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010675c:	74 71                	je     801067cf <sys_link+0x15a>
    goto bad;
  ilock(dp);
8010675e:	83 ec 0c             	sub    $0xc,%esp
80106761:	ff 75 f0             	pushl  -0x10(%ebp)
80106764:	e8 9f b2 ff ff       	call   80101a08 <ilock>
80106769:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010676c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010676f:	8b 10                	mov    (%eax),%edx
80106771:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106774:	8b 00                	mov    (%eax),%eax
80106776:	39 c2                	cmp    %eax,%edx
80106778:	75 1d                	jne    80106797 <sys_link+0x122>
8010677a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010677d:	8b 40 04             	mov    0x4(%eax),%eax
80106780:	83 ec 04             	sub    $0x4,%esp
80106783:	50                   	push   %eax
80106784:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106787:	50                   	push   %eax
80106788:	ff 75 f0             	pushl  -0x10(%ebp)
8010678b:	e8 9a bb ff ff       	call   8010232a <dirlink>
80106790:	83 c4 10             	add    $0x10,%esp
80106793:	85 c0                	test   %eax,%eax
80106795:	79 10                	jns    801067a7 <sys_link+0x132>
    iunlockput(dp);
80106797:	83 ec 0c             	sub    $0xc,%esp
8010679a:	ff 75 f0             	pushl  -0x10(%ebp)
8010679d:	e8 26 b5 ff ff       	call   80101cc8 <iunlockput>
801067a2:	83 c4 10             	add    $0x10,%esp
    goto bad;
801067a5:	eb 29                	jmp    801067d0 <sys_link+0x15b>
  }
  iunlockput(dp);
801067a7:	83 ec 0c             	sub    $0xc,%esp
801067aa:	ff 75 f0             	pushl  -0x10(%ebp)
801067ad:	e8 16 b5 ff ff       	call   80101cc8 <iunlockput>
801067b2:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801067b5:	83 ec 0c             	sub    $0xc,%esp
801067b8:	ff 75 f4             	pushl  -0xc(%ebp)
801067bb:	e8 18 b4 ff ff       	call   80101bd8 <iput>
801067c0:	83 c4 10             	add    $0x10,%esp

  end_op();
801067c3:	e8 af ce ff ff       	call   80103677 <end_op>

  return 0;
801067c8:	b8 00 00 00 00       	mov    $0x0,%eax
801067cd:	eb 48                	jmp    80106817 <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
801067cf:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
801067d0:	83 ec 0c             	sub    $0xc,%esp
801067d3:	ff 75 f4             	pushl  -0xc(%ebp)
801067d6:	e8 2d b2 ff ff       	call   80101a08 <ilock>
801067db:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801067de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067e1:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801067e5:	83 e8 01             	sub    $0x1,%eax
801067e8:	89 c2                	mov    %eax,%edx
801067ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067ed:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801067f1:	83 ec 0c             	sub    $0xc,%esp
801067f4:	ff 75 f4             	pushl  -0xc(%ebp)
801067f7:	e8 32 b0 ff ff       	call   8010182e <iupdate>
801067fc:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801067ff:	83 ec 0c             	sub    $0xc,%esp
80106802:	ff 75 f4             	pushl  -0xc(%ebp)
80106805:	e8 be b4 ff ff       	call   80101cc8 <iunlockput>
8010680a:	83 c4 10             	add    $0x10,%esp
  end_op();
8010680d:	e8 65 ce ff ff       	call   80103677 <end_op>
  return -1;
80106812:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106817:	c9                   	leave  
80106818:	c3                   	ret    

80106819 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80106819:	55                   	push   %ebp
8010681a:	89 e5                	mov    %esp,%ebp
8010681c:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010681f:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80106826:	eb 40                	jmp    80106868 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010682b:	6a 10                	push   $0x10
8010682d:	50                   	push   %eax
8010682e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106831:	50                   	push   %eax
80106832:	ff 75 08             	pushl  0x8(%ebp)
80106835:	e8 3c b7 ff ff       	call   80101f76 <readi>
8010683a:	83 c4 10             	add    $0x10,%esp
8010683d:	83 f8 10             	cmp    $0x10,%eax
80106840:	74 0d                	je     8010684f <isdirempty+0x36>
      panic("isdirempty: readi");
80106842:	83 ec 0c             	sub    $0xc,%esp
80106845:	68 fa 98 10 80       	push   $0x801098fa
8010684a:	e8 17 9d ff ff       	call   80100566 <panic>
    if(de.inum != 0)
8010684f:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80106853:	66 85 c0             	test   %ax,%ax
80106856:	74 07                	je     8010685f <isdirempty+0x46>
      return 0;
80106858:	b8 00 00 00 00       	mov    $0x0,%eax
8010685d:	eb 1b                	jmp    8010687a <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010685f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106862:	83 c0 10             	add    $0x10,%eax
80106865:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106868:	8b 45 08             	mov    0x8(%ebp),%eax
8010686b:	8b 50 18             	mov    0x18(%eax),%edx
8010686e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106871:	39 c2                	cmp    %eax,%edx
80106873:	77 b3                	ja     80106828 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80106875:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010687a:	c9                   	leave  
8010687b:	c3                   	ret    

8010687c <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
8010687c:	55                   	push   %ebp
8010687d:	89 e5                	mov    %esp,%ebp
8010687f:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80106882:	83 ec 08             	sub    $0x8,%esp
80106885:	8d 45 cc             	lea    -0x34(%ebp),%eax
80106888:	50                   	push   %eax
80106889:	6a 00                	push   $0x0
8010688b:	e8 a0 fa ff ff       	call   80106330 <argstr>
80106890:	83 c4 10             	add    $0x10,%esp
80106893:	85 c0                	test   %eax,%eax
80106895:	79 0a                	jns    801068a1 <sys_unlink+0x25>
    return -1;
80106897:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010689c:	e9 bc 01 00 00       	jmp    80106a5d <sys_unlink+0x1e1>

  begin_op();
801068a1:	e8 45 cd ff ff       	call   801035eb <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801068a6:	8b 45 cc             	mov    -0x34(%ebp),%eax
801068a9:	83 ec 08             	sub    $0x8,%esp
801068ac:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801068af:	52                   	push   %edx
801068b0:	50                   	push   %eax
801068b1:	e8 2c bd ff ff       	call   801025e2 <nameiparent>
801068b6:	83 c4 10             	add    $0x10,%esp
801068b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801068bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801068c0:	75 0f                	jne    801068d1 <sys_unlink+0x55>
    end_op();
801068c2:	e8 b0 cd ff ff       	call   80103677 <end_op>
    return -1;
801068c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068cc:	e9 8c 01 00 00       	jmp    80106a5d <sys_unlink+0x1e1>
  }

  ilock(dp);
801068d1:	83 ec 0c             	sub    $0xc,%esp
801068d4:	ff 75 f4             	pushl  -0xc(%ebp)
801068d7:	e8 2c b1 ff ff       	call   80101a08 <ilock>
801068dc:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801068df:	83 ec 08             	sub    $0x8,%esp
801068e2:	68 0c 99 10 80       	push   $0x8010990c
801068e7:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801068ea:	50                   	push   %eax
801068eb:	e8 65 b9 ff ff       	call   80102255 <namecmp>
801068f0:	83 c4 10             	add    $0x10,%esp
801068f3:	85 c0                	test   %eax,%eax
801068f5:	0f 84 4a 01 00 00    	je     80106a45 <sys_unlink+0x1c9>
801068fb:	83 ec 08             	sub    $0x8,%esp
801068fe:	68 0e 99 10 80       	push   $0x8010990e
80106903:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106906:	50                   	push   %eax
80106907:	e8 49 b9 ff ff       	call   80102255 <namecmp>
8010690c:	83 c4 10             	add    $0x10,%esp
8010690f:	85 c0                	test   %eax,%eax
80106911:	0f 84 2e 01 00 00    	je     80106a45 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80106917:	83 ec 04             	sub    $0x4,%esp
8010691a:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010691d:	50                   	push   %eax
8010691e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106921:	50                   	push   %eax
80106922:	ff 75 f4             	pushl  -0xc(%ebp)
80106925:	e8 46 b9 ff ff       	call   80102270 <dirlookup>
8010692a:	83 c4 10             	add    $0x10,%esp
8010692d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106930:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106934:	0f 84 0a 01 00 00    	je     80106a44 <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
8010693a:	83 ec 0c             	sub    $0xc,%esp
8010693d:	ff 75 f0             	pushl  -0x10(%ebp)
80106940:	e8 c3 b0 ff ff       	call   80101a08 <ilock>
80106945:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80106948:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010694b:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010694f:	66 85 c0             	test   %ax,%ax
80106952:	7f 0d                	jg     80106961 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80106954:	83 ec 0c             	sub    $0xc,%esp
80106957:	68 11 99 10 80       	push   $0x80109911
8010695c:	e8 05 9c ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80106961:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106964:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106968:	66 83 f8 01          	cmp    $0x1,%ax
8010696c:	75 25                	jne    80106993 <sys_unlink+0x117>
8010696e:	83 ec 0c             	sub    $0xc,%esp
80106971:	ff 75 f0             	pushl  -0x10(%ebp)
80106974:	e8 a0 fe ff ff       	call   80106819 <isdirempty>
80106979:	83 c4 10             	add    $0x10,%esp
8010697c:	85 c0                	test   %eax,%eax
8010697e:	75 13                	jne    80106993 <sys_unlink+0x117>
    iunlockput(ip);
80106980:	83 ec 0c             	sub    $0xc,%esp
80106983:	ff 75 f0             	pushl  -0x10(%ebp)
80106986:	e8 3d b3 ff ff       	call   80101cc8 <iunlockput>
8010698b:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010698e:	e9 b2 00 00 00       	jmp    80106a45 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
80106993:	83 ec 04             	sub    $0x4,%esp
80106996:	6a 10                	push   $0x10
80106998:	6a 00                	push   $0x0
8010699a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010699d:	50                   	push   %eax
8010699e:	e8 e3 f5 ff ff       	call   80105f86 <memset>
801069a3:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801069a6:	8b 45 c8             	mov    -0x38(%ebp),%eax
801069a9:	6a 10                	push   $0x10
801069ab:	50                   	push   %eax
801069ac:	8d 45 e0             	lea    -0x20(%ebp),%eax
801069af:	50                   	push   %eax
801069b0:	ff 75 f4             	pushl  -0xc(%ebp)
801069b3:	e8 15 b7 ff ff       	call   801020cd <writei>
801069b8:	83 c4 10             	add    $0x10,%esp
801069bb:	83 f8 10             	cmp    $0x10,%eax
801069be:	74 0d                	je     801069cd <sys_unlink+0x151>
    panic("unlink: writei");
801069c0:	83 ec 0c             	sub    $0xc,%esp
801069c3:	68 23 99 10 80       	push   $0x80109923
801069c8:	e8 99 9b ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
801069cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069d0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801069d4:	66 83 f8 01          	cmp    $0x1,%ax
801069d8:	75 21                	jne    801069fb <sys_unlink+0x17f>
    dp->nlink--;
801069da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069dd:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801069e1:	83 e8 01             	sub    $0x1,%eax
801069e4:	89 c2                	mov    %eax,%edx
801069e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069e9:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801069ed:	83 ec 0c             	sub    $0xc,%esp
801069f0:	ff 75 f4             	pushl  -0xc(%ebp)
801069f3:	e8 36 ae ff ff       	call   8010182e <iupdate>
801069f8:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801069fb:	83 ec 0c             	sub    $0xc,%esp
801069fe:	ff 75 f4             	pushl  -0xc(%ebp)
80106a01:	e8 c2 b2 ff ff       	call   80101cc8 <iunlockput>
80106a06:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80106a09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a0c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106a10:	83 e8 01             	sub    $0x1,%eax
80106a13:	89 c2                	mov    %eax,%edx
80106a15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a18:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106a1c:	83 ec 0c             	sub    $0xc,%esp
80106a1f:	ff 75 f0             	pushl  -0x10(%ebp)
80106a22:	e8 07 ae ff ff       	call   8010182e <iupdate>
80106a27:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106a2a:	83 ec 0c             	sub    $0xc,%esp
80106a2d:	ff 75 f0             	pushl  -0x10(%ebp)
80106a30:	e8 93 b2 ff ff       	call   80101cc8 <iunlockput>
80106a35:	83 c4 10             	add    $0x10,%esp

  end_op();
80106a38:	e8 3a cc ff ff       	call   80103677 <end_op>

  return 0;
80106a3d:	b8 00 00 00 00       	mov    $0x0,%eax
80106a42:	eb 19                	jmp    80106a5d <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80106a44:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80106a45:	83 ec 0c             	sub    $0xc,%esp
80106a48:	ff 75 f4             	pushl  -0xc(%ebp)
80106a4b:	e8 78 b2 ff ff       	call   80101cc8 <iunlockput>
80106a50:	83 c4 10             	add    $0x10,%esp
  end_op();
80106a53:	e8 1f cc ff ff       	call   80103677 <end_op>
  return -1;
80106a58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106a5d:	c9                   	leave  
80106a5e:	c3                   	ret    

80106a5f <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80106a5f:	55                   	push   %ebp
80106a60:	89 e5                	mov    %esp,%ebp
80106a62:	83 ec 38             	sub    $0x38,%esp
80106a65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106a68:	8b 55 10             	mov    0x10(%ebp),%edx
80106a6b:	8b 45 14             	mov    0x14(%ebp),%eax
80106a6e:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106a72:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106a76:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106a7a:	83 ec 08             	sub    $0x8,%esp
80106a7d:	8d 45 de             	lea    -0x22(%ebp),%eax
80106a80:	50                   	push   %eax
80106a81:	ff 75 08             	pushl  0x8(%ebp)
80106a84:	e8 59 bb ff ff       	call   801025e2 <nameiparent>
80106a89:	83 c4 10             	add    $0x10,%esp
80106a8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106a8f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106a93:	75 0a                	jne    80106a9f <create+0x40>
    return 0;
80106a95:	b8 00 00 00 00       	mov    $0x0,%eax
80106a9a:	e9 90 01 00 00       	jmp    80106c2f <create+0x1d0>
  ilock(dp);
80106a9f:	83 ec 0c             	sub    $0xc,%esp
80106aa2:	ff 75 f4             	pushl  -0xc(%ebp)
80106aa5:	e8 5e af ff ff       	call   80101a08 <ilock>
80106aaa:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80106aad:	83 ec 04             	sub    $0x4,%esp
80106ab0:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106ab3:	50                   	push   %eax
80106ab4:	8d 45 de             	lea    -0x22(%ebp),%eax
80106ab7:	50                   	push   %eax
80106ab8:	ff 75 f4             	pushl  -0xc(%ebp)
80106abb:	e8 b0 b7 ff ff       	call   80102270 <dirlookup>
80106ac0:	83 c4 10             	add    $0x10,%esp
80106ac3:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106ac6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106aca:	74 50                	je     80106b1c <create+0xbd>
    iunlockput(dp);
80106acc:	83 ec 0c             	sub    $0xc,%esp
80106acf:	ff 75 f4             	pushl  -0xc(%ebp)
80106ad2:	e8 f1 b1 ff ff       	call   80101cc8 <iunlockput>
80106ad7:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80106ada:	83 ec 0c             	sub    $0xc,%esp
80106add:	ff 75 f0             	pushl  -0x10(%ebp)
80106ae0:	e8 23 af ff ff       	call   80101a08 <ilock>
80106ae5:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80106ae8:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106aed:	75 15                	jne    80106b04 <create+0xa5>
80106aef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106af2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106af6:	66 83 f8 02          	cmp    $0x2,%ax
80106afa:	75 08                	jne    80106b04 <create+0xa5>
      return ip;
80106afc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106aff:	e9 2b 01 00 00       	jmp    80106c2f <create+0x1d0>
    iunlockput(ip);
80106b04:	83 ec 0c             	sub    $0xc,%esp
80106b07:	ff 75 f0             	pushl  -0x10(%ebp)
80106b0a:	e8 b9 b1 ff ff       	call   80101cc8 <iunlockput>
80106b0f:	83 c4 10             	add    $0x10,%esp
    return 0;
80106b12:	b8 00 00 00 00       	mov    $0x0,%eax
80106b17:	e9 13 01 00 00       	jmp    80106c2f <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106b1c:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b23:	8b 00                	mov    (%eax),%eax
80106b25:	83 ec 08             	sub    $0x8,%esp
80106b28:	52                   	push   %edx
80106b29:	50                   	push   %eax
80106b2a:	e8 28 ac ff ff       	call   80101757 <ialloc>
80106b2f:	83 c4 10             	add    $0x10,%esp
80106b32:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106b35:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106b39:	75 0d                	jne    80106b48 <create+0xe9>
    panic("create: ialloc");
80106b3b:	83 ec 0c             	sub    $0xc,%esp
80106b3e:	68 32 99 10 80       	push   $0x80109932
80106b43:	e8 1e 9a ff ff       	call   80100566 <panic>

  ilock(ip);
80106b48:	83 ec 0c             	sub    $0xc,%esp
80106b4b:	ff 75 f0             	pushl  -0x10(%ebp)
80106b4e:	e8 b5 ae ff ff       	call   80101a08 <ilock>
80106b53:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80106b56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b59:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106b5d:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106b61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b64:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106b68:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106b6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b6f:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106b75:	83 ec 0c             	sub    $0xc,%esp
80106b78:	ff 75 f0             	pushl  -0x10(%ebp)
80106b7b:	e8 ae ac ff ff       	call   8010182e <iupdate>
80106b80:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80106b83:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106b88:	75 6a                	jne    80106bf4 <create+0x195>
    dp->nlink++;  // for ".."
80106b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b8d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106b91:	83 c0 01             	add    $0x1,%eax
80106b94:	89 c2                	mov    %eax,%edx
80106b96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b99:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106b9d:	83 ec 0c             	sub    $0xc,%esp
80106ba0:	ff 75 f4             	pushl  -0xc(%ebp)
80106ba3:	e8 86 ac ff ff       	call   8010182e <iupdate>
80106ba8:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106bab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106bae:	8b 40 04             	mov    0x4(%eax),%eax
80106bb1:	83 ec 04             	sub    $0x4,%esp
80106bb4:	50                   	push   %eax
80106bb5:	68 0c 99 10 80       	push   $0x8010990c
80106bba:	ff 75 f0             	pushl  -0x10(%ebp)
80106bbd:	e8 68 b7 ff ff       	call   8010232a <dirlink>
80106bc2:	83 c4 10             	add    $0x10,%esp
80106bc5:	85 c0                	test   %eax,%eax
80106bc7:	78 1e                	js     80106be7 <create+0x188>
80106bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bcc:	8b 40 04             	mov    0x4(%eax),%eax
80106bcf:	83 ec 04             	sub    $0x4,%esp
80106bd2:	50                   	push   %eax
80106bd3:	68 0e 99 10 80       	push   $0x8010990e
80106bd8:	ff 75 f0             	pushl  -0x10(%ebp)
80106bdb:	e8 4a b7 ff ff       	call   8010232a <dirlink>
80106be0:	83 c4 10             	add    $0x10,%esp
80106be3:	85 c0                	test   %eax,%eax
80106be5:	79 0d                	jns    80106bf4 <create+0x195>
      panic("create dots");
80106be7:	83 ec 0c             	sub    $0xc,%esp
80106bea:	68 41 99 10 80       	push   $0x80109941
80106bef:	e8 72 99 ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106bf4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106bf7:	8b 40 04             	mov    0x4(%eax),%eax
80106bfa:	83 ec 04             	sub    $0x4,%esp
80106bfd:	50                   	push   %eax
80106bfe:	8d 45 de             	lea    -0x22(%ebp),%eax
80106c01:	50                   	push   %eax
80106c02:	ff 75 f4             	pushl  -0xc(%ebp)
80106c05:	e8 20 b7 ff ff       	call   8010232a <dirlink>
80106c0a:	83 c4 10             	add    $0x10,%esp
80106c0d:	85 c0                	test   %eax,%eax
80106c0f:	79 0d                	jns    80106c1e <create+0x1bf>
    panic("create: dirlink");
80106c11:	83 ec 0c             	sub    $0xc,%esp
80106c14:	68 4d 99 10 80       	push   $0x8010994d
80106c19:	e8 48 99 ff ff       	call   80100566 <panic>

  iunlockput(dp);
80106c1e:	83 ec 0c             	sub    $0xc,%esp
80106c21:	ff 75 f4             	pushl  -0xc(%ebp)
80106c24:	e8 9f b0 ff ff       	call   80101cc8 <iunlockput>
80106c29:	83 c4 10             	add    $0x10,%esp

  return ip;
80106c2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106c2f:	c9                   	leave  
80106c30:	c3                   	ret    

80106c31 <sys_open>:

int
sys_open(void)
{
80106c31:	55                   	push   %ebp
80106c32:	89 e5                	mov    %esp,%ebp
80106c34:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106c37:	83 ec 08             	sub    $0x8,%esp
80106c3a:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106c3d:	50                   	push   %eax
80106c3e:	6a 00                	push   $0x0
80106c40:	e8 eb f6 ff ff       	call   80106330 <argstr>
80106c45:	83 c4 10             	add    $0x10,%esp
80106c48:	85 c0                	test   %eax,%eax
80106c4a:	78 15                	js     80106c61 <sys_open+0x30>
80106c4c:	83 ec 08             	sub    $0x8,%esp
80106c4f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106c52:	50                   	push   %eax
80106c53:	6a 01                	push   $0x1
80106c55:	e8 51 f6 ff ff       	call   801062ab <argint>
80106c5a:	83 c4 10             	add    $0x10,%esp
80106c5d:	85 c0                	test   %eax,%eax
80106c5f:	79 0a                	jns    80106c6b <sys_open+0x3a>
    return -1;
80106c61:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c66:	e9 61 01 00 00       	jmp    80106dcc <sys_open+0x19b>

  begin_op();
80106c6b:	e8 7b c9 ff ff       	call   801035eb <begin_op>

  if(omode & O_CREATE){
80106c70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c73:	25 00 02 00 00       	and    $0x200,%eax
80106c78:	85 c0                	test   %eax,%eax
80106c7a:	74 2a                	je     80106ca6 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80106c7c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106c7f:	6a 00                	push   $0x0
80106c81:	6a 00                	push   $0x0
80106c83:	6a 02                	push   $0x2
80106c85:	50                   	push   %eax
80106c86:	e8 d4 fd ff ff       	call   80106a5f <create>
80106c8b:	83 c4 10             	add    $0x10,%esp
80106c8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106c91:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c95:	75 75                	jne    80106d0c <sys_open+0xdb>
      end_op();
80106c97:	e8 db c9 ff ff       	call   80103677 <end_op>
      return -1;
80106c9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ca1:	e9 26 01 00 00       	jmp    80106dcc <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80106ca6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106ca9:	83 ec 0c             	sub    $0xc,%esp
80106cac:	50                   	push   %eax
80106cad:	e8 14 b9 ff ff       	call   801025c6 <namei>
80106cb2:	83 c4 10             	add    $0x10,%esp
80106cb5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106cb8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106cbc:	75 0f                	jne    80106ccd <sys_open+0x9c>
      end_op();
80106cbe:	e8 b4 c9 ff ff       	call   80103677 <end_op>
      return -1;
80106cc3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cc8:	e9 ff 00 00 00       	jmp    80106dcc <sys_open+0x19b>
    }
    ilock(ip);
80106ccd:	83 ec 0c             	sub    $0xc,%esp
80106cd0:	ff 75 f4             	pushl  -0xc(%ebp)
80106cd3:	e8 30 ad ff ff       	call   80101a08 <ilock>
80106cd8:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106cdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cde:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106ce2:	66 83 f8 01          	cmp    $0x1,%ax
80106ce6:	75 24                	jne    80106d0c <sys_open+0xdb>
80106ce8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106ceb:	85 c0                	test   %eax,%eax
80106ced:	74 1d                	je     80106d0c <sys_open+0xdb>
      iunlockput(ip);
80106cef:	83 ec 0c             	sub    $0xc,%esp
80106cf2:	ff 75 f4             	pushl  -0xc(%ebp)
80106cf5:	e8 ce af ff ff       	call   80101cc8 <iunlockput>
80106cfa:	83 c4 10             	add    $0x10,%esp
      end_op();
80106cfd:	e8 75 c9 ff ff       	call   80103677 <end_op>
      return -1;
80106d02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d07:	e9 c0 00 00 00       	jmp    80106dcc <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106d0c:	e8 20 a3 ff ff       	call   80101031 <filealloc>
80106d11:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106d14:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106d18:	74 17                	je     80106d31 <sys_open+0x100>
80106d1a:	83 ec 0c             	sub    $0xc,%esp
80106d1d:	ff 75 f0             	pushl  -0x10(%ebp)
80106d20:	e8 37 f7 ff ff       	call   8010645c <fdalloc>
80106d25:	83 c4 10             	add    $0x10,%esp
80106d28:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106d2b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106d2f:	79 2e                	jns    80106d5f <sys_open+0x12e>
    if(f)
80106d31:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106d35:	74 0e                	je     80106d45 <sys_open+0x114>
      fileclose(f);
80106d37:	83 ec 0c             	sub    $0xc,%esp
80106d3a:	ff 75 f0             	pushl  -0x10(%ebp)
80106d3d:	e8 ad a3 ff ff       	call   801010ef <fileclose>
80106d42:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106d45:	83 ec 0c             	sub    $0xc,%esp
80106d48:	ff 75 f4             	pushl  -0xc(%ebp)
80106d4b:	e8 78 af ff ff       	call   80101cc8 <iunlockput>
80106d50:	83 c4 10             	add    $0x10,%esp
    end_op();
80106d53:	e8 1f c9 ff ff       	call   80103677 <end_op>
    return -1;
80106d58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d5d:	eb 6d                	jmp    80106dcc <sys_open+0x19b>
  }
  iunlock(ip);
80106d5f:	83 ec 0c             	sub    $0xc,%esp
80106d62:	ff 75 f4             	pushl  -0xc(%ebp)
80106d65:	e8 fc ad ff ff       	call   80101b66 <iunlock>
80106d6a:	83 c4 10             	add    $0x10,%esp
  end_op();
80106d6d:	e8 05 c9 ff ff       	call   80103677 <end_op>

  f->type = FD_INODE;
80106d72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d75:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106d7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d7e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106d81:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106d84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d87:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106d8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d91:	83 e0 01             	and    $0x1,%eax
80106d94:	85 c0                	test   %eax,%eax
80106d96:	0f 94 c0             	sete   %al
80106d99:	89 c2                	mov    %eax,%edx
80106d9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d9e:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106da1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106da4:	83 e0 01             	and    $0x1,%eax
80106da7:	85 c0                	test   %eax,%eax
80106da9:	75 0a                	jne    80106db5 <sys_open+0x184>
80106dab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106dae:	83 e0 02             	and    $0x2,%eax
80106db1:	85 c0                	test   %eax,%eax
80106db3:	74 07                	je     80106dbc <sys_open+0x18b>
80106db5:	b8 01 00 00 00       	mov    $0x1,%eax
80106dba:	eb 05                	jmp    80106dc1 <sys_open+0x190>
80106dbc:	b8 00 00 00 00       	mov    $0x0,%eax
80106dc1:	89 c2                	mov    %eax,%edx
80106dc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106dc6:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106dc9:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106dcc:	c9                   	leave  
80106dcd:	c3                   	ret    

80106dce <sys_mkdir>:

int
sys_mkdir(void)
{
80106dce:	55                   	push   %ebp
80106dcf:	89 e5                	mov    %esp,%ebp
80106dd1:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106dd4:	e8 12 c8 ff ff       	call   801035eb <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106dd9:	83 ec 08             	sub    $0x8,%esp
80106ddc:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106ddf:	50                   	push   %eax
80106de0:	6a 00                	push   $0x0
80106de2:	e8 49 f5 ff ff       	call   80106330 <argstr>
80106de7:	83 c4 10             	add    $0x10,%esp
80106dea:	85 c0                	test   %eax,%eax
80106dec:	78 1b                	js     80106e09 <sys_mkdir+0x3b>
80106dee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106df1:	6a 00                	push   $0x0
80106df3:	6a 00                	push   $0x0
80106df5:	6a 01                	push   $0x1
80106df7:	50                   	push   %eax
80106df8:	e8 62 fc ff ff       	call   80106a5f <create>
80106dfd:	83 c4 10             	add    $0x10,%esp
80106e00:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106e03:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106e07:	75 0c                	jne    80106e15 <sys_mkdir+0x47>
    end_op();
80106e09:	e8 69 c8 ff ff       	call   80103677 <end_op>
    return -1;
80106e0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e13:	eb 18                	jmp    80106e2d <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106e15:	83 ec 0c             	sub    $0xc,%esp
80106e18:	ff 75 f4             	pushl  -0xc(%ebp)
80106e1b:	e8 a8 ae ff ff       	call   80101cc8 <iunlockput>
80106e20:	83 c4 10             	add    $0x10,%esp
  end_op();
80106e23:	e8 4f c8 ff ff       	call   80103677 <end_op>
  return 0;
80106e28:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106e2d:	c9                   	leave  
80106e2e:	c3                   	ret    

80106e2f <sys_mknod>:

int
sys_mknod(void)
{
80106e2f:	55                   	push   %ebp
80106e30:	89 e5                	mov    %esp,%ebp
80106e32:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106e35:	e8 b1 c7 ff ff       	call   801035eb <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106e3a:	83 ec 08             	sub    $0x8,%esp
80106e3d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106e40:	50                   	push   %eax
80106e41:	6a 00                	push   $0x0
80106e43:	e8 e8 f4 ff ff       	call   80106330 <argstr>
80106e48:	83 c4 10             	add    $0x10,%esp
80106e4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106e4e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106e52:	78 4f                	js     80106ea3 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80106e54:	83 ec 08             	sub    $0x8,%esp
80106e57:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106e5a:	50                   	push   %eax
80106e5b:	6a 01                	push   $0x1
80106e5d:	e8 49 f4 ff ff       	call   801062ab <argint>
80106e62:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106e65:	85 c0                	test   %eax,%eax
80106e67:	78 3a                	js     80106ea3 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106e69:	83 ec 08             	sub    $0x8,%esp
80106e6c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106e6f:	50                   	push   %eax
80106e70:	6a 02                	push   $0x2
80106e72:	e8 34 f4 ff ff       	call   801062ab <argint>
80106e77:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106e7a:	85 c0                	test   %eax,%eax
80106e7c:	78 25                	js     80106ea3 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106e7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106e81:	0f bf c8             	movswl %ax,%ecx
80106e84:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106e87:	0f bf d0             	movswl %ax,%edx
80106e8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106e8d:	51                   	push   %ecx
80106e8e:	52                   	push   %edx
80106e8f:	6a 03                	push   $0x3
80106e91:	50                   	push   %eax
80106e92:	e8 c8 fb ff ff       	call   80106a5f <create>
80106e97:	83 c4 10             	add    $0x10,%esp
80106e9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106e9d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106ea1:	75 0c                	jne    80106eaf <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106ea3:	e8 cf c7 ff ff       	call   80103677 <end_op>
    return -1;
80106ea8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ead:	eb 18                	jmp    80106ec7 <sys_mknod+0x98>
  }
  iunlockput(ip);
80106eaf:	83 ec 0c             	sub    $0xc,%esp
80106eb2:	ff 75 f0             	pushl  -0x10(%ebp)
80106eb5:	e8 0e ae ff ff       	call   80101cc8 <iunlockput>
80106eba:	83 c4 10             	add    $0x10,%esp
  end_op();
80106ebd:	e8 b5 c7 ff ff       	call   80103677 <end_op>
  return 0;
80106ec2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106ec7:	c9                   	leave  
80106ec8:	c3                   	ret    

80106ec9 <sys_chdir>:

int
sys_chdir(void)
{
80106ec9:	55                   	push   %ebp
80106eca:	89 e5                	mov    %esp,%ebp
80106ecc:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106ecf:	e8 17 c7 ff ff       	call   801035eb <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106ed4:	83 ec 08             	sub    $0x8,%esp
80106ed7:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106eda:	50                   	push   %eax
80106edb:	6a 00                	push   $0x0
80106edd:	e8 4e f4 ff ff       	call   80106330 <argstr>
80106ee2:	83 c4 10             	add    $0x10,%esp
80106ee5:	85 c0                	test   %eax,%eax
80106ee7:	78 18                	js     80106f01 <sys_chdir+0x38>
80106ee9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106eec:	83 ec 0c             	sub    $0xc,%esp
80106eef:	50                   	push   %eax
80106ef0:	e8 d1 b6 ff ff       	call   801025c6 <namei>
80106ef5:	83 c4 10             	add    $0x10,%esp
80106ef8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106efb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106eff:	75 0c                	jne    80106f0d <sys_chdir+0x44>
    end_op();
80106f01:	e8 71 c7 ff ff       	call   80103677 <end_op>
    return -1;
80106f06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f0b:	eb 6e                	jmp    80106f7b <sys_chdir+0xb2>
  }
  ilock(ip);
80106f0d:	83 ec 0c             	sub    $0xc,%esp
80106f10:	ff 75 f4             	pushl  -0xc(%ebp)
80106f13:	e8 f0 aa ff ff       	call   80101a08 <ilock>
80106f18:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f1e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106f22:	66 83 f8 01          	cmp    $0x1,%ax
80106f26:	74 1a                	je     80106f42 <sys_chdir+0x79>
    iunlockput(ip);
80106f28:	83 ec 0c             	sub    $0xc,%esp
80106f2b:	ff 75 f4             	pushl  -0xc(%ebp)
80106f2e:	e8 95 ad ff ff       	call   80101cc8 <iunlockput>
80106f33:	83 c4 10             	add    $0x10,%esp
    end_op();
80106f36:	e8 3c c7 ff ff       	call   80103677 <end_op>
    return -1;
80106f3b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f40:	eb 39                	jmp    80106f7b <sys_chdir+0xb2>
  }
  iunlock(ip);
80106f42:	83 ec 0c             	sub    $0xc,%esp
80106f45:	ff 75 f4             	pushl  -0xc(%ebp)
80106f48:	e8 19 ac ff ff       	call   80101b66 <iunlock>
80106f4d:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80106f50:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f56:	8b 40 68             	mov    0x68(%eax),%eax
80106f59:	83 ec 0c             	sub    $0xc,%esp
80106f5c:	50                   	push   %eax
80106f5d:	e8 76 ac ff ff       	call   80101bd8 <iput>
80106f62:	83 c4 10             	add    $0x10,%esp
  end_op();
80106f65:	e8 0d c7 ff ff       	call   80103677 <end_op>
  proc->cwd = ip;
80106f6a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f70:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106f73:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106f76:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106f7b:	c9                   	leave  
80106f7c:	c3                   	ret    

80106f7d <sys_exec>:

int
sys_exec(void)
{
80106f7d:	55                   	push   %ebp
80106f7e:	89 e5                	mov    %esp,%ebp
80106f80:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106f86:	83 ec 08             	sub    $0x8,%esp
80106f89:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106f8c:	50                   	push   %eax
80106f8d:	6a 00                	push   $0x0
80106f8f:	e8 9c f3 ff ff       	call   80106330 <argstr>
80106f94:	83 c4 10             	add    $0x10,%esp
80106f97:	85 c0                	test   %eax,%eax
80106f99:	78 18                	js     80106fb3 <sys_exec+0x36>
80106f9b:	83 ec 08             	sub    $0x8,%esp
80106f9e:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106fa4:	50                   	push   %eax
80106fa5:	6a 01                	push   $0x1
80106fa7:	e8 ff f2 ff ff       	call   801062ab <argint>
80106fac:	83 c4 10             	add    $0x10,%esp
80106faf:	85 c0                	test   %eax,%eax
80106fb1:	79 0a                	jns    80106fbd <sys_exec+0x40>
    return -1;
80106fb3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fb8:	e9 c6 00 00 00       	jmp    80107083 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106fbd:	83 ec 04             	sub    $0x4,%esp
80106fc0:	68 80 00 00 00       	push   $0x80
80106fc5:	6a 00                	push   $0x0
80106fc7:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106fcd:	50                   	push   %eax
80106fce:	e8 b3 ef ff ff       	call   80105f86 <memset>
80106fd3:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106fd6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fe0:	83 f8 1f             	cmp    $0x1f,%eax
80106fe3:	76 0a                	jbe    80106fef <sys_exec+0x72>
      return -1;
80106fe5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fea:	e9 94 00 00 00       	jmp    80107083 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106fef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ff2:	c1 e0 02             	shl    $0x2,%eax
80106ff5:	89 c2                	mov    %eax,%edx
80106ff7:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106ffd:	01 c2                	add    %eax,%edx
80106fff:	83 ec 08             	sub    $0x8,%esp
80107002:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80107008:	50                   	push   %eax
80107009:	52                   	push   %edx
8010700a:	e8 00 f2 ff ff       	call   8010620f <fetchint>
8010700f:	83 c4 10             	add    $0x10,%esp
80107012:	85 c0                	test   %eax,%eax
80107014:	79 07                	jns    8010701d <sys_exec+0xa0>
      return -1;
80107016:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010701b:	eb 66                	jmp    80107083 <sys_exec+0x106>
    if(uarg == 0){
8010701d:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107023:	85 c0                	test   %eax,%eax
80107025:	75 27                	jne    8010704e <sys_exec+0xd1>
      argv[i] = 0;
80107027:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010702a:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80107031:	00 00 00 00 
      break;
80107035:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80107036:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107039:	83 ec 08             	sub    $0x8,%esp
8010703c:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80107042:	52                   	push   %edx
80107043:	50                   	push   %eax
80107044:	e8 c6 9b ff ff       	call   80100c0f <exec>
80107049:	83 c4 10             	add    $0x10,%esp
8010704c:	eb 35                	jmp    80107083 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
8010704e:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80107054:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107057:	c1 e2 02             	shl    $0x2,%edx
8010705a:	01 c2                	add    %eax,%edx
8010705c:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107062:	83 ec 08             	sub    $0x8,%esp
80107065:	52                   	push   %edx
80107066:	50                   	push   %eax
80107067:	e8 dd f1 ff ff       	call   80106249 <fetchstr>
8010706c:	83 c4 10             	add    $0x10,%esp
8010706f:	85 c0                	test   %eax,%eax
80107071:	79 07                	jns    8010707a <sys_exec+0xfd>
      return -1;
80107073:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107078:	eb 09                	jmp    80107083 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010707a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
8010707e:	e9 5a ff ff ff       	jmp    80106fdd <sys_exec+0x60>
  return exec(path, argv);
}
80107083:	c9                   	leave  
80107084:	c3                   	ret    

80107085 <sys_pipe>:

int
sys_pipe(void)
{
80107085:	55                   	push   %ebp
80107086:	89 e5                	mov    %esp,%ebp
80107088:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010708b:	83 ec 04             	sub    $0x4,%esp
8010708e:	6a 08                	push   $0x8
80107090:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107093:	50                   	push   %eax
80107094:	6a 00                	push   $0x0
80107096:	e8 38 f2 ff ff       	call   801062d3 <argptr>
8010709b:	83 c4 10             	add    $0x10,%esp
8010709e:	85 c0                	test   %eax,%eax
801070a0:	79 0a                	jns    801070ac <sys_pipe+0x27>
    return -1;
801070a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070a7:	e9 af 00 00 00       	jmp    8010715b <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
801070ac:	83 ec 08             	sub    $0x8,%esp
801070af:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801070b2:	50                   	push   %eax
801070b3:	8d 45 e8             	lea    -0x18(%ebp),%eax
801070b6:	50                   	push   %eax
801070b7:	e8 23 d0 ff ff       	call   801040df <pipealloc>
801070bc:	83 c4 10             	add    $0x10,%esp
801070bf:	85 c0                	test   %eax,%eax
801070c1:	79 0a                	jns    801070cd <sys_pipe+0x48>
    return -1;
801070c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070c8:	e9 8e 00 00 00       	jmp    8010715b <sys_pipe+0xd6>
  fd0 = -1;
801070cd:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801070d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801070d7:	83 ec 0c             	sub    $0xc,%esp
801070da:	50                   	push   %eax
801070db:	e8 7c f3 ff ff       	call   8010645c <fdalloc>
801070e0:	83 c4 10             	add    $0x10,%esp
801070e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801070e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801070ea:	78 18                	js     80107104 <sys_pipe+0x7f>
801070ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801070ef:	83 ec 0c             	sub    $0xc,%esp
801070f2:	50                   	push   %eax
801070f3:	e8 64 f3 ff ff       	call   8010645c <fdalloc>
801070f8:	83 c4 10             	add    $0x10,%esp
801070fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801070fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107102:	79 3f                	jns    80107143 <sys_pipe+0xbe>
    if(fd0 >= 0)
80107104:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107108:	78 14                	js     8010711e <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
8010710a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107110:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107113:	83 c2 08             	add    $0x8,%edx
80107116:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010711d:	00 
    fileclose(rf);
8010711e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107121:	83 ec 0c             	sub    $0xc,%esp
80107124:	50                   	push   %eax
80107125:	e8 c5 9f ff ff       	call   801010ef <fileclose>
8010712a:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
8010712d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107130:	83 ec 0c             	sub    $0xc,%esp
80107133:	50                   	push   %eax
80107134:	e8 b6 9f ff ff       	call   801010ef <fileclose>
80107139:	83 c4 10             	add    $0x10,%esp
    return -1;
8010713c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107141:	eb 18                	jmp    8010715b <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80107143:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107146:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107149:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010714b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010714e:	8d 50 04             	lea    0x4(%eax),%edx
80107151:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107154:	89 02                	mov    %eax,(%edx)
  return 0;
80107156:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010715b:	c9                   	leave  
8010715c:	c3                   	ret    

8010715d <outw>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outw(ushort port, ushort data)
{
8010715d:	55                   	push   %ebp
8010715e:	89 e5                	mov    %esp,%ebp
80107160:	83 ec 08             	sub    $0x8,%esp
80107163:	8b 55 08             	mov    0x8(%ebp),%edx
80107166:	8b 45 0c             	mov    0xc(%ebp),%eax
80107169:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010716d:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107171:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
80107175:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107179:	66 ef                	out    %ax,(%dx)
}
8010717b:	90                   	nop
8010717c:	c9                   	leave  
8010717d:	c3                   	ret    

8010717e <sys_fork>:
#include "proc.h"
#include "uproc.h"

int
sys_fork(void)
{
8010717e:	55                   	push   %ebp
8010717f:	89 e5                	mov    %esp,%ebp
80107181:	83 ec 08             	sub    $0x8,%esp
  return fork();
80107184:	e8 57 d7 ff ff       	call   801048e0 <fork>
}
80107189:	c9                   	leave  
8010718a:	c3                   	ret    

8010718b <sys_exit>:

int
sys_exit(void)
{
8010718b:	55                   	push   %ebp
8010718c:	89 e5                	mov    %esp,%ebp
8010718e:	83 ec 08             	sub    $0x8,%esp
  exit();
80107191:	e8 89 d9 ff ff       	call   80104b1f <exit>
  return 0;  // not reached
80107196:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010719b:	c9                   	leave  
8010719c:	c3                   	ret    

8010719d <sys_wait>:

int
sys_wait(void)
{
8010719d:	55                   	push   %ebp
8010719e:	89 e5                	mov    %esp,%ebp
801071a0:	83 ec 08             	sub    $0x8,%esp
  return wait();
801071a3:	e8 79 db ff ff       	call   80104d21 <wait>
}
801071a8:	c9                   	leave  
801071a9:	c3                   	ret    

801071aa <sys_kill>:

int
sys_kill(void)
{
801071aa:	55                   	push   %ebp
801071ab:	89 e5                	mov    %esp,%ebp
801071ad:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801071b0:	83 ec 08             	sub    $0x8,%esp
801071b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
801071b6:	50                   	push   %eax
801071b7:	6a 00                	push   $0x0
801071b9:	e8 ed f0 ff ff       	call   801062ab <argint>
801071be:	83 c4 10             	add    $0x10,%esp
801071c1:	85 c0                	test   %eax,%eax
801071c3:	79 07                	jns    801071cc <sys_kill+0x22>
    return -1;
801071c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071ca:	eb 0f                	jmp    801071db <sys_kill+0x31>
  return kill(pid);
801071cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071cf:	83 ec 0c             	sub    $0xc,%esp
801071d2:	50                   	push   %eax
801071d3:	e8 af e1 ff ff       	call   80105387 <kill>
801071d8:	83 c4 10             	add    $0x10,%esp
}
801071db:	c9                   	leave  
801071dc:	c3                   	ret    

801071dd <sys_getpid>:

int
sys_getpid(void)
{
801071dd:	55                   	push   %ebp
801071de:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801071e0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071e6:	8b 40 10             	mov    0x10(%eax),%eax
}
801071e9:	5d                   	pop    %ebp
801071ea:	c3                   	ret    

801071eb <sys_sbrk>:

int
sys_sbrk(void)
{
801071eb:	55                   	push   %ebp
801071ec:	89 e5                	mov    %esp,%ebp
801071ee:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801071f1:	83 ec 08             	sub    $0x8,%esp
801071f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801071f7:	50                   	push   %eax
801071f8:	6a 00                	push   $0x0
801071fa:	e8 ac f0 ff ff       	call   801062ab <argint>
801071ff:	83 c4 10             	add    $0x10,%esp
80107202:	85 c0                	test   %eax,%eax
80107204:	79 07                	jns    8010720d <sys_sbrk+0x22>
    return -1;
80107206:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010720b:	eb 28                	jmp    80107235 <sys_sbrk+0x4a>
  addr = proc->sz;
8010720d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107213:	8b 00                	mov    (%eax),%eax
80107215:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80107218:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010721b:	83 ec 0c             	sub    $0xc,%esp
8010721e:	50                   	push   %eax
8010721f:	e8 19 d6 ff ff       	call   8010483d <growproc>
80107224:	83 c4 10             	add    $0x10,%esp
80107227:	85 c0                	test   %eax,%eax
80107229:	79 07                	jns    80107232 <sys_sbrk+0x47>
    return -1;
8010722b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107230:	eb 03                	jmp    80107235 <sys_sbrk+0x4a>
  return addr;
80107232:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107235:	c9                   	leave  
80107236:	c3                   	ret    

80107237 <sys_sleep>:

int
sys_sleep(void)
{
80107237:	55                   	push   %ebp
80107238:	89 e5                	mov    %esp,%ebp
8010723a:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
8010723d:	83 ec 08             	sub    $0x8,%esp
80107240:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107243:	50                   	push   %eax
80107244:	6a 00                	push   $0x0
80107246:	e8 60 f0 ff ff       	call   801062ab <argint>
8010724b:	83 c4 10             	add    $0x10,%esp
8010724e:	85 c0                	test   %eax,%eax
80107250:	79 07                	jns    80107259 <sys_sleep+0x22>
    return -1;
80107252:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107257:	eb 44                	jmp    8010729d <sys_sleep+0x66>
  ticks0 = ticks;
80107259:	a1 00 67 11 80       	mov    0x80116700,%eax
8010725e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80107261:	eb 26                	jmp    80107289 <sys_sleep+0x52>
    if(proc->killed){
80107263:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107269:	8b 40 24             	mov    0x24(%eax),%eax
8010726c:	85 c0                	test   %eax,%eax
8010726e:	74 07                	je     80107277 <sys_sleep+0x40>
      return -1;
80107270:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107275:	eb 26                	jmp    8010729d <sys_sleep+0x66>
    }
    sleep(&ticks, (struct spinlock *)0);
80107277:	83 ec 08             	sub    $0x8,%esp
8010727a:	6a 00                	push   $0x0
8010727c:	68 00 67 11 80       	push   $0x80116700
80107281:	e8 83 df ff ff       	call   80105209 <sleep>
80107286:	83 c4 10             	add    $0x10,%esp
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80107289:	a1 00 67 11 80       	mov    0x80116700,%eax
8010728e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107291:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107294:	39 d0                	cmp    %edx,%eax
80107296:	72 cb                	jb     80107263 <sys_sleep+0x2c>
    if(proc->killed){
      return -1;
    }
    sleep(&ticks, (struct spinlock *)0);
  }
  return 0;
80107298:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010729d:	c9                   	leave  
8010729e:	c3                   	ret    

8010729f <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010729f:	55                   	push   %ebp
801072a0:	89 e5                	mov    %esp,%ebp
801072a2:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  xticks = ticks;
801072a5:	a1 00 67 11 80       	mov    0x80116700,%eax
801072aa:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return xticks;
801072ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801072b0:	c9                   	leave  
801072b1:	c3                   	ret    

801072b2 <sys_halt>:

//Turn of the computer
int
sys_halt(void){
801072b2:	55                   	push   %ebp
801072b3:	89 e5                	mov    %esp,%ebp
801072b5:	83 ec 08             	sub    $0x8,%esp
  cprintf("Shutting down ...\n");
801072b8:	83 ec 0c             	sub    $0xc,%esp
801072bb:	68 5d 99 10 80       	push   $0x8010995d
801072c0:	e8 01 91 ff ff       	call   801003c6 <cprintf>
801072c5:	83 c4 10             	add    $0x10,%esp
  outw( 0x604, 0x0 | 0x2000);
801072c8:	83 ec 08             	sub    $0x8,%esp
801072cb:	68 00 20 00 00       	push   $0x2000
801072d0:	68 04 06 00 00       	push   $0x604
801072d5:	e8 83 fe ff ff       	call   8010715d <outw>
801072da:	83 c4 10             	add    $0x10,%esp
  return 0;
801072dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801072e2:	c9                   	leave  
801072e3:	c3                   	ret    

801072e4 <sys_date>:


int
sys_date(void)
{
801072e4:	55                   	push   %ebp
801072e5:	89 e5                	mov    %esp,%ebp
801072e7:	83 ec 18             	sub    $0x18,%esp
  struct rtcdate *d;
  if(argptr(0, (void*)&d, sizeof(struct rtcdate)) < 0)
801072ea:	83 ec 04             	sub    $0x4,%esp
801072ed:	6a 18                	push   $0x18
801072ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
801072f2:	50                   	push   %eax
801072f3:	6a 00                	push   $0x0
801072f5:	e8 d9 ef ff ff       	call   801062d3 <argptr>
801072fa:	83 c4 10             	add    $0x10,%esp
801072fd:	85 c0                	test   %eax,%eax
801072ff:	79 07                	jns    80107308 <sys_date+0x24>
    return -1;
80107301:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107306:	eb 14                	jmp    8010731c <sys_date+0x38>
  cmostime(d);
80107308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010730b:	83 ec 0c             	sub    $0xc,%esp
8010730e:	50                   	push   %eax
8010730f:	e8 52 bf ff ff       	call   80103266 <cmostime>
80107314:	83 c4 10             	add    $0x10,%esp
  return 0;
80107317:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010731c:	c9                   	leave  
8010731d:	c3                   	ret    

8010731e <sys_getuid>:

//Get gid
uint
sys_getuid(void)
{
8010731e:	55                   	push   %ebp
8010731f:	89 e5                	mov    %esp,%ebp
  return proc->uid;
80107321:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107327:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
8010732d:	5d                   	pop    %ebp
8010732e:	c3                   	ret    

8010732f <sys_getgid>:

//Get gid
uint
sys_getgid(void)
{
8010732f:	55                   	push   %ebp
80107330:	89 e5                	mov    %esp,%ebp
  return proc->gid;
80107332:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107338:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
}
8010733e:	5d                   	pop    %ebp
8010733f:	c3                   	ret    

80107340 <sys_getppid>:

//Returns init's pid, since it has no parent.
//Or returns the parents pid.
uint
sys_getppid(void)
{
80107340:	55                   	push   %ebp
80107341:	89 e5                	mov    %esp,%ebp
  if(proc->parent != 0)
80107343:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107349:	8b 40 14             	mov    0x14(%eax),%eax
8010734c:	85 c0                	test   %eax,%eax
8010734e:	74 0e                	je     8010735e <sys_getppid+0x1e>
    return proc->parent->pid;
80107350:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107356:	8b 40 14             	mov    0x14(%eax),%eax
80107359:	8b 40 10             	mov    0x10(%eax),%eax
8010735c:	eb 09                	jmp    80107367 <sys_getppid+0x27>
  return proc->pid;
8010735e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107364:	8b 40 10             	mov    0x10(%eax),%eax
}
80107367:	5d                   	pop    %ebp
80107368:	c3                   	ret    

80107369 <sys_setuid>:

//Sets the uid after making sure that the argument
//is within the bounds 0<=32767
int
sys_setuid(uint _uid)
{
80107369:	55                   	push   %ebp
8010736a:	89 e5                	mov    %esp,%ebp
8010736c:	83 ec 08             	sub    $0x8,%esp
  argint(0, (int*)&_uid);
8010736f:	83 ec 08             	sub    $0x8,%esp
80107372:	8d 45 08             	lea    0x8(%ebp),%eax
80107375:	50                   	push   %eax
80107376:	6a 00                	push   $0x0
80107378:	e8 2e ef ff ff       	call   801062ab <argint>
8010737d:	83 c4 10             	add    $0x10,%esp
  if (_uid>= 0 && _uid<= 32767)
80107380:	8b 45 08             	mov    0x8(%ebp),%eax
80107383:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
80107388:	77 16                	ja     801073a0 <sys_setuid+0x37>
  {
    proc->uid = _uid;
8010738a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107390:	8b 55 08             	mov    0x8(%ebp),%edx
80107393:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
    return 0;
80107399:	b8 00 00 00 00       	mov    $0x0,%eax
8010739e:	eb 05                	jmp    801073a5 <sys_setuid+0x3c>
  }
  return -1;
801073a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801073a5:	c9                   	leave  
801073a6:	c3                   	ret    

801073a7 <sys_setgid>:

//Sets the gid after making sure that the argument
//is within the bouds 0<=32767
int
sys_setgid(uint _uid)
{
801073a7:	55                   	push   %ebp
801073a8:	89 e5                	mov    %esp,%ebp
801073aa:	83 ec 08             	sub    $0x8,%esp
  argint(0, (int*)&_uid);
801073ad:	83 ec 08             	sub    $0x8,%esp
801073b0:	8d 45 08             	lea    0x8(%ebp),%eax
801073b3:	50                   	push   %eax
801073b4:	6a 00                	push   $0x0
801073b6:	e8 f0 ee ff ff       	call   801062ab <argint>
801073bb:	83 c4 10             	add    $0x10,%esp
  if (_uid>= 0 && _uid<= 32767)
801073be:	8b 45 08             	mov    0x8(%ebp),%eax
801073c1:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
801073c6:	77 16                	ja     801073de <sys_setgid+0x37>
  {
    proc->gid = _uid;
801073c8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073ce:	8b 55 08             	mov    0x8(%ebp),%edx
801073d1:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
    return 0;
801073d7:	b8 00 00 00 00       	mov    $0x0,%eax
801073dc:	eb 05                	jmp    801073e3 <sys_setgid+0x3c>
  }
  return -1;
801073de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801073e3:	c9                   	leave  
801073e4:	c3                   	ret    

801073e5 <sys_getprocs>:

//Getprocs calls getprocs in proc.c in order to lock the ptable and
//grab all the processes off of that when ps is called.
int
sys_getprocs(int max, struct uproc* table)
{
801073e5:	55                   	push   %ebp
801073e6:	89 e5                	mov    %esp,%ebp
801073e8:	83 ec 08             	sub    $0x8,%esp
  if(argint(0,&max)< 0 || argptr(1,(void*)&table,sizeof(*table)*max) <0)
801073eb:	83 ec 08             	sub    $0x8,%esp
801073ee:	8d 45 08             	lea    0x8(%ebp),%eax
801073f1:	50                   	push   %eax
801073f2:	6a 00                	push   $0x0
801073f4:	e8 b2 ee ff ff       	call   801062ab <argint>
801073f9:	83 c4 10             	add    $0x10,%esp
801073fc:	85 c0                	test   %eax,%eax
801073fe:	78 1c                	js     8010741c <sys_getprocs+0x37>
80107400:	8b 45 08             	mov    0x8(%ebp),%eax
80107403:	6b c0 5c             	imul   $0x5c,%eax,%eax
80107406:	83 ec 04             	sub    $0x4,%esp
80107409:	50                   	push   %eax
8010740a:	8d 45 0c             	lea    0xc(%ebp),%eax
8010740d:	50                   	push   %eax
8010740e:	6a 01                	push   $0x1
80107410:	e8 be ee ff ff       	call   801062d3 <argptr>
80107415:	83 c4 10             	add    $0x10,%esp
80107418:	85 c0                	test   %eax,%eax
8010741a:	79 07                	jns    80107423 <sys_getprocs+0x3e>
    return -1;
8010741c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107421:	eb 13                	jmp    80107436 <sys_getprocs+0x51>
  return getprocs(max,table);
80107423:	8b 55 0c             	mov    0xc(%ebp),%edx
80107426:	8b 45 08             	mov    0x8(%ebp),%eax
80107429:	83 ec 08             	sub    $0x8,%esp
8010742c:	52                   	push   %edx
8010742d:	50                   	push   %eax
8010742e:	e8 c4 e4 ff ff       	call   801058f7 <getprocs>
80107433:	83 c4 10             	add    $0x10,%esp
}
80107436:	c9                   	leave  
80107437:	c3                   	ret    

80107438 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107438:	55                   	push   %ebp
80107439:	89 e5                	mov    %esp,%ebp
8010743b:	83 ec 08             	sub    $0x8,%esp
8010743e:	8b 55 08             	mov    0x8(%ebp),%edx
80107441:	8b 45 0c             	mov    0xc(%ebp),%eax
80107444:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107448:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010744b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010744f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107453:	ee                   	out    %al,(%dx)
}
80107454:	90                   	nop
80107455:	c9                   	leave  
80107456:	c3                   	ret    

80107457 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80107457:	55                   	push   %ebp
80107458:	89 e5                	mov    %esp,%ebp
8010745a:	83 ec 08             	sub    $0x8,%esp
  // Interrupt TPS times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
8010745d:	6a 34                	push   $0x34
8010745f:	6a 43                	push   $0x43
80107461:	e8 d2 ff ff ff       	call   80107438 <outb>
80107466:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) % 256);
80107469:	68 a9 00 00 00       	push   $0xa9
8010746e:	6a 40                	push   $0x40
80107470:	e8 c3 ff ff ff       	call   80107438 <outb>
80107475:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) / 256);
80107478:	6a 04                	push   $0x4
8010747a:	6a 40                	push   $0x40
8010747c:	e8 b7 ff ff ff       	call   80107438 <outb>
80107481:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80107484:	83 ec 0c             	sub    $0xc,%esp
80107487:	6a 00                	push   $0x0
80107489:	e8 3b cb ff ff       	call   80103fc9 <picenable>
8010748e:	83 c4 10             	add    $0x10,%esp
}
80107491:	90                   	nop
80107492:	c9                   	leave  
80107493:	c3                   	ret    

80107494 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80107494:	1e                   	push   %ds
  pushl %es
80107495:	06                   	push   %es
  pushl %fs
80107496:	0f a0                	push   %fs
  pushl %gs
80107498:	0f a8                	push   %gs
  pushal
8010749a:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010749b:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010749f:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801074a1:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801074a3:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801074a7:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801074a9:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801074ab:	54                   	push   %esp
  call trap
801074ac:	e8 ce 01 00 00       	call   8010767f <trap>
  addl $4, %esp
801074b1:	83 c4 04             	add    $0x4,%esp

801074b4 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801074b4:	61                   	popa   
  popl %gs
801074b5:	0f a9                	pop    %gs
  popl %fs
801074b7:	0f a1                	pop    %fs
  popl %es
801074b9:	07                   	pop    %es
  popl %ds
801074ba:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801074bb:	83 c4 08             	add    $0x8,%esp
  iret
801074be:	cf                   	iret   

801074bf <atom_inc>:

// Routines added for CS333
// atom_inc() added to simplify handling of ticks global
static inline void
atom_inc(volatile int *num)
{
801074bf:	55                   	push   %ebp
801074c0:	89 e5                	mov    %esp,%ebp
  asm volatile ( "lock incl %0" : "=m" (*num));
801074c2:	8b 45 08             	mov    0x8(%ebp),%eax
801074c5:	f0 ff 00             	lock incl (%eax)
}
801074c8:	90                   	nop
801074c9:	5d                   	pop    %ebp
801074ca:	c3                   	ret    

801074cb <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801074cb:	55                   	push   %ebp
801074cc:	89 e5                	mov    %esp,%ebp
801074ce:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801074d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801074d4:	83 e8 01             	sub    $0x1,%eax
801074d7:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801074db:	8b 45 08             	mov    0x8(%ebp),%eax
801074de:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801074e2:	8b 45 08             	mov    0x8(%ebp),%eax
801074e5:	c1 e8 10             	shr    $0x10,%eax
801074e8:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801074ec:	8d 45 fa             	lea    -0x6(%ebp),%eax
801074ef:	0f 01 18             	lidtl  (%eax)
}
801074f2:	90                   	nop
801074f3:	c9                   	leave  
801074f4:	c3                   	ret    

801074f5 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801074f5:	55                   	push   %ebp
801074f6:	89 e5                	mov    %esp,%ebp
801074f8:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801074fb:	0f 20 d0             	mov    %cr2,%eax
801074fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80107501:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80107504:	c9                   	leave  
80107505:	c3                   	ret    

80107506 <tvinit>:
// Software Developer’s Manual, Vol 3A, 8.1.1 Guaranteed Atomic Operations.
uint ticks __attribute__ ((aligned (4)));

void
tvinit(void)
{
80107506:	55                   	push   %ebp
80107507:	89 e5                	mov    %esp,%ebp
80107509:	83 ec 10             	sub    $0x10,%esp
  int i;

  for(i = 0; i < 256; i++)
8010750c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80107513:	e9 c3 00 00 00       	jmp    801075db <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80107518:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010751b:	8b 04 85 b4 c0 10 80 	mov    -0x7fef3f4c(,%eax,4),%eax
80107522:	89 c2                	mov    %eax,%edx
80107524:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107527:	66 89 14 c5 00 5f 11 	mov    %dx,-0x7feea100(,%eax,8)
8010752e:	80 
8010752f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107532:	66 c7 04 c5 02 5f 11 	movw   $0x8,-0x7feea0fe(,%eax,8)
80107539:	80 08 00 
8010753c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010753f:	0f b6 14 c5 04 5f 11 	movzbl -0x7feea0fc(,%eax,8),%edx
80107546:	80 
80107547:	83 e2 e0             	and    $0xffffffe0,%edx
8010754a:	88 14 c5 04 5f 11 80 	mov    %dl,-0x7feea0fc(,%eax,8)
80107551:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107554:	0f b6 14 c5 04 5f 11 	movzbl -0x7feea0fc(,%eax,8),%edx
8010755b:	80 
8010755c:	83 e2 1f             	and    $0x1f,%edx
8010755f:	88 14 c5 04 5f 11 80 	mov    %dl,-0x7feea0fc(,%eax,8)
80107566:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107569:	0f b6 14 c5 05 5f 11 	movzbl -0x7feea0fb(,%eax,8),%edx
80107570:	80 
80107571:	83 e2 f0             	and    $0xfffffff0,%edx
80107574:	83 ca 0e             	or     $0xe,%edx
80107577:	88 14 c5 05 5f 11 80 	mov    %dl,-0x7feea0fb(,%eax,8)
8010757e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107581:	0f b6 14 c5 05 5f 11 	movzbl -0x7feea0fb(,%eax,8),%edx
80107588:	80 
80107589:	83 e2 ef             	and    $0xffffffef,%edx
8010758c:	88 14 c5 05 5f 11 80 	mov    %dl,-0x7feea0fb(,%eax,8)
80107593:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107596:	0f b6 14 c5 05 5f 11 	movzbl -0x7feea0fb(,%eax,8),%edx
8010759d:	80 
8010759e:	83 e2 9f             	and    $0xffffff9f,%edx
801075a1:	88 14 c5 05 5f 11 80 	mov    %dl,-0x7feea0fb(,%eax,8)
801075a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801075ab:	0f b6 14 c5 05 5f 11 	movzbl -0x7feea0fb(,%eax,8),%edx
801075b2:	80 
801075b3:	83 ca 80             	or     $0xffffff80,%edx
801075b6:	88 14 c5 05 5f 11 80 	mov    %dl,-0x7feea0fb(,%eax,8)
801075bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801075c0:	8b 04 85 b4 c0 10 80 	mov    -0x7fef3f4c(,%eax,4),%eax
801075c7:	c1 e8 10             	shr    $0x10,%eax
801075ca:	89 c2                	mov    %eax,%edx
801075cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801075cf:	66 89 14 c5 06 5f 11 	mov    %dx,-0x7feea0fa(,%eax,8)
801075d6:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801075d7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801075db:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
801075e2:	0f 8e 30 ff ff ff    	jle    80107518 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801075e8:	a1 b4 c1 10 80       	mov    0x8010c1b4,%eax
801075ed:	66 a3 00 61 11 80    	mov    %ax,0x80116100
801075f3:	66 c7 05 02 61 11 80 	movw   $0x8,0x80116102
801075fa:	08 00 
801075fc:	0f b6 05 04 61 11 80 	movzbl 0x80116104,%eax
80107603:	83 e0 e0             	and    $0xffffffe0,%eax
80107606:	a2 04 61 11 80       	mov    %al,0x80116104
8010760b:	0f b6 05 04 61 11 80 	movzbl 0x80116104,%eax
80107612:	83 e0 1f             	and    $0x1f,%eax
80107615:	a2 04 61 11 80       	mov    %al,0x80116104
8010761a:	0f b6 05 05 61 11 80 	movzbl 0x80116105,%eax
80107621:	83 c8 0f             	or     $0xf,%eax
80107624:	a2 05 61 11 80       	mov    %al,0x80116105
80107629:	0f b6 05 05 61 11 80 	movzbl 0x80116105,%eax
80107630:	83 e0 ef             	and    $0xffffffef,%eax
80107633:	a2 05 61 11 80       	mov    %al,0x80116105
80107638:	0f b6 05 05 61 11 80 	movzbl 0x80116105,%eax
8010763f:	83 c8 60             	or     $0x60,%eax
80107642:	a2 05 61 11 80       	mov    %al,0x80116105
80107647:	0f b6 05 05 61 11 80 	movzbl 0x80116105,%eax
8010764e:	83 c8 80             	or     $0xffffff80,%eax
80107651:	a2 05 61 11 80       	mov    %al,0x80116105
80107656:	a1 b4 c1 10 80       	mov    0x8010c1b4,%eax
8010765b:	c1 e8 10             	shr    $0x10,%eax
8010765e:	66 a3 06 61 11 80    	mov    %ax,0x80116106
  
}
80107664:	90                   	nop
80107665:	c9                   	leave  
80107666:	c3                   	ret    

80107667 <idtinit>:

void
idtinit(void)
{
80107667:	55                   	push   %ebp
80107668:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
8010766a:	68 00 08 00 00       	push   $0x800
8010766f:	68 00 5f 11 80       	push   $0x80115f00
80107674:	e8 52 fe ff ff       	call   801074cb <lidt>
80107679:	83 c4 08             	add    $0x8,%esp
}
8010767c:	90                   	nop
8010767d:	c9                   	leave  
8010767e:	c3                   	ret    

8010767f <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010767f:	55                   	push   %ebp
80107680:	89 e5                	mov    %esp,%ebp
80107682:	57                   	push   %edi
80107683:	56                   	push   %esi
80107684:	53                   	push   %ebx
80107685:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80107688:	8b 45 08             	mov    0x8(%ebp),%eax
8010768b:	8b 40 30             	mov    0x30(%eax),%eax
8010768e:	83 f8 40             	cmp    $0x40,%eax
80107691:	75 3e                	jne    801076d1 <trap+0x52>
    if(proc->killed)
80107693:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107699:	8b 40 24             	mov    0x24(%eax),%eax
8010769c:	85 c0                	test   %eax,%eax
8010769e:	74 05                	je     801076a5 <trap+0x26>
      exit();
801076a0:	e8 7a d4 ff ff       	call   80104b1f <exit>
    proc->tf = tf;
801076a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801076ab:	8b 55 08             	mov    0x8(%ebp),%edx
801076ae:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801076b1:	e8 ab ec ff ff       	call   80106361 <syscall>
    if(proc->killed)
801076b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801076bc:	8b 40 24             	mov    0x24(%eax),%eax
801076bf:	85 c0                	test   %eax,%eax
801076c1:	0f 84 21 02 00 00    	je     801078e8 <trap+0x269>
      exit();
801076c7:	e8 53 d4 ff ff       	call   80104b1f <exit>
    return;
801076cc:	e9 17 02 00 00       	jmp    801078e8 <trap+0x269>
  }

  switch(tf->trapno){
801076d1:	8b 45 08             	mov    0x8(%ebp),%eax
801076d4:	8b 40 30             	mov    0x30(%eax),%eax
801076d7:	83 e8 20             	sub    $0x20,%eax
801076da:	83 f8 1f             	cmp    $0x1f,%eax
801076dd:	0f 87 a3 00 00 00    	ja     80107786 <trap+0x107>
801076e3:	8b 04 85 10 9a 10 80 	mov    -0x7fef65f0(,%eax,4),%eax
801076ea:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
   if(cpu->id == 0){
801076ec:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801076f2:	0f b6 00             	movzbl (%eax),%eax
801076f5:	84 c0                	test   %al,%al
801076f7:	75 20                	jne    80107719 <trap+0x9a>
      atom_inc((int *)&ticks);   // guaranteed atomic so no lock necessary
801076f9:	83 ec 0c             	sub    $0xc,%esp
801076fc:	68 00 67 11 80       	push   $0x80116700
80107701:	e8 b9 fd ff ff       	call   801074bf <atom_inc>
80107706:	83 c4 10             	add    $0x10,%esp
      wakeup(&ticks);
80107709:	83 ec 0c             	sub    $0xc,%esp
8010770c:	68 00 67 11 80       	push   $0x80116700
80107711:	e8 3a dc ff ff       	call   80105350 <wakeup>
80107716:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80107719:	e8 a5 b9 ff ff       	call   801030c3 <lapiceoi>
    break;
8010771e:	e9 1c 01 00 00       	jmp    8010783f <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80107723:	e8 ae b1 ff ff       	call   801028d6 <ideintr>
    lapiceoi();
80107728:	e8 96 b9 ff ff       	call   801030c3 <lapiceoi>
    break;
8010772d:	e9 0d 01 00 00       	jmp    8010783f <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80107732:	e8 8e b7 ff ff       	call   80102ec5 <kbdintr>
    lapiceoi();
80107737:	e8 87 b9 ff ff       	call   801030c3 <lapiceoi>
    break;
8010773c:	e9 fe 00 00 00       	jmp    8010783f <trap+0x1c0>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80107741:	e8 83 03 00 00       	call   80107ac9 <uartintr>
    lapiceoi();
80107746:	e8 78 b9 ff ff       	call   801030c3 <lapiceoi>
    break;
8010774b:	e9 ef 00 00 00       	jmp    8010783f <trap+0x1c0>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107750:	8b 45 08             	mov    0x8(%ebp),%eax
80107753:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80107756:	8b 45 08             	mov    0x8(%ebp),%eax
80107759:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010775d:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80107760:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107766:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107769:	0f b6 c0             	movzbl %al,%eax
8010776c:	51                   	push   %ecx
8010776d:	52                   	push   %edx
8010776e:	50                   	push   %eax
8010776f:	68 70 99 10 80       	push   $0x80109970
80107774:	e8 4d 8c ff ff       	call   801003c6 <cprintf>
80107779:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
8010777c:	e8 42 b9 ff ff       	call   801030c3 <lapiceoi>
    break;
80107781:	e9 b9 00 00 00       	jmp    8010783f <trap+0x1c0>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80107786:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010778c:	85 c0                	test   %eax,%eax
8010778e:	74 11                	je     801077a1 <trap+0x122>
80107790:	8b 45 08             	mov    0x8(%ebp),%eax
80107793:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107797:	0f b7 c0             	movzwl %ax,%eax
8010779a:	83 e0 03             	and    $0x3,%eax
8010779d:	85 c0                	test   %eax,%eax
8010779f:	75 40                	jne    801077e1 <trap+0x162>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801077a1:	e8 4f fd ff ff       	call   801074f5 <rcr2>
801077a6:	89 c3                	mov    %eax,%ebx
801077a8:	8b 45 08             	mov    0x8(%ebp),%eax
801077ab:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
801077ae:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801077b4:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801077b7:	0f b6 d0             	movzbl %al,%edx
801077ba:	8b 45 08             	mov    0x8(%ebp),%eax
801077bd:	8b 40 30             	mov    0x30(%eax),%eax
801077c0:	83 ec 0c             	sub    $0xc,%esp
801077c3:	53                   	push   %ebx
801077c4:	51                   	push   %ecx
801077c5:	52                   	push   %edx
801077c6:	50                   	push   %eax
801077c7:	68 94 99 10 80       	push   $0x80109994
801077cc:	e8 f5 8b ff ff       	call   801003c6 <cprintf>
801077d1:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
801077d4:	83 ec 0c             	sub    $0xc,%esp
801077d7:	68 c6 99 10 80       	push   $0x801099c6
801077dc:	e8 85 8d ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801077e1:	e8 0f fd ff ff       	call   801074f5 <rcr2>
801077e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801077e9:	8b 45 08             	mov    0x8(%ebp),%eax
801077ec:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801077ef:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801077f5:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801077f8:	0f b6 d8             	movzbl %al,%ebx
801077fb:	8b 45 08             	mov    0x8(%ebp),%eax
801077fe:	8b 48 34             	mov    0x34(%eax),%ecx
80107801:	8b 45 08             	mov    0x8(%ebp),%eax
80107804:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107807:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010780d:	8d 78 6c             	lea    0x6c(%eax),%edi
80107810:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107816:	8b 40 10             	mov    0x10(%eax),%eax
80107819:	ff 75 e4             	pushl  -0x1c(%ebp)
8010781c:	56                   	push   %esi
8010781d:	53                   	push   %ebx
8010781e:	51                   	push   %ecx
8010781f:	52                   	push   %edx
80107820:	57                   	push   %edi
80107821:	50                   	push   %eax
80107822:	68 cc 99 10 80       	push   $0x801099cc
80107827:	e8 9a 8b ff ff       	call   801003c6 <cprintf>
8010782c:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
8010782f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107835:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010783c:	eb 01                	jmp    8010783f <trap+0x1c0>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
8010783e:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010783f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107845:	85 c0                	test   %eax,%eax
80107847:	74 24                	je     8010786d <trap+0x1ee>
80107849:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010784f:	8b 40 24             	mov    0x24(%eax),%eax
80107852:	85 c0                	test   %eax,%eax
80107854:	74 17                	je     8010786d <trap+0x1ee>
80107856:	8b 45 08             	mov    0x8(%ebp),%eax
80107859:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010785d:	0f b7 c0             	movzwl %ax,%eax
80107860:	83 e0 03             	and    $0x3,%eax
80107863:	83 f8 03             	cmp    $0x3,%eax
80107866:	75 05                	jne    8010786d <trap+0x1ee>
    exit();
80107868:	e8 b2 d2 ff ff       	call   80104b1f <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
8010786d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107873:	85 c0                	test   %eax,%eax
80107875:	74 41                	je     801078b8 <trap+0x239>
80107877:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010787d:	8b 40 0c             	mov    0xc(%eax),%eax
80107880:	83 f8 04             	cmp    $0x4,%eax
80107883:	75 33                	jne    801078b8 <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
80107885:	8b 45 08             	mov    0x8(%ebp),%eax
80107888:	8b 40 30             	mov    0x30(%eax),%eax
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
8010788b:	83 f8 20             	cmp    $0x20,%eax
8010788e:	75 28                	jne    801078b8 <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
80107890:	8b 0d 00 67 11 80    	mov    0x80116700,%ecx
80107896:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
8010789b:	89 c8                	mov    %ecx,%eax
8010789d:	f7 e2                	mul    %edx
8010789f:	c1 ea 03             	shr    $0x3,%edx
801078a2:	89 d0                	mov    %edx,%eax
801078a4:	c1 e0 02             	shl    $0x2,%eax
801078a7:	01 d0                	add    %edx,%eax
801078a9:	01 c0                	add    %eax,%eax
801078ab:	29 c1                	sub    %eax,%ecx
801078ad:	89 ca                	mov    %ecx,%edx
801078af:	85 d2                	test   %edx,%edx
801078b1:	75 05                	jne    801078b8 <trap+0x239>
    yield();
801078b3:	e8 98 d8 ff ff       	call   80105150 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801078b8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801078be:	85 c0                	test   %eax,%eax
801078c0:	74 27                	je     801078e9 <trap+0x26a>
801078c2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801078c8:	8b 40 24             	mov    0x24(%eax),%eax
801078cb:	85 c0                	test   %eax,%eax
801078cd:	74 1a                	je     801078e9 <trap+0x26a>
801078cf:	8b 45 08             	mov    0x8(%ebp),%eax
801078d2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801078d6:	0f b7 c0             	movzwl %ax,%eax
801078d9:	83 e0 03             	and    $0x3,%eax
801078dc:	83 f8 03             	cmp    $0x3,%eax
801078df:	75 08                	jne    801078e9 <trap+0x26a>
    exit();
801078e1:	e8 39 d2 ff ff       	call   80104b1f <exit>
801078e6:	eb 01                	jmp    801078e9 <trap+0x26a>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
801078e8:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
801078e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801078ec:	5b                   	pop    %ebx
801078ed:	5e                   	pop    %esi
801078ee:	5f                   	pop    %edi
801078ef:	5d                   	pop    %ebp
801078f0:	c3                   	ret    

801078f1 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
801078f1:	55                   	push   %ebp
801078f2:	89 e5                	mov    %esp,%ebp
801078f4:	83 ec 14             	sub    $0x14,%esp
801078f7:	8b 45 08             	mov    0x8(%ebp),%eax
801078fa:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801078fe:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107902:	89 c2                	mov    %eax,%edx
80107904:	ec                   	in     (%dx),%al
80107905:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107908:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010790c:	c9                   	leave  
8010790d:	c3                   	ret    

8010790e <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010790e:	55                   	push   %ebp
8010790f:	89 e5                	mov    %esp,%ebp
80107911:	83 ec 08             	sub    $0x8,%esp
80107914:	8b 55 08             	mov    0x8(%ebp),%edx
80107917:	8b 45 0c             	mov    0xc(%ebp),%eax
8010791a:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010791e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107921:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107925:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107929:	ee                   	out    %al,(%dx)
}
8010792a:	90                   	nop
8010792b:	c9                   	leave  
8010792c:	c3                   	ret    

8010792d <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010792d:	55                   	push   %ebp
8010792e:	89 e5                	mov    %esp,%ebp
80107930:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107933:	6a 00                	push   $0x0
80107935:	68 fa 03 00 00       	push   $0x3fa
8010793a:	e8 cf ff ff ff       	call   8010790e <outb>
8010793f:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107942:	68 80 00 00 00       	push   $0x80
80107947:	68 fb 03 00 00       	push   $0x3fb
8010794c:	e8 bd ff ff ff       	call   8010790e <outb>
80107951:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107954:	6a 0c                	push   $0xc
80107956:	68 f8 03 00 00       	push   $0x3f8
8010795b:	e8 ae ff ff ff       	call   8010790e <outb>
80107960:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107963:	6a 00                	push   $0x0
80107965:	68 f9 03 00 00       	push   $0x3f9
8010796a:	e8 9f ff ff ff       	call   8010790e <outb>
8010796f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107972:	6a 03                	push   $0x3
80107974:	68 fb 03 00 00       	push   $0x3fb
80107979:	e8 90 ff ff ff       	call   8010790e <outb>
8010797e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107981:	6a 00                	push   $0x0
80107983:	68 fc 03 00 00       	push   $0x3fc
80107988:	e8 81 ff ff ff       	call   8010790e <outb>
8010798d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107990:	6a 01                	push   $0x1
80107992:	68 f9 03 00 00       	push   $0x3f9
80107997:	e8 72 ff ff ff       	call   8010790e <outb>
8010799c:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
8010799f:	68 fd 03 00 00       	push   $0x3fd
801079a4:	e8 48 ff ff ff       	call   801078f1 <inb>
801079a9:	83 c4 04             	add    $0x4,%esp
801079ac:	3c ff                	cmp    $0xff,%al
801079ae:	74 6e                	je     80107a1e <uartinit+0xf1>
    return;
  uart = 1;
801079b0:	c7 05 6c c6 10 80 01 	movl   $0x1,0x8010c66c
801079b7:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801079ba:	68 fa 03 00 00       	push   $0x3fa
801079bf:	e8 2d ff ff ff       	call   801078f1 <inb>
801079c4:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801079c7:	68 f8 03 00 00       	push   $0x3f8
801079cc:	e8 20 ff ff ff       	call   801078f1 <inb>
801079d1:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
801079d4:	83 ec 0c             	sub    $0xc,%esp
801079d7:	6a 04                	push   $0x4
801079d9:	e8 eb c5 ff ff       	call   80103fc9 <picenable>
801079de:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
801079e1:	83 ec 08             	sub    $0x8,%esp
801079e4:	6a 00                	push   $0x0
801079e6:	6a 04                	push   $0x4
801079e8:	e8 8b b1 ff ff       	call   80102b78 <ioapicenable>
801079ed:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801079f0:	c7 45 f4 90 9a 10 80 	movl   $0x80109a90,-0xc(%ebp)
801079f7:	eb 19                	jmp    80107a12 <uartinit+0xe5>
    uartputc(*p);
801079f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079fc:	0f b6 00             	movzbl (%eax),%eax
801079ff:	0f be c0             	movsbl %al,%eax
80107a02:	83 ec 0c             	sub    $0xc,%esp
80107a05:	50                   	push   %eax
80107a06:	e8 16 00 00 00       	call   80107a21 <uartputc>
80107a0b:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107a0e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a15:	0f b6 00             	movzbl (%eax),%eax
80107a18:	84 c0                	test   %al,%al
80107a1a:	75 dd                	jne    801079f9 <uartinit+0xcc>
80107a1c:	eb 01                	jmp    80107a1f <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80107a1e:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80107a1f:	c9                   	leave  
80107a20:	c3                   	ret    

80107a21 <uartputc>:

void
uartputc(int c)
{
80107a21:	55                   	push   %ebp
80107a22:	89 e5                	mov    %esp,%ebp
80107a24:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80107a27:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
80107a2c:	85 c0                	test   %eax,%eax
80107a2e:	74 53                	je     80107a83 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107a30:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107a37:	eb 11                	jmp    80107a4a <uartputc+0x29>
    microdelay(10);
80107a39:	83 ec 0c             	sub    $0xc,%esp
80107a3c:	6a 0a                	push   $0xa
80107a3e:	e8 9b b6 ff ff       	call   801030de <microdelay>
80107a43:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107a46:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107a4a:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107a4e:	7f 1a                	jg     80107a6a <uartputc+0x49>
80107a50:	83 ec 0c             	sub    $0xc,%esp
80107a53:	68 fd 03 00 00       	push   $0x3fd
80107a58:	e8 94 fe ff ff       	call   801078f1 <inb>
80107a5d:	83 c4 10             	add    $0x10,%esp
80107a60:	0f b6 c0             	movzbl %al,%eax
80107a63:	83 e0 20             	and    $0x20,%eax
80107a66:	85 c0                	test   %eax,%eax
80107a68:	74 cf                	je     80107a39 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80107a6a:	8b 45 08             	mov    0x8(%ebp),%eax
80107a6d:	0f b6 c0             	movzbl %al,%eax
80107a70:	83 ec 08             	sub    $0x8,%esp
80107a73:	50                   	push   %eax
80107a74:	68 f8 03 00 00       	push   $0x3f8
80107a79:	e8 90 fe ff ff       	call   8010790e <outb>
80107a7e:	83 c4 10             	add    $0x10,%esp
80107a81:	eb 01                	jmp    80107a84 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80107a83:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80107a84:	c9                   	leave  
80107a85:	c3                   	ret    

80107a86 <uartgetc>:

static int
uartgetc(void)
{
80107a86:	55                   	push   %ebp
80107a87:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107a89:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
80107a8e:	85 c0                	test   %eax,%eax
80107a90:	75 07                	jne    80107a99 <uartgetc+0x13>
    return -1;
80107a92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a97:	eb 2e                	jmp    80107ac7 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80107a99:	68 fd 03 00 00       	push   $0x3fd
80107a9e:	e8 4e fe ff ff       	call   801078f1 <inb>
80107aa3:	83 c4 04             	add    $0x4,%esp
80107aa6:	0f b6 c0             	movzbl %al,%eax
80107aa9:	83 e0 01             	and    $0x1,%eax
80107aac:	85 c0                	test   %eax,%eax
80107aae:	75 07                	jne    80107ab7 <uartgetc+0x31>
    return -1;
80107ab0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ab5:	eb 10                	jmp    80107ac7 <uartgetc+0x41>
  return inb(COM1+0);
80107ab7:	68 f8 03 00 00       	push   $0x3f8
80107abc:	e8 30 fe ff ff       	call   801078f1 <inb>
80107ac1:	83 c4 04             	add    $0x4,%esp
80107ac4:	0f b6 c0             	movzbl %al,%eax
}
80107ac7:	c9                   	leave  
80107ac8:	c3                   	ret    

80107ac9 <uartintr>:

void
uartintr(void)
{
80107ac9:	55                   	push   %ebp
80107aca:	89 e5                	mov    %esp,%ebp
80107acc:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107acf:	83 ec 0c             	sub    $0xc,%esp
80107ad2:	68 86 7a 10 80       	push   $0x80107a86
80107ad7:	e8 1d 8d ff ff       	call   801007f9 <consoleintr>
80107adc:	83 c4 10             	add    $0x10,%esp
}
80107adf:	90                   	nop
80107ae0:	c9                   	leave  
80107ae1:	c3                   	ret    

80107ae2 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107ae2:	6a 00                	push   $0x0
  pushl $0
80107ae4:	6a 00                	push   $0x0
  jmp alltraps
80107ae6:	e9 a9 f9 ff ff       	jmp    80107494 <alltraps>

80107aeb <vector1>:
.globl vector1
vector1:
  pushl $0
80107aeb:	6a 00                	push   $0x0
  pushl $1
80107aed:	6a 01                	push   $0x1
  jmp alltraps
80107aef:	e9 a0 f9 ff ff       	jmp    80107494 <alltraps>

80107af4 <vector2>:
.globl vector2
vector2:
  pushl $0
80107af4:	6a 00                	push   $0x0
  pushl $2
80107af6:	6a 02                	push   $0x2
  jmp alltraps
80107af8:	e9 97 f9 ff ff       	jmp    80107494 <alltraps>

80107afd <vector3>:
.globl vector3
vector3:
  pushl $0
80107afd:	6a 00                	push   $0x0
  pushl $3
80107aff:	6a 03                	push   $0x3
  jmp alltraps
80107b01:	e9 8e f9 ff ff       	jmp    80107494 <alltraps>

80107b06 <vector4>:
.globl vector4
vector4:
  pushl $0
80107b06:	6a 00                	push   $0x0
  pushl $4
80107b08:	6a 04                	push   $0x4
  jmp alltraps
80107b0a:	e9 85 f9 ff ff       	jmp    80107494 <alltraps>

80107b0f <vector5>:
.globl vector5
vector5:
  pushl $0
80107b0f:	6a 00                	push   $0x0
  pushl $5
80107b11:	6a 05                	push   $0x5
  jmp alltraps
80107b13:	e9 7c f9 ff ff       	jmp    80107494 <alltraps>

80107b18 <vector6>:
.globl vector6
vector6:
  pushl $0
80107b18:	6a 00                	push   $0x0
  pushl $6
80107b1a:	6a 06                	push   $0x6
  jmp alltraps
80107b1c:	e9 73 f9 ff ff       	jmp    80107494 <alltraps>

80107b21 <vector7>:
.globl vector7
vector7:
  pushl $0
80107b21:	6a 00                	push   $0x0
  pushl $7
80107b23:	6a 07                	push   $0x7
  jmp alltraps
80107b25:	e9 6a f9 ff ff       	jmp    80107494 <alltraps>

80107b2a <vector8>:
.globl vector8
vector8:
  pushl $8
80107b2a:	6a 08                	push   $0x8
  jmp alltraps
80107b2c:	e9 63 f9 ff ff       	jmp    80107494 <alltraps>

80107b31 <vector9>:
.globl vector9
vector9:
  pushl $0
80107b31:	6a 00                	push   $0x0
  pushl $9
80107b33:	6a 09                	push   $0x9
  jmp alltraps
80107b35:	e9 5a f9 ff ff       	jmp    80107494 <alltraps>

80107b3a <vector10>:
.globl vector10
vector10:
  pushl $10
80107b3a:	6a 0a                	push   $0xa
  jmp alltraps
80107b3c:	e9 53 f9 ff ff       	jmp    80107494 <alltraps>

80107b41 <vector11>:
.globl vector11
vector11:
  pushl $11
80107b41:	6a 0b                	push   $0xb
  jmp alltraps
80107b43:	e9 4c f9 ff ff       	jmp    80107494 <alltraps>

80107b48 <vector12>:
.globl vector12
vector12:
  pushl $12
80107b48:	6a 0c                	push   $0xc
  jmp alltraps
80107b4a:	e9 45 f9 ff ff       	jmp    80107494 <alltraps>

80107b4f <vector13>:
.globl vector13
vector13:
  pushl $13
80107b4f:	6a 0d                	push   $0xd
  jmp alltraps
80107b51:	e9 3e f9 ff ff       	jmp    80107494 <alltraps>

80107b56 <vector14>:
.globl vector14
vector14:
  pushl $14
80107b56:	6a 0e                	push   $0xe
  jmp alltraps
80107b58:	e9 37 f9 ff ff       	jmp    80107494 <alltraps>

80107b5d <vector15>:
.globl vector15
vector15:
  pushl $0
80107b5d:	6a 00                	push   $0x0
  pushl $15
80107b5f:	6a 0f                	push   $0xf
  jmp alltraps
80107b61:	e9 2e f9 ff ff       	jmp    80107494 <alltraps>

80107b66 <vector16>:
.globl vector16
vector16:
  pushl $0
80107b66:	6a 00                	push   $0x0
  pushl $16
80107b68:	6a 10                	push   $0x10
  jmp alltraps
80107b6a:	e9 25 f9 ff ff       	jmp    80107494 <alltraps>

80107b6f <vector17>:
.globl vector17
vector17:
  pushl $17
80107b6f:	6a 11                	push   $0x11
  jmp alltraps
80107b71:	e9 1e f9 ff ff       	jmp    80107494 <alltraps>

80107b76 <vector18>:
.globl vector18
vector18:
  pushl $0
80107b76:	6a 00                	push   $0x0
  pushl $18
80107b78:	6a 12                	push   $0x12
  jmp alltraps
80107b7a:	e9 15 f9 ff ff       	jmp    80107494 <alltraps>

80107b7f <vector19>:
.globl vector19
vector19:
  pushl $0
80107b7f:	6a 00                	push   $0x0
  pushl $19
80107b81:	6a 13                	push   $0x13
  jmp alltraps
80107b83:	e9 0c f9 ff ff       	jmp    80107494 <alltraps>

80107b88 <vector20>:
.globl vector20
vector20:
  pushl $0
80107b88:	6a 00                	push   $0x0
  pushl $20
80107b8a:	6a 14                	push   $0x14
  jmp alltraps
80107b8c:	e9 03 f9 ff ff       	jmp    80107494 <alltraps>

80107b91 <vector21>:
.globl vector21
vector21:
  pushl $0
80107b91:	6a 00                	push   $0x0
  pushl $21
80107b93:	6a 15                	push   $0x15
  jmp alltraps
80107b95:	e9 fa f8 ff ff       	jmp    80107494 <alltraps>

80107b9a <vector22>:
.globl vector22
vector22:
  pushl $0
80107b9a:	6a 00                	push   $0x0
  pushl $22
80107b9c:	6a 16                	push   $0x16
  jmp alltraps
80107b9e:	e9 f1 f8 ff ff       	jmp    80107494 <alltraps>

80107ba3 <vector23>:
.globl vector23
vector23:
  pushl $0
80107ba3:	6a 00                	push   $0x0
  pushl $23
80107ba5:	6a 17                	push   $0x17
  jmp alltraps
80107ba7:	e9 e8 f8 ff ff       	jmp    80107494 <alltraps>

80107bac <vector24>:
.globl vector24
vector24:
  pushl $0
80107bac:	6a 00                	push   $0x0
  pushl $24
80107bae:	6a 18                	push   $0x18
  jmp alltraps
80107bb0:	e9 df f8 ff ff       	jmp    80107494 <alltraps>

80107bb5 <vector25>:
.globl vector25
vector25:
  pushl $0
80107bb5:	6a 00                	push   $0x0
  pushl $25
80107bb7:	6a 19                	push   $0x19
  jmp alltraps
80107bb9:	e9 d6 f8 ff ff       	jmp    80107494 <alltraps>

80107bbe <vector26>:
.globl vector26
vector26:
  pushl $0
80107bbe:	6a 00                	push   $0x0
  pushl $26
80107bc0:	6a 1a                	push   $0x1a
  jmp alltraps
80107bc2:	e9 cd f8 ff ff       	jmp    80107494 <alltraps>

80107bc7 <vector27>:
.globl vector27
vector27:
  pushl $0
80107bc7:	6a 00                	push   $0x0
  pushl $27
80107bc9:	6a 1b                	push   $0x1b
  jmp alltraps
80107bcb:	e9 c4 f8 ff ff       	jmp    80107494 <alltraps>

80107bd0 <vector28>:
.globl vector28
vector28:
  pushl $0
80107bd0:	6a 00                	push   $0x0
  pushl $28
80107bd2:	6a 1c                	push   $0x1c
  jmp alltraps
80107bd4:	e9 bb f8 ff ff       	jmp    80107494 <alltraps>

80107bd9 <vector29>:
.globl vector29
vector29:
  pushl $0
80107bd9:	6a 00                	push   $0x0
  pushl $29
80107bdb:	6a 1d                	push   $0x1d
  jmp alltraps
80107bdd:	e9 b2 f8 ff ff       	jmp    80107494 <alltraps>

80107be2 <vector30>:
.globl vector30
vector30:
  pushl $0
80107be2:	6a 00                	push   $0x0
  pushl $30
80107be4:	6a 1e                	push   $0x1e
  jmp alltraps
80107be6:	e9 a9 f8 ff ff       	jmp    80107494 <alltraps>

80107beb <vector31>:
.globl vector31
vector31:
  pushl $0
80107beb:	6a 00                	push   $0x0
  pushl $31
80107bed:	6a 1f                	push   $0x1f
  jmp alltraps
80107bef:	e9 a0 f8 ff ff       	jmp    80107494 <alltraps>

80107bf4 <vector32>:
.globl vector32
vector32:
  pushl $0
80107bf4:	6a 00                	push   $0x0
  pushl $32
80107bf6:	6a 20                	push   $0x20
  jmp alltraps
80107bf8:	e9 97 f8 ff ff       	jmp    80107494 <alltraps>

80107bfd <vector33>:
.globl vector33
vector33:
  pushl $0
80107bfd:	6a 00                	push   $0x0
  pushl $33
80107bff:	6a 21                	push   $0x21
  jmp alltraps
80107c01:	e9 8e f8 ff ff       	jmp    80107494 <alltraps>

80107c06 <vector34>:
.globl vector34
vector34:
  pushl $0
80107c06:	6a 00                	push   $0x0
  pushl $34
80107c08:	6a 22                	push   $0x22
  jmp alltraps
80107c0a:	e9 85 f8 ff ff       	jmp    80107494 <alltraps>

80107c0f <vector35>:
.globl vector35
vector35:
  pushl $0
80107c0f:	6a 00                	push   $0x0
  pushl $35
80107c11:	6a 23                	push   $0x23
  jmp alltraps
80107c13:	e9 7c f8 ff ff       	jmp    80107494 <alltraps>

80107c18 <vector36>:
.globl vector36
vector36:
  pushl $0
80107c18:	6a 00                	push   $0x0
  pushl $36
80107c1a:	6a 24                	push   $0x24
  jmp alltraps
80107c1c:	e9 73 f8 ff ff       	jmp    80107494 <alltraps>

80107c21 <vector37>:
.globl vector37
vector37:
  pushl $0
80107c21:	6a 00                	push   $0x0
  pushl $37
80107c23:	6a 25                	push   $0x25
  jmp alltraps
80107c25:	e9 6a f8 ff ff       	jmp    80107494 <alltraps>

80107c2a <vector38>:
.globl vector38
vector38:
  pushl $0
80107c2a:	6a 00                	push   $0x0
  pushl $38
80107c2c:	6a 26                	push   $0x26
  jmp alltraps
80107c2e:	e9 61 f8 ff ff       	jmp    80107494 <alltraps>

80107c33 <vector39>:
.globl vector39
vector39:
  pushl $0
80107c33:	6a 00                	push   $0x0
  pushl $39
80107c35:	6a 27                	push   $0x27
  jmp alltraps
80107c37:	e9 58 f8 ff ff       	jmp    80107494 <alltraps>

80107c3c <vector40>:
.globl vector40
vector40:
  pushl $0
80107c3c:	6a 00                	push   $0x0
  pushl $40
80107c3e:	6a 28                	push   $0x28
  jmp alltraps
80107c40:	e9 4f f8 ff ff       	jmp    80107494 <alltraps>

80107c45 <vector41>:
.globl vector41
vector41:
  pushl $0
80107c45:	6a 00                	push   $0x0
  pushl $41
80107c47:	6a 29                	push   $0x29
  jmp alltraps
80107c49:	e9 46 f8 ff ff       	jmp    80107494 <alltraps>

80107c4e <vector42>:
.globl vector42
vector42:
  pushl $0
80107c4e:	6a 00                	push   $0x0
  pushl $42
80107c50:	6a 2a                	push   $0x2a
  jmp alltraps
80107c52:	e9 3d f8 ff ff       	jmp    80107494 <alltraps>

80107c57 <vector43>:
.globl vector43
vector43:
  pushl $0
80107c57:	6a 00                	push   $0x0
  pushl $43
80107c59:	6a 2b                	push   $0x2b
  jmp alltraps
80107c5b:	e9 34 f8 ff ff       	jmp    80107494 <alltraps>

80107c60 <vector44>:
.globl vector44
vector44:
  pushl $0
80107c60:	6a 00                	push   $0x0
  pushl $44
80107c62:	6a 2c                	push   $0x2c
  jmp alltraps
80107c64:	e9 2b f8 ff ff       	jmp    80107494 <alltraps>

80107c69 <vector45>:
.globl vector45
vector45:
  pushl $0
80107c69:	6a 00                	push   $0x0
  pushl $45
80107c6b:	6a 2d                	push   $0x2d
  jmp alltraps
80107c6d:	e9 22 f8 ff ff       	jmp    80107494 <alltraps>

80107c72 <vector46>:
.globl vector46
vector46:
  pushl $0
80107c72:	6a 00                	push   $0x0
  pushl $46
80107c74:	6a 2e                	push   $0x2e
  jmp alltraps
80107c76:	e9 19 f8 ff ff       	jmp    80107494 <alltraps>

80107c7b <vector47>:
.globl vector47
vector47:
  pushl $0
80107c7b:	6a 00                	push   $0x0
  pushl $47
80107c7d:	6a 2f                	push   $0x2f
  jmp alltraps
80107c7f:	e9 10 f8 ff ff       	jmp    80107494 <alltraps>

80107c84 <vector48>:
.globl vector48
vector48:
  pushl $0
80107c84:	6a 00                	push   $0x0
  pushl $48
80107c86:	6a 30                	push   $0x30
  jmp alltraps
80107c88:	e9 07 f8 ff ff       	jmp    80107494 <alltraps>

80107c8d <vector49>:
.globl vector49
vector49:
  pushl $0
80107c8d:	6a 00                	push   $0x0
  pushl $49
80107c8f:	6a 31                	push   $0x31
  jmp alltraps
80107c91:	e9 fe f7 ff ff       	jmp    80107494 <alltraps>

80107c96 <vector50>:
.globl vector50
vector50:
  pushl $0
80107c96:	6a 00                	push   $0x0
  pushl $50
80107c98:	6a 32                	push   $0x32
  jmp alltraps
80107c9a:	e9 f5 f7 ff ff       	jmp    80107494 <alltraps>

80107c9f <vector51>:
.globl vector51
vector51:
  pushl $0
80107c9f:	6a 00                	push   $0x0
  pushl $51
80107ca1:	6a 33                	push   $0x33
  jmp alltraps
80107ca3:	e9 ec f7 ff ff       	jmp    80107494 <alltraps>

80107ca8 <vector52>:
.globl vector52
vector52:
  pushl $0
80107ca8:	6a 00                	push   $0x0
  pushl $52
80107caa:	6a 34                	push   $0x34
  jmp alltraps
80107cac:	e9 e3 f7 ff ff       	jmp    80107494 <alltraps>

80107cb1 <vector53>:
.globl vector53
vector53:
  pushl $0
80107cb1:	6a 00                	push   $0x0
  pushl $53
80107cb3:	6a 35                	push   $0x35
  jmp alltraps
80107cb5:	e9 da f7 ff ff       	jmp    80107494 <alltraps>

80107cba <vector54>:
.globl vector54
vector54:
  pushl $0
80107cba:	6a 00                	push   $0x0
  pushl $54
80107cbc:	6a 36                	push   $0x36
  jmp alltraps
80107cbe:	e9 d1 f7 ff ff       	jmp    80107494 <alltraps>

80107cc3 <vector55>:
.globl vector55
vector55:
  pushl $0
80107cc3:	6a 00                	push   $0x0
  pushl $55
80107cc5:	6a 37                	push   $0x37
  jmp alltraps
80107cc7:	e9 c8 f7 ff ff       	jmp    80107494 <alltraps>

80107ccc <vector56>:
.globl vector56
vector56:
  pushl $0
80107ccc:	6a 00                	push   $0x0
  pushl $56
80107cce:	6a 38                	push   $0x38
  jmp alltraps
80107cd0:	e9 bf f7 ff ff       	jmp    80107494 <alltraps>

80107cd5 <vector57>:
.globl vector57
vector57:
  pushl $0
80107cd5:	6a 00                	push   $0x0
  pushl $57
80107cd7:	6a 39                	push   $0x39
  jmp alltraps
80107cd9:	e9 b6 f7 ff ff       	jmp    80107494 <alltraps>

80107cde <vector58>:
.globl vector58
vector58:
  pushl $0
80107cde:	6a 00                	push   $0x0
  pushl $58
80107ce0:	6a 3a                	push   $0x3a
  jmp alltraps
80107ce2:	e9 ad f7 ff ff       	jmp    80107494 <alltraps>

80107ce7 <vector59>:
.globl vector59
vector59:
  pushl $0
80107ce7:	6a 00                	push   $0x0
  pushl $59
80107ce9:	6a 3b                	push   $0x3b
  jmp alltraps
80107ceb:	e9 a4 f7 ff ff       	jmp    80107494 <alltraps>

80107cf0 <vector60>:
.globl vector60
vector60:
  pushl $0
80107cf0:	6a 00                	push   $0x0
  pushl $60
80107cf2:	6a 3c                	push   $0x3c
  jmp alltraps
80107cf4:	e9 9b f7 ff ff       	jmp    80107494 <alltraps>

80107cf9 <vector61>:
.globl vector61
vector61:
  pushl $0
80107cf9:	6a 00                	push   $0x0
  pushl $61
80107cfb:	6a 3d                	push   $0x3d
  jmp alltraps
80107cfd:	e9 92 f7 ff ff       	jmp    80107494 <alltraps>

80107d02 <vector62>:
.globl vector62
vector62:
  pushl $0
80107d02:	6a 00                	push   $0x0
  pushl $62
80107d04:	6a 3e                	push   $0x3e
  jmp alltraps
80107d06:	e9 89 f7 ff ff       	jmp    80107494 <alltraps>

80107d0b <vector63>:
.globl vector63
vector63:
  pushl $0
80107d0b:	6a 00                	push   $0x0
  pushl $63
80107d0d:	6a 3f                	push   $0x3f
  jmp alltraps
80107d0f:	e9 80 f7 ff ff       	jmp    80107494 <alltraps>

80107d14 <vector64>:
.globl vector64
vector64:
  pushl $0
80107d14:	6a 00                	push   $0x0
  pushl $64
80107d16:	6a 40                	push   $0x40
  jmp alltraps
80107d18:	e9 77 f7 ff ff       	jmp    80107494 <alltraps>

80107d1d <vector65>:
.globl vector65
vector65:
  pushl $0
80107d1d:	6a 00                	push   $0x0
  pushl $65
80107d1f:	6a 41                	push   $0x41
  jmp alltraps
80107d21:	e9 6e f7 ff ff       	jmp    80107494 <alltraps>

80107d26 <vector66>:
.globl vector66
vector66:
  pushl $0
80107d26:	6a 00                	push   $0x0
  pushl $66
80107d28:	6a 42                	push   $0x42
  jmp alltraps
80107d2a:	e9 65 f7 ff ff       	jmp    80107494 <alltraps>

80107d2f <vector67>:
.globl vector67
vector67:
  pushl $0
80107d2f:	6a 00                	push   $0x0
  pushl $67
80107d31:	6a 43                	push   $0x43
  jmp alltraps
80107d33:	e9 5c f7 ff ff       	jmp    80107494 <alltraps>

80107d38 <vector68>:
.globl vector68
vector68:
  pushl $0
80107d38:	6a 00                	push   $0x0
  pushl $68
80107d3a:	6a 44                	push   $0x44
  jmp alltraps
80107d3c:	e9 53 f7 ff ff       	jmp    80107494 <alltraps>

80107d41 <vector69>:
.globl vector69
vector69:
  pushl $0
80107d41:	6a 00                	push   $0x0
  pushl $69
80107d43:	6a 45                	push   $0x45
  jmp alltraps
80107d45:	e9 4a f7 ff ff       	jmp    80107494 <alltraps>

80107d4a <vector70>:
.globl vector70
vector70:
  pushl $0
80107d4a:	6a 00                	push   $0x0
  pushl $70
80107d4c:	6a 46                	push   $0x46
  jmp alltraps
80107d4e:	e9 41 f7 ff ff       	jmp    80107494 <alltraps>

80107d53 <vector71>:
.globl vector71
vector71:
  pushl $0
80107d53:	6a 00                	push   $0x0
  pushl $71
80107d55:	6a 47                	push   $0x47
  jmp alltraps
80107d57:	e9 38 f7 ff ff       	jmp    80107494 <alltraps>

80107d5c <vector72>:
.globl vector72
vector72:
  pushl $0
80107d5c:	6a 00                	push   $0x0
  pushl $72
80107d5e:	6a 48                	push   $0x48
  jmp alltraps
80107d60:	e9 2f f7 ff ff       	jmp    80107494 <alltraps>

80107d65 <vector73>:
.globl vector73
vector73:
  pushl $0
80107d65:	6a 00                	push   $0x0
  pushl $73
80107d67:	6a 49                	push   $0x49
  jmp alltraps
80107d69:	e9 26 f7 ff ff       	jmp    80107494 <alltraps>

80107d6e <vector74>:
.globl vector74
vector74:
  pushl $0
80107d6e:	6a 00                	push   $0x0
  pushl $74
80107d70:	6a 4a                	push   $0x4a
  jmp alltraps
80107d72:	e9 1d f7 ff ff       	jmp    80107494 <alltraps>

80107d77 <vector75>:
.globl vector75
vector75:
  pushl $0
80107d77:	6a 00                	push   $0x0
  pushl $75
80107d79:	6a 4b                	push   $0x4b
  jmp alltraps
80107d7b:	e9 14 f7 ff ff       	jmp    80107494 <alltraps>

80107d80 <vector76>:
.globl vector76
vector76:
  pushl $0
80107d80:	6a 00                	push   $0x0
  pushl $76
80107d82:	6a 4c                	push   $0x4c
  jmp alltraps
80107d84:	e9 0b f7 ff ff       	jmp    80107494 <alltraps>

80107d89 <vector77>:
.globl vector77
vector77:
  pushl $0
80107d89:	6a 00                	push   $0x0
  pushl $77
80107d8b:	6a 4d                	push   $0x4d
  jmp alltraps
80107d8d:	e9 02 f7 ff ff       	jmp    80107494 <alltraps>

80107d92 <vector78>:
.globl vector78
vector78:
  pushl $0
80107d92:	6a 00                	push   $0x0
  pushl $78
80107d94:	6a 4e                	push   $0x4e
  jmp alltraps
80107d96:	e9 f9 f6 ff ff       	jmp    80107494 <alltraps>

80107d9b <vector79>:
.globl vector79
vector79:
  pushl $0
80107d9b:	6a 00                	push   $0x0
  pushl $79
80107d9d:	6a 4f                	push   $0x4f
  jmp alltraps
80107d9f:	e9 f0 f6 ff ff       	jmp    80107494 <alltraps>

80107da4 <vector80>:
.globl vector80
vector80:
  pushl $0
80107da4:	6a 00                	push   $0x0
  pushl $80
80107da6:	6a 50                	push   $0x50
  jmp alltraps
80107da8:	e9 e7 f6 ff ff       	jmp    80107494 <alltraps>

80107dad <vector81>:
.globl vector81
vector81:
  pushl $0
80107dad:	6a 00                	push   $0x0
  pushl $81
80107daf:	6a 51                	push   $0x51
  jmp alltraps
80107db1:	e9 de f6 ff ff       	jmp    80107494 <alltraps>

80107db6 <vector82>:
.globl vector82
vector82:
  pushl $0
80107db6:	6a 00                	push   $0x0
  pushl $82
80107db8:	6a 52                	push   $0x52
  jmp alltraps
80107dba:	e9 d5 f6 ff ff       	jmp    80107494 <alltraps>

80107dbf <vector83>:
.globl vector83
vector83:
  pushl $0
80107dbf:	6a 00                	push   $0x0
  pushl $83
80107dc1:	6a 53                	push   $0x53
  jmp alltraps
80107dc3:	e9 cc f6 ff ff       	jmp    80107494 <alltraps>

80107dc8 <vector84>:
.globl vector84
vector84:
  pushl $0
80107dc8:	6a 00                	push   $0x0
  pushl $84
80107dca:	6a 54                	push   $0x54
  jmp alltraps
80107dcc:	e9 c3 f6 ff ff       	jmp    80107494 <alltraps>

80107dd1 <vector85>:
.globl vector85
vector85:
  pushl $0
80107dd1:	6a 00                	push   $0x0
  pushl $85
80107dd3:	6a 55                	push   $0x55
  jmp alltraps
80107dd5:	e9 ba f6 ff ff       	jmp    80107494 <alltraps>

80107dda <vector86>:
.globl vector86
vector86:
  pushl $0
80107dda:	6a 00                	push   $0x0
  pushl $86
80107ddc:	6a 56                	push   $0x56
  jmp alltraps
80107dde:	e9 b1 f6 ff ff       	jmp    80107494 <alltraps>

80107de3 <vector87>:
.globl vector87
vector87:
  pushl $0
80107de3:	6a 00                	push   $0x0
  pushl $87
80107de5:	6a 57                	push   $0x57
  jmp alltraps
80107de7:	e9 a8 f6 ff ff       	jmp    80107494 <alltraps>

80107dec <vector88>:
.globl vector88
vector88:
  pushl $0
80107dec:	6a 00                	push   $0x0
  pushl $88
80107dee:	6a 58                	push   $0x58
  jmp alltraps
80107df0:	e9 9f f6 ff ff       	jmp    80107494 <alltraps>

80107df5 <vector89>:
.globl vector89
vector89:
  pushl $0
80107df5:	6a 00                	push   $0x0
  pushl $89
80107df7:	6a 59                	push   $0x59
  jmp alltraps
80107df9:	e9 96 f6 ff ff       	jmp    80107494 <alltraps>

80107dfe <vector90>:
.globl vector90
vector90:
  pushl $0
80107dfe:	6a 00                	push   $0x0
  pushl $90
80107e00:	6a 5a                	push   $0x5a
  jmp alltraps
80107e02:	e9 8d f6 ff ff       	jmp    80107494 <alltraps>

80107e07 <vector91>:
.globl vector91
vector91:
  pushl $0
80107e07:	6a 00                	push   $0x0
  pushl $91
80107e09:	6a 5b                	push   $0x5b
  jmp alltraps
80107e0b:	e9 84 f6 ff ff       	jmp    80107494 <alltraps>

80107e10 <vector92>:
.globl vector92
vector92:
  pushl $0
80107e10:	6a 00                	push   $0x0
  pushl $92
80107e12:	6a 5c                	push   $0x5c
  jmp alltraps
80107e14:	e9 7b f6 ff ff       	jmp    80107494 <alltraps>

80107e19 <vector93>:
.globl vector93
vector93:
  pushl $0
80107e19:	6a 00                	push   $0x0
  pushl $93
80107e1b:	6a 5d                	push   $0x5d
  jmp alltraps
80107e1d:	e9 72 f6 ff ff       	jmp    80107494 <alltraps>

80107e22 <vector94>:
.globl vector94
vector94:
  pushl $0
80107e22:	6a 00                	push   $0x0
  pushl $94
80107e24:	6a 5e                	push   $0x5e
  jmp alltraps
80107e26:	e9 69 f6 ff ff       	jmp    80107494 <alltraps>

80107e2b <vector95>:
.globl vector95
vector95:
  pushl $0
80107e2b:	6a 00                	push   $0x0
  pushl $95
80107e2d:	6a 5f                	push   $0x5f
  jmp alltraps
80107e2f:	e9 60 f6 ff ff       	jmp    80107494 <alltraps>

80107e34 <vector96>:
.globl vector96
vector96:
  pushl $0
80107e34:	6a 00                	push   $0x0
  pushl $96
80107e36:	6a 60                	push   $0x60
  jmp alltraps
80107e38:	e9 57 f6 ff ff       	jmp    80107494 <alltraps>

80107e3d <vector97>:
.globl vector97
vector97:
  pushl $0
80107e3d:	6a 00                	push   $0x0
  pushl $97
80107e3f:	6a 61                	push   $0x61
  jmp alltraps
80107e41:	e9 4e f6 ff ff       	jmp    80107494 <alltraps>

80107e46 <vector98>:
.globl vector98
vector98:
  pushl $0
80107e46:	6a 00                	push   $0x0
  pushl $98
80107e48:	6a 62                	push   $0x62
  jmp alltraps
80107e4a:	e9 45 f6 ff ff       	jmp    80107494 <alltraps>

80107e4f <vector99>:
.globl vector99
vector99:
  pushl $0
80107e4f:	6a 00                	push   $0x0
  pushl $99
80107e51:	6a 63                	push   $0x63
  jmp alltraps
80107e53:	e9 3c f6 ff ff       	jmp    80107494 <alltraps>

80107e58 <vector100>:
.globl vector100
vector100:
  pushl $0
80107e58:	6a 00                	push   $0x0
  pushl $100
80107e5a:	6a 64                	push   $0x64
  jmp alltraps
80107e5c:	e9 33 f6 ff ff       	jmp    80107494 <alltraps>

80107e61 <vector101>:
.globl vector101
vector101:
  pushl $0
80107e61:	6a 00                	push   $0x0
  pushl $101
80107e63:	6a 65                	push   $0x65
  jmp alltraps
80107e65:	e9 2a f6 ff ff       	jmp    80107494 <alltraps>

80107e6a <vector102>:
.globl vector102
vector102:
  pushl $0
80107e6a:	6a 00                	push   $0x0
  pushl $102
80107e6c:	6a 66                	push   $0x66
  jmp alltraps
80107e6e:	e9 21 f6 ff ff       	jmp    80107494 <alltraps>

80107e73 <vector103>:
.globl vector103
vector103:
  pushl $0
80107e73:	6a 00                	push   $0x0
  pushl $103
80107e75:	6a 67                	push   $0x67
  jmp alltraps
80107e77:	e9 18 f6 ff ff       	jmp    80107494 <alltraps>

80107e7c <vector104>:
.globl vector104
vector104:
  pushl $0
80107e7c:	6a 00                	push   $0x0
  pushl $104
80107e7e:	6a 68                	push   $0x68
  jmp alltraps
80107e80:	e9 0f f6 ff ff       	jmp    80107494 <alltraps>

80107e85 <vector105>:
.globl vector105
vector105:
  pushl $0
80107e85:	6a 00                	push   $0x0
  pushl $105
80107e87:	6a 69                	push   $0x69
  jmp alltraps
80107e89:	e9 06 f6 ff ff       	jmp    80107494 <alltraps>

80107e8e <vector106>:
.globl vector106
vector106:
  pushl $0
80107e8e:	6a 00                	push   $0x0
  pushl $106
80107e90:	6a 6a                	push   $0x6a
  jmp alltraps
80107e92:	e9 fd f5 ff ff       	jmp    80107494 <alltraps>

80107e97 <vector107>:
.globl vector107
vector107:
  pushl $0
80107e97:	6a 00                	push   $0x0
  pushl $107
80107e99:	6a 6b                	push   $0x6b
  jmp alltraps
80107e9b:	e9 f4 f5 ff ff       	jmp    80107494 <alltraps>

80107ea0 <vector108>:
.globl vector108
vector108:
  pushl $0
80107ea0:	6a 00                	push   $0x0
  pushl $108
80107ea2:	6a 6c                	push   $0x6c
  jmp alltraps
80107ea4:	e9 eb f5 ff ff       	jmp    80107494 <alltraps>

80107ea9 <vector109>:
.globl vector109
vector109:
  pushl $0
80107ea9:	6a 00                	push   $0x0
  pushl $109
80107eab:	6a 6d                	push   $0x6d
  jmp alltraps
80107ead:	e9 e2 f5 ff ff       	jmp    80107494 <alltraps>

80107eb2 <vector110>:
.globl vector110
vector110:
  pushl $0
80107eb2:	6a 00                	push   $0x0
  pushl $110
80107eb4:	6a 6e                	push   $0x6e
  jmp alltraps
80107eb6:	e9 d9 f5 ff ff       	jmp    80107494 <alltraps>

80107ebb <vector111>:
.globl vector111
vector111:
  pushl $0
80107ebb:	6a 00                	push   $0x0
  pushl $111
80107ebd:	6a 6f                	push   $0x6f
  jmp alltraps
80107ebf:	e9 d0 f5 ff ff       	jmp    80107494 <alltraps>

80107ec4 <vector112>:
.globl vector112
vector112:
  pushl $0
80107ec4:	6a 00                	push   $0x0
  pushl $112
80107ec6:	6a 70                	push   $0x70
  jmp alltraps
80107ec8:	e9 c7 f5 ff ff       	jmp    80107494 <alltraps>

80107ecd <vector113>:
.globl vector113
vector113:
  pushl $0
80107ecd:	6a 00                	push   $0x0
  pushl $113
80107ecf:	6a 71                	push   $0x71
  jmp alltraps
80107ed1:	e9 be f5 ff ff       	jmp    80107494 <alltraps>

80107ed6 <vector114>:
.globl vector114
vector114:
  pushl $0
80107ed6:	6a 00                	push   $0x0
  pushl $114
80107ed8:	6a 72                	push   $0x72
  jmp alltraps
80107eda:	e9 b5 f5 ff ff       	jmp    80107494 <alltraps>

80107edf <vector115>:
.globl vector115
vector115:
  pushl $0
80107edf:	6a 00                	push   $0x0
  pushl $115
80107ee1:	6a 73                	push   $0x73
  jmp alltraps
80107ee3:	e9 ac f5 ff ff       	jmp    80107494 <alltraps>

80107ee8 <vector116>:
.globl vector116
vector116:
  pushl $0
80107ee8:	6a 00                	push   $0x0
  pushl $116
80107eea:	6a 74                	push   $0x74
  jmp alltraps
80107eec:	e9 a3 f5 ff ff       	jmp    80107494 <alltraps>

80107ef1 <vector117>:
.globl vector117
vector117:
  pushl $0
80107ef1:	6a 00                	push   $0x0
  pushl $117
80107ef3:	6a 75                	push   $0x75
  jmp alltraps
80107ef5:	e9 9a f5 ff ff       	jmp    80107494 <alltraps>

80107efa <vector118>:
.globl vector118
vector118:
  pushl $0
80107efa:	6a 00                	push   $0x0
  pushl $118
80107efc:	6a 76                	push   $0x76
  jmp alltraps
80107efe:	e9 91 f5 ff ff       	jmp    80107494 <alltraps>

80107f03 <vector119>:
.globl vector119
vector119:
  pushl $0
80107f03:	6a 00                	push   $0x0
  pushl $119
80107f05:	6a 77                	push   $0x77
  jmp alltraps
80107f07:	e9 88 f5 ff ff       	jmp    80107494 <alltraps>

80107f0c <vector120>:
.globl vector120
vector120:
  pushl $0
80107f0c:	6a 00                	push   $0x0
  pushl $120
80107f0e:	6a 78                	push   $0x78
  jmp alltraps
80107f10:	e9 7f f5 ff ff       	jmp    80107494 <alltraps>

80107f15 <vector121>:
.globl vector121
vector121:
  pushl $0
80107f15:	6a 00                	push   $0x0
  pushl $121
80107f17:	6a 79                	push   $0x79
  jmp alltraps
80107f19:	e9 76 f5 ff ff       	jmp    80107494 <alltraps>

80107f1e <vector122>:
.globl vector122
vector122:
  pushl $0
80107f1e:	6a 00                	push   $0x0
  pushl $122
80107f20:	6a 7a                	push   $0x7a
  jmp alltraps
80107f22:	e9 6d f5 ff ff       	jmp    80107494 <alltraps>

80107f27 <vector123>:
.globl vector123
vector123:
  pushl $0
80107f27:	6a 00                	push   $0x0
  pushl $123
80107f29:	6a 7b                	push   $0x7b
  jmp alltraps
80107f2b:	e9 64 f5 ff ff       	jmp    80107494 <alltraps>

80107f30 <vector124>:
.globl vector124
vector124:
  pushl $0
80107f30:	6a 00                	push   $0x0
  pushl $124
80107f32:	6a 7c                	push   $0x7c
  jmp alltraps
80107f34:	e9 5b f5 ff ff       	jmp    80107494 <alltraps>

80107f39 <vector125>:
.globl vector125
vector125:
  pushl $0
80107f39:	6a 00                	push   $0x0
  pushl $125
80107f3b:	6a 7d                	push   $0x7d
  jmp alltraps
80107f3d:	e9 52 f5 ff ff       	jmp    80107494 <alltraps>

80107f42 <vector126>:
.globl vector126
vector126:
  pushl $0
80107f42:	6a 00                	push   $0x0
  pushl $126
80107f44:	6a 7e                	push   $0x7e
  jmp alltraps
80107f46:	e9 49 f5 ff ff       	jmp    80107494 <alltraps>

80107f4b <vector127>:
.globl vector127
vector127:
  pushl $0
80107f4b:	6a 00                	push   $0x0
  pushl $127
80107f4d:	6a 7f                	push   $0x7f
  jmp alltraps
80107f4f:	e9 40 f5 ff ff       	jmp    80107494 <alltraps>

80107f54 <vector128>:
.globl vector128
vector128:
  pushl $0
80107f54:	6a 00                	push   $0x0
  pushl $128
80107f56:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107f5b:	e9 34 f5 ff ff       	jmp    80107494 <alltraps>

80107f60 <vector129>:
.globl vector129
vector129:
  pushl $0
80107f60:	6a 00                	push   $0x0
  pushl $129
80107f62:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107f67:	e9 28 f5 ff ff       	jmp    80107494 <alltraps>

80107f6c <vector130>:
.globl vector130
vector130:
  pushl $0
80107f6c:	6a 00                	push   $0x0
  pushl $130
80107f6e:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107f73:	e9 1c f5 ff ff       	jmp    80107494 <alltraps>

80107f78 <vector131>:
.globl vector131
vector131:
  pushl $0
80107f78:	6a 00                	push   $0x0
  pushl $131
80107f7a:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107f7f:	e9 10 f5 ff ff       	jmp    80107494 <alltraps>

80107f84 <vector132>:
.globl vector132
vector132:
  pushl $0
80107f84:	6a 00                	push   $0x0
  pushl $132
80107f86:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107f8b:	e9 04 f5 ff ff       	jmp    80107494 <alltraps>

80107f90 <vector133>:
.globl vector133
vector133:
  pushl $0
80107f90:	6a 00                	push   $0x0
  pushl $133
80107f92:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107f97:	e9 f8 f4 ff ff       	jmp    80107494 <alltraps>

80107f9c <vector134>:
.globl vector134
vector134:
  pushl $0
80107f9c:	6a 00                	push   $0x0
  pushl $134
80107f9e:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107fa3:	e9 ec f4 ff ff       	jmp    80107494 <alltraps>

80107fa8 <vector135>:
.globl vector135
vector135:
  pushl $0
80107fa8:	6a 00                	push   $0x0
  pushl $135
80107faa:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107faf:	e9 e0 f4 ff ff       	jmp    80107494 <alltraps>

80107fb4 <vector136>:
.globl vector136
vector136:
  pushl $0
80107fb4:	6a 00                	push   $0x0
  pushl $136
80107fb6:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107fbb:	e9 d4 f4 ff ff       	jmp    80107494 <alltraps>

80107fc0 <vector137>:
.globl vector137
vector137:
  pushl $0
80107fc0:	6a 00                	push   $0x0
  pushl $137
80107fc2:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107fc7:	e9 c8 f4 ff ff       	jmp    80107494 <alltraps>

80107fcc <vector138>:
.globl vector138
vector138:
  pushl $0
80107fcc:	6a 00                	push   $0x0
  pushl $138
80107fce:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107fd3:	e9 bc f4 ff ff       	jmp    80107494 <alltraps>

80107fd8 <vector139>:
.globl vector139
vector139:
  pushl $0
80107fd8:	6a 00                	push   $0x0
  pushl $139
80107fda:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107fdf:	e9 b0 f4 ff ff       	jmp    80107494 <alltraps>

80107fe4 <vector140>:
.globl vector140
vector140:
  pushl $0
80107fe4:	6a 00                	push   $0x0
  pushl $140
80107fe6:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107feb:	e9 a4 f4 ff ff       	jmp    80107494 <alltraps>

80107ff0 <vector141>:
.globl vector141
vector141:
  pushl $0
80107ff0:	6a 00                	push   $0x0
  pushl $141
80107ff2:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107ff7:	e9 98 f4 ff ff       	jmp    80107494 <alltraps>

80107ffc <vector142>:
.globl vector142
vector142:
  pushl $0
80107ffc:	6a 00                	push   $0x0
  pushl $142
80107ffe:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80108003:	e9 8c f4 ff ff       	jmp    80107494 <alltraps>

80108008 <vector143>:
.globl vector143
vector143:
  pushl $0
80108008:	6a 00                	push   $0x0
  pushl $143
8010800a:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010800f:	e9 80 f4 ff ff       	jmp    80107494 <alltraps>

80108014 <vector144>:
.globl vector144
vector144:
  pushl $0
80108014:	6a 00                	push   $0x0
  pushl $144
80108016:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010801b:	e9 74 f4 ff ff       	jmp    80107494 <alltraps>

80108020 <vector145>:
.globl vector145
vector145:
  pushl $0
80108020:	6a 00                	push   $0x0
  pushl $145
80108022:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80108027:	e9 68 f4 ff ff       	jmp    80107494 <alltraps>

8010802c <vector146>:
.globl vector146
vector146:
  pushl $0
8010802c:	6a 00                	push   $0x0
  pushl $146
8010802e:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80108033:	e9 5c f4 ff ff       	jmp    80107494 <alltraps>

80108038 <vector147>:
.globl vector147
vector147:
  pushl $0
80108038:	6a 00                	push   $0x0
  pushl $147
8010803a:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010803f:	e9 50 f4 ff ff       	jmp    80107494 <alltraps>

80108044 <vector148>:
.globl vector148
vector148:
  pushl $0
80108044:	6a 00                	push   $0x0
  pushl $148
80108046:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010804b:	e9 44 f4 ff ff       	jmp    80107494 <alltraps>

80108050 <vector149>:
.globl vector149
vector149:
  pushl $0
80108050:	6a 00                	push   $0x0
  pushl $149
80108052:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80108057:	e9 38 f4 ff ff       	jmp    80107494 <alltraps>

8010805c <vector150>:
.globl vector150
vector150:
  pushl $0
8010805c:	6a 00                	push   $0x0
  pushl $150
8010805e:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80108063:	e9 2c f4 ff ff       	jmp    80107494 <alltraps>

80108068 <vector151>:
.globl vector151
vector151:
  pushl $0
80108068:	6a 00                	push   $0x0
  pushl $151
8010806a:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010806f:	e9 20 f4 ff ff       	jmp    80107494 <alltraps>

80108074 <vector152>:
.globl vector152
vector152:
  pushl $0
80108074:	6a 00                	push   $0x0
  pushl $152
80108076:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010807b:	e9 14 f4 ff ff       	jmp    80107494 <alltraps>

80108080 <vector153>:
.globl vector153
vector153:
  pushl $0
80108080:	6a 00                	push   $0x0
  pushl $153
80108082:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80108087:	e9 08 f4 ff ff       	jmp    80107494 <alltraps>

8010808c <vector154>:
.globl vector154
vector154:
  pushl $0
8010808c:	6a 00                	push   $0x0
  pushl $154
8010808e:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80108093:	e9 fc f3 ff ff       	jmp    80107494 <alltraps>

80108098 <vector155>:
.globl vector155
vector155:
  pushl $0
80108098:	6a 00                	push   $0x0
  pushl $155
8010809a:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010809f:	e9 f0 f3 ff ff       	jmp    80107494 <alltraps>

801080a4 <vector156>:
.globl vector156
vector156:
  pushl $0
801080a4:	6a 00                	push   $0x0
  pushl $156
801080a6:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801080ab:	e9 e4 f3 ff ff       	jmp    80107494 <alltraps>

801080b0 <vector157>:
.globl vector157
vector157:
  pushl $0
801080b0:	6a 00                	push   $0x0
  pushl $157
801080b2:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801080b7:	e9 d8 f3 ff ff       	jmp    80107494 <alltraps>

801080bc <vector158>:
.globl vector158
vector158:
  pushl $0
801080bc:	6a 00                	push   $0x0
  pushl $158
801080be:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801080c3:	e9 cc f3 ff ff       	jmp    80107494 <alltraps>

801080c8 <vector159>:
.globl vector159
vector159:
  pushl $0
801080c8:	6a 00                	push   $0x0
  pushl $159
801080ca:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801080cf:	e9 c0 f3 ff ff       	jmp    80107494 <alltraps>

801080d4 <vector160>:
.globl vector160
vector160:
  pushl $0
801080d4:	6a 00                	push   $0x0
  pushl $160
801080d6:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801080db:	e9 b4 f3 ff ff       	jmp    80107494 <alltraps>

801080e0 <vector161>:
.globl vector161
vector161:
  pushl $0
801080e0:	6a 00                	push   $0x0
  pushl $161
801080e2:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801080e7:	e9 a8 f3 ff ff       	jmp    80107494 <alltraps>

801080ec <vector162>:
.globl vector162
vector162:
  pushl $0
801080ec:	6a 00                	push   $0x0
  pushl $162
801080ee:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801080f3:	e9 9c f3 ff ff       	jmp    80107494 <alltraps>

801080f8 <vector163>:
.globl vector163
vector163:
  pushl $0
801080f8:	6a 00                	push   $0x0
  pushl $163
801080fa:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801080ff:	e9 90 f3 ff ff       	jmp    80107494 <alltraps>

80108104 <vector164>:
.globl vector164
vector164:
  pushl $0
80108104:	6a 00                	push   $0x0
  pushl $164
80108106:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010810b:	e9 84 f3 ff ff       	jmp    80107494 <alltraps>

80108110 <vector165>:
.globl vector165
vector165:
  pushl $0
80108110:	6a 00                	push   $0x0
  pushl $165
80108112:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80108117:	e9 78 f3 ff ff       	jmp    80107494 <alltraps>

8010811c <vector166>:
.globl vector166
vector166:
  pushl $0
8010811c:	6a 00                	push   $0x0
  pushl $166
8010811e:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80108123:	e9 6c f3 ff ff       	jmp    80107494 <alltraps>

80108128 <vector167>:
.globl vector167
vector167:
  pushl $0
80108128:	6a 00                	push   $0x0
  pushl $167
8010812a:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010812f:	e9 60 f3 ff ff       	jmp    80107494 <alltraps>

80108134 <vector168>:
.globl vector168
vector168:
  pushl $0
80108134:	6a 00                	push   $0x0
  pushl $168
80108136:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010813b:	e9 54 f3 ff ff       	jmp    80107494 <alltraps>

80108140 <vector169>:
.globl vector169
vector169:
  pushl $0
80108140:	6a 00                	push   $0x0
  pushl $169
80108142:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80108147:	e9 48 f3 ff ff       	jmp    80107494 <alltraps>

8010814c <vector170>:
.globl vector170
vector170:
  pushl $0
8010814c:	6a 00                	push   $0x0
  pushl $170
8010814e:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80108153:	e9 3c f3 ff ff       	jmp    80107494 <alltraps>

80108158 <vector171>:
.globl vector171
vector171:
  pushl $0
80108158:	6a 00                	push   $0x0
  pushl $171
8010815a:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
8010815f:	e9 30 f3 ff ff       	jmp    80107494 <alltraps>

80108164 <vector172>:
.globl vector172
vector172:
  pushl $0
80108164:	6a 00                	push   $0x0
  pushl $172
80108166:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010816b:	e9 24 f3 ff ff       	jmp    80107494 <alltraps>

80108170 <vector173>:
.globl vector173
vector173:
  pushl $0
80108170:	6a 00                	push   $0x0
  pushl $173
80108172:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80108177:	e9 18 f3 ff ff       	jmp    80107494 <alltraps>

8010817c <vector174>:
.globl vector174
vector174:
  pushl $0
8010817c:	6a 00                	push   $0x0
  pushl $174
8010817e:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80108183:	e9 0c f3 ff ff       	jmp    80107494 <alltraps>

80108188 <vector175>:
.globl vector175
vector175:
  pushl $0
80108188:	6a 00                	push   $0x0
  pushl $175
8010818a:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010818f:	e9 00 f3 ff ff       	jmp    80107494 <alltraps>

80108194 <vector176>:
.globl vector176
vector176:
  pushl $0
80108194:	6a 00                	push   $0x0
  pushl $176
80108196:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010819b:	e9 f4 f2 ff ff       	jmp    80107494 <alltraps>

801081a0 <vector177>:
.globl vector177
vector177:
  pushl $0
801081a0:	6a 00                	push   $0x0
  pushl $177
801081a2:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801081a7:	e9 e8 f2 ff ff       	jmp    80107494 <alltraps>

801081ac <vector178>:
.globl vector178
vector178:
  pushl $0
801081ac:	6a 00                	push   $0x0
  pushl $178
801081ae:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801081b3:	e9 dc f2 ff ff       	jmp    80107494 <alltraps>

801081b8 <vector179>:
.globl vector179
vector179:
  pushl $0
801081b8:	6a 00                	push   $0x0
  pushl $179
801081ba:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801081bf:	e9 d0 f2 ff ff       	jmp    80107494 <alltraps>

801081c4 <vector180>:
.globl vector180
vector180:
  pushl $0
801081c4:	6a 00                	push   $0x0
  pushl $180
801081c6:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801081cb:	e9 c4 f2 ff ff       	jmp    80107494 <alltraps>

801081d0 <vector181>:
.globl vector181
vector181:
  pushl $0
801081d0:	6a 00                	push   $0x0
  pushl $181
801081d2:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801081d7:	e9 b8 f2 ff ff       	jmp    80107494 <alltraps>

801081dc <vector182>:
.globl vector182
vector182:
  pushl $0
801081dc:	6a 00                	push   $0x0
  pushl $182
801081de:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801081e3:	e9 ac f2 ff ff       	jmp    80107494 <alltraps>

801081e8 <vector183>:
.globl vector183
vector183:
  pushl $0
801081e8:	6a 00                	push   $0x0
  pushl $183
801081ea:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801081ef:	e9 a0 f2 ff ff       	jmp    80107494 <alltraps>

801081f4 <vector184>:
.globl vector184
vector184:
  pushl $0
801081f4:	6a 00                	push   $0x0
  pushl $184
801081f6:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801081fb:	e9 94 f2 ff ff       	jmp    80107494 <alltraps>

80108200 <vector185>:
.globl vector185
vector185:
  pushl $0
80108200:	6a 00                	push   $0x0
  pushl $185
80108202:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80108207:	e9 88 f2 ff ff       	jmp    80107494 <alltraps>

8010820c <vector186>:
.globl vector186
vector186:
  pushl $0
8010820c:	6a 00                	push   $0x0
  pushl $186
8010820e:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80108213:	e9 7c f2 ff ff       	jmp    80107494 <alltraps>

80108218 <vector187>:
.globl vector187
vector187:
  pushl $0
80108218:	6a 00                	push   $0x0
  pushl $187
8010821a:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010821f:	e9 70 f2 ff ff       	jmp    80107494 <alltraps>

80108224 <vector188>:
.globl vector188
vector188:
  pushl $0
80108224:	6a 00                	push   $0x0
  pushl $188
80108226:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010822b:	e9 64 f2 ff ff       	jmp    80107494 <alltraps>

80108230 <vector189>:
.globl vector189
vector189:
  pushl $0
80108230:	6a 00                	push   $0x0
  pushl $189
80108232:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80108237:	e9 58 f2 ff ff       	jmp    80107494 <alltraps>

8010823c <vector190>:
.globl vector190
vector190:
  pushl $0
8010823c:	6a 00                	push   $0x0
  pushl $190
8010823e:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80108243:	e9 4c f2 ff ff       	jmp    80107494 <alltraps>

80108248 <vector191>:
.globl vector191
vector191:
  pushl $0
80108248:	6a 00                	push   $0x0
  pushl $191
8010824a:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
8010824f:	e9 40 f2 ff ff       	jmp    80107494 <alltraps>

80108254 <vector192>:
.globl vector192
vector192:
  pushl $0
80108254:	6a 00                	push   $0x0
  pushl $192
80108256:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010825b:	e9 34 f2 ff ff       	jmp    80107494 <alltraps>

80108260 <vector193>:
.globl vector193
vector193:
  pushl $0
80108260:	6a 00                	push   $0x0
  pushl $193
80108262:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80108267:	e9 28 f2 ff ff       	jmp    80107494 <alltraps>

8010826c <vector194>:
.globl vector194
vector194:
  pushl $0
8010826c:	6a 00                	push   $0x0
  pushl $194
8010826e:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80108273:	e9 1c f2 ff ff       	jmp    80107494 <alltraps>

80108278 <vector195>:
.globl vector195
vector195:
  pushl $0
80108278:	6a 00                	push   $0x0
  pushl $195
8010827a:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010827f:	e9 10 f2 ff ff       	jmp    80107494 <alltraps>

80108284 <vector196>:
.globl vector196
vector196:
  pushl $0
80108284:	6a 00                	push   $0x0
  pushl $196
80108286:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010828b:	e9 04 f2 ff ff       	jmp    80107494 <alltraps>

80108290 <vector197>:
.globl vector197
vector197:
  pushl $0
80108290:	6a 00                	push   $0x0
  pushl $197
80108292:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80108297:	e9 f8 f1 ff ff       	jmp    80107494 <alltraps>

8010829c <vector198>:
.globl vector198
vector198:
  pushl $0
8010829c:	6a 00                	push   $0x0
  pushl $198
8010829e:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801082a3:	e9 ec f1 ff ff       	jmp    80107494 <alltraps>

801082a8 <vector199>:
.globl vector199
vector199:
  pushl $0
801082a8:	6a 00                	push   $0x0
  pushl $199
801082aa:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801082af:	e9 e0 f1 ff ff       	jmp    80107494 <alltraps>

801082b4 <vector200>:
.globl vector200
vector200:
  pushl $0
801082b4:	6a 00                	push   $0x0
  pushl $200
801082b6:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801082bb:	e9 d4 f1 ff ff       	jmp    80107494 <alltraps>

801082c0 <vector201>:
.globl vector201
vector201:
  pushl $0
801082c0:	6a 00                	push   $0x0
  pushl $201
801082c2:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801082c7:	e9 c8 f1 ff ff       	jmp    80107494 <alltraps>

801082cc <vector202>:
.globl vector202
vector202:
  pushl $0
801082cc:	6a 00                	push   $0x0
  pushl $202
801082ce:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801082d3:	e9 bc f1 ff ff       	jmp    80107494 <alltraps>

801082d8 <vector203>:
.globl vector203
vector203:
  pushl $0
801082d8:	6a 00                	push   $0x0
  pushl $203
801082da:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801082df:	e9 b0 f1 ff ff       	jmp    80107494 <alltraps>

801082e4 <vector204>:
.globl vector204
vector204:
  pushl $0
801082e4:	6a 00                	push   $0x0
  pushl $204
801082e6:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801082eb:	e9 a4 f1 ff ff       	jmp    80107494 <alltraps>

801082f0 <vector205>:
.globl vector205
vector205:
  pushl $0
801082f0:	6a 00                	push   $0x0
  pushl $205
801082f2:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801082f7:	e9 98 f1 ff ff       	jmp    80107494 <alltraps>

801082fc <vector206>:
.globl vector206
vector206:
  pushl $0
801082fc:	6a 00                	push   $0x0
  pushl $206
801082fe:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80108303:	e9 8c f1 ff ff       	jmp    80107494 <alltraps>

80108308 <vector207>:
.globl vector207
vector207:
  pushl $0
80108308:	6a 00                	push   $0x0
  pushl $207
8010830a:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010830f:	e9 80 f1 ff ff       	jmp    80107494 <alltraps>

80108314 <vector208>:
.globl vector208
vector208:
  pushl $0
80108314:	6a 00                	push   $0x0
  pushl $208
80108316:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010831b:	e9 74 f1 ff ff       	jmp    80107494 <alltraps>

80108320 <vector209>:
.globl vector209
vector209:
  pushl $0
80108320:	6a 00                	push   $0x0
  pushl $209
80108322:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80108327:	e9 68 f1 ff ff       	jmp    80107494 <alltraps>

8010832c <vector210>:
.globl vector210
vector210:
  pushl $0
8010832c:	6a 00                	push   $0x0
  pushl $210
8010832e:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80108333:	e9 5c f1 ff ff       	jmp    80107494 <alltraps>

80108338 <vector211>:
.globl vector211
vector211:
  pushl $0
80108338:	6a 00                	push   $0x0
  pushl $211
8010833a:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
8010833f:	e9 50 f1 ff ff       	jmp    80107494 <alltraps>

80108344 <vector212>:
.globl vector212
vector212:
  pushl $0
80108344:	6a 00                	push   $0x0
  pushl $212
80108346:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010834b:	e9 44 f1 ff ff       	jmp    80107494 <alltraps>

80108350 <vector213>:
.globl vector213
vector213:
  pushl $0
80108350:	6a 00                	push   $0x0
  pushl $213
80108352:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80108357:	e9 38 f1 ff ff       	jmp    80107494 <alltraps>

8010835c <vector214>:
.globl vector214
vector214:
  pushl $0
8010835c:	6a 00                	push   $0x0
  pushl $214
8010835e:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80108363:	e9 2c f1 ff ff       	jmp    80107494 <alltraps>

80108368 <vector215>:
.globl vector215
vector215:
  pushl $0
80108368:	6a 00                	push   $0x0
  pushl $215
8010836a:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010836f:	e9 20 f1 ff ff       	jmp    80107494 <alltraps>

80108374 <vector216>:
.globl vector216
vector216:
  pushl $0
80108374:	6a 00                	push   $0x0
  pushl $216
80108376:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010837b:	e9 14 f1 ff ff       	jmp    80107494 <alltraps>

80108380 <vector217>:
.globl vector217
vector217:
  pushl $0
80108380:	6a 00                	push   $0x0
  pushl $217
80108382:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80108387:	e9 08 f1 ff ff       	jmp    80107494 <alltraps>

8010838c <vector218>:
.globl vector218
vector218:
  pushl $0
8010838c:	6a 00                	push   $0x0
  pushl $218
8010838e:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80108393:	e9 fc f0 ff ff       	jmp    80107494 <alltraps>

80108398 <vector219>:
.globl vector219
vector219:
  pushl $0
80108398:	6a 00                	push   $0x0
  pushl $219
8010839a:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010839f:	e9 f0 f0 ff ff       	jmp    80107494 <alltraps>

801083a4 <vector220>:
.globl vector220
vector220:
  pushl $0
801083a4:	6a 00                	push   $0x0
  pushl $220
801083a6:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801083ab:	e9 e4 f0 ff ff       	jmp    80107494 <alltraps>

801083b0 <vector221>:
.globl vector221
vector221:
  pushl $0
801083b0:	6a 00                	push   $0x0
  pushl $221
801083b2:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801083b7:	e9 d8 f0 ff ff       	jmp    80107494 <alltraps>

801083bc <vector222>:
.globl vector222
vector222:
  pushl $0
801083bc:	6a 00                	push   $0x0
  pushl $222
801083be:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801083c3:	e9 cc f0 ff ff       	jmp    80107494 <alltraps>

801083c8 <vector223>:
.globl vector223
vector223:
  pushl $0
801083c8:	6a 00                	push   $0x0
  pushl $223
801083ca:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801083cf:	e9 c0 f0 ff ff       	jmp    80107494 <alltraps>

801083d4 <vector224>:
.globl vector224
vector224:
  pushl $0
801083d4:	6a 00                	push   $0x0
  pushl $224
801083d6:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801083db:	e9 b4 f0 ff ff       	jmp    80107494 <alltraps>

801083e0 <vector225>:
.globl vector225
vector225:
  pushl $0
801083e0:	6a 00                	push   $0x0
  pushl $225
801083e2:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801083e7:	e9 a8 f0 ff ff       	jmp    80107494 <alltraps>

801083ec <vector226>:
.globl vector226
vector226:
  pushl $0
801083ec:	6a 00                	push   $0x0
  pushl $226
801083ee:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801083f3:	e9 9c f0 ff ff       	jmp    80107494 <alltraps>

801083f8 <vector227>:
.globl vector227
vector227:
  pushl $0
801083f8:	6a 00                	push   $0x0
  pushl $227
801083fa:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801083ff:	e9 90 f0 ff ff       	jmp    80107494 <alltraps>

80108404 <vector228>:
.globl vector228
vector228:
  pushl $0
80108404:	6a 00                	push   $0x0
  pushl $228
80108406:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010840b:	e9 84 f0 ff ff       	jmp    80107494 <alltraps>

80108410 <vector229>:
.globl vector229
vector229:
  pushl $0
80108410:	6a 00                	push   $0x0
  pushl $229
80108412:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80108417:	e9 78 f0 ff ff       	jmp    80107494 <alltraps>

8010841c <vector230>:
.globl vector230
vector230:
  pushl $0
8010841c:	6a 00                	push   $0x0
  pushl $230
8010841e:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80108423:	e9 6c f0 ff ff       	jmp    80107494 <alltraps>

80108428 <vector231>:
.globl vector231
vector231:
  pushl $0
80108428:	6a 00                	push   $0x0
  pushl $231
8010842a:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010842f:	e9 60 f0 ff ff       	jmp    80107494 <alltraps>

80108434 <vector232>:
.globl vector232
vector232:
  pushl $0
80108434:	6a 00                	push   $0x0
  pushl $232
80108436:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010843b:	e9 54 f0 ff ff       	jmp    80107494 <alltraps>

80108440 <vector233>:
.globl vector233
vector233:
  pushl $0
80108440:	6a 00                	push   $0x0
  pushl $233
80108442:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80108447:	e9 48 f0 ff ff       	jmp    80107494 <alltraps>

8010844c <vector234>:
.globl vector234
vector234:
  pushl $0
8010844c:	6a 00                	push   $0x0
  pushl $234
8010844e:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80108453:	e9 3c f0 ff ff       	jmp    80107494 <alltraps>

80108458 <vector235>:
.globl vector235
vector235:
  pushl $0
80108458:	6a 00                	push   $0x0
  pushl $235
8010845a:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
8010845f:	e9 30 f0 ff ff       	jmp    80107494 <alltraps>

80108464 <vector236>:
.globl vector236
vector236:
  pushl $0
80108464:	6a 00                	push   $0x0
  pushl $236
80108466:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010846b:	e9 24 f0 ff ff       	jmp    80107494 <alltraps>

80108470 <vector237>:
.globl vector237
vector237:
  pushl $0
80108470:	6a 00                	push   $0x0
  pushl $237
80108472:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80108477:	e9 18 f0 ff ff       	jmp    80107494 <alltraps>

8010847c <vector238>:
.globl vector238
vector238:
  pushl $0
8010847c:	6a 00                	push   $0x0
  pushl $238
8010847e:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80108483:	e9 0c f0 ff ff       	jmp    80107494 <alltraps>

80108488 <vector239>:
.globl vector239
vector239:
  pushl $0
80108488:	6a 00                	push   $0x0
  pushl $239
8010848a:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010848f:	e9 00 f0 ff ff       	jmp    80107494 <alltraps>

80108494 <vector240>:
.globl vector240
vector240:
  pushl $0
80108494:	6a 00                	push   $0x0
  pushl $240
80108496:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010849b:	e9 f4 ef ff ff       	jmp    80107494 <alltraps>

801084a0 <vector241>:
.globl vector241
vector241:
  pushl $0
801084a0:	6a 00                	push   $0x0
  pushl $241
801084a2:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801084a7:	e9 e8 ef ff ff       	jmp    80107494 <alltraps>

801084ac <vector242>:
.globl vector242
vector242:
  pushl $0
801084ac:	6a 00                	push   $0x0
  pushl $242
801084ae:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801084b3:	e9 dc ef ff ff       	jmp    80107494 <alltraps>

801084b8 <vector243>:
.globl vector243
vector243:
  pushl $0
801084b8:	6a 00                	push   $0x0
  pushl $243
801084ba:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801084bf:	e9 d0 ef ff ff       	jmp    80107494 <alltraps>

801084c4 <vector244>:
.globl vector244
vector244:
  pushl $0
801084c4:	6a 00                	push   $0x0
  pushl $244
801084c6:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801084cb:	e9 c4 ef ff ff       	jmp    80107494 <alltraps>

801084d0 <vector245>:
.globl vector245
vector245:
  pushl $0
801084d0:	6a 00                	push   $0x0
  pushl $245
801084d2:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801084d7:	e9 b8 ef ff ff       	jmp    80107494 <alltraps>

801084dc <vector246>:
.globl vector246
vector246:
  pushl $0
801084dc:	6a 00                	push   $0x0
  pushl $246
801084de:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801084e3:	e9 ac ef ff ff       	jmp    80107494 <alltraps>

801084e8 <vector247>:
.globl vector247
vector247:
  pushl $0
801084e8:	6a 00                	push   $0x0
  pushl $247
801084ea:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801084ef:	e9 a0 ef ff ff       	jmp    80107494 <alltraps>

801084f4 <vector248>:
.globl vector248
vector248:
  pushl $0
801084f4:	6a 00                	push   $0x0
  pushl $248
801084f6:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801084fb:	e9 94 ef ff ff       	jmp    80107494 <alltraps>

80108500 <vector249>:
.globl vector249
vector249:
  pushl $0
80108500:	6a 00                	push   $0x0
  pushl $249
80108502:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80108507:	e9 88 ef ff ff       	jmp    80107494 <alltraps>

8010850c <vector250>:
.globl vector250
vector250:
  pushl $0
8010850c:	6a 00                	push   $0x0
  pushl $250
8010850e:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80108513:	e9 7c ef ff ff       	jmp    80107494 <alltraps>

80108518 <vector251>:
.globl vector251
vector251:
  pushl $0
80108518:	6a 00                	push   $0x0
  pushl $251
8010851a:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010851f:	e9 70 ef ff ff       	jmp    80107494 <alltraps>

80108524 <vector252>:
.globl vector252
vector252:
  pushl $0
80108524:	6a 00                	push   $0x0
  pushl $252
80108526:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010852b:	e9 64 ef ff ff       	jmp    80107494 <alltraps>

80108530 <vector253>:
.globl vector253
vector253:
  pushl $0
80108530:	6a 00                	push   $0x0
  pushl $253
80108532:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80108537:	e9 58 ef ff ff       	jmp    80107494 <alltraps>

8010853c <vector254>:
.globl vector254
vector254:
  pushl $0
8010853c:	6a 00                	push   $0x0
  pushl $254
8010853e:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80108543:	e9 4c ef ff ff       	jmp    80107494 <alltraps>

80108548 <vector255>:
.globl vector255
vector255:
  pushl $0
80108548:	6a 00                	push   $0x0
  pushl $255
8010854a:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
8010854f:	e9 40 ef ff ff       	jmp    80107494 <alltraps>

80108554 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80108554:	55                   	push   %ebp
80108555:	89 e5                	mov    %esp,%ebp
80108557:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010855a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010855d:	83 e8 01             	sub    $0x1,%eax
80108560:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80108564:	8b 45 08             	mov    0x8(%ebp),%eax
80108567:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010856b:	8b 45 08             	mov    0x8(%ebp),%eax
8010856e:	c1 e8 10             	shr    $0x10,%eax
80108571:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80108575:	8d 45 fa             	lea    -0x6(%ebp),%eax
80108578:	0f 01 10             	lgdtl  (%eax)
}
8010857b:	90                   	nop
8010857c:	c9                   	leave  
8010857d:	c3                   	ret    

8010857e <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
8010857e:	55                   	push   %ebp
8010857f:	89 e5                	mov    %esp,%ebp
80108581:	83 ec 04             	sub    $0x4,%esp
80108584:	8b 45 08             	mov    0x8(%ebp),%eax
80108587:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010858b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010858f:	0f 00 d8             	ltr    %ax
}
80108592:	90                   	nop
80108593:	c9                   	leave  
80108594:	c3                   	ret    

80108595 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80108595:	55                   	push   %ebp
80108596:	89 e5                	mov    %esp,%ebp
80108598:	83 ec 04             	sub    $0x4,%esp
8010859b:	8b 45 08             	mov    0x8(%ebp),%eax
8010859e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801085a2:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801085a6:	8e e8                	mov    %eax,%gs
}
801085a8:	90                   	nop
801085a9:	c9                   	leave  
801085aa:	c3                   	ret    

801085ab <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801085ab:	55                   	push   %ebp
801085ac:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801085ae:	8b 45 08             	mov    0x8(%ebp),%eax
801085b1:	0f 22 d8             	mov    %eax,%cr3
}
801085b4:	90                   	nop
801085b5:	5d                   	pop    %ebp
801085b6:	c3                   	ret    

801085b7 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801085b7:	55                   	push   %ebp
801085b8:	89 e5                	mov    %esp,%ebp
801085ba:	8b 45 08             	mov    0x8(%ebp),%eax
801085bd:	05 00 00 00 80       	add    $0x80000000,%eax
801085c2:	5d                   	pop    %ebp
801085c3:	c3                   	ret    

801085c4 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801085c4:	55                   	push   %ebp
801085c5:	89 e5                	mov    %esp,%ebp
801085c7:	8b 45 08             	mov    0x8(%ebp),%eax
801085ca:	05 00 00 00 80       	add    $0x80000000,%eax
801085cf:	5d                   	pop    %ebp
801085d0:	c3                   	ret    

801085d1 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801085d1:	55                   	push   %ebp
801085d2:	89 e5                	mov    %esp,%ebp
801085d4:	53                   	push   %ebx
801085d5:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801085d8:	e8 8d aa ff ff       	call   8010306a <cpunum>
801085dd:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801085e3:	05 80 33 11 80       	add    $0x80113380,%eax
801085e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801085eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ee:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801085f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f7:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801085fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108600:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80108604:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108607:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010860b:	83 e2 f0             	and    $0xfffffff0,%edx
8010860e:	83 ca 0a             	or     $0xa,%edx
80108611:	88 50 7d             	mov    %dl,0x7d(%eax)
80108614:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108617:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010861b:	83 ca 10             	or     $0x10,%edx
8010861e:	88 50 7d             	mov    %dl,0x7d(%eax)
80108621:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108624:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108628:	83 e2 9f             	and    $0xffffff9f,%edx
8010862b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010862e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108631:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108635:	83 ca 80             	or     $0xffffff80,%edx
80108638:	88 50 7d             	mov    %dl,0x7d(%eax)
8010863b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010863e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108642:	83 ca 0f             	or     $0xf,%edx
80108645:	88 50 7e             	mov    %dl,0x7e(%eax)
80108648:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010864b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010864f:	83 e2 ef             	and    $0xffffffef,%edx
80108652:	88 50 7e             	mov    %dl,0x7e(%eax)
80108655:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108658:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010865c:	83 e2 df             	and    $0xffffffdf,%edx
8010865f:	88 50 7e             	mov    %dl,0x7e(%eax)
80108662:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108665:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108669:	83 ca 40             	or     $0x40,%edx
8010866c:	88 50 7e             	mov    %dl,0x7e(%eax)
8010866f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108672:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108676:	83 ca 80             	or     $0xffffff80,%edx
80108679:	88 50 7e             	mov    %dl,0x7e(%eax)
8010867c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010867f:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80108683:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108686:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010868d:	ff ff 
8010868f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108692:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80108699:	00 00 
8010869b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010869e:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801086a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a8:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801086af:	83 e2 f0             	and    $0xfffffff0,%edx
801086b2:	83 ca 02             	or     $0x2,%edx
801086b5:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801086bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086be:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801086c5:	83 ca 10             	or     $0x10,%edx
801086c8:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801086ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d1:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801086d8:	83 e2 9f             	and    $0xffffff9f,%edx
801086db:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801086e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e4:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801086eb:	83 ca 80             	or     $0xffffff80,%edx
801086ee:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801086f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f7:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801086fe:	83 ca 0f             	or     $0xf,%edx
80108701:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108707:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010870a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108711:	83 e2 ef             	and    $0xffffffef,%edx
80108714:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010871a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010871d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108724:	83 e2 df             	and    $0xffffffdf,%edx
80108727:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010872d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108730:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108737:	83 ca 40             	or     $0x40,%edx
8010873a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108740:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108743:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010874a:	83 ca 80             	or     $0xffffff80,%edx
8010874d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108753:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108756:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010875d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108760:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80108767:	ff ff 
80108769:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010876c:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80108773:	00 00 
80108775:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108778:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010877f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108782:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108789:	83 e2 f0             	and    $0xfffffff0,%edx
8010878c:	83 ca 0a             	or     $0xa,%edx
8010878f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108795:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108798:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010879f:	83 ca 10             	or     $0x10,%edx
801087a2:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801087a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ab:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801087b2:	83 ca 60             	or     $0x60,%edx
801087b5:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801087bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087be:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801087c5:	83 ca 80             	or     $0xffffff80,%edx
801087c8:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801087ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087d1:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801087d8:	83 ca 0f             	or     $0xf,%edx
801087db:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801087e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087e4:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801087eb:	83 e2 ef             	and    $0xffffffef,%edx
801087ee:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801087f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f7:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801087fe:	83 e2 df             	and    $0xffffffdf,%edx
80108801:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108807:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010880a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108811:	83 ca 40             	or     $0x40,%edx
80108814:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010881a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010881d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108824:	83 ca 80             	or     $0xffffff80,%edx
80108827:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010882d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108830:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80108837:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010883a:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80108841:	ff ff 
80108843:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108846:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
8010884d:	00 00 
8010884f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108852:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80108859:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010885c:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108863:	83 e2 f0             	and    $0xfffffff0,%edx
80108866:	83 ca 02             	or     $0x2,%edx
80108869:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010886f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108872:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108879:	83 ca 10             	or     $0x10,%edx
8010887c:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108882:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108885:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010888c:	83 ca 60             	or     $0x60,%edx
8010888f:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108895:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108898:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010889f:	83 ca 80             	or     $0xffffff80,%edx
801088a2:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801088a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ab:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801088b2:	83 ca 0f             	or     $0xf,%edx
801088b5:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801088bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088be:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801088c5:	83 e2 ef             	and    $0xffffffef,%edx
801088c8:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801088ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088d1:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801088d8:	83 e2 df             	and    $0xffffffdf,%edx
801088db:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801088e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088e4:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801088eb:	83 ca 40             	or     $0x40,%edx
801088ee:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801088f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088f7:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801088fe:	83 ca 80             	or     $0xffffff80,%edx
80108901:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108907:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010890a:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80108911:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108914:	05 b4 00 00 00       	add    $0xb4,%eax
80108919:	89 c3                	mov    %eax,%ebx
8010891b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010891e:	05 b4 00 00 00       	add    $0xb4,%eax
80108923:	c1 e8 10             	shr    $0x10,%eax
80108926:	89 c2                	mov    %eax,%edx
80108928:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010892b:	05 b4 00 00 00       	add    $0xb4,%eax
80108930:	c1 e8 18             	shr    $0x18,%eax
80108933:	89 c1                	mov    %eax,%ecx
80108935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108938:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
8010893f:	00 00 
80108941:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108944:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
8010894b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010894e:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80108954:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108957:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010895e:	83 e2 f0             	and    $0xfffffff0,%edx
80108961:	83 ca 02             	or     $0x2,%edx
80108964:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010896a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010896d:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108974:	83 ca 10             	or     $0x10,%edx
80108977:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010897d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108980:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108987:	83 e2 9f             	and    $0xffffff9f,%edx
8010898a:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108990:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108993:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010899a:	83 ca 80             	or     $0xffffff80,%edx
8010899d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801089a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089a6:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801089ad:	83 e2 f0             	and    $0xfffffff0,%edx
801089b0:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801089b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089b9:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801089c0:	83 e2 ef             	and    $0xffffffef,%edx
801089c3:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801089c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089cc:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801089d3:	83 e2 df             	and    $0xffffffdf,%edx
801089d6:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801089dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089df:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801089e6:	83 ca 40             	or     $0x40,%edx
801089e9:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801089ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089f2:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801089f9:	83 ca 80             	or     $0xffffff80,%edx
801089fc:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108a02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a05:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80108a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a0e:	83 c0 70             	add    $0x70,%eax
80108a11:	83 ec 08             	sub    $0x8,%esp
80108a14:	6a 38                	push   $0x38
80108a16:	50                   	push   %eax
80108a17:	e8 38 fb ff ff       	call   80108554 <lgdt>
80108a1c:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80108a1f:	83 ec 0c             	sub    $0xc,%esp
80108a22:	6a 18                	push   $0x18
80108a24:	e8 6c fb ff ff       	call   80108595 <loadgs>
80108a29:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80108a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a2f:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80108a35:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80108a3c:	00 00 00 00 
}
80108a40:	90                   	nop
80108a41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108a44:	c9                   	leave  
80108a45:	c3                   	ret    

80108a46 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108a46:	55                   	push   %ebp
80108a47:	89 e5                	mov    %esp,%ebp
80108a49:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108a4c:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a4f:	c1 e8 16             	shr    $0x16,%eax
80108a52:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108a59:	8b 45 08             	mov    0x8(%ebp),%eax
80108a5c:	01 d0                	add    %edx,%eax
80108a5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108a61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a64:	8b 00                	mov    (%eax),%eax
80108a66:	83 e0 01             	and    $0x1,%eax
80108a69:	85 c0                	test   %eax,%eax
80108a6b:	74 18                	je     80108a85 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80108a6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a70:	8b 00                	mov    (%eax),%eax
80108a72:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a77:	50                   	push   %eax
80108a78:	e8 47 fb ff ff       	call   801085c4 <p2v>
80108a7d:	83 c4 04             	add    $0x4,%esp
80108a80:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108a83:	eb 48                	jmp    80108acd <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108a85:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108a89:	74 0e                	je     80108a99 <walkpgdir+0x53>
80108a8b:	e8 74 a2 ff ff       	call   80102d04 <kalloc>
80108a90:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108a93:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108a97:	75 07                	jne    80108aa0 <walkpgdir+0x5a>
      return 0;
80108a99:	b8 00 00 00 00       	mov    $0x0,%eax
80108a9e:	eb 44                	jmp    80108ae4 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108aa0:	83 ec 04             	sub    $0x4,%esp
80108aa3:	68 00 10 00 00       	push   $0x1000
80108aa8:	6a 00                	push   $0x0
80108aaa:	ff 75 f4             	pushl  -0xc(%ebp)
80108aad:	e8 d4 d4 ff ff       	call   80105f86 <memset>
80108ab2:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80108ab5:	83 ec 0c             	sub    $0xc,%esp
80108ab8:	ff 75 f4             	pushl  -0xc(%ebp)
80108abb:	e8 f7 fa ff ff       	call   801085b7 <v2p>
80108ac0:	83 c4 10             	add    $0x10,%esp
80108ac3:	83 c8 07             	or     $0x7,%eax
80108ac6:	89 c2                	mov    %eax,%edx
80108ac8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108acb:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108acd:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ad0:	c1 e8 0c             	shr    $0xc,%eax
80108ad3:	25 ff 03 00 00       	and    $0x3ff,%eax
80108ad8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ae2:	01 d0                	add    %edx,%eax
}
80108ae4:	c9                   	leave  
80108ae5:	c3                   	ret    

80108ae6 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108ae6:	55                   	push   %ebp
80108ae7:	89 e5                	mov    %esp,%ebp
80108ae9:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80108aec:	8b 45 0c             	mov    0xc(%ebp),%eax
80108aef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108af4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108af7:	8b 55 0c             	mov    0xc(%ebp),%edx
80108afa:	8b 45 10             	mov    0x10(%ebp),%eax
80108afd:	01 d0                	add    %edx,%eax
80108aff:	83 e8 01             	sub    $0x1,%eax
80108b02:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b07:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108b0a:	83 ec 04             	sub    $0x4,%esp
80108b0d:	6a 01                	push   $0x1
80108b0f:	ff 75 f4             	pushl  -0xc(%ebp)
80108b12:	ff 75 08             	pushl  0x8(%ebp)
80108b15:	e8 2c ff ff ff       	call   80108a46 <walkpgdir>
80108b1a:	83 c4 10             	add    $0x10,%esp
80108b1d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108b20:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108b24:	75 07                	jne    80108b2d <mappages+0x47>
      return -1;
80108b26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108b2b:	eb 47                	jmp    80108b74 <mappages+0x8e>
    if(*pte & PTE_P)
80108b2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b30:	8b 00                	mov    (%eax),%eax
80108b32:	83 e0 01             	and    $0x1,%eax
80108b35:	85 c0                	test   %eax,%eax
80108b37:	74 0d                	je     80108b46 <mappages+0x60>
      panic("remap");
80108b39:	83 ec 0c             	sub    $0xc,%esp
80108b3c:	68 98 9a 10 80       	push   $0x80109a98
80108b41:	e8 20 7a ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
80108b46:	8b 45 18             	mov    0x18(%ebp),%eax
80108b49:	0b 45 14             	or     0x14(%ebp),%eax
80108b4c:	83 c8 01             	or     $0x1,%eax
80108b4f:	89 c2                	mov    %eax,%edx
80108b51:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b54:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108b56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b59:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108b5c:	74 10                	je     80108b6e <mappages+0x88>
      break;
    a += PGSIZE;
80108b5e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108b65:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108b6c:	eb 9c                	jmp    80108b0a <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80108b6e:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108b6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108b74:	c9                   	leave  
80108b75:	c3                   	ret    

80108b76 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108b76:	55                   	push   %ebp
80108b77:	89 e5                	mov    %esp,%ebp
80108b79:	53                   	push   %ebx
80108b7a:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108b7d:	e8 82 a1 ff ff       	call   80102d04 <kalloc>
80108b82:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108b85:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108b89:	75 0a                	jne    80108b95 <setupkvm+0x1f>
    return 0;
80108b8b:	b8 00 00 00 00       	mov    $0x0,%eax
80108b90:	e9 8e 00 00 00       	jmp    80108c23 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80108b95:	83 ec 04             	sub    $0x4,%esp
80108b98:	68 00 10 00 00       	push   $0x1000
80108b9d:	6a 00                	push   $0x0
80108b9f:	ff 75 f0             	pushl  -0x10(%ebp)
80108ba2:	e8 df d3 ff ff       	call   80105f86 <memset>
80108ba7:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108baa:	83 ec 0c             	sub    $0xc,%esp
80108bad:	68 00 00 00 0e       	push   $0xe000000
80108bb2:	e8 0d fa ff ff       	call   801085c4 <p2v>
80108bb7:	83 c4 10             	add    $0x10,%esp
80108bba:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108bbf:	76 0d                	jbe    80108bce <setupkvm+0x58>
    panic("PHYSTOP too high");
80108bc1:	83 ec 0c             	sub    $0xc,%esp
80108bc4:	68 9e 9a 10 80       	push   $0x80109a9e
80108bc9:	e8 98 79 ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108bce:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
80108bd5:	eb 40                	jmp    80108c17 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bda:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108be0:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108be6:	8b 58 08             	mov    0x8(%eax),%ebx
80108be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bec:	8b 40 04             	mov    0x4(%eax),%eax
80108bef:	29 c3                	sub    %eax,%ebx
80108bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bf4:	8b 00                	mov    (%eax),%eax
80108bf6:	83 ec 0c             	sub    $0xc,%esp
80108bf9:	51                   	push   %ecx
80108bfa:	52                   	push   %edx
80108bfb:	53                   	push   %ebx
80108bfc:	50                   	push   %eax
80108bfd:	ff 75 f0             	pushl  -0x10(%ebp)
80108c00:	e8 e1 fe ff ff       	call   80108ae6 <mappages>
80108c05:	83 c4 20             	add    $0x20,%esp
80108c08:	85 c0                	test   %eax,%eax
80108c0a:	79 07                	jns    80108c13 <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108c0c:	b8 00 00 00 00       	mov    $0x0,%eax
80108c11:	eb 10                	jmp    80108c23 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108c13:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108c17:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
80108c1e:	72 b7                	jb     80108bd7 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108c20:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108c23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108c26:	c9                   	leave  
80108c27:	c3                   	ret    

80108c28 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108c28:	55                   	push   %ebp
80108c29:	89 e5                	mov    %esp,%ebp
80108c2b:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108c2e:	e8 43 ff ff ff       	call   80108b76 <setupkvm>
80108c33:	a3 58 67 11 80       	mov    %eax,0x80116758
  switchkvm();
80108c38:	e8 03 00 00 00       	call   80108c40 <switchkvm>
}
80108c3d:	90                   	nop
80108c3e:	c9                   	leave  
80108c3f:	c3                   	ret    

80108c40 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108c40:	55                   	push   %ebp
80108c41:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108c43:	a1 58 67 11 80       	mov    0x80116758,%eax
80108c48:	50                   	push   %eax
80108c49:	e8 69 f9 ff ff       	call   801085b7 <v2p>
80108c4e:	83 c4 04             	add    $0x4,%esp
80108c51:	50                   	push   %eax
80108c52:	e8 54 f9 ff ff       	call   801085ab <lcr3>
80108c57:	83 c4 04             	add    $0x4,%esp
}
80108c5a:	90                   	nop
80108c5b:	c9                   	leave  
80108c5c:	c3                   	ret    

80108c5d <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108c5d:	55                   	push   %ebp
80108c5e:	89 e5                	mov    %esp,%ebp
80108c60:	56                   	push   %esi
80108c61:	53                   	push   %ebx
  pushcli();
80108c62:	e8 19 d2 ff ff       	call   80105e80 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108c67:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108c6d:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108c74:	83 c2 08             	add    $0x8,%edx
80108c77:	89 d6                	mov    %edx,%esi
80108c79:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108c80:	83 c2 08             	add    $0x8,%edx
80108c83:	c1 ea 10             	shr    $0x10,%edx
80108c86:	89 d3                	mov    %edx,%ebx
80108c88:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108c8f:	83 c2 08             	add    $0x8,%edx
80108c92:	c1 ea 18             	shr    $0x18,%edx
80108c95:	89 d1                	mov    %edx,%ecx
80108c97:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108c9e:	67 00 
80108ca0:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108ca7:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108cad:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108cb4:	83 e2 f0             	and    $0xfffffff0,%edx
80108cb7:	83 ca 09             	or     $0x9,%edx
80108cba:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108cc0:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108cc7:	83 ca 10             	or     $0x10,%edx
80108cca:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108cd0:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108cd7:	83 e2 9f             	and    $0xffffff9f,%edx
80108cda:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108ce0:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108ce7:	83 ca 80             	or     $0xffffff80,%edx
80108cea:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108cf0:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108cf7:	83 e2 f0             	and    $0xfffffff0,%edx
80108cfa:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108d00:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108d07:	83 e2 ef             	and    $0xffffffef,%edx
80108d0a:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108d10:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108d17:	83 e2 df             	and    $0xffffffdf,%edx
80108d1a:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108d20:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108d27:	83 ca 40             	or     $0x40,%edx
80108d2a:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108d30:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108d37:	83 e2 7f             	and    $0x7f,%edx
80108d3a:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108d40:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108d46:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108d4c:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108d53:	83 e2 ef             	and    $0xffffffef,%edx
80108d56:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108d5c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108d62:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108d68:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108d6e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108d75:	8b 52 08             	mov    0x8(%edx),%edx
80108d78:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108d7e:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108d81:	83 ec 0c             	sub    $0xc,%esp
80108d84:	6a 30                	push   $0x30
80108d86:	e8 f3 f7 ff ff       	call   8010857e <ltr>
80108d8b:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108d8e:	8b 45 08             	mov    0x8(%ebp),%eax
80108d91:	8b 40 04             	mov    0x4(%eax),%eax
80108d94:	85 c0                	test   %eax,%eax
80108d96:	75 0d                	jne    80108da5 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80108d98:	83 ec 0c             	sub    $0xc,%esp
80108d9b:	68 af 9a 10 80       	push   $0x80109aaf
80108da0:	e8 c1 77 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108da5:	8b 45 08             	mov    0x8(%ebp),%eax
80108da8:	8b 40 04             	mov    0x4(%eax),%eax
80108dab:	83 ec 0c             	sub    $0xc,%esp
80108dae:	50                   	push   %eax
80108daf:	e8 03 f8 ff ff       	call   801085b7 <v2p>
80108db4:	83 c4 10             	add    $0x10,%esp
80108db7:	83 ec 0c             	sub    $0xc,%esp
80108dba:	50                   	push   %eax
80108dbb:	e8 eb f7 ff ff       	call   801085ab <lcr3>
80108dc0:	83 c4 10             	add    $0x10,%esp
  popcli();
80108dc3:	e8 fd d0 ff ff       	call   80105ec5 <popcli>
}
80108dc8:	90                   	nop
80108dc9:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108dcc:	5b                   	pop    %ebx
80108dcd:	5e                   	pop    %esi
80108dce:	5d                   	pop    %ebp
80108dcf:	c3                   	ret    

80108dd0 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108dd0:	55                   	push   %ebp
80108dd1:	89 e5                	mov    %esp,%ebp
80108dd3:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108dd6:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108ddd:	76 0d                	jbe    80108dec <inituvm+0x1c>
    panic("inituvm: more than a page");
80108ddf:	83 ec 0c             	sub    $0xc,%esp
80108de2:	68 c3 9a 10 80       	push   $0x80109ac3
80108de7:	e8 7a 77 ff ff       	call   80100566 <panic>
  mem = kalloc();
80108dec:	e8 13 9f ff ff       	call   80102d04 <kalloc>
80108df1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108df4:	83 ec 04             	sub    $0x4,%esp
80108df7:	68 00 10 00 00       	push   $0x1000
80108dfc:	6a 00                	push   $0x0
80108dfe:	ff 75 f4             	pushl  -0xc(%ebp)
80108e01:	e8 80 d1 ff ff       	call   80105f86 <memset>
80108e06:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108e09:	83 ec 0c             	sub    $0xc,%esp
80108e0c:	ff 75 f4             	pushl  -0xc(%ebp)
80108e0f:	e8 a3 f7 ff ff       	call   801085b7 <v2p>
80108e14:	83 c4 10             	add    $0x10,%esp
80108e17:	83 ec 0c             	sub    $0xc,%esp
80108e1a:	6a 06                	push   $0x6
80108e1c:	50                   	push   %eax
80108e1d:	68 00 10 00 00       	push   $0x1000
80108e22:	6a 00                	push   $0x0
80108e24:	ff 75 08             	pushl  0x8(%ebp)
80108e27:	e8 ba fc ff ff       	call   80108ae6 <mappages>
80108e2c:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108e2f:	83 ec 04             	sub    $0x4,%esp
80108e32:	ff 75 10             	pushl  0x10(%ebp)
80108e35:	ff 75 0c             	pushl  0xc(%ebp)
80108e38:	ff 75 f4             	pushl  -0xc(%ebp)
80108e3b:	e8 05 d2 ff ff       	call   80106045 <memmove>
80108e40:	83 c4 10             	add    $0x10,%esp
}
80108e43:	90                   	nop
80108e44:	c9                   	leave  
80108e45:	c3                   	ret    

80108e46 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108e46:	55                   	push   %ebp
80108e47:	89 e5                	mov    %esp,%ebp
80108e49:	53                   	push   %ebx
80108e4a:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108e4d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e50:	25 ff 0f 00 00       	and    $0xfff,%eax
80108e55:	85 c0                	test   %eax,%eax
80108e57:	74 0d                	je     80108e66 <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80108e59:	83 ec 0c             	sub    $0xc,%esp
80108e5c:	68 e0 9a 10 80       	push   $0x80109ae0
80108e61:	e8 00 77 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108e66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108e6d:	e9 95 00 00 00       	jmp    80108f07 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108e72:	8b 55 0c             	mov    0xc(%ebp),%edx
80108e75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e78:	01 d0                	add    %edx,%eax
80108e7a:	83 ec 04             	sub    $0x4,%esp
80108e7d:	6a 00                	push   $0x0
80108e7f:	50                   	push   %eax
80108e80:	ff 75 08             	pushl  0x8(%ebp)
80108e83:	e8 be fb ff ff       	call   80108a46 <walkpgdir>
80108e88:	83 c4 10             	add    $0x10,%esp
80108e8b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108e8e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108e92:	75 0d                	jne    80108ea1 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80108e94:	83 ec 0c             	sub    $0xc,%esp
80108e97:	68 03 9b 10 80       	push   $0x80109b03
80108e9c:	e8 c5 76 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108ea1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ea4:	8b 00                	mov    (%eax),%eax
80108ea6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108eab:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108eae:	8b 45 18             	mov    0x18(%ebp),%eax
80108eb1:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108eb4:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108eb9:	77 0b                	ja     80108ec6 <loaduvm+0x80>
      n = sz - i;
80108ebb:	8b 45 18             	mov    0x18(%ebp),%eax
80108ebe:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108ec1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108ec4:	eb 07                	jmp    80108ecd <loaduvm+0x87>
    else
      n = PGSIZE;
80108ec6:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108ecd:	8b 55 14             	mov    0x14(%ebp),%edx
80108ed0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ed3:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108ed6:	83 ec 0c             	sub    $0xc,%esp
80108ed9:	ff 75 e8             	pushl  -0x18(%ebp)
80108edc:	e8 e3 f6 ff ff       	call   801085c4 <p2v>
80108ee1:	83 c4 10             	add    $0x10,%esp
80108ee4:	ff 75 f0             	pushl  -0x10(%ebp)
80108ee7:	53                   	push   %ebx
80108ee8:	50                   	push   %eax
80108ee9:	ff 75 10             	pushl  0x10(%ebp)
80108eec:	e8 85 90 ff ff       	call   80101f76 <readi>
80108ef1:	83 c4 10             	add    $0x10,%esp
80108ef4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108ef7:	74 07                	je     80108f00 <loaduvm+0xba>
      return -1;
80108ef9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108efe:	eb 18                	jmp    80108f18 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108f00:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108f07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f0a:	3b 45 18             	cmp    0x18(%ebp),%eax
80108f0d:	0f 82 5f ff ff ff    	jb     80108e72 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108f13:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108f18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108f1b:	c9                   	leave  
80108f1c:	c3                   	ret    

80108f1d <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108f1d:	55                   	push   %ebp
80108f1e:	89 e5                	mov    %esp,%ebp
80108f20:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108f23:	8b 45 10             	mov    0x10(%ebp),%eax
80108f26:	85 c0                	test   %eax,%eax
80108f28:	79 0a                	jns    80108f34 <allocuvm+0x17>
    return 0;
80108f2a:	b8 00 00 00 00       	mov    $0x0,%eax
80108f2f:	e9 b0 00 00 00       	jmp    80108fe4 <allocuvm+0xc7>
  if(newsz < oldsz)
80108f34:	8b 45 10             	mov    0x10(%ebp),%eax
80108f37:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108f3a:	73 08                	jae    80108f44 <allocuvm+0x27>
    return oldsz;
80108f3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f3f:	e9 a0 00 00 00       	jmp    80108fe4 <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80108f44:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f47:	05 ff 0f 00 00       	add    $0xfff,%eax
80108f4c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f51:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108f54:	eb 7f                	jmp    80108fd5 <allocuvm+0xb8>
    mem = kalloc();
80108f56:	e8 a9 9d ff ff       	call   80102d04 <kalloc>
80108f5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108f5e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108f62:	75 2b                	jne    80108f8f <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80108f64:	83 ec 0c             	sub    $0xc,%esp
80108f67:	68 21 9b 10 80       	push   $0x80109b21
80108f6c:	e8 55 74 ff ff       	call   801003c6 <cprintf>
80108f71:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108f74:	83 ec 04             	sub    $0x4,%esp
80108f77:	ff 75 0c             	pushl  0xc(%ebp)
80108f7a:	ff 75 10             	pushl  0x10(%ebp)
80108f7d:	ff 75 08             	pushl  0x8(%ebp)
80108f80:	e8 61 00 00 00       	call   80108fe6 <deallocuvm>
80108f85:	83 c4 10             	add    $0x10,%esp
      return 0;
80108f88:	b8 00 00 00 00       	mov    $0x0,%eax
80108f8d:	eb 55                	jmp    80108fe4 <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
80108f8f:	83 ec 04             	sub    $0x4,%esp
80108f92:	68 00 10 00 00       	push   $0x1000
80108f97:	6a 00                	push   $0x0
80108f99:	ff 75 f0             	pushl  -0x10(%ebp)
80108f9c:	e8 e5 cf ff ff       	call   80105f86 <memset>
80108fa1:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108fa4:	83 ec 0c             	sub    $0xc,%esp
80108fa7:	ff 75 f0             	pushl  -0x10(%ebp)
80108faa:	e8 08 f6 ff ff       	call   801085b7 <v2p>
80108faf:	83 c4 10             	add    $0x10,%esp
80108fb2:	89 c2                	mov    %eax,%edx
80108fb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fb7:	83 ec 0c             	sub    $0xc,%esp
80108fba:	6a 06                	push   $0x6
80108fbc:	52                   	push   %edx
80108fbd:	68 00 10 00 00       	push   $0x1000
80108fc2:	50                   	push   %eax
80108fc3:	ff 75 08             	pushl  0x8(%ebp)
80108fc6:	e8 1b fb ff ff       	call   80108ae6 <mappages>
80108fcb:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108fce:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108fd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fd8:	3b 45 10             	cmp    0x10(%ebp),%eax
80108fdb:	0f 82 75 ff ff ff    	jb     80108f56 <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108fe1:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108fe4:	c9                   	leave  
80108fe5:	c3                   	ret    

80108fe6 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108fe6:	55                   	push   %ebp
80108fe7:	89 e5                	mov    %esp,%ebp
80108fe9:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108fec:	8b 45 10             	mov    0x10(%ebp),%eax
80108fef:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108ff2:	72 08                	jb     80108ffc <deallocuvm+0x16>
    return oldsz;
80108ff4:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ff7:	e9 a5 00 00 00       	jmp    801090a1 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80108ffc:	8b 45 10             	mov    0x10(%ebp),%eax
80108fff:	05 ff 0f 00 00       	add    $0xfff,%eax
80109004:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109009:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010900c:	e9 81 00 00 00       	jmp    80109092 <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80109011:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109014:	83 ec 04             	sub    $0x4,%esp
80109017:	6a 00                	push   $0x0
80109019:	50                   	push   %eax
8010901a:	ff 75 08             	pushl  0x8(%ebp)
8010901d:	e8 24 fa ff ff       	call   80108a46 <walkpgdir>
80109022:	83 c4 10             	add    $0x10,%esp
80109025:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80109028:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010902c:	75 09                	jne    80109037 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
8010902e:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80109035:	eb 54                	jmp    8010908b <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
80109037:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010903a:	8b 00                	mov    (%eax),%eax
8010903c:	83 e0 01             	and    $0x1,%eax
8010903f:	85 c0                	test   %eax,%eax
80109041:	74 48                	je     8010908b <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
80109043:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109046:	8b 00                	mov    (%eax),%eax
80109048:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010904d:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80109050:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109054:	75 0d                	jne    80109063 <deallocuvm+0x7d>
        panic("kfree");
80109056:	83 ec 0c             	sub    $0xc,%esp
80109059:	68 39 9b 10 80       	push   $0x80109b39
8010905e:	e8 03 75 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
80109063:	83 ec 0c             	sub    $0xc,%esp
80109066:	ff 75 ec             	pushl  -0x14(%ebp)
80109069:	e8 56 f5 ff ff       	call   801085c4 <p2v>
8010906e:	83 c4 10             	add    $0x10,%esp
80109071:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80109074:	83 ec 0c             	sub    $0xc,%esp
80109077:	ff 75 e8             	pushl  -0x18(%ebp)
8010907a:	e8 e8 9b ff ff       	call   80102c67 <kfree>
8010907f:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80109082:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109085:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
8010908b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109092:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109095:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109098:	0f 82 73 ff ff ff    	jb     80109011 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
8010909e:	8b 45 10             	mov    0x10(%ebp),%eax
}
801090a1:	c9                   	leave  
801090a2:	c3                   	ret    

801090a3 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801090a3:	55                   	push   %ebp
801090a4:	89 e5                	mov    %esp,%ebp
801090a6:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801090a9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801090ad:	75 0d                	jne    801090bc <freevm+0x19>
    panic("freevm: no pgdir");
801090af:	83 ec 0c             	sub    $0xc,%esp
801090b2:	68 3f 9b 10 80       	push   $0x80109b3f
801090b7:	e8 aa 74 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801090bc:	83 ec 04             	sub    $0x4,%esp
801090bf:	6a 00                	push   $0x0
801090c1:	68 00 00 00 80       	push   $0x80000000
801090c6:	ff 75 08             	pushl  0x8(%ebp)
801090c9:	e8 18 ff ff ff       	call   80108fe6 <deallocuvm>
801090ce:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801090d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801090d8:	eb 4f                	jmp    80109129 <freevm+0x86>
    if(pgdir[i] & PTE_P){
801090da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090dd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801090e4:	8b 45 08             	mov    0x8(%ebp),%eax
801090e7:	01 d0                	add    %edx,%eax
801090e9:	8b 00                	mov    (%eax),%eax
801090eb:	83 e0 01             	and    $0x1,%eax
801090ee:	85 c0                	test   %eax,%eax
801090f0:	74 33                	je     80109125 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
801090f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090f5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801090fc:	8b 45 08             	mov    0x8(%ebp),%eax
801090ff:	01 d0                	add    %edx,%eax
80109101:	8b 00                	mov    (%eax),%eax
80109103:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109108:	83 ec 0c             	sub    $0xc,%esp
8010910b:	50                   	push   %eax
8010910c:	e8 b3 f4 ff ff       	call   801085c4 <p2v>
80109111:	83 c4 10             	add    $0x10,%esp
80109114:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80109117:	83 ec 0c             	sub    $0xc,%esp
8010911a:	ff 75 f0             	pushl  -0x10(%ebp)
8010911d:	e8 45 9b ff ff       	call   80102c67 <kfree>
80109122:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80109125:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109129:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80109130:	76 a8                	jbe    801090da <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80109132:	83 ec 0c             	sub    $0xc,%esp
80109135:	ff 75 08             	pushl  0x8(%ebp)
80109138:	e8 2a 9b ff ff       	call   80102c67 <kfree>
8010913d:	83 c4 10             	add    $0x10,%esp
}
80109140:	90                   	nop
80109141:	c9                   	leave  
80109142:	c3                   	ret    

80109143 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80109143:	55                   	push   %ebp
80109144:	89 e5                	mov    %esp,%ebp
80109146:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109149:	83 ec 04             	sub    $0x4,%esp
8010914c:	6a 00                	push   $0x0
8010914e:	ff 75 0c             	pushl  0xc(%ebp)
80109151:	ff 75 08             	pushl  0x8(%ebp)
80109154:	e8 ed f8 ff ff       	call   80108a46 <walkpgdir>
80109159:	83 c4 10             	add    $0x10,%esp
8010915c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010915f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109163:	75 0d                	jne    80109172 <clearpteu+0x2f>
    panic("clearpteu");
80109165:	83 ec 0c             	sub    $0xc,%esp
80109168:	68 50 9b 10 80       	push   $0x80109b50
8010916d:	e8 f4 73 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
80109172:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109175:	8b 00                	mov    (%eax),%eax
80109177:	83 e0 fb             	and    $0xfffffffb,%eax
8010917a:	89 c2                	mov    %eax,%edx
8010917c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010917f:	89 10                	mov    %edx,(%eax)
}
80109181:	90                   	nop
80109182:	c9                   	leave  
80109183:	c3                   	ret    

80109184 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80109184:	55                   	push   %ebp
80109185:	89 e5                	mov    %esp,%ebp
80109187:	53                   	push   %ebx
80109188:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010918b:	e8 e6 f9 ff ff       	call   80108b76 <setupkvm>
80109190:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109193:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109197:	75 0a                	jne    801091a3 <copyuvm+0x1f>
    return 0;
80109199:	b8 00 00 00 00       	mov    $0x0,%eax
8010919e:	e9 f8 00 00 00       	jmp    8010929b <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
801091a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801091aa:	e9 c4 00 00 00       	jmp    80109273 <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801091af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091b2:	83 ec 04             	sub    $0x4,%esp
801091b5:	6a 00                	push   $0x0
801091b7:	50                   	push   %eax
801091b8:	ff 75 08             	pushl  0x8(%ebp)
801091bb:	e8 86 f8 ff ff       	call   80108a46 <walkpgdir>
801091c0:	83 c4 10             	add    $0x10,%esp
801091c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
801091c6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801091ca:	75 0d                	jne    801091d9 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
801091cc:	83 ec 0c             	sub    $0xc,%esp
801091cf:	68 5a 9b 10 80       	push   $0x80109b5a
801091d4:	e8 8d 73 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
801091d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091dc:	8b 00                	mov    (%eax),%eax
801091de:	83 e0 01             	and    $0x1,%eax
801091e1:	85 c0                	test   %eax,%eax
801091e3:	75 0d                	jne    801091f2 <copyuvm+0x6e>
      panic("copyuvm: page not present");
801091e5:	83 ec 0c             	sub    $0xc,%esp
801091e8:	68 74 9b 10 80       	push   $0x80109b74
801091ed:	e8 74 73 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
801091f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091f5:	8b 00                	mov    (%eax),%eax
801091f7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801091fc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801091ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109202:	8b 00                	mov    (%eax),%eax
80109204:	25 ff 0f 00 00       	and    $0xfff,%eax
80109209:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010920c:	e8 f3 9a ff ff       	call   80102d04 <kalloc>
80109211:	89 45 e0             	mov    %eax,-0x20(%ebp)
80109214:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80109218:	74 6a                	je     80109284 <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
8010921a:	83 ec 0c             	sub    $0xc,%esp
8010921d:	ff 75 e8             	pushl  -0x18(%ebp)
80109220:	e8 9f f3 ff ff       	call   801085c4 <p2v>
80109225:	83 c4 10             	add    $0x10,%esp
80109228:	83 ec 04             	sub    $0x4,%esp
8010922b:	68 00 10 00 00       	push   $0x1000
80109230:	50                   	push   %eax
80109231:	ff 75 e0             	pushl  -0x20(%ebp)
80109234:	e8 0c ce ff ff       	call   80106045 <memmove>
80109239:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
8010923c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010923f:	83 ec 0c             	sub    $0xc,%esp
80109242:	ff 75 e0             	pushl  -0x20(%ebp)
80109245:	e8 6d f3 ff ff       	call   801085b7 <v2p>
8010924a:	83 c4 10             	add    $0x10,%esp
8010924d:	89 c2                	mov    %eax,%edx
8010924f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109252:	83 ec 0c             	sub    $0xc,%esp
80109255:	53                   	push   %ebx
80109256:	52                   	push   %edx
80109257:	68 00 10 00 00       	push   $0x1000
8010925c:	50                   	push   %eax
8010925d:	ff 75 f0             	pushl  -0x10(%ebp)
80109260:	e8 81 f8 ff ff       	call   80108ae6 <mappages>
80109265:	83 c4 20             	add    $0x20,%esp
80109268:	85 c0                	test   %eax,%eax
8010926a:	78 1b                	js     80109287 <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010926c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109273:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109276:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109279:	0f 82 30 ff ff ff    	jb     801091af <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
8010927f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109282:	eb 17                	jmp    8010929b <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80109284:	90                   	nop
80109285:	eb 01                	jmp    80109288 <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
80109287:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80109288:	83 ec 0c             	sub    $0xc,%esp
8010928b:	ff 75 f0             	pushl  -0x10(%ebp)
8010928e:	e8 10 fe ff ff       	call   801090a3 <freevm>
80109293:	83 c4 10             	add    $0x10,%esp
  return 0;
80109296:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010929b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010929e:	c9                   	leave  
8010929f:	c3                   	ret    

801092a0 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801092a0:	55                   	push   %ebp
801092a1:	89 e5                	mov    %esp,%ebp
801092a3:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801092a6:	83 ec 04             	sub    $0x4,%esp
801092a9:	6a 00                	push   $0x0
801092ab:	ff 75 0c             	pushl  0xc(%ebp)
801092ae:	ff 75 08             	pushl  0x8(%ebp)
801092b1:	e8 90 f7 ff ff       	call   80108a46 <walkpgdir>
801092b6:	83 c4 10             	add    $0x10,%esp
801092b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801092bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092bf:	8b 00                	mov    (%eax),%eax
801092c1:	83 e0 01             	and    $0x1,%eax
801092c4:	85 c0                	test   %eax,%eax
801092c6:	75 07                	jne    801092cf <uva2ka+0x2f>
    return 0;
801092c8:	b8 00 00 00 00       	mov    $0x0,%eax
801092cd:	eb 29                	jmp    801092f8 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
801092cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092d2:	8b 00                	mov    (%eax),%eax
801092d4:	83 e0 04             	and    $0x4,%eax
801092d7:	85 c0                	test   %eax,%eax
801092d9:	75 07                	jne    801092e2 <uva2ka+0x42>
    return 0;
801092db:	b8 00 00 00 00       	mov    $0x0,%eax
801092e0:	eb 16                	jmp    801092f8 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
801092e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092e5:	8b 00                	mov    (%eax),%eax
801092e7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801092ec:	83 ec 0c             	sub    $0xc,%esp
801092ef:	50                   	push   %eax
801092f0:	e8 cf f2 ff ff       	call   801085c4 <p2v>
801092f5:	83 c4 10             	add    $0x10,%esp
}
801092f8:	c9                   	leave  
801092f9:	c3                   	ret    

801092fa <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801092fa:	55                   	push   %ebp
801092fb:	89 e5                	mov    %esp,%ebp
801092fd:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80109300:	8b 45 10             	mov    0x10(%ebp),%eax
80109303:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80109306:	eb 7f                	jmp    80109387 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80109308:	8b 45 0c             	mov    0xc(%ebp),%eax
8010930b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109310:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80109313:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109316:	83 ec 08             	sub    $0x8,%esp
80109319:	50                   	push   %eax
8010931a:	ff 75 08             	pushl  0x8(%ebp)
8010931d:	e8 7e ff ff ff       	call   801092a0 <uva2ka>
80109322:	83 c4 10             	add    $0x10,%esp
80109325:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80109328:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010932c:	75 07                	jne    80109335 <copyout+0x3b>
      return -1;
8010932e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109333:	eb 61                	jmp    80109396 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80109335:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109338:	2b 45 0c             	sub    0xc(%ebp),%eax
8010933b:	05 00 10 00 00       	add    $0x1000,%eax
80109340:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80109343:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109346:	3b 45 14             	cmp    0x14(%ebp),%eax
80109349:	76 06                	jbe    80109351 <copyout+0x57>
      n = len;
8010934b:	8b 45 14             	mov    0x14(%ebp),%eax
8010934e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80109351:	8b 45 0c             	mov    0xc(%ebp),%eax
80109354:	2b 45 ec             	sub    -0x14(%ebp),%eax
80109357:	89 c2                	mov    %eax,%edx
80109359:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010935c:	01 d0                	add    %edx,%eax
8010935e:	83 ec 04             	sub    $0x4,%esp
80109361:	ff 75 f0             	pushl  -0x10(%ebp)
80109364:	ff 75 f4             	pushl  -0xc(%ebp)
80109367:	50                   	push   %eax
80109368:	e8 d8 cc ff ff       	call   80106045 <memmove>
8010936d:	83 c4 10             	add    $0x10,%esp
    len -= n;
80109370:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109373:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80109376:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109379:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010937c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010937f:	05 00 10 00 00       	add    $0x1000,%eax
80109384:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80109387:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010938b:	0f 85 77 ff ff ff    	jne    80109308 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80109391:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109396:	c9                   	leave  
80109397:	c3                   	ret    


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
80100015:	b8 00 c0 10 00       	mov    $0x10c000,%eax
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
80100028:	bc 70 e6 10 80       	mov    $0x8010e670,%esp

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
8010003d:	68 30 9f 10 80       	push   $0x80109f30
80100042:	68 80 e6 10 80       	push   $0x8010e680
80100047:	e8 f7 67 00 00       	call   80106843 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 90 25 11 80 84 	movl   $0x80112584,0x80112590
80100056:	25 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 94 25 11 80 84 	movl   $0x80112584,0x80112594
80100060:	25 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 b4 e6 10 80 	movl   $0x8010e6b4,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 94 25 11 80    	mov    0x80112594,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c 84 25 11 80 	movl   $0x80112584,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 94 25 11 80       	mov    0x80112594,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 94 25 11 80       	mov    %eax,0x80112594

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 84 25 11 80       	mov    $0x80112584,%eax
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
801000bc:	68 80 e6 10 80       	push   $0x8010e680
801000c1:	e8 9f 67 00 00       	call   80106865 <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c9:	a1 94 25 11 80       	mov    0x80112594,%eax
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
80100107:	68 80 e6 10 80       	push   $0x8010e680
8010010c:	e8 bb 67 00 00       	call   801068cc <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 80 e6 10 80       	push   $0x8010e680
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 94 54 00 00       	call   801055c0 <sleep>
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
8010013a:	81 7d f4 84 25 11 80 	cmpl   $0x80112584,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100143:	a1 90 25 11 80       	mov    0x80112590,%eax
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
80100183:	68 80 e6 10 80       	push   $0x8010e680
80100188:	e8 3f 67 00 00       	call   801068cc <release>
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
8010019e:	81 7d f4 84 25 11 80 	cmpl   $0x80112584,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 37 9f 10 80       	push   $0x80109f37
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
80100204:	68 48 9f 10 80       	push   $0x80109f48
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
80100243:	68 4f 9f 10 80       	push   $0x80109f4f
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 80 e6 10 80       	push   $0x8010e680
80100255:	e8 0b 66 00 00       	call   80106865 <acquire>
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
8010027b:	8b 15 94 25 11 80    	mov    0x80112594,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c 84 25 11 80 	movl   $0x80112584,0xc(%eax)
  bcache.head.next->prev = b;
80100291:	a1 94 25 11 80       	mov    0x80112594,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 94 25 11 80       	mov    %eax,0x80112594

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
801002b9:	e8 78 55 00 00       	call   80105836 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 80 e6 10 80       	push   $0x8010e680
801002c9:	e8 fe 65 00 00       	call   801068cc <release>
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
80100365:	0f b6 80 04 b0 10 80 	movzbl -0x7fef4ffc(%eax),%eax
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
801003cc:	a1 14 d6 10 80       	mov    0x8010d614,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 e0 d5 10 80       	push   $0x8010d5e0
801003e2:	e8 7e 64 00 00       	call   80106865 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 56 9f 10 80       	push   $0x80109f56
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
801004cd:	c7 45 ec 5f 9f 10 80 	movl   $0x80109f5f,-0x14(%ebp)
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
80100556:	68 e0 d5 10 80       	push   $0x8010d5e0
8010055b:	e8 6c 63 00 00       	call   801068cc <release>
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
80100571:	c7 05 14 d6 10 80 00 	movl   $0x0,0x8010d614
80100578:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010057b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f b6 c0             	movzbl %al,%eax
80100587:	83 ec 08             	sub    $0x8,%esp
8010058a:	50                   	push   %eax
8010058b:	68 66 9f 10 80       	push   $0x80109f66
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
801005aa:	68 75 9f 10 80       	push   $0x80109f75
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 57 63 00 00       	call   8010691e <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 77 9f 10 80       	push   $0x80109f77
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
801005f5:	c7 05 c0 d5 10 80 01 	movl   $0x1,0x8010d5c0
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
80100699:	8b 0d 00 b0 10 80    	mov    0x8010b000,%ecx
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
801006ca:	68 7b 9f 10 80       	push   $0x80109f7b
801006cf:	e8 92 fe ff ff       	call   80100566 <panic>

  if((pos/80) >= 24){  // Scroll up.
801006d4:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006db:	7e 4c                	jle    80100729 <cgaputc+0x128>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006dd:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801006e2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006e8:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801006ed:	83 ec 04             	sub    $0x4,%esp
801006f0:	68 60 0e 00 00       	push   $0xe60
801006f5:	52                   	push   %edx
801006f6:	50                   	push   %eax
801006f7:	e8 8b 64 00 00       	call   80106b87 <memmove>
801006fc:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801006ff:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100703:	b8 80 07 00 00       	mov    $0x780,%eax
80100708:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010070b:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010070e:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100713:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100716:	01 c9                	add    %ecx,%ecx
80100718:	01 c8                	add    %ecx,%eax
8010071a:	83 ec 04             	sub    $0x4,%esp
8010071d:	52                   	push   %edx
8010071e:	6a 00                	push   $0x0
80100720:	50                   	push   %eax
80100721:	e8 a2 63 00 00       	call   80106ac8 <memset>
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
8010077e:	a1 00 b0 10 80       	mov    0x8010b000,%eax
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
80100798:	a1 c0 d5 10 80       	mov    0x8010d5c0,%eax
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
801007b6:	e8 fc 7d 00 00       	call   801085b7 <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 ef 7d 00 00       	call   801085b7 <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 e2 7d 00 00       	call   801085b7 <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 d2 7d 00 00       	call   801085b7 <uartputc>
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
80100825:	68 e0 d5 10 80       	push   $0x8010d5e0
8010082a:	e8 36 60 00 00       	call   80106865 <acquire>
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
801008bf:	a1 28 28 11 80       	mov    0x80112828,%eax
801008c4:	83 e8 01             	sub    $0x1,%eax
801008c7:	a3 28 28 11 80       	mov    %eax,0x80112828
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
801008dc:	8b 15 28 28 11 80    	mov    0x80112828,%edx
801008e2:	a1 24 28 11 80       	mov    0x80112824,%eax
801008e7:	39 c2                	cmp    %eax,%edx
801008e9:	0f 84 e2 00 00 00    	je     801009d1 <consoleintr+0x1d8>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008ef:	a1 28 28 11 80       	mov    0x80112828,%eax
801008f4:	83 e8 01             	sub    $0x1,%eax
801008f7:	83 e0 7f             	and    $0x7f,%eax
801008fa:	0f b6 80 a0 27 11 80 	movzbl -0x7feed860(%eax),%eax
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
8010090a:	8b 15 28 28 11 80    	mov    0x80112828,%edx
80100910:	a1 24 28 11 80       	mov    0x80112824,%eax
80100915:	39 c2                	cmp    %eax,%edx
80100917:	0f 84 b4 00 00 00    	je     801009d1 <consoleintr+0x1d8>
        input.e--;
8010091d:	a1 28 28 11 80       	mov    0x80112828,%eax
80100922:	83 e8 01             	sub    $0x1,%eax
80100925:	a3 28 28 11 80       	mov    %eax,0x80112828
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
80100949:	8b 15 28 28 11 80    	mov    0x80112828,%edx
8010094f:	a1 20 28 11 80       	mov    0x80112820,%eax
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
80100970:	a1 28 28 11 80       	mov    0x80112828,%eax
80100975:	8d 50 01             	lea    0x1(%eax),%edx
80100978:	89 15 28 28 11 80    	mov    %edx,0x80112828
8010097e:	83 e0 7f             	and    $0x7f,%eax
80100981:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100984:	88 90 a0 27 11 80    	mov    %dl,-0x7feed860(%eax)
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
801009a4:	a1 28 28 11 80       	mov    0x80112828,%eax
801009a9:	8b 15 20 28 11 80    	mov    0x80112820,%edx
801009af:	83 ea 80             	sub    $0xffffff80,%edx
801009b2:	39 d0                	cmp    %edx,%eax
801009b4:	75 1a                	jne    801009d0 <consoleintr+0x1d7>
          input.w = input.e;
801009b6:	a1 28 28 11 80       	mov    0x80112828,%eax
801009bb:	a3 24 28 11 80       	mov    %eax,0x80112824
          wakeup(&input.r);
801009c0:	83 ec 0c             	sub    $0xc,%esp
801009c3:	68 20 28 11 80       	push   $0x80112820
801009c8:	e8 69 4e 00 00       	call   80105836 <wakeup>
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
801009e6:	68 e0 d5 10 80       	push   $0x8010d5e0
801009eb:	e8 dc 5e 00 00       	call   801068cc <release>
801009f0:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009f7:	74 05                	je     801009fe <consoleintr+0x205>
    procdump();  // now call procdump() wo. cons.lock held
801009f9:	e8 64 50 00 00       	call   80105a62 <procdump>
  }
#ifdef CS333_P3P4
  if(dopids) {
801009fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100a02:	74 05                	je     80100a09 <consoleintr+0x210>
    piddump();
80100a04:	e8 58 57 00 00       	call   80106161 <piddump>
  }
  if(dofree) {
80100a09:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100a0d:	74 05                	je     80100a14 <consoleintr+0x21b>
    freedump();
80100a0f:	e8 37 58 00 00       	call   8010624b <freedump>
  }
  if(dosleep) {
80100a14:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100a18:	74 05                	je     80100a1f <consoleintr+0x226>
    sleepdump();
80100a1a:	e8 8f 58 00 00       	call   801062ae <sleepdump>
  }
  if(dozombie) {
80100a1f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a23:	74 05                	je     80100a2a <consoleintr+0x231>
    zombiedump();
80100a25:	e8 1d 59 00 00       	call   80106347 <zombiedump>
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
80100a4a:	68 e0 d5 10 80       	push   $0x8010d5e0
80100a4f:	e8 11 5e 00 00       	call   80106865 <acquire>
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
80100a6c:	68 e0 d5 10 80       	push   $0x8010d5e0
80100a71:	e8 56 5e 00 00       	call   801068cc <release>
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
80100a94:	68 e0 d5 10 80       	push   $0x8010d5e0
80100a99:	68 20 28 11 80       	push   $0x80112820
80100a9e:	e8 1d 4b 00 00       	call   801055c0 <sleep>
80100aa3:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100aa6:	8b 15 20 28 11 80    	mov    0x80112820,%edx
80100aac:	a1 24 28 11 80       	mov    0x80112824,%eax
80100ab1:	39 c2                	cmp    %eax,%edx
80100ab3:	74 a7                	je     80100a5c <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100ab5:	a1 20 28 11 80       	mov    0x80112820,%eax
80100aba:	8d 50 01             	lea    0x1(%eax),%edx
80100abd:	89 15 20 28 11 80    	mov    %edx,0x80112820
80100ac3:	83 e0 7f             	and    $0x7f,%eax
80100ac6:	0f b6 80 a0 27 11 80 	movzbl -0x7feed860(%eax),%eax
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
80100ae1:	a1 20 28 11 80       	mov    0x80112820,%eax
80100ae6:	83 e8 01             	sub    $0x1,%eax
80100ae9:	a3 20 28 11 80       	mov    %eax,0x80112820
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
80100b17:	68 e0 d5 10 80       	push   $0x8010d5e0
80100b1c:	e8 ab 5d 00 00       	call   801068cc <release>
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
80100b55:	68 e0 d5 10 80       	push   $0x8010d5e0
80100b5a:	e8 06 5d 00 00       	call   80106865 <acquire>
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
80100b97:	68 e0 d5 10 80       	push   $0x8010d5e0
80100b9c:	e8 2b 5d 00 00       	call   801068cc <release>
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
80100bc0:	68 8e 9f 10 80       	push   $0x80109f8e
80100bc5:	68 e0 d5 10 80       	push   $0x8010d5e0
80100bca:	e8 74 5c 00 00       	call   80106843 <initlock>
80100bcf:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100bd2:	c7 05 ec 31 11 80 3e 	movl   $0x80100b3e,0x801131ec
80100bd9:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100bdc:	c7 05 e8 31 11 80 2d 	movl   $0x80100a2d,0x801131e8
80100be3:	0a 10 80 
  cons.locking = 1;
80100be6:	c7 05 14 d6 10 80 01 	movl   $0x1,0x8010d614
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
80100c88:	e8 7f 8a 00 00       	call   8010970c <setupkvm>
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
80100d0e:	e8 a0 8d 00 00       	call   80109ab3 <allocuvm>
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
80100d41:	e8 96 8c 00 00       	call   801099dc <loaduvm>
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
80100db0:	e8 fe 8c 00 00       	call   80109ab3 <allocuvm>
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
80100dd4:	e8 00 8f 00 00       	call   80109cd9 <clearpteu>
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
80100e0d:	e8 03 5f 00 00       	call   80106d15 <strlen>
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
80100e3a:	e8 d6 5e 00 00       	call   80106d15 <strlen>
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
80100e60:	e8 2b 90 00 00       	call   80109e90 <copyout>
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
80100efc:	e8 8f 8f 00 00       	call   80109e90 <copyout>
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
80100f4d:	e8 79 5d 00 00       	call   80106ccb <safestrcpy>
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
80100fa3:	e8 4b 88 00 00       	call   801097f3 <switchuvm>
80100fa8:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100fab:	83 ec 0c             	sub    $0xc,%esp
80100fae:	ff 75 d0             	pushl  -0x30(%ebp)
80100fb1:	e8 83 8c 00 00       	call   80109c39 <freevm>
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
80100feb:	e8 49 8c 00 00       	call   80109c39 <freevm>
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
8010101c:	68 96 9f 10 80       	push   $0x80109f96
80101021:	68 40 28 11 80       	push   $0x80112840
80101026:	e8 18 58 00 00       	call   80106843 <initlock>
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
8010103a:	68 40 28 11 80       	push   $0x80112840
8010103f:	e8 21 58 00 00       	call   80106865 <acquire>
80101044:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101047:	c7 45 f4 74 28 11 80 	movl   $0x80112874,-0xc(%ebp)
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
80101067:	68 40 28 11 80       	push   $0x80112840
8010106c:	e8 5b 58 00 00       	call   801068cc <release>
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
8010107d:	b8 d4 31 11 80       	mov    $0x801131d4,%eax
80101082:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101085:	72 c9                	jb     80101050 <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80101087:	83 ec 0c             	sub    $0xc,%esp
8010108a:	68 40 28 11 80       	push   $0x80112840
8010108f:	e8 38 58 00 00       	call   801068cc <release>
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
801010a7:	68 40 28 11 80       	push   $0x80112840
801010ac:	e8 b4 57 00 00       	call   80106865 <acquire>
801010b1:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b4:	8b 45 08             	mov    0x8(%ebp),%eax
801010b7:	8b 40 04             	mov    0x4(%eax),%eax
801010ba:	85 c0                	test   %eax,%eax
801010bc:	7f 0d                	jg     801010cb <filedup+0x2d>
    panic("filedup");
801010be:	83 ec 0c             	sub    $0xc,%esp
801010c1:	68 9d 9f 10 80       	push   $0x80109f9d
801010c6:	e8 9b f4 ff ff       	call   80100566 <panic>
  f->ref++;
801010cb:	8b 45 08             	mov    0x8(%ebp),%eax
801010ce:	8b 40 04             	mov    0x4(%eax),%eax
801010d1:	8d 50 01             	lea    0x1(%eax),%edx
801010d4:	8b 45 08             	mov    0x8(%ebp),%eax
801010d7:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010da:	83 ec 0c             	sub    $0xc,%esp
801010dd:	68 40 28 11 80       	push   $0x80112840
801010e2:	e8 e5 57 00 00       	call   801068cc <release>
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
801010f8:	68 40 28 11 80       	push   $0x80112840
801010fd:	e8 63 57 00 00       	call   80106865 <acquire>
80101102:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101105:	8b 45 08             	mov    0x8(%ebp),%eax
80101108:	8b 40 04             	mov    0x4(%eax),%eax
8010110b:	85 c0                	test   %eax,%eax
8010110d:	7f 0d                	jg     8010111c <fileclose+0x2d>
    panic("fileclose");
8010110f:	83 ec 0c             	sub    $0xc,%esp
80101112:	68 a5 9f 10 80       	push   $0x80109fa5
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
80101138:	68 40 28 11 80       	push   $0x80112840
8010113d:	e8 8a 57 00 00       	call   801068cc <release>
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
80101186:	68 40 28 11 80       	push   $0x80112840
8010118b:	e8 3c 57 00 00       	call   801068cc <release>
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
801012da:	68 af 9f 10 80       	push   $0x80109faf
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
801013dd:	68 b8 9f 10 80       	push   $0x80109fb8
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
80101413:	68 c8 9f 10 80       	push   $0x80109fc8
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
8010144b:	e8 37 57 00 00       	call   80106b87 <memmove>
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
80101491:	e8 32 56 00 00       	call   80106ac8 <memset>
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
801014e4:	a1 58 32 11 80       	mov    0x80113258,%eax
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
801015c2:	a1 40 32 11 80       	mov    0x80113240,%eax
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
801015e4:	8b 15 40 32 11 80    	mov    0x80113240,%edx
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
801015f8:	68 d4 9f 10 80       	push   $0x80109fd4
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
8010160d:	68 40 32 11 80       	push   $0x80113240
80101612:	ff 75 08             	pushl  0x8(%ebp)
80101615:	e8 08 fe ff ff       	call   80101422 <readsb>
8010161a:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
8010161d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101620:	c1 e8 0c             	shr    $0xc,%eax
80101623:	89 c2                	mov    %eax,%edx
80101625:	a1 58 32 11 80       	mov    0x80113258,%eax
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
8010168b:	68 ea 9f 10 80       	push   $0x80109fea
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
801016e8:	68 fd 9f 10 80       	push   $0x80109ffd
801016ed:	68 60 32 11 80       	push   $0x80113260
801016f2:	e8 4c 51 00 00       	call   80106843 <initlock>
801016f7:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
801016fa:	83 ec 08             	sub    $0x8,%esp
801016fd:	68 40 32 11 80       	push   $0x80113240
80101702:	ff 75 08             	pushl  0x8(%ebp)
80101705:	e8 18 fd ff ff       	call   80101422 <readsb>
8010170a:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
8010170d:	a1 58 32 11 80       	mov    0x80113258,%eax
80101712:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101715:	8b 3d 54 32 11 80    	mov    0x80113254,%edi
8010171b:	8b 35 50 32 11 80    	mov    0x80113250,%esi
80101721:	8b 1d 4c 32 11 80    	mov    0x8011324c,%ebx
80101727:	8b 0d 48 32 11 80    	mov    0x80113248,%ecx
8010172d:	8b 15 44 32 11 80    	mov    0x80113244,%edx
80101733:	a1 40 32 11 80       	mov    0x80113240,%eax
80101738:	ff 75 e4             	pushl  -0x1c(%ebp)
8010173b:	57                   	push   %edi
8010173c:	56                   	push   %esi
8010173d:	53                   	push   %ebx
8010173e:	51                   	push   %ecx
8010173f:	52                   	push   %edx
80101740:	50                   	push   %eax
80101741:	68 04 a0 10 80       	push   $0x8010a004
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
80101778:	a1 54 32 11 80       	mov    0x80113254,%eax
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
801017ba:	e8 09 53 00 00       	call   80106ac8 <memset>
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
8010180e:	8b 15 48 32 11 80    	mov    0x80113248,%edx
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
80101822:	68 57 a0 10 80       	push   $0x8010a057
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
8010183f:	a1 54 32 11 80       	mov    0x80113254,%eax
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
801018c8:	e8 ba 52 00 00       	call   80106b87 <memmove>
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
801018f8:	68 60 32 11 80       	push   $0x80113260
801018fd:	e8 63 4f 00 00       	call   80106865 <acquire>
80101902:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101905:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010190c:	c7 45 f4 94 32 11 80 	movl   $0x80113294,-0xc(%ebp)
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
80101946:	68 60 32 11 80       	push   $0x80113260
8010194b:	e8 7c 4f 00 00       	call   801068cc <release>
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
80101972:	81 7d f4 34 42 11 80 	cmpl   $0x80114234,-0xc(%ebp)
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
80101984:	68 69 a0 10 80       	push   $0x8010a069
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
801019bc:	68 60 32 11 80       	push   $0x80113260
801019c1:	e8 06 4f 00 00       	call   801068cc <release>
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
801019d7:	68 60 32 11 80       	push   $0x80113260
801019dc:	e8 84 4e 00 00       	call   80106865 <acquire>
801019e1:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019e4:	8b 45 08             	mov    0x8(%ebp),%eax
801019e7:	8b 40 08             	mov    0x8(%eax),%eax
801019ea:	8d 50 01             	lea    0x1(%eax),%edx
801019ed:	8b 45 08             	mov    0x8(%ebp),%eax
801019f0:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019f3:	83 ec 0c             	sub    $0xc,%esp
801019f6:	68 60 32 11 80       	push   $0x80113260
801019fb:	e8 cc 4e 00 00       	call   801068cc <release>
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
80101a21:	68 79 a0 10 80       	push   $0x8010a079
80101a26:	e8 3b eb ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101a2b:	83 ec 0c             	sub    $0xc,%esp
80101a2e:	68 60 32 11 80       	push   $0x80113260
80101a33:	e8 2d 4e 00 00       	call   80106865 <acquire>
80101a38:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
80101a3b:	eb 13                	jmp    80101a50 <ilock+0x48>
    sleep(ip, &icache.lock);
80101a3d:	83 ec 08             	sub    $0x8,%esp
80101a40:	68 60 32 11 80       	push   $0x80113260
80101a45:	ff 75 08             	pushl  0x8(%ebp)
80101a48:	e8 73 3b 00 00       	call   801055c0 <sleep>
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
80101a71:	68 60 32 11 80       	push   $0x80113260
80101a76:	e8 51 4e 00 00       	call   801068cc <release>
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
80101a9a:	a1 54 32 11 80       	mov    0x80113254,%eax
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
80101b23:	e8 5f 50 00 00       	call   80106b87 <memmove>
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
80101b59:	68 7f a0 10 80       	push   $0x8010a07f
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
80101b8c:	68 8e a0 10 80       	push   $0x8010a08e
80101b91:	e8 d0 e9 ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101b96:	83 ec 0c             	sub    $0xc,%esp
80101b99:	68 60 32 11 80       	push   $0x80113260
80101b9e:	e8 c2 4c 00 00       	call   80106865 <acquire>
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
80101bbd:	e8 74 3c 00 00       	call   80105836 <wakeup>
80101bc2:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101bc5:	83 ec 0c             	sub    $0xc,%esp
80101bc8:	68 60 32 11 80       	push   $0x80113260
80101bcd:	e8 fa 4c 00 00       	call   801068cc <release>
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
80101be1:	68 60 32 11 80       	push   $0x80113260
80101be6:	e8 7a 4c 00 00       	call   80106865 <acquire>
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
80101c2e:	68 96 a0 10 80       	push   $0x8010a096
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
80101c4c:	68 60 32 11 80       	push   $0x80113260
80101c51:	e8 76 4c 00 00       	call   801068cc <release>
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
80101c81:	68 60 32 11 80       	push   $0x80113260
80101c86:	e8 da 4b 00 00       	call   80106865 <acquire>
80101c8b:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101c8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c91:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101c98:	83 ec 0c             	sub    $0xc,%esp
80101c9b:	ff 75 08             	pushl  0x8(%ebp)
80101c9e:	e8 93 3b 00 00       	call   80105836 <wakeup>
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
80101cb8:	68 60 32 11 80       	push   $0x80113260
80101cbd:	e8 0a 4c 00 00       	call   801068cc <release>
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
80101dfd:	68 a0 a0 10 80       	push   $0x8010a0a0
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
80101faa:	8b 04 c5 e0 31 11 80 	mov    -0x7feece20(,%eax,8),%eax
80101fb1:	85 c0                	test   %eax,%eax
80101fb3:	75 0a                	jne    80101fbf <readi+0x49>
      return -1;
80101fb5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fba:	e9 0c 01 00 00       	jmp    801020cb <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80101fbf:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc2:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fc6:	98                   	cwtl   
80101fc7:	8b 04 c5 e0 31 11 80 	mov    -0x7feece20(,%eax,8),%eax
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
80102094:	e8 ee 4a 00 00       	call   80106b87 <memmove>
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
80102101:	8b 04 c5 e4 31 11 80 	mov    -0x7feece1c(,%eax,8),%eax
80102108:	85 c0                	test   %eax,%eax
8010210a:	75 0a                	jne    80102116 <writei+0x49>
      return -1;
8010210c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102111:	e9 3d 01 00 00       	jmp    80102253 <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
80102116:	8b 45 08             	mov    0x8(%ebp),%eax
80102119:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010211d:	98                   	cwtl   
8010211e:	8b 04 c5 e4 31 11 80 	mov    -0x7feece1c(,%eax,8),%eax
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
801021e6:	e8 9c 49 00 00       	call   80106b87 <memmove>
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
80102266:	e8 b2 49 00 00       	call   80106c1d <strncmp>
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
80102286:	68 b3 a0 10 80       	push   $0x8010a0b3
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
801022b5:	68 c5 a0 10 80       	push   $0x8010a0c5
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
8010238a:	68 c5 a0 10 80       	push   $0x8010a0c5
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
801023c5:	e8 a9 48 00 00       	call   80106c73 <strncpy>
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
801023f1:	68 d2 a0 10 80       	push   $0x8010a0d2
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
80102467:	e8 1b 47 00 00       	call   80106b87 <memmove>
8010246c:	83 c4 10             	add    $0x10,%esp
8010246f:	eb 26                	jmp    80102497 <skipelem+0x95>
  else {
    memmove(name, s, len);
80102471:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102474:	83 ec 04             	sub    $0x4,%esp
80102477:	50                   	push   %eax
80102478:	ff 75 f4             	pushl  -0xc(%ebp)
8010247b:	ff 75 0c             	pushl  0xc(%ebp)
8010247e:	e8 04 47 00 00       	call   80106b87 <memmove>
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
801026d3:	68 da a0 10 80       	push   $0x8010a0da
801026d8:	68 20 d6 10 80       	push   $0x8010d620
801026dd:	e8 61 41 00 00       	call   80106843 <initlock>
801026e2:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
801026e5:	83 ec 0c             	sub    $0xc,%esp
801026e8:	6a 0e                	push   $0xe
801026ea:	e8 da 18 00 00       	call   80103fc9 <picenable>
801026ef:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801026f2:	a1 60 49 11 80       	mov    0x80114960,%eax
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
80102747:	c7 05 58 d6 10 80 01 	movl   $0x1,0x8010d658
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
80102787:	68 de a0 10 80       	push   $0x8010a0de
8010278c:	e8 d5 dd ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE)
80102791:	8b 45 08             	mov    0x8(%ebp),%eax
80102794:	8b 40 08             	mov    0x8(%eax),%eax
80102797:	3d cf 07 00 00       	cmp    $0x7cf,%eax
8010279c:	76 0d                	jbe    801027ab <idestart+0x33>
    panic("incorrect blockno");
8010279e:	83 ec 0c             	sub    $0xc,%esp
801027a1:	68 e7 a0 10 80       	push   $0x8010a0e7
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
801027ca:	68 de a0 10 80       	push   $0x8010a0de
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
801028df:	68 20 d6 10 80       	push   $0x8010d620
801028e4:	e8 7c 3f 00 00       	call   80106865 <acquire>
801028e9:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
801028ec:	a1 54 d6 10 80       	mov    0x8010d654,%eax
801028f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801028f8:	75 15                	jne    8010290f <ideintr+0x39>
    release(&idelock);
801028fa:	83 ec 0c             	sub    $0xc,%esp
801028fd:	68 20 d6 10 80       	push   $0x8010d620
80102902:	e8 c5 3f 00 00       	call   801068cc <release>
80102907:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
8010290a:	e9 9a 00 00 00       	jmp    801029a9 <ideintr+0xd3>
  }
  idequeue = b->qnext;
8010290f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102912:	8b 40 14             	mov    0x14(%eax),%eax
80102915:	a3 54 d6 10 80       	mov    %eax,0x8010d654

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
80102977:	e8 ba 2e 00 00       	call   80105836 <wakeup>
8010297c:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
8010297f:	a1 54 d6 10 80       	mov    0x8010d654,%eax
80102984:	85 c0                	test   %eax,%eax
80102986:	74 11                	je     80102999 <ideintr+0xc3>
    idestart(idequeue);
80102988:	a1 54 d6 10 80       	mov    0x8010d654,%eax
8010298d:	83 ec 0c             	sub    $0xc,%esp
80102990:	50                   	push   %eax
80102991:	e8 e2 fd ff ff       	call   80102778 <idestart>
80102996:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102999:	83 ec 0c             	sub    $0xc,%esp
8010299c:	68 20 d6 10 80       	push   $0x8010d620
801029a1:	e8 26 3f 00 00       	call   801068cc <release>
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
801029c0:	68 f9 a0 10 80       	push   $0x8010a0f9
801029c5:	e8 9c db ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801029ca:	8b 45 08             	mov    0x8(%ebp),%eax
801029cd:	8b 00                	mov    (%eax),%eax
801029cf:	83 e0 06             	and    $0x6,%eax
801029d2:	83 f8 02             	cmp    $0x2,%eax
801029d5:	75 0d                	jne    801029e4 <iderw+0x39>
    panic("iderw: nothing to do");
801029d7:	83 ec 0c             	sub    $0xc,%esp
801029da:	68 0d a1 10 80       	push   $0x8010a10d
801029df:	e8 82 db ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
801029e4:	8b 45 08             	mov    0x8(%ebp),%eax
801029e7:	8b 40 04             	mov    0x4(%eax),%eax
801029ea:	85 c0                	test   %eax,%eax
801029ec:	74 16                	je     80102a04 <iderw+0x59>
801029ee:	a1 58 d6 10 80       	mov    0x8010d658,%eax
801029f3:	85 c0                	test   %eax,%eax
801029f5:	75 0d                	jne    80102a04 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
801029f7:	83 ec 0c             	sub    $0xc,%esp
801029fa:	68 22 a1 10 80       	push   $0x8010a122
801029ff:	e8 62 db ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102a04:	83 ec 0c             	sub    $0xc,%esp
80102a07:	68 20 d6 10 80       	push   $0x8010d620
80102a0c:	e8 54 3e 00 00       	call   80106865 <acquire>
80102a11:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102a14:	8b 45 08             	mov    0x8(%ebp),%eax
80102a17:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102a1e:	c7 45 f4 54 d6 10 80 	movl   $0x8010d654,-0xc(%ebp)
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
80102a43:	a1 54 d6 10 80       	mov    0x8010d654,%eax
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
80102a60:	68 20 d6 10 80       	push   $0x8010d620
80102a65:	ff 75 08             	pushl  0x8(%ebp)
80102a68:	e8 53 2b 00 00       	call   801055c0 <sleep>
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
80102a80:	68 20 d6 10 80       	push   $0x8010d620
80102a85:	e8 42 3e 00 00       	call   801068cc <release>
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
80102a93:	a1 34 42 11 80       	mov    0x80114234,%eax
80102a98:	8b 55 08             	mov    0x8(%ebp),%edx
80102a9b:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a9d:	a1 34 42 11 80       	mov    0x80114234,%eax
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
80102aaa:	a1 34 42 11 80       	mov    0x80114234,%eax
80102aaf:	8b 55 08             	mov    0x8(%ebp),%edx
80102ab2:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102ab4:	a1 34 42 11 80       	mov    0x80114234,%eax
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
80102ac8:	a1 64 43 11 80       	mov    0x80114364,%eax
80102acd:	85 c0                	test   %eax,%eax
80102acf:	0f 84 a0 00 00 00    	je     80102b75 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102ad5:	c7 05 34 42 11 80 00 	movl   $0xfec00000,0x80114234
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
80102b04:	0f b6 05 60 43 11 80 	movzbl 0x80114360,%eax
80102b0b:	0f b6 c0             	movzbl %al,%eax
80102b0e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102b11:	74 10                	je     80102b23 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102b13:	83 ec 0c             	sub    $0xc,%esp
80102b16:	68 40 a1 10 80       	push   $0x8010a140
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
80102b7b:	a1 64 43 11 80       	mov    0x80114364,%eax
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
80102bd6:	68 72 a1 10 80       	push   $0x8010a172
80102bdb:	68 40 42 11 80       	push   $0x80114240
80102be0:	e8 5e 3c 00 00       	call   80106843 <initlock>
80102be5:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102be8:	c7 05 74 42 11 80 00 	movl   $0x0,0x80114274
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
80102c1d:	c7 05 74 42 11 80 01 	movl   $0x1,0x80114274
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
80102c79:	81 7d 08 7c 79 11 80 	cmpl   $0x8011797c,0x8(%ebp)
80102c80:	72 12                	jb     80102c94 <kfree+0x2d>
80102c82:	ff 75 08             	pushl  0x8(%ebp)
80102c85:	e8 36 ff ff ff       	call   80102bc0 <v2p>
80102c8a:	83 c4 04             	add    $0x4,%esp
80102c8d:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102c92:	76 0d                	jbe    80102ca1 <kfree+0x3a>
    panic("kfree");
80102c94:	83 ec 0c             	sub    $0xc,%esp
80102c97:	68 77 a1 10 80       	push   $0x8010a177
80102c9c:	e8 c5 d8 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102ca1:	83 ec 04             	sub    $0x4,%esp
80102ca4:	68 00 10 00 00       	push   $0x1000
80102ca9:	6a 01                	push   $0x1
80102cab:	ff 75 08             	pushl  0x8(%ebp)
80102cae:	e8 15 3e 00 00       	call   80106ac8 <memset>
80102cb3:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102cb6:	a1 74 42 11 80       	mov    0x80114274,%eax
80102cbb:	85 c0                	test   %eax,%eax
80102cbd:	74 10                	je     80102ccf <kfree+0x68>
    acquire(&kmem.lock);
80102cbf:	83 ec 0c             	sub    $0xc,%esp
80102cc2:	68 40 42 11 80       	push   $0x80114240
80102cc7:	e8 99 3b 00 00       	call   80106865 <acquire>
80102ccc:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102ccf:	8b 45 08             	mov    0x8(%ebp),%eax
80102cd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102cd5:	8b 15 78 42 11 80    	mov    0x80114278,%edx
80102cdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cde:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ce3:	a3 78 42 11 80       	mov    %eax,0x80114278
  if(kmem.use_lock)
80102ce8:	a1 74 42 11 80       	mov    0x80114274,%eax
80102ced:	85 c0                	test   %eax,%eax
80102cef:	74 10                	je     80102d01 <kfree+0x9a>
    release(&kmem.lock);
80102cf1:	83 ec 0c             	sub    $0xc,%esp
80102cf4:	68 40 42 11 80       	push   $0x80114240
80102cf9:	e8 ce 3b 00 00       	call   801068cc <release>
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
80102d0a:	a1 74 42 11 80       	mov    0x80114274,%eax
80102d0f:	85 c0                	test   %eax,%eax
80102d11:	74 10                	je     80102d23 <kalloc+0x1f>
    acquire(&kmem.lock);
80102d13:	83 ec 0c             	sub    $0xc,%esp
80102d16:	68 40 42 11 80       	push   $0x80114240
80102d1b:	e8 45 3b 00 00       	call   80106865 <acquire>
80102d20:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102d23:	a1 78 42 11 80       	mov    0x80114278,%eax
80102d28:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102d2b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102d2f:	74 0a                	je     80102d3b <kalloc+0x37>
    kmem.freelist = r->next;
80102d31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d34:	8b 00                	mov    (%eax),%eax
80102d36:	a3 78 42 11 80       	mov    %eax,0x80114278
  if(kmem.use_lock)
80102d3b:	a1 74 42 11 80       	mov    0x80114274,%eax
80102d40:	85 c0                	test   %eax,%eax
80102d42:	74 10                	je     80102d54 <kalloc+0x50>
    release(&kmem.lock);
80102d44:	83 ec 0c             	sub    $0xc,%esp
80102d47:	68 40 42 11 80       	push   $0x80114240
80102d4c:	e8 7b 3b 00 00       	call   801068cc <release>
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
80102db9:	a1 5c d6 10 80       	mov    0x8010d65c,%eax
80102dbe:	83 c8 40             	or     $0x40,%eax
80102dc1:	a3 5c d6 10 80       	mov    %eax,0x8010d65c
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
80102ddc:	a1 5c d6 10 80       	mov    0x8010d65c,%eax
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
80102df9:	05 20 b0 10 80       	add    $0x8010b020,%eax
80102dfe:	0f b6 00             	movzbl (%eax),%eax
80102e01:	83 c8 40             	or     $0x40,%eax
80102e04:	0f b6 c0             	movzbl %al,%eax
80102e07:	f7 d0                	not    %eax
80102e09:	89 c2                	mov    %eax,%edx
80102e0b:	a1 5c d6 10 80       	mov    0x8010d65c,%eax
80102e10:	21 d0                	and    %edx,%eax
80102e12:	a3 5c d6 10 80       	mov    %eax,0x8010d65c
    return 0;
80102e17:	b8 00 00 00 00       	mov    $0x0,%eax
80102e1c:	e9 a2 00 00 00       	jmp    80102ec3 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102e21:	a1 5c d6 10 80       	mov    0x8010d65c,%eax
80102e26:	83 e0 40             	and    $0x40,%eax
80102e29:	85 c0                	test   %eax,%eax
80102e2b:	74 14                	je     80102e41 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102e2d:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102e34:	a1 5c d6 10 80       	mov    0x8010d65c,%eax
80102e39:	83 e0 bf             	and    $0xffffffbf,%eax
80102e3c:	a3 5c d6 10 80       	mov    %eax,0x8010d65c
  }

  shift |= shiftcode[data];
80102e41:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e44:	05 20 b0 10 80       	add    $0x8010b020,%eax
80102e49:	0f b6 00             	movzbl (%eax),%eax
80102e4c:	0f b6 d0             	movzbl %al,%edx
80102e4f:	a1 5c d6 10 80       	mov    0x8010d65c,%eax
80102e54:	09 d0                	or     %edx,%eax
80102e56:	a3 5c d6 10 80       	mov    %eax,0x8010d65c
  shift ^= togglecode[data];
80102e5b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e5e:	05 20 b1 10 80       	add    $0x8010b120,%eax
80102e63:	0f b6 00             	movzbl (%eax),%eax
80102e66:	0f b6 d0             	movzbl %al,%edx
80102e69:	a1 5c d6 10 80       	mov    0x8010d65c,%eax
80102e6e:	31 d0                	xor    %edx,%eax
80102e70:	a3 5c d6 10 80       	mov    %eax,0x8010d65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102e75:	a1 5c d6 10 80       	mov    0x8010d65c,%eax
80102e7a:	83 e0 03             	and    $0x3,%eax
80102e7d:	8b 14 85 20 b5 10 80 	mov    -0x7fef4ae0(,%eax,4),%edx
80102e84:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e87:	01 d0                	add    %edx,%eax
80102e89:	0f b6 00             	movzbl (%eax),%eax
80102e8c:	0f b6 c0             	movzbl %al,%eax
80102e8f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e92:	a1 5c d6 10 80       	mov    0x8010d65c,%eax
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
80102f2d:	a1 7c 42 11 80       	mov    0x8011427c,%eax
80102f32:	8b 55 08             	mov    0x8(%ebp),%edx
80102f35:	c1 e2 02             	shl    $0x2,%edx
80102f38:	01 c2                	add    %eax,%edx
80102f3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f3d:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102f3f:	a1 7c 42 11 80       	mov    0x8011427c,%eax
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
80102f4f:	a1 7c 42 11 80       	mov    0x8011427c,%eax
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
80102fc2:	a1 7c 42 11 80       	mov    0x8011427c,%eax
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
80103044:	a1 7c 42 11 80       	mov    0x8011427c,%eax
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
8010307e:	a1 60 d6 10 80       	mov    0x8010d660,%eax
80103083:	8d 50 01             	lea    0x1(%eax),%edx
80103086:	89 15 60 d6 10 80    	mov    %edx,0x8010d660
8010308c:	85 c0                	test   %eax,%eax
8010308e:	75 14                	jne    801030a4 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80103090:	8b 45 04             	mov    0x4(%ebp),%eax
80103093:	83 ec 08             	sub    $0x8,%esp
80103096:	50                   	push   %eax
80103097:	68 80 a1 10 80       	push   $0x8010a180
8010309c:	e8 25 d3 ff ff       	call   801003c6 <cprintf>
801030a1:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
801030a4:	a1 7c 42 11 80       	mov    0x8011427c,%eax
801030a9:	85 c0                	test   %eax,%eax
801030ab:	74 0f                	je     801030bc <cpunum+0x52>
    return lapic[ID]>>24;
801030ad:	a1 7c 42 11 80       	mov    0x8011427c,%eax
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
801030c6:	a1 7c 42 11 80       	mov    0x8011427c,%eax
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
801032c2:	e8 68 38 00 00       	call   80106b2f <memcmp>
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
801033d6:	68 ac a1 10 80       	push   $0x8010a1ac
801033db:	68 80 42 11 80       	push   $0x80114280
801033e0:	e8 5e 34 00 00       	call   80106843 <initlock>
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
801033fd:	a3 b4 42 11 80       	mov    %eax,0x801142b4
  log.size = sb.nlog;
80103402:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103405:	a3 b8 42 11 80       	mov    %eax,0x801142b8
  log.dev = dev;
8010340a:	8b 45 08             	mov    0x8(%ebp),%eax
8010340d:	a3 c4 42 11 80       	mov    %eax,0x801142c4
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
8010342c:	8b 15 b4 42 11 80    	mov    0x801142b4,%edx
80103432:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103435:	01 d0                	add    %edx,%eax
80103437:	83 c0 01             	add    $0x1,%eax
8010343a:	89 c2                	mov    %eax,%edx
8010343c:	a1 c4 42 11 80       	mov    0x801142c4,%eax
80103441:	83 ec 08             	sub    $0x8,%esp
80103444:	52                   	push   %edx
80103445:	50                   	push   %eax
80103446:	e8 6b cd ff ff       	call   801001b6 <bread>
8010344b:	83 c4 10             	add    $0x10,%esp
8010344e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103451:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103454:	83 c0 10             	add    $0x10,%eax
80103457:	8b 04 85 8c 42 11 80 	mov    -0x7feebd74(,%eax,4),%eax
8010345e:	89 c2                	mov    %eax,%edx
80103460:	a1 c4 42 11 80       	mov    0x801142c4,%eax
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
8010348b:	e8 f7 36 00 00       	call   80106b87 <memmove>
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
801034c1:	a1 c8 42 11 80       	mov    0x801142c8,%eax
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
801034d8:	a1 b4 42 11 80       	mov    0x801142b4,%eax
801034dd:	89 c2                	mov    %eax,%edx
801034df:	a1 c4 42 11 80       	mov    0x801142c4,%eax
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
80103502:	a3 c8 42 11 80       	mov    %eax,0x801142c8
  for (i = 0; i < log.lh.n; i++) {
80103507:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010350e:	eb 1b                	jmp    8010352b <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103510:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103513:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103516:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010351a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010351d:	83 c2 10             	add    $0x10,%edx
80103520:	89 04 95 8c 42 11 80 	mov    %eax,-0x7feebd74(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103527:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010352b:	a1 c8 42 11 80       	mov    0x801142c8,%eax
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
8010354c:	a1 b4 42 11 80       	mov    0x801142b4,%eax
80103551:	89 c2                	mov    %eax,%edx
80103553:	a1 c4 42 11 80       	mov    0x801142c4,%eax
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
80103571:	8b 15 c8 42 11 80    	mov    0x801142c8,%edx
80103577:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010357a:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010357c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103583:	eb 1b                	jmp    801035a0 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80103585:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103588:	83 c0 10             	add    $0x10,%eax
8010358b:	8b 0c 85 8c 42 11 80 	mov    -0x7feebd74(,%eax,4),%ecx
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
801035a0:	a1 c8 42 11 80       	mov    0x801142c8,%eax
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
801035d9:	c7 05 c8 42 11 80 00 	movl   $0x0,0x801142c8
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
801035f4:	68 80 42 11 80       	push   $0x80114280
801035f9:	e8 67 32 00 00       	call   80106865 <acquire>
801035fe:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103601:	a1 c0 42 11 80       	mov    0x801142c0,%eax
80103606:	85 c0                	test   %eax,%eax
80103608:	74 17                	je     80103621 <begin_op+0x36>
      sleep(&log, &log.lock);
8010360a:	83 ec 08             	sub    $0x8,%esp
8010360d:	68 80 42 11 80       	push   $0x80114280
80103612:	68 80 42 11 80       	push   $0x80114280
80103617:	e8 a4 1f 00 00       	call   801055c0 <sleep>
8010361c:	83 c4 10             	add    $0x10,%esp
8010361f:	eb e0                	jmp    80103601 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103621:	8b 0d c8 42 11 80    	mov    0x801142c8,%ecx
80103627:	a1 bc 42 11 80       	mov    0x801142bc,%eax
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
80103642:	68 80 42 11 80       	push   $0x80114280
80103647:	68 80 42 11 80       	push   $0x80114280
8010364c:	e8 6f 1f 00 00       	call   801055c0 <sleep>
80103651:	83 c4 10             	add    $0x10,%esp
80103654:	eb ab                	jmp    80103601 <begin_op+0x16>
    } else {
      log.outstanding += 1;
80103656:	a1 bc 42 11 80       	mov    0x801142bc,%eax
8010365b:	83 c0 01             	add    $0x1,%eax
8010365e:	a3 bc 42 11 80       	mov    %eax,0x801142bc
      release(&log.lock);
80103663:	83 ec 0c             	sub    $0xc,%esp
80103666:	68 80 42 11 80       	push   $0x80114280
8010366b:	e8 5c 32 00 00       	call   801068cc <release>
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
80103687:	68 80 42 11 80       	push   $0x80114280
8010368c:	e8 d4 31 00 00       	call   80106865 <acquire>
80103691:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103694:	a1 bc 42 11 80       	mov    0x801142bc,%eax
80103699:	83 e8 01             	sub    $0x1,%eax
8010369c:	a3 bc 42 11 80       	mov    %eax,0x801142bc
  if(log.committing)
801036a1:	a1 c0 42 11 80       	mov    0x801142c0,%eax
801036a6:	85 c0                	test   %eax,%eax
801036a8:	74 0d                	je     801036b7 <end_op+0x40>
    panic("log.committing");
801036aa:	83 ec 0c             	sub    $0xc,%esp
801036ad:	68 b0 a1 10 80       	push   $0x8010a1b0
801036b2:	e8 af ce ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
801036b7:	a1 bc 42 11 80       	mov    0x801142bc,%eax
801036bc:	85 c0                	test   %eax,%eax
801036be:	75 13                	jne    801036d3 <end_op+0x5c>
    do_commit = 1;
801036c0:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801036c7:	c7 05 c0 42 11 80 01 	movl   $0x1,0x801142c0
801036ce:	00 00 00 
801036d1:	eb 10                	jmp    801036e3 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
801036d3:	83 ec 0c             	sub    $0xc,%esp
801036d6:	68 80 42 11 80       	push   $0x80114280
801036db:	e8 56 21 00 00       	call   80105836 <wakeup>
801036e0:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801036e3:	83 ec 0c             	sub    $0xc,%esp
801036e6:	68 80 42 11 80       	push   $0x80114280
801036eb:	e8 dc 31 00 00       	call   801068cc <release>
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
80103701:	68 80 42 11 80       	push   $0x80114280
80103706:	e8 5a 31 00 00       	call   80106865 <acquire>
8010370b:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010370e:	c7 05 c0 42 11 80 00 	movl   $0x0,0x801142c0
80103715:	00 00 00 
    wakeup(&log);
80103718:	83 ec 0c             	sub    $0xc,%esp
8010371b:	68 80 42 11 80       	push   $0x80114280
80103720:	e8 11 21 00 00       	call   80105836 <wakeup>
80103725:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103728:	83 ec 0c             	sub    $0xc,%esp
8010372b:	68 80 42 11 80       	push   $0x80114280
80103730:	e8 97 31 00 00       	call   801068cc <release>
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
8010374d:	8b 15 b4 42 11 80    	mov    0x801142b4,%edx
80103753:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103756:	01 d0                	add    %edx,%eax
80103758:	83 c0 01             	add    $0x1,%eax
8010375b:	89 c2                	mov    %eax,%edx
8010375d:	a1 c4 42 11 80       	mov    0x801142c4,%eax
80103762:	83 ec 08             	sub    $0x8,%esp
80103765:	52                   	push   %edx
80103766:	50                   	push   %eax
80103767:	e8 4a ca ff ff       	call   801001b6 <bread>
8010376c:	83 c4 10             	add    $0x10,%esp
8010376f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103772:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103775:	83 c0 10             	add    $0x10,%eax
80103778:	8b 04 85 8c 42 11 80 	mov    -0x7feebd74(,%eax,4),%eax
8010377f:	89 c2                	mov    %eax,%edx
80103781:	a1 c4 42 11 80       	mov    0x801142c4,%eax
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
801037ac:	e8 d6 33 00 00       	call   80106b87 <memmove>
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
801037e2:	a1 c8 42 11 80       	mov    0x801142c8,%eax
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
801037f9:	a1 c8 42 11 80       	mov    0x801142c8,%eax
801037fe:	85 c0                	test   %eax,%eax
80103800:	7e 1e                	jle    80103820 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103802:	e8 34 ff ff ff       	call   8010373b <write_log>
    write_head();    // Write header to disk -- the real commit
80103807:	e8 3a fd ff ff       	call   80103546 <write_head>
    install_trans(); // Now install writes to home locations
8010380c:	e8 09 fc ff ff       	call   8010341a <install_trans>
    log.lh.n = 0; 
80103811:	c7 05 c8 42 11 80 00 	movl   $0x0,0x801142c8
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
80103829:	a1 c8 42 11 80       	mov    0x801142c8,%eax
8010382e:	83 f8 1d             	cmp    $0x1d,%eax
80103831:	7f 12                	jg     80103845 <log_write+0x22>
80103833:	a1 c8 42 11 80       	mov    0x801142c8,%eax
80103838:	8b 15 b8 42 11 80    	mov    0x801142b8,%edx
8010383e:	83 ea 01             	sub    $0x1,%edx
80103841:	39 d0                	cmp    %edx,%eax
80103843:	7c 0d                	jl     80103852 <log_write+0x2f>
    panic("too big a transaction");
80103845:	83 ec 0c             	sub    $0xc,%esp
80103848:	68 bf a1 10 80       	push   $0x8010a1bf
8010384d:	e8 14 cd ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
80103852:	a1 bc 42 11 80       	mov    0x801142bc,%eax
80103857:	85 c0                	test   %eax,%eax
80103859:	7f 0d                	jg     80103868 <log_write+0x45>
    panic("log_write outside of trans");
8010385b:	83 ec 0c             	sub    $0xc,%esp
8010385e:	68 d5 a1 10 80       	push   $0x8010a1d5
80103863:	e8 fe cc ff ff       	call   80100566 <panic>

  acquire(&log.lock);
80103868:	83 ec 0c             	sub    $0xc,%esp
8010386b:	68 80 42 11 80       	push   $0x80114280
80103870:	e8 f0 2f 00 00       	call   80106865 <acquire>
80103875:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103878:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010387f:	eb 1d                	jmp    8010389e <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103881:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103884:	83 c0 10             	add    $0x10,%eax
80103887:	8b 04 85 8c 42 11 80 	mov    -0x7feebd74(,%eax,4),%eax
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
8010389e:	a1 c8 42 11 80       	mov    0x801142c8,%eax
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
801038b9:	89 14 85 8c 42 11 80 	mov    %edx,-0x7feebd74(,%eax,4)
  if (i == log.lh.n)
801038c0:	a1 c8 42 11 80       	mov    0x801142c8,%eax
801038c5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038c8:	75 0d                	jne    801038d7 <log_write+0xb4>
    log.lh.n++;
801038ca:	a1 c8 42 11 80       	mov    0x801142c8,%eax
801038cf:	83 c0 01             	add    $0x1,%eax
801038d2:	a3 c8 42 11 80       	mov    %eax,0x801142c8
  b->flags |= B_DIRTY; // prevent eviction
801038d7:	8b 45 08             	mov    0x8(%ebp),%eax
801038da:	8b 00                	mov    (%eax),%eax
801038dc:	83 c8 04             	or     $0x4,%eax
801038df:	89 c2                	mov    %eax,%edx
801038e1:	8b 45 08             	mov    0x8(%ebp),%eax
801038e4:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801038e6:	83 ec 0c             	sub    $0xc,%esp
801038e9:	68 80 42 11 80       	push   $0x80114280
801038ee:	e8 d9 2f 00 00       	call   801068cc <release>
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
80103946:	68 7c 79 11 80       	push   $0x8011797c
8010394b:	e8 7d f2 ff ff       	call   80102bcd <kinit1>
80103950:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103953:	e8 66 5e 00 00       	call   801097be <kvmalloc>
  mpinit();        // collect info about this machine
80103958:	e8 43 04 00 00       	call   80103da0 <mpinit>
  lapicinit();
8010395d:	e8 ea f5 ff ff       	call   80102f4c <lapicinit>
  seginit();       // set up segments
80103962:	e8 00 58 00 00       	call   80109167 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103967:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010396d:	0f b6 00             	movzbl (%eax),%eax
80103970:	0f b6 c0             	movzbl %al,%eax
80103973:	83 ec 08             	sub    $0x8,%esp
80103976:	50                   	push   %eax
80103977:	68 f0 a1 10 80       	push   $0x8010a1f0
8010397c:	e8 45 ca ff ff       	call   801003c6 <cprintf>
80103981:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
80103984:	e8 6d 06 00 00       	call   80103ff6 <picinit>
  ioapicinit();    // another interrupt controller
80103989:	e8 34 f1 ff ff       	call   80102ac2 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010398e:	e8 24 d2 ff ff       	call   80100bb7 <consoleinit>
  uartinit();      // serial port
80103993:	e8 2b 4b 00 00       	call   801084c3 <uartinit>
  pinit();         // process table
80103998:	e8 5d 0b 00 00       	call   801044fa <pinit>
  tvinit();        // trap vectors
8010399d:	e8 fa 46 00 00       	call   8010809c <tvinit>
  binit();         // buffer cache
801039a2:	e8 8d c6 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801039a7:	e8 67 d6 ff ff       	call   80101013 <fileinit>
  ideinit();       // disk
801039ac:	e8 19 ed ff ff       	call   801026ca <ideinit>
  if(!ismp)
801039b1:	a1 64 43 11 80       	mov    0x80114364,%eax
801039b6:	85 c0                	test   %eax,%eax
801039b8:	75 05                	jne    801039bf <main+0x92>
    timerinit();   // uniprocessor timer
801039ba:	e8 2e 46 00 00       	call   80107fed <timerinit>
  startothers();   // start other processors
801039bf:	e8 7f 00 00 00       	call   80103a43 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801039c4:	83 ec 08             	sub    $0x8,%esp
801039c7:	68 00 00 00 8e       	push   $0x8e000000
801039cc:	68 00 00 40 80       	push   $0x80400000
801039d1:	e8 30 f2 ff ff       	call   80102c06 <kinit2>
801039d6:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
801039d9:	e8 4e 0d 00 00       	call   8010472c <userinit>
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
801039e9:	e8 e8 5d 00 00       	call   801097d6 <switchkvm>
  seginit();
801039ee:	e8 74 57 00 00       	call   80109167 <seginit>
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
80103a13:	68 07 a2 10 80       	push   $0x8010a207
80103a18:	e8 a9 c9 ff ff       	call   801003c6 <cprintf>
80103a1d:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103a20:	e8 d8 47 00 00       	call   801081fd <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103a25:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103a2b:	05 a8 00 00 00       	add    $0xa8,%eax
80103a30:	83 ec 08             	sub    $0x8,%esp
80103a33:	6a 01                	push   $0x1
80103a35:	50                   	push   %eax
80103a36:	e8 d8 fe ff ff       	call   80103913 <xchg>
80103a3b:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103a3e:	e8 5a 17 00 00       	call   8010519d <scheduler>

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
80103a63:	68 2c d5 10 80       	push   $0x8010d52c
80103a68:	ff 75 f0             	pushl  -0x10(%ebp)
80103a6b:	e8 17 31 00 00       	call   80106b87 <memmove>
80103a70:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103a73:	c7 45 f4 80 43 11 80 	movl   $0x80114380,-0xc(%ebp)
80103a7a:	e9 90 00 00 00       	jmp    80103b0f <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
80103a7f:	e8 e6 f5 ff ff       	call   8010306a <cpunum>
80103a84:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103a8a:	05 80 43 11 80       	add    $0x80114380,%eax
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
80103ac2:	68 00 c0 10 80       	push   $0x8010c000
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
80103b0f:	a1 60 49 11 80       	mov    0x80114960,%eax
80103b14:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103b1a:	05 80 43 11 80       	add    $0x80114380,%eax
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
80103b7a:	a1 64 d6 10 80       	mov    0x8010d664,%eax
80103b7f:	89 c2                	mov    %eax,%edx
80103b81:	b8 80 43 11 80       	mov    $0x80114380,%eax
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
80103bf9:	68 18 a2 10 80       	push   $0x8010a218
80103bfe:	ff 75 f4             	pushl  -0xc(%ebp)
80103c01:	e8 29 2f 00 00       	call   80106b2f <memcmp>
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
80103d37:	68 1d a2 10 80       	push   $0x8010a21d
80103d3c:	ff 75 f0             	pushl  -0x10(%ebp)
80103d3f:	e8 eb 2d 00 00       	call   80106b2f <memcmp>
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
80103da6:	c7 05 64 d6 10 80 80 	movl   $0x80114380,0x8010d664
80103dad:	43 11 80 
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
80103dcc:	c7 05 64 43 11 80 01 	movl   $0x1,0x80114364
80103dd3:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103dd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dd9:	8b 40 24             	mov    0x24(%eax),%eax
80103ddc:	a3 7c 42 11 80       	mov    %eax,0x8011427c
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
80103e13:	8b 04 85 60 a2 10 80 	mov    -0x7fef5da0(,%eax,4),%eax
80103e1a:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e1f:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103e22:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e25:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e29:	0f b6 d0             	movzbl %al,%edx
80103e2c:	a1 60 49 11 80       	mov    0x80114960,%eax
80103e31:	39 c2                	cmp    %eax,%edx
80103e33:	74 2b                	je     80103e60 <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103e35:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e38:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e3c:	0f b6 d0             	movzbl %al,%edx
80103e3f:	a1 60 49 11 80       	mov    0x80114960,%eax
80103e44:	83 ec 04             	sub    $0x4,%esp
80103e47:	52                   	push   %edx
80103e48:	50                   	push   %eax
80103e49:	68 22 a2 10 80       	push   $0x8010a222
80103e4e:	e8 73 c5 ff ff       	call   801003c6 <cprintf>
80103e53:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103e56:	c7 05 64 43 11 80 00 	movl   $0x0,0x80114364
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
80103e71:	a1 60 49 11 80       	mov    0x80114960,%eax
80103e76:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103e7c:	05 80 43 11 80       	add    $0x80114380,%eax
80103e81:	a3 64 d6 10 80       	mov    %eax,0x8010d664
      cpus[ncpu].id = ncpu;
80103e86:	a1 60 49 11 80       	mov    0x80114960,%eax
80103e8b:	8b 15 60 49 11 80    	mov    0x80114960,%edx
80103e91:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103e97:	05 80 43 11 80       	add    $0x80114380,%eax
80103e9c:	88 10                	mov    %dl,(%eax)
      ncpu++;
80103e9e:	a1 60 49 11 80       	mov    0x80114960,%eax
80103ea3:	83 c0 01             	add    $0x1,%eax
80103ea6:	a3 60 49 11 80       	mov    %eax,0x80114960
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
80103ebe:	a2 60 43 11 80       	mov    %al,0x80114360
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
80103edc:	68 40 a2 10 80       	push   $0x8010a240
80103ee1:	e8 e0 c4 ff ff       	call   801003c6 <cprintf>
80103ee6:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103ee9:	c7 05 64 43 11 80 00 	movl   $0x0,0x80114364
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
80103eff:	a1 64 43 11 80       	mov    0x80114364,%eax
80103f04:	85 c0                	test   %eax,%eax
80103f06:	75 1d                	jne    80103f25 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103f08:	c7 05 60 49 11 80 01 	movl   $0x1,0x80114960
80103f0f:	00 00 00 
    lapic = 0;
80103f12:	c7 05 7c 42 11 80 00 	movl   $0x0,0x8011427c
80103f19:	00 00 00 
    ioapicid = 0;
80103f1c:	c6 05 60 43 11 80 00 	movb   $0x0,0x80114360
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
80103f95:	66 a3 00 d0 10 80    	mov    %ax,0x8010d000
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
80103fde:	0f b7 05 00 d0 10 80 	movzwl 0x8010d000,%eax
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
801040bc:	0f b7 05 00 d0 10 80 	movzwl 0x8010d000,%eax
801040c3:	66 83 f8 ff          	cmp    $0xffff,%ax
801040c7:	74 13                	je     801040dc <picinit+0xe6>
    picsetmask(irqmask);
801040c9:	0f b7 05 00 d0 10 80 	movzwl 0x8010d000,%eax
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
8010417d:	68 74 a2 10 80       	push   $0x8010a274
80104182:	50                   	push   %eax
80104183:	e8 bb 26 00 00       	call   80106843 <initlock>
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
8010423f:	e8 21 26 00 00       	call   80106865 <acquire>
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
80104266:	e8 cb 15 00 00       	call   80105836 <wakeup>
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
80104289:	e8 a8 15 00 00       	call   80105836 <wakeup>
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
801042b2:	e8 15 26 00 00       	call   801068cc <release>
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
801042d1:	e8 f6 25 00 00       	call   801068cc <release>
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
801042e9:	e8 77 25 00 00       	call   80106865 <acquire>
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
8010431e:	e8 a9 25 00 00       	call   801068cc <release>
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
8010433c:	e8 f5 14 00 00       	call   80105836 <wakeup>
80104341:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104344:	8b 45 08             	mov    0x8(%ebp),%eax
80104347:	8b 55 08             	mov    0x8(%ebp),%edx
8010434a:	81 c2 38 02 00 00    	add    $0x238,%edx
80104350:	83 ec 08             	sub    $0x8,%esp
80104353:	50                   	push   %eax
80104354:	52                   	push   %edx
80104355:	e8 66 12 00 00       	call   801055c0 <sleep>
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
801043be:	e8 73 14 00 00       	call   80105836 <wakeup>
801043c3:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801043c6:	8b 45 08             	mov    0x8(%ebp),%eax
801043c9:	83 ec 0c             	sub    $0xc,%esp
801043cc:	50                   	push   %eax
801043cd:	e8 fa 24 00 00       	call   801068cc <release>
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
801043e8:	e8 78 24 00 00       	call   80106865 <acquire>
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
80104406:	e8 c1 24 00 00       	call   801068cc <release>
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
80104429:	e8 92 11 00 00       	call   801055c0 <sleep>
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
801044bd:	e8 74 13 00 00       	call   80105836 <wakeup>
801044c2:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801044c5:	8b 45 08             	mov    0x8(%ebp),%eax
801044c8:	83 ec 0c             	sub    $0xc,%esp
801044cb:	50                   	push   %eax
801044cc:	e8 fb 23 00 00       	call   801068cc <release>
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
static void promoteAll(void);
#endif

void
pinit(void)
{
801044fa:	55                   	push   %ebp
801044fb:	89 e5                	mov    %esp,%ebp
801044fd:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104500:	83 ec 08             	sub    $0x8,%esp
80104503:	68 7c a2 10 80       	push   $0x8010a27c
80104508:	68 80 49 11 80       	push   $0x80114980
8010450d:	e8 31 23 00 00       	call   80106843 <initlock>
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
80104521:	68 80 49 11 80       	push   $0x80114980
80104526:	e8 3a 23 00 00       	call   80106865 <acquire>
8010452b:	83 c4 10             	add    $0x10,%esp
#ifndef CS333_P3P4
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
#else
  p = ptable.pLists.free;
8010452e:	a1 e4 70 11 80       	mov    0x801170e4,%eax
80104533:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p)
80104536:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010453a:	75 1a                	jne    80104556 <allocproc+0x3e>
    goto found;
#endif
  release(&ptable.lock);
8010453c:	83 ec 0c             	sub    $0xc,%esp
8010453f:	68 80 49 11 80       	push   $0x80114980
80104544:	e8 83 23 00 00       	call   801068cc <release>
80104549:	83 c4 10             	add    $0x10,%esp
  return 0;
8010454c:	b8 00 00 00 00       	mov    $0x0,%eax
80104551:	e9 d4 01 00 00       	jmp    8010472a <allocproc+0x212>
    if(p->state == UNUSED)
      goto found;
#else
  p = ptable.pLists.free;
  if(p)
    goto found;
80104556:	90                   	nop
#endif
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104557:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455a:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
#ifdef CS333_P3P4
  if(stateListRemove(&ptable.pLists.free, &ptable.pLists.freeTail, p))
80104561:	83 ec 04             	sub    $0x4,%esp
80104564:	ff 75 f4             	pushl  -0xc(%ebp)
80104567:	68 e8 70 11 80       	push   $0x801170e8
8010456c:	68 e4 70 11 80       	push   $0x801170e4
80104571:	e8 06 18 00 00       	call   80105d7c <stateListRemove>
80104576:	83 c4 10             	add    $0x10,%esp
80104579:	85 c0                	test   %eax,%eax
8010457b:	74 0d                	je     8010458a <allocproc+0x72>
    panic("error removing from free list.");
8010457d:	83 ec 0c             	sub    $0xc,%esp
80104580:	68 84 a2 10 80       	push   $0x8010a284
80104585:	e8 dc bf ff ff       	call   80100566 <panic>
  if(stateListAdd(&ptable.pLists.embryo, &ptable.pLists.embryoTail,p))
8010458a:	83 ec 04             	sub    $0x4,%esp
8010458d:	ff 75 f4             	pushl  -0xc(%ebp)
80104590:	68 08 71 11 80       	push   $0x80117108
80104595:	68 04 71 11 80       	push   $0x80117104
8010459a:	e8 7e 17 00 00       	call   80105d1d <stateListAdd>
8010459f:	83 c4 10             	add    $0x10,%esp
801045a2:	85 c0                	test   %eax,%eax
801045a4:	74 0d                	je     801045b3 <allocproc+0x9b>
    panic("error adding to embryo list.");
801045a6:	83 ec 0c             	sub    $0xc,%esp
801045a9:	68 a3 a2 10 80       	push   $0x8010a2a3
801045ae:	e8 b3 bf ff ff       	call   80100566 <panic>
  assertState(p, EMBRYO);
801045b3:	83 ec 08             	sub    $0x8,%esp
801045b6:	6a 01                	push   $0x1
801045b8:	ff 75 f4             	pushl  -0xc(%ebp)
801045bb:	e8 3c 1e 00 00       	call   801063fc <assertState>
801045c0:	83 c4 10             	add    $0x10,%esp
#endif
  p->pid = nextpid++;
801045c3:	a1 04 d0 10 80       	mov    0x8010d004,%eax
801045c8:	8d 50 01             	lea    0x1(%eax),%edx
801045cb:	89 15 04 d0 10 80    	mov    %edx,0x8010d004
801045d1:	89 c2                	mov    %eax,%edx
801045d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d6:	89 50 10             	mov    %edx,0x10(%eax)
  p->start_ticks = ticks;
801045d9:	8b 15 20 79 11 80    	mov    0x80117920,%edx
801045df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e2:	89 50 7c             	mov    %edx,0x7c(%eax)
  p->uid = 0;
801045e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e8:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
801045ef:	00 00 00 
  p->gid = 0;
801045f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f5:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
801045fc:	00 00 00 
  p->cpu_ticks_in = 0;
801045ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104602:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80104609:	00 00 00 
  p->cpu_ticks_total = 0;
8010460c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010460f:	c7 80 88 00 00 00 00 	movl   $0x0,0x88(%eax)
80104616:	00 00 00 
  p->priority = 0;
80104619:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010461c:	c7 80 98 00 00 00 00 	movl   $0x0,0x98(%eax)
80104623:	00 00 00 
  p->budget = BUDGET;
80104626:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104629:	c7 80 94 00 00 00 64 	movl   $0x64,0x94(%eax)
80104630:	00 00 00 
  release(&ptable.lock);
80104633:	83 ec 0c             	sub    $0xc,%esp
80104636:	68 80 49 11 80       	push   $0x80114980
8010463b:	e8 8c 22 00 00       	call   801068cc <release>
80104640:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104643:	e8 bc e6 ff ff       	call   80102d04 <kalloc>
80104648:	89 c2                	mov    %eax,%edx
8010464a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010464d:	89 50 08             	mov    %edx,0x8(%eax)
80104650:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104653:	8b 40 08             	mov    0x8(%eax),%eax
80104656:	85 c0                	test   %eax,%eax
80104658:	75 73                	jne    801046cd <allocproc+0x1b5>
    p->state = UNUSED;
8010465a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010465d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
#ifdef CS333_P3P4
    if(stateListRemove(&ptable.pLists.embryo, &ptable.pLists.embryoTail,p))
80104664:	83 ec 04             	sub    $0x4,%esp
80104667:	ff 75 f4             	pushl  -0xc(%ebp)
8010466a:	68 08 71 11 80       	push   $0x80117108
8010466f:	68 04 71 11 80       	push   $0x80117104
80104674:	e8 03 17 00 00       	call   80105d7c <stateListRemove>
80104679:	83 c4 10             	add    $0x10,%esp
8010467c:	85 c0                	test   %eax,%eax
8010467e:	74 0d                	je     8010468d <allocproc+0x175>
      panic("error removing from embryo list.");
80104680:	83 ec 0c             	sub    $0xc,%esp
80104683:	68 c0 a2 10 80       	push   $0x8010a2c0
80104688:	e8 d9 be ff ff       	call   80100566 <panic>
    if(stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail,p))
8010468d:	83 ec 04             	sub    $0x4,%esp
80104690:	ff 75 f4             	pushl  -0xc(%ebp)
80104693:	68 e8 70 11 80       	push   $0x801170e8
80104698:	68 e4 70 11 80       	push   $0x801170e4
8010469d:	e8 7b 16 00 00       	call   80105d1d <stateListAdd>
801046a2:	83 c4 10             	add    $0x10,%esp
801046a5:	85 c0                	test   %eax,%eax
801046a7:	74 0d                	je     801046b6 <allocproc+0x19e>
      panic("error adding to free list.");
801046a9:	83 ec 0c             	sub    $0xc,%esp
801046ac:	68 e1 a2 10 80       	push   $0x8010a2e1
801046b1:	e8 b0 be ff ff       	call   80100566 <panic>
    assertState(p, UNUSED);
801046b6:	83 ec 08             	sub    $0x8,%esp
801046b9:	6a 00                	push   $0x0
801046bb:	ff 75 f4             	pushl  -0xc(%ebp)
801046be:	e8 39 1d 00 00       	call   801063fc <assertState>
801046c3:	83 c4 10             	add    $0x10,%esp
#endif
    return 0;
801046c6:	b8 00 00 00 00       	mov    $0x0,%eax
801046cb:	eb 5d                	jmp    8010472a <allocproc+0x212>
  }
  sp = p->kstack + KSTACKSIZE;
801046cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d0:	8b 40 08             	mov    0x8(%eax),%eax
801046d3:	05 00 10 00 00       	add    $0x1000,%eax
801046d8:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801046db:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801046df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801046e5:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801046e8:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801046ec:	ba 4a 80 10 80       	mov    $0x8010804a,%edx
801046f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046f4:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801046f6:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801046fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046fd:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104700:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104703:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104706:	8b 40 1c             	mov    0x1c(%eax),%eax
80104709:	83 ec 04             	sub    $0x4,%esp
8010470c:	6a 14                	push   $0x14
8010470e:	6a 00                	push   $0x0
80104710:	50                   	push   %eax
80104711:	e8 b2 23 00 00       	call   80106ac8 <memset>
80104716:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104719:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010471c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010471f:	ba 7a 55 10 80       	mov    $0x8010557a,%edx
80104724:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104727:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010472a:	c9                   	leave  
8010472b:	c3                   	ret    

8010472c <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010472c:	55                   	push   %ebp
8010472d:	89 e5                	mov    %esp,%ebp
8010472f:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

#ifdef CS333_P3P4
  acquire(&ptable.lock);
80104732:	83 ec 0c             	sub    $0xc,%esp
80104735:	68 80 49 11 80       	push   $0x80114980
8010473a:	e8 26 21 00 00       	call   80106865 <acquire>
8010473f:	83 c4 10             	add    $0x10,%esp
  initProcessLists();
80104742:	e8 17 17 00 00       	call   80105e5e <initProcessLists>
  initFreeList();
80104747:	e8 b8 17 00 00       	call   80105f04 <initFreeList>
  ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
8010474c:	a1 20 79 11 80       	mov    0x80117920,%eax
80104751:	05 10 27 00 00       	add    $0x2710,%eax
80104756:	a3 0c 71 11 80       	mov    %eax,0x8011710c
  release(&ptable.lock);
8010475b:	83 ec 0c             	sub    $0xc,%esp
8010475e:	68 80 49 11 80       	push   $0x80114980
80104763:	e8 64 21 00 00       	call   801068cc <release>
80104768:	83 c4 10             	add    $0x10,%esp
#endif
  p = allocproc();
8010476b:	e8 a8 fd ff ff       	call   80104518 <allocproc>
80104770:	89 45 f4             	mov    %eax,-0xc(%ebp)

  initproc = p;
80104773:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104776:	a3 68 d6 10 80       	mov    %eax,0x8010d668
  if((p->pgdir = setupkvm()) == 0)
8010477b:	e8 8c 4f 00 00       	call   8010970c <setupkvm>
80104780:	89 c2                	mov    %eax,%edx
80104782:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104785:	89 50 04             	mov    %edx,0x4(%eax)
80104788:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010478b:	8b 40 04             	mov    0x4(%eax),%eax
8010478e:	85 c0                	test   %eax,%eax
80104790:	75 0d                	jne    8010479f <userinit+0x73>
    panic("userinit: out of memory?");
80104792:	83 ec 0c             	sub    $0xc,%esp
80104795:	68 fc a2 10 80       	push   $0x8010a2fc
8010479a:	e8 c7 bd ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010479f:	ba 2c 00 00 00       	mov    $0x2c,%edx
801047a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047a7:	8b 40 04             	mov    0x4(%eax),%eax
801047aa:	83 ec 04             	sub    $0x4,%esp
801047ad:	52                   	push   %edx
801047ae:	68 00 d5 10 80       	push   $0x8010d500
801047b3:	50                   	push   %eax
801047b4:	e8 ad 51 00 00       	call   80109966 <inituvm>
801047b9:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
801047bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047bf:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801047c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047c8:	8b 40 18             	mov    0x18(%eax),%eax
801047cb:	83 ec 04             	sub    $0x4,%esp
801047ce:	6a 4c                	push   $0x4c
801047d0:	6a 00                	push   $0x0
801047d2:	50                   	push   %eax
801047d3:	e8 f0 22 00 00       	call   80106ac8 <memset>
801047d8:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801047db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047de:	8b 40 18             	mov    0x18(%eax),%eax
801047e1:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801047e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ea:	8b 40 18             	mov    0x18(%eax),%eax
801047ed:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
801047f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047f6:	8b 40 18             	mov    0x18(%eax),%eax
801047f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047fc:	8b 52 18             	mov    0x18(%edx),%edx
801047ff:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104803:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104807:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010480a:	8b 40 18             	mov    0x18(%eax),%eax
8010480d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104810:	8b 52 18             	mov    0x18(%edx),%edx
80104813:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104817:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010481b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010481e:	8b 40 18             	mov    0x18(%eax),%eax
80104821:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010482b:	8b 40 18             	mov    0x18(%eax),%eax
8010482e:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104838:	8b 40 18             	mov    0x18(%eax),%eax
8010483b:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104842:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104845:	83 c0 6c             	add    $0x6c,%eax
80104848:	83 ec 04             	sub    $0x4,%esp
8010484b:	6a 10                	push   $0x10
8010484d:	68 15 a3 10 80       	push   $0x8010a315
80104852:	50                   	push   %eax
80104853:	e8 73 24 00 00       	call   80106ccb <safestrcpy>
80104858:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
8010485b:	83 ec 0c             	sub    $0xc,%esp
8010485e:	68 1e a3 10 80       	push   $0x8010a31e
80104863:	e8 5e dd ff ff       	call   801025c6 <namei>
80104868:	83 c4 10             	add    $0x10,%esp
8010486b:	89 c2                	mov    %eax,%edx
8010486d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104870:	89 50 68             	mov    %edx,0x68(%eax)

  p->state = RUNNABLE;
80104873:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104876:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
#ifdef CS333_P3P4
  acquire(&ptable.lock);
8010487d:	83 ec 0c             	sub    $0xc,%esp
80104880:	68 80 49 11 80       	push   $0x80114980
80104885:	e8 db 1f 00 00       	call   80106865 <acquire>
8010488a:	83 c4 10             	add    $0x10,%esp
  if(stateListRemove(&ptable.pLists.embryo, &ptable.pLists.embryoTail, p))
8010488d:	83 ec 04             	sub    $0x4,%esp
80104890:	ff 75 f4             	pushl  -0xc(%ebp)
80104893:	68 08 71 11 80       	push   $0x80117108
80104898:	68 04 71 11 80       	push   $0x80117104
8010489d:	e8 da 14 00 00       	call   80105d7c <stateListRemove>
801048a2:	83 c4 10             	add    $0x10,%esp
801048a5:	85 c0                	test   %eax,%eax
801048a7:	74 0d                	je     801048b6 <userinit+0x18a>
    panic("error removing from embryo list.");
801048a9:	83 ec 0c             	sub    $0xc,%esp
801048ac:	68 c0 a2 10 80       	push   $0x8010a2c0
801048b1:	e8 b0 bc ff ff       	call   80100566 <panic>
  if(stateListAdd(&ptable.pLists.ready[p->priority], &ptable.pLists.readyTail[p->priority], p))
801048b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b9:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801048bf:	05 d0 09 00 00       	add    $0x9d0,%eax
801048c4:	c1 e0 02             	shl    $0x2,%eax
801048c7:	05 80 49 11 80       	add    $0x80114980,%eax
801048cc:	8d 50 0c             	lea    0xc(%eax),%edx
801048cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048d2:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801048d8:	05 cc 09 00 00       	add    $0x9cc,%eax
801048dd:	c1 e0 02             	shl    $0x2,%eax
801048e0:	05 80 49 11 80       	add    $0x80114980,%eax
801048e5:	83 c0 04             	add    $0x4,%eax
801048e8:	83 ec 04             	sub    $0x4,%esp
801048eb:	ff 75 f4             	pushl  -0xc(%ebp)
801048ee:	52                   	push   %edx
801048ef:	50                   	push   %eax
801048f0:	e8 28 14 00 00       	call   80105d1d <stateListAdd>
801048f5:	83 c4 10             	add    $0x10,%esp
801048f8:	85 c0                	test   %eax,%eax
801048fa:	74 0d                	je     80104909 <userinit+0x1dd>
    panic("error adding to ready list.");
801048fc:	83 ec 0c             	sub    $0xc,%esp
801048ff:	68 20 a3 10 80       	push   $0x8010a320
80104904:	e8 5d bc ff ff       	call   80100566 <panic>
  assertState(p, RUNNABLE);
80104909:	83 ec 08             	sub    $0x8,%esp
8010490c:	6a 03                	push   $0x3
8010490e:	ff 75 f4             	pushl  -0xc(%ebp)
80104911:	e8 e6 1a 00 00       	call   801063fc <assertState>
80104916:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104919:	83 ec 0c             	sub    $0xc,%esp
8010491c:	68 80 49 11 80       	push   $0x80114980
80104921:	e8 a6 1f 00 00       	call   801068cc <release>
80104926:	83 c4 10             	add    $0x10,%esp
#endif
  p->uid = 0;
80104929:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010492c:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80104933:	00 00 00 
  p->gid = 0;
80104936:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104939:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
80104940:	00 00 00 
}
80104943:	90                   	nop
80104944:	c9                   	leave  
80104945:	c3                   	ret    

80104946 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104946:	55                   	push   %ebp
80104947:	89 e5                	mov    %esp,%ebp
80104949:	83 ec 18             	sub    $0x18,%esp
  uint sz;

  sz = proc->sz;
8010494c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104952:	8b 00                	mov    (%eax),%eax
80104954:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104957:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010495b:	7e 31                	jle    8010498e <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
8010495d:	8b 55 08             	mov    0x8(%ebp),%edx
80104960:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104963:	01 c2                	add    %eax,%edx
80104965:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010496b:	8b 40 04             	mov    0x4(%eax),%eax
8010496e:	83 ec 04             	sub    $0x4,%esp
80104971:	52                   	push   %edx
80104972:	ff 75 f4             	pushl  -0xc(%ebp)
80104975:	50                   	push   %eax
80104976:	e8 38 51 00 00       	call   80109ab3 <allocuvm>
8010497b:	83 c4 10             	add    $0x10,%esp
8010497e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104981:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104985:	75 3e                	jne    801049c5 <growproc+0x7f>
      return -1;
80104987:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010498c:	eb 59                	jmp    801049e7 <growproc+0xa1>
  } else if(n < 0){
8010498e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104992:	79 31                	jns    801049c5 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104994:	8b 55 08             	mov    0x8(%ebp),%edx
80104997:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010499a:	01 c2                	add    %eax,%edx
8010499c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049a2:	8b 40 04             	mov    0x4(%eax),%eax
801049a5:	83 ec 04             	sub    $0x4,%esp
801049a8:	52                   	push   %edx
801049a9:	ff 75 f4             	pushl  -0xc(%ebp)
801049ac:	50                   	push   %eax
801049ad:	e8 ca 51 00 00       	call   80109b7c <deallocuvm>
801049b2:	83 c4 10             	add    $0x10,%esp
801049b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801049b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801049bc:	75 07                	jne    801049c5 <growproc+0x7f>
      return -1;
801049be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049c3:	eb 22                	jmp    801049e7 <growproc+0xa1>
  }
  proc->sz = sz;
801049c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049ce:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
801049d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049d6:	83 ec 0c             	sub    $0xc,%esp
801049d9:	50                   	push   %eax
801049da:	e8 14 4e 00 00       	call   801097f3 <switchuvm>
801049df:	83 c4 10             	add    $0x10,%esp
  return 0;
801049e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801049e7:	c9                   	leave  
801049e8:	c3                   	ret    

801049e9 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801049e9:	55                   	push   %ebp
801049ea:	89 e5                	mov    %esp,%ebp
801049ec:	57                   	push   %edi
801049ed:	56                   	push   %esi
801049ee:	53                   	push   %ebx
801049ef:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
801049f2:	e8 21 fb ff ff       	call   80104518 <allocproc>
801049f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
801049fa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801049fe:	75 0a                	jne    80104a0a <fork+0x21>
    return -1;
80104a00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a05:	e9 be 02 00 00       	jmp    80104cc8 <fork+0x2df>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104a0a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a10:	8b 10                	mov    (%eax),%edx
80104a12:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a18:	8b 40 04             	mov    0x4(%eax),%eax
80104a1b:	83 ec 08             	sub    $0x8,%esp
80104a1e:	52                   	push   %edx
80104a1f:	50                   	push   %eax
80104a20:	e8 f5 52 00 00       	call   80109d1a <copyuvm>
80104a25:	83 c4 10             	add    $0x10,%esp
80104a28:	89 c2                	mov    %eax,%edx
80104a2a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a2d:	89 50 04             	mov    %edx,0x4(%eax)
80104a30:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a33:	8b 40 04             	mov    0x4(%eax),%eax
80104a36:	85 c0                	test   %eax,%eax
80104a38:	0f 85 b2 00 00 00    	jne    80104af0 <fork+0x107>
    kfree(np->kstack);
80104a3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a41:	8b 40 08             	mov    0x8(%eax),%eax
80104a44:	83 ec 0c             	sub    $0xc,%esp
80104a47:	50                   	push   %eax
80104a48:	e8 1a e2 ff ff       	call   80102c67 <kfree>
80104a4d:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104a50:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a53:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104a5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a5d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
#ifdef CS333_P3P4
    acquire(&ptable.lock);
80104a64:	83 ec 0c             	sub    $0xc,%esp
80104a67:	68 80 49 11 80       	push   $0x80114980
80104a6c:	e8 f4 1d 00 00       	call   80106865 <acquire>
80104a71:	83 c4 10             	add    $0x10,%esp
    if(stateListRemove(&ptable.pLists.embryo, &ptable.pLists.embryoTail, np))
80104a74:	83 ec 04             	sub    $0x4,%esp
80104a77:	ff 75 e0             	pushl  -0x20(%ebp)
80104a7a:	68 08 71 11 80       	push   $0x80117108
80104a7f:	68 04 71 11 80       	push   $0x80117104
80104a84:	e8 f3 12 00 00       	call   80105d7c <stateListRemove>
80104a89:	83 c4 10             	add    $0x10,%esp
80104a8c:	85 c0                	test   %eax,%eax
80104a8e:	74 0d                	je     80104a9d <fork+0xb4>
      panic("error removing from embryo.");
80104a90:	83 ec 0c             	sub    $0xc,%esp
80104a93:	68 3c a3 10 80       	push   $0x8010a33c
80104a98:	e8 c9 ba ff ff       	call   80100566 <panic>
    if(stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail, np))
80104a9d:	83 ec 04             	sub    $0x4,%esp
80104aa0:	ff 75 e0             	pushl  -0x20(%ebp)
80104aa3:	68 e8 70 11 80       	push   $0x801170e8
80104aa8:	68 e4 70 11 80       	push   $0x801170e4
80104aad:	e8 6b 12 00 00       	call   80105d1d <stateListAdd>
80104ab2:	83 c4 10             	add    $0x10,%esp
80104ab5:	85 c0                	test   %eax,%eax
80104ab7:	74 0d                	je     80104ac6 <fork+0xdd>
      panic("error adding to freelist.");
80104ab9:	83 ec 0c             	sub    $0xc,%esp
80104abc:	68 58 a3 10 80       	push   $0x8010a358
80104ac1:	e8 a0 ba ff ff       	call   80100566 <panic>
    assertState(np, UNUSED);
80104ac6:	83 ec 08             	sub    $0x8,%esp
80104ac9:	6a 00                	push   $0x0
80104acb:	ff 75 e0             	pushl  -0x20(%ebp)
80104ace:	e8 29 19 00 00       	call   801063fc <assertState>
80104ad3:	83 c4 10             	add    $0x10,%esp
    release(&ptable.lock);
80104ad6:	83 ec 0c             	sub    $0xc,%esp
80104ad9:	68 80 49 11 80       	push   $0x80114980
80104ade:	e8 e9 1d 00 00       	call   801068cc <release>
80104ae3:	83 c4 10             	add    $0x10,%esp
#endif
    return -1;
80104ae6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104aeb:	e9 d8 01 00 00       	jmp    80104cc8 <fork+0x2df>
  }
  np->sz = proc->sz;
80104af0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104af6:	8b 10                	mov    (%eax),%edx
80104af8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104afb:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104afd:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104b04:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b07:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104b0a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b0d:	8b 50 18             	mov    0x18(%eax),%edx
80104b10:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b16:	8b 40 18             	mov    0x18(%eax),%eax
80104b19:	89 c3                	mov    %eax,%ebx
80104b1b:	b8 13 00 00 00       	mov    $0x13,%eax
80104b20:	89 d7                	mov    %edx,%edi
80104b22:	89 de                	mov    %ebx,%esi
80104b24:	89 c1                	mov    %eax,%ecx
80104b26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104b28:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b2b:	8b 40 18             	mov    0x18(%eax),%eax
80104b2e:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104b35:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104b3c:	eb 43                	jmp    80104b81 <fork+0x198>
    if(proc->ofile[i])
80104b3e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b44:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104b47:	83 c2 08             	add    $0x8,%edx
80104b4a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104b4e:	85 c0                	test   %eax,%eax
80104b50:	74 2b                	je     80104b7d <fork+0x194>
      np->ofile[i] = filedup(proc->ofile[i]);
80104b52:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b58:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104b5b:	83 c2 08             	add    $0x8,%edx
80104b5e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104b62:	83 ec 0c             	sub    $0xc,%esp
80104b65:	50                   	push   %eax
80104b66:	e8 33 c5 ff ff       	call   8010109e <filedup>
80104b6b:	83 c4 10             	add    $0x10,%esp
80104b6e:	89 c1                	mov    %eax,%ecx
80104b70:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b73:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104b76:	83 c2 08             	add    $0x8,%edx
80104b79:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104b7d:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104b81:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104b85:	7e b7                	jle    80104b3e <fork+0x155>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104b87:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b8d:	8b 40 68             	mov    0x68(%eax),%eax
80104b90:	83 ec 0c             	sub    $0xc,%esp
80104b93:	50                   	push   %eax
80104b94:	e8 35 ce ff ff       	call   801019ce <idup>
80104b99:	83 c4 10             	add    $0x10,%esp
80104b9c:	89 c2                	mov    %eax,%edx
80104b9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ba1:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104ba4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104baa:	8d 50 6c             	lea    0x6c(%eax),%edx
80104bad:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104bb0:	83 c0 6c             	add    $0x6c,%eax
80104bb3:	83 ec 04             	sub    $0x4,%esp
80104bb6:	6a 10                	push   $0x10
80104bb8:	52                   	push   %edx
80104bb9:	50                   	push   %eax
80104bba:	e8 0c 21 00 00       	call   80106ccb <safestrcpy>
80104bbf:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104bc2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104bc5:	8b 40 10             	mov    0x10(%eax),%eax
80104bc8:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104bcb:	83 ec 0c             	sub    $0xc,%esp
80104bce:	68 80 49 11 80       	push   $0x80114980
80104bd3:	e8 8d 1c 00 00       	call   80106865 <acquire>
80104bd8:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
80104bdb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104bde:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
#ifdef CS333_P3P4
  np->priority = 0;
80104be5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104be8:	c7 80 98 00 00 00 00 	movl   $0x0,0x98(%eax)
80104bef:	00 00 00 
  np->budget = BUDGET;
80104bf2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104bf5:	c7 80 94 00 00 00 64 	movl   $0x64,0x94(%eax)
80104bfc:	00 00 00 
  if(stateListRemove(&ptable.pLists.embryo, &ptable.pLists.embryoTail, np))
80104bff:	83 ec 04             	sub    $0x4,%esp
80104c02:	ff 75 e0             	pushl  -0x20(%ebp)
80104c05:	68 08 71 11 80       	push   $0x80117108
80104c0a:	68 04 71 11 80       	push   $0x80117104
80104c0f:	e8 68 11 00 00       	call   80105d7c <stateListRemove>
80104c14:	83 c4 10             	add    $0x10,%esp
80104c17:	85 c0                	test   %eax,%eax
80104c19:	74 0d                	je     80104c28 <fork+0x23f>
    panic("error removing from embryo.");
80104c1b:	83 ec 0c             	sub    $0xc,%esp
80104c1e:	68 3c a3 10 80       	push   $0x8010a33c
80104c23:	e8 3e b9 ff ff       	call   80100566 <panic>
  if(stateListAdd(&ptable.pLists.ready[np->priority], &ptable.pLists.readyTail[np->priority], np))
80104c28:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c2b:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80104c31:	05 d0 09 00 00       	add    $0x9d0,%eax
80104c36:	c1 e0 02             	shl    $0x2,%eax
80104c39:	05 80 49 11 80       	add    $0x80114980,%eax
80104c3e:	8d 50 0c             	lea    0xc(%eax),%edx
80104c41:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c44:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80104c4a:	05 cc 09 00 00       	add    $0x9cc,%eax
80104c4f:	c1 e0 02             	shl    $0x2,%eax
80104c52:	05 80 49 11 80       	add    $0x80114980,%eax
80104c57:	83 c0 04             	add    $0x4,%eax
80104c5a:	83 ec 04             	sub    $0x4,%esp
80104c5d:	ff 75 e0             	pushl  -0x20(%ebp)
80104c60:	52                   	push   %edx
80104c61:	50                   	push   %eax
80104c62:	e8 b6 10 00 00       	call   80105d1d <stateListAdd>
80104c67:	83 c4 10             	add    $0x10,%esp
80104c6a:	85 c0                	test   %eax,%eax
80104c6c:	74 0d                	je     80104c7b <fork+0x292>
    panic("error adding to ready list.");
80104c6e:	83 ec 0c             	sub    $0xc,%esp
80104c71:	68 20 a3 10 80       	push   $0x8010a320
80104c76:	e8 eb b8 ff ff       	call   80100566 <panic>
  assertState(np, RUNNABLE);
80104c7b:	83 ec 08             	sub    $0x8,%esp
80104c7e:	6a 03                	push   $0x3
80104c80:	ff 75 e0             	pushl  -0x20(%ebp)
80104c83:	e8 74 17 00 00       	call   801063fc <assertState>
80104c88:	83 c4 10             	add    $0x10,%esp
#endif
  release(&ptable.lock);
80104c8b:	83 ec 0c             	sub    $0xc,%esp
80104c8e:	68 80 49 11 80       	push   $0x80114980
80104c93:	e8 34 1c 00 00       	call   801068cc <release>
80104c98:	83 c4 10             	add    $0x10,%esp

  np->uid = proc->uid;
80104c9b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ca1:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104ca7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104caa:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  np->gid = proc->gid;
80104cb0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cb6:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80104cbc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104cbf:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)

  return pid;
80104cc5:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104cc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104ccb:	5b                   	pop    %ebx
80104ccc:	5e                   	pop    %esi
80104ccd:	5f                   	pop    %edi
80104cce:	5d                   	pop    %ebp
80104ccf:	c3                   	ret    

80104cd0 <exit>:
  panic("zombie exit");
}
#else
void
exit(void)
{
80104cd0:	55                   	push   %ebp
80104cd1:	89 e5                	mov    %esp,%ebp
80104cd3:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104cd6:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104cdd:	a1 68 d6 10 80       	mov    0x8010d668,%eax
80104ce2:	39 c2                	cmp    %eax,%edx
80104ce4:	75 0d                	jne    80104cf3 <exit+0x23>
    panic("init exiting");
80104ce6:	83 ec 0c             	sub    $0xc,%esp
80104ce9:	68 72 a3 10 80       	push   $0x8010a372
80104cee:	e8 73 b8 ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104cf3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104cfa:	eb 48                	jmp    80104d44 <exit+0x74>
    if(proc->ofile[fd]){
80104cfc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d02:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d05:	83 c2 08             	add    $0x8,%edx
80104d08:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104d0c:	85 c0                	test   %eax,%eax
80104d0e:	74 30                	je     80104d40 <exit+0x70>
      fileclose(proc->ofile[fd]);
80104d10:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d16:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d19:	83 c2 08             	add    $0x8,%edx
80104d1c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104d20:	83 ec 0c             	sub    $0xc,%esp
80104d23:	50                   	push   %eax
80104d24:	e8 c6 c3 ff ff       	call   801010ef <fileclose>
80104d29:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80104d2c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d32:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d35:	83 c2 08             	add    $0x8,%edx
80104d38:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104d3f:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104d40:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104d44:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104d48:	7e b2                	jle    80104cfc <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104d4a:	e8 9c e8 ff ff       	call   801035eb <begin_op>
  iput(proc->cwd);
80104d4f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d55:	8b 40 68             	mov    0x68(%eax),%eax
80104d58:	83 ec 0c             	sub    $0xc,%esp
80104d5b:	50                   	push   %eax
80104d5c:	e8 77 ce ff ff       	call   80101bd8 <iput>
80104d61:	83 c4 10             	add    $0x10,%esp
  end_op();
80104d64:	e8 0e e9 ff ff       	call   80103677 <end_op>
  proc->cwd = 0;
80104d69:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d6f:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104d76:	83 ec 0c             	sub    $0xc,%esp
80104d79:	68 80 49 11 80       	push   $0x80114980
80104d7e:	e8 e2 1a 00 00       	call   80106865 <acquire>
80104d83:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104d86:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d8c:	8b 40 14             	mov    0x14(%eax),%eax
80104d8f:	83 ec 0c             	sub    $0xc,%esp
80104d92:	50                   	push   %eax
80104d93:	e8 cd 09 00 00       	call   80105765 <wakeup1>
80104d98:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(int i = 0; i< MAXPRIO; ++i)
80104d9b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80104da2:	eb 46                	jmp    80104dea <exit+0x11a>
  {
    for(p = ptable.pLists.ready[i];p;p=p->next)
80104da4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104da7:	05 cc 09 00 00       	add    $0x9cc,%eax
80104dac:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
80104db3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104db6:	eb 28                	jmp    80104de0 <exit+0x110>
    {
      if(p->parent == proc)
80104db8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dbb:	8b 50 14             	mov    0x14(%eax),%edx
80104dbe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dc4:	39 c2                	cmp    %eax,%edx
80104dc6:	75 0c                	jne    80104dd4 <exit+0x104>
        p->parent = initproc;
80104dc8:	8b 15 68 d6 10 80    	mov    0x8010d668,%edx
80104dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dd1:	89 50 14             	mov    %edx,0x14(%eax)
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(int i = 0; i< MAXPRIO; ++i)
  {
    for(p = ptable.pLists.ready[i];p;p=p->next)
80104dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dd7:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104ddd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104de0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104de4:	75 d2                	jne    80104db8 <exit+0xe8>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(int i = 0; i< MAXPRIO; ++i)
80104de6:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80104dea:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
80104dee:	7e b4                	jle    80104da4 <exit+0xd4>
    {
      if(p->parent == proc)
        p->parent = initproc;
    }
  }
  for(p = ptable.pLists.sleep;p;p=p->next)
80104df0:	a1 ec 70 11 80       	mov    0x801170ec,%eax
80104df5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104df8:	eb 28                	jmp    80104e22 <exit+0x152>
  {
    if(p->parent == proc)
80104dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dfd:	8b 50 14             	mov    0x14(%eax),%edx
80104e00:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e06:	39 c2                	cmp    %eax,%edx
80104e08:	75 0c                	jne    80104e16 <exit+0x146>
      p->parent = initproc;
80104e0a:	8b 15 68 d6 10 80    	mov    0x8010d668,%edx
80104e10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e13:	89 50 14             	mov    %edx,0x14(%eax)
    {
      if(p->parent == proc)
        p->parent = initproc;
    }
  }
  for(p = ptable.pLists.sleep;p;p=p->next)
80104e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e19:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104e1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e22:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e26:	75 d2                	jne    80104dfa <exit+0x12a>
  {
    if(p->parent == proc)
      p->parent = initproc;
  }
  for(p = ptable.pLists.embryo;p;p=p->next)
80104e28:	a1 04 71 11 80       	mov    0x80117104,%eax
80104e2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e30:	eb 28                	jmp    80104e5a <exit+0x18a>
  {
    if(p->parent == proc)
80104e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e35:	8b 50 14             	mov    0x14(%eax),%edx
80104e38:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e3e:	39 c2                	cmp    %eax,%edx
80104e40:	75 0c                	jne    80104e4e <exit+0x17e>
      p->parent = initproc;
80104e42:	8b 15 68 d6 10 80    	mov    0x8010d668,%edx
80104e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e4b:	89 50 14             	mov    %edx,0x14(%eax)
  for(p = ptable.pLists.sleep;p;p=p->next)
  {
    if(p->parent == proc)
      p->parent = initproc;
  }
  for(p = ptable.pLists.embryo;p;p=p->next)
80104e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e51:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104e57:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e5a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e5e:	75 d2                	jne    80104e32 <exit+0x162>
  {
    if(p->parent == proc)
      p->parent = initproc;
  }
  for(p=ptable.pLists.running;p;p=p->next)
80104e60:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80104e65:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e68:	eb 28                	jmp    80104e92 <exit+0x1c2>
  {
    if(p->parent == proc)
80104e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e6d:	8b 50 14             	mov    0x14(%eax),%edx
80104e70:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e76:	39 c2                	cmp    %eax,%edx
80104e78:	75 0c                	jne    80104e86 <exit+0x1b6>
      p->parent = initproc;
80104e7a:	8b 15 68 d6 10 80    	mov    0x8010d668,%edx
80104e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e83:	89 50 14             	mov    %edx,0x14(%eax)
  for(p = ptable.pLists.embryo;p;p=p->next)
  {
    if(p->parent == proc)
      p->parent = initproc;
  }
  for(p=ptable.pLists.running;p;p=p->next)
80104e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e89:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104e8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e92:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e96:	75 d2                	jne    80104e6a <exit+0x19a>
    if(p->parent == proc)
      p->parent = initproc;
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104e98:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e9e:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  if(stateListRemove(&ptable.pLists.running, &ptable.pLists.runningTail, proc))
80104ea5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104eab:	83 ec 04             	sub    $0x4,%esp
80104eae:	50                   	push   %eax
80104eaf:	68 00 71 11 80       	push   $0x80117100
80104eb4:	68 fc 70 11 80       	push   $0x801170fc
80104eb9:	e8 be 0e 00 00       	call   80105d7c <stateListRemove>
80104ebe:	83 c4 10             	add    $0x10,%esp
80104ec1:	85 c0                	test   %eax,%eax
80104ec3:	74 0d                	je     80104ed2 <exit+0x202>
    panic("Error removing from running.");
80104ec5:	83 ec 0c             	sub    $0xc,%esp
80104ec8:	68 7f a3 10 80       	push   $0x8010a37f
80104ecd:	e8 94 b6 ff ff       	call   80100566 <panic>
  if(stateListAdd(&ptable.pLists.zombie, &ptable.pLists.zombieTail, proc))
80104ed2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ed8:	83 ec 04             	sub    $0x4,%esp
80104edb:	50                   	push   %eax
80104edc:	68 f8 70 11 80       	push   $0x801170f8
80104ee1:	68 f4 70 11 80       	push   $0x801170f4
80104ee6:	e8 32 0e 00 00       	call   80105d1d <stateListAdd>
80104eeb:	83 c4 10             	add    $0x10,%esp
80104eee:	85 c0                	test   %eax,%eax
80104ef0:	74 0d                	je     80104eff <exit+0x22f>
    panic("error adding to zombie list.");
80104ef2:	83 ec 0c             	sub    $0xc,%esp
80104ef5:	68 9c a3 10 80       	push   $0x8010a39c
80104efa:	e8 67 b6 ff ff       	call   80100566 <panic>
  assertState(proc, ZOMBIE);
80104eff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f05:	83 ec 08             	sub    $0x8,%esp
80104f08:	6a 05                	push   $0x5
80104f0a:	50                   	push   %eax
80104f0b:	e8 ec 14 00 00       	call   801063fc <assertState>
80104f10:	83 c4 10             	add    $0x10,%esp
  sched();
80104f13:	e8 57 04 00 00       	call   8010536f <sched>
  panic("zombie exit");
80104f18:	83 ec 0c             	sub    $0xc,%esp
80104f1b:	68 b9 a3 10 80       	push   $0x8010a3b9
80104f20:	e8 41 b6 ff ff       	call   80100566 <panic>

80104f25 <wait>:
  }
}
#else
int
wait(void)
{
80104f25:	55                   	push   %ebp
80104f26:	89 e5                	mov    %esp,%ebp
80104f28:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104f2b:	83 ec 0c             	sub    $0xc,%esp
80104f2e:	68 80 49 11 80       	push   $0x80114980
80104f33:	e8 2d 19 00 00       	call   80106865 <acquire>
80104f38:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104f3b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.pLists.zombie; p; p=p->next){
80104f42:	a1 f4 70 11 80       	mov    0x801170f4,%eax
80104f47:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104f4a:	e9 08 01 00 00       	jmp    80105057 <wait+0x132>
      if(p->parent != proc)
80104f4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f52:	8b 50 14             	mov    0x14(%eax),%edx
80104f55:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f5b:	39 c2                	cmp    %eax,%edx
80104f5d:	74 11                	je     80104f70 <wait+0x4b>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.pLists.zombie; p; p=p->next){
80104f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f62:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104f68:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104f6b:	e9 e7 00 00 00       	jmp    80105057 <wait+0x132>
      if(p->parent != proc)
        continue;

      havekids = 1;
80104f70:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      // Found one.
      pid = p->pid;
80104f77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f7a:	8b 40 10             	mov    0x10(%eax),%eax
80104f7d:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(p->kstack);
80104f80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f83:	8b 40 08             	mov    0x8(%eax),%eax
80104f86:	83 ec 0c             	sub    $0xc,%esp
80104f89:	50                   	push   %eax
80104f8a:	e8 d8 dc ff ff       	call   80102c67 <kfree>
80104f8f:	83 c4 10             	add    $0x10,%esp
      p->kstack = 0;
80104f92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f95:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
      freevm(p->pgdir);
80104f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f9f:	8b 40 04             	mov    0x4(%eax),%eax
80104fa2:	83 ec 0c             	sub    $0xc,%esp
80104fa5:	50                   	push   %eax
80104fa6:	e8 8e 4c 00 00       	call   80109c39 <freevm>
80104fab:	83 c4 10             	add    $0x10,%esp
      p->state = UNUSED;
80104fae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fb1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
      if(stateListRemove(&ptable.pLists.zombie, &ptable.pLists.zombieTail,p))
80104fb8:	83 ec 04             	sub    $0x4,%esp
80104fbb:	ff 75 f4             	pushl  -0xc(%ebp)
80104fbe:	68 f8 70 11 80       	push   $0x801170f8
80104fc3:	68 f4 70 11 80       	push   $0x801170f4
80104fc8:	e8 af 0d 00 00       	call   80105d7c <stateListRemove>
80104fcd:	83 c4 10             	add    $0x10,%esp
80104fd0:	85 c0                	test   %eax,%eax
80104fd2:	74 0d                	je     80104fe1 <wait+0xbc>
        panic("Error removing from zombie list.");
80104fd4:	83 ec 0c             	sub    $0xc,%esp
80104fd7:	68 c8 a3 10 80       	push   $0x8010a3c8
80104fdc:	e8 85 b5 ff ff       	call   80100566 <panic>
      if(stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail,p))
80104fe1:	83 ec 04             	sub    $0x4,%esp
80104fe4:	ff 75 f4             	pushl  -0xc(%ebp)
80104fe7:	68 e8 70 11 80       	push   $0x801170e8
80104fec:	68 e4 70 11 80       	push   $0x801170e4
80104ff1:	e8 27 0d 00 00       	call   80105d1d <stateListAdd>
80104ff6:	83 c4 10             	add    $0x10,%esp
80104ff9:	85 c0                	test   %eax,%eax
80104ffb:	74 0d                	je     8010500a <wait+0xe5>
        panic("Error adding to free list.");
80104ffd:	83 ec 0c             	sub    $0xc,%esp
80105000:	68 e9 a3 10 80       	push   $0x8010a3e9
80105005:	e8 5c b5 ff ff       	call   80100566 <panic>
      assertState(p, UNUSED);
8010500a:	83 ec 08             	sub    $0x8,%esp
8010500d:	6a 00                	push   $0x0
8010500f:	ff 75 f4             	pushl  -0xc(%ebp)
80105012:	e8 e5 13 00 00       	call   801063fc <assertState>
80105017:	83 c4 10             	add    $0x10,%esp
      p->pid = 0;
8010501a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010501d:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
      p->parent = 0;
80105024:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105027:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
      p->name[0] = 0;
8010502e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105031:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
      p->killed = 0;
80105035:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105038:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
      release(&ptable.lock);
8010503f:	83 ec 0c             	sub    $0xc,%esp
80105042:	68 80 49 11 80       	push   $0x80114980
80105047:	e8 80 18 00 00       	call   801068cc <release>
8010504c:	83 c4 10             	add    $0x10,%esp
      return pid;
8010504f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105052:	e9 44 01 00 00       	jmp    8010519b <wait+0x276>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.pLists.zombie; p; p=p->next){
80105057:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010505b:	0f 85 ee fe ff ff    	jne    80104f4f <wait+0x2a>
      release(&ptable.lock);
      return pid;

    }

    for(int i = 0; i < MAXPRIO; ++i)
80105061:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80105068:	eb 46                	jmp    801050b0 <wait+0x18b>
    {
      for(p = ptable.pLists.ready[i];p;p=p->next)
8010506a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010506d:	05 cc 09 00 00       	add    $0x9cc,%eax
80105072:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
80105079:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010507c:	eb 28                	jmp    801050a6 <wait+0x181>
      {
        if(p->parent == proc)
8010507e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105081:	8b 50 14             	mov    0x14(%eax),%edx
80105084:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010508a:	39 c2                	cmp    %eax,%edx
8010508c:	75 0c                	jne    8010509a <wait+0x175>
        {
          havekids = 1;
8010508e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
          goto kids;
80105095:	e9 bb 00 00 00       	jmp    80105155 <wait+0x230>

    }

    for(int i = 0; i < MAXPRIO; ++i)
    {
      for(p = ptable.pLists.ready[i];p;p=p->next)
8010509a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010509d:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801050a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801050a6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801050aa:	75 d2                	jne    8010507e <wait+0x159>
      release(&ptable.lock);
      return pid;

    }

    for(int i = 0; i < MAXPRIO; ++i)
801050ac:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801050b0:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
801050b4:	7e b4                	jle    8010506a <wait+0x145>
          havekids = 1;
          goto kids;
        }
      }
    }
    for(p = ptable.pLists.sleep;p;p=p->next)
801050b6:	a1 ec 70 11 80       	mov    0x801170ec,%eax
801050bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801050be:	eb 25                	jmp    801050e5 <wait+0x1c0>
    {
      if(p->parent == proc)
801050c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050c3:	8b 50 14             	mov    0x14(%eax),%edx
801050c6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050cc:	39 c2                	cmp    %eax,%edx
801050ce:	75 09                	jne    801050d9 <wait+0x1b4>
      {
        havekids = 1;
801050d0:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
        goto kids;
801050d7:	eb 7c                	jmp    80105155 <wait+0x230>
          havekids = 1;
          goto kids;
        }
      }
    }
    for(p = ptable.pLists.sleep;p;p=p->next)
801050d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050dc:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801050e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801050e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801050e9:	75 d5                	jne    801050c0 <wait+0x19b>
      {
        havekids = 1;
        goto kids;
      }
    }
    for(p = ptable.pLists.embryo;p;p=p->next)
801050eb:	a1 04 71 11 80       	mov    0x80117104,%eax
801050f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801050f3:	eb 25                	jmp    8010511a <wait+0x1f5>
    {
      if(p->parent == proc)
801050f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050f8:	8b 50 14             	mov    0x14(%eax),%edx
801050fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105101:	39 c2                	cmp    %eax,%edx
80105103:	75 09                	jne    8010510e <wait+0x1e9>
      {
        havekids = 1;
80105105:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
        goto kids;
8010510c:	eb 47                	jmp    80105155 <wait+0x230>
      {
        havekids = 1;
        goto kids;
      }
    }
    for(p = ptable.pLists.embryo;p;p=p->next)
8010510e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105111:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105117:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010511a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010511e:	75 d5                	jne    801050f5 <wait+0x1d0>
      {
        havekids = 1;
        goto kids;
      }
    }
    for(p=ptable.pLists.running;p;p=p->next)
80105120:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80105125:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105128:	eb 25                	jmp    8010514f <wait+0x22a>
    {
      if(p->parent == proc)
8010512a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010512d:	8b 50 14             	mov    0x14(%eax),%edx
80105130:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105136:	39 c2                	cmp    %eax,%edx
80105138:	75 09                	jne    80105143 <wait+0x21e>
      {
        havekids = 1;
8010513a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
        goto kids;
80105141:	eb 12                	jmp    80105155 <wait+0x230>
      {
        havekids = 1;
        goto kids;
      }
    }
    for(p=ptable.pLists.running;p;p=p->next)
80105143:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105146:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010514c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010514f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105153:	75 d5                	jne    8010512a <wait+0x205>
      }
    }

    kids:
    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80105155:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105159:	74 0d                	je     80105168 <wait+0x243>
8010515b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105161:	8b 40 24             	mov    0x24(%eax),%eax
80105164:	85 c0                	test   %eax,%eax
80105166:	74 17                	je     8010517f <wait+0x25a>
      release(&ptable.lock);
80105168:	83 ec 0c             	sub    $0xc,%esp
8010516b:	68 80 49 11 80       	push   $0x80114980
80105170:	e8 57 17 00 00       	call   801068cc <release>
80105175:	83 c4 10             	add    $0x10,%esp
      return -1;
80105178:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010517d:	eb 1c                	jmp    8010519b <wait+0x276>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
8010517f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105185:	83 ec 08             	sub    $0x8,%esp
80105188:	68 80 49 11 80       	push   $0x80114980
8010518d:	50                   	push   %eax
8010518e:	e8 2d 04 00 00       	call   801055c0 <sleep>
80105193:	83 c4 10             	add    $0x10,%esp
  }
80105196:	e9 a0 fd ff ff       	jmp    80104f3b <wait+0x16>
}
8010519b:	c9                   	leave  
8010519c:	c3                   	ret    

8010519d <scheduler>:
}

#else
void
scheduler(void)
{
8010519d:	55                   	push   %ebp
8010519e:	89 e5                	mov    %esp,%ebp
801051a0:	53                   	push   %ebx
801051a1:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;
  int idle;  // for checking if processor is idle

  for(;;){
    // Enable interrupts on this processor.
    sti();
801051a4:	e8 4a f3 ff ff       	call   801044f3 <sti>

    idle = 1;  // assume idle unless we schedule a process
801051a9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801051b0:	83 ec 0c             	sub    $0xc,%esp
801051b3:	68 80 49 11 80       	push   $0x80114980
801051b8:	e8 a8 16 00 00       	call   80106865 <acquire>
801051bd:	83 c4 10             	add    $0x10,%esp
    if(ticks >= ptable.PromoteAtTime)
801051c0:	8b 15 0c 71 11 80    	mov    0x8011710c,%edx
801051c6:	a1 20 79 11 80       	mov    0x80117920,%eax
801051cb:	39 c2                	cmp    %eax,%edx
801051cd:	77 14                	ja     801051e3 <scheduler+0x46>
    {
      promoteAll();
801051cf:	e8 77 14 00 00       	call   8010664b <promoteAll>
      ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
801051d4:	a1 20 79 11 80       	mov    0x80117920,%eax
801051d9:	05 10 27 00 00       	add    $0x2710,%eax
801051de:	a3 0c 71 11 80       	mov    %eax,0x8011710c
    }
    for(int i = 0; i < MAXPRIO; ++i)
801051e3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801051ea:	e9 4d 01 00 00       	jmp    8010533c <scheduler+0x19f>
    {
      for(p = ptable.pLists.ready[i]; p; p = p->next){
801051ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801051f2:	05 cc 09 00 00       	add    $0x9cc,%eax
801051f7:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
801051fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105201:	e9 28 01 00 00       	jmp    8010532e <scheduler+0x191>

        // Switch to chosen process.  It is the process's job
        // to release ptable.lock and then reacquire it
        // before jumping back to us.
        idle = 0;  // not idle this timeslice
80105206:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
        proc = p;
8010520d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105210:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
        switchuvm(p);
80105216:	83 ec 0c             	sub    $0xc,%esp
80105219:	ff 75 f4             	pushl  -0xc(%ebp)
8010521c:	e8 d2 45 00 00       	call   801097f3 <switchuvm>
80105221:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNING;
80105224:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105227:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
        if(stateListRemove(&ptable.pLists.ready[i], &ptable.pLists.readyTail[i], p))
8010522e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105231:	05 d0 09 00 00       	add    $0x9d0,%eax
80105236:	c1 e0 02             	shl    $0x2,%eax
80105239:	05 80 49 11 80       	add    $0x80114980,%eax
8010523e:	8d 50 0c             	lea    0xc(%eax),%edx
80105241:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105244:	05 cc 09 00 00       	add    $0x9cc,%eax
80105249:	c1 e0 02             	shl    $0x2,%eax
8010524c:	05 80 49 11 80       	add    $0x80114980,%eax
80105251:	83 c0 04             	add    $0x4,%eax
80105254:	83 ec 04             	sub    $0x4,%esp
80105257:	ff 75 f4             	pushl  -0xc(%ebp)
8010525a:	52                   	push   %edx
8010525b:	50                   	push   %eax
8010525c:	e8 1b 0b 00 00       	call   80105d7c <stateListRemove>
80105261:	83 c4 10             	add    $0x10,%esp
80105264:	85 c0                	test   %eax,%eax
80105266:	74 0d                	je     80105275 <scheduler+0xd8>
          panic("problem with removing from ready list.");
80105268:	83 ec 0c             	sub    $0xc,%esp
8010526b:	68 04 a4 10 80       	push   $0x8010a404
80105270:	e8 f1 b2 ff ff       	call   80100566 <panic>
        if(stateListAdd(&ptable.pLists.running, &ptable.pLists.runningTail, p))
80105275:	83 ec 04             	sub    $0x4,%esp
80105278:	ff 75 f4             	pushl  -0xc(%ebp)
8010527b:	68 00 71 11 80       	push   $0x80117100
80105280:	68 fc 70 11 80       	push   $0x801170fc
80105285:	e8 93 0a 00 00       	call   80105d1d <stateListAdd>
8010528a:	83 c4 10             	add    $0x10,%esp
8010528d:	85 c0                	test   %eax,%eax
8010528f:	74 0d                	je     8010529e <scheduler+0x101>
          panic("problem with adding to running list.");
80105291:	83 ec 0c             	sub    $0xc,%esp
80105294:	68 2c a4 10 80       	push   $0x8010a42c
80105299:	e8 c8 b2 ff ff       	call   80100566 <panic>
        assertState(p, RUNNING);
8010529e:	83 ec 08             	sub    $0x8,%esp
801052a1:	6a 04                	push   $0x4
801052a3:	ff 75 f4             	pushl  -0xc(%ebp)
801052a6:	e8 51 11 00 00       	call   801063fc <assertState>
801052ab:	83 c4 10             	add    $0x10,%esp

        proc->cpu_ticks_in = ticks;
801052ae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052b4:	8b 15 20 79 11 80    	mov    0x80117920,%edx
801052ba:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)

        swtch(&cpu->scheduler, proc->context);
801052c0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052c6:	8b 40 1c             	mov    0x1c(%eax),%eax
801052c9:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801052d0:	83 c2 04             	add    $0x4,%edx
801052d3:	83 ec 08             	sub    $0x8,%esp
801052d6:	50                   	push   %eax
801052d7:	52                   	push   %edx
801052d8:	e8 5f 1a 00 00       	call   80106d3c <swtch>
801052dd:	83 c4 10             	add    $0x10,%esp

        proc->cpu_ticks_total = proc->cpu_ticks_total + (ticks - proc->cpu_ticks_in);
801052e0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052e6:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801052ed:	8b 8a 88 00 00 00    	mov    0x88(%edx),%ecx
801052f3:	8b 1d 20 79 11 80    	mov    0x80117920,%ebx
801052f9:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105300:	8b 92 8c 00 00 00    	mov    0x8c(%edx),%edx
80105306:	29 d3                	sub    %edx,%ebx
80105308:	89 da                	mov    %ebx,%edx
8010530a:	01 ca                	add    %ecx,%edx
8010530c:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
        switchkvm();
80105312:	e8 bf 44 00 00       	call   801097d6 <switchkvm>

        // Process is done running for now.
        // It should have changed its p->state before coming back.
        proc = 0;
80105317:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010531e:	00 00 00 00 
      promoteAll();
      ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
    }
    for(int i = 0; i < MAXPRIO; ++i)
    {
      for(p = ptable.pLists.ready[i]; p; p = p->next){
80105322:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105325:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010532b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010532e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105332:	0f 85 ce fe ff ff    	jne    80105206 <scheduler+0x69>
    if(ticks >= ptable.PromoteAtTime)
    {
      promoteAll();
      ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
    }
    for(int i = 0; i < MAXPRIO; ++i)
80105338:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010533c:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
80105340:	0f 8e a9 fe ff ff    	jle    801051ef <scheduler+0x52>
        // Process is done running for now.
        // It should have changed its p->state before coming back.
        proc = 0;
      }
    }
      release(&ptable.lock);
80105346:	83 ec 0c             	sub    $0xc,%esp
80105349:	68 80 49 11 80       	push   $0x80114980
8010534e:	e8 79 15 00 00       	call   801068cc <release>
80105353:	83 c4 10             	add    $0x10,%esp
      // if idle, wait for next interrupt
      if (idle) {
80105356:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010535a:	0f 84 44 fe ff ff    	je     801051a4 <scheduler+0x7>
        sti();
80105360:	e8 8e f1 ff ff       	call   801044f3 <sti>
        hlt();
80105365:	e8 72 f1 ff ff       	call   801044dc <hlt>
      }
  }
8010536a:	e9 35 fe ff ff       	jmp    801051a4 <scheduler+0x7>

8010536f <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
8010536f:	55                   	push   %ebp
80105370:	89 e5                	mov    %esp,%ebp
80105372:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80105375:	83 ec 0c             	sub    $0xc,%esp
80105378:	68 80 49 11 80       	push   $0x80114980
8010537d:	e8 16 16 00 00       	call   80106998 <holding>
80105382:	83 c4 10             	add    $0x10,%esp
80105385:	85 c0                	test   %eax,%eax
80105387:	75 0d                	jne    80105396 <sched+0x27>
    panic("sched ptable.lock");
80105389:	83 ec 0c             	sub    $0xc,%esp
8010538c:	68 51 a4 10 80       	push   $0x8010a451
80105391:	e8 d0 b1 ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
80105396:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010539c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801053a2:	83 f8 01             	cmp    $0x1,%eax
801053a5:	74 0d                	je     801053b4 <sched+0x45>
    panic("sched locks");
801053a7:	83 ec 0c             	sub    $0xc,%esp
801053aa:	68 63 a4 10 80       	push   $0x8010a463
801053af:	e8 b2 b1 ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
801053b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053ba:	8b 40 0c             	mov    0xc(%eax),%eax
801053bd:	83 f8 04             	cmp    $0x4,%eax
801053c0:	75 0d                	jne    801053cf <sched+0x60>
    panic("sched running");
801053c2:	83 ec 0c             	sub    $0xc,%esp
801053c5:	68 6f a4 10 80       	push   $0x8010a46f
801053ca:	e8 97 b1 ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
801053cf:	e8 0f f1 ff ff       	call   801044e3 <readeflags>
801053d4:	25 00 02 00 00       	and    $0x200,%eax
801053d9:	85 c0                	test   %eax,%eax
801053db:	74 0d                	je     801053ea <sched+0x7b>
    panic("sched interruptible");
801053dd:	83 ec 0c             	sub    $0xc,%esp
801053e0:	68 7d a4 10 80       	push   $0x8010a47d
801053e5:	e8 7c b1 ff ff       	call   80100566 <panic>
  intena = cpu->intena;
801053ea:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801053f0:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801053f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
801053f9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801053ff:	8b 40 04             	mov    0x4(%eax),%eax
80105402:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105409:	83 c2 1c             	add    $0x1c,%edx
8010540c:	83 ec 08             	sub    $0x8,%esp
8010540f:	50                   	push   %eax
80105410:	52                   	push   %edx
80105411:	e8 26 19 00 00       	call   80106d3c <swtch>
80105416:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80105419:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010541f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105422:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105428:	90                   	nop
80105429:	c9                   	leave  
8010542a:	c3                   	ret    

8010542b <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010542b:	55                   	push   %ebp
8010542c:	89 e5                	mov    %esp,%ebp
8010542e:	53                   	push   %ebx
8010542f:	83 ec 04             	sub    $0x4,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80105432:	83 ec 0c             	sub    $0xc,%esp
80105435:	68 80 49 11 80       	push   $0x80114980
8010543a:	e8 26 14 00 00       	call   80106865 <acquire>
8010543f:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80105442:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105448:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
#ifdef CS333_P3P4
  proc->budget = proc->budget - (ticks - proc->cpu_ticks_in);
8010544f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105455:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010545c:	8b 8a 94 00 00 00    	mov    0x94(%edx),%ecx
80105462:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105469:	8b 9a 8c 00 00 00    	mov    0x8c(%edx),%ebx
8010546f:	8b 15 20 79 11 80    	mov    0x80117920,%edx
80105475:	29 d3                	sub    %edx,%ebx
80105477:	89 da                	mov    %ebx,%edx
80105479:	01 ca                	add    %ecx,%edx
8010547b:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
  if(proc->budget <= 0)
80105481:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105487:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
8010548d:	85 c0                	test   %eax,%eax
8010548f:	75 4c                	jne    801054dd <yield+0xb2>
  {
    if(proc->priority < MAXPRIO)
80105491:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105497:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
8010549d:	83 f8 04             	cmp    $0x4,%eax
801054a0:	77 1c                	ja     801054be <yield+0x93>
      proc->priority += 1;
801054a2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054a8:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801054af:	8b 92 98 00 00 00    	mov    0x98(%edx),%edx
801054b5:	83 c2 01             	add    $0x1,%edx
801054b8:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
    proc->budget = BUDGET*(proc->priority+1);
801054be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054c4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801054cb:	8b 92 98 00 00 00    	mov    0x98(%edx),%edx
801054d1:	83 c2 01             	add    $0x1,%edx
801054d4:	6b d2 64             	imul   $0x64,%edx,%edx
801054d7:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
  }
  stateListRemove(&ptable.pLists.running, &ptable.pLists.runningTail, proc);
801054dd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054e3:	83 ec 04             	sub    $0x4,%esp
801054e6:	50                   	push   %eax
801054e7:	68 00 71 11 80       	push   $0x80117100
801054ec:	68 fc 70 11 80       	push   $0x801170fc
801054f1:	e8 86 08 00 00       	call   80105d7c <stateListRemove>
801054f6:	83 c4 10             	add    $0x10,%esp
  stateListAdd(&ptable.pLists.ready[proc->priority], &ptable.pLists.readyTail[proc->priority], proc);
801054f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054ff:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105506:	8b 92 98 00 00 00    	mov    0x98(%edx),%edx
8010550c:	81 c2 d0 09 00 00    	add    $0x9d0,%edx
80105512:	c1 e2 02             	shl    $0x2,%edx
80105515:	81 c2 80 49 11 80    	add    $0x80114980,%edx
8010551b:	8d 4a 0c             	lea    0xc(%edx),%ecx
8010551e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105525:	8b 92 98 00 00 00    	mov    0x98(%edx),%edx
8010552b:	81 c2 cc 09 00 00    	add    $0x9cc,%edx
80105531:	c1 e2 02             	shl    $0x2,%edx
80105534:	81 c2 80 49 11 80    	add    $0x80114980,%edx
8010553a:	83 c2 04             	add    $0x4,%edx
8010553d:	83 ec 04             	sub    $0x4,%esp
80105540:	50                   	push   %eax
80105541:	51                   	push   %ecx
80105542:	52                   	push   %edx
80105543:	e8 d5 07 00 00       	call   80105d1d <stateListAdd>
80105548:	83 c4 10             	add    $0x10,%esp
  assertState(proc, RUNNABLE);
8010554b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105551:	83 ec 08             	sub    $0x8,%esp
80105554:	6a 03                	push   $0x3
80105556:	50                   	push   %eax
80105557:	e8 a0 0e 00 00       	call   801063fc <assertState>
8010555c:	83 c4 10             	add    $0x10,%esp
#endif
  sched();
8010555f:	e8 0b fe ff ff       	call   8010536f <sched>
  release(&ptable.lock);
80105564:	83 ec 0c             	sub    $0xc,%esp
80105567:	68 80 49 11 80       	push   $0x80114980
8010556c:	e8 5b 13 00 00       	call   801068cc <release>
80105571:	83 c4 10             	add    $0x10,%esp
}
80105574:	90                   	nop
80105575:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105578:	c9                   	leave  
80105579:	c3                   	ret    

8010557a <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010557a:	55                   	push   %ebp
8010557b:	89 e5                	mov    %esp,%ebp
8010557d:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80105580:	83 ec 0c             	sub    $0xc,%esp
80105583:	68 80 49 11 80       	push   $0x80114980
80105588:	e8 3f 13 00 00       	call   801068cc <release>
8010558d:	83 c4 10             	add    $0x10,%esp

  if (first) {
80105590:	a1 20 d0 10 80       	mov    0x8010d020,%eax
80105595:	85 c0                	test   %eax,%eax
80105597:	74 24                	je     801055bd <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80105599:	c7 05 20 d0 10 80 00 	movl   $0x0,0x8010d020
801055a0:	00 00 00 
    iinit(ROOTDEV);
801055a3:	83 ec 0c             	sub    $0xc,%esp
801055a6:	6a 01                	push   $0x1
801055a8:	e8 2f c1 ff ff       	call   801016dc <iinit>
801055ad:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801055b0:	83 ec 0c             	sub    $0xc,%esp
801055b3:	6a 01                	push   $0x1
801055b5:	e8 13 de ff ff       	call   801033cd <initlog>
801055ba:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801055bd:	90                   	nop
801055be:	c9                   	leave  
801055bf:	c3                   	ret    

801055c0 <sleep>:
// Reacquires lock when awakened.
// 2016/12/28: ticklock removed from xv6. sleep() changed to
// accept a NULL lock to accommodate.
void
sleep(void *chan, struct spinlock *lk)
{
801055c0:	55                   	push   %ebp
801055c1:	89 e5                	mov    %esp,%ebp
801055c3:	53                   	push   %ebx
801055c4:	83 ec 04             	sub    $0x4,%esp
  if(proc == 0)
801055c7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055cd:	85 c0                	test   %eax,%eax
801055cf:	75 0d                	jne    801055de <sleep+0x1e>
    panic("sleep");
801055d1:	83 ec 0c             	sub    $0xc,%esp
801055d4:	68 91 a4 10 80       	push   $0x8010a491
801055d9:	e8 88 af ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){
801055de:	81 7d 0c 80 49 11 80 	cmpl   $0x80114980,0xc(%ebp)
801055e5:	74 24                	je     8010560b <sleep+0x4b>
    acquire(&ptable.lock);
801055e7:	83 ec 0c             	sub    $0xc,%esp
801055ea:	68 80 49 11 80       	push   $0x80114980
801055ef:	e8 71 12 00 00       	call   80106865 <acquire>
801055f4:	83 c4 10             	add    $0x10,%esp
    if (lk) release(lk);
801055f7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801055fb:	74 0e                	je     8010560b <sleep+0x4b>
801055fd:	83 ec 0c             	sub    $0xc,%esp
80105600:	ff 75 0c             	pushl  0xc(%ebp)
80105603:	e8 c4 12 00 00       	call   801068cc <release>
80105608:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
8010560b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105611:	8b 55 08             	mov    0x8(%ebp),%edx
80105614:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80105617:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010561d:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
#ifdef CS333_P3P4
  proc->budget = proc->budget - (ticks - proc->cpu_ticks_in);
80105624:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010562a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105631:	8b 8a 94 00 00 00    	mov    0x94(%edx),%ecx
80105637:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010563e:	8b 9a 8c 00 00 00    	mov    0x8c(%edx),%ebx
80105644:	8b 15 20 79 11 80    	mov    0x80117920,%edx
8010564a:	29 d3                	sub    %edx,%ebx
8010564c:	89 da                	mov    %ebx,%edx
8010564e:	01 ca                	add    %ecx,%edx
80105650:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
  if(proc->budget <= 0)
80105656:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010565c:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80105662:	85 c0                	test   %eax,%eax
80105664:	75 4c                	jne    801056b2 <sleep+0xf2>
  {
    if(proc->priority < MAXPRIO)
80105666:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010566c:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80105672:	83 f8 04             	cmp    $0x4,%eax
80105675:	77 1c                	ja     80105693 <sleep+0xd3>
      proc->priority += 1;
80105677:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010567d:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105684:	8b 92 98 00 00 00    	mov    0x98(%edx),%edx
8010568a:	83 c2 01             	add    $0x1,%edx
8010568d:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)

    proc->budget = BUDGET*(proc->priority+1);
80105693:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105699:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801056a0:	8b 92 98 00 00 00    	mov    0x98(%edx),%edx
801056a6:	83 c2 01             	add    $0x1,%edx
801056a9:	6b d2 64             	imul   $0x64,%edx,%edx
801056ac:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
  }
  if(stateListRemove(&ptable.pLists.running, &ptable.pLists.runningTail, proc))
801056b2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056b8:	83 ec 04             	sub    $0x4,%esp
801056bb:	50                   	push   %eax
801056bc:	68 00 71 11 80       	push   $0x80117100
801056c1:	68 fc 70 11 80       	push   $0x801170fc
801056c6:	e8 b1 06 00 00       	call   80105d7c <stateListRemove>
801056cb:	83 c4 10             	add    $0x10,%esp
801056ce:	85 c0                	test   %eax,%eax
801056d0:	74 0d                	je     801056df <sleep+0x11f>
    panic("error removing from running list.");
801056d2:	83 ec 0c             	sub    $0xc,%esp
801056d5:	68 98 a4 10 80       	push   $0x8010a498
801056da:	e8 87 ae ff ff       	call   80100566 <panic>
  if(stateListAdd(&ptable.pLists.sleep, &ptable.pLists.sleepTail, proc))
801056df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056e5:	83 ec 04             	sub    $0x4,%esp
801056e8:	50                   	push   %eax
801056e9:	68 f0 70 11 80       	push   $0x801170f0
801056ee:	68 ec 70 11 80       	push   $0x801170ec
801056f3:	e8 25 06 00 00       	call   80105d1d <stateListAdd>
801056f8:	83 c4 10             	add    $0x10,%esp
801056fb:	85 c0                	test   %eax,%eax
801056fd:	74 0d                	je     8010570c <sleep+0x14c>
    panic("error adding to sleep list.");
801056ff:	83 ec 0c             	sub    $0xc,%esp
80105702:	68 ba a4 10 80       	push   $0x8010a4ba
80105707:	e8 5a ae ff ff       	call   80100566 <panic>
  assertState(proc, SLEEPING);
8010570c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105712:	83 ec 08             	sub    $0x8,%esp
80105715:	6a 02                	push   $0x2
80105717:	50                   	push   %eax
80105718:	e8 df 0c 00 00       	call   801063fc <assertState>
8010571d:	83 c4 10             	add    $0x10,%esp
#endif
  sched();
80105720:	e8 4a fc ff ff       	call   8010536f <sched>

  // Tidy up.
  proc->chan = 0;
80105725:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010572b:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){
80105732:	81 7d 0c 80 49 11 80 	cmpl   $0x80114980,0xc(%ebp)
80105739:	74 24                	je     8010575f <sleep+0x19f>
    release(&ptable.lock);
8010573b:	83 ec 0c             	sub    $0xc,%esp
8010573e:	68 80 49 11 80       	push   $0x80114980
80105743:	e8 84 11 00 00       	call   801068cc <release>
80105748:	83 c4 10             	add    $0x10,%esp
    if (lk) acquire(lk);
8010574b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010574f:	74 0e                	je     8010575f <sleep+0x19f>
80105751:	83 ec 0c             	sub    $0xc,%esp
80105754:	ff 75 0c             	pushl  0xc(%ebp)
80105757:	e8 09 11 00 00       	call   80106865 <acquire>
8010575c:	83 c4 10             	add    $0x10,%esp
  }
}
8010575f:	90                   	nop
80105760:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105763:	c9                   	leave  
80105764:	c3                   	ret    

80105765 <wakeup1>:
      p->state = RUNNABLE;
}
#else
static void
wakeup1(void *chan)
{
80105765:	55                   	push   %ebp
80105766:	89 e5                	mov    %esp,%ebp
80105768:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  p = ptable.pLists.sleep;
8010576b:	a1 ec 70 11 80       	mov    0x801170ec,%eax
80105770:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(p)
80105773:	e9 b1 00 00 00       	jmp    80105829 <wakeup1+0xc4>
  {
    if(p->chan == chan)
80105778:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010577b:	8b 40 20             	mov    0x20(%eax),%eax
8010577e:	3b 45 08             	cmp    0x8(%ebp),%eax
80105781:	0f 85 96 00 00 00    	jne    8010581d <wakeup1+0xb8>
    {
      p->state = RUNNABLE;
80105787:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010578a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      if(stateListRemove(&ptable.pLists.sleep, &ptable.pLists.sleepTail, p))
80105791:	83 ec 04             	sub    $0x4,%esp
80105794:	ff 75 f4             	pushl  -0xc(%ebp)
80105797:	68 f0 70 11 80       	push   $0x801170f0
8010579c:	68 ec 70 11 80       	push   $0x801170ec
801057a1:	e8 d6 05 00 00       	call   80105d7c <stateListRemove>
801057a6:	83 c4 10             	add    $0x10,%esp
801057a9:	85 c0                	test   %eax,%eax
801057ab:	74 0d                	je     801057ba <wakeup1+0x55>
        panic("error removing from sleep list.");
801057ad:	83 ec 0c             	sub    $0xc,%esp
801057b0:	68 d8 a4 10 80       	push   $0x8010a4d8
801057b5:	e8 ac ad ff ff       	call   80100566 <panic>
      if(stateListAdd(&ptable.pLists.ready[p->priority], &ptable.pLists.readyTail[p->priority], p))
801057ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057bd:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801057c3:	05 d0 09 00 00       	add    $0x9d0,%eax
801057c8:	c1 e0 02             	shl    $0x2,%eax
801057cb:	05 80 49 11 80       	add    $0x80114980,%eax
801057d0:	8d 50 0c             	lea    0xc(%eax),%edx
801057d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057d6:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801057dc:	05 cc 09 00 00       	add    $0x9cc,%eax
801057e1:	c1 e0 02             	shl    $0x2,%eax
801057e4:	05 80 49 11 80       	add    $0x80114980,%eax
801057e9:	83 c0 04             	add    $0x4,%eax
801057ec:	83 ec 04             	sub    $0x4,%esp
801057ef:	ff 75 f4             	pushl  -0xc(%ebp)
801057f2:	52                   	push   %edx
801057f3:	50                   	push   %eax
801057f4:	e8 24 05 00 00       	call   80105d1d <stateListAdd>
801057f9:	83 c4 10             	add    $0x10,%esp
801057fc:	85 c0                	test   %eax,%eax
801057fe:	74 0d                	je     8010580d <wakeup1+0xa8>
        panic("error adding to ready list.");
80105800:	83 ec 0c             	sub    $0xc,%esp
80105803:	68 20 a3 10 80       	push   $0x8010a320
80105808:	e8 59 ad ff ff       	call   80100566 <panic>
      assertState(p, RUNNABLE);
8010580d:	83 ec 08             	sub    $0x8,%esp
80105810:	6a 03                	push   $0x3
80105812:	ff 75 f4             	pushl  -0xc(%ebp)
80105815:	e8 e2 0b 00 00       	call   801063fc <assertState>
8010581a:	83 c4 10             	add    $0x10,%esp
    }
    p = p->next;
8010581d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105820:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105826:	89 45 f4             	mov    %eax,-0xc(%ebp)
wakeup1(void *chan)
{
  struct proc *p;

  p = ptable.pLists.sleep;
  while(p)
80105829:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010582d:	0f 85 45 ff ff ff    	jne    80105778 <wakeup1+0x13>
        panic("error adding to ready list.");
      assertState(p, RUNNABLE);
    }
    p = p->next;
  }
}
80105833:	90                   	nop
80105834:	c9                   	leave  
80105835:	c3                   	ret    

80105836 <wakeup>:
#endif

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80105836:	55                   	push   %ebp
80105837:	89 e5                	mov    %esp,%ebp
80105839:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
8010583c:	83 ec 0c             	sub    $0xc,%esp
8010583f:	68 80 49 11 80       	push   $0x80114980
80105844:	e8 1c 10 00 00       	call   80106865 <acquire>
80105849:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
8010584c:	83 ec 0c             	sub    $0xc,%esp
8010584f:	ff 75 08             	pushl  0x8(%ebp)
80105852:	e8 0e ff ff ff       	call   80105765 <wakeup1>
80105857:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
8010585a:	83 ec 0c             	sub    $0xc,%esp
8010585d:	68 80 49 11 80       	push   $0x80114980
80105862:	e8 65 10 00 00       	call   801068cc <release>
80105867:	83 c4 10             	add    $0x10,%esp
}
8010586a:	90                   	nop
8010586b:	c9                   	leave  
8010586c:	c3                   	ret    

8010586d <kill>:
  return -1;
}
#else
int
kill(int pid)
{
8010586d:	55                   	push   %ebp
8010586e:	89 e5                	mov    %esp,%ebp
80105870:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80105873:	83 ec 0c             	sub    $0xc,%esp
80105876:	68 80 49 11 80       	push   $0x80114980
8010587b:	e8 e5 0f 00 00       	call   80106865 <acquire>
80105880:	83 c4 10             	add    $0x10,%esp
  for(int i = 0; i < MAXPRIO; ++i)
80105883:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010588a:	eb 3b                	jmp    801058c7 <kill+0x5a>
  {
    for(p = ptable.pLists.ready[i]; p ; p = p->next)
8010588c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010588f:	05 cc 09 00 00       	add    $0x9cc,%eax
80105894:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
8010589b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010589e:	eb 1d                	jmp    801058bd <kill+0x50>
    {
      if(p->pid == pid)
801058a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058a3:	8b 50 10             	mov    0x10(%eax),%edx
801058a6:	8b 45 08             	mov    0x8(%ebp),%eax
801058a9:	39 c2                	cmp    %eax,%edx
801058ab:	0f 84 86 01 00 00    	je     80105a37 <kill+0x1ca>
  struct proc *p;

  acquire(&ptable.lock);
  for(int i = 0; i < MAXPRIO; ++i)
  {
    for(p = ptable.pLists.ready[i]; p ; p = p->next)
801058b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058b4:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801058ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058c1:	75 dd                	jne    801058a0 <kill+0x33>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(int i = 0; i < MAXPRIO; ++i)
801058c3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801058c7:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801058cb:	7e bf                	jle    8010588c <kill+0x1f>
    {
      if(p->pid == pid)
        goto found;
    }
  }
  for(p = ptable.pLists.running; p ; p = p->next)
801058cd:	a1 fc 70 11 80       	mov    0x801170fc,%eax
801058d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058d5:	eb 1d                	jmp    801058f4 <kill+0x87>
  {
    if(p->pid == pid)
801058d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058da:	8b 50 10             	mov    0x10(%eax),%edx
801058dd:	8b 45 08             	mov    0x8(%ebp),%eax
801058e0:	39 c2                	cmp    %eax,%edx
801058e2:	0f 84 52 01 00 00    	je     80105a3a <kill+0x1cd>
    {
      if(p->pid == pid)
        goto found;
    }
  }
  for(p = ptable.pLists.running; p ; p = p->next)
801058e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058eb:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801058f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058f8:	75 dd                	jne    801058d7 <kill+0x6a>
  {
    if(p->pid == pid)
      goto found;
  }
  for(p = ptable.pLists.embryo; p ; p = p->next)
801058fa:	a1 04 71 11 80       	mov    0x80117104,%eax
801058ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105902:	eb 1d                	jmp    80105921 <kill+0xb4>
  {
    if(p->pid == pid)
80105904:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105907:	8b 50 10             	mov    0x10(%eax),%edx
8010590a:	8b 45 08             	mov    0x8(%ebp),%eax
8010590d:	39 c2                	cmp    %eax,%edx
8010590f:	0f 84 28 01 00 00    	je     80105a3d <kill+0x1d0>
  for(p = ptable.pLists.running; p ; p = p->next)
  {
    if(p->pid == pid)
      goto found;
  }
  for(p = ptable.pLists.embryo; p ; p = p->next)
80105915:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105918:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010591e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105921:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105925:	75 dd                	jne    80105904 <kill+0x97>
  {
    if(p->pid == pid)
      goto found;
  }
  for(p = ptable.pLists.zombie; p ; p = p->next)
80105927:	a1 f4 70 11 80       	mov    0x801170f4,%eax
8010592c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010592f:	eb 1d                	jmp    8010594e <kill+0xe1>
  {
    if(p->pid == pid)
80105931:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105934:	8b 50 10             	mov    0x10(%eax),%edx
80105937:	8b 45 08             	mov    0x8(%ebp),%eax
8010593a:	39 c2                	cmp    %eax,%edx
8010593c:	0f 84 fe 00 00 00    	je     80105a40 <kill+0x1d3>
  for(p = ptable.pLists.embryo; p ; p = p->next)
  {
    if(p->pid == pid)
      goto found;
  }
  for(p = ptable.pLists.zombie; p ; p = p->next)
80105942:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105945:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010594b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010594e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105952:	75 dd                	jne    80105931 <kill+0xc4>
  {
    if(p->pid == pid)
      goto found;
  }
  for(p = ptable.pLists.sleep; p ; p = p->next)
80105954:	a1 ec 70 11 80       	mov    0x801170ec,%eax
80105959:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010595c:	e9 b5 00 00 00       	jmp    80105a16 <kill+0x1a9>
  {
    if(p->pid == pid)
80105961:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105964:	8b 50 10             	mov    0x10(%eax),%edx
80105967:	8b 45 08             	mov    0x8(%ebp),%eax
8010596a:	39 c2                	cmp    %eax,%edx
8010596c:	0f 85 98 00 00 00    	jne    80105a0a <kill+0x19d>
    {
      // Wake process from sleep if necessary.
      if(stateListRemove(&ptable.pLists.sleep, &ptable.pLists.sleepTail, p))
80105972:	83 ec 04             	sub    $0x4,%esp
80105975:	ff 75 f4             	pushl  -0xc(%ebp)
80105978:	68 f0 70 11 80       	push   $0x801170f0
8010597d:	68 ec 70 11 80       	push   $0x801170ec
80105982:	e8 f5 03 00 00       	call   80105d7c <stateListRemove>
80105987:	83 c4 10             	add    $0x10,%esp
8010598a:	85 c0                	test   %eax,%eax
8010598c:	74 0d                	je     8010599b <kill+0x12e>
        panic("error removing from sleep list.");
8010598e:	83 ec 0c             	sub    $0xc,%esp
80105991:	68 d8 a4 10 80       	push   $0x8010a4d8
80105996:	e8 cb ab ff ff       	call   80100566 <panic>
      if(stateListAdd(&ptable.pLists.ready[p->priority], &ptable.pLists.readyTail[p->priority], p))
8010599b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010599e:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801059a4:	05 d0 09 00 00       	add    $0x9d0,%eax
801059a9:	c1 e0 02             	shl    $0x2,%eax
801059ac:	05 80 49 11 80       	add    $0x80114980,%eax
801059b1:	8d 50 0c             	lea    0xc(%eax),%edx
801059b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059b7:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801059bd:	05 cc 09 00 00       	add    $0x9cc,%eax
801059c2:	c1 e0 02             	shl    $0x2,%eax
801059c5:	05 80 49 11 80       	add    $0x80114980,%eax
801059ca:	83 c0 04             	add    $0x4,%eax
801059cd:	83 ec 04             	sub    $0x4,%esp
801059d0:	ff 75 f4             	pushl  -0xc(%ebp)
801059d3:	52                   	push   %edx
801059d4:	50                   	push   %eax
801059d5:	e8 43 03 00 00       	call   80105d1d <stateListAdd>
801059da:	83 c4 10             	add    $0x10,%esp
801059dd:	85 c0                	test   %eax,%eax
801059df:	74 0d                	je     801059ee <kill+0x181>
        panic("error adding to ready list.");
801059e1:	83 ec 0c             	sub    $0xc,%esp
801059e4:	68 20 a3 10 80       	push   $0x8010a320
801059e9:	e8 78 ab ff ff       	call   80100566 <panic>
      p->state = RUNNABLE;
801059ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      assertState(p, RUNNABLE);
801059f8:	83 ec 08             	sub    $0x8,%esp
801059fb:	6a 03                	push   $0x3
801059fd:	ff 75 f4             	pushl  -0xc(%ebp)
80105a00:	e8 f7 09 00 00       	call   801063fc <assertState>
80105a05:	83 c4 10             	add    $0x10,%esp
      goto found;
80105a08:	eb 37                	jmp    80105a41 <kill+0x1d4>
  for(p = ptable.pLists.zombie; p ; p = p->next)
  {
    if(p->pid == pid)
      goto found;
  }
  for(p = ptable.pLists.sleep; p ; p = p->next)
80105a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a0d:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105a13:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a16:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a1a:	0f 85 41 ff ff ff    	jne    80105961 <kill+0xf4>
      p->state = RUNNABLE;
      assertState(p, RUNNABLE);
      goto found;
    }
  }
  release(&ptable.lock);
80105a20:	83 ec 0c             	sub    $0xc,%esp
80105a23:	68 80 49 11 80       	push   $0x80114980
80105a28:	e8 9f 0e 00 00       	call   801068cc <release>
80105a2d:	83 c4 10             	add    $0x10,%esp
  return -1;
80105a30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a35:	eb 29                	jmp    80105a60 <kill+0x1f3>
  for(int i = 0; i < MAXPRIO; ++i)
  {
    for(p = ptable.pLists.ready[i]; p ; p = p->next)
    {
      if(p->pid == pid)
        goto found;
80105a37:	90                   	nop
80105a38:	eb 07                	jmp    80105a41 <kill+0x1d4>
    }
  }
  for(p = ptable.pLists.running; p ; p = p->next)
  {
    if(p->pid == pid)
      goto found;
80105a3a:	90                   	nop
80105a3b:	eb 04                	jmp    80105a41 <kill+0x1d4>
  }
  for(p = ptable.pLists.embryo; p ; p = p->next)
  {
    if(p->pid == pid)
      goto found;
80105a3d:	90                   	nop
80105a3e:	eb 01                	jmp    80105a41 <kill+0x1d4>
  }
  for(p = ptable.pLists.zombie; p ; p = p->next)
  {
    if(p->pid == pid)
      goto found;
80105a40:	90                   	nop
  }
  release(&ptable.lock);
  return -1;

  found:
  p->killed = 1;
80105a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a44:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
  release(&ptable.lock);
80105a4b:	83 ec 0c             	sub    $0xc,%esp
80105a4e:	68 80 49 11 80       	push   $0x80114980
80105a53:	e8 74 0e 00 00       	call   801068cc <release>
80105a58:	83 c4 10             	add    $0x10,%esp
  return 0;
80105a5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a60:	c9                   	leave  
80105a61:	c3                   	ret    

80105a62 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105a62:	55                   	push   %ebp
80105a63:	89 e5                	mov    %esp,%ebp
80105a65:	53                   	push   %ebx
80105a66:	83 ec 44             	sub    $0x44,%esp
  uint current_ticks;
  struct proc *p;
  char *state;
  uint pc[10];
#if defined CS333_P3P4
  cprintf("\nPID\tName\tUID\tGID\tPPID\tPrio\tElapsed\tCPU\tState\tSize\t PCs\n");
80105a69:	83 ec 0c             	sub    $0xc,%esp
80105a6c:	68 24 a5 10 80       	push   $0x8010a524
80105a71:	e8 50 a9 ff ff       	call   801003c6 <cprintf>
80105a76:	83 c4 10             	add    $0x10,%esp
#elif defined CS333_P1
  cprintf("\nPID\tState\tName\tElapsed\t PCs\n");
#else
  cprintf("\nPID\tState\tName\t PCs\n");
#endif
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a79:	c7 45 f0 b4 49 11 80 	movl   $0x801149b4,-0x10(%ebp)
80105a80:	e9 85 02 00 00       	jmp    80105d0a <procdump+0x2a8>
    if(p->state == UNUSED)
80105a85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a88:	8b 40 0c             	mov    0xc(%eax),%eax
80105a8b:	85 c0                	test   %eax,%eax
80105a8d:	0f 84 6f 02 00 00    	je     80105d02 <procdump+0x2a0>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105a93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a96:	8b 40 0c             	mov    0xc(%eax),%eax
80105a99:	83 f8 05             	cmp    $0x5,%eax
80105a9c:	77 23                	ja     80105ac1 <procdump+0x5f>
80105a9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aa1:	8b 40 0c             	mov    0xc(%eax),%eax
80105aa4:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
80105aab:	85 c0                	test   %eax,%eax
80105aad:	74 12                	je     80105ac1 <procdump+0x5f>
      state = states[p->state];
80105aaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ab2:	8b 40 0c             	mov    0xc(%eax),%eax
80105ab5:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
80105abc:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105abf:	eb 07                	jmp    80105ac8 <procdump+0x66>
    else
      state = "???";
80105ac1:	c7 45 ec 5d a5 10 80 	movl   $0x8010a55d,-0x14(%ebp)
    current_ticks = ticks;
80105ac8:	a1 20 79 11 80       	mov    0x80117920,%eax
80105acd:	89 45 e8             	mov    %eax,-0x18(%ebp)
    i = ((current_ticks-p->start_ticks)%1000);
80105ad0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ad3:	8b 40 7c             	mov    0x7c(%eax),%eax
80105ad6:	8b 55 e8             	mov    -0x18(%ebp),%edx
80105ad9:	89 d1                	mov    %edx,%ecx
80105adb:	29 c1                	sub    %eax,%ecx
80105add:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105ae2:	89 c8                	mov    %ecx,%eax
80105ae4:	f7 e2                	mul    %edx
80105ae6:	89 d0                	mov    %edx,%eax
80105ae8:	c1 e8 06             	shr    $0x6,%eax
80105aeb:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
80105af1:	29 c1                	sub    %eax,%ecx
80105af3:	89 c8                	mov    %ecx,%eax
80105af5:	89 45 f4             	mov    %eax,-0xc(%ebp)
#if defined CS333_P2
    cprintf("%d\t%s\t%d\t%d", p->pid, p->name, p->uid, p->gid);
80105af8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105afb:	8b 88 84 00 00 00    	mov    0x84(%eax),%ecx
80105b01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b04:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80105b0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b0d:	8d 58 6c             	lea    0x6c(%eax),%ebx
80105b10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b13:	8b 40 10             	mov    0x10(%eax),%eax
80105b16:	83 ec 0c             	sub    $0xc,%esp
80105b19:	51                   	push   %ecx
80105b1a:	52                   	push   %edx
80105b1b:	53                   	push   %ebx
80105b1c:	50                   	push   %eax
80105b1d:	68 61 a5 10 80       	push   $0x8010a561
80105b22:	e8 9f a8 ff ff       	call   801003c6 <cprintf>
80105b27:	83 c4 20             	add    $0x20,%esp
    if(p->pid == 1)
80105b2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b2d:	8b 40 10             	mov    0x10(%eax),%eax
80105b30:	83 f8 01             	cmp    $0x1,%eax
80105b33:	75 19                	jne    80105b4e <procdump+0xec>
      cprintf("\t%d",p->pid);
80105b35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b38:	8b 40 10             	mov    0x10(%eax),%eax
80105b3b:	83 ec 08             	sub    $0x8,%esp
80105b3e:	50                   	push   %eax
80105b3f:	68 6d a5 10 80       	push   $0x8010a56d
80105b44:	e8 7d a8 ff ff       	call   801003c6 <cprintf>
80105b49:	83 c4 10             	add    $0x10,%esp
80105b4c:	eb 1a                	jmp    80105b68 <procdump+0x106>
    else
      cprintf("\t%d",p->parent->pid);
80105b4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b51:	8b 40 14             	mov    0x14(%eax),%eax
80105b54:	8b 40 10             	mov    0x10(%eax),%eax
80105b57:	83 ec 08             	sub    $0x8,%esp
80105b5a:	50                   	push   %eax
80105b5b:	68 6d a5 10 80       	push   $0x8010a56d
80105b60:	e8 61 a8 ff ff       	call   801003c6 <cprintf>
80105b65:	83 c4 10             	add    $0x10,%esp
#if defined CS333_P3P4
      cprintf("\t%d",p->priority);
80105b68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b6b:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80105b71:	83 ec 08             	sub    $0x8,%esp
80105b74:	50                   	push   %eax
80105b75:	68 6d a5 10 80       	push   $0x8010a56d
80105b7a:	e8 47 a8 ff ff       	call   801003c6 <cprintf>
80105b7f:	83 c4 10             	add    $0x10,%esp
#endif
    cprintf("\t%d.", ((current_ticks-p->start_ticks)/1000));
80105b82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b85:	8b 40 7c             	mov    0x7c(%eax),%eax
80105b88:	8b 55 e8             	mov    -0x18(%ebp),%edx
80105b8b:	29 c2                	sub    %eax,%edx
80105b8d:	89 d0                	mov    %edx,%eax
80105b8f:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105b94:	f7 e2                	mul    %edx
80105b96:	89 d0                	mov    %edx,%eax
80105b98:	c1 e8 06             	shr    $0x6,%eax
80105b9b:	83 ec 08             	sub    $0x8,%esp
80105b9e:	50                   	push   %eax
80105b9f:	68 71 a5 10 80       	push   $0x8010a571
80105ba4:	e8 1d a8 ff ff       	call   801003c6 <cprintf>
80105ba9:	83 c4 10             	add    $0x10,%esp
    if (i<100)
80105bac:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
80105bb0:	7f 10                	jg     80105bc2 <procdump+0x160>
      cprintf("0");
80105bb2:	83 ec 0c             	sub    $0xc,%esp
80105bb5:	68 76 a5 10 80       	push   $0x8010a576
80105bba:	e8 07 a8 ff ff       	call   801003c6 <cprintf>
80105bbf:	83 c4 10             	add    $0x10,%esp
    if (i<10)
80105bc2:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105bc6:	7f 10                	jg     80105bd8 <procdump+0x176>
      cprintf("0");
80105bc8:	83 ec 0c             	sub    $0xc,%esp
80105bcb:	68 76 a5 10 80       	push   $0x8010a576
80105bd0:	e8 f1 a7 ff ff       	call   801003c6 <cprintf>
80105bd5:	83 c4 10             	add    $0x10,%esp
    cprintf("%d", i);
80105bd8:	83 ec 08             	sub    $0x8,%esp
80105bdb:	ff 75 f4             	pushl  -0xc(%ebp)
80105bde:	68 78 a5 10 80       	push   $0x8010a578
80105be3:	e8 de a7 ff ff       	call   801003c6 <cprintf>
80105be8:	83 c4 10             	add    $0x10,%esp
    i = p->cpu_ticks_total;
80105beb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bee:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80105bf4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("\t%d.", i/1000);
80105bf7:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80105bfa:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105bff:	89 c8                	mov    %ecx,%eax
80105c01:	f7 ea                	imul   %edx
80105c03:	c1 fa 06             	sar    $0x6,%edx
80105c06:	89 c8                	mov    %ecx,%eax
80105c08:	c1 f8 1f             	sar    $0x1f,%eax
80105c0b:	29 c2                	sub    %eax,%edx
80105c0d:	89 d0                	mov    %edx,%eax
80105c0f:	83 ec 08             	sub    $0x8,%esp
80105c12:	50                   	push   %eax
80105c13:	68 71 a5 10 80       	push   $0x8010a571
80105c18:	e8 a9 a7 ff ff       	call   801003c6 <cprintf>
80105c1d:	83 c4 10             	add    $0x10,%esp
    i = i%1000;
80105c20:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80105c23:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105c28:	89 c8                	mov    %ecx,%eax
80105c2a:	f7 ea                	imul   %edx
80105c2c:	c1 fa 06             	sar    $0x6,%edx
80105c2f:	89 c8                	mov    %ecx,%eax
80105c31:	c1 f8 1f             	sar    $0x1f,%eax
80105c34:	29 c2                	sub    %eax,%edx
80105c36:	89 d0                	mov    %edx,%eax
80105c38:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
80105c3e:	29 c1                	sub    %eax,%ecx
80105c40:	89 c8                	mov    %ecx,%eax
80105c42:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i<100)
80105c45:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
80105c49:	7f 10                	jg     80105c5b <procdump+0x1f9>
      cprintf("0");
80105c4b:	83 ec 0c             	sub    $0xc,%esp
80105c4e:	68 76 a5 10 80       	push   $0x8010a576
80105c53:	e8 6e a7 ff ff       	call   801003c6 <cprintf>
80105c58:	83 c4 10             	add    $0x10,%esp
    if (i<10)
80105c5b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105c5f:	7f 10                	jg     80105c71 <procdump+0x20f>
      cprintf("0");
80105c61:	83 ec 0c             	sub    $0xc,%esp
80105c64:	68 76 a5 10 80       	push   $0x8010a576
80105c69:	e8 58 a7 ff ff       	call   801003c6 <cprintf>
80105c6e:	83 c4 10             	add    $0x10,%esp
    cprintf("%d\t%s\t%d\t", i, state, p->sz);
80105c71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c74:	8b 00                	mov    (%eax),%eax
80105c76:	50                   	push   %eax
80105c77:	ff 75 ec             	pushl  -0x14(%ebp)
80105c7a:	ff 75 f4             	pushl  -0xc(%ebp)
80105c7d:	68 7b a5 10 80       	push   $0x8010a57b
80105c82:	e8 3f a7 ff ff       	call   801003c6 <cprintf>
80105c87:	83 c4 10             	add    $0x10,%esp
      cprintf("0");
    cprintf("%d\t",i);
#else
    cprintf("%d\t%s\t%s", p->pid, state, p->name);
#endif
    i = 0;
80105c8a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(p->state == SLEEPING){
80105c91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c94:	8b 40 0c             	mov    0xc(%eax),%eax
80105c97:	83 f8 02             	cmp    $0x2,%eax
80105c9a:	75 54                	jne    80105cf0 <procdump+0x28e>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105c9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c9f:	8b 40 1c             	mov    0x1c(%eax),%eax
80105ca2:	8b 40 0c             	mov    0xc(%eax),%eax
80105ca5:	83 c0 08             	add    $0x8,%eax
80105ca8:	89 c2                	mov    %eax,%edx
80105caa:	83 ec 08             	sub    $0x8,%esp
80105cad:	8d 45 c0             	lea    -0x40(%ebp),%eax
80105cb0:	50                   	push   %eax
80105cb1:	52                   	push   %edx
80105cb2:	e8 67 0c 00 00       	call   8010691e <getcallerpcs>
80105cb7:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105cba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105cc1:	eb 1c                	jmp    80105cdf <procdump+0x27d>
        cprintf(" %p", pc[i]);
80105cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cc6:	8b 44 85 c0          	mov    -0x40(%ebp,%eax,4),%eax
80105cca:	83 ec 08             	sub    $0x8,%esp
80105ccd:	50                   	push   %eax
80105cce:	68 85 a5 10 80       	push   $0x8010a585
80105cd3:	e8 ee a6 ff ff       	call   801003c6 <cprintf>
80105cd8:	83 c4 10             	add    $0x10,%esp
    cprintf("%d\t%s\t%s", p->pid, state, p->name);
#endif
    i = 0;
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105cdb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105cdf:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105ce3:	7f 0b                	jg     80105cf0 <procdump+0x28e>
80105ce5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ce8:	8b 44 85 c0          	mov    -0x40(%ebp,%eax,4),%eax
80105cec:	85 c0                	test   %eax,%eax
80105cee:	75 d3                	jne    80105cc3 <procdump+0x261>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105cf0:	83 ec 0c             	sub    $0xc,%esp
80105cf3:	68 89 a5 10 80       	push   $0x8010a589
80105cf8:	e8 c9 a6 ff ff       	call   801003c6 <cprintf>
80105cfd:	83 c4 10             	add    $0x10,%esp
80105d00:	eb 01                	jmp    80105d03 <procdump+0x2a1>
#else
  cprintf("\nPID\tState\tName\t PCs\n");
#endif
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105d02:	90                   	nop
#elif defined CS333_P1
  cprintf("\nPID\tState\tName\tElapsed\t PCs\n");
#else
  cprintf("\nPID\tState\tName\t PCs\n");
#endif
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105d03:	81 45 f0 9c 00 00 00 	addl   $0x9c,-0x10(%ebp)
80105d0a:	81 7d f0 b4 70 11 80 	cmpl   $0x801170b4,-0x10(%ebp)
80105d11:	0f 82 6e fd ff ff    	jb     80105a85 <procdump+0x23>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105d17:	90                   	nop
80105d18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105d1b:	c9                   	leave  
80105d1c:	c3                   	ret    

80105d1d <stateListAdd>:


#ifdef CS333_P3P4
static int
stateListAdd(struct proc** head, struct proc** tail, struct proc* p)
{
80105d1d:	55                   	push   %ebp
80105d1e:	89 e5                	mov    %esp,%ebp
  if (*head == 0) {
80105d20:	8b 45 08             	mov    0x8(%ebp),%eax
80105d23:	8b 00                	mov    (%eax),%eax
80105d25:	85 c0                	test   %eax,%eax
80105d27:	75 1f                	jne    80105d48 <stateListAdd+0x2b>
    *head = p;
80105d29:	8b 45 08             	mov    0x8(%ebp),%eax
80105d2c:	8b 55 10             	mov    0x10(%ebp),%edx
80105d2f:	89 10                	mov    %edx,(%eax)
    *tail = p;
80105d31:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d34:	8b 55 10             	mov    0x10(%ebp),%edx
80105d37:	89 10                	mov    %edx,(%eax)
    p->next = 0;
80105d39:	8b 45 10             	mov    0x10(%ebp),%eax
80105d3c:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80105d43:	00 00 00 
80105d46:	eb 2d                	jmp    80105d75 <stateListAdd+0x58>
  } else {
    (*tail)->next = p;
80105d48:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d4b:	8b 00                	mov    (%eax),%eax
80105d4d:	8b 55 10             	mov    0x10(%ebp),%edx
80105d50:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
    *tail = (*tail)->next;
80105d56:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d59:	8b 00                	mov    (%eax),%eax
80105d5b:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
80105d61:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d64:	89 10                	mov    %edx,(%eax)
    (*tail)->next = 0;
80105d66:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d69:	8b 00                	mov    (%eax),%eax
80105d6b:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80105d72:	00 00 00 
  }

  return 0;
80105d75:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d7a:	5d                   	pop    %ebp
80105d7b:	c3                   	ret    

80105d7c <stateListRemove>:

static int
stateListRemove(struct proc** head, struct proc** tail, struct proc* p)
{
80105d7c:	55                   	push   %ebp
80105d7d:	89 e5                	mov    %esp,%ebp
80105d7f:	83 ec 10             	sub    $0x10,%esp
  if(*head == 0 || *tail == 0 || p == 0)
80105d82:	8b 45 08             	mov    0x8(%ebp),%eax
80105d85:	8b 00                	mov    (%eax),%eax
80105d87:	85 c0                	test   %eax,%eax
80105d89:	74 0f                	je     80105d9a <stateListRemove+0x1e>
80105d8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d8e:	8b 00                	mov    (%eax),%eax
80105d90:	85 c0                	test   %eax,%eax
80105d92:	74 06                	je     80105d9a <stateListRemove+0x1e>
80105d94:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105d98:	75 0a                	jne    80105da4 <stateListRemove+0x28>
  {
    return -1;
80105d9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d9f:	e9 b8 00 00 00       	jmp    80105e5c <stateListRemove+0xe0>
  }

  struct proc* current = *head;
80105da4:	8b 45 08             	mov    0x8(%ebp),%eax
80105da7:	8b 00                	mov    (%eax),%eax
80105da9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct proc* previous = 0;
80105dac:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

  if(current == p){
80105db3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105db6:	3b 45 10             	cmp    0x10(%ebp),%eax
80105db9:	75 44                	jne    80105dff <stateListRemove+0x83>
    *head = (*head)->next;
80105dbb:	8b 45 08             	mov    0x8(%ebp),%eax
80105dbe:	8b 00                	mov    (%eax),%eax
80105dc0:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
80105dc6:	8b 45 08             	mov    0x8(%ebp),%eax
80105dc9:	89 10                	mov    %edx,(%eax)
    // prevent tail remaining assigned when we've removed the only item
    // on the list
    if(*tail == p){
80105dcb:	8b 45 0c             	mov    0xc(%ebp),%eax
80105dce:	8b 00                	mov    (%eax),%eax
80105dd0:	3b 45 10             	cmp    0x10(%ebp),%eax
80105dd3:	75 09                	jne    80105dde <stateListRemove+0x62>
      *tail = 0;
80105dd5:	8b 45 0c             	mov    0xc(%ebp),%eax
80105dd8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    }
    return 0;
80105dde:	b8 00 00 00 00       	mov    $0x0,%eax
80105de3:	eb 77                	jmp    80105e5c <stateListRemove+0xe0>
  }

  while(current){
    if(current == p){
80105de5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105de8:	3b 45 10             	cmp    0x10(%ebp),%eax
80105deb:	74 1a                	je     80105e07 <stateListRemove+0x8b>
      break;
    }

    previous = current;
80105ded:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105df0:	89 45 f8             	mov    %eax,-0x8(%ebp)
    current = current->next;
80105df3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105df6:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105dfc:	89 45 fc             	mov    %eax,-0x4(%ebp)
      *tail = 0;
    }
    return 0;
  }

  while(current){
80105dff:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105e03:	75 e0                	jne    80105de5 <stateListRemove+0x69>
80105e05:	eb 01                	jmp    80105e08 <stateListRemove+0x8c>
    if(current == p){
      break;
80105e07:	90                   	nop
    previous = current;
    current = current->next;
  }

  // Process not found, hit eject.
  if(current == 0){
80105e08:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105e0c:	75 07                	jne    80105e15 <stateListRemove+0x99>
    return -1;
80105e0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e13:	eb 47                	jmp    80105e5c <stateListRemove+0xe0>
  }
  // Process found. Set the appropriate next pointer.
  if(current == *tail){
80105e15:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e18:	8b 00                	mov    (%eax),%eax
80105e1a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
80105e1d:	75 19                	jne    80105e38 <stateListRemove+0xbc>
    *tail = previous;
80105e1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e22:	8b 55 f8             	mov    -0x8(%ebp),%edx
80105e25:	89 10                	mov    %edx,(%eax)
    (*tail)->next = 0;
80105e27:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e2a:	8b 00                	mov    (%eax),%eax
80105e2c:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80105e33:	00 00 00 
80105e36:	eb 12                	jmp    80105e4a <stateListRemove+0xce>
  } else{
    previous->next = current->next;
80105e38:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e3b:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
80105e41:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e44:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
  }
  // Make sure p->next doesn't point into the list.
  p->next = 0;
80105e4a:	8b 45 10             	mov    0x10(%ebp),%eax
80105e4d:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80105e54:	00 00 00 
  return 0;
80105e57:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e5c:	c9                   	leave  
80105e5d:	c3                   	ret    

80105e5e <initProcessLists>:

static void
initProcessLists(void) {
80105e5e:	55                   	push   %ebp
80105e5f:	89 e5                	mov    %esp,%ebp
80105e61:	83 ec 10             	sub    $0x10,%esp
  for(int i = 0; i < MAXPRIO; ++i)
80105e64:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105e6b:	eb 2a                	jmp    80105e97 <initProcessLists+0x39>
  {
    ptable.pLists.ready[i] = 0;
80105e6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e70:	05 cc 09 00 00       	add    $0x9cc,%eax
80105e75:	c7 04 85 84 49 11 80 	movl   $0x0,-0x7feeb67c(,%eax,4)
80105e7c:	00 00 00 00 
    ptable.pLists.readyTail[i] = 0;
80105e80:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e83:	05 d0 09 00 00       	add    $0x9d0,%eax
80105e88:	c7 04 85 8c 49 11 80 	movl   $0x0,-0x7feeb674(,%eax,4)
80105e8f:	00 00 00 00 
  return 0;
}

static void
initProcessLists(void) {
  for(int i = 0; i < MAXPRIO; ++i)
80105e93:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105e97:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
80105e9b:	7e d0                	jle    80105e6d <initProcessLists+0xf>
  {
    ptable.pLists.ready[i] = 0;
    ptable.pLists.readyTail[i] = 0;
  }
  ptable.pLists.free = 0;
80105e9d:	c7 05 e4 70 11 80 00 	movl   $0x0,0x801170e4
80105ea4:	00 00 00 
  ptable.pLists.freeTail = 0;
80105ea7:	c7 05 e8 70 11 80 00 	movl   $0x0,0x801170e8
80105eae:	00 00 00 
  ptable.pLists.sleep = 0;
80105eb1:	c7 05 ec 70 11 80 00 	movl   $0x0,0x801170ec
80105eb8:	00 00 00 
  ptable.pLists.sleepTail = 0;
80105ebb:	c7 05 f0 70 11 80 00 	movl   $0x0,0x801170f0
80105ec2:	00 00 00 
  ptable.pLists.zombie = 0;
80105ec5:	c7 05 f4 70 11 80 00 	movl   $0x0,0x801170f4
80105ecc:	00 00 00 
  ptable.pLists.zombieTail = 0;
80105ecf:	c7 05 f8 70 11 80 00 	movl   $0x0,0x801170f8
80105ed6:	00 00 00 
  ptable.pLists.running = 0;
80105ed9:	c7 05 fc 70 11 80 00 	movl   $0x0,0x801170fc
80105ee0:	00 00 00 
  ptable.pLists.runningTail = 0;
80105ee3:	c7 05 00 71 11 80 00 	movl   $0x0,0x80117100
80105eea:	00 00 00 
  ptable.pLists.embryo = 0;
80105eed:	c7 05 04 71 11 80 00 	movl   $0x0,0x80117104
80105ef4:	00 00 00 
  ptable.pLists.embryoTail = 0;
80105ef7:	c7 05 08 71 11 80 00 	movl   $0x0,0x80117108
80105efe:	00 00 00 
}
80105f01:	90                   	nop
80105f02:	c9                   	leave  
80105f03:	c3                   	ret    

80105f04 <initFreeList>:

static void
initFreeList(void) {
80105f04:	55                   	push   %ebp
80105f05:	89 e5                	mov    %esp,%ebp
80105f07:	83 ec 18             	sub    $0x18,%esp
  if (!holding(&ptable.lock)) {
80105f0a:	83 ec 0c             	sub    $0xc,%esp
80105f0d:	68 80 49 11 80       	push   $0x80114980
80105f12:	e8 81 0a 00 00       	call   80106998 <holding>
80105f17:	83 c4 10             	add    $0x10,%esp
80105f1a:	85 c0                	test   %eax,%eax
80105f1c:	75 0d                	jne    80105f2b <initFreeList+0x27>
    panic("acquire the ptable lock before calling initFreeList\n");
80105f1e:	83 ec 0c             	sub    $0xc,%esp
80105f21:	68 8c a5 10 80       	push   $0x8010a58c
80105f26:	e8 3b a6 ff ff       	call   80100566 <panic>
  }

  struct proc* p;

  for (p = ptable.proc; p < ptable.proc + NPROC; ++p) {
80105f2b:	c7 45 f4 b4 49 11 80 	movl   $0x801149b4,-0xc(%ebp)
80105f32:	eb 29                	jmp    80105f5d <initFreeList+0x59>
    p->state = UNUSED;
80105f34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f37:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail, p);
80105f3e:	83 ec 04             	sub    $0x4,%esp
80105f41:	ff 75 f4             	pushl  -0xc(%ebp)
80105f44:	68 e8 70 11 80       	push   $0x801170e8
80105f49:	68 e4 70 11 80       	push   $0x801170e4
80105f4e:	e8 ca fd ff ff       	call   80105d1d <stateListAdd>
80105f53:	83 c4 10             	add    $0x10,%esp
    panic("acquire the ptable lock before calling initFreeList\n");
  }

  struct proc* p;

  for (p = ptable.proc; p < ptable.proc + NPROC; ++p) {
80105f56:	81 45 f4 9c 00 00 00 	addl   $0x9c,-0xc(%ebp)
80105f5d:	b8 b4 70 11 80       	mov    $0x801170b4,%eax
80105f62:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80105f65:	72 cd                	jb     80105f34 <initFreeList+0x30>
    p->state = UNUSED;
    stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail, p);
  }
}
80105f67:	90                   	nop
80105f68:	c9                   	leave  
80105f69:	c3                   	ret    

80105f6a <getprocs>:
#endif

//Get all current processes within the system.
int
getprocs(int max, struct uproc* proctable)
{
80105f6a:	55                   	push   %ebp
80105f6b:	89 e5                	mov    %esp,%ebp
80105f6d:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int i;

  //LOCK PTABLE
  acquire(&ptable.lock);
80105f70:	83 ec 0c             	sub    $0xc,%esp
80105f73:	68 80 49 11 80       	push   $0x80114980
80105f78:	e8 e8 08 00 00       	call   80106865 <acquire>
80105f7d:	83 c4 10             	add    $0x10,%esp

  //ptable gets incremented within forloop, i get incremented at the end
  //of the forloop.
  for(i=0, p = ptable.proc; p < &ptable.proc[NPROC] && i<max; p++)
80105f80:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80105f87:	c7 45 f4 b4 49 11 80 	movl   $0x801149b4,-0xc(%ebp)
80105f8e:	e9 a4 01 00 00       	jmp    80106137 <getprocs+0x1cd>
  {
    //copy all the info into one element of the array
    //skip if the process is in the unused state
    if(p->state != UNUSED && p->state != EMBRYO)
80105f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f96:	8b 40 0c             	mov    0xc(%eax),%eax
80105f99:	85 c0                	test   %eax,%eax
80105f9b:	0f 84 8f 01 00 00    	je     80106130 <getprocs+0x1c6>
80105fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fa4:	8b 40 0c             	mov    0xc(%eax),%eax
80105fa7:	83 f8 01             	cmp    $0x1,%eax
80105faa:	0f 84 80 01 00 00    	je     80106130 <getprocs+0x1c6>
    {
      proctable[i].pid = p->pid;
80105fb0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105fb3:	89 d0                	mov    %edx,%eax
80105fb5:	01 c0                	add    %eax,%eax
80105fb7:	01 d0                	add    %edx,%eax
80105fb9:	c1 e0 05             	shl    $0x5,%eax
80105fbc:	89 c2                	mov    %eax,%edx
80105fbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fc1:	01 c2                	add    %eax,%edx
80105fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fc6:	8b 40 10             	mov    0x10(%eax),%eax
80105fc9:	89 02                	mov    %eax,(%edx)
      proctable[i].uid = p->uid;
80105fcb:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105fce:	89 d0                	mov    %edx,%eax
80105fd0:	01 c0                	add    %eax,%eax
80105fd2:	01 d0                	add    %edx,%eax
80105fd4:	c1 e0 05             	shl    $0x5,%eax
80105fd7:	89 c2                	mov    %eax,%edx
80105fd9:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fdc:	01 c2                	add    %eax,%edx
80105fde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fe1:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105fe7:	89 42 04             	mov    %eax,0x4(%edx)
      proctable[i].gid = p->gid;
80105fea:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105fed:	89 d0                	mov    %edx,%eax
80105fef:	01 c0                	add    %eax,%eax
80105ff1:	01 d0                	add    %edx,%eax
80105ff3:	c1 e0 05             	shl    $0x5,%eax
80105ff6:	89 c2                	mov    %eax,%edx
80105ff8:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ffb:	01 c2                	add    %eax,%edx
80105ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106000:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80106006:	89 42 08             	mov    %eax,0x8(%edx)
      if(p->parent != 0)
80106009:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010600c:	8b 40 14             	mov    0x14(%eax),%eax
8010600f:	85 c0                	test   %eax,%eax
80106011:	74 21                	je     80106034 <getprocs+0xca>
        proctable[i].ppid = p->parent->pid;
80106013:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106016:	89 d0                	mov    %edx,%eax
80106018:	01 c0                	add    %eax,%eax
8010601a:	01 d0                	add    %edx,%eax
8010601c:	c1 e0 05             	shl    $0x5,%eax
8010601f:	89 c2                	mov    %eax,%edx
80106021:	8b 45 0c             	mov    0xc(%ebp),%eax
80106024:	01 c2                	add    %eax,%edx
80106026:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106029:	8b 40 14             	mov    0x14(%eax),%eax
8010602c:	8b 40 10             	mov    0x10(%eax),%eax
8010602f:	89 42 0c             	mov    %eax,0xc(%edx)
80106032:	eb 1c                	jmp    80106050 <getprocs+0xe6>
      else
        proctable[i].ppid = p->pid;
80106034:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106037:	89 d0                	mov    %edx,%eax
80106039:	01 c0                	add    %eax,%eax
8010603b:	01 d0                	add    %edx,%eax
8010603d:	c1 e0 05             	shl    $0x5,%eax
80106040:	89 c2                	mov    %eax,%edx
80106042:	8b 45 0c             	mov    0xc(%ebp),%eax
80106045:	01 c2                	add    %eax,%edx
80106047:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010604a:	8b 40 10             	mov    0x10(%eax),%eax
8010604d:	89 42 0c             	mov    %eax,0xc(%edx)

      //Get the current ticks for elapsed ticks.
      proctable[i].elapsed_ticks = ticks-p->start_ticks;
80106050:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106053:	89 d0                	mov    %edx,%eax
80106055:	01 c0                	add    %eax,%eax
80106057:	01 d0                	add    %edx,%eax
80106059:	c1 e0 05             	shl    $0x5,%eax
8010605c:	89 c2                	mov    %eax,%edx
8010605e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106061:	01 c2                	add    %eax,%edx
80106063:	8b 0d 20 79 11 80    	mov    0x80117920,%ecx
80106069:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010606c:	8b 40 7c             	mov    0x7c(%eax),%eax
8010606f:	29 c1                	sub    %eax,%ecx
80106071:	89 c8                	mov    %ecx,%eax
80106073:	89 42 10             	mov    %eax,0x10(%edx)
      proctable[i].CPU_total_ticks = p->cpu_ticks_total;
80106076:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106079:	89 d0                	mov    %edx,%eax
8010607b:	01 c0                	add    %eax,%eax
8010607d:	01 d0                	add    %edx,%eax
8010607f:	c1 e0 05             	shl    $0x5,%eax
80106082:	89 c2                	mov    %eax,%edx
80106084:	8b 45 0c             	mov    0xc(%ebp),%eax
80106087:	01 c2                	add    %eax,%edx
80106089:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010608c:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80106092:	89 42 14             	mov    %eax,0x14(%edx)
      safestrcpy(proctable[i].state, states[p->state], sizeof(proctable[i].state));
80106095:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106098:	8b 40 0c             	mov    0xc(%eax),%eax
8010609b:	8b 0c 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%ecx
801060a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801060a5:	89 d0                	mov    %edx,%eax
801060a7:	01 c0                	add    %eax,%eax
801060a9:	01 d0                	add    %edx,%eax
801060ab:	c1 e0 05             	shl    $0x5,%eax
801060ae:	89 c2                	mov    %eax,%edx
801060b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801060b3:	01 d0                	add    %edx,%eax
801060b5:	83 c0 18             	add    $0x18,%eax
801060b8:	83 ec 04             	sub    $0x4,%esp
801060bb:	6a 20                	push   $0x20
801060bd:	51                   	push   %ecx
801060be:	50                   	push   %eax
801060bf:	e8 07 0c 00 00       	call   80106ccb <safestrcpy>
801060c4:	83 c4 10             	add    $0x10,%esp
      proctable[i].size = p->sz;
801060c7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801060ca:	89 d0                	mov    %edx,%eax
801060cc:	01 c0                	add    %eax,%eax
801060ce:	01 d0                	add    %edx,%eax
801060d0:	c1 e0 05             	shl    $0x5,%eax
801060d3:	89 c2                	mov    %eax,%edx
801060d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801060d8:	01 c2                	add    %eax,%edx
801060da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060dd:	8b 00                	mov    (%eax),%eax
801060df:	89 42 38             	mov    %eax,0x38(%edx)
      safestrcpy(proctable[i].name, p->name, sizeof(p->name));
801060e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060e5:	8d 48 6c             	lea    0x6c(%eax),%ecx
801060e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801060eb:	89 d0                	mov    %edx,%eax
801060ed:	01 c0                	add    %eax,%eax
801060ef:	01 d0                	add    %edx,%eax
801060f1:	c1 e0 05             	shl    $0x5,%eax
801060f4:	89 c2                	mov    %eax,%edx
801060f6:	8b 45 0c             	mov    0xc(%ebp),%eax
801060f9:	01 d0                	add    %edx,%eax
801060fb:	83 c0 3c             	add    $0x3c,%eax
801060fe:	83 ec 04             	sub    $0x4,%esp
80106101:	6a 10                	push   $0x10
80106103:	51                   	push   %ecx
80106104:	50                   	push   %eax
80106105:	e8 c1 0b 00 00       	call   80106ccb <safestrcpy>
8010610a:	83 c4 10             	add    $0x10,%esp
      proctable[i].priority = p->priority;
8010610d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106110:	89 d0                	mov    %edx,%eax
80106112:	01 c0                	add    %eax,%eax
80106114:	01 d0                	add    %edx,%eax
80106116:	c1 e0 05             	shl    $0x5,%eax
80106119:	89 c2                	mov    %eax,%edx
8010611b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010611e:	01 c2                	add    %eax,%edx
80106120:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106123:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80106129:	89 42 5c             	mov    %eax,0x5c(%edx)

      //Increment the array that is having info copied into
      ++i;
8010612c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  //LOCK PTABLE
  acquire(&ptable.lock);

  //ptable gets incremented within forloop, i get incremented at the end
  //of the forloop.
  for(i=0, p = ptable.proc; p < &ptable.proc[NPROC] && i<max; p++)
80106130:	81 45 f4 9c 00 00 00 	addl   $0x9c,-0xc(%ebp)
80106137:	81 7d f4 b4 70 11 80 	cmpl   $0x801170b4,-0xc(%ebp)
8010613e:	73 0c                	jae    8010614c <getprocs+0x1e2>
80106140:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106143:	3b 45 08             	cmp    0x8(%ebp),%eax
80106146:	0f 8c 47 fe ff ff    	jl     80105f93 <getprocs+0x29>

    }
  }

  //UNLOCK PTABLE
  release(&ptable.lock);
8010614c:	83 ec 0c             	sub    $0xc,%esp
8010614f:	68 80 49 11 80       	push   $0x80114980
80106154:	e8 73 07 00 00       	call   801068cc <release>
80106159:	83 c4 10             	add    $0x10,%esp

  return i;
8010615c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010615f:	c9                   	leave  
80106160:	c3                   	ret    

80106161 <piddump>:

void
piddump(void)
{
80106161:	55                   	push   %ebp
80106162:	89 e5                	mov    %esp,%ebp
80106164:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  cprintf("\nReady List Processes:\n");
80106167:	83 ec 0c             	sub    $0xc,%esp
8010616a:	68 c1 a5 10 80       	push   $0x8010a5c1
8010616f:	e8 52 a2 ff ff       	call   801003c6 <cprintf>
80106174:	83 c4 10             	add    $0x10,%esp
  acquire(&ptable.lock);
80106177:	83 ec 0c             	sub    $0xc,%esp
8010617a:	68 80 49 11 80       	push   $0x80114980
8010617f:	e8 e1 06 00 00       	call   80106865 <acquire>
80106184:	83 c4 10             	add    $0x10,%esp
  for(int i = 0; i < MAXPRIO; ++i)
80106187:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010618e:	e9 8b 00 00 00       	jmp    8010621e <piddump+0xbd>
  {
    cprintf("%d: ", i);
80106193:	83 ec 08             	sub    $0x8,%esp
80106196:	ff 75 f0             	pushl  -0x10(%ebp)
80106199:	68 d9 a5 10 80       	push   $0x8010a5d9
8010619e:	e8 23 a2 ff ff       	call   801003c6 <cprintf>
801061a3:	83 c4 10             	add    $0x10,%esp
    p = ptable.pLists.ready[i];
801061a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061a9:	05 cc 09 00 00       	add    $0x9cc,%eax
801061ae:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
801061b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while(p)
801061b8:	eb 4a                	jmp    80106204 <piddump+0xa3>
    {
      cprintf("(%d, %d)", p->pid, p->budget);
801061ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061bd:	8b 90 94 00 00 00    	mov    0x94(%eax),%edx
801061c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061c6:	8b 40 10             	mov    0x10(%eax),%eax
801061c9:	83 ec 04             	sub    $0x4,%esp
801061cc:	52                   	push   %edx
801061cd:	50                   	push   %eax
801061ce:	68 de a5 10 80       	push   $0x8010a5de
801061d3:	e8 ee a1 ff ff       	call   801003c6 <cprintf>
801061d8:	83 c4 10             	add    $0x10,%esp
      if(p->next)
801061db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061de:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801061e4:	85 c0                	test   %eax,%eax
801061e6:	74 10                	je     801061f8 <piddump+0x97>
        cprintf(" -> ");
801061e8:	83 ec 0c             	sub    $0xc,%esp
801061eb:	68 e7 a5 10 80       	push   $0x8010a5e7
801061f0:	e8 d1 a1 ff ff       	call   801003c6 <cprintf>
801061f5:	83 c4 10             	add    $0x10,%esp
      p = p->next;
801061f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061fb:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106201:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&ptable.lock);
  for(int i = 0; i < MAXPRIO; ++i)
  {
    cprintf("%d: ", i);
    p = ptable.pLists.ready[i];
    while(p)
80106204:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106208:	75 b0                	jne    801061ba <piddump+0x59>
      cprintf("(%d, %d)", p->pid, p->budget);
      if(p->next)
        cprintf(" -> ");
      p = p->next;
    }
    cprintf("\n");
8010620a:	83 ec 0c             	sub    $0xc,%esp
8010620d:	68 89 a5 10 80       	push   $0x8010a589
80106212:	e8 af a1 ff ff       	call   801003c6 <cprintf>
80106217:	83 c4 10             	add    $0x10,%esp
piddump(void)
{
  struct proc *p;
  cprintf("\nReady List Processes:\n");
  acquire(&ptable.lock);
  for(int i = 0; i < MAXPRIO; ++i)
8010621a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010621e:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80106222:	0f 8e 6b ff ff ff    	jle    80106193 <piddump+0x32>
        cprintf(" -> ");
      p = p->next;
    }
    cprintf("\n");
  }
  cprintf("\n");
80106228:	83 ec 0c             	sub    $0xc,%esp
8010622b:	68 89 a5 10 80       	push   $0x8010a589
80106230:	e8 91 a1 ff ff       	call   801003c6 <cprintf>
80106235:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80106238:	83 ec 0c             	sub    $0xc,%esp
8010623b:	68 80 49 11 80       	push   $0x80114980
80106240:	e8 87 06 00 00       	call   801068cc <release>
80106245:	83 c4 10             	add    $0x10,%esp
}
80106248:	90                   	nop
80106249:	c9                   	leave  
8010624a:	c3                   	ret    

8010624b <freedump>:

void
freedump(void)
{
8010624b:	55                   	push   %ebp
8010624c:	89 e5                	mov    %esp,%ebp
8010624e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int counter = 0;
80106251:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  acquire(&ptable.lock);
80106258:	83 ec 0c             	sub    $0xc,%esp
8010625b:	68 80 49 11 80       	push   $0x80114980
80106260:	e8 00 06 00 00       	call   80106865 <acquire>
80106265:	83 c4 10             	add    $0x10,%esp
  p = ptable.pLists.free;
80106268:	a1 e4 70 11 80       	mov    0x801170e4,%eax
8010626d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(p)
80106270:	eb 10                	jmp    80106282 <freedump+0x37>
  {
    p = p->next;
80106272:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106275:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010627b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    ++counter;
8010627e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
{
  struct proc *p;
  int counter = 0;
  acquire(&ptable.lock);
  p = ptable.pLists.free;
  while(p)
80106282:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106286:	75 ea                	jne    80106272 <freedump+0x27>
  {
    p = p->next;
    ++counter;
  }

  cprintf("\nFree List Size: %d processes\n", counter);
80106288:	83 ec 08             	sub    $0x8,%esp
8010628b:	ff 75 f0             	pushl  -0x10(%ebp)
8010628e:	68 ec a5 10 80       	push   $0x8010a5ec
80106293:	e8 2e a1 ff ff       	call   801003c6 <cprintf>
80106298:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
8010629b:	83 ec 0c             	sub    $0xc,%esp
8010629e:	68 80 49 11 80       	push   $0x80114980
801062a3:	e8 24 06 00 00       	call   801068cc <release>
801062a8:	83 c4 10             	add    $0x10,%esp
}
801062ab:	90                   	nop
801062ac:	c9                   	leave  
801062ad:	c3                   	ret    

801062ae <sleepdump>:

void
sleepdump(void)
{
801062ae:	55                   	push   %ebp
801062af:	89 e5                	mov    %esp,%ebp
801062b1:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  acquire(&ptable.lock);
801062b4:	83 ec 0c             	sub    $0xc,%esp
801062b7:	68 80 49 11 80       	push   $0x80114980
801062bc:	e8 a4 05 00 00       	call   80106865 <acquire>
801062c1:	83 c4 10             	add    $0x10,%esp
  p = ptable.pLists.sleep;
801062c4:	a1 ec 70 11 80       	mov    0x801170ec,%eax
801062c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cprintf("\nSleep List Processes:\n");
801062cc:	83 ec 0c             	sub    $0xc,%esp
801062cf:	68 0b a6 10 80       	push   $0x8010a60b
801062d4:	e8 ed a0 ff ff       	call   801003c6 <cprintf>
801062d9:	83 c4 10             	add    $0x10,%esp
  while(p)
801062dc:	eb 40                	jmp    8010631e <sleepdump+0x70>
  {
    cprintf("%d", p->pid);
801062de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e1:	8b 40 10             	mov    0x10(%eax),%eax
801062e4:	83 ec 08             	sub    $0x8,%esp
801062e7:	50                   	push   %eax
801062e8:	68 78 a5 10 80       	push   $0x8010a578
801062ed:	e8 d4 a0 ff ff       	call   801003c6 <cprintf>
801062f2:	83 c4 10             	add    $0x10,%esp
    if(p->next)
801062f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062f8:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801062fe:	85 c0                	test   %eax,%eax
80106300:	74 10                	je     80106312 <sleepdump+0x64>
      cprintf(" -> ");
80106302:	83 ec 0c             	sub    $0xc,%esp
80106305:	68 e7 a5 10 80       	push   $0x8010a5e7
8010630a:	e8 b7 a0 ff ff       	call   801003c6 <cprintf>
8010630f:	83 c4 10             	add    $0x10,%esp
    p = p->next;
80106312:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106315:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010631b:	89 45 f4             	mov    %eax,-0xc(%ebp)
{
  struct proc *p;
  acquire(&ptable.lock);
  p = ptable.pLists.sleep;
  cprintf("\nSleep List Processes:\n");
  while(p)
8010631e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106322:	75 ba                	jne    801062de <sleepdump+0x30>
    cprintf("%d", p->pid);
    if(p->next)
      cprintf(" -> ");
    p = p->next;
  }
  cprintf("\n");
80106324:	83 ec 0c             	sub    $0xc,%esp
80106327:	68 89 a5 10 80       	push   $0x8010a589
8010632c:	e8 95 a0 ff ff       	call   801003c6 <cprintf>
80106331:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80106334:	83 ec 0c             	sub    $0xc,%esp
80106337:	68 80 49 11 80       	push   $0x80114980
8010633c:	e8 8b 05 00 00       	call   801068cc <release>
80106341:	83 c4 10             	add    $0x10,%esp
}
80106344:	90                   	nop
80106345:	c9                   	leave  
80106346:	c3                   	ret    

80106347 <zombiedump>:

void
zombiedump(void)
{
80106347:	55                   	push   %ebp
80106348:	89 e5                	mov    %esp,%ebp
8010634a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  acquire(&ptable.lock);
8010634d:	83 ec 0c             	sub    $0xc,%esp
80106350:	68 80 49 11 80       	push   $0x80114980
80106355:	e8 0b 05 00 00       	call   80106865 <acquire>
8010635a:	83 c4 10             	add    $0x10,%esp
  p = ptable.pLists.zombie;
8010635d:	a1 f4 70 11 80       	mov    0x801170f4,%eax
80106362:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cprintf("\nZombie List Processes:\n");
80106365:	83 ec 0c             	sub    $0xc,%esp
80106368:	68 23 a6 10 80       	push   $0x8010a623
8010636d:	e8 54 a0 ff ff       	call   801003c6 <cprintf>
80106372:	83 c4 10             	add    $0x10,%esp
  while(p)
80106375:	eb 5c                	jmp    801063d3 <zombiedump+0x8c>
  {
    cprintf("(PID%d, PPID%d)", p->pid, (p->parent? p->parent->pid : p->pid));
80106377:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010637a:	8b 40 14             	mov    0x14(%eax),%eax
8010637d:	85 c0                	test   %eax,%eax
8010637f:	74 0b                	je     8010638c <zombiedump+0x45>
80106381:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106384:	8b 40 14             	mov    0x14(%eax),%eax
80106387:	8b 40 10             	mov    0x10(%eax),%eax
8010638a:	eb 06                	jmp    80106392 <zombiedump+0x4b>
8010638c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010638f:	8b 40 10             	mov    0x10(%eax),%eax
80106392:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106395:	8b 52 10             	mov    0x10(%edx),%edx
80106398:	83 ec 04             	sub    $0x4,%esp
8010639b:	50                   	push   %eax
8010639c:	52                   	push   %edx
8010639d:	68 3c a6 10 80       	push   $0x8010a63c
801063a2:	e8 1f a0 ff ff       	call   801003c6 <cprintf>
801063a7:	83 c4 10             	add    $0x10,%esp
    if(p->next)
801063aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063ad:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801063b3:	85 c0                	test   %eax,%eax
801063b5:	74 10                	je     801063c7 <zombiedump+0x80>
      cprintf(" -> ");
801063b7:	83 ec 0c             	sub    $0xc,%esp
801063ba:	68 e7 a5 10 80       	push   $0x8010a5e7
801063bf:	e8 02 a0 ff ff       	call   801003c6 <cprintf>
801063c4:	83 c4 10             	add    $0x10,%esp
    p = p->next;
801063c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063ca:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801063d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
{
  struct proc *p;
  acquire(&ptable.lock);
  p = ptable.pLists.zombie;
  cprintf("\nZombie List Processes:\n");
  while(p)
801063d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063d7:	75 9e                	jne    80106377 <zombiedump+0x30>
    cprintf("(PID%d, PPID%d)", p->pid, (p->parent? p->parent->pid : p->pid));
    if(p->next)
      cprintf(" -> ");
    p = p->next;
  }
  cprintf("\n");
801063d9:	83 ec 0c             	sub    $0xc,%esp
801063dc:	68 89 a5 10 80       	push   $0x8010a589
801063e1:	e8 e0 9f ff ff       	call   801003c6 <cprintf>
801063e6:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801063e9:	83 ec 0c             	sub    $0xc,%esp
801063ec:	68 80 49 11 80       	push   $0x80114980
801063f1:	e8 d6 04 00 00       	call   801068cc <release>
801063f6:	83 c4 10             	add    $0x10,%esp
}
801063f9:	90                   	nop
801063fa:	c9                   	leave  
801063fb:	c3                   	ret    

801063fc <assertState>:

void
assertState(struct proc* p, enum procstate state)
{
801063fc:	55                   	push   %ebp
801063fd:	89 e5                	mov    %esp,%ebp
801063ff:	83 ec 08             	sub    $0x8,%esp
  if(p->state != state)
80106402:	8b 45 08             	mov    0x8(%ebp),%eax
80106405:	8b 40 0c             	mov    0xc(%eax),%eax
80106408:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010640b:	74 0d                	je     8010641a <assertState+0x1e>
    panic("proc state does not match list state.");
8010640d:	83 ec 0c             	sub    $0xc,%esp
80106410:	68 4c a6 10 80       	push   $0x8010a64c
80106415:	e8 4c a1 ff ff       	call   80100566 <panic>
}
8010641a:	90                   	nop
8010641b:	c9                   	leave  
8010641c:	c3                   	ret    

8010641d <setpriority>:

int
setpriority(int pid, int priority)
{
8010641d:	55                   	push   %ebp
8010641e:	89 e5                	mov    %esp,%ebp
80106420:	83 ec 18             	sub    $0x18,%esp
  struct proc * p;
  int found = 0;
80106423:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(pid < 0 || priority < 0 || priority > MAXPRIO)
8010642a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010642e:	78 0c                	js     8010643c <setpriority+0x1f>
80106430:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106434:	78 06                	js     8010643c <setpriority+0x1f>
80106436:	83 7d 0c 05          	cmpl   $0x5,0xc(%ebp)
8010643a:	7e 0a                	jle    80106446 <setpriority+0x29>
    return -1;
8010643c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106441:	e9 03 02 00 00       	jmp    80106649 <setpriority+0x22c>
  acquire(&ptable.lock);
80106446:	83 ec 0c             	sub    $0xc,%esp
80106449:	68 80 49 11 80       	push   $0x80114980
8010644e:	e8 12 04 00 00       	call   80106865 <acquire>
80106453:	83 c4 10             	add    $0x10,%esp
  for(int i = 0; !found && i < MAXPRIO; i++)
80106456:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010645d:	e9 01 01 00 00       	jmp    80106563 <setpriority+0x146>
  {
    for(p = ptable.pLists.ready[i];!found && p;p=p->next)
80106462:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106465:	05 cc 09 00 00       	add    $0x9cc,%eax
8010646a:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
80106471:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106474:	e9 d6 00 00 00       	jmp    8010654f <setpriority+0x132>
    {
      if(p->pid == pid)
80106479:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010647c:	8b 50 10             	mov    0x10(%eax),%edx
8010647f:	8b 45 08             	mov    0x8(%ebp),%eax
80106482:	39 c2                	cmp    %eax,%edx
80106484:	0f 85 b9 00 00 00    	jne    80106543 <setpriority+0x126>
      {
        p->priority = priority;
8010648a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010648d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106490:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
        p->budget = BUDGET*(p->priority+1);
80106496:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106499:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
8010649f:	83 c0 01             	add    $0x1,%eax
801064a2:	6b d0 64             	imul   $0x64,%eax,%edx
801064a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064a8:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
        if(stateListRemove(&ptable.pLists.ready[i], &ptable.pLists.readyTail[i], p))
801064ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
801064b1:	05 d0 09 00 00       	add    $0x9d0,%eax
801064b6:	c1 e0 02             	shl    $0x2,%eax
801064b9:	05 80 49 11 80       	add    $0x80114980,%eax
801064be:	8d 50 0c             	lea    0xc(%eax),%edx
801064c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801064c4:	05 cc 09 00 00       	add    $0x9cc,%eax
801064c9:	c1 e0 02             	shl    $0x2,%eax
801064cc:	05 80 49 11 80       	add    $0x80114980,%eax
801064d1:	83 c0 04             	add    $0x4,%eax
801064d4:	83 ec 04             	sub    $0x4,%esp
801064d7:	ff 75 f4             	pushl  -0xc(%ebp)
801064da:	52                   	push   %edx
801064db:	50                   	push   %eax
801064dc:	e8 9b f8 ff ff       	call   80105d7c <stateListRemove>
801064e1:	83 c4 10             	add    $0x10,%esp
801064e4:	85 c0                	test   %eax,%eax
801064e6:	74 0d                	je     801064f5 <setpriority+0xd8>
          panic("Error removing process from current prioity");
801064e8:	83 ec 0c             	sub    $0xc,%esp
801064eb:	68 74 a6 10 80       	push   $0x8010a674
801064f0:	e8 71 a0 ff ff       	call   80100566 <panic>
        if(stateListAdd(&ptable.pLists.ready[priority], &ptable.pLists.readyTail[priority],p))
801064f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801064f8:	05 d0 09 00 00       	add    $0x9d0,%eax
801064fd:	c1 e0 02             	shl    $0x2,%eax
80106500:	05 80 49 11 80       	add    $0x80114980,%eax
80106505:	8d 50 0c             	lea    0xc(%eax),%edx
80106508:	8b 45 0c             	mov    0xc(%ebp),%eax
8010650b:	05 cc 09 00 00       	add    $0x9cc,%eax
80106510:	c1 e0 02             	shl    $0x2,%eax
80106513:	05 80 49 11 80       	add    $0x80114980,%eax
80106518:	83 c0 04             	add    $0x4,%eax
8010651b:	83 ec 04             	sub    $0x4,%esp
8010651e:	ff 75 f4             	pushl  -0xc(%ebp)
80106521:	52                   	push   %edx
80106522:	50                   	push   %eax
80106523:	e8 f5 f7 ff ff       	call   80105d1d <stateListAdd>
80106528:	83 c4 10             	add    $0x10,%esp
8010652b:	85 c0                	test   %eax,%eax
8010652d:	74 0d                	je     8010653c <setpriority+0x11f>
          panic("error adding process to desired priority");
8010652f:	83 ec 0c             	sub    $0xc,%esp
80106532:	68 a0 a6 10 80       	push   $0x8010a6a0
80106537:	e8 2a a0 ff ff       	call   80100566 <panic>
        found = 1;
8010653c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  if(pid < 0 || priority < 0 || priority > MAXPRIO)
    return -1;
  acquire(&ptable.lock);
  for(int i = 0; !found && i < MAXPRIO; i++)
  {
    for(p = ptable.pLists.ready[i];!found && p;p=p->next)
80106543:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106546:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010654c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010654f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106553:	75 0a                	jne    8010655f <setpriority+0x142>
80106555:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106559:	0f 85 1a ff ff ff    	jne    80106479 <setpriority+0x5c>
  struct proc * p;
  int found = 0;
  if(pid < 0 || priority < 0 || priority > MAXPRIO)
    return -1;
  acquire(&ptable.lock);
  for(int i = 0; !found && i < MAXPRIO; i++)
8010655f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80106563:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106567:	75 0a                	jne    80106573 <setpriority+0x156>
80106569:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
8010656d:	0f 8e ef fe ff ff    	jle    80106462 <setpriority+0x45>
          panic("error adding process to desired priority");
        found = 1;
      }
    }
  }
  for(p = ptable.pLists.sleep;!found && p; p=p->next)
80106573:	a1 ec 70 11 80       	mov    0x801170ec,%eax
80106578:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010657b:	eb 44                	jmp    801065c1 <setpriority+0x1a4>
  {
    if(p->pid == pid)
8010657d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106580:	8b 50 10             	mov    0x10(%eax),%edx
80106583:	8b 45 08             	mov    0x8(%ebp),%eax
80106586:	39 c2                	cmp    %eax,%edx
80106588:	75 2b                	jne    801065b5 <setpriority+0x198>
    {
      p->priority = priority;
8010658a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010658d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106590:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
      p->budget = BUDGET*(p->priority+1);
80106596:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106599:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
8010659f:	83 c0 01             	add    $0x1,%eax
801065a2:	6b d0 64             	imul   $0x64,%eax,%edx
801065a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065a8:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
      found = 1;
801065ae:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
          panic("error adding process to desired priority");
        found = 1;
      }
    }
  }
  for(p = ptable.pLists.sleep;!found && p; p=p->next)
801065b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065b8:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801065be:	89 45 f4             	mov    %eax,-0xc(%ebp)
801065c1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065c5:	75 06                	jne    801065cd <setpriority+0x1b0>
801065c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065cb:	75 b0                	jne    8010657d <setpriority+0x160>
      p->priority = priority;
      p->budget = BUDGET*(p->priority+1);
      found = 1;
    }
  }
  for(p = ptable.pLists.running;!found && p; p=p->next)
801065cd:	a1 fc 70 11 80       	mov    0x801170fc,%eax
801065d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801065d5:	eb 44                	jmp    8010661b <setpriority+0x1fe>
  {
    if(p->pid == pid)
801065d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065da:	8b 50 10             	mov    0x10(%eax),%edx
801065dd:	8b 45 08             	mov    0x8(%ebp),%eax
801065e0:	39 c2                	cmp    %eax,%edx
801065e2:	75 2b                	jne    8010660f <setpriority+0x1f2>
    {
      p->priority = priority;
801065e4:	8b 55 0c             	mov    0xc(%ebp),%edx
801065e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065ea:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
      p->budget = BUDGET*(p->priority+1);
801065f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065f3:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801065f9:	83 c0 01             	add    $0x1,%eax
801065fc:	6b d0 64             	imul   $0x64,%eax,%edx
801065ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106602:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
      found = 1;
80106608:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      p->priority = priority;
      p->budget = BUDGET*(p->priority+1);
      found = 1;
    }
  }
  for(p = ptable.pLists.running;!found && p; p=p->next)
8010660f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106612:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106618:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010661b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010661f:	75 06                	jne    80106627 <setpriority+0x20a>
80106621:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106625:	75 b0                	jne    801065d7 <setpriority+0x1ba>
      p->priority = priority;
      p->budget = BUDGET*(p->priority+1);
      found = 1;
    }
  }
  release(&ptable.lock);
80106627:	83 ec 0c             	sub    $0xc,%esp
8010662a:	68 80 49 11 80       	push   $0x80114980
8010662f:	e8 98 02 00 00       	call   801068cc <release>
80106634:	83 c4 10             	add    $0x10,%esp
  if(found)
80106637:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010663b:	74 07                	je     80106644 <setpriority+0x227>
    return 0;
8010663d:	b8 00 00 00 00       	mov    $0x0,%eax
80106642:	eb 05                	jmp    80106649 <setpriority+0x22c>
  return -1;
80106644:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106649:	c9                   	leave  
8010664a:	c3                   	ret    

8010664b <promoteAll>:

void
promoteAll(void)
{
8010664b:	55                   	push   %ebp
8010664c:	89 e5                	mov    %esp,%ebp
8010664e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  for(int i = 0; i< MAXPRIO; ++i)
80106651:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80106658:	e9 f5 00 00 00       	jmp    80106752 <promoteAll+0x107>
  {
    for(p = ptable.pLists.ready[i]; p ; p=p->next)
8010665d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106660:	05 cc 09 00 00       	add    $0x9cc,%eax
80106665:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
8010666c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010666f:	e9 d0 00 00 00       	jmp    80106744 <promoteAll+0xf9>
    {
      if(i > 0)
80106674:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106678:	0f 8e a2 00 00 00    	jle    80106720 <promoteAll+0xd5>
      {
        if(stateListRemove(&ptable.pLists.ready[i], &ptable.pLists.readyTail[i], p))
8010667e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106681:	05 d0 09 00 00       	add    $0x9d0,%eax
80106686:	c1 e0 02             	shl    $0x2,%eax
80106689:	05 80 49 11 80       	add    $0x80114980,%eax
8010668e:	8d 50 0c             	lea    0xc(%eax),%edx
80106691:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106694:	05 cc 09 00 00       	add    $0x9cc,%eax
80106699:	c1 e0 02             	shl    $0x2,%eax
8010669c:	05 80 49 11 80       	add    $0x80114980,%eax
801066a1:	83 c0 04             	add    $0x4,%eax
801066a4:	ff 75 f4             	pushl  -0xc(%ebp)
801066a7:	52                   	push   %edx
801066a8:	50                   	push   %eax
801066a9:	e8 ce f6 ff ff       	call   80105d7c <stateListRemove>
801066ae:	83 c4 0c             	add    $0xc,%esp
801066b1:	85 c0                	test   %eax,%eax
801066b3:	74 0d                	je     801066c2 <promoteAll+0x77>
          panic("Error removing process from current priority");
801066b5:	83 ec 0c             	sub    $0xc,%esp
801066b8:	68 cc a6 10 80       	push   $0x8010a6cc
801066bd:	e8 a4 9e ff ff       	call   80100566 <panic>
        p->priority = i - 1;
801066c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066c5:	83 e8 01             	sub    $0x1,%eax
801066c8:	89 c2                	mov    %eax,%edx
801066ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066cd:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
        if(stateListAdd(&ptable.pLists.ready[(i-1)], &ptable.pLists.readyTail[(i-1)], p))
801066d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066d6:	83 e8 01             	sub    $0x1,%eax
801066d9:	05 d0 09 00 00       	add    $0x9d0,%eax
801066de:	c1 e0 02             	shl    $0x2,%eax
801066e1:	05 80 49 11 80       	add    $0x80114980,%eax
801066e6:	8d 50 0c             	lea    0xc(%eax),%edx
801066e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066ec:	83 e8 01             	sub    $0x1,%eax
801066ef:	05 cc 09 00 00       	add    $0x9cc,%eax
801066f4:	c1 e0 02             	shl    $0x2,%eax
801066f7:	05 80 49 11 80       	add    $0x80114980,%eax
801066fc:	83 c0 04             	add    $0x4,%eax
801066ff:	83 ec 04             	sub    $0x4,%esp
80106702:	ff 75 f4             	pushl  -0xc(%ebp)
80106705:	52                   	push   %edx
80106706:	50                   	push   %eax
80106707:	e8 11 f6 ff ff       	call   80105d1d <stateListAdd>
8010670c:	83 c4 10             	add    $0x10,%esp
8010670f:	85 c0                	test   %eax,%eax
80106711:	74 0d                	je     80106720 <promoteAll+0xd5>
          panic("Error adding process to desired priority");
80106713:	83 ec 0c             	sub    $0xc,%esp
80106716:	68 fc a6 10 80       	push   $0x8010a6fc
8010671b:	e8 46 9e ff ff       	call   80100566 <panic>
      }
      p->budget = BUDGET*(p->priority+1);
80106720:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106723:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80106729:	83 c0 01             	add    $0x1,%eax
8010672c:	6b d0 64             	imul   $0x64,%eax,%edx
8010672f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106732:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
promoteAll(void)
{
  struct proc *p;
  for(int i = 0; i< MAXPRIO; ++i)
  {
    for(p = ptable.pLists.ready[i]; p ; p=p->next)
80106738:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010673b:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106741:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106744:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106748:	0f 85 26 ff ff ff    	jne    80106674 <promoteAll+0x29>

void
promoteAll(void)
{
  struct proc *p;
  for(int i = 0; i< MAXPRIO; ++i)
8010674e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80106752:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80106756:	0f 8e 01 ff ff ff    	jle    8010665d <promoteAll+0x12>
          panic("Error adding process to desired priority");
      }
      p->budget = BUDGET*(p->priority+1);
    }
  }
  for(p = ptable.pLists.sleep; p ; p=p->next)
8010675c:	a1 ec 70 11 80       	mov    0x801170ec,%eax
80106761:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106764:	eb 46                	jmp    801067ac <promoteAll+0x161>
  {
    if(p->priority > 0)
80106766:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106769:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
8010676f:	85 c0                	test   %eax,%eax
80106771:	74 15                	je     80106788 <promoteAll+0x13d>
      p->priority = p->priority - 1;
80106773:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106776:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
8010677c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010677f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106782:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)

    p->budget = BUDGET*(p->priority+1);
80106788:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010678b:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80106791:	83 c0 01             	add    $0x1,%eax
80106794:	6b d0 64             	imul   $0x64,%eax,%edx
80106797:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010679a:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
          panic("Error adding process to desired priority");
      }
      p->budget = BUDGET*(p->priority+1);
    }
  }
  for(p = ptable.pLists.sleep; p ; p=p->next)
801067a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067a3:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801067a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067ac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067b0:	75 b4                	jne    80106766 <promoteAll+0x11b>
    if(p->priority > 0)
      p->priority = p->priority - 1;

    p->budget = BUDGET*(p->priority+1);
  }
  for(p = ptable.pLists.running; p ; p=p->next)
801067b2:	a1 fc 70 11 80       	mov    0x801170fc,%eax
801067b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067ba:	eb 46                	jmp    80106802 <promoteAll+0x1b7>
  {
    if(p->priority > 0)
801067bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067bf:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801067c5:	85 c0                	test   %eax,%eax
801067c7:	74 15                	je     801067de <promoteAll+0x193>
      p->priority = p->priority - 1;
801067c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067cc:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801067d2:	8d 50 ff             	lea    -0x1(%eax),%edx
801067d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067d8:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)

    p->budget = BUDGET*(p->priority+1);
801067de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067e1:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801067e7:	83 c0 01             	add    $0x1,%eax
801067ea:	6b d0 64             	imul   $0x64,%eax,%edx
801067ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067f0:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
    if(p->priority > 0)
      p->priority = p->priority - 1;

    p->budget = BUDGET*(p->priority+1);
  }
  for(p = ptable.pLists.running; p ; p=p->next)
801067f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067f9:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801067ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106802:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106806:	75 b4                	jne    801067bc <promoteAll+0x171>
    if(p->priority > 0)
      p->priority = p->priority - 1;

    p->budget = BUDGET*(p->priority+1);
  }
}
80106808:	90                   	nop
80106809:	c9                   	leave  
8010680a:	c3                   	ret    

8010680b <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010680b:	55                   	push   %ebp
8010680c:	89 e5                	mov    %esp,%ebp
8010680e:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80106811:	9c                   	pushf  
80106812:	58                   	pop    %eax
80106813:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80106816:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106819:	c9                   	leave  
8010681a:	c3                   	ret    

8010681b <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010681b:	55                   	push   %ebp
8010681c:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010681e:	fa                   	cli    
}
8010681f:	90                   	nop
80106820:	5d                   	pop    %ebp
80106821:	c3                   	ret    

80106822 <sti>:

static inline void
sti(void)
{
80106822:	55                   	push   %ebp
80106823:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80106825:	fb                   	sti    
}
80106826:	90                   	nop
80106827:	5d                   	pop    %ebp
80106828:	c3                   	ret    

80106829 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80106829:	55                   	push   %ebp
8010682a:	89 e5                	mov    %esp,%ebp
8010682c:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010682f:	8b 55 08             	mov    0x8(%ebp),%edx
80106832:	8b 45 0c             	mov    0xc(%ebp),%eax
80106835:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106838:	f0 87 02             	lock xchg %eax,(%edx)
8010683b:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010683e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106841:	c9                   	leave  
80106842:	c3                   	ret    

80106843 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80106843:	55                   	push   %ebp
80106844:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80106846:	8b 45 08             	mov    0x8(%ebp),%eax
80106849:	8b 55 0c             	mov    0xc(%ebp),%edx
8010684c:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010684f:	8b 45 08             	mov    0x8(%ebp),%eax
80106852:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80106858:	8b 45 08             	mov    0x8(%ebp),%eax
8010685b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80106862:	90                   	nop
80106863:	5d                   	pop    %ebp
80106864:	c3                   	ret    

80106865 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80106865:	55                   	push   %ebp
80106866:	89 e5                	mov    %esp,%ebp
80106868:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010686b:	e8 52 01 00 00       	call   801069c2 <pushcli>
  if(holding(lk))
80106870:	8b 45 08             	mov    0x8(%ebp),%eax
80106873:	83 ec 0c             	sub    $0xc,%esp
80106876:	50                   	push   %eax
80106877:	e8 1c 01 00 00       	call   80106998 <holding>
8010687c:	83 c4 10             	add    $0x10,%esp
8010687f:	85 c0                	test   %eax,%eax
80106881:	74 0d                	je     80106890 <acquire+0x2b>
    panic("acquire");
80106883:	83 ec 0c             	sub    $0xc,%esp
80106886:	68 25 a7 10 80       	push   $0x8010a725
8010688b:	e8 d6 9c ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80106890:	90                   	nop
80106891:	8b 45 08             	mov    0x8(%ebp),%eax
80106894:	83 ec 08             	sub    $0x8,%esp
80106897:	6a 01                	push   $0x1
80106899:	50                   	push   %eax
8010689a:	e8 8a ff ff ff       	call   80106829 <xchg>
8010689f:	83 c4 10             	add    $0x10,%esp
801068a2:	85 c0                	test   %eax,%eax
801068a4:	75 eb                	jne    80106891 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801068a6:	8b 45 08             	mov    0x8(%ebp),%eax
801068a9:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801068b0:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
801068b3:	8b 45 08             	mov    0x8(%ebp),%eax
801068b6:	83 c0 0c             	add    $0xc,%eax
801068b9:	83 ec 08             	sub    $0x8,%esp
801068bc:	50                   	push   %eax
801068bd:	8d 45 08             	lea    0x8(%ebp),%eax
801068c0:	50                   	push   %eax
801068c1:	e8 58 00 00 00       	call   8010691e <getcallerpcs>
801068c6:	83 c4 10             	add    $0x10,%esp
}
801068c9:	90                   	nop
801068ca:	c9                   	leave  
801068cb:	c3                   	ret    

801068cc <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801068cc:	55                   	push   %ebp
801068cd:	89 e5                	mov    %esp,%ebp
801068cf:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801068d2:	83 ec 0c             	sub    $0xc,%esp
801068d5:	ff 75 08             	pushl  0x8(%ebp)
801068d8:	e8 bb 00 00 00       	call   80106998 <holding>
801068dd:	83 c4 10             	add    $0x10,%esp
801068e0:	85 c0                	test   %eax,%eax
801068e2:	75 0d                	jne    801068f1 <release+0x25>
    panic("release");
801068e4:	83 ec 0c             	sub    $0xc,%esp
801068e7:	68 2d a7 10 80       	push   $0x8010a72d
801068ec:	e8 75 9c ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
801068f1:	8b 45 08             	mov    0x8(%ebp),%eax
801068f4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801068fb:	8b 45 08             	mov    0x8(%ebp),%eax
801068fe:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80106905:	8b 45 08             	mov    0x8(%ebp),%eax
80106908:	83 ec 08             	sub    $0x8,%esp
8010690b:	6a 00                	push   $0x0
8010690d:	50                   	push   %eax
8010690e:	e8 16 ff ff ff       	call   80106829 <xchg>
80106913:	83 c4 10             	add    $0x10,%esp

  popcli();
80106916:	e8 ec 00 00 00       	call   80106a07 <popcli>
}
8010691b:	90                   	nop
8010691c:	c9                   	leave  
8010691d:	c3                   	ret    

8010691e <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010691e:	55                   	push   %ebp
8010691f:	89 e5                	mov    %esp,%ebp
80106921:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80106924:	8b 45 08             	mov    0x8(%ebp),%eax
80106927:	83 e8 08             	sub    $0x8,%eax
8010692a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010692d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80106934:	eb 38                	jmp    8010696e <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80106936:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010693a:	74 53                	je     8010698f <getcallerpcs+0x71>
8010693c:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80106943:	76 4a                	jbe    8010698f <getcallerpcs+0x71>
80106945:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80106949:	74 44                	je     8010698f <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010694b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010694e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106955:	8b 45 0c             	mov    0xc(%ebp),%eax
80106958:	01 c2                	add    %eax,%edx
8010695a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010695d:	8b 40 04             	mov    0x4(%eax),%eax
80106960:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80106962:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106965:	8b 00                	mov    (%eax),%eax
80106967:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
8010696a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010696e:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80106972:	7e c2                	jle    80106936 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80106974:	eb 19                	jmp    8010698f <getcallerpcs+0x71>
    pcs[i] = 0;
80106976:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106979:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106980:	8b 45 0c             	mov    0xc(%ebp),%eax
80106983:	01 d0                	add    %edx,%eax
80106985:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010698b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010698f:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80106993:	7e e1                	jle    80106976 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80106995:	90                   	nop
80106996:	c9                   	leave  
80106997:	c3                   	ret    

80106998 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80106998:	55                   	push   %ebp
80106999:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
8010699b:	8b 45 08             	mov    0x8(%ebp),%eax
8010699e:	8b 00                	mov    (%eax),%eax
801069a0:	85 c0                	test   %eax,%eax
801069a2:	74 17                	je     801069bb <holding+0x23>
801069a4:	8b 45 08             	mov    0x8(%ebp),%eax
801069a7:	8b 50 08             	mov    0x8(%eax),%edx
801069aa:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801069b0:	39 c2                	cmp    %eax,%edx
801069b2:	75 07                	jne    801069bb <holding+0x23>
801069b4:	b8 01 00 00 00       	mov    $0x1,%eax
801069b9:	eb 05                	jmp    801069c0 <holding+0x28>
801069bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801069c0:	5d                   	pop    %ebp
801069c1:	c3                   	ret    

801069c2 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801069c2:	55                   	push   %ebp
801069c3:	89 e5                	mov    %esp,%ebp
801069c5:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
801069c8:	e8 3e fe ff ff       	call   8010680b <readeflags>
801069cd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
801069d0:	e8 46 fe ff ff       	call   8010681b <cli>
  if(cpu->ncli++ == 0)
801069d5:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801069dc:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
801069e2:	8d 48 01             	lea    0x1(%eax),%ecx
801069e5:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
801069eb:	85 c0                	test   %eax,%eax
801069ed:	75 15                	jne    80106a04 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
801069ef:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801069f5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801069f8:	81 e2 00 02 00 00    	and    $0x200,%edx
801069fe:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80106a04:	90                   	nop
80106a05:	c9                   	leave  
80106a06:	c3                   	ret    

80106a07 <popcli>:

void
popcli(void)
{
80106a07:	55                   	push   %ebp
80106a08:	89 e5                	mov    %esp,%ebp
80106a0a:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80106a0d:	e8 f9 fd ff ff       	call   8010680b <readeflags>
80106a12:	25 00 02 00 00       	and    $0x200,%eax
80106a17:	85 c0                	test   %eax,%eax
80106a19:	74 0d                	je     80106a28 <popcli+0x21>
    panic("popcli - interruptible");
80106a1b:	83 ec 0c             	sub    $0xc,%esp
80106a1e:	68 35 a7 10 80       	push   $0x8010a735
80106a23:	e8 3e 9b ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80106a28:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a2e:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80106a34:	83 ea 01             	sub    $0x1,%edx
80106a37:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80106a3d:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80106a43:	85 c0                	test   %eax,%eax
80106a45:	79 0d                	jns    80106a54 <popcli+0x4d>
    panic("popcli");
80106a47:	83 ec 0c             	sub    $0xc,%esp
80106a4a:	68 4c a7 10 80       	push   $0x8010a74c
80106a4f:	e8 12 9b ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80106a54:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a5a:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80106a60:	85 c0                	test   %eax,%eax
80106a62:	75 15                	jne    80106a79 <popcli+0x72>
80106a64:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a6a:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80106a70:	85 c0                	test   %eax,%eax
80106a72:	74 05                	je     80106a79 <popcli+0x72>
    sti();
80106a74:	e8 a9 fd ff ff       	call   80106822 <sti>
}
80106a79:	90                   	nop
80106a7a:	c9                   	leave  
80106a7b:	c3                   	ret    

80106a7c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80106a7c:	55                   	push   %ebp
80106a7d:	89 e5                	mov    %esp,%ebp
80106a7f:	57                   	push   %edi
80106a80:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80106a81:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106a84:	8b 55 10             	mov    0x10(%ebp),%edx
80106a87:	8b 45 0c             	mov    0xc(%ebp),%eax
80106a8a:	89 cb                	mov    %ecx,%ebx
80106a8c:	89 df                	mov    %ebx,%edi
80106a8e:	89 d1                	mov    %edx,%ecx
80106a90:	fc                   	cld    
80106a91:	f3 aa                	rep stos %al,%es:(%edi)
80106a93:	89 ca                	mov    %ecx,%edx
80106a95:	89 fb                	mov    %edi,%ebx
80106a97:	89 5d 08             	mov    %ebx,0x8(%ebp)
80106a9a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80106a9d:	90                   	nop
80106a9e:	5b                   	pop    %ebx
80106a9f:	5f                   	pop    %edi
80106aa0:	5d                   	pop    %ebp
80106aa1:	c3                   	ret    

80106aa2 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80106aa2:	55                   	push   %ebp
80106aa3:	89 e5                	mov    %esp,%ebp
80106aa5:	57                   	push   %edi
80106aa6:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80106aa7:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106aaa:	8b 55 10             	mov    0x10(%ebp),%edx
80106aad:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ab0:	89 cb                	mov    %ecx,%ebx
80106ab2:	89 df                	mov    %ebx,%edi
80106ab4:	89 d1                	mov    %edx,%ecx
80106ab6:	fc                   	cld    
80106ab7:	f3 ab                	rep stos %eax,%es:(%edi)
80106ab9:	89 ca                	mov    %ecx,%edx
80106abb:	89 fb                	mov    %edi,%ebx
80106abd:	89 5d 08             	mov    %ebx,0x8(%ebp)
80106ac0:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80106ac3:	90                   	nop
80106ac4:	5b                   	pop    %ebx
80106ac5:	5f                   	pop    %edi
80106ac6:	5d                   	pop    %ebp
80106ac7:	c3                   	ret    

80106ac8 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80106ac8:	55                   	push   %ebp
80106ac9:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80106acb:	8b 45 08             	mov    0x8(%ebp),%eax
80106ace:	83 e0 03             	and    $0x3,%eax
80106ad1:	85 c0                	test   %eax,%eax
80106ad3:	75 43                	jne    80106b18 <memset+0x50>
80106ad5:	8b 45 10             	mov    0x10(%ebp),%eax
80106ad8:	83 e0 03             	and    $0x3,%eax
80106adb:	85 c0                	test   %eax,%eax
80106add:	75 39                	jne    80106b18 <memset+0x50>
    c &= 0xFF;
80106adf:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80106ae6:	8b 45 10             	mov    0x10(%ebp),%eax
80106ae9:	c1 e8 02             	shr    $0x2,%eax
80106aec:	89 c1                	mov    %eax,%ecx
80106aee:	8b 45 0c             	mov    0xc(%ebp),%eax
80106af1:	c1 e0 18             	shl    $0x18,%eax
80106af4:	89 c2                	mov    %eax,%edx
80106af6:	8b 45 0c             	mov    0xc(%ebp),%eax
80106af9:	c1 e0 10             	shl    $0x10,%eax
80106afc:	09 c2                	or     %eax,%edx
80106afe:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b01:	c1 e0 08             	shl    $0x8,%eax
80106b04:	09 d0                	or     %edx,%eax
80106b06:	0b 45 0c             	or     0xc(%ebp),%eax
80106b09:	51                   	push   %ecx
80106b0a:	50                   	push   %eax
80106b0b:	ff 75 08             	pushl  0x8(%ebp)
80106b0e:	e8 8f ff ff ff       	call   80106aa2 <stosl>
80106b13:	83 c4 0c             	add    $0xc,%esp
80106b16:	eb 12                	jmp    80106b2a <memset+0x62>
  } else
    stosb(dst, c, n);
80106b18:	8b 45 10             	mov    0x10(%ebp),%eax
80106b1b:	50                   	push   %eax
80106b1c:	ff 75 0c             	pushl  0xc(%ebp)
80106b1f:	ff 75 08             	pushl  0x8(%ebp)
80106b22:	e8 55 ff ff ff       	call   80106a7c <stosb>
80106b27:	83 c4 0c             	add    $0xc,%esp
  return dst;
80106b2a:	8b 45 08             	mov    0x8(%ebp),%eax
}
80106b2d:	c9                   	leave  
80106b2e:	c3                   	ret    

80106b2f <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80106b2f:	55                   	push   %ebp
80106b30:	89 e5                	mov    %esp,%ebp
80106b32:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80106b35:	8b 45 08             	mov    0x8(%ebp),%eax
80106b38:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80106b3b:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b3e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80106b41:	eb 30                	jmp    80106b73 <memcmp+0x44>
    if(*s1 != *s2)
80106b43:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106b46:	0f b6 10             	movzbl (%eax),%edx
80106b49:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106b4c:	0f b6 00             	movzbl (%eax),%eax
80106b4f:	38 c2                	cmp    %al,%dl
80106b51:	74 18                	je     80106b6b <memcmp+0x3c>
      return *s1 - *s2;
80106b53:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106b56:	0f b6 00             	movzbl (%eax),%eax
80106b59:	0f b6 d0             	movzbl %al,%edx
80106b5c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106b5f:	0f b6 00             	movzbl (%eax),%eax
80106b62:	0f b6 c0             	movzbl %al,%eax
80106b65:	29 c2                	sub    %eax,%edx
80106b67:	89 d0                	mov    %edx,%eax
80106b69:	eb 1a                	jmp    80106b85 <memcmp+0x56>
    s1++, s2++;
80106b6b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106b6f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80106b73:	8b 45 10             	mov    0x10(%ebp),%eax
80106b76:	8d 50 ff             	lea    -0x1(%eax),%edx
80106b79:	89 55 10             	mov    %edx,0x10(%ebp)
80106b7c:	85 c0                	test   %eax,%eax
80106b7e:	75 c3                	jne    80106b43 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80106b80:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106b85:	c9                   	leave  
80106b86:	c3                   	ret    

80106b87 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80106b87:	55                   	push   %ebp
80106b88:	89 e5                	mov    %esp,%ebp
80106b8a:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80106b8d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b90:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80106b93:	8b 45 08             	mov    0x8(%ebp),%eax
80106b96:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80106b99:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106b9c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106b9f:	73 54                	jae    80106bf5 <memmove+0x6e>
80106ba1:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106ba4:	8b 45 10             	mov    0x10(%ebp),%eax
80106ba7:	01 d0                	add    %edx,%eax
80106ba9:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106bac:	76 47                	jbe    80106bf5 <memmove+0x6e>
    s += n;
80106bae:	8b 45 10             	mov    0x10(%ebp),%eax
80106bb1:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80106bb4:	8b 45 10             	mov    0x10(%ebp),%eax
80106bb7:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80106bba:	eb 13                	jmp    80106bcf <memmove+0x48>
      *--d = *--s;
80106bbc:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80106bc0:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80106bc4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106bc7:	0f b6 10             	movzbl (%eax),%edx
80106bca:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106bcd:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80106bcf:	8b 45 10             	mov    0x10(%ebp),%eax
80106bd2:	8d 50 ff             	lea    -0x1(%eax),%edx
80106bd5:	89 55 10             	mov    %edx,0x10(%ebp)
80106bd8:	85 c0                	test   %eax,%eax
80106bda:	75 e0                	jne    80106bbc <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80106bdc:	eb 24                	jmp    80106c02 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80106bde:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106be1:	8d 50 01             	lea    0x1(%eax),%edx
80106be4:	89 55 f8             	mov    %edx,-0x8(%ebp)
80106be7:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106bea:	8d 4a 01             	lea    0x1(%edx),%ecx
80106bed:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80106bf0:	0f b6 12             	movzbl (%edx),%edx
80106bf3:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80106bf5:	8b 45 10             	mov    0x10(%ebp),%eax
80106bf8:	8d 50 ff             	lea    -0x1(%eax),%edx
80106bfb:	89 55 10             	mov    %edx,0x10(%ebp)
80106bfe:	85 c0                	test   %eax,%eax
80106c00:	75 dc                	jne    80106bde <memmove+0x57>
      *d++ = *s++;

  return dst;
80106c02:	8b 45 08             	mov    0x8(%ebp),%eax
}
80106c05:	c9                   	leave  
80106c06:	c3                   	ret    

80106c07 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80106c07:	55                   	push   %ebp
80106c08:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80106c0a:	ff 75 10             	pushl  0x10(%ebp)
80106c0d:	ff 75 0c             	pushl  0xc(%ebp)
80106c10:	ff 75 08             	pushl  0x8(%ebp)
80106c13:	e8 6f ff ff ff       	call   80106b87 <memmove>
80106c18:	83 c4 0c             	add    $0xc,%esp
}
80106c1b:	c9                   	leave  
80106c1c:	c3                   	ret    

80106c1d <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80106c1d:	55                   	push   %ebp
80106c1e:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80106c20:	eb 0c                	jmp    80106c2e <strncmp+0x11>
    n--, p++, q++;
80106c22:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106c26:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80106c2a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80106c2e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106c32:	74 1a                	je     80106c4e <strncmp+0x31>
80106c34:	8b 45 08             	mov    0x8(%ebp),%eax
80106c37:	0f b6 00             	movzbl (%eax),%eax
80106c3a:	84 c0                	test   %al,%al
80106c3c:	74 10                	je     80106c4e <strncmp+0x31>
80106c3e:	8b 45 08             	mov    0x8(%ebp),%eax
80106c41:	0f b6 10             	movzbl (%eax),%edx
80106c44:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c47:	0f b6 00             	movzbl (%eax),%eax
80106c4a:	38 c2                	cmp    %al,%dl
80106c4c:	74 d4                	je     80106c22 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80106c4e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106c52:	75 07                	jne    80106c5b <strncmp+0x3e>
    return 0;
80106c54:	b8 00 00 00 00       	mov    $0x0,%eax
80106c59:	eb 16                	jmp    80106c71 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80106c5b:	8b 45 08             	mov    0x8(%ebp),%eax
80106c5e:	0f b6 00             	movzbl (%eax),%eax
80106c61:	0f b6 d0             	movzbl %al,%edx
80106c64:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c67:	0f b6 00             	movzbl (%eax),%eax
80106c6a:	0f b6 c0             	movzbl %al,%eax
80106c6d:	29 c2                	sub    %eax,%edx
80106c6f:	89 d0                	mov    %edx,%eax
}
80106c71:	5d                   	pop    %ebp
80106c72:	c3                   	ret    

80106c73 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80106c73:	55                   	push   %ebp
80106c74:	89 e5                	mov    %esp,%ebp
80106c76:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80106c79:	8b 45 08             	mov    0x8(%ebp),%eax
80106c7c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80106c7f:	90                   	nop
80106c80:	8b 45 10             	mov    0x10(%ebp),%eax
80106c83:	8d 50 ff             	lea    -0x1(%eax),%edx
80106c86:	89 55 10             	mov    %edx,0x10(%ebp)
80106c89:	85 c0                	test   %eax,%eax
80106c8b:	7e 2c                	jle    80106cb9 <strncpy+0x46>
80106c8d:	8b 45 08             	mov    0x8(%ebp),%eax
80106c90:	8d 50 01             	lea    0x1(%eax),%edx
80106c93:	89 55 08             	mov    %edx,0x8(%ebp)
80106c96:	8b 55 0c             	mov    0xc(%ebp),%edx
80106c99:	8d 4a 01             	lea    0x1(%edx),%ecx
80106c9c:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80106c9f:	0f b6 12             	movzbl (%edx),%edx
80106ca2:	88 10                	mov    %dl,(%eax)
80106ca4:	0f b6 00             	movzbl (%eax),%eax
80106ca7:	84 c0                	test   %al,%al
80106ca9:	75 d5                	jne    80106c80 <strncpy+0xd>
    ;
  while(n-- > 0)
80106cab:	eb 0c                	jmp    80106cb9 <strncpy+0x46>
    *s++ = 0;
80106cad:	8b 45 08             	mov    0x8(%ebp),%eax
80106cb0:	8d 50 01             	lea    0x1(%eax),%edx
80106cb3:	89 55 08             	mov    %edx,0x8(%ebp)
80106cb6:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80106cb9:	8b 45 10             	mov    0x10(%ebp),%eax
80106cbc:	8d 50 ff             	lea    -0x1(%eax),%edx
80106cbf:	89 55 10             	mov    %edx,0x10(%ebp)
80106cc2:	85 c0                	test   %eax,%eax
80106cc4:	7f e7                	jg     80106cad <strncpy+0x3a>
    *s++ = 0;
  return os;
80106cc6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106cc9:	c9                   	leave  
80106cca:	c3                   	ret    

80106ccb <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80106ccb:	55                   	push   %ebp
80106ccc:	89 e5                	mov    %esp,%ebp
80106cce:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80106cd1:	8b 45 08             	mov    0x8(%ebp),%eax
80106cd4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80106cd7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106cdb:	7f 05                	jg     80106ce2 <safestrcpy+0x17>
    return os;
80106cdd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106ce0:	eb 31                	jmp    80106d13 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80106ce2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106ce6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106cea:	7e 1e                	jle    80106d0a <safestrcpy+0x3f>
80106cec:	8b 45 08             	mov    0x8(%ebp),%eax
80106cef:	8d 50 01             	lea    0x1(%eax),%edx
80106cf2:	89 55 08             	mov    %edx,0x8(%ebp)
80106cf5:	8b 55 0c             	mov    0xc(%ebp),%edx
80106cf8:	8d 4a 01             	lea    0x1(%edx),%ecx
80106cfb:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80106cfe:	0f b6 12             	movzbl (%edx),%edx
80106d01:	88 10                	mov    %dl,(%eax)
80106d03:	0f b6 00             	movzbl (%eax),%eax
80106d06:	84 c0                	test   %al,%al
80106d08:	75 d8                	jne    80106ce2 <safestrcpy+0x17>
    ;
  *s = 0;
80106d0a:	8b 45 08             	mov    0x8(%ebp),%eax
80106d0d:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80106d10:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106d13:	c9                   	leave  
80106d14:	c3                   	ret    

80106d15 <strlen>:

int
strlen(const char *s)
{
80106d15:	55                   	push   %ebp
80106d16:	89 e5                	mov    %esp,%ebp
80106d18:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80106d1b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106d22:	eb 04                	jmp    80106d28 <strlen+0x13>
80106d24:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106d28:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106d2b:	8b 45 08             	mov    0x8(%ebp),%eax
80106d2e:	01 d0                	add    %edx,%eax
80106d30:	0f b6 00             	movzbl (%eax),%eax
80106d33:	84 c0                	test   %al,%al
80106d35:	75 ed                	jne    80106d24 <strlen+0xf>
    ;
  return n;
80106d37:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106d3a:	c9                   	leave  
80106d3b:	c3                   	ret    

80106d3c <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80106d3c:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80106d40:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80106d44:	55                   	push   %ebp
  pushl %ebx
80106d45:	53                   	push   %ebx
  pushl %esi
80106d46:	56                   	push   %esi
  pushl %edi
80106d47:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80106d48:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80106d4a:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80106d4c:	5f                   	pop    %edi
  popl %esi
80106d4d:	5e                   	pop    %esi
  popl %ebx
80106d4e:	5b                   	pop    %ebx
  popl %ebp
80106d4f:	5d                   	pop    %ebp
  ret
80106d50:	c3                   	ret    

80106d51 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80106d51:	55                   	push   %ebp
80106d52:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80106d54:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d5a:	8b 00                	mov    (%eax),%eax
80106d5c:	3b 45 08             	cmp    0x8(%ebp),%eax
80106d5f:	76 12                	jbe    80106d73 <fetchint+0x22>
80106d61:	8b 45 08             	mov    0x8(%ebp),%eax
80106d64:	8d 50 04             	lea    0x4(%eax),%edx
80106d67:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d6d:	8b 00                	mov    (%eax),%eax
80106d6f:	39 c2                	cmp    %eax,%edx
80106d71:	76 07                	jbe    80106d7a <fetchint+0x29>
    return -1;
80106d73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d78:	eb 0f                	jmp    80106d89 <fetchint+0x38>
  *ip = *(int*)(addr);
80106d7a:	8b 45 08             	mov    0x8(%ebp),%eax
80106d7d:	8b 10                	mov    (%eax),%edx
80106d7f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d82:	89 10                	mov    %edx,(%eax)
  return 0;
80106d84:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106d89:	5d                   	pop    %ebp
80106d8a:	c3                   	ret    

80106d8b <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80106d8b:	55                   	push   %ebp
80106d8c:	89 e5                	mov    %esp,%ebp
80106d8e:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80106d91:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d97:	8b 00                	mov    (%eax),%eax
80106d99:	3b 45 08             	cmp    0x8(%ebp),%eax
80106d9c:	77 07                	ja     80106da5 <fetchstr+0x1a>
    return -1;
80106d9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106da3:	eb 46                	jmp    80106deb <fetchstr+0x60>
  *pp = (char*)addr;
80106da5:	8b 55 08             	mov    0x8(%ebp),%edx
80106da8:	8b 45 0c             	mov    0xc(%ebp),%eax
80106dab:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80106dad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106db3:	8b 00                	mov    (%eax),%eax
80106db5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80106db8:	8b 45 0c             	mov    0xc(%ebp),%eax
80106dbb:	8b 00                	mov    (%eax),%eax
80106dbd:	89 45 fc             	mov    %eax,-0x4(%ebp)
80106dc0:	eb 1c                	jmp    80106dde <fetchstr+0x53>
    if(*s == 0)
80106dc2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106dc5:	0f b6 00             	movzbl (%eax),%eax
80106dc8:	84 c0                	test   %al,%al
80106dca:	75 0e                	jne    80106dda <fetchstr+0x4f>
      return s - *pp;
80106dcc:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106dcf:	8b 45 0c             	mov    0xc(%ebp),%eax
80106dd2:	8b 00                	mov    (%eax),%eax
80106dd4:	29 c2                	sub    %eax,%edx
80106dd6:	89 d0                	mov    %edx,%eax
80106dd8:	eb 11                	jmp    80106deb <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80106dda:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106dde:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106de1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106de4:	72 dc                	jb     80106dc2 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80106de6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106deb:	c9                   	leave  
80106dec:	c3                   	ret    

80106ded <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80106ded:	55                   	push   %ebp
80106dee:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80106df0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106df6:	8b 40 18             	mov    0x18(%eax),%eax
80106df9:	8b 40 44             	mov    0x44(%eax),%eax
80106dfc:	8b 55 08             	mov    0x8(%ebp),%edx
80106dff:	c1 e2 02             	shl    $0x2,%edx
80106e02:	01 d0                	add    %edx,%eax
80106e04:	83 c0 04             	add    $0x4,%eax
80106e07:	ff 75 0c             	pushl  0xc(%ebp)
80106e0a:	50                   	push   %eax
80106e0b:	e8 41 ff ff ff       	call   80106d51 <fetchint>
80106e10:	83 c4 08             	add    $0x8,%esp
}
80106e13:	c9                   	leave  
80106e14:	c3                   	ret    

80106e15 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80106e15:	55                   	push   %ebp
80106e16:	89 e5                	mov    %esp,%ebp
80106e18:	83 ec 10             	sub    $0x10,%esp
  int i;

  if(argint(n, &i) < 0)
80106e1b:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106e1e:	50                   	push   %eax
80106e1f:	ff 75 08             	pushl  0x8(%ebp)
80106e22:	e8 c6 ff ff ff       	call   80106ded <argint>
80106e27:	83 c4 08             	add    $0x8,%esp
80106e2a:	85 c0                	test   %eax,%eax
80106e2c:	79 07                	jns    80106e35 <argptr+0x20>
    return -1;
80106e2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e33:	eb 3b                	jmp    80106e70 <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80106e35:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e3b:	8b 00                	mov    (%eax),%eax
80106e3d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106e40:	39 d0                	cmp    %edx,%eax
80106e42:	76 16                	jbe    80106e5a <argptr+0x45>
80106e44:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106e47:	89 c2                	mov    %eax,%edx
80106e49:	8b 45 10             	mov    0x10(%ebp),%eax
80106e4c:	01 c2                	add    %eax,%edx
80106e4e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e54:	8b 00                	mov    (%eax),%eax
80106e56:	39 c2                	cmp    %eax,%edx
80106e58:	76 07                	jbe    80106e61 <argptr+0x4c>
    return -1;
80106e5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e5f:	eb 0f                	jmp    80106e70 <argptr+0x5b>
  *pp = (char*)i;
80106e61:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106e64:	89 c2                	mov    %eax,%edx
80106e66:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e69:	89 10                	mov    %edx,(%eax)
  return 0;
80106e6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106e70:	c9                   	leave  
80106e71:	c3                   	ret    

80106e72 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80106e72:	55                   	push   %ebp
80106e73:	89 e5                	mov    %esp,%ebp
80106e75:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80106e78:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106e7b:	50                   	push   %eax
80106e7c:	ff 75 08             	pushl  0x8(%ebp)
80106e7f:	e8 69 ff ff ff       	call   80106ded <argint>
80106e84:	83 c4 08             	add    $0x8,%esp
80106e87:	85 c0                	test   %eax,%eax
80106e89:	79 07                	jns    80106e92 <argstr+0x20>
    return -1;
80106e8b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e90:	eb 0f                	jmp    80106ea1 <argstr+0x2f>
  return fetchstr(addr, pp);
80106e92:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106e95:	ff 75 0c             	pushl  0xc(%ebp)
80106e98:	50                   	push   %eax
80106e99:	e8 ed fe ff ff       	call   80106d8b <fetchstr>
80106e9e:	83 c4 08             	add    $0x8,%esp
}
80106ea1:	c9                   	leave  
80106ea2:	c3                   	ret    

80106ea3 <syscall>:
};
#endif

void
syscall(void)
{
80106ea3:	55                   	push   %ebp
80106ea4:	89 e5                	mov    %esp,%ebp
80106ea6:	53                   	push   %ebx
80106ea7:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
80106eaa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106eb0:	8b 40 18             	mov    0x18(%eax),%eax
80106eb3:	8b 40 1c             	mov    0x1c(%eax),%eax
80106eb6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80106eb9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106ebd:	7e 30                	jle    80106eef <syscall+0x4c>
80106ebf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ec2:	83 f8 1c             	cmp    $0x1c,%eax
80106ec5:	77 28                	ja     80106eef <syscall+0x4c>
80106ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106eca:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
80106ed1:	85 c0                	test   %eax,%eax
80106ed3:	74 1a                	je     80106eef <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80106ed5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106edb:	8b 58 18             	mov    0x18(%eax),%ebx
80106ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ee1:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
80106ee8:	ff d0                	call   *%eax
80106eea:	89 43 1c             	mov    %eax,0x1c(%ebx)
80106eed:	eb 34                	jmp    80106f23 <syscall+0x80>
#ifdef PRINT_SYSCALLS
    cprintf("%s -> %d\n",syscallnames[num],proc->tf->eax);
#endif
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80106eef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ef5:	8d 50 6c             	lea    0x6c(%eax),%edx
80106ef8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
// some code goes here
#ifdef PRINT_SYSCALLS
    cprintf("%s -> %d\n",syscallnames[num],proc->tf->eax);
#endif
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80106efe:	8b 40 10             	mov    0x10(%eax),%eax
80106f01:	ff 75 f4             	pushl  -0xc(%ebp)
80106f04:	52                   	push   %edx
80106f05:	50                   	push   %eax
80106f06:	68 53 a7 10 80       	push   $0x8010a753
80106f0b:	e8 b6 94 ff ff       	call   801003c6 <cprintf>
80106f10:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80106f13:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f19:	8b 40 18             	mov    0x18(%eax),%eax
80106f1c:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80106f23:	90                   	nop
80106f24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106f27:	c9                   	leave  
80106f28:	c3                   	ret    

80106f29 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80106f29:	55                   	push   %ebp
80106f2a:	89 e5                	mov    %esp,%ebp
80106f2c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80106f2f:	83 ec 08             	sub    $0x8,%esp
80106f32:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106f35:	50                   	push   %eax
80106f36:	ff 75 08             	pushl  0x8(%ebp)
80106f39:	e8 af fe ff ff       	call   80106ded <argint>
80106f3e:	83 c4 10             	add    $0x10,%esp
80106f41:	85 c0                	test   %eax,%eax
80106f43:	79 07                	jns    80106f4c <argfd+0x23>
    return -1;
80106f45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f4a:	eb 50                	jmp    80106f9c <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80106f4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f4f:	85 c0                	test   %eax,%eax
80106f51:	78 21                	js     80106f74 <argfd+0x4b>
80106f53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f56:	83 f8 0f             	cmp    $0xf,%eax
80106f59:	7f 19                	jg     80106f74 <argfd+0x4b>
80106f5b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f61:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106f64:	83 c2 08             	add    $0x8,%edx
80106f67:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106f6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106f6e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106f72:	75 07                	jne    80106f7b <argfd+0x52>
    return -1;
80106f74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f79:	eb 21                	jmp    80106f9c <argfd+0x73>
  if(pfd)
80106f7b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106f7f:	74 08                	je     80106f89 <argfd+0x60>
    *pfd = fd;
80106f81:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106f84:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f87:	89 10                	mov    %edx,(%eax)
  if(pf)
80106f89:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106f8d:	74 08                	je     80106f97 <argfd+0x6e>
    *pf = f;
80106f8f:	8b 45 10             	mov    0x10(%ebp),%eax
80106f92:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106f95:	89 10                	mov    %edx,(%eax)
  return 0;
80106f97:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106f9c:	c9                   	leave  
80106f9d:	c3                   	ret    

80106f9e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80106f9e:	55                   	push   %ebp
80106f9f:	89 e5                	mov    %esp,%ebp
80106fa1:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80106fa4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106fab:	eb 30                	jmp    80106fdd <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80106fad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fb3:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106fb6:	83 c2 08             	add    $0x8,%edx
80106fb9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106fbd:	85 c0                	test   %eax,%eax
80106fbf:	75 18                	jne    80106fd9 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80106fc1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fc7:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106fca:	8d 4a 08             	lea    0x8(%edx),%ecx
80106fcd:	8b 55 08             	mov    0x8(%ebp),%edx
80106fd0:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80106fd4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106fd7:	eb 0f                	jmp    80106fe8 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80106fd9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106fdd:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80106fe1:	7e ca                	jle    80106fad <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80106fe3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106fe8:	c9                   	leave  
80106fe9:	c3                   	ret    

80106fea <sys_dup>:

int
sys_dup(void)
{
80106fea:	55                   	push   %ebp
80106feb:	89 e5                	mov    %esp,%ebp
80106fed:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80106ff0:	83 ec 04             	sub    $0x4,%esp
80106ff3:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106ff6:	50                   	push   %eax
80106ff7:	6a 00                	push   $0x0
80106ff9:	6a 00                	push   $0x0
80106ffb:	e8 29 ff ff ff       	call   80106f29 <argfd>
80107000:	83 c4 10             	add    $0x10,%esp
80107003:	85 c0                	test   %eax,%eax
80107005:	79 07                	jns    8010700e <sys_dup+0x24>
    return -1;
80107007:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010700c:	eb 31                	jmp    8010703f <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010700e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107011:	83 ec 0c             	sub    $0xc,%esp
80107014:	50                   	push   %eax
80107015:	e8 84 ff ff ff       	call   80106f9e <fdalloc>
8010701a:	83 c4 10             	add    $0x10,%esp
8010701d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107020:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107024:	79 07                	jns    8010702d <sys_dup+0x43>
    return -1;
80107026:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010702b:	eb 12                	jmp    8010703f <sys_dup+0x55>
  filedup(f);
8010702d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107030:	83 ec 0c             	sub    $0xc,%esp
80107033:	50                   	push   %eax
80107034:	e8 65 a0 ff ff       	call   8010109e <filedup>
80107039:	83 c4 10             	add    $0x10,%esp
  return fd;
8010703c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010703f:	c9                   	leave  
80107040:	c3                   	ret    

80107041 <sys_read>:

int
sys_read(void)
{
80107041:	55                   	push   %ebp
80107042:	89 e5                	mov    %esp,%ebp
80107044:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80107047:	83 ec 04             	sub    $0x4,%esp
8010704a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010704d:	50                   	push   %eax
8010704e:	6a 00                	push   $0x0
80107050:	6a 00                	push   $0x0
80107052:	e8 d2 fe ff ff       	call   80106f29 <argfd>
80107057:	83 c4 10             	add    $0x10,%esp
8010705a:	85 c0                	test   %eax,%eax
8010705c:	78 2e                	js     8010708c <sys_read+0x4b>
8010705e:	83 ec 08             	sub    $0x8,%esp
80107061:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107064:	50                   	push   %eax
80107065:	6a 02                	push   $0x2
80107067:	e8 81 fd ff ff       	call   80106ded <argint>
8010706c:	83 c4 10             	add    $0x10,%esp
8010706f:	85 c0                	test   %eax,%eax
80107071:	78 19                	js     8010708c <sys_read+0x4b>
80107073:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107076:	83 ec 04             	sub    $0x4,%esp
80107079:	50                   	push   %eax
8010707a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010707d:	50                   	push   %eax
8010707e:	6a 01                	push   $0x1
80107080:	e8 90 fd ff ff       	call   80106e15 <argptr>
80107085:	83 c4 10             	add    $0x10,%esp
80107088:	85 c0                	test   %eax,%eax
8010708a:	79 07                	jns    80107093 <sys_read+0x52>
    return -1;
8010708c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107091:	eb 17                	jmp    801070aa <sys_read+0x69>
  return fileread(f, p, n);
80107093:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80107096:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107099:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010709c:	83 ec 04             	sub    $0x4,%esp
8010709f:	51                   	push   %ecx
801070a0:	52                   	push   %edx
801070a1:	50                   	push   %eax
801070a2:	e8 87 a1 ff ff       	call   8010122e <fileread>
801070a7:	83 c4 10             	add    $0x10,%esp
}
801070aa:	c9                   	leave  
801070ab:	c3                   	ret    

801070ac <sys_write>:

int
sys_write(void)
{
801070ac:	55                   	push   %ebp
801070ad:	89 e5                	mov    %esp,%ebp
801070af:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801070b2:	83 ec 04             	sub    $0x4,%esp
801070b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801070b8:	50                   	push   %eax
801070b9:	6a 00                	push   $0x0
801070bb:	6a 00                	push   $0x0
801070bd:	e8 67 fe ff ff       	call   80106f29 <argfd>
801070c2:	83 c4 10             	add    $0x10,%esp
801070c5:	85 c0                	test   %eax,%eax
801070c7:	78 2e                	js     801070f7 <sys_write+0x4b>
801070c9:	83 ec 08             	sub    $0x8,%esp
801070cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801070cf:	50                   	push   %eax
801070d0:	6a 02                	push   $0x2
801070d2:	e8 16 fd ff ff       	call   80106ded <argint>
801070d7:	83 c4 10             	add    $0x10,%esp
801070da:	85 c0                	test   %eax,%eax
801070dc:	78 19                	js     801070f7 <sys_write+0x4b>
801070de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070e1:	83 ec 04             	sub    $0x4,%esp
801070e4:	50                   	push   %eax
801070e5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801070e8:	50                   	push   %eax
801070e9:	6a 01                	push   $0x1
801070eb:	e8 25 fd ff ff       	call   80106e15 <argptr>
801070f0:	83 c4 10             	add    $0x10,%esp
801070f3:	85 c0                	test   %eax,%eax
801070f5:	79 07                	jns    801070fe <sys_write+0x52>
    return -1;
801070f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070fc:	eb 17                	jmp    80107115 <sys_write+0x69>
  return filewrite(f, p, n);
801070fe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80107101:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107104:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107107:	83 ec 04             	sub    $0x4,%esp
8010710a:	51                   	push   %ecx
8010710b:	52                   	push   %edx
8010710c:	50                   	push   %eax
8010710d:	e8 d4 a1 ff ff       	call   801012e6 <filewrite>
80107112:	83 c4 10             	add    $0x10,%esp
}
80107115:	c9                   	leave  
80107116:	c3                   	ret    

80107117 <sys_close>:

int
sys_close(void)
{
80107117:	55                   	push   %ebp
80107118:	89 e5                	mov    %esp,%ebp
8010711a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
8010711d:	83 ec 04             	sub    $0x4,%esp
80107120:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107123:	50                   	push   %eax
80107124:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107127:	50                   	push   %eax
80107128:	6a 00                	push   $0x0
8010712a:	e8 fa fd ff ff       	call   80106f29 <argfd>
8010712f:	83 c4 10             	add    $0x10,%esp
80107132:	85 c0                	test   %eax,%eax
80107134:	79 07                	jns    8010713d <sys_close+0x26>
    return -1;
80107136:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010713b:	eb 28                	jmp    80107165 <sys_close+0x4e>
  proc->ofile[fd] = 0;
8010713d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107143:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107146:	83 c2 08             	add    $0x8,%edx
80107149:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80107150:	00 
  fileclose(f);
80107151:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107154:	83 ec 0c             	sub    $0xc,%esp
80107157:	50                   	push   %eax
80107158:	e8 92 9f ff ff       	call   801010ef <fileclose>
8010715d:	83 c4 10             	add    $0x10,%esp
  return 0;
80107160:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107165:	c9                   	leave  
80107166:	c3                   	ret    

80107167 <sys_fstat>:

int
sys_fstat(void)
{
80107167:	55                   	push   %ebp
80107168:	89 e5                	mov    %esp,%ebp
8010716a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010716d:	83 ec 04             	sub    $0x4,%esp
80107170:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107173:	50                   	push   %eax
80107174:	6a 00                	push   $0x0
80107176:	6a 00                	push   $0x0
80107178:	e8 ac fd ff ff       	call   80106f29 <argfd>
8010717d:	83 c4 10             	add    $0x10,%esp
80107180:	85 c0                	test   %eax,%eax
80107182:	78 17                	js     8010719b <sys_fstat+0x34>
80107184:	83 ec 04             	sub    $0x4,%esp
80107187:	6a 14                	push   $0x14
80107189:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010718c:	50                   	push   %eax
8010718d:	6a 01                	push   $0x1
8010718f:	e8 81 fc ff ff       	call   80106e15 <argptr>
80107194:	83 c4 10             	add    $0x10,%esp
80107197:	85 c0                	test   %eax,%eax
80107199:	79 07                	jns    801071a2 <sys_fstat+0x3b>
    return -1;
8010719b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071a0:	eb 13                	jmp    801071b5 <sys_fstat+0x4e>
  return filestat(f, st);
801071a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801071a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071a8:	83 ec 08             	sub    $0x8,%esp
801071ab:	52                   	push   %edx
801071ac:	50                   	push   %eax
801071ad:	e8 25 a0 ff ff       	call   801011d7 <filestat>
801071b2:	83 c4 10             	add    $0x10,%esp
}
801071b5:	c9                   	leave  
801071b6:	c3                   	ret    

801071b7 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801071b7:	55                   	push   %ebp
801071b8:	89 e5                	mov    %esp,%ebp
801071ba:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801071bd:	83 ec 08             	sub    $0x8,%esp
801071c0:	8d 45 d8             	lea    -0x28(%ebp),%eax
801071c3:	50                   	push   %eax
801071c4:	6a 00                	push   $0x0
801071c6:	e8 a7 fc ff ff       	call   80106e72 <argstr>
801071cb:	83 c4 10             	add    $0x10,%esp
801071ce:	85 c0                	test   %eax,%eax
801071d0:	78 15                	js     801071e7 <sys_link+0x30>
801071d2:	83 ec 08             	sub    $0x8,%esp
801071d5:	8d 45 dc             	lea    -0x24(%ebp),%eax
801071d8:	50                   	push   %eax
801071d9:	6a 01                	push   $0x1
801071db:	e8 92 fc ff ff       	call   80106e72 <argstr>
801071e0:	83 c4 10             	add    $0x10,%esp
801071e3:	85 c0                	test   %eax,%eax
801071e5:	79 0a                	jns    801071f1 <sys_link+0x3a>
    return -1;
801071e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071ec:	e9 68 01 00 00       	jmp    80107359 <sys_link+0x1a2>

  begin_op();
801071f1:	e8 f5 c3 ff ff       	call   801035eb <begin_op>
  if((ip = namei(old)) == 0){
801071f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
801071f9:	83 ec 0c             	sub    $0xc,%esp
801071fc:	50                   	push   %eax
801071fd:	e8 c4 b3 ff ff       	call   801025c6 <namei>
80107202:	83 c4 10             	add    $0x10,%esp
80107205:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107208:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010720c:	75 0f                	jne    8010721d <sys_link+0x66>
    end_op();
8010720e:	e8 64 c4 ff ff       	call   80103677 <end_op>
    return -1;
80107213:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107218:	e9 3c 01 00 00       	jmp    80107359 <sys_link+0x1a2>
  }

  ilock(ip);
8010721d:	83 ec 0c             	sub    $0xc,%esp
80107220:	ff 75 f4             	pushl  -0xc(%ebp)
80107223:	e8 e0 a7 ff ff       	call   80101a08 <ilock>
80107228:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010722b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010722e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107232:	66 83 f8 01          	cmp    $0x1,%ax
80107236:	75 1d                	jne    80107255 <sys_link+0x9e>
    iunlockput(ip);
80107238:	83 ec 0c             	sub    $0xc,%esp
8010723b:	ff 75 f4             	pushl  -0xc(%ebp)
8010723e:	e8 85 aa ff ff       	call   80101cc8 <iunlockput>
80107243:	83 c4 10             	add    $0x10,%esp
    end_op();
80107246:	e8 2c c4 ff ff       	call   80103677 <end_op>
    return -1;
8010724b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107250:	e9 04 01 00 00       	jmp    80107359 <sys_link+0x1a2>
  }

  ip->nlink++;
80107255:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107258:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010725c:	83 c0 01             	add    $0x1,%eax
8010725f:	89 c2                	mov    %eax,%edx
80107261:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107264:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80107268:	83 ec 0c             	sub    $0xc,%esp
8010726b:	ff 75 f4             	pushl  -0xc(%ebp)
8010726e:	e8 bb a5 ff ff       	call   8010182e <iupdate>
80107273:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80107276:	83 ec 0c             	sub    $0xc,%esp
80107279:	ff 75 f4             	pushl  -0xc(%ebp)
8010727c:	e8 e5 a8 ff ff       	call   80101b66 <iunlock>
80107281:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80107284:	8b 45 dc             	mov    -0x24(%ebp),%eax
80107287:	83 ec 08             	sub    $0x8,%esp
8010728a:	8d 55 e2             	lea    -0x1e(%ebp),%edx
8010728d:	52                   	push   %edx
8010728e:	50                   	push   %eax
8010728f:	e8 4e b3 ff ff       	call   801025e2 <nameiparent>
80107294:	83 c4 10             	add    $0x10,%esp
80107297:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010729a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010729e:	74 71                	je     80107311 <sys_link+0x15a>
    goto bad;
  ilock(dp);
801072a0:	83 ec 0c             	sub    $0xc,%esp
801072a3:	ff 75 f0             	pushl  -0x10(%ebp)
801072a6:	e8 5d a7 ff ff       	call   80101a08 <ilock>
801072ab:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801072ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801072b1:	8b 10                	mov    (%eax),%edx
801072b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072b6:	8b 00                	mov    (%eax),%eax
801072b8:	39 c2                	cmp    %eax,%edx
801072ba:	75 1d                	jne    801072d9 <sys_link+0x122>
801072bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072bf:	8b 40 04             	mov    0x4(%eax),%eax
801072c2:	83 ec 04             	sub    $0x4,%esp
801072c5:	50                   	push   %eax
801072c6:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801072c9:	50                   	push   %eax
801072ca:	ff 75 f0             	pushl  -0x10(%ebp)
801072cd:	e8 58 b0 ff ff       	call   8010232a <dirlink>
801072d2:	83 c4 10             	add    $0x10,%esp
801072d5:	85 c0                	test   %eax,%eax
801072d7:	79 10                	jns    801072e9 <sys_link+0x132>
    iunlockput(dp);
801072d9:	83 ec 0c             	sub    $0xc,%esp
801072dc:	ff 75 f0             	pushl  -0x10(%ebp)
801072df:	e8 e4 a9 ff ff       	call   80101cc8 <iunlockput>
801072e4:	83 c4 10             	add    $0x10,%esp
    goto bad;
801072e7:	eb 29                	jmp    80107312 <sys_link+0x15b>
  }
  iunlockput(dp);
801072e9:	83 ec 0c             	sub    $0xc,%esp
801072ec:	ff 75 f0             	pushl  -0x10(%ebp)
801072ef:	e8 d4 a9 ff ff       	call   80101cc8 <iunlockput>
801072f4:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801072f7:	83 ec 0c             	sub    $0xc,%esp
801072fa:	ff 75 f4             	pushl  -0xc(%ebp)
801072fd:	e8 d6 a8 ff ff       	call   80101bd8 <iput>
80107302:	83 c4 10             	add    $0x10,%esp

  end_op();
80107305:	e8 6d c3 ff ff       	call   80103677 <end_op>

  return 0;
8010730a:	b8 00 00 00 00       	mov    $0x0,%eax
8010730f:	eb 48                	jmp    80107359 <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80107311:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80107312:	83 ec 0c             	sub    $0xc,%esp
80107315:	ff 75 f4             	pushl  -0xc(%ebp)
80107318:	e8 eb a6 ff ff       	call   80101a08 <ilock>
8010731d:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80107320:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107323:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80107327:	83 e8 01             	sub    $0x1,%eax
8010732a:	89 c2                	mov    %eax,%edx
8010732c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010732f:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80107333:	83 ec 0c             	sub    $0xc,%esp
80107336:	ff 75 f4             	pushl  -0xc(%ebp)
80107339:	e8 f0 a4 ff ff       	call   8010182e <iupdate>
8010733e:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80107341:	83 ec 0c             	sub    $0xc,%esp
80107344:	ff 75 f4             	pushl  -0xc(%ebp)
80107347:	e8 7c a9 ff ff       	call   80101cc8 <iunlockput>
8010734c:	83 c4 10             	add    $0x10,%esp
  end_op();
8010734f:	e8 23 c3 ff ff       	call   80103677 <end_op>
  return -1;
80107354:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107359:	c9                   	leave  
8010735a:	c3                   	ret    

8010735b <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010735b:	55                   	push   %ebp
8010735c:	89 e5                	mov    %esp,%ebp
8010735e:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80107361:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80107368:	eb 40                	jmp    801073aa <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010736a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010736d:	6a 10                	push   $0x10
8010736f:	50                   	push   %eax
80107370:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107373:	50                   	push   %eax
80107374:	ff 75 08             	pushl  0x8(%ebp)
80107377:	e8 fa ab ff ff       	call   80101f76 <readi>
8010737c:	83 c4 10             	add    $0x10,%esp
8010737f:	83 f8 10             	cmp    $0x10,%eax
80107382:	74 0d                	je     80107391 <isdirempty+0x36>
      panic("isdirempty: readi");
80107384:	83 ec 0c             	sub    $0xc,%esp
80107387:	68 6f a7 10 80       	push   $0x8010a76f
8010738c:	e8 d5 91 ff ff       	call   80100566 <panic>
    if(de.inum != 0)
80107391:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80107395:	66 85 c0             	test   %ax,%ax
80107398:	74 07                	je     801073a1 <isdirempty+0x46>
      return 0;
8010739a:	b8 00 00 00 00       	mov    $0x0,%eax
8010739f:	eb 1b                	jmp    801073bc <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801073a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073a4:	83 c0 10             	add    $0x10,%eax
801073a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801073aa:	8b 45 08             	mov    0x8(%ebp),%eax
801073ad:	8b 50 18             	mov    0x18(%eax),%edx
801073b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073b3:	39 c2                	cmp    %eax,%edx
801073b5:	77 b3                	ja     8010736a <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
801073b7:	b8 01 00 00 00       	mov    $0x1,%eax
}
801073bc:	c9                   	leave  
801073bd:	c3                   	ret    

801073be <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801073be:	55                   	push   %ebp
801073bf:	89 e5                	mov    %esp,%ebp
801073c1:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801073c4:	83 ec 08             	sub    $0x8,%esp
801073c7:	8d 45 cc             	lea    -0x34(%ebp),%eax
801073ca:	50                   	push   %eax
801073cb:	6a 00                	push   $0x0
801073cd:	e8 a0 fa ff ff       	call   80106e72 <argstr>
801073d2:	83 c4 10             	add    $0x10,%esp
801073d5:	85 c0                	test   %eax,%eax
801073d7:	79 0a                	jns    801073e3 <sys_unlink+0x25>
    return -1;
801073d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073de:	e9 bc 01 00 00       	jmp    8010759f <sys_unlink+0x1e1>

  begin_op();
801073e3:	e8 03 c2 ff ff       	call   801035eb <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801073e8:	8b 45 cc             	mov    -0x34(%ebp),%eax
801073eb:	83 ec 08             	sub    $0x8,%esp
801073ee:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801073f1:	52                   	push   %edx
801073f2:	50                   	push   %eax
801073f3:	e8 ea b1 ff ff       	call   801025e2 <nameiparent>
801073f8:	83 c4 10             	add    $0x10,%esp
801073fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801073fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107402:	75 0f                	jne    80107413 <sys_unlink+0x55>
    end_op();
80107404:	e8 6e c2 ff ff       	call   80103677 <end_op>
    return -1;
80107409:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010740e:	e9 8c 01 00 00       	jmp    8010759f <sys_unlink+0x1e1>
  }

  ilock(dp);
80107413:	83 ec 0c             	sub    $0xc,%esp
80107416:	ff 75 f4             	pushl  -0xc(%ebp)
80107419:	e8 ea a5 ff ff       	call   80101a08 <ilock>
8010741e:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80107421:	83 ec 08             	sub    $0x8,%esp
80107424:	68 81 a7 10 80       	push   $0x8010a781
80107429:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010742c:	50                   	push   %eax
8010742d:	e8 23 ae ff ff       	call   80102255 <namecmp>
80107432:	83 c4 10             	add    $0x10,%esp
80107435:	85 c0                	test   %eax,%eax
80107437:	0f 84 4a 01 00 00    	je     80107587 <sys_unlink+0x1c9>
8010743d:	83 ec 08             	sub    $0x8,%esp
80107440:	68 83 a7 10 80       	push   $0x8010a783
80107445:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80107448:	50                   	push   %eax
80107449:	e8 07 ae ff ff       	call   80102255 <namecmp>
8010744e:	83 c4 10             	add    $0x10,%esp
80107451:	85 c0                	test   %eax,%eax
80107453:	0f 84 2e 01 00 00    	je     80107587 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80107459:	83 ec 04             	sub    $0x4,%esp
8010745c:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010745f:	50                   	push   %eax
80107460:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80107463:	50                   	push   %eax
80107464:	ff 75 f4             	pushl  -0xc(%ebp)
80107467:	e8 04 ae ff ff       	call   80102270 <dirlookup>
8010746c:	83 c4 10             	add    $0x10,%esp
8010746f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107472:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107476:	0f 84 0a 01 00 00    	je     80107586 <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
8010747c:	83 ec 0c             	sub    $0xc,%esp
8010747f:	ff 75 f0             	pushl  -0x10(%ebp)
80107482:	e8 81 a5 ff ff       	call   80101a08 <ilock>
80107487:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
8010748a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010748d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80107491:	66 85 c0             	test   %ax,%ax
80107494:	7f 0d                	jg     801074a3 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80107496:	83 ec 0c             	sub    $0xc,%esp
80107499:	68 86 a7 10 80       	push   $0x8010a786
8010749e:	e8 c3 90 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801074a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801074a6:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801074aa:	66 83 f8 01          	cmp    $0x1,%ax
801074ae:	75 25                	jne    801074d5 <sys_unlink+0x117>
801074b0:	83 ec 0c             	sub    $0xc,%esp
801074b3:	ff 75 f0             	pushl  -0x10(%ebp)
801074b6:	e8 a0 fe ff ff       	call   8010735b <isdirempty>
801074bb:	83 c4 10             	add    $0x10,%esp
801074be:	85 c0                	test   %eax,%eax
801074c0:	75 13                	jne    801074d5 <sys_unlink+0x117>
    iunlockput(ip);
801074c2:	83 ec 0c             	sub    $0xc,%esp
801074c5:	ff 75 f0             	pushl  -0x10(%ebp)
801074c8:	e8 fb a7 ff ff       	call   80101cc8 <iunlockput>
801074cd:	83 c4 10             	add    $0x10,%esp
    goto bad;
801074d0:	e9 b2 00 00 00       	jmp    80107587 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
801074d5:	83 ec 04             	sub    $0x4,%esp
801074d8:	6a 10                	push   $0x10
801074da:	6a 00                	push   $0x0
801074dc:	8d 45 e0             	lea    -0x20(%ebp),%eax
801074df:	50                   	push   %eax
801074e0:	e8 e3 f5 ff ff       	call   80106ac8 <memset>
801074e5:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801074e8:	8b 45 c8             	mov    -0x38(%ebp),%eax
801074eb:	6a 10                	push   $0x10
801074ed:	50                   	push   %eax
801074ee:	8d 45 e0             	lea    -0x20(%ebp),%eax
801074f1:	50                   	push   %eax
801074f2:	ff 75 f4             	pushl  -0xc(%ebp)
801074f5:	e8 d3 ab ff ff       	call   801020cd <writei>
801074fa:	83 c4 10             	add    $0x10,%esp
801074fd:	83 f8 10             	cmp    $0x10,%eax
80107500:	74 0d                	je     8010750f <sys_unlink+0x151>
    panic("unlink: writei");
80107502:	83 ec 0c             	sub    $0xc,%esp
80107505:	68 98 a7 10 80       	push   $0x8010a798
8010750a:	e8 57 90 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
8010750f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107512:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107516:	66 83 f8 01          	cmp    $0x1,%ax
8010751a:	75 21                	jne    8010753d <sys_unlink+0x17f>
    dp->nlink--;
8010751c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010751f:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80107523:	83 e8 01             	sub    $0x1,%eax
80107526:	89 c2                	mov    %eax,%edx
80107528:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010752b:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
8010752f:	83 ec 0c             	sub    $0xc,%esp
80107532:	ff 75 f4             	pushl  -0xc(%ebp)
80107535:	e8 f4 a2 ff ff       	call   8010182e <iupdate>
8010753a:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
8010753d:	83 ec 0c             	sub    $0xc,%esp
80107540:	ff 75 f4             	pushl  -0xc(%ebp)
80107543:	e8 80 a7 ff ff       	call   80101cc8 <iunlockput>
80107548:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
8010754b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010754e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80107552:	83 e8 01             	sub    $0x1,%eax
80107555:	89 c2                	mov    %eax,%edx
80107557:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010755a:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010755e:	83 ec 0c             	sub    $0xc,%esp
80107561:	ff 75 f0             	pushl  -0x10(%ebp)
80107564:	e8 c5 a2 ff ff       	call   8010182e <iupdate>
80107569:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010756c:	83 ec 0c             	sub    $0xc,%esp
8010756f:	ff 75 f0             	pushl  -0x10(%ebp)
80107572:	e8 51 a7 ff ff       	call   80101cc8 <iunlockput>
80107577:	83 c4 10             	add    $0x10,%esp

  end_op();
8010757a:	e8 f8 c0 ff ff       	call   80103677 <end_op>

  return 0;
8010757f:	b8 00 00 00 00       	mov    $0x0,%eax
80107584:	eb 19                	jmp    8010759f <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80107586:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80107587:	83 ec 0c             	sub    $0xc,%esp
8010758a:	ff 75 f4             	pushl  -0xc(%ebp)
8010758d:	e8 36 a7 ff ff       	call   80101cc8 <iunlockput>
80107592:	83 c4 10             	add    $0x10,%esp
  end_op();
80107595:	e8 dd c0 ff ff       	call   80103677 <end_op>
  return -1;
8010759a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010759f:	c9                   	leave  
801075a0:	c3                   	ret    

801075a1 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801075a1:	55                   	push   %ebp
801075a2:	89 e5                	mov    %esp,%ebp
801075a4:	83 ec 38             	sub    $0x38,%esp
801075a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801075aa:	8b 55 10             	mov    0x10(%ebp),%edx
801075ad:	8b 45 14             	mov    0x14(%ebp),%eax
801075b0:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801075b4:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801075b8:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801075bc:	83 ec 08             	sub    $0x8,%esp
801075bf:	8d 45 de             	lea    -0x22(%ebp),%eax
801075c2:	50                   	push   %eax
801075c3:	ff 75 08             	pushl  0x8(%ebp)
801075c6:	e8 17 b0 ff ff       	call   801025e2 <nameiparent>
801075cb:	83 c4 10             	add    $0x10,%esp
801075ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801075d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801075d5:	75 0a                	jne    801075e1 <create+0x40>
    return 0;
801075d7:	b8 00 00 00 00       	mov    $0x0,%eax
801075dc:	e9 90 01 00 00       	jmp    80107771 <create+0x1d0>
  ilock(dp);
801075e1:	83 ec 0c             	sub    $0xc,%esp
801075e4:	ff 75 f4             	pushl  -0xc(%ebp)
801075e7:	e8 1c a4 ff ff       	call   80101a08 <ilock>
801075ec:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801075ef:	83 ec 04             	sub    $0x4,%esp
801075f2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801075f5:	50                   	push   %eax
801075f6:	8d 45 de             	lea    -0x22(%ebp),%eax
801075f9:	50                   	push   %eax
801075fa:	ff 75 f4             	pushl  -0xc(%ebp)
801075fd:	e8 6e ac ff ff       	call   80102270 <dirlookup>
80107602:	83 c4 10             	add    $0x10,%esp
80107605:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107608:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010760c:	74 50                	je     8010765e <create+0xbd>
    iunlockput(dp);
8010760e:	83 ec 0c             	sub    $0xc,%esp
80107611:	ff 75 f4             	pushl  -0xc(%ebp)
80107614:	e8 af a6 ff ff       	call   80101cc8 <iunlockput>
80107619:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
8010761c:	83 ec 0c             	sub    $0xc,%esp
8010761f:	ff 75 f0             	pushl  -0x10(%ebp)
80107622:	e8 e1 a3 ff ff       	call   80101a08 <ilock>
80107627:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010762a:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
8010762f:	75 15                	jne    80107646 <create+0xa5>
80107631:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107634:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107638:	66 83 f8 02          	cmp    $0x2,%ax
8010763c:	75 08                	jne    80107646 <create+0xa5>
      return ip;
8010763e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107641:	e9 2b 01 00 00       	jmp    80107771 <create+0x1d0>
    iunlockput(ip);
80107646:	83 ec 0c             	sub    $0xc,%esp
80107649:	ff 75 f0             	pushl  -0x10(%ebp)
8010764c:	e8 77 a6 ff ff       	call   80101cc8 <iunlockput>
80107651:	83 c4 10             	add    $0x10,%esp
    return 0;
80107654:	b8 00 00 00 00       	mov    $0x0,%eax
80107659:	e9 13 01 00 00       	jmp    80107771 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010765e:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80107662:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107665:	8b 00                	mov    (%eax),%eax
80107667:	83 ec 08             	sub    $0x8,%esp
8010766a:	52                   	push   %edx
8010766b:	50                   	push   %eax
8010766c:	e8 e6 a0 ff ff       	call   80101757 <ialloc>
80107671:	83 c4 10             	add    $0x10,%esp
80107674:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107677:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010767b:	75 0d                	jne    8010768a <create+0xe9>
    panic("create: ialloc");
8010767d:	83 ec 0c             	sub    $0xc,%esp
80107680:	68 a7 a7 10 80       	push   $0x8010a7a7
80107685:	e8 dc 8e ff ff       	call   80100566 <panic>

  ilock(ip);
8010768a:	83 ec 0c             	sub    $0xc,%esp
8010768d:	ff 75 f0             	pushl  -0x10(%ebp)
80107690:	e8 73 a3 ff ff       	call   80101a08 <ilock>
80107695:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80107698:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010769b:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010769f:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
801076a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076a6:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801076aa:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
801076ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076b1:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
801076b7:	83 ec 0c             	sub    $0xc,%esp
801076ba:	ff 75 f0             	pushl  -0x10(%ebp)
801076bd:	e8 6c a1 ff ff       	call   8010182e <iupdate>
801076c2:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801076c5:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801076ca:	75 6a                	jne    80107736 <create+0x195>
    dp->nlink++;  // for ".."
801076cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076cf:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801076d3:	83 c0 01             	add    $0x1,%eax
801076d6:	89 c2                	mov    %eax,%edx
801076d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076db:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801076df:	83 ec 0c             	sub    $0xc,%esp
801076e2:	ff 75 f4             	pushl  -0xc(%ebp)
801076e5:	e8 44 a1 ff ff       	call   8010182e <iupdate>
801076ea:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801076ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076f0:	8b 40 04             	mov    0x4(%eax),%eax
801076f3:	83 ec 04             	sub    $0x4,%esp
801076f6:	50                   	push   %eax
801076f7:	68 81 a7 10 80       	push   $0x8010a781
801076fc:	ff 75 f0             	pushl  -0x10(%ebp)
801076ff:	e8 26 ac ff ff       	call   8010232a <dirlink>
80107704:	83 c4 10             	add    $0x10,%esp
80107707:	85 c0                	test   %eax,%eax
80107709:	78 1e                	js     80107729 <create+0x188>
8010770b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010770e:	8b 40 04             	mov    0x4(%eax),%eax
80107711:	83 ec 04             	sub    $0x4,%esp
80107714:	50                   	push   %eax
80107715:	68 83 a7 10 80       	push   $0x8010a783
8010771a:	ff 75 f0             	pushl  -0x10(%ebp)
8010771d:	e8 08 ac ff ff       	call   8010232a <dirlink>
80107722:	83 c4 10             	add    $0x10,%esp
80107725:	85 c0                	test   %eax,%eax
80107727:	79 0d                	jns    80107736 <create+0x195>
      panic("create dots");
80107729:	83 ec 0c             	sub    $0xc,%esp
8010772c:	68 b6 a7 10 80       	push   $0x8010a7b6
80107731:	e8 30 8e ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80107736:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107739:	8b 40 04             	mov    0x4(%eax),%eax
8010773c:	83 ec 04             	sub    $0x4,%esp
8010773f:	50                   	push   %eax
80107740:	8d 45 de             	lea    -0x22(%ebp),%eax
80107743:	50                   	push   %eax
80107744:	ff 75 f4             	pushl  -0xc(%ebp)
80107747:	e8 de ab ff ff       	call   8010232a <dirlink>
8010774c:	83 c4 10             	add    $0x10,%esp
8010774f:	85 c0                	test   %eax,%eax
80107751:	79 0d                	jns    80107760 <create+0x1bf>
    panic("create: dirlink");
80107753:	83 ec 0c             	sub    $0xc,%esp
80107756:	68 c2 a7 10 80       	push   $0x8010a7c2
8010775b:	e8 06 8e ff ff       	call   80100566 <panic>

  iunlockput(dp);
80107760:	83 ec 0c             	sub    $0xc,%esp
80107763:	ff 75 f4             	pushl  -0xc(%ebp)
80107766:	e8 5d a5 ff ff       	call   80101cc8 <iunlockput>
8010776b:	83 c4 10             	add    $0x10,%esp

  return ip;
8010776e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107771:	c9                   	leave  
80107772:	c3                   	ret    

80107773 <sys_open>:

int
sys_open(void)
{
80107773:	55                   	push   %ebp
80107774:	89 e5                	mov    %esp,%ebp
80107776:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80107779:	83 ec 08             	sub    $0x8,%esp
8010777c:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010777f:	50                   	push   %eax
80107780:	6a 00                	push   $0x0
80107782:	e8 eb f6 ff ff       	call   80106e72 <argstr>
80107787:	83 c4 10             	add    $0x10,%esp
8010778a:	85 c0                	test   %eax,%eax
8010778c:	78 15                	js     801077a3 <sys_open+0x30>
8010778e:	83 ec 08             	sub    $0x8,%esp
80107791:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107794:	50                   	push   %eax
80107795:	6a 01                	push   $0x1
80107797:	e8 51 f6 ff ff       	call   80106ded <argint>
8010779c:	83 c4 10             	add    $0x10,%esp
8010779f:	85 c0                	test   %eax,%eax
801077a1:	79 0a                	jns    801077ad <sys_open+0x3a>
    return -1;
801077a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801077a8:	e9 61 01 00 00       	jmp    8010790e <sys_open+0x19b>

  begin_op();
801077ad:	e8 39 be ff ff       	call   801035eb <begin_op>

  if(omode & O_CREATE){
801077b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801077b5:	25 00 02 00 00       	and    $0x200,%eax
801077ba:	85 c0                	test   %eax,%eax
801077bc:	74 2a                	je     801077e8 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
801077be:	8b 45 e8             	mov    -0x18(%ebp),%eax
801077c1:	6a 00                	push   $0x0
801077c3:	6a 00                	push   $0x0
801077c5:	6a 02                	push   $0x2
801077c7:	50                   	push   %eax
801077c8:	e8 d4 fd ff ff       	call   801075a1 <create>
801077cd:	83 c4 10             	add    $0x10,%esp
801077d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801077d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801077d7:	75 75                	jne    8010784e <sys_open+0xdb>
      end_op();
801077d9:	e8 99 be ff ff       	call   80103677 <end_op>
      return -1;
801077de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801077e3:	e9 26 01 00 00       	jmp    8010790e <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
801077e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801077eb:	83 ec 0c             	sub    $0xc,%esp
801077ee:	50                   	push   %eax
801077ef:	e8 d2 ad ff ff       	call   801025c6 <namei>
801077f4:	83 c4 10             	add    $0x10,%esp
801077f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801077fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801077fe:	75 0f                	jne    8010780f <sys_open+0x9c>
      end_op();
80107800:	e8 72 be ff ff       	call   80103677 <end_op>
      return -1;
80107805:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010780a:	e9 ff 00 00 00       	jmp    8010790e <sys_open+0x19b>
    }
    ilock(ip);
8010780f:	83 ec 0c             	sub    $0xc,%esp
80107812:	ff 75 f4             	pushl  -0xc(%ebp)
80107815:	e8 ee a1 ff ff       	call   80101a08 <ilock>
8010781a:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
8010781d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107820:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107824:	66 83 f8 01          	cmp    $0x1,%ax
80107828:	75 24                	jne    8010784e <sys_open+0xdb>
8010782a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010782d:	85 c0                	test   %eax,%eax
8010782f:	74 1d                	je     8010784e <sys_open+0xdb>
      iunlockput(ip);
80107831:	83 ec 0c             	sub    $0xc,%esp
80107834:	ff 75 f4             	pushl  -0xc(%ebp)
80107837:	e8 8c a4 ff ff       	call   80101cc8 <iunlockput>
8010783c:	83 c4 10             	add    $0x10,%esp
      end_op();
8010783f:	e8 33 be ff ff       	call   80103677 <end_op>
      return -1;
80107844:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107849:	e9 c0 00 00 00       	jmp    8010790e <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010784e:	e8 de 97 ff ff       	call   80101031 <filealloc>
80107853:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107856:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010785a:	74 17                	je     80107873 <sys_open+0x100>
8010785c:	83 ec 0c             	sub    $0xc,%esp
8010785f:	ff 75 f0             	pushl  -0x10(%ebp)
80107862:	e8 37 f7 ff ff       	call   80106f9e <fdalloc>
80107867:	83 c4 10             	add    $0x10,%esp
8010786a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010786d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107871:	79 2e                	jns    801078a1 <sys_open+0x12e>
    if(f)
80107873:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107877:	74 0e                	je     80107887 <sys_open+0x114>
      fileclose(f);
80107879:	83 ec 0c             	sub    $0xc,%esp
8010787c:	ff 75 f0             	pushl  -0x10(%ebp)
8010787f:	e8 6b 98 ff ff       	call   801010ef <fileclose>
80107884:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80107887:	83 ec 0c             	sub    $0xc,%esp
8010788a:	ff 75 f4             	pushl  -0xc(%ebp)
8010788d:	e8 36 a4 ff ff       	call   80101cc8 <iunlockput>
80107892:	83 c4 10             	add    $0x10,%esp
    end_op();
80107895:	e8 dd bd ff ff       	call   80103677 <end_op>
    return -1;
8010789a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010789f:	eb 6d                	jmp    8010790e <sys_open+0x19b>
  }
  iunlock(ip);
801078a1:	83 ec 0c             	sub    $0xc,%esp
801078a4:	ff 75 f4             	pushl  -0xc(%ebp)
801078a7:	e8 ba a2 ff ff       	call   80101b66 <iunlock>
801078ac:	83 c4 10             	add    $0x10,%esp
  end_op();
801078af:	e8 c3 bd ff ff       	call   80103677 <end_op>

  f->type = FD_INODE;
801078b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078b7:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801078bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801078c3:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801078c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078c9:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801078d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801078d3:	83 e0 01             	and    $0x1,%eax
801078d6:	85 c0                	test   %eax,%eax
801078d8:	0f 94 c0             	sete   %al
801078db:	89 c2                	mov    %eax,%edx
801078dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078e0:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801078e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801078e6:	83 e0 01             	and    $0x1,%eax
801078e9:	85 c0                	test   %eax,%eax
801078eb:	75 0a                	jne    801078f7 <sys_open+0x184>
801078ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801078f0:	83 e0 02             	and    $0x2,%eax
801078f3:	85 c0                	test   %eax,%eax
801078f5:	74 07                	je     801078fe <sys_open+0x18b>
801078f7:	b8 01 00 00 00       	mov    $0x1,%eax
801078fc:	eb 05                	jmp    80107903 <sys_open+0x190>
801078fe:	b8 00 00 00 00       	mov    $0x0,%eax
80107903:	89 c2                	mov    %eax,%edx
80107905:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107908:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010790b:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010790e:	c9                   	leave  
8010790f:	c3                   	ret    

80107910 <sys_mkdir>:

int
sys_mkdir(void)
{
80107910:	55                   	push   %ebp
80107911:	89 e5                	mov    %esp,%ebp
80107913:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80107916:	e8 d0 bc ff ff       	call   801035eb <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010791b:	83 ec 08             	sub    $0x8,%esp
8010791e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107921:	50                   	push   %eax
80107922:	6a 00                	push   $0x0
80107924:	e8 49 f5 ff ff       	call   80106e72 <argstr>
80107929:	83 c4 10             	add    $0x10,%esp
8010792c:	85 c0                	test   %eax,%eax
8010792e:	78 1b                	js     8010794b <sys_mkdir+0x3b>
80107930:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107933:	6a 00                	push   $0x0
80107935:	6a 00                	push   $0x0
80107937:	6a 01                	push   $0x1
80107939:	50                   	push   %eax
8010793a:	e8 62 fc ff ff       	call   801075a1 <create>
8010793f:	83 c4 10             	add    $0x10,%esp
80107942:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107945:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107949:	75 0c                	jne    80107957 <sys_mkdir+0x47>
    end_op();
8010794b:	e8 27 bd ff ff       	call   80103677 <end_op>
    return -1;
80107950:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107955:	eb 18                	jmp    8010796f <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80107957:	83 ec 0c             	sub    $0xc,%esp
8010795a:	ff 75 f4             	pushl  -0xc(%ebp)
8010795d:	e8 66 a3 ff ff       	call   80101cc8 <iunlockput>
80107962:	83 c4 10             	add    $0x10,%esp
  end_op();
80107965:	e8 0d bd ff ff       	call   80103677 <end_op>
  return 0;
8010796a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010796f:	c9                   	leave  
80107970:	c3                   	ret    

80107971 <sys_mknod>:

int
sys_mknod(void)
{
80107971:	55                   	push   %ebp
80107972:	89 e5                	mov    %esp,%ebp
80107974:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80107977:	e8 6f bc ff ff       	call   801035eb <begin_op>
  if((len=argstr(0, &path)) < 0 ||
8010797c:	83 ec 08             	sub    $0x8,%esp
8010797f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107982:	50                   	push   %eax
80107983:	6a 00                	push   $0x0
80107985:	e8 e8 f4 ff ff       	call   80106e72 <argstr>
8010798a:	83 c4 10             	add    $0x10,%esp
8010798d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107990:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107994:	78 4f                	js     801079e5 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80107996:	83 ec 08             	sub    $0x8,%esp
80107999:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010799c:	50                   	push   %eax
8010799d:	6a 01                	push   $0x1
8010799f:	e8 49 f4 ff ff       	call   80106ded <argint>
801079a4:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
801079a7:	85 c0                	test   %eax,%eax
801079a9:	78 3a                	js     801079e5 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801079ab:	83 ec 08             	sub    $0x8,%esp
801079ae:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801079b1:	50                   	push   %eax
801079b2:	6a 02                	push   $0x2
801079b4:	e8 34 f4 ff ff       	call   80106ded <argint>
801079b9:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801079bc:	85 c0                	test   %eax,%eax
801079be:	78 25                	js     801079e5 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801079c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801079c3:	0f bf c8             	movswl %ax,%ecx
801079c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801079c9:	0f bf d0             	movswl %ax,%edx
801079cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801079cf:	51                   	push   %ecx
801079d0:	52                   	push   %edx
801079d1:	6a 03                	push   $0x3
801079d3:	50                   	push   %eax
801079d4:	e8 c8 fb ff ff       	call   801075a1 <create>
801079d9:	83 c4 10             	add    $0x10,%esp
801079dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
801079df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801079e3:	75 0c                	jne    801079f1 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
801079e5:	e8 8d bc ff ff       	call   80103677 <end_op>
    return -1;
801079ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801079ef:	eb 18                	jmp    80107a09 <sys_mknod+0x98>
  }
  iunlockput(ip);
801079f1:	83 ec 0c             	sub    $0xc,%esp
801079f4:	ff 75 f0             	pushl  -0x10(%ebp)
801079f7:	e8 cc a2 ff ff       	call   80101cc8 <iunlockput>
801079fc:	83 c4 10             	add    $0x10,%esp
  end_op();
801079ff:	e8 73 bc ff ff       	call   80103677 <end_op>
  return 0;
80107a04:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107a09:	c9                   	leave  
80107a0a:	c3                   	ret    

80107a0b <sys_chdir>:

int
sys_chdir(void)
{
80107a0b:	55                   	push   %ebp
80107a0c:	89 e5                	mov    %esp,%ebp
80107a0e:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80107a11:	e8 d5 bb ff ff       	call   801035eb <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80107a16:	83 ec 08             	sub    $0x8,%esp
80107a19:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107a1c:	50                   	push   %eax
80107a1d:	6a 00                	push   $0x0
80107a1f:	e8 4e f4 ff ff       	call   80106e72 <argstr>
80107a24:	83 c4 10             	add    $0x10,%esp
80107a27:	85 c0                	test   %eax,%eax
80107a29:	78 18                	js     80107a43 <sys_chdir+0x38>
80107a2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a2e:	83 ec 0c             	sub    $0xc,%esp
80107a31:	50                   	push   %eax
80107a32:	e8 8f ab ff ff       	call   801025c6 <namei>
80107a37:	83 c4 10             	add    $0x10,%esp
80107a3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107a3d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107a41:	75 0c                	jne    80107a4f <sys_chdir+0x44>
    end_op();
80107a43:	e8 2f bc ff ff       	call   80103677 <end_op>
    return -1;
80107a48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a4d:	eb 6e                	jmp    80107abd <sys_chdir+0xb2>
  }
  ilock(ip);
80107a4f:	83 ec 0c             	sub    $0xc,%esp
80107a52:	ff 75 f4             	pushl  -0xc(%ebp)
80107a55:	e8 ae 9f ff ff       	call   80101a08 <ilock>
80107a5a:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80107a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a60:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107a64:	66 83 f8 01          	cmp    $0x1,%ax
80107a68:	74 1a                	je     80107a84 <sys_chdir+0x79>
    iunlockput(ip);
80107a6a:	83 ec 0c             	sub    $0xc,%esp
80107a6d:	ff 75 f4             	pushl  -0xc(%ebp)
80107a70:	e8 53 a2 ff ff       	call   80101cc8 <iunlockput>
80107a75:	83 c4 10             	add    $0x10,%esp
    end_op();
80107a78:	e8 fa bb ff ff       	call   80103677 <end_op>
    return -1;
80107a7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a82:	eb 39                	jmp    80107abd <sys_chdir+0xb2>
  }
  iunlock(ip);
80107a84:	83 ec 0c             	sub    $0xc,%esp
80107a87:	ff 75 f4             	pushl  -0xc(%ebp)
80107a8a:	e8 d7 a0 ff ff       	call   80101b66 <iunlock>
80107a8f:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80107a92:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107a98:	8b 40 68             	mov    0x68(%eax),%eax
80107a9b:	83 ec 0c             	sub    $0xc,%esp
80107a9e:	50                   	push   %eax
80107a9f:	e8 34 a1 ff ff       	call   80101bd8 <iput>
80107aa4:	83 c4 10             	add    $0x10,%esp
  end_op();
80107aa7:	e8 cb bb ff ff       	call   80103677 <end_op>
  proc->cwd = ip;
80107aac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107ab2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107ab5:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80107ab8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107abd:	c9                   	leave  
80107abe:	c3                   	ret    

80107abf <sys_exec>:

int
sys_exec(void)
{
80107abf:	55                   	push   %ebp
80107ac0:	89 e5                	mov    %esp,%ebp
80107ac2:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80107ac8:	83 ec 08             	sub    $0x8,%esp
80107acb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107ace:	50                   	push   %eax
80107acf:	6a 00                	push   $0x0
80107ad1:	e8 9c f3 ff ff       	call   80106e72 <argstr>
80107ad6:	83 c4 10             	add    $0x10,%esp
80107ad9:	85 c0                	test   %eax,%eax
80107adb:	78 18                	js     80107af5 <sys_exec+0x36>
80107add:	83 ec 08             	sub    $0x8,%esp
80107ae0:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80107ae6:	50                   	push   %eax
80107ae7:	6a 01                	push   $0x1
80107ae9:	e8 ff f2 ff ff       	call   80106ded <argint>
80107aee:	83 c4 10             	add    $0x10,%esp
80107af1:	85 c0                	test   %eax,%eax
80107af3:	79 0a                	jns    80107aff <sys_exec+0x40>
    return -1;
80107af5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107afa:	e9 c6 00 00 00       	jmp    80107bc5 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80107aff:	83 ec 04             	sub    $0x4,%esp
80107b02:	68 80 00 00 00       	push   $0x80
80107b07:	6a 00                	push   $0x0
80107b09:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80107b0f:	50                   	push   %eax
80107b10:	e8 b3 ef ff ff       	call   80106ac8 <memset>
80107b15:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80107b18:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80107b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b22:	83 f8 1f             	cmp    $0x1f,%eax
80107b25:	76 0a                	jbe    80107b31 <sys_exec+0x72>
      return -1;
80107b27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b2c:	e9 94 00 00 00       	jmp    80107bc5 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80107b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b34:	c1 e0 02             	shl    $0x2,%eax
80107b37:	89 c2                	mov    %eax,%edx
80107b39:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80107b3f:	01 c2                	add    %eax,%edx
80107b41:	83 ec 08             	sub    $0x8,%esp
80107b44:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80107b4a:	50                   	push   %eax
80107b4b:	52                   	push   %edx
80107b4c:	e8 00 f2 ff ff       	call   80106d51 <fetchint>
80107b51:	83 c4 10             	add    $0x10,%esp
80107b54:	85 c0                	test   %eax,%eax
80107b56:	79 07                	jns    80107b5f <sys_exec+0xa0>
      return -1;
80107b58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b5d:	eb 66                	jmp    80107bc5 <sys_exec+0x106>
    if(uarg == 0){
80107b5f:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107b65:	85 c0                	test   %eax,%eax
80107b67:	75 27                	jne    80107b90 <sys_exec+0xd1>
      argv[i] = 0;
80107b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b6c:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80107b73:	00 00 00 00 
      break;
80107b77:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80107b78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b7b:	83 ec 08             	sub    $0x8,%esp
80107b7e:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80107b84:	52                   	push   %edx
80107b85:	50                   	push   %eax
80107b86:	e8 84 90 ff ff       	call   80100c0f <exec>
80107b8b:	83 c4 10             	add    $0x10,%esp
80107b8e:	eb 35                	jmp    80107bc5 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80107b90:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80107b96:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107b99:	c1 e2 02             	shl    $0x2,%edx
80107b9c:	01 c2                	add    %eax,%edx
80107b9e:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107ba4:	83 ec 08             	sub    $0x8,%esp
80107ba7:	52                   	push   %edx
80107ba8:	50                   	push   %eax
80107ba9:	e8 dd f1 ff ff       	call   80106d8b <fetchstr>
80107bae:	83 c4 10             	add    $0x10,%esp
80107bb1:	85 c0                	test   %eax,%eax
80107bb3:	79 07                	jns    80107bbc <sys_exec+0xfd>
      return -1;
80107bb5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107bba:	eb 09                	jmp    80107bc5 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80107bbc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80107bc0:	e9 5a ff ff ff       	jmp    80107b1f <sys_exec+0x60>
  return exec(path, argv);
}
80107bc5:	c9                   	leave  
80107bc6:	c3                   	ret    

80107bc7 <sys_pipe>:

int
sys_pipe(void)
{
80107bc7:	55                   	push   %ebp
80107bc8:	89 e5                	mov    %esp,%ebp
80107bca:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80107bcd:	83 ec 04             	sub    $0x4,%esp
80107bd0:	6a 08                	push   $0x8
80107bd2:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107bd5:	50                   	push   %eax
80107bd6:	6a 00                	push   $0x0
80107bd8:	e8 38 f2 ff ff       	call   80106e15 <argptr>
80107bdd:	83 c4 10             	add    $0x10,%esp
80107be0:	85 c0                	test   %eax,%eax
80107be2:	79 0a                	jns    80107bee <sys_pipe+0x27>
    return -1;
80107be4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107be9:	e9 af 00 00 00       	jmp    80107c9d <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80107bee:	83 ec 08             	sub    $0x8,%esp
80107bf1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107bf4:	50                   	push   %eax
80107bf5:	8d 45 e8             	lea    -0x18(%ebp),%eax
80107bf8:	50                   	push   %eax
80107bf9:	e8 e1 c4 ff ff       	call   801040df <pipealloc>
80107bfe:	83 c4 10             	add    $0x10,%esp
80107c01:	85 c0                	test   %eax,%eax
80107c03:	79 0a                	jns    80107c0f <sys_pipe+0x48>
    return -1;
80107c05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c0a:	e9 8e 00 00 00       	jmp    80107c9d <sys_pipe+0xd6>
  fd0 = -1;
80107c0f:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80107c16:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107c19:	83 ec 0c             	sub    $0xc,%esp
80107c1c:	50                   	push   %eax
80107c1d:	e8 7c f3 ff ff       	call   80106f9e <fdalloc>
80107c22:	83 c4 10             	add    $0x10,%esp
80107c25:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107c28:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107c2c:	78 18                	js     80107c46 <sys_pipe+0x7f>
80107c2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107c31:	83 ec 0c             	sub    $0xc,%esp
80107c34:	50                   	push   %eax
80107c35:	e8 64 f3 ff ff       	call   80106f9e <fdalloc>
80107c3a:	83 c4 10             	add    $0x10,%esp
80107c3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107c40:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107c44:	79 3f                	jns    80107c85 <sys_pipe+0xbe>
    if(fd0 >= 0)
80107c46:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107c4a:	78 14                	js     80107c60 <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80107c4c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107c52:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107c55:	83 c2 08             	add    $0x8,%edx
80107c58:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80107c5f:	00 
    fileclose(rf);
80107c60:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107c63:	83 ec 0c             	sub    $0xc,%esp
80107c66:	50                   	push   %eax
80107c67:	e8 83 94 ff ff       	call   801010ef <fileclose>
80107c6c:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80107c6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107c72:	83 ec 0c             	sub    $0xc,%esp
80107c75:	50                   	push   %eax
80107c76:	e8 74 94 ff ff       	call   801010ef <fileclose>
80107c7b:	83 c4 10             	add    $0x10,%esp
    return -1;
80107c7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c83:	eb 18                	jmp    80107c9d <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80107c85:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c88:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107c8b:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80107c8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c90:	8d 50 04             	lea    0x4(%eax),%edx
80107c93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c96:	89 02                	mov    %eax,(%edx)
  return 0;
80107c98:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107c9d:	c9                   	leave  
80107c9e:	c3                   	ret    

80107c9f <outw>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outw(ushort port, ushort data)
{
80107c9f:	55                   	push   %ebp
80107ca0:	89 e5                	mov    %esp,%ebp
80107ca2:	83 ec 08             	sub    $0x8,%esp
80107ca5:	8b 55 08             	mov    0x8(%ebp),%edx
80107ca8:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cab:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107caf:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107cb3:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
80107cb7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107cbb:	66 ef                	out    %ax,(%dx)
}
80107cbd:	90                   	nop
80107cbe:	c9                   	leave  
80107cbf:	c3                   	ret    

80107cc0 <sys_fork>:
#include "proc.h"
#include "uproc.h"

int
sys_fork(void)
{
80107cc0:	55                   	push   %ebp
80107cc1:	89 e5                	mov    %esp,%ebp
80107cc3:	83 ec 08             	sub    $0x8,%esp
  return fork();
80107cc6:	e8 1e cd ff ff       	call   801049e9 <fork>
}
80107ccb:	c9                   	leave  
80107ccc:	c3                   	ret    

80107ccd <sys_exit>:

int
sys_exit(void)
{
80107ccd:	55                   	push   %ebp
80107cce:	89 e5                	mov    %esp,%ebp
80107cd0:	83 ec 08             	sub    $0x8,%esp
  exit();
80107cd3:	e8 f8 cf ff ff       	call   80104cd0 <exit>
  return 0;  // not reached
80107cd8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107cdd:	c9                   	leave  
80107cde:	c3                   	ret    

80107cdf <sys_wait>:

int
sys_wait(void)
{
80107cdf:	55                   	push   %ebp
80107ce0:	89 e5                	mov    %esp,%ebp
80107ce2:	83 ec 08             	sub    $0x8,%esp
  return wait();
80107ce5:	e8 3b d2 ff ff       	call   80104f25 <wait>
}
80107cea:	c9                   	leave  
80107ceb:	c3                   	ret    

80107cec <sys_kill>:

int
sys_kill(void)
{
80107cec:	55                   	push   %ebp
80107ced:	89 e5                	mov    %esp,%ebp
80107cef:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80107cf2:	83 ec 08             	sub    $0x8,%esp
80107cf5:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107cf8:	50                   	push   %eax
80107cf9:	6a 00                	push   $0x0
80107cfb:	e8 ed f0 ff ff       	call   80106ded <argint>
80107d00:	83 c4 10             	add    $0x10,%esp
80107d03:	85 c0                	test   %eax,%eax
80107d05:	79 07                	jns    80107d0e <sys_kill+0x22>
    return -1;
80107d07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d0c:	eb 0f                	jmp    80107d1d <sys_kill+0x31>
  return kill(pid);
80107d0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d11:	83 ec 0c             	sub    $0xc,%esp
80107d14:	50                   	push   %eax
80107d15:	e8 53 db ff ff       	call   8010586d <kill>
80107d1a:	83 c4 10             	add    $0x10,%esp
}
80107d1d:	c9                   	leave  
80107d1e:	c3                   	ret    

80107d1f <sys_getpid>:

int
sys_getpid(void)
{
80107d1f:	55                   	push   %ebp
80107d20:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80107d22:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107d28:	8b 40 10             	mov    0x10(%eax),%eax
}
80107d2b:	5d                   	pop    %ebp
80107d2c:	c3                   	ret    

80107d2d <sys_sbrk>:

int
sys_sbrk(void)
{
80107d2d:	55                   	push   %ebp
80107d2e:	89 e5                	mov    %esp,%ebp
80107d30:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80107d33:	83 ec 08             	sub    $0x8,%esp
80107d36:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107d39:	50                   	push   %eax
80107d3a:	6a 00                	push   $0x0
80107d3c:	e8 ac f0 ff ff       	call   80106ded <argint>
80107d41:	83 c4 10             	add    $0x10,%esp
80107d44:	85 c0                	test   %eax,%eax
80107d46:	79 07                	jns    80107d4f <sys_sbrk+0x22>
    return -1;
80107d48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d4d:	eb 28                	jmp    80107d77 <sys_sbrk+0x4a>
  addr = proc->sz;
80107d4f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107d55:	8b 00                	mov    (%eax),%eax
80107d57:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80107d5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d5d:	83 ec 0c             	sub    $0xc,%esp
80107d60:	50                   	push   %eax
80107d61:	e8 e0 cb ff ff       	call   80104946 <growproc>
80107d66:	83 c4 10             	add    $0x10,%esp
80107d69:	85 c0                	test   %eax,%eax
80107d6b:	79 07                	jns    80107d74 <sys_sbrk+0x47>
    return -1;
80107d6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d72:	eb 03                	jmp    80107d77 <sys_sbrk+0x4a>
  return addr;
80107d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107d77:	c9                   	leave  
80107d78:	c3                   	ret    

80107d79 <sys_sleep>:

int
sys_sleep(void)
{
80107d79:	55                   	push   %ebp
80107d7a:	89 e5                	mov    %esp,%ebp
80107d7c:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80107d7f:	83 ec 08             	sub    $0x8,%esp
80107d82:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107d85:	50                   	push   %eax
80107d86:	6a 00                	push   $0x0
80107d88:	e8 60 f0 ff ff       	call   80106ded <argint>
80107d8d:	83 c4 10             	add    $0x10,%esp
80107d90:	85 c0                	test   %eax,%eax
80107d92:	79 07                	jns    80107d9b <sys_sleep+0x22>
    return -1;
80107d94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d99:	eb 44                	jmp    80107ddf <sys_sleep+0x66>
  ticks0 = ticks;
80107d9b:	a1 20 79 11 80       	mov    0x80117920,%eax
80107da0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80107da3:	eb 26                	jmp    80107dcb <sys_sleep+0x52>
    if(proc->killed){
80107da5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107dab:	8b 40 24             	mov    0x24(%eax),%eax
80107dae:	85 c0                	test   %eax,%eax
80107db0:	74 07                	je     80107db9 <sys_sleep+0x40>
      return -1;
80107db2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107db7:	eb 26                	jmp    80107ddf <sys_sleep+0x66>
    }
    sleep(&ticks, (struct spinlock *)0);
80107db9:	83 ec 08             	sub    $0x8,%esp
80107dbc:	6a 00                	push   $0x0
80107dbe:	68 20 79 11 80       	push   $0x80117920
80107dc3:	e8 f8 d7 ff ff       	call   801055c0 <sleep>
80107dc8:	83 c4 10             	add    $0x10,%esp
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80107dcb:	a1 20 79 11 80       	mov    0x80117920,%eax
80107dd0:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107dd3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107dd6:	39 d0                	cmp    %edx,%eax
80107dd8:	72 cb                	jb     80107da5 <sys_sleep+0x2c>
    if(proc->killed){
      return -1;
    }
    sleep(&ticks, (struct spinlock *)0);
  }
  return 0;
80107dda:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107ddf:	c9                   	leave  
80107de0:	c3                   	ret    

80107de1 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80107de1:	55                   	push   %ebp
80107de2:	89 e5                	mov    %esp,%ebp
80107de4:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  xticks = ticks;
80107de7:	a1 20 79 11 80       	mov    0x80117920,%eax
80107dec:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return xticks;
80107def:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80107df2:	c9                   	leave  
80107df3:	c3                   	ret    

80107df4 <sys_halt>:

//Turn of the computer
int
sys_halt(void){
80107df4:	55                   	push   %ebp
80107df5:	89 e5                	mov    %esp,%ebp
80107df7:	83 ec 08             	sub    $0x8,%esp
  cprintf("Shutting down ...\n");
80107dfa:	83 ec 0c             	sub    $0xc,%esp
80107dfd:	68 d2 a7 10 80       	push   $0x8010a7d2
80107e02:	e8 bf 85 ff ff       	call   801003c6 <cprintf>
80107e07:	83 c4 10             	add    $0x10,%esp
  outw( 0x604, 0x0 | 0x2000);
80107e0a:	83 ec 08             	sub    $0x8,%esp
80107e0d:	68 00 20 00 00       	push   $0x2000
80107e12:	68 04 06 00 00       	push   $0x604
80107e17:	e8 83 fe ff ff       	call   80107c9f <outw>
80107e1c:	83 c4 10             	add    $0x10,%esp
  return 0;
80107e1f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107e24:	c9                   	leave  
80107e25:	c3                   	ret    

80107e26 <sys_date>:


int
sys_date(void)
{
80107e26:	55                   	push   %ebp
80107e27:	89 e5                	mov    %esp,%ebp
80107e29:	83 ec 18             	sub    $0x18,%esp
  struct rtcdate *d;
  if(argptr(0, (void*)&d, sizeof(struct rtcdate)) < 0)
80107e2c:	83 ec 04             	sub    $0x4,%esp
80107e2f:	6a 18                	push   $0x18
80107e31:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107e34:	50                   	push   %eax
80107e35:	6a 00                	push   $0x0
80107e37:	e8 d9 ef ff ff       	call   80106e15 <argptr>
80107e3c:	83 c4 10             	add    $0x10,%esp
80107e3f:	85 c0                	test   %eax,%eax
80107e41:	79 07                	jns    80107e4a <sys_date+0x24>
    return -1;
80107e43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e48:	eb 14                	jmp    80107e5e <sys_date+0x38>
  cmostime(d);
80107e4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4d:	83 ec 0c             	sub    $0xc,%esp
80107e50:	50                   	push   %eax
80107e51:	e8 10 b4 ff ff       	call   80103266 <cmostime>
80107e56:	83 c4 10             	add    $0x10,%esp
  return 0;
80107e59:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107e5e:	c9                   	leave  
80107e5f:	c3                   	ret    

80107e60 <sys_getuid>:

//Get gid
uint
sys_getuid(void)
{
80107e60:	55                   	push   %ebp
80107e61:	89 e5                	mov    %esp,%ebp
  return proc->uid;
80107e63:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107e69:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
80107e6f:	5d                   	pop    %ebp
80107e70:	c3                   	ret    

80107e71 <sys_getgid>:

//Get gid
uint
sys_getgid(void)
{
80107e71:	55                   	push   %ebp
80107e72:	89 e5                	mov    %esp,%ebp
  return proc->gid;
80107e74:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107e7a:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
}
80107e80:	5d                   	pop    %ebp
80107e81:	c3                   	ret    

80107e82 <sys_getppid>:

//Returns init's pid, since it has no parent.
//Or returns the parents pid.
uint
sys_getppid(void)
{
80107e82:	55                   	push   %ebp
80107e83:	89 e5                	mov    %esp,%ebp
  if(proc->parent != 0)
80107e85:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107e8b:	8b 40 14             	mov    0x14(%eax),%eax
80107e8e:	85 c0                	test   %eax,%eax
80107e90:	74 0e                	je     80107ea0 <sys_getppid+0x1e>
    return proc->parent->pid;
80107e92:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107e98:	8b 40 14             	mov    0x14(%eax),%eax
80107e9b:	8b 40 10             	mov    0x10(%eax),%eax
80107e9e:	eb 09                	jmp    80107ea9 <sys_getppid+0x27>
  return proc->pid;
80107ea0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107ea6:	8b 40 10             	mov    0x10(%eax),%eax
}
80107ea9:	5d                   	pop    %ebp
80107eaa:	c3                   	ret    

80107eab <sys_setuid>:

//Sets the uid after making sure that the argument
//is within the bounds 0<=32767
int
sys_setuid(uint _uid)
{
80107eab:	55                   	push   %ebp
80107eac:	89 e5                	mov    %esp,%ebp
80107eae:	83 ec 08             	sub    $0x8,%esp
  argint(0, (int*)&_uid);
80107eb1:	83 ec 08             	sub    $0x8,%esp
80107eb4:	8d 45 08             	lea    0x8(%ebp),%eax
80107eb7:	50                   	push   %eax
80107eb8:	6a 00                	push   $0x0
80107eba:	e8 2e ef ff ff       	call   80106ded <argint>
80107ebf:	83 c4 10             	add    $0x10,%esp
  if (_uid>= 0 && _uid<= 32767)
80107ec2:	8b 45 08             	mov    0x8(%ebp),%eax
80107ec5:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
80107eca:	77 16                	ja     80107ee2 <sys_setuid+0x37>
  {
    proc->uid = _uid;
80107ecc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107ed2:	8b 55 08             	mov    0x8(%ebp),%edx
80107ed5:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
    return 0;
80107edb:	b8 00 00 00 00       	mov    $0x0,%eax
80107ee0:	eb 05                	jmp    80107ee7 <sys_setuid+0x3c>
  }
  return -1;
80107ee2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107ee7:	c9                   	leave  
80107ee8:	c3                   	ret    

80107ee9 <sys_setgid>:

//Sets the gid after making sure that the argument
//is within the bouds 0<=32767
int
sys_setgid(uint _uid)
{
80107ee9:	55                   	push   %ebp
80107eea:	89 e5                	mov    %esp,%ebp
80107eec:	83 ec 08             	sub    $0x8,%esp
  argint(0, (int*)&_uid);
80107eef:	83 ec 08             	sub    $0x8,%esp
80107ef2:	8d 45 08             	lea    0x8(%ebp),%eax
80107ef5:	50                   	push   %eax
80107ef6:	6a 00                	push   $0x0
80107ef8:	e8 f0 ee ff ff       	call   80106ded <argint>
80107efd:	83 c4 10             	add    $0x10,%esp
  if (_uid>= 0 && _uid<= 32767)
80107f00:	8b 45 08             	mov    0x8(%ebp),%eax
80107f03:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
80107f08:	77 16                	ja     80107f20 <sys_setgid+0x37>
  {
    proc->gid = _uid;
80107f0a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107f10:	8b 55 08             	mov    0x8(%ebp),%edx
80107f13:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
    return 0;
80107f19:	b8 00 00 00 00       	mov    $0x0,%eax
80107f1e:	eb 05                	jmp    80107f25 <sys_setgid+0x3c>
  }
  return -1;
80107f20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107f25:	c9                   	leave  
80107f26:	c3                   	ret    

80107f27 <sys_getprocs>:

//Getprocs calls getprocs in proc.c in order to lock the ptable and
//grab all the processes off of that when ps is called.
int
sys_getprocs(int max, struct uproc* table)
{
80107f27:	55                   	push   %ebp
80107f28:	89 e5                	mov    %esp,%ebp
80107f2a:	83 ec 08             	sub    $0x8,%esp
  if(argint(0,&max)< 0 || argptr(1,(void*)&table,sizeof(*table)*max) <0)
80107f2d:	83 ec 08             	sub    $0x8,%esp
80107f30:	8d 45 08             	lea    0x8(%ebp),%eax
80107f33:	50                   	push   %eax
80107f34:	6a 00                	push   $0x0
80107f36:	e8 b2 ee ff ff       	call   80106ded <argint>
80107f3b:	83 c4 10             	add    $0x10,%esp
80107f3e:	85 c0                	test   %eax,%eax
80107f40:	78 24                	js     80107f66 <sys_getprocs+0x3f>
80107f42:	8b 45 08             	mov    0x8(%ebp),%eax
80107f45:	89 c2                	mov    %eax,%edx
80107f47:	89 d0                	mov    %edx,%eax
80107f49:	01 c0                	add    %eax,%eax
80107f4b:	01 d0                	add    %edx,%eax
80107f4d:	c1 e0 05             	shl    $0x5,%eax
80107f50:	83 ec 04             	sub    $0x4,%esp
80107f53:	50                   	push   %eax
80107f54:	8d 45 0c             	lea    0xc(%ebp),%eax
80107f57:	50                   	push   %eax
80107f58:	6a 01                	push   $0x1
80107f5a:	e8 b6 ee ff ff       	call   80106e15 <argptr>
80107f5f:	83 c4 10             	add    $0x10,%esp
80107f62:	85 c0                	test   %eax,%eax
80107f64:	79 07                	jns    80107f6d <sys_getprocs+0x46>
    return -1;
80107f66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f6b:	eb 13                	jmp    80107f80 <sys_getprocs+0x59>
  return getprocs(max,table);
80107f6d:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f70:	8b 45 08             	mov    0x8(%ebp),%eax
80107f73:	83 ec 08             	sub    $0x8,%esp
80107f76:	52                   	push   %edx
80107f77:	50                   	push   %eax
80107f78:	e8 ed df ff ff       	call   80105f6a <getprocs>
80107f7d:	83 c4 10             	add    $0x10,%esp
}
80107f80:	c9                   	leave  
80107f81:	c3                   	ret    

80107f82 <sys_setpriority>:

#ifdef CS333_P3P4
int
sys_setpriority(void)
{
80107f82:	55                   	push   %ebp
80107f83:	89 e5                	mov    %esp,%ebp
80107f85:	83 ec 18             	sub    $0x18,%esp
  int pid;
  int value;

  if(argint(0, &pid)< 0 || argint(1,&value))
80107f88:	83 ec 08             	sub    $0x8,%esp
80107f8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107f8e:	50                   	push   %eax
80107f8f:	6a 00                	push   $0x0
80107f91:	e8 57 ee ff ff       	call   80106ded <argint>
80107f96:	83 c4 10             	add    $0x10,%esp
80107f99:	85 c0                	test   %eax,%eax
80107f9b:	78 15                	js     80107fb2 <sys_setpriority+0x30>
80107f9d:	83 ec 08             	sub    $0x8,%esp
80107fa0:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107fa3:	50                   	push   %eax
80107fa4:	6a 01                	push   $0x1
80107fa6:	e8 42 ee ff ff       	call   80106ded <argint>
80107fab:	83 c4 10             	add    $0x10,%esp
80107fae:	85 c0                	test   %eax,%eax
80107fb0:	74 07                	je     80107fb9 <sys_setpriority+0x37>
    return -1;
80107fb2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107fb7:	eb 13                	jmp    80107fcc <sys_setpriority+0x4a>

  return setpriority(pid, value);
80107fb9:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fbf:	83 ec 08             	sub    $0x8,%esp
80107fc2:	52                   	push   %edx
80107fc3:	50                   	push   %eax
80107fc4:	e8 54 e4 ff ff       	call   8010641d <setpriority>
80107fc9:	83 c4 10             	add    $0x10,%esp
}
80107fcc:	c9                   	leave  
80107fcd:	c3                   	ret    

80107fce <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107fce:	55                   	push   %ebp
80107fcf:	89 e5                	mov    %esp,%ebp
80107fd1:	83 ec 08             	sub    $0x8,%esp
80107fd4:	8b 55 08             	mov    0x8(%ebp),%edx
80107fd7:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fda:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107fde:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107fe1:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107fe5:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107fe9:	ee                   	out    %al,(%dx)
}
80107fea:	90                   	nop
80107feb:	c9                   	leave  
80107fec:	c3                   	ret    

80107fed <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80107fed:	55                   	push   %ebp
80107fee:	89 e5                	mov    %esp,%ebp
80107ff0:	83 ec 08             	sub    $0x8,%esp
  // Interrupt TPS times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80107ff3:	6a 34                	push   $0x34
80107ff5:	6a 43                	push   $0x43
80107ff7:	e8 d2 ff ff ff       	call   80107fce <outb>
80107ffc:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) % 256);
80107fff:	68 a9 00 00 00       	push   $0xa9
80108004:	6a 40                	push   $0x40
80108006:	e8 c3 ff ff ff       	call   80107fce <outb>
8010800b:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) / 256);
8010800e:	6a 04                	push   $0x4
80108010:	6a 40                	push   $0x40
80108012:	e8 b7 ff ff ff       	call   80107fce <outb>
80108017:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
8010801a:	83 ec 0c             	sub    $0xc,%esp
8010801d:	6a 00                	push   $0x0
8010801f:	e8 a5 bf ff ff       	call   80103fc9 <picenable>
80108024:	83 c4 10             	add    $0x10,%esp
}
80108027:	90                   	nop
80108028:	c9                   	leave  
80108029:	c3                   	ret    

8010802a <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010802a:	1e                   	push   %ds
  pushl %es
8010802b:	06                   	push   %es
  pushl %fs
8010802c:	0f a0                	push   %fs
  pushl %gs
8010802e:	0f a8                	push   %gs
  pushal
80108030:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80108031:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80108035:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80108037:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80108039:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
8010803d:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
8010803f:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80108041:	54                   	push   %esp
  call trap
80108042:	e8 ce 01 00 00       	call   80108215 <trap>
  addl $4, %esp
80108047:	83 c4 04             	add    $0x4,%esp

8010804a <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010804a:	61                   	popa   
  popl %gs
8010804b:	0f a9                	pop    %gs
  popl %fs
8010804d:	0f a1                	pop    %fs
  popl %es
8010804f:	07                   	pop    %es
  popl %ds
80108050:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80108051:	83 c4 08             	add    $0x8,%esp
  iret
80108054:	cf                   	iret   

80108055 <atom_inc>:

// Routines added for CS333
// atom_inc() added to simplify handling of ticks global
static inline void
atom_inc(volatile int *num)
{
80108055:	55                   	push   %ebp
80108056:	89 e5                	mov    %esp,%ebp
  asm volatile ( "lock incl %0" : "=m" (*num));
80108058:	8b 45 08             	mov    0x8(%ebp),%eax
8010805b:	f0 ff 00             	lock incl (%eax)
}
8010805e:	90                   	nop
8010805f:	5d                   	pop    %ebp
80108060:	c3                   	ret    

80108061 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80108061:	55                   	push   %ebp
80108062:	89 e5                	mov    %esp,%ebp
80108064:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80108067:	8b 45 0c             	mov    0xc(%ebp),%eax
8010806a:	83 e8 01             	sub    $0x1,%eax
8010806d:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80108071:	8b 45 08             	mov    0x8(%ebp),%eax
80108074:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80108078:	8b 45 08             	mov    0x8(%ebp),%eax
8010807b:	c1 e8 10             	shr    $0x10,%eax
8010807e:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80108082:	8d 45 fa             	lea    -0x6(%ebp),%eax
80108085:	0f 01 18             	lidtl  (%eax)
}
80108088:	90                   	nop
80108089:	c9                   	leave  
8010808a:	c3                   	ret    

8010808b <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
8010808b:	55                   	push   %ebp
8010808c:	89 e5                	mov    %esp,%ebp
8010808e:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80108091:	0f 20 d0             	mov    %cr2,%eax
80108094:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80108097:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010809a:	c9                   	leave  
8010809b:	c3                   	ret    

8010809c <tvinit>:
// Software Developer’s Manual, Vol 3A, 8.1.1 Guaranteed Atomic Operations.
uint ticks __attribute__ ((aligned (4)));

void
tvinit(void)
{
8010809c:	55                   	push   %ebp
8010809d:	89 e5                	mov    %esp,%ebp
8010809f:	83 ec 10             	sub    $0x10,%esp
  int i;

  for(i = 0; i < 256; i++)
801080a2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801080a9:	e9 c3 00 00 00       	jmp    80108171 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801080ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080b1:	8b 04 85 b4 d0 10 80 	mov    -0x7fef2f4c(,%eax,4),%eax
801080b8:	89 c2                	mov    %eax,%edx
801080ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080bd:	66 89 14 c5 20 71 11 	mov    %dx,-0x7fee8ee0(,%eax,8)
801080c4:	80 
801080c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080c8:	66 c7 04 c5 22 71 11 	movw   $0x8,-0x7fee8ede(,%eax,8)
801080cf:	80 08 00 
801080d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080d5:	0f b6 14 c5 24 71 11 	movzbl -0x7fee8edc(,%eax,8),%edx
801080dc:	80 
801080dd:	83 e2 e0             	and    $0xffffffe0,%edx
801080e0:	88 14 c5 24 71 11 80 	mov    %dl,-0x7fee8edc(,%eax,8)
801080e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080ea:	0f b6 14 c5 24 71 11 	movzbl -0x7fee8edc(,%eax,8),%edx
801080f1:	80 
801080f2:	83 e2 1f             	and    $0x1f,%edx
801080f5:	88 14 c5 24 71 11 80 	mov    %dl,-0x7fee8edc(,%eax,8)
801080fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080ff:	0f b6 14 c5 25 71 11 	movzbl -0x7fee8edb(,%eax,8),%edx
80108106:	80 
80108107:	83 e2 f0             	and    $0xfffffff0,%edx
8010810a:	83 ca 0e             	or     $0xe,%edx
8010810d:	88 14 c5 25 71 11 80 	mov    %dl,-0x7fee8edb(,%eax,8)
80108114:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108117:	0f b6 14 c5 25 71 11 	movzbl -0x7fee8edb(,%eax,8),%edx
8010811e:	80 
8010811f:	83 e2 ef             	and    $0xffffffef,%edx
80108122:	88 14 c5 25 71 11 80 	mov    %dl,-0x7fee8edb(,%eax,8)
80108129:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010812c:	0f b6 14 c5 25 71 11 	movzbl -0x7fee8edb(,%eax,8),%edx
80108133:	80 
80108134:	83 e2 9f             	and    $0xffffff9f,%edx
80108137:	88 14 c5 25 71 11 80 	mov    %dl,-0x7fee8edb(,%eax,8)
8010813e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108141:	0f b6 14 c5 25 71 11 	movzbl -0x7fee8edb(,%eax,8),%edx
80108148:	80 
80108149:	83 ca 80             	or     $0xffffff80,%edx
8010814c:	88 14 c5 25 71 11 80 	mov    %dl,-0x7fee8edb(,%eax,8)
80108153:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108156:	8b 04 85 b4 d0 10 80 	mov    -0x7fef2f4c(,%eax,4),%eax
8010815d:	c1 e8 10             	shr    $0x10,%eax
80108160:	89 c2                	mov    %eax,%edx
80108162:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108165:	66 89 14 c5 26 71 11 	mov    %dx,-0x7fee8eda(,%eax,8)
8010816c:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010816d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80108171:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
80108178:	0f 8e 30 ff ff ff    	jle    801080ae <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010817e:	a1 b4 d1 10 80       	mov    0x8010d1b4,%eax
80108183:	66 a3 20 73 11 80    	mov    %ax,0x80117320
80108189:	66 c7 05 22 73 11 80 	movw   $0x8,0x80117322
80108190:	08 00 
80108192:	0f b6 05 24 73 11 80 	movzbl 0x80117324,%eax
80108199:	83 e0 e0             	and    $0xffffffe0,%eax
8010819c:	a2 24 73 11 80       	mov    %al,0x80117324
801081a1:	0f b6 05 24 73 11 80 	movzbl 0x80117324,%eax
801081a8:	83 e0 1f             	and    $0x1f,%eax
801081ab:	a2 24 73 11 80       	mov    %al,0x80117324
801081b0:	0f b6 05 25 73 11 80 	movzbl 0x80117325,%eax
801081b7:	83 c8 0f             	or     $0xf,%eax
801081ba:	a2 25 73 11 80       	mov    %al,0x80117325
801081bf:	0f b6 05 25 73 11 80 	movzbl 0x80117325,%eax
801081c6:	83 e0 ef             	and    $0xffffffef,%eax
801081c9:	a2 25 73 11 80       	mov    %al,0x80117325
801081ce:	0f b6 05 25 73 11 80 	movzbl 0x80117325,%eax
801081d5:	83 c8 60             	or     $0x60,%eax
801081d8:	a2 25 73 11 80       	mov    %al,0x80117325
801081dd:	0f b6 05 25 73 11 80 	movzbl 0x80117325,%eax
801081e4:	83 c8 80             	or     $0xffffff80,%eax
801081e7:	a2 25 73 11 80       	mov    %al,0x80117325
801081ec:	a1 b4 d1 10 80       	mov    0x8010d1b4,%eax
801081f1:	c1 e8 10             	shr    $0x10,%eax
801081f4:	66 a3 26 73 11 80    	mov    %ax,0x80117326
  
}
801081fa:	90                   	nop
801081fb:	c9                   	leave  
801081fc:	c3                   	ret    

801081fd <idtinit>:

void
idtinit(void)
{
801081fd:	55                   	push   %ebp
801081fe:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80108200:	68 00 08 00 00       	push   $0x800
80108205:	68 20 71 11 80       	push   $0x80117120
8010820a:	e8 52 fe ff ff       	call   80108061 <lidt>
8010820f:	83 c4 08             	add    $0x8,%esp
}
80108212:	90                   	nop
80108213:	c9                   	leave  
80108214:	c3                   	ret    

80108215 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80108215:	55                   	push   %ebp
80108216:	89 e5                	mov    %esp,%ebp
80108218:	57                   	push   %edi
80108219:	56                   	push   %esi
8010821a:	53                   	push   %ebx
8010821b:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
8010821e:	8b 45 08             	mov    0x8(%ebp),%eax
80108221:	8b 40 30             	mov    0x30(%eax),%eax
80108224:	83 f8 40             	cmp    $0x40,%eax
80108227:	75 3e                	jne    80108267 <trap+0x52>
    if(proc->killed)
80108229:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010822f:	8b 40 24             	mov    0x24(%eax),%eax
80108232:	85 c0                	test   %eax,%eax
80108234:	74 05                	je     8010823b <trap+0x26>
      exit();
80108236:	e8 95 ca ff ff       	call   80104cd0 <exit>
    proc->tf = tf;
8010823b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108241:	8b 55 08             	mov    0x8(%ebp),%edx
80108244:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80108247:	e8 57 ec ff ff       	call   80106ea3 <syscall>
    if(proc->killed)
8010824c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108252:	8b 40 24             	mov    0x24(%eax),%eax
80108255:	85 c0                	test   %eax,%eax
80108257:	0f 84 21 02 00 00    	je     8010847e <trap+0x269>
      exit();
8010825d:	e8 6e ca ff ff       	call   80104cd0 <exit>
    return;
80108262:	e9 17 02 00 00       	jmp    8010847e <trap+0x269>
  }

  switch(tf->trapno){
80108267:	8b 45 08             	mov    0x8(%ebp),%eax
8010826a:	8b 40 30             	mov    0x30(%eax),%eax
8010826d:	83 e8 20             	sub    $0x20,%eax
80108270:	83 f8 1f             	cmp    $0x1f,%eax
80108273:	0f 87 a3 00 00 00    	ja     8010831c <trap+0x107>
80108279:	8b 04 85 88 a8 10 80 	mov    -0x7fef5778(,%eax,4),%eax
80108280:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
   if(cpu->id == 0){
80108282:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108288:	0f b6 00             	movzbl (%eax),%eax
8010828b:	84 c0                	test   %al,%al
8010828d:	75 20                	jne    801082af <trap+0x9a>
      atom_inc((int *)&ticks);   // guaranteed atomic so no lock necessary
8010828f:	83 ec 0c             	sub    $0xc,%esp
80108292:	68 20 79 11 80       	push   $0x80117920
80108297:	e8 b9 fd ff ff       	call   80108055 <atom_inc>
8010829c:	83 c4 10             	add    $0x10,%esp
      wakeup(&ticks);
8010829f:	83 ec 0c             	sub    $0xc,%esp
801082a2:	68 20 79 11 80       	push   $0x80117920
801082a7:	e8 8a d5 ff ff       	call   80105836 <wakeup>
801082ac:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801082af:	e8 0f ae ff ff       	call   801030c3 <lapiceoi>
    break;
801082b4:	e9 1c 01 00 00       	jmp    801083d5 <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801082b9:	e8 18 a6 ff ff       	call   801028d6 <ideintr>
    lapiceoi();
801082be:	e8 00 ae ff ff       	call   801030c3 <lapiceoi>
    break;
801082c3:	e9 0d 01 00 00       	jmp    801083d5 <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801082c8:	e8 f8 ab ff ff       	call   80102ec5 <kbdintr>
    lapiceoi();
801082cd:	e8 f1 ad ff ff       	call   801030c3 <lapiceoi>
    break;
801082d2:	e9 fe 00 00 00       	jmp    801083d5 <trap+0x1c0>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801082d7:	e8 83 03 00 00       	call   8010865f <uartintr>
    lapiceoi();
801082dc:	e8 e2 ad ff ff       	call   801030c3 <lapiceoi>
    break;
801082e1:	e9 ef 00 00 00       	jmp    801083d5 <trap+0x1c0>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801082e6:	8b 45 08             	mov    0x8(%ebp),%eax
801082e9:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801082ec:	8b 45 08             	mov    0x8(%ebp),%eax
801082ef:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801082f3:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
801082f6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801082fc:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801082ff:	0f b6 c0             	movzbl %al,%eax
80108302:	51                   	push   %ecx
80108303:	52                   	push   %edx
80108304:	50                   	push   %eax
80108305:	68 e8 a7 10 80       	push   $0x8010a7e8
8010830a:	e8 b7 80 ff ff       	call   801003c6 <cprintf>
8010830f:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80108312:	e8 ac ad ff ff       	call   801030c3 <lapiceoi>
    break;
80108317:	e9 b9 00 00 00       	jmp    801083d5 <trap+0x1c0>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
8010831c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108322:	85 c0                	test   %eax,%eax
80108324:	74 11                	je     80108337 <trap+0x122>
80108326:	8b 45 08             	mov    0x8(%ebp),%eax
80108329:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010832d:	0f b7 c0             	movzwl %ax,%eax
80108330:	83 e0 03             	and    $0x3,%eax
80108333:	85 c0                	test   %eax,%eax
80108335:	75 40                	jne    80108377 <trap+0x162>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80108337:	e8 4f fd ff ff       	call   8010808b <rcr2>
8010833c:	89 c3                	mov    %eax,%ebx
8010833e:	8b 45 08             	mov    0x8(%ebp),%eax
80108341:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80108344:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010834a:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010834d:	0f b6 d0             	movzbl %al,%edx
80108350:	8b 45 08             	mov    0x8(%ebp),%eax
80108353:	8b 40 30             	mov    0x30(%eax),%eax
80108356:	83 ec 0c             	sub    $0xc,%esp
80108359:	53                   	push   %ebx
8010835a:	51                   	push   %ecx
8010835b:	52                   	push   %edx
8010835c:	50                   	push   %eax
8010835d:	68 0c a8 10 80       	push   $0x8010a80c
80108362:	e8 5f 80 ff ff       	call   801003c6 <cprintf>
80108367:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
8010836a:	83 ec 0c             	sub    $0xc,%esp
8010836d:	68 3e a8 10 80       	push   $0x8010a83e
80108372:	e8 ef 81 ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80108377:	e8 0f fd ff ff       	call   8010808b <rcr2>
8010837c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010837f:	8b 45 08             	mov    0x8(%ebp),%eax
80108382:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80108385:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010838b:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010838e:	0f b6 d8             	movzbl %al,%ebx
80108391:	8b 45 08             	mov    0x8(%ebp),%eax
80108394:	8b 48 34             	mov    0x34(%eax),%ecx
80108397:	8b 45 08             	mov    0x8(%ebp),%eax
8010839a:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010839d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801083a3:	8d 78 6c             	lea    0x6c(%eax),%edi
801083a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801083ac:	8b 40 10             	mov    0x10(%eax),%eax
801083af:	ff 75 e4             	pushl  -0x1c(%ebp)
801083b2:	56                   	push   %esi
801083b3:	53                   	push   %ebx
801083b4:	51                   	push   %ecx
801083b5:	52                   	push   %edx
801083b6:	57                   	push   %edi
801083b7:	50                   	push   %eax
801083b8:	68 44 a8 10 80       	push   $0x8010a844
801083bd:	e8 04 80 ff ff       	call   801003c6 <cprintf>
801083c2:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
801083c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801083cb:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801083d2:	eb 01                	jmp    801083d5 <trap+0x1c0>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801083d4:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801083d5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801083db:	85 c0                	test   %eax,%eax
801083dd:	74 24                	je     80108403 <trap+0x1ee>
801083df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801083e5:	8b 40 24             	mov    0x24(%eax),%eax
801083e8:	85 c0                	test   %eax,%eax
801083ea:	74 17                	je     80108403 <trap+0x1ee>
801083ec:	8b 45 08             	mov    0x8(%ebp),%eax
801083ef:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801083f3:	0f b7 c0             	movzwl %ax,%eax
801083f6:	83 e0 03             	and    $0x3,%eax
801083f9:	83 f8 03             	cmp    $0x3,%eax
801083fc:	75 05                	jne    80108403 <trap+0x1ee>
    exit();
801083fe:	e8 cd c8 ff ff       	call   80104cd0 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
80108403:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108409:	85 c0                	test   %eax,%eax
8010840b:	74 41                	je     8010844e <trap+0x239>
8010840d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108413:	8b 40 0c             	mov    0xc(%eax),%eax
80108416:	83 f8 04             	cmp    $0x4,%eax
80108419:	75 33                	jne    8010844e <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
8010841b:	8b 45 08             	mov    0x8(%ebp),%eax
8010841e:	8b 40 30             	mov    0x30(%eax),%eax
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
80108421:	83 f8 20             	cmp    $0x20,%eax
80108424:	75 28                	jne    8010844e <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
80108426:	8b 0d 20 79 11 80    	mov    0x80117920,%ecx
8010842c:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
80108431:	89 c8                	mov    %ecx,%eax
80108433:	f7 e2                	mul    %edx
80108435:	c1 ea 03             	shr    $0x3,%edx
80108438:	89 d0                	mov    %edx,%eax
8010843a:	c1 e0 02             	shl    $0x2,%eax
8010843d:	01 d0                	add    %edx,%eax
8010843f:	01 c0                	add    %eax,%eax
80108441:	29 c1                	sub    %eax,%ecx
80108443:	89 ca                	mov    %ecx,%edx
80108445:	85 d2                	test   %edx,%edx
80108447:	75 05                	jne    8010844e <trap+0x239>
    yield();
80108449:	e8 dd cf ff ff       	call   8010542b <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010844e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108454:	85 c0                	test   %eax,%eax
80108456:	74 27                	je     8010847f <trap+0x26a>
80108458:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010845e:	8b 40 24             	mov    0x24(%eax),%eax
80108461:	85 c0                	test   %eax,%eax
80108463:	74 1a                	je     8010847f <trap+0x26a>
80108465:	8b 45 08             	mov    0x8(%ebp),%eax
80108468:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010846c:	0f b7 c0             	movzwl %ax,%eax
8010846f:	83 e0 03             	and    $0x3,%eax
80108472:	83 f8 03             	cmp    $0x3,%eax
80108475:	75 08                	jne    8010847f <trap+0x26a>
    exit();
80108477:	e8 54 c8 ff ff       	call   80104cd0 <exit>
8010847c:	eb 01                	jmp    8010847f <trap+0x26a>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
8010847e:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
8010847f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108482:	5b                   	pop    %ebx
80108483:	5e                   	pop    %esi
80108484:	5f                   	pop    %edi
80108485:	5d                   	pop    %ebp
80108486:	c3                   	ret    

80108487 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80108487:	55                   	push   %ebp
80108488:	89 e5                	mov    %esp,%ebp
8010848a:	83 ec 14             	sub    $0x14,%esp
8010848d:	8b 45 08             	mov    0x8(%ebp),%eax
80108490:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108494:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108498:	89 c2                	mov    %eax,%edx
8010849a:	ec                   	in     (%dx),%al
8010849b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010849e:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801084a2:	c9                   	leave  
801084a3:	c3                   	ret    

801084a4 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801084a4:	55                   	push   %ebp
801084a5:	89 e5                	mov    %esp,%ebp
801084a7:	83 ec 08             	sub    $0x8,%esp
801084aa:	8b 55 08             	mov    0x8(%ebp),%edx
801084ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801084b0:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801084b4:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801084b7:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801084bb:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801084bf:	ee                   	out    %al,(%dx)
}
801084c0:	90                   	nop
801084c1:	c9                   	leave  
801084c2:	c3                   	ret    

801084c3 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801084c3:	55                   	push   %ebp
801084c4:	89 e5                	mov    %esp,%ebp
801084c6:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801084c9:	6a 00                	push   $0x0
801084cb:	68 fa 03 00 00       	push   $0x3fa
801084d0:	e8 cf ff ff ff       	call   801084a4 <outb>
801084d5:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801084d8:	68 80 00 00 00       	push   $0x80
801084dd:	68 fb 03 00 00       	push   $0x3fb
801084e2:	e8 bd ff ff ff       	call   801084a4 <outb>
801084e7:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801084ea:	6a 0c                	push   $0xc
801084ec:	68 f8 03 00 00       	push   $0x3f8
801084f1:	e8 ae ff ff ff       	call   801084a4 <outb>
801084f6:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801084f9:	6a 00                	push   $0x0
801084fb:	68 f9 03 00 00       	push   $0x3f9
80108500:	e8 9f ff ff ff       	call   801084a4 <outb>
80108505:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80108508:	6a 03                	push   $0x3
8010850a:	68 fb 03 00 00       	push   $0x3fb
8010850f:	e8 90 ff ff ff       	call   801084a4 <outb>
80108514:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80108517:	6a 00                	push   $0x0
80108519:	68 fc 03 00 00       	push   $0x3fc
8010851e:	e8 81 ff ff ff       	call   801084a4 <outb>
80108523:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80108526:	6a 01                	push   $0x1
80108528:	68 f9 03 00 00       	push   $0x3f9
8010852d:	e8 72 ff ff ff       	call   801084a4 <outb>
80108532:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80108535:	68 fd 03 00 00       	push   $0x3fd
8010853a:	e8 48 ff ff ff       	call   80108487 <inb>
8010853f:	83 c4 04             	add    $0x4,%esp
80108542:	3c ff                	cmp    $0xff,%al
80108544:	74 6e                	je     801085b4 <uartinit+0xf1>
    return;
  uart = 1;
80108546:	c7 05 6c d6 10 80 01 	movl   $0x1,0x8010d66c
8010854d:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80108550:	68 fa 03 00 00       	push   $0x3fa
80108555:	e8 2d ff ff ff       	call   80108487 <inb>
8010855a:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
8010855d:	68 f8 03 00 00       	push   $0x3f8
80108562:	e8 20 ff ff ff       	call   80108487 <inb>
80108567:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
8010856a:	83 ec 0c             	sub    $0xc,%esp
8010856d:	6a 04                	push   $0x4
8010856f:	e8 55 ba ff ff       	call   80103fc9 <picenable>
80108574:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80108577:	83 ec 08             	sub    $0x8,%esp
8010857a:	6a 00                	push   $0x0
8010857c:	6a 04                	push   $0x4
8010857e:	e8 f5 a5 ff ff       	call   80102b78 <ioapicenable>
80108583:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80108586:	c7 45 f4 08 a9 10 80 	movl   $0x8010a908,-0xc(%ebp)
8010858d:	eb 19                	jmp    801085a8 <uartinit+0xe5>
    uartputc(*p);
8010858f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108592:	0f b6 00             	movzbl (%eax),%eax
80108595:	0f be c0             	movsbl %al,%eax
80108598:	83 ec 0c             	sub    $0xc,%esp
8010859b:	50                   	push   %eax
8010859c:	e8 16 00 00 00       	call   801085b7 <uartputc>
801085a1:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801085a4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801085a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ab:	0f b6 00             	movzbl (%eax),%eax
801085ae:	84 c0                	test   %al,%al
801085b0:	75 dd                	jne    8010858f <uartinit+0xcc>
801085b2:	eb 01                	jmp    801085b5 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
801085b4:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
801085b5:	c9                   	leave  
801085b6:	c3                   	ret    

801085b7 <uartputc>:

void
uartputc(int c)
{
801085b7:	55                   	push   %ebp
801085b8:	89 e5                	mov    %esp,%ebp
801085ba:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801085bd:	a1 6c d6 10 80       	mov    0x8010d66c,%eax
801085c2:	85 c0                	test   %eax,%eax
801085c4:	74 53                	je     80108619 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801085c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801085cd:	eb 11                	jmp    801085e0 <uartputc+0x29>
    microdelay(10);
801085cf:	83 ec 0c             	sub    $0xc,%esp
801085d2:	6a 0a                	push   $0xa
801085d4:	e8 05 ab ff ff       	call   801030de <microdelay>
801085d9:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801085dc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801085e0:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801085e4:	7f 1a                	jg     80108600 <uartputc+0x49>
801085e6:	83 ec 0c             	sub    $0xc,%esp
801085e9:	68 fd 03 00 00       	push   $0x3fd
801085ee:	e8 94 fe ff ff       	call   80108487 <inb>
801085f3:	83 c4 10             	add    $0x10,%esp
801085f6:	0f b6 c0             	movzbl %al,%eax
801085f9:	83 e0 20             	and    $0x20,%eax
801085fc:	85 c0                	test   %eax,%eax
801085fe:	74 cf                	je     801085cf <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80108600:	8b 45 08             	mov    0x8(%ebp),%eax
80108603:	0f b6 c0             	movzbl %al,%eax
80108606:	83 ec 08             	sub    $0x8,%esp
80108609:	50                   	push   %eax
8010860a:	68 f8 03 00 00       	push   $0x3f8
8010860f:	e8 90 fe ff ff       	call   801084a4 <outb>
80108614:	83 c4 10             	add    $0x10,%esp
80108617:	eb 01                	jmp    8010861a <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80108619:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
8010861a:	c9                   	leave  
8010861b:	c3                   	ret    

8010861c <uartgetc>:

static int
uartgetc(void)
{
8010861c:	55                   	push   %ebp
8010861d:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010861f:	a1 6c d6 10 80       	mov    0x8010d66c,%eax
80108624:	85 c0                	test   %eax,%eax
80108626:	75 07                	jne    8010862f <uartgetc+0x13>
    return -1;
80108628:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010862d:	eb 2e                	jmp    8010865d <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
8010862f:	68 fd 03 00 00       	push   $0x3fd
80108634:	e8 4e fe ff ff       	call   80108487 <inb>
80108639:	83 c4 04             	add    $0x4,%esp
8010863c:	0f b6 c0             	movzbl %al,%eax
8010863f:	83 e0 01             	and    $0x1,%eax
80108642:	85 c0                	test   %eax,%eax
80108644:	75 07                	jne    8010864d <uartgetc+0x31>
    return -1;
80108646:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010864b:	eb 10                	jmp    8010865d <uartgetc+0x41>
  return inb(COM1+0);
8010864d:	68 f8 03 00 00       	push   $0x3f8
80108652:	e8 30 fe ff ff       	call   80108487 <inb>
80108657:	83 c4 04             	add    $0x4,%esp
8010865a:	0f b6 c0             	movzbl %al,%eax
}
8010865d:	c9                   	leave  
8010865e:	c3                   	ret    

8010865f <uartintr>:

void
uartintr(void)
{
8010865f:	55                   	push   %ebp
80108660:	89 e5                	mov    %esp,%ebp
80108662:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80108665:	83 ec 0c             	sub    $0xc,%esp
80108668:	68 1c 86 10 80       	push   $0x8010861c
8010866d:	e8 87 81 ff ff       	call   801007f9 <consoleintr>
80108672:	83 c4 10             	add    $0x10,%esp
}
80108675:	90                   	nop
80108676:	c9                   	leave  
80108677:	c3                   	ret    

80108678 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80108678:	6a 00                	push   $0x0
  pushl $0
8010867a:	6a 00                	push   $0x0
  jmp alltraps
8010867c:	e9 a9 f9 ff ff       	jmp    8010802a <alltraps>

80108681 <vector1>:
.globl vector1
vector1:
  pushl $0
80108681:	6a 00                	push   $0x0
  pushl $1
80108683:	6a 01                	push   $0x1
  jmp alltraps
80108685:	e9 a0 f9 ff ff       	jmp    8010802a <alltraps>

8010868a <vector2>:
.globl vector2
vector2:
  pushl $0
8010868a:	6a 00                	push   $0x0
  pushl $2
8010868c:	6a 02                	push   $0x2
  jmp alltraps
8010868e:	e9 97 f9 ff ff       	jmp    8010802a <alltraps>

80108693 <vector3>:
.globl vector3
vector3:
  pushl $0
80108693:	6a 00                	push   $0x0
  pushl $3
80108695:	6a 03                	push   $0x3
  jmp alltraps
80108697:	e9 8e f9 ff ff       	jmp    8010802a <alltraps>

8010869c <vector4>:
.globl vector4
vector4:
  pushl $0
8010869c:	6a 00                	push   $0x0
  pushl $4
8010869e:	6a 04                	push   $0x4
  jmp alltraps
801086a0:	e9 85 f9 ff ff       	jmp    8010802a <alltraps>

801086a5 <vector5>:
.globl vector5
vector5:
  pushl $0
801086a5:	6a 00                	push   $0x0
  pushl $5
801086a7:	6a 05                	push   $0x5
  jmp alltraps
801086a9:	e9 7c f9 ff ff       	jmp    8010802a <alltraps>

801086ae <vector6>:
.globl vector6
vector6:
  pushl $0
801086ae:	6a 00                	push   $0x0
  pushl $6
801086b0:	6a 06                	push   $0x6
  jmp alltraps
801086b2:	e9 73 f9 ff ff       	jmp    8010802a <alltraps>

801086b7 <vector7>:
.globl vector7
vector7:
  pushl $0
801086b7:	6a 00                	push   $0x0
  pushl $7
801086b9:	6a 07                	push   $0x7
  jmp alltraps
801086bb:	e9 6a f9 ff ff       	jmp    8010802a <alltraps>

801086c0 <vector8>:
.globl vector8
vector8:
  pushl $8
801086c0:	6a 08                	push   $0x8
  jmp alltraps
801086c2:	e9 63 f9 ff ff       	jmp    8010802a <alltraps>

801086c7 <vector9>:
.globl vector9
vector9:
  pushl $0
801086c7:	6a 00                	push   $0x0
  pushl $9
801086c9:	6a 09                	push   $0x9
  jmp alltraps
801086cb:	e9 5a f9 ff ff       	jmp    8010802a <alltraps>

801086d0 <vector10>:
.globl vector10
vector10:
  pushl $10
801086d0:	6a 0a                	push   $0xa
  jmp alltraps
801086d2:	e9 53 f9 ff ff       	jmp    8010802a <alltraps>

801086d7 <vector11>:
.globl vector11
vector11:
  pushl $11
801086d7:	6a 0b                	push   $0xb
  jmp alltraps
801086d9:	e9 4c f9 ff ff       	jmp    8010802a <alltraps>

801086de <vector12>:
.globl vector12
vector12:
  pushl $12
801086de:	6a 0c                	push   $0xc
  jmp alltraps
801086e0:	e9 45 f9 ff ff       	jmp    8010802a <alltraps>

801086e5 <vector13>:
.globl vector13
vector13:
  pushl $13
801086e5:	6a 0d                	push   $0xd
  jmp alltraps
801086e7:	e9 3e f9 ff ff       	jmp    8010802a <alltraps>

801086ec <vector14>:
.globl vector14
vector14:
  pushl $14
801086ec:	6a 0e                	push   $0xe
  jmp alltraps
801086ee:	e9 37 f9 ff ff       	jmp    8010802a <alltraps>

801086f3 <vector15>:
.globl vector15
vector15:
  pushl $0
801086f3:	6a 00                	push   $0x0
  pushl $15
801086f5:	6a 0f                	push   $0xf
  jmp alltraps
801086f7:	e9 2e f9 ff ff       	jmp    8010802a <alltraps>

801086fc <vector16>:
.globl vector16
vector16:
  pushl $0
801086fc:	6a 00                	push   $0x0
  pushl $16
801086fe:	6a 10                	push   $0x10
  jmp alltraps
80108700:	e9 25 f9 ff ff       	jmp    8010802a <alltraps>

80108705 <vector17>:
.globl vector17
vector17:
  pushl $17
80108705:	6a 11                	push   $0x11
  jmp alltraps
80108707:	e9 1e f9 ff ff       	jmp    8010802a <alltraps>

8010870c <vector18>:
.globl vector18
vector18:
  pushl $0
8010870c:	6a 00                	push   $0x0
  pushl $18
8010870e:	6a 12                	push   $0x12
  jmp alltraps
80108710:	e9 15 f9 ff ff       	jmp    8010802a <alltraps>

80108715 <vector19>:
.globl vector19
vector19:
  pushl $0
80108715:	6a 00                	push   $0x0
  pushl $19
80108717:	6a 13                	push   $0x13
  jmp alltraps
80108719:	e9 0c f9 ff ff       	jmp    8010802a <alltraps>

8010871e <vector20>:
.globl vector20
vector20:
  pushl $0
8010871e:	6a 00                	push   $0x0
  pushl $20
80108720:	6a 14                	push   $0x14
  jmp alltraps
80108722:	e9 03 f9 ff ff       	jmp    8010802a <alltraps>

80108727 <vector21>:
.globl vector21
vector21:
  pushl $0
80108727:	6a 00                	push   $0x0
  pushl $21
80108729:	6a 15                	push   $0x15
  jmp alltraps
8010872b:	e9 fa f8 ff ff       	jmp    8010802a <alltraps>

80108730 <vector22>:
.globl vector22
vector22:
  pushl $0
80108730:	6a 00                	push   $0x0
  pushl $22
80108732:	6a 16                	push   $0x16
  jmp alltraps
80108734:	e9 f1 f8 ff ff       	jmp    8010802a <alltraps>

80108739 <vector23>:
.globl vector23
vector23:
  pushl $0
80108739:	6a 00                	push   $0x0
  pushl $23
8010873b:	6a 17                	push   $0x17
  jmp alltraps
8010873d:	e9 e8 f8 ff ff       	jmp    8010802a <alltraps>

80108742 <vector24>:
.globl vector24
vector24:
  pushl $0
80108742:	6a 00                	push   $0x0
  pushl $24
80108744:	6a 18                	push   $0x18
  jmp alltraps
80108746:	e9 df f8 ff ff       	jmp    8010802a <alltraps>

8010874b <vector25>:
.globl vector25
vector25:
  pushl $0
8010874b:	6a 00                	push   $0x0
  pushl $25
8010874d:	6a 19                	push   $0x19
  jmp alltraps
8010874f:	e9 d6 f8 ff ff       	jmp    8010802a <alltraps>

80108754 <vector26>:
.globl vector26
vector26:
  pushl $0
80108754:	6a 00                	push   $0x0
  pushl $26
80108756:	6a 1a                	push   $0x1a
  jmp alltraps
80108758:	e9 cd f8 ff ff       	jmp    8010802a <alltraps>

8010875d <vector27>:
.globl vector27
vector27:
  pushl $0
8010875d:	6a 00                	push   $0x0
  pushl $27
8010875f:	6a 1b                	push   $0x1b
  jmp alltraps
80108761:	e9 c4 f8 ff ff       	jmp    8010802a <alltraps>

80108766 <vector28>:
.globl vector28
vector28:
  pushl $0
80108766:	6a 00                	push   $0x0
  pushl $28
80108768:	6a 1c                	push   $0x1c
  jmp alltraps
8010876a:	e9 bb f8 ff ff       	jmp    8010802a <alltraps>

8010876f <vector29>:
.globl vector29
vector29:
  pushl $0
8010876f:	6a 00                	push   $0x0
  pushl $29
80108771:	6a 1d                	push   $0x1d
  jmp alltraps
80108773:	e9 b2 f8 ff ff       	jmp    8010802a <alltraps>

80108778 <vector30>:
.globl vector30
vector30:
  pushl $0
80108778:	6a 00                	push   $0x0
  pushl $30
8010877a:	6a 1e                	push   $0x1e
  jmp alltraps
8010877c:	e9 a9 f8 ff ff       	jmp    8010802a <alltraps>

80108781 <vector31>:
.globl vector31
vector31:
  pushl $0
80108781:	6a 00                	push   $0x0
  pushl $31
80108783:	6a 1f                	push   $0x1f
  jmp alltraps
80108785:	e9 a0 f8 ff ff       	jmp    8010802a <alltraps>

8010878a <vector32>:
.globl vector32
vector32:
  pushl $0
8010878a:	6a 00                	push   $0x0
  pushl $32
8010878c:	6a 20                	push   $0x20
  jmp alltraps
8010878e:	e9 97 f8 ff ff       	jmp    8010802a <alltraps>

80108793 <vector33>:
.globl vector33
vector33:
  pushl $0
80108793:	6a 00                	push   $0x0
  pushl $33
80108795:	6a 21                	push   $0x21
  jmp alltraps
80108797:	e9 8e f8 ff ff       	jmp    8010802a <alltraps>

8010879c <vector34>:
.globl vector34
vector34:
  pushl $0
8010879c:	6a 00                	push   $0x0
  pushl $34
8010879e:	6a 22                	push   $0x22
  jmp alltraps
801087a0:	e9 85 f8 ff ff       	jmp    8010802a <alltraps>

801087a5 <vector35>:
.globl vector35
vector35:
  pushl $0
801087a5:	6a 00                	push   $0x0
  pushl $35
801087a7:	6a 23                	push   $0x23
  jmp alltraps
801087a9:	e9 7c f8 ff ff       	jmp    8010802a <alltraps>

801087ae <vector36>:
.globl vector36
vector36:
  pushl $0
801087ae:	6a 00                	push   $0x0
  pushl $36
801087b0:	6a 24                	push   $0x24
  jmp alltraps
801087b2:	e9 73 f8 ff ff       	jmp    8010802a <alltraps>

801087b7 <vector37>:
.globl vector37
vector37:
  pushl $0
801087b7:	6a 00                	push   $0x0
  pushl $37
801087b9:	6a 25                	push   $0x25
  jmp alltraps
801087bb:	e9 6a f8 ff ff       	jmp    8010802a <alltraps>

801087c0 <vector38>:
.globl vector38
vector38:
  pushl $0
801087c0:	6a 00                	push   $0x0
  pushl $38
801087c2:	6a 26                	push   $0x26
  jmp alltraps
801087c4:	e9 61 f8 ff ff       	jmp    8010802a <alltraps>

801087c9 <vector39>:
.globl vector39
vector39:
  pushl $0
801087c9:	6a 00                	push   $0x0
  pushl $39
801087cb:	6a 27                	push   $0x27
  jmp alltraps
801087cd:	e9 58 f8 ff ff       	jmp    8010802a <alltraps>

801087d2 <vector40>:
.globl vector40
vector40:
  pushl $0
801087d2:	6a 00                	push   $0x0
  pushl $40
801087d4:	6a 28                	push   $0x28
  jmp alltraps
801087d6:	e9 4f f8 ff ff       	jmp    8010802a <alltraps>

801087db <vector41>:
.globl vector41
vector41:
  pushl $0
801087db:	6a 00                	push   $0x0
  pushl $41
801087dd:	6a 29                	push   $0x29
  jmp alltraps
801087df:	e9 46 f8 ff ff       	jmp    8010802a <alltraps>

801087e4 <vector42>:
.globl vector42
vector42:
  pushl $0
801087e4:	6a 00                	push   $0x0
  pushl $42
801087e6:	6a 2a                	push   $0x2a
  jmp alltraps
801087e8:	e9 3d f8 ff ff       	jmp    8010802a <alltraps>

801087ed <vector43>:
.globl vector43
vector43:
  pushl $0
801087ed:	6a 00                	push   $0x0
  pushl $43
801087ef:	6a 2b                	push   $0x2b
  jmp alltraps
801087f1:	e9 34 f8 ff ff       	jmp    8010802a <alltraps>

801087f6 <vector44>:
.globl vector44
vector44:
  pushl $0
801087f6:	6a 00                	push   $0x0
  pushl $44
801087f8:	6a 2c                	push   $0x2c
  jmp alltraps
801087fa:	e9 2b f8 ff ff       	jmp    8010802a <alltraps>

801087ff <vector45>:
.globl vector45
vector45:
  pushl $0
801087ff:	6a 00                	push   $0x0
  pushl $45
80108801:	6a 2d                	push   $0x2d
  jmp alltraps
80108803:	e9 22 f8 ff ff       	jmp    8010802a <alltraps>

80108808 <vector46>:
.globl vector46
vector46:
  pushl $0
80108808:	6a 00                	push   $0x0
  pushl $46
8010880a:	6a 2e                	push   $0x2e
  jmp alltraps
8010880c:	e9 19 f8 ff ff       	jmp    8010802a <alltraps>

80108811 <vector47>:
.globl vector47
vector47:
  pushl $0
80108811:	6a 00                	push   $0x0
  pushl $47
80108813:	6a 2f                	push   $0x2f
  jmp alltraps
80108815:	e9 10 f8 ff ff       	jmp    8010802a <alltraps>

8010881a <vector48>:
.globl vector48
vector48:
  pushl $0
8010881a:	6a 00                	push   $0x0
  pushl $48
8010881c:	6a 30                	push   $0x30
  jmp alltraps
8010881e:	e9 07 f8 ff ff       	jmp    8010802a <alltraps>

80108823 <vector49>:
.globl vector49
vector49:
  pushl $0
80108823:	6a 00                	push   $0x0
  pushl $49
80108825:	6a 31                	push   $0x31
  jmp alltraps
80108827:	e9 fe f7 ff ff       	jmp    8010802a <alltraps>

8010882c <vector50>:
.globl vector50
vector50:
  pushl $0
8010882c:	6a 00                	push   $0x0
  pushl $50
8010882e:	6a 32                	push   $0x32
  jmp alltraps
80108830:	e9 f5 f7 ff ff       	jmp    8010802a <alltraps>

80108835 <vector51>:
.globl vector51
vector51:
  pushl $0
80108835:	6a 00                	push   $0x0
  pushl $51
80108837:	6a 33                	push   $0x33
  jmp alltraps
80108839:	e9 ec f7 ff ff       	jmp    8010802a <alltraps>

8010883e <vector52>:
.globl vector52
vector52:
  pushl $0
8010883e:	6a 00                	push   $0x0
  pushl $52
80108840:	6a 34                	push   $0x34
  jmp alltraps
80108842:	e9 e3 f7 ff ff       	jmp    8010802a <alltraps>

80108847 <vector53>:
.globl vector53
vector53:
  pushl $0
80108847:	6a 00                	push   $0x0
  pushl $53
80108849:	6a 35                	push   $0x35
  jmp alltraps
8010884b:	e9 da f7 ff ff       	jmp    8010802a <alltraps>

80108850 <vector54>:
.globl vector54
vector54:
  pushl $0
80108850:	6a 00                	push   $0x0
  pushl $54
80108852:	6a 36                	push   $0x36
  jmp alltraps
80108854:	e9 d1 f7 ff ff       	jmp    8010802a <alltraps>

80108859 <vector55>:
.globl vector55
vector55:
  pushl $0
80108859:	6a 00                	push   $0x0
  pushl $55
8010885b:	6a 37                	push   $0x37
  jmp alltraps
8010885d:	e9 c8 f7 ff ff       	jmp    8010802a <alltraps>

80108862 <vector56>:
.globl vector56
vector56:
  pushl $0
80108862:	6a 00                	push   $0x0
  pushl $56
80108864:	6a 38                	push   $0x38
  jmp alltraps
80108866:	e9 bf f7 ff ff       	jmp    8010802a <alltraps>

8010886b <vector57>:
.globl vector57
vector57:
  pushl $0
8010886b:	6a 00                	push   $0x0
  pushl $57
8010886d:	6a 39                	push   $0x39
  jmp alltraps
8010886f:	e9 b6 f7 ff ff       	jmp    8010802a <alltraps>

80108874 <vector58>:
.globl vector58
vector58:
  pushl $0
80108874:	6a 00                	push   $0x0
  pushl $58
80108876:	6a 3a                	push   $0x3a
  jmp alltraps
80108878:	e9 ad f7 ff ff       	jmp    8010802a <alltraps>

8010887d <vector59>:
.globl vector59
vector59:
  pushl $0
8010887d:	6a 00                	push   $0x0
  pushl $59
8010887f:	6a 3b                	push   $0x3b
  jmp alltraps
80108881:	e9 a4 f7 ff ff       	jmp    8010802a <alltraps>

80108886 <vector60>:
.globl vector60
vector60:
  pushl $0
80108886:	6a 00                	push   $0x0
  pushl $60
80108888:	6a 3c                	push   $0x3c
  jmp alltraps
8010888a:	e9 9b f7 ff ff       	jmp    8010802a <alltraps>

8010888f <vector61>:
.globl vector61
vector61:
  pushl $0
8010888f:	6a 00                	push   $0x0
  pushl $61
80108891:	6a 3d                	push   $0x3d
  jmp alltraps
80108893:	e9 92 f7 ff ff       	jmp    8010802a <alltraps>

80108898 <vector62>:
.globl vector62
vector62:
  pushl $0
80108898:	6a 00                	push   $0x0
  pushl $62
8010889a:	6a 3e                	push   $0x3e
  jmp alltraps
8010889c:	e9 89 f7 ff ff       	jmp    8010802a <alltraps>

801088a1 <vector63>:
.globl vector63
vector63:
  pushl $0
801088a1:	6a 00                	push   $0x0
  pushl $63
801088a3:	6a 3f                	push   $0x3f
  jmp alltraps
801088a5:	e9 80 f7 ff ff       	jmp    8010802a <alltraps>

801088aa <vector64>:
.globl vector64
vector64:
  pushl $0
801088aa:	6a 00                	push   $0x0
  pushl $64
801088ac:	6a 40                	push   $0x40
  jmp alltraps
801088ae:	e9 77 f7 ff ff       	jmp    8010802a <alltraps>

801088b3 <vector65>:
.globl vector65
vector65:
  pushl $0
801088b3:	6a 00                	push   $0x0
  pushl $65
801088b5:	6a 41                	push   $0x41
  jmp alltraps
801088b7:	e9 6e f7 ff ff       	jmp    8010802a <alltraps>

801088bc <vector66>:
.globl vector66
vector66:
  pushl $0
801088bc:	6a 00                	push   $0x0
  pushl $66
801088be:	6a 42                	push   $0x42
  jmp alltraps
801088c0:	e9 65 f7 ff ff       	jmp    8010802a <alltraps>

801088c5 <vector67>:
.globl vector67
vector67:
  pushl $0
801088c5:	6a 00                	push   $0x0
  pushl $67
801088c7:	6a 43                	push   $0x43
  jmp alltraps
801088c9:	e9 5c f7 ff ff       	jmp    8010802a <alltraps>

801088ce <vector68>:
.globl vector68
vector68:
  pushl $0
801088ce:	6a 00                	push   $0x0
  pushl $68
801088d0:	6a 44                	push   $0x44
  jmp alltraps
801088d2:	e9 53 f7 ff ff       	jmp    8010802a <alltraps>

801088d7 <vector69>:
.globl vector69
vector69:
  pushl $0
801088d7:	6a 00                	push   $0x0
  pushl $69
801088d9:	6a 45                	push   $0x45
  jmp alltraps
801088db:	e9 4a f7 ff ff       	jmp    8010802a <alltraps>

801088e0 <vector70>:
.globl vector70
vector70:
  pushl $0
801088e0:	6a 00                	push   $0x0
  pushl $70
801088e2:	6a 46                	push   $0x46
  jmp alltraps
801088e4:	e9 41 f7 ff ff       	jmp    8010802a <alltraps>

801088e9 <vector71>:
.globl vector71
vector71:
  pushl $0
801088e9:	6a 00                	push   $0x0
  pushl $71
801088eb:	6a 47                	push   $0x47
  jmp alltraps
801088ed:	e9 38 f7 ff ff       	jmp    8010802a <alltraps>

801088f2 <vector72>:
.globl vector72
vector72:
  pushl $0
801088f2:	6a 00                	push   $0x0
  pushl $72
801088f4:	6a 48                	push   $0x48
  jmp alltraps
801088f6:	e9 2f f7 ff ff       	jmp    8010802a <alltraps>

801088fb <vector73>:
.globl vector73
vector73:
  pushl $0
801088fb:	6a 00                	push   $0x0
  pushl $73
801088fd:	6a 49                	push   $0x49
  jmp alltraps
801088ff:	e9 26 f7 ff ff       	jmp    8010802a <alltraps>

80108904 <vector74>:
.globl vector74
vector74:
  pushl $0
80108904:	6a 00                	push   $0x0
  pushl $74
80108906:	6a 4a                	push   $0x4a
  jmp alltraps
80108908:	e9 1d f7 ff ff       	jmp    8010802a <alltraps>

8010890d <vector75>:
.globl vector75
vector75:
  pushl $0
8010890d:	6a 00                	push   $0x0
  pushl $75
8010890f:	6a 4b                	push   $0x4b
  jmp alltraps
80108911:	e9 14 f7 ff ff       	jmp    8010802a <alltraps>

80108916 <vector76>:
.globl vector76
vector76:
  pushl $0
80108916:	6a 00                	push   $0x0
  pushl $76
80108918:	6a 4c                	push   $0x4c
  jmp alltraps
8010891a:	e9 0b f7 ff ff       	jmp    8010802a <alltraps>

8010891f <vector77>:
.globl vector77
vector77:
  pushl $0
8010891f:	6a 00                	push   $0x0
  pushl $77
80108921:	6a 4d                	push   $0x4d
  jmp alltraps
80108923:	e9 02 f7 ff ff       	jmp    8010802a <alltraps>

80108928 <vector78>:
.globl vector78
vector78:
  pushl $0
80108928:	6a 00                	push   $0x0
  pushl $78
8010892a:	6a 4e                	push   $0x4e
  jmp alltraps
8010892c:	e9 f9 f6 ff ff       	jmp    8010802a <alltraps>

80108931 <vector79>:
.globl vector79
vector79:
  pushl $0
80108931:	6a 00                	push   $0x0
  pushl $79
80108933:	6a 4f                	push   $0x4f
  jmp alltraps
80108935:	e9 f0 f6 ff ff       	jmp    8010802a <alltraps>

8010893a <vector80>:
.globl vector80
vector80:
  pushl $0
8010893a:	6a 00                	push   $0x0
  pushl $80
8010893c:	6a 50                	push   $0x50
  jmp alltraps
8010893e:	e9 e7 f6 ff ff       	jmp    8010802a <alltraps>

80108943 <vector81>:
.globl vector81
vector81:
  pushl $0
80108943:	6a 00                	push   $0x0
  pushl $81
80108945:	6a 51                	push   $0x51
  jmp alltraps
80108947:	e9 de f6 ff ff       	jmp    8010802a <alltraps>

8010894c <vector82>:
.globl vector82
vector82:
  pushl $0
8010894c:	6a 00                	push   $0x0
  pushl $82
8010894e:	6a 52                	push   $0x52
  jmp alltraps
80108950:	e9 d5 f6 ff ff       	jmp    8010802a <alltraps>

80108955 <vector83>:
.globl vector83
vector83:
  pushl $0
80108955:	6a 00                	push   $0x0
  pushl $83
80108957:	6a 53                	push   $0x53
  jmp alltraps
80108959:	e9 cc f6 ff ff       	jmp    8010802a <alltraps>

8010895e <vector84>:
.globl vector84
vector84:
  pushl $0
8010895e:	6a 00                	push   $0x0
  pushl $84
80108960:	6a 54                	push   $0x54
  jmp alltraps
80108962:	e9 c3 f6 ff ff       	jmp    8010802a <alltraps>

80108967 <vector85>:
.globl vector85
vector85:
  pushl $0
80108967:	6a 00                	push   $0x0
  pushl $85
80108969:	6a 55                	push   $0x55
  jmp alltraps
8010896b:	e9 ba f6 ff ff       	jmp    8010802a <alltraps>

80108970 <vector86>:
.globl vector86
vector86:
  pushl $0
80108970:	6a 00                	push   $0x0
  pushl $86
80108972:	6a 56                	push   $0x56
  jmp alltraps
80108974:	e9 b1 f6 ff ff       	jmp    8010802a <alltraps>

80108979 <vector87>:
.globl vector87
vector87:
  pushl $0
80108979:	6a 00                	push   $0x0
  pushl $87
8010897b:	6a 57                	push   $0x57
  jmp alltraps
8010897d:	e9 a8 f6 ff ff       	jmp    8010802a <alltraps>

80108982 <vector88>:
.globl vector88
vector88:
  pushl $0
80108982:	6a 00                	push   $0x0
  pushl $88
80108984:	6a 58                	push   $0x58
  jmp alltraps
80108986:	e9 9f f6 ff ff       	jmp    8010802a <alltraps>

8010898b <vector89>:
.globl vector89
vector89:
  pushl $0
8010898b:	6a 00                	push   $0x0
  pushl $89
8010898d:	6a 59                	push   $0x59
  jmp alltraps
8010898f:	e9 96 f6 ff ff       	jmp    8010802a <alltraps>

80108994 <vector90>:
.globl vector90
vector90:
  pushl $0
80108994:	6a 00                	push   $0x0
  pushl $90
80108996:	6a 5a                	push   $0x5a
  jmp alltraps
80108998:	e9 8d f6 ff ff       	jmp    8010802a <alltraps>

8010899d <vector91>:
.globl vector91
vector91:
  pushl $0
8010899d:	6a 00                	push   $0x0
  pushl $91
8010899f:	6a 5b                	push   $0x5b
  jmp alltraps
801089a1:	e9 84 f6 ff ff       	jmp    8010802a <alltraps>

801089a6 <vector92>:
.globl vector92
vector92:
  pushl $0
801089a6:	6a 00                	push   $0x0
  pushl $92
801089a8:	6a 5c                	push   $0x5c
  jmp alltraps
801089aa:	e9 7b f6 ff ff       	jmp    8010802a <alltraps>

801089af <vector93>:
.globl vector93
vector93:
  pushl $0
801089af:	6a 00                	push   $0x0
  pushl $93
801089b1:	6a 5d                	push   $0x5d
  jmp alltraps
801089b3:	e9 72 f6 ff ff       	jmp    8010802a <alltraps>

801089b8 <vector94>:
.globl vector94
vector94:
  pushl $0
801089b8:	6a 00                	push   $0x0
  pushl $94
801089ba:	6a 5e                	push   $0x5e
  jmp alltraps
801089bc:	e9 69 f6 ff ff       	jmp    8010802a <alltraps>

801089c1 <vector95>:
.globl vector95
vector95:
  pushl $0
801089c1:	6a 00                	push   $0x0
  pushl $95
801089c3:	6a 5f                	push   $0x5f
  jmp alltraps
801089c5:	e9 60 f6 ff ff       	jmp    8010802a <alltraps>

801089ca <vector96>:
.globl vector96
vector96:
  pushl $0
801089ca:	6a 00                	push   $0x0
  pushl $96
801089cc:	6a 60                	push   $0x60
  jmp alltraps
801089ce:	e9 57 f6 ff ff       	jmp    8010802a <alltraps>

801089d3 <vector97>:
.globl vector97
vector97:
  pushl $0
801089d3:	6a 00                	push   $0x0
  pushl $97
801089d5:	6a 61                	push   $0x61
  jmp alltraps
801089d7:	e9 4e f6 ff ff       	jmp    8010802a <alltraps>

801089dc <vector98>:
.globl vector98
vector98:
  pushl $0
801089dc:	6a 00                	push   $0x0
  pushl $98
801089de:	6a 62                	push   $0x62
  jmp alltraps
801089e0:	e9 45 f6 ff ff       	jmp    8010802a <alltraps>

801089e5 <vector99>:
.globl vector99
vector99:
  pushl $0
801089e5:	6a 00                	push   $0x0
  pushl $99
801089e7:	6a 63                	push   $0x63
  jmp alltraps
801089e9:	e9 3c f6 ff ff       	jmp    8010802a <alltraps>

801089ee <vector100>:
.globl vector100
vector100:
  pushl $0
801089ee:	6a 00                	push   $0x0
  pushl $100
801089f0:	6a 64                	push   $0x64
  jmp alltraps
801089f2:	e9 33 f6 ff ff       	jmp    8010802a <alltraps>

801089f7 <vector101>:
.globl vector101
vector101:
  pushl $0
801089f7:	6a 00                	push   $0x0
  pushl $101
801089f9:	6a 65                	push   $0x65
  jmp alltraps
801089fb:	e9 2a f6 ff ff       	jmp    8010802a <alltraps>

80108a00 <vector102>:
.globl vector102
vector102:
  pushl $0
80108a00:	6a 00                	push   $0x0
  pushl $102
80108a02:	6a 66                	push   $0x66
  jmp alltraps
80108a04:	e9 21 f6 ff ff       	jmp    8010802a <alltraps>

80108a09 <vector103>:
.globl vector103
vector103:
  pushl $0
80108a09:	6a 00                	push   $0x0
  pushl $103
80108a0b:	6a 67                	push   $0x67
  jmp alltraps
80108a0d:	e9 18 f6 ff ff       	jmp    8010802a <alltraps>

80108a12 <vector104>:
.globl vector104
vector104:
  pushl $0
80108a12:	6a 00                	push   $0x0
  pushl $104
80108a14:	6a 68                	push   $0x68
  jmp alltraps
80108a16:	e9 0f f6 ff ff       	jmp    8010802a <alltraps>

80108a1b <vector105>:
.globl vector105
vector105:
  pushl $0
80108a1b:	6a 00                	push   $0x0
  pushl $105
80108a1d:	6a 69                	push   $0x69
  jmp alltraps
80108a1f:	e9 06 f6 ff ff       	jmp    8010802a <alltraps>

80108a24 <vector106>:
.globl vector106
vector106:
  pushl $0
80108a24:	6a 00                	push   $0x0
  pushl $106
80108a26:	6a 6a                	push   $0x6a
  jmp alltraps
80108a28:	e9 fd f5 ff ff       	jmp    8010802a <alltraps>

80108a2d <vector107>:
.globl vector107
vector107:
  pushl $0
80108a2d:	6a 00                	push   $0x0
  pushl $107
80108a2f:	6a 6b                	push   $0x6b
  jmp alltraps
80108a31:	e9 f4 f5 ff ff       	jmp    8010802a <alltraps>

80108a36 <vector108>:
.globl vector108
vector108:
  pushl $0
80108a36:	6a 00                	push   $0x0
  pushl $108
80108a38:	6a 6c                	push   $0x6c
  jmp alltraps
80108a3a:	e9 eb f5 ff ff       	jmp    8010802a <alltraps>

80108a3f <vector109>:
.globl vector109
vector109:
  pushl $0
80108a3f:	6a 00                	push   $0x0
  pushl $109
80108a41:	6a 6d                	push   $0x6d
  jmp alltraps
80108a43:	e9 e2 f5 ff ff       	jmp    8010802a <alltraps>

80108a48 <vector110>:
.globl vector110
vector110:
  pushl $0
80108a48:	6a 00                	push   $0x0
  pushl $110
80108a4a:	6a 6e                	push   $0x6e
  jmp alltraps
80108a4c:	e9 d9 f5 ff ff       	jmp    8010802a <alltraps>

80108a51 <vector111>:
.globl vector111
vector111:
  pushl $0
80108a51:	6a 00                	push   $0x0
  pushl $111
80108a53:	6a 6f                	push   $0x6f
  jmp alltraps
80108a55:	e9 d0 f5 ff ff       	jmp    8010802a <alltraps>

80108a5a <vector112>:
.globl vector112
vector112:
  pushl $0
80108a5a:	6a 00                	push   $0x0
  pushl $112
80108a5c:	6a 70                	push   $0x70
  jmp alltraps
80108a5e:	e9 c7 f5 ff ff       	jmp    8010802a <alltraps>

80108a63 <vector113>:
.globl vector113
vector113:
  pushl $0
80108a63:	6a 00                	push   $0x0
  pushl $113
80108a65:	6a 71                	push   $0x71
  jmp alltraps
80108a67:	e9 be f5 ff ff       	jmp    8010802a <alltraps>

80108a6c <vector114>:
.globl vector114
vector114:
  pushl $0
80108a6c:	6a 00                	push   $0x0
  pushl $114
80108a6e:	6a 72                	push   $0x72
  jmp alltraps
80108a70:	e9 b5 f5 ff ff       	jmp    8010802a <alltraps>

80108a75 <vector115>:
.globl vector115
vector115:
  pushl $0
80108a75:	6a 00                	push   $0x0
  pushl $115
80108a77:	6a 73                	push   $0x73
  jmp alltraps
80108a79:	e9 ac f5 ff ff       	jmp    8010802a <alltraps>

80108a7e <vector116>:
.globl vector116
vector116:
  pushl $0
80108a7e:	6a 00                	push   $0x0
  pushl $116
80108a80:	6a 74                	push   $0x74
  jmp alltraps
80108a82:	e9 a3 f5 ff ff       	jmp    8010802a <alltraps>

80108a87 <vector117>:
.globl vector117
vector117:
  pushl $0
80108a87:	6a 00                	push   $0x0
  pushl $117
80108a89:	6a 75                	push   $0x75
  jmp alltraps
80108a8b:	e9 9a f5 ff ff       	jmp    8010802a <alltraps>

80108a90 <vector118>:
.globl vector118
vector118:
  pushl $0
80108a90:	6a 00                	push   $0x0
  pushl $118
80108a92:	6a 76                	push   $0x76
  jmp alltraps
80108a94:	e9 91 f5 ff ff       	jmp    8010802a <alltraps>

80108a99 <vector119>:
.globl vector119
vector119:
  pushl $0
80108a99:	6a 00                	push   $0x0
  pushl $119
80108a9b:	6a 77                	push   $0x77
  jmp alltraps
80108a9d:	e9 88 f5 ff ff       	jmp    8010802a <alltraps>

80108aa2 <vector120>:
.globl vector120
vector120:
  pushl $0
80108aa2:	6a 00                	push   $0x0
  pushl $120
80108aa4:	6a 78                	push   $0x78
  jmp alltraps
80108aa6:	e9 7f f5 ff ff       	jmp    8010802a <alltraps>

80108aab <vector121>:
.globl vector121
vector121:
  pushl $0
80108aab:	6a 00                	push   $0x0
  pushl $121
80108aad:	6a 79                	push   $0x79
  jmp alltraps
80108aaf:	e9 76 f5 ff ff       	jmp    8010802a <alltraps>

80108ab4 <vector122>:
.globl vector122
vector122:
  pushl $0
80108ab4:	6a 00                	push   $0x0
  pushl $122
80108ab6:	6a 7a                	push   $0x7a
  jmp alltraps
80108ab8:	e9 6d f5 ff ff       	jmp    8010802a <alltraps>

80108abd <vector123>:
.globl vector123
vector123:
  pushl $0
80108abd:	6a 00                	push   $0x0
  pushl $123
80108abf:	6a 7b                	push   $0x7b
  jmp alltraps
80108ac1:	e9 64 f5 ff ff       	jmp    8010802a <alltraps>

80108ac6 <vector124>:
.globl vector124
vector124:
  pushl $0
80108ac6:	6a 00                	push   $0x0
  pushl $124
80108ac8:	6a 7c                	push   $0x7c
  jmp alltraps
80108aca:	e9 5b f5 ff ff       	jmp    8010802a <alltraps>

80108acf <vector125>:
.globl vector125
vector125:
  pushl $0
80108acf:	6a 00                	push   $0x0
  pushl $125
80108ad1:	6a 7d                	push   $0x7d
  jmp alltraps
80108ad3:	e9 52 f5 ff ff       	jmp    8010802a <alltraps>

80108ad8 <vector126>:
.globl vector126
vector126:
  pushl $0
80108ad8:	6a 00                	push   $0x0
  pushl $126
80108ada:	6a 7e                	push   $0x7e
  jmp alltraps
80108adc:	e9 49 f5 ff ff       	jmp    8010802a <alltraps>

80108ae1 <vector127>:
.globl vector127
vector127:
  pushl $0
80108ae1:	6a 00                	push   $0x0
  pushl $127
80108ae3:	6a 7f                	push   $0x7f
  jmp alltraps
80108ae5:	e9 40 f5 ff ff       	jmp    8010802a <alltraps>

80108aea <vector128>:
.globl vector128
vector128:
  pushl $0
80108aea:	6a 00                	push   $0x0
  pushl $128
80108aec:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80108af1:	e9 34 f5 ff ff       	jmp    8010802a <alltraps>

80108af6 <vector129>:
.globl vector129
vector129:
  pushl $0
80108af6:	6a 00                	push   $0x0
  pushl $129
80108af8:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80108afd:	e9 28 f5 ff ff       	jmp    8010802a <alltraps>

80108b02 <vector130>:
.globl vector130
vector130:
  pushl $0
80108b02:	6a 00                	push   $0x0
  pushl $130
80108b04:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80108b09:	e9 1c f5 ff ff       	jmp    8010802a <alltraps>

80108b0e <vector131>:
.globl vector131
vector131:
  pushl $0
80108b0e:	6a 00                	push   $0x0
  pushl $131
80108b10:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80108b15:	e9 10 f5 ff ff       	jmp    8010802a <alltraps>

80108b1a <vector132>:
.globl vector132
vector132:
  pushl $0
80108b1a:	6a 00                	push   $0x0
  pushl $132
80108b1c:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80108b21:	e9 04 f5 ff ff       	jmp    8010802a <alltraps>

80108b26 <vector133>:
.globl vector133
vector133:
  pushl $0
80108b26:	6a 00                	push   $0x0
  pushl $133
80108b28:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80108b2d:	e9 f8 f4 ff ff       	jmp    8010802a <alltraps>

80108b32 <vector134>:
.globl vector134
vector134:
  pushl $0
80108b32:	6a 00                	push   $0x0
  pushl $134
80108b34:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80108b39:	e9 ec f4 ff ff       	jmp    8010802a <alltraps>

80108b3e <vector135>:
.globl vector135
vector135:
  pushl $0
80108b3e:	6a 00                	push   $0x0
  pushl $135
80108b40:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80108b45:	e9 e0 f4 ff ff       	jmp    8010802a <alltraps>

80108b4a <vector136>:
.globl vector136
vector136:
  pushl $0
80108b4a:	6a 00                	push   $0x0
  pushl $136
80108b4c:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80108b51:	e9 d4 f4 ff ff       	jmp    8010802a <alltraps>

80108b56 <vector137>:
.globl vector137
vector137:
  pushl $0
80108b56:	6a 00                	push   $0x0
  pushl $137
80108b58:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80108b5d:	e9 c8 f4 ff ff       	jmp    8010802a <alltraps>

80108b62 <vector138>:
.globl vector138
vector138:
  pushl $0
80108b62:	6a 00                	push   $0x0
  pushl $138
80108b64:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80108b69:	e9 bc f4 ff ff       	jmp    8010802a <alltraps>

80108b6e <vector139>:
.globl vector139
vector139:
  pushl $0
80108b6e:	6a 00                	push   $0x0
  pushl $139
80108b70:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80108b75:	e9 b0 f4 ff ff       	jmp    8010802a <alltraps>

80108b7a <vector140>:
.globl vector140
vector140:
  pushl $0
80108b7a:	6a 00                	push   $0x0
  pushl $140
80108b7c:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80108b81:	e9 a4 f4 ff ff       	jmp    8010802a <alltraps>

80108b86 <vector141>:
.globl vector141
vector141:
  pushl $0
80108b86:	6a 00                	push   $0x0
  pushl $141
80108b88:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80108b8d:	e9 98 f4 ff ff       	jmp    8010802a <alltraps>

80108b92 <vector142>:
.globl vector142
vector142:
  pushl $0
80108b92:	6a 00                	push   $0x0
  pushl $142
80108b94:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80108b99:	e9 8c f4 ff ff       	jmp    8010802a <alltraps>

80108b9e <vector143>:
.globl vector143
vector143:
  pushl $0
80108b9e:	6a 00                	push   $0x0
  pushl $143
80108ba0:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80108ba5:	e9 80 f4 ff ff       	jmp    8010802a <alltraps>

80108baa <vector144>:
.globl vector144
vector144:
  pushl $0
80108baa:	6a 00                	push   $0x0
  pushl $144
80108bac:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80108bb1:	e9 74 f4 ff ff       	jmp    8010802a <alltraps>

80108bb6 <vector145>:
.globl vector145
vector145:
  pushl $0
80108bb6:	6a 00                	push   $0x0
  pushl $145
80108bb8:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80108bbd:	e9 68 f4 ff ff       	jmp    8010802a <alltraps>

80108bc2 <vector146>:
.globl vector146
vector146:
  pushl $0
80108bc2:	6a 00                	push   $0x0
  pushl $146
80108bc4:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80108bc9:	e9 5c f4 ff ff       	jmp    8010802a <alltraps>

80108bce <vector147>:
.globl vector147
vector147:
  pushl $0
80108bce:	6a 00                	push   $0x0
  pushl $147
80108bd0:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80108bd5:	e9 50 f4 ff ff       	jmp    8010802a <alltraps>

80108bda <vector148>:
.globl vector148
vector148:
  pushl $0
80108bda:	6a 00                	push   $0x0
  pushl $148
80108bdc:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80108be1:	e9 44 f4 ff ff       	jmp    8010802a <alltraps>

80108be6 <vector149>:
.globl vector149
vector149:
  pushl $0
80108be6:	6a 00                	push   $0x0
  pushl $149
80108be8:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80108bed:	e9 38 f4 ff ff       	jmp    8010802a <alltraps>

80108bf2 <vector150>:
.globl vector150
vector150:
  pushl $0
80108bf2:	6a 00                	push   $0x0
  pushl $150
80108bf4:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80108bf9:	e9 2c f4 ff ff       	jmp    8010802a <alltraps>

80108bfe <vector151>:
.globl vector151
vector151:
  pushl $0
80108bfe:	6a 00                	push   $0x0
  pushl $151
80108c00:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80108c05:	e9 20 f4 ff ff       	jmp    8010802a <alltraps>

80108c0a <vector152>:
.globl vector152
vector152:
  pushl $0
80108c0a:	6a 00                	push   $0x0
  pushl $152
80108c0c:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80108c11:	e9 14 f4 ff ff       	jmp    8010802a <alltraps>

80108c16 <vector153>:
.globl vector153
vector153:
  pushl $0
80108c16:	6a 00                	push   $0x0
  pushl $153
80108c18:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80108c1d:	e9 08 f4 ff ff       	jmp    8010802a <alltraps>

80108c22 <vector154>:
.globl vector154
vector154:
  pushl $0
80108c22:	6a 00                	push   $0x0
  pushl $154
80108c24:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80108c29:	e9 fc f3 ff ff       	jmp    8010802a <alltraps>

80108c2e <vector155>:
.globl vector155
vector155:
  pushl $0
80108c2e:	6a 00                	push   $0x0
  pushl $155
80108c30:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80108c35:	e9 f0 f3 ff ff       	jmp    8010802a <alltraps>

80108c3a <vector156>:
.globl vector156
vector156:
  pushl $0
80108c3a:	6a 00                	push   $0x0
  pushl $156
80108c3c:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80108c41:	e9 e4 f3 ff ff       	jmp    8010802a <alltraps>

80108c46 <vector157>:
.globl vector157
vector157:
  pushl $0
80108c46:	6a 00                	push   $0x0
  pushl $157
80108c48:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80108c4d:	e9 d8 f3 ff ff       	jmp    8010802a <alltraps>

80108c52 <vector158>:
.globl vector158
vector158:
  pushl $0
80108c52:	6a 00                	push   $0x0
  pushl $158
80108c54:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80108c59:	e9 cc f3 ff ff       	jmp    8010802a <alltraps>

80108c5e <vector159>:
.globl vector159
vector159:
  pushl $0
80108c5e:	6a 00                	push   $0x0
  pushl $159
80108c60:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80108c65:	e9 c0 f3 ff ff       	jmp    8010802a <alltraps>

80108c6a <vector160>:
.globl vector160
vector160:
  pushl $0
80108c6a:	6a 00                	push   $0x0
  pushl $160
80108c6c:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80108c71:	e9 b4 f3 ff ff       	jmp    8010802a <alltraps>

80108c76 <vector161>:
.globl vector161
vector161:
  pushl $0
80108c76:	6a 00                	push   $0x0
  pushl $161
80108c78:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80108c7d:	e9 a8 f3 ff ff       	jmp    8010802a <alltraps>

80108c82 <vector162>:
.globl vector162
vector162:
  pushl $0
80108c82:	6a 00                	push   $0x0
  pushl $162
80108c84:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80108c89:	e9 9c f3 ff ff       	jmp    8010802a <alltraps>

80108c8e <vector163>:
.globl vector163
vector163:
  pushl $0
80108c8e:	6a 00                	push   $0x0
  pushl $163
80108c90:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80108c95:	e9 90 f3 ff ff       	jmp    8010802a <alltraps>

80108c9a <vector164>:
.globl vector164
vector164:
  pushl $0
80108c9a:	6a 00                	push   $0x0
  pushl $164
80108c9c:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80108ca1:	e9 84 f3 ff ff       	jmp    8010802a <alltraps>

80108ca6 <vector165>:
.globl vector165
vector165:
  pushl $0
80108ca6:	6a 00                	push   $0x0
  pushl $165
80108ca8:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80108cad:	e9 78 f3 ff ff       	jmp    8010802a <alltraps>

80108cb2 <vector166>:
.globl vector166
vector166:
  pushl $0
80108cb2:	6a 00                	push   $0x0
  pushl $166
80108cb4:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80108cb9:	e9 6c f3 ff ff       	jmp    8010802a <alltraps>

80108cbe <vector167>:
.globl vector167
vector167:
  pushl $0
80108cbe:	6a 00                	push   $0x0
  pushl $167
80108cc0:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80108cc5:	e9 60 f3 ff ff       	jmp    8010802a <alltraps>

80108cca <vector168>:
.globl vector168
vector168:
  pushl $0
80108cca:	6a 00                	push   $0x0
  pushl $168
80108ccc:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80108cd1:	e9 54 f3 ff ff       	jmp    8010802a <alltraps>

80108cd6 <vector169>:
.globl vector169
vector169:
  pushl $0
80108cd6:	6a 00                	push   $0x0
  pushl $169
80108cd8:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80108cdd:	e9 48 f3 ff ff       	jmp    8010802a <alltraps>

80108ce2 <vector170>:
.globl vector170
vector170:
  pushl $0
80108ce2:	6a 00                	push   $0x0
  pushl $170
80108ce4:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80108ce9:	e9 3c f3 ff ff       	jmp    8010802a <alltraps>

80108cee <vector171>:
.globl vector171
vector171:
  pushl $0
80108cee:	6a 00                	push   $0x0
  pushl $171
80108cf0:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80108cf5:	e9 30 f3 ff ff       	jmp    8010802a <alltraps>

80108cfa <vector172>:
.globl vector172
vector172:
  pushl $0
80108cfa:	6a 00                	push   $0x0
  pushl $172
80108cfc:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80108d01:	e9 24 f3 ff ff       	jmp    8010802a <alltraps>

80108d06 <vector173>:
.globl vector173
vector173:
  pushl $0
80108d06:	6a 00                	push   $0x0
  pushl $173
80108d08:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80108d0d:	e9 18 f3 ff ff       	jmp    8010802a <alltraps>

80108d12 <vector174>:
.globl vector174
vector174:
  pushl $0
80108d12:	6a 00                	push   $0x0
  pushl $174
80108d14:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80108d19:	e9 0c f3 ff ff       	jmp    8010802a <alltraps>

80108d1e <vector175>:
.globl vector175
vector175:
  pushl $0
80108d1e:	6a 00                	push   $0x0
  pushl $175
80108d20:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80108d25:	e9 00 f3 ff ff       	jmp    8010802a <alltraps>

80108d2a <vector176>:
.globl vector176
vector176:
  pushl $0
80108d2a:	6a 00                	push   $0x0
  pushl $176
80108d2c:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80108d31:	e9 f4 f2 ff ff       	jmp    8010802a <alltraps>

80108d36 <vector177>:
.globl vector177
vector177:
  pushl $0
80108d36:	6a 00                	push   $0x0
  pushl $177
80108d38:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80108d3d:	e9 e8 f2 ff ff       	jmp    8010802a <alltraps>

80108d42 <vector178>:
.globl vector178
vector178:
  pushl $0
80108d42:	6a 00                	push   $0x0
  pushl $178
80108d44:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80108d49:	e9 dc f2 ff ff       	jmp    8010802a <alltraps>

80108d4e <vector179>:
.globl vector179
vector179:
  pushl $0
80108d4e:	6a 00                	push   $0x0
  pushl $179
80108d50:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80108d55:	e9 d0 f2 ff ff       	jmp    8010802a <alltraps>

80108d5a <vector180>:
.globl vector180
vector180:
  pushl $0
80108d5a:	6a 00                	push   $0x0
  pushl $180
80108d5c:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80108d61:	e9 c4 f2 ff ff       	jmp    8010802a <alltraps>

80108d66 <vector181>:
.globl vector181
vector181:
  pushl $0
80108d66:	6a 00                	push   $0x0
  pushl $181
80108d68:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80108d6d:	e9 b8 f2 ff ff       	jmp    8010802a <alltraps>

80108d72 <vector182>:
.globl vector182
vector182:
  pushl $0
80108d72:	6a 00                	push   $0x0
  pushl $182
80108d74:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80108d79:	e9 ac f2 ff ff       	jmp    8010802a <alltraps>

80108d7e <vector183>:
.globl vector183
vector183:
  pushl $0
80108d7e:	6a 00                	push   $0x0
  pushl $183
80108d80:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80108d85:	e9 a0 f2 ff ff       	jmp    8010802a <alltraps>

80108d8a <vector184>:
.globl vector184
vector184:
  pushl $0
80108d8a:	6a 00                	push   $0x0
  pushl $184
80108d8c:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80108d91:	e9 94 f2 ff ff       	jmp    8010802a <alltraps>

80108d96 <vector185>:
.globl vector185
vector185:
  pushl $0
80108d96:	6a 00                	push   $0x0
  pushl $185
80108d98:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80108d9d:	e9 88 f2 ff ff       	jmp    8010802a <alltraps>

80108da2 <vector186>:
.globl vector186
vector186:
  pushl $0
80108da2:	6a 00                	push   $0x0
  pushl $186
80108da4:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80108da9:	e9 7c f2 ff ff       	jmp    8010802a <alltraps>

80108dae <vector187>:
.globl vector187
vector187:
  pushl $0
80108dae:	6a 00                	push   $0x0
  pushl $187
80108db0:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80108db5:	e9 70 f2 ff ff       	jmp    8010802a <alltraps>

80108dba <vector188>:
.globl vector188
vector188:
  pushl $0
80108dba:	6a 00                	push   $0x0
  pushl $188
80108dbc:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80108dc1:	e9 64 f2 ff ff       	jmp    8010802a <alltraps>

80108dc6 <vector189>:
.globl vector189
vector189:
  pushl $0
80108dc6:	6a 00                	push   $0x0
  pushl $189
80108dc8:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80108dcd:	e9 58 f2 ff ff       	jmp    8010802a <alltraps>

80108dd2 <vector190>:
.globl vector190
vector190:
  pushl $0
80108dd2:	6a 00                	push   $0x0
  pushl $190
80108dd4:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80108dd9:	e9 4c f2 ff ff       	jmp    8010802a <alltraps>

80108dde <vector191>:
.globl vector191
vector191:
  pushl $0
80108dde:	6a 00                	push   $0x0
  pushl $191
80108de0:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80108de5:	e9 40 f2 ff ff       	jmp    8010802a <alltraps>

80108dea <vector192>:
.globl vector192
vector192:
  pushl $0
80108dea:	6a 00                	push   $0x0
  pushl $192
80108dec:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80108df1:	e9 34 f2 ff ff       	jmp    8010802a <alltraps>

80108df6 <vector193>:
.globl vector193
vector193:
  pushl $0
80108df6:	6a 00                	push   $0x0
  pushl $193
80108df8:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80108dfd:	e9 28 f2 ff ff       	jmp    8010802a <alltraps>

80108e02 <vector194>:
.globl vector194
vector194:
  pushl $0
80108e02:	6a 00                	push   $0x0
  pushl $194
80108e04:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80108e09:	e9 1c f2 ff ff       	jmp    8010802a <alltraps>

80108e0e <vector195>:
.globl vector195
vector195:
  pushl $0
80108e0e:	6a 00                	push   $0x0
  pushl $195
80108e10:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80108e15:	e9 10 f2 ff ff       	jmp    8010802a <alltraps>

80108e1a <vector196>:
.globl vector196
vector196:
  pushl $0
80108e1a:	6a 00                	push   $0x0
  pushl $196
80108e1c:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80108e21:	e9 04 f2 ff ff       	jmp    8010802a <alltraps>

80108e26 <vector197>:
.globl vector197
vector197:
  pushl $0
80108e26:	6a 00                	push   $0x0
  pushl $197
80108e28:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80108e2d:	e9 f8 f1 ff ff       	jmp    8010802a <alltraps>

80108e32 <vector198>:
.globl vector198
vector198:
  pushl $0
80108e32:	6a 00                	push   $0x0
  pushl $198
80108e34:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80108e39:	e9 ec f1 ff ff       	jmp    8010802a <alltraps>

80108e3e <vector199>:
.globl vector199
vector199:
  pushl $0
80108e3e:	6a 00                	push   $0x0
  pushl $199
80108e40:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80108e45:	e9 e0 f1 ff ff       	jmp    8010802a <alltraps>

80108e4a <vector200>:
.globl vector200
vector200:
  pushl $0
80108e4a:	6a 00                	push   $0x0
  pushl $200
80108e4c:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80108e51:	e9 d4 f1 ff ff       	jmp    8010802a <alltraps>

80108e56 <vector201>:
.globl vector201
vector201:
  pushl $0
80108e56:	6a 00                	push   $0x0
  pushl $201
80108e58:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80108e5d:	e9 c8 f1 ff ff       	jmp    8010802a <alltraps>

80108e62 <vector202>:
.globl vector202
vector202:
  pushl $0
80108e62:	6a 00                	push   $0x0
  pushl $202
80108e64:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80108e69:	e9 bc f1 ff ff       	jmp    8010802a <alltraps>

80108e6e <vector203>:
.globl vector203
vector203:
  pushl $0
80108e6e:	6a 00                	push   $0x0
  pushl $203
80108e70:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80108e75:	e9 b0 f1 ff ff       	jmp    8010802a <alltraps>

80108e7a <vector204>:
.globl vector204
vector204:
  pushl $0
80108e7a:	6a 00                	push   $0x0
  pushl $204
80108e7c:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80108e81:	e9 a4 f1 ff ff       	jmp    8010802a <alltraps>

80108e86 <vector205>:
.globl vector205
vector205:
  pushl $0
80108e86:	6a 00                	push   $0x0
  pushl $205
80108e88:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80108e8d:	e9 98 f1 ff ff       	jmp    8010802a <alltraps>

80108e92 <vector206>:
.globl vector206
vector206:
  pushl $0
80108e92:	6a 00                	push   $0x0
  pushl $206
80108e94:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80108e99:	e9 8c f1 ff ff       	jmp    8010802a <alltraps>

80108e9e <vector207>:
.globl vector207
vector207:
  pushl $0
80108e9e:	6a 00                	push   $0x0
  pushl $207
80108ea0:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80108ea5:	e9 80 f1 ff ff       	jmp    8010802a <alltraps>

80108eaa <vector208>:
.globl vector208
vector208:
  pushl $0
80108eaa:	6a 00                	push   $0x0
  pushl $208
80108eac:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80108eb1:	e9 74 f1 ff ff       	jmp    8010802a <alltraps>

80108eb6 <vector209>:
.globl vector209
vector209:
  pushl $0
80108eb6:	6a 00                	push   $0x0
  pushl $209
80108eb8:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80108ebd:	e9 68 f1 ff ff       	jmp    8010802a <alltraps>

80108ec2 <vector210>:
.globl vector210
vector210:
  pushl $0
80108ec2:	6a 00                	push   $0x0
  pushl $210
80108ec4:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80108ec9:	e9 5c f1 ff ff       	jmp    8010802a <alltraps>

80108ece <vector211>:
.globl vector211
vector211:
  pushl $0
80108ece:	6a 00                	push   $0x0
  pushl $211
80108ed0:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80108ed5:	e9 50 f1 ff ff       	jmp    8010802a <alltraps>

80108eda <vector212>:
.globl vector212
vector212:
  pushl $0
80108eda:	6a 00                	push   $0x0
  pushl $212
80108edc:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80108ee1:	e9 44 f1 ff ff       	jmp    8010802a <alltraps>

80108ee6 <vector213>:
.globl vector213
vector213:
  pushl $0
80108ee6:	6a 00                	push   $0x0
  pushl $213
80108ee8:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80108eed:	e9 38 f1 ff ff       	jmp    8010802a <alltraps>

80108ef2 <vector214>:
.globl vector214
vector214:
  pushl $0
80108ef2:	6a 00                	push   $0x0
  pushl $214
80108ef4:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80108ef9:	e9 2c f1 ff ff       	jmp    8010802a <alltraps>

80108efe <vector215>:
.globl vector215
vector215:
  pushl $0
80108efe:	6a 00                	push   $0x0
  pushl $215
80108f00:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80108f05:	e9 20 f1 ff ff       	jmp    8010802a <alltraps>

80108f0a <vector216>:
.globl vector216
vector216:
  pushl $0
80108f0a:	6a 00                	push   $0x0
  pushl $216
80108f0c:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80108f11:	e9 14 f1 ff ff       	jmp    8010802a <alltraps>

80108f16 <vector217>:
.globl vector217
vector217:
  pushl $0
80108f16:	6a 00                	push   $0x0
  pushl $217
80108f18:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80108f1d:	e9 08 f1 ff ff       	jmp    8010802a <alltraps>

80108f22 <vector218>:
.globl vector218
vector218:
  pushl $0
80108f22:	6a 00                	push   $0x0
  pushl $218
80108f24:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80108f29:	e9 fc f0 ff ff       	jmp    8010802a <alltraps>

80108f2e <vector219>:
.globl vector219
vector219:
  pushl $0
80108f2e:	6a 00                	push   $0x0
  pushl $219
80108f30:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80108f35:	e9 f0 f0 ff ff       	jmp    8010802a <alltraps>

80108f3a <vector220>:
.globl vector220
vector220:
  pushl $0
80108f3a:	6a 00                	push   $0x0
  pushl $220
80108f3c:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80108f41:	e9 e4 f0 ff ff       	jmp    8010802a <alltraps>

80108f46 <vector221>:
.globl vector221
vector221:
  pushl $0
80108f46:	6a 00                	push   $0x0
  pushl $221
80108f48:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80108f4d:	e9 d8 f0 ff ff       	jmp    8010802a <alltraps>

80108f52 <vector222>:
.globl vector222
vector222:
  pushl $0
80108f52:	6a 00                	push   $0x0
  pushl $222
80108f54:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80108f59:	e9 cc f0 ff ff       	jmp    8010802a <alltraps>

80108f5e <vector223>:
.globl vector223
vector223:
  pushl $0
80108f5e:	6a 00                	push   $0x0
  pushl $223
80108f60:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80108f65:	e9 c0 f0 ff ff       	jmp    8010802a <alltraps>

80108f6a <vector224>:
.globl vector224
vector224:
  pushl $0
80108f6a:	6a 00                	push   $0x0
  pushl $224
80108f6c:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80108f71:	e9 b4 f0 ff ff       	jmp    8010802a <alltraps>

80108f76 <vector225>:
.globl vector225
vector225:
  pushl $0
80108f76:	6a 00                	push   $0x0
  pushl $225
80108f78:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80108f7d:	e9 a8 f0 ff ff       	jmp    8010802a <alltraps>

80108f82 <vector226>:
.globl vector226
vector226:
  pushl $0
80108f82:	6a 00                	push   $0x0
  pushl $226
80108f84:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80108f89:	e9 9c f0 ff ff       	jmp    8010802a <alltraps>

80108f8e <vector227>:
.globl vector227
vector227:
  pushl $0
80108f8e:	6a 00                	push   $0x0
  pushl $227
80108f90:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80108f95:	e9 90 f0 ff ff       	jmp    8010802a <alltraps>

80108f9a <vector228>:
.globl vector228
vector228:
  pushl $0
80108f9a:	6a 00                	push   $0x0
  pushl $228
80108f9c:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80108fa1:	e9 84 f0 ff ff       	jmp    8010802a <alltraps>

80108fa6 <vector229>:
.globl vector229
vector229:
  pushl $0
80108fa6:	6a 00                	push   $0x0
  pushl $229
80108fa8:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80108fad:	e9 78 f0 ff ff       	jmp    8010802a <alltraps>

80108fb2 <vector230>:
.globl vector230
vector230:
  pushl $0
80108fb2:	6a 00                	push   $0x0
  pushl $230
80108fb4:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80108fb9:	e9 6c f0 ff ff       	jmp    8010802a <alltraps>

80108fbe <vector231>:
.globl vector231
vector231:
  pushl $0
80108fbe:	6a 00                	push   $0x0
  pushl $231
80108fc0:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80108fc5:	e9 60 f0 ff ff       	jmp    8010802a <alltraps>

80108fca <vector232>:
.globl vector232
vector232:
  pushl $0
80108fca:	6a 00                	push   $0x0
  pushl $232
80108fcc:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80108fd1:	e9 54 f0 ff ff       	jmp    8010802a <alltraps>

80108fd6 <vector233>:
.globl vector233
vector233:
  pushl $0
80108fd6:	6a 00                	push   $0x0
  pushl $233
80108fd8:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80108fdd:	e9 48 f0 ff ff       	jmp    8010802a <alltraps>

80108fe2 <vector234>:
.globl vector234
vector234:
  pushl $0
80108fe2:	6a 00                	push   $0x0
  pushl $234
80108fe4:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80108fe9:	e9 3c f0 ff ff       	jmp    8010802a <alltraps>

80108fee <vector235>:
.globl vector235
vector235:
  pushl $0
80108fee:	6a 00                	push   $0x0
  pushl $235
80108ff0:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80108ff5:	e9 30 f0 ff ff       	jmp    8010802a <alltraps>

80108ffa <vector236>:
.globl vector236
vector236:
  pushl $0
80108ffa:	6a 00                	push   $0x0
  pushl $236
80108ffc:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80109001:	e9 24 f0 ff ff       	jmp    8010802a <alltraps>

80109006 <vector237>:
.globl vector237
vector237:
  pushl $0
80109006:	6a 00                	push   $0x0
  pushl $237
80109008:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010900d:	e9 18 f0 ff ff       	jmp    8010802a <alltraps>

80109012 <vector238>:
.globl vector238
vector238:
  pushl $0
80109012:	6a 00                	push   $0x0
  pushl $238
80109014:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80109019:	e9 0c f0 ff ff       	jmp    8010802a <alltraps>

8010901e <vector239>:
.globl vector239
vector239:
  pushl $0
8010901e:	6a 00                	push   $0x0
  pushl $239
80109020:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80109025:	e9 00 f0 ff ff       	jmp    8010802a <alltraps>

8010902a <vector240>:
.globl vector240
vector240:
  pushl $0
8010902a:	6a 00                	push   $0x0
  pushl $240
8010902c:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80109031:	e9 f4 ef ff ff       	jmp    8010802a <alltraps>

80109036 <vector241>:
.globl vector241
vector241:
  pushl $0
80109036:	6a 00                	push   $0x0
  pushl $241
80109038:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010903d:	e9 e8 ef ff ff       	jmp    8010802a <alltraps>

80109042 <vector242>:
.globl vector242
vector242:
  pushl $0
80109042:	6a 00                	push   $0x0
  pushl $242
80109044:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80109049:	e9 dc ef ff ff       	jmp    8010802a <alltraps>

8010904e <vector243>:
.globl vector243
vector243:
  pushl $0
8010904e:	6a 00                	push   $0x0
  pushl $243
80109050:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80109055:	e9 d0 ef ff ff       	jmp    8010802a <alltraps>

8010905a <vector244>:
.globl vector244
vector244:
  pushl $0
8010905a:	6a 00                	push   $0x0
  pushl $244
8010905c:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80109061:	e9 c4 ef ff ff       	jmp    8010802a <alltraps>

80109066 <vector245>:
.globl vector245
vector245:
  pushl $0
80109066:	6a 00                	push   $0x0
  pushl $245
80109068:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010906d:	e9 b8 ef ff ff       	jmp    8010802a <alltraps>

80109072 <vector246>:
.globl vector246
vector246:
  pushl $0
80109072:	6a 00                	push   $0x0
  pushl $246
80109074:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80109079:	e9 ac ef ff ff       	jmp    8010802a <alltraps>

8010907e <vector247>:
.globl vector247
vector247:
  pushl $0
8010907e:	6a 00                	push   $0x0
  pushl $247
80109080:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80109085:	e9 a0 ef ff ff       	jmp    8010802a <alltraps>

8010908a <vector248>:
.globl vector248
vector248:
  pushl $0
8010908a:	6a 00                	push   $0x0
  pushl $248
8010908c:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80109091:	e9 94 ef ff ff       	jmp    8010802a <alltraps>

80109096 <vector249>:
.globl vector249
vector249:
  pushl $0
80109096:	6a 00                	push   $0x0
  pushl $249
80109098:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010909d:	e9 88 ef ff ff       	jmp    8010802a <alltraps>

801090a2 <vector250>:
.globl vector250
vector250:
  pushl $0
801090a2:	6a 00                	push   $0x0
  pushl $250
801090a4:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801090a9:	e9 7c ef ff ff       	jmp    8010802a <alltraps>

801090ae <vector251>:
.globl vector251
vector251:
  pushl $0
801090ae:	6a 00                	push   $0x0
  pushl $251
801090b0:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801090b5:	e9 70 ef ff ff       	jmp    8010802a <alltraps>

801090ba <vector252>:
.globl vector252
vector252:
  pushl $0
801090ba:	6a 00                	push   $0x0
  pushl $252
801090bc:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801090c1:	e9 64 ef ff ff       	jmp    8010802a <alltraps>

801090c6 <vector253>:
.globl vector253
vector253:
  pushl $0
801090c6:	6a 00                	push   $0x0
  pushl $253
801090c8:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801090cd:	e9 58 ef ff ff       	jmp    8010802a <alltraps>

801090d2 <vector254>:
.globl vector254
vector254:
  pushl $0
801090d2:	6a 00                	push   $0x0
  pushl $254
801090d4:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801090d9:	e9 4c ef ff ff       	jmp    8010802a <alltraps>

801090de <vector255>:
.globl vector255
vector255:
  pushl $0
801090de:	6a 00                	push   $0x0
  pushl $255
801090e0:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801090e5:	e9 40 ef ff ff       	jmp    8010802a <alltraps>

801090ea <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801090ea:	55                   	push   %ebp
801090eb:	89 e5                	mov    %esp,%ebp
801090ed:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801090f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801090f3:	83 e8 01             	sub    $0x1,%eax
801090f6:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801090fa:	8b 45 08             	mov    0x8(%ebp),%eax
801090fd:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80109101:	8b 45 08             	mov    0x8(%ebp),%eax
80109104:	c1 e8 10             	shr    $0x10,%eax
80109107:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
8010910b:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010910e:	0f 01 10             	lgdtl  (%eax)
}
80109111:	90                   	nop
80109112:	c9                   	leave  
80109113:	c3                   	ret    

80109114 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80109114:	55                   	push   %ebp
80109115:	89 e5                	mov    %esp,%ebp
80109117:	83 ec 04             	sub    $0x4,%esp
8010911a:	8b 45 08             	mov    0x8(%ebp),%eax
8010911d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80109121:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109125:	0f 00 d8             	ltr    %ax
}
80109128:	90                   	nop
80109129:	c9                   	leave  
8010912a:	c3                   	ret    

8010912b <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
8010912b:	55                   	push   %ebp
8010912c:	89 e5                	mov    %esp,%ebp
8010912e:	83 ec 04             	sub    $0x4,%esp
80109131:	8b 45 08             	mov    0x8(%ebp),%eax
80109134:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80109138:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010913c:	8e e8                	mov    %eax,%gs
}
8010913e:	90                   	nop
8010913f:	c9                   	leave  
80109140:	c3                   	ret    

80109141 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80109141:	55                   	push   %ebp
80109142:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80109144:	8b 45 08             	mov    0x8(%ebp),%eax
80109147:	0f 22 d8             	mov    %eax,%cr3
}
8010914a:	90                   	nop
8010914b:	5d                   	pop    %ebp
8010914c:	c3                   	ret    

8010914d <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
8010914d:	55                   	push   %ebp
8010914e:	89 e5                	mov    %esp,%ebp
80109150:	8b 45 08             	mov    0x8(%ebp),%eax
80109153:	05 00 00 00 80       	add    $0x80000000,%eax
80109158:	5d                   	pop    %ebp
80109159:	c3                   	ret    

8010915a <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010915a:	55                   	push   %ebp
8010915b:	89 e5                	mov    %esp,%ebp
8010915d:	8b 45 08             	mov    0x8(%ebp),%eax
80109160:	05 00 00 00 80       	add    $0x80000000,%eax
80109165:	5d                   	pop    %ebp
80109166:	c3                   	ret    

80109167 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80109167:	55                   	push   %ebp
80109168:	89 e5                	mov    %esp,%ebp
8010916a:	53                   	push   %ebx
8010916b:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
8010916e:	e8 f7 9e ff ff       	call   8010306a <cpunum>
80109173:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80109179:	05 80 43 11 80       	add    $0x80114380,%eax
8010917e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80109181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109184:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010918a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010918d:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80109193:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109196:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010919a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010919d:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801091a1:	83 e2 f0             	and    $0xfffffff0,%edx
801091a4:	83 ca 0a             	or     $0xa,%edx
801091a7:	88 50 7d             	mov    %dl,0x7d(%eax)
801091aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091ad:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801091b1:	83 ca 10             	or     $0x10,%edx
801091b4:	88 50 7d             	mov    %dl,0x7d(%eax)
801091b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091ba:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801091be:	83 e2 9f             	and    $0xffffff9f,%edx
801091c1:	88 50 7d             	mov    %dl,0x7d(%eax)
801091c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091c7:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801091cb:	83 ca 80             	or     $0xffffff80,%edx
801091ce:	88 50 7d             	mov    %dl,0x7d(%eax)
801091d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091d4:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801091d8:	83 ca 0f             	or     $0xf,%edx
801091db:	88 50 7e             	mov    %dl,0x7e(%eax)
801091de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091e1:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801091e5:	83 e2 ef             	and    $0xffffffef,%edx
801091e8:	88 50 7e             	mov    %dl,0x7e(%eax)
801091eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091ee:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801091f2:	83 e2 df             	and    $0xffffffdf,%edx
801091f5:	88 50 7e             	mov    %dl,0x7e(%eax)
801091f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091fb:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801091ff:	83 ca 40             	or     $0x40,%edx
80109202:	88 50 7e             	mov    %dl,0x7e(%eax)
80109205:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109208:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010920c:	83 ca 80             	or     $0xffffff80,%edx
8010920f:	88 50 7e             	mov    %dl,0x7e(%eax)
80109212:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109215:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80109219:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010921c:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80109223:	ff ff 
80109225:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109228:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010922f:	00 00 
80109231:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109234:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010923b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010923e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80109245:	83 e2 f0             	and    $0xfffffff0,%edx
80109248:	83 ca 02             	or     $0x2,%edx
8010924b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80109251:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109254:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010925b:	83 ca 10             	or     $0x10,%edx
8010925e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80109264:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109267:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010926e:	83 e2 9f             	and    $0xffffff9f,%edx
80109271:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80109277:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010927a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80109281:	83 ca 80             	or     $0xffffff80,%edx
80109284:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010928a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010928d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80109294:	83 ca 0f             	or     $0xf,%edx
80109297:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010929d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092a0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801092a7:	83 e2 ef             	and    $0xffffffef,%edx
801092aa:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801092b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092b3:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801092ba:	83 e2 df             	and    $0xffffffdf,%edx
801092bd:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801092c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092c6:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801092cd:	83 ca 40             	or     $0x40,%edx
801092d0:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801092d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092d9:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801092e0:	83 ca 80             	or     $0xffffff80,%edx
801092e3:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801092e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092ec:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801092f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092f6:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801092fd:	ff ff 
801092ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109302:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80109309:	00 00 
8010930b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010930e:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80109315:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109318:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010931f:	83 e2 f0             	and    $0xfffffff0,%edx
80109322:	83 ca 0a             	or     $0xa,%edx
80109325:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010932b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010932e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80109335:	83 ca 10             	or     $0x10,%edx
80109338:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010933e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109341:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80109348:	83 ca 60             	or     $0x60,%edx
8010934b:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80109351:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109354:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010935b:	83 ca 80             	or     $0xffffff80,%edx
8010935e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80109364:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109367:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010936e:	83 ca 0f             	or     $0xf,%edx
80109371:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80109377:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010937a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80109381:	83 e2 ef             	and    $0xffffffef,%edx
80109384:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010938a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010938d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80109394:	83 e2 df             	and    $0xffffffdf,%edx
80109397:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010939d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093a0:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801093a7:	83 ca 40             	or     $0x40,%edx
801093aa:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801093b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093b3:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801093ba:	83 ca 80             	or     $0xffffff80,%edx
801093bd:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801093c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093c6:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801093cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093d0:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
801093d7:	ff ff 
801093d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093dc:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
801093e3:	00 00 
801093e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093e8:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
801093ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093f2:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801093f9:	83 e2 f0             	and    $0xfffffff0,%edx
801093fc:	83 ca 02             	or     $0x2,%edx
801093ff:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80109405:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109408:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010940f:	83 ca 10             	or     $0x10,%edx
80109412:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80109418:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010941b:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80109422:	83 ca 60             	or     $0x60,%edx
80109425:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010942b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010942e:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80109435:	83 ca 80             	or     $0xffffff80,%edx
80109438:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010943e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109441:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80109448:	83 ca 0f             	or     $0xf,%edx
8010944b:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80109451:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109454:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010945b:	83 e2 ef             	and    $0xffffffef,%edx
8010945e:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80109464:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109467:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010946e:	83 e2 df             	and    $0xffffffdf,%edx
80109471:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80109477:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010947a:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80109481:	83 ca 40             	or     $0x40,%edx
80109484:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010948a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010948d:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80109494:	83 ca 80             	or     $0xffffff80,%edx
80109497:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010949d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094a0:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801094a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094aa:	05 b4 00 00 00       	add    $0xb4,%eax
801094af:	89 c3                	mov    %eax,%ebx
801094b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094b4:	05 b4 00 00 00       	add    $0xb4,%eax
801094b9:	c1 e8 10             	shr    $0x10,%eax
801094bc:	89 c2                	mov    %eax,%edx
801094be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094c1:	05 b4 00 00 00       	add    $0xb4,%eax
801094c6:	c1 e8 18             	shr    $0x18,%eax
801094c9:	89 c1                	mov    %eax,%ecx
801094cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094ce:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
801094d5:	00 00 
801094d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094da:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
801094e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094e4:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
801094ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094ed:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801094f4:	83 e2 f0             	and    $0xfffffff0,%edx
801094f7:	83 ca 02             	or     $0x2,%edx
801094fa:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80109500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109503:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010950a:	83 ca 10             	or     $0x10,%edx
8010950d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80109513:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109516:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010951d:	83 e2 9f             	and    $0xffffff9f,%edx
80109520:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80109526:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109529:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80109530:	83 ca 80             	or     $0xffffff80,%edx
80109533:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80109539:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010953c:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80109543:	83 e2 f0             	and    $0xfffffff0,%edx
80109546:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010954c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010954f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80109556:	83 e2 ef             	and    $0xffffffef,%edx
80109559:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010955f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109562:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80109569:	83 e2 df             	and    $0xffffffdf,%edx
8010956c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80109572:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109575:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010957c:	83 ca 40             	or     $0x40,%edx
8010957f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80109585:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109588:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010958f:	83 ca 80             	or     $0xffffff80,%edx
80109592:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80109598:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010959b:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
801095a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095a4:	83 c0 70             	add    $0x70,%eax
801095a7:	83 ec 08             	sub    $0x8,%esp
801095aa:	6a 38                	push   $0x38
801095ac:	50                   	push   %eax
801095ad:	e8 38 fb ff ff       	call   801090ea <lgdt>
801095b2:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
801095b5:	83 ec 0c             	sub    $0xc,%esp
801095b8:	6a 18                	push   $0x18
801095ba:	e8 6c fb ff ff       	call   8010912b <loadgs>
801095bf:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
801095c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095c5:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
801095cb:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801095d2:	00 00 00 00 
}
801095d6:	90                   	nop
801095d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801095da:	c9                   	leave  
801095db:	c3                   	ret    

801095dc <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801095dc:	55                   	push   %ebp
801095dd:	89 e5                	mov    %esp,%ebp
801095df:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801095e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801095e5:	c1 e8 16             	shr    $0x16,%eax
801095e8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801095ef:	8b 45 08             	mov    0x8(%ebp),%eax
801095f2:	01 d0                	add    %edx,%eax
801095f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801095f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095fa:	8b 00                	mov    (%eax),%eax
801095fc:	83 e0 01             	and    $0x1,%eax
801095ff:	85 c0                	test   %eax,%eax
80109601:	74 18                	je     8010961b <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80109603:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109606:	8b 00                	mov    (%eax),%eax
80109608:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010960d:	50                   	push   %eax
8010960e:	e8 47 fb ff ff       	call   8010915a <p2v>
80109613:	83 c4 04             	add    $0x4,%esp
80109616:	89 45 f4             	mov    %eax,-0xc(%ebp)
80109619:	eb 48                	jmp    80109663 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010961b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010961f:	74 0e                	je     8010962f <walkpgdir+0x53>
80109621:	e8 de 96 ff ff       	call   80102d04 <kalloc>
80109626:	89 45 f4             	mov    %eax,-0xc(%ebp)
80109629:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010962d:	75 07                	jne    80109636 <walkpgdir+0x5a>
      return 0;
8010962f:	b8 00 00 00 00       	mov    $0x0,%eax
80109634:	eb 44                	jmp    8010967a <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80109636:	83 ec 04             	sub    $0x4,%esp
80109639:	68 00 10 00 00       	push   $0x1000
8010963e:	6a 00                	push   $0x0
80109640:	ff 75 f4             	pushl  -0xc(%ebp)
80109643:	e8 80 d4 ff ff       	call   80106ac8 <memset>
80109648:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
8010964b:	83 ec 0c             	sub    $0xc,%esp
8010964e:	ff 75 f4             	pushl  -0xc(%ebp)
80109651:	e8 f7 fa ff ff       	call   8010914d <v2p>
80109656:	83 c4 10             	add    $0x10,%esp
80109659:	83 c8 07             	or     $0x7,%eax
8010965c:	89 c2                	mov    %eax,%edx
8010965e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109661:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80109663:	8b 45 0c             	mov    0xc(%ebp),%eax
80109666:	c1 e8 0c             	shr    $0xc,%eax
80109669:	25 ff 03 00 00       	and    $0x3ff,%eax
8010966e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109675:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109678:	01 d0                	add    %edx,%eax
}
8010967a:	c9                   	leave  
8010967b:	c3                   	ret    

8010967c <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010967c:	55                   	push   %ebp
8010967d:	89 e5                	mov    %esp,%ebp
8010967f:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80109682:	8b 45 0c             	mov    0xc(%ebp),%eax
80109685:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010968a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010968d:	8b 55 0c             	mov    0xc(%ebp),%edx
80109690:	8b 45 10             	mov    0x10(%ebp),%eax
80109693:	01 d0                	add    %edx,%eax
80109695:	83 e8 01             	sub    $0x1,%eax
80109698:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010969d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801096a0:	83 ec 04             	sub    $0x4,%esp
801096a3:	6a 01                	push   $0x1
801096a5:	ff 75 f4             	pushl  -0xc(%ebp)
801096a8:	ff 75 08             	pushl  0x8(%ebp)
801096ab:	e8 2c ff ff ff       	call   801095dc <walkpgdir>
801096b0:	83 c4 10             	add    $0x10,%esp
801096b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
801096b6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801096ba:	75 07                	jne    801096c3 <mappages+0x47>
      return -1;
801096bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801096c1:	eb 47                	jmp    8010970a <mappages+0x8e>
    if(*pte & PTE_P)
801096c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801096c6:	8b 00                	mov    (%eax),%eax
801096c8:	83 e0 01             	and    $0x1,%eax
801096cb:	85 c0                	test   %eax,%eax
801096cd:	74 0d                	je     801096dc <mappages+0x60>
      panic("remap");
801096cf:	83 ec 0c             	sub    $0xc,%esp
801096d2:	68 10 a9 10 80       	push   $0x8010a910
801096d7:	e8 8a 6e ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
801096dc:	8b 45 18             	mov    0x18(%ebp),%eax
801096df:	0b 45 14             	or     0x14(%ebp),%eax
801096e2:	83 c8 01             	or     $0x1,%eax
801096e5:	89 c2                	mov    %eax,%edx
801096e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801096ea:	89 10                	mov    %edx,(%eax)
    if(a == last)
801096ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096ef:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801096f2:	74 10                	je     80109704 <mappages+0x88>
      break;
    a += PGSIZE;
801096f4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801096fb:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80109702:	eb 9c                	jmp    801096a0 <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80109704:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80109705:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010970a:	c9                   	leave  
8010970b:	c3                   	ret    

8010970c <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
8010970c:	55                   	push   %ebp
8010970d:	89 e5                	mov    %esp,%ebp
8010970f:	53                   	push   %ebx
80109710:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80109713:	e8 ec 95 ff ff       	call   80102d04 <kalloc>
80109718:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010971b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010971f:	75 0a                	jne    8010972b <setupkvm+0x1f>
    return 0;
80109721:	b8 00 00 00 00       	mov    $0x0,%eax
80109726:	e9 8e 00 00 00       	jmp    801097b9 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
8010972b:	83 ec 04             	sub    $0x4,%esp
8010972e:	68 00 10 00 00       	push   $0x1000
80109733:	6a 00                	push   $0x0
80109735:	ff 75 f0             	pushl  -0x10(%ebp)
80109738:	e8 8b d3 ff ff       	call   80106ac8 <memset>
8010973d:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80109740:	83 ec 0c             	sub    $0xc,%esp
80109743:	68 00 00 00 0e       	push   $0xe000000
80109748:	e8 0d fa ff ff       	call   8010915a <p2v>
8010974d:	83 c4 10             	add    $0x10,%esp
80109750:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80109755:	76 0d                	jbe    80109764 <setupkvm+0x58>
    panic("PHYSTOP too high");
80109757:	83 ec 0c             	sub    $0xc,%esp
8010975a:	68 16 a9 10 80       	push   $0x8010a916
8010975f:	e8 02 6e ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80109764:	c7 45 f4 c0 d4 10 80 	movl   $0x8010d4c0,-0xc(%ebp)
8010976b:	eb 40                	jmp    801097ad <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
8010976d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109770:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80109773:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109776:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80109779:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010977c:	8b 58 08             	mov    0x8(%eax),%ebx
8010977f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109782:	8b 40 04             	mov    0x4(%eax),%eax
80109785:	29 c3                	sub    %eax,%ebx
80109787:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010978a:	8b 00                	mov    (%eax),%eax
8010978c:	83 ec 0c             	sub    $0xc,%esp
8010978f:	51                   	push   %ecx
80109790:	52                   	push   %edx
80109791:	53                   	push   %ebx
80109792:	50                   	push   %eax
80109793:	ff 75 f0             	pushl  -0x10(%ebp)
80109796:	e8 e1 fe ff ff       	call   8010967c <mappages>
8010979b:	83 c4 20             	add    $0x20,%esp
8010979e:	85 c0                	test   %eax,%eax
801097a0:	79 07                	jns    801097a9 <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
801097a2:	b8 00 00 00 00       	mov    $0x0,%eax
801097a7:	eb 10                	jmp    801097b9 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801097a9:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801097ad:	81 7d f4 00 d5 10 80 	cmpl   $0x8010d500,-0xc(%ebp)
801097b4:	72 b7                	jb     8010976d <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
801097b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801097b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801097bc:	c9                   	leave  
801097bd:	c3                   	ret    

801097be <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801097be:	55                   	push   %ebp
801097bf:	89 e5                	mov    %esp,%ebp
801097c1:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801097c4:	e8 43 ff ff ff       	call   8010970c <setupkvm>
801097c9:	a3 78 79 11 80       	mov    %eax,0x80117978
  switchkvm();
801097ce:	e8 03 00 00 00       	call   801097d6 <switchkvm>
}
801097d3:	90                   	nop
801097d4:	c9                   	leave  
801097d5:	c3                   	ret    

801097d6 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801097d6:	55                   	push   %ebp
801097d7:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
801097d9:	a1 78 79 11 80       	mov    0x80117978,%eax
801097de:	50                   	push   %eax
801097df:	e8 69 f9 ff ff       	call   8010914d <v2p>
801097e4:	83 c4 04             	add    $0x4,%esp
801097e7:	50                   	push   %eax
801097e8:	e8 54 f9 ff ff       	call   80109141 <lcr3>
801097ed:	83 c4 04             	add    $0x4,%esp
}
801097f0:	90                   	nop
801097f1:	c9                   	leave  
801097f2:	c3                   	ret    

801097f3 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801097f3:	55                   	push   %ebp
801097f4:	89 e5                	mov    %esp,%ebp
801097f6:	56                   	push   %esi
801097f7:	53                   	push   %ebx
  pushcli();
801097f8:	e8 c5 d1 ff ff       	call   801069c2 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
801097fd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109803:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010980a:	83 c2 08             	add    $0x8,%edx
8010980d:	89 d6                	mov    %edx,%esi
8010980f:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80109816:	83 c2 08             	add    $0x8,%edx
80109819:	c1 ea 10             	shr    $0x10,%edx
8010981c:	89 d3                	mov    %edx,%ebx
8010981e:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80109825:	83 c2 08             	add    $0x8,%edx
80109828:	c1 ea 18             	shr    $0x18,%edx
8010982b:	89 d1                	mov    %edx,%ecx
8010982d:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80109834:	67 00 
80109836:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
8010983d:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80109843:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010984a:	83 e2 f0             	and    $0xfffffff0,%edx
8010984d:	83 ca 09             	or     $0x9,%edx
80109850:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109856:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010985d:	83 ca 10             	or     $0x10,%edx
80109860:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109866:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010986d:	83 e2 9f             	and    $0xffffff9f,%edx
80109870:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109876:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010987d:	83 ca 80             	or     $0xffffff80,%edx
80109880:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109886:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
8010988d:	83 e2 f0             	and    $0xfffffff0,%edx
80109890:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109896:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
8010989d:	83 e2 ef             	and    $0xffffffef,%edx
801098a0:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801098a6:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801098ad:	83 e2 df             	and    $0xffffffdf,%edx
801098b0:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801098b6:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801098bd:	83 ca 40             	or     $0x40,%edx
801098c0:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801098c6:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801098cd:	83 e2 7f             	and    $0x7f,%edx
801098d0:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801098d6:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
801098dc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801098e2:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801098e9:	83 e2 ef             	and    $0xffffffef,%edx
801098ec:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
801098f2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801098f8:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
801098fe:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109904:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010990b:	8b 52 08             	mov    0x8(%edx),%edx
8010990e:	81 c2 00 10 00 00    	add    $0x1000,%edx
80109914:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80109917:	83 ec 0c             	sub    $0xc,%esp
8010991a:	6a 30                	push   $0x30
8010991c:	e8 f3 f7 ff ff       	call   80109114 <ltr>
80109921:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80109924:	8b 45 08             	mov    0x8(%ebp),%eax
80109927:	8b 40 04             	mov    0x4(%eax),%eax
8010992a:	85 c0                	test   %eax,%eax
8010992c:	75 0d                	jne    8010993b <switchuvm+0x148>
    panic("switchuvm: no pgdir");
8010992e:	83 ec 0c             	sub    $0xc,%esp
80109931:	68 27 a9 10 80       	push   $0x8010a927
80109936:	e8 2b 6c ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
8010993b:	8b 45 08             	mov    0x8(%ebp),%eax
8010993e:	8b 40 04             	mov    0x4(%eax),%eax
80109941:	83 ec 0c             	sub    $0xc,%esp
80109944:	50                   	push   %eax
80109945:	e8 03 f8 ff ff       	call   8010914d <v2p>
8010994a:	83 c4 10             	add    $0x10,%esp
8010994d:	83 ec 0c             	sub    $0xc,%esp
80109950:	50                   	push   %eax
80109951:	e8 eb f7 ff ff       	call   80109141 <lcr3>
80109956:	83 c4 10             	add    $0x10,%esp
  popcli();
80109959:	e8 a9 d0 ff ff       	call   80106a07 <popcli>
}
8010995e:	90                   	nop
8010995f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80109962:	5b                   	pop    %ebx
80109963:	5e                   	pop    %esi
80109964:	5d                   	pop    %ebp
80109965:	c3                   	ret    

80109966 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80109966:	55                   	push   %ebp
80109967:	89 e5                	mov    %esp,%ebp
80109969:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
8010996c:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80109973:	76 0d                	jbe    80109982 <inituvm+0x1c>
    panic("inituvm: more than a page");
80109975:	83 ec 0c             	sub    $0xc,%esp
80109978:	68 3b a9 10 80       	push   $0x8010a93b
8010997d:	e8 e4 6b ff ff       	call   80100566 <panic>
  mem = kalloc();
80109982:	e8 7d 93 ff ff       	call   80102d04 <kalloc>
80109987:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010998a:	83 ec 04             	sub    $0x4,%esp
8010998d:	68 00 10 00 00       	push   $0x1000
80109992:	6a 00                	push   $0x0
80109994:	ff 75 f4             	pushl  -0xc(%ebp)
80109997:	e8 2c d1 ff ff       	call   80106ac8 <memset>
8010999c:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010999f:	83 ec 0c             	sub    $0xc,%esp
801099a2:	ff 75 f4             	pushl  -0xc(%ebp)
801099a5:	e8 a3 f7 ff ff       	call   8010914d <v2p>
801099aa:	83 c4 10             	add    $0x10,%esp
801099ad:	83 ec 0c             	sub    $0xc,%esp
801099b0:	6a 06                	push   $0x6
801099b2:	50                   	push   %eax
801099b3:	68 00 10 00 00       	push   $0x1000
801099b8:	6a 00                	push   $0x0
801099ba:	ff 75 08             	pushl  0x8(%ebp)
801099bd:	e8 ba fc ff ff       	call   8010967c <mappages>
801099c2:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801099c5:	83 ec 04             	sub    $0x4,%esp
801099c8:	ff 75 10             	pushl  0x10(%ebp)
801099cb:	ff 75 0c             	pushl  0xc(%ebp)
801099ce:	ff 75 f4             	pushl  -0xc(%ebp)
801099d1:	e8 b1 d1 ff ff       	call   80106b87 <memmove>
801099d6:	83 c4 10             	add    $0x10,%esp
}
801099d9:	90                   	nop
801099da:	c9                   	leave  
801099db:	c3                   	ret    

801099dc <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801099dc:	55                   	push   %ebp
801099dd:	89 e5                	mov    %esp,%ebp
801099df:	53                   	push   %ebx
801099e0:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801099e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801099e6:	25 ff 0f 00 00       	and    $0xfff,%eax
801099eb:	85 c0                	test   %eax,%eax
801099ed:	74 0d                	je     801099fc <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
801099ef:	83 ec 0c             	sub    $0xc,%esp
801099f2:	68 58 a9 10 80       	push   $0x8010a958
801099f7:	e8 6a 6b ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801099fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109a03:	e9 95 00 00 00       	jmp    80109a9d <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80109a08:	8b 55 0c             	mov    0xc(%ebp),%edx
80109a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a0e:	01 d0                	add    %edx,%eax
80109a10:	83 ec 04             	sub    $0x4,%esp
80109a13:	6a 00                	push   $0x0
80109a15:	50                   	push   %eax
80109a16:	ff 75 08             	pushl  0x8(%ebp)
80109a19:	e8 be fb ff ff       	call   801095dc <walkpgdir>
80109a1e:	83 c4 10             	add    $0x10,%esp
80109a21:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109a24:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109a28:	75 0d                	jne    80109a37 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80109a2a:	83 ec 0c             	sub    $0xc,%esp
80109a2d:	68 7b a9 10 80       	push   $0x8010a97b
80109a32:	e8 2f 6b ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80109a37:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109a3a:	8b 00                	mov    (%eax),%eax
80109a3c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109a41:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80109a44:	8b 45 18             	mov    0x18(%ebp),%eax
80109a47:	2b 45 f4             	sub    -0xc(%ebp),%eax
80109a4a:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80109a4f:	77 0b                	ja     80109a5c <loaduvm+0x80>
      n = sz - i;
80109a51:	8b 45 18             	mov    0x18(%ebp),%eax
80109a54:	2b 45 f4             	sub    -0xc(%ebp),%eax
80109a57:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109a5a:	eb 07                	jmp    80109a63 <loaduvm+0x87>
    else
      n = PGSIZE;
80109a5c:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80109a63:	8b 55 14             	mov    0x14(%ebp),%edx
80109a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a69:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80109a6c:	83 ec 0c             	sub    $0xc,%esp
80109a6f:	ff 75 e8             	pushl  -0x18(%ebp)
80109a72:	e8 e3 f6 ff ff       	call   8010915a <p2v>
80109a77:	83 c4 10             	add    $0x10,%esp
80109a7a:	ff 75 f0             	pushl  -0x10(%ebp)
80109a7d:	53                   	push   %ebx
80109a7e:	50                   	push   %eax
80109a7f:	ff 75 10             	pushl  0x10(%ebp)
80109a82:	e8 ef 84 ff ff       	call   80101f76 <readi>
80109a87:	83 c4 10             	add    $0x10,%esp
80109a8a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80109a8d:	74 07                	je     80109a96 <loaduvm+0xba>
      return -1;
80109a8f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109a94:	eb 18                	jmp    80109aae <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80109a96:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109aa0:	3b 45 18             	cmp    0x18(%ebp),%eax
80109aa3:	0f 82 5f ff ff ff    	jb     80109a08 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80109aa9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109aae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109ab1:	c9                   	leave  
80109ab2:	c3                   	ret    

80109ab3 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80109ab3:	55                   	push   %ebp
80109ab4:	89 e5                	mov    %esp,%ebp
80109ab6:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80109ab9:	8b 45 10             	mov    0x10(%ebp),%eax
80109abc:	85 c0                	test   %eax,%eax
80109abe:	79 0a                	jns    80109aca <allocuvm+0x17>
    return 0;
80109ac0:	b8 00 00 00 00       	mov    $0x0,%eax
80109ac5:	e9 b0 00 00 00       	jmp    80109b7a <allocuvm+0xc7>
  if(newsz < oldsz)
80109aca:	8b 45 10             	mov    0x10(%ebp),%eax
80109acd:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109ad0:	73 08                	jae    80109ada <allocuvm+0x27>
    return oldsz;
80109ad2:	8b 45 0c             	mov    0xc(%ebp),%eax
80109ad5:	e9 a0 00 00 00       	jmp    80109b7a <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80109ada:	8b 45 0c             	mov    0xc(%ebp),%eax
80109add:	05 ff 0f 00 00       	add    $0xfff,%eax
80109ae2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109ae7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80109aea:	eb 7f                	jmp    80109b6b <allocuvm+0xb8>
    mem = kalloc();
80109aec:	e8 13 92 ff ff       	call   80102d04 <kalloc>
80109af1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80109af4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109af8:	75 2b                	jne    80109b25 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80109afa:	83 ec 0c             	sub    $0xc,%esp
80109afd:	68 99 a9 10 80       	push   $0x8010a999
80109b02:	e8 bf 68 ff ff       	call   801003c6 <cprintf>
80109b07:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80109b0a:	83 ec 04             	sub    $0x4,%esp
80109b0d:	ff 75 0c             	pushl  0xc(%ebp)
80109b10:	ff 75 10             	pushl  0x10(%ebp)
80109b13:	ff 75 08             	pushl  0x8(%ebp)
80109b16:	e8 61 00 00 00       	call   80109b7c <deallocuvm>
80109b1b:	83 c4 10             	add    $0x10,%esp
      return 0;
80109b1e:	b8 00 00 00 00       	mov    $0x0,%eax
80109b23:	eb 55                	jmp    80109b7a <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
80109b25:	83 ec 04             	sub    $0x4,%esp
80109b28:	68 00 10 00 00       	push   $0x1000
80109b2d:	6a 00                	push   $0x0
80109b2f:	ff 75 f0             	pushl  -0x10(%ebp)
80109b32:	e8 91 cf ff ff       	call   80106ac8 <memset>
80109b37:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80109b3a:	83 ec 0c             	sub    $0xc,%esp
80109b3d:	ff 75 f0             	pushl  -0x10(%ebp)
80109b40:	e8 08 f6 ff ff       	call   8010914d <v2p>
80109b45:	83 c4 10             	add    $0x10,%esp
80109b48:	89 c2                	mov    %eax,%edx
80109b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b4d:	83 ec 0c             	sub    $0xc,%esp
80109b50:	6a 06                	push   $0x6
80109b52:	52                   	push   %edx
80109b53:	68 00 10 00 00       	push   $0x1000
80109b58:	50                   	push   %eax
80109b59:	ff 75 08             	pushl  0x8(%ebp)
80109b5c:	e8 1b fb ff ff       	call   8010967c <mappages>
80109b61:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80109b64:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b6e:	3b 45 10             	cmp    0x10(%ebp),%eax
80109b71:	0f 82 75 ff ff ff    	jb     80109aec <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80109b77:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109b7a:	c9                   	leave  
80109b7b:	c3                   	ret    

80109b7c <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80109b7c:	55                   	push   %ebp
80109b7d:	89 e5                	mov    %esp,%ebp
80109b7f:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80109b82:	8b 45 10             	mov    0x10(%ebp),%eax
80109b85:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109b88:	72 08                	jb     80109b92 <deallocuvm+0x16>
    return oldsz;
80109b8a:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b8d:	e9 a5 00 00 00       	jmp    80109c37 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80109b92:	8b 45 10             	mov    0x10(%ebp),%eax
80109b95:	05 ff 0f 00 00       	add    $0xfff,%eax
80109b9a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109b9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80109ba2:	e9 81 00 00 00       	jmp    80109c28 <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80109ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109baa:	83 ec 04             	sub    $0x4,%esp
80109bad:	6a 00                	push   $0x0
80109baf:	50                   	push   %eax
80109bb0:	ff 75 08             	pushl  0x8(%ebp)
80109bb3:	e8 24 fa ff ff       	call   801095dc <walkpgdir>
80109bb8:	83 c4 10             	add    $0x10,%esp
80109bbb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80109bbe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109bc2:	75 09                	jne    80109bcd <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80109bc4:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80109bcb:	eb 54                	jmp    80109c21 <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
80109bcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bd0:	8b 00                	mov    (%eax),%eax
80109bd2:	83 e0 01             	and    $0x1,%eax
80109bd5:	85 c0                	test   %eax,%eax
80109bd7:	74 48                	je     80109c21 <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
80109bd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bdc:	8b 00                	mov    (%eax),%eax
80109bde:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109be3:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80109be6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109bea:	75 0d                	jne    80109bf9 <deallocuvm+0x7d>
        panic("kfree");
80109bec:	83 ec 0c             	sub    $0xc,%esp
80109bef:	68 b1 a9 10 80       	push   $0x8010a9b1
80109bf4:	e8 6d 69 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
80109bf9:	83 ec 0c             	sub    $0xc,%esp
80109bfc:	ff 75 ec             	pushl  -0x14(%ebp)
80109bff:	e8 56 f5 ff ff       	call   8010915a <p2v>
80109c04:	83 c4 10             	add    $0x10,%esp
80109c07:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80109c0a:	83 ec 0c             	sub    $0xc,%esp
80109c0d:	ff 75 e8             	pushl  -0x18(%ebp)
80109c10:	e8 52 90 ff ff       	call   80102c67 <kfree>
80109c15:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80109c18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c1b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80109c21:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c2b:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109c2e:	0f 82 73 ff ff ff    	jb     80109ba7 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80109c34:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109c37:	c9                   	leave  
80109c38:	c3                   	ret    

80109c39 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80109c39:	55                   	push   %ebp
80109c3a:	89 e5                	mov    %esp,%ebp
80109c3c:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80109c3f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80109c43:	75 0d                	jne    80109c52 <freevm+0x19>
    panic("freevm: no pgdir");
80109c45:	83 ec 0c             	sub    $0xc,%esp
80109c48:	68 b7 a9 10 80       	push   $0x8010a9b7
80109c4d:	e8 14 69 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80109c52:	83 ec 04             	sub    $0x4,%esp
80109c55:	6a 00                	push   $0x0
80109c57:	68 00 00 00 80       	push   $0x80000000
80109c5c:	ff 75 08             	pushl  0x8(%ebp)
80109c5f:	e8 18 ff ff ff       	call   80109b7c <deallocuvm>
80109c64:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80109c67:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109c6e:	eb 4f                	jmp    80109cbf <freevm+0x86>
    if(pgdir[i] & PTE_P){
80109c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c73:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109c7a:	8b 45 08             	mov    0x8(%ebp),%eax
80109c7d:	01 d0                	add    %edx,%eax
80109c7f:	8b 00                	mov    (%eax),%eax
80109c81:	83 e0 01             	and    $0x1,%eax
80109c84:	85 c0                	test   %eax,%eax
80109c86:	74 33                	je     80109cbb <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80109c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c8b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109c92:	8b 45 08             	mov    0x8(%ebp),%eax
80109c95:	01 d0                	add    %edx,%eax
80109c97:	8b 00                	mov    (%eax),%eax
80109c99:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109c9e:	83 ec 0c             	sub    $0xc,%esp
80109ca1:	50                   	push   %eax
80109ca2:	e8 b3 f4 ff ff       	call   8010915a <p2v>
80109ca7:	83 c4 10             	add    $0x10,%esp
80109caa:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80109cad:	83 ec 0c             	sub    $0xc,%esp
80109cb0:	ff 75 f0             	pushl  -0x10(%ebp)
80109cb3:	e8 af 8f ff ff       	call   80102c67 <kfree>
80109cb8:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80109cbb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109cbf:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80109cc6:	76 a8                	jbe    80109c70 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80109cc8:	83 ec 0c             	sub    $0xc,%esp
80109ccb:	ff 75 08             	pushl  0x8(%ebp)
80109cce:	e8 94 8f ff ff       	call   80102c67 <kfree>
80109cd3:	83 c4 10             	add    $0x10,%esp
}
80109cd6:	90                   	nop
80109cd7:	c9                   	leave  
80109cd8:	c3                   	ret    

80109cd9 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80109cd9:	55                   	push   %ebp
80109cda:	89 e5                	mov    %esp,%ebp
80109cdc:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109cdf:	83 ec 04             	sub    $0x4,%esp
80109ce2:	6a 00                	push   $0x0
80109ce4:	ff 75 0c             	pushl  0xc(%ebp)
80109ce7:	ff 75 08             	pushl  0x8(%ebp)
80109cea:	e8 ed f8 ff ff       	call   801095dc <walkpgdir>
80109cef:	83 c4 10             	add    $0x10,%esp
80109cf2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80109cf5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109cf9:	75 0d                	jne    80109d08 <clearpteu+0x2f>
    panic("clearpteu");
80109cfb:	83 ec 0c             	sub    $0xc,%esp
80109cfe:	68 c8 a9 10 80       	push   $0x8010a9c8
80109d03:	e8 5e 68 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
80109d08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d0b:	8b 00                	mov    (%eax),%eax
80109d0d:	83 e0 fb             	and    $0xfffffffb,%eax
80109d10:	89 c2                	mov    %eax,%edx
80109d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d15:	89 10                	mov    %edx,(%eax)
}
80109d17:	90                   	nop
80109d18:	c9                   	leave  
80109d19:	c3                   	ret    

80109d1a <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80109d1a:	55                   	push   %ebp
80109d1b:	89 e5                	mov    %esp,%ebp
80109d1d:	53                   	push   %ebx
80109d1e:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80109d21:	e8 e6 f9 ff ff       	call   8010970c <setupkvm>
80109d26:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109d29:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109d2d:	75 0a                	jne    80109d39 <copyuvm+0x1f>
    return 0;
80109d2f:	b8 00 00 00 00       	mov    $0x0,%eax
80109d34:	e9 f8 00 00 00       	jmp    80109e31 <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
80109d39:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109d40:	e9 c4 00 00 00       	jmp    80109e09 <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80109d45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d48:	83 ec 04             	sub    $0x4,%esp
80109d4b:	6a 00                	push   $0x0
80109d4d:	50                   	push   %eax
80109d4e:	ff 75 08             	pushl  0x8(%ebp)
80109d51:	e8 86 f8 ff ff       	call   801095dc <walkpgdir>
80109d56:	83 c4 10             	add    $0x10,%esp
80109d59:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109d5c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109d60:	75 0d                	jne    80109d6f <copyuvm+0x55>
      panic("copyuvm: pte should exist");
80109d62:	83 ec 0c             	sub    $0xc,%esp
80109d65:	68 d2 a9 10 80       	push   $0x8010a9d2
80109d6a:	e8 f7 67 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
80109d6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d72:	8b 00                	mov    (%eax),%eax
80109d74:	83 e0 01             	and    $0x1,%eax
80109d77:	85 c0                	test   %eax,%eax
80109d79:	75 0d                	jne    80109d88 <copyuvm+0x6e>
      panic("copyuvm: page not present");
80109d7b:	83 ec 0c             	sub    $0xc,%esp
80109d7e:	68 ec a9 10 80       	push   $0x8010a9ec
80109d83:	e8 de 67 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80109d88:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d8b:	8b 00                	mov    (%eax),%eax
80109d8d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109d92:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80109d95:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d98:	8b 00                	mov    (%eax),%eax
80109d9a:	25 ff 0f 00 00       	and    $0xfff,%eax
80109d9f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80109da2:	e8 5d 8f ff ff       	call   80102d04 <kalloc>
80109da7:	89 45 e0             	mov    %eax,-0x20(%ebp)
80109daa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80109dae:	74 6a                	je     80109e1a <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80109db0:	83 ec 0c             	sub    $0xc,%esp
80109db3:	ff 75 e8             	pushl  -0x18(%ebp)
80109db6:	e8 9f f3 ff ff       	call   8010915a <p2v>
80109dbb:	83 c4 10             	add    $0x10,%esp
80109dbe:	83 ec 04             	sub    $0x4,%esp
80109dc1:	68 00 10 00 00       	push   $0x1000
80109dc6:	50                   	push   %eax
80109dc7:	ff 75 e0             	pushl  -0x20(%ebp)
80109dca:	e8 b8 cd ff ff       	call   80106b87 <memmove>
80109dcf:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80109dd2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80109dd5:	83 ec 0c             	sub    $0xc,%esp
80109dd8:	ff 75 e0             	pushl  -0x20(%ebp)
80109ddb:	e8 6d f3 ff ff       	call   8010914d <v2p>
80109de0:	83 c4 10             	add    $0x10,%esp
80109de3:	89 c2                	mov    %eax,%edx
80109de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109de8:	83 ec 0c             	sub    $0xc,%esp
80109deb:	53                   	push   %ebx
80109dec:	52                   	push   %edx
80109ded:	68 00 10 00 00       	push   $0x1000
80109df2:	50                   	push   %eax
80109df3:	ff 75 f0             	pushl  -0x10(%ebp)
80109df6:	e8 81 f8 ff ff       	call   8010967c <mappages>
80109dfb:	83 c4 20             	add    $0x20,%esp
80109dfe:	85 c0                	test   %eax,%eax
80109e00:	78 1b                	js     80109e1d <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80109e02:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e0c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109e0f:	0f 82 30 ff ff ff    	jb     80109d45 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80109e15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e18:	eb 17                	jmp    80109e31 <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80109e1a:	90                   	nop
80109e1b:	eb 01                	jmp    80109e1e <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
80109e1d:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80109e1e:	83 ec 0c             	sub    $0xc,%esp
80109e21:	ff 75 f0             	pushl  -0x10(%ebp)
80109e24:	e8 10 fe ff ff       	call   80109c39 <freevm>
80109e29:	83 c4 10             	add    $0x10,%esp
  return 0;
80109e2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109e31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109e34:	c9                   	leave  
80109e35:	c3                   	ret    

80109e36 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80109e36:	55                   	push   %ebp
80109e37:	89 e5                	mov    %esp,%ebp
80109e39:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109e3c:	83 ec 04             	sub    $0x4,%esp
80109e3f:	6a 00                	push   $0x0
80109e41:	ff 75 0c             	pushl  0xc(%ebp)
80109e44:	ff 75 08             	pushl  0x8(%ebp)
80109e47:	e8 90 f7 ff ff       	call   801095dc <walkpgdir>
80109e4c:	83 c4 10             	add    $0x10,%esp
80109e4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80109e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e55:	8b 00                	mov    (%eax),%eax
80109e57:	83 e0 01             	and    $0x1,%eax
80109e5a:	85 c0                	test   %eax,%eax
80109e5c:	75 07                	jne    80109e65 <uva2ka+0x2f>
    return 0;
80109e5e:	b8 00 00 00 00       	mov    $0x0,%eax
80109e63:	eb 29                	jmp    80109e8e <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80109e65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e68:	8b 00                	mov    (%eax),%eax
80109e6a:	83 e0 04             	and    $0x4,%eax
80109e6d:	85 c0                	test   %eax,%eax
80109e6f:	75 07                	jne    80109e78 <uva2ka+0x42>
    return 0;
80109e71:	b8 00 00 00 00       	mov    $0x0,%eax
80109e76:	eb 16                	jmp    80109e8e <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
80109e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e7b:	8b 00                	mov    (%eax),%eax
80109e7d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109e82:	83 ec 0c             	sub    $0xc,%esp
80109e85:	50                   	push   %eax
80109e86:	e8 cf f2 ff ff       	call   8010915a <p2v>
80109e8b:	83 c4 10             	add    $0x10,%esp
}
80109e8e:	c9                   	leave  
80109e8f:	c3                   	ret    

80109e90 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80109e90:	55                   	push   %ebp
80109e91:	89 e5                	mov    %esp,%ebp
80109e93:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80109e96:	8b 45 10             	mov    0x10(%ebp),%eax
80109e99:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80109e9c:	eb 7f                	jmp    80109f1d <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80109e9e:	8b 45 0c             	mov    0xc(%ebp),%eax
80109ea1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109ea6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80109ea9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109eac:	83 ec 08             	sub    $0x8,%esp
80109eaf:	50                   	push   %eax
80109eb0:	ff 75 08             	pushl  0x8(%ebp)
80109eb3:	e8 7e ff ff ff       	call   80109e36 <uva2ka>
80109eb8:	83 c4 10             	add    $0x10,%esp
80109ebb:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80109ebe:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80109ec2:	75 07                	jne    80109ecb <copyout+0x3b>
      return -1;
80109ec4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109ec9:	eb 61                	jmp    80109f2c <copyout+0x9c>
    n = PGSIZE - (va - va0);
80109ecb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ece:	2b 45 0c             	sub    0xc(%ebp),%eax
80109ed1:	05 00 10 00 00       	add    $0x1000,%eax
80109ed6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80109ed9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109edc:	3b 45 14             	cmp    0x14(%ebp),%eax
80109edf:	76 06                	jbe    80109ee7 <copyout+0x57>
      n = len;
80109ee1:	8b 45 14             	mov    0x14(%ebp),%eax
80109ee4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80109ee7:	8b 45 0c             	mov    0xc(%ebp),%eax
80109eea:	2b 45 ec             	sub    -0x14(%ebp),%eax
80109eed:	89 c2                	mov    %eax,%edx
80109eef:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ef2:	01 d0                	add    %edx,%eax
80109ef4:	83 ec 04             	sub    $0x4,%esp
80109ef7:	ff 75 f0             	pushl  -0x10(%ebp)
80109efa:	ff 75 f4             	pushl  -0xc(%ebp)
80109efd:	50                   	push   %eax
80109efe:	e8 84 cc ff ff       	call   80106b87 <memmove>
80109f03:	83 c4 10             	add    $0x10,%esp
    len -= n;
80109f06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f09:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80109f0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f0f:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80109f12:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f15:	05 00 10 00 00       	add    $0x1000,%eax
80109f1a:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80109f1d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80109f21:	0f 85 77 ff ff ff    	jne    80109e9e <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80109f27:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109f2c:	c9                   	leave  
80109f2d:	c3                   	ret    

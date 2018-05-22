
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
8010003d:	68 40 9f 10 80       	push   $0x80109f40
80100042:	68 80 e6 10 80       	push   $0x8010e680
80100047:	e8 07 68 00 00       	call   80106853 <initlock>
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
801000c1:	e8 af 67 00 00       	call   80106875 <acquire>
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
8010010c:	e8 cb 67 00 00       	call   801068dc <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 80 e6 10 80       	push   $0x8010e680
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 6d 54 00 00       	call   80105599 <sleep>
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
80100188:	e8 4f 67 00 00       	call   801068dc <release>
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
801001aa:	68 47 9f 10 80       	push   $0x80109f47
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
80100204:	68 58 9f 10 80       	push   $0x80109f58
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
80100243:	68 5f 9f 10 80       	push   $0x80109f5f
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 80 e6 10 80       	push   $0x8010e680
80100255:	e8 1b 66 00 00       	call   80106875 <acquire>
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
801002b9:	e8 53 55 00 00       	call   80105811 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 80 e6 10 80       	push   $0x8010e680
801002c9:	e8 0e 66 00 00       	call   801068dc <release>
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
801003e2:	e8 8e 64 00 00       	call   80106875 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 66 9f 10 80       	push   $0x80109f66
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
801004cd:	c7 45 ec 6f 9f 10 80 	movl   $0x80109f6f,-0x14(%ebp)
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
8010055b:	e8 7c 63 00 00       	call   801068dc <release>
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
8010058b:	68 76 9f 10 80       	push   $0x80109f76
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
801005aa:	68 85 9f 10 80       	push   $0x80109f85
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 67 63 00 00       	call   8010692e <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 87 9f 10 80       	push   $0x80109f87
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
801006ca:	68 8b 9f 10 80       	push   $0x80109f8b
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
801006f7:	e8 9b 64 00 00       	call   80106b97 <memmove>
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
80100721:	e8 b2 63 00 00       	call   80106ad8 <memset>
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
801007b6:	e8 0c 7e 00 00       	call   801085c7 <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 ff 7d 00 00       	call   801085c7 <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 f2 7d 00 00       	call   801085c7 <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 e2 7d 00 00       	call   801085c7 <uartputc>
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
8010082a:	e8 46 60 00 00       	call   80106875 <acquire>
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
801009c8:	e8 44 4e 00 00       	call   80105811 <wakeup>
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
801009eb:	e8 ec 5e 00 00       	call   801068dc <release>
801009f0:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009f7:	74 05                	je     801009fe <consoleintr+0x205>
    procdump();  // now call procdump() wo. cons.lock held
801009f9:	e8 3f 50 00 00       	call   80105a3d <procdump>
  }
#ifdef CS333_P3P4
  if(dopids) {
801009fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100a02:	74 05                	je     80100a09 <consoleintr+0x210>
    piddump();
80100a04:	e8 20 57 00 00       	call   80106129 <piddump>
  }
  if(dofree) {
80100a09:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100a0d:	74 05                	je     80100a14 <consoleintr+0x21b>
    freedump();
80100a0f:	e8 ef 57 00 00       	call   80106203 <freedump>
  }
  if(dosleep) {
80100a14:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100a18:	74 05                	je     80100a1f <consoleintr+0x226>
    sleepdump();
80100a1a:	e8 47 58 00 00       	call   80106266 <sleepdump>
  }
  if(dozombie) {
80100a1f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a23:	74 05                	je     80100a2a <consoleintr+0x231>
    zombiedump();
80100a25:	e8 d5 58 00 00       	call   801062ff <zombiedump>
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
80100a4f:	e8 21 5e 00 00       	call   80106875 <acquire>
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
80100a71:	e8 66 5e 00 00       	call   801068dc <release>
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
80100a9e:	e8 f6 4a 00 00       	call   80105599 <sleep>
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
80100b1c:	e8 bb 5d 00 00       	call   801068dc <release>
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
80100b5a:	e8 16 5d 00 00       	call   80106875 <acquire>
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
80100b9c:	e8 3b 5d 00 00       	call   801068dc <release>
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
80100bc0:	68 9e 9f 10 80       	push   $0x80109f9e
80100bc5:	68 e0 d5 10 80       	push   $0x8010d5e0
80100bca:	e8 84 5c 00 00       	call   80106853 <initlock>
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
80100c88:	e8 8f 8a 00 00       	call   8010971c <setupkvm>
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
80100d0e:	e8 b0 8d 00 00       	call   80109ac3 <allocuvm>
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
80100d41:	e8 a6 8c 00 00       	call   801099ec <loaduvm>
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
80100db0:	e8 0e 8d 00 00       	call   80109ac3 <allocuvm>
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
80100dd4:	e8 10 8f 00 00       	call   80109ce9 <clearpteu>
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
80100e0d:	e8 13 5f 00 00       	call   80106d25 <strlen>
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
80100e3a:	e8 e6 5e 00 00       	call   80106d25 <strlen>
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
80100e60:	e8 3b 90 00 00       	call   80109ea0 <copyout>
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
80100efc:	e8 9f 8f 00 00       	call   80109ea0 <copyout>
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
80100f4d:	e8 89 5d 00 00       	call   80106cdb <safestrcpy>
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
80100fa3:	e8 5b 88 00 00       	call   80109803 <switchuvm>
80100fa8:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100fab:	83 ec 0c             	sub    $0xc,%esp
80100fae:	ff 75 d0             	pushl  -0x30(%ebp)
80100fb1:	e8 93 8c 00 00       	call   80109c49 <freevm>
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
80100feb:	e8 59 8c 00 00       	call   80109c49 <freevm>
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
8010101c:	68 a6 9f 10 80       	push   $0x80109fa6
80101021:	68 40 28 11 80       	push   $0x80112840
80101026:	e8 28 58 00 00       	call   80106853 <initlock>
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
8010103f:	e8 31 58 00 00       	call   80106875 <acquire>
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
8010106c:	e8 6b 58 00 00       	call   801068dc <release>
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
8010108f:	e8 48 58 00 00       	call   801068dc <release>
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
801010ac:	e8 c4 57 00 00       	call   80106875 <acquire>
801010b1:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b4:	8b 45 08             	mov    0x8(%ebp),%eax
801010b7:	8b 40 04             	mov    0x4(%eax),%eax
801010ba:	85 c0                	test   %eax,%eax
801010bc:	7f 0d                	jg     801010cb <filedup+0x2d>
    panic("filedup");
801010be:	83 ec 0c             	sub    $0xc,%esp
801010c1:	68 ad 9f 10 80       	push   $0x80109fad
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
801010e2:	e8 f5 57 00 00       	call   801068dc <release>
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
801010fd:	e8 73 57 00 00       	call   80106875 <acquire>
80101102:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101105:	8b 45 08             	mov    0x8(%ebp),%eax
80101108:	8b 40 04             	mov    0x4(%eax),%eax
8010110b:	85 c0                	test   %eax,%eax
8010110d:	7f 0d                	jg     8010111c <fileclose+0x2d>
    panic("fileclose");
8010110f:	83 ec 0c             	sub    $0xc,%esp
80101112:	68 b5 9f 10 80       	push   $0x80109fb5
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
8010113d:	e8 9a 57 00 00       	call   801068dc <release>
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
8010118b:	e8 4c 57 00 00       	call   801068dc <release>
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
801012da:	68 bf 9f 10 80       	push   $0x80109fbf
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
801013dd:	68 c8 9f 10 80       	push   $0x80109fc8
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
80101413:	68 d8 9f 10 80       	push   $0x80109fd8
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
8010144b:	e8 47 57 00 00       	call   80106b97 <memmove>
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
80101491:	e8 42 56 00 00       	call   80106ad8 <memset>
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
801015f8:	68 e4 9f 10 80       	push   $0x80109fe4
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
8010168b:	68 fa 9f 10 80       	push   $0x80109ffa
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
801016e8:	68 0d a0 10 80       	push   $0x8010a00d
801016ed:	68 60 32 11 80       	push   $0x80113260
801016f2:	e8 5c 51 00 00       	call   80106853 <initlock>
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
80101741:	68 14 a0 10 80       	push   $0x8010a014
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
801017ba:	e8 19 53 00 00       	call   80106ad8 <memset>
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
80101822:	68 67 a0 10 80       	push   $0x8010a067
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
801018c8:	e8 ca 52 00 00       	call   80106b97 <memmove>
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
801018fd:	e8 73 4f 00 00       	call   80106875 <acquire>
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
8010194b:	e8 8c 4f 00 00       	call   801068dc <release>
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
80101984:	68 79 a0 10 80       	push   $0x8010a079
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
801019c1:	e8 16 4f 00 00       	call   801068dc <release>
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
801019dc:	e8 94 4e 00 00       	call   80106875 <acquire>
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
801019fb:	e8 dc 4e 00 00       	call   801068dc <release>
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
80101a21:	68 89 a0 10 80       	push   $0x8010a089
80101a26:	e8 3b eb ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101a2b:	83 ec 0c             	sub    $0xc,%esp
80101a2e:	68 60 32 11 80       	push   $0x80113260
80101a33:	e8 3d 4e 00 00       	call   80106875 <acquire>
80101a38:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
80101a3b:	eb 13                	jmp    80101a50 <ilock+0x48>
    sleep(ip, &icache.lock);
80101a3d:	83 ec 08             	sub    $0x8,%esp
80101a40:	68 60 32 11 80       	push   $0x80113260
80101a45:	ff 75 08             	pushl  0x8(%ebp)
80101a48:	e8 4c 3b 00 00       	call   80105599 <sleep>
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
80101a76:	e8 61 4e 00 00       	call   801068dc <release>
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
80101b23:	e8 6f 50 00 00       	call   80106b97 <memmove>
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
80101b59:	68 8f a0 10 80       	push   $0x8010a08f
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
80101b8c:	68 9e a0 10 80       	push   $0x8010a09e
80101b91:	e8 d0 e9 ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101b96:	83 ec 0c             	sub    $0xc,%esp
80101b99:	68 60 32 11 80       	push   $0x80113260
80101b9e:	e8 d2 4c 00 00       	call   80106875 <acquire>
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
80101bbd:	e8 4f 3c 00 00       	call   80105811 <wakeup>
80101bc2:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101bc5:	83 ec 0c             	sub    $0xc,%esp
80101bc8:	68 60 32 11 80       	push   $0x80113260
80101bcd:	e8 0a 4d 00 00       	call   801068dc <release>
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
80101be6:	e8 8a 4c 00 00       	call   80106875 <acquire>
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
80101c2e:	68 a6 a0 10 80       	push   $0x8010a0a6
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
80101c51:	e8 86 4c 00 00       	call   801068dc <release>
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
80101c86:	e8 ea 4b 00 00       	call   80106875 <acquire>
80101c8b:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101c8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c91:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101c98:	83 ec 0c             	sub    $0xc,%esp
80101c9b:	ff 75 08             	pushl  0x8(%ebp)
80101c9e:	e8 6e 3b 00 00       	call   80105811 <wakeup>
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
80101cbd:	e8 1a 4c 00 00       	call   801068dc <release>
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
80101dfd:	68 b0 a0 10 80       	push   $0x8010a0b0
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
80102094:	e8 fe 4a 00 00       	call   80106b97 <memmove>
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
801021e6:	e8 ac 49 00 00       	call   80106b97 <memmove>
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
80102266:	e8 c2 49 00 00       	call   80106c2d <strncmp>
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
80102286:	68 c3 a0 10 80       	push   $0x8010a0c3
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
801022b5:	68 d5 a0 10 80       	push   $0x8010a0d5
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
8010238a:	68 d5 a0 10 80       	push   $0x8010a0d5
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
801023c5:	e8 b9 48 00 00       	call   80106c83 <strncpy>
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
801023f1:	68 e2 a0 10 80       	push   $0x8010a0e2
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
80102467:	e8 2b 47 00 00       	call   80106b97 <memmove>
8010246c:	83 c4 10             	add    $0x10,%esp
8010246f:	eb 26                	jmp    80102497 <skipelem+0x95>
  else {
    memmove(name, s, len);
80102471:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102474:	83 ec 04             	sub    $0x4,%esp
80102477:	50                   	push   %eax
80102478:	ff 75 f4             	pushl  -0xc(%ebp)
8010247b:	ff 75 0c             	pushl  0xc(%ebp)
8010247e:	e8 14 47 00 00       	call   80106b97 <memmove>
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
801026d3:	68 ea a0 10 80       	push   $0x8010a0ea
801026d8:	68 20 d6 10 80       	push   $0x8010d620
801026dd:	e8 71 41 00 00       	call   80106853 <initlock>
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
80102787:	68 ee a0 10 80       	push   $0x8010a0ee
8010278c:	e8 d5 dd ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE)
80102791:	8b 45 08             	mov    0x8(%ebp),%eax
80102794:	8b 40 08             	mov    0x8(%eax),%eax
80102797:	3d cf 07 00 00       	cmp    $0x7cf,%eax
8010279c:	76 0d                	jbe    801027ab <idestart+0x33>
    panic("incorrect blockno");
8010279e:	83 ec 0c             	sub    $0xc,%esp
801027a1:	68 f7 a0 10 80       	push   $0x8010a0f7
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
801027ca:	68 ee a0 10 80       	push   $0x8010a0ee
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
801028e4:	e8 8c 3f 00 00       	call   80106875 <acquire>
801028e9:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
801028ec:	a1 54 d6 10 80       	mov    0x8010d654,%eax
801028f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801028f8:	75 15                	jne    8010290f <ideintr+0x39>
    release(&idelock);
801028fa:	83 ec 0c             	sub    $0xc,%esp
801028fd:	68 20 d6 10 80       	push   $0x8010d620
80102902:	e8 d5 3f 00 00       	call   801068dc <release>
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
80102977:	e8 95 2e 00 00       	call   80105811 <wakeup>
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
801029a1:	e8 36 3f 00 00       	call   801068dc <release>
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
801029c0:	68 09 a1 10 80       	push   $0x8010a109
801029c5:	e8 9c db ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801029ca:	8b 45 08             	mov    0x8(%ebp),%eax
801029cd:	8b 00                	mov    (%eax),%eax
801029cf:	83 e0 06             	and    $0x6,%eax
801029d2:	83 f8 02             	cmp    $0x2,%eax
801029d5:	75 0d                	jne    801029e4 <iderw+0x39>
    panic("iderw: nothing to do");
801029d7:	83 ec 0c             	sub    $0xc,%esp
801029da:	68 1d a1 10 80       	push   $0x8010a11d
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
801029fa:	68 32 a1 10 80       	push   $0x8010a132
801029ff:	e8 62 db ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102a04:	83 ec 0c             	sub    $0xc,%esp
80102a07:	68 20 d6 10 80       	push   $0x8010d620
80102a0c:	e8 64 3e 00 00       	call   80106875 <acquire>
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
80102a68:	e8 2c 2b 00 00       	call   80105599 <sleep>
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
80102a85:	e8 52 3e 00 00       	call   801068dc <release>
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
80102b16:	68 50 a1 10 80       	push   $0x8010a150
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
80102bd6:	68 82 a1 10 80       	push   $0x8010a182
80102bdb:	68 40 42 11 80       	push   $0x80114240
80102be0:	e8 6e 3c 00 00       	call   80106853 <initlock>
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
80102c97:	68 87 a1 10 80       	push   $0x8010a187
80102c9c:	e8 c5 d8 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102ca1:	83 ec 04             	sub    $0x4,%esp
80102ca4:	68 00 10 00 00       	push   $0x1000
80102ca9:	6a 01                	push   $0x1
80102cab:	ff 75 08             	pushl  0x8(%ebp)
80102cae:	e8 25 3e 00 00       	call   80106ad8 <memset>
80102cb3:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102cb6:	a1 74 42 11 80       	mov    0x80114274,%eax
80102cbb:	85 c0                	test   %eax,%eax
80102cbd:	74 10                	je     80102ccf <kfree+0x68>
    acquire(&kmem.lock);
80102cbf:	83 ec 0c             	sub    $0xc,%esp
80102cc2:	68 40 42 11 80       	push   $0x80114240
80102cc7:	e8 a9 3b 00 00       	call   80106875 <acquire>
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
80102cf9:	e8 de 3b 00 00       	call   801068dc <release>
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
80102d1b:	e8 55 3b 00 00       	call   80106875 <acquire>
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
80102d4c:	e8 8b 3b 00 00       	call   801068dc <release>
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
80103097:	68 90 a1 10 80       	push   $0x8010a190
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
801032c2:	e8 78 38 00 00       	call   80106b3f <memcmp>
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
801033d6:	68 bc a1 10 80       	push   $0x8010a1bc
801033db:	68 80 42 11 80       	push   $0x80114280
801033e0:	e8 6e 34 00 00       	call   80106853 <initlock>
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
8010348b:	e8 07 37 00 00       	call   80106b97 <memmove>
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
801035f9:	e8 77 32 00 00       	call   80106875 <acquire>
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
80103617:	e8 7d 1f 00 00       	call   80105599 <sleep>
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
8010364c:	e8 48 1f 00 00       	call   80105599 <sleep>
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
8010366b:	e8 6c 32 00 00       	call   801068dc <release>
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
8010368c:	e8 e4 31 00 00       	call   80106875 <acquire>
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
801036ad:	68 c0 a1 10 80       	push   $0x8010a1c0
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
801036db:	e8 31 21 00 00       	call   80105811 <wakeup>
801036e0:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801036e3:	83 ec 0c             	sub    $0xc,%esp
801036e6:	68 80 42 11 80       	push   $0x80114280
801036eb:	e8 ec 31 00 00       	call   801068dc <release>
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
80103706:	e8 6a 31 00 00       	call   80106875 <acquire>
8010370b:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010370e:	c7 05 c0 42 11 80 00 	movl   $0x0,0x801142c0
80103715:	00 00 00 
    wakeup(&log);
80103718:	83 ec 0c             	sub    $0xc,%esp
8010371b:	68 80 42 11 80       	push   $0x80114280
80103720:	e8 ec 20 00 00       	call   80105811 <wakeup>
80103725:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103728:	83 ec 0c             	sub    $0xc,%esp
8010372b:	68 80 42 11 80       	push   $0x80114280
80103730:	e8 a7 31 00 00       	call   801068dc <release>
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
801037ac:	e8 e6 33 00 00       	call   80106b97 <memmove>
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
80103848:	68 cf a1 10 80       	push   $0x8010a1cf
8010384d:	e8 14 cd ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
80103852:	a1 bc 42 11 80       	mov    0x801142bc,%eax
80103857:	85 c0                	test   %eax,%eax
80103859:	7f 0d                	jg     80103868 <log_write+0x45>
    panic("log_write outside of trans");
8010385b:	83 ec 0c             	sub    $0xc,%esp
8010385e:	68 e5 a1 10 80       	push   $0x8010a1e5
80103863:	e8 fe cc ff ff       	call   80100566 <panic>

  acquire(&log.lock);
80103868:	83 ec 0c             	sub    $0xc,%esp
8010386b:	68 80 42 11 80       	push   $0x80114280
80103870:	e8 00 30 00 00       	call   80106875 <acquire>
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
801038ee:	e8 e9 2f 00 00       	call   801068dc <release>
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
80103953:	e8 76 5e 00 00       	call   801097ce <kvmalloc>
  mpinit();        // collect info about this machine
80103958:	e8 43 04 00 00       	call   80103da0 <mpinit>
  lapicinit();
8010395d:	e8 ea f5 ff ff       	call   80102f4c <lapicinit>
  seginit();       // set up segments
80103962:	e8 10 58 00 00       	call   80109177 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103967:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010396d:	0f b6 00             	movzbl (%eax),%eax
80103970:	0f b6 c0             	movzbl %al,%eax
80103973:	83 ec 08             	sub    $0x8,%esp
80103976:	50                   	push   %eax
80103977:	68 00 a2 10 80       	push   $0x8010a200
8010397c:	e8 45 ca ff ff       	call   801003c6 <cprintf>
80103981:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
80103984:	e8 6d 06 00 00       	call   80103ff6 <picinit>
  ioapicinit();    // another interrupt controller
80103989:	e8 34 f1 ff ff       	call   80102ac2 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010398e:	e8 24 d2 ff ff       	call   80100bb7 <consoleinit>
  uartinit();      // serial port
80103993:	e8 3b 4b 00 00       	call   801084d3 <uartinit>
  pinit();         // process table
80103998:	e8 5d 0b 00 00       	call   801044fa <pinit>
  tvinit();        // trap vectors
8010399d:	e8 0a 47 00 00       	call   801080ac <tvinit>
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
801039ba:	e8 3e 46 00 00       	call   80107ffd <timerinit>
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
801039e9:	e8 f8 5d 00 00       	call   801097e6 <switchkvm>
  seginit();
801039ee:	e8 84 57 00 00       	call   80109177 <seginit>
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
80103a13:	68 17 a2 10 80       	push   $0x8010a217
80103a18:	e8 a9 c9 ff ff       	call   801003c6 <cprintf>
80103a1d:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103a20:	e8 e8 47 00 00       	call   8010820d <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103a25:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103a2b:	05 a8 00 00 00       	add    $0xa8,%eax
80103a30:	83 ec 08             	sub    $0x8,%esp
80103a33:	6a 01                	push   $0x1
80103a35:	50                   	push   %eax
80103a36:	e8 d8 fe ff ff       	call   80103913 <xchg>
80103a3b:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103a3e:	e8 40 17 00 00       	call   80105183 <scheduler>

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
80103a6b:	e8 27 31 00 00       	call   80106b97 <memmove>
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
80103bf9:	68 28 a2 10 80       	push   $0x8010a228
80103bfe:	ff 75 f4             	pushl  -0xc(%ebp)
80103c01:	e8 39 2f 00 00       	call   80106b3f <memcmp>
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
80103d37:	68 2d a2 10 80       	push   $0x8010a22d
80103d3c:	ff 75 f0             	pushl  -0x10(%ebp)
80103d3f:	e8 fb 2d 00 00       	call   80106b3f <memcmp>
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
80103e13:	8b 04 85 70 a2 10 80 	mov    -0x7fef5d90(,%eax,4),%eax
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
80103e49:	68 32 a2 10 80       	push   $0x8010a232
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
80103edc:	68 50 a2 10 80       	push   $0x8010a250
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
8010417d:	68 84 a2 10 80       	push   $0x8010a284
80104182:	50                   	push   %eax
80104183:	e8 cb 26 00 00       	call   80106853 <initlock>
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
8010423f:	e8 31 26 00 00       	call   80106875 <acquire>
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
80104266:	e8 a6 15 00 00       	call   80105811 <wakeup>
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
80104289:	e8 83 15 00 00       	call   80105811 <wakeup>
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
801042b2:	e8 25 26 00 00       	call   801068dc <release>
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
801042d1:	e8 06 26 00 00       	call   801068dc <release>
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
801042e9:	e8 87 25 00 00       	call   80106875 <acquire>
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
8010431e:	e8 b9 25 00 00       	call   801068dc <release>
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
8010433c:	e8 d0 14 00 00       	call   80105811 <wakeup>
80104341:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104344:	8b 45 08             	mov    0x8(%ebp),%eax
80104347:	8b 55 08             	mov    0x8(%ebp),%edx
8010434a:	81 c2 38 02 00 00    	add    $0x238,%edx
80104350:	83 ec 08             	sub    $0x8,%esp
80104353:	50                   	push   %eax
80104354:	52                   	push   %edx
80104355:	e8 3f 12 00 00       	call   80105599 <sleep>
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
801043be:	e8 4e 14 00 00       	call   80105811 <wakeup>
801043c3:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801043c6:	8b 45 08             	mov    0x8(%ebp),%eax
801043c9:	83 ec 0c             	sub    $0xc,%esp
801043cc:	50                   	push   %eax
801043cd:	e8 0a 25 00 00       	call   801068dc <release>
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
801043e8:	e8 88 24 00 00       	call   80106875 <acquire>
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
80104406:	e8 d1 24 00 00       	call   801068dc <release>
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
80104429:	e8 6b 11 00 00       	call   80105599 <sleep>
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
801044bd:	e8 4f 13 00 00       	call   80105811 <wakeup>
801044c2:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801044c5:	8b 45 08             	mov    0x8(%ebp),%eax
801044c8:	83 ec 0c             	sub    $0xc,%esp
801044cb:	50                   	push   %eax
801044cc:	e8 0b 24 00 00       	call   801068dc <release>
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
80104503:	68 8c a2 10 80       	push   $0x8010a28c
80104508:	68 80 49 11 80       	push   $0x80114980
8010450d:	e8 41 23 00 00       	call   80106853 <initlock>
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
80104526:	e8 4a 23 00 00       	call   80106875 <acquire>
8010452b:	83 c4 10             	add    $0x10,%esp
#ifndef CS333_P3P4
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
#else
  p = ptable.pLists.free;
8010452e:	a1 ec 70 11 80       	mov    0x801170ec,%eax
80104533:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p)
80104536:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010453a:	75 1a                	jne    80104556 <allocproc+0x3e>
    goto found;
#endif
  release(&ptable.lock);
8010453c:	83 ec 0c             	sub    $0xc,%esp
8010453f:	68 80 49 11 80       	push   $0x80114980
80104544:	e8 93 23 00 00       	call   801068dc <release>
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
80104567:	68 f0 70 11 80       	push   $0x801170f0
8010456c:	68 ec 70 11 80       	push   $0x801170ec
80104571:	e8 e1 17 00 00       	call   80105d57 <stateListRemove>
80104576:	83 c4 10             	add    $0x10,%esp
80104579:	85 c0                	test   %eax,%eax
8010457b:	74 0d                	je     8010458a <allocproc+0x72>
    panic("error removing from free list.");
8010457d:	83 ec 0c             	sub    $0xc,%esp
80104580:	68 94 a2 10 80       	push   $0x8010a294
80104585:	e8 dc bf ff ff       	call   80100566 <panic>
  if(stateListAdd(&ptable.pLists.embryo, &ptable.pLists.embryoTail,p))
8010458a:	83 ec 04             	sub    $0x4,%esp
8010458d:	ff 75 f4             	pushl  -0xc(%ebp)
80104590:	68 10 71 11 80       	push   $0x80117110
80104595:	68 0c 71 11 80       	push   $0x8011710c
8010459a:	e8 59 17 00 00       	call   80105cf8 <stateListAdd>
8010459f:	83 c4 10             	add    $0x10,%esp
801045a2:	85 c0                	test   %eax,%eax
801045a4:	74 0d                	je     801045b3 <allocproc+0x9b>
    panic("error adding to embryo list.");
801045a6:	83 ec 0c             	sub    $0xc,%esp
801045a9:	68 b3 a2 10 80       	push   $0x8010a2b3
801045ae:	e8 b3 bf ff ff       	call   80100566 <panic>
  assertState(p, EMBRYO);
801045b3:	83 ec 08             	sub    $0x8,%esp
801045b6:	6a 01                	push   $0x1
801045b8:	ff 75 f4             	pushl  -0xc(%ebp)
801045bb:	e8 f4 1d 00 00       	call   801063b4 <assertState>
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
8010463b:	e8 9c 22 00 00       	call   801068dc <release>
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
8010466a:	68 10 71 11 80       	push   $0x80117110
8010466f:	68 0c 71 11 80       	push   $0x8011710c
80104674:	e8 de 16 00 00       	call   80105d57 <stateListRemove>
80104679:	83 c4 10             	add    $0x10,%esp
8010467c:	85 c0                	test   %eax,%eax
8010467e:	74 0d                	je     8010468d <allocproc+0x175>
      panic("error removing from embryo list.");
80104680:	83 ec 0c             	sub    $0xc,%esp
80104683:	68 d0 a2 10 80       	push   $0x8010a2d0
80104688:	e8 d9 be ff ff       	call   80100566 <panic>
    if(stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail,p))
8010468d:	83 ec 04             	sub    $0x4,%esp
80104690:	ff 75 f4             	pushl  -0xc(%ebp)
80104693:	68 f0 70 11 80       	push   $0x801170f0
80104698:	68 ec 70 11 80       	push   $0x801170ec
8010469d:	e8 56 16 00 00       	call   80105cf8 <stateListAdd>
801046a2:	83 c4 10             	add    $0x10,%esp
801046a5:	85 c0                	test   %eax,%eax
801046a7:	74 0d                	je     801046b6 <allocproc+0x19e>
      panic("error adding to free list.");
801046a9:	83 ec 0c             	sub    $0xc,%esp
801046ac:	68 f1 a2 10 80       	push   $0x8010a2f1
801046b1:	e8 b0 be ff ff       	call   80100566 <panic>
    assertState(p, UNUSED);
801046b6:	83 ec 08             	sub    $0x8,%esp
801046b9:	6a 00                	push   $0x0
801046bb:	ff 75 f4             	pushl  -0xc(%ebp)
801046be:	e8 f1 1c 00 00       	call   801063b4 <assertState>
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
801046ec:	ba 5a 80 10 80       	mov    $0x8010805a,%edx
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
80104711:	e8 c2 23 00 00       	call   80106ad8 <memset>
80104716:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104719:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010471c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010471f:	ba 53 55 10 80       	mov    $0x80105553,%edx
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
8010473a:	e8 36 21 00 00       	call   80106875 <acquire>
8010473f:	83 c4 10             	add    $0x10,%esp
  initProcessLists();
80104742:	e8 df 16 00 00       	call   80105e26 <initProcessLists>
  initFreeList();
80104747:	e8 80 17 00 00       	call   80105ecc <initFreeList>
  ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
8010474c:	a1 20 79 11 80       	mov    0x80117920,%eax
80104751:	05 f4 01 00 00       	add    $0x1f4,%eax
80104756:	a3 14 71 11 80       	mov    %eax,0x80117114
  release(&ptable.lock);
8010475b:	83 ec 0c             	sub    $0xc,%esp
8010475e:	68 80 49 11 80       	push   $0x80114980
80104763:	e8 74 21 00 00       	call   801068dc <release>
80104768:	83 c4 10             	add    $0x10,%esp
#endif
  p = allocproc();
8010476b:	e8 a8 fd ff ff       	call   80104518 <allocproc>
80104770:	89 45 f4             	mov    %eax,-0xc(%ebp)

  initproc = p;
80104773:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104776:	a3 68 d6 10 80       	mov    %eax,0x8010d668
  if((p->pgdir = setupkvm()) == 0)
8010477b:	e8 9c 4f 00 00       	call   8010971c <setupkvm>
80104780:	89 c2                	mov    %eax,%edx
80104782:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104785:	89 50 04             	mov    %edx,0x4(%eax)
80104788:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010478b:	8b 40 04             	mov    0x4(%eax),%eax
8010478e:	85 c0                	test   %eax,%eax
80104790:	75 0d                	jne    8010479f <userinit+0x73>
    panic("userinit: out of memory?");
80104792:	83 ec 0c             	sub    $0xc,%esp
80104795:	68 0c a3 10 80       	push   $0x8010a30c
8010479a:	e8 c7 bd ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010479f:	ba 2c 00 00 00       	mov    $0x2c,%edx
801047a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047a7:	8b 40 04             	mov    0x4(%eax),%eax
801047aa:	83 ec 04             	sub    $0x4,%esp
801047ad:	52                   	push   %edx
801047ae:	68 00 d5 10 80       	push   $0x8010d500
801047b3:	50                   	push   %eax
801047b4:	e8 bd 51 00 00       	call   80109976 <inituvm>
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
801047d3:	e8 00 23 00 00       	call   80106ad8 <memset>
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
8010484d:	68 25 a3 10 80       	push   $0x8010a325
80104852:	50                   	push   %eax
80104853:	e8 83 24 00 00       	call   80106cdb <safestrcpy>
80104858:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
8010485b:	83 ec 0c             	sub    $0xc,%esp
8010485e:	68 2e a3 10 80       	push   $0x8010a32e
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
80104885:	e8 eb 1f 00 00       	call   80106875 <acquire>
8010488a:	83 c4 10             	add    $0x10,%esp
  if(stateListRemove(&ptable.pLists.embryo, &ptable.pLists.embryoTail, p))
8010488d:	83 ec 04             	sub    $0x4,%esp
80104890:	ff 75 f4             	pushl  -0xc(%ebp)
80104893:	68 10 71 11 80       	push   $0x80117110
80104898:	68 0c 71 11 80       	push   $0x8011710c
8010489d:	e8 b5 14 00 00       	call   80105d57 <stateListRemove>
801048a2:	83 c4 10             	add    $0x10,%esp
801048a5:	85 c0                	test   %eax,%eax
801048a7:	74 0d                	je     801048b6 <userinit+0x18a>
    panic("error removing from embryo list.");
801048a9:	83 ec 0c             	sub    $0xc,%esp
801048ac:	68 d0 a2 10 80       	push   $0x8010a2d0
801048b1:	e8 b0 bc ff ff       	call   80100566 <panic>
  if(stateListAdd(&ptable.pLists.ready[p->priority], &ptable.pLists.readyTail[p->priority], p))
801048b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b9:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801048bf:	05 d0 09 00 00       	add    $0x9d0,%eax
801048c4:	c1 e0 02             	shl    $0x2,%eax
801048c7:	05 80 49 11 80       	add    $0x80114980,%eax
801048cc:	8d 50 10             	lea    0x10(%eax),%edx
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
801048f0:	e8 03 14 00 00       	call   80105cf8 <stateListAdd>
801048f5:	83 c4 10             	add    $0x10,%esp
801048f8:	85 c0                	test   %eax,%eax
801048fa:	74 0d                	je     80104909 <userinit+0x1dd>
    panic("error adding to ready list.");
801048fc:	83 ec 0c             	sub    $0xc,%esp
801048ff:	68 30 a3 10 80       	push   $0x8010a330
80104904:	e8 5d bc ff ff       	call   80100566 <panic>
  assertState(p, RUNNABLE);
80104909:	83 ec 08             	sub    $0x8,%esp
8010490c:	6a 03                	push   $0x3
8010490e:	ff 75 f4             	pushl  -0xc(%ebp)
80104911:	e8 9e 1a 00 00       	call   801063b4 <assertState>
80104916:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104919:	83 ec 0c             	sub    $0xc,%esp
8010491c:	68 80 49 11 80       	push   $0x80114980
80104921:	e8 b6 1f 00 00       	call   801068dc <release>
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
80104976:	e8 48 51 00 00       	call   80109ac3 <allocuvm>
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
801049ad:	e8 da 51 00 00       	call   80109b8c <deallocuvm>
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
801049da:	e8 24 4e 00 00       	call   80109803 <switchuvm>
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
80104a05:	e9 a4 02 00 00       	jmp    80104cae <fork+0x2c5>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104a0a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a10:	8b 10                	mov    (%eax),%edx
80104a12:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a18:	8b 40 04             	mov    0x4(%eax),%eax
80104a1b:	83 ec 08             	sub    $0x8,%esp
80104a1e:	52                   	push   %edx
80104a1f:	50                   	push   %eax
80104a20:	e8 05 53 00 00       	call   80109d2a <copyuvm>
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
80104a6c:	e8 04 1e 00 00       	call   80106875 <acquire>
80104a71:	83 c4 10             	add    $0x10,%esp
    if(stateListRemove(&ptable.pLists.embryo, &ptable.pLists.embryoTail, np))
80104a74:	83 ec 04             	sub    $0x4,%esp
80104a77:	ff 75 e0             	pushl  -0x20(%ebp)
80104a7a:	68 10 71 11 80       	push   $0x80117110
80104a7f:	68 0c 71 11 80       	push   $0x8011710c
80104a84:	e8 ce 12 00 00       	call   80105d57 <stateListRemove>
80104a89:	83 c4 10             	add    $0x10,%esp
80104a8c:	85 c0                	test   %eax,%eax
80104a8e:	74 0d                	je     80104a9d <fork+0xb4>
      panic("error removing from embryo.");
80104a90:	83 ec 0c             	sub    $0xc,%esp
80104a93:	68 4c a3 10 80       	push   $0x8010a34c
80104a98:	e8 c9 ba ff ff       	call   80100566 <panic>
    if(stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail, np))
80104a9d:	83 ec 04             	sub    $0x4,%esp
80104aa0:	ff 75 e0             	pushl  -0x20(%ebp)
80104aa3:	68 f0 70 11 80       	push   $0x801170f0
80104aa8:	68 ec 70 11 80       	push   $0x801170ec
80104aad:	e8 46 12 00 00       	call   80105cf8 <stateListAdd>
80104ab2:	83 c4 10             	add    $0x10,%esp
80104ab5:	85 c0                	test   %eax,%eax
80104ab7:	74 0d                	je     80104ac6 <fork+0xdd>
      panic("error adding to freelist.");
80104ab9:	83 ec 0c             	sub    $0xc,%esp
80104abc:	68 68 a3 10 80       	push   $0x8010a368
80104ac1:	e8 a0 ba ff ff       	call   80100566 <panic>
    assertState(np, UNUSED);
80104ac6:	83 ec 08             	sub    $0x8,%esp
80104ac9:	6a 00                	push   $0x0
80104acb:	ff 75 e0             	pushl  -0x20(%ebp)
80104ace:	e8 e1 18 00 00       	call   801063b4 <assertState>
80104ad3:	83 c4 10             	add    $0x10,%esp
    release(&ptable.lock);
80104ad6:	83 ec 0c             	sub    $0xc,%esp
80104ad9:	68 80 49 11 80       	push   $0x80114980
80104ade:	e8 f9 1d 00 00       	call   801068dc <release>
80104ae3:	83 c4 10             	add    $0x10,%esp
#endif
    return -1;
80104ae6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104aeb:	e9 be 01 00 00       	jmp    80104cae <fork+0x2c5>
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
80104bba:	e8 1c 21 00 00       	call   80106cdb <safestrcpy>
80104bbf:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104bc2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104bc5:	8b 40 10             	mov    0x10(%eax),%eax
80104bc8:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104bcb:	83 ec 0c             	sub    $0xc,%esp
80104bce:	68 80 49 11 80       	push   $0x80114980
80104bd3:	e8 9d 1c 00 00       	call   80106875 <acquire>
80104bd8:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
80104bdb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104bde:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
#ifdef CS333_P3P4
  if(stateListRemove(&ptable.pLists.embryo, &ptable.pLists.embryoTail, np))
80104be5:	83 ec 04             	sub    $0x4,%esp
80104be8:	ff 75 e0             	pushl  -0x20(%ebp)
80104beb:	68 10 71 11 80       	push   $0x80117110
80104bf0:	68 0c 71 11 80       	push   $0x8011710c
80104bf5:	e8 5d 11 00 00       	call   80105d57 <stateListRemove>
80104bfa:	83 c4 10             	add    $0x10,%esp
80104bfd:	85 c0                	test   %eax,%eax
80104bff:	74 0d                	je     80104c0e <fork+0x225>
    panic("error removing from embryo.");
80104c01:	83 ec 0c             	sub    $0xc,%esp
80104c04:	68 4c a3 10 80       	push   $0x8010a34c
80104c09:	e8 58 b9 ff ff       	call   80100566 <panic>
  if(stateListAdd(&ptable.pLists.ready[np->priority], &ptable.pLists.readyTail[np->priority], np))
80104c0e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c11:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80104c17:	05 d0 09 00 00       	add    $0x9d0,%eax
80104c1c:	c1 e0 02             	shl    $0x2,%eax
80104c1f:	05 80 49 11 80       	add    $0x80114980,%eax
80104c24:	8d 50 10             	lea    0x10(%eax),%edx
80104c27:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c2a:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80104c30:	05 cc 09 00 00       	add    $0x9cc,%eax
80104c35:	c1 e0 02             	shl    $0x2,%eax
80104c38:	05 80 49 11 80       	add    $0x80114980,%eax
80104c3d:	83 c0 04             	add    $0x4,%eax
80104c40:	83 ec 04             	sub    $0x4,%esp
80104c43:	ff 75 e0             	pushl  -0x20(%ebp)
80104c46:	52                   	push   %edx
80104c47:	50                   	push   %eax
80104c48:	e8 ab 10 00 00       	call   80105cf8 <stateListAdd>
80104c4d:	83 c4 10             	add    $0x10,%esp
80104c50:	85 c0                	test   %eax,%eax
80104c52:	74 0d                	je     80104c61 <fork+0x278>
    panic("error adding to ready list.");
80104c54:	83 ec 0c             	sub    $0xc,%esp
80104c57:	68 30 a3 10 80       	push   $0x8010a330
80104c5c:	e8 05 b9 ff ff       	call   80100566 <panic>
  assertState(np, RUNNABLE);
80104c61:	83 ec 08             	sub    $0x8,%esp
80104c64:	6a 03                	push   $0x3
80104c66:	ff 75 e0             	pushl  -0x20(%ebp)
80104c69:	e8 46 17 00 00       	call   801063b4 <assertState>
80104c6e:	83 c4 10             	add    $0x10,%esp
#endif
  release(&ptable.lock);
80104c71:	83 ec 0c             	sub    $0xc,%esp
80104c74:	68 80 49 11 80       	push   $0x80114980
80104c79:	e8 5e 1c 00 00       	call   801068dc <release>
80104c7e:	83 c4 10             	add    $0x10,%esp

  np->uid = proc->uid;
80104c81:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c87:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104c8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c90:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  np->gid = proc->gid;
80104c96:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c9c:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80104ca2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ca5:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)

  return pid;
80104cab:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104cae:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104cb1:	5b                   	pop    %ebx
80104cb2:	5e                   	pop    %esi
80104cb3:	5f                   	pop    %edi
80104cb4:	5d                   	pop    %ebp
80104cb5:	c3                   	ret    

80104cb6 <exit>:
  panic("zombie exit");
}
#else
void
exit(void)
{
80104cb6:	55                   	push   %ebp
80104cb7:	89 e5                	mov    %esp,%ebp
80104cb9:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104cbc:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104cc3:	a1 68 d6 10 80       	mov    0x8010d668,%eax
80104cc8:	39 c2                	cmp    %eax,%edx
80104cca:	75 0d                	jne    80104cd9 <exit+0x23>
    panic("init exiting");
80104ccc:	83 ec 0c             	sub    $0xc,%esp
80104ccf:	68 82 a3 10 80       	push   $0x8010a382
80104cd4:	e8 8d b8 ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104cd9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104ce0:	eb 48                	jmp    80104d2a <exit+0x74>
    if(proc->ofile[fd]){
80104ce2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ce8:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ceb:	83 c2 08             	add    $0x8,%edx
80104cee:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104cf2:	85 c0                	test   %eax,%eax
80104cf4:	74 30                	je     80104d26 <exit+0x70>
      fileclose(proc->ofile[fd]);
80104cf6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cfc:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104cff:	83 c2 08             	add    $0x8,%edx
80104d02:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104d06:	83 ec 0c             	sub    $0xc,%esp
80104d09:	50                   	push   %eax
80104d0a:	e8 e0 c3 ff ff       	call   801010ef <fileclose>
80104d0f:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80104d12:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d18:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d1b:	83 c2 08             	add    $0x8,%edx
80104d1e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104d25:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104d26:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104d2a:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104d2e:	7e b2                	jle    80104ce2 <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104d30:	e8 b6 e8 ff ff       	call   801035eb <begin_op>
  iput(proc->cwd);
80104d35:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d3b:	8b 40 68             	mov    0x68(%eax),%eax
80104d3e:	83 ec 0c             	sub    $0xc,%esp
80104d41:	50                   	push   %eax
80104d42:	e8 91 ce ff ff       	call   80101bd8 <iput>
80104d47:	83 c4 10             	add    $0x10,%esp
  end_op();
80104d4a:	e8 28 e9 ff ff       	call   80103677 <end_op>
  proc->cwd = 0;
80104d4f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d55:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104d5c:	83 ec 0c             	sub    $0xc,%esp
80104d5f:	68 80 49 11 80       	push   $0x80114980
80104d64:	e8 0c 1b 00 00       	call   80106875 <acquire>
80104d69:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104d6c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d72:	8b 40 14             	mov    0x14(%eax),%eax
80104d75:	83 ec 0c             	sub    $0xc,%esp
80104d78:	50                   	push   %eax
80104d79:	e8 c2 09 00 00       	call   80105740 <wakeup1>
80104d7e:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(int i = 0; i<MAXPRIO+1 ; ++i)
80104d81:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80104d88:	eb 46                	jmp    80104dd0 <exit+0x11a>
  {
    for(p = ptable.pLists.ready[i];p;p=p->next)
80104d8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d8d:	05 cc 09 00 00       	add    $0x9cc,%eax
80104d92:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
80104d99:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104d9c:	eb 28                	jmp    80104dc6 <exit+0x110>
    {
      if(p->parent == proc)
80104d9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104da1:	8b 50 14             	mov    0x14(%eax),%edx
80104da4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104daa:	39 c2                	cmp    %eax,%edx
80104dac:	75 0c                	jne    80104dba <exit+0x104>
        p->parent = initproc;
80104dae:	8b 15 68 d6 10 80    	mov    0x8010d668,%edx
80104db4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104db7:	89 50 14             	mov    %edx,0x14(%eax)
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(int i = 0; i<MAXPRIO+1 ; ++i)
  {
    for(p = ptable.pLists.ready[i];p;p=p->next)
80104dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dbd:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104dc3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104dc6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104dca:	75 d2                	jne    80104d9e <exit+0xe8>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(int i = 0; i<MAXPRIO+1 ; ++i)
80104dcc:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80104dd0:	83 7d ec 06          	cmpl   $0x6,-0x14(%ebp)
80104dd4:	7e b4                	jle    80104d8a <exit+0xd4>
    {
      if(p->parent == proc)
        p->parent = initproc;
    }
  }
  for(p = ptable.pLists.sleep;p;p=p->next)
80104dd6:	a1 f4 70 11 80       	mov    0x801170f4,%eax
80104ddb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104dde:	eb 28                	jmp    80104e08 <exit+0x152>
  {
    if(p->parent == proc)
80104de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104de3:	8b 50 14             	mov    0x14(%eax),%edx
80104de6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dec:	39 c2                	cmp    %eax,%edx
80104dee:	75 0c                	jne    80104dfc <exit+0x146>
      p->parent = initproc;
80104df0:	8b 15 68 d6 10 80    	mov    0x8010d668,%edx
80104df6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104df9:	89 50 14             	mov    %edx,0x14(%eax)
    {
      if(p->parent == proc)
        p->parent = initproc;
    }
  }
  for(p = ptable.pLists.sleep;p;p=p->next)
80104dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dff:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104e05:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e08:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e0c:	75 d2                	jne    80104de0 <exit+0x12a>
  {
    if(p->parent == proc)
      p->parent = initproc;
  }
  for(p = ptable.pLists.embryo;p;p=p->next)
80104e0e:	a1 0c 71 11 80       	mov    0x8011710c,%eax
80104e13:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e16:	eb 28                	jmp    80104e40 <exit+0x18a>
  {
    if(p->parent == proc)
80104e18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e1b:	8b 50 14             	mov    0x14(%eax),%edx
80104e1e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e24:	39 c2                	cmp    %eax,%edx
80104e26:	75 0c                	jne    80104e34 <exit+0x17e>
      p->parent = initproc;
80104e28:	8b 15 68 d6 10 80    	mov    0x8010d668,%edx
80104e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e31:	89 50 14             	mov    %edx,0x14(%eax)
  for(p = ptable.pLists.sleep;p;p=p->next)
  {
    if(p->parent == proc)
      p->parent = initproc;
  }
  for(p = ptable.pLists.embryo;p;p=p->next)
80104e34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e37:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104e3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e40:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e44:	75 d2                	jne    80104e18 <exit+0x162>
  {
    if(p->parent == proc)
      p->parent = initproc;
  }
  for(p=ptable.pLists.running;p;p=p->next)
80104e46:	a1 04 71 11 80       	mov    0x80117104,%eax
80104e4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e4e:	eb 28                	jmp    80104e78 <exit+0x1c2>
  {
    if(p->parent == proc)
80104e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e53:	8b 50 14             	mov    0x14(%eax),%edx
80104e56:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e5c:	39 c2                	cmp    %eax,%edx
80104e5e:	75 0c                	jne    80104e6c <exit+0x1b6>
      p->parent = initproc;
80104e60:	8b 15 68 d6 10 80    	mov    0x8010d668,%edx
80104e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e69:	89 50 14             	mov    %edx,0x14(%eax)
  for(p = ptable.pLists.embryo;p;p=p->next)
  {
    if(p->parent == proc)
      p->parent = initproc;
  }
  for(p=ptable.pLists.running;p;p=p->next)
80104e6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e6f:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104e75:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e78:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e7c:	75 d2                	jne    80104e50 <exit+0x19a>
    if(p->parent == proc)
      p->parent = initproc;
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104e7e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e84:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  if(stateListRemove(&ptable.pLists.running, &ptable.pLists.runningTail, proc))
80104e8b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e91:	83 ec 04             	sub    $0x4,%esp
80104e94:	50                   	push   %eax
80104e95:	68 08 71 11 80       	push   $0x80117108
80104e9a:	68 04 71 11 80       	push   $0x80117104
80104e9f:	e8 b3 0e 00 00       	call   80105d57 <stateListRemove>
80104ea4:	83 c4 10             	add    $0x10,%esp
80104ea7:	85 c0                	test   %eax,%eax
80104ea9:	74 0d                	je     80104eb8 <exit+0x202>
    panic("Error removing from running.");
80104eab:	83 ec 0c             	sub    $0xc,%esp
80104eae:	68 8f a3 10 80       	push   $0x8010a38f
80104eb3:	e8 ae b6 ff ff       	call   80100566 <panic>
  if(stateListAdd(&ptable.pLists.zombie, &ptable.pLists.zombieTail, proc))
80104eb8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ebe:	83 ec 04             	sub    $0x4,%esp
80104ec1:	50                   	push   %eax
80104ec2:	68 00 71 11 80       	push   $0x80117100
80104ec7:	68 fc 70 11 80       	push   $0x801170fc
80104ecc:	e8 27 0e 00 00       	call   80105cf8 <stateListAdd>
80104ed1:	83 c4 10             	add    $0x10,%esp
80104ed4:	85 c0                	test   %eax,%eax
80104ed6:	74 0d                	je     80104ee5 <exit+0x22f>
    panic("error adding to zombie list.");
80104ed8:	83 ec 0c             	sub    $0xc,%esp
80104edb:	68 ac a3 10 80       	push   $0x8010a3ac
80104ee0:	e8 81 b6 ff ff       	call   80100566 <panic>
  assertState(proc, ZOMBIE);
80104ee5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104eeb:	83 ec 08             	sub    $0x8,%esp
80104eee:	6a 05                	push   $0x5
80104ef0:	50                   	push   %eax
80104ef1:	e8 be 14 00 00       	call   801063b4 <assertState>
80104ef6:	83 c4 10             	add    $0x10,%esp
  sched();
80104ef9:	e8 48 04 00 00       	call   80105346 <sched>
  panic("zombie exit");
80104efe:	83 ec 0c             	sub    $0xc,%esp
80104f01:	68 c9 a3 10 80       	push   $0x8010a3c9
80104f06:	e8 5b b6 ff ff       	call   80100566 <panic>

80104f0b <wait>:
  }
}
#else
int
wait(void)
{
80104f0b:	55                   	push   %ebp
80104f0c:	89 e5                	mov    %esp,%ebp
80104f0e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104f11:	83 ec 0c             	sub    $0xc,%esp
80104f14:	68 80 49 11 80       	push   $0x80114980
80104f19:	e8 57 19 00 00       	call   80106875 <acquire>
80104f1e:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104f21:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.pLists.zombie; p; p=p->next){
80104f28:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80104f2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104f30:	e9 08 01 00 00       	jmp    8010503d <wait+0x132>
      if(p->parent != proc)
80104f35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f38:	8b 50 14             	mov    0x14(%eax),%edx
80104f3b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f41:	39 c2                	cmp    %eax,%edx
80104f43:	74 11                	je     80104f56 <wait+0x4b>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.pLists.zombie; p; p=p->next){
80104f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f48:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104f4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104f51:	e9 e7 00 00 00       	jmp    8010503d <wait+0x132>
      if(p->parent != proc)
        continue;

      havekids = 1;
80104f56:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      // Found one.
      pid = p->pid;
80104f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f60:	8b 40 10             	mov    0x10(%eax),%eax
80104f63:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(p->kstack);
80104f66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f69:	8b 40 08             	mov    0x8(%eax),%eax
80104f6c:	83 ec 0c             	sub    $0xc,%esp
80104f6f:	50                   	push   %eax
80104f70:	e8 f2 dc ff ff       	call   80102c67 <kfree>
80104f75:	83 c4 10             	add    $0x10,%esp
      p->kstack = 0;
80104f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f7b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
      freevm(p->pgdir);
80104f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f85:	8b 40 04             	mov    0x4(%eax),%eax
80104f88:	83 ec 0c             	sub    $0xc,%esp
80104f8b:	50                   	push   %eax
80104f8c:	e8 b8 4c 00 00       	call   80109c49 <freevm>
80104f91:	83 c4 10             	add    $0x10,%esp
      p->state = UNUSED;
80104f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f97:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
      if(stateListRemove(&ptable.pLists.zombie, &ptable.pLists.zombieTail,p))
80104f9e:	83 ec 04             	sub    $0x4,%esp
80104fa1:	ff 75 f4             	pushl  -0xc(%ebp)
80104fa4:	68 00 71 11 80       	push   $0x80117100
80104fa9:	68 fc 70 11 80       	push   $0x801170fc
80104fae:	e8 a4 0d 00 00       	call   80105d57 <stateListRemove>
80104fb3:	83 c4 10             	add    $0x10,%esp
80104fb6:	85 c0                	test   %eax,%eax
80104fb8:	74 0d                	je     80104fc7 <wait+0xbc>
        panic("Error removing from zombie list.");
80104fba:	83 ec 0c             	sub    $0xc,%esp
80104fbd:	68 d8 a3 10 80       	push   $0x8010a3d8
80104fc2:	e8 9f b5 ff ff       	call   80100566 <panic>
      if(stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail,p))
80104fc7:	83 ec 04             	sub    $0x4,%esp
80104fca:	ff 75 f4             	pushl  -0xc(%ebp)
80104fcd:	68 f0 70 11 80       	push   $0x801170f0
80104fd2:	68 ec 70 11 80       	push   $0x801170ec
80104fd7:	e8 1c 0d 00 00       	call   80105cf8 <stateListAdd>
80104fdc:	83 c4 10             	add    $0x10,%esp
80104fdf:	85 c0                	test   %eax,%eax
80104fe1:	74 0d                	je     80104ff0 <wait+0xe5>
        panic("Error adding to free list.");
80104fe3:	83 ec 0c             	sub    $0xc,%esp
80104fe6:	68 f9 a3 10 80       	push   $0x8010a3f9
80104feb:	e8 76 b5 ff ff       	call   80100566 <panic>
      assertState(p, UNUSED);
80104ff0:	83 ec 08             	sub    $0x8,%esp
80104ff3:	6a 00                	push   $0x0
80104ff5:	ff 75 f4             	pushl  -0xc(%ebp)
80104ff8:	e8 b7 13 00 00       	call   801063b4 <assertState>
80104ffd:	83 c4 10             	add    $0x10,%esp
      p->pid = 0;
80105000:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105003:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
      p->parent = 0;
8010500a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010500d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
      p->name[0] = 0;
80105014:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105017:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
      p->killed = 0;
8010501b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010501e:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
      release(&ptable.lock);
80105025:	83 ec 0c             	sub    $0xc,%esp
80105028:	68 80 49 11 80       	push   $0x80114980
8010502d:	e8 aa 18 00 00       	call   801068dc <release>
80105032:	83 c4 10             	add    $0x10,%esp
      return pid;
80105035:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105038:	e9 44 01 00 00       	jmp    80105181 <wait+0x276>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.pLists.zombie; p; p=p->next){
8010503d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105041:	0f 85 ee fe ff ff    	jne    80104f35 <wait+0x2a>
      release(&ptable.lock);
      return pid;

    }

    for(int i = 0; i<MAXPRIO+1 ; ++i)
80105047:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010504e:	eb 46                	jmp    80105096 <wait+0x18b>
    {
      for(p = ptable.pLists.ready[i];p;p=p->next)
80105050:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105053:	05 cc 09 00 00       	add    $0x9cc,%eax
80105058:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
8010505f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105062:	eb 28                	jmp    8010508c <wait+0x181>
      {
        if(p->parent == proc)
80105064:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105067:	8b 50 14             	mov    0x14(%eax),%edx
8010506a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105070:	39 c2                	cmp    %eax,%edx
80105072:	75 0c                	jne    80105080 <wait+0x175>
        {
          havekids = 1;
80105074:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
          goto kids;
8010507b:	e9 bb 00 00 00       	jmp    8010513b <wait+0x230>

    }

    for(int i = 0; i<MAXPRIO+1 ; ++i)
    {
      for(p = ptable.pLists.ready[i];p;p=p->next)
80105080:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105083:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105089:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010508c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105090:	75 d2                	jne    80105064 <wait+0x159>
      release(&ptable.lock);
      return pid;

    }

    for(int i = 0; i<MAXPRIO+1 ; ++i)
80105092:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80105096:	83 7d ec 06          	cmpl   $0x6,-0x14(%ebp)
8010509a:	7e b4                	jle    80105050 <wait+0x145>
          havekids = 1;
          goto kids;
        }
      }
    }
    for(p = ptable.pLists.sleep;p;p=p->next)
8010509c:	a1 f4 70 11 80       	mov    0x801170f4,%eax
801050a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801050a4:	eb 25                	jmp    801050cb <wait+0x1c0>
    {
      if(p->parent == proc)
801050a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050a9:	8b 50 14             	mov    0x14(%eax),%edx
801050ac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050b2:	39 c2                	cmp    %eax,%edx
801050b4:	75 09                	jne    801050bf <wait+0x1b4>
      {
        havekids = 1;
801050b6:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
        goto kids;
801050bd:	eb 7c                	jmp    8010513b <wait+0x230>
          havekids = 1;
          goto kids;
        }
      }
    }
    for(p = ptable.pLists.sleep;p;p=p->next)
801050bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050c2:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801050c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801050cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801050cf:	75 d5                	jne    801050a6 <wait+0x19b>
      {
        havekids = 1;
        goto kids;
      }
    }
    for(p = ptable.pLists.embryo;p;p=p->next)
801050d1:	a1 0c 71 11 80       	mov    0x8011710c,%eax
801050d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801050d9:	eb 25                	jmp    80105100 <wait+0x1f5>
    {
      if(p->parent == proc)
801050db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050de:	8b 50 14             	mov    0x14(%eax),%edx
801050e1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050e7:	39 c2                	cmp    %eax,%edx
801050e9:	75 09                	jne    801050f4 <wait+0x1e9>
      {
        havekids = 1;
801050eb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
        goto kids;
801050f2:	eb 47                	jmp    8010513b <wait+0x230>
      {
        havekids = 1;
        goto kids;
      }
    }
    for(p = ptable.pLists.embryo;p;p=p->next)
801050f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050f7:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801050fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105100:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105104:	75 d5                	jne    801050db <wait+0x1d0>
      {
        havekids = 1;
        goto kids;
      }
    }
    for(p=ptable.pLists.running;p;p=p->next)
80105106:	a1 04 71 11 80       	mov    0x80117104,%eax
8010510b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010510e:	eb 25                	jmp    80105135 <wait+0x22a>
    {
      if(p->parent == proc)
80105110:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105113:	8b 50 14             	mov    0x14(%eax),%edx
80105116:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010511c:	39 c2                	cmp    %eax,%edx
8010511e:	75 09                	jne    80105129 <wait+0x21e>
      {
        havekids = 1;
80105120:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
        goto kids;
80105127:	eb 12                	jmp    8010513b <wait+0x230>
      {
        havekids = 1;
        goto kids;
      }
    }
    for(p=ptable.pLists.running;p;p=p->next)
80105129:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010512c:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105132:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105135:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105139:	75 d5                	jne    80105110 <wait+0x205>
      }
    }

    kids:
    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
8010513b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010513f:	74 0d                	je     8010514e <wait+0x243>
80105141:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105147:	8b 40 24             	mov    0x24(%eax),%eax
8010514a:	85 c0                	test   %eax,%eax
8010514c:	74 17                	je     80105165 <wait+0x25a>
      release(&ptable.lock);
8010514e:	83 ec 0c             	sub    $0xc,%esp
80105151:	68 80 49 11 80       	push   $0x80114980
80105156:	e8 81 17 00 00       	call   801068dc <release>
8010515b:	83 c4 10             	add    $0x10,%esp
      return -1;
8010515e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105163:	eb 1c                	jmp    80105181 <wait+0x276>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80105165:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010516b:	83 ec 08             	sub    $0x8,%esp
8010516e:	68 80 49 11 80       	push   $0x80114980
80105173:	50                   	push   %eax
80105174:	e8 20 04 00 00       	call   80105599 <sleep>
80105179:	83 c4 10             	add    $0x10,%esp
  }
8010517c:	e9 a0 fd ff ff       	jmp    80104f21 <wait+0x16>
}
80105181:	c9                   	leave  
80105182:	c3                   	ret    

80105183 <scheduler>:
}

#else
void
scheduler(void)
{
80105183:	55                   	push   %ebp
80105184:	89 e5                	mov    %esp,%ebp
80105186:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int idle;  // for checking if processor is idle

  for(;;){
    // Enable interrupts on this processor.
    sti();
80105189:	e8 65 f3 ff ff       	call   801044f3 <sti>

    idle = 1;  // assume idle unless we schedule a process
8010518e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80105195:	83 ec 0c             	sub    $0xc,%esp
80105198:	68 80 49 11 80       	push   $0x80114980
8010519d:	e8 d3 16 00 00       	call   80106875 <acquire>
801051a2:	83 c4 10             	add    $0x10,%esp
    if(ticks >= ptable.PromoteAtTime)
801051a5:	8b 15 14 71 11 80    	mov    0x80117114,%edx
801051ab:	a1 20 79 11 80       	mov    0x80117920,%eax
801051b0:	39 c2                	cmp    %eax,%edx
801051b2:	77 14                	ja     801051c8 <scheduler+0x45>
    {
      promoteAll();
801051b4:	e8 86 14 00 00       	call   8010663f <promoteAll>
      ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
801051b9:	a1 20 79 11 80       	mov    0x80117920,%eax
801051be:	05 f4 01 00 00       	add    $0x1f4,%eax
801051c3:	a3 14 71 11 80       	mov    %eax,0x80117114
    }
    for(int i = 0; i<MAXPRIO+1; ++i)
801051c8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801051cf:	e9 3f 01 00 00       	jmp    80105313 <scheduler+0x190>
    {
      for(p = ptable.pLists.ready[i]; p; p = p->next){
801051d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801051d7:	05 cc 09 00 00       	add    $0x9cc,%eax
801051dc:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
801051e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801051e6:	e9 1a 01 00 00       	jmp    80105305 <scheduler+0x182>

        // Switch to chosen process.  It is the process's job
        // to release ptable.lock and then reacquire it
        // before jumping back to us.
        idle = 0;  // not idle this timeslice
801051eb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
        proc = p;
801051f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051f5:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
        switchuvm(p);
801051fb:	83 ec 0c             	sub    $0xc,%esp
801051fe:	ff 75 f4             	pushl  -0xc(%ebp)
80105201:	e8 fd 45 00 00       	call   80109803 <switchuvm>
80105206:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNING;
80105209:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010520c:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
        if(stateListRemove(&ptable.pLists.ready[i], &ptable.pLists.readyTail[i], p))
80105213:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105216:	05 d0 09 00 00       	add    $0x9d0,%eax
8010521b:	c1 e0 02             	shl    $0x2,%eax
8010521e:	05 80 49 11 80       	add    $0x80114980,%eax
80105223:	8d 50 10             	lea    0x10(%eax),%edx
80105226:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105229:	05 cc 09 00 00       	add    $0x9cc,%eax
8010522e:	c1 e0 02             	shl    $0x2,%eax
80105231:	05 80 49 11 80       	add    $0x80114980,%eax
80105236:	83 c0 04             	add    $0x4,%eax
80105239:	83 ec 04             	sub    $0x4,%esp
8010523c:	ff 75 f4             	pushl  -0xc(%ebp)
8010523f:	52                   	push   %edx
80105240:	50                   	push   %eax
80105241:	e8 11 0b 00 00       	call   80105d57 <stateListRemove>
80105246:	83 c4 10             	add    $0x10,%esp
80105249:	85 c0                	test   %eax,%eax
8010524b:	74 0d                	je     8010525a <scheduler+0xd7>
          panic("problem with removing from ready list.");
8010524d:	83 ec 0c             	sub    $0xc,%esp
80105250:	68 14 a4 10 80       	push   $0x8010a414
80105255:	e8 0c b3 ff ff       	call   80100566 <panic>
        if(stateListAdd(&ptable.pLists.running, &ptable.pLists.runningTail, p))
8010525a:	83 ec 04             	sub    $0x4,%esp
8010525d:	ff 75 f4             	pushl  -0xc(%ebp)
80105260:	68 08 71 11 80       	push   $0x80117108
80105265:	68 04 71 11 80       	push   $0x80117104
8010526a:	e8 89 0a 00 00       	call   80105cf8 <stateListAdd>
8010526f:	83 c4 10             	add    $0x10,%esp
80105272:	85 c0                	test   %eax,%eax
80105274:	74 0d                	je     80105283 <scheduler+0x100>
          panic("problem with adding to running list.");
80105276:	83 ec 0c             	sub    $0xc,%esp
80105279:	68 3c a4 10 80       	push   $0x8010a43c
8010527e:	e8 e3 b2 ff ff       	call   80100566 <panic>
        assertState(p, RUNNING);
80105283:	83 ec 08             	sub    $0x8,%esp
80105286:	6a 04                	push   $0x4
80105288:	ff 75 f4             	pushl  -0xc(%ebp)
8010528b:	e8 24 11 00 00       	call   801063b4 <assertState>
80105290:	83 c4 10             	add    $0x10,%esp

        p->cpu_ticks_in = ticks;
80105293:	8b 15 20 79 11 80    	mov    0x80117920,%edx
80105299:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010529c:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)

        swtch(&cpu->scheduler, proc->context);
801052a2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052a8:	8b 40 1c             	mov    0x1c(%eax),%eax
801052ab:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801052b2:	83 c2 04             	add    $0x4,%edx
801052b5:	83 ec 08             	sub    $0x8,%esp
801052b8:	50                   	push   %eax
801052b9:	52                   	push   %edx
801052ba:	e8 8d 1a 00 00       	call   80106d4c <swtch>
801052bf:	83 c4 10             	add    $0x10,%esp

        p->cpu_ticks_total = p->cpu_ticks_total + (ticks - p->cpu_ticks_in);
801052c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052c5:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
801052cb:	8b 0d 20 79 11 80    	mov    0x80117920,%ecx
801052d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052d4:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
801052da:	29 c1                	sub    %eax,%ecx
801052dc:	89 c8                	mov    %ecx,%eax
801052de:	01 c2                	add    %eax,%edx
801052e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052e3:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
        switchkvm();
801052e9:	e8 f8 44 00 00       	call   801097e6 <switchkvm>

        // Process is done running for now.
        // It should have changed its p->state before coming back.
        proc = 0;
801052ee:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801052f5:	00 00 00 00 
      promoteAll();
      ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
    }
    for(int i = 0; i<MAXPRIO+1; ++i)
    {
      for(p = ptable.pLists.ready[i]; p; p = p->next){
801052f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052fc:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105302:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105305:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105309:	0f 85 dc fe ff ff    	jne    801051eb <scheduler+0x68>
    if(ticks >= ptable.PromoteAtTime)
    {
      promoteAll();
      ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
    }
    for(int i = 0; i<MAXPRIO+1; ++i)
8010530f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80105313:	83 7d ec 06          	cmpl   $0x6,-0x14(%ebp)
80105317:	0f 8e b7 fe ff ff    	jle    801051d4 <scheduler+0x51>
        // Process is done running for now.
        // It should have changed its p->state before coming back.
        proc = 0;
      }
    }
    release(&ptable.lock);
8010531d:	83 ec 0c             	sub    $0xc,%esp
80105320:	68 80 49 11 80       	push   $0x80114980
80105325:	e8 b2 15 00 00       	call   801068dc <release>
8010532a:	83 c4 10             	add    $0x10,%esp
    // if idle, wait for next interrupt
    if (idle) {
8010532d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105331:	0f 84 52 fe ff ff    	je     80105189 <scheduler+0x6>
      sti();
80105337:	e8 b7 f1 ff ff       	call   801044f3 <sti>
      hlt();
8010533c:	e8 9b f1 ff ff       	call   801044dc <hlt>
    }
  }
80105341:	e9 43 fe ff ff       	jmp    80105189 <scheduler+0x6>

80105346 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80105346:	55                   	push   %ebp
80105347:	89 e5                	mov    %esp,%ebp
80105349:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
8010534c:	83 ec 0c             	sub    $0xc,%esp
8010534f:	68 80 49 11 80       	push   $0x80114980
80105354:	e8 4f 16 00 00       	call   801069a8 <holding>
80105359:	83 c4 10             	add    $0x10,%esp
8010535c:	85 c0                	test   %eax,%eax
8010535e:	75 0d                	jne    8010536d <sched+0x27>
    panic("sched ptable.lock");
80105360:	83 ec 0c             	sub    $0xc,%esp
80105363:	68 61 a4 10 80       	push   $0x8010a461
80105368:	e8 f9 b1 ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
8010536d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105373:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105379:	83 f8 01             	cmp    $0x1,%eax
8010537c:	74 0d                	je     8010538b <sched+0x45>
    panic("sched locks");
8010537e:	83 ec 0c             	sub    $0xc,%esp
80105381:	68 73 a4 10 80       	push   $0x8010a473
80105386:	e8 db b1 ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
8010538b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105391:	8b 40 0c             	mov    0xc(%eax),%eax
80105394:	83 f8 04             	cmp    $0x4,%eax
80105397:	75 0d                	jne    801053a6 <sched+0x60>
    panic("sched running");
80105399:	83 ec 0c             	sub    $0xc,%esp
8010539c:	68 7f a4 10 80       	push   $0x8010a47f
801053a1:	e8 c0 b1 ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
801053a6:	e8 38 f1 ff ff       	call   801044e3 <readeflags>
801053ab:	25 00 02 00 00       	and    $0x200,%eax
801053b0:	85 c0                	test   %eax,%eax
801053b2:	74 0d                	je     801053c1 <sched+0x7b>
    panic("sched interruptible");
801053b4:	83 ec 0c             	sub    $0xc,%esp
801053b7:	68 8d a4 10 80       	push   $0x8010a48d
801053bc:	e8 a5 b1 ff ff       	call   80100566 <panic>
  intena = cpu->intena;
801053c1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801053c7:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801053cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
801053d0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801053d6:	8b 40 04             	mov    0x4(%eax),%eax
801053d9:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801053e0:	83 c2 1c             	add    $0x1c,%edx
801053e3:	83 ec 08             	sub    $0x8,%esp
801053e6:	50                   	push   %eax
801053e7:	52                   	push   %edx
801053e8:	e8 5f 19 00 00       	call   80106d4c <swtch>
801053ed:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
801053f0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801053f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801053f9:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801053ff:	90                   	nop
80105400:	c9                   	leave  
80105401:	c3                   	ret    

80105402 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80105402:	55                   	push   %ebp
80105403:	89 e5                	mov    %esp,%ebp
80105405:	53                   	push   %ebx
80105406:	83 ec 04             	sub    $0x4,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80105409:	83 ec 0c             	sub    $0xc,%esp
8010540c:	68 80 49 11 80       	push   $0x80114980
80105411:	e8 5f 14 00 00       	call   80106875 <acquire>
80105416:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80105419:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010541f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
#ifdef CS333_P3P4
  proc->budget = proc->budget - (ticks - proc->cpu_ticks_in);
80105426:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010542c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105433:	8b 92 94 00 00 00    	mov    0x94(%edx),%edx
80105439:	89 d3                	mov    %edx,%ebx
8010543b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105442:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
80105448:	8b 15 20 79 11 80    	mov    0x80117920,%edx
8010544e:	29 d1                	sub    %edx,%ecx
80105450:	89 ca                	mov    %ecx,%edx
80105452:	01 da                	add    %ebx,%edx
80105454:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
  if(proc->budget <= 0)
8010545a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105460:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80105466:	85 c0                	test   %eax,%eax
80105468:	7f 4c                	jg     801054b6 <yield+0xb4>
  {
    if(proc->priority < MAXPRIO)
8010546a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105470:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80105476:	83 f8 05             	cmp    $0x5,%eax
80105479:	77 1c                	ja     80105497 <yield+0x95>
      proc->priority += 1;
8010547b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105481:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105488:	8b 92 98 00 00 00    	mov    0x98(%edx),%edx
8010548e:	83 c2 01             	add    $0x1,%edx
80105491:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
    proc->budget = BUDGET*(proc->priority+1);
80105497:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010549d:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801054a4:	8b 92 98 00 00 00    	mov    0x98(%edx),%edx
801054aa:	83 c2 01             	add    $0x1,%edx
801054ad:	6b d2 64             	imul   $0x64,%edx,%edx
801054b0:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
  }
  stateListRemove(&ptable.pLists.running, &ptable.pLists.runningTail, proc);
801054b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054bc:	83 ec 04             	sub    $0x4,%esp
801054bf:	50                   	push   %eax
801054c0:	68 08 71 11 80       	push   $0x80117108
801054c5:	68 04 71 11 80       	push   $0x80117104
801054ca:	e8 88 08 00 00       	call   80105d57 <stateListRemove>
801054cf:	83 c4 10             	add    $0x10,%esp
  stateListAdd(&ptable.pLists.ready[proc->priority], &ptable.pLists.readyTail[proc->priority], proc);
801054d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054d8:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801054df:	8b 92 98 00 00 00    	mov    0x98(%edx),%edx
801054e5:	81 c2 d0 09 00 00    	add    $0x9d0,%edx
801054eb:	c1 e2 02             	shl    $0x2,%edx
801054ee:	81 c2 80 49 11 80    	add    $0x80114980,%edx
801054f4:	8d 4a 10             	lea    0x10(%edx),%ecx
801054f7:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801054fe:	8b 92 98 00 00 00    	mov    0x98(%edx),%edx
80105504:	81 c2 cc 09 00 00    	add    $0x9cc,%edx
8010550a:	c1 e2 02             	shl    $0x2,%edx
8010550d:	81 c2 80 49 11 80    	add    $0x80114980,%edx
80105513:	83 c2 04             	add    $0x4,%edx
80105516:	83 ec 04             	sub    $0x4,%esp
80105519:	50                   	push   %eax
8010551a:	51                   	push   %ecx
8010551b:	52                   	push   %edx
8010551c:	e8 d7 07 00 00       	call   80105cf8 <stateListAdd>
80105521:	83 c4 10             	add    $0x10,%esp
  assertState(proc, RUNNABLE);
80105524:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010552a:	83 ec 08             	sub    $0x8,%esp
8010552d:	6a 03                	push   $0x3
8010552f:	50                   	push   %eax
80105530:	e8 7f 0e 00 00       	call   801063b4 <assertState>
80105535:	83 c4 10             	add    $0x10,%esp
#endif
  sched();
80105538:	e8 09 fe ff ff       	call   80105346 <sched>
  release(&ptable.lock);
8010553d:	83 ec 0c             	sub    $0xc,%esp
80105540:	68 80 49 11 80       	push   $0x80114980
80105545:	e8 92 13 00 00       	call   801068dc <release>
8010554a:	83 c4 10             	add    $0x10,%esp
}
8010554d:	90                   	nop
8010554e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105551:	c9                   	leave  
80105552:	c3                   	ret    

80105553 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80105553:	55                   	push   %ebp
80105554:	89 e5                	mov    %esp,%ebp
80105556:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80105559:	83 ec 0c             	sub    $0xc,%esp
8010555c:	68 80 49 11 80       	push   $0x80114980
80105561:	e8 76 13 00 00       	call   801068dc <release>
80105566:	83 c4 10             	add    $0x10,%esp

  if (first) {
80105569:	a1 20 d0 10 80       	mov    0x8010d020,%eax
8010556e:	85 c0                	test   %eax,%eax
80105570:	74 24                	je     80105596 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80105572:	c7 05 20 d0 10 80 00 	movl   $0x0,0x8010d020
80105579:	00 00 00 
    iinit(ROOTDEV);
8010557c:	83 ec 0c             	sub    $0xc,%esp
8010557f:	6a 01                	push   $0x1
80105581:	e8 56 c1 ff ff       	call   801016dc <iinit>
80105586:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80105589:	83 ec 0c             	sub    $0xc,%esp
8010558c:	6a 01                	push   $0x1
8010558e:	e8 3a de ff ff       	call   801033cd <initlog>
80105593:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80105596:	90                   	nop
80105597:	c9                   	leave  
80105598:	c3                   	ret    

80105599 <sleep>:
// Reacquires lock when awakened.
// 2016/12/28: ticklock removed from xv6. sleep() changed to
// accept a NULL lock to accommodate.
void
sleep(void *chan, struct spinlock *lk)
{
80105599:	55                   	push   %ebp
8010559a:	89 e5                	mov    %esp,%ebp
8010559c:	53                   	push   %ebx
8010559d:	83 ec 04             	sub    $0x4,%esp
  if(proc == 0)
801055a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055a6:	85 c0                	test   %eax,%eax
801055a8:	75 0d                	jne    801055b7 <sleep+0x1e>
    panic("sleep");
801055aa:	83 ec 0c             	sub    $0xc,%esp
801055ad:	68 a1 a4 10 80       	push   $0x8010a4a1
801055b2:	e8 af af ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){
801055b7:	81 7d 0c 80 49 11 80 	cmpl   $0x80114980,0xc(%ebp)
801055be:	74 24                	je     801055e4 <sleep+0x4b>
    acquire(&ptable.lock);
801055c0:	83 ec 0c             	sub    $0xc,%esp
801055c3:	68 80 49 11 80       	push   $0x80114980
801055c8:	e8 a8 12 00 00       	call   80106875 <acquire>
801055cd:	83 c4 10             	add    $0x10,%esp
    if (lk) release(lk);
801055d0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801055d4:	74 0e                	je     801055e4 <sleep+0x4b>
801055d6:	83 ec 0c             	sub    $0xc,%esp
801055d9:	ff 75 0c             	pushl  0xc(%ebp)
801055dc:	e8 fb 12 00 00       	call   801068dc <release>
801055e1:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
801055e4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055ea:	8b 55 08             	mov    0x8(%ebp),%edx
801055ed:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
801055f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055f6:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
#ifdef CS333_P3P4
  proc->budget = proc->budget - (ticks - proc->cpu_ticks_in);
801055fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105603:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010560a:	8b 92 94 00 00 00    	mov    0x94(%edx),%edx
80105610:	89 d3                	mov    %edx,%ebx
80105612:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105619:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
8010561f:	8b 15 20 79 11 80    	mov    0x80117920,%edx
80105625:	29 d1                	sub    %edx,%ecx
80105627:	89 ca                	mov    %ecx,%edx
80105629:	01 da                	add    %ebx,%edx
8010562b:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
  if(proc->budget <= 0)
80105631:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105637:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
8010563d:	85 c0                	test   %eax,%eax
8010563f:	7f 4c                	jg     8010568d <sleep+0xf4>
  {
    if(proc->priority < MAXPRIO)
80105641:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105647:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
8010564d:	83 f8 05             	cmp    $0x5,%eax
80105650:	77 1c                	ja     8010566e <sleep+0xd5>
      proc->priority += 1;
80105652:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105658:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010565f:	8b 92 98 00 00 00    	mov    0x98(%edx),%edx
80105665:	83 c2 01             	add    $0x1,%edx
80105668:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
    proc->budget = BUDGET*(proc->priority+1);
8010566e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105674:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010567b:	8b 92 98 00 00 00    	mov    0x98(%edx),%edx
80105681:	83 c2 01             	add    $0x1,%edx
80105684:	6b d2 64             	imul   $0x64,%edx,%edx
80105687:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
  }
  if(stateListRemove(&ptable.pLists.running, &ptable.pLists.runningTail, proc))
8010568d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105693:	83 ec 04             	sub    $0x4,%esp
80105696:	50                   	push   %eax
80105697:	68 08 71 11 80       	push   $0x80117108
8010569c:	68 04 71 11 80       	push   $0x80117104
801056a1:	e8 b1 06 00 00       	call   80105d57 <stateListRemove>
801056a6:	83 c4 10             	add    $0x10,%esp
801056a9:	85 c0                	test   %eax,%eax
801056ab:	74 0d                	je     801056ba <sleep+0x121>
    panic("error removing from running list.");
801056ad:	83 ec 0c             	sub    $0xc,%esp
801056b0:	68 a8 a4 10 80       	push   $0x8010a4a8
801056b5:	e8 ac ae ff ff       	call   80100566 <panic>
  if(stateListAdd(&ptable.pLists.sleep, &ptable.pLists.sleepTail, proc))
801056ba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056c0:	83 ec 04             	sub    $0x4,%esp
801056c3:	50                   	push   %eax
801056c4:	68 f8 70 11 80       	push   $0x801170f8
801056c9:	68 f4 70 11 80       	push   $0x801170f4
801056ce:	e8 25 06 00 00       	call   80105cf8 <stateListAdd>
801056d3:	83 c4 10             	add    $0x10,%esp
801056d6:	85 c0                	test   %eax,%eax
801056d8:	74 0d                	je     801056e7 <sleep+0x14e>
    panic("error adding to sleep list.");
801056da:	83 ec 0c             	sub    $0xc,%esp
801056dd:	68 ca a4 10 80       	push   $0x8010a4ca
801056e2:	e8 7f ae ff ff       	call   80100566 <panic>
  assertState(proc, SLEEPING);
801056e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056ed:	83 ec 08             	sub    $0x8,%esp
801056f0:	6a 02                	push   $0x2
801056f2:	50                   	push   %eax
801056f3:	e8 bc 0c 00 00       	call   801063b4 <assertState>
801056f8:	83 c4 10             	add    $0x10,%esp
#endif
  sched();
801056fb:	e8 46 fc ff ff       	call   80105346 <sched>

  // Tidy up.
  proc->chan = 0;
80105700:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105706:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){
8010570d:	81 7d 0c 80 49 11 80 	cmpl   $0x80114980,0xc(%ebp)
80105714:	74 24                	je     8010573a <sleep+0x1a1>
    release(&ptable.lock);
80105716:	83 ec 0c             	sub    $0xc,%esp
80105719:	68 80 49 11 80       	push   $0x80114980
8010571e:	e8 b9 11 00 00       	call   801068dc <release>
80105723:	83 c4 10             	add    $0x10,%esp
    if (lk) acquire(lk);
80105726:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010572a:	74 0e                	je     8010573a <sleep+0x1a1>
8010572c:	83 ec 0c             	sub    $0xc,%esp
8010572f:	ff 75 0c             	pushl  0xc(%ebp)
80105732:	e8 3e 11 00 00       	call   80106875 <acquire>
80105737:	83 c4 10             	add    $0x10,%esp
  }
}
8010573a:	90                   	nop
8010573b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010573e:	c9                   	leave  
8010573f:	c3                   	ret    

80105740 <wakeup1>:
      p->state = RUNNABLE;
}
#else
static void
wakeup1(void *chan)
{
80105740:	55                   	push   %ebp
80105741:	89 e5                	mov    %esp,%ebp
80105743:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  p = ptable.pLists.sleep;
80105746:	a1 f4 70 11 80       	mov    0x801170f4,%eax
8010574b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(p)
8010574e:	e9 b1 00 00 00       	jmp    80105804 <wakeup1+0xc4>
  {
    if(p->chan == chan)
80105753:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105756:	8b 40 20             	mov    0x20(%eax),%eax
80105759:	3b 45 08             	cmp    0x8(%ebp),%eax
8010575c:	0f 85 96 00 00 00    	jne    801057f8 <wakeup1+0xb8>
    {
      p->state = RUNNABLE;
80105762:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105765:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      if(stateListRemove(&ptable.pLists.sleep, &ptable.pLists.sleepTail, p))
8010576c:	83 ec 04             	sub    $0x4,%esp
8010576f:	ff 75 f4             	pushl  -0xc(%ebp)
80105772:	68 f8 70 11 80       	push   $0x801170f8
80105777:	68 f4 70 11 80       	push   $0x801170f4
8010577c:	e8 d6 05 00 00       	call   80105d57 <stateListRemove>
80105781:	83 c4 10             	add    $0x10,%esp
80105784:	85 c0                	test   %eax,%eax
80105786:	74 0d                	je     80105795 <wakeup1+0x55>
        panic("error removing from sleep list.");
80105788:	83 ec 0c             	sub    $0xc,%esp
8010578b:	68 e8 a4 10 80       	push   $0x8010a4e8
80105790:	e8 d1 ad ff ff       	call   80100566 <panic>
      if(stateListAdd(&ptable.pLists.ready[p->priority], &ptable.pLists.readyTail[p->priority], p))
80105795:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105798:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
8010579e:	05 d0 09 00 00       	add    $0x9d0,%eax
801057a3:	c1 e0 02             	shl    $0x2,%eax
801057a6:	05 80 49 11 80       	add    $0x80114980,%eax
801057ab:	8d 50 10             	lea    0x10(%eax),%edx
801057ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057b1:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801057b7:	05 cc 09 00 00       	add    $0x9cc,%eax
801057bc:	c1 e0 02             	shl    $0x2,%eax
801057bf:	05 80 49 11 80       	add    $0x80114980,%eax
801057c4:	83 c0 04             	add    $0x4,%eax
801057c7:	83 ec 04             	sub    $0x4,%esp
801057ca:	ff 75 f4             	pushl  -0xc(%ebp)
801057cd:	52                   	push   %edx
801057ce:	50                   	push   %eax
801057cf:	e8 24 05 00 00       	call   80105cf8 <stateListAdd>
801057d4:	83 c4 10             	add    $0x10,%esp
801057d7:	85 c0                	test   %eax,%eax
801057d9:	74 0d                	je     801057e8 <wakeup1+0xa8>
        panic("error adding to ready list.");
801057db:	83 ec 0c             	sub    $0xc,%esp
801057de:	68 30 a3 10 80       	push   $0x8010a330
801057e3:	e8 7e ad ff ff       	call   80100566 <panic>
      assertState(p, RUNNABLE);
801057e8:	83 ec 08             	sub    $0x8,%esp
801057eb:	6a 03                	push   $0x3
801057ed:	ff 75 f4             	pushl  -0xc(%ebp)
801057f0:	e8 bf 0b 00 00       	call   801063b4 <assertState>
801057f5:	83 c4 10             	add    $0x10,%esp
    }
    p = p->next;
801057f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057fb:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105801:	89 45 f4             	mov    %eax,-0xc(%ebp)
wakeup1(void *chan)
{
  struct proc *p;

  p = ptable.pLists.sleep;
  while(p)
80105804:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105808:	0f 85 45 ff ff ff    	jne    80105753 <wakeup1+0x13>
        panic("error adding to ready list.");
      assertState(p, RUNNABLE);
    }
    p = p->next;
  }
}
8010580e:	90                   	nop
8010580f:	c9                   	leave  
80105810:	c3                   	ret    

80105811 <wakeup>:
#endif

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80105811:	55                   	push   %ebp
80105812:	89 e5                	mov    %esp,%ebp
80105814:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80105817:	83 ec 0c             	sub    $0xc,%esp
8010581a:	68 80 49 11 80       	push   $0x80114980
8010581f:	e8 51 10 00 00       	call   80106875 <acquire>
80105824:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80105827:	83 ec 0c             	sub    $0xc,%esp
8010582a:	ff 75 08             	pushl  0x8(%ebp)
8010582d:	e8 0e ff ff ff       	call   80105740 <wakeup1>
80105832:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80105835:	83 ec 0c             	sub    $0xc,%esp
80105838:	68 80 49 11 80       	push   $0x80114980
8010583d:	e8 9a 10 00 00       	call   801068dc <release>
80105842:	83 c4 10             	add    $0x10,%esp
}
80105845:	90                   	nop
80105846:	c9                   	leave  
80105847:	c3                   	ret    

80105848 <kill>:
  return -1;
}
#else
int
kill(int pid)
{
80105848:	55                   	push   %ebp
80105849:	89 e5                	mov    %esp,%ebp
8010584b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
8010584e:	83 ec 0c             	sub    $0xc,%esp
80105851:	68 80 49 11 80       	push   $0x80114980
80105856:	e8 1a 10 00 00       	call   80106875 <acquire>
8010585b:	83 c4 10             	add    $0x10,%esp
  for(int i = 0; i<MAXPRIO+1; ++i)
8010585e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80105865:	eb 3b                	jmp    801058a2 <kill+0x5a>
  {
    for(p = ptable.pLists.ready[i]; p ; p = p->next)
80105867:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010586a:	05 cc 09 00 00       	add    $0x9cc,%eax
8010586f:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
80105876:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105879:	eb 1d                	jmp    80105898 <kill+0x50>
    {
      if(p->pid == pid)
8010587b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010587e:	8b 50 10             	mov    0x10(%eax),%edx
80105881:	8b 45 08             	mov    0x8(%ebp),%eax
80105884:	39 c2                	cmp    %eax,%edx
80105886:	0f 84 86 01 00 00    	je     80105a12 <kill+0x1ca>
  struct proc *p;

  acquire(&ptable.lock);
  for(int i = 0; i<MAXPRIO+1; ++i)
  {
    for(p = ptable.pLists.ready[i]; p ; p = p->next)
8010588c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010588f:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105895:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105898:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010589c:	75 dd                	jne    8010587b <kill+0x33>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(int i = 0; i<MAXPRIO+1; ++i)
8010589e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801058a2:	83 7d f0 06          	cmpl   $0x6,-0x10(%ebp)
801058a6:	7e bf                	jle    80105867 <kill+0x1f>
    {
      if(p->pid == pid)
        goto found;
    }
  }
  for(p = ptable.pLists.running; p ; p = p->next)
801058a8:	a1 04 71 11 80       	mov    0x80117104,%eax
801058ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058b0:	eb 1d                	jmp    801058cf <kill+0x87>
  {
    if(p->pid == pid)
801058b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058b5:	8b 50 10             	mov    0x10(%eax),%edx
801058b8:	8b 45 08             	mov    0x8(%ebp),%eax
801058bb:	39 c2                	cmp    %eax,%edx
801058bd:	0f 84 52 01 00 00    	je     80105a15 <kill+0x1cd>
    {
      if(p->pid == pid)
        goto found;
    }
  }
  for(p = ptable.pLists.running; p ; p = p->next)
801058c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058c6:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801058cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058cf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058d3:	75 dd                	jne    801058b2 <kill+0x6a>
  {
    if(p->pid == pid)
      goto found;
  }
  for(p = ptable.pLists.embryo; p ; p = p->next)
801058d5:	a1 0c 71 11 80       	mov    0x8011710c,%eax
801058da:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058dd:	eb 1d                	jmp    801058fc <kill+0xb4>
  {
    if(p->pid == pid)
801058df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058e2:	8b 50 10             	mov    0x10(%eax),%edx
801058e5:	8b 45 08             	mov    0x8(%ebp),%eax
801058e8:	39 c2                	cmp    %eax,%edx
801058ea:	0f 84 28 01 00 00    	je     80105a18 <kill+0x1d0>
  for(p = ptable.pLists.running; p ; p = p->next)
  {
    if(p->pid == pid)
      goto found;
  }
  for(p = ptable.pLists.embryo; p ; p = p->next)
801058f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058f3:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801058f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105900:	75 dd                	jne    801058df <kill+0x97>
  {
    if(p->pid == pid)
      goto found;
  }
  for(p = ptable.pLists.zombie; p ; p = p->next)
80105902:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80105907:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010590a:	eb 1d                	jmp    80105929 <kill+0xe1>
  {
    if(p->pid == pid)
8010590c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010590f:	8b 50 10             	mov    0x10(%eax),%edx
80105912:	8b 45 08             	mov    0x8(%ebp),%eax
80105915:	39 c2                	cmp    %eax,%edx
80105917:	0f 84 fe 00 00 00    	je     80105a1b <kill+0x1d3>
  for(p = ptable.pLists.embryo; p ; p = p->next)
  {
    if(p->pid == pid)
      goto found;
  }
  for(p = ptable.pLists.zombie; p ; p = p->next)
8010591d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105920:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105926:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105929:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010592d:	75 dd                	jne    8010590c <kill+0xc4>
  {
    if(p->pid == pid)
      goto found;
  }
  for(p = ptable.pLists.sleep; p ; p = p->next)
8010592f:	a1 f4 70 11 80       	mov    0x801170f4,%eax
80105934:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105937:	e9 b5 00 00 00       	jmp    801059f1 <kill+0x1a9>
  {
    if(p->pid == pid)
8010593c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010593f:	8b 50 10             	mov    0x10(%eax),%edx
80105942:	8b 45 08             	mov    0x8(%ebp),%eax
80105945:	39 c2                	cmp    %eax,%edx
80105947:	0f 85 98 00 00 00    	jne    801059e5 <kill+0x19d>
    {
      // Wake process from sleep if necessary.
      if(stateListRemove(&ptable.pLists.sleep, &ptable.pLists.sleepTail, p))
8010594d:	83 ec 04             	sub    $0x4,%esp
80105950:	ff 75 f4             	pushl  -0xc(%ebp)
80105953:	68 f8 70 11 80       	push   $0x801170f8
80105958:	68 f4 70 11 80       	push   $0x801170f4
8010595d:	e8 f5 03 00 00       	call   80105d57 <stateListRemove>
80105962:	83 c4 10             	add    $0x10,%esp
80105965:	85 c0                	test   %eax,%eax
80105967:	74 0d                	je     80105976 <kill+0x12e>
        panic("error removing from sleep list.");
80105969:	83 ec 0c             	sub    $0xc,%esp
8010596c:	68 e8 a4 10 80       	push   $0x8010a4e8
80105971:	e8 f0 ab ff ff       	call   80100566 <panic>
      if(stateListAdd(&ptable.pLists.ready[p->priority], &ptable.pLists.readyTail[p->priority], p))
80105976:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105979:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
8010597f:	05 d0 09 00 00       	add    $0x9d0,%eax
80105984:	c1 e0 02             	shl    $0x2,%eax
80105987:	05 80 49 11 80       	add    $0x80114980,%eax
8010598c:	8d 50 10             	lea    0x10(%eax),%edx
8010598f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105992:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80105998:	05 cc 09 00 00       	add    $0x9cc,%eax
8010599d:	c1 e0 02             	shl    $0x2,%eax
801059a0:	05 80 49 11 80       	add    $0x80114980,%eax
801059a5:	83 c0 04             	add    $0x4,%eax
801059a8:	83 ec 04             	sub    $0x4,%esp
801059ab:	ff 75 f4             	pushl  -0xc(%ebp)
801059ae:	52                   	push   %edx
801059af:	50                   	push   %eax
801059b0:	e8 43 03 00 00       	call   80105cf8 <stateListAdd>
801059b5:	83 c4 10             	add    $0x10,%esp
801059b8:	85 c0                	test   %eax,%eax
801059ba:	74 0d                	je     801059c9 <kill+0x181>
        panic("error adding to ready list.");
801059bc:	83 ec 0c             	sub    $0xc,%esp
801059bf:	68 30 a3 10 80       	push   $0x8010a330
801059c4:	e8 9d ab ff ff       	call   80100566 <panic>
      p->state = RUNNABLE;
801059c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059cc:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      assertState(p, RUNNABLE);
801059d3:	83 ec 08             	sub    $0x8,%esp
801059d6:	6a 03                	push   $0x3
801059d8:	ff 75 f4             	pushl  -0xc(%ebp)
801059db:	e8 d4 09 00 00       	call   801063b4 <assertState>
801059e0:	83 c4 10             	add    $0x10,%esp
      goto found;
801059e3:	eb 37                	jmp    80105a1c <kill+0x1d4>
  for(p = ptable.pLists.zombie; p ; p = p->next)
  {
    if(p->pid == pid)
      goto found;
  }
  for(p = ptable.pLists.sleep; p ; p = p->next)
801059e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059e8:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801059ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059f1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059f5:	0f 85 41 ff ff ff    	jne    8010593c <kill+0xf4>
      p->state = RUNNABLE;
      assertState(p, RUNNABLE);
      goto found;
    }
  }
  release(&ptable.lock);
801059fb:	83 ec 0c             	sub    $0xc,%esp
801059fe:	68 80 49 11 80       	push   $0x80114980
80105a03:	e8 d4 0e 00 00       	call   801068dc <release>
80105a08:	83 c4 10             	add    $0x10,%esp
  return -1;
80105a0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a10:	eb 29                	jmp    80105a3b <kill+0x1f3>
  for(int i = 0; i<MAXPRIO+1; ++i)
  {
    for(p = ptable.pLists.ready[i]; p ; p = p->next)
    {
      if(p->pid == pid)
        goto found;
80105a12:	90                   	nop
80105a13:	eb 07                	jmp    80105a1c <kill+0x1d4>
    }
  }
  for(p = ptable.pLists.running; p ; p = p->next)
  {
    if(p->pid == pid)
      goto found;
80105a15:	90                   	nop
80105a16:	eb 04                	jmp    80105a1c <kill+0x1d4>
  }
  for(p = ptable.pLists.embryo; p ; p = p->next)
  {
    if(p->pid == pid)
      goto found;
80105a18:	90                   	nop
80105a19:	eb 01                	jmp    80105a1c <kill+0x1d4>
  }
  for(p = ptable.pLists.zombie; p ; p = p->next)
  {
    if(p->pid == pid)
      goto found;
80105a1b:	90                   	nop
  }
  release(&ptable.lock);
  return -1;

  found:
  p->killed = 1;
80105a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a1f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
  release(&ptable.lock);
80105a26:	83 ec 0c             	sub    $0xc,%esp
80105a29:	68 80 49 11 80       	push   $0x80114980
80105a2e:	e8 a9 0e 00 00       	call   801068dc <release>
80105a33:	83 c4 10             	add    $0x10,%esp
  return 0;
80105a36:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a3b:	c9                   	leave  
80105a3c:	c3                   	ret    

80105a3d <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105a3d:	55                   	push   %ebp
80105a3e:	89 e5                	mov    %esp,%ebp
80105a40:	53                   	push   %ebx
80105a41:	83 ec 44             	sub    $0x44,%esp
  uint current_ticks;
  struct proc *p;
  char *state;
  uint pc[10];
#if defined CS333_P3P4
  cprintf("\nPID\tName\tUID\tGID\tPPID\tPrio\tElapsed\tCPU\tState\tSize\t PCs\n");
80105a44:	83 ec 0c             	sub    $0xc,%esp
80105a47:	68 34 a5 10 80       	push   $0x8010a534
80105a4c:	e8 75 a9 ff ff       	call   801003c6 <cprintf>
80105a51:	83 c4 10             	add    $0x10,%esp
#elif defined CS333_P1
  cprintf("\nPID\tState\tName\tElapsed\t PCs\n");
#else
  cprintf("\nPID\tState\tName\t PCs\n");
#endif
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a54:	c7 45 f0 b4 49 11 80 	movl   $0x801149b4,-0x10(%ebp)
80105a5b:	e9 85 02 00 00       	jmp    80105ce5 <procdump+0x2a8>
    if(p->state == UNUSED)
80105a60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a63:	8b 40 0c             	mov    0xc(%eax),%eax
80105a66:	85 c0                	test   %eax,%eax
80105a68:	0f 84 6f 02 00 00    	je     80105cdd <procdump+0x2a0>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105a6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a71:	8b 40 0c             	mov    0xc(%eax),%eax
80105a74:	83 f8 05             	cmp    $0x5,%eax
80105a77:	77 23                	ja     80105a9c <procdump+0x5f>
80105a79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a7c:	8b 40 0c             	mov    0xc(%eax),%eax
80105a7f:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
80105a86:	85 c0                	test   %eax,%eax
80105a88:	74 12                	je     80105a9c <procdump+0x5f>
      state = states[p->state];
80105a8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a8d:	8b 40 0c             	mov    0xc(%eax),%eax
80105a90:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
80105a97:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105a9a:	eb 07                	jmp    80105aa3 <procdump+0x66>
    else
      state = "???";
80105a9c:	c7 45 ec 6d a5 10 80 	movl   $0x8010a56d,-0x14(%ebp)
    current_ticks = ticks;
80105aa3:	a1 20 79 11 80       	mov    0x80117920,%eax
80105aa8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    i = ((current_ticks-p->start_ticks)%1000);
80105aab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aae:	8b 40 7c             	mov    0x7c(%eax),%eax
80105ab1:	8b 55 e8             	mov    -0x18(%ebp),%edx
80105ab4:	89 d1                	mov    %edx,%ecx
80105ab6:	29 c1                	sub    %eax,%ecx
80105ab8:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105abd:	89 c8                	mov    %ecx,%eax
80105abf:	f7 e2                	mul    %edx
80105ac1:	89 d0                	mov    %edx,%eax
80105ac3:	c1 e8 06             	shr    $0x6,%eax
80105ac6:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
80105acc:	29 c1                	sub    %eax,%ecx
80105ace:	89 c8                	mov    %ecx,%eax
80105ad0:	89 45 f4             	mov    %eax,-0xc(%ebp)
#if defined CS333_P2
    cprintf("%d\t%s\t%d\t%d", p->pid, p->name, p->uid, p->gid);
80105ad3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ad6:	8b 88 84 00 00 00    	mov    0x84(%eax),%ecx
80105adc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105adf:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80105ae5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ae8:	8d 58 6c             	lea    0x6c(%eax),%ebx
80105aeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aee:	8b 40 10             	mov    0x10(%eax),%eax
80105af1:	83 ec 0c             	sub    $0xc,%esp
80105af4:	51                   	push   %ecx
80105af5:	52                   	push   %edx
80105af6:	53                   	push   %ebx
80105af7:	50                   	push   %eax
80105af8:	68 71 a5 10 80       	push   $0x8010a571
80105afd:	e8 c4 a8 ff ff       	call   801003c6 <cprintf>
80105b02:	83 c4 20             	add    $0x20,%esp
    if(p->pid == 1)
80105b05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b08:	8b 40 10             	mov    0x10(%eax),%eax
80105b0b:	83 f8 01             	cmp    $0x1,%eax
80105b0e:	75 19                	jne    80105b29 <procdump+0xec>
      cprintf("\t%d",p->pid);
80105b10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b13:	8b 40 10             	mov    0x10(%eax),%eax
80105b16:	83 ec 08             	sub    $0x8,%esp
80105b19:	50                   	push   %eax
80105b1a:	68 7d a5 10 80       	push   $0x8010a57d
80105b1f:	e8 a2 a8 ff ff       	call   801003c6 <cprintf>
80105b24:	83 c4 10             	add    $0x10,%esp
80105b27:	eb 1a                	jmp    80105b43 <procdump+0x106>
    else
      cprintf("\t%d",p->parent->pid);
80105b29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b2c:	8b 40 14             	mov    0x14(%eax),%eax
80105b2f:	8b 40 10             	mov    0x10(%eax),%eax
80105b32:	83 ec 08             	sub    $0x8,%esp
80105b35:	50                   	push   %eax
80105b36:	68 7d a5 10 80       	push   $0x8010a57d
80105b3b:	e8 86 a8 ff ff       	call   801003c6 <cprintf>
80105b40:	83 c4 10             	add    $0x10,%esp
#if defined CS333_P3P4
      cprintf("\t%d", p->priority);
80105b43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b46:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80105b4c:	83 ec 08             	sub    $0x8,%esp
80105b4f:	50                   	push   %eax
80105b50:	68 7d a5 10 80       	push   $0x8010a57d
80105b55:	e8 6c a8 ff ff       	call   801003c6 <cprintf>
80105b5a:	83 c4 10             	add    $0x10,%esp
#endif
    cprintf("\t%d.", ((current_ticks-p->start_ticks)/1000));
80105b5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b60:	8b 40 7c             	mov    0x7c(%eax),%eax
80105b63:	8b 55 e8             	mov    -0x18(%ebp),%edx
80105b66:	29 c2                	sub    %eax,%edx
80105b68:	89 d0                	mov    %edx,%eax
80105b6a:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105b6f:	f7 e2                	mul    %edx
80105b71:	89 d0                	mov    %edx,%eax
80105b73:	c1 e8 06             	shr    $0x6,%eax
80105b76:	83 ec 08             	sub    $0x8,%esp
80105b79:	50                   	push   %eax
80105b7a:	68 81 a5 10 80       	push   $0x8010a581
80105b7f:	e8 42 a8 ff ff       	call   801003c6 <cprintf>
80105b84:	83 c4 10             	add    $0x10,%esp
    if (i<100)
80105b87:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
80105b8b:	7f 10                	jg     80105b9d <procdump+0x160>
      cprintf("0");
80105b8d:	83 ec 0c             	sub    $0xc,%esp
80105b90:	68 86 a5 10 80       	push   $0x8010a586
80105b95:	e8 2c a8 ff ff       	call   801003c6 <cprintf>
80105b9a:	83 c4 10             	add    $0x10,%esp
    if (i<10)
80105b9d:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105ba1:	7f 10                	jg     80105bb3 <procdump+0x176>
      cprintf("0");
80105ba3:	83 ec 0c             	sub    $0xc,%esp
80105ba6:	68 86 a5 10 80       	push   $0x8010a586
80105bab:	e8 16 a8 ff ff       	call   801003c6 <cprintf>
80105bb0:	83 c4 10             	add    $0x10,%esp
    cprintf("%d", i);
80105bb3:	83 ec 08             	sub    $0x8,%esp
80105bb6:	ff 75 f4             	pushl  -0xc(%ebp)
80105bb9:	68 88 a5 10 80       	push   $0x8010a588
80105bbe:	e8 03 a8 ff ff       	call   801003c6 <cprintf>
80105bc3:	83 c4 10             	add    $0x10,%esp
    i = p->cpu_ticks_total;
80105bc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bc9:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80105bcf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("\t%d.", i/1000);
80105bd2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80105bd5:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105bda:	89 c8                	mov    %ecx,%eax
80105bdc:	f7 ea                	imul   %edx
80105bde:	c1 fa 06             	sar    $0x6,%edx
80105be1:	89 c8                	mov    %ecx,%eax
80105be3:	c1 f8 1f             	sar    $0x1f,%eax
80105be6:	29 c2                	sub    %eax,%edx
80105be8:	89 d0                	mov    %edx,%eax
80105bea:	83 ec 08             	sub    $0x8,%esp
80105bed:	50                   	push   %eax
80105bee:	68 81 a5 10 80       	push   $0x8010a581
80105bf3:	e8 ce a7 ff ff       	call   801003c6 <cprintf>
80105bf8:	83 c4 10             	add    $0x10,%esp
    i = i%1000;
80105bfb:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80105bfe:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105c03:	89 c8                	mov    %ecx,%eax
80105c05:	f7 ea                	imul   %edx
80105c07:	c1 fa 06             	sar    $0x6,%edx
80105c0a:	89 c8                	mov    %ecx,%eax
80105c0c:	c1 f8 1f             	sar    $0x1f,%eax
80105c0f:	29 c2                	sub    %eax,%edx
80105c11:	89 d0                	mov    %edx,%eax
80105c13:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
80105c19:	29 c1                	sub    %eax,%ecx
80105c1b:	89 c8                	mov    %ecx,%eax
80105c1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i<100)
80105c20:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
80105c24:	7f 10                	jg     80105c36 <procdump+0x1f9>
      cprintf("0");
80105c26:	83 ec 0c             	sub    $0xc,%esp
80105c29:	68 86 a5 10 80       	push   $0x8010a586
80105c2e:	e8 93 a7 ff ff       	call   801003c6 <cprintf>
80105c33:	83 c4 10             	add    $0x10,%esp
    if (i<10)
80105c36:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105c3a:	7f 10                	jg     80105c4c <procdump+0x20f>
      cprintf("0");
80105c3c:	83 ec 0c             	sub    $0xc,%esp
80105c3f:	68 86 a5 10 80       	push   $0x8010a586
80105c44:	e8 7d a7 ff ff       	call   801003c6 <cprintf>
80105c49:	83 c4 10             	add    $0x10,%esp
    cprintf("%d\t%s\t%d\t", i, state, p->sz);
80105c4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c4f:	8b 00                	mov    (%eax),%eax
80105c51:	50                   	push   %eax
80105c52:	ff 75 ec             	pushl  -0x14(%ebp)
80105c55:	ff 75 f4             	pushl  -0xc(%ebp)
80105c58:	68 8b a5 10 80       	push   $0x8010a58b
80105c5d:	e8 64 a7 ff ff       	call   801003c6 <cprintf>
80105c62:	83 c4 10             	add    $0x10,%esp
      cprintf("0");
    cprintf("%d\t",i);
#else
    cprintf("%d\t%s\t%s", p->pid, state, p->name);
#endif
    i = 0;
80105c65:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(p->state == SLEEPING){
80105c6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c6f:	8b 40 0c             	mov    0xc(%eax),%eax
80105c72:	83 f8 02             	cmp    $0x2,%eax
80105c75:	75 54                	jne    80105ccb <procdump+0x28e>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105c77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c7a:	8b 40 1c             	mov    0x1c(%eax),%eax
80105c7d:	8b 40 0c             	mov    0xc(%eax),%eax
80105c80:	83 c0 08             	add    $0x8,%eax
80105c83:	89 c2                	mov    %eax,%edx
80105c85:	83 ec 08             	sub    $0x8,%esp
80105c88:	8d 45 c0             	lea    -0x40(%ebp),%eax
80105c8b:	50                   	push   %eax
80105c8c:	52                   	push   %edx
80105c8d:	e8 9c 0c 00 00       	call   8010692e <getcallerpcs>
80105c92:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105c95:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105c9c:	eb 1c                	jmp    80105cba <procdump+0x27d>
        cprintf(" %p", pc[i]);
80105c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ca1:	8b 44 85 c0          	mov    -0x40(%ebp,%eax,4),%eax
80105ca5:	83 ec 08             	sub    $0x8,%esp
80105ca8:	50                   	push   %eax
80105ca9:	68 95 a5 10 80       	push   $0x8010a595
80105cae:	e8 13 a7 ff ff       	call   801003c6 <cprintf>
80105cb3:	83 c4 10             	add    $0x10,%esp
    cprintf("%d\t%s\t%s", p->pid, state, p->name);
#endif
    i = 0;
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105cb6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105cba:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105cbe:	7f 0b                	jg     80105ccb <procdump+0x28e>
80105cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cc3:	8b 44 85 c0          	mov    -0x40(%ebp,%eax,4),%eax
80105cc7:	85 c0                	test   %eax,%eax
80105cc9:	75 d3                	jne    80105c9e <procdump+0x261>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105ccb:	83 ec 0c             	sub    $0xc,%esp
80105cce:	68 99 a5 10 80       	push   $0x8010a599
80105cd3:	e8 ee a6 ff ff       	call   801003c6 <cprintf>
80105cd8:	83 c4 10             	add    $0x10,%esp
80105cdb:	eb 01                	jmp    80105cde <procdump+0x2a1>
#else
  cprintf("\nPID\tState\tName\t PCs\n");
#endif
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105cdd:	90                   	nop
#elif defined CS333_P1
  cprintf("\nPID\tState\tName\tElapsed\t PCs\n");
#else
  cprintf("\nPID\tState\tName\t PCs\n");
#endif
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105cde:	81 45 f0 9c 00 00 00 	addl   $0x9c,-0x10(%ebp)
80105ce5:	81 7d f0 b4 70 11 80 	cmpl   $0x801170b4,-0x10(%ebp)
80105cec:	0f 82 6e fd ff ff    	jb     80105a60 <procdump+0x23>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105cf2:	90                   	nop
80105cf3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105cf6:	c9                   	leave  
80105cf7:	c3                   	ret    

80105cf8 <stateListAdd>:


#ifdef CS333_P3P4
static int
stateListAdd(struct proc** head, struct proc** tail, struct proc* p)
{
80105cf8:	55                   	push   %ebp
80105cf9:	89 e5                	mov    %esp,%ebp
  if (*head == 0) {
80105cfb:	8b 45 08             	mov    0x8(%ebp),%eax
80105cfe:	8b 00                	mov    (%eax),%eax
80105d00:	85 c0                	test   %eax,%eax
80105d02:	75 1f                	jne    80105d23 <stateListAdd+0x2b>
    *head = p;
80105d04:	8b 45 08             	mov    0x8(%ebp),%eax
80105d07:	8b 55 10             	mov    0x10(%ebp),%edx
80105d0a:	89 10                	mov    %edx,(%eax)
    *tail = p;
80105d0c:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d0f:	8b 55 10             	mov    0x10(%ebp),%edx
80105d12:	89 10                	mov    %edx,(%eax)
    p->next = 0;
80105d14:	8b 45 10             	mov    0x10(%ebp),%eax
80105d17:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80105d1e:	00 00 00 
80105d21:	eb 2d                	jmp    80105d50 <stateListAdd+0x58>
  } else {
    (*tail)->next = p;
80105d23:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d26:	8b 00                	mov    (%eax),%eax
80105d28:	8b 55 10             	mov    0x10(%ebp),%edx
80105d2b:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
    *tail = (*tail)->next;
80105d31:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d34:	8b 00                	mov    (%eax),%eax
80105d36:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
80105d3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d3f:	89 10                	mov    %edx,(%eax)
    (*tail)->next = 0;
80105d41:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d44:	8b 00                	mov    (%eax),%eax
80105d46:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80105d4d:	00 00 00 
  }

  return 0;
80105d50:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d55:	5d                   	pop    %ebp
80105d56:	c3                   	ret    

80105d57 <stateListRemove>:

static int
stateListRemove(struct proc** head, struct proc** tail, struct proc* p)
{
80105d57:	55                   	push   %ebp
80105d58:	89 e5                	mov    %esp,%ebp
80105d5a:	83 ec 10             	sub    $0x10,%esp
  if (*head == 0 || *tail == 0 || p == 0) {
80105d5d:	8b 45 08             	mov    0x8(%ebp),%eax
80105d60:	8b 00                	mov    (%eax),%eax
80105d62:	85 c0                	test   %eax,%eax
80105d64:	74 0f                	je     80105d75 <stateListRemove+0x1e>
80105d66:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d69:	8b 00                	mov    (%eax),%eax
80105d6b:	85 c0                	test   %eax,%eax
80105d6d:	74 06                	je     80105d75 <stateListRemove+0x1e>
80105d6f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105d73:	75 0a                	jne    80105d7f <stateListRemove+0x28>
    return -1;
80105d75:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d7a:	e9 a5 00 00 00       	jmp    80105e24 <stateListRemove+0xcd>
  }

  struct proc* current = *head;
80105d7f:	8b 45 08             	mov    0x8(%ebp),%eax
80105d82:	8b 00                	mov    (%eax),%eax
80105d84:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct proc* previous = 0;
80105d87:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

  if (current == p) {
80105d8e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d91:	3b 45 10             	cmp    0x10(%ebp),%eax
80105d94:	75 31                	jne    80105dc7 <stateListRemove+0x70>
    *head = (*head)->next;
80105d96:	8b 45 08             	mov    0x8(%ebp),%eax
80105d99:	8b 00                	mov    (%eax),%eax
80105d9b:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
80105da1:	8b 45 08             	mov    0x8(%ebp),%eax
80105da4:	89 10                	mov    %edx,(%eax)
    return 0;
80105da6:	b8 00 00 00 00       	mov    $0x0,%eax
80105dab:	eb 77                	jmp    80105e24 <stateListRemove+0xcd>
  }

  while(current) {
    if (current == p) {
80105dad:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105db0:	3b 45 10             	cmp    0x10(%ebp),%eax
80105db3:	74 1a                	je     80105dcf <stateListRemove+0x78>
      break;
    }

    previous = current;
80105db5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105db8:	89 45 f8             	mov    %eax,-0x8(%ebp)
    current = current->next;
80105dbb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105dbe:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105dc4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if (current == p) {
    *head = (*head)->next;
    return 0;
  }

  while(current) {
80105dc7:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105dcb:	75 e0                	jne    80105dad <stateListRemove+0x56>
80105dcd:	eb 01                	jmp    80105dd0 <stateListRemove+0x79>
    if (current == p) {
      break;
80105dcf:	90                   	nop
    previous = current;
    current = current->next;
  }

  // Process not found, hit eject.
  if (current == 0) {
80105dd0:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105dd4:	75 07                	jne    80105ddd <stateListRemove+0x86>
    return -1;
80105dd6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ddb:	eb 47                	jmp    80105e24 <stateListRemove+0xcd>
  }

  // Process found. Set the appropriate next pointer.
  if (current == *tail) {
80105ddd:	8b 45 0c             	mov    0xc(%ebp),%eax
80105de0:	8b 00                	mov    (%eax),%eax
80105de2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
80105de5:	75 19                	jne    80105e00 <stateListRemove+0xa9>
    *tail = previous;
80105de7:	8b 45 0c             	mov    0xc(%ebp),%eax
80105dea:	8b 55 f8             	mov    -0x8(%ebp),%edx
80105ded:	89 10                	mov    %edx,(%eax)
    (*tail)->next = 0;
80105def:	8b 45 0c             	mov    0xc(%ebp),%eax
80105df2:	8b 00                	mov    (%eax),%eax
80105df4:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80105dfb:	00 00 00 
80105dfe:	eb 12                	jmp    80105e12 <stateListRemove+0xbb>
  } else {
    previous->next = current->next;
80105e00:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e03:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
80105e09:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e0c:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
  }

  // Make sure p->next doesn't point into the list.
  p->next = 0;
80105e12:	8b 45 10             	mov    0x10(%ebp),%eax
80105e15:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80105e1c:	00 00 00 

  return 0;
80105e1f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e24:	c9                   	leave  
80105e25:	c3                   	ret    

80105e26 <initProcessLists>:

static void
initProcessLists(void) {
80105e26:	55                   	push   %ebp
80105e27:	89 e5                	mov    %esp,%ebp
80105e29:	83 ec 10             	sub    $0x10,%esp
  for(int i = 0; i<MAXPRIO+1; ++i)
80105e2c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105e33:	eb 2a                	jmp    80105e5f <initProcessLists+0x39>
  {
    ptable.pLists.ready[i] = 0;
80105e35:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e38:	05 cc 09 00 00       	add    $0x9cc,%eax
80105e3d:	c7 04 85 84 49 11 80 	movl   $0x0,-0x7feeb67c(,%eax,4)
80105e44:	00 00 00 00 
    ptable.pLists.readyTail[i] = 0;
80105e48:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e4b:	05 d0 09 00 00       	add    $0x9d0,%eax
80105e50:	c7 04 85 90 49 11 80 	movl   $0x0,-0x7feeb670(,%eax,4)
80105e57:	00 00 00 00 
  return 0;
}

static void
initProcessLists(void) {
  for(int i = 0; i<MAXPRIO+1; ++i)
80105e5b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105e5f:	83 7d fc 06          	cmpl   $0x6,-0x4(%ebp)
80105e63:	7e d0                	jle    80105e35 <initProcessLists+0xf>
  {
    ptable.pLists.ready[i] = 0;
    ptable.pLists.readyTail[i] = 0;
  }
  ptable.pLists.free = 0;
80105e65:	c7 05 ec 70 11 80 00 	movl   $0x0,0x801170ec
80105e6c:	00 00 00 
  ptable.pLists.freeTail = 0;
80105e6f:	c7 05 f0 70 11 80 00 	movl   $0x0,0x801170f0
80105e76:	00 00 00 
  ptable.pLists.sleep = 0;
80105e79:	c7 05 f4 70 11 80 00 	movl   $0x0,0x801170f4
80105e80:	00 00 00 
  ptable.pLists.sleepTail = 0;
80105e83:	c7 05 f8 70 11 80 00 	movl   $0x0,0x801170f8
80105e8a:	00 00 00 
  ptable.pLists.zombie = 0;
80105e8d:	c7 05 fc 70 11 80 00 	movl   $0x0,0x801170fc
80105e94:	00 00 00 
  ptable.pLists.zombieTail = 0;
80105e97:	c7 05 00 71 11 80 00 	movl   $0x0,0x80117100
80105e9e:	00 00 00 
  ptable.pLists.running = 0;
80105ea1:	c7 05 04 71 11 80 00 	movl   $0x0,0x80117104
80105ea8:	00 00 00 
  ptable.pLists.runningTail = 0;
80105eab:	c7 05 08 71 11 80 00 	movl   $0x0,0x80117108
80105eb2:	00 00 00 
  ptable.pLists.embryo = 0;
80105eb5:	c7 05 0c 71 11 80 00 	movl   $0x0,0x8011710c
80105ebc:	00 00 00 
  ptable.pLists.embryoTail = 0;
80105ebf:	c7 05 10 71 11 80 00 	movl   $0x0,0x80117110
80105ec6:	00 00 00 
}
80105ec9:	90                   	nop
80105eca:	c9                   	leave  
80105ecb:	c3                   	ret    

80105ecc <initFreeList>:

static void
initFreeList(void) {
80105ecc:	55                   	push   %ebp
80105ecd:	89 e5                	mov    %esp,%ebp
80105ecf:	83 ec 18             	sub    $0x18,%esp
  if (!holding(&ptable.lock)) {
80105ed2:	83 ec 0c             	sub    $0xc,%esp
80105ed5:	68 80 49 11 80       	push   $0x80114980
80105eda:	e8 c9 0a 00 00       	call   801069a8 <holding>
80105edf:	83 c4 10             	add    $0x10,%esp
80105ee2:	85 c0                	test   %eax,%eax
80105ee4:	75 0d                	jne    80105ef3 <initFreeList+0x27>
    panic("acquire the ptable lock before calling initFreeList\n");
80105ee6:	83 ec 0c             	sub    $0xc,%esp
80105ee9:	68 9c a5 10 80       	push   $0x8010a59c
80105eee:	e8 73 a6 ff ff       	call   80100566 <panic>
  }

  struct proc* p;

  for (p = ptable.proc; p < ptable.proc + NPROC; ++p) {
80105ef3:	c7 45 f4 b4 49 11 80 	movl   $0x801149b4,-0xc(%ebp)
80105efa:	eb 29                	jmp    80105f25 <initFreeList+0x59>
    p->state = UNUSED;
80105efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eff:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail, p);
80105f06:	83 ec 04             	sub    $0x4,%esp
80105f09:	ff 75 f4             	pushl  -0xc(%ebp)
80105f0c:	68 f0 70 11 80       	push   $0x801170f0
80105f11:	68 ec 70 11 80       	push   $0x801170ec
80105f16:	e8 dd fd ff ff       	call   80105cf8 <stateListAdd>
80105f1b:	83 c4 10             	add    $0x10,%esp
    panic("acquire the ptable lock before calling initFreeList\n");
  }

  struct proc* p;

  for (p = ptable.proc; p < ptable.proc + NPROC; ++p) {
80105f1e:	81 45 f4 9c 00 00 00 	addl   $0x9c,-0xc(%ebp)
80105f25:	b8 b4 70 11 80       	mov    $0x801170b4,%eax
80105f2a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80105f2d:	72 cd                	jb     80105efc <initFreeList+0x30>
    p->state = UNUSED;
    stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail, p);
  }
}
80105f2f:	90                   	nop
80105f30:	c9                   	leave  
80105f31:	c3                   	ret    

80105f32 <getprocs>:
#endif

//Get all current processes within the system.
int
getprocs(int max, struct uproc* proctable)
{
80105f32:	55                   	push   %ebp
80105f33:	89 e5                	mov    %esp,%ebp
80105f35:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int i;

  //LOCK PTABLE
  acquire(&ptable.lock);
80105f38:	83 ec 0c             	sub    $0xc,%esp
80105f3b:	68 80 49 11 80       	push   $0x80114980
80105f40:	e8 30 09 00 00       	call   80106875 <acquire>
80105f45:	83 c4 10             	add    $0x10,%esp

  //ptable gets incremented within forloop, i get incremented at the end
  //of the forloop.
  for(i=0, p = ptable.proc; p < &ptable.proc[NPROC] && i<max; p++)
80105f48:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80105f4f:	c7 45 f4 b4 49 11 80 	movl   $0x801149b4,-0xc(%ebp)
80105f56:	e9 a4 01 00 00       	jmp    801060ff <getprocs+0x1cd>
  {
    //copy all the info into one element of the array
    //skip if the process is in the unused state
    if(p->state != UNUSED && p->state != EMBRYO)
80105f5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f5e:	8b 40 0c             	mov    0xc(%eax),%eax
80105f61:	85 c0                	test   %eax,%eax
80105f63:	0f 84 8f 01 00 00    	je     801060f8 <getprocs+0x1c6>
80105f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f6c:	8b 40 0c             	mov    0xc(%eax),%eax
80105f6f:	83 f8 01             	cmp    $0x1,%eax
80105f72:	0f 84 80 01 00 00    	je     801060f8 <getprocs+0x1c6>
    {
      proctable[i].pid = p->pid;
80105f78:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105f7b:	89 d0                	mov    %edx,%eax
80105f7d:	01 c0                	add    %eax,%eax
80105f7f:	01 d0                	add    %edx,%eax
80105f81:	c1 e0 05             	shl    $0x5,%eax
80105f84:	89 c2                	mov    %eax,%edx
80105f86:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f89:	01 c2                	add    %eax,%edx
80105f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f8e:	8b 40 10             	mov    0x10(%eax),%eax
80105f91:	89 02                	mov    %eax,(%edx)
      proctable[i].uid = p->uid;
80105f93:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105f96:	89 d0                	mov    %edx,%eax
80105f98:	01 c0                	add    %eax,%eax
80105f9a:	01 d0                	add    %edx,%eax
80105f9c:	c1 e0 05             	shl    $0x5,%eax
80105f9f:	89 c2                	mov    %eax,%edx
80105fa1:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fa4:	01 c2                	add    %eax,%edx
80105fa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fa9:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105faf:	89 42 04             	mov    %eax,0x4(%edx)
      proctable[i].gid = p->gid;
80105fb2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105fb5:	89 d0                	mov    %edx,%eax
80105fb7:	01 c0                	add    %eax,%eax
80105fb9:	01 d0                	add    %edx,%eax
80105fbb:	c1 e0 05             	shl    $0x5,%eax
80105fbe:	89 c2                	mov    %eax,%edx
80105fc0:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fc3:	01 c2                	add    %eax,%edx
80105fc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fc8:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80105fce:	89 42 08             	mov    %eax,0x8(%edx)
      proctable[i].priority = p->priority;
80105fd1:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105fd4:	89 d0                	mov    %edx,%eax
80105fd6:	01 c0                	add    %eax,%eax
80105fd8:	01 d0                	add    %edx,%eax
80105fda:	c1 e0 05             	shl    $0x5,%eax
80105fdd:	89 c2                	mov    %eax,%edx
80105fdf:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fe2:	01 c2                	add    %eax,%edx
80105fe4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fe7:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80105fed:	89 42 5c             	mov    %eax,0x5c(%edx)
      if(p->parent != 0)
80105ff0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ff3:	8b 40 14             	mov    0x14(%eax),%eax
80105ff6:	85 c0                	test   %eax,%eax
80105ff8:	74 21                	je     8010601b <getprocs+0xe9>
        proctable[i].ppid = p->parent->pid;
80105ffa:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ffd:	89 d0                	mov    %edx,%eax
80105fff:	01 c0                	add    %eax,%eax
80106001:	01 d0                	add    %edx,%eax
80106003:	c1 e0 05             	shl    $0x5,%eax
80106006:	89 c2                	mov    %eax,%edx
80106008:	8b 45 0c             	mov    0xc(%ebp),%eax
8010600b:	01 c2                	add    %eax,%edx
8010600d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106010:	8b 40 14             	mov    0x14(%eax),%eax
80106013:	8b 40 10             	mov    0x10(%eax),%eax
80106016:	89 42 0c             	mov    %eax,0xc(%edx)
80106019:	eb 1c                	jmp    80106037 <getprocs+0x105>
      else
        proctable[i].ppid = p->pid;
8010601b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010601e:	89 d0                	mov    %edx,%eax
80106020:	01 c0                	add    %eax,%eax
80106022:	01 d0                	add    %edx,%eax
80106024:	c1 e0 05             	shl    $0x5,%eax
80106027:	89 c2                	mov    %eax,%edx
80106029:	8b 45 0c             	mov    0xc(%ebp),%eax
8010602c:	01 c2                	add    %eax,%edx
8010602e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106031:	8b 40 10             	mov    0x10(%eax),%eax
80106034:	89 42 0c             	mov    %eax,0xc(%edx)

      //Get the current ticks for elapsed ticks.
      proctable[i].elapsed_ticks = ticks-p->start_ticks;
80106037:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010603a:	89 d0                	mov    %edx,%eax
8010603c:	01 c0                	add    %eax,%eax
8010603e:	01 d0                	add    %edx,%eax
80106040:	c1 e0 05             	shl    $0x5,%eax
80106043:	89 c2                	mov    %eax,%edx
80106045:	8b 45 0c             	mov    0xc(%ebp),%eax
80106048:	01 c2                	add    %eax,%edx
8010604a:	8b 0d 20 79 11 80    	mov    0x80117920,%ecx
80106050:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106053:	8b 40 7c             	mov    0x7c(%eax),%eax
80106056:	29 c1                	sub    %eax,%ecx
80106058:	89 c8                	mov    %ecx,%eax
8010605a:	89 42 10             	mov    %eax,0x10(%edx)
      proctable[i].CPU_total_ticks = p->cpu_ticks_total;
8010605d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106060:	89 d0                	mov    %edx,%eax
80106062:	01 c0                	add    %eax,%eax
80106064:	01 d0                	add    %edx,%eax
80106066:	c1 e0 05             	shl    $0x5,%eax
80106069:	89 c2                	mov    %eax,%edx
8010606b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010606e:	01 c2                	add    %eax,%edx
80106070:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106073:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80106079:	89 42 14             	mov    %eax,0x14(%edx)
      safestrcpy(proctable[i].state, states[p->state], sizeof(proctable[i].state));
8010607c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010607f:	8b 40 0c             	mov    0xc(%eax),%eax
80106082:	8b 0c 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%ecx
80106089:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010608c:	89 d0                	mov    %edx,%eax
8010608e:	01 c0                	add    %eax,%eax
80106090:	01 d0                	add    %edx,%eax
80106092:	c1 e0 05             	shl    $0x5,%eax
80106095:	89 c2                	mov    %eax,%edx
80106097:	8b 45 0c             	mov    0xc(%ebp),%eax
8010609a:	01 d0                	add    %edx,%eax
8010609c:	83 c0 18             	add    $0x18,%eax
8010609f:	83 ec 04             	sub    $0x4,%esp
801060a2:	6a 20                	push   $0x20
801060a4:	51                   	push   %ecx
801060a5:	50                   	push   %eax
801060a6:	e8 30 0c 00 00       	call   80106cdb <safestrcpy>
801060ab:	83 c4 10             	add    $0x10,%esp
      proctable[i].size = p->sz;
801060ae:	8b 55 f0             	mov    -0x10(%ebp),%edx
801060b1:	89 d0                	mov    %edx,%eax
801060b3:	01 c0                	add    %eax,%eax
801060b5:	01 d0                	add    %edx,%eax
801060b7:	c1 e0 05             	shl    $0x5,%eax
801060ba:	89 c2                	mov    %eax,%edx
801060bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801060bf:	01 c2                	add    %eax,%edx
801060c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060c4:	8b 00                	mov    (%eax),%eax
801060c6:	89 42 38             	mov    %eax,0x38(%edx)
      safestrcpy(proctable[i].name, p->name, sizeof(p->name));
801060c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060cc:	8d 48 6c             	lea    0x6c(%eax),%ecx
801060cf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801060d2:	89 d0                	mov    %edx,%eax
801060d4:	01 c0                	add    %eax,%eax
801060d6:	01 d0                	add    %edx,%eax
801060d8:	c1 e0 05             	shl    $0x5,%eax
801060db:	89 c2                	mov    %eax,%edx
801060dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801060e0:	01 d0                	add    %edx,%eax
801060e2:	83 c0 3c             	add    $0x3c,%eax
801060e5:	83 ec 04             	sub    $0x4,%esp
801060e8:	6a 10                	push   $0x10
801060ea:	51                   	push   %ecx
801060eb:	50                   	push   %eax
801060ec:	e8 ea 0b 00 00       	call   80106cdb <safestrcpy>
801060f1:	83 c4 10             	add    $0x10,%esp

      //Increment the array that is having info copied into
      ++i;
801060f4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  //LOCK PTABLE
  acquire(&ptable.lock);

  //ptable gets incremented within forloop, i get incremented at the end
  //of the forloop.
  for(i=0, p = ptable.proc; p < &ptable.proc[NPROC] && i<max; p++)
801060f8:	81 45 f4 9c 00 00 00 	addl   $0x9c,-0xc(%ebp)
801060ff:	81 7d f4 b4 70 11 80 	cmpl   $0x801170b4,-0xc(%ebp)
80106106:	73 0c                	jae    80106114 <getprocs+0x1e2>
80106108:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010610b:	3b 45 08             	cmp    0x8(%ebp),%eax
8010610e:	0f 8c 47 fe ff ff    	jl     80105f5b <getprocs+0x29>

    }
  }

  //UNLOCK PTABLE
  release(&ptable.lock);
80106114:	83 ec 0c             	sub    $0xc,%esp
80106117:	68 80 49 11 80       	push   $0x80114980
8010611c:	e8 bb 07 00 00       	call   801068dc <release>
80106121:	83 c4 10             	add    $0x10,%esp

  return i;
80106124:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106127:	c9                   	leave  
80106128:	c3                   	ret    

80106129 <piddump>:

void
piddump(void)
{
80106129:	55                   	push   %ebp
8010612a:	89 e5                	mov    %esp,%ebp
8010612c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  acquire(&ptable.lock);
8010612f:	83 ec 0c             	sub    $0xc,%esp
80106132:	68 80 49 11 80       	push   $0x80114980
80106137:	e8 39 07 00 00       	call   80106875 <acquire>
8010613c:	83 c4 10             	add    $0x10,%esp
  cprintf("\nReady List Processes:\n");
8010613f:	83 ec 0c             	sub    $0xc,%esp
80106142:	68 d1 a5 10 80       	push   $0x8010a5d1
80106147:	e8 7a a2 ff ff       	call   801003c6 <cprintf>
8010614c:	83 c4 10             	add    $0x10,%esp
  for(int i = 0; i<MAXPRIO+1; ++i)
8010614f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80106156:	e9 8b 00 00 00       	jmp    801061e6 <piddump+0xbd>
  {
    p = ptable.pLists.ready[i];
8010615b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010615e:	05 cc 09 00 00       	add    $0x9cc,%eax
80106163:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
8010616a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("%d: ", i);
8010616d:	83 ec 08             	sub    $0x8,%esp
80106170:	ff 75 f0             	pushl  -0x10(%ebp)
80106173:	68 e9 a5 10 80       	push   $0x8010a5e9
80106178:	e8 49 a2 ff ff       	call   801003c6 <cprintf>
8010617d:	83 c4 10             	add    $0x10,%esp
    while(p)
80106180:	eb 4a                	jmp    801061cc <piddump+0xa3>
    {
      cprintf("(%d, %d)", p->pid, p->budget);
80106182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106185:	8b 90 94 00 00 00    	mov    0x94(%eax),%edx
8010618b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010618e:	8b 40 10             	mov    0x10(%eax),%eax
80106191:	83 ec 04             	sub    $0x4,%esp
80106194:	52                   	push   %edx
80106195:	50                   	push   %eax
80106196:	68 ee a5 10 80       	push   $0x8010a5ee
8010619b:	e8 26 a2 ff ff       	call   801003c6 <cprintf>
801061a0:	83 c4 10             	add    $0x10,%esp
      if(p->next)
801061a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061a6:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801061ac:	85 c0                	test   %eax,%eax
801061ae:	74 10                	je     801061c0 <piddump+0x97>
        cprintf(" -> ");
801061b0:	83 ec 0c             	sub    $0xc,%esp
801061b3:	68 f7 a5 10 80       	push   $0x8010a5f7
801061b8:	e8 09 a2 ff ff       	call   801003c6 <cprintf>
801061bd:	83 c4 10             	add    $0x10,%esp
      p = p->next;
801061c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061c3:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801061c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cprintf("\nReady List Processes:\n");
  for(int i = 0; i<MAXPRIO+1; ++i)
  {
    p = ptable.pLists.ready[i];
    cprintf("%d: ", i);
    while(p)
801061cc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061d0:	75 b0                	jne    80106182 <piddump+0x59>
      cprintf("(%d, %d)", p->pid, p->budget);
      if(p->next)
        cprintf(" -> ");
      p = p->next;
    }
    cprintf("\n");
801061d2:	83 ec 0c             	sub    $0xc,%esp
801061d5:	68 99 a5 10 80       	push   $0x8010a599
801061da:	e8 e7 a1 ff ff       	call   801003c6 <cprintf>
801061df:	83 c4 10             	add    $0x10,%esp
piddump(void)
{
  struct proc *p;
  acquire(&ptable.lock);
  cprintf("\nReady List Processes:\n");
  for(int i = 0; i<MAXPRIO+1; ++i)
801061e2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801061e6:	83 7d f0 06          	cmpl   $0x6,-0x10(%ebp)
801061ea:	0f 8e 6b ff ff ff    	jle    8010615b <piddump+0x32>
        cprintf(" -> ");
      p = p->next;
    }
    cprintf("\n");
  }
  release(&ptable.lock);
801061f0:	83 ec 0c             	sub    $0xc,%esp
801061f3:	68 80 49 11 80       	push   $0x80114980
801061f8:	e8 df 06 00 00       	call   801068dc <release>
801061fd:	83 c4 10             	add    $0x10,%esp
}
80106200:	90                   	nop
80106201:	c9                   	leave  
80106202:	c3                   	ret    

80106203 <freedump>:

void
freedump(void)
{
80106203:	55                   	push   %ebp
80106204:	89 e5                	mov    %esp,%ebp
80106206:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int counter = 0;
80106209:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  acquire(&ptable.lock);
80106210:	83 ec 0c             	sub    $0xc,%esp
80106213:	68 80 49 11 80       	push   $0x80114980
80106218:	e8 58 06 00 00       	call   80106875 <acquire>
8010621d:	83 c4 10             	add    $0x10,%esp
  p = ptable.pLists.free;
80106220:	a1 ec 70 11 80       	mov    0x801170ec,%eax
80106225:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(p)
80106228:	eb 10                	jmp    8010623a <freedump+0x37>
  {
    p = p->next;
8010622a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010622d:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106233:	89 45 f4             	mov    %eax,-0xc(%ebp)
    ++counter;
80106236:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
{
  struct proc *p;
  int counter = 0;
  acquire(&ptable.lock);
  p = ptable.pLists.free;
  while(p)
8010623a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010623e:	75 ea                	jne    8010622a <freedump+0x27>
  {
    p = p->next;
    ++counter;
  }

  cprintf("\nFree List Size: %d processes\n", counter);
80106240:	83 ec 08             	sub    $0x8,%esp
80106243:	ff 75 f0             	pushl  -0x10(%ebp)
80106246:	68 fc a5 10 80       	push   $0x8010a5fc
8010624b:	e8 76 a1 ff ff       	call   801003c6 <cprintf>
80106250:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80106253:	83 ec 0c             	sub    $0xc,%esp
80106256:	68 80 49 11 80       	push   $0x80114980
8010625b:	e8 7c 06 00 00       	call   801068dc <release>
80106260:	83 c4 10             	add    $0x10,%esp
}
80106263:	90                   	nop
80106264:	c9                   	leave  
80106265:	c3                   	ret    

80106266 <sleepdump>:

void
sleepdump(void)
{
80106266:	55                   	push   %ebp
80106267:	89 e5                	mov    %esp,%ebp
80106269:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  acquire(&ptable.lock);
8010626c:	83 ec 0c             	sub    $0xc,%esp
8010626f:	68 80 49 11 80       	push   $0x80114980
80106274:	e8 fc 05 00 00       	call   80106875 <acquire>
80106279:	83 c4 10             	add    $0x10,%esp
  p = ptable.pLists.sleep;
8010627c:	a1 f4 70 11 80       	mov    0x801170f4,%eax
80106281:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cprintf("\nSleep List Processes:\n");
80106284:	83 ec 0c             	sub    $0xc,%esp
80106287:	68 1b a6 10 80       	push   $0x8010a61b
8010628c:	e8 35 a1 ff ff       	call   801003c6 <cprintf>
80106291:	83 c4 10             	add    $0x10,%esp
  while(p)
80106294:	eb 40                	jmp    801062d6 <sleepdump+0x70>
  {
    cprintf("%d", p->pid);
80106296:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106299:	8b 40 10             	mov    0x10(%eax),%eax
8010629c:	83 ec 08             	sub    $0x8,%esp
8010629f:	50                   	push   %eax
801062a0:	68 88 a5 10 80       	push   $0x8010a588
801062a5:	e8 1c a1 ff ff       	call   801003c6 <cprintf>
801062aa:	83 c4 10             	add    $0x10,%esp
    if(p->next)
801062ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062b0:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801062b6:	85 c0                	test   %eax,%eax
801062b8:	74 10                	je     801062ca <sleepdump+0x64>
      cprintf(" -> ");
801062ba:	83 ec 0c             	sub    $0xc,%esp
801062bd:	68 f7 a5 10 80       	push   $0x8010a5f7
801062c2:	e8 ff a0 ff ff       	call   801003c6 <cprintf>
801062c7:	83 c4 10             	add    $0x10,%esp
    p = p->next;
801062ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062cd:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801062d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
{
  struct proc *p;
  acquire(&ptable.lock);
  p = ptable.pLists.sleep;
  cprintf("\nSleep List Processes:\n");
  while(p)
801062d6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062da:	75 ba                	jne    80106296 <sleepdump+0x30>
    cprintf("%d", p->pid);
    if(p->next)
      cprintf(" -> ");
    p = p->next;
  }
  cprintf("\n");
801062dc:	83 ec 0c             	sub    $0xc,%esp
801062df:	68 99 a5 10 80       	push   $0x8010a599
801062e4:	e8 dd a0 ff ff       	call   801003c6 <cprintf>
801062e9:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801062ec:	83 ec 0c             	sub    $0xc,%esp
801062ef:	68 80 49 11 80       	push   $0x80114980
801062f4:	e8 e3 05 00 00       	call   801068dc <release>
801062f9:	83 c4 10             	add    $0x10,%esp
}
801062fc:	90                   	nop
801062fd:	c9                   	leave  
801062fe:	c3                   	ret    

801062ff <zombiedump>:

void
zombiedump(void)
{
801062ff:	55                   	push   %ebp
80106300:	89 e5                	mov    %esp,%ebp
80106302:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  acquire(&ptable.lock);
80106305:	83 ec 0c             	sub    $0xc,%esp
80106308:	68 80 49 11 80       	push   $0x80114980
8010630d:	e8 63 05 00 00       	call   80106875 <acquire>
80106312:	83 c4 10             	add    $0x10,%esp
  p = ptable.pLists.zombie;
80106315:	a1 fc 70 11 80       	mov    0x801170fc,%eax
8010631a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cprintf("\nZombie List Processes:\n");
8010631d:	83 ec 0c             	sub    $0xc,%esp
80106320:	68 33 a6 10 80       	push   $0x8010a633
80106325:	e8 9c a0 ff ff       	call   801003c6 <cprintf>
8010632a:	83 c4 10             	add    $0x10,%esp
  while(p)
8010632d:	eb 5c                	jmp    8010638b <zombiedump+0x8c>
  {
    cprintf("(PID%d, PPID%d)", p->pid, (p->parent? p->parent->pid : p->pid));
8010632f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106332:	8b 40 14             	mov    0x14(%eax),%eax
80106335:	85 c0                	test   %eax,%eax
80106337:	74 0b                	je     80106344 <zombiedump+0x45>
80106339:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010633c:	8b 40 14             	mov    0x14(%eax),%eax
8010633f:	8b 40 10             	mov    0x10(%eax),%eax
80106342:	eb 06                	jmp    8010634a <zombiedump+0x4b>
80106344:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106347:	8b 40 10             	mov    0x10(%eax),%eax
8010634a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010634d:	8b 52 10             	mov    0x10(%edx),%edx
80106350:	83 ec 04             	sub    $0x4,%esp
80106353:	50                   	push   %eax
80106354:	52                   	push   %edx
80106355:	68 4c a6 10 80       	push   $0x8010a64c
8010635a:	e8 67 a0 ff ff       	call   801003c6 <cprintf>
8010635f:	83 c4 10             	add    $0x10,%esp
    if(p->next)
80106362:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106365:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010636b:	85 c0                	test   %eax,%eax
8010636d:	74 10                	je     8010637f <zombiedump+0x80>
      cprintf(" -> ");
8010636f:	83 ec 0c             	sub    $0xc,%esp
80106372:	68 f7 a5 10 80       	push   $0x8010a5f7
80106377:	e8 4a a0 ff ff       	call   801003c6 <cprintf>
8010637c:	83 c4 10             	add    $0x10,%esp
    p = p->next;
8010637f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106382:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106388:	89 45 f4             	mov    %eax,-0xc(%ebp)
{
  struct proc *p;
  acquire(&ptable.lock);
  p = ptable.pLists.zombie;
  cprintf("\nZombie List Processes:\n");
  while(p)
8010638b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010638f:	75 9e                	jne    8010632f <zombiedump+0x30>
    cprintf("(PID%d, PPID%d)", p->pid, (p->parent? p->parent->pid : p->pid));
    if(p->next)
      cprintf(" -> ");
    p = p->next;
  }
  cprintf("\n");
80106391:	83 ec 0c             	sub    $0xc,%esp
80106394:	68 99 a5 10 80       	push   $0x8010a599
80106399:	e8 28 a0 ff ff       	call   801003c6 <cprintf>
8010639e:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801063a1:	83 ec 0c             	sub    $0xc,%esp
801063a4:	68 80 49 11 80       	push   $0x80114980
801063a9:	e8 2e 05 00 00       	call   801068dc <release>
801063ae:	83 c4 10             	add    $0x10,%esp
}
801063b1:	90                   	nop
801063b2:	c9                   	leave  
801063b3:	c3                   	ret    

801063b4 <assertState>:

void
assertState(struct proc* p, enum procstate state)
{
801063b4:	55                   	push   %ebp
801063b5:	89 e5                	mov    %esp,%ebp
801063b7:	83 ec 08             	sub    $0x8,%esp
  if(p->state != state)
801063ba:	8b 45 08             	mov    0x8(%ebp),%eax
801063bd:	8b 40 0c             	mov    0xc(%eax),%eax
801063c0:	3b 45 0c             	cmp    0xc(%ebp),%eax
801063c3:	74 0d                	je     801063d2 <assertState+0x1e>
    panic("proc state does not match list state.");
801063c5:	83 ec 0c             	sub    $0xc,%esp
801063c8:	68 5c a6 10 80       	push   $0x8010a65c
801063cd:	e8 94 a1 ff ff       	call   80100566 <panic>
}
801063d2:	90                   	nop
801063d3:	c9                   	leave  
801063d4:	c3                   	ret    

801063d5 <setpriority>:

int
setpriority(int pid, int priority)
{
801063d5:	55                   	push   %ebp
801063d6:	89 e5                	mov    %esp,%ebp
801063d8:	83 ec 18             	sub    $0x18,%esp
  struct proc* p;
  if(pid<0 || priority < 0 || priority > MAXPRIO+1)
801063db:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801063df:	78 0c                	js     801063ed <setpriority+0x18>
801063e1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801063e5:	78 06                	js     801063ed <setpriority+0x18>
801063e7:	83 7d 0c 07          	cmpl   $0x7,0xc(%ebp)
801063eb:	7e 0a                	jle    801063f7 <setpriority+0x22>
    return -1;
801063ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063f2:	e9 46 02 00 00       	jmp    8010663d <setpriority+0x268>

  acquire(&ptable.lock);
801063f7:	83 ec 0c             	sub    $0xc,%esp
801063fa:	68 80 49 11 80       	push   $0x80114980
801063ff:	e8 71 04 00 00       	call   80106875 <acquire>
80106404:	83 c4 10             	add    $0x10,%esp
  for(int i = 0; i < MAXPRIO+1; ++i)
80106407:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010640e:	e9 3c 01 00 00       	jmp    8010654f <setpriority+0x17a>
  {
    for(p = ptable.pLists.ready[i];p;p=p->next)
80106413:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106416:	05 cc 09 00 00       	add    $0x9cc,%eax
8010641b:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
80106422:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106425:	e9 17 01 00 00       	jmp    80106541 <setpriority+0x16c>
    {
      if(p->pid == pid && priority != p->priority)
8010642a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010642d:	8b 50 10             	mov    0x10(%eax),%edx
80106430:	8b 45 08             	mov    0x8(%ebp),%eax
80106433:	39 c2                	cmp    %eax,%edx
80106435:	0f 85 fa 00 00 00    	jne    80106535 <setpriority+0x160>
8010643b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010643e:	8b 90 98 00 00 00    	mov    0x98(%eax),%edx
80106444:	8b 45 0c             	mov    0xc(%ebp),%eax
80106447:	39 c2                	cmp    %eax,%edx
80106449:	0f 84 e6 00 00 00    	je     80106535 <setpriority+0x160>
      {
#ifdef CS333_P3P4
        if(stateListRemove(&ptable.pLists.ready[p->priority], &ptable.pLists.readyTail[p->priority], p))
8010644f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106452:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80106458:	05 d0 09 00 00       	add    $0x9d0,%eax
8010645d:	c1 e0 02             	shl    $0x2,%eax
80106460:	05 80 49 11 80       	add    $0x80114980,%eax
80106465:	8d 50 10             	lea    0x10(%eax),%edx
80106468:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010646b:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80106471:	05 cc 09 00 00       	add    $0x9cc,%eax
80106476:	c1 e0 02             	shl    $0x2,%eax
80106479:	05 80 49 11 80       	add    $0x80114980,%eax
8010647e:	83 c0 04             	add    $0x4,%eax
80106481:	83 ec 04             	sub    $0x4,%esp
80106484:	ff 75 f4             	pushl  -0xc(%ebp)
80106487:	52                   	push   %edx
80106488:	50                   	push   %eax
80106489:	e8 c9 f8 ff ff       	call   80105d57 <stateListRemove>
8010648e:	83 c4 10             	add    $0x10,%esp
80106491:	85 c0                	test   %eax,%eax
80106493:	74 0d                	je     801064a2 <setpriority+0xcd>
          panic("Error removing process from current priority");
80106495:	83 ec 0c             	sub    $0xc,%esp
80106498:	68 84 a6 10 80       	push   $0x8010a684
8010649d:	e8 c4 a0 ff ff       	call   80100566 <panic>
        p->priority = priority;
801064a2:	8b 55 0c             	mov    0xc(%ebp),%edx
801064a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064a8:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
        if(stateListAdd(&ptable.pLists.ready[p->priority], &ptable.pLists.readyTail[p->priority], p))
801064ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064b1:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801064b7:	05 d0 09 00 00       	add    $0x9d0,%eax
801064bc:	c1 e0 02             	shl    $0x2,%eax
801064bf:	05 80 49 11 80       	add    $0x80114980,%eax
801064c4:	8d 50 10             	lea    0x10(%eax),%edx
801064c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064ca:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801064d0:	05 cc 09 00 00       	add    $0x9cc,%eax
801064d5:	c1 e0 02             	shl    $0x2,%eax
801064d8:	05 80 49 11 80       	add    $0x80114980,%eax
801064dd:	83 c0 04             	add    $0x4,%eax
801064e0:	83 ec 04             	sub    $0x4,%esp
801064e3:	ff 75 f4             	pushl  -0xc(%ebp)
801064e6:	52                   	push   %edx
801064e7:	50                   	push   %eax
801064e8:	e8 0b f8 ff ff       	call   80105cf8 <stateListAdd>
801064ed:	83 c4 10             	add    $0x10,%esp
801064f0:	85 c0                	test   %eax,%eax
801064f2:	74 0d                	je     80106501 <setpriority+0x12c>
          panic("Error adding process to current priority");
801064f4:	83 ec 0c             	sub    $0xc,%esp
801064f7:	68 b4 a6 10 80       	push   $0x8010a6b4
801064fc:	e8 65 a0 ff ff       	call   80100566 <panic>
#endif
        p->budget = BUDGET*(p->priority+1);
80106501:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106504:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
8010650a:	83 c0 01             	add    $0x1,%eax
8010650d:	6b c0 64             	imul   $0x64,%eax,%eax
80106510:	89 c2                	mov    %eax,%edx
80106512:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106515:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
        release(&ptable.lock);
8010651b:	83 ec 0c             	sub    $0xc,%esp
8010651e:	68 80 49 11 80       	push   $0x80114980
80106523:	e8 b4 03 00 00       	call   801068dc <release>
80106528:	83 c4 10             	add    $0x10,%esp
        return 0;
8010652b:	b8 00 00 00 00       	mov    $0x0,%eax
80106530:	e9 08 01 00 00       	jmp    8010663d <setpriority+0x268>
    return -1;

  acquire(&ptable.lock);
  for(int i = 0; i < MAXPRIO+1; ++i)
  {
    for(p = ptable.pLists.ready[i];p;p=p->next)
80106535:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106538:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010653e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106541:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106545:	0f 85 df fe ff ff    	jne    8010642a <setpriority+0x55>
  struct proc* p;
  if(pid<0 || priority < 0 || priority > MAXPRIO+1)
    return -1;

  acquire(&ptable.lock);
  for(int i = 0; i < MAXPRIO+1; ++i)
8010654b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010654f:	83 7d f0 06          	cmpl   $0x6,-0x10(%ebp)
80106553:	0f 8e ba fe ff ff    	jle    80106413 <setpriority+0x3e>
        release(&ptable.lock);
        return 0;
      }
    }
  }
  for(p = ptable.pLists.sleep; p ; p=p->next)
80106559:	a1 f4 70 11 80       	mov    0x801170f4,%eax
8010655e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106561:	eb 59                	jmp    801065bc <setpriority+0x1e7>
  {
    if(p->pid == pid)
80106563:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106566:	8b 50 10             	mov    0x10(%eax),%edx
80106569:	8b 45 08             	mov    0x8(%ebp),%eax
8010656c:	39 c2                	cmp    %eax,%edx
8010656e:	75 40                	jne    801065b0 <setpriority+0x1db>
    {
      p->priority = priority;
80106570:	8b 55 0c             	mov    0xc(%ebp),%edx
80106573:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106576:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
      p->budget = BUDGET*(p->priority+1);
8010657c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010657f:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80106585:	83 c0 01             	add    $0x1,%eax
80106588:	6b c0 64             	imul   $0x64,%eax,%eax
8010658b:	89 c2                	mov    %eax,%edx
8010658d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106590:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
      release(&ptable.lock);
80106596:	83 ec 0c             	sub    $0xc,%esp
80106599:	68 80 49 11 80       	push   $0x80114980
8010659e:	e8 39 03 00 00       	call   801068dc <release>
801065a3:	83 c4 10             	add    $0x10,%esp
      return 0;
801065a6:	b8 00 00 00 00       	mov    $0x0,%eax
801065ab:	e9 8d 00 00 00       	jmp    8010663d <setpriority+0x268>
        release(&ptable.lock);
        return 0;
      }
    }
  }
  for(p = ptable.pLists.sleep; p ; p=p->next)
801065b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065b3:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801065b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801065bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065c0:	75 a1                	jne    80106563 <setpriority+0x18e>
      release(&ptable.lock);
      return 0;
    }
  }

  for(p = ptable.pLists.running; p ; p=p->next)
801065c2:	a1 04 71 11 80       	mov    0x80117104,%eax
801065c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801065ca:	eb 56                	jmp    80106622 <setpriority+0x24d>
  {
    if(p->pid == pid)
801065cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065cf:	8b 50 10             	mov    0x10(%eax),%edx
801065d2:	8b 45 08             	mov    0x8(%ebp),%eax
801065d5:	39 c2                	cmp    %eax,%edx
801065d7:	75 3d                	jne    80106616 <setpriority+0x241>
    {
      p->priority = priority;
801065d9:	8b 55 0c             	mov    0xc(%ebp),%edx
801065dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065df:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
      p->budget = BUDGET*(p->priority+1);
801065e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065e8:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801065ee:	83 c0 01             	add    $0x1,%eax
801065f1:	6b c0 64             	imul   $0x64,%eax,%eax
801065f4:	89 c2                	mov    %eax,%edx
801065f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065f9:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
      release(&ptable.lock);
801065ff:	83 ec 0c             	sub    $0xc,%esp
80106602:	68 80 49 11 80       	push   $0x80114980
80106607:	e8 d0 02 00 00       	call   801068dc <release>
8010660c:	83 c4 10             	add    $0x10,%esp
      return 0;
8010660f:	b8 00 00 00 00       	mov    $0x0,%eax
80106614:	eb 27                	jmp    8010663d <setpriority+0x268>
      release(&ptable.lock);
      return 0;
    }
  }

  for(p = ptable.pLists.running; p ; p=p->next)
80106616:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106619:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010661f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106622:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106626:	75 a4                	jne    801065cc <setpriority+0x1f7>
      release(&ptable.lock);
      return 0;
    }
  }

  release(&ptable.lock);
80106628:	83 ec 0c             	sub    $0xc,%esp
8010662b:	68 80 49 11 80       	push   $0x80114980
80106630:	e8 a7 02 00 00       	call   801068dc <release>
80106635:	83 c4 10             	add    $0x10,%esp
  return -1;
80106638:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010663d:	c9                   	leave  
8010663e:	c3                   	ret    

8010663f <promoteAll>:

void
promoteAll(void)
{
8010663f:	55                   	push   %ebp
80106640:	89 e5                	mov    %esp,%ebp
80106642:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  for(int i = 0; i < MAXPRIO+1; ++i)
80106645:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010664c:	e9 0d 01 00 00       	jmp    8010675e <promoteAll+0x11f>
  {
    for(p = ptable.pLists.ready[i]; p; p=p->next)
80106651:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106654:	05 cc 09 00 00       	add    $0x9cc,%eax
80106659:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
80106660:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106663:	e9 e8 00 00 00       	jmp    80106750 <promoteAll+0x111>
    {
      if(i>0)
80106668:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010666c:	0f 8e b8 00 00 00    	jle    8010672a <promoteAll+0xeb>
      {
#ifdef CS333_P3P4
        if(stateListRemove(&ptable.pLists.ready[p->priority], &ptable.pLists.readyTail[p->priority], p))
80106672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106675:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
8010667b:	05 d0 09 00 00       	add    $0x9d0,%eax
80106680:	c1 e0 02             	shl    $0x2,%eax
80106683:	05 80 49 11 80       	add    $0x80114980,%eax
80106688:	8d 50 10             	lea    0x10(%eax),%edx
8010668b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010668e:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80106694:	05 cc 09 00 00       	add    $0x9cc,%eax
80106699:	c1 e0 02             	shl    $0x2,%eax
8010669c:	05 80 49 11 80       	add    $0x80114980,%eax
801066a1:	83 c0 04             	add    $0x4,%eax
801066a4:	ff 75 f4             	pushl  -0xc(%ebp)
801066a7:	52                   	push   %edx
801066a8:	50                   	push   %eax
801066a9:	e8 a9 f6 ff ff       	call   80105d57 <stateListRemove>
801066ae:	83 c4 0c             	add    $0xc,%esp
801066b1:	85 c0                	test   %eax,%eax
801066b3:	74 0d                	je     801066c2 <promoteAll+0x83>
          panic("Error removing process from current priority");
801066b5:	83 ec 0c             	sub    $0xc,%esp
801066b8:	68 84 a6 10 80       	push   $0x8010a684
801066bd:	e8 a4 9e ff ff       	call   80100566 <panic>
        p->priority -= 1;
801066c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066c5:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801066cb:	8d 50 ff             	lea    -0x1(%eax),%edx
801066ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066d1:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
        if(stateListAdd(&ptable.pLists.ready[p->priority], &ptable.pLists.readyTail[p->priority], p))
801066d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066da:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801066e0:	05 d0 09 00 00       	add    $0x9d0,%eax
801066e5:	c1 e0 02             	shl    $0x2,%eax
801066e8:	05 80 49 11 80       	add    $0x80114980,%eax
801066ed:	8d 50 10             	lea    0x10(%eax),%edx
801066f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066f3:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801066f9:	05 cc 09 00 00       	add    $0x9cc,%eax
801066fe:	c1 e0 02             	shl    $0x2,%eax
80106701:	05 80 49 11 80       	add    $0x80114980,%eax
80106706:	83 c0 04             	add    $0x4,%eax
80106709:	83 ec 04             	sub    $0x4,%esp
8010670c:	ff 75 f4             	pushl  -0xc(%ebp)
8010670f:	52                   	push   %edx
80106710:	50                   	push   %eax
80106711:	e8 e2 f5 ff ff       	call   80105cf8 <stateListAdd>
80106716:	83 c4 10             	add    $0x10,%esp
80106719:	85 c0                	test   %eax,%eax
8010671b:	74 0d                	je     8010672a <promoteAll+0xeb>
          panic("Error adding process to desired priority");
8010671d:	83 ec 0c             	sub    $0xc,%esp
80106720:	68 e0 a6 10 80       	push   $0x8010a6e0
80106725:	e8 3c 9e ff ff       	call   80100566 <panic>
#endif
      }
      p->budget = BUDGET*(p->priority+1);
8010672a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010672d:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80106733:	83 c0 01             	add    $0x1,%eax
80106736:	6b c0 64             	imul   $0x64,%eax,%eax
80106739:	89 c2                	mov    %eax,%edx
8010673b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010673e:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
promoteAll(void)
{
  struct proc *p;
  for(int i = 0; i < MAXPRIO+1; ++i)
  {
    for(p = ptable.pLists.ready[i]; p; p=p->next)
80106744:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106747:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010674d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106750:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106754:	0f 85 0e ff ff ff    	jne    80106668 <promoteAll+0x29>

void
promoteAll(void)
{
  struct proc *p;
  for(int i = 0; i < MAXPRIO+1; ++i)
8010675a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010675e:	83 7d f0 06          	cmpl   $0x6,-0x10(%ebp)
80106762:	0f 8e e9 fe ff ff    	jle    80106651 <promoteAll+0x12>
#endif
      }
      p->budget = BUDGET*(p->priority+1);
    }
  }
  for(p = ptable.pLists.sleep; p; p=p->next)
80106768:	a1 f4 70 11 80       	mov    0x801170f4,%eax
8010676d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106770:	eb 48                	jmp    801067ba <promoteAll+0x17b>
  {
    if(p->priority > 0)
80106772:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106775:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
8010677b:	85 c0                	test   %eax,%eax
8010677d:	74 15                	je     80106794 <promoteAll+0x155>
    {
      p->priority -= 1;
8010677f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106782:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80106788:	8d 50 ff             	lea    -0x1(%eax),%edx
8010678b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010678e:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
    }
    p->budget = BUDGET*(p->priority+1);
80106794:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106797:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
8010679d:	83 c0 01             	add    $0x1,%eax
801067a0:	6b c0 64             	imul   $0x64,%eax,%eax
801067a3:	89 c2                	mov    %eax,%edx
801067a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067a8:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
#endif
      }
      p->budget = BUDGET*(p->priority+1);
    }
  }
  for(p = ptable.pLists.sleep; p; p=p->next)
801067ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067b1:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801067b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067be:	75 b2                	jne    80106772 <promoteAll+0x133>
    {
      p->priority -= 1;
    }
    p->budget = BUDGET*(p->priority+1);
  }
  for(p = ptable.pLists.running; p; p=p->next)
801067c0:	a1 04 71 11 80       	mov    0x80117104,%eax
801067c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067c8:	eb 48                	jmp    80106812 <promoteAll+0x1d3>
  {
    if(p->priority > 0)
801067ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067cd:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801067d3:	85 c0                	test   %eax,%eax
801067d5:	74 15                	je     801067ec <promoteAll+0x1ad>
    {
      p->priority -= 1;
801067d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067da:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801067e0:	8d 50 ff             	lea    -0x1(%eax),%edx
801067e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067e6:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
    }
    p->budget = BUDGET*(p->priority+1);
801067ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067ef:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801067f5:	83 c0 01             	add    $0x1,%eax
801067f8:	6b c0 64             	imul   $0x64,%eax,%eax
801067fb:	89 c2                	mov    %eax,%edx
801067fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106800:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
    {
      p->priority -= 1;
    }
    p->budget = BUDGET*(p->priority+1);
  }
  for(p = ptable.pLists.running; p; p=p->next)
80106806:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106809:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010680f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106812:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106816:	75 b2                	jne    801067ca <promoteAll+0x18b>
    {
      p->priority -= 1;
    }
    p->budget = BUDGET*(p->priority+1);
  }
}
80106818:	90                   	nop
80106819:	c9                   	leave  
8010681a:	c3                   	ret    

8010681b <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010681b:	55                   	push   %ebp
8010681c:	89 e5                	mov    %esp,%ebp
8010681e:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80106821:	9c                   	pushf  
80106822:	58                   	pop    %eax
80106823:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80106826:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106829:	c9                   	leave  
8010682a:	c3                   	ret    

8010682b <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010682b:	55                   	push   %ebp
8010682c:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010682e:	fa                   	cli    
}
8010682f:	90                   	nop
80106830:	5d                   	pop    %ebp
80106831:	c3                   	ret    

80106832 <sti>:

static inline void
sti(void)
{
80106832:	55                   	push   %ebp
80106833:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80106835:	fb                   	sti    
}
80106836:	90                   	nop
80106837:	5d                   	pop    %ebp
80106838:	c3                   	ret    

80106839 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80106839:	55                   	push   %ebp
8010683a:	89 e5                	mov    %esp,%ebp
8010683c:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010683f:	8b 55 08             	mov    0x8(%ebp),%edx
80106842:	8b 45 0c             	mov    0xc(%ebp),%eax
80106845:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106848:	f0 87 02             	lock xchg %eax,(%edx)
8010684b:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010684e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106851:	c9                   	leave  
80106852:	c3                   	ret    

80106853 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80106853:	55                   	push   %ebp
80106854:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80106856:	8b 45 08             	mov    0x8(%ebp),%eax
80106859:	8b 55 0c             	mov    0xc(%ebp),%edx
8010685c:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010685f:	8b 45 08             	mov    0x8(%ebp),%eax
80106862:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80106868:	8b 45 08             	mov    0x8(%ebp),%eax
8010686b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80106872:	90                   	nop
80106873:	5d                   	pop    %ebp
80106874:	c3                   	ret    

80106875 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80106875:	55                   	push   %ebp
80106876:	89 e5                	mov    %esp,%ebp
80106878:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010687b:	e8 52 01 00 00       	call   801069d2 <pushcli>
  if(holding(lk))
80106880:	8b 45 08             	mov    0x8(%ebp),%eax
80106883:	83 ec 0c             	sub    $0xc,%esp
80106886:	50                   	push   %eax
80106887:	e8 1c 01 00 00       	call   801069a8 <holding>
8010688c:	83 c4 10             	add    $0x10,%esp
8010688f:	85 c0                	test   %eax,%eax
80106891:	74 0d                	je     801068a0 <acquire+0x2b>
    panic("acquire");
80106893:	83 ec 0c             	sub    $0xc,%esp
80106896:	68 09 a7 10 80       	push   $0x8010a709
8010689b:	e8 c6 9c ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
801068a0:	90                   	nop
801068a1:	8b 45 08             	mov    0x8(%ebp),%eax
801068a4:	83 ec 08             	sub    $0x8,%esp
801068a7:	6a 01                	push   $0x1
801068a9:	50                   	push   %eax
801068aa:	e8 8a ff ff ff       	call   80106839 <xchg>
801068af:	83 c4 10             	add    $0x10,%esp
801068b2:	85 c0                	test   %eax,%eax
801068b4:	75 eb                	jne    801068a1 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801068b6:	8b 45 08             	mov    0x8(%ebp),%eax
801068b9:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801068c0:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
801068c3:	8b 45 08             	mov    0x8(%ebp),%eax
801068c6:	83 c0 0c             	add    $0xc,%eax
801068c9:	83 ec 08             	sub    $0x8,%esp
801068cc:	50                   	push   %eax
801068cd:	8d 45 08             	lea    0x8(%ebp),%eax
801068d0:	50                   	push   %eax
801068d1:	e8 58 00 00 00       	call   8010692e <getcallerpcs>
801068d6:	83 c4 10             	add    $0x10,%esp
}
801068d9:	90                   	nop
801068da:	c9                   	leave  
801068db:	c3                   	ret    

801068dc <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801068dc:	55                   	push   %ebp
801068dd:	89 e5                	mov    %esp,%ebp
801068df:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801068e2:	83 ec 0c             	sub    $0xc,%esp
801068e5:	ff 75 08             	pushl  0x8(%ebp)
801068e8:	e8 bb 00 00 00       	call   801069a8 <holding>
801068ed:	83 c4 10             	add    $0x10,%esp
801068f0:	85 c0                	test   %eax,%eax
801068f2:	75 0d                	jne    80106901 <release+0x25>
    panic("release");
801068f4:	83 ec 0c             	sub    $0xc,%esp
801068f7:	68 11 a7 10 80       	push   $0x8010a711
801068fc:	e8 65 9c ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80106901:	8b 45 08             	mov    0x8(%ebp),%eax
80106904:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010690b:	8b 45 08             	mov    0x8(%ebp),%eax
8010690e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80106915:	8b 45 08             	mov    0x8(%ebp),%eax
80106918:	83 ec 08             	sub    $0x8,%esp
8010691b:	6a 00                	push   $0x0
8010691d:	50                   	push   %eax
8010691e:	e8 16 ff ff ff       	call   80106839 <xchg>
80106923:	83 c4 10             	add    $0x10,%esp

  popcli();
80106926:	e8 ec 00 00 00       	call   80106a17 <popcli>
}
8010692b:	90                   	nop
8010692c:	c9                   	leave  
8010692d:	c3                   	ret    

8010692e <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010692e:	55                   	push   %ebp
8010692f:	89 e5                	mov    %esp,%ebp
80106931:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80106934:	8b 45 08             	mov    0x8(%ebp),%eax
80106937:	83 e8 08             	sub    $0x8,%eax
8010693a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010693d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80106944:	eb 38                	jmp    8010697e <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80106946:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010694a:	74 53                	je     8010699f <getcallerpcs+0x71>
8010694c:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80106953:	76 4a                	jbe    8010699f <getcallerpcs+0x71>
80106955:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80106959:	74 44                	je     8010699f <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010695b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010695e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106965:	8b 45 0c             	mov    0xc(%ebp),%eax
80106968:	01 c2                	add    %eax,%edx
8010696a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010696d:	8b 40 04             	mov    0x4(%eax),%eax
80106970:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80106972:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106975:	8b 00                	mov    (%eax),%eax
80106977:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
8010697a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010697e:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80106982:	7e c2                	jle    80106946 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80106984:	eb 19                	jmp    8010699f <getcallerpcs+0x71>
    pcs[i] = 0;
80106986:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106989:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106990:	8b 45 0c             	mov    0xc(%ebp),%eax
80106993:	01 d0                	add    %edx,%eax
80106995:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010699b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010699f:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801069a3:	7e e1                	jle    80106986 <getcallerpcs+0x58>
    pcs[i] = 0;
}
801069a5:	90                   	nop
801069a6:	c9                   	leave  
801069a7:	c3                   	ret    

801069a8 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801069a8:	55                   	push   %ebp
801069a9:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
801069ab:	8b 45 08             	mov    0x8(%ebp),%eax
801069ae:	8b 00                	mov    (%eax),%eax
801069b0:	85 c0                	test   %eax,%eax
801069b2:	74 17                	je     801069cb <holding+0x23>
801069b4:	8b 45 08             	mov    0x8(%ebp),%eax
801069b7:	8b 50 08             	mov    0x8(%eax),%edx
801069ba:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801069c0:	39 c2                	cmp    %eax,%edx
801069c2:	75 07                	jne    801069cb <holding+0x23>
801069c4:	b8 01 00 00 00       	mov    $0x1,%eax
801069c9:	eb 05                	jmp    801069d0 <holding+0x28>
801069cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801069d0:	5d                   	pop    %ebp
801069d1:	c3                   	ret    

801069d2 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801069d2:	55                   	push   %ebp
801069d3:	89 e5                	mov    %esp,%ebp
801069d5:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
801069d8:	e8 3e fe ff ff       	call   8010681b <readeflags>
801069dd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
801069e0:	e8 46 fe ff ff       	call   8010682b <cli>
  if(cpu->ncli++ == 0)
801069e5:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801069ec:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
801069f2:	8d 48 01             	lea    0x1(%eax),%ecx
801069f5:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
801069fb:	85 c0                	test   %eax,%eax
801069fd:	75 15                	jne    80106a14 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
801069ff:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a05:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106a08:	81 e2 00 02 00 00    	and    $0x200,%edx
80106a0e:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80106a14:	90                   	nop
80106a15:	c9                   	leave  
80106a16:	c3                   	ret    

80106a17 <popcli>:

void
popcli(void)
{
80106a17:	55                   	push   %ebp
80106a18:	89 e5                	mov    %esp,%ebp
80106a1a:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80106a1d:	e8 f9 fd ff ff       	call   8010681b <readeflags>
80106a22:	25 00 02 00 00       	and    $0x200,%eax
80106a27:	85 c0                	test   %eax,%eax
80106a29:	74 0d                	je     80106a38 <popcli+0x21>
    panic("popcli - interruptible");
80106a2b:	83 ec 0c             	sub    $0xc,%esp
80106a2e:	68 19 a7 10 80       	push   $0x8010a719
80106a33:	e8 2e 9b ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80106a38:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a3e:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80106a44:	83 ea 01             	sub    $0x1,%edx
80106a47:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80106a4d:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80106a53:	85 c0                	test   %eax,%eax
80106a55:	79 0d                	jns    80106a64 <popcli+0x4d>
    panic("popcli");
80106a57:	83 ec 0c             	sub    $0xc,%esp
80106a5a:	68 30 a7 10 80       	push   $0x8010a730
80106a5f:	e8 02 9b ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80106a64:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a6a:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80106a70:	85 c0                	test   %eax,%eax
80106a72:	75 15                	jne    80106a89 <popcli+0x72>
80106a74:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a7a:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80106a80:	85 c0                	test   %eax,%eax
80106a82:	74 05                	je     80106a89 <popcli+0x72>
    sti();
80106a84:	e8 a9 fd ff ff       	call   80106832 <sti>
}
80106a89:	90                   	nop
80106a8a:	c9                   	leave  
80106a8b:	c3                   	ret    

80106a8c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80106a8c:	55                   	push   %ebp
80106a8d:	89 e5                	mov    %esp,%ebp
80106a8f:	57                   	push   %edi
80106a90:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80106a91:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106a94:	8b 55 10             	mov    0x10(%ebp),%edx
80106a97:	8b 45 0c             	mov    0xc(%ebp),%eax
80106a9a:	89 cb                	mov    %ecx,%ebx
80106a9c:	89 df                	mov    %ebx,%edi
80106a9e:	89 d1                	mov    %edx,%ecx
80106aa0:	fc                   	cld    
80106aa1:	f3 aa                	rep stos %al,%es:(%edi)
80106aa3:	89 ca                	mov    %ecx,%edx
80106aa5:	89 fb                	mov    %edi,%ebx
80106aa7:	89 5d 08             	mov    %ebx,0x8(%ebp)
80106aaa:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80106aad:	90                   	nop
80106aae:	5b                   	pop    %ebx
80106aaf:	5f                   	pop    %edi
80106ab0:	5d                   	pop    %ebp
80106ab1:	c3                   	ret    

80106ab2 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80106ab2:	55                   	push   %ebp
80106ab3:	89 e5                	mov    %esp,%ebp
80106ab5:	57                   	push   %edi
80106ab6:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80106ab7:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106aba:	8b 55 10             	mov    0x10(%ebp),%edx
80106abd:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ac0:	89 cb                	mov    %ecx,%ebx
80106ac2:	89 df                	mov    %ebx,%edi
80106ac4:	89 d1                	mov    %edx,%ecx
80106ac6:	fc                   	cld    
80106ac7:	f3 ab                	rep stos %eax,%es:(%edi)
80106ac9:	89 ca                	mov    %ecx,%edx
80106acb:	89 fb                	mov    %edi,%ebx
80106acd:	89 5d 08             	mov    %ebx,0x8(%ebp)
80106ad0:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80106ad3:	90                   	nop
80106ad4:	5b                   	pop    %ebx
80106ad5:	5f                   	pop    %edi
80106ad6:	5d                   	pop    %ebp
80106ad7:	c3                   	ret    

80106ad8 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80106ad8:	55                   	push   %ebp
80106ad9:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80106adb:	8b 45 08             	mov    0x8(%ebp),%eax
80106ade:	83 e0 03             	and    $0x3,%eax
80106ae1:	85 c0                	test   %eax,%eax
80106ae3:	75 43                	jne    80106b28 <memset+0x50>
80106ae5:	8b 45 10             	mov    0x10(%ebp),%eax
80106ae8:	83 e0 03             	and    $0x3,%eax
80106aeb:	85 c0                	test   %eax,%eax
80106aed:	75 39                	jne    80106b28 <memset+0x50>
    c &= 0xFF;
80106aef:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80106af6:	8b 45 10             	mov    0x10(%ebp),%eax
80106af9:	c1 e8 02             	shr    $0x2,%eax
80106afc:	89 c1                	mov    %eax,%ecx
80106afe:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b01:	c1 e0 18             	shl    $0x18,%eax
80106b04:	89 c2                	mov    %eax,%edx
80106b06:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b09:	c1 e0 10             	shl    $0x10,%eax
80106b0c:	09 c2                	or     %eax,%edx
80106b0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b11:	c1 e0 08             	shl    $0x8,%eax
80106b14:	09 d0                	or     %edx,%eax
80106b16:	0b 45 0c             	or     0xc(%ebp),%eax
80106b19:	51                   	push   %ecx
80106b1a:	50                   	push   %eax
80106b1b:	ff 75 08             	pushl  0x8(%ebp)
80106b1e:	e8 8f ff ff ff       	call   80106ab2 <stosl>
80106b23:	83 c4 0c             	add    $0xc,%esp
80106b26:	eb 12                	jmp    80106b3a <memset+0x62>
  } else
    stosb(dst, c, n);
80106b28:	8b 45 10             	mov    0x10(%ebp),%eax
80106b2b:	50                   	push   %eax
80106b2c:	ff 75 0c             	pushl  0xc(%ebp)
80106b2f:	ff 75 08             	pushl  0x8(%ebp)
80106b32:	e8 55 ff ff ff       	call   80106a8c <stosb>
80106b37:	83 c4 0c             	add    $0xc,%esp
  return dst;
80106b3a:	8b 45 08             	mov    0x8(%ebp),%eax
}
80106b3d:	c9                   	leave  
80106b3e:	c3                   	ret    

80106b3f <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80106b3f:	55                   	push   %ebp
80106b40:	89 e5                	mov    %esp,%ebp
80106b42:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80106b45:	8b 45 08             	mov    0x8(%ebp),%eax
80106b48:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80106b4b:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b4e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80106b51:	eb 30                	jmp    80106b83 <memcmp+0x44>
    if(*s1 != *s2)
80106b53:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106b56:	0f b6 10             	movzbl (%eax),%edx
80106b59:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106b5c:	0f b6 00             	movzbl (%eax),%eax
80106b5f:	38 c2                	cmp    %al,%dl
80106b61:	74 18                	je     80106b7b <memcmp+0x3c>
      return *s1 - *s2;
80106b63:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106b66:	0f b6 00             	movzbl (%eax),%eax
80106b69:	0f b6 d0             	movzbl %al,%edx
80106b6c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106b6f:	0f b6 00             	movzbl (%eax),%eax
80106b72:	0f b6 c0             	movzbl %al,%eax
80106b75:	29 c2                	sub    %eax,%edx
80106b77:	89 d0                	mov    %edx,%eax
80106b79:	eb 1a                	jmp    80106b95 <memcmp+0x56>
    s1++, s2++;
80106b7b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106b7f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80106b83:	8b 45 10             	mov    0x10(%ebp),%eax
80106b86:	8d 50 ff             	lea    -0x1(%eax),%edx
80106b89:	89 55 10             	mov    %edx,0x10(%ebp)
80106b8c:	85 c0                	test   %eax,%eax
80106b8e:	75 c3                	jne    80106b53 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80106b90:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106b95:	c9                   	leave  
80106b96:	c3                   	ret    

80106b97 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80106b97:	55                   	push   %ebp
80106b98:	89 e5                	mov    %esp,%ebp
80106b9a:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80106b9d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ba0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80106ba3:	8b 45 08             	mov    0x8(%ebp),%eax
80106ba6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80106ba9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106bac:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106baf:	73 54                	jae    80106c05 <memmove+0x6e>
80106bb1:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106bb4:	8b 45 10             	mov    0x10(%ebp),%eax
80106bb7:	01 d0                	add    %edx,%eax
80106bb9:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106bbc:	76 47                	jbe    80106c05 <memmove+0x6e>
    s += n;
80106bbe:	8b 45 10             	mov    0x10(%ebp),%eax
80106bc1:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80106bc4:	8b 45 10             	mov    0x10(%ebp),%eax
80106bc7:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80106bca:	eb 13                	jmp    80106bdf <memmove+0x48>
      *--d = *--s;
80106bcc:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80106bd0:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80106bd4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106bd7:	0f b6 10             	movzbl (%eax),%edx
80106bda:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106bdd:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80106bdf:	8b 45 10             	mov    0x10(%ebp),%eax
80106be2:	8d 50 ff             	lea    -0x1(%eax),%edx
80106be5:	89 55 10             	mov    %edx,0x10(%ebp)
80106be8:	85 c0                	test   %eax,%eax
80106bea:	75 e0                	jne    80106bcc <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80106bec:	eb 24                	jmp    80106c12 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80106bee:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106bf1:	8d 50 01             	lea    0x1(%eax),%edx
80106bf4:	89 55 f8             	mov    %edx,-0x8(%ebp)
80106bf7:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106bfa:	8d 4a 01             	lea    0x1(%edx),%ecx
80106bfd:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80106c00:	0f b6 12             	movzbl (%edx),%edx
80106c03:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80106c05:	8b 45 10             	mov    0x10(%ebp),%eax
80106c08:	8d 50 ff             	lea    -0x1(%eax),%edx
80106c0b:	89 55 10             	mov    %edx,0x10(%ebp)
80106c0e:	85 c0                	test   %eax,%eax
80106c10:	75 dc                	jne    80106bee <memmove+0x57>
      *d++ = *s++;

  return dst;
80106c12:	8b 45 08             	mov    0x8(%ebp),%eax
}
80106c15:	c9                   	leave  
80106c16:	c3                   	ret    

80106c17 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80106c17:	55                   	push   %ebp
80106c18:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80106c1a:	ff 75 10             	pushl  0x10(%ebp)
80106c1d:	ff 75 0c             	pushl  0xc(%ebp)
80106c20:	ff 75 08             	pushl  0x8(%ebp)
80106c23:	e8 6f ff ff ff       	call   80106b97 <memmove>
80106c28:	83 c4 0c             	add    $0xc,%esp
}
80106c2b:	c9                   	leave  
80106c2c:	c3                   	ret    

80106c2d <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80106c2d:	55                   	push   %ebp
80106c2e:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80106c30:	eb 0c                	jmp    80106c3e <strncmp+0x11>
    n--, p++, q++;
80106c32:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106c36:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80106c3a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80106c3e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106c42:	74 1a                	je     80106c5e <strncmp+0x31>
80106c44:	8b 45 08             	mov    0x8(%ebp),%eax
80106c47:	0f b6 00             	movzbl (%eax),%eax
80106c4a:	84 c0                	test   %al,%al
80106c4c:	74 10                	je     80106c5e <strncmp+0x31>
80106c4e:	8b 45 08             	mov    0x8(%ebp),%eax
80106c51:	0f b6 10             	movzbl (%eax),%edx
80106c54:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c57:	0f b6 00             	movzbl (%eax),%eax
80106c5a:	38 c2                	cmp    %al,%dl
80106c5c:	74 d4                	je     80106c32 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80106c5e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106c62:	75 07                	jne    80106c6b <strncmp+0x3e>
    return 0;
80106c64:	b8 00 00 00 00       	mov    $0x0,%eax
80106c69:	eb 16                	jmp    80106c81 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80106c6b:	8b 45 08             	mov    0x8(%ebp),%eax
80106c6e:	0f b6 00             	movzbl (%eax),%eax
80106c71:	0f b6 d0             	movzbl %al,%edx
80106c74:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c77:	0f b6 00             	movzbl (%eax),%eax
80106c7a:	0f b6 c0             	movzbl %al,%eax
80106c7d:	29 c2                	sub    %eax,%edx
80106c7f:	89 d0                	mov    %edx,%eax
}
80106c81:	5d                   	pop    %ebp
80106c82:	c3                   	ret    

80106c83 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80106c83:	55                   	push   %ebp
80106c84:	89 e5                	mov    %esp,%ebp
80106c86:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80106c89:	8b 45 08             	mov    0x8(%ebp),%eax
80106c8c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80106c8f:	90                   	nop
80106c90:	8b 45 10             	mov    0x10(%ebp),%eax
80106c93:	8d 50 ff             	lea    -0x1(%eax),%edx
80106c96:	89 55 10             	mov    %edx,0x10(%ebp)
80106c99:	85 c0                	test   %eax,%eax
80106c9b:	7e 2c                	jle    80106cc9 <strncpy+0x46>
80106c9d:	8b 45 08             	mov    0x8(%ebp),%eax
80106ca0:	8d 50 01             	lea    0x1(%eax),%edx
80106ca3:	89 55 08             	mov    %edx,0x8(%ebp)
80106ca6:	8b 55 0c             	mov    0xc(%ebp),%edx
80106ca9:	8d 4a 01             	lea    0x1(%edx),%ecx
80106cac:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80106caf:	0f b6 12             	movzbl (%edx),%edx
80106cb2:	88 10                	mov    %dl,(%eax)
80106cb4:	0f b6 00             	movzbl (%eax),%eax
80106cb7:	84 c0                	test   %al,%al
80106cb9:	75 d5                	jne    80106c90 <strncpy+0xd>
    ;
  while(n-- > 0)
80106cbb:	eb 0c                	jmp    80106cc9 <strncpy+0x46>
    *s++ = 0;
80106cbd:	8b 45 08             	mov    0x8(%ebp),%eax
80106cc0:	8d 50 01             	lea    0x1(%eax),%edx
80106cc3:	89 55 08             	mov    %edx,0x8(%ebp)
80106cc6:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80106cc9:	8b 45 10             	mov    0x10(%ebp),%eax
80106ccc:	8d 50 ff             	lea    -0x1(%eax),%edx
80106ccf:	89 55 10             	mov    %edx,0x10(%ebp)
80106cd2:	85 c0                	test   %eax,%eax
80106cd4:	7f e7                	jg     80106cbd <strncpy+0x3a>
    *s++ = 0;
  return os;
80106cd6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106cd9:	c9                   	leave  
80106cda:	c3                   	ret    

80106cdb <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80106cdb:	55                   	push   %ebp
80106cdc:	89 e5                	mov    %esp,%ebp
80106cde:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80106ce1:	8b 45 08             	mov    0x8(%ebp),%eax
80106ce4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80106ce7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106ceb:	7f 05                	jg     80106cf2 <safestrcpy+0x17>
    return os;
80106ced:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106cf0:	eb 31                	jmp    80106d23 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80106cf2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106cf6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106cfa:	7e 1e                	jle    80106d1a <safestrcpy+0x3f>
80106cfc:	8b 45 08             	mov    0x8(%ebp),%eax
80106cff:	8d 50 01             	lea    0x1(%eax),%edx
80106d02:	89 55 08             	mov    %edx,0x8(%ebp)
80106d05:	8b 55 0c             	mov    0xc(%ebp),%edx
80106d08:	8d 4a 01             	lea    0x1(%edx),%ecx
80106d0b:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80106d0e:	0f b6 12             	movzbl (%edx),%edx
80106d11:	88 10                	mov    %dl,(%eax)
80106d13:	0f b6 00             	movzbl (%eax),%eax
80106d16:	84 c0                	test   %al,%al
80106d18:	75 d8                	jne    80106cf2 <safestrcpy+0x17>
    ;
  *s = 0;
80106d1a:	8b 45 08             	mov    0x8(%ebp),%eax
80106d1d:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80106d20:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106d23:	c9                   	leave  
80106d24:	c3                   	ret    

80106d25 <strlen>:

int
strlen(const char *s)
{
80106d25:	55                   	push   %ebp
80106d26:	89 e5                	mov    %esp,%ebp
80106d28:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80106d2b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106d32:	eb 04                	jmp    80106d38 <strlen+0x13>
80106d34:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106d38:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106d3b:	8b 45 08             	mov    0x8(%ebp),%eax
80106d3e:	01 d0                	add    %edx,%eax
80106d40:	0f b6 00             	movzbl (%eax),%eax
80106d43:	84 c0                	test   %al,%al
80106d45:	75 ed                	jne    80106d34 <strlen+0xf>
    ;
  return n;
80106d47:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106d4a:	c9                   	leave  
80106d4b:	c3                   	ret    

80106d4c <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80106d4c:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80106d50:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80106d54:	55                   	push   %ebp
  pushl %ebx
80106d55:	53                   	push   %ebx
  pushl %esi
80106d56:	56                   	push   %esi
  pushl %edi
80106d57:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80106d58:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80106d5a:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80106d5c:	5f                   	pop    %edi
  popl %esi
80106d5d:	5e                   	pop    %esi
  popl %ebx
80106d5e:	5b                   	pop    %ebx
  popl %ebp
80106d5f:	5d                   	pop    %ebp
  ret
80106d60:	c3                   	ret    

80106d61 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80106d61:	55                   	push   %ebp
80106d62:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80106d64:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d6a:	8b 00                	mov    (%eax),%eax
80106d6c:	3b 45 08             	cmp    0x8(%ebp),%eax
80106d6f:	76 12                	jbe    80106d83 <fetchint+0x22>
80106d71:	8b 45 08             	mov    0x8(%ebp),%eax
80106d74:	8d 50 04             	lea    0x4(%eax),%edx
80106d77:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d7d:	8b 00                	mov    (%eax),%eax
80106d7f:	39 c2                	cmp    %eax,%edx
80106d81:	76 07                	jbe    80106d8a <fetchint+0x29>
    return -1;
80106d83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d88:	eb 0f                	jmp    80106d99 <fetchint+0x38>
  *ip = *(int*)(addr);
80106d8a:	8b 45 08             	mov    0x8(%ebp),%eax
80106d8d:	8b 10                	mov    (%eax),%edx
80106d8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d92:	89 10                	mov    %edx,(%eax)
  return 0;
80106d94:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106d99:	5d                   	pop    %ebp
80106d9a:	c3                   	ret    

80106d9b <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80106d9b:	55                   	push   %ebp
80106d9c:	89 e5                	mov    %esp,%ebp
80106d9e:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80106da1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106da7:	8b 00                	mov    (%eax),%eax
80106da9:	3b 45 08             	cmp    0x8(%ebp),%eax
80106dac:	77 07                	ja     80106db5 <fetchstr+0x1a>
    return -1;
80106dae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106db3:	eb 46                	jmp    80106dfb <fetchstr+0x60>
  *pp = (char*)addr;
80106db5:	8b 55 08             	mov    0x8(%ebp),%edx
80106db8:	8b 45 0c             	mov    0xc(%ebp),%eax
80106dbb:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80106dbd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106dc3:	8b 00                	mov    (%eax),%eax
80106dc5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80106dc8:	8b 45 0c             	mov    0xc(%ebp),%eax
80106dcb:	8b 00                	mov    (%eax),%eax
80106dcd:	89 45 fc             	mov    %eax,-0x4(%ebp)
80106dd0:	eb 1c                	jmp    80106dee <fetchstr+0x53>
    if(*s == 0)
80106dd2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106dd5:	0f b6 00             	movzbl (%eax),%eax
80106dd8:	84 c0                	test   %al,%al
80106dda:	75 0e                	jne    80106dea <fetchstr+0x4f>
      return s - *pp;
80106ddc:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106ddf:	8b 45 0c             	mov    0xc(%ebp),%eax
80106de2:	8b 00                	mov    (%eax),%eax
80106de4:	29 c2                	sub    %eax,%edx
80106de6:	89 d0                	mov    %edx,%eax
80106de8:	eb 11                	jmp    80106dfb <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80106dea:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106dee:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106df1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106df4:	72 dc                	jb     80106dd2 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80106df6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106dfb:	c9                   	leave  
80106dfc:	c3                   	ret    

80106dfd <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80106dfd:	55                   	push   %ebp
80106dfe:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80106e00:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e06:	8b 40 18             	mov    0x18(%eax),%eax
80106e09:	8b 40 44             	mov    0x44(%eax),%eax
80106e0c:	8b 55 08             	mov    0x8(%ebp),%edx
80106e0f:	c1 e2 02             	shl    $0x2,%edx
80106e12:	01 d0                	add    %edx,%eax
80106e14:	83 c0 04             	add    $0x4,%eax
80106e17:	ff 75 0c             	pushl  0xc(%ebp)
80106e1a:	50                   	push   %eax
80106e1b:	e8 41 ff ff ff       	call   80106d61 <fetchint>
80106e20:	83 c4 08             	add    $0x8,%esp
}
80106e23:	c9                   	leave  
80106e24:	c3                   	ret    

80106e25 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80106e25:	55                   	push   %ebp
80106e26:	89 e5                	mov    %esp,%ebp
80106e28:	83 ec 10             	sub    $0x10,%esp
  int i;

  if(argint(n, &i) < 0)
80106e2b:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106e2e:	50                   	push   %eax
80106e2f:	ff 75 08             	pushl  0x8(%ebp)
80106e32:	e8 c6 ff ff ff       	call   80106dfd <argint>
80106e37:	83 c4 08             	add    $0x8,%esp
80106e3a:	85 c0                	test   %eax,%eax
80106e3c:	79 07                	jns    80106e45 <argptr+0x20>
    return -1;
80106e3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e43:	eb 3b                	jmp    80106e80 <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80106e45:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e4b:	8b 00                	mov    (%eax),%eax
80106e4d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106e50:	39 d0                	cmp    %edx,%eax
80106e52:	76 16                	jbe    80106e6a <argptr+0x45>
80106e54:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106e57:	89 c2                	mov    %eax,%edx
80106e59:	8b 45 10             	mov    0x10(%ebp),%eax
80106e5c:	01 c2                	add    %eax,%edx
80106e5e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e64:	8b 00                	mov    (%eax),%eax
80106e66:	39 c2                	cmp    %eax,%edx
80106e68:	76 07                	jbe    80106e71 <argptr+0x4c>
    return -1;
80106e6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e6f:	eb 0f                	jmp    80106e80 <argptr+0x5b>
  *pp = (char*)i;
80106e71:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106e74:	89 c2                	mov    %eax,%edx
80106e76:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e79:	89 10                	mov    %edx,(%eax)
  return 0;
80106e7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106e80:	c9                   	leave  
80106e81:	c3                   	ret    

80106e82 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80106e82:	55                   	push   %ebp
80106e83:	89 e5                	mov    %esp,%ebp
80106e85:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80106e88:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106e8b:	50                   	push   %eax
80106e8c:	ff 75 08             	pushl  0x8(%ebp)
80106e8f:	e8 69 ff ff ff       	call   80106dfd <argint>
80106e94:	83 c4 08             	add    $0x8,%esp
80106e97:	85 c0                	test   %eax,%eax
80106e99:	79 07                	jns    80106ea2 <argstr+0x20>
    return -1;
80106e9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ea0:	eb 0f                	jmp    80106eb1 <argstr+0x2f>
  return fetchstr(addr, pp);
80106ea2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106ea5:	ff 75 0c             	pushl  0xc(%ebp)
80106ea8:	50                   	push   %eax
80106ea9:	e8 ed fe ff ff       	call   80106d9b <fetchstr>
80106eae:	83 c4 08             	add    $0x8,%esp
}
80106eb1:	c9                   	leave  
80106eb2:	c3                   	ret    

80106eb3 <syscall>:
};
#endif

void
syscall(void)
{
80106eb3:	55                   	push   %ebp
80106eb4:	89 e5                	mov    %esp,%ebp
80106eb6:	53                   	push   %ebx
80106eb7:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
80106eba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ec0:	8b 40 18             	mov    0x18(%eax),%eax
80106ec3:	8b 40 1c             	mov    0x1c(%eax),%eax
80106ec6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80106ec9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106ecd:	7e 30                	jle    80106eff <syscall+0x4c>
80106ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ed2:	83 f8 1c             	cmp    $0x1c,%eax
80106ed5:	77 28                	ja     80106eff <syscall+0x4c>
80106ed7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106eda:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
80106ee1:	85 c0                	test   %eax,%eax
80106ee3:	74 1a                	je     80106eff <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80106ee5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106eeb:	8b 58 18             	mov    0x18(%eax),%ebx
80106eee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ef1:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
80106ef8:	ff d0                	call   *%eax
80106efa:	89 43 1c             	mov    %eax,0x1c(%ebx)
80106efd:	eb 34                	jmp    80106f33 <syscall+0x80>
#ifdef PRINT_SYSCALLS
    cprintf("%s -> %d\n",syscallnames[num],proc->tf->eax);
#endif
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80106eff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f05:	8d 50 6c             	lea    0x6c(%eax),%edx
80106f08:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
// some code goes here
#ifdef PRINT_SYSCALLS
    cprintf("%s -> %d\n",syscallnames[num],proc->tf->eax);
#endif
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80106f0e:	8b 40 10             	mov    0x10(%eax),%eax
80106f11:	ff 75 f4             	pushl  -0xc(%ebp)
80106f14:	52                   	push   %edx
80106f15:	50                   	push   %eax
80106f16:	68 37 a7 10 80       	push   $0x8010a737
80106f1b:	e8 a6 94 ff ff       	call   801003c6 <cprintf>
80106f20:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80106f23:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f29:	8b 40 18             	mov    0x18(%eax),%eax
80106f2c:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80106f33:	90                   	nop
80106f34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106f37:	c9                   	leave  
80106f38:	c3                   	ret    

80106f39 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80106f39:	55                   	push   %ebp
80106f3a:	89 e5                	mov    %esp,%ebp
80106f3c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80106f3f:	83 ec 08             	sub    $0x8,%esp
80106f42:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106f45:	50                   	push   %eax
80106f46:	ff 75 08             	pushl  0x8(%ebp)
80106f49:	e8 af fe ff ff       	call   80106dfd <argint>
80106f4e:	83 c4 10             	add    $0x10,%esp
80106f51:	85 c0                	test   %eax,%eax
80106f53:	79 07                	jns    80106f5c <argfd+0x23>
    return -1;
80106f55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f5a:	eb 50                	jmp    80106fac <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80106f5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f5f:	85 c0                	test   %eax,%eax
80106f61:	78 21                	js     80106f84 <argfd+0x4b>
80106f63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f66:	83 f8 0f             	cmp    $0xf,%eax
80106f69:	7f 19                	jg     80106f84 <argfd+0x4b>
80106f6b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f71:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106f74:	83 c2 08             	add    $0x8,%edx
80106f77:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106f7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106f7e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106f82:	75 07                	jne    80106f8b <argfd+0x52>
    return -1;
80106f84:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f89:	eb 21                	jmp    80106fac <argfd+0x73>
  if(pfd)
80106f8b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106f8f:	74 08                	je     80106f99 <argfd+0x60>
    *pfd = fd;
80106f91:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106f94:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f97:	89 10                	mov    %edx,(%eax)
  if(pf)
80106f99:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106f9d:	74 08                	je     80106fa7 <argfd+0x6e>
    *pf = f;
80106f9f:	8b 45 10             	mov    0x10(%ebp),%eax
80106fa2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106fa5:	89 10                	mov    %edx,(%eax)
  return 0;
80106fa7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106fac:	c9                   	leave  
80106fad:	c3                   	ret    

80106fae <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80106fae:	55                   	push   %ebp
80106faf:	89 e5                	mov    %esp,%ebp
80106fb1:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80106fb4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106fbb:	eb 30                	jmp    80106fed <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80106fbd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fc3:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106fc6:	83 c2 08             	add    $0x8,%edx
80106fc9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106fcd:	85 c0                	test   %eax,%eax
80106fcf:	75 18                	jne    80106fe9 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80106fd1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fd7:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106fda:	8d 4a 08             	lea    0x8(%edx),%ecx
80106fdd:	8b 55 08             	mov    0x8(%ebp),%edx
80106fe0:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80106fe4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106fe7:	eb 0f                	jmp    80106ff8 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80106fe9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106fed:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80106ff1:	7e ca                	jle    80106fbd <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80106ff3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106ff8:	c9                   	leave  
80106ff9:	c3                   	ret    

80106ffa <sys_dup>:

int
sys_dup(void)
{
80106ffa:	55                   	push   %ebp
80106ffb:	89 e5                	mov    %esp,%ebp
80106ffd:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80107000:	83 ec 04             	sub    $0x4,%esp
80107003:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107006:	50                   	push   %eax
80107007:	6a 00                	push   $0x0
80107009:	6a 00                	push   $0x0
8010700b:	e8 29 ff ff ff       	call   80106f39 <argfd>
80107010:	83 c4 10             	add    $0x10,%esp
80107013:	85 c0                	test   %eax,%eax
80107015:	79 07                	jns    8010701e <sys_dup+0x24>
    return -1;
80107017:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010701c:	eb 31                	jmp    8010704f <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010701e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107021:	83 ec 0c             	sub    $0xc,%esp
80107024:	50                   	push   %eax
80107025:	e8 84 ff ff ff       	call   80106fae <fdalloc>
8010702a:	83 c4 10             	add    $0x10,%esp
8010702d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107030:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107034:	79 07                	jns    8010703d <sys_dup+0x43>
    return -1;
80107036:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010703b:	eb 12                	jmp    8010704f <sys_dup+0x55>
  filedup(f);
8010703d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107040:	83 ec 0c             	sub    $0xc,%esp
80107043:	50                   	push   %eax
80107044:	e8 55 a0 ff ff       	call   8010109e <filedup>
80107049:	83 c4 10             	add    $0x10,%esp
  return fd;
8010704c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010704f:	c9                   	leave  
80107050:	c3                   	ret    

80107051 <sys_read>:

int
sys_read(void)
{
80107051:	55                   	push   %ebp
80107052:	89 e5                	mov    %esp,%ebp
80107054:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80107057:	83 ec 04             	sub    $0x4,%esp
8010705a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010705d:	50                   	push   %eax
8010705e:	6a 00                	push   $0x0
80107060:	6a 00                	push   $0x0
80107062:	e8 d2 fe ff ff       	call   80106f39 <argfd>
80107067:	83 c4 10             	add    $0x10,%esp
8010706a:	85 c0                	test   %eax,%eax
8010706c:	78 2e                	js     8010709c <sys_read+0x4b>
8010706e:	83 ec 08             	sub    $0x8,%esp
80107071:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107074:	50                   	push   %eax
80107075:	6a 02                	push   $0x2
80107077:	e8 81 fd ff ff       	call   80106dfd <argint>
8010707c:	83 c4 10             	add    $0x10,%esp
8010707f:	85 c0                	test   %eax,%eax
80107081:	78 19                	js     8010709c <sys_read+0x4b>
80107083:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107086:	83 ec 04             	sub    $0x4,%esp
80107089:	50                   	push   %eax
8010708a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010708d:	50                   	push   %eax
8010708e:	6a 01                	push   $0x1
80107090:	e8 90 fd ff ff       	call   80106e25 <argptr>
80107095:	83 c4 10             	add    $0x10,%esp
80107098:	85 c0                	test   %eax,%eax
8010709a:	79 07                	jns    801070a3 <sys_read+0x52>
    return -1;
8010709c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070a1:	eb 17                	jmp    801070ba <sys_read+0x69>
  return fileread(f, p, n);
801070a3:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801070a6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801070a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070ac:	83 ec 04             	sub    $0x4,%esp
801070af:	51                   	push   %ecx
801070b0:	52                   	push   %edx
801070b1:	50                   	push   %eax
801070b2:	e8 77 a1 ff ff       	call   8010122e <fileread>
801070b7:	83 c4 10             	add    $0x10,%esp
}
801070ba:	c9                   	leave  
801070bb:	c3                   	ret    

801070bc <sys_write>:

int
sys_write(void)
{
801070bc:	55                   	push   %ebp
801070bd:	89 e5                	mov    %esp,%ebp
801070bf:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801070c2:	83 ec 04             	sub    $0x4,%esp
801070c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801070c8:	50                   	push   %eax
801070c9:	6a 00                	push   $0x0
801070cb:	6a 00                	push   $0x0
801070cd:	e8 67 fe ff ff       	call   80106f39 <argfd>
801070d2:	83 c4 10             	add    $0x10,%esp
801070d5:	85 c0                	test   %eax,%eax
801070d7:	78 2e                	js     80107107 <sys_write+0x4b>
801070d9:	83 ec 08             	sub    $0x8,%esp
801070dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801070df:	50                   	push   %eax
801070e0:	6a 02                	push   $0x2
801070e2:	e8 16 fd ff ff       	call   80106dfd <argint>
801070e7:	83 c4 10             	add    $0x10,%esp
801070ea:	85 c0                	test   %eax,%eax
801070ec:	78 19                	js     80107107 <sys_write+0x4b>
801070ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070f1:	83 ec 04             	sub    $0x4,%esp
801070f4:	50                   	push   %eax
801070f5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801070f8:	50                   	push   %eax
801070f9:	6a 01                	push   $0x1
801070fb:	e8 25 fd ff ff       	call   80106e25 <argptr>
80107100:	83 c4 10             	add    $0x10,%esp
80107103:	85 c0                	test   %eax,%eax
80107105:	79 07                	jns    8010710e <sys_write+0x52>
    return -1;
80107107:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010710c:	eb 17                	jmp    80107125 <sys_write+0x69>
  return filewrite(f, p, n);
8010710e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80107111:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107117:	83 ec 04             	sub    $0x4,%esp
8010711a:	51                   	push   %ecx
8010711b:	52                   	push   %edx
8010711c:	50                   	push   %eax
8010711d:	e8 c4 a1 ff ff       	call   801012e6 <filewrite>
80107122:	83 c4 10             	add    $0x10,%esp
}
80107125:	c9                   	leave  
80107126:	c3                   	ret    

80107127 <sys_close>:

int
sys_close(void)
{
80107127:	55                   	push   %ebp
80107128:	89 e5                	mov    %esp,%ebp
8010712a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
8010712d:	83 ec 04             	sub    $0x4,%esp
80107130:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107133:	50                   	push   %eax
80107134:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107137:	50                   	push   %eax
80107138:	6a 00                	push   $0x0
8010713a:	e8 fa fd ff ff       	call   80106f39 <argfd>
8010713f:	83 c4 10             	add    $0x10,%esp
80107142:	85 c0                	test   %eax,%eax
80107144:	79 07                	jns    8010714d <sys_close+0x26>
    return -1;
80107146:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010714b:	eb 28                	jmp    80107175 <sys_close+0x4e>
  proc->ofile[fd] = 0;
8010714d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107153:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107156:	83 c2 08             	add    $0x8,%edx
80107159:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80107160:	00 
  fileclose(f);
80107161:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107164:	83 ec 0c             	sub    $0xc,%esp
80107167:	50                   	push   %eax
80107168:	e8 82 9f ff ff       	call   801010ef <fileclose>
8010716d:	83 c4 10             	add    $0x10,%esp
  return 0;
80107170:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107175:	c9                   	leave  
80107176:	c3                   	ret    

80107177 <sys_fstat>:

int
sys_fstat(void)
{
80107177:	55                   	push   %ebp
80107178:	89 e5                	mov    %esp,%ebp
8010717a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010717d:	83 ec 04             	sub    $0x4,%esp
80107180:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107183:	50                   	push   %eax
80107184:	6a 00                	push   $0x0
80107186:	6a 00                	push   $0x0
80107188:	e8 ac fd ff ff       	call   80106f39 <argfd>
8010718d:	83 c4 10             	add    $0x10,%esp
80107190:	85 c0                	test   %eax,%eax
80107192:	78 17                	js     801071ab <sys_fstat+0x34>
80107194:	83 ec 04             	sub    $0x4,%esp
80107197:	6a 14                	push   $0x14
80107199:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010719c:	50                   	push   %eax
8010719d:	6a 01                	push   $0x1
8010719f:	e8 81 fc ff ff       	call   80106e25 <argptr>
801071a4:	83 c4 10             	add    $0x10,%esp
801071a7:	85 c0                	test   %eax,%eax
801071a9:	79 07                	jns    801071b2 <sys_fstat+0x3b>
    return -1;
801071ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071b0:	eb 13                	jmp    801071c5 <sys_fstat+0x4e>
  return filestat(f, st);
801071b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801071b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071b8:	83 ec 08             	sub    $0x8,%esp
801071bb:	52                   	push   %edx
801071bc:	50                   	push   %eax
801071bd:	e8 15 a0 ff ff       	call   801011d7 <filestat>
801071c2:	83 c4 10             	add    $0x10,%esp
}
801071c5:	c9                   	leave  
801071c6:	c3                   	ret    

801071c7 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801071c7:	55                   	push   %ebp
801071c8:	89 e5                	mov    %esp,%ebp
801071ca:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801071cd:	83 ec 08             	sub    $0x8,%esp
801071d0:	8d 45 d8             	lea    -0x28(%ebp),%eax
801071d3:	50                   	push   %eax
801071d4:	6a 00                	push   $0x0
801071d6:	e8 a7 fc ff ff       	call   80106e82 <argstr>
801071db:	83 c4 10             	add    $0x10,%esp
801071de:	85 c0                	test   %eax,%eax
801071e0:	78 15                	js     801071f7 <sys_link+0x30>
801071e2:	83 ec 08             	sub    $0x8,%esp
801071e5:	8d 45 dc             	lea    -0x24(%ebp),%eax
801071e8:	50                   	push   %eax
801071e9:	6a 01                	push   $0x1
801071eb:	e8 92 fc ff ff       	call   80106e82 <argstr>
801071f0:	83 c4 10             	add    $0x10,%esp
801071f3:	85 c0                	test   %eax,%eax
801071f5:	79 0a                	jns    80107201 <sys_link+0x3a>
    return -1;
801071f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071fc:	e9 68 01 00 00       	jmp    80107369 <sys_link+0x1a2>

  begin_op();
80107201:	e8 e5 c3 ff ff       	call   801035eb <begin_op>
  if((ip = namei(old)) == 0){
80107206:	8b 45 d8             	mov    -0x28(%ebp),%eax
80107209:	83 ec 0c             	sub    $0xc,%esp
8010720c:	50                   	push   %eax
8010720d:	e8 b4 b3 ff ff       	call   801025c6 <namei>
80107212:	83 c4 10             	add    $0x10,%esp
80107215:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107218:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010721c:	75 0f                	jne    8010722d <sys_link+0x66>
    end_op();
8010721e:	e8 54 c4 ff ff       	call   80103677 <end_op>
    return -1;
80107223:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107228:	e9 3c 01 00 00       	jmp    80107369 <sys_link+0x1a2>
  }

  ilock(ip);
8010722d:	83 ec 0c             	sub    $0xc,%esp
80107230:	ff 75 f4             	pushl  -0xc(%ebp)
80107233:	e8 d0 a7 ff ff       	call   80101a08 <ilock>
80107238:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010723b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010723e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107242:	66 83 f8 01          	cmp    $0x1,%ax
80107246:	75 1d                	jne    80107265 <sys_link+0x9e>
    iunlockput(ip);
80107248:	83 ec 0c             	sub    $0xc,%esp
8010724b:	ff 75 f4             	pushl  -0xc(%ebp)
8010724e:	e8 75 aa ff ff       	call   80101cc8 <iunlockput>
80107253:	83 c4 10             	add    $0x10,%esp
    end_op();
80107256:	e8 1c c4 ff ff       	call   80103677 <end_op>
    return -1;
8010725b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107260:	e9 04 01 00 00       	jmp    80107369 <sys_link+0x1a2>
  }

  ip->nlink++;
80107265:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107268:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010726c:	83 c0 01             	add    $0x1,%eax
8010726f:	89 c2                	mov    %eax,%edx
80107271:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107274:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80107278:	83 ec 0c             	sub    $0xc,%esp
8010727b:	ff 75 f4             	pushl  -0xc(%ebp)
8010727e:	e8 ab a5 ff ff       	call   8010182e <iupdate>
80107283:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80107286:	83 ec 0c             	sub    $0xc,%esp
80107289:	ff 75 f4             	pushl  -0xc(%ebp)
8010728c:	e8 d5 a8 ff ff       	call   80101b66 <iunlock>
80107291:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80107294:	8b 45 dc             	mov    -0x24(%ebp),%eax
80107297:	83 ec 08             	sub    $0x8,%esp
8010729a:	8d 55 e2             	lea    -0x1e(%ebp),%edx
8010729d:	52                   	push   %edx
8010729e:	50                   	push   %eax
8010729f:	e8 3e b3 ff ff       	call   801025e2 <nameiparent>
801072a4:	83 c4 10             	add    $0x10,%esp
801072a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801072aa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801072ae:	74 71                	je     80107321 <sys_link+0x15a>
    goto bad;
  ilock(dp);
801072b0:	83 ec 0c             	sub    $0xc,%esp
801072b3:	ff 75 f0             	pushl  -0x10(%ebp)
801072b6:	e8 4d a7 ff ff       	call   80101a08 <ilock>
801072bb:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801072be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801072c1:	8b 10                	mov    (%eax),%edx
801072c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072c6:	8b 00                	mov    (%eax),%eax
801072c8:	39 c2                	cmp    %eax,%edx
801072ca:	75 1d                	jne    801072e9 <sys_link+0x122>
801072cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072cf:	8b 40 04             	mov    0x4(%eax),%eax
801072d2:	83 ec 04             	sub    $0x4,%esp
801072d5:	50                   	push   %eax
801072d6:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801072d9:	50                   	push   %eax
801072da:	ff 75 f0             	pushl  -0x10(%ebp)
801072dd:	e8 48 b0 ff ff       	call   8010232a <dirlink>
801072e2:	83 c4 10             	add    $0x10,%esp
801072e5:	85 c0                	test   %eax,%eax
801072e7:	79 10                	jns    801072f9 <sys_link+0x132>
    iunlockput(dp);
801072e9:	83 ec 0c             	sub    $0xc,%esp
801072ec:	ff 75 f0             	pushl  -0x10(%ebp)
801072ef:	e8 d4 a9 ff ff       	call   80101cc8 <iunlockput>
801072f4:	83 c4 10             	add    $0x10,%esp
    goto bad;
801072f7:	eb 29                	jmp    80107322 <sys_link+0x15b>
  }
  iunlockput(dp);
801072f9:	83 ec 0c             	sub    $0xc,%esp
801072fc:	ff 75 f0             	pushl  -0x10(%ebp)
801072ff:	e8 c4 a9 ff ff       	call   80101cc8 <iunlockput>
80107304:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80107307:	83 ec 0c             	sub    $0xc,%esp
8010730a:	ff 75 f4             	pushl  -0xc(%ebp)
8010730d:	e8 c6 a8 ff ff       	call   80101bd8 <iput>
80107312:	83 c4 10             	add    $0x10,%esp

  end_op();
80107315:	e8 5d c3 ff ff       	call   80103677 <end_op>

  return 0;
8010731a:	b8 00 00 00 00       	mov    $0x0,%eax
8010731f:	eb 48                	jmp    80107369 <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80107321:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80107322:	83 ec 0c             	sub    $0xc,%esp
80107325:	ff 75 f4             	pushl  -0xc(%ebp)
80107328:	e8 db a6 ff ff       	call   80101a08 <ilock>
8010732d:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80107330:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107333:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80107337:	83 e8 01             	sub    $0x1,%eax
8010733a:	89 c2                	mov    %eax,%edx
8010733c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010733f:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80107343:	83 ec 0c             	sub    $0xc,%esp
80107346:	ff 75 f4             	pushl  -0xc(%ebp)
80107349:	e8 e0 a4 ff ff       	call   8010182e <iupdate>
8010734e:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80107351:	83 ec 0c             	sub    $0xc,%esp
80107354:	ff 75 f4             	pushl  -0xc(%ebp)
80107357:	e8 6c a9 ff ff       	call   80101cc8 <iunlockput>
8010735c:	83 c4 10             	add    $0x10,%esp
  end_op();
8010735f:	e8 13 c3 ff ff       	call   80103677 <end_op>
  return -1;
80107364:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107369:	c9                   	leave  
8010736a:	c3                   	ret    

8010736b <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010736b:	55                   	push   %ebp
8010736c:	89 e5                	mov    %esp,%ebp
8010736e:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80107371:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80107378:	eb 40                	jmp    801073ba <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010737a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010737d:	6a 10                	push   $0x10
8010737f:	50                   	push   %eax
80107380:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107383:	50                   	push   %eax
80107384:	ff 75 08             	pushl  0x8(%ebp)
80107387:	e8 ea ab ff ff       	call   80101f76 <readi>
8010738c:	83 c4 10             	add    $0x10,%esp
8010738f:	83 f8 10             	cmp    $0x10,%eax
80107392:	74 0d                	je     801073a1 <isdirempty+0x36>
      panic("isdirempty: readi");
80107394:	83 ec 0c             	sub    $0xc,%esp
80107397:	68 53 a7 10 80       	push   $0x8010a753
8010739c:	e8 c5 91 ff ff       	call   80100566 <panic>
    if(de.inum != 0)
801073a1:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801073a5:	66 85 c0             	test   %ax,%ax
801073a8:	74 07                	je     801073b1 <isdirempty+0x46>
      return 0;
801073aa:	b8 00 00 00 00       	mov    $0x0,%eax
801073af:	eb 1b                	jmp    801073cc <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801073b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073b4:	83 c0 10             	add    $0x10,%eax
801073b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801073ba:	8b 45 08             	mov    0x8(%ebp),%eax
801073bd:	8b 50 18             	mov    0x18(%eax),%edx
801073c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073c3:	39 c2                	cmp    %eax,%edx
801073c5:	77 b3                	ja     8010737a <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
801073c7:	b8 01 00 00 00       	mov    $0x1,%eax
}
801073cc:	c9                   	leave  
801073cd:	c3                   	ret    

801073ce <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801073ce:	55                   	push   %ebp
801073cf:	89 e5                	mov    %esp,%ebp
801073d1:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801073d4:	83 ec 08             	sub    $0x8,%esp
801073d7:	8d 45 cc             	lea    -0x34(%ebp),%eax
801073da:	50                   	push   %eax
801073db:	6a 00                	push   $0x0
801073dd:	e8 a0 fa ff ff       	call   80106e82 <argstr>
801073e2:	83 c4 10             	add    $0x10,%esp
801073e5:	85 c0                	test   %eax,%eax
801073e7:	79 0a                	jns    801073f3 <sys_unlink+0x25>
    return -1;
801073e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073ee:	e9 bc 01 00 00       	jmp    801075af <sys_unlink+0x1e1>

  begin_op();
801073f3:	e8 f3 c1 ff ff       	call   801035eb <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801073f8:	8b 45 cc             	mov    -0x34(%ebp),%eax
801073fb:	83 ec 08             	sub    $0x8,%esp
801073fe:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80107401:	52                   	push   %edx
80107402:	50                   	push   %eax
80107403:	e8 da b1 ff ff       	call   801025e2 <nameiparent>
80107408:	83 c4 10             	add    $0x10,%esp
8010740b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010740e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107412:	75 0f                	jne    80107423 <sys_unlink+0x55>
    end_op();
80107414:	e8 5e c2 ff ff       	call   80103677 <end_op>
    return -1;
80107419:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010741e:	e9 8c 01 00 00       	jmp    801075af <sys_unlink+0x1e1>
  }

  ilock(dp);
80107423:	83 ec 0c             	sub    $0xc,%esp
80107426:	ff 75 f4             	pushl  -0xc(%ebp)
80107429:	e8 da a5 ff ff       	call   80101a08 <ilock>
8010742e:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80107431:	83 ec 08             	sub    $0x8,%esp
80107434:	68 65 a7 10 80       	push   $0x8010a765
80107439:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010743c:	50                   	push   %eax
8010743d:	e8 13 ae ff ff       	call   80102255 <namecmp>
80107442:	83 c4 10             	add    $0x10,%esp
80107445:	85 c0                	test   %eax,%eax
80107447:	0f 84 4a 01 00 00    	je     80107597 <sys_unlink+0x1c9>
8010744d:	83 ec 08             	sub    $0x8,%esp
80107450:	68 67 a7 10 80       	push   $0x8010a767
80107455:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80107458:	50                   	push   %eax
80107459:	e8 f7 ad ff ff       	call   80102255 <namecmp>
8010745e:	83 c4 10             	add    $0x10,%esp
80107461:	85 c0                	test   %eax,%eax
80107463:	0f 84 2e 01 00 00    	je     80107597 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80107469:	83 ec 04             	sub    $0x4,%esp
8010746c:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010746f:	50                   	push   %eax
80107470:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80107473:	50                   	push   %eax
80107474:	ff 75 f4             	pushl  -0xc(%ebp)
80107477:	e8 f4 ad ff ff       	call   80102270 <dirlookup>
8010747c:	83 c4 10             	add    $0x10,%esp
8010747f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107482:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107486:	0f 84 0a 01 00 00    	je     80107596 <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
8010748c:	83 ec 0c             	sub    $0xc,%esp
8010748f:	ff 75 f0             	pushl  -0x10(%ebp)
80107492:	e8 71 a5 ff ff       	call   80101a08 <ilock>
80107497:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
8010749a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010749d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801074a1:	66 85 c0             	test   %ax,%ax
801074a4:	7f 0d                	jg     801074b3 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
801074a6:	83 ec 0c             	sub    $0xc,%esp
801074a9:	68 6a a7 10 80       	push   $0x8010a76a
801074ae:	e8 b3 90 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801074b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801074b6:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801074ba:	66 83 f8 01          	cmp    $0x1,%ax
801074be:	75 25                	jne    801074e5 <sys_unlink+0x117>
801074c0:	83 ec 0c             	sub    $0xc,%esp
801074c3:	ff 75 f0             	pushl  -0x10(%ebp)
801074c6:	e8 a0 fe ff ff       	call   8010736b <isdirempty>
801074cb:	83 c4 10             	add    $0x10,%esp
801074ce:	85 c0                	test   %eax,%eax
801074d0:	75 13                	jne    801074e5 <sys_unlink+0x117>
    iunlockput(ip);
801074d2:	83 ec 0c             	sub    $0xc,%esp
801074d5:	ff 75 f0             	pushl  -0x10(%ebp)
801074d8:	e8 eb a7 ff ff       	call   80101cc8 <iunlockput>
801074dd:	83 c4 10             	add    $0x10,%esp
    goto bad;
801074e0:	e9 b2 00 00 00       	jmp    80107597 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
801074e5:	83 ec 04             	sub    $0x4,%esp
801074e8:	6a 10                	push   $0x10
801074ea:	6a 00                	push   $0x0
801074ec:	8d 45 e0             	lea    -0x20(%ebp),%eax
801074ef:	50                   	push   %eax
801074f0:	e8 e3 f5 ff ff       	call   80106ad8 <memset>
801074f5:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801074f8:	8b 45 c8             	mov    -0x38(%ebp),%eax
801074fb:	6a 10                	push   $0x10
801074fd:	50                   	push   %eax
801074fe:	8d 45 e0             	lea    -0x20(%ebp),%eax
80107501:	50                   	push   %eax
80107502:	ff 75 f4             	pushl  -0xc(%ebp)
80107505:	e8 c3 ab ff ff       	call   801020cd <writei>
8010750a:	83 c4 10             	add    $0x10,%esp
8010750d:	83 f8 10             	cmp    $0x10,%eax
80107510:	74 0d                	je     8010751f <sys_unlink+0x151>
    panic("unlink: writei");
80107512:	83 ec 0c             	sub    $0xc,%esp
80107515:	68 7c a7 10 80       	push   $0x8010a77c
8010751a:	e8 47 90 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
8010751f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107522:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107526:	66 83 f8 01          	cmp    $0x1,%ax
8010752a:	75 21                	jne    8010754d <sys_unlink+0x17f>
    dp->nlink--;
8010752c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010752f:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80107533:	83 e8 01             	sub    $0x1,%eax
80107536:	89 c2                	mov    %eax,%edx
80107538:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010753b:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
8010753f:	83 ec 0c             	sub    $0xc,%esp
80107542:	ff 75 f4             	pushl  -0xc(%ebp)
80107545:	e8 e4 a2 ff ff       	call   8010182e <iupdate>
8010754a:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
8010754d:	83 ec 0c             	sub    $0xc,%esp
80107550:	ff 75 f4             	pushl  -0xc(%ebp)
80107553:	e8 70 a7 ff ff       	call   80101cc8 <iunlockput>
80107558:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
8010755b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010755e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80107562:	83 e8 01             	sub    $0x1,%eax
80107565:	89 c2                	mov    %eax,%edx
80107567:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010756a:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010756e:	83 ec 0c             	sub    $0xc,%esp
80107571:	ff 75 f0             	pushl  -0x10(%ebp)
80107574:	e8 b5 a2 ff ff       	call   8010182e <iupdate>
80107579:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010757c:	83 ec 0c             	sub    $0xc,%esp
8010757f:	ff 75 f0             	pushl  -0x10(%ebp)
80107582:	e8 41 a7 ff ff       	call   80101cc8 <iunlockput>
80107587:	83 c4 10             	add    $0x10,%esp

  end_op();
8010758a:	e8 e8 c0 ff ff       	call   80103677 <end_op>

  return 0;
8010758f:	b8 00 00 00 00       	mov    $0x0,%eax
80107594:	eb 19                	jmp    801075af <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80107596:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80107597:	83 ec 0c             	sub    $0xc,%esp
8010759a:	ff 75 f4             	pushl  -0xc(%ebp)
8010759d:	e8 26 a7 ff ff       	call   80101cc8 <iunlockput>
801075a2:	83 c4 10             	add    $0x10,%esp
  end_op();
801075a5:	e8 cd c0 ff ff       	call   80103677 <end_op>
  return -1;
801075aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801075af:	c9                   	leave  
801075b0:	c3                   	ret    

801075b1 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801075b1:	55                   	push   %ebp
801075b2:	89 e5                	mov    %esp,%ebp
801075b4:	83 ec 38             	sub    $0x38,%esp
801075b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801075ba:	8b 55 10             	mov    0x10(%ebp),%edx
801075bd:	8b 45 14             	mov    0x14(%ebp),%eax
801075c0:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801075c4:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801075c8:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801075cc:	83 ec 08             	sub    $0x8,%esp
801075cf:	8d 45 de             	lea    -0x22(%ebp),%eax
801075d2:	50                   	push   %eax
801075d3:	ff 75 08             	pushl  0x8(%ebp)
801075d6:	e8 07 b0 ff ff       	call   801025e2 <nameiparent>
801075db:	83 c4 10             	add    $0x10,%esp
801075de:	89 45 f4             	mov    %eax,-0xc(%ebp)
801075e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801075e5:	75 0a                	jne    801075f1 <create+0x40>
    return 0;
801075e7:	b8 00 00 00 00       	mov    $0x0,%eax
801075ec:	e9 90 01 00 00       	jmp    80107781 <create+0x1d0>
  ilock(dp);
801075f1:	83 ec 0c             	sub    $0xc,%esp
801075f4:	ff 75 f4             	pushl  -0xc(%ebp)
801075f7:	e8 0c a4 ff ff       	call   80101a08 <ilock>
801075fc:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801075ff:	83 ec 04             	sub    $0x4,%esp
80107602:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107605:	50                   	push   %eax
80107606:	8d 45 de             	lea    -0x22(%ebp),%eax
80107609:	50                   	push   %eax
8010760a:	ff 75 f4             	pushl  -0xc(%ebp)
8010760d:	e8 5e ac ff ff       	call   80102270 <dirlookup>
80107612:	83 c4 10             	add    $0x10,%esp
80107615:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107618:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010761c:	74 50                	je     8010766e <create+0xbd>
    iunlockput(dp);
8010761e:	83 ec 0c             	sub    $0xc,%esp
80107621:	ff 75 f4             	pushl  -0xc(%ebp)
80107624:	e8 9f a6 ff ff       	call   80101cc8 <iunlockput>
80107629:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
8010762c:	83 ec 0c             	sub    $0xc,%esp
8010762f:	ff 75 f0             	pushl  -0x10(%ebp)
80107632:	e8 d1 a3 ff ff       	call   80101a08 <ilock>
80107637:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010763a:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
8010763f:	75 15                	jne    80107656 <create+0xa5>
80107641:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107644:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107648:	66 83 f8 02          	cmp    $0x2,%ax
8010764c:	75 08                	jne    80107656 <create+0xa5>
      return ip;
8010764e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107651:	e9 2b 01 00 00       	jmp    80107781 <create+0x1d0>
    iunlockput(ip);
80107656:	83 ec 0c             	sub    $0xc,%esp
80107659:	ff 75 f0             	pushl  -0x10(%ebp)
8010765c:	e8 67 a6 ff ff       	call   80101cc8 <iunlockput>
80107661:	83 c4 10             	add    $0x10,%esp
    return 0;
80107664:	b8 00 00 00 00       	mov    $0x0,%eax
80107669:	e9 13 01 00 00       	jmp    80107781 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010766e:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80107672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107675:	8b 00                	mov    (%eax),%eax
80107677:	83 ec 08             	sub    $0x8,%esp
8010767a:	52                   	push   %edx
8010767b:	50                   	push   %eax
8010767c:	e8 d6 a0 ff ff       	call   80101757 <ialloc>
80107681:	83 c4 10             	add    $0x10,%esp
80107684:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107687:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010768b:	75 0d                	jne    8010769a <create+0xe9>
    panic("create: ialloc");
8010768d:	83 ec 0c             	sub    $0xc,%esp
80107690:	68 8b a7 10 80       	push   $0x8010a78b
80107695:	e8 cc 8e ff ff       	call   80100566 <panic>

  ilock(ip);
8010769a:	83 ec 0c             	sub    $0xc,%esp
8010769d:	ff 75 f0             	pushl  -0x10(%ebp)
801076a0:	e8 63 a3 ff ff       	call   80101a08 <ilock>
801076a5:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801076a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076ab:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801076af:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
801076b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076b6:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801076ba:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
801076be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076c1:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
801076c7:	83 ec 0c             	sub    $0xc,%esp
801076ca:	ff 75 f0             	pushl  -0x10(%ebp)
801076cd:	e8 5c a1 ff ff       	call   8010182e <iupdate>
801076d2:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801076d5:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801076da:	75 6a                	jne    80107746 <create+0x195>
    dp->nlink++;  // for ".."
801076dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076df:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801076e3:	83 c0 01             	add    $0x1,%eax
801076e6:	89 c2                	mov    %eax,%edx
801076e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076eb:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801076ef:	83 ec 0c             	sub    $0xc,%esp
801076f2:	ff 75 f4             	pushl  -0xc(%ebp)
801076f5:	e8 34 a1 ff ff       	call   8010182e <iupdate>
801076fa:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801076fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107700:	8b 40 04             	mov    0x4(%eax),%eax
80107703:	83 ec 04             	sub    $0x4,%esp
80107706:	50                   	push   %eax
80107707:	68 65 a7 10 80       	push   $0x8010a765
8010770c:	ff 75 f0             	pushl  -0x10(%ebp)
8010770f:	e8 16 ac ff ff       	call   8010232a <dirlink>
80107714:	83 c4 10             	add    $0x10,%esp
80107717:	85 c0                	test   %eax,%eax
80107719:	78 1e                	js     80107739 <create+0x188>
8010771b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010771e:	8b 40 04             	mov    0x4(%eax),%eax
80107721:	83 ec 04             	sub    $0x4,%esp
80107724:	50                   	push   %eax
80107725:	68 67 a7 10 80       	push   $0x8010a767
8010772a:	ff 75 f0             	pushl  -0x10(%ebp)
8010772d:	e8 f8 ab ff ff       	call   8010232a <dirlink>
80107732:	83 c4 10             	add    $0x10,%esp
80107735:	85 c0                	test   %eax,%eax
80107737:	79 0d                	jns    80107746 <create+0x195>
      panic("create dots");
80107739:	83 ec 0c             	sub    $0xc,%esp
8010773c:	68 9a a7 10 80       	push   $0x8010a79a
80107741:	e8 20 8e ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80107746:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107749:	8b 40 04             	mov    0x4(%eax),%eax
8010774c:	83 ec 04             	sub    $0x4,%esp
8010774f:	50                   	push   %eax
80107750:	8d 45 de             	lea    -0x22(%ebp),%eax
80107753:	50                   	push   %eax
80107754:	ff 75 f4             	pushl  -0xc(%ebp)
80107757:	e8 ce ab ff ff       	call   8010232a <dirlink>
8010775c:	83 c4 10             	add    $0x10,%esp
8010775f:	85 c0                	test   %eax,%eax
80107761:	79 0d                	jns    80107770 <create+0x1bf>
    panic("create: dirlink");
80107763:	83 ec 0c             	sub    $0xc,%esp
80107766:	68 a6 a7 10 80       	push   $0x8010a7a6
8010776b:	e8 f6 8d ff ff       	call   80100566 <panic>

  iunlockput(dp);
80107770:	83 ec 0c             	sub    $0xc,%esp
80107773:	ff 75 f4             	pushl  -0xc(%ebp)
80107776:	e8 4d a5 ff ff       	call   80101cc8 <iunlockput>
8010777b:	83 c4 10             	add    $0x10,%esp

  return ip;
8010777e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107781:	c9                   	leave  
80107782:	c3                   	ret    

80107783 <sys_open>:

int
sys_open(void)
{
80107783:	55                   	push   %ebp
80107784:	89 e5                	mov    %esp,%ebp
80107786:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80107789:	83 ec 08             	sub    $0x8,%esp
8010778c:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010778f:	50                   	push   %eax
80107790:	6a 00                	push   $0x0
80107792:	e8 eb f6 ff ff       	call   80106e82 <argstr>
80107797:	83 c4 10             	add    $0x10,%esp
8010779a:	85 c0                	test   %eax,%eax
8010779c:	78 15                	js     801077b3 <sys_open+0x30>
8010779e:	83 ec 08             	sub    $0x8,%esp
801077a1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801077a4:	50                   	push   %eax
801077a5:	6a 01                	push   $0x1
801077a7:	e8 51 f6 ff ff       	call   80106dfd <argint>
801077ac:	83 c4 10             	add    $0x10,%esp
801077af:	85 c0                	test   %eax,%eax
801077b1:	79 0a                	jns    801077bd <sys_open+0x3a>
    return -1;
801077b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801077b8:	e9 61 01 00 00       	jmp    8010791e <sys_open+0x19b>

  begin_op();
801077bd:	e8 29 be ff ff       	call   801035eb <begin_op>

  if(omode & O_CREATE){
801077c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801077c5:	25 00 02 00 00       	and    $0x200,%eax
801077ca:	85 c0                	test   %eax,%eax
801077cc:	74 2a                	je     801077f8 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
801077ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
801077d1:	6a 00                	push   $0x0
801077d3:	6a 00                	push   $0x0
801077d5:	6a 02                	push   $0x2
801077d7:	50                   	push   %eax
801077d8:	e8 d4 fd ff ff       	call   801075b1 <create>
801077dd:	83 c4 10             	add    $0x10,%esp
801077e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801077e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801077e7:	75 75                	jne    8010785e <sys_open+0xdb>
      end_op();
801077e9:	e8 89 be ff ff       	call   80103677 <end_op>
      return -1;
801077ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801077f3:	e9 26 01 00 00       	jmp    8010791e <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
801077f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801077fb:	83 ec 0c             	sub    $0xc,%esp
801077fe:	50                   	push   %eax
801077ff:	e8 c2 ad ff ff       	call   801025c6 <namei>
80107804:	83 c4 10             	add    $0x10,%esp
80107807:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010780a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010780e:	75 0f                	jne    8010781f <sys_open+0x9c>
      end_op();
80107810:	e8 62 be ff ff       	call   80103677 <end_op>
      return -1;
80107815:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010781a:	e9 ff 00 00 00       	jmp    8010791e <sys_open+0x19b>
    }
    ilock(ip);
8010781f:	83 ec 0c             	sub    $0xc,%esp
80107822:	ff 75 f4             	pushl  -0xc(%ebp)
80107825:	e8 de a1 ff ff       	call   80101a08 <ilock>
8010782a:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
8010782d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107830:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107834:	66 83 f8 01          	cmp    $0x1,%ax
80107838:	75 24                	jne    8010785e <sys_open+0xdb>
8010783a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010783d:	85 c0                	test   %eax,%eax
8010783f:	74 1d                	je     8010785e <sys_open+0xdb>
      iunlockput(ip);
80107841:	83 ec 0c             	sub    $0xc,%esp
80107844:	ff 75 f4             	pushl  -0xc(%ebp)
80107847:	e8 7c a4 ff ff       	call   80101cc8 <iunlockput>
8010784c:	83 c4 10             	add    $0x10,%esp
      end_op();
8010784f:	e8 23 be ff ff       	call   80103677 <end_op>
      return -1;
80107854:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107859:	e9 c0 00 00 00       	jmp    8010791e <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010785e:	e8 ce 97 ff ff       	call   80101031 <filealloc>
80107863:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107866:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010786a:	74 17                	je     80107883 <sys_open+0x100>
8010786c:	83 ec 0c             	sub    $0xc,%esp
8010786f:	ff 75 f0             	pushl  -0x10(%ebp)
80107872:	e8 37 f7 ff ff       	call   80106fae <fdalloc>
80107877:	83 c4 10             	add    $0x10,%esp
8010787a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010787d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107881:	79 2e                	jns    801078b1 <sys_open+0x12e>
    if(f)
80107883:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107887:	74 0e                	je     80107897 <sys_open+0x114>
      fileclose(f);
80107889:	83 ec 0c             	sub    $0xc,%esp
8010788c:	ff 75 f0             	pushl  -0x10(%ebp)
8010788f:	e8 5b 98 ff ff       	call   801010ef <fileclose>
80107894:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80107897:	83 ec 0c             	sub    $0xc,%esp
8010789a:	ff 75 f4             	pushl  -0xc(%ebp)
8010789d:	e8 26 a4 ff ff       	call   80101cc8 <iunlockput>
801078a2:	83 c4 10             	add    $0x10,%esp
    end_op();
801078a5:	e8 cd bd ff ff       	call   80103677 <end_op>
    return -1;
801078aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801078af:	eb 6d                	jmp    8010791e <sys_open+0x19b>
  }
  iunlock(ip);
801078b1:	83 ec 0c             	sub    $0xc,%esp
801078b4:	ff 75 f4             	pushl  -0xc(%ebp)
801078b7:	e8 aa a2 ff ff       	call   80101b66 <iunlock>
801078bc:	83 c4 10             	add    $0x10,%esp
  end_op();
801078bf:	e8 b3 bd ff ff       	call   80103677 <end_op>

  f->type = FD_INODE;
801078c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078c7:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801078cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801078d3:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801078d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078d9:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801078e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801078e3:	83 e0 01             	and    $0x1,%eax
801078e6:	85 c0                	test   %eax,%eax
801078e8:	0f 94 c0             	sete   %al
801078eb:	89 c2                	mov    %eax,%edx
801078ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078f0:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801078f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801078f6:	83 e0 01             	and    $0x1,%eax
801078f9:	85 c0                	test   %eax,%eax
801078fb:	75 0a                	jne    80107907 <sys_open+0x184>
801078fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107900:	83 e0 02             	and    $0x2,%eax
80107903:	85 c0                	test   %eax,%eax
80107905:	74 07                	je     8010790e <sys_open+0x18b>
80107907:	b8 01 00 00 00       	mov    $0x1,%eax
8010790c:	eb 05                	jmp    80107913 <sys_open+0x190>
8010790e:	b8 00 00 00 00       	mov    $0x0,%eax
80107913:	89 c2                	mov    %eax,%edx
80107915:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107918:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010791b:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010791e:	c9                   	leave  
8010791f:	c3                   	ret    

80107920 <sys_mkdir>:

int
sys_mkdir(void)
{
80107920:	55                   	push   %ebp
80107921:	89 e5                	mov    %esp,%ebp
80107923:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80107926:	e8 c0 bc ff ff       	call   801035eb <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010792b:	83 ec 08             	sub    $0x8,%esp
8010792e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107931:	50                   	push   %eax
80107932:	6a 00                	push   $0x0
80107934:	e8 49 f5 ff ff       	call   80106e82 <argstr>
80107939:	83 c4 10             	add    $0x10,%esp
8010793c:	85 c0                	test   %eax,%eax
8010793e:	78 1b                	js     8010795b <sys_mkdir+0x3b>
80107940:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107943:	6a 00                	push   $0x0
80107945:	6a 00                	push   $0x0
80107947:	6a 01                	push   $0x1
80107949:	50                   	push   %eax
8010794a:	e8 62 fc ff ff       	call   801075b1 <create>
8010794f:	83 c4 10             	add    $0x10,%esp
80107952:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107955:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107959:	75 0c                	jne    80107967 <sys_mkdir+0x47>
    end_op();
8010795b:	e8 17 bd ff ff       	call   80103677 <end_op>
    return -1;
80107960:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107965:	eb 18                	jmp    8010797f <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80107967:	83 ec 0c             	sub    $0xc,%esp
8010796a:	ff 75 f4             	pushl  -0xc(%ebp)
8010796d:	e8 56 a3 ff ff       	call   80101cc8 <iunlockput>
80107972:	83 c4 10             	add    $0x10,%esp
  end_op();
80107975:	e8 fd bc ff ff       	call   80103677 <end_op>
  return 0;
8010797a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010797f:	c9                   	leave  
80107980:	c3                   	ret    

80107981 <sys_mknod>:

int
sys_mknod(void)
{
80107981:	55                   	push   %ebp
80107982:	89 e5                	mov    %esp,%ebp
80107984:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80107987:	e8 5f bc ff ff       	call   801035eb <begin_op>
  if((len=argstr(0, &path)) < 0 ||
8010798c:	83 ec 08             	sub    $0x8,%esp
8010798f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107992:	50                   	push   %eax
80107993:	6a 00                	push   $0x0
80107995:	e8 e8 f4 ff ff       	call   80106e82 <argstr>
8010799a:	83 c4 10             	add    $0x10,%esp
8010799d:	89 45 f4             	mov    %eax,-0xc(%ebp)
801079a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801079a4:	78 4f                	js     801079f5 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
801079a6:	83 ec 08             	sub    $0x8,%esp
801079a9:	8d 45 e8             	lea    -0x18(%ebp),%eax
801079ac:	50                   	push   %eax
801079ad:	6a 01                	push   $0x1
801079af:	e8 49 f4 ff ff       	call   80106dfd <argint>
801079b4:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
801079b7:	85 c0                	test   %eax,%eax
801079b9:	78 3a                	js     801079f5 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801079bb:	83 ec 08             	sub    $0x8,%esp
801079be:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801079c1:	50                   	push   %eax
801079c2:	6a 02                	push   $0x2
801079c4:	e8 34 f4 ff ff       	call   80106dfd <argint>
801079c9:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801079cc:	85 c0                	test   %eax,%eax
801079ce:	78 25                	js     801079f5 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801079d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801079d3:	0f bf c8             	movswl %ax,%ecx
801079d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801079d9:	0f bf d0             	movswl %ax,%edx
801079dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801079df:	51                   	push   %ecx
801079e0:	52                   	push   %edx
801079e1:	6a 03                	push   $0x3
801079e3:	50                   	push   %eax
801079e4:	e8 c8 fb ff ff       	call   801075b1 <create>
801079e9:	83 c4 10             	add    $0x10,%esp
801079ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
801079ef:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801079f3:	75 0c                	jne    80107a01 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
801079f5:	e8 7d bc ff ff       	call   80103677 <end_op>
    return -1;
801079fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801079ff:	eb 18                	jmp    80107a19 <sys_mknod+0x98>
  }
  iunlockput(ip);
80107a01:	83 ec 0c             	sub    $0xc,%esp
80107a04:	ff 75 f0             	pushl  -0x10(%ebp)
80107a07:	e8 bc a2 ff ff       	call   80101cc8 <iunlockput>
80107a0c:	83 c4 10             	add    $0x10,%esp
  end_op();
80107a0f:	e8 63 bc ff ff       	call   80103677 <end_op>
  return 0;
80107a14:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107a19:	c9                   	leave  
80107a1a:	c3                   	ret    

80107a1b <sys_chdir>:

int
sys_chdir(void)
{
80107a1b:	55                   	push   %ebp
80107a1c:	89 e5                	mov    %esp,%ebp
80107a1e:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80107a21:	e8 c5 bb ff ff       	call   801035eb <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80107a26:	83 ec 08             	sub    $0x8,%esp
80107a29:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107a2c:	50                   	push   %eax
80107a2d:	6a 00                	push   $0x0
80107a2f:	e8 4e f4 ff ff       	call   80106e82 <argstr>
80107a34:	83 c4 10             	add    $0x10,%esp
80107a37:	85 c0                	test   %eax,%eax
80107a39:	78 18                	js     80107a53 <sys_chdir+0x38>
80107a3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a3e:	83 ec 0c             	sub    $0xc,%esp
80107a41:	50                   	push   %eax
80107a42:	e8 7f ab ff ff       	call   801025c6 <namei>
80107a47:	83 c4 10             	add    $0x10,%esp
80107a4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107a4d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107a51:	75 0c                	jne    80107a5f <sys_chdir+0x44>
    end_op();
80107a53:	e8 1f bc ff ff       	call   80103677 <end_op>
    return -1;
80107a58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a5d:	eb 6e                	jmp    80107acd <sys_chdir+0xb2>
  }
  ilock(ip);
80107a5f:	83 ec 0c             	sub    $0xc,%esp
80107a62:	ff 75 f4             	pushl  -0xc(%ebp)
80107a65:	e8 9e 9f ff ff       	call   80101a08 <ilock>
80107a6a:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80107a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a70:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107a74:	66 83 f8 01          	cmp    $0x1,%ax
80107a78:	74 1a                	je     80107a94 <sys_chdir+0x79>
    iunlockput(ip);
80107a7a:	83 ec 0c             	sub    $0xc,%esp
80107a7d:	ff 75 f4             	pushl  -0xc(%ebp)
80107a80:	e8 43 a2 ff ff       	call   80101cc8 <iunlockput>
80107a85:	83 c4 10             	add    $0x10,%esp
    end_op();
80107a88:	e8 ea bb ff ff       	call   80103677 <end_op>
    return -1;
80107a8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a92:	eb 39                	jmp    80107acd <sys_chdir+0xb2>
  }
  iunlock(ip);
80107a94:	83 ec 0c             	sub    $0xc,%esp
80107a97:	ff 75 f4             	pushl  -0xc(%ebp)
80107a9a:	e8 c7 a0 ff ff       	call   80101b66 <iunlock>
80107a9f:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80107aa2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107aa8:	8b 40 68             	mov    0x68(%eax),%eax
80107aab:	83 ec 0c             	sub    $0xc,%esp
80107aae:	50                   	push   %eax
80107aaf:	e8 24 a1 ff ff       	call   80101bd8 <iput>
80107ab4:	83 c4 10             	add    $0x10,%esp
  end_op();
80107ab7:	e8 bb bb ff ff       	call   80103677 <end_op>
  proc->cwd = ip;
80107abc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107ac2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107ac5:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80107ac8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107acd:	c9                   	leave  
80107ace:	c3                   	ret    

80107acf <sys_exec>:

int
sys_exec(void)
{
80107acf:	55                   	push   %ebp
80107ad0:	89 e5                	mov    %esp,%ebp
80107ad2:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80107ad8:	83 ec 08             	sub    $0x8,%esp
80107adb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107ade:	50                   	push   %eax
80107adf:	6a 00                	push   $0x0
80107ae1:	e8 9c f3 ff ff       	call   80106e82 <argstr>
80107ae6:	83 c4 10             	add    $0x10,%esp
80107ae9:	85 c0                	test   %eax,%eax
80107aeb:	78 18                	js     80107b05 <sys_exec+0x36>
80107aed:	83 ec 08             	sub    $0x8,%esp
80107af0:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80107af6:	50                   	push   %eax
80107af7:	6a 01                	push   $0x1
80107af9:	e8 ff f2 ff ff       	call   80106dfd <argint>
80107afe:	83 c4 10             	add    $0x10,%esp
80107b01:	85 c0                	test   %eax,%eax
80107b03:	79 0a                	jns    80107b0f <sys_exec+0x40>
    return -1;
80107b05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b0a:	e9 c6 00 00 00       	jmp    80107bd5 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80107b0f:	83 ec 04             	sub    $0x4,%esp
80107b12:	68 80 00 00 00       	push   $0x80
80107b17:	6a 00                	push   $0x0
80107b19:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80107b1f:	50                   	push   %eax
80107b20:	e8 b3 ef ff ff       	call   80106ad8 <memset>
80107b25:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80107b28:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80107b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b32:	83 f8 1f             	cmp    $0x1f,%eax
80107b35:	76 0a                	jbe    80107b41 <sys_exec+0x72>
      return -1;
80107b37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b3c:	e9 94 00 00 00       	jmp    80107bd5 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80107b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b44:	c1 e0 02             	shl    $0x2,%eax
80107b47:	89 c2                	mov    %eax,%edx
80107b49:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80107b4f:	01 c2                	add    %eax,%edx
80107b51:	83 ec 08             	sub    $0x8,%esp
80107b54:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80107b5a:	50                   	push   %eax
80107b5b:	52                   	push   %edx
80107b5c:	e8 00 f2 ff ff       	call   80106d61 <fetchint>
80107b61:	83 c4 10             	add    $0x10,%esp
80107b64:	85 c0                	test   %eax,%eax
80107b66:	79 07                	jns    80107b6f <sys_exec+0xa0>
      return -1;
80107b68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b6d:	eb 66                	jmp    80107bd5 <sys_exec+0x106>
    if(uarg == 0){
80107b6f:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107b75:	85 c0                	test   %eax,%eax
80107b77:	75 27                	jne    80107ba0 <sys_exec+0xd1>
      argv[i] = 0;
80107b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b7c:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80107b83:	00 00 00 00 
      break;
80107b87:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80107b88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b8b:	83 ec 08             	sub    $0x8,%esp
80107b8e:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80107b94:	52                   	push   %edx
80107b95:	50                   	push   %eax
80107b96:	e8 74 90 ff ff       	call   80100c0f <exec>
80107b9b:	83 c4 10             	add    $0x10,%esp
80107b9e:	eb 35                	jmp    80107bd5 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80107ba0:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80107ba6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107ba9:	c1 e2 02             	shl    $0x2,%edx
80107bac:	01 c2                	add    %eax,%edx
80107bae:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107bb4:	83 ec 08             	sub    $0x8,%esp
80107bb7:	52                   	push   %edx
80107bb8:	50                   	push   %eax
80107bb9:	e8 dd f1 ff ff       	call   80106d9b <fetchstr>
80107bbe:	83 c4 10             	add    $0x10,%esp
80107bc1:	85 c0                	test   %eax,%eax
80107bc3:	79 07                	jns    80107bcc <sys_exec+0xfd>
      return -1;
80107bc5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107bca:	eb 09                	jmp    80107bd5 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80107bcc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80107bd0:	e9 5a ff ff ff       	jmp    80107b2f <sys_exec+0x60>
  return exec(path, argv);
}
80107bd5:	c9                   	leave  
80107bd6:	c3                   	ret    

80107bd7 <sys_pipe>:

int
sys_pipe(void)
{
80107bd7:	55                   	push   %ebp
80107bd8:	89 e5                	mov    %esp,%ebp
80107bda:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80107bdd:	83 ec 04             	sub    $0x4,%esp
80107be0:	6a 08                	push   $0x8
80107be2:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107be5:	50                   	push   %eax
80107be6:	6a 00                	push   $0x0
80107be8:	e8 38 f2 ff ff       	call   80106e25 <argptr>
80107bed:	83 c4 10             	add    $0x10,%esp
80107bf0:	85 c0                	test   %eax,%eax
80107bf2:	79 0a                	jns    80107bfe <sys_pipe+0x27>
    return -1;
80107bf4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107bf9:	e9 af 00 00 00       	jmp    80107cad <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80107bfe:	83 ec 08             	sub    $0x8,%esp
80107c01:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107c04:	50                   	push   %eax
80107c05:	8d 45 e8             	lea    -0x18(%ebp),%eax
80107c08:	50                   	push   %eax
80107c09:	e8 d1 c4 ff ff       	call   801040df <pipealloc>
80107c0e:	83 c4 10             	add    $0x10,%esp
80107c11:	85 c0                	test   %eax,%eax
80107c13:	79 0a                	jns    80107c1f <sys_pipe+0x48>
    return -1;
80107c15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c1a:	e9 8e 00 00 00       	jmp    80107cad <sys_pipe+0xd6>
  fd0 = -1;
80107c1f:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80107c26:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107c29:	83 ec 0c             	sub    $0xc,%esp
80107c2c:	50                   	push   %eax
80107c2d:	e8 7c f3 ff ff       	call   80106fae <fdalloc>
80107c32:	83 c4 10             	add    $0x10,%esp
80107c35:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107c38:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107c3c:	78 18                	js     80107c56 <sys_pipe+0x7f>
80107c3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107c41:	83 ec 0c             	sub    $0xc,%esp
80107c44:	50                   	push   %eax
80107c45:	e8 64 f3 ff ff       	call   80106fae <fdalloc>
80107c4a:	83 c4 10             	add    $0x10,%esp
80107c4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107c50:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107c54:	79 3f                	jns    80107c95 <sys_pipe+0xbe>
    if(fd0 >= 0)
80107c56:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107c5a:	78 14                	js     80107c70 <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80107c5c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107c62:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107c65:	83 c2 08             	add    $0x8,%edx
80107c68:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80107c6f:	00 
    fileclose(rf);
80107c70:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107c73:	83 ec 0c             	sub    $0xc,%esp
80107c76:	50                   	push   %eax
80107c77:	e8 73 94 ff ff       	call   801010ef <fileclose>
80107c7c:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80107c7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107c82:	83 ec 0c             	sub    $0xc,%esp
80107c85:	50                   	push   %eax
80107c86:	e8 64 94 ff ff       	call   801010ef <fileclose>
80107c8b:	83 c4 10             	add    $0x10,%esp
    return -1;
80107c8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c93:	eb 18                	jmp    80107cad <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80107c95:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c98:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107c9b:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80107c9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ca0:	8d 50 04             	lea    0x4(%eax),%edx
80107ca3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ca6:	89 02                	mov    %eax,(%edx)
  return 0;
80107ca8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107cad:	c9                   	leave  
80107cae:	c3                   	ret    

80107caf <outw>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outw(ushort port, ushort data)
{
80107caf:	55                   	push   %ebp
80107cb0:	89 e5                	mov    %esp,%ebp
80107cb2:	83 ec 08             	sub    $0x8,%esp
80107cb5:	8b 55 08             	mov    0x8(%ebp),%edx
80107cb8:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cbb:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107cbf:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107cc3:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
80107cc7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107ccb:	66 ef                	out    %ax,(%dx)
}
80107ccd:	90                   	nop
80107cce:	c9                   	leave  
80107ccf:	c3                   	ret    

80107cd0 <sys_fork>:
#include "proc.h"
#include "uproc.h"

int
sys_fork(void)
{
80107cd0:	55                   	push   %ebp
80107cd1:	89 e5                	mov    %esp,%ebp
80107cd3:	83 ec 08             	sub    $0x8,%esp
  return fork();
80107cd6:	e8 0e cd ff ff       	call   801049e9 <fork>
}
80107cdb:	c9                   	leave  
80107cdc:	c3                   	ret    

80107cdd <sys_exit>:

int
sys_exit(void)
{
80107cdd:	55                   	push   %ebp
80107cde:	89 e5                	mov    %esp,%ebp
80107ce0:	83 ec 08             	sub    $0x8,%esp
  exit();
80107ce3:	e8 ce cf ff ff       	call   80104cb6 <exit>
  return 0;  // not reached
80107ce8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107ced:	c9                   	leave  
80107cee:	c3                   	ret    

80107cef <sys_wait>:

int
sys_wait(void)
{
80107cef:	55                   	push   %ebp
80107cf0:	89 e5                	mov    %esp,%ebp
80107cf2:	83 ec 08             	sub    $0x8,%esp
  return wait();
80107cf5:	e8 11 d2 ff ff       	call   80104f0b <wait>
}
80107cfa:	c9                   	leave  
80107cfb:	c3                   	ret    

80107cfc <sys_kill>:

int
sys_kill(void)
{
80107cfc:	55                   	push   %ebp
80107cfd:	89 e5                	mov    %esp,%ebp
80107cff:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80107d02:	83 ec 08             	sub    $0x8,%esp
80107d05:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107d08:	50                   	push   %eax
80107d09:	6a 00                	push   $0x0
80107d0b:	e8 ed f0 ff ff       	call   80106dfd <argint>
80107d10:	83 c4 10             	add    $0x10,%esp
80107d13:	85 c0                	test   %eax,%eax
80107d15:	79 07                	jns    80107d1e <sys_kill+0x22>
    return -1;
80107d17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d1c:	eb 0f                	jmp    80107d2d <sys_kill+0x31>
  return kill(pid);
80107d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d21:	83 ec 0c             	sub    $0xc,%esp
80107d24:	50                   	push   %eax
80107d25:	e8 1e db ff ff       	call   80105848 <kill>
80107d2a:	83 c4 10             	add    $0x10,%esp
}
80107d2d:	c9                   	leave  
80107d2e:	c3                   	ret    

80107d2f <sys_getpid>:

int
sys_getpid(void)
{
80107d2f:	55                   	push   %ebp
80107d30:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80107d32:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107d38:	8b 40 10             	mov    0x10(%eax),%eax
}
80107d3b:	5d                   	pop    %ebp
80107d3c:	c3                   	ret    

80107d3d <sys_sbrk>:

int
sys_sbrk(void)
{
80107d3d:	55                   	push   %ebp
80107d3e:	89 e5                	mov    %esp,%ebp
80107d40:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80107d43:	83 ec 08             	sub    $0x8,%esp
80107d46:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107d49:	50                   	push   %eax
80107d4a:	6a 00                	push   $0x0
80107d4c:	e8 ac f0 ff ff       	call   80106dfd <argint>
80107d51:	83 c4 10             	add    $0x10,%esp
80107d54:	85 c0                	test   %eax,%eax
80107d56:	79 07                	jns    80107d5f <sys_sbrk+0x22>
    return -1;
80107d58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d5d:	eb 28                	jmp    80107d87 <sys_sbrk+0x4a>
  addr = proc->sz;
80107d5f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107d65:	8b 00                	mov    (%eax),%eax
80107d67:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80107d6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d6d:	83 ec 0c             	sub    $0xc,%esp
80107d70:	50                   	push   %eax
80107d71:	e8 d0 cb ff ff       	call   80104946 <growproc>
80107d76:	83 c4 10             	add    $0x10,%esp
80107d79:	85 c0                	test   %eax,%eax
80107d7b:	79 07                	jns    80107d84 <sys_sbrk+0x47>
    return -1;
80107d7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d82:	eb 03                	jmp    80107d87 <sys_sbrk+0x4a>
  return addr;
80107d84:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107d87:	c9                   	leave  
80107d88:	c3                   	ret    

80107d89 <sys_sleep>:

int
sys_sleep(void)
{
80107d89:	55                   	push   %ebp
80107d8a:	89 e5                	mov    %esp,%ebp
80107d8c:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80107d8f:	83 ec 08             	sub    $0x8,%esp
80107d92:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107d95:	50                   	push   %eax
80107d96:	6a 00                	push   $0x0
80107d98:	e8 60 f0 ff ff       	call   80106dfd <argint>
80107d9d:	83 c4 10             	add    $0x10,%esp
80107da0:	85 c0                	test   %eax,%eax
80107da2:	79 07                	jns    80107dab <sys_sleep+0x22>
    return -1;
80107da4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107da9:	eb 44                	jmp    80107def <sys_sleep+0x66>
  ticks0 = ticks;
80107dab:	a1 20 79 11 80       	mov    0x80117920,%eax
80107db0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80107db3:	eb 26                	jmp    80107ddb <sys_sleep+0x52>
    if(proc->killed){
80107db5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107dbb:	8b 40 24             	mov    0x24(%eax),%eax
80107dbe:	85 c0                	test   %eax,%eax
80107dc0:	74 07                	je     80107dc9 <sys_sleep+0x40>
      return -1;
80107dc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107dc7:	eb 26                	jmp    80107def <sys_sleep+0x66>
    }
    sleep(&ticks, (struct spinlock *)0);
80107dc9:	83 ec 08             	sub    $0x8,%esp
80107dcc:	6a 00                	push   $0x0
80107dce:	68 20 79 11 80       	push   $0x80117920
80107dd3:	e8 c1 d7 ff ff       	call   80105599 <sleep>
80107dd8:	83 c4 10             	add    $0x10,%esp
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80107ddb:	a1 20 79 11 80       	mov    0x80117920,%eax
80107de0:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107de3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107de6:	39 d0                	cmp    %edx,%eax
80107de8:	72 cb                	jb     80107db5 <sys_sleep+0x2c>
    if(proc->killed){
      return -1;
    }
    sleep(&ticks, (struct spinlock *)0);
  }
  return 0;
80107dea:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107def:	c9                   	leave  
80107df0:	c3                   	ret    

80107df1 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80107df1:	55                   	push   %ebp
80107df2:	89 e5                	mov    %esp,%ebp
80107df4:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  xticks = ticks;
80107df7:	a1 20 79 11 80       	mov    0x80117920,%eax
80107dfc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return xticks;
80107dff:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80107e02:	c9                   	leave  
80107e03:	c3                   	ret    

80107e04 <sys_halt>:

//Turn of the computer
int
sys_halt(void){
80107e04:	55                   	push   %ebp
80107e05:	89 e5                	mov    %esp,%ebp
80107e07:	83 ec 08             	sub    $0x8,%esp
  cprintf("Shutting down ...\n");
80107e0a:	83 ec 0c             	sub    $0xc,%esp
80107e0d:	68 b6 a7 10 80       	push   $0x8010a7b6
80107e12:	e8 af 85 ff ff       	call   801003c6 <cprintf>
80107e17:	83 c4 10             	add    $0x10,%esp
  outw( 0x604, 0x0 | 0x2000);
80107e1a:	83 ec 08             	sub    $0x8,%esp
80107e1d:	68 00 20 00 00       	push   $0x2000
80107e22:	68 04 06 00 00       	push   $0x604
80107e27:	e8 83 fe ff ff       	call   80107caf <outw>
80107e2c:	83 c4 10             	add    $0x10,%esp
  return 0;
80107e2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107e34:	c9                   	leave  
80107e35:	c3                   	ret    

80107e36 <sys_date>:


int
sys_date(void)
{
80107e36:	55                   	push   %ebp
80107e37:	89 e5                	mov    %esp,%ebp
80107e39:	83 ec 18             	sub    $0x18,%esp
  struct rtcdate *d;
  if(argptr(0, (void*)&d, sizeof(struct rtcdate)) < 0)
80107e3c:	83 ec 04             	sub    $0x4,%esp
80107e3f:	6a 18                	push   $0x18
80107e41:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107e44:	50                   	push   %eax
80107e45:	6a 00                	push   $0x0
80107e47:	e8 d9 ef ff ff       	call   80106e25 <argptr>
80107e4c:	83 c4 10             	add    $0x10,%esp
80107e4f:	85 c0                	test   %eax,%eax
80107e51:	79 07                	jns    80107e5a <sys_date+0x24>
    return -1;
80107e53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e58:	eb 14                	jmp    80107e6e <sys_date+0x38>
  cmostime(d);
80107e5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5d:	83 ec 0c             	sub    $0xc,%esp
80107e60:	50                   	push   %eax
80107e61:	e8 00 b4 ff ff       	call   80103266 <cmostime>
80107e66:	83 c4 10             	add    $0x10,%esp
  return 0;
80107e69:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107e6e:	c9                   	leave  
80107e6f:	c3                   	ret    

80107e70 <sys_getuid>:

//Get gid
uint
sys_getuid(void)
{
80107e70:	55                   	push   %ebp
80107e71:	89 e5                	mov    %esp,%ebp
  return proc->uid;
80107e73:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107e79:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
80107e7f:	5d                   	pop    %ebp
80107e80:	c3                   	ret    

80107e81 <sys_getgid>:

//Get gid
uint
sys_getgid(void)
{
80107e81:	55                   	push   %ebp
80107e82:	89 e5                	mov    %esp,%ebp
  return proc->gid;
80107e84:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107e8a:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
}
80107e90:	5d                   	pop    %ebp
80107e91:	c3                   	ret    

80107e92 <sys_getppid>:

//Returns init's pid, since it has no parent.
//Or returns the parents pid.
uint
sys_getppid(void)
{
80107e92:	55                   	push   %ebp
80107e93:	89 e5                	mov    %esp,%ebp
  if(proc->parent != 0)
80107e95:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107e9b:	8b 40 14             	mov    0x14(%eax),%eax
80107e9e:	85 c0                	test   %eax,%eax
80107ea0:	74 0e                	je     80107eb0 <sys_getppid+0x1e>
    return proc->parent->pid;
80107ea2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107ea8:	8b 40 14             	mov    0x14(%eax),%eax
80107eab:	8b 40 10             	mov    0x10(%eax),%eax
80107eae:	eb 09                	jmp    80107eb9 <sys_getppid+0x27>
  return proc->pid;
80107eb0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107eb6:	8b 40 10             	mov    0x10(%eax),%eax
}
80107eb9:	5d                   	pop    %ebp
80107eba:	c3                   	ret    

80107ebb <sys_setuid>:

//Sets the uid after making sure that the argument
//is within the bounds 0<=32767
int
sys_setuid(uint _uid)
{
80107ebb:	55                   	push   %ebp
80107ebc:	89 e5                	mov    %esp,%ebp
80107ebe:	83 ec 08             	sub    $0x8,%esp
  argint(0, (int*)&_uid);
80107ec1:	83 ec 08             	sub    $0x8,%esp
80107ec4:	8d 45 08             	lea    0x8(%ebp),%eax
80107ec7:	50                   	push   %eax
80107ec8:	6a 00                	push   $0x0
80107eca:	e8 2e ef ff ff       	call   80106dfd <argint>
80107ecf:	83 c4 10             	add    $0x10,%esp
  if (_uid>= 0 && _uid<= 32767)
80107ed2:	8b 45 08             	mov    0x8(%ebp),%eax
80107ed5:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
80107eda:	77 16                	ja     80107ef2 <sys_setuid+0x37>
  {
    proc->uid = _uid;
80107edc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107ee2:	8b 55 08             	mov    0x8(%ebp),%edx
80107ee5:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
    return 0;
80107eeb:	b8 00 00 00 00       	mov    $0x0,%eax
80107ef0:	eb 05                	jmp    80107ef7 <sys_setuid+0x3c>
  }
  return -1;
80107ef2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107ef7:	c9                   	leave  
80107ef8:	c3                   	ret    

80107ef9 <sys_setgid>:

//Sets the gid after making sure that the argument
//is within the bouds 0<=32767
int
sys_setgid(uint _uid)
{
80107ef9:	55                   	push   %ebp
80107efa:	89 e5                	mov    %esp,%ebp
80107efc:	83 ec 08             	sub    $0x8,%esp
  argint(0, (int*)&_uid);
80107eff:	83 ec 08             	sub    $0x8,%esp
80107f02:	8d 45 08             	lea    0x8(%ebp),%eax
80107f05:	50                   	push   %eax
80107f06:	6a 00                	push   $0x0
80107f08:	e8 f0 ee ff ff       	call   80106dfd <argint>
80107f0d:	83 c4 10             	add    $0x10,%esp
  if (_uid>= 0 && _uid<= 32767)
80107f10:	8b 45 08             	mov    0x8(%ebp),%eax
80107f13:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
80107f18:	77 16                	ja     80107f30 <sys_setgid+0x37>
  {
    proc->gid = _uid;
80107f1a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107f20:	8b 55 08             	mov    0x8(%ebp),%edx
80107f23:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
    return 0;
80107f29:	b8 00 00 00 00       	mov    $0x0,%eax
80107f2e:	eb 05                	jmp    80107f35 <sys_setgid+0x3c>
  }
  return -1;
80107f30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107f35:	c9                   	leave  
80107f36:	c3                   	ret    

80107f37 <sys_getprocs>:

//Getprocs calls getprocs in proc.c in order to lock the ptable and
//grab all the processes off of that when ps is called.
int
sys_getprocs(int max, struct uproc* table)
{
80107f37:	55                   	push   %ebp
80107f38:	89 e5                	mov    %esp,%ebp
80107f3a:	83 ec 08             	sub    $0x8,%esp
  if(argint(0,&max)< 0 || argptr(1,(void*)&table,sizeof(*table)*max) <0)
80107f3d:	83 ec 08             	sub    $0x8,%esp
80107f40:	8d 45 08             	lea    0x8(%ebp),%eax
80107f43:	50                   	push   %eax
80107f44:	6a 00                	push   $0x0
80107f46:	e8 b2 ee ff ff       	call   80106dfd <argint>
80107f4b:	83 c4 10             	add    $0x10,%esp
80107f4e:	85 c0                	test   %eax,%eax
80107f50:	78 24                	js     80107f76 <sys_getprocs+0x3f>
80107f52:	8b 45 08             	mov    0x8(%ebp),%eax
80107f55:	89 c2                	mov    %eax,%edx
80107f57:	89 d0                	mov    %edx,%eax
80107f59:	01 c0                	add    %eax,%eax
80107f5b:	01 d0                	add    %edx,%eax
80107f5d:	c1 e0 05             	shl    $0x5,%eax
80107f60:	83 ec 04             	sub    $0x4,%esp
80107f63:	50                   	push   %eax
80107f64:	8d 45 0c             	lea    0xc(%ebp),%eax
80107f67:	50                   	push   %eax
80107f68:	6a 01                	push   $0x1
80107f6a:	e8 b6 ee ff ff       	call   80106e25 <argptr>
80107f6f:	83 c4 10             	add    $0x10,%esp
80107f72:	85 c0                	test   %eax,%eax
80107f74:	79 07                	jns    80107f7d <sys_getprocs+0x46>
    return -1;
80107f76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f7b:	eb 13                	jmp    80107f90 <sys_getprocs+0x59>
  return getprocs(max,table);
80107f7d:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f80:	8b 45 08             	mov    0x8(%ebp),%eax
80107f83:	83 ec 08             	sub    $0x8,%esp
80107f86:	52                   	push   %edx
80107f87:	50                   	push   %eax
80107f88:	e8 a5 df ff ff       	call   80105f32 <getprocs>
80107f8d:	83 c4 10             	add    $0x10,%esp
}
80107f90:	c9                   	leave  
80107f91:	c3                   	ret    

80107f92 <sys_setpriority>:

int
sys_setpriority(void)
{
80107f92:	55                   	push   %ebp
80107f93:	89 e5                	mov    %esp,%ebp
80107f95:	83 ec 18             	sub    $0x18,%esp
  int pid;
  int value;

  if(argint(0, &pid)< 0 || argint(1,&value))
80107f98:	83 ec 08             	sub    $0x8,%esp
80107f9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107f9e:	50                   	push   %eax
80107f9f:	6a 00                	push   $0x0
80107fa1:	e8 57 ee ff ff       	call   80106dfd <argint>
80107fa6:	83 c4 10             	add    $0x10,%esp
80107fa9:	85 c0                	test   %eax,%eax
80107fab:	78 15                	js     80107fc2 <sys_setpriority+0x30>
80107fad:	83 ec 08             	sub    $0x8,%esp
80107fb0:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107fb3:	50                   	push   %eax
80107fb4:	6a 01                	push   $0x1
80107fb6:	e8 42 ee ff ff       	call   80106dfd <argint>
80107fbb:	83 c4 10             	add    $0x10,%esp
80107fbe:	85 c0                	test   %eax,%eax
80107fc0:	74 07                	je     80107fc9 <sys_setpriority+0x37>
    return -1;
80107fc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107fc7:	eb 13                	jmp    80107fdc <sys_setpriority+0x4a>

  return setpriority(pid, value);
80107fc9:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fcf:	83 ec 08             	sub    $0x8,%esp
80107fd2:	52                   	push   %edx
80107fd3:	50                   	push   %eax
80107fd4:	e8 fc e3 ff ff       	call   801063d5 <setpriority>
80107fd9:	83 c4 10             	add    $0x10,%esp
}
80107fdc:	c9                   	leave  
80107fdd:	c3                   	ret    

80107fde <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107fde:	55                   	push   %ebp
80107fdf:	89 e5                	mov    %esp,%ebp
80107fe1:	83 ec 08             	sub    $0x8,%esp
80107fe4:	8b 55 08             	mov    0x8(%ebp),%edx
80107fe7:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fea:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107fee:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107ff1:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107ff5:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107ff9:	ee                   	out    %al,(%dx)
}
80107ffa:	90                   	nop
80107ffb:	c9                   	leave  
80107ffc:	c3                   	ret    

80107ffd <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80107ffd:	55                   	push   %ebp
80107ffe:	89 e5                	mov    %esp,%ebp
80108000:	83 ec 08             	sub    $0x8,%esp
  // Interrupt TPS times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80108003:	6a 34                	push   $0x34
80108005:	6a 43                	push   $0x43
80108007:	e8 d2 ff ff ff       	call   80107fde <outb>
8010800c:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) % 256);
8010800f:	68 a9 00 00 00       	push   $0xa9
80108014:	6a 40                	push   $0x40
80108016:	e8 c3 ff ff ff       	call   80107fde <outb>
8010801b:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) / 256);
8010801e:	6a 04                	push   $0x4
80108020:	6a 40                	push   $0x40
80108022:	e8 b7 ff ff ff       	call   80107fde <outb>
80108027:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
8010802a:	83 ec 0c             	sub    $0xc,%esp
8010802d:	6a 00                	push   $0x0
8010802f:	e8 95 bf ff ff       	call   80103fc9 <picenable>
80108034:	83 c4 10             	add    $0x10,%esp
}
80108037:	90                   	nop
80108038:	c9                   	leave  
80108039:	c3                   	ret    

8010803a <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010803a:	1e                   	push   %ds
  pushl %es
8010803b:	06                   	push   %es
  pushl %fs
8010803c:	0f a0                	push   %fs
  pushl %gs
8010803e:	0f a8                	push   %gs
  pushal
80108040:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80108041:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80108045:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80108047:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80108049:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
8010804d:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
8010804f:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80108051:	54                   	push   %esp
  call trap
80108052:	e8 ce 01 00 00       	call   80108225 <trap>
  addl $4, %esp
80108057:	83 c4 04             	add    $0x4,%esp

8010805a <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010805a:	61                   	popa   
  popl %gs
8010805b:	0f a9                	pop    %gs
  popl %fs
8010805d:	0f a1                	pop    %fs
  popl %es
8010805f:	07                   	pop    %es
  popl %ds
80108060:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80108061:	83 c4 08             	add    $0x8,%esp
  iret
80108064:	cf                   	iret   

80108065 <atom_inc>:

// Routines added for CS333
// atom_inc() added to simplify handling of ticks global
static inline void
atom_inc(volatile int *num)
{
80108065:	55                   	push   %ebp
80108066:	89 e5                	mov    %esp,%ebp
  asm volatile ( "lock incl %0" : "=m" (*num));
80108068:	8b 45 08             	mov    0x8(%ebp),%eax
8010806b:	f0 ff 00             	lock incl (%eax)
}
8010806e:	90                   	nop
8010806f:	5d                   	pop    %ebp
80108070:	c3                   	ret    

80108071 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80108071:	55                   	push   %ebp
80108072:	89 e5                	mov    %esp,%ebp
80108074:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80108077:	8b 45 0c             	mov    0xc(%ebp),%eax
8010807a:	83 e8 01             	sub    $0x1,%eax
8010807d:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80108081:	8b 45 08             	mov    0x8(%ebp),%eax
80108084:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80108088:	8b 45 08             	mov    0x8(%ebp),%eax
8010808b:	c1 e8 10             	shr    $0x10,%eax
8010808e:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80108092:	8d 45 fa             	lea    -0x6(%ebp),%eax
80108095:	0f 01 18             	lidtl  (%eax)
}
80108098:	90                   	nop
80108099:	c9                   	leave  
8010809a:	c3                   	ret    

8010809b <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
8010809b:	55                   	push   %ebp
8010809c:	89 e5                	mov    %esp,%ebp
8010809e:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801080a1:	0f 20 d0             	mov    %cr2,%eax
801080a4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801080a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801080aa:	c9                   	leave  
801080ab:	c3                   	ret    

801080ac <tvinit>:
// Software Developer’s Manual, Vol 3A, 8.1.1 Guaranteed Atomic Operations.
uint ticks __attribute__ ((aligned (4)));

void
tvinit(void)
{
801080ac:	55                   	push   %ebp
801080ad:	89 e5                	mov    %esp,%ebp
801080af:	83 ec 10             	sub    $0x10,%esp
  int i;

  for(i = 0; i < 256; i++)
801080b2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801080b9:	e9 c3 00 00 00       	jmp    80108181 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801080be:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080c1:	8b 04 85 b4 d0 10 80 	mov    -0x7fef2f4c(,%eax,4),%eax
801080c8:	89 c2                	mov    %eax,%edx
801080ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080cd:	66 89 14 c5 20 71 11 	mov    %dx,-0x7fee8ee0(,%eax,8)
801080d4:	80 
801080d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080d8:	66 c7 04 c5 22 71 11 	movw   $0x8,-0x7fee8ede(,%eax,8)
801080df:	80 08 00 
801080e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080e5:	0f b6 14 c5 24 71 11 	movzbl -0x7fee8edc(,%eax,8),%edx
801080ec:	80 
801080ed:	83 e2 e0             	and    $0xffffffe0,%edx
801080f0:	88 14 c5 24 71 11 80 	mov    %dl,-0x7fee8edc(,%eax,8)
801080f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080fa:	0f b6 14 c5 24 71 11 	movzbl -0x7fee8edc(,%eax,8),%edx
80108101:	80 
80108102:	83 e2 1f             	and    $0x1f,%edx
80108105:	88 14 c5 24 71 11 80 	mov    %dl,-0x7fee8edc(,%eax,8)
8010810c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010810f:	0f b6 14 c5 25 71 11 	movzbl -0x7fee8edb(,%eax,8),%edx
80108116:	80 
80108117:	83 e2 f0             	and    $0xfffffff0,%edx
8010811a:	83 ca 0e             	or     $0xe,%edx
8010811d:	88 14 c5 25 71 11 80 	mov    %dl,-0x7fee8edb(,%eax,8)
80108124:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108127:	0f b6 14 c5 25 71 11 	movzbl -0x7fee8edb(,%eax,8),%edx
8010812e:	80 
8010812f:	83 e2 ef             	and    $0xffffffef,%edx
80108132:	88 14 c5 25 71 11 80 	mov    %dl,-0x7fee8edb(,%eax,8)
80108139:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010813c:	0f b6 14 c5 25 71 11 	movzbl -0x7fee8edb(,%eax,8),%edx
80108143:	80 
80108144:	83 e2 9f             	and    $0xffffff9f,%edx
80108147:	88 14 c5 25 71 11 80 	mov    %dl,-0x7fee8edb(,%eax,8)
8010814e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108151:	0f b6 14 c5 25 71 11 	movzbl -0x7fee8edb(,%eax,8),%edx
80108158:	80 
80108159:	83 ca 80             	or     $0xffffff80,%edx
8010815c:	88 14 c5 25 71 11 80 	mov    %dl,-0x7fee8edb(,%eax,8)
80108163:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108166:	8b 04 85 b4 d0 10 80 	mov    -0x7fef2f4c(,%eax,4),%eax
8010816d:	c1 e8 10             	shr    $0x10,%eax
80108170:	89 c2                	mov    %eax,%edx
80108172:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108175:	66 89 14 c5 26 71 11 	mov    %dx,-0x7fee8eda(,%eax,8)
8010817c:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010817d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80108181:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
80108188:	0f 8e 30 ff ff ff    	jle    801080be <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010818e:	a1 b4 d1 10 80       	mov    0x8010d1b4,%eax
80108193:	66 a3 20 73 11 80    	mov    %ax,0x80117320
80108199:	66 c7 05 22 73 11 80 	movw   $0x8,0x80117322
801081a0:	08 00 
801081a2:	0f b6 05 24 73 11 80 	movzbl 0x80117324,%eax
801081a9:	83 e0 e0             	and    $0xffffffe0,%eax
801081ac:	a2 24 73 11 80       	mov    %al,0x80117324
801081b1:	0f b6 05 24 73 11 80 	movzbl 0x80117324,%eax
801081b8:	83 e0 1f             	and    $0x1f,%eax
801081bb:	a2 24 73 11 80       	mov    %al,0x80117324
801081c0:	0f b6 05 25 73 11 80 	movzbl 0x80117325,%eax
801081c7:	83 c8 0f             	or     $0xf,%eax
801081ca:	a2 25 73 11 80       	mov    %al,0x80117325
801081cf:	0f b6 05 25 73 11 80 	movzbl 0x80117325,%eax
801081d6:	83 e0 ef             	and    $0xffffffef,%eax
801081d9:	a2 25 73 11 80       	mov    %al,0x80117325
801081de:	0f b6 05 25 73 11 80 	movzbl 0x80117325,%eax
801081e5:	83 c8 60             	or     $0x60,%eax
801081e8:	a2 25 73 11 80       	mov    %al,0x80117325
801081ed:	0f b6 05 25 73 11 80 	movzbl 0x80117325,%eax
801081f4:	83 c8 80             	or     $0xffffff80,%eax
801081f7:	a2 25 73 11 80       	mov    %al,0x80117325
801081fc:	a1 b4 d1 10 80       	mov    0x8010d1b4,%eax
80108201:	c1 e8 10             	shr    $0x10,%eax
80108204:	66 a3 26 73 11 80    	mov    %ax,0x80117326
  
}
8010820a:	90                   	nop
8010820b:	c9                   	leave  
8010820c:	c3                   	ret    

8010820d <idtinit>:

void
idtinit(void)
{
8010820d:	55                   	push   %ebp
8010820e:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80108210:	68 00 08 00 00       	push   $0x800
80108215:	68 20 71 11 80       	push   $0x80117120
8010821a:	e8 52 fe ff ff       	call   80108071 <lidt>
8010821f:	83 c4 08             	add    $0x8,%esp
}
80108222:	90                   	nop
80108223:	c9                   	leave  
80108224:	c3                   	ret    

80108225 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80108225:	55                   	push   %ebp
80108226:	89 e5                	mov    %esp,%ebp
80108228:	57                   	push   %edi
80108229:	56                   	push   %esi
8010822a:	53                   	push   %ebx
8010822b:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
8010822e:	8b 45 08             	mov    0x8(%ebp),%eax
80108231:	8b 40 30             	mov    0x30(%eax),%eax
80108234:	83 f8 40             	cmp    $0x40,%eax
80108237:	75 3e                	jne    80108277 <trap+0x52>
    if(proc->killed)
80108239:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010823f:	8b 40 24             	mov    0x24(%eax),%eax
80108242:	85 c0                	test   %eax,%eax
80108244:	74 05                	je     8010824b <trap+0x26>
      exit();
80108246:	e8 6b ca ff ff       	call   80104cb6 <exit>
    proc->tf = tf;
8010824b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108251:	8b 55 08             	mov    0x8(%ebp),%edx
80108254:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80108257:	e8 57 ec ff ff       	call   80106eb3 <syscall>
    if(proc->killed)
8010825c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108262:	8b 40 24             	mov    0x24(%eax),%eax
80108265:	85 c0                	test   %eax,%eax
80108267:	0f 84 21 02 00 00    	je     8010848e <trap+0x269>
      exit();
8010826d:	e8 44 ca ff ff       	call   80104cb6 <exit>
    return;
80108272:	e9 17 02 00 00       	jmp    8010848e <trap+0x269>
  }

  switch(tf->trapno){
80108277:	8b 45 08             	mov    0x8(%ebp),%eax
8010827a:	8b 40 30             	mov    0x30(%eax),%eax
8010827d:	83 e8 20             	sub    $0x20,%eax
80108280:	83 f8 1f             	cmp    $0x1f,%eax
80108283:	0f 87 a3 00 00 00    	ja     8010832c <trap+0x107>
80108289:	8b 04 85 6c a8 10 80 	mov    -0x7fef5794(,%eax,4),%eax
80108290:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
   if(cpu->id == 0){
80108292:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108298:	0f b6 00             	movzbl (%eax),%eax
8010829b:	84 c0                	test   %al,%al
8010829d:	75 20                	jne    801082bf <trap+0x9a>
      atom_inc((int *)&ticks);   // guaranteed atomic so no lock necessary
8010829f:	83 ec 0c             	sub    $0xc,%esp
801082a2:	68 20 79 11 80       	push   $0x80117920
801082a7:	e8 b9 fd ff ff       	call   80108065 <atom_inc>
801082ac:	83 c4 10             	add    $0x10,%esp
      wakeup(&ticks);
801082af:	83 ec 0c             	sub    $0xc,%esp
801082b2:	68 20 79 11 80       	push   $0x80117920
801082b7:	e8 55 d5 ff ff       	call   80105811 <wakeup>
801082bc:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801082bf:	e8 ff ad ff ff       	call   801030c3 <lapiceoi>
    break;
801082c4:	e9 1c 01 00 00       	jmp    801083e5 <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801082c9:	e8 08 a6 ff ff       	call   801028d6 <ideintr>
    lapiceoi();
801082ce:	e8 f0 ad ff ff       	call   801030c3 <lapiceoi>
    break;
801082d3:	e9 0d 01 00 00       	jmp    801083e5 <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801082d8:	e8 e8 ab ff ff       	call   80102ec5 <kbdintr>
    lapiceoi();
801082dd:	e8 e1 ad ff ff       	call   801030c3 <lapiceoi>
    break;
801082e2:	e9 fe 00 00 00       	jmp    801083e5 <trap+0x1c0>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801082e7:	e8 83 03 00 00       	call   8010866f <uartintr>
    lapiceoi();
801082ec:	e8 d2 ad ff ff       	call   801030c3 <lapiceoi>
    break;
801082f1:	e9 ef 00 00 00       	jmp    801083e5 <trap+0x1c0>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801082f6:	8b 45 08             	mov    0x8(%ebp),%eax
801082f9:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801082fc:	8b 45 08             	mov    0x8(%ebp),%eax
801082ff:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80108303:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80108306:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010830c:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010830f:	0f b6 c0             	movzbl %al,%eax
80108312:	51                   	push   %ecx
80108313:	52                   	push   %edx
80108314:	50                   	push   %eax
80108315:	68 cc a7 10 80       	push   $0x8010a7cc
8010831a:	e8 a7 80 ff ff       	call   801003c6 <cprintf>
8010831f:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80108322:	e8 9c ad ff ff       	call   801030c3 <lapiceoi>
    break;
80108327:	e9 b9 00 00 00       	jmp    801083e5 <trap+0x1c0>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
8010832c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108332:	85 c0                	test   %eax,%eax
80108334:	74 11                	je     80108347 <trap+0x122>
80108336:	8b 45 08             	mov    0x8(%ebp),%eax
80108339:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010833d:	0f b7 c0             	movzwl %ax,%eax
80108340:	83 e0 03             	and    $0x3,%eax
80108343:	85 c0                	test   %eax,%eax
80108345:	75 40                	jne    80108387 <trap+0x162>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80108347:	e8 4f fd ff ff       	call   8010809b <rcr2>
8010834c:	89 c3                	mov    %eax,%ebx
8010834e:	8b 45 08             	mov    0x8(%ebp),%eax
80108351:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80108354:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010835a:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010835d:	0f b6 d0             	movzbl %al,%edx
80108360:	8b 45 08             	mov    0x8(%ebp),%eax
80108363:	8b 40 30             	mov    0x30(%eax),%eax
80108366:	83 ec 0c             	sub    $0xc,%esp
80108369:	53                   	push   %ebx
8010836a:	51                   	push   %ecx
8010836b:	52                   	push   %edx
8010836c:	50                   	push   %eax
8010836d:	68 f0 a7 10 80       	push   $0x8010a7f0
80108372:	e8 4f 80 ff ff       	call   801003c6 <cprintf>
80108377:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
8010837a:	83 ec 0c             	sub    $0xc,%esp
8010837d:	68 22 a8 10 80       	push   $0x8010a822
80108382:	e8 df 81 ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80108387:	e8 0f fd ff ff       	call   8010809b <rcr2>
8010838c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010838f:	8b 45 08             	mov    0x8(%ebp),%eax
80108392:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80108395:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010839b:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010839e:	0f b6 d8             	movzbl %al,%ebx
801083a1:	8b 45 08             	mov    0x8(%ebp),%eax
801083a4:	8b 48 34             	mov    0x34(%eax),%ecx
801083a7:	8b 45 08             	mov    0x8(%ebp),%eax
801083aa:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801083ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801083b3:	8d 78 6c             	lea    0x6c(%eax),%edi
801083b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801083bc:	8b 40 10             	mov    0x10(%eax),%eax
801083bf:	ff 75 e4             	pushl  -0x1c(%ebp)
801083c2:	56                   	push   %esi
801083c3:	53                   	push   %ebx
801083c4:	51                   	push   %ecx
801083c5:	52                   	push   %edx
801083c6:	57                   	push   %edi
801083c7:	50                   	push   %eax
801083c8:	68 28 a8 10 80       	push   $0x8010a828
801083cd:	e8 f4 7f ff ff       	call   801003c6 <cprintf>
801083d2:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
801083d5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801083db:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801083e2:	eb 01                	jmp    801083e5 <trap+0x1c0>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801083e4:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801083e5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801083eb:	85 c0                	test   %eax,%eax
801083ed:	74 24                	je     80108413 <trap+0x1ee>
801083ef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801083f5:	8b 40 24             	mov    0x24(%eax),%eax
801083f8:	85 c0                	test   %eax,%eax
801083fa:	74 17                	je     80108413 <trap+0x1ee>
801083fc:	8b 45 08             	mov    0x8(%ebp),%eax
801083ff:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80108403:	0f b7 c0             	movzwl %ax,%eax
80108406:	83 e0 03             	and    $0x3,%eax
80108409:	83 f8 03             	cmp    $0x3,%eax
8010840c:	75 05                	jne    80108413 <trap+0x1ee>
    exit();
8010840e:	e8 a3 c8 ff ff       	call   80104cb6 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
80108413:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108419:	85 c0                	test   %eax,%eax
8010841b:	74 41                	je     8010845e <trap+0x239>
8010841d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108423:	8b 40 0c             	mov    0xc(%eax),%eax
80108426:	83 f8 04             	cmp    $0x4,%eax
80108429:	75 33                	jne    8010845e <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
8010842b:	8b 45 08             	mov    0x8(%ebp),%eax
8010842e:	8b 40 30             	mov    0x30(%eax),%eax
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
80108431:	83 f8 20             	cmp    $0x20,%eax
80108434:	75 28                	jne    8010845e <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
80108436:	8b 0d 20 79 11 80    	mov    0x80117920,%ecx
8010843c:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
80108441:	89 c8                	mov    %ecx,%eax
80108443:	f7 e2                	mul    %edx
80108445:	c1 ea 03             	shr    $0x3,%edx
80108448:	89 d0                	mov    %edx,%eax
8010844a:	c1 e0 02             	shl    $0x2,%eax
8010844d:	01 d0                	add    %edx,%eax
8010844f:	01 c0                	add    %eax,%eax
80108451:	29 c1                	sub    %eax,%ecx
80108453:	89 ca                	mov    %ecx,%edx
80108455:	85 d2                	test   %edx,%edx
80108457:	75 05                	jne    8010845e <trap+0x239>
    yield();
80108459:	e8 a4 cf ff ff       	call   80105402 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010845e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108464:	85 c0                	test   %eax,%eax
80108466:	74 27                	je     8010848f <trap+0x26a>
80108468:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010846e:	8b 40 24             	mov    0x24(%eax),%eax
80108471:	85 c0                	test   %eax,%eax
80108473:	74 1a                	je     8010848f <trap+0x26a>
80108475:	8b 45 08             	mov    0x8(%ebp),%eax
80108478:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010847c:	0f b7 c0             	movzwl %ax,%eax
8010847f:	83 e0 03             	and    $0x3,%eax
80108482:	83 f8 03             	cmp    $0x3,%eax
80108485:	75 08                	jne    8010848f <trap+0x26a>
    exit();
80108487:	e8 2a c8 ff ff       	call   80104cb6 <exit>
8010848c:	eb 01                	jmp    8010848f <trap+0x26a>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
8010848e:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
8010848f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108492:	5b                   	pop    %ebx
80108493:	5e                   	pop    %esi
80108494:	5f                   	pop    %edi
80108495:	5d                   	pop    %ebp
80108496:	c3                   	ret    

80108497 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80108497:	55                   	push   %ebp
80108498:	89 e5                	mov    %esp,%ebp
8010849a:	83 ec 14             	sub    $0x14,%esp
8010849d:	8b 45 08             	mov    0x8(%ebp),%eax
801084a0:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801084a4:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801084a8:	89 c2                	mov    %eax,%edx
801084aa:	ec                   	in     (%dx),%al
801084ab:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801084ae:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801084b2:	c9                   	leave  
801084b3:	c3                   	ret    

801084b4 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801084b4:	55                   	push   %ebp
801084b5:	89 e5                	mov    %esp,%ebp
801084b7:	83 ec 08             	sub    $0x8,%esp
801084ba:	8b 55 08             	mov    0x8(%ebp),%edx
801084bd:	8b 45 0c             	mov    0xc(%ebp),%eax
801084c0:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801084c4:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801084c7:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801084cb:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801084cf:	ee                   	out    %al,(%dx)
}
801084d0:	90                   	nop
801084d1:	c9                   	leave  
801084d2:	c3                   	ret    

801084d3 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801084d3:	55                   	push   %ebp
801084d4:	89 e5                	mov    %esp,%ebp
801084d6:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801084d9:	6a 00                	push   $0x0
801084db:	68 fa 03 00 00       	push   $0x3fa
801084e0:	e8 cf ff ff ff       	call   801084b4 <outb>
801084e5:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801084e8:	68 80 00 00 00       	push   $0x80
801084ed:	68 fb 03 00 00       	push   $0x3fb
801084f2:	e8 bd ff ff ff       	call   801084b4 <outb>
801084f7:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801084fa:	6a 0c                	push   $0xc
801084fc:	68 f8 03 00 00       	push   $0x3f8
80108501:	e8 ae ff ff ff       	call   801084b4 <outb>
80108506:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80108509:	6a 00                	push   $0x0
8010850b:	68 f9 03 00 00       	push   $0x3f9
80108510:	e8 9f ff ff ff       	call   801084b4 <outb>
80108515:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80108518:	6a 03                	push   $0x3
8010851a:	68 fb 03 00 00       	push   $0x3fb
8010851f:	e8 90 ff ff ff       	call   801084b4 <outb>
80108524:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80108527:	6a 00                	push   $0x0
80108529:	68 fc 03 00 00       	push   $0x3fc
8010852e:	e8 81 ff ff ff       	call   801084b4 <outb>
80108533:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80108536:	6a 01                	push   $0x1
80108538:	68 f9 03 00 00       	push   $0x3f9
8010853d:	e8 72 ff ff ff       	call   801084b4 <outb>
80108542:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80108545:	68 fd 03 00 00       	push   $0x3fd
8010854a:	e8 48 ff ff ff       	call   80108497 <inb>
8010854f:	83 c4 04             	add    $0x4,%esp
80108552:	3c ff                	cmp    $0xff,%al
80108554:	74 6e                	je     801085c4 <uartinit+0xf1>
    return;
  uart = 1;
80108556:	c7 05 6c d6 10 80 01 	movl   $0x1,0x8010d66c
8010855d:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80108560:	68 fa 03 00 00       	push   $0x3fa
80108565:	e8 2d ff ff ff       	call   80108497 <inb>
8010856a:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
8010856d:	68 f8 03 00 00       	push   $0x3f8
80108572:	e8 20 ff ff ff       	call   80108497 <inb>
80108577:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
8010857a:	83 ec 0c             	sub    $0xc,%esp
8010857d:	6a 04                	push   $0x4
8010857f:	e8 45 ba ff ff       	call   80103fc9 <picenable>
80108584:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80108587:	83 ec 08             	sub    $0x8,%esp
8010858a:	6a 00                	push   $0x0
8010858c:	6a 04                	push   $0x4
8010858e:	e8 e5 a5 ff ff       	call   80102b78 <ioapicenable>
80108593:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80108596:	c7 45 f4 ec a8 10 80 	movl   $0x8010a8ec,-0xc(%ebp)
8010859d:	eb 19                	jmp    801085b8 <uartinit+0xe5>
    uartputc(*p);
8010859f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a2:	0f b6 00             	movzbl (%eax),%eax
801085a5:	0f be c0             	movsbl %al,%eax
801085a8:	83 ec 0c             	sub    $0xc,%esp
801085ab:	50                   	push   %eax
801085ac:	e8 16 00 00 00       	call   801085c7 <uartputc>
801085b1:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801085b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801085b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085bb:	0f b6 00             	movzbl (%eax),%eax
801085be:	84 c0                	test   %al,%al
801085c0:	75 dd                	jne    8010859f <uartinit+0xcc>
801085c2:	eb 01                	jmp    801085c5 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
801085c4:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
801085c5:	c9                   	leave  
801085c6:	c3                   	ret    

801085c7 <uartputc>:

void
uartputc(int c)
{
801085c7:	55                   	push   %ebp
801085c8:	89 e5                	mov    %esp,%ebp
801085ca:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801085cd:	a1 6c d6 10 80       	mov    0x8010d66c,%eax
801085d2:	85 c0                	test   %eax,%eax
801085d4:	74 53                	je     80108629 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801085d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801085dd:	eb 11                	jmp    801085f0 <uartputc+0x29>
    microdelay(10);
801085df:	83 ec 0c             	sub    $0xc,%esp
801085e2:	6a 0a                	push   $0xa
801085e4:	e8 f5 aa ff ff       	call   801030de <microdelay>
801085e9:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801085ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801085f0:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801085f4:	7f 1a                	jg     80108610 <uartputc+0x49>
801085f6:	83 ec 0c             	sub    $0xc,%esp
801085f9:	68 fd 03 00 00       	push   $0x3fd
801085fe:	e8 94 fe ff ff       	call   80108497 <inb>
80108603:	83 c4 10             	add    $0x10,%esp
80108606:	0f b6 c0             	movzbl %al,%eax
80108609:	83 e0 20             	and    $0x20,%eax
8010860c:	85 c0                	test   %eax,%eax
8010860e:	74 cf                	je     801085df <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80108610:	8b 45 08             	mov    0x8(%ebp),%eax
80108613:	0f b6 c0             	movzbl %al,%eax
80108616:	83 ec 08             	sub    $0x8,%esp
80108619:	50                   	push   %eax
8010861a:	68 f8 03 00 00       	push   $0x3f8
8010861f:	e8 90 fe ff ff       	call   801084b4 <outb>
80108624:	83 c4 10             	add    $0x10,%esp
80108627:	eb 01                	jmp    8010862a <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80108629:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
8010862a:	c9                   	leave  
8010862b:	c3                   	ret    

8010862c <uartgetc>:

static int
uartgetc(void)
{
8010862c:	55                   	push   %ebp
8010862d:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010862f:	a1 6c d6 10 80       	mov    0x8010d66c,%eax
80108634:	85 c0                	test   %eax,%eax
80108636:	75 07                	jne    8010863f <uartgetc+0x13>
    return -1;
80108638:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010863d:	eb 2e                	jmp    8010866d <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
8010863f:	68 fd 03 00 00       	push   $0x3fd
80108644:	e8 4e fe ff ff       	call   80108497 <inb>
80108649:	83 c4 04             	add    $0x4,%esp
8010864c:	0f b6 c0             	movzbl %al,%eax
8010864f:	83 e0 01             	and    $0x1,%eax
80108652:	85 c0                	test   %eax,%eax
80108654:	75 07                	jne    8010865d <uartgetc+0x31>
    return -1;
80108656:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010865b:	eb 10                	jmp    8010866d <uartgetc+0x41>
  return inb(COM1+0);
8010865d:	68 f8 03 00 00       	push   $0x3f8
80108662:	e8 30 fe ff ff       	call   80108497 <inb>
80108667:	83 c4 04             	add    $0x4,%esp
8010866a:	0f b6 c0             	movzbl %al,%eax
}
8010866d:	c9                   	leave  
8010866e:	c3                   	ret    

8010866f <uartintr>:

void
uartintr(void)
{
8010866f:	55                   	push   %ebp
80108670:	89 e5                	mov    %esp,%ebp
80108672:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80108675:	83 ec 0c             	sub    $0xc,%esp
80108678:	68 2c 86 10 80       	push   $0x8010862c
8010867d:	e8 77 81 ff ff       	call   801007f9 <consoleintr>
80108682:	83 c4 10             	add    $0x10,%esp
}
80108685:	90                   	nop
80108686:	c9                   	leave  
80108687:	c3                   	ret    

80108688 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80108688:	6a 00                	push   $0x0
  pushl $0
8010868a:	6a 00                	push   $0x0
  jmp alltraps
8010868c:	e9 a9 f9 ff ff       	jmp    8010803a <alltraps>

80108691 <vector1>:
.globl vector1
vector1:
  pushl $0
80108691:	6a 00                	push   $0x0
  pushl $1
80108693:	6a 01                	push   $0x1
  jmp alltraps
80108695:	e9 a0 f9 ff ff       	jmp    8010803a <alltraps>

8010869a <vector2>:
.globl vector2
vector2:
  pushl $0
8010869a:	6a 00                	push   $0x0
  pushl $2
8010869c:	6a 02                	push   $0x2
  jmp alltraps
8010869e:	e9 97 f9 ff ff       	jmp    8010803a <alltraps>

801086a3 <vector3>:
.globl vector3
vector3:
  pushl $0
801086a3:	6a 00                	push   $0x0
  pushl $3
801086a5:	6a 03                	push   $0x3
  jmp alltraps
801086a7:	e9 8e f9 ff ff       	jmp    8010803a <alltraps>

801086ac <vector4>:
.globl vector4
vector4:
  pushl $0
801086ac:	6a 00                	push   $0x0
  pushl $4
801086ae:	6a 04                	push   $0x4
  jmp alltraps
801086b0:	e9 85 f9 ff ff       	jmp    8010803a <alltraps>

801086b5 <vector5>:
.globl vector5
vector5:
  pushl $0
801086b5:	6a 00                	push   $0x0
  pushl $5
801086b7:	6a 05                	push   $0x5
  jmp alltraps
801086b9:	e9 7c f9 ff ff       	jmp    8010803a <alltraps>

801086be <vector6>:
.globl vector6
vector6:
  pushl $0
801086be:	6a 00                	push   $0x0
  pushl $6
801086c0:	6a 06                	push   $0x6
  jmp alltraps
801086c2:	e9 73 f9 ff ff       	jmp    8010803a <alltraps>

801086c7 <vector7>:
.globl vector7
vector7:
  pushl $0
801086c7:	6a 00                	push   $0x0
  pushl $7
801086c9:	6a 07                	push   $0x7
  jmp alltraps
801086cb:	e9 6a f9 ff ff       	jmp    8010803a <alltraps>

801086d0 <vector8>:
.globl vector8
vector8:
  pushl $8
801086d0:	6a 08                	push   $0x8
  jmp alltraps
801086d2:	e9 63 f9 ff ff       	jmp    8010803a <alltraps>

801086d7 <vector9>:
.globl vector9
vector9:
  pushl $0
801086d7:	6a 00                	push   $0x0
  pushl $9
801086d9:	6a 09                	push   $0x9
  jmp alltraps
801086db:	e9 5a f9 ff ff       	jmp    8010803a <alltraps>

801086e0 <vector10>:
.globl vector10
vector10:
  pushl $10
801086e0:	6a 0a                	push   $0xa
  jmp alltraps
801086e2:	e9 53 f9 ff ff       	jmp    8010803a <alltraps>

801086e7 <vector11>:
.globl vector11
vector11:
  pushl $11
801086e7:	6a 0b                	push   $0xb
  jmp alltraps
801086e9:	e9 4c f9 ff ff       	jmp    8010803a <alltraps>

801086ee <vector12>:
.globl vector12
vector12:
  pushl $12
801086ee:	6a 0c                	push   $0xc
  jmp alltraps
801086f0:	e9 45 f9 ff ff       	jmp    8010803a <alltraps>

801086f5 <vector13>:
.globl vector13
vector13:
  pushl $13
801086f5:	6a 0d                	push   $0xd
  jmp alltraps
801086f7:	e9 3e f9 ff ff       	jmp    8010803a <alltraps>

801086fc <vector14>:
.globl vector14
vector14:
  pushl $14
801086fc:	6a 0e                	push   $0xe
  jmp alltraps
801086fe:	e9 37 f9 ff ff       	jmp    8010803a <alltraps>

80108703 <vector15>:
.globl vector15
vector15:
  pushl $0
80108703:	6a 00                	push   $0x0
  pushl $15
80108705:	6a 0f                	push   $0xf
  jmp alltraps
80108707:	e9 2e f9 ff ff       	jmp    8010803a <alltraps>

8010870c <vector16>:
.globl vector16
vector16:
  pushl $0
8010870c:	6a 00                	push   $0x0
  pushl $16
8010870e:	6a 10                	push   $0x10
  jmp alltraps
80108710:	e9 25 f9 ff ff       	jmp    8010803a <alltraps>

80108715 <vector17>:
.globl vector17
vector17:
  pushl $17
80108715:	6a 11                	push   $0x11
  jmp alltraps
80108717:	e9 1e f9 ff ff       	jmp    8010803a <alltraps>

8010871c <vector18>:
.globl vector18
vector18:
  pushl $0
8010871c:	6a 00                	push   $0x0
  pushl $18
8010871e:	6a 12                	push   $0x12
  jmp alltraps
80108720:	e9 15 f9 ff ff       	jmp    8010803a <alltraps>

80108725 <vector19>:
.globl vector19
vector19:
  pushl $0
80108725:	6a 00                	push   $0x0
  pushl $19
80108727:	6a 13                	push   $0x13
  jmp alltraps
80108729:	e9 0c f9 ff ff       	jmp    8010803a <alltraps>

8010872e <vector20>:
.globl vector20
vector20:
  pushl $0
8010872e:	6a 00                	push   $0x0
  pushl $20
80108730:	6a 14                	push   $0x14
  jmp alltraps
80108732:	e9 03 f9 ff ff       	jmp    8010803a <alltraps>

80108737 <vector21>:
.globl vector21
vector21:
  pushl $0
80108737:	6a 00                	push   $0x0
  pushl $21
80108739:	6a 15                	push   $0x15
  jmp alltraps
8010873b:	e9 fa f8 ff ff       	jmp    8010803a <alltraps>

80108740 <vector22>:
.globl vector22
vector22:
  pushl $0
80108740:	6a 00                	push   $0x0
  pushl $22
80108742:	6a 16                	push   $0x16
  jmp alltraps
80108744:	e9 f1 f8 ff ff       	jmp    8010803a <alltraps>

80108749 <vector23>:
.globl vector23
vector23:
  pushl $0
80108749:	6a 00                	push   $0x0
  pushl $23
8010874b:	6a 17                	push   $0x17
  jmp alltraps
8010874d:	e9 e8 f8 ff ff       	jmp    8010803a <alltraps>

80108752 <vector24>:
.globl vector24
vector24:
  pushl $0
80108752:	6a 00                	push   $0x0
  pushl $24
80108754:	6a 18                	push   $0x18
  jmp alltraps
80108756:	e9 df f8 ff ff       	jmp    8010803a <alltraps>

8010875b <vector25>:
.globl vector25
vector25:
  pushl $0
8010875b:	6a 00                	push   $0x0
  pushl $25
8010875d:	6a 19                	push   $0x19
  jmp alltraps
8010875f:	e9 d6 f8 ff ff       	jmp    8010803a <alltraps>

80108764 <vector26>:
.globl vector26
vector26:
  pushl $0
80108764:	6a 00                	push   $0x0
  pushl $26
80108766:	6a 1a                	push   $0x1a
  jmp alltraps
80108768:	e9 cd f8 ff ff       	jmp    8010803a <alltraps>

8010876d <vector27>:
.globl vector27
vector27:
  pushl $0
8010876d:	6a 00                	push   $0x0
  pushl $27
8010876f:	6a 1b                	push   $0x1b
  jmp alltraps
80108771:	e9 c4 f8 ff ff       	jmp    8010803a <alltraps>

80108776 <vector28>:
.globl vector28
vector28:
  pushl $0
80108776:	6a 00                	push   $0x0
  pushl $28
80108778:	6a 1c                	push   $0x1c
  jmp alltraps
8010877a:	e9 bb f8 ff ff       	jmp    8010803a <alltraps>

8010877f <vector29>:
.globl vector29
vector29:
  pushl $0
8010877f:	6a 00                	push   $0x0
  pushl $29
80108781:	6a 1d                	push   $0x1d
  jmp alltraps
80108783:	e9 b2 f8 ff ff       	jmp    8010803a <alltraps>

80108788 <vector30>:
.globl vector30
vector30:
  pushl $0
80108788:	6a 00                	push   $0x0
  pushl $30
8010878a:	6a 1e                	push   $0x1e
  jmp alltraps
8010878c:	e9 a9 f8 ff ff       	jmp    8010803a <alltraps>

80108791 <vector31>:
.globl vector31
vector31:
  pushl $0
80108791:	6a 00                	push   $0x0
  pushl $31
80108793:	6a 1f                	push   $0x1f
  jmp alltraps
80108795:	e9 a0 f8 ff ff       	jmp    8010803a <alltraps>

8010879a <vector32>:
.globl vector32
vector32:
  pushl $0
8010879a:	6a 00                	push   $0x0
  pushl $32
8010879c:	6a 20                	push   $0x20
  jmp alltraps
8010879e:	e9 97 f8 ff ff       	jmp    8010803a <alltraps>

801087a3 <vector33>:
.globl vector33
vector33:
  pushl $0
801087a3:	6a 00                	push   $0x0
  pushl $33
801087a5:	6a 21                	push   $0x21
  jmp alltraps
801087a7:	e9 8e f8 ff ff       	jmp    8010803a <alltraps>

801087ac <vector34>:
.globl vector34
vector34:
  pushl $0
801087ac:	6a 00                	push   $0x0
  pushl $34
801087ae:	6a 22                	push   $0x22
  jmp alltraps
801087b0:	e9 85 f8 ff ff       	jmp    8010803a <alltraps>

801087b5 <vector35>:
.globl vector35
vector35:
  pushl $0
801087b5:	6a 00                	push   $0x0
  pushl $35
801087b7:	6a 23                	push   $0x23
  jmp alltraps
801087b9:	e9 7c f8 ff ff       	jmp    8010803a <alltraps>

801087be <vector36>:
.globl vector36
vector36:
  pushl $0
801087be:	6a 00                	push   $0x0
  pushl $36
801087c0:	6a 24                	push   $0x24
  jmp alltraps
801087c2:	e9 73 f8 ff ff       	jmp    8010803a <alltraps>

801087c7 <vector37>:
.globl vector37
vector37:
  pushl $0
801087c7:	6a 00                	push   $0x0
  pushl $37
801087c9:	6a 25                	push   $0x25
  jmp alltraps
801087cb:	e9 6a f8 ff ff       	jmp    8010803a <alltraps>

801087d0 <vector38>:
.globl vector38
vector38:
  pushl $0
801087d0:	6a 00                	push   $0x0
  pushl $38
801087d2:	6a 26                	push   $0x26
  jmp alltraps
801087d4:	e9 61 f8 ff ff       	jmp    8010803a <alltraps>

801087d9 <vector39>:
.globl vector39
vector39:
  pushl $0
801087d9:	6a 00                	push   $0x0
  pushl $39
801087db:	6a 27                	push   $0x27
  jmp alltraps
801087dd:	e9 58 f8 ff ff       	jmp    8010803a <alltraps>

801087e2 <vector40>:
.globl vector40
vector40:
  pushl $0
801087e2:	6a 00                	push   $0x0
  pushl $40
801087e4:	6a 28                	push   $0x28
  jmp alltraps
801087e6:	e9 4f f8 ff ff       	jmp    8010803a <alltraps>

801087eb <vector41>:
.globl vector41
vector41:
  pushl $0
801087eb:	6a 00                	push   $0x0
  pushl $41
801087ed:	6a 29                	push   $0x29
  jmp alltraps
801087ef:	e9 46 f8 ff ff       	jmp    8010803a <alltraps>

801087f4 <vector42>:
.globl vector42
vector42:
  pushl $0
801087f4:	6a 00                	push   $0x0
  pushl $42
801087f6:	6a 2a                	push   $0x2a
  jmp alltraps
801087f8:	e9 3d f8 ff ff       	jmp    8010803a <alltraps>

801087fd <vector43>:
.globl vector43
vector43:
  pushl $0
801087fd:	6a 00                	push   $0x0
  pushl $43
801087ff:	6a 2b                	push   $0x2b
  jmp alltraps
80108801:	e9 34 f8 ff ff       	jmp    8010803a <alltraps>

80108806 <vector44>:
.globl vector44
vector44:
  pushl $0
80108806:	6a 00                	push   $0x0
  pushl $44
80108808:	6a 2c                	push   $0x2c
  jmp alltraps
8010880a:	e9 2b f8 ff ff       	jmp    8010803a <alltraps>

8010880f <vector45>:
.globl vector45
vector45:
  pushl $0
8010880f:	6a 00                	push   $0x0
  pushl $45
80108811:	6a 2d                	push   $0x2d
  jmp alltraps
80108813:	e9 22 f8 ff ff       	jmp    8010803a <alltraps>

80108818 <vector46>:
.globl vector46
vector46:
  pushl $0
80108818:	6a 00                	push   $0x0
  pushl $46
8010881a:	6a 2e                	push   $0x2e
  jmp alltraps
8010881c:	e9 19 f8 ff ff       	jmp    8010803a <alltraps>

80108821 <vector47>:
.globl vector47
vector47:
  pushl $0
80108821:	6a 00                	push   $0x0
  pushl $47
80108823:	6a 2f                	push   $0x2f
  jmp alltraps
80108825:	e9 10 f8 ff ff       	jmp    8010803a <alltraps>

8010882a <vector48>:
.globl vector48
vector48:
  pushl $0
8010882a:	6a 00                	push   $0x0
  pushl $48
8010882c:	6a 30                	push   $0x30
  jmp alltraps
8010882e:	e9 07 f8 ff ff       	jmp    8010803a <alltraps>

80108833 <vector49>:
.globl vector49
vector49:
  pushl $0
80108833:	6a 00                	push   $0x0
  pushl $49
80108835:	6a 31                	push   $0x31
  jmp alltraps
80108837:	e9 fe f7 ff ff       	jmp    8010803a <alltraps>

8010883c <vector50>:
.globl vector50
vector50:
  pushl $0
8010883c:	6a 00                	push   $0x0
  pushl $50
8010883e:	6a 32                	push   $0x32
  jmp alltraps
80108840:	e9 f5 f7 ff ff       	jmp    8010803a <alltraps>

80108845 <vector51>:
.globl vector51
vector51:
  pushl $0
80108845:	6a 00                	push   $0x0
  pushl $51
80108847:	6a 33                	push   $0x33
  jmp alltraps
80108849:	e9 ec f7 ff ff       	jmp    8010803a <alltraps>

8010884e <vector52>:
.globl vector52
vector52:
  pushl $0
8010884e:	6a 00                	push   $0x0
  pushl $52
80108850:	6a 34                	push   $0x34
  jmp alltraps
80108852:	e9 e3 f7 ff ff       	jmp    8010803a <alltraps>

80108857 <vector53>:
.globl vector53
vector53:
  pushl $0
80108857:	6a 00                	push   $0x0
  pushl $53
80108859:	6a 35                	push   $0x35
  jmp alltraps
8010885b:	e9 da f7 ff ff       	jmp    8010803a <alltraps>

80108860 <vector54>:
.globl vector54
vector54:
  pushl $0
80108860:	6a 00                	push   $0x0
  pushl $54
80108862:	6a 36                	push   $0x36
  jmp alltraps
80108864:	e9 d1 f7 ff ff       	jmp    8010803a <alltraps>

80108869 <vector55>:
.globl vector55
vector55:
  pushl $0
80108869:	6a 00                	push   $0x0
  pushl $55
8010886b:	6a 37                	push   $0x37
  jmp alltraps
8010886d:	e9 c8 f7 ff ff       	jmp    8010803a <alltraps>

80108872 <vector56>:
.globl vector56
vector56:
  pushl $0
80108872:	6a 00                	push   $0x0
  pushl $56
80108874:	6a 38                	push   $0x38
  jmp alltraps
80108876:	e9 bf f7 ff ff       	jmp    8010803a <alltraps>

8010887b <vector57>:
.globl vector57
vector57:
  pushl $0
8010887b:	6a 00                	push   $0x0
  pushl $57
8010887d:	6a 39                	push   $0x39
  jmp alltraps
8010887f:	e9 b6 f7 ff ff       	jmp    8010803a <alltraps>

80108884 <vector58>:
.globl vector58
vector58:
  pushl $0
80108884:	6a 00                	push   $0x0
  pushl $58
80108886:	6a 3a                	push   $0x3a
  jmp alltraps
80108888:	e9 ad f7 ff ff       	jmp    8010803a <alltraps>

8010888d <vector59>:
.globl vector59
vector59:
  pushl $0
8010888d:	6a 00                	push   $0x0
  pushl $59
8010888f:	6a 3b                	push   $0x3b
  jmp alltraps
80108891:	e9 a4 f7 ff ff       	jmp    8010803a <alltraps>

80108896 <vector60>:
.globl vector60
vector60:
  pushl $0
80108896:	6a 00                	push   $0x0
  pushl $60
80108898:	6a 3c                	push   $0x3c
  jmp alltraps
8010889a:	e9 9b f7 ff ff       	jmp    8010803a <alltraps>

8010889f <vector61>:
.globl vector61
vector61:
  pushl $0
8010889f:	6a 00                	push   $0x0
  pushl $61
801088a1:	6a 3d                	push   $0x3d
  jmp alltraps
801088a3:	e9 92 f7 ff ff       	jmp    8010803a <alltraps>

801088a8 <vector62>:
.globl vector62
vector62:
  pushl $0
801088a8:	6a 00                	push   $0x0
  pushl $62
801088aa:	6a 3e                	push   $0x3e
  jmp alltraps
801088ac:	e9 89 f7 ff ff       	jmp    8010803a <alltraps>

801088b1 <vector63>:
.globl vector63
vector63:
  pushl $0
801088b1:	6a 00                	push   $0x0
  pushl $63
801088b3:	6a 3f                	push   $0x3f
  jmp alltraps
801088b5:	e9 80 f7 ff ff       	jmp    8010803a <alltraps>

801088ba <vector64>:
.globl vector64
vector64:
  pushl $0
801088ba:	6a 00                	push   $0x0
  pushl $64
801088bc:	6a 40                	push   $0x40
  jmp alltraps
801088be:	e9 77 f7 ff ff       	jmp    8010803a <alltraps>

801088c3 <vector65>:
.globl vector65
vector65:
  pushl $0
801088c3:	6a 00                	push   $0x0
  pushl $65
801088c5:	6a 41                	push   $0x41
  jmp alltraps
801088c7:	e9 6e f7 ff ff       	jmp    8010803a <alltraps>

801088cc <vector66>:
.globl vector66
vector66:
  pushl $0
801088cc:	6a 00                	push   $0x0
  pushl $66
801088ce:	6a 42                	push   $0x42
  jmp alltraps
801088d0:	e9 65 f7 ff ff       	jmp    8010803a <alltraps>

801088d5 <vector67>:
.globl vector67
vector67:
  pushl $0
801088d5:	6a 00                	push   $0x0
  pushl $67
801088d7:	6a 43                	push   $0x43
  jmp alltraps
801088d9:	e9 5c f7 ff ff       	jmp    8010803a <alltraps>

801088de <vector68>:
.globl vector68
vector68:
  pushl $0
801088de:	6a 00                	push   $0x0
  pushl $68
801088e0:	6a 44                	push   $0x44
  jmp alltraps
801088e2:	e9 53 f7 ff ff       	jmp    8010803a <alltraps>

801088e7 <vector69>:
.globl vector69
vector69:
  pushl $0
801088e7:	6a 00                	push   $0x0
  pushl $69
801088e9:	6a 45                	push   $0x45
  jmp alltraps
801088eb:	e9 4a f7 ff ff       	jmp    8010803a <alltraps>

801088f0 <vector70>:
.globl vector70
vector70:
  pushl $0
801088f0:	6a 00                	push   $0x0
  pushl $70
801088f2:	6a 46                	push   $0x46
  jmp alltraps
801088f4:	e9 41 f7 ff ff       	jmp    8010803a <alltraps>

801088f9 <vector71>:
.globl vector71
vector71:
  pushl $0
801088f9:	6a 00                	push   $0x0
  pushl $71
801088fb:	6a 47                	push   $0x47
  jmp alltraps
801088fd:	e9 38 f7 ff ff       	jmp    8010803a <alltraps>

80108902 <vector72>:
.globl vector72
vector72:
  pushl $0
80108902:	6a 00                	push   $0x0
  pushl $72
80108904:	6a 48                	push   $0x48
  jmp alltraps
80108906:	e9 2f f7 ff ff       	jmp    8010803a <alltraps>

8010890b <vector73>:
.globl vector73
vector73:
  pushl $0
8010890b:	6a 00                	push   $0x0
  pushl $73
8010890d:	6a 49                	push   $0x49
  jmp alltraps
8010890f:	e9 26 f7 ff ff       	jmp    8010803a <alltraps>

80108914 <vector74>:
.globl vector74
vector74:
  pushl $0
80108914:	6a 00                	push   $0x0
  pushl $74
80108916:	6a 4a                	push   $0x4a
  jmp alltraps
80108918:	e9 1d f7 ff ff       	jmp    8010803a <alltraps>

8010891d <vector75>:
.globl vector75
vector75:
  pushl $0
8010891d:	6a 00                	push   $0x0
  pushl $75
8010891f:	6a 4b                	push   $0x4b
  jmp alltraps
80108921:	e9 14 f7 ff ff       	jmp    8010803a <alltraps>

80108926 <vector76>:
.globl vector76
vector76:
  pushl $0
80108926:	6a 00                	push   $0x0
  pushl $76
80108928:	6a 4c                	push   $0x4c
  jmp alltraps
8010892a:	e9 0b f7 ff ff       	jmp    8010803a <alltraps>

8010892f <vector77>:
.globl vector77
vector77:
  pushl $0
8010892f:	6a 00                	push   $0x0
  pushl $77
80108931:	6a 4d                	push   $0x4d
  jmp alltraps
80108933:	e9 02 f7 ff ff       	jmp    8010803a <alltraps>

80108938 <vector78>:
.globl vector78
vector78:
  pushl $0
80108938:	6a 00                	push   $0x0
  pushl $78
8010893a:	6a 4e                	push   $0x4e
  jmp alltraps
8010893c:	e9 f9 f6 ff ff       	jmp    8010803a <alltraps>

80108941 <vector79>:
.globl vector79
vector79:
  pushl $0
80108941:	6a 00                	push   $0x0
  pushl $79
80108943:	6a 4f                	push   $0x4f
  jmp alltraps
80108945:	e9 f0 f6 ff ff       	jmp    8010803a <alltraps>

8010894a <vector80>:
.globl vector80
vector80:
  pushl $0
8010894a:	6a 00                	push   $0x0
  pushl $80
8010894c:	6a 50                	push   $0x50
  jmp alltraps
8010894e:	e9 e7 f6 ff ff       	jmp    8010803a <alltraps>

80108953 <vector81>:
.globl vector81
vector81:
  pushl $0
80108953:	6a 00                	push   $0x0
  pushl $81
80108955:	6a 51                	push   $0x51
  jmp alltraps
80108957:	e9 de f6 ff ff       	jmp    8010803a <alltraps>

8010895c <vector82>:
.globl vector82
vector82:
  pushl $0
8010895c:	6a 00                	push   $0x0
  pushl $82
8010895e:	6a 52                	push   $0x52
  jmp alltraps
80108960:	e9 d5 f6 ff ff       	jmp    8010803a <alltraps>

80108965 <vector83>:
.globl vector83
vector83:
  pushl $0
80108965:	6a 00                	push   $0x0
  pushl $83
80108967:	6a 53                	push   $0x53
  jmp alltraps
80108969:	e9 cc f6 ff ff       	jmp    8010803a <alltraps>

8010896e <vector84>:
.globl vector84
vector84:
  pushl $0
8010896e:	6a 00                	push   $0x0
  pushl $84
80108970:	6a 54                	push   $0x54
  jmp alltraps
80108972:	e9 c3 f6 ff ff       	jmp    8010803a <alltraps>

80108977 <vector85>:
.globl vector85
vector85:
  pushl $0
80108977:	6a 00                	push   $0x0
  pushl $85
80108979:	6a 55                	push   $0x55
  jmp alltraps
8010897b:	e9 ba f6 ff ff       	jmp    8010803a <alltraps>

80108980 <vector86>:
.globl vector86
vector86:
  pushl $0
80108980:	6a 00                	push   $0x0
  pushl $86
80108982:	6a 56                	push   $0x56
  jmp alltraps
80108984:	e9 b1 f6 ff ff       	jmp    8010803a <alltraps>

80108989 <vector87>:
.globl vector87
vector87:
  pushl $0
80108989:	6a 00                	push   $0x0
  pushl $87
8010898b:	6a 57                	push   $0x57
  jmp alltraps
8010898d:	e9 a8 f6 ff ff       	jmp    8010803a <alltraps>

80108992 <vector88>:
.globl vector88
vector88:
  pushl $0
80108992:	6a 00                	push   $0x0
  pushl $88
80108994:	6a 58                	push   $0x58
  jmp alltraps
80108996:	e9 9f f6 ff ff       	jmp    8010803a <alltraps>

8010899b <vector89>:
.globl vector89
vector89:
  pushl $0
8010899b:	6a 00                	push   $0x0
  pushl $89
8010899d:	6a 59                	push   $0x59
  jmp alltraps
8010899f:	e9 96 f6 ff ff       	jmp    8010803a <alltraps>

801089a4 <vector90>:
.globl vector90
vector90:
  pushl $0
801089a4:	6a 00                	push   $0x0
  pushl $90
801089a6:	6a 5a                	push   $0x5a
  jmp alltraps
801089a8:	e9 8d f6 ff ff       	jmp    8010803a <alltraps>

801089ad <vector91>:
.globl vector91
vector91:
  pushl $0
801089ad:	6a 00                	push   $0x0
  pushl $91
801089af:	6a 5b                	push   $0x5b
  jmp alltraps
801089b1:	e9 84 f6 ff ff       	jmp    8010803a <alltraps>

801089b6 <vector92>:
.globl vector92
vector92:
  pushl $0
801089b6:	6a 00                	push   $0x0
  pushl $92
801089b8:	6a 5c                	push   $0x5c
  jmp alltraps
801089ba:	e9 7b f6 ff ff       	jmp    8010803a <alltraps>

801089bf <vector93>:
.globl vector93
vector93:
  pushl $0
801089bf:	6a 00                	push   $0x0
  pushl $93
801089c1:	6a 5d                	push   $0x5d
  jmp alltraps
801089c3:	e9 72 f6 ff ff       	jmp    8010803a <alltraps>

801089c8 <vector94>:
.globl vector94
vector94:
  pushl $0
801089c8:	6a 00                	push   $0x0
  pushl $94
801089ca:	6a 5e                	push   $0x5e
  jmp alltraps
801089cc:	e9 69 f6 ff ff       	jmp    8010803a <alltraps>

801089d1 <vector95>:
.globl vector95
vector95:
  pushl $0
801089d1:	6a 00                	push   $0x0
  pushl $95
801089d3:	6a 5f                	push   $0x5f
  jmp alltraps
801089d5:	e9 60 f6 ff ff       	jmp    8010803a <alltraps>

801089da <vector96>:
.globl vector96
vector96:
  pushl $0
801089da:	6a 00                	push   $0x0
  pushl $96
801089dc:	6a 60                	push   $0x60
  jmp alltraps
801089de:	e9 57 f6 ff ff       	jmp    8010803a <alltraps>

801089e3 <vector97>:
.globl vector97
vector97:
  pushl $0
801089e3:	6a 00                	push   $0x0
  pushl $97
801089e5:	6a 61                	push   $0x61
  jmp alltraps
801089e7:	e9 4e f6 ff ff       	jmp    8010803a <alltraps>

801089ec <vector98>:
.globl vector98
vector98:
  pushl $0
801089ec:	6a 00                	push   $0x0
  pushl $98
801089ee:	6a 62                	push   $0x62
  jmp alltraps
801089f0:	e9 45 f6 ff ff       	jmp    8010803a <alltraps>

801089f5 <vector99>:
.globl vector99
vector99:
  pushl $0
801089f5:	6a 00                	push   $0x0
  pushl $99
801089f7:	6a 63                	push   $0x63
  jmp alltraps
801089f9:	e9 3c f6 ff ff       	jmp    8010803a <alltraps>

801089fe <vector100>:
.globl vector100
vector100:
  pushl $0
801089fe:	6a 00                	push   $0x0
  pushl $100
80108a00:	6a 64                	push   $0x64
  jmp alltraps
80108a02:	e9 33 f6 ff ff       	jmp    8010803a <alltraps>

80108a07 <vector101>:
.globl vector101
vector101:
  pushl $0
80108a07:	6a 00                	push   $0x0
  pushl $101
80108a09:	6a 65                	push   $0x65
  jmp alltraps
80108a0b:	e9 2a f6 ff ff       	jmp    8010803a <alltraps>

80108a10 <vector102>:
.globl vector102
vector102:
  pushl $0
80108a10:	6a 00                	push   $0x0
  pushl $102
80108a12:	6a 66                	push   $0x66
  jmp alltraps
80108a14:	e9 21 f6 ff ff       	jmp    8010803a <alltraps>

80108a19 <vector103>:
.globl vector103
vector103:
  pushl $0
80108a19:	6a 00                	push   $0x0
  pushl $103
80108a1b:	6a 67                	push   $0x67
  jmp alltraps
80108a1d:	e9 18 f6 ff ff       	jmp    8010803a <alltraps>

80108a22 <vector104>:
.globl vector104
vector104:
  pushl $0
80108a22:	6a 00                	push   $0x0
  pushl $104
80108a24:	6a 68                	push   $0x68
  jmp alltraps
80108a26:	e9 0f f6 ff ff       	jmp    8010803a <alltraps>

80108a2b <vector105>:
.globl vector105
vector105:
  pushl $0
80108a2b:	6a 00                	push   $0x0
  pushl $105
80108a2d:	6a 69                	push   $0x69
  jmp alltraps
80108a2f:	e9 06 f6 ff ff       	jmp    8010803a <alltraps>

80108a34 <vector106>:
.globl vector106
vector106:
  pushl $0
80108a34:	6a 00                	push   $0x0
  pushl $106
80108a36:	6a 6a                	push   $0x6a
  jmp alltraps
80108a38:	e9 fd f5 ff ff       	jmp    8010803a <alltraps>

80108a3d <vector107>:
.globl vector107
vector107:
  pushl $0
80108a3d:	6a 00                	push   $0x0
  pushl $107
80108a3f:	6a 6b                	push   $0x6b
  jmp alltraps
80108a41:	e9 f4 f5 ff ff       	jmp    8010803a <alltraps>

80108a46 <vector108>:
.globl vector108
vector108:
  pushl $0
80108a46:	6a 00                	push   $0x0
  pushl $108
80108a48:	6a 6c                	push   $0x6c
  jmp alltraps
80108a4a:	e9 eb f5 ff ff       	jmp    8010803a <alltraps>

80108a4f <vector109>:
.globl vector109
vector109:
  pushl $0
80108a4f:	6a 00                	push   $0x0
  pushl $109
80108a51:	6a 6d                	push   $0x6d
  jmp alltraps
80108a53:	e9 e2 f5 ff ff       	jmp    8010803a <alltraps>

80108a58 <vector110>:
.globl vector110
vector110:
  pushl $0
80108a58:	6a 00                	push   $0x0
  pushl $110
80108a5a:	6a 6e                	push   $0x6e
  jmp alltraps
80108a5c:	e9 d9 f5 ff ff       	jmp    8010803a <alltraps>

80108a61 <vector111>:
.globl vector111
vector111:
  pushl $0
80108a61:	6a 00                	push   $0x0
  pushl $111
80108a63:	6a 6f                	push   $0x6f
  jmp alltraps
80108a65:	e9 d0 f5 ff ff       	jmp    8010803a <alltraps>

80108a6a <vector112>:
.globl vector112
vector112:
  pushl $0
80108a6a:	6a 00                	push   $0x0
  pushl $112
80108a6c:	6a 70                	push   $0x70
  jmp alltraps
80108a6e:	e9 c7 f5 ff ff       	jmp    8010803a <alltraps>

80108a73 <vector113>:
.globl vector113
vector113:
  pushl $0
80108a73:	6a 00                	push   $0x0
  pushl $113
80108a75:	6a 71                	push   $0x71
  jmp alltraps
80108a77:	e9 be f5 ff ff       	jmp    8010803a <alltraps>

80108a7c <vector114>:
.globl vector114
vector114:
  pushl $0
80108a7c:	6a 00                	push   $0x0
  pushl $114
80108a7e:	6a 72                	push   $0x72
  jmp alltraps
80108a80:	e9 b5 f5 ff ff       	jmp    8010803a <alltraps>

80108a85 <vector115>:
.globl vector115
vector115:
  pushl $0
80108a85:	6a 00                	push   $0x0
  pushl $115
80108a87:	6a 73                	push   $0x73
  jmp alltraps
80108a89:	e9 ac f5 ff ff       	jmp    8010803a <alltraps>

80108a8e <vector116>:
.globl vector116
vector116:
  pushl $0
80108a8e:	6a 00                	push   $0x0
  pushl $116
80108a90:	6a 74                	push   $0x74
  jmp alltraps
80108a92:	e9 a3 f5 ff ff       	jmp    8010803a <alltraps>

80108a97 <vector117>:
.globl vector117
vector117:
  pushl $0
80108a97:	6a 00                	push   $0x0
  pushl $117
80108a99:	6a 75                	push   $0x75
  jmp alltraps
80108a9b:	e9 9a f5 ff ff       	jmp    8010803a <alltraps>

80108aa0 <vector118>:
.globl vector118
vector118:
  pushl $0
80108aa0:	6a 00                	push   $0x0
  pushl $118
80108aa2:	6a 76                	push   $0x76
  jmp alltraps
80108aa4:	e9 91 f5 ff ff       	jmp    8010803a <alltraps>

80108aa9 <vector119>:
.globl vector119
vector119:
  pushl $0
80108aa9:	6a 00                	push   $0x0
  pushl $119
80108aab:	6a 77                	push   $0x77
  jmp alltraps
80108aad:	e9 88 f5 ff ff       	jmp    8010803a <alltraps>

80108ab2 <vector120>:
.globl vector120
vector120:
  pushl $0
80108ab2:	6a 00                	push   $0x0
  pushl $120
80108ab4:	6a 78                	push   $0x78
  jmp alltraps
80108ab6:	e9 7f f5 ff ff       	jmp    8010803a <alltraps>

80108abb <vector121>:
.globl vector121
vector121:
  pushl $0
80108abb:	6a 00                	push   $0x0
  pushl $121
80108abd:	6a 79                	push   $0x79
  jmp alltraps
80108abf:	e9 76 f5 ff ff       	jmp    8010803a <alltraps>

80108ac4 <vector122>:
.globl vector122
vector122:
  pushl $0
80108ac4:	6a 00                	push   $0x0
  pushl $122
80108ac6:	6a 7a                	push   $0x7a
  jmp alltraps
80108ac8:	e9 6d f5 ff ff       	jmp    8010803a <alltraps>

80108acd <vector123>:
.globl vector123
vector123:
  pushl $0
80108acd:	6a 00                	push   $0x0
  pushl $123
80108acf:	6a 7b                	push   $0x7b
  jmp alltraps
80108ad1:	e9 64 f5 ff ff       	jmp    8010803a <alltraps>

80108ad6 <vector124>:
.globl vector124
vector124:
  pushl $0
80108ad6:	6a 00                	push   $0x0
  pushl $124
80108ad8:	6a 7c                	push   $0x7c
  jmp alltraps
80108ada:	e9 5b f5 ff ff       	jmp    8010803a <alltraps>

80108adf <vector125>:
.globl vector125
vector125:
  pushl $0
80108adf:	6a 00                	push   $0x0
  pushl $125
80108ae1:	6a 7d                	push   $0x7d
  jmp alltraps
80108ae3:	e9 52 f5 ff ff       	jmp    8010803a <alltraps>

80108ae8 <vector126>:
.globl vector126
vector126:
  pushl $0
80108ae8:	6a 00                	push   $0x0
  pushl $126
80108aea:	6a 7e                	push   $0x7e
  jmp alltraps
80108aec:	e9 49 f5 ff ff       	jmp    8010803a <alltraps>

80108af1 <vector127>:
.globl vector127
vector127:
  pushl $0
80108af1:	6a 00                	push   $0x0
  pushl $127
80108af3:	6a 7f                	push   $0x7f
  jmp alltraps
80108af5:	e9 40 f5 ff ff       	jmp    8010803a <alltraps>

80108afa <vector128>:
.globl vector128
vector128:
  pushl $0
80108afa:	6a 00                	push   $0x0
  pushl $128
80108afc:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80108b01:	e9 34 f5 ff ff       	jmp    8010803a <alltraps>

80108b06 <vector129>:
.globl vector129
vector129:
  pushl $0
80108b06:	6a 00                	push   $0x0
  pushl $129
80108b08:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80108b0d:	e9 28 f5 ff ff       	jmp    8010803a <alltraps>

80108b12 <vector130>:
.globl vector130
vector130:
  pushl $0
80108b12:	6a 00                	push   $0x0
  pushl $130
80108b14:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80108b19:	e9 1c f5 ff ff       	jmp    8010803a <alltraps>

80108b1e <vector131>:
.globl vector131
vector131:
  pushl $0
80108b1e:	6a 00                	push   $0x0
  pushl $131
80108b20:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80108b25:	e9 10 f5 ff ff       	jmp    8010803a <alltraps>

80108b2a <vector132>:
.globl vector132
vector132:
  pushl $0
80108b2a:	6a 00                	push   $0x0
  pushl $132
80108b2c:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80108b31:	e9 04 f5 ff ff       	jmp    8010803a <alltraps>

80108b36 <vector133>:
.globl vector133
vector133:
  pushl $0
80108b36:	6a 00                	push   $0x0
  pushl $133
80108b38:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80108b3d:	e9 f8 f4 ff ff       	jmp    8010803a <alltraps>

80108b42 <vector134>:
.globl vector134
vector134:
  pushl $0
80108b42:	6a 00                	push   $0x0
  pushl $134
80108b44:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80108b49:	e9 ec f4 ff ff       	jmp    8010803a <alltraps>

80108b4e <vector135>:
.globl vector135
vector135:
  pushl $0
80108b4e:	6a 00                	push   $0x0
  pushl $135
80108b50:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80108b55:	e9 e0 f4 ff ff       	jmp    8010803a <alltraps>

80108b5a <vector136>:
.globl vector136
vector136:
  pushl $0
80108b5a:	6a 00                	push   $0x0
  pushl $136
80108b5c:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80108b61:	e9 d4 f4 ff ff       	jmp    8010803a <alltraps>

80108b66 <vector137>:
.globl vector137
vector137:
  pushl $0
80108b66:	6a 00                	push   $0x0
  pushl $137
80108b68:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80108b6d:	e9 c8 f4 ff ff       	jmp    8010803a <alltraps>

80108b72 <vector138>:
.globl vector138
vector138:
  pushl $0
80108b72:	6a 00                	push   $0x0
  pushl $138
80108b74:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80108b79:	e9 bc f4 ff ff       	jmp    8010803a <alltraps>

80108b7e <vector139>:
.globl vector139
vector139:
  pushl $0
80108b7e:	6a 00                	push   $0x0
  pushl $139
80108b80:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80108b85:	e9 b0 f4 ff ff       	jmp    8010803a <alltraps>

80108b8a <vector140>:
.globl vector140
vector140:
  pushl $0
80108b8a:	6a 00                	push   $0x0
  pushl $140
80108b8c:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80108b91:	e9 a4 f4 ff ff       	jmp    8010803a <alltraps>

80108b96 <vector141>:
.globl vector141
vector141:
  pushl $0
80108b96:	6a 00                	push   $0x0
  pushl $141
80108b98:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80108b9d:	e9 98 f4 ff ff       	jmp    8010803a <alltraps>

80108ba2 <vector142>:
.globl vector142
vector142:
  pushl $0
80108ba2:	6a 00                	push   $0x0
  pushl $142
80108ba4:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80108ba9:	e9 8c f4 ff ff       	jmp    8010803a <alltraps>

80108bae <vector143>:
.globl vector143
vector143:
  pushl $0
80108bae:	6a 00                	push   $0x0
  pushl $143
80108bb0:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80108bb5:	e9 80 f4 ff ff       	jmp    8010803a <alltraps>

80108bba <vector144>:
.globl vector144
vector144:
  pushl $0
80108bba:	6a 00                	push   $0x0
  pushl $144
80108bbc:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80108bc1:	e9 74 f4 ff ff       	jmp    8010803a <alltraps>

80108bc6 <vector145>:
.globl vector145
vector145:
  pushl $0
80108bc6:	6a 00                	push   $0x0
  pushl $145
80108bc8:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80108bcd:	e9 68 f4 ff ff       	jmp    8010803a <alltraps>

80108bd2 <vector146>:
.globl vector146
vector146:
  pushl $0
80108bd2:	6a 00                	push   $0x0
  pushl $146
80108bd4:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80108bd9:	e9 5c f4 ff ff       	jmp    8010803a <alltraps>

80108bde <vector147>:
.globl vector147
vector147:
  pushl $0
80108bde:	6a 00                	push   $0x0
  pushl $147
80108be0:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80108be5:	e9 50 f4 ff ff       	jmp    8010803a <alltraps>

80108bea <vector148>:
.globl vector148
vector148:
  pushl $0
80108bea:	6a 00                	push   $0x0
  pushl $148
80108bec:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80108bf1:	e9 44 f4 ff ff       	jmp    8010803a <alltraps>

80108bf6 <vector149>:
.globl vector149
vector149:
  pushl $0
80108bf6:	6a 00                	push   $0x0
  pushl $149
80108bf8:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80108bfd:	e9 38 f4 ff ff       	jmp    8010803a <alltraps>

80108c02 <vector150>:
.globl vector150
vector150:
  pushl $0
80108c02:	6a 00                	push   $0x0
  pushl $150
80108c04:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80108c09:	e9 2c f4 ff ff       	jmp    8010803a <alltraps>

80108c0e <vector151>:
.globl vector151
vector151:
  pushl $0
80108c0e:	6a 00                	push   $0x0
  pushl $151
80108c10:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80108c15:	e9 20 f4 ff ff       	jmp    8010803a <alltraps>

80108c1a <vector152>:
.globl vector152
vector152:
  pushl $0
80108c1a:	6a 00                	push   $0x0
  pushl $152
80108c1c:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80108c21:	e9 14 f4 ff ff       	jmp    8010803a <alltraps>

80108c26 <vector153>:
.globl vector153
vector153:
  pushl $0
80108c26:	6a 00                	push   $0x0
  pushl $153
80108c28:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80108c2d:	e9 08 f4 ff ff       	jmp    8010803a <alltraps>

80108c32 <vector154>:
.globl vector154
vector154:
  pushl $0
80108c32:	6a 00                	push   $0x0
  pushl $154
80108c34:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80108c39:	e9 fc f3 ff ff       	jmp    8010803a <alltraps>

80108c3e <vector155>:
.globl vector155
vector155:
  pushl $0
80108c3e:	6a 00                	push   $0x0
  pushl $155
80108c40:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80108c45:	e9 f0 f3 ff ff       	jmp    8010803a <alltraps>

80108c4a <vector156>:
.globl vector156
vector156:
  pushl $0
80108c4a:	6a 00                	push   $0x0
  pushl $156
80108c4c:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80108c51:	e9 e4 f3 ff ff       	jmp    8010803a <alltraps>

80108c56 <vector157>:
.globl vector157
vector157:
  pushl $0
80108c56:	6a 00                	push   $0x0
  pushl $157
80108c58:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80108c5d:	e9 d8 f3 ff ff       	jmp    8010803a <alltraps>

80108c62 <vector158>:
.globl vector158
vector158:
  pushl $0
80108c62:	6a 00                	push   $0x0
  pushl $158
80108c64:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80108c69:	e9 cc f3 ff ff       	jmp    8010803a <alltraps>

80108c6e <vector159>:
.globl vector159
vector159:
  pushl $0
80108c6e:	6a 00                	push   $0x0
  pushl $159
80108c70:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80108c75:	e9 c0 f3 ff ff       	jmp    8010803a <alltraps>

80108c7a <vector160>:
.globl vector160
vector160:
  pushl $0
80108c7a:	6a 00                	push   $0x0
  pushl $160
80108c7c:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80108c81:	e9 b4 f3 ff ff       	jmp    8010803a <alltraps>

80108c86 <vector161>:
.globl vector161
vector161:
  pushl $0
80108c86:	6a 00                	push   $0x0
  pushl $161
80108c88:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80108c8d:	e9 a8 f3 ff ff       	jmp    8010803a <alltraps>

80108c92 <vector162>:
.globl vector162
vector162:
  pushl $0
80108c92:	6a 00                	push   $0x0
  pushl $162
80108c94:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80108c99:	e9 9c f3 ff ff       	jmp    8010803a <alltraps>

80108c9e <vector163>:
.globl vector163
vector163:
  pushl $0
80108c9e:	6a 00                	push   $0x0
  pushl $163
80108ca0:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80108ca5:	e9 90 f3 ff ff       	jmp    8010803a <alltraps>

80108caa <vector164>:
.globl vector164
vector164:
  pushl $0
80108caa:	6a 00                	push   $0x0
  pushl $164
80108cac:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80108cb1:	e9 84 f3 ff ff       	jmp    8010803a <alltraps>

80108cb6 <vector165>:
.globl vector165
vector165:
  pushl $0
80108cb6:	6a 00                	push   $0x0
  pushl $165
80108cb8:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80108cbd:	e9 78 f3 ff ff       	jmp    8010803a <alltraps>

80108cc2 <vector166>:
.globl vector166
vector166:
  pushl $0
80108cc2:	6a 00                	push   $0x0
  pushl $166
80108cc4:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80108cc9:	e9 6c f3 ff ff       	jmp    8010803a <alltraps>

80108cce <vector167>:
.globl vector167
vector167:
  pushl $0
80108cce:	6a 00                	push   $0x0
  pushl $167
80108cd0:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80108cd5:	e9 60 f3 ff ff       	jmp    8010803a <alltraps>

80108cda <vector168>:
.globl vector168
vector168:
  pushl $0
80108cda:	6a 00                	push   $0x0
  pushl $168
80108cdc:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80108ce1:	e9 54 f3 ff ff       	jmp    8010803a <alltraps>

80108ce6 <vector169>:
.globl vector169
vector169:
  pushl $0
80108ce6:	6a 00                	push   $0x0
  pushl $169
80108ce8:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80108ced:	e9 48 f3 ff ff       	jmp    8010803a <alltraps>

80108cf2 <vector170>:
.globl vector170
vector170:
  pushl $0
80108cf2:	6a 00                	push   $0x0
  pushl $170
80108cf4:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80108cf9:	e9 3c f3 ff ff       	jmp    8010803a <alltraps>

80108cfe <vector171>:
.globl vector171
vector171:
  pushl $0
80108cfe:	6a 00                	push   $0x0
  pushl $171
80108d00:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80108d05:	e9 30 f3 ff ff       	jmp    8010803a <alltraps>

80108d0a <vector172>:
.globl vector172
vector172:
  pushl $0
80108d0a:	6a 00                	push   $0x0
  pushl $172
80108d0c:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80108d11:	e9 24 f3 ff ff       	jmp    8010803a <alltraps>

80108d16 <vector173>:
.globl vector173
vector173:
  pushl $0
80108d16:	6a 00                	push   $0x0
  pushl $173
80108d18:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80108d1d:	e9 18 f3 ff ff       	jmp    8010803a <alltraps>

80108d22 <vector174>:
.globl vector174
vector174:
  pushl $0
80108d22:	6a 00                	push   $0x0
  pushl $174
80108d24:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80108d29:	e9 0c f3 ff ff       	jmp    8010803a <alltraps>

80108d2e <vector175>:
.globl vector175
vector175:
  pushl $0
80108d2e:	6a 00                	push   $0x0
  pushl $175
80108d30:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80108d35:	e9 00 f3 ff ff       	jmp    8010803a <alltraps>

80108d3a <vector176>:
.globl vector176
vector176:
  pushl $0
80108d3a:	6a 00                	push   $0x0
  pushl $176
80108d3c:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80108d41:	e9 f4 f2 ff ff       	jmp    8010803a <alltraps>

80108d46 <vector177>:
.globl vector177
vector177:
  pushl $0
80108d46:	6a 00                	push   $0x0
  pushl $177
80108d48:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80108d4d:	e9 e8 f2 ff ff       	jmp    8010803a <alltraps>

80108d52 <vector178>:
.globl vector178
vector178:
  pushl $0
80108d52:	6a 00                	push   $0x0
  pushl $178
80108d54:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80108d59:	e9 dc f2 ff ff       	jmp    8010803a <alltraps>

80108d5e <vector179>:
.globl vector179
vector179:
  pushl $0
80108d5e:	6a 00                	push   $0x0
  pushl $179
80108d60:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80108d65:	e9 d0 f2 ff ff       	jmp    8010803a <alltraps>

80108d6a <vector180>:
.globl vector180
vector180:
  pushl $0
80108d6a:	6a 00                	push   $0x0
  pushl $180
80108d6c:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80108d71:	e9 c4 f2 ff ff       	jmp    8010803a <alltraps>

80108d76 <vector181>:
.globl vector181
vector181:
  pushl $0
80108d76:	6a 00                	push   $0x0
  pushl $181
80108d78:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80108d7d:	e9 b8 f2 ff ff       	jmp    8010803a <alltraps>

80108d82 <vector182>:
.globl vector182
vector182:
  pushl $0
80108d82:	6a 00                	push   $0x0
  pushl $182
80108d84:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80108d89:	e9 ac f2 ff ff       	jmp    8010803a <alltraps>

80108d8e <vector183>:
.globl vector183
vector183:
  pushl $0
80108d8e:	6a 00                	push   $0x0
  pushl $183
80108d90:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80108d95:	e9 a0 f2 ff ff       	jmp    8010803a <alltraps>

80108d9a <vector184>:
.globl vector184
vector184:
  pushl $0
80108d9a:	6a 00                	push   $0x0
  pushl $184
80108d9c:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80108da1:	e9 94 f2 ff ff       	jmp    8010803a <alltraps>

80108da6 <vector185>:
.globl vector185
vector185:
  pushl $0
80108da6:	6a 00                	push   $0x0
  pushl $185
80108da8:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80108dad:	e9 88 f2 ff ff       	jmp    8010803a <alltraps>

80108db2 <vector186>:
.globl vector186
vector186:
  pushl $0
80108db2:	6a 00                	push   $0x0
  pushl $186
80108db4:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80108db9:	e9 7c f2 ff ff       	jmp    8010803a <alltraps>

80108dbe <vector187>:
.globl vector187
vector187:
  pushl $0
80108dbe:	6a 00                	push   $0x0
  pushl $187
80108dc0:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80108dc5:	e9 70 f2 ff ff       	jmp    8010803a <alltraps>

80108dca <vector188>:
.globl vector188
vector188:
  pushl $0
80108dca:	6a 00                	push   $0x0
  pushl $188
80108dcc:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80108dd1:	e9 64 f2 ff ff       	jmp    8010803a <alltraps>

80108dd6 <vector189>:
.globl vector189
vector189:
  pushl $0
80108dd6:	6a 00                	push   $0x0
  pushl $189
80108dd8:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80108ddd:	e9 58 f2 ff ff       	jmp    8010803a <alltraps>

80108de2 <vector190>:
.globl vector190
vector190:
  pushl $0
80108de2:	6a 00                	push   $0x0
  pushl $190
80108de4:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80108de9:	e9 4c f2 ff ff       	jmp    8010803a <alltraps>

80108dee <vector191>:
.globl vector191
vector191:
  pushl $0
80108dee:	6a 00                	push   $0x0
  pushl $191
80108df0:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80108df5:	e9 40 f2 ff ff       	jmp    8010803a <alltraps>

80108dfa <vector192>:
.globl vector192
vector192:
  pushl $0
80108dfa:	6a 00                	push   $0x0
  pushl $192
80108dfc:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80108e01:	e9 34 f2 ff ff       	jmp    8010803a <alltraps>

80108e06 <vector193>:
.globl vector193
vector193:
  pushl $0
80108e06:	6a 00                	push   $0x0
  pushl $193
80108e08:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80108e0d:	e9 28 f2 ff ff       	jmp    8010803a <alltraps>

80108e12 <vector194>:
.globl vector194
vector194:
  pushl $0
80108e12:	6a 00                	push   $0x0
  pushl $194
80108e14:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80108e19:	e9 1c f2 ff ff       	jmp    8010803a <alltraps>

80108e1e <vector195>:
.globl vector195
vector195:
  pushl $0
80108e1e:	6a 00                	push   $0x0
  pushl $195
80108e20:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80108e25:	e9 10 f2 ff ff       	jmp    8010803a <alltraps>

80108e2a <vector196>:
.globl vector196
vector196:
  pushl $0
80108e2a:	6a 00                	push   $0x0
  pushl $196
80108e2c:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80108e31:	e9 04 f2 ff ff       	jmp    8010803a <alltraps>

80108e36 <vector197>:
.globl vector197
vector197:
  pushl $0
80108e36:	6a 00                	push   $0x0
  pushl $197
80108e38:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80108e3d:	e9 f8 f1 ff ff       	jmp    8010803a <alltraps>

80108e42 <vector198>:
.globl vector198
vector198:
  pushl $0
80108e42:	6a 00                	push   $0x0
  pushl $198
80108e44:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80108e49:	e9 ec f1 ff ff       	jmp    8010803a <alltraps>

80108e4e <vector199>:
.globl vector199
vector199:
  pushl $0
80108e4e:	6a 00                	push   $0x0
  pushl $199
80108e50:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80108e55:	e9 e0 f1 ff ff       	jmp    8010803a <alltraps>

80108e5a <vector200>:
.globl vector200
vector200:
  pushl $0
80108e5a:	6a 00                	push   $0x0
  pushl $200
80108e5c:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80108e61:	e9 d4 f1 ff ff       	jmp    8010803a <alltraps>

80108e66 <vector201>:
.globl vector201
vector201:
  pushl $0
80108e66:	6a 00                	push   $0x0
  pushl $201
80108e68:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80108e6d:	e9 c8 f1 ff ff       	jmp    8010803a <alltraps>

80108e72 <vector202>:
.globl vector202
vector202:
  pushl $0
80108e72:	6a 00                	push   $0x0
  pushl $202
80108e74:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80108e79:	e9 bc f1 ff ff       	jmp    8010803a <alltraps>

80108e7e <vector203>:
.globl vector203
vector203:
  pushl $0
80108e7e:	6a 00                	push   $0x0
  pushl $203
80108e80:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80108e85:	e9 b0 f1 ff ff       	jmp    8010803a <alltraps>

80108e8a <vector204>:
.globl vector204
vector204:
  pushl $0
80108e8a:	6a 00                	push   $0x0
  pushl $204
80108e8c:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80108e91:	e9 a4 f1 ff ff       	jmp    8010803a <alltraps>

80108e96 <vector205>:
.globl vector205
vector205:
  pushl $0
80108e96:	6a 00                	push   $0x0
  pushl $205
80108e98:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80108e9d:	e9 98 f1 ff ff       	jmp    8010803a <alltraps>

80108ea2 <vector206>:
.globl vector206
vector206:
  pushl $0
80108ea2:	6a 00                	push   $0x0
  pushl $206
80108ea4:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80108ea9:	e9 8c f1 ff ff       	jmp    8010803a <alltraps>

80108eae <vector207>:
.globl vector207
vector207:
  pushl $0
80108eae:	6a 00                	push   $0x0
  pushl $207
80108eb0:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80108eb5:	e9 80 f1 ff ff       	jmp    8010803a <alltraps>

80108eba <vector208>:
.globl vector208
vector208:
  pushl $0
80108eba:	6a 00                	push   $0x0
  pushl $208
80108ebc:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80108ec1:	e9 74 f1 ff ff       	jmp    8010803a <alltraps>

80108ec6 <vector209>:
.globl vector209
vector209:
  pushl $0
80108ec6:	6a 00                	push   $0x0
  pushl $209
80108ec8:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80108ecd:	e9 68 f1 ff ff       	jmp    8010803a <alltraps>

80108ed2 <vector210>:
.globl vector210
vector210:
  pushl $0
80108ed2:	6a 00                	push   $0x0
  pushl $210
80108ed4:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80108ed9:	e9 5c f1 ff ff       	jmp    8010803a <alltraps>

80108ede <vector211>:
.globl vector211
vector211:
  pushl $0
80108ede:	6a 00                	push   $0x0
  pushl $211
80108ee0:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80108ee5:	e9 50 f1 ff ff       	jmp    8010803a <alltraps>

80108eea <vector212>:
.globl vector212
vector212:
  pushl $0
80108eea:	6a 00                	push   $0x0
  pushl $212
80108eec:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80108ef1:	e9 44 f1 ff ff       	jmp    8010803a <alltraps>

80108ef6 <vector213>:
.globl vector213
vector213:
  pushl $0
80108ef6:	6a 00                	push   $0x0
  pushl $213
80108ef8:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80108efd:	e9 38 f1 ff ff       	jmp    8010803a <alltraps>

80108f02 <vector214>:
.globl vector214
vector214:
  pushl $0
80108f02:	6a 00                	push   $0x0
  pushl $214
80108f04:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80108f09:	e9 2c f1 ff ff       	jmp    8010803a <alltraps>

80108f0e <vector215>:
.globl vector215
vector215:
  pushl $0
80108f0e:	6a 00                	push   $0x0
  pushl $215
80108f10:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80108f15:	e9 20 f1 ff ff       	jmp    8010803a <alltraps>

80108f1a <vector216>:
.globl vector216
vector216:
  pushl $0
80108f1a:	6a 00                	push   $0x0
  pushl $216
80108f1c:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80108f21:	e9 14 f1 ff ff       	jmp    8010803a <alltraps>

80108f26 <vector217>:
.globl vector217
vector217:
  pushl $0
80108f26:	6a 00                	push   $0x0
  pushl $217
80108f28:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80108f2d:	e9 08 f1 ff ff       	jmp    8010803a <alltraps>

80108f32 <vector218>:
.globl vector218
vector218:
  pushl $0
80108f32:	6a 00                	push   $0x0
  pushl $218
80108f34:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80108f39:	e9 fc f0 ff ff       	jmp    8010803a <alltraps>

80108f3e <vector219>:
.globl vector219
vector219:
  pushl $0
80108f3e:	6a 00                	push   $0x0
  pushl $219
80108f40:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80108f45:	e9 f0 f0 ff ff       	jmp    8010803a <alltraps>

80108f4a <vector220>:
.globl vector220
vector220:
  pushl $0
80108f4a:	6a 00                	push   $0x0
  pushl $220
80108f4c:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80108f51:	e9 e4 f0 ff ff       	jmp    8010803a <alltraps>

80108f56 <vector221>:
.globl vector221
vector221:
  pushl $0
80108f56:	6a 00                	push   $0x0
  pushl $221
80108f58:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80108f5d:	e9 d8 f0 ff ff       	jmp    8010803a <alltraps>

80108f62 <vector222>:
.globl vector222
vector222:
  pushl $0
80108f62:	6a 00                	push   $0x0
  pushl $222
80108f64:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80108f69:	e9 cc f0 ff ff       	jmp    8010803a <alltraps>

80108f6e <vector223>:
.globl vector223
vector223:
  pushl $0
80108f6e:	6a 00                	push   $0x0
  pushl $223
80108f70:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80108f75:	e9 c0 f0 ff ff       	jmp    8010803a <alltraps>

80108f7a <vector224>:
.globl vector224
vector224:
  pushl $0
80108f7a:	6a 00                	push   $0x0
  pushl $224
80108f7c:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80108f81:	e9 b4 f0 ff ff       	jmp    8010803a <alltraps>

80108f86 <vector225>:
.globl vector225
vector225:
  pushl $0
80108f86:	6a 00                	push   $0x0
  pushl $225
80108f88:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80108f8d:	e9 a8 f0 ff ff       	jmp    8010803a <alltraps>

80108f92 <vector226>:
.globl vector226
vector226:
  pushl $0
80108f92:	6a 00                	push   $0x0
  pushl $226
80108f94:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80108f99:	e9 9c f0 ff ff       	jmp    8010803a <alltraps>

80108f9e <vector227>:
.globl vector227
vector227:
  pushl $0
80108f9e:	6a 00                	push   $0x0
  pushl $227
80108fa0:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80108fa5:	e9 90 f0 ff ff       	jmp    8010803a <alltraps>

80108faa <vector228>:
.globl vector228
vector228:
  pushl $0
80108faa:	6a 00                	push   $0x0
  pushl $228
80108fac:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80108fb1:	e9 84 f0 ff ff       	jmp    8010803a <alltraps>

80108fb6 <vector229>:
.globl vector229
vector229:
  pushl $0
80108fb6:	6a 00                	push   $0x0
  pushl $229
80108fb8:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80108fbd:	e9 78 f0 ff ff       	jmp    8010803a <alltraps>

80108fc2 <vector230>:
.globl vector230
vector230:
  pushl $0
80108fc2:	6a 00                	push   $0x0
  pushl $230
80108fc4:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80108fc9:	e9 6c f0 ff ff       	jmp    8010803a <alltraps>

80108fce <vector231>:
.globl vector231
vector231:
  pushl $0
80108fce:	6a 00                	push   $0x0
  pushl $231
80108fd0:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80108fd5:	e9 60 f0 ff ff       	jmp    8010803a <alltraps>

80108fda <vector232>:
.globl vector232
vector232:
  pushl $0
80108fda:	6a 00                	push   $0x0
  pushl $232
80108fdc:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80108fe1:	e9 54 f0 ff ff       	jmp    8010803a <alltraps>

80108fe6 <vector233>:
.globl vector233
vector233:
  pushl $0
80108fe6:	6a 00                	push   $0x0
  pushl $233
80108fe8:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80108fed:	e9 48 f0 ff ff       	jmp    8010803a <alltraps>

80108ff2 <vector234>:
.globl vector234
vector234:
  pushl $0
80108ff2:	6a 00                	push   $0x0
  pushl $234
80108ff4:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80108ff9:	e9 3c f0 ff ff       	jmp    8010803a <alltraps>

80108ffe <vector235>:
.globl vector235
vector235:
  pushl $0
80108ffe:	6a 00                	push   $0x0
  pushl $235
80109000:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80109005:	e9 30 f0 ff ff       	jmp    8010803a <alltraps>

8010900a <vector236>:
.globl vector236
vector236:
  pushl $0
8010900a:	6a 00                	push   $0x0
  pushl $236
8010900c:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80109011:	e9 24 f0 ff ff       	jmp    8010803a <alltraps>

80109016 <vector237>:
.globl vector237
vector237:
  pushl $0
80109016:	6a 00                	push   $0x0
  pushl $237
80109018:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010901d:	e9 18 f0 ff ff       	jmp    8010803a <alltraps>

80109022 <vector238>:
.globl vector238
vector238:
  pushl $0
80109022:	6a 00                	push   $0x0
  pushl $238
80109024:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80109029:	e9 0c f0 ff ff       	jmp    8010803a <alltraps>

8010902e <vector239>:
.globl vector239
vector239:
  pushl $0
8010902e:	6a 00                	push   $0x0
  pushl $239
80109030:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80109035:	e9 00 f0 ff ff       	jmp    8010803a <alltraps>

8010903a <vector240>:
.globl vector240
vector240:
  pushl $0
8010903a:	6a 00                	push   $0x0
  pushl $240
8010903c:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80109041:	e9 f4 ef ff ff       	jmp    8010803a <alltraps>

80109046 <vector241>:
.globl vector241
vector241:
  pushl $0
80109046:	6a 00                	push   $0x0
  pushl $241
80109048:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010904d:	e9 e8 ef ff ff       	jmp    8010803a <alltraps>

80109052 <vector242>:
.globl vector242
vector242:
  pushl $0
80109052:	6a 00                	push   $0x0
  pushl $242
80109054:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80109059:	e9 dc ef ff ff       	jmp    8010803a <alltraps>

8010905e <vector243>:
.globl vector243
vector243:
  pushl $0
8010905e:	6a 00                	push   $0x0
  pushl $243
80109060:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80109065:	e9 d0 ef ff ff       	jmp    8010803a <alltraps>

8010906a <vector244>:
.globl vector244
vector244:
  pushl $0
8010906a:	6a 00                	push   $0x0
  pushl $244
8010906c:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80109071:	e9 c4 ef ff ff       	jmp    8010803a <alltraps>

80109076 <vector245>:
.globl vector245
vector245:
  pushl $0
80109076:	6a 00                	push   $0x0
  pushl $245
80109078:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010907d:	e9 b8 ef ff ff       	jmp    8010803a <alltraps>

80109082 <vector246>:
.globl vector246
vector246:
  pushl $0
80109082:	6a 00                	push   $0x0
  pushl $246
80109084:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80109089:	e9 ac ef ff ff       	jmp    8010803a <alltraps>

8010908e <vector247>:
.globl vector247
vector247:
  pushl $0
8010908e:	6a 00                	push   $0x0
  pushl $247
80109090:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80109095:	e9 a0 ef ff ff       	jmp    8010803a <alltraps>

8010909a <vector248>:
.globl vector248
vector248:
  pushl $0
8010909a:	6a 00                	push   $0x0
  pushl $248
8010909c:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801090a1:	e9 94 ef ff ff       	jmp    8010803a <alltraps>

801090a6 <vector249>:
.globl vector249
vector249:
  pushl $0
801090a6:	6a 00                	push   $0x0
  pushl $249
801090a8:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801090ad:	e9 88 ef ff ff       	jmp    8010803a <alltraps>

801090b2 <vector250>:
.globl vector250
vector250:
  pushl $0
801090b2:	6a 00                	push   $0x0
  pushl $250
801090b4:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801090b9:	e9 7c ef ff ff       	jmp    8010803a <alltraps>

801090be <vector251>:
.globl vector251
vector251:
  pushl $0
801090be:	6a 00                	push   $0x0
  pushl $251
801090c0:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801090c5:	e9 70 ef ff ff       	jmp    8010803a <alltraps>

801090ca <vector252>:
.globl vector252
vector252:
  pushl $0
801090ca:	6a 00                	push   $0x0
  pushl $252
801090cc:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801090d1:	e9 64 ef ff ff       	jmp    8010803a <alltraps>

801090d6 <vector253>:
.globl vector253
vector253:
  pushl $0
801090d6:	6a 00                	push   $0x0
  pushl $253
801090d8:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801090dd:	e9 58 ef ff ff       	jmp    8010803a <alltraps>

801090e2 <vector254>:
.globl vector254
vector254:
  pushl $0
801090e2:	6a 00                	push   $0x0
  pushl $254
801090e4:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801090e9:	e9 4c ef ff ff       	jmp    8010803a <alltraps>

801090ee <vector255>:
.globl vector255
vector255:
  pushl $0
801090ee:	6a 00                	push   $0x0
  pushl $255
801090f0:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801090f5:	e9 40 ef ff ff       	jmp    8010803a <alltraps>

801090fa <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801090fa:	55                   	push   %ebp
801090fb:	89 e5                	mov    %esp,%ebp
801090fd:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80109100:	8b 45 0c             	mov    0xc(%ebp),%eax
80109103:	83 e8 01             	sub    $0x1,%eax
80109106:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010910a:	8b 45 08             	mov    0x8(%ebp),%eax
8010910d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80109111:	8b 45 08             	mov    0x8(%ebp),%eax
80109114:	c1 e8 10             	shr    $0x10,%eax
80109117:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
8010911b:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010911e:	0f 01 10             	lgdtl  (%eax)
}
80109121:	90                   	nop
80109122:	c9                   	leave  
80109123:	c3                   	ret    

80109124 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80109124:	55                   	push   %ebp
80109125:	89 e5                	mov    %esp,%ebp
80109127:	83 ec 04             	sub    $0x4,%esp
8010912a:	8b 45 08             	mov    0x8(%ebp),%eax
8010912d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80109131:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109135:	0f 00 d8             	ltr    %ax
}
80109138:	90                   	nop
80109139:	c9                   	leave  
8010913a:	c3                   	ret    

8010913b <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
8010913b:	55                   	push   %ebp
8010913c:	89 e5                	mov    %esp,%ebp
8010913e:	83 ec 04             	sub    $0x4,%esp
80109141:	8b 45 08             	mov    0x8(%ebp),%eax
80109144:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80109148:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010914c:	8e e8                	mov    %eax,%gs
}
8010914e:	90                   	nop
8010914f:	c9                   	leave  
80109150:	c3                   	ret    

80109151 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80109151:	55                   	push   %ebp
80109152:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80109154:	8b 45 08             	mov    0x8(%ebp),%eax
80109157:	0f 22 d8             	mov    %eax,%cr3
}
8010915a:	90                   	nop
8010915b:	5d                   	pop    %ebp
8010915c:	c3                   	ret    

8010915d <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
8010915d:	55                   	push   %ebp
8010915e:	89 e5                	mov    %esp,%ebp
80109160:	8b 45 08             	mov    0x8(%ebp),%eax
80109163:	05 00 00 00 80       	add    $0x80000000,%eax
80109168:	5d                   	pop    %ebp
80109169:	c3                   	ret    

8010916a <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010916a:	55                   	push   %ebp
8010916b:	89 e5                	mov    %esp,%ebp
8010916d:	8b 45 08             	mov    0x8(%ebp),%eax
80109170:	05 00 00 00 80       	add    $0x80000000,%eax
80109175:	5d                   	pop    %ebp
80109176:	c3                   	ret    

80109177 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80109177:	55                   	push   %ebp
80109178:	89 e5                	mov    %esp,%ebp
8010917a:	53                   	push   %ebx
8010917b:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
8010917e:	e8 e7 9e ff ff       	call   8010306a <cpunum>
80109183:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80109189:	05 80 43 11 80       	add    $0x80114380,%eax
8010918e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80109191:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109194:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010919a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010919d:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801091a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091a6:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801091aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091ad:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801091b1:	83 e2 f0             	and    $0xfffffff0,%edx
801091b4:	83 ca 0a             	or     $0xa,%edx
801091b7:	88 50 7d             	mov    %dl,0x7d(%eax)
801091ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091bd:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801091c1:	83 ca 10             	or     $0x10,%edx
801091c4:	88 50 7d             	mov    %dl,0x7d(%eax)
801091c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091ca:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801091ce:	83 e2 9f             	and    $0xffffff9f,%edx
801091d1:	88 50 7d             	mov    %dl,0x7d(%eax)
801091d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091d7:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801091db:	83 ca 80             	or     $0xffffff80,%edx
801091de:	88 50 7d             	mov    %dl,0x7d(%eax)
801091e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091e4:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801091e8:	83 ca 0f             	or     $0xf,%edx
801091eb:	88 50 7e             	mov    %dl,0x7e(%eax)
801091ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091f1:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801091f5:	83 e2 ef             	and    $0xffffffef,%edx
801091f8:	88 50 7e             	mov    %dl,0x7e(%eax)
801091fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091fe:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80109202:	83 e2 df             	and    $0xffffffdf,%edx
80109205:	88 50 7e             	mov    %dl,0x7e(%eax)
80109208:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010920b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010920f:	83 ca 40             	or     $0x40,%edx
80109212:	88 50 7e             	mov    %dl,0x7e(%eax)
80109215:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109218:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010921c:	83 ca 80             	or     $0xffffff80,%edx
8010921f:	88 50 7e             	mov    %dl,0x7e(%eax)
80109222:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109225:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80109229:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010922c:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80109233:	ff ff 
80109235:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109238:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010923f:	00 00 
80109241:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109244:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010924b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010924e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80109255:	83 e2 f0             	and    $0xfffffff0,%edx
80109258:	83 ca 02             	or     $0x2,%edx
8010925b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80109261:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109264:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010926b:	83 ca 10             	or     $0x10,%edx
8010926e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80109274:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109277:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010927e:	83 e2 9f             	and    $0xffffff9f,%edx
80109281:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80109287:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010928a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80109291:	83 ca 80             	or     $0xffffff80,%edx
80109294:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010929a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010929d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801092a4:	83 ca 0f             	or     $0xf,%edx
801092a7:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801092ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092b0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801092b7:	83 e2 ef             	and    $0xffffffef,%edx
801092ba:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801092c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092c3:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801092ca:	83 e2 df             	and    $0xffffffdf,%edx
801092cd:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801092d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092d6:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801092dd:	83 ca 40             	or     $0x40,%edx
801092e0:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801092e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092e9:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801092f0:	83 ca 80             	or     $0xffffff80,%edx
801092f3:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801092f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092fc:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80109303:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109306:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010930d:	ff ff 
8010930f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109312:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80109319:	00 00 
8010931b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010931e:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80109325:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109328:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010932f:	83 e2 f0             	and    $0xfffffff0,%edx
80109332:	83 ca 0a             	or     $0xa,%edx
80109335:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010933b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010933e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80109345:	83 ca 10             	or     $0x10,%edx
80109348:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010934e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109351:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80109358:	83 ca 60             	or     $0x60,%edx
8010935b:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80109361:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109364:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010936b:	83 ca 80             	or     $0xffffff80,%edx
8010936e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80109374:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109377:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010937e:	83 ca 0f             	or     $0xf,%edx
80109381:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80109387:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010938a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80109391:	83 e2 ef             	and    $0xffffffef,%edx
80109394:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010939a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010939d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801093a4:	83 e2 df             	and    $0xffffffdf,%edx
801093a7:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801093ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093b0:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801093b7:	83 ca 40             	or     $0x40,%edx
801093ba:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801093c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093c3:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801093ca:	83 ca 80             	or     $0xffffff80,%edx
801093cd:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801093d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093d6:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801093dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093e0:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
801093e7:	ff ff 
801093e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093ec:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
801093f3:	00 00 
801093f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093f8:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
801093ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109402:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80109409:	83 e2 f0             	and    $0xfffffff0,%edx
8010940c:	83 ca 02             	or     $0x2,%edx
8010940f:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80109415:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109418:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010941f:	83 ca 10             	or     $0x10,%edx
80109422:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80109428:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010942b:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80109432:	83 ca 60             	or     $0x60,%edx
80109435:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010943b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010943e:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80109445:	83 ca 80             	or     $0xffffff80,%edx
80109448:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010944e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109451:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80109458:	83 ca 0f             	or     $0xf,%edx
8010945b:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80109461:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109464:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010946b:	83 e2 ef             	and    $0xffffffef,%edx
8010946e:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80109474:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109477:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010947e:	83 e2 df             	and    $0xffffffdf,%edx
80109481:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80109487:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010948a:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80109491:	83 ca 40             	or     $0x40,%edx
80109494:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010949a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010949d:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801094a4:	83 ca 80             	or     $0xffffff80,%edx
801094a7:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801094ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094b0:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801094b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094ba:	05 b4 00 00 00       	add    $0xb4,%eax
801094bf:	89 c3                	mov    %eax,%ebx
801094c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094c4:	05 b4 00 00 00       	add    $0xb4,%eax
801094c9:	c1 e8 10             	shr    $0x10,%eax
801094cc:	89 c2                	mov    %eax,%edx
801094ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094d1:	05 b4 00 00 00       	add    $0xb4,%eax
801094d6:	c1 e8 18             	shr    $0x18,%eax
801094d9:	89 c1                	mov    %eax,%ecx
801094db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094de:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
801094e5:	00 00 
801094e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094ea:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
801094f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094f4:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
801094fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094fd:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80109504:	83 e2 f0             	and    $0xfffffff0,%edx
80109507:	83 ca 02             	or     $0x2,%edx
8010950a:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80109510:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109513:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010951a:	83 ca 10             	or     $0x10,%edx
8010951d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80109523:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109526:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010952d:	83 e2 9f             	and    $0xffffff9f,%edx
80109530:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80109536:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109539:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80109540:	83 ca 80             	or     $0xffffff80,%edx
80109543:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80109549:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010954c:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80109553:	83 e2 f0             	and    $0xfffffff0,%edx
80109556:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010955c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010955f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80109566:	83 e2 ef             	and    $0xffffffef,%edx
80109569:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010956f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109572:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80109579:	83 e2 df             	and    $0xffffffdf,%edx
8010957c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80109582:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109585:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010958c:	83 ca 40             	or     $0x40,%edx
8010958f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80109595:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109598:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010959f:	83 ca 80             	or     $0xffffff80,%edx
801095a2:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801095a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095ab:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
801095b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095b4:	83 c0 70             	add    $0x70,%eax
801095b7:	83 ec 08             	sub    $0x8,%esp
801095ba:	6a 38                	push   $0x38
801095bc:	50                   	push   %eax
801095bd:	e8 38 fb ff ff       	call   801090fa <lgdt>
801095c2:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
801095c5:	83 ec 0c             	sub    $0xc,%esp
801095c8:	6a 18                	push   $0x18
801095ca:	e8 6c fb ff ff       	call   8010913b <loadgs>
801095cf:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
801095d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095d5:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
801095db:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801095e2:	00 00 00 00 
}
801095e6:	90                   	nop
801095e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801095ea:	c9                   	leave  
801095eb:	c3                   	ret    

801095ec <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801095ec:	55                   	push   %ebp
801095ed:	89 e5                	mov    %esp,%ebp
801095ef:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801095f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801095f5:	c1 e8 16             	shr    $0x16,%eax
801095f8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801095ff:	8b 45 08             	mov    0x8(%ebp),%eax
80109602:	01 d0                	add    %edx,%eax
80109604:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80109607:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010960a:	8b 00                	mov    (%eax),%eax
8010960c:	83 e0 01             	and    $0x1,%eax
8010960f:	85 c0                	test   %eax,%eax
80109611:	74 18                	je     8010962b <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80109613:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109616:	8b 00                	mov    (%eax),%eax
80109618:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010961d:	50                   	push   %eax
8010961e:	e8 47 fb ff ff       	call   8010916a <p2v>
80109623:	83 c4 04             	add    $0x4,%esp
80109626:	89 45 f4             	mov    %eax,-0xc(%ebp)
80109629:	eb 48                	jmp    80109673 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010962b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010962f:	74 0e                	je     8010963f <walkpgdir+0x53>
80109631:	e8 ce 96 ff ff       	call   80102d04 <kalloc>
80109636:	89 45 f4             	mov    %eax,-0xc(%ebp)
80109639:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010963d:	75 07                	jne    80109646 <walkpgdir+0x5a>
      return 0;
8010963f:	b8 00 00 00 00       	mov    $0x0,%eax
80109644:	eb 44                	jmp    8010968a <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80109646:	83 ec 04             	sub    $0x4,%esp
80109649:	68 00 10 00 00       	push   $0x1000
8010964e:	6a 00                	push   $0x0
80109650:	ff 75 f4             	pushl  -0xc(%ebp)
80109653:	e8 80 d4 ff ff       	call   80106ad8 <memset>
80109658:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
8010965b:	83 ec 0c             	sub    $0xc,%esp
8010965e:	ff 75 f4             	pushl  -0xc(%ebp)
80109661:	e8 f7 fa ff ff       	call   8010915d <v2p>
80109666:	83 c4 10             	add    $0x10,%esp
80109669:	83 c8 07             	or     $0x7,%eax
8010966c:	89 c2                	mov    %eax,%edx
8010966e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109671:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80109673:	8b 45 0c             	mov    0xc(%ebp),%eax
80109676:	c1 e8 0c             	shr    $0xc,%eax
80109679:	25 ff 03 00 00       	and    $0x3ff,%eax
8010967e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109685:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109688:	01 d0                	add    %edx,%eax
}
8010968a:	c9                   	leave  
8010968b:	c3                   	ret    

8010968c <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010968c:	55                   	push   %ebp
8010968d:	89 e5                	mov    %esp,%ebp
8010968f:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80109692:	8b 45 0c             	mov    0xc(%ebp),%eax
80109695:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010969a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010969d:	8b 55 0c             	mov    0xc(%ebp),%edx
801096a0:	8b 45 10             	mov    0x10(%ebp),%eax
801096a3:	01 d0                	add    %edx,%eax
801096a5:	83 e8 01             	sub    $0x1,%eax
801096a8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801096ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801096b0:	83 ec 04             	sub    $0x4,%esp
801096b3:	6a 01                	push   $0x1
801096b5:	ff 75 f4             	pushl  -0xc(%ebp)
801096b8:	ff 75 08             	pushl  0x8(%ebp)
801096bb:	e8 2c ff ff ff       	call   801095ec <walkpgdir>
801096c0:	83 c4 10             	add    $0x10,%esp
801096c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
801096c6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801096ca:	75 07                	jne    801096d3 <mappages+0x47>
      return -1;
801096cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801096d1:	eb 47                	jmp    8010971a <mappages+0x8e>
    if(*pte & PTE_P)
801096d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801096d6:	8b 00                	mov    (%eax),%eax
801096d8:	83 e0 01             	and    $0x1,%eax
801096db:	85 c0                	test   %eax,%eax
801096dd:	74 0d                	je     801096ec <mappages+0x60>
      panic("remap");
801096df:	83 ec 0c             	sub    $0xc,%esp
801096e2:	68 f4 a8 10 80       	push   $0x8010a8f4
801096e7:	e8 7a 6e ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
801096ec:	8b 45 18             	mov    0x18(%ebp),%eax
801096ef:	0b 45 14             	or     0x14(%ebp),%eax
801096f2:	83 c8 01             	or     $0x1,%eax
801096f5:	89 c2                	mov    %eax,%edx
801096f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801096fa:	89 10                	mov    %edx,(%eax)
    if(a == last)
801096fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096ff:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80109702:	74 10                	je     80109714 <mappages+0x88>
      break;
    a += PGSIZE;
80109704:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
8010970b:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80109712:	eb 9c                	jmp    801096b0 <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80109714:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80109715:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010971a:	c9                   	leave  
8010971b:	c3                   	ret    

8010971c <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
8010971c:	55                   	push   %ebp
8010971d:	89 e5                	mov    %esp,%ebp
8010971f:	53                   	push   %ebx
80109720:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80109723:	e8 dc 95 ff ff       	call   80102d04 <kalloc>
80109728:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010972b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010972f:	75 0a                	jne    8010973b <setupkvm+0x1f>
    return 0;
80109731:	b8 00 00 00 00       	mov    $0x0,%eax
80109736:	e9 8e 00 00 00       	jmp    801097c9 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
8010973b:	83 ec 04             	sub    $0x4,%esp
8010973e:	68 00 10 00 00       	push   $0x1000
80109743:	6a 00                	push   $0x0
80109745:	ff 75 f0             	pushl  -0x10(%ebp)
80109748:	e8 8b d3 ff ff       	call   80106ad8 <memset>
8010974d:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80109750:	83 ec 0c             	sub    $0xc,%esp
80109753:	68 00 00 00 0e       	push   $0xe000000
80109758:	e8 0d fa ff ff       	call   8010916a <p2v>
8010975d:	83 c4 10             	add    $0x10,%esp
80109760:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80109765:	76 0d                	jbe    80109774 <setupkvm+0x58>
    panic("PHYSTOP too high");
80109767:	83 ec 0c             	sub    $0xc,%esp
8010976a:	68 fa a8 10 80       	push   $0x8010a8fa
8010976f:	e8 f2 6d ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80109774:	c7 45 f4 c0 d4 10 80 	movl   $0x8010d4c0,-0xc(%ebp)
8010977b:	eb 40                	jmp    801097bd <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
8010977d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109780:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80109783:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109786:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80109789:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010978c:	8b 58 08             	mov    0x8(%eax),%ebx
8010978f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109792:	8b 40 04             	mov    0x4(%eax),%eax
80109795:	29 c3                	sub    %eax,%ebx
80109797:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010979a:	8b 00                	mov    (%eax),%eax
8010979c:	83 ec 0c             	sub    $0xc,%esp
8010979f:	51                   	push   %ecx
801097a0:	52                   	push   %edx
801097a1:	53                   	push   %ebx
801097a2:	50                   	push   %eax
801097a3:	ff 75 f0             	pushl  -0x10(%ebp)
801097a6:	e8 e1 fe ff ff       	call   8010968c <mappages>
801097ab:	83 c4 20             	add    $0x20,%esp
801097ae:	85 c0                	test   %eax,%eax
801097b0:	79 07                	jns    801097b9 <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
801097b2:	b8 00 00 00 00       	mov    $0x0,%eax
801097b7:	eb 10                	jmp    801097c9 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801097b9:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801097bd:	81 7d f4 00 d5 10 80 	cmpl   $0x8010d500,-0xc(%ebp)
801097c4:	72 b7                	jb     8010977d <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
801097c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801097c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801097cc:	c9                   	leave  
801097cd:	c3                   	ret    

801097ce <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801097ce:	55                   	push   %ebp
801097cf:	89 e5                	mov    %esp,%ebp
801097d1:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801097d4:	e8 43 ff ff ff       	call   8010971c <setupkvm>
801097d9:	a3 78 79 11 80       	mov    %eax,0x80117978
  switchkvm();
801097de:	e8 03 00 00 00       	call   801097e6 <switchkvm>
}
801097e3:	90                   	nop
801097e4:	c9                   	leave  
801097e5:	c3                   	ret    

801097e6 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801097e6:	55                   	push   %ebp
801097e7:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
801097e9:	a1 78 79 11 80       	mov    0x80117978,%eax
801097ee:	50                   	push   %eax
801097ef:	e8 69 f9 ff ff       	call   8010915d <v2p>
801097f4:	83 c4 04             	add    $0x4,%esp
801097f7:	50                   	push   %eax
801097f8:	e8 54 f9 ff ff       	call   80109151 <lcr3>
801097fd:	83 c4 04             	add    $0x4,%esp
}
80109800:	90                   	nop
80109801:	c9                   	leave  
80109802:	c3                   	ret    

80109803 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80109803:	55                   	push   %ebp
80109804:	89 e5                	mov    %esp,%ebp
80109806:	56                   	push   %esi
80109807:	53                   	push   %ebx
  pushcli();
80109808:	e8 c5 d1 ff ff       	call   801069d2 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
8010980d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109813:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010981a:	83 c2 08             	add    $0x8,%edx
8010981d:	89 d6                	mov    %edx,%esi
8010981f:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80109826:	83 c2 08             	add    $0x8,%edx
80109829:	c1 ea 10             	shr    $0x10,%edx
8010982c:	89 d3                	mov    %edx,%ebx
8010982e:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80109835:	83 c2 08             	add    $0x8,%edx
80109838:	c1 ea 18             	shr    $0x18,%edx
8010983b:	89 d1                	mov    %edx,%ecx
8010983d:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80109844:	67 00 
80109846:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
8010984d:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80109853:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010985a:	83 e2 f0             	and    $0xfffffff0,%edx
8010985d:	83 ca 09             	or     $0x9,%edx
80109860:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109866:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010986d:	83 ca 10             	or     $0x10,%edx
80109870:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109876:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010987d:	83 e2 9f             	and    $0xffffff9f,%edx
80109880:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109886:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010988d:	83 ca 80             	or     $0xffffff80,%edx
80109890:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109896:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
8010989d:	83 e2 f0             	and    $0xfffffff0,%edx
801098a0:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801098a6:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801098ad:	83 e2 ef             	and    $0xffffffef,%edx
801098b0:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801098b6:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801098bd:	83 e2 df             	and    $0xffffffdf,%edx
801098c0:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801098c6:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801098cd:	83 ca 40             	or     $0x40,%edx
801098d0:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801098d6:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801098dd:	83 e2 7f             	and    $0x7f,%edx
801098e0:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801098e6:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
801098ec:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801098f2:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801098f9:	83 e2 ef             	and    $0xffffffef,%edx
801098fc:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80109902:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109908:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
8010990e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109914:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010991b:	8b 52 08             	mov    0x8(%edx),%edx
8010991e:	81 c2 00 10 00 00    	add    $0x1000,%edx
80109924:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80109927:	83 ec 0c             	sub    $0xc,%esp
8010992a:	6a 30                	push   $0x30
8010992c:	e8 f3 f7 ff ff       	call   80109124 <ltr>
80109931:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80109934:	8b 45 08             	mov    0x8(%ebp),%eax
80109937:	8b 40 04             	mov    0x4(%eax),%eax
8010993a:	85 c0                	test   %eax,%eax
8010993c:	75 0d                	jne    8010994b <switchuvm+0x148>
    panic("switchuvm: no pgdir");
8010993e:	83 ec 0c             	sub    $0xc,%esp
80109941:	68 0b a9 10 80       	push   $0x8010a90b
80109946:	e8 1b 6c ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
8010994b:	8b 45 08             	mov    0x8(%ebp),%eax
8010994e:	8b 40 04             	mov    0x4(%eax),%eax
80109951:	83 ec 0c             	sub    $0xc,%esp
80109954:	50                   	push   %eax
80109955:	e8 03 f8 ff ff       	call   8010915d <v2p>
8010995a:	83 c4 10             	add    $0x10,%esp
8010995d:	83 ec 0c             	sub    $0xc,%esp
80109960:	50                   	push   %eax
80109961:	e8 eb f7 ff ff       	call   80109151 <lcr3>
80109966:	83 c4 10             	add    $0x10,%esp
  popcli();
80109969:	e8 a9 d0 ff ff       	call   80106a17 <popcli>
}
8010996e:	90                   	nop
8010996f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80109972:	5b                   	pop    %ebx
80109973:	5e                   	pop    %esi
80109974:	5d                   	pop    %ebp
80109975:	c3                   	ret    

80109976 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80109976:	55                   	push   %ebp
80109977:	89 e5                	mov    %esp,%ebp
80109979:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
8010997c:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80109983:	76 0d                	jbe    80109992 <inituvm+0x1c>
    panic("inituvm: more than a page");
80109985:	83 ec 0c             	sub    $0xc,%esp
80109988:	68 1f a9 10 80       	push   $0x8010a91f
8010998d:	e8 d4 6b ff ff       	call   80100566 <panic>
  mem = kalloc();
80109992:	e8 6d 93 ff ff       	call   80102d04 <kalloc>
80109997:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010999a:	83 ec 04             	sub    $0x4,%esp
8010999d:	68 00 10 00 00       	push   $0x1000
801099a2:	6a 00                	push   $0x0
801099a4:	ff 75 f4             	pushl  -0xc(%ebp)
801099a7:	e8 2c d1 ff ff       	call   80106ad8 <memset>
801099ac:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
801099af:	83 ec 0c             	sub    $0xc,%esp
801099b2:	ff 75 f4             	pushl  -0xc(%ebp)
801099b5:	e8 a3 f7 ff ff       	call   8010915d <v2p>
801099ba:	83 c4 10             	add    $0x10,%esp
801099bd:	83 ec 0c             	sub    $0xc,%esp
801099c0:	6a 06                	push   $0x6
801099c2:	50                   	push   %eax
801099c3:	68 00 10 00 00       	push   $0x1000
801099c8:	6a 00                	push   $0x0
801099ca:	ff 75 08             	pushl  0x8(%ebp)
801099cd:	e8 ba fc ff ff       	call   8010968c <mappages>
801099d2:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801099d5:	83 ec 04             	sub    $0x4,%esp
801099d8:	ff 75 10             	pushl  0x10(%ebp)
801099db:	ff 75 0c             	pushl  0xc(%ebp)
801099de:	ff 75 f4             	pushl  -0xc(%ebp)
801099e1:	e8 b1 d1 ff ff       	call   80106b97 <memmove>
801099e6:	83 c4 10             	add    $0x10,%esp
}
801099e9:	90                   	nop
801099ea:	c9                   	leave  
801099eb:	c3                   	ret    

801099ec <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801099ec:	55                   	push   %ebp
801099ed:	89 e5                	mov    %esp,%ebp
801099ef:	53                   	push   %ebx
801099f0:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801099f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801099f6:	25 ff 0f 00 00       	and    $0xfff,%eax
801099fb:	85 c0                	test   %eax,%eax
801099fd:	74 0d                	je     80109a0c <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
801099ff:	83 ec 0c             	sub    $0xc,%esp
80109a02:	68 3c a9 10 80       	push   $0x8010a93c
80109a07:	e8 5a 6b ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80109a0c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109a13:	e9 95 00 00 00       	jmp    80109aad <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80109a18:	8b 55 0c             	mov    0xc(%ebp),%edx
80109a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a1e:	01 d0                	add    %edx,%eax
80109a20:	83 ec 04             	sub    $0x4,%esp
80109a23:	6a 00                	push   $0x0
80109a25:	50                   	push   %eax
80109a26:	ff 75 08             	pushl  0x8(%ebp)
80109a29:	e8 be fb ff ff       	call   801095ec <walkpgdir>
80109a2e:	83 c4 10             	add    $0x10,%esp
80109a31:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109a34:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109a38:	75 0d                	jne    80109a47 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80109a3a:	83 ec 0c             	sub    $0xc,%esp
80109a3d:	68 5f a9 10 80       	push   $0x8010a95f
80109a42:	e8 1f 6b ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80109a47:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109a4a:	8b 00                	mov    (%eax),%eax
80109a4c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109a51:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80109a54:	8b 45 18             	mov    0x18(%ebp),%eax
80109a57:	2b 45 f4             	sub    -0xc(%ebp),%eax
80109a5a:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80109a5f:	77 0b                	ja     80109a6c <loaduvm+0x80>
      n = sz - i;
80109a61:	8b 45 18             	mov    0x18(%ebp),%eax
80109a64:	2b 45 f4             	sub    -0xc(%ebp),%eax
80109a67:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109a6a:	eb 07                	jmp    80109a73 <loaduvm+0x87>
    else
      n = PGSIZE;
80109a6c:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80109a73:	8b 55 14             	mov    0x14(%ebp),%edx
80109a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a79:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80109a7c:	83 ec 0c             	sub    $0xc,%esp
80109a7f:	ff 75 e8             	pushl  -0x18(%ebp)
80109a82:	e8 e3 f6 ff ff       	call   8010916a <p2v>
80109a87:	83 c4 10             	add    $0x10,%esp
80109a8a:	ff 75 f0             	pushl  -0x10(%ebp)
80109a8d:	53                   	push   %ebx
80109a8e:	50                   	push   %eax
80109a8f:	ff 75 10             	pushl  0x10(%ebp)
80109a92:	e8 df 84 ff ff       	call   80101f76 <readi>
80109a97:	83 c4 10             	add    $0x10,%esp
80109a9a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80109a9d:	74 07                	je     80109aa6 <loaduvm+0xba>
      return -1;
80109a9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109aa4:	eb 18                	jmp    80109abe <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80109aa6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ab0:	3b 45 18             	cmp    0x18(%ebp),%eax
80109ab3:	0f 82 5f ff ff ff    	jb     80109a18 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80109ab9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109abe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109ac1:	c9                   	leave  
80109ac2:	c3                   	ret    

80109ac3 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80109ac3:	55                   	push   %ebp
80109ac4:	89 e5                	mov    %esp,%ebp
80109ac6:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80109ac9:	8b 45 10             	mov    0x10(%ebp),%eax
80109acc:	85 c0                	test   %eax,%eax
80109ace:	79 0a                	jns    80109ada <allocuvm+0x17>
    return 0;
80109ad0:	b8 00 00 00 00       	mov    $0x0,%eax
80109ad5:	e9 b0 00 00 00       	jmp    80109b8a <allocuvm+0xc7>
  if(newsz < oldsz)
80109ada:	8b 45 10             	mov    0x10(%ebp),%eax
80109add:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109ae0:	73 08                	jae    80109aea <allocuvm+0x27>
    return oldsz;
80109ae2:	8b 45 0c             	mov    0xc(%ebp),%eax
80109ae5:	e9 a0 00 00 00       	jmp    80109b8a <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80109aea:	8b 45 0c             	mov    0xc(%ebp),%eax
80109aed:	05 ff 0f 00 00       	add    $0xfff,%eax
80109af2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109af7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80109afa:	eb 7f                	jmp    80109b7b <allocuvm+0xb8>
    mem = kalloc();
80109afc:	e8 03 92 ff ff       	call   80102d04 <kalloc>
80109b01:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80109b04:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109b08:	75 2b                	jne    80109b35 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80109b0a:	83 ec 0c             	sub    $0xc,%esp
80109b0d:	68 7d a9 10 80       	push   $0x8010a97d
80109b12:	e8 af 68 ff ff       	call   801003c6 <cprintf>
80109b17:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80109b1a:	83 ec 04             	sub    $0x4,%esp
80109b1d:	ff 75 0c             	pushl  0xc(%ebp)
80109b20:	ff 75 10             	pushl  0x10(%ebp)
80109b23:	ff 75 08             	pushl  0x8(%ebp)
80109b26:	e8 61 00 00 00       	call   80109b8c <deallocuvm>
80109b2b:	83 c4 10             	add    $0x10,%esp
      return 0;
80109b2e:	b8 00 00 00 00       	mov    $0x0,%eax
80109b33:	eb 55                	jmp    80109b8a <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
80109b35:	83 ec 04             	sub    $0x4,%esp
80109b38:	68 00 10 00 00       	push   $0x1000
80109b3d:	6a 00                	push   $0x0
80109b3f:	ff 75 f0             	pushl  -0x10(%ebp)
80109b42:	e8 91 cf ff ff       	call   80106ad8 <memset>
80109b47:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80109b4a:	83 ec 0c             	sub    $0xc,%esp
80109b4d:	ff 75 f0             	pushl  -0x10(%ebp)
80109b50:	e8 08 f6 ff ff       	call   8010915d <v2p>
80109b55:	83 c4 10             	add    $0x10,%esp
80109b58:	89 c2                	mov    %eax,%edx
80109b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b5d:	83 ec 0c             	sub    $0xc,%esp
80109b60:	6a 06                	push   $0x6
80109b62:	52                   	push   %edx
80109b63:	68 00 10 00 00       	push   $0x1000
80109b68:	50                   	push   %eax
80109b69:	ff 75 08             	pushl  0x8(%ebp)
80109b6c:	e8 1b fb ff ff       	call   8010968c <mappages>
80109b71:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80109b74:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109b7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b7e:	3b 45 10             	cmp    0x10(%ebp),%eax
80109b81:	0f 82 75 ff ff ff    	jb     80109afc <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80109b87:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109b8a:	c9                   	leave  
80109b8b:	c3                   	ret    

80109b8c <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80109b8c:	55                   	push   %ebp
80109b8d:	89 e5                	mov    %esp,%ebp
80109b8f:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80109b92:	8b 45 10             	mov    0x10(%ebp),%eax
80109b95:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109b98:	72 08                	jb     80109ba2 <deallocuvm+0x16>
    return oldsz;
80109b9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b9d:	e9 a5 00 00 00       	jmp    80109c47 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80109ba2:	8b 45 10             	mov    0x10(%ebp),%eax
80109ba5:	05 ff 0f 00 00       	add    $0xfff,%eax
80109baa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109baf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80109bb2:	e9 81 00 00 00       	jmp    80109c38 <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80109bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bba:	83 ec 04             	sub    $0x4,%esp
80109bbd:	6a 00                	push   $0x0
80109bbf:	50                   	push   %eax
80109bc0:	ff 75 08             	pushl  0x8(%ebp)
80109bc3:	e8 24 fa ff ff       	call   801095ec <walkpgdir>
80109bc8:	83 c4 10             	add    $0x10,%esp
80109bcb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80109bce:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109bd2:	75 09                	jne    80109bdd <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80109bd4:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80109bdb:	eb 54                	jmp    80109c31 <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
80109bdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109be0:	8b 00                	mov    (%eax),%eax
80109be2:	83 e0 01             	and    $0x1,%eax
80109be5:	85 c0                	test   %eax,%eax
80109be7:	74 48                	je     80109c31 <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
80109be9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bec:	8b 00                	mov    (%eax),%eax
80109bee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109bf3:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80109bf6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109bfa:	75 0d                	jne    80109c09 <deallocuvm+0x7d>
        panic("kfree");
80109bfc:	83 ec 0c             	sub    $0xc,%esp
80109bff:	68 95 a9 10 80       	push   $0x8010a995
80109c04:	e8 5d 69 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
80109c09:	83 ec 0c             	sub    $0xc,%esp
80109c0c:	ff 75 ec             	pushl  -0x14(%ebp)
80109c0f:	e8 56 f5 ff ff       	call   8010916a <p2v>
80109c14:	83 c4 10             	add    $0x10,%esp
80109c17:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80109c1a:	83 ec 0c             	sub    $0xc,%esp
80109c1d:	ff 75 e8             	pushl  -0x18(%ebp)
80109c20:	e8 42 90 ff ff       	call   80102c67 <kfree>
80109c25:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80109c28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c2b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80109c31:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c3b:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109c3e:	0f 82 73 ff ff ff    	jb     80109bb7 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80109c44:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109c47:	c9                   	leave  
80109c48:	c3                   	ret    

80109c49 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80109c49:	55                   	push   %ebp
80109c4a:	89 e5                	mov    %esp,%ebp
80109c4c:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80109c4f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80109c53:	75 0d                	jne    80109c62 <freevm+0x19>
    panic("freevm: no pgdir");
80109c55:	83 ec 0c             	sub    $0xc,%esp
80109c58:	68 9b a9 10 80       	push   $0x8010a99b
80109c5d:	e8 04 69 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80109c62:	83 ec 04             	sub    $0x4,%esp
80109c65:	6a 00                	push   $0x0
80109c67:	68 00 00 00 80       	push   $0x80000000
80109c6c:	ff 75 08             	pushl  0x8(%ebp)
80109c6f:	e8 18 ff ff ff       	call   80109b8c <deallocuvm>
80109c74:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80109c77:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109c7e:	eb 4f                	jmp    80109ccf <freevm+0x86>
    if(pgdir[i] & PTE_P){
80109c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c83:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109c8a:	8b 45 08             	mov    0x8(%ebp),%eax
80109c8d:	01 d0                	add    %edx,%eax
80109c8f:	8b 00                	mov    (%eax),%eax
80109c91:	83 e0 01             	and    $0x1,%eax
80109c94:	85 c0                	test   %eax,%eax
80109c96:	74 33                	je     80109ccb <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80109c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c9b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109ca2:	8b 45 08             	mov    0x8(%ebp),%eax
80109ca5:	01 d0                	add    %edx,%eax
80109ca7:	8b 00                	mov    (%eax),%eax
80109ca9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109cae:	83 ec 0c             	sub    $0xc,%esp
80109cb1:	50                   	push   %eax
80109cb2:	e8 b3 f4 ff ff       	call   8010916a <p2v>
80109cb7:	83 c4 10             	add    $0x10,%esp
80109cba:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80109cbd:	83 ec 0c             	sub    $0xc,%esp
80109cc0:	ff 75 f0             	pushl  -0x10(%ebp)
80109cc3:	e8 9f 8f ff ff       	call   80102c67 <kfree>
80109cc8:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80109ccb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109ccf:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80109cd6:	76 a8                	jbe    80109c80 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80109cd8:	83 ec 0c             	sub    $0xc,%esp
80109cdb:	ff 75 08             	pushl  0x8(%ebp)
80109cde:	e8 84 8f ff ff       	call   80102c67 <kfree>
80109ce3:	83 c4 10             	add    $0x10,%esp
}
80109ce6:	90                   	nop
80109ce7:	c9                   	leave  
80109ce8:	c3                   	ret    

80109ce9 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80109ce9:	55                   	push   %ebp
80109cea:	89 e5                	mov    %esp,%ebp
80109cec:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109cef:	83 ec 04             	sub    $0x4,%esp
80109cf2:	6a 00                	push   $0x0
80109cf4:	ff 75 0c             	pushl  0xc(%ebp)
80109cf7:	ff 75 08             	pushl  0x8(%ebp)
80109cfa:	e8 ed f8 ff ff       	call   801095ec <walkpgdir>
80109cff:	83 c4 10             	add    $0x10,%esp
80109d02:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80109d05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109d09:	75 0d                	jne    80109d18 <clearpteu+0x2f>
    panic("clearpteu");
80109d0b:	83 ec 0c             	sub    $0xc,%esp
80109d0e:	68 ac a9 10 80       	push   $0x8010a9ac
80109d13:	e8 4e 68 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
80109d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d1b:	8b 00                	mov    (%eax),%eax
80109d1d:	83 e0 fb             	and    $0xfffffffb,%eax
80109d20:	89 c2                	mov    %eax,%edx
80109d22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d25:	89 10                	mov    %edx,(%eax)
}
80109d27:	90                   	nop
80109d28:	c9                   	leave  
80109d29:	c3                   	ret    

80109d2a <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80109d2a:	55                   	push   %ebp
80109d2b:	89 e5                	mov    %esp,%ebp
80109d2d:	53                   	push   %ebx
80109d2e:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80109d31:	e8 e6 f9 ff ff       	call   8010971c <setupkvm>
80109d36:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109d39:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109d3d:	75 0a                	jne    80109d49 <copyuvm+0x1f>
    return 0;
80109d3f:	b8 00 00 00 00       	mov    $0x0,%eax
80109d44:	e9 f8 00 00 00       	jmp    80109e41 <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
80109d49:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109d50:	e9 c4 00 00 00       	jmp    80109e19 <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80109d55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d58:	83 ec 04             	sub    $0x4,%esp
80109d5b:	6a 00                	push   $0x0
80109d5d:	50                   	push   %eax
80109d5e:	ff 75 08             	pushl  0x8(%ebp)
80109d61:	e8 86 f8 ff ff       	call   801095ec <walkpgdir>
80109d66:	83 c4 10             	add    $0x10,%esp
80109d69:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109d6c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109d70:	75 0d                	jne    80109d7f <copyuvm+0x55>
      panic("copyuvm: pte should exist");
80109d72:	83 ec 0c             	sub    $0xc,%esp
80109d75:	68 b6 a9 10 80       	push   $0x8010a9b6
80109d7a:	e8 e7 67 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
80109d7f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d82:	8b 00                	mov    (%eax),%eax
80109d84:	83 e0 01             	and    $0x1,%eax
80109d87:	85 c0                	test   %eax,%eax
80109d89:	75 0d                	jne    80109d98 <copyuvm+0x6e>
      panic("copyuvm: page not present");
80109d8b:	83 ec 0c             	sub    $0xc,%esp
80109d8e:	68 d0 a9 10 80       	push   $0x8010a9d0
80109d93:	e8 ce 67 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80109d98:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d9b:	8b 00                	mov    (%eax),%eax
80109d9d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109da2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80109da5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109da8:	8b 00                	mov    (%eax),%eax
80109daa:	25 ff 0f 00 00       	and    $0xfff,%eax
80109daf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80109db2:	e8 4d 8f ff ff       	call   80102d04 <kalloc>
80109db7:	89 45 e0             	mov    %eax,-0x20(%ebp)
80109dba:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80109dbe:	74 6a                	je     80109e2a <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80109dc0:	83 ec 0c             	sub    $0xc,%esp
80109dc3:	ff 75 e8             	pushl  -0x18(%ebp)
80109dc6:	e8 9f f3 ff ff       	call   8010916a <p2v>
80109dcb:	83 c4 10             	add    $0x10,%esp
80109dce:	83 ec 04             	sub    $0x4,%esp
80109dd1:	68 00 10 00 00       	push   $0x1000
80109dd6:	50                   	push   %eax
80109dd7:	ff 75 e0             	pushl  -0x20(%ebp)
80109dda:	e8 b8 cd ff ff       	call   80106b97 <memmove>
80109ddf:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80109de2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80109de5:	83 ec 0c             	sub    $0xc,%esp
80109de8:	ff 75 e0             	pushl  -0x20(%ebp)
80109deb:	e8 6d f3 ff ff       	call   8010915d <v2p>
80109df0:	83 c4 10             	add    $0x10,%esp
80109df3:	89 c2                	mov    %eax,%edx
80109df5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109df8:	83 ec 0c             	sub    $0xc,%esp
80109dfb:	53                   	push   %ebx
80109dfc:	52                   	push   %edx
80109dfd:	68 00 10 00 00       	push   $0x1000
80109e02:	50                   	push   %eax
80109e03:	ff 75 f0             	pushl  -0x10(%ebp)
80109e06:	e8 81 f8 ff ff       	call   8010968c <mappages>
80109e0b:	83 c4 20             	add    $0x20,%esp
80109e0e:	85 c0                	test   %eax,%eax
80109e10:	78 1b                	js     80109e2d <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80109e12:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109e19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e1c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109e1f:	0f 82 30 ff ff ff    	jb     80109d55 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80109e25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e28:	eb 17                	jmp    80109e41 <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80109e2a:	90                   	nop
80109e2b:	eb 01                	jmp    80109e2e <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
80109e2d:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80109e2e:	83 ec 0c             	sub    $0xc,%esp
80109e31:	ff 75 f0             	pushl  -0x10(%ebp)
80109e34:	e8 10 fe ff ff       	call   80109c49 <freevm>
80109e39:	83 c4 10             	add    $0x10,%esp
  return 0;
80109e3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109e41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109e44:	c9                   	leave  
80109e45:	c3                   	ret    

80109e46 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80109e46:	55                   	push   %ebp
80109e47:	89 e5                	mov    %esp,%ebp
80109e49:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109e4c:	83 ec 04             	sub    $0x4,%esp
80109e4f:	6a 00                	push   $0x0
80109e51:	ff 75 0c             	pushl  0xc(%ebp)
80109e54:	ff 75 08             	pushl  0x8(%ebp)
80109e57:	e8 90 f7 ff ff       	call   801095ec <walkpgdir>
80109e5c:	83 c4 10             	add    $0x10,%esp
80109e5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80109e62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e65:	8b 00                	mov    (%eax),%eax
80109e67:	83 e0 01             	and    $0x1,%eax
80109e6a:	85 c0                	test   %eax,%eax
80109e6c:	75 07                	jne    80109e75 <uva2ka+0x2f>
    return 0;
80109e6e:	b8 00 00 00 00       	mov    $0x0,%eax
80109e73:	eb 29                	jmp    80109e9e <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80109e75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e78:	8b 00                	mov    (%eax),%eax
80109e7a:	83 e0 04             	and    $0x4,%eax
80109e7d:	85 c0                	test   %eax,%eax
80109e7f:	75 07                	jne    80109e88 <uva2ka+0x42>
    return 0;
80109e81:	b8 00 00 00 00       	mov    $0x0,%eax
80109e86:	eb 16                	jmp    80109e9e <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
80109e88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e8b:	8b 00                	mov    (%eax),%eax
80109e8d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109e92:	83 ec 0c             	sub    $0xc,%esp
80109e95:	50                   	push   %eax
80109e96:	e8 cf f2 ff ff       	call   8010916a <p2v>
80109e9b:	83 c4 10             	add    $0x10,%esp
}
80109e9e:	c9                   	leave  
80109e9f:	c3                   	ret    

80109ea0 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80109ea0:	55                   	push   %ebp
80109ea1:	89 e5                	mov    %esp,%ebp
80109ea3:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80109ea6:	8b 45 10             	mov    0x10(%ebp),%eax
80109ea9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80109eac:	eb 7f                	jmp    80109f2d <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80109eae:	8b 45 0c             	mov    0xc(%ebp),%eax
80109eb1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109eb6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80109eb9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ebc:	83 ec 08             	sub    $0x8,%esp
80109ebf:	50                   	push   %eax
80109ec0:	ff 75 08             	pushl  0x8(%ebp)
80109ec3:	e8 7e ff ff ff       	call   80109e46 <uva2ka>
80109ec8:	83 c4 10             	add    $0x10,%esp
80109ecb:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80109ece:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80109ed2:	75 07                	jne    80109edb <copyout+0x3b>
      return -1;
80109ed4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109ed9:	eb 61                	jmp    80109f3c <copyout+0x9c>
    n = PGSIZE - (va - va0);
80109edb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ede:	2b 45 0c             	sub    0xc(%ebp),%eax
80109ee1:	05 00 10 00 00       	add    $0x1000,%eax
80109ee6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80109ee9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109eec:	3b 45 14             	cmp    0x14(%ebp),%eax
80109eef:	76 06                	jbe    80109ef7 <copyout+0x57>
      n = len;
80109ef1:	8b 45 14             	mov    0x14(%ebp),%eax
80109ef4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80109ef7:	8b 45 0c             	mov    0xc(%ebp),%eax
80109efa:	2b 45 ec             	sub    -0x14(%ebp),%eax
80109efd:	89 c2                	mov    %eax,%edx
80109eff:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f02:	01 d0                	add    %edx,%eax
80109f04:	83 ec 04             	sub    $0x4,%esp
80109f07:	ff 75 f0             	pushl  -0x10(%ebp)
80109f0a:	ff 75 f4             	pushl  -0xc(%ebp)
80109f0d:	50                   	push   %eax
80109f0e:	e8 84 cc ff ff       	call   80106b97 <memmove>
80109f13:	83 c4 10             	add    $0x10,%esp
    len -= n;
80109f16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f19:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80109f1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f1f:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80109f22:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f25:	05 00 10 00 00       	add    $0x1000,%eax
80109f2a:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80109f2d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80109f31:	0f 85 77 ff ff ff    	jne    80109eae <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80109f37:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109f3c:	c9                   	leave  
80109f3d:	c3                   	ret    

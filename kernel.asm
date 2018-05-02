
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
8010003d:	68 44 92 10 80       	push   $0x80109244
80100042:	68 80 d6 10 80       	push   $0x8010d680
80100047:	e8 60 5b 00 00       	call   80105bac <initlock>
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
801000c1:	e8 08 5b 00 00       	call   80105bce <acquire>
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
8010010c:	e8 24 5b 00 00       	call   80105c35 <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 80 d6 10 80       	push   $0x8010d680
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 80 4f 00 00       	call   801050ac <sleep>
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
80100188:	e8 a8 5a 00 00       	call   80105c35 <release>
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
801001aa:	68 4b 92 10 80       	push   $0x8010924b
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
80100204:	68 5c 92 10 80       	push   $0x8010925c
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
80100243:	68 63 92 10 80       	push   $0x80109263
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 80 d6 10 80       	push   $0x8010d680
80100255:	e8 74 59 00 00       	call   80105bce <acquire>
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
801002b9:	e8 3d 4f 00 00       	call   801051fb <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 80 d6 10 80       	push   $0x8010d680
801002c9:	e8 67 59 00 00       	call   80105c35 <release>
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
801003e2:	e8 e7 57 00 00       	call   80105bce <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 6a 92 10 80       	push   $0x8010926a
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
801004cd:	c7 45 ec 73 92 10 80 	movl   $0x80109273,-0x14(%ebp)
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
8010055b:	e8 d5 56 00 00       	call   80105c35 <release>
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
8010058b:	68 7a 92 10 80       	push   $0x8010927a
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
801005aa:	68 89 92 10 80       	push   $0x80109289
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 c0 56 00 00       	call   80105c87 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 8b 92 10 80       	push   $0x8010928b
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
801006ca:	68 8f 92 10 80       	push   $0x8010928f
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
801006f7:	e8 f4 57 00 00       	call   80105ef0 <memmove>
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
80100721:	e8 0b 57 00 00       	call   80105e31 <memset>
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
801007b6:	e8 11 71 00 00       	call   801078cc <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 04 71 00 00       	call   801078cc <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 f7 70 00 00       	call   801078cc <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 e7 70 00 00       	call   801078cc <uartputc>
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
  int dopids = 0;
80100806:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  int dofree = 0;
8010080d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int dosleep = 0;
80100814:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  int dozombie = 0;
8010081b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

  acquire(&cons.lock);
80100822:	83 ec 0c             	sub    $0xc,%esp
80100825:	68 e0 c5 10 80       	push   $0x8010c5e0
8010082a:	e8 9f 53 00 00       	call   80105bce <acquire>
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
      break;
    case C('Z'):
      dozombie = 1;
      break;
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
      break;
    case C('Z'):
      dozombie = 1;
      break;
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
801009c8:	e8 2e 48 00 00       	call   801051fb <wakeup>
801009cd:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
801009d0:	90                   	nop
  int dofree = 0;
  int dosleep = 0;
  int dozombie = 0;

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
801009eb:	e8 45 52 00 00       	call   80105c35 <release>
801009f0:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009f7:	74 05                	je     801009fe <consoleintr+0x205>
    procdump();  // now call procdump() wo. cons.lock held
801009f9:	e8 f1 48 00 00       	call   801052ef <procdump>
  }
  if(dopids) {
801009fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100a02:	74 05                	je     80100a09 <consoleintr+0x210>
    piddump();
80100a04:	e8 21 4f 00 00       	call   8010592a <piddump>
  }
  if(dofree) {
80100a09:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100a0d:	74 05                	je     80100a14 <consoleintr+0x21b>
    freedump();
80100a0f:	e8 af 4f 00 00       	call   801059c3 <freedump>
  }
  if(dosleep) {
80100a14:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100a18:	74 05                	je     80100a1f <consoleintr+0x226>
    sleepdump();
80100a1a:	e8 07 50 00 00       	call   80105a26 <sleepdump>
  }
  if(dozombie) {
80100a1f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a23:	74 05                	je     80100a2a <consoleintr+0x231>
    zombiedump();
80100a25:	e8 95 50 00 00       	call   80105abf <zombiedump>
  }
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
80100a4f:	e8 7a 51 00 00       	call   80105bce <acquire>
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
80100a71:	e8 bf 51 00 00       	call   80105c35 <release>
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
80100a9e:	e8 09 46 00 00       	call   801050ac <sleep>
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
80100b1c:	e8 14 51 00 00       	call   80105c35 <release>
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
80100b5a:	e8 6f 50 00 00       	call   80105bce <acquire>
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
80100b9c:	e8 94 50 00 00       	call   80105c35 <release>
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
80100bc0:	68 a2 92 10 80       	push   $0x801092a2
80100bc5:	68 e0 c5 10 80       	push   $0x8010c5e0
80100bca:	e8 dd 4f 00 00       	call   80105bac <initlock>
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
80100c88:	e8 94 7d 00 00       	call   80108a21 <setupkvm>
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
80100d0e:	e8 b5 80 00 00       	call   80108dc8 <allocuvm>
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
80100d41:	e8 ab 7f 00 00       	call   80108cf1 <loaduvm>
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
80100db0:	e8 13 80 00 00       	call   80108dc8 <allocuvm>
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
80100dd4:	e8 15 82 00 00       	call   80108fee <clearpteu>
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
80100e0d:	e8 6c 52 00 00       	call   8010607e <strlen>
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
80100e3a:	e8 3f 52 00 00       	call   8010607e <strlen>
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
80100e60:	e8 40 83 00 00       	call   801091a5 <copyout>
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
80100efc:	e8 a4 82 00 00       	call   801091a5 <copyout>
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
80100f4d:	e8 e2 50 00 00       	call   80106034 <safestrcpy>
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
80100fa3:	e8 60 7b 00 00       	call   80108b08 <switchuvm>
80100fa8:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100fab:	83 ec 0c             	sub    $0xc,%esp
80100fae:	ff 75 d0             	pushl  -0x30(%ebp)
80100fb1:	e8 98 7f 00 00       	call   80108f4e <freevm>
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
80100feb:	e8 5e 7f 00 00       	call   80108f4e <freevm>
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
8010101c:	68 aa 92 10 80       	push   $0x801092aa
80101021:	68 40 18 11 80       	push   $0x80111840
80101026:	e8 81 4b 00 00       	call   80105bac <initlock>
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
8010103f:	e8 8a 4b 00 00       	call   80105bce <acquire>
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
8010106c:	e8 c4 4b 00 00       	call   80105c35 <release>
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
8010108f:	e8 a1 4b 00 00       	call   80105c35 <release>
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
801010ac:	e8 1d 4b 00 00       	call   80105bce <acquire>
801010b1:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b4:	8b 45 08             	mov    0x8(%ebp),%eax
801010b7:	8b 40 04             	mov    0x4(%eax),%eax
801010ba:	85 c0                	test   %eax,%eax
801010bc:	7f 0d                	jg     801010cb <filedup+0x2d>
    panic("filedup");
801010be:	83 ec 0c             	sub    $0xc,%esp
801010c1:	68 b1 92 10 80       	push   $0x801092b1
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
801010e2:	e8 4e 4b 00 00       	call   80105c35 <release>
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
801010fd:	e8 cc 4a 00 00       	call   80105bce <acquire>
80101102:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101105:	8b 45 08             	mov    0x8(%ebp),%eax
80101108:	8b 40 04             	mov    0x4(%eax),%eax
8010110b:	85 c0                	test   %eax,%eax
8010110d:	7f 0d                	jg     8010111c <fileclose+0x2d>
    panic("fileclose");
8010110f:	83 ec 0c             	sub    $0xc,%esp
80101112:	68 b9 92 10 80       	push   $0x801092b9
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
8010113d:	e8 f3 4a 00 00       	call   80105c35 <release>
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
8010118b:	e8 a5 4a 00 00       	call   80105c35 <release>
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
801012da:	68 c3 92 10 80       	push   $0x801092c3
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
801013dd:	68 cc 92 10 80       	push   $0x801092cc
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
80101413:	68 dc 92 10 80       	push   $0x801092dc
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
8010144b:	e8 a0 4a 00 00       	call   80105ef0 <memmove>
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
80101491:	e8 9b 49 00 00       	call   80105e31 <memset>
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
801015f8:	68 e8 92 10 80       	push   $0x801092e8
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
8010168b:	68 fe 92 10 80       	push   $0x801092fe
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
801016e8:	68 11 93 10 80       	push   $0x80109311
801016ed:	68 60 22 11 80       	push   $0x80112260
801016f2:	e8 b5 44 00 00       	call   80105bac <initlock>
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
80101741:	68 18 93 10 80       	push   $0x80109318
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
801017ba:	e8 72 46 00 00       	call   80105e31 <memset>
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
80101822:	68 6b 93 10 80       	push   $0x8010936b
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
801018c8:	e8 23 46 00 00       	call   80105ef0 <memmove>
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
801018fd:	e8 cc 42 00 00       	call   80105bce <acquire>
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
8010194b:	e8 e5 42 00 00       	call   80105c35 <release>
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
80101984:	68 7d 93 10 80       	push   $0x8010937d
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
801019c1:	e8 6f 42 00 00       	call   80105c35 <release>
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
801019dc:	e8 ed 41 00 00       	call   80105bce <acquire>
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
801019fb:	e8 35 42 00 00       	call   80105c35 <release>
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
80101a21:	68 8d 93 10 80       	push   $0x8010938d
80101a26:	e8 3b eb ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101a2b:	83 ec 0c             	sub    $0xc,%esp
80101a2e:	68 60 22 11 80       	push   $0x80112260
80101a33:	e8 96 41 00 00       	call   80105bce <acquire>
80101a38:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
80101a3b:	eb 13                	jmp    80101a50 <ilock+0x48>
    sleep(ip, &icache.lock);
80101a3d:	83 ec 08             	sub    $0x8,%esp
80101a40:	68 60 22 11 80       	push   $0x80112260
80101a45:	ff 75 08             	pushl  0x8(%ebp)
80101a48:	e8 5f 36 00 00       	call   801050ac <sleep>
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
80101a76:	e8 ba 41 00 00       	call   80105c35 <release>
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
80101b23:	e8 c8 43 00 00       	call   80105ef0 <memmove>
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
80101b59:	68 93 93 10 80       	push   $0x80109393
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
80101b8c:	68 a2 93 10 80       	push   $0x801093a2
80101b91:	e8 d0 e9 ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101b96:	83 ec 0c             	sub    $0xc,%esp
80101b99:	68 60 22 11 80       	push   $0x80112260
80101b9e:	e8 2b 40 00 00       	call   80105bce <acquire>
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
80101bbd:	e8 39 36 00 00       	call   801051fb <wakeup>
80101bc2:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101bc5:	83 ec 0c             	sub    $0xc,%esp
80101bc8:	68 60 22 11 80       	push   $0x80112260
80101bcd:	e8 63 40 00 00       	call   80105c35 <release>
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
80101be6:	e8 e3 3f 00 00       	call   80105bce <acquire>
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
80101c2e:	68 aa 93 10 80       	push   $0x801093aa
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
80101c51:	e8 df 3f 00 00       	call   80105c35 <release>
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
80101c86:	e8 43 3f 00 00       	call   80105bce <acquire>
80101c8b:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101c8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c91:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101c98:	83 ec 0c             	sub    $0xc,%esp
80101c9b:	ff 75 08             	pushl  0x8(%ebp)
80101c9e:	e8 58 35 00 00       	call   801051fb <wakeup>
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
80101cbd:	e8 73 3f 00 00       	call   80105c35 <release>
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
80101dfd:	68 b4 93 10 80       	push   $0x801093b4
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
80102094:	e8 57 3e 00 00       	call   80105ef0 <memmove>
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
801021e6:	e8 05 3d 00 00       	call   80105ef0 <memmove>
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
80102266:	e8 1b 3d 00 00       	call   80105f86 <strncmp>
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
80102286:	68 c7 93 10 80       	push   $0x801093c7
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
801022b5:	68 d9 93 10 80       	push   $0x801093d9
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
8010238a:	68 d9 93 10 80       	push   $0x801093d9
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
801023c5:	e8 12 3c 00 00       	call   80105fdc <strncpy>
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
801023f1:	68 e6 93 10 80       	push   $0x801093e6
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
80102467:	e8 84 3a 00 00       	call   80105ef0 <memmove>
8010246c:	83 c4 10             	add    $0x10,%esp
8010246f:	eb 26                	jmp    80102497 <skipelem+0x95>
  else {
    memmove(name, s, len);
80102471:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102474:	83 ec 04             	sub    $0x4,%esp
80102477:	50                   	push   %eax
80102478:	ff 75 f4             	pushl  -0xc(%ebp)
8010247b:	ff 75 0c             	pushl  0xc(%ebp)
8010247e:	e8 6d 3a 00 00       	call   80105ef0 <memmove>
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
801026d3:	68 ee 93 10 80       	push   $0x801093ee
801026d8:	68 20 c6 10 80       	push   $0x8010c620
801026dd:	e8 ca 34 00 00       	call   80105bac <initlock>
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
80102787:	68 f2 93 10 80       	push   $0x801093f2
8010278c:	e8 d5 dd ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE)
80102791:	8b 45 08             	mov    0x8(%ebp),%eax
80102794:	8b 40 08             	mov    0x8(%eax),%eax
80102797:	3d cf 07 00 00       	cmp    $0x7cf,%eax
8010279c:	76 0d                	jbe    801027ab <idestart+0x33>
    panic("incorrect blockno");
8010279e:	83 ec 0c             	sub    $0xc,%esp
801027a1:	68 fb 93 10 80       	push   $0x801093fb
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
801027ca:	68 f2 93 10 80       	push   $0x801093f2
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
801028e4:	e8 e5 32 00 00       	call   80105bce <acquire>
801028e9:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
801028ec:	a1 54 c6 10 80       	mov    0x8010c654,%eax
801028f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801028f8:	75 15                	jne    8010290f <ideintr+0x39>
    release(&idelock);
801028fa:	83 ec 0c             	sub    $0xc,%esp
801028fd:	68 20 c6 10 80       	push   $0x8010c620
80102902:	e8 2e 33 00 00       	call   80105c35 <release>
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
80102977:	e8 7f 28 00 00       	call   801051fb <wakeup>
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
801029a1:	e8 8f 32 00 00       	call   80105c35 <release>
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
801029c0:	68 0d 94 10 80       	push   $0x8010940d
801029c5:	e8 9c db ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801029ca:	8b 45 08             	mov    0x8(%ebp),%eax
801029cd:	8b 00                	mov    (%eax),%eax
801029cf:	83 e0 06             	and    $0x6,%eax
801029d2:	83 f8 02             	cmp    $0x2,%eax
801029d5:	75 0d                	jne    801029e4 <iderw+0x39>
    panic("iderw: nothing to do");
801029d7:	83 ec 0c             	sub    $0xc,%esp
801029da:	68 21 94 10 80       	push   $0x80109421
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
801029fa:	68 36 94 10 80       	push   $0x80109436
801029ff:	e8 62 db ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102a04:	83 ec 0c             	sub    $0xc,%esp
80102a07:	68 20 c6 10 80       	push   $0x8010c620
80102a0c:	e8 bd 31 00 00       	call   80105bce <acquire>
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
80102a68:	e8 3f 26 00 00       	call   801050ac <sleep>
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
80102a85:	e8 ab 31 00 00       	call   80105c35 <release>
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
80102b16:	68 54 94 10 80       	push   $0x80109454
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
80102bd6:	68 86 94 10 80       	push   $0x80109486
80102bdb:	68 40 32 11 80       	push   $0x80113240
80102be0:	e8 c7 2f 00 00       	call   80105bac <initlock>
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
80102c97:	68 8b 94 10 80       	push   $0x8010948b
80102c9c:	e8 c5 d8 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102ca1:	83 ec 04             	sub    $0x4,%esp
80102ca4:	68 00 10 00 00       	push   $0x1000
80102ca9:	6a 01                	push   $0x1
80102cab:	ff 75 08             	pushl  0x8(%ebp)
80102cae:	e8 7e 31 00 00       	call   80105e31 <memset>
80102cb3:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102cb6:	a1 74 32 11 80       	mov    0x80113274,%eax
80102cbb:	85 c0                	test   %eax,%eax
80102cbd:	74 10                	je     80102ccf <kfree+0x68>
    acquire(&kmem.lock);
80102cbf:	83 ec 0c             	sub    $0xc,%esp
80102cc2:	68 40 32 11 80       	push   $0x80113240
80102cc7:	e8 02 2f 00 00       	call   80105bce <acquire>
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
80102cf9:	e8 37 2f 00 00       	call   80105c35 <release>
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
80102d1b:	e8 ae 2e 00 00       	call   80105bce <acquire>
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
80102d4c:	e8 e4 2e 00 00       	call   80105c35 <release>
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
80103097:	68 94 94 10 80       	push   $0x80109494
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
801032c2:	e8 d1 2b 00 00       	call   80105e98 <memcmp>
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
801033d6:	68 c0 94 10 80       	push   $0x801094c0
801033db:	68 80 32 11 80       	push   $0x80113280
801033e0:	e8 c7 27 00 00       	call   80105bac <initlock>
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
8010348b:	e8 60 2a 00 00       	call   80105ef0 <memmove>
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
801035f9:	e8 d0 25 00 00       	call   80105bce <acquire>
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
80103617:	e8 90 1a 00 00       	call   801050ac <sleep>
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
8010364c:	e8 5b 1a 00 00       	call   801050ac <sleep>
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
8010366b:	e8 c5 25 00 00       	call   80105c35 <release>
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
8010368c:	e8 3d 25 00 00       	call   80105bce <acquire>
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
801036ad:	68 c4 94 10 80       	push   $0x801094c4
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
801036db:	e8 1b 1b 00 00       	call   801051fb <wakeup>
801036e0:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801036e3:	83 ec 0c             	sub    $0xc,%esp
801036e6:	68 80 32 11 80       	push   $0x80113280
801036eb:	e8 45 25 00 00       	call   80105c35 <release>
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
80103706:	e8 c3 24 00 00       	call   80105bce <acquire>
8010370b:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010370e:	c7 05 c0 32 11 80 00 	movl   $0x0,0x801132c0
80103715:	00 00 00 
    wakeup(&log);
80103718:	83 ec 0c             	sub    $0xc,%esp
8010371b:	68 80 32 11 80       	push   $0x80113280
80103720:	e8 d6 1a 00 00       	call   801051fb <wakeup>
80103725:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103728:	83 ec 0c             	sub    $0xc,%esp
8010372b:	68 80 32 11 80       	push   $0x80113280
80103730:	e8 00 25 00 00       	call   80105c35 <release>
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
801037ac:	e8 3f 27 00 00       	call   80105ef0 <memmove>
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
80103848:	68 d3 94 10 80       	push   $0x801094d3
8010384d:	e8 14 cd ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
80103852:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103857:	85 c0                	test   %eax,%eax
80103859:	7f 0d                	jg     80103868 <log_write+0x45>
    panic("log_write outside of trans");
8010385b:	83 ec 0c             	sub    $0xc,%esp
8010385e:	68 e9 94 10 80       	push   $0x801094e9
80103863:	e8 fe cc ff ff       	call   80100566 <panic>

  acquire(&log.lock);
80103868:	83 ec 0c             	sub    $0xc,%esp
8010386b:	68 80 32 11 80       	push   $0x80113280
80103870:	e8 59 23 00 00       	call   80105bce <acquire>
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
801038ee:	e8 42 23 00 00       	call   80105c35 <release>
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
80103953:	e8 7b 51 00 00       	call   80108ad3 <kvmalloc>
  mpinit();        // collect info about this machine
80103958:	e8 43 04 00 00       	call   80103da0 <mpinit>
  lapicinit();
8010395d:	e8 ea f5 ff ff       	call   80102f4c <lapicinit>
  seginit();       // set up segments
80103962:	e8 15 4b 00 00       	call   8010847c <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103967:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010396d:	0f b6 00             	movzbl (%eax),%eax
80103970:	0f b6 c0             	movzbl %al,%eax
80103973:	83 ec 08             	sub    $0x8,%esp
80103976:	50                   	push   %eax
80103977:	68 04 95 10 80       	push   $0x80109504
8010397c:	e8 45 ca ff ff       	call   801003c6 <cprintf>
80103981:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
80103984:	e8 6d 06 00 00       	call   80103ff6 <picinit>
  ioapicinit();    // another interrupt controller
80103989:	e8 34 f1 ff ff       	call   80102ac2 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010398e:	e8 24 d2 ff ff       	call   80100bb7 <consoleinit>
  uartinit();      // serial port
80103993:	e8 40 3e 00 00       	call   801077d8 <uartinit>
  pinit();         // process table
80103998:	e8 5d 0b 00 00       	call   801044fa <pinit>
  tvinit();        // trap vectors
8010399d:	e8 0f 3a 00 00       	call   801073b1 <tvinit>
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
801039ba:	e8 43 39 00 00       	call   80107302 <timerinit>
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
801039e9:	e8 fd 50 00 00       	call   80108aeb <switchkvm>
  seginit();
801039ee:	e8 89 4a 00 00       	call   8010847c <seginit>
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
80103a13:	68 1b 95 10 80       	push   $0x8010951b
80103a18:	e8 a9 c9 ff ff       	call   801003c6 <cprintf>
80103a1d:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103a20:	e8 ed 3a 00 00       	call   80107512 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103a25:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103a2b:	05 a8 00 00 00       	add    $0xa8,%eax
80103a30:	83 ec 08             	sub    $0x8,%esp
80103a33:	6a 01                	push   $0x1
80103a35:	50                   	push   %eax
80103a36:	e8 d8 fe ff ff       	call   80103913 <xchg>
80103a3b:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103a3e:	e8 aa 13 00 00       	call   80104ded <scheduler>

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
80103a6b:	e8 80 24 00 00       	call   80105ef0 <memmove>
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
80103bf9:	68 2c 95 10 80       	push   $0x8010952c
80103bfe:	ff 75 f4             	pushl  -0xc(%ebp)
80103c01:	e8 92 22 00 00       	call   80105e98 <memcmp>
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
80103d37:	68 31 95 10 80       	push   $0x80109531
80103d3c:	ff 75 f0             	pushl  -0x10(%ebp)
80103d3f:	e8 54 21 00 00       	call   80105e98 <memcmp>
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
80103e13:	8b 04 85 74 95 10 80 	mov    -0x7fef6a8c(,%eax,4),%eax
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
80103e49:	68 36 95 10 80       	push   $0x80109536
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
80103edc:	68 54 95 10 80       	push   $0x80109554
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
8010417d:	68 88 95 10 80       	push   $0x80109588
80104182:	50                   	push   %eax
80104183:	e8 24 1a 00 00       	call   80105bac <initlock>
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
8010423f:	e8 8a 19 00 00       	call   80105bce <acquire>
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
80104266:	e8 90 0f 00 00       	call   801051fb <wakeup>
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
80104289:	e8 6d 0f 00 00       	call   801051fb <wakeup>
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
801042b2:	e8 7e 19 00 00       	call   80105c35 <release>
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
801042d1:	e8 5f 19 00 00       	call   80105c35 <release>
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
801042e9:	e8 e0 18 00 00       	call   80105bce <acquire>
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
8010431e:	e8 12 19 00 00       	call   80105c35 <release>
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
8010433c:	e8 ba 0e 00 00       	call   801051fb <wakeup>
80104341:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104344:	8b 45 08             	mov    0x8(%ebp),%eax
80104347:	8b 55 08             	mov    0x8(%ebp),%edx
8010434a:	81 c2 38 02 00 00    	add    $0x238,%edx
80104350:	83 ec 08             	sub    $0x8,%esp
80104353:	50                   	push   %eax
80104354:	52                   	push   %edx
80104355:	e8 52 0d 00 00       	call   801050ac <sleep>
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
801043be:	e8 38 0e 00 00       	call   801051fb <wakeup>
801043c3:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801043c6:	8b 45 08             	mov    0x8(%ebp),%eax
801043c9:	83 ec 0c             	sub    $0xc,%esp
801043cc:	50                   	push   %eax
801043cd:	e8 63 18 00 00       	call   80105c35 <release>
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
801043e8:	e8 e1 17 00 00       	call   80105bce <acquire>
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
80104406:	e8 2a 18 00 00       	call   80105c35 <release>
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
80104429:	e8 7e 0c 00 00       	call   801050ac <sleep>
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
801044bd:	e8 39 0d 00 00       	call   801051fb <wakeup>
801044c2:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801044c5:	8b 45 08             	mov    0x8(%ebp),%eax
801044c8:	83 ec 0c             	sub    $0xc,%esp
801044cb:	50                   	push   %eax
801044cc:	e8 64 17 00 00       	call   80105c35 <release>
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
80104503:	68 90 95 10 80       	push   $0x80109590
80104508:	68 80 39 11 80       	push   $0x80113980
8010450d:	e8 9a 16 00 00       	call   80105bac <initlock>
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
80104526:	e8 a3 16 00 00       	call   80105bce <acquire>
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
80104546:	e8 a4 10 00 00       	call   801055ef <stateListRemove>
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
80104569:	e8 22 10 00 00       	call   80105590 <stateListAdd>
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
801045cf:	e8 61 16 00 00       	call   80105c35 <release>
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
80104608:	e8 e2 0f 00 00       	call   801055ef <stateListRemove>
8010460d:	83 c4 10             	add    $0x10,%esp
    stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail,p);
80104610:	83 ec 04             	sub    $0x4,%esp
80104613:	ff 75 f4             	pushl  -0xc(%ebp)
80104616:	68 c0 5e 11 80       	push   $0x80115ec0
8010461b:	68 bc 5e 11 80       	push   $0x80115ebc
80104620:	e8 6b 0f 00 00       	call   80105590 <stateListAdd>
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
8010464e:	ba 5f 73 10 80       	mov    $0x8010735f,%edx
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
80104673:	e8 b9 17 00 00       	call   80105e31 <memset>
80104678:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
8010467b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010467e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104681:	ba 66 50 10 80       	mov    $0x80105066,%edx
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
8010469c:	e8 2d 15 00 00       	call   80105bce <acquire>
801046a1:	83 c4 10             	add    $0x10,%esp
  initProcessLists();
801046a4:	e8 15 10 00 00       	call   801056be <initProcessLists>
  initFreeList();
801046a9:	e8 8e 10 00 00       	call   8010573c <initFreeList>
  release(&ptable.lock);
801046ae:	83 ec 0c             	sub    $0xc,%esp
801046b1:	68 80 39 11 80       	push   $0x80113980
801046b6:	e8 7a 15 00 00       	call   80105c35 <release>
801046bb:	83 c4 10             	add    $0x10,%esp
#endif
  p = allocproc();
801046be:	e8 55 fe ff ff       	call   80104518 <allocproc>
801046c3:	89 45 f4             	mov    %eax,-0xc(%ebp)

  initproc = p;
801046c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c9:	a3 68 c6 10 80       	mov    %eax,0x8010c668
  if((p->pgdir = setupkvm()) == 0)
801046ce:	e8 4e 43 00 00       	call   80108a21 <setupkvm>
801046d3:	89 c2                	mov    %eax,%edx
801046d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d8:	89 50 04             	mov    %edx,0x4(%eax)
801046db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046de:	8b 40 04             	mov    0x4(%eax),%eax
801046e1:	85 c0                	test   %eax,%eax
801046e3:	75 0d                	jne    801046f2 <userinit+0x64>
    panic("userinit: out of memory?");
801046e5:	83 ec 0c             	sub    $0xc,%esp
801046e8:	68 97 95 10 80       	push   $0x80109597
801046ed:	e8 74 be ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801046f2:	ba 2c 00 00 00       	mov    $0x2c,%edx
801046f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046fa:	8b 40 04             	mov    0x4(%eax),%eax
801046fd:	83 ec 04             	sub    $0x4,%esp
80104700:	52                   	push   %edx
80104701:	68 00 c5 10 80       	push   $0x8010c500
80104706:	50                   	push   %eax
80104707:	e8 6f 45 00 00       	call   80108c7b <inituvm>
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
80104726:	e8 06 17 00 00       	call   80105e31 <memset>
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
801047a0:	68 b0 95 10 80       	push   $0x801095b0
801047a5:	50                   	push   %eax
801047a6:	e8 89 18 00 00       	call   80106034 <safestrcpy>
801047ab:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801047ae:	83 ec 0c             	sub    $0xc,%esp
801047b1:	68 b9 95 10 80       	push   $0x801095b9
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
801047d8:	e8 f1 13 00 00       	call   80105bce <acquire>
801047dd:	83 c4 10             	add    $0x10,%esp
  stateListRemove(&ptable.pLists.embryo, &ptable.pLists.embryoTail, p);
801047e0:	83 ec 04             	sub    $0x4,%esp
801047e3:	ff 75 f4             	pushl  -0xc(%ebp)
801047e6:	68 e0 5e 11 80       	push   $0x80115ee0
801047eb:	68 dc 5e 11 80       	push   $0x80115edc
801047f0:	e8 fa 0d 00 00       	call   801055ef <stateListRemove>
801047f5:	83 c4 10             	add    $0x10,%esp
  stateListAdd(&ptable.pLists.ready, &ptable.pLists.readyTail, p);
801047f8:	83 ec 04             	sub    $0x4,%esp
801047fb:	ff 75 f4             	pushl  -0xc(%ebp)
801047fe:	68 b8 5e 11 80       	push   $0x80115eb8
80104803:	68 b4 5e 11 80       	push   $0x80115eb4
80104808:	e8 83 0d 00 00       	call   80105590 <stateListAdd>
8010480d:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104810:	83 ec 0c             	sub    $0xc,%esp
80104813:	68 80 39 11 80       	push   $0x80113980
80104818:	e8 18 14 00 00       	call   80105c35 <release>
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
8010486d:	e8 56 45 00 00       	call   80108dc8 <allocuvm>
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
801048a4:	e8 e8 45 00 00       	call   80108e91 <deallocuvm>
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
801048d1:	e8 32 42 00 00       	call   80108b08 <switchuvm>
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
80104917:	e8 13 47 00 00       	call   8010902f <copyuvm>
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
80104963:	e8 66 12 00 00       	call   80105bce <acquire>
80104968:	83 c4 10             	add    $0x10,%esp
    stateListRemove(&ptable.pLists.embryo, &ptable.pLists.embryoTail, np);
8010496b:	83 ec 04             	sub    $0x4,%esp
8010496e:	ff 75 e0             	pushl  -0x20(%ebp)
80104971:	68 e0 5e 11 80       	push   $0x80115ee0
80104976:	68 dc 5e 11 80       	push   $0x80115edc
8010497b:	e8 6f 0c 00 00       	call   801055ef <stateListRemove>
80104980:	83 c4 10             	add    $0x10,%esp
    stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail, np);
80104983:	83 ec 04             	sub    $0x4,%esp
80104986:	ff 75 e0             	pushl  -0x20(%ebp)
80104989:	68 c0 5e 11 80       	push   $0x80115ec0
8010498e:	68 bc 5e 11 80       	push   $0x80115ebc
80104993:	e8 f8 0b 00 00       	call   80105590 <stateListAdd>
80104998:	83 c4 10             	add    $0x10,%esp
    release(&ptable.lock);
8010499b:	83 ec 0c             	sub    $0xc,%esp
8010499e:	68 80 39 11 80       	push   $0x80113980
801049a3:	e8 8d 12 00 00       	call   80105c35 <release>
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
80104a7f:	e8 b0 15 00 00       	call   80106034 <safestrcpy>
80104a84:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104a87:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a8a:	8b 40 10             	mov    0x10(%eax),%eax
80104a8d:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104a90:	83 ec 0c             	sub    $0xc,%esp
80104a93:	68 80 39 11 80       	push   $0x80113980
80104a98:	e8 31 11 00 00       	call   80105bce <acquire>
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
80104aba:	e8 30 0b 00 00       	call   801055ef <stateListRemove>
80104abf:	83 c4 10             	add    $0x10,%esp
  stateListAdd(&ptable.pLists.ready, &ptable.pLists.readyTail, np);
80104ac2:	83 ec 04             	sub    $0x4,%esp
80104ac5:	ff 75 e0             	pushl  -0x20(%ebp)
80104ac8:	68 b8 5e 11 80       	push   $0x80115eb8
80104acd:	68 b4 5e 11 80       	push   $0x80115eb4
80104ad2:	e8 b9 0a 00 00       	call   80105590 <stateListAdd>
80104ad7:	83 c4 10             	add    $0x10,%esp
#endif
  release(&ptable.lock);
80104ada:	83 ec 0c             	sub    $0xc,%esp
80104add:	68 80 39 11 80       	push   $0x80113980
80104ae2:	e8 4e 11 00 00       	call   80105c35 <release>
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
80104b38:	68 bb 95 10 80       	push   $0x801095bb
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
80104bcd:	e8 fc 0f 00 00       	call   80105bce <acquire>
80104bd2:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104bd5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bdb:	8b 40 14             	mov    0x14(%eax),%eax
80104bde:	83 ec 0c             	sub    $0xc,%esp
80104be1:	50                   	push   %eax
80104be2:	e8 a2 05 00 00       	call   80105189 <wakeup1>
80104be7:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bea:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104bf1:	eb 3f                	jmp    80104c32 <exit+0x113>
    if(p->parent == proc){
80104bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf6:	8b 50 14             	mov    0x14(%eax),%edx
80104bf9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bff:	39 c2                	cmp    %eax,%edx
80104c01:	75 28                	jne    80104c2b <exit+0x10c>
      p->parent = initproc;
80104c03:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
80104c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c0c:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104c0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c12:	8b 40 0c             	mov    0xc(%eax),%eax
80104c15:	83 f8 05             	cmp    $0x5,%eax
80104c18:	75 11                	jne    80104c2b <exit+0x10c>
        wakeup1(initproc);
80104c1a:	a1 68 c6 10 80       	mov    0x8010c668,%eax
80104c1f:	83 ec 0c             	sub    $0xc,%esp
80104c22:	50                   	push   %eax
80104c23:	e8 61 05 00 00       	call   80105189 <wakeup1>
80104c28:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c2b:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
80104c32:	81 7d f4 b4 5e 11 80 	cmpl   $0x80115eb4,-0xc(%ebp)
80104c39:	72 b8                	jb     80104bf3 <exit+0xd4>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104c3b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c41:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  stateListRemove(&ptable.pLists.running, &ptable.pLists.runningTail, proc);
80104c48:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c4e:	83 ec 04             	sub    $0x4,%esp
80104c51:	50                   	push   %eax
80104c52:	68 d8 5e 11 80       	push   $0x80115ed8
80104c57:	68 d4 5e 11 80       	push   $0x80115ed4
80104c5c:	e8 8e 09 00 00       	call   801055ef <stateListRemove>
80104c61:	83 c4 10             	add    $0x10,%esp
  stateListAdd(&ptable.pLists.zombie, &ptable.pLists.zombieTail, proc);
80104c64:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c6a:	83 ec 04             	sub    $0x4,%esp
80104c6d:	50                   	push   %eax
80104c6e:	68 d0 5e 11 80       	push   $0x80115ed0
80104c73:	68 cc 5e 11 80       	push   $0x80115ecc
80104c78:	e8 13 09 00 00       	call   80105590 <stateListAdd>
80104c7d:	83 c4 10             	add    $0x10,%esp
  sched();
80104c80:	e8 b2 02 00 00       	call   80104f37 <sched>
  panic("zombie exit");
80104c85:	83 ec 0c             	sub    $0xc,%esp
80104c88:	68 c8 95 10 80       	push   $0x801095c8
80104c8d:	e8 d4 b8 ff ff       	call   80100566 <panic>

80104c92 <wait>:
  }
}
#else
int
wait(void)
{
80104c92:	55                   	push   %ebp
80104c93:	89 e5                	mov    %esp,%ebp
80104c95:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104c98:	83 ec 0c             	sub    $0xc,%esp
80104c9b:	68 80 39 11 80       	push   $0x80113980
80104ca0:	e8 29 0f 00 00       	call   80105bce <acquire>
80104ca5:	83 c4 10             	add    $0x10,%esp
  //TODO Implement this
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104ca8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104caf:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104cb6:	e9 dd 00 00 00       	jmp    80104d98 <wait+0x106>
      if(p->parent != proc)
80104cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cbe:	8b 50 14             	mov    0x14(%eax),%edx
80104cc1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cc7:	39 c2                	cmp    %eax,%edx
80104cc9:	0f 85 c1 00 00 00    	jne    80104d90 <wait+0xfe>
        continue;
      havekids = 1;
80104ccf:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cd9:	8b 40 0c             	mov    0xc(%eax),%eax
80104cdc:	83 f8 05             	cmp    $0x5,%eax
80104cdf:	0f 85 ac 00 00 00    	jne    80104d91 <wait+0xff>
        // Found one.
        pid = p->pid;
80104ce5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ce8:	8b 40 10             	mov    0x10(%eax),%eax
80104ceb:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cf1:	8b 40 08             	mov    0x8(%eax),%eax
80104cf4:	83 ec 0c             	sub    $0xc,%esp
80104cf7:	50                   	push   %eax
80104cf8:	e8 6a df ff ff       	call   80102c67 <kfree>
80104cfd:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d03:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d0d:	8b 40 04             	mov    0x4(%eax),%eax
80104d10:	83 ec 0c             	sub    $0xc,%esp
80104d13:	50                   	push   %eax
80104d14:	e8 35 42 00 00       	call   80108f4e <freevm>
80104d19:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80104d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d1f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d29:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104d30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d33:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104d3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d3d:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104d41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d44:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        stateListRemove(&ptable.pLists.zombie, &ptable.pLists.zombieTail, p);
80104d4b:	83 ec 04             	sub    $0x4,%esp
80104d4e:	ff 75 f4             	pushl  -0xc(%ebp)
80104d51:	68 d0 5e 11 80       	push   $0x80115ed0
80104d56:	68 cc 5e 11 80       	push   $0x80115ecc
80104d5b:	e8 8f 08 00 00       	call   801055ef <stateListRemove>
80104d60:	83 c4 10             	add    $0x10,%esp
        stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail, p);
80104d63:	83 ec 04             	sub    $0x4,%esp
80104d66:	ff 75 f4             	pushl  -0xc(%ebp)
80104d69:	68 c0 5e 11 80       	push   $0x80115ec0
80104d6e:	68 bc 5e 11 80       	push   $0x80115ebc
80104d73:	e8 18 08 00 00       	call   80105590 <stateListAdd>
80104d78:	83 c4 10             	add    $0x10,%esp
        release(&ptable.lock);
80104d7b:	83 ec 0c             	sub    $0xc,%esp
80104d7e:	68 80 39 11 80       	push   $0x80113980
80104d83:	e8 ad 0e 00 00       	call   80105c35 <release>
80104d88:	83 c4 10             	add    $0x10,%esp
        return pid;
80104d8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d8e:	eb 5b                	jmp    80104deb <wait+0x159>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104d90:	90                   	nop
  acquire(&ptable.lock);
  //TODO Implement this
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d91:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
80104d98:	81 7d f4 b4 5e 11 80 	cmpl   $0x80115eb4,-0xc(%ebp)
80104d9f:	0f 82 16 ff ff ff    	jb     80104cbb <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104da5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104da9:	74 0d                	je     80104db8 <wait+0x126>
80104dab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104db1:	8b 40 24             	mov    0x24(%eax),%eax
80104db4:	85 c0                	test   %eax,%eax
80104db6:	74 17                	je     80104dcf <wait+0x13d>
      release(&ptable.lock);
80104db8:	83 ec 0c             	sub    $0xc,%esp
80104dbb:	68 80 39 11 80       	push   $0x80113980
80104dc0:	e8 70 0e 00 00       	call   80105c35 <release>
80104dc5:	83 c4 10             	add    $0x10,%esp
      return -1;
80104dc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dcd:	eb 1c                	jmp    80104deb <wait+0x159>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104dcf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dd5:	83 ec 08             	sub    $0x8,%esp
80104dd8:	68 80 39 11 80       	push   $0x80113980
80104ddd:	50                   	push   %eax
80104dde:	e8 c9 02 00 00       	call   801050ac <sleep>
80104de3:	83 c4 10             	add    $0x10,%esp
  }
80104de6:	e9 bd fe ff ff       	jmp    80104ca8 <wait+0x16>

}
80104deb:	c9                   	leave  
80104dec:	c3                   	ret    

80104ded <scheduler>:
}

#else
void
scheduler(void)
{
80104ded:	55                   	push   %ebp
80104dee:	89 e5                	mov    %esp,%ebp
80104df0:	53                   	push   %ebx
80104df1:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;
  int idle;  // for checking if processor is idle

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104df4:	e8 fa f6 ff ff       	call   801044f3 <sti>

    idle = 1;  // assume idle unless we schedule a process
80104df9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104e00:	83 ec 0c             	sub    $0xc,%esp
80104e03:	68 80 39 11 80       	push   $0x80113980
80104e08:	e8 c1 0d 00 00       	call   80105bce <acquire>
80104e0d:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e10:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104e17:	e9 e5 00 00 00       	jmp    80104f01 <scheduler+0x114>
      if(p->state != RUNNABLE)
80104e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e1f:	8b 40 0c             	mov    0xc(%eax),%eax
80104e22:	83 f8 03             	cmp    $0x3,%eax
80104e25:	0f 85 ce 00 00 00    	jne    80104ef9 <scheduler+0x10c>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      idle = 0;  // not idle this timeslice
80104e2b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      proc = p;
80104e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e35:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104e3b:	83 ec 0c             	sub    $0xc,%esp
80104e3e:	ff 75 f4             	pushl  -0xc(%ebp)
80104e41:	e8 c2 3c 00 00       	call   80108b08 <switchuvm>
80104e46:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104e49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e4c:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      stateListRemove(&ptable.pLists.ready, &ptable.pLists.readyTail, p);
80104e53:	83 ec 04             	sub    $0x4,%esp
80104e56:	ff 75 f4             	pushl  -0xc(%ebp)
80104e59:	68 b8 5e 11 80       	push   $0x80115eb8
80104e5e:	68 b4 5e 11 80       	push   $0x80115eb4
80104e63:	e8 87 07 00 00       	call   801055ef <stateListRemove>
80104e68:	83 c4 10             	add    $0x10,%esp
      stateListAdd(&ptable.pLists.running, &ptable.pLists.runningTail, p);
80104e6b:	83 ec 04             	sub    $0x4,%esp
80104e6e:	ff 75 f4             	pushl  -0xc(%ebp)
80104e71:	68 d8 5e 11 80       	push   $0x80115ed8
80104e76:	68 d4 5e 11 80       	push   $0x80115ed4
80104e7b:	e8 10 07 00 00       	call   80105590 <stateListAdd>
80104e80:	83 c4 10             	add    $0x10,%esp

      proc->cpu_ticks_in = ticks;
80104e83:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e89:	8b 15 00 67 11 80    	mov    0x80116700,%edx
80104e8f:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)

      swtch(&cpu->scheduler, proc->context);
80104e95:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e9b:	8b 40 1c             	mov    0x1c(%eax),%eax
80104e9e:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104ea5:	83 c2 04             	add    $0x4,%edx
80104ea8:	83 ec 08             	sub    $0x8,%esp
80104eab:	50                   	push   %eax
80104eac:	52                   	push   %edx
80104ead:	e8 f3 11 00 00       	call   801060a5 <swtch>
80104eb2:	83 c4 10             	add    $0x10,%esp

      proc->cpu_ticks_total = proc->cpu_ticks_total + (ticks - proc->cpu_ticks_in);
80104eb5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ebb:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104ec2:	8b 8a 88 00 00 00    	mov    0x88(%edx),%ecx
80104ec8:	8b 1d 00 67 11 80    	mov    0x80116700,%ebx
80104ece:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104ed5:	8b 92 8c 00 00 00    	mov    0x8c(%edx),%edx
80104edb:	29 d3                	sub    %edx,%ebx
80104edd:	89 da                	mov    %ebx,%edx
80104edf:	01 ca                	add    %ecx,%edx
80104ee1:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
      switchkvm();
80104ee7:	e8 ff 3b 00 00       	call   80108aeb <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104eec:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104ef3:	00 00 00 00 
80104ef7:	eb 01                	jmp    80104efa <scheduler+0x10d>
    idle = 1;  // assume idle unless we schedule a process
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80104ef9:	90                   	nop
    sti();

    idle = 1;  // assume idle unless we schedule a process
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104efa:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
80104f01:	81 7d f4 b4 5e 11 80 	cmpl   $0x80115eb4,-0xc(%ebp)
80104f08:	0f 82 0e ff ff ff    	jb     80104e1c <scheduler+0x2f>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104f0e:	83 ec 0c             	sub    $0xc,%esp
80104f11:	68 80 39 11 80       	push   $0x80113980
80104f16:	e8 1a 0d 00 00       	call   80105c35 <release>
80104f1b:	83 c4 10             	add    $0x10,%esp
    // if idle, wait for next interrupt
    if (idle) {
80104f1e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104f22:	0f 84 cc fe ff ff    	je     80104df4 <scheduler+0x7>
      sti();
80104f28:	e8 c6 f5 ff ff       	call   801044f3 <sti>
      hlt();
80104f2d:	e8 aa f5 ff ff       	call   801044dc <hlt>
    }
  }
80104f32:	e9 bd fe ff ff       	jmp    80104df4 <scheduler+0x7>

80104f37 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104f37:	55                   	push   %ebp
80104f38:	89 e5                	mov    %esp,%ebp
80104f3a:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80104f3d:	83 ec 0c             	sub    $0xc,%esp
80104f40:	68 80 39 11 80       	push   $0x80113980
80104f45:	e8 b7 0d 00 00       	call   80105d01 <holding>
80104f4a:	83 c4 10             	add    $0x10,%esp
80104f4d:	85 c0                	test   %eax,%eax
80104f4f:	75 0d                	jne    80104f5e <sched+0x27>
    panic("sched ptable.lock");
80104f51:	83 ec 0c             	sub    $0xc,%esp
80104f54:	68 d4 95 10 80       	push   $0x801095d4
80104f59:	e8 08 b6 ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
80104f5e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f64:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104f6a:	83 f8 01             	cmp    $0x1,%eax
80104f6d:	74 0d                	je     80104f7c <sched+0x45>
    panic("sched locks");
80104f6f:	83 ec 0c             	sub    $0xc,%esp
80104f72:	68 e6 95 10 80       	push   $0x801095e6
80104f77:	e8 ea b5 ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
80104f7c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f82:	8b 40 0c             	mov    0xc(%eax),%eax
80104f85:	83 f8 04             	cmp    $0x4,%eax
80104f88:	75 0d                	jne    80104f97 <sched+0x60>
    panic("sched running");
80104f8a:	83 ec 0c             	sub    $0xc,%esp
80104f8d:	68 f2 95 10 80       	push   $0x801095f2
80104f92:	e8 cf b5 ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
80104f97:	e8 47 f5 ff ff       	call   801044e3 <readeflags>
80104f9c:	25 00 02 00 00       	and    $0x200,%eax
80104fa1:	85 c0                	test   %eax,%eax
80104fa3:	74 0d                	je     80104fb2 <sched+0x7b>
    panic("sched interruptible");
80104fa5:	83 ec 0c             	sub    $0xc,%esp
80104fa8:	68 00 96 10 80       	push   $0x80109600
80104fad:	e8 b4 b5 ff ff       	call   80100566 <panic>
  intena = cpu->intena;
80104fb2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104fb8:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104fbe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104fc1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104fc7:	8b 40 04             	mov    0x4(%eax),%eax
80104fca:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104fd1:	83 c2 1c             	add    $0x1c,%edx
80104fd4:	83 ec 08             	sub    $0x8,%esp
80104fd7:	50                   	push   %eax
80104fd8:	52                   	push   %edx
80104fd9:	e8 c7 10 00 00       	call   801060a5 <swtch>
80104fde:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80104fe1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104fe7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104fea:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104ff0:	90                   	nop
80104ff1:	c9                   	leave  
80104ff2:	c3                   	ret    

80104ff3 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104ff3:	55                   	push   %ebp
80104ff4:	89 e5                	mov    %esp,%ebp
80104ff6:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104ff9:	83 ec 0c             	sub    $0xc,%esp
80104ffc:	68 80 39 11 80       	push   $0x80113980
80105001:	e8 c8 0b 00 00       	call   80105bce <acquire>
80105006:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80105009:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010500f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
#ifdef CS333_P3P4
  stateListRemove(&ptable.pLists.running, &ptable.pLists.runningTail, proc);
80105016:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010501c:	83 ec 04             	sub    $0x4,%esp
8010501f:	50                   	push   %eax
80105020:	68 d8 5e 11 80       	push   $0x80115ed8
80105025:	68 d4 5e 11 80       	push   $0x80115ed4
8010502a:	e8 c0 05 00 00       	call   801055ef <stateListRemove>
8010502f:	83 c4 10             	add    $0x10,%esp
  stateListAdd(&ptable.pLists.ready, &ptable.pLists.readyTail, proc);
80105032:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105038:	83 ec 04             	sub    $0x4,%esp
8010503b:	50                   	push   %eax
8010503c:	68 b8 5e 11 80       	push   $0x80115eb8
80105041:	68 b4 5e 11 80       	push   $0x80115eb4
80105046:	e8 45 05 00 00       	call   80105590 <stateListAdd>
8010504b:	83 c4 10             	add    $0x10,%esp
#endif
  sched();
8010504e:	e8 e4 fe ff ff       	call   80104f37 <sched>
  release(&ptable.lock);
80105053:	83 ec 0c             	sub    $0xc,%esp
80105056:	68 80 39 11 80       	push   $0x80113980
8010505b:	e8 d5 0b 00 00       	call   80105c35 <release>
80105060:	83 c4 10             	add    $0x10,%esp
}
80105063:	90                   	nop
80105064:	c9                   	leave  
80105065:	c3                   	ret    

80105066 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80105066:	55                   	push   %ebp
80105067:	89 e5                	mov    %esp,%ebp
80105069:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010506c:	83 ec 0c             	sub    $0xc,%esp
8010506f:	68 80 39 11 80       	push   $0x80113980
80105074:	e8 bc 0b 00 00       	call   80105c35 <release>
80105079:	83 c4 10             	add    $0x10,%esp

  if (first) {
8010507c:	a1 20 c0 10 80       	mov    0x8010c020,%eax
80105081:	85 c0                	test   %eax,%eax
80105083:	74 24                	je     801050a9 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80105085:	c7 05 20 c0 10 80 00 	movl   $0x0,0x8010c020
8010508c:	00 00 00 
    iinit(ROOTDEV);
8010508f:	83 ec 0c             	sub    $0xc,%esp
80105092:	6a 01                	push   $0x1
80105094:	e8 43 c6 ff ff       	call   801016dc <iinit>
80105099:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
8010509c:	83 ec 0c             	sub    $0xc,%esp
8010509f:	6a 01                	push   $0x1
801050a1:	e8 27 e3 ff ff       	call   801033cd <initlog>
801050a6:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801050a9:	90                   	nop
801050aa:	c9                   	leave  
801050ab:	c3                   	ret    

801050ac <sleep>:
// Reacquires lock when awakened.
// 2016/12/28: ticklock removed from xv6. sleep() changed to
// accept a NULL lock to accommodate.
void
sleep(void *chan, struct spinlock *lk)
{
801050ac:	55                   	push   %ebp
801050ad:	89 e5                	mov    %esp,%ebp
801050af:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
801050b2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050b8:	85 c0                	test   %eax,%eax
801050ba:	75 0d                	jne    801050c9 <sleep+0x1d>
    panic("sleep");
801050bc:	83 ec 0c             	sub    $0xc,%esp
801050bf:	68 14 96 10 80       	push   $0x80109614
801050c4:	e8 9d b4 ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){
801050c9:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
801050d0:	74 24                	je     801050f6 <sleep+0x4a>
    acquire(&ptable.lock);
801050d2:	83 ec 0c             	sub    $0xc,%esp
801050d5:	68 80 39 11 80       	push   $0x80113980
801050da:	e8 ef 0a 00 00       	call   80105bce <acquire>
801050df:	83 c4 10             	add    $0x10,%esp
    if (lk) release(lk);
801050e2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801050e6:	74 0e                	je     801050f6 <sleep+0x4a>
801050e8:	83 ec 0c             	sub    $0xc,%esp
801050eb:	ff 75 0c             	pushl  0xc(%ebp)
801050ee:	e8 42 0b 00 00       	call   80105c35 <release>
801050f3:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
801050f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050fc:	8b 55 08             	mov    0x8(%ebp),%edx
801050ff:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80105102:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105108:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
#ifdef CS333_P3P4
  stateListRemove(&ptable.pLists.running, &ptable.pLists.runningTail, proc);
8010510f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105115:	83 ec 04             	sub    $0x4,%esp
80105118:	50                   	push   %eax
80105119:	68 d8 5e 11 80       	push   $0x80115ed8
8010511e:	68 d4 5e 11 80       	push   $0x80115ed4
80105123:	e8 c7 04 00 00       	call   801055ef <stateListRemove>
80105128:	83 c4 10             	add    $0x10,%esp
  stateListAdd(&ptable.pLists.sleep, &ptable.pLists.sleepTail, proc);
8010512b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105131:	83 ec 04             	sub    $0x4,%esp
80105134:	50                   	push   %eax
80105135:	68 c8 5e 11 80       	push   $0x80115ec8
8010513a:	68 c4 5e 11 80       	push   $0x80115ec4
8010513f:	e8 4c 04 00 00       	call   80105590 <stateListAdd>
80105144:	83 c4 10             	add    $0x10,%esp
#endif
  sched();
80105147:	e8 eb fd ff ff       	call   80104f37 <sched>

  // Tidy up.
  proc->chan = 0;
8010514c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105152:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){
80105159:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
80105160:	74 24                	je     80105186 <sleep+0xda>
    release(&ptable.lock);
80105162:	83 ec 0c             	sub    $0xc,%esp
80105165:	68 80 39 11 80       	push   $0x80113980
8010516a:	e8 c6 0a 00 00       	call   80105c35 <release>
8010516f:	83 c4 10             	add    $0x10,%esp
    if (lk) acquire(lk);
80105172:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105176:	74 0e                	je     80105186 <sleep+0xda>
80105178:	83 ec 0c             	sub    $0xc,%esp
8010517b:	ff 75 0c             	pushl  0xc(%ebp)
8010517e:	e8 4b 0a 00 00       	call   80105bce <acquire>
80105183:	83 c4 10             	add    $0x10,%esp
  }
}
80105186:	90                   	nop
80105187:	c9                   	leave  
80105188:	c3                   	ret    

80105189 <wakeup1>:
      p->state = RUNNABLE;
}
#else
static void
wakeup1(void *chan)
{
80105189:	55                   	push   %ebp
8010518a:	89 e5                	mov    %esp,%ebp
8010518c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010518f:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80105196:	eb 57                	jmp    801051ef <wakeup1+0x66>
    if(p->state == SLEEPING && p->chan == chan)
80105198:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010519b:	8b 40 0c             	mov    0xc(%eax),%eax
8010519e:	83 f8 02             	cmp    $0x2,%eax
801051a1:	75 45                	jne    801051e8 <wakeup1+0x5f>
801051a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051a6:	8b 40 20             	mov    0x20(%eax),%eax
801051a9:	3b 45 08             	cmp    0x8(%ebp),%eax
801051ac:	75 3a                	jne    801051e8 <wakeup1+0x5f>
    {
      p->state = RUNNABLE;
801051ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051b1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      stateListRemove(&ptable.pLists.sleep, &ptable.pLists.sleepTail, p);
801051b8:	83 ec 04             	sub    $0x4,%esp
801051bb:	ff 75 f4             	pushl  -0xc(%ebp)
801051be:	68 c8 5e 11 80       	push   $0x80115ec8
801051c3:	68 c4 5e 11 80       	push   $0x80115ec4
801051c8:	e8 22 04 00 00       	call   801055ef <stateListRemove>
801051cd:	83 c4 10             	add    $0x10,%esp
      stateListAdd(&ptable.pLists.ready, &ptable.pLists.readyTail, p);
801051d0:	83 ec 04             	sub    $0x4,%esp
801051d3:	ff 75 f4             	pushl  -0xc(%ebp)
801051d6:	68 b8 5e 11 80       	push   $0x80115eb8
801051db:	68 b4 5e 11 80       	push   $0x80115eb4
801051e0:	e8 ab 03 00 00       	call   80105590 <stateListAdd>
801051e5:	83 c4 10             	add    $0x10,%esp
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801051e8:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
801051ef:	81 7d f4 b4 5e 11 80 	cmpl   $0x80115eb4,-0xc(%ebp)
801051f6:	72 a0                	jb     80105198 <wakeup1+0xf>
    {
      p->state = RUNNABLE;
      stateListRemove(&ptable.pLists.sleep, &ptable.pLists.sleepTail, p);
      stateListAdd(&ptable.pLists.ready, &ptable.pLists.readyTail, p);
    }
}
801051f8:	90                   	nop
801051f9:	c9                   	leave  
801051fa:	c3                   	ret    

801051fb <wakeup>:
#endif

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801051fb:	55                   	push   %ebp
801051fc:	89 e5                	mov    %esp,%ebp
801051fe:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80105201:	83 ec 0c             	sub    $0xc,%esp
80105204:	68 80 39 11 80       	push   $0x80113980
80105209:	e8 c0 09 00 00       	call   80105bce <acquire>
8010520e:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80105211:	83 ec 0c             	sub    $0xc,%esp
80105214:	ff 75 08             	pushl  0x8(%ebp)
80105217:	e8 6d ff ff ff       	call   80105189 <wakeup1>
8010521c:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
8010521f:	83 ec 0c             	sub    $0xc,%esp
80105222:	68 80 39 11 80       	push   $0x80113980
80105227:	e8 09 0a 00 00       	call   80105c35 <release>
8010522c:	83 c4 10             	add    $0x10,%esp
}
8010522f:	90                   	nop
80105230:	c9                   	leave  
80105231:	c3                   	ret    

80105232 <kill>:
  return -1;
}
#else
int
kill(int pid)
{
80105232:	55                   	push   %ebp
80105233:	89 e5                	mov    %esp,%ebp
80105235:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80105238:	83 ec 0c             	sub    $0xc,%esp
8010523b:	68 80 39 11 80       	push   $0x80113980
80105240:	e8 89 09 00 00       	call   80105bce <acquire>
80105245:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105248:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
8010524f:	eb 7a                	jmp    801052cb <kill+0x99>
    if(p->pid == pid){
80105251:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105254:	8b 50 10             	mov    0x10(%eax),%edx
80105257:	8b 45 08             	mov    0x8(%ebp),%eax
8010525a:	39 c2                	cmp    %eax,%edx
8010525c:	75 66                	jne    801052c4 <kill+0x92>
      p->killed = 1;
8010525e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105261:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80105268:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010526b:	8b 40 0c             	mov    0xc(%eax),%eax
8010526e:	83 f8 02             	cmp    $0x2,%eax
80105271:	75 3a                	jne    801052ad <kill+0x7b>
      {
        stateListRemove(&ptable.pLists.sleep, &ptable.pLists.sleepTail, p);
80105273:	83 ec 04             	sub    $0x4,%esp
80105276:	ff 75 f4             	pushl  -0xc(%ebp)
80105279:	68 c8 5e 11 80       	push   $0x80115ec8
8010527e:	68 c4 5e 11 80       	push   $0x80115ec4
80105283:	e8 67 03 00 00       	call   801055ef <stateListRemove>
80105288:	83 c4 10             	add    $0x10,%esp
        stateListAdd(&ptable.pLists.ready, &ptable.pLists.readyTail, p);
8010528b:	83 ec 04             	sub    $0x4,%esp
8010528e:	ff 75 f4             	pushl  -0xc(%ebp)
80105291:	68 b8 5e 11 80       	push   $0x80115eb8
80105296:	68 b4 5e 11 80       	push   $0x80115eb4
8010529b:	e8 f0 02 00 00       	call   80105590 <stateListAdd>
801052a0:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNABLE;
801052a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052a6:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      }
      release(&ptable.lock);
801052ad:	83 ec 0c             	sub    $0xc,%esp
801052b0:	68 80 39 11 80       	push   $0x80113980
801052b5:	e8 7b 09 00 00       	call   80105c35 <release>
801052ba:	83 c4 10             	add    $0x10,%esp
      return 0;
801052bd:	b8 00 00 00 00       	mov    $0x0,%eax
801052c2:	eb 29                	jmp    801052ed <kill+0xbb>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801052c4:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
801052cb:	81 7d f4 b4 5e 11 80 	cmpl   $0x80115eb4,-0xc(%ebp)
801052d2:	0f 82 79 ff ff ff    	jb     80105251 <kill+0x1f>
      }
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
801052d8:	83 ec 0c             	sub    $0xc,%esp
801052db:	68 80 39 11 80       	push   $0x80113980
801052e0:	e8 50 09 00 00       	call   80105c35 <release>
801052e5:	83 c4 10             	add    $0x10,%esp
  return -1;
801052e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

}
801052ed:	c9                   	leave  
801052ee:	c3                   	ret    

801052ef <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801052ef:	55                   	push   %ebp
801052f0:	89 e5                	mov    %esp,%ebp
801052f2:	53                   	push   %ebx
801052f3:	83 ec 44             	sub    $0x44,%esp
  uint current_ticks;
  struct proc *p;
  char *state;
  uint pc[10];
#if defined CS333_P2
  cprintf("\nPID\tName\tUID\tGID\tPPID\tElapsed\tCPU\tState\tSize\t PCs\n");
801052f6:	83 ec 0c             	sub    $0xc,%esp
801052f9:	68 44 96 10 80       	push   $0x80109644
801052fe:	e8 c3 b0 ff ff       	call   801003c6 <cprintf>
80105303:	83 c4 10             	add    $0x10,%esp
#elif defined CS333_P1
  cprintf("\nPID\tState\tName\tElapsed\t PCs\n");
#else
  cprintf("\nPID\tState\tName\t PCs\n");
#endif
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105306:	c7 45 f0 b4 39 11 80 	movl   $0x801139b4,-0x10(%ebp)
8010530d:	e9 6b 02 00 00       	jmp    8010557d <procdump+0x28e>
    if(p->state == UNUSED)
80105312:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105315:	8b 40 0c             	mov    0xc(%eax),%eax
80105318:	85 c0                	test   %eax,%eax
8010531a:	0f 84 55 02 00 00    	je     80105575 <procdump+0x286>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105320:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105323:	8b 40 0c             	mov    0xc(%eax),%eax
80105326:	83 f8 05             	cmp    $0x5,%eax
80105329:	77 23                	ja     8010534e <procdump+0x5f>
8010532b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010532e:	8b 40 0c             	mov    0xc(%eax),%eax
80105331:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105338:	85 c0                	test   %eax,%eax
8010533a:	74 12                	je     8010534e <procdump+0x5f>
      state = states[p->state];
8010533c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010533f:	8b 40 0c             	mov    0xc(%eax),%eax
80105342:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105349:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010534c:	eb 07                	jmp    80105355 <procdump+0x66>
    else
      state = "???";
8010534e:	c7 45 ec 78 96 10 80 	movl   $0x80109678,-0x14(%ebp)
    current_ticks = ticks;
80105355:	a1 00 67 11 80       	mov    0x80116700,%eax
8010535a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    i = ((current_ticks-p->start_ticks)%1000);
8010535d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105360:	8b 40 7c             	mov    0x7c(%eax),%eax
80105363:	8b 55 e8             	mov    -0x18(%ebp),%edx
80105366:	89 d1                	mov    %edx,%ecx
80105368:	29 c1                	sub    %eax,%ecx
8010536a:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
8010536f:	89 c8                	mov    %ecx,%eax
80105371:	f7 e2                	mul    %edx
80105373:	89 d0                	mov    %edx,%eax
80105375:	c1 e8 06             	shr    $0x6,%eax
80105378:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
8010537e:	29 c1                	sub    %eax,%ecx
80105380:	89 c8                	mov    %ecx,%eax
80105382:	89 45 f4             	mov    %eax,-0xc(%ebp)
#if defined CS333_P2
    cprintf("%d\t%s\t%d\t%d", p->pid, p->name, p->uid, p->gid);
80105385:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105388:	8b 88 84 00 00 00    	mov    0x84(%eax),%ecx
8010538e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105391:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80105397:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010539a:	8d 58 6c             	lea    0x6c(%eax),%ebx
8010539d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053a0:	8b 40 10             	mov    0x10(%eax),%eax
801053a3:	83 ec 0c             	sub    $0xc,%esp
801053a6:	51                   	push   %ecx
801053a7:	52                   	push   %edx
801053a8:	53                   	push   %ebx
801053a9:	50                   	push   %eax
801053aa:	68 7c 96 10 80       	push   $0x8010967c
801053af:	e8 12 b0 ff ff       	call   801003c6 <cprintf>
801053b4:	83 c4 20             	add    $0x20,%esp
    if(p->pid == 1)
801053b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053ba:	8b 40 10             	mov    0x10(%eax),%eax
801053bd:	83 f8 01             	cmp    $0x1,%eax
801053c0:	75 19                	jne    801053db <procdump+0xec>
      cprintf("\t%d",p->pid);
801053c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053c5:	8b 40 10             	mov    0x10(%eax),%eax
801053c8:	83 ec 08             	sub    $0x8,%esp
801053cb:	50                   	push   %eax
801053cc:	68 88 96 10 80       	push   $0x80109688
801053d1:	e8 f0 af ff ff       	call   801003c6 <cprintf>
801053d6:	83 c4 10             	add    $0x10,%esp
801053d9:	eb 1a                	jmp    801053f5 <procdump+0x106>
    else
      cprintf("\t%d",p->parent->pid);
801053db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053de:	8b 40 14             	mov    0x14(%eax),%eax
801053e1:	8b 40 10             	mov    0x10(%eax),%eax
801053e4:	83 ec 08             	sub    $0x8,%esp
801053e7:	50                   	push   %eax
801053e8:	68 88 96 10 80       	push   $0x80109688
801053ed:	e8 d4 af ff ff       	call   801003c6 <cprintf>
801053f2:	83 c4 10             	add    $0x10,%esp
    cprintf("\t%d.", ((current_ticks-p->start_ticks)/1000));
801053f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053f8:	8b 40 7c             	mov    0x7c(%eax),%eax
801053fb:	8b 55 e8             	mov    -0x18(%ebp),%edx
801053fe:	29 c2                	sub    %eax,%edx
80105400:	89 d0                	mov    %edx,%eax
80105402:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105407:	f7 e2                	mul    %edx
80105409:	89 d0                	mov    %edx,%eax
8010540b:	c1 e8 06             	shr    $0x6,%eax
8010540e:	83 ec 08             	sub    $0x8,%esp
80105411:	50                   	push   %eax
80105412:	68 8c 96 10 80       	push   $0x8010968c
80105417:	e8 aa af ff ff       	call   801003c6 <cprintf>
8010541c:	83 c4 10             	add    $0x10,%esp
    if (i<100)
8010541f:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
80105423:	7f 10                	jg     80105435 <procdump+0x146>
      cprintf("0");
80105425:	83 ec 0c             	sub    $0xc,%esp
80105428:	68 91 96 10 80       	push   $0x80109691
8010542d:	e8 94 af ff ff       	call   801003c6 <cprintf>
80105432:	83 c4 10             	add    $0x10,%esp
    if (i<10)
80105435:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105439:	7f 10                	jg     8010544b <procdump+0x15c>
      cprintf("0");
8010543b:	83 ec 0c             	sub    $0xc,%esp
8010543e:	68 91 96 10 80       	push   $0x80109691
80105443:	e8 7e af ff ff       	call   801003c6 <cprintf>
80105448:	83 c4 10             	add    $0x10,%esp
    cprintf("%d", i);
8010544b:	83 ec 08             	sub    $0x8,%esp
8010544e:	ff 75 f4             	pushl  -0xc(%ebp)
80105451:	68 93 96 10 80       	push   $0x80109693
80105456:	e8 6b af ff ff       	call   801003c6 <cprintf>
8010545b:	83 c4 10             	add    $0x10,%esp
    i = p->cpu_ticks_total;
8010545e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105461:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80105467:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("\t%d.", i/1000);
8010546a:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010546d:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105472:	89 c8                	mov    %ecx,%eax
80105474:	f7 ea                	imul   %edx
80105476:	c1 fa 06             	sar    $0x6,%edx
80105479:	89 c8                	mov    %ecx,%eax
8010547b:	c1 f8 1f             	sar    $0x1f,%eax
8010547e:	29 c2                	sub    %eax,%edx
80105480:	89 d0                	mov    %edx,%eax
80105482:	83 ec 08             	sub    $0x8,%esp
80105485:	50                   	push   %eax
80105486:	68 8c 96 10 80       	push   $0x8010968c
8010548b:	e8 36 af ff ff       	call   801003c6 <cprintf>
80105490:	83 c4 10             	add    $0x10,%esp
    i = i%1000;
80105493:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80105496:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
8010549b:	89 c8                	mov    %ecx,%eax
8010549d:	f7 ea                	imul   %edx
8010549f:	c1 fa 06             	sar    $0x6,%edx
801054a2:	89 c8                	mov    %ecx,%eax
801054a4:	c1 f8 1f             	sar    $0x1f,%eax
801054a7:	29 c2                	sub    %eax,%edx
801054a9:	89 d0                	mov    %edx,%eax
801054ab:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
801054b1:	29 c1                	sub    %eax,%ecx
801054b3:	89 c8                	mov    %ecx,%eax
801054b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i<100)
801054b8:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
801054bc:	7f 10                	jg     801054ce <procdump+0x1df>
      cprintf("0");
801054be:	83 ec 0c             	sub    $0xc,%esp
801054c1:	68 91 96 10 80       	push   $0x80109691
801054c6:	e8 fb ae ff ff       	call   801003c6 <cprintf>
801054cb:	83 c4 10             	add    $0x10,%esp
    if (i<10)
801054ce:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801054d2:	7f 10                	jg     801054e4 <procdump+0x1f5>
      cprintf("0");
801054d4:	83 ec 0c             	sub    $0xc,%esp
801054d7:	68 91 96 10 80       	push   $0x80109691
801054dc:	e8 e5 ae ff ff       	call   801003c6 <cprintf>
801054e1:	83 c4 10             	add    $0x10,%esp
    cprintf("%d\t%s\t%d\t", i, state, p->sz);
801054e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054e7:	8b 00                	mov    (%eax),%eax
801054e9:	50                   	push   %eax
801054ea:	ff 75 ec             	pushl  -0x14(%ebp)
801054ed:	ff 75 f4             	pushl  -0xc(%ebp)
801054f0:	68 96 96 10 80       	push   $0x80109696
801054f5:	e8 cc ae ff ff       	call   801003c6 <cprintf>
801054fa:	83 c4 10             	add    $0x10,%esp
      cprintf("0");
    cprintf("%d\t",i);
#else
    cprintf("%d\t%s\t%s", p->pid, state, p->name);
#endif
    i = 0;
801054fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(p->state == SLEEPING){
80105504:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105507:	8b 40 0c             	mov    0xc(%eax),%eax
8010550a:	83 f8 02             	cmp    $0x2,%eax
8010550d:	75 54                	jne    80105563 <procdump+0x274>
      getcallerpcs((uint*)p->context->ebp+2, pc);
8010550f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105512:	8b 40 1c             	mov    0x1c(%eax),%eax
80105515:	8b 40 0c             	mov    0xc(%eax),%eax
80105518:	83 c0 08             	add    $0x8,%eax
8010551b:	89 c2                	mov    %eax,%edx
8010551d:	83 ec 08             	sub    $0x8,%esp
80105520:	8d 45 c0             	lea    -0x40(%ebp),%eax
80105523:	50                   	push   %eax
80105524:	52                   	push   %edx
80105525:	e8 5d 07 00 00       	call   80105c87 <getcallerpcs>
8010552a:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010552d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105534:	eb 1c                	jmp    80105552 <procdump+0x263>
        cprintf(" %p", pc[i]);
80105536:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105539:	8b 44 85 c0          	mov    -0x40(%ebp,%eax,4),%eax
8010553d:	83 ec 08             	sub    $0x8,%esp
80105540:	50                   	push   %eax
80105541:	68 a0 96 10 80       	push   $0x801096a0
80105546:	e8 7b ae ff ff       	call   801003c6 <cprintf>
8010554b:	83 c4 10             	add    $0x10,%esp
    cprintf("%d\t%s\t%s", p->pid, state, p->name);
#endif
    i = 0;
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
8010554e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105552:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105556:	7f 0b                	jg     80105563 <procdump+0x274>
80105558:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010555b:	8b 44 85 c0          	mov    -0x40(%ebp,%eax,4),%eax
8010555f:	85 c0                	test   %eax,%eax
80105561:	75 d3                	jne    80105536 <procdump+0x247>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105563:	83 ec 0c             	sub    $0xc,%esp
80105566:	68 a4 96 10 80       	push   $0x801096a4
8010556b:	e8 56 ae ff ff       	call   801003c6 <cprintf>
80105570:	83 c4 10             	add    $0x10,%esp
80105573:	eb 01                	jmp    80105576 <procdump+0x287>
#else
  cprintf("\nPID\tState\tName\t PCs\n");
#endif
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105575:	90                   	nop
#elif defined CS333_P1
  cprintf("\nPID\tState\tName\tElapsed\t PCs\n");
#else
  cprintf("\nPID\tState\tName\t PCs\n");
#endif
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105576:	81 45 f0 94 00 00 00 	addl   $0x94,-0x10(%ebp)
8010557d:	81 7d f0 b4 5e 11 80 	cmpl   $0x80115eb4,-0x10(%ebp)
80105584:	0f 82 88 fd ff ff    	jb     80105312 <procdump+0x23>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
8010558a:	90                   	nop
8010558b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010558e:	c9                   	leave  
8010558f:	c3                   	ret    

80105590 <stateListAdd>:


#ifdef CS333_P3P4
static int
stateListAdd(struct proc** head, struct proc** tail, struct proc* p)
{
80105590:	55                   	push   %ebp
80105591:	89 e5                	mov    %esp,%ebp
  if (*head == 0) {
80105593:	8b 45 08             	mov    0x8(%ebp),%eax
80105596:	8b 00                	mov    (%eax),%eax
80105598:	85 c0                	test   %eax,%eax
8010559a:	75 1f                	jne    801055bb <stateListAdd+0x2b>
    *head = p;
8010559c:	8b 45 08             	mov    0x8(%ebp),%eax
8010559f:	8b 55 10             	mov    0x10(%ebp),%edx
801055a2:	89 10                	mov    %edx,(%eax)
    *tail = p;
801055a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801055a7:	8b 55 10             	mov    0x10(%ebp),%edx
801055aa:	89 10                	mov    %edx,(%eax)
    p->next = 0;
801055ac:	8b 45 10             	mov    0x10(%ebp),%eax
801055af:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
801055b6:	00 00 00 
801055b9:	eb 2d                	jmp    801055e8 <stateListAdd+0x58>
  } else {
    (*tail)->next = p;
801055bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801055be:	8b 00                	mov    (%eax),%eax
801055c0:	8b 55 10             	mov    0x10(%ebp),%edx
801055c3:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
    *tail = (*tail)->next;
801055c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801055cc:	8b 00                	mov    (%eax),%eax
801055ce:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
801055d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801055d7:	89 10                	mov    %edx,(%eax)
    (*tail)->next = 0;
801055d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801055dc:	8b 00                	mov    (%eax),%eax
801055de:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
801055e5:	00 00 00 
  }

  return 0;
801055e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055ed:	5d                   	pop    %ebp
801055ee:	c3                   	ret    

801055ef <stateListRemove>:

static int
stateListRemove(struct proc** head, struct proc** tail, struct proc* p)
{
801055ef:	55                   	push   %ebp
801055f0:	89 e5                	mov    %esp,%ebp
801055f2:	83 ec 10             	sub    $0x10,%esp
  if (*head == 0 || *tail == 0 || p == 0) {
801055f5:	8b 45 08             	mov    0x8(%ebp),%eax
801055f8:	8b 00                	mov    (%eax),%eax
801055fa:	85 c0                	test   %eax,%eax
801055fc:	74 0f                	je     8010560d <stateListRemove+0x1e>
801055fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80105601:	8b 00                	mov    (%eax),%eax
80105603:	85 c0                	test   %eax,%eax
80105605:	74 06                	je     8010560d <stateListRemove+0x1e>
80105607:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010560b:	75 0a                	jne    80105617 <stateListRemove+0x28>
    return -1;
8010560d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105612:	e9 a5 00 00 00       	jmp    801056bc <stateListRemove+0xcd>
  }

  struct proc* current = *head;
80105617:	8b 45 08             	mov    0x8(%ebp),%eax
8010561a:	8b 00                	mov    (%eax),%eax
8010561c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct proc* previous = 0;
8010561f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

  if (current == p) {
80105626:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105629:	3b 45 10             	cmp    0x10(%ebp),%eax
8010562c:	75 31                	jne    8010565f <stateListRemove+0x70>
    *head = (*head)->next;
8010562e:	8b 45 08             	mov    0x8(%ebp),%eax
80105631:	8b 00                	mov    (%eax),%eax
80105633:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
80105639:	8b 45 08             	mov    0x8(%ebp),%eax
8010563c:	89 10                	mov    %edx,(%eax)
    return 0;
8010563e:	b8 00 00 00 00       	mov    $0x0,%eax
80105643:	eb 77                	jmp    801056bc <stateListRemove+0xcd>
  }

  while(current) {
    if (current == p) {
80105645:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105648:	3b 45 10             	cmp    0x10(%ebp),%eax
8010564b:	74 1a                	je     80105667 <stateListRemove+0x78>
      break;
    }

    previous = current;
8010564d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105650:	89 45 f8             	mov    %eax,-0x8(%ebp)
    current = current->next;
80105653:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105656:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010565c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if (current == p) {
    *head = (*head)->next;
    return 0;
  }

  while(current) {
8010565f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105663:	75 e0                	jne    80105645 <stateListRemove+0x56>
80105665:	eb 01                	jmp    80105668 <stateListRemove+0x79>
    if (current == p) {
      break;
80105667:	90                   	nop
    previous = current;
    current = current->next;
  }

  // Process not found, hit eject.
  if (current == 0) {
80105668:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010566c:	75 07                	jne    80105675 <stateListRemove+0x86>
    return -1;
8010566e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105673:	eb 47                	jmp    801056bc <stateListRemove+0xcd>
  }

  // Process found. Set the appropriate next pointer.
  if (current == *tail) {
80105675:	8b 45 0c             	mov    0xc(%ebp),%eax
80105678:	8b 00                	mov    (%eax),%eax
8010567a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
8010567d:	75 19                	jne    80105698 <stateListRemove+0xa9>
    *tail = previous;
8010567f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105682:	8b 55 f8             	mov    -0x8(%ebp),%edx
80105685:	89 10                	mov    %edx,(%eax)
    (*tail)->next = 0;
80105687:	8b 45 0c             	mov    0xc(%ebp),%eax
8010568a:	8b 00                	mov    (%eax),%eax
8010568c:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80105693:	00 00 00 
80105696:	eb 12                	jmp    801056aa <stateListRemove+0xbb>
  } else {
    previous->next = current->next;
80105698:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010569b:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
801056a1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801056a4:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
  }

  // Make sure p->next doesn't point into the list.
  p->next = 0;
801056aa:	8b 45 10             	mov    0x10(%ebp),%eax
801056ad:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
801056b4:	00 00 00 

  return 0;
801056b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056bc:	c9                   	leave  
801056bd:	c3                   	ret    

801056be <initProcessLists>:

static void
initProcessLists(void) {
801056be:	55                   	push   %ebp
801056bf:	89 e5                	mov    %esp,%ebp
  ptable.pLists.ready = 0;
801056c1:	c7 05 b4 5e 11 80 00 	movl   $0x0,0x80115eb4
801056c8:	00 00 00 
  ptable.pLists.readyTail = 0;
801056cb:	c7 05 b8 5e 11 80 00 	movl   $0x0,0x80115eb8
801056d2:	00 00 00 
  ptable.pLists.free = 0;
801056d5:	c7 05 bc 5e 11 80 00 	movl   $0x0,0x80115ebc
801056dc:	00 00 00 
  ptable.pLists.freeTail = 0;
801056df:	c7 05 c0 5e 11 80 00 	movl   $0x0,0x80115ec0
801056e6:	00 00 00 
  ptable.pLists.sleep = 0;
801056e9:	c7 05 c4 5e 11 80 00 	movl   $0x0,0x80115ec4
801056f0:	00 00 00 
  ptable.pLists.sleepTail = 0;
801056f3:	c7 05 c8 5e 11 80 00 	movl   $0x0,0x80115ec8
801056fa:	00 00 00 
  ptable.pLists.zombie = 0;
801056fd:	c7 05 cc 5e 11 80 00 	movl   $0x0,0x80115ecc
80105704:	00 00 00 
  ptable.pLists.zombieTail = 0;
80105707:	c7 05 d0 5e 11 80 00 	movl   $0x0,0x80115ed0
8010570e:	00 00 00 
  ptable.pLists.running = 0;
80105711:	c7 05 d4 5e 11 80 00 	movl   $0x0,0x80115ed4
80105718:	00 00 00 
  ptable.pLists.runningTail = 0;
8010571b:	c7 05 d8 5e 11 80 00 	movl   $0x0,0x80115ed8
80105722:	00 00 00 
  ptable.pLists.embryo = 0;
80105725:	c7 05 dc 5e 11 80 00 	movl   $0x0,0x80115edc
8010572c:	00 00 00 
  ptable.pLists.embryoTail = 0;
8010572f:	c7 05 e0 5e 11 80 00 	movl   $0x0,0x80115ee0
80105736:	00 00 00 
}
80105739:	90                   	nop
8010573a:	5d                   	pop    %ebp
8010573b:	c3                   	ret    

8010573c <initFreeList>:

static void
initFreeList(void) {
8010573c:	55                   	push   %ebp
8010573d:	89 e5                	mov    %esp,%ebp
8010573f:	83 ec 18             	sub    $0x18,%esp
  if (!holding(&ptable.lock)) {
80105742:	83 ec 0c             	sub    $0xc,%esp
80105745:	68 80 39 11 80       	push   $0x80113980
8010574a:	e8 b2 05 00 00       	call   80105d01 <holding>
8010574f:	83 c4 10             	add    $0x10,%esp
80105752:	85 c0                	test   %eax,%eax
80105754:	75 0d                	jne    80105763 <initFreeList+0x27>
    panic("acquire the ptable lock before calling initFreeList\n");
80105756:	83 ec 0c             	sub    $0xc,%esp
80105759:	68 a8 96 10 80       	push   $0x801096a8
8010575e:	e8 03 ae ff ff       	call   80100566 <panic>
  }

  struct proc* p;

  for (p = ptable.proc; p < ptable.proc + NPROC; ++p) {
80105763:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
8010576a:	eb 29                	jmp    80105795 <initFreeList+0x59>
    p->state = UNUSED;
8010576c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010576f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail, p);
80105776:	83 ec 04             	sub    $0x4,%esp
80105779:	ff 75 f4             	pushl  -0xc(%ebp)
8010577c:	68 c0 5e 11 80       	push   $0x80115ec0
80105781:	68 bc 5e 11 80       	push   $0x80115ebc
80105786:	e8 05 fe ff ff       	call   80105590 <stateListAdd>
8010578b:	83 c4 10             	add    $0x10,%esp
    panic("acquire the ptable lock before calling initFreeList\n");
  }

  struct proc* p;

  for (p = ptable.proc; p < ptable.proc + NPROC; ++p) {
8010578e:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
80105795:	b8 b4 5e 11 80       	mov    $0x80115eb4,%eax
8010579a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010579d:	72 cd                	jb     8010576c <initFreeList+0x30>
    p->state = UNUSED;
    stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail, p);
  }
}
8010579f:	90                   	nop
801057a0:	c9                   	leave  
801057a1:	c3                   	ret    

801057a2 <getprocs>:
#endif

//Get all current processes within the system.
int
getprocs(int max, struct uproc* proctable)
{
801057a2:	55                   	push   %ebp
801057a3:	89 e5                	mov    %esp,%ebp
801057a5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int i;

  //LOCK PTABLE
  acquire(&ptable.lock);
801057a8:	83 ec 0c             	sub    $0xc,%esp
801057ab:	68 80 39 11 80       	push   $0x80113980
801057b0:	e8 19 04 00 00       	call   80105bce <acquire>
801057b5:	83 c4 10             	add    $0x10,%esp

  //ptable gets incremented within forloop, i get incremented at the end
  //of the forloop.
  for(i=0, p = ptable.proc; p < &ptable.proc[NPROC] && i<max; p++)
801057b8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801057bf:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
801057c6:	e9 35 01 00 00       	jmp    80105900 <getprocs+0x15e>
  {
    //copy all the info into one element of the array
    //skip if the process is in the unused state
    if(p->state != UNUSED && p->state != EMBRYO)
801057cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057ce:	8b 40 0c             	mov    0xc(%eax),%eax
801057d1:	85 c0                	test   %eax,%eax
801057d3:	0f 84 20 01 00 00    	je     801058f9 <getprocs+0x157>
801057d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057dc:	8b 40 0c             	mov    0xc(%eax),%eax
801057df:	83 f8 01             	cmp    $0x1,%eax
801057e2:	0f 84 11 01 00 00    	je     801058f9 <getprocs+0x157>
    {
      proctable[i].pid = p->pid;
801057e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057eb:	6b d0 5c             	imul   $0x5c,%eax,%edx
801057ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801057f1:	01 c2                	add    %eax,%edx
801057f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057f6:	8b 40 10             	mov    0x10(%eax),%eax
801057f9:	89 02                	mov    %eax,(%edx)
      proctable[i].uid = p->uid;
801057fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057fe:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105801:	8b 45 0c             	mov    0xc(%ebp),%eax
80105804:	01 c2                	add    %eax,%edx
80105806:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105809:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010580f:	89 42 04             	mov    %eax,0x4(%edx)
      proctable[i].gid = p->gid;
80105812:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105815:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105818:	8b 45 0c             	mov    0xc(%ebp),%eax
8010581b:	01 c2                	add    %eax,%edx
8010581d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105820:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80105826:	89 42 08             	mov    %eax,0x8(%edx)
      if(p->parent != 0)
80105829:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010582c:	8b 40 14             	mov    0x14(%eax),%eax
8010582f:	85 c0                	test   %eax,%eax
80105831:	74 19                	je     8010584c <getprocs+0xaa>
        proctable[i].ppid = p->parent->pid;
80105833:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105836:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105839:	8b 45 0c             	mov    0xc(%ebp),%eax
8010583c:	01 c2                	add    %eax,%edx
8010583e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105841:	8b 40 14             	mov    0x14(%eax),%eax
80105844:	8b 40 10             	mov    0x10(%eax),%eax
80105847:	89 42 0c             	mov    %eax,0xc(%edx)
8010584a:	eb 14                	jmp    80105860 <getprocs+0xbe>
      else
        proctable[i].ppid = p->pid;
8010584c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010584f:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105852:	8b 45 0c             	mov    0xc(%ebp),%eax
80105855:	01 c2                	add    %eax,%edx
80105857:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010585a:	8b 40 10             	mov    0x10(%eax),%eax
8010585d:	89 42 0c             	mov    %eax,0xc(%edx)

      //Get the current ticks for elapsed ticks.
      proctable[i].elapsed_ticks = ticks-p->start_ticks;
80105860:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105863:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105866:	8b 45 0c             	mov    0xc(%ebp),%eax
80105869:	01 c2                	add    %eax,%edx
8010586b:	8b 0d 00 67 11 80    	mov    0x80116700,%ecx
80105871:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105874:	8b 40 7c             	mov    0x7c(%eax),%eax
80105877:	29 c1                	sub    %eax,%ecx
80105879:	89 c8                	mov    %ecx,%eax
8010587b:	89 42 10             	mov    %eax,0x10(%edx)
      proctable[i].CPU_total_ticks = p->cpu_ticks_total;
8010587e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105881:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105884:	8b 45 0c             	mov    0xc(%ebp),%eax
80105887:	01 c2                	add    %eax,%edx
80105889:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010588c:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80105892:	89 42 14             	mov    %eax,0x14(%edx)
      safestrcpy(proctable[i].state, states[p->state], sizeof(proctable[i].state));
80105895:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105898:	8b 40 0c             	mov    0xc(%eax),%eax
8010589b:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
801058a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801058a5:	6b ca 5c             	imul   $0x5c,%edx,%ecx
801058a8:	8b 55 0c             	mov    0xc(%ebp),%edx
801058ab:	01 ca                	add    %ecx,%edx
801058ad:	83 c2 18             	add    $0x18,%edx
801058b0:	83 ec 04             	sub    $0x4,%esp
801058b3:	6a 20                	push   $0x20
801058b5:	50                   	push   %eax
801058b6:	52                   	push   %edx
801058b7:	e8 78 07 00 00       	call   80106034 <safestrcpy>
801058bc:	83 c4 10             	add    $0x10,%esp
      proctable[i].size = p->sz;
801058bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058c2:	6b d0 5c             	imul   $0x5c,%eax,%edx
801058c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801058c8:	01 c2                	add    %eax,%edx
801058ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058cd:	8b 00                	mov    (%eax),%eax
801058cf:	89 42 38             	mov    %eax,0x38(%edx)
      safestrcpy(proctable[i].name, p->name, sizeof(p->name));
801058d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058d5:	8d 50 6c             	lea    0x6c(%eax),%edx
801058d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058db:	6b c8 5c             	imul   $0x5c,%eax,%ecx
801058de:	8b 45 0c             	mov    0xc(%ebp),%eax
801058e1:	01 c8                	add    %ecx,%eax
801058e3:	83 c0 3c             	add    $0x3c,%eax
801058e6:	83 ec 04             	sub    $0x4,%esp
801058e9:	6a 10                	push   $0x10
801058eb:	52                   	push   %edx
801058ec:	50                   	push   %eax
801058ed:	e8 42 07 00 00       	call   80106034 <safestrcpy>
801058f2:	83 c4 10             	add    $0x10,%esp

      //Increment the array that is having info copied into
      ++i;
801058f5:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  //LOCK PTABLE
  acquire(&ptable.lock);

  //ptable gets incremented within forloop, i get incremented at the end
  //of the forloop.
  for(i=0, p = ptable.proc; p < &ptable.proc[NPROC] && i<max; p++)
801058f9:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
80105900:	81 7d f4 b4 5e 11 80 	cmpl   $0x80115eb4,-0xc(%ebp)
80105907:	73 0c                	jae    80105915 <getprocs+0x173>
80105909:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010590c:	3b 45 08             	cmp    0x8(%ebp),%eax
8010590f:	0f 8c b6 fe ff ff    	jl     801057cb <getprocs+0x29>

    }
  }

  //UNLOCK PTABLE
  release(&ptable.lock);
80105915:	83 ec 0c             	sub    $0xc,%esp
80105918:	68 80 39 11 80       	push   $0x80113980
8010591d:	e8 13 03 00 00       	call   80105c35 <release>
80105922:	83 c4 10             	add    $0x10,%esp

  return i;
80105925:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105928:	c9                   	leave  
80105929:	c3                   	ret    

8010592a <piddump>:

void
piddump(void)
{
8010592a:	55                   	push   %ebp
8010592b:	89 e5                	mov    %esp,%ebp
8010592d:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  acquire(&ptable.lock);
80105930:	83 ec 0c             	sub    $0xc,%esp
80105933:	68 80 39 11 80       	push   $0x80113980
80105938:	e8 91 02 00 00       	call   80105bce <acquire>
8010593d:	83 c4 10             	add    $0x10,%esp
  p = ptable.pLists.ready;
80105940:	a1 b4 5e 11 80       	mov    0x80115eb4,%eax
80105945:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cprintf("\nReady List Processes:\n");
80105948:	83 ec 0c             	sub    $0xc,%esp
8010594b:	68 dd 96 10 80       	push   $0x801096dd
80105950:	e8 71 aa ff ff       	call   801003c6 <cprintf>
80105955:	83 c4 10             	add    $0x10,%esp
  while(p)
80105958:	eb 40                	jmp    8010599a <piddump+0x70>
  {
    cprintf("%d", p->pid);
8010595a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010595d:	8b 40 10             	mov    0x10(%eax),%eax
80105960:	83 ec 08             	sub    $0x8,%esp
80105963:	50                   	push   %eax
80105964:	68 93 96 10 80       	push   $0x80109693
80105969:	e8 58 aa ff ff       	call   801003c6 <cprintf>
8010596e:	83 c4 10             	add    $0x10,%esp
    if(p->next)
80105971:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105974:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010597a:	85 c0                	test   %eax,%eax
8010597c:	74 10                	je     8010598e <piddump+0x64>
      cprintf(" -> ");
8010597e:	83 ec 0c             	sub    $0xc,%esp
80105981:	68 f5 96 10 80       	push   $0x801096f5
80105986:	e8 3b aa ff ff       	call   801003c6 <cprintf>
8010598b:	83 c4 10             	add    $0x10,%esp
    p = p->next;
8010598e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105991:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105997:	89 45 f4             	mov    %eax,-0xc(%ebp)
{
  struct proc *p;
  acquire(&ptable.lock);
  p = ptable.pLists.ready;
  cprintf("\nReady List Processes:\n");
  while(p)
8010599a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010599e:	75 ba                	jne    8010595a <piddump+0x30>
    cprintf("%d", p->pid);
    if(p->next)
      cprintf(" -> ");
    p = p->next;
  }
  cprintf("\n");
801059a0:	83 ec 0c             	sub    $0xc,%esp
801059a3:	68 a4 96 10 80       	push   $0x801096a4
801059a8:	e8 19 aa ff ff       	call   801003c6 <cprintf>
801059ad:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801059b0:	83 ec 0c             	sub    $0xc,%esp
801059b3:	68 80 39 11 80       	push   $0x80113980
801059b8:	e8 78 02 00 00       	call   80105c35 <release>
801059bd:	83 c4 10             	add    $0x10,%esp
}
801059c0:	90                   	nop
801059c1:	c9                   	leave  
801059c2:	c3                   	ret    

801059c3 <freedump>:

void
freedump(void)
{
801059c3:	55                   	push   %ebp
801059c4:	89 e5                	mov    %esp,%ebp
801059c6:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int counter = 0;
801059c9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  acquire(&ptable.lock);
801059d0:	83 ec 0c             	sub    $0xc,%esp
801059d3:	68 80 39 11 80       	push   $0x80113980
801059d8:	e8 f1 01 00 00       	call   80105bce <acquire>
801059dd:	83 c4 10             	add    $0x10,%esp
  p = ptable.pLists.free;
801059e0:	a1 bc 5e 11 80       	mov    0x80115ebc,%eax
801059e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(p)
801059e8:	eb 10                	jmp    801059fa <freedump+0x37>
  {
    p = p->next;
801059ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ed:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801059f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    ++counter;
801059f6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
{
  struct proc *p;
  int counter = 0;
  acquire(&ptable.lock);
  p = ptable.pLists.free;
  while(p)
801059fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059fe:	75 ea                	jne    801059ea <freedump+0x27>
  {
    p = p->next;
    ++counter;
  }

  cprintf("\nFree List Size: %d processes\n", counter);
80105a00:	83 ec 08             	sub    $0x8,%esp
80105a03:	ff 75 f0             	pushl  -0x10(%ebp)
80105a06:	68 fc 96 10 80       	push   $0x801096fc
80105a0b:	e8 b6 a9 ff ff       	call   801003c6 <cprintf>
80105a10:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80105a13:	83 ec 0c             	sub    $0xc,%esp
80105a16:	68 80 39 11 80       	push   $0x80113980
80105a1b:	e8 15 02 00 00       	call   80105c35 <release>
80105a20:	83 c4 10             	add    $0x10,%esp
}
80105a23:	90                   	nop
80105a24:	c9                   	leave  
80105a25:	c3                   	ret    

80105a26 <sleepdump>:

void
sleepdump(void)
{
80105a26:	55                   	push   %ebp
80105a27:	89 e5                	mov    %esp,%ebp
80105a29:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  acquire(&ptable.lock);
80105a2c:	83 ec 0c             	sub    $0xc,%esp
80105a2f:	68 80 39 11 80       	push   $0x80113980
80105a34:	e8 95 01 00 00       	call   80105bce <acquire>
80105a39:	83 c4 10             	add    $0x10,%esp
  p = ptable.pLists.sleep;
80105a3c:	a1 c4 5e 11 80       	mov    0x80115ec4,%eax
80105a41:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cprintf("\nSleep List Processes:\n");
80105a44:	83 ec 0c             	sub    $0xc,%esp
80105a47:	68 1b 97 10 80       	push   $0x8010971b
80105a4c:	e8 75 a9 ff ff       	call   801003c6 <cprintf>
80105a51:	83 c4 10             	add    $0x10,%esp
  while(p)
80105a54:	eb 40                	jmp    80105a96 <sleepdump+0x70>
  {
    cprintf("%d", p->pid);
80105a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a59:	8b 40 10             	mov    0x10(%eax),%eax
80105a5c:	83 ec 08             	sub    $0x8,%esp
80105a5f:	50                   	push   %eax
80105a60:	68 93 96 10 80       	push   $0x80109693
80105a65:	e8 5c a9 ff ff       	call   801003c6 <cprintf>
80105a6a:	83 c4 10             	add    $0x10,%esp
    if(p->next)
80105a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a70:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105a76:	85 c0                	test   %eax,%eax
80105a78:	74 10                	je     80105a8a <sleepdump+0x64>
      cprintf(" -> ");
80105a7a:	83 ec 0c             	sub    $0xc,%esp
80105a7d:	68 f5 96 10 80       	push   $0x801096f5
80105a82:	e8 3f a9 ff ff       	call   801003c6 <cprintf>
80105a87:	83 c4 10             	add    $0x10,%esp
    p = p->next;
80105a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a8d:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105a93:	89 45 f4             	mov    %eax,-0xc(%ebp)
{
  struct proc *p;
  acquire(&ptable.lock);
  p = ptable.pLists.sleep;
  cprintf("\nSleep List Processes:\n");
  while(p)
80105a96:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a9a:	75 ba                	jne    80105a56 <sleepdump+0x30>
    cprintf("%d", p->pid);
    if(p->next)
      cprintf(" -> ");
    p = p->next;
  }
  cprintf("\n");
80105a9c:	83 ec 0c             	sub    $0xc,%esp
80105a9f:	68 a4 96 10 80       	push   $0x801096a4
80105aa4:	e8 1d a9 ff ff       	call   801003c6 <cprintf>
80105aa9:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80105aac:	83 ec 0c             	sub    $0xc,%esp
80105aaf:	68 80 39 11 80       	push   $0x80113980
80105ab4:	e8 7c 01 00 00       	call   80105c35 <release>
80105ab9:	83 c4 10             	add    $0x10,%esp
}
80105abc:	90                   	nop
80105abd:	c9                   	leave  
80105abe:	c3                   	ret    

80105abf <zombiedump>:

void
zombiedump(void)
{
80105abf:	55                   	push   %ebp
80105ac0:	89 e5                	mov    %esp,%ebp
80105ac2:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  acquire(&ptable.lock);
80105ac5:	83 ec 0c             	sub    $0xc,%esp
80105ac8:	68 80 39 11 80       	push   $0x80113980
80105acd:	e8 fc 00 00 00       	call   80105bce <acquire>
80105ad2:	83 c4 10             	add    $0x10,%esp
  p = ptable.pLists.zombie;
80105ad5:	a1 cc 5e 11 80       	mov    0x80115ecc,%eax
80105ada:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cprintf("\nZombie List Processes:\n");
80105add:	83 ec 0c             	sub    $0xc,%esp
80105ae0:	68 33 97 10 80       	push   $0x80109733
80105ae5:	e8 dc a8 ff ff       	call   801003c6 <cprintf>
80105aea:	83 c4 10             	add    $0x10,%esp
  while(p)
80105aed:	eb 5c                	jmp    80105b4b <zombiedump+0x8c>
  {
    cprintf("(PID%d, PPID%d)", p->pid, (p->parent? p->parent->pid : p->pid));
80105aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105af2:	8b 40 14             	mov    0x14(%eax),%eax
80105af5:	85 c0                	test   %eax,%eax
80105af7:	74 0b                	je     80105b04 <zombiedump+0x45>
80105af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105afc:	8b 40 14             	mov    0x14(%eax),%eax
80105aff:	8b 40 10             	mov    0x10(%eax),%eax
80105b02:	eb 06                	jmp    80105b0a <zombiedump+0x4b>
80105b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b07:	8b 40 10             	mov    0x10(%eax),%eax
80105b0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b0d:	8b 52 10             	mov    0x10(%edx),%edx
80105b10:	83 ec 04             	sub    $0x4,%esp
80105b13:	50                   	push   %eax
80105b14:	52                   	push   %edx
80105b15:	68 4c 97 10 80       	push   $0x8010974c
80105b1a:	e8 a7 a8 ff ff       	call   801003c6 <cprintf>
80105b1f:	83 c4 10             	add    $0x10,%esp
    if(p->next)
80105b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b25:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105b2b:	85 c0                	test   %eax,%eax
80105b2d:	74 10                	je     80105b3f <zombiedump+0x80>
      cprintf(" -> ");
80105b2f:	83 ec 0c             	sub    $0xc,%esp
80105b32:	68 f5 96 10 80       	push   $0x801096f5
80105b37:	e8 8a a8 ff ff       	call   801003c6 <cprintf>
80105b3c:	83 c4 10             	add    $0x10,%esp
    p = p->next;
80105b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b42:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105b48:	89 45 f4             	mov    %eax,-0xc(%ebp)
{
  struct proc *p;
  acquire(&ptable.lock);
  p = ptable.pLists.zombie;
  cprintf("\nZombie List Processes:\n");
  while(p)
80105b4b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b4f:	75 9e                	jne    80105aef <zombiedump+0x30>
    cprintf("(PID%d, PPID%d)", p->pid, (p->parent? p->parent->pid : p->pid));
    if(p->next)
      cprintf(" -> ");
    p = p->next;
  }
  cprintf("\n");
80105b51:	83 ec 0c             	sub    $0xc,%esp
80105b54:	68 a4 96 10 80       	push   $0x801096a4
80105b59:	e8 68 a8 ff ff       	call   801003c6 <cprintf>
80105b5e:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80105b61:	83 ec 0c             	sub    $0xc,%esp
80105b64:	68 80 39 11 80       	push   $0x80113980
80105b69:	e8 c7 00 00 00       	call   80105c35 <release>
80105b6e:	83 c4 10             	add    $0x10,%esp
}
80105b71:	90                   	nop
80105b72:	c9                   	leave  
80105b73:	c3                   	ret    

80105b74 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105b74:	55                   	push   %ebp
80105b75:	89 e5                	mov    %esp,%ebp
80105b77:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105b7a:	9c                   	pushf  
80105b7b:	58                   	pop    %eax
80105b7c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105b7f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105b82:	c9                   	leave  
80105b83:	c3                   	ret    

80105b84 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105b84:	55                   	push   %ebp
80105b85:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105b87:	fa                   	cli    
}
80105b88:	90                   	nop
80105b89:	5d                   	pop    %ebp
80105b8a:	c3                   	ret    

80105b8b <sti>:

static inline void
sti(void)
{
80105b8b:	55                   	push   %ebp
80105b8c:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105b8e:	fb                   	sti    
}
80105b8f:	90                   	nop
80105b90:	5d                   	pop    %ebp
80105b91:	c3                   	ret    

80105b92 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105b92:	55                   	push   %ebp
80105b93:	89 e5                	mov    %esp,%ebp
80105b95:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105b98:	8b 55 08             	mov    0x8(%ebp),%edx
80105b9b:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105ba1:	f0 87 02             	lock xchg %eax,(%edx)
80105ba4:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105ba7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105baa:	c9                   	leave  
80105bab:	c3                   	ret    

80105bac <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105bac:	55                   	push   %ebp
80105bad:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105baf:	8b 45 08             	mov    0x8(%ebp),%eax
80105bb2:	8b 55 0c             	mov    0xc(%ebp),%edx
80105bb5:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105bb8:	8b 45 08             	mov    0x8(%ebp),%eax
80105bbb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105bc1:	8b 45 08             	mov    0x8(%ebp),%eax
80105bc4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105bcb:	90                   	nop
80105bcc:	5d                   	pop    %ebp
80105bcd:	c3                   	ret    

80105bce <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105bce:	55                   	push   %ebp
80105bcf:	89 e5                	mov    %esp,%ebp
80105bd1:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105bd4:	e8 52 01 00 00       	call   80105d2b <pushcli>
  if(holding(lk))
80105bd9:	8b 45 08             	mov    0x8(%ebp),%eax
80105bdc:	83 ec 0c             	sub    $0xc,%esp
80105bdf:	50                   	push   %eax
80105be0:	e8 1c 01 00 00       	call   80105d01 <holding>
80105be5:	83 c4 10             	add    $0x10,%esp
80105be8:	85 c0                	test   %eax,%eax
80105bea:	74 0d                	je     80105bf9 <acquire+0x2b>
    panic("acquire");
80105bec:	83 ec 0c             	sub    $0xc,%esp
80105bef:	68 5c 97 10 80       	push   $0x8010975c
80105bf4:	e8 6d a9 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105bf9:	90                   	nop
80105bfa:	8b 45 08             	mov    0x8(%ebp),%eax
80105bfd:	83 ec 08             	sub    $0x8,%esp
80105c00:	6a 01                	push   $0x1
80105c02:	50                   	push   %eax
80105c03:	e8 8a ff ff ff       	call   80105b92 <xchg>
80105c08:	83 c4 10             	add    $0x10,%esp
80105c0b:	85 c0                	test   %eax,%eax
80105c0d:	75 eb                	jne    80105bfa <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105c0f:	8b 45 08             	mov    0x8(%ebp),%eax
80105c12:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105c19:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105c1c:	8b 45 08             	mov    0x8(%ebp),%eax
80105c1f:	83 c0 0c             	add    $0xc,%eax
80105c22:	83 ec 08             	sub    $0x8,%esp
80105c25:	50                   	push   %eax
80105c26:	8d 45 08             	lea    0x8(%ebp),%eax
80105c29:	50                   	push   %eax
80105c2a:	e8 58 00 00 00       	call   80105c87 <getcallerpcs>
80105c2f:	83 c4 10             	add    $0x10,%esp
}
80105c32:	90                   	nop
80105c33:	c9                   	leave  
80105c34:	c3                   	ret    

80105c35 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105c35:	55                   	push   %ebp
80105c36:	89 e5                	mov    %esp,%ebp
80105c38:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105c3b:	83 ec 0c             	sub    $0xc,%esp
80105c3e:	ff 75 08             	pushl  0x8(%ebp)
80105c41:	e8 bb 00 00 00       	call   80105d01 <holding>
80105c46:	83 c4 10             	add    $0x10,%esp
80105c49:	85 c0                	test   %eax,%eax
80105c4b:	75 0d                	jne    80105c5a <release+0x25>
    panic("release");
80105c4d:	83 ec 0c             	sub    $0xc,%esp
80105c50:	68 64 97 10 80       	push   $0x80109764
80105c55:	e8 0c a9 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80105c5a:	8b 45 08             	mov    0x8(%ebp),%eax
80105c5d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105c64:	8b 45 08             	mov    0x8(%ebp),%eax
80105c67:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105c6e:	8b 45 08             	mov    0x8(%ebp),%eax
80105c71:	83 ec 08             	sub    $0x8,%esp
80105c74:	6a 00                	push   $0x0
80105c76:	50                   	push   %eax
80105c77:	e8 16 ff ff ff       	call   80105b92 <xchg>
80105c7c:	83 c4 10             	add    $0x10,%esp

  popcli();
80105c7f:	e8 ec 00 00 00       	call   80105d70 <popcli>
}
80105c84:	90                   	nop
80105c85:	c9                   	leave  
80105c86:	c3                   	ret    

80105c87 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105c87:	55                   	push   %ebp
80105c88:	89 e5                	mov    %esp,%ebp
80105c8a:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105c8d:	8b 45 08             	mov    0x8(%ebp),%eax
80105c90:	83 e8 08             	sub    $0x8,%eax
80105c93:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105c96:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105c9d:	eb 38                	jmp    80105cd7 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105c9f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105ca3:	74 53                	je     80105cf8 <getcallerpcs+0x71>
80105ca5:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105cac:	76 4a                	jbe    80105cf8 <getcallerpcs+0x71>
80105cae:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105cb2:	74 44                	je     80105cf8 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105cb4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105cb7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105cbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80105cc1:	01 c2                	add    %eax,%edx
80105cc3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105cc6:	8b 40 04             	mov    0x4(%eax),%eax
80105cc9:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105ccb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105cce:	8b 00                	mov    (%eax),%eax
80105cd0:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105cd3:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105cd7:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105cdb:	7e c2                	jle    80105c9f <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105cdd:	eb 19                	jmp    80105cf8 <getcallerpcs+0x71>
    pcs[i] = 0;
80105cdf:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105ce2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105ce9:	8b 45 0c             	mov    0xc(%ebp),%eax
80105cec:	01 d0                	add    %edx,%eax
80105cee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105cf4:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105cf8:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105cfc:	7e e1                	jle    80105cdf <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105cfe:	90                   	nop
80105cff:	c9                   	leave  
80105d00:	c3                   	ret    

80105d01 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105d01:	55                   	push   %ebp
80105d02:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105d04:	8b 45 08             	mov    0x8(%ebp),%eax
80105d07:	8b 00                	mov    (%eax),%eax
80105d09:	85 c0                	test   %eax,%eax
80105d0b:	74 17                	je     80105d24 <holding+0x23>
80105d0d:	8b 45 08             	mov    0x8(%ebp),%eax
80105d10:	8b 50 08             	mov    0x8(%eax),%edx
80105d13:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d19:	39 c2                	cmp    %eax,%edx
80105d1b:	75 07                	jne    80105d24 <holding+0x23>
80105d1d:	b8 01 00 00 00       	mov    $0x1,%eax
80105d22:	eb 05                	jmp    80105d29 <holding+0x28>
80105d24:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d29:	5d                   	pop    %ebp
80105d2a:	c3                   	ret    

80105d2b <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105d2b:	55                   	push   %ebp
80105d2c:	89 e5                	mov    %esp,%ebp
80105d2e:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105d31:	e8 3e fe ff ff       	call   80105b74 <readeflags>
80105d36:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105d39:	e8 46 fe ff ff       	call   80105b84 <cli>
  if(cpu->ncli++ == 0)
80105d3e:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105d45:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105d4b:	8d 48 01             	lea    0x1(%eax),%ecx
80105d4e:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105d54:	85 c0                	test   %eax,%eax
80105d56:	75 15                	jne    80105d6d <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105d58:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d5e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105d61:	81 e2 00 02 00 00    	and    $0x200,%edx
80105d67:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105d6d:	90                   	nop
80105d6e:	c9                   	leave  
80105d6f:	c3                   	ret    

80105d70 <popcli>:

void
popcli(void)
{
80105d70:	55                   	push   %ebp
80105d71:	89 e5                	mov    %esp,%ebp
80105d73:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105d76:	e8 f9 fd ff ff       	call   80105b74 <readeflags>
80105d7b:	25 00 02 00 00       	and    $0x200,%eax
80105d80:	85 c0                	test   %eax,%eax
80105d82:	74 0d                	je     80105d91 <popcli+0x21>
    panic("popcli - interruptible");
80105d84:	83 ec 0c             	sub    $0xc,%esp
80105d87:	68 6c 97 10 80       	push   $0x8010976c
80105d8c:	e8 d5 a7 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80105d91:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d97:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105d9d:	83 ea 01             	sub    $0x1,%edx
80105da0:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105da6:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105dac:	85 c0                	test   %eax,%eax
80105dae:	79 0d                	jns    80105dbd <popcli+0x4d>
    panic("popcli");
80105db0:	83 ec 0c             	sub    $0xc,%esp
80105db3:	68 83 97 10 80       	push   $0x80109783
80105db8:	e8 a9 a7 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105dbd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105dc3:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105dc9:	85 c0                	test   %eax,%eax
80105dcb:	75 15                	jne    80105de2 <popcli+0x72>
80105dcd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105dd3:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105dd9:	85 c0                	test   %eax,%eax
80105ddb:	74 05                	je     80105de2 <popcli+0x72>
    sti();
80105ddd:	e8 a9 fd ff ff       	call   80105b8b <sti>
}
80105de2:	90                   	nop
80105de3:	c9                   	leave  
80105de4:	c3                   	ret    

80105de5 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105de5:	55                   	push   %ebp
80105de6:	89 e5                	mov    %esp,%ebp
80105de8:	57                   	push   %edi
80105de9:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105dea:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105ded:	8b 55 10             	mov    0x10(%ebp),%edx
80105df0:	8b 45 0c             	mov    0xc(%ebp),%eax
80105df3:	89 cb                	mov    %ecx,%ebx
80105df5:	89 df                	mov    %ebx,%edi
80105df7:	89 d1                	mov    %edx,%ecx
80105df9:	fc                   	cld    
80105dfa:	f3 aa                	rep stos %al,%es:(%edi)
80105dfc:	89 ca                	mov    %ecx,%edx
80105dfe:	89 fb                	mov    %edi,%ebx
80105e00:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105e03:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105e06:	90                   	nop
80105e07:	5b                   	pop    %ebx
80105e08:	5f                   	pop    %edi
80105e09:	5d                   	pop    %ebp
80105e0a:	c3                   	ret    

80105e0b <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105e0b:	55                   	push   %ebp
80105e0c:	89 e5                	mov    %esp,%ebp
80105e0e:	57                   	push   %edi
80105e0f:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105e10:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105e13:	8b 55 10             	mov    0x10(%ebp),%edx
80105e16:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e19:	89 cb                	mov    %ecx,%ebx
80105e1b:	89 df                	mov    %ebx,%edi
80105e1d:	89 d1                	mov    %edx,%ecx
80105e1f:	fc                   	cld    
80105e20:	f3 ab                	rep stos %eax,%es:(%edi)
80105e22:	89 ca                	mov    %ecx,%edx
80105e24:	89 fb                	mov    %edi,%ebx
80105e26:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105e29:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105e2c:	90                   	nop
80105e2d:	5b                   	pop    %ebx
80105e2e:	5f                   	pop    %edi
80105e2f:	5d                   	pop    %ebp
80105e30:	c3                   	ret    

80105e31 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105e31:	55                   	push   %ebp
80105e32:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105e34:	8b 45 08             	mov    0x8(%ebp),%eax
80105e37:	83 e0 03             	and    $0x3,%eax
80105e3a:	85 c0                	test   %eax,%eax
80105e3c:	75 43                	jne    80105e81 <memset+0x50>
80105e3e:	8b 45 10             	mov    0x10(%ebp),%eax
80105e41:	83 e0 03             	and    $0x3,%eax
80105e44:	85 c0                	test   %eax,%eax
80105e46:	75 39                	jne    80105e81 <memset+0x50>
    c &= 0xFF;
80105e48:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105e4f:	8b 45 10             	mov    0x10(%ebp),%eax
80105e52:	c1 e8 02             	shr    $0x2,%eax
80105e55:	89 c1                	mov    %eax,%ecx
80105e57:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e5a:	c1 e0 18             	shl    $0x18,%eax
80105e5d:	89 c2                	mov    %eax,%edx
80105e5f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e62:	c1 e0 10             	shl    $0x10,%eax
80105e65:	09 c2                	or     %eax,%edx
80105e67:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e6a:	c1 e0 08             	shl    $0x8,%eax
80105e6d:	09 d0                	or     %edx,%eax
80105e6f:	0b 45 0c             	or     0xc(%ebp),%eax
80105e72:	51                   	push   %ecx
80105e73:	50                   	push   %eax
80105e74:	ff 75 08             	pushl  0x8(%ebp)
80105e77:	e8 8f ff ff ff       	call   80105e0b <stosl>
80105e7c:	83 c4 0c             	add    $0xc,%esp
80105e7f:	eb 12                	jmp    80105e93 <memset+0x62>
  } else
    stosb(dst, c, n);
80105e81:	8b 45 10             	mov    0x10(%ebp),%eax
80105e84:	50                   	push   %eax
80105e85:	ff 75 0c             	pushl  0xc(%ebp)
80105e88:	ff 75 08             	pushl  0x8(%ebp)
80105e8b:	e8 55 ff ff ff       	call   80105de5 <stosb>
80105e90:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105e93:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105e96:	c9                   	leave  
80105e97:	c3                   	ret    

80105e98 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105e98:	55                   	push   %ebp
80105e99:	89 e5                	mov    %esp,%ebp
80105e9b:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105e9e:	8b 45 08             	mov    0x8(%ebp),%eax
80105ea1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105ea4:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ea7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105eaa:	eb 30                	jmp    80105edc <memcmp+0x44>
    if(*s1 != *s2)
80105eac:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105eaf:	0f b6 10             	movzbl (%eax),%edx
80105eb2:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105eb5:	0f b6 00             	movzbl (%eax),%eax
80105eb8:	38 c2                	cmp    %al,%dl
80105eba:	74 18                	je     80105ed4 <memcmp+0x3c>
      return *s1 - *s2;
80105ebc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ebf:	0f b6 00             	movzbl (%eax),%eax
80105ec2:	0f b6 d0             	movzbl %al,%edx
80105ec5:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105ec8:	0f b6 00             	movzbl (%eax),%eax
80105ecb:	0f b6 c0             	movzbl %al,%eax
80105ece:	29 c2                	sub    %eax,%edx
80105ed0:	89 d0                	mov    %edx,%eax
80105ed2:	eb 1a                	jmp    80105eee <memcmp+0x56>
    s1++, s2++;
80105ed4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105ed8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105edc:	8b 45 10             	mov    0x10(%ebp),%eax
80105edf:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ee2:	89 55 10             	mov    %edx,0x10(%ebp)
80105ee5:	85 c0                	test   %eax,%eax
80105ee7:	75 c3                	jne    80105eac <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105ee9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105eee:	c9                   	leave  
80105eef:	c3                   	ret    

80105ef0 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105ef0:	55                   	push   %ebp
80105ef1:	89 e5                	mov    %esp,%ebp
80105ef3:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105ef6:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ef9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105efc:	8b 45 08             	mov    0x8(%ebp),%eax
80105eff:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105f02:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f05:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105f08:	73 54                	jae    80105f5e <memmove+0x6e>
80105f0a:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105f0d:	8b 45 10             	mov    0x10(%ebp),%eax
80105f10:	01 d0                	add    %edx,%eax
80105f12:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105f15:	76 47                	jbe    80105f5e <memmove+0x6e>
    s += n;
80105f17:	8b 45 10             	mov    0x10(%ebp),%eax
80105f1a:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105f1d:	8b 45 10             	mov    0x10(%ebp),%eax
80105f20:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105f23:	eb 13                	jmp    80105f38 <memmove+0x48>
      *--d = *--s;
80105f25:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105f29:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105f2d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f30:	0f b6 10             	movzbl (%eax),%edx
80105f33:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105f36:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105f38:	8b 45 10             	mov    0x10(%ebp),%eax
80105f3b:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f3e:	89 55 10             	mov    %edx,0x10(%ebp)
80105f41:	85 c0                	test   %eax,%eax
80105f43:	75 e0                	jne    80105f25 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105f45:	eb 24                	jmp    80105f6b <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105f47:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105f4a:	8d 50 01             	lea    0x1(%eax),%edx
80105f4d:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105f50:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105f53:	8d 4a 01             	lea    0x1(%edx),%ecx
80105f56:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105f59:	0f b6 12             	movzbl (%edx),%edx
80105f5c:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105f5e:	8b 45 10             	mov    0x10(%ebp),%eax
80105f61:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f64:	89 55 10             	mov    %edx,0x10(%ebp)
80105f67:	85 c0                	test   %eax,%eax
80105f69:	75 dc                	jne    80105f47 <memmove+0x57>
      *d++ = *s++;

  return dst;
80105f6b:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105f6e:	c9                   	leave  
80105f6f:	c3                   	ret    

80105f70 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105f70:	55                   	push   %ebp
80105f71:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105f73:	ff 75 10             	pushl  0x10(%ebp)
80105f76:	ff 75 0c             	pushl  0xc(%ebp)
80105f79:	ff 75 08             	pushl  0x8(%ebp)
80105f7c:	e8 6f ff ff ff       	call   80105ef0 <memmove>
80105f81:	83 c4 0c             	add    $0xc,%esp
}
80105f84:	c9                   	leave  
80105f85:	c3                   	ret    

80105f86 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105f86:	55                   	push   %ebp
80105f87:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105f89:	eb 0c                	jmp    80105f97 <strncmp+0x11>
    n--, p++, q++;
80105f8b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105f8f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105f93:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105f97:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f9b:	74 1a                	je     80105fb7 <strncmp+0x31>
80105f9d:	8b 45 08             	mov    0x8(%ebp),%eax
80105fa0:	0f b6 00             	movzbl (%eax),%eax
80105fa3:	84 c0                	test   %al,%al
80105fa5:	74 10                	je     80105fb7 <strncmp+0x31>
80105fa7:	8b 45 08             	mov    0x8(%ebp),%eax
80105faa:	0f b6 10             	movzbl (%eax),%edx
80105fad:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fb0:	0f b6 00             	movzbl (%eax),%eax
80105fb3:	38 c2                	cmp    %al,%dl
80105fb5:	74 d4                	je     80105f8b <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105fb7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105fbb:	75 07                	jne    80105fc4 <strncmp+0x3e>
    return 0;
80105fbd:	b8 00 00 00 00       	mov    $0x0,%eax
80105fc2:	eb 16                	jmp    80105fda <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105fc4:	8b 45 08             	mov    0x8(%ebp),%eax
80105fc7:	0f b6 00             	movzbl (%eax),%eax
80105fca:	0f b6 d0             	movzbl %al,%edx
80105fcd:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fd0:	0f b6 00             	movzbl (%eax),%eax
80105fd3:	0f b6 c0             	movzbl %al,%eax
80105fd6:	29 c2                	sub    %eax,%edx
80105fd8:	89 d0                	mov    %edx,%eax
}
80105fda:	5d                   	pop    %ebp
80105fdb:	c3                   	ret    

80105fdc <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105fdc:	55                   	push   %ebp
80105fdd:	89 e5                	mov    %esp,%ebp
80105fdf:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105fe2:	8b 45 08             	mov    0x8(%ebp),%eax
80105fe5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105fe8:	90                   	nop
80105fe9:	8b 45 10             	mov    0x10(%ebp),%eax
80105fec:	8d 50 ff             	lea    -0x1(%eax),%edx
80105fef:	89 55 10             	mov    %edx,0x10(%ebp)
80105ff2:	85 c0                	test   %eax,%eax
80105ff4:	7e 2c                	jle    80106022 <strncpy+0x46>
80105ff6:	8b 45 08             	mov    0x8(%ebp),%eax
80105ff9:	8d 50 01             	lea    0x1(%eax),%edx
80105ffc:	89 55 08             	mov    %edx,0x8(%ebp)
80105fff:	8b 55 0c             	mov    0xc(%ebp),%edx
80106002:	8d 4a 01             	lea    0x1(%edx),%ecx
80106005:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80106008:	0f b6 12             	movzbl (%edx),%edx
8010600b:	88 10                	mov    %dl,(%eax)
8010600d:	0f b6 00             	movzbl (%eax),%eax
80106010:	84 c0                	test   %al,%al
80106012:	75 d5                	jne    80105fe9 <strncpy+0xd>
    ;
  while(n-- > 0)
80106014:	eb 0c                	jmp    80106022 <strncpy+0x46>
    *s++ = 0;
80106016:	8b 45 08             	mov    0x8(%ebp),%eax
80106019:	8d 50 01             	lea    0x1(%eax),%edx
8010601c:	89 55 08             	mov    %edx,0x8(%ebp)
8010601f:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80106022:	8b 45 10             	mov    0x10(%ebp),%eax
80106025:	8d 50 ff             	lea    -0x1(%eax),%edx
80106028:	89 55 10             	mov    %edx,0x10(%ebp)
8010602b:	85 c0                	test   %eax,%eax
8010602d:	7f e7                	jg     80106016 <strncpy+0x3a>
    *s++ = 0;
  return os;
8010602f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106032:	c9                   	leave  
80106033:	c3                   	ret    

80106034 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80106034:	55                   	push   %ebp
80106035:	89 e5                	mov    %esp,%ebp
80106037:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010603a:	8b 45 08             	mov    0x8(%ebp),%eax
8010603d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80106040:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106044:	7f 05                	jg     8010604b <safestrcpy+0x17>
    return os;
80106046:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106049:	eb 31                	jmp    8010607c <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
8010604b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010604f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106053:	7e 1e                	jle    80106073 <safestrcpy+0x3f>
80106055:	8b 45 08             	mov    0x8(%ebp),%eax
80106058:	8d 50 01             	lea    0x1(%eax),%edx
8010605b:	89 55 08             	mov    %edx,0x8(%ebp)
8010605e:	8b 55 0c             	mov    0xc(%ebp),%edx
80106061:	8d 4a 01             	lea    0x1(%edx),%ecx
80106064:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80106067:	0f b6 12             	movzbl (%edx),%edx
8010606a:	88 10                	mov    %dl,(%eax)
8010606c:	0f b6 00             	movzbl (%eax),%eax
8010606f:	84 c0                	test   %al,%al
80106071:	75 d8                	jne    8010604b <safestrcpy+0x17>
    ;
  *s = 0;
80106073:	8b 45 08             	mov    0x8(%ebp),%eax
80106076:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80106079:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010607c:	c9                   	leave  
8010607d:	c3                   	ret    

8010607e <strlen>:

int
strlen(const char *s)
{
8010607e:	55                   	push   %ebp
8010607f:	89 e5                	mov    %esp,%ebp
80106081:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80106084:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010608b:	eb 04                	jmp    80106091 <strlen+0x13>
8010608d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106091:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106094:	8b 45 08             	mov    0x8(%ebp),%eax
80106097:	01 d0                	add    %edx,%eax
80106099:	0f b6 00             	movzbl (%eax),%eax
8010609c:	84 c0                	test   %al,%al
8010609e:	75 ed                	jne    8010608d <strlen+0xf>
    ;
  return n;
801060a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801060a3:	c9                   	leave  
801060a4:	c3                   	ret    

801060a5 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801060a5:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801060a9:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801060ad:	55                   	push   %ebp
  pushl %ebx
801060ae:	53                   	push   %ebx
  pushl %esi
801060af:	56                   	push   %esi
  pushl %edi
801060b0:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801060b1:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801060b3:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801060b5:	5f                   	pop    %edi
  popl %esi
801060b6:	5e                   	pop    %esi
  popl %ebx
801060b7:	5b                   	pop    %ebx
  popl %ebp
801060b8:	5d                   	pop    %ebp
  ret
801060b9:	c3                   	ret    

801060ba <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801060ba:	55                   	push   %ebp
801060bb:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801060bd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060c3:	8b 00                	mov    (%eax),%eax
801060c5:	3b 45 08             	cmp    0x8(%ebp),%eax
801060c8:	76 12                	jbe    801060dc <fetchint+0x22>
801060ca:	8b 45 08             	mov    0x8(%ebp),%eax
801060cd:	8d 50 04             	lea    0x4(%eax),%edx
801060d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060d6:	8b 00                	mov    (%eax),%eax
801060d8:	39 c2                	cmp    %eax,%edx
801060da:	76 07                	jbe    801060e3 <fetchint+0x29>
    return -1;
801060dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060e1:	eb 0f                	jmp    801060f2 <fetchint+0x38>
  *ip = *(int*)(addr);
801060e3:	8b 45 08             	mov    0x8(%ebp),%eax
801060e6:	8b 10                	mov    (%eax),%edx
801060e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801060eb:	89 10                	mov    %edx,(%eax)
  return 0;
801060ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060f2:	5d                   	pop    %ebp
801060f3:	c3                   	ret    

801060f4 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801060f4:	55                   	push   %ebp
801060f5:	89 e5                	mov    %esp,%ebp
801060f7:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801060fa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106100:	8b 00                	mov    (%eax),%eax
80106102:	3b 45 08             	cmp    0x8(%ebp),%eax
80106105:	77 07                	ja     8010610e <fetchstr+0x1a>
    return -1;
80106107:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010610c:	eb 46                	jmp    80106154 <fetchstr+0x60>
  *pp = (char*)addr;
8010610e:	8b 55 08             	mov    0x8(%ebp),%edx
80106111:	8b 45 0c             	mov    0xc(%ebp),%eax
80106114:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80106116:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010611c:	8b 00                	mov    (%eax),%eax
8010611e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80106121:	8b 45 0c             	mov    0xc(%ebp),%eax
80106124:	8b 00                	mov    (%eax),%eax
80106126:	89 45 fc             	mov    %eax,-0x4(%ebp)
80106129:	eb 1c                	jmp    80106147 <fetchstr+0x53>
    if(*s == 0)
8010612b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010612e:	0f b6 00             	movzbl (%eax),%eax
80106131:	84 c0                	test   %al,%al
80106133:	75 0e                	jne    80106143 <fetchstr+0x4f>
      return s - *pp;
80106135:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106138:	8b 45 0c             	mov    0xc(%ebp),%eax
8010613b:	8b 00                	mov    (%eax),%eax
8010613d:	29 c2                	sub    %eax,%edx
8010613f:	89 d0                	mov    %edx,%eax
80106141:	eb 11                	jmp    80106154 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80106143:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106147:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010614a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010614d:	72 dc                	jb     8010612b <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
8010614f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106154:	c9                   	leave  
80106155:	c3                   	ret    

80106156 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80106156:	55                   	push   %ebp
80106157:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80106159:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010615f:	8b 40 18             	mov    0x18(%eax),%eax
80106162:	8b 40 44             	mov    0x44(%eax),%eax
80106165:	8b 55 08             	mov    0x8(%ebp),%edx
80106168:	c1 e2 02             	shl    $0x2,%edx
8010616b:	01 d0                	add    %edx,%eax
8010616d:	83 c0 04             	add    $0x4,%eax
80106170:	ff 75 0c             	pushl  0xc(%ebp)
80106173:	50                   	push   %eax
80106174:	e8 41 ff ff ff       	call   801060ba <fetchint>
80106179:	83 c4 08             	add    $0x8,%esp
}
8010617c:	c9                   	leave  
8010617d:	c3                   	ret    

8010617e <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010617e:	55                   	push   %ebp
8010617f:	89 e5                	mov    %esp,%ebp
80106181:	83 ec 10             	sub    $0x10,%esp
  int i;

  if(argint(n, &i) < 0)
80106184:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106187:	50                   	push   %eax
80106188:	ff 75 08             	pushl  0x8(%ebp)
8010618b:	e8 c6 ff ff ff       	call   80106156 <argint>
80106190:	83 c4 08             	add    $0x8,%esp
80106193:	85 c0                	test   %eax,%eax
80106195:	79 07                	jns    8010619e <argptr+0x20>
    return -1;
80106197:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010619c:	eb 3b                	jmp    801061d9 <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
8010619e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061a4:	8b 00                	mov    (%eax),%eax
801061a6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801061a9:	39 d0                	cmp    %edx,%eax
801061ab:	76 16                	jbe    801061c3 <argptr+0x45>
801061ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
801061b0:	89 c2                	mov    %eax,%edx
801061b2:	8b 45 10             	mov    0x10(%ebp),%eax
801061b5:	01 c2                	add    %eax,%edx
801061b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061bd:	8b 00                	mov    (%eax),%eax
801061bf:	39 c2                	cmp    %eax,%edx
801061c1:	76 07                	jbe    801061ca <argptr+0x4c>
    return -1;
801061c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061c8:	eb 0f                	jmp    801061d9 <argptr+0x5b>
  *pp = (char*)i;
801061ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
801061cd:	89 c2                	mov    %eax,%edx
801061cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801061d2:	89 10                	mov    %edx,(%eax)
  return 0;
801061d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061d9:	c9                   	leave  
801061da:	c3                   	ret    

801061db <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801061db:	55                   	push   %ebp
801061dc:	89 e5                	mov    %esp,%ebp
801061de:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
801061e1:	8d 45 fc             	lea    -0x4(%ebp),%eax
801061e4:	50                   	push   %eax
801061e5:	ff 75 08             	pushl  0x8(%ebp)
801061e8:	e8 69 ff ff ff       	call   80106156 <argint>
801061ed:	83 c4 08             	add    $0x8,%esp
801061f0:	85 c0                	test   %eax,%eax
801061f2:	79 07                	jns    801061fb <argstr+0x20>
    return -1;
801061f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061f9:	eb 0f                	jmp    8010620a <argstr+0x2f>
  return fetchstr(addr, pp);
801061fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801061fe:	ff 75 0c             	pushl  0xc(%ebp)
80106201:	50                   	push   %eax
80106202:	e8 ed fe ff ff       	call   801060f4 <fetchstr>
80106207:	83 c4 08             	add    $0x8,%esp
}
8010620a:	c9                   	leave  
8010620b:	c3                   	ret    

8010620c <syscall>:
};
#endif

void
syscall(void)
{
8010620c:	55                   	push   %ebp
8010620d:	89 e5                	mov    %esp,%ebp
8010620f:	53                   	push   %ebx
80106210:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
80106213:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106219:	8b 40 18             	mov    0x18(%eax),%eax
8010621c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010621f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80106222:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106226:	7e 30                	jle    80106258 <syscall+0x4c>
80106228:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010622b:	83 f8 1c             	cmp    $0x1c,%eax
8010622e:	77 28                	ja     80106258 <syscall+0x4c>
80106230:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106233:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
8010623a:	85 c0                	test   %eax,%eax
8010623c:	74 1a                	je     80106258 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
8010623e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106244:	8b 58 18             	mov    0x18(%eax),%ebx
80106247:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010624a:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80106251:	ff d0                	call   *%eax
80106253:	89 43 1c             	mov    %eax,0x1c(%ebx)
80106256:	eb 34                	jmp    8010628c <syscall+0x80>
#ifdef PRINT_SYSCALLS
    cprintf("%s -> %d\n",syscallnames[num],proc->tf->eax);
#endif
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80106258:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010625e:	8d 50 6c             	lea    0x6c(%eax),%edx
80106261:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
// some code goes here
#ifdef PRINT_SYSCALLS
    cprintf("%s -> %d\n",syscallnames[num],proc->tf->eax);
#endif
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80106267:	8b 40 10             	mov    0x10(%eax),%eax
8010626a:	ff 75 f4             	pushl  -0xc(%ebp)
8010626d:	52                   	push   %edx
8010626e:	50                   	push   %eax
8010626f:	68 8a 97 10 80       	push   $0x8010978a
80106274:	e8 4d a1 ff ff       	call   801003c6 <cprintf>
80106279:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
8010627c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106282:	8b 40 18             	mov    0x18(%eax),%eax
80106285:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010628c:	90                   	nop
8010628d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106290:	c9                   	leave  
80106291:	c3                   	ret    

80106292 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80106292:	55                   	push   %ebp
80106293:	89 e5                	mov    %esp,%ebp
80106295:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80106298:	83 ec 08             	sub    $0x8,%esp
8010629b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010629e:	50                   	push   %eax
8010629f:	ff 75 08             	pushl  0x8(%ebp)
801062a2:	e8 af fe ff ff       	call   80106156 <argint>
801062a7:	83 c4 10             	add    $0x10,%esp
801062aa:	85 c0                	test   %eax,%eax
801062ac:	79 07                	jns    801062b5 <argfd+0x23>
    return -1;
801062ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062b3:	eb 50                	jmp    80106305 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801062b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062b8:	85 c0                	test   %eax,%eax
801062ba:	78 21                	js     801062dd <argfd+0x4b>
801062bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062bf:	83 f8 0f             	cmp    $0xf,%eax
801062c2:	7f 19                	jg     801062dd <argfd+0x4b>
801062c4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062ca:	8b 55 f0             	mov    -0x10(%ebp),%edx
801062cd:	83 c2 08             	add    $0x8,%edx
801062d0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801062d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062db:	75 07                	jne    801062e4 <argfd+0x52>
    return -1;
801062dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062e2:	eb 21                	jmp    80106305 <argfd+0x73>
  if(pfd)
801062e4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801062e8:	74 08                	je     801062f2 <argfd+0x60>
    *pfd = fd;
801062ea:	8b 55 f0             	mov    -0x10(%ebp),%edx
801062ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801062f0:	89 10                	mov    %edx,(%eax)
  if(pf)
801062f2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801062f6:	74 08                	je     80106300 <argfd+0x6e>
    *pf = f;
801062f8:	8b 45 10             	mov    0x10(%ebp),%eax
801062fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062fe:	89 10                	mov    %edx,(%eax)
  return 0;
80106300:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106305:	c9                   	leave  
80106306:	c3                   	ret    

80106307 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80106307:	55                   	push   %ebp
80106308:	89 e5                	mov    %esp,%ebp
8010630a:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010630d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106314:	eb 30                	jmp    80106346 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80106316:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010631c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010631f:	83 c2 08             	add    $0x8,%edx
80106322:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106326:	85 c0                	test   %eax,%eax
80106328:	75 18                	jne    80106342 <fdalloc+0x3b>
      proc->ofile[fd] = f;
8010632a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106330:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106333:	8d 4a 08             	lea    0x8(%edx),%ecx
80106336:	8b 55 08             	mov    0x8(%ebp),%edx
80106339:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010633d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106340:	eb 0f                	jmp    80106351 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80106342:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106346:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
8010634a:	7e ca                	jle    80106316 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
8010634c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106351:	c9                   	leave  
80106352:	c3                   	ret    

80106353 <sys_dup>:

int
sys_dup(void)
{
80106353:	55                   	push   %ebp
80106354:	89 e5                	mov    %esp,%ebp
80106356:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80106359:	83 ec 04             	sub    $0x4,%esp
8010635c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010635f:	50                   	push   %eax
80106360:	6a 00                	push   $0x0
80106362:	6a 00                	push   $0x0
80106364:	e8 29 ff ff ff       	call   80106292 <argfd>
80106369:	83 c4 10             	add    $0x10,%esp
8010636c:	85 c0                	test   %eax,%eax
8010636e:	79 07                	jns    80106377 <sys_dup+0x24>
    return -1;
80106370:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106375:	eb 31                	jmp    801063a8 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80106377:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010637a:	83 ec 0c             	sub    $0xc,%esp
8010637d:	50                   	push   %eax
8010637e:	e8 84 ff ff ff       	call   80106307 <fdalloc>
80106383:	83 c4 10             	add    $0x10,%esp
80106386:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106389:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010638d:	79 07                	jns    80106396 <sys_dup+0x43>
    return -1;
8010638f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106394:	eb 12                	jmp    801063a8 <sys_dup+0x55>
  filedup(f);
80106396:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106399:	83 ec 0c             	sub    $0xc,%esp
8010639c:	50                   	push   %eax
8010639d:	e8 fc ac ff ff       	call   8010109e <filedup>
801063a2:	83 c4 10             	add    $0x10,%esp
  return fd;
801063a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801063a8:	c9                   	leave  
801063a9:	c3                   	ret    

801063aa <sys_read>:

int
sys_read(void)
{
801063aa:	55                   	push   %ebp
801063ab:	89 e5                	mov    %esp,%ebp
801063ad:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801063b0:	83 ec 04             	sub    $0x4,%esp
801063b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063b6:	50                   	push   %eax
801063b7:	6a 00                	push   $0x0
801063b9:	6a 00                	push   $0x0
801063bb:	e8 d2 fe ff ff       	call   80106292 <argfd>
801063c0:	83 c4 10             	add    $0x10,%esp
801063c3:	85 c0                	test   %eax,%eax
801063c5:	78 2e                	js     801063f5 <sys_read+0x4b>
801063c7:	83 ec 08             	sub    $0x8,%esp
801063ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063cd:	50                   	push   %eax
801063ce:	6a 02                	push   $0x2
801063d0:	e8 81 fd ff ff       	call   80106156 <argint>
801063d5:	83 c4 10             	add    $0x10,%esp
801063d8:	85 c0                	test   %eax,%eax
801063da:	78 19                	js     801063f5 <sys_read+0x4b>
801063dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063df:	83 ec 04             	sub    $0x4,%esp
801063e2:	50                   	push   %eax
801063e3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801063e6:	50                   	push   %eax
801063e7:	6a 01                	push   $0x1
801063e9:	e8 90 fd ff ff       	call   8010617e <argptr>
801063ee:	83 c4 10             	add    $0x10,%esp
801063f1:	85 c0                	test   %eax,%eax
801063f3:	79 07                	jns    801063fc <sys_read+0x52>
    return -1;
801063f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063fa:	eb 17                	jmp    80106413 <sys_read+0x69>
  return fileread(f, p, n);
801063fc:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801063ff:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106405:	83 ec 04             	sub    $0x4,%esp
80106408:	51                   	push   %ecx
80106409:	52                   	push   %edx
8010640a:	50                   	push   %eax
8010640b:	e8 1e ae ff ff       	call   8010122e <fileread>
80106410:	83 c4 10             	add    $0x10,%esp
}
80106413:	c9                   	leave  
80106414:	c3                   	ret    

80106415 <sys_write>:

int
sys_write(void)
{
80106415:	55                   	push   %ebp
80106416:	89 e5                	mov    %esp,%ebp
80106418:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010641b:	83 ec 04             	sub    $0x4,%esp
8010641e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106421:	50                   	push   %eax
80106422:	6a 00                	push   $0x0
80106424:	6a 00                	push   $0x0
80106426:	e8 67 fe ff ff       	call   80106292 <argfd>
8010642b:	83 c4 10             	add    $0x10,%esp
8010642e:	85 c0                	test   %eax,%eax
80106430:	78 2e                	js     80106460 <sys_write+0x4b>
80106432:	83 ec 08             	sub    $0x8,%esp
80106435:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106438:	50                   	push   %eax
80106439:	6a 02                	push   $0x2
8010643b:	e8 16 fd ff ff       	call   80106156 <argint>
80106440:	83 c4 10             	add    $0x10,%esp
80106443:	85 c0                	test   %eax,%eax
80106445:	78 19                	js     80106460 <sys_write+0x4b>
80106447:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010644a:	83 ec 04             	sub    $0x4,%esp
8010644d:	50                   	push   %eax
8010644e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106451:	50                   	push   %eax
80106452:	6a 01                	push   $0x1
80106454:	e8 25 fd ff ff       	call   8010617e <argptr>
80106459:	83 c4 10             	add    $0x10,%esp
8010645c:	85 c0                	test   %eax,%eax
8010645e:	79 07                	jns    80106467 <sys_write+0x52>
    return -1;
80106460:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106465:	eb 17                	jmp    8010647e <sys_write+0x69>
  return filewrite(f, p, n);
80106467:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010646a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010646d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106470:	83 ec 04             	sub    $0x4,%esp
80106473:	51                   	push   %ecx
80106474:	52                   	push   %edx
80106475:	50                   	push   %eax
80106476:	e8 6b ae ff ff       	call   801012e6 <filewrite>
8010647b:	83 c4 10             	add    $0x10,%esp
}
8010647e:	c9                   	leave  
8010647f:	c3                   	ret    

80106480 <sys_close>:

int
sys_close(void)
{
80106480:	55                   	push   %ebp
80106481:	89 e5                	mov    %esp,%ebp
80106483:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80106486:	83 ec 04             	sub    $0x4,%esp
80106489:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010648c:	50                   	push   %eax
8010648d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106490:	50                   	push   %eax
80106491:	6a 00                	push   $0x0
80106493:	e8 fa fd ff ff       	call   80106292 <argfd>
80106498:	83 c4 10             	add    $0x10,%esp
8010649b:	85 c0                	test   %eax,%eax
8010649d:	79 07                	jns    801064a6 <sys_close+0x26>
    return -1;
8010649f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064a4:	eb 28                	jmp    801064ce <sys_close+0x4e>
  proc->ofile[fd] = 0;
801064a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064af:	83 c2 08             	add    $0x8,%edx
801064b2:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801064b9:	00 
  fileclose(f);
801064ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064bd:	83 ec 0c             	sub    $0xc,%esp
801064c0:	50                   	push   %eax
801064c1:	e8 29 ac ff ff       	call   801010ef <fileclose>
801064c6:	83 c4 10             	add    $0x10,%esp
  return 0;
801064c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064ce:	c9                   	leave  
801064cf:	c3                   	ret    

801064d0 <sys_fstat>:

int
sys_fstat(void)
{
801064d0:	55                   	push   %ebp
801064d1:	89 e5                	mov    %esp,%ebp
801064d3:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801064d6:	83 ec 04             	sub    $0x4,%esp
801064d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064dc:	50                   	push   %eax
801064dd:	6a 00                	push   $0x0
801064df:	6a 00                	push   $0x0
801064e1:	e8 ac fd ff ff       	call   80106292 <argfd>
801064e6:	83 c4 10             	add    $0x10,%esp
801064e9:	85 c0                	test   %eax,%eax
801064eb:	78 17                	js     80106504 <sys_fstat+0x34>
801064ed:	83 ec 04             	sub    $0x4,%esp
801064f0:	6a 14                	push   $0x14
801064f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064f5:	50                   	push   %eax
801064f6:	6a 01                	push   $0x1
801064f8:	e8 81 fc ff ff       	call   8010617e <argptr>
801064fd:	83 c4 10             	add    $0x10,%esp
80106500:	85 c0                	test   %eax,%eax
80106502:	79 07                	jns    8010650b <sys_fstat+0x3b>
    return -1;
80106504:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106509:	eb 13                	jmp    8010651e <sys_fstat+0x4e>
  return filestat(f, st);
8010650b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010650e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106511:	83 ec 08             	sub    $0x8,%esp
80106514:	52                   	push   %edx
80106515:	50                   	push   %eax
80106516:	e8 bc ac ff ff       	call   801011d7 <filestat>
8010651b:	83 c4 10             	add    $0x10,%esp
}
8010651e:	c9                   	leave  
8010651f:	c3                   	ret    

80106520 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80106520:	55                   	push   %ebp
80106521:	89 e5                	mov    %esp,%ebp
80106523:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80106526:	83 ec 08             	sub    $0x8,%esp
80106529:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010652c:	50                   	push   %eax
8010652d:	6a 00                	push   $0x0
8010652f:	e8 a7 fc ff ff       	call   801061db <argstr>
80106534:	83 c4 10             	add    $0x10,%esp
80106537:	85 c0                	test   %eax,%eax
80106539:	78 15                	js     80106550 <sys_link+0x30>
8010653b:	83 ec 08             	sub    $0x8,%esp
8010653e:	8d 45 dc             	lea    -0x24(%ebp),%eax
80106541:	50                   	push   %eax
80106542:	6a 01                	push   $0x1
80106544:	e8 92 fc ff ff       	call   801061db <argstr>
80106549:	83 c4 10             	add    $0x10,%esp
8010654c:	85 c0                	test   %eax,%eax
8010654e:	79 0a                	jns    8010655a <sys_link+0x3a>
    return -1;
80106550:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106555:	e9 68 01 00 00       	jmp    801066c2 <sys_link+0x1a2>

  begin_op();
8010655a:	e8 8c d0 ff ff       	call   801035eb <begin_op>
  if((ip = namei(old)) == 0){
8010655f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106562:	83 ec 0c             	sub    $0xc,%esp
80106565:	50                   	push   %eax
80106566:	e8 5b c0 ff ff       	call   801025c6 <namei>
8010656b:	83 c4 10             	add    $0x10,%esp
8010656e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106571:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106575:	75 0f                	jne    80106586 <sys_link+0x66>
    end_op();
80106577:	e8 fb d0 ff ff       	call   80103677 <end_op>
    return -1;
8010657c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106581:	e9 3c 01 00 00       	jmp    801066c2 <sys_link+0x1a2>
  }

  ilock(ip);
80106586:	83 ec 0c             	sub    $0xc,%esp
80106589:	ff 75 f4             	pushl  -0xc(%ebp)
8010658c:	e8 77 b4 ff ff       	call   80101a08 <ilock>
80106591:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80106594:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106597:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010659b:	66 83 f8 01          	cmp    $0x1,%ax
8010659f:	75 1d                	jne    801065be <sys_link+0x9e>
    iunlockput(ip);
801065a1:	83 ec 0c             	sub    $0xc,%esp
801065a4:	ff 75 f4             	pushl  -0xc(%ebp)
801065a7:	e8 1c b7 ff ff       	call   80101cc8 <iunlockput>
801065ac:	83 c4 10             	add    $0x10,%esp
    end_op();
801065af:	e8 c3 d0 ff ff       	call   80103677 <end_op>
    return -1;
801065b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065b9:	e9 04 01 00 00       	jmp    801066c2 <sys_link+0x1a2>
  }

  ip->nlink++;
801065be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065c1:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801065c5:	83 c0 01             	add    $0x1,%eax
801065c8:	89 c2                	mov    %eax,%edx
801065ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065cd:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801065d1:	83 ec 0c             	sub    $0xc,%esp
801065d4:	ff 75 f4             	pushl  -0xc(%ebp)
801065d7:	e8 52 b2 ff ff       	call   8010182e <iupdate>
801065dc:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801065df:	83 ec 0c             	sub    $0xc,%esp
801065e2:	ff 75 f4             	pushl  -0xc(%ebp)
801065e5:	e8 7c b5 ff ff       	call   80101b66 <iunlock>
801065ea:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801065ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
801065f0:	83 ec 08             	sub    $0x8,%esp
801065f3:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801065f6:	52                   	push   %edx
801065f7:	50                   	push   %eax
801065f8:	e8 e5 bf ff ff       	call   801025e2 <nameiparent>
801065fd:	83 c4 10             	add    $0x10,%esp
80106600:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106603:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106607:	74 71                	je     8010667a <sys_link+0x15a>
    goto bad;
  ilock(dp);
80106609:	83 ec 0c             	sub    $0xc,%esp
8010660c:	ff 75 f0             	pushl  -0x10(%ebp)
8010660f:	e8 f4 b3 ff ff       	call   80101a08 <ilock>
80106614:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80106617:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010661a:	8b 10                	mov    (%eax),%edx
8010661c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010661f:	8b 00                	mov    (%eax),%eax
80106621:	39 c2                	cmp    %eax,%edx
80106623:	75 1d                	jne    80106642 <sys_link+0x122>
80106625:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106628:	8b 40 04             	mov    0x4(%eax),%eax
8010662b:	83 ec 04             	sub    $0x4,%esp
8010662e:	50                   	push   %eax
8010662f:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106632:	50                   	push   %eax
80106633:	ff 75 f0             	pushl  -0x10(%ebp)
80106636:	e8 ef bc ff ff       	call   8010232a <dirlink>
8010663b:	83 c4 10             	add    $0x10,%esp
8010663e:	85 c0                	test   %eax,%eax
80106640:	79 10                	jns    80106652 <sys_link+0x132>
    iunlockput(dp);
80106642:	83 ec 0c             	sub    $0xc,%esp
80106645:	ff 75 f0             	pushl  -0x10(%ebp)
80106648:	e8 7b b6 ff ff       	call   80101cc8 <iunlockput>
8010664d:	83 c4 10             	add    $0x10,%esp
    goto bad;
80106650:	eb 29                	jmp    8010667b <sys_link+0x15b>
  }
  iunlockput(dp);
80106652:	83 ec 0c             	sub    $0xc,%esp
80106655:	ff 75 f0             	pushl  -0x10(%ebp)
80106658:	e8 6b b6 ff ff       	call   80101cc8 <iunlockput>
8010665d:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80106660:	83 ec 0c             	sub    $0xc,%esp
80106663:	ff 75 f4             	pushl  -0xc(%ebp)
80106666:	e8 6d b5 ff ff       	call   80101bd8 <iput>
8010666b:	83 c4 10             	add    $0x10,%esp

  end_op();
8010666e:	e8 04 d0 ff ff       	call   80103677 <end_op>

  return 0;
80106673:	b8 00 00 00 00       	mov    $0x0,%eax
80106678:	eb 48                	jmp    801066c2 <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
8010667a:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
8010667b:	83 ec 0c             	sub    $0xc,%esp
8010667e:	ff 75 f4             	pushl  -0xc(%ebp)
80106681:	e8 82 b3 ff ff       	call   80101a08 <ilock>
80106686:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80106689:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010668c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106690:	83 e8 01             	sub    $0x1,%eax
80106693:	89 c2                	mov    %eax,%edx
80106695:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106698:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010669c:	83 ec 0c             	sub    $0xc,%esp
8010669f:	ff 75 f4             	pushl  -0xc(%ebp)
801066a2:	e8 87 b1 ff ff       	call   8010182e <iupdate>
801066a7:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801066aa:	83 ec 0c             	sub    $0xc,%esp
801066ad:	ff 75 f4             	pushl  -0xc(%ebp)
801066b0:	e8 13 b6 ff ff       	call   80101cc8 <iunlockput>
801066b5:	83 c4 10             	add    $0x10,%esp
  end_op();
801066b8:	e8 ba cf ff ff       	call   80103677 <end_op>
  return -1;
801066bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801066c2:	c9                   	leave  
801066c3:	c3                   	ret    

801066c4 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801066c4:	55                   	push   %ebp
801066c5:	89 e5                	mov    %esp,%ebp
801066c7:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801066ca:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801066d1:	eb 40                	jmp    80106713 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801066d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066d6:	6a 10                	push   $0x10
801066d8:	50                   	push   %eax
801066d9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801066dc:	50                   	push   %eax
801066dd:	ff 75 08             	pushl  0x8(%ebp)
801066e0:	e8 91 b8 ff ff       	call   80101f76 <readi>
801066e5:	83 c4 10             	add    $0x10,%esp
801066e8:	83 f8 10             	cmp    $0x10,%eax
801066eb:	74 0d                	je     801066fa <isdirempty+0x36>
      panic("isdirempty: readi");
801066ed:	83 ec 0c             	sub    $0xc,%esp
801066f0:	68 a6 97 10 80       	push   $0x801097a6
801066f5:	e8 6c 9e ff ff       	call   80100566 <panic>
    if(de.inum != 0)
801066fa:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801066fe:	66 85 c0             	test   %ax,%ax
80106701:	74 07                	je     8010670a <isdirempty+0x46>
      return 0;
80106703:	b8 00 00 00 00       	mov    $0x0,%eax
80106708:	eb 1b                	jmp    80106725 <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010670a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010670d:	83 c0 10             	add    $0x10,%eax
80106710:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106713:	8b 45 08             	mov    0x8(%ebp),%eax
80106716:	8b 50 18             	mov    0x18(%eax),%edx
80106719:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010671c:	39 c2                	cmp    %eax,%edx
8010671e:	77 b3                	ja     801066d3 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80106720:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106725:	c9                   	leave  
80106726:	c3                   	ret    

80106727 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80106727:	55                   	push   %ebp
80106728:	89 e5                	mov    %esp,%ebp
8010672a:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010672d:	83 ec 08             	sub    $0x8,%esp
80106730:	8d 45 cc             	lea    -0x34(%ebp),%eax
80106733:	50                   	push   %eax
80106734:	6a 00                	push   $0x0
80106736:	e8 a0 fa ff ff       	call   801061db <argstr>
8010673b:	83 c4 10             	add    $0x10,%esp
8010673e:	85 c0                	test   %eax,%eax
80106740:	79 0a                	jns    8010674c <sys_unlink+0x25>
    return -1;
80106742:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106747:	e9 bc 01 00 00       	jmp    80106908 <sys_unlink+0x1e1>

  begin_op();
8010674c:	e8 9a ce ff ff       	call   801035eb <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80106751:	8b 45 cc             	mov    -0x34(%ebp),%eax
80106754:	83 ec 08             	sub    $0x8,%esp
80106757:	8d 55 d2             	lea    -0x2e(%ebp),%edx
8010675a:	52                   	push   %edx
8010675b:	50                   	push   %eax
8010675c:	e8 81 be ff ff       	call   801025e2 <nameiparent>
80106761:	83 c4 10             	add    $0x10,%esp
80106764:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106767:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010676b:	75 0f                	jne    8010677c <sys_unlink+0x55>
    end_op();
8010676d:	e8 05 cf ff ff       	call   80103677 <end_op>
    return -1;
80106772:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106777:	e9 8c 01 00 00       	jmp    80106908 <sys_unlink+0x1e1>
  }

  ilock(dp);
8010677c:	83 ec 0c             	sub    $0xc,%esp
8010677f:	ff 75 f4             	pushl  -0xc(%ebp)
80106782:	e8 81 b2 ff ff       	call   80101a08 <ilock>
80106787:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010678a:	83 ec 08             	sub    $0x8,%esp
8010678d:	68 b8 97 10 80       	push   $0x801097b8
80106792:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106795:	50                   	push   %eax
80106796:	e8 ba ba ff ff       	call   80102255 <namecmp>
8010679b:	83 c4 10             	add    $0x10,%esp
8010679e:	85 c0                	test   %eax,%eax
801067a0:	0f 84 4a 01 00 00    	je     801068f0 <sys_unlink+0x1c9>
801067a6:	83 ec 08             	sub    $0x8,%esp
801067a9:	68 ba 97 10 80       	push   $0x801097ba
801067ae:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801067b1:	50                   	push   %eax
801067b2:	e8 9e ba ff ff       	call   80102255 <namecmp>
801067b7:	83 c4 10             	add    $0x10,%esp
801067ba:	85 c0                	test   %eax,%eax
801067bc:	0f 84 2e 01 00 00    	je     801068f0 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801067c2:	83 ec 04             	sub    $0x4,%esp
801067c5:	8d 45 c8             	lea    -0x38(%ebp),%eax
801067c8:	50                   	push   %eax
801067c9:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801067cc:	50                   	push   %eax
801067cd:	ff 75 f4             	pushl  -0xc(%ebp)
801067d0:	e8 9b ba ff ff       	call   80102270 <dirlookup>
801067d5:	83 c4 10             	add    $0x10,%esp
801067d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801067db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801067df:	0f 84 0a 01 00 00    	je     801068ef <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
801067e5:	83 ec 0c             	sub    $0xc,%esp
801067e8:	ff 75 f0             	pushl  -0x10(%ebp)
801067eb:	e8 18 b2 ff ff       	call   80101a08 <ilock>
801067f0:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
801067f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067f6:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801067fa:	66 85 c0             	test   %ax,%ax
801067fd:	7f 0d                	jg     8010680c <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
801067ff:	83 ec 0c             	sub    $0xc,%esp
80106802:	68 bd 97 10 80       	push   $0x801097bd
80106807:	e8 5a 9d ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010680c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010680f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106813:	66 83 f8 01          	cmp    $0x1,%ax
80106817:	75 25                	jne    8010683e <sys_unlink+0x117>
80106819:	83 ec 0c             	sub    $0xc,%esp
8010681c:	ff 75 f0             	pushl  -0x10(%ebp)
8010681f:	e8 a0 fe ff ff       	call   801066c4 <isdirempty>
80106824:	83 c4 10             	add    $0x10,%esp
80106827:	85 c0                	test   %eax,%eax
80106829:	75 13                	jne    8010683e <sys_unlink+0x117>
    iunlockput(ip);
8010682b:	83 ec 0c             	sub    $0xc,%esp
8010682e:	ff 75 f0             	pushl  -0x10(%ebp)
80106831:	e8 92 b4 ff ff       	call   80101cc8 <iunlockput>
80106836:	83 c4 10             	add    $0x10,%esp
    goto bad;
80106839:	e9 b2 00 00 00       	jmp    801068f0 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
8010683e:	83 ec 04             	sub    $0x4,%esp
80106841:	6a 10                	push   $0x10
80106843:	6a 00                	push   $0x0
80106845:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106848:	50                   	push   %eax
80106849:	e8 e3 f5 ff ff       	call   80105e31 <memset>
8010684e:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106851:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106854:	6a 10                	push   $0x10
80106856:	50                   	push   %eax
80106857:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010685a:	50                   	push   %eax
8010685b:	ff 75 f4             	pushl  -0xc(%ebp)
8010685e:	e8 6a b8 ff ff       	call   801020cd <writei>
80106863:	83 c4 10             	add    $0x10,%esp
80106866:	83 f8 10             	cmp    $0x10,%eax
80106869:	74 0d                	je     80106878 <sys_unlink+0x151>
    panic("unlink: writei");
8010686b:	83 ec 0c             	sub    $0xc,%esp
8010686e:	68 cf 97 10 80       	push   $0x801097cf
80106873:	e8 ee 9c ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
80106878:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010687b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010687f:	66 83 f8 01          	cmp    $0x1,%ax
80106883:	75 21                	jne    801068a6 <sys_unlink+0x17f>
    dp->nlink--;
80106885:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106888:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010688c:	83 e8 01             	sub    $0x1,%eax
8010688f:	89 c2                	mov    %eax,%edx
80106891:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106894:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106898:	83 ec 0c             	sub    $0xc,%esp
8010689b:	ff 75 f4             	pushl  -0xc(%ebp)
8010689e:	e8 8b af ff ff       	call   8010182e <iupdate>
801068a3:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801068a6:	83 ec 0c             	sub    $0xc,%esp
801068a9:	ff 75 f4             	pushl  -0xc(%ebp)
801068ac:	e8 17 b4 ff ff       	call   80101cc8 <iunlockput>
801068b1:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801068b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068b7:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801068bb:	83 e8 01             	sub    $0x1,%eax
801068be:	89 c2                	mov    %eax,%edx
801068c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068c3:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801068c7:	83 ec 0c             	sub    $0xc,%esp
801068ca:	ff 75 f0             	pushl  -0x10(%ebp)
801068cd:	e8 5c af ff ff       	call   8010182e <iupdate>
801068d2:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801068d5:	83 ec 0c             	sub    $0xc,%esp
801068d8:	ff 75 f0             	pushl  -0x10(%ebp)
801068db:	e8 e8 b3 ff ff       	call   80101cc8 <iunlockput>
801068e0:	83 c4 10             	add    $0x10,%esp

  end_op();
801068e3:	e8 8f cd ff ff       	call   80103677 <end_op>

  return 0;
801068e8:	b8 00 00 00 00       	mov    $0x0,%eax
801068ed:	eb 19                	jmp    80106908 <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
801068ef:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
801068f0:	83 ec 0c             	sub    $0xc,%esp
801068f3:	ff 75 f4             	pushl  -0xc(%ebp)
801068f6:	e8 cd b3 ff ff       	call   80101cc8 <iunlockput>
801068fb:	83 c4 10             	add    $0x10,%esp
  end_op();
801068fe:	e8 74 cd ff ff       	call   80103677 <end_op>
  return -1;
80106903:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106908:	c9                   	leave  
80106909:	c3                   	ret    

8010690a <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010690a:	55                   	push   %ebp
8010690b:	89 e5                	mov    %esp,%ebp
8010690d:	83 ec 38             	sub    $0x38,%esp
80106910:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106913:	8b 55 10             	mov    0x10(%ebp),%edx
80106916:	8b 45 14             	mov    0x14(%ebp),%eax
80106919:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010691d:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106921:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106925:	83 ec 08             	sub    $0x8,%esp
80106928:	8d 45 de             	lea    -0x22(%ebp),%eax
8010692b:	50                   	push   %eax
8010692c:	ff 75 08             	pushl  0x8(%ebp)
8010692f:	e8 ae bc ff ff       	call   801025e2 <nameiparent>
80106934:	83 c4 10             	add    $0x10,%esp
80106937:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010693a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010693e:	75 0a                	jne    8010694a <create+0x40>
    return 0;
80106940:	b8 00 00 00 00       	mov    $0x0,%eax
80106945:	e9 90 01 00 00       	jmp    80106ada <create+0x1d0>
  ilock(dp);
8010694a:	83 ec 0c             	sub    $0xc,%esp
8010694d:	ff 75 f4             	pushl  -0xc(%ebp)
80106950:	e8 b3 b0 ff ff       	call   80101a08 <ilock>
80106955:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80106958:	83 ec 04             	sub    $0x4,%esp
8010695b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010695e:	50                   	push   %eax
8010695f:	8d 45 de             	lea    -0x22(%ebp),%eax
80106962:	50                   	push   %eax
80106963:	ff 75 f4             	pushl  -0xc(%ebp)
80106966:	e8 05 b9 ff ff       	call   80102270 <dirlookup>
8010696b:	83 c4 10             	add    $0x10,%esp
8010696e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106971:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106975:	74 50                	je     801069c7 <create+0xbd>
    iunlockput(dp);
80106977:	83 ec 0c             	sub    $0xc,%esp
8010697a:	ff 75 f4             	pushl  -0xc(%ebp)
8010697d:	e8 46 b3 ff ff       	call   80101cc8 <iunlockput>
80106982:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80106985:	83 ec 0c             	sub    $0xc,%esp
80106988:	ff 75 f0             	pushl  -0x10(%ebp)
8010698b:	e8 78 b0 ff ff       	call   80101a08 <ilock>
80106990:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80106993:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106998:	75 15                	jne    801069af <create+0xa5>
8010699a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010699d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801069a1:	66 83 f8 02          	cmp    $0x2,%ax
801069a5:	75 08                	jne    801069af <create+0xa5>
      return ip;
801069a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069aa:	e9 2b 01 00 00       	jmp    80106ada <create+0x1d0>
    iunlockput(ip);
801069af:	83 ec 0c             	sub    $0xc,%esp
801069b2:	ff 75 f0             	pushl  -0x10(%ebp)
801069b5:	e8 0e b3 ff ff       	call   80101cc8 <iunlockput>
801069ba:	83 c4 10             	add    $0x10,%esp
    return 0;
801069bd:	b8 00 00 00 00       	mov    $0x0,%eax
801069c2:	e9 13 01 00 00       	jmp    80106ada <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801069c7:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801069cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ce:	8b 00                	mov    (%eax),%eax
801069d0:	83 ec 08             	sub    $0x8,%esp
801069d3:	52                   	push   %edx
801069d4:	50                   	push   %eax
801069d5:	e8 7d ad ff ff       	call   80101757 <ialloc>
801069da:	83 c4 10             	add    $0x10,%esp
801069dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
801069e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801069e4:	75 0d                	jne    801069f3 <create+0xe9>
    panic("create: ialloc");
801069e6:	83 ec 0c             	sub    $0xc,%esp
801069e9:	68 de 97 10 80       	push   $0x801097de
801069ee:	e8 73 9b ff ff       	call   80100566 <panic>

  ilock(ip);
801069f3:	83 ec 0c             	sub    $0xc,%esp
801069f6:	ff 75 f0             	pushl  -0x10(%ebp)
801069f9:	e8 0a b0 ff ff       	call   80101a08 <ilock>
801069fe:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80106a01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a04:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106a08:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106a0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a0f:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106a13:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106a17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a1a:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106a20:	83 ec 0c             	sub    $0xc,%esp
80106a23:	ff 75 f0             	pushl  -0x10(%ebp)
80106a26:	e8 03 ae ff ff       	call   8010182e <iupdate>
80106a2b:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80106a2e:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106a33:	75 6a                	jne    80106a9f <create+0x195>
    dp->nlink++;  // for ".."
80106a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a38:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106a3c:	83 c0 01             	add    $0x1,%eax
80106a3f:	89 c2                	mov    %eax,%edx
80106a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a44:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106a48:	83 ec 0c             	sub    $0xc,%esp
80106a4b:	ff 75 f4             	pushl  -0xc(%ebp)
80106a4e:	e8 db ad ff ff       	call   8010182e <iupdate>
80106a53:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106a56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a59:	8b 40 04             	mov    0x4(%eax),%eax
80106a5c:	83 ec 04             	sub    $0x4,%esp
80106a5f:	50                   	push   %eax
80106a60:	68 b8 97 10 80       	push   $0x801097b8
80106a65:	ff 75 f0             	pushl  -0x10(%ebp)
80106a68:	e8 bd b8 ff ff       	call   8010232a <dirlink>
80106a6d:	83 c4 10             	add    $0x10,%esp
80106a70:	85 c0                	test   %eax,%eax
80106a72:	78 1e                	js     80106a92 <create+0x188>
80106a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a77:	8b 40 04             	mov    0x4(%eax),%eax
80106a7a:	83 ec 04             	sub    $0x4,%esp
80106a7d:	50                   	push   %eax
80106a7e:	68 ba 97 10 80       	push   $0x801097ba
80106a83:	ff 75 f0             	pushl  -0x10(%ebp)
80106a86:	e8 9f b8 ff ff       	call   8010232a <dirlink>
80106a8b:	83 c4 10             	add    $0x10,%esp
80106a8e:	85 c0                	test   %eax,%eax
80106a90:	79 0d                	jns    80106a9f <create+0x195>
      panic("create dots");
80106a92:	83 ec 0c             	sub    $0xc,%esp
80106a95:	68 ed 97 10 80       	push   $0x801097ed
80106a9a:	e8 c7 9a ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106a9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106aa2:	8b 40 04             	mov    0x4(%eax),%eax
80106aa5:	83 ec 04             	sub    $0x4,%esp
80106aa8:	50                   	push   %eax
80106aa9:	8d 45 de             	lea    -0x22(%ebp),%eax
80106aac:	50                   	push   %eax
80106aad:	ff 75 f4             	pushl  -0xc(%ebp)
80106ab0:	e8 75 b8 ff ff       	call   8010232a <dirlink>
80106ab5:	83 c4 10             	add    $0x10,%esp
80106ab8:	85 c0                	test   %eax,%eax
80106aba:	79 0d                	jns    80106ac9 <create+0x1bf>
    panic("create: dirlink");
80106abc:	83 ec 0c             	sub    $0xc,%esp
80106abf:	68 f9 97 10 80       	push   $0x801097f9
80106ac4:	e8 9d 9a ff ff       	call   80100566 <panic>

  iunlockput(dp);
80106ac9:	83 ec 0c             	sub    $0xc,%esp
80106acc:	ff 75 f4             	pushl  -0xc(%ebp)
80106acf:	e8 f4 b1 ff ff       	call   80101cc8 <iunlockput>
80106ad4:	83 c4 10             	add    $0x10,%esp

  return ip;
80106ad7:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106ada:	c9                   	leave  
80106adb:	c3                   	ret    

80106adc <sys_open>:

int
sys_open(void)
{
80106adc:	55                   	push   %ebp
80106add:	89 e5                	mov    %esp,%ebp
80106adf:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106ae2:	83 ec 08             	sub    $0x8,%esp
80106ae5:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106ae8:	50                   	push   %eax
80106ae9:	6a 00                	push   $0x0
80106aeb:	e8 eb f6 ff ff       	call   801061db <argstr>
80106af0:	83 c4 10             	add    $0x10,%esp
80106af3:	85 c0                	test   %eax,%eax
80106af5:	78 15                	js     80106b0c <sys_open+0x30>
80106af7:	83 ec 08             	sub    $0x8,%esp
80106afa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106afd:	50                   	push   %eax
80106afe:	6a 01                	push   $0x1
80106b00:	e8 51 f6 ff ff       	call   80106156 <argint>
80106b05:	83 c4 10             	add    $0x10,%esp
80106b08:	85 c0                	test   %eax,%eax
80106b0a:	79 0a                	jns    80106b16 <sys_open+0x3a>
    return -1;
80106b0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b11:	e9 61 01 00 00       	jmp    80106c77 <sys_open+0x19b>

  begin_op();
80106b16:	e8 d0 ca ff ff       	call   801035eb <begin_op>

  if(omode & O_CREATE){
80106b1b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106b1e:	25 00 02 00 00       	and    $0x200,%eax
80106b23:	85 c0                	test   %eax,%eax
80106b25:	74 2a                	je     80106b51 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80106b27:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106b2a:	6a 00                	push   $0x0
80106b2c:	6a 00                	push   $0x0
80106b2e:	6a 02                	push   $0x2
80106b30:	50                   	push   %eax
80106b31:	e8 d4 fd ff ff       	call   8010690a <create>
80106b36:	83 c4 10             	add    $0x10,%esp
80106b39:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106b3c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106b40:	75 75                	jne    80106bb7 <sys_open+0xdb>
      end_op();
80106b42:	e8 30 cb ff ff       	call   80103677 <end_op>
      return -1;
80106b47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b4c:	e9 26 01 00 00       	jmp    80106c77 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80106b51:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106b54:	83 ec 0c             	sub    $0xc,%esp
80106b57:	50                   	push   %eax
80106b58:	e8 69 ba ff ff       	call   801025c6 <namei>
80106b5d:	83 c4 10             	add    $0x10,%esp
80106b60:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106b63:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106b67:	75 0f                	jne    80106b78 <sys_open+0x9c>
      end_op();
80106b69:	e8 09 cb ff ff       	call   80103677 <end_op>
      return -1;
80106b6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b73:	e9 ff 00 00 00       	jmp    80106c77 <sys_open+0x19b>
    }
    ilock(ip);
80106b78:	83 ec 0c             	sub    $0xc,%esp
80106b7b:	ff 75 f4             	pushl  -0xc(%ebp)
80106b7e:	e8 85 ae ff ff       	call   80101a08 <ilock>
80106b83:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b89:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106b8d:	66 83 f8 01          	cmp    $0x1,%ax
80106b91:	75 24                	jne    80106bb7 <sys_open+0xdb>
80106b93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106b96:	85 c0                	test   %eax,%eax
80106b98:	74 1d                	je     80106bb7 <sys_open+0xdb>
      iunlockput(ip);
80106b9a:	83 ec 0c             	sub    $0xc,%esp
80106b9d:	ff 75 f4             	pushl  -0xc(%ebp)
80106ba0:	e8 23 b1 ff ff       	call   80101cc8 <iunlockput>
80106ba5:	83 c4 10             	add    $0x10,%esp
      end_op();
80106ba8:	e8 ca ca ff ff       	call   80103677 <end_op>
      return -1;
80106bad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bb2:	e9 c0 00 00 00       	jmp    80106c77 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106bb7:	e8 75 a4 ff ff       	call   80101031 <filealloc>
80106bbc:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106bbf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106bc3:	74 17                	je     80106bdc <sys_open+0x100>
80106bc5:	83 ec 0c             	sub    $0xc,%esp
80106bc8:	ff 75 f0             	pushl  -0x10(%ebp)
80106bcb:	e8 37 f7 ff ff       	call   80106307 <fdalloc>
80106bd0:	83 c4 10             	add    $0x10,%esp
80106bd3:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106bd6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106bda:	79 2e                	jns    80106c0a <sys_open+0x12e>
    if(f)
80106bdc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106be0:	74 0e                	je     80106bf0 <sys_open+0x114>
      fileclose(f);
80106be2:	83 ec 0c             	sub    $0xc,%esp
80106be5:	ff 75 f0             	pushl  -0x10(%ebp)
80106be8:	e8 02 a5 ff ff       	call   801010ef <fileclose>
80106bed:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106bf0:	83 ec 0c             	sub    $0xc,%esp
80106bf3:	ff 75 f4             	pushl  -0xc(%ebp)
80106bf6:	e8 cd b0 ff ff       	call   80101cc8 <iunlockput>
80106bfb:	83 c4 10             	add    $0x10,%esp
    end_op();
80106bfe:	e8 74 ca ff ff       	call   80103677 <end_op>
    return -1;
80106c03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c08:	eb 6d                	jmp    80106c77 <sys_open+0x19b>
  }
  iunlock(ip);
80106c0a:	83 ec 0c             	sub    $0xc,%esp
80106c0d:	ff 75 f4             	pushl  -0xc(%ebp)
80106c10:	e8 51 af ff ff       	call   80101b66 <iunlock>
80106c15:	83 c4 10             	add    $0x10,%esp
  end_op();
80106c18:	e8 5a ca ff ff       	call   80103677 <end_op>

  f->type = FD_INODE;
80106c1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c20:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106c26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c29:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106c2c:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106c2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c32:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106c39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c3c:	83 e0 01             	and    $0x1,%eax
80106c3f:	85 c0                	test   %eax,%eax
80106c41:	0f 94 c0             	sete   %al
80106c44:	89 c2                	mov    %eax,%edx
80106c46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c49:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106c4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c4f:	83 e0 01             	and    $0x1,%eax
80106c52:	85 c0                	test   %eax,%eax
80106c54:	75 0a                	jne    80106c60 <sys_open+0x184>
80106c56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c59:	83 e0 02             	and    $0x2,%eax
80106c5c:	85 c0                	test   %eax,%eax
80106c5e:	74 07                	je     80106c67 <sys_open+0x18b>
80106c60:	b8 01 00 00 00       	mov    $0x1,%eax
80106c65:	eb 05                	jmp    80106c6c <sys_open+0x190>
80106c67:	b8 00 00 00 00       	mov    $0x0,%eax
80106c6c:	89 c2                	mov    %eax,%edx
80106c6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c71:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106c74:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106c77:	c9                   	leave  
80106c78:	c3                   	ret    

80106c79 <sys_mkdir>:

int
sys_mkdir(void)
{
80106c79:	55                   	push   %ebp
80106c7a:	89 e5                	mov    %esp,%ebp
80106c7c:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106c7f:	e8 67 c9 ff ff       	call   801035eb <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106c84:	83 ec 08             	sub    $0x8,%esp
80106c87:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106c8a:	50                   	push   %eax
80106c8b:	6a 00                	push   $0x0
80106c8d:	e8 49 f5 ff ff       	call   801061db <argstr>
80106c92:	83 c4 10             	add    $0x10,%esp
80106c95:	85 c0                	test   %eax,%eax
80106c97:	78 1b                	js     80106cb4 <sys_mkdir+0x3b>
80106c99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c9c:	6a 00                	push   $0x0
80106c9e:	6a 00                	push   $0x0
80106ca0:	6a 01                	push   $0x1
80106ca2:	50                   	push   %eax
80106ca3:	e8 62 fc ff ff       	call   8010690a <create>
80106ca8:	83 c4 10             	add    $0x10,%esp
80106cab:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106cae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106cb2:	75 0c                	jne    80106cc0 <sys_mkdir+0x47>
    end_op();
80106cb4:	e8 be c9 ff ff       	call   80103677 <end_op>
    return -1;
80106cb9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cbe:	eb 18                	jmp    80106cd8 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106cc0:	83 ec 0c             	sub    $0xc,%esp
80106cc3:	ff 75 f4             	pushl  -0xc(%ebp)
80106cc6:	e8 fd af ff ff       	call   80101cc8 <iunlockput>
80106ccb:	83 c4 10             	add    $0x10,%esp
  end_op();
80106cce:	e8 a4 c9 ff ff       	call   80103677 <end_op>
  return 0;
80106cd3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106cd8:	c9                   	leave  
80106cd9:	c3                   	ret    

80106cda <sys_mknod>:

int
sys_mknod(void)
{
80106cda:	55                   	push   %ebp
80106cdb:	89 e5                	mov    %esp,%ebp
80106cdd:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106ce0:	e8 06 c9 ff ff       	call   801035eb <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106ce5:	83 ec 08             	sub    $0x8,%esp
80106ce8:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106ceb:	50                   	push   %eax
80106cec:	6a 00                	push   $0x0
80106cee:	e8 e8 f4 ff ff       	call   801061db <argstr>
80106cf3:	83 c4 10             	add    $0x10,%esp
80106cf6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106cf9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106cfd:	78 4f                	js     80106d4e <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80106cff:	83 ec 08             	sub    $0x8,%esp
80106d02:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106d05:	50                   	push   %eax
80106d06:	6a 01                	push   $0x1
80106d08:	e8 49 f4 ff ff       	call   80106156 <argint>
80106d0d:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106d10:	85 c0                	test   %eax,%eax
80106d12:	78 3a                	js     80106d4e <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106d14:	83 ec 08             	sub    $0x8,%esp
80106d17:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106d1a:	50                   	push   %eax
80106d1b:	6a 02                	push   $0x2
80106d1d:	e8 34 f4 ff ff       	call   80106156 <argint>
80106d22:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106d25:	85 c0                	test   %eax,%eax
80106d27:	78 25                	js     80106d4e <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106d29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d2c:	0f bf c8             	movswl %ax,%ecx
80106d2f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106d32:	0f bf d0             	movswl %ax,%edx
80106d35:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106d38:	51                   	push   %ecx
80106d39:	52                   	push   %edx
80106d3a:	6a 03                	push   $0x3
80106d3c:	50                   	push   %eax
80106d3d:	e8 c8 fb ff ff       	call   8010690a <create>
80106d42:	83 c4 10             	add    $0x10,%esp
80106d45:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106d48:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106d4c:	75 0c                	jne    80106d5a <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106d4e:	e8 24 c9 ff ff       	call   80103677 <end_op>
    return -1;
80106d53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d58:	eb 18                	jmp    80106d72 <sys_mknod+0x98>
  }
  iunlockput(ip);
80106d5a:	83 ec 0c             	sub    $0xc,%esp
80106d5d:	ff 75 f0             	pushl  -0x10(%ebp)
80106d60:	e8 63 af ff ff       	call   80101cc8 <iunlockput>
80106d65:	83 c4 10             	add    $0x10,%esp
  end_op();
80106d68:	e8 0a c9 ff ff       	call   80103677 <end_op>
  return 0;
80106d6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106d72:	c9                   	leave  
80106d73:	c3                   	ret    

80106d74 <sys_chdir>:

int
sys_chdir(void)
{
80106d74:	55                   	push   %ebp
80106d75:	89 e5                	mov    %esp,%ebp
80106d77:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106d7a:	e8 6c c8 ff ff       	call   801035eb <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106d7f:	83 ec 08             	sub    $0x8,%esp
80106d82:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106d85:	50                   	push   %eax
80106d86:	6a 00                	push   $0x0
80106d88:	e8 4e f4 ff ff       	call   801061db <argstr>
80106d8d:	83 c4 10             	add    $0x10,%esp
80106d90:	85 c0                	test   %eax,%eax
80106d92:	78 18                	js     80106dac <sys_chdir+0x38>
80106d94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d97:	83 ec 0c             	sub    $0xc,%esp
80106d9a:	50                   	push   %eax
80106d9b:	e8 26 b8 ff ff       	call   801025c6 <namei>
80106da0:	83 c4 10             	add    $0x10,%esp
80106da3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106da6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106daa:	75 0c                	jne    80106db8 <sys_chdir+0x44>
    end_op();
80106dac:	e8 c6 c8 ff ff       	call   80103677 <end_op>
    return -1;
80106db1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106db6:	eb 6e                	jmp    80106e26 <sys_chdir+0xb2>
  }
  ilock(ip);
80106db8:	83 ec 0c             	sub    $0xc,%esp
80106dbb:	ff 75 f4             	pushl  -0xc(%ebp)
80106dbe:	e8 45 ac ff ff       	call   80101a08 <ilock>
80106dc3:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106dc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dc9:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106dcd:	66 83 f8 01          	cmp    $0x1,%ax
80106dd1:	74 1a                	je     80106ded <sys_chdir+0x79>
    iunlockput(ip);
80106dd3:	83 ec 0c             	sub    $0xc,%esp
80106dd6:	ff 75 f4             	pushl  -0xc(%ebp)
80106dd9:	e8 ea ae ff ff       	call   80101cc8 <iunlockput>
80106dde:	83 c4 10             	add    $0x10,%esp
    end_op();
80106de1:	e8 91 c8 ff ff       	call   80103677 <end_op>
    return -1;
80106de6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106deb:	eb 39                	jmp    80106e26 <sys_chdir+0xb2>
  }
  iunlock(ip);
80106ded:	83 ec 0c             	sub    $0xc,%esp
80106df0:	ff 75 f4             	pushl  -0xc(%ebp)
80106df3:	e8 6e ad ff ff       	call   80101b66 <iunlock>
80106df8:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80106dfb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e01:	8b 40 68             	mov    0x68(%eax),%eax
80106e04:	83 ec 0c             	sub    $0xc,%esp
80106e07:	50                   	push   %eax
80106e08:	e8 cb ad ff ff       	call   80101bd8 <iput>
80106e0d:	83 c4 10             	add    $0x10,%esp
  end_op();
80106e10:	e8 62 c8 ff ff       	call   80103677 <end_op>
  proc->cwd = ip;
80106e15:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106e1e:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106e21:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106e26:	c9                   	leave  
80106e27:	c3                   	ret    

80106e28 <sys_exec>:

int
sys_exec(void)
{
80106e28:	55                   	push   %ebp
80106e29:	89 e5                	mov    %esp,%ebp
80106e2b:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106e31:	83 ec 08             	sub    $0x8,%esp
80106e34:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106e37:	50                   	push   %eax
80106e38:	6a 00                	push   $0x0
80106e3a:	e8 9c f3 ff ff       	call   801061db <argstr>
80106e3f:	83 c4 10             	add    $0x10,%esp
80106e42:	85 c0                	test   %eax,%eax
80106e44:	78 18                	js     80106e5e <sys_exec+0x36>
80106e46:	83 ec 08             	sub    $0x8,%esp
80106e49:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106e4f:	50                   	push   %eax
80106e50:	6a 01                	push   $0x1
80106e52:	e8 ff f2 ff ff       	call   80106156 <argint>
80106e57:	83 c4 10             	add    $0x10,%esp
80106e5a:	85 c0                	test   %eax,%eax
80106e5c:	79 0a                	jns    80106e68 <sys_exec+0x40>
    return -1;
80106e5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e63:	e9 c6 00 00 00       	jmp    80106f2e <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106e68:	83 ec 04             	sub    $0x4,%esp
80106e6b:	68 80 00 00 00       	push   $0x80
80106e70:	6a 00                	push   $0x0
80106e72:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106e78:	50                   	push   %eax
80106e79:	e8 b3 ef ff ff       	call   80105e31 <memset>
80106e7e:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106e81:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106e88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e8b:	83 f8 1f             	cmp    $0x1f,%eax
80106e8e:	76 0a                	jbe    80106e9a <sys_exec+0x72>
      return -1;
80106e90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e95:	e9 94 00 00 00       	jmp    80106f2e <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106e9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e9d:	c1 e0 02             	shl    $0x2,%eax
80106ea0:	89 c2                	mov    %eax,%edx
80106ea2:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106ea8:	01 c2                	add    %eax,%edx
80106eaa:	83 ec 08             	sub    $0x8,%esp
80106ead:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106eb3:	50                   	push   %eax
80106eb4:	52                   	push   %edx
80106eb5:	e8 00 f2 ff ff       	call   801060ba <fetchint>
80106eba:	83 c4 10             	add    $0x10,%esp
80106ebd:	85 c0                	test   %eax,%eax
80106ebf:	79 07                	jns    80106ec8 <sys_exec+0xa0>
      return -1;
80106ec1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ec6:	eb 66                	jmp    80106f2e <sys_exec+0x106>
    if(uarg == 0){
80106ec8:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106ece:	85 c0                	test   %eax,%eax
80106ed0:	75 27                	jne    80106ef9 <sys_exec+0xd1>
      argv[i] = 0;
80106ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ed5:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106edc:	00 00 00 00 
      break;
80106ee0:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106ee1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ee4:	83 ec 08             	sub    $0x8,%esp
80106ee7:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106eed:	52                   	push   %edx
80106eee:	50                   	push   %eax
80106eef:	e8 1b 9d ff ff       	call   80100c0f <exec>
80106ef4:	83 c4 10             	add    $0x10,%esp
80106ef7:	eb 35                	jmp    80106f2e <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106ef9:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106eff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106f02:	c1 e2 02             	shl    $0x2,%edx
80106f05:	01 c2                	add    %eax,%edx
80106f07:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106f0d:	83 ec 08             	sub    $0x8,%esp
80106f10:	52                   	push   %edx
80106f11:	50                   	push   %eax
80106f12:	e8 dd f1 ff ff       	call   801060f4 <fetchstr>
80106f17:	83 c4 10             	add    $0x10,%esp
80106f1a:	85 c0                	test   %eax,%eax
80106f1c:	79 07                	jns    80106f25 <sys_exec+0xfd>
      return -1;
80106f1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f23:	eb 09                	jmp    80106f2e <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106f25:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106f29:	e9 5a ff ff ff       	jmp    80106e88 <sys_exec+0x60>
  return exec(path, argv);
}
80106f2e:	c9                   	leave  
80106f2f:	c3                   	ret    

80106f30 <sys_pipe>:

int
sys_pipe(void)
{
80106f30:	55                   	push   %ebp
80106f31:	89 e5                	mov    %esp,%ebp
80106f33:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106f36:	83 ec 04             	sub    $0x4,%esp
80106f39:	6a 08                	push   $0x8
80106f3b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106f3e:	50                   	push   %eax
80106f3f:	6a 00                	push   $0x0
80106f41:	e8 38 f2 ff ff       	call   8010617e <argptr>
80106f46:	83 c4 10             	add    $0x10,%esp
80106f49:	85 c0                	test   %eax,%eax
80106f4b:	79 0a                	jns    80106f57 <sys_pipe+0x27>
    return -1;
80106f4d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f52:	e9 af 00 00 00       	jmp    80107006 <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80106f57:	83 ec 08             	sub    $0x8,%esp
80106f5a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106f5d:	50                   	push   %eax
80106f5e:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106f61:	50                   	push   %eax
80106f62:	e8 78 d1 ff ff       	call   801040df <pipealloc>
80106f67:	83 c4 10             	add    $0x10,%esp
80106f6a:	85 c0                	test   %eax,%eax
80106f6c:	79 0a                	jns    80106f78 <sys_pipe+0x48>
    return -1;
80106f6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f73:	e9 8e 00 00 00       	jmp    80107006 <sys_pipe+0xd6>
  fd0 = -1;
80106f78:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106f7f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106f82:	83 ec 0c             	sub    $0xc,%esp
80106f85:	50                   	push   %eax
80106f86:	e8 7c f3 ff ff       	call   80106307 <fdalloc>
80106f8b:	83 c4 10             	add    $0x10,%esp
80106f8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106f91:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106f95:	78 18                	js     80106faf <sys_pipe+0x7f>
80106f97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106f9a:	83 ec 0c             	sub    $0xc,%esp
80106f9d:	50                   	push   %eax
80106f9e:	e8 64 f3 ff ff       	call   80106307 <fdalloc>
80106fa3:	83 c4 10             	add    $0x10,%esp
80106fa6:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106fa9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106fad:	79 3f                	jns    80106fee <sys_pipe+0xbe>
    if(fd0 >= 0)
80106faf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106fb3:	78 14                	js     80106fc9 <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80106fb5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fbb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106fbe:	83 c2 08             	add    $0x8,%edx
80106fc1:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106fc8:	00 
    fileclose(rf);
80106fc9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106fcc:	83 ec 0c             	sub    $0xc,%esp
80106fcf:	50                   	push   %eax
80106fd0:	e8 1a a1 ff ff       	call   801010ef <fileclose>
80106fd5:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106fd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106fdb:	83 ec 0c             	sub    $0xc,%esp
80106fde:	50                   	push   %eax
80106fdf:	e8 0b a1 ff ff       	call   801010ef <fileclose>
80106fe4:	83 c4 10             	add    $0x10,%esp
    return -1;
80106fe7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fec:	eb 18                	jmp    80107006 <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80106fee:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106ff1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106ff4:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106ff6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106ff9:	8d 50 04             	lea    0x4(%eax),%edx
80106ffc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106fff:	89 02                	mov    %eax,(%edx)
  return 0;
80107001:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107006:	c9                   	leave  
80107007:	c3                   	ret    

80107008 <outw>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outw(ushort port, ushort data)
{
80107008:	55                   	push   %ebp
80107009:	89 e5                	mov    %esp,%ebp
8010700b:	83 ec 08             	sub    $0x8,%esp
8010700e:	8b 55 08             	mov    0x8(%ebp),%edx
80107011:	8b 45 0c             	mov    0xc(%ebp),%eax
80107014:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107018:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010701c:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
80107020:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107024:	66 ef                	out    %ax,(%dx)
}
80107026:	90                   	nop
80107027:	c9                   	leave  
80107028:	c3                   	ret    

80107029 <sys_fork>:
#include "proc.h"
#include "uproc.h"

int
sys_fork(void)
{
80107029:	55                   	push   %ebp
8010702a:	89 e5                	mov    %esp,%ebp
8010702c:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010702f:	e8 ac d8 ff ff       	call   801048e0 <fork>
}
80107034:	c9                   	leave  
80107035:	c3                   	ret    

80107036 <sys_exit>:

int
sys_exit(void)
{
80107036:	55                   	push   %ebp
80107037:	89 e5                	mov    %esp,%ebp
80107039:	83 ec 08             	sub    $0x8,%esp
  exit();
8010703c:	e8 de da ff ff       	call   80104b1f <exit>
  return 0;  // not reached
80107041:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107046:	c9                   	leave  
80107047:	c3                   	ret    

80107048 <sys_wait>:

int
sys_wait(void)
{
80107048:	55                   	push   %ebp
80107049:	89 e5                	mov    %esp,%ebp
8010704b:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010704e:	e8 3f dc ff ff       	call   80104c92 <wait>
}
80107053:	c9                   	leave  
80107054:	c3                   	ret    

80107055 <sys_kill>:

int
sys_kill(void)
{
80107055:	55                   	push   %ebp
80107056:	89 e5                	mov    %esp,%ebp
80107058:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010705b:	83 ec 08             	sub    $0x8,%esp
8010705e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107061:	50                   	push   %eax
80107062:	6a 00                	push   $0x0
80107064:	e8 ed f0 ff ff       	call   80106156 <argint>
80107069:	83 c4 10             	add    $0x10,%esp
8010706c:	85 c0                	test   %eax,%eax
8010706e:	79 07                	jns    80107077 <sys_kill+0x22>
    return -1;
80107070:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107075:	eb 0f                	jmp    80107086 <sys_kill+0x31>
  return kill(pid);
80107077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010707a:	83 ec 0c             	sub    $0xc,%esp
8010707d:	50                   	push   %eax
8010707e:	e8 af e1 ff ff       	call   80105232 <kill>
80107083:	83 c4 10             	add    $0x10,%esp
}
80107086:	c9                   	leave  
80107087:	c3                   	ret    

80107088 <sys_getpid>:

int
sys_getpid(void)
{
80107088:	55                   	push   %ebp
80107089:	89 e5                	mov    %esp,%ebp
  return proc->pid;
8010708b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107091:	8b 40 10             	mov    0x10(%eax),%eax
}
80107094:	5d                   	pop    %ebp
80107095:	c3                   	ret    

80107096 <sys_sbrk>:

int
sys_sbrk(void)
{
80107096:	55                   	push   %ebp
80107097:	89 e5                	mov    %esp,%ebp
80107099:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010709c:	83 ec 08             	sub    $0x8,%esp
8010709f:	8d 45 f0             	lea    -0x10(%ebp),%eax
801070a2:	50                   	push   %eax
801070a3:	6a 00                	push   $0x0
801070a5:	e8 ac f0 ff ff       	call   80106156 <argint>
801070aa:	83 c4 10             	add    $0x10,%esp
801070ad:	85 c0                	test   %eax,%eax
801070af:	79 07                	jns    801070b8 <sys_sbrk+0x22>
    return -1;
801070b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070b6:	eb 28                	jmp    801070e0 <sys_sbrk+0x4a>
  addr = proc->sz;
801070b8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070be:	8b 00                	mov    (%eax),%eax
801070c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801070c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070c6:	83 ec 0c             	sub    $0xc,%esp
801070c9:	50                   	push   %eax
801070ca:	e8 6e d7 ff ff       	call   8010483d <growproc>
801070cf:	83 c4 10             	add    $0x10,%esp
801070d2:	85 c0                	test   %eax,%eax
801070d4:	79 07                	jns    801070dd <sys_sbrk+0x47>
    return -1;
801070d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070db:	eb 03                	jmp    801070e0 <sys_sbrk+0x4a>
  return addr;
801070dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801070e0:	c9                   	leave  
801070e1:	c3                   	ret    

801070e2 <sys_sleep>:

int
sys_sleep(void)
{
801070e2:	55                   	push   %ebp
801070e3:	89 e5                	mov    %esp,%ebp
801070e5:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801070e8:	83 ec 08             	sub    $0x8,%esp
801070eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801070ee:	50                   	push   %eax
801070ef:	6a 00                	push   $0x0
801070f1:	e8 60 f0 ff ff       	call   80106156 <argint>
801070f6:	83 c4 10             	add    $0x10,%esp
801070f9:	85 c0                	test   %eax,%eax
801070fb:	79 07                	jns    80107104 <sys_sleep+0x22>
    return -1;
801070fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107102:	eb 44                	jmp    80107148 <sys_sleep+0x66>
  ticks0 = ticks;
80107104:	a1 00 67 11 80       	mov    0x80116700,%eax
80107109:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010710c:	eb 26                	jmp    80107134 <sys_sleep+0x52>
    if(proc->killed){
8010710e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107114:	8b 40 24             	mov    0x24(%eax),%eax
80107117:	85 c0                	test   %eax,%eax
80107119:	74 07                	je     80107122 <sys_sleep+0x40>
      return -1;
8010711b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107120:	eb 26                	jmp    80107148 <sys_sleep+0x66>
    }
    sleep(&ticks, (struct spinlock *)0);
80107122:	83 ec 08             	sub    $0x8,%esp
80107125:	6a 00                	push   $0x0
80107127:	68 00 67 11 80       	push   $0x80116700
8010712c:	e8 7b df ff ff       	call   801050ac <sleep>
80107131:	83 c4 10             	add    $0x10,%esp
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80107134:	a1 00 67 11 80       	mov    0x80116700,%eax
80107139:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010713c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010713f:	39 d0                	cmp    %edx,%eax
80107141:	72 cb                	jb     8010710e <sys_sleep+0x2c>
    if(proc->killed){
      return -1;
    }
    sleep(&ticks, (struct spinlock *)0);
  }
  return 0;
80107143:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107148:	c9                   	leave  
80107149:	c3                   	ret    

8010714a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010714a:	55                   	push   %ebp
8010714b:	89 e5                	mov    %esp,%ebp
8010714d:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  xticks = ticks;
80107150:	a1 00 67 11 80       	mov    0x80116700,%eax
80107155:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return xticks;
80107158:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010715b:	c9                   	leave  
8010715c:	c3                   	ret    

8010715d <sys_halt>:

//Turn of the computer
int
sys_halt(void){
8010715d:	55                   	push   %ebp
8010715e:	89 e5                	mov    %esp,%ebp
80107160:	83 ec 08             	sub    $0x8,%esp
  cprintf("Shutting down ...\n");
80107163:	83 ec 0c             	sub    $0xc,%esp
80107166:	68 09 98 10 80       	push   $0x80109809
8010716b:	e8 56 92 ff ff       	call   801003c6 <cprintf>
80107170:	83 c4 10             	add    $0x10,%esp
  outw( 0x604, 0x0 | 0x2000);
80107173:	83 ec 08             	sub    $0x8,%esp
80107176:	68 00 20 00 00       	push   $0x2000
8010717b:	68 04 06 00 00       	push   $0x604
80107180:	e8 83 fe ff ff       	call   80107008 <outw>
80107185:	83 c4 10             	add    $0x10,%esp
  return 0;
80107188:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010718d:	c9                   	leave  
8010718e:	c3                   	ret    

8010718f <sys_date>:


int
sys_date(void)
{
8010718f:	55                   	push   %ebp
80107190:	89 e5                	mov    %esp,%ebp
80107192:	83 ec 18             	sub    $0x18,%esp
  struct rtcdate *d;
  if(argptr(0, (void*)&d, sizeof(struct rtcdate)) < 0)
80107195:	83 ec 04             	sub    $0x4,%esp
80107198:	6a 18                	push   $0x18
8010719a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010719d:	50                   	push   %eax
8010719e:	6a 00                	push   $0x0
801071a0:	e8 d9 ef ff ff       	call   8010617e <argptr>
801071a5:	83 c4 10             	add    $0x10,%esp
801071a8:	85 c0                	test   %eax,%eax
801071aa:	79 07                	jns    801071b3 <sys_date+0x24>
    return -1;
801071ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071b1:	eb 14                	jmp    801071c7 <sys_date+0x38>
  cmostime(d);
801071b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071b6:	83 ec 0c             	sub    $0xc,%esp
801071b9:	50                   	push   %eax
801071ba:	e8 a7 c0 ff ff       	call   80103266 <cmostime>
801071bf:	83 c4 10             	add    $0x10,%esp
  return 0;
801071c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801071c7:	c9                   	leave  
801071c8:	c3                   	ret    

801071c9 <sys_getuid>:

//Get gid
uint
sys_getuid(void)
{
801071c9:	55                   	push   %ebp
801071ca:	89 e5                	mov    %esp,%ebp
  return proc->uid;
801071cc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071d2:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
801071d8:	5d                   	pop    %ebp
801071d9:	c3                   	ret    

801071da <sys_getgid>:

//Get gid
uint
sys_getgid(void)
{
801071da:	55                   	push   %ebp
801071db:	89 e5                	mov    %esp,%ebp
  return proc->gid;
801071dd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071e3:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
}
801071e9:	5d                   	pop    %ebp
801071ea:	c3                   	ret    

801071eb <sys_getppid>:

//Returns init's pid, since it has no parent.
//Or returns the parents pid.
uint
sys_getppid(void)
{
801071eb:	55                   	push   %ebp
801071ec:	89 e5                	mov    %esp,%ebp
  if(proc->parent != 0)
801071ee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071f4:	8b 40 14             	mov    0x14(%eax),%eax
801071f7:	85 c0                	test   %eax,%eax
801071f9:	74 0e                	je     80107209 <sys_getppid+0x1e>
    return proc->parent->pid;
801071fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107201:	8b 40 14             	mov    0x14(%eax),%eax
80107204:	8b 40 10             	mov    0x10(%eax),%eax
80107207:	eb 09                	jmp    80107212 <sys_getppid+0x27>
  return proc->pid;
80107209:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010720f:	8b 40 10             	mov    0x10(%eax),%eax
}
80107212:	5d                   	pop    %ebp
80107213:	c3                   	ret    

80107214 <sys_setuid>:

//Sets the uid after making sure that the argument
//is within the bounds 0<=32767
int
sys_setuid(uint _uid)
{
80107214:	55                   	push   %ebp
80107215:	89 e5                	mov    %esp,%ebp
80107217:	83 ec 08             	sub    $0x8,%esp
  argint(0, (int*)&_uid);
8010721a:	83 ec 08             	sub    $0x8,%esp
8010721d:	8d 45 08             	lea    0x8(%ebp),%eax
80107220:	50                   	push   %eax
80107221:	6a 00                	push   $0x0
80107223:	e8 2e ef ff ff       	call   80106156 <argint>
80107228:	83 c4 10             	add    $0x10,%esp
  if (_uid>= 0 && _uid<= 32767)
8010722b:	8b 45 08             	mov    0x8(%ebp),%eax
8010722e:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
80107233:	77 16                	ja     8010724b <sys_setuid+0x37>
  {
    proc->uid = _uid;
80107235:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010723b:	8b 55 08             	mov    0x8(%ebp),%edx
8010723e:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
    return 0;
80107244:	b8 00 00 00 00       	mov    $0x0,%eax
80107249:	eb 05                	jmp    80107250 <sys_setuid+0x3c>
  }
  return -1;
8010724b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107250:	c9                   	leave  
80107251:	c3                   	ret    

80107252 <sys_setgid>:

//Sets the gid after making sure that the argument
//is within the bouds 0<=32767
int
sys_setgid(uint _uid)
{
80107252:	55                   	push   %ebp
80107253:	89 e5                	mov    %esp,%ebp
80107255:	83 ec 08             	sub    $0x8,%esp
  argint(0, (int*)&_uid);
80107258:	83 ec 08             	sub    $0x8,%esp
8010725b:	8d 45 08             	lea    0x8(%ebp),%eax
8010725e:	50                   	push   %eax
8010725f:	6a 00                	push   $0x0
80107261:	e8 f0 ee ff ff       	call   80106156 <argint>
80107266:	83 c4 10             	add    $0x10,%esp
  if (_uid>= 0 && _uid<= 32767)
80107269:	8b 45 08             	mov    0x8(%ebp),%eax
8010726c:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
80107271:	77 16                	ja     80107289 <sys_setgid+0x37>
  {
    proc->gid = _uid;
80107273:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107279:	8b 55 08             	mov    0x8(%ebp),%edx
8010727c:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
    return 0;
80107282:	b8 00 00 00 00       	mov    $0x0,%eax
80107287:	eb 05                	jmp    8010728e <sys_setgid+0x3c>
  }
  return -1;
80107289:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010728e:	c9                   	leave  
8010728f:	c3                   	ret    

80107290 <sys_getprocs>:

//Getprocs calls getprocs in proc.c in order to lock the ptable and
//grab all the processes off of that when ps is called.
int
sys_getprocs(int max, struct uproc* table)
{
80107290:	55                   	push   %ebp
80107291:	89 e5                	mov    %esp,%ebp
80107293:	83 ec 08             	sub    $0x8,%esp
  if(argint(0,&max)< 0 || argptr(1,(void*)&table,sizeof(*table)*max) <0)
80107296:	83 ec 08             	sub    $0x8,%esp
80107299:	8d 45 08             	lea    0x8(%ebp),%eax
8010729c:	50                   	push   %eax
8010729d:	6a 00                	push   $0x0
8010729f:	e8 b2 ee ff ff       	call   80106156 <argint>
801072a4:	83 c4 10             	add    $0x10,%esp
801072a7:	85 c0                	test   %eax,%eax
801072a9:	78 1c                	js     801072c7 <sys_getprocs+0x37>
801072ab:	8b 45 08             	mov    0x8(%ebp),%eax
801072ae:	6b c0 5c             	imul   $0x5c,%eax,%eax
801072b1:	83 ec 04             	sub    $0x4,%esp
801072b4:	50                   	push   %eax
801072b5:	8d 45 0c             	lea    0xc(%ebp),%eax
801072b8:	50                   	push   %eax
801072b9:	6a 01                	push   $0x1
801072bb:	e8 be ee ff ff       	call   8010617e <argptr>
801072c0:	83 c4 10             	add    $0x10,%esp
801072c3:	85 c0                	test   %eax,%eax
801072c5:	79 07                	jns    801072ce <sys_getprocs+0x3e>
    return -1;
801072c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072cc:	eb 13                	jmp    801072e1 <sys_getprocs+0x51>
  return getprocs(max,table);
801072ce:	8b 55 0c             	mov    0xc(%ebp),%edx
801072d1:	8b 45 08             	mov    0x8(%ebp),%eax
801072d4:	83 ec 08             	sub    $0x8,%esp
801072d7:	52                   	push   %edx
801072d8:	50                   	push   %eax
801072d9:	e8 c4 e4 ff ff       	call   801057a2 <getprocs>
801072de:	83 c4 10             	add    $0x10,%esp
}
801072e1:	c9                   	leave  
801072e2:	c3                   	ret    

801072e3 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801072e3:	55                   	push   %ebp
801072e4:	89 e5                	mov    %esp,%ebp
801072e6:	83 ec 08             	sub    $0x8,%esp
801072e9:	8b 55 08             	mov    0x8(%ebp),%edx
801072ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801072ef:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801072f3:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801072f6:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801072fa:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801072fe:	ee                   	out    %al,(%dx)
}
801072ff:	90                   	nop
80107300:	c9                   	leave  
80107301:	c3                   	ret    

80107302 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80107302:	55                   	push   %ebp
80107303:	89 e5                	mov    %esp,%ebp
80107305:	83 ec 08             	sub    $0x8,%esp
  // Interrupt TPS times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80107308:	6a 34                	push   $0x34
8010730a:	6a 43                	push   $0x43
8010730c:	e8 d2 ff ff ff       	call   801072e3 <outb>
80107311:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) % 256);
80107314:	68 a9 00 00 00       	push   $0xa9
80107319:	6a 40                	push   $0x40
8010731b:	e8 c3 ff ff ff       	call   801072e3 <outb>
80107320:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) / 256);
80107323:	6a 04                	push   $0x4
80107325:	6a 40                	push   $0x40
80107327:	e8 b7 ff ff ff       	call   801072e3 <outb>
8010732c:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
8010732f:	83 ec 0c             	sub    $0xc,%esp
80107332:	6a 00                	push   $0x0
80107334:	e8 90 cc ff ff       	call   80103fc9 <picenable>
80107339:	83 c4 10             	add    $0x10,%esp
}
8010733c:	90                   	nop
8010733d:	c9                   	leave  
8010733e:	c3                   	ret    

8010733f <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010733f:	1e                   	push   %ds
  pushl %es
80107340:	06                   	push   %es
  pushl %fs
80107341:	0f a0                	push   %fs
  pushl %gs
80107343:	0f a8                	push   %gs
  pushal
80107345:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80107346:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010734a:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010734c:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
8010734e:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80107352:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80107354:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80107356:	54                   	push   %esp
  call trap
80107357:	e8 ce 01 00 00       	call   8010752a <trap>
  addl $4, %esp
8010735c:	83 c4 04             	add    $0x4,%esp

8010735f <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010735f:	61                   	popa   
  popl %gs
80107360:	0f a9                	pop    %gs
  popl %fs
80107362:	0f a1                	pop    %fs
  popl %es
80107364:	07                   	pop    %es
  popl %ds
80107365:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80107366:	83 c4 08             	add    $0x8,%esp
  iret
80107369:	cf                   	iret   

8010736a <atom_inc>:

// Routines added for CS333
// atom_inc() added to simplify handling of ticks global
static inline void
atom_inc(volatile int *num)
{
8010736a:	55                   	push   %ebp
8010736b:	89 e5                	mov    %esp,%ebp
  asm volatile ( "lock incl %0" : "=m" (*num));
8010736d:	8b 45 08             	mov    0x8(%ebp),%eax
80107370:	f0 ff 00             	lock incl (%eax)
}
80107373:	90                   	nop
80107374:	5d                   	pop    %ebp
80107375:	c3                   	ret    

80107376 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80107376:	55                   	push   %ebp
80107377:	89 e5                	mov    %esp,%ebp
80107379:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010737c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010737f:	83 e8 01             	sub    $0x1,%eax
80107382:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107386:	8b 45 08             	mov    0x8(%ebp),%eax
80107389:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010738d:	8b 45 08             	mov    0x8(%ebp),%eax
80107390:	c1 e8 10             	shr    $0x10,%eax
80107393:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80107397:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010739a:	0f 01 18             	lidtl  (%eax)
}
8010739d:	90                   	nop
8010739e:	c9                   	leave  
8010739f:	c3                   	ret    

801073a0 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801073a0:	55                   	push   %ebp
801073a1:	89 e5                	mov    %esp,%ebp
801073a3:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801073a6:	0f 20 d0             	mov    %cr2,%eax
801073a9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801073ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801073af:	c9                   	leave  
801073b0:	c3                   	ret    

801073b1 <tvinit>:
// Software Developer’s Manual, Vol 3A, 8.1.1 Guaranteed Atomic Operations.
uint ticks __attribute__ ((aligned (4)));

void
tvinit(void)
{
801073b1:	55                   	push   %ebp
801073b2:	89 e5                	mov    %esp,%ebp
801073b4:	83 ec 10             	sub    $0x10,%esp
  int i;

  for(i = 0; i < 256; i++)
801073b7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801073be:	e9 c3 00 00 00       	jmp    80107486 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801073c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801073c6:	8b 04 85 b4 c0 10 80 	mov    -0x7fef3f4c(,%eax,4),%eax
801073cd:	89 c2                	mov    %eax,%edx
801073cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801073d2:	66 89 14 c5 00 5f 11 	mov    %dx,-0x7feea100(,%eax,8)
801073d9:	80 
801073da:	8b 45 fc             	mov    -0x4(%ebp),%eax
801073dd:	66 c7 04 c5 02 5f 11 	movw   $0x8,-0x7feea0fe(,%eax,8)
801073e4:	80 08 00 
801073e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801073ea:	0f b6 14 c5 04 5f 11 	movzbl -0x7feea0fc(,%eax,8),%edx
801073f1:	80 
801073f2:	83 e2 e0             	and    $0xffffffe0,%edx
801073f5:	88 14 c5 04 5f 11 80 	mov    %dl,-0x7feea0fc(,%eax,8)
801073fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801073ff:	0f b6 14 c5 04 5f 11 	movzbl -0x7feea0fc(,%eax,8),%edx
80107406:	80 
80107407:	83 e2 1f             	and    $0x1f,%edx
8010740a:	88 14 c5 04 5f 11 80 	mov    %dl,-0x7feea0fc(,%eax,8)
80107411:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107414:	0f b6 14 c5 05 5f 11 	movzbl -0x7feea0fb(,%eax,8),%edx
8010741b:	80 
8010741c:	83 e2 f0             	and    $0xfffffff0,%edx
8010741f:	83 ca 0e             	or     $0xe,%edx
80107422:	88 14 c5 05 5f 11 80 	mov    %dl,-0x7feea0fb(,%eax,8)
80107429:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010742c:	0f b6 14 c5 05 5f 11 	movzbl -0x7feea0fb(,%eax,8),%edx
80107433:	80 
80107434:	83 e2 ef             	and    $0xffffffef,%edx
80107437:	88 14 c5 05 5f 11 80 	mov    %dl,-0x7feea0fb(,%eax,8)
8010743e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107441:	0f b6 14 c5 05 5f 11 	movzbl -0x7feea0fb(,%eax,8),%edx
80107448:	80 
80107449:	83 e2 9f             	and    $0xffffff9f,%edx
8010744c:	88 14 c5 05 5f 11 80 	mov    %dl,-0x7feea0fb(,%eax,8)
80107453:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107456:	0f b6 14 c5 05 5f 11 	movzbl -0x7feea0fb(,%eax,8),%edx
8010745d:	80 
8010745e:	83 ca 80             	or     $0xffffff80,%edx
80107461:	88 14 c5 05 5f 11 80 	mov    %dl,-0x7feea0fb(,%eax,8)
80107468:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010746b:	8b 04 85 b4 c0 10 80 	mov    -0x7fef3f4c(,%eax,4),%eax
80107472:	c1 e8 10             	shr    $0x10,%eax
80107475:	89 c2                	mov    %eax,%edx
80107477:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010747a:	66 89 14 c5 06 5f 11 	mov    %dx,-0x7feea0fa(,%eax,8)
80107481:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80107482:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80107486:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
8010748d:	0f 8e 30 ff ff ff    	jle    801073c3 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80107493:	a1 b4 c1 10 80       	mov    0x8010c1b4,%eax
80107498:	66 a3 00 61 11 80    	mov    %ax,0x80116100
8010749e:	66 c7 05 02 61 11 80 	movw   $0x8,0x80116102
801074a5:	08 00 
801074a7:	0f b6 05 04 61 11 80 	movzbl 0x80116104,%eax
801074ae:	83 e0 e0             	and    $0xffffffe0,%eax
801074b1:	a2 04 61 11 80       	mov    %al,0x80116104
801074b6:	0f b6 05 04 61 11 80 	movzbl 0x80116104,%eax
801074bd:	83 e0 1f             	and    $0x1f,%eax
801074c0:	a2 04 61 11 80       	mov    %al,0x80116104
801074c5:	0f b6 05 05 61 11 80 	movzbl 0x80116105,%eax
801074cc:	83 c8 0f             	or     $0xf,%eax
801074cf:	a2 05 61 11 80       	mov    %al,0x80116105
801074d4:	0f b6 05 05 61 11 80 	movzbl 0x80116105,%eax
801074db:	83 e0 ef             	and    $0xffffffef,%eax
801074de:	a2 05 61 11 80       	mov    %al,0x80116105
801074e3:	0f b6 05 05 61 11 80 	movzbl 0x80116105,%eax
801074ea:	83 c8 60             	or     $0x60,%eax
801074ed:	a2 05 61 11 80       	mov    %al,0x80116105
801074f2:	0f b6 05 05 61 11 80 	movzbl 0x80116105,%eax
801074f9:	83 c8 80             	or     $0xffffff80,%eax
801074fc:	a2 05 61 11 80       	mov    %al,0x80116105
80107501:	a1 b4 c1 10 80       	mov    0x8010c1b4,%eax
80107506:	c1 e8 10             	shr    $0x10,%eax
80107509:	66 a3 06 61 11 80    	mov    %ax,0x80116106
  
}
8010750f:	90                   	nop
80107510:	c9                   	leave  
80107511:	c3                   	ret    

80107512 <idtinit>:

void
idtinit(void)
{
80107512:	55                   	push   %ebp
80107513:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80107515:	68 00 08 00 00       	push   $0x800
8010751a:	68 00 5f 11 80       	push   $0x80115f00
8010751f:	e8 52 fe ff ff       	call   80107376 <lidt>
80107524:	83 c4 08             	add    $0x8,%esp
}
80107527:	90                   	nop
80107528:	c9                   	leave  
80107529:	c3                   	ret    

8010752a <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010752a:	55                   	push   %ebp
8010752b:	89 e5                	mov    %esp,%ebp
8010752d:	57                   	push   %edi
8010752e:	56                   	push   %esi
8010752f:	53                   	push   %ebx
80107530:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80107533:	8b 45 08             	mov    0x8(%ebp),%eax
80107536:	8b 40 30             	mov    0x30(%eax),%eax
80107539:	83 f8 40             	cmp    $0x40,%eax
8010753c:	75 3e                	jne    8010757c <trap+0x52>
    if(proc->killed)
8010753e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107544:	8b 40 24             	mov    0x24(%eax),%eax
80107547:	85 c0                	test   %eax,%eax
80107549:	74 05                	je     80107550 <trap+0x26>
      exit();
8010754b:	e8 cf d5 ff ff       	call   80104b1f <exit>
    proc->tf = tf;
80107550:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107556:	8b 55 08             	mov    0x8(%ebp),%edx
80107559:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010755c:	e8 ab ec ff ff       	call   8010620c <syscall>
    if(proc->killed)
80107561:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107567:	8b 40 24             	mov    0x24(%eax),%eax
8010756a:	85 c0                	test   %eax,%eax
8010756c:	0f 84 21 02 00 00    	je     80107793 <trap+0x269>
      exit();
80107572:	e8 a8 d5 ff ff       	call   80104b1f <exit>
    return;
80107577:	e9 17 02 00 00       	jmp    80107793 <trap+0x269>
  }

  switch(tf->trapno){
8010757c:	8b 45 08             	mov    0x8(%ebp),%eax
8010757f:	8b 40 30             	mov    0x30(%eax),%eax
80107582:	83 e8 20             	sub    $0x20,%eax
80107585:	83 f8 1f             	cmp    $0x1f,%eax
80107588:	0f 87 a3 00 00 00    	ja     80107631 <trap+0x107>
8010758e:	8b 04 85 bc 98 10 80 	mov    -0x7fef6744(,%eax,4),%eax
80107595:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
   if(cpu->id == 0){
80107597:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010759d:	0f b6 00             	movzbl (%eax),%eax
801075a0:	84 c0                	test   %al,%al
801075a2:	75 20                	jne    801075c4 <trap+0x9a>
      atom_inc((int *)&ticks);   // guaranteed atomic so no lock necessary
801075a4:	83 ec 0c             	sub    $0xc,%esp
801075a7:	68 00 67 11 80       	push   $0x80116700
801075ac:	e8 b9 fd ff ff       	call   8010736a <atom_inc>
801075b1:	83 c4 10             	add    $0x10,%esp
      wakeup(&ticks);
801075b4:	83 ec 0c             	sub    $0xc,%esp
801075b7:	68 00 67 11 80       	push   $0x80116700
801075bc:	e8 3a dc ff ff       	call   801051fb <wakeup>
801075c1:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801075c4:	e8 fa ba ff ff       	call   801030c3 <lapiceoi>
    break;
801075c9:	e9 1c 01 00 00       	jmp    801076ea <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801075ce:	e8 03 b3 ff ff       	call   801028d6 <ideintr>
    lapiceoi();
801075d3:	e8 eb ba ff ff       	call   801030c3 <lapiceoi>
    break;
801075d8:	e9 0d 01 00 00       	jmp    801076ea <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801075dd:	e8 e3 b8 ff ff       	call   80102ec5 <kbdintr>
    lapiceoi();
801075e2:	e8 dc ba ff ff       	call   801030c3 <lapiceoi>
    break;
801075e7:	e9 fe 00 00 00       	jmp    801076ea <trap+0x1c0>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801075ec:	e8 83 03 00 00       	call   80107974 <uartintr>
    lapiceoi();
801075f1:	e8 cd ba ff ff       	call   801030c3 <lapiceoi>
    break;
801075f6:	e9 ef 00 00 00       	jmp    801076ea <trap+0x1c0>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801075fb:	8b 45 08             	mov    0x8(%ebp),%eax
801075fe:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80107601:	8b 45 08             	mov    0x8(%ebp),%eax
80107604:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107608:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
8010760b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107611:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107614:	0f b6 c0             	movzbl %al,%eax
80107617:	51                   	push   %ecx
80107618:	52                   	push   %edx
80107619:	50                   	push   %eax
8010761a:	68 1c 98 10 80       	push   $0x8010981c
8010761f:	e8 a2 8d ff ff       	call   801003c6 <cprintf>
80107624:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80107627:	e8 97 ba ff ff       	call   801030c3 <lapiceoi>
    break;
8010762c:	e9 b9 00 00 00       	jmp    801076ea <trap+0x1c0>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80107631:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107637:	85 c0                	test   %eax,%eax
80107639:	74 11                	je     8010764c <trap+0x122>
8010763b:	8b 45 08             	mov    0x8(%ebp),%eax
8010763e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107642:	0f b7 c0             	movzwl %ax,%eax
80107645:	83 e0 03             	and    $0x3,%eax
80107648:	85 c0                	test   %eax,%eax
8010764a:	75 40                	jne    8010768c <trap+0x162>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010764c:	e8 4f fd ff ff       	call   801073a0 <rcr2>
80107651:	89 c3                	mov    %eax,%ebx
80107653:	8b 45 08             	mov    0x8(%ebp),%eax
80107656:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80107659:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010765f:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107662:	0f b6 d0             	movzbl %al,%edx
80107665:	8b 45 08             	mov    0x8(%ebp),%eax
80107668:	8b 40 30             	mov    0x30(%eax),%eax
8010766b:	83 ec 0c             	sub    $0xc,%esp
8010766e:	53                   	push   %ebx
8010766f:	51                   	push   %ecx
80107670:	52                   	push   %edx
80107671:	50                   	push   %eax
80107672:	68 40 98 10 80       	push   $0x80109840
80107677:	e8 4a 8d ff ff       	call   801003c6 <cprintf>
8010767c:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
8010767f:	83 ec 0c             	sub    $0xc,%esp
80107682:	68 72 98 10 80       	push   $0x80109872
80107687:	e8 da 8e ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010768c:	e8 0f fd ff ff       	call   801073a0 <rcr2>
80107691:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107694:	8b 45 08             	mov    0x8(%ebp),%eax
80107697:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010769a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801076a0:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801076a3:	0f b6 d8             	movzbl %al,%ebx
801076a6:	8b 45 08             	mov    0x8(%ebp),%eax
801076a9:	8b 48 34             	mov    0x34(%eax),%ecx
801076ac:	8b 45 08             	mov    0x8(%ebp),%eax
801076af:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801076b2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801076b8:	8d 78 6c             	lea    0x6c(%eax),%edi
801076bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801076c1:	8b 40 10             	mov    0x10(%eax),%eax
801076c4:	ff 75 e4             	pushl  -0x1c(%ebp)
801076c7:	56                   	push   %esi
801076c8:	53                   	push   %ebx
801076c9:	51                   	push   %ecx
801076ca:	52                   	push   %edx
801076cb:	57                   	push   %edi
801076cc:	50                   	push   %eax
801076cd:	68 78 98 10 80       	push   $0x80109878
801076d2:	e8 ef 8c ff ff       	call   801003c6 <cprintf>
801076d7:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
801076da:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801076e0:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801076e7:	eb 01                	jmp    801076ea <trap+0x1c0>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801076e9:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801076ea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801076f0:	85 c0                	test   %eax,%eax
801076f2:	74 24                	je     80107718 <trap+0x1ee>
801076f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801076fa:	8b 40 24             	mov    0x24(%eax),%eax
801076fd:	85 c0                	test   %eax,%eax
801076ff:	74 17                	je     80107718 <trap+0x1ee>
80107701:	8b 45 08             	mov    0x8(%ebp),%eax
80107704:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107708:	0f b7 c0             	movzwl %ax,%eax
8010770b:	83 e0 03             	and    $0x3,%eax
8010770e:	83 f8 03             	cmp    $0x3,%eax
80107711:	75 05                	jne    80107718 <trap+0x1ee>
    exit();
80107713:	e8 07 d4 ff ff       	call   80104b1f <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
80107718:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010771e:	85 c0                	test   %eax,%eax
80107720:	74 41                	je     80107763 <trap+0x239>
80107722:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107728:	8b 40 0c             	mov    0xc(%eax),%eax
8010772b:	83 f8 04             	cmp    $0x4,%eax
8010772e:	75 33                	jne    80107763 <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
80107730:	8b 45 08             	mov    0x8(%ebp),%eax
80107733:	8b 40 30             	mov    0x30(%eax),%eax
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
80107736:	83 f8 20             	cmp    $0x20,%eax
80107739:	75 28                	jne    80107763 <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
8010773b:	8b 0d 00 67 11 80    	mov    0x80116700,%ecx
80107741:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
80107746:	89 c8                	mov    %ecx,%eax
80107748:	f7 e2                	mul    %edx
8010774a:	c1 ea 03             	shr    $0x3,%edx
8010774d:	89 d0                	mov    %edx,%eax
8010774f:	c1 e0 02             	shl    $0x2,%eax
80107752:	01 d0                	add    %edx,%eax
80107754:	01 c0                	add    %eax,%eax
80107756:	29 c1                	sub    %eax,%ecx
80107758:	89 ca                	mov    %ecx,%edx
8010775a:	85 d2                	test   %edx,%edx
8010775c:	75 05                	jne    80107763 <trap+0x239>
    yield();
8010775e:	e8 90 d8 ff ff       	call   80104ff3 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107763:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107769:	85 c0                	test   %eax,%eax
8010776b:	74 27                	je     80107794 <trap+0x26a>
8010776d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107773:	8b 40 24             	mov    0x24(%eax),%eax
80107776:	85 c0                	test   %eax,%eax
80107778:	74 1a                	je     80107794 <trap+0x26a>
8010777a:	8b 45 08             	mov    0x8(%ebp),%eax
8010777d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107781:	0f b7 c0             	movzwl %ax,%eax
80107784:	83 e0 03             	and    $0x3,%eax
80107787:	83 f8 03             	cmp    $0x3,%eax
8010778a:	75 08                	jne    80107794 <trap+0x26a>
    exit();
8010778c:	e8 8e d3 ff ff       	call   80104b1f <exit>
80107791:	eb 01                	jmp    80107794 <trap+0x26a>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80107793:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80107794:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107797:	5b                   	pop    %ebx
80107798:	5e                   	pop    %esi
80107799:	5f                   	pop    %edi
8010779a:	5d                   	pop    %ebp
8010779b:	c3                   	ret    

8010779c <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
8010779c:	55                   	push   %ebp
8010779d:	89 e5                	mov    %esp,%ebp
8010779f:	83 ec 14             	sub    $0x14,%esp
801077a2:	8b 45 08             	mov    0x8(%ebp),%eax
801077a5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801077a9:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801077ad:	89 c2                	mov    %eax,%edx
801077af:	ec                   	in     (%dx),%al
801077b0:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801077b3:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801077b7:	c9                   	leave  
801077b8:	c3                   	ret    

801077b9 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801077b9:	55                   	push   %ebp
801077ba:	89 e5                	mov    %esp,%ebp
801077bc:	83 ec 08             	sub    $0x8,%esp
801077bf:	8b 55 08             	mov    0x8(%ebp),%edx
801077c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801077c5:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801077c9:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801077cc:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801077d0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801077d4:	ee                   	out    %al,(%dx)
}
801077d5:	90                   	nop
801077d6:	c9                   	leave  
801077d7:	c3                   	ret    

801077d8 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801077d8:	55                   	push   %ebp
801077d9:	89 e5                	mov    %esp,%ebp
801077db:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801077de:	6a 00                	push   $0x0
801077e0:	68 fa 03 00 00       	push   $0x3fa
801077e5:	e8 cf ff ff ff       	call   801077b9 <outb>
801077ea:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801077ed:	68 80 00 00 00       	push   $0x80
801077f2:	68 fb 03 00 00       	push   $0x3fb
801077f7:	e8 bd ff ff ff       	call   801077b9 <outb>
801077fc:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801077ff:	6a 0c                	push   $0xc
80107801:	68 f8 03 00 00       	push   $0x3f8
80107806:	e8 ae ff ff ff       	call   801077b9 <outb>
8010780b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
8010780e:	6a 00                	push   $0x0
80107810:	68 f9 03 00 00       	push   $0x3f9
80107815:	e8 9f ff ff ff       	call   801077b9 <outb>
8010781a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010781d:	6a 03                	push   $0x3
8010781f:	68 fb 03 00 00       	push   $0x3fb
80107824:	e8 90 ff ff ff       	call   801077b9 <outb>
80107829:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010782c:	6a 00                	push   $0x0
8010782e:	68 fc 03 00 00       	push   $0x3fc
80107833:	e8 81 ff ff ff       	call   801077b9 <outb>
80107838:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010783b:	6a 01                	push   $0x1
8010783d:	68 f9 03 00 00       	push   $0x3f9
80107842:	e8 72 ff ff ff       	call   801077b9 <outb>
80107847:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
8010784a:	68 fd 03 00 00       	push   $0x3fd
8010784f:	e8 48 ff ff ff       	call   8010779c <inb>
80107854:	83 c4 04             	add    $0x4,%esp
80107857:	3c ff                	cmp    $0xff,%al
80107859:	74 6e                	je     801078c9 <uartinit+0xf1>
    return;
  uart = 1;
8010785b:	c7 05 6c c6 10 80 01 	movl   $0x1,0x8010c66c
80107862:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107865:	68 fa 03 00 00       	push   $0x3fa
8010786a:	e8 2d ff ff ff       	call   8010779c <inb>
8010786f:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80107872:	68 f8 03 00 00       	push   $0x3f8
80107877:	e8 20 ff ff ff       	call   8010779c <inb>
8010787c:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
8010787f:	83 ec 0c             	sub    $0xc,%esp
80107882:	6a 04                	push   $0x4
80107884:	e8 40 c7 ff ff       	call   80103fc9 <picenable>
80107889:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
8010788c:	83 ec 08             	sub    $0x8,%esp
8010788f:	6a 00                	push   $0x0
80107891:	6a 04                	push   $0x4
80107893:	e8 e0 b2 ff ff       	call   80102b78 <ioapicenable>
80107898:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010789b:	c7 45 f4 3c 99 10 80 	movl   $0x8010993c,-0xc(%ebp)
801078a2:	eb 19                	jmp    801078bd <uartinit+0xe5>
    uartputc(*p);
801078a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a7:	0f b6 00             	movzbl (%eax),%eax
801078aa:	0f be c0             	movsbl %al,%eax
801078ad:	83 ec 0c             	sub    $0xc,%esp
801078b0:	50                   	push   %eax
801078b1:	e8 16 00 00 00       	call   801078cc <uartputc>
801078b6:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801078b9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801078bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c0:	0f b6 00             	movzbl (%eax),%eax
801078c3:	84 c0                	test   %al,%al
801078c5:	75 dd                	jne    801078a4 <uartinit+0xcc>
801078c7:	eb 01                	jmp    801078ca <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
801078c9:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
801078ca:	c9                   	leave  
801078cb:	c3                   	ret    

801078cc <uartputc>:

void
uartputc(int c)
{
801078cc:	55                   	push   %ebp
801078cd:	89 e5                	mov    %esp,%ebp
801078cf:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801078d2:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
801078d7:	85 c0                	test   %eax,%eax
801078d9:	74 53                	je     8010792e <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801078db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801078e2:	eb 11                	jmp    801078f5 <uartputc+0x29>
    microdelay(10);
801078e4:	83 ec 0c             	sub    $0xc,%esp
801078e7:	6a 0a                	push   $0xa
801078e9:	e8 f0 b7 ff ff       	call   801030de <microdelay>
801078ee:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801078f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801078f5:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801078f9:	7f 1a                	jg     80107915 <uartputc+0x49>
801078fb:	83 ec 0c             	sub    $0xc,%esp
801078fe:	68 fd 03 00 00       	push   $0x3fd
80107903:	e8 94 fe ff ff       	call   8010779c <inb>
80107908:	83 c4 10             	add    $0x10,%esp
8010790b:	0f b6 c0             	movzbl %al,%eax
8010790e:	83 e0 20             	and    $0x20,%eax
80107911:	85 c0                	test   %eax,%eax
80107913:	74 cf                	je     801078e4 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80107915:	8b 45 08             	mov    0x8(%ebp),%eax
80107918:	0f b6 c0             	movzbl %al,%eax
8010791b:	83 ec 08             	sub    $0x8,%esp
8010791e:	50                   	push   %eax
8010791f:	68 f8 03 00 00       	push   $0x3f8
80107924:	e8 90 fe ff ff       	call   801077b9 <outb>
80107929:	83 c4 10             	add    $0x10,%esp
8010792c:	eb 01                	jmp    8010792f <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
8010792e:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
8010792f:	c9                   	leave  
80107930:	c3                   	ret    

80107931 <uartgetc>:

static int
uartgetc(void)
{
80107931:	55                   	push   %ebp
80107932:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107934:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
80107939:	85 c0                	test   %eax,%eax
8010793b:	75 07                	jne    80107944 <uartgetc+0x13>
    return -1;
8010793d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107942:	eb 2e                	jmp    80107972 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80107944:	68 fd 03 00 00       	push   $0x3fd
80107949:	e8 4e fe ff ff       	call   8010779c <inb>
8010794e:	83 c4 04             	add    $0x4,%esp
80107951:	0f b6 c0             	movzbl %al,%eax
80107954:	83 e0 01             	and    $0x1,%eax
80107957:	85 c0                	test   %eax,%eax
80107959:	75 07                	jne    80107962 <uartgetc+0x31>
    return -1;
8010795b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107960:	eb 10                	jmp    80107972 <uartgetc+0x41>
  return inb(COM1+0);
80107962:	68 f8 03 00 00       	push   $0x3f8
80107967:	e8 30 fe ff ff       	call   8010779c <inb>
8010796c:	83 c4 04             	add    $0x4,%esp
8010796f:	0f b6 c0             	movzbl %al,%eax
}
80107972:	c9                   	leave  
80107973:	c3                   	ret    

80107974 <uartintr>:

void
uartintr(void)
{
80107974:	55                   	push   %ebp
80107975:	89 e5                	mov    %esp,%ebp
80107977:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
8010797a:	83 ec 0c             	sub    $0xc,%esp
8010797d:	68 31 79 10 80       	push   $0x80107931
80107982:	e8 72 8e ff ff       	call   801007f9 <consoleintr>
80107987:	83 c4 10             	add    $0x10,%esp
}
8010798a:	90                   	nop
8010798b:	c9                   	leave  
8010798c:	c3                   	ret    

8010798d <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010798d:	6a 00                	push   $0x0
  pushl $0
8010798f:	6a 00                	push   $0x0
  jmp alltraps
80107991:	e9 a9 f9 ff ff       	jmp    8010733f <alltraps>

80107996 <vector1>:
.globl vector1
vector1:
  pushl $0
80107996:	6a 00                	push   $0x0
  pushl $1
80107998:	6a 01                	push   $0x1
  jmp alltraps
8010799a:	e9 a0 f9 ff ff       	jmp    8010733f <alltraps>

8010799f <vector2>:
.globl vector2
vector2:
  pushl $0
8010799f:	6a 00                	push   $0x0
  pushl $2
801079a1:	6a 02                	push   $0x2
  jmp alltraps
801079a3:	e9 97 f9 ff ff       	jmp    8010733f <alltraps>

801079a8 <vector3>:
.globl vector3
vector3:
  pushl $0
801079a8:	6a 00                	push   $0x0
  pushl $3
801079aa:	6a 03                	push   $0x3
  jmp alltraps
801079ac:	e9 8e f9 ff ff       	jmp    8010733f <alltraps>

801079b1 <vector4>:
.globl vector4
vector4:
  pushl $0
801079b1:	6a 00                	push   $0x0
  pushl $4
801079b3:	6a 04                	push   $0x4
  jmp alltraps
801079b5:	e9 85 f9 ff ff       	jmp    8010733f <alltraps>

801079ba <vector5>:
.globl vector5
vector5:
  pushl $0
801079ba:	6a 00                	push   $0x0
  pushl $5
801079bc:	6a 05                	push   $0x5
  jmp alltraps
801079be:	e9 7c f9 ff ff       	jmp    8010733f <alltraps>

801079c3 <vector6>:
.globl vector6
vector6:
  pushl $0
801079c3:	6a 00                	push   $0x0
  pushl $6
801079c5:	6a 06                	push   $0x6
  jmp alltraps
801079c7:	e9 73 f9 ff ff       	jmp    8010733f <alltraps>

801079cc <vector7>:
.globl vector7
vector7:
  pushl $0
801079cc:	6a 00                	push   $0x0
  pushl $7
801079ce:	6a 07                	push   $0x7
  jmp alltraps
801079d0:	e9 6a f9 ff ff       	jmp    8010733f <alltraps>

801079d5 <vector8>:
.globl vector8
vector8:
  pushl $8
801079d5:	6a 08                	push   $0x8
  jmp alltraps
801079d7:	e9 63 f9 ff ff       	jmp    8010733f <alltraps>

801079dc <vector9>:
.globl vector9
vector9:
  pushl $0
801079dc:	6a 00                	push   $0x0
  pushl $9
801079de:	6a 09                	push   $0x9
  jmp alltraps
801079e0:	e9 5a f9 ff ff       	jmp    8010733f <alltraps>

801079e5 <vector10>:
.globl vector10
vector10:
  pushl $10
801079e5:	6a 0a                	push   $0xa
  jmp alltraps
801079e7:	e9 53 f9 ff ff       	jmp    8010733f <alltraps>

801079ec <vector11>:
.globl vector11
vector11:
  pushl $11
801079ec:	6a 0b                	push   $0xb
  jmp alltraps
801079ee:	e9 4c f9 ff ff       	jmp    8010733f <alltraps>

801079f3 <vector12>:
.globl vector12
vector12:
  pushl $12
801079f3:	6a 0c                	push   $0xc
  jmp alltraps
801079f5:	e9 45 f9 ff ff       	jmp    8010733f <alltraps>

801079fa <vector13>:
.globl vector13
vector13:
  pushl $13
801079fa:	6a 0d                	push   $0xd
  jmp alltraps
801079fc:	e9 3e f9 ff ff       	jmp    8010733f <alltraps>

80107a01 <vector14>:
.globl vector14
vector14:
  pushl $14
80107a01:	6a 0e                	push   $0xe
  jmp alltraps
80107a03:	e9 37 f9 ff ff       	jmp    8010733f <alltraps>

80107a08 <vector15>:
.globl vector15
vector15:
  pushl $0
80107a08:	6a 00                	push   $0x0
  pushl $15
80107a0a:	6a 0f                	push   $0xf
  jmp alltraps
80107a0c:	e9 2e f9 ff ff       	jmp    8010733f <alltraps>

80107a11 <vector16>:
.globl vector16
vector16:
  pushl $0
80107a11:	6a 00                	push   $0x0
  pushl $16
80107a13:	6a 10                	push   $0x10
  jmp alltraps
80107a15:	e9 25 f9 ff ff       	jmp    8010733f <alltraps>

80107a1a <vector17>:
.globl vector17
vector17:
  pushl $17
80107a1a:	6a 11                	push   $0x11
  jmp alltraps
80107a1c:	e9 1e f9 ff ff       	jmp    8010733f <alltraps>

80107a21 <vector18>:
.globl vector18
vector18:
  pushl $0
80107a21:	6a 00                	push   $0x0
  pushl $18
80107a23:	6a 12                	push   $0x12
  jmp alltraps
80107a25:	e9 15 f9 ff ff       	jmp    8010733f <alltraps>

80107a2a <vector19>:
.globl vector19
vector19:
  pushl $0
80107a2a:	6a 00                	push   $0x0
  pushl $19
80107a2c:	6a 13                	push   $0x13
  jmp alltraps
80107a2e:	e9 0c f9 ff ff       	jmp    8010733f <alltraps>

80107a33 <vector20>:
.globl vector20
vector20:
  pushl $0
80107a33:	6a 00                	push   $0x0
  pushl $20
80107a35:	6a 14                	push   $0x14
  jmp alltraps
80107a37:	e9 03 f9 ff ff       	jmp    8010733f <alltraps>

80107a3c <vector21>:
.globl vector21
vector21:
  pushl $0
80107a3c:	6a 00                	push   $0x0
  pushl $21
80107a3e:	6a 15                	push   $0x15
  jmp alltraps
80107a40:	e9 fa f8 ff ff       	jmp    8010733f <alltraps>

80107a45 <vector22>:
.globl vector22
vector22:
  pushl $0
80107a45:	6a 00                	push   $0x0
  pushl $22
80107a47:	6a 16                	push   $0x16
  jmp alltraps
80107a49:	e9 f1 f8 ff ff       	jmp    8010733f <alltraps>

80107a4e <vector23>:
.globl vector23
vector23:
  pushl $0
80107a4e:	6a 00                	push   $0x0
  pushl $23
80107a50:	6a 17                	push   $0x17
  jmp alltraps
80107a52:	e9 e8 f8 ff ff       	jmp    8010733f <alltraps>

80107a57 <vector24>:
.globl vector24
vector24:
  pushl $0
80107a57:	6a 00                	push   $0x0
  pushl $24
80107a59:	6a 18                	push   $0x18
  jmp alltraps
80107a5b:	e9 df f8 ff ff       	jmp    8010733f <alltraps>

80107a60 <vector25>:
.globl vector25
vector25:
  pushl $0
80107a60:	6a 00                	push   $0x0
  pushl $25
80107a62:	6a 19                	push   $0x19
  jmp alltraps
80107a64:	e9 d6 f8 ff ff       	jmp    8010733f <alltraps>

80107a69 <vector26>:
.globl vector26
vector26:
  pushl $0
80107a69:	6a 00                	push   $0x0
  pushl $26
80107a6b:	6a 1a                	push   $0x1a
  jmp alltraps
80107a6d:	e9 cd f8 ff ff       	jmp    8010733f <alltraps>

80107a72 <vector27>:
.globl vector27
vector27:
  pushl $0
80107a72:	6a 00                	push   $0x0
  pushl $27
80107a74:	6a 1b                	push   $0x1b
  jmp alltraps
80107a76:	e9 c4 f8 ff ff       	jmp    8010733f <alltraps>

80107a7b <vector28>:
.globl vector28
vector28:
  pushl $0
80107a7b:	6a 00                	push   $0x0
  pushl $28
80107a7d:	6a 1c                	push   $0x1c
  jmp alltraps
80107a7f:	e9 bb f8 ff ff       	jmp    8010733f <alltraps>

80107a84 <vector29>:
.globl vector29
vector29:
  pushl $0
80107a84:	6a 00                	push   $0x0
  pushl $29
80107a86:	6a 1d                	push   $0x1d
  jmp alltraps
80107a88:	e9 b2 f8 ff ff       	jmp    8010733f <alltraps>

80107a8d <vector30>:
.globl vector30
vector30:
  pushl $0
80107a8d:	6a 00                	push   $0x0
  pushl $30
80107a8f:	6a 1e                	push   $0x1e
  jmp alltraps
80107a91:	e9 a9 f8 ff ff       	jmp    8010733f <alltraps>

80107a96 <vector31>:
.globl vector31
vector31:
  pushl $0
80107a96:	6a 00                	push   $0x0
  pushl $31
80107a98:	6a 1f                	push   $0x1f
  jmp alltraps
80107a9a:	e9 a0 f8 ff ff       	jmp    8010733f <alltraps>

80107a9f <vector32>:
.globl vector32
vector32:
  pushl $0
80107a9f:	6a 00                	push   $0x0
  pushl $32
80107aa1:	6a 20                	push   $0x20
  jmp alltraps
80107aa3:	e9 97 f8 ff ff       	jmp    8010733f <alltraps>

80107aa8 <vector33>:
.globl vector33
vector33:
  pushl $0
80107aa8:	6a 00                	push   $0x0
  pushl $33
80107aaa:	6a 21                	push   $0x21
  jmp alltraps
80107aac:	e9 8e f8 ff ff       	jmp    8010733f <alltraps>

80107ab1 <vector34>:
.globl vector34
vector34:
  pushl $0
80107ab1:	6a 00                	push   $0x0
  pushl $34
80107ab3:	6a 22                	push   $0x22
  jmp alltraps
80107ab5:	e9 85 f8 ff ff       	jmp    8010733f <alltraps>

80107aba <vector35>:
.globl vector35
vector35:
  pushl $0
80107aba:	6a 00                	push   $0x0
  pushl $35
80107abc:	6a 23                	push   $0x23
  jmp alltraps
80107abe:	e9 7c f8 ff ff       	jmp    8010733f <alltraps>

80107ac3 <vector36>:
.globl vector36
vector36:
  pushl $0
80107ac3:	6a 00                	push   $0x0
  pushl $36
80107ac5:	6a 24                	push   $0x24
  jmp alltraps
80107ac7:	e9 73 f8 ff ff       	jmp    8010733f <alltraps>

80107acc <vector37>:
.globl vector37
vector37:
  pushl $0
80107acc:	6a 00                	push   $0x0
  pushl $37
80107ace:	6a 25                	push   $0x25
  jmp alltraps
80107ad0:	e9 6a f8 ff ff       	jmp    8010733f <alltraps>

80107ad5 <vector38>:
.globl vector38
vector38:
  pushl $0
80107ad5:	6a 00                	push   $0x0
  pushl $38
80107ad7:	6a 26                	push   $0x26
  jmp alltraps
80107ad9:	e9 61 f8 ff ff       	jmp    8010733f <alltraps>

80107ade <vector39>:
.globl vector39
vector39:
  pushl $0
80107ade:	6a 00                	push   $0x0
  pushl $39
80107ae0:	6a 27                	push   $0x27
  jmp alltraps
80107ae2:	e9 58 f8 ff ff       	jmp    8010733f <alltraps>

80107ae7 <vector40>:
.globl vector40
vector40:
  pushl $0
80107ae7:	6a 00                	push   $0x0
  pushl $40
80107ae9:	6a 28                	push   $0x28
  jmp alltraps
80107aeb:	e9 4f f8 ff ff       	jmp    8010733f <alltraps>

80107af0 <vector41>:
.globl vector41
vector41:
  pushl $0
80107af0:	6a 00                	push   $0x0
  pushl $41
80107af2:	6a 29                	push   $0x29
  jmp alltraps
80107af4:	e9 46 f8 ff ff       	jmp    8010733f <alltraps>

80107af9 <vector42>:
.globl vector42
vector42:
  pushl $0
80107af9:	6a 00                	push   $0x0
  pushl $42
80107afb:	6a 2a                	push   $0x2a
  jmp alltraps
80107afd:	e9 3d f8 ff ff       	jmp    8010733f <alltraps>

80107b02 <vector43>:
.globl vector43
vector43:
  pushl $0
80107b02:	6a 00                	push   $0x0
  pushl $43
80107b04:	6a 2b                	push   $0x2b
  jmp alltraps
80107b06:	e9 34 f8 ff ff       	jmp    8010733f <alltraps>

80107b0b <vector44>:
.globl vector44
vector44:
  pushl $0
80107b0b:	6a 00                	push   $0x0
  pushl $44
80107b0d:	6a 2c                	push   $0x2c
  jmp alltraps
80107b0f:	e9 2b f8 ff ff       	jmp    8010733f <alltraps>

80107b14 <vector45>:
.globl vector45
vector45:
  pushl $0
80107b14:	6a 00                	push   $0x0
  pushl $45
80107b16:	6a 2d                	push   $0x2d
  jmp alltraps
80107b18:	e9 22 f8 ff ff       	jmp    8010733f <alltraps>

80107b1d <vector46>:
.globl vector46
vector46:
  pushl $0
80107b1d:	6a 00                	push   $0x0
  pushl $46
80107b1f:	6a 2e                	push   $0x2e
  jmp alltraps
80107b21:	e9 19 f8 ff ff       	jmp    8010733f <alltraps>

80107b26 <vector47>:
.globl vector47
vector47:
  pushl $0
80107b26:	6a 00                	push   $0x0
  pushl $47
80107b28:	6a 2f                	push   $0x2f
  jmp alltraps
80107b2a:	e9 10 f8 ff ff       	jmp    8010733f <alltraps>

80107b2f <vector48>:
.globl vector48
vector48:
  pushl $0
80107b2f:	6a 00                	push   $0x0
  pushl $48
80107b31:	6a 30                	push   $0x30
  jmp alltraps
80107b33:	e9 07 f8 ff ff       	jmp    8010733f <alltraps>

80107b38 <vector49>:
.globl vector49
vector49:
  pushl $0
80107b38:	6a 00                	push   $0x0
  pushl $49
80107b3a:	6a 31                	push   $0x31
  jmp alltraps
80107b3c:	e9 fe f7 ff ff       	jmp    8010733f <alltraps>

80107b41 <vector50>:
.globl vector50
vector50:
  pushl $0
80107b41:	6a 00                	push   $0x0
  pushl $50
80107b43:	6a 32                	push   $0x32
  jmp alltraps
80107b45:	e9 f5 f7 ff ff       	jmp    8010733f <alltraps>

80107b4a <vector51>:
.globl vector51
vector51:
  pushl $0
80107b4a:	6a 00                	push   $0x0
  pushl $51
80107b4c:	6a 33                	push   $0x33
  jmp alltraps
80107b4e:	e9 ec f7 ff ff       	jmp    8010733f <alltraps>

80107b53 <vector52>:
.globl vector52
vector52:
  pushl $0
80107b53:	6a 00                	push   $0x0
  pushl $52
80107b55:	6a 34                	push   $0x34
  jmp alltraps
80107b57:	e9 e3 f7 ff ff       	jmp    8010733f <alltraps>

80107b5c <vector53>:
.globl vector53
vector53:
  pushl $0
80107b5c:	6a 00                	push   $0x0
  pushl $53
80107b5e:	6a 35                	push   $0x35
  jmp alltraps
80107b60:	e9 da f7 ff ff       	jmp    8010733f <alltraps>

80107b65 <vector54>:
.globl vector54
vector54:
  pushl $0
80107b65:	6a 00                	push   $0x0
  pushl $54
80107b67:	6a 36                	push   $0x36
  jmp alltraps
80107b69:	e9 d1 f7 ff ff       	jmp    8010733f <alltraps>

80107b6e <vector55>:
.globl vector55
vector55:
  pushl $0
80107b6e:	6a 00                	push   $0x0
  pushl $55
80107b70:	6a 37                	push   $0x37
  jmp alltraps
80107b72:	e9 c8 f7 ff ff       	jmp    8010733f <alltraps>

80107b77 <vector56>:
.globl vector56
vector56:
  pushl $0
80107b77:	6a 00                	push   $0x0
  pushl $56
80107b79:	6a 38                	push   $0x38
  jmp alltraps
80107b7b:	e9 bf f7 ff ff       	jmp    8010733f <alltraps>

80107b80 <vector57>:
.globl vector57
vector57:
  pushl $0
80107b80:	6a 00                	push   $0x0
  pushl $57
80107b82:	6a 39                	push   $0x39
  jmp alltraps
80107b84:	e9 b6 f7 ff ff       	jmp    8010733f <alltraps>

80107b89 <vector58>:
.globl vector58
vector58:
  pushl $0
80107b89:	6a 00                	push   $0x0
  pushl $58
80107b8b:	6a 3a                	push   $0x3a
  jmp alltraps
80107b8d:	e9 ad f7 ff ff       	jmp    8010733f <alltraps>

80107b92 <vector59>:
.globl vector59
vector59:
  pushl $0
80107b92:	6a 00                	push   $0x0
  pushl $59
80107b94:	6a 3b                	push   $0x3b
  jmp alltraps
80107b96:	e9 a4 f7 ff ff       	jmp    8010733f <alltraps>

80107b9b <vector60>:
.globl vector60
vector60:
  pushl $0
80107b9b:	6a 00                	push   $0x0
  pushl $60
80107b9d:	6a 3c                	push   $0x3c
  jmp alltraps
80107b9f:	e9 9b f7 ff ff       	jmp    8010733f <alltraps>

80107ba4 <vector61>:
.globl vector61
vector61:
  pushl $0
80107ba4:	6a 00                	push   $0x0
  pushl $61
80107ba6:	6a 3d                	push   $0x3d
  jmp alltraps
80107ba8:	e9 92 f7 ff ff       	jmp    8010733f <alltraps>

80107bad <vector62>:
.globl vector62
vector62:
  pushl $0
80107bad:	6a 00                	push   $0x0
  pushl $62
80107baf:	6a 3e                	push   $0x3e
  jmp alltraps
80107bb1:	e9 89 f7 ff ff       	jmp    8010733f <alltraps>

80107bb6 <vector63>:
.globl vector63
vector63:
  pushl $0
80107bb6:	6a 00                	push   $0x0
  pushl $63
80107bb8:	6a 3f                	push   $0x3f
  jmp alltraps
80107bba:	e9 80 f7 ff ff       	jmp    8010733f <alltraps>

80107bbf <vector64>:
.globl vector64
vector64:
  pushl $0
80107bbf:	6a 00                	push   $0x0
  pushl $64
80107bc1:	6a 40                	push   $0x40
  jmp alltraps
80107bc3:	e9 77 f7 ff ff       	jmp    8010733f <alltraps>

80107bc8 <vector65>:
.globl vector65
vector65:
  pushl $0
80107bc8:	6a 00                	push   $0x0
  pushl $65
80107bca:	6a 41                	push   $0x41
  jmp alltraps
80107bcc:	e9 6e f7 ff ff       	jmp    8010733f <alltraps>

80107bd1 <vector66>:
.globl vector66
vector66:
  pushl $0
80107bd1:	6a 00                	push   $0x0
  pushl $66
80107bd3:	6a 42                	push   $0x42
  jmp alltraps
80107bd5:	e9 65 f7 ff ff       	jmp    8010733f <alltraps>

80107bda <vector67>:
.globl vector67
vector67:
  pushl $0
80107bda:	6a 00                	push   $0x0
  pushl $67
80107bdc:	6a 43                	push   $0x43
  jmp alltraps
80107bde:	e9 5c f7 ff ff       	jmp    8010733f <alltraps>

80107be3 <vector68>:
.globl vector68
vector68:
  pushl $0
80107be3:	6a 00                	push   $0x0
  pushl $68
80107be5:	6a 44                	push   $0x44
  jmp alltraps
80107be7:	e9 53 f7 ff ff       	jmp    8010733f <alltraps>

80107bec <vector69>:
.globl vector69
vector69:
  pushl $0
80107bec:	6a 00                	push   $0x0
  pushl $69
80107bee:	6a 45                	push   $0x45
  jmp alltraps
80107bf0:	e9 4a f7 ff ff       	jmp    8010733f <alltraps>

80107bf5 <vector70>:
.globl vector70
vector70:
  pushl $0
80107bf5:	6a 00                	push   $0x0
  pushl $70
80107bf7:	6a 46                	push   $0x46
  jmp alltraps
80107bf9:	e9 41 f7 ff ff       	jmp    8010733f <alltraps>

80107bfe <vector71>:
.globl vector71
vector71:
  pushl $0
80107bfe:	6a 00                	push   $0x0
  pushl $71
80107c00:	6a 47                	push   $0x47
  jmp alltraps
80107c02:	e9 38 f7 ff ff       	jmp    8010733f <alltraps>

80107c07 <vector72>:
.globl vector72
vector72:
  pushl $0
80107c07:	6a 00                	push   $0x0
  pushl $72
80107c09:	6a 48                	push   $0x48
  jmp alltraps
80107c0b:	e9 2f f7 ff ff       	jmp    8010733f <alltraps>

80107c10 <vector73>:
.globl vector73
vector73:
  pushl $0
80107c10:	6a 00                	push   $0x0
  pushl $73
80107c12:	6a 49                	push   $0x49
  jmp alltraps
80107c14:	e9 26 f7 ff ff       	jmp    8010733f <alltraps>

80107c19 <vector74>:
.globl vector74
vector74:
  pushl $0
80107c19:	6a 00                	push   $0x0
  pushl $74
80107c1b:	6a 4a                	push   $0x4a
  jmp alltraps
80107c1d:	e9 1d f7 ff ff       	jmp    8010733f <alltraps>

80107c22 <vector75>:
.globl vector75
vector75:
  pushl $0
80107c22:	6a 00                	push   $0x0
  pushl $75
80107c24:	6a 4b                	push   $0x4b
  jmp alltraps
80107c26:	e9 14 f7 ff ff       	jmp    8010733f <alltraps>

80107c2b <vector76>:
.globl vector76
vector76:
  pushl $0
80107c2b:	6a 00                	push   $0x0
  pushl $76
80107c2d:	6a 4c                	push   $0x4c
  jmp alltraps
80107c2f:	e9 0b f7 ff ff       	jmp    8010733f <alltraps>

80107c34 <vector77>:
.globl vector77
vector77:
  pushl $0
80107c34:	6a 00                	push   $0x0
  pushl $77
80107c36:	6a 4d                	push   $0x4d
  jmp alltraps
80107c38:	e9 02 f7 ff ff       	jmp    8010733f <alltraps>

80107c3d <vector78>:
.globl vector78
vector78:
  pushl $0
80107c3d:	6a 00                	push   $0x0
  pushl $78
80107c3f:	6a 4e                	push   $0x4e
  jmp alltraps
80107c41:	e9 f9 f6 ff ff       	jmp    8010733f <alltraps>

80107c46 <vector79>:
.globl vector79
vector79:
  pushl $0
80107c46:	6a 00                	push   $0x0
  pushl $79
80107c48:	6a 4f                	push   $0x4f
  jmp alltraps
80107c4a:	e9 f0 f6 ff ff       	jmp    8010733f <alltraps>

80107c4f <vector80>:
.globl vector80
vector80:
  pushl $0
80107c4f:	6a 00                	push   $0x0
  pushl $80
80107c51:	6a 50                	push   $0x50
  jmp alltraps
80107c53:	e9 e7 f6 ff ff       	jmp    8010733f <alltraps>

80107c58 <vector81>:
.globl vector81
vector81:
  pushl $0
80107c58:	6a 00                	push   $0x0
  pushl $81
80107c5a:	6a 51                	push   $0x51
  jmp alltraps
80107c5c:	e9 de f6 ff ff       	jmp    8010733f <alltraps>

80107c61 <vector82>:
.globl vector82
vector82:
  pushl $0
80107c61:	6a 00                	push   $0x0
  pushl $82
80107c63:	6a 52                	push   $0x52
  jmp alltraps
80107c65:	e9 d5 f6 ff ff       	jmp    8010733f <alltraps>

80107c6a <vector83>:
.globl vector83
vector83:
  pushl $0
80107c6a:	6a 00                	push   $0x0
  pushl $83
80107c6c:	6a 53                	push   $0x53
  jmp alltraps
80107c6e:	e9 cc f6 ff ff       	jmp    8010733f <alltraps>

80107c73 <vector84>:
.globl vector84
vector84:
  pushl $0
80107c73:	6a 00                	push   $0x0
  pushl $84
80107c75:	6a 54                	push   $0x54
  jmp alltraps
80107c77:	e9 c3 f6 ff ff       	jmp    8010733f <alltraps>

80107c7c <vector85>:
.globl vector85
vector85:
  pushl $0
80107c7c:	6a 00                	push   $0x0
  pushl $85
80107c7e:	6a 55                	push   $0x55
  jmp alltraps
80107c80:	e9 ba f6 ff ff       	jmp    8010733f <alltraps>

80107c85 <vector86>:
.globl vector86
vector86:
  pushl $0
80107c85:	6a 00                	push   $0x0
  pushl $86
80107c87:	6a 56                	push   $0x56
  jmp alltraps
80107c89:	e9 b1 f6 ff ff       	jmp    8010733f <alltraps>

80107c8e <vector87>:
.globl vector87
vector87:
  pushl $0
80107c8e:	6a 00                	push   $0x0
  pushl $87
80107c90:	6a 57                	push   $0x57
  jmp alltraps
80107c92:	e9 a8 f6 ff ff       	jmp    8010733f <alltraps>

80107c97 <vector88>:
.globl vector88
vector88:
  pushl $0
80107c97:	6a 00                	push   $0x0
  pushl $88
80107c99:	6a 58                	push   $0x58
  jmp alltraps
80107c9b:	e9 9f f6 ff ff       	jmp    8010733f <alltraps>

80107ca0 <vector89>:
.globl vector89
vector89:
  pushl $0
80107ca0:	6a 00                	push   $0x0
  pushl $89
80107ca2:	6a 59                	push   $0x59
  jmp alltraps
80107ca4:	e9 96 f6 ff ff       	jmp    8010733f <alltraps>

80107ca9 <vector90>:
.globl vector90
vector90:
  pushl $0
80107ca9:	6a 00                	push   $0x0
  pushl $90
80107cab:	6a 5a                	push   $0x5a
  jmp alltraps
80107cad:	e9 8d f6 ff ff       	jmp    8010733f <alltraps>

80107cb2 <vector91>:
.globl vector91
vector91:
  pushl $0
80107cb2:	6a 00                	push   $0x0
  pushl $91
80107cb4:	6a 5b                	push   $0x5b
  jmp alltraps
80107cb6:	e9 84 f6 ff ff       	jmp    8010733f <alltraps>

80107cbb <vector92>:
.globl vector92
vector92:
  pushl $0
80107cbb:	6a 00                	push   $0x0
  pushl $92
80107cbd:	6a 5c                	push   $0x5c
  jmp alltraps
80107cbf:	e9 7b f6 ff ff       	jmp    8010733f <alltraps>

80107cc4 <vector93>:
.globl vector93
vector93:
  pushl $0
80107cc4:	6a 00                	push   $0x0
  pushl $93
80107cc6:	6a 5d                	push   $0x5d
  jmp alltraps
80107cc8:	e9 72 f6 ff ff       	jmp    8010733f <alltraps>

80107ccd <vector94>:
.globl vector94
vector94:
  pushl $0
80107ccd:	6a 00                	push   $0x0
  pushl $94
80107ccf:	6a 5e                	push   $0x5e
  jmp alltraps
80107cd1:	e9 69 f6 ff ff       	jmp    8010733f <alltraps>

80107cd6 <vector95>:
.globl vector95
vector95:
  pushl $0
80107cd6:	6a 00                	push   $0x0
  pushl $95
80107cd8:	6a 5f                	push   $0x5f
  jmp alltraps
80107cda:	e9 60 f6 ff ff       	jmp    8010733f <alltraps>

80107cdf <vector96>:
.globl vector96
vector96:
  pushl $0
80107cdf:	6a 00                	push   $0x0
  pushl $96
80107ce1:	6a 60                	push   $0x60
  jmp alltraps
80107ce3:	e9 57 f6 ff ff       	jmp    8010733f <alltraps>

80107ce8 <vector97>:
.globl vector97
vector97:
  pushl $0
80107ce8:	6a 00                	push   $0x0
  pushl $97
80107cea:	6a 61                	push   $0x61
  jmp alltraps
80107cec:	e9 4e f6 ff ff       	jmp    8010733f <alltraps>

80107cf1 <vector98>:
.globl vector98
vector98:
  pushl $0
80107cf1:	6a 00                	push   $0x0
  pushl $98
80107cf3:	6a 62                	push   $0x62
  jmp alltraps
80107cf5:	e9 45 f6 ff ff       	jmp    8010733f <alltraps>

80107cfa <vector99>:
.globl vector99
vector99:
  pushl $0
80107cfa:	6a 00                	push   $0x0
  pushl $99
80107cfc:	6a 63                	push   $0x63
  jmp alltraps
80107cfe:	e9 3c f6 ff ff       	jmp    8010733f <alltraps>

80107d03 <vector100>:
.globl vector100
vector100:
  pushl $0
80107d03:	6a 00                	push   $0x0
  pushl $100
80107d05:	6a 64                	push   $0x64
  jmp alltraps
80107d07:	e9 33 f6 ff ff       	jmp    8010733f <alltraps>

80107d0c <vector101>:
.globl vector101
vector101:
  pushl $0
80107d0c:	6a 00                	push   $0x0
  pushl $101
80107d0e:	6a 65                	push   $0x65
  jmp alltraps
80107d10:	e9 2a f6 ff ff       	jmp    8010733f <alltraps>

80107d15 <vector102>:
.globl vector102
vector102:
  pushl $0
80107d15:	6a 00                	push   $0x0
  pushl $102
80107d17:	6a 66                	push   $0x66
  jmp alltraps
80107d19:	e9 21 f6 ff ff       	jmp    8010733f <alltraps>

80107d1e <vector103>:
.globl vector103
vector103:
  pushl $0
80107d1e:	6a 00                	push   $0x0
  pushl $103
80107d20:	6a 67                	push   $0x67
  jmp alltraps
80107d22:	e9 18 f6 ff ff       	jmp    8010733f <alltraps>

80107d27 <vector104>:
.globl vector104
vector104:
  pushl $0
80107d27:	6a 00                	push   $0x0
  pushl $104
80107d29:	6a 68                	push   $0x68
  jmp alltraps
80107d2b:	e9 0f f6 ff ff       	jmp    8010733f <alltraps>

80107d30 <vector105>:
.globl vector105
vector105:
  pushl $0
80107d30:	6a 00                	push   $0x0
  pushl $105
80107d32:	6a 69                	push   $0x69
  jmp alltraps
80107d34:	e9 06 f6 ff ff       	jmp    8010733f <alltraps>

80107d39 <vector106>:
.globl vector106
vector106:
  pushl $0
80107d39:	6a 00                	push   $0x0
  pushl $106
80107d3b:	6a 6a                	push   $0x6a
  jmp alltraps
80107d3d:	e9 fd f5 ff ff       	jmp    8010733f <alltraps>

80107d42 <vector107>:
.globl vector107
vector107:
  pushl $0
80107d42:	6a 00                	push   $0x0
  pushl $107
80107d44:	6a 6b                	push   $0x6b
  jmp alltraps
80107d46:	e9 f4 f5 ff ff       	jmp    8010733f <alltraps>

80107d4b <vector108>:
.globl vector108
vector108:
  pushl $0
80107d4b:	6a 00                	push   $0x0
  pushl $108
80107d4d:	6a 6c                	push   $0x6c
  jmp alltraps
80107d4f:	e9 eb f5 ff ff       	jmp    8010733f <alltraps>

80107d54 <vector109>:
.globl vector109
vector109:
  pushl $0
80107d54:	6a 00                	push   $0x0
  pushl $109
80107d56:	6a 6d                	push   $0x6d
  jmp alltraps
80107d58:	e9 e2 f5 ff ff       	jmp    8010733f <alltraps>

80107d5d <vector110>:
.globl vector110
vector110:
  pushl $0
80107d5d:	6a 00                	push   $0x0
  pushl $110
80107d5f:	6a 6e                	push   $0x6e
  jmp alltraps
80107d61:	e9 d9 f5 ff ff       	jmp    8010733f <alltraps>

80107d66 <vector111>:
.globl vector111
vector111:
  pushl $0
80107d66:	6a 00                	push   $0x0
  pushl $111
80107d68:	6a 6f                	push   $0x6f
  jmp alltraps
80107d6a:	e9 d0 f5 ff ff       	jmp    8010733f <alltraps>

80107d6f <vector112>:
.globl vector112
vector112:
  pushl $0
80107d6f:	6a 00                	push   $0x0
  pushl $112
80107d71:	6a 70                	push   $0x70
  jmp alltraps
80107d73:	e9 c7 f5 ff ff       	jmp    8010733f <alltraps>

80107d78 <vector113>:
.globl vector113
vector113:
  pushl $0
80107d78:	6a 00                	push   $0x0
  pushl $113
80107d7a:	6a 71                	push   $0x71
  jmp alltraps
80107d7c:	e9 be f5 ff ff       	jmp    8010733f <alltraps>

80107d81 <vector114>:
.globl vector114
vector114:
  pushl $0
80107d81:	6a 00                	push   $0x0
  pushl $114
80107d83:	6a 72                	push   $0x72
  jmp alltraps
80107d85:	e9 b5 f5 ff ff       	jmp    8010733f <alltraps>

80107d8a <vector115>:
.globl vector115
vector115:
  pushl $0
80107d8a:	6a 00                	push   $0x0
  pushl $115
80107d8c:	6a 73                	push   $0x73
  jmp alltraps
80107d8e:	e9 ac f5 ff ff       	jmp    8010733f <alltraps>

80107d93 <vector116>:
.globl vector116
vector116:
  pushl $0
80107d93:	6a 00                	push   $0x0
  pushl $116
80107d95:	6a 74                	push   $0x74
  jmp alltraps
80107d97:	e9 a3 f5 ff ff       	jmp    8010733f <alltraps>

80107d9c <vector117>:
.globl vector117
vector117:
  pushl $0
80107d9c:	6a 00                	push   $0x0
  pushl $117
80107d9e:	6a 75                	push   $0x75
  jmp alltraps
80107da0:	e9 9a f5 ff ff       	jmp    8010733f <alltraps>

80107da5 <vector118>:
.globl vector118
vector118:
  pushl $0
80107da5:	6a 00                	push   $0x0
  pushl $118
80107da7:	6a 76                	push   $0x76
  jmp alltraps
80107da9:	e9 91 f5 ff ff       	jmp    8010733f <alltraps>

80107dae <vector119>:
.globl vector119
vector119:
  pushl $0
80107dae:	6a 00                	push   $0x0
  pushl $119
80107db0:	6a 77                	push   $0x77
  jmp alltraps
80107db2:	e9 88 f5 ff ff       	jmp    8010733f <alltraps>

80107db7 <vector120>:
.globl vector120
vector120:
  pushl $0
80107db7:	6a 00                	push   $0x0
  pushl $120
80107db9:	6a 78                	push   $0x78
  jmp alltraps
80107dbb:	e9 7f f5 ff ff       	jmp    8010733f <alltraps>

80107dc0 <vector121>:
.globl vector121
vector121:
  pushl $0
80107dc0:	6a 00                	push   $0x0
  pushl $121
80107dc2:	6a 79                	push   $0x79
  jmp alltraps
80107dc4:	e9 76 f5 ff ff       	jmp    8010733f <alltraps>

80107dc9 <vector122>:
.globl vector122
vector122:
  pushl $0
80107dc9:	6a 00                	push   $0x0
  pushl $122
80107dcb:	6a 7a                	push   $0x7a
  jmp alltraps
80107dcd:	e9 6d f5 ff ff       	jmp    8010733f <alltraps>

80107dd2 <vector123>:
.globl vector123
vector123:
  pushl $0
80107dd2:	6a 00                	push   $0x0
  pushl $123
80107dd4:	6a 7b                	push   $0x7b
  jmp alltraps
80107dd6:	e9 64 f5 ff ff       	jmp    8010733f <alltraps>

80107ddb <vector124>:
.globl vector124
vector124:
  pushl $0
80107ddb:	6a 00                	push   $0x0
  pushl $124
80107ddd:	6a 7c                	push   $0x7c
  jmp alltraps
80107ddf:	e9 5b f5 ff ff       	jmp    8010733f <alltraps>

80107de4 <vector125>:
.globl vector125
vector125:
  pushl $0
80107de4:	6a 00                	push   $0x0
  pushl $125
80107de6:	6a 7d                	push   $0x7d
  jmp alltraps
80107de8:	e9 52 f5 ff ff       	jmp    8010733f <alltraps>

80107ded <vector126>:
.globl vector126
vector126:
  pushl $0
80107ded:	6a 00                	push   $0x0
  pushl $126
80107def:	6a 7e                	push   $0x7e
  jmp alltraps
80107df1:	e9 49 f5 ff ff       	jmp    8010733f <alltraps>

80107df6 <vector127>:
.globl vector127
vector127:
  pushl $0
80107df6:	6a 00                	push   $0x0
  pushl $127
80107df8:	6a 7f                	push   $0x7f
  jmp alltraps
80107dfa:	e9 40 f5 ff ff       	jmp    8010733f <alltraps>

80107dff <vector128>:
.globl vector128
vector128:
  pushl $0
80107dff:	6a 00                	push   $0x0
  pushl $128
80107e01:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107e06:	e9 34 f5 ff ff       	jmp    8010733f <alltraps>

80107e0b <vector129>:
.globl vector129
vector129:
  pushl $0
80107e0b:	6a 00                	push   $0x0
  pushl $129
80107e0d:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107e12:	e9 28 f5 ff ff       	jmp    8010733f <alltraps>

80107e17 <vector130>:
.globl vector130
vector130:
  pushl $0
80107e17:	6a 00                	push   $0x0
  pushl $130
80107e19:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107e1e:	e9 1c f5 ff ff       	jmp    8010733f <alltraps>

80107e23 <vector131>:
.globl vector131
vector131:
  pushl $0
80107e23:	6a 00                	push   $0x0
  pushl $131
80107e25:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107e2a:	e9 10 f5 ff ff       	jmp    8010733f <alltraps>

80107e2f <vector132>:
.globl vector132
vector132:
  pushl $0
80107e2f:	6a 00                	push   $0x0
  pushl $132
80107e31:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107e36:	e9 04 f5 ff ff       	jmp    8010733f <alltraps>

80107e3b <vector133>:
.globl vector133
vector133:
  pushl $0
80107e3b:	6a 00                	push   $0x0
  pushl $133
80107e3d:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107e42:	e9 f8 f4 ff ff       	jmp    8010733f <alltraps>

80107e47 <vector134>:
.globl vector134
vector134:
  pushl $0
80107e47:	6a 00                	push   $0x0
  pushl $134
80107e49:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107e4e:	e9 ec f4 ff ff       	jmp    8010733f <alltraps>

80107e53 <vector135>:
.globl vector135
vector135:
  pushl $0
80107e53:	6a 00                	push   $0x0
  pushl $135
80107e55:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107e5a:	e9 e0 f4 ff ff       	jmp    8010733f <alltraps>

80107e5f <vector136>:
.globl vector136
vector136:
  pushl $0
80107e5f:	6a 00                	push   $0x0
  pushl $136
80107e61:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107e66:	e9 d4 f4 ff ff       	jmp    8010733f <alltraps>

80107e6b <vector137>:
.globl vector137
vector137:
  pushl $0
80107e6b:	6a 00                	push   $0x0
  pushl $137
80107e6d:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107e72:	e9 c8 f4 ff ff       	jmp    8010733f <alltraps>

80107e77 <vector138>:
.globl vector138
vector138:
  pushl $0
80107e77:	6a 00                	push   $0x0
  pushl $138
80107e79:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107e7e:	e9 bc f4 ff ff       	jmp    8010733f <alltraps>

80107e83 <vector139>:
.globl vector139
vector139:
  pushl $0
80107e83:	6a 00                	push   $0x0
  pushl $139
80107e85:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107e8a:	e9 b0 f4 ff ff       	jmp    8010733f <alltraps>

80107e8f <vector140>:
.globl vector140
vector140:
  pushl $0
80107e8f:	6a 00                	push   $0x0
  pushl $140
80107e91:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107e96:	e9 a4 f4 ff ff       	jmp    8010733f <alltraps>

80107e9b <vector141>:
.globl vector141
vector141:
  pushl $0
80107e9b:	6a 00                	push   $0x0
  pushl $141
80107e9d:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107ea2:	e9 98 f4 ff ff       	jmp    8010733f <alltraps>

80107ea7 <vector142>:
.globl vector142
vector142:
  pushl $0
80107ea7:	6a 00                	push   $0x0
  pushl $142
80107ea9:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107eae:	e9 8c f4 ff ff       	jmp    8010733f <alltraps>

80107eb3 <vector143>:
.globl vector143
vector143:
  pushl $0
80107eb3:	6a 00                	push   $0x0
  pushl $143
80107eb5:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107eba:	e9 80 f4 ff ff       	jmp    8010733f <alltraps>

80107ebf <vector144>:
.globl vector144
vector144:
  pushl $0
80107ebf:	6a 00                	push   $0x0
  pushl $144
80107ec1:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107ec6:	e9 74 f4 ff ff       	jmp    8010733f <alltraps>

80107ecb <vector145>:
.globl vector145
vector145:
  pushl $0
80107ecb:	6a 00                	push   $0x0
  pushl $145
80107ecd:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107ed2:	e9 68 f4 ff ff       	jmp    8010733f <alltraps>

80107ed7 <vector146>:
.globl vector146
vector146:
  pushl $0
80107ed7:	6a 00                	push   $0x0
  pushl $146
80107ed9:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107ede:	e9 5c f4 ff ff       	jmp    8010733f <alltraps>

80107ee3 <vector147>:
.globl vector147
vector147:
  pushl $0
80107ee3:	6a 00                	push   $0x0
  pushl $147
80107ee5:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107eea:	e9 50 f4 ff ff       	jmp    8010733f <alltraps>

80107eef <vector148>:
.globl vector148
vector148:
  pushl $0
80107eef:	6a 00                	push   $0x0
  pushl $148
80107ef1:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107ef6:	e9 44 f4 ff ff       	jmp    8010733f <alltraps>

80107efb <vector149>:
.globl vector149
vector149:
  pushl $0
80107efb:	6a 00                	push   $0x0
  pushl $149
80107efd:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107f02:	e9 38 f4 ff ff       	jmp    8010733f <alltraps>

80107f07 <vector150>:
.globl vector150
vector150:
  pushl $0
80107f07:	6a 00                	push   $0x0
  pushl $150
80107f09:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107f0e:	e9 2c f4 ff ff       	jmp    8010733f <alltraps>

80107f13 <vector151>:
.globl vector151
vector151:
  pushl $0
80107f13:	6a 00                	push   $0x0
  pushl $151
80107f15:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107f1a:	e9 20 f4 ff ff       	jmp    8010733f <alltraps>

80107f1f <vector152>:
.globl vector152
vector152:
  pushl $0
80107f1f:	6a 00                	push   $0x0
  pushl $152
80107f21:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107f26:	e9 14 f4 ff ff       	jmp    8010733f <alltraps>

80107f2b <vector153>:
.globl vector153
vector153:
  pushl $0
80107f2b:	6a 00                	push   $0x0
  pushl $153
80107f2d:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107f32:	e9 08 f4 ff ff       	jmp    8010733f <alltraps>

80107f37 <vector154>:
.globl vector154
vector154:
  pushl $0
80107f37:	6a 00                	push   $0x0
  pushl $154
80107f39:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107f3e:	e9 fc f3 ff ff       	jmp    8010733f <alltraps>

80107f43 <vector155>:
.globl vector155
vector155:
  pushl $0
80107f43:	6a 00                	push   $0x0
  pushl $155
80107f45:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107f4a:	e9 f0 f3 ff ff       	jmp    8010733f <alltraps>

80107f4f <vector156>:
.globl vector156
vector156:
  pushl $0
80107f4f:	6a 00                	push   $0x0
  pushl $156
80107f51:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107f56:	e9 e4 f3 ff ff       	jmp    8010733f <alltraps>

80107f5b <vector157>:
.globl vector157
vector157:
  pushl $0
80107f5b:	6a 00                	push   $0x0
  pushl $157
80107f5d:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107f62:	e9 d8 f3 ff ff       	jmp    8010733f <alltraps>

80107f67 <vector158>:
.globl vector158
vector158:
  pushl $0
80107f67:	6a 00                	push   $0x0
  pushl $158
80107f69:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107f6e:	e9 cc f3 ff ff       	jmp    8010733f <alltraps>

80107f73 <vector159>:
.globl vector159
vector159:
  pushl $0
80107f73:	6a 00                	push   $0x0
  pushl $159
80107f75:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107f7a:	e9 c0 f3 ff ff       	jmp    8010733f <alltraps>

80107f7f <vector160>:
.globl vector160
vector160:
  pushl $0
80107f7f:	6a 00                	push   $0x0
  pushl $160
80107f81:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107f86:	e9 b4 f3 ff ff       	jmp    8010733f <alltraps>

80107f8b <vector161>:
.globl vector161
vector161:
  pushl $0
80107f8b:	6a 00                	push   $0x0
  pushl $161
80107f8d:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107f92:	e9 a8 f3 ff ff       	jmp    8010733f <alltraps>

80107f97 <vector162>:
.globl vector162
vector162:
  pushl $0
80107f97:	6a 00                	push   $0x0
  pushl $162
80107f99:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107f9e:	e9 9c f3 ff ff       	jmp    8010733f <alltraps>

80107fa3 <vector163>:
.globl vector163
vector163:
  pushl $0
80107fa3:	6a 00                	push   $0x0
  pushl $163
80107fa5:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107faa:	e9 90 f3 ff ff       	jmp    8010733f <alltraps>

80107faf <vector164>:
.globl vector164
vector164:
  pushl $0
80107faf:	6a 00                	push   $0x0
  pushl $164
80107fb1:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107fb6:	e9 84 f3 ff ff       	jmp    8010733f <alltraps>

80107fbb <vector165>:
.globl vector165
vector165:
  pushl $0
80107fbb:	6a 00                	push   $0x0
  pushl $165
80107fbd:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107fc2:	e9 78 f3 ff ff       	jmp    8010733f <alltraps>

80107fc7 <vector166>:
.globl vector166
vector166:
  pushl $0
80107fc7:	6a 00                	push   $0x0
  pushl $166
80107fc9:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107fce:	e9 6c f3 ff ff       	jmp    8010733f <alltraps>

80107fd3 <vector167>:
.globl vector167
vector167:
  pushl $0
80107fd3:	6a 00                	push   $0x0
  pushl $167
80107fd5:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107fda:	e9 60 f3 ff ff       	jmp    8010733f <alltraps>

80107fdf <vector168>:
.globl vector168
vector168:
  pushl $0
80107fdf:	6a 00                	push   $0x0
  pushl $168
80107fe1:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107fe6:	e9 54 f3 ff ff       	jmp    8010733f <alltraps>

80107feb <vector169>:
.globl vector169
vector169:
  pushl $0
80107feb:	6a 00                	push   $0x0
  pushl $169
80107fed:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107ff2:	e9 48 f3 ff ff       	jmp    8010733f <alltraps>

80107ff7 <vector170>:
.globl vector170
vector170:
  pushl $0
80107ff7:	6a 00                	push   $0x0
  pushl $170
80107ff9:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107ffe:	e9 3c f3 ff ff       	jmp    8010733f <alltraps>

80108003 <vector171>:
.globl vector171
vector171:
  pushl $0
80108003:	6a 00                	push   $0x0
  pushl $171
80108005:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
8010800a:	e9 30 f3 ff ff       	jmp    8010733f <alltraps>

8010800f <vector172>:
.globl vector172
vector172:
  pushl $0
8010800f:	6a 00                	push   $0x0
  pushl $172
80108011:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80108016:	e9 24 f3 ff ff       	jmp    8010733f <alltraps>

8010801b <vector173>:
.globl vector173
vector173:
  pushl $0
8010801b:	6a 00                	push   $0x0
  pushl $173
8010801d:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80108022:	e9 18 f3 ff ff       	jmp    8010733f <alltraps>

80108027 <vector174>:
.globl vector174
vector174:
  pushl $0
80108027:	6a 00                	push   $0x0
  pushl $174
80108029:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010802e:	e9 0c f3 ff ff       	jmp    8010733f <alltraps>

80108033 <vector175>:
.globl vector175
vector175:
  pushl $0
80108033:	6a 00                	push   $0x0
  pushl $175
80108035:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010803a:	e9 00 f3 ff ff       	jmp    8010733f <alltraps>

8010803f <vector176>:
.globl vector176
vector176:
  pushl $0
8010803f:	6a 00                	push   $0x0
  pushl $176
80108041:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80108046:	e9 f4 f2 ff ff       	jmp    8010733f <alltraps>

8010804b <vector177>:
.globl vector177
vector177:
  pushl $0
8010804b:	6a 00                	push   $0x0
  pushl $177
8010804d:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80108052:	e9 e8 f2 ff ff       	jmp    8010733f <alltraps>

80108057 <vector178>:
.globl vector178
vector178:
  pushl $0
80108057:	6a 00                	push   $0x0
  pushl $178
80108059:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010805e:	e9 dc f2 ff ff       	jmp    8010733f <alltraps>

80108063 <vector179>:
.globl vector179
vector179:
  pushl $0
80108063:	6a 00                	push   $0x0
  pushl $179
80108065:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010806a:	e9 d0 f2 ff ff       	jmp    8010733f <alltraps>

8010806f <vector180>:
.globl vector180
vector180:
  pushl $0
8010806f:	6a 00                	push   $0x0
  pushl $180
80108071:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80108076:	e9 c4 f2 ff ff       	jmp    8010733f <alltraps>

8010807b <vector181>:
.globl vector181
vector181:
  pushl $0
8010807b:	6a 00                	push   $0x0
  pushl $181
8010807d:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80108082:	e9 b8 f2 ff ff       	jmp    8010733f <alltraps>

80108087 <vector182>:
.globl vector182
vector182:
  pushl $0
80108087:	6a 00                	push   $0x0
  pushl $182
80108089:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010808e:	e9 ac f2 ff ff       	jmp    8010733f <alltraps>

80108093 <vector183>:
.globl vector183
vector183:
  pushl $0
80108093:	6a 00                	push   $0x0
  pushl $183
80108095:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010809a:	e9 a0 f2 ff ff       	jmp    8010733f <alltraps>

8010809f <vector184>:
.globl vector184
vector184:
  pushl $0
8010809f:	6a 00                	push   $0x0
  pushl $184
801080a1:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801080a6:	e9 94 f2 ff ff       	jmp    8010733f <alltraps>

801080ab <vector185>:
.globl vector185
vector185:
  pushl $0
801080ab:	6a 00                	push   $0x0
  pushl $185
801080ad:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801080b2:	e9 88 f2 ff ff       	jmp    8010733f <alltraps>

801080b7 <vector186>:
.globl vector186
vector186:
  pushl $0
801080b7:	6a 00                	push   $0x0
  pushl $186
801080b9:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801080be:	e9 7c f2 ff ff       	jmp    8010733f <alltraps>

801080c3 <vector187>:
.globl vector187
vector187:
  pushl $0
801080c3:	6a 00                	push   $0x0
  pushl $187
801080c5:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801080ca:	e9 70 f2 ff ff       	jmp    8010733f <alltraps>

801080cf <vector188>:
.globl vector188
vector188:
  pushl $0
801080cf:	6a 00                	push   $0x0
  pushl $188
801080d1:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801080d6:	e9 64 f2 ff ff       	jmp    8010733f <alltraps>

801080db <vector189>:
.globl vector189
vector189:
  pushl $0
801080db:	6a 00                	push   $0x0
  pushl $189
801080dd:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801080e2:	e9 58 f2 ff ff       	jmp    8010733f <alltraps>

801080e7 <vector190>:
.globl vector190
vector190:
  pushl $0
801080e7:	6a 00                	push   $0x0
  pushl $190
801080e9:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801080ee:	e9 4c f2 ff ff       	jmp    8010733f <alltraps>

801080f3 <vector191>:
.globl vector191
vector191:
  pushl $0
801080f3:	6a 00                	push   $0x0
  pushl $191
801080f5:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801080fa:	e9 40 f2 ff ff       	jmp    8010733f <alltraps>

801080ff <vector192>:
.globl vector192
vector192:
  pushl $0
801080ff:	6a 00                	push   $0x0
  pushl $192
80108101:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80108106:	e9 34 f2 ff ff       	jmp    8010733f <alltraps>

8010810b <vector193>:
.globl vector193
vector193:
  pushl $0
8010810b:	6a 00                	push   $0x0
  pushl $193
8010810d:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80108112:	e9 28 f2 ff ff       	jmp    8010733f <alltraps>

80108117 <vector194>:
.globl vector194
vector194:
  pushl $0
80108117:	6a 00                	push   $0x0
  pushl $194
80108119:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010811e:	e9 1c f2 ff ff       	jmp    8010733f <alltraps>

80108123 <vector195>:
.globl vector195
vector195:
  pushl $0
80108123:	6a 00                	push   $0x0
  pushl $195
80108125:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010812a:	e9 10 f2 ff ff       	jmp    8010733f <alltraps>

8010812f <vector196>:
.globl vector196
vector196:
  pushl $0
8010812f:	6a 00                	push   $0x0
  pushl $196
80108131:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80108136:	e9 04 f2 ff ff       	jmp    8010733f <alltraps>

8010813b <vector197>:
.globl vector197
vector197:
  pushl $0
8010813b:	6a 00                	push   $0x0
  pushl $197
8010813d:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80108142:	e9 f8 f1 ff ff       	jmp    8010733f <alltraps>

80108147 <vector198>:
.globl vector198
vector198:
  pushl $0
80108147:	6a 00                	push   $0x0
  pushl $198
80108149:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010814e:	e9 ec f1 ff ff       	jmp    8010733f <alltraps>

80108153 <vector199>:
.globl vector199
vector199:
  pushl $0
80108153:	6a 00                	push   $0x0
  pushl $199
80108155:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010815a:	e9 e0 f1 ff ff       	jmp    8010733f <alltraps>

8010815f <vector200>:
.globl vector200
vector200:
  pushl $0
8010815f:	6a 00                	push   $0x0
  pushl $200
80108161:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80108166:	e9 d4 f1 ff ff       	jmp    8010733f <alltraps>

8010816b <vector201>:
.globl vector201
vector201:
  pushl $0
8010816b:	6a 00                	push   $0x0
  pushl $201
8010816d:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80108172:	e9 c8 f1 ff ff       	jmp    8010733f <alltraps>

80108177 <vector202>:
.globl vector202
vector202:
  pushl $0
80108177:	6a 00                	push   $0x0
  pushl $202
80108179:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010817e:	e9 bc f1 ff ff       	jmp    8010733f <alltraps>

80108183 <vector203>:
.globl vector203
vector203:
  pushl $0
80108183:	6a 00                	push   $0x0
  pushl $203
80108185:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010818a:	e9 b0 f1 ff ff       	jmp    8010733f <alltraps>

8010818f <vector204>:
.globl vector204
vector204:
  pushl $0
8010818f:	6a 00                	push   $0x0
  pushl $204
80108191:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80108196:	e9 a4 f1 ff ff       	jmp    8010733f <alltraps>

8010819b <vector205>:
.globl vector205
vector205:
  pushl $0
8010819b:	6a 00                	push   $0x0
  pushl $205
8010819d:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801081a2:	e9 98 f1 ff ff       	jmp    8010733f <alltraps>

801081a7 <vector206>:
.globl vector206
vector206:
  pushl $0
801081a7:	6a 00                	push   $0x0
  pushl $206
801081a9:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801081ae:	e9 8c f1 ff ff       	jmp    8010733f <alltraps>

801081b3 <vector207>:
.globl vector207
vector207:
  pushl $0
801081b3:	6a 00                	push   $0x0
  pushl $207
801081b5:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801081ba:	e9 80 f1 ff ff       	jmp    8010733f <alltraps>

801081bf <vector208>:
.globl vector208
vector208:
  pushl $0
801081bf:	6a 00                	push   $0x0
  pushl $208
801081c1:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801081c6:	e9 74 f1 ff ff       	jmp    8010733f <alltraps>

801081cb <vector209>:
.globl vector209
vector209:
  pushl $0
801081cb:	6a 00                	push   $0x0
  pushl $209
801081cd:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801081d2:	e9 68 f1 ff ff       	jmp    8010733f <alltraps>

801081d7 <vector210>:
.globl vector210
vector210:
  pushl $0
801081d7:	6a 00                	push   $0x0
  pushl $210
801081d9:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801081de:	e9 5c f1 ff ff       	jmp    8010733f <alltraps>

801081e3 <vector211>:
.globl vector211
vector211:
  pushl $0
801081e3:	6a 00                	push   $0x0
  pushl $211
801081e5:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801081ea:	e9 50 f1 ff ff       	jmp    8010733f <alltraps>

801081ef <vector212>:
.globl vector212
vector212:
  pushl $0
801081ef:	6a 00                	push   $0x0
  pushl $212
801081f1:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801081f6:	e9 44 f1 ff ff       	jmp    8010733f <alltraps>

801081fb <vector213>:
.globl vector213
vector213:
  pushl $0
801081fb:	6a 00                	push   $0x0
  pushl $213
801081fd:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80108202:	e9 38 f1 ff ff       	jmp    8010733f <alltraps>

80108207 <vector214>:
.globl vector214
vector214:
  pushl $0
80108207:	6a 00                	push   $0x0
  pushl $214
80108209:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010820e:	e9 2c f1 ff ff       	jmp    8010733f <alltraps>

80108213 <vector215>:
.globl vector215
vector215:
  pushl $0
80108213:	6a 00                	push   $0x0
  pushl $215
80108215:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010821a:	e9 20 f1 ff ff       	jmp    8010733f <alltraps>

8010821f <vector216>:
.globl vector216
vector216:
  pushl $0
8010821f:	6a 00                	push   $0x0
  pushl $216
80108221:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80108226:	e9 14 f1 ff ff       	jmp    8010733f <alltraps>

8010822b <vector217>:
.globl vector217
vector217:
  pushl $0
8010822b:	6a 00                	push   $0x0
  pushl $217
8010822d:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80108232:	e9 08 f1 ff ff       	jmp    8010733f <alltraps>

80108237 <vector218>:
.globl vector218
vector218:
  pushl $0
80108237:	6a 00                	push   $0x0
  pushl $218
80108239:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010823e:	e9 fc f0 ff ff       	jmp    8010733f <alltraps>

80108243 <vector219>:
.globl vector219
vector219:
  pushl $0
80108243:	6a 00                	push   $0x0
  pushl $219
80108245:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010824a:	e9 f0 f0 ff ff       	jmp    8010733f <alltraps>

8010824f <vector220>:
.globl vector220
vector220:
  pushl $0
8010824f:	6a 00                	push   $0x0
  pushl $220
80108251:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80108256:	e9 e4 f0 ff ff       	jmp    8010733f <alltraps>

8010825b <vector221>:
.globl vector221
vector221:
  pushl $0
8010825b:	6a 00                	push   $0x0
  pushl $221
8010825d:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80108262:	e9 d8 f0 ff ff       	jmp    8010733f <alltraps>

80108267 <vector222>:
.globl vector222
vector222:
  pushl $0
80108267:	6a 00                	push   $0x0
  pushl $222
80108269:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010826e:	e9 cc f0 ff ff       	jmp    8010733f <alltraps>

80108273 <vector223>:
.globl vector223
vector223:
  pushl $0
80108273:	6a 00                	push   $0x0
  pushl $223
80108275:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010827a:	e9 c0 f0 ff ff       	jmp    8010733f <alltraps>

8010827f <vector224>:
.globl vector224
vector224:
  pushl $0
8010827f:	6a 00                	push   $0x0
  pushl $224
80108281:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80108286:	e9 b4 f0 ff ff       	jmp    8010733f <alltraps>

8010828b <vector225>:
.globl vector225
vector225:
  pushl $0
8010828b:	6a 00                	push   $0x0
  pushl $225
8010828d:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80108292:	e9 a8 f0 ff ff       	jmp    8010733f <alltraps>

80108297 <vector226>:
.globl vector226
vector226:
  pushl $0
80108297:	6a 00                	push   $0x0
  pushl $226
80108299:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010829e:	e9 9c f0 ff ff       	jmp    8010733f <alltraps>

801082a3 <vector227>:
.globl vector227
vector227:
  pushl $0
801082a3:	6a 00                	push   $0x0
  pushl $227
801082a5:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801082aa:	e9 90 f0 ff ff       	jmp    8010733f <alltraps>

801082af <vector228>:
.globl vector228
vector228:
  pushl $0
801082af:	6a 00                	push   $0x0
  pushl $228
801082b1:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801082b6:	e9 84 f0 ff ff       	jmp    8010733f <alltraps>

801082bb <vector229>:
.globl vector229
vector229:
  pushl $0
801082bb:	6a 00                	push   $0x0
  pushl $229
801082bd:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801082c2:	e9 78 f0 ff ff       	jmp    8010733f <alltraps>

801082c7 <vector230>:
.globl vector230
vector230:
  pushl $0
801082c7:	6a 00                	push   $0x0
  pushl $230
801082c9:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801082ce:	e9 6c f0 ff ff       	jmp    8010733f <alltraps>

801082d3 <vector231>:
.globl vector231
vector231:
  pushl $0
801082d3:	6a 00                	push   $0x0
  pushl $231
801082d5:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801082da:	e9 60 f0 ff ff       	jmp    8010733f <alltraps>

801082df <vector232>:
.globl vector232
vector232:
  pushl $0
801082df:	6a 00                	push   $0x0
  pushl $232
801082e1:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801082e6:	e9 54 f0 ff ff       	jmp    8010733f <alltraps>

801082eb <vector233>:
.globl vector233
vector233:
  pushl $0
801082eb:	6a 00                	push   $0x0
  pushl $233
801082ed:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801082f2:	e9 48 f0 ff ff       	jmp    8010733f <alltraps>

801082f7 <vector234>:
.globl vector234
vector234:
  pushl $0
801082f7:	6a 00                	push   $0x0
  pushl $234
801082f9:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801082fe:	e9 3c f0 ff ff       	jmp    8010733f <alltraps>

80108303 <vector235>:
.globl vector235
vector235:
  pushl $0
80108303:	6a 00                	push   $0x0
  pushl $235
80108305:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
8010830a:	e9 30 f0 ff ff       	jmp    8010733f <alltraps>

8010830f <vector236>:
.globl vector236
vector236:
  pushl $0
8010830f:	6a 00                	push   $0x0
  pushl $236
80108311:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80108316:	e9 24 f0 ff ff       	jmp    8010733f <alltraps>

8010831b <vector237>:
.globl vector237
vector237:
  pushl $0
8010831b:	6a 00                	push   $0x0
  pushl $237
8010831d:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80108322:	e9 18 f0 ff ff       	jmp    8010733f <alltraps>

80108327 <vector238>:
.globl vector238
vector238:
  pushl $0
80108327:	6a 00                	push   $0x0
  pushl $238
80108329:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010832e:	e9 0c f0 ff ff       	jmp    8010733f <alltraps>

80108333 <vector239>:
.globl vector239
vector239:
  pushl $0
80108333:	6a 00                	push   $0x0
  pushl $239
80108335:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010833a:	e9 00 f0 ff ff       	jmp    8010733f <alltraps>

8010833f <vector240>:
.globl vector240
vector240:
  pushl $0
8010833f:	6a 00                	push   $0x0
  pushl $240
80108341:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80108346:	e9 f4 ef ff ff       	jmp    8010733f <alltraps>

8010834b <vector241>:
.globl vector241
vector241:
  pushl $0
8010834b:	6a 00                	push   $0x0
  pushl $241
8010834d:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80108352:	e9 e8 ef ff ff       	jmp    8010733f <alltraps>

80108357 <vector242>:
.globl vector242
vector242:
  pushl $0
80108357:	6a 00                	push   $0x0
  pushl $242
80108359:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010835e:	e9 dc ef ff ff       	jmp    8010733f <alltraps>

80108363 <vector243>:
.globl vector243
vector243:
  pushl $0
80108363:	6a 00                	push   $0x0
  pushl $243
80108365:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010836a:	e9 d0 ef ff ff       	jmp    8010733f <alltraps>

8010836f <vector244>:
.globl vector244
vector244:
  pushl $0
8010836f:	6a 00                	push   $0x0
  pushl $244
80108371:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80108376:	e9 c4 ef ff ff       	jmp    8010733f <alltraps>

8010837b <vector245>:
.globl vector245
vector245:
  pushl $0
8010837b:	6a 00                	push   $0x0
  pushl $245
8010837d:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80108382:	e9 b8 ef ff ff       	jmp    8010733f <alltraps>

80108387 <vector246>:
.globl vector246
vector246:
  pushl $0
80108387:	6a 00                	push   $0x0
  pushl $246
80108389:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010838e:	e9 ac ef ff ff       	jmp    8010733f <alltraps>

80108393 <vector247>:
.globl vector247
vector247:
  pushl $0
80108393:	6a 00                	push   $0x0
  pushl $247
80108395:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010839a:	e9 a0 ef ff ff       	jmp    8010733f <alltraps>

8010839f <vector248>:
.globl vector248
vector248:
  pushl $0
8010839f:	6a 00                	push   $0x0
  pushl $248
801083a1:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801083a6:	e9 94 ef ff ff       	jmp    8010733f <alltraps>

801083ab <vector249>:
.globl vector249
vector249:
  pushl $0
801083ab:	6a 00                	push   $0x0
  pushl $249
801083ad:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801083b2:	e9 88 ef ff ff       	jmp    8010733f <alltraps>

801083b7 <vector250>:
.globl vector250
vector250:
  pushl $0
801083b7:	6a 00                	push   $0x0
  pushl $250
801083b9:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801083be:	e9 7c ef ff ff       	jmp    8010733f <alltraps>

801083c3 <vector251>:
.globl vector251
vector251:
  pushl $0
801083c3:	6a 00                	push   $0x0
  pushl $251
801083c5:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801083ca:	e9 70 ef ff ff       	jmp    8010733f <alltraps>

801083cf <vector252>:
.globl vector252
vector252:
  pushl $0
801083cf:	6a 00                	push   $0x0
  pushl $252
801083d1:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801083d6:	e9 64 ef ff ff       	jmp    8010733f <alltraps>

801083db <vector253>:
.globl vector253
vector253:
  pushl $0
801083db:	6a 00                	push   $0x0
  pushl $253
801083dd:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801083e2:	e9 58 ef ff ff       	jmp    8010733f <alltraps>

801083e7 <vector254>:
.globl vector254
vector254:
  pushl $0
801083e7:	6a 00                	push   $0x0
  pushl $254
801083e9:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801083ee:	e9 4c ef ff ff       	jmp    8010733f <alltraps>

801083f3 <vector255>:
.globl vector255
vector255:
  pushl $0
801083f3:	6a 00                	push   $0x0
  pushl $255
801083f5:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801083fa:	e9 40 ef ff ff       	jmp    8010733f <alltraps>

801083ff <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801083ff:	55                   	push   %ebp
80108400:	89 e5                	mov    %esp,%ebp
80108402:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80108405:	8b 45 0c             	mov    0xc(%ebp),%eax
80108408:	83 e8 01             	sub    $0x1,%eax
8010840b:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010840f:	8b 45 08             	mov    0x8(%ebp),%eax
80108412:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80108416:	8b 45 08             	mov    0x8(%ebp),%eax
80108419:	c1 e8 10             	shr    $0x10,%eax
8010841c:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80108420:	8d 45 fa             	lea    -0x6(%ebp),%eax
80108423:	0f 01 10             	lgdtl  (%eax)
}
80108426:	90                   	nop
80108427:	c9                   	leave  
80108428:	c3                   	ret    

80108429 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80108429:	55                   	push   %ebp
8010842a:	89 e5                	mov    %esp,%ebp
8010842c:	83 ec 04             	sub    $0x4,%esp
8010842f:	8b 45 08             	mov    0x8(%ebp),%eax
80108432:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80108436:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010843a:	0f 00 d8             	ltr    %ax
}
8010843d:	90                   	nop
8010843e:	c9                   	leave  
8010843f:	c3                   	ret    

80108440 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80108440:	55                   	push   %ebp
80108441:	89 e5                	mov    %esp,%ebp
80108443:	83 ec 04             	sub    $0x4,%esp
80108446:	8b 45 08             	mov    0x8(%ebp),%eax
80108449:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
8010844d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108451:	8e e8                	mov    %eax,%gs
}
80108453:	90                   	nop
80108454:	c9                   	leave  
80108455:	c3                   	ret    

80108456 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80108456:	55                   	push   %ebp
80108457:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80108459:	8b 45 08             	mov    0x8(%ebp),%eax
8010845c:	0f 22 d8             	mov    %eax,%cr3
}
8010845f:	90                   	nop
80108460:	5d                   	pop    %ebp
80108461:	c3                   	ret    

80108462 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80108462:	55                   	push   %ebp
80108463:	89 e5                	mov    %esp,%ebp
80108465:	8b 45 08             	mov    0x8(%ebp),%eax
80108468:	05 00 00 00 80       	add    $0x80000000,%eax
8010846d:	5d                   	pop    %ebp
8010846e:	c3                   	ret    

8010846f <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010846f:	55                   	push   %ebp
80108470:	89 e5                	mov    %esp,%ebp
80108472:	8b 45 08             	mov    0x8(%ebp),%eax
80108475:	05 00 00 00 80       	add    $0x80000000,%eax
8010847a:	5d                   	pop    %ebp
8010847b:	c3                   	ret    

8010847c <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010847c:	55                   	push   %ebp
8010847d:	89 e5                	mov    %esp,%ebp
8010847f:	53                   	push   %ebx
80108480:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80108483:	e8 e2 ab ff ff       	call   8010306a <cpunum>
80108488:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010848e:	05 80 33 11 80       	add    $0x80113380,%eax
80108493:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80108496:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108499:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010849f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084a2:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801084a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ab:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801084af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b2:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801084b6:	83 e2 f0             	and    $0xfffffff0,%edx
801084b9:	83 ca 0a             	or     $0xa,%edx
801084bc:	88 50 7d             	mov    %dl,0x7d(%eax)
801084bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084c2:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801084c6:	83 ca 10             	or     $0x10,%edx
801084c9:	88 50 7d             	mov    %dl,0x7d(%eax)
801084cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084cf:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801084d3:	83 e2 9f             	and    $0xffffff9f,%edx
801084d6:	88 50 7d             	mov    %dl,0x7d(%eax)
801084d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084dc:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801084e0:	83 ca 80             	or     $0xffffff80,%edx
801084e3:	88 50 7d             	mov    %dl,0x7d(%eax)
801084e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084e9:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801084ed:	83 ca 0f             	or     $0xf,%edx
801084f0:	88 50 7e             	mov    %dl,0x7e(%eax)
801084f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084f6:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801084fa:	83 e2 ef             	and    $0xffffffef,%edx
801084fd:	88 50 7e             	mov    %dl,0x7e(%eax)
80108500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108503:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108507:	83 e2 df             	and    $0xffffffdf,%edx
8010850a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010850d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108510:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108514:	83 ca 40             	or     $0x40,%edx
80108517:	88 50 7e             	mov    %dl,0x7e(%eax)
8010851a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010851d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108521:	83 ca 80             	or     $0xffffff80,%edx
80108524:	88 50 7e             	mov    %dl,0x7e(%eax)
80108527:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010852a:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010852e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108531:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80108538:	ff ff 
8010853a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010853d:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80108544:	00 00 
80108546:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108549:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80108550:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108553:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010855a:	83 e2 f0             	and    $0xfffffff0,%edx
8010855d:	83 ca 02             	or     $0x2,%edx
80108560:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108566:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108569:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108570:	83 ca 10             	or     $0x10,%edx
80108573:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108579:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010857c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108583:	83 e2 9f             	and    $0xffffff9f,%edx
80108586:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010858c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010858f:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108596:	83 ca 80             	or     $0xffffff80,%edx
80108599:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010859f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a2:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801085a9:	83 ca 0f             	or     $0xf,%edx
801085ac:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801085b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b5:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801085bc:	83 e2 ef             	and    $0xffffffef,%edx
801085bf:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801085c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c8:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801085cf:	83 e2 df             	and    $0xffffffdf,%edx
801085d2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801085d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085db:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801085e2:	83 ca 40             	or     $0x40,%edx
801085e5:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801085eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ee:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801085f5:	83 ca 80             	or     $0xffffff80,%edx
801085f8:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801085fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108601:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80108608:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010860b:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80108612:	ff ff 
80108614:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108617:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010861e:	00 00 
80108620:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108623:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010862a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010862d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108634:	83 e2 f0             	and    $0xfffffff0,%edx
80108637:	83 ca 0a             	or     $0xa,%edx
8010863a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108640:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108643:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010864a:	83 ca 10             	or     $0x10,%edx
8010864d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108653:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108656:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010865d:	83 ca 60             	or     $0x60,%edx
80108660:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108666:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108669:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108670:	83 ca 80             	or     $0xffffff80,%edx
80108673:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108679:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010867c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108683:	83 ca 0f             	or     $0xf,%edx
80108686:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010868c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010868f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108696:	83 e2 ef             	and    $0xffffffef,%edx
80108699:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010869f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a2:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801086a9:	83 e2 df             	and    $0xffffffdf,%edx
801086ac:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801086b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b5:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801086bc:	83 ca 40             	or     $0x40,%edx
801086bf:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801086c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c8:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801086cf:	83 ca 80             	or     $0xffffff80,%edx
801086d2:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801086d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086db:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801086e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e5:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
801086ec:	ff ff 
801086ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f1:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
801086f8:	00 00 
801086fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086fd:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80108704:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108707:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010870e:	83 e2 f0             	and    $0xfffffff0,%edx
80108711:	83 ca 02             	or     $0x2,%edx
80108714:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010871a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010871d:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108724:	83 ca 10             	or     $0x10,%edx
80108727:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010872d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108730:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108737:	83 ca 60             	or     $0x60,%edx
8010873a:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108740:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108743:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010874a:	83 ca 80             	or     $0xffffff80,%edx
8010874d:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108753:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108756:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010875d:	83 ca 0f             	or     $0xf,%edx
80108760:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108766:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108769:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108770:	83 e2 ef             	and    $0xffffffef,%edx
80108773:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108779:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010877c:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108783:	83 e2 df             	and    $0xffffffdf,%edx
80108786:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010878c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010878f:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108796:	83 ca 40             	or     $0x40,%edx
80108799:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010879f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a2:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801087a9:	83 ca 80             	or     $0xffffff80,%edx
801087ac:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801087b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087b5:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801087bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087bf:	05 b4 00 00 00       	add    $0xb4,%eax
801087c4:	89 c3                	mov    %eax,%ebx
801087c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087c9:	05 b4 00 00 00       	add    $0xb4,%eax
801087ce:	c1 e8 10             	shr    $0x10,%eax
801087d1:	89 c2                	mov    %eax,%edx
801087d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087d6:	05 b4 00 00 00       	add    $0xb4,%eax
801087db:	c1 e8 18             	shr    $0x18,%eax
801087de:	89 c1                	mov    %eax,%ecx
801087e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087e3:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
801087ea:	00 00 
801087ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ef:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
801087f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f9:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
801087ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108802:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108809:	83 e2 f0             	and    $0xfffffff0,%edx
8010880c:	83 ca 02             	or     $0x2,%edx
8010880f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108815:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108818:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010881f:	83 ca 10             	or     $0x10,%edx
80108822:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010882b:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108832:	83 e2 9f             	and    $0xffffff9f,%edx
80108835:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010883b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010883e:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108845:	83 ca 80             	or     $0xffffff80,%edx
80108848:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010884e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108851:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108858:	83 e2 f0             	and    $0xfffffff0,%edx
8010885b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108861:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108864:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010886b:	83 e2 ef             	and    $0xffffffef,%edx
8010886e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108874:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108877:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010887e:	83 e2 df             	and    $0xffffffdf,%edx
80108881:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108887:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010888a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108891:	83 ca 40             	or     $0x40,%edx
80108894:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010889a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010889d:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801088a4:	83 ca 80             	or     $0xffffff80,%edx
801088a7:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801088ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b0:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
801088b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b9:	83 c0 70             	add    $0x70,%eax
801088bc:	83 ec 08             	sub    $0x8,%esp
801088bf:	6a 38                	push   $0x38
801088c1:	50                   	push   %eax
801088c2:	e8 38 fb ff ff       	call   801083ff <lgdt>
801088c7:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
801088ca:	83 ec 0c             	sub    $0xc,%esp
801088cd:	6a 18                	push   $0x18
801088cf:	e8 6c fb ff ff       	call   80108440 <loadgs>
801088d4:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
801088d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088da:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
801088e0:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801088e7:	00 00 00 00 
}
801088eb:	90                   	nop
801088ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801088ef:	c9                   	leave  
801088f0:	c3                   	ret    

801088f1 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801088f1:	55                   	push   %ebp
801088f2:	89 e5                	mov    %esp,%ebp
801088f4:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801088f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801088fa:	c1 e8 16             	shr    $0x16,%eax
801088fd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108904:	8b 45 08             	mov    0x8(%ebp),%eax
80108907:	01 d0                	add    %edx,%eax
80108909:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
8010890c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010890f:	8b 00                	mov    (%eax),%eax
80108911:	83 e0 01             	and    $0x1,%eax
80108914:	85 c0                	test   %eax,%eax
80108916:	74 18                	je     80108930 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80108918:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010891b:	8b 00                	mov    (%eax),%eax
8010891d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108922:	50                   	push   %eax
80108923:	e8 47 fb ff ff       	call   8010846f <p2v>
80108928:	83 c4 04             	add    $0x4,%esp
8010892b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010892e:	eb 48                	jmp    80108978 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108930:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108934:	74 0e                	je     80108944 <walkpgdir+0x53>
80108936:	e8 c9 a3 ff ff       	call   80102d04 <kalloc>
8010893b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010893e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108942:	75 07                	jne    8010894b <walkpgdir+0x5a>
      return 0;
80108944:	b8 00 00 00 00       	mov    $0x0,%eax
80108949:	eb 44                	jmp    8010898f <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
8010894b:	83 ec 04             	sub    $0x4,%esp
8010894e:	68 00 10 00 00       	push   $0x1000
80108953:	6a 00                	push   $0x0
80108955:	ff 75 f4             	pushl  -0xc(%ebp)
80108958:	e8 d4 d4 ff ff       	call   80105e31 <memset>
8010895d:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80108960:	83 ec 0c             	sub    $0xc,%esp
80108963:	ff 75 f4             	pushl  -0xc(%ebp)
80108966:	e8 f7 fa ff ff       	call   80108462 <v2p>
8010896b:	83 c4 10             	add    $0x10,%esp
8010896e:	83 c8 07             	or     $0x7,%eax
80108971:	89 c2                	mov    %eax,%edx
80108973:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108976:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108978:	8b 45 0c             	mov    0xc(%ebp),%eax
8010897b:	c1 e8 0c             	shr    $0xc,%eax
8010897e:	25 ff 03 00 00       	and    $0x3ff,%eax
80108983:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010898a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010898d:	01 d0                	add    %edx,%eax
}
8010898f:	c9                   	leave  
80108990:	c3                   	ret    

80108991 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108991:	55                   	push   %ebp
80108992:	89 e5                	mov    %esp,%ebp
80108994:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80108997:	8b 45 0c             	mov    0xc(%ebp),%eax
8010899a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010899f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801089a2:	8b 55 0c             	mov    0xc(%ebp),%edx
801089a5:	8b 45 10             	mov    0x10(%ebp),%eax
801089a8:	01 d0                	add    %edx,%eax
801089aa:	83 e8 01             	sub    $0x1,%eax
801089ad:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801089b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801089b5:	83 ec 04             	sub    $0x4,%esp
801089b8:	6a 01                	push   $0x1
801089ba:	ff 75 f4             	pushl  -0xc(%ebp)
801089bd:	ff 75 08             	pushl  0x8(%ebp)
801089c0:	e8 2c ff ff ff       	call   801088f1 <walkpgdir>
801089c5:	83 c4 10             	add    $0x10,%esp
801089c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
801089cb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801089cf:	75 07                	jne    801089d8 <mappages+0x47>
      return -1;
801089d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801089d6:	eb 47                	jmp    80108a1f <mappages+0x8e>
    if(*pte & PTE_P)
801089d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089db:	8b 00                	mov    (%eax),%eax
801089dd:	83 e0 01             	and    $0x1,%eax
801089e0:	85 c0                	test   %eax,%eax
801089e2:	74 0d                	je     801089f1 <mappages+0x60>
      panic("remap");
801089e4:	83 ec 0c             	sub    $0xc,%esp
801089e7:	68 44 99 10 80       	push   $0x80109944
801089ec:	e8 75 7b ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
801089f1:	8b 45 18             	mov    0x18(%ebp),%eax
801089f4:	0b 45 14             	or     0x14(%ebp),%eax
801089f7:	83 c8 01             	or     $0x1,%eax
801089fa:	89 c2                	mov    %eax,%edx
801089fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089ff:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a04:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108a07:	74 10                	je     80108a19 <mappages+0x88>
      break;
    a += PGSIZE;
80108a09:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108a10:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108a17:	eb 9c                	jmp    801089b5 <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80108a19:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108a1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108a1f:	c9                   	leave  
80108a20:	c3                   	ret    

80108a21 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108a21:	55                   	push   %ebp
80108a22:	89 e5                	mov    %esp,%ebp
80108a24:	53                   	push   %ebx
80108a25:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108a28:	e8 d7 a2 ff ff       	call   80102d04 <kalloc>
80108a2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108a30:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108a34:	75 0a                	jne    80108a40 <setupkvm+0x1f>
    return 0;
80108a36:	b8 00 00 00 00       	mov    $0x0,%eax
80108a3b:	e9 8e 00 00 00       	jmp    80108ace <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80108a40:	83 ec 04             	sub    $0x4,%esp
80108a43:	68 00 10 00 00       	push   $0x1000
80108a48:	6a 00                	push   $0x0
80108a4a:	ff 75 f0             	pushl  -0x10(%ebp)
80108a4d:	e8 df d3 ff ff       	call   80105e31 <memset>
80108a52:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108a55:	83 ec 0c             	sub    $0xc,%esp
80108a58:	68 00 00 00 0e       	push   $0xe000000
80108a5d:	e8 0d fa ff ff       	call   8010846f <p2v>
80108a62:	83 c4 10             	add    $0x10,%esp
80108a65:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108a6a:	76 0d                	jbe    80108a79 <setupkvm+0x58>
    panic("PHYSTOP too high");
80108a6c:	83 ec 0c             	sub    $0xc,%esp
80108a6f:	68 4a 99 10 80       	push   $0x8010994a
80108a74:	e8 ed 7a ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108a79:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
80108a80:	eb 40                	jmp    80108ac2 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a85:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a8b:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a91:	8b 58 08             	mov    0x8(%eax),%ebx
80108a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a97:	8b 40 04             	mov    0x4(%eax),%eax
80108a9a:	29 c3                	sub    %eax,%ebx
80108a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a9f:	8b 00                	mov    (%eax),%eax
80108aa1:	83 ec 0c             	sub    $0xc,%esp
80108aa4:	51                   	push   %ecx
80108aa5:	52                   	push   %edx
80108aa6:	53                   	push   %ebx
80108aa7:	50                   	push   %eax
80108aa8:	ff 75 f0             	pushl  -0x10(%ebp)
80108aab:	e8 e1 fe ff ff       	call   80108991 <mappages>
80108ab0:	83 c4 20             	add    $0x20,%esp
80108ab3:	85 c0                	test   %eax,%eax
80108ab5:	79 07                	jns    80108abe <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108ab7:	b8 00 00 00 00       	mov    $0x0,%eax
80108abc:	eb 10                	jmp    80108ace <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108abe:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108ac2:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
80108ac9:	72 b7                	jb     80108a82 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108acb:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108ace:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108ad1:	c9                   	leave  
80108ad2:	c3                   	ret    

80108ad3 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108ad3:	55                   	push   %ebp
80108ad4:	89 e5                	mov    %esp,%ebp
80108ad6:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108ad9:	e8 43 ff ff ff       	call   80108a21 <setupkvm>
80108ade:	a3 58 67 11 80       	mov    %eax,0x80116758
  switchkvm();
80108ae3:	e8 03 00 00 00       	call   80108aeb <switchkvm>
}
80108ae8:	90                   	nop
80108ae9:	c9                   	leave  
80108aea:	c3                   	ret    

80108aeb <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108aeb:	55                   	push   %ebp
80108aec:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108aee:	a1 58 67 11 80       	mov    0x80116758,%eax
80108af3:	50                   	push   %eax
80108af4:	e8 69 f9 ff ff       	call   80108462 <v2p>
80108af9:	83 c4 04             	add    $0x4,%esp
80108afc:	50                   	push   %eax
80108afd:	e8 54 f9 ff ff       	call   80108456 <lcr3>
80108b02:	83 c4 04             	add    $0x4,%esp
}
80108b05:	90                   	nop
80108b06:	c9                   	leave  
80108b07:	c3                   	ret    

80108b08 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108b08:	55                   	push   %ebp
80108b09:	89 e5                	mov    %esp,%ebp
80108b0b:	56                   	push   %esi
80108b0c:	53                   	push   %ebx
  pushcli();
80108b0d:	e8 19 d2 ff ff       	call   80105d2b <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108b12:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108b18:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108b1f:	83 c2 08             	add    $0x8,%edx
80108b22:	89 d6                	mov    %edx,%esi
80108b24:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108b2b:	83 c2 08             	add    $0x8,%edx
80108b2e:	c1 ea 10             	shr    $0x10,%edx
80108b31:	89 d3                	mov    %edx,%ebx
80108b33:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108b3a:	83 c2 08             	add    $0x8,%edx
80108b3d:	c1 ea 18             	shr    $0x18,%edx
80108b40:	89 d1                	mov    %edx,%ecx
80108b42:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108b49:	67 00 
80108b4b:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108b52:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108b58:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108b5f:	83 e2 f0             	and    $0xfffffff0,%edx
80108b62:	83 ca 09             	or     $0x9,%edx
80108b65:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108b6b:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108b72:	83 ca 10             	or     $0x10,%edx
80108b75:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108b7b:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108b82:	83 e2 9f             	and    $0xffffff9f,%edx
80108b85:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108b8b:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108b92:	83 ca 80             	or     $0xffffff80,%edx
80108b95:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108b9b:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108ba2:	83 e2 f0             	and    $0xfffffff0,%edx
80108ba5:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108bab:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108bb2:	83 e2 ef             	and    $0xffffffef,%edx
80108bb5:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108bbb:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108bc2:	83 e2 df             	and    $0xffffffdf,%edx
80108bc5:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108bcb:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108bd2:	83 ca 40             	or     $0x40,%edx
80108bd5:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108bdb:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108be2:	83 e2 7f             	and    $0x7f,%edx
80108be5:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108beb:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108bf1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108bf7:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108bfe:	83 e2 ef             	and    $0xffffffef,%edx
80108c01:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108c07:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108c0d:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108c13:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108c19:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108c20:	8b 52 08             	mov    0x8(%edx),%edx
80108c23:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108c29:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108c2c:	83 ec 0c             	sub    $0xc,%esp
80108c2f:	6a 30                	push   $0x30
80108c31:	e8 f3 f7 ff ff       	call   80108429 <ltr>
80108c36:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108c39:	8b 45 08             	mov    0x8(%ebp),%eax
80108c3c:	8b 40 04             	mov    0x4(%eax),%eax
80108c3f:	85 c0                	test   %eax,%eax
80108c41:	75 0d                	jne    80108c50 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80108c43:	83 ec 0c             	sub    $0xc,%esp
80108c46:	68 5b 99 10 80       	push   $0x8010995b
80108c4b:	e8 16 79 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108c50:	8b 45 08             	mov    0x8(%ebp),%eax
80108c53:	8b 40 04             	mov    0x4(%eax),%eax
80108c56:	83 ec 0c             	sub    $0xc,%esp
80108c59:	50                   	push   %eax
80108c5a:	e8 03 f8 ff ff       	call   80108462 <v2p>
80108c5f:	83 c4 10             	add    $0x10,%esp
80108c62:	83 ec 0c             	sub    $0xc,%esp
80108c65:	50                   	push   %eax
80108c66:	e8 eb f7 ff ff       	call   80108456 <lcr3>
80108c6b:	83 c4 10             	add    $0x10,%esp
  popcli();
80108c6e:	e8 fd d0 ff ff       	call   80105d70 <popcli>
}
80108c73:	90                   	nop
80108c74:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108c77:	5b                   	pop    %ebx
80108c78:	5e                   	pop    %esi
80108c79:	5d                   	pop    %ebp
80108c7a:	c3                   	ret    

80108c7b <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108c7b:	55                   	push   %ebp
80108c7c:	89 e5                	mov    %esp,%ebp
80108c7e:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108c81:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108c88:	76 0d                	jbe    80108c97 <inituvm+0x1c>
    panic("inituvm: more than a page");
80108c8a:	83 ec 0c             	sub    $0xc,%esp
80108c8d:	68 6f 99 10 80       	push   $0x8010996f
80108c92:	e8 cf 78 ff ff       	call   80100566 <panic>
  mem = kalloc();
80108c97:	e8 68 a0 ff ff       	call   80102d04 <kalloc>
80108c9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108c9f:	83 ec 04             	sub    $0x4,%esp
80108ca2:	68 00 10 00 00       	push   $0x1000
80108ca7:	6a 00                	push   $0x0
80108ca9:	ff 75 f4             	pushl  -0xc(%ebp)
80108cac:	e8 80 d1 ff ff       	call   80105e31 <memset>
80108cb1:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108cb4:	83 ec 0c             	sub    $0xc,%esp
80108cb7:	ff 75 f4             	pushl  -0xc(%ebp)
80108cba:	e8 a3 f7 ff ff       	call   80108462 <v2p>
80108cbf:	83 c4 10             	add    $0x10,%esp
80108cc2:	83 ec 0c             	sub    $0xc,%esp
80108cc5:	6a 06                	push   $0x6
80108cc7:	50                   	push   %eax
80108cc8:	68 00 10 00 00       	push   $0x1000
80108ccd:	6a 00                	push   $0x0
80108ccf:	ff 75 08             	pushl  0x8(%ebp)
80108cd2:	e8 ba fc ff ff       	call   80108991 <mappages>
80108cd7:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108cda:	83 ec 04             	sub    $0x4,%esp
80108cdd:	ff 75 10             	pushl  0x10(%ebp)
80108ce0:	ff 75 0c             	pushl  0xc(%ebp)
80108ce3:	ff 75 f4             	pushl  -0xc(%ebp)
80108ce6:	e8 05 d2 ff ff       	call   80105ef0 <memmove>
80108ceb:	83 c4 10             	add    $0x10,%esp
}
80108cee:	90                   	nop
80108cef:	c9                   	leave  
80108cf0:	c3                   	ret    

80108cf1 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108cf1:	55                   	push   %ebp
80108cf2:	89 e5                	mov    %esp,%ebp
80108cf4:	53                   	push   %ebx
80108cf5:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108cf8:	8b 45 0c             	mov    0xc(%ebp),%eax
80108cfb:	25 ff 0f 00 00       	and    $0xfff,%eax
80108d00:	85 c0                	test   %eax,%eax
80108d02:	74 0d                	je     80108d11 <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80108d04:	83 ec 0c             	sub    $0xc,%esp
80108d07:	68 8c 99 10 80       	push   $0x8010998c
80108d0c:	e8 55 78 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108d11:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108d18:	e9 95 00 00 00       	jmp    80108db2 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108d1d:	8b 55 0c             	mov    0xc(%ebp),%edx
80108d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d23:	01 d0                	add    %edx,%eax
80108d25:	83 ec 04             	sub    $0x4,%esp
80108d28:	6a 00                	push   $0x0
80108d2a:	50                   	push   %eax
80108d2b:	ff 75 08             	pushl  0x8(%ebp)
80108d2e:	e8 be fb ff ff       	call   801088f1 <walkpgdir>
80108d33:	83 c4 10             	add    $0x10,%esp
80108d36:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108d39:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108d3d:	75 0d                	jne    80108d4c <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80108d3f:	83 ec 0c             	sub    $0xc,%esp
80108d42:	68 af 99 10 80       	push   $0x801099af
80108d47:	e8 1a 78 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108d4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d4f:	8b 00                	mov    (%eax),%eax
80108d51:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108d56:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108d59:	8b 45 18             	mov    0x18(%ebp),%eax
80108d5c:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108d5f:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108d64:	77 0b                	ja     80108d71 <loaduvm+0x80>
      n = sz - i;
80108d66:	8b 45 18             	mov    0x18(%ebp),%eax
80108d69:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108d6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108d6f:	eb 07                	jmp    80108d78 <loaduvm+0x87>
    else
      n = PGSIZE;
80108d71:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108d78:	8b 55 14             	mov    0x14(%ebp),%edx
80108d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d7e:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108d81:	83 ec 0c             	sub    $0xc,%esp
80108d84:	ff 75 e8             	pushl  -0x18(%ebp)
80108d87:	e8 e3 f6 ff ff       	call   8010846f <p2v>
80108d8c:	83 c4 10             	add    $0x10,%esp
80108d8f:	ff 75 f0             	pushl  -0x10(%ebp)
80108d92:	53                   	push   %ebx
80108d93:	50                   	push   %eax
80108d94:	ff 75 10             	pushl  0x10(%ebp)
80108d97:	e8 da 91 ff ff       	call   80101f76 <readi>
80108d9c:	83 c4 10             	add    $0x10,%esp
80108d9f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108da2:	74 07                	je     80108dab <loaduvm+0xba>
      return -1;
80108da4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108da9:	eb 18                	jmp    80108dc3 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108dab:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108db5:	3b 45 18             	cmp    0x18(%ebp),%eax
80108db8:	0f 82 5f ff ff ff    	jb     80108d1d <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108dbe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108dc3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108dc6:	c9                   	leave  
80108dc7:	c3                   	ret    

80108dc8 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108dc8:	55                   	push   %ebp
80108dc9:	89 e5                	mov    %esp,%ebp
80108dcb:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108dce:	8b 45 10             	mov    0x10(%ebp),%eax
80108dd1:	85 c0                	test   %eax,%eax
80108dd3:	79 0a                	jns    80108ddf <allocuvm+0x17>
    return 0;
80108dd5:	b8 00 00 00 00       	mov    $0x0,%eax
80108dda:	e9 b0 00 00 00       	jmp    80108e8f <allocuvm+0xc7>
  if(newsz < oldsz)
80108ddf:	8b 45 10             	mov    0x10(%ebp),%eax
80108de2:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108de5:	73 08                	jae    80108def <allocuvm+0x27>
    return oldsz;
80108de7:	8b 45 0c             	mov    0xc(%ebp),%eax
80108dea:	e9 a0 00 00 00       	jmp    80108e8f <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80108def:	8b 45 0c             	mov    0xc(%ebp),%eax
80108df2:	05 ff 0f 00 00       	add    $0xfff,%eax
80108df7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108dfc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108dff:	eb 7f                	jmp    80108e80 <allocuvm+0xb8>
    mem = kalloc();
80108e01:	e8 fe 9e ff ff       	call   80102d04 <kalloc>
80108e06:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108e09:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108e0d:	75 2b                	jne    80108e3a <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80108e0f:	83 ec 0c             	sub    $0xc,%esp
80108e12:	68 cd 99 10 80       	push   $0x801099cd
80108e17:	e8 aa 75 ff ff       	call   801003c6 <cprintf>
80108e1c:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108e1f:	83 ec 04             	sub    $0x4,%esp
80108e22:	ff 75 0c             	pushl  0xc(%ebp)
80108e25:	ff 75 10             	pushl  0x10(%ebp)
80108e28:	ff 75 08             	pushl  0x8(%ebp)
80108e2b:	e8 61 00 00 00       	call   80108e91 <deallocuvm>
80108e30:	83 c4 10             	add    $0x10,%esp
      return 0;
80108e33:	b8 00 00 00 00       	mov    $0x0,%eax
80108e38:	eb 55                	jmp    80108e8f <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
80108e3a:	83 ec 04             	sub    $0x4,%esp
80108e3d:	68 00 10 00 00       	push   $0x1000
80108e42:	6a 00                	push   $0x0
80108e44:	ff 75 f0             	pushl  -0x10(%ebp)
80108e47:	e8 e5 cf ff ff       	call   80105e31 <memset>
80108e4c:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108e4f:	83 ec 0c             	sub    $0xc,%esp
80108e52:	ff 75 f0             	pushl  -0x10(%ebp)
80108e55:	e8 08 f6 ff ff       	call   80108462 <v2p>
80108e5a:	83 c4 10             	add    $0x10,%esp
80108e5d:	89 c2                	mov    %eax,%edx
80108e5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e62:	83 ec 0c             	sub    $0xc,%esp
80108e65:	6a 06                	push   $0x6
80108e67:	52                   	push   %edx
80108e68:	68 00 10 00 00       	push   $0x1000
80108e6d:	50                   	push   %eax
80108e6e:	ff 75 08             	pushl  0x8(%ebp)
80108e71:	e8 1b fb ff ff       	call   80108991 <mappages>
80108e76:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108e79:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e83:	3b 45 10             	cmp    0x10(%ebp),%eax
80108e86:	0f 82 75 ff ff ff    	jb     80108e01 <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108e8c:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108e8f:	c9                   	leave  
80108e90:	c3                   	ret    

80108e91 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108e91:	55                   	push   %ebp
80108e92:	89 e5                	mov    %esp,%ebp
80108e94:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108e97:	8b 45 10             	mov    0x10(%ebp),%eax
80108e9a:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108e9d:	72 08                	jb     80108ea7 <deallocuvm+0x16>
    return oldsz;
80108e9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ea2:	e9 a5 00 00 00       	jmp    80108f4c <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80108ea7:	8b 45 10             	mov    0x10(%ebp),%eax
80108eaa:	05 ff 0f 00 00       	add    $0xfff,%eax
80108eaf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108eb4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108eb7:	e9 81 00 00 00       	jmp    80108f3d <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108ebc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ebf:	83 ec 04             	sub    $0x4,%esp
80108ec2:	6a 00                	push   $0x0
80108ec4:	50                   	push   %eax
80108ec5:	ff 75 08             	pushl  0x8(%ebp)
80108ec8:	e8 24 fa ff ff       	call   801088f1 <walkpgdir>
80108ecd:	83 c4 10             	add    $0x10,%esp
80108ed0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108ed3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108ed7:	75 09                	jne    80108ee2 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80108ed9:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108ee0:	eb 54                	jmp    80108f36 <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
80108ee2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ee5:	8b 00                	mov    (%eax),%eax
80108ee7:	83 e0 01             	and    $0x1,%eax
80108eea:	85 c0                	test   %eax,%eax
80108eec:	74 48                	je     80108f36 <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
80108eee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ef1:	8b 00                	mov    (%eax),%eax
80108ef3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ef8:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108efb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108eff:	75 0d                	jne    80108f0e <deallocuvm+0x7d>
        panic("kfree");
80108f01:	83 ec 0c             	sub    $0xc,%esp
80108f04:	68 e5 99 10 80       	push   $0x801099e5
80108f09:	e8 58 76 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
80108f0e:	83 ec 0c             	sub    $0xc,%esp
80108f11:	ff 75 ec             	pushl  -0x14(%ebp)
80108f14:	e8 56 f5 ff ff       	call   8010846f <p2v>
80108f19:	83 c4 10             	add    $0x10,%esp
80108f1c:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108f1f:	83 ec 0c             	sub    $0xc,%esp
80108f22:	ff 75 e8             	pushl  -0x18(%ebp)
80108f25:	e8 3d 9d ff ff       	call   80102c67 <kfree>
80108f2a:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108f2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f30:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108f36:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108f3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f40:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108f43:	0f 82 73 ff ff ff    	jb     80108ebc <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108f49:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108f4c:	c9                   	leave  
80108f4d:	c3                   	ret    

80108f4e <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108f4e:	55                   	push   %ebp
80108f4f:	89 e5                	mov    %esp,%ebp
80108f51:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108f54:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108f58:	75 0d                	jne    80108f67 <freevm+0x19>
    panic("freevm: no pgdir");
80108f5a:	83 ec 0c             	sub    $0xc,%esp
80108f5d:	68 eb 99 10 80       	push   $0x801099eb
80108f62:	e8 ff 75 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108f67:	83 ec 04             	sub    $0x4,%esp
80108f6a:	6a 00                	push   $0x0
80108f6c:	68 00 00 00 80       	push   $0x80000000
80108f71:	ff 75 08             	pushl  0x8(%ebp)
80108f74:	e8 18 ff ff ff       	call   80108e91 <deallocuvm>
80108f79:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108f7c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108f83:	eb 4f                	jmp    80108fd4 <freevm+0x86>
    if(pgdir[i] & PTE_P){
80108f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f88:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108f8f:	8b 45 08             	mov    0x8(%ebp),%eax
80108f92:	01 d0                	add    %edx,%eax
80108f94:	8b 00                	mov    (%eax),%eax
80108f96:	83 e0 01             	and    $0x1,%eax
80108f99:	85 c0                	test   %eax,%eax
80108f9b:	74 33                	je     80108fd0 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fa0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108fa7:	8b 45 08             	mov    0x8(%ebp),%eax
80108faa:	01 d0                	add    %edx,%eax
80108fac:	8b 00                	mov    (%eax),%eax
80108fae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108fb3:	83 ec 0c             	sub    $0xc,%esp
80108fb6:	50                   	push   %eax
80108fb7:	e8 b3 f4 ff ff       	call   8010846f <p2v>
80108fbc:	83 c4 10             	add    $0x10,%esp
80108fbf:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108fc2:	83 ec 0c             	sub    $0xc,%esp
80108fc5:	ff 75 f0             	pushl  -0x10(%ebp)
80108fc8:	e8 9a 9c ff ff       	call   80102c67 <kfree>
80108fcd:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108fd0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108fd4:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108fdb:	76 a8                	jbe    80108f85 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108fdd:	83 ec 0c             	sub    $0xc,%esp
80108fe0:	ff 75 08             	pushl  0x8(%ebp)
80108fe3:	e8 7f 9c ff ff       	call   80102c67 <kfree>
80108fe8:	83 c4 10             	add    $0x10,%esp
}
80108feb:	90                   	nop
80108fec:	c9                   	leave  
80108fed:	c3                   	ret    

80108fee <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108fee:	55                   	push   %ebp
80108fef:	89 e5                	mov    %esp,%ebp
80108ff1:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108ff4:	83 ec 04             	sub    $0x4,%esp
80108ff7:	6a 00                	push   $0x0
80108ff9:	ff 75 0c             	pushl  0xc(%ebp)
80108ffc:	ff 75 08             	pushl  0x8(%ebp)
80108fff:	e8 ed f8 ff ff       	call   801088f1 <walkpgdir>
80109004:	83 c4 10             	add    $0x10,%esp
80109007:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010900a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010900e:	75 0d                	jne    8010901d <clearpteu+0x2f>
    panic("clearpteu");
80109010:	83 ec 0c             	sub    $0xc,%esp
80109013:	68 fc 99 10 80       	push   $0x801099fc
80109018:	e8 49 75 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
8010901d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109020:	8b 00                	mov    (%eax),%eax
80109022:	83 e0 fb             	and    $0xfffffffb,%eax
80109025:	89 c2                	mov    %eax,%edx
80109027:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010902a:	89 10                	mov    %edx,(%eax)
}
8010902c:	90                   	nop
8010902d:	c9                   	leave  
8010902e:	c3                   	ret    

8010902f <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010902f:	55                   	push   %ebp
80109030:	89 e5                	mov    %esp,%ebp
80109032:	53                   	push   %ebx
80109033:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80109036:	e8 e6 f9 ff ff       	call   80108a21 <setupkvm>
8010903b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010903e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109042:	75 0a                	jne    8010904e <copyuvm+0x1f>
    return 0;
80109044:	b8 00 00 00 00       	mov    $0x0,%eax
80109049:	e9 f8 00 00 00       	jmp    80109146 <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
8010904e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109055:	e9 c4 00 00 00       	jmp    8010911e <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010905a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010905d:	83 ec 04             	sub    $0x4,%esp
80109060:	6a 00                	push   $0x0
80109062:	50                   	push   %eax
80109063:	ff 75 08             	pushl  0x8(%ebp)
80109066:	e8 86 f8 ff ff       	call   801088f1 <walkpgdir>
8010906b:	83 c4 10             	add    $0x10,%esp
8010906e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109071:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109075:	75 0d                	jne    80109084 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
80109077:	83 ec 0c             	sub    $0xc,%esp
8010907a:	68 06 9a 10 80       	push   $0x80109a06
8010907f:	e8 e2 74 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
80109084:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109087:	8b 00                	mov    (%eax),%eax
80109089:	83 e0 01             	and    $0x1,%eax
8010908c:	85 c0                	test   %eax,%eax
8010908e:	75 0d                	jne    8010909d <copyuvm+0x6e>
      panic("copyuvm: page not present");
80109090:	83 ec 0c             	sub    $0xc,%esp
80109093:	68 20 9a 10 80       	push   $0x80109a20
80109098:	e8 c9 74 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
8010909d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090a0:	8b 00                	mov    (%eax),%eax
801090a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801090a7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801090aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090ad:	8b 00                	mov    (%eax),%eax
801090af:	25 ff 0f 00 00       	and    $0xfff,%eax
801090b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801090b7:	e8 48 9c ff ff       	call   80102d04 <kalloc>
801090bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
801090bf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801090c3:	74 6a                	je     8010912f <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
801090c5:	83 ec 0c             	sub    $0xc,%esp
801090c8:	ff 75 e8             	pushl  -0x18(%ebp)
801090cb:	e8 9f f3 ff ff       	call   8010846f <p2v>
801090d0:	83 c4 10             	add    $0x10,%esp
801090d3:	83 ec 04             	sub    $0x4,%esp
801090d6:	68 00 10 00 00       	push   $0x1000
801090db:	50                   	push   %eax
801090dc:	ff 75 e0             	pushl  -0x20(%ebp)
801090df:	e8 0c ce ff ff       	call   80105ef0 <memmove>
801090e4:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
801090e7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801090ea:	83 ec 0c             	sub    $0xc,%esp
801090ed:	ff 75 e0             	pushl  -0x20(%ebp)
801090f0:	e8 6d f3 ff ff       	call   80108462 <v2p>
801090f5:	83 c4 10             	add    $0x10,%esp
801090f8:	89 c2                	mov    %eax,%edx
801090fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090fd:	83 ec 0c             	sub    $0xc,%esp
80109100:	53                   	push   %ebx
80109101:	52                   	push   %edx
80109102:	68 00 10 00 00       	push   $0x1000
80109107:	50                   	push   %eax
80109108:	ff 75 f0             	pushl  -0x10(%ebp)
8010910b:	e8 81 f8 ff ff       	call   80108991 <mappages>
80109110:	83 c4 20             	add    $0x20,%esp
80109113:	85 c0                	test   %eax,%eax
80109115:	78 1b                	js     80109132 <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80109117:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010911e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109121:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109124:	0f 82 30 ff ff ff    	jb     8010905a <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
8010912a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010912d:	eb 17                	jmp    80109146 <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
8010912f:	90                   	nop
80109130:	eb 01                	jmp    80109133 <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
80109132:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80109133:	83 ec 0c             	sub    $0xc,%esp
80109136:	ff 75 f0             	pushl  -0x10(%ebp)
80109139:	e8 10 fe ff ff       	call   80108f4e <freevm>
8010913e:	83 c4 10             	add    $0x10,%esp
  return 0;
80109141:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109146:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109149:	c9                   	leave  
8010914a:	c3                   	ret    

8010914b <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010914b:	55                   	push   %ebp
8010914c:	89 e5                	mov    %esp,%ebp
8010914e:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109151:	83 ec 04             	sub    $0x4,%esp
80109154:	6a 00                	push   $0x0
80109156:	ff 75 0c             	pushl  0xc(%ebp)
80109159:	ff 75 08             	pushl  0x8(%ebp)
8010915c:	e8 90 f7 ff ff       	call   801088f1 <walkpgdir>
80109161:	83 c4 10             	add    $0x10,%esp
80109164:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80109167:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010916a:	8b 00                	mov    (%eax),%eax
8010916c:	83 e0 01             	and    $0x1,%eax
8010916f:	85 c0                	test   %eax,%eax
80109171:	75 07                	jne    8010917a <uva2ka+0x2f>
    return 0;
80109173:	b8 00 00 00 00       	mov    $0x0,%eax
80109178:	eb 29                	jmp    801091a3 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
8010917a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010917d:	8b 00                	mov    (%eax),%eax
8010917f:	83 e0 04             	and    $0x4,%eax
80109182:	85 c0                	test   %eax,%eax
80109184:	75 07                	jne    8010918d <uva2ka+0x42>
    return 0;
80109186:	b8 00 00 00 00       	mov    $0x0,%eax
8010918b:	eb 16                	jmp    801091a3 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
8010918d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109190:	8b 00                	mov    (%eax),%eax
80109192:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109197:	83 ec 0c             	sub    $0xc,%esp
8010919a:	50                   	push   %eax
8010919b:	e8 cf f2 ff ff       	call   8010846f <p2v>
801091a0:	83 c4 10             	add    $0x10,%esp
}
801091a3:	c9                   	leave  
801091a4:	c3                   	ret    

801091a5 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801091a5:	55                   	push   %ebp
801091a6:	89 e5                	mov    %esp,%ebp
801091a8:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801091ab:	8b 45 10             	mov    0x10(%ebp),%eax
801091ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801091b1:	eb 7f                	jmp    80109232 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
801091b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801091b6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801091bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801091be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091c1:	83 ec 08             	sub    $0x8,%esp
801091c4:	50                   	push   %eax
801091c5:	ff 75 08             	pushl  0x8(%ebp)
801091c8:	e8 7e ff ff ff       	call   8010914b <uva2ka>
801091cd:	83 c4 10             	add    $0x10,%esp
801091d0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801091d3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801091d7:	75 07                	jne    801091e0 <copyout+0x3b>
      return -1;
801091d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801091de:	eb 61                	jmp    80109241 <copyout+0x9c>
    n = PGSIZE - (va - va0);
801091e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091e3:	2b 45 0c             	sub    0xc(%ebp),%eax
801091e6:	05 00 10 00 00       	add    $0x1000,%eax
801091eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801091ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091f1:	3b 45 14             	cmp    0x14(%ebp),%eax
801091f4:	76 06                	jbe    801091fc <copyout+0x57>
      n = len;
801091f6:	8b 45 14             	mov    0x14(%ebp),%eax
801091f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801091fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801091ff:	2b 45 ec             	sub    -0x14(%ebp),%eax
80109202:	89 c2                	mov    %eax,%edx
80109204:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109207:	01 d0                	add    %edx,%eax
80109209:	83 ec 04             	sub    $0x4,%esp
8010920c:	ff 75 f0             	pushl  -0x10(%ebp)
8010920f:	ff 75 f4             	pushl  -0xc(%ebp)
80109212:	50                   	push   %eax
80109213:	e8 d8 cc ff ff       	call   80105ef0 <memmove>
80109218:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010921b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010921e:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80109221:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109224:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80109227:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010922a:	05 00 10 00 00       	add    $0x1000,%eax
8010922f:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80109232:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80109236:	0f 85 77 ff ff ff    	jne    801091b3 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010923c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109241:	c9                   	leave  
80109242:	c3                   	ret    

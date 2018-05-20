
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
8010003d:	68 2c 9f 10 80       	push   $0x80109f2c
80100042:	68 80 e6 10 80       	push   $0x8010e680
80100047:	e8 f5 67 00 00       	call   80106841 <initlock>
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
801000c1:	e8 9d 67 00 00       	call   80106863 <acquire>
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
8010010c:	e8 b9 67 00 00       	call   801068ca <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 80 e6 10 80       	push   $0x8010e680
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 6a 54 00 00       	call   80105596 <sleep>
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
80100188:	e8 3d 67 00 00       	call   801068ca <release>
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
801001aa:	68 33 9f 10 80       	push   $0x80109f33
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
80100204:	68 44 9f 10 80       	push   $0x80109f44
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
80100243:	68 4b 9f 10 80       	push   $0x80109f4b
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 80 e6 10 80       	push   $0x8010e680
80100255:	e8 09 66 00 00       	call   80106863 <acquire>
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
801002b9:	e8 4d 55 00 00       	call   8010580b <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 80 e6 10 80       	push   $0x8010e680
801002c9:	e8 fc 65 00 00       	call   801068ca <release>
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
801003e2:	e8 7c 64 00 00       	call   80106863 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 52 9f 10 80       	push   $0x80109f52
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
801004cd:	c7 45 ec 5b 9f 10 80 	movl   $0x80109f5b,-0x14(%ebp)
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
8010055b:	e8 6a 63 00 00       	call   801068ca <release>
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
8010058b:	68 62 9f 10 80       	push   $0x80109f62
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
801005aa:	68 71 9f 10 80       	push   $0x80109f71
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 55 63 00 00       	call   8010691c <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 73 9f 10 80       	push   $0x80109f73
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
801006ca:	68 77 9f 10 80       	push   $0x80109f77
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
801006f7:	e8 89 64 00 00       	call   80106b85 <memmove>
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
80100721:	e8 a0 63 00 00       	call   80106ac6 <memset>
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
801007b6:	e8 fa 7d 00 00       	call   801085b5 <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 ed 7d 00 00       	call   801085b5 <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 e0 7d 00 00       	call   801085b5 <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 d0 7d 00 00       	call   801085b5 <uartputc>
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
8010082a:	e8 34 60 00 00       	call   80106863 <acquire>
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
801009c8:	e8 3e 4e 00 00       	call   8010580b <wakeup>
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
801009eb:	e8 da 5e 00 00       	call   801068ca <release>
801009f0:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009f7:	74 05                	je     801009fe <consoleintr+0x205>
    procdump();  // now call procdump() wo. cons.lock held
801009f9:	e8 39 50 00 00       	call   80105a37 <procdump>
  }
#ifdef CS333_P3P4
  if(dopids) {
801009fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100a02:	74 05                	je     80100a09 <consoleintr+0x210>
    piddump();
80100a04:	e8 1a 57 00 00       	call   80106123 <piddump>
  }
  if(dofree) {
80100a09:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100a0d:	74 05                	je     80100a14 <consoleintr+0x21b>
    freedump();
80100a0f:	e8 e9 57 00 00       	call   801061fd <freedump>
  }
  if(dosleep) {
80100a14:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100a18:	74 05                	je     80100a1f <consoleintr+0x226>
    sleepdump();
80100a1a:	e8 41 58 00 00       	call   80106260 <sleepdump>
  }
  if(dozombie) {
80100a1f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a23:	74 05                	je     80100a2a <consoleintr+0x231>
    zombiedump();
80100a25:	e8 cf 58 00 00       	call   801062f9 <zombiedump>
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
80100a4f:	e8 0f 5e 00 00       	call   80106863 <acquire>
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
80100a71:	e8 54 5e 00 00       	call   801068ca <release>
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
80100a9e:	e8 f3 4a 00 00       	call   80105596 <sleep>
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
80100b1c:	e8 a9 5d 00 00       	call   801068ca <release>
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
80100b5a:	e8 04 5d 00 00       	call   80106863 <acquire>
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
80100b9c:	e8 29 5d 00 00       	call   801068ca <release>
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
80100bc0:	68 8a 9f 10 80       	push   $0x80109f8a
80100bc5:	68 e0 d5 10 80       	push   $0x8010d5e0
80100bca:	e8 72 5c 00 00       	call   80106841 <initlock>
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
80100c88:	e8 7d 8a 00 00       	call   8010970a <setupkvm>
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
80100d0e:	e8 9e 8d 00 00       	call   80109ab1 <allocuvm>
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
80100d41:	e8 94 8c 00 00       	call   801099da <loaduvm>
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
80100db0:	e8 fc 8c 00 00       	call   80109ab1 <allocuvm>
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
80100dd4:	e8 fe 8e 00 00       	call   80109cd7 <clearpteu>
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
80100e0d:	e8 01 5f 00 00       	call   80106d13 <strlen>
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
80100e3a:	e8 d4 5e 00 00       	call   80106d13 <strlen>
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
80100e60:	e8 29 90 00 00       	call   80109e8e <copyout>
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
80100efc:	e8 8d 8f 00 00       	call   80109e8e <copyout>
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
80100f4d:	e8 77 5d 00 00       	call   80106cc9 <safestrcpy>
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
80100fa3:	e8 49 88 00 00       	call   801097f1 <switchuvm>
80100fa8:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100fab:	83 ec 0c             	sub    $0xc,%esp
80100fae:	ff 75 d0             	pushl  -0x30(%ebp)
80100fb1:	e8 81 8c 00 00       	call   80109c37 <freevm>
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
80100feb:	e8 47 8c 00 00       	call   80109c37 <freevm>
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
8010101c:	68 92 9f 10 80       	push   $0x80109f92
80101021:	68 40 28 11 80       	push   $0x80112840
80101026:	e8 16 58 00 00       	call   80106841 <initlock>
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
8010103f:	e8 1f 58 00 00       	call   80106863 <acquire>
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
8010106c:	e8 59 58 00 00       	call   801068ca <release>
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
8010108f:	e8 36 58 00 00       	call   801068ca <release>
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
801010ac:	e8 b2 57 00 00       	call   80106863 <acquire>
801010b1:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b4:	8b 45 08             	mov    0x8(%ebp),%eax
801010b7:	8b 40 04             	mov    0x4(%eax),%eax
801010ba:	85 c0                	test   %eax,%eax
801010bc:	7f 0d                	jg     801010cb <filedup+0x2d>
    panic("filedup");
801010be:	83 ec 0c             	sub    $0xc,%esp
801010c1:	68 99 9f 10 80       	push   $0x80109f99
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
801010e2:	e8 e3 57 00 00       	call   801068ca <release>
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
801010fd:	e8 61 57 00 00       	call   80106863 <acquire>
80101102:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101105:	8b 45 08             	mov    0x8(%ebp),%eax
80101108:	8b 40 04             	mov    0x4(%eax),%eax
8010110b:	85 c0                	test   %eax,%eax
8010110d:	7f 0d                	jg     8010111c <fileclose+0x2d>
    panic("fileclose");
8010110f:	83 ec 0c             	sub    $0xc,%esp
80101112:	68 a1 9f 10 80       	push   $0x80109fa1
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
8010113d:	e8 88 57 00 00       	call   801068ca <release>
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
8010118b:	e8 3a 57 00 00       	call   801068ca <release>
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
801012da:	68 ab 9f 10 80       	push   $0x80109fab
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
801013dd:	68 b4 9f 10 80       	push   $0x80109fb4
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
80101413:	68 c4 9f 10 80       	push   $0x80109fc4
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
8010144b:	e8 35 57 00 00       	call   80106b85 <memmove>
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
80101491:	e8 30 56 00 00       	call   80106ac6 <memset>
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
801015f8:	68 d0 9f 10 80       	push   $0x80109fd0
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
8010168b:	68 e6 9f 10 80       	push   $0x80109fe6
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
801016e8:	68 f9 9f 10 80       	push   $0x80109ff9
801016ed:	68 60 32 11 80       	push   $0x80113260
801016f2:	e8 4a 51 00 00       	call   80106841 <initlock>
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
80101741:	68 00 a0 10 80       	push   $0x8010a000
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
801017ba:	e8 07 53 00 00       	call   80106ac6 <memset>
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
80101822:	68 53 a0 10 80       	push   $0x8010a053
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
801018c8:	e8 b8 52 00 00       	call   80106b85 <memmove>
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
801018fd:	e8 61 4f 00 00       	call   80106863 <acquire>
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
8010194b:	e8 7a 4f 00 00       	call   801068ca <release>
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
80101984:	68 65 a0 10 80       	push   $0x8010a065
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
801019c1:	e8 04 4f 00 00       	call   801068ca <release>
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
801019dc:	e8 82 4e 00 00       	call   80106863 <acquire>
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
801019fb:	e8 ca 4e 00 00       	call   801068ca <release>
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
80101a21:	68 75 a0 10 80       	push   $0x8010a075
80101a26:	e8 3b eb ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101a2b:	83 ec 0c             	sub    $0xc,%esp
80101a2e:	68 60 32 11 80       	push   $0x80113260
80101a33:	e8 2b 4e 00 00       	call   80106863 <acquire>
80101a38:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
80101a3b:	eb 13                	jmp    80101a50 <ilock+0x48>
    sleep(ip, &icache.lock);
80101a3d:	83 ec 08             	sub    $0x8,%esp
80101a40:	68 60 32 11 80       	push   $0x80113260
80101a45:	ff 75 08             	pushl  0x8(%ebp)
80101a48:	e8 49 3b 00 00       	call   80105596 <sleep>
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
80101a76:	e8 4f 4e 00 00       	call   801068ca <release>
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
80101b23:	e8 5d 50 00 00       	call   80106b85 <memmove>
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
80101b59:	68 7b a0 10 80       	push   $0x8010a07b
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
80101b8c:	68 8a a0 10 80       	push   $0x8010a08a
80101b91:	e8 d0 e9 ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101b96:	83 ec 0c             	sub    $0xc,%esp
80101b99:	68 60 32 11 80       	push   $0x80113260
80101b9e:	e8 c0 4c 00 00       	call   80106863 <acquire>
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
80101bbd:	e8 49 3c 00 00       	call   8010580b <wakeup>
80101bc2:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101bc5:	83 ec 0c             	sub    $0xc,%esp
80101bc8:	68 60 32 11 80       	push   $0x80113260
80101bcd:	e8 f8 4c 00 00       	call   801068ca <release>
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
80101be6:	e8 78 4c 00 00       	call   80106863 <acquire>
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
80101c2e:	68 92 a0 10 80       	push   $0x8010a092
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
80101c51:	e8 74 4c 00 00       	call   801068ca <release>
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
80101c86:	e8 d8 4b 00 00       	call   80106863 <acquire>
80101c8b:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101c8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c91:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101c98:	83 ec 0c             	sub    $0xc,%esp
80101c9b:	ff 75 08             	pushl  0x8(%ebp)
80101c9e:	e8 68 3b 00 00       	call   8010580b <wakeup>
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
80101cbd:	e8 08 4c 00 00       	call   801068ca <release>
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
80101dfd:	68 9c a0 10 80       	push   $0x8010a09c
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
80102094:	e8 ec 4a 00 00       	call   80106b85 <memmove>
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
801021e6:	e8 9a 49 00 00       	call   80106b85 <memmove>
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
80102266:	e8 b0 49 00 00       	call   80106c1b <strncmp>
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
80102286:	68 af a0 10 80       	push   $0x8010a0af
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
801022b5:	68 c1 a0 10 80       	push   $0x8010a0c1
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
8010238a:	68 c1 a0 10 80       	push   $0x8010a0c1
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
801023c5:	e8 a7 48 00 00       	call   80106c71 <strncpy>
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
801023f1:	68 ce a0 10 80       	push   $0x8010a0ce
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
80102467:	e8 19 47 00 00       	call   80106b85 <memmove>
8010246c:	83 c4 10             	add    $0x10,%esp
8010246f:	eb 26                	jmp    80102497 <skipelem+0x95>
  else {
    memmove(name, s, len);
80102471:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102474:	83 ec 04             	sub    $0x4,%esp
80102477:	50                   	push   %eax
80102478:	ff 75 f4             	pushl  -0xc(%ebp)
8010247b:	ff 75 0c             	pushl  0xc(%ebp)
8010247e:	e8 02 47 00 00       	call   80106b85 <memmove>
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
801026d3:	68 d6 a0 10 80       	push   $0x8010a0d6
801026d8:	68 20 d6 10 80       	push   $0x8010d620
801026dd:	e8 5f 41 00 00       	call   80106841 <initlock>
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
80102787:	68 da a0 10 80       	push   $0x8010a0da
8010278c:	e8 d5 dd ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE)
80102791:	8b 45 08             	mov    0x8(%ebp),%eax
80102794:	8b 40 08             	mov    0x8(%eax),%eax
80102797:	3d cf 07 00 00       	cmp    $0x7cf,%eax
8010279c:	76 0d                	jbe    801027ab <idestart+0x33>
    panic("incorrect blockno");
8010279e:	83 ec 0c             	sub    $0xc,%esp
801027a1:	68 e3 a0 10 80       	push   $0x8010a0e3
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
801027ca:	68 da a0 10 80       	push   $0x8010a0da
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
801028e4:	e8 7a 3f 00 00       	call   80106863 <acquire>
801028e9:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
801028ec:	a1 54 d6 10 80       	mov    0x8010d654,%eax
801028f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801028f8:	75 15                	jne    8010290f <ideintr+0x39>
    release(&idelock);
801028fa:	83 ec 0c             	sub    $0xc,%esp
801028fd:	68 20 d6 10 80       	push   $0x8010d620
80102902:	e8 c3 3f 00 00       	call   801068ca <release>
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
80102977:	e8 8f 2e 00 00       	call   8010580b <wakeup>
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
801029a1:	e8 24 3f 00 00       	call   801068ca <release>
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
801029c0:	68 f5 a0 10 80       	push   $0x8010a0f5
801029c5:	e8 9c db ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801029ca:	8b 45 08             	mov    0x8(%ebp),%eax
801029cd:	8b 00                	mov    (%eax),%eax
801029cf:	83 e0 06             	and    $0x6,%eax
801029d2:	83 f8 02             	cmp    $0x2,%eax
801029d5:	75 0d                	jne    801029e4 <iderw+0x39>
    panic("iderw: nothing to do");
801029d7:	83 ec 0c             	sub    $0xc,%esp
801029da:	68 09 a1 10 80       	push   $0x8010a109
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
801029fa:	68 1e a1 10 80       	push   $0x8010a11e
801029ff:	e8 62 db ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102a04:	83 ec 0c             	sub    $0xc,%esp
80102a07:	68 20 d6 10 80       	push   $0x8010d620
80102a0c:	e8 52 3e 00 00       	call   80106863 <acquire>
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
80102a68:	e8 29 2b 00 00       	call   80105596 <sleep>
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
80102a85:	e8 40 3e 00 00       	call   801068ca <release>
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
80102b16:	68 3c a1 10 80       	push   $0x8010a13c
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
80102bd6:	68 6e a1 10 80       	push   $0x8010a16e
80102bdb:	68 40 42 11 80       	push   $0x80114240
80102be0:	e8 5c 3c 00 00       	call   80106841 <initlock>
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
80102c79:	81 7d 08 5c 79 11 80 	cmpl   $0x8011795c,0x8(%ebp)
80102c80:	72 12                	jb     80102c94 <kfree+0x2d>
80102c82:	ff 75 08             	pushl  0x8(%ebp)
80102c85:	e8 36 ff ff ff       	call   80102bc0 <v2p>
80102c8a:	83 c4 04             	add    $0x4,%esp
80102c8d:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102c92:	76 0d                	jbe    80102ca1 <kfree+0x3a>
    panic("kfree");
80102c94:	83 ec 0c             	sub    $0xc,%esp
80102c97:	68 73 a1 10 80       	push   $0x8010a173
80102c9c:	e8 c5 d8 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102ca1:	83 ec 04             	sub    $0x4,%esp
80102ca4:	68 00 10 00 00       	push   $0x1000
80102ca9:	6a 01                	push   $0x1
80102cab:	ff 75 08             	pushl  0x8(%ebp)
80102cae:	e8 13 3e 00 00       	call   80106ac6 <memset>
80102cb3:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102cb6:	a1 74 42 11 80       	mov    0x80114274,%eax
80102cbb:	85 c0                	test   %eax,%eax
80102cbd:	74 10                	je     80102ccf <kfree+0x68>
    acquire(&kmem.lock);
80102cbf:	83 ec 0c             	sub    $0xc,%esp
80102cc2:	68 40 42 11 80       	push   $0x80114240
80102cc7:	e8 97 3b 00 00       	call   80106863 <acquire>
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
80102cf9:	e8 cc 3b 00 00       	call   801068ca <release>
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
80102d1b:	e8 43 3b 00 00       	call   80106863 <acquire>
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
80102d4c:	e8 79 3b 00 00       	call   801068ca <release>
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
80103097:	68 7c a1 10 80       	push   $0x8010a17c
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
801032c2:	e8 66 38 00 00       	call   80106b2d <memcmp>
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
801033d6:	68 a8 a1 10 80       	push   $0x8010a1a8
801033db:	68 80 42 11 80       	push   $0x80114280
801033e0:	e8 5c 34 00 00       	call   80106841 <initlock>
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
8010348b:	e8 f5 36 00 00       	call   80106b85 <memmove>
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
801035f9:	e8 65 32 00 00       	call   80106863 <acquire>
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
80103617:	e8 7a 1f 00 00       	call   80105596 <sleep>
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
8010364c:	e8 45 1f 00 00       	call   80105596 <sleep>
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
8010366b:	e8 5a 32 00 00       	call   801068ca <release>
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
8010368c:	e8 d2 31 00 00       	call   80106863 <acquire>
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
801036ad:	68 ac a1 10 80       	push   $0x8010a1ac
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
801036db:	e8 2b 21 00 00       	call   8010580b <wakeup>
801036e0:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801036e3:	83 ec 0c             	sub    $0xc,%esp
801036e6:	68 80 42 11 80       	push   $0x80114280
801036eb:	e8 da 31 00 00       	call   801068ca <release>
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
80103706:	e8 58 31 00 00       	call   80106863 <acquire>
8010370b:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010370e:	c7 05 c0 42 11 80 00 	movl   $0x0,0x801142c0
80103715:	00 00 00 
    wakeup(&log);
80103718:	83 ec 0c             	sub    $0xc,%esp
8010371b:	68 80 42 11 80       	push   $0x80114280
80103720:	e8 e6 20 00 00       	call   8010580b <wakeup>
80103725:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103728:	83 ec 0c             	sub    $0xc,%esp
8010372b:	68 80 42 11 80       	push   $0x80114280
80103730:	e8 95 31 00 00       	call   801068ca <release>
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
801037ac:	e8 d4 33 00 00       	call   80106b85 <memmove>
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
80103848:	68 bb a1 10 80       	push   $0x8010a1bb
8010384d:	e8 14 cd ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
80103852:	a1 bc 42 11 80       	mov    0x801142bc,%eax
80103857:	85 c0                	test   %eax,%eax
80103859:	7f 0d                	jg     80103868 <log_write+0x45>
    panic("log_write outside of trans");
8010385b:	83 ec 0c             	sub    $0xc,%esp
8010385e:	68 d1 a1 10 80       	push   $0x8010a1d1
80103863:	e8 fe cc ff ff       	call   80100566 <panic>

  acquire(&log.lock);
80103868:	83 ec 0c             	sub    $0xc,%esp
8010386b:	68 80 42 11 80       	push   $0x80114280
80103870:	e8 ee 2f 00 00       	call   80106863 <acquire>
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
801038ee:	e8 d7 2f 00 00       	call   801068ca <release>
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
80103946:	68 5c 79 11 80       	push   $0x8011795c
8010394b:	e8 7d f2 ff ff       	call   80102bcd <kinit1>
80103950:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103953:	e8 64 5e 00 00       	call   801097bc <kvmalloc>
  mpinit();        // collect info about this machine
80103958:	e8 43 04 00 00       	call   80103da0 <mpinit>
  lapicinit();
8010395d:	e8 ea f5 ff ff       	call   80102f4c <lapicinit>
  seginit();       // set up segments
80103962:	e8 fe 57 00 00       	call   80109165 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103967:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010396d:	0f b6 00             	movzbl (%eax),%eax
80103970:	0f b6 c0             	movzbl %al,%eax
80103973:	83 ec 08             	sub    $0x8,%esp
80103976:	50                   	push   %eax
80103977:	68 ec a1 10 80       	push   $0x8010a1ec
8010397c:	e8 45 ca ff ff       	call   801003c6 <cprintf>
80103981:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
80103984:	e8 6d 06 00 00       	call   80103ff6 <picinit>
  ioapicinit();    // another interrupt controller
80103989:	e8 34 f1 ff ff       	call   80102ac2 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010398e:	e8 24 d2 ff ff       	call   80100bb7 <consoleinit>
  uartinit();      // serial port
80103993:	e8 29 4b 00 00       	call   801084c1 <uartinit>
  pinit();         // process table
80103998:	e8 5d 0b 00 00       	call   801044fa <pinit>
  tvinit();        // trap vectors
8010399d:	e8 f8 46 00 00       	call   8010809a <tvinit>
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
801039ba:	e8 2c 46 00 00       	call   80107feb <timerinit>
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
801039e9:	e8 e6 5d 00 00       	call   801097d4 <switchkvm>
  seginit();
801039ee:	e8 72 57 00 00       	call   80109165 <seginit>
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
80103a13:	68 03 a2 10 80       	push   $0x8010a203
80103a18:	e8 a9 c9 ff ff       	call   801003c6 <cprintf>
80103a1d:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103a20:	e8 d6 47 00 00       	call   801081fb <idtinit>
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
80103a6b:	e8 15 31 00 00       	call   80106b85 <memmove>
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
80103bf9:	68 14 a2 10 80       	push   $0x8010a214
80103bfe:	ff 75 f4             	pushl  -0xc(%ebp)
80103c01:	e8 27 2f 00 00       	call   80106b2d <memcmp>
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
80103d37:	68 19 a2 10 80       	push   $0x8010a219
80103d3c:	ff 75 f0             	pushl  -0x10(%ebp)
80103d3f:	e8 e9 2d 00 00       	call   80106b2d <memcmp>
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
80103e13:	8b 04 85 5c a2 10 80 	mov    -0x7fef5da4(,%eax,4),%eax
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
80103e49:	68 1e a2 10 80       	push   $0x8010a21e
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
80103edc:	68 3c a2 10 80       	push   $0x8010a23c
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
8010417d:	68 70 a2 10 80       	push   $0x8010a270
80104182:	50                   	push   %eax
80104183:	e8 b9 26 00 00       	call   80106841 <initlock>
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
8010423f:	e8 1f 26 00 00       	call   80106863 <acquire>
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
80104266:	e8 a0 15 00 00       	call   8010580b <wakeup>
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
80104289:	e8 7d 15 00 00       	call   8010580b <wakeup>
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
801042b2:	e8 13 26 00 00       	call   801068ca <release>
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
801042d1:	e8 f4 25 00 00       	call   801068ca <release>
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
801042e9:	e8 75 25 00 00       	call   80106863 <acquire>
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
8010431e:	e8 a7 25 00 00       	call   801068ca <release>
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
8010433c:	e8 ca 14 00 00       	call   8010580b <wakeup>
80104341:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104344:	8b 45 08             	mov    0x8(%ebp),%eax
80104347:	8b 55 08             	mov    0x8(%ebp),%edx
8010434a:	81 c2 38 02 00 00    	add    $0x238,%edx
80104350:	83 ec 08             	sub    $0x8,%esp
80104353:	50                   	push   %eax
80104354:	52                   	push   %edx
80104355:	e8 3c 12 00 00       	call   80105596 <sleep>
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
801043be:	e8 48 14 00 00       	call   8010580b <wakeup>
801043c3:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801043c6:	8b 45 08             	mov    0x8(%ebp),%eax
801043c9:	83 ec 0c             	sub    $0xc,%esp
801043cc:	50                   	push   %eax
801043cd:	e8 f8 24 00 00       	call   801068ca <release>
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
801043e8:	e8 76 24 00 00       	call   80106863 <acquire>
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
80104406:	e8 bf 24 00 00       	call   801068ca <release>
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
80104429:	e8 68 11 00 00       	call   80105596 <sleep>
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
801044bd:	e8 49 13 00 00       	call   8010580b <wakeup>
801044c2:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801044c5:	8b 45 08             	mov    0x8(%ebp),%eax
801044c8:	83 ec 0c             	sub    $0xc,%esp
801044cb:	50                   	push   %eax
801044cc:	e8 f9 23 00 00       	call   801068ca <release>
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
80104503:	68 78 a2 10 80       	push   $0x8010a278
80104508:	68 80 49 11 80       	push   $0x80114980
8010450d:	e8 2f 23 00 00       	call   80106841 <initlock>
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
80104526:	e8 38 23 00 00       	call   80106863 <acquire>
8010452b:	83 c4 10             	add    $0x10,%esp
#ifndef CS333_P3P4
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
#else
  p = ptable.pLists.free;
8010452e:	a1 c4 70 11 80       	mov    0x801170c4,%eax
80104533:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p)
80104536:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010453a:	75 1a                	jne    80104556 <allocproc+0x3e>
    goto found;
#endif
  release(&ptable.lock);
8010453c:	83 ec 0c             	sub    $0xc,%esp
8010453f:	68 80 49 11 80       	push   $0x80114980
80104544:	e8 81 23 00 00       	call   801068ca <release>
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
80104567:	68 c8 70 11 80       	push   $0x801170c8
8010456c:	68 c4 70 11 80       	push   $0x801170c4
80104571:	e8 db 17 00 00       	call   80105d51 <stateListRemove>
80104576:	83 c4 10             	add    $0x10,%esp
80104579:	85 c0                	test   %eax,%eax
8010457b:	74 0d                	je     8010458a <allocproc+0x72>
    panic("error removing from free list.");
8010457d:	83 ec 0c             	sub    $0xc,%esp
80104580:	68 80 a2 10 80       	push   $0x8010a280
80104585:	e8 dc bf ff ff       	call   80100566 <panic>
  if(stateListAdd(&ptable.pLists.embryo, &ptable.pLists.embryoTail,p))
8010458a:	83 ec 04             	sub    $0x4,%esp
8010458d:	ff 75 f4             	pushl  -0xc(%ebp)
80104590:	68 e8 70 11 80       	push   $0x801170e8
80104595:	68 e4 70 11 80       	push   $0x801170e4
8010459a:	e8 53 17 00 00       	call   80105cf2 <stateListAdd>
8010459f:	83 c4 10             	add    $0x10,%esp
801045a2:	85 c0                	test   %eax,%eax
801045a4:	74 0d                	je     801045b3 <allocproc+0x9b>
    panic("error adding to embryo list.");
801045a6:	83 ec 0c             	sub    $0xc,%esp
801045a9:	68 9f a2 10 80       	push   $0x8010a29f
801045ae:	e8 b3 bf ff ff       	call   80100566 <panic>
  assertState(p, EMBRYO);
801045b3:	83 ec 08             	sub    $0x8,%esp
801045b6:	6a 01                	push   $0x1
801045b8:	ff 75 f4             	pushl  -0xc(%ebp)
801045bb:	e8 ee 1d 00 00       	call   801063ae <assertState>
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
801045d9:	8b 15 00 79 11 80    	mov    0x80117900,%edx
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
8010463b:	e8 8a 22 00 00       	call   801068ca <release>
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
8010466a:	68 e8 70 11 80       	push   $0x801170e8
8010466f:	68 e4 70 11 80       	push   $0x801170e4
80104674:	e8 d8 16 00 00       	call   80105d51 <stateListRemove>
80104679:	83 c4 10             	add    $0x10,%esp
8010467c:	85 c0                	test   %eax,%eax
8010467e:	74 0d                	je     8010468d <allocproc+0x175>
      panic("error removing from embryo list.");
80104680:	83 ec 0c             	sub    $0xc,%esp
80104683:	68 bc a2 10 80       	push   $0x8010a2bc
80104688:	e8 d9 be ff ff       	call   80100566 <panic>
    if(stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail,p))
8010468d:	83 ec 04             	sub    $0x4,%esp
80104690:	ff 75 f4             	pushl  -0xc(%ebp)
80104693:	68 c8 70 11 80       	push   $0x801170c8
80104698:	68 c4 70 11 80       	push   $0x801170c4
8010469d:	e8 50 16 00 00       	call   80105cf2 <stateListAdd>
801046a2:	83 c4 10             	add    $0x10,%esp
801046a5:	85 c0                	test   %eax,%eax
801046a7:	74 0d                	je     801046b6 <allocproc+0x19e>
      panic("error adding to free list.");
801046a9:	83 ec 0c             	sub    $0xc,%esp
801046ac:	68 dd a2 10 80       	push   $0x8010a2dd
801046b1:	e8 b0 be ff ff       	call   80100566 <panic>
    assertState(p, UNUSED);
801046b6:	83 ec 08             	sub    $0x8,%esp
801046b9:	6a 00                	push   $0x0
801046bb:	ff 75 f4             	pushl  -0xc(%ebp)
801046be:	e8 eb 1c 00 00       	call   801063ae <assertState>
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
801046ec:	ba 48 80 10 80       	mov    $0x80108048,%edx
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
80104711:	e8 b0 23 00 00       	call   80106ac6 <memset>
80104716:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104719:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010471c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010471f:	ba 50 55 10 80       	mov    $0x80105550,%edx
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
8010473a:	e8 24 21 00 00       	call   80106863 <acquire>
8010473f:	83 c4 10             	add    $0x10,%esp
  initProcessLists();
80104742:	e8 d9 16 00 00       	call   80105e20 <initProcessLists>
  initFreeList();
80104747:	e8 7a 17 00 00       	call   80105ec6 <initFreeList>
  ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
8010474c:	a1 00 79 11 80       	mov    0x80117900,%eax
80104751:	05 f4 01 00 00       	add    $0x1f4,%eax
80104756:	a3 ec 70 11 80       	mov    %eax,0x801170ec
  release(&ptable.lock);
8010475b:	83 ec 0c             	sub    $0xc,%esp
8010475e:	68 80 49 11 80       	push   $0x80114980
80104763:	e8 62 21 00 00       	call   801068ca <release>
80104768:	83 c4 10             	add    $0x10,%esp
#endif
  p = allocproc();
8010476b:	e8 a8 fd ff ff       	call   80104518 <allocproc>
80104770:	89 45 f4             	mov    %eax,-0xc(%ebp)

  initproc = p;
80104773:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104776:	a3 68 d6 10 80       	mov    %eax,0x8010d668
  if((p->pgdir = setupkvm()) == 0)
8010477b:	e8 8a 4f 00 00       	call   8010970a <setupkvm>
80104780:	89 c2                	mov    %eax,%edx
80104782:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104785:	89 50 04             	mov    %edx,0x4(%eax)
80104788:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010478b:	8b 40 04             	mov    0x4(%eax),%eax
8010478e:	85 c0                	test   %eax,%eax
80104790:	75 0d                	jne    8010479f <userinit+0x73>
    panic("userinit: out of memory?");
80104792:	83 ec 0c             	sub    $0xc,%esp
80104795:	68 f8 a2 10 80       	push   $0x8010a2f8
8010479a:	e8 c7 bd ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010479f:	ba 2c 00 00 00       	mov    $0x2c,%edx
801047a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047a7:	8b 40 04             	mov    0x4(%eax),%eax
801047aa:	83 ec 04             	sub    $0x4,%esp
801047ad:	52                   	push   %edx
801047ae:	68 00 d5 10 80       	push   $0x8010d500
801047b3:	50                   	push   %eax
801047b4:	e8 ab 51 00 00       	call   80109964 <inituvm>
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
801047d3:	e8 ee 22 00 00       	call   80106ac6 <memset>
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
8010484d:	68 11 a3 10 80       	push   $0x8010a311
80104852:	50                   	push   %eax
80104853:	e8 71 24 00 00       	call   80106cc9 <safestrcpy>
80104858:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
8010485b:	83 ec 0c             	sub    $0xc,%esp
8010485e:	68 1a a3 10 80       	push   $0x8010a31a
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
80104885:	e8 d9 1f 00 00       	call   80106863 <acquire>
8010488a:	83 c4 10             	add    $0x10,%esp
  if(stateListRemove(&ptable.pLists.embryo, &ptable.pLists.embryoTail, p))
8010488d:	83 ec 04             	sub    $0x4,%esp
80104890:	ff 75 f4             	pushl  -0xc(%ebp)
80104893:	68 e8 70 11 80       	push   $0x801170e8
80104898:	68 e4 70 11 80       	push   $0x801170e4
8010489d:	e8 af 14 00 00       	call   80105d51 <stateListRemove>
801048a2:	83 c4 10             	add    $0x10,%esp
801048a5:	85 c0                	test   %eax,%eax
801048a7:	74 0d                	je     801048b6 <userinit+0x18a>
    panic("error removing from embryo list.");
801048a9:	83 ec 0c             	sub    $0xc,%esp
801048ac:	68 bc a2 10 80       	push   $0x8010a2bc
801048b1:	e8 b0 bc ff ff       	call   80100566 <panic>
  if(stateListAdd(&ptable.pLists.ready[p->priority], &ptable.pLists.readyTail[p->priority], p))
801048b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b9:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801048bf:	05 cc 09 00 00       	add    $0x9cc,%eax
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
801048f0:	e8 fd 13 00 00       	call   80105cf2 <stateListAdd>
801048f5:	83 c4 10             	add    $0x10,%esp
801048f8:	85 c0                	test   %eax,%eax
801048fa:	74 0d                	je     80104909 <userinit+0x1dd>
    panic("error adding to ready list.");
801048fc:	83 ec 0c             	sub    $0xc,%esp
801048ff:	68 1c a3 10 80       	push   $0x8010a31c
80104904:	e8 5d bc ff ff       	call   80100566 <panic>
  assertState(p, RUNNABLE);
80104909:	83 ec 08             	sub    $0x8,%esp
8010490c:	6a 03                	push   $0x3
8010490e:	ff 75 f4             	pushl  -0xc(%ebp)
80104911:	e8 98 1a 00 00       	call   801063ae <assertState>
80104916:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104919:	83 ec 0c             	sub    $0xc,%esp
8010491c:	68 80 49 11 80       	push   $0x80114980
80104921:	e8 a4 1f 00 00       	call   801068ca <release>
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
80104976:	e8 36 51 00 00       	call   80109ab1 <allocuvm>
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
801049ad:	e8 c8 51 00 00       	call   80109b7a <deallocuvm>
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
801049da:	e8 12 4e 00 00       	call   801097f1 <switchuvm>
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
80104a20:	e8 f3 52 00 00       	call   80109d18 <copyuvm>
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
80104a6c:	e8 f2 1d 00 00       	call   80106863 <acquire>
80104a71:	83 c4 10             	add    $0x10,%esp
    if(stateListRemove(&ptable.pLists.embryo, &ptable.pLists.embryoTail, np))
80104a74:	83 ec 04             	sub    $0x4,%esp
80104a77:	ff 75 e0             	pushl  -0x20(%ebp)
80104a7a:	68 e8 70 11 80       	push   $0x801170e8
80104a7f:	68 e4 70 11 80       	push   $0x801170e4
80104a84:	e8 c8 12 00 00       	call   80105d51 <stateListRemove>
80104a89:	83 c4 10             	add    $0x10,%esp
80104a8c:	85 c0                	test   %eax,%eax
80104a8e:	74 0d                	je     80104a9d <fork+0xb4>
      panic("error removing from embryo.");
80104a90:	83 ec 0c             	sub    $0xc,%esp
80104a93:	68 38 a3 10 80       	push   $0x8010a338
80104a98:	e8 c9 ba ff ff       	call   80100566 <panic>
    if(stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail, np))
80104a9d:	83 ec 04             	sub    $0x4,%esp
80104aa0:	ff 75 e0             	pushl  -0x20(%ebp)
80104aa3:	68 c8 70 11 80       	push   $0x801170c8
80104aa8:	68 c4 70 11 80       	push   $0x801170c4
80104aad:	e8 40 12 00 00       	call   80105cf2 <stateListAdd>
80104ab2:	83 c4 10             	add    $0x10,%esp
80104ab5:	85 c0                	test   %eax,%eax
80104ab7:	74 0d                	je     80104ac6 <fork+0xdd>
      panic("error adding to freelist.");
80104ab9:	83 ec 0c             	sub    $0xc,%esp
80104abc:	68 54 a3 10 80       	push   $0x8010a354
80104ac1:	e8 a0 ba ff ff       	call   80100566 <panic>
    assertState(np, UNUSED);
80104ac6:	83 ec 08             	sub    $0x8,%esp
80104ac9:	6a 00                	push   $0x0
80104acb:	ff 75 e0             	pushl  -0x20(%ebp)
80104ace:	e8 db 18 00 00       	call   801063ae <assertState>
80104ad3:	83 c4 10             	add    $0x10,%esp
    release(&ptable.lock);
80104ad6:	83 ec 0c             	sub    $0xc,%esp
80104ad9:	68 80 49 11 80       	push   $0x80114980
80104ade:	e8 e7 1d 00 00       	call   801068ca <release>
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
80104bba:	e8 0a 21 00 00       	call   80106cc9 <safestrcpy>
80104bbf:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104bc2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104bc5:	8b 40 10             	mov    0x10(%eax),%eax
80104bc8:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104bcb:	83 ec 0c             	sub    $0xc,%esp
80104bce:	68 80 49 11 80       	push   $0x80114980
80104bd3:	e8 8b 1c 00 00       	call   80106863 <acquire>
80104bd8:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
80104bdb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104bde:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
#ifdef CS333_P3P4
  if(stateListRemove(&ptable.pLists.embryo, &ptable.pLists.embryoTail, np))
80104be5:	83 ec 04             	sub    $0x4,%esp
80104be8:	ff 75 e0             	pushl  -0x20(%ebp)
80104beb:	68 e8 70 11 80       	push   $0x801170e8
80104bf0:	68 e4 70 11 80       	push   $0x801170e4
80104bf5:	e8 57 11 00 00       	call   80105d51 <stateListRemove>
80104bfa:	83 c4 10             	add    $0x10,%esp
80104bfd:	85 c0                	test   %eax,%eax
80104bff:	74 0d                	je     80104c0e <fork+0x225>
    panic("error removing from embryo.");
80104c01:	83 ec 0c             	sub    $0xc,%esp
80104c04:	68 38 a3 10 80       	push   $0x8010a338
80104c09:	e8 58 b9 ff ff       	call   80100566 <panic>
  if(stateListAdd(&ptable.pLists.ready[np->priority], &ptable.pLists.readyTail[np->priority], np))
80104c0e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c11:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80104c17:	05 cc 09 00 00       	add    $0x9cc,%eax
80104c1c:	c1 e0 02             	shl    $0x2,%eax
80104c1f:	05 80 49 11 80       	add    $0x80114980,%eax
80104c24:	8d 50 0c             	lea    0xc(%eax),%edx
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
80104c48:	e8 a5 10 00 00       	call   80105cf2 <stateListAdd>
80104c4d:	83 c4 10             	add    $0x10,%esp
80104c50:	85 c0                	test   %eax,%eax
80104c52:	74 0d                	je     80104c61 <fork+0x278>
    panic("error adding to ready list.");
80104c54:	83 ec 0c             	sub    $0xc,%esp
80104c57:	68 1c a3 10 80       	push   $0x8010a31c
80104c5c:	e8 05 b9 ff ff       	call   80100566 <panic>
  assertState(np, RUNNABLE);
80104c61:	83 ec 08             	sub    $0x8,%esp
80104c64:	6a 03                	push   $0x3
80104c66:	ff 75 e0             	pushl  -0x20(%ebp)
80104c69:	e8 40 17 00 00       	call   801063ae <assertState>
80104c6e:	83 c4 10             	add    $0x10,%esp
#endif
  release(&ptable.lock);
80104c71:	83 ec 0c             	sub    $0xc,%esp
80104c74:	68 80 49 11 80       	push   $0x80114980
80104c79:	e8 4c 1c 00 00       	call   801068ca <release>
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
80104ccf:	68 6e a3 10 80       	push   $0x8010a36e
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
80104d64:	e8 fa 1a 00 00       	call   80106863 <acquire>
80104d69:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104d6c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d72:	8b 40 14             	mov    0x14(%eax),%eax
80104d75:	83 ec 0c             	sub    $0xc,%esp
80104d78:	50                   	push   %eax
80104d79:	e8 bc 09 00 00       	call   8010573a <wakeup1>
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
80104dd0:	83 7d ec 01          	cmpl   $0x1,-0x14(%ebp)
80104dd4:	7e b4                	jle    80104d8a <exit+0xd4>
    {
      if(p->parent == proc)
        p->parent = initproc;
    }
  }
  for(p = ptable.pLists.sleep;p;p=p->next)
80104dd6:	a1 cc 70 11 80       	mov    0x801170cc,%eax
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
80104e0e:	a1 e4 70 11 80       	mov    0x801170e4,%eax
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
80104e46:	a1 dc 70 11 80       	mov    0x801170dc,%eax
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
80104e95:	68 e0 70 11 80       	push   $0x801170e0
80104e9a:	68 dc 70 11 80       	push   $0x801170dc
80104e9f:	e8 ad 0e 00 00       	call   80105d51 <stateListRemove>
80104ea4:	83 c4 10             	add    $0x10,%esp
80104ea7:	85 c0                	test   %eax,%eax
80104ea9:	74 0d                	je     80104eb8 <exit+0x202>
    panic("Error removing from running.");
80104eab:	83 ec 0c             	sub    $0xc,%esp
80104eae:	68 7b a3 10 80       	push   $0x8010a37b
80104eb3:	e8 ae b6 ff ff       	call   80100566 <panic>
  if(stateListAdd(&ptable.pLists.zombie, &ptable.pLists.zombieTail, proc))
80104eb8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ebe:	83 ec 04             	sub    $0x4,%esp
80104ec1:	50                   	push   %eax
80104ec2:	68 d8 70 11 80       	push   $0x801170d8
80104ec7:	68 d4 70 11 80       	push   $0x801170d4
80104ecc:	e8 21 0e 00 00       	call   80105cf2 <stateListAdd>
80104ed1:	83 c4 10             	add    $0x10,%esp
80104ed4:	85 c0                	test   %eax,%eax
80104ed6:	74 0d                	je     80104ee5 <exit+0x22f>
    panic("error adding to zombie list.");
80104ed8:	83 ec 0c             	sub    $0xc,%esp
80104edb:	68 98 a3 10 80       	push   $0x8010a398
80104ee0:	e8 81 b6 ff ff       	call   80100566 <panic>
  assertState(proc, ZOMBIE);
80104ee5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104eeb:	83 ec 08             	sub    $0x8,%esp
80104eee:	6a 05                	push   $0x5
80104ef0:	50                   	push   %eax
80104ef1:	e8 b8 14 00 00       	call   801063ae <assertState>
80104ef6:	83 c4 10             	add    $0x10,%esp
  sched();
80104ef9:	e8 48 04 00 00       	call   80105346 <sched>
  panic("zombie exit");
80104efe:	83 ec 0c             	sub    $0xc,%esp
80104f01:	68 b5 a3 10 80       	push   $0x8010a3b5
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
80104f19:	e8 45 19 00 00       	call   80106863 <acquire>
80104f1e:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104f21:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.pLists.zombie; p; p=p->next){
80104f28:	a1 d4 70 11 80       	mov    0x801170d4,%eax
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
80104f8c:	e8 a6 4c 00 00       	call   80109c37 <freevm>
80104f91:	83 c4 10             	add    $0x10,%esp
      p->state = UNUSED;
80104f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f97:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
      if(stateListRemove(&ptable.pLists.zombie, &ptable.pLists.zombieTail,p))
80104f9e:	83 ec 04             	sub    $0x4,%esp
80104fa1:	ff 75 f4             	pushl  -0xc(%ebp)
80104fa4:	68 d8 70 11 80       	push   $0x801170d8
80104fa9:	68 d4 70 11 80       	push   $0x801170d4
80104fae:	e8 9e 0d 00 00       	call   80105d51 <stateListRemove>
80104fb3:	83 c4 10             	add    $0x10,%esp
80104fb6:	85 c0                	test   %eax,%eax
80104fb8:	74 0d                	je     80104fc7 <wait+0xbc>
        panic("Error removing from zombie list.");
80104fba:	83 ec 0c             	sub    $0xc,%esp
80104fbd:	68 c4 a3 10 80       	push   $0x8010a3c4
80104fc2:	e8 9f b5 ff ff       	call   80100566 <panic>
      if(stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail,p))
80104fc7:	83 ec 04             	sub    $0x4,%esp
80104fca:	ff 75 f4             	pushl  -0xc(%ebp)
80104fcd:	68 c8 70 11 80       	push   $0x801170c8
80104fd2:	68 c4 70 11 80       	push   $0x801170c4
80104fd7:	e8 16 0d 00 00       	call   80105cf2 <stateListAdd>
80104fdc:	83 c4 10             	add    $0x10,%esp
80104fdf:	85 c0                	test   %eax,%eax
80104fe1:	74 0d                	je     80104ff0 <wait+0xe5>
        panic("Error adding to free list.");
80104fe3:	83 ec 0c             	sub    $0xc,%esp
80104fe6:	68 e5 a3 10 80       	push   $0x8010a3e5
80104feb:	e8 76 b5 ff ff       	call   80100566 <panic>
      assertState(p, UNUSED);
80104ff0:	83 ec 08             	sub    $0x8,%esp
80104ff3:	6a 00                	push   $0x0
80104ff5:	ff 75 f4             	pushl  -0xc(%ebp)
80104ff8:	e8 b1 13 00 00       	call   801063ae <assertState>
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
8010502d:	e8 98 18 00 00       	call   801068ca <release>
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
80105096:	83 7d ec 01          	cmpl   $0x1,-0x14(%ebp)
8010509a:	7e b4                	jle    80105050 <wait+0x145>
          havekids = 1;
          goto kids;
        }
      }
    }
    for(p = ptable.pLists.sleep;p;p=p->next)
8010509c:	a1 cc 70 11 80       	mov    0x801170cc,%eax
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
801050d1:	a1 e4 70 11 80       	mov    0x801170e4,%eax
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
80105106:	a1 dc 70 11 80       	mov    0x801170dc,%eax
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
80105156:	e8 6f 17 00 00       	call   801068ca <release>
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
80105174:	e8 1d 04 00 00       	call   80105596 <sleep>
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
8010519d:	e8 c1 16 00 00       	call   80106863 <acquire>
801051a2:	83 c4 10             	add    $0x10,%esp
    if(ticks >= ptable.PromoteAtTime)
801051a5:	8b 15 ec 70 11 80    	mov    0x801170ec,%edx
801051ab:	a1 00 79 11 80       	mov    0x80117900,%eax
801051b0:	39 c2                	cmp    %eax,%edx
801051b2:	77 14                	ja     801051c8 <scheduler+0x45>
    {
      promoteAll();
801051b4:	e8 7a 14 00 00       	call   80106633 <promoteAll>
      ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
801051b9:	a1 00 79 11 80       	mov    0x80117900,%eax
801051be:	05 f4 01 00 00       	add    $0x1f4,%eax
801051c3:	a3 ec 70 11 80       	mov    %eax,0x801170ec
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
80105201:	e8 eb 45 00 00       	call   801097f1 <switchuvm>
80105206:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNING;
80105209:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010520c:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
        if(stateListRemove(&ptable.pLists.ready[i], &ptable.pLists.readyTail[i], p))
80105213:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105216:	05 cc 09 00 00       	add    $0x9cc,%eax
8010521b:	c1 e0 02             	shl    $0x2,%eax
8010521e:	05 80 49 11 80       	add    $0x80114980,%eax
80105223:	8d 50 0c             	lea    0xc(%eax),%edx
80105226:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105229:	05 cc 09 00 00       	add    $0x9cc,%eax
8010522e:	c1 e0 02             	shl    $0x2,%eax
80105231:	05 80 49 11 80       	add    $0x80114980,%eax
80105236:	83 c0 04             	add    $0x4,%eax
80105239:	83 ec 04             	sub    $0x4,%esp
8010523c:	ff 75 f4             	pushl  -0xc(%ebp)
8010523f:	52                   	push   %edx
80105240:	50                   	push   %eax
80105241:	e8 0b 0b 00 00       	call   80105d51 <stateListRemove>
80105246:	83 c4 10             	add    $0x10,%esp
80105249:	85 c0                	test   %eax,%eax
8010524b:	74 0d                	je     8010525a <scheduler+0xd7>
          panic("problem with removing from ready list.");
8010524d:	83 ec 0c             	sub    $0xc,%esp
80105250:	68 00 a4 10 80       	push   $0x8010a400
80105255:	e8 0c b3 ff ff       	call   80100566 <panic>
        if(stateListAdd(&ptable.pLists.running, &ptable.pLists.runningTail, p))
8010525a:	83 ec 04             	sub    $0x4,%esp
8010525d:	ff 75 f4             	pushl  -0xc(%ebp)
80105260:	68 e0 70 11 80       	push   $0x801170e0
80105265:	68 dc 70 11 80       	push   $0x801170dc
8010526a:	e8 83 0a 00 00       	call   80105cf2 <stateListAdd>
8010526f:	83 c4 10             	add    $0x10,%esp
80105272:	85 c0                	test   %eax,%eax
80105274:	74 0d                	je     80105283 <scheduler+0x100>
          panic("problem with adding to running list.");
80105276:	83 ec 0c             	sub    $0xc,%esp
80105279:	68 28 a4 10 80       	push   $0x8010a428
8010527e:	e8 e3 b2 ff ff       	call   80100566 <panic>
        assertState(p, RUNNING);
80105283:	83 ec 08             	sub    $0x8,%esp
80105286:	6a 04                	push   $0x4
80105288:	ff 75 f4             	pushl  -0xc(%ebp)
8010528b:	e8 1e 11 00 00       	call   801063ae <assertState>
80105290:	83 c4 10             	add    $0x10,%esp

        p->cpu_ticks_in = ticks;
80105293:	8b 15 00 79 11 80    	mov    0x80117900,%edx
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
801052ba:	e8 7b 1a 00 00       	call   80106d3a <swtch>
801052bf:	83 c4 10             	add    $0x10,%esp

        p->cpu_ticks_total = p->cpu_ticks_total + (ticks - p->cpu_ticks_in);
801052c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052c5:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
801052cb:	8b 0d 00 79 11 80    	mov    0x80117900,%ecx
801052d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052d4:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
801052da:	29 c1                	sub    %eax,%ecx
801052dc:	89 c8                	mov    %ecx,%eax
801052de:	01 c2                	add    %eax,%edx
801052e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052e3:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
        switchkvm();
801052e9:	e8 e6 44 00 00       	call   801097d4 <switchkvm>

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
80105313:	83 7d ec 01          	cmpl   $0x1,-0x14(%ebp)
80105317:	0f 8e b7 fe ff ff    	jle    801051d4 <scheduler+0x51>
        // Process is done running for now.
        // It should have changed its p->state before coming back.
        proc = 0;
      }
    }
    release(&ptable.lock);
8010531d:	83 ec 0c             	sub    $0xc,%esp
80105320:	68 80 49 11 80       	push   $0x80114980
80105325:	e8 a0 15 00 00       	call   801068ca <release>
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
80105354:	e8 3d 16 00 00       	call   80106996 <holding>
80105359:	83 c4 10             	add    $0x10,%esp
8010535c:	85 c0                	test   %eax,%eax
8010535e:	75 0d                	jne    8010536d <sched+0x27>
    panic("sched ptable.lock");
80105360:	83 ec 0c             	sub    $0xc,%esp
80105363:	68 4d a4 10 80       	push   $0x8010a44d
80105368:	e8 f9 b1 ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
8010536d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105373:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105379:	83 f8 01             	cmp    $0x1,%eax
8010537c:	74 0d                	je     8010538b <sched+0x45>
    panic("sched locks");
8010537e:	83 ec 0c             	sub    $0xc,%esp
80105381:	68 5f a4 10 80       	push   $0x8010a45f
80105386:	e8 db b1 ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
8010538b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105391:	8b 40 0c             	mov    0xc(%eax),%eax
80105394:	83 f8 04             	cmp    $0x4,%eax
80105397:	75 0d                	jne    801053a6 <sched+0x60>
    panic("sched running");
80105399:	83 ec 0c             	sub    $0xc,%esp
8010539c:	68 6b a4 10 80       	push   $0x8010a46b
801053a1:	e8 c0 b1 ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
801053a6:	e8 38 f1 ff ff       	call   801044e3 <readeflags>
801053ab:	25 00 02 00 00       	and    $0x200,%eax
801053b0:	85 c0                	test   %eax,%eax
801053b2:	74 0d                	je     801053c1 <sched+0x7b>
    panic("sched interruptible");
801053b4:	83 ec 0c             	sub    $0xc,%esp
801053b7:	68 79 a4 10 80       	push   $0x8010a479
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
801053e8:	e8 4d 19 00 00       	call   80106d3a <swtch>
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
80105411:	e8 4d 14 00 00       	call   80106863 <acquire>
80105416:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80105419:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010541f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
#ifdef CS333_P3P4
  proc->budget = proc->budget - (ticks - proc->cpu_ticks_in);
80105426:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010542c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105433:	8b 8a 94 00 00 00    	mov    0x94(%edx),%ecx
80105439:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105440:	8b 9a 8c 00 00 00    	mov    0x8c(%edx),%ebx
80105446:	8b 15 00 79 11 80    	mov    0x80117900,%edx
8010544c:	29 d3                	sub    %edx,%ebx
8010544e:	89 da                	mov    %ebx,%edx
80105450:	01 ca                	add    %ecx,%edx
80105452:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
  if(proc->budget <= 0)
80105458:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010545e:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80105464:	85 c0                	test   %eax,%eax
80105466:	75 4b                	jne    801054b3 <yield+0xb1>
  {
    if(proc->priority < MAXPRIO)
80105468:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010546e:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80105474:	85 c0                	test   %eax,%eax
80105476:	75 1c                	jne    80105494 <yield+0x92>
      proc->priority += 1;
80105478:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010547e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105485:	8b 92 98 00 00 00    	mov    0x98(%edx),%edx
8010548b:	83 c2 01             	add    $0x1,%edx
8010548e:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
    proc->budget = BUDGET*(proc->priority+1);
80105494:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010549a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801054a1:	8b 92 98 00 00 00    	mov    0x98(%edx),%edx
801054a7:	83 c2 01             	add    $0x1,%edx
801054aa:	6b d2 64             	imul   $0x64,%edx,%edx
801054ad:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
  }
  stateListRemove(&ptable.pLists.running, &ptable.pLists.runningTail, proc);
801054b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054b9:	83 ec 04             	sub    $0x4,%esp
801054bc:	50                   	push   %eax
801054bd:	68 e0 70 11 80       	push   $0x801170e0
801054c2:	68 dc 70 11 80       	push   $0x801170dc
801054c7:	e8 85 08 00 00       	call   80105d51 <stateListRemove>
801054cc:	83 c4 10             	add    $0x10,%esp
  stateListAdd(&ptable.pLists.ready[proc->priority], &ptable.pLists.readyTail[proc->priority], proc);
801054cf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054d5:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801054dc:	8b 92 98 00 00 00    	mov    0x98(%edx),%edx
801054e2:	81 c2 cc 09 00 00    	add    $0x9cc,%edx
801054e8:	c1 e2 02             	shl    $0x2,%edx
801054eb:	81 c2 80 49 11 80    	add    $0x80114980,%edx
801054f1:	8d 4a 0c             	lea    0xc(%edx),%ecx
801054f4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801054fb:	8b 92 98 00 00 00    	mov    0x98(%edx),%edx
80105501:	81 c2 cc 09 00 00    	add    $0x9cc,%edx
80105507:	c1 e2 02             	shl    $0x2,%edx
8010550a:	81 c2 80 49 11 80    	add    $0x80114980,%edx
80105510:	83 c2 04             	add    $0x4,%edx
80105513:	83 ec 04             	sub    $0x4,%esp
80105516:	50                   	push   %eax
80105517:	51                   	push   %ecx
80105518:	52                   	push   %edx
80105519:	e8 d4 07 00 00       	call   80105cf2 <stateListAdd>
8010551e:	83 c4 10             	add    $0x10,%esp
  assertState(proc, RUNNABLE);
80105521:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105527:	83 ec 08             	sub    $0x8,%esp
8010552a:	6a 03                	push   $0x3
8010552c:	50                   	push   %eax
8010552d:	e8 7c 0e 00 00       	call   801063ae <assertState>
80105532:	83 c4 10             	add    $0x10,%esp
#endif
  sched();
80105535:	e8 0c fe ff ff       	call   80105346 <sched>
  release(&ptable.lock);
8010553a:	83 ec 0c             	sub    $0xc,%esp
8010553d:	68 80 49 11 80       	push   $0x80114980
80105542:	e8 83 13 00 00       	call   801068ca <release>
80105547:	83 c4 10             	add    $0x10,%esp
}
8010554a:	90                   	nop
8010554b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010554e:	c9                   	leave  
8010554f:	c3                   	ret    

80105550 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80105550:	55                   	push   %ebp
80105551:	89 e5                	mov    %esp,%ebp
80105553:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80105556:	83 ec 0c             	sub    $0xc,%esp
80105559:	68 80 49 11 80       	push   $0x80114980
8010555e:	e8 67 13 00 00       	call   801068ca <release>
80105563:	83 c4 10             	add    $0x10,%esp

  if (first) {
80105566:	a1 20 d0 10 80       	mov    0x8010d020,%eax
8010556b:	85 c0                	test   %eax,%eax
8010556d:	74 24                	je     80105593 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
8010556f:	c7 05 20 d0 10 80 00 	movl   $0x0,0x8010d020
80105576:	00 00 00 
    iinit(ROOTDEV);
80105579:	83 ec 0c             	sub    $0xc,%esp
8010557c:	6a 01                	push   $0x1
8010557e:	e8 59 c1 ff ff       	call   801016dc <iinit>
80105583:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80105586:	83 ec 0c             	sub    $0xc,%esp
80105589:	6a 01                	push   $0x1
8010558b:	e8 3d de ff ff       	call   801033cd <initlog>
80105590:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80105593:	90                   	nop
80105594:	c9                   	leave  
80105595:	c3                   	ret    

80105596 <sleep>:
// Reacquires lock when awakened.
// 2016/12/28: ticklock removed from xv6. sleep() changed to
// accept a NULL lock to accommodate.
void
sleep(void *chan, struct spinlock *lk)
{
80105596:	55                   	push   %ebp
80105597:	89 e5                	mov    %esp,%ebp
80105599:	53                   	push   %ebx
8010559a:	83 ec 04             	sub    $0x4,%esp
  if(proc == 0)
8010559d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055a3:	85 c0                	test   %eax,%eax
801055a5:	75 0d                	jne    801055b4 <sleep+0x1e>
    panic("sleep");
801055a7:	83 ec 0c             	sub    $0xc,%esp
801055aa:	68 8d a4 10 80       	push   $0x8010a48d
801055af:	e8 b2 af ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){
801055b4:	81 7d 0c 80 49 11 80 	cmpl   $0x80114980,0xc(%ebp)
801055bb:	74 24                	je     801055e1 <sleep+0x4b>
    acquire(&ptable.lock);
801055bd:	83 ec 0c             	sub    $0xc,%esp
801055c0:	68 80 49 11 80       	push   $0x80114980
801055c5:	e8 99 12 00 00       	call   80106863 <acquire>
801055ca:	83 c4 10             	add    $0x10,%esp
    if (lk) release(lk);
801055cd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801055d1:	74 0e                	je     801055e1 <sleep+0x4b>
801055d3:	83 ec 0c             	sub    $0xc,%esp
801055d6:	ff 75 0c             	pushl  0xc(%ebp)
801055d9:	e8 ec 12 00 00       	call   801068ca <release>
801055de:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
801055e1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055e7:	8b 55 08             	mov    0x8(%ebp),%edx
801055ea:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
801055ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055f3:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
#ifdef CS333_P3P4
  proc->budget = proc->budget - (ticks - proc->cpu_ticks_in);
801055fa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105600:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105607:	8b 8a 94 00 00 00    	mov    0x94(%edx),%ecx
8010560d:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105614:	8b 9a 8c 00 00 00    	mov    0x8c(%edx),%ebx
8010561a:	8b 15 00 79 11 80    	mov    0x80117900,%edx
80105620:	29 d3                	sub    %edx,%ebx
80105622:	89 da                	mov    %ebx,%edx
80105624:	01 ca                	add    %ecx,%edx
80105626:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
  if(proc->budget <= 0)
8010562c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105632:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80105638:	85 c0                	test   %eax,%eax
8010563a:	75 4b                	jne    80105687 <sleep+0xf1>
  {
    if(proc->priority < MAXPRIO)
8010563c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105642:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80105648:	85 c0                	test   %eax,%eax
8010564a:	75 1c                	jne    80105668 <sleep+0xd2>
      proc->priority += 1;
8010564c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105652:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105659:	8b 92 98 00 00 00    	mov    0x98(%edx),%edx
8010565f:	83 c2 01             	add    $0x1,%edx
80105662:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
    proc->budget = BUDGET*(proc->priority+1);
80105668:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010566e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105675:	8b 92 98 00 00 00    	mov    0x98(%edx),%edx
8010567b:	83 c2 01             	add    $0x1,%edx
8010567e:	6b d2 64             	imul   $0x64,%edx,%edx
80105681:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
  }
  if(stateListRemove(&ptable.pLists.running, &ptable.pLists.runningTail, proc))
80105687:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010568d:	83 ec 04             	sub    $0x4,%esp
80105690:	50                   	push   %eax
80105691:	68 e0 70 11 80       	push   $0x801170e0
80105696:	68 dc 70 11 80       	push   $0x801170dc
8010569b:	e8 b1 06 00 00       	call   80105d51 <stateListRemove>
801056a0:	83 c4 10             	add    $0x10,%esp
801056a3:	85 c0                	test   %eax,%eax
801056a5:	74 0d                	je     801056b4 <sleep+0x11e>
    panic("error removing from running list.");
801056a7:	83 ec 0c             	sub    $0xc,%esp
801056aa:	68 94 a4 10 80       	push   $0x8010a494
801056af:	e8 b2 ae ff ff       	call   80100566 <panic>
  if(stateListAdd(&ptable.pLists.sleep, &ptable.pLists.sleepTail, proc))
801056b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056ba:	83 ec 04             	sub    $0x4,%esp
801056bd:	50                   	push   %eax
801056be:	68 d0 70 11 80       	push   $0x801170d0
801056c3:	68 cc 70 11 80       	push   $0x801170cc
801056c8:	e8 25 06 00 00       	call   80105cf2 <stateListAdd>
801056cd:	83 c4 10             	add    $0x10,%esp
801056d0:	85 c0                	test   %eax,%eax
801056d2:	74 0d                	je     801056e1 <sleep+0x14b>
    panic("error adding to sleep list.");
801056d4:	83 ec 0c             	sub    $0xc,%esp
801056d7:	68 b6 a4 10 80       	push   $0x8010a4b6
801056dc:	e8 85 ae ff ff       	call   80100566 <panic>
  assertState(proc, SLEEPING);
801056e1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056e7:	83 ec 08             	sub    $0x8,%esp
801056ea:	6a 02                	push   $0x2
801056ec:	50                   	push   %eax
801056ed:	e8 bc 0c 00 00       	call   801063ae <assertState>
801056f2:	83 c4 10             	add    $0x10,%esp
#endif
  sched();
801056f5:	e8 4c fc ff ff       	call   80105346 <sched>

  // Tidy up.
  proc->chan = 0;
801056fa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105700:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){
80105707:	81 7d 0c 80 49 11 80 	cmpl   $0x80114980,0xc(%ebp)
8010570e:	74 24                	je     80105734 <sleep+0x19e>
    release(&ptable.lock);
80105710:	83 ec 0c             	sub    $0xc,%esp
80105713:	68 80 49 11 80       	push   $0x80114980
80105718:	e8 ad 11 00 00       	call   801068ca <release>
8010571d:	83 c4 10             	add    $0x10,%esp
    if (lk) acquire(lk);
80105720:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105724:	74 0e                	je     80105734 <sleep+0x19e>
80105726:	83 ec 0c             	sub    $0xc,%esp
80105729:	ff 75 0c             	pushl  0xc(%ebp)
8010572c:	e8 32 11 00 00       	call   80106863 <acquire>
80105731:	83 c4 10             	add    $0x10,%esp
  }
}
80105734:	90                   	nop
80105735:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105738:	c9                   	leave  
80105739:	c3                   	ret    

8010573a <wakeup1>:
      p->state = RUNNABLE;
}
#else
static void
wakeup1(void *chan)
{
8010573a:	55                   	push   %ebp
8010573b:	89 e5                	mov    %esp,%ebp
8010573d:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  p = ptable.pLists.sleep;
80105740:	a1 cc 70 11 80       	mov    0x801170cc,%eax
80105745:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(p)
80105748:	e9 b1 00 00 00       	jmp    801057fe <wakeup1+0xc4>
  {
    if(p->chan == chan)
8010574d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105750:	8b 40 20             	mov    0x20(%eax),%eax
80105753:	3b 45 08             	cmp    0x8(%ebp),%eax
80105756:	0f 85 96 00 00 00    	jne    801057f2 <wakeup1+0xb8>
    {
      p->state = RUNNABLE;
8010575c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010575f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      if(stateListRemove(&ptable.pLists.sleep, &ptable.pLists.sleepTail, p))
80105766:	83 ec 04             	sub    $0x4,%esp
80105769:	ff 75 f4             	pushl  -0xc(%ebp)
8010576c:	68 d0 70 11 80       	push   $0x801170d0
80105771:	68 cc 70 11 80       	push   $0x801170cc
80105776:	e8 d6 05 00 00       	call   80105d51 <stateListRemove>
8010577b:	83 c4 10             	add    $0x10,%esp
8010577e:	85 c0                	test   %eax,%eax
80105780:	74 0d                	je     8010578f <wakeup1+0x55>
        panic("error removing from sleep list.");
80105782:	83 ec 0c             	sub    $0xc,%esp
80105785:	68 d4 a4 10 80       	push   $0x8010a4d4
8010578a:	e8 d7 ad ff ff       	call   80100566 <panic>
      if(stateListAdd(&ptable.pLists.ready[p->priority], &ptable.pLists.readyTail[p->priority], p))
8010578f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105792:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80105798:	05 cc 09 00 00       	add    $0x9cc,%eax
8010579d:	c1 e0 02             	shl    $0x2,%eax
801057a0:	05 80 49 11 80       	add    $0x80114980,%eax
801057a5:	8d 50 0c             	lea    0xc(%eax),%edx
801057a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057ab:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801057b1:	05 cc 09 00 00       	add    $0x9cc,%eax
801057b6:	c1 e0 02             	shl    $0x2,%eax
801057b9:	05 80 49 11 80       	add    $0x80114980,%eax
801057be:	83 c0 04             	add    $0x4,%eax
801057c1:	83 ec 04             	sub    $0x4,%esp
801057c4:	ff 75 f4             	pushl  -0xc(%ebp)
801057c7:	52                   	push   %edx
801057c8:	50                   	push   %eax
801057c9:	e8 24 05 00 00       	call   80105cf2 <stateListAdd>
801057ce:	83 c4 10             	add    $0x10,%esp
801057d1:	85 c0                	test   %eax,%eax
801057d3:	74 0d                	je     801057e2 <wakeup1+0xa8>
        panic("error adding to ready list.");
801057d5:	83 ec 0c             	sub    $0xc,%esp
801057d8:	68 1c a3 10 80       	push   $0x8010a31c
801057dd:	e8 84 ad ff ff       	call   80100566 <panic>
      assertState(p, RUNNABLE);
801057e2:	83 ec 08             	sub    $0x8,%esp
801057e5:	6a 03                	push   $0x3
801057e7:	ff 75 f4             	pushl  -0xc(%ebp)
801057ea:	e8 bf 0b 00 00       	call   801063ae <assertState>
801057ef:	83 c4 10             	add    $0x10,%esp
    }
    p = p->next;
801057f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057f5:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801057fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
wakeup1(void *chan)
{
  struct proc *p;

  p = ptable.pLists.sleep;
  while(p)
801057fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105802:	0f 85 45 ff ff ff    	jne    8010574d <wakeup1+0x13>
        panic("error adding to ready list.");
      assertState(p, RUNNABLE);
    }
    p = p->next;
  }
}
80105808:	90                   	nop
80105809:	c9                   	leave  
8010580a:	c3                   	ret    

8010580b <wakeup>:
#endif

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010580b:	55                   	push   %ebp
8010580c:	89 e5                	mov    %esp,%ebp
8010580e:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80105811:	83 ec 0c             	sub    $0xc,%esp
80105814:	68 80 49 11 80       	push   $0x80114980
80105819:	e8 45 10 00 00       	call   80106863 <acquire>
8010581e:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80105821:	83 ec 0c             	sub    $0xc,%esp
80105824:	ff 75 08             	pushl  0x8(%ebp)
80105827:	e8 0e ff ff ff       	call   8010573a <wakeup1>
8010582c:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
8010582f:	83 ec 0c             	sub    $0xc,%esp
80105832:	68 80 49 11 80       	push   $0x80114980
80105837:	e8 8e 10 00 00       	call   801068ca <release>
8010583c:	83 c4 10             	add    $0x10,%esp
}
8010583f:	90                   	nop
80105840:	c9                   	leave  
80105841:	c3                   	ret    

80105842 <kill>:
  return -1;
}
#else
int
kill(int pid)
{
80105842:	55                   	push   %ebp
80105843:	89 e5                	mov    %esp,%ebp
80105845:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80105848:	83 ec 0c             	sub    $0xc,%esp
8010584b:	68 80 49 11 80       	push   $0x80114980
80105850:	e8 0e 10 00 00       	call   80106863 <acquire>
80105855:	83 c4 10             	add    $0x10,%esp
  for(int i = 0; i<MAXPRIO+1; ++i)
80105858:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010585f:	eb 3b                	jmp    8010589c <kill+0x5a>
  {
    for(p = ptable.pLists.ready[i]; p ; p = p->next)
80105861:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105864:	05 cc 09 00 00       	add    $0x9cc,%eax
80105869:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
80105870:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105873:	eb 1d                	jmp    80105892 <kill+0x50>
    {
      if(p->pid == pid)
80105875:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105878:	8b 50 10             	mov    0x10(%eax),%edx
8010587b:	8b 45 08             	mov    0x8(%ebp),%eax
8010587e:	39 c2                	cmp    %eax,%edx
80105880:	0f 84 86 01 00 00    	je     80105a0c <kill+0x1ca>
  struct proc *p;

  acquire(&ptable.lock);
  for(int i = 0; i<MAXPRIO+1; ++i)
  {
    for(p = ptable.pLists.ready[i]; p ; p = p->next)
80105886:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105889:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010588f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105892:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105896:	75 dd                	jne    80105875 <kill+0x33>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(int i = 0; i<MAXPRIO+1; ++i)
80105898:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010589c:	83 7d f0 01          	cmpl   $0x1,-0x10(%ebp)
801058a0:	7e bf                	jle    80105861 <kill+0x1f>
    {
      if(p->pid == pid)
        goto found;
    }
  }
  for(p = ptable.pLists.running; p ; p = p->next)
801058a2:	a1 dc 70 11 80       	mov    0x801170dc,%eax
801058a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058aa:	eb 1d                	jmp    801058c9 <kill+0x87>
  {
    if(p->pid == pid)
801058ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058af:	8b 50 10             	mov    0x10(%eax),%edx
801058b2:	8b 45 08             	mov    0x8(%ebp),%eax
801058b5:	39 c2                	cmp    %eax,%edx
801058b7:	0f 84 52 01 00 00    	je     80105a0f <kill+0x1cd>
    {
      if(p->pid == pid)
        goto found;
    }
  }
  for(p = ptable.pLists.running; p ; p = p->next)
801058bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058c0:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801058c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058cd:	75 dd                	jne    801058ac <kill+0x6a>
  {
    if(p->pid == pid)
      goto found;
  }
  for(p = ptable.pLists.embryo; p ; p = p->next)
801058cf:	a1 e4 70 11 80       	mov    0x801170e4,%eax
801058d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058d7:	eb 1d                	jmp    801058f6 <kill+0xb4>
  {
    if(p->pid == pid)
801058d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058dc:	8b 50 10             	mov    0x10(%eax),%edx
801058df:	8b 45 08             	mov    0x8(%ebp),%eax
801058e2:	39 c2                	cmp    %eax,%edx
801058e4:	0f 84 28 01 00 00    	je     80105a12 <kill+0x1d0>
  for(p = ptable.pLists.running; p ; p = p->next)
  {
    if(p->pid == pid)
      goto found;
  }
  for(p = ptable.pLists.embryo; p ; p = p->next)
801058ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058ed:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801058f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058fa:	75 dd                	jne    801058d9 <kill+0x97>
  {
    if(p->pid == pid)
      goto found;
  }
  for(p = ptable.pLists.zombie; p ; p = p->next)
801058fc:	a1 d4 70 11 80       	mov    0x801170d4,%eax
80105901:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105904:	eb 1d                	jmp    80105923 <kill+0xe1>
  {
    if(p->pid == pid)
80105906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105909:	8b 50 10             	mov    0x10(%eax),%edx
8010590c:	8b 45 08             	mov    0x8(%ebp),%eax
8010590f:	39 c2                	cmp    %eax,%edx
80105911:	0f 84 fe 00 00 00    	je     80105a15 <kill+0x1d3>
  for(p = ptable.pLists.embryo; p ; p = p->next)
  {
    if(p->pid == pid)
      goto found;
  }
  for(p = ptable.pLists.zombie; p ; p = p->next)
80105917:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010591a:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105920:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105923:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105927:	75 dd                	jne    80105906 <kill+0xc4>
  {
    if(p->pid == pid)
      goto found;
  }
  for(p = ptable.pLists.sleep; p ; p = p->next)
80105929:	a1 cc 70 11 80       	mov    0x801170cc,%eax
8010592e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105931:	e9 b5 00 00 00       	jmp    801059eb <kill+0x1a9>
  {
    if(p->pid == pid)
80105936:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105939:	8b 50 10             	mov    0x10(%eax),%edx
8010593c:	8b 45 08             	mov    0x8(%ebp),%eax
8010593f:	39 c2                	cmp    %eax,%edx
80105941:	0f 85 98 00 00 00    	jne    801059df <kill+0x19d>
    {
      // Wake process from sleep if necessary.
      if(stateListRemove(&ptable.pLists.sleep, &ptable.pLists.sleepTail, p))
80105947:	83 ec 04             	sub    $0x4,%esp
8010594a:	ff 75 f4             	pushl  -0xc(%ebp)
8010594d:	68 d0 70 11 80       	push   $0x801170d0
80105952:	68 cc 70 11 80       	push   $0x801170cc
80105957:	e8 f5 03 00 00       	call   80105d51 <stateListRemove>
8010595c:	83 c4 10             	add    $0x10,%esp
8010595f:	85 c0                	test   %eax,%eax
80105961:	74 0d                	je     80105970 <kill+0x12e>
        panic("error removing from sleep list.");
80105963:	83 ec 0c             	sub    $0xc,%esp
80105966:	68 d4 a4 10 80       	push   $0x8010a4d4
8010596b:	e8 f6 ab ff ff       	call   80100566 <panic>
      if(stateListAdd(&ptable.pLists.ready[p->priority], &ptable.pLists.readyTail[p->priority], p))
80105970:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105973:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80105979:	05 cc 09 00 00       	add    $0x9cc,%eax
8010597e:	c1 e0 02             	shl    $0x2,%eax
80105981:	05 80 49 11 80       	add    $0x80114980,%eax
80105986:	8d 50 0c             	lea    0xc(%eax),%edx
80105989:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010598c:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80105992:	05 cc 09 00 00       	add    $0x9cc,%eax
80105997:	c1 e0 02             	shl    $0x2,%eax
8010599a:	05 80 49 11 80       	add    $0x80114980,%eax
8010599f:	83 c0 04             	add    $0x4,%eax
801059a2:	83 ec 04             	sub    $0x4,%esp
801059a5:	ff 75 f4             	pushl  -0xc(%ebp)
801059a8:	52                   	push   %edx
801059a9:	50                   	push   %eax
801059aa:	e8 43 03 00 00       	call   80105cf2 <stateListAdd>
801059af:	83 c4 10             	add    $0x10,%esp
801059b2:	85 c0                	test   %eax,%eax
801059b4:	74 0d                	je     801059c3 <kill+0x181>
        panic("error adding to ready list.");
801059b6:	83 ec 0c             	sub    $0xc,%esp
801059b9:	68 1c a3 10 80       	push   $0x8010a31c
801059be:	e8 a3 ab ff ff       	call   80100566 <panic>
      p->state = RUNNABLE;
801059c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c6:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      assertState(p, RUNNABLE);
801059cd:	83 ec 08             	sub    $0x8,%esp
801059d0:	6a 03                	push   $0x3
801059d2:	ff 75 f4             	pushl  -0xc(%ebp)
801059d5:	e8 d4 09 00 00       	call   801063ae <assertState>
801059da:	83 c4 10             	add    $0x10,%esp
      goto found;
801059dd:	eb 37                	jmp    80105a16 <kill+0x1d4>
  for(p = ptable.pLists.zombie; p ; p = p->next)
  {
    if(p->pid == pid)
      goto found;
  }
  for(p = ptable.pLists.sleep; p ; p = p->next)
801059df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059e2:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801059e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059ef:	0f 85 41 ff ff ff    	jne    80105936 <kill+0xf4>
      p->state = RUNNABLE;
      assertState(p, RUNNABLE);
      goto found;
    }
  }
  release(&ptable.lock);
801059f5:	83 ec 0c             	sub    $0xc,%esp
801059f8:	68 80 49 11 80       	push   $0x80114980
801059fd:	e8 c8 0e 00 00       	call   801068ca <release>
80105a02:	83 c4 10             	add    $0x10,%esp
  return -1;
80105a05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a0a:	eb 29                	jmp    80105a35 <kill+0x1f3>
  for(int i = 0; i<MAXPRIO+1; ++i)
  {
    for(p = ptable.pLists.ready[i]; p ; p = p->next)
    {
      if(p->pid == pid)
        goto found;
80105a0c:	90                   	nop
80105a0d:	eb 07                	jmp    80105a16 <kill+0x1d4>
    }
  }
  for(p = ptable.pLists.running; p ; p = p->next)
  {
    if(p->pid == pid)
      goto found;
80105a0f:	90                   	nop
80105a10:	eb 04                	jmp    80105a16 <kill+0x1d4>
  }
  for(p = ptable.pLists.embryo; p ; p = p->next)
  {
    if(p->pid == pid)
      goto found;
80105a12:	90                   	nop
80105a13:	eb 01                	jmp    80105a16 <kill+0x1d4>
  }
  for(p = ptable.pLists.zombie; p ; p = p->next)
  {
    if(p->pid == pid)
      goto found;
80105a15:	90                   	nop
  }
  release(&ptable.lock);
  return -1;

  found:
  p->killed = 1;
80105a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a19:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
  release(&ptable.lock);
80105a20:	83 ec 0c             	sub    $0xc,%esp
80105a23:	68 80 49 11 80       	push   $0x80114980
80105a28:	e8 9d 0e 00 00       	call   801068ca <release>
80105a2d:	83 c4 10             	add    $0x10,%esp
  return 0;
80105a30:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a35:	c9                   	leave  
80105a36:	c3                   	ret    

80105a37 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105a37:	55                   	push   %ebp
80105a38:	89 e5                	mov    %esp,%ebp
80105a3a:	53                   	push   %ebx
80105a3b:	83 ec 44             	sub    $0x44,%esp
  uint current_ticks;
  struct proc *p;
  char *state;
  uint pc[10];
#if defined CS333_P3P4
  cprintf("\nPID\tName\tUID\tGID\tPPID\tPrio\tElapsed\tCPU\tState\tSize\t PCs\n");
80105a3e:	83 ec 0c             	sub    $0xc,%esp
80105a41:	68 20 a5 10 80       	push   $0x8010a520
80105a46:	e8 7b a9 ff ff       	call   801003c6 <cprintf>
80105a4b:	83 c4 10             	add    $0x10,%esp
#elif defined CS333_P1
  cprintf("\nPID\tState\tName\tElapsed\t PCs\n");
#else
  cprintf("\nPID\tState\tName\t PCs\n");
#endif
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a4e:	c7 45 f0 b4 49 11 80 	movl   $0x801149b4,-0x10(%ebp)
80105a55:	e9 85 02 00 00       	jmp    80105cdf <procdump+0x2a8>
    if(p->state == UNUSED)
80105a5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a5d:	8b 40 0c             	mov    0xc(%eax),%eax
80105a60:	85 c0                	test   %eax,%eax
80105a62:	0f 84 6f 02 00 00    	je     80105cd7 <procdump+0x2a0>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105a68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a6b:	8b 40 0c             	mov    0xc(%eax),%eax
80105a6e:	83 f8 05             	cmp    $0x5,%eax
80105a71:	77 23                	ja     80105a96 <procdump+0x5f>
80105a73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a76:	8b 40 0c             	mov    0xc(%eax),%eax
80105a79:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
80105a80:	85 c0                	test   %eax,%eax
80105a82:	74 12                	je     80105a96 <procdump+0x5f>
      state = states[p->state];
80105a84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a87:	8b 40 0c             	mov    0xc(%eax),%eax
80105a8a:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
80105a91:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105a94:	eb 07                	jmp    80105a9d <procdump+0x66>
    else
      state = "???";
80105a96:	c7 45 ec 59 a5 10 80 	movl   $0x8010a559,-0x14(%ebp)
    current_ticks = ticks;
80105a9d:	a1 00 79 11 80       	mov    0x80117900,%eax
80105aa2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    i = ((current_ticks-p->start_ticks)%1000);
80105aa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aa8:	8b 40 7c             	mov    0x7c(%eax),%eax
80105aab:	8b 55 e8             	mov    -0x18(%ebp),%edx
80105aae:	89 d1                	mov    %edx,%ecx
80105ab0:	29 c1                	sub    %eax,%ecx
80105ab2:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105ab7:	89 c8                	mov    %ecx,%eax
80105ab9:	f7 e2                	mul    %edx
80105abb:	89 d0                	mov    %edx,%eax
80105abd:	c1 e8 06             	shr    $0x6,%eax
80105ac0:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
80105ac6:	29 c1                	sub    %eax,%ecx
80105ac8:	89 c8                	mov    %ecx,%eax
80105aca:	89 45 f4             	mov    %eax,-0xc(%ebp)
#if defined CS333_P2
    cprintf("%d\t%s\t%d\t%d", p->pid, p->name, p->uid, p->gid);
80105acd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ad0:	8b 88 84 00 00 00    	mov    0x84(%eax),%ecx
80105ad6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ad9:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80105adf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ae2:	8d 58 6c             	lea    0x6c(%eax),%ebx
80105ae5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ae8:	8b 40 10             	mov    0x10(%eax),%eax
80105aeb:	83 ec 0c             	sub    $0xc,%esp
80105aee:	51                   	push   %ecx
80105aef:	52                   	push   %edx
80105af0:	53                   	push   %ebx
80105af1:	50                   	push   %eax
80105af2:	68 5d a5 10 80       	push   $0x8010a55d
80105af7:	e8 ca a8 ff ff       	call   801003c6 <cprintf>
80105afc:	83 c4 20             	add    $0x20,%esp
    if(p->pid == 1)
80105aff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b02:	8b 40 10             	mov    0x10(%eax),%eax
80105b05:	83 f8 01             	cmp    $0x1,%eax
80105b08:	75 19                	jne    80105b23 <procdump+0xec>
      cprintf("\t%d",p->pid);
80105b0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b0d:	8b 40 10             	mov    0x10(%eax),%eax
80105b10:	83 ec 08             	sub    $0x8,%esp
80105b13:	50                   	push   %eax
80105b14:	68 69 a5 10 80       	push   $0x8010a569
80105b19:	e8 a8 a8 ff ff       	call   801003c6 <cprintf>
80105b1e:	83 c4 10             	add    $0x10,%esp
80105b21:	eb 1a                	jmp    80105b3d <procdump+0x106>
    else
      cprintf("\t%d",p->parent->pid);
80105b23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b26:	8b 40 14             	mov    0x14(%eax),%eax
80105b29:	8b 40 10             	mov    0x10(%eax),%eax
80105b2c:	83 ec 08             	sub    $0x8,%esp
80105b2f:	50                   	push   %eax
80105b30:	68 69 a5 10 80       	push   $0x8010a569
80105b35:	e8 8c a8 ff ff       	call   801003c6 <cprintf>
80105b3a:	83 c4 10             	add    $0x10,%esp
#if defined CS333_P3P4
      cprintf("\t%d", p->priority);
80105b3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b40:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80105b46:	83 ec 08             	sub    $0x8,%esp
80105b49:	50                   	push   %eax
80105b4a:	68 69 a5 10 80       	push   $0x8010a569
80105b4f:	e8 72 a8 ff ff       	call   801003c6 <cprintf>
80105b54:	83 c4 10             	add    $0x10,%esp
#endif
    cprintf("\t%d.", ((current_ticks-p->start_ticks)/1000));
80105b57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b5a:	8b 40 7c             	mov    0x7c(%eax),%eax
80105b5d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80105b60:	29 c2                	sub    %eax,%edx
80105b62:	89 d0                	mov    %edx,%eax
80105b64:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105b69:	f7 e2                	mul    %edx
80105b6b:	89 d0                	mov    %edx,%eax
80105b6d:	c1 e8 06             	shr    $0x6,%eax
80105b70:	83 ec 08             	sub    $0x8,%esp
80105b73:	50                   	push   %eax
80105b74:	68 6d a5 10 80       	push   $0x8010a56d
80105b79:	e8 48 a8 ff ff       	call   801003c6 <cprintf>
80105b7e:	83 c4 10             	add    $0x10,%esp
    if (i<100)
80105b81:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
80105b85:	7f 10                	jg     80105b97 <procdump+0x160>
      cprintf("0");
80105b87:	83 ec 0c             	sub    $0xc,%esp
80105b8a:	68 72 a5 10 80       	push   $0x8010a572
80105b8f:	e8 32 a8 ff ff       	call   801003c6 <cprintf>
80105b94:	83 c4 10             	add    $0x10,%esp
    if (i<10)
80105b97:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105b9b:	7f 10                	jg     80105bad <procdump+0x176>
      cprintf("0");
80105b9d:	83 ec 0c             	sub    $0xc,%esp
80105ba0:	68 72 a5 10 80       	push   $0x8010a572
80105ba5:	e8 1c a8 ff ff       	call   801003c6 <cprintf>
80105baa:	83 c4 10             	add    $0x10,%esp
    cprintf("%d", i);
80105bad:	83 ec 08             	sub    $0x8,%esp
80105bb0:	ff 75 f4             	pushl  -0xc(%ebp)
80105bb3:	68 74 a5 10 80       	push   $0x8010a574
80105bb8:	e8 09 a8 ff ff       	call   801003c6 <cprintf>
80105bbd:	83 c4 10             	add    $0x10,%esp
    i = p->cpu_ticks_total;
80105bc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bc3:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80105bc9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("\t%d.", i/1000);
80105bcc:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80105bcf:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105bd4:	89 c8                	mov    %ecx,%eax
80105bd6:	f7 ea                	imul   %edx
80105bd8:	c1 fa 06             	sar    $0x6,%edx
80105bdb:	89 c8                	mov    %ecx,%eax
80105bdd:	c1 f8 1f             	sar    $0x1f,%eax
80105be0:	29 c2                	sub    %eax,%edx
80105be2:	89 d0                	mov    %edx,%eax
80105be4:	83 ec 08             	sub    $0x8,%esp
80105be7:	50                   	push   %eax
80105be8:	68 6d a5 10 80       	push   $0x8010a56d
80105bed:	e8 d4 a7 ff ff       	call   801003c6 <cprintf>
80105bf2:	83 c4 10             	add    $0x10,%esp
    i = i%1000;
80105bf5:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80105bf8:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105bfd:	89 c8                	mov    %ecx,%eax
80105bff:	f7 ea                	imul   %edx
80105c01:	c1 fa 06             	sar    $0x6,%edx
80105c04:	89 c8                	mov    %ecx,%eax
80105c06:	c1 f8 1f             	sar    $0x1f,%eax
80105c09:	29 c2                	sub    %eax,%edx
80105c0b:	89 d0                	mov    %edx,%eax
80105c0d:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
80105c13:	29 c1                	sub    %eax,%ecx
80105c15:	89 c8                	mov    %ecx,%eax
80105c17:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i<100)
80105c1a:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
80105c1e:	7f 10                	jg     80105c30 <procdump+0x1f9>
      cprintf("0");
80105c20:	83 ec 0c             	sub    $0xc,%esp
80105c23:	68 72 a5 10 80       	push   $0x8010a572
80105c28:	e8 99 a7 ff ff       	call   801003c6 <cprintf>
80105c2d:	83 c4 10             	add    $0x10,%esp
    if (i<10)
80105c30:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105c34:	7f 10                	jg     80105c46 <procdump+0x20f>
      cprintf("0");
80105c36:	83 ec 0c             	sub    $0xc,%esp
80105c39:	68 72 a5 10 80       	push   $0x8010a572
80105c3e:	e8 83 a7 ff ff       	call   801003c6 <cprintf>
80105c43:	83 c4 10             	add    $0x10,%esp
    cprintf("%d\t%s\t%d\t", i, state, p->sz);
80105c46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c49:	8b 00                	mov    (%eax),%eax
80105c4b:	50                   	push   %eax
80105c4c:	ff 75 ec             	pushl  -0x14(%ebp)
80105c4f:	ff 75 f4             	pushl  -0xc(%ebp)
80105c52:	68 77 a5 10 80       	push   $0x8010a577
80105c57:	e8 6a a7 ff ff       	call   801003c6 <cprintf>
80105c5c:	83 c4 10             	add    $0x10,%esp
      cprintf("0");
    cprintf("%d\t",i);
#else
    cprintf("%d\t%s\t%s", p->pid, state, p->name);
#endif
    i = 0;
80105c5f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(p->state == SLEEPING){
80105c66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c69:	8b 40 0c             	mov    0xc(%eax),%eax
80105c6c:	83 f8 02             	cmp    $0x2,%eax
80105c6f:	75 54                	jne    80105cc5 <procdump+0x28e>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105c71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c74:	8b 40 1c             	mov    0x1c(%eax),%eax
80105c77:	8b 40 0c             	mov    0xc(%eax),%eax
80105c7a:	83 c0 08             	add    $0x8,%eax
80105c7d:	89 c2                	mov    %eax,%edx
80105c7f:	83 ec 08             	sub    $0x8,%esp
80105c82:	8d 45 c0             	lea    -0x40(%ebp),%eax
80105c85:	50                   	push   %eax
80105c86:	52                   	push   %edx
80105c87:	e8 90 0c 00 00       	call   8010691c <getcallerpcs>
80105c8c:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105c8f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105c96:	eb 1c                	jmp    80105cb4 <procdump+0x27d>
        cprintf(" %p", pc[i]);
80105c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c9b:	8b 44 85 c0          	mov    -0x40(%ebp,%eax,4),%eax
80105c9f:	83 ec 08             	sub    $0x8,%esp
80105ca2:	50                   	push   %eax
80105ca3:	68 81 a5 10 80       	push   $0x8010a581
80105ca8:	e8 19 a7 ff ff       	call   801003c6 <cprintf>
80105cad:	83 c4 10             	add    $0x10,%esp
    cprintf("%d\t%s\t%s", p->pid, state, p->name);
#endif
    i = 0;
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105cb0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105cb4:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105cb8:	7f 0b                	jg     80105cc5 <procdump+0x28e>
80105cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cbd:	8b 44 85 c0          	mov    -0x40(%ebp,%eax,4),%eax
80105cc1:	85 c0                	test   %eax,%eax
80105cc3:	75 d3                	jne    80105c98 <procdump+0x261>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105cc5:	83 ec 0c             	sub    $0xc,%esp
80105cc8:	68 85 a5 10 80       	push   $0x8010a585
80105ccd:	e8 f4 a6 ff ff       	call   801003c6 <cprintf>
80105cd2:	83 c4 10             	add    $0x10,%esp
80105cd5:	eb 01                	jmp    80105cd8 <procdump+0x2a1>
#else
  cprintf("\nPID\tState\tName\t PCs\n");
#endif
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105cd7:	90                   	nop
#elif defined CS333_P1
  cprintf("\nPID\tState\tName\tElapsed\t PCs\n");
#else
  cprintf("\nPID\tState\tName\t PCs\n");
#endif
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105cd8:	81 45 f0 9c 00 00 00 	addl   $0x9c,-0x10(%ebp)
80105cdf:	81 7d f0 b4 70 11 80 	cmpl   $0x801170b4,-0x10(%ebp)
80105ce6:	0f 82 6e fd ff ff    	jb     80105a5a <procdump+0x23>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105cec:	90                   	nop
80105ced:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105cf0:	c9                   	leave  
80105cf1:	c3                   	ret    

80105cf2 <stateListAdd>:


#ifdef CS333_P3P4
static int
stateListAdd(struct proc** head, struct proc** tail, struct proc* p)
{
80105cf2:	55                   	push   %ebp
80105cf3:	89 e5                	mov    %esp,%ebp
  if (*head == 0) {
80105cf5:	8b 45 08             	mov    0x8(%ebp),%eax
80105cf8:	8b 00                	mov    (%eax),%eax
80105cfa:	85 c0                	test   %eax,%eax
80105cfc:	75 1f                	jne    80105d1d <stateListAdd+0x2b>
    *head = p;
80105cfe:	8b 45 08             	mov    0x8(%ebp),%eax
80105d01:	8b 55 10             	mov    0x10(%ebp),%edx
80105d04:	89 10                	mov    %edx,(%eax)
    *tail = p;
80105d06:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d09:	8b 55 10             	mov    0x10(%ebp),%edx
80105d0c:	89 10                	mov    %edx,(%eax)
    p->next = 0;
80105d0e:	8b 45 10             	mov    0x10(%ebp),%eax
80105d11:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80105d18:	00 00 00 
80105d1b:	eb 2d                	jmp    80105d4a <stateListAdd+0x58>
  } else {
    (*tail)->next = p;
80105d1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d20:	8b 00                	mov    (%eax),%eax
80105d22:	8b 55 10             	mov    0x10(%ebp),%edx
80105d25:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
    *tail = (*tail)->next;
80105d2b:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d2e:	8b 00                	mov    (%eax),%eax
80105d30:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
80105d36:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d39:	89 10                	mov    %edx,(%eax)
    (*tail)->next = 0;
80105d3b:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d3e:	8b 00                	mov    (%eax),%eax
80105d40:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80105d47:	00 00 00 
  }

  return 0;
80105d4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d4f:	5d                   	pop    %ebp
80105d50:	c3                   	ret    

80105d51 <stateListRemove>:

static int
stateListRemove(struct proc** head, struct proc** tail, struct proc* p)
{
80105d51:	55                   	push   %ebp
80105d52:	89 e5                	mov    %esp,%ebp
80105d54:	83 ec 10             	sub    $0x10,%esp
  if (*head == 0 || *tail == 0 || p == 0) {
80105d57:	8b 45 08             	mov    0x8(%ebp),%eax
80105d5a:	8b 00                	mov    (%eax),%eax
80105d5c:	85 c0                	test   %eax,%eax
80105d5e:	74 0f                	je     80105d6f <stateListRemove+0x1e>
80105d60:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d63:	8b 00                	mov    (%eax),%eax
80105d65:	85 c0                	test   %eax,%eax
80105d67:	74 06                	je     80105d6f <stateListRemove+0x1e>
80105d69:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105d6d:	75 0a                	jne    80105d79 <stateListRemove+0x28>
    return -1;
80105d6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d74:	e9 a5 00 00 00       	jmp    80105e1e <stateListRemove+0xcd>
  }

  struct proc* current = *head;
80105d79:	8b 45 08             	mov    0x8(%ebp),%eax
80105d7c:	8b 00                	mov    (%eax),%eax
80105d7e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct proc* previous = 0;
80105d81:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

  if (current == p) {
80105d88:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d8b:	3b 45 10             	cmp    0x10(%ebp),%eax
80105d8e:	75 31                	jne    80105dc1 <stateListRemove+0x70>
    *head = (*head)->next;
80105d90:	8b 45 08             	mov    0x8(%ebp),%eax
80105d93:	8b 00                	mov    (%eax),%eax
80105d95:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
80105d9b:	8b 45 08             	mov    0x8(%ebp),%eax
80105d9e:	89 10                	mov    %edx,(%eax)
    return 0;
80105da0:	b8 00 00 00 00       	mov    $0x0,%eax
80105da5:	eb 77                	jmp    80105e1e <stateListRemove+0xcd>
  }

  while(current) {
    if (current == p) {
80105da7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105daa:	3b 45 10             	cmp    0x10(%ebp),%eax
80105dad:	74 1a                	je     80105dc9 <stateListRemove+0x78>
      break;
    }

    previous = current;
80105daf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105db2:	89 45 f8             	mov    %eax,-0x8(%ebp)
    current = current->next;
80105db5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105db8:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105dbe:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if (current == p) {
    *head = (*head)->next;
    return 0;
  }

  while(current) {
80105dc1:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105dc5:	75 e0                	jne    80105da7 <stateListRemove+0x56>
80105dc7:	eb 01                	jmp    80105dca <stateListRemove+0x79>
    if (current == p) {
      break;
80105dc9:	90                   	nop
    previous = current;
    current = current->next;
  }

  // Process not found, hit eject.
  if (current == 0) {
80105dca:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105dce:	75 07                	jne    80105dd7 <stateListRemove+0x86>
    return -1;
80105dd0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dd5:	eb 47                	jmp    80105e1e <stateListRemove+0xcd>
  }

  // Process found. Set the appropriate next pointer.
  if (current == *tail) {
80105dd7:	8b 45 0c             	mov    0xc(%ebp),%eax
80105dda:	8b 00                	mov    (%eax),%eax
80105ddc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
80105ddf:	75 19                	jne    80105dfa <stateListRemove+0xa9>
    *tail = previous;
80105de1:	8b 45 0c             	mov    0xc(%ebp),%eax
80105de4:	8b 55 f8             	mov    -0x8(%ebp),%edx
80105de7:	89 10                	mov    %edx,(%eax)
    (*tail)->next = 0;
80105de9:	8b 45 0c             	mov    0xc(%ebp),%eax
80105dec:	8b 00                	mov    (%eax),%eax
80105dee:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80105df5:	00 00 00 
80105df8:	eb 12                	jmp    80105e0c <stateListRemove+0xbb>
  } else {
    previous->next = current->next;
80105dfa:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105dfd:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
80105e03:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e06:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
  }

  // Make sure p->next doesn't point into the list.
  p->next = 0;
80105e0c:	8b 45 10             	mov    0x10(%ebp),%eax
80105e0f:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80105e16:	00 00 00 

  return 0;
80105e19:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e1e:	c9                   	leave  
80105e1f:	c3                   	ret    

80105e20 <initProcessLists>:

static void
initProcessLists(void) {
80105e20:	55                   	push   %ebp
80105e21:	89 e5                	mov    %esp,%ebp
80105e23:	83 ec 10             	sub    $0x10,%esp
  for(int i = 0; i<MAXPRIO+1; ++i)
80105e26:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105e2d:	eb 2a                	jmp    80105e59 <initProcessLists+0x39>
  {
    ptable.pLists.ready[i] = 0;
80105e2f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e32:	05 cc 09 00 00       	add    $0x9cc,%eax
80105e37:	c7 04 85 84 49 11 80 	movl   $0x0,-0x7feeb67c(,%eax,4)
80105e3e:	00 00 00 00 
    ptable.pLists.readyTail[i] = 0;
80105e42:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e45:	05 cc 09 00 00       	add    $0x9cc,%eax
80105e4a:	c7 04 85 8c 49 11 80 	movl   $0x0,-0x7feeb674(,%eax,4)
80105e51:	00 00 00 00 
  return 0;
}

static void
initProcessLists(void) {
  for(int i = 0; i<MAXPRIO+1; ++i)
80105e55:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105e59:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80105e5d:	7e d0                	jle    80105e2f <initProcessLists+0xf>
  {
    ptable.pLists.ready[i] = 0;
    ptable.pLists.readyTail[i] = 0;
  }
  ptable.pLists.free = 0;
80105e5f:	c7 05 c4 70 11 80 00 	movl   $0x0,0x801170c4
80105e66:	00 00 00 
  ptable.pLists.freeTail = 0;
80105e69:	c7 05 c8 70 11 80 00 	movl   $0x0,0x801170c8
80105e70:	00 00 00 
  ptable.pLists.sleep = 0;
80105e73:	c7 05 cc 70 11 80 00 	movl   $0x0,0x801170cc
80105e7a:	00 00 00 
  ptable.pLists.sleepTail = 0;
80105e7d:	c7 05 d0 70 11 80 00 	movl   $0x0,0x801170d0
80105e84:	00 00 00 
  ptable.pLists.zombie = 0;
80105e87:	c7 05 d4 70 11 80 00 	movl   $0x0,0x801170d4
80105e8e:	00 00 00 
  ptable.pLists.zombieTail = 0;
80105e91:	c7 05 d8 70 11 80 00 	movl   $0x0,0x801170d8
80105e98:	00 00 00 
  ptable.pLists.running = 0;
80105e9b:	c7 05 dc 70 11 80 00 	movl   $0x0,0x801170dc
80105ea2:	00 00 00 
  ptable.pLists.runningTail = 0;
80105ea5:	c7 05 e0 70 11 80 00 	movl   $0x0,0x801170e0
80105eac:	00 00 00 
  ptable.pLists.embryo = 0;
80105eaf:	c7 05 e4 70 11 80 00 	movl   $0x0,0x801170e4
80105eb6:	00 00 00 
  ptable.pLists.embryoTail = 0;
80105eb9:	c7 05 e8 70 11 80 00 	movl   $0x0,0x801170e8
80105ec0:	00 00 00 
}
80105ec3:	90                   	nop
80105ec4:	c9                   	leave  
80105ec5:	c3                   	ret    

80105ec6 <initFreeList>:

static void
initFreeList(void) {
80105ec6:	55                   	push   %ebp
80105ec7:	89 e5                	mov    %esp,%ebp
80105ec9:	83 ec 18             	sub    $0x18,%esp
  if (!holding(&ptable.lock)) {
80105ecc:	83 ec 0c             	sub    $0xc,%esp
80105ecf:	68 80 49 11 80       	push   $0x80114980
80105ed4:	e8 bd 0a 00 00       	call   80106996 <holding>
80105ed9:	83 c4 10             	add    $0x10,%esp
80105edc:	85 c0                	test   %eax,%eax
80105ede:	75 0d                	jne    80105eed <initFreeList+0x27>
    panic("acquire the ptable lock before calling initFreeList\n");
80105ee0:	83 ec 0c             	sub    $0xc,%esp
80105ee3:	68 88 a5 10 80       	push   $0x8010a588
80105ee8:	e8 79 a6 ff ff       	call   80100566 <panic>
  }

  struct proc* p;

  for (p = ptable.proc; p < ptable.proc + NPROC; ++p) {
80105eed:	c7 45 f4 b4 49 11 80 	movl   $0x801149b4,-0xc(%ebp)
80105ef4:	eb 29                	jmp    80105f1f <initFreeList+0x59>
    p->state = UNUSED;
80105ef6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ef9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail, p);
80105f00:	83 ec 04             	sub    $0x4,%esp
80105f03:	ff 75 f4             	pushl  -0xc(%ebp)
80105f06:	68 c8 70 11 80       	push   $0x801170c8
80105f0b:	68 c4 70 11 80       	push   $0x801170c4
80105f10:	e8 dd fd ff ff       	call   80105cf2 <stateListAdd>
80105f15:	83 c4 10             	add    $0x10,%esp
    panic("acquire the ptable lock before calling initFreeList\n");
  }

  struct proc* p;

  for (p = ptable.proc; p < ptable.proc + NPROC; ++p) {
80105f18:	81 45 f4 9c 00 00 00 	addl   $0x9c,-0xc(%ebp)
80105f1f:	b8 b4 70 11 80       	mov    $0x801170b4,%eax
80105f24:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80105f27:	72 cd                	jb     80105ef6 <initFreeList+0x30>
    p->state = UNUSED;
    stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail, p);
  }
}
80105f29:	90                   	nop
80105f2a:	c9                   	leave  
80105f2b:	c3                   	ret    

80105f2c <getprocs>:
#endif

//Get all current processes within the system.
int
getprocs(int max, struct uproc* proctable)
{
80105f2c:	55                   	push   %ebp
80105f2d:	89 e5                	mov    %esp,%ebp
80105f2f:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int i;

  //LOCK PTABLE
  acquire(&ptable.lock);
80105f32:	83 ec 0c             	sub    $0xc,%esp
80105f35:	68 80 49 11 80       	push   $0x80114980
80105f3a:	e8 24 09 00 00       	call   80106863 <acquire>
80105f3f:	83 c4 10             	add    $0x10,%esp

  //ptable gets incremented within forloop, i get incremented at the end
  //of the forloop.
  for(i=0, p = ptable.proc; p < &ptable.proc[NPROC] && i<max; p++)
80105f42:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80105f49:	c7 45 f4 b4 49 11 80 	movl   $0x801149b4,-0xc(%ebp)
80105f50:	e9 a4 01 00 00       	jmp    801060f9 <getprocs+0x1cd>
  {
    //copy all the info into one element of the array
    //skip if the process is in the unused state
    if(p->state != UNUSED && p->state != EMBRYO)
80105f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f58:	8b 40 0c             	mov    0xc(%eax),%eax
80105f5b:	85 c0                	test   %eax,%eax
80105f5d:	0f 84 8f 01 00 00    	je     801060f2 <getprocs+0x1c6>
80105f63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f66:	8b 40 0c             	mov    0xc(%eax),%eax
80105f69:	83 f8 01             	cmp    $0x1,%eax
80105f6c:	0f 84 80 01 00 00    	je     801060f2 <getprocs+0x1c6>
    {
      proctable[i].pid = p->pid;
80105f72:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105f75:	89 d0                	mov    %edx,%eax
80105f77:	01 c0                	add    %eax,%eax
80105f79:	01 d0                	add    %edx,%eax
80105f7b:	c1 e0 05             	shl    $0x5,%eax
80105f7e:	89 c2                	mov    %eax,%edx
80105f80:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f83:	01 c2                	add    %eax,%edx
80105f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f88:	8b 40 10             	mov    0x10(%eax),%eax
80105f8b:	89 02                	mov    %eax,(%edx)
      proctable[i].uid = p->uid;
80105f8d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105f90:	89 d0                	mov    %edx,%eax
80105f92:	01 c0                	add    %eax,%eax
80105f94:	01 d0                	add    %edx,%eax
80105f96:	c1 e0 05             	shl    $0x5,%eax
80105f99:	89 c2                	mov    %eax,%edx
80105f9b:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f9e:	01 c2                	add    %eax,%edx
80105fa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fa3:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105fa9:	89 42 04             	mov    %eax,0x4(%edx)
      proctable[i].gid = p->gid;
80105fac:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105faf:	89 d0                	mov    %edx,%eax
80105fb1:	01 c0                	add    %eax,%eax
80105fb3:	01 d0                	add    %edx,%eax
80105fb5:	c1 e0 05             	shl    $0x5,%eax
80105fb8:	89 c2                	mov    %eax,%edx
80105fba:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fbd:	01 c2                	add    %eax,%edx
80105fbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fc2:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80105fc8:	89 42 08             	mov    %eax,0x8(%edx)
      proctable[i].priority = p->priority;
80105fcb:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105fce:	89 d0                	mov    %edx,%eax
80105fd0:	01 c0                	add    %eax,%eax
80105fd2:	01 d0                	add    %edx,%eax
80105fd4:	c1 e0 05             	shl    $0x5,%eax
80105fd7:	89 c2                	mov    %eax,%edx
80105fd9:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fdc:	01 c2                	add    %eax,%edx
80105fde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fe1:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80105fe7:	89 42 5c             	mov    %eax,0x5c(%edx)
      if(p->parent != 0)
80105fea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fed:	8b 40 14             	mov    0x14(%eax),%eax
80105ff0:	85 c0                	test   %eax,%eax
80105ff2:	74 21                	je     80106015 <getprocs+0xe9>
        proctable[i].ppid = p->parent->pid;
80105ff4:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ff7:	89 d0                	mov    %edx,%eax
80105ff9:	01 c0                	add    %eax,%eax
80105ffb:	01 d0                	add    %edx,%eax
80105ffd:	c1 e0 05             	shl    $0x5,%eax
80106000:	89 c2                	mov    %eax,%edx
80106002:	8b 45 0c             	mov    0xc(%ebp),%eax
80106005:	01 c2                	add    %eax,%edx
80106007:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010600a:	8b 40 14             	mov    0x14(%eax),%eax
8010600d:	8b 40 10             	mov    0x10(%eax),%eax
80106010:	89 42 0c             	mov    %eax,0xc(%edx)
80106013:	eb 1c                	jmp    80106031 <getprocs+0x105>
      else
        proctable[i].ppid = p->pid;
80106015:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106018:	89 d0                	mov    %edx,%eax
8010601a:	01 c0                	add    %eax,%eax
8010601c:	01 d0                	add    %edx,%eax
8010601e:	c1 e0 05             	shl    $0x5,%eax
80106021:	89 c2                	mov    %eax,%edx
80106023:	8b 45 0c             	mov    0xc(%ebp),%eax
80106026:	01 c2                	add    %eax,%edx
80106028:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010602b:	8b 40 10             	mov    0x10(%eax),%eax
8010602e:	89 42 0c             	mov    %eax,0xc(%edx)

      //Get the current ticks for elapsed ticks.
      proctable[i].elapsed_ticks = ticks-p->start_ticks;
80106031:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106034:	89 d0                	mov    %edx,%eax
80106036:	01 c0                	add    %eax,%eax
80106038:	01 d0                	add    %edx,%eax
8010603a:	c1 e0 05             	shl    $0x5,%eax
8010603d:	89 c2                	mov    %eax,%edx
8010603f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106042:	01 c2                	add    %eax,%edx
80106044:	8b 0d 00 79 11 80    	mov    0x80117900,%ecx
8010604a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010604d:	8b 40 7c             	mov    0x7c(%eax),%eax
80106050:	29 c1                	sub    %eax,%ecx
80106052:	89 c8                	mov    %ecx,%eax
80106054:	89 42 10             	mov    %eax,0x10(%edx)
      proctable[i].CPU_total_ticks = p->cpu_ticks_total;
80106057:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010605a:	89 d0                	mov    %edx,%eax
8010605c:	01 c0                	add    %eax,%eax
8010605e:	01 d0                	add    %edx,%eax
80106060:	c1 e0 05             	shl    $0x5,%eax
80106063:	89 c2                	mov    %eax,%edx
80106065:	8b 45 0c             	mov    0xc(%ebp),%eax
80106068:	01 c2                	add    %eax,%edx
8010606a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010606d:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80106073:	89 42 14             	mov    %eax,0x14(%edx)
      safestrcpy(proctable[i].state, states[p->state], sizeof(proctable[i].state));
80106076:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106079:	8b 40 0c             	mov    0xc(%eax),%eax
8010607c:	8b 0c 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%ecx
80106083:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106086:	89 d0                	mov    %edx,%eax
80106088:	01 c0                	add    %eax,%eax
8010608a:	01 d0                	add    %edx,%eax
8010608c:	c1 e0 05             	shl    $0x5,%eax
8010608f:	89 c2                	mov    %eax,%edx
80106091:	8b 45 0c             	mov    0xc(%ebp),%eax
80106094:	01 d0                	add    %edx,%eax
80106096:	83 c0 18             	add    $0x18,%eax
80106099:	83 ec 04             	sub    $0x4,%esp
8010609c:	6a 20                	push   $0x20
8010609e:	51                   	push   %ecx
8010609f:	50                   	push   %eax
801060a0:	e8 24 0c 00 00       	call   80106cc9 <safestrcpy>
801060a5:	83 c4 10             	add    $0x10,%esp
      proctable[i].size = p->sz;
801060a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801060ab:	89 d0                	mov    %edx,%eax
801060ad:	01 c0                	add    %eax,%eax
801060af:	01 d0                	add    %edx,%eax
801060b1:	c1 e0 05             	shl    $0x5,%eax
801060b4:	89 c2                	mov    %eax,%edx
801060b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801060b9:	01 c2                	add    %eax,%edx
801060bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060be:	8b 00                	mov    (%eax),%eax
801060c0:	89 42 38             	mov    %eax,0x38(%edx)
      safestrcpy(proctable[i].name, p->name, sizeof(p->name));
801060c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060c6:	8d 48 6c             	lea    0x6c(%eax),%ecx
801060c9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801060cc:	89 d0                	mov    %edx,%eax
801060ce:	01 c0                	add    %eax,%eax
801060d0:	01 d0                	add    %edx,%eax
801060d2:	c1 e0 05             	shl    $0x5,%eax
801060d5:	89 c2                	mov    %eax,%edx
801060d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801060da:	01 d0                	add    %edx,%eax
801060dc:	83 c0 3c             	add    $0x3c,%eax
801060df:	83 ec 04             	sub    $0x4,%esp
801060e2:	6a 10                	push   $0x10
801060e4:	51                   	push   %ecx
801060e5:	50                   	push   %eax
801060e6:	e8 de 0b 00 00       	call   80106cc9 <safestrcpy>
801060eb:	83 c4 10             	add    $0x10,%esp

      //Increment the array that is having info copied into
      ++i;
801060ee:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  //LOCK PTABLE
  acquire(&ptable.lock);

  //ptable gets incremented within forloop, i get incremented at the end
  //of the forloop.
  for(i=0, p = ptable.proc; p < &ptable.proc[NPROC] && i<max; p++)
801060f2:	81 45 f4 9c 00 00 00 	addl   $0x9c,-0xc(%ebp)
801060f9:	81 7d f4 b4 70 11 80 	cmpl   $0x801170b4,-0xc(%ebp)
80106100:	73 0c                	jae    8010610e <getprocs+0x1e2>
80106102:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106105:	3b 45 08             	cmp    0x8(%ebp),%eax
80106108:	0f 8c 47 fe ff ff    	jl     80105f55 <getprocs+0x29>

    }
  }

  //UNLOCK PTABLE
  release(&ptable.lock);
8010610e:	83 ec 0c             	sub    $0xc,%esp
80106111:	68 80 49 11 80       	push   $0x80114980
80106116:	e8 af 07 00 00       	call   801068ca <release>
8010611b:	83 c4 10             	add    $0x10,%esp

  return i;
8010611e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106121:	c9                   	leave  
80106122:	c3                   	ret    

80106123 <piddump>:

void
piddump(void)
{
80106123:	55                   	push   %ebp
80106124:	89 e5                	mov    %esp,%ebp
80106126:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  acquire(&ptable.lock);
80106129:	83 ec 0c             	sub    $0xc,%esp
8010612c:	68 80 49 11 80       	push   $0x80114980
80106131:	e8 2d 07 00 00       	call   80106863 <acquire>
80106136:	83 c4 10             	add    $0x10,%esp
  cprintf("\nReady List Processes:\n");
80106139:	83 ec 0c             	sub    $0xc,%esp
8010613c:	68 bd a5 10 80       	push   $0x8010a5bd
80106141:	e8 80 a2 ff ff       	call   801003c6 <cprintf>
80106146:	83 c4 10             	add    $0x10,%esp
  for(int i = 0; i<MAXPRIO+1; ++i)
80106149:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80106150:	e9 8b 00 00 00       	jmp    801061e0 <piddump+0xbd>
  {
    p = ptable.pLists.ready[i];
80106155:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106158:	05 cc 09 00 00       	add    $0x9cc,%eax
8010615d:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
80106164:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("%d: ", i);
80106167:	83 ec 08             	sub    $0x8,%esp
8010616a:	ff 75 f0             	pushl  -0x10(%ebp)
8010616d:	68 d5 a5 10 80       	push   $0x8010a5d5
80106172:	e8 4f a2 ff ff       	call   801003c6 <cprintf>
80106177:	83 c4 10             	add    $0x10,%esp
    while(p)
8010617a:	eb 4a                	jmp    801061c6 <piddump+0xa3>
    {
      cprintf("(%d, %d)", p->pid, p->budget);
8010617c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010617f:	8b 90 94 00 00 00    	mov    0x94(%eax),%edx
80106185:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106188:	8b 40 10             	mov    0x10(%eax),%eax
8010618b:	83 ec 04             	sub    $0x4,%esp
8010618e:	52                   	push   %edx
8010618f:	50                   	push   %eax
80106190:	68 da a5 10 80       	push   $0x8010a5da
80106195:	e8 2c a2 ff ff       	call   801003c6 <cprintf>
8010619a:	83 c4 10             	add    $0x10,%esp
      if(p->next)
8010619d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061a0:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801061a6:	85 c0                	test   %eax,%eax
801061a8:	74 10                	je     801061ba <piddump+0x97>
        cprintf(" -> ");
801061aa:	83 ec 0c             	sub    $0xc,%esp
801061ad:	68 e3 a5 10 80       	push   $0x8010a5e3
801061b2:	e8 0f a2 ff ff       	call   801003c6 <cprintf>
801061b7:	83 c4 10             	add    $0x10,%esp
      p = p->next;
801061ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061bd:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801061c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cprintf("\nReady List Processes:\n");
  for(int i = 0; i<MAXPRIO+1; ++i)
  {
    p = ptable.pLists.ready[i];
    cprintf("%d: ", i);
    while(p)
801061c6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061ca:	75 b0                	jne    8010617c <piddump+0x59>
      cprintf("(%d, %d)", p->pid, p->budget);
      if(p->next)
        cprintf(" -> ");
      p = p->next;
    }
    cprintf("\n");
801061cc:	83 ec 0c             	sub    $0xc,%esp
801061cf:	68 85 a5 10 80       	push   $0x8010a585
801061d4:	e8 ed a1 ff ff       	call   801003c6 <cprintf>
801061d9:	83 c4 10             	add    $0x10,%esp
piddump(void)
{
  struct proc *p;
  acquire(&ptable.lock);
  cprintf("\nReady List Processes:\n");
  for(int i = 0; i<MAXPRIO+1; ++i)
801061dc:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801061e0:	83 7d f0 01          	cmpl   $0x1,-0x10(%ebp)
801061e4:	0f 8e 6b ff ff ff    	jle    80106155 <piddump+0x32>
        cprintf(" -> ");
      p = p->next;
    }
    cprintf("\n");
  }
  release(&ptable.lock);
801061ea:	83 ec 0c             	sub    $0xc,%esp
801061ed:	68 80 49 11 80       	push   $0x80114980
801061f2:	e8 d3 06 00 00       	call   801068ca <release>
801061f7:	83 c4 10             	add    $0x10,%esp
}
801061fa:	90                   	nop
801061fb:	c9                   	leave  
801061fc:	c3                   	ret    

801061fd <freedump>:

void
freedump(void)
{
801061fd:	55                   	push   %ebp
801061fe:	89 e5                	mov    %esp,%ebp
80106200:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int counter = 0;
80106203:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  acquire(&ptable.lock);
8010620a:	83 ec 0c             	sub    $0xc,%esp
8010620d:	68 80 49 11 80       	push   $0x80114980
80106212:	e8 4c 06 00 00       	call   80106863 <acquire>
80106217:	83 c4 10             	add    $0x10,%esp
  p = ptable.pLists.free;
8010621a:	a1 c4 70 11 80       	mov    0x801170c4,%eax
8010621f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(p)
80106222:	eb 10                	jmp    80106234 <freedump+0x37>
  {
    p = p->next;
80106224:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106227:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010622d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    ++counter;
80106230:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
{
  struct proc *p;
  int counter = 0;
  acquire(&ptable.lock);
  p = ptable.pLists.free;
  while(p)
80106234:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106238:	75 ea                	jne    80106224 <freedump+0x27>
  {
    p = p->next;
    ++counter;
  }

  cprintf("\nFree List Size: %d processes\n", counter);
8010623a:	83 ec 08             	sub    $0x8,%esp
8010623d:	ff 75 f0             	pushl  -0x10(%ebp)
80106240:	68 e8 a5 10 80       	push   $0x8010a5e8
80106245:	e8 7c a1 ff ff       	call   801003c6 <cprintf>
8010624a:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
8010624d:	83 ec 0c             	sub    $0xc,%esp
80106250:	68 80 49 11 80       	push   $0x80114980
80106255:	e8 70 06 00 00       	call   801068ca <release>
8010625a:	83 c4 10             	add    $0x10,%esp
}
8010625d:	90                   	nop
8010625e:	c9                   	leave  
8010625f:	c3                   	ret    

80106260 <sleepdump>:

void
sleepdump(void)
{
80106260:	55                   	push   %ebp
80106261:	89 e5                	mov    %esp,%ebp
80106263:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  acquire(&ptable.lock);
80106266:	83 ec 0c             	sub    $0xc,%esp
80106269:	68 80 49 11 80       	push   $0x80114980
8010626e:	e8 f0 05 00 00       	call   80106863 <acquire>
80106273:	83 c4 10             	add    $0x10,%esp
  p = ptable.pLists.sleep;
80106276:	a1 cc 70 11 80       	mov    0x801170cc,%eax
8010627b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cprintf("\nSleep List Processes:\n");
8010627e:	83 ec 0c             	sub    $0xc,%esp
80106281:	68 07 a6 10 80       	push   $0x8010a607
80106286:	e8 3b a1 ff ff       	call   801003c6 <cprintf>
8010628b:	83 c4 10             	add    $0x10,%esp
  while(p)
8010628e:	eb 40                	jmp    801062d0 <sleepdump+0x70>
  {
    cprintf("%d", p->pid);
80106290:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106293:	8b 40 10             	mov    0x10(%eax),%eax
80106296:	83 ec 08             	sub    $0x8,%esp
80106299:	50                   	push   %eax
8010629a:	68 74 a5 10 80       	push   $0x8010a574
8010629f:	e8 22 a1 ff ff       	call   801003c6 <cprintf>
801062a4:	83 c4 10             	add    $0x10,%esp
    if(p->next)
801062a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062aa:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801062b0:	85 c0                	test   %eax,%eax
801062b2:	74 10                	je     801062c4 <sleepdump+0x64>
      cprintf(" -> ");
801062b4:	83 ec 0c             	sub    $0xc,%esp
801062b7:	68 e3 a5 10 80       	push   $0x8010a5e3
801062bc:	e8 05 a1 ff ff       	call   801003c6 <cprintf>
801062c1:	83 c4 10             	add    $0x10,%esp
    p = p->next;
801062c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062c7:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801062cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
{
  struct proc *p;
  acquire(&ptable.lock);
  p = ptable.pLists.sleep;
  cprintf("\nSleep List Processes:\n");
  while(p)
801062d0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062d4:	75 ba                	jne    80106290 <sleepdump+0x30>
    cprintf("%d", p->pid);
    if(p->next)
      cprintf(" -> ");
    p = p->next;
  }
  cprintf("\n");
801062d6:	83 ec 0c             	sub    $0xc,%esp
801062d9:	68 85 a5 10 80       	push   $0x8010a585
801062de:	e8 e3 a0 ff ff       	call   801003c6 <cprintf>
801062e3:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801062e6:	83 ec 0c             	sub    $0xc,%esp
801062e9:	68 80 49 11 80       	push   $0x80114980
801062ee:	e8 d7 05 00 00       	call   801068ca <release>
801062f3:	83 c4 10             	add    $0x10,%esp
}
801062f6:	90                   	nop
801062f7:	c9                   	leave  
801062f8:	c3                   	ret    

801062f9 <zombiedump>:

void
zombiedump(void)
{
801062f9:	55                   	push   %ebp
801062fa:	89 e5                	mov    %esp,%ebp
801062fc:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  acquire(&ptable.lock);
801062ff:	83 ec 0c             	sub    $0xc,%esp
80106302:	68 80 49 11 80       	push   $0x80114980
80106307:	e8 57 05 00 00       	call   80106863 <acquire>
8010630c:	83 c4 10             	add    $0x10,%esp
  p = ptable.pLists.zombie;
8010630f:	a1 d4 70 11 80       	mov    0x801170d4,%eax
80106314:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cprintf("\nZombie List Processes:\n");
80106317:	83 ec 0c             	sub    $0xc,%esp
8010631a:	68 1f a6 10 80       	push   $0x8010a61f
8010631f:	e8 a2 a0 ff ff       	call   801003c6 <cprintf>
80106324:	83 c4 10             	add    $0x10,%esp
  while(p)
80106327:	eb 5c                	jmp    80106385 <zombiedump+0x8c>
  {
    cprintf("(PID%d, PPID%d)", p->pid, (p->parent? p->parent->pid : p->pid));
80106329:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010632c:	8b 40 14             	mov    0x14(%eax),%eax
8010632f:	85 c0                	test   %eax,%eax
80106331:	74 0b                	je     8010633e <zombiedump+0x45>
80106333:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106336:	8b 40 14             	mov    0x14(%eax),%eax
80106339:	8b 40 10             	mov    0x10(%eax),%eax
8010633c:	eb 06                	jmp    80106344 <zombiedump+0x4b>
8010633e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106341:	8b 40 10             	mov    0x10(%eax),%eax
80106344:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106347:	8b 52 10             	mov    0x10(%edx),%edx
8010634a:	83 ec 04             	sub    $0x4,%esp
8010634d:	50                   	push   %eax
8010634e:	52                   	push   %edx
8010634f:	68 38 a6 10 80       	push   $0x8010a638
80106354:	e8 6d a0 ff ff       	call   801003c6 <cprintf>
80106359:	83 c4 10             	add    $0x10,%esp
    if(p->next)
8010635c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010635f:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106365:	85 c0                	test   %eax,%eax
80106367:	74 10                	je     80106379 <zombiedump+0x80>
      cprintf(" -> ");
80106369:	83 ec 0c             	sub    $0xc,%esp
8010636c:	68 e3 a5 10 80       	push   $0x8010a5e3
80106371:	e8 50 a0 ff ff       	call   801003c6 <cprintf>
80106376:	83 c4 10             	add    $0x10,%esp
    p = p->next;
80106379:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010637c:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106382:	89 45 f4             	mov    %eax,-0xc(%ebp)
{
  struct proc *p;
  acquire(&ptable.lock);
  p = ptable.pLists.zombie;
  cprintf("\nZombie List Processes:\n");
  while(p)
80106385:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106389:	75 9e                	jne    80106329 <zombiedump+0x30>
    cprintf("(PID%d, PPID%d)", p->pid, (p->parent? p->parent->pid : p->pid));
    if(p->next)
      cprintf(" -> ");
    p = p->next;
  }
  cprintf("\n");
8010638b:	83 ec 0c             	sub    $0xc,%esp
8010638e:	68 85 a5 10 80       	push   $0x8010a585
80106393:	e8 2e a0 ff ff       	call   801003c6 <cprintf>
80106398:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
8010639b:	83 ec 0c             	sub    $0xc,%esp
8010639e:	68 80 49 11 80       	push   $0x80114980
801063a3:	e8 22 05 00 00       	call   801068ca <release>
801063a8:	83 c4 10             	add    $0x10,%esp
}
801063ab:	90                   	nop
801063ac:	c9                   	leave  
801063ad:	c3                   	ret    

801063ae <assertState>:

void
assertState(struct proc* p, enum procstate state)
{
801063ae:	55                   	push   %ebp
801063af:	89 e5                	mov    %esp,%ebp
801063b1:	83 ec 08             	sub    $0x8,%esp
  if(p->state != state)
801063b4:	8b 45 08             	mov    0x8(%ebp),%eax
801063b7:	8b 40 0c             	mov    0xc(%eax),%eax
801063ba:	3b 45 0c             	cmp    0xc(%ebp),%eax
801063bd:	74 0d                	je     801063cc <assertState+0x1e>
    panic("proc state does not match list state.");
801063bf:	83 ec 0c             	sub    $0xc,%esp
801063c2:	68 48 a6 10 80       	push   $0x8010a648
801063c7:	e8 9a a1 ff ff       	call   80100566 <panic>
}
801063cc:	90                   	nop
801063cd:	c9                   	leave  
801063ce:	c3                   	ret    

801063cf <setpriority>:

int
setpriority(int pid, int priority)
{
801063cf:	55                   	push   %ebp
801063d0:	89 e5                	mov    %esp,%ebp
801063d2:	83 ec 18             	sub    $0x18,%esp
  struct proc* p;
  if(pid<0 || priority < 0 || priority > MAXPRIO+1)
801063d5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801063d9:	78 0c                	js     801063e7 <setpriority+0x18>
801063db:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801063df:	78 06                	js     801063e7 <setpriority+0x18>
801063e1:	83 7d 0c 02          	cmpl   $0x2,0xc(%ebp)
801063e5:	7e 0a                	jle    801063f1 <setpriority+0x22>
    return -1;
801063e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063ec:	e9 40 02 00 00       	jmp    80106631 <setpriority+0x262>

  acquire(&ptable.lock);
801063f1:	83 ec 0c             	sub    $0xc,%esp
801063f4:	68 80 49 11 80       	push   $0x80114980
801063f9:	e8 65 04 00 00       	call   80106863 <acquire>
801063fe:	83 c4 10             	add    $0x10,%esp
  for(int i = 0; i < MAXPRIO+1; ++i)
80106401:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80106408:	e9 3a 01 00 00       	jmp    80106547 <setpriority+0x178>
  {
    for(p = ptable.pLists.ready[i];p;p=p->next)
8010640d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106410:	05 cc 09 00 00       	add    $0x9cc,%eax
80106415:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
8010641c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010641f:	e9 15 01 00 00       	jmp    80106539 <setpriority+0x16a>
    {
      if(p->pid == pid && priority != p->priority)
80106424:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106427:	8b 50 10             	mov    0x10(%eax),%edx
8010642a:	8b 45 08             	mov    0x8(%ebp),%eax
8010642d:	39 c2                	cmp    %eax,%edx
8010642f:	0f 85 f8 00 00 00    	jne    8010652d <setpriority+0x15e>
80106435:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106438:	8b 90 98 00 00 00    	mov    0x98(%eax),%edx
8010643e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106441:	39 c2                	cmp    %eax,%edx
80106443:	0f 84 e4 00 00 00    	je     8010652d <setpriority+0x15e>
      {
#ifdef CS333_P3P4
        if(stateListRemove(&ptable.pLists.ready[p->priority], &ptable.pLists.readyTail[p->priority], p))
80106449:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010644c:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80106452:	05 cc 09 00 00       	add    $0x9cc,%eax
80106457:	c1 e0 02             	shl    $0x2,%eax
8010645a:	05 80 49 11 80       	add    $0x80114980,%eax
8010645f:	8d 50 0c             	lea    0xc(%eax),%edx
80106462:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106465:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
8010646b:	05 cc 09 00 00       	add    $0x9cc,%eax
80106470:	c1 e0 02             	shl    $0x2,%eax
80106473:	05 80 49 11 80       	add    $0x80114980,%eax
80106478:	83 c0 04             	add    $0x4,%eax
8010647b:	83 ec 04             	sub    $0x4,%esp
8010647e:	ff 75 f4             	pushl  -0xc(%ebp)
80106481:	52                   	push   %edx
80106482:	50                   	push   %eax
80106483:	e8 c9 f8 ff ff       	call   80105d51 <stateListRemove>
80106488:	83 c4 10             	add    $0x10,%esp
8010648b:	85 c0                	test   %eax,%eax
8010648d:	74 0d                	je     8010649c <setpriority+0xcd>
          panic("Error removing process from current priority");
8010648f:	83 ec 0c             	sub    $0xc,%esp
80106492:	68 70 a6 10 80       	push   $0x8010a670
80106497:	e8 ca a0 ff ff       	call   80100566 <panic>
        p->priority = priority;
8010649c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010649f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064a2:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
        if(stateListAdd(&ptable.pLists.ready[p->priority], &ptable.pLists.readyTail[p->priority], p))
801064a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064ab:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801064b1:	05 cc 09 00 00       	add    $0x9cc,%eax
801064b6:	c1 e0 02             	shl    $0x2,%eax
801064b9:	05 80 49 11 80       	add    $0x80114980,%eax
801064be:	8d 50 0c             	lea    0xc(%eax),%edx
801064c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064c4:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801064ca:	05 cc 09 00 00       	add    $0x9cc,%eax
801064cf:	c1 e0 02             	shl    $0x2,%eax
801064d2:	05 80 49 11 80       	add    $0x80114980,%eax
801064d7:	83 c0 04             	add    $0x4,%eax
801064da:	83 ec 04             	sub    $0x4,%esp
801064dd:	ff 75 f4             	pushl  -0xc(%ebp)
801064e0:	52                   	push   %edx
801064e1:	50                   	push   %eax
801064e2:	e8 0b f8 ff ff       	call   80105cf2 <stateListAdd>
801064e7:	83 c4 10             	add    $0x10,%esp
801064ea:	85 c0                	test   %eax,%eax
801064ec:	74 0d                	je     801064fb <setpriority+0x12c>
          panic("Error adding process to current priority");
801064ee:	83 ec 0c             	sub    $0xc,%esp
801064f1:	68 a0 a6 10 80       	push   $0x8010a6a0
801064f6:	e8 6b a0 ff ff       	call   80100566 <panic>
#endif
        p->budget = BUDGET*(p->priority+1);
801064fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064fe:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80106504:	83 c0 01             	add    $0x1,%eax
80106507:	6b d0 64             	imul   $0x64,%eax,%edx
8010650a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010650d:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
        release(&ptable.lock);
80106513:	83 ec 0c             	sub    $0xc,%esp
80106516:	68 80 49 11 80       	push   $0x80114980
8010651b:	e8 aa 03 00 00       	call   801068ca <release>
80106520:	83 c4 10             	add    $0x10,%esp
        return 0;
80106523:	b8 00 00 00 00       	mov    $0x0,%eax
80106528:	e9 04 01 00 00       	jmp    80106631 <setpriority+0x262>
    return -1;

  acquire(&ptable.lock);
  for(int i = 0; i < MAXPRIO+1; ++i)
  {
    for(p = ptable.pLists.ready[i];p;p=p->next)
8010652d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106530:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106536:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106539:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010653d:	0f 85 e1 fe ff ff    	jne    80106424 <setpriority+0x55>
  struct proc* p;
  if(pid<0 || priority < 0 || priority > MAXPRIO+1)
    return -1;

  acquire(&ptable.lock);
  for(int i = 0; i < MAXPRIO+1; ++i)
80106543:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80106547:	83 7d f0 01          	cmpl   $0x1,-0x10(%ebp)
8010654b:	0f 8e bc fe ff ff    	jle    8010640d <setpriority+0x3e>
        release(&ptable.lock);
        return 0;
      }
    }
  }
  for(p = ptable.pLists.sleep; p ; p=p->next)
80106551:	a1 cc 70 11 80       	mov    0x801170cc,%eax
80106556:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106559:	eb 57                	jmp    801065b2 <setpriority+0x1e3>
  {
    if(p->pid == pid)
8010655b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010655e:	8b 50 10             	mov    0x10(%eax),%edx
80106561:	8b 45 08             	mov    0x8(%ebp),%eax
80106564:	39 c2                	cmp    %eax,%edx
80106566:	75 3e                	jne    801065a6 <setpriority+0x1d7>
    {
      p->priority = priority;
80106568:	8b 55 0c             	mov    0xc(%ebp),%edx
8010656b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010656e:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
      p->budget = BUDGET*(p->priority+1);
80106574:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106577:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
8010657d:	83 c0 01             	add    $0x1,%eax
80106580:	6b d0 64             	imul   $0x64,%eax,%edx
80106583:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106586:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
      release(&ptable.lock);
8010658c:	83 ec 0c             	sub    $0xc,%esp
8010658f:	68 80 49 11 80       	push   $0x80114980
80106594:	e8 31 03 00 00       	call   801068ca <release>
80106599:	83 c4 10             	add    $0x10,%esp
      return 0;
8010659c:	b8 00 00 00 00       	mov    $0x0,%eax
801065a1:	e9 8b 00 00 00       	jmp    80106631 <setpriority+0x262>
        release(&ptable.lock);
        return 0;
      }
    }
  }
  for(p = ptable.pLists.sleep; p ; p=p->next)
801065a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065a9:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801065af:	89 45 f4             	mov    %eax,-0xc(%ebp)
801065b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065b6:	75 a3                	jne    8010655b <setpriority+0x18c>
      release(&ptable.lock);
      return 0;
    }
  }

  for(p = ptable.pLists.running; p ; p=p->next)
801065b8:	a1 dc 70 11 80       	mov    0x801170dc,%eax
801065bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801065c0:	eb 54                	jmp    80106616 <setpriority+0x247>
  {
    if(p->pid == pid)
801065c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065c5:	8b 50 10             	mov    0x10(%eax),%edx
801065c8:	8b 45 08             	mov    0x8(%ebp),%eax
801065cb:	39 c2                	cmp    %eax,%edx
801065cd:	75 3b                	jne    8010660a <setpriority+0x23b>
    {
      p->priority = priority;
801065cf:	8b 55 0c             	mov    0xc(%ebp),%edx
801065d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065d5:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
      p->budget = BUDGET*(p->priority+1);
801065db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065de:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801065e4:	83 c0 01             	add    $0x1,%eax
801065e7:	6b d0 64             	imul   $0x64,%eax,%edx
801065ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065ed:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
      release(&ptable.lock);
801065f3:	83 ec 0c             	sub    $0xc,%esp
801065f6:	68 80 49 11 80       	push   $0x80114980
801065fb:	e8 ca 02 00 00       	call   801068ca <release>
80106600:	83 c4 10             	add    $0x10,%esp
      return 0;
80106603:	b8 00 00 00 00       	mov    $0x0,%eax
80106608:	eb 27                	jmp    80106631 <setpriority+0x262>
      release(&ptable.lock);
      return 0;
    }
  }

  for(p = ptable.pLists.running; p ; p=p->next)
8010660a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010660d:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106613:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106616:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010661a:	75 a6                	jne    801065c2 <setpriority+0x1f3>
      release(&ptable.lock);
      return 0;
    }
  }

  release(&ptable.lock);
8010661c:	83 ec 0c             	sub    $0xc,%esp
8010661f:	68 80 49 11 80       	push   $0x80114980
80106624:	e8 a1 02 00 00       	call   801068ca <release>
80106629:	83 c4 10             	add    $0x10,%esp
  return -1;
8010662c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106631:	c9                   	leave  
80106632:	c3                   	ret    

80106633 <promoteAll>:

void
promoteAll(void)
{
80106633:	55                   	push   %ebp
80106634:	89 e5                	mov    %esp,%ebp
80106636:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  for(int i = 0; i < MAXPRIO+1; ++i)
80106639:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80106640:	e9 0b 01 00 00       	jmp    80106750 <promoteAll+0x11d>
  {
    for(p = ptable.pLists.ready[i]; p; p=p->next)
80106645:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106648:	05 cc 09 00 00       	add    $0x9cc,%eax
8010664d:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
80106654:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106657:	e9 e6 00 00 00       	jmp    80106742 <promoteAll+0x10f>
    {
      if(i>0)
8010665c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106660:	0f 8e b8 00 00 00    	jle    8010671e <promoteAll+0xeb>
      {
#ifdef CS333_P3P4
        if(stateListRemove(&ptable.pLists.ready[p->priority], &ptable.pLists.readyTail[p->priority], p))
80106666:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106669:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
8010666f:	05 cc 09 00 00       	add    $0x9cc,%eax
80106674:	c1 e0 02             	shl    $0x2,%eax
80106677:	05 80 49 11 80       	add    $0x80114980,%eax
8010667c:	8d 50 0c             	lea    0xc(%eax),%edx
8010667f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106682:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80106688:	05 cc 09 00 00       	add    $0x9cc,%eax
8010668d:	c1 e0 02             	shl    $0x2,%eax
80106690:	05 80 49 11 80       	add    $0x80114980,%eax
80106695:	83 c0 04             	add    $0x4,%eax
80106698:	ff 75 f4             	pushl  -0xc(%ebp)
8010669b:	52                   	push   %edx
8010669c:	50                   	push   %eax
8010669d:	e8 af f6 ff ff       	call   80105d51 <stateListRemove>
801066a2:	83 c4 0c             	add    $0xc,%esp
801066a5:	85 c0                	test   %eax,%eax
801066a7:	74 0d                	je     801066b6 <promoteAll+0x83>
          panic("Error removing process from current priority");
801066a9:	83 ec 0c             	sub    $0xc,%esp
801066ac:	68 70 a6 10 80       	push   $0x8010a670
801066b1:	e8 b0 9e ff ff       	call   80100566 <panic>
        p->priority -= 1;
801066b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066b9:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801066bf:	8d 50 ff             	lea    -0x1(%eax),%edx
801066c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066c5:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
        if(stateListAdd(&ptable.pLists.ready[p->priority], &ptable.pLists.readyTail[p->priority], p))
801066cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066ce:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801066d4:	05 cc 09 00 00       	add    $0x9cc,%eax
801066d9:	c1 e0 02             	shl    $0x2,%eax
801066dc:	05 80 49 11 80       	add    $0x80114980,%eax
801066e1:	8d 50 0c             	lea    0xc(%eax),%edx
801066e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066e7:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801066ed:	05 cc 09 00 00       	add    $0x9cc,%eax
801066f2:	c1 e0 02             	shl    $0x2,%eax
801066f5:	05 80 49 11 80       	add    $0x80114980,%eax
801066fa:	83 c0 04             	add    $0x4,%eax
801066fd:	83 ec 04             	sub    $0x4,%esp
80106700:	ff 75 f4             	pushl  -0xc(%ebp)
80106703:	52                   	push   %edx
80106704:	50                   	push   %eax
80106705:	e8 e8 f5 ff ff       	call   80105cf2 <stateListAdd>
8010670a:	83 c4 10             	add    $0x10,%esp
8010670d:	85 c0                	test   %eax,%eax
8010670f:	74 0d                	je     8010671e <promoteAll+0xeb>
          panic("Error adding process to desired priority");
80106711:	83 ec 0c             	sub    $0xc,%esp
80106714:	68 cc a6 10 80       	push   $0x8010a6cc
80106719:	e8 48 9e ff ff       	call   80100566 <panic>
#endif
      }
      p->budget = BUDGET*(p->priority+1);
8010671e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106721:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80106727:	83 c0 01             	add    $0x1,%eax
8010672a:	6b d0 64             	imul   $0x64,%eax,%edx
8010672d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106730:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
promoteAll(void)
{
  struct proc *p;
  for(int i = 0; i < MAXPRIO+1; ++i)
  {
    for(p = ptable.pLists.ready[i]; p; p=p->next)
80106736:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106739:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010673f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106742:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106746:	0f 85 10 ff ff ff    	jne    8010665c <promoteAll+0x29>

void
promoteAll(void)
{
  struct proc *p;
  for(int i = 0; i < MAXPRIO+1; ++i)
8010674c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80106750:	83 7d f0 01          	cmpl   $0x1,-0x10(%ebp)
80106754:	0f 8e eb fe ff ff    	jle    80106645 <promoteAll+0x12>
#endif
      }
      p->budget = BUDGET*(p->priority+1);
    }
  }
  for(p = ptable.pLists.sleep; p; p=p->next)
8010675a:	a1 cc 70 11 80       	mov    0x801170cc,%eax
8010675f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106762:	eb 46                	jmp    801067aa <promoteAll+0x177>
  {
    if(p->priority > 0)
80106764:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106767:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
8010676d:	85 c0                	test   %eax,%eax
8010676f:	74 15                	je     80106786 <promoteAll+0x153>
    {
      p->priority -= 1;
80106771:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106774:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
8010677a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010677d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106780:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
    }
    p->budget = BUDGET*(p->priority+1);
80106786:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106789:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
8010678f:	83 c0 01             	add    $0x1,%eax
80106792:	6b d0 64             	imul   $0x64,%eax,%edx
80106795:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106798:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
#endif
      }
      p->budget = BUDGET*(p->priority+1);
    }
  }
  for(p = ptable.pLists.sleep; p; p=p->next)
8010679e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067a1:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801067a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067aa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067ae:	75 b4                	jne    80106764 <promoteAll+0x131>
    {
      p->priority -= 1;
    }
    p->budget = BUDGET*(p->priority+1);
  }
  for(p = ptable.pLists.running; p; p=p->next)
801067b0:	a1 dc 70 11 80       	mov    0x801170dc,%eax
801067b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067b8:	eb 46                	jmp    80106800 <promoteAll+0x1cd>
  {
    if(p->priority > 0)
801067ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067bd:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801067c3:	85 c0                	test   %eax,%eax
801067c5:	74 15                	je     801067dc <promoteAll+0x1a9>
    {
      p->priority -= 1;
801067c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067ca:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801067d0:	8d 50 ff             	lea    -0x1(%eax),%edx
801067d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067d6:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
    }
    p->budget = BUDGET*(p->priority+1);
801067dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067df:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801067e5:	83 c0 01             	add    $0x1,%eax
801067e8:	6b d0 64             	imul   $0x64,%eax,%edx
801067eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067ee:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
    {
      p->priority -= 1;
    }
    p->budget = BUDGET*(p->priority+1);
  }
  for(p = ptable.pLists.running; p; p=p->next)
801067f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067f7:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801067fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106800:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106804:	75 b4                	jne    801067ba <promoteAll+0x187>
    {
      p->priority -= 1;
    }
    p->budget = BUDGET*(p->priority+1);
  }
}
80106806:	90                   	nop
80106807:	c9                   	leave  
80106808:	c3                   	ret    

80106809 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80106809:	55                   	push   %ebp
8010680a:	89 e5                	mov    %esp,%ebp
8010680c:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010680f:	9c                   	pushf  
80106810:	58                   	pop    %eax
80106811:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80106814:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106817:	c9                   	leave  
80106818:	c3                   	ret    

80106819 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80106819:	55                   	push   %ebp
8010681a:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010681c:	fa                   	cli    
}
8010681d:	90                   	nop
8010681e:	5d                   	pop    %ebp
8010681f:	c3                   	ret    

80106820 <sti>:

static inline void
sti(void)
{
80106820:	55                   	push   %ebp
80106821:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80106823:	fb                   	sti    
}
80106824:	90                   	nop
80106825:	5d                   	pop    %ebp
80106826:	c3                   	ret    

80106827 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80106827:	55                   	push   %ebp
80106828:	89 e5                	mov    %esp,%ebp
8010682a:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010682d:	8b 55 08             	mov    0x8(%ebp),%edx
80106830:	8b 45 0c             	mov    0xc(%ebp),%eax
80106833:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106836:	f0 87 02             	lock xchg %eax,(%edx)
80106839:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010683c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010683f:	c9                   	leave  
80106840:	c3                   	ret    

80106841 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80106841:	55                   	push   %ebp
80106842:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80106844:	8b 45 08             	mov    0x8(%ebp),%eax
80106847:	8b 55 0c             	mov    0xc(%ebp),%edx
8010684a:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010684d:	8b 45 08             	mov    0x8(%ebp),%eax
80106850:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80106856:	8b 45 08             	mov    0x8(%ebp),%eax
80106859:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80106860:	90                   	nop
80106861:	5d                   	pop    %ebp
80106862:	c3                   	ret    

80106863 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80106863:	55                   	push   %ebp
80106864:	89 e5                	mov    %esp,%ebp
80106866:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80106869:	e8 52 01 00 00       	call   801069c0 <pushcli>
  if(holding(lk))
8010686e:	8b 45 08             	mov    0x8(%ebp),%eax
80106871:	83 ec 0c             	sub    $0xc,%esp
80106874:	50                   	push   %eax
80106875:	e8 1c 01 00 00       	call   80106996 <holding>
8010687a:	83 c4 10             	add    $0x10,%esp
8010687d:	85 c0                	test   %eax,%eax
8010687f:	74 0d                	je     8010688e <acquire+0x2b>
    panic("acquire");
80106881:	83 ec 0c             	sub    $0xc,%esp
80106884:	68 f5 a6 10 80       	push   $0x8010a6f5
80106889:	e8 d8 9c ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
8010688e:	90                   	nop
8010688f:	8b 45 08             	mov    0x8(%ebp),%eax
80106892:	83 ec 08             	sub    $0x8,%esp
80106895:	6a 01                	push   $0x1
80106897:	50                   	push   %eax
80106898:	e8 8a ff ff ff       	call   80106827 <xchg>
8010689d:	83 c4 10             	add    $0x10,%esp
801068a0:	85 c0                	test   %eax,%eax
801068a2:	75 eb                	jne    8010688f <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801068a4:	8b 45 08             	mov    0x8(%ebp),%eax
801068a7:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801068ae:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
801068b1:	8b 45 08             	mov    0x8(%ebp),%eax
801068b4:	83 c0 0c             	add    $0xc,%eax
801068b7:	83 ec 08             	sub    $0x8,%esp
801068ba:	50                   	push   %eax
801068bb:	8d 45 08             	lea    0x8(%ebp),%eax
801068be:	50                   	push   %eax
801068bf:	e8 58 00 00 00       	call   8010691c <getcallerpcs>
801068c4:	83 c4 10             	add    $0x10,%esp
}
801068c7:	90                   	nop
801068c8:	c9                   	leave  
801068c9:	c3                   	ret    

801068ca <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801068ca:	55                   	push   %ebp
801068cb:	89 e5                	mov    %esp,%ebp
801068cd:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801068d0:	83 ec 0c             	sub    $0xc,%esp
801068d3:	ff 75 08             	pushl  0x8(%ebp)
801068d6:	e8 bb 00 00 00       	call   80106996 <holding>
801068db:	83 c4 10             	add    $0x10,%esp
801068de:	85 c0                	test   %eax,%eax
801068e0:	75 0d                	jne    801068ef <release+0x25>
    panic("release");
801068e2:	83 ec 0c             	sub    $0xc,%esp
801068e5:	68 fd a6 10 80       	push   $0x8010a6fd
801068ea:	e8 77 9c ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
801068ef:	8b 45 08             	mov    0x8(%ebp),%eax
801068f2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801068f9:	8b 45 08             	mov    0x8(%ebp),%eax
801068fc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80106903:	8b 45 08             	mov    0x8(%ebp),%eax
80106906:	83 ec 08             	sub    $0x8,%esp
80106909:	6a 00                	push   $0x0
8010690b:	50                   	push   %eax
8010690c:	e8 16 ff ff ff       	call   80106827 <xchg>
80106911:	83 c4 10             	add    $0x10,%esp

  popcli();
80106914:	e8 ec 00 00 00       	call   80106a05 <popcli>
}
80106919:	90                   	nop
8010691a:	c9                   	leave  
8010691b:	c3                   	ret    

8010691c <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010691c:	55                   	push   %ebp
8010691d:	89 e5                	mov    %esp,%ebp
8010691f:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80106922:	8b 45 08             	mov    0x8(%ebp),%eax
80106925:	83 e8 08             	sub    $0x8,%eax
80106928:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010692b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80106932:	eb 38                	jmp    8010696c <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80106934:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80106938:	74 53                	je     8010698d <getcallerpcs+0x71>
8010693a:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80106941:	76 4a                	jbe    8010698d <getcallerpcs+0x71>
80106943:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80106947:	74 44                	je     8010698d <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80106949:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010694c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106953:	8b 45 0c             	mov    0xc(%ebp),%eax
80106956:	01 c2                	add    %eax,%edx
80106958:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010695b:	8b 40 04             	mov    0x4(%eax),%eax
8010695e:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80106960:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106963:	8b 00                	mov    (%eax),%eax
80106965:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80106968:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010696c:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80106970:	7e c2                	jle    80106934 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80106972:	eb 19                	jmp    8010698d <getcallerpcs+0x71>
    pcs[i] = 0;
80106974:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106977:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010697e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106981:	01 d0                	add    %edx,%eax
80106983:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80106989:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010698d:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80106991:	7e e1                	jle    80106974 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80106993:	90                   	nop
80106994:	c9                   	leave  
80106995:	c3                   	ret    

80106996 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80106996:	55                   	push   %ebp
80106997:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80106999:	8b 45 08             	mov    0x8(%ebp),%eax
8010699c:	8b 00                	mov    (%eax),%eax
8010699e:	85 c0                	test   %eax,%eax
801069a0:	74 17                	je     801069b9 <holding+0x23>
801069a2:	8b 45 08             	mov    0x8(%ebp),%eax
801069a5:	8b 50 08             	mov    0x8(%eax),%edx
801069a8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801069ae:	39 c2                	cmp    %eax,%edx
801069b0:	75 07                	jne    801069b9 <holding+0x23>
801069b2:	b8 01 00 00 00       	mov    $0x1,%eax
801069b7:	eb 05                	jmp    801069be <holding+0x28>
801069b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801069be:	5d                   	pop    %ebp
801069bf:	c3                   	ret    

801069c0 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801069c0:	55                   	push   %ebp
801069c1:	89 e5                	mov    %esp,%ebp
801069c3:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
801069c6:	e8 3e fe ff ff       	call   80106809 <readeflags>
801069cb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
801069ce:	e8 46 fe ff ff       	call   80106819 <cli>
  if(cpu->ncli++ == 0)
801069d3:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801069da:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
801069e0:	8d 48 01             	lea    0x1(%eax),%ecx
801069e3:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
801069e9:	85 c0                	test   %eax,%eax
801069eb:	75 15                	jne    80106a02 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
801069ed:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801069f3:	8b 55 fc             	mov    -0x4(%ebp),%edx
801069f6:	81 e2 00 02 00 00    	and    $0x200,%edx
801069fc:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80106a02:	90                   	nop
80106a03:	c9                   	leave  
80106a04:	c3                   	ret    

80106a05 <popcli>:

void
popcli(void)
{
80106a05:	55                   	push   %ebp
80106a06:	89 e5                	mov    %esp,%ebp
80106a08:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80106a0b:	e8 f9 fd ff ff       	call   80106809 <readeflags>
80106a10:	25 00 02 00 00       	and    $0x200,%eax
80106a15:	85 c0                	test   %eax,%eax
80106a17:	74 0d                	je     80106a26 <popcli+0x21>
    panic("popcli - interruptible");
80106a19:	83 ec 0c             	sub    $0xc,%esp
80106a1c:	68 05 a7 10 80       	push   $0x8010a705
80106a21:	e8 40 9b ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80106a26:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a2c:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80106a32:	83 ea 01             	sub    $0x1,%edx
80106a35:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80106a3b:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80106a41:	85 c0                	test   %eax,%eax
80106a43:	79 0d                	jns    80106a52 <popcli+0x4d>
    panic("popcli");
80106a45:	83 ec 0c             	sub    $0xc,%esp
80106a48:	68 1c a7 10 80       	push   $0x8010a71c
80106a4d:	e8 14 9b ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80106a52:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a58:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80106a5e:	85 c0                	test   %eax,%eax
80106a60:	75 15                	jne    80106a77 <popcli+0x72>
80106a62:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a68:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80106a6e:	85 c0                	test   %eax,%eax
80106a70:	74 05                	je     80106a77 <popcli+0x72>
    sti();
80106a72:	e8 a9 fd ff ff       	call   80106820 <sti>
}
80106a77:	90                   	nop
80106a78:	c9                   	leave  
80106a79:	c3                   	ret    

80106a7a <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80106a7a:	55                   	push   %ebp
80106a7b:	89 e5                	mov    %esp,%ebp
80106a7d:	57                   	push   %edi
80106a7e:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80106a7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106a82:	8b 55 10             	mov    0x10(%ebp),%edx
80106a85:	8b 45 0c             	mov    0xc(%ebp),%eax
80106a88:	89 cb                	mov    %ecx,%ebx
80106a8a:	89 df                	mov    %ebx,%edi
80106a8c:	89 d1                	mov    %edx,%ecx
80106a8e:	fc                   	cld    
80106a8f:	f3 aa                	rep stos %al,%es:(%edi)
80106a91:	89 ca                	mov    %ecx,%edx
80106a93:	89 fb                	mov    %edi,%ebx
80106a95:	89 5d 08             	mov    %ebx,0x8(%ebp)
80106a98:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80106a9b:	90                   	nop
80106a9c:	5b                   	pop    %ebx
80106a9d:	5f                   	pop    %edi
80106a9e:	5d                   	pop    %ebp
80106a9f:	c3                   	ret    

80106aa0 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80106aa0:	55                   	push   %ebp
80106aa1:	89 e5                	mov    %esp,%ebp
80106aa3:	57                   	push   %edi
80106aa4:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80106aa5:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106aa8:	8b 55 10             	mov    0x10(%ebp),%edx
80106aab:	8b 45 0c             	mov    0xc(%ebp),%eax
80106aae:	89 cb                	mov    %ecx,%ebx
80106ab0:	89 df                	mov    %ebx,%edi
80106ab2:	89 d1                	mov    %edx,%ecx
80106ab4:	fc                   	cld    
80106ab5:	f3 ab                	rep stos %eax,%es:(%edi)
80106ab7:	89 ca                	mov    %ecx,%edx
80106ab9:	89 fb                	mov    %edi,%ebx
80106abb:	89 5d 08             	mov    %ebx,0x8(%ebp)
80106abe:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80106ac1:	90                   	nop
80106ac2:	5b                   	pop    %ebx
80106ac3:	5f                   	pop    %edi
80106ac4:	5d                   	pop    %ebp
80106ac5:	c3                   	ret    

80106ac6 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80106ac6:	55                   	push   %ebp
80106ac7:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80106ac9:	8b 45 08             	mov    0x8(%ebp),%eax
80106acc:	83 e0 03             	and    $0x3,%eax
80106acf:	85 c0                	test   %eax,%eax
80106ad1:	75 43                	jne    80106b16 <memset+0x50>
80106ad3:	8b 45 10             	mov    0x10(%ebp),%eax
80106ad6:	83 e0 03             	and    $0x3,%eax
80106ad9:	85 c0                	test   %eax,%eax
80106adb:	75 39                	jne    80106b16 <memset+0x50>
    c &= 0xFF;
80106add:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80106ae4:	8b 45 10             	mov    0x10(%ebp),%eax
80106ae7:	c1 e8 02             	shr    $0x2,%eax
80106aea:	89 c1                	mov    %eax,%ecx
80106aec:	8b 45 0c             	mov    0xc(%ebp),%eax
80106aef:	c1 e0 18             	shl    $0x18,%eax
80106af2:	89 c2                	mov    %eax,%edx
80106af4:	8b 45 0c             	mov    0xc(%ebp),%eax
80106af7:	c1 e0 10             	shl    $0x10,%eax
80106afa:	09 c2                	or     %eax,%edx
80106afc:	8b 45 0c             	mov    0xc(%ebp),%eax
80106aff:	c1 e0 08             	shl    $0x8,%eax
80106b02:	09 d0                	or     %edx,%eax
80106b04:	0b 45 0c             	or     0xc(%ebp),%eax
80106b07:	51                   	push   %ecx
80106b08:	50                   	push   %eax
80106b09:	ff 75 08             	pushl  0x8(%ebp)
80106b0c:	e8 8f ff ff ff       	call   80106aa0 <stosl>
80106b11:	83 c4 0c             	add    $0xc,%esp
80106b14:	eb 12                	jmp    80106b28 <memset+0x62>
  } else
    stosb(dst, c, n);
80106b16:	8b 45 10             	mov    0x10(%ebp),%eax
80106b19:	50                   	push   %eax
80106b1a:	ff 75 0c             	pushl  0xc(%ebp)
80106b1d:	ff 75 08             	pushl  0x8(%ebp)
80106b20:	e8 55 ff ff ff       	call   80106a7a <stosb>
80106b25:	83 c4 0c             	add    $0xc,%esp
  return dst;
80106b28:	8b 45 08             	mov    0x8(%ebp),%eax
}
80106b2b:	c9                   	leave  
80106b2c:	c3                   	ret    

80106b2d <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80106b2d:	55                   	push   %ebp
80106b2e:	89 e5                	mov    %esp,%ebp
80106b30:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80106b33:	8b 45 08             	mov    0x8(%ebp),%eax
80106b36:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80106b39:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b3c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80106b3f:	eb 30                	jmp    80106b71 <memcmp+0x44>
    if(*s1 != *s2)
80106b41:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106b44:	0f b6 10             	movzbl (%eax),%edx
80106b47:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106b4a:	0f b6 00             	movzbl (%eax),%eax
80106b4d:	38 c2                	cmp    %al,%dl
80106b4f:	74 18                	je     80106b69 <memcmp+0x3c>
      return *s1 - *s2;
80106b51:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106b54:	0f b6 00             	movzbl (%eax),%eax
80106b57:	0f b6 d0             	movzbl %al,%edx
80106b5a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106b5d:	0f b6 00             	movzbl (%eax),%eax
80106b60:	0f b6 c0             	movzbl %al,%eax
80106b63:	29 c2                	sub    %eax,%edx
80106b65:	89 d0                	mov    %edx,%eax
80106b67:	eb 1a                	jmp    80106b83 <memcmp+0x56>
    s1++, s2++;
80106b69:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106b6d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80106b71:	8b 45 10             	mov    0x10(%ebp),%eax
80106b74:	8d 50 ff             	lea    -0x1(%eax),%edx
80106b77:	89 55 10             	mov    %edx,0x10(%ebp)
80106b7a:	85 c0                	test   %eax,%eax
80106b7c:	75 c3                	jne    80106b41 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80106b7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106b83:	c9                   	leave  
80106b84:	c3                   	ret    

80106b85 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80106b85:	55                   	push   %ebp
80106b86:	89 e5                	mov    %esp,%ebp
80106b88:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80106b8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b8e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80106b91:	8b 45 08             	mov    0x8(%ebp),%eax
80106b94:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80106b97:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106b9a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106b9d:	73 54                	jae    80106bf3 <memmove+0x6e>
80106b9f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106ba2:	8b 45 10             	mov    0x10(%ebp),%eax
80106ba5:	01 d0                	add    %edx,%eax
80106ba7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106baa:	76 47                	jbe    80106bf3 <memmove+0x6e>
    s += n;
80106bac:	8b 45 10             	mov    0x10(%ebp),%eax
80106baf:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80106bb2:	8b 45 10             	mov    0x10(%ebp),%eax
80106bb5:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80106bb8:	eb 13                	jmp    80106bcd <memmove+0x48>
      *--d = *--s;
80106bba:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80106bbe:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80106bc2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106bc5:	0f b6 10             	movzbl (%eax),%edx
80106bc8:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106bcb:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80106bcd:	8b 45 10             	mov    0x10(%ebp),%eax
80106bd0:	8d 50 ff             	lea    -0x1(%eax),%edx
80106bd3:	89 55 10             	mov    %edx,0x10(%ebp)
80106bd6:	85 c0                	test   %eax,%eax
80106bd8:	75 e0                	jne    80106bba <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80106bda:	eb 24                	jmp    80106c00 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80106bdc:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106bdf:	8d 50 01             	lea    0x1(%eax),%edx
80106be2:	89 55 f8             	mov    %edx,-0x8(%ebp)
80106be5:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106be8:	8d 4a 01             	lea    0x1(%edx),%ecx
80106beb:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80106bee:	0f b6 12             	movzbl (%edx),%edx
80106bf1:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80106bf3:	8b 45 10             	mov    0x10(%ebp),%eax
80106bf6:	8d 50 ff             	lea    -0x1(%eax),%edx
80106bf9:	89 55 10             	mov    %edx,0x10(%ebp)
80106bfc:	85 c0                	test   %eax,%eax
80106bfe:	75 dc                	jne    80106bdc <memmove+0x57>
      *d++ = *s++;

  return dst;
80106c00:	8b 45 08             	mov    0x8(%ebp),%eax
}
80106c03:	c9                   	leave  
80106c04:	c3                   	ret    

80106c05 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80106c05:	55                   	push   %ebp
80106c06:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80106c08:	ff 75 10             	pushl  0x10(%ebp)
80106c0b:	ff 75 0c             	pushl  0xc(%ebp)
80106c0e:	ff 75 08             	pushl  0x8(%ebp)
80106c11:	e8 6f ff ff ff       	call   80106b85 <memmove>
80106c16:	83 c4 0c             	add    $0xc,%esp
}
80106c19:	c9                   	leave  
80106c1a:	c3                   	ret    

80106c1b <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80106c1b:	55                   	push   %ebp
80106c1c:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80106c1e:	eb 0c                	jmp    80106c2c <strncmp+0x11>
    n--, p++, q++;
80106c20:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106c24:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80106c28:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80106c2c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106c30:	74 1a                	je     80106c4c <strncmp+0x31>
80106c32:	8b 45 08             	mov    0x8(%ebp),%eax
80106c35:	0f b6 00             	movzbl (%eax),%eax
80106c38:	84 c0                	test   %al,%al
80106c3a:	74 10                	je     80106c4c <strncmp+0x31>
80106c3c:	8b 45 08             	mov    0x8(%ebp),%eax
80106c3f:	0f b6 10             	movzbl (%eax),%edx
80106c42:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c45:	0f b6 00             	movzbl (%eax),%eax
80106c48:	38 c2                	cmp    %al,%dl
80106c4a:	74 d4                	je     80106c20 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80106c4c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106c50:	75 07                	jne    80106c59 <strncmp+0x3e>
    return 0;
80106c52:	b8 00 00 00 00       	mov    $0x0,%eax
80106c57:	eb 16                	jmp    80106c6f <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80106c59:	8b 45 08             	mov    0x8(%ebp),%eax
80106c5c:	0f b6 00             	movzbl (%eax),%eax
80106c5f:	0f b6 d0             	movzbl %al,%edx
80106c62:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c65:	0f b6 00             	movzbl (%eax),%eax
80106c68:	0f b6 c0             	movzbl %al,%eax
80106c6b:	29 c2                	sub    %eax,%edx
80106c6d:	89 d0                	mov    %edx,%eax
}
80106c6f:	5d                   	pop    %ebp
80106c70:	c3                   	ret    

80106c71 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80106c71:	55                   	push   %ebp
80106c72:	89 e5                	mov    %esp,%ebp
80106c74:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80106c77:	8b 45 08             	mov    0x8(%ebp),%eax
80106c7a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80106c7d:	90                   	nop
80106c7e:	8b 45 10             	mov    0x10(%ebp),%eax
80106c81:	8d 50 ff             	lea    -0x1(%eax),%edx
80106c84:	89 55 10             	mov    %edx,0x10(%ebp)
80106c87:	85 c0                	test   %eax,%eax
80106c89:	7e 2c                	jle    80106cb7 <strncpy+0x46>
80106c8b:	8b 45 08             	mov    0x8(%ebp),%eax
80106c8e:	8d 50 01             	lea    0x1(%eax),%edx
80106c91:	89 55 08             	mov    %edx,0x8(%ebp)
80106c94:	8b 55 0c             	mov    0xc(%ebp),%edx
80106c97:	8d 4a 01             	lea    0x1(%edx),%ecx
80106c9a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80106c9d:	0f b6 12             	movzbl (%edx),%edx
80106ca0:	88 10                	mov    %dl,(%eax)
80106ca2:	0f b6 00             	movzbl (%eax),%eax
80106ca5:	84 c0                	test   %al,%al
80106ca7:	75 d5                	jne    80106c7e <strncpy+0xd>
    ;
  while(n-- > 0)
80106ca9:	eb 0c                	jmp    80106cb7 <strncpy+0x46>
    *s++ = 0;
80106cab:	8b 45 08             	mov    0x8(%ebp),%eax
80106cae:	8d 50 01             	lea    0x1(%eax),%edx
80106cb1:	89 55 08             	mov    %edx,0x8(%ebp)
80106cb4:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80106cb7:	8b 45 10             	mov    0x10(%ebp),%eax
80106cba:	8d 50 ff             	lea    -0x1(%eax),%edx
80106cbd:	89 55 10             	mov    %edx,0x10(%ebp)
80106cc0:	85 c0                	test   %eax,%eax
80106cc2:	7f e7                	jg     80106cab <strncpy+0x3a>
    *s++ = 0;
  return os;
80106cc4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106cc7:	c9                   	leave  
80106cc8:	c3                   	ret    

80106cc9 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80106cc9:	55                   	push   %ebp
80106cca:	89 e5                	mov    %esp,%ebp
80106ccc:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80106ccf:	8b 45 08             	mov    0x8(%ebp),%eax
80106cd2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80106cd5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106cd9:	7f 05                	jg     80106ce0 <safestrcpy+0x17>
    return os;
80106cdb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106cde:	eb 31                	jmp    80106d11 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80106ce0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106ce4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106ce8:	7e 1e                	jle    80106d08 <safestrcpy+0x3f>
80106cea:	8b 45 08             	mov    0x8(%ebp),%eax
80106ced:	8d 50 01             	lea    0x1(%eax),%edx
80106cf0:	89 55 08             	mov    %edx,0x8(%ebp)
80106cf3:	8b 55 0c             	mov    0xc(%ebp),%edx
80106cf6:	8d 4a 01             	lea    0x1(%edx),%ecx
80106cf9:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80106cfc:	0f b6 12             	movzbl (%edx),%edx
80106cff:	88 10                	mov    %dl,(%eax)
80106d01:	0f b6 00             	movzbl (%eax),%eax
80106d04:	84 c0                	test   %al,%al
80106d06:	75 d8                	jne    80106ce0 <safestrcpy+0x17>
    ;
  *s = 0;
80106d08:	8b 45 08             	mov    0x8(%ebp),%eax
80106d0b:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80106d0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106d11:	c9                   	leave  
80106d12:	c3                   	ret    

80106d13 <strlen>:

int
strlen(const char *s)
{
80106d13:	55                   	push   %ebp
80106d14:	89 e5                	mov    %esp,%ebp
80106d16:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80106d19:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106d20:	eb 04                	jmp    80106d26 <strlen+0x13>
80106d22:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106d26:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106d29:	8b 45 08             	mov    0x8(%ebp),%eax
80106d2c:	01 d0                	add    %edx,%eax
80106d2e:	0f b6 00             	movzbl (%eax),%eax
80106d31:	84 c0                	test   %al,%al
80106d33:	75 ed                	jne    80106d22 <strlen+0xf>
    ;
  return n;
80106d35:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106d38:	c9                   	leave  
80106d39:	c3                   	ret    

80106d3a <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80106d3a:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80106d3e:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80106d42:	55                   	push   %ebp
  pushl %ebx
80106d43:	53                   	push   %ebx
  pushl %esi
80106d44:	56                   	push   %esi
  pushl %edi
80106d45:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80106d46:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80106d48:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80106d4a:	5f                   	pop    %edi
  popl %esi
80106d4b:	5e                   	pop    %esi
  popl %ebx
80106d4c:	5b                   	pop    %ebx
  popl %ebp
80106d4d:	5d                   	pop    %ebp
  ret
80106d4e:	c3                   	ret    

80106d4f <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80106d4f:	55                   	push   %ebp
80106d50:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80106d52:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d58:	8b 00                	mov    (%eax),%eax
80106d5a:	3b 45 08             	cmp    0x8(%ebp),%eax
80106d5d:	76 12                	jbe    80106d71 <fetchint+0x22>
80106d5f:	8b 45 08             	mov    0x8(%ebp),%eax
80106d62:	8d 50 04             	lea    0x4(%eax),%edx
80106d65:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d6b:	8b 00                	mov    (%eax),%eax
80106d6d:	39 c2                	cmp    %eax,%edx
80106d6f:	76 07                	jbe    80106d78 <fetchint+0x29>
    return -1;
80106d71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d76:	eb 0f                	jmp    80106d87 <fetchint+0x38>
  *ip = *(int*)(addr);
80106d78:	8b 45 08             	mov    0x8(%ebp),%eax
80106d7b:	8b 10                	mov    (%eax),%edx
80106d7d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d80:	89 10                	mov    %edx,(%eax)
  return 0;
80106d82:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106d87:	5d                   	pop    %ebp
80106d88:	c3                   	ret    

80106d89 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80106d89:	55                   	push   %ebp
80106d8a:	89 e5                	mov    %esp,%ebp
80106d8c:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80106d8f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d95:	8b 00                	mov    (%eax),%eax
80106d97:	3b 45 08             	cmp    0x8(%ebp),%eax
80106d9a:	77 07                	ja     80106da3 <fetchstr+0x1a>
    return -1;
80106d9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106da1:	eb 46                	jmp    80106de9 <fetchstr+0x60>
  *pp = (char*)addr;
80106da3:	8b 55 08             	mov    0x8(%ebp),%edx
80106da6:	8b 45 0c             	mov    0xc(%ebp),%eax
80106da9:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80106dab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106db1:	8b 00                	mov    (%eax),%eax
80106db3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80106db6:	8b 45 0c             	mov    0xc(%ebp),%eax
80106db9:	8b 00                	mov    (%eax),%eax
80106dbb:	89 45 fc             	mov    %eax,-0x4(%ebp)
80106dbe:	eb 1c                	jmp    80106ddc <fetchstr+0x53>
    if(*s == 0)
80106dc0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106dc3:	0f b6 00             	movzbl (%eax),%eax
80106dc6:	84 c0                	test   %al,%al
80106dc8:	75 0e                	jne    80106dd8 <fetchstr+0x4f>
      return s - *pp;
80106dca:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106dcd:	8b 45 0c             	mov    0xc(%ebp),%eax
80106dd0:	8b 00                	mov    (%eax),%eax
80106dd2:	29 c2                	sub    %eax,%edx
80106dd4:	89 d0                	mov    %edx,%eax
80106dd6:	eb 11                	jmp    80106de9 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80106dd8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106ddc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106ddf:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106de2:	72 dc                	jb     80106dc0 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80106de4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106de9:	c9                   	leave  
80106dea:	c3                   	ret    

80106deb <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80106deb:	55                   	push   %ebp
80106dec:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80106dee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106df4:	8b 40 18             	mov    0x18(%eax),%eax
80106df7:	8b 40 44             	mov    0x44(%eax),%eax
80106dfa:	8b 55 08             	mov    0x8(%ebp),%edx
80106dfd:	c1 e2 02             	shl    $0x2,%edx
80106e00:	01 d0                	add    %edx,%eax
80106e02:	83 c0 04             	add    $0x4,%eax
80106e05:	ff 75 0c             	pushl  0xc(%ebp)
80106e08:	50                   	push   %eax
80106e09:	e8 41 ff ff ff       	call   80106d4f <fetchint>
80106e0e:	83 c4 08             	add    $0x8,%esp
}
80106e11:	c9                   	leave  
80106e12:	c3                   	ret    

80106e13 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80106e13:	55                   	push   %ebp
80106e14:	89 e5                	mov    %esp,%ebp
80106e16:	83 ec 10             	sub    $0x10,%esp
  int i;

  if(argint(n, &i) < 0)
80106e19:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106e1c:	50                   	push   %eax
80106e1d:	ff 75 08             	pushl  0x8(%ebp)
80106e20:	e8 c6 ff ff ff       	call   80106deb <argint>
80106e25:	83 c4 08             	add    $0x8,%esp
80106e28:	85 c0                	test   %eax,%eax
80106e2a:	79 07                	jns    80106e33 <argptr+0x20>
    return -1;
80106e2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e31:	eb 3b                	jmp    80106e6e <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80106e33:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e39:	8b 00                	mov    (%eax),%eax
80106e3b:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106e3e:	39 d0                	cmp    %edx,%eax
80106e40:	76 16                	jbe    80106e58 <argptr+0x45>
80106e42:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106e45:	89 c2                	mov    %eax,%edx
80106e47:	8b 45 10             	mov    0x10(%ebp),%eax
80106e4a:	01 c2                	add    %eax,%edx
80106e4c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e52:	8b 00                	mov    (%eax),%eax
80106e54:	39 c2                	cmp    %eax,%edx
80106e56:	76 07                	jbe    80106e5f <argptr+0x4c>
    return -1;
80106e58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e5d:	eb 0f                	jmp    80106e6e <argptr+0x5b>
  *pp = (char*)i;
80106e5f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106e62:	89 c2                	mov    %eax,%edx
80106e64:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e67:	89 10                	mov    %edx,(%eax)
  return 0;
80106e69:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106e6e:	c9                   	leave  
80106e6f:	c3                   	ret    

80106e70 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80106e70:	55                   	push   %ebp
80106e71:	89 e5                	mov    %esp,%ebp
80106e73:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80106e76:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106e79:	50                   	push   %eax
80106e7a:	ff 75 08             	pushl  0x8(%ebp)
80106e7d:	e8 69 ff ff ff       	call   80106deb <argint>
80106e82:	83 c4 08             	add    $0x8,%esp
80106e85:	85 c0                	test   %eax,%eax
80106e87:	79 07                	jns    80106e90 <argstr+0x20>
    return -1;
80106e89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e8e:	eb 0f                	jmp    80106e9f <argstr+0x2f>
  return fetchstr(addr, pp);
80106e90:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106e93:	ff 75 0c             	pushl  0xc(%ebp)
80106e96:	50                   	push   %eax
80106e97:	e8 ed fe ff ff       	call   80106d89 <fetchstr>
80106e9c:	83 c4 08             	add    $0x8,%esp
}
80106e9f:	c9                   	leave  
80106ea0:	c3                   	ret    

80106ea1 <syscall>:
};
#endif

void
syscall(void)
{
80106ea1:	55                   	push   %ebp
80106ea2:	89 e5                	mov    %esp,%ebp
80106ea4:	53                   	push   %ebx
80106ea5:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
80106ea8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106eae:	8b 40 18             	mov    0x18(%eax),%eax
80106eb1:	8b 40 1c             	mov    0x1c(%eax),%eax
80106eb4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80106eb7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106ebb:	7e 30                	jle    80106eed <syscall+0x4c>
80106ebd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ec0:	83 f8 1c             	cmp    $0x1c,%eax
80106ec3:	77 28                	ja     80106eed <syscall+0x4c>
80106ec5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ec8:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
80106ecf:	85 c0                	test   %eax,%eax
80106ed1:	74 1a                	je     80106eed <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80106ed3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ed9:	8b 58 18             	mov    0x18(%eax),%ebx
80106edc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106edf:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
80106ee6:	ff d0                	call   *%eax
80106ee8:	89 43 1c             	mov    %eax,0x1c(%ebx)
80106eeb:	eb 34                	jmp    80106f21 <syscall+0x80>
#ifdef PRINT_SYSCALLS
    cprintf("%s -> %d\n",syscallnames[num],proc->tf->eax);
#endif
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80106eed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ef3:	8d 50 6c             	lea    0x6c(%eax),%edx
80106ef6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
// some code goes here
#ifdef PRINT_SYSCALLS
    cprintf("%s -> %d\n",syscallnames[num],proc->tf->eax);
#endif
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80106efc:	8b 40 10             	mov    0x10(%eax),%eax
80106eff:	ff 75 f4             	pushl  -0xc(%ebp)
80106f02:	52                   	push   %edx
80106f03:	50                   	push   %eax
80106f04:	68 23 a7 10 80       	push   $0x8010a723
80106f09:	e8 b8 94 ff ff       	call   801003c6 <cprintf>
80106f0e:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80106f11:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f17:	8b 40 18             	mov    0x18(%eax),%eax
80106f1a:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80106f21:	90                   	nop
80106f22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106f25:	c9                   	leave  
80106f26:	c3                   	ret    

80106f27 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80106f27:	55                   	push   %ebp
80106f28:	89 e5                	mov    %esp,%ebp
80106f2a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80106f2d:	83 ec 08             	sub    $0x8,%esp
80106f30:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106f33:	50                   	push   %eax
80106f34:	ff 75 08             	pushl  0x8(%ebp)
80106f37:	e8 af fe ff ff       	call   80106deb <argint>
80106f3c:	83 c4 10             	add    $0x10,%esp
80106f3f:	85 c0                	test   %eax,%eax
80106f41:	79 07                	jns    80106f4a <argfd+0x23>
    return -1;
80106f43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f48:	eb 50                	jmp    80106f9a <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80106f4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f4d:	85 c0                	test   %eax,%eax
80106f4f:	78 21                	js     80106f72 <argfd+0x4b>
80106f51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f54:	83 f8 0f             	cmp    $0xf,%eax
80106f57:	7f 19                	jg     80106f72 <argfd+0x4b>
80106f59:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f5f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106f62:	83 c2 08             	add    $0x8,%edx
80106f65:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106f69:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106f6c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106f70:	75 07                	jne    80106f79 <argfd+0x52>
    return -1;
80106f72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f77:	eb 21                	jmp    80106f9a <argfd+0x73>
  if(pfd)
80106f79:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106f7d:	74 08                	je     80106f87 <argfd+0x60>
    *pfd = fd;
80106f7f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106f82:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f85:	89 10                	mov    %edx,(%eax)
  if(pf)
80106f87:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106f8b:	74 08                	je     80106f95 <argfd+0x6e>
    *pf = f;
80106f8d:	8b 45 10             	mov    0x10(%ebp),%eax
80106f90:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106f93:	89 10                	mov    %edx,(%eax)
  return 0;
80106f95:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106f9a:	c9                   	leave  
80106f9b:	c3                   	ret    

80106f9c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80106f9c:	55                   	push   %ebp
80106f9d:	89 e5                	mov    %esp,%ebp
80106f9f:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80106fa2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106fa9:	eb 30                	jmp    80106fdb <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80106fab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fb1:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106fb4:	83 c2 08             	add    $0x8,%edx
80106fb7:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106fbb:	85 c0                	test   %eax,%eax
80106fbd:	75 18                	jne    80106fd7 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80106fbf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fc5:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106fc8:	8d 4a 08             	lea    0x8(%edx),%ecx
80106fcb:	8b 55 08             	mov    0x8(%ebp),%edx
80106fce:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80106fd2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106fd5:	eb 0f                	jmp    80106fe6 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80106fd7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106fdb:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80106fdf:	7e ca                	jle    80106fab <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80106fe1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106fe6:	c9                   	leave  
80106fe7:	c3                   	ret    

80106fe8 <sys_dup>:

int
sys_dup(void)
{
80106fe8:	55                   	push   %ebp
80106fe9:	89 e5                	mov    %esp,%ebp
80106feb:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80106fee:	83 ec 04             	sub    $0x4,%esp
80106ff1:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106ff4:	50                   	push   %eax
80106ff5:	6a 00                	push   $0x0
80106ff7:	6a 00                	push   $0x0
80106ff9:	e8 29 ff ff ff       	call   80106f27 <argfd>
80106ffe:	83 c4 10             	add    $0x10,%esp
80107001:	85 c0                	test   %eax,%eax
80107003:	79 07                	jns    8010700c <sys_dup+0x24>
    return -1;
80107005:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010700a:	eb 31                	jmp    8010703d <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010700c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010700f:	83 ec 0c             	sub    $0xc,%esp
80107012:	50                   	push   %eax
80107013:	e8 84 ff ff ff       	call   80106f9c <fdalloc>
80107018:	83 c4 10             	add    $0x10,%esp
8010701b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010701e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107022:	79 07                	jns    8010702b <sys_dup+0x43>
    return -1;
80107024:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107029:	eb 12                	jmp    8010703d <sys_dup+0x55>
  filedup(f);
8010702b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010702e:	83 ec 0c             	sub    $0xc,%esp
80107031:	50                   	push   %eax
80107032:	e8 67 a0 ff ff       	call   8010109e <filedup>
80107037:	83 c4 10             	add    $0x10,%esp
  return fd;
8010703a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010703d:	c9                   	leave  
8010703e:	c3                   	ret    

8010703f <sys_read>:

int
sys_read(void)
{
8010703f:	55                   	push   %ebp
80107040:	89 e5                	mov    %esp,%ebp
80107042:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80107045:	83 ec 04             	sub    $0x4,%esp
80107048:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010704b:	50                   	push   %eax
8010704c:	6a 00                	push   $0x0
8010704e:	6a 00                	push   $0x0
80107050:	e8 d2 fe ff ff       	call   80106f27 <argfd>
80107055:	83 c4 10             	add    $0x10,%esp
80107058:	85 c0                	test   %eax,%eax
8010705a:	78 2e                	js     8010708a <sys_read+0x4b>
8010705c:	83 ec 08             	sub    $0x8,%esp
8010705f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107062:	50                   	push   %eax
80107063:	6a 02                	push   $0x2
80107065:	e8 81 fd ff ff       	call   80106deb <argint>
8010706a:	83 c4 10             	add    $0x10,%esp
8010706d:	85 c0                	test   %eax,%eax
8010706f:	78 19                	js     8010708a <sys_read+0x4b>
80107071:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107074:	83 ec 04             	sub    $0x4,%esp
80107077:	50                   	push   %eax
80107078:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010707b:	50                   	push   %eax
8010707c:	6a 01                	push   $0x1
8010707e:	e8 90 fd ff ff       	call   80106e13 <argptr>
80107083:	83 c4 10             	add    $0x10,%esp
80107086:	85 c0                	test   %eax,%eax
80107088:	79 07                	jns    80107091 <sys_read+0x52>
    return -1;
8010708a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010708f:	eb 17                	jmp    801070a8 <sys_read+0x69>
  return fileread(f, p, n);
80107091:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80107094:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010709a:	83 ec 04             	sub    $0x4,%esp
8010709d:	51                   	push   %ecx
8010709e:	52                   	push   %edx
8010709f:	50                   	push   %eax
801070a0:	e8 89 a1 ff ff       	call   8010122e <fileread>
801070a5:	83 c4 10             	add    $0x10,%esp
}
801070a8:	c9                   	leave  
801070a9:	c3                   	ret    

801070aa <sys_write>:

int
sys_write(void)
{
801070aa:	55                   	push   %ebp
801070ab:	89 e5                	mov    %esp,%ebp
801070ad:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801070b0:	83 ec 04             	sub    $0x4,%esp
801070b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
801070b6:	50                   	push   %eax
801070b7:	6a 00                	push   $0x0
801070b9:	6a 00                	push   $0x0
801070bb:	e8 67 fe ff ff       	call   80106f27 <argfd>
801070c0:	83 c4 10             	add    $0x10,%esp
801070c3:	85 c0                	test   %eax,%eax
801070c5:	78 2e                	js     801070f5 <sys_write+0x4b>
801070c7:	83 ec 08             	sub    $0x8,%esp
801070ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
801070cd:	50                   	push   %eax
801070ce:	6a 02                	push   $0x2
801070d0:	e8 16 fd ff ff       	call   80106deb <argint>
801070d5:	83 c4 10             	add    $0x10,%esp
801070d8:	85 c0                	test   %eax,%eax
801070da:	78 19                	js     801070f5 <sys_write+0x4b>
801070dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070df:	83 ec 04             	sub    $0x4,%esp
801070e2:	50                   	push   %eax
801070e3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801070e6:	50                   	push   %eax
801070e7:	6a 01                	push   $0x1
801070e9:	e8 25 fd ff ff       	call   80106e13 <argptr>
801070ee:	83 c4 10             	add    $0x10,%esp
801070f1:	85 c0                	test   %eax,%eax
801070f3:	79 07                	jns    801070fc <sys_write+0x52>
    return -1;
801070f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070fa:	eb 17                	jmp    80107113 <sys_write+0x69>
  return filewrite(f, p, n);
801070fc:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801070ff:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107102:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107105:	83 ec 04             	sub    $0x4,%esp
80107108:	51                   	push   %ecx
80107109:	52                   	push   %edx
8010710a:	50                   	push   %eax
8010710b:	e8 d6 a1 ff ff       	call   801012e6 <filewrite>
80107110:	83 c4 10             	add    $0x10,%esp
}
80107113:	c9                   	leave  
80107114:	c3                   	ret    

80107115 <sys_close>:

int
sys_close(void)
{
80107115:	55                   	push   %ebp
80107116:	89 e5                	mov    %esp,%ebp
80107118:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
8010711b:	83 ec 04             	sub    $0x4,%esp
8010711e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107121:	50                   	push   %eax
80107122:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107125:	50                   	push   %eax
80107126:	6a 00                	push   $0x0
80107128:	e8 fa fd ff ff       	call   80106f27 <argfd>
8010712d:	83 c4 10             	add    $0x10,%esp
80107130:	85 c0                	test   %eax,%eax
80107132:	79 07                	jns    8010713b <sys_close+0x26>
    return -1;
80107134:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107139:	eb 28                	jmp    80107163 <sys_close+0x4e>
  proc->ofile[fd] = 0;
8010713b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107141:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107144:	83 c2 08             	add    $0x8,%edx
80107147:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010714e:	00 
  fileclose(f);
8010714f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107152:	83 ec 0c             	sub    $0xc,%esp
80107155:	50                   	push   %eax
80107156:	e8 94 9f ff ff       	call   801010ef <fileclose>
8010715b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010715e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107163:	c9                   	leave  
80107164:	c3                   	ret    

80107165 <sys_fstat>:

int
sys_fstat(void)
{
80107165:	55                   	push   %ebp
80107166:	89 e5                	mov    %esp,%ebp
80107168:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010716b:	83 ec 04             	sub    $0x4,%esp
8010716e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107171:	50                   	push   %eax
80107172:	6a 00                	push   $0x0
80107174:	6a 00                	push   $0x0
80107176:	e8 ac fd ff ff       	call   80106f27 <argfd>
8010717b:	83 c4 10             	add    $0x10,%esp
8010717e:	85 c0                	test   %eax,%eax
80107180:	78 17                	js     80107199 <sys_fstat+0x34>
80107182:	83 ec 04             	sub    $0x4,%esp
80107185:	6a 14                	push   $0x14
80107187:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010718a:	50                   	push   %eax
8010718b:	6a 01                	push   $0x1
8010718d:	e8 81 fc ff ff       	call   80106e13 <argptr>
80107192:	83 c4 10             	add    $0x10,%esp
80107195:	85 c0                	test   %eax,%eax
80107197:	79 07                	jns    801071a0 <sys_fstat+0x3b>
    return -1;
80107199:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010719e:	eb 13                	jmp    801071b3 <sys_fstat+0x4e>
  return filestat(f, st);
801071a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801071a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071a6:	83 ec 08             	sub    $0x8,%esp
801071a9:	52                   	push   %edx
801071aa:	50                   	push   %eax
801071ab:	e8 27 a0 ff ff       	call   801011d7 <filestat>
801071b0:	83 c4 10             	add    $0x10,%esp
}
801071b3:	c9                   	leave  
801071b4:	c3                   	ret    

801071b5 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801071b5:	55                   	push   %ebp
801071b6:	89 e5                	mov    %esp,%ebp
801071b8:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801071bb:	83 ec 08             	sub    $0x8,%esp
801071be:	8d 45 d8             	lea    -0x28(%ebp),%eax
801071c1:	50                   	push   %eax
801071c2:	6a 00                	push   $0x0
801071c4:	e8 a7 fc ff ff       	call   80106e70 <argstr>
801071c9:	83 c4 10             	add    $0x10,%esp
801071cc:	85 c0                	test   %eax,%eax
801071ce:	78 15                	js     801071e5 <sys_link+0x30>
801071d0:	83 ec 08             	sub    $0x8,%esp
801071d3:	8d 45 dc             	lea    -0x24(%ebp),%eax
801071d6:	50                   	push   %eax
801071d7:	6a 01                	push   $0x1
801071d9:	e8 92 fc ff ff       	call   80106e70 <argstr>
801071de:	83 c4 10             	add    $0x10,%esp
801071e1:	85 c0                	test   %eax,%eax
801071e3:	79 0a                	jns    801071ef <sys_link+0x3a>
    return -1;
801071e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071ea:	e9 68 01 00 00       	jmp    80107357 <sys_link+0x1a2>

  begin_op();
801071ef:	e8 f7 c3 ff ff       	call   801035eb <begin_op>
  if((ip = namei(old)) == 0){
801071f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
801071f7:	83 ec 0c             	sub    $0xc,%esp
801071fa:	50                   	push   %eax
801071fb:	e8 c6 b3 ff ff       	call   801025c6 <namei>
80107200:	83 c4 10             	add    $0x10,%esp
80107203:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107206:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010720a:	75 0f                	jne    8010721b <sys_link+0x66>
    end_op();
8010720c:	e8 66 c4 ff ff       	call   80103677 <end_op>
    return -1;
80107211:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107216:	e9 3c 01 00 00       	jmp    80107357 <sys_link+0x1a2>
  }

  ilock(ip);
8010721b:	83 ec 0c             	sub    $0xc,%esp
8010721e:	ff 75 f4             	pushl  -0xc(%ebp)
80107221:	e8 e2 a7 ff ff       	call   80101a08 <ilock>
80107226:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80107229:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010722c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107230:	66 83 f8 01          	cmp    $0x1,%ax
80107234:	75 1d                	jne    80107253 <sys_link+0x9e>
    iunlockput(ip);
80107236:	83 ec 0c             	sub    $0xc,%esp
80107239:	ff 75 f4             	pushl  -0xc(%ebp)
8010723c:	e8 87 aa ff ff       	call   80101cc8 <iunlockput>
80107241:	83 c4 10             	add    $0x10,%esp
    end_op();
80107244:	e8 2e c4 ff ff       	call   80103677 <end_op>
    return -1;
80107249:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010724e:	e9 04 01 00 00       	jmp    80107357 <sys_link+0x1a2>
  }

  ip->nlink++;
80107253:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107256:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010725a:	83 c0 01             	add    $0x1,%eax
8010725d:	89 c2                	mov    %eax,%edx
8010725f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107262:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80107266:	83 ec 0c             	sub    $0xc,%esp
80107269:	ff 75 f4             	pushl  -0xc(%ebp)
8010726c:	e8 bd a5 ff ff       	call   8010182e <iupdate>
80107271:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80107274:	83 ec 0c             	sub    $0xc,%esp
80107277:	ff 75 f4             	pushl  -0xc(%ebp)
8010727a:	e8 e7 a8 ff ff       	call   80101b66 <iunlock>
8010727f:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80107282:	8b 45 dc             	mov    -0x24(%ebp),%eax
80107285:	83 ec 08             	sub    $0x8,%esp
80107288:	8d 55 e2             	lea    -0x1e(%ebp),%edx
8010728b:	52                   	push   %edx
8010728c:	50                   	push   %eax
8010728d:	e8 50 b3 ff ff       	call   801025e2 <nameiparent>
80107292:	83 c4 10             	add    $0x10,%esp
80107295:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107298:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010729c:	74 71                	je     8010730f <sys_link+0x15a>
    goto bad;
  ilock(dp);
8010729e:	83 ec 0c             	sub    $0xc,%esp
801072a1:	ff 75 f0             	pushl  -0x10(%ebp)
801072a4:	e8 5f a7 ff ff       	call   80101a08 <ilock>
801072a9:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801072ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801072af:	8b 10                	mov    (%eax),%edx
801072b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072b4:	8b 00                	mov    (%eax),%eax
801072b6:	39 c2                	cmp    %eax,%edx
801072b8:	75 1d                	jne    801072d7 <sys_link+0x122>
801072ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072bd:	8b 40 04             	mov    0x4(%eax),%eax
801072c0:	83 ec 04             	sub    $0x4,%esp
801072c3:	50                   	push   %eax
801072c4:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801072c7:	50                   	push   %eax
801072c8:	ff 75 f0             	pushl  -0x10(%ebp)
801072cb:	e8 5a b0 ff ff       	call   8010232a <dirlink>
801072d0:	83 c4 10             	add    $0x10,%esp
801072d3:	85 c0                	test   %eax,%eax
801072d5:	79 10                	jns    801072e7 <sys_link+0x132>
    iunlockput(dp);
801072d7:	83 ec 0c             	sub    $0xc,%esp
801072da:	ff 75 f0             	pushl  -0x10(%ebp)
801072dd:	e8 e6 a9 ff ff       	call   80101cc8 <iunlockput>
801072e2:	83 c4 10             	add    $0x10,%esp
    goto bad;
801072e5:	eb 29                	jmp    80107310 <sys_link+0x15b>
  }
  iunlockput(dp);
801072e7:	83 ec 0c             	sub    $0xc,%esp
801072ea:	ff 75 f0             	pushl  -0x10(%ebp)
801072ed:	e8 d6 a9 ff ff       	call   80101cc8 <iunlockput>
801072f2:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801072f5:	83 ec 0c             	sub    $0xc,%esp
801072f8:	ff 75 f4             	pushl  -0xc(%ebp)
801072fb:	e8 d8 a8 ff ff       	call   80101bd8 <iput>
80107300:	83 c4 10             	add    $0x10,%esp

  end_op();
80107303:	e8 6f c3 ff ff       	call   80103677 <end_op>

  return 0;
80107308:	b8 00 00 00 00       	mov    $0x0,%eax
8010730d:	eb 48                	jmp    80107357 <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
8010730f:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80107310:	83 ec 0c             	sub    $0xc,%esp
80107313:	ff 75 f4             	pushl  -0xc(%ebp)
80107316:	e8 ed a6 ff ff       	call   80101a08 <ilock>
8010731b:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
8010731e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107321:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80107325:	83 e8 01             	sub    $0x1,%eax
80107328:	89 c2                	mov    %eax,%edx
8010732a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010732d:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80107331:	83 ec 0c             	sub    $0xc,%esp
80107334:	ff 75 f4             	pushl  -0xc(%ebp)
80107337:	e8 f2 a4 ff ff       	call   8010182e <iupdate>
8010733c:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010733f:	83 ec 0c             	sub    $0xc,%esp
80107342:	ff 75 f4             	pushl  -0xc(%ebp)
80107345:	e8 7e a9 ff ff       	call   80101cc8 <iunlockput>
8010734a:	83 c4 10             	add    $0x10,%esp
  end_op();
8010734d:	e8 25 c3 ff ff       	call   80103677 <end_op>
  return -1;
80107352:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107357:	c9                   	leave  
80107358:	c3                   	ret    

80107359 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80107359:	55                   	push   %ebp
8010735a:	89 e5                	mov    %esp,%ebp
8010735c:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010735f:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80107366:	eb 40                	jmp    801073a8 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80107368:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010736b:	6a 10                	push   $0x10
8010736d:	50                   	push   %eax
8010736e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107371:	50                   	push   %eax
80107372:	ff 75 08             	pushl  0x8(%ebp)
80107375:	e8 fc ab ff ff       	call   80101f76 <readi>
8010737a:	83 c4 10             	add    $0x10,%esp
8010737d:	83 f8 10             	cmp    $0x10,%eax
80107380:	74 0d                	je     8010738f <isdirempty+0x36>
      panic("isdirempty: readi");
80107382:	83 ec 0c             	sub    $0xc,%esp
80107385:	68 3f a7 10 80       	push   $0x8010a73f
8010738a:	e8 d7 91 ff ff       	call   80100566 <panic>
    if(de.inum != 0)
8010738f:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80107393:	66 85 c0             	test   %ax,%ax
80107396:	74 07                	je     8010739f <isdirempty+0x46>
      return 0;
80107398:	b8 00 00 00 00       	mov    $0x0,%eax
8010739d:	eb 1b                	jmp    801073ba <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010739f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073a2:	83 c0 10             	add    $0x10,%eax
801073a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801073a8:	8b 45 08             	mov    0x8(%ebp),%eax
801073ab:	8b 50 18             	mov    0x18(%eax),%edx
801073ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073b1:	39 c2                	cmp    %eax,%edx
801073b3:	77 b3                	ja     80107368 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
801073b5:	b8 01 00 00 00       	mov    $0x1,%eax
}
801073ba:	c9                   	leave  
801073bb:	c3                   	ret    

801073bc <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801073bc:	55                   	push   %ebp
801073bd:	89 e5                	mov    %esp,%ebp
801073bf:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801073c2:	83 ec 08             	sub    $0x8,%esp
801073c5:	8d 45 cc             	lea    -0x34(%ebp),%eax
801073c8:	50                   	push   %eax
801073c9:	6a 00                	push   $0x0
801073cb:	e8 a0 fa ff ff       	call   80106e70 <argstr>
801073d0:	83 c4 10             	add    $0x10,%esp
801073d3:	85 c0                	test   %eax,%eax
801073d5:	79 0a                	jns    801073e1 <sys_unlink+0x25>
    return -1;
801073d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073dc:	e9 bc 01 00 00       	jmp    8010759d <sys_unlink+0x1e1>

  begin_op();
801073e1:	e8 05 c2 ff ff       	call   801035eb <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801073e6:	8b 45 cc             	mov    -0x34(%ebp),%eax
801073e9:	83 ec 08             	sub    $0x8,%esp
801073ec:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801073ef:	52                   	push   %edx
801073f0:	50                   	push   %eax
801073f1:	e8 ec b1 ff ff       	call   801025e2 <nameiparent>
801073f6:	83 c4 10             	add    $0x10,%esp
801073f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801073fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107400:	75 0f                	jne    80107411 <sys_unlink+0x55>
    end_op();
80107402:	e8 70 c2 ff ff       	call   80103677 <end_op>
    return -1;
80107407:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010740c:	e9 8c 01 00 00       	jmp    8010759d <sys_unlink+0x1e1>
  }

  ilock(dp);
80107411:	83 ec 0c             	sub    $0xc,%esp
80107414:	ff 75 f4             	pushl  -0xc(%ebp)
80107417:	e8 ec a5 ff ff       	call   80101a08 <ilock>
8010741c:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010741f:	83 ec 08             	sub    $0x8,%esp
80107422:	68 51 a7 10 80       	push   $0x8010a751
80107427:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010742a:	50                   	push   %eax
8010742b:	e8 25 ae ff ff       	call   80102255 <namecmp>
80107430:	83 c4 10             	add    $0x10,%esp
80107433:	85 c0                	test   %eax,%eax
80107435:	0f 84 4a 01 00 00    	je     80107585 <sys_unlink+0x1c9>
8010743b:	83 ec 08             	sub    $0x8,%esp
8010743e:	68 53 a7 10 80       	push   $0x8010a753
80107443:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80107446:	50                   	push   %eax
80107447:	e8 09 ae ff ff       	call   80102255 <namecmp>
8010744c:	83 c4 10             	add    $0x10,%esp
8010744f:	85 c0                	test   %eax,%eax
80107451:	0f 84 2e 01 00 00    	je     80107585 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80107457:	83 ec 04             	sub    $0x4,%esp
8010745a:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010745d:	50                   	push   %eax
8010745e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80107461:	50                   	push   %eax
80107462:	ff 75 f4             	pushl  -0xc(%ebp)
80107465:	e8 06 ae ff ff       	call   80102270 <dirlookup>
8010746a:	83 c4 10             	add    $0x10,%esp
8010746d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107470:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107474:	0f 84 0a 01 00 00    	je     80107584 <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
8010747a:	83 ec 0c             	sub    $0xc,%esp
8010747d:	ff 75 f0             	pushl  -0x10(%ebp)
80107480:	e8 83 a5 ff ff       	call   80101a08 <ilock>
80107485:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80107488:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010748b:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010748f:	66 85 c0             	test   %ax,%ax
80107492:	7f 0d                	jg     801074a1 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80107494:	83 ec 0c             	sub    $0xc,%esp
80107497:	68 56 a7 10 80       	push   $0x8010a756
8010749c:	e8 c5 90 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801074a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801074a4:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801074a8:	66 83 f8 01          	cmp    $0x1,%ax
801074ac:	75 25                	jne    801074d3 <sys_unlink+0x117>
801074ae:	83 ec 0c             	sub    $0xc,%esp
801074b1:	ff 75 f0             	pushl  -0x10(%ebp)
801074b4:	e8 a0 fe ff ff       	call   80107359 <isdirempty>
801074b9:	83 c4 10             	add    $0x10,%esp
801074bc:	85 c0                	test   %eax,%eax
801074be:	75 13                	jne    801074d3 <sys_unlink+0x117>
    iunlockput(ip);
801074c0:	83 ec 0c             	sub    $0xc,%esp
801074c3:	ff 75 f0             	pushl  -0x10(%ebp)
801074c6:	e8 fd a7 ff ff       	call   80101cc8 <iunlockput>
801074cb:	83 c4 10             	add    $0x10,%esp
    goto bad;
801074ce:	e9 b2 00 00 00       	jmp    80107585 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
801074d3:	83 ec 04             	sub    $0x4,%esp
801074d6:	6a 10                	push   $0x10
801074d8:	6a 00                	push   $0x0
801074da:	8d 45 e0             	lea    -0x20(%ebp),%eax
801074dd:	50                   	push   %eax
801074de:	e8 e3 f5 ff ff       	call   80106ac6 <memset>
801074e3:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801074e6:	8b 45 c8             	mov    -0x38(%ebp),%eax
801074e9:	6a 10                	push   $0x10
801074eb:	50                   	push   %eax
801074ec:	8d 45 e0             	lea    -0x20(%ebp),%eax
801074ef:	50                   	push   %eax
801074f0:	ff 75 f4             	pushl  -0xc(%ebp)
801074f3:	e8 d5 ab ff ff       	call   801020cd <writei>
801074f8:	83 c4 10             	add    $0x10,%esp
801074fb:	83 f8 10             	cmp    $0x10,%eax
801074fe:	74 0d                	je     8010750d <sys_unlink+0x151>
    panic("unlink: writei");
80107500:	83 ec 0c             	sub    $0xc,%esp
80107503:	68 68 a7 10 80       	push   $0x8010a768
80107508:	e8 59 90 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
8010750d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107510:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107514:	66 83 f8 01          	cmp    $0x1,%ax
80107518:	75 21                	jne    8010753b <sys_unlink+0x17f>
    dp->nlink--;
8010751a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010751d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80107521:	83 e8 01             	sub    $0x1,%eax
80107524:	89 c2                	mov    %eax,%edx
80107526:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107529:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
8010752d:	83 ec 0c             	sub    $0xc,%esp
80107530:	ff 75 f4             	pushl  -0xc(%ebp)
80107533:	e8 f6 a2 ff ff       	call   8010182e <iupdate>
80107538:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
8010753b:	83 ec 0c             	sub    $0xc,%esp
8010753e:	ff 75 f4             	pushl  -0xc(%ebp)
80107541:	e8 82 a7 ff ff       	call   80101cc8 <iunlockput>
80107546:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80107549:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010754c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80107550:	83 e8 01             	sub    $0x1,%eax
80107553:	89 c2                	mov    %eax,%edx
80107555:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107558:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010755c:	83 ec 0c             	sub    $0xc,%esp
8010755f:	ff 75 f0             	pushl  -0x10(%ebp)
80107562:	e8 c7 a2 ff ff       	call   8010182e <iupdate>
80107567:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010756a:	83 ec 0c             	sub    $0xc,%esp
8010756d:	ff 75 f0             	pushl  -0x10(%ebp)
80107570:	e8 53 a7 ff ff       	call   80101cc8 <iunlockput>
80107575:	83 c4 10             	add    $0x10,%esp

  end_op();
80107578:	e8 fa c0 ff ff       	call   80103677 <end_op>

  return 0;
8010757d:	b8 00 00 00 00       	mov    $0x0,%eax
80107582:	eb 19                	jmp    8010759d <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80107584:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80107585:	83 ec 0c             	sub    $0xc,%esp
80107588:	ff 75 f4             	pushl  -0xc(%ebp)
8010758b:	e8 38 a7 ff ff       	call   80101cc8 <iunlockput>
80107590:	83 c4 10             	add    $0x10,%esp
  end_op();
80107593:	e8 df c0 ff ff       	call   80103677 <end_op>
  return -1;
80107598:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010759d:	c9                   	leave  
8010759e:	c3                   	ret    

8010759f <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010759f:	55                   	push   %ebp
801075a0:	89 e5                	mov    %esp,%ebp
801075a2:	83 ec 38             	sub    $0x38,%esp
801075a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801075a8:	8b 55 10             	mov    0x10(%ebp),%edx
801075ab:	8b 45 14             	mov    0x14(%ebp),%eax
801075ae:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801075b2:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801075b6:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801075ba:	83 ec 08             	sub    $0x8,%esp
801075bd:	8d 45 de             	lea    -0x22(%ebp),%eax
801075c0:	50                   	push   %eax
801075c1:	ff 75 08             	pushl  0x8(%ebp)
801075c4:	e8 19 b0 ff ff       	call   801025e2 <nameiparent>
801075c9:	83 c4 10             	add    $0x10,%esp
801075cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801075cf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801075d3:	75 0a                	jne    801075df <create+0x40>
    return 0;
801075d5:	b8 00 00 00 00       	mov    $0x0,%eax
801075da:	e9 90 01 00 00       	jmp    8010776f <create+0x1d0>
  ilock(dp);
801075df:	83 ec 0c             	sub    $0xc,%esp
801075e2:	ff 75 f4             	pushl  -0xc(%ebp)
801075e5:	e8 1e a4 ff ff       	call   80101a08 <ilock>
801075ea:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801075ed:	83 ec 04             	sub    $0x4,%esp
801075f0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801075f3:	50                   	push   %eax
801075f4:	8d 45 de             	lea    -0x22(%ebp),%eax
801075f7:	50                   	push   %eax
801075f8:	ff 75 f4             	pushl  -0xc(%ebp)
801075fb:	e8 70 ac ff ff       	call   80102270 <dirlookup>
80107600:	83 c4 10             	add    $0x10,%esp
80107603:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107606:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010760a:	74 50                	je     8010765c <create+0xbd>
    iunlockput(dp);
8010760c:	83 ec 0c             	sub    $0xc,%esp
8010760f:	ff 75 f4             	pushl  -0xc(%ebp)
80107612:	e8 b1 a6 ff ff       	call   80101cc8 <iunlockput>
80107617:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
8010761a:	83 ec 0c             	sub    $0xc,%esp
8010761d:	ff 75 f0             	pushl  -0x10(%ebp)
80107620:	e8 e3 a3 ff ff       	call   80101a08 <ilock>
80107625:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80107628:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
8010762d:	75 15                	jne    80107644 <create+0xa5>
8010762f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107632:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107636:	66 83 f8 02          	cmp    $0x2,%ax
8010763a:	75 08                	jne    80107644 <create+0xa5>
      return ip;
8010763c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010763f:	e9 2b 01 00 00       	jmp    8010776f <create+0x1d0>
    iunlockput(ip);
80107644:	83 ec 0c             	sub    $0xc,%esp
80107647:	ff 75 f0             	pushl  -0x10(%ebp)
8010764a:	e8 79 a6 ff ff       	call   80101cc8 <iunlockput>
8010764f:	83 c4 10             	add    $0x10,%esp
    return 0;
80107652:	b8 00 00 00 00       	mov    $0x0,%eax
80107657:	e9 13 01 00 00       	jmp    8010776f <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010765c:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80107660:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107663:	8b 00                	mov    (%eax),%eax
80107665:	83 ec 08             	sub    $0x8,%esp
80107668:	52                   	push   %edx
80107669:	50                   	push   %eax
8010766a:	e8 e8 a0 ff ff       	call   80101757 <ialloc>
8010766f:	83 c4 10             	add    $0x10,%esp
80107672:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107675:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107679:	75 0d                	jne    80107688 <create+0xe9>
    panic("create: ialloc");
8010767b:	83 ec 0c             	sub    $0xc,%esp
8010767e:	68 77 a7 10 80       	push   $0x8010a777
80107683:	e8 de 8e ff ff       	call   80100566 <panic>

  ilock(ip);
80107688:	83 ec 0c             	sub    $0xc,%esp
8010768b:	ff 75 f0             	pushl  -0x10(%ebp)
8010768e:	e8 75 a3 ff ff       	call   80101a08 <ilock>
80107693:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80107696:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107699:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010769d:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
801076a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076a4:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801076a8:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
801076ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076af:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
801076b5:	83 ec 0c             	sub    $0xc,%esp
801076b8:	ff 75 f0             	pushl  -0x10(%ebp)
801076bb:	e8 6e a1 ff ff       	call   8010182e <iupdate>
801076c0:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801076c3:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801076c8:	75 6a                	jne    80107734 <create+0x195>
    dp->nlink++;  // for ".."
801076ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076cd:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801076d1:	83 c0 01             	add    $0x1,%eax
801076d4:	89 c2                	mov    %eax,%edx
801076d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076d9:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801076dd:	83 ec 0c             	sub    $0xc,%esp
801076e0:	ff 75 f4             	pushl  -0xc(%ebp)
801076e3:	e8 46 a1 ff ff       	call   8010182e <iupdate>
801076e8:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801076eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076ee:	8b 40 04             	mov    0x4(%eax),%eax
801076f1:	83 ec 04             	sub    $0x4,%esp
801076f4:	50                   	push   %eax
801076f5:	68 51 a7 10 80       	push   $0x8010a751
801076fa:	ff 75 f0             	pushl  -0x10(%ebp)
801076fd:	e8 28 ac ff ff       	call   8010232a <dirlink>
80107702:	83 c4 10             	add    $0x10,%esp
80107705:	85 c0                	test   %eax,%eax
80107707:	78 1e                	js     80107727 <create+0x188>
80107709:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010770c:	8b 40 04             	mov    0x4(%eax),%eax
8010770f:	83 ec 04             	sub    $0x4,%esp
80107712:	50                   	push   %eax
80107713:	68 53 a7 10 80       	push   $0x8010a753
80107718:	ff 75 f0             	pushl  -0x10(%ebp)
8010771b:	e8 0a ac ff ff       	call   8010232a <dirlink>
80107720:	83 c4 10             	add    $0x10,%esp
80107723:	85 c0                	test   %eax,%eax
80107725:	79 0d                	jns    80107734 <create+0x195>
      panic("create dots");
80107727:	83 ec 0c             	sub    $0xc,%esp
8010772a:	68 86 a7 10 80       	push   $0x8010a786
8010772f:	e8 32 8e ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80107734:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107737:	8b 40 04             	mov    0x4(%eax),%eax
8010773a:	83 ec 04             	sub    $0x4,%esp
8010773d:	50                   	push   %eax
8010773e:	8d 45 de             	lea    -0x22(%ebp),%eax
80107741:	50                   	push   %eax
80107742:	ff 75 f4             	pushl  -0xc(%ebp)
80107745:	e8 e0 ab ff ff       	call   8010232a <dirlink>
8010774a:	83 c4 10             	add    $0x10,%esp
8010774d:	85 c0                	test   %eax,%eax
8010774f:	79 0d                	jns    8010775e <create+0x1bf>
    panic("create: dirlink");
80107751:	83 ec 0c             	sub    $0xc,%esp
80107754:	68 92 a7 10 80       	push   $0x8010a792
80107759:	e8 08 8e ff ff       	call   80100566 <panic>

  iunlockput(dp);
8010775e:	83 ec 0c             	sub    $0xc,%esp
80107761:	ff 75 f4             	pushl  -0xc(%ebp)
80107764:	e8 5f a5 ff ff       	call   80101cc8 <iunlockput>
80107769:	83 c4 10             	add    $0x10,%esp

  return ip;
8010776c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010776f:	c9                   	leave  
80107770:	c3                   	ret    

80107771 <sys_open>:

int
sys_open(void)
{
80107771:	55                   	push   %ebp
80107772:	89 e5                	mov    %esp,%ebp
80107774:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80107777:	83 ec 08             	sub    $0x8,%esp
8010777a:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010777d:	50                   	push   %eax
8010777e:	6a 00                	push   $0x0
80107780:	e8 eb f6 ff ff       	call   80106e70 <argstr>
80107785:	83 c4 10             	add    $0x10,%esp
80107788:	85 c0                	test   %eax,%eax
8010778a:	78 15                	js     801077a1 <sys_open+0x30>
8010778c:	83 ec 08             	sub    $0x8,%esp
8010778f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107792:	50                   	push   %eax
80107793:	6a 01                	push   $0x1
80107795:	e8 51 f6 ff ff       	call   80106deb <argint>
8010779a:	83 c4 10             	add    $0x10,%esp
8010779d:	85 c0                	test   %eax,%eax
8010779f:	79 0a                	jns    801077ab <sys_open+0x3a>
    return -1;
801077a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801077a6:	e9 61 01 00 00       	jmp    8010790c <sys_open+0x19b>

  begin_op();
801077ab:	e8 3b be ff ff       	call   801035eb <begin_op>

  if(omode & O_CREATE){
801077b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801077b3:	25 00 02 00 00       	and    $0x200,%eax
801077b8:	85 c0                	test   %eax,%eax
801077ba:	74 2a                	je     801077e6 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
801077bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801077bf:	6a 00                	push   $0x0
801077c1:	6a 00                	push   $0x0
801077c3:	6a 02                	push   $0x2
801077c5:	50                   	push   %eax
801077c6:	e8 d4 fd ff ff       	call   8010759f <create>
801077cb:	83 c4 10             	add    $0x10,%esp
801077ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801077d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801077d5:	75 75                	jne    8010784c <sys_open+0xdb>
      end_op();
801077d7:	e8 9b be ff ff       	call   80103677 <end_op>
      return -1;
801077dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801077e1:	e9 26 01 00 00       	jmp    8010790c <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
801077e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801077e9:	83 ec 0c             	sub    $0xc,%esp
801077ec:	50                   	push   %eax
801077ed:	e8 d4 ad ff ff       	call   801025c6 <namei>
801077f2:	83 c4 10             	add    $0x10,%esp
801077f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801077f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801077fc:	75 0f                	jne    8010780d <sys_open+0x9c>
      end_op();
801077fe:	e8 74 be ff ff       	call   80103677 <end_op>
      return -1;
80107803:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107808:	e9 ff 00 00 00       	jmp    8010790c <sys_open+0x19b>
    }
    ilock(ip);
8010780d:	83 ec 0c             	sub    $0xc,%esp
80107810:	ff 75 f4             	pushl  -0xc(%ebp)
80107813:	e8 f0 a1 ff ff       	call   80101a08 <ilock>
80107818:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
8010781b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010781e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107822:	66 83 f8 01          	cmp    $0x1,%ax
80107826:	75 24                	jne    8010784c <sys_open+0xdb>
80107828:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010782b:	85 c0                	test   %eax,%eax
8010782d:	74 1d                	je     8010784c <sys_open+0xdb>
      iunlockput(ip);
8010782f:	83 ec 0c             	sub    $0xc,%esp
80107832:	ff 75 f4             	pushl  -0xc(%ebp)
80107835:	e8 8e a4 ff ff       	call   80101cc8 <iunlockput>
8010783a:	83 c4 10             	add    $0x10,%esp
      end_op();
8010783d:	e8 35 be ff ff       	call   80103677 <end_op>
      return -1;
80107842:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107847:	e9 c0 00 00 00       	jmp    8010790c <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010784c:	e8 e0 97 ff ff       	call   80101031 <filealloc>
80107851:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107854:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107858:	74 17                	je     80107871 <sys_open+0x100>
8010785a:	83 ec 0c             	sub    $0xc,%esp
8010785d:	ff 75 f0             	pushl  -0x10(%ebp)
80107860:	e8 37 f7 ff ff       	call   80106f9c <fdalloc>
80107865:	83 c4 10             	add    $0x10,%esp
80107868:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010786b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010786f:	79 2e                	jns    8010789f <sys_open+0x12e>
    if(f)
80107871:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107875:	74 0e                	je     80107885 <sys_open+0x114>
      fileclose(f);
80107877:	83 ec 0c             	sub    $0xc,%esp
8010787a:	ff 75 f0             	pushl  -0x10(%ebp)
8010787d:	e8 6d 98 ff ff       	call   801010ef <fileclose>
80107882:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80107885:	83 ec 0c             	sub    $0xc,%esp
80107888:	ff 75 f4             	pushl  -0xc(%ebp)
8010788b:	e8 38 a4 ff ff       	call   80101cc8 <iunlockput>
80107890:	83 c4 10             	add    $0x10,%esp
    end_op();
80107893:	e8 df bd ff ff       	call   80103677 <end_op>
    return -1;
80107898:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010789d:	eb 6d                	jmp    8010790c <sys_open+0x19b>
  }
  iunlock(ip);
8010789f:	83 ec 0c             	sub    $0xc,%esp
801078a2:	ff 75 f4             	pushl  -0xc(%ebp)
801078a5:	e8 bc a2 ff ff       	call   80101b66 <iunlock>
801078aa:	83 c4 10             	add    $0x10,%esp
  end_op();
801078ad:	e8 c5 bd ff ff       	call   80103677 <end_op>

  f->type = FD_INODE;
801078b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078b5:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801078bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078be:	8b 55 f4             	mov    -0xc(%ebp),%edx
801078c1:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801078c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078c7:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801078ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801078d1:	83 e0 01             	and    $0x1,%eax
801078d4:	85 c0                	test   %eax,%eax
801078d6:	0f 94 c0             	sete   %al
801078d9:	89 c2                	mov    %eax,%edx
801078db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078de:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801078e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801078e4:	83 e0 01             	and    $0x1,%eax
801078e7:	85 c0                	test   %eax,%eax
801078e9:	75 0a                	jne    801078f5 <sys_open+0x184>
801078eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801078ee:	83 e0 02             	and    $0x2,%eax
801078f1:	85 c0                	test   %eax,%eax
801078f3:	74 07                	je     801078fc <sys_open+0x18b>
801078f5:	b8 01 00 00 00       	mov    $0x1,%eax
801078fa:	eb 05                	jmp    80107901 <sys_open+0x190>
801078fc:	b8 00 00 00 00       	mov    $0x0,%eax
80107901:	89 c2                	mov    %eax,%edx
80107903:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107906:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80107909:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010790c:	c9                   	leave  
8010790d:	c3                   	ret    

8010790e <sys_mkdir>:

int
sys_mkdir(void)
{
8010790e:	55                   	push   %ebp
8010790f:	89 e5                	mov    %esp,%ebp
80107911:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80107914:	e8 d2 bc ff ff       	call   801035eb <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80107919:	83 ec 08             	sub    $0x8,%esp
8010791c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010791f:	50                   	push   %eax
80107920:	6a 00                	push   $0x0
80107922:	e8 49 f5 ff ff       	call   80106e70 <argstr>
80107927:	83 c4 10             	add    $0x10,%esp
8010792a:	85 c0                	test   %eax,%eax
8010792c:	78 1b                	js     80107949 <sys_mkdir+0x3b>
8010792e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107931:	6a 00                	push   $0x0
80107933:	6a 00                	push   $0x0
80107935:	6a 01                	push   $0x1
80107937:	50                   	push   %eax
80107938:	e8 62 fc ff ff       	call   8010759f <create>
8010793d:	83 c4 10             	add    $0x10,%esp
80107940:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107943:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107947:	75 0c                	jne    80107955 <sys_mkdir+0x47>
    end_op();
80107949:	e8 29 bd ff ff       	call   80103677 <end_op>
    return -1;
8010794e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107953:	eb 18                	jmp    8010796d <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80107955:	83 ec 0c             	sub    $0xc,%esp
80107958:	ff 75 f4             	pushl  -0xc(%ebp)
8010795b:	e8 68 a3 ff ff       	call   80101cc8 <iunlockput>
80107960:	83 c4 10             	add    $0x10,%esp
  end_op();
80107963:	e8 0f bd ff ff       	call   80103677 <end_op>
  return 0;
80107968:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010796d:	c9                   	leave  
8010796e:	c3                   	ret    

8010796f <sys_mknod>:

int
sys_mknod(void)
{
8010796f:	55                   	push   %ebp
80107970:	89 e5                	mov    %esp,%ebp
80107972:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80107975:	e8 71 bc ff ff       	call   801035eb <begin_op>
  if((len=argstr(0, &path)) < 0 ||
8010797a:	83 ec 08             	sub    $0x8,%esp
8010797d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107980:	50                   	push   %eax
80107981:	6a 00                	push   $0x0
80107983:	e8 e8 f4 ff ff       	call   80106e70 <argstr>
80107988:	83 c4 10             	add    $0x10,%esp
8010798b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010798e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107992:	78 4f                	js     801079e3 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80107994:	83 ec 08             	sub    $0x8,%esp
80107997:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010799a:	50                   	push   %eax
8010799b:	6a 01                	push   $0x1
8010799d:	e8 49 f4 ff ff       	call   80106deb <argint>
801079a2:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
801079a5:	85 c0                	test   %eax,%eax
801079a7:	78 3a                	js     801079e3 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801079a9:	83 ec 08             	sub    $0x8,%esp
801079ac:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801079af:	50                   	push   %eax
801079b0:	6a 02                	push   $0x2
801079b2:	e8 34 f4 ff ff       	call   80106deb <argint>
801079b7:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801079ba:	85 c0                	test   %eax,%eax
801079bc:	78 25                	js     801079e3 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801079be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801079c1:	0f bf c8             	movswl %ax,%ecx
801079c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801079c7:	0f bf d0             	movswl %ax,%edx
801079ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801079cd:	51                   	push   %ecx
801079ce:	52                   	push   %edx
801079cf:	6a 03                	push   $0x3
801079d1:	50                   	push   %eax
801079d2:	e8 c8 fb ff ff       	call   8010759f <create>
801079d7:	83 c4 10             	add    $0x10,%esp
801079da:	89 45 f0             	mov    %eax,-0x10(%ebp)
801079dd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801079e1:	75 0c                	jne    801079ef <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
801079e3:	e8 8f bc ff ff       	call   80103677 <end_op>
    return -1;
801079e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801079ed:	eb 18                	jmp    80107a07 <sys_mknod+0x98>
  }
  iunlockput(ip);
801079ef:	83 ec 0c             	sub    $0xc,%esp
801079f2:	ff 75 f0             	pushl  -0x10(%ebp)
801079f5:	e8 ce a2 ff ff       	call   80101cc8 <iunlockput>
801079fa:	83 c4 10             	add    $0x10,%esp
  end_op();
801079fd:	e8 75 bc ff ff       	call   80103677 <end_op>
  return 0;
80107a02:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107a07:	c9                   	leave  
80107a08:	c3                   	ret    

80107a09 <sys_chdir>:

int
sys_chdir(void)
{
80107a09:	55                   	push   %ebp
80107a0a:	89 e5                	mov    %esp,%ebp
80107a0c:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80107a0f:	e8 d7 bb ff ff       	call   801035eb <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80107a14:	83 ec 08             	sub    $0x8,%esp
80107a17:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107a1a:	50                   	push   %eax
80107a1b:	6a 00                	push   $0x0
80107a1d:	e8 4e f4 ff ff       	call   80106e70 <argstr>
80107a22:	83 c4 10             	add    $0x10,%esp
80107a25:	85 c0                	test   %eax,%eax
80107a27:	78 18                	js     80107a41 <sys_chdir+0x38>
80107a29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a2c:	83 ec 0c             	sub    $0xc,%esp
80107a2f:	50                   	push   %eax
80107a30:	e8 91 ab ff ff       	call   801025c6 <namei>
80107a35:	83 c4 10             	add    $0x10,%esp
80107a38:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107a3b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107a3f:	75 0c                	jne    80107a4d <sys_chdir+0x44>
    end_op();
80107a41:	e8 31 bc ff ff       	call   80103677 <end_op>
    return -1;
80107a46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a4b:	eb 6e                	jmp    80107abb <sys_chdir+0xb2>
  }
  ilock(ip);
80107a4d:	83 ec 0c             	sub    $0xc,%esp
80107a50:	ff 75 f4             	pushl  -0xc(%ebp)
80107a53:	e8 b0 9f ff ff       	call   80101a08 <ilock>
80107a58:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80107a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a5e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107a62:	66 83 f8 01          	cmp    $0x1,%ax
80107a66:	74 1a                	je     80107a82 <sys_chdir+0x79>
    iunlockput(ip);
80107a68:	83 ec 0c             	sub    $0xc,%esp
80107a6b:	ff 75 f4             	pushl  -0xc(%ebp)
80107a6e:	e8 55 a2 ff ff       	call   80101cc8 <iunlockput>
80107a73:	83 c4 10             	add    $0x10,%esp
    end_op();
80107a76:	e8 fc bb ff ff       	call   80103677 <end_op>
    return -1;
80107a7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a80:	eb 39                	jmp    80107abb <sys_chdir+0xb2>
  }
  iunlock(ip);
80107a82:	83 ec 0c             	sub    $0xc,%esp
80107a85:	ff 75 f4             	pushl  -0xc(%ebp)
80107a88:	e8 d9 a0 ff ff       	call   80101b66 <iunlock>
80107a8d:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80107a90:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107a96:	8b 40 68             	mov    0x68(%eax),%eax
80107a99:	83 ec 0c             	sub    $0xc,%esp
80107a9c:	50                   	push   %eax
80107a9d:	e8 36 a1 ff ff       	call   80101bd8 <iput>
80107aa2:	83 c4 10             	add    $0x10,%esp
  end_op();
80107aa5:	e8 cd bb ff ff       	call   80103677 <end_op>
  proc->cwd = ip;
80107aaa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107ab0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107ab3:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80107ab6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107abb:	c9                   	leave  
80107abc:	c3                   	ret    

80107abd <sys_exec>:

int
sys_exec(void)
{
80107abd:	55                   	push   %ebp
80107abe:	89 e5                	mov    %esp,%ebp
80107ac0:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80107ac6:	83 ec 08             	sub    $0x8,%esp
80107ac9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107acc:	50                   	push   %eax
80107acd:	6a 00                	push   $0x0
80107acf:	e8 9c f3 ff ff       	call   80106e70 <argstr>
80107ad4:	83 c4 10             	add    $0x10,%esp
80107ad7:	85 c0                	test   %eax,%eax
80107ad9:	78 18                	js     80107af3 <sys_exec+0x36>
80107adb:	83 ec 08             	sub    $0x8,%esp
80107ade:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80107ae4:	50                   	push   %eax
80107ae5:	6a 01                	push   $0x1
80107ae7:	e8 ff f2 ff ff       	call   80106deb <argint>
80107aec:	83 c4 10             	add    $0x10,%esp
80107aef:	85 c0                	test   %eax,%eax
80107af1:	79 0a                	jns    80107afd <sys_exec+0x40>
    return -1;
80107af3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107af8:	e9 c6 00 00 00       	jmp    80107bc3 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80107afd:	83 ec 04             	sub    $0x4,%esp
80107b00:	68 80 00 00 00       	push   $0x80
80107b05:	6a 00                	push   $0x0
80107b07:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80107b0d:	50                   	push   %eax
80107b0e:	e8 b3 ef ff ff       	call   80106ac6 <memset>
80107b13:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80107b16:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80107b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b20:	83 f8 1f             	cmp    $0x1f,%eax
80107b23:	76 0a                	jbe    80107b2f <sys_exec+0x72>
      return -1;
80107b25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b2a:	e9 94 00 00 00       	jmp    80107bc3 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80107b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b32:	c1 e0 02             	shl    $0x2,%eax
80107b35:	89 c2                	mov    %eax,%edx
80107b37:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80107b3d:	01 c2                	add    %eax,%edx
80107b3f:	83 ec 08             	sub    $0x8,%esp
80107b42:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80107b48:	50                   	push   %eax
80107b49:	52                   	push   %edx
80107b4a:	e8 00 f2 ff ff       	call   80106d4f <fetchint>
80107b4f:	83 c4 10             	add    $0x10,%esp
80107b52:	85 c0                	test   %eax,%eax
80107b54:	79 07                	jns    80107b5d <sys_exec+0xa0>
      return -1;
80107b56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b5b:	eb 66                	jmp    80107bc3 <sys_exec+0x106>
    if(uarg == 0){
80107b5d:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107b63:	85 c0                	test   %eax,%eax
80107b65:	75 27                	jne    80107b8e <sys_exec+0xd1>
      argv[i] = 0;
80107b67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b6a:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80107b71:	00 00 00 00 
      break;
80107b75:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80107b76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b79:	83 ec 08             	sub    $0x8,%esp
80107b7c:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80107b82:	52                   	push   %edx
80107b83:	50                   	push   %eax
80107b84:	e8 86 90 ff ff       	call   80100c0f <exec>
80107b89:	83 c4 10             	add    $0x10,%esp
80107b8c:	eb 35                	jmp    80107bc3 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80107b8e:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80107b94:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107b97:	c1 e2 02             	shl    $0x2,%edx
80107b9a:	01 c2                	add    %eax,%edx
80107b9c:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107ba2:	83 ec 08             	sub    $0x8,%esp
80107ba5:	52                   	push   %edx
80107ba6:	50                   	push   %eax
80107ba7:	e8 dd f1 ff ff       	call   80106d89 <fetchstr>
80107bac:	83 c4 10             	add    $0x10,%esp
80107baf:	85 c0                	test   %eax,%eax
80107bb1:	79 07                	jns    80107bba <sys_exec+0xfd>
      return -1;
80107bb3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107bb8:	eb 09                	jmp    80107bc3 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80107bba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80107bbe:	e9 5a ff ff ff       	jmp    80107b1d <sys_exec+0x60>
  return exec(path, argv);
}
80107bc3:	c9                   	leave  
80107bc4:	c3                   	ret    

80107bc5 <sys_pipe>:

int
sys_pipe(void)
{
80107bc5:	55                   	push   %ebp
80107bc6:	89 e5                	mov    %esp,%ebp
80107bc8:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80107bcb:	83 ec 04             	sub    $0x4,%esp
80107bce:	6a 08                	push   $0x8
80107bd0:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107bd3:	50                   	push   %eax
80107bd4:	6a 00                	push   $0x0
80107bd6:	e8 38 f2 ff ff       	call   80106e13 <argptr>
80107bdb:	83 c4 10             	add    $0x10,%esp
80107bde:	85 c0                	test   %eax,%eax
80107be0:	79 0a                	jns    80107bec <sys_pipe+0x27>
    return -1;
80107be2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107be7:	e9 af 00 00 00       	jmp    80107c9b <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80107bec:	83 ec 08             	sub    $0x8,%esp
80107bef:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107bf2:	50                   	push   %eax
80107bf3:	8d 45 e8             	lea    -0x18(%ebp),%eax
80107bf6:	50                   	push   %eax
80107bf7:	e8 e3 c4 ff ff       	call   801040df <pipealloc>
80107bfc:	83 c4 10             	add    $0x10,%esp
80107bff:	85 c0                	test   %eax,%eax
80107c01:	79 0a                	jns    80107c0d <sys_pipe+0x48>
    return -1;
80107c03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c08:	e9 8e 00 00 00       	jmp    80107c9b <sys_pipe+0xd6>
  fd0 = -1;
80107c0d:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80107c14:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107c17:	83 ec 0c             	sub    $0xc,%esp
80107c1a:	50                   	push   %eax
80107c1b:	e8 7c f3 ff ff       	call   80106f9c <fdalloc>
80107c20:	83 c4 10             	add    $0x10,%esp
80107c23:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107c26:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107c2a:	78 18                	js     80107c44 <sys_pipe+0x7f>
80107c2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107c2f:	83 ec 0c             	sub    $0xc,%esp
80107c32:	50                   	push   %eax
80107c33:	e8 64 f3 ff ff       	call   80106f9c <fdalloc>
80107c38:	83 c4 10             	add    $0x10,%esp
80107c3b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107c3e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107c42:	79 3f                	jns    80107c83 <sys_pipe+0xbe>
    if(fd0 >= 0)
80107c44:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107c48:	78 14                	js     80107c5e <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80107c4a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107c50:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107c53:	83 c2 08             	add    $0x8,%edx
80107c56:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80107c5d:	00 
    fileclose(rf);
80107c5e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107c61:	83 ec 0c             	sub    $0xc,%esp
80107c64:	50                   	push   %eax
80107c65:	e8 85 94 ff ff       	call   801010ef <fileclose>
80107c6a:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80107c6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107c70:	83 ec 0c             	sub    $0xc,%esp
80107c73:	50                   	push   %eax
80107c74:	e8 76 94 ff ff       	call   801010ef <fileclose>
80107c79:	83 c4 10             	add    $0x10,%esp
    return -1;
80107c7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c81:	eb 18                	jmp    80107c9b <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80107c83:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c86:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107c89:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80107c8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c8e:	8d 50 04             	lea    0x4(%eax),%edx
80107c91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c94:	89 02                	mov    %eax,(%edx)
  return 0;
80107c96:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107c9b:	c9                   	leave  
80107c9c:	c3                   	ret    

80107c9d <outw>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outw(ushort port, ushort data)
{
80107c9d:	55                   	push   %ebp
80107c9e:	89 e5                	mov    %esp,%ebp
80107ca0:	83 ec 08             	sub    $0x8,%esp
80107ca3:	8b 55 08             	mov    0x8(%ebp),%edx
80107ca6:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ca9:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107cad:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107cb1:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
80107cb5:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107cb9:	66 ef                	out    %ax,(%dx)
}
80107cbb:	90                   	nop
80107cbc:	c9                   	leave  
80107cbd:	c3                   	ret    

80107cbe <sys_fork>:
#include "proc.h"
#include "uproc.h"

int
sys_fork(void)
{
80107cbe:	55                   	push   %ebp
80107cbf:	89 e5                	mov    %esp,%ebp
80107cc1:	83 ec 08             	sub    $0x8,%esp
  return fork();
80107cc4:	e8 20 cd ff ff       	call   801049e9 <fork>
}
80107cc9:	c9                   	leave  
80107cca:	c3                   	ret    

80107ccb <sys_exit>:

int
sys_exit(void)
{
80107ccb:	55                   	push   %ebp
80107ccc:	89 e5                	mov    %esp,%ebp
80107cce:	83 ec 08             	sub    $0x8,%esp
  exit();
80107cd1:	e8 e0 cf ff ff       	call   80104cb6 <exit>
  return 0;  // not reached
80107cd6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107cdb:	c9                   	leave  
80107cdc:	c3                   	ret    

80107cdd <sys_wait>:

int
sys_wait(void)
{
80107cdd:	55                   	push   %ebp
80107cde:	89 e5                	mov    %esp,%ebp
80107ce0:	83 ec 08             	sub    $0x8,%esp
  return wait();
80107ce3:	e8 23 d2 ff ff       	call   80104f0b <wait>
}
80107ce8:	c9                   	leave  
80107ce9:	c3                   	ret    

80107cea <sys_kill>:

int
sys_kill(void)
{
80107cea:	55                   	push   %ebp
80107ceb:	89 e5                	mov    %esp,%ebp
80107ced:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80107cf0:	83 ec 08             	sub    $0x8,%esp
80107cf3:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107cf6:	50                   	push   %eax
80107cf7:	6a 00                	push   $0x0
80107cf9:	e8 ed f0 ff ff       	call   80106deb <argint>
80107cfe:	83 c4 10             	add    $0x10,%esp
80107d01:	85 c0                	test   %eax,%eax
80107d03:	79 07                	jns    80107d0c <sys_kill+0x22>
    return -1;
80107d05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d0a:	eb 0f                	jmp    80107d1b <sys_kill+0x31>
  return kill(pid);
80107d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d0f:	83 ec 0c             	sub    $0xc,%esp
80107d12:	50                   	push   %eax
80107d13:	e8 2a db ff ff       	call   80105842 <kill>
80107d18:	83 c4 10             	add    $0x10,%esp
}
80107d1b:	c9                   	leave  
80107d1c:	c3                   	ret    

80107d1d <sys_getpid>:

int
sys_getpid(void)
{
80107d1d:	55                   	push   %ebp
80107d1e:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80107d20:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107d26:	8b 40 10             	mov    0x10(%eax),%eax
}
80107d29:	5d                   	pop    %ebp
80107d2a:	c3                   	ret    

80107d2b <sys_sbrk>:

int
sys_sbrk(void)
{
80107d2b:	55                   	push   %ebp
80107d2c:	89 e5                	mov    %esp,%ebp
80107d2e:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80107d31:	83 ec 08             	sub    $0x8,%esp
80107d34:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107d37:	50                   	push   %eax
80107d38:	6a 00                	push   $0x0
80107d3a:	e8 ac f0 ff ff       	call   80106deb <argint>
80107d3f:	83 c4 10             	add    $0x10,%esp
80107d42:	85 c0                	test   %eax,%eax
80107d44:	79 07                	jns    80107d4d <sys_sbrk+0x22>
    return -1;
80107d46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d4b:	eb 28                	jmp    80107d75 <sys_sbrk+0x4a>
  addr = proc->sz;
80107d4d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107d53:	8b 00                	mov    (%eax),%eax
80107d55:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80107d58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d5b:	83 ec 0c             	sub    $0xc,%esp
80107d5e:	50                   	push   %eax
80107d5f:	e8 e2 cb ff ff       	call   80104946 <growproc>
80107d64:	83 c4 10             	add    $0x10,%esp
80107d67:	85 c0                	test   %eax,%eax
80107d69:	79 07                	jns    80107d72 <sys_sbrk+0x47>
    return -1;
80107d6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d70:	eb 03                	jmp    80107d75 <sys_sbrk+0x4a>
  return addr;
80107d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107d75:	c9                   	leave  
80107d76:	c3                   	ret    

80107d77 <sys_sleep>:

int
sys_sleep(void)
{
80107d77:	55                   	push   %ebp
80107d78:	89 e5                	mov    %esp,%ebp
80107d7a:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80107d7d:	83 ec 08             	sub    $0x8,%esp
80107d80:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107d83:	50                   	push   %eax
80107d84:	6a 00                	push   $0x0
80107d86:	e8 60 f0 ff ff       	call   80106deb <argint>
80107d8b:	83 c4 10             	add    $0x10,%esp
80107d8e:	85 c0                	test   %eax,%eax
80107d90:	79 07                	jns    80107d99 <sys_sleep+0x22>
    return -1;
80107d92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d97:	eb 44                	jmp    80107ddd <sys_sleep+0x66>
  ticks0 = ticks;
80107d99:	a1 00 79 11 80       	mov    0x80117900,%eax
80107d9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80107da1:	eb 26                	jmp    80107dc9 <sys_sleep+0x52>
    if(proc->killed){
80107da3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107da9:	8b 40 24             	mov    0x24(%eax),%eax
80107dac:	85 c0                	test   %eax,%eax
80107dae:	74 07                	je     80107db7 <sys_sleep+0x40>
      return -1;
80107db0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107db5:	eb 26                	jmp    80107ddd <sys_sleep+0x66>
    }
    sleep(&ticks, (struct spinlock *)0);
80107db7:	83 ec 08             	sub    $0x8,%esp
80107dba:	6a 00                	push   $0x0
80107dbc:	68 00 79 11 80       	push   $0x80117900
80107dc1:	e8 d0 d7 ff ff       	call   80105596 <sleep>
80107dc6:	83 c4 10             	add    $0x10,%esp
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80107dc9:	a1 00 79 11 80       	mov    0x80117900,%eax
80107dce:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107dd1:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107dd4:	39 d0                	cmp    %edx,%eax
80107dd6:	72 cb                	jb     80107da3 <sys_sleep+0x2c>
    if(proc->killed){
      return -1;
    }
    sleep(&ticks, (struct spinlock *)0);
  }
  return 0;
80107dd8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107ddd:	c9                   	leave  
80107dde:	c3                   	ret    

80107ddf <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80107ddf:	55                   	push   %ebp
80107de0:	89 e5                	mov    %esp,%ebp
80107de2:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  xticks = ticks;
80107de5:	a1 00 79 11 80       	mov    0x80117900,%eax
80107dea:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return xticks;
80107ded:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80107df0:	c9                   	leave  
80107df1:	c3                   	ret    

80107df2 <sys_halt>:

//Turn of the computer
int
sys_halt(void){
80107df2:	55                   	push   %ebp
80107df3:	89 e5                	mov    %esp,%ebp
80107df5:	83 ec 08             	sub    $0x8,%esp
  cprintf("Shutting down ...\n");
80107df8:	83 ec 0c             	sub    $0xc,%esp
80107dfb:	68 a2 a7 10 80       	push   $0x8010a7a2
80107e00:	e8 c1 85 ff ff       	call   801003c6 <cprintf>
80107e05:	83 c4 10             	add    $0x10,%esp
  outw( 0x604, 0x0 | 0x2000);
80107e08:	83 ec 08             	sub    $0x8,%esp
80107e0b:	68 00 20 00 00       	push   $0x2000
80107e10:	68 04 06 00 00       	push   $0x604
80107e15:	e8 83 fe ff ff       	call   80107c9d <outw>
80107e1a:	83 c4 10             	add    $0x10,%esp
  return 0;
80107e1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107e22:	c9                   	leave  
80107e23:	c3                   	ret    

80107e24 <sys_date>:


int
sys_date(void)
{
80107e24:	55                   	push   %ebp
80107e25:	89 e5                	mov    %esp,%ebp
80107e27:	83 ec 18             	sub    $0x18,%esp
  struct rtcdate *d;
  if(argptr(0, (void*)&d, sizeof(struct rtcdate)) < 0)
80107e2a:	83 ec 04             	sub    $0x4,%esp
80107e2d:	6a 18                	push   $0x18
80107e2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107e32:	50                   	push   %eax
80107e33:	6a 00                	push   $0x0
80107e35:	e8 d9 ef ff ff       	call   80106e13 <argptr>
80107e3a:	83 c4 10             	add    $0x10,%esp
80107e3d:	85 c0                	test   %eax,%eax
80107e3f:	79 07                	jns    80107e48 <sys_date+0x24>
    return -1;
80107e41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e46:	eb 14                	jmp    80107e5c <sys_date+0x38>
  cmostime(d);
80107e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4b:	83 ec 0c             	sub    $0xc,%esp
80107e4e:	50                   	push   %eax
80107e4f:	e8 12 b4 ff ff       	call   80103266 <cmostime>
80107e54:	83 c4 10             	add    $0x10,%esp
  return 0;
80107e57:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107e5c:	c9                   	leave  
80107e5d:	c3                   	ret    

80107e5e <sys_getuid>:

//Get gid
uint
sys_getuid(void)
{
80107e5e:	55                   	push   %ebp
80107e5f:	89 e5                	mov    %esp,%ebp
  return proc->uid;
80107e61:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107e67:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
80107e6d:	5d                   	pop    %ebp
80107e6e:	c3                   	ret    

80107e6f <sys_getgid>:

//Get gid
uint
sys_getgid(void)
{
80107e6f:	55                   	push   %ebp
80107e70:	89 e5                	mov    %esp,%ebp
  return proc->gid;
80107e72:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107e78:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
}
80107e7e:	5d                   	pop    %ebp
80107e7f:	c3                   	ret    

80107e80 <sys_getppid>:

//Returns init's pid, since it has no parent.
//Or returns the parents pid.
uint
sys_getppid(void)
{
80107e80:	55                   	push   %ebp
80107e81:	89 e5                	mov    %esp,%ebp
  if(proc->parent != 0)
80107e83:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107e89:	8b 40 14             	mov    0x14(%eax),%eax
80107e8c:	85 c0                	test   %eax,%eax
80107e8e:	74 0e                	je     80107e9e <sys_getppid+0x1e>
    return proc->parent->pid;
80107e90:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107e96:	8b 40 14             	mov    0x14(%eax),%eax
80107e99:	8b 40 10             	mov    0x10(%eax),%eax
80107e9c:	eb 09                	jmp    80107ea7 <sys_getppid+0x27>
  return proc->pid;
80107e9e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107ea4:	8b 40 10             	mov    0x10(%eax),%eax
}
80107ea7:	5d                   	pop    %ebp
80107ea8:	c3                   	ret    

80107ea9 <sys_setuid>:

//Sets the uid after making sure that the argument
//is within the bounds 0<=32767
int
sys_setuid(uint _uid)
{
80107ea9:	55                   	push   %ebp
80107eaa:	89 e5                	mov    %esp,%ebp
80107eac:	83 ec 08             	sub    $0x8,%esp
  argint(0, (int*)&_uid);
80107eaf:	83 ec 08             	sub    $0x8,%esp
80107eb2:	8d 45 08             	lea    0x8(%ebp),%eax
80107eb5:	50                   	push   %eax
80107eb6:	6a 00                	push   $0x0
80107eb8:	e8 2e ef ff ff       	call   80106deb <argint>
80107ebd:	83 c4 10             	add    $0x10,%esp
  if (_uid>= 0 && _uid<= 32767)
80107ec0:	8b 45 08             	mov    0x8(%ebp),%eax
80107ec3:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
80107ec8:	77 16                	ja     80107ee0 <sys_setuid+0x37>
  {
    proc->uid = _uid;
80107eca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107ed0:	8b 55 08             	mov    0x8(%ebp),%edx
80107ed3:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
    return 0;
80107ed9:	b8 00 00 00 00       	mov    $0x0,%eax
80107ede:	eb 05                	jmp    80107ee5 <sys_setuid+0x3c>
  }
  return -1;
80107ee0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107ee5:	c9                   	leave  
80107ee6:	c3                   	ret    

80107ee7 <sys_setgid>:

//Sets the gid after making sure that the argument
//is within the bouds 0<=32767
int
sys_setgid(uint _uid)
{
80107ee7:	55                   	push   %ebp
80107ee8:	89 e5                	mov    %esp,%ebp
80107eea:	83 ec 08             	sub    $0x8,%esp
  argint(0, (int*)&_uid);
80107eed:	83 ec 08             	sub    $0x8,%esp
80107ef0:	8d 45 08             	lea    0x8(%ebp),%eax
80107ef3:	50                   	push   %eax
80107ef4:	6a 00                	push   $0x0
80107ef6:	e8 f0 ee ff ff       	call   80106deb <argint>
80107efb:	83 c4 10             	add    $0x10,%esp
  if (_uid>= 0 && _uid<= 32767)
80107efe:	8b 45 08             	mov    0x8(%ebp),%eax
80107f01:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
80107f06:	77 16                	ja     80107f1e <sys_setgid+0x37>
  {
    proc->gid = _uid;
80107f08:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107f0e:	8b 55 08             	mov    0x8(%ebp),%edx
80107f11:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
    return 0;
80107f17:	b8 00 00 00 00       	mov    $0x0,%eax
80107f1c:	eb 05                	jmp    80107f23 <sys_setgid+0x3c>
  }
  return -1;
80107f1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107f23:	c9                   	leave  
80107f24:	c3                   	ret    

80107f25 <sys_getprocs>:

//Getprocs calls getprocs in proc.c in order to lock the ptable and
//grab all the processes off of that when ps is called.
int
sys_getprocs(int max, struct uproc* table)
{
80107f25:	55                   	push   %ebp
80107f26:	89 e5                	mov    %esp,%ebp
80107f28:	83 ec 08             	sub    $0x8,%esp
  if(argint(0,&max)< 0 || argptr(1,(void*)&table,sizeof(*table)*max) <0)
80107f2b:	83 ec 08             	sub    $0x8,%esp
80107f2e:	8d 45 08             	lea    0x8(%ebp),%eax
80107f31:	50                   	push   %eax
80107f32:	6a 00                	push   $0x0
80107f34:	e8 b2 ee ff ff       	call   80106deb <argint>
80107f39:	83 c4 10             	add    $0x10,%esp
80107f3c:	85 c0                	test   %eax,%eax
80107f3e:	78 24                	js     80107f64 <sys_getprocs+0x3f>
80107f40:	8b 45 08             	mov    0x8(%ebp),%eax
80107f43:	89 c2                	mov    %eax,%edx
80107f45:	89 d0                	mov    %edx,%eax
80107f47:	01 c0                	add    %eax,%eax
80107f49:	01 d0                	add    %edx,%eax
80107f4b:	c1 e0 05             	shl    $0x5,%eax
80107f4e:	83 ec 04             	sub    $0x4,%esp
80107f51:	50                   	push   %eax
80107f52:	8d 45 0c             	lea    0xc(%ebp),%eax
80107f55:	50                   	push   %eax
80107f56:	6a 01                	push   $0x1
80107f58:	e8 b6 ee ff ff       	call   80106e13 <argptr>
80107f5d:	83 c4 10             	add    $0x10,%esp
80107f60:	85 c0                	test   %eax,%eax
80107f62:	79 07                	jns    80107f6b <sys_getprocs+0x46>
    return -1;
80107f64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f69:	eb 13                	jmp    80107f7e <sys_getprocs+0x59>
  return getprocs(max,table);
80107f6b:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f6e:	8b 45 08             	mov    0x8(%ebp),%eax
80107f71:	83 ec 08             	sub    $0x8,%esp
80107f74:	52                   	push   %edx
80107f75:	50                   	push   %eax
80107f76:	e8 b1 df ff ff       	call   80105f2c <getprocs>
80107f7b:	83 c4 10             	add    $0x10,%esp
}
80107f7e:	c9                   	leave  
80107f7f:	c3                   	ret    

80107f80 <sys_setpriority>:

int
sys_setpriority(void)
{
80107f80:	55                   	push   %ebp
80107f81:	89 e5                	mov    %esp,%ebp
80107f83:	83 ec 18             	sub    $0x18,%esp
  int pid;
  int value;

  if(argint(0, &pid)< 0 || argint(1,&value))
80107f86:	83 ec 08             	sub    $0x8,%esp
80107f89:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107f8c:	50                   	push   %eax
80107f8d:	6a 00                	push   $0x0
80107f8f:	e8 57 ee ff ff       	call   80106deb <argint>
80107f94:	83 c4 10             	add    $0x10,%esp
80107f97:	85 c0                	test   %eax,%eax
80107f99:	78 15                	js     80107fb0 <sys_setpriority+0x30>
80107f9b:	83 ec 08             	sub    $0x8,%esp
80107f9e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107fa1:	50                   	push   %eax
80107fa2:	6a 01                	push   $0x1
80107fa4:	e8 42 ee ff ff       	call   80106deb <argint>
80107fa9:	83 c4 10             	add    $0x10,%esp
80107fac:	85 c0                	test   %eax,%eax
80107fae:	74 07                	je     80107fb7 <sys_setpriority+0x37>
    return -1;
80107fb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107fb5:	eb 13                	jmp    80107fca <sys_setpriority+0x4a>

  return setpriority(pid, value);
80107fb7:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fbd:	83 ec 08             	sub    $0x8,%esp
80107fc0:	52                   	push   %edx
80107fc1:	50                   	push   %eax
80107fc2:	e8 08 e4 ff ff       	call   801063cf <setpriority>
80107fc7:	83 c4 10             	add    $0x10,%esp
}
80107fca:	c9                   	leave  
80107fcb:	c3                   	ret    

80107fcc <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107fcc:	55                   	push   %ebp
80107fcd:	89 e5                	mov    %esp,%ebp
80107fcf:	83 ec 08             	sub    $0x8,%esp
80107fd2:	8b 55 08             	mov    0x8(%ebp),%edx
80107fd5:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fd8:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107fdc:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107fdf:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107fe3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107fe7:	ee                   	out    %al,(%dx)
}
80107fe8:	90                   	nop
80107fe9:	c9                   	leave  
80107fea:	c3                   	ret    

80107feb <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80107feb:	55                   	push   %ebp
80107fec:	89 e5                	mov    %esp,%ebp
80107fee:	83 ec 08             	sub    $0x8,%esp
  // Interrupt TPS times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80107ff1:	6a 34                	push   $0x34
80107ff3:	6a 43                	push   $0x43
80107ff5:	e8 d2 ff ff ff       	call   80107fcc <outb>
80107ffa:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) % 256);
80107ffd:	68 a9 00 00 00       	push   $0xa9
80108002:	6a 40                	push   $0x40
80108004:	e8 c3 ff ff ff       	call   80107fcc <outb>
80108009:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) / 256);
8010800c:	6a 04                	push   $0x4
8010800e:	6a 40                	push   $0x40
80108010:	e8 b7 ff ff ff       	call   80107fcc <outb>
80108015:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80108018:	83 ec 0c             	sub    $0xc,%esp
8010801b:	6a 00                	push   $0x0
8010801d:	e8 a7 bf ff ff       	call   80103fc9 <picenable>
80108022:	83 c4 10             	add    $0x10,%esp
}
80108025:	90                   	nop
80108026:	c9                   	leave  
80108027:	c3                   	ret    

80108028 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80108028:	1e                   	push   %ds
  pushl %es
80108029:	06                   	push   %es
  pushl %fs
8010802a:	0f a0                	push   %fs
  pushl %gs
8010802c:	0f a8                	push   %gs
  pushal
8010802e:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010802f:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80108033:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80108035:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80108037:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
8010803b:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
8010803d:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
8010803f:	54                   	push   %esp
  call trap
80108040:	e8 ce 01 00 00       	call   80108213 <trap>
  addl $4, %esp
80108045:	83 c4 04             	add    $0x4,%esp

80108048 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80108048:	61                   	popa   
  popl %gs
80108049:	0f a9                	pop    %gs
  popl %fs
8010804b:	0f a1                	pop    %fs
  popl %es
8010804d:	07                   	pop    %es
  popl %ds
8010804e:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010804f:	83 c4 08             	add    $0x8,%esp
  iret
80108052:	cf                   	iret   

80108053 <atom_inc>:

// Routines added for CS333
// atom_inc() added to simplify handling of ticks global
static inline void
atom_inc(volatile int *num)
{
80108053:	55                   	push   %ebp
80108054:	89 e5                	mov    %esp,%ebp
  asm volatile ( "lock incl %0" : "=m" (*num));
80108056:	8b 45 08             	mov    0x8(%ebp),%eax
80108059:	f0 ff 00             	lock incl (%eax)
}
8010805c:	90                   	nop
8010805d:	5d                   	pop    %ebp
8010805e:	c3                   	ret    

8010805f <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
8010805f:	55                   	push   %ebp
80108060:	89 e5                	mov    %esp,%ebp
80108062:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80108065:	8b 45 0c             	mov    0xc(%ebp),%eax
80108068:	83 e8 01             	sub    $0x1,%eax
8010806b:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010806f:	8b 45 08             	mov    0x8(%ebp),%eax
80108072:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80108076:	8b 45 08             	mov    0x8(%ebp),%eax
80108079:	c1 e8 10             	shr    $0x10,%eax
8010807c:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80108080:	8d 45 fa             	lea    -0x6(%ebp),%eax
80108083:	0f 01 18             	lidtl  (%eax)
}
80108086:	90                   	nop
80108087:	c9                   	leave  
80108088:	c3                   	ret    

80108089 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80108089:	55                   	push   %ebp
8010808a:	89 e5                	mov    %esp,%ebp
8010808c:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010808f:	0f 20 d0             	mov    %cr2,%eax
80108092:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80108095:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80108098:	c9                   	leave  
80108099:	c3                   	ret    

8010809a <tvinit>:
// Software Developer’s Manual, Vol 3A, 8.1.1 Guaranteed Atomic Operations.
uint ticks __attribute__ ((aligned (4)));

void
tvinit(void)
{
8010809a:	55                   	push   %ebp
8010809b:	89 e5                	mov    %esp,%ebp
8010809d:	83 ec 10             	sub    $0x10,%esp
  int i;

  for(i = 0; i < 256; i++)
801080a0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801080a7:	e9 c3 00 00 00       	jmp    8010816f <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801080ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080af:	8b 04 85 b4 d0 10 80 	mov    -0x7fef2f4c(,%eax,4),%eax
801080b6:	89 c2                	mov    %eax,%edx
801080b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080bb:	66 89 14 c5 00 71 11 	mov    %dx,-0x7fee8f00(,%eax,8)
801080c2:	80 
801080c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080c6:	66 c7 04 c5 02 71 11 	movw   $0x8,-0x7fee8efe(,%eax,8)
801080cd:	80 08 00 
801080d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080d3:	0f b6 14 c5 04 71 11 	movzbl -0x7fee8efc(,%eax,8),%edx
801080da:	80 
801080db:	83 e2 e0             	and    $0xffffffe0,%edx
801080de:	88 14 c5 04 71 11 80 	mov    %dl,-0x7fee8efc(,%eax,8)
801080e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080e8:	0f b6 14 c5 04 71 11 	movzbl -0x7fee8efc(,%eax,8),%edx
801080ef:	80 
801080f0:	83 e2 1f             	and    $0x1f,%edx
801080f3:	88 14 c5 04 71 11 80 	mov    %dl,-0x7fee8efc(,%eax,8)
801080fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080fd:	0f b6 14 c5 05 71 11 	movzbl -0x7fee8efb(,%eax,8),%edx
80108104:	80 
80108105:	83 e2 f0             	and    $0xfffffff0,%edx
80108108:	83 ca 0e             	or     $0xe,%edx
8010810b:	88 14 c5 05 71 11 80 	mov    %dl,-0x7fee8efb(,%eax,8)
80108112:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108115:	0f b6 14 c5 05 71 11 	movzbl -0x7fee8efb(,%eax,8),%edx
8010811c:	80 
8010811d:	83 e2 ef             	and    $0xffffffef,%edx
80108120:	88 14 c5 05 71 11 80 	mov    %dl,-0x7fee8efb(,%eax,8)
80108127:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010812a:	0f b6 14 c5 05 71 11 	movzbl -0x7fee8efb(,%eax,8),%edx
80108131:	80 
80108132:	83 e2 9f             	and    $0xffffff9f,%edx
80108135:	88 14 c5 05 71 11 80 	mov    %dl,-0x7fee8efb(,%eax,8)
8010813c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010813f:	0f b6 14 c5 05 71 11 	movzbl -0x7fee8efb(,%eax,8),%edx
80108146:	80 
80108147:	83 ca 80             	or     $0xffffff80,%edx
8010814a:	88 14 c5 05 71 11 80 	mov    %dl,-0x7fee8efb(,%eax,8)
80108151:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108154:	8b 04 85 b4 d0 10 80 	mov    -0x7fef2f4c(,%eax,4),%eax
8010815b:	c1 e8 10             	shr    $0x10,%eax
8010815e:	89 c2                	mov    %eax,%edx
80108160:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108163:	66 89 14 c5 06 71 11 	mov    %dx,-0x7fee8efa(,%eax,8)
8010816a:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010816b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010816f:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
80108176:	0f 8e 30 ff ff ff    	jle    801080ac <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010817c:	a1 b4 d1 10 80       	mov    0x8010d1b4,%eax
80108181:	66 a3 00 73 11 80    	mov    %ax,0x80117300
80108187:	66 c7 05 02 73 11 80 	movw   $0x8,0x80117302
8010818e:	08 00 
80108190:	0f b6 05 04 73 11 80 	movzbl 0x80117304,%eax
80108197:	83 e0 e0             	and    $0xffffffe0,%eax
8010819a:	a2 04 73 11 80       	mov    %al,0x80117304
8010819f:	0f b6 05 04 73 11 80 	movzbl 0x80117304,%eax
801081a6:	83 e0 1f             	and    $0x1f,%eax
801081a9:	a2 04 73 11 80       	mov    %al,0x80117304
801081ae:	0f b6 05 05 73 11 80 	movzbl 0x80117305,%eax
801081b5:	83 c8 0f             	or     $0xf,%eax
801081b8:	a2 05 73 11 80       	mov    %al,0x80117305
801081bd:	0f b6 05 05 73 11 80 	movzbl 0x80117305,%eax
801081c4:	83 e0 ef             	and    $0xffffffef,%eax
801081c7:	a2 05 73 11 80       	mov    %al,0x80117305
801081cc:	0f b6 05 05 73 11 80 	movzbl 0x80117305,%eax
801081d3:	83 c8 60             	or     $0x60,%eax
801081d6:	a2 05 73 11 80       	mov    %al,0x80117305
801081db:	0f b6 05 05 73 11 80 	movzbl 0x80117305,%eax
801081e2:	83 c8 80             	or     $0xffffff80,%eax
801081e5:	a2 05 73 11 80       	mov    %al,0x80117305
801081ea:	a1 b4 d1 10 80       	mov    0x8010d1b4,%eax
801081ef:	c1 e8 10             	shr    $0x10,%eax
801081f2:	66 a3 06 73 11 80    	mov    %ax,0x80117306
  
}
801081f8:	90                   	nop
801081f9:	c9                   	leave  
801081fa:	c3                   	ret    

801081fb <idtinit>:

void
idtinit(void)
{
801081fb:	55                   	push   %ebp
801081fc:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801081fe:	68 00 08 00 00       	push   $0x800
80108203:	68 00 71 11 80       	push   $0x80117100
80108208:	e8 52 fe ff ff       	call   8010805f <lidt>
8010820d:	83 c4 08             	add    $0x8,%esp
}
80108210:	90                   	nop
80108211:	c9                   	leave  
80108212:	c3                   	ret    

80108213 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80108213:	55                   	push   %ebp
80108214:	89 e5                	mov    %esp,%ebp
80108216:	57                   	push   %edi
80108217:	56                   	push   %esi
80108218:	53                   	push   %ebx
80108219:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
8010821c:	8b 45 08             	mov    0x8(%ebp),%eax
8010821f:	8b 40 30             	mov    0x30(%eax),%eax
80108222:	83 f8 40             	cmp    $0x40,%eax
80108225:	75 3e                	jne    80108265 <trap+0x52>
    if(proc->killed)
80108227:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010822d:	8b 40 24             	mov    0x24(%eax),%eax
80108230:	85 c0                	test   %eax,%eax
80108232:	74 05                	je     80108239 <trap+0x26>
      exit();
80108234:	e8 7d ca ff ff       	call   80104cb6 <exit>
    proc->tf = tf;
80108239:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010823f:	8b 55 08             	mov    0x8(%ebp),%edx
80108242:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80108245:	e8 57 ec ff ff       	call   80106ea1 <syscall>
    if(proc->killed)
8010824a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108250:	8b 40 24             	mov    0x24(%eax),%eax
80108253:	85 c0                	test   %eax,%eax
80108255:	0f 84 21 02 00 00    	je     8010847c <trap+0x269>
      exit();
8010825b:	e8 56 ca ff ff       	call   80104cb6 <exit>
    return;
80108260:	e9 17 02 00 00       	jmp    8010847c <trap+0x269>
  }

  switch(tf->trapno){
80108265:	8b 45 08             	mov    0x8(%ebp),%eax
80108268:	8b 40 30             	mov    0x30(%eax),%eax
8010826b:	83 e8 20             	sub    $0x20,%eax
8010826e:	83 f8 1f             	cmp    $0x1f,%eax
80108271:	0f 87 a3 00 00 00    	ja     8010831a <trap+0x107>
80108277:	8b 04 85 58 a8 10 80 	mov    -0x7fef57a8(,%eax,4),%eax
8010827e:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
   if(cpu->id == 0){
80108280:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108286:	0f b6 00             	movzbl (%eax),%eax
80108289:	84 c0                	test   %al,%al
8010828b:	75 20                	jne    801082ad <trap+0x9a>
      atom_inc((int *)&ticks);   // guaranteed atomic so no lock necessary
8010828d:	83 ec 0c             	sub    $0xc,%esp
80108290:	68 00 79 11 80       	push   $0x80117900
80108295:	e8 b9 fd ff ff       	call   80108053 <atom_inc>
8010829a:	83 c4 10             	add    $0x10,%esp
      wakeup(&ticks);
8010829d:	83 ec 0c             	sub    $0xc,%esp
801082a0:	68 00 79 11 80       	push   $0x80117900
801082a5:	e8 61 d5 ff ff       	call   8010580b <wakeup>
801082aa:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801082ad:	e8 11 ae ff ff       	call   801030c3 <lapiceoi>
    break;
801082b2:	e9 1c 01 00 00       	jmp    801083d3 <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801082b7:	e8 1a a6 ff ff       	call   801028d6 <ideintr>
    lapiceoi();
801082bc:	e8 02 ae ff ff       	call   801030c3 <lapiceoi>
    break;
801082c1:	e9 0d 01 00 00       	jmp    801083d3 <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801082c6:	e8 fa ab ff ff       	call   80102ec5 <kbdintr>
    lapiceoi();
801082cb:	e8 f3 ad ff ff       	call   801030c3 <lapiceoi>
    break;
801082d0:	e9 fe 00 00 00       	jmp    801083d3 <trap+0x1c0>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801082d5:	e8 83 03 00 00       	call   8010865d <uartintr>
    lapiceoi();
801082da:	e8 e4 ad ff ff       	call   801030c3 <lapiceoi>
    break;
801082df:	e9 ef 00 00 00       	jmp    801083d3 <trap+0x1c0>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801082e4:	8b 45 08             	mov    0x8(%ebp),%eax
801082e7:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801082ea:	8b 45 08             	mov    0x8(%ebp),%eax
801082ed:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801082f1:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
801082f4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801082fa:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801082fd:	0f b6 c0             	movzbl %al,%eax
80108300:	51                   	push   %ecx
80108301:	52                   	push   %edx
80108302:	50                   	push   %eax
80108303:	68 b8 a7 10 80       	push   $0x8010a7b8
80108308:	e8 b9 80 ff ff       	call   801003c6 <cprintf>
8010830d:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80108310:	e8 ae ad ff ff       	call   801030c3 <lapiceoi>
    break;
80108315:	e9 b9 00 00 00       	jmp    801083d3 <trap+0x1c0>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
8010831a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108320:	85 c0                	test   %eax,%eax
80108322:	74 11                	je     80108335 <trap+0x122>
80108324:	8b 45 08             	mov    0x8(%ebp),%eax
80108327:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010832b:	0f b7 c0             	movzwl %ax,%eax
8010832e:	83 e0 03             	and    $0x3,%eax
80108331:	85 c0                	test   %eax,%eax
80108333:	75 40                	jne    80108375 <trap+0x162>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80108335:	e8 4f fd ff ff       	call   80108089 <rcr2>
8010833a:	89 c3                	mov    %eax,%ebx
8010833c:	8b 45 08             	mov    0x8(%ebp),%eax
8010833f:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80108342:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108348:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010834b:	0f b6 d0             	movzbl %al,%edx
8010834e:	8b 45 08             	mov    0x8(%ebp),%eax
80108351:	8b 40 30             	mov    0x30(%eax),%eax
80108354:	83 ec 0c             	sub    $0xc,%esp
80108357:	53                   	push   %ebx
80108358:	51                   	push   %ecx
80108359:	52                   	push   %edx
8010835a:	50                   	push   %eax
8010835b:	68 dc a7 10 80       	push   $0x8010a7dc
80108360:	e8 61 80 ff ff       	call   801003c6 <cprintf>
80108365:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80108368:	83 ec 0c             	sub    $0xc,%esp
8010836b:	68 0e a8 10 80       	push   $0x8010a80e
80108370:	e8 f1 81 ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80108375:	e8 0f fd ff ff       	call   80108089 <rcr2>
8010837a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010837d:	8b 45 08             	mov    0x8(%ebp),%eax
80108380:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80108383:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108389:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010838c:	0f b6 d8             	movzbl %al,%ebx
8010838f:	8b 45 08             	mov    0x8(%ebp),%eax
80108392:	8b 48 34             	mov    0x34(%eax),%ecx
80108395:	8b 45 08             	mov    0x8(%ebp),%eax
80108398:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010839b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801083a1:	8d 78 6c             	lea    0x6c(%eax),%edi
801083a4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801083aa:	8b 40 10             	mov    0x10(%eax),%eax
801083ad:	ff 75 e4             	pushl  -0x1c(%ebp)
801083b0:	56                   	push   %esi
801083b1:	53                   	push   %ebx
801083b2:	51                   	push   %ecx
801083b3:	52                   	push   %edx
801083b4:	57                   	push   %edi
801083b5:	50                   	push   %eax
801083b6:	68 14 a8 10 80       	push   $0x8010a814
801083bb:	e8 06 80 ff ff       	call   801003c6 <cprintf>
801083c0:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
801083c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801083c9:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801083d0:	eb 01                	jmp    801083d3 <trap+0x1c0>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801083d2:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801083d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801083d9:	85 c0                	test   %eax,%eax
801083db:	74 24                	je     80108401 <trap+0x1ee>
801083dd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801083e3:	8b 40 24             	mov    0x24(%eax),%eax
801083e6:	85 c0                	test   %eax,%eax
801083e8:	74 17                	je     80108401 <trap+0x1ee>
801083ea:	8b 45 08             	mov    0x8(%ebp),%eax
801083ed:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801083f1:	0f b7 c0             	movzwl %ax,%eax
801083f4:	83 e0 03             	and    $0x3,%eax
801083f7:	83 f8 03             	cmp    $0x3,%eax
801083fa:	75 05                	jne    80108401 <trap+0x1ee>
    exit();
801083fc:	e8 b5 c8 ff ff       	call   80104cb6 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
80108401:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108407:	85 c0                	test   %eax,%eax
80108409:	74 41                	je     8010844c <trap+0x239>
8010840b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108411:	8b 40 0c             	mov    0xc(%eax),%eax
80108414:	83 f8 04             	cmp    $0x4,%eax
80108417:	75 33                	jne    8010844c <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
80108419:	8b 45 08             	mov    0x8(%ebp),%eax
8010841c:	8b 40 30             	mov    0x30(%eax),%eax
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
8010841f:	83 f8 20             	cmp    $0x20,%eax
80108422:	75 28                	jne    8010844c <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
80108424:	8b 0d 00 79 11 80    	mov    0x80117900,%ecx
8010842a:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
8010842f:	89 c8                	mov    %ecx,%eax
80108431:	f7 e2                	mul    %edx
80108433:	c1 ea 03             	shr    $0x3,%edx
80108436:	89 d0                	mov    %edx,%eax
80108438:	c1 e0 02             	shl    $0x2,%eax
8010843b:	01 d0                	add    %edx,%eax
8010843d:	01 c0                	add    %eax,%eax
8010843f:	29 c1                	sub    %eax,%ecx
80108441:	89 ca                	mov    %ecx,%edx
80108443:	85 d2                	test   %edx,%edx
80108445:	75 05                	jne    8010844c <trap+0x239>
    yield();
80108447:	e8 b6 cf ff ff       	call   80105402 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010844c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108452:	85 c0                	test   %eax,%eax
80108454:	74 27                	je     8010847d <trap+0x26a>
80108456:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010845c:	8b 40 24             	mov    0x24(%eax),%eax
8010845f:	85 c0                	test   %eax,%eax
80108461:	74 1a                	je     8010847d <trap+0x26a>
80108463:	8b 45 08             	mov    0x8(%ebp),%eax
80108466:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010846a:	0f b7 c0             	movzwl %ax,%eax
8010846d:	83 e0 03             	and    $0x3,%eax
80108470:	83 f8 03             	cmp    $0x3,%eax
80108473:	75 08                	jne    8010847d <trap+0x26a>
    exit();
80108475:	e8 3c c8 ff ff       	call   80104cb6 <exit>
8010847a:	eb 01                	jmp    8010847d <trap+0x26a>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
8010847c:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
8010847d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108480:	5b                   	pop    %ebx
80108481:	5e                   	pop    %esi
80108482:	5f                   	pop    %edi
80108483:	5d                   	pop    %ebp
80108484:	c3                   	ret    

80108485 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80108485:	55                   	push   %ebp
80108486:	89 e5                	mov    %esp,%ebp
80108488:	83 ec 14             	sub    $0x14,%esp
8010848b:	8b 45 08             	mov    0x8(%ebp),%eax
8010848e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108492:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108496:	89 c2                	mov    %eax,%edx
80108498:	ec                   	in     (%dx),%al
80108499:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010849c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801084a0:	c9                   	leave  
801084a1:	c3                   	ret    

801084a2 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801084a2:	55                   	push   %ebp
801084a3:	89 e5                	mov    %esp,%ebp
801084a5:	83 ec 08             	sub    $0x8,%esp
801084a8:	8b 55 08             	mov    0x8(%ebp),%edx
801084ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801084ae:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801084b2:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801084b5:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801084b9:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801084bd:	ee                   	out    %al,(%dx)
}
801084be:	90                   	nop
801084bf:	c9                   	leave  
801084c0:	c3                   	ret    

801084c1 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801084c1:	55                   	push   %ebp
801084c2:	89 e5                	mov    %esp,%ebp
801084c4:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801084c7:	6a 00                	push   $0x0
801084c9:	68 fa 03 00 00       	push   $0x3fa
801084ce:	e8 cf ff ff ff       	call   801084a2 <outb>
801084d3:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801084d6:	68 80 00 00 00       	push   $0x80
801084db:	68 fb 03 00 00       	push   $0x3fb
801084e0:	e8 bd ff ff ff       	call   801084a2 <outb>
801084e5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801084e8:	6a 0c                	push   $0xc
801084ea:	68 f8 03 00 00       	push   $0x3f8
801084ef:	e8 ae ff ff ff       	call   801084a2 <outb>
801084f4:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801084f7:	6a 00                	push   $0x0
801084f9:	68 f9 03 00 00       	push   $0x3f9
801084fe:	e8 9f ff ff ff       	call   801084a2 <outb>
80108503:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80108506:	6a 03                	push   $0x3
80108508:	68 fb 03 00 00       	push   $0x3fb
8010850d:	e8 90 ff ff ff       	call   801084a2 <outb>
80108512:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80108515:	6a 00                	push   $0x0
80108517:	68 fc 03 00 00       	push   $0x3fc
8010851c:	e8 81 ff ff ff       	call   801084a2 <outb>
80108521:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80108524:	6a 01                	push   $0x1
80108526:	68 f9 03 00 00       	push   $0x3f9
8010852b:	e8 72 ff ff ff       	call   801084a2 <outb>
80108530:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80108533:	68 fd 03 00 00       	push   $0x3fd
80108538:	e8 48 ff ff ff       	call   80108485 <inb>
8010853d:	83 c4 04             	add    $0x4,%esp
80108540:	3c ff                	cmp    $0xff,%al
80108542:	74 6e                	je     801085b2 <uartinit+0xf1>
    return;
  uart = 1;
80108544:	c7 05 6c d6 10 80 01 	movl   $0x1,0x8010d66c
8010854b:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010854e:	68 fa 03 00 00       	push   $0x3fa
80108553:	e8 2d ff ff ff       	call   80108485 <inb>
80108558:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
8010855b:	68 f8 03 00 00       	push   $0x3f8
80108560:	e8 20 ff ff ff       	call   80108485 <inb>
80108565:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80108568:	83 ec 0c             	sub    $0xc,%esp
8010856b:	6a 04                	push   $0x4
8010856d:	e8 57 ba ff ff       	call   80103fc9 <picenable>
80108572:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80108575:	83 ec 08             	sub    $0x8,%esp
80108578:	6a 00                	push   $0x0
8010857a:	6a 04                	push   $0x4
8010857c:	e8 f7 a5 ff ff       	call   80102b78 <ioapicenable>
80108581:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80108584:	c7 45 f4 d8 a8 10 80 	movl   $0x8010a8d8,-0xc(%ebp)
8010858b:	eb 19                	jmp    801085a6 <uartinit+0xe5>
    uartputc(*p);
8010858d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108590:	0f b6 00             	movzbl (%eax),%eax
80108593:	0f be c0             	movsbl %al,%eax
80108596:	83 ec 0c             	sub    $0xc,%esp
80108599:	50                   	push   %eax
8010859a:	e8 16 00 00 00       	call   801085b5 <uartputc>
8010859f:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801085a2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801085a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a9:	0f b6 00             	movzbl (%eax),%eax
801085ac:	84 c0                	test   %al,%al
801085ae:	75 dd                	jne    8010858d <uartinit+0xcc>
801085b0:	eb 01                	jmp    801085b3 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
801085b2:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
801085b3:	c9                   	leave  
801085b4:	c3                   	ret    

801085b5 <uartputc>:

void
uartputc(int c)
{
801085b5:	55                   	push   %ebp
801085b6:	89 e5                	mov    %esp,%ebp
801085b8:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801085bb:	a1 6c d6 10 80       	mov    0x8010d66c,%eax
801085c0:	85 c0                	test   %eax,%eax
801085c2:	74 53                	je     80108617 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801085c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801085cb:	eb 11                	jmp    801085de <uartputc+0x29>
    microdelay(10);
801085cd:	83 ec 0c             	sub    $0xc,%esp
801085d0:	6a 0a                	push   $0xa
801085d2:	e8 07 ab ff ff       	call   801030de <microdelay>
801085d7:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801085da:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801085de:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801085e2:	7f 1a                	jg     801085fe <uartputc+0x49>
801085e4:	83 ec 0c             	sub    $0xc,%esp
801085e7:	68 fd 03 00 00       	push   $0x3fd
801085ec:	e8 94 fe ff ff       	call   80108485 <inb>
801085f1:	83 c4 10             	add    $0x10,%esp
801085f4:	0f b6 c0             	movzbl %al,%eax
801085f7:	83 e0 20             	and    $0x20,%eax
801085fa:	85 c0                	test   %eax,%eax
801085fc:	74 cf                	je     801085cd <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
801085fe:	8b 45 08             	mov    0x8(%ebp),%eax
80108601:	0f b6 c0             	movzbl %al,%eax
80108604:	83 ec 08             	sub    $0x8,%esp
80108607:	50                   	push   %eax
80108608:	68 f8 03 00 00       	push   $0x3f8
8010860d:	e8 90 fe ff ff       	call   801084a2 <outb>
80108612:	83 c4 10             	add    $0x10,%esp
80108615:	eb 01                	jmp    80108618 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80108617:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80108618:	c9                   	leave  
80108619:	c3                   	ret    

8010861a <uartgetc>:

static int
uartgetc(void)
{
8010861a:	55                   	push   %ebp
8010861b:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010861d:	a1 6c d6 10 80       	mov    0x8010d66c,%eax
80108622:	85 c0                	test   %eax,%eax
80108624:	75 07                	jne    8010862d <uartgetc+0x13>
    return -1;
80108626:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010862b:	eb 2e                	jmp    8010865b <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
8010862d:	68 fd 03 00 00       	push   $0x3fd
80108632:	e8 4e fe ff ff       	call   80108485 <inb>
80108637:	83 c4 04             	add    $0x4,%esp
8010863a:	0f b6 c0             	movzbl %al,%eax
8010863d:	83 e0 01             	and    $0x1,%eax
80108640:	85 c0                	test   %eax,%eax
80108642:	75 07                	jne    8010864b <uartgetc+0x31>
    return -1;
80108644:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108649:	eb 10                	jmp    8010865b <uartgetc+0x41>
  return inb(COM1+0);
8010864b:	68 f8 03 00 00       	push   $0x3f8
80108650:	e8 30 fe ff ff       	call   80108485 <inb>
80108655:	83 c4 04             	add    $0x4,%esp
80108658:	0f b6 c0             	movzbl %al,%eax
}
8010865b:	c9                   	leave  
8010865c:	c3                   	ret    

8010865d <uartintr>:

void
uartintr(void)
{
8010865d:	55                   	push   %ebp
8010865e:	89 e5                	mov    %esp,%ebp
80108660:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80108663:	83 ec 0c             	sub    $0xc,%esp
80108666:	68 1a 86 10 80       	push   $0x8010861a
8010866b:	e8 89 81 ff ff       	call   801007f9 <consoleintr>
80108670:	83 c4 10             	add    $0x10,%esp
}
80108673:	90                   	nop
80108674:	c9                   	leave  
80108675:	c3                   	ret    

80108676 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80108676:	6a 00                	push   $0x0
  pushl $0
80108678:	6a 00                	push   $0x0
  jmp alltraps
8010867a:	e9 a9 f9 ff ff       	jmp    80108028 <alltraps>

8010867f <vector1>:
.globl vector1
vector1:
  pushl $0
8010867f:	6a 00                	push   $0x0
  pushl $1
80108681:	6a 01                	push   $0x1
  jmp alltraps
80108683:	e9 a0 f9 ff ff       	jmp    80108028 <alltraps>

80108688 <vector2>:
.globl vector2
vector2:
  pushl $0
80108688:	6a 00                	push   $0x0
  pushl $2
8010868a:	6a 02                	push   $0x2
  jmp alltraps
8010868c:	e9 97 f9 ff ff       	jmp    80108028 <alltraps>

80108691 <vector3>:
.globl vector3
vector3:
  pushl $0
80108691:	6a 00                	push   $0x0
  pushl $3
80108693:	6a 03                	push   $0x3
  jmp alltraps
80108695:	e9 8e f9 ff ff       	jmp    80108028 <alltraps>

8010869a <vector4>:
.globl vector4
vector4:
  pushl $0
8010869a:	6a 00                	push   $0x0
  pushl $4
8010869c:	6a 04                	push   $0x4
  jmp alltraps
8010869e:	e9 85 f9 ff ff       	jmp    80108028 <alltraps>

801086a3 <vector5>:
.globl vector5
vector5:
  pushl $0
801086a3:	6a 00                	push   $0x0
  pushl $5
801086a5:	6a 05                	push   $0x5
  jmp alltraps
801086a7:	e9 7c f9 ff ff       	jmp    80108028 <alltraps>

801086ac <vector6>:
.globl vector6
vector6:
  pushl $0
801086ac:	6a 00                	push   $0x0
  pushl $6
801086ae:	6a 06                	push   $0x6
  jmp alltraps
801086b0:	e9 73 f9 ff ff       	jmp    80108028 <alltraps>

801086b5 <vector7>:
.globl vector7
vector7:
  pushl $0
801086b5:	6a 00                	push   $0x0
  pushl $7
801086b7:	6a 07                	push   $0x7
  jmp alltraps
801086b9:	e9 6a f9 ff ff       	jmp    80108028 <alltraps>

801086be <vector8>:
.globl vector8
vector8:
  pushl $8
801086be:	6a 08                	push   $0x8
  jmp alltraps
801086c0:	e9 63 f9 ff ff       	jmp    80108028 <alltraps>

801086c5 <vector9>:
.globl vector9
vector9:
  pushl $0
801086c5:	6a 00                	push   $0x0
  pushl $9
801086c7:	6a 09                	push   $0x9
  jmp alltraps
801086c9:	e9 5a f9 ff ff       	jmp    80108028 <alltraps>

801086ce <vector10>:
.globl vector10
vector10:
  pushl $10
801086ce:	6a 0a                	push   $0xa
  jmp alltraps
801086d0:	e9 53 f9 ff ff       	jmp    80108028 <alltraps>

801086d5 <vector11>:
.globl vector11
vector11:
  pushl $11
801086d5:	6a 0b                	push   $0xb
  jmp alltraps
801086d7:	e9 4c f9 ff ff       	jmp    80108028 <alltraps>

801086dc <vector12>:
.globl vector12
vector12:
  pushl $12
801086dc:	6a 0c                	push   $0xc
  jmp alltraps
801086de:	e9 45 f9 ff ff       	jmp    80108028 <alltraps>

801086e3 <vector13>:
.globl vector13
vector13:
  pushl $13
801086e3:	6a 0d                	push   $0xd
  jmp alltraps
801086e5:	e9 3e f9 ff ff       	jmp    80108028 <alltraps>

801086ea <vector14>:
.globl vector14
vector14:
  pushl $14
801086ea:	6a 0e                	push   $0xe
  jmp alltraps
801086ec:	e9 37 f9 ff ff       	jmp    80108028 <alltraps>

801086f1 <vector15>:
.globl vector15
vector15:
  pushl $0
801086f1:	6a 00                	push   $0x0
  pushl $15
801086f3:	6a 0f                	push   $0xf
  jmp alltraps
801086f5:	e9 2e f9 ff ff       	jmp    80108028 <alltraps>

801086fa <vector16>:
.globl vector16
vector16:
  pushl $0
801086fa:	6a 00                	push   $0x0
  pushl $16
801086fc:	6a 10                	push   $0x10
  jmp alltraps
801086fe:	e9 25 f9 ff ff       	jmp    80108028 <alltraps>

80108703 <vector17>:
.globl vector17
vector17:
  pushl $17
80108703:	6a 11                	push   $0x11
  jmp alltraps
80108705:	e9 1e f9 ff ff       	jmp    80108028 <alltraps>

8010870a <vector18>:
.globl vector18
vector18:
  pushl $0
8010870a:	6a 00                	push   $0x0
  pushl $18
8010870c:	6a 12                	push   $0x12
  jmp alltraps
8010870e:	e9 15 f9 ff ff       	jmp    80108028 <alltraps>

80108713 <vector19>:
.globl vector19
vector19:
  pushl $0
80108713:	6a 00                	push   $0x0
  pushl $19
80108715:	6a 13                	push   $0x13
  jmp alltraps
80108717:	e9 0c f9 ff ff       	jmp    80108028 <alltraps>

8010871c <vector20>:
.globl vector20
vector20:
  pushl $0
8010871c:	6a 00                	push   $0x0
  pushl $20
8010871e:	6a 14                	push   $0x14
  jmp alltraps
80108720:	e9 03 f9 ff ff       	jmp    80108028 <alltraps>

80108725 <vector21>:
.globl vector21
vector21:
  pushl $0
80108725:	6a 00                	push   $0x0
  pushl $21
80108727:	6a 15                	push   $0x15
  jmp alltraps
80108729:	e9 fa f8 ff ff       	jmp    80108028 <alltraps>

8010872e <vector22>:
.globl vector22
vector22:
  pushl $0
8010872e:	6a 00                	push   $0x0
  pushl $22
80108730:	6a 16                	push   $0x16
  jmp alltraps
80108732:	e9 f1 f8 ff ff       	jmp    80108028 <alltraps>

80108737 <vector23>:
.globl vector23
vector23:
  pushl $0
80108737:	6a 00                	push   $0x0
  pushl $23
80108739:	6a 17                	push   $0x17
  jmp alltraps
8010873b:	e9 e8 f8 ff ff       	jmp    80108028 <alltraps>

80108740 <vector24>:
.globl vector24
vector24:
  pushl $0
80108740:	6a 00                	push   $0x0
  pushl $24
80108742:	6a 18                	push   $0x18
  jmp alltraps
80108744:	e9 df f8 ff ff       	jmp    80108028 <alltraps>

80108749 <vector25>:
.globl vector25
vector25:
  pushl $0
80108749:	6a 00                	push   $0x0
  pushl $25
8010874b:	6a 19                	push   $0x19
  jmp alltraps
8010874d:	e9 d6 f8 ff ff       	jmp    80108028 <alltraps>

80108752 <vector26>:
.globl vector26
vector26:
  pushl $0
80108752:	6a 00                	push   $0x0
  pushl $26
80108754:	6a 1a                	push   $0x1a
  jmp alltraps
80108756:	e9 cd f8 ff ff       	jmp    80108028 <alltraps>

8010875b <vector27>:
.globl vector27
vector27:
  pushl $0
8010875b:	6a 00                	push   $0x0
  pushl $27
8010875d:	6a 1b                	push   $0x1b
  jmp alltraps
8010875f:	e9 c4 f8 ff ff       	jmp    80108028 <alltraps>

80108764 <vector28>:
.globl vector28
vector28:
  pushl $0
80108764:	6a 00                	push   $0x0
  pushl $28
80108766:	6a 1c                	push   $0x1c
  jmp alltraps
80108768:	e9 bb f8 ff ff       	jmp    80108028 <alltraps>

8010876d <vector29>:
.globl vector29
vector29:
  pushl $0
8010876d:	6a 00                	push   $0x0
  pushl $29
8010876f:	6a 1d                	push   $0x1d
  jmp alltraps
80108771:	e9 b2 f8 ff ff       	jmp    80108028 <alltraps>

80108776 <vector30>:
.globl vector30
vector30:
  pushl $0
80108776:	6a 00                	push   $0x0
  pushl $30
80108778:	6a 1e                	push   $0x1e
  jmp alltraps
8010877a:	e9 a9 f8 ff ff       	jmp    80108028 <alltraps>

8010877f <vector31>:
.globl vector31
vector31:
  pushl $0
8010877f:	6a 00                	push   $0x0
  pushl $31
80108781:	6a 1f                	push   $0x1f
  jmp alltraps
80108783:	e9 a0 f8 ff ff       	jmp    80108028 <alltraps>

80108788 <vector32>:
.globl vector32
vector32:
  pushl $0
80108788:	6a 00                	push   $0x0
  pushl $32
8010878a:	6a 20                	push   $0x20
  jmp alltraps
8010878c:	e9 97 f8 ff ff       	jmp    80108028 <alltraps>

80108791 <vector33>:
.globl vector33
vector33:
  pushl $0
80108791:	6a 00                	push   $0x0
  pushl $33
80108793:	6a 21                	push   $0x21
  jmp alltraps
80108795:	e9 8e f8 ff ff       	jmp    80108028 <alltraps>

8010879a <vector34>:
.globl vector34
vector34:
  pushl $0
8010879a:	6a 00                	push   $0x0
  pushl $34
8010879c:	6a 22                	push   $0x22
  jmp alltraps
8010879e:	e9 85 f8 ff ff       	jmp    80108028 <alltraps>

801087a3 <vector35>:
.globl vector35
vector35:
  pushl $0
801087a3:	6a 00                	push   $0x0
  pushl $35
801087a5:	6a 23                	push   $0x23
  jmp alltraps
801087a7:	e9 7c f8 ff ff       	jmp    80108028 <alltraps>

801087ac <vector36>:
.globl vector36
vector36:
  pushl $0
801087ac:	6a 00                	push   $0x0
  pushl $36
801087ae:	6a 24                	push   $0x24
  jmp alltraps
801087b0:	e9 73 f8 ff ff       	jmp    80108028 <alltraps>

801087b5 <vector37>:
.globl vector37
vector37:
  pushl $0
801087b5:	6a 00                	push   $0x0
  pushl $37
801087b7:	6a 25                	push   $0x25
  jmp alltraps
801087b9:	e9 6a f8 ff ff       	jmp    80108028 <alltraps>

801087be <vector38>:
.globl vector38
vector38:
  pushl $0
801087be:	6a 00                	push   $0x0
  pushl $38
801087c0:	6a 26                	push   $0x26
  jmp alltraps
801087c2:	e9 61 f8 ff ff       	jmp    80108028 <alltraps>

801087c7 <vector39>:
.globl vector39
vector39:
  pushl $0
801087c7:	6a 00                	push   $0x0
  pushl $39
801087c9:	6a 27                	push   $0x27
  jmp alltraps
801087cb:	e9 58 f8 ff ff       	jmp    80108028 <alltraps>

801087d0 <vector40>:
.globl vector40
vector40:
  pushl $0
801087d0:	6a 00                	push   $0x0
  pushl $40
801087d2:	6a 28                	push   $0x28
  jmp alltraps
801087d4:	e9 4f f8 ff ff       	jmp    80108028 <alltraps>

801087d9 <vector41>:
.globl vector41
vector41:
  pushl $0
801087d9:	6a 00                	push   $0x0
  pushl $41
801087db:	6a 29                	push   $0x29
  jmp alltraps
801087dd:	e9 46 f8 ff ff       	jmp    80108028 <alltraps>

801087e2 <vector42>:
.globl vector42
vector42:
  pushl $0
801087e2:	6a 00                	push   $0x0
  pushl $42
801087e4:	6a 2a                	push   $0x2a
  jmp alltraps
801087e6:	e9 3d f8 ff ff       	jmp    80108028 <alltraps>

801087eb <vector43>:
.globl vector43
vector43:
  pushl $0
801087eb:	6a 00                	push   $0x0
  pushl $43
801087ed:	6a 2b                	push   $0x2b
  jmp alltraps
801087ef:	e9 34 f8 ff ff       	jmp    80108028 <alltraps>

801087f4 <vector44>:
.globl vector44
vector44:
  pushl $0
801087f4:	6a 00                	push   $0x0
  pushl $44
801087f6:	6a 2c                	push   $0x2c
  jmp alltraps
801087f8:	e9 2b f8 ff ff       	jmp    80108028 <alltraps>

801087fd <vector45>:
.globl vector45
vector45:
  pushl $0
801087fd:	6a 00                	push   $0x0
  pushl $45
801087ff:	6a 2d                	push   $0x2d
  jmp alltraps
80108801:	e9 22 f8 ff ff       	jmp    80108028 <alltraps>

80108806 <vector46>:
.globl vector46
vector46:
  pushl $0
80108806:	6a 00                	push   $0x0
  pushl $46
80108808:	6a 2e                	push   $0x2e
  jmp alltraps
8010880a:	e9 19 f8 ff ff       	jmp    80108028 <alltraps>

8010880f <vector47>:
.globl vector47
vector47:
  pushl $0
8010880f:	6a 00                	push   $0x0
  pushl $47
80108811:	6a 2f                	push   $0x2f
  jmp alltraps
80108813:	e9 10 f8 ff ff       	jmp    80108028 <alltraps>

80108818 <vector48>:
.globl vector48
vector48:
  pushl $0
80108818:	6a 00                	push   $0x0
  pushl $48
8010881a:	6a 30                	push   $0x30
  jmp alltraps
8010881c:	e9 07 f8 ff ff       	jmp    80108028 <alltraps>

80108821 <vector49>:
.globl vector49
vector49:
  pushl $0
80108821:	6a 00                	push   $0x0
  pushl $49
80108823:	6a 31                	push   $0x31
  jmp alltraps
80108825:	e9 fe f7 ff ff       	jmp    80108028 <alltraps>

8010882a <vector50>:
.globl vector50
vector50:
  pushl $0
8010882a:	6a 00                	push   $0x0
  pushl $50
8010882c:	6a 32                	push   $0x32
  jmp alltraps
8010882e:	e9 f5 f7 ff ff       	jmp    80108028 <alltraps>

80108833 <vector51>:
.globl vector51
vector51:
  pushl $0
80108833:	6a 00                	push   $0x0
  pushl $51
80108835:	6a 33                	push   $0x33
  jmp alltraps
80108837:	e9 ec f7 ff ff       	jmp    80108028 <alltraps>

8010883c <vector52>:
.globl vector52
vector52:
  pushl $0
8010883c:	6a 00                	push   $0x0
  pushl $52
8010883e:	6a 34                	push   $0x34
  jmp alltraps
80108840:	e9 e3 f7 ff ff       	jmp    80108028 <alltraps>

80108845 <vector53>:
.globl vector53
vector53:
  pushl $0
80108845:	6a 00                	push   $0x0
  pushl $53
80108847:	6a 35                	push   $0x35
  jmp alltraps
80108849:	e9 da f7 ff ff       	jmp    80108028 <alltraps>

8010884e <vector54>:
.globl vector54
vector54:
  pushl $0
8010884e:	6a 00                	push   $0x0
  pushl $54
80108850:	6a 36                	push   $0x36
  jmp alltraps
80108852:	e9 d1 f7 ff ff       	jmp    80108028 <alltraps>

80108857 <vector55>:
.globl vector55
vector55:
  pushl $0
80108857:	6a 00                	push   $0x0
  pushl $55
80108859:	6a 37                	push   $0x37
  jmp alltraps
8010885b:	e9 c8 f7 ff ff       	jmp    80108028 <alltraps>

80108860 <vector56>:
.globl vector56
vector56:
  pushl $0
80108860:	6a 00                	push   $0x0
  pushl $56
80108862:	6a 38                	push   $0x38
  jmp alltraps
80108864:	e9 bf f7 ff ff       	jmp    80108028 <alltraps>

80108869 <vector57>:
.globl vector57
vector57:
  pushl $0
80108869:	6a 00                	push   $0x0
  pushl $57
8010886b:	6a 39                	push   $0x39
  jmp alltraps
8010886d:	e9 b6 f7 ff ff       	jmp    80108028 <alltraps>

80108872 <vector58>:
.globl vector58
vector58:
  pushl $0
80108872:	6a 00                	push   $0x0
  pushl $58
80108874:	6a 3a                	push   $0x3a
  jmp alltraps
80108876:	e9 ad f7 ff ff       	jmp    80108028 <alltraps>

8010887b <vector59>:
.globl vector59
vector59:
  pushl $0
8010887b:	6a 00                	push   $0x0
  pushl $59
8010887d:	6a 3b                	push   $0x3b
  jmp alltraps
8010887f:	e9 a4 f7 ff ff       	jmp    80108028 <alltraps>

80108884 <vector60>:
.globl vector60
vector60:
  pushl $0
80108884:	6a 00                	push   $0x0
  pushl $60
80108886:	6a 3c                	push   $0x3c
  jmp alltraps
80108888:	e9 9b f7 ff ff       	jmp    80108028 <alltraps>

8010888d <vector61>:
.globl vector61
vector61:
  pushl $0
8010888d:	6a 00                	push   $0x0
  pushl $61
8010888f:	6a 3d                	push   $0x3d
  jmp alltraps
80108891:	e9 92 f7 ff ff       	jmp    80108028 <alltraps>

80108896 <vector62>:
.globl vector62
vector62:
  pushl $0
80108896:	6a 00                	push   $0x0
  pushl $62
80108898:	6a 3e                	push   $0x3e
  jmp alltraps
8010889a:	e9 89 f7 ff ff       	jmp    80108028 <alltraps>

8010889f <vector63>:
.globl vector63
vector63:
  pushl $0
8010889f:	6a 00                	push   $0x0
  pushl $63
801088a1:	6a 3f                	push   $0x3f
  jmp alltraps
801088a3:	e9 80 f7 ff ff       	jmp    80108028 <alltraps>

801088a8 <vector64>:
.globl vector64
vector64:
  pushl $0
801088a8:	6a 00                	push   $0x0
  pushl $64
801088aa:	6a 40                	push   $0x40
  jmp alltraps
801088ac:	e9 77 f7 ff ff       	jmp    80108028 <alltraps>

801088b1 <vector65>:
.globl vector65
vector65:
  pushl $0
801088b1:	6a 00                	push   $0x0
  pushl $65
801088b3:	6a 41                	push   $0x41
  jmp alltraps
801088b5:	e9 6e f7 ff ff       	jmp    80108028 <alltraps>

801088ba <vector66>:
.globl vector66
vector66:
  pushl $0
801088ba:	6a 00                	push   $0x0
  pushl $66
801088bc:	6a 42                	push   $0x42
  jmp alltraps
801088be:	e9 65 f7 ff ff       	jmp    80108028 <alltraps>

801088c3 <vector67>:
.globl vector67
vector67:
  pushl $0
801088c3:	6a 00                	push   $0x0
  pushl $67
801088c5:	6a 43                	push   $0x43
  jmp alltraps
801088c7:	e9 5c f7 ff ff       	jmp    80108028 <alltraps>

801088cc <vector68>:
.globl vector68
vector68:
  pushl $0
801088cc:	6a 00                	push   $0x0
  pushl $68
801088ce:	6a 44                	push   $0x44
  jmp alltraps
801088d0:	e9 53 f7 ff ff       	jmp    80108028 <alltraps>

801088d5 <vector69>:
.globl vector69
vector69:
  pushl $0
801088d5:	6a 00                	push   $0x0
  pushl $69
801088d7:	6a 45                	push   $0x45
  jmp alltraps
801088d9:	e9 4a f7 ff ff       	jmp    80108028 <alltraps>

801088de <vector70>:
.globl vector70
vector70:
  pushl $0
801088de:	6a 00                	push   $0x0
  pushl $70
801088e0:	6a 46                	push   $0x46
  jmp alltraps
801088e2:	e9 41 f7 ff ff       	jmp    80108028 <alltraps>

801088e7 <vector71>:
.globl vector71
vector71:
  pushl $0
801088e7:	6a 00                	push   $0x0
  pushl $71
801088e9:	6a 47                	push   $0x47
  jmp alltraps
801088eb:	e9 38 f7 ff ff       	jmp    80108028 <alltraps>

801088f0 <vector72>:
.globl vector72
vector72:
  pushl $0
801088f0:	6a 00                	push   $0x0
  pushl $72
801088f2:	6a 48                	push   $0x48
  jmp alltraps
801088f4:	e9 2f f7 ff ff       	jmp    80108028 <alltraps>

801088f9 <vector73>:
.globl vector73
vector73:
  pushl $0
801088f9:	6a 00                	push   $0x0
  pushl $73
801088fb:	6a 49                	push   $0x49
  jmp alltraps
801088fd:	e9 26 f7 ff ff       	jmp    80108028 <alltraps>

80108902 <vector74>:
.globl vector74
vector74:
  pushl $0
80108902:	6a 00                	push   $0x0
  pushl $74
80108904:	6a 4a                	push   $0x4a
  jmp alltraps
80108906:	e9 1d f7 ff ff       	jmp    80108028 <alltraps>

8010890b <vector75>:
.globl vector75
vector75:
  pushl $0
8010890b:	6a 00                	push   $0x0
  pushl $75
8010890d:	6a 4b                	push   $0x4b
  jmp alltraps
8010890f:	e9 14 f7 ff ff       	jmp    80108028 <alltraps>

80108914 <vector76>:
.globl vector76
vector76:
  pushl $0
80108914:	6a 00                	push   $0x0
  pushl $76
80108916:	6a 4c                	push   $0x4c
  jmp alltraps
80108918:	e9 0b f7 ff ff       	jmp    80108028 <alltraps>

8010891d <vector77>:
.globl vector77
vector77:
  pushl $0
8010891d:	6a 00                	push   $0x0
  pushl $77
8010891f:	6a 4d                	push   $0x4d
  jmp alltraps
80108921:	e9 02 f7 ff ff       	jmp    80108028 <alltraps>

80108926 <vector78>:
.globl vector78
vector78:
  pushl $0
80108926:	6a 00                	push   $0x0
  pushl $78
80108928:	6a 4e                	push   $0x4e
  jmp alltraps
8010892a:	e9 f9 f6 ff ff       	jmp    80108028 <alltraps>

8010892f <vector79>:
.globl vector79
vector79:
  pushl $0
8010892f:	6a 00                	push   $0x0
  pushl $79
80108931:	6a 4f                	push   $0x4f
  jmp alltraps
80108933:	e9 f0 f6 ff ff       	jmp    80108028 <alltraps>

80108938 <vector80>:
.globl vector80
vector80:
  pushl $0
80108938:	6a 00                	push   $0x0
  pushl $80
8010893a:	6a 50                	push   $0x50
  jmp alltraps
8010893c:	e9 e7 f6 ff ff       	jmp    80108028 <alltraps>

80108941 <vector81>:
.globl vector81
vector81:
  pushl $0
80108941:	6a 00                	push   $0x0
  pushl $81
80108943:	6a 51                	push   $0x51
  jmp alltraps
80108945:	e9 de f6 ff ff       	jmp    80108028 <alltraps>

8010894a <vector82>:
.globl vector82
vector82:
  pushl $0
8010894a:	6a 00                	push   $0x0
  pushl $82
8010894c:	6a 52                	push   $0x52
  jmp alltraps
8010894e:	e9 d5 f6 ff ff       	jmp    80108028 <alltraps>

80108953 <vector83>:
.globl vector83
vector83:
  pushl $0
80108953:	6a 00                	push   $0x0
  pushl $83
80108955:	6a 53                	push   $0x53
  jmp alltraps
80108957:	e9 cc f6 ff ff       	jmp    80108028 <alltraps>

8010895c <vector84>:
.globl vector84
vector84:
  pushl $0
8010895c:	6a 00                	push   $0x0
  pushl $84
8010895e:	6a 54                	push   $0x54
  jmp alltraps
80108960:	e9 c3 f6 ff ff       	jmp    80108028 <alltraps>

80108965 <vector85>:
.globl vector85
vector85:
  pushl $0
80108965:	6a 00                	push   $0x0
  pushl $85
80108967:	6a 55                	push   $0x55
  jmp alltraps
80108969:	e9 ba f6 ff ff       	jmp    80108028 <alltraps>

8010896e <vector86>:
.globl vector86
vector86:
  pushl $0
8010896e:	6a 00                	push   $0x0
  pushl $86
80108970:	6a 56                	push   $0x56
  jmp alltraps
80108972:	e9 b1 f6 ff ff       	jmp    80108028 <alltraps>

80108977 <vector87>:
.globl vector87
vector87:
  pushl $0
80108977:	6a 00                	push   $0x0
  pushl $87
80108979:	6a 57                	push   $0x57
  jmp alltraps
8010897b:	e9 a8 f6 ff ff       	jmp    80108028 <alltraps>

80108980 <vector88>:
.globl vector88
vector88:
  pushl $0
80108980:	6a 00                	push   $0x0
  pushl $88
80108982:	6a 58                	push   $0x58
  jmp alltraps
80108984:	e9 9f f6 ff ff       	jmp    80108028 <alltraps>

80108989 <vector89>:
.globl vector89
vector89:
  pushl $0
80108989:	6a 00                	push   $0x0
  pushl $89
8010898b:	6a 59                	push   $0x59
  jmp alltraps
8010898d:	e9 96 f6 ff ff       	jmp    80108028 <alltraps>

80108992 <vector90>:
.globl vector90
vector90:
  pushl $0
80108992:	6a 00                	push   $0x0
  pushl $90
80108994:	6a 5a                	push   $0x5a
  jmp alltraps
80108996:	e9 8d f6 ff ff       	jmp    80108028 <alltraps>

8010899b <vector91>:
.globl vector91
vector91:
  pushl $0
8010899b:	6a 00                	push   $0x0
  pushl $91
8010899d:	6a 5b                	push   $0x5b
  jmp alltraps
8010899f:	e9 84 f6 ff ff       	jmp    80108028 <alltraps>

801089a4 <vector92>:
.globl vector92
vector92:
  pushl $0
801089a4:	6a 00                	push   $0x0
  pushl $92
801089a6:	6a 5c                	push   $0x5c
  jmp alltraps
801089a8:	e9 7b f6 ff ff       	jmp    80108028 <alltraps>

801089ad <vector93>:
.globl vector93
vector93:
  pushl $0
801089ad:	6a 00                	push   $0x0
  pushl $93
801089af:	6a 5d                	push   $0x5d
  jmp alltraps
801089b1:	e9 72 f6 ff ff       	jmp    80108028 <alltraps>

801089b6 <vector94>:
.globl vector94
vector94:
  pushl $0
801089b6:	6a 00                	push   $0x0
  pushl $94
801089b8:	6a 5e                	push   $0x5e
  jmp alltraps
801089ba:	e9 69 f6 ff ff       	jmp    80108028 <alltraps>

801089bf <vector95>:
.globl vector95
vector95:
  pushl $0
801089bf:	6a 00                	push   $0x0
  pushl $95
801089c1:	6a 5f                	push   $0x5f
  jmp alltraps
801089c3:	e9 60 f6 ff ff       	jmp    80108028 <alltraps>

801089c8 <vector96>:
.globl vector96
vector96:
  pushl $0
801089c8:	6a 00                	push   $0x0
  pushl $96
801089ca:	6a 60                	push   $0x60
  jmp alltraps
801089cc:	e9 57 f6 ff ff       	jmp    80108028 <alltraps>

801089d1 <vector97>:
.globl vector97
vector97:
  pushl $0
801089d1:	6a 00                	push   $0x0
  pushl $97
801089d3:	6a 61                	push   $0x61
  jmp alltraps
801089d5:	e9 4e f6 ff ff       	jmp    80108028 <alltraps>

801089da <vector98>:
.globl vector98
vector98:
  pushl $0
801089da:	6a 00                	push   $0x0
  pushl $98
801089dc:	6a 62                	push   $0x62
  jmp alltraps
801089de:	e9 45 f6 ff ff       	jmp    80108028 <alltraps>

801089e3 <vector99>:
.globl vector99
vector99:
  pushl $0
801089e3:	6a 00                	push   $0x0
  pushl $99
801089e5:	6a 63                	push   $0x63
  jmp alltraps
801089e7:	e9 3c f6 ff ff       	jmp    80108028 <alltraps>

801089ec <vector100>:
.globl vector100
vector100:
  pushl $0
801089ec:	6a 00                	push   $0x0
  pushl $100
801089ee:	6a 64                	push   $0x64
  jmp alltraps
801089f0:	e9 33 f6 ff ff       	jmp    80108028 <alltraps>

801089f5 <vector101>:
.globl vector101
vector101:
  pushl $0
801089f5:	6a 00                	push   $0x0
  pushl $101
801089f7:	6a 65                	push   $0x65
  jmp alltraps
801089f9:	e9 2a f6 ff ff       	jmp    80108028 <alltraps>

801089fe <vector102>:
.globl vector102
vector102:
  pushl $0
801089fe:	6a 00                	push   $0x0
  pushl $102
80108a00:	6a 66                	push   $0x66
  jmp alltraps
80108a02:	e9 21 f6 ff ff       	jmp    80108028 <alltraps>

80108a07 <vector103>:
.globl vector103
vector103:
  pushl $0
80108a07:	6a 00                	push   $0x0
  pushl $103
80108a09:	6a 67                	push   $0x67
  jmp alltraps
80108a0b:	e9 18 f6 ff ff       	jmp    80108028 <alltraps>

80108a10 <vector104>:
.globl vector104
vector104:
  pushl $0
80108a10:	6a 00                	push   $0x0
  pushl $104
80108a12:	6a 68                	push   $0x68
  jmp alltraps
80108a14:	e9 0f f6 ff ff       	jmp    80108028 <alltraps>

80108a19 <vector105>:
.globl vector105
vector105:
  pushl $0
80108a19:	6a 00                	push   $0x0
  pushl $105
80108a1b:	6a 69                	push   $0x69
  jmp alltraps
80108a1d:	e9 06 f6 ff ff       	jmp    80108028 <alltraps>

80108a22 <vector106>:
.globl vector106
vector106:
  pushl $0
80108a22:	6a 00                	push   $0x0
  pushl $106
80108a24:	6a 6a                	push   $0x6a
  jmp alltraps
80108a26:	e9 fd f5 ff ff       	jmp    80108028 <alltraps>

80108a2b <vector107>:
.globl vector107
vector107:
  pushl $0
80108a2b:	6a 00                	push   $0x0
  pushl $107
80108a2d:	6a 6b                	push   $0x6b
  jmp alltraps
80108a2f:	e9 f4 f5 ff ff       	jmp    80108028 <alltraps>

80108a34 <vector108>:
.globl vector108
vector108:
  pushl $0
80108a34:	6a 00                	push   $0x0
  pushl $108
80108a36:	6a 6c                	push   $0x6c
  jmp alltraps
80108a38:	e9 eb f5 ff ff       	jmp    80108028 <alltraps>

80108a3d <vector109>:
.globl vector109
vector109:
  pushl $0
80108a3d:	6a 00                	push   $0x0
  pushl $109
80108a3f:	6a 6d                	push   $0x6d
  jmp alltraps
80108a41:	e9 e2 f5 ff ff       	jmp    80108028 <alltraps>

80108a46 <vector110>:
.globl vector110
vector110:
  pushl $0
80108a46:	6a 00                	push   $0x0
  pushl $110
80108a48:	6a 6e                	push   $0x6e
  jmp alltraps
80108a4a:	e9 d9 f5 ff ff       	jmp    80108028 <alltraps>

80108a4f <vector111>:
.globl vector111
vector111:
  pushl $0
80108a4f:	6a 00                	push   $0x0
  pushl $111
80108a51:	6a 6f                	push   $0x6f
  jmp alltraps
80108a53:	e9 d0 f5 ff ff       	jmp    80108028 <alltraps>

80108a58 <vector112>:
.globl vector112
vector112:
  pushl $0
80108a58:	6a 00                	push   $0x0
  pushl $112
80108a5a:	6a 70                	push   $0x70
  jmp alltraps
80108a5c:	e9 c7 f5 ff ff       	jmp    80108028 <alltraps>

80108a61 <vector113>:
.globl vector113
vector113:
  pushl $0
80108a61:	6a 00                	push   $0x0
  pushl $113
80108a63:	6a 71                	push   $0x71
  jmp alltraps
80108a65:	e9 be f5 ff ff       	jmp    80108028 <alltraps>

80108a6a <vector114>:
.globl vector114
vector114:
  pushl $0
80108a6a:	6a 00                	push   $0x0
  pushl $114
80108a6c:	6a 72                	push   $0x72
  jmp alltraps
80108a6e:	e9 b5 f5 ff ff       	jmp    80108028 <alltraps>

80108a73 <vector115>:
.globl vector115
vector115:
  pushl $0
80108a73:	6a 00                	push   $0x0
  pushl $115
80108a75:	6a 73                	push   $0x73
  jmp alltraps
80108a77:	e9 ac f5 ff ff       	jmp    80108028 <alltraps>

80108a7c <vector116>:
.globl vector116
vector116:
  pushl $0
80108a7c:	6a 00                	push   $0x0
  pushl $116
80108a7e:	6a 74                	push   $0x74
  jmp alltraps
80108a80:	e9 a3 f5 ff ff       	jmp    80108028 <alltraps>

80108a85 <vector117>:
.globl vector117
vector117:
  pushl $0
80108a85:	6a 00                	push   $0x0
  pushl $117
80108a87:	6a 75                	push   $0x75
  jmp alltraps
80108a89:	e9 9a f5 ff ff       	jmp    80108028 <alltraps>

80108a8e <vector118>:
.globl vector118
vector118:
  pushl $0
80108a8e:	6a 00                	push   $0x0
  pushl $118
80108a90:	6a 76                	push   $0x76
  jmp alltraps
80108a92:	e9 91 f5 ff ff       	jmp    80108028 <alltraps>

80108a97 <vector119>:
.globl vector119
vector119:
  pushl $0
80108a97:	6a 00                	push   $0x0
  pushl $119
80108a99:	6a 77                	push   $0x77
  jmp alltraps
80108a9b:	e9 88 f5 ff ff       	jmp    80108028 <alltraps>

80108aa0 <vector120>:
.globl vector120
vector120:
  pushl $0
80108aa0:	6a 00                	push   $0x0
  pushl $120
80108aa2:	6a 78                	push   $0x78
  jmp alltraps
80108aa4:	e9 7f f5 ff ff       	jmp    80108028 <alltraps>

80108aa9 <vector121>:
.globl vector121
vector121:
  pushl $0
80108aa9:	6a 00                	push   $0x0
  pushl $121
80108aab:	6a 79                	push   $0x79
  jmp alltraps
80108aad:	e9 76 f5 ff ff       	jmp    80108028 <alltraps>

80108ab2 <vector122>:
.globl vector122
vector122:
  pushl $0
80108ab2:	6a 00                	push   $0x0
  pushl $122
80108ab4:	6a 7a                	push   $0x7a
  jmp alltraps
80108ab6:	e9 6d f5 ff ff       	jmp    80108028 <alltraps>

80108abb <vector123>:
.globl vector123
vector123:
  pushl $0
80108abb:	6a 00                	push   $0x0
  pushl $123
80108abd:	6a 7b                	push   $0x7b
  jmp alltraps
80108abf:	e9 64 f5 ff ff       	jmp    80108028 <alltraps>

80108ac4 <vector124>:
.globl vector124
vector124:
  pushl $0
80108ac4:	6a 00                	push   $0x0
  pushl $124
80108ac6:	6a 7c                	push   $0x7c
  jmp alltraps
80108ac8:	e9 5b f5 ff ff       	jmp    80108028 <alltraps>

80108acd <vector125>:
.globl vector125
vector125:
  pushl $0
80108acd:	6a 00                	push   $0x0
  pushl $125
80108acf:	6a 7d                	push   $0x7d
  jmp alltraps
80108ad1:	e9 52 f5 ff ff       	jmp    80108028 <alltraps>

80108ad6 <vector126>:
.globl vector126
vector126:
  pushl $0
80108ad6:	6a 00                	push   $0x0
  pushl $126
80108ad8:	6a 7e                	push   $0x7e
  jmp alltraps
80108ada:	e9 49 f5 ff ff       	jmp    80108028 <alltraps>

80108adf <vector127>:
.globl vector127
vector127:
  pushl $0
80108adf:	6a 00                	push   $0x0
  pushl $127
80108ae1:	6a 7f                	push   $0x7f
  jmp alltraps
80108ae3:	e9 40 f5 ff ff       	jmp    80108028 <alltraps>

80108ae8 <vector128>:
.globl vector128
vector128:
  pushl $0
80108ae8:	6a 00                	push   $0x0
  pushl $128
80108aea:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80108aef:	e9 34 f5 ff ff       	jmp    80108028 <alltraps>

80108af4 <vector129>:
.globl vector129
vector129:
  pushl $0
80108af4:	6a 00                	push   $0x0
  pushl $129
80108af6:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80108afb:	e9 28 f5 ff ff       	jmp    80108028 <alltraps>

80108b00 <vector130>:
.globl vector130
vector130:
  pushl $0
80108b00:	6a 00                	push   $0x0
  pushl $130
80108b02:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80108b07:	e9 1c f5 ff ff       	jmp    80108028 <alltraps>

80108b0c <vector131>:
.globl vector131
vector131:
  pushl $0
80108b0c:	6a 00                	push   $0x0
  pushl $131
80108b0e:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80108b13:	e9 10 f5 ff ff       	jmp    80108028 <alltraps>

80108b18 <vector132>:
.globl vector132
vector132:
  pushl $0
80108b18:	6a 00                	push   $0x0
  pushl $132
80108b1a:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80108b1f:	e9 04 f5 ff ff       	jmp    80108028 <alltraps>

80108b24 <vector133>:
.globl vector133
vector133:
  pushl $0
80108b24:	6a 00                	push   $0x0
  pushl $133
80108b26:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80108b2b:	e9 f8 f4 ff ff       	jmp    80108028 <alltraps>

80108b30 <vector134>:
.globl vector134
vector134:
  pushl $0
80108b30:	6a 00                	push   $0x0
  pushl $134
80108b32:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80108b37:	e9 ec f4 ff ff       	jmp    80108028 <alltraps>

80108b3c <vector135>:
.globl vector135
vector135:
  pushl $0
80108b3c:	6a 00                	push   $0x0
  pushl $135
80108b3e:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80108b43:	e9 e0 f4 ff ff       	jmp    80108028 <alltraps>

80108b48 <vector136>:
.globl vector136
vector136:
  pushl $0
80108b48:	6a 00                	push   $0x0
  pushl $136
80108b4a:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80108b4f:	e9 d4 f4 ff ff       	jmp    80108028 <alltraps>

80108b54 <vector137>:
.globl vector137
vector137:
  pushl $0
80108b54:	6a 00                	push   $0x0
  pushl $137
80108b56:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80108b5b:	e9 c8 f4 ff ff       	jmp    80108028 <alltraps>

80108b60 <vector138>:
.globl vector138
vector138:
  pushl $0
80108b60:	6a 00                	push   $0x0
  pushl $138
80108b62:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80108b67:	e9 bc f4 ff ff       	jmp    80108028 <alltraps>

80108b6c <vector139>:
.globl vector139
vector139:
  pushl $0
80108b6c:	6a 00                	push   $0x0
  pushl $139
80108b6e:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80108b73:	e9 b0 f4 ff ff       	jmp    80108028 <alltraps>

80108b78 <vector140>:
.globl vector140
vector140:
  pushl $0
80108b78:	6a 00                	push   $0x0
  pushl $140
80108b7a:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80108b7f:	e9 a4 f4 ff ff       	jmp    80108028 <alltraps>

80108b84 <vector141>:
.globl vector141
vector141:
  pushl $0
80108b84:	6a 00                	push   $0x0
  pushl $141
80108b86:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80108b8b:	e9 98 f4 ff ff       	jmp    80108028 <alltraps>

80108b90 <vector142>:
.globl vector142
vector142:
  pushl $0
80108b90:	6a 00                	push   $0x0
  pushl $142
80108b92:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80108b97:	e9 8c f4 ff ff       	jmp    80108028 <alltraps>

80108b9c <vector143>:
.globl vector143
vector143:
  pushl $0
80108b9c:	6a 00                	push   $0x0
  pushl $143
80108b9e:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80108ba3:	e9 80 f4 ff ff       	jmp    80108028 <alltraps>

80108ba8 <vector144>:
.globl vector144
vector144:
  pushl $0
80108ba8:	6a 00                	push   $0x0
  pushl $144
80108baa:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80108baf:	e9 74 f4 ff ff       	jmp    80108028 <alltraps>

80108bb4 <vector145>:
.globl vector145
vector145:
  pushl $0
80108bb4:	6a 00                	push   $0x0
  pushl $145
80108bb6:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80108bbb:	e9 68 f4 ff ff       	jmp    80108028 <alltraps>

80108bc0 <vector146>:
.globl vector146
vector146:
  pushl $0
80108bc0:	6a 00                	push   $0x0
  pushl $146
80108bc2:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80108bc7:	e9 5c f4 ff ff       	jmp    80108028 <alltraps>

80108bcc <vector147>:
.globl vector147
vector147:
  pushl $0
80108bcc:	6a 00                	push   $0x0
  pushl $147
80108bce:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80108bd3:	e9 50 f4 ff ff       	jmp    80108028 <alltraps>

80108bd8 <vector148>:
.globl vector148
vector148:
  pushl $0
80108bd8:	6a 00                	push   $0x0
  pushl $148
80108bda:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80108bdf:	e9 44 f4 ff ff       	jmp    80108028 <alltraps>

80108be4 <vector149>:
.globl vector149
vector149:
  pushl $0
80108be4:	6a 00                	push   $0x0
  pushl $149
80108be6:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80108beb:	e9 38 f4 ff ff       	jmp    80108028 <alltraps>

80108bf0 <vector150>:
.globl vector150
vector150:
  pushl $0
80108bf0:	6a 00                	push   $0x0
  pushl $150
80108bf2:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80108bf7:	e9 2c f4 ff ff       	jmp    80108028 <alltraps>

80108bfc <vector151>:
.globl vector151
vector151:
  pushl $0
80108bfc:	6a 00                	push   $0x0
  pushl $151
80108bfe:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80108c03:	e9 20 f4 ff ff       	jmp    80108028 <alltraps>

80108c08 <vector152>:
.globl vector152
vector152:
  pushl $0
80108c08:	6a 00                	push   $0x0
  pushl $152
80108c0a:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80108c0f:	e9 14 f4 ff ff       	jmp    80108028 <alltraps>

80108c14 <vector153>:
.globl vector153
vector153:
  pushl $0
80108c14:	6a 00                	push   $0x0
  pushl $153
80108c16:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80108c1b:	e9 08 f4 ff ff       	jmp    80108028 <alltraps>

80108c20 <vector154>:
.globl vector154
vector154:
  pushl $0
80108c20:	6a 00                	push   $0x0
  pushl $154
80108c22:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80108c27:	e9 fc f3 ff ff       	jmp    80108028 <alltraps>

80108c2c <vector155>:
.globl vector155
vector155:
  pushl $0
80108c2c:	6a 00                	push   $0x0
  pushl $155
80108c2e:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80108c33:	e9 f0 f3 ff ff       	jmp    80108028 <alltraps>

80108c38 <vector156>:
.globl vector156
vector156:
  pushl $0
80108c38:	6a 00                	push   $0x0
  pushl $156
80108c3a:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80108c3f:	e9 e4 f3 ff ff       	jmp    80108028 <alltraps>

80108c44 <vector157>:
.globl vector157
vector157:
  pushl $0
80108c44:	6a 00                	push   $0x0
  pushl $157
80108c46:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80108c4b:	e9 d8 f3 ff ff       	jmp    80108028 <alltraps>

80108c50 <vector158>:
.globl vector158
vector158:
  pushl $0
80108c50:	6a 00                	push   $0x0
  pushl $158
80108c52:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80108c57:	e9 cc f3 ff ff       	jmp    80108028 <alltraps>

80108c5c <vector159>:
.globl vector159
vector159:
  pushl $0
80108c5c:	6a 00                	push   $0x0
  pushl $159
80108c5e:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80108c63:	e9 c0 f3 ff ff       	jmp    80108028 <alltraps>

80108c68 <vector160>:
.globl vector160
vector160:
  pushl $0
80108c68:	6a 00                	push   $0x0
  pushl $160
80108c6a:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80108c6f:	e9 b4 f3 ff ff       	jmp    80108028 <alltraps>

80108c74 <vector161>:
.globl vector161
vector161:
  pushl $0
80108c74:	6a 00                	push   $0x0
  pushl $161
80108c76:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80108c7b:	e9 a8 f3 ff ff       	jmp    80108028 <alltraps>

80108c80 <vector162>:
.globl vector162
vector162:
  pushl $0
80108c80:	6a 00                	push   $0x0
  pushl $162
80108c82:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80108c87:	e9 9c f3 ff ff       	jmp    80108028 <alltraps>

80108c8c <vector163>:
.globl vector163
vector163:
  pushl $0
80108c8c:	6a 00                	push   $0x0
  pushl $163
80108c8e:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80108c93:	e9 90 f3 ff ff       	jmp    80108028 <alltraps>

80108c98 <vector164>:
.globl vector164
vector164:
  pushl $0
80108c98:	6a 00                	push   $0x0
  pushl $164
80108c9a:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80108c9f:	e9 84 f3 ff ff       	jmp    80108028 <alltraps>

80108ca4 <vector165>:
.globl vector165
vector165:
  pushl $0
80108ca4:	6a 00                	push   $0x0
  pushl $165
80108ca6:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80108cab:	e9 78 f3 ff ff       	jmp    80108028 <alltraps>

80108cb0 <vector166>:
.globl vector166
vector166:
  pushl $0
80108cb0:	6a 00                	push   $0x0
  pushl $166
80108cb2:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80108cb7:	e9 6c f3 ff ff       	jmp    80108028 <alltraps>

80108cbc <vector167>:
.globl vector167
vector167:
  pushl $0
80108cbc:	6a 00                	push   $0x0
  pushl $167
80108cbe:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80108cc3:	e9 60 f3 ff ff       	jmp    80108028 <alltraps>

80108cc8 <vector168>:
.globl vector168
vector168:
  pushl $0
80108cc8:	6a 00                	push   $0x0
  pushl $168
80108cca:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80108ccf:	e9 54 f3 ff ff       	jmp    80108028 <alltraps>

80108cd4 <vector169>:
.globl vector169
vector169:
  pushl $0
80108cd4:	6a 00                	push   $0x0
  pushl $169
80108cd6:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80108cdb:	e9 48 f3 ff ff       	jmp    80108028 <alltraps>

80108ce0 <vector170>:
.globl vector170
vector170:
  pushl $0
80108ce0:	6a 00                	push   $0x0
  pushl $170
80108ce2:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80108ce7:	e9 3c f3 ff ff       	jmp    80108028 <alltraps>

80108cec <vector171>:
.globl vector171
vector171:
  pushl $0
80108cec:	6a 00                	push   $0x0
  pushl $171
80108cee:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80108cf3:	e9 30 f3 ff ff       	jmp    80108028 <alltraps>

80108cf8 <vector172>:
.globl vector172
vector172:
  pushl $0
80108cf8:	6a 00                	push   $0x0
  pushl $172
80108cfa:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80108cff:	e9 24 f3 ff ff       	jmp    80108028 <alltraps>

80108d04 <vector173>:
.globl vector173
vector173:
  pushl $0
80108d04:	6a 00                	push   $0x0
  pushl $173
80108d06:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80108d0b:	e9 18 f3 ff ff       	jmp    80108028 <alltraps>

80108d10 <vector174>:
.globl vector174
vector174:
  pushl $0
80108d10:	6a 00                	push   $0x0
  pushl $174
80108d12:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80108d17:	e9 0c f3 ff ff       	jmp    80108028 <alltraps>

80108d1c <vector175>:
.globl vector175
vector175:
  pushl $0
80108d1c:	6a 00                	push   $0x0
  pushl $175
80108d1e:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80108d23:	e9 00 f3 ff ff       	jmp    80108028 <alltraps>

80108d28 <vector176>:
.globl vector176
vector176:
  pushl $0
80108d28:	6a 00                	push   $0x0
  pushl $176
80108d2a:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80108d2f:	e9 f4 f2 ff ff       	jmp    80108028 <alltraps>

80108d34 <vector177>:
.globl vector177
vector177:
  pushl $0
80108d34:	6a 00                	push   $0x0
  pushl $177
80108d36:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80108d3b:	e9 e8 f2 ff ff       	jmp    80108028 <alltraps>

80108d40 <vector178>:
.globl vector178
vector178:
  pushl $0
80108d40:	6a 00                	push   $0x0
  pushl $178
80108d42:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80108d47:	e9 dc f2 ff ff       	jmp    80108028 <alltraps>

80108d4c <vector179>:
.globl vector179
vector179:
  pushl $0
80108d4c:	6a 00                	push   $0x0
  pushl $179
80108d4e:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80108d53:	e9 d0 f2 ff ff       	jmp    80108028 <alltraps>

80108d58 <vector180>:
.globl vector180
vector180:
  pushl $0
80108d58:	6a 00                	push   $0x0
  pushl $180
80108d5a:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80108d5f:	e9 c4 f2 ff ff       	jmp    80108028 <alltraps>

80108d64 <vector181>:
.globl vector181
vector181:
  pushl $0
80108d64:	6a 00                	push   $0x0
  pushl $181
80108d66:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80108d6b:	e9 b8 f2 ff ff       	jmp    80108028 <alltraps>

80108d70 <vector182>:
.globl vector182
vector182:
  pushl $0
80108d70:	6a 00                	push   $0x0
  pushl $182
80108d72:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80108d77:	e9 ac f2 ff ff       	jmp    80108028 <alltraps>

80108d7c <vector183>:
.globl vector183
vector183:
  pushl $0
80108d7c:	6a 00                	push   $0x0
  pushl $183
80108d7e:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80108d83:	e9 a0 f2 ff ff       	jmp    80108028 <alltraps>

80108d88 <vector184>:
.globl vector184
vector184:
  pushl $0
80108d88:	6a 00                	push   $0x0
  pushl $184
80108d8a:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80108d8f:	e9 94 f2 ff ff       	jmp    80108028 <alltraps>

80108d94 <vector185>:
.globl vector185
vector185:
  pushl $0
80108d94:	6a 00                	push   $0x0
  pushl $185
80108d96:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80108d9b:	e9 88 f2 ff ff       	jmp    80108028 <alltraps>

80108da0 <vector186>:
.globl vector186
vector186:
  pushl $0
80108da0:	6a 00                	push   $0x0
  pushl $186
80108da2:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80108da7:	e9 7c f2 ff ff       	jmp    80108028 <alltraps>

80108dac <vector187>:
.globl vector187
vector187:
  pushl $0
80108dac:	6a 00                	push   $0x0
  pushl $187
80108dae:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80108db3:	e9 70 f2 ff ff       	jmp    80108028 <alltraps>

80108db8 <vector188>:
.globl vector188
vector188:
  pushl $0
80108db8:	6a 00                	push   $0x0
  pushl $188
80108dba:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80108dbf:	e9 64 f2 ff ff       	jmp    80108028 <alltraps>

80108dc4 <vector189>:
.globl vector189
vector189:
  pushl $0
80108dc4:	6a 00                	push   $0x0
  pushl $189
80108dc6:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80108dcb:	e9 58 f2 ff ff       	jmp    80108028 <alltraps>

80108dd0 <vector190>:
.globl vector190
vector190:
  pushl $0
80108dd0:	6a 00                	push   $0x0
  pushl $190
80108dd2:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80108dd7:	e9 4c f2 ff ff       	jmp    80108028 <alltraps>

80108ddc <vector191>:
.globl vector191
vector191:
  pushl $0
80108ddc:	6a 00                	push   $0x0
  pushl $191
80108dde:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80108de3:	e9 40 f2 ff ff       	jmp    80108028 <alltraps>

80108de8 <vector192>:
.globl vector192
vector192:
  pushl $0
80108de8:	6a 00                	push   $0x0
  pushl $192
80108dea:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80108def:	e9 34 f2 ff ff       	jmp    80108028 <alltraps>

80108df4 <vector193>:
.globl vector193
vector193:
  pushl $0
80108df4:	6a 00                	push   $0x0
  pushl $193
80108df6:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80108dfb:	e9 28 f2 ff ff       	jmp    80108028 <alltraps>

80108e00 <vector194>:
.globl vector194
vector194:
  pushl $0
80108e00:	6a 00                	push   $0x0
  pushl $194
80108e02:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80108e07:	e9 1c f2 ff ff       	jmp    80108028 <alltraps>

80108e0c <vector195>:
.globl vector195
vector195:
  pushl $0
80108e0c:	6a 00                	push   $0x0
  pushl $195
80108e0e:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80108e13:	e9 10 f2 ff ff       	jmp    80108028 <alltraps>

80108e18 <vector196>:
.globl vector196
vector196:
  pushl $0
80108e18:	6a 00                	push   $0x0
  pushl $196
80108e1a:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80108e1f:	e9 04 f2 ff ff       	jmp    80108028 <alltraps>

80108e24 <vector197>:
.globl vector197
vector197:
  pushl $0
80108e24:	6a 00                	push   $0x0
  pushl $197
80108e26:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80108e2b:	e9 f8 f1 ff ff       	jmp    80108028 <alltraps>

80108e30 <vector198>:
.globl vector198
vector198:
  pushl $0
80108e30:	6a 00                	push   $0x0
  pushl $198
80108e32:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80108e37:	e9 ec f1 ff ff       	jmp    80108028 <alltraps>

80108e3c <vector199>:
.globl vector199
vector199:
  pushl $0
80108e3c:	6a 00                	push   $0x0
  pushl $199
80108e3e:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80108e43:	e9 e0 f1 ff ff       	jmp    80108028 <alltraps>

80108e48 <vector200>:
.globl vector200
vector200:
  pushl $0
80108e48:	6a 00                	push   $0x0
  pushl $200
80108e4a:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80108e4f:	e9 d4 f1 ff ff       	jmp    80108028 <alltraps>

80108e54 <vector201>:
.globl vector201
vector201:
  pushl $0
80108e54:	6a 00                	push   $0x0
  pushl $201
80108e56:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80108e5b:	e9 c8 f1 ff ff       	jmp    80108028 <alltraps>

80108e60 <vector202>:
.globl vector202
vector202:
  pushl $0
80108e60:	6a 00                	push   $0x0
  pushl $202
80108e62:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80108e67:	e9 bc f1 ff ff       	jmp    80108028 <alltraps>

80108e6c <vector203>:
.globl vector203
vector203:
  pushl $0
80108e6c:	6a 00                	push   $0x0
  pushl $203
80108e6e:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80108e73:	e9 b0 f1 ff ff       	jmp    80108028 <alltraps>

80108e78 <vector204>:
.globl vector204
vector204:
  pushl $0
80108e78:	6a 00                	push   $0x0
  pushl $204
80108e7a:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80108e7f:	e9 a4 f1 ff ff       	jmp    80108028 <alltraps>

80108e84 <vector205>:
.globl vector205
vector205:
  pushl $0
80108e84:	6a 00                	push   $0x0
  pushl $205
80108e86:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80108e8b:	e9 98 f1 ff ff       	jmp    80108028 <alltraps>

80108e90 <vector206>:
.globl vector206
vector206:
  pushl $0
80108e90:	6a 00                	push   $0x0
  pushl $206
80108e92:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80108e97:	e9 8c f1 ff ff       	jmp    80108028 <alltraps>

80108e9c <vector207>:
.globl vector207
vector207:
  pushl $0
80108e9c:	6a 00                	push   $0x0
  pushl $207
80108e9e:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80108ea3:	e9 80 f1 ff ff       	jmp    80108028 <alltraps>

80108ea8 <vector208>:
.globl vector208
vector208:
  pushl $0
80108ea8:	6a 00                	push   $0x0
  pushl $208
80108eaa:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80108eaf:	e9 74 f1 ff ff       	jmp    80108028 <alltraps>

80108eb4 <vector209>:
.globl vector209
vector209:
  pushl $0
80108eb4:	6a 00                	push   $0x0
  pushl $209
80108eb6:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80108ebb:	e9 68 f1 ff ff       	jmp    80108028 <alltraps>

80108ec0 <vector210>:
.globl vector210
vector210:
  pushl $0
80108ec0:	6a 00                	push   $0x0
  pushl $210
80108ec2:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80108ec7:	e9 5c f1 ff ff       	jmp    80108028 <alltraps>

80108ecc <vector211>:
.globl vector211
vector211:
  pushl $0
80108ecc:	6a 00                	push   $0x0
  pushl $211
80108ece:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80108ed3:	e9 50 f1 ff ff       	jmp    80108028 <alltraps>

80108ed8 <vector212>:
.globl vector212
vector212:
  pushl $0
80108ed8:	6a 00                	push   $0x0
  pushl $212
80108eda:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80108edf:	e9 44 f1 ff ff       	jmp    80108028 <alltraps>

80108ee4 <vector213>:
.globl vector213
vector213:
  pushl $0
80108ee4:	6a 00                	push   $0x0
  pushl $213
80108ee6:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80108eeb:	e9 38 f1 ff ff       	jmp    80108028 <alltraps>

80108ef0 <vector214>:
.globl vector214
vector214:
  pushl $0
80108ef0:	6a 00                	push   $0x0
  pushl $214
80108ef2:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80108ef7:	e9 2c f1 ff ff       	jmp    80108028 <alltraps>

80108efc <vector215>:
.globl vector215
vector215:
  pushl $0
80108efc:	6a 00                	push   $0x0
  pushl $215
80108efe:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80108f03:	e9 20 f1 ff ff       	jmp    80108028 <alltraps>

80108f08 <vector216>:
.globl vector216
vector216:
  pushl $0
80108f08:	6a 00                	push   $0x0
  pushl $216
80108f0a:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80108f0f:	e9 14 f1 ff ff       	jmp    80108028 <alltraps>

80108f14 <vector217>:
.globl vector217
vector217:
  pushl $0
80108f14:	6a 00                	push   $0x0
  pushl $217
80108f16:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80108f1b:	e9 08 f1 ff ff       	jmp    80108028 <alltraps>

80108f20 <vector218>:
.globl vector218
vector218:
  pushl $0
80108f20:	6a 00                	push   $0x0
  pushl $218
80108f22:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80108f27:	e9 fc f0 ff ff       	jmp    80108028 <alltraps>

80108f2c <vector219>:
.globl vector219
vector219:
  pushl $0
80108f2c:	6a 00                	push   $0x0
  pushl $219
80108f2e:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80108f33:	e9 f0 f0 ff ff       	jmp    80108028 <alltraps>

80108f38 <vector220>:
.globl vector220
vector220:
  pushl $0
80108f38:	6a 00                	push   $0x0
  pushl $220
80108f3a:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80108f3f:	e9 e4 f0 ff ff       	jmp    80108028 <alltraps>

80108f44 <vector221>:
.globl vector221
vector221:
  pushl $0
80108f44:	6a 00                	push   $0x0
  pushl $221
80108f46:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80108f4b:	e9 d8 f0 ff ff       	jmp    80108028 <alltraps>

80108f50 <vector222>:
.globl vector222
vector222:
  pushl $0
80108f50:	6a 00                	push   $0x0
  pushl $222
80108f52:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80108f57:	e9 cc f0 ff ff       	jmp    80108028 <alltraps>

80108f5c <vector223>:
.globl vector223
vector223:
  pushl $0
80108f5c:	6a 00                	push   $0x0
  pushl $223
80108f5e:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80108f63:	e9 c0 f0 ff ff       	jmp    80108028 <alltraps>

80108f68 <vector224>:
.globl vector224
vector224:
  pushl $0
80108f68:	6a 00                	push   $0x0
  pushl $224
80108f6a:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80108f6f:	e9 b4 f0 ff ff       	jmp    80108028 <alltraps>

80108f74 <vector225>:
.globl vector225
vector225:
  pushl $0
80108f74:	6a 00                	push   $0x0
  pushl $225
80108f76:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80108f7b:	e9 a8 f0 ff ff       	jmp    80108028 <alltraps>

80108f80 <vector226>:
.globl vector226
vector226:
  pushl $0
80108f80:	6a 00                	push   $0x0
  pushl $226
80108f82:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80108f87:	e9 9c f0 ff ff       	jmp    80108028 <alltraps>

80108f8c <vector227>:
.globl vector227
vector227:
  pushl $0
80108f8c:	6a 00                	push   $0x0
  pushl $227
80108f8e:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80108f93:	e9 90 f0 ff ff       	jmp    80108028 <alltraps>

80108f98 <vector228>:
.globl vector228
vector228:
  pushl $0
80108f98:	6a 00                	push   $0x0
  pushl $228
80108f9a:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80108f9f:	e9 84 f0 ff ff       	jmp    80108028 <alltraps>

80108fa4 <vector229>:
.globl vector229
vector229:
  pushl $0
80108fa4:	6a 00                	push   $0x0
  pushl $229
80108fa6:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80108fab:	e9 78 f0 ff ff       	jmp    80108028 <alltraps>

80108fb0 <vector230>:
.globl vector230
vector230:
  pushl $0
80108fb0:	6a 00                	push   $0x0
  pushl $230
80108fb2:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80108fb7:	e9 6c f0 ff ff       	jmp    80108028 <alltraps>

80108fbc <vector231>:
.globl vector231
vector231:
  pushl $0
80108fbc:	6a 00                	push   $0x0
  pushl $231
80108fbe:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80108fc3:	e9 60 f0 ff ff       	jmp    80108028 <alltraps>

80108fc8 <vector232>:
.globl vector232
vector232:
  pushl $0
80108fc8:	6a 00                	push   $0x0
  pushl $232
80108fca:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80108fcf:	e9 54 f0 ff ff       	jmp    80108028 <alltraps>

80108fd4 <vector233>:
.globl vector233
vector233:
  pushl $0
80108fd4:	6a 00                	push   $0x0
  pushl $233
80108fd6:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80108fdb:	e9 48 f0 ff ff       	jmp    80108028 <alltraps>

80108fe0 <vector234>:
.globl vector234
vector234:
  pushl $0
80108fe0:	6a 00                	push   $0x0
  pushl $234
80108fe2:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80108fe7:	e9 3c f0 ff ff       	jmp    80108028 <alltraps>

80108fec <vector235>:
.globl vector235
vector235:
  pushl $0
80108fec:	6a 00                	push   $0x0
  pushl $235
80108fee:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80108ff3:	e9 30 f0 ff ff       	jmp    80108028 <alltraps>

80108ff8 <vector236>:
.globl vector236
vector236:
  pushl $0
80108ff8:	6a 00                	push   $0x0
  pushl $236
80108ffa:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80108fff:	e9 24 f0 ff ff       	jmp    80108028 <alltraps>

80109004 <vector237>:
.globl vector237
vector237:
  pushl $0
80109004:	6a 00                	push   $0x0
  pushl $237
80109006:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010900b:	e9 18 f0 ff ff       	jmp    80108028 <alltraps>

80109010 <vector238>:
.globl vector238
vector238:
  pushl $0
80109010:	6a 00                	push   $0x0
  pushl $238
80109012:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80109017:	e9 0c f0 ff ff       	jmp    80108028 <alltraps>

8010901c <vector239>:
.globl vector239
vector239:
  pushl $0
8010901c:	6a 00                	push   $0x0
  pushl $239
8010901e:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80109023:	e9 00 f0 ff ff       	jmp    80108028 <alltraps>

80109028 <vector240>:
.globl vector240
vector240:
  pushl $0
80109028:	6a 00                	push   $0x0
  pushl $240
8010902a:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010902f:	e9 f4 ef ff ff       	jmp    80108028 <alltraps>

80109034 <vector241>:
.globl vector241
vector241:
  pushl $0
80109034:	6a 00                	push   $0x0
  pushl $241
80109036:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010903b:	e9 e8 ef ff ff       	jmp    80108028 <alltraps>

80109040 <vector242>:
.globl vector242
vector242:
  pushl $0
80109040:	6a 00                	push   $0x0
  pushl $242
80109042:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80109047:	e9 dc ef ff ff       	jmp    80108028 <alltraps>

8010904c <vector243>:
.globl vector243
vector243:
  pushl $0
8010904c:	6a 00                	push   $0x0
  pushl $243
8010904e:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80109053:	e9 d0 ef ff ff       	jmp    80108028 <alltraps>

80109058 <vector244>:
.globl vector244
vector244:
  pushl $0
80109058:	6a 00                	push   $0x0
  pushl $244
8010905a:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010905f:	e9 c4 ef ff ff       	jmp    80108028 <alltraps>

80109064 <vector245>:
.globl vector245
vector245:
  pushl $0
80109064:	6a 00                	push   $0x0
  pushl $245
80109066:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010906b:	e9 b8 ef ff ff       	jmp    80108028 <alltraps>

80109070 <vector246>:
.globl vector246
vector246:
  pushl $0
80109070:	6a 00                	push   $0x0
  pushl $246
80109072:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80109077:	e9 ac ef ff ff       	jmp    80108028 <alltraps>

8010907c <vector247>:
.globl vector247
vector247:
  pushl $0
8010907c:	6a 00                	push   $0x0
  pushl $247
8010907e:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80109083:	e9 a0 ef ff ff       	jmp    80108028 <alltraps>

80109088 <vector248>:
.globl vector248
vector248:
  pushl $0
80109088:	6a 00                	push   $0x0
  pushl $248
8010908a:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010908f:	e9 94 ef ff ff       	jmp    80108028 <alltraps>

80109094 <vector249>:
.globl vector249
vector249:
  pushl $0
80109094:	6a 00                	push   $0x0
  pushl $249
80109096:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010909b:	e9 88 ef ff ff       	jmp    80108028 <alltraps>

801090a0 <vector250>:
.globl vector250
vector250:
  pushl $0
801090a0:	6a 00                	push   $0x0
  pushl $250
801090a2:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801090a7:	e9 7c ef ff ff       	jmp    80108028 <alltraps>

801090ac <vector251>:
.globl vector251
vector251:
  pushl $0
801090ac:	6a 00                	push   $0x0
  pushl $251
801090ae:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801090b3:	e9 70 ef ff ff       	jmp    80108028 <alltraps>

801090b8 <vector252>:
.globl vector252
vector252:
  pushl $0
801090b8:	6a 00                	push   $0x0
  pushl $252
801090ba:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801090bf:	e9 64 ef ff ff       	jmp    80108028 <alltraps>

801090c4 <vector253>:
.globl vector253
vector253:
  pushl $0
801090c4:	6a 00                	push   $0x0
  pushl $253
801090c6:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801090cb:	e9 58 ef ff ff       	jmp    80108028 <alltraps>

801090d0 <vector254>:
.globl vector254
vector254:
  pushl $0
801090d0:	6a 00                	push   $0x0
  pushl $254
801090d2:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801090d7:	e9 4c ef ff ff       	jmp    80108028 <alltraps>

801090dc <vector255>:
.globl vector255
vector255:
  pushl $0
801090dc:	6a 00                	push   $0x0
  pushl $255
801090de:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801090e3:	e9 40 ef ff ff       	jmp    80108028 <alltraps>

801090e8 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801090e8:	55                   	push   %ebp
801090e9:	89 e5                	mov    %esp,%ebp
801090eb:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801090ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801090f1:	83 e8 01             	sub    $0x1,%eax
801090f4:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801090f8:	8b 45 08             	mov    0x8(%ebp),%eax
801090fb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801090ff:	8b 45 08             	mov    0x8(%ebp),%eax
80109102:	c1 e8 10             	shr    $0x10,%eax
80109105:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80109109:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010910c:	0f 01 10             	lgdtl  (%eax)
}
8010910f:	90                   	nop
80109110:	c9                   	leave  
80109111:	c3                   	ret    

80109112 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80109112:	55                   	push   %ebp
80109113:	89 e5                	mov    %esp,%ebp
80109115:	83 ec 04             	sub    $0x4,%esp
80109118:	8b 45 08             	mov    0x8(%ebp),%eax
8010911b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010911f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109123:	0f 00 d8             	ltr    %ax
}
80109126:	90                   	nop
80109127:	c9                   	leave  
80109128:	c3                   	ret    

80109129 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80109129:	55                   	push   %ebp
8010912a:	89 e5                	mov    %esp,%ebp
8010912c:	83 ec 04             	sub    $0x4,%esp
8010912f:	8b 45 08             	mov    0x8(%ebp),%eax
80109132:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80109136:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010913a:	8e e8                	mov    %eax,%gs
}
8010913c:	90                   	nop
8010913d:	c9                   	leave  
8010913e:	c3                   	ret    

8010913f <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
8010913f:	55                   	push   %ebp
80109140:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80109142:	8b 45 08             	mov    0x8(%ebp),%eax
80109145:	0f 22 d8             	mov    %eax,%cr3
}
80109148:	90                   	nop
80109149:	5d                   	pop    %ebp
8010914a:	c3                   	ret    

8010914b <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
8010914b:	55                   	push   %ebp
8010914c:	89 e5                	mov    %esp,%ebp
8010914e:	8b 45 08             	mov    0x8(%ebp),%eax
80109151:	05 00 00 00 80       	add    $0x80000000,%eax
80109156:	5d                   	pop    %ebp
80109157:	c3                   	ret    

80109158 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80109158:	55                   	push   %ebp
80109159:	89 e5                	mov    %esp,%ebp
8010915b:	8b 45 08             	mov    0x8(%ebp),%eax
8010915e:	05 00 00 00 80       	add    $0x80000000,%eax
80109163:	5d                   	pop    %ebp
80109164:	c3                   	ret    

80109165 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80109165:	55                   	push   %ebp
80109166:	89 e5                	mov    %esp,%ebp
80109168:	53                   	push   %ebx
80109169:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
8010916c:	e8 f9 9e ff ff       	call   8010306a <cpunum>
80109171:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80109177:	05 80 43 11 80       	add    $0x80114380,%eax
8010917c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010917f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109182:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80109188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010918b:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80109191:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109194:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80109198:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010919b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010919f:	83 e2 f0             	and    $0xfffffff0,%edx
801091a2:	83 ca 0a             	or     $0xa,%edx
801091a5:	88 50 7d             	mov    %dl,0x7d(%eax)
801091a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091ab:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801091af:	83 ca 10             	or     $0x10,%edx
801091b2:	88 50 7d             	mov    %dl,0x7d(%eax)
801091b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091b8:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801091bc:	83 e2 9f             	and    $0xffffff9f,%edx
801091bf:	88 50 7d             	mov    %dl,0x7d(%eax)
801091c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091c5:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801091c9:	83 ca 80             	or     $0xffffff80,%edx
801091cc:	88 50 7d             	mov    %dl,0x7d(%eax)
801091cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091d2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801091d6:	83 ca 0f             	or     $0xf,%edx
801091d9:	88 50 7e             	mov    %dl,0x7e(%eax)
801091dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091df:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801091e3:	83 e2 ef             	and    $0xffffffef,%edx
801091e6:	88 50 7e             	mov    %dl,0x7e(%eax)
801091e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091ec:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801091f0:	83 e2 df             	and    $0xffffffdf,%edx
801091f3:	88 50 7e             	mov    %dl,0x7e(%eax)
801091f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091f9:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801091fd:	83 ca 40             	or     $0x40,%edx
80109200:	88 50 7e             	mov    %dl,0x7e(%eax)
80109203:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109206:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010920a:	83 ca 80             	or     $0xffffff80,%edx
8010920d:	88 50 7e             	mov    %dl,0x7e(%eax)
80109210:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109213:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80109217:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010921a:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80109221:	ff ff 
80109223:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109226:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010922d:	00 00 
8010922f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109232:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80109239:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010923c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80109243:	83 e2 f0             	and    $0xfffffff0,%edx
80109246:	83 ca 02             	or     $0x2,%edx
80109249:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010924f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109252:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80109259:	83 ca 10             	or     $0x10,%edx
8010925c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80109262:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109265:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010926c:	83 e2 9f             	and    $0xffffff9f,%edx
8010926f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80109275:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109278:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010927f:	83 ca 80             	or     $0xffffff80,%edx
80109282:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80109288:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010928b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80109292:	83 ca 0f             	or     $0xf,%edx
80109295:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010929b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010929e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801092a5:	83 e2 ef             	and    $0xffffffef,%edx
801092a8:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801092ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092b1:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801092b8:	83 e2 df             	and    $0xffffffdf,%edx
801092bb:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801092c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092c4:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801092cb:	83 ca 40             	or     $0x40,%edx
801092ce:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801092d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092d7:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801092de:	83 ca 80             	or     $0xffffff80,%edx
801092e1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801092e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092ea:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801092f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092f4:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801092fb:	ff ff 
801092fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109300:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80109307:	00 00 
80109309:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010930c:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80109313:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109316:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010931d:	83 e2 f0             	and    $0xfffffff0,%edx
80109320:	83 ca 0a             	or     $0xa,%edx
80109323:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80109329:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010932c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80109333:	83 ca 10             	or     $0x10,%edx
80109336:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010933c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010933f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80109346:	83 ca 60             	or     $0x60,%edx
80109349:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010934f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109352:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80109359:	83 ca 80             	or     $0xffffff80,%edx
8010935c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80109362:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109365:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010936c:	83 ca 0f             	or     $0xf,%edx
8010936f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80109375:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109378:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010937f:	83 e2 ef             	and    $0xffffffef,%edx
80109382:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80109388:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010938b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80109392:	83 e2 df             	and    $0xffffffdf,%edx
80109395:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010939b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010939e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801093a5:	83 ca 40             	or     $0x40,%edx
801093a8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801093ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093b1:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801093b8:	83 ca 80             	or     $0xffffff80,%edx
801093bb:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801093c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093c4:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801093cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093ce:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
801093d5:	ff ff 
801093d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093da:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
801093e1:	00 00 
801093e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093e6:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
801093ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093f0:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801093f7:	83 e2 f0             	and    $0xfffffff0,%edx
801093fa:	83 ca 02             	or     $0x2,%edx
801093fd:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80109403:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109406:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010940d:	83 ca 10             	or     $0x10,%edx
80109410:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80109416:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109419:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80109420:	83 ca 60             	or     $0x60,%edx
80109423:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80109429:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010942c:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80109433:	83 ca 80             	or     $0xffffff80,%edx
80109436:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010943c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010943f:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80109446:	83 ca 0f             	or     $0xf,%edx
80109449:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010944f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109452:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80109459:	83 e2 ef             	and    $0xffffffef,%edx
8010945c:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80109462:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109465:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010946c:	83 e2 df             	and    $0xffffffdf,%edx
8010946f:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80109475:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109478:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010947f:	83 ca 40             	or     $0x40,%edx
80109482:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80109488:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010948b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80109492:	83 ca 80             	or     $0xffffff80,%edx
80109495:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010949b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010949e:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801094a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094a8:	05 b4 00 00 00       	add    $0xb4,%eax
801094ad:	89 c3                	mov    %eax,%ebx
801094af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094b2:	05 b4 00 00 00       	add    $0xb4,%eax
801094b7:	c1 e8 10             	shr    $0x10,%eax
801094ba:	89 c2                	mov    %eax,%edx
801094bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094bf:	05 b4 00 00 00       	add    $0xb4,%eax
801094c4:	c1 e8 18             	shr    $0x18,%eax
801094c7:	89 c1                	mov    %eax,%ecx
801094c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094cc:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
801094d3:	00 00 
801094d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094d8:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
801094df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094e2:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
801094e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094eb:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801094f2:	83 e2 f0             	and    $0xfffffff0,%edx
801094f5:	83 ca 02             	or     $0x2,%edx
801094f8:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801094fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109501:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80109508:	83 ca 10             	or     $0x10,%edx
8010950b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80109511:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109514:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010951b:	83 e2 9f             	and    $0xffffff9f,%edx
8010951e:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80109524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109527:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010952e:	83 ca 80             	or     $0xffffff80,%edx
80109531:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80109537:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010953a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80109541:	83 e2 f0             	and    $0xfffffff0,%edx
80109544:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010954a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010954d:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80109554:	83 e2 ef             	and    $0xffffffef,%edx
80109557:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010955d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109560:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80109567:	83 e2 df             	and    $0xffffffdf,%edx
8010956a:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80109570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109573:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010957a:	83 ca 40             	or     $0x40,%edx
8010957d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80109583:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109586:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010958d:	83 ca 80             	or     $0xffffff80,%edx
80109590:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80109596:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109599:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
8010959f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095a2:	83 c0 70             	add    $0x70,%eax
801095a5:	83 ec 08             	sub    $0x8,%esp
801095a8:	6a 38                	push   $0x38
801095aa:	50                   	push   %eax
801095ab:	e8 38 fb ff ff       	call   801090e8 <lgdt>
801095b0:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
801095b3:	83 ec 0c             	sub    $0xc,%esp
801095b6:	6a 18                	push   $0x18
801095b8:	e8 6c fb ff ff       	call   80109129 <loadgs>
801095bd:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
801095c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095c3:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
801095c9:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801095d0:	00 00 00 00 
}
801095d4:	90                   	nop
801095d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801095d8:	c9                   	leave  
801095d9:	c3                   	ret    

801095da <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801095da:	55                   	push   %ebp
801095db:	89 e5                	mov    %esp,%ebp
801095dd:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801095e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801095e3:	c1 e8 16             	shr    $0x16,%eax
801095e6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801095ed:	8b 45 08             	mov    0x8(%ebp),%eax
801095f0:	01 d0                	add    %edx,%eax
801095f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801095f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095f8:	8b 00                	mov    (%eax),%eax
801095fa:	83 e0 01             	and    $0x1,%eax
801095fd:	85 c0                	test   %eax,%eax
801095ff:	74 18                	je     80109619 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80109601:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109604:	8b 00                	mov    (%eax),%eax
80109606:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010960b:	50                   	push   %eax
8010960c:	e8 47 fb ff ff       	call   80109158 <p2v>
80109611:	83 c4 04             	add    $0x4,%esp
80109614:	89 45 f4             	mov    %eax,-0xc(%ebp)
80109617:	eb 48                	jmp    80109661 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80109619:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010961d:	74 0e                	je     8010962d <walkpgdir+0x53>
8010961f:	e8 e0 96 ff ff       	call   80102d04 <kalloc>
80109624:	89 45 f4             	mov    %eax,-0xc(%ebp)
80109627:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010962b:	75 07                	jne    80109634 <walkpgdir+0x5a>
      return 0;
8010962d:	b8 00 00 00 00       	mov    $0x0,%eax
80109632:	eb 44                	jmp    80109678 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80109634:	83 ec 04             	sub    $0x4,%esp
80109637:	68 00 10 00 00       	push   $0x1000
8010963c:	6a 00                	push   $0x0
8010963e:	ff 75 f4             	pushl  -0xc(%ebp)
80109641:	e8 80 d4 ff ff       	call   80106ac6 <memset>
80109646:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80109649:	83 ec 0c             	sub    $0xc,%esp
8010964c:	ff 75 f4             	pushl  -0xc(%ebp)
8010964f:	e8 f7 fa ff ff       	call   8010914b <v2p>
80109654:	83 c4 10             	add    $0x10,%esp
80109657:	83 c8 07             	or     $0x7,%eax
8010965a:	89 c2                	mov    %eax,%edx
8010965c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010965f:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80109661:	8b 45 0c             	mov    0xc(%ebp),%eax
80109664:	c1 e8 0c             	shr    $0xc,%eax
80109667:	25 ff 03 00 00       	and    $0x3ff,%eax
8010966c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109673:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109676:	01 d0                	add    %edx,%eax
}
80109678:	c9                   	leave  
80109679:	c3                   	ret    

8010967a <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010967a:	55                   	push   %ebp
8010967b:	89 e5                	mov    %esp,%ebp
8010967d:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80109680:	8b 45 0c             	mov    0xc(%ebp),%eax
80109683:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109688:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010968b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010968e:	8b 45 10             	mov    0x10(%ebp),%eax
80109691:	01 d0                	add    %edx,%eax
80109693:	83 e8 01             	sub    $0x1,%eax
80109696:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010969b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010969e:	83 ec 04             	sub    $0x4,%esp
801096a1:	6a 01                	push   $0x1
801096a3:	ff 75 f4             	pushl  -0xc(%ebp)
801096a6:	ff 75 08             	pushl  0x8(%ebp)
801096a9:	e8 2c ff ff ff       	call   801095da <walkpgdir>
801096ae:	83 c4 10             	add    $0x10,%esp
801096b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
801096b4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801096b8:	75 07                	jne    801096c1 <mappages+0x47>
      return -1;
801096ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801096bf:	eb 47                	jmp    80109708 <mappages+0x8e>
    if(*pte & PTE_P)
801096c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801096c4:	8b 00                	mov    (%eax),%eax
801096c6:	83 e0 01             	and    $0x1,%eax
801096c9:	85 c0                	test   %eax,%eax
801096cb:	74 0d                	je     801096da <mappages+0x60>
      panic("remap");
801096cd:	83 ec 0c             	sub    $0xc,%esp
801096d0:	68 e0 a8 10 80       	push   $0x8010a8e0
801096d5:	e8 8c 6e ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
801096da:	8b 45 18             	mov    0x18(%ebp),%eax
801096dd:	0b 45 14             	or     0x14(%ebp),%eax
801096e0:	83 c8 01             	or     $0x1,%eax
801096e3:	89 c2                	mov    %eax,%edx
801096e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801096e8:	89 10                	mov    %edx,(%eax)
    if(a == last)
801096ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096ed:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801096f0:	74 10                	je     80109702 <mappages+0x88>
      break;
    a += PGSIZE;
801096f2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801096f9:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80109700:	eb 9c                	jmp    8010969e <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80109702:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80109703:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109708:	c9                   	leave  
80109709:	c3                   	ret    

8010970a <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
8010970a:	55                   	push   %ebp
8010970b:	89 e5                	mov    %esp,%ebp
8010970d:	53                   	push   %ebx
8010970e:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80109711:	e8 ee 95 ff ff       	call   80102d04 <kalloc>
80109716:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109719:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010971d:	75 0a                	jne    80109729 <setupkvm+0x1f>
    return 0;
8010971f:	b8 00 00 00 00       	mov    $0x0,%eax
80109724:	e9 8e 00 00 00       	jmp    801097b7 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80109729:	83 ec 04             	sub    $0x4,%esp
8010972c:	68 00 10 00 00       	push   $0x1000
80109731:	6a 00                	push   $0x0
80109733:	ff 75 f0             	pushl  -0x10(%ebp)
80109736:	e8 8b d3 ff ff       	call   80106ac6 <memset>
8010973b:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
8010973e:	83 ec 0c             	sub    $0xc,%esp
80109741:	68 00 00 00 0e       	push   $0xe000000
80109746:	e8 0d fa ff ff       	call   80109158 <p2v>
8010974b:	83 c4 10             	add    $0x10,%esp
8010974e:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80109753:	76 0d                	jbe    80109762 <setupkvm+0x58>
    panic("PHYSTOP too high");
80109755:	83 ec 0c             	sub    $0xc,%esp
80109758:	68 e6 a8 10 80       	push   $0x8010a8e6
8010975d:	e8 04 6e ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80109762:	c7 45 f4 c0 d4 10 80 	movl   $0x8010d4c0,-0xc(%ebp)
80109769:	eb 40                	jmp    801097ab <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
8010976b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010976e:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80109771:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109774:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80109777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010977a:	8b 58 08             	mov    0x8(%eax),%ebx
8010977d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109780:	8b 40 04             	mov    0x4(%eax),%eax
80109783:	29 c3                	sub    %eax,%ebx
80109785:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109788:	8b 00                	mov    (%eax),%eax
8010978a:	83 ec 0c             	sub    $0xc,%esp
8010978d:	51                   	push   %ecx
8010978e:	52                   	push   %edx
8010978f:	53                   	push   %ebx
80109790:	50                   	push   %eax
80109791:	ff 75 f0             	pushl  -0x10(%ebp)
80109794:	e8 e1 fe ff ff       	call   8010967a <mappages>
80109799:	83 c4 20             	add    $0x20,%esp
8010979c:	85 c0                	test   %eax,%eax
8010979e:	79 07                	jns    801097a7 <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
801097a0:	b8 00 00 00 00       	mov    $0x0,%eax
801097a5:	eb 10                	jmp    801097b7 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801097a7:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801097ab:	81 7d f4 00 d5 10 80 	cmpl   $0x8010d500,-0xc(%ebp)
801097b2:	72 b7                	jb     8010976b <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
801097b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801097b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801097ba:	c9                   	leave  
801097bb:	c3                   	ret    

801097bc <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801097bc:	55                   	push   %ebp
801097bd:	89 e5                	mov    %esp,%ebp
801097bf:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801097c2:	e8 43 ff ff ff       	call   8010970a <setupkvm>
801097c7:	a3 58 79 11 80       	mov    %eax,0x80117958
  switchkvm();
801097cc:	e8 03 00 00 00       	call   801097d4 <switchkvm>
}
801097d1:	90                   	nop
801097d2:	c9                   	leave  
801097d3:	c3                   	ret    

801097d4 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801097d4:	55                   	push   %ebp
801097d5:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
801097d7:	a1 58 79 11 80       	mov    0x80117958,%eax
801097dc:	50                   	push   %eax
801097dd:	e8 69 f9 ff ff       	call   8010914b <v2p>
801097e2:	83 c4 04             	add    $0x4,%esp
801097e5:	50                   	push   %eax
801097e6:	e8 54 f9 ff ff       	call   8010913f <lcr3>
801097eb:	83 c4 04             	add    $0x4,%esp
}
801097ee:	90                   	nop
801097ef:	c9                   	leave  
801097f0:	c3                   	ret    

801097f1 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801097f1:	55                   	push   %ebp
801097f2:	89 e5                	mov    %esp,%ebp
801097f4:	56                   	push   %esi
801097f5:	53                   	push   %ebx
  pushcli();
801097f6:	e8 c5 d1 ff ff       	call   801069c0 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
801097fb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109801:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80109808:	83 c2 08             	add    $0x8,%edx
8010980b:	89 d6                	mov    %edx,%esi
8010980d:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80109814:	83 c2 08             	add    $0x8,%edx
80109817:	c1 ea 10             	shr    $0x10,%edx
8010981a:	89 d3                	mov    %edx,%ebx
8010981c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80109823:	83 c2 08             	add    $0x8,%edx
80109826:	c1 ea 18             	shr    $0x18,%edx
80109829:	89 d1                	mov    %edx,%ecx
8010982b:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80109832:	67 00 
80109834:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
8010983b:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80109841:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80109848:	83 e2 f0             	and    $0xfffffff0,%edx
8010984b:	83 ca 09             	or     $0x9,%edx
8010984e:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109854:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010985b:	83 ca 10             	or     $0x10,%edx
8010985e:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109864:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010986b:	83 e2 9f             	and    $0xffffff9f,%edx
8010986e:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109874:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010987b:	83 ca 80             	or     $0xffffff80,%edx
8010987e:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109884:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
8010988b:	83 e2 f0             	and    $0xfffffff0,%edx
8010988e:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109894:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
8010989b:	83 e2 ef             	and    $0xffffffef,%edx
8010989e:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801098a4:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801098ab:	83 e2 df             	and    $0xffffffdf,%edx
801098ae:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801098b4:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801098bb:	83 ca 40             	or     $0x40,%edx
801098be:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801098c4:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801098cb:	83 e2 7f             	and    $0x7f,%edx
801098ce:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801098d4:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
801098da:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801098e0:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801098e7:	83 e2 ef             	and    $0xffffffef,%edx
801098ea:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
801098f0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801098f6:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
801098fc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109902:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109909:	8b 52 08             	mov    0x8(%edx),%edx
8010990c:	81 c2 00 10 00 00    	add    $0x1000,%edx
80109912:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80109915:	83 ec 0c             	sub    $0xc,%esp
80109918:	6a 30                	push   $0x30
8010991a:	e8 f3 f7 ff ff       	call   80109112 <ltr>
8010991f:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80109922:	8b 45 08             	mov    0x8(%ebp),%eax
80109925:	8b 40 04             	mov    0x4(%eax),%eax
80109928:	85 c0                	test   %eax,%eax
8010992a:	75 0d                	jne    80109939 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
8010992c:	83 ec 0c             	sub    $0xc,%esp
8010992f:	68 f7 a8 10 80       	push   $0x8010a8f7
80109934:	e8 2d 6c ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80109939:	8b 45 08             	mov    0x8(%ebp),%eax
8010993c:	8b 40 04             	mov    0x4(%eax),%eax
8010993f:	83 ec 0c             	sub    $0xc,%esp
80109942:	50                   	push   %eax
80109943:	e8 03 f8 ff ff       	call   8010914b <v2p>
80109948:	83 c4 10             	add    $0x10,%esp
8010994b:	83 ec 0c             	sub    $0xc,%esp
8010994e:	50                   	push   %eax
8010994f:	e8 eb f7 ff ff       	call   8010913f <lcr3>
80109954:	83 c4 10             	add    $0x10,%esp
  popcli();
80109957:	e8 a9 d0 ff ff       	call   80106a05 <popcli>
}
8010995c:	90                   	nop
8010995d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80109960:	5b                   	pop    %ebx
80109961:	5e                   	pop    %esi
80109962:	5d                   	pop    %ebp
80109963:	c3                   	ret    

80109964 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80109964:	55                   	push   %ebp
80109965:	89 e5                	mov    %esp,%ebp
80109967:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
8010996a:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80109971:	76 0d                	jbe    80109980 <inituvm+0x1c>
    panic("inituvm: more than a page");
80109973:	83 ec 0c             	sub    $0xc,%esp
80109976:	68 0b a9 10 80       	push   $0x8010a90b
8010997b:	e8 e6 6b ff ff       	call   80100566 <panic>
  mem = kalloc();
80109980:	e8 7f 93 ff ff       	call   80102d04 <kalloc>
80109985:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80109988:	83 ec 04             	sub    $0x4,%esp
8010998b:	68 00 10 00 00       	push   $0x1000
80109990:	6a 00                	push   $0x0
80109992:	ff 75 f4             	pushl  -0xc(%ebp)
80109995:	e8 2c d1 ff ff       	call   80106ac6 <memset>
8010999a:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010999d:	83 ec 0c             	sub    $0xc,%esp
801099a0:	ff 75 f4             	pushl  -0xc(%ebp)
801099a3:	e8 a3 f7 ff ff       	call   8010914b <v2p>
801099a8:	83 c4 10             	add    $0x10,%esp
801099ab:	83 ec 0c             	sub    $0xc,%esp
801099ae:	6a 06                	push   $0x6
801099b0:	50                   	push   %eax
801099b1:	68 00 10 00 00       	push   $0x1000
801099b6:	6a 00                	push   $0x0
801099b8:	ff 75 08             	pushl  0x8(%ebp)
801099bb:	e8 ba fc ff ff       	call   8010967a <mappages>
801099c0:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801099c3:	83 ec 04             	sub    $0x4,%esp
801099c6:	ff 75 10             	pushl  0x10(%ebp)
801099c9:	ff 75 0c             	pushl  0xc(%ebp)
801099cc:	ff 75 f4             	pushl  -0xc(%ebp)
801099cf:	e8 b1 d1 ff ff       	call   80106b85 <memmove>
801099d4:	83 c4 10             	add    $0x10,%esp
}
801099d7:	90                   	nop
801099d8:	c9                   	leave  
801099d9:	c3                   	ret    

801099da <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801099da:	55                   	push   %ebp
801099db:	89 e5                	mov    %esp,%ebp
801099dd:	53                   	push   %ebx
801099de:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801099e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801099e4:	25 ff 0f 00 00       	and    $0xfff,%eax
801099e9:	85 c0                	test   %eax,%eax
801099eb:	74 0d                	je     801099fa <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
801099ed:	83 ec 0c             	sub    $0xc,%esp
801099f0:	68 28 a9 10 80       	push   $0x8010a928
801099f5:	e8 6c 6b ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801099fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109a01:	e9 95 00 00 00       	jmp    80109a9b <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80109a06:	8b 55 0c             	mov    0xc(%ebp),%edx
80109a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a0c:	01 d0                	add    %edx,%eax
80109a0e:	83 ec 04             	sub    $0x4,%esp
80109a11:	6a 00                	push   $0x0
80109a13:	50                   	push   %eax
80109a14:	ff 75 08             	pushl  0x8(%ebp)
80109a17:	e8 be fb ff ff       	call   801095da <walkpgdir>
80109a1c:	83 c4 10             	add    $0x10,%esp
80109a1f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109a22:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109a26:	75 0d                	jne    80109a35 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80109a28:	83 ec 0c             	sub    $0xc,%esp
80109a2b:	68 4b a9 10 80       	push   $0x8010a94b
80109a30:	e8 31 6b ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80109a35:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109a38:	8b 00                	mov    (%eax),%eax
80109a3a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109a3f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80109a42:	8b 45 18             	mov    0x18(%ebp),%eax
80109a45:	2b 45 f4             	sub    -0xc(%ebp),%eax
80109a48:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80109a4d:	77 0b                	ja     80109a5a <loaduvm+0x80>
      n = sz - i;
80109a4f:	8b 45 18             	mov    0x18(%ebp),%eax
80109a52:	2b 45 f4             	sub    -0xc(%ebp),%eax
80109a55:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109a58:	eb 07                	jmp    80109a61 <loaduvm+0x87>
    else
      n = PGSIZE;
80109a5a:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80109a61:	8b 55 14             	mov    0x14(%ebp),%edx
80109a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a67:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80109a6a:	83 ec 0c             	sub    $0xc,%esp
80109a6d:	ff 75 e8             	pushl  -0x18(%ebp)
80109a70:	e8 e3 f6 ff ff       	call   80109158 <p2v>
80109a75:	83 c4 10             	add    $0x10,%esp
80109a78:	ff 75 f0             	pushl  -0x10(%ebp)
80109a7b:	53                   	push   %ebx
80109a7c:	50                   	push   %eax
80109a7d:	ff 75 10             	pushl  0x10(%ebp)
80109a80:	e8 f1 84 ff ff       	call   80101f76 <readi>
80109a85:	83 c4 10             	add    $0x10,%esp
80109a88:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80109a8b:	74 07                	je     80109a94 <loaduvm+0xba>
      return -1;
80109a8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109a92:	eb 18                	jmp    80109aac <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80109a94:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a9e:	3b 45 18             	cmp    0x18(%ebp),%eax
80109aa1:	0f 82 5f ff ff ff    	jb     80109a06 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80109aa7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109aac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109aaf:	c9                   	leave  
80109ab0:	c3                   	ret    

80109ab1 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80109ab1:	55                   	push   %ebp
80109ab2:	89 e5                	mov    %esp,%ebp
80109ab4:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80109ab7:	8b 45 10             	mov    0x10(%ebp),%eax
80109aba:	85 c0                	test   %eax,%eax
80109abc:	79 0a                	jns    80109ac8 <allocuvm+0x17>
    return 0;
80109abe:	b8 00 00 00 00       	mov    $0x0,%eax
80109ac3:	e9 b0 00 00 00       	jmp    80109b78 <allocuvm+0xc7>
  if(newsz < oldsz)
80109ac8:	8b 45 10             	mov    0x10(%ebp),%eax
80109acb:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109ace:	73 08                	jae    80109ad8 <allocuvm+0x27>
    return oldsz;
80109ad0:	8b 45 0c             	mov    0xc(%ebp),%eax
80109ad3:	e9 a0 00 00 00       	jmp    80109b78 <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80109ad8:	8b 45 0c             	mov    0xc(%ebp),%eax
80109adb:	05 ff 0f 00 00       	add    $0xfff,%eax
80109ae0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109ae5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80109ae8:	eb 7f                	jmp    80109b69 <allocuvm+0xb8>
    mem = kalloc();
80109aea:	e8 15 92 ff ff       	call   80102d04 <kalloc>
80109aef:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80109af2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109af6:	75 2b                	jne    80109b23 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80109af8:	83 ec 0c             	sub    $0xc,%esp
80109afb:	68 69 a9 10 80       	push   $0x8010a969
80109b00:	e8 c1 68 ff ff       	call   801003c6 <cprintf>
80109b05:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80109b08:	83 ec 04             	sub    $0x4,%esp
80109b0b:	ff 75 0c             	pushl  0xc(%ebp)
80109b0e:	ff 75 10             	pushl  0x10(%ebp)
80109b11:	ff 75 08             	pushl  0x8(%ebp)
80109b14:	e8 61 00 00 00       	call   80109b7a <deallocuvm>
80109b19:	83 c4 10             	add    $0x10,%esp
      return 0;
80109b1c:	b8 00 00 00 00       	mov    $0x0,%eax
80109b21:	eb 55                	jmp    80109b78 <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
80109b23:	83 ec 04             	sub    $0x4,%esp
80109b26:	68 00 10 00 00       	push   $0x1000
80109b2b:	6a 00                	push   $0x0
80109b2d:	ff 75 f0             	pushl  -0x10(%ebp)
80109b30:	e8 91 cf ff ff       	call   80106ac6 <memset>
80109b35:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80109b38:	83 ec 0c             	sub    $0xc,%esp
80109b3b:	ff 75 f0             	pushl  -0x10(%ebp)
80109b3e:	e8 08 f6 ff ff       	call   8010914b <v2p>
80109b43:	83 c4 10             	add    $0x10,%esp
80109b46:	89 c2                	mov    %eax,%edx
80109b48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b4b:	83 ec 0c             	sub    $0xc,%esp
80109b4e:	6a 06                	push   $0x6
80109b50:	52                   	push   %edx
80109b51:	68 00 10 00 00       	push   $0x1000
80109b56:	50                   	push   %eax
80109b57:	ff 75 08             	pushl  0x8(%ebp)
80109b5a:	e8 1b fb ff ff       	call   8010967a <mappages>
80109b5f:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80109b62:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b6c:	3b 45 10             	cmp    0x10(%ebp),%eax
80109b6f:	0f 82 75 ff ff ff    	jb     80109aea <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80109b75:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109b78:	c9                   	leave  
80109b79:	c3                   	ret    

80109b7a <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80109b7a:	55                   	push   %ebp
80109b7b:	89 e5                	mov    %esp,%ebp
80109b7d:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80109b80:	8b 45 10             	mov    0x10(%ebp),%eax
80109b83:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109b86:	72 08                	jb     80109b90 <deallocuvm+0x16>
    return oldsz;
80109b88:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b8b:	e9 a5 00 00 00       	jmp    80109c35 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80109b90:	8b 45 10             	mov    0x10(%ebp),%eax
80109b93:	05 ff 0f 00 00       	add    $0xfff,%eax
80109b98:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109b9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80109ba0:	e9 81 00 00 00       	jmp    80109c26 <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80109ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ba8:	83 ec 04             	sub    $0x4,%esp
80109bab:	6a 00                	push   $0x0
80109bad:	50                   	push   %eax
80109bae:	ff 75 08             	pushl  0x8(%ebp)
80109bb1:	e8 24 fa ff ff       	call   801095da <walkpgdir>
80109bb6:	83 c4 10             	add    $0x10,%esp
80109bb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80109bbc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109bc0:	75 09                	jne    80109bcb <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80109bc2:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80109bc9:	eb 54                	jmp    80109c1f <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
80109bcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bce:	8b 00                	mov    (%eax),%eax
80109bd0:	83 e0 01             	and    $0x1,%eax
80109bd3:	85 c0                	test   %eax,%eax
80109bd5:	74 48                	je     80109c1f <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
80109bd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bda:	8b 00                	mov    (%eax),%eax
80109bdc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109be1:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80109be4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109be8:	75 0d                	jne    80109bf7 <deallocuvm+0x7d>
        panic("kfree");
80109bea:	83 ec 0c             	sub    $0xc,%esp
80109bed:	68 81 a9 10 80       	push   $0x8010a981
80109bf2:	e8 6f 69 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
80109bf7:	83 ec 0c             	sub    $0xc,%esp
80109bfa:	ff 75 ec             	pushl  -0x14(%ebp)
80109bfd:	e8 56 f5 ff ff       	call   80109158 <p2v>
80109c02:	83 c4 10             	add    $0x10,%esp
80109c05:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80109c08:	83 ec 0c             	sub    $0xc,%esp
80109c0b:	ff 75 e8             	pushl  -0x18(%ebp)
80109c0e:	e8 54 90 ff ff       	call   80102c67 <kfree>
80109c13:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80109c16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c19:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80109c1f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c29:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109c2c:	0f 82 73 ff ff ff    	jb     80109ba5 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80109c32:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109c35:	c9                   	leave  
80109c36:	c3                   	ret    

80109c37 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80109c37:	55                   	push   %ebp
80109c38:	89 e5                	mov    %esp,%ebp
80109c3a:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80109c3d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80109c41:	75 0d                	jne    80109c50 <freevm+0x19>
    panic("freevm: no pgdir");
80109c43:	83 ec 0c             	sub    $0xc,%esp
80109c46:	68 87 a9 10 80       	push   $0x8010a987
80109c4b:	e8 16 69 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80109c50:	83 ec 04             	sub    $0x4,%esp
80109c53:	6a 00                	push   $0x0
80109c55:	68 00 00 00 80       	push   $0x80000000
80109c5a:	ff 75 08             	pushl  0x8(%ebp)
80109c5d:	e8 18 ff ff ff       	call   80109b7a <deallocuvm>
80109c62:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80109c65:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109c6c:	eb 4f                	jmp    80109cbd <freevm+0x86>
    if(pgdir[i] & PTE_P){
80109c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c71:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109c78:	8b 45 08             	mov    0x8(%ebp),%eax
80109c7b:	01 d0                	add    %edx,%eax
80109c7d:	8b 00                	mov    (%eax),%eax
80109c7f:	83 e0 01             	and    $0x1,%eax
80109c82:	85 c0                	test   %eax,%eax
80109c84:	74 33                	je     80109cb9 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80109c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c89:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109c90:	8b 45 08             	mov    0x8(%ebp),%eax
80109c93:	01 d0                	add    %edx,%eax
80109c95:	8b 00                	mov    (%eax),%eax
80109c97:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109c9c:	83 ec 0c             	sub    $0xc,%esp
80109c9f:	50                   	push   %eax
80109ca0:	e8 b3 f4 ff ff       	call   80109158 <p2v>
80109ca5:	83 c4 10             	add    $0x10,%esp
80109ca8:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80109cab:	83 ec 0c             	sub    $0xc,%esp
80109cae:	ff 75 f0             	pushl  -0x10(%ebp)
80109cb1:	e8 b1 8f ff ff       	call   80102c67 <kfree>
80109cb6:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80109cb9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109cbd:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80109cc4:	76 a8                	jbe    80109c6e <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80109cc6:	83 ec 0c             	sub    $0xc,%esp
80109cc9:	ff 75 08             	pushl  0x8(%ebp)
80109ccc:	e8 96 8f ff ff       	call   80102c67 <kfree>
80109cd1:	83 c4 10             	add    $0x10,%esp
}
80109cd4:	90                   	nop
80109cd5:	c9                   	leave  
80109cd6:	c3                   	ret    

80109cd7 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80109cd7:	55                   	push   %ebp
80109cd8:	89 e5                	mov    %esp,%ebp
80109cda:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109cdd:	83 ec 04             	sub    $0x4,%esp
80109ce0:	6a 00                	push   $0x0
80109ce2:	ff 75 0c             	pushl  0xc(%ebp)
80109ce5:	ff 75 08             	pushl  0x8(%ebp)
80109ce8:	e8 ed f8 ff ff       	call   801095da <walkpgdir>
80109ced:	83 c4 10             	add    $0x10,%esp
80109cf0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80109cf3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109cf7:	75 0d                	jne    80109d06 <clearpteu+0x2f>
    panic("clearpteu");
80109cf9:	83 ec 0c             	sub    $0xc,%esp
80109cfc:	68 98 a9 10 80       	push   $0x8010a998
80109d01:	e8 60 68 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
80109d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d09:	8b 00                	mov    (%eax),%eax
80109d0b:	83 e0 fb             	and    $0xfffffffb,%eax
80109d0e:	89 c2                	mov    %eax,%edx
80109d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d13:	89 10                	mov    %edx,(%eax)
}
80109d15:	90                   	nop
80109d16:	c9                   	leave  
80109d17:	c3                   	ret    

80109d18 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80109d18:	55                   	push   %ebp
80109d19:	89 e5                	mov    %esp,%ebp
80109d1b:	53                   	push   %ebx
80109d1c:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80109d1f:	e8 e6 f9 ff ff       	call   8010970a <setupkvm>
80109d24:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109d27:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109d2b:	75 0a                	jne    80109d37 <copyuvm+0x1f>
    return 0;
80109d2d:	b8 00 00 00 00       	mov    $0x0,%eax
80109d32:	e9 f8 00 00 00       	jmp    80109e2f <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
80109d37:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109d3e:	e9 c4 00 00 00       	jmp    80109e07 <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80109d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d46:	83 ec 04             	sub    $0x4,%esp
80109d49:	6a 00                	push   $0x0
80109d4b:	50                   	push   %eax
80109d4c:	ff 75 08             	pushl  0x8(%ebp)
80109d4f:	e8 86 f8 ff ff       	call   801095da <walkpgdir>
80109d54:	83 c4 10             	add    $0x10,%esp
80109d57:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109d5a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109d5e:	75 0d                	jne    80109d6d <copyuvm+0x55>
      panic("copyuvm: pte should exist");
80109d60:	83 ec 0c             	sub    $0xc,%esp
80109d63:	68 a2 a9 10 80       	push   $0x8010a9a2
80109d68:	e8 f9 67 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
80109d6d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d70:	8b 00                	mov    (%eax),%eax
80109d72:	83 e0 01             	and    $0x1,%eax
80109d75:	85 c0                	test   %eax,%eax
80109d77:	75 0d                	jne    80109d86 <copyuvm+0x6e>
      panic("copyuvm: page not present");
80109d79:	83 ec 0c             	sub    $0xc,%esp
80109d7c:	68 bc a9 10 80       	push   $0x8010a9bc
80109d81:	e8 e0 67 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80109d86:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d89:	8b 00                	mov    (%eax),%eax
80109d8b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109d90:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80109d93:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d96:	8b 00                	mov    (%eax),%eax
80109d98:	25 ff 0f 00 00       	and    $0xfff,%eax
80109d9d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80109da0:	e8 5f 8f ff ff       	call   80102d04 <kalloc>
80109da5:	89 45 e0             	mov    %eax,-0x20(%ebp)
80109da8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80109dac:	74 6a                	je     80109e18 <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80109dae:	83 ec 0c             	sub    $0xc,%esp
80109db1:	ff 75 e8             	pushl  -0x18(%ebp)
80109db4:	e8 9f f3 ff ff       	call   80109158 <p2v>
80109db9:	83 c4 10             	add    $0x10,%esp
80109dbc:	83 ec 04             	sub    $0x4,%esp
80109dbf:	68 00 10 00 00       	push   $0x1000
80109dc4:	50                   	push   %eax
80109dc5:	ff 75 e0             	pushl  -0x20(%ebp)
80109dc8:	e8 b8 cd ff ff       	call   80106b85 <memmove>
80109dcd:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80109dd0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80109dd3:	83 ec 0c             	sub    $0xc,%esp
80109dd6:	ff 75 e0             	pushl  -0x20(%ebp)
80109dd9:	e8 6d f3 ff ff       	call   8010914b <v2p>
80109dde:	83 c4 10             	add    $0x10,%esp
80109de1:	89 c2                	mov    %eax,%edx
80109de3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109de6:	83 ec 0c             	sub    $0xc,%esp
80109de9:	53                   	push   %ebx
80109dea:	52                   	push   %edx
80109deb:	68 00 10 00 00       	push   $0x1000
80109df0:	50                   	push   %eax
80109df1:	ff 75 f0             	pushl  -0x10(%ebp)
80109df4:	e8 81 f8 ff ff       	call   8010967a <mappages>
80109df9:	83 c4 20             	add    $0x20,%esp
80109dfc:	85 c0                	test   %eax,%eax
80109dfe:	78 1b                	js     80109e1b <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80109e00:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e0a:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109e0d:	0f 82 30 ff ff ff    	jb     80109d43 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80109e13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e16:	eb 17                	jmp    80109e2f <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80109e18:	90                   	nop
80109e19:	eb 01                	jmp    80109e1c <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
80109e1b:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80109e1c:	83 ec 0c             	sub    $0xc,%esp
80109e1f:	ff 75 f0             	pushl  -0x10(%ebp)
80109e22:	e8 10 fe ff ff       	call   80109c37 <freevm>
80109e27:	83 c4 10             	add    $0x10,%esp
  return 0;
80109e2a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109e2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109e32:	c9                   	leave  
80109e33:	c3                   	ret    

80109e34 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80109e34:	55                   	push   %ebp
80109e35:	89 e5                	mov    %esp,%ebp
80109e37:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109e3a:	83 ec 04             	sub    $0x4,%esp
80109e3d:	6a 00                	push   $0x0
80109e3f:	ff 75 0c             	pushl  0xc(%ebp)
80109e42:	ff 75 08             	pushl  0x8(%ebp)
80109e45:	e8 90 f7 ff ff       	call   801095da <walkpgdir>
80109e4a:	83 c4 10             	add    $0x10,%esp
80109e4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80109e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e53:	8b 00                	mov    (%eax),%eax
80109e55:	83 e0 01             	and    $0x1,%eax
80109e58:	85 c0                	test   %eax,%eax
80109e5a:	75 07                	jne    80109e63 <uva2ka+0x2f>
    return 0;
80109e5c:	b8 00 00 00 00       	mov    $0x0,%eax
80109e61:	eb 29                	jmp    80109e8c <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80109e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e66:	8b 00                	mov    (%eax),%eax
80109e68:	83 e0 04             	and    $0x4,%eax
80109e6b:	85 c0                	test   %eax,%eax
80109e6d:	75 07                	jne    80109e76 <uva2ka+0x42>
    return 0;
80109e6f:	b8 00 00 00 00       	mov    $0x0,%eax
80109e74:	eb 16                	jmp    80109e8c <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
80109e76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e79:	8b 00                	mov    (%eax),%eax
80109e7b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109e80:	83 ec 0c             	sub    $0xc,%esp
80109e83:	50                   	push   %eax
80109e84:	e8 cf f2 ff ff       	call   80109158 <p2v>
80109e89:	83 c4 10             	add    $0x10,%esp
}
80109e8c:	c9                   	leave  
80109e8d:	c3                   	ret    

80109e8e <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80109e8e:	55                   	push   %ebp
80109e8f:	89 e5                	mov    %esp,%ebp
80109e91:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80109e94:	8b 45 10             	mov    0x10(%ebp),%eax
80109e97:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80109e9a:	eb 7f                	jmp    80109f1b <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80109e9c:	8b 45 0c             	mov    0xc(%ebp),%eax
80109e9f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109ea4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80109ea7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109eaa:	83 ec 08             	sub    $0x8,%esp
80109ead:	50                   	push   %eax
80109eae:	ff 75 08             	pushl  0x8(%ebp)
80109eb1:	e8 7e ff ff ff       	call   80109e34 <uva2ka>
80109eb6:	83 c4 10             	add    $0x10,%esp
80109eb9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80109ebc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80109ec0:	75 07                	jne    80109ec9 <copyout+0x3b>
      return -1;
80109ec2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109ec7:	eb 61                	jmp    80109f2a <copyout+0x9c>
    n = PGSIZE - (va - va0);
80109ec9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ecc:	2b 45 0c             	sub    0xc(%ebp),%eax
80109ecf:	05 00 10 00 00       	add    $0x1000,%eax
80109ed4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80109ed7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109eda:	3b 45 14             	cmp    0x14(%ebp),%eax
80109edd:	76 06                	jbe    80109ee5 <copyout+0x57>
      n = len;
80109edf:	8b 45 14             	mov    0x14(%ebp),%eax
80109ee2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80109ee5:	8b 45 0c             	mov    0xc(%ebp),%eax
80109ee8:	2b 45 ec             	sub    -0x14(%ebp),%eax
80109eeb:	89 c2                	mov    %eax,%edx
80109eed:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ef0:	01 d0                	add    %edx,%eax
80109ef2:	83 ec 04             	sub    $0x4,%esp
80109ef5:	ff 75 f0             	pushl  -0x10(%ebp)
80109ef8:	ff 75 f4             	pushl  -0xc(%ebp)
80109efb:	50                   	push   %eax
80109efc:	e8 84 cc ff ff       	call   80106b85 <memmove>
80109f01:	83 c4 10             	add    $0x10,%esp
    len -= n;
80109f04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f07:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80109f0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f0d:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80109f10:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f13:	05 00 10 00 00       	add    $0x1000,%eax
80109f18:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80109f1b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80109f1f:	0f 85 77 ff ff ff    	jne    80109e9c <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80109f25:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109f2a:	c9                   	leave  
80109f2b:	c3                   	ret    

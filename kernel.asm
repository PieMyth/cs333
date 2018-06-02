
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
80100028:	bc 90 d6 10 80       	mov    $0x8010d690,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 9e 39 10 80       	mov    $0x8010399e,%eax
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
8010003d:	68 64 94 10 80       	push   $0x80109464
80100042:	68 a0 d6 10 80       	push   $0x8010d6a0
80100047:	e8 cb 5a 00 00       	call   80105b17 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 b0 15 11 80 a4 	movl   $0x801115a4,0x801115b0
80100056:	15 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 b4 15 11 80 a4 	movl   $0x801115a4,0x801115b4
80100060:	15 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 d4 d6 10 80 	movl   $0x8010d6d4,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 b4 15 11 80    	mov    0x801115b4,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c a4 15 11 80 	movl   $0x801115a4,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 b4 15 11 80       	mov    0x801115b4,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 b4 15 11 80       	mov    %eax,0x801115b4

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 a4 15 11 80       	mov    $0x801115a4,%eax
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
801000bc:	68 a0 d6 10 80       	push   $0x8010d6a0
801000c1:	e8 73 5a 00 00       	call   80105b39 <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c9:	a1 b4 15 11 80       	mov    0x801115b4,%eax
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
80100107:	68 a0 d6 10 80       	push   $0x8010d6a0
8010010c:	e8 8f 5a 00 00       	call   80105ba0 <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 a0 d6 10 80       	push   $0x8010d6a0
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 16 4e 00 00       	call   80104f42 <sleep>
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
8010013a:	81 7d f4 a4 15 11 80 	cmpl   $0x801115a4,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100143:	a1 b0 15 11 80       	mov    0x801115b0,%eax
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
80100183:	68 a0 d6 10 80       	push   $0x8010d6a0
80100188:	e8 13 5a 00 00       	call   80105ba0 <release>
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
8010019e:	81 7d f4 a4 15 11 80 	cmpl   $0x801115a4,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 6b 94 10 80       	push   $0x8010946b
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
801001e2:	e8 35 28 00 00       	call   80102a1c <iderw>
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
80100204:	68 7c 94 10 80       	push   $0x8010947c
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
80100223:	e8 f4 27 00 00       	call   80102a1c <iderw>
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
80100243:	68 83 94 10 80       	push   $0x80109483
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 a0 d6 10 80       	push   $0x8010d6a0
80100255:	e8 df 58 00 00       	call   80105b39 <acquire>
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
8010027b:	8b 15 b4 15 11 80    	mov    0x801115b4,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c a4 15 11 80 	movl   $0x801115a4,0xc(%eax)
  bcache.head.next->prev = b;
80100291:	a1 b4 15 11 80       	mov    0x801115b4,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 b4 15 11 80       	mov    %eax,0x801115b4

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
801002b9:	e8 6b 4d 00 00       	call   80105029 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 a0 d6 10 80       	push   $0x8010d6a0
801002c9:	e8 d2 58 00 00       	call   80105ba0 <release>
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
801003cc:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 00 c6 10 80       	push   $0x8010c600
801003e2:	e8 52 57 00 00       	call   80105b39 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 8a 94 10 80       	push   $0x8010948a
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
801004cd:	c7 45 ec 93 94 10 80 	movl   $0x80109493,-0x14(%ebp)
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
80100556:	68 00 c6 10 80       	push   $0x8010c600
8010055b:	e8 40 56 00 00       	call   80105ba0 <release>
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
80100571:	c7 05 34 c6 10 80 00 	movl   $0x0,0x8010c634
80100578:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010057b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f b6 c0             	movzbl %al,%eax
80100587:	83 ec 08             	sub    $0x8,%esp
8010058a:	50                   	push   %eax
8010058b:	68 9a 94 10 80       	push   $0x8010949a
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
801005aa:	68 a9 94 10 80       	push   $0x801094a9
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 2b 56 00 00       	call   80105bf2 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 ab 94 10 80       	push   $0x801094ab
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
801005f5:	c7 05 e0 c5 10 80 01 	movl   $0x1,0x8010c5e0
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
801006ca:	68 af 94 10 80       	push   $0x801094af
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
801006f7:	e8 5f 57 00 00       	call   80105e5b <memmove>
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
80100721:	e8 76 56 00 00       	call   80105d9c <memset>
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
80100798:	a1 e0 c5 10 80       	mov    0x8010c5e0,%eax
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
801007b6:	e8 32 73 00 00       	call   80107aed <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 25 73 00 00       	call   80107aed <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 18 73 00 00       	call   80107aed <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 08 73 00 00       	call   80107aed <uartputc>
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
801007fc:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801007ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  int dofree = 0;
  int dosleep = 0;
  int dozombie = 0;
#endif

  acquire(&cons.lock);
80100806:	83 ec 0c             	sub    $0xc,%esp
80100809:	68 00 c6 10 80       	push   $0x8010c600
8010080e:	e8 26 53 00 00       	call   80105b39 <acquire>
80100813:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
80100816:	e9 44 01 00 00       	jmp    8010095f <consoleintr+0x166>
    switch(c){
8010081b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010081e:	83 f8 10             	cmp    $0x10,%eax
80100821:	74 1e                	je     80100841 <consoleintr+0x48>
80100823:	83 f8 10             	cmp    $0x10,%eax
80100826:	7f 0a                	jg     80100832 <consoleintr+0x39>
80100828:	83 f8 08             	cmp    $0x8,%eax
8010082b:	74 6b                	je     80100898 <consoleintr+0x9f>
8010082d:	e9 9b 00 00 00       	jmp    801008cd <consoleintr+0xd4>
80100832:	83 f8 15             	cmp    $0x15,%eax
80100835:	74 33                	je     8010086a <consoleintr+0x71>
80100837:	83 f8 7f             	cmp    $0x7f,%eax
8010083a:	74 5c                	je     80100898 <consoleintr+0x9f>
8010083c:	e9 8c 00 00 00       	jmp    801008cd <consoleintr+0xd4>
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
80100841:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100848:	e9 12 01 00 00       	jmp    8010095f <consoleintr+0x166>
      break;
#endif
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010084d:	a1 48 18 11 80       	mov    0x80111848,%eax
80100852:	83 e8 01             	sub    $0x1,%eax
80100855:	a3 48 18 11 80       	mov    %eax,0x80111848
        consputc(BACKSPACE);
8010085a:	83 ec 0c             	sub    $0xc,%esp
8010085d:	68 00 01 00 00       	push   $0x100
80100862:	e8 2b ff ff ff       	call   80100792 <consputc>
80100867:	83 c4 10             	add    $0x10,%esp
    case C('Z'):
      dozombie = 1;
      break;
#endif
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010086a:	8b 15 48 18 11 80    	mov    0x80111848,%edx
80100870:	a1 44 18 11 80       	mov    0x80111844,%eax
80100875:	39 c2                	cmp    %eax,%edx
80100877:	0f 84 e2 00 00 00    	je     8010095f <consoleintr+0x166>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010087d:	a1 48 18 11 80       	mov    0x80111848,%eax
80100882:	83 e8 01             	sub    $0x1,%eax
80100885:	83 e0 7f             	and    $0x7f,%eax
80100888:	0f b6 80 c0 17 11 80 	movzbl -0x7feee840(%eax),%eax
    case C('Z'):
      dozombie = 1;
      break;
#endif
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010088f:	3c 0a                	cmp    $0xa,%al
80100891:	75 ba                	jne    8010084d <consoleintr+0x54>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100893:	e9 c7 00 00 00       	jmp    8010095f <consoleintr+0x166>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100898:	8b 15 48 18 11 80    	mov    0x80111848,%edx
8010089e:	a1 44 18 11 80       	mov    0x80111844,%eax
801008a3:	39 c2                	cmp    %eax,%edx
801008a5:	0f 84 b4 00 00 00    	je     8010095f <consoleintr+0x166>
        input.e--;
801008ab:	a1 48 18 11 80       	mov    0x80111848,%eax
801008b0:	83 e8 01             	sub    $0x1,%eax
801008b3:	a3 48 18 11 80       	mov    %eax,0x80111848
        consputc(BACKSPACE);
801008b8:	83 ec 0c             	sub    $0xc,%esp
801008bb:	68 00 01 00 00       	push   $0x100
801008c0:	e8 cd fe ff ff       	call   80100792 <consputc>
801008c5:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008c8:	e9 92 00 00 00       	jmp    8010095f <consoleintr+0x166>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008d1:	0f 84 87 00 00 00    	je     8010095e <consoleintr+0x165>
801008d7:	8b 15 48 18 11 80    	mov    0x80111848,%edx
801008dd:	a1 40 18 11 80       	mov    0x80111840,%eax
801008e2:	29 c2                	sub    %eax,%edx
801008e4:	89 d0                	mov    %edx,%eax
801008e6:	83 f8 7f             	cmp    $0x7f,%eax
801008e9:	77 73                	ja     8010095e <consoleintr+0x165>
        c = (c == '\r') ? '\n' : c;
801008eb:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008ef:	74 05                	je     801008f6 <consoleintr+0xfd>
801008f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008f4:	eb 05                	jmp    801008fb <consoleintr+0x102>
801008f6:	b8 0a 00 00 00       	mov    $0xa,%eax
801008fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008fe:	a1 48 18 11 80       	mov    0x80111848,%eax
80100903:	8d 50 01             	lea    0x1(%eax),%edx
80100906:	89 15 48 18 11 80    	mov    %edx,0x80111848
8010090c:	83 e0 7f             	and    $0x7f,%eax
8010090f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100912:	88 90 c0 17 11 80    	mov    %dl,-0x7feee840(%eax)
        consputc(c);
80100918:	83 ec 0c             	sub    $0xc,%esp
8010091b:	ff 75 f0             	pushl  -0x10(%ebp)
8010091e:	e8 6f fe ff ff       	call   80100792 <consputc>
80100923:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100926:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
8010092a:	74 18                	je     80100944 <consoleintr+0x14b>
8010092c:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100930:	74 12                	je     80100944 <consoleintr+0x14b>
80100932:	a1 48 18 11 80       	mov    0x80111848,%eax
80100937:	8b 15 40 18 11 80    	mov    0x80111840,%edx
8010093d:	83 ea 80             	sub    $0xffffff80,%edx
80100940:	39 d0                	cmp    %edx,%eax
80100942:	75 1a                	jne    8010095e <consoleintr+0x165>
          input.w = input.e;
80100944:	a1 48 18 11 80       	mov    0x80111848,%eax
80100949:	a3 44 18 11 80       	mov    %eax,0x80111844
          wakeup(&input.r);
8010094e:	83 ec 0c             	sub    $0xc,%esp
80100951:	68 40 18 11 80       	push   $0x80111840
80100956:	e8 ce 46 00 00       	call   80105029 <wakeup>
8010095b:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
8010095e:	90                   	nop
  int dosleep = 0;
  int dozombie = 0;
#endif

  acquire(&cons.lock);
  while((c = getc()) >= 0){
8010095f:	8b 45 08             	mov    0x8(%ebp),%eax
80100962:	ff d0                	call   *%eax
80100964:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100967:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010096b:	0f 89 aa fe ff ff    	jns    8010081b <consoleintr+0x22>
        }
      }
      break;
    }
  }
  release(&cons.lock);
80100971:	83 ec 0c             	sub    $0xc,%esp
80100974:	68 00 c6 10 80       	push   $0x8010c600
80100979:	e8 22 52 00 00       	call   80105ba0 <release>
8010097e:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100981:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100985:	74 05                	je     8010098c <consoleintr+0x193>
    procdump();  // now call procdump() wo. cons.lock held
80100987:	e8 5d 47 00 00       	call   801050e9 <procdump>
  }
  if(dozombie) {
    zombiedump();
  }
#endif
}
8010098c:	90                   	nop
8010098d:	c9                   	leave  
8010098e:	c3                   	ret    

8010098f <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010098f:	55                   	push   %ebp
80100990:	89 e5                	mov    %esp,%ebp
80100992:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100995:	83 ec 0c             	sub    $0xc,%esp
80100998:	ff 75 08             	pushl  0x8(%ebp)
8010099b:	e8 0f 12 00 00       	call   80101baf <iunlock>
801009a0:	83 c4 10             	add    $0x10,%esp
  target = n;
801009a3:	8b 45 10             	mov    0x10(%ebp),%eax
801009a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009a9:	83 ec 0c             	sub    $0xc,%esp
801009ac:	68 00 c6 10 80       	push   $0x8010c600
801009b1:	e8 83 51 00 00       	call   80105b39 <acquire>
801009b6:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009b9:	e9 ac 00 00 00       	jmp    80100a6a <consoleread+0xdb>
    while(input.r == input.w){
      if(proc->killed){
801009be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801009c4:	8b 40 24             	mov    0x24(%eax),%eax
801009c7:	85 c0                	test   %eax,%eax
801009c9:	74 28                	je     801009f3 <consoleread+0x64>
        release(&cons.lock);
801009cb:	83 ec 0c             	sub    $0xc,%esp
801009ce:	68 00 c6 10 80       	push   $0x8010c600
801009d3:	e8 c8 51 00 00       	call   80105ba0 <release>
801009d8:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009db:	83 ec 0c             	sub    $0xc,%esp
801009de:	ff 75 08             	pushl  0x8(%ebp)
801009e1:	e8 43 10 00 00       	call   80101a29 <ilock>
801009e6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009ee:	e9 ab 00 00 00       	jmp    80100a9e <consoleread+0x10f>
      }
      sleep(&input.r, &cons.lock);
801009f3:	83 ec 08             	sub    $0x8,%esp
801009f6:	68 00 c6 10 80       	push   $0x8010c600
801009fb:	68 40 18 11 80       	push   $0x80111840
80100a00:	e8 3d 45 00 00       	call   80104f42 <sleep>
80100a05:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100a08:	8b 15 40 18 11 80    	mov    0x80111840,%edx
80100a0e:	a1 44 18 11 80       	mov    0x80111844,%eax
80100a13:	39 c2                	cmp    %eax,%edx
80100a15:	74 a7                	je     801009be <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a17:	a1 40 18 11 80       	mov    0x80111840,%eax
80100a1c:	8d 50 01             	lea    0x1(%eax),%edx
80100a1f:	89 15 40 18 11 80    	mov    %edx,0x80111840
80100a25:	83 e0 7f             	and    $0x7f,%eax
80100a28:	0f b6 80 c0 17 11 80 	movzbl -0x7feee840(%eax),%eax
80100a2f:	0f be c0             	movsbl %al,%eax
80100a32:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a35:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a39:	75 17                	jne    80100a52 <consoleread+0xc3>
      if(n < target){
80100a3b:	8b 45 10             	mov    0x10(%ebp),%eax
80100a3e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a41:	73 2f                	jae    80100a72 <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a43:	a1 40 18 11 80       	mov    0x80111840,%eax
80100a48:	83 e8 01             	sub    $0x1,%eax
80100a4b:	a3 40 18 11 80       	mov    %eax,0x80111840
      }
      break;
80100a50:	eb 20                	jmp    80100a72 <consoleread+0xe3>
    }
    *dst++ = c;
80100a52:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a55:	8d 50 01             	lea    0x1(%eax),%edx
80100a58:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a5b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a5e:	88 10                	mov    %dl,(%eax)
    --n;
80100a60:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a64:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a68:	74 0b                	je     80100a75 <consoleread+0xe6>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100a6a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a6e:	7f 98                	jg     80100a08 <consoleread+0x79>
80100a70:	eb 04                	jmp    80100a76 <consoleread+0xe7>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100a72:	90                   	nop
80100a73:	eb 01                	jmp    80100a76 <consoleread+0xe7>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100a75:	90                   	nop
  }
  release(&cons.lock);
80100a76:	83 ec 0c             	sub    $0xc,%esp
80100a79:	68 00 c6 10 80       	push   $0x8010c600
80100a7e:	e8 1d 51 00 00       	call   80105ba0 <release>
80100a83:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a86:	83 ec 0c             	sub    $0xc,%esp
80100a89:	ff 75 08             	pushl  0x8(%ebp)
80100a8c:	e8 98 0f 00 00       	call   80101a29 <ilock>
80100a91:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a94:	8b 45 10             	mov    0x10(%ebp),%eax
80100a97:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a9a:	29 c2                	sub    %eax,%edx
80100a9c:	89 d0                	mov    %edx,%eax
}
80100a9e:	c9                   	leave  
80100a9f:	c3                   	ret    

80100aa0 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100aa0:	55                   	push   %ebp
80100aa1:	89 e5                	mov    %esp,%ebp
80100aa3:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100aa6:	83 ec 0c             	sub    $0xc,%esp
80100aa9:	ff 75 08             	pushl  0x8(%ebp)
80100aac:	e8 fe 10 00 00       	call   80101baf <iunlock>
80100ab1:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ab4:	83 ec 0c             	sub    $0xc,%esp
80100ab7:	68 00 c6 10 80       	push   $0x8010c600
80100abc:	e8 78 50 00 00       	call   80105b39 <acquire>
80100ac1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ac4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100acb:	eb 21                	jmp    80100aee <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100acd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ad0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ad3:	01 d0                	add    %edx,%eax
80100ad5:	0f b6 00             	movzbl (%eax),%eax
80100ad8:	0f be c0             	movsbl %al,%eax
80100adb:	0f b6 c0             	movzbl %al,%eax
80100ade:	83 ec 0c             	sub    $0xc,%esp
80100ae1:	50                   	push   %eax
80100ae2:	e8 ab fc ff ff       	call   80100792 <consputc>
80100ae7:	83 c4 10             	add    $0x10,%esp
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100aea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100af1:	3b 45 10             	cmp    0x10(%ebp),%eax
80100af4:	7c d7                	jl     80100acd <consolewrite+0x2d>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100af6:	83 ec 0c             	sub    $0xc,%esp
80100af9:	68 00 c6 10 80       	push   $0x8010c600
80100afe:	e8 9d 50 00 00       	call   80105ba0 <release>
80100b03:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b06:	83 ec 0c             	sub    $0xc,%esp
80100b09:	ff 75 08             	pushl  0x8(%ebp)
80100b0c:	e8 18 0f 00 00       	call   80101a29 <ilock>
80100b11:	83 c4 10             	add    $0x10,%esp

  return n;
80100b14:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b17:	c9                   	leave  
80100b18:	c3                   	ret    

80100b19 <consoleinit>:

void
consoleinit(void)
{
80100b19:	55                   	push   %ebp
80100b1a:	89 e5                	mov    %esp,%ebp
80100b1c:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100b1f:	83 ec 08             	sub    $0x8,%esp
80100b22:	68 c2 94 10 80       	push   $0x801094c2
80100b27:	68 00 c6 10 80       	push   $0x8010c600
80100b2c:	e8 e6 4f 00 00       	call   80105b17 <initlock>
80100b31:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b34:	c7 05 0c 22 11 80 a0 	movl   $0x80100aa0,0x8011220c
80100b3b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b3e:	c7 05 08 22 11 80 8f 	movl   $0x8010098f,0x80112208
80100b45:	09 10 80 
  cons.locking = 1;
80100b48:	c7 05 34 c6 10 80 01 	movl   $0x1,0x8010c634
80100b4f:	00 00 00 

  picenable(IRQ_KBD);
80100b52:	83 ec 0c             	sub    $0xc,%esp
80100b55:	6a 01                	push   $0x1
80100b57:	e8 de 34 00 00       	call   8010403a <picenable>
80100b5c:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b5f:	83 ec 08             	sub    $0x8,%esp
80100b62:	6a 00                	push   $0x0
80100b64:	6a 01                	push   $0x1
80100b66:	e8 7e 20 00 00       	call   80102be9 <ioapicenable>
80100b6b:	83 c4 10             	add    $0x10,%esp
}
80100b6e:	90                   	nop
80100b6f:	c9                   	leave  
80100b70:	c3                   	ret    

80100b71 <exec>:
#include "fs.h"
#include "file.h"

int
exec(char *path, char **argv)
{
80100b71:	55                   	push   %ebp
80100b72:	89 e5                	mov    %esp,%ebp
80100b74:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b7a:	e8 dd 2a 00 00       	call   8010365c <begin_op>
  if((ip = namei(path)) == 0){
80100b7f:	83 ec 0c             	sub    $0xc,%esp
80100b82:	ff 75 08             	pushl  0x8(%ebp)
80100b85:	e8 ad 1a 00 00       	call   80102637 <namei>
80100b8a:	83 c4 10             	add    $0x10,%esp
80100b8d:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b90:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b94:	75 0f                	jne    80100ba5 <exec+0x34>
    end_op();
80100b96:	e8 4d 2b 00 00       	call   801036e8 <end_op>
    return -1;
80100b9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ba0:	e9 65 04 00 00       	jmp    8010100a <exec+0x499>
  }
  ilock(ip);
80100ba5:	83 ec 0c             	sub    $0xc,%esp
80100ba8:	ff 75 d8             	pushl  -0x28(%ebp)
80100bab:	e8 79 0e 00 00       	call   80101a29 <ilock>
80100bb0:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bb3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
#ifdef CS333_P5
  if(proc->uid == ip->uid && ip->mode.flags.u_x != 1)
80100bba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100bc0:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80100bc6:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bc9:	0f b7 40 18          	movzwl 0x18(%eax),%eax
80100bcd:	0f b7 c0             	movzwl %ax,%eax
80100bd0:	39 c2                	cmp    %eax,%edx
80100bd2:	75 12                	jne    80100be6 <exec+0x75>
80100bd4:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bd7:	0f b6 40 1c          	movzbl 0x1c(%eax),%eax
80100bdb:	83 e0 40             	and    $0x40,%eax
80100bde:	84 c0                	test   %al,%al
80100be0:	0f 84 ca 03 00 00    	je     80100fb0 <exec+0x43f>
    goto bad;
  if(proc->gid == ip->gid && ip->mode.flags.g_x != 1)
80100be6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100bec:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80100bf2:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bf5:	0f b7 40 1a          	movzwl 0x1a(%eax),%eax
80100bf9:	0f b7 c0             	movzwl %ax,%eax
80100bfc:	39 c2                	cmp    %eax,%edx
80100bfe:	75 12                	jne    80100c12 <exec+0xa1>
80100c00:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c03:	0f b6 40 1c          	movzbl 0x1c(%eax),%eax
80100c07:	83 e0 08             	and    $0x8,%eax
80100c0a:	84 c0                	test   %al,%al
80100c0c:	0f 84 a1 03 00 00    	je     80100fb3 <exec+0x442>
    goto bad;
  if(ip->mode.flags.o_x != 1)
80100c12:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c15:	0f b6 40 1c          	movzbl 0x1c(%eax),%eax
80100c19:	83 e0 01             	and    $0x1,%eax
80100c1c:	84 c0                	test   %al,%al
80100c1e:	0f 84 92 03 00 00    	je     80100fb6 <exec+0x445>
    goto bad;

  if(ip->mode.flags.setuid == 1)
80100c24:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c27:	0f b6 40 1d          	movzbl 0x1d(%eax),%eax
80100c2b:	83 e0 02             	and    $0x2,%eax
80100c2e:	84 c0                	test   %al,%al
80100c30:	74 16                	je     80100c48 <exec+0xd7>
    proc->uid = ip->uid;
80100c32:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c38:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100c3b:	0f b7 52 18          	movzwl 0x18(%edx),%edx
80100c3f:	0f b7 d2             	movzwl %dx,%edx
80100c42:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
#endif


  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100c48:	6a 34                	push   $0x34
80100c4a:	6a 00                	push   $0x0
80100c4c:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100c52:	50                   	push   %eax
80100c53:	ff 75 d8             	pushl  -0x28(%ebp)
80100c56:	e8 8c 13 00 00       	call   80101fe7 <readi>
80100c5b:	83 c4 10             	add    $0x10,%esp
80100c5e:	83 f8 33             	cmp    $0x33,%eax
80100c61:	0f 86 52 03 00 00    	jbe    80100fb9 <exec+0x448>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c67:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100c6d:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c72:	0f 85 44 03 00 00    	jne    80100fbc <exec+0x44b>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c78:	e8 c5 7f 00 00       	call   80108c42 <setupkvm>
80100c7d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c80:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c84:	0f 84 35 03 00 00    	je     80100fbf <exec+0x44e>
    goto bad;
  // Load program into memory.
  sz = 0;
80100c8a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c91:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c98:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100c9e:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100ca1:	e9 ab 00 00 00       	jmp    80100d51 <exec+0x1e0>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100ca6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100ca9:	6a 20                	push   $0x20
80100cab:	50                   	push   %eax
80100cac:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100cb2:	50                   	push   %eax
80100cb3:	ff 75 d8             	pushl  -0x28(%ebp)
80100cb6:	e8 2c 13 00 00       	call   80101fe7 <readi>
80100cbb:	83 c4 10             	add    $0x10,%esp
80100cbe:	83 f8 20             	cmp    $0x20,%eax
80100cc1:	0f 85 fb 02 00 00    	jne    80100fc2 <exec+0x451>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100cc7:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100ccd:	83 f8 01             	cmp    $0x1,%eax
80100cd0:	75 71                	jne    80100d43 <exec+0x1d2>
      continue;
    if(ph.memsz < ph.filesz)
80100cd2:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100cd8:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cde:	39 c2                	cmp    %eax,%edx
80100ce0:	0f 82 df 02 00 00    	jb     80100fc5 <exec+0x454>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100ce6:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100cec:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100cf2:	01 d0                	add    %edx,%eax
80100cf4:	83 ec 04             	sub    $0x4,%esp
80100cf7:	50                   	push   %eax
80100cf8:	ff 75 e0             	pushl  -0x20(%ebp)
80100cfb:	ff 75 d4             	pushl  -0x2c(%ebp)
80100cfe:	e8 e6 82 00 00       	call   80108fe9 <allocuvm>
80100d03:	83 c4 10             	add    $0x10,%esp
80100d06:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d09:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d0d:	0f 84 b5 02 00 00    	je     80100fc8 <exec+0x457>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100d13:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100d19:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d1f:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100d25:	83 ec 0c             	sub    $0xc,%esp
80100d28:	52                   	push   %edx
80100d29:	50                   	push   %eax
80100d2a:	ff 75 d8             	pushl  -0x28(%ebp)
80100d2d:	51                   	push   %ecx
80100d2e:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d31:	e8 dc 81 00 00       	call   80108f12 <loaduvm>
80100d36:	83 c4 20             	add    $0x20,%esp
80100d39:	85 c0                	test   %eax,%eax
80100d3b:	0f 88 8a 02 00 00    	js     80100fcb <exec+0x45a>
80100d41:	eb 01                	jmp    80100d44 <exec+0x1d3>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100d43:	90                   	nop

  if((pgdir = setupkvm()) == 0)
    goto bad;
  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d44:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d48:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d4b:	83 c0 20             	add    $0x20,%eax
80100d4e:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d51:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100d58:	0f b7 c0             	movzwl %ax,%eax
80100d5b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100d5e:	0f 8f 42 ff ff ff    	jg     80100ca6 <exec+0x135>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100d64:	83 ec 0c             	sub    $0xc,%esp
80100d67:	ff 75 d8             	pushl  -0x28(%ebp)
80100d6a:	e8 a2 0f 00 00       	call   80101d11 <iunlockput>
80100d6f:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d72:	e8 71 29 00 00       	call   801036e8 <end_op>
  ip = 0;
80100d77:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d7e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d81:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d86:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d8b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d91:	05 00 20 00 00       	add    $0x2000,%eax
80100d96:	83 ec 04             	sub    $0x4,%esp
80100d99:	50                   	push   %eax
80100d9a:	ff 75 e0             	pushl  -0x20(%ebp)
80100d9d:	ff 75 d4             	pushl  -0x2c(%ebp)
80100da0:	e8 44 82 00 00       	call   80108fe9 <allocuvm>
80100da5:	83 c4 10             	add    $0x10,%esp
80100da8:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100dab:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100daf:	0f 84 19 02 00 00    	je     80100fce <exec+0x45d>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100db5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100db8:	2d 00 20 00 00       	sub    $0x2000,%eax
80100dbd:	83 ec 08             	sub    $0x8,%esp
80100dc0:	50                   	push   %eax
80100dc1:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dc4:	e8 46 84 00 00       	call   8010920f <clearpteu>
80100dc9:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100dcc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100dcf:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100dd2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100dd9:	e9 96 00 00 00       	jmp    80100e74 <exec+0x303>
    if(argc >= MAXARG)
80100dde:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100de2:	0f 87 e9 01 00 00    	ja     80100fd1 <exec+0x460>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100de8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100deb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100df2:	8b 45 0c             	mov    0xc(%ebp),%eax
80100df5:	01 d0                	add    %edx,%eax
80100df7:	8b 00                	mov    (%eax),%eax
80100df9:	83 ec 0c             	sub    $0xc,%esp
80100dfc:	50                   	push   %eax
80100dfd:	e8 e7 51 00 00       	call   80105fe9 <strlen>
80100e02:	83 c4 10             	add    $0x10,%esp
80100e05:	89 c2                	mov    %eax,%edx
80100e07:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e0a:	29 d0                	sub    %edx,%eax
80100e0c:	83 e8 01             	sub    $0x1,%eax
80100e0f:	83 e0 fc             	and    $0xfffffffc,%eax
80100e12:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e18:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e22:	01 d0                	add    %edx,%eax
80100e24:	8b 00                	mov    (%eax),%eax
80100e26:	83 ec 0c             	sub    $0xc,%esp
80100e29:	50                   	push   %eax
80100e2a:	e8 ba 51 00 00       	call   80105fe9 <strlen>
80100e2f:	83 c4 10             	add    $0x10,%esp
80100e32:	83 c0 01             	add    $0x1,%eax
80100e35:	89 c1                	mov    %eax,%ecx
80100e37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e3a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e41:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e44:	01 d0                	add    %edx,%eax
80100e46:	8b 00                	mov    (%eax),%eax
80100e48:	51                   	push   %ecx
80100e49:	50                   	push   %eax
80100e4a:	ff 75 dc             	pushl  -0x24(%ebp)
80100e4d:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e50:	e8 71 85 00 00       	call   801093c6 <copyout>
80100e55:	83 c4 10             	add    $0x10,%esp
80100e58:	85 c0                	test   %eax,%eax
80100e5a:	0f 88 74 01 00 00    	js     80100fd4 <exec+0x463>
      goto bad;
    ustack[3+argc] = sp;
80100e60:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e63:	8d 50 03             	lea    0x3(%eax),%edx
80100e66:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e69:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e70:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e77:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e7e:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e81:	01 d0                	add    %edx,%eax
80100e83:	8b 00                	mov    (%eax),%eax
80100e85:	85 c0                	test   %eax,%eax
80100e87:	0f 85 51 ff ff ff    	jne    80100dde <exec+0x26d>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100e8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e90:	83 c0 03             	add    $0x3,%eax
80100e93:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100e9a:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e9e:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100ea5:	ff ff ff 
  ustack[1] = argc;
80100ea8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eab:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100eb1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eb4:	83 c0 01             	add    $0x1,%eax
80100eb7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ebe:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ec1:	29 d0                	sub    %edx,%eax
80100ec3:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100ec9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ecc:	83 c0 04             	add    $0x4,%eax
80100ecf:	c1 e0 02             	shl    $0x2,%eax
80100ed2:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100ed5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ed8:	83 c0 04             	add    $0x4,%eax
80100edb:	c1 e0 02             	shl    $0x2,%eax
80100ede:	50                   	push   %eax
80100edf:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100ee5:	50                   	push   %eax
80100ee6:	ff 75 dc             	pushl  -0x24(%ebp)
80100ee9:	ff 75 d4             	pushl  -0x2c(%ebp)
80100eec:	e8 d5 84 00 00       	call   801093c6 <copyout>
80100ef1:	83 c4 10             	add    $0x10,%esp
80100ef4:	85 c0                	test   %eax,%eax
80100ef6:	0f 88 db 00 00 00    	js     80100fd7 <exec+0x466>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100efc:	8b 45 08             	mov    0x8(%ebp),%eax
80100eff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f05:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f08:	eb 17                	jmp    80100f21 <exec+0x3b0>
    if(*s == '/')
80100f0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f0d:	0f b6 00             	movzbl (%eax),%eax
80100f10:	3c 2f                	cmp    $0x2f,%al
80100f12:	75 09                	jne    80100f1d <exec+0x3ac>
      last = s+1;
80100f14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f17:	83 c0 01             	add    $0x1,%eax
80100f1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f1d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f24:	0f b6 00             	movzbl (%eax),%eax
80100f27:	84 c0                	test   %al,%al
80100f29:	75 df                	jne    80100f0a <exec+0x399>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100f2b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f31:	83 c0 6c             	add    $0x6c,%eax
80100f34:	83 ec 04             	sub    $0x4,%esp
80100f37:	6a 10                	push   $0x10
80100f39:	ff 75 f0             	pushl  -0x10(%ebp)
80100f3c:	50                   	push   %eax
80100f3d:	e8 5d 50 00 00       	call   80105f9f <safestrcpy>
80100f42:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100f45:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f4b:	8b 40 04             	mov    0x4(%eax),%eax
80100f4e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100f51:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f57:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f5a:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100f5d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f63:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f66:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100f68:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f6e:	8b 40 18             	mov    0x18(%eax),%eax
80100f71:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100f77:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100f7a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f80:	8b 40 18             	mov    0x18(%eax),%eax
80100f83:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f86:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100f89:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f8f:	83 ec 0c             	sub    $0xc,%esp
80100f92:	50                   	push   %eax
80100f93:	e8 91 7d 00 00       	call   80108d29 <switchuvm>
80100f98:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f9b:	83 ec 0c             	sub    $0xc,%esp
80100f9e:	ff 75 d0             	pushl  -0x30(%ebp)
80100fa1:	e8 c9 81 00 00       	call   8010916f <freevm>
80100fa6:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fa9:	b8 00 00 00 00       	mov    $0x0,%eax
80100fae:	eb 5a                	jmp    8010100a <exec+0x499>
  }
  ilock(ip);
  pgdir = 0;
#ifdef CS333_P5
  if(proc->uid == ip->uid && ip->mode.flags.u_x != 1)
    goto bad;
80100fb0:	90                   	nop
80100fb1:	eb 25                	jmp    80100fd8 <exec+0x467>
  if(proc->gid == ip->gid && ip->mode.flags.g_x != 1)
    goto bad;
80100fb3:	90                   	nop
80100fb4:	eb 22                	jmp    80100fd8 <exec+0x467>
  if(ip->mode.flags.o_x != 1)
    goto bad;
80100fb6:	90                   	nop
80100fb7:	eb 1f                	jmp    80100fd8 <exec+0x467>
#endif


  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100fb9:	90                   	nop
80100fba:	eb 1c                	jmp    80100fd8 <exec+0x467>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100fbc:	90                   	nop
80100fbd:	eb 19                	jmp    80100fd8 <exec+0x467>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100fbf:	90                   	nop
80100fc0:	eb 16                	jmp    80100fd8 <exec+0x467>
  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100fc2:	90                   	nop
80100fc3:	eb 13                	jmp    80100fd8 <exec+0x467>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100fc5:	90                   	nop
80100fc6:	eb 10                	jmp    80100fd8 <exec+0x467>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100fc8:	90                   	nop
80100fc9:	eb 0d                	jmp    80100fd8 <exec+0x467>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100fcb:	90                   	nop
80100fcc:	eb 0a                	jmp    80100fd8 <exec+0x467>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80100fce:	90                   	nop
80100fcf:	eb 07                	jmp    80100fd8 <exec+0x467>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100fd1:	90                   	nop
80100fd2:	eb 04                	jmp    80100fd8 <exec+0x467>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100fd4:	90                   	nop
80100fd5:	eb 01                	jmp    80100fd8 <exec+0x467>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100fd7:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100fd8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100fdc:	74 0e                	je     80100fec <exec+0x47b>
    freevm(pgdir);
80100fde:	83 ec 0c             	sub    $0xc,%esp
80100fe1:	ff 75 d4             	pushl  -0x2c(%ebp)
80100fe4:	e8 86 81 00 00       	call   8010916f <freevm>
80100fe9:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100fec:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100ff0:	74 13                	je     80101005 <exec+0x494>
    iunlockput(ip);
80100ff2:	83 ec 0c             	sub    $0xc,%esp
80100ff5:	ff 75 d8             	pushl  -0x28(%ebp)
80100ff8:	e8 14 0d 00 00       	call   80101d11 <iunlockput>
80100ffd:	83 c4 10             	add    $0x10,%esp
    end_op();
80101000:	e8 e3 26 00 00       	call   801036e8 <end_op>
  }
  return -1;
80101005:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010100a:	c9                   	leave  
8010100b:	c3                   	ret    

8010100c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
8010100c:	55                   	push   %ebp
8010100d:	89 e5                	mov    %esp,%ebp
8010100f:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80101012:	83 ec 08             	sub    $0x8,%esp
80101015:	68 ca 94 10 80       	push   $0x801094ca
8010101a:	68 60 18 11 80       	push   $0x80111860
8010101f:	e8 f3 4a 00 00       	call   80105b17 <initlock>
80101024:	83 c4 10             	add    $0x10,%esp
}
80101027:	90                   	nop
80101028:	c9                   	leave  
80101029:	c3                   	ret    

8010102a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
8010102a:	55                   	push   %ebp
8010102b:	89 e5                	mov    %esp,%ebp
8010102d:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80101030:	83 ec 0c             	sub    $0xc,%esp
80101033:	68 60 18 11 80       	push   $0x80111860
80101038:	e8 fc 4a 00 00       	call   80105b39 <acquire>
8010103d:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101040:	c7 45 f4 94 18 11 80 	movl   $0x80111894,-0xc(%ebp)
80101047:	eb 2d                	jmp    80101076 <filealloc+0x4c>
    if(f->ref == 0){
80101049:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010104c:	8b 40 04             	mov    0x4(%eax),%eax
8010104f:	85 c0                	test   %eax,%eax
80101051:	75 1f                	jne    80101072 <filealloc+0x48>
      f->ref = 1;
80101053:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101056:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010105d:	83 ec 0c             	sub    $0xc,%esp
80101060:	68 60 18 11 80       	push   $0x80111860
80101065:	e8 36 4b 00 00       	call   80105ba0 <release>
8010106a:	83 c4 10             	add    $0x10,%esp
      return f;
8010106d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101070:	eb 23                	jmp    80101095 <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101072:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101076:	b8 f4 21 11 80       	mov    $0x801121f4,%eax
8010107b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010107e:	72 c9                	jb     80101049 <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80101080:	83 ec 0c             	sub    $0xc,%esp
80101083:	68 60 18 11 80       	push   $0x80111860
80101088:	e8 13 4b 00 00       	call   80105ba0 <release>
8010108d:	83 c4 10             	add    $0x10,%esp
  return 0;
80101090:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101095:	c9                   	leave  
80101096:	c3                   	ret    

80101097 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101097:	55                   	push   %ebp
80101098:	89 e5                	mov    %esp,%ebp
8010109a:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
8010109d:	83 ec 0c             	sub    $0xc,%esp
801010a0:	68 60 18 11 80       	push   $0x80111860
801010a5:	e8 8f 4a 00 00       	call   80105b39 <acquire>
801010aa:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010ad:	8b 45 08             	mov    0x8(%ebp),%eax
801010b0:	8b 40 04             	mov    0x4(%eax),%eax
801010b3:	85 c0                	test   %eax,%eax
801010b5:	7f 0d                	jg     801010c4 <filedup+0x2d>
    panic("filedup");
801010b7:	83 ec 0c             	sub    $0xc,%esp
801010ba:	68 d1 94 10 80       	push   $0x801094d1
801010bf:	e8 a2 f4 ff ff       	call   80100566 <panic>
  f->ref++;
801010c4:	8b 45 08             	mov    0x8(%ebp),%eax
801010c7:	8b 40 04             	mov    0x4(%eax),%eax
801010ca:	8d 50 01             	lea    0x1(%eax),%edx
801010cd:	8b 45 08             	mov    0x8(%ebp),%eax
801010d0:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010d3:	83 ec 0c             	sub    $0xc,%esp
801010d6:	68 60 18 11 80       	push   $0x80111860
801010db:	e8 c0 4a 00 00       	call   80105ba0 <release>
801010e0:	83 c4 10             	add    $0x10,%esp
  return f;
801010e3:	8b 45 08             	mov    0x8(%ebp),%eax
}
801010e6:	c9                   	leave  
801010e7:	c3                   	ret    

801010e8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801010e8:	55                   	push   %ebp
801010e9:	89 e5                	mov    %esp,%ebp
801010eb:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010ee:	83 ec 0c             	sub    $0xc,%esp
801010f1:	68 60 18 11 80       	push   $0x80111860
801010f6:	e8 3e 4a 00 00       	call   80105b39 <acquire>
801010fb:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101101:	8b 40 04             	mov    0x4(%eax),%eax
80101104:	85 c0                	test   %eax,%eax
80101106:	7f 0d                	jg     80101115 <fileclose+0x2d>
    panic("fileclose");
80101108:	83 ec 0c             	sub    $0xc,%esp
8010110b:	68 d9 94 10 80       	push   $0x801094d9
80101110:	e8 51 f4 ff ff       	call   80100566 <panic>
  if(--f->ref > 0){
80101115:	8b 45 08             	mov    0x8(%ebp),%eax
80101118:	8b 40 04             	mov    0x4(%eax),%eax
8010111b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010111e:	8b 45 08             	mov    0x8(%ebp),%eax
80101121:	89 50 04             	mov    %edx,0x4(%eax)
80101124:	8b 45 08             	mov    0x8(%ebp),%eax
80101127:	8b 40 04             	mov    0x4(%eax),%eax
8010112a:	85 c0                	test   %eax,%eax
8010112c:	7e 15                	jle    80101143 <fileclose+0x5b>
    release(&ftable.lock);
8010112e:	83 ec 0c             	sub    $0xc,%esp
80101131:	68 60 18 11 80       	push   $0x80111860
80101136:	e8 65 4a 00 00       	call   80105ba0 <release>
8010113b:	83 c4 10             	add    $0x10,%esp
8010113e:	e9 8b 00 00 00       	jmp    801011ce <fileclose+0xe6>
    return;
  }
  ff = *f;
80101143:	8b 45 08             	mov    0x8(%ebp),%eax
80101146:	8b 10                	mov    (%eax),%edx
80101148:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010114b:	8b 50 04             	mov    0x4(%eax),%edx
8010114e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101151:	8b 50 08             	mov    0x8(%eax),%edx
80101154:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101157:	8b 50 0c             	mov    0xc(%eax),%edx
8010115a:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010115d:	8b 50 10             	mov    0x10(%eax),%edx
80101160:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101163:	8b 40 14             	mov    0x14(%eax),%eax
80101166:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101169:	8b 45 08             	mov    0x8(%ebp),%eax
8010116c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101173:	8b 45 08             	mov    0x8(%ebp),%eax
80101176:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010117c:	83 ec 0c             	sub    $0xc,%esp
8010117f:	68 60 18 11 80       	push   $0x80111860
80101184:	e8 17 4a 00 00       	call   80105ba0 <release>
80101189:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
8010118c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010118f:	83 f8 01             	cmp    $0x1,%eax
80101192:	75 19                	jne    801011ad <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101194:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101198:	0f be d0             	movsbl %al,%edx
8010119b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010119e:	83 ec 08             	sub    $0x8,%esp
801011a1:	52                   	push   %edx
801011a2:	50                   	push   %eax
801011a3:	e8 fb 30 00 00       	call   801042a3 <pipeclose>
801011a8:	83 c4 10             	add    $0x10,%esp
801011ab:	eb 21                	jmp    801011ce <fileclose+0xe6>
  else if(ff.type == FD_INODE){
801011ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011b0:	83 f8 02             	cmp    $0x2,%eax
801011b3:	75 19                	jne    801011ce <fileclose+0xe6>
    begin_op();
801011b5:	e8 a2 24 00 00       	call   8010365c <begin_op>
    iput(ff.ip);
801011ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011bd:	83 ec 0c             	sub    $0xc,%esp
801011c0:	50                   	push   %eax
801011c1:	e8 5b 0a 00 00       	call   80101c21 <iput>
801011c6:	83 c4 10             	add    $0x10,%esp
    end_op();
801011c9:	e8 1a 25 00 00       	call   801036e8 <end_op>
  }
}
801011ce:	c9                   	leave  
801011cf:	c3                   	ret    

801011d0 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801011d0:	55                   	push   %ebp
801011d1:	89 e5                	mov    %esp,%ebp
801011d3:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801011d6:	8b 45 08             	mov    0x8(%ebp),%eax
801011d9:	8b 00                	mov    (%eax),%eax
801011db:	83 f8 02             	cmp    $0x2,%eax
801011de:	75 40                	jne    80101220 <filestat+0x50>
    ilock(f->ip);
801011e0:	8b 45 08             	mov    0x8(%ebp),%eax
801011e3:	8b 40 10             	mov    0x10(%eax),%eax
801011e6:	83 ec 0c             	sub    $0xc,%esp
801011e9:	50                   	push   %eax
801011ea:	e8 3a 08 00 00       	call   80101a29 <ilock>
801011ef:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011f2:	8b 45 08             	mov    0x8(%ebp),%eax
801011f5:	8b 40 10             	mov    0x10(%eax),%eax
801011f8:	83 ec 08             	sub    $0x8,%esp
801011fb:	ff 75 0c             	pushl  0xc(%ebp)
801011fe:	50                   	push   %eax
801011ff:	e8 75 0d 00 00       	call   80101f79 <stati>
80101204:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101207:	8b 45 08             	mov    0x8(%ebp),%eax
8010120a:	8b 40 10             	mov    0x10(%eax),%eax
8010120d:	83 ec 0c             	sub    $0xc,%esp
80101210:	50                   	push   %eax
80101211:	e8 99 09 00 00       	call   80101baf <iunlock>
80101216:	83 c4 10             	add    $0x10,%esp
    return 0;
80101219:	b8 00 00 00 00       	mov    $0x0,%eax
8010121e:	eb 05                	jmp    80101225 <filestat+0x55>
  }
  return -1;
80101220:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101225:	c9                   	leave  
80101226:	c3                   	ret    

80101227 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101227:	55                   	push   %ebp
80101228:	89 e5                	mov    %esp,%ebp
8010122a:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
8010122d:	8b 45 08             	mov    0x8(%ebp),%eax
80101230:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101234:	84 c0                	test   %al,%al
80101236:	75 0a                	jne    80101242 <fileread+0x1b>
    return -1;
80101238:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010123d:	e9 9b 00 00 00       	jmp    801012dd <fileread+0xb6>
  if(f->type == FD_PIPE)
80101242:	8b 45 08             	mov    0x8(%ebp),%eax
80101245:	8b 00                	mov    (%eax),%eax
80101247:	83 f8 01             	cmp    $0x1,%eax
8010124a:	75 1a                	jne    80101266 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
8010124c:	8b 45 08             	mov    0x8(%ebp),%eax
8010124f:	8b 40 0c             	mov    0xc(%eax),%eax
80101252:	83 ec 04             	sub    $0x4,%esp
80101255:	ff 75 10             	pushl  0x10(%ebp)
80101258:	ff 75 0c             	pushl  0xc(%ebp)
8010125b:	50                   	push   %eax
8010125c:	e8 ea 31 00 00       	call   8010444b <piperead>
80101261:	83 c4 10             	add    $0x10,%esp
80101264:	eb 77                	jmp    801012dd <fileread+0xb6>
  if(f->type == FD_INODE){
80101266:	8b 45 08             	mov    0x8(%ebp),%eax
80101269:	8b 00                	mov    (%eax),%eax
8010126b:	83 f8 02             	cmp    $0x2,%eax
8010126e:	75 60                	jne    801012d0 <fileread+0xa9>
    ilock(f->ip);
80101270:	8b 45 08             	mov    0x8(%ebp),%eax
80101273:	8b 40 10             	mov    0x10(%eax),%eax
80101276:	83 ec 0c             	sub    $0xc,%esp
80101279:	50                   	push   %eax
8010127a:	e8 aa 07 00 00       	call   80101a29 <ilock>
8010127f:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101282:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101285:	8b 45 08             	mov    0x8(%ebp),%eax
80101288:	8b 50 14             	mov    0x14(%eax),%edx
8010128b:	8b 45 08             	mov    0x8(%ebp),%eax
8010128e:	8b 40 10             	mov    0x10(%eax),%eax
80101291:	51                   	push   %ecx
80101292:	52                   	push   %edx
80101293:	ff 75 0c             	pushl  0xc(%ebp)
80101296:	50                   	push   %eax
80101297:	e8 4b 0d 00 00       	call   80101fe7 <readi>
8010129c:	83 c4 10             	add    $0x10,%esp
8010129f:	89 45 f4             	mov    %eax,-0xc(%ebp)
801012a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801012a6:	7e 11                	jle    801012b9 <fileread+0x92>
      f->off += r;
801012a8:	8b 45 08             	mov    0x8(%ebp),%eax
801012ab:	8b 50 14             	mov    0x14(%eax),%edx
801012ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012b1:	01 c2                	add    %eax,%edx
801012b3:	8b 45 08             	mov    0x8(%ebp),%eax
801012b6:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801012b9:	8b 45 08             	mov    0x8(%ebp),%eax
801012bc:	8b 40 10             	mov    0x10(%eax),%eax
801012bf:	83 ec 0c             	sub    $0xc,%esp
801012c2:	50                   	push   %eax
801012c3:	e8 e7 08 00 00       	call   80101baf <iunlock>
801012c8:	83 c4 10             	add    $0x10,%esp
    return r;
801012cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012ce:	eb 0d                	jmp    801012dd <fileread+0xb6>
  }
  panic("fileread");
801012d0:	83 ec 0c             	sub    $0xc,%esp
801012d3:	68 e3 94 10 80       	push   $0x801094e3
801012d8:	e8 89 f2 ff ff       	call   80100566 <panic>
}
801012dd:	c9                   	leave  
801012de:	c3                   	ret    

801012df <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801012df:	55                   	push   %ebp
801012e0:	89 e5                	mov    %esp,%ebp
801012e2:	53                   	push   %ebx
801012e3:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801012e6:	8b 45 08             	mov    0x8(%ebp),%eax
801012e9:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012ed:	84 c0                	test   %al,%al
801012ef:	75 0a                	jne    801012fb <filewrite+0x1c>
    return -1;
801012f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012f6:	e9 1b 01 00 00       	jmp    80101416 <filewrite+0x137>
  if(f->type == FD_PIPE)
801012fb:	8b 45 08             	mov    0x8(%ebp),%eax
801012fe:	8b 00                	mov    (%eax),%eax
80101300:	83 f8 01             	cmp    $0x1,%eax
80101303:	75 1d                	jne    80101322 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
80101305:	8b 45 08             	mov    0x8(%ebp),%eax
80101308:	8b 40 0c             	mov    0xc(%eax),%eax
8010130b:	83 ec 04             	sub    $0x4,%esp
8010130e:	ff 75 10             	pushl  0x10(%ebp)
80101311:	ff 75 0c             	pushl  0xc(%ebp)
80101314:	50                   	push   %eax
80101315:	e8 33 30 00 00       	call   8010434d <pipewrite>
8010131a:	83 c4 10             	add    $0x10,%esp
8010131d:	e9 f4 00 00 00       	jmp    80101416 <filewrite+0x137>
  if(f->type == FD_INODE){
80101322:	8b 45 08             	mov    0x8(%ebp),%eax
80101325:	8b 00                	mov    (%eax),%eax
80101327:	83 f8 02             	cmp    $0x2,%eax
8010132a:	0f 85 d9 00 00 00    	jne    80101409 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101330:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
80101337:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010133e:	e9 a3 00 00 00       	jmp    801013e6 <filewrite+0x107>
      int n1 = n - i;
80101343:	8b 45 10             	mov    0x10(%ebp),%eax
80101346:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101349:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010134c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010134f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101352:	7e 06                	jle    8010135a <filewrite+0x7b>
        n1 = max;
80101354:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101357:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010135a:	e8 fd 22 00 00       	call   8010365c <begin_op>
      ilock(f->ip);
8010135f:	8b 45 08             	mov    0x8(%ebp),%eax
80101362:	8b 40 10             	mov    0x10(%eax),%eax
80101365:	83 ec 0c             	sub    $0xc,%esp
80101368:	50                   	push   %eax
80101369:	e8 bb 06 00 00       	call   80101a29 <ilock>
8010136e:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101371:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101374:	8b 45 08             	mov    0x8(%ebp),%eax
80101377:	8b 50 14             	mov    0x14(%eax),%edx
8010137a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010137d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101380:	01 c3                	add    %eax,%ebx
80101382:	8b 45 08             	mov    0x8(%ebp),%eax
80101385:	8b 40 10             	mov    0x10(%eax),%eax
80101388:	51                   	push   %ecx
80101389:	52                   	push   %edx
8010138a:	53                   	push   %ebx
8010138b:	50                   	push   %eax
8010138c:	e8 ad 0d 00 00       	call   8010213e <writei>
80101391:	83 c4 10             	add    $0x10,%esp
80101394:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101397:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010139b:	7e 11                	jle    801013ae <filewrite+0xcf>
        f->off += r;
8010139d:	8b 45 08             	mov    0x8(%ebp),%eax
801013a0:	8b 50 14             	mov    0x14(%eax),%edx
801013a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013a6:	01 c2                	add    %eax,%edx
801013a8:	8b 45 08             	mov    0x8(%ebp),%eax
801013ab:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801013ae:	8b 45 08             	mov    0x8(%ebp),%eax
801013b1:	8b 40 10             	mov    0x10(%eax),%eax
801013b4:	83 ec 0c             	sub    $0xc,%esp
801013b7:	50                   	push   %eax
801013b8:	e8 f2 07 00 00       	call   80101baf <iunlock>
801013bd:	83 c4 10             	add    $0x10,%esp
      end_op();
801013c0:	e8 23 23 00 00       	call   801036e8 <end_op>

      if(r < 0)
801013c5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013c9:	78 29                	js     801013f4 <filewrite+0x115>
        break;
      if(r != n1)
801013cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013ce:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801013d1:	74 0d                	je     801013e0 <filewrite+0x101>
        panic("short filewrite");
801013d3:	83 ec 0c             	sub    $0xc,%esp
801013d6:	68 ec 94 10 80       	push   $0x801094ec
801013db:	e8 86 f1 ff ff       	call   80100566 <panic>
      i += r;
801013e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013e3:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801013e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013e9:	3b 45 10             	cmp    0x10(%ebp),%eax
801013ec:	0f 8c 51 ff ff ff    	jl     80101343 <filewrite+0x64>
801013f2:	eb 01                	jmp    801013f5 <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
801013f4:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801013f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013f8:	3b 45 10             	cmp    0x10(%ebp),%eax
801013fb:	75 05                	jne    80101402 <filewrite+0x123>
801013fd:	8b 45 10             	mov    0x10(%ebp),%eax
80101400:	eb 14                	jmp    80101416 <filewrite+0x137>
80101402:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101407:	eb 0d                	jmp    80101416 <filewrite+0x137>
  }
  panic("filewrite");
80101409:	83 ec 0c             	sub    $0xc,%esp
8010140c:	68 fc 94 10 80       	push   $0x801094fc
80101411:	e8 50 f1 ff ff       	call   80100566 <panic>
}
80101416:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101419:	c9                   	leave  
8010141a:	c3                   	ret    

8010141b <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010141b:	55                   	push   %ebp
8010141c:	89 e5                	mov    %esp,%ebp
8010141e:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
80101421:	8b 45 08             	mov    0x8(%ebp),%eax
80101424:	83 ec 08             	sub    $0x8,%esp
80101427:	6a 01                	push   $0x1
80101429:	50                   	push   %eax
8010142a:	e8 87 ed ff ff       	call   801001b6 <bread>
8010142f:	83 c4 10             	add    $0x10,%esp
80101432:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101435:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101438:	83 c0 18             	add    $0x18,%eax
8010143b:	83 ec 04             	sub    $0x4,%esp
8010143e:	6a 1c                	push   $0x1c
80101440:	50                   	push   %eax
80101441:	ff 75 0c             	pushl  0xc(%ebp)
80101444:	e8 12 4a 00 00       	call   80105e5b <memmove>
80101449:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010144c:	83 ec 0c             	sub    $0xc,%esp
8010144f:	ff 75 f4             	pushl  -0xc(%ebp)
80101452:	e8 d7 ed ff ff       	call   8010022e <brelse>
80101457:	83 c4 10             	add    $0x10,%esp
}
8010145a:	90                   	nop
8010145b:	c9                   	leave  
8010145c:	c3                   	ret    

8010145d <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010145d:	55                   	push   %ebp
8010145e:	89 e5                	mov    %esp,%ebp
80101460:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101463:	8b 55 0c             	mov    0xc(%ebp),%edx
80101466:	8b 45 08             	mov    0x8(%ebp),%eax
80101469:	83 ec 08             	sub    $0x8,%esp
8010146c:	52                   	push   %edx
8010146d:	50                   	push   %eax
8010146e:	e8 43 ed ff ff       	call   801001b6 <bread>
80101473:	83 c4 10             	add    $0x10,%esp
80101476:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101479:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010147c:	83 c0 18             	add    $0x18,%eax
8010147f:	83 ec 04             	sub    $0x4,%esp
80101482:	68 00 02 00 00       	push   $0x200
80101487:	6a 00                	push   $0x0
80101489:	50                   	push   %eax
8010148a:	e8 0d 49 00 00       	call   80105d9c <memset>
8010148f:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101492:	83 ec 0c             	sub    $0xc,%esp
80101495:	ff 75 f4             	pushl  -0xc(%ebp)
80101498:	e8 f7 23 00 00       	call   80103894 <log_write>
8010149d:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801014a0:	83 ec 0c             	sub    $0xc,%esp
801014a3:	ff 75 f4             	pushl  -0xc(%ebp)
801014a6:	e8 83 ed ff ff       	call   8010022e <brelse>
801014ab:	83 c4 10             	add    $0x10,%esp
}
801014ae:	90                   	nop
801014af:	c9                   	leave  
801014b0:	c3                   	ret    

801014b1 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801014b1:	55                   	push   %ebp
801014b2:	89 e5                	mov    %esp,%ebp
801014b4:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801014b7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801014be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801014c5:	e9 13 01 00 00       	jmp    801015dd <balloc+0x12c>
    bp = bread(dev, BBLOCK(b, sb));
801014ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014cd:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801014d3:	85 c0                	test   %eax,%eax
801014d5:	0f 48 c2             	cmovs  %edx,%eax
801014d8:	c1 f8 0c             	sar    $0xc,%eax
801014db:	89 c2                	mov    %eax,%edx
801014dd:	a1 78 22 11 80       	mov    0x80112278,%eax
801014e2:	01 d0                	add    %edx,%eax
801014e4:	83 ec 08             	sub    $0x8,%esp
801014e7:	50                   	push   %eax
801014e8:	ff 75 08             	pushl  0x8(%ebp)
801014eb:	e8 c6 ec ff ff       	call   801001b6 <bread>
801014f0:	83 c4 10             	add    $0x10,%esp
801014f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014f6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014fd:	e9 a6 00 00 00       	jmp    801015a8 <balloc+0xf7>
      m = 1 << (bi % 8);
80101502:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101505:	99                   	cltd   
80101506:	c1 ea 1d             	shr    $0x1d,%edx
80101509:	01 d0                	add    %edx,%eax
8010150b:	83 e0 07             	and    $0x7,%eax
8010150e:	29 d0                	sub    %edx,%eax
80101510:	ba 01 00 00 00       	mov    $0x1,%edx
80101515:	89 c1                	mov    %eax,%ecx
80101517:	d3 e2                	shl    %cl,%edx
80101519:	89 d0                	mov    %edx,%eax
8010151b:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010151e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101521:	8d 50 07             	lea    0x7(%eax),%edx
80101524:	85 c0                	test   %eax,%eax
80101526:	0f 48 c2             	cmovs  %edx,%eax
80101529:	c1 f8 03             	sar    $0x3,%eax
8010152c:	89 c2                	mov    %eax,%edx
8010152e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101531:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
80101536:	0f b6 c0             	movzbl %al,%eax
80101539:	23 45 e8             	and    -0x18(%ebp),%eax
8010153c:	85 c0                	test   %eax,%eax
8010153e:	75 64                	jne    801015a4 <balloc+0xf3>
        bp->data[bi/8] |= m;  // Mark block in use.
80101540:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101543:	8d 50 07             	lea    0x7(%eax),%edx
80101546:	85 c0                	test   %eax,%eax
80101548:	0f 48 c2             	cmovs  %edx,%eax
8010154b:	c1 f8 03             	sar    $0x3,%eax
8010154e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101551:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101556:	89 d1                	mov    %edx,%ecx
80101558:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010155b:	09 ca                	or     %ecx,%edx
8010155d:	89 d1                	mov    %edx,%ecx
8010155f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101562:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101566:	83 ec 0c             	sub    $0xc,%esp
80101569:	ff 75 ec             	pushl  -0x14(%ebp)
8010156c:	e8 23 23 00 00       	call   80103894 <log_write>
80101571:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101574:	83 ec 0c             	sub    $0xc,%esp
80101577:	ff 75 ec             	pushl  -0x14(%ebp)
8010157a:	e8 af ec ff ff       	call   8010022e <brelse>
8010157f:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101582:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101585:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101588:	01 c2                	add    %eax,%edx
8010158a:	8b 45 08             	mov    0x8(%ebp),%eax
8010158d:	83 ec 08             	sub    $0x8,%esp
80101590:	52                   	push   %edx
80101591:	50                   	push   %eax
80101592:	e8 c6 fe ff ff       	call   8010145d <bzero>
80101597:	83 c4 10             	add    $0x10,%esp
        return b + bi;
8010159a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010159d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015a0:	01 d0                	add    %edx,%eax
801015a2:	eb 57                	jmp    801015fb <balloc+0x14a>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015a4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801015a8:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801015af:	7f 17                	jg     801015c8 <balloc+0x117>
801015b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015b7:	01 d0                	add    %edx,%eax
801015b9:	89 c2                	mov    %eax,%edx
801015bb:	a1 60 22 11 80       	mov    0x80112260,%eax
801015c0:	39 c2                	cmp    %eax,%edx
801015c2:	0f 82 3a ff ff ff    	jb     80101502 <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801015c8:	83 ec 0c             	sub    $0xc,%esp
801015cb:	ff 75 ec             	pushl  -0x14(%ebp)
801015ce:	e8 5b ec ff ff       	call   8010022e <brelse>
801015d3:	83 c4 10             	add    $0x10,%esp
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
801015d6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801015dd:	8b 15 60 22 11 80    	mov    0x80112260,%edx
801015e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015e6:	39 c2                	cmp    %eax,%edx
801015e8:	0f 87 dc fe ff ff    	ja     801014ca <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801015ee:	83 ec 0c             	sub    $0xc,%esp
801015f1:	68 08 95 10 80       	push   $0x80109508
801015f6:	e8 6b ef ff ff       	call   80100566 <panic>
}
801015fb:	c9                   	leave  
801015fc:	c3                   	ret    

801015fd <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015fd:	55                   	push   %ebp
801015fe:	89 e5                	mov    %esp,%ebp
80101600:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101603:	83 ec 08             	sub    $0x8,%esp
80101606:	68 60 22 11 80       	push   $0x80112260
8010160b:	ff 75 08             	pushl  0x8(%ebp)
8010160e:	e8 08 fe ff ff       	call   8010141b <readsb>
80101613:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101616:	8b 45 0c             	mov    0xc(%ebp),%eax
80101619:	c1 e8 0c             	shr    $0xc,%eax
8010161c:	89 c2                	mov    %eax,%edx
8010161e:	a1 78 22 11 80       	mov    0x80112278,%eax
80101623:	01 c2                	add    %eax,%edx
80101625:	8b 45 08             	mov    0x8(%ebp),%eax
80101628:	83 ec 08             	sub    $0x8,%esp
8010162b:	52                   	push   %edx
8010162c:	50                   	push   %eax
8010162d:	e8 84 eb ff ff       	call   801001b6 <bread>
80101632:	83 c4 10             	add    $0x10,%esp
80101635:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101638:	8b 45 0c             	mov    0xc(%ebp),%eax
8010163b:	25 ff 0f 00 00       	and    $0xfff,%eax
80101640:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101643:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101646:	99                   	cltd   
80101647:	c1 ea 1d             	shr    $0x1d,%edx
8010164a:	01 d0                	add    %edx,%eax
8010164c:	83 e0 07             	and    $0x7,%eax
8010164f:	29 d0                	sub    %edx,%eax
80101651:	ba 01 00 00 00       	mov    $0x1,%edx
80101656:	89 c1                	mov    %eax,%ecx
80101658:	d3 e2                	shl    %cl,%edx
8010165a:	89 d0                	mov    %edx,%eax
8010165c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010165f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101662:	8d 50 07             	lea    0x7(%eax),%edx
80101665:	85 c0                	test   %eax,%eax
80101667:	0f 48 c2             	cmovs  %edx,%eax
8010166a:	c1 f8 03             	sar    $0x3,%eax
8010166d:	89 c2                	mov    %eax,%edx
8010166f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101672:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
80101677:	0f b6 c0             	movzbl %al,%eax
8010167a:	23 45 ec             	and    -0x14(%ebp),%eax
8010167d:	85 c0                	test   %eax,%eax
8010167f:	75 0d                	jne    8010168e <bfree+0x91>
    panic("freeing free block");
80101681:	83 ec 0c             	sub    $0xc,%esp
80101684:	68 1e 95 10 80       	push   $0x8010951e
80101689:	e8 d8 ee ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
8010168e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101691:	8d 50 07             	lea    0x7(%eax),%edx
80101694:	85 c0                	test   %eax,%eax
80101696:	0f 48 c2             	cmovs  %edx,%eax
80101699:	c1 f8 03             	sar    $0x3,%eax
8010169c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010169f:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801016a4:	89 d1                	mov    %edx,%ecx
801016a6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801016a9:	f7 d2                	not    %edx
801016ab:	21 ca                	and    %ecx,%edx
801016ad:	89 d1                	mov    %edx,%ecx
801016af:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016b2:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
801016b6:	83 ec 0c             	sub    $0xc,%esp
801016b9:	ff 75 f4             	pushl  -0xc(%ebp)
801016bc:	e8 d3 21 00 00       	call   80103894 <log_write>
801016c1:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801016c4:	83 ec 0c             	sub    $0xc,%esp
801016c7:	ff 75 f4             	pushl  -0xc(%ebp)
801016ca:	e8 5f eb ff ff       	call   8010022e <brelse>
801016cf:	83 c4 10             	add    $0x10,%esp
}
801016d2:	90                   	nop
801016d3:	c9                   	leave  
801016d4:	c3                   	ret    

801016d5 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801016d5:	55                   	push   %ebp
801016d6:	89 e5                	mov    %esp,%ebp
801016d8:	57                   	push   %edi
801016d9:	56                   	push   %esi
801016da:	53                   	push   %ebx
801016db:	83 ec 1c             	sub    $0x1c,%esp
  initlock(&icache.lock, "icache");
801016de:	83 ec 08             	sub    $0x8,%esp
801016e1:	68 31 95 10 80       	push   $0x80109531
801016e6:	68 80 22 11 80       	push   $0x80112280
801016eb:	e8 27 44 00 00       	call   80105b17 <initlock>
801016f0:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
801016f3:	83 ec 08             	sub    $0x8,%esp
801016f6:	68 60 22 11 80       	push   $0x80112260
801016fb:	ff 75 08             	pushl  0x8(%ebp)
801016fe:	e8 18 fd ff ff       	call   8010141b <readsb>
80101703:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
80101706:	a1 78 22 11 80       	mov    0x80112278,%eax
8010170b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010170e:	8b 3d 74 22 11 80    	mov    0x80112274,%edi
80101714:	8b 35 70 22 11 80    	mov    0x80112270,%esi
8010171a:	8b 1d 6c 22 11 80    	mov    0x8011226c,%ebx
80101720:	8b 0d 68 22 11 80    	mov    0x80112268,%ecx
80101726:	8b 15 64 22 11 80    	mov    0x80112264,%edx
8010172c:	a1 60 22 11 80       	mov    0x80112260,%eax
80101731:	ff 75 e4             	pushl  -0x1c(%ebp)
80101734:	57                   	push   %edi
80101735:	56                   	push   %esi
80101736:	53                   	push   %ebx
80101737:	51                   	push   %ecx
80101738:	52                   	push   %edx
80101739:	50                   	push   %eax
8010173a:	68 38 95 10 80       	push   $0x80109538
8010173f:	e8 82 ec ff ff       	call   801003c6 <cprintf>
80101744:	83 c4 20             	add    $0x20,%esp
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
80101747:	90                   	nop
80101748:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010174b:	5b                   	pop    %ebx
8010174c:	5e                   	pop    %esi
8010174d:	5f                   	pop    %edi
8010174e:	5d                   	pop    %ebp
8010174f:	c3                   	ret    

80101750 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101750:	55                   	push   %ebp
80101751:	89 e5                	mov    %esp,%ebp
80101753:	83 ec 28             	sub    $0x28,%esp
80101756:	8b 45 0c             	mov    0xc(%ebp),%eax
80101759:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010175d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101764:	e9 9e 00 00 00       	jmp    80101807 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
80101769:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010176c:	c1 e8 03             	shr    $0x3,%eax
8010176f:	89 c2                	mov    %eax,%edx
80101771:	a1 74 22 11 80       	mov    0x80112274,%eax
80101776:	01 d0                	add    %edx,%eax
80101778:	83 ec 08             	sub    $0x8,%esp
8010177b:	50                   	push   %eax
8010177c:	ff 75 08             	pushl  0x8(%ebp)
8010177f:	e8 32 ea ff ff       	call   801001b6 <bread>
80101784:	83 c4 10             	add    $0x10,%esp
80101787:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
8010178a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010178d:	8d 50 18             	lea    0x18(%eax),%edx
80101790:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101793:	83 e0 07             	and    $0x7,%eax
80101796:	c1 e0 06             	shl    $0x6,%eax
80101799:	01 d0                	add    %edx,%eax
8010179b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010179e:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017a1:	0f b7 00             	movzwl (%eax),%eax
801017a4:	66 85 c0             	test   %ax,%ax
801017a7:	75 4c                	jne    801017f5 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
801017a9:	83 ec 04             	sub    $0x4,%esp
801017ac:	6a 40                	push   $0x40
801017ae:	6a 00                	push   $0x0
801017b0:	ff 75 ec             	pushl  -0x14(%ebp)
801017b3:	e8 e4 45 00 00       	call   80105d9c <memset>
801017b8:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017be:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017c2:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017c5:	83 ec 0c             	sub    $0xc,%esp
801017c8:	ff 75 f0             	pushl  -0x10(%ebp)
801017cb:	e8 c4 20 00 00       	call   80103894 <log_write>
801017d0:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017d3:	83 ec 0c             	sub    $0xc,%esp
801017d6:	ff 75 f0             	pushl  -0x10(%ebp)
801017d9:	e8 50 ea ff ff       	call   8010022e <brelse>
801017de:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017e4:	83 ec 08             	sub    $0x8,%esp
801017e7:	50                   	push   %eax
801017e8:	ff 75 08             	pushl  0x8(%ebp)
801017eb:	e8 20 01 00 00       	call   80101910 <iget>
801017f0:	83 c4 10             	add    $0x10,%esp
801017f3:	eb 30                	jmp    80101825 <ialloc+0xd5>
    }
    brelse(bp);
801017f5:	83 ec 0c             	sub    $0xc,%esp
801017f8:	ff 75 f0             	pushl  -0x10(%ebp)
801017fb:	e8 2e ea ff ff       	call   8010022e <brelse>
80101800:	83 c4 10             	add    $0x10,%esp
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101803:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101807:	8b 15 68 22 11 80    	mov    0x80112268,%edx
8010180d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101810:	39 c2                	cmp    %eax,%edx
80101812:	0f 87 51 ff ff ff    	ja     80101769 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101818:	83 ec 0c             	sub    $0xc,%esp
8010181b:	68 8b 95 10 80       	push   $0x8010958b
80101820:	e8 41 ed ff ff       	call   80100566 <panic>
}
80101825:	c9                   	leave  
80101826:	c3                   	ret    

80101827 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101827:	55                   	push   %ebp
80101828:	89 e5                	mov    %esp,%ebp
8010182a:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010182d:	8b 45 08             	mov    0x8(%ebp),%eax
80101830:	8b 40 04             	mov    0x4(%eax),%eax
80101833:	c1 e8 03             	shr    $0x3,%eax
80101836:	89 c2                	mov    %eax,%edx
80101838:	a1 74 22 11 80       	mov    0x80112274,%eax
8010183d:	01 c2                	add    %eax,%edx
8010183f:	8b 45 08             	mov    0x8(%ebp),%eax
80101842:	8b 00                	mov    (%eax),%eax
80101844:	83 ec 08             	sub    $0x8,%esp
80101847:	52                   	push   %edx
80101848:	50                   	push   %eax
80101849:	e8 68 e9 ff ff       	call   801001b6 <bread>
8010184e:	83 c4 10             	add    $0x10,%esp
80101851:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101854:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101857:	8d 50 18             	lea    0x18(%eax),%edx
8010185a:	8b 45 08             	mov    0x8(%ebp),%eax
8010185d:	8b 40 04             	mov    0x4(%eax),%eax
80101860:	83 e0 07             	and    $0x7,%eax
80101863:	c1 e0 06             	shl    $0x6,%eax
80101866:	01 d0                	add    %edx,%eax
80101868:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
8010186b:	8b 45 08             	mov    0x8(%ebp),%eax
8010186e:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101872:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101875:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101878:	8b 45 08             	mov    0x8(%ebp),%eax
8010187b:	0f b7 50 12          	movzwl 0x12(%eax),%edx
8010187f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101882:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101886:	8b 45 08             	mov    0x8(%ebp),%eax
80101889:	0f b7 50 14          	movzwl 0x14(%eax),%edx
8010188d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101890:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101894:	8b 45 08             	mov    0x8(%ebp),%eax
80101897:	0f b7 50 16          	movzwl 0x16(%eax),%edx
8010189b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010189e:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801018a2:	8b 45 08             	mov    0x8(%ebp),%eax
801018a5:	8b 50 20             	mov    0x20(%eax),%edx
801018a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018ab:	89 50 10             	mov    %edx,0x10(%eax)
#ifdef CS333_P5
  dip->uid = ip -> uid;
801018ae:	8b 45 08             	mov    0x8(%ebp),%eax
801018b1:	0f b7 50 18          	movzwl 0x18(%eax),%edx
801018b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018b8:	66 89 50 08          	mov    %dx,0x8(%eax)
  dip->gid = ip -> gid;
801018bc:	8b 45 08             	mov    0x8(%ebp),%eax
801018bf:	0f b7 50 1a          	movzwl 0x1a(%eax),%edx
801018c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018c6:	66 89 50 0a          	mov    %dx,0xa(%eax)
  dip->mode.asInt = ip->mode.asInt;
801018ca:	8b 45 08             	mov    0x8(%ebp),%eax
801018cd:	8b 50 1c             	mov    0x1c(%eax),%edx
801018d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018d3:	89 50 0c             	mov    %edx,0xc(%eax)
#endif
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801018d6:	8b 45 08             	mov    0x8(%ebp),%eax
801018d9:	8d 50 24             	lea    0x24(%eax),%edx
801018dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018df:	83 c0 14             	add    $0x14,%eax
801018e2:	83 ec 04             	sub    $0x4,%esp
801018e5:	6a 2c                	push   $0x2c
801018e7:	52                   	push   %edx
801018e8:	50                   	push   %eax
801018e9:	e8 6d 45 00 00       	call   80105e5b <memmove>
801018ee:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018f1:	83 ec 0c             	sub    $0xc,%esp
801018f4:	ff 75 f4             	pushl  -0xc(%ebp)
801018f7:	e8 98 1f 00 00       	call   80103894 <log_write>
801018fc:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018ff:	83 ec 0c             	sub    $0xc,%esp
80101902:	ff 75 f4             	pushl  -0xc(%ebp)
80101905:	e8 24 e9 ff ff       	call   8010022e <brelse>
8010190a:	83 c4 10             	add    $0x10,%esp
}
8010190d:	90                   	nop
8010190e:	c9                   	leave  
8010190f:	c3                   	ret    

80101910 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101910:	55                   	push   %ebp
80101911:	89 e5                	mov    %esp,%ebp
80101913:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101916:	83 ec 0c             	sub    $0xc,%esp
80101919:	68 80 22 11 80       	push   $0x80112280
8010191e:	e8 16 42 00 00       	call   80105b39 <acquire>
80101923:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101926:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010192d:	c7 45 f4 b4 22 11 80 	movl   $0x801122b4,-0xc(%ebp)
80101934:	eb 5d                	jmp    80101993 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101936:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101939:	8b 40 08             	mov    0x8(%eax),%eax
8010193c:	85 c0                	test   %eax,%eax
8010193e:	7e 39                	jle    80101979 <iget+0x69>
80101940:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101943:	8b 00                	mov    (%eax),%eax
80101945:	3b 45 08             	cmp    0x8(%ebp),%eax
80101948:	75 2f                	jne    80101979 <iget+0x69>
8010194a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010194d:	8b 40 04             	mov    0x4(%eax),%eax
80101950:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101953:	75 24                	jne    80101979 <iget+0x69>
      ip->ref++;
80101955:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101958:	8b 40 08             	mov    0x8(%eax),%eax
8010195b:	8d 50 01             	lea    0x1(%eax),%edx
8010195e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101961:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101964:	83 ec 0c             	sub    $0xc,%esp
80101967:	68 80 22 11 80       	push   $0x80112280
8010196c:	e8 2f 42 00 00       	call   80105ba0 <release>
80101971:	83 c4 10             	add    $0x10,%esp
      return ip;
80101974:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101977:	eb 74                	jmp    801019ed <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101979:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010197d:	75 10                	jne    8010198f <iget+0x7f>
8010197f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101982:	8b 40 08             	mov    0x8(%eax),%eax
80101985:	85 c0                	test   %eax,%eax
80101987:	75 06                	jne    8010198f <iget+0x7f>
      empty = ip;
80101989:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010198f:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101993:	81 7d f4 54 32 11 80 	cmpl   $0x80113254,-0xc(%ebp)
8010199a:	72 9a                	jb     80101936 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010199c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019a0:	75 0d                	jne    801019af <iget+0x9f>
    panic("iget: no inodes");
801019a2:	83 ec 0c             	sub    $0xc,%esp
801019a5:	68 9d 95 10 80       	push   $0x8010959d
801019aa:	e8 b7 eb ff ff       	call   80100566 <panic>
  ip = empty;
801019af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801019b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019b8:	8b 55 08             	mov    0x8(%ebp),%edx
801019bb:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801019bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019c0:	8b 55 0c             	mov    0xc(%ebp),%edx
801019c3:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801019c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019c9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
801019d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019d3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
801019da:	83 ec 0c             	sub    $0xc,%esp
801019dd:	68 80 22 11 80       	push   $0x80112280
801019e2:	e8 b9 41 00 00       	call   80105ba0 <release>
801019e7:	83 c4 10             	add    $0x10,%esp

  return ip;
801019ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019ed:	c9                   	leave  
801019ee:	c3                   	ret    

801019ef <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019ef:	55                   	push   %ebp
801019f0:	89 e5                	mov    %esp,%ebp
801019f2:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019f5:	83 ec 0c             	sub    $0xc,%esp
801019f8:	68 80 22 11 80       	push   $0x80112280
801019fd:	e8 37 41 00 00       	call   80105b39 <acquire>
80101a02:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101a05:	8b 45 08             	mov    0x8(%ebp),%eax
80101a08:	8b 40 08             	mov    0x8(%eax),%eax
80101a0b:	8d 50 01             	lea    0x1(%eax),%edx
80101a0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a11:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a14:	83 ec 0c             	sub    $0xc,%esp
80101a17:	68 80 22 11 80       	push   $0x80112280
80101a1c:	e8 7f 41 00 00       	call   80105ba0 <release>
80101a21:	83 c4 10             	add    $0x10,%esp
  return ip;
80101a24:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101a27:	c9                   	leave  
80101a28:	c3                   	ret    

80101a29 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101a29:	55                   	push   %ebp
80101a2a:	89 e5                	mov    %esp,%ebp
80101a2c:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101a2f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a33:	74 0a                	je     80101a3f <ilock+0x16>
80101a35:	8b 45 08             	mov    0x8(%ebp),%eax
80101a38:	8b 40 08             	mov    0x8(%eax),%eax
80101a3b:	85 c0                	test   %eax,%eax
80101a3d:	7f 0d                	jg     80101a4c <ilock+0x23>
    panic("ilock");
80101a3f:	83 ec 0c             	sub    $0xc,%esp
80101a42:	68 ad 95 10 80       	push   $0x801095ad
80101a47:	e8 1a eb ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101a4c:	83 ec 0c             	sub    $0xc,%esp
80101a4f:	68 80 22 11 80       	push   $0x80112280
80101a54:	e8 e0 40 00 00       	call   80105b39 <acquire>
80101a59:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
80101a5c:	eb 13                	jmp    80101a71 <ilock+0x48>
    sleep(ip, &icache.lock);
80101a5e:	83 ec 08             	sub    $0x8,%esp
80101a61:	68 80 22 11 80       	push   $0x80112280
80101a66:	ff 75 08             	pushl  0x8(%ebp)
80101a69:	e8 d4 34 00 00       	call   80104f42 <sleep>
80101a6e:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101a71:	8b 45 08             	mov    0x8(%ebp),%eax
80101a74:	8b 40 0c             	mov    0xc(%eax),%eax
80101a77:	83 e0 01             	and    $0x1,%eax
80101a7a:	85 c0                	test   %eax,%eax
80101a7c:	75 e0                	jne    80101a5e <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a81:	8b 40 0c             	mov    0xc(%eax),%eax
80101a84:	83 c8 01             	or     $0x1,%eax
80101a87:	89 c2                	mov    %eax,%edx
80101a89:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8c:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101a8f:	83 ec 0c             	sub    $0xc,%esp
80101a92:	68 80 22 11 80       	push   $0x80112280
80101a97:	e8 04 41 00 00       	call   80105ba0 <release>
80101a9c:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
80101a9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa2:	8b 40 0c             	mov    0xc(%eax),%eax
80101aa5:	83 e0 02             	and    $0x2,%eax
80101aa8:	85 c0                	test   %eax,%eax
80101aaa:	0f 85 fc 00 00 00    	jne    80101bac <ilock+0x183>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101ab0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab3:	8b 40 04             	mov    0x4(%eax),%eax
80101ab6:	c1 e8 03             	shr    $0x3,%eax
80101ab9:	89 c2                	mov    %eax,%edx
80101abb:	a1 74 22 11 80       	mov    0x80112274,%eax
80101ac0:	01 c2                	add    %eax,%edx
80101ac2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac5:	8b 00                	mov    (%eax),%eax
80101ac7:	83 ec 08             	sub    $0x8,%esp
80101aca:	52                   	push   %edx
80101acb:	50                   	push   %eax
80101acc:	e8 e5 e6 ff ff       	call   801001b6 <bread>
80101ad1:	83 c4 10             	add    $0x10,%esp
80101ad4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ada:	8d 50 18             	lea    0x18(%eax),%edx
80101add:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae0:	8b 40 04             	mov    0x4(%eax),%eax
80101ae3:	83 e0 07             	and    $0x7,%eax
80101ae6:	c1 e0 06             	shl    $0x6,%eax
80101ae9:	01 d0                	add    %edx,%eax
80101aeb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101aee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101af1:	0f b7 10             	movzwl (%eax),%edx
80101af4:	8b 45 08             	mov    0x8(%ebp),%eax
80101af7:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101afb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101afe:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101b02:	8b 45 08             	mov    0x8(%ebp),%eax
80101b05:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101b09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b0c:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101b10:	8b 45 08             	mov    0x8(%ebp),%eax
80101b13:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101b17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b1a:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101b1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b21:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101b25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b28:	8b 50 10             	mov    0x10(%eax),%edx
80101b2b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2e:	89 50 20             	mov    %edx,0x20(%eax)
#ifdef CS333_P5
    ip->uid = dip -> uid;
80101b31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b34:	0f b7 50 08          	movzwl 0x8(%eax),%edx
80101b38:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3b:	66 89 50 18          	mov    %dx,0x18(%eax)
    ip->gid = dip -> gid;
80101b3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b42:	0f b7 50 0a          	movzwl 0xa(%eax),%edx
80101b46:	8b 45 08             	mov    0x8(%ebp),%eax
80101b49:	66 89 50 1a          	mov    %dx,0x1a(%eax)
    ip->mode.asInt = dip->mode.asInt;
80101b4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b50:	8b 50 0c             	mov    0xc(%eax),%edx
80101b53:	8b 45 08             	mov    0x8(%ebp),%eax
80101b56:	89 50 1c             	mov    %edx,0x1c(%eax)
#endif
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b5c:	8d 50 14             	lea    0x14(%eax),%edx
80101b5f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b62:	83 c0 24             	add    $0x24,%eax
80101b65:	83 ec 04             	sub    $0x4,%esp
80101b68:	6a 2c                	push   $0x2c
80101b6a:	52                   	push   %edx
80101b6b:	50                   	push   %eax
80101b6c:	e8 ea 42 00 00       	call   80105e5b <memmove>
80101b71:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101b74:	83 ec 0c             	sub    $0xc,%esp
80101b77:	ff 75 f4             	pushl  -0xc(%ebp)
80101b7a:	e8 af e6 ff ff       	call   8010022e <brelse>
80101b7f:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101b82:	8b 45 08             	mov    0x8(%ebp),%eax
80101b85:	8b 40 0c             	mov    0xc(%eax),%eax
80101b88:	83 c8 02             	or     $0x2,%eax
80101b8b:	89 c2                	mov    %eax,%edx
80101b8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b90:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101b93:	8b 45 08             	mov    0x8(%ebp),%eax
80101b96:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101b9a:	66 85 c0             	test   %ax,%ax
80101b9d:	75 0d                	jne    80101bac <ilock+0x183>
      panic("ilock: no type");
80101b9f:	83 ec 0c             	sub    $0xc,%esp
80101ba2:	68 b3 95 10 80       	push   $0x801095b3
80101ba7:	e8 ba e9 ff ff       	call   80100566 <panic>
  }
}
80101bac:	90                   	nop
80101bad:	c9                   	leave  
80101bae:	c3                   	ret    

80101baf <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101baf:	55                   	push   %ebp
80101bb0:	89 e5                	mov    %esp,%ebp
80101bb2:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101bb5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101bb9:	74 17                	je     80101bd2 <iunlock+0x23>
80101bbb:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbe:	8b 40 0c             	mov    0xc(%eax),%eax
80101bc1:	83 e0 01             	and    $0x1,%eax
80101bc4:	85 c0                	test   %eax,%eax
80101bc6:	74 0a                	je     80101bd2 <iunlock+0x23>
80101bc8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcb:	8b 40 08             	mov    0x8(%eax),%eax
80101bce:	85 c0                	test   %eax,%eax
80101bd0:	7f 0d                	jg     80101bdf <iunlock+0x30>
    panic("iunlock");
80101bd2:	83 ec 0c             	sub    $0xc,%esp
80101bd5:	68 c2 95 10 80       	push   $0x801095c2
80101bda:	e8 87 e9 ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101bdf:	83 ec 0c             	sub    $0xc,%esp
80101be2:	68 80 22 11 80       	push   $0x80112280
80101be7:	e8 4d 3f 00 00       	call   80105b39 <acquire>
80101bec:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101bef:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf2:	8b 40 0c             	mov    0xc(%eax),%eax
80101bf5:	83 e0 fe             	and    $0xfffffffe,%eax
80101bf8:	89 c2                	mov    %eax,%edx
80101bfa:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfd:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101c00:	83 ec 0c             	sub    $0xc,%esp
80101c03:	ff 75 08             	pushl  0x8(%ebp)
80101c06:	e8 1e 34 00 00       	call   80105029 <wakeup>
80101c0b:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101c0e:	83 ec 0c             	sub    $0xc,%esp
80101c11:	68 80 22 11 80       	push   $0x80112280
80101c16:	e8 85 3f 00 00       	call   80105ba0 <release>
80101c1b:	83 c4 10             	add    $0x10,%esp
}
80101c1e:	90                   	nop
80101c1f:	c9                   	leave  
80101c20:	c3                   	ret    

80101c21 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101c21:	55                   	push   %ebp
80101c22:	89 e5                	mov    %esp,%ebp
80101c24:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101c27:	83 ec 0c             	sub    $0xc,%esp
80101c2a:	68 80 22 11 80       	push   $0x80112280
80101c2f:	e8 05 3f 00 00       	call   80105b39 <acquire>
80101c34:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101c37:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3a:	8b 40 08             	mov    0x8(%eax),%eax
80101c3d:	83 f8 01             	cmp    $0x1,%eax
80101c40:	0f 85 a9 00 00 00    	jne    80101cef <iput+0xce>
80101c46:	8b 45 08             	mov    0x8(%ebp),%eax
80101c49:	8b 40 0c             	mov    0xc(%eax),%eax
80101c4c:	83 e0 02             	and    $0x2,%eax
80101c4f:	85 c0                	test   %eax,%eax
80101c51:	0f 84 98 00 00 00    	je     80101cef <iput+0xce>
80101c57:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101c5e:	66 85 c0             	test   %ax,%ax
80101c61:	0f 85 88 00 00 00    	jne    80101cef <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101c67:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6a:	8b 40 0c             	mov    0xc(%eax),%eax
80101c6d:	83 e0 01             	and    $0x1,%eax
80101c70:	85 c0                	test   %eax,%eax
80101c72:	74 0d                	je     80101c81 <iput+0x60>
      panic("iput busy");
80101c74:	83 ec 0c             	sub    $0xc,%esp
80101c77:	68 ca 95 10 80       	push   $0x801095ca
80101c7c:	e8 e5 e8 ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101c81:	8b 45 08             	mov    0x8(%ebp),%eax
80101c84:	8b 40 0c             	mov    0xc(%eax),%eax
80101c87:	83 c8 01             	or     $0x1,%eax
80101c8a:	89 c2                	mov    %eax,%edx
80101c8c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8f:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101c92:	83 ec 0c             	sub    $0xc,%esp
80101c95:	68 80 22 11 80       	push   $0x80112280
80101c9a:	e8 01 3f 00 00       	call   80105ba0 <release>
80101c9f:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101ca2:	83 ec 0c             	sub    $0xc,%esp
80101ca5:	ff 75 08             	pushl  0x8(%ebp)
80101ca8:	e8 a8 01 00 00       	call   80101e55 <itrunc>
80101cad:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101cb0:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb3:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101cb9:	83 ec 0c             	sub    $0xc,%esp
80101cbc:	ff 75 08             	pushl  0x8(%ebp)
80101cbf:	e8 63 fb ff ff       	call   80101827 <iupdate>
80101cc4:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101cc7:	83 ec 0c             	sub    $0xc,%esp
80101cca:	68 80 22 11 80       	push   $0x80112280
80101ccf:	e8 65 3e 00 00       	call   80105b39 <acquire>
80101cd4:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101cd7:	8b 45 08             	mov    0x8(%ebp),%eax
80101cda:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101ce1:	83 ec 0c             	sub    $0xc,%esp
80101ce4:	ff 75 08             	pushl  0x8(%ebp)
80101ce7:	e8 3d 33 00 00       	call   80105029 <wakeup>
80101cec:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101cef:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf2:	8b 40 08             	mov    0x8(%eax),%eax
80101cf5:	8d 50 ff             	lea    -0x1(%eax),%edx
80101cf8:	8b 45 08             	mov    0x8(%ebp),%eax
80101cfb:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101cfe:	83 ec 0c             	sub    $0xc,%esp
80101d01:	68 80 22 11 80       	push   $0x80112280
80101d06:	e8 95 3e 00 00       	call   80105ba0 <release>
80101d0b:	83 c4 10             	add    $0x10,%esp
}
80101d0e:	90                   	nop
80101d0f:	c9                   	leave  
80101d10:	c3                   	ret    

80101d11 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101d11:	55                   	push   %ebp
80101d12:	89 e5                	mov    %esp,%ebp
80101d14:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101d17:	83 ec 0c             	sub    $0xc,%esp
80101d1a:	ff 75 08             	pushl  0x8(%ebp)
80101d1d:	e8 8d fe ff ff       	call   80101baf <iunlock>
80101d22:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101d25:	83 ec 0c             	sub    $0xc,%esp
80101d28:	ff 75 08             	pushl  0x8(%ebp)
80101d2b:	e8 f1 fe ff ff       	call   80101c21 <iput>
80101d30:	83 c4 10             	add    $0x10,%esp
}
80101d33:	90                   	nop
80101d34:	c9                   	leave  
80101d35:	c3                   	ret    

80101d36 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101d36:	55                   	push   %ebp
80101d37:	89 e5                	mov    %esp,%ebp
80101d39:	53                   	push   %ebx
80101d3a:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101d3d:	83 7d 0c 09          	cmpl   $0x9,0xc(%ebp)
80101d41:	77 42                	ja     80101d85 <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101d43:	8b 45 08             	mov    0x8(%ebp),%eax
80101d46:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d49:	83 c2 08             	add    $0x8,%edx
80101d4c:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80101d50:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d53:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d57:	75 24                	jne    80101d7d <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d59:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5c:	8b 00                	mov    (%eax),%eax
80101d5e:	83 ec 0c             	sub    $0xc,%esp
80101d61:	50                   	push   %eax
80101d62:	e8 4a f7 ff ff       	call   801014b1 <balloc>
80101d67:	83 c4 10             	add    $0x10,%esp
80101d6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d70:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d73:	8d 4a 08             	lea    0x8(%edx),%ecx
80101d76:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d79:	89 54 88 04          	mov    %edx,0x4(%eax,%ecx,4)
    return addr;
80101d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d80:	e9 cb 00 00 00       	jmp    80101e50 <bmap+0x11a>
  }
  bn -= NDIRECT;
80101d85:	83 6d 0c 0a          	subl   $0xa,0xc(%ebp)

  if(bn < NINDIRECT){
80101d89:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d8d:	0f 87 b0 00 00 00    	ja     80101e43 <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d93:	8b 45 08             	mov    0x8(%ebp),%eax
80101d96:	8b 40 4c             	mov    0x4c(%eax),%eax
80101d99:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d9c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101da0:	75 1d                	jne    80101dbf <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101da2:	8b 45 08             	mov    0x8(%ebp),%eax
80101da5:	8b 00                	mov    (%eax),%eax
80101da7:	83 ec 0c             	sub    $0xc,%esp
80101daa:	50                   	push   %eax
80101dab:	e8 01 f7 ff ff       	call   801014b1 <balloc>
80101db0:	83 c4 10             	add    $0x10,%esp
80101db3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101db6:	8b 45 08             	mov    0x8(%ebp),%eax
80101db9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dbc:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101dbf:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc2:	8b 00                	mov    (%eax),%eax
80101dc4:	83 ec 08             	sub    $0x8,%esp
80101dc7:	ff 75 f4             	pushl  -0xc(%ebp)
80101dca:	50                   	push   %eax
80101dcb:	e8 e6 e3 ff ff       	call   801001b6 <bread>
80101dd0:	83 c4 10             	add    $0x10,%esp
80101dd3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101dd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dd9:	83 c0 18             	add    $0x18,%eax
80101ddc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101ddf:	8b 45 0c             	mov    0xc(%ebp),%eax
80101de2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101de9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dec:	01 d0                	add    %edx,%eax
80101dee:	8b 00                	mov    (%eax),%eax
80101df0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101df3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101df7:	75 37                	jne    80101e30 <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80101df9:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dfc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e03:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e06:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101e09:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0c:	8b 00                	mov    (%eax),%eax
80101e0e:	83 ec 0c             	sub    $0xc,%esp
80101e11:	50                   	push   %eax
80101e12:	e8 9a f6 ff ff       	call   801014b1 <balloc>
80101e17:	83 c4 10             	add    $0x10,%esp
80101e1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e20:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101e22:	83 ec 0c             	sub    $0xc,%esp
80101e25:	ff 75 f0             	pushl  -0x10(%ebp)
80101e28:	e8 67 1a 00 00       	call   80103894 <log_write>
80101e2d:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101e30:	83 ec 0c             	sub    $0xc,%esp
80101e33:	ff 75 f0             	pushl  -0x10(%ebp)
80101e36:	e8 f3 e3 ff ff       	call   8010022e <brelse>
80101e3b:	83 c4 10             	add    $0x10,%esp
    return addr;
80101e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e41:	eb 0d                	jmp    80101e50 <bmap+0x11a>
  }

  panic("bmap: out of range");
80101e43:	83 ec 0c             	sub    $0xc,%esp
80101e46:	68 d4 95 10 80       	push   $0x801095d4
80101e4b:	e8 16 e7 ff ff       	call   80100566 <panic>
}
80101e50:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101e53:	c9                   	leave  
80101e54:	c3                   	ret    

80101e55 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101e55:	55                   	push   %ebp
80101e56:	89 e5                	mov    %esp,%ebp
80101e58:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e5b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e62:	eb 45                	jmp    80101ea9 <itrunc+0x54>
    if(ip->addrs[i]){
80101e64:	8b 45 08             	mov    0x8(%ebp),%eax
80101e67:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e6a:	83 c2 08             	add    $0x8,%edx
80101e6d:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80101e71:	85 c0                	test   %eax,%eax
80101e73:	74 30                	je     80101ea5 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101e75:	8b 45 08             	mov    0x8(%ebp),%eax
80101e78:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e7b:	83 c2 08             	add    $0x8,%edx
80101e7e:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80101e82:	8b 55 08             	mov    0x8(%ebp),%edx
80101e85:	8b 12                	mov    (%edx),%edx
80101e87:	83 ec 08             	sub    $0x8,%esp
80101e8a:	50                   	push   %eax
80101e8b:	52                   	push   %edx
80101e8c:	e8 6c f7 ff ff       	call   801015fd <bfree>
80101e91:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101e94:	8b 45 08             	mov    0x8(%ebp),%eax
80101e97:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e9a:	83 c2 08             	add    $0x8,%edx
80101e9d:	c7 44 90 04 00 00 00 	movl   $0x0,0x4(%eax,%edx,4)
80101ea4:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101ea5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101ea9:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80101ead:	7e b5                	jle    80101e64 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
80101eaf:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb2:	8b 40 4c             	mov    0x4c(%eax),%eax
80101eb5:	85 c0                	test   %eax,%eax
80101eb7:	0f 84 a1 00 00 00    	je     80101f5e <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101ebd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec0:	8b 50 4c             	mov    0x4c(%eax),%edx
80101ec3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec6:	8b 00                	mov    (%eax),%eax
80101ec8:	83 ec 08             	sub    $0x8,%esp
80101ecb:	52                   	push   %edx
80101ecc:	50                   	push   %eax
80101ecd:	e8 e4 e2 ff ff       	call   801001b6 <bread>
80101ed2:	83 c4 10             	add    $0x10,%esp
80101ed5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101ed8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101edb:	83 c0 18             	add    $0x18,%eax
80101ede:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101ee1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101ee8:	eb 3c                	jmp    80101f26 <itrunc+0xd1>
      if(a[j])
80101eea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101eed:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ef4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ef7:	01 d0                	add    %edx,%eax
80101ef9:	8b 00                	mov    (%eax),%eax
80101efb:	85 c0                	test   %eax,%eax
80101efd:	74 23                	je     80101f22 <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101eff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f02:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f09:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f0c:	01 d0                	add    %edx,%eax
80101f0e:	8b 00                	mov    (%eax),%eax
80101f10:	8b 55 08             	mov    0x8(%ebp),%edx
80101f13:	8b 12                	mov    (%edx),%edx
80101f15:	83 ec 08             	sub    $0x8,%esp
80101f18:	50                   	push   %eax
80101f19:	52                   	push   %edx
80101f1a:	e8 de f6 ff ff       	call   801015fd <bfree>
80101f1f:	83 c4 10             	add    $0x10,%esp
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101f22:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101f26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f29:	83 f8 7f             	cmp    $0x7f,%eax
80101f2c:	76 bc                	jbe    80101eea <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101f2e:	83 ec 0c             	sub    $0xc,%esp
80101f31:	ff 75 ec             	pushl  -0x14(%ebp)
80101f34:	e8 f5 e2 ff ff       	call   8010022e <brelse>
80101f39:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101f3c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3f:	8b 40 4c             	mov    0x4c(%eax),%eax
80101f42:	8b 55 08             	mov    0x8(%ebp),%edx
80101f45:	8b 12                	mov    (%edx),%edx
80101f47:	83 ec 08             	sub    $0x8,%esp
80101f4a:	50                   	push   %eax
80101f4b:	52                   	push   %edx
80101f4c:	e8 ac f6 ff ff       	call   801015fd <bfree>
80101f51:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101f54:	8b 45 08             	mov    0x8(%ebp),%eax
80101f57:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101f5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f61:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
  iupdate(ip);
80101f68:	83 ec 0c             	sub    $0xc,%esp
80101f6b:	ff 75 08             	pushl  0x8(%ebp)
80101f6e:	e8 b4 f8 ff ff       	call   80101827 <iupdate>
80101f73:	83 c4 10             	add    $0x10,%esp
}
80101f76:	90                   	nop
80101f77:	c9                   	leave  
80101f78:	c3                   	ret    

80101f79 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101f79:	55                   	push   %ebp
80101f7a:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7f:	8b 00                	mov    (%eax),%eax
80101f81:	89 c2                	mov    %eax,%edx
80101f83:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f86:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f89:	8b 45 08             	mov    0x8(%ebp),%eax
80101f8c:	8b 50 04             	mov    0x4(%eax),%edx
80101f8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f92:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f95:	8b 45 08             	mov    0x8(%ebp),%eax
80101f98:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101f9c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f9f:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101fa2:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa5:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101fa9:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fac:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101fb0:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb3:	8b 50 20             	mov    0x20(%eax),%edx
80101fb6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fb9:	89 50 10             	mov    %edx,0x10(%eax)
#ifdef CS333_P5
  st->uid = ip -> uid;
80101fbc:	8b 45 08             	mov    0x8(%ebp),%eax
80101fbf:	0f b7 50 18          	movzwl 0x18(%eax),%edx
80101fc3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fc6:	66 89 50 18          	mov    %dx,0x18(%eax)
  st->gid = ip -> gid;
80101fca:	8b 45 08             	mov    0x8(%ebp),%eax
80101fcd:	0f b7 50 1a          	movzwl 0x1a(%eax),%edx
80101fd1:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fd4:	66 89 50 1a          	mov    %dx,0x1a(%eax)
  st->mode.asInt = ip->mode.asInt;
80101fd8:	8b 45 08             	mov    0x8(%ebp),%eax
80101fdb:	8b 50 1c             	mov    0x1c(%eax),%edx
80101fde:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fe1:	89 50 14             	mov    %edx,0x14(%eax)
#endif
}
80101fe4:	90                   	nop
80101fe5:	5d                   	pop    %ebp
80101fe6:	c3                   	ret    

80101fe7 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101fe7:	55                   	push   %ebp
80101fe8:	89 e5                	mov    %esp,%ebp
80101fea:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101fed:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ff4:	66 83 f8 03          	cmp    $0x3,%ax
80101ff8:	75 5c                	jne    80102056 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ffa:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffd:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102001:	66 85 c0             	test   %ax,%ax
80102004:	78 20                	js     80102026 <readi+0x3f>
80102006:	8b 45 08             	mov    0x8(%ebp),%eax
80102009:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010200d:	66 83 f8 09          	cmp    $0x9,%ax
80102011:	7f 13                	jg     80102026 <readi+0x3f>
80102013:	8b 45 08             	mov    0x8(%ebp),%eax
80102016:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010201a:	98                   	cwtl   
8010201b:	8b 04 c5 00 22 11 80 	mov    -0x7feede00(,%eax,8),%eax
80102022:	85 c0                	test   %eax,%eax
80102024:	75 0a                	jne    80102030 <readi+0x49>
      return -1;
80102026:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010202b:	e9 0c 01 00 00       	jmp    8010213c <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80102030:	8b 45 08             	mov    0x8(%ebp),%eax
80102033:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102037:	98                   	cwtl   
80102038:	8b 04 c5 00 22 11 80 	mov    -0x7feede00(,%eax,8),%eax
8010203f:	8b 55 14             	mov    0x14(%ebp),%edx
80102042:	83 ec 04             	sub    $0x4,%esp
80102045:	52                   	push   %edx
80102046:	ff 75 0c             	pushl  0xc(%ebp)
80102049:	ff 75 08             	pushl  0x8(%ebp)
8010204c:	ff d0                	call   *%eax
8010204e:	83 c4 10             	add    $0x10,%esp
80102051:	e9 e6 00 00 00       	jmp    8010213c <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80102056:	8b 45 08             	mov    0x8(%ebp),%eax
80102059:	8b 40 20             	mov    0x20(%eax),%eax
8010205c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010205f:	72 0d                	jb     8010206e <readi+0x87>
80102061:	8b 55 10             	mov    0x10(%ebp),%edx
80102064:	8b 45 14             	mov    0x14(%ebp),%eax
80102067:	01 d0                	add    %edx,%eax
80102069:	3b 45 10             	cmp    0x10(%ebp),%eax
8010206c:	73 0a                	jae    80102078 <readi+0x91>
    return -1;
8010206e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102073:	e9 c4 00 00 00       	jmp    8010213c <readi+0x155>
  if(off + n > ip->size)
80102078:	8b 55 10             	mov    0x10(%ebp),%edx
8010207b:	8b 45 14             	mov    0x14(%ebp),%eax
8010207e:	01 c2                	add    %eax,%edx
80102080:	8b 45 08             	mov    0x8(%ebp),%eax
80102083:	8b 40 20             	mov    0x20(%eax),%eax
80102086:	39 c2                	cmp    %eax,%edx
80102088:	76 0c                	jbe    80102096 <readi+0xaf>
    n = ip->size - off;
8010208a:	8b 45 08             	mov    0x8(%ebp),%eax
8010208d:	8b 40 20             	mov    0x20(%eax),%eax
80102090:	2b 45 10             	sub    0x10(%ebp),%eax
80102093:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102096:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010209d:	e9 8b 00 00 00       	jmp    8010212d <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020a2:	8b 45 10             	mov    0x10(%ebp),%eax
801020a5:	c1 e8 09             	shr    $0x9,%eax
801020a8:	83 ec 08             	sub    $0x8,%esp
801020ab:	50                   	push   %eax
801020ac:	ff 75 08             	pushl  0x8(%ebp)
801020af:	e8 82 fc ff ff       	call   80101d36 <bmap>
801020b4:	83 c4 10             	add    $0x10,%esp
801020b7:	89 c2                	mov    %eax,%edx
801020b9:	8b 45 08             	mov    0x8(%ebp),%eax
801020bc:	8b 00                	mov    (%eax),%eax
801020be:	83 ec 08             	sub    $0x8,%esp
801020c1:	52                   	push   %edx
801020c2:	50                   	push   %eax
801020c3:	e8 ee e0 ff ff       	call   801001b6 <bread>
801020c8:	83 c4 10             	add    $0x10,%esp
801020cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801020ce:	8b 45 10             	mov    0x10(%ebp),%eax
801020d1:	25 ff 01 00 00       	and    $0x1ff,%eax
801020d6:	ba 00 02 00 00       	mov    $0x200,%edx
801020db:	29 c2                	sub    %eax,%edx
801020dd:	8b 45 14             	mov    0x14(%ebp),%eax
801020e0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801020e3:	39 c2                	cmp    %eax,%edx
801020e5:	0f 46 c2             	cmovbe %edx,%eax
801020e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
801020eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020ee:	8d 50 18             	lea    0x18(%eax),%edx
801020f1:	8b 45 10             	mov    0x10(%ebp),%eax
801020f4:	25 ff 01 00 00       	and    $0x1ff,%eax
801020f9:	01 d0                	add    %edx,%eax
801020fb:	83 ec 04             	sub    $0x4,%esp
801020fe:	ff 75 ec             	pushl  -0x14(%ebp)
80102101:	50                   	push   %eax
80102102:	ff 75 0c             	pushl  0xc(%ebp)
80102105:	e8 51 3d 00 00       	call   80105e5b <memmove>
8010210a:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010210d:	83 ec 0c             	sub    $0xc,%esp
80102110:	ff 75 f0             	pushl  -0x10(%ebp)
80102113:	e8 16 e1 ff ff       	call   8010022e <brelse>
80102118:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010211b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010211e:	01 45 f4             	add    %eax,-0xc(%ebp)
80102121:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102124:	01 45 10             	add    %eax,0x10(%ebp)
80102127:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010212a:	01 45 0c             	add    %eax,0xc(%ebp)
8010212d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102130:	3b 45 14             	cmp    0x14(%ebp),%eax
80102133:	0f 82 69 ff ff ff    	jb     801020a2 <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80102139:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010213c:	c9                   	leave  
8010213d:	c3                   	ret    

8010213e <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010213e:	55                   	push   %ebp
8010213f:	89 e5                	mov    %esp,%ebp
80102141:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102144:	8b 45 08             	mov    0x8(%ebp),%eax
80102147:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010214b:	66 83 f8 03          	cmp    $0x3,%ax
8010214f:	75 5c                	jne    801021ad <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102151:	8b 45 08             	mov    0x8(%ebp),%eax
80102154:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102158:	66 85 c0             	test   %ax,%ax
8010215b:	78 20                	js     8010217d <writei+0x3f>
8010215d:	8b 45 08             	mov    0x8(%ebp),%eax
80102160:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102164:	66 83 f8 09          	cmp    $0x9,%ax
80102168:	7f 13                	jg     8010217d <writei+0x3f>
8010216a:	8b 45 08             	mov    0x8(%ebp),%eax
8010216d:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102171:	98                   	cwtl   
80102172:	8b 04 c5 04 22 11 80 	mov    -0x7feeddfc(,%eax,8),%eax
80102179:	85 c0                	test   %eax,%eax
8010217b:	75 0a                	jne    80102187 <writei+0x49>
      return -1;
8010217d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102182:	e9 3d 01 00 00       	jmp    801022c4 <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
80102187:	8b 45 08             	mov    0x8(%ebp),%eax
8010218a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010218e:	98                   	cwtl   
8010218f:	8b 04 c5 04 22 11 80 	mov    -0x7feeddfc(,%eax,8),%eax
80102196:	8b 55 14             	mov    0x14(%ebp),%edx
80102199:	83 ec 04             	sub    $0x4,%esp
8010219c:	52                   	push   %edx
8010219d:	ff 75 0c             	pushl  0xc(%ebp)
801021a0:	ff 75 08             	pushl  0x8(%ebp)
801021a3:	ff d0                	call   *%eax
801021a5:	83 c4 10             	add    $0x10,%esp
801021a8:	e9 17 01 00 00       	jmp    801022c4 <writei+0x186>
  }

  if(off > ip->size || off + n < off)
801021ad:	8b 45 08             	mov    0x8(%ebp),%eax
801021b0:	8b 40 20             	mov    0x20(%eax),%eax
801021b3:	3b 45 10             	cmp    0x10(%ebp),%eax
801021b6:	72 0d                	jb     801021c5 <writei+0x87>
801021b8:	8b 55 10             	mov    0x10(%ebp),%edx
801021bb:	8b 45 14             	mov    0x14(%ebp),%eax
801021be:	01 d0                	add    %edx,%eax
801021c0:	3b 45 10             	cmp    0x10(%ebp),%eax
801021c3:	73 0a                	jae    801021cf <writei+0x91>
    return -1;
801021c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021ca:	e9 f5 00 00 00       	jmp    801022c4 <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
801021cf:	8b 55 10             	mov    0x10(%ebp),%edx
801021d2:	8b 45 14             	mov    0x14(%ebp),%eax
801021d5:	01 d0                	add    %edx,%eax
801021d7:	3d 00 14 01 00       	cmp    $0x11400,%eax
801021dc:	76 0a                	jbe    801021e8 <writei+0xaa>
    return -1;
801021de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021e3:	e9 dc 00 00 00       	jmp    801022c4 <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801021e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021ef:	e9 99 00 00 00       	jmp    8010228d <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801021f4:	8b 45 10             	mov    0x10(%ebp),%eax
801021f7:	c1 e8 09             	shr    $0x9,%eax
801021fa:	83 ec 08             	sub    $0x8,%esp
801021fd:	50                   	push   %eax
801021fe:	ff 75 08             	pushl  0x8(%ebp)
80102201:	e8 30 fb ff ff       	call   80101d36 <bmap>
80102206:	83 c4 10             	add    $0x10,%esp
80102209:	89 c2                	mov    %eax,%edx
8010220b:	8b 45 08             	mov    0x8(%ebp),%eax
8010220e:	8b 00                	mov    (%eax),%eax
80102210:	83 ec 08             	sub    $0x8,%esp
80102213:	52                   	push   %edx
80102214:	50                   	push   %eax
80102215:	e8 9c df ff ff       	call   801001b6 <bread>
8010221a:	83 c4 10             	add    $0x10,%esp
8010221d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102220:	8b 45 10             	mov    0x10(%ebp),%eax
80102223:	25 ff 01 00 00       	and    $0x1ff,%eax
80102228:	ba 00 02 00 00       	mov    $0x200,%edx
8010222d:	29 c2                	sub    %eax,%edx
8010222f:	8b 45 14             	mov    0x14(%ebp),%eax
80102232:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102235:	39 c2                	cmp    %eax,%edx
80102237:	0f 46 c2             	cmovbe %edx,%eax
8010223a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010223d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102240:	8d 50 18             	lea    0x18(%eax),%edx
80102243:	8b 45 10             	mov    0x10(%ebp),%eax
80102246:	25 ff 01 00 00       	and    $0x1ff,%eax
8010224b:	01 d0                	add    %edx,%eax
8010224d:	83 ec 04             	sub    $0x4,%esp
80102250:	ff 75 ec             	pushl  -0x14(%ebp)
80102253:	ff 75 0c             	pushl  0xc(%ebp)
80102256:	50                   	push   %eax
80102257:	e8 ff 3b 00 00       	call   80105e5b <memmove>
8010225c:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010225f:	83 ec 0c             	sub    $0xc,%esp
80102262:	ff 75 f0             	pushl  -0x10(%ebp)
80102265:	e8 2a 16 00 00       	call   80103894 <log_write>
8010226a:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010226d:	83 ec 0c             	sub    $0xc,%esp
80102270:	ff 75 f0             	pushl  -0x10(%ebp)
80102273:	e8 b6 df ff ff       	call   8010022e <brelse>
80102278:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010227b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010227e:	01 45 f4             	add    %eax,-0xc(%ebp)
80102281:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102284:	01 45 10             	add    %eax,0x10(%ebp)
80102287:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010228a:	01 45 0c             	add    %eax,0xc(%ebp)
8010228d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102290:	3b 45 14             	cmp    0x14(%ebp),%eax
80102293:	0f 82 5b ff ff ff    	jb     801021f4 <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102299:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010229d:	74 22                	je     801022c1 <writei+0x183>
8010229f:	8b 45 08             	mov    0x8(%ebp),%eax
801022a2:	8b 40 20             	mov    0x20(%eax),%eax
801022a5:	3b 45 10             	cmp    0x10(%ebp),%eax
801022a8:	73 17                	jae    801022c1 <writei+0x183>
    ip->size = off;
801022aa:	8b 45 08             	mov    0x8(%ebp),%eax
801022ad:	8b 55 10             	mov    0x10(%ebp),%edx
801022b0:	89 50 20             	mov    %edx,0x20(%eax)
    iupdate(ip);
801022b3:	83 ec 0c             	sub    $0xc,%esp
801022b6:	ff 75 08             	pushl  0x8(%ebp)
801022b9:	e8 69 f5 ff ff       	call   80101827 <iupdate>
801022be:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801022c1:	8b 45 14             	mov    0x14(%ebp),%eax
}
801022c4:	c9                   	leave  
801022c5:	c3                   	ret    

801022c6 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801022c6:	55                   	push   %ebp
801022c7:	89 e5                	mov    %esp,%ebp
801022c9:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801022cc:	83 ec 04             	sub    $0x4,%esp
801022cf:	6a 0e                	push   $0xe
801022d1:	ff 75 0c             	pushl  0xc(%ebp)
801022d4:	ff 75 08             	pushl  0x8(%ebp)
801022d7:	e8 15 3c 00 00       	call   80105ef1 <strncmp>
801022dc:	83 c4 10             	add    $0x10,%esp
}
801022df:	c9                   	leave  
801022e0:	c3                   	ret    

801022e1 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801022e1:	55                   	push   %ebp
801022e2:	89 e5                	mov    %esp,%ebp
801022e4:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801022e7:	8b 45 08             	mov    0x8(%ebp),%eax
801022ea:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801022ee:	66 83 f8 01          	cmp    $0x1,%ax
801022f2:	74 0d                	je     80102301 <dirlookup+0x20>
    panic("dirlookup not DIR");
801022f4:	83 ec 0c             	sub    $0xc,%esp
801022f7:	68 e7 95 10 80       	push   $0x801095e7
801022fc:	e8 65 e2 ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102301:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102308:	eb 7b                	jmp    80102385 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010230a:	6a 10                	push   $0x10
8010230c:	ff 75 f4             	pushl  -0xc(%ebp)
8010230f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102312:	50                   	push   %eax
80102313:	ff 75 08             	pushl  0x8(%ebp)
80102316:	e8 cc fc ff ff       	call   80101fe7 <readi>
8010231b:	83 c4 10             	add    $0x10,%esp
8010231e:	83 f8 10             	cmp    $0x10,%eax
80102321:	74 0d                	je     80102330 <dirlookup+0x4f>
      panic("dirlink read");
80102323:	83 ec 0c             	sub    $0xc,%esp
80102326:	68 f9 95 10 80       	push   $0x801095f9
8010232b:	e8 36 e2 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
80102330:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102334:	66 85 c0             	test   %ax,%ax
80102337:	74 47                	je     80102380 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102339:	83 ec 08             	sub    $0x8,%esp
8010233c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010233f:	83 c0 02             	add    $0x2,%eax
80102342:	50                   	push   %eax
80102343:	ff 75 0c             	pushl  0xc(%ebp)
80102346:	e8 7b ff ff ff       	call   801022c6 <namecmp>
8010234b:	83 c4 10             	add    $0x10,%esp
8010234e:	85 c0                	test   %eax,%eax
80102350:	75 2f                	jne    80102381 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102352:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102356:	74 08                	je     80102360 <dirlookup+0x7f>
        *poff = off;
80102358:	8b 45 10             	mov    0x10(%ebp),%eax
8010235b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010235e:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102360:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102364:	0f b7 c0             	movzwl %ax,%eax
80102367:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010236a:	8b 45 08             	mov    0x8(%ebp),%eax
8010236d:	8b 00                	mov    (%eax),%eax
8010236f:	83 ec 08             	sub    $0x8,%esp
80102372:	ff 75 f0             	pushl  -0x10(%ebp)
80102375:	50                   	push   %eax
80102376:	e8 95 f5 ff ff       	call   80101910 <iget>
8010237b:	83 c4 10             	add    $0x10,%esp
8010237e:	eb 19                	jmp    80102399 <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102380:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102381:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102385:	8b 45 08             	mov    0x8(%ebp),%eax
80102388:	8b 40 20             	mov    0x20(%eax),%eax
8010238b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010238e:	0f 87 76 ff ff ff    	ja     8010230a <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102394:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102399:	c9                   	leave  
8010239a:	c3                   	ret    

8010239b <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010239b:	55                   	push   %ebp
8010239c:	89 e5                	mov    %esp,%ebp
8010239e:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801023a1:	83 ec 04             	sub    $0x4,%esp
801023a4:	6a 00                	push   $0x0
801023a6:	ff 75 0c             	pushl  0xc(%ebp)
801023a9:	ff 75 08             	pushl  0x8(%ebp)
801023ac:	e8 30 ff ff ff       	call   801022e1 <dirlookup>
801023b1:	83 c4 10             	add    $0x10,%esp
801023b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801023b7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023bb:	74 18                	je     801023d5 <dirlink+0x3a>
    iput(ip);
801023bd:	83 ec 0c             	sub    $0xc,%esp
801023c0:	ff 75 f0             	pushl  -0x10(%ebp)
801023c3:	e8 59 f8 ff ff       	call   80101c21 <iput>
801023c8:	83 c4 10             	add    $0x10,%esp
    return -1;
801023cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801023d0:	e9 9c 00 00 00       	jmp    80102471 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801023d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023dc:	eb 39                	jmp    80102417 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023e1:	6a 10                	push   $0x10
801023e3:	50                   	push   %eax
801023e4:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023e7:	50                   	push   %eax
801023e8:	ff 75 08             	pushl  0x8(%ebp)
801023eb:	e8 f7 fb ff ff       	call   80101fe7 <readi>
801023f0:	83 c4 10             	add    $0x10,%esp
801023f3:	83 f8 10             	cmp    $0x10,%eax
801023f6:	74 0d                	je     80102405 <dirlink+0x6a>
      panic("dirlink read");
801023f8:	83 ec 0c             	sub    $0xc,%esp
801023fb:	68 f9 95 10 80       	push   $0x801095f9
80102400:	e8 61 e1 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
80102405:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102409:	66 85 c0             	test   %ax,%ax
8010240c:	74 18                	je     80102426 <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010240e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102411:	83 c0 10             	add    $0x10,%eax
80102414:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102417:	8b 45 08             	mov    0x8(%ebp),%eax
8010241a:	8b 50 20             	mov    0x20(%eax),%edx
8010241d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102420:	39 c2                	cmp    %eax,%edx
80102422:	77 ba                	ja     801023de <dirlink+0x43>
80102424:	eb 01                	jmp    80102427 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
80102426:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102427:	83 ec 04             	sub    $0x4,%esp
8010242a:	6a 0e                	push   $0xe
8010242c:	ff 75 0c             	pushl  0xc(%ebp)
8010242f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102432:	83 c0 02             	add    $0x2,%eax
80102435:	50                   	push   %eax
80102436:	e8 0c 3b 00 00       	call   80105f47 <strncpy>
8010243b:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
8010243e:	8b 45 10             	mov    0x10(%ebp),%eax
80102441:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102445:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102448:	6a 10                	push   $0x10
8010244a:	50                   	push   %eax
8010244b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010244e:	50                   	push   %eax
8010244f:	ff 75 08             	pushl  0x8(%ebp)
80102452:	e8 e7 fc ff ff       	call   8010213e <writei>
80102457:	83 c4 10             	add    $0x10,%esp
8010245a:	83 f8 10             	cmp    $0x10,%eax
8010245d:	74 0d                	je     8010246c <dirlink+0xd1>
    panic("dirlink");
8010245f:	83 ec 0c             	sub    $0xc,%esp
80102462:	68 06 96 10 80       	push   $0x80109606
80102467:	e8 fa e0 ff ff       	call   80100566 <panic>

  return 0;
8010246c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102471:	c9                   	leave  
80102472:	c3                   	ret    

80102473 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102473:	55                   	push   %ebp
80102474:	89 e5                	mov    %esp,%ebp
80102476:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102479:	eb 04                	jmp    8010247f <skipelem+0xc>
    path++;
8010247b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
8010247f:	8b 45 08             	mov    0x8(%ebp),%eax
80102482:	0f b6 00             	movzbl (%eax),%eax
80102485:	3c 2f                	cmp    $0x2f,%al
80102487:	74 f2                	je     8010247b <skipelem+0x8>
    path++;
  if(*path == 0)
80102489:	8b 45 08             	mov    0x8(%ebp),%eax
8010248c:	0f b6 00             	movzbl (%eax),%eax
8010248f:	84 c0                	test   %al,%al
80102491:	75 07                	jne    8010249a <skipelem+0x27>
    return 0;
80102493:	b8 00 00 00 00       	mov    $0x0,%eax
80102498:	eb 7b                	jmp    80102515 <skipelem+0xa2>
  s = path;
8010249a:	8b 45 08             	mov    0x8(%ebp),%eax
8010249d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801024a0:	eb 04                	jmp    801024a6 <skipelem+0x33>
    path++;
801024a2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801024a6:	8b 45 08             	mov    0x8(%ebp),%eax
801024a9:	0f b6 00             	movzbl (%eax),%eax
801024ac:	3c 2f                	cmp    $0x2f,%al
801024ae:	74 0a                	je     801024ba <skipelem+0x47>
801024b0:	8b 45 08             	mov    0x8(%ebp),%eax
801024b3:	0f b6 00             	movzbl (%eax),%eax
801024b6:	84 c0                	test   %al,%al
801024b8:	75 e8                	jne    801024a2 <skipelem+0x2f>
    path++;
  len = path - s;
801024ba:	8b 55 08             	mov    0x8(%ebp),%edx
801024bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024c0:	29 c2                	sub    %eax,%edx
801024c2:	89 d0                	mov    %edx,%eax
801024c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801024c7:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801024cb:	7e 15                	jle    801024e2 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
801024cd:	83 ec 04             	sub    $0x4,%esp
801024d0:	6a 0e                	push   $0xe
801024d2:	ff 75 f4             	pushl  -0xc(%ebp)
801024d5:	ff 75 0c             	pushl  0xc(%ebp)
801024d8:	e8 7e 39 00 00       	call   80105e5b <memmove>
801024dd:	83 c4 10             	add    $0x10,%esp
801024e0:	eb 26                	jmp    80102508 <skipelem+0x95>
  else {
    memmove(name, s, len);
801024e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024e5:	83 ec 04             	sub    $0x4,%esp
801024e8:	50                   	push   %eax
801024e9:	ff 75 f4             	pushl  -0xc(%ebp)
801024ec:	ff 75 0c             	pushl  0xc(%ebp)
801024ef:	e8 67 39 00 00       	call   80105e5b <memmove>
801024f4:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801024f7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801024fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801024fd:	01 d0                	add    %edx,%eax
801024ff:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102502:	eb 04                	jmp    80102508 <skipelem+0x95>
    path++;
80102504:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102508:	8b 45 08             	mov    0x8(%ebp),%eax
8010250b:	0f b6 00             	movzbl (%eax),%eax
8010250e:	3c 2f                	cmp    $0x2f,%al
80102510:	74 f2                	je     80102504 <skipelem+0x91>
    path++;
  return path;
80102512:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102515:	c9                   	leave  
80102516:	c3                   	ret    

80102517 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102517:	55                   	push   %ebp
80102518:	89 e5                	mov    %esp,%ebp
8010251a:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010251d:	8b 45 08             	mov    0x8(%ebp),%eax
80102520:	0f b6 00             	movzbl (%eax),%eax
80102523:	3c 2f                	cmp    $0x2f,%al
80102525:	75 17                	jne    8010253e <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
80102527:	83 ec 08             	sub    $0x8,%esp
8010252a:	6a 01                	push   $0x1
8010252c:	6a 01                	push   $0x1
8010252e:	e8 dd f3 ff ff       	call   80101910 <iget>
80102533:	83 c4 10             	add    $0x10,%esp
80102536:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102539:	e9 bb 00 00 00       	jmp    801025f9 <namex+0xe2>
  else
    ip = idup(proc->cwd);
8010253e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102544:	8b 40 68             	mov    0x68(%eax),%eax
80102547:	83 ec 0c             	sub    $0xc,%esp
8010254a:	50                   	push   %eax
8010254b:	e8 9f f4 ff ff       	call   801019ef <idup>
80102550:	83 c4 10             	add    $0x10,%esp
80102553:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102556:	e9 9e 00 00 00       	jmp    801025f9 <namex+0xe2>
    ilock(ip);
8010255b:	83 ec 0c             	sub    $0xc,%esp
8010255e:	ff 75 f4             	pushl  -0xc(%ebp)
80102561:	e8 c3 f4 ff ff       	call   80101a29 <ilock>
80102566:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102569:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010256c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102570:	66 83 f8 01          	cmp    $0x1,%ax
80102574:	74 18                	je     8010258e <namex+0x77>
      iunlockput(ip);
80102576:	83 ec 0c             	sub    $0xc,%esp
80102579:	ff 75 f4             	pushl  -0xc(%ebp)
8010257c:	e8 90 f7 ff ff       	call   80101d11 <iunlockput>
80102581:	83 c4 10             	add    $0x10,%esp
      return 0;
80102584:	b8 00 00 00 00       	mov    $0x0,%eax
80102589:	e9 a7 00 00 00       	jmp    80102635 <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
8010258e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102592:	74 20                	je     801025b4 <namex+0x9d>
80102594:	8b 45 08             	mov    0x8(%ebp),%eax
80102597:	0f b6 00             	movzbl (%eax),%eax
8010259a:	84 c0                	test   %al,%al
8010259c:	75 16                	jne    801025b4 <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
8010259e:	83 ec 0c             	sub    $0xc,%esp
801025a1:	ff 75 f4             	pushl  -0xc(%ebp)
801025a4:	e8 06 f6 ff ff       	call   80101baf <iunlock>
801025a9:	83 c4 10             	add    $0x10,%esp
      return ip;
801025ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025af:	e9 81 00 00 00       	jmp    80102635 <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801025b4:	83 ec 04             	sub    $0x4,%esp
801025b7:	6a 00                	push   $0x0
801025b9:	ff 75 10             	pushl  0x10(%ebp)
801025bc:	ff 75 f4             	pushl  -0xc(%ebp)
801025bf:	e8 1d fd ff ff       	call   801022e1 <dirlookup>
801025c4:	83 c4 10             	add    $0x10,%esp
801025c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801025ca:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801025ce:	75 15                	jne    801025e5 <namex+0xce>
      iunlockput(ip);
801025d0:	83 ec 0c             	sub    $0xc,%esp
801025d3:	ff 75 f4             	pushl  -0xc(%ebp)
801025d6:	e8 36 f7 ff ff       	call   80101d11 <iunlockput>
801025db:	83 c4 10             	add    $0x10,%esp
      return 0;
801025de:	b8 00 00 00 00       	mov    $0x0,%eax
801025e3:	eb 50                	jmp    80102635 <namex+0x11e>
    }
    iunlockput(ip);
801025e5:	83 ec 0c             	sub    $0xc,%esp
801025e8:	ff 75 f4             	pushl  -0xc(%ebp)
801025eb:	e8 21 f7 ff ff       	call   80101d11 <iunlockput>
801025f0:	83 c4 10             	add    $0x10,%esp
    ip = next;
801025f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801025f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801025f9:	83 ec 08             	sub    $0x8,%esp
801025fc:	ff 75 10             	pushl  0x10(%ebp)
801025ff:	ff 75 08             	pushl  0x8(%ebp)
80102602:	e8 6c fe ff ff       	call   80102473 <skipelem>
80102607:	83 c4 10             	add    $0x10,%esp
8010260a:	89 45 08             	mov    %eax,0x8(%ebp)
8010260d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102611:	0f 85 44 ff ff ff    	jne    8010255b <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102617:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010261b:	74 15                	je     80102632 <namex+0x11b>
    iput(ip);
8010261d:	83 ec 0c             	sub    $0xc,%esp
80102620:	ff 75 f4             	pushl  -0xc(%ebp)
80102623:	e8 f9 f5 ff ff       	call   80101c21 <iput>
80102628:	83 c4 10             	add    $0x10,%esp
    return 0;
8010262b:	b8 00 00 00 00       	mov    $0x0,%eax
80102630:	eb 03                	jmp    80102635 <namex+0x11e>
  }
  return ip;
80102632:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102635:	c9                   	leave  
80102636:	c3                   	ret    

80102637 <namei>:

struct inode*
namei(char *path)
{
80102637:	55                   	push   %ebp
80102638:	89 e5                	mov    %esp,%ebp
8010263a:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010263d:	83 ec 04             	sub    $0x4,%esp
80102640:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102643:	50                   	push   %eax
80102644:	6a 00                	push   $0x0
80102646:	ff 75 08             	pushl  0x8(%ebp)
80102649:	e8 c9 fe ff ff       	call   80102517 <namex>
8010264e:	83 c4 10             	add    $0x10,%esp
}
80102651:	c9                   	leave  
80102652:	c3                   	ret    

80102653 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102653:	55                   	push   %ebp
80102654:	89 e5                	mov    %esp,%ebp
80102656:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102659:	83 ec 04             	sub    $0x4,%esp
8010265c:	ff 75 0c             	pushl  0xc(%ebp)
8010265f:	6a 01                	push   $0x1
80102661:	ff 75 08             	pushl  0x8(%ebp)
80102664:	e8 ae fe ff ff       	call   80102517 <namex>
80102669:	83 c4 10             	add    $0x10,%esp
}
8010266c:	c9                   	leave  
8010266d:	c3                   	ret    

8010266e <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
8010266e:	55                   	push   %ebp
8010266f:	89 e5                	mov    %esp,%ebp
80102671:	83 ec 14             	sub    $0x14,%esp
80102674:	8b 45 08             	mov    0x8(%ebp),%eax
80102677:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010267b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010267f:	89 c2                	mov    %eax,%edx
80102681:	ec                   	in     (%dx),%al
80102682:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102685:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102689:	c9                   	leave  
8010268a:	c3                   	ret    

8010268b <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
8010268b:	55                   	push   %ebp
8010268c:	89 e5                	mov    %esp,%ebp
8010268e:	57                   	push   %edi
8010268f:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102690:	8b 55 08             	mov    0x8(%ebp),%edx
80102693:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102696:	8b 45 10             	mov    0x10(%ebp),%eax
80102699:	89 cb                	mov    %ecx,%ebx
8010269b:	89 df                	mov    %ebx,%edi
8010269d:	89 c1                	mov    %eax,%ecx
8010269f:	fc                   	cld    
801026a0:	f3 6d                	rep insl (%dx),%es:(%edi)
801026a2:	89 c8                	mov    %ecx,%eax
801026a4:	89 fb                	mov    %edi,%ebx
801026a6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801026a9:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801026ac:	90                   	nop
801026ad:	5b                   	pop    %ebx
801026ae:	5f                   	pop    %edi
801026af:	5d                   	pop    %ebp
801026b0:	c3                   	ret    

801026b1 <outb>:

static inline void
outb(ushort port, uchar data)
{
801026b1:	55                   	push   %ebp
801026b2:	89 e5                	mov    %esp,%ebp
801026b4:	83 ec 08             	sub    $0x8,%esp
801026b7:	8b 55 08             	mov    0x8(%ebp),%edx
801026ba:	8b 45 0c             	mov    0xc(%ebp),%eax
801026bd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801026c1:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801026c4:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801026c8:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801026cc:	ee                   	out    %al,(%dx)
}
801026cd:	90                   	nop
801026ce:	c9                   	leave  
801026cf:	c3                   	ret    

801026d0 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801026d0:	55                   	push   %ebp
801026d1:	89 e5                	mov    %esp,%ebp
801026d3:	56                   	push   %esi
801026d4:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801026d5:	8b 55 08             	mov    0x8(%ebp),%edx
801026d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801026db:	8b 45 10             	mov    0x10(%ebp),%eax
801026de:	89 cb                	mov    %ecx,%ebx
801026e0:	89 de                	mov    %ebx,%esi
801026e2:	89 c1                	mov    %eax,%ecx
801026e4:	fc                   	cld    
801026e5:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801026e7:	89 c8                	mov    %ecx,%eax
801026e9:	89 f3                	mov    %esi,%ebx
801026eb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801026ee:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801026f1:	90                   	nop
801026f2:	5b                   	pop    %ebx
801026f3:	5e                   	pop    %esi
801026f4:	5d                   	pop    %ebp
801026f5:	c3                   	ret    

801026f6 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801026f6:	55                   	push   %ebp
801026f7:	89 e5                	mov    %esp,%ebp
801026f9:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801026fc:	90                   	nop
801026fd:	68 f7 01 00 00       	push   $0x1f7
80102702:	e8 67 ff ff ff       	call   8010266e <inb>
80102707:	83 c4 04             	add    $0x4,%esp
8010270a:	0f b6 c0             	movzbl %al,%eax
8010270d:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102710:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102713:	25 c0 00 00 00       	and    $0xc0,%eax
80102718:	83 f8 40             	cmp    $0x40,%eax
8010271b:	75 e0                	jne    801026fd <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010271d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102721:	74 11                	je     80102734 <idewait+0x3e>
80102723:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102726:	83 e0 21             	and    $0x21,%eax
80102729:	85 c0                	test   %eax,%eax
8010272b:	74 07                	je     80102734 <idewait+0x3e>
    return -1;
8010272d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102732:	eb 05                	jmp    80102739 <idewait+0x43>
  return 0;
80102734:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102739:	c9                   	leave  
8010273a:	c3                   	ret    

8010273b <ideinit>:

void
ideinit(void)
{
8010273b:	55                   	push   %ebp
8010273c:	89 e5                	mov    %esp,%ebp
8010273e:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
80102741:	83 ec 08             	sub    $0x8,%esp
80102744:	68 0e 96 10 80       	push   $0x8010960e
80102749:	68 40 c6 10 80       	push   $0x8010c640
8010274e:	e8 c4 33 00 00       	call   80105b17 <initlock>
80102753:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
80102756:	83 ec 0c             	sub    $0xc,%esp
80102759:	6a 0e                	push   $0xe
8010275b:	e8 da 18 00 00       	call   8010403a <picenable>
80102760:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102763:	a1 80 39 11 80       	mov    0x80113980,%eax
80102768:	83 e8 01             	sub    $0x1,%eax
8010276b:	83 ec 08             	sub    $0x8,%esp
8010276e:	50                   	push   %eax
8010276f:	6a 0e                	push   $0xe
80102771:	e8 73 04 00 00       	call   80102be9 <ioapicenable>
80102776:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102779:	83 ec 0c             	sub    $0xc,%esp
8010277c:	6a 00                	push   $0x0
8010277e:	e8 73 ff ff ff       	call   801026f6 <idewait>
80102783:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102786:	83 ec 08             	sub    $0x8,%esp
80102789:	68 f0 00 00 00       	push   $0xf0
8010278e:	68 f6 01 00 00       	push   $0x1f6
80102793:	e8 19 ff ff ff       	call   801026b1 <outb>
80102798:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
8010279b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801027a2:	eb 24                	jmp    801027c8 <ideinit+0x8d>
    if(inb(0x1f7) != 0){
801027a4:	83 ec 0c             	sub    $0xc,%esp
801027a7:	68 f7 01 00 00       	push   $0x1f7
801027ac:	e8 bd fe ff ff       	call   8010266e <inb>
801027b1:	83 c4 10             	add    $0x10,%esp
801027b4:	84 c0                	test   %al,%al
801027b6:	74 0c                	je     801027c4 <ideinit+0x89>
      havedisk1 = 1;
801027b8:	c7 05 78 c6 10 80 01 	movl   $0x1,0x8010c678
801027bf:	00 00 00 
      break;
801027c2:	eb 0d                	jmp    801027d1 <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801027c4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801027c8:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801027cf:	7e d3                	jle    801027a4 <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801027d1:	83 ec 08             	sub    $0x8,%esp
801027d4:	68 e0 00 00 00       	push   $0xe0
801027d9:	68 f6 01 00 00       	push   $0x1f6
801027de:	e8 ce fe ff ff       	call   801026b1 <outb>
801027e3:	83 c4 10             	add    $0x10,%esp
}
801027e6:	90                   	nop
801027e7:	c9                   	leave  
801027e8:	c3                   	ret    

801027e9 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801027e9:	55                   	push   %ebp
801027ea:	89 e5                	mov    %esp,%ebp
801027ec:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801027ef:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801027f3:	75 0d                	jne    80102802 <idestart+0x19>
    panic("idestart");
801027f5:	83 ec 0c             	sub    $0xc,%esp
801027f8:	68 12 96 10 80       	push   $0x80109612
801027fd:	e8 64 dd ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE)
80102802:	8b 45 08             	mov    0x8(%ebp),%eax
80102805:	8b 40 08             	mov    0x8(%eax),%eax
80102808:	3d cf 07 00 00       	cmp    $0x7cf,%eax
8010280d:	76 0d                	jbe    8010281c <idestart+0x33>
    panic("incorrect blockno");
8010280f:	83 ec 0c             	sub    $0xc,%esp
80102812:	68 1b 96 10 80       	push   $0x8010961b
80102817:	e8 4a dd ff ff       	call   80100566 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
8010281c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102823:	8b 45 08             	mov    0x8(%ebp),%eax
80102826:	8b 50 08             	mov    0x8(%eax),%edx
80102829:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010282c:	0f af c2             	imul   %edx,%eax
8010282f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102832:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102836:	7e 0d                	jle    80102845 <idestart+0x5c>
80102838:	83 ec 0c             	sub    $0xc,%esp
8010283b:	68 12 96 10 80       	push   $0x80109612
80102840:	e8 21 dd ff ff       	call   80100566 <panic>
  
  idewait(0);
80102845:	83 ec 0c             	sub    $0xc,%esp
80102848:	6a 00                	push   $0x0
8010284a:	e8 a7 fe ff ff       	call   801026f6 <idewait>
8010284f:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102852:	83 ec 08             	sub    $0x8,%esp
80102855:	6a 00                	push   $0x0
80102857:	68 f6 03 00 00       	push   $0x3f6
8010285c:	e8 50 fe ff ff       	call   801026b1 <outb>
80102861:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102864:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102867:	0f b6 c0             	movzbl %al,%eax
8010286a:	83 ec 08             	sub    $0x8,%esp
8010286d:	50                   	push   %eax
8010286e:	68 f2 01 00 00       	push   $0x1f2
80102873:	e8 39 fe ff ff       	call   801026b1 <outb>
80102878:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
8010287b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010287e:	0f b6 c0             	movzbl %al,%eax
80102881:	83 ec 08             	sub    $0x8,%esp
80102884:	50                   	push   %eax
80102885:	68 f3 01 00 00       	push   $0x1f3
8010288a:	e8 22 fe ff ff       	call   801026b1 <outb>
8010288f:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102892:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102895:	c1 f8 08             	sar    $0x8,%eax
80102898:	0f b6 c0             	movzbl %al,%eax
8010289b:	83 ec 08             	sub    $0x8,%esp
8010289e:	50                   	push   %eax
8010289f:	68 f4 01 00 00       	push   $0x1f4
801028a4:	e8 08 fe ff ff       	call   801026b1 <outb>
801028a9:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
801028ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801028af:	c1 f8 10             	sar    $0x10,%eax
801028b2:	0f b6 c0             	movzbl %al,%eax
801028b5:	83 ec 08             	sub    $0x8,%esp
801028b8:	50                   	push   %eax
801028b9:	68 f5 01 00 00       	push   $0x1f5
801028be:	e8 ee fd ff ff       	call   801026b1 <outb>
801028c3:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801028c6:	8b 45 08             	mov    0x8(%ebp),%eax
801028c9:	8b 40 04             	mov    0x4(%eax),%eax
801028cc:	83 e0 01             	and    $0x1,%eax
801028cf:	c1 e0 04             	shl    $0x4,%eax
801028d2:	89 c2                	mov    %eax,%edx
801028d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801028d7:	c1 f8 18             	sar    $0x18,%eax
801028da:	83 e0 0f             	and    $0xf,%eax
801028dd:	09 d0                	or     %edx,%eax
801028df:	83 c8 e0             	or     $0xffffffe0,%eax
801028e2:	0f b6 c0             	movzbl %al,%eax
801028e5:	83 ec 08             	sub    $0x8,%esp
801028e8:	50                   	push   %eax
801028e9:	68 f6 01 00 00       	push   $0x1f6
801028ee:	e8 be fd ff ff       	call   801026b1 <outb>
801028f3:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801028f6:	8b 45 08             	mov    0x8(%ebp),%eax
801028f9:	8b 00                	mov    (%eax),%eax
801028fb:	83 e0 04             	and    $0x4,%eax
801028fe:	85 c0                	test   %eax,%eax
80102900:	74 30                	je     80102932 <idestart+0x149>
    outb(0x1f7, IDE_CMD_WRITE);
80102902:	83 ec 08             	sub    $0x8,%esp
80102905:	6a 30                	push   $0x30
80102907:	68 f7 01 00 00       	push   $0x1f7
8010290c:	e8 a0 fd ff ff       	call   801026b1 <outb>
80102911:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102914:	8b 45 08             	mov    0x8(%ebp),%eax
80102917:	83 c0 18             	add    $0x18,%eax
8010291a:	83 ec 04             	sub    $0x4,%esp
8010291d:	68 80 00 00 00       	push   $0x80
80102922:	50                   	push   %eax
80102923:	68 f0 01 00 00       	push   $0x1f0
80102928:	e8 a3 fd ff ff       	call   801026d0 <outsl>
8010292d:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80102930:	eb 12                	jmp    80102944 <idestart+0x15b>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102932:	83 ec 08             	sub    $0x8,%esp
80102935:	6a 20                	push   $0x20
80102937:	68 f7 01 00 00       	push   $0x1f7
8010293c:	e8 70 fd ff ff       	call   801026b1 <outb>
80102941:	83 c4 10             	add    $0x10,%esp
  }
}
80102944:	90                   	nop
80102945:	c9                   	leave  
80102946:	c3                   	ret    

80102947 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102947:	55                   	push   %ebp
80102948:	89 e5                	mov    %esp,%ebp
8010294a:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010294d:	83 ec 0c             	sub    $0xc,%esp
80102950:	68 40 c6 10 80       	push   $0x8010c640
80102955:	e8 df 31 00 00       	call   80105b39 <acquire>
8010295a:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
8010295d:	a1 74 c6 10 80       	mov    0x8010c674,%eax
80102962:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102965:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102969:	75 15                	jne    80102980 <ideintr+0x39>
    release(&idelock);
8010296b:	83 ec 0c             	sub    $0xc,%esp
8010296e:	68 40 c6 10 80       	push   $0x8010c640
80102973:	e8 28 32 00 00       	call   80105ba0 <release>
80102978:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
8010297b:	e9 9a 00 00 00       	jmp    80102a1a <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102980:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102983:	8b 40 14             	mov    0x14(%eax),%eax
80102986:	a3 74 c6 10 80       	mov    %eax,0x8010c674

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010298b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010298e:	8b 00                	mov    (%eax),%eax
80102990:	83 e0 04             	and    $0x4,%eax
80102993:	85 c0                	test   %eax,%eax
80102995:	75 2d                	jne    801029c4 <ideintr+0x7d>
80102997:	83 ec 0c             	sub    $0xc,%esp
8010299a:	6a 01                	push   $0x1
8010299c:	e8 55 fd ff ff       	call   801026f6 <idewait>
801029a1:	83 c4 10             	add    $0x10,%esp
801029a4:	85 c0                	test   %eax,%eax
801029a6:	78 1c                	js     801029c4 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
801029a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029ab:	83 c0 18             	add    $0x18,%eax
801029ae:	83 ec 04             	sub    $0x4,%esp
801029b1:	68 80 00 00 00       	push   $0x80
801029b6:	50                   	push   %eax
801029b7:	68 f0 01 00 00       	push   $0x1f0
801029bc:	e8 ca fc ff ff       	call   8010268b <insl>
801029c1:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801029c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029c7:	8b 00                	mov    (%eax),%eax
801029c9:	83 c8 02             	or     $0x2,%eax
801029cc:	89 c2                	mov    %eax,%edx
801029ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029d1:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801029d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029d6:	8b 00                	mov    (%eax),%eax
801029d8:	83 e0 fb             	and    $0xfffffffb,%eax
801029db:	89 c2                	mov    %eax,%edx
801029dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029e0:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801029e2:	83 ec 0c             	sub    $0xc,%esp
801029e5:	ff 75 f4             	pushl  -0xc(%ebp)
801029e8:	e8 3c 26 00 00       	call   80105029 <wakeup>
801029ed:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
801029f0:	a1 74 c6 10 80       	mov    0x8010c674,%eax
801029f5:	85 c0                	test   %eax,%eax
801029f7:	74 11                	je     80102a0a <ideintr+0xc3>
    idestart(idequeue);
801029f9:	a1 74 c6 10 80       	mov    0x8010c674,%eax
801029fe:	83 ec 0c             	sub    $0xc,%esp
80102a01:	50                   	push   %eax
80102a02:	e8 e2 fd ff ff       	call   801027e9 <idestart>
80102a07:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102a0a:	83 ec 0c             	sub    $0xc,%esp
80102a0d:	68 40 c6 10 80       	push   $0x8010c640
80102a12:	e8 89 31 00 00       	call   80105ba0 <release>
80102a17:	83 c4 10             	add    $0x10,%esp
}
80102a1a:	c9                   	leave  
80102a1b:	c3                   	ret    

80102a1c <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102a1c:	55                   	push   %ebp
80102a1d:	89 e5                	mov    %esp,%ebp
80102a1f:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102a22:	8b 45 08             	mov    0x8(%ebp),%eax
80102a25:	8b 00                	mov    (%eax),%eax
80102a27:	83 e0 01             	and    $0x1,%eax
80102a2a:	85 c0                	test   %eax,%eax
80102a2c:	75 0d                	jne    80102a3b <iderw+0x1f>
    panic("iderw: buf not busy");
80102a2e:	83 ec 0c             	sub    $0xc,%esp
80102a31:	68 2d 96 10 80       	push   $0x8010962d
80102a36:	e8 2b db ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102a3b:	8b 45 08             	mov    0x8(%ebp),%eax
80102a3e:	8b 00                	mov    (%eax),%eax
80102a40:	83 e0 06             	and    $0x6,%eax
80102a43:	83 f8 02             	cmp    $0x2,%eax
80102a46:	75 0d                	jne    80102a55 <iderw+0x39>
    panic("iderw: nothing to do");
80102a48:	83 ec 0c             	sub    $0xc,%esp
80102a4b:	68 41 96 10 80       	push   $0x80109641
80102a50:	e8 11 db ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
80102a55:	8b 45 08             	mov    0x8(%ebp),%eax
80102a58:	8b 40 04             	mov    0x4(%eax),%eax
80102a5b:	85 c0                	test   %eax,%eax
80102a5d:	74 16                	je     80102a75 <iderw+0x59>
80102a5f:	a1 78 c6 10 80       	mov    0x8010c678,%eax
80102a64:	85 c0                	test   %eax,%eax
80102a66:	75 0d                	jne    80102a75 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
80102a68:	83 ec 0c             	sub    $0xc,%esp
80102a6b:	68 56 96 10 80       	push   $0x80109656
80102a70:	e8 f1 da ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102a75:	83 ec 0c             	sub    $0xc,%esp
80102a78:	68 40 c6 10 80       	push   $0x8010c640
80102a7d:	e8 b7 30 00 00       	call   80105b39 <acquire>
80102a82:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102a85:	8b 45 08             	mov    0x8(%ebp),%eax
80102a88:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102a8f:	c7 45 f4 74 c6 10 80 	movl   $0x8010c674,-0xc(%ebp)
80102a96:	eb 0b                	jmp    80102aa3 <iderw+0x87>
80102a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a9b:	8b 00                	mov    (%eax),%eax
80102a9d:	83 c0 14             	add    $0x14,%eax
80102aa0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aa6:	8b 00                	mov    (%eax),%eax
80102aa8:	85 c0                	test   %eax,%eax
80102aaa:	75 ec                	jne    80102a98 <iderw+0x7c>
    ;
  *pp = b;
80102aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aaf:	8b 55 08             	mov    0x8(%ebp),%edx
80102ab2:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102ab4:	a1 74 c6 10 80       	mov    0x8010c674,%eax
80102ab9:	3b 45 08             	cmp    0x8(%ebp),%eax
80102abc:	75 23                	jne    80102ae1 <iderw+0xc5>
    idestart(b);
80102abe:	83 ec 0c             	sub    $0xc,%esp
80102ac1:	ff 75 08             	pushl  0x8(%ebp)
80102ac4:	e8 20 fd ff ff       	call   801027e9 <idestart>
80102ac9:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102acc:	eb 13                	jmp    80102ae1 <iderw+0xc5>
    sleep(b, &idelock);
80102ace:	83 ec 08             	sub    $0x8,%esp
80102ad1:	68 40 c6 10 80       	push   $0x8010c640
80102ad6:	ff 75 08             	pushl  0x8(%ebp)
80102ad9:	e8 64 24 00 00       	call   80104f42 <sleep>
80102ade:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102ae1:	8b 45 08             	mov    0x8(%ebp),%eax
80102ae4:	8b 00                	mov    (%eax),%eax
80102ae6:	83 e0 06             	and    $0x6,%eax
80102ae9:	83 f8 02             	cmp    $0x2,%eax
80102aec:	75 e0                	jne    80102ace <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
80102aee:	83 ec 0c             	sub    $0xc,%esp
80102af1:	68 40 c6 10 80       	push   $0x8010c640
80102af6:	e8 a5 30 00 00       	call   80105ba0 <release>
80102afb:	83 c4 10             	add    $0x10,%esp
}
80102afe:	90                   	nop
80102aff:	c9                   	leave  
80102b00:	c3                   	ret    

80102b01 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102b01:	55                   	push   %ebp
80102b02:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102b04:	a1 54 32 11 80       	mov    0x80113254,%eax
80102b09:	8b 55 08             	mov    0x8(%ebp),%edx
80102b0c:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102b0e:	a1 54 32 11 80       	mov    0x80113254,%eax
80102b13:	8b 40 10             	mov    0x10(%eax),%eax
}
80102b16:	5d                   	pop    %ebp
80102b17:	c3                   	ret    

80102b18 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102b18:	55                   	push   %ebp
80102b19:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102b1b:	a1 54 32 11 80       	mov    0x80113254,%eax
80102b20:	8b 55 08             	mov    0x8(%ebp),%edx
80102b23:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102b25:	a1 54 32 11 80       	mov    0x80113254,%eax
80102b2a:	8b 55 0c             	mov    0xc(%ebp),%edx
80102b2d:	89 50 10             	mov    %edx,0x10(%eax)
}
80102b30:	90                   	nop
80102b31:	5d                   	pop    %ebp
80102b32:	c3                   	ret    

80102b33 <ioapicinit>:

void
ioapicinit(void)
{
80102b33:	55                   	push   %ebp
80102b34:	89 e5                	mov    %esp,%ebp
80102b36:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102b39:	a1 84 33 11 80       	mov    0x80113384,%eax
80102b3e:	85 c0                	test   %eax,%eax
80102b40:	0f 84 a0 00 00 00    	je     80102be6 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102b46:	c7 05 54 32 11 80 00 	movl   $0xfec00000,0x80113254
80102b4d:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102b50:	6a 01                	push   $0x1
80102b52:	e8 aa ff ff ff       	call   80102b01 <ioapicread>
80102b57:	83 c4 04             	add    $0x4,%esp
80102b5a:	c1 e8 10             	shr    $0x10,%eax
80102b5d:	25 ff 00 00 00       	and    $0xff,%eax
80102b62:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102b65:	6a 00                	push   $0x0
80102b67:	e8 95 ff ff ff       	call   80102b01 <ioapicread>
80102b6c:	83 c4 04             	add    $0x4,%esp
80102b6f:	c1 e8 18             	shr    $0x18,%eax
80102b72:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102b75:	0f b6 05 80 33 11 80 	movzbl 0x80113380,%eax
80102b7c:	0f b6 c0             	movzbl %al,%eax
80102b7f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102b82:	74 10                	je     80102b94 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102b84:	83 ec 0c             	sub    $0xc,%esp
80102b87:	68 74 96 10 80       	push   $0x80109674
80102b8c:	e8 35 d8 ff ff       	call   801003c6 <cprintf>
80102b91:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b94:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102b9b:	eb 3f                	jmp    80102bdc <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ba0:	83 c0 20             	add    $0x20,%eax
80102ba3:	0d 00 00 01 00       	or     $0x10000,%eax
80102ba8:	89 c2                	mov    %eax,%edx
80102baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bad:	83 c0 08             	add    $0x8,%eax
80102bb0:	01 c0                	add    %eax,%eax
80102bb2:	83 ec 08             	sub    $0x8,%esp
80102bb5:	52                   	push   %edx
80102bb6:	50                   	push   %eax
80102bb7:	e8 5c ff ff ff       	call   80102b18 <ioapicwrite>
80102bbc:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bc2:	83 c0 08             	add    $0x8,%eax
80102bc5:	01 c0                	add    %eax,%eax
80102bc7:	83 c0 01             	add    $0x1,%eax
80102bca:	83 ec 08             	sub    $0x8,%esp
80102bcd:	6a 00                	push   $0x0
80102bcf:	50                   	push   %eax
80102bd0:	e8 43 ff ff ff       	call   80102b18 <ioapicwrite>
80102bd5:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102bd8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102bdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bdf:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102be2:	7e b9                	jle    80102b9d <ioapicinit+0x6a>
80102be4:	eb 01                	jmp    80102be7 <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102be6:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102be7:	c9                   	leave  
80102be8:	c3                   	ret    

80102be9 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102be9:	55                   	push   %ebp
80102bea:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102bec:	a1 84 33 11 80       	mov    0x80113384,%eax
80102bf1:	85 c0                	test   %eax,%eax
80102bf3:	74 39                	je     80102c2e <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102bf5:	8b 45 08             	mov    0x8(%ebp),%eax
80102bf8:	83 c0 20             	add    $0x20,%eax
80102bfb:	89 c2                	mov    %eax,%edx
80102bfd:	8b 45 08             	mov    0x8(%ebp),%eax
80102c00:	83 c0 08             	add    $0x8,%eax
80102c03:	01 c0                	add    %eax,%eax
80102c05:	52                   	push   %edx
80102c06:	50                   	push   %eax
80102c07:	e8 0c ff ff ff       	call   80102b18 <ioapicwrite>
80102c0c:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102c0f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c12:	c1 e0 18             	shl    $0x18,%eax
80102c15:	89 c2                	mov    %eax,%edx
80102c17:	8b 45 08             	mov    0x8(%ebp),%eax
80102c1a:	83 c0 08             	add    $0x8,%eax
80102c1d:	01 c0                	add    %eax,%eax
80102c1f:	83 c0 01             	add    $0x1,%eax
80102c22:	52                   	push   %edx
80102c23:	50                   	push   %eax
80102c24:	e8 ef fe ff ff       	call   80102b18 <ioapicwrite>
80102c29:	83 c4 08             	add    $0x8,%esp
80102c2c:	eb 01                	jmp    80102c2f <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102c2e:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102c2f:	c9                   	leave  
80102c30:	c3                   	ret    

80102c31 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102c31:	55                   	push   %ebp
80102c32:	89 e5                	mov    %esp,%ebp
80102c34:	8b 45 08             	mov    0x8(%ebp),%eax
80102c37:	05 00 00 00 80       	add    $0x80000000,%eax
80102c3c:	5d                   	pop    %ebp
80102c3d:	c3                   	ret    

80102c3e <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102c3e:	55                   	push   %ebp
80102c3f:	89 e5                	mov    %esp,%ebp
80102c41:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102c44:	83 ec 08             	sub    $0x8,%esp
80102c47:	68 a6 96 10 80       	push   $0x801096a6
80102c4c:	68 60 32 11 80       	push   $0x80113260
80102c51:	e8 c1 2e 00 00       	call   80105b17 <initlock>
80102c56:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102c59:	c7 05 94 32 11 80 00 	movl   $0x0,0x80113294
80102c60:	00 00 00 
  freerange(vstart, vend);
80102c63:	83 ec 08             	sub    $0x8,%esp
80102c66:	ff 75 0c             	pushl  0xc(%ebp)
80102c69:	ff 75 08             	pushl  0x8(%ebp)
80102c6c:	e8 2a 00 00 00       	call   80102c9b <freerange>
80102c71:	83 c4 10             	add    $0x10,%esp
}
80102c74:	90                   	nop
80102c75:	c9                   	leave  
80102c76:	c3                   	ret    

80102c77 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102c77:	55                   	push   %ebp
80102c78:	89 e5                	mov    %esp,%ebp
80102c7a:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102c7d:	83 ec 08             	sub    $0x8,%esp
80102c80:	ff 75 0c             	pushl  0xc(%ebp)
80102c83:	ff 75 08             	pushl  0x8(%ebp)
80102c86:	e8 10 00 00 00       	call   80102c9b <freerange>
80102c8b:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102c8e:	c7 05 94 32 11 80 01 	movl   $0x1,0x80113294
80102c95:	00 00 00 
}
80102c98:	90                   	nop
80102c99:	c9                   	leave  
80102c9a:	c3                   	ret    

80102c9b <freerange>:

void
freerange(void *vstart, void *vend)
{
80102c9b:	55                   	push   %ebp
80102c9c:	89 e5                	mov    %esp,%ebp
80102c9e:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102ca1:	8b 45 08             	mov    0x8(%ebp),%eax
80102ca4:	05 ff 0f 00 00       	add    $0xfff,%eax
80102ca9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102cae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102cb1:	eb 15                	jmp    80102cc8 <freerange+0x2d>
    kfree(p);
80102cb3:	83 ec 0c             	sub    $0xc,%esp
80102cb6:	ff 75 f4             	pushl  -0xc(%ebp)
80102cb9:	e8 1a 00 00 00       	call   80102cd8 <kfree>
80102cbe:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102cc1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102cc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ccb:	05 00 10 00 00       	add    $0x1000,%eax
80102cd0:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102cd3:	76 de                	jbe    80102cb3 <freerange+0x18>
    kfree(p);
}
80102cd5:	90                   	nop
80102cd6:	c9                   	leave  
80102cd7:	c3                   	ret    

80102cd8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102cd8:	55                   	push   %ebp
80102cd9:	89 e5                	mov    %esp,%ebp
80102cdb:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102cde:	8b 45 08             	mov    0x8(%ebp),%eax
80102ce1:	25 ff 0f 00 00       	and    $0xfff,%eax
80102ce6:	85 c0                	test   %eax,%eax
80102ce8:	75 1b                	jne    80102d05 <kfree+0x2d>
80102cea:	81 7d 08 9c 69 11 80 	cmpl   $0x8011699c,0x8(%ebp)
80102cf1:	72 12                	jb     80102d05 <kfree+0x2d>
80102cf3:	ff 75 08             	pushl  0x8(%ebp)
80102cf6:	e8 36 ff ff ff       	call   80102c31 <v2p>
80102cfb:	83 c4 04             	add    $0x4,%esp
80102cfe:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102d03:	76 0d                	jbe    80102d12 <kfree+0x3a>
    panic("kfree");
80102d05:	83 ec 0c             	sub    $0xc,%esp
80102d08:	68 ab 96 10 80       	push   $0x801096ab
80102d0d:	e8 54 d8 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102d12:	83 ec 04             	sub    $0x4,%esp
80102d15:	68 00 10 00 00       	push   $0x1000
80102d1a:	6a 01                	push   $0x1
80102d1c:	ff 75 08             	pushl  0x8(%ebp)
80102d1f:	e8 78 30 00 00       	call   80105d9c <memset>
80102d24:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102d27:	a1 94 32 11 80       	mov    0x80113294,%eax
80102d2c:	85 c0                	test   %eax,%eax
80102d2e:	74 10                	je     80102d40 <kfree+0x68>
    acquire(&kmem.lock);
80102d30:	83 ec 0c             	sub    $0xc,%esp
80102d33:	68 60 32 11 80       	push   $0x80113260
80102d38:	e8 fc 2d 00 00       	call   80105b39 <acquire>
80102d3d:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102d40:	8b 45 08             	mov    0x8(%ebp),%eax
80102d43:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102d46:	8b 15 98 32 11 80    	mov    0x80113298,%edx
80102d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d4f:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102d51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d54:	a3 98 32 11 80       	mov    %eax,0x80113298
  if(kmem.use_lock)
80102d59:	a1 94 32 11 80       	mov    0x80113294,%eax
80102d5e:	85 c0                	test   %eax,%eax
80102d60:	74 10                	je     80102d72 <kfree+0x9a>
    release(&kmem.lock);
80102d62:	83 ec 0c             	sub    $0xc,%esp
80102d65:	68 60 32 11 80       	push   $0x80113260
80102d6a:	e8 31 2e 00 00       	call   80105ba0 <release>
80102d6f:	83 c4 10             	add    $0x10,%esp
}
80102d72:	90                   	nop
80102d73:	c9                   	leave  
80102d74:	c3                   	ret    

80102d75 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102d75:	55                   	push   %ebp
80102d76:	89 e5                	mov    %esp,%ebp
80102d78:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102d7b:	a1 94 32 11 80       	mov    0x80113294,%eax
80102d80:	85 c0                	test   %eax,%eax
80102d82:	74 10                	je     80102d94 <kalloc+0x1f>
    acquire(&kmem.lock);
80102d84:	83 ec 0c             	sub    $0xc,%esp
80102d87:	68 60 32 11 80       	push   $0x80113260
80102d8c:	e8 a8 2d 00 00       	call   80105b39 <acquire>
80102d91:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102d94:	a1 98 32 11 80       	mov    0x80113298,%eax
80102d99:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102d9c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102da0:	74 0a                	je     80102dac <kalloc+0x37>
    kmem.freelist = r->next;
80102da2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102da5:	8b 00                	mov    (%eax),%eax
80102da7:	a3 98 32 11 80       	mov    %eax,0x80113298
  if(kmem.use_lock)
80102dac:	a1 94 32 11 80       	mov    0x80113294,%eax
80102db1:	85 c0                	test   %eax,%eax
80102db3:	74 10                	je     80102dc5 <kalloc+0x50>
    release(&kmem.lock);
80102db5:	83 ec 0c             	sub    $0xc,%esp
80102db8:	68 60 32 11 80       	push   $0x80113260
80102dbd:	e8 de 2d 00 00       	call   80105ba0 <release>
80102dc2:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102dc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102dc8:	c9                   	leave  
80102dc9:	c3                   	ret    

80102dca <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80102dca:	55                   	push   %ebp
80102dcb:	89 e5                	mov    %esp,%ebp
80102dcd:	83 ec 14             	sub    $0x14,%esp
80102dd0:	8b 45 08             	mov    0x8(%ebp),%eax
80102dd3:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102dd7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102ddb:	89 c2                	mov    %eax,%edx
80102ddd:	ec                   	in     (%dx),%al
80102dde:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102de1:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102de5:	c9                   	leave  
80102de6:	c3                   	ret    

80102de7 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102de7:	55                   	push   %ebp
80102de8:	89 e5                	mov    %esp,%ebp
80102dea:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102ded:	6a 64                	push   $0x64
80102def:	e8 d6 ff ff ff       	call   80102dca <inb>
80102df4:	83 c4 04             	add    $0x4,%esp
80102df7:	0f b6 c0             	movzbl %al,%eax
80102dfa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102dfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e00:	83 e0 01             	and    $0x1,%eax
80102e03:	85 c0                	test   %eax,%eax
80102e05:	75 0a                	jne    80102e11 <kbdgetc+0x2a>
    return -1;
80102e07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e0c:	e9 23 01 00 00       	jmp    80102f34 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102e11:	6a 60                	push   $0x60
80102e13:	e8 b2 ff ff ff       	call   80102dca <inb>
80102e18:	83 c4 04             	add    $0x4,%esp
80102e1b:	0f b6 c0             	movzbl %al,%eax
80102e1e:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102e21:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102e28:	75 17                	jne    80102e41 <kbdgetc+0x5a>
    shift |= E0ESC;
80102e2a:	a1 7c c6 10 80       	mov    0x8010c67c,%eax
80102e2f:	83 c8 40             	or     $0x40,%eax
80102e32:	a3 7c c6 10 80       	mov    %eax,0x8010c67c
    return 0;
80102e37:	b8 00 00 00 00       	mov    $0x0,%eax
80102e3c:	e9 f3 00 00 00       	jmp    80102f34 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102e41:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e44:	25 80 00 00 00       	and    $0x80,%eax
80102e49:	85 c0                	test   %eax,%eax
80102e4b:	74 45                	je     80102e92 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102e4d:	a1 7c c6 10 80       	mov    0x8010c67c,%eax
80102e52:	83 e0 40             	and    $0x40,%eax
80102e55:	85 c0                	test   %eax,%eax
80102e57:	75 08                	jne    80102e61 <kbdgetc+0x7a>
80102e59:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e5c:	83 e0 7f             	and    $0x7f,%eax
80102e5f:	eb 03                	jmp    80102e64 <kbdgetc+0x7d>
80102e61:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e64:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102e67:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e6a:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102e6f:	0f b6 00             	movzbl (%eax),%eax
80102e72:	83 c8 40             	or     $0x40,%eax
80102e75:	0f b6 c0             	movzbl %al,%eax
80102e78:	f7 d0                	not    %eax
80102e7a:	89 c2                	mov    %eax,%edx
80102e7c:	a1 7c c6 10 80       	mov    0x8010c67c,%eax
80102e81:	21 d0                	and    %edx,%eax
80102e83:	a3 7c c6 10 80       	mov    %eax,0x8010c67c
    return 0;
80102e88:	b8 00 00 00 00       	mov    $0x0,%eax
80102e8d:	e9 a2 00 00 00       	jmp    80102f34 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102e92:	a1 7c c6 10 80       	mov    0x8010c67c,%eax
80102e97:	83 e0 40             	and    $0x40,%eax
80102e9a:	85 c0                	test   %eax,%eax
80102e9c:	74 14                	je     80102eb2 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102e9e:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102ea5:	a1 7c c6 10 80       	mov    0x8010c67c,%eax
80102eaa:	83 e0 bf             	and    $0xffffffbf,%eax
80102ead:	a3 7c c6 10 80       	mov    %eax,0x8010c67c
  }

  shift |= shiftcode[data];
80102eb2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102eb5:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102eba:	0f b6 00             	movzbl (%eax),%eax
80102ebd:	0f b6 d0             	movzbl %al,%edx
80102ec0:	a1 7c c6 10 80       	mov    0x8010c67c,%eax
80102ec5:	09 d0                	or     %edx,%eax
80102ec7:	a3 7c c6 10 80       	mov    %eax,0x8010c67c
  shift ^= togglecode[data];
80102ecc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ecf:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102ed4:	0f b6 00             	movzbl (%eax),%eax
80102ed7:	0f b6 d0             	movzbl %al,%edx
80102eda:	a1 7c c6 10 80       	mov    0x8010c67c,%eax
80102edf:	31 d0                	xor    %edx,%eax
80102ee1:	a3 7c c6 10 80       	mov    %eax,0x8010c67c
  c = charcode[shift & (CTL | SHIFT)][data];
80102ee6:	a1 7c c6 10 80       	mov    0x8010c67c,%eax
80102eeb:	83 e0 03             	and    $0x3,%eax
80102eee:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102ef5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ef8:	01 d0                	add    %edx,%eax
80102efa:	0f b6 00             	movzbl (%eax),%eax
80102efd:	0f b6 c0             	movzbl %al,%eax
80102f00:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102f03:	a1 7c c6 10 80       	mov    0x8010c67c,%eax
80102f08:	83 e0 08             	and    $0x8,%eax
80102f0b:	85 c0                	test   %eax,%eax
80102f0d:	74 22                	je     80102f31 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102f0f:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102f13:	76 0c                	jbe    80102f21 <kbdgetc+0x13a>
80102f15:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102f19:	77 06                	ja     80102f21 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102f1b:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102f1f:	eb 10                	jmp    80102f31 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102f21:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102f25:	76 0a                	jbe    80102f31 <kbdgetc+0x14a>
80102f27:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102f2b:	77 04                	ja     80102f31 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102f2d:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102f31:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102f34:	c9                   	leave  
80102f35:	c3                   	ret    

80102f36 <kbdintr>:

void
kbdintr(void)
{
80102f36:	55                   	push   %ebp
80102f37:	89 e5                	mov    %esp,%ebp
80102f39:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102f3c:	83 ec 0c             	sub    $0xc,%esp
80102f3f:	68 e7 2d 10 80       	push   $0x80102de7
80102f44:	e8 b0 d8 ff ff       	call   801007f9 <consoleintr>
80102f49:	83 c4 10             	add    $0x10,%esp
}
80102f4c:	90                   	nop
80102f4d:	c9                   	leave  
80102f4e:	c3                   	ret    

80102f4f <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80102f4f:	55                   	push   %ebp
80102f50:	89 e5                	mov    %esp,%ebp
80102f52:	83 ec 14             	sub    $0x14,%esp
80102f55:	8b 45 08             	mov    0x8(%ebp),%eax
80102f58:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102f5c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102f60:	89 c2                	mov    %eax,%edx
80102f62:	ec                   	in     (%dx),%al
80102f63:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102f66:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102f6a:	c9                   	leave  
80102f6b:	c3                   	ret    

80102f6c <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102f6c:	55                   	push   %ebp
80102f6d:	89 e5                	mov    %esp,%ebp
80102f6f:	83 ec 08             	sub    $0x8,%esp
80102f72:	8b 55 08             	mov    0x8(%ebp),%edx
80102f75:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f78:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102f7c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102f7f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102f83:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102f87:	ee                   	out    %al,(%dx)
}
80102f88:	90                   	nop
80102f89:	c9                   	leave  
80102f8a:	c3                   	ret    

80102f8b <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102f8b:	55                   	push   %ebp
80102f8c:	89 e5                	mov    %esp,%ebp
80102f8e:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102f91:	9c                   	pushf  
80102f92:	58                   	pop    %eax
80102f93:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102f96:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102f99:	c9                   	leave  
80102f9a:	c3                   	ret    

80102f9b <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102f9b:	55                   	push   %ebp
80102f9c:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102f9e:	a1 9c 32 11 80       	mov    0x8011329c,%eax
80102fa3:	8b 55 08             	mov    0x8(%ebp),%edx
80102fa6:	c1 e2 02             	shl    $0x2,%edx
80102fa9:	01 c2                	add    %eax,%edx
80102fab:	8b 45 0c             	mov    0xc(%ebp),%eax
80102fae:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102fb0:	a1 9c 32 11 80       	mov    0x8011329c,%eax
80102fb5:	83 c0 20             	add    $0x20,%eax
80102fb8:	8b 00                	mov    (%eax),%eax
}
80102fba:	90                   	nop
80102fbb:	5d                   	pop    %ebp
80102fbc:	c3                   	ret    

80102fbd <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102fbd:	55                   	push   %ebp
80102fbe:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80102fc0:	a1 9c 32 11 80       	mov    0x8011329c,%eax
80102fc5:	85 c0                	test   %eax,%eax
80102fc7:	0f 84 0b 01 00 00    	je     801030d8 <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102fcd:	68 3f 01 00 00       	push   $0x13f
80102fd2:	6a 3c                	push   $0x3c
80102fd4:	e8 c2 ff ff ff       	call   80102f9b <lapicw>
80102fd9:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102fdc:	6a 0b                	push   $0xb
80102fde:	68 f8 00 00 00       	push   $0xf8
80102fe3:	e8 b3 ff ff ff       	call   80102f9b <lapicw>
80102fe8:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102feb:	68 20 00 02 00       	push   $0x20020
80102ff0:	68 c8 00 00 00       	push   $0xc8
80102ff5:	e8 a1 ff ff ff       	call   80102f9b <lapicw>
80102ffa:	83 c4 08             	add    $0x8,%esp
  // lapicw(TICR, 10000000); 
  lapicw(TICR, 1000000000/TPS); // PSU CS333. Makes ticks per second programmable
80102ffd:	68 40 42 0f 00       	push   $0xf4240
80103002:	68 e0 00 00 00       	push   $0xe0
80103007:	e8 8f ff ff ff       	call   80102f9b <lapicw>
8010300c:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
8010300f:	68 00 00 01 00       	push   $0x10000
80103014:	68 d4 00 00 00       	push   $0xd4
80103019:	e8 7d ff ff ff       	call   80102f9b <lapicw>
8010301e:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80103021:	68 00 00 01 00       	push   $0x10000
80103026:	68 d8 00 00 00       	push   $0xd8
8010302b:	e8 6b ff ff ff       	call   80102f9b <lapicw>
80103030:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80103033:	a1 9c 32 11 80       	mov    0x8011329c,%eax
80103038:	83 c0 30             	add    $0x30,%eax
8010303b:	8b 00                	mov    (%eax),%eax
8010303d:	c1 e8 10             	shr    $0x10,%eax
80103040:	0f b6 c0             	movzbl %al,%eax
80103043:	83 f8 03             	cmp    $0x3,%eax
80103046:	76 12                	jbe    8010305a <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80103048:	68 00 00 01 00       	push   $0x10000
8010304d:	68 d0 00 00 00       	push   $0xd0
80103052:	e8 44 ff ff ff       	call   80102f9b <lapicw>
80103057:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
8010305a:	6a 33                	push   $0x33
8010305c:	68 dc 00 00 00       	push   $0xdc
80103061:	e8 35 ff ff ff       	call   80102f9b <lapicw>
80103066:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103069:	6a 00                	push   $0x0
8010306b:	68 a0 00 00 00       	push   $0xa0
80103070:	e8 26 ff ff ff       	call   80102f9b <lapicw>
80103075:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80103078:	6a 00                	push   $0x0
8010307a:	68 a0 00 00 00       	push   $0xa0
8010307f:	e8 17 ff ff ff       	call   80102f9b <lapicw>
80103084:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103087:	6a 00                	push   $0x0
80103089:	6a 2c                	push   $0x2c
8010308b:	e8 0b ff ff ff       	call   80102f9b <lapicw>
80103090:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103093:	6a 00                	push   $0x0
80103095:	68 c4 00 00 00       	push   $0xc4
8010309a:	e8 fc fe ff ff       	call   80102f9b <lapicw>
8010309f:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801030a2:	68 00 85 08 00       	push   $0x88500
801030a7:	68 c0 00 00 00       	push   $0xc0
801030ac:	e8 ea fe ff ff       	call   80102f9b <lapicw>
801030b1:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
801030b4:	90                   	nop
801030b5:	a1 9c 32 11 80       	mov    0x8011329c,%eax
801030ba:	05 00 03 00 00       	add    $0x300,%eax
801030bf:	8b 00                	mov    (%eax),%eax
801030c1:	25 00 10 00 00       	and    $0x1000,%eax
801030c6:	85 c0                	test   %eax,%eax
801030c8:	75 eb                	jne    801030b5 <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801030ca:	6a 00                	push   $0x0
801030cc:	6a 20                	push   $0x20
801030ce:	e8 c8 fe ff ff       	call   80102f9b <lapicw>
801030d3:	83 c4 08             	add    $0x8,%esp
801030d6:	eb 01                	jmp    801030d9 <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
801030d8:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
801030d9:	c9                   	leave  
801030da:	c3                   	ret    

801030db <cpunum>:

int
cpunum(void)
{
801030db:	55                   	push   %ebp
801030dc:	89 e5                	mov    %esp,%ebp
801030de:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
801030e1:	e8 a5 fe ff ff       	call   80102f8b <readeflags>
801030e6:	25 00 02 00 00       	and    $0x200,%eax
801030eb:	85 c0                	test   %eax,%eax
801030ed:	74 26                	je     80103115 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
801030ef:	a1 80 c6 10 80       	mov    0x8010c680,%eax
801030f4:	8d 50 01             	lea    0x1(%eax),%edx
801030f7:	89 15 80 c6 10 80    	mov    %edx,0x8010c680
801030fd:	85 c0                	test   %eax,%eax
801030ff:	75 14                	jne    80103115 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80103101:	8b 45 04             	mov    0x4(%ebp),%eax
80103104:	83 ec 08             	sub    $0x8,%esp
80103107:	50                   	push   %eax
80103108:	68 b4 96 10 80       	push   $0x801096b4
8010310d:	e8 b4 d2 ff ff       	call   801003c6 <cprintf>
80103112:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
80103115:	a1 9c 32 11 80       	mov    0x8011329c,%eax
8010311a:	85 c0                	test   %eax,%eax
8010311c:	74 0f                	je     8010312d <cpunum+0x52>
    return lapic[ID]>>24;
8010311e:	a1 9c 32 11 80       	mov    0x8011329c,%eax
80103123:	83 c0 20             	add    $0x20,%eax
80103126:	8b 00                	mov    (%eax),%eax
80103128:	c1 e8 18             	shr    $0x18,%eax
8010312b:	eb 05                	jmp    80103132 <cpunum+0x57>
  return 0;
8010312d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103132:	c9                   	leave  
80103133:	c3                   	ret    

80103134 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103134:	55                   	push   %ebp
80103135:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103137:	a1 9c 32 11 80       	mov    0x8011329c,%eax
8010313c:	85 c0                	test   %eax,%eax
8010313e:	74 0c                	je     8010314c <lapiceoi+0x18>
    lapicw(EOI, 0);
80103140:	6a 00                	push   $0x0
80103142:	6a 2c                	push   $0x2c
80103144:	e8 52 fe ff ff       	call   80102f9b <lapicw>
80103149:	83 c4 08             	add    $0x8,%esp
}
8010314c:	90                   	nop
8010314d:	c9                   	leave  
8010314e:	c3                   	ret    

8010314f <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010314f:	55                   	push   %ebp
80103150:	89 e5                	mov    %esp,%ebp
}
80103152:	90                   	nop
80103153:	5d                   	pop    %ebp
80103154:	c3                   	ret    

80103155 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103155:	55                   	push   %ebp
80103156:	89 e5                	mov    %esp,%ebp
80103158:	83 ec 14             	sub    $0x14,%esp
8010315b:	8b 45 08             	mov    0x8(%ebp),%eax
8010315e:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103161:	6a 0f                	push   $0xf
80103163:	6a 70                	push   $0x70
80103165:	e8 02 fe ff ff       	call   80102f6c <outb>
8010316a:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
8010316d:	6a 0a                	push   $0xa
8010316f:	6a 71                	push   $0x71
80103171:	e8 f6 fd ff ff       	call   80102f6c <outb>
80103176:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103179:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103180:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103183:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103188:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010318b:	83 c0 02             	add    $0x2,%eax
8010318e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103191:	c1 ea 04             	shr    $0x4,%edx
80103194:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103197:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010319b:	c1 e0 18             	shl    $0x18,%eax
8010319e:	50                   	push   %eax
8010319f:	68 c4 00 00 00       	push   $0xc4
801031a4:	e8 f2 fd ff ff       	call   80102f9b <lapicw>
801031a9:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801031ac:	68 00 c5 00 00       	push   $0xc500
801031b1:	68 c0 00 00 00       	push   $0xc0
801031b6:	e8 e0 fd ff ff       	call   80102f9b <lapicw>
801031bb:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801031be:	68 c8 00 00 00       	push   $0xc8
801031c3:	e8 87 ff ff ff       	call   8010314f <microdelay>
801031c8:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801031cb:	68 00 85 00 00       	push   $0x8500
801031d0:	68 c0 00 00 00       	push   $0xc0
801031d5:	e8 c1 fd ff ff       	call   80102f9b <lapicw>
801031da:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801031dd:	6a 64                	push   $0x64
801031df:	e8 6b ff ff ff       	call   8010314f <microdelay>
801031e4:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801031e7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801031ee:	eb 3d                	jmp    8010322d <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
801031f0:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801031f4:	c1 e0 18             	shl    $0x18,%eax
801031f7:	50                   	push   %eax
801031f8:	68 c4 00 00 00       	push   $0xc4
801031fd:	e8 99 fd ff ff       	call   80102f9b <lapicw>
80103202:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103205:	8b 45 0c             	mov    0xc(%ebp),%eax
80103208:	c1 e8 0c             	shr    $0xc,%eax
8010320b:	80 cc 06             	or     $0x6,%ah
8010320e:	50                   	push   %eax
8010320f:	68 c0 00 00 00       	push   $0xc0
80103214:	e8 82 fd ff ff       	call   80102f9b <lapicw>
80103219:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
8010321c:	68 c8 00 00 00       	push   $0xc8
80103221:	e8 29 ff ff ff       	call   8010314f <microdelay>
80103226:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103229:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010322d:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103231:	7e bd                	jle    801031f0 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103233:	90                   	nop
80103234:	c9                   	leave  
80103235:	c3                   	ret    

80103236 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103236:	55                   	push   %ebp
80103237:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103239:	8b 45 08             	mov    0x8(%ebp),%eax
8010323c:	0f b6 c0             	movzbl %al,%eax
8010323f:	50                   	push   %eax
80103240:	6a 70                	push   $0x70
80103242:	e8 25 fd ff ff       	call   80102f6c <outb>
80103247:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010324a:	68 c8 00 00 00       	push   $0xc8
8010324f:	e8 fb fe ff ff       	call   8010314f <microdelay>
80103254:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103257:	6a 71                	push   $0x71
80103259:	e8 f1 fc ff ff       	call   80102f4f <inb>
8010325e:	83 c4 04             	add    $0x4,%esp
80103261:	0f b6 c0             	movzbl %al,%eax
}
80103264:	c9                   	leave  
80103265:	c3                   	ret    

80103266 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103266:	55                   	push   %ebp
80103267:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103269:	6a 00                	push   $0x0
8010326b:	e8 c6 ff ff ff       	call   80103236 <cmos_read>
80103270:	83 c4 04             	add    $0x4,%esp
80103273:	89 c2                	mov    %eax,%edx
80103275:	8b 45 08             	mov    0x8(%ebp),%eax
80103278:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
8010327a:	6a 02                	push   $0x2
8010327c:	e8 b5 ff ff ff       	call   80103236 <cmos_read>
80103281:	83 c4 04             	add    $0x4,%esp
80103284:	89 c2                	mov    %eax,%edx
80103286:	8b 45 08             	mov    0x8(%ebp),%eax
80103289:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
8010328c:	6a 04                	push   $0x4
8010328e:	e8 a3 ff ff ff       	call   80103236 <cmos_read>
80103293:	83 c4 04             	add    $0x4,%esp
80103296:	89 c2                	mov    %eax,%edx
80103298:	8b 45 08             	mov    0x8(%ebp),%eax
8010329b:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
8010329e:	6a 07                	push   $0x7
801032a0:	e8 91 ff ff ff       	call   80103236 <cmos_read>
801032a5:	83 c4 04             	add    $0x4,%esp
801032a8:	89 c2                	mov    %eax,%edx
801032aa:	8b 45 08             	mov    0x8(%ebp),%eax
801032ad:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
801032b0:	6a 08                	push   $0x8
801032b2:	e8 7f ff ff ff       	call   80103236 <cmos_read>
801032b7:	83 c4 04             	add    $0x4,%esp
801032ba:	89 c2                	mov    %eax,%edx
801032bc:	8b 45 08             	mov    0x8(%ebp),%eax
801032bf:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
801032c2:	6a 09                	push   $0x9
801032c4:	e8 6d ff ff ff       	call   80103236 <cmos_read>
801032c9:	83 c4 04             	add    $0x4,%esp
801032cc:	89 c2                	mov    %eax,%edx
801032ce:	8b 45 08             	mov    0x8(%ebp),%eax
801032d1:	89 50 14             	mov    %edx,0x14(%eax)
}
801032d4:	90                   	nop
801032d5:	c9                   	leave  
801032d6:	c3                   	ret    

801032d7 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801032d7:	55                   	push   %ebp
801032d8:	89 e5                	mov    %esp,%ebp
801032da:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801032dd:	6a 0b                	push   $0xb
801032df:	e8 52 ff ff ff       	call   80103236 <cmos_read>
801032e4:	83 c4 04             	add    $0x4,%esp
801032e7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801032ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032ed:	83 e0 04             	and    $0x4,%eax
801032f0:	85 c0                	test   %eax,%eax
801032f2:	0f 94 c0             	sete   %al
801032f5:	0f b6 c0             	movzbl %al,%eax
801032f8:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
801032fb:	8d 45 d8             	lea    -0x28(%ebp),%eax
801032fe:	50                   	push   %eax
801032ff:	e8 62 ff ff ff       	call   80103266 <fill_rtcdate>
80103304:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
80103307:	6a 0a                	push   $0xa
80103309:	e8 28 ff ff ff       	call   80103236 <cmos_read>
8010330e:	83 c4 04             	add    $0x4,%esp
80103311:	25 80 00 00 00       	and    $0x80,%eax
80103316:	85 c0                	test   %eax,%eax
80103318:	75 27                	jne    80103341 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
8010331a:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010331d:	50                   	push   %eax
8010331e:	e8 43 ff ff ff       	call   80103266 <fill_rtcdate>
80103323:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103326:	83 ec 04             	sub    $0x4,%esp
80103329:	6a 18                	push   $0x18
8010332b:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010332e:	50                   	push   %eax
8010332f:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103332:	50                   	push   %eax
80103333:	e8 cb 2a 00 00       	call   80105e03 <memcmp>
80103338:	83 c4 10             	add    $0x10,%esp
8010333b:	85 c0                	test   %eax,%eax
8010333d:	74 05                	je     80103344 <cmostime+0x6d>
8010333f:	eb ba                	jmp    801032fb <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
80103341:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103342:	eb b7                	jmp    801032fb <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
80103344:	90                   	nop
  }

  // convert
  if (bcd) {
80103345:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103349:	0f 84 b4 00 00 00    	je     80103403 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010334f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103352:	c1 e8 04             	shr    $0x4,%eax
80103355:	89 c2                	mov    %eax,%edx
80103357:	89 d0                	mov    %edx,%eax
80103359:	c1 e0 02             	shl    $0x2,%eax
8010335c:	01 d0                	add    %edx,%eax
8010335e:	01 c0                	add    %eax,%eax
80103360:	89 c2                	mov    %eax,%edx
80103362:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103365:	83 e0 0f             	and    $0xf,%eax
80103368:	01 d0                	add    %edx,%eax
8010336a:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
8010336d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103370:	c1 e8 04             	shr    $0x4,%eax
80103373:	89 c2                	mov    %eax,%edx
80103375:	89 d0                	mov    %edx,%eax
80103377:	c1 e0 02             	shl    $0x2,%eax
8010337a:	01 d0                	add    %edx,%eax
8010337c:	01 c0                	add    %eax,%eax
8010337e:	89 c2                	mov    %eax,%edx
80103380:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103383:	83 e0 0f             	and    $0xf,%eax
80103386:	01 d0                	add    %edx,%eax
80103388:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010338b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010338e:	c1 e8 04             	shr    $0x4,%eax
80103391:	89 c2                	mov    %eax,%edx
80103393:	89 d0                	mov    %edx,%eax
80103395:	c1 e0 02             	shl    $0x2,%eax
80103398:	01 d0                	add    %edx,%eax
8010339a:	01 c0                	add    %eax,%eax
8010339c:	89 c2                	mov    %eax,%edx
8010339e:	8b 45 e0             	mov    -0x20(%ebp),%eax
801033a1:	83 e0 0f             	and    $0xf,%eax
801033a4:	01 d0                	add    %edx,%eax
801033a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801033a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801033ac:	c1 e8 04             	shr    $0x4,%eax
801033af:	89 c2                	mov    %eax,%edx
801033b1:	89 d0                	mov    %edx,%eax
801033b3:	c1 e0 02             	shl    $0x2,%eax
801033b6:	01 d0                	add    %edx,%eax
801033b8:	01 c0                	add    %eax,%eax
801033ba:	89 c2                	mov    %eax,%edx
801033bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801033bf:	83 e0 0f             	and    $0xf,%eax
801033c2:	01 d0                	add    %edx,%eax
801033c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801033c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801033ca:	c1 e8 04             	shr    $0x4,%eax
801033cd:	89 c2                	mov    %eax,%edx
801033cf:	89 d0                	mov    %edx,%eax
801033d1:	c1 e0 02             	shl    $0x2,%eax
801033d4:	01 d0                	add    %edx,%eax
801033d6:	01 c0                	add    %eax,%eax
801033d8:	89 c2                	mov    %eax,%edx
801033da:	8b 45 e8             	mov    -0x18(%ebp),%eax
801033dd:	83 e0 0f             	and    $0xf,%eax
801033e0:	01 d0                	add    %edx,%eax
801033e2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801033e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033e8:	c1 e8 04             	shr    $0x4,%eax
801033eb:	89 c2                	mov    %eax,%edx
801033ed:	89 d0                	mov    %edx,%eax
801033ef:	c1 e0 02             	shl    $0x2,%eax
801033f2:	01 d0                	add    %edx,%eax
801033f4:	01 c0                	add    %eax,%eax
801033f6:	89 c2                	mov    %eax,%edx
801033f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033fb:	83 e0 0f             	and    $0xf,%eax
801033fe:	01 d0                	add    %edx,%eax
80103400:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103403:	8b 45 08             	mov    0x8(%ebp),%eax
80103406:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103409:	89 10                	mov    %edx,(%eax)
8010340b:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010340e:	89 50 04             	mov    %edx,0x4(%eax)
80103411:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103414:	89 50 08             	mov    %edx,0x8(%eax)
80103417:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010341a:	89 50 0c             	mov    %edx,0xc(%eax)
8010341d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103420:	89 50 10             	mov    %edx,0x10(%eax)
80103423:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103426:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103429:	8b 45 08             	mov    0x8(%ebp),%eax
8010342c:	8b 40 14             	mov    0x14(%eax),%eax
8010342f:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103435:	8b 45 08             	mov    0x8(%ebp),%eax
80103438:	89 50 14             	mov    %edx,0x14(%eax)
}
8010343b:	90                   	nop
8010343c:	c9                   	leave  
8010343d:	c3                   	ret    

8010343e <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
8010343e:	55                   	push   %ebp
8010343f:	89 e5                	mov    %esp,%ebp
80103441:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103444:	83 ec 08             	sub    $0x8,%esp
80103447:	68 e0 96 10 80       	push   $0x801096e0
8010344c:	68 a0 32 11 80       	push   $0x801132a0
80103451:	e8 c1 26 00 00       	call   80105b17 <initlock>
80103456:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80103459:	83 ec 08             	sub    $0x8,%esp
8010345c:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010345f:	50                   	push   %eax
80103460:	ff 75 08             	pushl  0x8(%ebp)
80103463:	e8 b3 df ff ff       	call   8010141b <readsb>
80103468:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
8010346b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010346e:	a3 d4 32 11 80       	mov    %eax,0x801132d4
  log.size = sb.nlog;
80103473:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103476:	a3 d8 32 11 80       	mov    %eax,0x801132d8
  log.dev = dev;
8010347b:	8b 45 08             	mov    0x8(%ebp),%eax
8010347e:	a3 e4 32 11 80       	mov    %eax,0x801132e4
  recover_from_log();
80103483:	e8 b2 01 00 00       	call   8010363a <recover_from_log>
}
80103488:	90                   	nop
80103489:	c9                   	leave  
8010348a:	c3                   	ret    

8010348b <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
8010348b:	55                   	push   %ebp
8010348c:	89 e5                	mov    %esp,%ebp
8010348e:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103491:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103498:	e9 95 00 00 00       	jmp    80103532 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010349d:	8b 15 d4 32 11 80    	mov    0x801132d4,%edx
801034a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034a6:	01 d0                	add    %edx,%eax
801034a8:	83 c0 01             	add    $0x1,%eax
801034ab:	89 c2                	mov    %eax,%edx
801034ad:	a1 e4 32 11 80       	mov    0x801132e4,%eax
801034b2:	83 ec 08             	sub    $0x8,%esp
801034b5:	52                   	push   %edx
801034b6:	50                   	push   %eax
801034b7:	e8 fa cc ff ff       	call   801001b6 <bread>
801034bc:	83 c4 10             	add    $0x10,%esp
801034bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801034c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034c5:	83 c0 10             	add    $0x10,%eax
801034c8:	8b 04 85 ac 32 11 80 	mov    -0x7feecd54(,%eax,4),%eax
801034cf:	89 c2                	mov    %eax,%edx
801034d1:	a1 e4 32 11 80       	mov    0x801132e4,%eax
801034d6:	83 ec 08             	sub    $0x8,%esp
801034d9:	52                   	push   %edx
801034da:	50                   	push   %eax
801034db:	e8 d6 cc ff ff       	call   801001b6 <bread>
801034e0:	83 c4 10             	add    $0x10,%esp
801034e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801034e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034e9:	8d 50 18             	lea    0x18(%eax),%edx
801034ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034ef:	83 c0 18             	add    $0x18,%eax
801034f2:	83 ec 04             	sub    $0x4,%esp
801034f5:	68 00 02 00 00       	push   $0x200
801034fa:	52                   	push   %edx
801034fb:	50                   	push   %eax
801034fc:	e8 5a 29 00 00       	call   80105e5b <memmove>
80103501:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103504:	83 ec 0c             	sub    $0xc,%esp
80103507:	ff 75 ec             	pushl  -0x14(%ebp)
8010350a:	e8 e0 cc ff ff       	call   801001ef <bwrite>
8010350f:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103512:	83 ec 0c             	sub    $0xc,%esp
80103515:	ff 75 f0             	pushl  -0x10(%ebp)
80103518:	e8 11 cd ff ff       	call   8010022e <brelse>
8010351d:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103520:	83 ec 0c             	sub    $0xc,%esp
80103523:	ff 75 ec             	pushl  -0x14(%ebp)
80103526:	e8 03 cd ff ff       	call   8010022e <brelse>
8010352b:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010352e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103532:	a1 e8 32 11 80       	mov    0x801132e8,%eax
80103537:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010353a:	0f 8f 5d ff ff ff    	jg     8010349d <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103540:	90                   	nop
80103541:	c9                   	leave  
80103542:	c3                   	ret    

80103543 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103543:	55                   	push   %ebp
80103544:	89 e5                	mov    %esp,%ebp
80103546:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103549:	a1 d4 32 11 80       	mov    0x801132d4,%eax
8010354e:	89 c2                	mov    %eax,%edx
80103550:	a1 e4 32 11 80       	mov    0x801132e4,%eax
80103555:	83 ec 08             	sub    $0x8,%esp
80103558:	52                   	push   %edx
80103559:	50                   	push   %eax
8010355a:	e8 57 cc ff ff       	call   801001b6 <bread>
8010355f:	83 c4 10             	add    $0x10,%esp
80103562:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103565:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103568:	83 c0 18             	add    $0x18,%eax
8010356b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010356e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103571:	8b 00                	mov    (%eax),%eax
80103573:	a3 e8 32 11 80       	mov    %eax,0x801132e8
  for (i = 0; i < log.lh.n; i++) {
80103578:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010357f:	eb 1b                	jmp    8010359c <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103581:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103584:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103587:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010358b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010358e:	83 c2 10             	add    $0x10,%edx
80103591:	89 04 95 ac 32 11 80 	mov    %eax,-0x7feecd54(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103598:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010359c:	a1 e8 32 11 80       	mov    0x801132e8,%eax
801035a1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801035a4:	7f db                	jg     80103581 <read_head+0x3e>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
801035a6:	83 ec 0c             	sub    $0xc,%esp
801035a9:	ff 75 f0             	pushl  -0x10(%ebp)
801035ac:	e8 7d cc ff ff       	call   8010022e <brelse>
801035b1:	83 c4 10             	add    $0x10,%esp
}
801035b4:	90                   	nop
801035b5:	c9                   	leave  
801035b6:	c3                   	ret    

801035b7 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801035b7:	55                   	push   %ebp
801035b8:	89 e5                	mov    %esp,%ebp
801035ba:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801035bd:	a1 d4 32 11 80       	mov    0x801132d4,%eax
801035c2:	89 c2                	mov    %eax,%edx
801035c4:	a1 e4 32 11 80       	mov    0x801132e4,%eax
801035c9:	83 ec 08             	sub    $0x8,%esp
801035cc:	52                   	push   %edx
801035cd:	50                   	push   %eax
801035ce:	e8 e3 cb ff ff       	call   801001b6 <bread>
801035d3:	83 c4 10             	add    $0x10,%esp
801035d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801035d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035dc:	83 c0 18             	add    $0x18,%eax
801035df:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801035e2:	8b 15 e8 32 11 80    	mov    0x801132e8,%edx
801035e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035eb:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801035ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035f4:	eb 1b                	jmp    80103611 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
801035f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035f9:	83 c0 10             	add    $0x10,%eax
801035fc:	8b 0c 85 ac 32 11 80 	mov    -0x7feecd54(,%eax,4),%ecx
80103603:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103606:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103609:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
8010360d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103611:	a1 e8 32 11 80       	mov    0x801132e8,%eax
80103616:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103619:	7f db                	jg     801035f6 <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
8010361b:	83 ec 0c             	sub    $0xc,%esp
8010361e:	ff 75 f0             	pushl  -0x10(%ebp)
80103621:	e8 c9 cb ff ff       	call   801001ef <bwrite>
80103626:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103629:	83 ec 0c             	sub    $0xc,%esp
8010362c:	ff 75 f0             	pushl  -0x10(%ebp)
8010362f:	e8 fa cb ff ff       	call   8010022e <brelse>
80103634:	83 c4 10             	add    $0x10,%esp
}
80103637:	90                   	nop
80103638:	c9                   	leave  
80103639:	c3                   	ret    

8010363a <recover_from_log>:

static void
recover_from_log(void)
{
8010363a:	55                   	push   %ebp
8010363b:	89 e5                	mov    %esp,%ebp
8010363d:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103640:	e8 fe fe ff ff       	call   80103543 <read_head>
  install_trans(); // if committed, copy from log to disk
80103645:	e8 41 fe ff ff       	call   8010348b <install_trans>
  log.lh.n = 0;
8010364a:	c7 05 e8 32 11 80 00 	movl   $0x0,0x801132e8
80103651:	00 00 00 
  write_head(); // clear the log
80103654:	e8 5e ff ff ff       	call   801035b7 <write_head>
}
80103659:	90                   	nop
8010365a:	c9                   	leave  
8010365b:	c3                   	ret    

8010365c <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010365c:	55                   	push   %ebp
8010365d:	89 e5                	mov    %esp,%ebp
8010365f:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103662:	83 ec 0c             	sub    $0xc,%esp
80103665:	68 a0 32 11 80       	push   $0x801132a0
8010366a:	e8 ca 24 00 00       	call   80105b39 <acquire>
8010366f:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103672:	a1 e0 32 11 80       	mov    0x801132e0,%eax
80103677:	85 c0                	test   %eax,%eax
80103679:	74 17                	je     80103692 <begin_op+0x36>
      sleep(&log, &log.lock);
8010367b:	83 ec 08             	sub    $0x8,%esp
8010367e:	68 a0 32 11 80       	push   $0x801132a0
80103683:	68 a0 32 11 80       	push   $0x801132a0
80103688:	e8 b5 18 00 00       	call   80104f42 <sleep>
8010368d:	83 c4 10             	add    $0x10,%esp
80103690:	eb e0                	jmp    80103672 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103692:	8b 0d e8 32 11 80    	mov    0x801132e8,%ecx
80103698:	a1 dc 32 11 80       	mov    0x801132dc,%eax
8010369d:	8d 50 01             	lea    0x1(%eax),%edx
801036a0:	89 d0                	mov    %edx,%eax
801036a2:	c1 e0 02             	shl    $0x2,%eax
801036a5:	01 d0                	add    %edx,%eax
801036a7:	01 c0                	add    %eax,%eax
801036a9:	01 c8                	add    %ecx,%eax
801036ab:	83 f8 1e             	cmp    $0x1e,%eax
801036ae:	7e 17                	jle    801036c7 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801036b0:	83 ec 08             	sub    $0x8,%esp
801036b3:	68 a0 32 11 80       	push   $0x801132a0
801036b8:	68 a0 32 11 80       	push   $0x801132a0
801036bd:	e8 80 18 00 00       	call   80104f42 <sleep>
801036c2:	83 c4 10             	add    $0x10,%esp
801036c5:	eb ab                	jmp    80103672 <begin_op+0x16>
    } else {
      log.outstanding += 1;
801036c7:	a1 dc 32 11 80       	mov    0x801132dc,%eax
801036cc:	83 c0 01             	add    $0x1,%eax
801036cf:	a3 dc 32 11 80       	mov    %eax,0x801132dc
      release(&log.lock);
801036d4:	83 ec 0c             	sub    $0xc,%esp
801036d7:	68 a0 32 11 80       	push   $0x801132a0
801036dc:	e8 bf 24 00 00       	call   80105ba0 <release>
801036e1:	83 c4 10             	add    $0x10,%esp
      break;
801036e4:	90                   	nop
    }
  }
}
801036e5:	90                   	nop
801036e6:	c9                   	leave  
801036e7:	c3                   	ret    

801036e8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801036e8:	55                   	push   %ebp
801036e9:	89 e5                	mov    %esp,%ebp
801036eb:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801036ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801036f5:	83 ec 0c             	sub    $0xc,%esp
801036f8:	68 a0 32 11 80       	push   $0x801132a0
801036fd:	e8 37 24 00 00       	call   80105b39 <acquire>
80103702:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103705:	a1 dc 32 11 80       	mov    0x801132dc,%eax
8010370a:	83 e8 01             	sub    $0x1,%eax
8010370d:	a3 dc 32 11 80       	mov    %eax,0x801132dc
  if(log.committing)
80103712:	a1 e0 32 11 80       	mov    0x801132e0,%eax
80103717:	85 c0                	test   %eax,%eax
80103719:	74 0d                	je     80103728 <end_op+0x40>
    panic("log.committing");
8010371b:	83 ec 0c             	sub    $0xc,%esp
8010371e:	68 e4 96 10 80       	push   $0x801096e4
80103723:	e8 3e ce ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
80103728:	a1 dc 32 11 80       	mov    0x801132dc,%eax
8010372d:	85 c0                	test   %eax,%eax
8010372f:	75 13                	jne    80103744 <end_op+0x5c>
    do_commit = 1;
80103731:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103738:	c7 05 e0 32 11 80 01 	movl   $0x1,0x801132e0
8010373f:	00 00 00 
80103742:	eb 10                	jmp    80103754 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103744:	83 ec 0c             	sub    $0xc,%esp
80103747:	68 a0 32 11 80       	push   $0x801132a0
8010374c:	e8 d8 18 00 00       	call   80105029 <wakeup>
80103751:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103754:	83 ec 0c             	sub    $0xc,%esp
80103757:	68 a0 32 11 80       	push   $0x801132a0
8010375c:	e8 3f 24 00 00       	call   80105ba0 <release>
80103761:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103764:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103768:	74 3f                	je     801037a9 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010376a:	e8 f5 00 00 00       	call   80103864 <commit>
    acquire(&log.lock);
8010376f:	83 ec 0c             	sub    $0xc,%esp
80103772:	68 a0 32 11 80       	push   $0x801132a0
80103777:	e8 bd 23 00 00       	call   80105b39 <acquire>
8010377c:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010377f:	c7 05 e0 32 11 80 00 	movl   $0x0,0x801132e0
80103786:	00 00 00 
    wakeup(&log);
80103789:	83 ec 0c             	sub    $0xc,%esp
8010378c:	68 a0 32 11 80       	push   $0x801132a0
80103791:	e8 93 18 00 00       	call   80105029 <wakeup>
80103796:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103799:	83 ec 0c             	sub    $0xc,%esp
8010379c:	68 a0 32 11 80       	push   $0x801132a0
801037a1:	e8 fa 23 00 00       	call   80105ba0 <release>
801037a6:	83 c4 10             	add    $0x10,%esp
  }
}
801037a9:	90                   	nop
801037aa:	c9                   	leave  
801037ab:	c3                   	ret    

801037ac <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
801037ac:	55                   	push   %ebp
801037ad:	89 e5                	mov    %esp,%ebp
801037af:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801037b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037b9:	e9 95 00 00 00       	jmp    80103853 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801037be:	8b 15 d4 32 11 80    	mov    0x801132d4,%edx
801037c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037c7:	01 d0                	add    %edx,%eax
801037c9:	83 c0 01             	add    $0x1,%eax
801037cc:	89 c2                	mov    %eax,%edx
801037ce:	a1 e4 32 11 80       	mov    0x801132e4,%eax
801037d3:	83 ec 08             	sub    $0x8,%esp
801037d6:	52                   	push   %edx
801037d7:	50                   	push   %eax
801037d8:	e8 d9 c9 ff ff       	call   801001b6 <bread>
801037dd:	83 c4 10             	add    $0x10,%esp
801037e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801037e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037e6:	83 c0 10             	add    $0x10,%eax
801037e9:	8b 04 85 ac 32 11 80 	mov    -0x7feecd54(,%eax,4),%eax
801037f0:	89 c2                	mov    %eax,%edx
801037f2:	a1 e4 32 11 80       	mov    0x801132e4,%eax
801037f7:	83 ec 08             	sub    $0x8,%esp
801037fa:	52                   	push   %edx
801037fb:	50                   	push   %eax
801037fc:	e8 b5 c9 ff ff       	call   801001b6 <bread>
80103801:	83 c4 10             	add    $0x10,%esp
80103804:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103807:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010380a:	8d 50 18             	lea    0x18(%eax),%edx
8010380d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103810:	83 c0 18             	add    $0x18,%eax
80103813:	83 ec 04             	sub    $0x4,%esp
80103816:	68 00 02 00 00       	push   $0x200
8010381b:	52                   	push   %edx
8010381c:	50                   	push   %eax
8010381d:	e8 39 26 00 00       	call   80105e5b <memmove>
80103822:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103825:	83 ec 0c             	sub    $0xc,%esp
80103828:	ff 75 f0             	pushl  -0x10(%ebp)
8010382b:	e8 bf c9 ff ff       	call   801001ef <bwrite>
80103830:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
80103833:	83 ec 0c             	sub    $0xc,%esp
80103836:	ff 75 ec             	pushl  -0x14(%ebp)
80103839:	e8 f0 c9 ff ff       	call   8010022e <brelse>
8010383e:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103841:	83 ec 0c             	sub    $0xc,%esp
80103844:	ff 75 f0             	pushl  -0x10(%ebp)
80103847:	e8 e2 c9 ff ff       	call   8010022e <brelse>
8010384c:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010384f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103853:	a1 e8 32 11 80       	mov    0x801132e8,%eax
80103858:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010385b:	0f 8f 5d ff ff ff    	jg     801037be <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103861:	90                   	nop
80103862:	c9                   	leave  
80103863:	c3                   	ret    

80103864 <commit>:

static void
commit()
{
80103864:	55                   	push   %ebp
80103865:	89 e5                	mov    %esp,%ebp
80103867:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010386a:	a1 e8 32 11 80       	mov    0x801132e8,%eax
8010386f:	85 c0                	test   %eax,%eax
80103871:	7e 1e                	jle    80103891 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103873:	e8 34 ff ff ff       	call   801037ac <write_log>
    write_head();    // Write header to disk -- the real commit
80103878:	e8 3a fd ff ff       	call   801035b7 <write_head>
    install_trans(); // Now install writes to home locations
8010387d:	e8 09 fc ff ff       	call   8010348b <install_trans>
    log.lh.n = 0; 
80103882:	c7 05 e8 32 11 80 00 	movl   $0x0,0x801132e8
80103889:	00 00 00 
    write_head();    // Erase the transaction from the log
8010388c:	e8 26 fd ff ff       	call   801035b7 <write_head>
  }
}
80103891:	90                   	nop
80103892:	c9                   	leave  
80103893:	c3                   	ret    

80103894 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103894:	55                   	push   %ebp
80103895:	89 e5                	mov    %esp,%ebp
80103897:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010389a:	a1 e8 32 11 80       	mov    0x801132e8,%eax
8010389f:	83 f8 1d             	cmp    $0x1d,%eax
801038a2:	7f 12                	jg     801038b6 <log_write+0x22>
801038a4:	a1 e8 32 11 80       	mov    0x801132e8,%eax
801038a9:	8b 15 d8 32 11 80    	mov    0x801132d8,%edx
801038af:	83 ea 01             	sub    $0x1,%edx
801038b2:	39 d0                	cmp    %edx,%eax
801038b4:	7c 0d                	jl     801038c3 <log_write+0x2f>
    panic("too big a transaction");
801038b6:	83 ec 0c             	sub    $0xc,%esp
801038b9:	68 f3 96 10 80       	push   $0x801096f3
801038be:	e8 a3 cc ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
801038c3:	a1 dc 32 11 80       	mov    0x801132dc,%eax
801038c8:	85 c0                	test   %eax,%eax
801038ca:	7f 0d                	jg     801038d9 <log_write+0x45>
    panic("log_write outside of trans");
801038cc:	83 ec 0c             	sub    $0xc,%esp
801038cf:	68 09 97 10 80       	push   $0x80109709
801038d4:	e8 8d cc ff ff       	call   80100566 <panic>

  acquire(&log.lock);
801038d9:	83 ec 0c             	sub    $0xc,%esp
801038dc:	68 a0 32 11 80       	push   $0x801132a0
801038e1:	e8 53 22 00 00       	call   80105b39 <acquire>
801038e6:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801038e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038f0:	eb 1d                	jmp    8010390f <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801038f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038f5:	83 c0 10             	add    $0x10,%eax
801038f8:	8b 04 85 ac 32 11 80 	mov    -0x7feecd54(,%eax,4),%eax
801038ff:	89 c2                	mov    %eax,%edx
80103901:	8b 45 08             	mov    0x8(%ebp),%eax
80103904:	8b 40 08             	mov    0x8(%eax),%eax
80103907:	39 c2                	cmp    %eax,%edx
80103909:	74 10                	je     8010391b <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
8010390b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010390f:	a1 e8 32 11 80       	mov    0x801132e8,%eax
80103914:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103917:	7f d9                	jg     801038f2 <log_write+0x5e>
80103919:	eb 01                	jmp    8010391c <log_write+0x88>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
8010391b:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
8010391c:	8b 45 08             	mov    0x8(%ebp),%eax
8010391f:	8b 40 08             	mov    0x8(%eax),%eax
80103922:	89 c2                	mov    %eax,%edx
80103924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103927:	83 c0 10             	add    $0x10,%eax
8010392a:	89 14 85 ac 32 11 80 	mov    %edx,-0x7feecd54(,%eax,4)
  if (i == log.lh.n)
80103931:	a1 e8 32 11 80       	mov    0x801132e8,%eax
80103936:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103939:	75 0d                	jne    80103948 <log_write+0xb4>
    log.lh.n++;
8010393b:	a1 e8 32 11 80       	mov    0x801132e8,%eax
80103940:	83 c0 01             	add    $0x1,%eax
80103943:	a3 e8 32 11 80       	mov    %eax,0x801132e8
  b->flags |= B_DIRTY; // prevent eviction
80103948:	8b 45 08             	mov    0x8(%ebp),%eax
8010394b:	8b 00                	mov    (%eax),%eax
8010394d:	83 c8 04             	or     $0x4,%eax
80103950:	89 c2                	mov    %eax,%edx
80103952:	8b 45 08             	mov    0x8(%ebp),%eax
80103955:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103957:	83 ec 0c             	sub    $0xc,%esp
8010395a:	68 a0 32 11 80       	push   $0x801132a0
8010395f:	e8 3c 22 00 00       	call   80105ba0 <release>
80103964:	83 c4 10             	add    $0x10,%esp
}
80103967:	90                   	nop
80103968:	c9                   	leave  
80103969:	c3                   	ret    

8010396a <v2p>:
8010396a:	55                   	push   %ebp
8010396b:	89 e5                	mov    %esp,%ebp
8010396d:	8b 45 08             	mov    0x8(%ebp),%eax
80103970:	05 00 00 00 80       	add    $0x80000000,%eax
80103975:	5d                   	pop    %ebp
80103976:	c3                   	ret    

80103977 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103977:	55                   	push   %ebp
80103978:	89 e5                	mov    %esp,%ebp
8010397a:	8b 45 08             	mov    0x8(%ebp),%eax
8010397d:	05 00 00 00 80       	add    $0x80000000,%eax
80103982:	5d                   	pop    %ebp
80103983:	c3                   	ret    

80103984 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103984:	55                   	push   %ebp
80103985:	89 e5                	mov    %esp,%ebp
80103987:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010398a:	8b 55 08             	mov    0x8(%ebp),%edx
8010398d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103990:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103993:	f0 87 02             	lock xchg %eax,(%edx)
80103996:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103999:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010399c:	c9                   	leave  
8010399d:	c3                   	ret    

8010399e <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010399e:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801039a2:	83 e4 f0             	and    $0xfffffff0,%esp
801039a5:	ff 71 fc             	pushl  -0x4(%ecx)
801039a8:	55                   	push   %ebp
801039a9:	89 e5                	mov    %esp,%ebp
801039ab:	51                   	push   %ecx
801039ac:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801039af:	83 ec 08             	sub    $0x8,%esp
801039b2:	68 00 00 40 80       	push   $0x80400000
801039b7:	68 9c 69 11 80       	push   $0x8011699c
801039bc:	e8 7d f2 ff ff       	call   80102c3e <kinit1>
801039c1:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801039c4:	e8 2b 53 00 00       	call   80108cf4 <kvmalloc>
  mpinit();        // collect info about this machine
801039c9:	e8 43 04 00 00       	call   80103e11 <mpinit>
  lapicinit();
801039ce:	e8 ea f5 ff ff       	call   80102fbd <lapicinit>
  seginit();       // set up segments
801039d3:	e8 c5 4c 00 00       	call   8010869d <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801039d8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801039de:	0f b6 00             	movzbl (%eax),%eax
801039e1:	0f b6 c0             	movzbl %al,%eax
801039e4:	83 ec 08             	sub    $0x8,%esp
801039e7:	50                   	push   %eax
801039e8:	68 24 97 10 80       	push   $0x80109724
801039ed:	e8 d4 c9 ff ff       	call   801003c6 <cprintf>
801039f2:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
801039f5:	e8 6d 06 00 00       	call   80104067 <picinit>
  ioapicinit();    // another interrupt controller
801039fa:	e8 34 f1 ff ff       	call   80102b33 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801039ff:	e8 15 d1 ff ff       	call   80100b19 <consoleinit>
  uartinit();      // serial port
80103a04:	e8 f0 3f 00 00       	call   801079f9 <uartinit>
  pinit();         // process table
80103a09:	e8 5d 0b 00 00       	call   8010456b <pinit>
  tvinit();        // trap vectors
80103a0e:	e8 bf 3b 00 00       	call   801075d2 <tvinit>
  binit();         // buffer cache
80103a13:	e8 1c c6 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103a18:	e8 ef d5 ff ff       	call   8010100c <fileinit>
  ideinit();       // disk
80103a1d:	e8 19 ed ff ff       	call   8010273b <ideinit>
  if(!ismp)
80103a22:	a1 84 33 11 80       	mov    0x80113384,%eax
80103a27:	85 c0                	test   %eax,%eax
80103a29:	75 05                	jne    80103a30 <main+0x92>
    timerinit();   // uniprocessor timer
80103a2b:	e8 f3 3a 00 00       	call   80107523 <timerinit>
  startothers();   // start other processors
80103a30:	e8 7f 00 00 00       	call   80103ab4 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103a35:	83 ec 08             	sub    $0x8,%esp
80103a38:	68 00 00 00 8e       	push   $0x8e000000
80103a3d:	68 00 00 40 80       	push   $0x80400000
80103a42:	e8 30 f2 ff ff       	call   80102c77 <kinit2>
80103a47:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103a4a:	e8 9f 0c 00 00       	call   801046ee <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103a4f:	e8 1a 00 00 00       	call   80103a6e <mpmain>

80103a54 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103a54:	55                   	push   %ebp
80103a55:	89 e5                	mov    %esp,%ebp
80103a57:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80103a5a:	e8 ad 52 00 00       	call   80108d0c <switchkvm>
  seginit();
80103a5f:	e8 39 4c 00 00       	call   8010869d <seginit>
  lapicinit();
80103a64:	e8 54 f5 ff ff       	call   80102fbd <lapicinit>
  mpmain();
80103a69:	e8 00 00 00 00       	call   80103a6e <mpmain>

80103a6e <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103a6e:	55                   	push   %ebp
80103a6f:	89 e5                	mov    %esp,%ebp
80103a71:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103a74:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103a7a:	0f b6 00             	movzbl (%eax),%eax
80103a7d:	0f b6 c0             	movzbl %al,%eax
80103a80:	83 ec 08             	sub    $0x8,%esp
80103a83:	50                   	push   %eax
80103a84:	68 3b 97 10 80       	push   $0x8010973b
80103a89:	e8 38 c9 ff ff       	call   801003c6 <cprintf>
80103a8e:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103a91:	e8 9d 3c 00 00       	call   80107733 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103a96:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103a9c:	05 a8 00 00 00       	add    $0xa8,%eax
80103aa1:	83 ec 08             	sub    $0x8,%esp
80103aa4:	6a 01                	push   $0x1
80103aa6:	50                   	push   %eax
80103aa7:	e8 d8 fe ff ff       	call   80103984 <xchg>
80103aac:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103aaf:	e8 37 12 00 00       	call   80104ceb <scheduler>

80103ab4 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103ab4:	55                   	push   %ebp
80103ab5:	89 e5                	mov    %esp,%ebp
80103ab7:	53                   	push   %ebx
80103ab8:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103abb:	68 00 70 00 00       	push   $0x7000
80103ac0:	e8 b2 fe ff ff       	call   80103977 <p2v>
80103ac5:	83 c4 04             	add    $0x4,%esp
80103ac8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103acb:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103ad0:	83 ec 04             	sub    $0x4,%esp
80103ad3:	50                   	push   %eax
80103ad4:	68 4c c5 10 80       	push   $0x8010c54c
80103ad9:	ff 75 f0             	pushl  -0x10(%ebp)
80103adc:	e8 7a 23 00 00       	call   80105e5b <memmove>
80103ae1:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103ae4:	c7 45 f4 a0 33 11 80 	movl   $0x801133a0,-0xc(%ebp)
80103aeb:	e9 90 00 00 00       	jmp    80103b80 <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
80103af0:	e8 e6 f5 ff ff       	call   801030db <cpunum>
80103af5:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103afb:	05 a0 33 11 80       	add    $0x801133a0,%eax
80103b00:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b03:	74 73                	je     80103b78 <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103b05:	e8 6b f2 ff ff       	call   80102d75 <kalloc>
80103b0a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103b0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b10:	83 e8 04             	sub    $0x4,%eax
80103b13:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103b16:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103b1c:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103b1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b21:	83 e8 08             	sub    $0x8,%eax
80103b24:	c7 00 54 3a 10 80    	movl   $0x80103a54,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103b2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b2d:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103b30:	83 ec 0c             	sub    $0xc,%esp
80103b33:	68 00 b0 10 80       	push   $0x8010b000
80103b38:	e8 2d fe ff ff       	call   8010396a <v2p>
80103b3d:	83 c4 10             	add    $0x10,%esp
80103b40:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103b42:	83 ec 0c             	sub    $0xc,%esp
80103b45:	ff 75 f0             	pushl  -0x10(%ebp)
80103b48:	e8 1d fe ff ff       	call   8010396a <v2p>
80103b4d:	83 c4 10             	add    $0x10,%esp
80103b50:	89 c2                	mov    %eax,%edx
80103b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b55:	0f b6 00             	movzbl (%eax),%eax
80103b58:	0f b6 c0             	movzbl %al,%eax
80103b5b:	83 ec 08             	sub    $0x8,%esp
80103b5e:	52                   	push   %edx
80103b5f:	50                   	push   %eax
80103b60:	e8 f0 f5 ff ff       	call   80103155 <lapicstartap>
80103b65:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103b68:	90                   	nop
80103b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b6c:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103b72:	85 c0                	test   %eax,%eax
80103b74:	74 f3                	je     80103b69 <startothers+0xb5>
80103b76:	eb 01                	jmp    80103b79 <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103b78:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103b79:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103b80:	a1 80 39 11 80       	mov    0x80113980,%eax
80103b85:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103b8b:	05 a0 33 11 80       	add    $0x801133a0,%eax
80103b90:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b93:	0f 87 57 ff ff ff    	ja     80103af0 <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103b99:	90                   	nop
80103b9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b9d:	c9                   	leave  
80103b9e:	c3                   	ret    

80103b9f <p2v>:
80103b9f:	55                   	push   %ebp
80103ba0:	89 e5                	mov    %esp,%ebp
80103ba2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ba5:	05 00 00 00 80       	add    $0x80000000,%eax
80103baa:	5d                   	pop    %ebp
80103bab:	c3                   	ret    

80103bac <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80103bac:	55                   	push   %ebp
80103bad:	89 e5                	mov    %esp,%ebp
80103baf:	83 ec 14             	sub    $0x14,%esp
80103bb2:	8b 45 08             	mov    0x8(%ebp),%eax
80103bb5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103bb9:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103bbd:	89 c2                	mov    %eax,%edx
80103bbf:	ec                   	in     (%dx),%al
80103bc0:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103bc3:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103bc7:	c9                   	leave  
80103bc8:	c3                   	ret    

80103bc9 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103bc9:	55                   	push   %ebp
80103bca:	89 e5                	mov    %esp,%ebp
80103bcc:	83 ec 08             	sub    $0x8,%esp
80103bcf:	8b 55 08             	mov    0x8(%ebp),%edx
80103bd2:	8b 45 0c             	mov    0xc(%ebp),%eax
80103bd5:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103bd9:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103bdc:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103be0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103be4:	ee                   	out    %al,(%dx)
}
80103be5:	90                   	nop
80103be6:	c9                   	leave  
80103be7:	c3                   	ret    

80103be8 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103be8:	55                   	push   %ebp
80103be9:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103beb:	a1 84 c6 10 80       	mov    0x8010c684,%eax
80103bf0:	89 c2                	mov    %eax,%edx
80103bf2:	b8 a0 33 11 80       	mov    $0x801133a0,%eax
80103bf7:	29 c2                	sub    %eax,%edx
80103bf9:	89 d0                	mov    %edx,%eax
80103bfb:	c1 f8 02             	sar    $0x2,%eax
80103bfe:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103c04:	5d                   	pop    %ebp
80103c05:	c3                   	ret    

80103c06 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103c06:	55                   	push   %ebp
80103c07:	89 e5                	mov    %esp,%ebp
80103c09:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103c0c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103c13:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103c1a:	eb 15                	jmp    80103c31 <sum+0x2b>
    sum += addr[i];
80103c1c:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103c1f:	8b 45 08             	mov    0x8(%ebp),%eax
80103c22:	01 d0                	add    %edx,%eax
80103c24:	0f b6 00             	movzbl (%eax),%eax
80103c27:	0f b6 c0             	movzbl %al,%eax
80103c2a:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103c2d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103c31:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103c34:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103c37:	7c e3                	jl     80103c1c <sum+0x16>
    sum += addr[i];
  return sum;
80103c39:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103c3c:	c9                   	leave  
80103c3d:	c3                   	ret    

80103c3e <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103c3e:	55                   	push   %ebp
80103c3f:	89 e5                	mov    %esp,%ebp
80103c41:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103c44:	ff 75 08             	pushl  0x8(%ebp)
80103c47:	e8 53 ff ff ff       	call   80103b9f <p2v>
80103c4c:	83 c4 04             	add    $0x4,%esp
80103c4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103c52:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c58:	01 d0                	add    %edx,%eax
80103c5a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103c5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c60:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c63:	eb 36                	jmp    80103c9b <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103c65:	83 ec 04             	sub    $0x4,%esp
80103c68:	6a 04                	push   $0x4
80103c6a:	68 4c 97 10 80       	push   $0x8010974c
80103c6f:	ff 75 f4             	pushl  -0xc(%ebp)
80103c72:	e8 8c 21 00 00       	call   80105e03 <memcmp>
80103c77:	83 c4 10             	add    $0x10,%esp
80103c7a:	85 c0                	test   %eax,%eax
80103c7c:	75 19                	jne    80103c97 <mpsearch1+0x59>
80103c7e:	83 ec 08             	sub    $0x8,%esp
80103c81:	6a 10                	push   $0x10
80103c83:	ff 75 f4             	pushl  -0xc(%ebp)
80103c86:	e8 7b ff ff ff       	call   80103c06 <sum>
80103c8b:	83 c4 10             	add    $0x10,%esp
80103c8e:	84 c0                	test   %al,%al
80103c90:	75 05                	jne    80103c97 <mpsearch1+0x59>
      return (struct mp*)p;
80103c92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c95:	eb 11                	jmp    80103ca8 <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103c97:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c9e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103ca1:	72 c2                	jb     80103c65 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103ca3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103ca8:	c9                   	leave  
80103ca9:	c3                   	ret    

80103caa <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103caa:	55                   	push   %ebp
80103cab:	89 e5                	mov    %esp,%ebp
80103cad:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103cb0:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cba:	83 c0 0f             	add    $0xf,%eax
80103cbd:	0f b6 00             	movzbl (%eax),%eax
80103cc0:	0f b6 c0             	movzbl %al,%eax
80103cc3:	c1 e0 08             	shl    $0x8,%eax
80103cc6:	89 c2                	mov    %eax,%edx
80103cc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ccb:	83 c0 0e             	add    $0xe,%eax
80103cce:	0f b6 00             	movzbl (%eax),%eax
80103cd1:	0f b6 c0             	movzbl %al,%eax
80103cd4:	09 d0                	or     %edx,%eax
80103cd6:	c1 e0 04             	shl    $0x4,%eax
80103cd9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103cdc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103ce0:	74 21                	je     80103d03 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103ce2:	83 ec 08             	sub    $0x8,%esp
80103ce5:	68 00 04 00 00       	push   $0x400
80103cea:	ff 75 f0             	pushl  -0x10(%ebp)
80103ced:	e8 4c ff ff ff       	call   80103c3e <mpsearch1>
80103cf2:	83 c4 10             	add    $0x10,%esp
80103cf5:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103cf8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103cfc:	74 51                	je     80103d4f <mpsearch+0xa5>
      return mp;
80103cfe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d01:	eb 61                	jmp    80103d64 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103d03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d06:	83 c0 14             	add    $0x14,%eax
80103d09:	0f b6 00             	movzbl (%eax),%eax
80103d0c:	0f b6 c0             	movzbl %al,%eax
80103d0f:	c1 e0 08             	shl    $0x8,%eax
80103d12:	89 c2                	mov    %eax,%edx
80103d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d17:	83 c0 13             	add    $0x13,%eax
80103d1a:	0f b6 00             	movzbl (%eax),%eax
80103d1d:	0f b6 c0             	movzbl %al,%eax
80103d20:	09 d0                	or     %edx,%eax
80103d22:	c1 e0 0a             	shl    $0xa,%eax
80103d25:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103d28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d2b:	2d 00 04 00 00       	sub    $0x400,%eax
80103d30:	83 ec 08             	sub    $0x8,%esp
80103d33:	68 00 04 00 00       	push   $0x400
80103d38:	50                   	push   %eax
80103d39:	e8 00 ff ff ff       	call   80103c3e <mpsearch1>
80103d3e:	83 c4 10             	add    $0x10,%esp
80103d41:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d44:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d48:	74 05                	je     80103d4f <mpsearch+0xa5>
      return mp;
80103d4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d4d:	eb 15                	jmp    80103d64 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103d4f:	83 ec 08             	sub    $0x8,%esp
80103d52:	68 00 00 01 00       	push   $0x10000
80103d57:	68 00 00 0f 00       	push   $0xf0000
80103d5c:	e8 dd fe ff ff       	call   80103c3e <mpsearch1>
80103d61:	83 c4 10             	add    $0x10,%esp
}
80103d64:	c9                   	leave  
80103d65:	c3                   	ret    

80103d66 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103d66:	55                   	push   %ebp
80103d67:	89 e5                	mov    %esp,%ebp
80103d69:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103d6c:	e8 39 ff ff ff       	call   80103caa <mpsearch>
80103d71:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d74:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d78:	74 0a                	je     80103d84 <mpconfig+0x1e>
80103d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d7d:	8b 40 04             	mov    0x4(%eax),%eax
80103d80:	85 c0                	test   %eax,%eax
80103d82:	75 0a                	jne    80103d8e <mpconfig+0x28>
    return 0;
80103d84:	b8 00 00 00 00       	mov    $0x0,%eax
80103d89:	e9 81 00 00 00       	jmp    80103e0f <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d91:	8b 40 04             	mov    0x4(%eax),%eax
80103d94:	83 ec 0c             	sub    $0xc,%esp
80103d97:	50                   	push   %eax
80103d98:	e8 02 fe ff ff       	call   80103b9f <p2v>
80103d9d:	83 c4 10             	add    $0x10,%esp
80103da0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103da3:	83 ec 04             	sub    $0x4,%esp
80103da6:	6a 04                	push   $0x4
80103da8:	68 51 97 10 80       	push   $0x80109751
80103dad:	ff 75 f0             	pushl  -0x10(%ebp)
80103db0:	e8 4e 20 00 00       	call   80105e03 <memcmp>
80103db5:	83 c4 10             	add    $0x10,%esp
80103db8:	85 c0                	test   %eax,%eax
80103dba:	74 07                	je     80103dc3 <mpconfig+0x5d>
    return 0;
80103dbc:	b8 00 00 00 00       	mov    $0x0,%eax
80103dc1:	eb 4c                	jmp    80103e0f <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103dc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dc6:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103dca:	3c 01                	cmp    $0x1,%al
80103dcc:	74 12                	je     80103de0 <mpconfig+0x7a>
80103dce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dd1:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103dd5:	3c 04                	cmp    $0x4,%al
80103dd7:	74 07                	je     80103de0 <mpconfig+0x7a>
    return 0;
80103dd9:	b8 00 00 00 00       	mov    $0x0,%eax
80103dde:	eb 2f                	jmp    80103e0f <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80103de0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103de3:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103de7:	0f b7 c0             	movzwl %ax,%eax
80103dea:	83 ec 08             	sub    $0x8,%esp
80103ded:	50                   	push   %eax
80103dee:	ff 75 f0             	pushl  -0x10(%ebp)
80103df1:	e8 10 fe ff ff       	call   80103c06 <sum>
80103df6:	83 c4 10             	add    $0x10,%esp
80103df9:	84 c0                	test   %al,%al
80103dfb:	74 07                	je     80103e04 <mpconfig+0x9e>
    return 0;
80103dfd:	b8 00 00 00 00       	mov    $0x0,%eax
80103e02:	eb 0b                	jmp    80103e0f <mpconfig+0xa9>
  *pmp = mp;
80103e04:	8b 45 08             	mov    0x8(%ebp),%eax
80103e07:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e0a:	89 10                	mov    %edx,(%eax)
  return conf;
80103e0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103e0f:	c9                   	leave  
80103e10:	c3                   	ret    

80103e11 <mpinit>:

void
mpinit(void)
{
80103e11:	55                   	push   %ebp
80103e12:	89 e5                	mov    %esp,%ebp
80103e14:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103e17:	c7 05 84 c6 10 80 a0 	movl   $0x801133a0,0x8010c684
80103e1e:	33 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103e21:	83 ec 0c             	sub    $0xc,%esp
80103e24:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103e27:	50                   	push   %eax
80103e28:	e8 39 ff ff ff       	call   80103d66 <mpconfig>
80103e2d:	83 c4 10             	add    $0x10,%esp
80103e30:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103e33:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103e37:	0f 84 96 01 00 00    	je     80103fd3 <mpinit+0x1c2>
    return;
  ismp = 1;
80103e3d:	c7 05 84 33 11 80 01 	movl   $0x1,0x80113384
80103e44:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103e47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e4a:	8b 40 24             	mov    0x24(%eax),%eax
80103e4d:	a3 9c 32 11 80       	mov    %eax,0x8011329c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103e52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e55:	83 c0 2c             	add    $0x2c,%eax
80103e58:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e5e:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103e62:	0f b7 d0             	movzwl %ax,%edx
80103e65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e68:	01 d0                	add    %edx,%eax
80103e6a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103e6d:	e9 f2 00 00 00       	jmp    80103f64 <mpinit+0x153>
    switch(*p){
80103e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e75:	0f b6 00             	movzbl (%eax),%eax
80103e78:	0f b6 c0             	movzbl %al,%eax
80103e7b:	83 f8 04             	cmp    $0x4,%eax
80103e7e:	0f 87 bc 00 00 00    	ja     80103f40 <mpinit+0x12f>
80103e84:	8b 04 85 94 97 10 80 	mov    -0x7fef686c(,%eax,4),%eax
80103e8b:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e90:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103e93:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e96:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e9a:	0f b6 d0             	movzbl %al,%edx
80103e9d:	a1 80 39 11 80       	mov    0x80113980,%eax
80103ea2:	39 c2                	cmp    %eax,%edx
80103ea4:	74 2b                	je     80103ed1 <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103ea6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103ea9:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103ead:	0f b6 d0             	movzbl %al,%edx
80103eb0:	a1 80 39 11 80       	mov    0x80113980,%eax
80103eb5:	83 ec 04             	sub    $0x4,%esp
80103eb8:	52                   	push   %edx
80103eb9:	50                   	push   %eax
80103eba:	68 56 97 10 80       	push   $0x80109756
80103ebf:	e8 02 c5 ff ff       	call   801003c6 <cprintf>
80103ec4:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103ec7:	c7 05 84 33 11 80 00 	movl   $0x0,0x80113384
80103ece:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103ed1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103ed4:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103ed8:	0f b6 c0             	movzbl %al,%eax
80103edb:	83 e0 02             	and    $0x2,%eax
80103ede:	85 c0                	test   %eax,%eax
80103ee0:	74 15                	je     80103ef7 <mpinit+0xe6>
        bcpu = &cpus[ncpu];
80103ee2:	a1 80 39 11 80       	mov    0x80113980,%eax
80103ee7:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103eed:	05 a0 33 11 80       	add    $0x801133a0,%eax
80103ef2:	a3 84 c6 10 80       	mov    %eax,0x8010c684
      cpus[ncpu].id = ncpu;
80103ef7:	a1 80 39 11 80       	mov    0x80113980,%eax
80103efc:	8b 15 80 39 11 80    	mov    0x80113980,%edx
80103f02:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103f08:	05 a0 33 11 80       	add    $0x801133a0,%eax
80103f0d:	88 10                	mov    %dl,(%eax)
      ncpu++;
80103f0f:	a1 80 39 11 80       	mov    0x80113980,%eax
80103f14:	83 c0 01             	add    $0x1,%eax
80103f17:	a3 80 39 11 80       	mov    %eax,0x80113980
      p += sizeof(struct mpproc);
80103f1c:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103f20:	eb 42                	jmp    80103f64 <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f25:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103f28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103f2b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103f2f:	a2 80 33 11 80       	mov    %al,0x80113380
      p += sizeof(struct mpioapic);
80103f34:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f38:	eb 2a                	jmp    80103f64 <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103f3a:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f3e:	eb 24                	jmp    80103f64 <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103f40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f43:	0f b6 00             	movzbl (%eax),%eax
80103f46:	0f b6 c0             	movzbl %al,%eax
80103f49:	83 ec 08             	sub    $0x8,%esp
80103f4c:	50                   	push   %eax
80103f4d:	68 74 97 10 80       	push   $0x80109774
80103f52:	e8 6f c4 ff ff       	call   801003c6 <cprintf>
80103f57:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103f5a:	c7 05 84 33 11 80 00 	movl   $0x0,0x80113384
80103f61:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103f64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f67:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103f6a:	0f 82 02 ff ff ff    	jb     80103e72 <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103f70:	a1 84 33 11 80       	mov    0x80113384,%eax
80103f75:	85 c0                	test   %eax,%eax
80103f77:	75 1d                	jne    80103f96 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103f79:	c7 05 80 39 11 80 01 	movl   $0x1,0x80113980
80103f80:	00 00 00 
    lapic = 0;
80103f83:	c7 05 9c 32 11 80 00 	movl   $0x0,0x8011329c
80103f8a:	00 00 00 
    ioapicid = 0;
80103f8d:	c6 05 80 33 11 80 00 	movb   $0x0,0x80113380
    return;
80103f94:	eb 3e                	jmp    80103fd4 <mpinit+0x1c3>
  }

  if(mp->imcrp){
80103f96:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f99:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103f9d:	84 c0                	test   %al,%al
80103f9f:	74 33                	je     80103fd4 <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103fa1:	83 ec 08             	sub    $0x8,%esp
80103fa4:	6a 70                	push   $0x70
80103fa6:	6a 22                	push   $0x22
80103fa8:	e8 1c fc ff ff       	call   80103bc9 <outb>
80103fad:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103fb0:	83 ec 0c             	sub    $0xc,%esp
80103fb3:	6a 23                	push   $0x23
80103fb5:	e8 f2 fb ff ff       	call   80103bac <inb>
80103fba:	83 c4 10             	add    $0x10,%esp
80103fbd:	83 c8 01             	or     $0x1,%eax
80103fc0:	0f b6 c0             	movzbl %al,%eax
80103fc3:	83 ec 08             	sub    $0x8,%esp
80103fc6:	50                   	push   %eax
80103fc7:	6a 23                	push   $0x23
80103fc9:	e8 fb fb ff ff       	call   80103bc9 <outb>
80103fce:	83 c4 10             	add    $0x10,%esp
80103fd1:	eb 01                	jmp    80103fd4 <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103fd3:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103fd4:	c9                   	leave  
80103fd5:	c3                   	ret    

80103fd6 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103fd6:	55                   	push   %ebp
80103fd7:	89 e5                	mov    %esp,%ebp
80103fd9:	83 ec 08             	sub    $0x8,%esp
80103fdc:	8b 55 08             	mov    0x8(%ebp),%edx
80103fdf:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fe2:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103fe6:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103fe9:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103fed:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103ff1:	ee                   	out    %al,(%dx)
}
80103ff2:	90                   	nop
80103ff3:	c9                   	leave  
80103ff4:	c3                   	ret    

80103ff5 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103ff5:	55                   	push   %ebp
80103ff6:	89 e5                	mov    %esp,%ebp
80103ff8:	83 ec 04             	sub    $0x4,%esp
80103ffb:	8b 45 08             	mov    0x8(%ebp),%eax
80103ffe:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80104002:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104006:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
8010400c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104010:	0f b6 c0             	movzbl %al,%eax
80104013:	50                   	push   %eax
80104014:	6a 21                	push   $0x21
80104016:	e8 bb ff ff ff       	call   80103fd6 <outb>
8010401b:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
8010401e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104022:	66 c1 e8 08          	shr    $0x8,%ax
80104026:	0f b6 c0             	movzbl %al,%eax
80104029:	50                   	push   %eax
8010402a:	68 a1 00 00 00       	push   $0xa1
8010402f:	e8 a2 ff ff ff       	call   80103fd6 <outb>
80104034:	83 c4 08             	add    $0x8,%esp
}
80104037:	90                   	nop
80104038:	c9                   	leave  
80104039:	c3                   	ret    

8010403a <picenable>:

void
picenable(int irq)
{
8010403a:	55                   	push   %ebp
8010403b:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
8010403d:	8b 45 08             	mov    0x8(%ebp),%eax
80104040:	ba 01 00 00 00       	mov    $0x1,%edx
80104045:	89 c1                	mov    %eax,%ecx
80104047:	d3 e2                	shl    %cl,%edx
80104049:	89 d0                	mov    %edx,%eax
8010404b:	f7 d0                	not    %eax
8010404d:	89 c2                	mov    %eax,%edx
8010404f:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104056:	21 d0                	and    %edx,%eax
80104058:	0f b7 c0             	movzwl %ax,%eax
8010405b:	50                   	push   %eax
8010405c:	e8 94 ff ff ff       	call   80103ff5 <picsetmask>
80104061:	83 c4 04             	add    $0x4,%esp
}
80104064:	90                   	nop
80104065:	c9                   	leave  
80104066:	c3                   	ret    

80104067 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80104067:	55                   	push   %ebp
80104068:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
8010406a:	68 ff 00 00 00       	push   $0xff
8010406f:	6a 21                	push   $0x21
80104071:	e8 60 ff ff ff       	call   80103fd6 <outb>
80104076:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80104079:	68 ff 00 00 00       	push   $0xff
8010407e:	68 a1 00 00 00       	push   $0xa1
80104083:	e8 4e ff ff ff       	call   80103fd6 <outb>
80104088:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
8010408b:	6a 11                	push   $0x11
8010408d:	6a 20                	push   $0x20
8010408f:	e8 42 ff ff ff       	call   80103fd6 <outb>
80104094:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80104097:	6a 20                	push   $0x20
80104099:	6a 21                	push   $0x21
8010409b:	e8 36 ff ff ff       	call   80103fd6 <outb>
801040a0:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
801040a3:	6a 04                	push   $0x4
801040a5:	6a 21                	push   $0x21
801040a7:	e8 2a ff ff ff       	call   80103fd6 <outb>
801040ac:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
801040af:	6a 03                	push   $0x3
801040b1:	6a 21                	push   $0x21
801040b3:	e8 1e ff ff ff       	call   80103fd6 <outb>
801040b8:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
801040bb:	6a 11                	push   $0x11
801040bd:	68 a0 00 00 00       	push   $0xa0
801040c2:	e8 0f ff ff ff       	call   80103fd6 <outb>
801040c7:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
801040ca:	6a 28                	push   $0x28
801040cc:	68 a1 00 00 00       	push   $0xa1
801040d1:	e8 00 ff ff ff       	call   80103fd6 <outb>
801040d6:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
801040d9:	6a 02                	push   $0x2
801040db:	68 a1 00 00 00       	push   $0xa1
801040e0:	e8 f1 fe ff ff       	call   80103fd6 <outb>
801040e5:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
801040e8:	6a 03                	push   $0x3
801040ea:	68 a1 00 00 00       	push   $0xa1
801040ef:	e8 e2 fe ff ff       	call   80103fd6 <outb>
801040f4:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
801040f7:	6a 68                	push   $0x68
801040f9:	6a 20                	push   $0x20
801040fb:	e8 d6 fe ff ff       	call   80103fd6 <outb>
80104100:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80104103:	6a 0a                	push   $0xa
80104105:	6a 20                	push   $0x20
80104107:	e8 ca fe ff ff       	call   80103fd6 <outb>
8010410c:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
8010410f:	6a 68                	push   $0x68
80104111:	68 a0 00 00 00       	push   $0xa0
80104116:	e8 bb fe ff ff       	call   80103fd6 <outb>
8010411b:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
8010411e:	6a 0a                	push   $0xa
80104120:	68 a0 00 00 00       	push   $0xa0
80104125:	e8 ac fe ff ff       	call   80103fd6 <outb>
8010412a:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
8010412d:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104134:	66 83 f8 ff          	cmp    $0xffff,%ax
80104138:	74 13                	je     8010414d <picinit+0xe6>
    picsetmask(irqmask);
8010413a:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104141:	0f b7 c0             	movzwl %ax,%eax
80104144:	50                   	push   %eax
80104145:	e8 ab fe ff ff       	call   80103ff5 <picsetmask>
8010414a:	83 c4 04             	add    $0x4,%esp
}
8010414d:	90                   	nop
8010414e:	c9                   	leave  
8010414f:	c3                   	ret    

80104150 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104150:	55                   	push   %ebp
80104151:	89 e5                	mov    %esp,%ebp
80104153:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80104156:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010415d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104160:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104166:	8b 45 0c             	mov    0xc(%ebp),%eax
80104169:	8b 10                	mov    (%eax),%edx
8010416b:	8b 45 08             	mov    0x8(%ebp),%eax
8010416e:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104170:	e8 b5 ce ff ff       	call   8010102a <filealloc>
80104175:	89 c2                	mov    %eax,%edx
80104177:	8b 45 08             	mov    0x8(%ebp),%eax
8010417a:	89 10                	mov    %edx,(%eax)
8010417c:	8b 45 08             	mov    0x8(%ebp),%eax
8010417f:	8b 00                	mov    (%eax),%eax
80104181:	85 c0                	test   %eax,%eax
80104183:	0f 84 cb 00 00 00    	je     80104254 <pipealloc+0x104>
80104189:	e8 9c ce ff ff       	call   8010102a <filealloc>
8010418e:	89 c2                	mov    %eax,%edx
80104190:	8b 45 0c             	mov    0xc(%ebp),%eax
80104193:	89 10                	mov    %edx,(%eax)
80104195:	8b 45 0c             	mov    0xc(%ebp),%eax
80104198:	8b 00                	mov    (%eax),%eax
8010419a:	85 c0                	test   %eax,%eax
8010419c:	0f 84 b2 00 00 00    	je     80104254 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801041a2:	e8 ce eb ff ff       	call   80102d75 <kalloc>
801041a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801041aa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801041ae:	0f 84 9f 00 00 00    	je     80104253 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
801041b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b7:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801041be:	00 00 00 
  p->writeopen = 1;
801041c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041c4:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801041cb:	00 00 00 
  p->nwrite = 0;
801041ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041d1:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801041d8:	00 00 00 
  p->nread = 0;
801041db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041de:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801041e5:	00 00 00 
  initlock(&p->lock, "pipe");
801041e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041eb:	83 ec 08             	sub    $0x8,%esp
801041ee:	68 a8 97 10 80       	push   $0x801097a8
801041f3:	50                   	push   %eax
801041f4:	e8 1e 19 00 00       	call   80105b17 <initlock>
801041f9:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801041fc:	8b 45 08             	mov    0x8(%ebp),%eax
801041ff:	8b 00                	mov    (%eax),%eax
80104201:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104207:	8b 45 08             	mov    0x8(%ebp),%eax
8010420a:	8b 00                	mov    (%eax),%eax
8010420c:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104210:	8b 45 08             	mov    0x8(%ebp),%eax
80104213:	8b 00                	mov    (%eax),%eax
80104215:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104219:	8b 45 08             	mov    0x8(%ebp),%eax
8010421c:	8b 00                	mov    (%eax),%eax
8010421e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104221:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104224:	8b 45 0c             	mov    0xc(%ebp),%eax
80104227:	8b 00                	mov    (%eax),%eax
80104229:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010422f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104232:	8b 00                	mov    (%eax),%eax
80104234:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104238:	8b 45 0c             	mov    0xc(%ebp),%eax
8010423b:	8b 00                	mov    (%eax),%eax
8010423d:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104241:	8b 45 0c             	mov    0xc(%ebp),%eax
80104244:	8b 00                	mov    (%eax),%eax
80104246:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104249:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
8010424c:	b8 00 00 00 00       	mov    $0x0,%eax
80104251:	eb 4e                	jmp    801042a1 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80104253:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80104254:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104258:	74 0e                	je     80104268 <pipealloc+0x118>
    kfree((char*)p);
8010425a:	83 ec 0c             	sub    $0xc,%esp
8010425d:	ff 75 f4             	pushl  -0xc(%ebp)
80104260:	e8 73 ea ff ff       	call   80102cd8 <kfree>
80104265:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80104268:	8b 45 08             	mov    0x8(%ebp),%eax
8010426b:	8b 00                	mov    (%eax),%eax
8010426d:	85 c0                	test   %eax,%eax
8010426f:	74 11                	je     80104282 <pipealloc+0x132>
    fileclose(*f0);
80104271:	8b 45 08             	mov    0x8(%ebp),%eax
80104274:	8b 00                	mov    (%eax),%eax
80104276:	83 ec 0c             	sub    $0xc,%esp
80104279:	50                   	push   %eax
8010427a:	e8 69 ce ff ff       	call   801010e8 <fileclose>
8010427f:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104282:	8b 45 0c             	mov    0xc(%ebp),%eax
80104285:	8b 00                	mov    (%eax),%eax
80104287:	85 c0                	test   %eax,%eax
80104289:	74 11                	je     8010429c <pipealloc+0x14c>
    fileclose(*f1);
8010428b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010428e:	8b 00                	mov    (%eax),%eax
80104290:	83 ec 0c             	sub    $0xc,%esp
80104293:	50                   	push   %eax
80104294:	e8 4f ce ff ff       	call   801010e8 <fileclose>
80104299:	83 c4 10             	add    $0x10,%esp
  return -1;
8010429c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801042a1:	c9                   	leave  
801042a2:	c3                   	ret    

801042a3 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801042a3:	55                   	push   %ebp
801042a4:	89 e5                	mov    %esp,%ebp
801042a6:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801042a9:	8b 45 08             	mov    0x8(%ebp),%eax
801042ac:	83 ec 0c             	sub    $0xc,%esp
801042af:	50                   	push   %eax
801042b0:	e8 84 18 00 00       	call   80105b39 <acquire>
801042b5:	83 c4 10             	add    $0x10,%esp
  if(writable){
801042b8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801042bc:	74 23                	je     801042e1 <pipeclose+0x3e>
    p->writeopen = 0;
801042be:	8b 45 08             	mov    0x8(%ebp),%eax
801042c1:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801042c8:	00 00 00 
    wakeup(&p->nread);
801042cb:	8b 45 08             	mov    0x8(%ebp),%eax
801042ce:	05 34 02 00 00       	add    $0x234,%eax
801042d3:	83 ec 0c             	sub    $0xc,%esp
801042d6:	50                   	push   %eax
801042d7:	e8 4d 0d 00 00       	call   80105029 <wakeup>
801042dc:	83 c4 10             	add    $0x10,%esp
801042df:	eb 21                	jmp    80104302 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801042e1:	8b 45 08             	mov    0x8(%ebp),%eax
801042e4:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801042eb:	00 00 00 
    wakeup(&p->nwrite);
801042ee:	8b 45 08             	mov    0x8(%ebp),%eax
801042f1:	05 38 02 00 00       	add    $0x238,%eax
801042f6:	83 ec 0c             	sub    $0xc,%esp
801042f9:	50                   	push   %eax
801042fa:	e8 2a 0d 00 00       	call   80105029 <wakeup>
801042ff:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104302:	8b 45 08             	mov    0x8(%ebp),%eax
80104305:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010430b:	85 c0                	test   %eax,%eax
8010430d:	75 2c                	jne    8010433b <pipeclose+0x98>
8010430f:	8b 45 08             	mov    0x8(%ebp),%eax
80104312:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104318:	85 c0                	test   %eax,%eax
8010431a:	75 1f                	jne    8010433b <pipeclose+0x98>
    release(&p->lock);
8010431c:	8b 45 08             	mov    0x8(%ebp),%eax
8010431f:	83 ec 0c             	sub    $0xc,%esp
80104322:	50                   	push   %eax
80104323:	e8 78 18 00 00       	call   80105ba0 <release>
80104328:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
8010432b:	83 ec 0c             	sub    $0xc,%esp
8010432e:	ff 75 08             	pushl  0x8(%ebp)
80104331:	e8 a2 e9 ff ff       	call   80102cd8 <kfree>
80104336:	83 c4 10             	add    $0x10,%esp
80104339:	eb 0f                	jmp    8010434a <pipeclose+0xa7>
  } else
    release(&p->lock);
8010433b:	8b 45 08             	mov    0x8(%ebp),%eax
8010433e:	83 ec 0c             	sub    $0xc,%esp
80104341:	50                   	push   %eax
80104342:	e8 59 18 00 00       	call   80105ba0 <release>
80104347:	83 c4 10             	add    $0x10,%esp
}
8010434a:	90                   	nop
8010434b:	c9                   	leave  
8010434c:	c3                   	ret    

8010434d <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010434d:	55                   	push   %ebp
8010434e:	89 e5                	mov    %esp,%ebp
80104350:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104353:	8b 45 08             	mov    0x8(%ebp),%eax
80104356:	83 ec 0c             	sub    $0xc,%esp
80104359:	50                   	push   %eax
8010435a:	e8 da 17 00 00       	call   80105b39 <acquire>
8010435f:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104362:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104369:	e9 ad 00 00 00       	jmp    8010441b <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
8010436e:	8b 45 08             	mov    0x8(%ebp),%eax
80104371:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104377:	85 c0                	test   %eax,%eax
80104379:	74 0d                	je     80104388 <pipewrite+0x3b>
8010437b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104381:	8b 40 24             	mov    0x24(%eax),%eax
80104384:	85 c0                	test   %eax,%eax
80104386:	74 19                	je     801043a1 <pipewrite+0x54>
        release(&p->lock);
80104388:	8b 45 08             	mov    0x8(%ebp),%eax
8010438b:	83 ec 0c             	sub    $0xc,%esp
8010438e:	50                   	push   %eax
8010438f:	e8 0c 18 00 00       	call   80105ba0 <release>
80104394:	83 c4 10             	add    $0x10,%esp
        return -1;
80104397:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010439c:	e9 a8 00 00 00       	jmp    80104449 <pipewrite+0xfc>
      }
      wakeup(&p->nread);
801043a1:	8b 45 08             	mov    0x8(%ebp),%eax
801043a4:	05 34 02 00 00       	add    $0x234,%eax
801043a9:	83 ec 0c             	sub    $0xc,%esp
801043ac:	50                   	push   %eax
801043ad:	e8 77 0c 00 00       	call   80105029 <wakeup>
801043b2:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801043b5:	8b 45 08             	mov    0x8(%ebp),%eax
801043b8:	8b 55 08             	mov    0x8(%ebp),%edx
801043bb:	81 c2 38 02 00 00    	add    $0x238,%edx
801043c1:	83 ec 08             	sub    $0x8,%esp
801043c4:	50                   	push   %eax
801043c5:	52                   	push   %edx
801043c6:	e8 77 0b 00 00       	call   80104f42 <sleep>
801043cb:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801043ce:	8b 45 08             	mov    0x8(%ebp),%eax
801043d1:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801043d7:	8b 45 08             	mov    0x8(%ebp),%eax
801043da:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801043e0:	05 00 02 00 00       	add    $0x200,%eax
801043e5:	39 c2                	cmp    %eax,%edx
801043e7:	74 85                	je     8010436e <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801043e9:	8b 45 08             	mov    0x8(%ebp),%eax
801043ec:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043f2:	8d 48 01             	lea    0x1(%eax),%ecx
801043f5:	8b 55 08             	mov    0x8(%ebp),%edx
801043f8:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801043fe:	25 ff 01 00 00       	and    $0x1ff,%eax
80104403:	89 c1                	mov    %eax,%ecx
80104405:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104408:	8b 45 0c             	mov    0xc(%ebp),%eax
8010440b:	01 d0                	add    %edx,%eax
8010440d:	0f b6 10             	movzbl (%eax),%edx
80104410:	8b 45 08             	mov    0x8(%ebp),%eax
80104413:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104417:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010441b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010441e:	3b 45 10             	cmp    0x10(%ebp),%eax
80104421:	7c ab                	jl     801043ce <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104423:	8b 45 08             	mov    0x8(%ebp),%eax
80104426:	05 34 02 00 00       	add    $0x234,%eax
8010442b:	83 ec 0c             	sub    $0xc,%esp
8010442e:	50                   	push   %eax
8010442f:	e8 f5 0b 00 00       	call   80105029 <wakeup>
80104434:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104437:	8b 45 08             	mov    0x8(%ebp),%eax
8010443a:	83 ec 0c             	sub    $0xc,%esp
8010443d:	50                   	push   %eax
8010443e:	e8 5d 17 00 00       	call   80105ba0 <release>
80104443:	83 c4 10             	add    $0x10,%esp
  return n;
80104446:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104449:	c9                   	leave  
8010444a:	c3                   	ret    

8010444b <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010444b:	55                   	push   %ebp
8010444c:	89 e5                	mov    %esp,%ebp
8010444e:	53                   	push   %ebx
8010444f:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104452:	8b 45 08             	mov    0x8(%ebp),%eax
80104455:	83 ec 0c             	sub    $0xc,%esp
80104458:	50                   	push   %eax
80104459:	e8 db 16 00 00       	call   80105b39 <acquire>
8010445e:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104461:	eb 3f                	jmp    801044a2 <piperead+0x57>
    if(proc->killed){
80104463:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104469:	8b 40 24             	mov    0x24(%eax),%eax
8010446c:	85 c0                	test   %eax,%eax
8010446e:	74 19                	je     80104489 <piperead+0x3e>
      release(&p->lock);
80104470:	8b 45 08             	mov    0x8(%ebp),%eax
80104473:	83 ec 0c             	sub    $0xc,%esp
80104476:	50                   	push   %eax
80104477:	e8 24 17 00 00       	call   80105ba0 <release>
8010447c:	83 c4 10             	add    $0x10,%esp
      return -1;
8010447f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104484:	e9 bf 00 00 00       	jmp    80104548 <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104489:	8b 45 08             	mov    0x8(%ebp),%eax
8010448c:	8b 55 08             	mov    0x8(%ebp),%edx
8010448f:	81 c2 34 02 00 00    	add    $0x234,%edx
80104495:	83 ec 08             	sub    $0x8,%esp
80104498:	50                   	push   %eax
80104499:	52                   	push   %edx
8010449a:	e8 a3 0a 00 00       	call   80104f42 <sleep>
8010449f:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801044a2:	8b 45 08             	mov    0x8(%ebp),%eax
801044a5:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801044ab:	8b 45 08             	mov    0x8(%ebp),%eax
801044ae:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801044b4:	39 c2                	cmp    %eax,%edx
801044b6:	75 0d                	jne    801044c5 <piperead+0x7a>
801044b8:	8b 45 08             	mov    0x8(%ebp),%eax
801044bb:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801044c1:	85 c0                	test   %eax,%eax
801044c3:	75 9e                	jne    80104463 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801044c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801044cc:	eb 49                	jmp    80104517 <piperead+0xcc>
    if(p->nread == p->nwrite)
801044ce:	8b 45 08             	mov    0x8(%ebp),%eax
801044d1:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801044d7:	8b 45 08             	mov    0x8(%ebp),%eax
801044da:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801044e0:	39 c2                	cmp    %eax,%edx
801044e2:	74 3d                	je     80104521 <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801044e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801044ea:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801044ed:	8b 45 08             	mov    0x8(%ebp),%eax
801044f0:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801044f6:	8d 48 01             	lea    0x1(%eax),%ecx
801044f9:	8b 55 08             	mov    0x8(%ebp),%edx
801044fc:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104502:	25 ff 01 00 00       	and    $0x1ff,%eax
80104507:	89 c2                	mov    %eax,%edx
80104509:	8b 45 08             	mov    0x8(%ebp),%eax
8010450c:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104511:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104513:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104517:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010451d:	7c af                	jl     801044ce <piperead+0x83>
8010451f:	eb 01                	jmp    80104522 <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
80104521:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104522:	8b 45 08             	mov    0x8(%ebp),%eax
80104525:	05 38 02 00 00       	add    $0x238,%eax
8010452a:	83 ec 0c             	sub    $0xc,%esp
8010452d:	50                   	push   %eax
8010452e:	e8 f6 0a 00 00       	call   80105029 <wakeup>
80104533:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104536:	8b 45 08             	mov    0x8(%ebp),%eax
80104539:	83 ec 0c             	sub    $0xc,%esp
8010453c:	50                   	push   %eax
8010453d:	e8 5e 16 00 00       	call   80105ba0 <release>
80104542:	83 c4 10             	add    $0x10,%esp
  return i;
80104545:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104548:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010454b:	c9                   	leave  
8010454c:	c3                   	ret    

8010454d <hlt>:
}

// hlt() added by Noah Zentzis, Fall 2016.
static inline void
hlt()
{
8010454d:	55                   	push   %ebp
8010454e:	89 e5                	mov    %esp,%ebp
  asm volatile("hlt");
80104550:	f4                   	hlt    
}
80104551:	90                   	nop
80104552:	5d                   	pop    %ebp
80104553:	c3                   	ret    

80104554 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104554:	55                   	push   %ebp
80104555:	89 e5                	mov    %esp,%ebp
80104557:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010455a:	9c                   	pushf  
8010455b:	58                   	pop    %eax
8010455c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010455f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104562:	c9                   	leave  
80104563:	c3                   	ret    

80104564 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104564:	55                   	push   %ebp
80104565:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104567:	fb                   	sti    
}
80104568:	90                   	nop
80104569:	5d                   	pop    %ebp
8010456a:	c3                   	ret    

8010456b <pinit>:
static void promoteAll(void);
#endif

void
pinit(void)
{
8010456b:	55                   	push   %ebp
8010456c:	89 e5                	mov    %esp,%ebp
8010456e:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104571:	83 ec 08             	sub    $0x8,%esp
80104574:	68 b0 97 10 80       	push   $0x801097b0
80104579:	68 a0 39 11 80       	push   $0x801139a0
8010457e:	e8 94 15 00 00       	call   80105b17 <initlock>
80104583:	83 c4 10             	add    $0x10,%esp
}
80104586:	90                   	nop
80104587:	c9                   	leave  
80104588:	c3                   	ret    

80104589 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104589:	55                   	push   %ebp
8010458a:	89 e5                	mov    %esp,%ebp
8010458c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
8010458f:	83 ec 0c             	sub    $0xc,%esp
80104592:	68 a0 39 11 80       	push   $0x801139a0
80104597:	e8 9d 15 00 00       	call   80105b39 <acquire>
8010459c:	83 c4 10             	add    $0x10,%esp
#ifndef CS333_P3P4
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010459f:	c7 45 f4 d4 39 11 80 	movl   $0x801139d4,-0xc(%ebp)
801045a6:	eb 11                	jmp    801045b9 <allocproc+0x30>
    if(p->state == UNUSED)
801045a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ab:	8b 40 0c             	mov    0xc(%eax),%eax
801045ae:	85 c0                	test   %eax,%eax
801045b0:	74 2a                	je     801045dc <allocproc+0x53>
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
#ifndef CS333_P3P4
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801045b2:	81 45 f4 9c 00 00 00 	addl   $0x9c,-0xc(%ebp)
801045b9:	81 7d f4 d4 60 11 80 	cmpl   $0x801160d4,-0xc(%ebp)
801045c0:	72 e6                	jb     801045a8 <allocproc+0x1f>
#else
  p = ptable.pLists.free;
  if(p)
    goto found;
#endif
  release(&ptable.lock);
801045c2:	83 ec 0c             	sub    $0xc,%esp
801045c5:	68 a0 39 11 80       	push   $0x801139a0
801045ca:	e8 d1 15 00 00       	call   80105ba0 <release>
801045cf:	83 c4 10             	add    $0x10,%esp
  return 0;
801045d2:	b8 00 00 00 00       	mov    $0x0,%eax
801045d7:	e9 10 01 00 00       	jmp    801046ec <allocproc+0x163>

  acquire(&ptable.lock);
#ifndef CS333_P3P4
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
801045dc:	90                   	nop
#endif
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801045dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e0:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
    panic("error removing from free list.");
  if(stateListAdd(&ptable.pLists.embryo, &ptable.pLists.embryoTail,p))
    panic("error adding to embryo list.");
  assertState(p, EMBRYO);
#endif
  p->pid = nextpid++;
801045e7:	a1 04 c0 10 80       	mov    0x8010c004,%eax
801045ec:	8d 50 01             	lea    0x1(%eax),%edx
801045ef:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
801045f5:	89 c2                	mov    %eax,%edx
801045f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045fa:	89 50 10             	mov    %edx,0x10(%eax)
  p->start_ticks = ticks;
801045fd:	8b 15 40 69 11 80    	mov    0x80116940,%edx
80104603:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104606:	89 50 7c             	mov    %edx,0x7c(%eax)
  p->uid = 0;
80104609:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010460c:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80104613:	00 00 00 
  p->gid = 0;
80104616:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104619:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
80104620:	00 00 00 
  p->cpu_ticks_in = 0;
80104623:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104626:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
8010462d:	00 00 00 
  p->cpu_ticks_total = 0;
80104630:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104633:	c7 80 88 00 00 00 00 	movl   $0x0,0x88(%eax)
8010463a:	00 00 00 
  p->priority = 0;
8010463d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104640:	c7 80 98 00 00 00 00 	movl   $0x0,0x98(%eax)
80104647:	00 00 00 
  p->budget = BUDGET;
8010464a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010464d:	c7 80 94 00 00 00 64 	movl   $0x64,0x94(%eax)
80104654:	00 00 00 
  release(&ptable.lock);
80104657:	83 ec 0c             	sub    $0xc,%esp
8010465a:	68 a0 39 11 80       	push   $0x801139a0
8010465f:	e8 3c 15 00 00       	call   80105ba0 <release>
80104664:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104667:	e8 09 e7 ff ff       	call   80102d75 <kalloc>
8010466c:	89 c2                	mov    %eax,%edx
8010466e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104671:	89 50 08             	mov    %edx,0x8(%eax)
80104674:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104677:	8b 40 08             	mov    0x8(%eax),%eax
8010467a:	85 c0                	test   %eax,%eax
8010467c:	75 11                	jne    8010468f <allocproc+0x106>
    p->state = UNUSED;
8010467e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104681:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
      panic("error removing from embryo list.");
    if(stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail,p))
      panic("error adding to free list.");
    assertState(p, UNUSED);
#endif
    return 0;
80104688:	b8 00 00 00 00       	mov    $0x0,%eax
8010468d:	eb 5d                	jmp    801046ec <allocproc+0x163>
  }
  sp = p->kstack + KSTACKSIZE;
8010468f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104692:	8b 40 08             	mov    0x8(%eax),%eax
80104695:	05 00 10 00 00       	add    $0x1000,%eax
8010469a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010469d:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801046a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801046a7:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801046aa:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801046ae:	ba 80 75 10 80       	mov    $0x80107580,%edx
801046b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046b6:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801046b8:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801046bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046bf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801046c2:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801046c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c8:	8b 40 1c             	mov    0x1c(%eax),%eax
801046cb:	83 ec 04             	sub    $0x4,%esp
801046ce:	6a 14                	push   $0x14
801046d0:	6a 00                	push   $0x0
801046d2:	50                   	push   %eax
801046d3:	e8 c4 16 00 00       	call   80105d9c <memset>
801046d8:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801046db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046de:	8b 40 1c             	mov    0x1c(%eax),%eax
801046e1:	ba fc 4e 10 80       	mov    $0x80104efc,%edx
801046e6:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801046e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801046ec:	c9                   	leave  
801046ed:	c3                   	ret    

801046ee <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801046ee:	55                   	push   %ebp
801046ef:	89 e5                	mov    %esp,%ebp
801046f1:	83 ec 18             	sub    $0x18,%esp
  initProcessLists();
  initFreeList();
  ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
  release(&ptable.lock);
#endif
  p = allocproc();
801046f4:	e8 90 fe ff ff       	call   80104589 <allocproc>
801046f9:	89 45 f4             	mov    %eax,-0xc(%ebp)

  initproc = p;
801046fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ff:	a3 88 c6 10 80       	mov    %eax,0x8010c688
  if((p->pgdir = setupkvm()) == 0)
80104704:	e8 39 45 00 00       	call   80108c42 <setupkvm>
80104709:	89 c2                	mov    %eax,%edx
8010470b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010470e:	89 50 04             	mov    %edx,0x4(%eax)
80104711:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104714:	8b 40 04             	mov    0x4(%eax),%eax
80104717:	85 c0                	test   %eax,%eax
80104719:	75 0d                	jne    80104728 <userinit+0x3a>
    panic("userinit: out of memory?");
8010471b:	83 ec 0c             	sub    $0xc,%esp
8010471e:	68 b7 97 10 80       	push   $0x801097b7
80104723:	e8 3e be ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104728:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010472d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104730:	8b 40 04             	mov    0x4(%eax),%eax
80104733:	83 ec 04             	sub    $0x4,%esp
80104736:	52                   	push   %edx
80104737:	68 20 c5 10 80       	push   $0x8010c520
8010473c:	50                   	push   %eax
8010473d:	e8 5a 47 00 00       	call   80108e9c <inituvm>
80104742:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104745:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104748:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010474e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104751:	8b 40 18             	mov    0x18(%eax),%eax
80104754:	83 ec 04             	sub    $0x4,%esp
80104757:	6a 4c                	push   $0x4c
80104759:	6a 00                	push   $0x0
8010475b:	50                   	push   %eax
8010475c:	e8 3b 16 00 00       	call   80105d9c <memset>
80104761:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104764:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104767:	8b 40 18             	mov    0x18(%eax),%eax
8010476a:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104770:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104773:	8b 40 18             	mov    0x18(%eax),%eax
80104776:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010477c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010477f:	8b 40 18             	mov    0x18(%eax),%eax
80104782:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104785:	8b 52 18             	mov    0x18(%edx),%edx
80104788:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010478c:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104790:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104793:	8b 40 18             	mov    0x18(%eax),%eax
80104796:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104799:	8b 52 18             	mov    0x18(%edx),%edx
8010479c:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801047a0:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801047a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047a7:	8b 40 18             	mov    0x18(%eax),%eax
801047aa:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801047b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047b4:	8b 40 18             	mov    0x18(%eax),%eax
801047b7:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801047be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047c1:	8b 40 18             	mov    0x18(%eax),%eax
801047c4:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801047cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ce:	83 c0 6c             	add    $0x6c,%eax
801047d1:	83 ec 04             	sub    $0x4,%esp
801047d4:	6a 10                	push   $0x10
801047d6:	68 d0 97 10 80       	push   $0x801097d0
801047db:	50                   	push   %eax
801047dc:	e8 be 17 00 00       	call   80105f9f <safestrcpy>
801047e1:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801047e4:	83 ec 0c             	sub    $0xc,%esp
801047e7:	68 d9 97 10 80       	push   $0x801097d9
801047ec:	e8 46 de ff ff       	call   80102637 <namei>
801047f1:	83 c4 10             	add    $0x10,%esp
801047f4:	89 c2                	mov    %eax,%edx
801047f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047f9:	89 50 68             	mov    %edx,0x68(%eax)

  p->state = RUNNABLE;
801047fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ff:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  if(stateListAdd(&ptable.pLists.ready[p->priority], &ptable.pLists.readyTail[p->priority], p))
    panic("error adding to ready list.");
  assertState(p, RUNNABLE);
  release(&ptable.lock);
#endif
  p->uid = 0;
80104806:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104809:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80104810:	00 00 00 
  p->gid = 0;
80104813:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104816:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
8010481d:	00 00 00 
}
80104820:	90                   	nop
80104821:	c9                   	leave  
80104822:	c3                   	ret    

80104823 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104823:	55                   	push   %ebp
80104824:	89 e5                	mov    %esp,%ebp
80104826:	83 ec 18             	sub    $0x18,%esp
  uint sz;

  sz = proc->sz;
80104829:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010482f:	8b 00                	mov    (%eax),%eax
80104831:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104834:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104838:	7e 31                	jle    8010486b <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
8010483a:	8b 55 08             	mov    0x8(%ebp),%edx
8010483d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104840:	01 c2                	add    %eax,%edx
80104842:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104848:	8b 40 04             	mov    0x4(%eax),%eax
8010484b:	83 ec 04             	sub    $0x4,%esp
8010484e:	52                   	push   %edx
8010484f:	ff 75 f4             	pushl  -0xc(%ebp)
80104852:	50                   	push   %eax
80104853:	e8 91 47 00 00       	call   80108fe9 <allocuvm>
80104858:	83 c4 10             	add    $0x10,%esp
8010485b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010485e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104862:	75 3e                	jne    801048a2 <growproc+0x7f>
      return -1;
80104864:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104869:	eb 59                	jmp    801048c4 <growproc+0xa1>
  } else if(n < 0){
8010486b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010486f:	79 31                	jns    801048a2 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104871:	8b 55 08             	mov    0x8(%ebp),%edx
80104874:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104877:	01 c2                	add    %eax,%edx
80104879:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010487f:	8b 40 04             	mov    0x4(%eax),%eax
80104882:	83 ec 04             	sub    $0x4,%esp
80104885:	52                   	push   %edx
80104886:	ff 75 f4             	pushl  -0xc(%ebp)
80104889:	50                   	push   %eax
8010488a:	e8 23 48 00 00       	call   801090b2 <deallocuvm>
8010488f:	83 c4 10             	add    $0x10,%esp
80104892:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104895:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104899:	75 07                	jne    801048a2 <growproc+0x7f>
      return -1;
8010489b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048a0:	eb 22                	jmp    801048c4 <growproc+0xa1>
  }
  proc->sz = sz;
801048a2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801048ab:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
801048ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048b3:	83 ec 0c             	sub    $0xc,%esp
801048b6:	50                   	push   %eax
801048b7:	e8 6d 44 00 00       	call   80108d29 <switchuvm>
801048bc:	83 c4 10             	add    $0x10,%esp
  return 0;
801048bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
801048c4:	c9                   	leave  
801048c5:	c3                   	ret    

801048c6 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801048c6:	55                   	push   %ebp
801048c7:	89 e5                	mov    %esp,%ebp
801048c9:	57                   	push   %edi
801048ca:	56                   	push   %esi
801048cb:	53                   	push   %ebx
801048cc:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
801048cf:	e8 b5 fc ff ff       	call   80104589 <allocproc>
801048d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
801048d7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801048db:	75 0a                	jne    801048e7 <fork+0x21>
    return -1;
801048dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048e2:	e9 92 01 00 00       	jmp    80104a79 <fork+0x1b3>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
801048e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048ed:	8b 10                	mov    (%eax),%edx
801048ef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048f5:	8b 40 04             	mov    0x4(%eax),%eax
801048f8:	83 ec 08             	sub    $0x8,%esp
801048fb:	52                   	push   %edx
801048fc:	50                   	push   %eax
801048fd:	e8 4e 49 00 00       	call   80109250 <copyuvm>
80104902:	83 c4 10             	add    $0x10,%esp
80104905:	89 c2                	mov    %eax,%edx
80104907:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010490a:	89 50 04             	mov    %edx,0x4(%eax)
8010490d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104910:	8b 40 04             	mov    0x4(%eax),%eax
80104913:	85 c0                	test   %eax,%eax
80104915:	75 30                	jne    80104947 <fork+0x81>
    kfree(np->kstack);
80104917:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010491a:	8b 40 08             	mov    0x8(%eax),%eax
8010491d:	83 ec 0c             	sub    $0xc,%esp
80104920:	50                   	push   %eax
80104921:	e8 b2 e3 ff ff       	call   80102cd8 <kfree>
80104926:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104929:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010492c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104933:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104936:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    if(stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail, np))
      panic("error adding to freelist.");
    assertState(np, UNUSED);
    release(&ptable.lock);
#endif
    return -1;
8010493d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104942:	e9 32 01 00 00       	jmp    80104a79 <fork+0x1b3>
  }
  np->sz = proc->sz;
80104947:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010494d:	8b 10                	mov    (%eax),%edx
8010494f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104952:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104954:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010495b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010495e:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104961:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104964:	8b 50 18             	mov    0x18(%eax),%edx
80104967:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010496d:	8b 40 18             	mov    0x18(%eax),%eax
80104970:	89 c3                	mov    %eax,%ebx
80104972:	b8 13 00 00 00       	mov    $0x13,%eax
80104977:	89 d7                	mov    %edx,%edi
80104979:	89 de                	mov    %ebx,%esi
8010497b:	89 c1                	mov    %eax,%ecx
8010497d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010497f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104982:	8b 40 18             	mov    0x18(%eax),%eax
80104985:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010498c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104993:	eb 43                	jmp    801049d8 <fork+0x112>
    if(proc->ofile[i])
80104995:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010499b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010499e:	83 c2 08             	add    $0x8,%edx
801049a1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801049a5:	85 c0                	test   %eax,%eax
801049a7:	74 2b                	je     801049d4 <fork+0x10e>
      np->ofile[i] = filedup(proc->ofile[i]);
801049a9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049af:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801049b2:	83 c2 08             	add    $0x8,%edx
801049b5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801049b9:	83 ec 0c             	sub    $0xc,%esp
801049bc:	50                   	push   %eax
801049bd:	e8 d5 c6 ff ff       	call   80101097 <filedup>
801049c2:	83 c4 10             	add    $0x10,%esp
801049c5:	89 c1                	mov    %eax,%ecx
801049c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801049cd:	83 c2 08             	add    $0x8,%edx
801049d0:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801049d4:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801049d8:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801049dc:	7e b7                	jle    80104995 <fork+0xcf>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
801049de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049e4:	8b 40 68             	mov    0x68(%eax),%eax
801049e7:	83 ec 0c             	sub    $0xc,%esp
801049ea:	50                   	push   %eax
801049eb:	e8 ff cf ff ff       	call   801019ef <idup>
801049f0:	83 c4 10             	add    $0x10,%esp
801049f3:	89 c2                	mov    %eax,%edx
801049f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049f8:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
801049fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a01:	8d 50 6c             	lea    0x6c(%eax),%edx
80104a04:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a07:	83 c0 6c             	add    $0x6c,%eax
80104a0a:	83 ec 04             	sub    $0x4,%esp
80104a0d:	6a 10                	push   $0x10
80104a0f:	52                   	push   %edx
80104a10:	50                   	push   %eax
80104a11:	e8 89 15 00 00       	call   80105f9f <safestrcpy>
80104a16:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104a19:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a1c:	8b 40 10             	mov    0x10(%eax),%eax
80104a1f:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104a22:	83 ec 0c             	sub    $0xc,%esp
80104a25:	68 a0 39 11 80       	push   $0x801139a0
80104a2a:	e8 0a 11 00 00       	call   80105b39 <acquire>
80104a2f:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
80104a32:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a35:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
    panic("error removing from embryo.");
  if(stateListAdd(&ptable.pLists.ready[np->priority], &ptable.pLists.readyTail[np->priority], np))
    panic("error adding to ready list.");
  assertState(np, RUNNABLE);
#endif
  release(&ptable.lock);
80104a3c:	83 ec 0c             	sub    $0xc,%esp
80104a3f:	68 a0 39 11 80       	push   $0x801139a0
80104a44:	e8 57 11 00 00       	call   80105ba0 <release>
80104a49:	83 c4 10             	add    $0x10,%esp

  np->uid = proc->uid;
80104a4c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a52:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104a58:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a5b:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  np->gid = proc->gid;
80104a61:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a67:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80104a6d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a70:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)

  return pid;
80104a76:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104a79:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104a7c:	5b                   	pop    %ebx
80104a7d:	5e                   	pop    %esi
80104a7e:	5f                   	pop    %edi
80104a7f:	5d                   	pop    %ebp
80104a80:	c3                   	ret    

80104a81 <exit>:
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
#ifndef CS333_P3P4
void
exit(void)
{
80104a81:	55                   	push   %ebp
80104a82:	89 e5                	mov    %esp,%ebp
80104a84:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104a87:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104a8e:	a1 88 c6 10 80       	mov    0x8010c688,%eax
80104a93:	39 c2                	cmp    %eax,%edx
80104a95:	75 0d                	jne    80104aa4 <exit+0x23>
    panic("init exiting");
80104a97:	83 ec 0c             	sub    $0xc,%esp
80104a9a:	68 db 97 10 80       	push   $0x801097db
80104a9f:	e8 c2 ba ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104aa4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104aab:	eb 48                	jmp    80104af5 <exit+0x74>
    if(proc->ofile[fd]){
80104aad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ab3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ab6:	83 c2 08             	add    $0x8,%edx
80104ab9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104abd:	85 c0                	test   %eax,%eax
80104abf:	74 30                	je     80104af1 <exit+0x70>
      fileclose(proc->ofile[fd]);
80104ac1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ac7:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104aca:	83 c2 08             	add    $0x8,%edx
80104acd:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104ad1:	83 ec 0c             	sub    $0xc,%esp
80104ad4:	50                   	push   %eax
80104ad5:	e8 0e c6 ff ff       	call   801010e8 <fileclose>
80104ada:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80104add:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ae3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ae6:	83 c2 08             	add    $0x8,%edx
80104ae9:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104af0:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104af1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104af5:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104af9:	7e b2                	jle    80104aad <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104afb:	e8 5c eb ff ff       	call   8010365c <begin_op>
  iput(proc->cwd);
80104b00:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b06:	8b 40 68             	mov    0x68(%eax),%eax
80104b09:	83 ec 0c             	sub    $0xc,%esp
80104b0c:	50                   	push   %eax
80104b0d:	e8 0f d1 ff ff       	call   80101c21 <iput>
80104b12:	83 c4 10             	add    $0x10,%esp
  end_op();
80104b15:	e8 ce eb ff ff       	call   801036e8 <end_op>
  proc->cwd = 0;
80104b1a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b20:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104b27:	83 ec 0c             	sub    $0xc,%esp
80104b2a:	68 a0 39 11 80       	push   $0x801139a0
80104b2f:	e8 05 10 00 00       	call   80105b39 <acquire>
80104b34:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104b37:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b3d:	8b 40 14             	mov    0x14(%eax),%eax
80104b40:	83 ec 0c             	sub    $0xc,%esp
80104b43:	50                   	push   %eax
80104b44:	e8 9e 04 00 00       	call   80104fe7 <wakeup1>
80104b49:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b4c:	c7 45 f4 d4 39 11 80 	movl   $0x801139d4,-0xc(%ebp)
80104b53:	eb 3f                	jmp    80104b94 <exit+0x113>
    if(p->parent == proc){
80104b55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b58:	8b 50 14             	mov    0x14(%eax),%edx
80104b5b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b61:	39 c2                	cmp    %eax,%edx
80104b63:	75 28                	jne    80104b8d <exit+0x10c>
      p->parent = initproc;
80104b65:	8b 15 88 c6 10 80    	mov    0x8010c688,%edx
80104b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b6e:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b74:	8b 40 0c             	mov    0xc(%eax),%eax
80104b77:	83 f8 05             	cmp    $0x5,%eax
80104b7a:	75 11                	jne    80104b8d <exit+0x10c>
        wakeup1(initproc);
80104b7c:	a1 88 c6 10 80       	mov    0x8010c688,%eax
80104b81:	83 ec 0c             	sub    $0xc,%esp
80104b84:	50                   	push   %eax
80104b85:	e8 5d 04 00 00       	call   80104fe7 <wakeup1>
80104b8a:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b8d:	81 45 f4 9c 00 00 00 	addl   $0x9c,-0xc(%ebp)
80104b94:	81 7d f4 d4 60 11 80 	cmpl   $0x801160d4,-0xc(%ebp)
80104b9b:	72 b8                	jb     80104b55 <exit+0xd4>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104b9d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ba3:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104baa:	e8 56 02 00 00       	call   80104e05 <sched>
  panic("zombie exit");
80104baf:	83 ec 0c             	sub    $0xc,%esp
80104bb2:	68 e8 97 10 80       	push   $0x801097e8
80104bb7:	e8 aa b9 ff ff       	call   80100566 <panic>

80104bbc <wait>:
// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
#ifndef CS333_P3P4
int
wait(void)
{
80104bbc:	55                   	push   %ebp
80104bbd:	89 e5                	mov    %esp,%ebp
80104bbf:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104bc2:	83 ec 0c             	sub    $0xc,%esp
80104bc5:	68 a0 39 11 80       	push   $0x801139a0
80104bca:	e8 6a 0f 00 00       	call   80105b39 <acquire>
80104bcf:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104bd2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    p = ptable.pLists.zombie;
80104bd9:	a1 1c 61 11 80       	mov    0x8011611c,%eax
80104bde:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104be1:	c7 45 f4 d4 39 11 80 	movl   $0x801139d4,-0xc(%ebp)
80104be8:	e9 a9 00 00 00       	jmp    80104c96 <wait+0xda>
      if(p->parent != proc)
80104bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf0:	8b 50 14             	mov    0x14(%eax),%edx
80104bf3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bf9:	39 c2                	cmp    %eax,%edx
80104bfb:	0f 85 8d 00 00 00    	jne    80104c8e <wait+0xd2>
        continue;
      havekids = 1;
80104c01:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c0b:	8b 40 0c             	mov    0xc(%eax),%eax
80104c0e:	83 f8 05             	cmp    $0x5,%eax
80104c11:	75 7c                	jne    80104c8f <wait+0xd3>
        // Found one.
        pid = p->pid;
80104c13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c16:	8b 40 10             	mov    0x10(%eax),%eax
80104c19:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c1f:	8b 40 08             	mov    0x8(%eax),%eax
80104c22:	83 ec 0c             	sub    $0xc,%esp
80104c25:	50                   	push   %eax
80104c26:	e8 ad e0 ff ff       	call   80102cd8 <kfree>
80104c2b:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c31:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c3b:	8b 40 04             	mov    0x4(%eax),%eax
80104c3e:	83 ec 0c             	sub    $0xc,%esp
80104c41:	50                   	push   %eax
80104c42:	e8 28 45 00 00       	call   8010916f <freevm>
80104c47:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80104c4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c4d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c57:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c61:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c6b:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c72:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104c79:	83 ec 0c             	sub    $0xc,%esp
80104c7c:	68 a0 39 11 80       	push   $0x801139a0
80104c81:	e8 1a 0f 00 00       	call   80105ba0 <release>
80104c86:	83 c4 10             	add    $0x10,%esp
        return pid;
80104c89:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c8c:	eb 5b                	jmp    80104ce9 <wait+0x12d>
    // Scan through table looking for zombie children.
    havekids = 0;
    p = ptable.pLists.zombie;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104c8e:	90                   	nop
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    p = ptable.pLists.zombie;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c8f:	81 45 f4 9c 00 00 00 	addl   $0x9c,-0xc(%ebp)
80104c96:	81 7d f4 d4 60 11 80 	cmpl   $0x801160d4,-0xc(%ebp)
80104c9d:	0f 82 4a ff ff ff    	jb     80104bed <wait+0x31>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104ca3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104ca7:	74 0d                	je     80104cb6 <wait+0xfa>
80104ca9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104caf:	8b 40 24             	mov    0x24(%eax),%eax
80104cb2:	85 c0                	test   %eax,%eax
80104cb4:	74 17                	je     80104ccd <wait+0x111>
      release(&ptable.lock);
80104cb6:	83 ec 0c             	sub    $0xc,%esp
80104cb9:	68 a0 39 11 80       	push   $0x801139a0
80104cbe:	e8 dd 0e 00 00       	call   80105ba0 <release>
80104cc3:	83 c4 10             	add    $0x10,%esp
      return -1;
80104cc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ccb:	eb 1c                	jmp    80104ce9 <wait+0x12d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104ccd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cd3:	83 ec 08             	sub    $0x8,%esp
80104cd6:	68 a0 39 11 80       	push   $0x801139a0
80104cdb:	50                   	push   %eax
80104cdc:	e8 61 02 00 00       	call   80104f42 <sleep>
80104ce1:	83 c4 10             	add    $0x10,%esp
  }
80104ce4:	e9 e9 fe ff ff       	jmp    80104bd2 <wait+0x16>
}
80104ce9:	c9                   	leave  
80104cea:	c3                   	ret    

80104ceb <scheduler>:
//      via swtch back to the scheduler.
#ifndef CS333_P3P4
// original xv6 scheduler. Use if CS333_P3P4 NOT defined.
void
scheduler(void)
{
80104ceb:	55                   	push   %ebp
80104cec:	89 e5                	mov    %esp,%ebp
80104cee:	53                   	push   %ebx
80104cef:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;
  int idle;  // for checking if processor is idle

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104cf2:	e8 6d f8 ff ff       	call   80104564 <sti>

    idle = 1;  // assume idle unless we schedule a process
80104cf7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104cfe:	83 ec 0c             	sub    $0xc,%esp
80104d01:	68 a0 39 11 80       	push   $0x801139a0
80104d06:	e8 2e 0e 00 00       	call   80105b39 <acquire>
80104d0b:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d0e:	c7 45 f4 d4 39 11 80 	movl   $0x801139d4,-0xc(%ebp)
80104d15:	e9 b5 00 00 00       	jmp    80104dcf <scheduler+0xe4>
      if(p->state != RUNNABLE)
80104d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d1d:	8b 40 0c             	mov    0xc(%eax),%eax
80104d20:	83 f8 03             	cmp    $0x3,%eax
80104d23:	0f 85 9e 00 00 00    	jne    80104dc7 <scheduler+0xdc>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      idle = 0;  // not idle this timeslice
80104d29:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      proc = p;
80104d30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d33:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104d39:	83 ec 0c             	sub    $0xc,%esp
80104d3c:	ff 75 f4             	pushl  -0xc(%ebp)
80104d3f:	e8 e5 3f 00 00       	call   80108d29 <switchuvm>
80104d44:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104d47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d4a:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      proc->cpu_ticks_in = ticks;
80104d51:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d57:	8b 15 40 69 11 80    	mov    0x80116940,%edx
80104d5d:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)

      swtch(&cpu->scheduler, proc->context);
80104d63:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d69:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d6c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104d73:	83 c2 04             	add    $0x4,%edx
80104d76:	83 ec 08             	sub    $0x8,%esp
80104d79:	50                   	push   %eax
80104d7a:	52                   	push   %edx
80104d7b:	e8 90 12 00 00       	call   80106010 <swtch>
80104d80:	83 c4 10             	add    $0x10,%esp

      proc->cpu_ticks_total = proc->cpu_ticks_total + (ticks - proc->cpu_ticks_in);
80104d83:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d89:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104d90:	8b 8a 88 00 00 00    	mov    0x88(%edx),%ecx
80104d96:	8b 1d 40 69 11 80    	mov    0x80116940,%ebx
80104d9c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104da3:	8b 92 8c 00 00 00    	mov    0x8c(%edx),%edx
80104da9:	29 d3                	sub    %edx,%ebx
80104dab:	89 da                	mov    %ebx,%edx
80104dad:	01 ca                	add    %ecx,%edx
80104daf:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
      switchkvm();
80104db5:	e8 52 3f 00 00       	call   80108d0c <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104dba:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104dc1:	00 00 00 00 
80104dc5:	eb 01                	jmp    80104dc8 <scheduler+0xdd>
    idle = 1;  // assume idle unless we schedule a process
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80104dc7:	90                   	nop
    sti();

    idle = 1;  // assume idle unless we schedule a process
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104dc8:	81 45 f4 9c 00 00 00 	addl   $0x9c,-0xc(%ebp)
80104dcf:	81 7d f4 d4 60 11 80 	cmpl   $0x801160d4,-0xc(%ebp)
80104dd6:	0f 82 3e ff ff ff    	jb     80104d1a <scheduler+0x2f>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104ddc:	83 ec 0c             	sub    $0xc,%esp
80104ddf:	68 a0 39 11 80       	push   $0x801139a0
80104de4:	e8 b7 0d 00 00       	call   80105ba0 <release>
80104de9:	83 c4 10             	add    $0x10,%esp
    // if idle, wait for next interrupt
    if (idle) {
80104dec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104df0:	0f 84 fc fe ff ff    	je     80104cf2 <scheduler+0x7>
      sti();
80104df6:	e8 69 f7 ff ff       	call   80104564 <sti>
      hlt();
80104dfb:	e8 4d f7 ff ff       	call   8010454d <hlt>
    }
  }
80104e00:	e9 ed fe ff ff       	jmp    80104cf2 <scheduler+0x7>

80104e05 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104e05:	55                   	push   %ebp
80104e06:	89 e5                	mov    %esp,%ebp
80104e08:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80104e0b:	83 ec 0c             	sub    $0xc,%esp
80104e0e:	68 a0 39 11 80       	push   $0x801139a0
80104e13:	e8 54 0e 00 00       	call   80105c6c <holding>
80104e18:	83 c4 10             	add    $0x10,%esp
80104e1b:	85 c0                	test   %eax,%eax
80104e1d:	75 0d                	jne    80104e2c <sched+0x27>
    panic("sched ptable.lock");
80104e1f:	83 ec 0c             	sub    $0xc,%esp
80104e22:	68 f4 97 10 80       	push   $0x801097f4
80104e27:	e8 3a b7 ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
80104e2c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104e32:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104e38:	83 f8 01             	cmp    $0x1,%eax
80104e3b:	74 0d                	je     80104e4a <sched+0x45>
    panic("sched locks");
80104e3d:	83 ec 0c             	sub    $0xc,%esp
80104e40:	68 06 98 10 80       	push   $0x80109806
80104e45:	e8 1c b7 ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
80104e4a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e50:	8b 40 0c             	mov    0xc(%eax),%eax
80104e53:	83 f8 04             	cmp    $0x4,%eax
80104e56:	75 0d                	jne    80104e65 <sched+0x60>
    panic("sched running");
80104e58:	83 ec 0c             	sub    $0xc,%esp
80104e5b:	68 12 98 10 80       	push   $0x80109812
80104e60:	e8 01 b7 ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
80104e65:	e8 ea f6 ff ff       	call   80104554 <readeflags>
80104e6a:	25 00 02 00 00       	and    $0x200,%eax
80104e6f:	85 c0                	test   %eax,%eax
80104e71:	74 0d                	je     80104e80 <sched+0x7b>
    panic("sched interruptible");
80104e73:	83 ec 0c             	sub    $0xc,%esp
80104e76:	68 20 98 10 80       	push   $0x80109820
80104e7b:	e8 e6 b6 ff ff       	call   80100566 <panic>
  intena = cpu->intena;
80104e80:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104e86:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104e8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104e8f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104e95:	8b 40 04             	mov    0x4(%eax),%eax
80104e98:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104e9f:	83 c2 1c             	add    $0x1c,%edx
80104ea2:	83 ec 08             	sub    $0x8,%esp
80104ea5:	50                   	push   %eax
80104ea6:	52                   	push   %edx
80104ea7:	e8 64 11 00 00       	call   80106010 <swtch>
80104eac:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80104eaf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104eb5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104eb8:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104ebe:	90                   	nop
80104ebf:	c9                   	leave  
80104ec0:	c3                   	ret    

80104ec1 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104ec1:	55                   	push   %ebp
80104ec2:	89 e5                	mov    %esp,%ebp
80104ec4:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104ec7:	83 ec 0c             	sub    $0xc,%esp
80104eca:	68 a0 39 11 80       	push   $0x801139a0
80104ecf:	e8 65 0c 00 00       	call   80105b39 <acquire>
80104ed4:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80104ed7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104edd:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  }
  stateListRemove(&ptable.pLists.running, &ptable.pLists.runningTail, proc);
  stateListAdd(&ptable.pLists.ready[proc->priority], &ptable.pLists.readyTail[proc->priority], proc);
  assertState(proc, RUNNABLE);
#endif
  sched();
80104ee4:	e8 1c ff ff ff       	call   80104e05 <sched>
  release(&ptable.lock);
80104ee9:	83 ec 0c             	sub    $0xc,%esp
80104eec:	68 a0 39 11 80       	push   $0x801139a0
80104ef1:	e8 aa 0c 00 00       	call   80105ba0 <release>
80104ef6:	83 c4 10             	add    $0x10,%esp
}
80104ef9:	90                   	nop
80104efa:	c9                   	leave  
80104efb:	c3                   	ret    

80104efc <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104efc:	55                   	push   %ebp
80104efd:	89 e5                	mov    %esp,%ebp
80104eff:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104f02:	83 ec 0c             	sub    $0xc,%esp
80104f05:	68 a0 39 11 80       	push   $0x801139a0
80104f0a:	e8 91 0c 00 00       	call   80105ba0 <release>
80104f0f:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104f12:	a1 20 c0 10 80       	mov    0x8010c020,%eax
80104f17:	85 c0                	test   %eax,%eax
80104f19:	74 24                	je     80104f3f <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104f1b:	c7 05 20 c0 10 80 00 	movl   $0x0,0x8010c020
80104f22:	00 00 00 
    iinit(ROOTDEV);
80104f25:	83 ec 0c             	sub    $0xc,%esp
80104f28:	6a 01                	push   $0x1
80104f2a:	e8 a6 c7 ff ff       	call   801016d5 <iinit>
80104f2f:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104f32:	83 ec 0c             	sub    $0xc,%esp
80104f35:	6a 01                	push   $0x1
80104f37:	e8 02 e5 ff ff       	call   8010343e <initlog>
80104f3c:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104f3f:	90                   	nop
80104f40:	c9                   	leave  
80104f41:	c3                   	ret    

80104f42 <sleep>:
// Reacquires lock when awakened.
// 2016/12/28: ticklock removed from xv6. sleep() changed to
// accept a NULL lock to accommodate.
void
sleep(void *chan, struct spinlock *lk)
{
80104f42:	55                   	push   %ebp
80104f43:	89 e5                	mov    %esp,%ebp
80104f45:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
80104f48:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f4e:	85 c0                	test   %eax,%eax
80104f50:	75 0d                	jne    80104f5f <sleep+0x1d>
    panic("sleep");
80104f52:	83 ec 0c             	sub    $0xc,%esp
80104f55:	68 34 98 10 80       	push   $0x80109834
80104f5a:	e8 07 b6 ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){
80104f5f:	81 7d 0c a0 39 11 80 	cmpl   $0x801139a0,0xc(%ebp)
80104f66:	74 24                	je     80104f8c <sleep+0x4a>
    acquire(&ptable.lock);
80104f68:	83 ec 0c             	sub    $0xc,%esp
80104f6b:	68 a0 39 11 80       	push   $0x801139a0
80104f70:	e8 c4 0b 00 00       	call   80105b39 <acquire>
80104f75:	83 c4 10             	add    $0x10,%esp
    if (lk) release(lk);
80104f78:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104f7c:	74 0e                	je     80104f8c <sleep+0x4a>
80104f7e:	83 ec 0c             	sub    $0xc,%esp
80104f81:	ff 75 0c             	pushl  0xc(%ebp)
80104f84:	e8 17 0c 00 00       	call   80105ba0 <release>
80104f89:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80104f8c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f92:	8b 55 08             	mov    0x8(%ebp),%edx
80104f95:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104f98:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f9e:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
    panic("error removing from running list.");
  if(stateListAdd(&ptable.pLists.sleep, &ptable.pLists.sleepTail, proc))
    panic("error adding to sleep list.");
  assertState(proc, SLEEPING);
#endif
  sched();
80104fa5:	e8 5b fe ff ff       	call   80104e05 <sched>

  // Tidy up.
  proc->chan = 0;
80104faa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fb0:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){
80104fb7:	81 7d 0c a0 39 11 80 	cmpl   $0x801139a0,0xc(%ebp)
80104fbe:	74 24                	je     80104fe4 <sleep+0xa2>
    release(&ptable.lock);
80104fc0:	83 ec 0c             	sub    $0xc,%esp
80104fc3:	68 a0 39 11 80       	push   $0x801139a0
80104fc8:	e8 d3 0b 00 00       	call   80105ba0 <release>
80104fcd:	83 c4 10             	add    $0x10,%esp
    if (lk) acquire(lk);
80104fd0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104fd4:	74 0e                	je     80104fe4 <sleep+0xa2>
80104fd6:	83 ec 0c             	sub    $0xc,%esp
80104fd9:	ff 75 0c             	pushl  0xc(%ebp)
80104fdc:	e8 58 0b 00 00       	call   80105b39 <acquire>
80104fe1:	83 c4 10             	add    $0x10,%esp
  }
}
80104fe4:	90                   	nop
80104fe5:	c9                   	leave  
80104fe6:	c3                   	ret    

80104fe7 <wakeup1>:
#ifndef CS333_P3P4
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104fe7:	55                   	push   %ebp
80104fe8:	89 e5                	mov    %esp,%ebp
80104fea:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104fed:	c7 45 fc d4 39 11 80 	movl   $0x801139d4,-0x4(%ebp)
80104ff4:	eb 27                	jmp    8010501d <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104ff6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ff9:	8b 40 0c             	mov    0xc(%eax),%eax
80104ffc:	83 f8 02             	cmp    $0x2,%eax
80104fff:	75 15                	jne    80105016 <wakeup1+0x2f>
80105001:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105004:	8b 40 20             	mov    0x20(%eax),%eax
80105007:	3b 45 08             	cmp    0x8(%ebp),%eax
8010500a:	75 0a                	jne    80105016 <wakeup1+0x2f>
      p->state = RUNNABLE;
8010500c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010500f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105016:	81 45 fc 9c 00 00 00 	addl   $0x9c,-0x4(%ebp)
8010501d:	81 7d fc d4 60 11 80 	cmpl   $0x801160d4,-0x4(%ebp)
80105024:	72 d0                	jb     80104ff6 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80105026:	90                   	nop
80105027:	c9                   	leave  
80105028:	c3                   	ret    

80105029 <wakeup>:
#endif

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80105029:	55                   	push   %ebp
8010502a:	89 e5                	mov    %esp,%ebp
8010502c:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
8010502f:	83 ec 0c             	sub    $0xc,%esp
80105032:	68 a0 39 11 80       	push   $0x801139a0
80105037:	e8 fd 0a 00 00       	call   80105b39 <acquire>
8010503c:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
8010503f:	83 ec 0c             	sub    $0xc,%esp
80105042:	ff 75 08             	pushl  0x8(%ebp)
80105045:	e8 9d ff ff ff       	call   80104fe7 <wakeup1>
8010504a:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
8010504d:	83 ec 0c             	sub    $0xc,%esp
80105050:	68 a0 39 11 80       	push   $0x801139a0
80105055:	e8 46 0b 00 00       	call   80105ba0 <release>
8010505a:	83 c4 10             	add    $0x10,%esp
}
8010505d:	90                   	nop
8010505e:	c9                   	leave  
8010505f:	c3                   	ret    

80105060 <kill>:
// Process won't exit until it returns
// to user space (see trap in trap.c).
#ifndef CS333_P3P4
int
kill(int pid)
{
80105060:	55                   	push   %ebp
80105061:	89 e5                	mov    %esp,%ebp
80105063:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80105066:	83 ec 0c             	sub    $0xc,%esp
80105069:	68 a0 39 11 80       	push   $0x801139a0
8010506e:	e8 c6 0a 00 00       	call   80105b39 <acquire>
80105073:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105076:	c7 45 f4 d4 39 11 80 	movl   $0x801139d4,-0xc(%ebp)
8010507d:	eb 4a                	jmp    801050c9 <kill+0x69>
    if(p->pid == pid){
8010507f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105082:	8b 50 10             	mov    0x10(%eax),%edx
80105085:	8b 45 08             	mov    0x8(%ebp),%eax
80105088:	39 c2                	cmp    %eax,%edx
8010508a:	75 36                	jne    801050c2 <kill+0x62>
      p->killed = 1;
8010508c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010508f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80105096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105099:	8b 40 0c             	mov    0xc(%eax),%eax
8010509c:	83 f8 02             	cmp    $0x2,%eax
8010509f:	75 0a                	jne    801050ab <kill+0x4b>
        p->state = RUNNABLE;
801050a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050a4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801050ab:	83 ec 0c             	sub    $0xc,%esp
801050ae:	68 a0 39 11 80       	push   $0x801139a0
801050b3:	e8 e8 0a 00 00       	call   80105ba0 <release>
801050b8:	83 c4 10             	add    $0x10,%esp
      return 0;
801050bb:	b8 00 00 00 00       	mov    $0x0,%eax
801050c0:	eb 25                	jmp    801050e7 <kill+0x87>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050c2:	81 45 f4 9c 00 00 00 	addl   $0x9c,-0xc(%ebp)
801050c9:	81 7d f4 d4 60 11 80 	cmpl   $0x801160d4,-0xc(%ebp)
801050d0:	72 ad                	jb     8010507f <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
801050d2:	83 ec 0c             	sub    $0xc,%esp
801050d5:	68 a0 39 11 80       	push   $0x801139a0
801050da:	e8 c1 0a 00 00       	call   80105ba0 <release>
801050df:	83 c4 10             	add    $0x10,%esp
  return -1;
801050e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801050e7:	c9                   	leave  
801050e8:	c3                   	ret    

801050e9 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801050e9:	55                   	push   %ebp
801050ea:	89 e5                	mov    %esp,%ebp
801050ec:	53                   	push   %ebx
801050ed:	83 ec 44             	sub    $0x44,%esp
  char *state;
  uint pc[10];
#if defined CS333_P3P4
  cprintf("\nPID\tName\tUID\tGID\tPPID\tPrio\tElapsed\tCPU\tState\tSize\t PCs\n");
#elif defined CS333_P2
  cprintf("\nPID\tName\tUID\tGID\tPPID\tElapsed\tCPU\tState\tSize\t PCs\n");
801050f0:	83 ec 0c             	sub    $0xc,%esp
801050f3:	68 64 98 10 80       	push   $0x80109864
801050f8:	e8 c9 b2 ff ff       	call   801003c6 <cprintf>
801050fd:	83 c4 10             	add    $0x10,%esp
#elif defined CS333_P1
  cprintf("\nPID\tState\tName\tElapsed\t PCs\n");
#else
  cprintf("\nPID\tState\tName\t PCs\n");
#endif
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105100:	c7 45 f0 d4 39 11 80 	movl   $0x801139d4,-0x10(%ebp)
80105107:	e9 6b 02 00 00       	jmp    80105377 <procdump+0x28e>
    if(p->state == UNUSED)
8010510c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010510f:	8b 40 0c             	mov    0xc(%eax),%eax
80105112:	85 c0                	test   %eax,%eax
80105114:	0f 84 55 02 00 00    	je     8010536f <procdump+0x286>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010511a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010511d:	8b 40 0c             	mov    0xc(%eax),%eax
80105120:	83 f8 05             	cmp    $0x5,%eax
80105123:	77 23                	ja     80105148 <procdump+0x5f>
80105125:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105128:	8b 40 0c             	mov    0xc(%eax),%eax
8010512b:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105132:	85 c0                	test   %eax,%eax
80105134:	74 12                	je     80105148 <procdump+0x5f>
      state = states[p->state];
80105136:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105139:	8b 40 0c             	mov    0xc(%eax),%eax
8010513c:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105143:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105146:	eb 07                	jmp    8010514f <procdump+0x66>
    else
      state = "???";
80105148:	c7 45 ec 98 98 10 80 	movl   $0x80109898,-0x14(%ebp)
    current_ticks = ticks;
8010514f:	a1 40 69 11 80       	mov    0x80116940,%eax
80105154:	89 45 e8             	mov    %eax,-0x18(%ebp)
    i = ((current_ticks-p->start_ticks)%1000);
80105157:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010515a:	8b 40 7c             	mov    0x7c(%eax),%eax
8010515d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80105160:	89 d1                	mov    %edx,%ecx
80105162:	29 c1                	sub    %eax,%ecx
80105164:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105169:	89 c8                	mov    %ecx,%eax
8010516b:	f7 e2                	mul    %edx
8010516d:	89 d0                	mov    %edx,%eax
8010516f:	c1 e8 06             	shr    $0x6,%eax
80105172:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
80105178:	29 c1                	sub    %eax,%ecx
8010517a:	89 c8                	mov    %ecx,%eax
8010517c:	89 45 f4             	mov    %eax,-0xc(%ebp)
#if defined CS333_P2
    cprintf("%d\t%s\t%d\t%d", p->pid, p->name, p->uid, p->gid);
8010517f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105182:	8b 88 84 00 00 00    	mov    0x84(%eax),%ecx
80105188:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010518b:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80105191:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105194:	8d 58 6c             	lea    0x6c(%eax),%ebx
80105197:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010519a:	8b 40 10             	mov    0x10(%eax),%eax
8010519d:	83 ec 0c             	sub    $0xc,%esp
801051a0:	51                   	push   %ecx
801051a1:	52                   	push   %edx
801051a2:	53                   	push   %ebx
801051a3:	50                   	push   %eax
801051a4:	68 9c 98 10 80       	push   $0x8010989c
801051a9:	e8 18 b2 ff ff       	call   801003c6 <cprintf>
801051ae:	83 c4 20             	add    $0x20,%esp
    if(p->pid == 1)
801051b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051b4:	8b 40 10             	mov    0x10(%eax),%eax
801051b7:	83 f8 01             	cmp    $0x1,%eax
801051ba:	75 19                	jne    801051d5 <procdump+0xec>
      cprintf("\t%d",p->pid);
801051bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051bf:	8b 40 10             	mov    0x10(%eax),%eax
801051c2:	83 ec 08             	sub    $0x8,%esp
801051c5:	50                   	push   %eax
801051c6:	68 a8 98 10 80       	push   $0x801098a8
801051cb:	e8 f6 b1 ff ff       	call   801003c6 <cprintf>
801051d0:	83 c4 10             	add    $0x10,%esp
801051d3:	eb 1a                	jmp    801051ef <procdump+0x106>
    else
      cprintf("\t%d",p->parent->pid);
801051d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051d8:	8b 40 14             	mov    0x14(%eax),%eax
801051db:	8b 40 10             	mov    0x10(%eax),%eax
801051de:	83 ec 08             	sub    $0x8,%esp
801051e1:	50                   	push   %eax
801051e2:	68 a8 98 10 80       	push   $0x801098a8
801051e7:	e8 da b1 ff ff       	call   801003c6 <cprintf>
801051ec:	83 c4 10             	add    $0x10,%esp
#if defined CS333_P3P4
      cprintf("\t%d", p->priority);
#endif
    cprintf("\t%d.", ((current_ticks-p->start_ticks)/1000));
801051ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051f2:	8b 40 7c             	mov    0x7c(%eax),%eax
801051f5:	8b 55 e8             	mov    -0x18(%ebp),%edx
801051f8:	29 c2                	sub    %eax,%edx
801051fa:	89 d0                	mov    %edx,%eax
801051fc:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105201:	f7 e2                	mul    %edx
80105203:	89 d0                	mov    %edx,%eax
80105205:	c1 e8 06             	shr    $0x6,%eax
80105208:	83 ec 08             	sub    $0x8,%esp
8010520b:	50                   	push   %eax
8010520c:	68 ac 98 10 80       	push   $0x801098ac
80105211:	e8 b0 b1 ff ff       	call   801003c6 <cprintf>
80105216:	83 c4 10             	add    $0x10,%esp
    if (i<100)
80105219:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
8010521d:	7f 10                	jg     8010522f <procdump+0x146>
      cprintf("0");
8010521f:	83 ec 0c             	sub    $0xc,%esp
80105222:	68 b1 98 10 80       	push   $0x801098b1
80105227:	e8 9a b1 ff ff       	call   801003c6 <cprintf>
8010522c:	83 c4 10             	add    $0x10,%esp
    if (i<10)
8010522f:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105233:	7f 10                	jg     80105245 <procdump+0x15c>
      cprintf("0");
80105235:	83 ec 0c             	sub    $0xc,%esp
80105238:	68 b1 98 10 80       	push   $0x801098b1
8010523d:	e8 84 b1 ff ff       	call   801003c6 <cprintf>
80105242:	83 c4 10             	add    $0x10,%esp
    cprintf("%d", i);
80105245:	83 ec 08             	sub    $0x8,%esp
80105248:	ff 75 f4             	pushl  -0xc(%ebp)
8010524b:	68 b3 98 10 80       	push   $0x801098b3
80105250:	e8 71 b1 ff ff       	call   801003c6 <cprintf>
80105255:	83 c4 10             	add    $0x10,%esp
    i = p->cpu_ticks_total;
80105258:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010525b:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80105261:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("\t%d.", i/1000);
80105264:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80105267:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
8010526c:	89 c8                	mov    %ecx,%eax
8010526e:	f7 ea                	imul   %edx
80105270:	c1 fa 06             	sar    $0x6,%edx
80105273:	89 c8                	mov    %ecx,%eax
80105275:	c1 f8 1f             	sar    $0x1f,%eax
80105278:	29 c2                	sub    %eax,%edx
8010527a:	89 d0                	mov    %edx,%eax
8010527c:	83 ec 08             	sub    $0x8,%esp
8010527f:	50                   	push   %eax
80105280:	68 ac 98 10 80       	push   $0x801098ac
80105285:	e8 3c b1 ff ff       	call   801003c6 <cprintf>
8010528a:	83 c4 10             	add    $0x10,%esp
    i = i%1000;
8010528d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80105290:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105295:	89 c8                	mov    %ecx,%eax
80105297:	f7 ea                	imul   %edx
80105299:	c1 fa 06             	sar    $0x6,%edx
8010529c:	89 c8                	mov    %ecx,%eax
8010529e:	c1 f8 1f             	sar    $0x1f,%eax
801052a1:	29 c2                	sub    %eax,%edx
801052a3:	89 d0                	mov    %edx,%eax
801052a5:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
801052ab:	29 c1                	sub    %eax,%ecx
801052ad:	89 c8                	mov    %ecx,%eax
801052af:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i<100)
801052b2:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
801052b6:	7f 10                	jg     801052c8 <procdump+0x1df>
      cprintf("0");
801052b8:	83 ec 0c             	sub    $0xc,%esp
801052bb:	68 b1 98 10 80       	push   $0x801098b1
801052c0:	e8 01 b1 ff ff       	call   801003c6 <cprintf>
801052c5:	83 c4 10             	add    $0x10,%esp
    if (i<10)
801052c8:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801052cc:	7f 10                	jg     801052de <procdump+0x1f5>
      cprintf("0");
801052ce:	83 ec 0c             	sub    $0xc,%esp
801052d1:	68 b1 98 10 80       	push   $0x801098b1
801052d6:	e8 eb b0 ff ff       	call   801003c6 <cprintf>
801052db:	83 c4 10             	add    $0x10,%esp
    cprintf("%d\t%s\t%d\t", i, state, p->sz);
801052de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052e1:	8b 00                	mov    (%eax),%eax
801052e3:	50                   	push   %eax
801052e4:	ff 75 ec             	pushl  -0x14(%ebp)
801052e7:	ff 75 f4             	pushl  -0xc(%ebp)
801052ea:	68 b6 98 10 80       	push   $0x801098b6
801052ef:	e8 d2 b0 ff ff       	call   801003c6 <cprintf>
801052f4:	83 c4 10             	add    $0x10,%esp
      cprintf("0");
    cprintf("%d\t",i);
#else
    cprintf("%d\t%s\t%s", p->pid, state, p->name);
#endif
    i = 0;
801052f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(p->state == SLEEPING){
801052fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105301:	8b 40 0c             	mov    0xc(%eax),%eax
80105304:	83 f8 02             	cmp    $0x2,%eax
80105307:	75 54                	jne    8010535d <procdump+0x274>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105309:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010530c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010530f:	8b 40 0c             	mov    0xc(%eax),%eax
80105312:	83 c0 08             	add    $0x8,%eax
80105315:	89 c2                	mov    %eax,%edx
80105317:	83 ec 08             	sub    $0x8,%esp
8010531a:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010531d:	50                   	push   %eax
8010531e:	52                   	push   %edx
8010531f:	e8 ce 08 00 00       	call   80105bf2 <getcallerpcs>
80105324:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105327:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010532e:	eb 1c                	jmp    8010534c <procdump+0x263>
        cprintf(" %p", pc[i]);
80105330:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105333:	8b 44 85 c0          	mov    -0x40(%ebp,%eax,4),%eax
80105337:	83 ec 08             	sub    $0x8,%esp
8010533a:	50                   	push   %eax
8010533b:	68 c0 98 10 80       	push   $0x801098c0
80105340:	e8 81 b0 ff ff       	call   801003c6 <cprintf>
80105345:	83 c4 10             	add    $0x10,%esp
    cprintf("%d\t%s\t%s", p->pid, state, p->name);
#endif
    i = 0;
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105348:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010534c:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105350:	7f 0b                	jg     8010535d <procdump+0x274>
80105352:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105355:	8b 44 85 c0          	mov    -0x40(%ebp,%eax,4),%eax
80105359:	85 c0                	test   %eax,%eax
8010535b:	75 d3                	jne    80105330 <procdump+0x247>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
8010535d:	83 ec 0c             	sub    $0xc,%esp
80105360:	68 c4 98 10 80       	push   $0x801098c4
80105365:	e8 5c b0 ff ff       	call   801003c6 <cprintf>
8010536a:	83 c4 10             	add    $0x10,%esp
8010536d:	eb 01                	jmp    80105370 <procdump+0x287>
#else
  cprintf("\nPID\tState\tName\t PCs\n");
#endif
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
8010536f:	90                   	nop
#elif defined CS333_P1
  cprintf("\nPID\tState\tName\tElapsed\t PCs\n");
#else
  cprintf("\nPID\tState\tName\t PCs\n");
#endif
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105370:	81 45 f0 9c 00 00 00 	addl   $0x9c,-0x10(%ebp)
80105377:	81 7d f0 d4 60 11 80 	cmpl   $0x801160d4,-0x10(%ebp)
8010537e:	0f 82 88 fd ff ff    	jb     8010510c <procdump+0x23>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105384:	90                   	nop
80105385:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105388:	c9                   	leave  
80105389:	c3                   	ret    

8010538a <getprocs>:
#endif

//Get all current processes within the system.
int
getprocs(int max, struct uproc* proctable)
{
8010538a:	55                   	push   %ebp
8010538b:	89 e5                	mov    %esp,%ebp
8010538d:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int i;

  //LOCK PTABLE
  acquire(&ptable.lock);
80105390:	83 ec 0c             	sub    $0xc,%esp
80105393:	68 a0 39 11 80       	push   $0x801139a0
80105398:	e8 9c 07 00 00       	call   80105b39 <acquire>
8010539d:	83 c4 10             	add    $0x10,%esp

  //ptable gets incremented within forloop, i get incremented at the end
  //of the forloop.
  for(i=0, p = ptable.proc; p < &ptable.proc[NPROC] && i<max; p++)
801053a0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801053a7:	c7 45 f4 d4 39 11 80 	movl   $0x801139d4,-0xc(%ebp)
801053ae:	e9 a4 01 00 00       	jmp    80105557 <getprocs+0x1cd>
  {
    //copy all the info into one element of the array
    //skip if the process is in the unused state
    if(p->state != UNUSED && p->state != EMBRYO)
801053b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053b6:	8b 40 0c             	mov    0xc(%eax),%eax
801053b9:	85 c0                	test   %eax,%eax
801053bb:	0f 84 8f 01 00 00    	je     80105550 <getprocs+0x1c6>
801053c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053c4:	8b 40 0c             	mov    0xc(%eax),%eax
801053c7:	83 f8 01             	cmp    $0x1,%eax
801053ca:	0f 84 80 01 00 00    	je     80105550 <getprocs+0x1c6>
    {
      proctable[i].pid = p->pid;
801053d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801053d3:	89 d0                	mov    %edx,%eax
801053d5:	01 c0                	add    %eax,%eax
801053d7:	01 d0                	add    %edx,%eax
801053d9:	c1 e0 05             	shl    $0x5,%eax
801053dc:	89 c2                	mov    %eax,%edx
801053de:	8b 45 0c             	mov    0xc(%ebp),%eax
801053e1:	01 c2                	add    %eax,%edx
801053e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053e6:	8b 40 10             	mov    0x10(%eax),%eax
801053e9:	89 02                	mov    %eax,(%edx)
      proctable[i].uid = p->uid;
801053eb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801053ee:	89 d0                	mov    %edx,%eax
801053f0:	01 c0                	add    %eax,%eax
801053f2:	01 d0                	add    %edx,%eax
801053f4:	c1 e0 05             	shl    $0x5,%eax
801053f7:	89 c2                	mov    %eax,%edx
801053f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801053fc:	01 c2                	add    %eax,%edx
801053fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105401:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105407:	89 42 04             	mov    %eax,0x4(%edx)
      proctable[i].gid = p->gid;
8010540a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010540d:	89 d0                	mov    %edx,%eax
8010540f:	01 c0                	add    %eax,%eax
80105411:	01 d0                	add    %edx,%eax
80105413:	c1 e0 05             	shl    $0x5,%eax
80105416:	89 c2                	mov    %eax,%edx
80105418:	8b 45 0c             	mov    0xc(%ebp),%eax
8010541b:	01 c2                	add    %eax,%edx
8010541d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105420:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80105426:	89 42 08             	mov    %eax,0x8(%edx)
      proctable[i].priority = p->priority;
80105429:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010542c:	89 d0                	mov    %edx,%eax
8010542e:	01 c0                	add    %eax,%eax
80105430:	01 d0                	add    %edx,%eax
80105432:	c1 e0 05             	shl    $0x5,%eax
80105435:	89 c2                	mov    %eax,%edx
80105437:	8b 45 0c             	mov    0xc(%ebp),%eax
8010543a:	01 c2                	add    %eax,%edx
8010543c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010543f:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80105445:	89 42 5c             	mov    %eax,0x5c(%edx)
      if(p->parent != 0)
80105448:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010544b:	8b 40 14             	mov    0x14(%eax),%eax
8010544e:	85 c0                	test   %eax,%eax
80105450:	74 21                	je     80105473 <getprocs+0xe9>
        proctable[i].ppid = p->parent->pid;
80105452:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105455:	89 d0                	mov    %edx,%eax
80105457:	01 c0                	add    %eax,%eax
80105459:	01 d0                	add    %edx,%eax
8010545b:	c1 e0 05             	shl    $0x5,%eax
8010545e:	89 c2                	mov    %eax,%edx
80105460:	8b 45 0c             	mov    0xc(%ebp),%eax
80105463:	01 c2                	add    %eax,%edx
80105465:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105468:	8b 40 14             	mov    0x14(%eax),%eax
8010546b:	8b 40 10             	mov    0x10(%eax),%eax
8010546e:	89 42 0c             	mov    %eax,0xc(%edx)
80105471:	eb 1c                	jmp    8010548f <getprocs+0x105>
      else
        proctable[i].ppid = p->pid;
80105473:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105476:	89 d0                	mov    %edx,%eax
80105478:	01 c0                	add    %eax,%eax
8010547a:	01 d0                	add    %edx,%eax
8010547c:	c1 e0 05             	shl    $0x5,%eax
8010547f:	89 c2                	mov    %eax,%edx
80105481:	8b 45 0c             	mov    0xc(%ebp),%eax
80105484:	01 c2                	add    %eax,%edx
80105486:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105489:	8b 40 10             	mov    0x10(%eax),%eax
8010548c:	89 42 0c             	mov    %eax,0xc(%edx)

      //Get the current ticks for elapsed ticks.
      proctable[i].elapsed_ticks = ticks-p->start_ticks;
8010548f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105492:	89 d0                	mov    %edx,%eax
80105494:	01 c0                	add    %eax,%eax
80105496:	01 d0                	add    %edx,%eax
80105498:	c1 e0 05             	shl    $0x5,%eax
8010549b:	89 c2                	mov    %eax,%edx
8010549d:	8b 45 0c             	mov    0xc(%ebp),%eax
801054a0:	01 c2                	add    %eax,%edx
801054a2:	8b 0d 40 69 11 80    	mov    0x80116940,%ecx
801054a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054ab:	8b 40 7c             	mov    0x7c(%eax),%eax
801054ae:	29 c1                	sub    %eax,%ecx
801054b0:	89 c8                	mov    %ecx,%eax
801054b2:	89 42 10             	mov    %eax,0x10(%edx)
      proctable[i].CPU_total_ticks = p->cpu_ticks_total;
801054b5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801054b8:	89 d0                	mov    %edx,%eax
801054ba:	01 c0                	add    %eax,%eax
801054bc:	01 d0                	add    %edx,%eax
801054be:	c1 e0 05             	shl    $0x5,%eax
801054c1:	89 c2                	mov    %eax,%edx
801054c3:	8b 45 0c             	mov    0xc(%ebp),%eax
801054c6:	01 c2                	add    %eax,%edx
801054c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054cb:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
801054d1:	89 42 14             	mov    %eax,0x14(%edx)
      safestrcpy(proctable[i].state, states[p->state], sizeof(proctable[i].state));
801054d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054d7:	8b 40 0c             	mov    0xc(%eax),%eax
801054da:	8b 0c 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%ecx
801054e1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801054e4:	89 d0                	mov    %edx,%eax
801054e6:	01 c0                	add    %eax,%eax
801054e8:	01 d0                	add    %edx,%eax
801054ea:	c1 e0 05             	shl    $0x5,%eax
801054ed:	89 c2                	mov    %eax,%edx
801054ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801054f2:	01 d0                	add    %edx,%eax
801054f4:	83 c0 18             	add    $0x18,%eax
801054f7:	83 ec 04             	sub    $0x4,%esp
801054fa:	6a 20                	push   $0x20
801054fc:	51                   	push   %ecx
801054fd:	50                   	push   %eax
801054fe:	e8 9c 0a 00 00       	call   80105f9f <safestrcpy>
80105503:	83 c4 10             	add    $0x10,%esp
      proctable[i].size = p->sz;
80105506:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105509:	89 d0                	mov    %edx,%eax
8010550b:	01 c0                	add    %eax,%eax
8010550d:	01 d0                	add    %edx,%eax
8010550f:	c1 e0 05             	shl    $0x5,%eax
80105512:	89 c2                	mov    %eax,%edx
80105514:	8b 45 0c             	mov    0xc(%ebp),%eax
80105517:	01 c2                	add    %eax,%edx
80105519:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010551c:	8b 00                	mov    (%eax),%eax
8010551e:	89 42 38             	mov    %eax,0x38(%edx)
      safestrcpy(proctable[i].name, p->name, sizeof(p->name));
80105521:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105524:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105527:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010552a:	89 d0                	mov    %edx,%eax
8010552c:	01 c0                	add    %eax,%eax
8010552e:	01 d0                	add    %edx,%eax
80105530:	c1 e0 05             	shl    $0x5,%eax
80105533:	89 c2                	mov    %eax,%edx
80105535:	8b 45 0c             	mov    0xc(%ebp),%eax
80105538:	01 d0                	add    %edx,%eax
8010553a:	83 c0 3c             	add    $0x3c,%eax
8010553d:	83 ec 04             	sub    $0x4,%esp
80105540:	6a 10                	push   $0x10
80105542:	51                   	push   %ecx
80105543:	50                   	push   %eax
80105544:	e8 56 0a 00 00       	call   80105f9f <safestrcpy>
80105549:	83 c4 10             	add    $0x10,%esp

      //Increment the array that is having info copied into
      ++i;
8010554c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  //LOCK PTABLE
  acquire(&ptable.lock);

  //ptable gets incremented within forloop, i get incremented at the end
  //of the forloop.
  for(i=0, p = ptable.proc; p < &ptable.proc[NPROC] && i<max; p++)
80105550:	81 45 f4 9c 00 00 00 	addl   $0x9c,-0xc(%ebp)
80105557:	81 7d f4 d4 60 11 80 	cmpl   $0x801160d4,-0xc(%ebp)
8010555e:	73 0c                	jae    8010556c <getprocs+0x1e2>
80105560:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105563:	3b 45 08             	cmp    0x8(%ebp),%eax
80105566:	0f 8c 47 fe ff ff    	jl     801053b3 <getprocs+0x29>

    }
  }

  //UNLOCK PTABLE
  release(&ptable.lock);
8010556c:	83 ec 0c             	sub    $0xc,%esp
8010556f:	68 a0 39 11 80       	push   $0x801139a0
80105574:	e8 27 06 00 00       	call   80105ba0 <release>
80105579:	83 c4 10             	add    $0x10,%esp

  return i;
8010557c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010557f:	c9                   	leave  
80105580:	c3                   	ret    

80105581 <piddump>:

void
piddump(void)
{
80105581:	55                   	push   %ebp
80105582:	89 e5                	mov    %esp,%ebp
80105584:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  acquire(&ptable.lock);
80105587:	83 ec 0c             	sub    $0xc,%esp
8010558a:	68 a0 39 11 80       	push   $0x801139a0
8010558f:	e8 a5 05 00 00       	call   80105b39 <acquire>
80105594:	83 c4 10             	add    $0x10,%esp
  cprintf("\nReady List Processes:\n");
80105597:	83 ec 0c             	sub    $0xc,%esp
8010559a:	68 c6 98 10 80       	push   $0x801098c6
8010559f:	e8 22 ae ff ff       	call   801003c6 <cprintf>
801055a4:	83 c4 10             	add    $0x10,%esp
  for(int i = 0; i<MAXPRIO+1; ++i)
801055a7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801055ae:	e9 8b 00 00 00       	jmp    8010563e <piddump+0xbd>
  {
    p = ptable.pLists.ready[i];
801055b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055b6:	05 cc 09 00 00       	add    $0x9cc,%eax
801055bb:	8b 04 85 a4 39 11 80 	mov    -0x7feec65c(,%eax,4),%eax
801055c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("%d: ", i);
801055c5:	83 ec 08             	sub    $0x8,%esp
801055c8:	ff 75 f0             	pushl  -0x10(%ebp)
801055cb:	68 de 98 10 80       	push   $0x801098de
801055d0:	e8 f1 ad ff ff       	call   801003c6 <cprintf>
801055d5:	83 c4 10             	add    $0x10,%esp
    while(p)
801055d8:	eb 4a                	jmp    80105624 <piddump+0xa3>
    {
      cprintf("(%d, %d)", p->pid, p->budget);
801055da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055dd:	8b 90 94 00 00 00    	mov    0x94(%eax),%edx
801055e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055e6:	8b 40 10             	mov    0x10(%eax),%eax
801055e9:	83 ec 04             	sub    $0x4,%esp
801055ec:	52                   	push   %edx
801055ed:	50                   	push   %eax
801055ee:	68 e3 98 10 80       	push   $0x801098e3
801055f3:	e8 ce ad ff ff       	call   801003c6 <cprintf>
801055f8:	83 c4 10             	add    $0x10,%esp
      if(p->next)
801055fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055fe:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105604:	85 c0                	test   %eax,%eax
80105606:	74 10                	je     80105618 <piddump+0x97>
        cprintf(" -> ");
80105608:	83 ec 0c             	sub    $0xc,%esp
8010560b:	68 ec 98 10 80       	push   $0x801098ec
80105610:	e8 b1 ad ff ff       	call   801003c6 <cprintf>
80105615:	83 c4 10             	add    $0x10,%esp
      p = p->next;
80105618:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010561b:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105621:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cprintf("\nReady List Processes:\n");
  for(int i = 0; i<MAXPRIO+1; ++i)
  {
    p = ptable.pLists.ready[i];
    cprintf("%d: ", i);
    while(p)
80105624:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105628:	75 b0                	jne    801055da <piddump+0x59>
      cprintf("(%d, %d)", p->pid, p->budget);
      if(p->next)
        cprintf(" -> ");
      p = p->next;
    }
    cprintf("\n");
8010562a:	83 ec 0c             	sub    $0xc,%esp
8010562d:	68 c4 98 10 80       	push   $0x801098c4
80105632:	e8 8f ad ff ff       	call   801003c6 <cprintf>
80105637:	83 c4 10             	add    $0x10,%esp
piddump(void)
{
  struct proc *p;
  acquire(&ptable.lock);
  cprintf("\nReady List Processes:\n");
  for(int i = 0; i<MAXPRIO+1; ++i)
8010563a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010563e:	83 7d f0 06          	cmpl   $0x6,-0x10(%ebp)
80105642:	0f 8e 6b ff ff ff    	jle    801055b3 <piddump+0x32>
        cprintf(" -> ");
      p = p->next;
    }
    cprintf("\n");
  }
  release(&ptable.lock);
80105648:	83 ec 0c             	sub    $0xc,%esp
8010564b:	68 a0 39 11 80       	push   $0x801139a0
80105650:	e8 4b 05 00 00       	call   80105ba0 <release>
80105655:	83 c4 10             	add    $0x10,%esp
}
80105658:	90                   	nop
80105659:	c9                   	leave  
8010565a:	c3                   	ret    

8010565b <freedump>:

void
freedump(void)
{
8010565b:	55                   	push   %ebp
8010565c:	89 e5                	mov    %esp,%ebp
8010565e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int counter = 0;
80105661:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  acquire(&ptable.lock);
80105668:	83 ec 0c             	sub    $0xc,%esp
8010566b:	68 a0 39 11 80       	push   $0x801139a0
80105670:	e8 c4 04 00 00       	call   80105b39 <acquire>
80105675:	83 c4 10             	add    $0x10,%esp
  p = ptable.pLists.free;
80105678:	a1 0c 61 11 80       	mov    0x8011610c,%eax
8010567d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(p)
80105680:	eb 10                	jmp    80105692 <freedump+0x37>
  {
    p = p->next;
80105682:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105685:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010568b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    ++counter;
8010568e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
{
  struct proc *p;
  int counter = 0;
  acquire(&ptable.lock);
  p = ptable.pLists.free;
  while(p)
80105692:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105696:	75 ea                	jne    80105682 <freedump+0x27>
  {
    p = p->next;
    ++counter;
  }

  cprintf("\nFree List Size: %d processes\n", counter);
80105698:	83 ec 08             	sub    $0x8,%esp
8010569b:	ff 75 f0             	pushl  -0x10(%ebp)
8010569e:	68 f4 98 10 80       	push   $0x801098f4
801056a3:	e8 1e ad ff ff       	call   801003c6 <cprintf>
801056a8:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
801056ab:	83 ec 0c             	sub    $0xc,%esp
801056ae:	68 a0 39 11 80       	push   $0x801139a0
801056b3:	e8 e8 04 00 00       	call   80105ba0 <release>
801056b8:	83 c4 10             	add    $0x10,%esp
}
801056bb:	90                   	nop
801056bc:	c9                   	leave  
801056bd:	c3                   	ret    

801056be <sleepdump>:

void
sleepdump(void)
{
801056be:	55                   	push   %ebp
801056bf:	89 e5                	mov    %esp,%ebp
801056c1:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  acquire(&ptable.lock);
801056c4:	83 ec 0c             	sub    $0xc,%esp
801056c7:	68 a0 39 11 80       	push   $0x801139a0
801056cc:	e8 68 04 00 00       	call   80105b39 <acquire>
801056d1:	83 c4 10             	add    $0x10,%esp
  p = ptable.pLists.sleep;
801056d4:	a1 14 61 11 80       	mov    0x80116114,%eax
801056d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cprintf("\nSleep List Processes:\n");
801056dc:	83 ec 0c             	sub    $0xc,%esp
801056df:	68 13 99 10 80       	push   $0x80109913
801056e4:	e8 dd ac ff ff       	call   801003c6 <cprintf>
801056e9:	83 c4 10             	add    $0x10,%esp
  while(p)
801056ec:	eb 40                	jmp    8010572e <sleepdump+0x70>
  {
    cprintf("%d", p->pid);
801056ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056f1:	8b 40 10             	mov    0x10(%eax),%eax
801056f4:	83 ec 08             	sub    $0x8,%esp
801056f7:	50                   	push   %eax
801056f8:	68 b3 98 10 80       	push   $0x801098b3
801056fd:	e8 c4 ac ff ff       	call   801003c6 <cprintf>
80105702:	83 c4 10             	add    $0x10,%esp
    if(p->next)
80105705:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105708:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010570e:	85 c0                	test   %eax,%eax
80105710:	74 10                	je     80105722 <sleepdump+0x64>
      cprintf(" -> ");
80105712:	83 ec 0c             	sub    $0xc,%esp
80105715:	68 ec 98 10 80       	push   $0x801098ec
8010571a:	e8 a7 ac ff ff       	call   801003c6 <cprintf>
8010571f:	83 c4 10             	add    $0x10,%esp
    p = p->next;
80105722:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105725:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010572b:	89 45 f4             	mov    %eax,-0xc(%ebp)
{
  struct proc *p;
  acquire(&ptable.lock);
  p = ptable.pLists.sleep;
  cprintf("\nSleep List Processes:\n");
  while(p)
8010572e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105732:	75 ba                	jne    801056ee <sleepdump+0x30>
    cprintf("%d", p->pid);
    if(p->next)
      cprintf(" -> ");
    p = p->next;
  }
  cprintf("\n");
80105734:	83 ec 0c             	sub    $0xc,%esp
80105737:	68 c4 98 10 80       	push   $0x801098c4
8010573c:	e8 85 ac ff ff       	call   801003c6 <cprintf>
80105741:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80105744:	83 ec 0c             	sub    $0xc,%esp
80105747:	68 a0 39 11 80       	push   $0x801139a0
8010574c:	e8 4f 04 00 00       	call   80105ba0 <release>
80105751:	83 c4 10             	add    $0x10,%esp
}
80105754:	90                   	nop
80105755:	c9                   	leave  
80105756:	c3                   	ret    

80105757 <zombiedump>:

void
zombiedump(void)
{
80105757:	55                   	push   %ebp
80105758:	89 e5                	mov    %esp,%ebp
8010575a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  acquire(&ptable.lock);
8010575d:	83 ec 0c             	sub    $0xc,%esp
80105760:	68 a0 39 11 80       	push   $0x801139a0
80105765:	e8 cf 03 00 00       	call   80105b39 <acquire>
8010576a:	83 c4 10             	add    $0x10,%esp
  p = ptable.pLists.zombie;
8010576d:	a1 1c 61 11 80       	mov    0x8011611c,%eax
80105772:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cprintf("\nZombie List Processes:\n");
80105775:	83 ec 0c             	sub    $0xc,%esp
80105778:	68 2b 99 10 80       	push   $0x8010992b
8010577d:	e8 44 ac ff ff       	call   801003c6 <cprintf>
80105782:	83 c4 10             	add    $0x10,%esp
  while(p)
80105785:	eb 5c                	jmp    801057e3 <zombiedump+0x8c>
  {
    cprintf("(PID%d, PPID%d)", p->pid, (p->parent? p->parent->pid : p->pid));
80105787:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010578a:	8b 40 14             	mov    0x14(%eax),%eax
8010578d:	85 c0                	test   %eax,%eax
8010578f:	74 0b                	je     8010579c <zombiedump+0x45>
80105791:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105794:	8b 40 14             	mov    0x14(%eax),%eax
80105797:	8b 40 10             	mov    0x10(%eax),%eax
8010579a:	eb 06                	jmp    801057a2 <zombiedump+0x4b>
8010579c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010579f:	8b 40 10             	mov    0x10(%eax),%eax
801057a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057a5:	8b 52 10             	mov    0x10(%edx),%edx
801057a8:	83 ec 04             	sub    $0x4,%esp
801057ab:	50                   	push   %eax
801057ac:	52                   	push   %edx
801057ad:	68 44 99 10 80       	push   $0x80109944
801057b2:	e8 0f ac ff ff       	call   801003c6 <cprintf>
801057b7:	83 c4 10             	add    $0x10,%esp
    if(p->next)
801057ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057bd:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801057c3:	85 c0                	test   %eax,%eax
801057c5:	74 10                	je     801057d7 <zombiedump+0x80>
      cprintf(" -> ");
801057c7:	83 ec 0c             	sub    $0xc,%esp
801057ca:	68 ec 98 10 80       	push   $0x801098ec
801057cf:	e8 f2 ab ff ff       	call   801003c6 <cprintf>
801057d4:	83 c4 10             	add    $0x10,%esp
    p = p->next;
801057d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057da:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801057e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
{
  struct proc *p;
  acquire(&ptable.lock);
  p = ptable.pLists.zombie;
  cprintf("\nZombie List Processes:\n");
  while(p)
801057e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057e7:	75 9e                	jne    80105787 <zombiedump+0x30>
    cprintf("(PID%d, PPID%d)", p->pid, (p->parent? p->parent->pid : p->pid));
    if(p->next)
      cprintf(" -> ");
    p = p->next;
  }
  cprintf("\n");
801057e9:	83 ec 0c             	sub    $0xc,%esp
801057ec:	68 c4 98 10 80       	push   $0x801098c4
801057f1:	e8 d0 ab ff ff       	call   801003c6 <cprintf>
801057f6:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801057f9:	83 ec 0c             	sub    $0xc,%esp
801057fc:	68 a0 39 11 80       	push   $0x801139a0
80105801:	e8 9a 03 00 00       	call   80105ba0 <release>
80105806:	83 c4 10             	add    $0x10,%esp
}
80105809:	90                   	nop
8010580a:	c9                   	leave  
8010580b:	c3                   	ret    

8010580c <assertState>:

void
assertState(struct proc* p, enum procstate state)
{
8010580c:	55                   	push   %ebp
8010580d:	89 e5                	mov    %esp,%ebp
8010580f:	83 ec 08             	sub    $0x8,%esp
  if(p->state != state)
80105812:	8b 45 08             	mov    0x8(%ebp),%eax
80105815:	8b 40 0c             	mov    0xc(%eax),%eax
80105818:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010581b:	74 0d                	je     8010582a <assertState+0x1e>
    panic("proc state does not match list state.");
8010581d:	83 ec 0c             	sub    $0xc,%esp
80105820:	68 54 99 10 80       	push   $0x80109954
80105825:	e8 3c ad ff ff       	call   80100566 <panic>
}
8010582a:	90                   	nop
8010582b:	c9                   	leave  
8010582c:	c3                   	ret    

8010582d <setpriority>:

int
setpriority(int pid, int priority)
{
8010582d:	55                   	push   %ebp
8010582e:	89 e5                	mov    %esp,%ebp
80105830:	83 ec 18             	sub    $0x18,%esp
  struct proc* p;
  if(pid<0 || priority < 0 || priority > MAXPRIO+1)
80105833:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80105837:	78 0c                	js     80105845 <setpriority+0x18>
80105839:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010583d:	78 06                	js     80105845 <setpriority+0x18>
8010583f:	83 7d 0c 07          	cmpl   $0x7,0xc(%ebp)
80105843:	7e 0a                	jle    8010584f <setpriority+0x22>
    return -1;
80105845:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010584a:	e9 82 01 00 00       	jmp    801059d1 <setpriority+0x1a4>

  acquire(&ptable.lock);
8010584f:	83 ec 0c             	sub    $0xc,%esp
80105852:	68 a0 39 11 80       	push   $0x801139a0
80105857:	e8 dd 02 00 00       	call   80105b39 <acquire>
8010585c:	83 c4 10             	add    $0x10,%esp
  for(int i = 0; i < MAXPRIO+1; ++i)
8010585f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80105866:	eb 7b                	jmp    801058e3 <setpriority+0xb6>
  {
    for(p = ptable.pLists.ready[i];p;p=p->next)
80105868:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010586b:	05 cc 09 00 00       	add    $0x9cc,%eax
80105870:	8b 04 85 a4 39 11 80 	mov    -0x7feec65c(,%eax,4),%eax
80105877:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010587a:	eb 5d                	jmp    801058d9 <setpriority+0xac>
    {
      if(p->pid == pid && priority != p->priority)
8010587c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010587f:	8b 50 10             	mov    0x10(%eax),%edx
80105882:	8b 45 08             	mov    0x8(%ebp),%eax
80105885:	39 c2                	cmp    %eax,%edx
80105887:	75 44                	jne    801058cd <setpriority+0xa0>
80105889:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010588c:	8b 90 98 00 00 00    	mov    0x98(%eax),%edx
80105892:	8b 45 0c             	mov    0xc(%ebp),%eax
80105895:	39 c2                	cmp    %eax,%edx
80105897:	74 34                	je     801058cd <setpriority+0xa0>
          panic("Error removing process from current priority");
        p->priority = priority;
        if(stateListAdd(&ptable.pLists.ready[p->priority], &ptable.pLists.readyTail[p->priority], p))
          panic("Error adding process to current priority");
#endif
        p->budget = BUDGET*(p->priority+1);
80105899:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010589c:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801058a2:	83 c0 01             	add    $0x1,%eax
801058a5:	6b c0 64             	imul   $0x64,%eax,%eax
801058a8:	89 c2                	mov    %eax,%edx
801058aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058ad:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
        release(&ptable.lock);
801058b3:	83 ec 0c             	sub    $0xc,%esp
801058b6:	68 a0 39 11 80       	push   $0x801139a0
801058bb:	e8 e0 02 00 00       	call   80105ba0 <release>
801058c0:	83 c4 10             	add    $0x10,%esp
        return 0;
801058c3:	b8 00 00 00 00       	mov    $0x0,%eax
801058c8:	e9 04 01 00 00       	jmp    801059d1 <setpriority+0x1a4>
    return -1;

  acquire(&ptable.lock);
  for(int i = 0; i < MAXPRIO+1; ++i)
  {
    for(p = ptable.pLists.ready[i];p;p=p->next)
801058cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058d0:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801058d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058d9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058dd:	75 9d                	jne    8010587c <setpriority+0x4f>
  struct proc* p;
  if(pid<0 || priority < 0 || priority > MAXPRIO+1)
    return -1;

  acquire(&ptable.lock);
  for(int i = 0; i < MAXPRIO+1; ++i)
801058df:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801058e3:	83 7d f0 06          	cmpl   $0x6,-0x10(%ebp)
801058e7:	0f 8e 7b ff ff ff    	jle    80105868 <setpriority+0x3b>
        release(&ptable.lock);
        return 0;
      }
    }
  }
  for(p = ptable.pLists.sleep; p ; p=p->next)
801058ed:	a1 14 61 11 80       	mov    0x80116114,%eax
801058f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058f5:	eb 59                	jmp    80105950 <setpriority+0x123>
  {
    if(p->pid == pid)
801058f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058fa:	8b 50 10             	mov    0x10(%eax),%edx
801058fd:	8b 45 08             	mov    0x8(%ebp),%eax
80105900:	39 c2                	cmp    %eax,%edx
80105902:	75 40                	jne    80105944 <setpriority+0x117>
    {
      p->priority = priority;
80105904:	8b 55 0c             	mov    0xc(%ebp),%edx
80105907:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010590a:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
      p->budget = BUDGET*(p->priority+1);
80105910:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105913:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80105919:	83 c0 01             	add    $0x1,%eax
8010591c:	6b c0 64             	imul   $0x64,%eax,%eax
8010591f:	89 c2                	mov    %eax,%edx
80105921:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105924:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
      release(&ptable.lock);
8010592a:	83 ec 0c             	sub    $0xc,%esp
8010592d:	68 a0 39 11 80       	push   $0x801139a0
80105932:	e8 69 02 00 00       	call   80105ba0 <release>
80105937:	83 c4 10             	add    $0x10,%esp
      return 0;
8010593a:	b8 00 00 00 00       	mov    $0x0,%eax
8010593f:	e9 8d 00 00 00       	jmp    801059d1 <setpriority+0x1a4>
        release(&ptable.lock);
        return 0;
      }
    }
  }
  for(p = ptable.pLists.sleep; p ; p=p->next)
80105944:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105947:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010594d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105950:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105954:	75 a1                	jne    801058f7 <setpriority+0xca>
      release(&ptable.lock);
      return 0;
    }
  }

  for(p = ptable.pLists.running; p ; p=p->next)
80105956:	a1 24 61 11 80       	mov    0x80116124,%eax
8010595b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010595e:	eb 56                	jmp    801059b6 <setpriority+0x189>
  {
    if(p->pid == pid)
80105960:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105963:	8b 50 10             	mov    0x10(%eax),%edx
80105966:	8b 45 08             	mov    0x8(%ebp),%eax
80105969:	39 c2                	cmp    %eax,%edx
8010596b:	75 3d                	jne    801059aa <setpriority+0x17d>
    {
      p->priority = priority;
8010596d:	8b 55 0c             	mov    0xc(%ebp),%edx
80105970:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105973:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
      p->budget = BUDGET*(p->priority+1);
80105979:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010597c:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80105982:	83 c0 01             	add    $0x1,%eax
80105985:	6b c0 64             	imul   $0x64,%eax,%eax
80105988:	89 c2                	mov    %eax,%edx
8010598a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010598d:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
      release(&ptable.lock);
80105993:	83 ec 0c             	sub    $0xc,%esp
80105996:	68 a0 39 11 80       	push   $0x801139a0
8010599b:	e8 00 02 00 00       	call   80105ba0 <release>
801059a0:	83 c4 10             	add    $0x10,%esp
      return 0;
801059a3:	b8 00 00 00 00       	mov    $0x0,%eax
801059a8:	eb 27                	jmp    801059d1 <setpriority+0x1a4>
      release(&ptable.lock);
      return 0;
    }
  }

  for(p = ptable.pLists.running; p ; p=p->next)
801059aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ad:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801059b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059ba:	75 a4                	jne    80105960 <setpriority+0x133>
      release(&ptable.lock);
      return 0;
    }
  }

  release(&ptable.lock);
801059bc:	83 ec 0c             	sub    $0xc,%esp
801059bf:	68 a0 39 11 80       	push   $0x801139a0
801059c4:	e8 d7 01 00 00       	call   80105ba0 <release>
801059c9:	83 c4 10             	add    $0x10,%esp
  return -1;
801059cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801059d1:	c9                   	leave  
801059d2:	c3                   	ret    

801059d3 <promoteAll>:

void
promoteAll(void)
{
801059d3:	55                   	push   %ebp
801059d4:	89 e5                	mov    %esp,%ebp
801059d6:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;
  for(int i = 0; i < MAXPRIO+1; ++i)
801059d9:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801059e0:	eb 44                	jmp    80105a26 <promoteAll+0x53>
  {
    for(p = ptable.pLists.ready[i]; p; p=p->next)
801059e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801059e5:	05 cc 09 00 00       	add    $0x9cc,%eax
801059ea:	8b 04 85 a4 39 11 80 	mov    -0x7feec65c(,%eax,4),%eax
801059f1:	89 45 fc             	mov    %eax,-0x4(%ebp)
801059f4:	eb 26                	jmp    80105a1c <promoteAll+0x49>
        p->priority -= 1;
        if(stateListAdd(&ptable.pLists.ready[p->priority], &ptable.pLists.readyTail[p->priority], p))
          panic("Error adding process to desired priority");
#endif
      }
      p->budget = BUDGET*(p->priority+1);
801059f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059f9:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801059ff:	83 c0 01             	add    $0x1,%eax
80105a02:	6b c0 64             	imul   $0x64,%eax,%eax
80105a05:	89 c2                	mov    %eax,%edx
80105a07:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a0a:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
promoteAll(void)
{
  struct proc *p;
  for(int i = 0; i < MAXPRIO+1; ++i)
  {
    for(p = ptable.pLists.ready[i]; p; p=p->next)
80105a10:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a13:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105a19:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105a1c:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105a20:	75 d4                	jne    801059f6 <promoteAll+0x23>

void
promoteAll(void)
{
  struct proc *p;
  for(int i = 0; i < MAXPRIO+1; ++i)
80105a22:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105a26:	83 7d f8 06          	cmpl   $0x6,-0x8(%ebp)
80105a2a:	7e b6                	jle    801059e2 <promoteAll+0xf>
#endif
      }
      p->budget = BUDGET*(p->priority+1);
    }
  }
  for(p = ptable.pLists.sleep; p; p=p->next)
80105a2c:	a1 14 61 11 80       	mov    0x80116114,%eax
80105a31:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105a34:	eb 48                	jmp    80105a7e <promoteAll+0xab>
  {
    if(p->priority > 0)
80105a36:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a39:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80105a3f:	85 c0                	test   %eax,%eax
80105a41:	74 15                	je     80105a58 <promoteAll+0x85>
    {
      p->priority -= 1;
80105a43:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a46:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80105a4c:	8d 50 ff             	lea    -0x1(%eax),%edx
80105a4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a52:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
    }
    p->budget = BUDGET*(p->priority+1);
80105a58:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a5b:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80105a61:	83 c0 01             	add    $0x1,%eax
80105a64:	6b c0 64             	imul   $0x64,%eax,%eax
80105a67:	89 c2                	mov    %eax,%edx
80105a69:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a6c:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
#endif
      }
      p->budget = BUDGET*(p->priority+1);
    }
  }
  for(p = ptable.pLists.sleep; p; p=p->next)
80105a72:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a75:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105a7b:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105a7e:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105a82:	75 b2                	jne    80105a36 <promoteAll+0x63>
    {
      p->priority -= 1;
    }
    p->budget = BUDGET*(p->priority+1);
  }
  for(p = ptable.pLists.running; p; p=p->next)
80105a84:	a1 24 61 11 80       	mov    0x80116124,%eax
80105a89:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105a8c:	eb 48                	jmp    80105ad6 <promoteAll+0x103>
  {
    if(p->priority > 0)
80105a8e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a91:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80105a97:	85 c0                	test   %eax,%eax
80105a99:	74 15                	je     80105ab0 <promoteAll+0xdd>
    {
      p->priority -= 1;
80105a9b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a9e:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80105aa4:	8d 50 ff             	lea    -0x1(%eax),%edx
80105aa7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105aaa:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
    }
    p->budget = BUDGET*(p->priority+1);
80105ab0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ab3:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80105ab9:	83 c0 01             	add    $0x1,%eax
80105abc:	6b c0 64             	imul   $0x64,%eax,%eax
80105abf:	89 c2                	mov    %eax,%edx
80105ac1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ac4:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
    {
      p->priority -= 1;
    }
    p->budget = BUDGET*(p->priority+1);
  }
  for(p = ptable.pLists.running; p; p=p->next)
80105aca:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105acd:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105ad3:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105ad6:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105ada:	75 b2                	jne    80105a8e <promoteAll+0xbb>
    {
      p->priority -= 1;
    }
    p->budget = BUDGET*(p->priority+1);
  }
}
80105adc:	90                   	nop
80105add:	c9                   	leave  
80105ade:	c3                   	ret    

80105adf <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105adf:	55                   	push   %ebp
80105ae0:	89 e5                	mov    %esp,%ebp
80105ae2:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105ae5:	9c                   	pushf  
80105ae6:	58                   	pop    %eax
80105ae7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105aea:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105aed:	c9                   	leave  
80105aee:	c3                   	ret    

80105aef <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105aef:	55                   	push   %ebp
80105af0:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105af2:	fa                   	cli    
}
80105af3:	90                   	nop
80105af4:	5d                   	pop    %ebp
80105af5:	c3                   	ret    

80105af6 <sti>:

static inline void
sti(void)
{
80105af6:	55                   	push   %ebp
80105af7:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105af9:	fb                   	sti    
}
80105afa:	90                   	nop
80105afb:	5d                   	pop    %ebp
80105afc:	c3                   	ret    

80105afd <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105afd:	55                   	push   %ebp
80105afe:	89 e5                	mov    %esp,%ebp
80105b00:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105b03:	8b 55 08             	mov    0x8(%ebp),%edx
80105b06:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b09:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105b0c:	f0 87 02             	lock xchg %eax,(%edx)
80105b0f:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105b12:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105b15:	c9                   	leave  
80105b16:	c3                   	ret    

80105b17 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105b17:	55                   	push   %ebp
80105b18:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105b1a:	8b 45 08             	mov    0x8(%ebp),%eax
80105b1d:	8b 55 0c             	mov    0xc(%ebp),%edx
80105b20:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105b23:	8b 45 08             	mov    0x8(%ebp),%eax
80105b26:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105b2c:	8b 45 08             	mov    0x8(%ebp),%eax
80105b2f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105b36:	90                   	nop
80105b37:	5d                   	pop    %ebp
80105b38:	c3                   	ret    

80105b39 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105b39:	55                   	push   %ebp
80105b3a:	89 e5                	mov    %esp,%ebp
80105b3c:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105b3f:	e8 52 01 00 00       	call   80105c96 <pushcli>
  if(holding(lk))
80105b44:	8b 45 08             	mov    0x8(%ebp),%eax
80105b47:	83 ec 0c             	sub    $0xc,%esp
80105b4a:	50                   	push   %eax
80105b4b:	e8 1c 01 00 00       	call   80105c6c <holding>
80105b50:	83 c4 10             	add    $0x10,%esp
80105b53:	85 c0                	test   %eax,%eax
80105b55:	74 0d                	je     80105b64 <acquire+0x2b>
    panic("acquire");
80105b57:	83 ec 0c             	sub    $0xc,%esp
80105b5a:	68 7a 99 10 80       	push   $0x8010997a
80105b5f:	e8 02 aa ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105b64:	90                   	nop
80105b65:	8b 45 08             	mov    0x8(%ebp),%eax
80105b68:	83 ec 08             	sub    $0x8,%esp
80105b6b:	6a 01                	push   $0x1
80105b6d:	50                   	push   %eax
80105b6e:	e8 8a ff ff ff       	call   80105afd <xchg>
80105b73:	83 c4 10             	add    $0x10,%esp
80105b76:	85 c0                	test   %eax,%eax
80105b78:	75 eb                	jne    80105b65 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105b7a:	8b 45 08             	mov    0x8(%ebp),%eax
80105b7d:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105b84:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105b87:	8b 45 08             	mov    0x8(%ebp),%eax
80105b8a:	83 c0 0c             	add    $0xc,%eax
80105b8d:	83 ec 08             	sub    $0x8,%esp
80105b90:	50                   	push   %eax
80105b91:	8d 45 08             	lea    0x8(%ebp),%eax
80105b94:	50                   	push   %eax
80105b95:	e8 58 00 00 00       	call   80105bf2 <getcallerpcs>
80105b9a:	83 c4 10             	add    $0x10,%esp
}
80105b9d:	90                   	nop
80105b9e:	c9                   	leave  
80105b9f:	c3                   	ret    

80105ba0 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105ba0:	55                   	push   %ebp
80105ba1:	89 e5                	mov    %esp,%ebp
80105ba3:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105ba6:	83 ec 0c             	sub    $0xc,%esp
80105ba9:	ff 75 08             	pushl  0x8(%ebp)
80105bac:	e8 bb 00 00 00       	call   80105c6c <holding>
80105bb1:	83 c4 10             	add    $0x10,%esp
80105bb4:	85 c0                	test   %eax,%eax
80105bb6:	75 0d                	jne    80105bc5 <release+0x25>
    panic("release");
80105bb8:	83 ec 0c             	sub    $0xc,%esp
80105bbb:	68 82 99 10 80       	push   $0x80109982
80105bc0:	e8 a1 a9 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80105bc5:	8b 45 08             	mov    0x8(%ebp),%eax
80105bc8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105bcf:	8b 45 08             	mov    0x8(%ebp),%eax
80105bd2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105bd9:	8b 45 08             	mov    0x8(%ebp),%eax
80105bdc:	83 ec 08             	sub    $0x8,%esp
80105bdf:	6a 00                	push   $0x0
80105be1:	50                   	push   %eax
80105be2:	e8 16 ff ff ff       	call   80105afd <xchg>
80105be7:	83 c4 10             	add    $0x10,%esp

  popcli();
80105bea:	e8 ec 00 00 00       	call   80105cdb <popcli>
}
80105bef:	90                   	nop
80105bf0:	c9                   	leave  
80105bf1:	c3                   	ret    

80105bf2 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105bf2:	55                   	push   %ebp
80105bf3:	89 e5                	mov    %esp,%ebp
80105bf5:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105bf8:	8b 45 08             	mov    0x8(%ebp),%eax
80105bfb:	83 e8 08             	sub    $0x8,%eax
80105bfe:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105c01:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105c08:	eb 38                	jmp    80105c42 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105c0a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105c0e:	74 53                	je     80105c63 <getcallerpcs+0x71>
80105c10:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105c17:	76 4a                	jbe    80105c63 <getcallerpcs+0x71>
80105c19:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105c1d:	74 44                	je     80105c63 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105c1f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105c22:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105c29:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c2c:	01 c2                	add    %eax,%edx
80105c2e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c31:	8b 40 04             	mov    0x4(%eax),%eax
80105c34:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105c36:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c39:	8b 00                	mov    (%eax),%eax
80105c3b:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105c3e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105c42:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105c46:	7e c2                	jle    80105c0a <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105c48:	eb 19                	jmp    80105c63 <getcallerpcs+0x71>
    pcs[i] = 0;
80105c4a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105c4d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105c54:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c57:	01 d0                	add    %edx,%eax
80105c59:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105c5f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105c63:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105c67:	7e e1                	jle    80105c4a <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105c69:	90                   	nop
80105c6a:	c9                   	leave  
80105c6b:	c3                   	ret    

80105c6c <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105c6c:	55                   	push   %ebp
80105c6d:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105c6f:	8b 45 08             	mov    0x8(%ebp),%eax
80105c72:	8b 00                	mov    (%eax),%eax
80105c74:	85 c0                	test   %eax,%eax
80105c76:	74 17                	je     80105c8f <holding+0x23>
80105c78:	8b 45 08             	mov    0x8(%ebp),%eax
80105c7b:	8b 50 08             	mov    0x8(%eax),%edx
80105c7e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105c84:	39 c2                	cmp    %eax,%edx
80105c86:	75 07                	jne    80105c8f <holding+0x23>
80105c88:	b8 01 00 00 00       	mov    $0x1,%eax
80105c8d:	eb 05                	jmp    80105c94 <holding+0x28>
80105c8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c94:	5d                   	pop    %ebp
80105c95:	c3                   	ret    

80105c96 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105c96:	55                   	push   %ebp
80105c97:	89 e5                	mov    %esp,%ebp
80105c99:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105c9c:	e8 3e fe ff ff       	call   80105adf <readeflags>
80105ca1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105ca4:	e8 46 fe ff ff       	call   80105aef <cli>
  if(cpu->ncli++ == 0)
80105ca9:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105cb0:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105cb6:	8d 48 01             	lea    0x1(%eax),%ecx
80105cb9:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105cbf:	85 c0                	test   %eax,%eax
80105cc1:	75 15                	jne    80105cd8 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105cc3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105cc9:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105ccc:	81 e2 00 02 00 00    	and    $0x200,%edx
80105cd2:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105cd8:	90                   	nop
80105cd9:	c9                   	leave  
80105cda:	c3                   	ret    

80105cdb <popcli>:

void
popcli(void)
{
80105cdb:	55                   	push   %ebp
80105cdc:	89 e5                	mov    %esp,%ebp
80105cde:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105ce1:	e8 f9 fd ff ff       	call   80105adf <readeflags>
80105ce6:	25 00 02 00 00       	and    $0x200,%eax
80105ceb:	85 c0                	test   %eax,%eax
80105ced:	74 0d                	je     80105cfc <popcli+0x21>
    panic("popcli - interruptible");
80105cef:	83 ec 0c             	sub    $0xc,%esp
80105cf2:	68 8a 99 10 80       	push   $0x8010998a
80105cf7:	e8 6a a8 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80105cfc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d02:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105d08:	83 ea 01             	sub    $0x1,%edx
80105d0b:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105d11:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105d17:	85 c0                	test   %eax,%eax
80105d19:	79 0d                	jns    80105d28 <popcli+0x4d>
    panic("popcli");
80105d1b:	83 ec 0c             	sub    $0xc,%esp
80105d1e:	68 a1 99 10 80       	push   $0x801099a1
80105d23:	e8 3e a8 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105d28:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d2e:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105d34:	85 c0                	test   %eax,%eax
80105d36:	75 15                	jne    80105d4d <popcli+0x72>
80105d38:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d3e:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105d44:	85 c0                	test   %eax,%eax
80105d46:	74 05                	je     80105d4d <popcli+0x72>
    sti();
80105d48:	e8 a9 fd ff ff       	call   80105af6 <sti>
}
80105d4d:	90                   	nop
80105d4e:	c9                   	leave  
80105d4f:	c3                   	ret    

80105d50 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105d50:	55                   	push   %ebp
80105d51:	89 e5                	mov    %esp,%ebp
80105d53:	57                   	push   %edi
80105d54:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105d55:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105d58:	8b 55 10             	mov    0x10(%ebp),%edx
80105d5b:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d5e:	89 cb                	mov    %ecx,%ebx
80105d60:	89 df                	mov    %ebx,%edi
80105d62:	89 d1                	mov    %edx,%ecx
80105d64:	fc                   	cld    
80105d65:	f3 aa                	rep stos %al,%es:(%edi)
80105d67:	89 ca                	mov    %ecx,%edx
80105d69:	89 fb                	mov    %edi,%ebx
80105d6b:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105d6e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105d71:	90                   	nop
80105d72:	5b                   	pop    %ebx
80105d73:	5f                   	pop    %edi
80105d74:	5d                   	pop    %ebp
80105d75:	c3                   	ret    

80105d76 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105d76:	55                   	push   %ebp
80105d77:	89 e5                	mov    %esp,%ebp
80105d79:	57                   	push   %edi
80105d7a:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105d7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105d7e:	8b 55 10             	mov    0x10(%ebp),%edx
80105d81:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d84:	89 cb                	mov    %ecx,%ebx
80105d86:	89 df                	mov    %ebx,%edi
80105d88:	89 d1                	mov    %edx,%ecx
80105d8a:	fc                   	cld    
80105d8b:	f3 ab                	rep stos %eax,%es:(%edi)
80105d8d:	89 ca                	mov    %ecx,%edx
80105d8f:	89 fb                	mov    %edi,%ebx
80105d91:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105d94:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105d97:	90                   	nop
80105d98:	5b                   	pop    %ebx
80105d99:	5f                   	pop    %edi
80105d9a:	5d                   	pop    %ebp
80105d9b:	c3                   	ret    

80105d9c <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105d9c:	55                   	push   %ebp
80105d9d:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105d9f:	8b 45 08             	mov    0x8(%ebp),%eax
80105da2:	83 e0 03             	and    $0x3,%eax
80105da5:	85 c0                	test   %eax,%eax
80105da7:	75 43                	jne    80105dec <memset+0x50>
80105da9:	8b 45 10             	mov    0x10(%ebp),%eax
80105dac:	83 e0 03             	and    $0x3,%eax
80105daf:	85 c0                	test   %eax,%eax
80105db1:	75 39                	jne    80105dec <memset+0x50>
    c &= 0xFF;
80105db3:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105dba:	8b 45 10             	mov    0x10(%ebp),%eax
80105dbd:	c1 e8 02             	shr    $0x2,%eax
80105dc0:	89 c1                	mov    %eax,%ecx
80105dc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80105dc5:	c1 e0 18             	shl    $0x18,%eax
80105dc8:	89 c2                	mov    %eax,%edx
80105dca:	8b 45 0c             	mov    0xc(%ebp),%eax
80105dcd:	c1 e0 10             	shl    $0x10,%eax
80105dd0:	09 c2                	or     %eax,%edx
80105dd2:	8b 45 0c             	mov    0xc(%ebp),%eax
80105dd5:	c1 e0 08             	shl    $0x8,%eax
80105dd8:	09 d0                	or     %edx,%eax
80105dda:	0b 45 0c             	or     0xc(%ebp),%eax
80105ddd:	51                   	push   %ecx
80105dde:	50                   	push   %eax
80105ddf:	ff 75 08             	pushl  0x8(%ebp)
80105de2:	e8 8f ff ff ff       	call   80105d76 <stosl>
80105de7:	83 c4 0c             	add    $0xc,%esp
80105dea:	eb 12                	jmp    80105dfe <memset+0x62>
  } else
    stosb(dst, c, n);
80105dec:	8b 45 10             	mov    0x10(%ebp),%eax
80105def:	50                   	push   %eax
80105df0:	ff 75 0c             	pushl  0xc(%ebp)
80105df3:	ff 75 08             	pushl  0x8(%ebp)
80105df6:	e8 55 ff ff ff       	call   80105d50 <stosb>
80105dfb:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105dfe:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105e01:	c9                   	leave  
80105e02:	c3                   	ret    

80105e03 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105e03:	55                   	push   %ebp
80105e04:	89 e5                	mov    %esp,%ebp
80105e06:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105e09:	8b 45 08             	mov    0x8(%ebp),%eax
80105e0c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105e0f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e12:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105e15:	eb 30                	jmp    80105e47 <memcmp+0x44>
    if(*s1 != *s2)
80105e17:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e1a:	0f b6 10             	movzbl (%eax),%edx
80105e1d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e20:	0f b6 00             	movzbl (%eax),%eax
80105e23:	38 c2                	cmp    %al,%dl
80105e25:	74 18                	je     80105e3f <memcmp+0x3c>
      return *s1 - *s2;
80105e27:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e2a:	0f b6 00             	movzbl (%eax),%eax
80105e2d:	0f b6 d0             	movzbl %al,%edx
80105e30:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e33:	0f b6 00             	movzbl (%eax),%eax
80105e36:	0f b6 c0             	movzbl %al,%eax
80105e39:	29 c2                	sub    %eax,%edx
80105e3b:	89 d0                	mov    %edx,%eax
80105e3d:	eb 1a                	jmp    80105e59 <memcmp+0x56>
    s1++, s2++;
80105e3f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105e43:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105e47:	8b 45 10             	mov    0x10(%ebp),%eax
80105e4a:	8d 50 ff             	lea    -0x1(%eax),%edx
80105e4d:	89 55 10             	mov    %edx,0x10(%ebp)
80105e50:	85 c0                	test   %eax,%eax
80105e52:	75 c3                	jne    80105e17 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105e54:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e59:	c9                   	leave  
80105e5a:	c3                   	ret    

80105e5b <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105e5b:	55                   	push   %ebp
80105e5c:	89 e5                	mov    %esp,%ebp
80105e5e:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105e61:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e64:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105e67:	8b 45 08             	mov    0x8(%ebp),%eax
80105e6a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105e6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e70:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105e73:	73 54                	jae    80105ec9 <memmove+0x6e>
80105e75:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105e78:	8b 45 10             	mov    0x10(%ebp),%eax
80105e7b:	01 d0                	add    %edx,%eax
80105e7d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105e80:	76 47                	jbe    80105ec9 <memmove+0x6e>
    s += n;
80105e82:	8b 45 10             	mov    0x10(%ebp),%eax
80105e85:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105e88:	8b 45 10             	mov    0x10(%ebp),%eax
80105e8b:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105e8e:	eb 13                	jmp    80105ea3 <memmove+0x48>
      *--d = *--s;
80105e90:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105e94:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105e98:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e9b:	0f b6 10             	movzbl (%eax),%edx
80105e9e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105ea1:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105ea3:	8b 45 10             	mov    0x10(%ebp),%eax
80105ea6:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ea9:	89 55 10             	mov    %edx,0x10(%ebp)
80105eac:	85 c0                	test   %eax,%eax
80105eae:	75 e0                	jne    80105e90 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105eb0:	eb 24                	jmp    80105ed6 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105eb2:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105eb5:	8d 50 01             	lea    0x1(%eax),%edx
80105eb8:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105ebb:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105ebe:	8d 4a 01             	lea    0x1(%edx),%ecx
80105ec1:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105ec4:	0f b6 12             	movzbl (%edx),%edx
80105ec7:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105ec9:	8b 45 10             	mov    0x10(%ebp),%eax
80105ecc:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ecf:	89 55 10             	mov    %edx,0x10(%ebp)
80105ed2:	85 c0                	test   %eax,%eax
80105ed4:	75 dc                	jne    80105eb2 <memmove+0x57>
      *d++ = *s++;

  return dst;
80105ed6:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105ed9:	c9                   	leave  
80105eda:	c3                   	ret    

80105edb <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105edb:	55                   	push   %ebp
80105edc:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105ede:	ff 75 10             	pushl  0x10(%ebp)
80105ee1:	ff 75 0c             	pushl  0xc(%ebp)
80105ee4:	ff 75 08             	pushl  0x8(%ebp)
80105ee7:	e8 6f ff ff ff       	call   80105e5b <memmove>
80105eec:	83 c4 0c             	add    $0xc,%esp
}
80105eef:	c9                   	leave  
80105ef0:	c3                   	ret    

80105ef1 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105ef1:	55                   	push   %ebp
80105ef2:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105ef4:	eb 0c                	jmp    80105f02 <strncmp+0x11>
    n--, p++, q++;
80105ef6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105efa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105efe:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105f02:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f06:	74 1a                	je     80105f22 <strncmp+0x31>
80105f08:	8b 45 08             	mov    0x8(%ebp),%eax
80105f0b:	0f b6 00             	movzbl (%eax),%eax
80105f0e:	84 c0                	test   %al,%al
80105f10:	74 10                	je     80105f22 <strncmp+0x31>
80105f12:	8b 45 08             	mov    0x8(%ebp),%eax
80105f15:	0f b6 10             	movzbl (%eax),%edx
80105f18:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f1b:	0f b6 00             	movzbl (%eax),%eax
80105f1e:	38 c2                	cmp    %al,%dl
80105f20:	74 d4                	je     80105ef6 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105f22:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f26:	75 07                	jne    80105f2f <strncmp+0x3e>
    return 0;
80105f28:	b8 00 00 00 00       	mov    $0x0,%eax
80105f2d:	eb 16                	jmp    80105f45 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105f2f:	8b 45 08             	mov    0x8(%ebp),%eax
80105f32:	0f b6 00             	movzbl (%eax),%eax
80105f35:	0f b6 d0             	movzbl %al,%edx
80105f38:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f3b:	0f b6 00             	movzbl (%eax),%eax
80105f3e:	0f b6 c0             	movzbl %al,%eax
80105f41:	29 c2                	sub    %eax,%edx
80105f43:	89 d0                	mov    %edx,%eax
}
80105f45:	5d                   	pop    %ebp
80105f46:	c3                   	ret    

80105f47 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105f47:	55                   	push   %ebp
80105f48:	89 e5                	mov    %esp,%ebp
80105f4a:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105f4d:	8b 45 08             	mov    0x8(%ebp),%eax
80105f50:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105f53:	90                   	nop
80105f54:	8b 45 10             	mov    0x10(%ebp),%eax
80105f57:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f5a:	89 55 10             	mov    %edx,0x10(%ebp)
80105f5d:	85 c0                	test   %eax,%eax
80105f5f:	7e 2c                	jle    80105f8d <strncpy+0x46>
80105f61:	8b 45 08             	mov    0x8(%ebp),%eax
80105f64:	8d 50 01             	lea    0x1(%eax),%edx
80105f67:	89 55 08             	mov    %edx,0x8(%ebp)
80105f6a:	8b 55 0c             	mov    0xc(%ebp),%edx
80105f6d:	8d 4a 01             	lea    0x1(%edx),%ecx
80105f70:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105f73:	0f b6 12             	movzbl (%edx),%edx
80105f76:	88 10                	mov    %dl,(%eax)
80105f78:	0f b6 00             	movzbl (%eax),%eax
80105f7b:	84 c0                	test   %al,%al
80105f7d:	75 d5                	jne    80105f54 <strncpy+0xd>
    ;
  while(n-- > 0)
80105f7f:	eb 0c                	jmp    80105f8d <strncpy+0x46>
    *s++ = 0;
80105f81:	8b 45 08             	mov    0x8(%ebp),%eax
80105f84:	8d 50 01             	lea    0x1(%eax),%edx
80105f87:	89 55 08             	mov    %edx,0x8(%ebp)
80105f8a:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105f8d:	8b 45 10             	mov    0x10(%ebp),%eax
80105f90:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f93:	89 55 10             	mov    %edx,0x10(%ebp)
80105f96:	85 c0                	test   %eax,%eax
80105f98:	7f e7                	jg     80105f81 <strncpy+0x3a>
    *s++ = 0;
  return os;
80105f9a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105f9d:	c9                   	leave  
80105f9e:	c3                   	ret    

80105f9f <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105f9f:	55                   	push   %ebp
80105fa0:	89 e5                	mov    %esp,%ebp
80105fa2:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105fa5:	8b 45 08             	mov    0x8(%ebp),%eax
80105fa8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105fab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105faf:	7f 05                	jg     80105fb6 <safestrcpy+0x17>
    return os;
80105fb1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105fb4:	eb 31                	jmp    80105fe7 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105fb6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105fba:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105fbe:	7e 1e                	jle    80105fde <safestrcpy+0x3f>
80105fc0:	8b 45 08             	mov    0x8(%ebp),%eax
80105fc3:	8d 50 01             	lea    0x1(%eax),%edx
80105fc6:	89 55 08             	mov    %edx,0x8(%ebp)
80105fc9:	8b 55 0c             	mov    0xc(%ebp),%edx
80105fcc:	8d 4a 01             	lea    0x1(%edx),%ecx
80105fcf:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105fd2:	0f b6 12             	movzbl (%edx),%edx
80105fd5:	88 10                	mov    %dl,(%eax)
80105fd7:	0f b6 00             	movzbl (%eax),%eax
80105fda:	84 c0                	test   %al,%al
80105fdc:	75 d8                	jne    80105fb6 <safestrcpy+0x17>
    ;
  *s = 0;
80105fde:	8b 45 08             	mov    0x8(%ebp),%eax
80105fe1:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105fe4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105fe7:	c9                   	leave  
80105fe8:	c3                   	ret    

80105fe9 <strlen>:

int
strlen(const char *s)
{
80105fe9:	55                   	push   %ebp
80105fea:	89 e5                	mov    %esp,%ebp
80105fec:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105fef:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105ff6:	eb 04                	jmp    80105ffc <strlen+0x13>
80105ff8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105ffc:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105fff:	8b 45 08             	mov    0x8(%ebp),%eax
80106002:	01 d0                	add    %edx,%eax
80106004:	0f b6 00             	movzbl (%eax),%eax
80106007:	84 c0                	test   %al,%al
80106009:	75 ed                	jne    80105ff8 <strlen+0xf>
    ;
  return n;
8010600b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010600e:	c9                   	leave  
8010600f:	c3                   	ret    

80106010 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80106010:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80106014:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80106018:	55                   	push   %ebp
  pushl %ebx
80106019:	53                   	push   %ebx
  pushl %esi
8010601a:	56                   	push   %esi
  pushl %edi
8010601b:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010601c:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010601e:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80106020:	5f                   	pop    %edi
  popl %esi
80106021:	5e                   	pop    %esi
  popl %ebx
80106022:	5b                   	pop    %ebx
  popl %ebp
80106023:	5d                   	pop    %ebp
  ret
80106024:	c3                   	ret    

80106025 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80106025:	55                   	push   %ebp
80106026:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80106028:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010602e:	8b 00                	mov    (%eax),%eax
80106030:	3b 45 08             	cmp    0x8(%ebp),%eax
80106033:	76 12                	jbe    80106047 <fetchint+0x22>
80106035:	8b 45 08             	mov    0x8(%ebp),%eax
80106038:	8d 50 04             	lea    0x4(%eax),%edx
8010603b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106041:	8b 00                	mov    (%eax),%eax
80106043:	39 c2                	cmp    %eax,%edx
80106045:	76 07                	jbe    8010604e <fetchint+0x29>
    return -1;
80106047:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010604c:	eb 0f                	jmp    8010605d <fetchint+0x38>
  *ip = *(int*)(addr);
8010604e:	8b 45 08             	mov    0x8(%ebp),%eax
80106051:	8b 10                	mov    (%eax),%edx
80106053:	8b 45 0c             	mov    0xc(%ebp),%eax
80106056:	89 10                	mov    %edx,(%eax)
  return 0;
80106058:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010605d:	5d                   	pop    %ebp
8010605e:	c3                   	ret    

8010605f <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010605f:	55                   	push   %ebp
80106060:	89 e5                	mov    %esp,%ebp
80106062:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80106065:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010606b:	8b 00                	mov    (%eax),%eax
8010606d:	3b 45 08             	cmp    0x8(%ebp),%eax
80106070:	77 07                	ja     80106079 <fetchstr+0x1a>
    return -1;
80106072:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106077:	eb 46                	jmp    801060bf <fetchstr+0x60>
  *pp = (char*)addr;
80106079:	8b 55 08             	mov    0x8(%ebp),%edx
8010607c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010607f:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80106081:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106087:	8b 00                	mov    (%eax),%eax
80106089:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
8010608c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010608f:	8b 00                	mov    (%eax),%eax
80106091:	89 45 fc             	mov    %eax,-0x4(%ebp)
80106094:	eb 1c                	jmp    801060b2 <fetchstr+0x53>
    if(*s == 0)
80106096:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106099:	0f b6 00             	movzbl (%eax),%eax
8010609c:	84 c0                	test   %al,%al
8010609e:	75 0e                	jne    801060ae <fetchstr+0x4f>
      return s - *pp;
801060a0:	8b 55 fc             	mov    -0x4(%ebp),%edx
801060a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801060a6:	8b 00                	mov    (%eax),%eax
801060a8:	29 c2                	sub    %eax,%edx
801060aa:	89 d0                	mov    %edx,%eax
801060ac:	eb 11                	jmp    801060bf <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
801060ae:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801060b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801060b5:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801060b8:	72 dc                	jb     80106096 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
801060ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801060bf:	c9                   	leave  
801060c0:	c3                   	ret    

801060c1 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801060c1:	55                   	push   %ebp
801060c2:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
801060c4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060ca:	8b 40 18             	mov    0x18(%eax),%eax
801060cd:	8b 40 44             	mov    0x44(%eax),%eax
801060d0:	8b 55 08             	mov    0x8(%ebp),%edx
801060d3:	c1 e2 02             	shl    $0x2,%edx
801060d6:	01 d0                	add    %edx,%eax
801060d8:	83 c0 04             	add    $0x4,%eax
801060db:	ff 75 0c             	pushl  0xc(%ebp)
801060de:	50                   	push   %eax
801060df:	e8 41 ff ff ff       	call   80106025 <fetchint>
801060e4:	83 c4 08             	add    $0x8,%esp
}
801060e7:	c9                   	leave  
801060e8:	c3                   	ret    

801060e9 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801060e9:	55                   	push   %ebp
801060ea:	89 e5                	mov    %esp,%ebp
801060ec:	83 ec 10             	sub    $0x10,%esp
  int i;

  if(argint(n, &i) < 0)
801060ef:	8d 45 fc             	lea    -0x4(%ebp),%eax
801060f2:	50                   	push   %eax
801060f3:	ff 75 08             	pushl  0x8(%ebp)
801060f6:	e8 c6 ff ff ff       	call   801060c1 <argint>
801060fb:	83 c4 08             	add    $0x8,%esp
801060fe:	85 c0                	test   %eax,%eax
80106100:	79 07                	jns    80106109 <argptr+0x20>
    return -1;
80106102:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106107:	eb 3b                	jmp    80106144 <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80106109:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010610f:	8b 00                	mov    (%eax),%eax
80106111:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106114:	39 d0                	cmp    %edx,%eax
80106116:	76 16                	jbe    8010612e <argptr+0x45>
80106118:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010611b:	89 c2                	mov    %eax,%edx
8010611d:	8b 45 10             	mov    0x10(%ebp),%eax
80106120:	01 c2                	add    %eax,%edx
80106122:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106128:	8b 00                	mov    (%eax),%eax
8010612a:	39 c2                	cmp    %eax,%edx
8010612c:	76 07                	jbe    80106135 <argptr+0x4c>
    return -1;
8010612e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106133:	eb 0f                	jmp    80106144 <argptr+0x5b>
  *pp = (char*)i;
80106135:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106138:	89 c2                	mov    %eax,%edx
8010613a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010613d:	89 10                	mov    %edx,(%eax)
  return 0;
8010613f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106144:	c9                   	leave  
80106145:	c3                   	ret    

80106146 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80106146:	55                   	push   %ebp
80106147:	89 e5                	mov    %esp,%ebp
80106149:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010614c:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010614f:	50                   	push   %eax
80106150:	ff 75 08             	pushl  0x8(%ebp)
80106153:	e8 69 ff ff ff       	call   801060c1 <argint>
80106158:	83 c4 08             	add    $0x8,%esp
8010615b:	85 c0                	test   %eax,%eax
8010615d:	79 07                	jns    80106166 <argstr+0x20>
    return -1;
8010615f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106164:	eb 0f                	jmp    80106175 <argstr+0x2f>
  return fetchstr(addr, pp);
80106166:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106169:	ff 75 0c             	pushl  0xc(%ebp)
8010616c:	50                   	push   %eax
8010616d:	e8 ed fe ff ff       	call   8010605f <fetchstr>
80106172:	83 c4 08             	add    $0x8,%esp
}
80106175:	c9                   	leave  
80106176:	c3                   	ret    

80106177 <syscall>:
};
#endif

void
syscall(void)
{
80106177:	55                   	push   %ebp
80106178:	89 e5                	mov    %esp,%ebp
8010617a:	53                   	push   %ebx
8010617b:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
8010617e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106184:	8b 40 18             	mov    0x18(%eax),%eax
80106187:	8b 40 1c             	mov    0x1c(%eax),%eax
8010618a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010618d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106191:	7e 30                	jle    801061c3 <syscall+0x4c>
80106193:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106196:	83 f8 21             	cmp    $0x21,%eax
80106199:	77 28                	ja     801061c3 <syscall+0x4c>
8010619b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010619e:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
801061a5:	85 c0                	test   %eax,%eax
801061a7:	74 1a                	je     801061c3 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
801061a9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061af:	8b 58 18             	mov    0x18(%eax),%ebx
801061b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061b5:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
801061bc:	ff d0                	call   *%eax
801061be:	89 43 1c             	mov    %eax,0x1c(%ebx)
801061c1:	eb 34                	jmp    801061f7 <syscall+0x80>
#ifdef PRINT_SYSCALLS
    cprintf("%s -> %d\n",syscallnames[num],proc->tf->eax);
#endif
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801061c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061c9:	8d 50 6c             	lea    0x6c(%eax),%edx
801061cc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
// some code goes here
#ifdef PRINT_SYSCALLS
    cprintf("%s -> %d\n",syscallnames[num],proc->tf->eax);
#endif
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801061d2:	8b 40 10             	mov    0x10(%eax),%eax
801061d5:	ff 75 f4             	pushl  -0xc(%ebp)
801061d8:	52                   	push   %edx
801061d9:	50                   	push   %eax
801061da:	68 a8 99 10 80       	push   $0x801099a8
801061df:	e8 e2 a1 ff ff       	call   801003c6 <cprintf>
801061e4:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801061e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061ed:	8b 40 18             	mov    0x18(%eax),%eax
801061f0:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801061f7:	90                   	nop
801061f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801061fb:	c9                   	leave  
801061fc:	c3                   	ret    

801061fd <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801061fd:	55                   	push   %ebp
801061fe:	89 e5                	mov    %esp,%ebp
80106200:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80106203:	83 ec 08             	sub    $0x8,%esp
80106206:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106209:	50                   	push   %eax
8010620a:	ff 75 08             	pushl  0x8(%ebp)
8010620d:	e8 af fe ff ff       	call   801060c1 <argint>
80106212:	83 c4 10             	add    $0x10,%esp
80106215:	85 c0                	test   %eax,%eax
80106217:	79 07                	jns    80106220 <argfd+0x23>
    return -1;
80106219:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010621e:	eb 50                	jmp    80106270 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80106220:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106223:	85 c0                	test   %eax,%eax
80106225:	78 21                	js     80106248 <argfd+0x4b>
80106227:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010622a:	83 f8 0f             	cmp    $0xf,%eax
8010622d:	7f 19                	jg     80106248 <argfd+0x4b>
8010622f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106235:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106238:	83 c2 08             	add    $0x8,%edx
8010623b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010623f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106242:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106246:	75 07                	jne    8010624f <argfd+0x52>
    return -1;
80106248:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010624d:	eb 21                	jmp    80106270 <argfd+0x73>
  if(pfd)
8010624f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106253:	74 08                	je     8010625d <argfd+0x60>
    *pfd = fd;
80106255:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106258:	8b 45 0c             	mov    0xc(%ebp),%eax
8010625b:	89 10                	mov    %edx,(%eax)
  if(pf)
8010625d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106261:	74 08                	je     8010626b <argfd+0x6e>
    *pf = f;
80106263:	8b 45 10             	mov    0x10(%ebp),%eax
80106266:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106269:	89 10                	mov    %edx,(%eax)
  return 0;
8010626b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106270:	c9                   	leave  
80106271:	c3                   	ret    

80106272 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80106272:	55                   	push   %ebp
80106273:	89 e5                	mov    %esp,%ebp
80106275:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80106278:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010627f:	eb 30                	jmp    801062b1 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80106281:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106287:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010628a:	83 c2 08             	add    $0x8,%edx
8010628d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106291:	85 c0                	test   %eax,%eax
80106293:	75 18                	jne    801062ad <fdalloc+0x3b>
      proc->ofile[fd] = f;
80106295:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010629b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010629e:	8d 4a 08             	lea    0x8(%edx),%ecx
801062a1:	8b 55 08             	mov    0x8(%ebp),%edx
801062a4:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801062a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801062ab:	eb 0f                	jmp    801062bc <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801062ad:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801062b1:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801062b5:	7e ca                	jle    80106281 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801062b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801062bc:	c9                   	leave  
801062bd:	c3                   	ret    

801062be <sys_dup>:

int
sys_dup(void)
{
801062be:	55                   	push   %ebp
801062bf:	89 e5                	mov    %esp,%ebp
801062c1:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801062c4:	83 ec 04             	sub    $0x4,%esp
801062c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062ca:	50                   	push   %eax
801062cb:	6a 00                	push   $0x0
801062cd:	6a 00                	push   $0x0
801062cf:	e8 29 ff ff ff       	call   801061fd <argfd>
801062d4:	83 c4 10             	add    $0x10,%esp
801062d7:	85 c0                	test   %eax,%eax
801062d9:	79 07                	jns    801062e2 <sys_dup+0x24>
    return -1;
801062db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062e0:	eb 31                	jmp    80106313 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801062e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062e5:	83 ec 0c             	sub    $0xc,%esp
801062e8:	50                   	push   %eax
801062e9:	e8 84 ff ff ff       	call   80106272 <fdalloc>
801062ee:	83 c4 10             	add    $0x10,%esp
801062f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062f8:	79 07                	jns    80106301 <sys_dup+0x43>
    return -1;
801062fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062ff:	eb 12                	jmp    80106313 <sys_dup+0x55>
  filedup(f);
80106301:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106304:	83 ec 0c             	sub    $0xc,%esp
80106307:	50                   	push   %eax
80106308:	e8 8a ad ff ff       	call   80101097 <filedup>
8010630d:	83 c4 10             	add    $0x10,%esp
  return fd;
80106310:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106313:	c9                   	leave  
80106314:	c3                   	ret    

80106315 <sys_read>:

int
sys_read(void)
{
80106315:	55                   	push   %ebp
80106316:	89 e5                	mov    %esp,%ebp
80106318:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010631b:	83 ec 04             	sub    $0x4,%esp
8010631e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106321:	50                   	push   %eax
80106322:	6a 00                	push   $0x0
80106324:	6a 00                	push   $0x0
80106326:	e8 d2 fe ff ff       	call   801061fd <argfd>
8010632b:	83 c4 10             	add    $0x10,%esp
8010632e:	85 c0                	test   %eax,%eax
80106330:	78 2e                	js     80106360 <sys_read+0x4b>
80106332:	83 ec 08             	sub    $0x8,%esp
80106335:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106338:	50                   	push   %eax
80106339:	6a 02                	push   $0x2
8010633b:	e8 81 fd ff ff       	call   801060c1 <argint>
80106340:	83 c4 10             	add    $0x10,%esp
80106343:	85 c0                	test   %eax,%eax
80106345:	78 19                	js     80106360 <sys_read+0x4b>
80106347:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010634a:	83 ec 04             	sub    $0x4,%esp
8010634d:	50                   	push   %eax
8010634e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106351:	50                   	push   %eax
80106352:	6a 01                	push   $0x1
80106354:	e8 90 fd ff ff       	call   801060e9 <argptr>
80106359:	83 c4 10             	add    $0x10,%esp
8010635c:	85 c0                	test   %eax,%eax
8010635e:	79 07                	jns    80106367 <sys_read+0x52>
    return -1;
80106360:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106365:	eb 17                	jmp    8010637e <sys_read+0x69>
  return fileread(f, p, n);
80106367:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010636a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010636d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106370:	83 ec 04             	sub    $0x4,%esp
80106373:	51                   	push   %ecx
80106374:	52                   	push   %edx
80106375:	50                   	push   %eax
80106376:	e8 ac ae ff ff       	call   80101227 <fileread>
8010637b:	83 c4 10             	add    $0x10,%esp
}
8010637e:	c9                   	leave  
8010637f:	c3                   	ret    

80106380 <sys_write>:

int
sys_write(void)
{
80106380:	55                   	push   %ebp
80106381:	89 e5                	mov    %esp,%ebp
80106383:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106386:	83 ec 04             	sub    $0x4,%esp
80106389:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010638c:	50                   	push   %eax
8010638d:	6a 00                	push   $0x0
8010638f:	6a 00                	push   $0x0
80106391:	e8 67 fe ff ff       	call   801061fd <argfd>
80106396:	83 c4 10             	add    $0x10,%esp
80106399:	85 c0                	test   %eax,%eax
8010639b:	78 2e                	js     801063cb <sys_write+0x4b>
8010639d:	83 ec 08             	sub    $0x8,%esp
801063a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063a3:	50                   	push   %eax
801063a4:	6a 02                	push   $0x2
801063a6:	e8 16 fd ff ff       	call   801060c1 <argint>
801063ab:	83 c4 10             	add    $0x10,%esp
801063ae:	85 c0                	test   %eax,%eax
801063b0:	78 19                	js     801063cb <sys_write+0x4b>
801063b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063b5:	83 ec 04             	sub    $0x4,%esp
801063b8:	50                   	push   %eax
801063b9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801063bc:	50                   	push   %eax
801063bd:	6a 01                	push   $0x1
801063bf:	e8 25 fd ff ff       	call   801060e9 <argptr>
801063c4:	83 c4 10             	add    $0x10,%esp
801063c7:	85 c0                	test   %eax,%eax
801063c9:	79 07                	jns    801063d2 <sys_write+0x52>
    return -1;
801063cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063d0:	eb 17                	jmp    801063e9 <sys_write+0x69>
  return filewrite(f, p, n);
801063d2:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801063d5:	8b 55 ec             	mov    -0x14(%ebp),%edx
801063d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063db:	83 ec 04             	sub    $0x4,%esp
801063de:	51                   	push   %ecx
801063df:	52                   	push   %edx
801063e0:	50                   	push   %eax
801063e1:	e8 f9 ae ff ff       	call   801012df <filewrite>
801063e6:	83 c4 10             	add    $0x10,%esp
}
801063e9:	c9                   	leave  
801063ea:	c3                   	ret    

801063eb <sys_close>:

int
sys_close(void)
{
801063eb:	55                   	push   %ebp
801063ec:	89 e5                	mov    %esp,%ebp
801063ee:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801063f1:	83 ec 04             	sub    $0x4,%esp
801063f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063f7:	50                   	push   %eax
801063f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063fb:	50                   	push   %eax
801063fc:	6a 00                	push   $0x0
801063fe:	e8 fa fd ff ff       	call   801061fd <argfd>
80106403:	83 c4 10             	add    $0x10,%esp
80106406:	85 c0                	test   %eax,%eax
80106408:	79 07                	jns    80106411 <sys_close+0x26>
    return -1;
8010640a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010640f:	eb 28                	jmp    80106439 <sys_close+0x4e>
  proc->ofile[fd] = 0;
80106411:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106417:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010641a:	83 c2 08             	add    $0x8,%edx
8010641d:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106424:	00 
  fileclose(f);
80106425:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106428:	83 ec 0c             	sub    $0xc,%esp
8010642b:	50                   	push   %eax
8010642c:	e8 b7 ac ff ff       	call   801010e8 <fileclose>
80106431:	83 c4 10             	add    $0x10,%esp
  return 0;
80106434:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106439:	c9                   	leave  
8010643a:	c3                   	ret    

8010643b <sys_fstat>:

int
sys_fstat(void)
{
8010643b:	55                   	push   %ebp
8010643c:	89 e5                	mov    %esp,%ebp
8010643e:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80106441:	83 ec 04             	sub    $0x4,%esp
80106444:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106447:	50                   	push   %eax
80106448:	6a 00                	push   $0x0
8010644a:	6a 00                	push   $0x0
8010644c:	e8 ac fd ff ff       	call   801061fd <argfd>
80106451:	83 c4 10             	add    $0x10,%esp
80106454:	85 c0                	test   %eax,%eax
80106456:	78 17                	js     8010646f <sys_fstat+0x34>
80106458:	83 ec 04             	sub    $0x4,%esp
8010645b:	6a 1c                	push   $0x1c
8010645d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106460:	50                   	push   %eax
80106461:	6a 01                	push   $0x1
80106463:	e8 81 fc ff ff       	call   801060e9 <argptr>
80106468:	83 c4 10             	add    $0x10,%esp
8010646b:	85 c0                	test   %eax,%eax
8010646d:	79 07                	jns    80106476 <sys_fstat+0x3b>
    return -1;
8010646f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106474:	eb 13                	jmp    80106489 <sys_fstat+0x4e>
  return filestat(f, st);
80106476:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106479:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010647c:	83 ec 08             	sub    $0x8,%esp
8010647f:	52                   	push   %edx
80106480:	50                   	push   %eax
80106481:	e8 4a ad ff ff       	call   801011d0 <filestat>
80106486:	83 c4 10             	add    $0x10,%esp
}
80106489:	c9                   	leave  
8010648a:	c3                   	ret    

8010648b <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010648b:	55                   	push   %ebp
8010648c:	89 e5                	mov    %esp,%ebp
8010648e:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80106491:	83 ec 08             	sub    $0x8,%esp
80106494:	8d 45 d8             	lea    -0x28(%ebp),%eax
80106497:	50                   	push   %eax
80106498:	6a 00                	push   $0x0
8010649a:	e8 a7 fc ff ff       	call   80106146 <argstr>
8010649f:	83 c4 10             	add    $0x10,%esp
801064a2:	85 c0                	test   %eax,%eax
801064a4:	78 15                	js     801064bb <sys_link+0x30>
801064a6:	83 ec 08             	sub    $0x8,%esp
801064a9:	8d 45 dc             	lea    -0x24(%ebp),%eax
801064ac:	50                   	push   %eax
801064ad:	6a 01                	push   $0x1
801064af:	e8 92 fc ff ff       	call   80106146 <argstr>
801064b4:	83 c4 10             	add    $0x10,%esp
801064b7:	85 c0                	test   %eax,%eax
801064b9:	79 0a                	jns    801064c5 <sys_link+0x3a>
    return -1;
801064bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064c0:	e9 68 01 00 00       	jmp    8010662d <sys_link+0x1a2>

  begin_op();
801064c5:	e8 92 d1 ff ff       	call   8010365c <begin_op>
  if((ip = namei(old)) == 0){
801064ca:	8b 45 d8             	mov    -0x28(%ebp),%eax
801064cd:	83 ec 0c             	sub    $0xc,%esp
801064d0:	50                   	push   %eax
801064d1:	e8 61 c1 ff ff       	call   80102637 <namei>
801064d6:	83 c4 10             	add    $0x10,%esp
801064d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064dc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064e0:	75 0f                	jne    801064f1 <sys_link+0x66>
    end_op();
801064e2:	e8 01 d2 ff ff       	call   801036e8 <end_op>
    return -1;
801064e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064ec:	e9 3c 01 00 00       	jmp    8010662d <sys_link+0x1a2>
  }

  ilock(ip);
801064f1:	83 ec 0c             	sub    $0xc,%esp
801064f4:	ff 75 f4             	pushl  -0xc(%ebp)
801064f7:	e8 2d b5 ff ff       	call   80101a29 <ilock>
801064fc:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801064ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106502:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106506:	66 83 f8 01          	cmp    $0x1,%ax
8010650a:	75 1d                	jne    80106529 <sys_link+0x9e>
    iunlockput(ip);
8010650c:	83 ec 0c             	sub    $0xc,%esp
8010650f:	ff 75 f4             	pushl  -0xc(%ebp)
80106512:	e8 fa b7 ff ff       	call   80101d11 <iunlockput>
80106517:	83 c4 10             	add    $0x10,%esp
    end_op();
8010651a:	e8 c9 d1 ff ff       	call   801036e8 <end_op>
    return -1;
8010651f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106524:	e9 04 01 00 00       	jmp    8010662d <sys_link+0x1a2>
  }

  ip->nlink++;
80106529:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010652c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106530:	83 c0 01             	add    $0x1,%eax
80106533:	89 c2                	mov    %eax,%edx
80106535:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106538:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010653c:	83 ec 0c             	sub    $0xc,%esp
8010653f:	ff 75 f4             	pushl  -0xc(%ebp)
80106542:	e8 e0 b2 ff ff       	call   80101827 <iupdate>
80106547:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
8010654a:	83 ec 0c             	sub    $0xc,%esp
8010654d:	ff 75 f4             	pushl  -0xc(%ebp)
80106550:	e8 5a b6 ff ff       	call   80101baf <iunlock>
80106555:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80106558:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010655b:	83 ec 08             	sub    $0x8,%esp
8010655e:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80106561:	52                   	push   %edx
80106562:	50                   	push   %eax
80106563:	e8 eb c0 ff ff       	call   80102653 <nameiparent>
80106568:	83 c4 10             	add    $0x10,%esp
8010656b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010656e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106572:	74 71                	je     801065e5 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80106574:	83 ec 0c             	sub    $0xc,%esp
80106577:	ff 75 f0             	pushl  -0x10(%ebp)
8010657a:	e8 aa b4 ff ff       	call   80101a29 <ilock>
8010657f:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80106582:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106585:	8b 10                	mov    (%eax),%edx
80106587:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010658a:	8b 00                	mov    (%eax),%eax
8010658c:	39 c2                	cmp    %eax,%edx
8010658e:	75 1d                	jne    801065ad <sys_link+0x122>
80106590:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106593:	8b 40 04             	mov    0x4(%eax),%eax
80106596:	83 ec 04             	sub    $0x4,%esp
80106599:	50                   	push   %eax
8010659a:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010659d:	50                   	push   %eax
8010659e:	ff 75 f0             	pushl  -0x10(%ebp)
801065a1:	e8 f5 bd ff ff       	call   8010239b <dirlink>
801065a6:	83 c4 10             	add    $0x10,%esp
801065a9:	85 c0                	test   %eax,%eax
801065ab:	79 10                	jns    801065bd <sys_link+0x132>
    iunlockput(dp);
801065ad:	83 ec 0c             	sub    $0xc,%esp
801065b0:	ff 75 f0             	pushl  -0x10(%ebp)
801065b3:	e8 59 b7 ff ff       	call   80101d11 <iunlockput>
801065b8:	83 c4 10             	add    $0x10,%esp
    goto bad;
801065bb:	eb 29                	jmp    801065e6 <sys_link+0x15b>
  }
  iunlockput(dp);
801065bd:	83 ec 0c             	sub    $0xc,%esp
801065c0:	ff 75 f0             	pushl  -0x10(%ebp)
801065c3:	e8 49 b7 ff ff       	call   80101d11 <iunlockput>
801065c8:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801065cb:	83 ec 0c             	sub    $0xc,%esp
801065ce:	ff 75 f4             	pushl  -0xc(%ebp)
801065d1:	e8 4b b6 ff ff       	call   80101c21 <iput>
801065d6:	83 c4 10             	add    $0x10,%esp

  end_op();
801065d9:	e8 0a d1 ff ff       	call   801036e8 <end_op>

  return 0;
801065de:	b8 00 00 00 00       	mov    $0x0,%eax
801065e3:	eb 48                	jmp    8010662d <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
801065e5:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
801065e6:	83 ec 0c             	sub    $0xc,%esp
801065e9:	ff 75 f4             	pushl  -0xc(%ebp)
801065ec:	e8 38 b4 ff ff       	call   80101a29 <ilock>
801065f1:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801065f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065f7:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801065fb:	83 e8 01             	sub    $0x1,%eax
801065fe:	89 c2                	mov    %eax,%edx
80106600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106603:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106607:	83 ec 0c             	sub    $0xc,%esp
8010660a:	ff 75 f4             	pushl  -0xc(%ebp)
8010660d:	e8 15 b2 ff ff       	call   80101827 <iupdate>
80106612:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106615:	83 ec 0c             	sub    $0xc,%esp
80106618:	ff 75 f4             	pushl  -0xc(%ebp)
8010661b:	e8 f1 b6 ff ff       	call   80101d11 <iunlockput>
80106620:	83 c4 10             	add    $0x10,%esp
  end_op();
80106623:	e8 c0 d0 ff ff       	call   801036e8 <end_op>
  return -1;
80106628:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010662d:	c9                   	leave  
8010662e:	c3                   	ret    

8010662f <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010662f:	55                   	push   %ebp
80106630:	89 e5                	mov    %esp,%ebp
80106632:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106635:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010663c:	eb 40                	jmp    8010667e <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010663e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106641:	6a 10                	push   $0x10
80106643:	50                   	push   %eax
80106644:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106647:	50                   	push   %eax
80106648:	ff 75 08             	pushl  0x8(%ebp)
8010664b:	e8 97 b9 ff ff       	call   80101fe7 <readi>
80106650:	83 c4 10             	add    $0x10,%esp
80106653:	83 f8 10             	cmp    $0x10,%eax
80106656:	74 0d                	je     80106665 <isdirempty+0x36>
      panic("isdirempty: readi");
80106658:	83 ec 0c             	sub    $0xc,%esp
8010665b:	68 c4 99 10 80       	push   $0x801099c4
80106660:	e8 01 9f ff ff       	call   80100566 <panic>
    if(de.inum != 0)
80106665:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80106669:	66 85 c0             	test   %ax,%ax
8010666c:	74 07                	je     80106675 <isdirempty+0x46>
      return 0;
8010666e:	b8 00 00 00 00       	mov    $0x0,%eax
80106673:	eb 1b                	jmp    80106690 <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106675:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106678:	83 c0 10             	add    $0x10,%eax
8010667b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010667e:	8b 45 08             	mov    0x8(%ebp),%eax
80106681:	8b 50 20             	mov    0x20(%eax),%edx
80106684:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106687:	39 c2                	cmp    %eax,%edx
80106689:	77 b3                	ja     8010663e <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
8010668b:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106690:	c9                   	leave  
80106691:	c3                   	ret    

80106692 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80106692:	55                   	push   %ebp
80106693:	89 e5                	mov    %esp,%ebp
80106695:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80106698:	83 ec 08             	sub    $0x8,%esp
8010669b:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010669e:	50                   	push   %eax
8010669f:	6a 00                	push   $0x0
801066a1:	e8 a0 fa ff ff       	call   80106146 <argstr>
801066a6:	83 c4 10             	add    $0x10,%esp
801066a9:	85 c0                	test   %eax,%eax
801066ab:	79 0a                	jns    801066b7 <sys_unlink+0x25>
    return -1;
801066ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066b2:	e9 bc 01 00 00       	jmp    80106873 <sys_unlink+0x1e1>

  begin_op();
801066b7:	e8 a0 cf ff ff       	call   8010365c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801066bc:	8b 45 cc             	mov    -0x34(%ebp),%eax
801066bf:	83 ec 08             	sub    $0x8,%esp
801066c2:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801066c5:	52                   	push   %edx
801066c6:	50                   	push   %eax
801066c7:	e8 87 bf ff ff       	call   80102653 <nameiparent>
801066cc:	83 c4 10             	add    $0x10,%esp
801066cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801066d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066d6:	75 0f                	jne    801066e7 <sys_unlink+0x55>
    end_op();
801066d8:	e8 0b d0 ff ff       	call   801036e8 <end_op>
    return -1;
801066dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066e2:	e9 8c 01 00 00       	jmp    80106873 <sys_unlink+0x1e1>
  }

  ilock(dp);
801066e7:	83 ec 0c             	sub    $0xc,%esp
801066ea:	ff 75 f4             	pushl  -0xc(%ebp)
801066ed:	e8 37 b3 ff ff       	call   80101a29 <ilock>
801066f2:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801066f5:	83 ec 08             	sub    $0x8,%esp
801066f8:	68 d6 99 10 80       	push   $0x801099d6
801066fd:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106700:	50                   	push   %eax
80106701:	e8 c0 bb ff ff       	call   801022c6 <namecmp>
80106706:	83 c4 10             	add    $0x10,%esp
80106709:	85 c0                	test   %eax,%eax
8010670b:	0f 84 4a 01 00 00    	je     8010685b <sys_unlink+0x1c9>
80106711:	83 ec 08             	sub    $0x8,%esp
80106714:	68 d8 99 10 80       	push   $0x801099d8
80106719:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010671c:	50                   	push   %eax
8010671d:	e8 a4 bb ff ff       	call   801022c6 <namecmp>
80106722:	83 c4 10             	add    $0x10,%esp
80106725:	85 c0                	test   %eax,%eax
80106727:	0f 84 2e 01 00 00    	je     8010685b <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
8010672d:	83 ec 04             	sub    $0x4,%esp
80106730:	8d 45 c8             	lea    -0x38(%ebp),%eax
80106733:	50                   	push   %eax
80106734:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106737:	50                   	push   %eax
80106738:	ff 75 f4             	pushl  -0xc(%ebp)
8010673b:	e8 a1 bb ff ff       	call   801022e1 <dirlookup>
80106740:	83 c4 10             	add    $0x10,%esp
80106743:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106746:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010674a:	0f 84 0a 01 00 00    	je     8010685a <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
80106750:	83 ec 0c             	sub    $0xc,%esp
80106753:	ff 75 f0             	pushl  -0x10(%ebp)
80106756:	e8 ce b2 ff ff       	call   80101a29 <ilock>
8010675b:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
8010675e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106761:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106765:	66 85 c0             	test   %ax,%ax
80106768:	7f 0d                	jg     80106777 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
8010676a:	83 ec 0c             	sub    $0xc,%esp
8010676d:	68 db 99 10 80       	push   $0x801099db
80106772:	e8 ef 9d ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80106777:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010677a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010677e:	66 83 f8 01          	cmp    $0x1,%ax
80106782:	75 25                	jne    801067a9 <sys_unlink+0x117>
80106784:	83 ec 0c             	sub    $0xc,%esp
80106787:	ff 75 f0             	pushl  -0x10(%ebp)
8010678a:	e8 a0 fe ff ff       	call   8010662f <isdirempty>
8010678f:	83 c4 10             	add    $0x10,%esp
80106792:	85 c0                	test   %eax,%eax
80106794:	75 13                	jne    801067a9 <sys_unlink+0x117>
    iunlockput(ip);
80106796:	83 ec 0c             	sub    $0xc,%esp
80106799:	ff 75 f0             	pushl  -0x10(%ebp)
8010679c:	e8 70 b5 ff ff       	call   80101d11 <iunlockput>
801067a1:	83 c4 10             	add    $0x10,%esp
    goto bad;
801067a4:	e9 b2 00 00 00       	jmp    8010685b <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
801067a9:	83 ec 04             	sub    $0x4,%esp
801067ac:	6a 10                	push   $0x10
801067ae:	6a 00                	push   $0x0
801067b0:	8d 45 e0             	lea    -0x20(%ebp),%eax
801067b3:	50                   	push   %eax
801067b4:	e8 e3 f5 ff ff       	call   80105d9c <memset>
801067b9:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801067bc:	8b 45 c8             	mov    -0x38(%ebp),%eax
801067bf:	6a 10                	push   $0x10
801067c1:	50                   	push   %eax
801067c2:	8d 45 e0             	lea    -0x20(%ebp),%eax
801067c5:	50                   	push   %eax
801067c6:	ff 75 f4             	pushl  -0xc(%ebp)
801067c9:	e8 70 b9 ff ff       	call   8010213e <writei>
801067ce:	83 c4 10             	add    $0x10,%esp
801067d1:	83 f8 10             	cmp    $0x10,%eax
801067d4:	74 0d                	je     801067e3 <sys_unlink+0x151>
    panic("unlink: writei");
801067d6:	83 ec 0c             	sub    $0xc,%esp
801067d9:	68 ed 99 10 80       	push   $0x801099ed
801067de:	e8 83 9d ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
801067e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067e6:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801067ea:	66 83 f8 01          	cmp    $0x1,%ax
801067ee:	75 21                	jne    80106811 <sys_unlink+0x17f>
    dp->nlink--;
801067f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067f3:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801067f7:	83 e8 01             	sub    $0x1,%eax
801067fa:	89 c2                	mov    %eax,%edx
801067fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067ff:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106803:	83 ec 0c             	sub    $0xc,%esp
80106806:	ff 75 f4             	pushl  -0xc(%ebp)
80106809:	e8 19 b0 ff ff       	call   80101827 <iupdate>
8010680e:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80106811:	83 ec 0c             	sub    $0xc,%esp
80106814:	ff 75 f4             	pushl  -0xc(%ebp)
80106817:	e8 f5 b4 ff ff       	call   80101d11 <iunlockput>
8010681c:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
8010681f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106822:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106826:	83 e8 01             	sub    $0x1,%eax
80106829:	89 c2                	mov    %eax,%edx
8010682b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010682e:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106832:	83 ec 0c             	sub    $0xc,%esp
80106835:	ff 75 f0             	pushl  -0x10(%ebp)
80106838:	e8 ea af ff ff       	call   80101827 <iupdate>
8010683d:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106840:	83 ec 0c             	sub    $0xc,%esp
80106843:	ff 75 f0             	pushl  -0x10(%ebp)
80106846:	e8 c6 b4 ff ff       	call   80101d11 <iunlockput>
8010684b:	83 c4 10             	add    $0x10,%esp

  end_op();
8010684e:	e8 95 ce ff ff       	call   801036e8 <end_op>

  return 0;
80106853:	b8 00 00 00 00       	mov    $0x0,%eax
80106858:	eb 19                	jmp    80106873 <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
8010685a:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
8010685b:	83 ec 0c             	sub    $0xc,%esp
8010685e:	ff 75 f4             	pushl  -0xc(%ebp)
80106861:	e8 ab b4 ff ff       	call   80101d11 <iunlockput>
80106866:	83 c4 10             	add    $0x10,%esp
  end_op();
80106869:	e8 7a ce ff ff       	call   801036e8 <end_op>
  return -1;
8010686e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106873:	c9                   	leave  
80106874:	c3                   	ret    

80106875 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80106875:	55                   	push   %ebp
80106876:	89 e5                	mov    %esp,%ebp
80106878:	83 ec 38             	sub    $0x38,%esp
8010687b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010687e:	8b 55 10             	mov    0x10(%ebp),%edx
80106881:	8b 45 14             	mov    0x14(%ebp),%eax
80106884:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106888:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010688c:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106890:	83 ec 08             	sub    $0x8,%esp
80106893:	8d 45 de             	lea    -0x22(%ebp),%eax
80106896:	50                   	push   %eax
80106897:	ff 75 08             	pushl  0x8(%ebp)
8010689a:	e8 b4 bd ff ff       	call   80102653 <nameiparent>
8010689f:	83 c4 10             	add    $0x10,%esp
801068a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801068a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801068a9:	75 0a                	jne    801068b5 <create+0x40>
    return 0;
801068ab:	b8 00 00 00 00       	mov    $0x0,%eax
801068b0:	e9 90 01 00 00       	jmp    80106a45 <create+0x1d0>
  ilock(dp);
801068b5:	83 ec 0c             	sub    $0xc,%esp
801068b8:	ff 75 f4             	pushl  -0xc(%ebp)
801068bb:	e8 69 b1 ff ff       	call   80101a29 <ilock>
801068c0:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801068c3:	83 ec 04             	sub    $0x4,%esp
801068c6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801068c9:	50                   	push   %eax
801068ca:	8d 45 de             	lea    -0x22(%ebp),%eax
801068cd:	50                   	push   %eax
801068ce:	ff 75 f4             	pushl  -0xc(%ebp)
801068d1:	e8 0b ba ff ff       	call   801022e1 <dirlookup>
801068d6:	83 c4 10             	add    $0x10,%esp
801068d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801068dc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801068e0:	74 50                	je     80106932 <create+0xbd>
    iunlockput(dp);
801068e2:	83 ec 0c             	sub    $0xc,%esp
801068e5:	ff 75 f4             	pushl  -0xc(%ebp)
801068e8:	e8 24 b4 ff ff       	call   80101d11 <iunlockput>
801068ed:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801068f0:	83 ec 0c             	sub    $0xc,%esp
801068f3:	ff 75 f0             	pushl  -0x10(%ebp)
801068f6:	e8 2e b1 ff ff       	call   80101a29 <ilock>
801068fb:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801068fe:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106903:	75 15                	jne    8010691a <create+0xa5>
80106905:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106908:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010690c:	66 83 f8 02          	cmp    $0x2,%ax
80106910:	75 08                	jne    8010691a <create+0xa5>
      return ip;
80106912:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106915:	e9 2b 01 00 00       	jmp    80106a45 <create+0x1d0>
    iunlockput(ip);
8010691a:	83 ec 0c             	sub    $0xc,%esp
8010691d:	ff 75 f0             	pushl  -0x10(%ebp)
80106920:	e8 ec b3 ff ff       	call   80101d11 <iunlockput>
80106925:	83 c4 10             	add    $0x10,%esp
    return 0;
80106928:	b8 00 00 00 00       	mov    $0x0,%eax
8010692d:	e9 13 01 00 00       	jmp    80106a45 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106932:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106936:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106939:	8b 00                	mov    (%eax),%eax
8010693b:	83 ec 08             	sub    $0x8,%esp
8010693e:	52                   	push   %edx
8010693f:	50                   	push   %eax
80106940:	e8 0b ae ff ff       	call   80101750 <ialloc>
80106945:	83 c4 10             	add    $0x10,%esp
80106948:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010694b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010694f:	75 0d                	jne    8010695e <create+0xe9>
    panic("create: ialloc");
80106951:	83 ec 0c             	sub    $0xc,%esp
80106954:	68 fc 99 10 80       	push   $0x801099fc
80106959:	e8 08 9c ff ff       	call   80100566 <panic>

  ilock(ip);
8010695e:	83 ec 0c             	sub    $0xc,%esp
80106961:	ff 75 f0             	pushl  -0x10(%ebp)
80106964:	e8 c0 b0 ff ff       	call   80101a29 <ilock>
80106969:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
8010696c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010696f:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106973:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106977:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010697a:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
8010697e:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106982:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106985:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
8010698b:	83 ec 0c             	sub    $0xc,%esp
8010698e:	ff 75 f0             	pushl  -0x10(%ebp)
80106991:	e8 91 ae ff ff       	call   80101827 <iupdate>
80106996:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80106999:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010699e:	75 6a                	jne    80106a0a <create+0x195>
    dp->nlink++;  // for ".."
801069a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069a3:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801069a7:	83 c0 01             	add    $0x1,%eax
801069aa:	89 c2                	mov    %eax,%edx
801069ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069af:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801069b3:	83 ec 0c             	sub    $0xc,%esp
801069b6:	ff 75 f4             	pushl  -0xc(%ebp)
801069b9:	e8 69 ae ff ff       	call   80101827 <iupdate>
801069be:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801069c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069c4:	8b 40 04             	mov    0x4(%eax),%eax
801069c7:	83 ec 04             	sub    $0x4,%esp
801069ca:	50                   	push   %eax
801069cb:	68 d6 99 10 80       	push   $0x801099d6
801069d0:	ff 75 f0             	pushl  -0x10(%ebp)
801069d3:	e8 c3 b9 ff ff       	call   8010239b <dirlink>
801069d8:	83 c4 10             	add    $0x10,%esp
801069db:	85 c0                	test   %eax,%eax
801069dd:	78 1e                	js     801069fd <create+0x188>
801069df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069e2:	8b 40 04             	mov    0x4(%eax),%eax
801069e5:	83 ec 04             	sub    $0x4,%esp
801069e8:	50                   	push   %eax
801069e9:	68 d8 99 10 80       	push   $0x801099d8
801069ee:	ff 75 f0             	pushl  -0x10(%ebp)
801069f1:	e8 a5 b9 ff ff       	call   8010239b <dirlink>
801069f6:	83 c4 10             	add    $0x10,%esp
801069f9:	85 c0                	test   %eax,%eax
801069fb:	79 0d                	jns    80106a0a <create+0x195>
      panic("create dots");
801069fd:	83 ec 0c             	sub    $0xc,%esp
80106a00:	68 0b 9a 10 80       	push   $0x80109a0b
80106a05:	e8 5c 9b ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106a0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a0d:	8b 40 04             	mov    0x4(%eax),%eax
80106a10:	83 ec 04             	sub    $0x4,%esp
80106a13:	50                   	push   %eax
80106a14:	8d 45 de             	lea    -0x22(%ebp),%eax
80106a17:	50                   	push   %eax
80106a18:	ff 75 f4             	pushl  -0xc(%ebp)
80106a1b:	e8 7b b9 ff ff       	call   8010239b <dirlink>
80106a20:	83 c4 10             	add    $0x10,%esp
80106a23:	85 c0                	test   %eax,%eax
80106a25:	79 0d                	jns    80106a34 <create+0x1bf>
    panic("create: dirlink");
80106a27:	83 ec 0c             	sub    $0xc,%esp
80106a2a:	68 17 9a 10 80       	push   $0x80109a17
80106a2f:	e8 32 9b ff ff       	call   80100566 <panic>

  iunlockput(dp);
80106a34:	83 ec 0c             	sub    $0xc,%esp
80106a37:	ff 75 f4             	pushl  -0xc(%ebp)
80106a3a:	e8 d2 b2 ff ff       	call   80101d11 <iunlockput>
80106a3f:	83 c4 10             	add    $0x10,%esp

  return ip;
80106a42:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106a45:	c9                   	leave  
80106a46:	c3                   	ret    

80106a47 <sys_open>:

int
sys_open(void)
{
80106a47:	55                   	push   %ebp
80106a48:	89 e5                	mov    %esp,%ebp
80106a4a:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106a4d:	83 ec 08             	sub    $0x8,%esp
80106a50:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106a53:	50                   	push   %eax
80106a54:	6a 00                	push   $0x0
80106a56:	e8 eb f6 ff ff       	call   80106146 <argstr>
80106a5b:	83 c4 10             	add    $0x10,%esp
80106a5e:	85 c0                	test   %eax,%eax
80106a60:	78 15                	js     80106a77 <sys_open+0x30>
80106a62:	83 ec 08             	sub    $0x8,%esp
80106a65:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106a68:	50                   	push   %eax
80106a69:	6a 01                	push   $0x1
80106a6b:	e8 51 f6 ff ff       	call   801060c1 <argint>
80106a70:	83 c4 10             	add    $0x10,%esp
80106a73:	85 c0                	test   %eax,%eax
80106a75:	79 0a                	jns    80106a81 <sys_open+0x3a>
    return -1;
80106a77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a7c:	e9 61 01 00 00       	jmp    80106be2 <sys_open+0x19b>

  begin_op();
80106a81:	e8 d6 cb ff ff       	call   8010365c <begin_op>

  if(omode & O_CREATE){
80106a86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106a89:	25 00 02 00 00       	and    $0x200,%eax
80106a8e:	85 c0                	test   %eax,%eax
80106a90:	74 2a                	je     80106abc <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80106a92:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106a95:	6a 00                	push   $0x0
80106a97:	6a 00                	push   $0x0
80106a99:	6a 02                	push   $0x2
80106a9b:	50                   	push   %eax
80106a9c:	e8 d4 fd ff ff       	call   80106875 <create>
80106aa1:	83 c4 10             	add    $0x10,%esp
80106aa4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106aa7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106aab:	75 75                	jne    80106b22 <sys_open+0xdb>
      end_op();
80106aad:	e8 36 cc ff ff       	call   801036e8 <end_op>
      return -1;
80106ab2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ab7:	e9 26 01 00 00       	jmp    80106be2 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80106abc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106abf:	83 ec 0c             	sub    $0xc,%esp
80106ac2:	50                   	push   %eax
80106ac3:	e8 6f bb ff ff       	call   80102637 <namei>
80106ac8:	83 c4 10             	add    $0x10,%esp
80106acb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106ace:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106ad2:	75 0f                	jne    80106ae3 <sys_open+0x9c>
      end_op();
80106ad4:	e8 0f cc ff ff       	call   801036e8 <end_op>
      return -1;
80106ad9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ade:	e9 ff 00 00 00       	jmp    80106be2 <sys_open+0x19b>
    }
    ilock(ip);
80106ae3:	83 ec 0c             	sub    $0xc,%esp
80106ae6:	ff 75 f4             	pushl  -0xc(%ebp)
80106ae9:	e8 3b af ff ff       	call   80101a29 <ilock>
80106aee:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106af4:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106af8:	66 83 f8 01          	cmp    $0x1,%ax
80106afc:	75 24                	jne    80106b22 <sys_open+0xdb>
80106afe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106b01:	85 c0                	test   %eax,%eax
80106b03:	74 1d                	je     80106b22 <sys_open+0xdb>
      iunlockput(ip);
80106b05:	83 ec 0c             	sub    $0xc,%esp
80106b08:	ff 75 f4             	pushl  -0xc(%ebp)
80106b0b:	e8 01 b2 ff ff       	call   80101d11 <iunlockput>
80106b10:	83 c4 10             	add    $0x10,%esp
      end_op();
80106b13:	e8 d0 cb ff ff       	call   801036e8 <end_op>
      return -1;
80106b18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b1d:	e9 c0 00 00 00       	jmp    80106be2 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106b22:	e8 03 a5 ff ff       	call   8010102a <filealloc>
80106b27:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106b2a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106b2e:	74 17                	je     80106b47 <sys_open+0x100>
80106b30:	83 ec 0c             	sub    $0xc,%esp
80106b33:	ff 75 f0             	pushl  -0x10(%ebp)
80106b36:	e8 37 f7 ff ff       	call   80106272 <fdalloc>
80106b3b:	83 c4 10             	add    $0x10,%esp
80106b3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106b41:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106b45:	79 2e                	jns    80106b75 <sys_open+0x12e>
    if(f)
80106b47:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106b4b:	74 0e                	je     80106b5b <sys_open+0x114>
      fileclose(f);
80106b4d:	83 ec 0c             	sub    $0xc,%esp
80106b50:	ff 75 f0             	pushl  -0x10(%ebp)
80106b53:	e8 90 a5 ff ff       	call   801010e8 <fileclose>
80106b58:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106b5b:	83 ec 0c             	sub    $0xc,%esp
80106b5e:	ff 75 f4             	pushl  -0xc(%ebp)
80106b61:	e8 ab b1 ff ff       	call   80101d11 <iunlockput>
80106b66:	83 c4 10             	add    $0x10,%esp
    end_op();
80106b69:	e8 7a cb ff ff       	call   801036e8 <end_op>
    return -1;
80106b6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b73:	eb 6d                	jmp    80106be2 <sys_open+0x19b>
  }
  iunlock(ip);
80106b75:	83 ec 0c             	sub    $0xc,%esp
80106b78:	ff 75 f4             	pushl  -0xc(%ebp)
80106b7b:	e8 2f b0 ff ff       	call   80101baf <iunlock>
80106b80:	83 c4 10             	add    $0x10,%esp
  end_op();
80106b83:	e8 60 cb ff ff       	call   801036e8 <end_op>

  f->type = FD_INODE;
80106b88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b8b:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106b91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b94:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106b97:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106b9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b9d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106ba4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106ba7:	83 e0 01             	and    $0x1,%eax
80106baa:	85 c0                	test   %eax,%eax
80106bac:	0f 94 c0             	sete   %al
80106baf:	89 c2                	mov    %eax,%edx
80106bb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106bb4:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106bb7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106bba:	83 e0 01             	and    $0x1,%eax
80106bbd:	85 c0                	test   %eax,%eax
80106bbf:	75 0a                	jne    80106bcb <sys_open+0x184>
80106bc1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106bc4:	83 e0 02             	and    $0x2,%eax
80106bc7:	85 c0                	test   %eax,%eax
80106bc9:	74 07                	je     80106bd2 <sys_open+0x18b>
80106bcb:	b8 01 00 00 00       	mov    $0x1,%eax
80106bd0:	eb 05                	jmp    80106bd7 <sys_open+0x190>
80106bd2:	b8 00 00 00 00       	mov    $0x0,%eax
80106bd7:	89 c2                	mov    %eax,%edx
80106bd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106bdc:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106bdf:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106be2:	c9                   	leave  
80106be3:	c3                   	ret    

80106be4 <sys_mkdir>:

int
sys_mkdir(void)
{
80106be4:	55                   	push   %ebp
80106be5:	89 e5                	mov    %esp,%ebp
80106be7:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106bea:	e8 6d ca ff ff       	call   8010365c <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106bef:	83 ec 08             	sub    $0x8,%esp
80106bf2:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106bf5:	50                   	push   %eax
80106bf6:	6a 00                	push   $0x0
80106bf8:	e8 49 f5 ff ff       	call   80106146 <argstr>
80106bfd:	83 c4 10             	add    $0x10,%esp
80106c00:	85 c0                	test   %eax,%eax
80106c02:	78 1b                	js     80106c1f <sys_mkdir+0x3b>
80106c04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c07:	6a 00                	push   $0x0
80106c09:	6a 00                	push   $0x0
80106c0b:	6a 01                	push   $0x1
80106c0d:	50                   	push   %eax
80106c0e:	e8 62 fc ff ff       	call   80106875 <create>
80106c13:	83 c4 10             	add    $0x10,%esp
80106c16:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106c19:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c1d:	75 0c                	jne    80106c2b <sys_mkdir+0x47>
    end_op();
80106c1f:	e8 c4 ca ff ff       	call   801036e8 <end_op>
    return -1;
80106c24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c29:	eb 18                	jmp    80106c43 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106c2b:	83 ec 0c             	sub    $0xc,%esp
80106c2e:	ff 75 f4             	pushl  -0xc(%ebp)
80106c31:	e8 db b0 ff ff       	call   80101d11 <iunlockput>
80106c36:	83 c4 10             	add    $0x10,%esp
  end_op();
80106c39:	e8 aa ca ff ff       	call   801036e8 <end_op>
  return 0;
80106c3e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106c43:	c9                   	leave  
80106c44:	c3                   	ret    

80106c45 <sys_mknod>:

int
sys_mknod(void)
{
80106c45:	55                   	push   %ebp
80106c46:	89 e5                	mov    %esp,%ebp
80106c48:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;

  begin_op();
80106c4b:	e8 0c ca ff ff       	call   8010365c <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106c50:	83 ec 08             	sub    $0x8,%esp
80106c53:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106c56:	50                   	push   %eax
80106c57:	6a 00                	push   $0x0
80106c59:	e8 e8 f4 ff ff       	call   80106146 <argstr>
80106c5e:	83 c4 10             	add    $0x10,%esp
80106c61:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106c64:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c68:	78 4f                	js     80106cb9 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80106c6a:	83 ec 08             	sub    $0x8,%esp
80106c6d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106c70:	50                   	push   %eax
80106c71:	6a 01                	push   $0x1
80106c73:	e8 49 f4 ff ff       	call   801060c1 <argint>
80106c78:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;

  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106c7b:	85 c0                	test   %eax,%eax
80106c7d:	78 3a                	js     80106cb9 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106c7f:	83 ec 08             	sub    $0x8,%esp
80106c82:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106c85:	50                   	push   %eax
80106c86:	6a 02                	push   $0x2
80106c88:	e8 34 f4 ff ff       	call   801060c1 <argint>
80106c8d:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;

  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106c90:	85 c0                	test   %eax,%eax
80106c92:	78 25                	js     80106cb9 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106c94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c97:	0f bf c8             	movswl %ax,%ecx
80106c9a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106c9d:	0f bf d0             	movswl %ax,%edx
80106ca0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;

  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106ca3:	51                   	push   %ecx
80106ca4:	52                   	push   %edx
80106ca5:	6a 03                	push   $0x3
80106ca7:	50                   	push   %eax
80106ca8:	e8 c8 fb ff ff       	call   80106875 <create>
80106cad:	83 c4 10             	add    $0x10,%esp
80106cb0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106cb3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106cb7:	75 0c                	jne    80106cc5 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106cb9:	e8 2a ca ff ff       	call   801036e8 <end_op>
    return -1;
80106cbe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cc3:	eb 18                	jmp    80106cdd <sys_mknod+0x98>
  }
  iunlockput(ip);
80106cc5:	83 ec 0c             	sub    $0xc,%esp
80106cc8:	ff 75 f0             	pushl  -0x10(%ebp)
80106ccb:	e8 41 b0 ff ff       	call   80101d11 <iunlockput>
80106cd0:	83 c4 10             	add    $0x10,%esp
  end_op();
80106cd3:	e8 10 ca ff ff       	call   801036e8 <end_op>
  return 0;
80106cd8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106cdd:	c9                   	leave  
80106cde:	c3                   	ret    

80106cdf <sys_chdir>:

int
sys_chdir(void)
{
80106cdf:	55                   	push   %ebp
80106ce0:	89 e5                	mov    %esp,%ebp
80106ce2:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106ce5:	e8 72 c9 ff ff       	call   8010365c <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106cea:	83 ec 08             	sub    $0x8,%esp
80106ced:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106cf0:	50                   	push   %eax
80106cf1:	6a 00                	push   $0x0
80106cf3:	e8 4e f4 ff ff       	call   80106146 <argstr>
80106cf8:	83 c4 10             	add    $0x10,%esp
80106cfb:	85 c0                	test   %eax,%eax
80106cfd:	78 18                	js     80106d17 <sys_chdir+0x38>
80106cff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d02:	83 ec 0c             	sub    $0xc,%esp
80106d05:	50                   	push   %eax
80106d06:	e8 2c b9 ff ff       	call   80102637 <namei>
80106d0b:	83 c4 10             	add    $0x10,%esp
80106d0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106d11:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106d15:	75 0c                	jne    80106d23 <sys_chdir+0x44>
    end_op();
80106d17:	e8 cc c9 ff ff       	call   801036e8 <end_op>
    return -1;
80106d1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d21:	eb 6e                	jmp    80106d91 <sys_chdir+0xb2>
  }
  ilock(ip);
80106d23:	83 ec 0c             	sub    $0xc,%esp
80106d26:	ff 75 f4             	pushl  -0xc(%ebp)
80106d29:	e8 fb ac ff ff       	call   80101a29 <ilock>
80106d2e:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106d31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d34:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106d38:	66 83 f8 01          	cmp    $0x1,%ax
80106d3c:	74 1a                	je     80106d58 <sys_chdir+0x79>
    iunlockput(ip);
80106d3e:	83 ec 0c             	sub    $0xc,%esp
80106d41:	ff 75 f4             	pushl  -0xc(%ebp)
80106d44:	e8 c8 af ff ff       	call   80101d11 <iunlockput>
80106d49:	83 c4 10             	add    $0x10,%esp
    end_op();
80106d4c:	e8 97 c9 ff ff       	call   801036e8 <end_op>
    return -1;
80106d51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d56:	eb 39                	jmp    80106d91 <sys_chdir+0xb2>
  }
  iunlock(ip);
80106d58:	83 ec 0c             	sub    $0xc,%esp
80106d5b:	ff 75 f4             	pushl  -0xc(%ebp)
80106d5e:	e8 4c ae ff ff       	call   80101baf <iunlock>
80106d63:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80106d66:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d6c:	8b 40 68             	mov    0x68(%eax),%eax
80106d6f:	83 ec 0c             	sub    $0xc,%esp
80106d72:	50                   	push   %eax
80106d73:	e8 a9 ae ff ff       	call   80101c21 <iput>
80106d78:	83 c4 10             	add    $0x10,%esp
  end_op();
80106d7b:	e8 68 c9 ff ff       	call   801036e8 <end_op>
  proc->cwd = ip;
80106d80:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d86:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106d89:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106d8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106d91:	c9                   	leave  
80106d92:	c3                   	ret    

80106d93 <sys_exec>:

int
sys_exec(void)
{
80106d93:	55                   	push   %ebp
80106d94:	89 e5                	mov    %esp,%ebp
80106d96:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106d9c:	83 ec 08             	sub    $0x8,%esp
80106d9f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106da2:	50                   	push   %eax
80106da3:	6a 00                	push   $0x0
80106da5:	e8 9c f3 ff ff       	call   80106146 <argstr>
80106daa:	83 c4 10             	add    $0x10,%esp
80106dad:	85 c0                	test   %eax,%eax
80106daf:	78 18                	js     80106dc9 <sys_exec+0x36>
80106db1:	83 ec 08             	sub    $0x8,%esp
80106db4:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106dba:	50                   	push   %eax
80106dbb:	6a 01                	push   $0x1
80106dbd:	e8 ff f2 ff ff       	call   801060c1 <argint>
80106dc2:	83 c4 10             	add    $0x10,%esp
80106dc5:	85 c0                	test   %eax,%eax
80106dc7:	79 0a                	jns    80106dd3 <sys_exec+0x40>
    return -1;
80106dc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106dce:	e9 c6 00 00 00       	jmp    80106e99 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106dd3:	83 ec 04             	sub    $0x4,%esp
80106dd6:	68 80 00 00 00       	push   $0x80
80106ddb:	6a 00                	push   $0x0
80106ddd:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106de3:	50                   	push   %eax
80106de4:	e8 b3 ef ff ff       	call   80105d9c <memset>
80106de9:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106dec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106df3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106df6:	83 f8 1f             	cmp    $0x1f,%eax
80106df9:	76 0a                	jbe    80106e05 <sys_exec+0x72>
      return -1;
80106dfb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e00:	e9 94 00 00 00       	jmp    80106e99 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106e05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e08:	c1 e0 02             	shl    $0x2,%eax
80106e0b:	89 c2                	mov    %eax,%edx
80106e0d:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106e13:	01 c2                	add    %eax,%edx
80106e15:	83 ec 08             	sub    $0x8,%esp
80106e18:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106e1e:	50                   	push   %eax
80106e1f:	52                   	push   %edx
80106e20:	e8 00 f2 ff ff       	call   80106025 <fetchint>
80106e25:	83 c4 10             	add    $0x10,%esp
80106e28:	85 c0                	test   %eax,%eax
80106e2a:	79 07                	jns    80106e33 <sys_exec+0xa0>
      return -1;
80106e2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e31:	eb 66                	jmp    80106e99 <sys_exec+0x106>
    if(uarg == 0){
80106e33:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106e39:	85 c0                	test   %eax,%eax
80106e3b:	75 27                	jne    80106e64 <sys_exec+0xd1>
      argv[i] = 0;
80106e3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e40:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106e47:	00 00 00 00 
      break;
80106e4b:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106e4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106e4f:	83 ec 08             	sub    $0x8,%esp
80106e52:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106e58:	52                   	push   %edx
80106e59:	50                   	push   %eax
80106e5a:	e8 12 9d ff ff       	call   80100b71 <exec>
80106e5f:	83 c4 10             	add    $0x10,%esp
80106e62:	eb 35                	jmp    80106e99 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106e64:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106e6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106e6d:	c1 e2 02             	shl    $0x2,%edx
80106e70:	01 c2                	add    %eax,%edx
80106e72:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106e78:	83 ec 08             	sub    $0x8,%esp
80106e7b:	52                   	push   %edx
80106e7c:	50                   	push   %eax
80106e7d:	e8 dd f1 ff ff       	call   8010605f <fetchstr>
80106e82:	83 c4 10             	add    $0x10,%esp
80106e85:	85 c0                	test   %eax,%eax
80106e87:	79 07                	jns    80106e90 <sys_exec+0xfd>
      return -1;
80106e89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e8e:	eb 09                	jmp    80106e99 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106e90:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106e94:	e9 5a ff ff ff       	jmp    80106df3 <sys_exec+0x60>
  return exec(path, argv);
}
80106e99:	c9                   	leave  
80106e9a:	c3                   	ret    

80106e9b <sys_pipe>:

int
sys_pipe(void)
{
80106e9b:	55                   	push   %ebp
80106e9c:	89 e5                	mov    %esp,%ebp
80106e9e:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106ea1:	83 ec 04             	sub    $0x4,%esp
80106ea4:	6a 08                	push   $0x8
80106ea6:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106ea9:	50                   	push   %eax
80106eaa:	6a 00                	push   $0x0
80106eac:	e8 38 f2 ff ff       	call   801060e9 <argptr>
80106eb1:	83 c4 10             	add    $0x10,%esp
80106eb4:	85 c0                	test   %eax,%eax
80106eb6:	79 0a                	jns    80106ec2 <sys_pipe+0x27>
    return -1;
80106eb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ebd:	e9 af 00 00 00       	jmp    80106f71 <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80106ec2:	83 ec 08             	sub    $0x8,%esp
80106ec5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106ec8:	50                   	push   %eax
80106ec9:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106ecc:	50                   	push   %eax
80106ecd:	e8 7e d2 ff ff       	call   80104150 <pipealloc>
80106ed2:	83 c4 10             	add    $0x10,%esp
80106ed5:	85 c0                	test   %eax,%eax
80106ed7:	79 0a                	jns    80106ee3 <sys_pipe+0x48>
    return -1;
80106ed9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ede:	e9 8e 00 00 00       	jmp    80106f71 <sys_pipe+0xd6>
  fd0 = -1;
80106ee3:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106eea:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106eed:	83 ec 0c             	sub    $0xc,%esp
80106ef0:	50                   	push   %eax
80106ef1:	e8 7c f3 ff ff       	call   80106272 <fdalloc>
80106ef6:	83 c4 10             	add    $0x10,%esp
80106ef9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106efc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106f00:	78 18                	js     80106f1a <sys_pipe+0x7f>
80106f02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106f05:	83 ec 0c             	sub    $0xc,%esp
80106f08:	50                   	push   %eax
80106f09:	e8 64 f3 ff ff       	call   80106272 <fdalloc>
80106f0e:	83 c4 10             	add    $0x10,%esp
80106f11:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106f14:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106f18:	79 3f                	jns    80106f59 <sys_pipe+0xbe>
    if(fd0 >= 0)
80106f1a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106f1e:	78 14                	js     80106f34 <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80106f20:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f26:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106f29:	83 c2 08             	add    $0x8,%edx
80106f2c:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106f33:	00 
    fileclose(rf);
80106f34:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106f37:	83 ec 0c             	sub    $0xc,%esp
80106f3a:	50                   	push   %eax
80106f3b:	e8 a8 a1 ff ff       	call   801010e8 <fileclose>
80106f40:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106f43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106f46:	83 ec 0c             	sub    $0xc,%esp
80106f49:	50                   	push   %eax
80106f4a:	e8 99 a1 ff ff       	call   801010e8 <fileclose>
80106f4f:	83 c4 10             	add    $0x10,%esp
    return -1;
80106f52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f57:	eb 18                	jmp    80106f71 <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80106f59:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106f5c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106f5f:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106f61:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106f64:	8d 50 04             	lea    0x4(%eax),%edx
80106f67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f6a:	89 02                	mov    %eax,(%edx)
  return 0;
80106f6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106f71:	c9                   	leave  
80106f72:	c3                   	ret    

80106f73 <sys_chmod>:

#ifdef CS333_P5
int
sys_chmod(void)
{
80106f73:	55                   	push   %ebp
80106f74:	89 e5                	mov    %esp,%ebp
80106f76:	83 ec 18             	sub    $0x18,%esp
  char *pathname;
  int mode;
  struct inode *ip;

  begin_op();
80106f79:	e8 de c6 ff ff       	call   8010365c <begin_op>
  if(argstr(0, &pathname)<0 || argint(1, &mode) <0)
80106f7e:	83 ec 08             	sub    $0x8,%esp
80106f81:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106f84:	50                   	push   %eax
80106f85:	6a 00                	push   $0x0
80106f87:	e8 ba f1 ff ff       	call   80106146 <argstr>
80106f8c:	83 c4 10             	add    $0x10,%esp
80106f8f:	85 c0                	test   %eax,%eax
80106f91:	78 15                	js     80106fa8 <sys_chmod+0x35>
80106f93:	83 ec 08             	sub    $0x8,%esp
80106f96:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106f99:	50                   	push   %eax
80106f9a:	6a 01                	push   $0x1
80106f9c:	e8 20 f1 ff ff       	call   801060c1 <argint>
80106fa1:	83 c4 10             	add    $0x10,%esp
80106fa4:	85 c0                	test   %eax,%eax
80106fa6:	79 0f                	jns    80106fb7 <sys_chmod+0x44>
  {
    end_op();
80106fa8:	e8 3b c7 ff ff       	call   801036e8 <end_op>
    return -1;
80106fad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fb2:	e9 80 00 00 00       	jmp    80107037 <sys_chmod+0xc4>
  }

  //Check to make sure max isn't too small or too large.
  if(mode < 0000 || mode > 1777)
80106fb7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106fba:	85 c0                	test   %eax,%eax
80106fbc:	78 0a                	js     80106fc8 <sys_chmod+0x55>
80106fbe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106fc1:	3d f1 06 00 00       	cmp    $0x6f1,%eax
80106fc6:	7e 0c                	jle    80106fd4 <sys_chmod+0x61>
  {
    end_op();
80106fc8:	e8 1b c7 ff ff       	call   801036e8 <end_op>
    return -1;
80106fcd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fd2:	eb 63                	jmp    80107037 <sys_chmod+0xc4>
  }

  //Check if path exists
  if((ip = namei(pathname)) == 0)
80106fd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106fd7:	83 ec 0c             	sub    $0xc,%esp
80106fda:	50                   	push   %eax
80106fdb:	e8 57 b6 ff ff       	call   80102637 <namei>
80106fe0:	83 c4 10             	add    $0x10,%esp
80106fe3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106fe6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106fea:	75 0c                	jne    80106ff8 <sys_chmod+0x85>
  {
    end_op();
80106fec:	e8 f7 c6 ff ff       	call   801036e8 <end_op>
    return -1;
80106ff1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ff6:	eb 3f                	jmp    80107037 <sys_chmod+0xc4>
  }
  ilock(ip);
80106ff8:	83 ec 0c             	sub    $0xc,%esp
80106ffb:	ff 75 f4             	pushl  -0xc(%ebp)
80106ffe:	e8 26 aa ff ff       	call   80101a29 <ilock>
80107003:	83 c4 10             	add    $0x10,%esp
  ip->mode.asInt = mode;
80107006:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107009:	89 c2                	mov    %eax,%edx
8010700b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010700e:	89 50 1c             	mov    %edx,0x1c(%eax)
  iupdate(ip);
80107011:	83 ec 0c             	sub    $0xc,%esp
80107014:	ff 75 f4             	pushl  -0xc(%ebp)
80107017:	e8 0b a8 ff ff       	call   80101827 <iupdate>
8010701c:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010701f:	83 ec 0c             	sub    $0xc,%esp
80107022:	ff 75 f4             	pushl  -0xc(%ebp)
80107025:	e8 e7 ac ff ff       	call   80101d11 <iunlockput>
8010702a:	83 c4 10             	add    $0x10,%esp
  end_op();
8010702d:	e8 b6 c6 ff ff       	call   801036e8 <end_op>
  return 0;
80107032:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107037:	c9                   	leave  
80107038:	c3                   	ret    

80107039 <sys_chown>:

int
sys_chown(void)
{
80107039:	55                   	push   %ebp
8010703a:	89 e5                	mov    %esp,%ebp
8010703c:	83 ec 18             	sub    $0x18,%esp
  char *pathname;
  int uid;
  struct inode *ip;

  begin_op();
8010703f:	e8 18 c6 ff ff       	call   8010365c <begin_op>
  if(argstr(0, &pathname)<0 || argint(1, &uid) <0)
80107044:	83 ec 08             	sub    $0x8,%esp
80107047:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010704a:	50                   	push   %eax
8010704b:	6a 00                	push   $0x0
8010704d:	e8 f4 f0 ff ff       	call   80106146 <argstr>
80107052:	83 c4 10             	add    $0x10,%esp
80107055:	85 c0                	test   %eax,%eax
80107057:	78 15                	js     8010706e <sys_chown+0x35>
80107059:	83 ec 08             	sub    $0x8,%esp
8010705c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010705f:	50                   	push   %eax
80107060:	6a 01                	push   $0x1
80107062:	e8 5a f0 ff ff       	call   801060c1 <argint>
80107067:	83 c4 10             	add    $0x10,%esp
8010706a:	85 c0                	test   %eax,%eax
8010706c:	79 0f                	jns    8010707d <sys_chown+0x44>
  {
    end_op();
8010706e:	e8 75 c6 ff ff       	call   801036e8 <end_op>
    return -1;
80107073:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107078:	e9 81 00 00 00       	jmp    801070fe <sys_chown+0xc5>
  }
  //Check to make sure its within the bounds of UID 0 <= uid <= 32767
  if(uid < 0 || uid > 32767)
8010707d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107080:	85 c0                	test   %eax,%eax
80107082:	78 0a                	js     8010708e <sys_chown+0x55>
80107084:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107087:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
8010708c:	7e 0c                	jle    8010709a <sys_chown+0x61>
  {
    end_op();
8010708e:	e8 55 c6 ff ff       	call   801036e8 <end_op>
    return -1;
80107093:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107098:	eb 64                	jmp    801070fe <sys_chown+0xc5>
  }

  //Check if path exists
  if((ip= namei(pathname)) == 0)
8010709a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010709d:	83 ec 0c             	sub    $0xc,%esp
801070a0:	50                   	push   %eax
801070a1:	e8 91 b5 ff ff       	call   80102637 <namei>
801070a6:	83 c4 10             	add    $0x10,%esp
801070a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801070ac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801070b0:	75 0c                	jne    801070be <sys_chown+0x85>
  {
    end_op();
801070b2:	e8 31 c6 ff ff       	call   801036e8 <end_op>
    return -1;
801070b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070bc:	eb 40                	jmp    801070fe <sys_chown+0xc5>
  }
  ilock(ip);
801070be:	83 ec 0c             	sub    $0xc,%esp
801070c1:	ff 75 f4             	pushl  -0xc(%ebp)
801070c4:	e8 60 a9 ff ff       	call   80101a29 <ilock>
801070c9:	83 c4 10             	add    $0x10,%esp
  ip->uid = uid;
801070cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801070cf:	89 c2                	mov    %eax,%edx
801070d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070d4:	66 89 50 18          	mov    %dx,0x18(%eax)
  iupdate(ip);
801070d8:	83 ec 0c             	sub    $0xc,%esp
801070db:	ff 75 f4             	pushl  -0xc(%ebp)
801070de:	e8 44 a7 ff ff       	call   80101827 <iupdate>
801070e3:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801070e6:	83 ec 0c             	sub    $0xc,%esp
801070e9:	ff 75 f4             	pushl  -0xc(%ebp)
801070ec:	e8 20 ac ff ff       	call   80101d11 <iunlockput>
801070f1:	83 c4 10             	add    $0x10,%esp
  end_op();
801070f4:	e8 ef c5 ff ff       	call   801036e8 <end_op>
  return 0;
801070f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801070fe:	c9                   	leave  
801070ff:	c3                   	ret    

80107100 <sys_chgrp>:

int
sys_chgrp(void)
{
80107100:	55                   	push   %ebp
80107101:	89 e5                	mov    %esp,%ebp
80107103:	83 ec 18             	sub    $0x18,%esp
  char *pathname;
  int gid;
  struct inode *ip;

  begin_op();
80107106:	e8 51 c5 ff ff       	call   8010365c <begin_op>
  if(argstr(0, &pathname)<0 || argint(1, &gid) <0)
8010710b:	83 ec 08             	sub    $0x8,%esp
8010710e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107111:	50                   	push   %eax
80107112:	6a 00                	push   $0x0
80107114:	e8 2d f0 ff ff       	call   80106146 <argstr>
80107119:	83 c4 10             	add    $0x10,%esp
8010711c:	85 c0                	test   %eax,%eax
8010711e:	78 15                	js     80107135 <sys_chgrp+0x35>
80107120:	83 ec 08             	sub    $0x8,%esp
80107123:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107126:	50                   	push   %eax
80107127:	6a 01                	push   $0x1
80107129:	e8 93 ef ff ff       	call   801060c1 <argint>
8010712e:	83 c4 10             	add    $0x10,%esp
80107131:	85 c0                	test   %eax,%eax
80107133:	79 0f                	jns    80107144 <sys_chgrp+0x44>
  {
    end_op();
80107135:	e8 ae c5 ff ff       	call   801036e8 <end_op>
    return -1;
8010713a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010713f:	e9 81 00 00 00       	jmp    801071c5 <sys_chgrp+0xc5>
  }
  //Check to make sure its within the bounds of GID 0 <= id <= 32767
  if(gid < 0 || gid > 32767)
80107144:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107147:	85 c0                	test   %eax,%eax
80107149:	78 0a                	js     80107155 <sys_chgrp+0x55>
8010714b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010714e:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
80107153:	7e 0c                	jle    80107161 <sys_chgrp+0x61>
  {
    end_op();
80107155:	e8 8e c5 ff ff       	call   801036e8 <end_op>
    return -1;
8010715a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010715f:	eb 64                	jmp    801071c5 <sys_chgrp+0xc5>
  }

  //Check if path exists
  if((ip= namei(pathname)) == 0)
80107161:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107164:	83 ec 0c             	sub    $0xc,%esp
80107167:	50                   	push   %eax
80107168:	e8 ca b4 ff ff       	call   80102637 <namei>
8010716d:	83 c4 10             	add    $0x10,%esp
80107170:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107173:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107177:	75 0c                	jne    80107185 <sys_chgrp+0x85>
  {
    end_op();
80107179:	e8 6a c5 ff ff       	call   801036e8 <end_op>
    return -1;
8010717e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107183:	eb 40                	jmp    801071c5 <sys_chgrp+0xc5>
  }
  ilock(ip);
80107185:	83 ec 0c             	sub    $0xc,%esp
80107188:	ff 75 f4             	pushl  -0xc(%ebp)
8010718b:	e8 99 a8 ff ff       	call   80101a29 <ilock>
80107190:	83 c4 10             	add    $0x10,%esp
  ip->gid = gid;
80107193:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107196:	89 c2                	mov    %eax,%edx
80107198:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010719b:	66 89 50 1a          	mov    %dx,0x1a(%eax)
  iupdate(ip);
8010719f:	83 ec 0c             	sub    $0xc,%esp
801071a2:	ff 75 f4             	pushl  -0xc(%ebp)
801071a5:	e8 7d a6 ff ff       	call   80101827 <iupdate>
801071aa:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801071ad:	83 ec 0c             	sub    $0xc,%esp
801071b0:	ff 75 f4             	pushl  -0xc(%ebp)
801071b3:	e8 59 ab ff ff       	call   80101d11 <iunlockput>
801071b8:	83 c4 10             	add    $0x10,%esp
  end_op();
801071bb:	e8 28 c5 ff ff       	call   801036e8 <end_op>
  return 0;
801071c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801071c5:	c9                   	leave  
801071c6:	c3                   	ret    

801071c7 <outw>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outw(ushort port, ushort data)
{
801071c7:	55                   	push   %ebp
801071c8:	89 e5                	mov    %esp,%ebp
801071ca:	83 ec 08             	sub    $0x8,%esp
801071cd:	8b 55 08             	mov    0x8(%ebp),%edx
801071d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801071d3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801071d7:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801071db:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
801071df:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801071e3:	66 ef                	out    %ax,(%dx)
}
801071e5:	90                   	nop
801071e6:	c9                   	leave  
801071e7:	c3                   	ret    

801071e8 <sys_fork>:
#include "proc.h"
#include "uproc.h"

int
sys_fork(void)
{
801071e8:	55                   	push   %ebp
801071e9:	89 e5                	mov    %esp,%ebp
801071eb:	83 ec 08             	sub    $0x8,%esp
  return fork();
801071ee:	e8 d3 d6 ff ff       	call   801048c6 <fork>
}
801071f3:	c9                   	leave  
801071f4:	c3                   	ret    

801071f5 <sys_exit>:

int
sys_exit(void)
{
801071f5:	55                   	push   %ebp
801071f6:	89 e5                	mov    %esp,%ebp
801071f8:	83 ec 08             	sub    $0x8,%esp
  exit();
801071fb:	e8 81 d8 ff ff       	call   80104a81 <exit>
  return 0;  // not reached
80107200:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107205:	c9                   	leave  
80107206:	c3                   	ret    

80107207 <sys_wait>:

int
sys_wait(void)
{
80107207:	55                   	push   %ebp
80107208:	89 e5                	mov    %esp,%ebp
8010720a:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010720d:	e8 aa d9 ff ff       	call   80104bbc <wait>
}
80107212:	c9                   	leave  
80107213:	c3                   	ret    

80107214 <sys_kill>:

int
sys_kill(void)
{
80107214:	55                   	push   %ebp
80107215:	89 e5                	mov    %esp,%ebp
80107217:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010721a:	83 ec 08             	sub    $0x8,%esp
8010721d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107220:	50                   	push   %eax
80107221:	6a 00                	push   $0x0
80107223:	e8 99 ee ff ff       	call   801060c1 <argint>
80107228:	83 c4 10             	add    $0x10,%esp
8010722b:	85 c0                	test   %eax,%eax
8010722d:	79 07                	jns    80107236 <sys_kill+0x22>
    return -1;
8010722f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107234:	eb 0f                	jmp    80107245 <sys_kill+0x31>
  return kill(pid);
80107236:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107239:	83 ec 0c             	sub    $0xc,%esp
8010723c:	50                   	push   %eax
8010723d:	e8 1e de ff ff       	call   80105060 <kill>
80107242:	83 c4 10             	add    $0x10,%esp
}
80107245:	c9                   	leave  
80107246:	c3                   	ret    

80107247 <sys_getpid>:

int
sys_getpid(void)
{
80107247:	55                   	push   %ebp
80107248:	89 e5                	mov    %esp,%ebp
  return proc->pid;
8010724a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107250:	8b 40 10             	mov    0x10(%eax),%eax
}
80107253:	5d                   	pop    %ebp
80107254:	c3                   	ret    

80107255 <sys_sbrk>:

int
sys_sbrk(void)
{
80107255:	55                   	push   %ebp
80107256:	89 e5                	mov    %esp,%ebp
80107258:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010725b:	83 ec 08             	sub    $0x8,%esp
8010725e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107261:	50                   	push   %eax
80107262:	6a 00                	push   $0x0
80107264:	e8 58 ee ff ff       	call   801060c1 <argint>
80107269:	83 c4 10             	add    $0x10,%esp
8010726c:	85 c0                	test   %eax,%eax
8010726e:	79 07                	jns    80107277 <sys_sbrk+0x22>
    return -1;
80107270:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107275:	eb 28                	jmp    8010729f <sys_sbrk+0x4a>
  addr = proc->sz;
80107277:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010727d:	8b 00                	mov    (%eax),%eax
8010727f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80107282:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107285:	83 ec 0c             	sub    $0xc,%esp
80107288:	50                   	push   %eax
80107289:	e8 95 d5 ff ff       	call   80104823 <growproc>
8010728e:	83 c4 10             	add    $0x10,%esp
80107291:	85 c0                	test   %eax,%eax
80107293:	79 07                	jns    8010729c <sys_sbrk+0x47>
    return -1;
80107295:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010729a:	eb 03                	jmp    8010729f <sys_sbrk+0x4a>
  return addr;
8010729c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010729f:	c9                   	leave  
801072a0:	c3                   	ret    

801072a1 <sys_sleep>:

int
sys_sleep(void)
{
801072a1:	55                   	push   %ebp
801072a2:	89 e5                	mov    %esp,%ebp
801072a4:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801072a7:	83 ec 08             	sub    $0x8,%esp
801072aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
801072ad:	50                   	push   %eax
801072ae:	6a 00                	push   $0x0
801072b0:	e8 0c ee ff ff       	call   801060c1 <argint>
801072b5:	83 c4 10             	add    $0x10,%esp
801072b8:	85 c0                	test   %eax,%eax
801072ba:	79 07                	jns    801072c3 <sys_sleep+0x22>
    return -1;
801072bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072c1:	eb 44                	jmp    80107307 <sys_sleep+0x66>
  ticks0 = ticks;
801072c3:	a1 40 69 11 80       	mov    0x80116940,%eax
801072c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801072cb:	eb 26                	jmp    801072f3 <sys_sleep+0x52>
    if(proc->killed){
801072cd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801072d3:	8b 40 24             	mov    0x24(%eax),%eax
801072d6:	85 c0                	test   %eax,%eax
801072d8:	74 07                	je     801072e1 <sys_sleep+0x40>
      return -1;
801072da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072df:	eb 26                	jmp    80107307 <sys_sleep+0x66>
    }
    sleep(&ticks, (struct spinlock *)0);
801072e1:	83 ec 08             	sub    $0x8,%esp
801072e4:	6a 00                	push   $0x0
801072e6:	68 40 69 11 80       	push   $0x80116940
801072eb:	e8 52 dc ff ff       	call   80104f42 <sleep>
801072f0:	83 c4 10             	add    $0x10,%esp
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801072f3:	a1 40 69 11 80       	mov    0x80116940,%eax
801072f8:	2b 45 f4             	sub    -0xc(%ebp),%eax
801072fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801072fe:	39 d0                	cmp    %edx,%eax
80107300:	72 cb                	jb     801072cd <sys_sleep+0x2c>
    if(proc->killed){
      return -1;
    }
    sleep(&ticks, (struct spinlock *)0);
  }
  return 0;
80107302:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107307:	c9                   	leave  
80107308:	c3                   	ret    

80107309 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80107309:	55                   	push   %ebp
8010730a:	89 e5                	mov    %esp,%ebp
8010730c:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  xticks = ticks;
8010730f:	a1 40 69 11 80       	mov    0x80116940,%eax
80107314:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return xticks;
80107317:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010731a:	c9                   	leave  
8010731b:	c3                   	ret    

8010731c <sys_halt>:

//Turn of the computer
int
sys_halt(void){
8010731c:	55                   	push   %ebp
8010731d:	89 e5                	mov    %esp,%ebp
8010731f:	83 ec 08             	sub    $0x8,%esp
  cprintf("Shutting down ...\n");
80107322:	83 ec 0c             	sub    $0xc,%esp
80107325:	68 27 9a 10 80       	push   $0x80109a27
8010732a:	e8 97 90 ff ff       	call   801003c6 <cprintf>
8010732f:	83 c4 10             	add    $0x10,%esp
  outw( 0x604, 0x0 | 0x2000);
80107332:	83 ec 08             	sub    $0x8,%esp
80107335:	68 00 20 00 00       	push   $0x2000
8010733a:	68 04 06 00 00       	push   $0x604
8010733f:	e8 83 fe ff ff       	call   801071c7 <outw>
80107344:	83 c4 10             	add    $0x10,%esp
  return 0;
80107347:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010734c:	c9                   	leave  
8010734d:	c3                   	ret    

8010734e <sys_date>:


int
sys_date(void)
{
8010734e:	55                   	push   %ebp
8010734f:	89 e5                	mov    %esp,%ebp
80107351:	83 ec 18             	sub    $0x18,%esp
  struct rtcdate *d;
  if(argptr(0, (void*)&d, sizeof(struct rtcdate)) < 0)
80107354:	83 ec 04             	sub    $0x4,%esp
80107357:	6a 18                	push   $0x18
80107359:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010735c:	50                   	push   %eax
8010735d:	6a 00                	push   $0x0
8010735f:	e8 85 ed ff ff       	call   801060e9 <argptr>
80107364:	83 c4 10             	add    $0x10,%esp
80107367:	85 c0                	test   %eax,%eax
80107369:	79 07                	jns    80107372 <sys_date+0x24>
    return -1;
8010736b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107370:	eb 14                	jmp    80107386 <sys_date+0x38>
  cmostime(d);
80107372:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107375:	83 ec 0c             	sub    $0xc,%esp
80107378:	50                   	push   %eax
80107379:	e8 59 bf ff ff       	call   801032d7 <cmostime>
8010737e:	83 c4 10             	add    $0x10,%esp
  return 0;
80107381:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107386:	c9                   	leave  
80107387:	c3                   	ret    

80107388 <sys_getuid>:

//Get uid
uint
sys_getuid(void)
{
80107388:	55                   	push   %ebp
80107389:	89 e5                	mov    %esp,%ebp
  return proc->uid;
8010738b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107391:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
80107397:	5d                   	pop    %ebp
80107398:	c3                   	ret    

80107399 <sys_getgid>:

//Get gid
uint
sys_getgid(void)
{
80107399:	55                   	push   %ebp
8010739a:	89 e5                	mov    %esp,%ebp
  return proc->gid;
8010739c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073a2:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
}
801073a8:	5d                   	pop    %ebp
801073a9:	c3                   	ret    

801073aa <sys_getppid>:

//Returns init's pid, since it has no parent.
//Or returns the parents pid.
uint
sys_getppid(void)
{
801073aa:	55                   	push   %ebp
801073ab:	89 e5                	mov    %esp,%ebp
  if(proc->parent != 0)
801073ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073b3:	8b 40 14             	mov    0x14(%eax),%eax
801073b6:	85 c0                	test   %eax,%eax
801073b8:	74 0e                	je     801073c8 <sys_getppid+0x1e>
    return proc->parent->pid;
801073ba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073c0:	8b 40 14             	mov    0x14(%eax),%eax
801073c3:	8b 40 10             	mov    0x10(%eax),%eax
801073c6:	eb 09                	jmp    801073d1 <sys_getppid+0x27>
  return proc->pid;
801073c8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073ce:	8b 40 10             	mov    0x10(%eax),%eax
}
801073d1:	5d                   	pop    %ebp
801073d2:	c3                   	ret    

801073d3 <sys_setuid>:

//Sets the uid after making sure that the argument
//is within the bounds 0<=32767
int
sys_setuid(void)
{
801073d3:	55                   	push   %ebp
801073d4:	89 e5                	mov    %esp,%ebp
801073d6:	83 ec 18             	sub    $0x18,%esp
  int _uid;
  argint(0, (int*)&_uid);
801073d9:	83 ec 08             	sub    $0x8,%esp
801073dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
801073df:	50                   	push   %eax
801073e0:	6a 00                	push   $0x0
801073e2:	e8 da ec ff ff       	call   801060c1 <argint>
801073e7:	83 c4 10             	add    $0x10,%esp
  if (_uid>= 0 && _uid<= 32767)
801073ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073ed:	85 c0                	test   %eax,%eax
801073ef:	78 20                	js     80107411 <sys_setuid+0x3e>
801073f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073f4:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
801073f9:	7f 16                	jg     80107411 <sys_setuid+0x3e>
  {
    proc->uid = _uid;
801073fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107401:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107404:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
    return 0;
8010740a:	b8 00 00 00 00       	mov    $0x0,%eax
8010740f:	eb 05                	jmp    80107416 <sys_setuid+0x43>
  }
  return -1;
80107411:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107416:	c9                   	leave  
80107417:	c3                   	ret    

80107418 <sys_setgid>:
//Sets the gid after making sure that the argument
//is within the bouds 0<=32767
int
sys_setgid(void)
{
80107418:	55                   	push   %ebp
80107419:	89 e5                	mov    %esp,%ebp
8010741b:	83 ec 18             	sub    $0x18,%esp
  int _gid;
  argint(0, &_gid);
8010741e:	83 ec 08             	sub    $0x8,%esp
80107421:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107424:	50                   	push   %eax
80107425:	6a 00                	push   $0x0
80107427:	e8 95 ec ff ff       	call   801060c1 <argint>
8010742c:	83 c4 10             	add    $0x10,%esp
  if (_gid>= 0 && _gid<= 32767)
8010742f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107432:	85 c0                	test   %eax,%eax
80107434:	78 20                	js     80107456 <sys_setgid+0x3e>
80107436:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107439:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
8010743e:	7f 16                	jg     80107456 <sys_setgid+0x3e>
  {
    proc->gid = _gid;
80107440:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107446:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107449:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
    return 0;
8010744f:	b8 00 00 00 00       	mov    $0x0,%eax
80107454:	eb 05                	jmp    8010745b <sys_setgid+0x43>
  }
  return -1;
80107456:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010745b:	c9                   	leave  
8010745c:	c3                   	ret    

8010745d <sys_getprocs>:

//Getprocs calls getprocs in proc.c in order to lock the ptable and
//grab all the processes off of that when ps is called.
int
sys_getprocs(int max, struct uproc* table)
{
8010745d:	55                   	push   %ebp
8010745e:	89 e5                	mov    %esp,%ebp
80107460:	83 ec 08             	sub    $0x8,%esp
  if(argint(0,&max)< 0 || argptr(1,(void*)&table,sizeof(*table)*max) <0)
80107463:	83 ec 08             	sub    $0x8,%esp
80107466:	8d 45 08             	lea    0x8(%ebp),%eax
80107469:	50                   	push   %eax
8010746a:	6a 00                	push   $0x0
8010746c:	e8 50 ec ff ff       	call   801060c1 <argint>
80107471:	83 c4 10             	add    $0x10,%esp
80107474:	85 c0                	test   %eax,%eax
80107476:	78 24                	js     8010749c <sys_getprocs+0x3f>
80107478:	8b 45 08             	mov    0x8(%ebp),%eax
8010747b:	89 c2                	mov    %eax,%edx
8010747d:	89 d0                	mov    %edx,%eax
8010747f:	01 c0                	add    %eax,%eax
80107481:	01 d0                	add    %edx,%eax
80107483:	c1 e0 05             	shl    $0x5,%eax
80107486:	83 ec 04             	sub    $0x4,%esp
80107489:	50                   	push   %eax
8010748a:	8d 45 0c             	lea    0xc(%ebp),%eax
8010748d:	50                   	push   %eax
8010748e:	6a 01                	push   $0x1
80107490:	e8 54 ec ff ff       	call   801060e9 <argptr>
80107495:	83 c4 10             	add    $0x10,%esp
80107498:	85 c0                	test   %eax,%eax
8010749a:	79 07                	jns    801074a3 <sys_getprocs+0x46>
    return -1;
8010749c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801074a1:	eb 13                	jmp    801074b6 <sys_getprocs+0x59>
  return getprocs(max,table);
801074a3:	8b 55 0c             	mov    0xc(%ebp),%edx
801074a6:	8b 45 08             	mov    0x8(%ebp),%eax
801074a9:	83 ec 08             	sub    $0x8,%esp
801074ac:	52                   	push   %edx
801074ad:	50                   	push   %eax
801074ae:	e8 d7 de ff ff       	call   8010538a <getprocs>
801074b3:	83 c4 10             	add    $0x10,%esp
}
801074b6:	c9                   	leave  
801074b7:	c3                   	ret    

801074b8 <sys_setpriority>:

int
sys_setpriority(void)
{
801074b8:	55                   	push   %ebp
801074b9:	89 e5                	mov    %esp,%ebp
801074bb:	83 ec 18             	sub    $0x18,%esp
  int pid;
  int value;

  if(argint(0, &pid)< 0 || argint(1,&value))
801074be:	83 ec 08             	sub    $0x8,%esp
801074c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801074c4:	50                   	push   %eax
801074c5:	6a 00                	push   $0x0
801074c7:	e8 f5 eb ff ff       	call   801060c1 <argint>
801074cc:	83 c4 10             	add    $0x10,%esp
801074cf:	85 c0                	test   %eax,%eax
801074d1:	78 15                	js     801074e8 <sys_setpriority+0x30>
801074d3:	83 ec 08             	sub    $0x8,%esp
801074d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801074d9:	50                   	push   %eax
801074da:	6a 01                	push   $0x1
801074dc:	e8 e0 eb ff ff       	call   801060c1 <argint>
801074e1:	83 c4 10             	add    $0x10,%esp
801074e4:	85 c0                	test   %eax,%eax
801074e6:	74 07                	je     801074ef <sys_setpriority+0x37>
    return -1;
801074e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801074ed:	eb 13                	jmp    80107502 <sys_setpriority+0x4a>

  return setpriority(pid, value);
801074ef:	8b 55 f0             	mov    -0x10(%ebp),%edx
801074f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f5:	83 ec 08             	sub    $0x8,%esp
801074f8:	52                   	push   %edx
801074f9:	50                   	push   %eax
801074fa:	e8 2e e3 ff ff       	call   8010582d <setpriority>
801074ff:	83 c4 10             	add    $0x10,%esp
}
80107502:	c9                   	leave  
80107503:	c3                   	ret    

80107504 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107504:	55                   	push   %ebp
80107505:	89 e5                	mov    %esp,%ebp
80107507:	83 ec 08             	sub    $0x8,%esp
8010750a:	8b 55 08             	mov    0x8(%ebp),%edx
8010750d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107510:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107514:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107517:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010751b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010751f:	ee                   	out    %al,(%dx)
}
80107520:	90                   	nop
80107521:	c9                   	leave  
80107522:	c3                   	ret    

80107523 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80107523:	55                   	push   %ebp
80107524:	89 e5                	mov    %esp,%ebp
80107526:	83 ec 08             	sub    $0x8,%esp
  // Interrupt TPS times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80107529:	6a 34                	push   $0x34
8010752b:	6a 43                	push   $0x43
8010752d:	e8 d2 ff ff ff       	call   80107504 <outb>
80107532:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) % 256);
80107535:	68 a9 00 00 00       	push   $0xa9
8010753a:	6a 40                	push   $0x40
8010753c:	e8 c3 ff ff ff       	call   80107504 <outb>
80107541:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) / 256);
80107544:	6a 04                	push   $0x4
80107546:	6a 40                	push   $0x40
80107548:	e8 b7 ff ff ff       	call   80107504 <outb>
8010754d:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80107550:	83 ec 0c             	sub    $0xc,%esp
80107553:	6a 00                	push   $0x0
80107555:	e8 e0 ca ff ff       	call   8010403a <picenable>
8010755a:	83 c4 10             	add    $0x10,%esp
}
8010755d:	90                   	nop
8010755e:	c9                   	leave  
8010755f:	c3                   	ret    

80107560 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80107560:	1e                   	push   %ds
  pushl %es
80107561:	06                   	push   %es
  pushl %fs
80107562:	0f a0                	push   %fs
  pushl %gs
80107564:	0f a8                	push   %gs
  pushal
80107566:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80107567:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010756b:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010756d:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
8010756f:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80107573:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80107575:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80107577:	54                   	push   %esp
  call trap
80107578:	e8 ce 01 00 00       	call   8010774b <trap>
  addl $4, %esp
8010757d:	83 c4 04             	add    $0x4,%esp

80107580 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80107580:	61                   	popa   
  popl %gs
80107581:	0f a9                	pop    %gs
  popl %fs
80107583:	0f a1                	pop    %fs
  popl %es
80107585:	07                   	pop    %es
  popl %ds
80107586:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80107587:	83 c4 08             	add    $0x8,%esp
  iret
8010758a:	cf                   	iret   

8010758b <atom_inc>:

// Routines added for CS333
// atom_inc() added to simplify handling of ticks global
static inline void
atom_inc(volatile int *num)
{
8010758b:	55                   	push   %ebp
8010758c:	89 e5                	mov    %esp,%ebp
  asm volatile ( "lock incl %0" : "=m" (*num));
8010758e:	8b 45 08             	mov    0x8(%ebp),%eax
80107591:	f0 ff 00             	lock incl (%eax)
}
80107594:	90                   	nop
80107595:	5d                   	pop    %ebp
80107596:	c3                   	ret    

80107597 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80107597:	55                   	push   %ebp
80107598:	89 e5                	mov    %esp,%ebp
8010759a:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010759d:	8b 45 0c             	mov    0xc(%ebp),%eax
801075a0:	83 e8 01             	sub    $0x1,%eax
801075a3:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801075a7:	8b 45 08             	mov    0x8(%ebp),%eax
801075aa:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801075ae:	8b 45 08             	mov    0x8(%ebp),%eax
801075b1:	c1 e8 10             	shr    $0x10,%eax
801075b4:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801075b8:	8d 45 fa             	lea    -0x6(%ebp),%eax
801075bb:	0f 01 18             	lidtl  (%eax)
}
801075be:	90                   	nop
801075bf:	c9                   	leave  
801075c0:	c3                   	ret    

801075c1 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801075c1:	55                   	push   %ebp
801075c2:	89 e5                	mov    %esp,%ebp
801075c4:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801075c7:	0f 20 d0             	mov    %cr2,%eax
801075ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801075cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801075d0:	c9                   	leave  
801075d1:	c3                   	ret    

801075d2 <tvinit>:
// Software Developer’s Manual, Vol 3A, 8.1.1 Guaranteed Atomic Operations.
uint ticks __attribute__ ((aligned (4)));

void
tvinit(void)
{
801075d2:	55                   	push   %ebp
801075d3:	89 e5                	mov    %esp,%ebp
801075d5:	83 ec 10             	sub    $0x10,%esp
  int i;

  for(i = 0; i < 256; i++)
801075d8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801075df:	e9 c3 00 00 00       	jmp    801076a7 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801075e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801075e7:	8b 04 85 c8 c0 10 80 	mov    -0x7fef3f38(,%eax,4),%eax
801075ee:	89 c2                	mov    %eax,%edx
801075f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801075f3:	66 89 14 c5 40 61 11 	mov    %dx,-0x7fee9ec0(,%eax,8)
801075fa:	80 
801075fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801075fe:	66 c7 04 c5 42 61 11 	movw   $0x8,-0x7fee9ebe(,%eax,8)
80107605:	80 08 00 
80107608:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010760b:	0f b6 14 c5 44 61 11 	movzbl -0x7fee9ebc(,%eax,8),%edx
80107612:	80 
80107613:	83 e2 e0             	and    $0xffffffe0,%edx
80107616:	88 14 c5 44 61 11 80 	mov    %dl,-0x7fee9ebc(,%eax,8)
8010761d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107620:	0f b6 14 c5 44 61 11 	movzbl -0x7fee9ebc(,%eax,8),%edx
80107627:	80 
80107628:	83 e2 1f             	and    $0x1f,%edx
8010762b:	88 14 c5 44 61 11 80 	mov    %dl,-0x7fee9ebc(,%eax,8)
80107632:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107635:	0f b6 14 c5 45 61 11 	movzbl -0x7fee9ebb(,%eax,8),%edx
8010763c:	80 
8010763d:	83 e2 f0             	and    $0xfffffff0,%edx
80107640:	83 ca 0e             	or     $0xe,%edx
80107643:	88 14 c5 45 61 11 80 	mov    %dl,-0x7fee9ebb(,%eax,8)
8010764a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010764d:	0f b6 14 c5 45 61 11 	movzbl -0x7fee9ebb(,%eax,8),%edx
80107654:	80 
80107655:	83 e2 ef             	and    $0xffffffef,%edx
80107658:	88 14 c5 45 61 11 80 	mov    %dl,-0x7fee9ebb(,%eax,8)
8010765f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107662:	0f b6 14 c5 45 61 11 	movzbl -0x7fee9ebb(,%eax,8),%edx
80107669:	80 
8010766a:	83 e2 9f             	and    $0xffffff9f,%edx
8010766d:	88 14 c5 45 61 11 80 	mov    %dl,-0x7fee9ebb(,%eax,8)
80107674:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107677:	0f b6 14 c5 45 61 11 	movzbl -0x7fee9ebb(,%eax,8),%edx
8010767e:	80 
8010767f:	83 ca 80             	or     $0xffffff80,%edx
80107682:	88 14 c5 45 61 11 80 	mov    %dl,-0x7fee9ebb(,%eax,8)
80107689:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010768c:	8b 04 85 c8 c0 10 80 	mov    -0x7fef3f38(,%eax,4),%eax
80107693:	c1 e8 10             	shr    $0x10,%eax
80107696:	89 c2                	mov    %eax,%edx
80107698:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010769b:	66 89 14 c5 46 61 11 	mov    %dx,-0x7fee9eba(,%eax,8)
801076a2:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801076a3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801076a7:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
801076ae:	0f 8e 30 ff ff ff    	jle    801075e4 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801076b4:	a1 c8 c1 10 80       	mov    0x8010c1c8,%eax
801076b9:	66 a3 40 63 11 80    	mov    %ax,0x80116340
801076bf:	66 c7 05 42 63 11 80 	movw   $0x8,0x80116342
801076c6:	08 00 
801076c8:	0f b6 05 44 63 11 80 	movzbl 0x80116344,%eax
801076cf:	83 e0 e0             	and    $0xffffffe0,%eax
801076d2:	a2 44 63 11 80       	mov    %al,0x80116344
801076d7:	0f b6 05 44 63 11 80 	movzbl 0x80116344,%eax
801076de:	83 e0 1f             	and    $0x1f,%eax
801076e1:	a2 44 63 11 80       	mov    %al,0x80116344
801076e6:	0f b6 05 45 63 11 80 	movzbl 0x80116345,%eax
801076ed:	83 c8 0f             	or     $0xf,%eax
801076f0:	a2 45 63 11 80       	mov    %al,0x80116345
801076f5:	0f b6 05 45 63 11 80 	movzbl 0x80116345,%eax
801076fc:	83 e0 ef             	and    $0xffffffef,%eax
801076ff:	a2 45 63 11 80       	mov    %al,0x80116345
80107704:	0f b6 05 45 63 11 80 	movzbl 0x80116345,%eax
8010770b:	83 c8 60             	or     $0x60,%eax
8010770e:	a2 45 63 11 80       	mov    %al,0x80116345
80107713:	0f b6 05 45 63 11 80 	movzbl 0x80116345,%eax
8010771a:	83 c8 80             	or     $0xffffff80,%eax
8010771d:	a2 45 63 11 80       	mov    %al,0x80116345
80107722:	a1 c8 c1 10 80       	mov    0x8010c1c8,%eax
80107727:	c1 e8 10             	shr    $0x10,%eax
8010772a:	66 a3 46 63 11 80    	mov    %ax,0x80116346
  
}
80107730:	90                   	nop
80107731:	c9                   	leave  
80107732:	c3                   	ret    

80107733 <idtinit>:

void
idtinit(void)
{
80107733:	55                   	push   %ebp
80107734:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80107736:	68 00 08 00 00       	push   $0x800
8010773b:	68 40 61 11 80       	push   $0x80116140
80107740:	e8 52 fe ff ff       	call   80107597 <lidt>
80107745:	83 c4 08             	add    $0x8,%esp
}
80107748:	90                   	nop
80107749:	c9                   	leave  
8010774a:	c3                   	ret    

8010774b <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010774b:	55                   	push   %ebp
8010774c:	89 e5                	mov    %esp,%ebp
8010774e:	57                   	push   %edi
8010774f:	56                   	push   %esi
80107750:	53                   	push   %ebx
80107751:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80107754:	8b 45 08             	mov    0x8(%ebp),%eax
80107757:	8b 40 30             	mov    0x30(%eax),%eax
8010775a:	83 f8 40             	cmp    $0x40,%eax
8010775d:	75 3e                	jne    8010779d <trap+0x52>
    if(proc->killed)
8010775f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107765:	8b 40 24             	mov    0x24(%eax),%eax
80107768:	85 c0                	test   %eax,%eax
8010776a:	74 05                	je     80107771 <trap+0x26>
      exit();
8010776c:	e8 10 d3 ff ff       	call   80104a81 <exit>
    proc->tf = tf;
80107771:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107777:	8b 55 08             	mov    0x8(%ebp),%edx
8010777a:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010777d:	e8 f5 e9 ff ff       	call   80106177 <syscall>
    if(proc->killed)
80107782:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107788:	8b 40 24             	mov    0x24(%eax),%eax
8010778b:	85 c0                	test   %eax,%eax
8010778d:	0f 84 21 02 00 00    	je     801079b4 <trap+0x269>
      exit();
80107793:	e8 e9 d2 ff ff       	call   80104a81 <exit>
    return;
80107798:	e9 17 02 00 00       	jmp    801079b4 <trap+0x269>
  }

  switch(tf->trapno){
8010779d:	8b 45 08             	mov    0x8(%ebp),%eax
801077a0:	8b 40 30             	mov    0x30(%eax),%eax
801077a3:	83 e8 20             	sub    $0x20,%eax
801077a6:	83 f8 1f             	cmp    $0x1f,%eax
801077a9:	0f 87 a3 00 00 00    	ja     80107852 <trap+0x107>
801077af:	8b 04 85 dc 9a 10 80 	mov    -0x7fef6524(,%eax,4),%eax
801077b6:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
   if(cpu->id == 0){
801077b8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801077be:	0f b6 00             	movzbl (%eax),%eax
801077c1:	84 c0                	test   %al,%al
801077c3:	75 20                	jne    801077e5 <trap+0x9a>
      atom_inc((int *)&ticks);   // guaranteed atomic so no lock necessary
801077c5:	83 ec 0c             	sub    $0xc,%esp
801077c8:	68 40 69 11 80       	push   $0x80116940
801077cd:	e8 b9 fd ff ff       	call   8010758b <atom_inc>
801077d2:	83 c4 10             	add    $0x10,%esp
      wakeup(&ticks);
801077d5:	83 ec 0c             	sub    $0xc,%esp
801077d8:	68 40 69 11 80       	push   $0x80116940
801077dd:	e8 47 d8 ff ff       	call   80105029 <wakeup>
801077e2:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801077e5:	e8 4a b9 ff ff       	call   80103134 <lapiceoi>
    break;
801077ea:	e9 1c 01 00 00       	jmp    8010790b <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801077ef:	e8 53 b1 ff ff       	call   80102947 <ideintr>
    lapiceoi();
801077f4:	e8 3b b9 ff ff       	call   80103134 <lapiceoi>
    break;
801077f9:	e9 0d 01 00 00       	jmp    8010790b <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801077fe:	e8 33 b7 ff ff       	call   80102f36 <kbdintr>
    lapiceoi();
80107803:	e8 2c b9 ff ff       	call   80103134 <lapiceoi>
    break;
80107808:	e9 fe 00 00 00       	jmp    8010790b <trap+0x1c0>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010780d:	e8 83 03 00 00       	call   80107b95 <uartintr>
    lapiceoi();
80107812:	e8 1d b9 ff ff       	call   80103134 <lapiceoi>
    break;
80107817:	e9 ef 00 00 00       	jmp    8010790b <trap+0x1c0>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010781c:	8b 45 08             	mov    0x8(%ebp),%eax
8010781f:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80107822:	8b 45 08             	mov    0x8(%ebp),%eax
80107825:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107829:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
8010782c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107832:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107835:	0f b6 c0             	movzbl %al,%eax
80107838:	51                   	push   %ecx
80107839:	52                   	push   %edx
8010783a:	50                   	push   %eax
8010783b:	68 3c 9a 10 80       	push   $0x80109a3c
80107840:	e8 81 8b ff ff       	call   801003c6 <cprintf>
80107845:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80107848:	e8 e7 b8 ff ff       	call   80103134 <lapiceoi>
    break;
8010784d:	e9 b9 00 00 00       	jmp    8010790b <trap+0x1c0>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80107852:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107858:	85 c0                	test   %eax,%eax
8010785a:	74 11                	je     8010786d <trap+0x122>
8010785c:	8b 45 08             	mov    0x8(%ebp),%eax
8010785f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107863:	0f b7 c0             	movzwl %ax,%eax
80107866:	83 e0 03             	and    $0x3,%eax
80107869:	85 c0                	test   %eax,%eax
8010786b:	75 40                	jne    801078ad <trap+0x162>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010786d:	e8 4f fd ff ff       	call   801075c1 <rcr2>
80107872:	89 c3                	mov    %eax,%ebx
80107874:	8b 45 08             	mov    0x8(%ebp),%eax
80107877:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
8010787a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107880:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107883:	0f b6 d0             	movzbl %al,%edx
80107886:	8b 45 08             	mov    0x8(%ebp),%eax
80107889:	8b 40 30             	mov    0x30(%eax),%eax
8010788c:	83 ec 0c             	sub    $0xc,%esp
8010788f:	53                   	push   %ebx
80107890:	51                   	push   %ecx
80107891:	52                   	push   %edx
80107892:	50                   	push   %eax
80107893:	68 60 9a 10 80       	push   $0x80109a60
80107898:	e8 29 8b ff ff       	call   801003c6 <cprintf>
8010789d:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
801078a0:	83 ec 0c             	sub    $0xc,%esp
801078a3:	68 92 9a 10 80       	push   $0x80109a92
801078a8:	e8 b9 8c ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801078ad:	e8 0f fd ff ff       	call   801075c1 <rcr2>
801078b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801078b5:	8b 45 08             	mov    0x8(%ebp),%eax
801078b8:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801078bb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801078c1:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801078c4:	0f b6 d8             	movzbl %al,%ebx
801078c7:	8b 45 08             	mov    0x8(%ebp),%eax
801078ca:	8b 48 34             	mov    0x34(%eax),%ecx
801078cd:	8b 45 08             	mov    0x8(%ebp),%eax
801078d0:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801078d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801078d9:	8d 78 6c             	lea    0x6c(%eax),%edi
801078dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801078e2:	8b 40 10             	mov    0x10(%eax),%eax
801078e5:	ff 75 e4             	pushl  -0x1c(%ebp)
801078e8:	56                   	push   %esi
801078e9:	53                   	push   %ebx
801078ea:	51                   	push   %ecx
801078eb:	52                   	push   %edx
801078ec:	57                   	push   %edi
801078ed:	50                   	push   %eax
801078ee:	68 98 9a 10 80       	push   $0x80109a98
801078f3:	e8 ce 8a ff ff       	call   801003c6 <cprintf>
801078f8:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
801078fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107901:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80107908:	eb 01                	jmp    8010790b <trap+0x1c0>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
8010790a:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010790b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107911:	85 c0                	test   %eax,%eax
80107913:	74 24                	je     80107939 <trap+0x1ee>
80107915:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010791b:	8b 40 24             	mov    0x24(%eax),%eax
8010791e:	85 c0                	test   %eax,%eax
80107920:	74 17                	je     80107939 <trap+0x1ee>
80107922:	8b 45 08             	mov    0x8(%ebp),%eax
80107925:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107929:	0f b7 c0             	movzwl %ax,%eax
8010792c:	83 e0 03             	and    $0x3,%eax
8010792f:	83 f8 03             	cmp    $0x3,%eax
80107932:	75 05                	jne    80107939 <trap+0x1ee>
    exit();
80107934:	e8 48 d1 ff ff       	call   80104a81 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
80107939:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010793f:	85 c0                	test   %eax,%eax
80107941:	74 41                	je     80107984 <trap+0x239>
80107943:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107949:	8b 40 0c             	mov    0xc(%eax),%eax
8010794c:	83 f8 04             	cmp    $0x4,%eax
8010794f:	75 33                	jne    80107984 <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
80107951:	8b 45 08             	mov    0x8(%ebp),%eax
80107954:	8b 40 30             	mov    0x30(%eax),%eax
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
80107957:	83 f8 20             	cmp    $0x20,%eax
8010795a:	75 28                	jne    80107984 <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
8010795c:	8b 0d 40 69 11 80    	mov    0x80116940,%ecx
80107962:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
80107967:	89 c8                	mov    %ecx,%eax
80107969:	f7 e2                	mul    %edx
8010796b:	c1 ea 03             	shr    $0x3,%edx
8010796e:	89 d0                	mov    %edx,%eax
80107970:	c1 e0 02             	shl    $0x2,%eax
80107973:	01 d0                	add    %edx,%eax
80107975:	01 c0                	add    %eax,%eax
80107977:	29 c1                	sub    %eax,%ecx
80107979:	89 ca                	mov    %ecx,%edx
8010797b:	85 d2                	test   %edx,%edx
8010797d:	75 05                	jne    80107984 <trap+0x239>
    yield();
8010797f:	e8 3d d5 ff ff       	call   80104ec1 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107984:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010798a:	85 c0                	test   %eax,%eax
8010798c:	74 27                	je     801079b5 <trap+0x26a>
8010798e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107994:	8b 40 24             	mov    0x24(%eax),%eax
80107997:	85 c0                	test   %eax,%eax
80107999:	74 1a                	je     801079b5 <trap+0x26a>
8010799b:	8b 45 08             	mov    0x8(%ebp),%eax
8010799e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801079a2:	0f b7 c0             	movzwl %ax,%eax
801079a5:	83 e0 03             	and    $0x3,%eax
801079a8:	83 f8 03             	cmp    $0x3,%eax
801079ab:	75 08                	jne    801079b5 <trap+0x26a>
    exit();
801079ad:	e8 cf d0 ff ff       	call   80104a81 <exit>
801079b2:	eb 01                	jmp    801079b5 <trap+0x26a>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
801079b4:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
801079b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801079b8:	5b                   	pop    %ebx
801079b9:	5e                   	pop    %esi
801079ba:	5f                   	pop    %edi
801079bb:	5d                   	pop    %ebp
801079bc:	c3                   	ret    

801079bd <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
801079bd:	55                   	push   %ebp
801079be:	89 e5                	mov    %esp,%ebp
801079c0:	83 ec 14             	sub    $0x14,%esp
801079c3:	8b 45 08             	mov    0x8(%ebp),%eax
801079c6:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801079ca:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801079ce:	89 c2                	mov    %eax,%edx
801079d0:	ec                   	in     (%dx),%al
801079d1:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801079d4:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801079d8:	c9                   	leave  
801079d9:	c3                   	ret    

801079da <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801079da:	55                   	push   %ebp
801079db:	89 e5                	mov    %esp,%ebp
801079dd:	83 ec 08             	sub    $0x8,%esp
801079e0:	8b 55 08             	mov    0x8(%ebp),%edx
801079e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801079e6:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801079ea:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801079ed:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801079f1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801079f5:	ee                   	out    %al,(%dx)
}
801079f6:	90                   	nop
801079f7:	c9                   	leave  
801079f8:	c3                   	ret    

801079f9 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801079f9:	55                   	push   %ebp
801079fa:	89 e5                	mov    %esp,%ebp
801079fc:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801079ff:	6a 00                	push   $0x0
80107a01:	68 fa 03 00 00       	push   $0x3fa
80107a06:	e8 cf ff ff ff       	call   801079da <outb>
80107a0b:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107a0e:	68 80 00 00 00       	push   $0x80
80107a13:	68 fb 03 00 00       	push   $0x3fb
80107a18:	e8 bd ff ff ff       	call   801079da <outb>
80107a1d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107a20:	6a 0c                	push   $0xc
80107a22:	68 f8 03 00 00       	push   $0x3f8
80107a27:	e8 ae ff ff ff       	call   801079da <outb>
80107a2c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107a2f:	6a 00                	push   $0x0
80107a31:	68 f9 03 00 00       	push   $0x3f9
80107a36:	e8 9f ff ff ff       	call   801079da <outb>
80107a3b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107a3e:	6a 03                	push   $0x3
80107a40:	68 fb 03 00 00       	push   $0x3fb
80107a45:	e8 90 ff ff ff       	call   801079da <outb>
80107a4a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107a4d:	6a 00                	push   $0x0
80107a4f:	68 fc 03 00 00       	push   $0x3fc
80107a54:	e8 81 ff ff ff       	call   801079da <outb>
80107a59:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107a5c:	6a 01                	push   $0x1
80107a5e:	68 f9 03 00 00       	push   $0x3f9
80107a63:	e8 72 ff ff ff       	call   801079da <outb>
80107a68:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107a6b:	68 fd 03 00 00       	push   $0x3fd
80107a70:	e8 48 ff ff ff       	call   801079bd <inb>
80107a75:	83 c4 04             	add    $0x4,%esp
80107a78:	3c ff                	cmp    $0xff,%al
80107a7a:	74 6e                	je     80107aea <uartinit+0xf1>
    return;
  uart = 1;
80107a7c:	c7 05 8c c6 10 80 01 	movl   $0x1,0x8010c68c
80107a83:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107a86:	68 fa 03 00 00       	push   $0x3fa
80107a8b:	e8 2d ff ff ff       	call   801079bd <inb>
80107a90:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80107a93:	68 f8 03 00 00       	push   $0x3f8
80107a98:	e8 20 ff ff ff       	call   801079bd <inb>
80107a9d:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80107aa0:	83 ec 0c             	sub    $0xc,%esp
80107aa3:	6a 04                	push   $0x4
80107aa5:	e8 90 c5 ff ff       	call   8010403a <picenable>
80107aaa:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80107aad:	83 ec 08             	sub    $0x8,%esp
80107ab0:	6a 00                	push   $0x0
80107ab2:	6a 04                	push   $0x4
80107ab4:	e8 30 b1 ff ff       	call   80102be9 <ioapicenable>
80107ab9:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107abc:	c7 45 f4 5c 9b 10 80 	movl   $0x80109b5c,-0xc(%ebp)
80107ac3:	eb 19                	jmp    80107ade <uartinit+0xe5>
    uartputc(*p);
80107ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac8:	0f b6 00             	movzbl (%eax),%eax
80107acb:	0f be c0             	movsbl %al,%eax
80107ace:	83 ec 0c             	sub    $0xc,%esp
80107ad1:	50                   	push   %eax
80107ad2:	e8 16 00 00 00       	call   80107aed <uartputc>
80107ad7:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107ada:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae1:	0f b6 00             	movzbl (%eax),%eax
80107ae4:	84 c0                	test   %al,%al
80107ae6:	75 dd                	jne    80107ac5 <uartinit+0xcc>
80107ae8:	eb 01                	jmp    80107aeb <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80107aea:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80107aeb:	c9                   	leave  
80107aec:	c3                   	ret    

80107aed <uartputc>:

void
uartputc(int c)
{
80107aed:	55                   	push   %ebp
80107aee:	89 e5                	mov    %esp,%ebp
80107af0:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80107af3:	a1 8c c6 10 80       	mov    0x8010c68c,%eax
80107af8:	85 c0                	test   %eax,%eax
80107afa:	74 53                	je     80107b4f <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107afc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107b03:	eb 11                	jmp    80107b16 <uartputc+0x29>
    microdelay(10);
80107b05:	83 ec 0c             	sub    $0xc,%esp
80107b08:	6a 0a                	push   $0xa
80107b0a:	e8 40 b6 ff ff       	call   8010314f <microdelay>
80107b0f:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107b12:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107b16:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107b1a:	7f 1a                	jg     80107b36 <uartputc+0x49>
80107b1c:	83 ec 0c             	sub    $0xc,%esp
80107b1f:	68 fd 03 00 00       	push   $0x3fd
80107b24:	e8 94 fe ff ff       	call   801079bd <inb>
80107b29:	83 c4 10             	add    $0x10,%esp
80107b2c:	0f b6 c0             	movzbl %al,%eax
80107b2f:	83 e0 20             	and    $0x20,%eax
80107b32:	85 c0                	test   %eax,%eax
80107b34:	74 cf                	je     80107b05 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80107b36:	8b 45 08             	mov    0x8(%ebp),%eax
80107b39:	0f b6 c0             	movzbl %al,%eax
80107b3c:	83 ec 08             	sub    $0x8,%esp
80107b3f:	50                   	push   %eax
80107b40:	68 f8 03 00 00       	push   $0x3f8
80107b45:	e8 90 fe ff ff       	call   801079da <outb>
80107b4a:	83 c4 10             	add    $0x10,%esp
80107b4d:	eb 01                	jmp    80107b50 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80107b4f:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80107b50:	c9                   	leave  
80107b51:	c3                   	ret    

80107b52 <uartgetc>:

static int
uartgetc(void)
{
80107b52:	55                   	push   %ebp
80107b53:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107b55:	a1 8c c6 10 80       	mov    0x8010c68c,%eax
80107b5a:	85 c0                	test   %eax,%eax
80107b5c:	75 07                	jne    80107b65 <uartgetc+0x13>
    return -1;
80107b5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b63:	eb 2e                	jmp    80107b93 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80107b65:	68 fd 03 00 00       	push   $0x3fd
80107b6a:	e8 4e fe ff ff       	call   801079bd <inb>
80107b6f:	83 c4 04             	add    $0x4,%esp
80107b72:	0f b6 c0             	movzbl %al,%eax
80107b75:	83 e0 01             	and    $0x1,%eax
80107b78:	85 c0                	test   %eax,%eax
80107b7a:	75 07                	jne    80107b83 <uartgetc+0x31>
    return -1;
80107b7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b81:	eb 10                	jmp    80107b93 <uartgetc+0x41>
  return inb(COM1+0);
80107b83:	68 f8 03 00 00       	push   $0x3f8
80107b88:	e8 30 fe ff ff       	call   801079bd <inb>
80107b8d:	83 c4 04             	add    $0x4,%esp
80107b90:	0f b6 c0             	movzbl %al,%eax
}
80107b93:	c9                   	leave  
80107b94:	c3                   	ret    

80107b95 <uartintr>:

void
uartintr(void)
{
80107b95:	55                   	push   %ebp
80107b96:	89 e5                	mov    %esp,%ebp
80107b98:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107b9b:	83 ec 0c             	sub    $0xc,%esp
80107b9e:	68 52 7b 10 80       	push   $0x80107b52
80107ba3:	e8 51 8c ff ff       	call   801007f9 <consoleintr>
80107ba8:	83 c4 10             	add    $0x10,%esp
}
80107bab:	90                   	nop
80107bac:	c9                   	leave  
80107bad:	c3                   	ret    

80107bae <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107bae:	6a 00                	push   $0x0
  pushl $0
80107bb0:	6a 00                	push   $0x0
  jmp alltraps
80107bb2:	e9 a9 f9 ff ff       	jmp    80107560 <alltraps>

80107bb7 <vector1>:
.globl vector1
vector1:
  pushl $0
80107bb7:	6a 00                	push   $0x0
  pushl $1
80107bb9:	6a 01                	push   $0x1
  jmp alltraps
80107bbb:	e9 a0 f9 ff ff       	jmp    80107560 <alltraps>

80107bc0 <vector2>:
.globl vector2
vector2:
  pushl $0
80107bc0:	6a 00                	push   $0x0
  pushl $2
80107bc2:	6a 02                	push   $0x2
  jmp alltraps
80107bc4:	e9 97 f9 ff ff       	jmp    80107560 <alltraps>

80107bc9 <vector3>:
.globl vector3
vector3:
  pushl $0
80107bc9:	6a 00                	push   $0x0
  pushl $3
80107bcb:	6a 03                	push   $0x3
  jmp alltraps
80107bcd:	e9 8e f9 ff ff       	jmp    80107560 <alltraps>

80107bd2 <vector4>:
.globl vector4
vector4:
  pushl $0
80107bd2:	6a 00                	push   $0x0
  pushl $4
80107bd4:	6a 04                	push   $0x4
  jmp alltraps
80107bd6:	e9 85 f9 ff ff       	jmp    80107560 <alltraps>

80107bdb <vector5>:
.globl vector5
vector5:
  pushl $0
80107bdb:	6a 00                	push   $0x0
  pushl $5
80107bdd:	6a 05                	push   $0x5
  jmp alltraps
80107bdf:	e9 7c f9 ff ff       	jmp    80107560 <alltraps>

80107be4 <vector6>:
.globl vector6
vector6:
  pushl $0
80107be4:	6a 00                	push   $0x0
  pushl $6
80107be6:	6a 06                	push   $0x6
  jmp alltraps
80107be8:	e9 73 f9 ff ff       	jmp    80107560 <alltraps>

80107bed <vector7>:
.globl vector7
vector7:
  pushl $0
80107bed:	6a 00                	push   $0x0
  pushl $7
80107bef:	6a 07                	push   $0x7
  jmp alltraps
80107bf1:	e9 6a f9 ff ff       	jmp    80107560 <alltraps>

80107bf6 <vector8>:
.globl vector8
vector8:
  pushl $8
80107bf6:	6a 08                	push   $0x8
  jmp alltraps
80107bf8:	e9 63 f9 ff ff       	jmp    80107560 <alltraps>

80107bfd <vector9>:
.globl vector9
vector9:
  pushl $0
80107bfd:	6a 00                	push   $0x0
  pushl $9
80107bff:	6a 09                	push   $0x9
  jmp alltraps
80107c01:	e9 5a f9 ff ff       	jmp    80107560 <alltraps>

80107c06 <vector10>:
.globl vector10
vector10:
  pushl $10
80107c06:	6a 0a                	push   $0xa
  jmp alltraps
80107c08:	e9 53 f9 ff ff       	jmp    80107560 <alltraps>

80107c0d <vector11>:
.globl vector11
vector11:
  pushl $11
80107c0d:	6a 0b                	push   $0xb
  jmp alltraps
80107c0f:	e9 4c f9 ff ff       	jmp    80107560 <alltraps>

80107c14 <vector12>:
.globl vector12
vector12:
  pushl $12
80107c14:	6a 0c                	push   $0xc
  jmp alltraps
80107c16:	e9 45 f9 ff ff       	jmp    80107560 <alltraps>

80107c1b <vector13>:
.globl vector13
vector13:
  pushl $13
80107c1b:	6a 0d                	push   $0xd
  jmp alltraps
80107c1d:	e9 3e f9 ff ff       	jmp    80107560 <alltraps>

80107c22 <vector14>:
.globl vector14
vector14:
  pushl $14
80107c22:	6a 0e                	push   $0xe
  jmp alltraps
80107c24:	e9 37 f9 ff ff       	jmp    80107560 <alltraps>

80107c29 <vector15>:
.globl vector15
vector15:
  pushl $0
80107c29:	6a 00                	push   $0x0
  pushl $15
80107c2b:	6a 0f                	push   $0xf
  jmp alltraps
80107c2d:	e9 2e f9 ff ff       	jmp    80107560 <alltraps>

80107c32 <vector16>:
.globl vector16
vector16:
  pushl $0
80107c32:	6a 00                	push   $0x0
  pushl $16
80107c34:	6a 10                	push   $0x10
  jmp alltraps
80107c36:	e9 25 f9 ff ff       	jmp    80107560 <alltraps>

80107c3b <vector17>:
.globl vector17
vector17:
  pushl $17
80107c3b:	6a 11                	push   $0x11
  jmp alltraps
80107c3d:	e9 1e f9 ff ff       	jmp    80107560 <alltraps>

80107c42 <vector18>:
.globl vector18
vector18:
  pushl $0
80107c42:	6a 00                	push   $0x0
  pushl $18
80107c44:	6a 12                	push   $0x12
  jmp alltraps
80107c46:	e9 15 f9 ff ff       	jmp    80107560 <alltraps>

80107c4b <vector19>:
.globl vector19
vector19:
  pushl $0
80107c4b:	6a 00                	push   $0x0
  pushl $19
80107c4d:	6a 13                	push   $0x13
  jmp alltraps
80107c4f:	e9 0c f9 ff ff       	jmp    80107560 <alltraps>

80107c54 <vector20>:
.globl vector20
vector20:
  pushl $0
80107c54:	6a 00                	push   $0x0
  pushl $20
80107c56:	6a 14                	push   $0x14
  jmp alltraps
80107c58:	e9 03 f9 ff ff       	jmp    80107560 <alltraps>

80107c5d <vector21>:
.globl vector21
vector21:
  pushl $0
80107c5d:	6a 00                	push   $0x0
  pushl $21
80107c5f:	6a 15                	push   $0x15
  jmp alltraps
80107c61:	e9 fa f8 ff ff       	jmp    80107560 <alltraps>

80107c66 <vector22>:
.globl vector22
vector22:
  pushl $0
80107c66:	6a 00                	push   $0x0
  pushl $22
80107c68:	6a 16                	push   $0x16
  jmp alltraps
80107c6a:	e9 f1 f8 ff ff       	jmp    80107560 <alltraps>

80107c6f <vector23>:
.globl vector23
vector23:
  pushl $0
80107c6f:	6a 00                	push   $0x0
  pushl $23
80107c71:	6a 17                	push   $0x17
  jmp alltraps
80107c73:	e9 e8 f8 ff ff       	jmp    80107560 <alltraps>

80107c78 <vector24>:
.globl vector24
vector24:
  pushl $0
80107c78:	6a 00                	push   $0x0
  pushl $24
80107c7a:	6a 18                	push   $0x18
  jmp alltraps
80107c7c:	e9 df f8 ff ff       	jmp    80107560 <alltraps>

80107c81 <vector25>:
.globl vector25
vector25:
  pushl $0
80107c81:	6a 00                	push   $0x0
  pushl $25
80107c83:	6a 19                	push   $0x19
  jmp alltraps
80107c85:	e9 d6 f8 ff ff       	jmp    80107560 <alltraps>

80107c8a <vector26>:
.globl vector26
vector26:
  pushl $0
80107c8a:	6a 00                	push   $0x0
  pushl $26
80107c8c:	6a 1a                	push   $0x1a
  jmp alltraps
80107c8e:	e9 cd f8 ff ff       	jmp    80107560 <alltraps>

80107c93 <vector27>:
.globl vector27
vector27:
  pushl $0
80107c93:	6a 00                	push   $0x0
  pushl $27
80107c95:	6a 1b                	push   $0x1b
  jmp alltraps
80107c97:	e9 c4 f8 ff ff       	jmp    80107560 <alltraps>

80107c9c <vector28>:
.globl vector28
vector28:
  pushl $0
80107c9c:	6a 00                	push   $0x0
  pushl $28
80107c9e:	6a 1c                	push   $0x1c
  jmp alltraps
80107ca0:	e9 bb f8 ff ff       	jmp    80107560 <alltraps>

80107ca5 <vector29>:
.globl vector29
vector29:
  pushl $0
80107ca5:	6a 00                	push   $0x0
  pushl $29
80107ca7:	6a 1d                	push   $0x1d
  jmp alltraps
80107ca9:	e9 b2 f8 ff ff       	jmp    80107560 <alltraps>

80107cae <vector30>:
.globl vector30
vector30:
  pushl $0
80107cae:	6a 00                	push   $0x0
  pushl $30
80107cb0:	6a 1e                	push   $0x1e
  jmp alltraps
80107cb2:	e9 a9 f8 ff ff       	jmp    80107560 <alltraps>

80107cb7 <vector31>:
.globl vector31
vector31:
  pushl $0
80107cb7:	6a 00                	push   $0x0
  pushl $31
80107cb9:	6a 1f                	push   $0x1f
  jmp alltraps
80107cbb:	e9 a0 f8 ff ff       	jmp    80107560 <alltraps>

80107cc0 <vector32>:
.globl vector32
vector32:
  pushl $0
80107cc0:	6a 00                	push   $0x0
  pushl $32
80107cc2:	6a 20                	push   $0x20
  jmp alltraps
80107cc4:	e9 97 f8 ff ff       	jmp    80107560 <alltraps>

80107cc9 <vector33>:
.globl vector33
vector33:
  pushl $0
80107cc9:	6a 00                	push   $0x0
  pushl $33
80107ccb:	6a 21                	push   $0x21
  jmp alltraps
80107ccd:	e9 8e f8 ff ff       	jmp    80107560 <alltraps>

80107cd2 <vector34>:
.globl vector34
vector34:
  pushl $0
80107cd2:	6a 00                	push   $0x0
  pushl $34
80107cd4:	6a 22                	push   $0x22
  jmp alltraps
80107cd6:	e9 85 f8 ff ff       	jmp    80107560 <alltraps>

80107cdb <vector35>:
.globl vector35
vector35:
  pushl $0
80107cdb:	6a 00                	push   $0x0
  pushl $35
80107cdd:	6a 23                	push   $0x23
  jmp alltraps
80107cdf:	e9 7c f8 ff ff       	jmp    80107560 <alltraps>

80107ce4 <vector36>:
.globl vector36
vector36:
  pushl $0
80107ce4:	6a 00                	push   $0x0
  pushl $36
80107ce6:	6a 24                	push   $0x24
  jmp alltraps
80107ce8:	e9 73 f8 ff ff       	jmp    80107560 <alltraps>

80107ced <vector37>:
.globl vector37
vector37:
  pushl $0
80107ced:	6a 00                	push   $0x0
  pushl $37
80107cef:	6a 25                	push   $0x25
  jmp alltraps
80107cf1:	e9 6a f8 ff ff       	jmp    80107560 <alltraps>

80107cf6 <vector38>:
.globl vector38
vector38:
  pushl $0
80107cf6:	6a 00                	push   $0x0
  pushl $38
80107cf8:	6a 26                	push   $0x26
  jmp alltraps
80107cfa:	e9 61 f8 ff ff       	jmp    80107560 <alltraps>

80107cff <vector39>:
.globl vector39
vector39:
  pushl $0
80107cff:	6a 00                	push   $0x0
  pushl $39
80107d01:	6a 27                	push   $0x27
  jmp alltraps
80107d03:	e9 58 f8 ff ff       	jmp    80107560 <alltraps>

80107d08 <vector40>:
.globl vector40
vector40:
  pushl $0
80107d08:	6a 00                	push   $0x0
  pushl $40
80107d0a:	6a 28                	push   $0x28
  jmp alltraps
80107d0c:	e9 4f f8 ff ff       	jmp    80107560 <alltraps>

80107d11 <vector41>:
.globl vector41
vector41:
  pushl $0
80107d11:	6a 00                	push   $0x0
  pushl $41
80107d13:	6a 29                	push   $0x29
  jmp alltraps
80107d15:	e9 46 f8 ff ff       	jmp    80107560 <alltraps>

80107d1a <vector42>:
.globl vector42
vector42:
  pushl $0
80107d1a:	6a 00                	push   $0x0
  pushl $42
80107d1c:	6a 2a                	push   $0x2a
  jmp alltraps
80107d1e:	e9 3d f8 ff ff       	jmp    80107560 <alltraps>

80107d23 <vector43>:
.globl vector43
vector43:
  pushl $0
80107d23:	6a 00                	push   $0x0
  pushl $43
80107d25:	6a 2b                	push   $0x2b
  jmp alltraps
80107d27:	e9 34 f8 ff ff       	jmp    80107560 <alltraps>

80107d2c <vector44>:
.globl vector44
vector44:
  pushl $0
80107d2c:	6a 00                	push   $0x0
  pushl $44
80107d2e:	6a 2c                	push   $0x2c
  jmp alltraps
80107d30:	e9 2b f8 ff ff       	jmp    80107560 <alltraps>

80107d35 <vector45>:
.globl vector45
vector45:
  pushl $0
80107d35:	6a 00                	push   $0x0
  pushl $45
80107d37:	6a 2d                	push   $0x2d
  jmp alltraps
80107d39:	e9 22 f8 ff ff       	jmp    80107560 <alltraps>

80107d3e <vector46>:
.globl vector46
vector46:
  pushl $0
80107d3e:	6a 00                	push   $0x0
  pushl $46
80107d40:	6a 2e                	push   $0x2e
  jmp alltraps
80107d42:	e9 19 f8 ff ff       	jmp    80107560 <alltraps>

80107d47 <vector47>:
.globl vector47
vector47:
  pushl $0
80107d47:	6a 00                	push   $0x0
  pushl $47
80107d49:	6a 2f                	push   $0x2f
  jmp alltraps
80107d4b:	e9 10 f8 ff ff       	jmp    80107560 <alltraps>

80107d50 <vector48>:
.globl vector48
vector48:
  pushl $0
80107d50:	6a 00                	push   $0x0
  pushl $48
80107d52:	6a 30                	push   $0x30
  jmp alltraps
80107d54:	e9 07 f8 ff ff       	jmp    80107560 <alltraps>

80107d59 <vector49>:
.globl vector49
vector49:
  pushl $0
80107d59:	6a 00                	push   $0x0
  pushl $49
80107d5b:	6a 31                	push   $0x31
  jmp alltraps
80107d5d:	e9 fe f7 ff ff       	jmp    80107560 <alltraps>

80107d62 <vector50>:
.globl vector50
vector50:
  pushl $0
80107d62:	6a 00                	push   $0x0
  pushl $50
80107d64:	6a 32                	push   $0x32
  jmp alltraps
80107d66:	e9 f5 f7 ff ff       	jmp    80107560 <alltraps>

80107d6b <vector51>:
.globl vector51
vector51:
  pushl $0
80107d6b:	6a 00                	push   $0x0
  pushl $51
80107d6d:	6a 33                	push   $0x33
  jmp alltraps
80107d6f:	e9 ec f7 ff ff       	jmp    80107560 <alltraps>

80107d74 <vector52>:
.globl vector52
vector52:
  pushl $0
80107d74:	6a 00                	push   $0x0
  pushl $52
80107d76:	6a 34                	push   $0x34
  jmp alltraps
80107d78:	e9 e3 f7 ff ff       	jmp    80107560 <alltraps>

80107d7d <vector53>:
.globl vector53
vector53:
  pushl $0
80107d7d:	6a 00                	push   $0x0
  pushl $53
80107d7f:	6a 35                	push   $0x35
  jmp alltraps
80107d81:	e9 da f7 ff ff       	jmp    80107560 <alltraps>

80107d86 <vector54>:
.globl vector54
vector54:
  pushl $0
80107d86:	6a 00                	push   $0x0
  pushl $54
80107d88:	6a 36                	push   $0x36
  jmp alltraps
80107d8a:	e9 d1 f7 ff ff       	jmp    80107560 <alltraps>

80107d8f <vector55>:
.globl vector55
vector55:
  pushl $0
80107d8f:	6a 00                	push   $0x0
  pushl $55
80107d91:	6a 37                	push   $0x37
  jmp alltraps
80107d93:	e9 c8 f7 ff ff       	jmp    80107560 <alltraps>

80107d98 <vector56>:
.globl vector56
vector56:
  pushl $0
80107d98:	6a 00                	push   $0x0
  pushl $56
80107d9a:	6a 38                	push   $0x38
  jmp alltraps
80107d9c:	e9 bf f7 ff ff       	jmp    80107560 <alltraps>

80107da1 <vector57>:
.globl vector57
vector57:
  pushl $0
80107da1:	6a 00                	push   $0x0
  pushl $57
80107da3:	6a 39                	push   $0x39
  jmp alltraps
80107da5:	e9 b6 f7 ff ff       	jmp    80107560 <alltraps>

80107daa <vector58>:
.globl vector58
vector58:
  pushl $0
80107daa:	6a 00                	push   $0x0
  pushl $58
80107dac:	6a 3a                	push   $0x3a
  jmp alltraps
80107dae:	e9 ad f7 ff ff       	jmp    80107560 <alltraps>

80107db3 <vector59>:
.globl vector59
vector59:
  pushl $0
80107db3:	6a 00                	push   $0x0
  pushl $59
80107db5:	6a 3b                	push   $0x3b
  jmp alltraps
80107db7:	e9 a4 f7 ff ff       	jmp    80107560 <alltraps>

80107dbc <vector60>:
.globl vector60
vector60:
  pushl $0
80107dbc:	6a 00                	push   $0x0
  pushl $60
80107dbe:	6a 3c                	push   $0x3c
  jmp alltraps
80107dc0:	e9 9b f7 ff ff       	jmp    80107560 <alltraps>

80107dc5 <vector61>:
.globl vector61
vector61:
  pushl $0
80107dc5:	6a 00                	push   $0x0
  pushl $61
80107dc7:	6a 3d                	push   $0x3d
  jmp alltraps
80107dc9:	e9 92 f7 ff ff       	jmp    80107560 <alltraps>

80107dce <vector62>:
.globl vector62
vector62:
  pushl $0
80107dce:	6a 00                	push   $0x0
  pushl $62
80107dd0:	6a 3e                	push   $0x3e
  jmp alltraps
80107dd2:	e9 89 f7 ff ff       	jmp    80107560 <alltraps>

80107dd7 <vector63>:
.globl vector63
vector63:
  pushl $0
80107dd7:	6a 00                	push   $0x0
  pushl $63
80107dd9:	6a 3f                	push   $0x3f
  jmp alltraps
80107ddb:	e9 80 f7 ff ff       	jmp    80107560 <alltraps>

80107de0 <vector64>:
.globl vector64
vector64:
  pushl $0
80107de0:	6a 00                	push   $0x0
  pushl $64
80107de2:	6a 40                	push   $0x40
  jmp alltraps
80107de4:	e9 77 f7 ff ff       	jmp    80107560 <alltraps>

80107de9 <vector65>:
.globl vector65
vector65:
  pushl $0
80107de9:	6a 00                	push   $0x0
  pushl $65
80107deb:	6a 41                	push   $0x41
  jmp alltraps
80107ded:	e9 6e f7 ff ff       	jmp    80107560 <alltraps>

80107df2 <vector66>:
.globl vector66
vector66:
  pushl $0
80107df2:	6a 00                	push   $0x0
  pushl $66
80107df4:	6a 42                	push   $0x42
  jmp alltraps
80107df6:	e9 65 f7 ff ff       	jmp    80107560 <alltraps>

80107dfb <vector67>:
.globl vector67
vector67:
  pushl $0
80107dfb:	6a 00                	push   $0x0
  pushl $67
80107dfd:	6a 43                	push   $0x43
  jmp alltraps
80107dff:	e9 5c f7 ff ff       	jmp    80107560 <alltraps>

80107e04 <vector68>:
.globl vector68
vector68:
  pushl $0
80107e04:	6a 00                	push   $0x0
  pushl $68
80107e06:	6a 44                	push   $0x44
  jmp alltraps
80107e08:	e9 53 f7 ff ff       	jmp    80107560 <alltraps>

80107e0d <vector69>:
.globl vector69
vector69:
  pushl $0
80107e0d:	6a 00                	push   $0x0
  pushl $69
80107e0f:	6a 45                	push   $0x45
  jmp alltraps
80107e11:	e9 4a f7 ff ff       	jmp    80107560 <alltraps>

80107e16 <vector70>:
.globl vector70
vector70:
  pushl $0
80107e16:	6a 00                	push   $0x0
  pushl $70
80107e18:	6a 46                	push   $0x46
  jmp alltraps
80107e1a:	e9 41 f7 ff ff       	jmp    80107560 <alltraps>

80107e1f <vector71>:
.globl vector71
vector71:
  pushl $0
80107e1f:	6a 00                	push   $0x0
  pushl $71
80107e21:	6a 47                	push   $0x47
  jmp alltraps
80107e23:	e9 38 f7 ff ff       	jmp    80107560 <alltraps>

80107e28 <vector72>:
.globl vector72
vector72:
  pushl $0
80107e28:	6a 00                	push   $0x0
  pushl $72
80107e2a:	6a 48                	push   $0x48
  jmp alltraps
80107e2c:	e9 2f f7 ff ff       	jmp    80107560 <alltraps>

80107e31 <vector73>:
.globl vector73
vector73:
  pushl $0
80107e31:	6a 00                	push   $0x0
  pushl $73
80107e33:	6a 49                	push   $0x49
  jmp alltraps
80107e35:	e9 26 f7 ff ff       	jmp    80107560 <alltraps>

80107e3a <vector74>:
.globl vector74
vector74:
  pushl $0
80107e3a:	6a 00                	push   $0x0
  pushl $74
80107e3c:	6a 4a                	push   $0x4a
  jmp alltraps
80107e3e:	e9 1d f7 ff ff       	jmp    80107560 <alltraps>

80107e43 <vector75>:
.globl vector75
vector75:
  pushl $0
80107e43:	6a 00                	push   $0x0
  pushl $75
80107e45:	6a 4b                	push   $0x4b
  jmp alltraps
80107e47:	e9 14 f7 ff ff       	jmp    80107560 <alltraps>

80107e4c <vector76>:
.globl vector76
vector76:
  pushl $0
80107e4c:	6a 00                	push   $0x0
  pushl $76
80107e4e:	6a 4c                	push   $0x4c
  jmp alltraps
80107e50:	e9 0b f7 ff ff       	jmp    80107560 <alltraps>

80107e55 <vector77>:
.globl vector77
vector77:
  pushl $0
80107e55:	6a 00                	push   $0x0
  pushl $77
80107e57:	6a 4d                	push   $0x4d
  jmp alltraps
80107e59:	e9 02 f7 ff ff       	jmp    80107560 <alltraps>

80107e5e <vector78>:
.globl vector78
vector78:
  pushl $0
80107e5e:	6a 00                	push   $0x0
  pushl $78
80107e60:	6a 4e                	push   $0x4e
  jmp alltraps
80107e62:	e9 f9 f6 ff ff       	jmp    80107560 <alltraps>

80107e67 <vector79>:
.globl vector79
vector79:
  pushl $0
80107e67:	6a 00                	push   $0x0
  pushl $79
80107e69:	6a 4f                	push   $0x4f
  jmp alltraps
80107e6b:	e9 f0 f6 ff ff       	jmp    80107560 <alltraps>

80107e70 <vector80>:
.globl vector80
vector80:
  pushl $0
80107e70:	6a 00                	push   $0x0
  pushl $80
80107e72:	6a 50                	push   $0x50
  jmp alltraps
80107e74:	e9 e7 f6 ff ff       	jmp    80107560 <alltraps>

80107e79 <vector81>:
.globl vector81
vector81:
  pushl $0
80107e79:	6a 00                	push   $0x0
  pushl $81
80107e7b:	6a 51                	push   $0x51
  jmp alltraps
80107e7d:	e9 de f6 ff ff       	jmp    80107560 <alltraps>

80107e82 <vector82>:
.globl vector82
vector82:
  pushl $0
80107e82:	6a 00                	push   $0x0
  pushl $82
80107e84:	6a 52                	push   $0x52
  jmp alltraps
80107e86:	e9 d5 f6 ff ff       	jmp    80107560 <alltraps>

80107e8b <vector83>:
.globl vector83
vector83:
  pushl $0
80107e8b:	6a 00                	push   $0x0
  pushl $83
80107e8d:	6a 53                	push   $0x53
  jmp alltraps
80107e8f:	e9 cc f6 ff ff       	jmp    80107560 <alltraps>

80107e94 <vector84>:
.globl vector84
vector84:
  pushl $0
80107e94:	6a 00                	push   $0x0
  pushl $84
80107e96:	6a 54                	push   $0x54
  jmp alltraps
80107e98:	e9 c3 f6 ff ff       	jmp    80107560 <alltraps>

80107e9d <vector85>:
.globl vector85
vector85:
  pushl $0
80107e9d:	6a 00                	push   $0x0
  pushl $85
80107e9f:	6a 55                	push   $0x55
  jmp alltraps
80107ea1:	e9 ba f6 ff ff       	jmp    80107560 <alltraps>

80107ea6 <vector86>:
.globl vector86
vector86:
  pushl $0
80107ea6:	6a 00                	push   $0x0
  pushl $86
80107ea8:	6a 56                	push   $0x56
  jmp alltraps
80107eaa:	e9 b1 f6 ff ff       	jmp    80107560 <alltraps>

80107eaf <vector87>:
.globl vector87
vector87:
  pushl $0
80107eaf:	6a 00                	push   $0x0
  pushl $87
80107eb1:	6a 57                	push   $0x57
  jmp alltraps
80107eb3:	e9 a8 f6 ff ff       	jmp    80107560 <alltraps>

80107eb8 <vector88>:
.globl vector88
vector88:
  pushl $0
80107eb8:	6a 00                	push   $0x0
  pushl $88
80107eba:	6a 58                	push   $0x58
  jmp alltraps
80107ebc:	e9 9f f6 ff ff       	jmp    80107560 <alltraps>

80107ec1 <vector89>:
.globl vector89
vector89:
  pushl $0
80107ec1:	6a 00                	push   $0x0
  pushl $89
80107ec3:	6a 59                	push   $0x59
  jmp alltraps
80107ec5:	e9 96 f6 ff ff       	jmp    80107560 <alltraps>

80107eca <vector90>:
.globl vector90
vector90:
  pushl $0
80107eca:	6a 00                	push   $0x0
  pushl $90
80107ecc:	6a 5a                	push   $0x5a
  jmp alltraps
80107ece:	e9 8d f6 ff ff       	jmp    80107560 <alltraps>

80107ed3 <vector91>:
.globl vector91
vector91:
  pushl $0
80107ed3:	6a 00                	push   $0x0
  pushl $91
80107ed5:	6a 5b                	push   $0x5b
  jmp alltraps
80107ed7:	e9 84 f6 ff ff       	jmp    80107560 <alltraps>

80107edc <vector92>:
.globl vector92
vector92:
  pushl $0
80107edc:	6a 00                	push   $0x0
  pushl $92
80107ede:	6a 5c                	push   $0x5c
  jmp alltraps
80107ee0:	e9 7b f6 ff ff       	jmp    80107560 <alltraps>

80107ee5 <vector93>:
.globl vector93
vector93:
  pushl $0
80107ee5:	6a 00                	push   $0x0
  pushl $93
80107ee7:	6a 5d                	push   $0x5d
  jmp alltraps
80107ee9:	e9 72 f6 ff ff       	jmp    80107560 <alltraps>

80107eee <vector94>:
.globl vector94
vector94:
  pushl $0
80107eee:	6a 00                	push   $0x0
  pushl $94
80107ef0:	6a 5e                	push   $0x5e
  jmp alltraps
80107ef2:	e9 69 f6 ff ff       	jmp    80107560 <alltraps>

80107ef7 <vector95>:
.globl vector95
vector95:
  pushl $0
80107ef7:	6a 00                	push   $0x0
  pushl $95
80107ef9:	6a 5f                	push   $0x5f
  jmp alltraps
80107efb:	e9 60 f6 ff ff       	jmp    80107560 <alltraps>

80107f00 <vector96>:
.globl vector96
vector96:
  pushl $0
80107f00:	6a 00                	push   $0x0
  pushl $96
80107f02:	6a 60                	push   $0x60
  jmp alltraps
80107f04:	e9 57 f6 ff ff       	jmp    80107560 <alltraps>

80107f09 <vector97>:
.globl vector97
vector97:
  pushl $0
80107f09:	6a 00                	push   $0x0
  pushl $97
80107f0b:	6a 61                	push   $0x61
  jmp alltraps
80107f0d:	e9 4e f6 ff ff       	jmp    80107560 <alltraps>

80107f12 <vector98>:
.globl vector98
vector98:
  pushl $0
80107f12:	6a 00                	push   $0x0
  pushl $98
80107f14:	6a 62                	push   $0x62
  jmp alltraps
80107f16:	e9 45 f6 ff ff       	jmp    80107560 <alltraps>

80107f1b <vector99>:
.globl vector99
vector99:
  pushl $0
80107f1b:	6a 00                	push   $0x0
  pushl $99
80107f1d:	6a 63                	push   $0x63
  jmp alltraps
80107f1f:	e9 3c f6 ff ff       	jmp    80107560 <alltraps>

80107f24 <vector100>:
.globl vector100
vector100:
  pushl $0
80107f24:	6a 00                	push   $0x0
  pushl $100
80107f26:	6a 64                	push   $0x64
  jmp alltraps
80107f28:	e9 33 f6 ff ff       	jmp    80107560 <alltraps>

80107f2d <vector101>:
.globl vector101
vector101:
  pushl $0
80107f2d:	6a 00                	push   $0x0
  pushl $101
80107f2f:	6a 65                	push   $0x65
  jmp alltraps
80107f31:	e9 2a f6 ff ff       	jmp    80107560 <alltraps>

80107f36 <vector102>:
.globl vector102
vector102:
  pushl $0
80107f36:	6a 00                	push   $0x0
  pushl $102
80107f38:	6a 66                	push   $0x66
  jmp alltraps
80107f3a:	e9 21 f6 ff ff       	jmp    80107560 <alltraps>

80107f3f <vector103>:
.globl vector103
vector103:
  pushl $0
80107f3f:	6a 00                	push   $0x0
  pushl $103
80107f41:	6a 67                	push   $0x67
  jmp alltraps
80107f43:	e9 18 f6 ff ff       	jmp    80107560 <alltraps>

80107f48 <vector104>:
.globl vector104
vector104:
  pushl $0
80107f48:	6a 00                	push   $0x0
  pushl $104
80107f4a:	6a 68                	push   $0x68
  jmp alltraps
80107f4c:	e9 0f f6 ff ff       	jmp    80107560 <alltraps>

80107f51 <vector105>:
.globl vector105
vector105:
  pushl $0
80107f51:	6a 00                	push   $0x0
  pushl $105
80107f53:	6a 69                	push   $0x69
  jmp alltraps
80107f55:	e9 06 f6 ff ff       	jmp    80107560 <alltraps>

80107f5a <vector106>:
.globl vector106
vector106:
  pushl $0
80107f5a:	6a 00                	push   $0x0
  pushl $106
80107f5c:	6a 6a                	push   $0x6a
  jmp alltraps
80107f5e:	e9 fd f5 ff ff       	jmp    80107560 <alltraps>

80107f63 <vector107>:
.globl vector107
vector107:
  pushl $0
80107f63:	6a 00                	push   $0x0
  pushl $107
80107f65:	6a 6b                	push   $0x6b
  jmp alltraps
80107f67:	e9 f4 f5 ff ff       	jmp    80107560 <alltraps>

80107f6c <vector108>:
.globl vector108
vector108:
  pushl $0
80107f6c:	6a 00                	push   $0x0
  pushl $108
80107f6e:	6a 6c                	push   $0x6c
  jmp alltraps
80107f70:	e9 eb f5 ff ff       	jmp    80107560 <alltraps>

80107f75 <vector109>:
.globl vector109
vector109:
  pushl $0
80107f75:	6a 00                	push   $0x0
  pushl $109
80107f77:	6a 6d                	push   $0x6d
  jmp alltraps
80107f79:	e9 e2 f5 ff ff       	jmp    80107560 <alltraps>

80107f7e <vector110>:
.globl vector110
vector110:
  pushl $0
80107f7e:	6a 00                	push   $0x0
  pushl $110
80107f80:	6a 6e                	push   $0x6e
  jmp alltraps
80107f82:	e9 d9 f5 ff ff       	jmp    80107560 <alltraps>

80107f87 <vector111>:
.globl vector111
vector111:
  pushl $0
80107f87:	6a 00                	push   $0x0
  pushl $111
80107f89:	6a 6f                	push   $0x6f
  jmp alltraps
80107f8b:	e9 d0 f5 ff ff       	jmp    80107560 <alltraps>

80107f90 <vector112>:
.globl vector112
vector112:
  pushl $0
80107f90:	6a 00                	push   $0x0
  pushl $112
80107f92:	6a 70                	push   $0x70
  jmp alltraps
80107f94:	e9 c7 f5 ff ff       	jmp    80107560 <alltraps>

80107f99 <vector113>:
.globl vector113
vector113:
  pushl $0
80107f99:	6a 00                	push   $0x0
  pushl $113
80107f9b:	6a 71                	push   $0x71
  jmp alltraps
80107f9d:	e9 be f5 ff ff       	jmp    80107560 <alltraps>

80107fa2 <vector114>:
.globl vector114
vector114:
  pushl $0
80107fa2:	6a 00                	push   $0x0
  pushl $114
80107fa4:	6a 72                	push   $0x72
  jmp alltraps
80107fa6:	e9 b5 f5 ff ff       	jmp    80107560 <alltraps>

80107fab <vector115>:
.globl vector115
vector115:
  pushl $0
80107fab:	6a 00                	push   $0x0
  pushl $115
80107fad:	6a 73                	push   $0x73
  jmp alltraps
80107faf:	e9 ac f5 ff ff       	jmp    80107560 <alltraps>

80107fb4 <vector116>:
.globl vector116
vector116:
  pushl $0
80107fb4:	6a 00                	push   $0x0
  pushl $116
80107fb6:	6a 74                	push   $0x74
  jmp alltraps
80107fb8:	e9 a3 f5 ff ff       	jmp    80107560 <alltraps>

80107fbd <vector117>:
.globl vector117
vector117:
  pushl $0
80107fbd:	6a 00                	push   $0x0
  pushl $117
80107fbf:	6a 75                	push   $0x75
  jmp alltraps
80107fc1:	e9 9a f5 ff ff       	jmp    80107560 <alltraps>

80107fc6 <vector118>:
.globl vector118
vector118:
  pushl $0
80107fc6:	6a 00                	push   $0x0
  pushl $118
80107fc8:	6a 76                	push   $0x76
  jmp alltraps
80107fca:	e9 91 f5 ff ff       	jmp    80107560 <alltraps>

80107fcf <vector119>:
.globl vector119
vector119:
  pushl $0
80107fcf:	6a 00                	push   $0x0
  pushl $119
80107fd1:	6a 77                	push   $0x77
  jmp alltraps
80107fd3:	e9 88 f5 ff ff       	jmp    80107560 <alltraps>

80107fd8 <vector120>:
.globl vector120
vector120:
  pushl $0
80107fd8:	6a 00                	push   $0x0
  pushl $120
80107fda:	6a 78                	push   $0x78
  jmp alltraps
80107fdc:	e9 7f f5 ff ff       	jmp    80107560 <alltraps>

80107fe1 <vector121>:
.globl vector121
vector121:
  pushl $0
80107fe1:	6a 00                	push   $0x0
  pushl $121
80107fe3:	6a 79                	push   $0x79
  jmp alltraps
80107fe5:	e9 76 f5 ff ff       	jmp    80107560 <alltraps>

80107fea <vector122>:
.globl vector122
vector122:
  pushl $0
80107fea:	6a 00                	push   $0x0
  pushl $122
80107fec:	6a 7a                	push   $0x7a
  jmp alltraps
80107fee:	e9 6d f5 ff ff       	jmp    80107560 <alltraps>

80107ff3 <vector123>:
.globl vector123
vector123:
  pushl $0
80107ff3:	6a 00                	push   $0x0
  pushl $123
80107ff5:	6a 7b                	push   $0x7b
  jmp alltraps
80107ff7:	e9 64 f5 ff ff       	jmp    80107560 <alltraps>

80107ffc <vector124>:
.globl vector124
vector124:
  pushl $0
80107ffc:	6a 00                	push   $0x0
  pushl $124
80107ffe:	6a 7c                	push   $0x7c
  jmp alltraps
80108000:	e9 5b f5 ff ff       	jmp    80107560 <alltraps>

80108005 <vector125>:
.globl vector125
vector125:
  pushl $0
80108005:	6a 00                	push   $0x0
  pushl $125
80108007:	6a 7d                	push   $0x7d
  jmp alltraps
80108009:	e9 52 f5 ff ff       	jmp    80107560 <alltraps>

8010800e <vector126>:
.globl vector126
vector126:
  pushl $0
8010800e:	6a 00                	push   $0x0
  pushl $126
80108010:	6a 7e                	push   $0x7e
  jmp alltraps
80108012:	e9 49 f5 ff ff       	jmp    80107560 <alltraps>

80108017 <vector127>:
.globl vector127
vector127:
  pushl $0
80108017:	6a 00                	push   $0x0
  pushl $127
80108019:	6a 7f                	push   $0x7f
  jmp alltraps
8010801b:	e9 40 f5 ff ff       	jmp    80107560 <alltraps>

80108020 <vector128>:
.globl vector128
vector128:
  pushl $0
80108020:	6a 00                	push   $0x0
  pushl $128
80108022:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80108027:	e9 34 f5 ff ff       	jmp    80107560 <alltraps>

8010802c <vector129>:
.globl vector129
vector129:
  pushl $0
8010802c:	6a 00                	push   $0x0
  pushl $129
8010802e:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80108033:	e9 28 f5 ff ff       	jmp    80107560 <alltraps>

80108038 <vector130>:
.globl vector130
vector130:
  pushl $0
80108038:	6a 00                	push   $0x0
  pushl $130
8010803a:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010803f:	e9 1c f5 ff ff       	jmp    80107560 <alltraps>

80108044 <vector131>:
.globl vector131
vector131:
  pushl $0
80108044:	6a 00                	push   $0x0
  pushl $131
80108046:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010804b:	e9 10 f5 ff ff       	jmp    80107560 <alltraps>

80108050 <vector132>:
.globl vector132
vector132:
  pushl $0
80108050:	6a 00                	push   $0x0
  pushl $132
80108052:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80108057:	e9 04 f5 ff ff       	jmp    80107560 <alltraps>

8010805c <vector133>:
.globl vector133
vector133:
  pushl $0
8010805c:	6a 00                	push   $0x0
  pushl $133
8010805e:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80108063:	e9 f8 f4 ff ff       	jmp    80107560 <alltraps>

80108068 <vector134>:
.globl vector134
vector134:
  pushl $0
80108068:	6a 00                	push   $0x0
  pushl $134
8010806a:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010806f:	e9 ec f4 ff ff       	jmp    80107560 <alltraps>

80108074 <vector135>:
.globl vector135
vector135:
  pushl $0
80108074:	6a 00                	push   $0x0
  pushl $135
80108076:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010807b:	e9 e0 f4 ff ff       	jmp    80107560 <alltraps>

80108080 <vector136>:
.globl vector136
vector136:
  pushl $0
80108080:	6a 00                	push   $0x0
  pushl $136
80108082:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80108087:	e9 d4 f4 ff ff       	jmp    80107560 <alltraps>

8010808c <vector137>:
.globl vector137
vector137:
  pushl $0
8010808c:	6a 00                	push   $0x0
  pushl $137
8010808e:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80108093:	e9 c8 f4 ff ff       	jmp    80107560 <alltraps>

80108098 <vector138>:
.globl vector138
vector138:
  pushl $0
80108098:	6a 00                	push   $0x0
  pushl $138
8010809a:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010809f:	e9 bc f4 ff ff       	jmp    80107560 <alltraps>

801080a4 <vector139>:
.globl vector139
vector139:
  pushl $0
801080a4:	6a 00                	push   $0x0
  pushl $139
801080a6:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801080ab:	e9 b0 f4 ff ff       	jmp    80107560 <alltraps>

801080b0 <vector140>:
.globl vector140
vector140:
  pushl $0
801080b0:	6a 00                	push   $0x0
  pushl $140
801080b2:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801080b7:	e9 a4 f4 ff ff       	jmp    80107560 <alltraps>

801080bc <vector141>:
.globl vector141
vector141:
  pushl $0
801080bc:	6a 00                	push   $0x0
  pushl $141
801080be:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801080c3:	e9 98 f4 ff ff       	jmp    80107560 <alltraps>

801080c8 <vector142>:
.globl vector142
vector142:
  pushl $0
801080c8:	6a 00                	push   $0x0
  pushl $142
801080ca:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801080cf:	e9 8c f4 ff ff       	jmp    80107560 <alltraps>

801080d4 <vector143>:
.globl vector143
vector143:
  pushl $0
801080d4:	6a 00                	push   $0x0
  pushl $143
801080d6:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801080db:	e9 80 f4 ff ff       	jmp    80107560 <alltraps>

801080e0 <vector144>:
.globl vector144
vector144:
  pushl $0
801080e0:	6a 00                	push   $0x0
  pushl $144
801080e2:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801080e7:	e9 74 f4 ff ff       	jmp    80107560 <alltraps>

801080ec <vector145>:
.globl vector145
vector145:
  pushl $0
801080ec:	6a 00                	push   $0x0
  pushl $145
801080ee:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801080f3:	e9 68 f4 ff ff       	jmp    80107560 <alltraps>

801080f8 <vector146>:
.globl vector146
vector146:
  pushl $0
801080f8:	6a 00                	push   $0x0
  pushl $146
801080fa:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801080ff:	e9 5c f4 ff ff       	jmp    80107560 <alltraps>

80108104 <vector147>:
.globl vector147
vector147:
  pushl $0
80108104:	6a 00                	push   $0x0
  pushl $147
80108106:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010810b:	e9 50 f4 ff ff       	jmp    80107560 <alltraps>

80108110 <vector148>:
.globl vector148
vector148:
  pushl $0
80108110:	6a 00                	push   $0x0
  pushl $148
80108112:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80108117:	e9 44 f4 ff ff       	jmp    80107560 <alltraps>

8010811c <vector149>:
.globl vector149
vector149:
  pushl $0
8010811c:	6a 00                	push   $0x0
  pushl $149
8010811e:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80108123:	e9 38 f4 ff ff       	jmp    80107560 <alltraps>

80108128 <vector150>:
.globl vector150
vector150:
  pushl $0
80108128:	6a 00                	push   $0x0
  pushl $150
8010812a:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010812f:	e9 2c f4 ff ff       	jmp    80107560 <alltraps>

80108134 <vector151>:
.globl vector151
vector151:
  pushl $0
80108134:	6a 00                	push   $0x0
  pushl $151
80108136:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010813b:	e9 20 f4 ff ff       	jmp    80107560 <alltraps>

80108140 <vector152>:
.globl vector152
vector152:
  pushl $0
80108140:	6a 00                	push   $0x0
  pushl $152
80108142:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80108147:	e9 14 f4 ff ff       	jmp    80107560 <alltraps>

8010814c <vector153>:
.globl vector153
vector153:
  pushl $0
8010814c:	6a 00                	push   $0x0
  pushl $153
8010814e:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80108153:	e9 08 f4 ff ff       	jmp    80107560 <alltraps>

80108158 <vector154>:
.globl vector154
vector154:
  pushl $0
80108158:	6a 00                	push   $0x0
  pushl $154
8010815a:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010815f:	e9 fc f3 ff ff       	jmp    80107560 <alltraps>

80108164 <vector155>:
.globl vector155
vector155:
  pushl $0
80108164:	6a 00                	push   $0x0
  pushl $155
80108166:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010816b:	e9 f0 f3 ff ff       	jmp    80107560 <alltraps>

80108170 <vector156>:
.globl vector156
vector156:
  pushl $0
80108170:	6a 00                	push   $0x0
  pushl $156
80108172:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80108177:	e9 e4 f3 ff ff       	jmp    80107560 <alltraps>

8010817c <vector157>:
.globl vector157
vector157:
  pushl $0
8010817c:	6a 00                	push   $0x0
  pushl $157
8010817e:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80108183:	e9 d8 f3 ff ff       	jmp    80107560 <alltraps>

80108188 <vector158>:
.globl vector158
vector158:
  pushl $0
80108188:	6a 00                	push   $0x0
  pushl $158
8010818a:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010818f:	e9 cc f3 ff ff       	jmp    80107560 <alltraps>

80108194 <vector159>:
.globl vector159
vector159:
  pushl $0
80108194:	6a 00                	push   $0x0
  pushl $159
80108196:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010819b:	e9 c0 f3 ff ff       	jmp    80107560 <alltraps>

801081a0 <vector160>:
.globl vector160
vector160:
  pushl $0
801081a0:	6a 00                	push   $0x0
  pushl $160
801081a2:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801081a7:	e9 b4 f3 ff ff       	jmp    80107560 <alltraps>

801081ac <vector161>:
.globl vector161
vector161:
  pushl $0
801081ac:	6a 00                	push   $0x0
  pushl $161
801081ae:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801081b3:	e9 a8 f3 ff ff       	jmp    80107560 <alltraps>

801081b8 <vector162>:
.globl vector162
vector162:
  pushl $0
801081b8:	6a 00                	push   $0x0
  pushl $162
801081ba:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801081bf:	e9 9c f3 ff ff       	jmp    80107560 <alltraps>

801081c4 <vector163>:
.globl vector163
vector163:
  pushl $0
801081c4:	6a 00                	push   $0x0
  pushl $163
801081c6:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801081cb:	e9 90 f3 ff ff       	jmp    80107560 <alltraps>

801081d0 <vector164>:
.globl vector164
vector164:
  pushl $0
801081d0:	6a 00                	push   $0x0
  pushl $164
801081d2:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801081d7:	e9 84 f3 ff ff       	jmp    80107560 <alltraps>

801081dc <vector165>:
.globl vector165
vector165:
  pushl $0
801081dc:	6a 00                	push   $0x0
  pushl $165
801081de:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801081e3:	e9 78 f3 ff ff       	jmp    80107560 <alltraps>

801081e8 <vector166>:
.globl vector166
vector166:
  pushl $0
801081e8:	6a 00                	push   $0x0
  pushl $166
801081ea:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801081ef:	e9 6c f3 ff ff       	jmp    80107560 <alltraps>

801081f4 <vector167>:
.globl vector167
vector167:
  pushl $0
801081f4:	6a 00                	push   $0x0
  pushl $167
801081f6:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801081fb:	e9 60 f3 ff ff       	jmp    80107560 <alltraps>

80108200 <vector168>:
.globl vector168
vector168:
  pushl $0
80108200:	6a 00                	push   $0x0
  pushl $168
80108202:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80108207:	e9 54 f3 ff ff       	jmp    80107560 <alltraps>

8010820c <vector169>:
.globl vector169
vector169:
  pushl $0
8010820c:	6a 00                	push   $0x0
  pushl $169
8010820e:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80108213:	e9 48 f3 ff ff       	jmp    80107560 <alltraps>

80108218 <vector170>:
.globl vector170
vector170:
  pushl $0
80108218:	6a 00                	push   $0x0
  pushl $170
8010821a:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010821f:	e9 3c f3 ff ff       	jmp    80107560 <alltraps>

80108224 <vector171>:
.globl vector171
vector171:
  pushl $0
80108224:	6a 00                	push   $0x0
  pushl $171
80108226:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
8010822b:	e9 30 f3 ff ff       	jmp    80107560 <alltraps>

80108230 <vector172>:
.globl vector172
vector172:
  pushl $0
80108230:	6a 00                	push   $0x0
  pushl $172
80108232:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80108237:	e9 24 f3 ff ff       	jmp    80107560 <alltraps>

8010823c <vector173>:
.globl vector173
vector173:
  pushl $0
8010823c:	6a 00                	push   $0x0
  pushl $173
8010823e:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80108243:	e9 18 f3 ff ff       	jmp    80107560 <alltraps>

80108248 <vector174>:
.globl vector174
vector174:
  pushl $0
80108248:	6a 00                	push   $0x0
  pushl $174
8010824a:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010824f:	e9 0c f3 ff ff       	jmp    80107560 <alltraps>

80108254 <vector175>:
.globl vector175
vector175:
  pushl $0
80108254:	6a 00                	push   $0x0
  pushl $175
80108256:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010825b:	e9 00 f3 ff ff       	jmp    80107560 <alltraps>

80108260 <vector176>:
.globl vector176
vector176:
  pushl $0
80108260:	6a 00                	push   $0x0
  pushl $176
80108262:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80108267:	e9 f4 f2 ff ff       	jmp    80107560 <alltraps>

8010826c <vector177>:
.globl vector177
vector177:
  pushl $0
8010826c:	6a 00                	push   $0x0
  pushl $177
8010826e:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80108273:	e9 e8 f2 ff ff       	jmp    80107560 <alltraps>

80108278 <vector178>:
.globl vector178
vector178:
  pushl $0
80108278:	6a 00                	push   $0x0
  pushl $178
8010827a:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010827f:	e9 dc f2 ff ff       	jmp    80107560 <alltraps>

80108284 <vector179>:
.globl vector179
vector179:
  pushl $0
80108284:	6a 00                	push   $0x0
  pushl $179
80108286:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010828b:	e9 d0 f2 ff ff       	jmp    80107560 <alltraps>

80108290 <vector180>:
.globl vector180
vector180:
  pushl $0
80108290:	6a 00                	push   $0x0
  pushl $180
80108292:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80108297:	e9 c4 f2 ff ff       	jmp    80107560 <alltraps>

8010829c <vector181>:
.globl vector181
vector181:
  pushl $0
8010829c:	6a 00                	push   $0x0
  pushl $181
8010829e:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801082a3:	e9 b8 f2 ff ff       	jmp    80107560 <alltraps>

801082a8 <vector182>:
.globl vector182
vector182:
  pushl $0
801082a8:	6a 00                	push   $0x0
  pushl $182
801082aa:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801082af:	e9 ac f2 ff ff       	jmp    80107560 <alltraps>

801082b4 <vector183>:
.globl vector183
vector183:
  pushl $0
801082b4:	6a 00                	push   $0x0
  pushl $183
801082b6:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801082bb:	e9 a0 f2 ff ff       	jmp    80107560 <alltraps>

801082c0 <vector184>:
.globl vector184
vector184:
  pushl $0
801082c0:	6a 00                	push   $0x0
  pushl $184
801082c2:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801082c7:	e9 94 f2 ff ff       	jmp    80107560 <alltraps>

801082cc <vector185>:
.globl vector185
vector185:
  pushl $0
801082cc:	6a 00                	push   $0x0
  pushl $185
801082ce:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801082d3:	e9 88 f2 ff ff       	jmp    80107560 <alltraps>

801082d8 <vector186>:
.globl vector186
vector186:
  pushl $0
801082d8:	6a 00                	push   $0x0
  pushl $186
801082da:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801082df:	e9 7c f2 ff ff       	jmp    80107560 <alltraps>

801082e4 <vector187>:
.globl vector187
vector187:
  pushl $0
801082e4:	6a 00                	push   $0x0
  pushl $187
801082e6:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801082eb:	e9 70 f2 ff ff       	jmp    80107560 <alltraps>

801082f0 <vector188>:
.globl vector188
vector188:
  pushl $0
801082f0:	6a 00                	push   $0x0
  pushl $188
801082f2:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801082f7:	e9 64 f2 ff ff       	jmp    80107560 <alltraps>

801082fc <vector189>:
.globl vector189
vector189:
  pushl $0
801082fc:	6a 00                	push   $0x0
  pushl $189
801082fe:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80108303:	e9 58 f2 ff ff       	jmp    80107560 <alltraps>

80108308 <vector190>:
.globl vector190
vector190:
  pushl $0
80108308:	6a 00                	push   $0x0
  pushl $190
8010830a:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010830f:	e9 4c f2 ff ff       	jmp    80107560 <alltraps>

80108314 <vector191>:
.globl vector191
vector191:
  pushl $0
80108314:	6a 00                	push   $0x0
  pushl $191
80108316:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
8010831b:	e9 40 f2 ff ff       	jmp    80107560 <alltraps>

80108320 <vector192>:
.globl vector192
vector192:
  pushl $0
80108320:	6a 00                	push   $0x0
  pushl $192
80108322:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80108327:	e9 34 f2 ff ff       	jmp    80107560 <alltraps>

8010832c <vector193>:
.globl vector193
vector193:
  pushl $0
8010832c:	6a 00                	push   $0x0
  pushl $193
8010832e:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80108333:	e9 28 f2 ff ff       	jmp    80107560 <alltraps>

80108338 <vector194>:
.globl vector194
vector194:
  pushl $0
80108338:	6a 00                	push   $0x0
  pushl $194
8010833a:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010833f:	e9 1c f2 ff ff       	jmp    80107560 <alltraps>

80108344 <vector195>:
.globl vector195
vector195:
  pushl $0
80108344:	6a 00                	push   $0x0
  pushl $195
80108346:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010834b:	e9 10 f2 ff ff       	jmp    80107560 <alltraps>

80108350 <vector196>:
.globl vector196
vector196:
  pushl $0
80108350:	6a 00                	push   $0x0
  pushl $196
80108352:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80108357:	e9 04 f2 ff ff       	jmp    80107560 <alltraps>

8010835c <vector197>:
.globl vector197
vector197:
  pushl $0
8010835c:	6a 00                	push   $0x0
  pushl $197
8010835e:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80108363:	e9 f8 f1 ff ff       	jmp    80107560 <alltraps>

80108368 <vector198>:
.globl vector198
vector198:
  pushl $0
80108368:	6a 00                	push   $0x0
  pushl $198
8010836a:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010836f:	e9 ec f1 ff ff       	jmp    80107560 <alltraps>

80108374 <vector199>:
.globl vector199
vector199:
  pushl $0
80108374:	6a 00                	push   $0x0
  pushl $199
80108376:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010837b:	e9 e0 f1 ff ff       	jmp    80107560 <alltraps>

80108380 <vector200>:
.globl vector200
vector200:
  pushl $0
80108380:	6a 00                	push   $0x0
  pushl $200
80108382:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80108387:	e9 d4 f1 ff ff       	jmp    80107560 <alltraps>

8010838c <vector201>:
.globl vector201
vector201:
  pushl $0
8010838c:	6a 00                	push   $0x0
  pushl $201
8010838e:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80108393:	e9 c8 f1 ff ff       	jmp    80107560 <alltraps>

80108398 <vector202>:
.globl vector202
vector202:
  pushl $0
80108398:	6a 00                	push   $0x0
  pushl $202
8010839a:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010839f:	e9 bc f1 ff ff       	jmp    80107560 <alltraps>

801083a4 <vector203>:
.globl vector203
vector203:
  pushl $0
801083a4:	6a 00                	push   $0x0
  pushl $203
801083a6:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801083ab:	e9 b0 f1 ff ff       	jmp    80107560 <alltraps>

801083b0 <vector204>:
.globl vector204
vector204:
  pushl $0
801083b0:	6a 00                	push   $0x0
  pushl $204
801083b2:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801083b7:	e9 a4 f1 ff ff       	jmp    80107560 <alltraps>

801083bc <vector205>:
.globl vector205
vector205:
  pushl $0
801083bc:	6a 00                	push   $0x0
  pushl $205
801083be:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801083c3:	e9 98 f1 ff ff       	jmp    80107560 <alltraps>

801083c8 <vector206>:
.globl vector206
vector206:
  pushl $0
801083c8:	6a 00                	push   $0x0
  pushl $206
801083ca:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801083cf:	e9 8c f1 ff ff       	jmp    80107560 <alltraps>

801083d4 <vector207>:
.globl vector207
vector207:
  pushl $0
801083d4:	6a 00                	push   $0x0
  pushl $207
801083d6:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801083db:	e9 80 f1 ff ff       	jmp    80107560 <alltraps>

801083e0 <vector208>:
.globl vector208
vector208:
  pushl $0
801083e0:	6a 00                	push   $0x0
  pushl $208
801083e2:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801083e7:	e9 74 f1 ff ff       	jmp    80107560 <alltraps>

801083ec <vector209>:
.globl vector209
vector209:
  pushl $0
801083ec:	6a 00                	push   $0x0
  pushl $209
801083ee:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801083f3:	e9 68 f1 ff ff       	jmp    80107560 <alltraps>

801083f8 <vector210>:
.globl vector210
vector210:
  pushl $0
801083f8:	6a 00                	push   $0x0
  pushl $210
801083fa:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801083ff:	e9 5c f1 ff ff       	jmp    80107560 <alltraps>

80108404 <vector211>:
.globl vector211
vector211:
  pushl $0
80108404:	6a 00                	push   $0x0
  pushl $211
80108406:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
8010840b:	e9 50 f1 ff ff       	jmp    80107560 <alltraps>

80108410 <vector212>:
.globl vector212
vector212:
  pushl $0
80108410:	6a 00                	push   $0x0
  pushl $212
80108412:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80108417:	e9 44 f1 ff ff       	jmp    80107560 <alltraps>

8010841c <vector213>:
.globl vector213
vector213:
  pushl $0
8010841c:	6a 00                	push   $0x0
  pushl $213
8010841e:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80108423:	e9 38 f1 ff ff       	jmp    80107560 <alltraps>

80108428 <vector214>:
.globl vector214
vector214:
  pushl $0
80108428:	6a 00                	push   $0x0
  pushl $214
8010842a:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010842f:	e9 2c f1 ff ff       	jmp    80107560 <alltraps>

80108434 <vector215>:
.globl vector215
vector215:
  pushl $0
80108434:	6a 00                	push   $0x0
  pushl $215
80108436:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010843b:	e9 20 f1 ff ff       	jmp    80107560 <alltraps>

80108440 <vector216>:
.globl vector216
vector216:
  pushl $0
80108440:	6a 00                	push   $0x0
  pushl $216
80108442:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80108447:	e9 14 f1 ff ff       	jmp    80107560 <alltraps>

8010844c <vector217>:
.globl vector217
vector217:
  pushl $0
8010844c:	6a 00                	push   $0x0
  pushl $217
8010844e:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80108453:	e9 08 f1 ff ff       	jmp    80107560 <alltraps>

80108458 <vector218>:
.globl vector218
vector218:
  pushl $0
80108458:	6a 00                	push   $0x0
  pushl $218
8010845a:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010845f:	e9 fc f0 ff ff       	jmp    80107560 <alltraps>

80108464 <vector219>:
.globl vector219
vector219:
  pushl $0
80108464:	6a 00                	push   $0x0
  pushl $219
80108466:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010846b:	e9 f0 f0 ff ff       	jmp    80107560 <alltraps>

80108470 <vector220>:
.globl vector220
vector220:
  pushl $0
80108470:	6a 00                	push   $0x0
  pushl $220
80108472:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80108477:	e9 e4 f0 ff ff       	jmp    80107560 <alltraps>

8010847c <vector221>:
.globl vector221
vector221:
  pushl $0
8010847c:	6a 00                	push   $0x0
  pushl $221
8010847e:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80108483:	e9 d8 f0 ff ff       	jmp    80107560 <alltraps>

80108488 <vector222>:
.globl vector222
vector222:
  pushl $0
80108488:	6a 00                	push   $0x0
  pushl $222
8010848a:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010848f:	e9 cc f0 ff ff       	jmp    80107560 <alltraps>

80108494 <vector223>:
.globl vector223
vector223:
  pushl $0
80108494:	6a 00                	push   $0x0
  pushl $223
80108496:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010849b:	e9 c0 f0 ff ff       	jmp    80107560 <alltraps>

801084a0 <vector224>:
.globl vector224
vector224:
  pushl $0
801084a0:	6a 00                	push   $0x0
  pushl $224
801084a2:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801084a7:	e9 b4 f0 ff ff       	jmp    80107560 <alltraps>

801084ac <vector225>:
.globl vector225
vector225:
  pushl $0
801084ac:	6a 00                	push   $0x0
  pushl $225
801084ae:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801084b3:	e9 a8 f0 ff ff       	jmp    80107560 <alltraps>

801084b8 <vector226>:
.globl vector226
vector226:
  pushl $0
801084b8:	6a 00                	push   $0x0
  pushl $226
801084ba:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801084bf:	e9 9c f0 ff ff       	jmp    80107560 <alltraps>

801084c4 <vector227>:
.globl vector227
vector227:
  pushl $0
801084c4:	6a 00                	push   $0x0
  pushl $227
801084c6:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801084cb:	e9 90 f0 ff ff       	jmp    80107560 <alltraps>

801084d0 <vector228>:
.globl vector228
vector228:
  pushl $0
801084d0:	6a 00                	push   $0x0
  pushl $228
801084d2:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801084d7:	e9 84 f0 ff ff       	jmp    80107560 <alltraps>

801084dc <vector229>:
.globl vector229
vector229:
  pushl $0
801084dc:	6a 00                	push   $0x0
  pushl $229
801084de:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801084e3:	e9 78 f0 ff ff       	jmp    80107560 <alltraps>

801084e8 <vector230>:
.globl vector230
vector230:
  pushl $0
801084e8:	6a 00                	push   $0x0
  pushl $230
801084ea:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801084ef:	e9 6c f0 ff ff       	jmp    80107560 <alltraps>

801084f4 <vector231>:
.globl vector231
vector231:
  pushl $0
801084f4:	6a 00                	push   $0x0
  pushl $231
801084f6:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801084fb:	e9 60 f0 ff ff       	jmp    80107560 <alltraps>

80108500 <vector232>:
.globl vector232
vector232:
  pushl $0
80108500:	6a 00                	push   $0x0
  pushl $232
80108502:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80108507:	e9 54 f0 ff ff       	jmp    80107560 <alltraps>

8010850c <vector233>:
.globl vector233
vector233:
  pushl $0
8010850c:	6a 00                	push   $0x0
  pushl $233
8010850e:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80108513:	e9 48 f0 ff ff       	jmp    80107560 <alltraps>

80108518 <vector234>:
.globl vector234
vector234:
  pushl $0
80108518:	6a 00                	push   $0x0
  pushl $234
8010851a:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010851f:	e9 3c f0 ff ff       	jmp    80107560 <alltraps>

80108524 <vector235>:
.globl vector235
vector235:
  pushl $0
80108524:	6a 00                	push   $0x0
  pushl $235
80108526:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
8010852b:	e9 30 f0 ff ff       	jmp    80107560 <alltraps>

80108530 <vector236>:
.globl vector236
vector236:
  pushl $0
80108530:	6a 00                	push   $0x0
  pushl $236
80108532:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80108537:	e9 24 f0 ff ff       	jmp    80107560 <alltraps>

8010853c <vector237>:
.globl vector237
vector237:
  pushl $0
8010853c:	6a 00                	push   $0x0
  pushl $237
8010853e:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80108543:	e9 18 f0 ff ff       	jmp    80107560 <alltraps>

80108548 <vector238>:
.globl vector238
vector238:
  pushl $0
80108548:	6a 00                	push   $0x0
  pushl $238
8010854a:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010854f:	e9 0c f0 ff ff       	jmp    80107560 <alltraps>

80108554 <vector239>:
.globl vector239
vector239:
  pushl $0
80108554:	6a 00                	push   $0x0
  pushl $239
80108556:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010855b:	e9 00 f0 ff ff       	jmp    80107560 <alltraps>

80108560 <vector240>:
.globl vector240
vector240:
  pushl $0
80108560:	6a 00                	push   $0x0
  pushl $240
80108562:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80108567:	e9 f4 ef ff ff       	jmp    80107560 <alltraps>

8010856c <vector241>:
.globl vector241
vector241:
  pushl $0
8010856c:	6a 00                	push   $0x0
  pushl $241
8010856e:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80108573:	e9 e8 ef ff ff       	jmp    80107560 <alltraps>

80108578 <vector242>:
.globl vector242
vector242:
  pushl $0
80108578:	6a 00                	push   $0x0
  pushl $242
8010857a:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010857f:	e9 dc ef ff ff       	jmp    80107560 <alltraps>

80108584 <vector243>:
.globl vector243
vector243:
  pushl $0
80108584:	6a 00                	push   $0x0
  pushl $243
80108586:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010858b:	e9 d0 ef ff ff       	jmp    80107560 <alltraps>

80108590 <vector244>:
.globl vector244
vector244:
  pushl $0
80108590:	6a 00                	push   $0x0
  pushl $244
80108592:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80108597:	e9 c4 ef ff ff       	jmp    80107560 <alltraps>

8010859c <vector245>:
.globl vector245
vector245:
  pushl $0
8010859c:	6a 00                	push   $0x0
  pushl $245
8010859e:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801085a3:	e9 b8 ef ff ff       	jmp    80107560 <alltraps>

801085a8 <vector246>:
.globl vector246
vector246:
  pushl $0
801085a8:	6a 00                	push   $0x0
  pushl $246
801085aa:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801085af:	e9 ac ef ff ff       	jmp    80107560 <alltraps>

801085b4 <vector247>:
.globl vector247
vector247:
  pushl $0
801085b4:	6a 00                	push   $0x0
  pushl $247
801085b6:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801085bb:	e9 a0 ef ff ff       	jmp    80107560 <alltraps>

801085c0 <vector248>:
.globl vector248
vector248:
  pushl $0
801085c0:	6a 00                	push   $0x0
  pushl $248
801085c2:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801085c7:	e9 94 ef ff ff       	jmp    80107560 <alltraps>

801085cc <vector249>:
.globl vector249
vector249:
  pushl $0
801085cc:	6a 00                	push   $0x0
  pushl $249
801085ce:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801085d3:	e9 88 ef ff ff       	jmp    80107560 <alltraps>

801085d8 <vector250>:
.globl vector250
vector250:
  pushl $0
801085d8:	6a 00                	push   $0x0
  pushl $250
801085da:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801085df:	e9 7c ef ff ff       	jmp    80107560 <alltraps>

801085e4 <vector251>:
.globl vector251
vector251:
  pushl $0
801085e4:	6a 00                	push   $0x0
  pushl $251
801085e6:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801085eb:	e9 70 ef ff ff       	jmp    80107560 <alltraps>

801085f0 <vector252>:
.globl vector252
vector252:
  pushl $0
801085f0:	6a 00                	push   $0x0
  pushl $252
801085f2:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801085f7:	e9 64 ef ff ff       	jmp    80107560 <alltraps>

801085fc <vector253>:
.globl vector253
vector253:
  pushl $0
801085fc:	6a 00                	push   $0x0
  pushl $253
801085fe:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80108603:	e9 58 ef ff ff       	jmp    80107560 <alltraps>

80108608 <vector254>:
.globl vector254
vector254:
  pushl $0
80108608:	6a 00                	push   $0x0
  pushl $254
8010860a:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010860f:	e9 4c ef ff ff       	jmp    80107560 <alltraps>

80108614 <vector255>:
.globl vector255
vector255:
  pushl $0
80108614:	6a 00                	push   $0x0
  pushl $255
80108616:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
8010861b:	e9 40 ef ff ff       	jmp    80107560 <alltraps>

80108620 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80108620:	55                   	push   %ebp
80108621:	89 e5                	mov    %esp,%ebp
80108623:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80108626:	8b 45 0c             	mov    0xc(%ebp),%eax
80108629:	83 e8 01             	sub    $0x1,%eax
8010862c:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80108630:	8b 45 08             	mov    0x8(%ebp),%eax
80108633:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80108637:	8b 45 08             	mov    0x8(%ebp),%eax
8010863a:	c1 e8 10             	shr    $0x10,%eax
8010863d:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80108641:	8d 45 fa             	lea    -0x6(%ebp),%eax
80108644:	0f 01 10             	lgdtl  (%eax)
}
80108647:	90                   	nop
80108648:	c9                   	leave  
80108649:	c3                   	ret    

8010864a <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
8010864a:	55                   	push   %ebp
8010864b:	89 e5                	mov    %esp,%ebp
8010864d:	83 ec 04             	sub    $0x4,%esp
80108650:	8b 45 08             	mov    0x8(%ebp),%eax
80108653:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80108657:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010865b:	0f 00 d8             	ltr    %ax
}
8010865e:	90                   	nop
8010865f:	c9                   	leave  
80108660:	c3                   	ret    

80108661 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80108661:	55                   	push   %ebp
80108662:	89 e5                	mov    %esp,%ebp
80108664:	83 ec 04             	sub    $0x4,%esp
80108667:	8b 45 08             	mov    0x8(%ebp),%eax
8010866a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
8010866e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108672:	8e e8                	mov    %eax,%gs
}
80108674:	90                   	nop
80108675:	c9                   	leave  
80108676:	c3                   	ret    

80108677 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80108677:	55                   	push   %ebp
80108678:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010867a:	8b 45 08             	mov    0x8(%ebp),%eax
8010867d:	0f 22 d8             	mov    %eax,%cr3
}
80108680:	90                   	nop
80108681:	5d                   	pop    %ebp
80108682:	c3                   	ret    

80108683 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80108683:	55                   	push   %ebp
80108684:	89 e5                	mov    %esp,%ebp
80108686:	8b 45 08             	mov    0x8(%ebp),%eax
80108689:	05 00 00 00 80       	add    $0x80000000,%eax
8010868e:	5d                   	pop    %ebp
8010868f:	c3                   	ret    

80108690 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80108690:	55                   	push   %ebp
80108691:	89 e5                	mov    %esp,%ebp
80108693:	8b 45 08             	mov    0x8(%ebp),%eax
80108696:	05 00 00 00 80       	add    $0x80000000,%eax
8010869b:	5d                   	pop    %ebp
8010869c:	c3                   	ret    

8010869d <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010869d:	55                   	push   %ebp
8010869e:	89 e5                	mov    %esp,%ebp
801086a0:	53                   	push   %ebx
801086a1:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801086a4:	e8 32 aa ff ff       	call   801030db <cpunum>
801086a9:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801086af:	05 a0 33 11 80       	add    $0x801133a0,%eax
801086b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801086b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ba:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801086c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c3:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801086c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086cc:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801086d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d3:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801086d7:	83 e2 f0             	and    $0xfffffff0,%edx
801086da:	83 ca 0a             	or     $0xa,%edx
801086dd:	88 50 7d             	mov    %dl,0x7d(%eax)
801086e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e3:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801086e7:	83 ca 10             	or     $0x10,%edx
801086ea:	88 50 7d             	mov    %dl,0x7d(%eax)
801086ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f0:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801086f4:	83 e2 9f             	and    $0xffffff9f,%edx
801086f7:	88 50 7d             	mov    %dl,0x7d(%eax)
801086fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086fd:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108701:	83 ca 80             	or     $0xffffff80,%edx
80108704:	88 50 7d             	mov    %dl,0x7d(%eax)
80108707:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010870a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010870e:	83 ca 0f             	or     $0xf,%edx
80108711:	88 50 7e             	mov    %dl,0x7e(%eax)
80108714:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108717:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010871b:	83 e2 ef             	and    $0xffffffef,%edx
8010871e:	88 50 7e             	mov    %dl,0x7e(%eax)
80108721:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108724:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108728:	83 e2 df             	and    $0xffffffdf,%edx
8010872b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010872e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108731:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108735:	83 ca 40             	or     $0x40,%edx
80108738:	88 50 7e             	mov    %dl,0x7e(%eax)
8010873b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010873e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108742:	83 ca 80             	or     $0xffffff80,%edx
80108745:	88 50 7e             	mov    %dl,0x7e(%eax)
80108748:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010874b:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010874f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108752:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80108759:	ff ff 
8010875b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010875e:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80108765:	00 00 
80108767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010876a:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80108771:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108774:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010877b:	83 e2 f0             	and    $0xfffffff0,%edx
8010877e:	83 ca 02             	or     $0x2,%edx
80108781:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108787:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010878a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108791:	83 ca 10             	or     $0x10,%edx
80108794:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010879a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010879d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801087a4:	83 e2 9f             	and    $0xffffff9f,%edx
801087a7:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801087ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087b0:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801087b7:	83 ca 80             	or     $0xffffff80,%edx
801087ba:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801087c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087c3:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801087ca:	83 ca 0f             	or     $0xf,%edx
801087cd:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801087d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087d6:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801087dd:	83 e2 ef             	and    $0xffffffef,%edx
801087e0:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801087e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087e9:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801087f0:	83 e2 df             	and    $0xffffffdf,%edx
801087f3:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801087f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087fc:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108803:	83 ca 40             	or     $0x40,%edx
80108806:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010880c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010880f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108816:	83 ca 80             	or     $0xffffff80,%edx
80108819:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010881f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108822:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80108829:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010882c:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80108833:	ff ff 
80108835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108838:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010883f:	00 00 
80108841:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108844:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010884b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010884e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108855:	83 e2 f0             	and    $0xfffffff0,%edx
80108858:	83 ca 0a             	or     $0xa,%edx
8010885b:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108861:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108864:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010886b:	83 ca 10             	or     $0x10,%edx
8010886e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108874:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108877:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010887e:	83 ca 60             	or     $0x60,%edx
80108881:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108887:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010888a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108891:	83 ca 80             	or     $0xffffff80,%edx
80108894:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010889a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010889d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801088a4:	83 ca 0f             	or     $0xf,%edx
801088a7:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801088ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b0:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801088b7:	83 e2 ef             	and    $0xffffffef,%edx
801088ba:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801088c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088c3:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801088ca:	83 e2 df             	and    $0xffffffdf,%edx
801088cd:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801088d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088d6:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801088dd:	83 ca 40             	or     $0x40,%edx
801088e0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801088e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088e9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801088f0:	83 ca 80             	or     $0xffffff80,%edx
801088f3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801088f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088fc:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80108903:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108906:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
8010890d:	ff ff 
8010890f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108912:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80108919:	00 00 
8010891b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010891e:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80108925:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108928:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010892f:	83 e2 f0             	and    $0xfffffff0,%edx
80108932:	83 ca 02             	or     $0x2,%edx
80108935:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010893b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010893e:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108945:	83 ca 10             	or     $0x10,%edx
80108948:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010894e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108951:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108958:	83 ca 60             	or     $0x60,%edx
8010895b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108961:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108964:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010896b:	83 ca 80             	or     $0xffffff80,%edx
8010896e:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108974:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108977:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010897e:	83 ca 0f             	or     $0xf,%edx
80108981:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010898a:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108991:	83 e2 ef             	and    $0xffffffef,%edx
80108994:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010899a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010899d:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801089a4:	83 e2 df             	and    $0xffffffdf,%edx
801089a7:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801089ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089b0:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801089b7:	83 ca 40             	or     $0x40,%edx
801089ba:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801089c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c3:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801089ca:	83 ca 80             	or     $0xffffff80,%edx
801089cd:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801089d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089d6:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801089dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089e0:	05 b4 00 00 00       	add    $0xb4,%eax
801089e5:	89 c3                	mov    %eax,%ebx
801089e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ea:	05 b4 00 00 00       	add    $0xb4,%eax
801089ef:	c1 e8 10             	shr    $0x10,%eax
801089f2:	89 c2                	mov    %eax,%edx
801089f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089f7:	05 b4 00 00 00       	add    $0xb4,%eax
801089fc:	c1 e8 18             	shr    $0x18,%eax
801089ff:	89 c1                	mov    %eax,%ecx
80108a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a04:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80108a0b:	00 00 
80108a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a10:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80108a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a1a:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80108a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a23:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108a2a:	83 e2 f0             	and    $0xfffffff0,%edx
80108a2d:	83 ca 02             	or     $0x2,%edx
80108a30:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a39:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108a40:	83 ca 10             	or     $0x10,%edx
80108a43:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108a49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a4c:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108a53:	83 e2 9f             	and    $0xffffff9f,%edx
80108a56:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a5f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108a66:	83 ca 80             	or     $0xffffff80,%edx
80108a69:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a72:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108a79:	83 e2 f0             	and    $0xfffffff0,%edx
80108a7c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a85:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108a8c:	83 e2 ef             	and    $0xffffffef,%edx
80108a8f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a98:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108a9f:	83 e2 df             	and    $0xffffffdf,%edx
80108aa2:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aab:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108ab2:	83 ca 40             	or     $0x40,%edx
80108ab5:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108abe:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108ac5:	83 ca 80             	or     $0xffffff80,%edx
80108ac8:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ad1:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80108ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ada:	83 c0 70             	add    $0x70,%eax
80108add:	83 ec 08             	sub    $0x8,%esp
80108ae0:	6a 38                	push   $0x38
80108ae2:	50                   	push   %eax
80108ae3:	e8 38 fb ff ff       	call   80108620 <lgdt>
80108ae8:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80108aeb:	83 ec 0c             	sub    $0xc,%esp
80108aee:	6a 18                	push   $0x18
80108af0:	e8 6c fb ff ff       	call   80108661 <loadgs>
80108af5:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80108af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108afb:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80108b01:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80108b08:	00 00 00 00 
}
80108b0c:	90                   	nop
80108b0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108b10:	c9                   	leave  
80108b11:	c3                   	ret    

80108b12 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108b12:	55                   	push   %ebp
80108b13:	89 e5                	mov    %esp,%ebp
80108b15:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108b18:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b1b:	c1 e8 16             	shr    $0x16,%eax
80108b1e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108b25:	8b 45 08             	mov    0x8(%ebp),%eax
80108b28:	01 d0                	add    %edx,%eax
80108b2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108b2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b30:	8b 00                	mov    (%eax),%eax
80108b32:	83 e0 01             	and    $0x1,%eax
80108b35:	85 c0                	test   %eax,%eax
80108b37:	74 18                	je     80108b51 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80108b39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b3c:	8b 00                	mov    (%eax),%eax
80108b3e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b43:	50                   	push   %eax
80108b44:	e8 47 fb ff ff       	call   80108690 <p2v>
80108b49:	83 c4 04             	add    $0x4,%esp
80108b4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108b4f:	eb 48                	jmp    80108b99 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108b51:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108b55:	74 0e                	je     80108b65 <walkpgdir+0x53>
80108b57:	e8 19 a2 ff ff       	call   80102d75 <kalloc>
80108b5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108b5f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108b63:	75 07                	jne    80108b6c <walkpgdir+0x5a>
      return 0;
80108b65:	b8 00 00 00 00       	mov    $0x0,%eax
80108b6a:	eb 44                	jmp    80108bb0 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108b6c:	83 ec 04             	sub    $0x4,%esp
80108b6f:	68 00 10 00 00       	push   $0x1000
80108b74:	6a 00                	push   $0x0
80108b76:	ff 75 f4             	pushl  -0xc(%ebp)
80108b79:	e8 1e d2 ff ff       	call   80105d9c <memset>
80108b7e:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80108b81:	83 ec 0c             	sub    $0xc,%esp
80108b84:	ff 75 f4             	pushl  -0xc(%ebp)
80108b87:	e8 f7 fa ff ff       	call   80108683 <v2p>
80108b8c:	83 c4 10             	add    $0x10,%esp
80108b8f:	83 c8 07             	or     $0x7,%eax
80108b92:	89 c2                	mov    %eax,%edx
80108b94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b97:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108b99:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b9c:	c1 e8 0c             	shr    $0xc,%eax
80108b9f:	25 ff 03 00 00       	and    $0x3ff,%eax
80108ba4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bae:	01 d0                	add    %edx,%eax
}
80108bb0:	c9                   	leave  
80108bb1:	c3                   	ret    

80108bb2 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108bb2:	55                   	push   %ebp
80108bb3:	89 e5                	mov    %esp,%ebp
80108bb5:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80108bb8:	8b 45 0c             	mov    0xc(%ebp),%eax
80108bbb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108bc0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108bc3:	8b 55 0c             	mov    0xc(%ebp),%edx
80108bc6:	8b 45 10             	mov    0x10(%ebp),%eax
80108bc9:	01 d0                	add    %edx,%eax
80108bcb:	83 e8 01             	sub    $0x1,%eax
80108bce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108bd3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108bd6:	83 ec 04             	sub    $0x4,%esp
80108bd9:	6a 01                	push   $0x1
80108bdb:	ff 75 f4             	pushl  -0xc(%ebp)
80108bde:	ff 75 08             	pushl  0x8(%ebp)
80108be1:	e8 2c ff ff ff       	call   80108b12 <walkpgdir>
80108be6:	83 c4 10             	add    $0x10,%esp
80108be9:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108bec:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108bf0:	75 07                	jne    80108bf9 <mappages+0x47>
      return -1;
80108bf2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108bf7:	eb 47                	jmp    80108c40 <mappages+0x8e>
    if(*pte & PTE_P)
80108bf9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bfc:	8b 00                	mov    (%eax),%eax
80108bfe:	83 e0 01             	and    $0x1,%eax
80108c01:	85 c0                	test   %eax,%eax
80108c03:	74 0d                	je     80108c12 <mappages+0x60>
      panic("remap");
80108c05:	83 ec 0c             	sub    $0xc,%esp
80108c08:	68 64 9b 10 80       	push   $0x80109b64
80108c0d:	e8 54 79 ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
80108c12:	8b 45 18             	mov    0x18(%ebp),%eax
80108c15:	0b 45 14             	or     0x14(%ebp),%eax
80108c18:	83 c8 01             	or     $0x1,%eax
80108c1b:	89 c2                	mov    %eax,%edx
80108c1d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c20:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c25:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108c28:	74 10                	je     80108c3a <mappages+0x88>
      break;
    a += PGSIZE;
80108c2a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108c31:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108c38:	eb 9c                	jmp    80108bd6 <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80108c3a:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108c3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108c40:	c9                   	leave  
80108c41:	c3                   	ret    

80108c42 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108c42:	55                   	push   %ebp
80108c43:	89 e5                	mov    %esp,%ebp
80108c45:	53                   	push   %ebx
80108c46:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108c49:	e8 27 a1 ff ff       	call   80102d75 <kalloc>
80108c4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108c51:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108c55:	75 0a                	jne    80108c61 <setupkvm+0x1f>
    return 0;
80108c57:	b8 00 00 00 00       	mov    $0x0,%eax
80108c5c:	e9 8e 00 00 00       	jmp    80108cef <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80108c61:	83 ec 04             	sub    $0x4,%esp
80108c64:	68 00 10 00 00       	push   $0x1000
80108c69:	6a 00                	push   $0x0
80108c6b:	ff 75 f0             	pushl  -0x10(%ebp)
80108c6e:	e8 29 d1 ff ff       	call   80105d9c <memset>
80108c73:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108c76:	83 ec 0c             	sub    $0xc,%esp
80108c79:	68 00 00 00 0e       	push   $0xe000000
80108c7e:	e8 0d fa ff ff       	call   80108690 <p2v>
80108c83:	83 c4 10             	add    $0x10,%esp
80108c86:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108c8b:	76 0d                	jbe    80108c9a <setupkvm+0x58>
    panic("PHYSTOP too high");
80108c8d:	83 ec 0c             	sub    $0xc,%esp
80108c90:	68 6a 9b 10 80       	push   $0x80109b6a
80108c95:	e8 cc 78 ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108c9a:	c7 45 f4 e0 c4 10 80 	movl   $0x8010c4e0,-0xc(%ebp)
80108ca1:	eb 40                	jmp    80108ce3 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108ca3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ca6:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cac:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cb2:	8b 58 08             	mov    0x8(%eax),%ebx
80108cb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cb8:	8b 40 04             	mov    0x4(%eax),%eax
80108cbb:	29 c3                	sub    %eax,%ebx
80108cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cc0:	8b 00                	mov    (%eax),%eax
80108cc2:	83 ec 0c             	sub    $0xc,%esp
80108cc5:	51                   	push   %ecx
80108cc6:	52                   	push   %edx
80108cc7:	53                   	push   %ebx
80108cc8:	50                   	push   %eax
80108cc9:	ff 75 f0             	pushl  -0x10(%ebp)
80108ccc:	e8 e1 fe ff ff       	call   80108bb2 <mappages>
80108cd1:	83 c4 20             	add    $0x20,%esp
80108cd4:	85 c0                	test   %eax,%eax
80108cd6:	79 07                	jns    80108cdf <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108cd8:	b8 00 00 00 00       	mov    $0x0,%eax
80108cdd:	eb 10                	jmp    80108cef <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108cdf:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108ce3:	81 7d f4 20 c5 10 80 	cmpl   $0x8010c520,-0xc(%ebp)
80108cea:	72 b7                	jb     80108ca3 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108cec:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108cef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108cf2:	c9                   	leave  
80108cf3:	c3                   	ret    

80108cf4 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108cf4:	55                   	push   %ebp
80108cf5:	89 e5                	mov    %esp,%ebp
80108cf7:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108cfa:	e8 43 ff ff ff       	call   80108c42 <setupkvm>
80108cff:	a3 98 69 11 80       	mov    %eax,0x80116998
  switchkvm();
80108d04:	e8 03 00 00 00       	call   80108d0c <switchkvm>
}
80108d09:	90                   	nop
80108d0a:	c9                   	leave  
80108d0b:	c3                   	ret    

80108d0c <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108d0c:	55                   	push   %ebp
80108d0d:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108d0f:	a1 98 69 11 80       	mov    0x80116998,%eax
80108d14:	50                   	push   %eax
80108d15:	e8 69 f9 ff ff       	call   80108683 <v2p>
80108d1a:	83 c4 04             	add    $0x4,%esp
80108d1d:	50                   	push   %eax
80108d1e:	e8 54 f9 ff ff       	call   80108677 <lcr3>
80108d23:	83 c4 04             	add    $0x4,%esp
}
80108d26:	90                   	nop
80108d27:	c9                   	leave  
80108d28:	c3                   	ret    

80108d29 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108d29:	55                   	push   %ebp
80108d2a:	89 e5                	mov    %esp,%ebp
80108d2c:	56                   	push   %esi
80108d2d:	53                   	push   %ebx
  pushcli();
80108d2e:	e8 63 cf ff ff       	call   80105c96 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108d33:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108d39:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108d40:	83 c2 08             	add    $0x8,%edx
80108d43:	89 d6                	mov    %edx,%esi
80108d45:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108d4c:	83 c2 08             	add    $0x8,%edx
80108d4f:	c1 ea 10             	shr    $0x10,%edx
80108d52:	89 d3                	mov    %edx,%ebx
80108d54:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108d5b:	83 c2 08             	add    $0x8,%edx
80108d5e:	c1 ea 18             	shr    $0x18,%edx
80108d61:	89 d1                	mov    %edx,%ecx
80108d63:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108d6a:	67 00 
80108d6c:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108d73:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108d79:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108d80:	83 e2 f0             	and    $0xfffffff0,%edx
80108d83:	83 ca 09             	or     $0x9,%edx
80108d86:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108d8c:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108d93:	83 ca 10             	or     $0x10,%edx
80108d96:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108d9c:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108da3:	83 e2 9f             	and    $0xffffff9f,%edx
80108da6:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108dac:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108db3:	83 ca 80             	or     $0xffffff80,%edx
80108db6:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108dbc:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108dc3:	83 e2 f0             	and    $0xfffffff0,%edx
80108dc6:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108dcc:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108dd3:	83 e2 ef             	and    $0xffffffef,%edx
80108dd6:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108ddc:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108de3:	83 e2 df             	and    $0xffffffdf,%edx
80108de6:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108dec:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108df3:	83 ca 40             	or     $0x40,%edx
80108df6:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108dfc:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108e03:	83 e2 7f             	and    $0x7f,%edx
80108e06:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108e0c:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108e12:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108e18:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108e1f:	83 e2 ef             	and    $0xffffffef,%edx
80108e22:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108e28:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108e2e:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108e34:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108e3a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108e41:	8b 52 08             	mov    0x8(%edx),%edx
80108e44:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108e4a:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108e4d:	83 ec 0c             	sub    $0xc,%esp
80108e50:	6a 30                	push   $0x30
80108e52:	e8 f3 f7 ff ff       	call   8010864a <ltr>
80108e57:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108e5a:	8b 45 08             	mov    0x8(%ebp),%eax
80108e5d:	8b 40 04             	mov    0x4(%eax),%eax
80108e60:	85 c0                	test   %eax,%eax
80108e62:	75 0d                	jne    80108e71 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80108e64:	83 ec 0c             	sub    $0xc,%esp
80108e67:	68 7b 9b 10 80       	push   $0x80109b7b
80108e6c:	e8 f5 76 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108e71:	8b 45 08             	mov    0x8(%ebp),%eax
80108e74:	8b 40 04             	mov    0x4(%eax),%eax
80108e77:	83 ec 0c             	sub    $0xc,%esp
80108e7a:	50                   	push   %eax
80108e7b:	e8 03 f8 ff ff       	call   80108683 <v2p>
80108e80:	83 c4 10             	add    $0x10,%esp
80108e83:	83 ec 0c             	sub    $0xc,%esp
80108e86:	50                   	push   %eax
80108e87:	e8 eb f7 ff ff       	call   80108677 <lcr3>
80108e8c:	83 c4 10             	add    $0x10,%esp
  popcli();
80108e8f:	e8 47 ce ff ff       	call   80105cdb <popcli>
}
80108e94:	90                   	nop
80108e95:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108e98:	5b                   	pop    %ebx
80108e99:	5e                   	pop    %esi
80108e9a:	5d                   	pop    %ebp
80108e9b:	c3                   	ret    

80108e9c <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108e9c:	55                   	push   %ebp
80108e9d:	89 e5                	mov    %esp,%ebp
80108e9f:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108ea2:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108ea9:	76 0d                	jbe    80108eb8 <inituvm+0x1c>
    panic("inituvm: more than a page");
80108eab:	83 ec 0c             	sub    $0xc,%esp
80108eae:	68 8f 9b 10 80       	push   $0x80109b8f
80108eb3:	e8 ae 76 ff ff       	call   80100566 <panic>
  mem = kalloc();
80108eb8:	e8 b8 9e ff ff       	call   80102d75 <kalloc>
80108ebd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108ec0:	83 ec 04             	sub    $0x4,%esp
80108ec3:	68 00 10 00 00       	push   $0x1000
80108ec8:	6a 00                	push   $0x0
80108eca:	ff 75 f4             	pushl  -0xc(%ebp)
80108ecd:	e8 ca ce ff ff       	call   80105d9c <memset>
80108ed2:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108ed5:	83 ec 0c             	sub    $0xc,%esp
80108ed8:	ff 75 f4             	pushl  -0xc(%ebp)
80108edb:	e8 a3 f7 ff ff       	call   80108683 <v2p>
80108ee0:	83 c4 10             	add    $0x10,%esp
80108ee3:	83 ec 0c             	sub    $0xc,%esp
80108ee6:	6a 06                	push   $0x6
80108ee8:	50                   	push   %eax
80108ee9:	68 00 10 00 00       	push   $0x1000
80108eee:	6a 00                	push   $0x0
80108ef0:	ff 75 08             	pushl  0x8(%ebp)
80108ef3:	e8 ba fc ff ff       	call   80108bb2 <mappages>
80108ef8:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108efb:	83 ec 04             	sub    $0x4,%esp
80108efe:	ff 75 10             	pushl  0x10(%ebp)
80108f01:	ff 75 0c             	pushl  0xc(%ebp)
80108f04:	ff 75 f4             	pushl  -0xc(%ebp)
80108f07:	e8 4f cf ff ff       	call   80105e5b <memmove>
80108f0c:	83 c4 10             	add    $0x10,%esp
}
80108f0f:	90                   	nop
80108f10:	c9                   	leave  
80108f11:	c3                   	ret    

80108f12 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108f12:	55                   	push   %ebp
80108f13:	89 e5                	mov    %esp,%ebp
80108f15:	53                   	push   %ebx
80108f16:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108f19:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f1c:	25 ff 0f 00 00       	and    $0xfff,%eax
80108f21:	85 c0                	test   %eax,%eax
80108f23:	74 0d                	je     80108f32 <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80108f25:	83 ec 0c             	sub    $0xc,%esp
80108f28:	68 ac 9b 10 80       	push   $0x80109bac
80108f2d:	e8 34 76 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108f32:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108f39:	e9 95 00 00 00       	jmp    80108fd3 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108f3e:	8b 55 0c             	mov    0xc(%ebp),%edx
80108f41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f44:	01 d0                	add    %edx,%eax
80108f46:	83 ec 04             	sub    $0x4,%esp
80108f49:	6a 00                	push   $0x0
80108f4b:	50                   	push   %eax
80108f4c:	ff 75 08             	pushl  0x8(%ebp)
80108f4f:	e8 be fb ff ff       	call   80108b12 <walkpgdir>
80108f54:	83 c4 10             	add    $0x10,%esp
80108f57:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108f5a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108f5e:	75 0d                	jne    80108f6d <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80108f60:	83 ec 0c             	sub    $0xc,%esp
80108f63:	68 cf 9b 10 80       	push   $0x80109bcf
80108f68:	e8 f9 75 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108f6d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f70:	8b 00                	mov    (%eax),%eax
80108f72:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f77:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108f7a:	8b 45 18             	mov    0x18(%ebp),%eax
80108f7d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108f80:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108f85:	77 0b                	ja     80108f92 <loaduvm+0x80>
      n = sz - i;
80108f87:	8b 45 18             	mov    0x18(%ebp),%eax
80108f8a:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108f8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108f90:	eb 07                	jmp    80108f99 <loaduvm+0x87>
    else
      n = PGSIZE;
80108f92:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108f99:	8b 55 14             	mov    0x14(%ebp),%edx
80108f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f9f:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108fa2:	83 ec 0c             	sub    $0xc,%esp
80108fa5:	ff 75 e8             	pushl  -0x18(%ebp)
80108fa8:	e8 e3 f6 ff ff       	call   80108690 <p2v>
80108fad:	83 c4 10             	add    $0x10,%esp
80108fb0:	ff 75 f0             	pushl  -0x10(%ebp)
80108fb3:	53                   	push   %ebx
80108fb4:	50                   	push   %eax
80108fb5:	ff 75 10             	pushl  0x10(%ebp)
80108fb8:	e8 2a 90 ff ff       	call   80101fe7 <readi>
80108fbd:	83 c4 10             	add    $0x10,%esp
80108fc0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108fc3:	74 07                	je     80108fcc <loaduvm+0xba>
      return -1;
80108fc5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108fca:	eb 18                	jmp    80108fe4 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108fcc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fd6:	3b 45 18             	cmp    0x18(%ebp),%eax
80108fd9:	0f 82 5f ff ff ff    	jb     80108f3e <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108fdf:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108fe4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108fe7:	c9                   	leave  
80108fe8:	c3                   	ret    

80108fe9 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108fe9:	55                   	push   %ebp
80108fea:	89 e5                	mov    %esp,%ebp
80108fec:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108fef:	8b 45 10             	mov    0x10(%ebp),%eax
80108ff2:	85 c0                	test   %eax,%eax
80108ff4:	79 0a                	jns    80109000 <allocuvm+0x17>
    return 0;
80108ff6:	b8 00 00 00 00       	mov    $0x0,%eax
80108ffb:	e9 b0 00 00 00       	jmp    801090b0 <allocuvm+0xc7>
  if(newsz < oldsz)
80109000:	8b 45 10             	mov    0x10(%ebp),%eax
80109003:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109006:	73 08                	jae    80109010 <allocuvm+0x27>
    return oldsz;
80109008:	8b 45 0c             	mov    0xc(%ebp),%eax
8010900b:	e9 a0 00 00 00       	jmp    801090b0 <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80109010:	8b 45 0c             	mov    0xc(%ebp),%eax
80109013:	05 ff 0f 00 00       	add    $0xfff,%eax
80109018:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010901d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80109020:	eb 7f                	jmp    801090a1 <allocuvm+0xb8>
    mem = kalloc();
80109022:	e8 4e 9d ff ff       	call   80102d75 <kalloc>
80109027:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010902a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010902e:	75 2b                	jne    8010905b <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80109030:	83 ec 0c             	sub    $0xc,%esp
80109033:	68 ed 9b 10 80       	push   $0x80109bed
80109038:	e8 89 73 ff ff       	call   801003c6 <cprintf>
8010903d:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80109040:	83 ec 04             	sub    $0x4,%esp
80109043:	ff 75 0c             	pushl  0xc(%ebp)
80109046:	ff 75 10             	pushl  0x10(%ebp)
80109049:	ff 75 08             	pushl  0x8(%ebp)
8010904c:	e8 61 00 00 00       	call   801090b2 <deallocuvm>
80109051:	83 c4 10             	add    $0x10,%esp
      return 0;
80109054:	b8 00 00 00 00       	mov    $0x0,%eax
80109059:	eb 55                	jmp    801090b0 <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
8010905b:	83 ec 04             	sub    $0x4,%esp
8010905e:	68 00 10 00 00       	push   $0x1000
80109063:	6a 00                	push   $0x0
80109065:	ff 75 f0             	pushl  -0x10(%ebp)
80109068:	e8 2f cd ff ff       	call   80105d9c <memset>
8010906d:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80109070:	83 ec 0c             	sub    $0xc,%esp
80109073:	ff 75 f0             	pushl  -0x10(%ebp)
80109076:	e8 08 f6 ff ff       	call   80108683 <v2p>
8010907b:	83 c4 10             	add    $0x10,%esp
8010907e:	89 c2                	mov    %eax,%edx
80109080:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109083:	83 ec 0c             	sub    $0xc,%esp
80109086:	6a 06                	push   $0x6
80109088:	52                   	push   %edx
80109089:	68 00 10 00 00       	push   $0x1000
8010908e:	50                   	push   %eax
8010908f:	ff 75 08             	pushl  0x8(%ebp)
80109092:	e8 1b fb ff ff       	call   80108bb2 <mappages>
80109097:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
8010909a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801090a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090a4:	3b 45 10             	cmp    0x10(%ebp),%eax
801090a7:	0f 82 75 ff ff ff    	jb     80109022 <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
801090ad:	8b 45 10             	mov    0x10(%ebp),%eax
}
801090b0:	c9                   	leave  
801090b1:	c3                   	ret    

801090b2 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801090b2:	55                   	push   %ebp
801090b3:	89 e5                	mov    %esp,%ebp
801090b5:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801090b8:	8b 45 10             	mov    0x10(%ebp),%eax
801090bb:	3b 45 0c             	cmp    0xc(%ebp),%eax
801090be:	72 08                	jb     801090c8 <deallocuvm+0x16>
    return oldsz;
801090c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801090c3:	e9 a5 00 00 00       	jmp    8010916d <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
801090c8:	8b 45 10             	mov    0x10(%ebp),%eax
801090cb:	05 ff 0f 00 00       	add    $0xfff,%eax
801090d0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801090d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801090d8:	e9 81 00 00 00       	jmp    8010915e <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
801090dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090e0:	83 ec 04             	sub    $0x4,%esp
801090e3:	6a 00                	push   $0x0
801090e5:	50                   	push   %eax
801090e6:	ff 75 08             	pushl  0x8(%ebp)
801090e9:	e8 24 fa ff ff       	call   80108b12 <walkpgdir>
801090ee:	83 c4 10             	add    $0x10,%esp
801090f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801090f4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801090f8:	75 09                	jne    80109103 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
801090fa:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80109101:	eb 54                	jmp    80109157 <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
80109103:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109106:	8b 00                	mov    (%eax),%eax
80109108:	83 e0 01             	and    $0x1,%eax
8010910b:	85 c0                	test   %eax,%eax
8010910d:	74 48                	je     80109157 <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
8010910f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109112:	8b 00                	mov    (%eax),%eax
80109114:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109119:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
8010911c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109120:	75 0d                	jne    8010912f <deallocuvm+0x7d>
        panic("kfree");
80109122:	83 ec 0c             	sub    $0xc,%esp
80109125:	68 05 9c 10 80       	push   $0x80109c05
8010912a:	e8 37 74 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
8010912f:	83 ec 0c             	sub    $0xc,%esp
80109132:	ff 75 ec             	pushl  -0x14(%ebp)
80109135:	e8 56 f5 ff ff       	call   80108690 <p2v>
8010913a:	83 c4 10             	add    $0x10,%esp
8010913d:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80109140:	83 ec 0c             	sub    $0xc,%esp
80109143:	ff 75 e8             	pushl  -0x18(%ebp)
80109146:	e8 8d 9b ff ff       	call   80102cd8 <kfree>
8010914b:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
8010914e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109151:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80109157:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010915e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109161:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109164:	0f 82 73 ff ff ff    	jb     801090dd <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
8010916a:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010916d:	c9                   	leave  
8010916e:	c3                   	ret    

8010916f <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010916f:	55                   	push   %ebp
80109170:	89 e5                	mov    %esp,%ebp
80109172:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80109175:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80109179:	75 0d                	jne    80109188 <freevm+0x19>
    panic("freevm: no pgdir");
8010917b:	83 ec 0c             	sub    $0xc,%esp
8010917e:	68 0b 9c 10 80       	push   $0x80109c0b
80109183:	e8 de 73 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80109188:	83 ec 04             	sub    $0x4,%esp
8010918b:	6a 00                	push   $0x0
8010918d:	68 00 00 00 80       	push   $0x80000000
80109192:	ff 75 08             	pushl  0x8(%ebp)
80109195:	e8 18 ff ff ff       	call   801090b2 <deallocuvm>
8010919a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010919d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801091a4:	eb 4f                	jmp    801091f5 <freevm+0x86>
    if(pgdir[i] & PTE_P){
801091a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091a9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801091b0:	8b 45 08             	mov    0x8(%ebp),%eax
801091b3:	01 d0                	add    %edx,%eax
801091b5:	8b 00                	mov    (%eax),%eax
801091b7:	83 e0 01             	and    $0x1,%eax
801091ba:	85 c0                	test   %eax,%eax
801091bc:	74 33                	je     801091f1 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
801091be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091c1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801091c8:	8b 45 08             	mov    0x8(%ebp),%eax
801091cb:	01 d0                	add    %edx,%eax
801091cd:	8b 00                	mov    (%eax),%eax
801091cf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801091d4:	83 ec 0c             	sub    $0xc,%esp
801091d7:	50                   	push   %eax
801091d8:	e8 b3 f4 ff ff       	call   80108690 <p2v>
801091dd:	83 c4 10             	add    $0x10,%esp
801091e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801091e3:	83 ec 0c             	sub    $0xc,%esp
801091e6:	ff 75 f0             	pushl  -0x10(%ebp)
801091e9:	e8 ea 9a ff ff       	call   80102cd8 <kfree>
801091ee:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801091f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801091f5:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801091fc:	76 a8                	jbe    801091a6 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801091fe:	83 ec 0c             	sub    $0xc,%esp
80109201:	ff 75 08             	pushl  0x8(%ebp)
80109204:	e8 cf 9a ff ff       	call   80102cd8 <kfree>
80109209:	83 c4 10             	add    $0x10,%esp
}
8010920c:	90                   	nop
8010920d:	c9                   	leave  
8010920e:	c3                   	ret    

8010920f <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010920f:	55                   	push   %ebp
80109210:	89 e5                	mov    %esp,%ebp
80109212:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109215:	83 ec 04             	sub    $0x4,%esp
80109218:	6a 00                	push   $0x0
8010921a:	ff 75 0c             	pushl  0xc(%ebp)
8010921d:	ff 75 08             	pushl  0x8(%ebp)
80109220:	e8 ed f8 ff ff       	call   80108b12 <walkpgdir>
80109225:	83 c4 10             	add    $0x10,%esp
80109228:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010922b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010922f:	75 0d                	jne    8010923e <clearpteu+0x2f>
    panic("clearpteu");
80109231:	83 ec 0c             	sub    $0xc,%esp
80109234:	68 1c 9c 10 80       	push   $0x80109c1c
80109239:	e8 28 73 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
8010923e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109241:	8b 00                	mov    (%eax),%eax
80109243:	83 e0 fb             	and    $0xfffffffb,%eax
80109246:	89 c2                	mov    %eax,%edx
80109248:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010924b:	89 10                	mov    %edx,(%eax)
}
8010924d:	90                   	nop
8010924e:	c9                   	leave  
8010924f:	c3                   	ret    

80109250 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80109250:	55                   	push   %ebp
80109251:	89 e5                	mov    %esp,%ebp
80109253:	53                   	push   %ebx
80109254:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80109257:	e8 e6 f9 ff ff       	call   80108c42 <setupkvm>
8010925c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010925f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109263:	75 0a                	jne    8010926f <copyuvm+0x1f>
    return 0;
80109265:	b8 00 00 00 00       	mov    $0x0,%eax
8010926a:	e9 f8 00 00 00       	jmp    80109367 <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
8010926f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109276:	e9 c4 00 00 00       	jmp    8010933f <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010927b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010927e:	83 ec 04             	sub    $0x4,%esp
80109281:	6a 00                	push   $0x0
80109283:	50                   	push   %eax
80109284:	ff 75 08             	pushl  0x8(%ebp)
80109287:	e8 86 f8 ff ff       	call   80108b12 <walkpgdir>
8010928c:	83 c4 10             	add    $0x10,%esp
8010928f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109292:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109296:	75 0d                	jne    801092a5 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
80109298:	83 ec 0c             	sub    $0xc,%esp
8010929b:	68 26 9c 10 80       	push   $0x80109c26
801092a0:	e8 c1 72 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
801092a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801092a8:	8b 00                	mov    (%eax),%eax
801092aa:	83 e0 01             	and    $0x1,%eax
801092ad:	85 c0                	test   %eax,%eax
801092af:	75 0d                	jne    801092be <copyuvm+0x6e>
      panic("copyuvm: page not present");
801092b1:	83 ec 0c             	sub    $0xc,%esp
801092b4:	68 40 9c 10 80       	push   $0x80109c40
801092b9:	e8 a8 72 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
801092be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801092c1:	8b 00                	mov    (%eax),%eax
801092c3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801092c8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801092cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801092ce:	8b 00                	mov    (%eax),%eax
801092d0:	25 ff 0f 00 00       	and    $0xfff,%eax
801092d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801092d8:	e8 98 9a ff ff       	call   80102d75 <kalloc>
801092dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
801092e0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801092e4:	74 6a                	je     80109350 <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
801092e6:	83 ec 0c             	sub    $0xc,%esp
801092e9:	ff 75 e8             	pushl  -0x18(%ebp)
801092ec:	e8 9f f3 ff ff       	call   80108690 <p2v>
801092f1:	83 c4 10             	add    $0x10,%esp
801092f4:	83 ec 04             	sub    $0x4,%esp
801092f7:	68 00 10 00 00       	push   $0x1000
801092fc:	50                   	push   %eax
801092fd:	ff 75 e0             	pushl  -0x20(%ebp)
80109300:	e8 56 cb ff ff       	call   80105e5b <memmove>
80109305:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80109308:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010930b:	83 ec 0c             	sub    $0xc,%esp
8010930e:	ff 75 e0             	pushl  -0x20(%ebp)
80109311:	e8 6d f3 ff ff       	call   80108683 <v2p>
80109316:	83 c4 10             	add    $0x10,%esp
80109319:	89 c2                	mov    %eax,%edx
8010931b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010931e:	83 ec 0c             	sub    $0xc,%esp
80109321:	53                   	push   %ebx
80109322:	52                   	push   %edx
80109323:	68 00 10 00 00       	push   $0x1000
80109328:	50                   	push   %eax
80109329:	ff 75 f0             	pushl  -0x10(%ebp)
8010932c:	e8 81 f8 ff ff       	call   80108bb2 <mappages>
80109331:	83 c4 20             	add    $0x20,%esp
80109334:	85 c0                	test   %eax,%eax
80109336:	78 1b                	js     80109353 <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80109338:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010933f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109342:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109345:	0f 82 30 ff ff ff    	jb     8010927b <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
8010934b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010934e:	eb 17                	jmp    80109367 <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80109350:	90                   	nop
80109351:	eb 01                	jmp    80109354 <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
80109353:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80109354:	83 ec 0c             	sub    $0xc,%esp
80109357:	ff 75 f0             	pushl  -0x10(%ebp)
8010935a:	e8 10 fe ff ff       	call   8010916f <freevm>
8010935f:	83 c4 10             	add    $0x10,%esp
  return 0;
80109362:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109367:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010936a:	c9                   	leave  
8010936b:	c3                   	ret    

8010936c <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010936c:	55                   	push   %ebp
8010936d:	89 e5                	mov    %esp,%ebp
8010936f:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109372:	83 ec 04             	sub    $0x4,%esp
80109375:	6a 00                	push   $0x0
80109377:	ff 75 0c             	pushl  0xc(%ebp)
8010937a:	ff 75 08             	pushl  0x8(%ebp)
8010937d:	e8 90 f7 ff ff       	call   80108b12 <walkpgdir>
80109382:	83 c4 10             	add    $0x10,%esp
80109385:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80109388:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010938b:	8b 00                	mov    (%eax),%eax
8010938d:	83 e0 01             	and    $0x1,%eax
80109390:	85 c0                	test   %eax,%eax
80109392:	75 07                	jne    8010939b <uva2ka+0x2f>
    return 0;
80109394:	b8 00 00 00 00       	mov    $0x0,%eax
80109399:	eb 29                	jmp    801093c4 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
8010939b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010939e:	8b 00                	mov    (%eax),%eax
801093a0:	83 e0 04             	and    $0x4,%eax
801093a3:	85 c0                	test   %eax,%eax
801093a5:	75 07                	jne    801093ae <uva2ka+0x42>
    return 0;
801093a7:	b8 00 00 00 00       	mov    $0x0,%eax
801093ac:	eb 16                	jmp    801093c4 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
801093ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093b1:	8b 00                	mov    (%eax),%eax
801093b3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801093b8:	83 ec 0c             	sub    $0xc,%esp
801093bb:	50                   	push   %eax
801093bc:	e8 cf f2 ff ff       	call   80108690 <p2v>
801093c1:	83 c4 10             	add    $0x10,%esp
}
801093c4:	c9                   	leave  
801093c5:	c3                   	ret    

801093c6 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801093c6:	55                   	push   %ebp
801093c7:	89 e5                	mov    %esp,%ebp
801093c9:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801093cc:	8b 45 10             	mov    0x10(%ebp),%eax
801093cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801093d2:	eb 7f                	jmp    80109453 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
801093d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801093d7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801093dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801093df:	8b 45 ec             	mov    -0x14(%ebp),%eax
801093e2:	83 ec 08             	sub    $0x8,%esp
801093e5:	50                   	push   %eax
801093e6:	ff 75 08             	pushl  0x8(%ebp)
801093e9:	e8 7e ff ff ff       	call   8010936c <uva2ka>
801093ee:	83 c4 10             	add    $0x10,%esp
801093f1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801093f4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801093f8:	75 07                	jne    80109401 <copyout+0x3b>
      return -1;
801093fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801093ff:	eb 61                	jmp    80109462 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80109401:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109404:	2b 45 0c             	sub    0xc(%ebp),%eax
80109407:	05 00 10 00 00       	add    $0x1000,%eax
8010940c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010940f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109412:	3b 45 14             	cmp    0x14(%ebp),%eax
80109415:	76 06                	jbe    8010941d <copyout+0x57>
      n = len;
80109417:	8b 45 14             	mov    0x14(%ebp),%eax
8010941a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010941d:	8b 45 0c             	mov    0xc(%ebp),%eax
80109420:	2b 45 ec             	sub    -0x14(%ebp),%eax
80109423:	89 c2                	mov    %eax,%edx
80109425:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109428:	01 d0                	add    %edx,%eax
8010942a:	83 ec 04             	sub    $0x4,%esp
8010942d:	ff 75 f0             	pushl  -0x10(%ebp)
80109430:	ff 75 f4             	pushl  -0xc(%ebp)
80109433:	50                   	push   %eax
80109434:	e8 22 ca ff ff       	call   80105e5b <memmove>
80109439:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010943c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010943f:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80109442:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109445:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80109448:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010944b:	05 00 10 00 00       	add    $0x1000,%eax
80109450:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80109453:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80109457:	0f 85 77 ff ff ff    	jne    801093d4 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010945d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109462:	c9                   	leave  
80109463:	c3                   	ret    

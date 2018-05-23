// On-disk file system format.
// Both the kernel and user programs use this header file.


#define ROOTINO 1  // root i-number
#define BSIZE 512  // block size

// Disk layout:
// [ boot block | super block | log | inode blocks | free bit map | data blocks ]
//
// mkfs computes the super block and builds an initial file system. The super describes
// the disk layout:
struct superblock {
  uint size;         // Size of file system image (blocks)
  uint nblocks;      // Number of data blocks
  uint ninodes;      // Number of inodes.
  uint nlog;         // Number of log blocks
  uint logstart;     // Block number of first log block
  uint inodestart;   // Block number of first inode block
  uint bmapstart;    // Block number of first free map block
};

#ifdef CS333_P5
#define NDIRECT 10
#else
#define NDIRECT 12
#endif
#define NINDIRECT (BSIZE / sizeof(uint))
#define MAXFILE (NDIRECT + NINDIRECT)

#ifdef CS333_P5
union mode_t {
  struct {
    uint ox : 1;
    uint ow : 1;
    uint or : 1;     //other
    uint gx : 1;
    uint gw : 1;
    uint gr : 1;     //group
    uint ux : 1;
    uint uw : 1;
    uint ur : 1;     //user
    uint setuid : 1;
    uint : 22;       // pad
  } flags;
  uint asInt;
};
#endif

// On-disk inode structure
struct dinode {
  short type;           // File type
  short major;          // Major device number (T_DEV only)
  short minor;          // Minor device number (T_DEV only)
  short nlink;          // Number of links to inode in file system
#ifdef CS333_P5
  ushort uid;           // owner ID
  ushort gid;           // group ID
  union mode_t mode;    // protection/mode bits
#endif
  uint size;            // Size of file (bytes)
  uint addrs[NDIRECT+1];   // Data block addresses
};

// Inodes per block.
#define IPB           (BSIZE / sizeof(struct dinode))

// Block containing inode i
#define IBLOCK(i, sb)     ((i) / IPB + sb.inodestart)

// Bitmap bits per block
#define BPB           (BSIZE*8)

// Block of free map containing bit for block b
#define BBLOCK(b, sb) (b/BPB + sb.bmapstart)

// Directory is a file containing a sequence of dirent structures.
#define DIRSIZ 14

struct dirent {
  ushort inum;
  char name[DIRSIZ];
};


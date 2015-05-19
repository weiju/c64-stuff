#!/usr/bin/env python3

import argparse

BLOCK_SIZE = 256
FILETYPES = ['DEL', 'SEQ', 'PRG', 'USR', 'REL']

def num_sectors(track):
    """For a 40 track disk, return the number of sectors in the specified track"""
    if track > 0 and track <= 17:
        return 21
    elif track >= 18 and track <= 24:
        return 19
    elif track >= 25 and track <= 30:
        return 18
    elif track >= 31 and track <= 40:
        return 17
    else:
        raise Exception("invalid track number '%d'" % track)



def track_offset(track):
    cumsum_sectors = sum([num_sectors(i) for i in range(1, track)])
    return cumsum_sectors * BLOCK_SIZE
    

def read_block(data, track, sector):
    offset = track_offset(track) + sector * BLOCK_SIZE
    return data[offset:offset + BLOCK_SIZE]

def rem_pad_bytes(petscii_string):
    """shorten the name to exclude the pad characters"""
    padded_idx = -1
    for i in range(len(petscii_string)):
        if petscii_string[i] == 0xa0:
            padded_idx = i
            return petscii_string[:padded_idx]
    return petscii_string

def read_dir_block(block):
    offset = 0
    for i in range(8):
        filetype = block[offset + 2]
        actual_filetype = filetype & 7
        if (actual_filetype) != 0:
            fname = block[offset + 5: offset + 0x15]
            fname = rem_pad_bytes(fname)
            fname = fname.decode('utf-8')
            
            file_track, file_sector = block[offset + 3], block[offset + 4]
            size_hi, size_lo = block[offset + 0x1f], block[offset + 0x1e]
            num_sectors = size_hi * 256 + size_lo
            typename = FILETYPES[actual_filetype]
            print("%s[%02x]\t'%s'\t\t# sectors: %d\t-> (%d, %d)" % (typename, filetype,
                                                               fname,
                                                               num_sectors,
                                                               file_track, file_sector))
        offset += 0x20
    
def read_directory(data):
    """
    for i in range(0, 19):
    dir_block = read_block(data, 18, i)
    print("\n\nDIR BLOCK %d" % i)
    print(dir_block)
    """
    next_track = 18
    next_sector = 1
    while next_track != 0:
        print("reading track = %d sector = %d" % (next_track, next_sector))
        dir_block = read_block(data, next_track, next_sector)
        next_track, next_sector = dir_block[0], dir_block[1]
        read_dir_block(dir_block)


def read_bam(data):
    bam_block = read_block(data, 18, 0)
    disk_name = rem_pad_bytes(bam_block[0x90:0xa0]).decode('utf-8')
    print("DISK NAME '%s'" % disk_name)


def parse_d64_file(path):
    with open(path, 'rb') as infile:
        data = infile.read()
        print("# read: ", len(data))
        read_bam(data)
        read_directory(data)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='d64.py - disk image parser')
    parser.add_argument('d64file', help='d64 format file')
    args = parser.parse_args()
    parse_d64_file(args.d64file)


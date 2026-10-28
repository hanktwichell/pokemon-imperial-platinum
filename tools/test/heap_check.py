#!/usr/bin/env python3
"""Check the game's heaps in a running test build: each heap's lists of used and free blocks (NitroSystem's expanded
heap, src/heap.c's sHeapInfo) must hold only blocks inside the heap, with the right signature and back links.

A block freed twice, or a pointer that was never allocated (Heap_Free(NULL) on a failed file load), breaks these
lists, and the game crashes or writes over memory later, often far from the cause. Harnesses call heap_problems()
after a step to catch the break where it happened.
"""
import os
import re
import struct

DECOMP = 'decomp'
EXP_HEAP = 0x45585048  # 'EXPH'
FREE_BLOCK, USED_BLOCK = 0x4652, 0x5544  # 'FR', 'UD'
# struct HeapInfo (src/heap.c): heapHandles, ..., heapIdxs at 16, totalNumHeaps at 20, maxHeaps at 24.
HANDLES, HEAP_IDXS, TOTAL_HEAPS, MAX_HEAPS = 0, 16, 20, 24
# NNSiFndHeapHead then NNSiFndExpHeapHead: heapStart at 24, heapEnd at 28, the free list at 36, the used list at 44.
HEAP_START, HEAP_END, FREE_LIST, USED_LIST = 24, 28, 36, 44
# NNSiFndExpHeapMBlockHead: signature, attribute, blockSize at 4, prev at 8, next at 12.
BLOCK_SIZE, PREV, NEXT = 4, 8, 12


def heap_info_address():
    """The address of sHeapInfo, from the test build's map."""
    xmap = open(os.path.join(DECOMP, 'build_test', 'main.nef.xMAP'), encoding='utf-8', errors='replace').read()
    return int(re.search(r'^\s*([0-9A-F]{8}) [0-9A-F]{8} \.bss\s+sHeapInfo\b', xmap, re.M).group(1), 16)


def heap_problems(mem, heap_info):
    """[(heap ID, what is wrong)] for each heap whose block lists are broken."""
    def u16(addr):
        return struct.unpack('<H', bytes(mem.unsigned[addr:addr + 2]))[0]

    def u32(addr):
        return struct.unpack('<I', bytes(mem.unsigned[addr:addr + 4]))[0]

    handles, idxs = u32(heap_info + HANDLES), u32(heap_info + HEAP_IDXS)
    total, max_heaps = u16(heap_info + TOTAL_HEAPS), u16(heap_info + MAX_HEAPS)
    heap_ids = {mem.unsigned[idxs + heap_id]: heap_id for heap_id in range(total)
                if mem.unsigned[idxs + heap_id] != max_heaps}
    out = []
    for index in range(max_heaps):
        heap = u32(handles + 4 * index)
        if heap == 0:
            continue
        heap_id = heap_ids.get(index, f'index {index}')
        if u32(heap) != EXP_HEAP:
            out.append((heap_id, f'heap head {heap:08x} has signature {u32(heap):08x}'))
            continue
        start, end = u32(heap + HEAP_START), u32(heap + HEAP_END)
        for offset, signature, kind in ((FREE_LIST, FREE_BLOCK, 'free'), (USED_LIST, USED_BLOCK, 'used')):
            block, prev, count = u32(heap + offset), 0, 0
            while block and count < 10000:
                if not start <= block < end:
                    out.append((heap_id, f'{kind} block {block:08x} (after {prev:08x}) is outside the heap'))
                    break
                if u16(block) != signature or u32(block + PREV) != prev:
                    out.append((heap_id, f'{kind} block {block:08x} (after {prev:08x}) is broken'))
                    break
                prev, block, count = block, u32(block + NEXT), count + 1
    return out


def heap_free(mem, heap_info):
    """{heap ID: the bytes free in it (its free blocks' sizes)} for each heap."""
    def u16(addr):
        return struct.unpack('<H', bytes(mem.unsigned[addr:addr + 2]))[0]

    def u32(addr):
        return struct.unpack('<I', bytes(mem.unsigned[addr:addr + 4]))[0]

    handles, idxs = u32(heap_info + HANDLES), u32(heap_info + HEAP_IDXS)
    total, max_heaps = u16(heap_info + TOTAL_HEAPS), u16(heap_info + MAX_HEAPS)
    heap_ids = {mem.unsigned[idxs + heap_id]: heap_id for heap_id in range(total)
                if mem.unsigned[idxs + heap_id] != max_heaps}
    out = {}
    for index in range(max_heaps):
        heap = u32(handles + 4 * index)
        if heap == 0 or u32(heap) != EXP_HEAP:
            continue
        block, free, count = u32(heap + FREE_LIST), 0, 0
        while block and count < 10000:
            free += u32(block + BLOCK_SIZE)
            block, count = u32(block + NEXT), count + 1
        out[heap_ids.get(index, f'index {index}')] = free
    return out

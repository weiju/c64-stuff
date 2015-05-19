#!/usr/bin/env python3

import unittest
import d64

SECTORS = [21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
           19, 19, 19, 19, 19, 19, 19, 18, 18, 18, 18, 18, 18,
           17, 17, 17, 17, 17, 17, 17, 17, 17, 17]

OFFSETS = [0x00000, 0x01500, 0x02A00, 0x03F00, 0x05400, 0x06900, 0x07E00,
           0x09300, 0x0A800, 0x0BD00, 0x0D200, 0x0E700, 0x0FC00, 0x11100,
           0x12600, 0x13B00, 0x15000, 0x16500, 0x17800, 0x18B00, 0x19E00,
           0x1B100, 0x1C400, 0x1D700, 0x1EA00, 0x1FC00, 0x20E00, 0x22000,
           0x23200, 0x24400, 0x25600, 0x26700, 0x27800, 0x28900, 0x29A00,
           0x2AB00, 0x2BC00, 0x2CD00, 0x2DE00, 0x2EF00]


class D64Test(unittest.TestCase):

    def test_track_sectors(self):
        for track in range(1, 41):
            self.assertEquals(SECTORS[track - 1], d64.num_sectors(track))

    def test_track_offsets(self):
        for track in range(1, 41):
            self.assertEquals(OFFSETS[track - 1], d64.track_offset(track))


if __name__ == '__main__':
    SUITE = [unittest.TestLoader().loadTestsFromTestCase(D64Test)]
    unittest.TextTestRunner(verbosity=2).run(unittest.TestSuite(SUITE))

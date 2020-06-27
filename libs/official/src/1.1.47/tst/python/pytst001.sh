#!/bin/python

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

import sys

print('This file has .sh extension in order to pass shlibs tests \
for official libs. Otherwise this is just a standard python file \
used to test shlibs-python interaction.\n')

print('Arguments: ')
for argv in sys.argv : print(argv)

#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com


SHLIBS_HELP="SHLIBS Help
   shlibs is a CLI assistant and script manager for POSIX compliant systems.
   shlibs processed scripts run on any POSIX compliant system
including Linux, BSDs, MacOS, and Solaris.
   shlibs can handle shell script and other types of scripts 
(if an interpreter is available i.e. php, perl, python etc).

   Basic usage:
> shlibs   [ query shlibs for the code of a library/utility ]
> shlibs libcode   [ source libcode utility and call default function ]
> shlibs -p libcode   [ get libcode utility path; used for sourcing utility ]
> shlibs -s /path/to/script   [ interactive processing of scripts ]
> shlibs -y -s /path/to/script
      [ process script and run a realistic test ]
> shlibs -s /path/to/script -d /destination/folder
      [ process script and output to destination folder ]
      
Visit https://shlibs.org, https://shlibs.net for more instructions.\n\n"
export SHLIBS_HELP

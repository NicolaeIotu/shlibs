# Contributing

shlibs was designed to be simple and will try to maintain it's simplicity 
along the way. Please keep that in mind when contributing.

shlibs uses it's own libraries for tests and self-tests.
* use 'shlibs tst001' for testing all the official libraries
* use 'shlibs tst001 libcode(s)' (i.e. 'shlibs tst001 str005') to test 
libraries (not necessarily official libraries).

shlibs aims to be compatible and cover the biggest number of systems and apps. 
Target standard is POSIX&reg; IEEE&reg; Std 1003.1-2017, but can take 
on Bourne Shell only systems if some decent capabilities and POSIX tools available.
That being said, your contributions must pass the tests at least on the following OSes:
* Fedora
* Debian
* MacOS
* BSD family (FreeBSD, NetBSD, DragonFlyBSD)
* Solaris!
* Minix

shlibs structure can be decomposed in two main parts:
* shlibs _core_ ('shlibs' file and 'var' folder and its content)
* shlibs _libraries_ ('libs' folder and its content)

The 'official' libraries will only contain true shell scripts, while 'dev' and 
'community' libraries can contain other types of interpretable scripts. 
For example someone can initiate and be in charge of 'community/php' section.

More instructions to follow.

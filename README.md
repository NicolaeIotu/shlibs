# shlibs

_Author_: IOTU NICOLAE<br>
_Email_: nicolae.g.iotu@gmail.com<br>
_License_: Apache-2.0 modified with the Convergence Terms


** Description: ** 
shlibs targets command line ops, shell scripts and interpretable types of 
scripts on systems, sub-systems and apps complying with The Open Group® 
POSIX® IEEE® Std 1003.1-2017 specifications. shlibs is designed to be 
extremely easy to use, efficient and guaranteed to run on any compliant 
system (and highly probable to run on systems not fully compliant). 

The first release of **shlibs** comes packed with sufficient libraries 
to match the most common libraries of the popular interpreted programming 
languages including php, python and perl, while adding **shell scripts** 
style advantages: 
* guaranteed to run on the widest range of systems and apps
* superior speed
* use files and/or strings
* parameters with shifting position
* no installations (just copy 'shlibs' folder)
* full pipe integration
* a.m.m.o.

More instructions to follow.


## Quick Run
( elevate privileges if required )
* **cd** /shlibs/folder
* ./shlibs 


## Basic Usage
1. Define **SHLIBS_HOME** variable<br>
	i.e. **SHLIBS_HOME=/location/of/shlibs/folder**

2. Add shlibs location to PATH variable<br>
	i.e. **PATH=$SHLIBS_HOME:$PATH ; export PATH**

3. To query shlibs for the code of a library:<br>
	**shlibs**

4. Use '**shlibs libcode**' in your CLI or script<br>
	(see [https://shlibs.net](https://shlibs.net), 
	[https://shlibs.org](https://shlibs.org) for details), or

5. Include plain '**shlibs**' in your script and run setup:<br>
	**shlibs -s path/to/script**


&copy; 2020 IOTU NICOLAE, nicolae.g.iotu@gmail.com 
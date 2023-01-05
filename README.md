# wincputrack
This code runs a daemon process ```wincputrack.py``` which uses the ```wmic``` program to get the details of CPU usage from all current processes on a windows machine and logs them to a file called ```wincputrack.log``` in the users home directory.

A second script, ```plot_cpu.R``` can then be run at any point to generate ```wincputrack.svg``` which is a graph showing the CPU usage for different processes over the time of the logging.  This can help track down programs which go rogue and consume CPU, and track how long they run and how much CPU they use.

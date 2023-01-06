from pathlib import Path
import time
import subprocess
import re



def main():

    log_file = Path.home() / "wincputrack.log"

    while True:
        sample_cpu(log_file)

        # We'll take a sample every 15 mins
        time.sleep(60*15)


def sample_cpu(file):

    with open(file, "at", encoding="utf8") as out:
        epoch = int(time.time())

        # We read process info from wmic as we can't see all of the
        # processes using the python packages for this.

        with subprocess.Popen(
            ["wmic","path","Win32_PerfFormattedData_PerfProc_Process","get","Name,PercentProcessorTime"],
            stdout=subprocess.PIPE,
            shell=False,
            encoding="UTF-8"
        ) as running_proc:


            running_proc.stdout.readline() # Throw away header

            for line in running_proc.stdout:
                line = line.strip()

                if not line:
                    continue
                
                sections = re.split("\\s{2,}",line)
                if len(sections) == 2:
                    program,cpu = sections

                    if program.startswith("_"):
                        continue

                    if program.startswith("python"):
                        continue # Ignore this program

                    if program == "Idle":
                        continue

                    cpu = int(cpu)
                    if cpu == 0:
                        continue
                    print(f"{epoch}\t{program}\t{cpu}", file=out)



if __name__ == "__main__":
    main()

# collect-java-process-info
A simple shell that can help you collect some infomation about Java process, such as cpu, gc, stack, heap.

## Background
Some JDK tools are very useful for troubleshooting java process issues, such as jmap, jstack, jstat. But sometimes we need more than one tool to diagnosis one problem. For example, we need to use top and jstack at the same time to collect informations that can help us analysis high cpu issue. It will be a little difficult that input the commands by hand for such a thing. This shell script can help you collect cpu, gc, stack and heap information almost at the same time.


## Usage
```
Usage: bash collect-java-process-info.sh [options..]
Options:
--gc                   collect gc info
--cpu                  collect cpu info
--stack                collect stack info
--heap                 collect heap info
--interval SECONDS     seconds between two collections, default is 1
--count COUNT          total count of the collections , default is 5
--keyword KEYWORD      keywords for choosing the java process
```

## Output
The output files are under the **output** directory which is in the same directory with the script. The directory structure is like this.
```
output/
    ${pid}/
        top.yyyyMMddHHmmSS.txt
        jstack.yyyyMMddHHmmSS.txt
        jstat.yyyyMMddHHmmSS.txt
        heap..yyyyMMddHHmmSS.hprof
```
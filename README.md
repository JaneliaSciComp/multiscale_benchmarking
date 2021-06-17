# multiscale_benchmarking

Large Scale Benchmark:

Key Question:
- Which library + framework + configuration combination on average takes the least number of slot seconds to downsample a large n5 volume?

Source Data:
- s0 data set for old Z0720_07m_BR Sec30 alignment that we no longer need
- {
    "dataType":"uint8",
    "compression":{"type":"gzip","useZlib":false,"level":-1},
    "blockSize":[128,128,64],                                  # sorry Davis for irregular block size, assuming doesn't really matter
    "dimensions":[30519,8400,41163]
  }
- moved to /nrs/flyem/bench/Z0720_07m_BR.n5 so that it's clear we want to keep it around for benchmark testing
- made read-only to prevent accidental overwrites from tests
- here is another alignment of that same tab if you want to get a quick feel for the data set: https://bit.ly/3nUAWeA

Test Areas:
- thinking we can run tests here and remove s1-n directories after each test
- /nrs/flyem/bench/Z0720_07m_BR.n5/test_dask_down:
    attributes.json
    s0 -> /nrs/flyem/bench/Z0720_07m_BR.n5/render/Sec30/v1_acquire_trimmed_align___20210413_194018/s0
- /nrs/flyem/bench/Z0720_07m_BR.n5/test_spark_down:
    attributes.json
    s0 -> /nrs/flyem/bench/Z0720_07m_BR.n5/render/Sec30/v1_acquire_trimmed_align___20210413_194018/s0

Possible Variants to Test:
- spark  1 slot worker ( 1 slot/executor,  1 executor/worker,  0 overhead slot/worker)   # how much does having so many JVMs affect performance
- spark 11 slot worker ( 5 slots/executor, 2 executors/worker, 1 overhead slot/worker)   # fits well with busy cluster and 48-core nodes, potential new default setup but would like to verify
- spark 32 slot worker ( 6 slots/executor, 5 executors/worker, 2 overhead slots/worker)  # our old default setup
- spark 44 slot worker (41 slots/executor, 1 executor/worker,  2 overhead slots/worker)  # similar to 11 slot but with one JVM, how much does GC affect performance
- dask ... need Davis to suggest useful variants

Test Task:
- downsample 5 levels (s1 - s5) of the source s0 volume

Other Details:
- run each test 10? times and look at median slot seconds in feeble attempt to mitigate variances in cluster and file system environment conditions
- set up jobs to use 220 to 240 slots (5 full cluster nodes), small-ish runs that are big enough to exercise framework
- ???

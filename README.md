# Large Scale Benchmark
 
## Design

### Test Task:
- Downsample 5 levels (s1 - s5) of a reasonably large source s0 volume.

### Key Question:
- Which library + framework + configuration combination on average takes the least number of slot seconds to downsample a large n5 volume?

### Source Data:
- s0 data set for old Z0720_07m_BR Sec30 alignment that we no longer need has been moved to `/nrs/flyem/bench/Z0720_07m_BR.n5` so that it's clear we want to keep it around for testing
- full path to data set is: `/nrs/flyem/bench/Z0720_07m_BR.n5/render/Sec30/v1_acquire_trimmed_align___20210413_194018/s0` 
- data set attributes are: 
```json
  {
    "dataType":"uint8",
    "compression":{"type":"gzip","useZlib":false,"level":-1},
    "blockSize":[128,128,64],
    "dimensions":[30519,8400,41163]
  }
```
- made read-only to prevent accidental overwrites from tests
- for more context, here is our [reconstruction information](https://github.com/JaneliaSciComp/Z0720_07m_recon/issues/15) about the tab

### Test Areas:
- write down-sampled test results to `/nrs/flyem/bench/Z0720_07m_BR.n5/test_[dask|spark]_down/[test name]`

### Variants to Test:
| Test | Short Description | Full Description | Notes |
| --- | --- | --- | --- |
| SA | spark single core | 1 slot/executor,  1 executor/worker,  0 overhead slot/worker (220 total worker slots) | Does having so many JVMs affect performance? |
| SB | spark current default | 5 slots/executor, 2 executors/worker, 1 overhead slot/worker (220 total worker slots) | This is the current but relatively new default setup that we'd like to verify. |
| SC | spark legacy default | 6 slots/executor, 5 executors/worker, 2 overhead slots/worker (224 total worker slots) | This is the legacy setup we used before the 2021 cluster upgrade. |
| SD | spark fat executor | 42 slots/executor, 1 executor/worker,  2 overhead slots/worker (220 total worker slots) | Does having so much in one JVM affect performance (e.g. because of GC problems)? |
| DA | dask ... | | |

### Other Details:
- run each test 10? times and look at median slot seconds in feeble attempt to mitigate variances in cluster and file system environment conditions
- set up jobs to use roughly 220 slots (5 full cluster nodes), small-ish runs that are big enough to exercise framework
- ???
 
## Results

| Test | Run Date | Slot Seconds | Total Worker Slots | Turnaround Seconds | Notes |
| --- | --- | --- | --- | --- | --- |
| SA | 2021-06-18 | 447,040 | 220 | 2,032 |  `/groups/scicompsoft/home/trautmane/.spark/20210618_164316/logs/04-driver.log` |
| SA | 2021-06-19 | 738,760 | 220 | 3,358 |  `/groups/scicompsoft/home/trautmane/.spark/20210619_184638/logs/04-driver.log` |
| SB | 2021-06-19 | 530,860 | 220 | 2,413 |  `/groups/scicompsoft/home/trautmane/.spark/20210619_092316/logs/04-driver.log` |
| SB | 2021-06-19 | 568,920 | 220 | 2,586 |  `/groups/scicompsoft/home/trautmane/.spark/20210619_205914/logs/04-driver.log` |
| SC | 2021-06-19 | 488,768 | 224 | 2,182 |  `/groups/scicompsoft/home/trautmane/.spark/20210619_100609/logs/04-driver.log` |
| SC | 2021-06-19 | 600,544 | 224 | 2,681 |  `/groups/scicompsoft/home/trautmane/.spark/20210619_212851/logs/04-driver.log` |
| SD | 2021-06-19 | 850,520 | 220 | 3,866 |  `/groups/scicompsoft/home/trautmane/.spark/20210619_110125/logs/04-driver.log` |
| SD | 2021-06-19 | 847,440 | 220 | 3,852 |  `/groups/scicompsoft/home/trautmane/.spark/20210619_234249/logs/04-driver.log` |

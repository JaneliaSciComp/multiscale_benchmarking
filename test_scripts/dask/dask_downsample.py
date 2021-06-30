from cosem_flows.multiscale import Multiscales
from xarray_multiscale import multiscale
from fibsem_tools.io import read, read_xarray
import numpy as np
import dask
from tlz import get
from distributed import Client, performance_report
from dask_janelia import get_cluster
import os

num_workers = 25
tpw = 4
name = f'lsf_nw-{num_workers}_tpw-{tpw}'
levels = list(range(1,6))

def reducer(v, **kwargs):
    return np.mean(v, dtype='float32', **kwargs)

source_path = '/nrs/flyem/bench/Z0720_07m_BR.n5/render/Sec30/v1_acquire_trimmed_align___20210413_194018/s0'
target_path = '/nrs/flyem/bench/Z0720_07m_BR.n5/test_dask_down/'
store_chunks = read(source_path, storage_options={'normalize_keys': False}).chunks
read_chunks=(1024,1024,1024)

data = read_xarray(source_path, storage_options={'normalize_keys': False}, chunks=read_chunks, name='test_data')

_multi = get(levels, multiscale(data, reducer, (2,2,2)))
multi = []
for m in _multi:
    c = np.array(m.data.chunksize)
    x = np.array(m.data.chunksize) // np.array(store_chunks)
    c[x < 1] = np.array(store_chunks)[x<1]
    multi.append(m.chunk(c.tolist()))
    
multi_store = Multiscales(name, {f's{l}' : m for l,m in zip(levels, multi)})
store_group, store_arrays, storage_op = multi_store.store(target_path, output_chunks=store_chunks, mode='a')

if __name__ == '__main__':
    with get_cluster(threads_per_worker=tpw) as cluster, Client(cluster) as cl:
        print(cl.cluster.dashboard_link)
        cl.cluster.scale(num_workers)
        with performance_report(filename=os.path.join(target_path, f'{name}_report.html')):
            result = cl.compute(dask.delayed(storage_op), sync=True)
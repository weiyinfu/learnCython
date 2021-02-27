"""
DON'T format this file to avoid import error
"""
import multiprocessing as mp
from multiprocessing import Process, Pipe
from typing import List

import numpy as np
cimport numpy as np
from tqdm import tqdm

DOUBLE_TYPE = np.double
ctypedef np.double_t DOUBLE_TYPE_t
INT64_TYPE = np.int64
ctypedef np.int64_t INT64_TYPE_t
INT32_TYPE=np.int32
ctypedef np.int32_t INT32_TYPE_t

cdef int _find_root_nparry_int32(np.ndarray[INT32_TYPE_t, ndim=1] arr, int point):
    cdef int ans, i, temp
    i = point
    while arr[i]!=i:
        i=arr[i]
    ans=i
    i=point
    while ans!=i:
        temp=arr[i]
        arr[i]=ans
        i=temp
    return ans

def _find_root_slow_wyf(arr,point)->int:
    i = point
    while arr[i]!=i:
        i=arr[i]
    ans=i
    i=point
    while arr[i]!=i:
        temp=arr[i]
        arr[i]=ans
        i=temp
    return ans


def _find_root_slow(arr,point)->int:
    i = point
    back_arr = []
    while arr[i]!=i:
        back_arr.append(i)
        i=arr[i]
    ans=i
    for x in reversed(back_arr):
        arr[x] = ans
    return ans

cdef _compress_union_find(np.ndarray[INT32_TYPE_t,ndim=1]arr):
    # 压缩并查集数组
    cdef int sz=len(arr)
    for i in range(sz):
        if arr[i]==i:
            continue
        arr[i]=_find_root_nparry_int32(arr, i)

def find_root(arr, point):
    # python的find_root和C++的find_root的封装，充当路由器功能
    if type(arr)==np.ndarray and arr.dtype==np.int32:
        return _find_root_nparry_int32(arr, point)
    else:
        return _find_root_slow(arr,point)

def compress_union_find(np.ndarray[INT32_TYPE_t,ndim=1]arr):
    """
    展平一个并查集数组
    :param arr:
    :return:
    """
    _compress_union_find(arr)

cdef class DisjointSet:
    """
    使用cython实现的并查集
    """
    cdef int n
    cdef int [:]_father
    cdef int [:]_rank #使用rank，优先把小类合并到大类上面去，使得father改变的结点尽量少
    cdef int _n_sets
    def __cinit__(self, n,optimize_rank:bool=False):
        self.n = n
        self.root=np.arange(0,n,dtype=np.int32)
        self._father = self.root.data # 使用视图，下表索引会快一些
        self.optimize_rank=False
        if optimize_rank:
            self.rank_np=np.ones(n,dtype=np.int32)
            self._rank=self.rank_np.data
        else:
            self.rank=None
        self._n_sets = n

    cdef int _find(self, int i):
        if self._father[i] == i:
            return i
        else:
            self._father[i] = self.find(self._father[i])
            return self._father[i]

    def find(self, int i):
        if (i < 0) or (i > self.n):
            raise ValueError("Out of bounds index.")
        return self._find(i)

    def union(self, int i, int j):
        if (i < 0) or (i > self.n) or (j < 0) or (j > self.n):
            raise ValueError("Out of bounds index.")

        cdef int root_i, root_j
        root_i = self.find(i)
        root_j = self.find(j)
        if root_i != root_j:
            self._n_sets -= 1
            if self.optimize_rank:
                if self._rank[root_i] < self._rank[root_j]:
                    self._father[root_i] = root_j
                    return root_j
                elif self._rank[root_i] > self._rank[root_j]:
                    self._father[root_j] = root_i
                    return root_i
                else:
                    self._father[root_i] = root_j
                    self._rank[root_j] += 1
                    return root_j
            else:
                if root_i<root_j:
                    self._father[root_j]=root_i
                    return root_i
                else:
                    self._father[root_i]=root_j
                    return root_j
        else:
            return root_i

    property n_sets:
        def __get__(self):
            return self._n_sets


    def get_set(self):
        s = {}
        for idx in range(self.n):
            root = self.find(idx)
            if root in s.keys():
                c = s[root]
                c.append(idx)
            else:
                s[root] = [idx]
        return list(s.values())
    def __len__(self):
        return self.n

    def get_roots(self):
        return [i for i in range(self.n) if self._father[i]==i]

class DisjointSetFast(DisjointSet):
    # 使用python封装并查集
    pass

class DisjointSetSlow:
    """
    纯Python版并查集
    """
    def __init__(self, n):
        self.root = np.arange(n, dtype=np.int32)

    def __len__(self):
        return len(self.root)

    def find(self, x:int)->int:
        return _find_root_nparry_int32(self.root,x)

    def union(self, x1:int, x2:int)->int:
        self.root[self.find(x2)] = self.find(x1)

    def get_roots(self)->List[int]:
        return [i for i, r in enumerate(self.root) if i == r]

class MultiProcessCompress:
    """
    不要使用多进程并查集压缩，因为它非常慢，建议使用本文件的compress函数
    """
    @staticmethod
    def path_compress_worker(wid, shared_arr, start_idx, end_idx, pipe):
        root_set = set()
        for idx in range(start_idx, end_idx):
            root_id = find_root(shared_arr, idx)
            root_set.add(root_id)
        pipe.send(root_set)
        pipe.close()

    @staticmethod
    def compress(ar:np.ndarray,parallel:int):
        compress_ps = []
        n = len(ar)
        part_size = (n - 1) // parallel + 1
        for index, i in enumerate(range(0, n, part_size)):
            pconn, cconn = Pipe(duplex=False)
            p = Process(
                target=MultiProcessCompress.path_compress_worker,
                args=(index, ar, i, min(i + part_size, n), cconn),
            )
            p.daemon = True
            p.start()
            cconn.close()
            compress_ps.append([p, pconn])
        root_set = set()
        for parallel_id, (p, pconn) in enumerate(
                tqdm(compress_ps, desc="collecting_compress_worker")
        ):
            if pconn.poll(3600 * 24):
                _root_set = pconn.recv()
                root_set |= _root_set
            pconn.close()
            p.join()
        return root_set

cdef _compress(int[:] arr):
    # cython实现并查集压缩函数
    sz=len(arr)
    cdef int i
    cdef int ans
    cdef int temp
    for point in range(sz):
        if arr[point]==point:
            continue
        i=point
        while arr[i]!=i:
            i=arr[i]
        ans=i
        i=point
        while arr[i]!=i:
            temp=arr[i]
            arr[i]=ans
            i=temp

def compress(int[:]arr):
    # 使用python封装并查集压缩函数
    _compress(arr)


def to_set(ar):
    # 把一个并查集转换成llint
    a = {}
    cdef int i
    for i in range(len(ar)):
        root = find_root(ar, ar[i])
        if root not in a:
            a[root] = []
        a[root].append(i)
    ll = a.values()
    ll = sorted([sorted(l) for l in ll])
    return ll

cdef __to_set_and_map(int[:]ar,int[:]id_map):
    # 把一个并查集转换成llint，其中并查集中下标会使用id_map进行映射
    a = {}
    cdef int i
    for i in range(len(ar)):
        root = find_root(ar, ar[i])
        if root not in a:
            a[root] = []
        a[root].append(id_map[i])
    ll = a.values()
    ll = sorted([sorted(l) for l in ll])
    return ll

def to_set_and_map(ar:np.ndarray,id_map:np.ndarray)->List[List[int]]:
    return __to_set_and_map(ar,id_map)

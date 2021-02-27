import subprocess as sp

from timeit import timeit

n = 90
iter_count = 100000


def c():
    sp.check_output(f"./a.out {n} {iter_count}", shell=True)


def py():
    sp.check_output(f"python fib.py {n} {iter_count}", shell=True)


import cyfib


def cython_cdef():
    cyfib.go_cdef(n, iter_count)


def cython_pure_py():
    cyfib.go_pure_py(n, iter_count)


def cython_def():
    cyfib.go_def(n, iter_count)


for i in (c, py, cython_def, cython_cdef, cython_pure_py):
    ans = timeit(lambda: i(), number=1)
    print(i.__name__, ans)

cdef fib_cdef(int n):
    cdef int i
    cdef double a = 0.0, b = 1.0
    for i in range(n):
        a, b = a + b, a
    return a
def fib_def(int n):
    cdef int i
    cdef double a = 0.0, b = 1.0
    for i in range(n):
        a, b = a + b, a
    return a

def fib_pure_py(n):
    a, b = 0, 1
    for i in range(n):
        a, b = a + b, a
    return a

def go_cdef(int n, int iter_count):
    cdef int i
    for i in range(iter_count):
        fib_cdef(n)

def go_pure_py(int n, int iter_count):
    cdef int i
    for i in range(iter_count):
        fib_pure_py(n)

def go_def(int n, int iter_count):
    cdef int i
    for i in range(iter_count):
        fib_def(n)

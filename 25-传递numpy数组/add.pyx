def add(double[:]a):
    cdef int i
    i=0
    while i<len(a):
        a[i]+=3
        i+=1
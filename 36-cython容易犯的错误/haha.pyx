def go():
    cdef int i
    i=0
    print(i)
    a=[1.25,3.2]
    for i in a:
        # 此处会发生类型转换，float变成int
        print(i)
TEXT_TO_SAY = 'Hello from Python!'

cdef public int say_hello_from_python() except -1:
    print(TEXT_TO_SAY)
    return 0

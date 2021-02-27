def get_primes(int n):
    # 求小于n的全部质数
    assert n<1000
    cdef int is_prime[1000]
    for k in range(1000):
        is_prime[k]=1
    cdef int i,j

    ans=[]
    i=2
    while i<n:
        if is_prime[i]:
            ans.append(i)
        for j in range(i,n,i):
            is_prime[j]=0
        i+=1
    return ans
#include<stdio.h>
#include<stdlib.h>
double cfib(int n) {
    int i;
    double a=0.0, b=1.0, tmp;
    for (i=0; i<n; ++i) {
        tmp = a; a = a + b; b = tmp;
    }
    return a;
}
int main(int argc,char**argv){
//    printf("%d",argc);
    int n=atoi(argv[1]);
    int iterCount=atoi(argv[2]);
    while(iterCount--){
        cfib(n);
    }
    return 0;
}

#include <iostream>
#include <time.h>


using namespace std;


int main( int argc, char *argv[] ) {
  clock_t start, finish;

  start = clock();

  cout << "Hello, C++" << endl;

  finish = clock();

  double duration = ( double ) ( finish - start ) / CLOCKS_PER_SEC;
  cout << "elapse=" << duration << endl;

  return 0;
}

#include <iostream>
#include "tbb/tick_count.h"


using namespace std;
using namespace tbb;


int main( int argc, char *argv[] ) {
  tick_count start, finish;

  start = tick_count::now();

  cout << "Hello, TBB" << endl;

  finish = tick_count::now();

  double duration = ( finish - start ).seconds();
  cout << "elapse=" << duration << endl;

  return 0;
}

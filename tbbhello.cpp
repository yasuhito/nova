#include "tbb/task_scheduler_init.h"
#include "tbb/tick_count.h"
#include <iostream>


using namespace std;
using namespace tbb;


int main() {
  tick_count start, finish;

  start = tick_count::now();
  task_scheduler_init init;

  cout << "Hello, TBB" << endl;
  init.terminate();

  finish = tick_count::now();

  double duration = ( finish - start ).seconds();
  cout << "elapse=" << duration << endl;

  return 0;
}

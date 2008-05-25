#include "tbb/blocked_range.h"
#include "tbb/parallel_reduce.h"
#include "tbb/task_scheduler_init.h"
#include "tbb/tick_count.h"
#include <iostream>


using namespace std;
using namespace tbb;


const size_t MAX_N = 1000000;
double a[ MAX_N ];


struct Sum {
  double value;


  Sum() : value( 0 ) {
  }


  Sum( Sum& s, split ) {
    value = 0;
  }


  void operator()( const blocked_range< double * >& range ) {
    double temp = value;

    for ( double* a = range.begin() ; a != range.end() ; ++a ) {
      temp += *a;
    }
    value = temp;
  }


  void join( const Sum& rhs ) {
    value += rhs.value;
  }
};


int main() {
  for ( size_t i = 0 ; i < MAX_N ; i++ ){
    a[ i ] = i * 1.01;
  }

  tick_count start = tick_count::now();
  task_scheduler_init init;

  Sum total;
  parallel_reduce( blocked_range< double * >( a, a + MAX_N ), total, auto_partitioner() );

  double sum = total.value;

  init.terminate();

  tick_count finish = tick_count::now();
  double elapse = ( finish - start ).seconds();

  cout << "sum=" << std::scientific << sum << endl;
  cout << "elapse=" << std::fixed << elapse << "(sec)" << endl;

  return 0;
}

#include "tbb/blocked_range.h"
#include "tbb/parallel_for.h"
#include "tbb/task_scheduler_init.h"
#include "tbb/tick_count.h"
#include <iostream>


using namespace std;
using namespace tbb;


const int MAX_N = 100000;
int x[ MAX_N ];


class Prime {
  int *v;
  int *cnt;


public:


  void operator()( const blocked_range< int >& range ) const {
    for ( int n = range.begin() ; n != range.end() ; n++ ) {
      bool fPrime = true;
      for ( int j = 2 ; j < n ; j++ ) {
        if ( ( n % j ) == 0 ) {
          fPrime = false;
          break;
        }
      }
      if ( fPrime ) {
        v[ *cnt ] = n;
        ( *cnt ) += 1;
      }
    }
  }


  int getCount() {
    return( *cnt );
  }


  Prime( int *n, int *c ) : v( n ), cnt( c ) {
  }
};


int main() {
  tick_count start = tick_count::now();
  task_scheduler_init init;

  int counter = 0;
  Prime *prime = new Prime( x, &counter );
  parallel_for( blocked_range< int >( 2, MAX_N, 100 ), *prime );

  init.terminate();

  tick_count finish = tick_count::now();
  double elapse = ( double ) ( finish - start ).seconds();

  cout << "counter=" << counter << endl;
  cout << "elapse=" << elapse << "(sec)" << endl;
  for ( int i = 0 ; i < 50 ; i++ ) {
    cout << x[ i ] << ", ";
  }
  cout << endl << "..." << endl;
  for ( int i = counter - 50; i < counter; i++ ) {
    cout << x[ i ] << ", ";
  }
  cout << endl;

  return 0;
}

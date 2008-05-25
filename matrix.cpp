#include "tbb/blocked_range2d.h"
#include "tbb/parallel_for.h"
#include "tbb/task_scheduler_init.h"
#include <ctime>
#include <iostream>


using namespace std;
using namespace tbb;


const size_t L = 128;
const size_t M = 256;
const size_t N = 192;


double a[ M ][ L ];
double b[ L ][ N ];
double c[ M ][ N ];


class MatricMult {
  double ( *a )[ L ];
  double ( *b )[ N ];
  double ( *c )[ N ];


public:


  void operator()( const blocked_range2d< size_t > &range ) const {
    double ( *aa )[ L ] = a;
    double ( *bb )[ N ] = b;
    double ( *cc )[ N ] = c;

    for ( size_t i = range.rows().begin() ; i != range.rows().end(); i++ ) {
      for ( size_t j = range.cols().begin() ; j != range.cols().end() ; j++ ) {
        double total = 0;
        for ( size_t k = 0 ; k < L ; k++ ) {
          total += a[ i ][ k ] * b[ k ][ j ];
        }
        c[ i ][ j ] = total;
      }
    }
  }
  MatricMult( double aa[ M ][ L ], double bb[ L ][ N ], double cc[ M ][ N ] )
  : a( aa ), b( bb ), c( cc ) {}
};


int main() {
  task_scheduler_init init;

  time_t t;
  srand( ( unsigned ) time( &t ) );

  for ( size_t i = 0 ; i < M ; i++ ) {
    for ( size_t j = 0 ; j < L ; j++ ) {
      a[ i ][ j ] = rand() * 0.1;
    }
  }

  for ( size_t i = 0 ; i < L ; i++ ) {
    for ( size_t j = 0 ; j < N ; j++ ) {
      b[ i ][ j ] = rand() * 0.1;
    }
  }

  parallel_for( blocked_range2d< size_t >( 0, M, 0, N ), MatricMult( a, b, c ), auto_partitioner() );

  cout << "done" << endl;

  for ( size_t i = 0 ; i < 5 ; i++ ) {
    for ( size_t j = 0 ; j < 5 ; j++ ) {
      cout << a[ i ][ j ] << " ";
    }
    cout << endl;
  }
  cout << endl;

  for ( size_t i = 0 ; i < 5 ; i++ ) {
    for ( size_t j = 0 ; j < 5 ; j++ ) {
      cout << b[ i ][ j ] << " ";
    }
    cout << endl;
  }
  cout << endl;

  for ( size_t i = 0 ; i < 5 ; i++ ) {
    for ( size_t j = 0 ; j < 5 ; j++ ) {
      cout << c[ i ][ j ] << " ";
    }
    cout << endl;
  }

  return 0;
}

#include <iostream>
#include <time.h>


using namespace std;


const size_t MAX_N = 1000000;
double a[ MAX_N ];


int main() {
  for ( size_t i = 0 ; i < MAX_N ; i++ ){
    a[ i ] = i * 1.01;
  }

  double sum = 0.0;
  clock_t start = clock();

  for ( size_t i = 0 ; i < MAX_N ; i++ ){
    sum += a[ i ];
  }

  clock_t finish = clock();
  double elapse = ( double )( finish - start ) / CLOCKS_PER_SEC;

  cout << "sum=" << std::scientific << sum << endl;
  cout << "elapse=" << std::fixed << elapse << "(sec)" << endl;

  return 0;
}

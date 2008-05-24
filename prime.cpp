#include <iostream>
#include <time.h>


using namespace std;


const int MAX_N = 100000;
int x[ MAX_N ];


int main() {
  clock_t start = clock();
  int counter = 0;

  for ( int n = 2; n <= MAX_N; n++ ) {
    bool fPrime = true;
    for (int j = 2 ; j < n ; j++ ) {
      if ( ( n % j ) == 0 ) {
        fPrime = false;
        break;
      }
    }
    if ( fPrime ) {
      x[ counter++ ] = n;
    }
  }

  clock_t finish = clock();
  double elapse = ( double ) ( finish - start ) / CLOCKS_PER_SEC;

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

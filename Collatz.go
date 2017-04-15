// Tom Marquez
// 4/10/2016

// 2 versions of the collatz algorithm
// implemented in Golang

package main

import "fmt"

func recursiveCollatz(num int){
	fmt.Print(num, ", ")
	if num == 1 {
		return
	}else if num % 2 == 0 {
		recursiveCollatz(num / 2)
	}else {
		recursiveCollatz(3 * num + 1)
	}
}

////////////goroutine example/////////////////////////////
func main() {

	done := make(chan bool)

	go func() {
		recursiveCollatz(5)
		done <- true
	}()

	//recursiveCollatz(5)

	recursiveCollatz(7)
	fmt.Println()
	<- done

}

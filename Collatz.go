// Tom Marquez
// 4/10/2016

// 2 versions of the collatz algorithm
// implemented in Golang

package main

import "fmt"

func collatz(num int) int{
	fmt.Print(num, ", ")
	if num == 1 {
		return 1
	}else if num % 2 == 0 {
		return (num / 2)
	}else {
		return(3 * num + 1)
	}
}

func recursiveCollatz(num int){
	fmt.Print(num, ", ")
	if num == 1 {
		return
	}else if num % 2 == 0 {
		collatz(num / 2)
	}else {
		collatz(3 * num + 1)
	}
}

func main() {
	num := 3
	for num >= 1 {
		num = collatz(num)
		if num == 1 {
			fmt.Print(num)
			break
		}
	}

	//recursiveCollatz(3)
}

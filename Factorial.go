package main

import "fmt"

// factoiral using channels
func factorial (num int, product int, result chan int){
	product = product * num

	if num == 1{
		result <- product
		return
	}
	go factorial(num - 1, product, result)

}

func main() {

	result := make(chan int)
	number := 5
	product := 1

	factorial(number, product, result)
	total := <-result
	fmt.Println("Total = ", total)
}

// Created by tom on 4/10/17
//
// GoLangTypes
//
///////////////////////////////////

package main

import "fmt"

func main(){

//////////////various int variables:////////////////////////////////////////
	var num8 uint8
	//var num16 uint16

	num8 = 5
	//num16 = 5

	// the code below will not work: mismatched types
	//fmt.Print(num8 + num16)

	var b byte
	b = 5
	// code below will work:
	// byte = uint8
	fmt.Println(b + num8)

	// generally, use int for integers declarations
	// int is size 32 or 64, depending on compiler

//////////////Strings//////////////////////////////////////////////////////
	var hello string
	var tom string
	hello = "hello"
	tom = "Tom"

	fmt.Println(hello + " " +  tom)
	// declaration and assgnment on one line using ":="
	concat := tom + " " + hello
	fmt.Println(concat)

/////////////Multiple assignments//////////////////////////////////////////
	var (
		have = "Have"
		a = "a"
		good = "good"
		day = "day"
		space = " "
	)

	fmt.Println(have + space + a + space + good + space + day)

//////////////Arrays://////////////////////////////////////////////////////
	var array [5]int
	array[0] = 0
	array[1] = 1
	array[2] = 2
	array[3] = 3
	array[4] = 4
	fmt.Println(array) //prints [0 1 2 3 4]

///////////////Slices: like arrays but size is not needed//////////////////
	slc := []int{1,2,3,4}
	slc1 := slc[0:2] // a slice of a slice
	slc2 := append(slc1, 2, 5, 15) // slc2 = slc1 + 2 + 5 + 15
	fmt.Println("slc: ", slc)
	fmt.Println("slc1: ", slc1)
	fmt.Println("slc2: ", slc2)

//////////////Map//////////////////////////////////////////////////////////
	animals := make(map[string]string)
	animals["dog"] = "Fydo"
	animals["cat"] = "Pookie"
	animals["bear"] = "Yogi"
	fmt.Println("animals: ", animals)
	for _, value := range animals {
		fmt.Println(value)
	}

//////////////for loop////////////////////////////////////////////////////
	var total int64
	for i := 0; i < len(array); i++ {
		total += int64(array[i]) //explicit casting
	}
	fmt.Println("Total: ", total)

///////////////another for loop without iterator//////////////////////////
	var total1 int32
	for _, value := range array { //underscore tells compiler that an iterator is not needed
		total1 += int32(value)
	}
	fmt.Println("Total1: ", total1)



}

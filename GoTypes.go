// Created by tom on 4/10/17
//
// GoLangTypes
//
///////////////////////////////////

package main

import (
	"fmt"
	"bufio"
	"os"
	"strings"
)

func changeNum(num int){
	num = 8
}


func changePointer(num *int) {
	*num = 8
}

type Person struct {
	name string
	age int
}

func main(){

//////////////various int variables:////////////////////////////////////////

	// the code below will not work: mismatched types
	//fmt.Print(num8 + num16)
	var x uint8
	x = 5

	var y byte
	y = 5
	// code below will work:
	// byte = uint8
	fmt.Println(x + y)

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
		have = "Have "
		a = "a "
		good = "good "
		day = "day"
	)

	fmt.Println(have + a + good + day)

//////////////Arrays://////////////////////////////////////////////////////
	array := []int{0, 1, 2, 3, 4, 5}
	/*var array [5]int
	array[0] = 0
	array[1] = 1
	array[2] = 2
	array[3] = 3
	array[4] = 4
	*/
	fmt.Println(array) //prints [0 1 2 3 4]

///////////////Slices: like arrays but size is not needed//////////////////
	slc := []int{1,2,3,4}
	slc1 := slc[0:2] // a slice of a slice
	slc2 := append(slc1, 2, 5, 15) // slc2 = slc1 + 2 + 5 + 15
	fmt.Println("slc: ", slc)
	fmt.Println("slc1: ", slc1)
	fmt.Println("slc2: ", slc2)

///////////////////////Map/////////////////////////////////////////////////
/////////////The "make" function allocates a zeroed array /////////////////
/////////////and returns a slice that refers to that array/////////////////
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
		//fmt.Println(i)
	}
	fmt.Println("Total1: ", total1)

///////////////Pointers//////////////////////////////////////////////////
	z := 5
	p := &z

	fmt.Println("int z: ", z)
	fmt.Println("pointer p: ", *p)

	changeNum(z)
	fmt.Println("z after function call with z: ", z)

	fmt.Println("Now using a pointer")
	changePointer(p)
	fmt.Println("z now after function called with pointer: ", z)

///////////////Structs////////////////////////////////////////////////
	var p1 = new(Person)
	p1.name = "Jimmy"
	p1.age = 21

	fmt.Println("Name: ", p1.name, "Age: ", p1.age)

	p2 := Person{"Tim", 25}
	fmt.Println("Name: ", p2.name, "Age: ", p2.age)

///////////////Structs used with switch statements///////////////////
	p3 := p1

	fmt.Println("p3 name: ", p3.name)

	switch p3.name {
	case "Jimmy":
		fmt.Println("Same name as p1")
		fallthrough   ///switch statement with a fallthrough
	case "Tim":
		fmt.Println("Same name as p2")
	}

//////////////infinite for loop stdin//////////////////////////////////////
	for{
		reader := bufio.NewReader(os.Stdin)
		fmt.Print("Enter some text: ")
		text, _ := reader.ReadString('\n')
		fmt.Println(text)
		text = strings.Replace(text, "\n", "", -1) //replaces \n character with an empty character.

		if strings.Compare(text, "done") == 0 {
			break
		}

	}
}

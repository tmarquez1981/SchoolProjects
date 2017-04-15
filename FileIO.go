// Created by tom on 4/13/17
//
// GoFile_IO
//
///////////////////////////////////

package main

import(
	"fmt"
	"bufio"
	"os"
	//"io"
	"io/ioutil"
)

func check(e error) {
	if e != nil {
		panic(e)
	}
}

func main() {

	fileName := "fileExp.txt"

	reader := bufio.NewReader(os.Stdin)
	fmt.Print("Enter some text: ")
	text, _ := reader.ReadString('\n')
	fmt.Println(text)
	textByte := []byte(text)

	fmt.Print("Writing ", text, " to file ", fileName)

	err := ioutil.WriteFile(fileName, textByte, 0644)
	check(err)

}

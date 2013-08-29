package main

import (
  "fmt"
  "os"
  "io"
  "net"
  "bufio"
  "strings"
  "strconv"
)

func ListenForResponses(conn net.Conn, incoming chan string) {
  reader := bufio.NewReader(conn)
  for {
    numBytes, _ := reader.ReadString('\n')
    numBytes = strings.Trim(numBytes, "\n")
    i, _ := strconv.ParseUint(numBytes, 10, 64)

    buf := make([]byte, i)
    io.ReadFull(reader, buf)

    incoming <- string(buf)
  }
}

func ListenForStdin(outgoing chan string) {
  reader := bufio.NewReader(os.Stdin)
  for {
    jsonstr, e := reader.ReadString('\n')
    if e == io.EOF {
      jsonstr = "exit"
    }
    outgoing <- jsonstr
  }
}

func main() {
  conn, err := net.Dial("unix", "/tmp/zephyros.sock")
  if err != nil {
    fmt.Println("Can't connect. Is Zephyros running?")
    os.Exit(1)
  }

  incoming := make(chan string, 5)
  outgoing := make(chan string)

  go ListenForResponses(conn, incoming)
  go ListenForStdin(outgoing)

  MainLoop:
  for {
    fmt.Print("-> ")

    select {
    case request := <- outgoing:
      if request == "exit" {
        break MainLoop
      }
      fmt.Fprintf(conn, "%v\n%v", len(request), request)
      firstResponse := <- incoming
      fmt.Printf("<- %v\n", firstResponse)
    case asyncResponse := <- incoming:
      fmt.Printf("\n<- %v\n", asyncResponse)
    }
  }
}

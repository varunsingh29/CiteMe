#!/usr/bin/env/ bats

@test "Dunning Kruger Sample Test Case 1" {
  result="$(bash CiteMe_Testing.sh < inp1.txt)"
  out="$(cat out1.txt)"
  [ "$result" == "$out" ]
}

@test "Dunning Kruger Sample Test Case 2" {
  result="$(bash CiteMe_Testing.sh < inp2.txt)"
  out="$(cat out2.txt)"
  [ "$result" == "$out" ]
}

@test "Validate URL: Wrong URL" {
  result="$(bash CiteMe_Testing.sh < inp3.txt)"
  out="$(cat out3.txt)"
  [ "$result" == "$out" ]
}

@test "Internet Connection Issues" {
  result="$(bash CiteMe_Testing.sh < inp4.txt)"
  out="$(cat out4.txt)"
  [ "$result" == "$out" ]
}

@test "Wikipedia Page with no Citations : Regular Grammar" {
  result="$(bash CiteMe_Testing.sh < inp5.txt)"
  out="$(cat out5.txt)"
  [ "$result" == "$out" ]
}

@test "Type 1: Get lines which have citation X - Marvel - Multiple Citations" {
  result="$(bash CiteMe_Testing.sh < inp6.txt)"
  out="$(cat out6.txt)"
  [ "$result" == "$out" ]
}

@test "Type 1: Lithium - With metacharacters in text - Single Citation" {
  result="$(bash CiteMe_Testing.sh < inp7.txt)"
  out="$(cat out7.txt)"
  [ "$result" == "$out" ]
}

@test "Type 2: Get Citations of a line - Facebook - Single Citation" {
  result="$(bash CiteMe_Testing.sh < inp8.txt)"
  out="$(cat out8.txt)"
  [ "$result" == "$out" ]
}

@test "Type 2: Facebook - Multiple Citation - Substring search" {
  result="$(bash CiteMe_Testing.sh < inp9.txt)"
  out="$(cat out9.txt)"
  [ "$result" == "$out" ]
}

@test "Entering Citations that do not exist" {
  result="$(bash CiteMe_Testing.sh < inp10.txt)"
  out="$(cat out10.txt)"
  [ "$result" == "$out" ]
}


# A Tour of Go
## Imports | パッケージの参照

```go
import "fmt"

import (
  "fmt"
  "math/rand"
)
```

## Functions | 関数
```go
func add(x int, y int) int {
  return x + y
}
```

引数となる変数名の後ろに型名を書く。  

同じ型の引数が複数ある場合は、最後の型を省略する記述が可能。
```go
func add(x, y int) int {
  return x + y
}
```

関数は複数の戻り値を返すこともできる
```go
func swap(x, y string) (string, string) {
  return y,x
}
```

戻り値となる変数に名前を付けることも可能(named return value)  
戻り値に名前を付けると、関数の最初で定義した変数名として扱われる。  
また、名前を付けた戻り値を使うと、 `return` ステートメントに何も書かずに戻すことが可能。(これを naked returnと呼ぶ)  
naked return は、短い関数でのみ利用すべきらしい。長い関数で使うと可読性が悪くなるため非推奨。  
```go
func split(sum int) (x, y int) {
  x = sum * 4 / 9
  y = sum - x
  return
}
```

## Variable | 変数
変数の宣言には `var` ステートメントを使用する。  
```go
var c, python, java bool

func main() {
  var i int
  fmt.PrintLn(i, c, python, java)
}
```

初期化も行う場合、型を省略することができる。その変数は初期化子が持つ型と同じになる。  
```go
var i, j int = 1, 2
var c, python, java = true, false, "no"
```

括弧を使って一度に複数の変数を定義することが可能。
```go
var (
  i int = 1
  j int = 2
  v1 = Vertex{1, 2}
  v2 = Vertex{i, j}
)
```

関数の中でのみ、省略形 `:=` の代入文を使って、型宣言が可能。  
```go
func main() {
  var i, j int = 1, 2
  k := 3
  c, python, java := true, false, "no!"
  ...
}
```

# Basic Types | Goの基本の型
* bool
* string
* int, int8, int16, int32, int64
* uint, uint8, uint16, uint32, uint64, uintptr
* byte (uint8の別名)
* rune (int32の別名。Unicodeのコードポイントを表す)
* float32, float64
* complex64, complex128

`int`, `uint`, `uintptr` 型は32-bitシステムでは32bit, 64-bitシステムでは64bitで扱われる。  
特別な理由がない限り、整数の変数が必要な場合は `int` で良い。  

変数に初期値を与えずに宣言するとゼロ値が与えらられる。  
* 数値型の場合(int, float): `0`
* bool型: `false`
* string型: `""` (空文字列)

## Type Conversions | 型変換
変数 `v` を 型 `T` に変換したい場合、`T(v)` と記述することで変換ができる。  
```go
var i int = 42
var f float64 = float64(i)
var u int = uint(f)
```

C言語とは異なり、明示的な変換が必要。  
明示的に変換せずに別の型の変数に代入しようとすると、以下のようなエラーが表示される。
```go
package main

import (
	"fmt"
)

func main() {
	var i int = 42
	var f float64 = i
	fmt.Println(i,f)
}

> ./prog.go:9:18: cannot use i (variable of type int) as type float64 in variable declaration
```

## Constants | 定数
Goで定数を扱いたい場合は、 `const`キーワードを使用する。  
定数は、文字(character)、文字列(string)、boolean、数値(numeric)のみ使える。  
また、定数は `:=` を使って宣言することはできない。  
```go
const World = "世界"
const Truth = true
```

## For
`for`ループは、初期化、条件式、後処理をセミコロンで区切って記述する。  
```go
func main() {
    sum := 0
    for i := 0; i < 10; i++ {
        sum += i
    }
    fmt.Println(sum)
}
```
初期化と後処理は任意。書かなくても動作する。
```go
func main() {
    sum := 1
    for ; sum < 1000; {
        sum += sum
    }
    fmt.Println(sum)
}
```
セミコロンを省略することもできる。この書き方で `while`文のような使い方が可能。  
```go
func main() {
    sum := 1
    for sum < 1000 {
        sum += sum
    }
    fmt.PrintLn(sum)
}
```
他の言語のように、条件部分を`()`で括る必要はない。括るとシンタックスエラーになる。  
また、初期化の際に `var` を使った初期化は行えない。`:=`を使用する必要がある。  

ループ条件を省略すれば、無限ループになる。  
```go
func main() {
    for {
    }
}
```

## If
`for` と同様に括弧は不要。

```go
func sqrt(x float64) string {
    if x < 0 {
        return sqrt(-x) + "i"
    }
    return fmt.Sprint(math.Sqrt(x))
}
```

`if` ステートメントは、条件の前に、簡単なステートメントを書くことができる。  
下の例では変数`v`が宣言されている。この`v`は`if`のスコープ内だけで使用できる。  
`if`のスコープ外では `v`は使えない。
```go
func sum2(x, y, limit int) int {
	if v := x + y; v < limit {
		return v
	}
	return 0
}

func main() {
	fmt.Println(
		sum2(1,2,10),
	)
}

> 3
```

`if` と `else` の書き方
```go
func sum3(x, y, limit int) int {
	if v := x + y; v < limit {
		return v
	} else {
    	return v+1
    }
    return 0
}
```
`if`ステートメントで宣言された変数は、`else`ブロックでも使用することができる。

## Switch
`switch` ステートメントは、`if-else`ステートメントのシーケンスを短く方法。  
Goのswitchは、選択されたcaseだけを実行して、それに続く他の全てのcaseは実行されない。  
他の言語では、caseの最後に必要な `break` ステートメントがGoでは不要になる。（自動的に提供される）  
breakを明示的に記述してもエラーは起きず、実行可能。  
また、Goのswitchのcaseは定数や整数である必要がない。
```go
func choice(name string) {
	switch s := name; s {
	case "apple":
		fmt.Println("apple select")
	case "banana":
		fmt.Println("banana select")
	case "orange":
		fmt.Println("orange select")
	default:
		fmt.Println("no select")
	}
}
```
switchは、上から下へと評価される。caseの条件が一致すれば、そこで終了する。

条件のないswitchは `switch true` と書くことと同じ。  
この構造により、`if-then-else`をシンプルに表現することができる。

```go
t := time.Now()
switch {
    case t.Hour() < 12:
        fmt.Println("Good morning!")
    case t.Hour() < 17:
        fmt.Println("Good afternoon.")
    default:
        fmt.Println("Good evening.")
}
```
余談だがTour of Goでは、switchステートメントとcaseステートメントのインデントが同じ階層にある。もちろん実行可能だが、caseステートメントはswitchの `{}` の中で使われてるのでインデントさせたほうが気持ちがいい。インデントしてもエラーなく動作する。  


## Defer
`defer`ステートメントは、`defer`へ渡した関数の実行を、呼び出し元の関数の終わり(returnする)まで遅延させる。
`defer`へ渡した関数の引数は、すぐに評価されるが、その関数自体は呼び出し元の関数がreturnするまで実行されない。

```go
func main() {
	defer fmt.Println("world")

	fmt.Println("hello")
}

> hello
> world
```

`defer`へ渡した関数が複数ある場合はスタックされる。渡された関数はLIFO(最後に入れたものが最初に出る)の順番で実行される。

```go
fmt.Println("counting")

for i := 0; i < 10; i++ {
    defer fmt.Println(i)
}

fmt.Println("done")

> counting
> done
> 9
> 8
> 7
> 6
> 5
> 4
> 3
> 2
> 1
> 0
```

`defer`のより詳細な使い方は、[こちらの記事](https://go.dev/blog/defer-panic-and-recover)に誘導されていた。  

## Pointers | ポインタ
ポインタは値のメモリアドレスを指す。
変数 `T` のポインタ指定は、 `*T` 、ゼロ値は `nil`。
ポインタによってアドレスが格納された変数は `*T型` というポインタ型として扱われる。

```go
var p * int
```

`&`オペレータを使うことで、その変数のポインタ型を作ることができる。
下の例では 変数 `i` のアドレスを格納した 変数 `p` は、`*i型` になる。

```go
i := 42
p = &i
```

`*` オペレータは、ポインタが指す先の変数を示す。

```go
fmt.Println(*p) // ポインタpを通してiから値を読みだす
*p = 21         // ポインタpを通してiへ値を代入する
```

これを`dereferencing` または `indirecting`として知られている。
調べてみると、リファレンスとデリファレンスは主にC言語やPerlで解説されている記事が多い。  
リファレンスは、値のアドレスを参照するデータ(ポインタ)にアクセスすることを指す。  
デリファレンスは、ポインタ参照先(リファレンスが指している)の値にアクセスすること指す。  

## Structs | 構造体
構造体とは、フィールドの集まりのこと。

```go
type Vertex struct {
  X int
  Y int
}

func main() {
  fmt.Println(Vertex{1,2})
}

> {1 2}
```

構造体が持つフィールドにアクセスするときは、ドットを使用する。

```go
type Vertex struct {
	X int
	Y int
}

func main() {
	v := Vertex{1, 2}
	v.X = 4
	fmt.Println(v.X)
}

> 4
```

構造体のフィールドは、構造体のポインタを通してアクセスすることもできる。  
フィールド `X` を持つ構造体のポインタ `p` がある場合、フィールド `X` にアクセスする方法は `(*p).X` のように書くことができる。  
また、`p.X` のように省略して書くこともできる。  

構造体は、呼び出し時に初期値を割り当てることもできる。また、フィールドを指定して初期化することもできる。  
`&` を頭につけることで、構造体のポインタ型変数を作ることができる。

```go
type Vertex struct {
  X, Y int
}

var (
  v1 = Vertex{1, 2}
  v2 = Vertex{X: 1}
  v3 = Vertex{}
  p = &Vertex{1, 2}
)

func main() {
  fmt.Println(v1, v2, v3, p)
}

> {1 2} {1 0} {0 0} &{1 2}
```

## Arrays | 配列
`[n]T`型は型`T`の`n`個の変数の配列を表す。  

intの10個の配列を宣言する場合:  
```go
var a [10]int
```

配列への代入、配列の呼び出し方  
```go
func main() {
  var a [2]string
  a[0] = "Hello"
  a[1] = "World"
  fmt.Println(a[0], a[1])
  fmt.Println(a)

  primes := [6]int{2, 3, 5, 7, 11}
  a2 := [6]int{1, 2, 3}
  fmt.Println(primes)
  fmt.Print(a2)
}

> Hello World
> [Hello World]
> [2 3 5 7 11 13]
> [1 2 3 0 0 0]  // 初期値を設定してない要素はゼロ値で初期値される
```

配列のサイズを変えることはできない。(固定長)  


## Slices | スライス
配列は固定長なのに対し、スライスは可変長である。  
一般的に使うのは配列よりスライス。  

型 `[]T`型は型`T`のスライスを表す。  

コロンで区切られた二つのインデックスlowとhighの境界を指定することによってスライスが形成される。

```go
a[low: high]
```
スライス自体は、どんなデータも格納しておらず、元の配列の部分列を指し示す。  
スライスの要素を変更すると、その元となる配列の対応する要素が変更される。  
同じ元となる配列を共有している他のスライスは、それらの変更が反映される。  

```go
func main() {
	names := [4]string{
		"John",
		"Paul",
		"George",
		"Ringo",
	}
	fmt.Println(names)

	a := names[0:2]
	b := names[1:3]
	fmt.Println(a, b)

	b[0] = "XXX"
	fmt.Println(a, b)
	fmt.Println(names)
}

> [John Paul George Ringo]
> [John Paul] [Paul George]
> [John XXX] [XXX George]
> [John XXX George Ringo]
```
スライスという名前の通り、元の配列をスライスし。スライスした範囲を変数として生成する。  
スライス型の変数を操作すると、元の配列や、同じ元となる配列を使用して作られたスライスにも変更が反映されてしまうため、注意が必要。  

スライスのリテラルは、長さのない配列リテラルと同じようなものなので、以下のように記述することで、可変長な配列を作ることができる。

```go
[3]bool{true, true, false} //これは配列リテラル
[]bool{true, true, false}  //これはスライスリテラル
```

用例:  
```go
func main() {
	q := []int{2, 3, 5, 7, 11, 13}
	fmt.Println(q)

	r := []bool{true, false, true, true, false, true}
	fmt.Println(r)

	s := []struct {
		i int
		b bool
	}{
		{2, true},
		{3, false},
		{5, true},
		{7, true},
		{11, false},
		{13, true},
	}
	fmt.Println(s)
}

> [2 3 5 7 11 13]
> [true false true true false true]
> [{2 true} {3 false} {5 true} {7 true} {11 false} {13 true}]
```

スライスするとき、Goの既定値を使用することで、上限や下限の記述を省略することができる。  
既定値は下限が0、上限はスライスの長さ。  

以下の配列は、
```go
var a[10]int
```

これらのスライス式と等価である。
```go
a[0:10]
a[:10]
a[0:]
a[:]
```

スライスは、長さ(length)と要領(capacity)の両方を持っている。  
長さは、スライスされた時の要素数のこと。  
容量は、元の配列の要素数のこと。  

```go
func main() {
	s := []int{2, 3, 5, 7, 11, 13}
	printSlice(s)

	// Slice the slice to give it zero length.
	s = s[:0]
	printSlice(s)

	// Extend its length.
	s = s[:4]
	printSlice(s)

	// Drop its first two values.
	s = s[2:]
	printSlice(s)
}

func printSlice(s []int) {
	fmt.Printf("len=%d cap=%d %v\n", len(s), cap(s), s)
}

> len=6 cap=6 [2 3 5 7 11 13]
> len=0 cap=6 []
> len=4 cap=6 [2 3 5 7]
> len=2 cap=4 [5 7]
```

スライスのゼロ値は`nil`  
`nil`スライスは0の長さと容量をもっており、元となる配列は持っていない。

```go
func main() {
	var s []int
	fmt.Println(s, len(s), cap(s))
	if s == nil {
		fmt.Println("nil!")
	}
}

> [] 0 0
> nil!
```

スライスは組み込み関数`make`を使用して作成することができ、この方法は動的サイズの配列を作成する方法でもある。  

`make`関数はゼロかされた配列を割り当てて、その配列を指すスライスを返す。

```go
a := make([]int, 5) // len(a)=5
```

`make`の3番目の引数に。スライスの容量を指定することができる。

```go
b := make([]int, 0, 5) // len(b)=0, cap(b)=5

b = b[:cap(b)]  // len(b)=5, cap(b)=5
b = b[1:]       // len(b)=4, cap(b)=4
```

スライスには、他のスライスを含む任意の型を含ませることができる。

```go
ss := [][]int{
  []int{1, 2, 3},
  []int{4, 5, 6},
  []int{7, 8, 9},
}

for i := 0; i < len(ss); i++ {
  fmt.Printlen(ss[i])
}

> [1 2 3]
> [4 5 6]
> [7 8 9]

```

スライスに新しい要素を追加するには、組み込み関数の `append` を使用する。  

使い方:   
> append(追加元のスライス, 追加する変数群)

戻り値は追加元のスライスに追加する変数群が合わさったスライス。  
もし追加元のスライスが、追加する際に容量が小さい場合は、大きいサイズを割り当てしなおす。

```go
func main() {
	var s []int
	printSlice(s)

	// append works on nil slices.
	s = append(s, 0)
	printSlice(s)

	// The slice grows as needed.
	s = append(s, 1)
	printSlice(s)

	// We can add more than one element at a time.
	s = append(s, 2, 3, 4)
	printSlice(s)
}

func printSlice(s []int) {
	fmt.Printf("len=%d cap=%d %v\n", len(s), cap(s), s)
}

> len=0 cap=0 []
> len=1 cap=1 [0]
> len=2 cap=2 [0 1]
> len=5 cap=6 [0 1 2 3 4]

```
## Range
`for` ループに利用する `range` は、スライスやマップ(`map`)をひとつずつ反復処理するのに使用する。
スライスをrangeで繰り返す場合、rangeは反復毎にインデックスと、インデックス場所の要素（値）のコピーを返す。

```go
var pow = []int{1, 2, 4, 8, 16, 32, 64, 128}

func main() {
	for i, v := range pow {
		fmt.Printf("2**%d = %d\n", i, v)
	}
}

> 2**0 = 1
> 2**1 = 2
> 2**2 = 4
> 2**3 = 8
> 2**4 = 16
> 2**5 = 32
> 2**6 = 64
> 2**7 = 128
```

Pythonにおけるenumerate()に近い。  
インデックスはや値は、`_` へ代入することで捨てることができる。

```go
for i, _ := range pow
for _, value := range pow
```

インデックスだけ必要な場合は、二つ目の値を省略することができる。

```go
for i := range pow
```

## 練習
ネストした配列を作成する関数を作ってみる。

```go 
func f(x, y int) [][]int {
	s := make([][]int ,x)			// 長さxのスライスsを作成
	for i, _ := range s {			// sの長さだけforを回し、インデックスだけ利用する
		s[i] = make([]int, y)		// s[i] に 長さyのスライスを作成して格納
		for j := range s[i] {		// s[i]の長さ（つまりy）だけforを回し、インデックスだけ利用する。iの時のfor文と同じだが学習のため省略形で書いてみた。
			s[i][j] = i+j			// s[i][j] に 適当に値を入れてみる、とりあえずi+jとか。
		}
	}
	return s
}

func main() {
	fmt.Println(f(1,2))
	fmt.Println(f(2,3))
	fmt.Println(f(3,4))
	fmt.Println(f(4,4))
}

> [[0 1]]
> [[0 1 2] [1 2 3]]
> [[0 1 2 3] [1 2 3 4] [2 3 4 5]]
> [[0 1 2 3] [1 2 3 4] [2 3 4 5] [3 4 5 6]]
```


## Maps | マップ
`map`は、キーと値を関連付ける。
マップのゼロ値は`nil`。`nil`マップはキーを持っておらず、キーを追加することもできない。
`make`関数で、指定された型のマップを初期化して使用可能な状態で返すことができる。

```go
type Vertex struct {
	Lat, Long, float64
}

var m map[string] Vertex

func main() {
	m = make(map[string] Vertex)
	m["Bell Labs"] = Vertex {
		40.68433, -74.39967
	}
	fmt.Println(m["Bell Labs"])
}

> {40.68433 -74.39967}
```

mapの値を呼び出したいときは、関連付くキーを指定する。

```go
var m = map[string]Vertex{
	"Bell Labs": Vertex{
		40.68433, -74.39967,
	},
	"Google": Vertex{
		37.42202, -122.08408,
	},
}


func main() {
	fmt.Println(m["Google"])
}

> {37.42202 -122.08408}
```

トップレベルの型が単純な型名の場合は、リテラルの要素から推測できるため、型名を省略することができる。

```go
type Vertex struct {
	Lat, Long float64
}

var m = map[string]Vertex{
	"Bell Labs": {40.68433, -74.39967},
	"Google":    {37.42202, -122.08408},
}

func main() {
	fmt.Println(m)
}
```

map要素の挿入や更新:

```go
m[key] = elem
```

要素の取得

```go
elem = m[key]
```

要素の削除

```go
delete(m, key)
```

キーに対する要素が存在するか確認
```go
elem, ok := m[key]

if ok {
	fmt.Println("True")
} else {
	fmt.Println("False")
}
```
もし、キーが存在しない場合、elmはmapの要素の型のゼロ値となる。


```go
func main() {
	m := make(map[string]int)

	m["Answer"] = 42
	fmt.Println("The value:", m["Answer"])

	m["Answer"] = 48
	fmt.Println("The value:", m["Answer"])

	delete(m, "Answer")
	fmt.Println("The value:", m["Answer"])

	v, ok := m["Answer"]
	fmt.Println("The value:", v, "Present?", ok)
	
	if ok {
		fmt.Println("True")
	} else {
		fmt.Println("False")
	}
}

> The value: 42
> The value: 48
> The value: 0
> The value: 0 Present? false
> False
```

### 練習
スペースで区切られた単語の出現回数をカウントする関数を作成する

```go
package main

import (
	"golang.org/x/tour/wc"
	"strings"
)

func WordCount(s string) map[string]int {
	ss := strings.Fields(s)
	m := make(map[string]int)
	
	for _, word := range ss {
		_, ok := m[word] 
		if ok {
			m[word] += 1
		} else {
			m[word] = 1
		}
	}
	
	return m
}

func main() {
	wc.Test(WordCount)
}

> PASS
>  f("I am learning Go!") = 
>   map[string]int{"Go!":1, "I":1, "am":1, "learning":1}
> PASS
>  f("The quick brown fox jumped over the lazy dog.") = 
>   map[string]int{"The":1, "brown":1, "dog.":1, "fox":1, "jumped":1, "lazy":1, "over":1, "quick":1, "the":1}
> PASS
>  f("I ate a donut. Then I ate another donut.") = 
>   map[string]int{"I":2, "Then":1, "a":1, "another":1, "ate":2, "donut.":2}
> PASS
>  f("A man a plan a canal panama.") = 
>   map[string]int{"A":1, "a":2, "canal":1, "man":1, "panama.":1, "plan":1}
```

## Function values | 関数値
関数も変数として扱える。他の変数と同様に関数を渡すことができる。

```go
import (
	"fmt"
	"math"
)

func compute(fn func(float64, float64) float64) float64 {
	return fn(3, 4)
}

func main() {
	hypot := func(x, y float64) float64 {
		return math.Sqrt(x*x + y*y)
	}
	fmt.Println(hypot(5, 12))

	fmt.Println(compute(hypot))
	fmt.Println(compute(math.Pow))
}

> 13
> 5
> 81
```

Goの関数はクロージャの性質を持つ。関数の外側にある変数を参照することができる。  
JSやPythonでも同様のことができるし、同じ性質だと考えてよさそう。  

以下の例は、adder関数はクロージャを返している。戻り値の関数から見て外側にある変数sumを操作できているのがポイント。  
クロージャの中でも同名の変数がバインドされていることが分かる。  

```go
func adder() func(int) int {
	sum := 0
	return func(x int) int {
		sum += x
		return sum
	}
}

func main() {
	pos, neg := adder(), adder()
	for i := 0; i < 10; i++ {
		fmt.Println(
			pos(i),
			neg(-2*i),
		)
	}
}

> 0 0
> 1 -2
> 3 -6
> 6 -12
> 10 -20
> 15 -30
> 21 -42
> 28 -56
> 36 -72
> 45 -90

```

## Methods | メソッド
Goには、クラス(class)の仕組みがない（！）が、型にメソッドを定義することはできる。  
メソッドは、レシーバ引数を関数に取る。  言い方を変えるとレシーバと呼ばれる引数を伴う関数。  
レシーバは、`func`とメソッド名の間に引数リストで表現される。  

この例では、`Abs`メソッドは`v`という名前の`Vertex`型レシーバを持つことを意味する。

```go
type Vertex struct {
	X, Y float64
}

func (v Vertex) Abs() float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}

func main() {
	v := Vertex{3, 4}
	fmt.Println(v.Abs())
}

> 5
```

structだけでなく、任意の型にもメソッドを宣言できる。

例として、`Abs`メソッドをもつ数値型の`MyFloat`型

```go
type MyFloat float64

func (f MyFloat) Abs() float64 {
	if f < 0 {
		return float64(-f)
	}
	return float64(f)
}

func main() {
	f := MyFloat( -math.Sqrt2)
	fmt.Plentln(f.Abs())
}
```

レシーバを伴うメソッドの宣言は、レシーバ型が同じパッケージにある必要がある。  
他のパッケージに定義している型に対して、レシーバを伴うメソッドを宣言することはできない。  

ポインタのレシーバでメソッドを宣言することもできる。  
レシーバの型が、ある型`T`への構文`*T`があることを意味する。  

例として、`*Vertex`に`Scale`メソッドを定義する。
ポインタレシーバをもつメソッド（ここでは`Scale`)は、レシーバが指す変数を変更することができる。レシーバ自身を更新することが多いため、変数レシーバよりもポインタレシーバの方が一般的。  

変数レシーバは、元の`Vertex`変数のコピーを操作する。  
main関数で宣言した`Vertex`変数を変更するなら、`Scale`メソッドはポインタレシーバにする必要がある。

```go
type Vertex struct {
	X, Y float64
}

func (v Vertex) Abs() float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}

func (v *Vertex) Scale(f float64) {
	v.X = v.X * f
	v.Y = v.Y * f
}

func main() {
	v := Vertex{3, 4}
	v.Scale(10)
	fmt.Println(v.Abs())
}

> 50
```

```go
type Vertex struct {
	X, Y float64
}

func (v Vertex) Abs() float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}

func (v Vertex) Scale(f float64) {
	v.X = v.X * f
	v.Y = v.Y * f
}

func main() {
	v := Vertex{3, 4}
	v.Scale(10)
	fmt.Println(v.Abs())
}


> 5
```

ポインタレシーバを使う理由は2つ。  
一つ目は、メソッドがレシーバが指す変数を操作するため。  
二つ目は、メソッドの呼び出し毎に変数のコピーを避けるため。  例えばレシーバが大きな構造体である場合などに便利。
一般的には、レシーバは変数レシーバもしくはポインタレシーバのどちらかで統一させるべきで、混在させないほうが望ましい。  


## Interfaces | インターフェース
インターフェース型は、メソッドの集まりで定義される。

型にメソッドを実装していくことは、すなわちインターフェースを実装しているので、明示的に宣言しなくてもよい。(一つのメソッドだけだったらという意味かな)  

```go
type I interface {
	M()
}

type T struct {
	S string
}

// This method means type T implements the interface I,
// but we don't need to explicitly declare that it does so.
func (t T) M() {
	fmt.Println(t.S)
}

func main() {
	var i I = T{"hello"}
	i.M()
}
```

インターフェースの値は、値と具体的な型のタプルのように考えられる。

```
(value, type)
```

インターフェースの値は、特定の基底になる具体的な型の値を保持し、インターフェースの値のメソッドを呼び出すとその基底型の同じ名前のメソッドが実行される。

```go
type I interface {
	M()
}

type T struct {
	S string
}

func (t *T) M() {
	fmt.Println(t.S)
}

type F float64

func (f F) M() {
	fmt.Println(f)
}

func main() {
	var i I

	i = &T{"Hello"}
	describe(i)
	i.M()

	i = F(math.Pi)
	describe(i)
	i.M()
}

func describe(i I) {
	fmt.Printf("(%v, %T)\n", i, i)
}

> (&{Hello}, *main.T)
> Hello
> (3.141592653589793, main.F)
> 3.141592653589793
```

インターフェースの中にある値がnilの場合、メソッドのレシーバもnilとして呼び出される。
Goではnilをレシーバーとして呼び出されてもnullポインターの例外を出さずに適切に処理してくれる。

```go
type I interface {
	M()
}

type T struct {
	S string
}

func (t *T) M() {
	if t == nil {
		fmt.Println("<nil>")
		return
	}
	fmt.Println(t.S)
}

func main() {
	var i I

	var t *T
	i = t
	describe(i)
	i.M()

	i = &T{"hello"}
	describe(i)
	i.M()
}

func describe(i I) {
	fmt.Printf("(%v, %T)\n", i, i)
}

> (<nil>, *main.T)
> <nil>
> (&{hello}, *main.T)
> hello
```

nilインターフェースの値は、値も具体的な型も保持しない。  
呼び出すメソッドの示す型がインターフェースのタプル内に存在しないので、 nilインターフェースのメソッドを呼び出すと、ランタイムエラーを引き起こす。

```go
type I interface {
	M()
}

func main() {
	var i I
	describe(i)
	i.M()
}

func describe(i I) {
	fmt.Printf("(%v, %T)\n", i, i)
}

> (<nil>, <nil>)
> panic: runtime error: invalid memory address or nil pointer dereference
> [signal SIGSEGV: segmentation violation code=0x1 addr=0x0 pc=0x482161]
> 
> goroutine 1 [running]:
> main.main()
> 	/tmp/sandbox539928408/prog.go:12 +0x61
```

ゼロ個のメソッドを指定されたインターフェース型(メソッドを持たないインタフェース)は、 空のインターフェースと呼ばれる。

```go
interface{}
```

空のインターフェースは、任意の型の値を保持することができ、未知の型の値を扱うコードで使用される。  
例えば、 fmt.Print は interface{} 型の任意の数の引数を受け取る。

```go
func main() {
	var i interface{}
	describe(i)

	i = 42
	describe(i)

	i = "hello"
	describe(i)
}

func describe(i interface{}) {
	fmt.Printf("(%v, %T)\n", i, i)
}

> (<nil>, <nil>)
> (42, int)
> (hello, string)
```

## Type assertions | 型アサーション
型アサーションは、インターフェースの値のもととなる値や型を伝える手段を提供する。

この例では、インターフェースの値`i`が、具体的な型`T`を保持し、もとになる`T`の値を変数`t`に代入することを伝えている。

```go
t  := i.(T)
```

`i` が`T`を保持していない場合、panicを引き起こす。  
Pythonのアサーションと違って、 アサーションの通りに実装しなければならない…と解釈。


型アサーションは2つの値(もとになる値とアサーションが成功したかどうかを報告するbool値)を返すので、インターフェースの値が特定の型を保持しているかどうかをテストを行うことができる。  

```go
t, ok := i.(T)
```

`i`が`T`を保持していれば、`t`はもとになる値になり、`ok`はtrueになる。
異なる場合、`ok`はfalse、`t`は型`T`のゼロ値になる。panicは起きない。

```go
func main() {
	var i interface{} = "hello"

	s := i.(string)
	fmt.Println(s)

	s, ok := i.(string)
	fmt.Println(s, ok)

	f, ok := i.(float64) // panicは起きない
	fmt.Println(f, ok)

	f = i.(float64) // panic
	fmt.Println(f)
}

> hello
> hello true
> 0 false
> panic: interface conversion: interface {} is string, not float64
> 
> goroutine 1 [running]:
> main.main()
```

## Type Switches | 型Switch
型switchは、複数の型アサーションを直列に使用できる構造のこと。

型switchはswitch文と似ているが、型switchのcaseは型を指定し、指定れたインタフェースの値が保持する値の型と比較される。  

```go
switch v := i.(type) {
	case T:
		// here v has type T
	case S:
		// here v has type S
	default:
		// no match; here v has the same type as i
}
```
型switchの宣言は、型アサーション`i.(T)`と同じ構文ではあるが、特定の型`T`部分は、`type`に置き換えられる。

このswitch文は、インタフェースの値の方が`T`なのか`S`なのかをテストする。各caseにおいて変数`v`はそれぞれの型`T`もしくは`S`として扱われる。  
defaultの場合は、変数`v`は同じインタフェース型で値は`i`となる。

```go
func do(i interface{}) {
	switch v := i.(type) {
	case int:
		fmt.Printf("Twice %v is %v\n", v, v*2)
	case string:
		fmt.Printf("%q is %v bytes long\n", v, len(v))
	default:
		fmt.Printf("I don't know about type %T!\n", v)
	}
}

func main() {
	do(21)
	do("hello")
	do(true)
}

> Twice 21 is 42
> "hello" is 5 bytes long
> I don't know about type bool!
```

もっともよく使われているinterfaceの一つに`fmt`パッケージに定義されている`Stringer`がある。
```go
type Stringer interface {
    String() string
}
```

`Stringer`インタフェースは、`string`として表現することができる型。
`fmt`パッケージや多くのパッケージでは、変数を文字列で出力するためにこのインタフェースがあることを確認している。

```go
type Person struct {
	Name string
	Age  int
}

func (p Person) String() string {
	return fmt.Sprintf("%v (%v years)", p.Name, p.Age)
}

func main() {
	a := Person{"Arthur Dent", 42}
	z := Person{"Zaphod Beeblebrox", 9001}
	fmt.Println(a, z)
}

> Arthur Dent (42 years) Zaphod Beeblebrox (9001 years)
```

### 練習
IPAddr型のfmt.Stringerインタフェースの実装練習。

```go
type IPAddr [4]byte

// TODO: Add a "String() string" method to IPAddr.
func (ip IPAddr) String() string {
	return fmt.Sprintf("%v.%v.%v.%v", ip[0], ip[1], ip[2], ip[3])
}


func main() {
	hosts := map[string]IPAddr{
		"loopback":  {127, 0, 0, 1},
		"googleDNS": {8, 8, 8, 8},
	}
	for name, ip := range hosts {
		fmt.Printf("%v: %v\n", name, ip)
	}
}

> loopback: 127.0.0.1
> googleDNS: 8.8.8.8
```

## Errors | エラー
Goのプログラムは、エラーの常態を`error`値で表現する。

`error`型は、`fmt`.`Stringer`に似た組み込みのインターフェース。

```go
type error interface {
	Error() string
}
```

関数は`error`変数を返し、呼び出し元はエラーが`nil`かどうかを確認することでエラーハンドリングすることができる。

```go
i, err := strconv.atoi("42")
if err != nil {
	fmt.Printf("couldn't convert number: %v\n", err)
	return
}
fmt.Println("Converted integer:", i)
```

nilの`error`は成功したことを示し、nilではない`error`は失敗を示す。

```go
package main

import (
	"fmt"
	"time"
)

type MyError struct {
	When time.Time
	What string
}

func (e *MyError) Error() string {
	return fmt.Sprintf("at %v, %s",
		e.When, e.What)
}

func run() error {
	return &MyError{
		time.Now(),
		"it didn't work",
	}
}

func main() {
	if err := run(); err != nil {
		fmt.Println(err)
	}
}

> at 2009-11-10 23:00:00 +0000 UTC m=+0.000000001, it didn't work
```

### 練習
前回の練習で実装したSqrt関数に負の数が渡されたときの例外処理を実装するもの。

```go
type ErrNegativeSqrt float64

func (e ErrNegativeSqrt) Error() string {
	return fmt.Sprintf("cannot Sqrt negative number: %v", float64(e))
}

func Sqrt(x float64) (float64, error) {
	if x < 0 {
		return 0, ErrNegativeSqrt(x)
	}
	
	z := 1.0
	for i := 0; i < 10; i++ {
	z -= (z * z - x ) / (2 * z)
	}
	return z, nil
}

func main() {
	fmt.Println(Sqrt(2))
	fmt.Println(Sqrt(-2))
}
```

## Readers練習

```go 
package main

import (
	"golang.org/x/tour/reader"
)

type MyReader struct{}

// TODO: Add a Read([]byte) (int, error) method to MyReader.
func (r MyReader) Read(b []byte) (int, error) {
	var i int = 0
	var e error = nil
	
	for ;i < len(b); i++ {
		b[i] = 'A'
	}
	return i, e
}

func main() {
	reader.Validate(MyReader{})
}
````
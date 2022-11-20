# Create-go-module

# モジュールの準備
## greetingsモジュールの作成

モジュールのディレクトリ作成
```bash
cd ./greetingsGo
```

go mod initコマンドを使用して新しいモジュールの作成を行う。  

```bash
$ go mod init example.com/greetings
go: creating new go.mod: module example.com/greetings
```

実行すると`go.mod`ファイルが作成される。  
このファイルはコードの依存関係を管理するファイルとのこと。  

```bash
$ cat go.mod
module example.com/greetings

go 1.19
```

`greetings.go`ファイルを作ってコードを書いていく。  

```go:greetings.go
package greetings

import "fmt"

func Hello(name string) string {
	message := fmt.Sprintf("Hi, %v, Welcome!", name)
	return message
}
```

## helloモジュールの作成

次に呼び出す側のモジュールを作成する。

```bash
$ cd ../ #greetingsGoディレクトリにいる場合
$ mkdir helloGo
$ ls
greetingsGo helloGo

$ cd helloGo
```

先ほどと同様にモジュールを作るための初期化を行う。

```bash
$  go mod init example.com/hello
go: creating new go.mod: module example.com/hello
```

`hello.go`を作ってコードを書いてく。

```go:hello.go
package main

import (
    "fmt"
    "example.com/greetings" 
)

func main() {
    message :=greetings.Hello("Gladys")
    fmt.Println(message)
}
```

先ほど作成した`example.com/greetings`と`fmt`パッケージをインポートしている。  
このインポートで、コードは別のパッケージ内で定義された関数にアクセスすることができるようになる。`greetings.go`には`Hello`関数を定義しているので、`helloGo.go`側で呼びだせるようになる。

## モジュールの参照先をローカルに変える
本番環境であれば、Goが、モジュールを見つけるために公開されたモジュールから該当のモジュールを見つけてくれるが、今回は練習なのでローカルを参照するように調整する必要がある。

helloGoディレクトリで、`go mod edit`コマンドを使用してローカルディレクトリにリダイレクトするように変更する。

```bash
$ go mod edit -replace example.com/greetings=../greetingsGo
$ cat go.mod
module example.com/hello

go 1.19

replace example.com/greetings => ../greetingsGo
```

`--replace`じゃなくて、`-replace`なのは気になる・・・。  

次に`go mod tidy`コマンドでソースコードとgo.modに記載されているパッケージの整合性をチェックする。

```bash
$ go mod tidy
go: found example.com/greetings in example.com/greetings v0.0.0-00010101000000-000000000000
```

コマンドを実行してみる
```bash
$ go run .
Hi, Gladys, Welcome!
```

ちゃんとhello.goが実行されたことが確認できる。

# エラー処理を実装する
名前が空の場合、呼び出し元にエラーを返す処理を実装する。  
`greetings.go`を以下のように変更する。

```go:greetings.go
package greetings

import (
	"errors"
	"fmt"
)

func Hello(name string) (string, error) {
	if name == "" {
		return "", errors.New("empty name")
	}

	message := fmt.Sprintf("Hi, %v, Welcome!", name)
	return message, nil
}
```

エラーを返すように戻り値を(string, error)に変更。それに合わせて、正常処理の場合も、メッセージとエラー(正常なのでゼロ値のnil)を返すように変更。   
標準ライブラリの`errors`パッケージをインポート。  

次に`hello.go`を以下のように変更する。

```go:hello.go
package main

import (
	"fmt"
	"log"

	"example.com/greetings"
)

func main() {
	log.SetPrefix("greetings: ")
	log.SetFlags(0)

	message, err := greetings.Hello("")
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(message)
}

```

`log`パッケージを使用してログを出力するようにする。  
Hello関数の戻り値に対応するように、メッセージとエラー変数を割り当てる。  
エラー時の処理を確認したいので空の文字列を送る。  
エラーが発生した場合は、`log`パッケージのFatal関数を使用して、エラーを出力、プログラムを停止させる。  

`hello.go`を実行して確認してみる。

```bash
$ go run .
greetings: empty name
exit status 1
```

# ランダムな挨拶を返すようにする
3つの挨拶を用意したスライスを作成しておき、コードはこのうちの一つをランダムで返すように実装する。

`greetings.go`を以下のように変更する。
```go:greetings.go
package greetings

import (
	"errors"
	"fmt"
	"math/rand"
	"time"
)

func Hello(name string) (string, error) {
	if name == "" {
		return name, errors.New("empty name")
	}

	message := fmt.Sprintf(randomFormat(), name)
	return message, nil
}

func init() {
	rand.Seed(time.Now().UnixNano())
}
func randomFormat() string {
	formats := []string{
		"Hi, %v. Welcome!",
		"Great to see you, %v!",
		"Hail, %v! Well met!",
	}
	return formats[rand.Intn(len(formats))]
}

```

挨拶メッセージを返す関数`randomFormat`関数を実装する。  
randomFormat関数の最初の文字が小文字で始まっていることに注意。これによって、このパッケージのコード内でのみアクセスができる関数となる。（エクスポートされることがない）  
3つのメッセージをもつスライスを宣言する。  
`math/rand`パッケージを使用して、スライスからアイテムを選択するための乱数を生成している。  
現在の時刻をシードとする`init`関数を実装する。Goはグローバル変数が初期化された後、プログラムの起動時に`init`関数を自動的に実行する。  

今の`hello.go`は空の文字列を送って必ずエラーになってしまうため、文字列を入れて処理を通すように変更する。  

```go:hello.go
package main

import (
	"fmt"
	"log"

	"example.com/greetings"
)

func main() {
	log.SetPrefix("greetings: ")
	log.SetFlags(0)

	message, err := greetings.Hello("Gladys")
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(message)
}
```

何回か実行してランダムな挨拶が返ってくるか確認する。

```bash
$ go run .
Hi, Gladys. Welcome!

$ go run .
Hail, Gladys! Well met!

$ go run .
Great to see you, Gladys!
```

# 複数人に挨拶を返すようにする
一度の実行で、複数の人の挨拶を取得できるように実装する。  
チュートリアルでは、別の名前で新しい関数を作成することを進めているので、それに従う。
新しい関数`Hellos`は複数のパラメーターを受け取るようにしている。

```go:greetings.go
package greetings

import (
	"errors"
	"fmt"
	"math/rand"
	"time"
)

func Hello(name string) (string, error) {
	if name == "" {
		return name, errors.New("empty name")
	}

	message := fmt.Sprintf(randomFormat(), name)
	return message, nil
}

// Hellos関数だけ追加
func Hellos(names []string) (map[string]string, error) {
	messages := make(map[string]string)
	for _, name := range names {
		message, err := Hello(name)
		if err != nil {
			return nil, err
		}
		messages[name] = message
	}
	return messages, nil
}

func init() {
	rand.Seed(time.Now().UnixNano())
}

func randomFormat() string {
	formats := []string{
		"Hi, %v. Welcome!",
		"Great to see you, %v!",
		"Hail, %v! Well met!",
	}
	return formats[rand.Intn(len(formats))]
}

```

Hellosパラメータは複数の名前を受け取りたいので、string型のスライスを引数に持つ。  
戻り値も、それぞれの人名に対して、挨拶文を返すようにしたいため、名前をキーに、挨拶を値に割り当てられたMapを戻り値に設定する。  
Hellos関数の戻り値要に messages変数をまずmake関数を使って初期化。  
渡された名前のスライスをrangeを使って順次処理を行い、Hello関数に渡す。  
range関数を使うと、(インデックス、値)の形で複数戻り値が返ってくる。今回はインデックスは不要なので、使わない時の記述アンダースコアを使用。  
messagesにキーは名前、値は挨拶文を格納している。  


`hello.go`も複数の名前をスライスで渡せるように変更する。

```go:hello.go
package main

import (
	"fmt"
	"log"

	"example.com/greetings"
)

func main() {
	log.SetPrefix("greetings: ")
	log.SetFlags(0)

	names := []string{"Gladys", "Samantha", "Darrin"}

	messages, err := greetings.Hellos(names)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(messages)
}
```

複数の名前を持つstring型のスライスを変数namesとして作成。  
names変数を引数として関数Hellosに渡す。  

`hello.go`を実行。messagesがmapなので、Printlnしたときにmapの形式で出力されている。

```bash
$ go run .
map[Darrin:Great to see you, Darrin! Gladys:Great to see you, Gladys! Samantha:Hail, Samantha! Well met!]
```

# テストを追加する
Goの`testing`パッケージを使用して、単体テストを行う。

greetingsディレクトリに`greetings_test.go`ファイルを作成する。
ファイル名の最後に`_test.go`を付けると、`go test`コマンドで、自動的にテスト関数が含まれている場合に単体テストを行ってくれる。

```go:greetings_test.go
package greetings

import (
	"regexp"
	"testing"
)

func TestHelloName(t *testing.T) {
	name := "Gladys"
	want := regexp.MustCompile(`\b` + name + `\b`)
	msg, err := Hello("Gladys")
	if !want.MatchString(msg) || err != nil {
		t.Fatalf(`Hello("Gladys") = %q, %v, want match %#q, nil`, msg, err, want)
	}
}
func TestHelloEmpty(t *testing.T) {
	msg, err := Hello("")
	if msg != "" || err == nil {
		t.Fatalf(`Hello("") = %q, %v, want "", error`, msg, err)
	}
}
```

テストするコードと同じパッケージにテスト関数を実装する。  
関数をテストする2つのテスト関数を実装。  テスト関数の名前の形式は、`Test`を接頭辞にして、次にテストする特定の関数名とする。(Test+Hello => TestHello)  
テスト関数は、`testing.T`のポインターをパラメータとして受け取る。このパラメータのメソッドを使用して、テストのレポートやログ記録を行う。  

TestHelloName関数は、有効なメッセージを渡したときのテストを行っている。  
TestHelloEmpty関数は、空の文字列、つまりエラー処理が機能するかどうかテストする。  

greetingsGoのディレクトリで、`go test`を実行してテストしてみる。
`-v`オプションでテストの一覧とその結果を出力できる。  

```bash
$ go test
PASS
ok      example.com/greetings   0.003s

$ go test -v
=== RUN   TestHelloName
--- PASS: TestHelloName (0.00s)
=== RUN   TestHelloEmpty
--- PASS: TestHelloEmpty (0.00s)
PASS
ok      example.com/greetings   0.003s
```

あえて単体テストが失敗するようにgreetingsの処理を以下のように変更する。

```diff go:greetings.go
+ message := fmt.Sprint(randomFormat())
- message := fmt.Sprintf(randomFormat(), name)
```

テストを実行する。

```bash
$ go test
--- FAIL: TestHelloName (0.00s)
    greetings_test.go:13: Hello("Gladys") = "Hail, %!v(MISSING)! Well met!", <nil>, want match `\bGladys\b`, nil
FAIL
exit status 1
FAIL    example.com/greetings   0.003s

$ go test -v                                                                ✘ 1 
=== RUN   TestHelloName
    greetings_test.go:13: Hello("Gladys") = "Hail, %!v(MISSING)! Well met!", <nil>, want match `\bGladys\b`, nil
--- FAIL: TestHelloName (0.00s)
=== RUN   TestHelloEmpty
--- PASS: TestHelloEmpty (0.00s)
FAIL
exit status 1
FAIL    example.com/greetings   0.003s
```

テストが失敗したことが分かった。
`-v`オプションを付けることで、各テストの結果が分かる。TestHelloRmptyはPASSしているがTestHelloNameはFAILしているために、失敗の判定になった。  

# アプリケーションをコンパイルする
helloGoディレクトリで`go build`を実行して、コードをコンパイルする。

```bash
$ go build
```

コンパイルされ実行可能なファイル`hello`が出来上がっているのを確認する。

```bash
$ ls
go.mod  hello  hello.go
$ ./hello
map[Darrin:Hi, %!v(MISSING). Welcome! Gladys:Hi, %!v(MISSING). Welcome! Samantha:Great to see you, %!v(MISSING)!]
```

出力がおかしい。そういえば、エラー処理の時に意図的にエラーにしていたのを忘れていたので、修正する。

```diff go:greetings.go
+ message := fmt.Sprintf(randomFormat(), name)
- message := fmt.Sprint(randomFormat())
```

一応テストして、PASSするか確認する。

```bash
$ go test
PASS
ok      example.com/greetings   0.002s
```

再度コンパイルする

```bash 
$ go build
$ ./hello
map[Darrin:Hail, Darrin! Well met! Gladys:Great to see you, Gladys! Samantha:Hi, Samantha. Welcome!]
```

今度は問題なく実行できた。
この`hello`アプリケーションがあるディレクトリは環境変数PATHにセットされていない。そのため、別のディレクトリに移動すると実行できない。

```bash
$ cd ../
$ ./hello
zsh: no such file or directory: ./hello
```

もう一度helloGoディレクトリに戻り、実行可能ファイルの場所を確認する。  
インストールパスを検出するコマンドがgoコマンドにあるようなので、それ実行して確認する。

```bash
$ go list -f '{{.Target}}'
/home/red/go/bin/hello
```

Linux(Ubuntsu)なので`export`コマンドで環境変数設定。

```bash
export PATH="$PATH:$(dirname $(go list -f '{{.Target}}'))"
```

これでどこからでもhelloコマンドが打てるようになる。

```bash
$ cd ~/
$ hello
map[Darrin:Hi, Darrin. Welcome! Gladys:Hail, Gladys! Well met! Samantha:Hi, Samantha. Welcome!]
```

`export`コマンドでPATHを通しただけなので、ターミナルを落とすと再度`export`コマンドを実行しなければならない。  
永続化したい人は、`.bash_profile`とかに追記すると良い。

これで、モジュール作成のチュートリアルは終了。
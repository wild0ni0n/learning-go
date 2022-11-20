# モジュールの作成
`workspace`という名前でディレクトリを作成

```bash
$ mkdir workspace
$ cd workspace
```

モジュールの初期化。
```bash
$ mkdir hello
$ cd hello
$ go mod init example.com/hello
go: creating new go.mod: module example.com/hello
```

`go get`コマンドを使用して、`golang.org/x/example`モジュールの依存関係を追加する。

```bash
$ cat go.mod
module example.com/hello

go 1.19

$ go get golang.org/x/example
go: downloading golang.org/x/example v0.0.0-20220412213650-2e68773dfca0
go: added golang.org/x/example v0.0.0-20220412213650-2e68773dfca0

$ ls
go.mod  go.sum

$ cat go.mod
module example.com/hello

go 1.19

require golang.org/x/example v0.0.0-20220412213650-2e68773dfca0 // indirect

$ cat go.sum
github.com/yuin/goldmark v1.2.1/go.mod h1:3hX8gzYuyVAZsxl0MRgGTJEmQBFcNTphYh9decYSb74=
golang.org/x/crypto v0.0.0-20190308221718-c2843e01d9a2/go.mod h1:djNgcEr1/C05ACkg1iLfiJU5Ep61QUkGW8qpdssI0+w=
# 長いため割愛
```

`hello.go`を作成する。

```go:hello.go
package main

import (
	"fmt"
	"golang.org/x/example/stringutil"
)

func main() {
	fmt.Println(stringutil.Reverse("Hello"))
}
```

プログラムを実行する

```bash
$ go run example.com/hello
olleH
```

# ワークスペースを作成する
モジュールでワークスペースを指定するために`go.work`ファイルを作成する。

workspaceディレクトリで、次のコマンドを実行する。

```bash
$ go work init ./hello
```

`go work init`コマンドは、`./hello`ディレクトリ内のモジュールを含むワークスペース用の`go.work`ファイルを作成する。
これによって、`go.work`ファイルが生成される。

```bash
$ cat go.work
go 1.19

use ./hello
```
`go`ディレクティブは、Goのバージョンを示す。ディレクティブは`go.mod`と同じ。
`use`ディレクティブは、ビルド時に`hello`ディレクトリ内のモジュールがメインモジュールであることをGoに伝えている。

workspaceディレクトリでコマンドを実行する

```bash
$ go run example.com/hello
olleH
```

モジュールの外だが、helloプログラムが実行できていることが確認できた。
Goコマンドには、ワークスぺースないの全てのモジュールがメインモジュールとして含まれるので、モジュールの外であっても、モジュール内のパッケージを参照して実行することができる。
ワークスペースの外でコマンドを実行すると、コマンドが使用するモジュールを認識できなくなるため、エラーが発生する。

# golang.org/x/exampleモジュールをダウンロードして変更する
モジュールのGitリポジトリのコピーをダウンロードし、golang.org/x/exampleをワークスペースに追加して、新しい関数を追加する。

まずはじめにリポジトリをクローンする

```bash
$ git clone https://go.googlesource.com/example
Cloning into 'example'...
remote: Total 204 (delta 93), reused 204 (delta 93)
Receiving objects: 100% (204/204), 103.24 KiB | 121.00 KiB/s, done.
Resolving deltas: 100% (93/93), done.
```

モジュールをワークスペースに追加する

```bash
$ go work use ./example
```

このコマンドは、新しいモジュールを`go.work`ファイルに追加するもの。

```bash
$ cat go.work
go 1.19

use (
        ./example
        ./hello
)
```

次に新しい機能を追加する。
文字列を大文字にする新しい関数を`golang.org/x/example/stringutil`パッケージに追加する。

stringutilパッケージがあるディレクトリまで移動して、`toupper.gp`という新しいファイルを作成する。

```bash
$ cd example/stringutil
$ touch toupper.go
```

```go:toupper.go
package stringutil

import "unicode"

func ToUpper(s string) string {
	r := []rune(s)
	for i := range r {
		r[i] = unicode.ToUpper(r[i])
	}
	return string(r)
}
```
`hello`プログラム側で`ToUpper`関数を使用するように変更する。

```diff go:hello.go
-fmt.Println(stringutil.Reverse("Hello"))
+fmt.Println(stringutil.ToUpper("Hello"))
```

ワークスペースでコードを実行する

```bash
$ go run example.com/hello
HELLO
```

チュートリアルはこれで終了。
[モジュールのリリースのワークフロー](https://go.dev/doc/modules/release-workflow)が公開されているので、ちゃんとしたモジュールを開発したら、そちらを参照したほうがよい。

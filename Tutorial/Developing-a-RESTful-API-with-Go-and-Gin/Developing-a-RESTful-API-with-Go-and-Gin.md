このチュートリアルでは、GoとGin(GoのWebフレームワーク)を使用して、RESTful APIを作成する。

# API エンドポイントの設計
ビンテージレコードのレコードを販売するストアへのアクセスを提供するAPIを構築する。  
そのため、クライアントがユーザのアルバムを取得および追加できるエンドポイントを提供できるようようにする。

このチュートリアルで作成するエンドポイントは次の通り。

* `/albums`
    * GET - アルバムのリストをJSONで返す。
    * POST -JSONで送信されたリクエストデータから新しいアルバムを追加する。
* `/albums/:id`
    * GET - IDでアルバムを取得し、アルバムデータをJSONとして返す。

# 準備
## ディレクトリの準備
`web-service-gin`というディレクトリを用意して、モジュールの初期化を行う。

```bash
$ mkdir web-service-gin
$ cd web-service-gin
$ go mod init example.com/web-service-gin
go: creating new go.mod: module example.com/web-service-gin
```

## データの準備
今回はチュートリアルなのでデータはメモリ内で保存する。通常であればデータベースなどを使う。
`main.go`ファイルを作成する

```go:main.go
package main

type album struct {
	ID     string  `json:"id"`
	Title  string  `json:"title"`
	Artist string  `json:"artist"`
	Price  float64 `json:"price"`
}

var albums = []album{
	{ID: "1", Title: "Blue Train", Artist: "John Coltrane", Price: 56.99},
	{ID: "2", Title: "Jeru", Artist: "Gerry Mulligan", Price: 17.99},
	{ID: "3", Title: "Sarah Vaughan and Clifford Brown", Artist: "Sarah Vaughan", Price: 39.99},
}
```

構造体`album`を宣言し、`album`型のスライスに事前データを入れて変数`albums`に代入する。

# 全てのアイテムを返すハンドラの作成
## ロジックを考える
GET /albumsを実行したときに全てのアルバムをJSONで返すエンドポイントを実装する。

そのためには、次のような準備を行う。
* レスポンスを準備するロジックの実装
* リクエストパスをロジックにマッピングする実装

## 実装
main.goに実装していく

```go:main.go
package main

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type album struct {
	ID     string  `json:"id"`
	Title  string  `json:"title"`
	Artist string  `json:"artist"`
	Price  float64 `json:"price"`
}

var albums = []album{
	{ID: "1", Title: "Blue Train", Artist: "John Coltrane", Price: 56.99},
	{ID: "2", Title: "Jeru", Artist: "Gerry Mulligan", Price: 17.99},
	{ID: "3", Title: "Sarah Vaughan and Clifford Brown", Artist: "Sarah Vaughan", Price: 39.99},
}

func getAlbums(c *gin.Context) {
	c.IndentedJSON(http.StatusOK, albums)
}

func main() {
	router := gin.Default()
	router.GET("/albums", getAlbums)

	router.Run("localhost:8081")
}
```

`gin.Context`はリクエスト情報が格納されており、JSONを検証してシリアライズする。
Goの組み込みの`context`パッケージとは異なる。
`Context.IndentedJSON`で構造体をJSON にシリアル化し、それをレスポンスに追加する。
`http.StatusOK`は`net.http`パッケージから定数`StatusOK`を引っ張ってきて、返している。中身はHTTPのステータスコード。

main部分は、リクエストパスに関する処理。

## コードの実行
外部からGinモジュールを取得するために、まずはコード内の依存関係を取得してくる。

```bash
$ go get .
```

実行する

```bash
$ go run .
```

デバッグメッセージが表示されるが、サービスが起動して指定したポートでリッスンしたら成功。
curlでアクセスしてみる。

```bash
curl http://localhost:8081/albums
[
    {
        "id": "1",
        "title": "Blue Train",
        "artist": "John Coltrane",
        "price": 56.99
    },
    {
        "id": "2",
        "title": "Jeru",
        "artist": "Gerry Mulligan",
        "price": 17.99
    },
    {
        "id": "3",
        "title": "Sarah Vaughan and Clifford Brown",
        "artist": "Sarah Vaughan",
        "price": 39.99
    }
]
```

`/albums`エンドポイントが正しく機能していることがわかる。

# 新しいアイテムを追加するハンドラの実装
## ロジックを考える
次は、`POST /albums`でリクエストボディで渡されたアルバム情報を既存のアルバムデータに追加していく。

* 新しいアルバムを既存のリストに追加するロジック
* POSTリクエストをロジックにルーティングするための実装

## 実装
アルバムを追加する処理と、ルーティング処理を`main.go`に追加していく。
それ以外の部分は変更がないため、省略。

```go:main.go
//...それ以外は変更なしなので省略

func postAlbums(c *gin.Context) {
	var newAlbum album

	if err := c.BindJSON(&newAlbum); err != nil {
		return
	}

	albums = append(albums, newAlbum)
	c.IndentedJSON(http.StatusCreated, newAlbum)
}

func main() {
	router := gin.Default()
	router.GET("/albums", getAlbums)
	router.POST("/albums", postAlbums)

	router.Run("localhost:8081")
}
```

`context.BindJSON`を使って、変数`newAlbum`にリクエストボディをバインドさせる。
JSONから初期化された構造体`album`のデータを`albums`スライスに追加していく。
追加したアルバム情報をインデントされたJSONで201ステータスコードと共にレスポンスで返す。
mainに、POSTリクエストしたときにpostAlbumsにルーティングする処理を追加する。

## コードの実行
一旦サーバを停止し、再度コードを実行する。

```bash
$ go run .
```

curlでPOSTリクエストを送ってみる。

```bash
$ curl http://localhost:8081/albums \
    --include \
    --header "Content-Type: application/json" \
    --request "POST" \
    --data '{"id":"4", "title":"The Modern Sound of Betty Carter", "artist":"Betty Carter", "price":49.99}'

HTTP/1.1 201 Created
Content-Type: application/json; charset=utf-8
Date: Sun, 20 Nov 2022 09:54:25 GMT
Content-Length: 116

{
    "id": "4",
    "title": "The Modern Sound of Betty Carter",
    "artist": "Betty Carter",
    "price": 49.99
}
```
無事に201 Createdとレスポンスボディで追加した情報が返ってきていることが確認できた。
GET /albumsリクエストを送って、追加されたか確認してみる

```bash
$ curl http://localhost:8081/albums
[
    {
        "id": "1",
        "title": "Blue Train",
        "artist": "John Coltrane",
        "price": 56.99
    },
    {
        "id": "2",
        "title": "Jeru",
        "artist": "Gerry Mulligan",
        "price": 17.99
    },
    {
        "id": "3",
        "title": "Sarah Vaughan and Clifford Brown",
        "artist": "Sarah Vaughan",
        "price": 39.99
    },
    {
        "id": "4",
        "title": "The Modern Sound of Betty Carter",
        "artist": "Betty Carter",
        "price": 49.99
    }
]
```

問題なく、表示された。

# 特定のアイテムを返すハンドラーの実装
## ロジックを考える
GET /albums/[id]のリクエストを送信したとき、パスパラメータの[id]に一致するIDを持つアルバム情報を返すようにする。

* 要求されたアルバムを取得するロジックを実装。
* パスをロジックにマッピングする。

## 実装
IDに紐づくアルバム情報を返すロジックと、ルーティング処理を`main.go`に追加していく。
それ以外の部分は変更がないため、省略。

```go:main.go
//...長いの省略！
func getAlbumById(c *gin.Context) {
	id := c.Param("id")

	for _, a := range albums {
		if a.ID == id {
			c.IndentedJSON(http.StatusOK, a)
			return
		}
	}
	c.IndentedJSON(http.StatusNotFound, gin.H{"message": "album not found"})
}
func main() {
	router := gin.Default()
	router.GET("/albums", getAlbums)
	router.GET("/albums/:id", getAlbumById)
	router.POST("/albums", postAlbums)

	router.Run("localhost:8081")
}

```

URLのパスパラメータを取得するには、`Context.Param`を使用する。
albumスライス内の構造体をループして、ID値が一致する構造体を探す。一致するIDが見つかった場合は、その構造体をJSONにシリアル化して、HTTPコードと共にレスポンスとして返す。
見つからなかった場合は、404エラーとメッセージを返す。
mainに、GET /albums/:idをリクエストしたときにgetAlbumByIdにルーティングする処理を追加する。

## コードの実行
一旦サーバを停止し、再度コードを実行する。

```bash
$ go run .
```

curlでID2のアルバムを取得してみる。

```bash
$ curl http://localhost:8081/albums/2
{
    "id": "2",
    "title": "Jeru",
    "artist": "Gerry Mulligan",
    "price": 17.99
}
```

次にID4のアルバムを取得してみる。

```bash
$ curl http://localhost:8081/albums/4
{
    "message": "album not found"
}
```

先ほどPOSTで追加したが、サービスを一度停止させているため、メモリ内のデータがリセットされ、ID4のデータは存在しないので、Not Foundになっている。

# まとめ
簡単なWebサービスを作ることができた。
Pythonの時もFlask, PHPではSlimを使ってたけど、この手の軽量Webフレームワークはお手軽に作れるので嬉しい。
実際に使う場合は、データベース連携や、認証機能、セッション管理、パフォーマンスなどを気にしなければならないがチュートリアルではこのぐらいがちょうどいい。


# 完成したコード

```go:main.go
package main

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type album struct {
	ID     string  `json:"id"`
	Title  string  `json:"title"`
	Artist string  `json:"artist"`
	Price  float64 `json:"price"`
}

var albums = []album{
	{ID: "1", Title: "Blue Train", Artist: "John Coltrane", Price: 56.99},
	{ID: "2", Title: "Jeru", Artist: "Gerry Mulligan", Price: 17.99},
	{ID: "3", Title: "Sarah Vaughan and Clifford Brown", Artist: "Sarah Vaughan", Price: 39.99},
}

func getAlbums(c *gin.Context) {
	c.IndentedJSON(http.StatusOK, albums)
}

func postAlbums(c *gin.Context) {
	var newAlbum album

	if err := c.BindJSON(&newAlbum); err != nil {
		return
	}

	albums = append(albums, newAlbum)
	c.IndentedJSON(http.StatusCreated, newAlbum)
}

func getAlbumById(c *gin.Context) {
	id := c.Param("id")

	for _, a := range albums {
		if a.ID == id {
			c.IndentedJSON(http.StatusOK, a)
			return
		}
	}
	c.IndentedJSON(http.StatusNotFound, gin.H{"message": "album not found"})
}
func main() {
	router := gin.Default()
	router.GET("/albums", getAlbums)
	router.GET("/albums/:id", getAlbumById)
	router.POST("/albums", postAlbums)

	router.Run("localhost:8081")
}
```
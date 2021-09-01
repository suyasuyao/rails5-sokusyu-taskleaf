# rails5-sokusyu-taskleaf


# docker
## 利用方法
```
# 初回のみ
 docker-compose build --no-cache
 docker-compose run web bin/rails db:create 
# マイグレーションやデータ投入を行う際に 
 docker-compose run web bin/rails db:migrate db:seed
# アプリケーション起動時毎回実施
docker-compose up

```

# Docker環境の作り方

rails_base_app のところに作りたいアプリ名いれる
バージョンは5.2.6

```

rails _5.2.6_ new taskleaf -d postgresql

```

以下を実施して動くの確認する。

```
cd taskleaf 
rm -r .git
bin/rails s
```

ここでコミット
```
git add -A


```


WebのDockerfileつくる　インストールするパッケージがなければ変更なし
web/database.ymlいじる(ユーザー名パスワードデータベース名に注意)

起動した際動かない場合以下のコマンド使いながら調査

```
docker run -t -i   -v /Users/yoo_ad/work/rails/rails-base2/rails_base_app:/rails-base-app ruby:2.6.8 bash

```


DbのDockerファイル作る
postgresコンテナを起動する

Dockercomposeファイル作る。
.envファイルを作る　
環境変数を変える

# bootstrapの設定



package.jsonに以下を設定

```python
{
  "name": "taskleaf",
  "private": true,
  "dependencies": {
    "bootstrap": "3",
    "jquery": "^3.4.1"
  }
}
```

```python
docker-compose run web npm install
```

```python
touch app/javascript/stylesheets/application.scss
削除
rm app/javascript/stylesheets/application.css
```

```python
@import "bootstrap/dist/css/bootstrap.min";
```

注意点

- Sassファイルでは*= require、*= require_treeを削除する
- Sassファイルではインポートに@importを利用する
- Sassファイルで*= requireを利用すると他のスタイルシートではBootstrapのmixinや変数を利用できなくなる

```python
<中略>
# //= require_tree . より上に　今回読み込みたいjQueryの設定を記述

//= require rails-ujs
//= require turbolinks
//= require jquery/dist/jquery.js　　←　ここが今回記述追加した部分
//= require_tree .
```

```python
bin/rails g controller sample index
```
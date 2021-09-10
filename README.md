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

```shell
bin/rails g controller sample index
```

# taskmodel作成

```
docker-compose run web bin/rails g model Task name:string description:text
```

```
docker-compose run web bin/rails db:migrate db:seed
```


# controller作成

```
docker-compose run web bin/rails g controller tasks index show new edit 
```

# ルーティングファイル修正

taskleaf/config/routes.rb

```
Rails.application.routes.draw do
  resources :tasks
  # トップページにtaskのindexページを表示
  root to: 'tasks#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

```


# index(一覧）ページ作成


link_to　new_task_pathについてはヘルパーメソッド

taskleaf/app/views/tasks/index.html.erb
```
<h1>タスク一覧</h1>
<%= link_to '新規登録', , class: 'btn btn-primary' %>

```

# new（新規作成）ページ作成


newメソッドで@taskを作成することで返り値となりnew画面で利用できる

taskleaf/app/controllers/tasks_controller.rb
```
class TasksController < ApplicationController
（略）
  def new
    @task = Task.new
  end
(略)
```

taskleaf/app/views/tasks/new.html.erb

```
<h1>タスクの新規登録</h1>

<div class="nav justify-content-end">
  <%= link_to "一覧", tasks_path, class: "nav-link" %>


<%= form_with(model: @task, url: tasks_path, local:true ) do |f| %>
  <div class="form-group">
    <%= f.label :name %>
    <%= f.text_field :name , class: "form-control", id:"task_name" %>
  </div>
  <div class="form-group">
    <%= f.label :description %>
    <%= f.text_field :description , class: "form-control", id:"task_description" %>
  </div>

  <%= f.submit class: "btn btn-primary" %>

<% end %>
```

以下でnewアクションは@taskを引数にフォームを作成する。
url: tasks_pathはPOSTメソッドに対応するpathがそれしかないため
パスは`bin/rails routes`で確認する


```
<%= form_with(model: @task, url: tasks_path, local:true ) do |f| %>
```

以下でフォームを利用している。
```
  <div class="form-group">
    <%= f.label :name %>
    <%= f.text_field :name , class: "form-control", id:"task_name" %>
  </div>
```

# createアクション作成

以下を追記する

taskleaf/app/controllers/tasks_controller.rb

1 taskモデルのパラメータ取得するところは、共通化できるので切り出し
2 コントローラ内では、paramsからレスポンスパラメータを取得できる
この際、対象のモデル名をrequireで絞り込み、必要な属性をpermitで指定することで保存。

```
class TasksController < ApplicationController

略

  def create
    task = Task.new(task_params)
    task.save!
    redirect_to tasks_url, notice: "タスク「#{task.name}を登録しました。"
  end

  private

  def task_params
    params.require(:task).permit(:name, :description)
  end
end

```

パラメータの例(ActionController::Parametersクラス)
```
{\"utf8\"=>\"✓\", \"authenticity_token\"=>\"mQq0LVzEM06pwZ8hO2BhUHnWg+koGdgKqgvfBv1Wjx9UndfRXEH2QQS26ZUT3qKdjsNKITQgjpeQ2arJSdVLXQ==\", \"task\"=>{\"name\"=>\"a\", \"description\"=>\"a\"}, \"commit\"=>\"Create Task\", \"controller\"=>\"tasks\", \"action\"=>\"create\"} "
```

3 フラッシュメッセージの表示
redirect_to時にnoticeもしくはalert、もしくはflashオプションを指定することで、フラッシュメッセージを表示できる
flashで入れる場合は、ハッシュ値で渡せばnoticeやalert以外も指定可能

```
    redirect_to tasks_url, notice: "タスク「#{task.name}を登録しました。"
```

flash.noticeでnoticeのメッセージを開いている。
taskleaf/app/views/layouts/application.html.erb

```
    <% if flash.notice.present? %>
      <div class="alert alert-success">
      <%= flash.notice %>
      </div>
    <% end %>
```
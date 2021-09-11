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

#リセットしたいとき
docker container prune
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

navbarの指定

taskleaf/app/views/layouts/application.html.erb
```
    <div class= "app-title navbar navbar-expand-md navbar-light bg-light">
      <div class="navbar-brand"> Taskleaf </div>
    </div>
```

## bootstrap4のインストール

以下を設定しインストール
taskleaf/package.json
```
{
  "name": "taskleaf",
  "private": true,
  "dependencies": {
    "@popperjs/core": "",
    "bootstrap": "^4.6.0",
    "jquery": "^3.4.1"
  }
}

```

taskleaf/app/assets/stylesheets/application.scss
```
@import "bootstrap/dist/css/bootstrap.min.css";

```

taskleaf/app/assets/stylesheets/application.scss
```
//= require rails-ujs
//= require activestorage
//= require turbolinks
//= require jquery/dist/jquery.js
//= require popper.js/dist/popper.min.js
//= require_tree .
//= require bootstrap/dist/js/bootstrap.min.js
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


# new画面の作成


以下ではTaskモデルの論理名をconfig/locales/ja.ymlからとってくる
https://fuqda.hatenablog.com/entry/2019/04/07/212254

``` html
        <th>
          <%= Task.human_attribute_name(:name) %>
          <%= Task.human_attribute_name(:created_at) %>
        </th>
```


taskleaf/app/views/tasks/index.html.erb
```
<h1>タスク一覧</h1>
<%= link_to '新規登録', new_task_path, class: 'btn btn-primary' %>

<div class='mb-3'>
  <table class='table table-hover'>
    <thead class='thead-default'>
      <tr>
        <th>
          <%= Task.human_attribute_name(:name) %>
          <%= Task.human_attribute_name(:created_at) %>
        </th>
      </tr>
    </thead>
    <tbody>
      <% @tasks.each do |task| %>
      <tr>
        <td>
        <%= task.name %>
        </td>
        <td> 
        <%= task.created_at %>
        </td>
      </tr>
      <% end %>
    </tbody>
  </table>
</div>
```

----------------------------------------------------

# showアクション

indexページでlinktoを使い、showページへのリンクを作成

taskleaf/app/views/tasks/index.html.erb
```html
        <td>
        <%= link_to task.name, task_path(task) %>
        </td>
        <td> 
        <%= task.created_at %>
        </td>
```

showアクションでURLのパスからパラメータのidを取得
taskleaf/app/controllers/tasks_controller.rb

``` ruby
  def show
    @task = Task.find(params[:id])
  end
```

このパラメータは、フォーム時のパラメータと違い、フォームデータの中には入ってない。
routeコマンドで出したときにでる以下で規定されているもの

```
 task GET    /tasks/:id(.:format)   tasks#show
```

```
<ActionController::Parameters {"controller"=>"tasks", "action"=>"show", "id"=>"1"} permitted: false>

Parameters: {"id"=>"1"}
```


taskleaf/app/views/tasks/show.html.erb

```html
<h1>タスクの詳細</h1>

<div class="nav justify-content-end">
  <%= link_to "一覧", tasks_path, class:'nav-link' %>
</div>

<table class="table table-hover">
  <tbody>
    <tr>
      <th>
        <%= Task.human_attribute_name(:id)%>
      </th>
      <td>
        <%= @task.id %>
      </td>
    </tr>
    <tr>
      <th>
        <%= Task.human_attribute_name(:name) %>
      </th>
      <td>
        <%= @task.name %>
      </td>
    </tr>
    <tr>
      <th>
        <%= Task.human_attribute_name(:description) %>
      </th>
      <td>
        <%= simple_format(h(@task.description),{},sanitize:false, wrapper_tag:"div") %>
      </td>
    </tr>
    <tr>
      <th>
        <%= Task.human_attribute_name(:created_at) %>
      </th>
      <td>
        <%= @task.created_at %>
      </td>
    </tr>
    <tr>
      <th>
        <%= Task.human_attribute_name(:updated_at) %>
      </th>
      <td>
        <%= @task.updated_at %>
      </td>
    </tr>
  </tbody>
</table>

```

simple_formatは以下の効果がある
文字数が可変のときに役立つ？


文字列を<p>で括る
改行は
を付与
連続した改行は、</p><p>を付与

https://qiita.com/mojihige/items/c01682774e8ef29b361f
https://railsdoc.com/page/simple_format

hメソッドはhtmlエスケープしてくれる
sanitizeは一部の危険なタグを削除するので、タグを削除せず安全にしたい場合、h
https://docs.ruby-lang.org/ja/2.7.0/class/ERB=3a=3aUtil.html

```
        <%= simple_format(h(@task.description),{},sanitize:false, wrapper_tag:"div") %>
```
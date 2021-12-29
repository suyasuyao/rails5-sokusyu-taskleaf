# rails5-sokusyu-taskleaf


# docker
## 利用方法
```
# ビルド時のみ
 docker-compose build --no-cache
 
# アプリケーション起動時毎回実施
docker-compose up

# データベースコンテナが存在しないときのみ
 docker-compose run web bin/rails db:create 
# マイグレーションやデータ投入を行う際に 
 docker-compose run web bin/rails db:migrate db:seed


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

# new（新規作成）ページ作成



link_to　new_task_pathについてはヘルパーメソッド

taskleaf/app/views/tasks/index.html.erb
```
<h1>タスク一覧</h1>
<%= link_to '新規登録', , class: 'btn btn-primary' %>

```

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


# index画面の作成


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



# editアクション

editアクションとupdateアクションを実装
editはshowと同じく、パラメータからidを取るだけ。
updateはedit画面で更新対象となったパラメータをフォームで投稿するので、
変数taskで値を取得したあと、task_paramの内容で更新かける
変数task（ローカル変数）は@task(インスタンス変数）ではないかといえば、
ビューへのデータの受け渡しがないから
createとupdateは受け渡されたデータをもとに修正するのみ

taskleaf/app/controllers/tasks_controller.rb
``` ruby

  def edit
    @task = Task.find(params[:id])
  end

  def update
    task = Task.find(params[:id])
    task.update(task_params)
    redirect_to tasks_url, notice: "タスク「#{task.name}」を更新しました。"
  end

```

new画面とほぼ同じ
taskleaf/app/views/tasks/edit.html.erb

``` html
<h1>タスクの編集</h1>

<div class="nav justify-content-end">
  <%= link_to  "一覧", tasks_path, class:"nav-link" %>
</div>

<%= form_with model:@task, local:true do |f| %>
  <div class="form-group">
    <%= f.label :name %>
    <%= f.text_field :name, class:"form-control", id: "task_name" %>
  </div>
  <div class="form-group">
    <%= f.label :description %>
    <%= f.text_area :descriotion, rows:5, class:"form-control", id: "task_description" %>
  </div>
  <%= f.submit class:"btn btn-primary" %>

<% end %>
```


# editとnewの共通化

editとcreateでほぼ同じ画面を使っているので共通化する。
共通化にはパーシャル機能を使う。パーシャルとなる画面のファイル名は最初に_がつく

taskleaf/app/views/tasks/_form.html.erb

``` html
<%= form_with model:task, local:true do |f| %>
  <div class="form-group">
    <%= f.label :name %>
    <%= f.text_field :name, class: "form-control", id: "task_name" %>
  </div>
  <div class="form-group">
    <%= f.label :description %>
    <%= f.text_area :descriotion, rows:5, class:"form-control", id: "task_description" %>
  </div>
  <%= f.submit class: "btn btn-primary" %>
<% end %>
```

renderでパーシャルを呼び出すときは_も拡張子もつけない名前とする
 {task: @task} では各画面に引き渡されたインスタンス変数@taskをローカル変数taskに読み替えている。


taskleaf/app/views/tasks/new.html.erb
taskleaf/app/views/tasks/edit.html.erb
``` html
<%= render partial: "form", locals: {task: @task} %>
```


# destroyの設定

taskleaf/app/controllers/tasks_controller.rb
edit,createとほぼ同じ
```ruby
  def destroy
    task = Task.find(params[:id])
    task.destroy
    redirect_to tasks_url, notice: "タスク「#{task.name}」を削除しました。"
  end

```

link_toでmethodに:deleteを指定し、data: confirmで確認ポップアップを出している。

``` html
          <%= link_to  "削除", task_path(task), method: :delete, data: { confirm: "タスク「#{task.name}」を削除します。よろしいですか？"}, class: 'btn btn-primary mr-3' %>
```

# 日本語の設定

config/locales/ja.ymlを設定
```shell
curl -s https://raw.githubusercontent.com/svenfuchs/rails-i18n/master/rails/locale/ja.yml -o config/locales/ja.yml
```

model情報を追記

```yml
    models:
      task: タスク
    attributes:
      task:
        id: ID
        name: 名称
        description: 詳しい説明
        created_at: 登録日時
        updated_at: 更新日時
```

以下を追記
config/application.rb
```ruby

config.i18n.default_locale = :ja # 追加

```

# データの内容を制限する

taskテーブルのnameにnotnull制約設定 
taskテーブルのnameを最大30文字とする
taksテーブルのindexにユニーク制約を設定

```

# 新しいマイグレーションファイルつくるか既存のファイルを編集する。
docker-compose run web bin/rails g migration ChangeTasksNameNotNull

# docker-compose run web bin/rails db:migrate:reset
docker-compose run web bin/rails db:migrate
docker-compose run web bin/rails db:migrate:status

docker-compose run web bin/rails c

```

```shell
yoo_ad@ymbp13 ~/w/r/rails5-sokusyu-taskleaf (feature/issue#11)> docker-compose run web bin/rails c
[+] Running 1/0
 ⠿ Container rails5-sokusyu-taskleaf-db-1  Running                                                                                     0.0s
Loading development environment (Rails 5.2.6)
irb(main):001:0> Task.new
=> #<Task id: nil, name: nil, description: nil, created_at: nil, updated_at: nil>
irb(main):002:0> Task.new.save
   (0.6ms)  BEGIN
  Task Create (4.6ms)  INSERT INTO "tasks" ("created_at", "updated_at") VALUES ($1, $2) RETURNING "id"  [["created_at", "2021-12-09 22:59:31.343536"], ["updated_at", "2021-12-09 22:59:31.343536"]]
   (0.8ms)  ROLLBACK
Traceback (most recent call last):
        1: from (irb):2
ActiveRecord::NotNullViolation (PG::NotNullViolation: ERROR:  null value in column "name" violates not-null constraint)
DETAIL:  Failing row contains (15, null, null, 2021-12-09 22:59:31.343536, 2021-12-09 22:59:31.343536).
: INSERT INTO "tasks" ("created_at", "updated_at") VALUES ($1, $2) RETURNING "id"

```


以下に書き換える
app/controllers/tasks_controller.rb
```ruby
    @task = Task.new(task_params)

    if @task.save
      #redirect先を@taskにすべきかどうか？ｘ
      redirect_to @task,  notice: "タスク「#{@task.name}」を登録しました。"
    else
      render :new
    end
```
- saveメソッドは、保存できない場合falseを返します。
- save!メソッドは、保存できない場合例外ActiveRecord::RecordInvalidが発生します。


変数をローカル変数からインスタンス変数に変更してるのは、検証失敗時のrenderで表示する画面に渡すため 


app/views/tasks/_form.html.erb
```erbruby
<% if task.errors.present? %>
<ul id="error_explantion">
  <% task.errors.full_messages.each do|message| %>
    <li><%= message %></li>
  <% end %>
</ul>
<% end %>
```

渡されたtaskにはerrosがある
https://qiita.com/mom0tomo/items/e1e3fd29729b2d112a48
partial内ではインスタンス変数を使わない



オリジナルの検証コード書き方
```ruby
class Task < ApplicationRecord
  validates :name, presence: true,length: {maximum:30}
  validate :validate_name_not_including_comma

  private
  def validate_name_not_including_comma
    errors.add(:name, 'にカンマをふくめることはできません') if name&.include?(',')
  end
end

```
name&の部分はnilチェックしなくても、安全に操作するためのおまじない
if name&.include?

# モデルの状態を変更するコールバック


```ruby
class Task < ApplicationRecord
  before_validation :set_nameless_name
  validates :name, presence: true,length: {maximum:30}
  validate :validate_name_not_including_comma

  private
  def validate_name_not_including_comma
    errors.add(:name, 'にカンマをふくめることはできません') if name&.include?(',')
  end

  def set_nameless_name
    self.name = '名前なし' if name.blank?
  end
end
```

nameがblankの際、検証の前にデータを修正するコールバックを実行している


# ログイン機能を作る

## Userモデルを作る

userモデルを作成
password_digestにはダイジェスト化したパスワード入れるが、この時点では単なる平文

```shell
 docker-compose exec web bin/rails g model user name:string email:string password_digest:string

      invoke  active_record
      create    db/migrate/20211229082045_create_users.rb
      create    app/models/user.rb
      invoke    test_unit
      create      test/models/user_test.rb
      create      test/fixtures/users.yml

```

マイグレーションファイルを修正し、null成約とユニーセク制約を設定

```ruby
class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name,null: false
      t.string :email,null: false
      t.string :password_digest,null: false

      t.timestamps
      t.index :email, unique:true
    end
  end
end

```

```shell

 docker-compose exec web bin/rails db:migrate

```

## パスワードをdigest変換し保存する

bcryptを追加

```ruby
gem 'bcrypt', '~> 3.1.7'
```

ビルドを最初からやり直し

bcryptのgemがあるか確認する
```shell
docker-compose exec web gem list
```

userクラスにhas_secure_passwordをいれることでパスワードのダイジェスト化が可能になる
modelとしては、passwordとpassword_confirmationがDBに保存されないカラムとして設定される
また、それらをもとにサーバー側でpassword_digestが作成され保存される


```ruby
class User < ApplicationRecord

  has_secure_password
end

```
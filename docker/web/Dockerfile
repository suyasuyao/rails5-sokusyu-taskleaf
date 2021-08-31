# コピペでOK, app_nameもそのままでOK
# 19.01.20現在最新安定版のイメージを取得
FROM ruby:2.6.8

# 変数の表示
ARG BASEDIR

##作業ディレクトリ名をAPP_ROOTに割り当てて、以下$APP_ROOTで参照
ENV APP_ROOT /${BASEDIR} 
WORKDIR $APP_ROOT

# 作業ディレクトリの作成、設定
COPY ./${BASEDIR}/Gemfile* /$BASEDIR/

# 必要なパッケージのインストール（基本的に必要になってくるものだと思うので削らないこと）
RUN apt-get update -qq && \
  apt-get install -y build-essential \ 
  libpq-dev \        
  nodejs \
  npm \
  postgresql-client && \

  # npmのインストール
  npm install && \

  # Gemfileのbundle install
  gem install bundler:2.1.4 && \
  bundle install

# GCP

## gcloud tool

[公式ページ](https://cloud.google.com/sdk/docs/authorizing?hl=ja)を参考にして初期セットアップを行う。

1. Install the gcloud

```powershell
$ cinst -y gcloudsdk
```

2. 認証

```powershell
# 自分の場合、initは特に実行していないが問題なく動作していた
$ gcloud init
$ gcloud auth login
# リモートサーバーなどから認証を行う場合は以下のコマンドを実行して取得したURLでアクセスして表示されたTOKENを入力して認証する
$ gcloud auth login --no-browser
```

[この時点では、Terraform などが ArtifactRegistry を使用する際にエラーが発生してしまうため、以下コマンドを実行してさらに認証を完了させておく](https://zenn.dev/waddy/articles/terraform-google-cloud#gcloud-%E3%82%B3%E3%83%9E%E3%83%B3%E3%83%89%E3%81%AE%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB)。

```powershell
$ gcloud auth application-default login
```

### 接続するプロジェクトの変更

```powershell
gcloud projects list
gcloud config list
gcloud config set project daichi-ozaki213-gcp-tutorial
```

### ArtifactRegistry の認証

レポジトリ名のトップレベル名を以下コマンドで認証する。`us-central1-docker.pkg.dev/angular-cosmos-280512/hello-repo`の場合は`us-central1-docker.pkg.dev`となる。

```powershell
$ gcloud auth configure-docker us-central1-docker.pkg.dev
$ gcloud components update
```

本認証を実行すれば Terraform が使用する

## gsutil

GCS を細かく操作することができる CLI で、バケットの作成からアクセスコントロールの設定まで様々な制御を行うことができる。

[コマンド一覧](https://www.faq.idcf.jp/app/answers/detail/a_id/920/~/gsutil-%E3%81%AE%E4%BD%BF%E3%81%84%E6%96%B9%E3%82%92%E6%95%99%E3%81%88%E3%81%A6%E3%81%8F%E3%81%A0%E3%81%95%E3%81%84%E3%80%82)
[ACL の参考ページ](https://cloud.google.com/storage/docs/access-control/create-manage-lists?hl=ja)

### 使い方

```powershell
# 最初にCLIからGCPへの認証と操作するGCSの存在するプロジェクトへ接続する
gcloud projects list
gcloud config list
gcloud config set project daichi-ozaki213-gcp-tutorial
# gsutilを使用開始できる
# Bucketの作成
gsutil mb -c standard -l us-east1 gs://daichi-tutorial1008-bucket
gsutil ls
```

## Terraform

### 依存関係の出力

[ここのページで各リソースの依存関係を出力できる方法](https://qiita.com/takkii1010/items/082c0854fd41bc0b26c3)を見つけた。

`terraform graph`コマンドを使用すると Dot 形式でリソースの依存関係が出力されるので、graphviz を使用して jpg 形式に変換する。

```powershell
# Dot形式の依存関係をファイルに書き込む
$ terraform graph | Out-File .\diagram.dot -Encoding ascii
$ dot -Tjpg -o diagram.jpg .\diagram.dot
$ Remove-Item *diagram*
```

## How to use ArtifactRegistry

[Registry への Push](https://runble1.com/terraform-arififact-registry/#toc6)

```powershell
$ docker push us-central1-docker.pkg.dev/PROJECT/my-repository/quickstart-image:tag1
```

## GKE

### Docker Image の作成

GKE など kubenetes サービスへのアプリのデプロイは Docker Image を介して行う。基本的に compose.yml を使用しての起動ではなく、Dockerfile から作成した Docker Image を`docker run -it `

```Dockerfile
FROM ruby:latest

RUN mkdir -pm 770 /var/www
COPY ./sample_app /var/www/
WORKDIR /var/www/sample_app
# 各種ファイルをイメージへ焼き付け
RUN chmod 755 -R /var/www/sample_app
RUN gem update
RUN gem install bundler
RUN bundle install

EXPOSE 3000

# コンテナを起動する際にRailsを起動するための設定
COPY startup.sh /startup.sh
RUN chmod 744 /startup.sh
CMD ["/startup.sh"]
```

- Dockerfile に記載している設定について
  - sample_app
  - `rails new sample_app`して view に「Hello World!」を出力するだけの web アプリ
  - Rails を build するのに必要な Gemfile などをまとめてイメージへコピーする
- [Image の作成](https://www.wakuwakubank.com/posts/270-docker-build-image/)
  - 以下コマンドを使用してイメージを作成する
  - イメージを作成したら、問題ないかコンテナーを起動して確認してみる
    - なお、コンテナーで特定のポートを LISTEN する際には、以下を行う必要がある。
      - Dockerfile で`EXPOSE`から開放するポート番号を指定する
      - run コマンド時に開放ポートとコンテナー内へアタッチするポートを指定する

```powershell
# Imageを作成する
$ docker build -t gke_sample_app1:1 .
# 上記Imageで問題なく起動できるか確認する
$ docker run -p 3000:3000/tcp --name gke_sample_app_test -it gke_sample_app1:1
# 接続
$ docker exec -it <ContainerID> bash
```

# GCP 遭遇エラー

## cloud_compute_network is not found

`terraform import`を実行した際に以下のようなエラーが発生した。

```powershell
PS C:\Users\besta\app\gcp_practice\infra> terraform import google_compute_network.my-test-daichi-vpc my-test-daichi-vpc
[WARN] Invalid log level: "3". Defaulting to level: TRACE. Valid levels are: [TRACE DEBUG INFO WARN ERROR OFF][WARN] Invalid log level: "3". Defaulting to level: TRACE. Valid levels are: [TRACE DEBUG INFO WARN ERROR OFF][WARN] Invalid log level: "3". Defaulting to level: TRACE. Valid levels are: [TRACE DEBUG INFO WARN ERROR OFF]google_compute_network.my-test-daichi-vpc: Importing from ID "my-test-daichi-vpc"...
google_compute_network.my-test-daichi-vpc: Import prepared!
  Prepared google_compute_network for import
google_compute_network.my-test-daichi-vpc: Refreshing state... [id=projects/daichi-first-test/global/networks/my-test-daichi-vpc]
│ Error: Cannot import non-existent remote object
│
│ While attempting to import an existing object to "google_compute_network.my-test-daichi-vpc", the provider detected that no object exists with the given
│ id. Only pre-existing objects can be imported; check that the id is correct and that it is associated with the provider's configured region or endpoint,
│ or use "terraform apply" to create a new remote object for this resource.'

```

### 解決

terraform の Provider タグに設定している Project の引数をプロジェクト名で指定していたが、google API 側では Project ID がオブジェクトに組み込まれているようだったため`Not Found`のエラーとなっていた。

```t
provider "google" {
  credentials = file("./angular-cosmos-280512-933e1631fb78.json")

  project = "daichi-first-test"
  region  = "asia-northeast1"
  zone    = "asia-northeast1-a"
}
```

provider を Project ID に指定しなおして解決した。

```t
provider "google" {
  credentials = file("./angular-cosmos-280512-933e1631fb78.json")

  project = "angular-cosmos-280512"
  region  = "asia-northeast1"
  zone    = "asia-northeast1-a"
}

```

## instance 作成の際の IAM 関連エラー

```powershell
Error: Error waiting for instance to create: The user does not have access to service account 'test-20220724-serviceaccount@angular-cosmos-280512.iam.gserviceaccount.com'.  User: 'test-20220724-serviceaccount@angular-cosmos-280512.iam.gserviceaccount.com'.
Ask a project owner to grant you the iam.serviceAccountUser role on the service account
│
│
│   with google_compute_instance.test_instance1,
│   on cloud_compute.tf line 146, in resource "google_compute_instance" "test_instance1":
│  146: resource "google_compute_instance" "test_instance1" {
│
```

### 解決

マネジメントコンソールの場合は「IAM」のページから今回使用しているユーザーである「test-20220724-serviceaccount@angular-cosmos-280512.iam.gserviceaccount.com」に対して「roles/iam.serviceAccountUser」を割り当てることで解決する。
「test-20220724-serviceaccount@angular-cosmos-280512.iam.gserviceaccount.com」の編集ページからロールの追加を行おうとしたが、なかなか追加できなかったので、「ロール」のページ（ロールの一覧が記載されているページ）でカスタムロールを作成してからそれをユーザーに追加した。

## Not found resource type for Artifact Registry

artifact registry を`terraform import`した際に、`Error: unknown resource type: google_artifact_registry_repository`のエラーが出力された。

### google-beta の使用

原因は google の provider に artifact が含まれていなかったため、`Not Found`となっていた。[2022/7/27 現在は google-beta でなければ読み込めない](https://runble1.com/terraform-arififact-registry/)ようだったため、以下のように tf ファイルに google-beta の provider を追加して解決できた。

1. google-beta を追加

provider "google" {

```
  credentials = file("./angular-cosmos-280512-933e1631fb78.json")

  project = "angular-cosmos-280512"
  region  = "us-central1"
  zone    = "us-central1-a"
}

provider "google-beta" {
  credentials = file("./angular-cosmos-280512-933e1631fb78.json")

  project = "angular-cosmos-280512"
  region  = "us-central1"
  zone    = "us-central1-a"
}
```

2. terraform の実行ファイルをすでに作成していたため、一旦`.terraformディレクトリ`と`.terraform.lock.hcl`を削除

3. `terraform init`を再度実行

### registry の認証

[レジストリ自体にアクセスするための認証が行われていないと以下のように Permission Denied となってしまう。](https://runble1.com/terraform-arififact-registry/)

```powershell
PS C:\Users\besta\app\gcp_practice\iac> terraform import google_artifact_registry_repository.my_repo us-central1-docker.pkg.dev/angular-cosmos-280512/hello-repo
[WARN] Invalid log level: "3". Defaulting to level: TRACE. Valid levels are: [TRACE DEBUG INFO WARN ERROR OFF][WARN] Invalid log level: "3". Defaulting to level: TRACE. Valid levels are: [TRACE DEBUG INFO WARN ERROR OFF][WARN] Invalid log level: "3". Defaulting to level: TRACE. Valid levels are: [TRACE DEBUG INFO WARN ERROR OFF][WARN] Invalid log level: "3". Defaulting to level: TRACE. Valid levels are: [TRACE DEBUG INFO WARN ERROR OFF][WARN] Invalid log level: "3". Defaulting to level: TRACE. Valid levels are: [TRACE DEBUG INFO WARN ERROR OFF]google_artifact_registry_repository.my_repo: Importing from ID "us-central1-docker.pkg.dev/angular-cosmos-280512/hello-repo"...
google_artifact_registry_repository.my_repo: Import prepared!
  Prepared google_artifact_registry_repository for import
google_artifact_registry_repository.my_repo: Refreshing state... [id=projects/us-central1-docker.pkg.dev/locations/angular-cosmos-280512/repositories/hello-repo]
╷
│ Error: Error when reading or editing ArtifactRegistryRepository "projects/us-central1-docker.pkg.dev/locations/angular-cosmos-280512/repositories/hello-repo": googleapi: Error 403: Permission denied on resource project us-central1-docker.pkg.dev.
│ Details:
│ [
│   {
│     "@type": "type.googleapis.com/google.rpc.Help",
│     "links": [
│       {
│         "description": "Google developer console API key",
│         "url": "https://console.developers.google.com/project/us-central1-docker.pkg.dev/apiui/credential"
│       }
│     ]
│   },
│   {
│     "@type": "type.googleapis.com/google.rpc.ErrorInfo",
│     "domain": "googleapis.com",
│     "metadata": {
│       "consumer": "projects/us-central1-docker.pkg.dev",
│       "service": "artifactregistry.googleapis.com"
│     },
│     "reason": "CONSUMER_INVALID"
│   }
│ ]
│
```

まず、管理者権限でコマンドプロンプトを起動する、自分の場合は powershell のスクリプト実行の許可をしていないため、powershell から gcloud のコマンドが起動でいないためプロンプトから実行した。
以下の手順にしたがってレジストの認証を行う。

```powershell
$ gcloud auth configure-docker us-central1-docker.pkg.dev
$ gcloud components update
```

[さらに、以下コマンドを管理者権限で実行](https://zenn.dev/waddy/articles/terraform-google-cloud#gcloud-%E3%82%B3%E3%83%9E%E3%83%B3%E3%83%89%E3%81%AE%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB)

```powershell
$ gcloud auth login
$ gcloud auth application-default login
```

WINDOWS の場合は、ここで OS を再起動して無事`terraform import`が成功した。

```powershell
$ terraform import google_artifact_registry_repository.my_repo projects/angular-cosmos-280512/locations/us-central1/repositories/hello-repo
```

## powershell のスクリプト実行ポリシーエラー

[参考ページ](https://qiita.com/ponsuke0531/items/4629626a3e84bcd9398f)

```powershell
PS C:\Windows\system32> gcloud
gcloud : このシステムではスクリプトの実行が無効になっているため、ファイル C:\Program Files (x86)\Google\Cloud SDK\googl
e-cloud-sdk\bin\gcloud.ps1 を読み込むことができません。詳細については、「about_Execution_Policies」(https://go.microsof
t.com/fwlink/?LinkID=135170) を参照してください。
発生場所 行:1 文字:1
+ gcloud
+ ~~~~~~
    + CategoryInfo          : セキュリティ エラー: (: ) []、PSSecurityException
    + FullyQualifiedErrorId : UnauthorizedAccess
```

```powershell
Set-Executionpolicy -ExecutionPolicy RemoteSigned -Scope Process
Get-Executionpolicy

Set-Executionpolicy -ExecutionPolicy Restricted -Scope Process
Get-Executionpolicy
```

## gcloud auth login --no-launch-browser 実行時のエラー

gcloud auth login --no-launch-browser 使用時に以下エラーに遭遇

> 承認エラー
> エラー 400: invalid_request
> The version of the app you're using doesn't include the latest security features to keep you protected. Please make sure to download from a trusted source and update to the latest, most secure version.
> このセクションのコンテンツはアプリ デベロッパーが提供したものです。このコンテンツは、Google で審査、検証されていません。
> アプリ デベロッパーの方は、これらのリクエストの詳細が Google のポリシーを遵守していることをご確認ください。
> access_type: offline
> response_type: code
> redirect_uri: urn:ietf:wg:oauth:2.0:oob
> state: 6iQI90lCgCSBxRYLv8vwPPxAN3k5PN
> code_challenge_method: S256
> prompt: consent
> client_id: 32555940559.apps.googleusercontent.com
> code_challenge: 6LcTGa289DFJym4z9FrGW3kqRHcvHuZEw5c1g3QqyFs
> scope: openid https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/cloud-platform https://www.googleapis.com/auth/appengine.admin https://www.googleapis.com/auth/compute https://www.googleapis.com/auth/accounts.reauth

原因は gcloud のバージョンが最新でないことが原因だった

【対処】
以下手順で gcloud をバージョンアップ

```bash
sudo apt-get upgrade gcloud
sudo apt-get upgrade google-cloud-sdk
```

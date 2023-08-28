# wsl-isucon/isucon12-qualify

## これはなに

ISUCON12予選の環境をWSL2上に構築するスクリプトです。

## 事前準備

WSL2上でsystemdを動作させるためWSLのバージョン0.67.6以降を用意してください。

## 構築

PowerShell上で以下を実行します。

```
# ダウンロード
git clone https://github.com/matsuu/wsl-isucon.git

# ディレクトリに移動
cd wsl-isucon/isucon12-qualify

# 一時的にPowerShell実行を許可
Set-ExecutionPolicy RemoteSigned -Scope Process

# 構築スクリプト実行(引数はDistro名、インストールパス)
.\build.ps1 isucon12-qualify .\isucon12-qualify
```

Windows側のhostsファイルに以下を記載します。

```/etc/hosts
127.0.0.1 admin.t.isucon.local
127.0.0.1 isucon.t.isucon.local
127.0.0.1 kayac.t.isucon.local
```

## 実行

```
wsl.exe ~ -d isucon12-qualify /bin/bash
```

### サイト表示確認

それぞれのドメインでアクセス

https://admin.t.isucon.local/
https://isucon.t.isucon.local/
https://kayac.t.isucon.local/

### ベンチマーク実行

```
cd ~/bench
./bench -target-addr 127.0.0.1:443
```

## 関連

* [ISUCON12予選問題](https://github.com/isucon/isucon12-qualify)

## 本番と異なるところ

* 本番ではドメインとして `*.t.isucon.dev` が使われていましたが、[devトップレベルドメインはHSTS preload-listに含まれており](https://ja.wikipedia.org/wiki/.dev)、正規のSSL証明書がないとアクセスできないため `*.t.isucon.local` に書き換えています

## TODO

* エラー制御
  * 二重実行の防止
* `/etc/resolv.conf` 周りの調整
* PowerShellなんもわからん

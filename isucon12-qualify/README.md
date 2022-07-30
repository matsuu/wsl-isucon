# wsl-isucon/isucon12-qualify

## これはなに

ISUCON12予選の環境をWSL2上に構築するスクリプトです。

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

## 実行

systemdを利用するため `/usr/libexec/nslogin` を噛ませる必要があります。

```
wsl.exe ~ -d isucon12-qualify /usr/libexec/nslogin /bin/bash
```

### サイト表示確認

hostsファイルに以下を記載

```/etc/hosts
127.0.0.1 admin.t.isucon.dev isucon.t.isucon.dev kayac.t.isucon.dev
```

それぞれのドメインでアクセス

https://admin.t.isucon.dev/
https://isucon.t.isucon.dev/
https://kayac.t.isucon.dev/

### ベンチマーク実行

```
cd ~/bench
./bench -target-addr 127.0.0.1:443
```

## 関連

* [ISUCON12予選問題](https://github.com/isucon/isucon12-qualify)

## TODO

* エラー制御
  * 二重実行の防止
* `/etc/resolv.conf` 周りの調整
* PowerShellなんもわからん

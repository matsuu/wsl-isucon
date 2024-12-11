# wsl-isucon/isucon14

## これはなに

ISUCON14の環境をWSL2上に構築するスクリプトです。

## 事前準備

WSL2上でsystemdを動作させるためWSLのバージョン0.67.6以降を用意してください。

## 本番と異なるところ

* SSL証明書を自己署名証明書に差し替えています

## 構築

PowerShell上で以下を実行します。

```
# ダウンロード
git clone https://github.com/matsuu/wsl-isucon.git

# ディレクトリに移動
cd wsl-isucon/isucon14

# 一時的にPowerShell実行を許可
Set-ExecutionPolicy RemoteSigned -Scope Process

# 構築スクリプト実行(引数はDistro名、インストールパス)
.\build.ps1 isucon14 .\isucon14
```

## 実行

```
wsl.exe ~ -d isucon14 /bin/bash
```

### サイト表示確認

hostsファイルに以下を記載

```/etc/hosts
127.0.0.1 isuride.xiv.isucon.net
```

設定したドメインでアクセス

https://isuride.xiv.isucon.net/

### ベンチマーク実行

ローカルに対してベンチマークを実行する場合

```
./bench run . run --addr 127.0.0.1:443 --target https://isuride.xiv.isucon.net --payment-url http://127.0.0.1:12346 --payment-bind-port 12346
```

異なるサーバに対してベンチマークを実行する場合

```
./bench run . run --addr (ベンチ対象サーバのIPアドレス):443 --target https://isuride.xiv.isucon.net --payment-url http://(ベンチ実行サーバのIPアドレス):12346 --payment-bind-port 12346
```

### 本番に近い環境を再現する

本番環境のインスタンスタイプは `c5.large` でした。近いスペックを再現したい場合は以下のコマンドを実行してください（必要に応じてCPUQuotaの値を微調整してください）。

```
sudo systemctl set-property system.slice CPUQuota=200% MemoryLimit=4G
```

ベンチマーカーは手動実行(=user.slice扱いとなる)ためこの制約を受けません。

## 関連

* [ISUCON14問題](https://github.com/isucon/isucon14)

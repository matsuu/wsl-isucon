# wsl-isucon/isucon13

## これはなに

ISUCON13の環境をWSL2上に構築するスクリプトです。

## 事前準備

WSL2上でsystemdを動作させるためWSLのバージョン0.67.6以降を用意してください。

## 本番と異なるところ

* WSL環境ではUDPポート53がWSL側で使用されているため、UDPポート1053を使用しています
* ドメインを `*.u.isucon.dev` から `*.u.isucon.local` に差し替えています
* SSL証明書を自己署名証明書に差し替えています

## 構築

PowerShell上で以下を実行します。

```
# ダウンロード
git clone https://github.com/matsuu/wsl-isucon.git

# ディレクトリに移動
cd wsl-isucon/isucon13

# 一時的にPowerShell実行を許可
Set-ExecutionPolicy RemoteSigned -Scope Process

# 構築スクリプト実行(引数はDistro名、インストールパス)
.\build.ps1 isucon13 .\isucon13
```

## 実行

```
wsl.exe ~ -d isucon13 /bin/bash
```

### サイト表示確認

hostsファイルに以下を記載

```/etc/hosts
127.0.0.1 pipe.u.isucon.local
```

設定したドメインでアクセス

https://pipe.u.isucon.local/

### ベンチマーク実行

```
./bench run --dns-port 1053 --enable-ssl
```

ベンチ結果は `/tmp/result.json` でも確認が可能です。

### 本番に近い環境を再現する

本番環境のインスタンスタイプは `c5.large` でした。近いスペックを再現したい場合は以下のコマンドを実行してください（必要に応じてCPUQuotaの値を微調整してください）。

```
sudo systemctl set-property system.slice CPUQuota=200% MemoryLimit=3.75G
```

ベンチマーカーは手動実行(=user.slice扱いとなる)ためこの制約を受けません。

## 関連

* [ISUCON13問題](https://github.com/isucon/isucon13)

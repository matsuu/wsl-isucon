# wsl-isucon/isucon12-final

## これはなに

ISUCON12本選の環境をWSL2上に構築するスクリプトです。

## 構築

PowerShell上で以下を実行します。

```
# ダウンロード
git clone https://github.com/matsuu/wsl-isucon.git

# ディレクトリに移動
cd wsl-isucon/isucon12-final

# 一時的にPowerShell実行を許可
Set-ExecutionPolicy RemoteSigned -Scope Process

# 構築スクリプト実行(引数はDistro名、インストールパス)
.\build.ps1 isucon12-final .\isucon12-final
```

## 実行

systemdを利用するため `/usr/libexec/nslogin` を噛ませる必要があります。

```
wsl.exe ~ -d isucon12-final /usr/libexec/nslogin /bin/bash
```

### ベンチマーク実行

```
export ISUXBENCH_TARGET=127.0.0.1
./bin/benchmarker --stage=prod --request-timeout=10s --initialize-request-timeout=60s
```

## FAQ

### 初期状態でベンチマークのスコアが0になる

```
22:12:10.213976 [INITIALIZATION_ERR] prepare: timeout: initialize-error-invalid-req: timeout: Post "http://127.0.0.1/initialize": context deadline exceeded
22:12:10.213998 続行不可能なエラーが検出されたので、ここで処理を終了します。
22:12:10.214021 [PASSED]: false
22:12:10.214027 [SCORE] 0 (addition: 0, deduction: 0)
```

initialize時に初期データの流し込みが行われますが、CPUもしくはディスクの性能不足で60秒以内に完了していない可能性があります。 MySQLのチューニングを行うか、ベンチマーク実行時の `--initialize-request-timeout` の秒数を引き伸ばしてみてください。

## 関連

* [ISUCON12本選問題](https://github.com/isucon/isucon12-final)

## TODO

* エラー制御
  * 二重実行の防止
* `/etc/resolv.conf` 周りの調整
* PowerShellなんもわからん

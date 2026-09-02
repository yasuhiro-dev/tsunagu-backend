# Tsunagu Backend

[Tsunagu](https://github.com/yasuhiro-dev/tsunagu) のバックエンド（Rails 8 API）です。

学校の個人面談日程を自動調整するサービスで、兄弟の連続配置や特別支援学級との調整といった制約を踏まえたスケジューリングアルゴリズムを実装しています。

プロジェクト全体の背景・設計判断・画面・インフラ構成などの詳細は、[メインリポジトリのREADME](https://github.com/yasuhiro-dev/tsunagu)を参照してください。

## セットアップ（開発環境の起動）

このリポジトリには `docker-compose.yml` を含んでいません。開発環境は [tsunagu](https://github.com/yasuhiro-dev/tsunagu)（親リポジトリ）のDocker Compose構成を使って起動してください。

```bash
# コンテナ起動
docker compose up -d

# DB作成・マイグレーション
docker compose exec rails_container rails db:create db:migrate

# テスト実行
docker compose exec rails_container bundle exec rspec
```

## 技術スタック

- Rails 8（APIモード）
- MySQL
- JWT認証
- RSpec / FactoryBot
- Brakeman

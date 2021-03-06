# Ansible Demo

Ansible Night in Osaka 2018.07 にて使用した Ansible の Demo Playbook 

- [前提条件](#前提条件)
- [実行内容](#実行内容)
- [変数一覧](#変数一覧)
- [実行手順](#実行手順)

## 前提条件

Playbookは次の環境で作成、動作を確認済み

- ansible-2.5.5-1.el7.noarch (CentOS 7)
- python-2.7.5-68.el7.x86_64
- python package (pipにてインストール)
  - boto 2.48.0
  - boto3 1.7.48
  - Jinja2 2.10
  - zabbix-api 0.5.3

環境準備の詳細は tools/setup-ansible.sh を参照のこと

## 実行内容

このPlaybookでは以下を実行する

- AWS EC2 の起動
  - Security Groupの作成
  - Instance (CentOS7) の起動とTagの付与
- CentOS7 の設定
  - パッケージアップデート
  - パッケージ追加/削除
  - サービス有効化/無効化
  - SELinux設定
  - OS再起動
- Zabbix 監視設定
  - Zabbix Agent 導入・設定
  - Zabbix Server への監視登録

playbookとroleの関係は次のとおり

```bash
site.yml
  ├─ ec2_launch.yml
  │  ├─ ec2_group
  │  └─ ec2_instance
  ├─ rhel7_setup.yml
  │  ├─ ec2_add_host
  │  ├─ yum_update
  │  ├─ yum_package
  │  ├─ service
  │  ├─ selinux
  │  └─ reboot
  └─ zabbix-agent_setup.yml
     ├─ ec2_add_host
     ├─ zabbix_agent
     └─ zabbix_register
```

## 変数一覧

このPlaybookで使用する変数は次のとおり、記述例は roles/ *ROLE-NAME* /default/main.yml を参照のこと

### 共通変数

role共通で使用する変数

| key | description | 
| --- | --- |
| global_vpc_id | AWS EC2起動対象のVPC IDを指定 |
| global_aws_region | AWS 操作対象のリージョンを指定、環境変数 *AWS_REGION* による上書きを想定 |
| global_zabbix_server_ip | Zabbix ServerのIPを指定 |

### ec2_launch.yml

| role | key | description | 
| --- | --- | --- |
| ec2_group | ec2_group | 作成するEC2 Security Groupのパラメータを指定、false の場合は作成なし |
|| ec2_group_vpc_id | 操作対象の VPC IDを指定、*global_vpc_id* による上書きを想定 |
|| ec2_group_region | 操作対象のリージョンを指定、*global_aws_region* による上書きを想定 |
| ec2_instance | ec2_instance_vpc_id | 操作対象の VPC IDを指定、*global_vpc_id* による上書きを想定 |
|| ec2_instance_region | 操作対象のリージョンを指定、*global_aws_region* による上書きを想定 |
|| ec2_instance_autoip | 作成するEC2 Instanceのパラメータを指定、falseの場合は作成なし |
|| ec2_instance_tags | EC2 Instanceへ付与するTagを指定 |
|| ec2_instance_exact_count | 起動する Instance の数を指定 |

### rhel7_setup.yml

| role | key | description | 
| --- | --- | --- |
| ec2_add_host | ec2_add_host_region | 操作対象のリージョンを指定、*global_aws_region* による上書きを想定 |
|| ec2_add_host_AnsibleOS | Inventoryへ追加するtag filter条件、検索対象tag:AnsibleOS の値を指定 |
| yum_update | yum_update | *(boolean)* yum update の実施有無を指定 |
| yum_package | yum_package_install | yum install 対象のパッケージ名を指定、false の場合はinstallなし |
|| yum_package_remove | yum remove 対象のパッケージ名を指定、false の場合はremoveなし |
| service | service_enable | 有効化するサービス名を指定、false の場合は有効化なし |
|| service_disable | 無効化するサービス名を指定、false の場合は無効化なし |
| selinux | selinux | SELinuxの動作モードを指定、false の場合は変更なし |
| reboot | - | - |

### zabbix-agent_setup.yml

| role | key | description | 
| --- | --- | --- |
| zabbix_agent | zabbix_agent_setup | *(boolean)* Zabbix Agentの導入/設定の実施有無を指定 |
|| zabbix_agent_release_url | Zabbix Agent の release file URLを指定 |
|| zabbix_agent_package | Zabbix Agent の 導入対象パッケージを指定 |
|| zabbix_agent_server_ip | Zabbix ServerのIPを指定、*global_zabbix_server_ip* による上書きを想定 |
|| zabbix_agent_conf | zabbix_agentd.conf の設定変更内容を指定 |
| zabbix_register | zabbix_register | *(boolean)* Zabbix Serverへの登録の実施有無を指定 | 
|| zabbix_register_server_ip | Zabbix ServerのIPを指定、*global_zabbix_server_ip* による上書きを想定 |
|| zabbix_register_login_user | Zabbix Serverへのログインユーザを指定 |
|| zabbix_register_login_password | Zabbix Serverへのログインパスワードを指定 |
|| zabbix_register_host_groups | 登録するホストグループを指定 |
|| zabbix_register_link_templates | 登録するテンプレートを指定 |

## 実行手順

実行手順は次のとおり *非proxy環境を想定*

playbookをclone

```bash
$ git clone https://github.com/issi176/ansible-demo
...
$ cd ansible-demo
$
```

変数ファイルを作成 (既存ファイルを編集)

```bash
$ vi group_vars/all.yml
...
$ vi group_vars/RHEL7.yml
...
$
```

AWS認証情報を入力、環境変数へ反映

```bash
$ cp set_aws_keys.sh.sample set_aws_keys.sh
$ vi set_aws_keys.sh
...
$ source set_aws_keys.sh
$
```

(必要に応じて)環境変数を~/.bash_profile へ追記

```bash
$ cat set_aws_keys.sh >> ~/.bash_profile
$
```

EC2 起動時に使用するkey pairの秘密鍵をローカルへコピー

```bash
$ cp <keypair>.pem ~/.ssh/id_rsa
$ chmod 400 ~/.ssh/id_rsa
$
```

playbookを実行

```bash
$ ansible-playbook site.yml
...
$
```

※site.yml から import している各playbookを実行してもOK

```bash
$ ansible-playbook ec2_launch.yml
$ ansible-playbook rhel7_setup.yml
$ ansible-playbook zabbix-agent_setup.yml
```

以上

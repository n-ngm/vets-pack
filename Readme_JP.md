=======================================================
# 仮想環境構築パック
=======================================================

## 概要

このプログラムはWindows上で開発に使う
仮想環境ツール(virtualbox, vagrant, chefdk, cygwin)を
まとめてインストールできるようにしたものです。

## 説明

Windows上で VirtualBox + Vagrant + Chef を使って

- 環境構築をコードで管理したい  
  (boxの配布はやめたい)
- コードの修正はゲストマシンでなくWindows側で行いたい

といった開発をしようとすると以下の問題が見えてきます。

- Windows版Vagrantの共有フォルダは遅い。rsyncモードを使えば早くなる
- Windowsでrsyncを使うには MinGWかCygwin経由でインストールする
- rsyncモードではsshが必要。同じくMinGWかCygwin経由でインストールする
- rsync,ssh をMS-DOSで使うにはPATH設定を通す必要がある
- Chefコマンド群をWindows上で使うにはChefDKのインストールが必要
- ChefDKをインストールしてもCygwin上で使うにはalias設定が必要

これらはIT開発初心者には壁が高く、毎度教えてもいられないので、
まとめてインストールおよび設定を行うプログラムを用意しました。

## インストール方法

exeファイルを実行してください。
※各種ツールのインストーラをダウンロードするため、インターネット環境が必要です。
※レジストリを使用するため、管理者権限が必要です。


## アンインストール方法

アンインストールはまとめて行っていません。
コントロールパネルから各種ツールごとに実施してください。
このプログラム自体をアンインストールしても各種ツールの動作には影響しません。

## ライセンス

各種ツールのライセンスに従ってください。

- VirtualBox : GPLv2, PUEL  [view](https://www.virtualbox.org/wiki/Licensing_FAQ)
- Vagrant    : MIT License  [view](https://github.com/mitchellh/vagrant/blob/master/LICENSE)
- ChefDK     : Apache 2.0   [view](https://downloads.chef.io/chefdk/stable/0.13.21/windows/7/license)
- Cygwin     : GPL, LGPL    [view](https://cygwin.com/licensing.html)

このプログラム自体はApache 2.0を使用します。
[License](../License)

## バグ報告/問い合わせ

バグ報告および問い合わせは[こちら](https://github.com/clickmaker/virtual-environment-tools-pack/issues)から

## 著者

[clickmaker](https://github.com/clickmaker)

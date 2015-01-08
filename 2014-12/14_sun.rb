#!/usr/bin/ruby -WKu
# -*- coding: utf-8 -*-

=begin rdoc
:title: MiniTest::Assertions.assert_fail
= MiniTest::Assertions.assert_fail
Author:: Yuta Aoyagi
Since:: 2014-12-04 12:13:03 JST (※後述)

卒論とか卒論とかで1週間ほど空いてしまったが懲りずに再開。

テスト駆動かつバージョン管理下で開発をやってると、1コミットで通すまでやるには大きすぎるテストがあったりする。
こういうときは、

1. <tt>git checkout -b great-feature</tt>して
2. テストだけコミットして
3. (より小さい)テストとプロダクトコードのコミットを必要なだけ追加して
4. 最初のテストが通る実装をコミットしたあとに
5. <tt>git checkout develop && git merge --no-ff great-feature && git branch -d great-feature</tt>する

のが世界標準のワークフローだろう(ソースは俺)。
このとき2のコミットは、ちょうど1つのテストが通らない状態になる。
んで、「これキモいなー」で済めばいいけど、「コミットはすべてのテストが通る状態に限る」みたいな規則とは真っ向衝突するわけだ。
「フィーチャーブランチ先頭でテストを追加するコミットは例外」って言ってもいいけど、
コミット前のテストでは「よし、今書いたテストだけが失敗するぞ。コミットしてよし」と目で確認することになる。
これってアレ[要出典]じゃね？

というわけで(前置きが長くなったが)「この範囲のコードによってテストが失敗する」ことをテストするassertメソッドを実装することは自然な発想だ。
実を言うとこれは独自の発想ではなく、RSpecのpendingが元ネタである。
MiniTestには類似物がなさそうだったので自作したわけだ。
(なお、RSpecをそのまま使わずにMiniTestに移植する道を選んだのは、宗教上の理由でRSpecは使えないからである)

== 構成ファイル

- lib/minitest-supplement.rb: `require`などで読み込まれるべきファイル
- このファイル: 使い方の例とテスト

== 使い方
使い方そのものは下のTestAssertFail#test_assert_fail_succeedsやTestAssertFail#test_use_assert_fail_simplyを参照。

1. assert_failを呼んだ後できるだけ早くskipを呼ぶこと。
   特に、assert_failの戻り値をチェックしないなら、TestAssertFail#test_use_assert_fail_simplyでやってるように、ブロックを閉じたその行でskipを呼ぶこと。
2. ブロックの内容が短くてもassert_failを呼ぶ行にまとめないこと。

の2点をお勧めする。
1はそのテストメソッドが完全には実行されていないことを忘れないようにするため。
2は、テストが通るようになってassert_failを取り除くとき、(空白を無視する)diffをとるとassert_failが取り除かれただけだと分かりやすくなるため。

== 注意
MiniTest 5.4.2でしかテストしてない。
MiniTest::Assertionsの内部にベタベタに依存したコードなので、MiniTestの実装が変わるたびに見直す必要がある。
まあ、そういうコードをこのファイルにまとめたというだけでもマシではないかと。

== minitest-supplement.rbに書いてるSinceの時刻古くね？　というかその精度は何だ？
この時刻のコミットに、

    def assert_fails(&block)
      assert_raises(MiniTest::Assertion, &block)
    end

というコードがある。
これがこの実装の原点であった。
04_thu.md[04_thu.md]で「今日はもうちょっと違うことをやってたけど」というのはこれのこと。
minitest-supplement.rbの実装が10行にまで成長したのは、

- 上の手抜き実装ではブロック内でskipを呼んだときassert_failsが不正に成功してしまうこと
- assert_raisesがデフォルトで生成するメッセージが気に入らない

への対応を行ったため。

== あとがき(コードの後には置けないのでここで勘弁して)
「10行のメソッドでこんなハックしたぜ」な記事が(テスト含めて)150行超えてるんですかね？？
ではまた次回(明日とはもう言わない)。
=end

require 'rubygems'
require 'minitest'
require File.expand_path('../lib/minitest-supplement.rb', File.dirname(__FILE__))

if $0 == __FILE__
  MiniTest.autorun

  # お試しコード
  class TestAssertFail < MiniTest::Test
    # +assert_fail+を使ってみて、返してくる失敗のメッセージも検査する
    def test_assert_fail_succeeds
      e = assert_fail {
        some_failure_assertions
      }
      assert_match /IMPORTANT FAILURE MESSAGE/, e, 'assert_fail returns'
      skip
    end

    # 単純な場合の使い方
    def test_use_assert_fail_simply
      assert_fail {
        some_failure_assertions
      }; skip
    end

    # 以下のテストは「assert_failが失敗したときMiniTest::Assertionが投げられる」という
    # MiniTest::Assertionsの実装の詳細に依存していてよろしくない。

    # ブロック内のテストが失敗しなかったらassert_failは失敗する
    def test_assert_fail_fails_because_block_did_not_fail
      assert_raises(MiniTest::Assertion) {
        assert_fail {
          'passed inside block without any failure'
        }
      }
    end

    # ブロック内から例外が投げられるとassert_failは失敗する
    def test_assert_fail_fails_due_to_exception
      assert_raises(MiniTest::Assertion) {
        assert_fail {
          raise 'exception from inside block'
        }
      }
    end

    # ブロック内でskipが呼ばれるとassert_failは失敗する
    def test_assert_fail_fails_when_skip_is_called
      assert_raises(MiniTest::Assertion) {
        assert_fail {
          skip 'skip cause assert_fail to fail'
        }
      }
    end

    private

    # 機能がまだ実装されていないゆえに失敗するassertメソッドの呼び出し
    def some_failure_assertions
      flunk 'Failed because some features are not implemented yet, with IMPORTANT FAILURE MESSAGE'
    end
  end
end

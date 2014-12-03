#!/usr/bin/ruby -WKu
# -*- coding: utf-8 -*-

=begin rdoc
:title: Ruby組み込みライブラリのStructクラス
= Ruby組み込みライブラリのStructクラス
Author:: Yuta Aoyagi
Since:: 2014-12-03

今日の記事はRubyのコードが含まれるので、MarkdownではなくRDocで書くことにした。
RDocでブログ記事(or 日記)、うん、ロックだねｗｗ

== 導入
Structクラスを使うと比較系メソッドやhashが自動的に定義されるので、値が主体のクラスを書くのに便利である。

    Point = Struct.new(:x, :y)
    p = Point.new(42, 99)
    puts "p is (#{p.x}, #{p.y})"

なんて使い方をするけど、値クラスに他のメソッドをもたせたいときはこれでは不足である。

== ふるまいをもつ値クラス
Struct.newはClassのインスタンスを返すので、
その無名クラスを継承する方法(下のInheritStruct)で他のメソッドを定義できる。

とまあ、つい先日まではこれで満足していた。
ある晩気まぐれに"Ruby monad"でGoogle検索してトップにくる http://codon.com/refactoring-ruby-with-monads を見て驚いた。
調べてみると、Struct.newはブロックをとり、作られたクラスのコンテキストでそのブロックを実行するのだという。
これはStructクラスのドキュメントに書かれていない挙動である。

今日の記事の目的は、それを確かめることである。
このプログラムを実行するには

    ruby -WKu 03_wed.rb && rdoc -cUTF-8

とでもすればよい。
=end

require 'rubygems'
require 'minitest/autorun'

# Struct.newが返す無名クラスを継承してメソッドを定義する例。
class InheritStruct < Struct.new(:val)

  # 定義するメソッドからStructが提供するメソッド+val+を参照できることに注意。
  def foo
    val.inspect
  end
end

# ブロックが実行されるタイミングを調べるための記録。
Log = "before\n"

# Struct.newに渡すブロックのコンテキストの記録。
Self = ''

# Struct.newに渡したブロックでメソッドを定義する例。
BlockStruct = Struct.new(:val) {
  Log << "defining\n"
  Self << self.inspect

  # メソッドの例。
  def bar
    val.inspect
  end
}

Log << "after\n"

class TestStructs < MiniTest::Test
  # InheritStruct#fooを呼べることを確かめる。
  def test_inherit_struct_works
    assert_equal '42', InheritStruct.new(42).foo
  end

  # BlockStruct#barを呼べることを確かめる。
  # RDocはbarをファイルスコープだと誤認するが、
  # このテストが成功することから、BlockStructにメソッドが定義されていることが分かる。
  def test_block_struct_works
    assert_equal '42', BlockStruct.new(42).bar
  end

  # 'defining'が'before'と'after'の間にあること、
  # すなわち、Struct.newの中からブロックが実行されていることを確かめる。
  def test_log
    assert_equal "before\ndefining\nafter\n", Log
  end

  # SelfがClassクラスのインスタンスを表す文字列であること、すなわち、
  # Struct.newで作られたクラスのコンテキストでブロックが実行されていることを確かめる。
  def test_self
    assert_match /#<Class:0x[0-9A-Fa-f]+>/, Self
  end
end

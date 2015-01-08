# -*- coding: utf-8 -*-

=begin rdoc
= MiniTestへの拡張
Author:: Yuta Aoyagi
Since:: 2014-12-04 12:13:03 JST
=end

require 'rubygems'
require 'minitest/assertions'

module MiniTest
  module Assertions
    ##
    # 与えられたブロックを実行してMiniTestレベルの失敗が発生しなかったら失敗する。
    # MiniTestの失敗でない例外が発生しても失敗する。
    # 発生したMiniTestの失敗を返すので、呼び出し側でメッセージの検査などを追加してもよい。
    def assert_fail(msg = nil)
      msg += ".\n" if msg
      begin
        yield
      rescue Exception => e
        return e if e.instance_of?(MiniTest::Assertion)
        flunk exception_details(e, "#{msg}Expected to fail assertion, but raised")
      end
      flunk "#{msg}Expected to fail assertion, but didn't."
    end
  end
end

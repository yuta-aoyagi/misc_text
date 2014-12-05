#!/usr/bin/ruby -WKu
# -*- coding: utf-8 -*-

require 'rubygems'
require 'minitest/autorun'

class Maybe
  def self.return_(x)
    Maybe.new(x)
  end

  def self.just(x)
    Maybe.new(x)
  end

  def self.nothing
    Nothing
  end

  def initialize(x)
    @x = x
  end

  def ==(other)
    other.is_a?(Maybe) && @x == other.instance_variable_get(:@x)
  end

  def bind
    yield @x
  end

  Nothing = Object.new
  class << Nothing
    def bind
      self
    end
  end
end

class TestMaybe < MiniTest::Test
  def setup
    @hash = { 3 => 2, 2 => 1, 1 => 0 }
    @proc = proc {|n|
      @hash.key?(n) ? Maybe.return_(@hash[n]) : Maybe.nothing
    }
  end

  def test_left_identity
    assert_equal @proc[3], Maybe.return_(3).bind(&@proc)
  end

  def test_right_identity
    ret = proc {|n| Maybe.return_(n)}

    m = Maybe.return_(3)
    assert_equal m, m.bind(&ret)

    m = Maybe.nothing
    assert_equal m, m.bind(&ret)
  end

  def test_associativity
    m = Maybe.return_(1)
    f = g = @proc
    assert_equal (m.bind(&f)).bind(&g), m.bind {|n| f[n].bind(&g)}
  end
end

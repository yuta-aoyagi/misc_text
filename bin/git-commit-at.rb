#!/usr/bin/ruby -WKu
# -*- coding: utf-8 -*-

=begin rdoc
:title: git-commit-at.rb
= git-commit-at.rb
Author:: Yuta Aoyagi
Since:: 2014-12-06

    usage> ruby git-commit-at.rb (rev)

このスクリプトを起動すると<tt>git commit -v</tt>が起動されるが、
そこで作成されるコミットは+rev+と同一のAuthor dateをもつ。
=end

s = `git cat-file commit #{$*[0]}`
raise s if /^author\s.+<.*>\s+(\d+\s+[+-]\d+)$/ !~ s
ENV['GIT_AUTHOR_DATE'] = $1
raise if !system('git commit -v')

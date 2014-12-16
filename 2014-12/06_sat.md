git-commit-at.rb
================

`git rebase -i`で歴史修正すると、`pick`したコミットのAuthor dateは維持される。
これと同様に、他の変更でもある既存のコミットと同一のAuthor dateを記録したいことがある。

2014-12-17編集
--------------

上記を実現するコードが[../bin/git-commit-at.rb](../bin/git-commit-at.rb)にある。

このファイルは元はRubyのソースファイル`06_sat.rb`だったが、コードを適切な名前のファイルに移した結果コードが残らなかったのでMarkdownに置き換えた。

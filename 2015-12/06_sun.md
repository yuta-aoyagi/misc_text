# Ruby組み込みライブラリのStructクラス

去年の12月[3日](../2014-12/03_wed.rb)・[4日](../2014-12/04_thu.md)、「`Struct.new`がブロックをとるのはドキュメントされてない挙動だ」(大意)と主張したわけだけど。
この秋ごろ[ドキュメント](http://docs.ruby-lang.org/ja/1.8.7/method/Struct/s/=5b=5d.html)を見たら、しれっと追記されてたんですね。
ドキュメントのプロジェクトに[チケット](https://github.com/rurema/doctree/issues/178)が切られてて、今年の2月には対応されていたことが分かる。
このチケットからリンクされてる[ブログ記事](http://d.hatena.ne.jp/yarb/20130104/p1)が、2013年1月にソースコードレベルで追うところまでたいへんよくまとめてくれてるので、これ以上言うことはない。

無事ドキュメントに載ったので、今後はブロックを渡す方法でふるまいの定義やりますよ。

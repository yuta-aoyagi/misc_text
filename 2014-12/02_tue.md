今日やったこと
==============

夜中にちょろっと書けてすぐ完結するものと言うと、ブックマークレット書いたことかな。

For Twitter Webという名前で

    javascript:(function(s){location.href=s.replace(/^(\S+)\s+(\d+)$/, "https://twitter.com/$1/status/$2");})("")

これだけ。

Google Chromeがアドレスバーの内容でブックマークからも検索してくれることを利用して、このブックマークをアドレスバーに呼び出し、`("")`の中に次のような文字列を書き加えてEnter。

    yuuta_aoyagi	538639082209812480

実に簡単な仕掛けだが、こういう簡単なところから自動化を進めるのがお手軽でよい。

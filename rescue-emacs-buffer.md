# ハングしたEmacsからバッファのデータを救出する

## 試み1. マニュアルにあるGDBスクリプトの利用

Emacsマニュアルの\`After a Crash'節によると、core dumpからバッファのデータを取り出すGDB用スクリプトが提供されているらしい。
当時(2015-09-04夜、以下「前回」)のapt-cygはCygwinのリポジトリと不整合だったらしく、バイナリで配布されているGDBを検証できなかったので、GDBをソースからビルドすることになった。
これに失敗したので断念。

なお、GDBを動かせる環境が手に入ったところで、Cygwin環境でcore dumpをうまく吐かせられるのか不明ではあった。

- [Emacsがハングした→ファイルに対応させてないバッファで失いたくないものがある→gdbでそういうデータを救出するスクリプトがあるのを思い出す→gnupackのバージョンが古いためapt-cygは使えない→gdbをビルドしてる←ｲﾏｺｺ](https://twitter.com/yuuta_aoyagi/status/639748306264944640)
- [makeの中でさらにconfigure走るらしいのに気づかずに`make -j3'したので出力が楽しいことになっている。](https://twitter.com/yuuta_aoyagi/status/639753668242227200)
- [gdbのビルドに失敗](https://twitter.com/yuuta_aoyagi/status/639778301993549824)

## 試み2. Process Explorerによるダンプからod(1)で取り出す

どんな仕組みかは知らないが、Process Explorerではプロセスのメモリ空間のダンプを取得できる。
[Process]メニュー → [Create Dump] → [Create Full Dump...]でファイルとして保存する。
前回も今回(2016-03-28昼過ぎ)も0.8(±0.1)GiBほどになった。
短命なメモは英語またはローマ字で書く習慣なので、ASCIIコードの範囲でバッファのデータを探すキーワードを思い出せた。
`strings -tx (emacs).DMP | grep -C20 (keyword)`を眺めてデータがダンプのどこにあるのかオフセットを調べる。
そして`od -Ax -tx1z -j(offset) (emacs).DMP`でバッファの全体を救出できた。

- [Process ExplorerでCreate Full Dump→\`strings -tx dump-file | grep -C20 keyword'でバッファのデータ位置を発見→\`od -Ax -tx1z -j(offset) dump-file'](https://twitter.com/yuuta_aoyagi/status/639778301993549824)
- [「10行足らずのテキストのために2時間もかけたのかよ」とも言えるし、「今後Emacsがどんなハングしてもバッファのデータ救出できるノウハウが身についたな、おめでとう」とも言える。](https://twitter.com/yuuta_aoyagi/status/639779396941799424)
- [「某ソフト会社のオフィススイートなんかだとこう簡単にはデータ復旧できなかったはずなので、プレーンテキスト万歳」とも言える。](https://twitter.com/yuuta_aoyagi/status/639779603658096640)

## 試み3. 上のダンプからdd(1)で取り出す
前回はバッファの内容が完全にASCIIのみかつほんの数行だったので、od(1)の出力を見て手で新しいEmacsセッションに書き写せた。
今回はマルチバイト文字を含んでいるのでod(1)の出力から元の内容を読むのは(人間には)難しい、ということに、odをかけてから気づいた。
オフセットを調べるところまでは上の試みと同じだが、その数百バイト手前からバッファのデータより少し後ろまで余裕をとった長さで`dd if=(emacs).DMP bs=1 skip=(offset) count=(length) | cat -vE`の出力を見た。
バッファの外は都合よく`^@`が並んでいたり、マルチバイト文字はUTF-8っぽいバイト列が見えて行の長さが分かったりしたので、バッファ先頭の正確なオフセットと行数を特定できた。
EmacsのM-!(shell-command)で`dd if=(emacs).DMP bs=1 skip=(offset) count=(length) | head -n(num_lines)`を実行してすべてのデータを救出できた。
(既知の行数でhead(1)にパイプしているので、countに正確な長さを与える必要はない)

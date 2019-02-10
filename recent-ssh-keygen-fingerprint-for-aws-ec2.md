# Couldn't generate the fingerprint for a key pair imported to Amazon EC2, with the command provided by its document

tl; dr: `ssh-keygen -ef path_to_private_key -m PEM | openssl rsa -RSAPublicKey_in -outform DER | openssl md5 -c`

A command `openssl rsa -in path_to_private_key -pubout -outform DER | openssl md5 -c` (†1) is introduced as one generating the fingerprint for a key pair imported to Amazon EC2 (https://docs.aws.amazon.com/en_us/AWSEC2/latest/UserGuide/ec2-key-pairs.html#verify-key-pair-fingerprints).
The command doesn't work as expected when used with private keys generated by OpenSSH 7.8 or later (without specifying key format):

	$ ssh-keygen -b 4096
	(snip)
	$ openssl rsa -in .ssh/id_rsa -pubout -outform DER | openssl md5 -c
	unable to load Private Key
	2675996:error:0906D06C:PEM routines:PEM_read_bio:no start line:pem_lib.c:697:Expecting: ANY PRIVATE KEY
	(stdin)= d4:1d:8c:d9:8f:00:b2:04:e9:80:09:98:ec:f8:42:7e

This is because OpenSSH 7.8 and later changed the default private key format ((ja) https://dev.classmethod.jp/server-side/network/openssh78_potentially_incompatible_changes/ †2)(https://www.openssh.com/releasenotes.html).
The Web page (†2) shows `-m PEM` option to use old format, but it's not a perfect solution because OpenSSH project changes the format for improving security.
This post proposes a new command to generate the fingerprint that Amazon EC2 generates, using the new key format:

	$ ssh-keygen -ef .ssh/id_rsa -m PEM | openssl rsa -RSAPublicKey_in -outform DER | openssl md5 -c
	writing RSA key
	(stdin)= 01:23:45:67:89:ab:cd:ef:de:ad:be:af:ca:fe:ba:be

The original command (†1) extracted a public key in DER format on the left-hand side of the pipe. A command `ssh-keygen -ef path_to_private_key -m PEM | openssl rsa -RSAPublicKey_in -outform DER` provides the same output for the new key format: we can get a public key in PEM format by `ssh-keygen`'s `-e -m PEM`; and the latter half `openssl rsa -RSAPublicKey_in` reads the format.

## (日本語版)　Amazon EC2 にインポートしたキーペアのフィンガープリントをマニュアルにあるコマンドで生成できない件

tl; dr: `ssh-keygen -ef path_to_private_key -m PEM | openssl rsa -RSAPublicKey_in -outform DER | openssl md5 -c`

Amazon EC2 にインポートしたキーペアのフィンガープリントを生成するコマンドとして `openssl rsa -in path_to_private_key -pubout -outform DER | openssl md5 -c` (†1)が紹介されている (https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/ec2-key-pairs.html#verify-key-pair-fingerprints) 。
このコマンドは OpenSSH 7.8以降で(フォーマットを指定せずに)生成した秘密鍵に対しては期待通りに動かない:

	$ ssh-keygen -b 4096
	(snip)
	$ openssl rsa -in .ssh/id_rsa -pubout -outform DER | openssl md5 -c
	unable to load Private Key
	2675996:error:0906D06C:PEM routines:PEM_read_bio:no start line:pem_lib.c:697:Expecting: ANY PRIVATE KEY
	(stdin)= d4:1d:8c:d9:8f:00:b2:04:e9:80:09:98:ec:f8:42:7e

これは、 OpenSSH 7.8以降で秘密鍵のデフォルトのフォーマットが変わったためである (https://dev.classmethod.jp/server-side/network/openssh78_potentially_incompatible_changes/ †2)(https://www.openssh.com/releasenotes.html) 。
(†2)のページでは古いフォーマットを使う `-m PEM` オプションが紹介されているが、フォーマットの変更はセキュリティ向上のためだったので好ましくない。
本稿では、新しい鍵フォーマットを用いつつ、 Amazon EC2 が生成するフィンガープリントを生成するコマンドを提案する:

	$ ssh-keygen -ef .ssh/id_rsa -m PEM | openssl rsa -RSAPublicKey_in -outform DER | openssl md5 -c
	writing RSA key
	(stdin)= 01:23:45:67:89:ab:cd:ef:de:ad:be:af:ca:fe:ba:be

もともとのコマンド(†1)はパイプの左側で DER フォーマットの公開鍵を抽出していた。新しい鍵フォーマットに対しては `ssh-keygen -ef path_to_private_key -m PEM | openssl rsa -RSAPublicKey_in -outform DER` が同じ出力を与える: `ssh-keygen` の `-e -m PEM` で PEM 形式の公開鍵を得て、 `openssl rsa -RSAPublicKey_in` がそのフォーマットを読む。
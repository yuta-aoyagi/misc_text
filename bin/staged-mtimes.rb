#!/usr/bin/ruby -WKu
# -*- coding: utf-8 -*-

require 'kconv'

a = `git diff --cached --name-status`.split("\n").map {|l|
  abort("bad diff line: #{l}") until /^[ACDMRTUXB]\t(.*)$/ =~ l
  begin
    t = File.mtime($1).getlocal
  rescue => e
    next e
  end
  z = t.zone.kconv(Kconv::UTF8, Kconv::SJIS)
  if z != "東京 (標準時)" && z != 'JST'
    abort("unknown timezone: #{t.zone}")
  end
  "`#{$1}`は" + t.strftime("%Y-%m-%d %X JST") + "に"
}
if a.size < 1
  exit
elsif a.size == 1
  s = a[0]
else
  s = a.join(",\n") + "それぞれ"
end
s += "更新.\n"
print s

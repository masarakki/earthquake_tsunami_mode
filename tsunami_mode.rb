# -*- coding: utf-8 -*-
#
# Earthquakeを実況モードにするプラグインです
# 普通に起動した後
#  :tsunami #K-ON #tbs
# のようにして実況モードに入ります
#
# すると #K-ON (空白区切りで最初のキーワードのみ) で検索した結果が
# リアルタイムに更新されます
#
# つぶやこうとすると つぶやき内容の後ろに #K-ON #tbs が自動で付与されます
#
# 元のモードに戻るには :reconnect のコマンドを実行します
#
module Earthquake
  attr_accessor :tsunami_mode
  def self.reconnect(options = nil)
    @tsunami_mode = nil
    item_queue.clear
    default = {
      :host  => 'userstream.twitter.com',
      :path  => '/2/user.json',
      :ssl => true
    }
    start_stream(default.merge( options || {}))
  end
end

Earthquake.init do
  command :tsunami do |params|
    keywords = params[1]
    search_keyword = keywords.split(/ /).first
    reconnect(
      :host => 'stream.twitter.com',
      :path => '/1/statuses/filter.json',
      :method => 'POST',
      :ssl => false,
      :filters => [search_keyword])
    @tsunami_mode = keywords
  end
  
  input_filter do |text|
    text = "#{text} #{@tsunami_mode}" if text =~ /:update .*/ && !@tsunami_mode.nil?
    text
  end
end

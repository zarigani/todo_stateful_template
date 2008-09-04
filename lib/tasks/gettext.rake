desc "Update pot/po files."
task :updatepo do
  require 'gettext/utils'
  # Rails2.0から拡張子.erbもRubyとして解析する必要があるので、以下の追記が必要
  GetText::ErbParser.init(:extnames => ['.rhtml', '.erb'])

  GetText.update_pofiles(
    "todo",  #テキストドメイン名(init_gettextで使用した名前) 
    Dir.glob("{app,config,components,lib}/**/*.{rb,rhtml,rjs,erb}"),  #ターゲットとなるファイル（文字列内は余分なスペース無しで指定する）
    "todo_role 1.0.0")  #アプリケーションのバージョン
end

desc "Create mo-files"
task :makemo do
  require 'gettext/utils'
  GetText.create_mofiles(true, "po", "locale")
end

class BaseFormBuilder < ActionView::Helpers::FormBuilder
  class_inheritable_accessor :form_helpers
  self.form_helpers = ActionView::Helpers::FormHelper.instance_methods + 
                        ActionView::Helpers::FormOptionsHelper.instance_methods
  # 上記設定は以下と同等、参考ページ<http://rubyist.g.hatena.ne.jp/yamaz/20070107>
  #  def self.form_helpers
  #    @@form_helpers = ActionView::Helpers::FormHelper.instance_methods + 
  #                       ActionView::Helpers::FormOptionsHelper.instance_methods
  #  end

private

  # 以下のオプションをマージする
  #   args（f.text_field等のオプション）
  #   @options（form_for,fields_forのオプション）の中の独自オプション
  def merge_options_with(args)
    #args_hash = args.last.is_a?(Hash) ? args.pop : {}
    args_hash = args.extract_options!
    args << form_options.merge(args_hash)
  end

  # フォームに設定する独自オプションだけ取り出す
  def form_options
    _options = @options.dup
    [:url, :html, :builder].each {|key| _options.delete(key)}
    _options
  end

  # オブジェクト名からクラスを取得する
  def object_class
    Object.const_get(@object_name.to_s.classify)
  end
end
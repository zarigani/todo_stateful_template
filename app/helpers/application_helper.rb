# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # LabelMsgFormBuilderを利用するform_forヘルパー
  #
  #   form_for @todo, :builder=>LabelMsgFormBuilder do |f|
  #     f.text_field :body
  #   end
  #
  #   simple_form_forを利用すれば:builderオプションは省略できる
  #
  #   simple_form_for @todo do |f|
  #     f.text_field :body
  #   end
  def simple_form_for(record_or_name_or_array, *args, &block)
    #options = args.last.is_a?(Hash) ? args.pop : {}
    options = args.extract_options!
    args << options.merge(:builder=>LabelMsgFormBuilder)

    form_for(record_or_name_or_array, *args, &block)
  end

  # simple_form_forを<fieldset>と<legend>でラップする
  def label_msg_form_for(record_or_name_or_array, *args, &block)
    #options = args.last.is_a?(Hash) ? args.pop : {}
    options = args.extract_options!
    args << options.merge(:builder=>LabelMsgFormBuilder)

    name = case record_or_name_or_array
           when String, Symbol
             _(record_or_name_or_array)
           else
             _(ActionController::RecordIdentifier.singular_class_name(record_or_name_or_array.to_a.last))
           end

    concat('<fieldset>', block.binding)
    concat("<legend>#{name}</legend>", block.binding)
    form_for(record_or_name_or_array, *args, &block)
    concat('</fieldset>', block.binding)
  end
end

# FormHelperの拡張
module ActionView
  module Helpers
    module FormHelper
      # FormBuilderに合わせて、内容は同じだが念のためオーバーライド
      def label(object_name, method, text = nil, options = {})
        InstanceTag.new(object_name, method, self, nil, options.delete(:object)).to_label_tag(text, options)
      end

      # 円数値入力用のテキストフィールドを生成
      # 右寄せ、3桁区切り[   1,000]、オートコンプリートオフ
      def yen_field(object_name, method, options = {})
        # object_nameに基づくオブジェクト(モデルのインスタンス)から、methodが示すフィールドの値を取得している。
        # 例: yen_field 'slip', 'total_yen' --> @slip.total_yenがvalueに設定される。
        object = options[:object] || self.instance_variable_get("@#{object_name}")
        value = object.send(method)
        # デフォルトのオプション設定
        options.merge!(:value=>number_with_delimiter(value), 
                       :autocomplete=>'off', 
                       :style=>"text-align:right")
        InstanceTag.new(object_name, method, self, nil, options.delete(:object)).to_input_field_tag("text", options)
      end

      # error_message_onの複数形版
      # 指定したフィールドのすべてのエラーを返す
      def error_messages_on(object, method, prepend_text = "", append_text = "", css_class = "formErrorMsg")
        if (obj = (object.respond_to?(:errors) ? object : instance_variable_get("@#{object}"))) && (errors = obj.errors.on(method))
          errors_list = errors.map {|error| "<li>#{prepend_text}#{error}#{append_text}</li>"}.join
          content_tag('ul', errors_list, :class => css_class, :style=>"padding:0;margin-top:0;")
        else 
          ''
        end
      end
    end

    class InstanceTag #:nodoc:
      # ruby-gettextで翻訳するため修正
      def to_label_tag(text = nil, options = {})
        name_and_id = options.dup
        add_default_name_and_id(name_and_id)
        options["for"] = name_and_id["id"]
        #content = (text.blank? ? nil : text.to_s) || method_name.humanize
        content = (text.blank? ? nil : text.to_s) || object_class.human_attribute_name(method_name)
        content_tag("label", content, options)
      end

      # オブジェクト名からクラスを取得する
      def object_class
        Object.const_get(@object_name.to_s.classify)
      end
    end
    
    # form_for, fields_forブロック内のメソッド定義
    class FormBuilder
      # f.labl
      # 内容は同じだが、ここでオーバーライドしておかないと翻訳されなかった
      def label(method, text = nil, options = {})
        @template.label(@object_name, method, text, objectify_options(options))
      end

      # f.yen_field
      def yen_field(method, options = {})
        @template.yen_field(@object_name, method, options.merge(:object => @object))
      end

      # f.error_messages_on
      def error_messages_on(method, prepend_text = "", append_text = "", css_class = "formErrorMsg")
        @template.error_messages_on(@object, method, prepend_text, append_text, css_class)
      end
    end
  end
end

# visual_effectの:startcolorオプションでエラー対策
# http://d.hatena.ne.jp/zariganitosh/20080123/1201163615#visual_effect_startcolor
module ActionView
  module Helpers
    module ScriptaculousHelper
      def visual_effect(name, element_id = false, js_options = {})
        element = element_id ? element_id.to_json : "element"
        
        js_options[:queue] = 
          if js_options[:queue].is_a?(Hash)
            '{' + js_options[:queue].map {|k, v| k == :limit ? "#{k}:#{v}" : "#{k}:'#{v}'" }.join(',') + '}'
          elsif js_options[:queue]
            "'#{js_options[:queue]}'"
          end if js_options[:queue]
        
        [:endcolor, :direction, :startcolor, :scaleMode, :restorecolor].each do |option|
          js_options[option] = "'#{js_options[option]}'" if js_options[option] && !(/¥A(['"]).+¥1¥z/ =~ js_options[option])
        end

        if TOGGLE_EFFECTS.include? name.to_sym
          "Effect.toggle(#{element},'#{name.to_s.gsub(/^toggle_/,'')}',#{options_for_javascript(js_options)});"
        else
          "new Effect.#{name.to_s.camelize}(#{element},#{options_for_javascript(js_options)});"
        end
      end
    end
  end
end

# nil.to_s(:simple)を利用可能にする
class NilClass
  def to_s(*args)
    ""
  end
end
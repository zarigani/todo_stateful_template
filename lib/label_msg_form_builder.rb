class LabelMsgFormBuilder < BaseFormBuilder
  # <% form_for @slip do |f| %>
  #   <p>
  #     <%= f.label :number %>
  #     <%= f.text_field :number %>
  #     <%= f.error_messages_on :number %>
  #   </p>
  # <% end %>
  #
  # :builder=>LabelMsgFormBuilderオプションを利用すると以下のように書ける
  #
  # <% form_for @slip, :builder=>LabelMsgFormBuilder do |f| %>
  #   <%= f.text_field :number %>
  # <% end %>
  (form_helpers - %w(label form_for field_for hidden_field error_messages_on)).each do |selector|
    define_method(selector) do |field, *args|
      args_hash = args.extract_options!
      label = args_hash.delete(:label)
      args << args_hash
      @template.content_tag('p', 
        @template.label(@object_name, field, label, :style=>"display:table") + #'<br/>' +
        super(field, *merge_options_with(args)) + 
        @template.error_messages_on(@object_name, field))
    end
  end

  # form_forのoptionとは無関係
  def submit(value = "Save changes", options = {})
    @template.content_tag('p', super)
  end

  # form_forのoptionと共用する場合 
#  def submit(value = "Save changes", *args)
#    @template.content_tag('p', super(value, *merge_options_with(args)))
#  end



  # hidden_fieldだけ特例扱い、以下理由
  #   見えないフィールドにtdタグは設定したくない
  #   form_for等で設定した独自オプション（:index等）だけは有効にしたい
  def hidden_field(field, *args)
    super(field, *merge_options_with(args))
  end
end

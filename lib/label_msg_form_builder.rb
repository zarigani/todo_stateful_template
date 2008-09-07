# form_forに:builder => LabelMsgFormBuilderオプションを設定することで、以下の機能が発揮される
# ===ラベル付きエラーメッセージ付きのフォームを生成する
#
#     <% form_for @slip do |f| %>
#       <p>
#         <%= f.label :number %>
#         <%= f.text_field :number %>
#         <%= f.error_messages_on :number %>
#       </p>
#     <% end %>
#
# :builder=>LabelMsgFormBuilderオプションを利用すると以下のように書ける
#
#     <% form_for @slip, :builder=>LabelMsgFormBuilder do |f| %>
#       <%= f.text_field :number %>
#     <% end %>
#
# ===:url, :html, :builder以外のform_forオプションは、そのブロック内のフォームにマージされる
#
#     <% form_for @user, :disabled=>true, :html=>{:autocomplete=>'off'}, :builder=>LabelMsgFormBuilder do |f| %>
#       <%= f.text_field :login %>
#       <%= f.text_field :email %>
#     <% end %>
#
# 上記:disabled=>trueは、以下のように展開される
#
#     <form action="/users/1" autocomplete="off" class="edit_user" id="edit_user_1" method="post">
#       <p>
#         <label for="user_login" style="display:table">ログイン名</label>
#         <input disabled="disabled" id="user_login" name="user[login]" size="30" type="text" value="" />
#       </p>
#       <p>
#         <label for="user_email" style="display:table">Eメール</label>
#         <input disabled="disabled" id="user_email" name="user[email]" size="30" type="text" value="" />
#       </p>
#     </form>
#
# - :login, :emailそれぞれのinputタグに<tt>disabled="disabled"</tt>が設定されているのが確認できる
# - ちなみに:html=>{:autocomplete=>'off'}はformタグで展開され、そのフォームブロック内のすべてのtext_fieldに効果を及ぼす
# - 同様の効果がその他のオプションについても欲しいため、このようなマージを行う仕様とした
class LabelMsgFormBuilder < BaseFormBuilder
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
  # - 見えないフィールドに余分なタグは設定したくない
  # - form_for等で設定した独自オプション（:index等）だけは有効にしたい
  def hidden_field(field, *args)
    super(field, *merge_options_with(args))
  end
end

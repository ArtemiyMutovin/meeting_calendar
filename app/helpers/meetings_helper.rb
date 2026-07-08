module MeetingsHelper
  # Кастомный выпадающий список (см. app/javascript/custom_select.js).
  # options — массив пар [подпись, значение], selected — выбранное значение.
  def custom_select(name, options, selected)
    selected_label = options.find { |_label, value| value == selected }&.first

    tag.div(class: "cselect") do
      hidden = hidden_field_tag(name, selected, class: "cselect__input")

      trigger = button_tag(selected_label, type: "button", class: "cselect__trigger")

      menu = tag.ul(class: "cselect__menu") do
        safe_join(options.map do |label, value|
          tag.li(label, class: "cselect__option #{'is-selected' if value == selected}",
            data: { value: value })
        end)
      end

      safe_join([hidden, trigger, menu])
    end
  end
end

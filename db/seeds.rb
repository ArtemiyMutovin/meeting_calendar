# Демо-данные: сотрудники и несколько встреч.
# Идемпотентно — можно запускать повторно.

names = [
  ["Анна Смирнова",   "anna@company.ru"],
  ["Борис Ковалёв",   "boris@company.ru"],
  ["Вера Николаева",  "vera@company.ru"],
  ["Григорий Орлов",  "grigory@company.ru"],
  ["Дарья Волкова",   "darya@company.ru"],
]

employees = names.map do |name, email|
  Employee.find_or_create_by!(name: name) { |e| e.email = email }
end

anna, boris, vera, grigory, darya = employees

today = Time.zone.today

def slot(date, from, to)
  [Time.zone.local(date.year, date.month, date.day, from),
   Time.zone.local(date.year, date.month, date.day, to)]
end

demo = [
  ["Планёрка по спринту", slot(today, 10, 11), [anna, boris, vera]],
  ["1-на-1: цели квартала", slot(today, 14, 15), [grigory, darya]],
  ["Ретро команды",        slot(today + 1, 11, 12), [anna, boris, grigory]],
]

demo.each do |title, (starts_at, ends_at), participants|
  next if Meeting.exists?(title: title, starts_at: starts_at)

  Meeting.create!(title: title, starts_at: starts_at, ends_at: ends_at, employees: participants)
end

puts "Готово: #{Employee.count} сотрудников, #{Meeting.count} встреч."

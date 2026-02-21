require 'date'

# приём данных с консоли
teams = ARGV[0]
start_date = Date.strptime(ARGV[1], '%d.%m.%Y')
end_date = Date.strptime(ARGV[2], '%d.%m.%Y')
output = ARGV[3]

# валидация всех данных
abort if teams.nil? || output.nil? || start_date.nil? || end_date.nil?
abort if start_date.year > end_date.year
abort if start_date.year == end_date.year && start_date.month > end_date.month
abort if start_date.year == end_date.year && start_date.month == end_date.month && start_date.day > end_date.day

lines = []
File.foreach(teams) do |line|
  lines << line
end

all_teams = []
lines.each do |line|
  all_teams << line.gsub(/^\d+[.)]\s*/, '').split(' — ') # сплитуем строку и убираем порядковый номер - получаем на выходе
  # массив, состоящий из двух строк - команды и города
end

# делаем все возможные пары игр
combs = all_teams.combination(2)

# берём все даты и делаем из них массив
dates = (start_date..end_date).to_a

# берём из этих дат только те, которые подходят нам (по дням недели)
valid_dates = dates.select { |date| date.friday? || date.saturday? || date.sunday? }

time_slots = []

# делаем массив всех возможных слотов по времени
valid_dates.each do |date|
  time_slots << Time.new(date.year, date.month, date.day, 12, 0, 0)
  time_slots << Time.new(date.year, date.month, date.day, 12, 0, 0)
  time_slots << Time.new(date.year, date.month, date.day, 15, 0, 0)
  time_slots << Time.new(date.year, date.month, date.day, 15, 0, 0)
  time_slots << Time.new(date.year, date.month, date.day, 18, 0, 0)
  time_slots << Time.new(date.year, date.month, date.day, 18, 0, 0)
end

# вычисляем шаг, для того, чтобы равномерно распределить игры
step = time_slots.size / combs.size

# открываем файл, проходимся по массиву пар с индексом, для того, чтобы определить в какой временной слот мы попадаем
# после чего генерируем красивые строки из частей пар и делаем в строке с интерполяцией нашу итоговую строку для календаря
# и записываем её в файл
File.open(output, 'w') do |f|
  combs.each_with_index do |pair, index|
    cur_time_index = (index * step).to_i
    game_time = time_slots[cur_time_index]
    t1_name = pair[0][0].strip
    t1_city = pair[0][1].strip
    t2_name = pair[1][0].strip
    t2_city = pair[1][1].strip
    f.puts "#{game_time.strftime('%d.%m.%Y (%A) %H:%M')} | #{t1_name} (#{t1_city}) vs #{t2_name} (#{t2_city})"
  end
end

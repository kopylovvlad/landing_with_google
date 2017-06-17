require 'bundler'
require 'sinatra'
Bundler.require

# файл-ключик с доступами
KEY_FILE = 'client_secret.json'

# ссылка на таблицу в google drive
FILE_URL = 'https://docs.google.com/spreadsheets/d/174Z4f7XvpaMSU9vky-___________/edit#gid=0'

# инициализация доступа к таблице на google drive
def worksheet
  session ||= GoogleDrive::Session.from_service_account_key(KEY_FILE)
  spreadsheet ||= session.spreadsheet_by_url(FILE_URL)
  @worksheet ||= spreadsheet.worksheets.first
end

# обработчик загрузки страницы
get '/' do
  @status = :hello
  erb :index
end

# обработчик отправки формы
post '/' do
  # собираем даные из формы
  new_row = [params['name'], params['email'], params['phone'], 'Новая заявка']

  begin
    # делаем попытку сохранить данные в google drive
    worksheet.insert_rows(worksheet.num_rows + 1, [new_row])
    worksheet.save
    @status = :success
    erb :index
  rescue
    # если не получилось сохранить - выведем сообщение об ошибке
    @status = :error
    erb :index
  end
end

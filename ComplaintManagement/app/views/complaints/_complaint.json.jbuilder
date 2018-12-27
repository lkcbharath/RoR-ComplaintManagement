json.extract! complaint, :id, :name, :title, :details, :created_at, :updated_at
json.url complaint_url(complaint, format: :json)

json.array!(@events) do |event|
  json.extract! event, :id, :provider, :external_id, :content
  json.url event_url(event, format: :json)
end

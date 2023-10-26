[
  {"type": "App","path": "NEW_NAME"},
  {"type": "Notifier", "context": "Blog.Post", "name": "PostNotifier", "message_names": ["post_created", "post_updated", "post_deleted"]},
  {"type": "Secret", "length": "34"},
  {"type": "Release", "docker": "true", "no_ecto": "true"},
  {"type": "Socket", "module": "User"},
  {"type": "Presence", "module": "User"},
  {"type": "Cert", "app": "my_app", "domain": "my_app.com"},
  {"type": "Channel", "module": "Room"},
  {"type": "Schema", "module": "Blog.Post", "name": "posts", "fields": [{"field_name": "title", "datatype": "string"}, {"field_name": "views", "datatype": "integer"}] }
]

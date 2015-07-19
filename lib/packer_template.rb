
# Helper methods for packer templates.

# "{{env `NAME`}}"
def env_var(name)
  var(:env, name.to_s.upcase)
end

# "`name`"
def quoted(name)
  "`#{name}`"
end

def upload_service(name)
  {
    type: 'file',
    source: "services/#{name}",
    destination: "/etc/systemd/system/#{name}"
  }
end

# "{{user `name`}}""
def user_var(name)
  var(:user, name.to_s)
end

# "{{function `name`}}" or "{{function}}"
def var(function, name = nil)
  if name
    "{{#{function} #{quoted(name)}}}"
  else
    "{{#{function}}}"
  end
end

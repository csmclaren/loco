function Header(elem)
  local content = {}

  for _, item in ipairs(elem.content) do
    if item.t == "Str" then
      local str = item.text:match("^%s*(.-)%s*$")
      table.insert(content, pandoc.Str(str))
    else
      table.insert(content, item)
    end
  end

  elem.content = content
  return elem
end

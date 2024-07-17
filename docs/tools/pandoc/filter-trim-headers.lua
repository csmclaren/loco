function Header(elem)
  local content = {}

  for _, item in ipairs(elem.content) do
    if item.t == "Str" then
      local text = item.text:match("^%s*(.-)%s*$")
      table.insert(content, pandoc.Str(text))
    else
      table.insert(content, item)
    end
  end

  elem.content = content
  return elem
end

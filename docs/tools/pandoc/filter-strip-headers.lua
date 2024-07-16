function Header(elem)
  local content = {}

  for _, item in ipairs(elem.content) do
    if item.t == "Str" then
      local str = {}

      for c in item.text:gmatch(".") do
        if c:byte() <= 127 then
          table.insert(str, c)
        end
      end

      str = table.concat(str)
      table.insert(content, pandoc.Str(str))
    else
      table.insert(content, item)
    end
  end

  elem.content = content
  return elem
end

function Header(elem)
  if elem.level >= 5 then
    elem.level = 4
  end

  return elem
end

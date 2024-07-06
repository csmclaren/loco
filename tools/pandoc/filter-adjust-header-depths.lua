function Header(elem)
  if elem.level == 1 then
    return {}
  else
    if elem.level >= 5 then
      elem.level = 4
    else
      elem.level = elem.level - 1
    end

    return elem
  end
end

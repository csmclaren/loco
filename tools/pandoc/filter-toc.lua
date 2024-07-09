local path = {}
local root = pandoc.BulletList{}

function Header(elem)
  local level = elem.level
  local text = pandoc.utils.stringify(elem.content)
  local id = elem.identifier
  local item = {pandoc.Link(text, "#" .. id), pandoc.BulletList{}}

  while level < #path + 1 do
    table.remove(path)
  end

  if level == #path + 1 then
    if #path >= 1 then
      table.insert(path[#path][2].content, item)
    else
      table.insert(root.content, item)
    end
    table.insert(path, item)
  else
    -- We ignore headers that descend too quickly,
    -- (i.e. with a level greater than one deeper than the parent),
    -- otherwise we would need to insert anonymous scaffolding nodes to support them.
  end

  return nil
end

function Pandoc(doc)
  for i, block in ipairs(doc.blocks) do
    if block.t == "Para" and #block.c == 1 and block.c[1].t == "Str" and block.c[1].text == "{{TOC}}" then
      doc.blocks[i] = root
    end
  end

  return doc
end

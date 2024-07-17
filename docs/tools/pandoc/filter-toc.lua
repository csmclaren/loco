local exclude_pattern = nil
local path = {}
local root = pandoc.BulletList{}

function Meta(meta)
  exclude_pattern = meta.filter_toc_exclude_pattern
  return meta
end

function Header(elem)
  local id = elem.identifier

  if exclude_pattern and string.match(id, exclude_pattern) then
    return nil
  end

  local level = elem.level

  while level < #path + 1 do
    table.remove(path)
  end

  local text = pandoc.utils.stringify(elem.content)
  -- Strip non-ASCII
  text = text:gsub("[^\x00-\x7F]", "")
  -- Trim whitespace
  text = text:match("^%s*(.-)%s*$")

  local item = {pandoc.Link(text, "#" .. id), pandoc.BulletList{}}

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

-- Ensure Meta is called before Header.
return {
  {Meta = Meta},
  {Header = Header},
  {Pandoc = Pandoc}
}
